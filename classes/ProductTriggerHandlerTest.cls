/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-06-02
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-06-02   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class ProductTriggerHandlerTest {
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
        Account dealerAcc;
        Contact dealerCon;

        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            dealerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert dealerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerCon);
            insert dealer;

            User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert kaUser;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        prod.IsStrategicMaterial__c = false;
        prod.HEIndicator__c = false;
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;


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

            System.debug('test01 check query count 03 : ' + Limits.getQueries() + ' / ' + oItem);
            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            System.debug('test01 check query count 04 : ' + Limits.getQueries() + ' / ' + quote);
            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;

            System.debug('test01 check query count 06 : ' + Limits.getQueries() + ' / ' + sq);
            Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
            insert accessory;

            Quote dnsaQuote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
            insert dnsaQuote;

            QuoteLineItem dnsaQItem = TestDataFactoryForSales.createQuoteItem(dnsaQuote, entry, oItem, prod);
            insert dnsaQItem;
        
            Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
            insert newCompetitor;

            OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty, newCompetitor);
            insert optyCompetitor;

        }
    }


    @isTest
    static void testUpdate() {
        Test.startTest();

        Product2 prod = [SELECT Id, Name, IsStrategicMaterial__c, HEIndicator__c FROM Product2 WHERE Name = 'DNM4504-F0MP-1-K30' LIMIT 1];
        prod.IsStrategicMaterial__c = true;
        prod.HEIndicator__c = true;
        update prod;

        Test.stopTest();
    }
}