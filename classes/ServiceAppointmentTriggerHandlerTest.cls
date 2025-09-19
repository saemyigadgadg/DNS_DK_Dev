/**
 * @description       : DN_WorkOrderCancelController_TEST
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
 * @Percentage        : 
**/
@isTest
public with sharing class ServiceAppointmentTriggerHandlerTest {
    @TestSetup
    static void makeData(){

        TriggerHandler.bypass('TicketTriggerHandler');
        TriggerHandler.bypass('WorkOrderTriggerHandler');
        TriggerHandler.bypass('AssignedResourceTriggerHandler');

        String profileId = UserInfo.getProfileId();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        User thisUser = [SELECT Id, UserName FROM User WHERE Id =: UserInfo.getUserId()];

        User user;
        System.runAs(thisUser) {
            user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
            user.LastName = 'Test User Test';
            insert user;
        }

        CustomNotificationType noti = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        Alimtalk_Tamplate__mdt alarmTem = [SELECT Id, TemplateCode__c FROM Alimtalk_Tamplate__mdt LIMIT 1];

        List<AlertManager__c> insertAlertManagerList = new List<AlertManager__c>();
        AlertManager__c alertManager1 = new AlertManager__c();
        alertManager1.Name = 'CS Worker Type Noti';
        alertManager1.Part__c = 'Service';
        alertManager1.IsActive__c = true;
        alertManager1.Description__c = 'Test';
        insertAlertManagerList.add(alertManager1);
        AlertManager__c alertManager2 = new AlertManager__c();
        alertManager2.Name = 'CS Assigning Service Resource Alarm Talk';
        alertManager2.Part__c = 'Service';
        alertManager2.IsActive__c = true;
        alertManager2.Description__c = 'Test';
        insertAlertManagerList.add(alertManager2);
        AlertManager__c alertManager3 = new AlertManager__c();
        alertManager3.Name = 'CS Estimated Time Arrival Alarm Talk';
        alertManager3.Part__c = 'Service';
        alertManager3.IsActive__c = true;
        alertManager3.Description__c = 'Test';
        insertAlertManagerList.add(alertManager3);
        insert insertAlertManagerList;

        List<AlertNotificationTemplate__c> insertNotiTemList = new List<AlertNotificationTemplate__c>();
        AlertNotificationTemplate__c alertNoti1 = new AlertNotificationTemplate__c();
        alertNoti1.Name = 'TestNoti';
        alertNoti1.AlertManagerID__c = alertManager1.Id;
        alertNoti1.Body__c = 'Test Notification {0}';
        alertNoti1.IsDynamic__c = true;
        alertNoti1.Language__c = 'ko';
        alertNoti1.Title__c = 'Test Notification';
        alertNoti1.CustomNotificationName__c = noti.DeveloperName;
        insertNotiTemList.add(alertNoti1);
        insert insertNotiTemList;

        AlertAlarmTalkTemplate__c alertAlarm = new AlertAlarmTalkTemplate__c();
        alertAlarm.Name = 'TestAlarm';
        alertAlarm.AlertManagerID__c = alertManager2.Id;
        alertAlarm.AlarmTalkTemplateCode__c = alarmTem.TemplateCode__c;
        alertAlarm.Language__c = 'ko';
        alertAlarm.Name = 'TestAlarm';
        insert alertAlarm;

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

        List<NotiReceptionList__c> insertNotiRecepList = new List<NotiReceptionList__c>();
        NotiReceptionList__c notiRecep1 = new NotiReceptionList__c();
        notiRecep1.Name = 'IndirectReception';
        notiRecep1.UserName__c = thisUser.UserName;
        insertNotiRecepList.add(notiRecep1);
        NotiReceptionList__c notiRecep2 = new NotiReceptionList__c();
        notiRecep2.Name = 'AlarmTalk';
        notiRecep2.UserName__c = thisUser.UserName;
        insertNotiRecepList.add(notiRecep2);
        NotiReceptionList__c notiRecep3 = new NotiReceptionList__c();
        notiRecep3.Name = 'PClaimPermission';
        notiRecep3.UserName__c = thisUser.UserName;
        insertNotiRecepList.add(notiRecep3);
        insert insertNotiRecepList;

        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;
        Country__c us = TestDataFactoryForService.createUSCountry();
        insert us;
        
        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        insert account;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        List<Case> insertTicketList = new List<Case>();
        Case technicalTicket1 = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insertTicketList.add(technicalTicket1);
        Case technicalTicket2 = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Installation request');
        insertTicketList.add(technicalTicket2);
        Case technicalTicket3 = TestDataFactoryForService.createCase('Ticket_DNSA', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insertTicketList.add(technicalTicket3);
        insert insertTicketList;

        List<OperatingHours> hours = TestDataFactoryForService.createOperatingHours();        
        insert hours;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();       
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        List<ServiceResource> insertResourceList = new List<ServiceResource>();
        ServiceResource resource1 = TestDataFactoryForService.createResource(territory.Id);
        insertResourceList.add(resource1);
        ServiceResource resource2 = TestDataFactoryForService.createResource(territory.Id, user.Id);
        insertResourceList.add(resource2);
        insert insertResourceList;

        List<WorkOrder> insertWOList = new List<WorkOrder>();
        WorkOrder wo1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket1.Id, '201', territory.Id, resource1.Id);
        insertWOList.add(wo1);
        WorkOrder wo2 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket2.Id, '104', territory.Id, resource1.Id);
        insertWOList.add(wo2);
        WorkOrder wo3 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_DNSA', technicalTicket3.Id, '602', territory.Id, resource1.Id);
        wo3.PMActivityType__c = 'HS01';
        insertWOList.add(wo3);
        insert insertWOList;

        TriggerHandler.clearAllBypasses();
    }

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

    @isTest
    static void testInsertSADNS(){        

        Test.setMock(HttpCalloutMock.class, Type.forName('ServiceAppointmentTriggerHandlerTest.IF_SWEET_TRACKER_HttpMock').newInstance());

        TriggerHandler.bypass('TicketTriggerHandler');
        TriggerHandler.bypass('WorkOrderTriggerHandler');
        TriggerHandler.bypass('AssignedResourceTriggerHandler');

        WorkOrder wo = [SELECT Id, Worker__c FROM WorkOrder LIMIT 1];
        ServiceResource resource = [SELECT Id FROM ServiceResource WHERE Id != :wo.Worker__c LIMIT 1];

        String dnsRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ServiceAppointment').getRecordTypeId();
        List<ServiceAppointment> insertSAList = new List<ServiceAppointment>();

        ServiceAppointment sa1 = new ServiceAppointment();
        sa1.RecordTypeId = dnsRecordTypeId;
        sa1.ParentRecordId = wo.Id;
        sa1.ServiceResource__c = wo.Worker__c;
        sa1.WorkerType__c = 'Service Resource (Main)';
        sa1.SchedStartTime = System.now();
        sa1.SchedEndTime = System.now().addDays(1);
        insertSAList.add(sa1);

        ServiceAppointment sa2 = new ServiceAppointment();
        sa2.RecordTypeId = dnsRecordTypeId;
        sa2.ParentRecordId = wo.Id;
        sa2.ServiceResource__c = resource.Id;
        sa2.WorkerType__c = 'Service Resource (Sub)';
        sa2.SchedStartTime = System.now();
        sa2.SchedEndTime = System.now().addDays(1);
        insertSAList.add(sa2);
        insert insertSAList;

        TriggerHandler.clearAllBypasses();

    }

    @isTest
    static void testInsertSADNSA(){

        TriggerHandler.bypass('TicketTriggerHandler');
        TriggerHandler.bypass('WorkOrderTriggerHandler');
        TriggerHandler.bypass('AssignedResourceTriggerHandler');

        WorkOrder wo = [SELECT Id, Worker__c FROM WorkOrder WHERE RecordType.DeveloperName = 'WorkOrder_DNSA' LIMIT 1];

        String dnsaRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ServiceAppointment_DNSA').getRecordTypeId();

        ServiceAppointment sa = new ServiceAppointment();
        sa.RecordTypeId = dnsaRecordTypeId;
        sa.ParentRecordId = wo.Id;
        sa.ServiceResource__c = wo.Worker__c;
        sa.SchedStartTime = System.now();
        sa.SchedEndTime = System.now().addDays(1);
        insert sa;

        TriggerHandler.clearAllBypasses();

    }

    @isTest
    static void testUpdateSADNS(){        

        TriggerHandler.bypass('TicketTriggerHandler');
        TriggerHandler.bypass('WorkOrderTriggerHandler');
        TriggerHandler.bypass('AssignedResourceTriggerHandler');

        WorkOrder wo = [SELECT Id, Worker__c FROM WorkOrder LIMIT 1];
        ServiceResource resource = [SELECT Id FROM ServiceResource WHERE Id != :wo.Worker__c LIMIT 1];

        String dnsRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ServiceAppointment').getRecordTypeId();
        List<ServiceAppointment> insertSAList = new List<ServiceAppointment>();

        ServiceAppointment sa1 = new ServiceAppointment();
        sa1.RecordTypeId = dnsRecordTypeId;
        sa1.ParentRecordId = wo.Id;
        sa1.ServiceResource__c = wo.Worker__c;
        sa1.WorkerType__c = 'Service Resource (Main)';
        sa1.SchedStartTime = System.now();
        sa1.SchedEndTime = System.now().addDays(1);
        insertSAList.add(sa1);

        insert insertSAList;

        sa1.WorkerType__c = 'Service Resource (Sub)';
        sa1.ServiceResource__c = resource.Id;
        sa1.OnsiteDate__c = System.now();
        update sa1;

        TriggerHandler.clearAllBypasses();
    }

    @isTest
    static void testUpdateSADNS2(){        

        TriggerHandler.bypass('TicketTriggerHandler');
        TriggerHandler.bypass('WorkOrderTriggerHandler');
        TriggerHandler.bypass('AssignedResourceTriggerHandler');

        WorkOrder wo = [SELECT Id, Worker__c FROM WorkOrder LIMIT 1];
        ServiceResource resource = [SELECT Id FROM ServiceResource WHERE Id != :wo.Worker__c LIMIT 1];

        String dnsRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ServiceAppointment').getRecordTypeId();
        List<ServiceAppointment> insertSAList = new List<ServiceAppointment>();

        ServiceAppointment sa1 = new ServiceAppointment();
        sa1.RecordTypeId = dnsRecordTypeId;
        sa1.ParentRecordId = wo.Id;
        sa1.ServiceResource__c = wo.Worker__c;
        sa1.WorkerType__c = 'Service Resource (Main)';
        sa1.SchedStartTime = System.now();
        sa1.SchedEndTime = System.now().addDays(1);
        sa1.OnsiteDate__c = System.now();
        insertSAList.add(sa1);

        insert insertSAList;

        sa1.OnsiteDate__c = System.now().addDays(1);

        update sa1;
        TriggerHandler.clearAllBypasses();

    }

}