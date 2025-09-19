@isTest
public with sharing class TestDataFactoryForDealerPortal {

    public static String partDealerProfileName;
    public static String partProductRecordTypeName;

    public static Account dealer; // 대리점
    public static String dealerCustomerCode = '1218163602';
    public static Account dealer2; // 다른 대리점
    static {
        partDealerProfileName = 'DNS CS Parts_Partner';
        partProductRecordTypeName = 'Part';
        dealer = new Account(
            Name =' Test Dealer',
            RecordTypeId = getRecordType('Dealer', 'Account').Id,
            ShippingStreet = '서울특별시 용산구 한강대로 지하392 (동자동)연세브란스',
            ShippingCity ='Seongnam-si',
            ShippingPostalCode ='13494',
            ShippingCountry = 'South Korea',
            Phone = '01012345678',
            Fax = '02-123-4567',
            Email__c = 'TEst11@naver.com',
            SalesOrganization__c = '1846',
            CustomerCode__c = dealerCustomerCode
        );
        dealer2 = new Account(
            Name =' Test Dealer2',
            RecordTypeId = getRecordType('Dealer', 'Account').Id,
            ShippingStreet = '서울특별시 용산구 한강대로 지하392 (동자동)연세브란스',
            ShippingCity ='Seongnam-si',
            ShippingPostalCode ='13494',
            ShippingCountry = 'South Korea',
            Phone = '01012345555',
            Fax = '02-123-3333',
            Email__c = 'TEst22@naver.com',
            SalesOrganization__c = '1846'
        );
    }
    
    
    /* */
    public static RecordType getRecordType(String devName, String sObjName) {
        RecordType type = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType =: sObjName AND DeveloperName =:devName];
        return type;
    }

    public static Account createAccountDelear(String name) {
        return new Account(
            Name = name,
            RecordTypeId = getRecordType('Dealer', 'Account').Id,
            ShippingStreet = '서울특별시 용산구 한강대로 지하392 (동자동)연세브란스',
            ShippingCity ='Seongnam-si',
            ShippingPostalCode ='13494',
            ShippingCountry = 'South Korea',
            Phone = '01012345555',
            Fax = '02-123-3333',
            Email__c = 'TEst22@naver.com',
            SalesOrganization__c = '1846',
            SalesOffice__c = '1146'
        );
    }

    // accountId 가 있으면 대리점고객 없으면 일반고객
    public static DealerCustomer__c getCustomer(Id accountId) {
        DealerCustomer__c customer = new DealerCustomer__c(
            Name = 'test Customer',
            BusinessNumber__c = '1218163602',
            Representative__c =' Test 대표',
            CustomerCode__c = dealerCustomerCode,
            TypeOfBusiness__c = 'Manufacturing and Wholesale',
            DistributionChannel__c = '10',
            Division__c = '40',
            AccountNameEnglish__c = 'Test Dealer ENG',
            sggNm__c = '안성시',
            Phone__c = '123123123',
            PartManagerName__c = ' TEST ManageName',
            PartsManagerContact__c =' 1333333',
            TypeOfIndustry__c = '부품 도/소매업',
            IsDealer__c = false,
            IsActive__c = true,
            IsConvert__c = true
        );
        if(accountId != null) {
            customer.IsDealer__c = true;
            customer.SourceAccount__c = accountId;
        }else {
            customer.Dealer__c = dealer.Id;
        }
        return customer;
    }

    public static String getAdminProfileName() {
        return UserInfo.getLanguage() == 'ko' ? '시스템 관리자' : 'System Administrator';
    }

    public static User createTestAdminUser(String roleName) {
        return createTestUser(getAdminProfileName(), roleName);
    }

    public static User createTestPartPortalUser(Id contactId) {
        User partPortalUser = createTestUser(partDealerProfileName, null);
        partPortalUser.ContactId = contactId;
        return partPortalUser;
    }
    
    public static User createTestUser(String profileName, String roleName) {
        // Profile 조회
        List<Profile> profileList = [SELECT Id FROM Profile WHERE Name = :profileName ];
        Profile profile = profileList[0];

        // Role 설정 (Optional)
        Id roleId = null;
        if (roleName != null) {
            List<UserRole> roleList = [SELECT Id FROM UserRole WHERE DeveloperName = :roleName ];
            UserRole role = roleList[0];
            roleId = role != null ? role.Id : null;
        }

        // 테스트 User 생성
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser' + DateTime.now().getTime() + '@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US',
            UserRoleId = roleId
        );

        return testUser;
    }

    public static Contact createContact(Id accountId) {
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = accountId
        );
        return contact;
    }

    public static Product2 getPart(String productCode, String productNameEn, String productNameKo) {
        return new Product2(
            Name = productCode,
            ProductCode = productCode,
            MaterialDetailsKO__c = productNameKo,
            MaterialDetailsEN__c = productNameEn,
            RecordTypeId = getRecordType(partProductRecordTypeName, 'Product2').Id,
            Plant__c = '184S;1846'
        );
    }

    public static DealerLocation__c getLocation(String dealer) {
        return new DealerLocation__c(
            SourceSystem__c ='CRM',
            Description__c = 'test',
            Loc1__c = 'TESTABC11',
            Loc2__c = '11',
            Dealer__c = dealer,
            Division__c = '40',
            DistributionChannel__c = '10',
            SalesOrganization__c = '1846',
            IsConvert__c = false
        );
    }

    public static DealerStock__c createDealerStock(String dealer, String part) {
        return new DealerStock__c(
            SalesOrganization__c = '1846',
            DistributionChannel__c ='10',
            Division__c	='40',
            Dealer__c = dealer,
            Part__c = part
        );
    }

    public static DealerOrder__c getOrder(String dealer,String customer) {
        return new DealerOrder__c(
            OrderType__c='S',
            OrderNumber__c = 'TESTORDER',
            SalesOrganization__c = '1846',
            DistributionChannel__c ='10',
            Division__c	='40',
            CustomerPurchaseOrderNumber__c = 'TEST',
            Dealer__c = dealer,
            Customer__c = customer,
            BulkShipping__c ='N',
            Representative__c ='고객 담당자',
            ShippingType__c = '4',
            SourceSystem__c = 'CRM'
        );
    }

    public static DealerOrderItem__c getOrderItem(String order, String part, String replacingPart) {
        return new DealerOrderItem__c(
            Order__c = order,
            SourceSystem__c = 'CRM',
            OrderItemNumber__c ='000010',
            Part__c = part,
            ReplacingPart__c = replacingPart,
            Quantity__c = 1,
            AvailableQuantity__c =0,
            CurrentStockQuantity__c = 0,
            SaleQuantityUnit__c = 1,
            CustomerPrice__c = 152200,
            DiscountPrice__c = 152200,
            Delete__c = 'N'
        );
    }

    public static DealerReturnOrderItem__c createReturnOrderItem(String ordreItem) {
        return new DealerReturnOrderItem__c(
            SalesOrganization__c = '1846',
            DistributionChannel__c ='10',
            Division__c	='40',
            OrderItem__c = ordreItem
        );
    }

    public static DealerInventoryMovements__c createGI() {
        return new DealerInventoryMovements__c(
            SalesOrganization__c = '1846',
            DistributionChannel__c ='10',
            Division__c	='40',
            RecordTypeId = getRecordType('GoodsIssue', 'DealerInventoryMovements__c').Id
        );
    }

    /**MPPS Data */
    public static DealerPartMasterByMPPS__c getPartMasterByMpps(String part, String dealer) {
        return new DealerPartMasterByMPPS__c(
            Plant__c = '1846',
            ABCIndicator__c = 'Z',
            MRPType__c = 'VB',
            Part__c = part,
            IsPOListReview__c = true,
            Dealer__c = dealer
        );
    }

    public static MonthlyDemandSummaryByRegion__c getMonSumByRegion(String area,String part) {
        return new MonthlyDemandSummaryByRegion__c(
            Area__c = area,
            Part__c = part,
            AnalysisPeriodMonth__c = Datetime.now().format('yyyyMM'),
            Quantity__c  =1,
            ReplacementQuantitiy__c =1,
            Frequency__c =1
        );
    }

    public static AreaPartMasterByMPPS__c getAreaPartByMpps(String area, String part) {
        return new AreaPartMasterByMPPS__c(
            Area__c = area,
            Part__c = part,
            Plant__c = '1846',
            ABCIndicator__c = 'Z',
            MRPType__c = 'VB'
        );
    }
    
    public static DealerOrderSummary__c getDealerOrderSummary(String dealer,String part) {
        return new DealerOrderSummary__c(
            Dealer__c = dealer,
            Part__c = part,
            OrderQuantity__c = 1,
            CurrentQuantity__c =1,
            CreatedDateTime__c = Datetime.now()
        );
    }

    public static ProductByPlant__c getProductByPlant(String part, String lastPart) {
        return new ProductByPlant__c(
            Plant__c = '1846',
            Part__c = part,
            LastPart__c = lastPart,
            InterchangeabilityCode__c = 'I'
        );
    }

    public static DealerStock__c getStock(String part, String dealer) {
        return new DealerStock__c(
            Part__c = part,
            Dealer__c = dealer
        );
    }

    public static AreaByMPPS__c getAreaByMpps() {
        return new AreaByMPPS__c(
            Area__c ='A0'
        );
    }

    public static DealerAreaByMPPS__c getDealerAreaByMPPS(String dealer, String area) {
        return new DealerAreaByMPPS__c(
            Dealer__c = dealer,
            Area__c = area
        );
    }

    public static RegionAreaByMPPS__c getRegionAreaByMPPS(String area) {
        return new RegionAreaByMPPS__c(
            Region__c = '01',
            Area__c = area
        );
    }

    public static ZipRegionAreaByMPPS__c getZipRegionAreaByMPPS(String zipCode, String region) {
        return new ZipRegionAreaByMPPS__c(
            ZipCode__c = zipCode,
            Region__c = region
        );
    }

    public static DealerOrderSummary__c createDealerOrderSummary(String dealer, String orderItem, String part, String area) {
        String objectType = Id.valueOf(orderItem).getSobjectType().getDescribe().getName();

        DealerOrderSummary__c summary = new DealerOrderSummary__c(
            Address__PostalCode__s = '01',
            Area__c = area,
            Dealer__c = dealer,
            Part__c = part,
            Plant__c = '1846', 
            CreatedDateTime__c = System.now()
        );

        switch on objectType {
            when 'DealerOrderItem__c' {
                summary.DealerOrderItem__c = orderItem;
            }
            when 'ProductRequest' {
                summary.ServiceOrderItem__c = orderItem;
            }
        }

        return summary;
    }

    public static ABCCriteriaPeriod__c createCalculatePeriod() {
        return new ABCCriteriaPeriod__c(
            Plant__c = '1846',
            Period__c = 18
        );
    }

    public static ABCGradeFrequencyCriteria__c createGradeFrequencyCriteria(String grade, Double frequency, String targetId) {
        ABCGradeFrequencyCriteria__c frequencyCriteria = new ABCGradeFrequencyCriteria__c(
            Plant__c = '1846',
            Grade__c = grade,
            Frequency__c = frequency
        );
        String objectType = Id.valueOf(targetId).getSobjectType().getDescribe().getName();

        switch on objectType {
            when 'Account' {
                frequencyCriteria.Dealer__c = targetId;
            }
            when 'AreaByMPPS__c' {
                frequencyCriteria.Region__c = targetId;
            }
        }

        return frequencyCriteria;
    }

    public static ABCGradeAmountCriteria__c createGradeAmountCriteria(String grade, Double Rate, String targetId) {
        ABCGradeAmountCriteria__c amountCriteria = new ABCGradeAmountCriteria__c(
            Plant__c = '1846',
            Grade__c = grade,
            Rate__c = rate
        );
        String objectType = Id.valueOf(targetId).getSobjectType().getDescribe().getName();

        switch on objectType {
            when 'Account' {
                amountCriteria.Dealer__c = targetId;
            }
            when 'AreaByMPPS__c' {
                amountCriteria.Region__c = targetId;
            }
        }

        return amountCriteria;
    }

    public static ABCIndicatorMatrix__c createABCIndicatorMatrix(String amountGrade, String frequencyGrade, String abcIndicator) {
        return new ABCIndicatorMatrix__c(
            Plant__c = '1846',
            AmountGrade__c = amountGrade,
            FrequencyGrade__c = frequencyGrade,
            ABCIndicator__c = abcIndicator
        );
    }

    public static MonthlyDemandSummaryByDealer__c createMonthlySummaryByDealer(String analysisPeriod, String dealer, String part) {
        return new MonthlyDemandSummaryByDealer__c(
            Plant__c = '1846',
            CustomerPrice__c = 1000,
            AnalysisPeriodMonth__c = analysisPeriod,
            Dealer__c = dealer,
            Part__c = part
        );
    }

    public static MonthlyDemandSummaryByRegion__c createMonthlySummaryByRegion(String analysisPeriod, String area, String part) {
        return new MonthlyDemandSummaryByRegion__c(
            Plant__c = '1846',
            CustomerPrice__c = 1000,
            AnalysisPeriodMonth__c = analysisPeriod,
            Area__c = area,
            Part__c = part
        );
    }

    public static ABCGradeCalculationResult__c createABCGradeResult(ABCIndicatorMatrix__c abcIndicator, String amountGrade, String frquecyGrade, String part ,String targetId) {
        //ExternalKey__c =
        ABCGradeCalculationResult__c abcResult = new ABCGradeCalculationResult__c(
                Plant__c = '1846',
                ABCIndicator__r = abcIndicator,
                AmountGrade__c = amountGrade,
                FrequencyGrade__c = frquecyGrade,
                Part__c = part
        );
        String objectType = Id.valueOf(targetId).getSobjectType().getDescribe().getName();

        switch on objectType {
            when 'Account' {
                abcResult.Dealer__c = targetId;
            }
            when 'AreaByMPPS__c' {
                abcResult.Region__c = targetId;
            }
        }

        return abcResult;
    }
        

     /*  *interface */
     public static Interface__c createinterface(String ifName, String processingType){
        Interface__c ifc      = new Interface__c();
        ifc.Name              = ifName; // e.g.
        ifc.ProcessingType__c = processingType; // Real-Time, Batch
        ifc.Description__c    = 'test';
        ifc.IsActive__c       = true;
        ifc.HttpMethod__c     = 'POST';
        ifc.EndpointURL__c    = 'http://temp';
        ifc.System__c         = 'ERP';
        ifc.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
        ifc.Timeout__c        = 120000;
        return ifc;
    }

    public static InterfaceClasses__c createIFClass(String ifClasName, Id interfaceId){
        InterfaceClasses__c ifClass = new InterfaceClasses__c();
        ifClass.Name         = ifClasName; // e.g. IF_ERP_DELIV
        ifClass.Interface__c = interfaceId;
        return ifClass;
    }

    public static ContentVersion getContentVersion(String userId) {
        Blob fileBody = Blob.valueOf('Test file content');
        return new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.txt',
            VersionData = fileBody,
            FirstPublishLocationId = userId // 소유자 지정
        );
    }

    public static ContentDocumentLink getDocumentLink(String contentDocumentId, String linkedEntityId) {
        return new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = linkedEntityId, // 파일을 Account에 연결
            ShareType = 'V' // 'V' = View, 'C' = Collaborate, 'I' = Inferred
        );
    }
    
    public static ContentDistribution getContentDistribution(String contentVersionId) {
        return new ContentDistribution(
            Name = 'TestFile Share',
            ContentVersionId = contentVersionId,
            PreferencesAllowViewInBrowser = true,
            PreferencesAllowOriginalDownload = true
        );
    }

    public static DealerCustomerShipTo__c getCustomerShipTO(String DealerCustomerId) {
        return new DealerCustomerShipTo__c(
            Customer__c = DealerCustomerId,
            Address__Street__s = '서울특별시 용산구 한강대로 지하392 (동자동)연세브란스',
            Address__City__s = 'Seongnam-si',
            Address__PostalCode__s	 = '13494',
            Address__CountryCode__s = 'KR',
            RoadAddr__c = '서울특별시 용산구 한강대로 지하392 (동자동)연세브란스'
        );
    }

    public static PurchaseOrder__c getPurOrder(String dealer) {
        return new PurchaseOrder__c (
            PartOrderNo__c = '3001955256',
            CustomerOrderNo__c = 'Ring_TEST_YDOR_001',
            Supplier__c = 'DN Solutions	',
            Buyer__c = dealer,
            ShippingDestination__c = '고객사명(한글)',
            ShippingAddress__c = '24154 강원특별자치도 화천군 사내면 수피령로 73',
            //OrderType__c = 'YDOR',
            PaymentTerm__c ='CPBC',
            ShippingTerm__c = '내수 택배',
            ConsolidatedShipping__c = 'No',
            TransportationTermOne__c = 'EXW',
            TransportationTermTwo__c = '공장 인도 가격',
            PartManager__c = '고객사명(한글)한글',
            PartManagerMobilePhone__c = '010-222-5555',
            RequestedDeliveryDate__c = Date.today(),
            BuyerNo__c = 'C5000006',
            RecordTypeId = getRecordType('Order', 'PurchaseOrder__c').Id
        );
    }
    public static PurchaseOrder__c getPurOrderReturn(String dealer) {
        return new PurchaseOrder__c (
            PartOrderNo__c = '7100253175',
            CustomerOrderNo__c = 'Ring_TEST_YDOR_001',
            Supplier__c = 'DN Solutions	',
            Buyer__c = dealer,
            ShippingDestination__c = '고객사명(한글)',
            ShippingAddress__c = '24154 강원특별자치도 화천군 사내면 수피령로 73',
            //OrderType__c = 'YDOR',
            PaymentTerm__c ='CPBC',
            ShippingTerm__c = '내수 택배',
            ConsolidatedShipping__c = 'No',
            TransportationTermOne__c = 'EXW',
            TransportationTermTwo__c = '공장 인도 가격',
            PartManager__c = '고객사명(한글)한글',
            PartManagerMobilePhone__c = '010-222-5555',
            RequestedDeliveryDate__c = Date.today(),
            BuyerNo__c = 'C5000006',
            RecordTypeId = getRecordType('ReturnOrder', 'PurchaseOrder__c').Id
        );
    }



    public static PurchaseOrderItems__c getPurOrderItem(String order, String product){
        return new PurchaseOrderItems__c(
            OrderPartNo__c = 'R18181',
            SupplyPartNo__c = 'R18182',
            PartName__c = 'CENTER,LIVE',
            Unit__c = 'EA',
            MachineName__c = 'ACE V40',
            Quantity__c = 1,
            UnitPrice__c = 213200,
            EquipmentNo__c = 'AV40-0006',
            ItemNo__c = '000001',
            OrderPartId__c = product,
            DepartureSite__c = 'DNS 부품 창원창고 출하처',
            ExpectedSupplyDate__c = Date.today(),
            PurchaseOrder__c = order
        );
    }

    public static DealerInventoryMovements__c getGoodsIssue(String dealer, String product) {
        return new DealerInventoryMovements__c(
            InventoryItemNumber__c ='00010',
            SalesOrganization__c = '1846',
            DistributionChannel__c = '10',
            Division__c = '40',
            Dealer__c = dealer,
            InventoryChange__c = 'S',
            Part__c = product,
            Quantity__c = 1,
            CustomerPrice__c = 275100,
            DiscountPrice__c = 275100,
            DiscountAmount__c = 2751000,
            RecordTypeId = getRecordType('GoodsIssue', 'DealerInventoryMovements__c').Id
        );
    }

    public static DealerInventoryMovements__c getGoodsReceipt(String dealer, String product) {
        return new DealerInventoryMovements__c(
            InventoryItemNumber__c ='00010',
            SalesOrganization__c = '1846',
            DistributionChannel__c = '10',
            Division__c = '40',
            Dealer__c = dealer,
            InventoryChange__c = 'S',
            Part__c = product,
            Quantity__c = 1,
            CustomerPrice__c = 275100,
            DiscountPrice__c = 275100,
            DiscountAmount__c = 2751000,
            RecordTypeId = getRecordType('GoodsReceipt', 'DealerInventoryMovements__c').Id
        );
    }

    public static DealerPurchaseOrder__c getDealerPur(String dealer, String customer) {
        return new DealerPurchaseOrder__c(
            SalesOrganization__c = '1846',
            DistributionChannel__c = '10',
            Division__c = '40',
            CustomerPurchaseOrderNumber__c = 'Test1234',
            Dealer__c = dealer,
            Customer__c = customer
        );
    }

    public static DealerPurchaseOrderItem__c getDealerPurItem(String dealerPurOrder, String part, String repPart) {
        return new DealerPurchaseOrderItem__c(
            DealerPurchaseOrder__c = dealerPurOrder,
            Part__c = part,
            ReplacingPart__c = repPart,
            Quantity__c = 1,
            SaleQuantityUnit__c = 1,
            CustomerPrice__c = 5900,
            DiscountPrice__c = 4720,
            Delete__c = 'N'
        );
    }

    public static Sequence__c getSequence(String name,String obj,String type,String pattern) {
        return new Sequence__c(
            Name = name,
            Type__c = type,
            Pattern__c = pattern,
            SObjectAPI__c = obj,
            StartNumber__c = 1
        );
    }

    public static ShipmentOrder__c getShipmentOrder(String dealer, String order) {
        return new ShipmentOrder__c(
            SalesOrganization__c ='1846',
            DistributionChannel__c = '10',
            Division__c ='40',
            Dealer__c = dealer,
            Quantity__c = 1,
            CustomerPrice__c = 275100,
            DiscountPrice__c = 137550,
            DiscountAmount__c = 275100,
            DealerOrderItem__c = order
        );
    }

    //무상부품
    public static Asset createEquipment(String accountId) {
        return new Asset(
            Name           = 'ML0006-006231',
            MachineName__c = 'LYNX 220A-NT',
            Material__c    = 'L22ANT-F0TP-0-K30',
            SerialNumber   = 'ML0006-006231',
            Status         = 'AVLB',
            AccountId      = accountId,
            SoldTo__c      = accountId,
            NCType__c      = 'TEST'
        );
    }

    public static Case createCase(String equipmentId) {
        return new Case(
            TicketType__c         = 'Technical inquiry',
            InternalTicketType__c = 'Failure receipt',
            Status                = 'Uncompleted',
            RecordTypeId          = getRecordType('Ticket_Domestic', 'Case').Id,
            AssetId               = equipmentId,
            isAlarmToCustomer__c  = false
        );
    }

    public static OperatingHours createOperatingHours() {
        return new OperatingHours(
            Name = '대한민국 표준 작업 시간',
            TimeZone = 'Asia/Seoul'
        );
    }

    public static ServiceTerritory createWorkCenter(String dealerId, String operatingHourId) {
        return new ServiceTerritory(
            Name = 'Test Account dw3',
            ServiceWorkCenter__c = dealerId,
            OperatingHoursId = operatingHourId,
            IsActive = true
        );
    }

    public static ServiceResource createServiceWorker(String portalUserId, String workcenterId) {
        return new ServiceResource(
            Name = 'Partner Worker',
            CurrentStatus__c = 'Wait',
            RelatedRecordId = portalUserId,
            IsActive = true,
            Service_Territory__c = workcenterId,
            Branch__c = 'DNS'
        );
    }

    public static WorkOrder createServiceOrder(String ticketId, String equipmentId, String accountId, String workCenterId, String workId) {
        return new WorkOrder(
            CaseId = ticketId,
            AssetId = equipmentId,
            AccountId = accountId,
            SoldTo__c = accountId,
            ServiceTerritoryId = workCenterId,
            Worker__c = workId,
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
    }

    public static ProductRequest createPartClaim(String serviceOrderId, String partId) {
        return new ProductRequest(
            WorkOrderId = serviceOrderId,
            Product__c = partId,
            Quantity__c = 2
        );
    }

    public static DealerFreeDispatch__c createFreeClaim(String claimId, String dealerId) {
        return new DealerFreeDispatch__c(
            OrderItem__c = claimId,
            Dealer__c = dealerId
        );
    }

    public static ROPAndStockFactorConfig__c createRopConfig(String dealer){
        return new ROPAndStockFactorConfig__c(
            Plant__c = '1846',
            ABCIndicator__c = 'A',
            PriceFrom__c = 0,
            PriceTo__c = 2000,
            Weight__c = 5,
            DemandPeriod__c =18,
            RecordTypeId = getRecordType('AreaMaxStockWeightingFactor', 'ROPAndStockFactorConfig__c').Id
        );
    }

    public static ROPAndStockFactorConfig__c createAreaRopCalculation(){
        return new ROPAndStockFactorConfig__c(
            Plant__c = '1846',
            ABCIndicator__c = 'A',
            TargetServiceLevel__c = 96,
            SVCFactor__c = 1.75,
            AMDType__c = 'W.AMD',
            DemandPeriod__c = 18,
            AreaCode__c = 'A0',
            AddSFTFlag__c = 'X',
            ApplyMaxFlag__c = 'X',
            RecordTypeId = getRecordType('AreaROPCalculationFactorConfiguration', 'ROPAndStockFactorConfig__c').Id
        );
    }

    public static DealerLeadTimeManagement__c createLeadTime(String part) {
        return new DealerLeadTimeManagement__c(
            Plant__c = '1846',
            Part__c = part,
            PlannedDeliveryDays__c = 15
        );
    }

    public static MonthlyDemandSummaryByDealer__c createMonDemSumByDealer(String part, String dealer) {
        return new MonthlyDemandSummaryByDealer__c(
            Part__c = part,
            AnalysisPeriodMonth__c = Datetime.now().format('yyyyMM'),
            Quantity__c  =1,
            ReplacementQuantitiy__c =1,
            Frequency__c =1,
            Dealer__c = dealer
        );
    }


    public static void assignFLSPermissionSet(String portalUserId) {
        PermissionSetAssignment psaResource = new PermissionSetAssignment(
                AssigneeId = portalUserId,
                PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'FSL_Resource_Permissions' LIMIT 1].Id
        );
        insert psaResource;
    }

    public static PricebookEntry createPriceBookEntry(Product2 prod, String curr) {
        Id pBookId = Test.getStandardPricebookId();

        PricebookEntry entry  = new PricebookEntry();
        entry.Pricebook2Id    = pBookId;
        entry.Product2Id      = prod.Id;
        entry.CurrencyIsoCode = curr;
        entry.UnitPrice       = 0;
        entry.IsActive        = true;

        return entry;
    }

    /*  *opportunity info  */
    public static Opportunity createDNSDomesticOpty(Account acc, User owner, String optyType){
        RecordType type  = getRecordType(optyType, 'Opportunity');
        Id pBookId = Test.getStandardPricebookId();

        Date today = Date.today();
        System.debug('owner : ' + owner);
        Opportunity opty             = new Opportunity();
        opty.AccountId               = acc.Id;
        opty.RecordTypeId            = type.Id;
        opty.Name                    = 'test opportunity';
        opty.StageName               = 'Identified';
        opty.LeadSource              = 'Employee Referral';
        opty.CurrencyIsoCode         = 'KRW';
        opty.Pricebook2Id            = pBookId;
        opty.OwnerId                 = owner.Id;
        opty.MainCategory__c         = 'MB';
        opty.SubCategory__c          = 'MB2';
        opty.IsTooling__c            = 'MY';
        opty.Country__c              = 'KR';
        opty.Budget__c               = 100000000;
        opty.RequestDelieveryDate__c = today.addMonths(2);
        opty.CloseDate               = today.addMonths(1);
        opty.OpportunityIdentifier__c = owner.Id;
        opty.Opportunity_Owner__c    = owner.Id;

        return opty;
    }

    public static OpportunityLineItem createOptyItem(Opportunity opty, PricebookEntry entry, Product2 prod) {

        OpportunityLineItem oItem = new OpportunityLineItem();
        oItem.OpportunityId       = opty.Id;
        oItem.PricebookEntryId    = entry.Id;
        oItem.Product2Id          = prod.Id;
        oITem.Quantity            = 1;
        oItem.UnitPrice           = 0;
        return oItem;
    }

    /*  *Quote info  */
    public static Quote createDNSDomesticQuote(User owner, Opportunity opty, String quoteType) {
        RecordType type  = getRecordType(quoteType, 'Quote');
        Id pBookId = Test.getStandardPricebookId();

        Quote quote                 = new Quote();
        quote.Name                  = 'test quote_Quote_V1';
        quote.RecordTypeId          = type.Id;
        quote.OpportunityId         = opty.Id;
        quote.Pricebook2Id          = pBookId;
        quote.Incoterms__c          = 'Y03';
        quote.ExpectedDelivDate__c  = '계약 후 5개월 내';
        quote.TermsOfPayment__c     = 'C001';
        quote.CurrencyIsoCode       = 'KRW';
        quote.Tax                   = 1234;

        return quote;
    }

    /*  *order info  */
    public static Order createDNSDomesticOrder(Account acc, Opportunity opty, Quote quote, User owner, String orderType){
        RecordType type  = getRecordType(orderType, 'Order');
        Id pBookId = Test.getStandardPricebookId();

        Date today = Date.today();

        Order order                  = new Order();
        order.AccountId              = acc.Id;
        order.Pricebook2Id           = pBookId;
        order.OpportunityId          = opty.Id;
        order.QuoteId                = quote.Id;
        order.RecordTypeId           = type.Id;
        order.EffectiveDate          = today;
        order.Status                 = 'Created';
        order.CurrencyIsoCode        = quote.CurrencyIsoCode;
        order.OrderType__c           = 'ZPO';
        order.ReqDeliveryDate__c     = today.addMonths(2);
        order.PurchaseType__c        = 'Z1';
        order.SalesChannelType__c    = 'DomesticPartner';
        order.OrderSegmentation__c   = 'Wholesale';
        order.Country__c             = 'KR';
        
        order.PaymentTerms__c        = 'C001';
        order.Incoterms__c           = 'Y03';
        order.ShippingConditions__c  = '10';
        order.Warranty__c            = 'B1D';

        order.EndUser__c             = 'test';
        order.Contractor__c          = 'test';
        order.MainCategory__c        = 'MB';
        order.SubCategory__c         = 'MB2';
        order.IsTooling__c           = 'MY';

        order.OwnerId                = owner.Id;
        order.SalesRep__c            = owner.AccountId;
        order.ServiceDealer__c       = owner.AccountId;
        order.CreditDealer__c        = owner.AccountId;

        order.BillTo__c              = acc.Id;
        order.ShipTo__c              = acc.Id;
        order.Payer__c               = acc.Id;
        order.SoldTo__c              = acc.Id;

        order.DistributionChannel__c = '10';
        order.Division__c            = '40';
        order.SalesDistrict__c       = 'A1KR';
        order.SalesOrganization__c   = '1800';
        return order;
    }
}