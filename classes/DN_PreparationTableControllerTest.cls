@isTest
public with sharing class DN_PreparationTableControllerTest {
    
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        // TestDataFactoryForSales.activatePriceBook();

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        System.runAs(dealer) {

            Asset asset = TestDataFactoryForSales.createAsset();
            insert asset;

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
    
            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;
    
            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.Status = 'Confirmed';
            order.SerialNumber__c = 'MH0014-000391';
            order.SOSerialNumber__c = asset.Id;
            insert order;
    
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;
        }
    }

    @isTest
    static void testFetchTableItems() {
        Test.startTest();
        DN_PreparationTableController.fetchTableItems();
        Test.stopTest();
    }

    @isTest
    static void testGetMode() {

        Order order = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        User u = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        PreparationCheckList__c preparation = TestDataFactoryForSales.createPreparation(order.Id, acc.Id, con.Id, u.Id);
        insert preparation;

        TriggerHandler.bypassedHandlers = new Set<String>{'TicketTriggerHandler'};

        Case c = new Case(
            Status = 'New'
            , PreparationCheckList__c = preparation.Id
        );
        insert c;

        Test.startTest();
        DN_PreparationTableController.getMode(preparation.Id);
        Test.stopTest();
    }
}