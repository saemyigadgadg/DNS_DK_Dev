/**
 * @description       : DN_ServiceHistoryReportControllerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_ServiceHistoryReportControllerTest {
    @TestSetup
    static void makeData(){
        Profile p =[
            SELECT ID 
            FROM Profile 
            WHERE Name = 'System Administrator' OR Name = '시스템 관리자'
        ];

        List<User> userList = new List<User>{
            new User(
                Alias = 'standt1',Country='United Kingdom',
                Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', 
                LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', 
                UserName='demoTest05461@andomdemodomain.com'
            ),
            new User(
                Alias = 'standt1',Country='United Kingdom',
                Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', 
                LastName='Testing2', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', 
                UserName='demoTest205461@andomdemodomain.com'
            )   
        };
        insert userList;

        TriggerHandler.bypassedHandlers = new Set<String>{
            'AccountTriggerHandler'
            , 'ContactTriggerHandler'
            , 'UserTriggerHandler'
            , 'TicketTriggerHandler'
            , 'WorkOrderTriggerHandler'
        };

        List<OperatingHours> hoursList = TestDataFactoryForService.createOperatingHours();
        insert hoursList;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);
        insert resource;
        ServiceTerritory territory2 = [SELECT Id FROM ServiceTerritory WHERE Name = '광명산업'];
        ServiceResource resource2 = TestDataFactoryForService.createResource(territory2.Id);
        resource2.RelatedRecordId = userList[0].Id;
        insert resource2;
        ServiceResource resource3 = TestDataFactoryForService.createResource(territory2.Id);
        resource3.RelatedRecordId = userList[1].Id;
        insert resource3;

        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;

        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        insert account;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        ModelManager__c mm = new ModelManager__c(Name = 'HM1250', ModelCode__c = 'MH0014', ModelGroup__c = 'TC');
        insert mm;
        
        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;
        
        WorkOrder workOrder1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', territory.Id, resource.Id);
        workOrder1.ReceptionDetail__c = 'TEST';
        workOrder1.PendingOrCustomerMatters__c = 'TEST';
        workOrder1.ConfirmedDate__c = System.now();
        insert workOrder1;

        ServiceAppointment sa1 = TestDataFactoryForService.createDNSAppointment(workOrder1, territory.Id, resource.Id, 'Main');
        sa1.Department__c = System.now();
        sa1.Arrival__c = System.now();
        sa1.WorkCompletionTime__c = System.now();
        sa1.DepartmentReport__c = System.now();
        sa1.ArrivalReport__c = System.now();
        sa1.WorkCompletionTimeMobile__c = System.now();
        
        insert sa1;

        List<WorkOrderResult__c> wrList = new List<WorkOrderResult__c>{
            new WorkOrderResult__c(
                WorkOrder__c = workOrder1.Id,
                ServiceAppointment__c = sa1.Id,
                ResultType__c = 'WH',
                WorkDate__c = Date.today(),
                WorkEndDate__c = Date.today().addDays(1),
                WorkStartTime__c = Time.newInstance(17, 30, 0, 0),
                WorkEndTime__c = Time.newInstance(17, 35, 0, 0),
                ServiceResource__c = resource.Id,
                WorkType__c = 'WK'
            ),
            new WorkOrderResult__c(
                WorkOrder__c = workOrder1.Id,
                ServiceAppointment__c = sa1.Id,
                ResultType__c = 'COM',
                TotalStandardWork__c = 10,
                TotalWork__c = 10,
                OverReason__c = 'TEST'
            ),
            new WorkOrderResult__c(
                WorkOrder__c = workOrder1.Id,
                ServiceAppointment__c = sa1.Id,
                ResultType__c = 'SWT',
                StandardWorkForce__c = 10,
                StandardWorkItem__c = 'CROSS SLIDE 교체_TEST'
            ),
            new WorkOrderResult__c(
                WorkOrder__c = workOrder1.Id,
                ServiceAppointment__c = sa1.Id,
                ResultType__c = 'SWT',
                StandardWorkForce__c = 10,
                StandardWorkItem__c = 'CROSS SLIDE 교체_TEST'
            )
        };
        insert wrList;

        List<Collaborator__c> colList = new List<Collaborator__c>{
            new Collaborator__c(WorkOrder__c = workOrder1.Id, ServiceResource__c = resource2.Id),
            new Collaborator__c(WorkOrder__c = workOrder1.Id, ServiceResource__c = resource3.Id)
        };
        insert colList;

    }

    @isTest
    static void test1(){        
        Account acc = [SELECT Id, Name, CustomerCode__c FROM Account LIMIT 1];
        Asset equip = [SELECT Id, Name, MachineName__c FROM Asset LIMIT 1];
        WorkOrder wo = [SELECT Id, ServiceOrderNumber__c, Worker__c, ServiceTerritoryId, Status FROM WorkOrder LIMIT 1];

        String conditionData1 = '{"startDate":null,"endDate":null,"completeStartDate":null,"completeEndDate":null,"orderNumber":"'+wo.ServiceOrderNumber__c+'","workcenter":"'+wo.ServiceTerritoryId+'","branch":"'+wo.ServiceTerritoryId+'","status":"Assigned","account":"'+acc.Name+'","modelValue":"'+equip.Name+'","modelTypeValue":"'+equip.MachineName__c+'","checkStandard":true,"customerCode":"'+acc.CustomerCode__c+'","confirmStartDate":"2024-06-05T12:00:00Z","confirmEndDate":"2024-06-05T12:00:00Z", "modelTypeNameValue":"HM1250"}';
        String conditionData2 = '{"startDate":"2025-05-01","endDate":"2025-06-05","completeStartDate":"2025-06-02","completeEndDate":"2025-06-05","orderNumber":"'+wo.ServiceOrderNumber__c+'","workcenter":"'+wo.ServiceTerritoryId+'","branch":"'+wo.ServiceTerritoryId+'","status":"Assigned","account":"'+acc.Name+'","modelValue":"'+equip.Name+'","modelTypeValue":"'+equip.MachineName__c+'","checkStandard":true,"customerCode":"'+acc.CustomerCode__c+'","confirmStartDate":null,"confirmEndDate":null}';
        
        Test.startTest();
        DN_ServiceHistoryReportController.getEquipmentList('MH0014');
        DN_ServiceHistoryReportController.getTypeList('HM1250');
        DN_ServiceHistoryReportController.getSettingInfo();
        DN_ServiceHistoryReportController.getServiceHistoryList(conditionData1);
        DN_ServiceHistoryReportController.getServiceHistoryList(conditionData2);
        DN_ServiceHistoryReportController.getServiceHistoryList('');
        Test.stopTest();
    }

    @isTest
    static void test2(){        
        Account acc = [SELECT Id, Name, CustomerCode__c FROM Account LIMIT 1];
        Asset equip = [SELECT Id, Name, MachineName__c FROM Asset LIMIT 1];
        WorkOrder wo = [SELECT Id, ServiceOrderNumber__c, Worker__c, ServiceTerritoryId, Status FROM WorkOrder WHERE OrderType__c = '201'  LIMIT 1];
        
        Date today = Date.today();
        String yearStr = String.valueOf(today.year());
        String monthStr = today.month() < 10 ? '0' + today.month() : String.valueOf(today.month());
        String dayStr = today.day() < 10 ? '0' + today.day() : String.valueOf(today.day());
        String str = yearStr + '-' + monthStr + '-' + dayStr;
        
        String conditionData1 = '{"startDate":"'+str+'","endDate":"'+str+'","completeStartDate":"'+str+'","completeEndDate":"'+str+'","orderNumber":"'+wo.ServiceOrderNumber__c+'","workcenter":"'+wo.ServiceTerritoryId+'","branch":"'+wo.ServiceTerritoryId+'","status":"Assigned","account":"'+acc.Name+'","modelValue":"'+equip.Name+'","modelTypeValue":"'+equip.MachineName__c+'","checkStandard":false,"customerCode":"'+acc.CustomerCode__c+'","confirmStartDate":null,"confirmEndDate":null}';
        String conditionData2 = '{"startDate":"'+str+'","endDate":"'+str+'","completeStartDate":null,"completeEndDate":null,"orderNumber":"'+wo.ServiceOrderNumber__c+'","workcenter":"'+wo.ServiceTerritoryId+'","branch":"'+wo.ServiceTerritoryId+'","status":"Assigned","account":"'+acc.Name+'","modelValue":"'+equip.Name+'","modelTypeValue":"'+equip.MachineName__c+'","checkStandard":false,"customerCode":"'+acc.CustomerCode__c+'","confirmStartDate":null,"confirmEndDate":null}';


        Test.startTest();
        DN_ServiceHistoryReportController.getServiceHistoryList(conditionData1);
        DN_ServiceHistoryReportController.getServiceHistoryList(conditionData2);
        Test.stopTest();
    }

    @isTest
    static void test3(){        
        Account acc = [SELECT Id, Name, CustomerCode__c FROM Account LIMIT 1];
        Asset equip = [SELECT Id, Name, MachineName__c FROM Asset LIMIT 1];
        WorkOrder wo = [SELECT Id, ServiceOrderNumber__c, Worker__c, ServiceTerritoryId, Status FROM WorkOrder WHERE OrderType__c = '201' LIMIT 1];
        
        Date today = Date.today();
        String yearStr = String.valueOf(today.year());
        String monthStr = today.month() < 10 ? '0' + today.month() : String.valueOf(today.month());
        String dayStr = today.day() < 10 ? '0' + today.day() : String.valueOf(today.day());
        String str = yearStr + '-' + monthStr + '-' + dayStr;
        
        String conditionData1 = '{"startDate":"'+str+'","endDate":"'+str+'","completeStartDate":null,"completeEndDate":null,"orderNumber":"'+wo.ServiceOrderNumber__c+'","workcenter":"'+wo.ServiceTerritoryId+'","branch":"'+wo.ServiceTerritoryId+'","status":"Assigned","account":"'+acc.Name+'","modelValue":"'+equip.Name+'","modelTypeValue":"'+equip.MachineName__c+'","checkStandard":false,"customerCode":"'+acc.CustomerCode__c+'","confirmStartDate":null,"confirmEndDate":null}';

        Test.startTest();
        DN_ServiceHistoryReportController.getServiceHistoryList(conditionData1);
        Test.stopTest();
    }

    @isTest
    static void test4(){        
        Account acc = [SELECT Id, Name, CustomerCode__c FROM Account LIMIT 1];
        Asset equip = [SELECT Id, Name, MachineName__c FROM Asset LIMIT 1];
        
        WorkOrder wo = [SELECT Id, ServiceOrderNumber__c, Worker__c, ServiceTerritoryId, Status, CreatedDate, CaseID FROM WorkOrder WHERE OrderType__c = '201' LIMIT 1];
        
        Date testMigDate = Date.newInstance(2025,4,1);
        String yearStr = String.valueOf(testMigDate.year());
        String monthStr = testMigDate.month() < 10 ? '0' + testMigDate.month() : String.valueOf(testMigDate.month());
        String dayStr = testMigDate.day() < 10 ? '0' + testMigDate.day() : String.valueOf(testMigDate.day());
        String str = yearStr + '-' + monthStr + '-' + dayStr;
        
       TriggerHandler.bypassedHandlers = new Set<String>{
            'TicketTriggerHandler'
        };

        DateTime migrDateTime = DateTime.newInstance(2025,4,1);

        Case ticket = TestDataFactoryForService.createCase('Ticket_Domestic', acc.Id, equip.Id, null, 'Technical inquiry', 'Failure receipt');
        ticket.ApplicationDateTime__c = DateTime.newInstance(2025, 4, 1, 15, 30, 0);
        insert ticket;

        WorkOrder workOrder2 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', ticket.Id, '202', wo.ServiceTerritoryId, wo.Worker__c);
        workOrder2.ReceptionDetail__c = 'TEST';
        workOrder2.PendingOrCustomerMatters__c = 'TEST';
        workOrder2.ConfirmedDate__c = migrDateTime;
        insert workOrder2;

        ServiceAppointment mig_sa = TestDataFactoryForService.createDNSAppointment(workOrder2, wo.ServiceTerritoryId, wo.Worker__c, 'Main');
        mig_sa.Department__c = migrDateTime;
        mig_sa.Arrival__c = migrDateTime;
        mig_sa.WorkCompletionTime__c = migrDateTime;
        mig_sa.DepartmentReport__c = migrDateTime;
        mig_sa.ArrivalReport__c = migrDateTime;
        mig_sa.WorkCompletionTimeMobile__c = migrDateTime;
        
        insert mig_sa;

        Date migDate = Date.newInstance(2025, 4, 1);
        List<WorkOrderResult__c> mig_wrList = new List<WorkOrderResult__c>{
            new WorkOrderResult__c(
                WorkOrder__c = workOrder2.Id,
                ServiceAppointment__c = mig_sa.Id,
                ResultType__c = 'WH',
                WorkDate__c = migDate,
                WorkEndDate__c = migDate.addDays(1),
                WorkStartTime__c = Time.newInstance(17, 30, 0, 0),
                WorkEndTime__c = Time.newInstance(17, 35, 0, 0),
                ServiceResource__c = wo.Worker__c,
                WorkType__c = 'WK'
            ),
            new WorkOrderResult__c(
                WorkOrder__c = workOrder2.Id,
                ServiceAppointment__c = mig_sa.Id,
                ResultType__c = 'COM',
                TotalStandardWork__c = 10,
                TotalWork__c = 10,
                OverReason__c = 'TEST'
            ),
            new WorkOrderResult__c(
                WorkOrder__c = workOrder2.Id,
                ServiceAppointment__c = mig_sa.Id,
                ResultType__c = 'SWT',
                StandardWorkForce__c = 10,
                StandardWorkItem__c = 'CROSS SLIDE 교체_TEST'
            ),
            new WorkOrderResult__c(
                WorkOrder__c = workOrder2.Id,
                ServiceAppointment__c = mig_sa.Id,
                ResultType__c = 'SWT',
                StandardWorkForce__c = 10,
                StandardWorkItem__c = 'CROSS SLIDE 교체_TEST'
            )
        };
        insert mig_wrList;

        String conditionData1 = '{"startDate":"'+str+'","endDate":"'+str+'","completeStartDate":null,"completeEndDate":null,"orderNumber":"'+workOrder2.ServiceOrderNumber__c+'","workcenter":"'+workOrder2.ServiceTerritoryId+'","branch":"'+workOrder2.ServiceTerritoryId+'","status":"Assigned","account":"'+acc.Name+'","modelValue":"'+equip.Name+'","modelTypeValue":"'+equip.MachineName__c+'","checkStandard":false,"customerCode":"'+acc.CustomerCode__c+'","confirmStartDate":null,"confirmEndDate":null}';

        WorkOrder wo1 = [SELECT ID, FM_ApplicationDateTime__c FROM WorkOrder WHERE OrderType__c = '202' LIMIT 1];
        Test.setCreatedDate(ticket.Id, DateTime.newInstance(2025,4,1));
        Test.setCreatedDate(workOrder2.Id, DateTime.newInstance(2025,4,1));

        Test.startTest();
        DN_ServiceHistoryReportController.getServiceHistoryList(conditionData1);
        Test.stopTest();
    }

    
    
}