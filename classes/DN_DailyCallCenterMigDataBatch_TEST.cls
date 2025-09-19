/**
 * @author            : Yeong-Deok Seo
 * @description       : 
 * @last modified on  : 2025-06-09
 * @last modified by  : yeongdeok.seo@sbtglobal.com
**/
@isTest
public with sharing class DN_DailyCallCenterMigDataBatch_TEST {
    public DN_DailyCallCenterMigDataBatch_TEST() {}

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, Type.forName('DN_TrendReportBatch_TEST.IF_SWEET_TRACKER_HttpMock').newInstance());
        Interface__c testInterface = new Interface__c();
        testInterface.Name = 'Sweet_Tracker_SendMessage_Op';
        testInterface.EndpointURL__c = 'https://alimtalk-api.sweettracker.net/v2';
        testInterface.HttpMethod__c = 'POST';
        testInterface.ContentType__c = 'application/json; charset=UTF-8';
        testInterface.Timeout__c = 120000;
        testInterface.System__c = 'SWEET TRAKER';
        testInterface.IsActive__c = true;
        insert testInterface;

        InterfaceClasses__c testInterface2 = new InterfaceClasses__c();
        testInterface2.Name = 'IF_SWEET_TRACKER';
        insert testInterface2;

        Alimtalk_Tamplate__mdt alarmTem = [SELECT Id, TemplateCode__c FROM Alimtalk_Tamplate__mdt LIMIT 1];
        CustomNotificationType noti = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        
        List<AlertManager__c> managerList = new List<AlertManager__c>();
        AlertManager__c alertManager1 = new AlertManager__c();
        alertManager1.Name = 'CS Assigning Service Resource Alarm Talk';
        alertManager1.Part__c = 'Service';
        alertManager1.IsActive__c = true;
        alertManager1.Description__c = 'Test';
        managerList.add(alertManager1);

        AlertManager__c alertManager2 = new AlertManager__c();
        alertManager2.Name = 'CS Worker Type Noti';
        alertManager2.Part__c = 'Service';
        alertManager2.IsActive__c = true;
        alertManager2.Description__c = 'Test';
        managerList.add(alertManager2);

        AlertManager__c alertManager3 = new AlertManager__c();
        alertManager3.Name = 'WorkOrder Assignment Service Resource Notification';
        alertManager3.Part__c = 'Service';
        alertManager3.IsActive__c = true;
        alertManager3.Description__c = 'Test';
        managerList.add(alertManager3);

        AlertManager__c alertManager4 = new AlertManager__c();
        alertManager4.Name = 'WorkOrder Assignment DNSA Service Resource Notification';
        alertManager4.Part__c = 'Service';
        alertManager4.IsActive__c = true;
        alertManager4.Description__c = 'Test';
        managerList.add(alertManager4);

        insert managerList;


        AlertAlarmTalkTemplate__c alertAlarm = new AlertAlarmTalkTemplate__c();
        alertAlarm.Name = 'TestAlarm';
        alertAlarm.AlertManagerID__c = alertManager1.Id;
        alertAlarm.AlarmTalkTemplateCode__c = alarmTem.TemplateCode__c;
        alertAlarm.Language__c = 'ko';
        alertAlarm.Name = 'TestAlarm';
        insert alertAlarm;


        List<AlertNotificationTemplate__c> notiTemList = new List<AlertNotificationTemplate__c>();
        AlertNotificationTemplate__c alertNoti1 = new AlertNotificationTemplate__c();
        alertNoti1.Name = 'TestNoti';
        alertNoti1.AlertManagerID__c = alertManager2.Id;
        alertNoti1.Body__c = 'Test Notification {0}';
        alertNoti1.IsDynamic__c = true;
        alertNoti1.Language__c = 'ko';
        alertNoti1.Title__c = 'Test Notification';
        alertNoti1.CustomNotificationName__c = noti.DeveloperName;
        notiTemList.add(alertNoti1);

        AlertNotificationTemplate__c alertNoti2 = new AlertNotificationTemplate__c();
        alertNoti2.Name = 'TestNoti';
        alertNoti2.AlertManagerID__c = alertManager3.Id;
        alertNoti2.Body__c = 'Test Notification {0}';
        alertNoti2.IsDynamic__c = true;
        alertNoti2.Language__c = 'ko';
        alertNoti2.Title__c = 'Test Notification';
        alertNoti2.CustomNotificationName__c = noti.DeveloperName;
        notiTemList.add(alertNoti2);

        AlertNotificationTemplate__c alertNoti3 = new AlertNotificationTemplate__c();
        alertNoti3.Name = 'TestNoti';
        alertNoti3.AlertManagerID__c = alertManager4.Id;
        alertNoti3.Body__c = 'Test Notification {0}';
        alertNoti3.IsDynamic__c = true;
        alertNoti3.Language__c = 'en';
        alertNoti3.Title__c = 'Test Notification';
        alertNoti3.CustomNotificationName__c = noti.DeveloperName;
        notiTemList.add(alertNoti3);

        insert notiTemList;


        String profileId = UserInfo.getProfileId();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        // User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        User thisUser = new User(Id = UserInfo.getUserId());
        
        User user;
        System.runAs(thisUser) {
            user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
            user.LastName = 'admin';
            insert user;
        }

        Country__c country = TestDataFactoryForService.createKRCountry();
        insert country;

        List<OperatingHours> testHours = TestDataFactoryForService.createOperatingHours();
        insert testHours;

        AssignmentRule__c ar = new AssignmentRule__c ();
        ar.Name = '기술상담사 순차배정';
        ar.AssignmentType__c = 'Owner';
        ar.Corporation__c = 'DNS';

        insert ar;

        AssignmentMember__c am = new AssignmentMember__c();
        am.AssignmentRule__c = ar.Id;
        am.User__c = thisUser.Id;
        insert am;

        List<NotiReceptionList__c> settingList = new List<NotiReceptionList__c>();
        NotiReceptionList__c setting1 = new NotiReceptionList__c();
        setting1.Name = 'IndirectReception';
        setting1.UserName__c = 'yeongdeok.s@dncompany.com.dev';
        settingList.add(setting1);

        NotiReceptionList__c setting2 = new NotiReceptionList__c();
        setting2.Name = 'AlarmTalk';
        setting2.UserName__c = 'yeongdeok.s@dncompany.com.dev';
        settingList.add(setting2);

        insert settingList;

        System.runAs(user) {
            List<ServiceTerritory> stList = TestDataFactoryForService.createTerritory();
            stList[0].WCCode__c = '1244842';
            stList[0].AvailableServiceResource__c = 0;
            stList[1].WCCode__c = '1244842';
            stList[1].AvailableServiceResource__c = 0;
            insert stList;
    
            List<ServiceResource> insertSRList = new List<ServiceResource>();
            ServiceResource sr = TestDataFactoryForService.createResource(stList[1].Id);
            sr.RelatedRecordId = thisUser.Id;
            sr.StaffNumber__c = '6527';
            sr.LastKnownLatitude = 37.557718278300890;
            sr.LastKnownLongitude = 126.974039677136940;
            insertSRList.add(sr);
    
            ServiceResource sr2 = TestDataFactoryForService.createResource(stList[0].Id);
            sr2.RelatedRecordId = user.Id;
            sr2.StaffNumber__c = '6482';
            sr2.LastKnownLatitude = 37.557718278300890;
            sr2.LastKnownLongitude = 126.974039677136940;
            sr2.CurrentStatus__c = 'Work';
            insertSRList.add(sr2);
            insert insertSRList;
    
            List<Account> insertAccountList = new List<Account>();
            Account dealerAcc = TestDataFactoryForService.createAccount('Dealer', 'Test Dealer', country);
            dealerAcc.CustomerCode__c = '1311191';
            insertAccountList.add(dealerAcc);
            Account shipToAcc = TestDataFactoryForService.createAccount('ShipToParty', 'Test Account', country);
            shipToAcc.CustomerCode__c = '1237758';
            insertAccountList.add(shipToAcc);
            insert insertAccountList;
    
            Asset testAsset = TestDataFactoryForService.createAsset(shipToAcc.Id);
            testAsset.Name           = 'MH0015-000307';
            testAsset.SerialNumber   = 'MH0015-000307';
            testAsset.ConstrYrMth__c = '2025/03';
            insert testAsset;
    
            Contact con = TestDataFactoryForService.createContact('CSCustomer', shipToAcc.Id);
            insert con;
    
            List<FailureArea_Major__c > majorList = TestDataFactoryForService.createFailureAreaMajor();
            insert majorList;
            List<FailureAreaMiddle__c > middleList = TestDataFactoryForService.createFailureAreaMiddle();
            insert middleList;
            List<FailurePhenomenon__c > phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
            insert phenomenonList;

            Datetime nowDT = Datetime.now();

            TriggerHandler.bypass('TicketTriggerHandler');
            TriggerHandler.bypass('WorkOrderTriggerHandler');
            List<Case> insertCaseList = new List<Case>();
            Case technicalTicket1 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket1.ReceptionDetails__c = 'test';
            technicalTicket1.RepairRequestDateTime__c = nowDT;
            technicalTicket1.ApplicationDateTime__c = Datetime.newInstance(2024, 12, 23);
            technicalTicket1.CreatedDate = Datetime.newInstance(2024, 12, 23);
            technicalTicket1.FailureArea__c = '4T9';
            technicalTicket1.FailureAreaDetailValue__c = '001';
            technicalTicket1.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket1);

            insert insertCaseList;

            List<WorkOrder> insertWOList = new List<WorkOrder>();
            WorkOrder wo1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket1.Id, '201', stList[1].Id, sr.Id);
            wo1.CreatedDate = Datetime.newInstance(2024, 12, 23);
            insertWOList.add(wo1);

            insert insertWOList;

            TriggerHandler.clearAllBypasses();

        }
    }

    @isTest
    static void testBatch() {

        User user = [SELECT Id FROM User WHERE LastName = 'admin' LIMIT 1];

        Datetime nowDT = Datetime.now();
        String typeId = SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        Case ticket = [SELECT Id FROM Case LIMIT 1];

        System.runAs(user) {
            Task task = new Task();
            task.RecordTypeId = typeId;
            task.CreatedDate = Date.newInstance(2024, 12, 23);
            task.ActivityDate = Date.newInstance(2024, 12, 23);
            task.CallType__c = 'Inbound Call';
            task.WhatId = ticket.Id;
            insert task;
        }

        Test.startTest();
        DN_DailyCallCenterMigDataBatch batch = new DN_DailyCallCenterMigDataBatch();
        batch.taskStartDate = Date.newInstance(2024, 01, 01);
        batch.taskEndDate = Date.newInstance(2024, 12, 31);
        Database.executeBatch(batch,1);
        Test.stopTest();
    }
}