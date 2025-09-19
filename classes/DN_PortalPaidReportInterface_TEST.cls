/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 05-13-2025
 * @last modified by  : Chungwoo Lee
**/
@IsTest
public class DN_PortalPaidReportInterface_TEST {

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
                Email             = 'portaluser@test.com.PortalPaidReportInterface',
                Username          = 'portaluser@test.com.PortalPaidReportInterface',
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
            cs.FailureAreaValue__c          = '4R0';
            cs.FailureAreaDetailValue__c    = '001';
            cs.FailureArea__c               = '001';
            cs.FailureAreaDetail__c         = 'CNC System';
            cs.FailurePhenomenonValue__c    = '01';
            cs.FailurePhenomenon__c         = '작동 불량';
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

        Product2 prod = new Product2();
        prod.Name = 'ESWSL0132';
        prod.ProductCode = 'ESWSL0132';
        prod.IsActive = true;
        prod.CurrencyIsoCode = 'KRW';
        prod.RecordTypeId = productPartRT.Id;
        prod.Plant__c = '184S;414S;1846;4146;1840;1842;4140';
        prod.put('Unit__c', 'EA');
        insert prod;
        
        Id woWithPRId; 

        System.runAs(portalUser) {
            Asset assetForUser = [SELECT Id FROM Asset WHERE Name = 'ML0006-006231' LIMIT 1];
            Case caseForUser = [SELECT Id, TicketType__c FROM Case WHERE TicketType__c = 'Technical inquiry' LIMIT 1];
            ServiceResource sr = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :portalUser.Id LIMIT 1];
            ServiceTerritory wc = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Test Account dw3' LIMIT 1];

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

            WorkOrderResult__c worCom = new WorkOrderResult__c(resultType__c = 'COM', WorkOrder__c = woWithPR.Id);
            insert worCom;

            WorkOrderResult__c worWH = new WorkOrderResult__c(resultType__c = 'WH', WorkOrder__c = woWithPR.Id);
            insert worWH;

            WorkOrderResult__c worPT = new WorkOrderResult__c(resultType__c = 'PT', WorkOrder__c = woWithPR.Id);
            insert worPT;
        }

        // WorkOrder와 연결된 ContentVersion 및 ContentDocumentLink 생성
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true,
            DealerPotalFileType__c = ''
        );
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = woWithPRId,
            ShareType = 'V', 
            Visibility = 'AllUsers'
        );
        insert cdl;

        // ProductRequest preq = new ProductRequest(WorkOrderId = woWithPRId, Product__c = prod.Id);
        // insert preq;
    }

    @IsTest
    static void testInterfaceCall049() {
        InterfaceCommonUtil.setInterface('IF-SERVICE-049', 'IF_ERP_Service_Report');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_CostAdjustment_Test.IF_SERVICE_043_HttpMock());

        List<String> convertVersionIdList = new List<String>();

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res res = (new DN_PortalPaidReportInterface()).interfaceCall049(wo.Id, true, convertVersionIdList);
        Test.stopTest();

        System.debug('interfaceCall049 result: ' + JSON.serialize(res));
    }

    @IsTest
    static void testGetConvertFile_WithData() {
        // 생성된 ContentVersion Id를 포함한 리스트를 준비
        List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE Title = 'TestFile' LIMIT 1];
        List<String> convertVersionIdList = new List<String>();
        if(!cvList.isEmpty()){
            convertVersionIdList.add(cvList[0].Id);
        }
        
        Test.startTest();
        List<Map<String, Object>> fileTable = DN_PortalPaidReportInterface.getConvertFile(convertVersionIdList);
        Test.stopTest();
        
        System.debug('fileTable: ' + JSON.serialize(fileTable));
    }
}