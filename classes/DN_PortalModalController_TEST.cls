/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 04-29-2025
 * @last modified by  : Chungwoo Lee
**/
@IsTest
public with sharing class DN_PortalModalController_TEST {

    /*********************
     * TestSetup 데이터
     *********************/
    private static final Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
    private static final Id dealerRT        = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id conDealerRT     = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    @TestSetup
    static void makeData() {
        RecordType ticketCaseRT = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');
        RecordType productPartRT = TestDataFactoryForSales.getRecordType('Part', 'Product2');

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEO' Limit 1];

        // 시스템 어드민 계정 생성 후 Work Cneter생성을 위한 Dealer Account 생성하고 어드민 계정 Owner로 매핑
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', '시스템 관리자') LIMIT 1];

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        Country__c krCountry = TestDataFactoryForSales.createKRCountry();
        krCountry.Country_Picklist__c = 'KR';
        insert krCountry;
        
        Region__c krRegion = TestDataFactoryForSales.createRegion('제주도', 'KRW', '01', krCountry.Id);
        insert krRegion;
        
        User adminUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            UserRole adminUserRole = new UserRole(Name = 'Admin Role');
            insert adminUserRole;

            adminUser = new User(FirstName='Admin', LastName='portalTest', Email='portalTest3@dncompany.com.test9', Username='portalTest3@dncompany.com.test9', Alias='poTest', TimeZoneSidKey='Asia/Seoul', LocaleSidKey='ko', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=adminProfile.Id, UserRoleId=adminUserRole.Id); 
            insert adminUser;
        }

        Account dealerAccount = new Account(Name='Test WorkCenter', CountryLookup__c=krCountry.Id, RegionLookup__c=krRegion.Id, RecordTypeId=dealerRT, BusinessNumber__c='123-45-67893', Representative__c='Rep12', SalesOrganization__c='1800', SalesDistrict__c='A1KR', SalesOffice__c='114E', Division__c='40', DistributionChannel__c='10', OwnerId=adminUser.Id);
        insert dealerAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName  = 'User', Email = 'testuser@portaltest.com', AccountId = dealerAccount.Id);
        insert testContact;

        Contact testContact2 = new Contact(FirstName = 'Test2', LastName  = 'User2', Email = 'testuser2@portaltest.com', AccountId = dealerAccount.Id);
        insert testContact2;

        // 포탈 계정 생성 후 포탈 계정으로 접근 가능한 데이터 생성
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'DNS CS Service_Partner' LIMIT 1];
        User portalUser;
        User portalUser2;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            portalUser = new User(FirstName='Test', LastName='PortalUser', Email='portaluser@dncompany.com.test9', Username='portaluser@dncompany.com.test9', Alias='puser', TimeZoneSidKey='Asia/Seoul', LocaleSidKey='ko', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=portalProfile.Id, ContactId=testContact.Id); 
            insert portalUser;
            portalUser2 = new User(FirstName='Test2', LastName='PortalUser2', Email='portaluser2@dncompany.com.test9', Username='portaluser2@dncompany.com.test9', Alias='puser2', TimeZoneSidKey='Asia/Seoul', LocaleSidKey='ko', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', ProfileId=portalProfile.Id, ContactId=testContact2.Id); 
            insert portalUser2;
            
            Account acc = new Account(Name='Test Account 2', ResidentRegistrationNumber__c='990811', CountryLookup__c=krCountry.Id, RegionLookup__c=krRegion.Id, RecordTypeId=tradeCustomerRT, BusinessNumber__c='987-65-43210', Representative__c='Rep2', SalesOrganization__c='1800', SalesDistrict__c='A1KR', SalesOffice__c='114E', Division__c='40', DistributionChannel__c='10', CustomerCode__c='1308913', OwnerId=portalUser.Id); 
            insert acc;

            Asset ass = new Asset(Name='ML0006-006231', MachineName__c='LYNX 220A-NT', Material__c='L22ANT-F0TP-0-K30', SerialNumber='ML0006-006231', Status='AVLB', AccountId=acc.Id, SoldTo__c=acc.Id, OwnerId=portalUser.Id, NCType__c='TEST'); 
            insert ass;
            
            insert new Case(TicketType__c='Technical inquiry', InternalTicketType__c='Failure receipt', Status='Uncompleted', RecordTypeId=ticketCaseRT.Id, AssetId=ass.Id, OwnerId=portalUser.Id, isAlarmToCustomer__c=false);

            insert new Model__c(Name = 'Test Model');

            ModelManager__c manager = new ModelManager__c(Name='Test Manager', ModelCode__c='Test', Manager__c=adminUser.Id, ModelCategory__c='CS_MT_PMA');
            insert manager;

            insert new FailureArea_Major__c(FailureAreaMajor_Value__c = '4T0', FailureAreaMajor_Label__c = 'Elec._Ctrl', ModelCategory__c = 'CS_MT_PMA');
            insert new Standard_HR__c(FailureArea__c = 'Elec._Ctrl', ModelManager__c = manager.Id, IsActive__c = true, StandardWorkTime__c = 2, StandardWorkForce__c = 2);
        } 

        AssignmentRule__c assignmentRule = new AssignmentRule__c(Name = '기술상담사 순차배정');
        insert assignmentRule;

        Product2 prod2 = new Product2(Name = 'ESWSL0132', ProductCode = 'ESWSL0132', IsActive = true, CurrencyIsoCode = 'KRW', RecordTypeId = productPartRT.Id, MaterialDetailsEN__c = 'ESWSL0132', MaterialDetailsKO__c = 'ESWSL0132', Plant__c = '184S;414S;1846;4146');
        insert prod2;

        OperatingHours ohForPortal;
        System.runAs(portalUser) { 
            ohForPortal = new OperatingHours(Name = '대한민국 표준 작업 시간', TimeZone = 'Asia/Seoul');
            insert ohForPortal;
        }

        // Portal User 컨텍스트에서 ServiceTerritory 생성 시, ohForPortal.Id 사용
        ServiceTerritory workCenter;
        System.runAs(portalUser) {
            workCenter = new ServiceTerritory(Name = 'Test WorkCenter', ServiceWorkCenter__c = dealerAccount.Id, OperatingHoursId = ohForPortal.Id, IsActive = true, classify__c = 'W/C');
            insert workCenter;
        }

        System.runAs(new User(Id = UserInfo.getUserId())) {
            PermissionSetAssignment psaResource = new PermissionSetAssignment(AssigneeId = portalUser.Id, PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Resource_Permissions' LIMIT 1].Id);
            insert psaResource;

            PermissionSetAssignment psaResource2 = new PermissionSetAssignment(AssigneeId = portalUser2.Id, PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Resource_Permissions' LIMIT 1].Id);
            insert psaResource2;
        }        

        ServiceResource worker;
        ServiceResource worker2;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            worker = new ServiceResource(Name = 'Partner Worker', CurrentStatus__c = 'Wait', RelatedRecordId = portalUser.Id, IsActive = true, Service_Territory__c = workCenter.Id, Branch__c = 'DNS');
            insert worker;

            worker2 = new ServiceResource(Name = 'Partner Worker2', CurrentStatus__c = 'Wait', RelatedRecordId = portalUser2.Id, StaffNumber__c = '6527', IsActive = true, Service_Territory__c = workCenter.Id, Branch__c = 'DNS');
            insert worker2;
        }
        
        Id woWithPRId; 

        System.runAs(portalUser) {
            Asset assetForUser = [SELECT Id FROM Asset WHERE Name = 'ML0006-006231' LIMIT 1];
            Case caseForUser = [SELECT Id, TicketType__c FROM Case WHERE TicketType__c = 'Technical inquiry' LIMIT 1];
            ServiceResource sr = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :portalUser.Id LIMIT 1];
            ServiceTerritory wc = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Test WorkCenter' LIMIT 1];

            WorkOrder woWithPR = new WorkOrder(
                CaseId = caseForUser.Id,
                AssetId = assetForUser.Id,
                AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1].Id,
                SoldTo__c = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1].Id,
                ServiceTerritoryId = wc.Id,
                Worker__c = sr.Id,
                TicketType__c = 'Failure receipt',
                OrderType__c = '202',
                PMActivityType__c = 'CS02',
                Status = 'New',
                completionTime__c = System.now(),
                ActualDispatchTime__c = System.now(),
                ScheduledDispatchTime__c = System.now(),
                HasWarrantyDirectManagement__c = true,
                isAlarmToStaff__c = false
            );
            insert woWithPR;
            woWithPRId = woWithPR.Id; 
        }

        Collaborator__c collaborator = new Collaborator__c (WorkOrder__c = woWithPRId, ServiceResource__c = worker2.Id);
        insert collaborator;

        ProductRequest preq = new ProductRequest(WorkOrderId = woWithPRId, Product__c = prod2.Id);
        insert preq;
    }
    
    /*********************
     * WorkerInfoWrapper 테스트
     *********************/
    @IsTest
    static void testWorkerInfoWrapperInstantiation() {
        // 기본 생성자
        DN_PortalModalController.WorkerInfoWrapper wrapper1 = new DN_PortalModalController.WorkerInfoWrapper();
        wrapper1.Id = 'SR001';
        wrapper1.Name = 'John Doe';
        wrapper1.workerPartnerNumber = 'WP123';
        wrapper1.workCenterId = 'WC001';
        wrapper1.workCenterCode = 'WCCODE1';
        wrapper1.workCenterName = 'Work Center 1';
        wrapper1.workCenterDivision = 'Division A';
        
        String json1 = JSON.serialize(wrapper1);
        System.debug('WorkerInfoWrapper default constructor JSON: ' + json1);
        
        // 파라미터 생성자
        DN_PortalModalController.WorkerInfoWrapper wrapper2 = new DN_PortalModalController.WorkerInfoWrapper(
            'SR002',
            'Jane Smith',
            'WP456',
            'WC002',
            'WCCODE2',
            'Work Center 2',
            'Division B'
        );
        
        String json2 = JSON.serialize(wrapper2);
        System.debug('WorkerInfoWrapper parameterized constructor JSON: ' + json2);
    }
    
    /*********************
     * getLoginUserInfo 테스트
     *********************/
    // 타입이 'ServiceReport'일 경우
    @IsTest
    static void testGetLoginUserInfo_ServiceReport() {
        String workOrderId = [SELECT Id FROM WorkOrder WHERE OrderType__c = '202' LIMIT 1].Id;

        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getLoginUserInfo(workOrderId, 'ServiceReport', false);
        Test.stopTest();
    }

    // 타입이 'InstallTest' 인 경우
    @IsTest
    static void testGetLoginUserInfo_InstallTest() {
        String workOrderId = [SELECT Id FROM WorkOrder WHERE OrderType__c = '202' LIMIT 1].Id;

        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getLoginUserInfo(workOrderId, 'InstallTest', false);
        Test.stopTest();
    }
    
    // 타입이 'DNSA'일 경우
    @IsTest
    static void testGetLoginUserInfo_DNSA() {
        String workCenterId = [SELECT Id FROM ServiceTerritory WHERE Name = 'Test WorkCenter' LIMIT 1].Id;
        
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getLoginUserInfo(workCenterId, 'DNSA', false);
        Test.stopTest();
    }
    
    // 그 외 타입 (else 분기)
    @IsTest
    static void testGetLoginUserInfo_Other() {
        String workCenterId = [SELECT Id FROM ServiceTerritory WHERE Name = 'Test WorkCenter' LIMIT 1].Id;
        
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getLoginUserInfo(workCenterId, 'Other', false);
        Test.stopTest();
    }

    // Exception Test
    @IsTest
    static void testGetLoginUserInfo_ExceptionCase() {
        
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getLoginUserInfo('testException', 'Other', false);
        Test.stopTest();
    }
    
    /*********************
     * getCurruntWorkCenter 테스트
     *********************/
    @IsTest
    static void testGetCurruntWorkCenter() {
        String workCenterId = [SELECT Id FROM ServiceTerritory WHERE Name = 'Test WorkCenter' LIMIT 1].Id;

        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getCurruntWorkCenter(workCenterId);
        Test.stopTest();
    }

    @IsTest
    static void testGetCurruntWorkCenter_InvalidCase() {
        String workCenterId;

        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getCurruntWorkCenter(workCenterId);
        Test.stopTest();
    }

    @IsTest
    static void testGetCurruntWorkCenter_NullCase() {
        String workCenterId = 'a1HF700000481KGMAY'; // 생성되지 않은 Id 값

        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getCurruntWorkCenter(workCenterId);
        Test.stopTest();
    }
    
    /*********************
     * getNewWorkers 테스트
     *********************/
    @IsTest
    static void testGetNewWorkers() {
        String workCenterId = [SELECT Id FROM ServiceTerritory WHERE Name = 'Test WorkCenter' LIMIT 1].Id;

        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getNewWorkers(workCenterId);
        Test.stopTest();
    }

    @IsTest
    static void testGetNewWorkers_InvalidCase() {
        String workCenterId = '';

        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getNewWorkers(workCenterId);
        Test.stopTest();
    }

    @IsTest
    static void testGetNewWorkers_ExceptionCase() {
        String workCenterId = 'testException'; // throw 발생 시키기 위한 고정 값
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getNewWorkers(workCenterId);
        Test.stopTest();
    }
        
    /*********************
     * searchWorkOrderList 테스트 (수주 번호 조회)
     *********************/
    @IsTest
    static void testSearchWorkOrderList() {
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.searchWorkOrderList('123');
        Test.stopTest();
        System.debug('searchWorkOrderList: ' + res);
    }

    @IsTest
    static void testSearchWorkOrderList_ExceptionCase() {
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.searchWorkOrderList('testException');
        Test.stopTest();
    }


    @IsTest
    static void testsearchOrderList_ExceptionCase() {
        List<Order> order2 = new List<Order>();
        insert order2;
        Test.startTest();
        try{
            Map<String, Object> res = DN_PortalModalController.searchOrderList('testException', 'testException');
        }catch(Exception e) {}
        
        Test.stopTest();
    }

    @IsTest
    static void testOrderEquipmentInfo_ExceptionCase() {
        List<Order> order3 = new List<Order>();
        insert order3;

        Test.startTest();
        try{
            List<Order> res = DN_PortalModalController.OrderEquipmentInfo('testException', 'en', 'accId');
        }catch(Exception e) {}
        
        Test.stopTest();
    }
    
    /*********************
     * searchCustomer 테스트
     *********************/
    @IsTest
    static void testSearchCustomer() {
        Map<String, Object> searchData = new Map<String, Object>{
            'accountName' => 'Test Customer',
            'representative' => 'Test Rep',
            'address' => 'Test Address'
        };
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.searchCustomer(searchData);
        Test.stopTest();
        System.debug('searchCustomer: ' + res);
    }

    @IsTest
    static void testSearchCustomer_ExceptionCase() {
        Map<String, Object> searchData = new Map<String, Object>{
            'accountName' => 123,
            'representative' => '',
            'address' => ''
        };
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.searchCustomer(searchData);
        Test.stopTest();
        System.debug('searchCustomer: ' + res);
    }
    
    /*********************
     * initStandardHRList 테스트
     *********************/
    @IsTest
    static void testInitStandardHRList() {
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.initStandardHRList('CS_MT_PMA', 'Test');
        Test.stopTest();
    }

    @IsTest
    static void testInitStandardHRList_EmptyCase() {
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.initStandardHRList('CS_NO_NO', 'Test');
        Test.stopTest();
    }

    /*********************
     * getStandardHRbyfailureArea 테스트
     *********************/
    @IsTest
    static void testGetStandardHRbyfailureArea() {
        String managerId = [SELECT Id FROM ModelManager__c WHERE Name = 'Test Manager' LIMIT 1].Id;

        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getStandardHRbyfailureArea('Elec._Ctrl', managerId);
        Test.stopTest();
    }

    @IsTest
    static void testGetStandardHRbyfailureArea_ExceptionCase() {
        String managerId = [SELECT Id FROM ModelManager__c WHERE Name = 'Test Manager' LIMIT 1].Id;

        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.getStandardHRbyfailureArea('testException', managerId);
        Test.stopTest();
    }
    
    /*********************
     * searchStandardHRList 테스트
     *********************/
    @IsTest
    static void testSearchStandardHRList() {
        List<Standard_HR__c> stdList = [SELECT Id, FailureArea__c, StandardHourItem__c, ModelManager__c FROM Standard_HR__c LIMIT 1];
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.searchStandardHRList(stdList[0].FailureArea__c, stdList[0].ModelManager__c, stdList[0].StandardHourItem__c);
        Test.stopTest();
    }

    @IsTest
    static void testSearchStandardHRList_ExceptionCase() {
        List<Standard_HR__c> stdList = [SELECT Id, FailureArea__c, StandardHourItem__c, ModelManager__c FROM Standard_HR__c LIMIT 1];
        Test.startTest();
        Map<String, Object> res = DN_PortalModalController.searchStandardHRList('testException', stdList[0].ModelManager__c, stdList[0].StandardHourItem__c);
        Test.stopTest();
    }
    
    /*********************
     * machineInfo 테스트
     *********************/
    @IsTest
    static void testMachineInfo() {
        Test.startTest();
        List<ModelManager__c> res = DN_PortalModalController.machineInfo('Test Manager');
        Test.stopTest();
    }
    
    /*********************
     * unitInfo 테스트
     *********************/
    @IsTest
    static void testUnitInfo() {
        Test.startTest();
        List<Asset> res = DN_PortalModalController.unitInfo('LYNX 220A-NT');
        Test.stopTest();
    }
    
    /*********************
     * equipmentInfo 테스트
     *********************/
    @IsTest
    static void testEquipmentInfo() {
        Test.startTest();
        List<Asset> res = DN_PortalModalController.equipmentInfo('LYNX 220A-NT', 'ML0006-006231');
        Test.stopTest();
    }
    
    /*********************
     * getDealerInfo 테스트
     *********************/
    @IsTest
    static void testGetDealerInfo() {
        Test.startTest();
        List<Account> res = DN_PortalModalController.getDealerInfo();
        Test.stopTest();
    }
    
    /*********************
     * getPartsInfo 테스트
     *********************/
    @IsTest
    static void testGetPartsInfo() {
        List<String> partList = new List<String>(); 
        Test.startTest();
        List<Product2> res = DN_PortalModalController.getPartsInfo('ESWSL0132', 'ESWSL0132', partList, true);
        Test.stopTest();
    }
    
    /*********************
     * searchBuyerInfo 테스트
     *********************/
    @IsTest
    static void testSearchBuyerInfo() {
        DN_PortalLoginUser.DealerInfo dli = new DN_PortalLoginUser.DealerInfo();
        dli.dealerCode = 'D001';
        dli.userProfile = 'Profile1';
        dli.accountId = 'A001';
        
        Test.startTest();
        List<DealerCustomerShipTo__c> res = DN_PortalModalController.searchBuyerInfo('BC', 'Buyer', (DN_PortalLoginUser.DealerInfo) dli);
        Test.stopTest();
        System.debug('searchBuyerInfo: ' + res);
    }
    
    /*********************
     * getDealerCustomerShipTo 테스트
     *********************/
    @IsTest
    static void testGetDealerCustomerShipTo() {
        Test.startTest();
        List<DN_AgencyCustomerListModalController.AgencyCustomerShipTo> res = DN_PortalModalController.getDealerCustomerShipTo('CustCode', 'CustName');
        Test.stopTest();
        System.debug('getDealerCustomerShipTo: ' + res);
    }
}