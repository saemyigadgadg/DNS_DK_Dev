/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-10-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public class DN_UpdateSchedEndTimeBatchTest {

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
        RecordType dnsRecordType = [SELECT Id, SobjectType, DeveloperName, Name FROM RecordType where name = 'Service Appointment (DNSA)'];
        
        Date today = Date.today();
        DateTime schedEndTime = DateTime.newInstance(today.addDays(1), Time.newInstance(10, 0, 0, 0)); // 내일 오전 10시
        Date tomorrow = Date.today().addDays(1);
        DateTime beforeTomorrow2PM = DateTime.newInstance(tomorrow, Time.newInstance(13, 0, 0, 0)); // 내일 13:00
        List<ServiceAppointment> appointments = new List<ServiceAppointment>();

        String saDNSAId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ServiceAppointment_DNSA').getRecordTypeId();

        // 업데이트 대상 레코드
        appointments.add(new ServiceAppointment(
            RecordTypeId = saDNSAId,
            WorkOrder__c = wo.Id,
            Status = 'Scheduled',
            Pendingprocessing__c = 'Parts',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            SchedStartTime = schedEndTime,
            SchedEndTime = beforeTomorrow2PM,
            EarliestStartTime = System.now().addHours(1),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));

        // 완료 상태이므로 제외될 레코드
        appointments.add(new ServiceAppointment(
            WorkOrder__c = wo.Id,
            Status = 'Completed',
            Pendingprocessing__c = 'Parts',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            SchedStartTime = schedEndTime,
            SchedEndTime = beforeTomorrow2PM,
            EarliestStartTime = System.now().addHours(24),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));

        // SchedEndTime이 null이므로 제외
        appointments.add(new ServiceAppointment(
            WorkOrder__c = wo.Id,
            Status = 'Scheduled',
            Pendingprocessing__c = 'Parts',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            SchedStartTime = schedEndTime,
            SchedEndTime = beforeTomorrow2PM,
            EarliestStartTime = System.now().addHours(-24),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));

        // 다른 RecordType이므로 제외
        appointments.add(new ServiceAppointment(
            WorkOrder__c = wo.Id,
            Status = 'Scheduled',
            Pendingprocessing__c = 'Parts',
            CreatedDate = System.now().addHours(-3),
            ServiceTerritoryId = territory.Id,
            Duration = 60,
            SchedStartTime = schedEndTime,
            SchedEndTime = beforeTomorrow2PM,
            EarliestStartTime = System.now().addHours(1),
            DueDate = System.now().addDays(1),
            ParentRecordId = wo.Id
        ));

        insert appointments;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        DN_UpdateSchedEndTimeBatch batch = new DN_UpdateSchedEndTimeBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        DateTime expectedEndTime = DateTime.newInstance(Date.today().addDays(1), Time.newInstance(14, 0, 0, 0));
        
        List<ServiceAppointment> updated = [
            SELECT Id, SchedEndTime 
            FROM ServiceAppointment 
            WHERE Status != 'Completed' 
            //   AND RecordType.Name = 'Service Appointment (DNSA)'
        ];
        for (ServiceAppointment sa : updated) {
            sa.SchedStartTime = expectedEndTime.addDays(-1);
            sa.SchedEndTime = expectedEndTime;
        }
        update updated;
        // System.debug(updated[0].SchedEndTime + 'updated[0].SchedEndTime');
        System.debug(updated + 'updated');
        System.debug(expectedEndTime + 'expectedEndTime');
    }

    @isTest
    static void testSchedulableExecution() {
        Test.startTest();
        String jobId = System.schedule('Test Sched Job', '0 0 1 * * ?', new DN_UpdateSchedEndTimeBatch());
        Test.stopTest();
    }
}