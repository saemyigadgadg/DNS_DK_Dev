@isTest
public with sharing class TriggerHandler_Test {
    public TriggerHandler_Test() {}

    @isTest
    static void triggerHandler_allInOne_Test(){
        
        TriggerHandler th1 = new TriggerHandler();
        TriggerHandler th2 = new TriggerHandler(true, TriggerOperation.AFTER_DELETE);
        TriggerHandler.setBatchUpdate(true);

        IF_Product__c ifPrd = new IF_Product__c(MTART__c = 'test');
        insert ifPrd;
        List<IF_Product__c> ifPrdList = new List<IF_Product__c>{ifPrd};
        th1.setting(true, TriggerOperation.BEFORE_INSERT);
        th1.setting(true, TriggerOperation.BEFORE_INSERT, true);
        th1.execute(ifPrdList, ifPrdList, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd}, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd});
        th1.setting(true, TriggerOperation.AFTER_INSERT);
        th1.execute(ifPrdList, ifPrdList, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd}, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd});
        th1.setting(true, TriggerOperation.BEFORE_UPDATE);
        th1.execute(ifPrdList, ifPrdList, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd}, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd});
        th1.setting(true, TriggerOperation.AFTER_UPDATE);
        th1.execute(ifPrdList, ifPrdList, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd}, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd});
        th1.setting(true, TriggerOperation.BEFORE_DELETE);
        th1.execute(ifPrdList, ifPrdList, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd}, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd});
        th1.setting(true, TriggerOperation.AFTER_DELETE);
        th1.execute(ifPrdList, ifPrdList, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd}, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd});
        th1.setting(true, TriggerOperation.AFTER_UNDELETE);
        th1.execute(ifPrdList, ifPrdList, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd}, new Map<Id, IF_Product__c>{ifPrd.Id => ifPrd});
        
        th1.onBeforeInsert(ifPrd);
        th1.onBeforeUpdate(ifPrd, ifPrd);
        th1.onBeforeDelete(ifPrd);
        th1.onAfterInsert(ifPrd);
        th1.onAfterUpdate(ifPrd, ifPrd);
        th1.onAfterDelete(ifPrd);

        th1.executeDivisionCondision(new TriggerHandler.TriggerOption(true, false));

        TriggerHandler.bypass('handlerName');
        TriggerHandler.clearBypass('handlerName');
        TriggerHandler.isBypassed('handlerName');
        TriggerHandler.clearAllBypasses();

        OrganizationMapper testOrgMapper = new OrganizationMapper(new List<Opportunity>{new Opportunity(OwnerId = UserInfo.getUserId())});
    }

    @isTest
    static void testMappingField() {
        User u = new User(
            UserName = 'testuser1534@example.com',
            LastName = 'testuser1',
            Alias = 'test1',
            Email = 'testuser1@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Seoul',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;

        // 테스트용 커스텀 오브젝트 생성 (예: Test__c)
        Opportunity testRecord = new Opportunity(Name = 'Before Owner Change', OwnerId = u.Id, stageName = 'Closed Won', CloseDate = Date.today());
        insert testRecord;

        // WHEN: OrganizationMapper 사용
        List<sObject> recordList = new List<sObject>{testRecord};

        Test.startTest();
        OrganizationMapper mapper = new OrganizationMapper(recordList);
        mapper.mappingField(recordList);
        Test.stopTest();
    }

    @isTest
    static void testOwnerChangeMapping() {
        User oldUser = new User(
            UserName = 'olduser3431@example.com',
            LastName = 'olduser',
            Alias = 'old1',
            Email = 'olduser@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Seoul',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert oldUser;

        User newUser = new User(
            UserName = 'newuser5421@example.com',
            LastName = 'newuser',
            Alias = 'new1',
            Email = 'newuser@example.com',
            ProfileId = oldUser.ProfileId,
            TimeZoneSidKey = 'Asia/Seoul',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert newUser;

        // 커스텀 오브젝트 생성
        Opportunity before = new Opportunity(Name = 'Before Owner Change', OwnerId = oldUser.Id, stageName = 'Closed Won', CloseDate = Date.today());
        insert before;

        // Owner 변경
        before.OwnerId = newUser.Id;

        Map<Id, SObject> oldMap = new Map<Id, SObject>{
            before.Id => new Opportunity(Id = before.Id, OwnerId = oldUser.Id)
        };
        List<sObject> news = new List<sObject>{before};

        Test.startTest();
        OrganizationMapper mapper = new OrganizationMapper(news);
        mapper.mappingField(news, oldMap);
        Test.stopTest();
    }
}