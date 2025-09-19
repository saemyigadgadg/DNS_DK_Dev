/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-30
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-26   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_TrendReportBatch_TEST {
    public DN_TrendReportBatch_TEST() {}

    public class IF_SWEET_TRACKER_HttpMock implements HttpCalloutMock {
        public IF_SWEET_TRACKER_HttpMock() {}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse(); 
            
            String resBody = '[{"result":"Y","code":"K000","kind":"K","msgid":"20250404_134650_44","originCode":null,"error":"","sendtime":"2025-04-04 13:46:50","originError":null}]';
            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

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
            technicalTicket1.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 1, nowDT.day());
            technicalTicket1.FailureArea__c = '4T9';
            technicalTicket1.FailureAreaDetailValue__c = '001';
            technicalTicket1.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket1);

            Case technicalTicket2 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket2.ReceptionDetails__c = 'test';
            technicalTicket2.RepairRequestDateTime__c = nowDT;
            technicalTicket2.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 2, nowDT.day());
            technicalTicket2.FailureArea__c = '4T9';
            technicalTicket2.FailureAreaDetailValue__c = '001';
            technicalTicket2.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket2);

            Case technicalTicket3 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket3.ReceptionDetails__c = 'test';
            technicalTicket3.RepairRequestDateTime__c = nowDT;
            technicalTicket3.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 3, nowDT.day());
            technicalTicket3.FailureArea__c = '4T9';
            technicalTicket3.FailureAreaDetailValue__c = '001';
            technicalTicket3.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket3);

            Case technicalTicket4 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket4.ReceptionDetails__c = 'test';
            technicalTicket4.RepairRequestDateTime__c = nowDT;
            technicalTicket4.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 4, nowDT.day());
            technicalTicket4.FailureArea__c = '4T9';
            technicalTicket4.FailureAreaDetailValue__c = '001';
            technicalTicket4.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket4);

            Case technicalTicket5 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket5.ReceptionDetails__c = 'test';
            technicalTicket5.RepairRequestDateTime__c = nowDT;
            technicalTicket5.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 5, nowDT.day());
            technicalTicket5.FailureArea__c = '4T9';
            technicalTicket5.FailureAreaDetailValue__c = '001';
            technicalTicket5.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket5);

            Case technicalTicket6 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket6.ReceptionDetails__c = 'test';
            technicalTicket6.RepairRequestDateTime__c = nowDT;
            technicalTicket6.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 6, nowDT.day());
            technicalTicket6.FailureArea__c = '4T9';
            technicalTicket6.FailureAreaDetailValue__c = '001';
            technicalTicket6.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket6);

            Case technicalTicket7 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket7.ReceptionDetails__c = 'test';
            technicalTicket7.RepairRequestDateTime__c = nowDT;
            technicalTicket7.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 7, nowDT.day());
            technicalTicket7.FailureArea__c = '4T9';
            technicalTicket7.FailureAreaDetailValue__c = '001';
            technicalTicket7.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket7);

            Case technicalTicket8 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket8.ReceptionDetails__c = 'test';
            technicalTicket8.RepairRequestDateTime__c = nowDT;
            technicalTicket8.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 8, nowDT.day());
            technicalTicket8.FailureArea__c = '4T9';
            technicalTicket8.FailureAreaDetailValue__c = '001';
            technicalTicket8.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket8);

            Case technicalTicket9 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket9.ReceptionDetails__c = 'test';
            technicalTicket9.RepairRequestDateTime__c = nowDT;
            technicalTicket9.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 9, nowDT.day());
            technicalTicket9.FailureArea__c = '4T9';
            technicalTicket9.FailureAreaDetailValue__c = '001';
            technicalTicket9.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket9);

            Case technicalTicket10 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket10.ReceptionDetails__c = 'test';
            technicalTicket10.RepairRequestDateTime__c = nowDT;
            technicalTicket10.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 10, nowDT.day());
            technicalTicket10.FailureArea__c = '4T9';
            technicalTicket10.FailureAreaDetailValue__c = '001';
            technicalTicket10.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket10);

            Case technicalTicket11 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket11.ReceptionDetails__c = 'test';
            technicalTicket11.RepairRequestDateTime__c = nowDT;
            technicalTicket11.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 11, nowDT.day());
            technicalTicket11.FailureArea__c = '4T9';
            technicalTicket11.FailureAreaDetailValue__c = '001';
            technicalTicket11.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket11);

            Case technicalTicket12 = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket12.ReceptionDetails__c = 'test';
            technicalTicket12.RepairRequestDateTime__c = nowDT;
            technicalTicket12.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), 12, nowDT.day());
            technicalTicket12.FailureArea__c = '4T9';
            technicalTicket12.FailureAreaDetailValue__c = '001';
            technicalTicket12.FailurePhenomenonValue__c = '02';
            insertCaseList.add(technicalTicket12);
            insert insertCaseList;

            // technicalTicket1.ApplicationDateTime__c = Datetime.newInstance(nowDT.year(), (nowDT.month() - 1), nowDT.day());
            // update technicalTicket1;


            List<WorkOrder> insertWOList = new List<WorkOrder>();
            WorkOrder wo1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket1.Id, '201', stList[1].Id, sr.Id);
            wo1.CreatedDate = Datetime.newInstance(nowDT.year(), 1, nowDT.day());
            WorkOrder wo2 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket2.Id, '201', stList[1].Id, sr.Id);
            wo2.CreatedDate = Datetime.newInstance(nowDT.year(), 2, nowDT.day());
            WorkOrder wo3 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket3.Id, '201', stList[1].Id, sr.Id);
            wo3.CreatedDate = Datetime.newInstance(nowDT.year(), 3, nowDT.day());
            WorkOrder wo4 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket4.Id, '201', stList[1].Id, sr.Id);
            wo4.CreatedDate = Datetime.newInstance(nowDT.year(), 4, nowDT.day());
            WorkOrder wo5 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket5.Id, '201', stList[1].Id, sr.Id);
            wo5.CreatedDate = Datetime.newInstance(nowDT.year(), 5, nowDT.day());
            WorkOrder wo6 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket6.Id, '201', stList[1].Id, sr.Id);
            wo6.CreatedDate = Datetime.newInstance(2024, 6, nowDT.day());
            WorkOrder wo7 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket7.Id, '201', stList[1].Id, sr.Id);
            wo7.CreatedDate = Datetime.newInstance(2024, 7, nowDT.day());
            WorkOrder wo8 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket8.Id, '201', stList[1].Id, sr.Id);
            wo8.CreatedDate = Datetime.newInstance(2024, 8, nowDT.day());
            WorkOrder wo9 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket9.Id, '201', stList[1].Id, sr.Id);
            wo9.CreatedDate = Datetime.newInstance(2024, 9, nowDT.day());
            WorkOrder wo10 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket10.Id, '201', stList[1].Id, sr.Id);
            wo10.CreatedDate = Datetime.newInstance(2024, 10, nowDT.day());
            WorkOrder wo11 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket11.Id, '201', stList[0].Id, sr.Id);
            wo11.CreatedDate = Datetime.newInstance(2024, 11, nowDT.day());
            WorkOrder wo12 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket12.Id, '201', stList[0].Id, sr.Id);
            wo12.CreatedDate = Datetime.newInstance(2024, 12, nowDT.day());
            insertWOList.add(wo1);
            insertWOList.add(wo2);
            insertWOList.add(wo3);
            insertWOList.add(wo4);
            insertWOList.add(wo5);
            insertWOList.add(wo6);
            insertWOList.add(wo7);
            insertWOList.add(wo8);
            insertWOList.add(wo9);
            insertWOList.add(wo10);
            insertWOList.add(wo11);
            insertWOList.add(wo12);
            insert insertWOList;

            TriggerHandler.clearAllBypasses();

        }
    }

    @isTest
    static void testExecuteBatch1() {
        Test.startTest();
        DN_TrendReportBatch batch = new DN_TrendReportBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void testExecuteBatch2() {

        TrendReport__c trend = new TrendReport__c();
        trend.Type__c = '기종 별 통계';
        trend.year__c = '2025';
        trend.Model__c = 'HM1250';
        insert trend;


        Test.startTest();
        DN_TrendReportBatch batch = new DN_TrendReportBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void testExecuteBatch3() {

        TrendReport__c trend = new TrendReport__c();
        trend.Type__c = '상담원 별 접수';
        trend.year__c = '2025';
        trend.OwnerName__c = 'testuser';
        insert trend;


        Test.startTest();
        DN_TrendReportBatch batch = new DN_TrendReportBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void testExecuteBatch4() {

        List<TrendReport__c> insertList = new List<TrendReport__c>();
        TrendReport__c trend1 = new TrendReport__c();
        trend1.Type__c = '지사 별 접수';
        trend1.year__c = '2025';
        trend1.TopWorkCenter__c = '창원지사';
        trend1.WorkCenter__c = '광명산업';
        insertList.add(trend1);
        TrendReport__c trend2 = new TrendReport__c();
        trend2.Type__c = '지사 별 접수';
        trend2.year__c = '2025';
        trend2.TopWorkCenter__c = '창원지사';
        trend2.WorkCenter__c = '광명산업';
        insertList.add(trend2);
        insert insertList;


        Test.startTest();
        DN_TrendReportBatch batch = new DN_TrendReportBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void testExecuteBatch5() {

        TrendReport__c trend = new TrendReport__c();
        trend.Type__c = '월 별 콜 접수';
        trend.year__c = '2025';
        trend.OwnerName__c = 'testuser';
        insert trend;

        List<Case> ticketList = [SELECT Id FROM Case];
        for (Case ticket : ticketList) {
            ticket.Status = 'Closed';
            ticket.EndOfReason__c = 'Call Service';
        }
        TriggerHandler.bypass('TicketTriggerHandler');
        update ticketList;
        TriggerHandler.clearAllBypasses();
        
        Test.startTest();
        DN_TrendReportBatch batch = new DN_TrendReportBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void testExecuteBatch6() {

        TrendReport__c trend = new TrendReport__c();
        trend.Type__c = '월 별 오더';
        trend.year__c = '2025';
        insert trend;


        Test.startTest();
        DN_TrendReportBatch batch = new DN_TrendReportBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }

}