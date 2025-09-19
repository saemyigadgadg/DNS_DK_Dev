@isTest
public with sharing class DN_ExecuteHappyCallControllerTest {
    @TestSetup
    static void makeData(){
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.CustomerCode__c   = '123456';
        acc.BusinessNumber__c = '5148171773';
        acc.Representative__c = 'realAcc';
        insert acc;

        Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        con.MobilePhone = '01011112222';
        insert con;

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
        cp2.Name = 'Test Campaign2';
        cp2.ExtractCheck__c = false;
        cp2.CampaignType__c = 'ServiceCampaign';
        cp2.Purpose__c = 'test';
        cp2.Description = 'test';
        cp2.Pre__c = 'Pre-call';
        insert cp2;

        CampaignAsset__c ca = new CampaignAsset__c();
        ca.Campaign__c = cp.Id;
        ca.Email__c = 'test@test.com';
        insert ca;

        CommonPart__c testCp = new CommonPart__c();
        testCp.Campaign__c = cp.Id;
        insert testCp;

        ContentVersion cv = new ContentVersion();
        cv.Title = '파일1';
        cv.VersionData = Blob.valueOf('Test Content Data');
        cv.PathOnClient = '파일1.png';
        insert cv;

        String contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = cp.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;    
    }

    @isTest
    static void testBatch() {
        Campaign cpObj = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign' LIMIT 1];
        Campaign cp2Obj = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign2' LIMIT 1];
        CampaignAsset__c caObj = [SELECT Id FROM CampaignAsset__c LIMIT 1];

        List<DN_ExecuteHappyCallController.TargetListWrapper> testTargetList = new List<DN_ExecuteHappyCallController.TargetListWrapper>();
        DN_ExecuteHappyCallController.TargetListWrapper testTarget = new DN_ExecuteHappyCallController.TargetListWrapper();
        testTarget.tId = caObj.Id;
        testTargetList.add(testTarget);
        String jsonSelectedData = JSON.serialize(testTargetList);

        Test.startTest();
        DN_ExecuteHappyCallController.initEquipment(cpObj.Id);
        DN_ExecuteHappyCallController.sendPreCallEmail(cpObj.Id, jsonSelectedData);
        DN_ExecuteHappyCallController.sendPreCallEmail(cp2Obj.Id, jsonSelectedData);
        Test.stopTest();
    }
}