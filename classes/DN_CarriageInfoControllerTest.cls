@isTest
public with sharing class DN_CarriageInfoControllerTest {
    
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

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

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-DELIV-004', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_DELIV', ifc.Id);
        insert ifClass;

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
            order.ERPPSONo__c  = 'test';
            insert order;

            DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
            insert dOrder;

            DeliveryOrder__c dOrder2 = TestDataFactoryForSales.createDeliveryOrder(order.Id);
            dOrder2.ERPDONo__c = 'test';
            insert dOrder2;
        }
    }

    @IsTest
    static void initTest01(){
        DeliveryOrder__c dOrder = [SELECT Id FROM DeliveryOrder__c WHERE ERPDONo__c = null LIMIT 1];

        Test.startTest();

        DN_CarriageInfoController.fetchInit(dOrder.Id);
        
        Test.stopTest();
    }

    @IsTest
    static void initTest02(){
        DeliveryOrder__c dOrder = [SELECT Id FROM DeliveryOrder__c WHERE ERPDONo__c != null LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_CARRIAGE());

        DN_CarriageInfoController.fetchInit(dOrder.Id);
        
        Test.stopTest();
    }

    @IsTest
    static void initTest03(){
        DeliveryOrder__c dOrder = [SELECT Id FROM DeliveryOrder__c WHERE ERPDONo__c != null LIMIT 1];

        Test.startTest();
        try {
            DN_CarriageInfoController.fetchInit(null);
        } catch (Exception e) {
            System.debug('ERROR Test : ' + e.getMessage());
        }
        
        Test.stopTest();
    }

    private class MockIF_ERP_CARRIAGE implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "S", "MESSAGE": "Success" } }'
            );
            return res;
        }
    }
}