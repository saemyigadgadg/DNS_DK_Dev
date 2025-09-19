@isTest
public with sharing class DN_OrderConfirmRequestBtnControllerTest {
    @testSetup
    static void setupTestData() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('test01 - thisUser ::: ' + thisUser);

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler', 'QuoteTriggerHandler'};
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

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-ORDER-001', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc.Id);
        insert ifClass;

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        System.runAs(dealer) {
            Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
            insert parentAcc;

            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
            acc.CustomerCode__c   = 'CUST001';
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
        }
    }

    @isTest
    static void testValidation() {

        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        DN_OrderConfirmRequestBtnController.validateDeliveryConfrim(order.Id);

        Set<String> bypassSet = new Set<String>{'OrderTriggerHandler'};
        order.ERPOrderNo__c = 'test';
        update order;

        DN_OrderConfirmRequestBtnController.validateDeliveryConfrim(order.Id);

        try {
            DN_OrderConfirmRequestBtnController.validateDeliveryConfrim(null);
        } catch (Exception e) {
            System.debug('testValidation');
        }

        Test.stopTest();

    }

    @isTest
    static void testConfirm() {

        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Success());

        DN_OrderConfirmRequestBtnController.requestConfirm(order.Id);

        Test.stopTest();

    }

    @isTest
    static void testConfirm02() {

        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Fail());

        DN_OrderConfirmRequestBtnController.requestConfirm(order.Id);

        Test.stopTest();

    }

    private class MockIF_ERP_Success implements HttpCalloutMock {
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

    private class MockIF_ERP_Fail implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "E", "MESSAGE": "ERROR" } }'
            );
            return res;
        }
    }
}