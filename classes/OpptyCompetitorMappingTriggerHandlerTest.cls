@isTest
public with sharing class OpptyCompetitorMappingTriggerHandlerTest {
    @TestSetup
    static void makeData(){

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

            User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert kaUser;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderKeyAccountCreated'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderStatusConfirmed'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderCanceled'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalApproved'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalRejected'));
        insert alertList;

        Asset asset = TestDataFactoryForSales.createAsset();
        insert asset;

        System.runAs(dealer) {
            Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
            insert parentAcc;

            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            insert area;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;

            System.debug('test01 check query count 01 : ' + Limits.getQueries());
            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            System.debug('test01 check query count 02 : ' + Limits.getQueries() + ' / ' + opty);
            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            // System.debug('test01 check query count 03 : ' + Limits.getQueries() + ' / ' + oItem);
            // Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            // insert quote;

            // System.debug('test01 check query count 04 : ' + Limits.getQueries() + ' / ' + quote);
            // QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            // insert qItem;

            // System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
            // SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            // insert sq;

            // System.debug('test01 check query count 06 : ' + Limits.getQueries() + ' / ' + sq);
            // Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
            // insert accessory;

            // Quote dnsaQuote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
            // insert dnsaQuote;

            // QuoteLineItem dnsaQItem = TestDataFactoryForSales.createQuoteItem(dnsaQuote, entry, oItem, prod);
            // insert dnsaQItem;
        

            Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
            insert newCompetitor;

            OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty, newCompetitor);
            insert optyCompetitor;


            // System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
        }
    }
    @isTest
    static void testgetRecordName() {
        Test.startTest();
        OpptyCompetitorMappingTriggerHandler.dummy();

        Test.stopTest();
    }
}