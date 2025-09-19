/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 06-11-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class DN_ServiceAppointmentControllerTest {

    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, Type.forName('DN_ServiceAppointmentControllerTest.IF_SWEET_TRACKER_HttpMock').newInstance());

        EmailTemplate eTem = [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 1];
        CustomNotificationType noti = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        Alimtalk_Tamplate__mdt alarmTem = [SELECT Id, TemplateCode__c FROM Alimtalk_Tamplate__mdt LIMIT 1];
        
        List<AlertManager__c> insertAlertList = new List<AlertManager__c>();
        AlertManager__c alertManager1 = new AlertManager__c();
        alertManager1.Name = 'CS Service Resource Department Alarm Talk';
        alertManager1.Part__c = 'Service';
        alertManager1.IsActive__c = true;
        alertManager1.Description__c = 'Test';
        insertAlertList.add(alertManager1);
        AlertManager__c alertManager2 = new AlertManager__c();
        alertManager2.Name = 'CS Worker Type Noti';
        alertManager2.Part__c = 'Service';
        alertManager2.IsActive__c = true;
        alertManager2.Description__c = 'Test';
        insertAlertList.add(alertManager2);
        insert insertAlertList;

        AlertAlarmTalkTemplate__c alertAlarm = new AlertAlarmTalkTemplate__c();
        alertAlarm.Name = 'TestAlarm';
        alertAlarm.AlertManagerID__c = alertManager1.Id;
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

        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

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

        // Account account1 = TestDataFactoryForService.createAccount('DNSA Customer', 'TEST dnsa Company', us);
        // insert account1;

        // Asset asset1 = TestDataFactoryForService.createAsset(account1.Id);
        // insert asset1;

        // Contact contact1 = TestDataFactoryForService.createContact('CSCustomer', account1.Id);
        // insert contact1;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;

        // Case technicalTicket1 = TestDataFactoryForService.createCase('Ticket_DNSA', account1.Id, asset1.Id, contact1.Id, 'Technical inquiry', 'Failure receipt');
        // insert technicalTicket1;

        List<OperatingHours> hours = TestDataFactoryForService.createOperatingHours();        
        insert hours;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();       
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);       
        insert resource;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', territory.Id, resource.Id);
        insert wo;
        Datetime arrivalTime = Datetime.now();
        ServiceAppointment appointment = TestDataFactoryForService.createDNSAppointment(wo, territory.Id, resource.Id, 'Main');
        insert appointment;

        WorkOrderResult__c wor = new WorkOrderResult__c(
            WorkOrder__c = wo.Id,
            ServiceAppointment__c = appointment.Id,
            ServiceResource__c = resource.Id,
            WorkDate__c = Date.today(),
            WorkStartTime__c = Time.newInstance(10, 0, 0, 0),
            WorkEndTime__c = Time.newInstance(11, 0, 0, 0),
            WorkType__c = 'WK',
            ResultType__c = 'WH'
        );
        insert wor;



        // WorkOrder wo1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_DNSA', technicalTicket.Id, '201', territory.Id, resource.Id);
        // insert wo;

        // ServiceAppointment appointment1 = TestDataFactoryForService.createDNSAppointment(wo, territory.Id, resource.Id, 'Main');
        // insert appointment;
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
    static void getServiceAppointmentTest() {        
        Id currentUserId = UserInfo.getUserId();
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
        ServiceAppointment sa = [SELECT Id FROM ServiceAppointment WHERE ServiceResource__c = :sr.Id LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
    
        Test.startTest();
        DN_ServiceAppointmentController.getServiceAppointment(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void getOnSiteDateTimeTest() {        
        Id currentUserId = UserInfo.getUserId();
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        ServiceAppointment sa = [SELECT Id FROM ServiceAppointment WHERE ServiceResource__c = :sr.Id AND ParentRecordId = :wo.Id  LIMIT 1];
    
        Test.startTest();
        DN_ServiceAppointmentController.getOnSiteDateTime(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void updateOnSiteDateTimeTest() {        
        Id currentUserId = UserInfo.getUserId();
        DateTime onsiteDateTime = System.now();

        // 현재 유저의 ServiceResource 찾기
        ServiceResource sr = [
            SELECT Id 
            FROM ServiceResource 
            WHERE RelatedRecordId = :currentUserId 
            LIMIT 1
        ];

                // 테스트용 WorkOrder 하나 선택
        WorkOrder wo = [SELECT Id, TimeAgreedOnSite__c FROM WorkOrder LIMIT 1];
        wo.TimeAgreedOnSite__c = onsiteDateTime;
        update wo;

        // ServiceAppointment 중 해당 유저와 WorkOrder 연결된 거 가져오기
        ServiceAppointment sa = [
            SELECT Id, Status, OnsiteDate__c
            FROM ServiceAppointment 
            WHERE ServiceResource__c = :sr.Id 
            AND Status = 'Assigned' 
            AND ParentRecordId = :wo.Id 
            LIMIT 1
        ];
        sa.OnsiteDate__c = onsiteDateTime;
        update sa;
        // sa.Status = 'None';
        // update sa;



        Test.startTest();
        String result = DN_ServiceAppointmentController.updateOnSiteDateTime(wo.Id, onsiteDateTime);
        Test.stopTest();

        // 결과 확인
        ServiceAppointment updatedSA = [
            SELECT OnsiteDate__c, Status 
            FROM ServiceAppointment 
            WHERE Id = :sa.Id
        ];

        WorkOrder updatedWO = [
            SELECT TimeAgreedOnSite__c 
            FROM WorkOrder 
            WHERE Id = :wo.Id
        ];
    }

    @isTest
    static void updateOnSiteDateTime_isDNSA_Test() {
        // 테스트용 유저 생성 (SalesOrganization__c = '4140'로 설정)
        User u = DN_ModelManagerControllerTest.createTestUser('4140');
        update u;
        DateTime onsiteDateTime = System.now();

        WorkOrder wo = [SELECT Id, TimeAgreedOnSite__c FROM WorkOrder LIMIT 1];
        wo.TimeAgreedOnSite__c = onsiteDateTime;
        update wo;

        ServiceAppointment sa = [
            SELECT Id, Status, OnsiteDate__c
            FROM ServiceAppointment 
            LIMIT 1
        ];
        sa.OnsiteDate__c = onsiteDateTime;
        update sa;

        Test.startTest();
        String result = DN_ServiceAppointmentController.updateOnSiteDateTime(wo.Id, onsiteDateTime);
        Test.stopTest();
    }
    
    @isTest
    static void updateArrivalTimeTest() {       
        InterfaceCommonUtil.setInterface('IF-CSPLUS-028', 'IF_ERP_WorkOrder'); 
        Id currentUserId = UserInfo.getUserId();
        Datetime arrivalTime = Datetime.now();
        // 현재 유저의 ServiceResource 찾기
        ServiceResource sr = [
            SELECT Id 
            FROM ServiceResource 
            WHERE RelatedRecordId = :currentUserId 
            LIMIT 1
        ];

        // 테스트용 WorkOrder 하나 선택
        WorkOrder wo = [SELECT Id, ActualDispatchTime__c, Status, Arrival__c FROM WorkOrder LIMIT 1];
        wo.ActualDispatchTime__c = arrivalTime;
        wo.Arrival__c = arrivalTime;
        wo.Status = 'Arrived';
        update wo;

        // ServiceAppointment 중 해당 유저와 WorkOrder 연결된 거 가져오기
        ServiceAppointment sa = [
            SELECT Id, Status, Arrival__c, WorkOrder__c
            FROM ServiceAppointment 
            WHERE ServiceResource__c = :sr.Id 
            AND Status = 'Assigned' 
            AND ParentRecordId = :wo.Id 
            LIMIT 1
        ];
        sa.Department__c = arrivalTime;
        sa.Arrival__c = arrivalTime;
        update sa;
        // sa.Status = 'None';
        // update sa;

        WorkOrderResult__c wor = [
            SELECT Id, WorkEndTime__c, WorkOrder__c
            FROM WorkOrderResult__c
            LIMIT 1
        ];
        wor.WorkEndTime__c = arrivalTime.time();
        wor.WorkOrder__c = sa.WorkOrder__c;
        update wor;


        Test.startTest();
        String result = DN_ServiceAppointmentController.updateArrivalTime(wo.Id);
        Test.stopTest();

        // 결과 확인
        ServiceAppointment updatedSA = [
            SELECT OnsiteDate__c, Status 
            FROM ServiceAppointment 
            WHERE Id = :sa.Id
        ];

        WorkOrder updatedWO = [
            SELECT TimeAgreedOnSite__c 
            FROM WorkOrder 
            WHERE Id = :wo.Id
        ];
    }
    
    @isTest
    static void updateArrivalTimeTest2() {       
        InterfaceCommonUtil.setInterface('IF-CSPLUS-028', 'IF_ERP_WorkOrder'); 
        Id currentUserId = UserInfo.getUserId();
        Datetime arrivalTime = Datetime.now();
        // 현재 유저의 ServiceResource 찾기
        ServiceResource sr = [
            SELECT Id 
            FROM ServiceResource 
            WHERE RelatedRecordId = :currentUserId 
            LIMIT 1
        ];

        // 테스트용 WorkOrder 하나 선택
        WorkOrder wo = [SELECT Id, ActualDispatchTime__c, Status, Arrival__c FROM WorkOrder LIMIT 1];
        wo.ActualDispatchTime__c = arrivalTime;
        wo.Arrival__c = arrivalTime;
        wo.Status = 'Confirm';
        update wo;

        // ServiceAppointment 중 해당 유저와 WorkOrder 연결된 거 가져오기
        ServiceAppointment sa = [
            SELECT Id, Status, Arrival__c, WorkOrder__c
            FROM ServiceAppointment 
            WHERE ServiceResource__c = :sr.Id 
            AND Status = 'Assigned' 
            AND ParentRecordId = :wo.Id 
            LIMIT 1
        ];
        sa.Department__c = arrivalTime;
        sa.Arrival__c = arrivalTime;
        update sa;
        // sa.Status = 'None';
        // update sa;

        WorkOrderResult__c wor = [
            SELECT Id, WorkEndTime__c, WorkOrder__c
            FROM WorkOrderResult__c
            LIMIT 1
        ];
        wor.WorkEndTime__c = arrivalTime.time();
        wor.WorkOrder__c = sa.WorkOrder__c;
        update wor;


        Test.startTest();
        String result = DN_ServiceAppointmentController.updateArrivalTime(wo.Id);
        Test.stopTest();

        // 결과 확인
        ServiceAppointment updatedSA = [
            SELECT OnsiteDate__c, Status 
            FROM ServiceAppointment 
            WHERE Id = :sa.Id
        ];

        WorkOrder updatedWO = [
            SELECT TimeAgreedOnSite__c 
            FROM WorkOrder 
            WHERE Id = :wo.Id
        ];
    }

    @isTest
    static void updateArrivalTime_isDNSA_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-028', 'IF_ERP_WorkOrder'); 
        // 테스트용 유저 생성 (SalesOrganization__c = '4140'로 설정)
        User u = DN_ModelManagerControllerTest.createTestUser('4140');
        update u;
        Datetime arrivalTime = Datetime.now();

        WorkOrder wo = [SELECT Id, ActualDispatchTime__c, Status, Arrival__c FROM WorkOrder LIMIT 1];
        wo.ActualDispatchTime__c = arrivalTime;
        wo.Arrival__c = arrivalTime;
        wo.Status = 'Arrived';
        update wo;

        ServiceAppointment sa = [
            SELECT Id, Status, Arrival__c, ParentRecordId, WorkOrder__c
            FROM ServiceAppointment 
            LIMIT 1
        ];
        sa.Department__c = arrivalTime;
        sa.Arrival__c = arrivalTime;
        update sa;

        WorkOrderResult__c wor = [
            SELECT Id, WorkEndTime__c, WorkOrder__c
            FROM WorkOrderResult__c
            LIMIT 1
        ];
        wor.WorkEndTime__c = arrivalTime.time();
        wor.WorkOrder__c = sa.WorkOrder__c;
        update wor;

        Test.startTest();
        String result = DN_ServiceAppointmentController.updateArrivalTime(wo.Id);
        Test.stopTest();
    }
    
    @isTest
    static void updateDepartmentTimeTest() {       
        // InterfaceCommonUtil.setInterface('IF-CSPLUS-028', 'IF_ERP_WorkOrder'); 
        Id currentUserId = UserInfo.getUserId();
        Datetime departmentTime = Datetime.now();

        AlertManager__c alert = [SELECT Id FROM AlertManager__c LIMIT 1];
        // 현재 유저의 ServiceResource 찾기
        ServiceResource sr = [
            SELECT Id 
            FROM ServiceResource 
            WHERE RelatedRecordId = :currentUserId 
            LIMIT 1
        ];

        Case ca = [SELECT Id, EndOfReason__c, Status, CaseNumber FROM Case LIMIT 1];

        // 테스트용 WorkOrder 하나 선택
        WorkOrder wo = [
            SELECT Id, ActualDispatchTime__c, Status, Arrival__c, CaseId
            FROM WorkOrder 
            LIMIT 1
        ];
        // wo.ActualDispatchTime__c = departmentTime;
        // wo.Arrival__c = departmentTime;
        wo.Status = 'Started';
        update wo;

        // ServiceAppointment 중 해당 유저와 WorkOrder 연결된 거 가져오기
        ServiceAppointment sa = [
            SELECT Id, Status, Arrival__c, WorkOrder__c, Contact.MobilePhone
            FROM ServiceAppointment 
            WHERE ServiceResource__c = :sr.Id 
            AND Status = 'Assigned' 
            AND ParentRecordId = :wo.Id 
            LIMIT 1
        ];

        sa.WorkerType__c = 'Service Resource (Main)';
        // sa.Department__c = departmentTime;

        update sa;
        // sa.Status = 'None';
        // update sa;

        WorkOrderResult__c wor = [
            SELECT Id, WorkEndTime__c, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, WorkDate__c,
            WorkStartTime__c, Description__c, ResultType__c, WorkType__c
            FROM WorkOrderResult__c
            LIMIT 1
        ];

        wor.ServiceAppointment__c = sa.Id;
        wor.WorkOrder__c = sa.WorkOrder__c;
        wor.ServiceResource__c = sr.Id;
        wor.WorkDate__c = Date.newInstance(departmentTime.year(), departmentTime.month(), departmentTime.day());
        wor.WorkStartTime__c = departmentTime.time();
        wor.Description__c = '고객사로 이동';
        wor.ResultType__c = 'WH';
        wor.WorkType__c = 'MV';
        update wor;

        String phone = sa.Contact.MobilePhone;
        String ticketNumber = ca.CaseNumber;
        Id caseId = wo.CaseId;
        String ctiUrl = System.Label.CTI_Url;

        AlertManager__c alertManager = new AlertManager__c();
        alertManager.Name = 'Test Alert Manager2';
        alertManager.Part__c = 'Service';
        alertManager.IsActive__c = true;
        alertManager.Description__c = 'Test';
        insert alertManager;

        List<UTIL_Alert.HistoryWrapper> wrapperList = new List<UTIL_Alert.HistoryWrapper>();

        // Alarmtalk
        Map<String, String> elementMap = new Map<String, String>();
        elementMap.put('url', 'naver.com');
        UTIL_Alert.HistoryWrapper wrapper3 = new UTIL_Alert.HistoryWrapper();
        wrapper3.alertID = alertManager.Id;
        wrapper3.targetID = alertManager.Id;
        wrapper3.alertType = 'AlarmTalk';
        wrapper3.alertLanguage = 'ko';
        wrapper3.elementMap = elementMap;
        wrapper3.receiverforPhone = new Set<String>{'01071913896'};
        wrapperList.add(wrapper3);

        UTIL_Alert.runAlertEvent(wrapperList);


        Test.startTest();
        String result = DN_ServiceAppointmentController.updateDepartmentTime(wo.Id);
        Test.stopTest();

        // 결과 확인
        ServiceAppointment updatedSA = [
            SELECT OnsiteDate__c, Status 
            FROM ServiceAppointment 
            WHERE Id = :sa.Id
        ];

        WorkOrder updatedWO = [
            SELECT TimeAgreedOnSite__c 
            FROM WorkOrder 
            WHERE Id = :wo.Id
        ];
    }
    
    @isTest
    static void updateDepartmentTimeTest2() {       
        // InterfaceCommonUtil.setInterface('IF-CSPLUS-028', 'IF_ERP_WorkOrder'); 
        Id currentUserId = UserInfo.getUserId();
        Datetime departmentTime = Datetime.now();

        AlertManager__c alert = [SELECT Id FROM AlertManager__c LIMIT 1];
        // 현재 유저의 ServiceResource 찾기
        ServiceResource sr = [
            SELECT Id 
            FROM ServiceResource 
            WHERE RelatedRecordId = :currentUserId 
            LIMIT 1
        ];

        Case ca = [SELECT Id, EndOfReason__c, Status, CaseNumber FROM Case LIMIT 1];

        // 테스트용 WorkOrder 하나 선택
        WorkOrder wo = [
            SELECT Id, ActualDispatchTime__c, Status, Arrival__c, CaseId
            FROM WorkOrder 
            LIMIT 1
        ];
        // wo.ActualDispatchTime__c = departmentTime;
        // wo.Arrival__c = departmentTime;
        wo.Status = 'Confirm';
        update wo;

        // ServiceAppointment 중 해당 유저와 WorkOrder 연결된 거 가져오기
        ServiceAppointment sa = [
            SELECT Id, Status, Arrival__c, WorkOrder__c, Contact.MobilePhone
            FROM ServiceAppointment 
            WHERE ServiceResource__c = :sr.Id 
            AND Status = 'Assigned' 
            AND ParentRecordId = :wo.Id 
            LIMIT 1
        ];

        sa.WorkerType__c = 'Service Resource (Main)';
        // sa.Department__c = departmentTime;

        update sa;
        // sa.Status = 'None';
        // update sa;

        WorkOrderResult__c wor = [
            SELECT Id, WorkEndTime__c, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, WorkDate__c,
            WorkStartTime__c, Description__c, ResultType__c, WorkType__c
            FROM WorkOrderResult__c
            LIMIT 1
        ];

        wor.ServiceAppointment__c = sa.Id;
        wor.WorkOrder__c = sa.WorkOrder__c;
        wor.ServiceResource__c = sr.Id;
        wor.WorkDate__c = Date.newInstance(departmentTime.year(), departmentTime.month(), departmentTime.day());
        wor.WorkStartTime__c = departmentTime.time();
        wor.Description__c = '고객사로 이동';
        wor.ResultType__c = 'WH';
        wor.WorkType__c = 'MV';
        update wor;

        String phone = sa.Contact.MobilePhone;
        String ticketNumber = ca.CaseNumber;
        Id caseId = wo.CaseId;
        String ctiUrl = System.Label.CTI_Url;

        AlertManager__c alertManager = new AlertManager__c();
        alertManager.Name = 'Test Alert Manager2';
        alertManager.Part__c = 'Service';
        alertManager.IsActive__c = true;
        alertManager.Description__c = 'Test';
        insert alertManager;

        List<UTIL_Alert.HistoryWrapper> wrapperList = new List<UTIL_Alert.HistoryWrapper>();

        // Alarmtalk
        Map<String, String> elementMap = new Map<String, String>();
        elementMap.put('url', 'naver.com');
        UTIL_Alert.HistoryWrapper wrapper3 = new UTIL_Alert.HistoryWrapper();
        wrapper3.alertID = alertManager.Id;
        wrapper3.targetID = alertManager.Id;
        wrapper3.alertType = 'AlarmTalk';
        wrapper3.alertLanguage = 'ko';
        wrapper3.elementMap = elementMap;
        wrapper3.receiverforPhone = new Set<String>{'01071913896'};
        wrapperList.add(wrapper3);

        UTIL_Alert.runAlertEvent(wrapperList);


        Test.startTest();
        String result = DN_ServiceAppointmentController.updateDepartmentTime(wo.Id);
        Test.stopTest();

        // 결과 확인
        ServiceAppointment updatedSA = [
            SELECT OnsiteDate__c, Status 
            FROM ServiceAppointment 
            WHERE Id = :sa.Id
        ];

        WorkOrder updatedWO = [
            SELECT TimeAgreedOnSite__c 
            FROM WorkOrder 
            WHERE Id = :wo.Id
        ];
    }

    @isTest
    static void updateDepartmentTime_isDNSA_Test() {
        // 테스트용 유저 생성 (SalesOrganization__c = '4140'로 설정)
        User u = DN_ModelManagerControllerTest.createTestUser('4140');
        update u;
        Datetime departmentTime = Datetime.now();

        // AlertManager__c alert = [SELECT Id FROM AlertManager__c LIMIT 1];

        ServiceResource sr = [
            SELECT Id 
            FROM ServiceResource 
            WHERE RelatedRecordId = :u.Id 
            LIMIT 1
        ];

        Case ca = [SELECT Id, EndOfReason__c, Status, CaseNumber FROM Case LIMIT 1];

        WorkOrder wo = [SELECT Id, ActualDispatchTime__c, Status, Arrival__c FROM WorkOrder LIMIT 1];
        // wo.ActualDispatchTime__c = arrivalTime;
        // wo.Arrival__c = arrivalTime;
        wo.Status = 'Started';
        update wo;

        ServiceAppointment sa = [
            SELECT Id, Status, Arrival__c, ParentRecordId, WorkOrder__c
            FROM ServiceAppointment 
            LIMIT 1
        ];
        // sa.Department__c = departmentTime;
        // sa.Arrival__c = arrivalTime;
        update sa;

        WorkOrderResult__c wor = [
            SELECT Id, WorkEndTime__c, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, WorkDate__c,
            WorkStartTime__c, Description__c, ResultType__c, WorkType__c
            FROM WorkOrderResult__c
            LIMIT 1
        ];
        wor.ServiceAppointment__c = sa.Id;
        wor.WorkOrder__c = sa.WorkOrder__c;
        wor.ServiceResource__c = sr.Id;
        wor.WorkDate__c = Date.newInstance(departmentTime.year(), departmentTime.month(), departmentTime.day());
        wor.WorkStartTime__c = departmentTime.time();
        wor.Description__c = 'Go to Site';
        wor.ResultType__c = 'WH';
        wor.WorkType__c = 'MV';
        update wor;

        Test.startTest();
        String result = DN_ServiceAppointmentController.updateDepartmentTime(wo.Id);
        Test.stopTest();
    }
    
    @isTest
    static void updateArrivalIFTest() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-028', 'IF_ERP_WorkOrder');
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        WorkOrder wo = [SELECT Id, ServiceOrderNumber__c FROM WorkOrder LIMIT 1];
        ServiceResource sr = [SELECT Id, StaffNumber__c FROM ServiceResource LIMIT 1];

        // 날짜/시간 문자열 파라미터 준비
        String msdd = Date.today().addDays(-2).format(); // 'yyyy-MM-dd'
        String msdz = '08:00:00';
        String isdd = Date.today().addDays(-1).format();
        String isdz = '10:30:00';
        // String iedd = Date.today().format();
        // String iedz = '12:00:00';

        Test.startTest();
        DN_ServiceAppointmentController.updateArrivalIF(
            wo.ServiceOrderNumber__c,
            sr.StaffNumber__c,
            msdd, msdz,
            isdd, isdz
        );
        Test.stopTest();
    }

    @isTest
    static void cloneServiceAppointmentTest() {       
        Id currentUserId = UserInfo.getUserId();
        Datetime dt = Datetime.now();
        String pendingReasons = 'Person';
        String pendingDetails = 'Test Pending Detail';

        ServiceResource sr = [
            SELECT Id 
            FROM ServiceResource 
            WHERE RelatedRecordId = :currentUserId 
            LIMIT 1
        ];

        Case ca = [SELECT Id FROM Case LIMIT 1];

        WorkOrder wo = [
            SELECT Id, Status, Pendingprocessing__c, PendingMattersCustomerRequirements__c
            FROM WorkOrder 
            LIMIT 1
        ];
        wo.Status = 'Uncompleted';
        wo.Pendingprocessing__c = pendingReasons;
        wo.PendingMattersCustomerRequirements__c = pendingDetails;
        update wo;

        ServiceAppointment sa = [
            SELECT Id, Status, Arrival__c, WorkOrder__c, Contact.MobilePhone
            FROM ServiceAppointment 
            WHERE ServiceResource__c = :sr.Id 
            AND Status = 'Assigned' 
            AND ParentRecordId = :wo.Id 
            LIMIT 1
        ];

        sa.Pendingprocessing__c = pendingReasons;
        sa.PendingDetail__c = pendingDetails;
        sa.Is_Pending_Process__c = true;
        update sa;

        WorkOrderResult__c wor = [
            SELECT Id, WorkEndTime__c, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, WorkDate__c,
            WorkStartTime__c, Description__c, ResultType__c, WorkType__c
            FROM WorkOrderResult__c
            LIMIT 1
        ];

        wor.ServiceAppointment__c = sa.Id;
        wor.WorkOrder__c = sa.WorkOrder__c;
        wor.ServiceResource__c = sr.Id;
        wor.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
        wor.WorkStartTime__c = dt.time();
        wor.WorkEndTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time();
        wor.Description__c = '[미결사항]: ' + pendingReasons + ' [미결내용]: ' + pendingDetails;
        wor.ResultType__c = 'WH';
        wor.WorkType__c = 'MV';
        update wor;

        String recordId = wo.Id;

        Test.startTest();
        Map<String, Object> result = DN_ServiceAppointmentController.cloneServiceAppointment(recordId, pendingDetails, pendingReasons);
        Test.stopTest();

    }

    @isTest
    static void cloneServiceAppointmentTest2() {       
        Id currentUserId = UserInfo.getUserId();
        Datetime dt = Datetime.now();
        String pendingReasons = 'Person';
        String pendingDetails = 'Test Pending Detail';

        ServiceResource sr = [
            SELECT Id 
            FROM ServiceResource 
            WHERE RelatedRecordId = :currentUserId 
            LIMIT 1
        ];

        Case ca = [SELECT Id FROM Case LIMIT 1];

        WorkOrder wo = [
            SELECT Id, Status, Pendingprocessing__c, PendingMattersCustomerRequirements__c
            FROM WorkOrder 
            LIMIT 1
        ];
        wo.Status = 'Confirm';
        wo.Pendingprocessing__c = pendingReasons;
        wo.PendingMattersCustomerRequirements__c = pendingDetails;
        update wo;

        ServiceAppointment sa = [
            SELECT Id, Status, Arrival__c, WorkOrder__c, Contact.MobilePhone
            FROM ServiceAppointment 
            WHERE ServiceResource__c = :sr.Id 
            AND Status = 'Assigned' 
            AND ParentRecordId = :wo.Id 
            LIMIT 1
        ];

        sa.Pendingprocessing__c = pendingReasons;
        sa.PendingDetail__c = pendingDetails;
        sa.Is_Pending_Process__c = true;
        update sa;

        WorkOrderResult__c wor = [
            SELECT Id, WorkEndTime__c, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, WorkDate__c,
            WorkStartTime__c, Description__c, ResultType__c, WorkType__c
            FROM WorkOrderResult__c
            LIMIT 1
        ];

        wor.ServiceAppointment__c = sa.Id;
        wor.WorkOrder__c = sa.WorkOrder__c;
        wor.ServiceResource__c = sr.Id;
        wor.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
        wor.WorkStartTime__c = dt.time();
        wor.WorkEndTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time();
        wor.Description__c = '[미결사항]: ' + pendingReasons + ' [미결내용]: ' + pendingDetails;
        wor.ResultType__c = 'WH';
        wor.WorkType__c = 'MV';
        update wor;

        String recordId = wo.Id;

        Test.startTest();
        Map<String, Object> result = DN_ServiceAppointmentController.cloneServiceAppointment(recordId, pendingDetails, pendingReasons);
        Test.stopTest();

    }




    public static User createTestUser(String salesOrg) {
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        user1.SalesOrganization__c = salesOrg;
        return user1;
    }
}