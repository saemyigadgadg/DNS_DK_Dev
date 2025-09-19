/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-10-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public class DN_PendingProcessReportBatchTest {

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

        List<ServiceAppointment> saList = new List<ServiceAppointment>();

        // 다양한 날짜 조건을 만족하는 테스트 데이터 생성
        List<Integer> daysAgoList = new List<Integer>{2, 7, 15, 30};
        List<String> categories = new List<String>{'Parts', 'Closing', 'Customer', 'Person', 'ETC', 'Installation'};

        for (String cat : categories) {
            for (Integer daysAgo : daysAgoList) {
                saList.add(new ServiceAppointment(
                    ParentRecordId = wo.Id,
                    Status = 'Assigned',
                    Pendingprocessing__c = cat,
                    CreatedDate = System.today().addDays(-daysAgo),
                    LastModifiedDate = System.now().addDays(-daysAgo)
                    // CaseId = cs.Id,
                    // AssetId = asset.Id
                ));
            }
        }

        insert saList;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        DN_PendingProcessReportBatch batch = new DN_PendingProcessReportBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // 결과 검증
        List<PendingprocessingReport__c> reports = [
            SELECT Name, Division__c, ALLTotal__c, PartsTotal__c, ClosingTotal__c, CustomerTotal__c,
                   PersonTotal__c, ETCTotal__c, InstallationTotal__c, TechnicalTotal__c
            FROM PendingprocessingReport__c
        ];

        for (PendingprocessingReport__c rpt : reports) {
            System.debug('보고서: ' + rpt.Division__c);
        }
    }

    @isTest
    static void testSchedulable() {
        Test.startTest();
        String jobId = System.schedule('Test Scheduled Job', '0 0 23 * * ?', new DN_PendingProcessReportBatch());
        Test.stopTest();
    }
}