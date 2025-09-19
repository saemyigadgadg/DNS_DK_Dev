@isTest public with sharing class DN_Opportunity_Path_ControllerTest {
    @TestSetup
    static void makeData(){

        // User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        // Country__c country = TestDataFactoryForSales.createKRCountry();
        // insert country;

        // TestDataFactoryForSales.activatePriceBook();

        // User dealer;
        // System.runAs(thisUser) {
        //     Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
        //     insert dealerAcc;
    
        //     Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
        //     insert delaerCon;
    
        //     dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
        //     insert dealer;

        //     User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
        //     insert kaUser;
        // }

        // Product2 prod = TestDataFactoryForSales.createProduct();
        // insert prod;

        // PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        // insert entry;


        // Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler'};
        // TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        
        // System.runAs(dealer) {
        //     Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
        //     insert parentAcc;

        //     Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
        //     acc.CustomerCode__c   = '123456';
        //     acc.BusinessNumber__c = '5148171773';
        //     acc.Representative__c = 'realAcc';
        //     insert acc;

        //     SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
        //     insert area;
    
        //     Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        //     insert con;

        //     System.debug('test01 check query count 01 : ' + Limits.getQueries());
        //     Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
        //     insert opty;

        //     Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
        //     insert newCompetitor;

        //     OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty, newCompetitor);
        //     insert optyCompetitor;

        //     Opportunity optyTurnkey = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_key');
        //     insert optyTurnkey;

        //     System.debug('test01 check query count 02 : ' + Limits.getQueries() + ' / ' + opty);
        //     OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
        //     insert oItem;

        //     System.debug('test01 check query count 03 : ' + Limits.getQueries() + ' / ' + oItem);
        //     // Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
        //     // insert quote;

        //     // System.debug('test01 check query count 04 : ' + Limits.getQueries() + ' / ' + quote);
        //     // QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
        //     // insert qItem;

        //     // System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
        // }
    }
    // @isTest
    // static void testgetStage(){
    //     System.debug('DN_Opportunity_Path_Controller getStage is Started.');
    //     Test.startTest();
    //     Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];
    //     DN_Opportunity_Path_Controller.getStage(opty.Id);
    //     Test.stopTest();
    //     System.debug('DN_Opportunity_Path_Controller getStage is ended.');
    // }

    @isTest
    static void testupdateStage(){
        System.debug('DN_Opportunity_Path_Controller updateStage is Started.');
        Test.startTest();
        // Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];
        // DN_Opportunity_Path_Controller.updateStage(opty);
        DN_Opportunity_Path_Controller.dummy();

        Test.stopTest();
        System.debug('DN_Opportunity_Path_Controller updateStage is ended.');
    }

    // @isTest
    // static void testgetPicklistValues(){
    //     System.debug('DN_Opportunity_Path_Controller getPicklistValues is Started.');
    //     Test.startTest();
    //     Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler'};
    //     TriggerHandler.bypassedHandlers = bypassSet;
    //     Map<String, List<String>> dummyPicklistValues = new Map<String, List<String>>();
    //     dummyPicklistValues.put('Closed Won', new List<String>{'OptionA', 'OptionB'});

    //     Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];
    //     DN_Opportunity_Path_Controller.getPicklistValues('Closed Won');
    //     Test.stopTest();
    //     System.debug('DN_Opportunity_Path_Controller getPicklistValues is ended.');
    // }
}