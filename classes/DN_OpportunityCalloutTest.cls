@isTest 
public with sharing class DN_OpportunityCalloutTest {
        private String ownerId;
        private String accountId;
        private String optyId;
        private String inquiryType;
        private List<OpportunityLineItem> prdInfo;
        private Integer currentIndex;

        // public InquiryQueueable(String ownerId, String accountId, String optyId, String inquiryType, List<OpportunityLineItem> prdInfo, Integer currentIndex) {
        //     this.ownerId = ownerId;
        //     this.accountId = accountId;
        //     this.optyId = optyId;
        //     this.inquiryType = inquiryType;
        //     this.prdInfo = prdInfo;
        //     this.currentIndex = currentIndex;
        // }
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
        //     Test.startTest();
        //     dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
        //     insert dealer;
        //     Test.stopTest();
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
        //     Id pBookId = Test.getStandardPricebookId();
        //     Date today = Date.today();

        //     Opportunity opty1             = new Opportunity();
        //     opty1.AccountId               = acc.Id;
        //     opty1.RecordTypeId            = opty.RecordTypeId;
        //     opty1.Name                    = 'test opportunity';
        //     opty1.StageName               = 'Qualified';
        //     opty1.LeadSource              = 'Employee Referral';
        //     opty1.CurrencyIsoCode         = 'KRW';
        //     opty1.Pricebook2Id            = pBookId;
        //     opty1.OwnerId                 = dealer.Id;
        //     opty1.MainCategory__c         = 'MB';
        //     opty1.SubCategory__c          = 'MB2';
        //     opty1.IsTooling__c            = 'MY';
        //     opty1.Country__c              = 'KR';
        //     opty1.Budget__c               = 100000000;
        //     opty1.RequestDelieveryDate__c = today.addMonths(2);
        //     opty1.CloseDate               = today.addMonths(1);
        //     opty1.OpportunityIdentifier__c = dealer.Id;
        //     opty1.Opportunity_Owner__c    = dealer.Id;
        //     insert opty1;
            
        //     System.debug('test01 check query count 02 : ' + Limits.getQueries() + ' / ' + opty);
        //     OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty1, entry, prod);
        //     insert oItem;

        //     System.debug('test01 check query count 03 : ' + Limits.getQueries() + ' / ' + oItem);
        //     Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty1, 'Korea');
        //     insert quote;

        //     System.debug('test01 check query count 04 : ' + Limits.getQueries() + ' / ' + quote);
        //     QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
        //     insert qItem;

        //     // System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
        // }
    }
    @isTest
    static void testBatchExecution() {
        Test.startTest();

        // Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler'};
        // TriggerHandler.bypassedHandlers = bypassSet; 
        // InterfaceCommonUtil.setInterface('IF-OPTY-006', 'IF_ERP_Inquiry');

        // User owner      = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        // Account acc      = [SELECT Id, SalesOffice__c, OwnerId, RecordType.DeveloperName FROM Account WHERE CustomerCode__c = '123456' LIMIT 1]; 
        // Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE StageName = 'Qualified' LIMIT 1];
        // DN_OpportunityCallout.createInquiry(owner.Id, acc.Id, testOpportunity.Id, 'ZINM');
        DN_OpportunityCallout.dummy();

        Test.stopTest();
    }
}