/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-04-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public class DN_IndirectReceptionControllerTest {

    @testSetup
    static void setupTestData() {
        // 프로파일 생성
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];


        // DNS 사용자 생성 (SalesOrg: 4130)
        // User dnsUser = new User(
        //     Username = 'dnsuser@test.com',
        //     Alias = 'dns',
        //     Email = 'dnsuser@test.com',
        //     EmailEncodingKey = 'UTF-8',
        //     LanguageLocaleKey = 'en_US',
        //     LocaleSidKey = 'en_US',
        //     TimeZoneSidKey = 'Asia/Seoul',
        //     LastName = 'Test DNS',
        //     ProfileId = testProfile,
        //     SalesOrganization__c = '1800'
        // );
        // insert dnsUser;

        // DNSA 사용자 생성 (SalesOrg: 4140)
        // User dnsaUser = new User(
        //     Username = 'dnsauser@test.com',
        //     Alias = 'dnsa',
        //     Email = 'dnsauser@test.com',
        //     EmailEncodingKey = 'UTF-8',
        //     LanguageLocaleKey = 'en_US',
        //     LocaleSidKey = 'en_US',
        //     TimeZoneSidKey = 'Asia/Seoul',
        //     ProfileId = testProfile,
        //     LastName = 'Test DNSA',
        //     SalesOrganization__c = '4140'
        // );
        // insert dnsaUser;
        // String testProfile = UserInfo.getProfileId();
        // User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
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
        wo.Status = 'Assigned';
        insert wo;

        ServiceAppointment appointment = TestDataFactoryForService.createDNSAppointment(wo, territory.Id, resource.Id, 'Main');
        insert appointment;

        // DNSA RecordType 생성 (임의로 삽입)
        // RecordType rt = new RecordType(
        //     Name = 'Ticket(DNSA)',
        //     SObjectType = 'Case',
        //     DeveloperName = 'Ticket_DNSA',
        //     IsActive = true
        // );
        // insert rt;
    }

    static User getUserBySalesOrg(String salesOrg) {
        return [SELECT Id FROM User WHERE SalesOrganization__c = :salesOrg LIMIT 1];
    }

    @isTest
    static void testCreateTicket_DNS_Success() {
        User dnsUser = getUserBySalesOrg('1800');
        System.runAs(dnsUser) {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Asset asset = [SELECT Id FROM Asset LIMIT 1];

            String result = DN_IndirectReceptionController.createTicket(
                acc.Id,
                con.Id,
                asset.Id,
                'Dispatch',
                'Complete',
                'Test DNS 접수',
                System.now()
            );
        }
    }

    @isTest
    static void testCreateTicket_DNS_NotComplete() {
        User dnsUser = getUserBySalesOrg('1800');
        System.runAs(dnsUser) {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Asset asset = [SELECT Id FROM Asset LIMIT 1];

            String result = DN_IndirectReceptionController.createTicket(
                acc.Id,
                con.Id,
                asset.Id,
                'Dispatch',
                'Not Complete',
                'Test DNS 접수',
                System.now()
            );
        }
    }

    @isTest
    static void testCreateTicket_DNS_NotDispatch() {
        User dnsUser = getUserBySalesOrg('1800');
        System.runAs(dnsUser) {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            Asset asset = [SELECT Id FROM Asset LIMIT 1];

            String result = DN_IndirectReceptionController.createTicket(
                acc.Id,
                con.Id,
                asset.Id,
                'Not Dispatch',
                'Not Complete',
                'Test DNS 접수',
                System.now()
            );
        }
    }

    // @isTest
    // static void testCreateTicket_DNSA_Success() {
    //     User dnsaUser = getUserBySalesOrg('4140');
    //     System.runAs(dnsaUser) {
    //         User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
    //         // Account acc = [SELECT Id FROM Account LIMIT 1];
    //         // Contact con = [SELECT Id FROM Contact LIMIT 1];
    //         // Asset asset = [SELECT Id FROM Asset LIMIT 1];

    //         String result = DN_IndirectReceptionController.createTicket(
    //             user1.Id,
    //             user1.Id,
    //             user1.Id,
    //             'Dispatch',
    //             'Not Complete',
    //             'Test DNSA 접수',
    //             null
    //         );

    //         List<Case> caseList = [SELECT Id, RecordTypeId FROM Case LIMIT 1];
    //         // List<Case> caseList = [SELECT Id, RecordTypeId FROM Case WHERE ReceptionDetails__c LIKE '%Test DNSA%' LIMIT 1];
    //     }
    // }

    // @isTest
    // static void testCreateTicket_AccountMismatch_DNS() {
    //     User dnsUser = getUserBySalesOrg('1800');
    //     System.runAs(dnsUser) {
    //         Account acc1 = [SELECT Id FROM Account WHERE RecordType.Name = 'TradeCustomer' LIMIT 1];
    //         Asset asset = [SELECT Id FROM Asset LIMIT 1];

    //         // 다른 계정으로 테스트
    //         Account acc2 = new Account(Name = 'TEST Company');
    //         insert acc2;

    //         Contact con = [SELECT Id FROM Contact LIMIT 1];

    //         String result = DN_IndirectReceptionController.createTicket(
    //             acc2.Id, // 잘못된 AccountId
    //             con.Id,
    //             asset.Id,
    //             'Dispatch',
    //             'Complete',
    //             'Account mismatch test',
    //             null
    //         );
    //     }
    // }

    // @isTest
    // static void testCreateTicket_AccountMismatch_DNSA() {
    //     User dnsaUser = getUserBySalesOrg('4140');
    //     System.runAs(dnsaUser) {
    //     User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
    //         // Account acc1 = [SELECT Id FROM Account WHERE RecordType.Name = 'DNSA Customer' LIMIT 1];
    //         // Asset asset = [SELECT Id FROM Asset LIMIT 1];

    //         // Account wrongAccount = new Account(Name = 'TEST Company');
    //         // insert wrongAccount;

    //         Contact con = [SELECT Id FROM Contact LIMIT 1];

    //         String result = DN_IndirectReceptionController.createTicket(
    //             user1.Id,
    //             user1.Id,
    //             user1.Id,
    //             'Dispatch',
    //             'Not Complete',
    //             'DNSA account mismatch',
    //             null
    //         );
    //     }
    // }

    @isTest
    static void testCreateTicket_NullAsset() {
        User dnsUser = getUserBySalesOrg('1800');
        System.runAs(dnsUser) {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Contact con = [SELECT Id FROM Contact LIMIT 1];

            String result = DN_IndirectReceptionController.createTicket(
                acc.Id,
                con.Id,
                null,
                'Not Dispatch',
                'Complete',
                'Null asset test',
                System.now()
            );
        }
    }
}