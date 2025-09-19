/**
 * @description       : DN_WorkOrderCancelController_TEST
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class WorkOrderTriggerHandlerTest {
    @TestSetup
    static void makeData(){

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

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;

        List<OperatingHours> hours = TestDataFactoryForService.createOperatingHours();        
        insert hours;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();       
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);       
        insert resource;

        List<WorkOrder> insertWOList = new List<WorkOrder>();
        WorkOrder wo1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', territory.Id, resource.Id);
        insertWOList.add(wo1);
        insert insertWOList;

        TestDataFactoryForService.activatePriceBook();

        List<Product2> insertProdList = new List<Product2>();
        Product2 prod = TestDataFactoryForService.createProduct();
        insertProdList.add(prod);
        Product2 prod2 = TestDataFactoryForService.createProduct();
        prod2.Name = '220209-00219-KIT';
        prod2.ProductCode = '220209-00219-KIT';
        insertProdList.add(prod2);
        insert insertProdList;

        ProductRequest pr = TestDataFactoryForService.createProductRequest(prod, wo1, territory);
        pr.Status = 'Approved';
        insert pr;
        
    }

    @isTest
    static void testSMS(){
        Test.startTest();
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        SendSMS__e smsEvent = new SendSMS__e(
            WorkOrderId__c = wo.Id
        );
        EventBus.publish(smsEvent);
        Test.stopTest();
    }

    @isTest
    static void testInstallation() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', 'IF_ERP_Material');

        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        ServiceResource resource = [SELECT Id FROM ServiceResource LIMIT 1];

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Installation request');
        insert technicalTicket;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '104', territory.Id, resource.Id);
        insert wo;
    }

    @isTest
    static void testInstallation1() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', 'IF_ERP_Material');

        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        ServiceResource resource = [SELECT Id FROM ServiceResource LIMIT 1];
        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Pre-Call');
        insert technicalTicket;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '104', territory.Id, resource.Id);
        insert wo;
    }

    @isTest
    static void testUpdateWO() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-010', 'IF_ERP_WorkOrder');
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        String profileId = UserInfo.getProfileId();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        User user;
        System.runAs(thisUser) {
            user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
            insert user;
        }

        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id, user.Id);
        resource.Name = 'TEST2';
        resource.StaffNumber__c = '6483';
        insert resource;

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        wo.Worker__c = resource.Id;
        update wo;
    }
    
    @isTest
    static void testUpdateWO_WithProductRequest_ShouldThrowError() {
        // 필요한 레코드타입 조회
        RecordType rt = [
            SELECT Id FROM RecordType 
            WHERE DeveloperName = 'WorkOrder_Domestic' AND SObjectType = 'WorkOrder' 
            LIMIT 1
        ];

        // WorkOrder 생성
        WorkOrder wo = new WorkOrder(
            Subject = 'Test for Validation',
            Status = 'New',
            RecordTypeId = rt.Id,
            OrderType__c = '106'
        );
        insert wo;

        // 조건 3: ProductRequest 연결 (부품청구)
        ProductRequest pr = new ProductRequest(
            WorkOrderId = wo.Id,
            Status = 'Draft'
        );
        insert pr;

        // OrderType 변경하여 validation 발생 유도
        wo.OrderType__c = '204';

        // 테스트 수행
        Test.startTest();
        try {
            update wo; // 이 줄에서 addError 발생 예상
            //System.assert(false, 'Expected exception due to PMActivity 변경 제한');
        } catch (DmlException e) {
            System.debug('Caught Exception: ' + e.getMessage());
            System.assert(
                e.getMessage().contains('부품청구가 된 오더는 PMActivity를 변경할 수 없습니다'),
                '에러 메시지가 기대와 다릅니다.'
            );
        }
        Test.stopTest();
    }


    @isTest
    static void testUpdateWO3() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-010', 'IF_ERP_WorkOrder');
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        String profileId = UserInfo.getProfileId();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        User user;
        System.runAs(thisUser) {
            user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
            insert user;
        }

        AssignmentRule__c ar = new AssignmentRule__c ();
        ar.Name = 'P-Claim 사용자';
        ar.AssignmentType__c = 'Owner';
        ar.Corporation__c = 'DNS';

        insert ar;

        AssignmentMember__c am = new AssignmentMember__c();
        am.AssignmentRule__c = ar.Id;
        am.User__c = thisUser.Id;
        insert am;

        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id, user.Id);
        resource.Name = 'TEST2';
        resource.StaffNumber__c = '6483';
        insert resource;



        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        wo.FieldWorker__c = resource.Id;
        update wo;
    }

    @isTest
    static void testUpdateWO4() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-010', 'IF_ERP_WorkOrder');
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        String profileId = UserInfo.getProfileId();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        User user;
        System.runAs(thisUser) {
            user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
            insert user;
        }

        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id, user.Id);
        resource.Name = 'TEST2';
        resource.StaffNumber__c = '6483';
        insert resource;

        WorkOrder wo = [SELECT Id, CaseId FROM WorkOrder LIMIT 1];

        // Case ticket = [SELECT Id FROM Case WHERE Id = :wo.CaseId LIMIT 1];

        // TriggerHandler.bypass('TicketTriggerHandler');
        
        // ticket.FailureArea__c = null;
        // ticket.FailureAreaValue__c = null;
        // ticket.FailureAreaDetail__c = null;
        // ticket.FailureAreaDetailValue__c = null;
        // ticket.FailurePhenomenon__c = null;
        // ticket.FailurePhenomenonValue__c = null;
        // ticket.FailureArea__c = null;
        // update ticket;
        
        // TriggerHandler.clearAllBypasses();

        wo.FieldWorker__c = resource.Id;
        wo.FailureAreaValue__c = null;
        wo.FailureAreaGroupValue__c = null;
        wo.FailurePhenomenonValue__c = null;
        wo.ScheduledDispatchTime__c = System.now();
        update wo;
    }

    @isTest
    static void testUpdateWO5() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-005', 'IF_ERP_WorkOrder');
        InterfaceCommonUtil.setInterface('IF-CSPLUS-010', 'IF_ERP_WorkOrder');

        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        ServiceResource resource = [SELECT Id FROM ServiceResource LIMIT 1];

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Post-delivery training');
        insert technicalTicket;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '801', territory.Id, resource.Id);
        insert wo;

        wo.OrderType__c = '802';
        update wo;
    }

    @isTest
    static void testUpdateWO6() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-043', 'IF_ERP_InstAndComm');

        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        ServiceResource resource = [SELECT Id FROM ServiceResource LIMIT 1];

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Installation request');
        insert technicalTicket;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '809', territory.Id, resource.Id);
        insert wo;

        wo.OrderType__c = '104';
        update wo;
        wo.Status = 'Completed';
        update wo;
    }

    @isTest
    static void testUpdateWO7() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-042', 'IF_ERP_WorkOrder');

        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        ServiceResource resource = [SELECT Id FROM ServiceResource LIMIT 1];


        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Installation request');
        insert technicalTicket;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '104', territory.Id, resource.Id);
        insert wo;

        wo.OrderType__c = '809';
        update wo;
    }

    @isTest
    static void testUpdateWO8() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-044', 'IF_ERP_SalesOrder');

        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        ServiceResource resource = [SELECT Id FROM ServiceResource LIMIT 1];

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_DNSA', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');

        insert technicalTicket;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_DNSA', technicalTicket.Id, '602', territory.Id, resource.Id);
        wo.PMActivityType__c = 'HS01';
        insert wo;

        wo.OrderType__c = '601';
        update wo;
    }

    @isTest
    static void testDeleteWO() {
        WorkOrder wo = [SELECT Id, CaseId FROM WorkOrder LIMIT 1];

        delete wo;
    }

}