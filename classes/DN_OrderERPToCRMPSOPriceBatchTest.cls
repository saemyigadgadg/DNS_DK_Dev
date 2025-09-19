@isTest
public with sharing class DN_OrderERPToCRMPSOPriceBatchTest {
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

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-ORDER-022', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc.Id);
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
            order.CustomerOrderNo__c = 'test01';
            order.ERPPSONo__c = '0201970591';
            insert order;
        }
    }

    @IsTest
    static void fetchFieldInfoTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP());

        Database.executeBatch(new DN_OrderERPToCRMPSOPriceBatch(), 50);
        Database.executeBatch(new DN_OrderERPToCRMPSOPriceBatch('20250526','20250526'), 50);

        Test.stopTest();
    }

    public class MockIF_ERP implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ ' 
                + ' "O_RETURN": { "TYPE": "S", "MESSAGE": "Success" } '
                + ' , "OT_NET_VALUE": [ '
                + ' {"NETWR":"93110000.00","VBELN":"0201970591","WAERK":"KRW","MWST":"9311000.00"} '
                +' ]'
                + ' }'
            );
            return res;
        }
    }
}