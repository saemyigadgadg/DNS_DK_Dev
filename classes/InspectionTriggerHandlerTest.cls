@isTest
public with sharing class InspectionTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;

            User qmUser = TestDataFactoryForSales.createDNSUser('품질 QM', 'QualityTeam');
            insert qmUser;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('InspectionCreation'));
        alertList.add(TestDataFactoryForSales.createAlertManager('InspectionConfirmed'));
        insert alertList;

        Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
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
    
            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;
    
            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.Status = 'Confirmed';
            insert order;
    
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;
    
            OrderItem oItemSQ = TestDataFactoryForSales.createOrderSQ(order.Id, prod.Id, entry.Id, qItem.Id, sq.Id, '000020');
            insert oItemSQ;

            Quote dnsaQuote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
            insert dnsaQuote;

            QuoteLineItem dnsaQItem = TestDataFactoryForSales.createQuoteItem(dnsaQuote, entry, oItem, prod);
            insert dnsaQItem;

            Order dnsaOrder = TestDataFactoryForSales.createDNSAOrder(acc, opty, dnsaQuote, dealer);
            dnsaOrder.Status = 'Confirmed';
            insert dnsaOrder;
        }
    }

    @isTest
    static void testInspection01() {

        Order order = [SELECT Id FROM Order WHERE SalesChannelType__c <> 'DNSA' LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        User qmUser = [SELECT Id FROM User WHERE Profile.Name = '품질 QM' LIMIT 1];
        
        Test.startTest();

        Inspection__c inspection = TestDataFactoryForSales.createInspection(order.Id, qmUser.Id);
        insert inspection;

        inspection.QualityConfirm__c = 'Y';
        update inspection;
        
        Test.stopTest();
    }

    @isTest
    static void testInspection02() {

        Order order = [SELECT Id FROM Order WHERE SalesChannelType__c = 'DNSA' LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        User qmUser = [SELECT Id FROM User WHERE Profile.Name = '품질 QM' LIMIT 1];
        
        Test.startTest();

        Inspection__c inspection = TestDataFactoryForSales.createInspection(order.Id, qmUser.Id);
        insert inspection;

        inspection.QualityConfirm__c = 'Y';
        update inspection;
        
        Test.stopTest();
    }
}