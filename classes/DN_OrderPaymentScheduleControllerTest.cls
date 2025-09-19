@isTest
public with sharing class DN_OrderPaymentScheduleControllerTest {
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

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-ORDER-015', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc.Id);
        insert ifClass;

        Interface__c ifc02 = TestDataFactoryForSales.createinterface('IF-ORDER-014', 'Real-Time');
        insert ifc02;

        InterfaceClasses__c ifClass02 = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc02.Id);
        insert ifClass02;

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
            order.CustomerOrderNo__c = 'test01';
            insert order;

            Order order02 = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order02.CustomerOrderNo__c = 'test02';
            order02.HasPricingProcessed__c = true;
            order02.DCAmount__c = 132880000;
            insert order02;

            PaymentSchedule__c payment = TestDataFactoryForSales.createPaymentSchedule(order02.Id);
            insert payment;

            Decimal tempAmt   = order02.DCAmount__c;
            Decimal tempAmt02 = tempAmt * 0.1;
            Decimal tempAmt03 = tempAmt + tempAmt02;

            PaymentScheduleItem__c paymentItem = TestDataFactoryForSales.createPaymentItem(payment.Id);
            paymentItem.InstallmentPrincipal__c = tempAmt03;
            insert paymentItem;
        }
    }

    @IsTest
    static void fetchFieldInfoTest(){
        Order order = [SELECT Id FROM Order WHERE CustomerOrderNo__c = 'test01' LIMIT 1];

        Test.startTest();

        DN_OrderPaymentScheduleController.fetchFieldInfo(order.Id);
        DN_OrderPaymentScheduleController.fetchInitData(order.Id);

        Test.stopTest();
    }

    @IsTest
    static void savePaymentScheduleTest(){
        Order order = [SELECT Id FROM Order WHERE CustomerOrderNo__c = 'test01' LIMIT 1];

        Test.startTest();

        DN_OrderPaymentScheduleController.HeaderWrapper hWrap = new DN_OrderPaymentScheduleController.HeaderWrapper();
        hWrap.docuDate = Date.today().addDays(30);
        hWrap.reqDDate = Date.today().addDays(30);
        hWrap.draftPick = '[영업지원Part]2401_0074';
        hWrap.draftText = '[영업지원Part]2401_0074';
        hWrap.draftcheck = 'Success';
        hWrap.totalAmt = 55000000;
        hWrap.curr = 'KRW';

        List<DN_OrderPaymentScheduleController.ItemWrapper> iWrapList = new List<DN_OrderPaymentScheduleController.ItemWrapper>();
        DN_OrderPaymentScheduleController.ItemWrapper iWrap = new DN_OrderPaymentScheduleController.ItemWrapper('KRW');
        iWrap.type = 'P01';
        iWrap.scheduleDate = Date.today().addDays(20);
        iWrap.paymentTerms = 'CP00';
        iWrap.days = 0;
        iWrap.principal = 55000000;
        iWrapList.add(iWrap);

        DN_OrderPaymentScheduleController.savePaymentSchedule(order.Id, hWrap, JSON.serialize(iWrapList));
        DN_OrderPaymentScheduleController.fetchInitData(order.Id);

        Test.stopTest();
    }

    @IsTest
    static void checkDraftNoTest(){
        Order order = [SELECT Id FROM Order WHERE CustomerOrderNo__c = 'test01' LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Draft());
        DN_OrderPaymentScheduleController.checkDraftNo('test', 'test', order.Id);

        Test.stopTest();
    }

    public class MockIF_ERP_Draft implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "S" }, '
                + '"T_LIST": [ '
                + ' {"DOC_TITLE": "test", "DOC_NO": "test", "DOODREAM_DOC_NO": "test" } '
                + ' ]}'
            );
            return res;
        }
    }

    @IsTest
    static void sendScheduleToERPTest(){
        Order order = [SELECT Id FROM Order WHERE CustomerOrderNo__c = 'test02' LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Schedule());
        System.runAs(dealer) {

            DN_OrderPaymentScheduleController.sendScheduleToERP(order.Id);
        }

        Test.stopTest();
    }

    public class MockIF_ERP_Schedule implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                ' { '
                + ' "O_IPLAN":"0000433259", '
                + ' "O_MESSAGE":"S:Succesfully finished", '
                + ' "O_RETURN":[] '
                +' } '
            );
            return res;
        }
    }
}