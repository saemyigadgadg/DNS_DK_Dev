/**
 * @description       : DN_LaunchingExcellenceBtnController_TEST
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_LaunchingExcellenceBtnControllerTest {
    @TestSetup
    static void makeData(){
        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;

        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        insert account;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;
        
        Asset asset2 = TestDataFactoryForService.createAsset(account.Id);
        asset2.Name = 'TEST';
        insert asset2;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        Case ticket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        ticket.TicketType__c = 'Internal request';
        ticket.InternalTicketType__c = 'Installation request';
        insert ticket;
        
        Case ticket2 = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset2.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        ticket2.TicketType__c = 'Internal request';
        ticket2.InternalTicketType__c = 'Installation request';
        insert ticket2;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', ticket.Id, '104');
        insert wo;
        WorkOrder wo2 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', ticket2.Id, '104');
        wo2.Status = 'Confirm';
        insert wo2;
        
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'WorkOrderTriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        String scheduleId = Schema.SObjectType.LaunchingExcellenceDoc__c.getRecordTypeInfosByDeveloperName().get('InstallSchedule').getRecordTypeId();
        String manualId = Schema.SObjectType.LaunchingExcellenceDoc__c.getRecordTypeInfosByDeveloperName().get('InstallManual').getRecordTypeId();

        List<LaunchingExcellenceDoc__c> docList = new List<LaunchingExcellenceDoc__c>();
        LaunchingExcellenceDoc__c lcDoc1 = new LaunchingExcellenceDoc__c();
        lcDoc1.RecordTypeId = scheduleId;
        docList.add(lcDoc1);
        LaunchingExcellenceDoc__c lcDoc2 = new LaunchingExcellenceDoc__c();
        lcDoc2.RecordTypeId = manualId;
        docList.add(lcDoc2);
        insert docList;

        ContentVersion schedule = new ContentVersion();
        schedule.Title = 'Test File';
        schedule.PathOnClient = 'schedule.txt';
        schedule.VersionData = Blob.valueOf('This is a test file.');
        schedule.IsMajorVersion = true;
        insert schedule;
        
        ContentVersion manual = new ContentVersion();
        manual.Title = 'Test File';
        manual.PathOnClient = 'manual.txt';
        manual.VersionData = Blob.valueOf('This is a test file.');
        manual.IsMajorVersion = true;
        insert manual;

        ContentVersion cv_schedule = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :schedule.Id
            LIMIT 1
        ];

        ContentVersion cv_manual = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :manual.Id
            LIMIT 1
        ];

        ContentDocumentLink cdl_schedule = new ContentDocumentLink();
        cdl_schedule.ContentDocumentId = cv_schedule.ContentDocumentId;
        cdl_schedule.LinkedEntityId = lcDoc1.Id;
        cdl_schedule.ShareType = 'V'; // Viewer access
        cdl_schedule.Visibility = 'AllUsers';
        insert cdl_schedule;
        
        ContentDocumentLink cdl_manual = new ContentDocumentLink();
        cdl_manual.ContentDocumentId = cv_manual.ContentDocumentId;
        cdl_manual.LinkedEntityId = lcDoc1.Id;
        cdl_manual.ShareType = 'V'; // Viewer access
        cdl_manual.Visibility = 'AllUsers';
        insert cdl_manual;

        List<ModelManager__c> mmList = new List<ModelManager__c>();
        ModelManager__c mm1 = new ModelManager__c(ModelCode__c = 'MH0014',
                                                UserTraining_EN__c = 'crm/DVF 사용자 교육', 
                                                UserTraining_KR__c = 'crm/DVF 사용자 교육', 
                                                Install_EN__c = 'crm/DVF5000 INSATALL_EN',
                                                Install_KR__c = 'crm/DVF5000 INSATALL_KOR',
                                                InstallationInspection_KR__c = 'crm/Installation inspet sheet',
                                                InstallationInspection_EN__c = 'crm/Installation inspet sheet',
                                                InstallManual_EN__c = 'manual.txt',
                                                InstallManual_KR__c = 'manual.txt',
                                                InstallSchedule_EN__c = 'schedule.txt',
                                                InstallSchedule_KR__c = 'schedule.txt'
                                                );
        ModelManager__c mm2 = new ModelManager__c(ModelCode__c = 'TEST');
        
        mmList.add(mm1);
        mmList.add(mm2);
        insert mmList;
    }

    @isTest
    static void testGetPMActivityType(){   
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE OrderType__c = '104' limit 1];
        
        Test.startTest();
        DN_LaunchingExcellenceBtnController.getPMActivityType(wo.Id);
        // DN_LaunchingExcellenceBtnController.getPMActivityType('Exception');
        Test.stopTest();
    }

    @isTest
    static void testGetDocInfo(){   
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE OrderType__c = '104' limit 1];
        Map<String, Object> dataMap = new Map<String, Object>{
            'chName' => 'UserTraining',
            'woId' => wo.Id,
            'userId' => UserInfo.getUserId(),
            'device' => 'Large'
        };

        String data = JSON.serialize(dataMap);

        List<Map<String, Object>> contentList = new List<Map<String, Object>>();
        Map<String, Object> contentMap = new Map<String, Object>{
            'FORMID' => 'AT1',
            'NAME' => 'FixedTableLabel1',
            'VALUE' => 'TEST'
        };
        Map<String, Object> contentMap2 = new Map<String, Object>{
            'FORMID' => 'AT2',
            'NAME' => 'FixedTableLabel2',
            'VALUE' => 'TEST'
        };
        contentList.add(contentMap);
        contentList.add(contentMap2);

        String contentData = JSON.serialize(contentList);

        Test.startTest();
        DN_LaunchingExcellenceBtnController.ParamWrapper pw = new DN_LaunchingExcellenceBtnController.ParamWrapper();
        pw.chName = 'UserTraining';
        pw.woId = wo.Id;
        pw.userId = UserInfo.getUserId();
        pw.device = 'Large';


        DN_LaunchingExcellenceBtnController.saveDocContent(contentData,data);
        DN_LaunchingExcellenceBtnController.getHtmlContent(data);
        DN_LaunchingExcellenceBtnController.saveDocContent(contentData,data);
        DN_LaunchingExcellenceBtnController.saveDocContent('Exception', 'Exception');
        Test.stopTest();
    }

    @isTest
    static void testGetCheckSheet(){   
        Asset equip1 = [SELECT Id FROM Asset WHERE Name = 'TEST' LIMIT 1];
        Asset equip2 = [SELECT Id FROM Asset WHERE Name != 'TEST' LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE OrderType__c = '104' AND AssetId = :equip2.Id LIMIT 1];
        WorkOrder wo2 = [SELECT Id FROM WorkOrder WHERE OrderType__c = '104' AND AssetId = :equip1.Id LIMIT 1];


        Map<String, Object> dataMap_training = new Map<String, Object>{
            'chName' => 'UserTraining',
            'woId' => wo2.Id,
            'userId' => UserInfo.getUserId(),
            'device' => 'Large'
        };

        Map<String, Object> dataMap_install = new Map<String, Object>{
            'chName' => 'Install',
            'woId' => wo2.Id,
            'userId' => UserInfo.getUserId(),
            'device' => 'Large'
        };
       
        Map<String, Object> dataMap_inspection = new Map<String, Object>{
            'chName' => 'InstallationInspection',
            'woId' => wo2.Id,
            'userId' => UserInfo.getUserId(),
            'device' => 'Large'
        };

        String data_training = JSON.serialize(dataMap_training);
        String data_install = JSON.serialize(dataMap_install);
        String data_inspection = JSON.serialize(dataMap_inspection);

        Test.startTest();
        DN_LaunchingExcellenceBtnController.checkDocId(wo.Id, 'InstallManual');
        DN_LaunchingExcellenceBtnController.checkDocId(wo.Id, 'InstallSchedule');
        DN_LaunchingExcellenceBtnController.checkDocId(wo2.Id, 'InstallSchedule');
        DN_LaunchingExcellenceBtnController.checkDocId('Exception', 'InstallSchedule');
        DN_LaunchingExcellenceBtnController.getHtmlContent(data_training);
        DN_LaunchingExcellenceBtnController.getHtmlContent(data_install);
        DN_LaunchingExcellenceBtnController.getHtmlContent(data_inspection);
        Test.stopTest();
    }

}