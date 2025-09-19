@isTest 
public with sharing class DN_CloneOpportunityControllerTest {
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

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

        Product2 prod = TestDataFactoryForSales.createProduct();
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

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
            insert newCompetitor;

            OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty, newCompetitor);
            insert optyCompetitor;

            Opportunity optyTurnkey = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_key');
            insert optyTurnkey;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;
        }

    }

    @isTest
    static void testOpptyCloneCreate() {
        Opportunity original = [SELECT Id, RecordTypeId, CloseDate, StageName, CurrencyIsoCode, AccountId FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id =: original.AccountId];
        User dealer = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        Opportunity newOpp = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');

        Test.startTest();
        DN_CloneOpportunityController.opptyCloneCreate(newOpp, original.Id, 'ChangeType', 'General');
        Test.stopTest();
    }

    @isTest
    static void testOpptyCloneCreate02() {
        Opportunity original = [SELECT Id, RecordTypeId, CloseDate, StageName, CurrencyIsoCode, AccountId FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id =: original.AccountId];
        User dealer = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        Opportunity newOpp = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
        newOpp.RecordTypeId = null;

        Test.startTest();
        DN_CloneOpportunityController.opptyCloneCreate(newOpp, original.Id, 'ChangeType', 'General');
        Test.stopTest();
    }



    @isTest
    static void testgetStage(){
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        DN_CloneOpportunityController.getStage(opty.Id);

        try {
            DN_CloneOpportunityController.getStage(null);
        } catch (Exception ex) {
            System.debug('error');
        }
        Test.stopTest();
    }

    @isTest
    static void testChangeRecordTypes(){
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        DN_CloneOpportunityController.changeRecordTypes(opty.Id);

        try {
            DN_CloneOpportunityController.changeRecordTypes(null);
        } catch (Exception ex) {
            System.debug('error');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetRecordName(){
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        DN_CloneOpportunityController.getRecordName(opty.Id);

        try {
            DN_CloneOpportunityController.getRecordName(null);
        } catch (Exception ex) {
            System.debug('error');
        }
        Test.stopTest();
    }

}