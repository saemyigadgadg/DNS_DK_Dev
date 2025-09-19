@isTest
public with sharing class DN_RFQActivityAlertBatchTest {
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler', 'QuoteTriggerHandler','PSTriggerHandler'};
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
            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_key');
            insert opty;
            Opportunity opty1 = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_key');
            opty1.StageName = 'Validated';
            insert opty1;
            Opportunity opty2 = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_key');
            opty2.StageName = 'Qualified';
            insert opty2;
            Opportunity opty3 = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_key');
            insert opty3;

            Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
            insert newCompetitor;

            OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty, newCompetitor);
            insert optyCompetitor;

            Opportunity optyTurnkey = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_key');
            insert optyTurnkey;
            Id pBookId = Test.getStandardPricebookId();
            Date today = Date.today();

            PS__c ps1 = new PS__c();
            // ps1.Name = '600202656';
            ps1.ERPInquiryNo__c = '600202656';
            ps1.Opportunity__c = opty.Id;
            ps1.RequiredDelivryDate__c = today.addDays(-1);
            ps1.Status__c = 'SalesReview';
            insert ps1;

            PS__c ps2 = new PS__c();
            // ps2.Name = '600202657';
            ps2.ERPInquiryNo__c = '600202657';
            ps2.Opportunity__c = opty.Id;
            ps2.RequiredDelivryDate__c = today.addDays(-1);
            ps2.Status__c = 'SalesReview';
            insert ps2;

            PS__c ps3 = new PS__c();
            // ps3.Name = '600202658';
            ps3.ERPInquiryNo__c = '600202658';
            ps3.Opportunity__c = opty.Id;
            ps3.RequiredDelivryDate__c = today.addDays(-1);
            ps3.Status__c = 'SEReceipt';
            insert ps3;

            PS__c ps4 = new PS__c();
            // ps4.Name = '600202659';
            ps4.ERPInquiryNo__c = '600202659';
            ps4.Opportunity__c = opty.Id;
            ps4.RequiredDelivryDate__c = today.addDays(-1);
            ps4.Status__c = 'SalesConfirm';
            insert ps4;
        }
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        Database.ExecuteBatch(new DN_RFQActivityAlertBatch(), 5);
        Test.stopTest();
    }
}