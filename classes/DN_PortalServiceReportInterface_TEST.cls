/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 05-23-2025
 * @last modified by  : Chungwoo Lee
**/
@isTest
public with sharing class DN_PortalServiceReportInterface_TEST {

    private static final Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
    private static final Id dealerRT        = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id conDealerRT     = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    @TestSetup
    static void makeData() {
        RecordType ticketCaseRT = TestDataFactoryForSales.getRecordType('Ticket_Domestic', 'Case');
        RecordType productPartRT = TestDataFactoryForSales.getRecordType('Part', 'Product2');
        Integer currentYear = Date.today().year();

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
            OwnerId             = adminUser.Id,
            sggNm__c            = '서울특별시 용산구'
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
                Email             = 'portaluser@test.com.portalServiceReportInterface',
                Username          = 'portaluser@test.com.portalServiceReportInterface',
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
            ass.WarrantyStartDateWages__c = Date.newInstance(currentYear, 1, 1);
            ass.WarrantyEndWages__c = Date.newInstance(currentYear, 12, 31);
            ass.WarrantyStartDate__c = Date.newInstance(currentYear - 1, 1, 1);
            ass.WarrantyEnd__c = Date.newInstance(currentYear - 1, 12, 31);
            insert ass;

            Case cs = new Case();
            cs.FailureAreaValue__c          = '4R0';
            cs.FailureAreaDetailValue__c    = '001';
            cs.FailureArea__c               = '001';
            cs.FailureAreaDetail__c         = 'CNC System';
            cs.FailurePhenomenonValue__c    = '01';
            cs.FailurePhenomenon__c         = '작동 불량량';
            cs.TicketType__c                = 'Technical inquiry';
            cs.InternalTicketType__c        = 'Failure receipt';
            cs.Status                       = 'Uncompleted';
            cs.RecordTypeId                 = ticketCaseRT.Id;
            cs.AssetId                      = ass.Id;
            cs.OwnerId                      = portalUser.Id;
            cs.isAlarmToCustomer__c         = false;
            insert cs;
        } 

        AssignmentRule__c assignmentRule = new AssignmentRule__c(Name = '기술상담사 순차배정');
        insert assignmentRule;

        Product2 prod = new Product2();
        prod.Name = 'ESWSL0132';
        prod.ProductCode = 'ESWSL0132';
        prod.IsActive = true;
        prod.CurrencyIsoCode = 'KRW';
        prod.RecordTypeId = productPartRT.Id;
        prod.Plant__c = '184S;414S;1846;4146';
        prod.put('Unit__c', 'EA');
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
                isAlarmToStaff__c = false,
                FailurePhenomenonDetail__c = '줄바꿈 \n 테스트',
                CauseOfFailureDetail__c = '줄바꿈 \n 테스트',
                PendingOrCustomerMatters__c = '줄바꿈 \n 테스트',
                ReceptionDetail__c = '줄바꿈 \n 테스트'
            );
            insert woWithPR;
            woWithPRId = woWithPR.Id; 

            System.debug('test ::: ' + JSON.serialize(woWithPR));

            Collaborator__c cbr = new Collaborator__c( WorkOrder__c = woWithPRId);
            insert cbr;

            WorkOrderResult__c worCom = new WorkOrderResult__c(resultType__c = 'COM', WorkOrder__c = woWithPR.Id, ReadinessStatus__c = 'ZELEC;ZLUB;ZHYD;ZPNEU;ZLAYOUT;ZFOUND');
            insert worCom;

            WorkOrderResult__c worWH = new WorkOrderResult__c(resultType__c = 'WH', WorkOrder__c = woWithPR.Id);
            insert worWH;

            WorkOrderResult__c worITD = new WorkOrderResult__c(resultType__c = 'ITD', WorkOrder__c = woWithPR.Id);
            insert worITD;

            WorkOrderResult__c worPT = new WorkOrderResult__c(resultType__c = 'PT', WorkOrder__c = woWithPR.Id);
            insert worPT;
        }

        // WorkOrder와 연결된 ContentVersion 및 ContentDocumentLink 생성
        ContentVersion cvReport = new ContentVersion(
            Title = 'ReportFile', 
            PathOnClient = 'ReportFile.html',
            VersionData = Blob.valueOf('Report content'),
            IsMajorVersion = true,
            DealerPotalFileType__c = 'report' 
        );
        insert cvReport;

        ContentVersion cvInfo = new ContentVersion(
            Title = 'InfoFile',
            PathOnClient = 'InfoFile.html',
            VersionData = Blob.valueOf('Info content'),
            IsMajorVersion = true,
            DealerPotalFileType__c = '' 
        );
        insert cvInfo;
        
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();

        for (ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title IN ('ReportFile', 'InfoFile')]) {
            docLinks.add(new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId = woWithPRId,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ));
        }
        insert docLinks;

        ProductRequest preq = new ProductRequest();
        preq.WorkOrderId = woWithPRId;
        preq.Product__c = prod.Id;
        preq.IsCause__c = true;
        preq.SupplyType__c = '';
        preq.SAPPartsPrice__c = 100.50;
        preq.ReturnStatus__c = 'Y';
        preq.SAPItemCategory__c = '';
        preq.ReturnType__c = '1';
        preq.DeliveryCompleted__c   = 2;  
        preq.Quantity__c = 2;
        preq.Seq__c = '0001';
        preq.ShippingCheck__c = 'N';
        preq.Reason1__c = 'A';
        preq.Reason2__c = 'A01';
        preq.ReturnNote__c = 'Return Note Example';
        preq.Status                 = 'Approved';
        insert preq;
    }

    @IsTest
    static void testInterfaceCall015() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-015', 'IF_ERP_WorkOrder');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_WorkOrder_Test.IF_CSPLUS_015_HttpMock());

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        Map<String, Object> res = (new DN_PortalServiceReportInterface()).interfaceCall015(wo.Id, false);
        Test.stopTest();

        System.debug('interfaceCall015 result ::: ' + JSON.serialize(res));
    }

    @IsTest
    static void testInterfaceCall054() {
        InterfaceCommonUtil.setInterface('IF-SERVICE-054', 'IF_ERP_Service_Report');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_Report_Test.IF_SERVICE_054_HttpMock());

        WorkOrder wo = [SELECT Id, OrderType__c FROM WorkOrder LIMIT 1];

        Test.startTest();
        IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res res = (new DN_PortalServiceReportInterface()).interfaceCall054(wo.Id, 'RT05');
        Test.stopTest();

        System.debug('interfaceCall054 result ::: ' + JSON.serialize(res));
    }

    @IsTest
    static void testInterfaceCall025() {
        InterfaceCommonUtil.setInterface('IF-PARTS-025', 'IF_ERP_DeliveryTraining');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_DeliveryTraining_Test.IF_PARTS_025_HttpMock());

        List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE Title = 'InfoFile' LIMIT 1];
        List<String> convertVersionIdList = new List<String>();
        for(ContentVersion cv : cvList) {
            convertVersionIdList.add(cv.Id);
        }


        List<Map<String, String>> docMapList = new List<Map<String, String>>();
        Map<String, String> docMap = new Map<String, String>{
            'erpDocNo' => 'DOC123456'
        };
        docMapList.add(docMap);

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res res = (new DN_PortalServiceReportInterface()).interfaceCall025(wo.Id, true, docMapList, convertVersionIdList);
        Test.stopTest();

        System.debug('interfaceCall046 result ::: ' + JSON.serialize(res));
    }

    @IsTest
    static void testInterfaceCall045() {
        InterfaceCommonUtil.setInterface('IF-SERVICE-045', 'IF_ERP_Service_InstAndComm');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_InstAndComm_Test.IF_SERVICE_045_HttpMock());

        List<ContentVersion> cvList = [SELECT Id FROM ContentVersion WHERE Title = 'InfoFile' LIMIT 1];
        List<String> convertVersionIdList = new List<String>();
        for(ContentVersion cv : cvList) {
            convertVersionIdList.add(cv.Id);
        }


        List<Map<String, String>> docMapList = new List<Map<String, String>>();
        Map<String, String> docMap = new Map<String, String>{
            'erpDocNo' => 'DOC123456'
        };
        docMapList.add(docMap);

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res res = (new DN_PortalServiceReportInterface()).interfaceCall045(wo.Id, true, docMapList, convertVersionIdList);
        Test.stopTest();

        System.debug('interfaceCall045 result ::: ' + JSON.serialize(res));

        List<Map<String, Object>> fileMapList = DN_PortalServiceReportInterface.getConvertFile(convertVersionIdList, '', '');

        System.debug('Test File Check ::: ' + JSON.serialize(fileMapList));
    }


    @IsTest
    static void testInterfaceCall046() {
        InterfaceCommonUtil.setInterface('IF-SERVICE-046', 'IF_ERP_Service_ServRepInput');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_ServRepInput_Test.IF_SERVICE_046_HttpMock());

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        List<Map<String, String>> docMapList = new List<Map<String, String>>{
            new Map<String, String>{
                'erpDocNo' => 'DOC123456',
                'reportType' => 'report'
            },
            new Map<String, String>{
                'erpDocNo' => 'DOC654321',
                'reportType' => ''
            }
        };
        
        List<ContentVersion> testCVs = [ SELECT Id FROM ContentVersion WHERE Title IN ('ReportFile', 'InfoFile') LIMIT 2 ];
        List<String> convertVersionIdList = new List<String>();
        
        for (ContentVersion cv : testCVs) {
            convertVersionIdList.add(cv.Id);
        }
        
        Test.startTest();
        Map<String, Object> res = (new DN_PortalServiceReportInterface()).interfaceCall046(wo.Id, false, docMapList, convertVersionIdList);
        Test.stopTest();

        System.debug('interfaceCall046 result ::: ' + JSON.serialize(res));
    }

    @IsTest
    static void testInterfaceCall050() {
        InterfaceCommonUtil.setInterface('IF-SERVICE-050', 'IF_ERP_Service_Report');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Service_Report_Test.IF_SERVICE_050_HttpMock());

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        
        Test.startTest();
        IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res res = (new DN_PortalServiceReportInterface()).interfaceCall050(wo.Id, true);
        Test.stopTest();

        System.debug('interfaceCall050 result ::: ' + JSON.serialize(res));
    }

    @IsTest
    static void testInterfaceCall044() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-044', 'IF_ERP_SalesOrder');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_SalesOrder_Test.IF_CSPLUS_044_HttpMock());

        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        List<Map<String, String>> docMapList = new List<Map<String, String>>{
            new Map<String, String>{
                'erpDocNo' => 'DOC123456',
                'reportType' => 'report'
            },
            new Map<String, String>{
                'erpDocNo' => 'DOC654321',
                'reportType' => ''
            }
        };
        
        List<ContentVersion> testCVs = [ SELECT Id FROM ContentVersion WHERE Title IN ('ReportFile', 'InfoFile') LIMIT 2 ];
        List<String> convertVersionIdList = new List<String>();
        
        for (ContentVersion cv : testCVs) {
            convertVersionIdList.add(cv.Id);
        }
        
        Test.startTest();
        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res res = (new DN_PortalServiceReportInterface()).interfaceCall044(wo.Id, true, docMapList, convertVersionIdList);
        Test.stopTest();

        System.debug('interfaceCall044 result ::: ' + JSON.serialize(res));
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
        List<Map<String, Object>> fileTable = DN_PortalServiceReportInterface.getConvertFile(convertVersionIdList, '', '');
        Test.stopTest();
        
        System.debug('fileTable ::: ' + JSON.serialize(fileTable));
    }
}