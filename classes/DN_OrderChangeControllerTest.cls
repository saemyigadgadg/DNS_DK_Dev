@isTest
public with sharing class DN_OrderChangeControllerTest {
    
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        User dealer;
        Account dealerAcc;
        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer.ManagerId = thisUser.Id;
            insert dealer;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        AlertManager__c alert = TestDataFactoryForSales.createAlertManager('OrderChangeRequest');
        insert alert;

        Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler', 'AccountTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            insert area;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            insert order;
    
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            OrderChangeRequest__c changeRequest = TestDataFactoryForSales.createOrderChangeRequest(order.Id, dealerAcc.Id);
            insert changeRequest;
        }
    }

    @IsTest
    static void orderChangeRequestTest(){
        Order order = [SELECT Id, CurrencyIsoCode, QuoteId FROM Order LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        OrderChangeRequest__c changeRequest = [SELECT Id FROM OrderChangeRequest__c LIMIT 1];
        
        Test.startTest();
        System.runAs(dealer){
            DN_OrderChangeController.sendNotiToManager(order.Id, changeRequest.Id);
        }
        Test.stopTest();
        
    }
}