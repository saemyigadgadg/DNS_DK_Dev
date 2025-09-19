@isTest
public with sharing class DN_DNSAemailBatchTest {
    @TestSetup
    static void makeData(){
        RecordType campaign_recordType = TestDataFactoryForSales.getRecordType('DNSAPreCall', 'Campaign');
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Date today = Date.today();
        Date oneMonthAgo = today.addMonths(-1);
    
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.CustomerCode__c   = '123456';
        acc.BusinessNumber__c = '5148171773';
        acc.Representative__c = 'realAcc';
        acc.ServiceManager__c = 'test011@email.com';
        acc.PartsManagerEmail__c = 'test012@email.com';
        insert acc;

        OperatingHours oh = new OperatingHours();
        oh.Name     = 'DNSA Operating Hours_ Los Angeles';
        oh.TimeZone = 'America/Los_Angeles';
        insert oh;

        Asset ass = new Asset();
        ass.Name            = 'ML0006-006231';
        ass.MachineName__c  = 'LYNX 220A-NT';
        ass.Material__c     = 'L22ANT-F0TP-0-K30';
        ass.SerialNumber    = 'ML0006-006231';
        ass.Status          = 'AVLB';
        ass.AccountId       = acc.Id;
        ass.SoldTo__c       = acc.Id;
        insert ass;

        Asset ass2 = new Asset();
        ass2.Name            = 'ML0006-006233';
        ass2.MachineName__c  = 'LYNX 221A-NT';
        ass2.Material__c     = 'L22ANT-F0TP-0-K31';
        ass2.SerialNumber    = 'ML0006-006232';
        ass2.Status          = 'AVLB';
        ass2.AccountId       = acc.Id;
        ass2.SoldTo__c       = acc.Id;
        insert ass2;

        Asset ass3 = new Asset();
        ass3.Name            = 'ML0006-006234';
        ass3.MachineName__c  = 'LYNX 222A-NT';
        ass3.Material__c     = 'L22ANT-F0TP-0-K31';
        ass3.SerialNumber    = 'ML0006-006232';
        ass3.Status          = 'AVLB';
        ass3.AccountId       = acc.Id;
        ass3.SoldTo__c       = acc.Id;
        insert ass3;

        Campaign cp = new Campaign();
        cp.Name = 'Test Campaign';
        cp.ExtractCheck__c = false;
        cp.CampaignType__c = 'ServiceCampaign';
        cp.Purpose__c = 'test';
        cp.Description = 'test';
        cp.MailContents__c = 'mail text';
        cp.Pre__c = 'Pre-call';
        insert cp;

        Campaign cp2 = new Campaign();
        cp2.Name = 'Test Campaign';
        cp2.ExtractCheck__c = false;
        cp2.CampaignType__c = 'ServiceCampaign';
        cp2.Purpose__c = 'test';
        cp2.Description = 'test';
        cp2.Pre__c = 'Pre-call';
        insert cp2;

        // ✅ 조건 1: SendDate__c = 한 달 전, EmailStatus__c = 'Send'
        CampaignAsset__c ca1 = new CampaignAsset__c(
            Campaign__c = cp.Id,
            Equipment__c = ass.Id,
            SendDate__c = oneMonthAgo,
            EmailStatus__c = 'Send',
            Email__c = 'test1@naver.com'
        );

        // ✅ 조건 2: RecentlySendDate__c = 한 달 전, EmailStatus__c = 'Not Completed'
        CampaignAsset__c ca2 = new CampaignAsset__c(
            Campaign__c = cp.Id,
            Equipment__c = ass2.Id,
            RecentlySendDate__c = oneMonthAgo,
            EmailStatus__c = 'Not Completed',
            Email__c = 'test2@naver.com'
        );

        // ✅ 조건 3: RecentlySendDate__c = 한 달 전, EmailStatus__c = 'Remind Confirm'
        CampaignAsset__c ca3 = new CampaignAsset__c(
            Campaign__c = cp.Id,
            Equipment__c = ass3.Id,
            RecentlySendDate__c = oneMonthAgo,
            EmailStatus__c = 'Remind Confirm',
            Email__c = 'test3@naver.com'
        );
        insert new List<CampaignAsset__c>{ca1, ca2, ca3};

        AlertManager__c am = new AlertManager__c();
        am.Name = 'DNSA Pre-call & Missing Part Email Alert';
        insert am;
    }

    @isTest
    static void testBatch() {
        Test.startTest();
        System.schedule('Test Scheduled Batch', '0 0 0 * * ?', new DN_DNSAemailBatch());
        Database.ExecuteBatch(new DN_DNSAemailBatch());
        Test.stopTest();
    }
}