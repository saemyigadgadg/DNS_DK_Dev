/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 09-01-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-20-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class RequestedSQTriggerHandler_TEST {
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

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler', 'QuoteTriggerHandler'
        , 'OpportunityLineItemTriggerHandler', 'QuoteLineItemTriggerHandler', 'SQRegistrationTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        User kaUser;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;

            kaUser = TestDataFactoryForSales.createDNSUser('System Administrator', 'KA');
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

            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;

            Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
            insert accessory;

            Quote dnsaQuote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Factory');
            dnsaQuote.CurrencyIsoCode = 'USD';
            dnsaQuote.DNSA_SalesOffice__c = '414P';
            insert dnsaQuote;

            QuoteLineItem dnsaQItem = TestDataFactoryForSales.createQuoteItem(dnsaQuote, entry, oItem, prod);
            insert dnsaQItem;
        }
    }

    @isTest
    static void triggerInsertTest() {
        Quote dnsaQuote = [SELECT Id, AccountId FROM Quote WHERE CurrencyIsoCode = 'USD' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        User dealer = [SELECT Id, AccountId FROM User WHERE LastName = 'dealer' LIMIT 1];
        MessageGroup__c mg = [SELECT Id FROM MessageGroup__c WHERE Name = 'Quote Request' LIMIT 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'SQRegistration__c' AND DeveloperName = 'DNSA' LIMIT 1];

        SQRegistration__c sqReg    = new SQRegistration__c();
        sqReg.Name                 = 'TEST';
        sqReg.RecordTypeId         = rt.Id;
        sqReg.Model__c             = 'DBC 110S';
        sqReg.BaseCode__c          = prod.Id;
        sqReg.Account__c           = dnsaQuote.AccountId;
        sqReg.Stage__c             = 'Request';
        sqReg.Owner__c             = dealer.Id;
        sqReg.Dealer__c            = dealer.AccountId;
        sqReg.SalesOrganization__c = '1800';
        sqReg.Quote__c             = dnsaQuote.Id;
        sqReg.DNSA_Sales_Team__c   = mg.Id;
        insert sqReg;

        Test.startTest();
        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqReg.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;
        Test.stopTest();
    }

    @isTest
    static void triggerUpdateTest() {
        Quote dnsaQuote = [SELECT Id, AccountId FROM Quote WHERE CurrencyIsoCode = 'USD' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        User dealer = [SELECT Id, AccountId FROM User WHERE LastName = 'dealer' LIMIT 1];
        MessageGroup__c mg = [SELECT Id FROM MessageGroup__c WHERE Name = 'Quote Request' LIMIT 1];

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
        insert sqReg;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqReg.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        Test.startTest();
        req.Name = 'ddddddddddddddddddddddddddddddddddddddddd';
        update req;
        Test.stopTest();
    }
}