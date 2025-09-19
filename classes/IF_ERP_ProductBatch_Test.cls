/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 07-28-2025
 * @last modified by  : JangJunHee
**/
@isTest
public with sharing class IF_ERP_ProductBatch_Test {
    public IF_ERP_ProductBatch_Test() {}

    @testSetup
    static void setupTestData() {
        // // Pricebook 생성
        // Pricebook2 standardPb = new Pricebook2(Name='Standard Pricebook', IsStandard=true, IsActive=true);
        // insert standardPb;
        String pbId = Test.getStandardPricebookId();

        // Model__c 생성
        Model__c testModel = new Model__c(
            MaterialCode__c = 'TESTMATNR001',
            Name = 'TestModel',
            NameEN__c = 'Test Model EN',
            Name__c = 'Test Model',
            Unit__c = 'PCS',
            Weight__c = 100.0,
            WeightUnit__c = 'KG',
            MaterialGroupCode__c = 'MATGRP001',
            MaterialGroupName__c = 'Test Material Group'
        );
        insert testModel;

        // Product2 생성
        Product2 testProduct = new Product2(
            Name = 'TestProduct',
            ERP_Key__c = 'TESTMATNR001',
            ProductCode = 'TESTMATNR001',
            NameEN__c = 'Test Product EN',
            Name__c = 'Test Product',
            Unit__c = 'PCS',
            Weight__c = 200.0,
            WeightUnit__c = 'KG',
            MaterialGroupCode__c = 'MATGRP001',
            MaterialGroupName__c = 'Test Material Group'
        );
        insert testProduct;

        // PricebookEntry 생성
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = testProduct.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 10.0,
            IsActive = true
        );
        insert pbe;
    }

/* Test Method
    */
    @isTest
    private static void IF_ERP_ProductBatch_Test () {
        InterfaceCommonUtil.setInterface('IF-OPTY-002', 'IF_ERP_Product');
        Test.startTest();

        IF_ERP_Product_Classes.IF_OPTY_002_Req req = new IF_ERP_Product_Classes.IF_OPTY_002_Req();
        req.I_EDATE = '2025-02-08';
        req.I_SDATE = '2025-02-01';

        IF_ERP_ProductBatch batch = new IF_ERP_ProductBatch();
        batch.req = req;
        Database.executeBatch(batch);

        Test.stopTest();
    }
    @isTest
    private static void IF_ERP_ProductBatchForPermittedItem_Test () {
        InterfaceCommonUtil.setInterface('IF-OPTY-030', 'IF_ERP_Product');
        Test.startTest();

        IF_ERP_Product_Classes.IF_OPTY_030_Req req = new IF_ERP_Product_Classes.IF_OPTY_030_Req();
        req.I_FROM = '2025-02-01';
        req.I_TO = '2025-02-08';
        
        IF_ERP_ProductBatchForPermittedItem batch = new IF_ERP_ProductBatchForPermittedItem();
        batch.req = req;
        Database.executeBatch(batch);

        Test.stopTest();
    }
    @isTest
    private static void IF_ERP_ProductBatchForRegionBaseCode_Test () {
        InterfaceCommonUtil.setInterface('IF-OPTY-032', 'IF_ERP_Product');
        Test.startTest();

        IF_ERP_Product_Classes.IF_OPTY_032_Req req = new IF_ERP_Product_Classes.IF_OPTY_032_Req();
        req.I_EDATE = '2025-02-08';
        req.I_SDATE = '2025-02-01';
        
        IF_ERP_ProductBatchForRegionBaseCode batch = new IF_ERP_ProductBatchForRegionBaseCode(req);
        Database.executeBatch(batch);

        Test.stopTest();
    }
    @isTest
    private static void IF_ERP_ProductBatchForDealerBaseCode_Test () {
        InterfaceCommonUtil.setInterface('IF-OPTY-029', 'IF_ERP_Product');
        Test.startTest();

        IF_ERP_Product_Classes.IF_OPTY_029_Req req = new IF_ERP_Product_Classes.IF_OPTY_029_Req();
        req.I_FROM_DAT = '2025-02-08';
        req.I_TO_DAT = '2025-02-01';
        
        IF_ERP_ProductBatchForDealerBaseCode batch = new IF_ERP_ProductBatchForDealerBaseCode(req);
        Database.executeBatch(batch);

        Test.stopTest();
    }
    @isTest
    private static void IF_ERP_ProductBatchForDNSAModel_Test () {
        InterfaceCommonUtil.setInterface('IF-OPTY-033', 'IF_ERP_SalesOrder');
        Test.startTest();

        IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req req = new IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req();
        req.I_FROM  = '2025-02-01';
        req.I_TO    = '2025-02-04';
        
        IF_ERP_ProductBatchForDNSAModel batch = new IF_ERP_ProductBatchForDNSAModel();
        batch.req = req;
        Database.executeBatch(batch);

        Test.stopTest();
    }
    @isTest
    static void DN_UpdateProductFromERPBatch_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-002', 'IF_ERP_Product');

        String pbId = Test.getStandardPricebookId();

        // Model__c 생성
        Model__c testModel = new Model__c(
            MaterialCode__c = 'TESTMATNR001',
            Name = 'TestModel',
            NameEN__c = 'Test Model EN',
            Name__c = 'Test Model',
            Unit__c = 'PCS',
            Weight__c = 100.0,
            WeightUnit__c = 'KG',
            MaterialGroupCode__c = 'MATGRP001',
            MaterialGroupName__c = 'Test Material Group'
        );
        insert testModel;

        // Product2 생성
        Product2 testProduct = new Product2(
            Name = 'TestProduct',
            ERP_Key__c = 'TESTMATNR001',
            ProductCode = 'TESTMATNR001',
            NameEN__c = 'Test Product EN',
            Name__c = 'Test Product',
            Unit__c = 'PCS',
            Weight__c = 200.0,
            WeightUnit__c = 'KG',
            MaterialGroupCode__c = 'MATGRP001',
            MaterialGroupName__c = 'Test Material Group'
        );
        insert testProduct;

        // PricebookEntry 생성
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = testProduct.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 10.0,
            IsActive = true
        );
        insert pbe;

        // IF_Product__c 데이터 생성
        IF_Product__c ifPrd1 = new IF_Product__c(
            MATNR__c = 'TESTMATNR001',
            SATNR__c = 'TESTSATNR001',
            MTART__c = 'PKMT',
            MAKTX__c = 'Test Product Name',
            MEINS__c = 'PCS',
            NTGEW__c = '500.0',
            GEWEI__c = 'KG',
            MATKL__c = 'MATGRP001',
            WGBEZ__c = 'Test Material Group',
            WERKS__c = '184S',
            HE_INDICATOR__c = 'HE',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-002'
        );

        IF_Product__c ifPrd2 = new IF_Product__c(
            MATNR__c = 'T4005-F0MP-1-C10',
            SATNR__c = 'TESTSATNR002',
            MTART__c = 'FPRO',
            MAKTX__c = 'Another Product Name',
            MEINS__c = 'PCS',
            NTGEW__c = '250.0',
            GEWEI__c = 'KG',
            MATKL__c = 'MATGRP002',
            WGBEZ__c = 'Another Material Group',
            WERKS__c = '184S',
            HE_INDICATOR__c = 'CP',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-002'
        );
        IF_Product__c ifPrd3 = new IF_Product__c(
            MATNR__c = 'T4005-F0MP-1-K10',
            SATNR__c = 'TESTSATNR002',
            MTART__c = 'FPRO',
            MAKTX__c = 'Another Product Name',
            MEINS__c = 'PCS',
            NTGEW__c = '250.0',
            GEWEI__c = 'KG',
            MATKL__c = 'MATGRP002',
            WGBEZ__c = 'Another Material Group',
            WERKS__c = '184S',
            HE_INDICATOR__c = 'CP',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-002'
        );

        IF_Product__c ifPrd4 = new IF_Product__c(
            MATNR__c = 'TESTMATNR003',
            SATNR__c = 'TESTSATNR003',
            MTART__c = 'SEMI',
            MAKTX__c = 'Another Product Name',
            MEINS__c = 'PCS',
            NTGEW__c = '250.0',
            GEWEI__c = 'KG',
            MATKL__c = 'MATGRP003',
            WGBEZ__c = 'Another Material Group',
            WERKS__c = '184S',
            HE_INDICATOR__c = 'CP',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-002'
        );

        insert new List<IF_Product__c> {ifPrd1, ifPrd2, ifPrd3, ifPrd4};

        Test.startTest();
        
        // 배치 클래스 실행
        DN_UpdateProductFromERPBatch batch = new DN_UpdateProductFromERPBatch();
        Database.executeBatch(batch, 10);

        Test.stopTest();
    }
    @isTest
    static void DN_UpdateProductFromERPBatch_Error_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-002', 'IF_ERP_Product');

        // IF_Product__c 데이터 생성
        IF_Product__c ifPrd1 = new IF_Product__c(
            MATNR__c = 'TESTMATNR001',
            SATNR__c = 'TESTSATNR001',
            MTART__c = 'PKMT',
            MAKTX__c = 'Test Product Name',
            MEINS__c = 'PCS',
            NTGEW__c = '500.0',
            GEWEI__c = 'KG',
            MATKL__c = 'MATGRP001',
            WGBEZ__c = 'Test Material Group',
            WERKS__c = '184S',
            HE_INDICATOR__c = 'HE',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-002'
        );

        IF_Product__c ifPrd2 = new IF_Product__c(
            MATNR__c = 'T4005-F0MP-1-C10',
            SATNR__c = 'TESTSATNR002',
            MTART__c = 'FPRO',
            MAKTX__c = 'Another Product Name',
            MEINS__c = 'PCS',
            NTGEW__c = '250.0',
            GEWEI__c = 'KG',
            MATKL__c = 'MATGRP002',
            WGBEZ__c = 'Another Material Group',
            WERKS__c = '184S',
            HE_INDICATOR__c = 'CP',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-002'
        );
        IF_Product__c ifPrd3 = new IF_Product__c(
            MATNR__c = 'T4005-F0MP-1-K10',
            SATNR__c = 'TESTSATNR002',
            MTART__c = 'FPRO',
            MAKTX__c = 'Another Product Name',
            MEINS__c = 'PCS',
            NTGEW__c = '250.0',
            GEWEI__c = 'KG',
            MATKL__c = 'MATGRP002',
            WGBEZ__c = 'Another Material Group',
            WERKS__c = '184S',
            HE_INDICATOR__c = 'CP',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-002'
        );

        IF_Product__c ifPrd4 = new IF_Product__c(
            MATNR__c = 'TESTMATNR003',
            SATNR__c = 'TESTSATNR003',
            MTART__c = 'SEMI',
            MAKTX__c = 'Another Product Name',
            MEINS__c = 'PCS',
            NTGEW__c = '250.0',
            GEWEI__c = 'KG',
            MATKL__c = 'MATGRP003',
            WGBEZ__c = 'Another Material Group',
            WERKS__c = '184S',
            HE_INDICATOR__c = 'CP',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-002'
        );

        insert new List<IF_Product__c> {ifPrd1, ifPrd2, ifPrd3, ifPrd4};

        Test.startTest();
        
        // 배치 클래스 실행
        DN_UpdateProductFromERPBatch batch = new DN_UpdateProductFromERPBatch();
        Database.executeBatch(batch, 10);

        Test.stopTest();
    }
    @isTest
    private static void IF_ERP_productBatch_Schedule_Test(){
        InterfaceCommonUtil.setInterface('IF-OPTY-002', 'IF_ERP_Product');
        Test.startTest();
        IF_ERP_Product_Classes.IF_OPTY_002_Req req = new IF_ERP_Product_Classes.IF_OPTY_002_Req();
        IF_ERP_ProductBatch scheduler = new IF_ERP_ProductBatch();
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);
        Test.stopTest();
    }
    @isTest
    static void IF_ERP_ProductBatchForDealerBaseCode_Schedule_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-029', 'IF_ERP_Product');
        Test.startTest();
        IF_ERP_Product_Classes.IF_OPTY_029_Req req = new IF_ERP_Product_Classes.IF_OPTY_029_Req();
        IF_ERP_ProductBatchForDealerBaseCode scheduler = new IF_ERP_ProductBatchForDealerBaseCode(req);
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);
        Test.stopTest();
    }
    @isTest
    static void IF_ERP_ProductBatchForPermittedItem_Schedule_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-030', 'IF_ERP_Product');
        Test.startTest();
        IF_ERP_ProductBatchForPermittedItem scheduler = new IF_ERP_ProductBatchForPermittedItem();
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);
        Test.stopTest();
    }
    @isTest
    static void IF_ERP_ProductBatchForRegionBaseCode_Schedule_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-032', 'IF_ERP_Product');
        Test.startTest();
        IF_ERP_Product_Classes.IF_OPTY_032_Req req = new IF_ERP_Product_Classes.IF_OPTY_032_Req();
        IF_ERP_ProductBatchForRegionBaseCode scheduler = new IF_ERP_ProductBatchForRegionBaseCode(req);
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);
        Test.stopTest();
    }
    @isTest
    static void IF_ERP_ProductBatchForDNSAModel_Schedule_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-033', 'IF_ERP_SalesOrder');
        Test.startTest();
        IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req req = new IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req();
        IF_ERP_ProductBatchForDNSAModel scheduler = new IF_ERP_ProductBatchForDNSAModel();
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);
        Test.stopTest();
    }
    @isTest
    static void DN_UpdateProductActiveFromERPBatch_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-030', 'IF_ERP_Product');
        Product2 testProduct = new Product2(
            Name = 'TEST_MALNR_001-K30',
            ERP_Key__c = 'TESTMATNR001',
            ProductCode = 'TESTMATNR001',
            NameEN__c = 'Test Product EN',
            Name__c = 'Test Product',
            Unit__c = 'PCS',
            Weight__c = 200.0,
            WeightUnit__c = 'KG',
            MaterialGroupCode__c = 'MATGRP001',
            MaterialGroupName__c = 'Test Material Group',
            RecordTypeId = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('BaseCode').getRecordTypeId()
        );
        insert testProduct;

        // IF_Product__c 데이터 생성
        IF_Product__c ifPrd1 = new IF_Product__c(
            MATNR__c = 'TESTMATNR001',
            MALNR__c = 'TEST_MALNR_001-K30',
            MAKTX__c = 'Test Product Name',
            MEINS__c = 'PCS',
            NTGEW__c = '500.0',
            GEWEI__c = 'KG',
            MATKL__c = 'MATGRP001',
            WGBEZ__c = 'Test Material Group',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-030',
            VKORG__c = '1800',
            SPART__c = '40',
            VTWEG__c = '10',
            KUNNR__c = 'KR'
        );

        insert new List<IF_Product__c> {ifPrd1};

        Test.startTest();
        
        // 배치 클래스 실행
        DN_UpdateProductActiveFromERPBatch batch = new DN_UpdateProductActiveFromERPBatch();
        Database.executeBatch(batch, 10);

        Test.stopTest();
    }
    @isTest
    static void DN_UpdateProductSpindleFromERPBatch_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-032', 'IF_ERP_Product');
        // Product2 데이터 생성 (Spindle 필드 없음)
        Product2 testProduct = new Product2(
            Name = 'TEST_MATNR_001',
            ERP_Key__c = 'TESTMATNR001',
            ProductCode = 'TESTMATNR001',
            NameEN__c = 'Test Product EN',
            Name__c = 'Test Product'
        );
        insert testProduct;

        // IF_Product__c 데이터 생성 (IsComplete__c=false)
        IF_Product__c ifPrd1 = new IF_Product__c(
            MATNR__c = 'TEST_MATNR_001',
            REGION__c = 'KR',
            ATWTB__c = 'NC System X',
            ATWTB2__c = '15000 RPM',
            ATWTB3__c = '20 Tools',
            ATWTB4__c = '15 inch',
            ATWTB5__c = '10000 RPM',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-032'
        );

        IF_Product__c ifPrd2 = new IF_Product__c(
            MATNR__c = 'TEST_MATNR_002',
            REGION__c = 'EU',
            ATWTB__c = 'NC System Y',
            ATWTB2__c = '18000 RPM',
            ATWTB3__c = '25 Tools',
            ATWTB4__c = '17 inch',
            ATWTB5__c = '12000 RPM',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-032'
        );

        insert new List<IF_Product__c> {ifPrd1, ifPrd2};

        Test.startTest();
        
        // 배치 클래스 실행
        DN_UpdateProductSpindleFromERPBatch batch = new DN_UpdateProductSpindleFromERPBatch();
        Database.executeBatch(batch, 10);

        Test.stopTest();
    }
    @isTest
    static void DN_UpdateDNSAModelFromERPBatch_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-033', 'IF_ERP_SalesOrder');

        // IF_Product__c 데이터 생성 (IsComplete__c=false)
        IF_Product__c ifPrd1 = new IF_Product__c(
            ZZSQ__c         = '1',
            BASE_CODE__c    = 'KR',
            MDLNM__c        = 'NC System X',
            SATNR__c        = '15000 RPM',
            AEDAT__c        = '20 Tools',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-033'
        );
        IF_Product__c ifPrd2 = new IF_Product__c(
            ZZSQ__c         = '2',
            BASE_CODE__c    = 'KR',
            MDLNM__c        = 'NC System X',
            SATNR__c        = '15000 RPM',
            AEDAT__c        = '20 Tools',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-033'
        );

        insert new List<IF_Product__c> {ifPrd1, ifPrd2};

        Test.startTest();
        
        // 배치 클래스 실행
        DN_UpdateDNSAModelFromERPBatch batch = new DN_UpdateDNSAModelFromERPBatch();
        Database.executeBatch(batch, 10);

        Test.stopTest();
    }
    @isTest
    static void DN_UpdateProductSpindleFromERPBatch2_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-029', 'IF_ERP_Product');
        // Product2 데이터 생성 (Spindle 필드 없음)
        Product2 testProduct = new Product2(
            Name = 'TEST_MATNR_001',
            ERP_Key__c = 'TESTMATNR001',
            ProductCode = 'TESTMATNR001',
            NameEN__c = 'Test Product EN',
            Name__c = 'Test Product'
        );
        insert testProduct;

        // IF_Product__c 데이터 생성 (IsComplete__c=false)
        IF_Product__c ifPrd1 = new IF_Product__c(
            MATNR__c = 'TEST_MATNR_001',
            REGION__c = 'KR',
            ATWTB__c = 'NC System X',
            ATWTB2__c = '15000 RPM',
            ATWTB3__c = '20 Tools',
            ATWTB4__c = '15 inch',
            ATWTB5__c = '10000 RPM',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-029'
        );

        IF_Product__c ifPrd2 = new IF_Product__c(
            MATNR__c = 'TEST_MATNR_002',
            REGION__c = 'EU',
            ATWTB__c = 'NC System Y',
            ATWTB2__c = '18000 RPM',
            ATWTB3__c = '25 Tools',
            ATWTB4__c = '17 inch',
            ATWTB5__c = '12000 RPM',
            IsComplete__c = false,
            FromInterfaceId__c = 'IF-OPTY-029'
        );

        insert new List<IF_Product__c> {ifPrd1, ifPrd2};

        Test.startTest();
        
        // 배치 클래스 실행
        DN_UpdateProductSpindleFromERPBatch2 batch = new DN_UpdateProductSpindleFromERPBatch2();
        Database.executeBatch(batch, 10);

        Test.stopTest();
    }
}