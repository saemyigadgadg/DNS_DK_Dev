/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 04-16-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class ServiceReportTriggerTest {
    
    // @TestSetup
    // static void makeData(){

    //     String profileId = UserInfo.getProfileId();

    //     Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

    //     User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

    //     User user;
    //     System.runAs(thisUser) {
    //         user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
    //         insert user;
    //     }

    //     Country__c country = TestDataFactoryForService.createKRCountry();
    //     insert country;

    //     List<OperatingHours> testHours = TestDataFactoryForService.createOperatingHours();
    //     insert testHours;
    //     System.runAs(user) {
    //         TriggerHandler.bypass('ServiceAppointmentTriggerHandler');
    //         TriggerHandler.bypass('TicketTriggerHandler');
    //         TriggerHandler.bypass('WorkOrderTriggerHandler');
    //         List<ServiceTerritory> stList = TestDataFactoryForService.createTerritory();
    //         stList[0].WCCode__c = '';
    //         stList[0].AvailableServiceResource__c = 0;
    //         stList[1].WCCode__c = '1244842';
    //         stList[1].AvailableServiceResource__c = 0;
    //         insert stList;
    
    //         User testUser = [SELECT Id FROM User WHERE LastName = 'testuser' LIMIT 1];
    
    //         List<ServiceResource> insertSRList = new List<ServiceResource>();
    //         ServiceResource sr = TestDataFactoryForService.createResource(stList[1].Id);
    //         sr.RelatedRecordId = thisUser.Id;
    //         sr.StaffNumber__c = '6527';
    //         sr.LastKnownLatitude = 37.557718278300890;
    //         sr.LastKnownLongitude = 126.974039677136940;
    //         insertSRList.add(sr);
    
    //         ServiceResource sr2 = TestDataFactoryForService.createResource(stList[0].Id);
    //         sr2.RelatedRecordId = testUser.Id;
    //         sr2.StaffNumber__c = '6482';
    //         sr2.LastKnownLatitude = 37.557718278300890;
    //         sr2.LastKnownLongitude = 126.974039677136940;
    //         sr2.CurrentStatus__c = 'Work';
    //         insertSRList.add(sr2);
    //         insert insertSRList;
    
    //         List<Account> insertAccountList = new List<Account>();
    //         Account dealerAcc = TestDataFactoryForService.createAccount('Dealer', 'Test Dealer', country);
    //         dealerAcc.CustomerCode__c = '1311191';
    //         insertAccountList.add(dealerAcc);
    //         Account shipToAcc = TestDataFactoryForService.createAccount('ShipToParty', 'Test Account', country);
    //         shipToAcc.CustomerCode__c = '1237758';
    //         insertAccountList.add(shipToAcc);
    //         insert insertAccountList;
    
    //         Asset testAsset = TestDataFactoryForService.createAsset(shipToAcc.Id);
    //         testAsset.Name           = 'MH0015-000307';
    //         testAsset.SerialNumber   = 'MH0015-000307';
    //         testAsset.ConstrYrMth__c = '2025/03';
    //         insert testAsset;
    
    //         Contact con = TestDataFactoryForService.createContact('CSCustomer', shipToAcc.Id);
    //         insert con;
    
    //         List<FailureArea_Major__c > majorList = TestDataFactoryForService.createFailureAreaMajor();
    //         insert majorList;
    //         List<FailureAreaMiddle__c > middleList = TestDataFactoryForService.createFailureAreaMiddle();
    //         insert middleList;
    //         List<FailurePhenomenon__c > phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
    //         insert phenomenonList;

    //         Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
    //         technicalTicket.RepairRequestDateTime__c = Datetime.now();
    //         insert technicalTicket;
            
    //         WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', stList[1].Id, sr.Id);
    //         wo.PMActivityType__c = 'CS02';
    //         insert wo;

    //         ServiceAppointment sa = new ServiceAppointment();
    //         sa.ParentRecordId = wo.Id;
    //         sa.EarliestStartTime = DateTime.now();
    //         sa.DueDate = DateTime.now();
    //         sa.WorkerType__c = 'Service Resource (Main)';
    //         insert sa;

    //         ServiceReportLayout srl = new ServiceReportLayout();
    //         // srl.MasterLabel = 'Standard Template';
    //         // srl.Language = 'en_US';
    //         // srl.TemplateType = 'ServiceReport';
    //         insert srl;
    //         TriggerHandler.clearAllBypasses();

    //     }
    // }
    // @isTest(seeAll
    @isTest
    public static void testServiceReport(){

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

    }

    // @isTest
    // static void testServiceReportTrigger_InsertAndUpdate() {
    //     WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
    //     ServiceAppointment sa = [SELECT Id FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1];
    //     List<ServiceReportLayout> srlList = [SELECT Id FROM ServiceReportLayout LIMIT 1];
    
    //     Test.startTest();
    
    //     Test.setMock(HttpCalloutMock.class, new ServiceReportTriggerHandlerMock());
    
    //     ServiceReport sr = new ServiceReport();
    //     sr.ParentId = sa.Id;
    //     sr.Template = srlList[0].Id;
    //     sr.CurrencyIsoCode = 'USD';
    //     insert sr;
    
    //     sr.CurrencyIsoCode = 'KRW';
    //     update sr;
    
    //     Test.stopTest();
    // }
    
}