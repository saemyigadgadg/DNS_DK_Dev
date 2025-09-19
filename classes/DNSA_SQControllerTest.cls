/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-19-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class DNSA_SQControllerTest {
    @TestSetup
    static void setUp() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('test01 - thisUser ::: ' + thisUser);

        AlertManager__c am1 = TestDataFactoryForSales.createAlertManager('New SQ Registration Alert');
        insert am1;

        MessageGroup__c mg = new MessageGroup__c();
        mg.Name = 'Quote Request';
        mg.SalesDistrict__c = 'DNSA';
        mg.SalesOffice__c = '414P';
        insert mg;

        Message_Group_Junction__c qqq = new Message_Group_Junction__c();
        qqq.User__c = thisUser.Id;
        qqq.Message_Group__c = mg.Id;
        insert qqq;

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler', 'QuoteTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];

        User dealer;
        User kaUser;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;

            kaUser = TestDataFactoryForSales.createDNSUser(profile.Name, 'KA');
            kaUser.LastName = 'ddd1';
            insert kaUser;
        }

        Message_Group_Junction__c qqq2 = new Message_Group_Junction__c();
        qqq2.User__c = kaUser.Id;
        qqq2.Message_Group__c = mg.Id;
        insert qqq2;

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'USD');
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

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            opty.CurrencyIsoCode = 'USD';
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            Quote dnsaQuote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Factory');
            dnsaQuote.CurrencyIsoCode = 'USD';
            dnsaQuote.DNSA_SalesOffice__c = '414P';
            insert dnsaQuote;

            QuoteLineItem dnsaQItem = TestDataFactoryForSales.createQuoteItem(dnsaQuote, entry, oItem, prod);
            insert dnsaQItem;
        }
    }

    @isTest
    static void getInit_Test() {
        Quote quote = [SELECT Id FROM Quote WHERE CurrencyIsoCode = 'USD' LIMIT 1];

        Test.startTest();
        DNSA_SQController.getInit(quote.Id);
        Test.stopTest();
    }

    @isTest
    static void createSQ_Test() {
        Quote dnsaQuote = [SELECT Id, AccountId FROM Quote WHERE CurrencyIsoCode = 'USD' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        User dealer = [SELECT Id, AccountId FROM User WHERE LastName = 'dealer' LIMIT 1];
        MessageGroup__c mg = [SELECT Id FROM MessageGroup__c WHERE Name = 'Quote Request' LIMIT 1];


        Test.startTest();
        SQRegistration__c sqReg    = new SQRegistration__c();
        sqReg.Name                 = 'TEST';
        sqReg.Model__c             = 'DBC 110S';
        sqReg.BaseCode__c          = prod.Id;
        sqReg.Account__c           = dnsaQuote.AccountId;
        sqReg.Stage__c             = 'Request';
        sqReg.Owner__c             = dealer.Id;
        sqReg.Dealer__c            = dealer.AccountId;
        sqReg.SalesOrganization__c = '1800';
        sqReg.SalesOffice__c       = '114F';
        sqReg.Quote__c             = dnsaQuote.Id;
        sqReg.DNSA_Sales_Team__c   = mg.Id;
        DNSA_SQController.createSQ(dnsaQuote.Id, sqReg);
        Test.stopTest();
    }

    @isTest
    static void createSQ_Test_kr() {
        Quote dnsaQuote = [SELECT Id, AccountId FROM Quote WHERE CurrencyIsoCode = 'USD' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        User dealer = [SELECT Id, AccountId FROM User WHERE LastName = 'dealer' LIMIT 1];
        MessageGroup__c mg = [SELECT Id FROM MessageGroup__c WHERE Name = 'Quote Request' LIMIT 1];
        User krUser = [SELECT Id FROM User WHERE LastName = 'ddd1' LIMIT 1];


        System.runAs(krUser) {
            Test.startTest();
            SQRegistration__c sqReg    = new SQRegistration__c();
            sqReg.Name                 = 'TEST';
            sqReg.Model__c             = 'DBC 110S';
            sqReg.BaseCode__c          = prod.Id;
            sqReg.Account__c           = dnsaQuote.AccountId;
            sqReg.Stage__c             = 'Request';
            sqReg.Owner__c             = dealer.Id;
            sqReg.Dealer__c            = dealer.AccountId;
            sqReg.SalesOrganization__c = '1800';
            sqReg.SalesOffice__c       = '114F';
            sqReg.Quote__c             = dnsaQuote.Id;
            sqReg.DNSA_Sales_Team__c   = mg.Id;
            DNSA_SQController.createSQ(dnsaQuote.Id, sqReg);
            Test.stopTest();
        }
    }
}