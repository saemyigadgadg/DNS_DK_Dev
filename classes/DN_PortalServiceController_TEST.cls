/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 2025-05-16
 * @last modified by  : yeongju.yun
**/
@isTest
public class DN_PortalServiceController_TEST {
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

        // Too many SOQL queries 방지
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'TicketTriggerHandler', 'WorkOrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; 

        // 포탈 계정 생성 후 포탈 계정으로 접근 가능한 데이터 생성
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'DNS CS Service_Partner' LIMIT 1];
        User portalUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            portalUser = new User(
                FirstName         = 'Test',
                LastName          = 'PortalUser',
                Email             = 'portaluser@test.com.PortalService',
                Username          = 'portaluser@test.com.PortalService',
                Alias             = 'puser',
                TimeZoneSidKey    = 'Asia/Seoul',
                LocaleSidKey      = 'ko',
                EmailEncodingKey  = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId         = portalProfile.Id,
                ContactId         = testContact.Id
            );
            insert portalUser;

            Account acc = new Account(
                Name                = 'Test Account 2',
                ResidentRegistrationNumber__c = '990811',
                CountryLookup__c    = krCountry.Id,
                RegionLookup__c     = krRegion.Id,
                RecordTypeId        = tradeCustomerRT,  
                BusinessNumber__c   = '987-65-43210',
                Representative__c   = 'Rep2',
                SalesOrganization__c= '1800',
                SalesDistrict__c    = 'A1KR',
                SalesOffice__c      = '114E',
                Division__c         = '40',
                DistributionChannel__c = '10',
                CustomerCode__c     = '1308913',
                OwnerId             = portalUser.Id
            );
            insert acc;

            Asset ass = new Asset();
            ass.Name           = 'ML0006-006231';
            ass.MachineName__c = 'LYNX 220A-NT';
            ass.Material__c    = 'L22ANT-F0TP-0-K30';
            ass.SerialNumber   = 'ML0006-006231';
            ass.Status         = 'AVLB';
            ass.AccountId      = acc.Id;
            ass.SoldTo__c      = acc.Id;
            ass.OwnerId        = portalUser.Id;
            ass.NCType__c      = 'TEST';
            insert ass;

            Case cs = new Case();
            cs.TicketType__c         = 'Technical inquiry';
            cs.InternalTicketType__c = 'Failure receipt';
            cs.Status                = 'Uncompleted';
            cs.RecordTypeId          = ticketCaseRT.Id;
            cs.AssetId               = ass.Id;
            cs.OwnerId               = portalUser.Id;
            cs.isAlarmToCustomer__c  = false;
            insert cs;
        } 

        AssignmentRule__c assignmentRule = new AssignmentRule__c(Name = '기술상담사 순차배정');
        insert assignmentRule;

        Product2 prod = new Product2();
        prod.Name            = 'ESWSL0132';
        prod.ProductCode     = 'ESWSL0132';
        prod.IsActive        = true;
        prod.CurrencyIsoCode = 'KRW';
        prod.RecordTypeId    = productPartRT.Id;
        prod.Plant__c        = '184S;414S;1846;4146';
        insert prod;

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
            workCenter.ServiceWorkCenter__c = dealer.Id; 
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

        System.runAs(portalUser) {
            Asset assetForUser = [SELECT Id FROM Asset WHERE Name = 'ML0006-006231' LIMIT 1];
            Case caseForUser = [SELECT Id, TicketType__c FROM Case WHERE TicketType__c = 'Technical inquiry' LIMIT 1];
            ServiceResource sr = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :portalUser.Id LIMIT 1];
            ServiceTerritory wc = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Test Account dw3' LIMIT 1];
            Account AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
            Account soldTo = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];

            WorkOrder woWithPR = new WorkOrder(
                CaseId = caseForUser.Id,
                AssetId = assetForUser.Id,
                AccountId = AccountId.Id,
                SoldTo__c = soldTo.Id,
                ServiceTerritoryId = wc.Id,
                Worker__c = sr.Id,
                TicketType__c = 'Failure receipt',
                OrderType__c = '201',
                PMActivityType__c = 'CS02',
                Status = 'New',
                completionTime__c = System.now(),
                ActualDispatchTime__c = System.now(),
                ScheduledDispatchTime__c = System.now(),
                HasWarrantyDirectManagement__c = true,
                isAlarmToStaff__c = false,
                ServiceOrderNumber__c= '000000001'
            );
            insert woWithPR;
            woWithPRId = woWithPR.Id; 

            WorkOrder woWithoutPR = new WorkOrder(
                CaseId = caseForUser.Id,
                AssetId = assetForUser.Id,
                AccountId = AccountId.Id,
                SoldTo__c = soldTo.Id,
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
                isAlarmToStaff__c = false,
                ServiceOrderNumber__c= '000000002'
            );
            insert woWithoutPR;
        }

        ProductRequest preq = new ProductRequest(WorkOrderId = woWithPRId, Product__c = prod.Id);
        insert preq;

        System.runAs(portalUser) {
            ResourceAbsence resource = new ResourceAbsence();
            resource.ResourceId = worker.Id;
            resource.Type = 'Leave';
            resource.Start = System.now().addDays(-5);
            resource.End = System.now().addDays(-4);
            resource.description = 'TEST Description';
            resource.EquipmentText__c = 'TEST Equipment';
            resource.AccountNameText__c = 'TEST Account';
            insert resource;
        }
    }

    
    static testMethod void testGetLoginUserInfo() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalService' LIMIT 1];

        System.runAs(portalUser) { 
            Test.startTest();
            Map<String, Object> resMap = DN_PortalServiceController.getLoginUserInfo();
            Test.stopTest();
        }
    }
    
    static testMethod void testGetLoginUserWorkCenter() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalService' LIMIT 1];

        System.runAs(portalUser) { 
            Test.startTest();
            Map<String, Object> resMap = DN_PortalServiceController.getLoginUserWorkCenter();
            Test.stopTest();
        }
    }
    
    static testMethod void testGetServiceHistoryList() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalService' LIMIT 1];

        System.runAs(portalUser) { 
            Map<String, Object> searchData = new Map<String, Object>{
                'psoNumber'       => '',
                'customerCode'    => '1308913',
                'customerName'    => 'test',
                'machineName'     => 'test',
                'assetName'       => 'test',
                'receiptDateFrom' => '2024-01-01',
                'receiptDateTo'   => '2024-12-31'
            };
            
            Test.startTest();
            Map<String, Object> resMap = DN_PortalServiceController.getServiceHistoryList(searchData);
            Test.stopTest();
        }
    }
    
    static testMethod void testSearchProgressWork() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalService' LIMIT 1];

        System.runAs(portalUser) { 
            Map<String, Object> searchData1 = new Map<String, Object>{
                'workStatus'         => '',
                'workStartDate'      => '2024-01-01',
                'workEndDate'        => '2024-12-31',
                'workOrderNumber'    => '000000001',
                'orderType'          => '201',
                'hasWarranty'        => false
            };

            Map<String, Object> searchData2 = new Map<String, Object>{
                'workStatus'         => 'notConfirm',
                'workStartDate'      => '2024-01-01',
                'workEndDate'        => '2024-12-31',
                'workOrderNumber'    => '000000001',
                'orderType'          => '201',
                'hasWarranty'        => false
            };

            Map<String, Object> searchData3 = new Map<String, Object>{
                'workStatus'         => 'Confirm',
                'workStartDate'      => '2024-01-01',
                'workEndDate'        => '2024-12-31',
                'workOrderNumber'    => '000000001',
                'orderType'          => '201',
                'hasWarranty'        => true
            };
            
            Test.startTest();
            Map<String, Object> resMap1 = DN_PortalServiceController.searchProgressWork(searchData1);
            Map<String, Object> resMap2 = DN_PortalServiceController.searchProgressWork(searchData2);
            Map<String, Object> resMap3 = DN_PortalServiceController.searchProgressWork(searchData3);
            Test.stopTest();
        }
    }
    
    static testMethod void testGetCSServiceHistoryList() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalService' LIMIT 1];

        System.runAs(portalUser) { 
            ServiceResource worker = [SELECT Id FROM ServiceResource WHERE RelatedRecordId =:userInfo.getUserId()];
            Map<String, Object> searchData = new Map<String, String>{
                'orderNumber'     => '00000001',
                'customerName'    => 'Test Account 2',
                'machineName'     => 'test Machine Name',
                'assetName'       => 'test Asset Name',
                'orderType'       => 'test',
                'workCenter'      => 'test Work Center',
                'worker'          =>  worker.Id,
                'ncType'          => 'TEST',
                'receiptDateFrom' => '2024-01-01',
                'receiptDateTo'   => '2024-12-31'
            };
            
            Test.startTest();
            Map<String, Object> resMap = DN_PortalServiceController.getCSServiceHistoryList(searchData);
            Test.stopTest();
        }
    }

    @isTest
    static void testGetCSServiceHistoryByPartNumber() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalService' LIMIT 1];
        Asset asset = [SELECT Id, MachineName__c, Name FROM Asset WHERE Name = 'ML0006-006231' LIMIT 1];
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        ServiceTerritory st = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Test Account dw3' LIMIT 1];
        Case cs = [SELECT Id, ApplicationDateTime__c FROM Case LIMIT 1];

        System.runAs(portalUser) { 
            ServiceResource sr = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() LIMIT 1];
                
            Date testStart = Date.today().addMonths(-1);
            Date testEnd   = Date.today().addDays(1);
            DateTime startDatetime = DateTime.newInstance(testStart.year(), testStart.month(), testStart.day());
            DateTime endDatetime   = DateTime.newInstance(testEnd.year(), testEnd.month(), testEnd.day());
            String startDate = startDatetime.format('yyyy-MM-dd');
            String endDate   = endDatetime.format('yyyy-MM-dd');
        
            // Map<String, Object> searchData = new Map<String, Object>{
            //     'receiptDateFrom' => startDate,
            //     'receiptDateTo'   => endDate,
            //     'orderNumber'     => '',
            //     'customerCode'    => '1308913',
            //     'machineName'     => 'LYNX 220A-NT',
            //     'assetName'       => 'ML0006-006231',
            //     'orderType'       => 'CS02',         
            //     'workCenter'      => 'Test Account dw3',
            //     'worker'          => sr.Id,
            //     'ncType'          => 'TEST',
            //     'productNumber'   => ''
            // };

            Map<String, Object> searchData = new Map<String, Object>{
                // 'receiptDateFrom' => startDate,
                // 'receiptDateTo'   => endDate,
                // 'customerCode'    => '1308913',
                'machineName'     => 'LYNX 220A-NT',
                'assetName'       => 'ML0006-006231',
                'orderType'       => 'CS02',
                'workCenter'      => 'Test Account dw3',
                'ncType'          => 'TEST'
            };
            
        
            Test.startTest();
                Map<String, Object> resMap = DN_PortalServiceController.getCSServiceHistoryByPartNumber(searchData);
            Test.stopTest();
        
            System.debug('Result: ' + JSON.serialize(resMap));
        }
    }
    
    @isTest
    static void testGetList() {
        User portalUser = [SELECT Id FROM User WHERE Username='portaluser@test.com.PortalService' LIMIT 1];
        System.runAs(portalUser) {
            String resource   = 'Partner Worker';
            String type       = 'Leave';
            Date   searchDate = Date.today().addDays(-5);

            Test.startTest();
            Map<String,Object> result = DN_PortalServiceController.getList(resource, type, searchDate, null);
            Test.stopTest();
        }
    }


    @isTest
    static void testResourceAbsenceInsert() {        
        User testUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalService' LIMIT 1];
        
        Asset asset = [SELECT Id, AccountId FROM Asset WHERE Name = 'ML0006-006231' LIMIT 1];
        System.runAs(testUser) {
            System.debug('asset ::: ' + asset);
            ServiceResource res = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :testUser.Id LIMIT 1];

            DN_PortalServiceController.Resource resource = new DN_PortalServiceController.Resource();
            resource.resourceId  = res.Id;
            resource.Type        = 'Leave';
            resource.startDate   = System.now().addDays(-10);
            resource.endDate     = System.now().addDays(-9);
            resource.description = 'TEST Description';
            resource.machineName        = 'test machineName';                        
            resource.equipmentText      = 'test equipmentText';                        
            resource.accountNameText    = 'test accountNameText';                            
            resource.accountAddress     = 'test accountAddress';      

            Test.startTest();       
            ResourceAbsence returnFalse = DN_PortalServiceController.resourceAbsenceInsert(resource, false);
            Test.stopTest();
        }
    }

    @isTest
    static void testResourceAbsenceUpdate() {        
        User testUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalService' LIMIT 1];
        
        System.runAs(testUser) {
            ServiceResource res = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :testUser.Id LIMIT 1];
            ResourceAbsence absence = [SELECT Id FROM ResourceAbsence WHERE ResourceId =:res.Id LIMIT 1];

            DN_PortalServiceController.Resource resource = new DN_PortalServiceController.Resource();
            resource.resourceId         = res.Id;
            resource.Type               = 'Leave';
            resource.startDate          = System.now().addDays(-5);
            resource.endDate            = System.now().addDays(-4);
            resource.description        = 'TEST Description Update';
            resource.accountNameText    = 'TEST Update Account';
            resource.equipmentText      = 'TEST Update Equipment';
            resource.id                 = absence.Id;

            Test.startTest();       
            ResourceAbsence returnFalse = DN_PortalServiceController.resourceAbsenceUpdate(resource, false);
            Test.stopTest();
        }
    }

    static testMethod void testResourceAbsenceDelete() {
        User testUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalService' LIMIT 1];
        
        System.runAs(testUser) {
            ServiceResource res = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :testUser.Id LIMIT 1];
            ResourceAbsence absence = [SELECT Id FROM ResourceAbsence WHERE ResourceId =:res.Id LIMIT 1];
            List<String> absenceList = new List<String>{absence.Id};
            Test.startTest();       
                DN_PortalServiceController.resourceAbsenceDelete(absenceList);
            Test.stopTest();
        }
    }

    static testMethod void testSearchHistorybyAsset() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portaluser@test.com.PortalService' LIMIT 1];

        System.runAs(portalUser) { 
            Date testStart = Date.today().addMonths(-1);
            Date testEnd = Date.today();

            DateTime startDatetime = DateTime.newInstance(testStart.year(), testStart.month(), testStart.day());
            DateTime endtDatetime = DateTime.newInstance(testEnd.year(), testEnd.month(), testEnd.day());
            String startDate = startDatetime.format('yyyy-MM-dd');
            String endDate = endtDatetime.format('yyyy-MM-dd');

            Map<String, Object> fieldMap = new Map<String, Object>{
                'machineName' => 'ML0006-006231',
                'assetName'   => 'LYNX 220A-NT',
                'startDate'   => startDate,
                'endDate'     => endDate
            };
            
            Test.startTest();
            Map<String, Object> resMap = DN_PortalServiceController.searchHistorybyAsset(fieldMap);
            Test.stopTest();
        }
    }
    
    static testMethod void testGetPicklistValues() {
        Test.startTest();
        Map<String, Object> resMap = DN_PortalServiceController.getpicklistValues();
        Test.stopTest();
        List<DN_PortalServiceController.PicklistWrapper> picklistValues =
            (List<DN_PortalServiceController.PicklistWrapper>) resMap.get('picklistValues');
    }

    // static testMethod void testDummyMethod() {
    //     Test.startTest();
    //     DN_PortalServiceController.dummy();
    //     Test.stopTest();
    // }
}