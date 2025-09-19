/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-10-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public class DN_MonthlyDispatchStatusReportBatchTest {

    @testSetup
    static void setupTestData() {
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

        List<WorkOrder> woList = new List<WorkOrder>();
        for (Integer i = 1; i <= 12; i++) {
            DateTime repairDateTime = DateTime.newInstance(Date.today().year(), i, 15, 18, 0, 0); // 야간
            woList.add(new WorkOrder(
                Subject = 'Test WorkOrder ' + i,
                ServiceTerritoryId = territory.Id
                // ,
                // FM_RepairRequestDateTime__c = repairDateTime
            ));
        }
        insert woList;
    }

    @isTest
    static void testBatchExecuteAndFinish() {
        Test.startTest();
        DN_MonthlyDispatchStatusReportBatch batch = new DN_MonthlyDispatchStatusReportBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // 결과 검증
        List<PendingprocessingReport__c> reports = [
            SELECT Id, ServiceCenter__c, TotalCount__c, TotalDispatchRate__c, Score__c, Ranking__c
            FROM PendingprocessingReport__c
        ];
    }

    @isTest
    static void testScheduledExecution() {
        Test.startTest();
        String jobId = System.schedule('Test Schedule', '0 0 1 * * ?', new DN_MonthlyDispatchStatusReportBatch());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
    }

    @isTest
    static void testCompareScoreAndDispatchRate() {
        PendingprocessingReport__c r1 = new PendingprocessingReport__c(
            Score__c = 2,
            TotalDispatchRate__c = 20
        );
        
        PendingprocessingReport__c r2 = new PendingprocessingReport__c(
            Score__c = 3,
            TotalDispatchRate__c = 30
        );

        PendingprocessingReport__c r3 = new PendingprocessingReport__c(
            Score__c = 4,
            TotalDispatchRate__c = 50
        );

        PendingprocessingReport__c r4 = new PendingprocessingReport__c(
            Score__c = 5,
            TotalDispatchRate__c = 80
        );

        PendingprocessingReport__c r5 = new PendingprocessingReport__c(); // 모두 null

        // List<PendingprocessingReport__c> list = new List<PendingprocessingReport__c>{ r2, r1, r3, r5, r4 };

        // list.sort(new DN_MonthlyDispatchStatusReportBatch.ScoreCompare());
    }

    @isTest
    static void testNullDispatchRateResolution() {
        PendingprocessingReport__c r1 = new PendingprocessingReport__c(Score__c = 5, TotalDispatchRate__c = null);
        PendingprocessingReport__c r2 = new PendingprocessingReport__c(Score__c = 5, TotalDispatchRate__c = 20);

        Integer result = new DN_MonthlyDispatchStatusReportBatch.ScoreCompare().compare(r1, r2);
    }
    
    @isTest
    static void testNullDispatch() {
        PendingprocessingReport__c r1 = new PendingprocessingReport__c(Score__c = 5, TotalDispatchRate__c = 20);
        PendingprocessingReport__c r2 = new PendingprocessingReport__c(Score__c = 5, TotalDispatchRate__c = null);

        Integer result = new DN_MonthlyDispatchStatusReportBatch.ScoreCompare().compare(r1, r2);
    }
    
    @isTest
    static void testNullDispatchRate() {
        PendingprocessingReport__c r1 = new PendingprocessingReport__c(Score__c = 5, TotalDispatchRate__c = 20);
        PendingprocessingReport__c r2 = new PendingprocessingReport__c(Score__c = 5, TotalDispatchRate__c = 20);

        Integer result = new DN_MonthlyDispatchStatusReportBatch.ScoreCompare().compare(r1, r2);
    }
    @isTest
    static void testNullScoreResolution() {
        PendingprocessingReport__c r1 = new PendingprocessingReport__c(Score__c = null);
        PendingprocessingReport__c r2 = new PendingprocessingReport__c(Score__c = 1);

        Integer result = new DN_MonthlyDispatchStatusReportBatch.ScoreCompare().compare(r1, r2);
    }
}