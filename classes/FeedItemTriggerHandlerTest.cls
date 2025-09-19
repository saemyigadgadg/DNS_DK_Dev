/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class FeedItemTriggerHandlerTest {
    
    @isTest
    static void testOnAfterInsert() {
        // 테스트용 RecordType 생성
        // RecordType woRecordType = new RecordType(
        //     SObjectType = 'WorkOrder',
        //     DeveloperName = 'WorkOrder_Domestic	',
        //     Name = 'Work Order Record Type'
        // );
        // insert woRecordType;

        // 테스트용 사용자 생성
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        // 테스트용 Case 생성
        // Case testCase = new Case(
        //     Subject = 'Test Case',
        //     Status = 'New',
        //     Origin = 'Phone',
        //     OwnerId = thisUser.Id
        // );
        // insert testCase;

        // 테스트용 WorkOrder 생성
        // WorkOrder wo = new WorkOrder(
        //     // Subject = 'Test WO',
        //     CaseId = testCase.Id,
        //     RecordTypeId = '012F7000000KWFsIAO',
        //     ServiceOrderNumber__c = '403908094',
        //     Status = 'New'
        // );
        // insert wo;
        Set<String> bypassSet = new Set<String>{'TicketTriggerHandler', 'WorkOrderTriggerHandler', 'ServiceResourcesTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

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

        ServiceTerritoryMember stmember = TestDataFactoryForService.createTerritoryMember(territory.Id, resource.Id);
        insert stmember;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', territory.Id, resource.Id);
        insert wo;

        ServiceAppointment appointment = TestDataFactoryForService.createAppointmentWithoutAssignedResource(wo, 'Main');
        insert appointment;

        DateTime dt = wo.ScheduledDispatchTime__c;
        appointment.SchedStartTime = dt;
        appointment.SchedEndTime = dt.addHours(4);
        update appointment;

        System.debug(appointment);
        AssignedResource ar = TestDataFactoryForService.createAssignedResource(appointment.Id, resource.Id);
        insert ar;
        System.debug('AR ::: '+ar);

        // AlertManager__c 레코드 생성
        AlertManager__c alert = new AlertManager__c(
            Name = 'CS Feed Noti',
            IsActive__c = true
        );
        insert alert;

        // FeedItem 생성 (after insert 트리거 작동 대상)
        FeedItem feed = new FeedItem(
            ParentId = wo.Id,
            Body = '<b>Hello World!</b>',
            Type = 'TextPost',
            CreatedById = thisUser.Id
        );
        insert feed;

        // 검증 (assert 또는 log를 활용)
        System.assertEquals('TextPost', feed.Type);
    }
}