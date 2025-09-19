/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 2025-04-29
 * @last modified by  : chungwoo.lee@sobetec.com
**/
@isTest
public with sharing class DN_PortalServiceReportController_TEST {

    /*********************
     * TestSetup 데이터
     *********************/
    private static final Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
    private static final Id dealerRT        = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id conDealerRT     = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    @TestSetup
    static void makeData() {
        RecordType ticketCaseRT = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');
        RecordType ticketCaseDNSART = TestDataFactoryForSales.getRecordType('Ticket_DNSA', 'Case');
        RecordType productPartRT = TestDataFactoryForSales.getRecordType('Part', 'Product2');

        Datetime now = Date.today();
        Datetime oneMonthAgo = now.addMonths(-1);
        Datetime oneYearLater = now.addYears(1);
        String today = now.format('yyyy-MM-dd');
        String convertByOneMonthAgo = oneMonthAgo.format('yyyy-MM-dd');
        String convertByOneYearLater = oneYearLater.format('yyyy-MM-dd');

        Integer currentYear = Date.today().year();
        
        insert new AlertManager__c(Name = 'CS StandardMH Request Noti', CurrencyIsoCode = 'KRW', Description__c = '', IsActive__c = true, Part__c = 'Partner');

        // 시스템 어드민 계정 생성 후 Work Cneter생성을 위한 Dealer Account 생성하고 Admin 계정 Owner로 매핑
        // Profile.Name == 'System Administrator' || Profile.Name == '시스템 관리자'
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];

        User adminUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            UserRole adminUserRole = new UserRole(Name = 'Admin Role');
            insert adminUserRole;
            
            adminUser = new User(FirstName='Admin', LastName='portalTest', Email='portalTest3@portalTest3.com', Username='portalTest3@portalTest3.com', Alias='poTest', TimeZoneSidKey='Asia/Seoul', LocaleSidKey='ko', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=adminProfile.Id, UserRoleId=adminUserRole.Id); 
            insert adminUser;
        }

        Country__c krCountry = TestDataFactoryForSales.createKRCountry();
        Country__c usCountry = TestDataFactoryForSales.createCountry('USA', 'USD', 'US');
        insert new List<Country__c>{krCountry, usCountry};

        Region__c krRegion = TestDataFactoryForSales.createRegion('제주도', 'KRW', '01', krCountry.Id);
        Region__c usRegion = TestDataFactoryForSales.createRegion('California', 'USD', 'CA', usCountry.Id);
        insert new List<Region__c>{krRegion, usRegion};

        Account accountDNS = TestDataFactoryForSales.createAccount('Dealer', krCountry, null);
        Account accountDNSA = TestDataFactoryForSales.createAccount('Dealer', usCountry, null);
        accountDNS.OwnerId = adminUser.Id;
        accountDNSA.OwnerId = adminUser.Id;

        accountDNSA.Name = 'ExclusiveDealer';
        accountDNSA.Representative__c = 'Exclusive';
        accountDNSA.BusinessNumber__c = '151235341';
        accountDNSA.IsExclusiveDealer__c = true;
        accountDNSA.SalesOrganization__c = '4140';
        accountDNSA.SalesOffice__c = '414A';
        accountDNSA.SalesDistrict__c = 'M3US';
        accountDNSA.DistributionChannel__c = '10';
        accountDNSA.Division__c = '40';
        insert new List<Account>{accountDNS, accountDNSA};

        Contact portalContact = TestDataFactoryForSales.createContact('CS_Field_Service', accountDNS.Id);
        Contact collaboContact = TestDataFactoryForSales.createContact('CS_Field_Service', accountDNS.Id);
        Contact dnsaContact = TestDataFactoryForSales.createContact('CS_Field_Service', accountDNSA.Id);
        dnsaContact.LastName = 'asdas';
        dnsaContact.Email = 'qregrgdf@gmail.com';
        dnsaContact.SalesOrganization__c = '4140';
        dnsaContact.SalesOffice__c = '414A';
        dnsaContact.SalesDistrict__c = 'MP04';
        dnsaContact.DistributionChannel__c = '10';
        dnsaContact.Division__c = '40';
        insert new List<Contact>{portalContact, collaboContact, dnsaContact};

        AssignmentRule__c assignmentRule = new AssignmentRule__c(Name = '기술상담사 순차배정');
        insert assignmentRule;

        Product2 prod = new Product2(Name = 'ESWSL0132', ProductCode = 'ESWSL0132', IsActive = true, CurrencyIsoCode = 'KRW', RecordTypeId = productPartRT.Id, MaterialDetailsEN__c = 'ESWSL0132', MaterialDetailsKO__c = 'ESWSL0132', Plant__c = '184S;414S;1846;4146');
        insert prod;
        
        // Too many SOQL queries 방지
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'TicketTriggerHandler', 'WorkOrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; 
        
        // 포탈 계정 생성 후 포탈 계정으로 접근 가능한 데이터 생성
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'DNS CS Service_Partner' LIMIT 1];
        Profile portalProfileDNSA = [SELECT Id FROM Profile WHERE Name = 'DNSA CS Agency' LIMIT 1];

        User portalUser;
        User collaboUser;
        User portalUserDNSA;
        Campaign testCampaign; // Common Part 에서 해당 레코드 Id값 사용하기 위함
        Campaign heCareCampaign;

        // Admin
        System.runAs(new User(Id = UserInfo.getUserId())) {
            portalUser = new User(FirstName='Test', LastName='PortalUser', Email='portaluser@test.com.PortalServiceReportController', Username='portaluser@test.com.PortalServiceReportController', Alias='puser', TimeZoneSidKey='Asia/Seoul', LocaleSidKey='ko', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=portalProfile.Id, ContactId=portalContact.Id); 
            insert portalUser;
            
            collaboUser = new User(FirstName='collaborator', LastName='collaboUser', Email='collaboUser@test.com', Username='collaboUser@test.com', Alias='puser2', TimeZoneSidKey='Asia/Seoul', LocaleSidKey='ko', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=portalProfile.Id, ContactId=collaboContact.Id); 
            insert collaboUser;
            
            portalUserDNSA = new User(FirstName='portalUserDNSA', LastName='portalUserDNSA', Email='DNSA@test.com', Username='DNSA@test.com', Alias='puser3', TimeZoneSidKey='Asia/Seoul', LocaleSidKey='ko', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=portalProfileDNSA.Id, ContactId=dnsaContact.Id); 
            insert portalUserDNSA;

            testCampaign = new Campaign(Name = 'TEST Campaign', Status = 'Planned', StartDate = Date.valueOf(today), EndDate = Date.valueOf(convertByOneYearLater));
            insert testCampaign;
        }

        // DNS
        System.runAs(portalUser) {
            Account acc = new Account(Name='DNS Account', ResidentRegistrationNumber__c='990811', CountryLookup__c=krCountry.Id, RegionLookup__c=krRegion.Id, RecordTypeId=tradeCustomerRT, BusinessNumber__c='987-65-43210', Representative__c='Rep2', SalesOrganization__c='1800', SalesDistrict__c='A1KR', SalesOffice__c='114E', Division__c='40', DistributionChannel__c='10', CustomerCode__c='1308913', OwnerId=portalUser.Id); 
            insert acc;

            Asset ass = new Asset(Name='ML0006-006231', MachineName__c='LYNX 220A-NT', Material__c='L22ANT-F0TP-0-K30', SerialNumber='ML0006-006231', Status='AVLB', AccountId=acc.Id, SoldTo__c=acc.Id, OwnerId=portalUser.Id, NCType__c='TEST', ObjectType__c = 'CS_MT_PMA', WarrantyStartDateWages__c = Date.newInstance(currentYear, 1, 1), WarrantyEndWages__c = Date.newInstance(currentYear, 12, 31), WarrantyStartDate__c = Date.newInstance(currentYear - 1, 1, 1), WarrantyEnd__c = Date.newInstance(currentYear - 1, 12, 31)); 
            insert ass;
            
            heCareCampaign = new Campaign(Name = 'HE CARE Campaign', Status = 'Planned', RegularServiceType__c = 'HE Care', IsActive =true, StartDate = Date.valueOf(today), EndDate = Date.valueOf(convertByOneYearLater));
            insert heCareCampaign;

            // 서비스 리포트
            insert new Case(TicketType__c='Technical inquiry', InternalTicketType__c='Failure receipt', Status='Uncompleted', RecordTypeId=ticketCaseRT.Id, AssetId=ass.Id, OwnerId=portalUser.Id, isAlarmToCustomer__c=false, AccountShippingAddress__c = 'test address');
            // 설치 검수, 설치시운전
            insert new Case(TicketType__c='Internal request', InternalTicketType__c='Installation request', Status='Uncompleted', RecordTypeId=ticketCaseRT.Id, AssetId=ass.Id, OwnerId=portalUser.Id, isAlarmToCustomer__c=false, AccountShippingAddress__c = 'test address');
            // 기획/순회서비스
            insert new Case(TicketType__c='Internal request', InternalTicketType__c='Service Campaign', Status='Uncompleted', RecordTypeId=ticketCaseRT.Id, AssetId=ass.Id, OwnerId=portalUser.Id, isAlarmToCustomer__c=false, AccountShippingAddress__c = 'test address');

            insert new Model__c(Name = 'Test Model');

            ModelManager__c manager = new ModelManager__c(Name='Test Manager', ModelCode__c='ML0006', Manager__c=adminUser.Id, ModelCategory__c='CS_MT_PMA');
            insert manager;

            insert new FailureArea_Major__c(FailureAreaMajor_Value__c = '4T0', FailureAreaMajor_Label__c = 'Elec._Ctrl', ModelCategory__c = 'CS_MT_PMA');
            insert new Standard_HR__c(FailureArea__c = 'Elec._Ctrl', ModelManager__c = manager.Id, IsActive__c = true, StandardWorkTime__c = 2, StandardWorkForce__c = 2);
        } 

        // DNSA
        System.runAs(portalUserDNSA) {
            Account accDNSA = new Account(Name='DNSA Account', ResidentRegistrationNumber__c='990811', CountryLookup__c=usCountry.Id, RegionLookup__c=usRegion.Id, RecordTypeId=tradeCustomerRT, BusinessNumber__c='987-65-43210', Representative__c='Rep2', SalesOrganization__c='1800', SalesDistrict__c='A1KR', SalesOffice__c='114E', Division__c='40', DistributionChannel__c='10', CustomerCode__c='1308914', OwnerId=portalUserDNSA.Id); 
            insert accDNSA;

            Asset DNSA = new Asset(Name='ML0006-006231', MachineName__c='LYNX 220A-NT', Material__c='L22ANT-F0TP-0-K30', SerialNumber='ML0006-006231', Status='AVLB', AccountId=accDNSA.Id, SoldTo__c=accDNSA.Id, OwnerId=portalUserDNSA.Id, NCType__c='TEST', ObjectType__c = 'CS_MT_PMA', WarrantyStartDateWages__c = Date.newInstance(currentYear, 1, 1), WarrantyEndWages__c = Date.newInstance(currentYear, 12, 31), WarrantyStartDate__c = Date.newInstance(currentYear - 1, 1, 1), WarrantyEnd__c = Date.newInstance(currentYear - 1, 12, 31)); 
            insert DNSA;

            // DNSA 서비스 리포트
            insert new Case(TicketType__c='Technical inquiry', InternalTicketType__c='Failure receipt', Status='Uncompleted', RecordTypeId=ticketCaseDNSART.Id, AssetId=DNSA.Id, OwnerId=portalUserDNSA.Id, isAlarmToCustomer__c=false);
        }
        
        OperatingHours ohForPortal;
        System.runAs(portalUser) { 
            ohForPortal = new OperatingHours(Name = '대한민국 표준 작업 시간', TimeZone = 'Asia/Seoul');
            insert ohForPortal;
        }

        ServiceTerritory workCenter;
        System.runAs(portalUser) {
            workCenter = new ServiceTerritory(Name = 'Test WorkCenter', ServiceWorkCenter__c = accountDNS.Id, OperatingHoursId = ohForPortal.Id, IsActive = true, classify__c = 'W/C');
            insert workCenter;
        }

        OperatingHours ohForPortalDNSA;
        System.runAs(portalUserDNSA) { 
            ohForPortalDNSA = new OperatingHours(Name = 'DNSA Operating Hours_Chicago', TimeZone = 'America/Chicago');
            insert ohForPortalDNSA;
        }

        ServiceTerritory workCenterDNSA;
        System.runAs(portalUserDNSA) {
            workCenterDNSA = new ServiceTerritory(Name = 'Test WorkCenter DNSA', ServiceWorkCenter__c = accountDNSA.Id, OperatingHoursId = ohForPortalDNSA.Id, IsActive = true, classify__c = 'W/C');
            insert workCenterDNSA;
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            PermissionSet flsPermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Resource_Permissions' LIMIT 1];
            PermissionSetAssignment psaResource = new PermissionSetAssignment(AssigneeId = portalUser.Id, PermissionSetId = flsPermissionSetId.id);
            insert psaResource;

            PermissionSetAssignment psaResource2 = new PermissionSetAssignment(AssigneeId = collaboUser.Id, PermissionSetId = flsPermissionSetId.id);
            insert psaResource2;

            PermissionSetAssignment psaResourceDNSA = new PermissionSetAssignment(AssigneeId = portalUserDNSA.Id, PermissionSetId = flsPermissionSetId.id);
            insert psaResourceDNSA;
        }        

        ServiceResource worker;
        ServiceResource worker2;
        ServiceResource workerDNSA;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            worker = new ServiceResource(Name = 'Partner Worker', CurrentStatus__c = 'Wait', RelatedRecordId = portalUser.Id, IsActive = true, Service_Territory__c = workCenter.Id, Branch__c = 'DNS');
            insert worker;

            worker2 = new ServiceResource(Name = 'Partner Worker2', CurrentStatus__c = 'Wait', RelatedRecordId = collaboUser.Id, StaffNumber__c = '6527', IsActive = true, Service_Territory__c = workCenter.Id, Branch__c = 'DNS');
            insert worker2;

            workerDNSA = new ServiceResource(Name = 'DNSA Worker', CurrentStatus__c = 'Wait', RelatedRecordId = portalUserDNSA.Id, IsActive = true, Service_Territory__c = workCenter.Id, Branch__c = 'DNSA');
            insert workerDNSA;
        }
        
        WorkOrder woWithPR; // 서비스 리포트 (201) *Product Request 레코드 있는 유형
        WorkOrder paidWorkOrder; // 자체 유상 서비스 오더 HasWarrantyDirectManagement__c = TRUE
        WorkOrder inspectionWorkOrder; // 설치검수 (809)
        WorkOrder trialrunWorkOrder; // 설치시운전 (104)
        WorkOrder campaignWorkOrder; // 기획/순회서비스 (106)
        
        System.runAs(portalUser) {
            Account accDNS      = [SELECT Id FROM Account WHERE Name='DNS Account' LIMIT 1];
            Asset assetForUser  = [SELECT Id FROM Asset WHERE Name = 'ML0006-006231' LIMIT 1];
            ServiceResource sr  = [SELECT Id FROM ServiceResource WHERE Id =:worker.Id LIMIT 1];
            ServiceTerritory wc = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Test WorkCenter' LIMIT 1];

            Case inquiryCase    = [SELECT Id, TicketType__c FROM Case WHERE TicketType__c = 'Technical inquiry' LIMIT 1];
            Case requestCase    = [SELECT Id, TicketType__c FROM Case WHERE TicketType__c = 'Internal request' LIMIT 1];
            Case campaignCase   = [SELECT Id, TicketType__c FROM Case WHERE InternalTicketType__c = 'Service Campaign' LIMIT 1];

            // 서비스 리포트 (201)
            woWithPR = new WorkOrder(CaseId=inquiryCase.Id, AssetId=assetForUser.Id, AccountId=accDNS.Id, SoldTo__c=accDNS.Id, ServiceTerritoryId=wc.Id, Worker__c=sr.Id, TicketType__c='Failure receipt', OrderType__c='201', PMActivityType__c='CS02', Status='New', ServiceOrderNumber__c='403900201', completionTime__c=System.now(), ActualDispatchTime__c=System.now(), ScheduledDispatchTime__c=System.now(), HasWarrantyDirectManagement__c=false, isAlarmToStaff__c=false);
            insert woWithPR;

            // 자체 유상 서비스 리포트 (202)
            paidWorkOrder = new WorkOrder(AssetId=assetForUser.Id, AccountId=accDNS.Id, SoldTo__c=accDNS.Id, ServiceTerritoryId=wc.Id, Worker__c=sr.Id, TicketType__c='Failure receipt', OrderType__c='202', PMActivityType__c='CS02', Status='New', ServiceOrderNumber__c='403900202', completionTime__c=System.now(), ActualDispatchTime__c=System.now(), ScheduledDispatchTime__c=System.now(), HasWarrantyDirectManagement__c=true, isAlarmToStaff__c=false);
            insert paidWorkOrder;

            // 설치검수 (809)
            inspectionWorkOrder = new WorkOrder(CaseId=requestCase.Id, AssetId=assetForUser.Id, AccountId=accDNS.Id, SoldTo__c=accDNS.Id, ServiceTerritoryId=wc.Id, Worker__c=sr.Id, TicketType__c='Installation request', OrderType__c='809', PMActivityType__c='CS08', Status='New', ServiceOrderNumber__c='403900809', completionTime__c=System.now(), ActualDispatchTime__c=System.now(), ScheduledDispatchTime__c=System.now(), HasWarrantyDirectManagement__c=false, isAlarmToStaff__c=false);
            insert inspectionWorkOrder;

            // 설치시운전 (104)
            trialrunWorkOrder = new WorkOrder(CaseId=requestCase.Id, AssetId=assetForUser.Id, AccountId=accDNS.Id, SoldTo__c=accDNS.Id, ServiceTerritoryId=wc.Id, Worker__c=sr.Id, TicketType__c='Installation request', OrderType__c='104', PMActivityType__c='CS01', Status='New', ServiceOrderNumber__c='403900104', completionTime__c=System.now(), ActualDispatchTime__c=System.now(), ScheduledDispatchTime__c=System.now(), HasWarrantyDirectManagement__c=false, isAlarmToStaff__c=false, InstallTestFinish__c = Date.valueOf(convertByOneMonthAgo));
            insert trialrunWorkOrder;

            // 기획/ 순회서비스 (106)
            campaignWorkOrder = new WorkOrder(CaseId=campaignCase.Id, AssetId=assetForUser.Id, AccountId=accDNS.Id, SoldTo__c=accDNS.Id, ServiceTerritoryId=wc.Id, Worker__c=sr.Id, TicketType__c='Service Campaign', OrderType__c='106', PMActivityType__c='CS01', Status='New', ServiceOrderNumber__c='403900106', completionTime__c=System.now(), ActualDispatchTime__c=System.now(), ScheduledDispatchTime__c=System.now(), HasWarrantyDirectManagement__c=false, isAlarmToStaff__c=false);
            insert campaignWorkOrder;
        }

        WorkOrder dnsaWorkOrder; // DNSA 서비스 리포트 (699)

        System.runAs(portalUserDNSA) {
            Account accDNSA     = [SELECT Id FROM Account WHERE Name='DNSA Account' LIMIT 1];
            Asset assetForUser  = [SELECT Id FROM Asset WHERE Name = 'ML0006-006231' LIMIT 1];
            ServiceResource sr  = [SELECT Id FROM ServiceResource WHERE Id =:workerDNSA.Id LIMIT 1];
            ServiceTerritory wc = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Test WorkCenter DNSA' LIMIT 1];

            Case dnsaCase       = [SELECT Id, TicketType__c FROM Case WHERE RecordType.Name = 'Ticket(DNSA)' LIMIT 1];

            // DNSA 서비스 리포트 (699)
            dnsaWorkOrder = new WorkOrder(CaseId=dnsaCase.Id, AssetId=assetForUser.Id, AccountId=accDNSA.Id, SoldTo__c=accDNSA.Id, ServiceTerritoryId=wc.Id, Worker__c=sr.Id, TicketType__c='Failure receipt', OrderType__c='601', PMActivityType__c='HS01', Status='New', ServiceOrderNumber__c='501500601', completionTime__c=System.now(), ActualDispatchTime__c=System.now(), ScheduledDispatchTime__c=System.now(), HasWarrantyDirectManagement__c=false, isAlarmToStaff__c=false);
            insert dnsaWorkOrder;
        }

        Collaborator__c collaborator = new Collaborator__c (WorkOrder__c = woWithPR.Id, ServiceResource__c = worker2.Id);
        insert collaborator;

        // 서비스 리포트 WorkOrderResult 생성
        WorkOrderResult__c worWHType = new WorkOrderResult__c(WorkOrder__c = woWithPR.Id, ResultType__c = 'WH');
        insert worWHType;
        WorkOrderResult__c worSWTType = new WorkOrderResult__c(WorkOrder__c = woWithPR.Id, ResultType__c = 'SWT');
        insert worSWTType;
        WorkOrderResult__c worPTType = new WorkOrderResult__c(WorkOrder__c = woWithPR.Id, ResultType__c = 'PT');
        insert worPTType;

        // 설치시운전 WorkOrderResult 생성
        WorkOrderResult__c worCOMType = new WorkOrderResult__c(WorkOrder__c = trialrunWorkOrder.Id, ResultType__c = 'COM');
        insert worCOMType;
        WorkOrderResult__c worITDType = new WorkOrderResult__c(WorkOrder__c = trialrunWorkOrder.Id, ResultType__c = 'ITD');
        insert worITDType;

        ProductRequest preq = new ProductRequest(WorkOrderId = woWithPR.Id, Product__c = prod.Id, Status = 'Approved', IsDealerPortalDelete__c = false);
        insert preq;

        CommonPart__c commonPart = new CommonPart__c(Campaign__c = testCampaign.Id, Product__c = prod.Id, Quantity__c = 2, Note__c = 'Test');
        insert commonPart;

        insert new LaunchingExcellence__c(Name = 'Test LaunchingExcellence', WorkOrder__c = inspectionWorkOrder.Id, Value__c = '95', FORMID__c = 'SUM');

        ContentVersion cv = new ContentVersion(Title = 'Test File Upload', PathOnClient = 'TestFileList.pdf', VersionData = Blob.valueOf('Test Data'), ERPDocNo__c = '1234567890', DealerPotalFileType__c = 'report');
        insert cv;

        ContentVersion cvWithDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = cvWithDoc.ContentDocumentId, LinkedEntityId = woWithPR.Id, ShareType = 'V', Visibility = 'AllUsers');
        insert cdl;
    }
    
    /*********************
     * getServiceOrderNumber 테스트
     *********************/
    @IsTest
    static void getServiceOrderNumber_TEST() {
        String workOrderId = [SELECT Id FROM WorkOrder WHERE ServiceOrderNumber__c = '403900201' LIMIT 1].Id;
        String res = DN_PortalServiceReportController.getServiceOrderNumber(workOrderId);
    }
    
    /*********************
     * getLoginUserInfo 테스트
     *********************/
    @IsTest
    static void getLoginUserInfo_TEST() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, Object> res = DN_PortalServiceReportController.getLoginUserInfo();
            Test.stopTest();
        }
    }

    /*********************
     * getUpdateScore 테스트
     *********************/
    @IsTest
    static void getUpdateScore_TEST() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];
        String workOrderId = [SELECT Id FROM WorkOrder WHERE ServiceOrderNumber__c = '403900809' LIMIT 1].Id;

        System.runAs(portalUser) {
            Test.startTest();
            Integer res = DN_PortalServiceReportController.getUpdateScore(workOrderId);
            Test.stopTest();
        }
    }

    /*********************
     * searchBeforeCallOut 테스트
     *********************/
    @IsTest
    static void searchBeforeCallOut_TEST() {
        // IF 테스트 레코드 생성
        InterfaceCommonUtil.setInterface('IF-SERVICE-054', 'IF_ERP_Service_Report');
        // IF Mock 데이터 셋팅
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_Report_Test.IF_SERVICE_054_HttpMock());

        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];
        String serviceOrderNumber = [SELECT Id, ServiceOrderNumber__c FROM WorkOrder WHERE ServiceOrderNumber__c = '403900201' LIMIT 1].ServiceOrderNumber__c;

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, Object> res = DN_PortalServiceReportController.searchBeforeCallOut(serviceOrderNumber);
            Test.stopTest();
        }
    }

    /*********************
     * orderNumberSearch 테스트
     *********************/
    // 서비스 리포트
    @IsTest
    static void orderNumberSearch_TEST() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];
        String serviceOrderNumber201 = [SELECT Id, ServiceOrderNumber__c, FM_WorkOrderResult_Template__c FROM WorkOrder WHERE ServiceOrderNumber__c = '403900201' LIMIT 1].ServiceOrderNumber__c;
        String serviceOrderNumber202 = [SELECT Id, ServiceOrderNumber__c, FM_WorkOrderResult_Template__c FROM WorkOrder WHERE ServiceOrderNumber__c = '403900202' LIMIT 1].ServiceOrderNumber__c;
        String serviceOrderNumber809 = [SELECT Id, ServiceOrderNumber__c FROM WorkOrder WHERE ServiceOrderNumber__c = '403900809' LIMIT 1].ServiceOrderNumber__c;
        String serviceOrderNumber104 = [SELECT Id, ServiceOrderNumber__c FROM WorkOrder WHERE ServiceOrderNumber__c = '403900104' LIMIT 1].ServiceOrderNumber__c;
        String serviceOrderNumber106 = [SELECT Id, ServiceOrderNumber__c FROM WorkOrder WHERE ServiceOrderNumber__c = '403900106' LIMIT 1].ServiceOrderNumber__c;

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, Object> res201 = DN_PortalServiceReportController.orderNumberSearch(serviceOrderNumber201);
            Map<String, Object> res202 = DN_PortalServiceReportController.orderNumberSearch(serviceOrderNumber202);
            Map<String, Object> res809 = DN_PortalServiceReportController.orderNumberSearch(serviceOrderNumber809);
            Map<String, Object> res104 = DN_PortalServiceReportController.orderNumberSearch(serviceOrderNumber104);
            Map<String, Object> res106 = DN_PortalServiceReportController.orderNumberSearch(serviceOrderNumber106);
            Test.stopTest();
        }
    }

    /*********************
     * upsertServiceReport 테스트
     *********************/
    // 서비스 리포트
    @IsTest
    static void upsertServiceReport_TEST() {
        User portalUser = [SELECT Id, Name FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];
        WorkOrder workOrder = [SELECT Id FROM WorkOrder WHERE OrderType__c = '201' LIMIT 1];
        ServiceResource worker = [SELECT Id, Name FROM ServiceResource WHERE RelatedRecordId =:portalUser.Id LIMIT 1];
        Standard_HR__c standardHR = [SELECT Id FROM Standard_HR__c WHERE IsActive__c = true LIMIT 1];
        ProductRequest productReq = [SELECT Id, Product__c, Status FROM ProductRequest WHERE WorkOrderId =:workOrder.Id];

        // JSON 
        Map<String, Object> fieldMap = new Map<String, Object>{
            'workOrderId' => workOrder.Id,
            'siteManager' => '에현장',
            'siteManagerPhone' => '111-1111-1111',
            'mainWorker' => '에현장',
            'mainWorkerPhone' => '111-1111-1111',
            'workOrderResultData' => new Map<Object, Object>{
                'pendingOrCustomerMatters' => 'test',
                'responsibleDepartment' => '0007',
                'selectedBrokenArea' => new Map<Object, Object>{
                    'brokenAreaCode' => '004',
                    'brokenAreaGroup' => '4Q1',
                    'brokenAreaPart' => 'Spindle Head - Tool Cyl.',
                    'failureArea' => 'Spindle Head',
                    'failureAreaDetail' => 'Tool Cyl.',
                    'phenomenonGroup' => '4Q100400'
                },
                'selectedBrokenStatus' => new Map<Object, Object>{
                    'brokenStatusCode' => '0003',
                    'brokenStatusPart' => '가동불능경'
                },
                'selectedCauseArea' => new Map<Object, Object>{
                    'causeAreaCode' => '05',
                    'causeAreaDetail' => 'test',
                    'causeAreaPart' => '서비스 오류 (진단_수리)'
                },
                'selectedPhenomenon' => new Map<Object, Object>{
                    'causeAreaGroup' => '4Q100404',
                    'phenomenonCode' => '04',
                    'phenomenonDetail' => 'test',
                    'phenomenonPart' => '소음_이음_진동'
                },
                'selectedRepairAction' => new Map<Object, Object>{
                    'repairActionCode' => '05',
                    'repairActionPart' => '설치 (Option/후납부품)',
                    'repairActionDetail' => 'test'
                },
                'totalWorkTime' => 0,
                'totalStandardWorkTime' => 2,
                'overWork' => 0,
                'reasonForOrverWork' => ''
            },
            'workList' => new List<Object>{
                new Map<Object, Object>{
                    'checkbox' => false,
                    'worker' => new Map<Object, Object>{
                        'Id' => worker.Id,
                        'Name' => worker.Name
                    },
                    'workDate' => '2025-03-14',
                    'workEndDate' => '',
                    'startTime' => '09:00:00.000',
                    'endTime' => '09:15:00.000',
                    'workHours' => '0.3',
                    'workType' => 'MV',
                    'workContent' => '고객사로 이동',
                    'workTypeLabel' => '이동',
                    'workId' => '',
                    'serviceAppointmentId' => '',
                    'saKey' => 'sa001'
                }
            },
            'standardWorkList' => new List<Object>{
                new Map<Object, Object>{
                    'checkbox' => false,
                    'breakdownPart' => 'Elec._Ctrl',
                    'standardWorkItem' => 'APC Door Limit 스위치 교체',
                    'standardWorkTime' => 2,
                    'standardWorkPeople' => 1,
                    'actualWorkTime' => 5,
                    'actualWorkPeople' => 2,
                    'isChangedStandardWork' => true,
                    'isLeftDisabled' => true,
                    'isNew' => false,
                    'standardHourId' => standardHR.Id
                },
                new Map<Object, Object>{
                    'checkbox' => false,
                    'breakdownPart' => '4Q5',
                    'standardWorkItem' => 'APC 생성',
                    'standardWorkTime' => 0,
                    'standardWorkPeople' => 0,
                    'actualWorkTime' => 4,
                    'actualWorkPeople' => 1,
                    'isChangedStandardWork' => true,
                    'isLeftDisabled' => true,
                    'isNew' => true,
                    'changeRequestReason' => 'new TEST'
                }
            },
            'defectList' => new List<Object>{
                new Map<Object, Object>{
                    'type' => '001',
                    'content' => '초기하자 내용 TEST',
                    'actionTaken' => '초기하자 조치내역 TEST',
                    'remarks' => '초기하자 비고 TEST',
                    'workId' => ''
                }
            },
            'productRequests' => new List<Object>{
                new Map<Object, Object>{
                    'Id' => productReq.Id,
                    'Product__c' => productReq.Product__c,
                    'Quantity__c' => 3,
                    'DeliveryCompleted__c' => 3,
                    'Status' => 'Approved',
                    'IsCause__c' => true,
                    'ShippingCheck__c' => 'N',
                    'ReturnStatus__c' => 'Y',
                    'Product__r' => new Map<Object, Object>{
                        'FM_MaterialDetails__c' => 'ESWSL0132',
                        'ProductCode' => 'ESWSL0132',
                        'Name' => 'ESWSL0132',
                        'Unit__c' => '',
                        'Id' => productReq.Product__c
                    }
                }
            },
            'deletedWorkList' => new List<Object>(),
            'deletedFileList' => new List<Object>()
        };

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, Object> res = DN_PortalServiceReportController.upsertServiceReport(fieldMap);
            Test.stopTest();
        }
    }

    /*********************
     * callOutServiceOrder 테스트
     *********************/
    // 서비스 리포트
    @IsTest
    static void callOutServiceOrder_106_TEST() {
        // IF 테스트 레코드 생성
        InterfaceCommonUtil.setInterface('IF-CSPLUS-015', 'IF_ERP_WorkOrder');
        InterfaceCommonUtil.setInterface('IF-PARTS-025', 'IF_ERP_DeliveryTraining');
        
        // IF Mock 데이터 셋팅
        Test.setMock(HttpCalloutMock.class, new IF_Combined_HttpMock());

        User portalUser = [SELECT Id, Name FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];
        WorkOrder workOrder106 = [SELECT Id FROM WorkOrder WHERE OrderType__c = '106' LIMIT 1];
        List<Map<String, String>> docMapList = new List<Map<String, String>>();
        List<String> convertVersionIdList = new List<String>();

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, Object> res104 = DN_PortalServiceReportController.callOutServiceOrder(workOrder106.Id, true, docMapList, convertVersionIdList);
            Test.stopTest();
        }
    }

    @IsTest
    static void callOutServiceOrder_104_TEST() {
        // IF 테스트 레코드 생성
        InterfaceCommonUtil.setInterface('IF-CSPLUS-015', 'IF_ERP_WorkOrder');
        InterfaceCommonUtil.setInterface('IF-SERVICE-045', 'IF_ERP_Service_InstAndComm');

        // IF Mock 데이터 셋팅
        Test.setMock(HttpCalloutMock.class, new IF_Combined_HttpMock());

        User portalUser = [SELECT Id, Name FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];
        WorkOrder workOrder104 = [SELECT Id FROM WorkOrder WHERE OrderType__c = '104' LIMIT 1];
        List<Map<String, String>> docMapList = new List<Map<String, String>>();
        List<String> convertVersionIdList = new List<String>();

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, Object> res104 = DN_PortalServiceReportController.callOutServiceOrder(workOrder104.Id, true, docMapList, convertVersionIdList);
            Test.stopTest();
        }
    }

    @IsTest
    static void callOutServiceOrder_201_TEST() {
        // IF 테스트 레코드 생성
        InterfaceCommonUtil.setInterface('IF-SERVICE-054', 'IF_ERP_Service_Report');
        InterfaceCommonUtil.setInterface('IF-SERVICE-046', 'IF_ERP_Service_ServRepInput');

        // IF Mock 데이터 셋팅
        Test.setMock(HttpCalloutMock.class, new IF_Combined_HttpMock());

        User portalUser = [SELECT Id, Name FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];
        WorkOrder workOrder201 = [SELECT Id FROM WorkOrder WHERE OrderType__c = '201' LIMIT 1];
        List<Map<String, String>> docMapList = new List<Map<String, String>>();
        List<String> convertVersionIdList = new List<String>();

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, Object> res201 = DN_PortalServiceReportController.callOutServiceOrder(workOrder201.Id, false, docMapList, convertVersionIdList);
            Test.stopTest();
        }
    }

    // 다중 CallOut을 위해 requestBody에 포함된 특정 문자열에 따라 responseBody String 분기처리 
    public class IF_Combined_HttpMock implements HttpCalloutMock {
        public IF_Combined_HttpMock() {}

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            String endpoint = req.getEndpoint();

            System.debug('req Body ::: ' + JSON.serialize(req.getBody()));

            String resBody = '';

            if (req.getBody().contains('I_AUFNR')) {
                // IF_CSPLUS_015_HttpMock
                resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"보조작업자를 등록하였습니다."}}';
            } else if (req.getBody().contains('I_ORDER')) {
                // IF_SERVICE_054_HttpMock
                resBody = '{"O_AMOUNT":{"TOTAL":"0.00","VAT":"0.00","WAERS":""},"O_AUFNR":"403907829","O_BILL_CATEGORY":"","O_BYRJD":"","O_BYRJM":"","O_BYRJT":"","O_CITY1":"","O_CODE":{"CODE_01":"","CODE_02":"","CODE_03":"","TEXT":"","TEXT2":""},"O_EQART":"","O_HISTORY":{"MANDT":"","QMNUM":"","SEQNO":"","OTGRP":"","OTEIL":"","KURZTEXT":"","FEGRP":"","FECOD":"","TXTCDFE":"","FETXT":"","SYMPTOM_ADD_TXT":"","URGRP":"","URCOD":"","TXTCDUR":"","URTXT":"","CAUSE_ADD_TXT":"","MNGRP":"","MNCOD":"","TXTCDMA":"","MATXT":"","ACT_ADD_TXT":"","FAULT_CAUSE":"","PHENO_ADD_TXT":"","BLCOD":"","BLCOD_T":"","ERDAT":"0000-00-00","ERNAM":"","ERZET":"00:00:00","AEDAT":"0000-00-00","AENAM":"","AEZET":"00:00:00","TXTQM":""},"O_HUMAN_VAL":"","O_ILART":"104","O_INFO":{"MANDT":"","AUFNR":"","AUART":"CS01","ORDER_TYPE_TXT":"Inspection Order","QMNUM":"","ILART":"104","DMACTTYPE_TXT":"Installation & Test-run","QMDAT":"0000-00-00","GSTRP":"2025-01-21","LTRMN":"0000-00-00","QMTXT":"","TXTQM":"","EQUNR":"","MATNR":"GT3100-F0TP-0-K30","TYPBZ":"PUMA GT3100","SERNR":"ML0311-000789","INBDT":"0000-00-00","RBNR":"","IDATE":"0000-00-00","STAND_WE":"","MDOCM":"","KUNNR":"","NAME":"","TELEPHONE":"","REP_NAME":"","TAX_NO_2":"","ABCKZ":"","BEBER":"","CONTACT_TYPE":"","CONTACT_NAME":"","CONTACT_MOBILE":"","CONTACT_TEL":"","PART_PRICE":"0.00","LABOR_PRICE":"0.00","TOT_AMOUNT":"0.00","DISCOUNT_AMT":"0.00","WAERS":"KRW","VBELN":"","ERDAT":"0000-00-00","ERNAM":"","ERZET":"00:00:00","AEDAT":"0000-00-00","AENAM":"","AEZET":"00:00:00","ARBPL":"","WTY_TYPE":"In","NOTIFTIME":"00:00:00","MOBILE":"","LTRUR":"00:00:00","ISMNW":"0.000","ZDIST":"0.000","OTHER_COST":"0.00","ZENGNO":"","USNAM":"","UDATE":"0000-00-00","UTIME":"00:00:00"},"O_LOEKZ":"","O_MANHOUR_REASON":"","O_MANHOUR_USE_YN":"","O_MANHOUR_VAL":"","O_NOT_DELIVERY":"","O_REF_NO":"","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":""},"O_RJXO":"","O_SERIES_NAME":"","O_STATUS":"REL","O_STREET":"","O_TEXT":"","O_TEXT_RJ":"","O_UNIT_NAME":"","O_UNIT_SUB_DESC":"","O_UNIT_SUB_NAME":"","O_USR11":"","O_WORK_ITEM_NAME":"","T_CONSIGN":[],"T_DATA":[],"T_DOC":[],"T_DOC_INFO":[],"T_DOC_SR":[],"T_MATERIAL":[],"T_MOTION":[{"AENAM":"","ISDZ":"00:00:00","ISMNE":"","FLAG_0060":"X","LTXA1":"","SEQNO":"0001","ISMNW_PDK":"0.0","SVCMAN_NAME":"MKRC0067 정경연","ERZET":"13:24:17","AUFNR":"403907829","AEDAT":"0000-00-00","WORKCD":"","AUSBS":"2025-03-12","ERNAM":"","HOL_CHK":"","OT_CHK":"","ISDD":"2025-03-12","EXRSN":"","RUECK":"0137294904","MANDT":"","ISMNW":"0.0","ERDAT":"2025-03-12","RMZHL":"00000000","AUZTB":"00:00:00","PERNR":"00006068","AEZET":"00:00:00","WORKNO":"0000"}],"T_SUB":[],"T_TEXT_A":[{"TDLINE":"딜러포탈테스트20250131001-조치:수정","TDFORMAT":"*"}],"T_TEXT_C":[{"TDLINE":"테스트-고장원인내용입력 12","TDFORMAT":"*"}],"T_TEXT_CR":[],"T_TEXT_D":[{"TDLINE":"테스트-고장현상내용입력 12","TDFORMAT":"*"}],"T_ZCST0061":[],"T_ZCST0062":[]}';
            } else {
                if (req.getBody().contains('"INSPECTION_TP":"106"')) {
                    // IF_PARTS_025_HttpMock
                    resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully saved ![ZCS02081]"},"O_UPD_MSG":"","O_DEL_MSG":"","T_DOC2":[],"T_INSPEC":[],"T_DEL":[],"T_DEL2":[],"T_TMP":[{"FILENAME":"up.txt","FILE_SIZE":"","DESC":"up.txt","LINE":"[B@559f7330","EVISEQX":"01"}],"T_MOTION":[{"AUSBS":"2025-02-06","HOL_CHK":"","CHK_FLAG":"","CONF":"","GRUND":"","ISDZ":"16:30:00","ZFLAG":"","RMZHL":"00000000","ISDD":"2025-02-06","TEMPHR":"","AENAM":"","MANDT":"","MAINHR":"","AEDAT":"0000-00-00","AUZTB":"23:15:00","PERNR":"00006462","OPTCHK5":"","OPTCHK4":"","OPTCHK3":"","OPTCHK2":"","OPTCHK1":"","WERKS":"184S","WORKCD":"MV","AUFNR":"403908121","AEZET":"00:00:00","ERNAM":"","SVCMAN_NAME":"null 민광식","ETC_HR":"0.0","OT_CHK":"","LTXA1":"test","ERDAT":"0000-00-00","ISMNW":"6.8","RUECK":"0000000000","EXRSN":"","HDAYWDV":"","ETC_TXT":"","OPTNHR5":"","OPTNHR4":"","OPTNHR3":"","OPTNHR2":"","OPTNHR1":"","SEQNO":"0000","ERZET":"00:00:00","WORKNO":"0000","ISMNW_PDK":"0.0","ISMNE":"H"}]}';
                
                } else if (req.getBody().contains('"INSPECTION_TP":"104"')) {
                    // IF_SERVICE_045_HttpMock
                    resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully saved ![ZCS02081]"},"O_DEL_MSG":"","O_TIME":"","O_UPD_MSG":"File upload was successful.","T_MOTION":[{"AUSBS":"2025-02-11","HOL_CHK":"","CHK_FLAG":"","CONF":"","GRUND":"","ISDZ":"00:30:00","ZFLAG":"","RMZHL":"00000000","ISDD":"2025-02-11","TEMPHR":"","AENAM":"","MANDT":"","MAINHR":"","AEDAT":"0000-00-00","AUZTB":"07:00:00","PERNR":"00006520","OPTCHK5":"","OPTCHK4":"","OPTCHK3":"","OPTCHK2":"","OPTCHK1":"","WERKS":"","WORKCD":"","AUFNR":"000403908071","AEZET":"00:00:00","ERNAM":"","SVCMAN_NAME":"이재구","ETC_HR":"0.0","OT_CHK":"","LTXA1":"","ERDAT":"0000-00-00","ISMNW":"6.5","RUECK":"0000000000","EXRSN":"","HDAYWDV":"","ETC_TXT":"","OPTNHR5":"","OPTNHR4":"","OPTNHR3":"","OPTNHR2":"","OPTNHR1":"","SEQNO":"0001","ERZET":"00:00:00","WORKNO":"0000","ISMNW_PDK":"0.0","ISMNE":""}],"T_RETURN":[],"T_TMP":[{"FILENAME":"up.txt","FILE_SIZE":"","DESC":"up.txt","LINE":"[B@7904289a","EVISEQX":"01"}],"T_DEL":[]}';
                
                } else if (req.getBody().contains('"ILART":"201"')) {
                    // IF_SERVICE_046_HttpMock
                    resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Confm No(CBO) insert ok[ZCS02034]"},"O_DEL_MSG":"","O_TIME":"X","O_UPD_MSG":"","T_CONSIGN":[],"T_DEL":[],"T_DEL_SR":[],"T_DOC":[],"T_MATERIAL":[],"T_MOTION":[{"AENAM":"","ISDZ":"09:30:00","ISMNE":"","FLAG_0060":"","LTXA1":"고객사이동15분2","SEQNO":"0000","ISMNW_PDK":"0.0","SVCMAN_NAME":"","ERZET":"00:00:00","AUFNR":"403908144","AEDAT":"0000-00-00","WORKCD":"MV","AUSBS":"2025-02-05","ERNAM":"","HOL_CHK":"","OT_CHK":"","ISDD":"2025-02-05","EXRSN":"","RUECK":"0000000000","MANDT":"","ISMNW":"0.3","ERDAT":"0000-00-00","RMZHL":"00000000","AUZTB":"09:45:00","PERNR":"00006527","AEZET":"00:00:00","WORKNO":"0000"},{"AENAM":"","ISDZ":"09:45:00","ISMNE":"","FLAG_0060":"","LTXA1":"진단1시간2","SEQNO":"0000","ISMNW_PDK":"0.0","SVCMAN_NAME":"","ERZET":"00:00:00","AUFNR":"403908144","AEDAT":"0000-00-00","WORKCD":"DN","AUSBS":"2025-02-05","ERNAM":"","HOL_CHK":"","OT_CHK":"","ISDD":"2025-02-05","EXRSN":"","RUECK":"0000000000","MANDT":"","ISMNW":"1.0","ERDAT":"0000-00-00","RMZHL":"00000000","AUZTB":"10:45:00","PERNR":"00006527","AEZET":"00:00:00","WORKNO":"0000"},{"AENAM":"","ISDZ":"10:45:00","ISMNE":"","FLAG_0060":"","LTXA1":"작업1시간2","SEQNO":"0000","ISMNW_PDK":"0.0","SVCMAN_NAME":"","ERZET":"00:00:00","AUFNR":"403908144","AEDAT":"0000-00-00","WORKCD":"WK","AUSBS":"2025-02-05","ERNAM":"","HOL_CHK":"","OT_CHK":"","ISDD":"2025-02-05","EXRSN":"","RUECK":"0000000000","MANDT":"","ISMNW":"1.0","ERDAT":"0000-00-00","RMZHL":"00000000","AUZTB":"11:45:00","PERNR":"00006527","AEZET":"00:00:00","WORKNO":"0000"}],"T_RETURN":[{"CODE":"","MESSAGE":"Contact info update ok ![ZCS02025]","TYPE":"S"},{"CODE":"","MESSAGE":"Notification Same data[ZCS02064]","TYPE":"S"},{"CODE":"","MESSAGE":"Settlement Rule Entry OK ![ZCS02158]","TYPE":"S"},{"CODE":"","MESSAGE":"Confm No(CBO) insert ok[ZCS02034]","TYPE":"S"},{"CODE":"","MESSAGE":"Service Report File upload was successful.","TYPE":"S"}],"T_TMP":[],"T_TMP_SR":[{"FILENAME":"403908144_test.txt","FILE_SIZE":"76","DESC":"403908144_test.txt","LINE":"[B@173590b2","EVISEQX":"01"}]}';
                } else {
                    // 기본 응답을 설정하여 빈 문자열 반환 방지
                    resBody = '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Default response"}}';
                }
            }
            res.setBody(resBody);
            res.setStatusCode(200);
            return res;
        }
    }

    /*********************
     * searchServiceData 테스트
     *********************/
    @IsTest
    static void searchServiceData_TEST() {
        User portalUser = [SELECT Id, Name FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, Object> res = DN_PortalServiceReportController.searchServiceData('LYNX 220A-NT', 'ML0006-006231');
            Test.stopTest();
        }
    }

    /*********************
     * savePaidService 테스트
     *********************/
    // 서비스 리포트
    @IsTest
    static void savePaidService_TEST() {
        User portalUser = [SELECT Id, Name FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];
        ServiceResource worker = [SELECT Id, Name, StaffNumber__c, Service_Territory__c, Service_Territory__r.WCID__c, Service_Territory__r.Name FROM ServiceResource WHERE RelatedRecordId =:portalUser.Id LIMIT 1];
        Product2 product = [SELECT Name, ProductCode FROM Product2 WHERE Name = 'ESWSL0132' LIMIT 1];
        ContentVersion cv  = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test File Upload' LIMIT 1];

        // JSON 
        Map<String, Object> fieldMap = new Map<String, Object>{
            'searchService' => new Map<Object, Object>{
                'accountAddress' => '충청남도 천안시 서북구 직산읍 4산단3로, 33181',
                'accountName' => 'DNS Account',
                'accountTel' => '0000000000',
                'assetName' => 'ML0006-006231',
                'installDate' => '2025-02-05',
                'machineName' => 'LYNX 220A-NT',
                'objectType' => 'CS_MT_PVM',
                'orderType' => '필드서비스 오더',
                'representative' => 'Rep2',
                'warranty' => 'Y / Y',
                'workOrderType' => '유상 Claim'
            },
            'workOrderResultData' => new Map<Object, Object>{
                'selectedBrokenArea' => new Map<Object, Object>{
                    'brokenAreaGroup' => '4R0',
                    'brokenAreaCode' => '001',
                    'failureArea' => 'Elec._Ctrl',
                    'failureAreaDetail' => 'CNC System',
                    'brokenAreaPart' => 'Elec._Ctrl - CNC System',
                    'phenomenonGroup' => '4R0001'
                },
                'selectedPhenomenon' => new Map<Object, Object>{
                    'phenomenonCode' => '01',
                    'phenomenonPart' => '작동 불량',
                    'causeAreaGroup' => '4R000101',
                    'phenomenonDetail' => 'test'
                },
                'selectedCauseArea' => new Map<Object, Object>{
                    'causeAreaCode' => '01',
                    'causeAreaPart' => '설계 이상',
                    'causeAreaDetail' => 'test'
                },
                'selectedRepairAction' => new Map<Object, Object>{
                    'repairActionCode' => '01',
                    'repairActionPart' => '현상/원인 진단',
                    'repairActionDetail' => 'test'
                },
                'selectedBrokenStatus' => new Map<Object, Object>{
                    'brokenStatusCode' => '0001',
                    'brokenStatusPart' => '단순하자'
                }
            },
            'worker' => worker.Id,
            'workCenter' => worker.Service_Territory__c,
            'workList' => new List<Object>{
                new Map<Object, Object>{
                    'checkbox' => false,
                    'worker' => new Map<Object, Object>{
                        'Id' => worker.Id,
                        'Name' => worker.Name
                    },
                    'workDate' => '2025-03-14',
                    'workEndDate' => '',
                    'startTime' => '09:00:00.000',
                    'endTime' => '09:15:00.000',
                    'workHours' => '0.3',
                    'workType' => '',
                    'workContent' => '고객사로 이동',
                    'workTypeLabel' => '이동',
                    'workId' => '',
                    'serviceAppointmentId' => '',
                    'saKey' => 'sa001'
                }
            },
            'usageList' => new List<Object>{
                new Map<Object, Object>{
                    'checkbox' => false,
                    'productCode' => product.ProductCode,
                    'productName' => product.Name,
                    'isCause' => true,
                    'quantity' => 2,
                    'returnNote' => 'test',
                    'productId' => ''
                }
            },
            'defectDate' => '2025-03-24',
            'receiptDate' => '2025-03-24',
            'actionCallDate' => '2025-03-24',
            'fileList' => new List<Object>{
                new Map<Object, Object>{
                    'contentDocumentId' => cv.ContentDocumentId
                }
            }
        };

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, Object> res = DN_PortalServiceReportController.savePaidService(fieldMap);
            Test.stopTest();
        }
    }

    /*********************
     * saveDNSAServiceReport 테스트
     *********************/
    // 서비스 리포트
    @IsTest
    static void saveDNSAServiceReport_TEST() {
        User portalUserDNSA = [SELECT Id, Name FROM User WHERE Username = 'DNSA@test.com' LIMIT 1];
        WorkOrder workOrder = [SELECT Id FROM WorkOrder WHERE OrderType__c = '601' LIMIT 1];
        ServiceResource worker = [SELECT Id, Name FROM ServiceResource WHERE RelatedRecordId =:portalUserDNSA.Id LIMIT 1];

        // JSON 
        Map<String, Object> fieldMap = new Map<String, Object>{
            'workOrderId' => workOrder.Id,
            'serviceReportInfo' => new Map<Object, Object>{
                'accountAddress' => '충청남도 천안시 서북구 직산읍 4산단3로, 33181',
                'accountName' => 'DNS Account',
                'accountTel' => '0000000000',
                'assetName' => 'ML0006-006231',
                'installDate' => '2025-02-05',
                'machineName' => 'LYNX 220A-NT',
                'objectType' => 'CS_MT_PVM',
                'orderType' => '필드서비스 오더',
                'representative' => 'Rep2',
                'warranty' => 'Y / Y',
                'workOrderType' => '유상 Claim',
                'reportType' => 'Non-WRT(N)',
                'repairStartDate' => '2025-03-09',
                'repairEndDate' => '',
                'signatureDate' => '2025-03-09',
                'isMachineDown' => false
            },
            'workOrderResultData' => new Map<Object, Object>{
                'pendingOrCustomerMatters' => 'test',
                'responsibleDepartment' => '0007',
                'selectedBrokenArea' => new Map<Object, Object>{
                    'brokenAreaCode' => '004',
                    'brokenAreaGroup' => '4Q1',
                    'brokenAreaPart' => 'Spindle Head - Tool Cyl.',
                    'failureArea' => 'Spindle Head',
                    'failureAreaDetail' => 'Tool Cyl.',
                    'phenomenonGroup' => '4Q100400'
                },
                'selectedBrokenStatus' => new Map<Object, Object>{
                    'brokenStatusCode' => '0003',
                    'brokenStatusPart' => '가동불능경'
                },
                'selectedCauseArea' => new Map<Object, Object>{
                    'causeAreaCode' => '05',
                    'causeAreaDetail' => 'test',
                    'causeAreaPart' => '서비스 오류 (진단_수리)'
                },
                'selectedPhenomenon' => new Map<Object, Object>{
                    'causeAreaGroup' => '4Q100404',
                    'phenomenonCode' => '04',
                    'phenomenonDetail' => 'test',
                    'phenomenonPart' => '소음_이음_진동'
                },
                'selectedRepairAction' => new Map<Object, Object>{
                    'repairActionCode' => '05',
                    'repairActionPart' => '설치 (Option/후납부품)',
                    'repairActionDetail' => 'test'
                },
                'totalWorkTime' => 0,
                'totalStandardWorkTime' => 2,
                'overWork' => 0,
                'reasonForOrverWork' => ''
            },
            'workList' => new List<Object>{
                new Map<Object, Object>{
                    'checkbox' => false,
                    'worker' => new Map<Object, Object>{
                        'Id' => worker.Id,
                        'Name' => worker.Name
                    },
                    'workDate' => '2025-03-14',
                    'workEndDate' => '',
                    'startTime' => '09:00:00.000',
                    'endTime' => '09:15:00.000',
                    'workHours' => '0.3',
                    'workType' => 'MV',
                    'workContent' => '고객사로 이동',
                    'workTypeLabel' => '이동',
                    'workId' => '',
                    'serviceAppointmentId' => '',
                    'saKey' => 'sa001'
                }
            },
            'deletedWorkList' => new List<Object>(),
            'deletedFileList' => new List<Object>(),
            'usageList' => new List<Object>{
                // new Map<String, Object>{
                //     'productCode' => 'PC001',
                //     'productName' => 'Test Product',
                //     'isCause' => true,
                //     'quantity' => 5,
                //     'returnNote' => 'Test note',
                //     'workId' => 'a1ZJO000000TestId'
                // },
                new Map<Object, Object>{
                    'productCode' => 'PC002',
                    'productName' => 'TEST Product',
                    'isCause' => false,
                    'quantity' => 3,
                    'returnNote' => 'TEST note',
                    'workId' => ''
                }
            }
        };

        System.runAs(portalUserDNSA) {
            Test.startTest();
            Map<String, Object> res = DN_PortalServiceReportController.saveDNSAServiceReport(fieldMap);
            Test.stopTest();
        }
    }

    /*********************
     * getPicklistValueList 테스트
     *********************/
    @IsTest
    static void getPicklistValueList_TEST() {
        User portalUser = [SELECT Id, Name FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];

        System.runAs(portalUser) {
            Test.startTest();
            List<Map<String,String>> returnStatus   = DN_PortalServiceReportController.getPicklistValueList('Y', 'returnStatus');
            List<Map<String,String>> returnType     = DN_PortalServiceReportController.getPicklistValueList('1', 'returnType');
            List<Map<String,String>> firstReason    = DN_PortalServiceReportController.getPicklistValueList('A', 'firstReason');
            Test.stopTest();
        }
    }

    /*********************
     * 수리내역 Dependency 픽리스트 테스트
     *********************/
    @IsTest
    static void getFailure_PickList_TEST() {
        User portalUser = [SELECT Id, Name FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];

        System.runAs(portalUser) {
            Test.startTest();
            List<DN_FailureAreaController.CustomSelectOption> failureAreaMiddle = DN_PortalServiceReportController.getFailureAreaMiddle('01');
            List<DN_FailureAreaController.CustomSelectOption> failurePhenomenon = DN_PortalServiceReportController.getFailurePhenomenon('01');
            List<DN_FailureAreaController.CustomSelectOption> failureCause      = DN_PortalServiceReportController.getFailureCause('01');
            List<DN_FailureAreaController.CustomSelectOption> repairAction      = DN_PortalServiceReportController.getRepairAction('01');
            Test.stopTest();
        }
    }

    /*********************
     * getServiceReportType 테스트
     *********************/
    @IsTest
    static void getServiceReportType_TEST() {
        User portalUser = [SELECT Id, Name FROM User WHERE Username = 'portaluser@test.com.PortalServiceReportController' LIMIT 1];

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, Object> failureAreaMiddle = DN_PortalServiceReportController.getServiceReportType();
            Test.stopTest();
        }
    }

    /*********************
     * uploadfinished 테스트
     *********************/
    @IsTest
    static void uploadfinished_TEST() {
        ContentVersion cv  = [SELECT Id FROM ContentVersion WHERE Title = 'Test File Upload' LIMIT 1];
        
        DN_PortalServiceReportController.FileInfo fi = new DN_PortalServiceReportController.FileInfo();
        fi.contentVersionId = cv.Id;
        fi.fileType = 'testType';
        List<DN_PortalServiceReportController.FileInfo> fileList = new List<DN_PortalServiceReportController.FileInfo>{ fi };

        Test.startTest();
            DN_PortalServiceReportController.uploadfinished(fileList);
        Test.stopTest();
    }

    /*********************
     * getFileList 테스트
     *********************/
    @IsTest
    static void getFileList_TEST() {
        WorkOrder workOrder = [SELECT Id FROM WorkOrder WHERE OrderType__c = '201' LIMIT 1];
        
        Test.startTest();
            List<DN_PortalServiceReportController.FileInfo> fileList = DN_PortalServiceReportController.getFileList(workOrder.Id);
        Test.stopTest();
    }

    /*********************
     * fileRemove 테스트
     *********************/
    @IsTest
    static void fileRemove_TEST() {
        ContentVersion cv  = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test File Upload' LIMIT 1];
        
        List<String> fileIds = new List<String>{ cv.ContentDocumentId };
        
        Test.startTest();
            List<Map<String, String>> result = DN_PortalServiceReportController.fileRemove(fileIds);
        Test.stopTest();
    }
    
    /*********************
     * sendPDFEmail 테스트
     *********************/
    @IsTest
    static void sendPDFEmail_TEST() {
        WorkOrder workOrder = [SELECT Id FROM WorkOrder WHERE OrderType__c = '601' LIMIT 1];
        Test.setCurrentPageReference(new PageReference('/apex/DN_ServiceReportAPrint?recordId=' + workOrder.Id));
        
        Test.startTest();
            String result = DN_PortalServiceReportController.sendPDFEmail('test@example.com', workOrder.Id);
        Test.stopTest();
    }

    /*********************
     * 생성자 및 calculateTotals 테스트
     *********************/
    @IsTest
    static void constructorAndCalculateTotals_TEST() {
        WorkOrder workOrder = [SELECT Id FROM WorkOrder WHERE OrderType__c = '201' LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('/apex/DummyPage?recordId=' + workOrder.Id));
        
        DN_PortalServiceReportController controller = new DN_PortalServiceReportController();
        // controller.serviceWrapper.workList = new List<DN_PortalServiceWrapper.WorkList>{
        //     new DN_PortalServiceWrapper.WorkList(workTime = '2.5', travelHour = '1.0'),
        //     new DN_PortalServiceWrapper.WorkList(workTime = '3.0', travelHour = '0.5')
        // };
        
        Test.startTest();
            controller.calculateTotals();
        Test.stopTest();
    }

    /*********************
     * getAction 테스트
     *********************/
    @IsTest
    static void getAction_TEST() {
        WorkOrder workOrder = [SELECT Id FROM WorkOrder WHERE OrderType__c = '201' LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('/apex/DummyPage?recordId=' + workOrder.Id));
        DN_PortalServiceReportController controller = new DN_PortalServiceReportController();
        
        Test.startTest();
            controller.getAction();
        Test.stopTest();
    }    

}