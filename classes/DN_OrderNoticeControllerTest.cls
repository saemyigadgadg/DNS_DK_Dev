@isTest
public with sharing class DN_OrderNoticeControllerTest {
    
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

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-ORDER-003', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc.Id);
        insert ifClass;

        String orderNotice  = '{ "O_RETURN": { "TYPE": "S" }, '
                            + '"OS_TITLE": {"TITLE": "Test Title"},'
                            + '"OS_HEADER": {"VBELN": "0001234567", "APP_DATE": "2024-01-01"},'
                            + '"OT_DATA": [],'
                            + '"OT_INCOM": ['
                            + '   {"INCOM_CODE": "P01", "ZTERM": "T001", "ZBD1T": "30 Days", "EST_DAT": "2024-02-01", "EST_AMT": "1000"}'
                            + '],'
                            + '"OT_INCOMH": [],'
                            + '"OT_TEXT": [],'
                            + '"OT_TEXT02": []'
                            + '}';

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
            order.ERPOrderNo__c  = 'test';
            order.OrderNotice__c = orderNotice;
            insert order;
        }
    }

    @IsTest
    static void noticeInitTest(){
        Order order = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();

        ApexPages.currentPage().getParameters().put('Id', order.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(order);
        DN_OrderNoticeController controller = new DN_OrderNoticeController(sc);

        Test.stopTest();
    }

    @IsTest
    static void validationTest(){
        Order order = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_OrderNotice());

        DN_OrderNoticeController.validateOrder(order.Id, TRUE);
        DN_OrderNoticeController.validateOrder(order.Id, FALSE);
        
        Test.stopTest();
    }

    private class MockIF_ERP_OrderNotice implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "S" }, '
                + '"OS_TITLE": {"TITLE": "Test Title"},'
                + '"OS_HEADER": {"VBELN": "0001234567", "APP_DATE": "2024-01-01"},'
                + '"OT_DATA": [],'
                + '"OT_INCOM": ['
                + '   {"INCOM_CODE": "P01", "ZTERM": "T001", "ZBD1T": "30 Days", "EST_DAT": "2024-02-01", "EST_AMT": "1000"}'
                + '],'
                + '"OT_INCOMH": [],'
                + '"OT_TEXT": [],'
                + '"OT_TEXT02": []'
                + '}'
            );
            return res;
        }
    }



    // @IsTest
    // static void noticeTest(){

    //     Order order = [SELECT Id, CurrencyIsoCode, QuoteId FROM Order LIMIT 1];
    //     User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];

    //     TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

    //     Test.startTest();
        
    //     Test.setMock(HttpCalloutMock.class, new MockIF_ERP_DELIV());
    //     DN_OrderCheckDownpaymnetController.callIFDownPayment(order.Id);
    //     Test.stopTest();
    // }
}