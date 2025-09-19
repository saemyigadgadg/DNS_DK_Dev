@isTest
public with sharing class DN_OpportunityActivityAlertBatchTest {
    private class OpportunityNotification {
        public Id opportunityId { get; set; }
        public Id ownerId { get; set; }
        public String message { get; set; }
        public Integer duration { get; set; }
        public String email { get; set; }
        public String lang { get; set; }
        public String license { get; set; }
        public String accName { get; set; }
        public String opptyName { get; set; }

        // 생성자
        public OpportunityNotification(Id opportunityId, Id ownerId, String message, Integer duration, String email, String lang, String license, String accName, String opptyName) {
            this.opportunityId = opportunityId;
            this.ownerId = ownerId;
            this.message = message;
            this.duration = duration;
            this.email = email;
            this.lang = lang;
            this.license = license;
            this.accName = accName;
            this.opptyName = opptyName;
        }
    }
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler', 'QuoteTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        Profile globalProfile = TestDataFactoryForSales.getProfile('영업 글로벌 대리점');

        User dealer;
        User dealerWorker;
        User dealerGlobal;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;

            Contact dealerConWorker = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            dealerConWorker.Lastname = 'Worker User';
            insert dealerConWorker;

            Contact dealerConGlobal = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            dealerConGlobal.Lastname = 'One More';
            insert dealerConGlobal;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer.portalRole = 'Manager';
            insert dealer;

            dealerWorker = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerConWorker);
            dealerWorker.portalRole = 'Worker';
            dealerWorker.LanguageLocaleKey = 'en_US';
            insert dealerWorker;

            dealerGlobal = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerConGlobal);
            dealerGlobal.LanguageLocaleKey = 'de';
            dealerGlobal.ProfileId = globalProfile.Id;
            insert dealerGlobal;
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

            System.debug('test01 check query count 01 : ' + Limits.getQueries());
            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;
            Opportunity opty1 = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            opty1.StageName = 'Validated';
            insert opty1;
            Opportunity opty2 = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealerWorker, 'General');
            opty2.StageName = 'Qualified';
            insert opty2;
            Opportunity opty3 = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealerGlobal, 'General');
            insert opty3;

            Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
            insert newCompetitor;

            OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty, newCompetitor);
            insert optyCompetitor;

            Opportunity optyTurnkey = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_key');
            insert optyTurnkey;
            Id pBookId = Test.getStandardPricebookId();
            Date today = Date.today();

            Integer duration = 100;
            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            Opportunity_Stage_Tracker__c newSt = new Opportunity_Stage_Tracker__c();
            newSt.Opportunity__c = opty1.Id;
            newSt.StageName__c = 'Identified';
            insert newSt;

            Opportunity_Stage_Tracker__c newSt2 = new Opportunity_Stage_Tracker__c();
            newSt2.Opportunity__c = opty2.Id;
            newSt2.StageName__c = 'Validated';
            insert newSt2;

            Opportunity_Stage_Tracker__c newSt3 = new Opportunity_Stage_Tracker__c();
            newSt3.Opportunity__c = opty3.Id;
            newSt3.StageName__c = 'Qualified';
            insert newSt3;

            List<OpportunityNotification> notifications = new List<OpportunityNotification>();

            OpportunityNotification notification = new OpportunityNotification(
                opty1.Id,
                UserInfo.getUserId(), // 현재 실행 중인 사용자 ID
                'This is a test message',
                70,
                'test@example.com',
                'en',
                'Enterprise',
                'account',
                opty1.Name
            );
            notifications.add(notification);
            OpportunityNotification notification2 = new OpportunityNotification(
                opty1.Id,
                UserInfo.getUserId(), // 현재 실행 중인 사용자 ID
                'This is a test message',
                70,
                'test@example.com',
                'ko',
                'Enterprise',
                'account',
                opty2.Name
            );
            notifications.add(notification2);

            OpportunityNotification notification3 = new OpportunityNotification(
                opty1.Id,
                UserInfo.getUserId(), // 현재 실행 중인 사용자 ID
                'This is a test message',
                70,
                'test@example.com',
                'en_US',
                'Enterprise',
                'account',
                opty3.Name
            );
            notifications.add(notification3);
        }
    }
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        Database.ExecuteBatch(new DN_OpportunityActivityAlertBatch(), 5);
        Test.stopTest();
    }
}