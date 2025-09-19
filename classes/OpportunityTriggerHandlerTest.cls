@isTest
public with sharing class OpportunityTriggerHandlerTest {
    static Opportunity testOpportunity1;
    static Opportunity testOpportunity2;
    static Model__c testModel;
    static Id priceBookId;
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

            // System.debug('test01 check query count 02 : ' + Limits.getQueries() + ' / ' + opty);
            // OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            // insert oItem;

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
        }
    }
    @isTest
    static void testRunning() {
        Test.startTest();
        
        // Opportunity op = [SELECT Id, MainCategory__c, SubCategory__c, RequestDelieveryDate__c, OwnerId FROM Opportunity WHERE StageName = 'Identified' LIMIT 1];
        // Model__c model = [SELECT Id FROM Model__c LIMIT 1];
        // // Opportunity op = testOpportunity1;
        // // Model__c model = testModel;

        // Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
        // insert newCompetitor;

        // OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(op, newCompetitor);
        // insert optyCompetitor;

        // Opportunity opup1 = new Opportunity();
        // opup1.Id = op.Id;
        // opup1.StageName = 'Validated';
        // opup1.ReasonForConsulting__c = '노후장비교체';
        // opup1.Prospective_Prd__c = model.Id;
        // opup1.MainCategory__c = op.MainCategory__c;
        // opup1.SubCategory__c = op.SubCategory__c;
        // opup1.Opportunity_Owner__c = op.OwnerId;
        // update opup1;

        // Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
        // bypassSet.add('ContactTriggerHandler');
        // bypassSet.add('OpptyCompetitorMappingTriggerHandler');

        // TriggerHandler.bypassedHandlers = bypassSet;
        OpportunityTriggerHandler.dummy();

        Test.stopTest();
    }

    // @isTest
    // static void testRunning2() {
    //     Test.startTest();

    //     Opportunity op = [SELECT Id, MainCategory__c, SubCategory__c, RequestDelieveryDate__c, OwnerId FROM Opportunity WHERE StageName = 'Validated' LIMIT 1];
    //     // Opportunity op = testOpportunity2;
    //     Model__c model = [SELECT Id FROM Model__c LIMIT 1];
    //     // Model__c model = testModel;

    //     Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
    //     insert newCompetitor;

    //     OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(op, newCompetitor);
    //     insert optyCompetitor;

    //     Opportunity opup1 = new Opportunity();
    //     opup1.Id = op.Id;
    //     opup1.StageName = 'Qualified';
    //     opup1.ReasonForConsulting__c = '노후장비교체';
    //     opup1.Prospective_Prd__c = model.Id;
    //     opup1.MainCategory__c = op.MainCategory__c;
    //     opup1.SubCategory__c = op.SubCategory__c;
    //     opup1.Opportunity_Owner__c = op.OwnerId;
    //     opup1.RequestDelieveryDate__c = op.RequestDelieveryDate__c;
    //     opup1.IsExport__c = false;
    //     opup1.ProcessedProduct__c = 'Qualified';
    //     update opup1;

    //     Opportunity opup2 = new Opportunity();
    //     opup2.Id = op.Id;
    //     opup2.StageName = 'Conditional Agreement';
    //     opup2.CustBudgetRoute__c = '노후장비교체';
    //     opup2.Amount__c = 123;
    //     opup2.HasFinalQuote__c = true;
    //     update opup2;

    //     Opportunity opup3 = new Opportunity();
    //     opup3.Id = op.Id;
    //     opup3.StageName = 'Closed Won';
    //     update opup3;

    //     Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
    //     bypassSet.add('ContactTriggerHandler');
    //     bypassSet.add('OpptyCompetitorMappingTriggerHandler');

    //     TriggerHandler.bypassedHandlers = bypassSet;

    //     Test.stopTest();
    // }

    // @isTest
    // static void testRunning3() {
    //     Test.startTest();

    //     Opportunity op = [SELECT Id, AccountId, RecordTypeId, MainCategory__c, SubCategory__c, RequestDelieveryDate__c, OwnerId FROM Opportunity WHERE StageName = 'Validated' LIMIT 1];
    //     // Opportunity op = testOpportunity2;
    //     System.debug('opop : ' + testOpportunity2);
    //     // Id pBookId = Test.getStandardPricebookId();
    //     Date today = Date.today();
    //     Opportunity opty2             = new Opportunity();
    //     opty2.AccountId               = op.AccountId;
    //     opty2.RecordTypeId            = op.RecordTypeId;
    //     opty2.Name                    = 'test opportunity';
    //     opty2.StageName               = 'Identified';
    //     opty2.LeadSource              = 'Employee Referral';
    //     opty2.CurrencyIsoCode         = 'KRW';
    //     opty2.Pricebook2Id            = priceBookId;
    //     opty2.OwnerId                 = op.OwnerId;
    //     opty2.MainCategory__c         = 'MB';
    //     opty2.SubCategory__c          = 'MB2';
    //     opty2.IsTooling__c            = 'MY';
    //     opty2.Country__c              = 'US';
    //     opty2.Budget__c               = 100000000;
    //     opty2.RequestDelieveryDate__c = today.addMonths(2);
    //     opty2.CloseDate               = today.addMonths(1);
    //     opty2.OpportunityIdentifier__c = op.OwnerId;
    //     opty2.Opportunity_Owner__c    = op.OwnerId;
    //     insert opty2;

        
    //     // Model__c model = [SELECT Id FROM Model__c LIMIT 1];
    //     Model__c model = testModel;

    //     Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
    //     insert newCompetitor;

    //     OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty2, newCompetitor);
    //     insert optyCompetitor;

    //     Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
    //     bypassSet.add('ContactTriggerHandler');
    //     bypassSet.add('OpptyCompetitorMappingTriggerHandler');

    //     TriggerHandler.bypassedHandlers = bypassSet;

    //     Test.stopTest();
    // }


    // @isTest
    // static void testRunning4() {
    //     Test.startTest();
    //     RecordType type  = TestDataFactoryForSales.getRecordType('Turn_Key', 'Opportunity');

    //     Opportunity op = [SELECT Id, AccountId, RecordTypeId, MainCategory__c, SubCategory__c, RequestDelieveryDate__c, OwnerId FROM Opportunity WHERE StageName = 'Validated' LIMIT 1];
    //     // Opportunity op = testOpportunity2;
    //     System.debug('opop : ' + testOpportunity2);
    //     // Id pBookId = Test.getStandardPricebookId();
    //     Date today = Date.today();
    //     Opportunity opty2             = new Opportunity();
    //     opty2.AccountId               = op.AccountId;
    //     opty2.RecordTypeId            = type.Id;
    //     opty2.Name                    = 'test opportunity';
    //     opty2.StageName               = 'Identified';
    //     opty2.LeadSource              = 'Employee Referral';
    //     opty2.CurrencyIsoCode         = 'KRW';
    //     opty2.Pricebook2Id            = priceBookId;
    //     opty2.OwnerId                 = op.OwnerId;
    //     opty2.MainCategory__c         = 'MB';
    //     opty2.SubCategory__c          = 'MB2';
    //     opty2.IsTooling__c            = 'MY';
    //     opty2.Country__c              = 'US';
    //     opty2.Budget__c               = 100000000;
    //     opty2.RequestDelieveryDate__c = today.addMonths(2);
    //     opty2.CloseDate               = today.addMonths(1);
    //     opty2.OpportunityIdentifier__c = op.OwnerId;
    //     opty2.Opportunity_Owner__c    = op.OwnerId;
    //     insert opty2;

        
    //     // Model__c model = [SELECT Id FROM Model__c LIMIT 1];
    //     Model__c model = testModel;

    //     Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
    //     insert newCompetitor;

    //     OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty2, newCompetitor);
    //     insert optyCompetitor;

    //     Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
    //     bypassSet.add('ContactTriggerHandler');
    //     bypassSet.add('OpptyCompetitorMappingTriggerHandler');

    //     TriggerHandler.bypassedHandlers = bypassSet;

    //     Test.stopTest();
    // }
}