/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 2025-04-08
 * @last modified by  : chungwoo.lee@sobetec.com
**/
@isTest
public class DN_PortalManageServiceController_TEST {

    private static final Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
    private static final Id dealerRT        = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id conDealerRT     = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    @TestSetup
    static void makeData() {
        RecordType ticketCaseRT = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');
        RecordType productPartRT = TestDataFactoryForSales.getRecordType('Part', 'Product2');

        // 시스템 어드민 계정 생성 후 Work Cneter생성을 위한 Dealer Account 생성하고 어드민 계정 Owner로 매핑
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', '시스템 관리자') LIMIT 1];
        User adminUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            UserRole adminUserRole = new UserRole(Name = 'Admin Role');
            insert adminUserRole;
            adminUser = new User(
                FirstName         = 'Admin',
                LastName          = 'portalTest',
                Email             = 'portalTest3@portalTest3.com',
                Username          = 'portalTest3@portalTest3.com',
                Alias             = 'poTest',
                TimeZoneSidKey    = 'Asia/Seoul',
                LocaleSidKey      = 'ko',
                EmailEncodingKey  = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId         = adminProfile.Id,
                UserRoleId        = adminUserRole.Id
            );
            insert adminUser;
        }

        Country__c krCountry = TestDataFactoryForSales.createKRCountry();
        krCountry.Country_Picklist__c = 'KR';
        insert krCountry;
        Region__c krRegion = TestDataFactoryForSales.createRegion('제주도', 'KRW', '01', krCountry.Id);
        insert krRegion;

        Account dealer = new Account(
            Name                = 'Test Account dw3',
            CountryLookup__c    = krCountry.Id,
            RegionLookup__c     = krRegion.Id,
            RecordTypeId        = dealerRT,  
            BusinessNumber__c   = '123-45-67893',
            Representative__c   = 'Rep12',
            SalesOrganization__c= '1800',
            SalesDistrict__c    = 'A1KR',
            SalesOffice__c      = '114E',
            Division__c         = '40',
            DistributionChannel__c = '10',
            OwnerId             = adminUser.Id
        );
        insert dealer;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName  = 'User',
            Email     = 'testuser@portaltest.com',
            AccountId = dealer.Id
        );
        insert testContact;

        // 포탈 계정 생성 후 포탈 계정으로 접근 가능한 데이터 생성
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'DNS CS Service_Partner' LIMIT 1];
        User portalUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            portalUser = new User(
                FirstName         = 'Test',
                LastName          = 'PortalUser',
                Email             = 'portaluser@test9999.com',
                Username          = 'portaluser@test9999.com',
                Alias             = 'puser',
                TimeZoneSidKey    = 'Asia/Seoul',
                LocaleSidKey      = 'ko',
                EmailEncodingKey  = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId         = portalProfile.Id,
                ContactId         = testContact.Id
            );
            insert portalUser;
        } 

        OperatingHours ohForPortal;
        System.runAs(portalUser) {
            ohForPortal = new OperatingHours();
            ohForPortal.Name = '대한민국 표준 작업 시간';
            ohForPortal.TimeZone = 'Asia/Seoul';
            insert ohForPortal;
        }

        // Portal User 컨텍스트에서 ServiceTerritory 생성 시, ohForPortal.Id 사용
        ServiceTerritory workCenter;
        System.runAs(portalUser) {
            workCenter = new ServiceTerritory();
            workCenter.Name = 'Test Account dw3';
            workCenter.ServiceWorkCenter__c = dealer.Id; // 필요에 맞게 설정
            workCenter.OperatingHoursId = ohForPortal.Id;
            workCenter.IsActive = true;
            insert workCenter;
        }


        System.runAs(new User(Id = UserInfo.getUserId())) {
            PermissionSetAssignment psaResource = new PermissionSetAssignment(
                AssigneeId = portalUser.Id,
                PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Resource_Permissions' LIMIT 1].Id
            );
            insert psaResource;
        }        

        ServiceResource worker;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            worker = new ServiceResource();
            worker.Name = 'Partner Worker';
            worker.CurrentStatus__c = 'Wait';
            worker.RelatedRecordId = portalUser.Id;
            worker.IsActive = true;
            worker.Service_Territory__c = workCenter.Id;
            worker.Branch__c = 'DNS';
            insert worker;
        }
        
        Id woWithPRId; 
    }
    
    static testMethod void testGetLoginUserInfo() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test9999.com' LIMIT 1];

        System.runAs(portalUser) { 
            Test.startTest();
            DN_PortalManageServiceController testInstans = new DN_PortalManageServiceController();
            DN_PortalManageServiceController.NonReturnedScrap testWrapper = new DN_PortalManageServiceController.NonReturnedScrap();
            Map<String, Object> resMap = DN_PortalManageServiceController.getLoginUserInfo();
            Test.stopTest();
        }
    }

    @IsTest
    static void testServiceCostAdjustment() {
        // IF 테스트 레코드 생성
        InterfaceCommonUtil.setInterface('IF-SERVICE-043', 'IF_ERP_Service_CostAdjustment');
        // IF Mock 데이터 셋팅
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_CostAdjustment_Test.IF_SERVICE_043_HttpMock());

        Map<String, Object> fieldMap = new Map<String, Object>{
            'orderNumber'    => '000403907884',
            'dateFrom'       => '2025-01-01',
            'dateTo'         => '2025-01-31',
            'orderType'      => 'I'
        };

        Test.startTest();
        Map<String, Object> result = DN_PortalManageServiceController.serviceCostAdjustment(fieldMap);
        System.debug('test testServiceCostAdjustment ::: ' + JSON.serialize(result));
        Test.stopTest();
    }   

    @IsTest
    static void testServiceCostAdjustmentSend() {
        // IF 테스트 레코드 생성
        InterfaceCommonUtil.setInterface('IF-SERVICE-044', 'IF_ERP_Service_CostAdjustment');
        // IF Mock 데이터 셋팅
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_CostAdjustment_Test.IF_SERVICE_044_HttpMock());
        
        List<DN_PortalManageServiceController.CostAdjustmentSend> sendList = new List<DN_PortalManageServiceController.CostAdjustmentSend>();
        DN_PortalManageServiceController.CostAdjustmentSend item = new DN_PortalManageServiceController.CostAdjustmentSend();
        item.AUFNR   = '000403907884';
        item.SEQNO   = '001';
        item.WEB_CHK = 'Y';
        sendList.add(item);
        
        Test.startTest();
        Map<String, Object> result = DN_PortalManageServiceController.serviceCostAdjustmentSend(sendList);
        System.debug('test testServiceCostAdjustmentSend ::: ' + JSON.serialize(result));
        Test.stopTest();
    }

    @IsTest
    static void testGetNonReturnedList_Call() {
        // IF 테스트 레코드 생성
        InterfaceCommonUtil.setInterface('IF-SERVICE-047', 'IF_ERP_Service_Scrap');
        // IF Mock 데이터 셋팅
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_Scrap_Test.IF_SERVICE_047_HttpMock());
        
        DN_PortalManageServiceController.NonReturnedScrap searchParam = new DN_PortalManageServiceController.NonReturnedScrap();
        searchParam.I_DATUM_FROM = '2025-01-01';
        searchParam.I_DATUM_TO   = '2025-01-31';
        searchParam.I_ARBPL      = '';
        searchParam.I_RETURN_TYPE= '';
        searchParam.I_RETURN_YN  = 'Y';
        searchParam.I_AUFNR      = '';
        searchParam.I_MATNR      = '';
        searchParam.WERKS        = '184S';
        
        Test.startTest();
        DN_PortalManageServiceController.getNonReturnedList(searchParam);
        Test.stopTest();
    }

    @IsTest
    static void testGetAction_Call() {
        // IF 테스트 레코드 생성
        InterfaceCommonUtil.setInterface('IF-SERVICE-048', 'IF_ERP_Service_Scrap');
        // IF Mock 데이터 셋팅
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_Scrap_Test.IF_SERVICE_048_HttpMock());
        
        PageReference pageRef = new PageReference('/apex/TestPage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('MATNR', 'MAT001,MAT002');
        ApexPages.currentPage().getParameters().put('AUFNR', '11111,22222');

        Test.startTest();
        DN_PortalManageServiceController controller = new DN_PortalManageServiceController();
        controller.getAction();
        Test.stopTest();
    }

    @IsTest
    static void testTOutputInstantiation() {
        DN_PortalManageServiceController.T_OUTPUT output = new DN_PortalManageServiceController.T_OUTPUT();
        output.AUFNR = 'TestOrder';
        output.ENAME = 'Test Employee';
        output.KTEXT = 'Test KTEXT';
        output.MAKTX = 'Test MAKTX';
        output.MATNR = 'Test MATNR';
        output.MATXT = 'Test MATXT';
        output.MEINS = 'EA';
        output.MENGE = '1.000';
        output.MZEIT = '09:00:00';
        output.NAME1 = 'Test Name1';
        output.NAME2 = 'Test Name2';
        output.PRT_DATE = '2025-01-01';
        output.PRT_TIME = '12:00:00';
        output.QMDAT = '2025-01-01';
        output.QMNUM = 'Test QMNUM';
        output.RETURN_DT = '2025-01-05';
        output.RETURN_TEXT = 'Test Return Text';
        output.RETURN_TYPE = 'Test Return Type';
        output.SEQNO = '0001';
        output.SERNR = 'Test Serial';
        output.SUPPLY_TYPE = 'Test Supply';
        output.TYPBZ = 'Test TYPBZ';
        output.WADAT_IST = '2025-01-01';
        
        String jsonStr = JSON.serialize(output);
        System.debug('T_OUTPUT JSON: ' + jsonStr);
    }

    @IsTest
    static void testGetPartsIssuanceStatus_Call() {
        InterfaceCommonUtil.setInterface('IF-SERVICE-035', 'IF_ERP_Service_PartStat');
        
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_PartStat_Test.IF_SERVICE_035_HttpMock());
        
        DN_PortalManageServiceController.PartsIssuanceSearch search = new DN_PortalManageServiceController.PartsIssuanceSearch();
        search.I_AUART   = 'CS02';
        search.I_EQUNR   = 'EQ001';
        search.I_SERNR   = 'SERNR001';
        search.WERKS     = '184S';
        search.I_RPDAT_F = '2025-01-01T00:00:00';
        search.I_RPDAT_T = '2025-01-31T00:00:00';
        search.I_AUFNR_F = '11111';
        search.I_AUFNR_T = '22222';
        search.I_VBELN_F = 'VB001';
        search.I_VBELN_T = 'VB002';
        search.I_ARBPL_F = 'WC003';
        search.I_ARBPL_T = 'WC004';
        search.I_EQFNR_F = 'EQF001';
        search.I_EQFNR_T = 'EQF002';
        
        Test.startTest();
        IF_ERP_Service_PartStat_Classes.IF_SERVICE_035_Res res = DN_PortalManageServiceController.getPartsIssuanceStatus(search);
        Test.stopTest();
        
        System.debug('PartsIssuanceStatus result: ' + res);
    }
}