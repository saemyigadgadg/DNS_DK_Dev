@isTest
public with sharing class DN_RegularServiceCampaignBatchTest {
    @TestSetup
    static void makeData(){
        RecordType campaign_recordType = TestDataFactoryForSales.getRecordType('RegularInspections', 'Campaign');
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.CustomerCode__c   = '123456';
        acc.BusinessNumber__c = '5148171773';
        acc.Representative__c = 'realAcc';
        insert acc;

        Asset ass = TestDataFactoryForSales.createAsset();
        ass.Status          = 'AVLB';
        ass.AccountId       = acc.Id;
        ass.SoldTo__c       = acc.Id;
        insert ass;

        Campaign cp = new Campaign();
        cp.Name = 'Test Campaign';
        cp.CampaignType__c = 'RegularInspections';
        cp.RegularServiceType__c   = 'General Regular Service';
        insert cp;
    }

    @isTest
    static void testBatch() {
        Test.startTest();
        System.schedule('Test Scheduled Batch', '0 0 0 * * ?', new DN_RegularServiceCampaignBatch());
        Database.ExecuteBatch(new DN_RegularServiceCampaignBatch());
        Test.stopTest();
    }
}