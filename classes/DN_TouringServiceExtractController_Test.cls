@IsTest
public with sharing class DN_TouringServiceExtractController_Test {
    private static final Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    // private static final Id ticketRT = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket').getRecordTypeId();

    @TestSetup
    static void makeData(){
        // Profile 생성
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];

        // User 1 생성
        User user1 = new User(
            Alias               = 'SBTAdmin',
            Email               = 'sbtAdmin@test.com',
            EmailEncodingKey    = 'UTF-8',
            LastName            = 'testAdmin',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'ko',
            ProfileId           = testProfile.Id,
            TimeZoneSidKey      = 'Asia/Seoul',
            UserName            = 'sbtAdmin3@solution.com'
        );
        insert user1;

        Account acc = new Account(
            Name                    = 'Test Account',
            RecordTypeId            = prospectCustomerRT,
            BusinessNumber__c       = '111111',
            Representative__c       = 'test',
            Competitor__c           = 'None',
            MainCategory__c         = 'MB',
            SubCategory__c          = 'MB1',
            IsTooling__c            = 'MY',
            Production__c           = 'TEST',
            TypeOfBusiness__c       = 'Manufacturing',
            TypeOfIndustry__c       = '가구,기타 제품 제조',
            Country__c              = 'KR',
            Phone                   = '010-1111-2222',
            Website                 = 'www.test.com',
            Fax                     = '010-1111-2222',
            SearchTerm__c           = 'test',
            SalesOrganization__c    = '1800',
            SalesDistrict__c        = 'A1KR',
            SalesOffice__c          = '114C',
            DistributionChannel__c  = '10',
            Division__c             = '40'
        );
        insert acc;

        Campaign testCampaign = new Campaign(Name = 'Test Campaign', ExtractCheck__c = false, CampaignType__c = 'ServiceCampaign', Purpose__c = 'test', Description = 'test');
        insert testCampaign;

        Campaign testCampaign2 = new Campaign(Name = 'Test Campaign2', ExtractCheck__c = true, CampaignType__c = 'Pre_Call', Purpose__c = 'test', Description = 'test');
        insert testCampaign2;
        
        Asset asset = new Asset(Name = 'ML0006-006231');
        insert asset;

        List<CampaignAsset__c> assetList = new List<CampaignAsset__c>();
        for (Integer i = 0; i < 5; i++) {
            CampaignAsset__c testAsset = new CampaignAsset__c(
                Campaign__c = testCampaign.Id,
                Equipment__c = asset.Id,
                Manager__c = user1.Id
            );
            assetList.add(testAsset);
        }
        insert assetList;

        ContentVersion contentVersion = new ContentVersion(
                VersionData = Blob.valueOf('Test Content'),
                Title = 'Test Content',
                PathOnClient = 'Test_Content.txt',
                ContentLocation = 'S',
                Origin = 'C',
                ReasonForChange = 'Testing'
            );
        insert contentVersion;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        ContentDocument contentDocument = [SELECT Id, Title, FileType, PublishStatus, LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentDocumentId];

        ContentDocumentLink objLink = new ContentDocumentLink(
            LinkedEntityId = testCampaign.Id,
            ContentDocumentId = contentDocument.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert objLink;

        Case caseObj = new Case(
            // RecordTypeId        = ticketRT,
            Status              = 'New',
            AssetId             = asset.Id,
            ReceptionDetails__c = 'Test',
            TicketType__c       = 'Technical inquiry',
            InternalTicketType__c = 'Program Inquiry'
        );
        insert caseObj;
    }

    @isTest
    static void DN_TouringServiceExtractController_Test() {
        Campaign cp = [SELECT Id FROM Campaign LIMIT 1];
        Campaign cp2 = [SELECT Id FROM Campaign WHERE ExtractCheck__c = true];
        List<CampaignAsset__c> caList = [SELECT Id, Equipment__c, Manager__c, Equipment__r.AccountId FROM CampaignAsset__c WHERE Campaign__c = :cp.Id];
        List<Map<String, Object>> targetList = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Name' => 'test1',
                'Id' => caList[0].Id
            },
            new Map<String, Object>{
                'Name' => 'test2',
                'Id' => caList[1].Id
            }
        };
        String targetData = JSON.serialize(targetList);

        Test.startTest();
        DN_TouringServiceExtractController.confirmExtract(cp.Id);
        DN_TouringServiceExtractController.confirmExtract(cp2.Id);
        DN_TouringServiceExtractController.getTargetEquipList(cp.Id);
        DN_TouringServiceExtractController.extractTicket(cp.Id, targetData);
        Test.stopTest();
    }
}