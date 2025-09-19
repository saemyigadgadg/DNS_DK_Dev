/**
 * @description       : DN_WorkOrderIFRunControllerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_WorkOrderIFRunControllerTest {
    @TestSetup
    static void makeData(){
        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;

        TriggerHandler.bypassedHandlers = new Set<String>{
            'AccountTriggerHandler'
            , 'ContactTriggerHandler'
            , 'TicketTriggerHandler'
        };
        
        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TradeCustomer Company', korea);
        account.AccountGroup__c= '1010';
        insert account;

        Account dealer = TestDataFactoryForService.createAccount('Dealer', 'Dealer Company', korea);
        dealer.BusinessNumber__c= 'dealer BusinessNumber';
        dealer.AccountGroup__c= '1010';
        insert dealer;
        
        Account shipto = TestDataFactoryForService.createAccount('TradeCustomer', 'ShipTo Company', korea);
        shipto.BusinessNumber__c= 'shipto BusinessNumber';
        shipto.AccountGroup__c= '1030';
        insert shipto;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        asset.WarrantyStartDateWages__c = Date.newInstance(2024, 5, 20);
        asset.WarrantyEndWages__c = Date.newInstance(2026, 5, 20);
        insert asset;

        Asset asset2 = TestDataFactoryForService.createAsset(shipto.Id);
        asset2.WarrantyStartDateWages__c = Date.newInstance(2024, 5, 20);
        asset2.WarrantyEndWages__c = Date.newInstance(2026, 5, 20);
        insert asset2;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        List<OperatingHours> hoursList = TestDataFactoryForService.createOperatingHours();
        insert hoursList;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);
        insert resource;   

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        List<Case> ticketList = new List<Case>();
        Case dnsaTicket = TestDataFactoryForService.createCase('Ticket_DNSA', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        ticketList.add(dnsaTicket);
        
        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        ticketList.add(technicalTicket);
        
        Case installTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Installation request');
        installTicket.TicketType__c = 'Internal request';
        installTicket.InternalTicketType__c = 'Installation request';
        ticketList.add(installTicket);
        
        Case trainingTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Installation request');
        trainingTicket.TicketType__c = 'Internal request';
        trainingTicket.InternalTicketType__c = 'Post-delivery training';
        ticketList.add(trainingTicket);
        
        Case regularTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Internal request', 'Installation request');
        regularTicket.TicketType__c = 'Internal request';
        regularTicket.InternalTicketType__c = 'Regular Inspections';
        ticketList.add(regularTicket);
        insert ticketList;

        String dnsaId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WorkOrder_DNSA').getRecordTypeId();
        List<WorkOrder> woList = new List<WorkOrder>{
            TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic',installTicket.Id, '104', territory.Id, resource.Id),
            TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic',trainingTicket.Id, '801', territory.Id, resource.Id),
            TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic',regularTicket.Id, '103', territory.Id, resource.Id),
            TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic',technicalTicket.Id, '215', territory.Id, resource.Id),
            new WorkOrder(RecordTypeId = dnsaId, 
                AccountId = account.Id,
                AssetId = asset.Id,
                TicketType__c = 'Failure receipt', 
                OrderType__c = '601', 
                PMActivityType__c = 'HS01',
                SoldTo__c = account.Id,
                ScheduledDispatchTime__c = System.now().addDays(4),
                ServiceOrderNumber__c = 'DNSA_001',
                CaseId = dnsaTicket.Id,
                FailureAreaValue__c = '4T0',
                FailureAreaGroupValue__c = '001',
                FailurePhenomenonValue__c = '01',
                FailurePhenomenonDetail__c = 'TEST',
                CauseOfFailureValue__c = 'TEST',
                CauseOfFailureDetail__c = 'TEST',
                RepairActionValue__c = 'TEST',
                PendingOrCustomerMatters__c = 'TEST'
            )
        };
        insert woList;

        WorkOrder dnsaWo = [SELECT Id FROM WorkOrder WHERE OrderType__c = '601'];
        List<WorkOrderResult__c> wrList = new List<WorkOrderResult__c>{
            new WorkOrderResult__c(ResultType__c = 'WH', 
            WorkOrder__c = dnsaWo.Id, 
            WorkDate__c = Date.newInstance(2024, 5, 20), 
            WorkStartTime__c = Time.newInstance(14, 30, 0, 0),
            WorkEndTime__c = Time.newInstance(15, 30, 0, 0)),
            new WorkOrderResult__c(ResultType__c = 'PT', 
            WorkOrder__c = dnsaWo.Id)
        };
        insert wrList;

    }
        

    @isTest
    static void test104Order(){   
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE OrderType__c = '104' LIMIT 1];  
        InterfaceCommonUtil.setInterface('IF-CSPLUS-043', 'IF_ERP_InstAndComm');

        Test.startTest();
        DN_WorkOrderIFRunController.callWorkOrderIF(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void test801Order(){   
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE OrderType__c = '801' LIMIT 1];  
        InterfaceCommonUtil.setInterface('IF-CSPLUS-005', 'IF_ERP_WorkOrder');

        Test.startTest();
        DN_WorkOrderIFRunController.callWorkOrderIF(wo.Id);
        Test.stopTest();
    }
    
    @isTest
    static void test103Order(){   
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE OrderType__c = '103' LIMIT 1];  
        InterfaceCommonUtil.setInterface('IF-CSPLUS-042', 'IF_ERP_WorkOrder');

        Test.startTest();
        DN_WorkOrderIFRunController.callWorkOrderIF(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void test215Order(){   
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE OrderType__c = '215' LIMIT 1];  
        InterfaceCommonUtil.setInterface('IF-CSPLUS-010', 'IF_ERP_WorkOrder');

        Test.startTest();
        DN_WorkOrderIFRunController.callWorkOrderIF(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void testDNSAOrder(){   
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE RecordType.DeveloperName = 'WorkOrder_DNSA' LIMIT 1];  
        InterfaceCommonUtil.setInterface('IF-CSPLUS-044', 'IF_ERP_SalesOrder');

        Test.startTest();
        DN_WorkOrderIFRunController.callWorkOrderIF(wo.Id);
        DN_WorkOrderIFRunController.callWorkOrderIF('Exception');
        Test.stopTest();
    }
}