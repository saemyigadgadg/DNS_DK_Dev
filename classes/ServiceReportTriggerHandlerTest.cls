/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-12-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class ServiceReportTriggerHandlerTest {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }  

    @isTest
    public static void testOnInsert_ValidCase() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        User testUser = createTestUser('1846');
        System.runAs(testUser) {
        Account a = new Account(Name = 'testAccountSA',
            BillingPostalCode = '83059',
            BillingCountry = 'Deutschland'
        );
        insert a; 

        Case cas = new Case (AccountId = a.Id,
            STATUS = 'New',
            Origin = 'Homepage'
        );
        insert cas;

        WorkOrder WO = new WorkOrder (
            AccountId = a.Id,
            PMActivityType__c = 'CS02',
            CaseId = cas.Id
        );

        insert WO;

        system.debug('WO : ' + WO);

        Profile p =[
            SELECT ID 
            FROM Profile 
            WHERE Name = 'System Administrator' OR Name = '시스템 관리자'
        ];

        User u = new User(
            Alias = 'standt1',Country='United Kingdom',
            Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', 
            LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
            ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', 
            UserName='demoTest05461@andomdemodomain.com'
        );
        insert u;

        String dnsaRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ServiceAppointment_DNSA').getRecordTypeId();
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        ServiceAppointment SA = new ServiceAppointment (
            ParentRecordId = WO.Id,
            WorkerType__c = 'Service Resource (Main)',
            ownerId = u.Id
        );
        saList.add(sa);
        ServiceAppointment DnsaSa = new ServiceAppointment (
            ParentRecordId = WO.Id,
            RecordTypeId = dnsaRecordTypeId,
            WorkerType__c = 'Service Resource (Main)',
            ownerId = u.Id
        );
        saList.add(DnsaSa);
        insert saList;

        

        system.debug('SA : ' + SA);
        ServiceReport sr1 = new ServiceReport();
        sr1.DocumentBody = Blob.valueOf('Test Content') ; 
        sr1.DocumentContentType ='application/pdf';
        sr1.DocumentName='Test';
        sr1.ParentId = WO.Id ; 
        insert sr1;
        ServiceReport sr = new ServiceReport();
        sr.DocumentBody = Blob.valueOf('Test Content') ; 
        sr.DocumentContentType ='application/pdf';
        sr.DocumentName='Test';
        sr.ParentId = SA.Id ; 

        Test.startTest();
        insert sr;
        Test.stopTest();
        }
    }

    @isTest
    public static void testOnInsert_InvalidWorkerType() {
        User testUser = createTestUser('1846');
        System.runAs(testUser) {
            WorkOrder wo = new WorkOrder(Subject = 'Test', Status = 'New', PMActivityType__c = 'CS02');
            insert wo;

            ServiceAppointment sa = new ServiceAppointment(
                ParentRecordId = wo.Id,
                WorkerType__c = 'Service Resource (Sub)'
            );
            insert sa;

            ServiceReport sr = new ServiceReport(
                ParentId = sa.Id,
                Template = '0SLF70000004IHD'
            );

            Test.startTest();
            try {
                insert sr;
                System.assert(false, 'Should have thrown an error');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Worker Type이 "Service Resource (Main)"이 아니므로'));
            }
            Test.stopTest();
        }
    }
    @isTest
    public static void testOnInsert_InvalidPMType() {
        User testUser = createTestUser('1846');
        System.runAs(testUser) {
            WorkOrder wo = new WorkOrder(Subject = 'Test', Status = 'New', PMActivityType__c = 'CS01');
            insert wo;
            Id dnsaRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ServiceAppointment_DNSA' LIMIT 1].Id;
            List<ServiceAppointment> saList = new List<ServiceAppointment>();
            ServiceAppointment sa = new ServiceAppointment(
                ParentRecordId = wo.Id,
                WorkerType__c = 'Service Resource (Main)'
            );
            saList.add(sa);
            ServiceAppointment dnsaSa = new ServiceAppointment(
                ParentRecordId = wo.Id,
                RecordTypeId = dnsaRecTypeId,
                WorkerType__c = 'Service Resource (Main)'
            );
            saList.add(dnsaSa);
            insert saList;

            ServiceReport sr = new ServiceReport(
                ParentId = sa.Id,
                Template = '0SLF70000004IHD'
            );

            Test.startTest();
            try {
                insert sr;
                System.assert(false, 'Should have thrown error');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('CS02 유형의 Order Type만'));
            }
            Test.stopTest();
        }
    }
    @isTest
    public static void testOnInsert_DuplicateReport() {
        User testUser = createTestUser('1846');
        System.runAs(testUser) {
            Account a = new Account(Name = 'testAccountSA',
                BillingPostalCode = '83059',
                BillingCountry = 'Deutschland'
            );
            insert a; 

            Case cas = new Case (AccountId = a.Id,
                STATUS = 'New',
                Origin = 'Homepage'
            );
            insert cas;

            WorkOrder WO = new WorkOrder (
                AccountId = a.Id,
                PMActivityType__c = 'CS02',
                CaseId = cas.Id
            );

            insert WO;

            system.debug('WO : ' + WO);

            Profile p =[
                SELECT ID 
                FROM Profile 
                WHERE Name = 'System Administrator' OR Name = '시스템 관리자'
            ];

            User u = new User(
                Alias = 'standt1',Country='United Kingdom',
                Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', 
                LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', 
                UserName='demoTest05461@andomdemodomain.com'
            );
            insert u;

            ServiceAppointment SA = new ServiceAppointment (
                ParentRecordId = WO.Id,
                WorkerType__c = 'Service Resource (Main)',
                ownerId = u.Id
            );
            insert SA;

            ServiceReport existing = new ServiceReport(
                DocumentBody = Blob.valueOf('Test Content'),
                DocumentContentType ='application/pdf',
                DocumentName='Test',
                ParentId = SA.Id 
            );
            insert existing;

            ServiceReport newReport = new ServiceReport(
                DocumentBody = Blob.valueOf('Test Content'),
                DocumentContentType ='application/pdf',
                DocumentName='Test',
                ParentId = SA.Id 
            );

            Test.startTest();
            try {
                insert newReport;
                System.assert(false, 'Should have thrown error');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('이미 해당 ServiceAppointment에 관련된'));
            }
            Test.stopTest();
        }
    }
    @isTest
    public static void testOnDelete_RemovesCustomObject() {
        User testUser = createTestUser('1846');
        System.runAs(testUser) {
            Account a = new Account(Name = 'testAccountSA',
                BillingPostalCode = '83059',
                BillingCountry = 'Deutschland'
            );
            insert a; 

            Case cas = new Case (AccountId = a.Id,
                STATUS = 'New',
                Origin = 'Homepage'
            );
            insert cas;

            WorkOrder WO = new WorkOrder (
                AccountId = a.Id,
                PMActivityType__c = 'CS02',
                CaseId = cas.Id
            );

            insert WO;

            system.debug('WO : ' + WO);

            Profile p =[
                SELECT ID 
                FROM Profile 
                WHERE Name = 'System Administrator' OR Name = '시스템 관리자'
            ];

            User u = new User(
                Alias = 'standt1',Country='United Kingdom',
                Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', 
                LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', 
                UserName='demoTest05461@andomdemodomain.com'
            );
            insert u;

            ServiceAppointment SA = new ServiceAppointment (
                ParentRecordId = WO.Id,
                WorkerType__c = 'Service Resource (Main)',
                ownerId = u.Id
            );
            insert SA;

            system.debug('SA : ' + SA);
            ServiceReport sr = new ServiceReport();
            sr.DocumentBody = Blob.valueOf('Test Content') ; 
            sr.DocumentContentType ='application/pdf';
            sr.DocumentName='Test';
            sr.ParentId = SA.Id ; 
            insert sr ;

            // ServiceReport__c srCustom = new ServiceReport__c(
            //     ServiceAppointment__c = SA.Id,
            //     ServiceReportNo__c = sr.ServiceReportNumber
            // );
            // insert srCustom;

            Test.startTest();
            delete sr;
            Test.stopTest();

            // System.assertEquals(0,
            //     [SELECT Id FROM ServiceReport__c WHERE ServiceReportNo__c = :sr.ServiceReportNumber],
            //     'Custom report should be deleted');
        }
    }

        @isTest 
        public static void testUpdateOrdertReport() {
            Account a = new Account(Name = 'testAccountSA',
                BillingPostalCode = '83059',
                BillingCountry = 'Deutschland'
            );
            insert a; 

            Case cas = new Case (AccountId = a.Id,
                STATUS = 'New',
                Origin = 'Homepage'
            );
            insert cas;

            WorkOrder WO = new WorkOrder (
                AccountId = a.Id,
                PMActivityType__c = 'CS02',
                CaseId = cas.Id
            );

            insert WO;

            system.debug('WO : ' + WO);

            Profile p =[
                SELECT ID 
                FROM Profile 
                WHERE Name = 'System Administrator' OR Name = '시스템 관리자'
            ];

            User u = new User(
                Alias = 'standt1',Country='United Kingdom',
                Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', 
                LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', 
                UserName='demoTest05461@andomdemodomain.com'
            );
            insert u;

            ServiceAppointment SA = new ServiceAppointment (
                ParentRecordId = WO.Id,
                WorkerType__c = 'Service Resource (Main)',
                ownerId = u.Id
            );
            insert SA;

        // ServiceReport oldReport = new ServiceReport(
        //     CreatedById = UserInfo.getUserId(),
        //     CreatedDate = DateTime.now().addDays(-5),
        //     DocumentBody = Blob.valueOf('Test Content'),
        //     DocumentContentType ='application/pdf',
        //     DocumentName='OLD REPORT',
        //     ParentId = SA.Id
        // );
        // insert oldReport;

        ServiceReport newReport = new ServiceReport(
            CreatedById = UserInfo.getUserId(),
            CreatedDate = DateTime.now(),
            DocumentBody = Blob.valueOf('Test Content'),
            DocumentContentType ='application/pdf',
            DocumentName='NEW REPORT',
            ParentId = SA.Id
        );
        insert newReport;

        Test.startTest();
        ServiceReportTriggerHandler.updateOrdertReport(WO.Id, newReport);
        Test.stopTest();

    }

    @isTest 
    public static void testOnBeforeDeleteCascadesCustomReport() {
        Account a = new Account(Name = 'testAccountSA',
            BillingPostalCode = '83059',
            BillingCountry = 'Deutschland'
        );
        insert a; 

        Case cas = new Case (AccountId = a.Id,
            STATUS = 'New',
            Origin = 'Homepage'
        );
        insert cas;

        WorkOrder WO = new WorkOrder (
            AccountId = a.Id,
            PMActivityType__c = 'CS02',
            CaseId = cas.Id
        );

        insert WO;

        system.debug('WO : ' + WO);

        Profile p =[
            SELECT ID 
            FROM Profile 
            WHERE Name = 'System Administrator' OR Name = '시스템 관리자'
        ];

        User u = new User(
            Alias = 'standt1',Country='United Kingdom',
            Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', 
            LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',
            ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', 
            UserName='demoTest05461@andomdemodomain.com'
        );
        insert u;

        ServiceAppointment SA = new ServiceAppointment (
            ParentRecordId = WO.Id,
            WorkerType__c = 'Service Resource (Main)',
            ownerId = u.Id
        );
        insert SA;

        system.debug('SA : ' + SA);
        ServiceReport sr = new ServiceReport();
        sr.DocumentBody = Blob.valueOf('Test Content') ; 
        sr.DocumentContentType ='application/pdf';
        sr.DocumentName='Test';
        sr.ParentId = SA.Id ; 
        insert sr ;

        sr = [SELECT Id, ServiceReportNumber FROM ServiceReport WHERE Id = :sr.Id];

        // ServiceReport__c customSR = new ServiceReport__c(
        //     ServiceReportNo__c = sr.ServiceReportNumber
        // );
        // insert customSR;

        Test.startTest();
        delete sr;
        Test.stopTest();

        // List<ServiceReport__c> remaining = [
        //     SELECT Id FROM ServiceReport__c WHERE ServiceReportNo__c = :sr.ServiceReportNumber
        // ];
    }

    private static User createTestUser(String salesOrg) {
        String profileId = UserInfo.getProfileId();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];
        User u = new User(
            SalesOrganization__c = salesOrg,
            ProfileId = profile.Id,
            // UserRoleId = role.Id,

            Username               = 'test001@gmail.com' + System.currentTimeMillis(),
            LastName               = 'testuser',
            Phone                  = '01012345678',
            CompanyName            = 'DN Solutions',
            Email                  = 'yeongdeok.s@dncompany.com',
            Alias                  = 'testuser',
            IsActive               = true,
            TimeZoneSidKey         = 'Asia/Seoul',
            LocaleSidKey           = 'ko_KR',
            LanguageLocaleKey      = 'ko',
            EmailEncodingKey       = 'UTF-8',
            SalesDistrict__c       = 'A1KR',
            DistributionChannel__c = '10',
            Division__c            = '40'
        );
        insert u;

        return u;
    }
}