/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-09-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public class DN_ModelManagerControllerTest {

    @testSetup
    static void setupData() {
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

        ServiceAppointment appointment = TestDataFactoryForService.createDNSAppointment(wo, territory.Id, resource.Id, 'Main');
        insert appointment;

        // WorkOrder wo1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_DNSA', technicalTicket.Id, '201', territory.Id, resource.Id);
        // insert wo;

        // ServiceAppointment appointment1 = TestDataFactoryForService.createDNSAppointment(wo, territory.Id, resource.Id, 'Main');
        // insert appointment;

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
    }

    @isTest
    static void testGetWorkOrder() {
        ServiceAppointment sa = [SELECT Id, ParentRecordId FROM ServiceAppointment LIMIT 1];
        Test.startTest();
        WorkOrder wo = DN_ModelManagerController.getWorkOrder(sa.ParentRecordId);
        Test.stopTest();
        System.assertNotEquals(null, wo);
    }

    @isTest
    static void testGetFailureAreaMajor() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        Test.startTest();
        List<DN_FailureAreaController.CustomSelectOption> result = DN_ModelManagerController.getFailureAreaMajor(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetFailureAreaMiddle() {
        Test.startTest();
        List<DN_FailureAreaController.CustomSelectOption> result = DN_ModelManagerController.getFailureAreaMiddle('MAJOR1');
        Test.stopTest();
    }

    @isTest
    static void testGetFailurePhenomenon() {
        Test.startTest();
        List<DN_FailureAreaController.CustomSelectOption> result = DN_ModelManagerController.getFailurePhenomenon('MIDDLE1');
        Test.stopTest();
    }

    @isTest
    static void testGetFailureCause() {
        Test.startTest();
        List<DN_FailureAreaController.CustomSelectOption> result = DN_ModelManagerController.getFailureCause('PHENOMENON1');
        Test.stopTest();
    }

    @isTest
    static void testGetRepairAction() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        Test.startTest();
        List<DN_FailureAreaController.CustomSelectOption> result = DN_ModelManagerController.getRepairAction(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetServiceAppointment_IS_DNSA() {
        // 사용자에 DNSA 조건 만족하도록 SalesOrg 세팅
        User u = [SELECT Id, ProfileId, SalesOrganization__c FROM User WHERE SalesOrganization__c = '4140' LIMIT 1];

        // User 수정 (SalesOrganization__c 가 4140 또는 4146이어야 함)
        // User updatedUser = new User(Id = u.Id, SalesOrganization__c = '4140');
        // update updatedUser;

        ServiceAppointment sa = [SELECT Id, ParentRecordId FROM ServiceAppointment LIMIT 1];

        Test.startTest();
        String result = DN_ModelManagerController.getServiceAppointment(sa.ParentRecordId);
        Test.stopTest();

    }

    @isTest
    static void testGetServiceAppointment_IS_ORDERTYPE_FALSE() {
        // 조건 미충족 설정 (SalesOrg 제외)
        User u = [SELECT Id, SalesOrganization__c FROM User LIMIT 1];
        // User updatedUser = new User(Id = u.Id, SalesOrganization__c = '1800');
        // update updatedUser;

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        // wo.OrderType__c = '102';
        update wo;

        ServiceAppointment sa = [SELECT Id, ParentRecordId FROM ServiceAppointment LIMIT 1];

        Test.startTest();
        String result = DN_ModelManagerController.getServiceAppointment(sa.ParentRecordId);
        Test.stopTest();

    }

    @isTest
    static void testGetServiceAppointment_IS_COMPLETE_TRUE() {
        // 완료 처리된 예약 테스트
        ServiceAppointment sa = [SELECT Id, Is_Complete__c, ParentRecordId FROM ServiceAppointment LIMIT 1];
        sa.Is_Complete__c = true;
        update sa;

        User u = [SELECT Id, SalesOrganization__c FROM User LIMIT 1];
        // User updatedUser = new User(Id = u.Id, SalesOrganization__c = '1800');
        // update updatedUser;

        Test.startTest();
        String result = DN_ModelManagerController.getServiceAppointment(sa.ParentRecordId);
        Test.stopTest();

    }

    @isTest
    static void testGetServiceAppointment_SUCCESS() {
        // 성공 조건
        WorkOrder wo = [SELECT Id, OrderType__c FROM WorkOrder LIMIT 1];
        wo.OrderType__c = '201'; // startsWith('2') 만족
        update wo;

        ServiceAppointment sa = [SELECT Id, ParentRecordId, Is_Complete__c FROM ServiceAppointment LIMIT 1];
        sa.Is_Complete__c = false;
        update sa;

        User u = [SELECT Id, SalesOrganization__c FROM User LIMIT 1];
        // User updatedUser = new User(Id = u.Id, SalesOrganization__c = '1800');
        // update updatedUser;

        Test.startTest();
        String result = DN_ModelManagerController.getServiceAppointment(sa.ParentRecordId);
        Test.stopTest();

    }

    @isTest
    static void testUpdateResult_isDNSA_true() {
        // 사용자 설정 (SalesOrganization__c = '4140' or '4146')
        User u = DN_ModelManagerControllerTest.createTestUser('4140');
        update u;

        // 관련 객체 설정
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        // JSON 구조
        Map<String, Object> mapData = DN_ModelManagerControllerTest.mockWorkOrderResultJson();
        String saveObject = JSON.serialize(mapData);

        Test.startTest();
        String result = DN_ModelManagerController.updateResult(
            wo.Id,
            saveObject,
            'Non-WRT(N)', // reportValue
            true,
            Date.today().addDays(-1), // repairStart
            Date.today() // repairEnd
        );
        Test.stopTest();
    }

    @isTest
    static void testUpdateResult_isDNSA_false() {
        User u = DN_ModelManagerControllerTest.createTestUser('1800');
        update u;
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        WorkOrderResult__c wor = [SELECT Id FROM WorkOrderResult__c LIMIT 1];
        Map<String, Object> mapData = DN_ModelManagerControllerTest.mockWorkOrderResultJson();
        String saveObject = JSON.serialize(mapData);

        Test.startTest();
        String result = DN_ModelManagerController.updateResult(
            wo.Id,
            saveObject,
            'Non-WRT(N)',
            false,
            Date.today().addDays(-2),
            Date.today()
        );
        Test.stopTest();
    }

    // static testMethod void testUpdateResult_isDNSA_false_MV() {
    //     User u = DN_ModelManagerControllerTest.createTestUser('1800');
    //     update u;
    //     Case c = [SELECT Id FROM Case LIMIT 1];
    //     WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
    //     ServiceResource sr = [SELECT Id FROM ServiceResource LIMIT 1];
    //     ServiceAppointment sa = [SELECT Id, ParentRecordId, ServiceResource__c, Status FROM ServiceAppointment LIMIT 1];

    //     WorkOrderResult__c wor = new WorkOrderResult__c(
    //         WorkOrder__c = wo.Id,
    //         ServiceAppointment__c = sa.Id,
    //         ServiceResource__c = sr.Id,
    //         WorkDate__c = Date.today(),
    //         WorkStartTime__c = Time.newInstance(10, 0, 0, 0),
    //         WorkEndTime__c = Time.newInstance(11, 0, 0, 0),
    //         WorkType__c = 'MV',
    //         ResultType__c = 'WH'
    //     );
    //     insert wor;

    //     Map<String, Object> mapData = DN_ModelManagerControllerTest.mockWorkOrderResultJson();
    //     String saveObject = JSON.serialize(mapData);

    //     Test.startTest();
    //     String result = DN_ModelManagerController.updateResult(
    //         wo.Id,
    //         saveObject,
    //         'Non-WRT(N)',
    //         false,
    //         Date.today().addDays(-2),
    //         Date.today()
    //     );
    //     Test.stopTest();
    // }

    @isTest
    static void testCreatedResult_isDNSA_false() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-028', 'IF_ERP_WorkOrder');
        User u = DN_ModelManagerControllerTest.createTestUser('1800');
        update u;
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Map<String, Object> mapData = DN_ModelManagerControllerTest.mockWorkOrderResultJson();
        String saveObject = JSON.serialize(mapData);

        Test.startTest();
        String result = DN_ModelManagerController.createdResult(
            wo.Id,
            saveObject
        );
        Test.stopTest();
    }

    @IsTest
    static void testCreatedResult_isDNSA_true() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-028', 'IF_ERP_WorkOrder');
        // 사용자 설정 (SalesOrganization__c = '4140' or '4146')
        User u = DN_ModelManagerControllerTest.createTestUser('4140');
        update u;

        // 관련 객체 설정
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        // JSON 구조
        Map<String, Object> mapData = DN_ModelManagerControllerTest.mockWorkOrderResultJson();
        String saveObject = JSON.serialize(mapData);

        Test.startTest();
        String result = DN_ModelManagerController.createdResult(
            wo.Id,
            saveObject
        );
        Test.stopTest();
    }

        @isTest
    static void testCreateResult_isDNSA_false() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-028', 'IF_ERP_WorkOrder');
        User u = DN_ModelManagerControllerTest.createTestUser('1800');
        update u;
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        WorkOrderResult__c wor = [SELECT Id FROM WorkOrderResult__c LIMIT 1];
        Map<String, Object> mapData = DN_ModelManagerControllerTest.mockWorkOrderResultJson();
        String saveObject = JSON.serialize(mapData);

        Test.startTest();
        String result = DN_ModelManagerController.createResult(
            wo.Id,
            saveObject
        );
        Test.stopTest();
    }

    @IsTest
    static void testCreateResult_isDNSA_true() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-028', 'IF_ERP_WorkOrder');
        // 사용자 설정 (SalesOrganization__c = '4140' or '4146')
        User u = DN_ModelManagerControllerTest.createTestUser('4140');
        update u;

        // 관련 객체 설정
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        // JSON 구조
        Map<String, Object> mapData = DN_ModelManagerControllerTest.mockWorkOrderResultJson();
        String saveObject = JSON.serialize(mapData);

        Test.startTest();
        String result = DN_ModelManagerController.createResult(
            wo.Id,
            saveObject
        );
        Test.stopTest();
    }

    @isTest
    static void testUpdateCompletIF() {
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
        String iedd = Date.today().format();
        String iedz = '12:00:00';

        Test.startTest();
        DN_ModelManagerController.updateCompletIF(
            wo.ServiceOrderNumber__c,
            sr.StaffNumber__c,
            msdd, msdz,
            isdd, isdz,
            iedd, iedz
        );
        Test.stopTest();
    }

    @isTest
    static void testCalculateLTXA1_NormalCase() {
        Decimal result = DN_ModelManagerController.calculateLTXA1('2024-06-09', '09:00:00', '2024-06-09', '11:30:00');
    }

    @isTest
    static void testCalculateLTXA1_WithZAndMilliseconds() {
        Decimal result = DN_ModelManagerController.calculateLTXA1('2024-06-09', '08:15:00.000Z', '2024-06-09', '10:45:00.000Z');
    }

    @isTest
    static void testCalculateLTXA1_EmptyTime() {
        Decimal result = DN_ModelManagerController.calculateLTXA1('2024-06-09', '', '2024-06-09', '12:00:00');
    }

    @isTest
    static void testCalculateLTXA1_InvalidTimeFormat() {
        Decimal result = DN_ModelManagerController.calculateLTXA1('2024-06-09', 'xx:yy:zz', '2024-06-09', '12:00:00');
    }

    @isTest
    static void testParseTime_ValidHHmm() {
        Time t = DN_ModelManagerController.parseTime('17:45');
    }

    @isTest
    static void testParseTime_ValidHHmmssZ() {
        Time t = DN_ModelManagerController.parseTime('23:15:30.000Z');
    }

    @isTest
    static void testParseTime_InvalidFormat() {
        try {
            DN_ModelManagerController.parseTime('invalid-time');
        } catch (Exception e) {
        }
    }

    public static User createTestUser(String salesOrg) {
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        user1.SalesOrganization__c = salesOrg;
        return user1;
    }

    public static Case createTestCase() {
        Case c = new Case(Subject = 'Test Case');
        insert c;
        return c;
    }

    public static WorkOrder createWorkOrder(Id caseId) {
        WorkOrder wo = new WorkOrder(
            Subject = 'Test Work Order',
            CaseId = caseId,
            Status = 'New'
        );
        insert wo;
        return wo;
    }

    public static ServiceResource createServiceResource(Id userId) {
        Id usersId = '005F7000006CfKbIAK';
        ServiceResource sr = new ServiceResource(
            Name = 'Test Resource',
            RelatedRecordId = usersId,
            IsActive = true
        );
        insert sr;
        return sr;
    }

    public static ServiceAppointment createServiceAppointment(Id woId, Id srId) {
        ServiceAppointment sa = new ServiceAppointment(
            ParentRecordId = woId,
            ServiceResource__c = srId,
            Status = 'Scheduled',
            WorkerType__c = 'Service Resource (Main)',
            Arrival__c = DateTime.now()
        );
        insert sa;
        return sa;
    }

    public static Map<String, Object> mockWorkOrderResultJson() {
        return new Map<String, Object>{
            'failureAreaMajor' => new Map<String, Object>{'label' => 'Elec._Ctrl', 'value' => '4M0'},
            'failureAreaMiddle' => new Map<String, Object>{'label' => 'CNC System', 'value' => '001'},
            'failurePhenomenon' => new Map<String, Object>{'label' => '작동 불량', 'value' => '01'},
            'failureCause' => new Map<String, Object>{'label' => '설계 이상', 'value' => '01'},
            'repairAction' => new Map<String, Object>{'label' => 'SW/파라메터 변경', 'value' => '06'},
            'pendingOrCustomerMatters' => '테스트 조치내용',
            'failurePhenomenonDetail' => '현상 상세',
            'causeOfFailureDetail' => '원인 상세'
        };
    }
}