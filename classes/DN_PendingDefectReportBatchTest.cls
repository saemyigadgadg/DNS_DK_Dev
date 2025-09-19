/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-10-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public class DN_PendingDefectReportBatchTest {

    @testSetup
    static void setupData() {
        // 기본 테스트 사용자
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

        List<ServiceAppointment> saList = new List<ServiceAppointment>();

        saList.add(new ServiceAppointment(
            WorkOrder__c = wo.Id,
            Status = 'Assigned',
            Pendingprocessing__c = 'Parts',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            EarliestStartTime = System.now().addHours(1),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));

        saList.add(new ServiceAppointment(
            WorkOrder__c = wo.Id,
            Status = 'Assigned',
            Pendingprocessing__c = 'Customer',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            EarliestStartTime = System.now().addHours(1),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));

        saList.add(new ServiceAppointment(
            WorkOrder__c = wo.Id,
            Status = 'Assigned',
            Pendingprocessing__c = 'Closing',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            EarliestStartTime = System.now().addHours(1),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));

        saList.add(new ServiceAppointment(
            WorkOrder__c = wo.Id,
            Status = 'Assigned',
            Pendingprocessing__c = 'Person',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            EarliestStartTime = System.now().addHours(1),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));

        saList.add(new ServiceAppointment(
            WorkOrder__c = wo.Id,
            Status = 'Assigned',
            Pendingprocessing__c = 'Installation',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            EarliestStartTime = System.now().addHours(1),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));

        saList.add(new ServiceAppointment(
            WorkOrder__c = wo.Id,
            Status = 'Assigned',
            Pendingprocessing__c = 'Technical Parts',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            EarliestStartTime = System.now().addHours(1),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));
        
        saList.add(new ServiceAppointment(
            WorkOrder__c = wo.Id,
            Status = 'Assigned',
            Pendingprocessing__c = 'ETC',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            EarliestStartTime = System.now().addHours(1),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));
        // saList.add(new ServiceAppointment(
        //     WorkOrder__c = wo.Id,
        //     Status = 'Assigned',
        //     Pendingprocessing__c = 'Customer',
        //     CreatedDate = System.now().addHours(-2),
        //     ServiceTerritoryId = territory.Id
        // ));

        // saList.add(new ServiceAppointment(
        //     WorkOrder__c = wo.Id,
        //     Status = 'Assigned',
        //     Pendingprocessing__c = 'Closing',
        //     CreatedDate = System.now().addHours(-1),
        //     ServiceTerritoryId = territory.Id
        // ));

        insert saList;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        DN_PendingDefectReportBatch batch = new DN_PendingDefectReportBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // 결과 확인
        List<PendingprocessingReport__c> reports = [
            SELECT WorkCenter__c, Parts__c, Customer__c, Technical__c, Total__c, WeeklyNumberReceived__c
            FROM PendingprocessingReport__c
        ];
        
        // PendingprocessingReport__c rpt = reports[0];
    }

    @isTest
    static void testBatchWithExistingReports() {
        // 기존 레포트 생성
        PendingprocessingReport__c oldReport = new PendingprocessingReport__c(
            DateReceived__c = String.valueOf(System.today()),
            DateReceive__c = System.today(),
            WorkCenter__c = 'Test Center',
            Parts__c = 99,
            Total__c = 99
        );
        insert oldReport;

        Test.startTest();
        DN_PendingDefectReportBatch batch = new DN_PendingDefectReportBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        List<PendingprocessingReport__c> reports = [
            SELECT WorkCenter__c, Total__c FROM PendingprocessingReport__c
        ];
    }

    @isTest
    static void testSchedulableExecute() {
        Test.startTest();
        String jobId = System.schedule('DefectReportScheduledJob', '0 0 23 * * ?', new DN_PendingDefectReportBatch());
        Test.stopTest();
    }
}