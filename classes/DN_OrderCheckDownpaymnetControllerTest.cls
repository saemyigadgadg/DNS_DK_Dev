@isTest
public with sharing class DN_OrderCheckDownpaymnetControllerTest {
    
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

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-DELIV-003', 'Real-Time');
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
            order.Status = 'Confirmed';
            order.ERPOrderNo__c = 'test';
            insert order;
    
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            PaymentSchedule__c payment = TestDataFactoryForSales.createPaymentSchedule(order.Id);
            insert payment;

            PaymentScheduleItem__c paymentItem = TestDataFactoryForSales.createPaymentItem(payment.Id);
            insert paymentItem;
        }
    }

    @IsTest
    static void validationTest(){

        Order order = [SELECT Id, CurrencyIsoCode, QuoteId FROM Order LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        Test.startTest();
        
        try {

            order.ERPOrderNo__c = '';
            update order;

            DN_OrderCheckDownpaymnetController.callIFDownPayment(order.Id);

        } catch (Exception e) {
            System.debug('error ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void successTest(){

        Order order = [SELECT Id, CurrencyIsoCode, QuoteId FROM Order LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_DELIV());
        DN_OrderCheckDownpaymnetController.callIFDownPayment(order.Id);
        Test.stopTest();
    }

    @IsTest
    static void failTest(){

        Order order = [SELECT Id, CurrencyIsoCode, QuoteId FROM Order LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_DELIV_Fail());
        DN_OrderCheckDownpaymnetController.callIFDownPayment(order.Id);
        Test.stopTest();
    }

    public class MockIF_ERP_DELIV implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "S" }, '
                + '"T_LIST": [ '
                + ' {"INCOM_CODE": "P01", "SERIAL_NO": "01", "CLRAMT": "11510000" } '
                + ' ]}'
            );
            return res;
        }
    }

    public class MockIF_ERP_DELIV_Fail implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "E", "MESSAGE": "error" }}'
            );
            return res;
        }
    }

}