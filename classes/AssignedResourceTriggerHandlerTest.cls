/**
 * @description       : DN_WorkOrderCancelController_TEST
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class AssignedResourceTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        EmailTemplate eTem = [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 1];
        CustomNotificationType noti = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];

        List<AlertManager__c> insertAlertManagerList = new List<AlertManager__c>();
        AlertManager__c alertManager1 = new AlertManager__c();
        alertManager1.Name = 'WorkOrder Assignment Service Resource Notification';
        alertManager1.Part__c = 'Service';
        alertManager1.IsActive__c = true;
        alertManager1.Description__c = 'Test';
        insertAlertManagerList.add(alertManager1);
        AlertManager__c alertManager2 = new AlertManager__c();
        alertManager2.Name = 'WorkOrder Assignment DNSA Service Resource Notification';
        alertManager2.Part__c = 'Service';
        alertManager2.IsActive__c = true;
        alertManager2.Description__c = 'Test';
        insertAlertManagerList.add(alertManager2);
        insert insertAlertManagerList;

        AlertEmailTemplate__c alertEmail = new AlertEmailTemplate__c();
        alertEmail.Name = 'TestEmail';
        alertEmail.AlertManagerID__c = alertManager1.Id;
        alertEmail.EmailTemplateName__c = eTem.DeveloperName;
        alertEmail.Language__c = 'ko';
        insert alertEmail;

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
        AlertNotificationTemplate__c alertNoti2 = new AlertNotificationTemplate__c();
        alertNoti2.Name = 'TestNoti';
        alertNoti2.AlertManagerID__c = alertManager1.Id;
        alertNoti2.Body__c = 'Test Notification {0}';
        alertNoti2.IsDynamic__c = true;
        alertNoti2.Language__c = 'ko';
        alertNoti2.Title__c = 'Test Notification';
        alertNoti2.CustomNotificationName__c = noti.DeveloperName;
        insertNotiTemList.add(alertNoti2);
        insert insertNotiTemList;

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
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);       
        insert resource;

        List<WorkOrder> insertWOList = new List<WorkOrder>();
        WorkOrder wo1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket1.Id, '201', territory.Id, resource.Id);
        insertWOList.add(wo1);
        WorkOrder wo2 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket2.Id, '104', territory.Id, resource.Id);
        insertWOList.add(wo2);
        WorkOrder wo3 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_DNSA', technicalTicket3.Id, '602', territory.Id, resource.Id);
        wo3.PMActivityType__c = 'HS01';
        insertWOList.add(wo3);
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
    static void testAssignedResource1(){

        WorkOrder wo = [SELECT Id, Worker__c FROM WorkOrder WHERE OrderType__c = '201' LIMIT 1];

        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = wo.Id;
        sa.ServiceResource__c = wo.Worker__c;
        sa.SchedStartTime = System.now();
        sa.SchedEndTime = System.now().addDays(1);
        insert sa;

    }

    @isTest
    static void testAssignedResource2(){
        WorkOrder wo = [SELECT Id, Worker__c FROM WorkOrder WHERE OrderType__c = '104' LIMIT 1];

        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = wo.Id;
        sa.ServiceResource__c = wo.Worker__c;
        sa.SchedStartTime = System.now();
        sa.SchedEndTime = System.now().addDays(1);
        insert sa;

    }

    @isTest
    static void testDNSAAssignedResource2(){
        WorkOrder wo = [SELECT Id, Worker__c FROM WorkOrder WHERE RecordType.Name = 'WorkOrder(DNSA)' LIMIT 1];

        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = wo.Id;
        sa.ServiceResource__c = wo.Worker__c;
        sa.SchedStartTime = System.now();
        sa.SchedEndTime = System.now().addDays(1);
        insert sa;

    }
}