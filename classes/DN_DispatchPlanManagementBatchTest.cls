/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-12-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public class DN_DispatchPlanManagementBatchTest {
    
    @testSetup
    static void setup() {
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        List<User> users = new List<User>();
        for (Integer i = 0; i < 3; i++) {
            users.add(new User(
                Username = 'testcodeuser' + i + '@test.com',
                Alias = 'tuser' + i,
                Email = 'testuser' + i + '@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test' + i,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile,
                TimeZoneSidKey = 'Asia/Seoul'
            ));
        }
        insert users;

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
        OperatingHours koHours = [SELECT Id FROM OperatingHours WHERE Name = '대한민국 표준 작업 시간'];
        List<ServiceTerritory> stList = new List<ServiceTerritory>();
        for (Integer i = 0; i < 2; i++) {
            stList.add(new ServiceTerritory(
                Name = '지사' + i,
                PlanningPlant__c = '184S',
                OperatingHoursId = koHours.Id,
                WCCode__c = '114G',
                IsActive = true
            ));
        }
        insert stList;

        // ServiceResource 생성 (User마다 하나씩, Territory마다 하나씩)
        List<ServiceResource> srList = new List<ServiceResource>();
        for (Integer i = 0; i < 3; i++) {
            srList.add(new ServiceResource(
                Name = 'SR_' + i,
                RelatedRecordId = users[i].Id,
                Service_Territory__c = territory.Id
            ));
        }
        insert srList;

        // WorkOrder 생성 (어제 날짜 기준)
        Date yesterday = Date.today().addDays(-1);  // 3/12
        Integer monthInt = yesterday.month();   // 3
        Integer dayInt = yesterday.day();   // 12
        List<WorkOrder> woList = new List<WorkOrder>();
        for (ServiceTerritory st : stList) {
            woList.add(new WorkOrder(
                Subject = 'Test WO',
                Status = 'New',
                ServiceTerritoryId = st.Id,
                RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'WorkOrder_Domestic' AND SObjectType = 'WorkOrder' LIMIT 1].Id,
                CreatedDate = yesterday
            ));
        }
        insert woList;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        DN_DispatchPlanManagementBatch batch = new DN_DispatchPlanManagementBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }

    @isTest
    static void testBatchExecution_size() {
        List<PendingprocessingReport__c> existingPRs = new List<PendingprocessingReport__c>();
        existingPRs.add(new PendingprocessingReport__c(
            Year__c = String.valueOf(System.today().year()),
            WC__c = '지사0',
            DispatchPlanManagement__c = true,
            Persons__c = 0 
        ));
        insert existingPRs;

        Test.startTest();
        DN_DispatchPlanManagementBatch batch = new DN_DispatchPlanManagementBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }

    @isTest
    static void testScheduledExecution() {
        Test.startTest();
        String jobId = System.schedule('Test Schedule', '0 0 12 * * ?', new DN_DispatchPlanManagementBatch());
        Test.stopTest();
    }
}