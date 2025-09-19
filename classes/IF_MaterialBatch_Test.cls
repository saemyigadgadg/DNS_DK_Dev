@isTest
public with sharing class IF_MaterialBatch_Test {
    public IF_MaterialBatch_Test() {}

/* Test Method
    */
    @isTest
    private static void IF_MaterialBatch_Test () {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', 'IF_ERP_Material');
        Test.startTest();

        IF_ERP_Material_Classes.IF_CSPLUS_018_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_018_Req();
        req.I_FROM  = '2025-01-01';
        req.I_TO    = '2025-02-01';

        IF_MaterialBatch batch = new IF_MaterialBatch();
        batch.req = req;
        Database.executeBatch(batch);

        Test.stopTest();
    }
    @isTest
    static void DN_UpdateAssetFromERPBatch_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', 'IF_ERP_Material');

        IF_Material__c ifMaterial1 = new IF_Material__c(
            EQUNR__c = 'ASSET001',
            HERLD__c = 'Korea',
            EQKTX__c = 'Test Equipment',
            MATNR__c = 'MAT001',
            SERNR__c = 'SERIAL001',
            TXT04__c = 'Active',
            INTERNAL_NOTE__c = 'Test Internal Note',
            CLASS__c = 'Class A',
            EQART__c = 'EQ Type 1',
            INBDT__c = '2023-01-01',
            ANSDT__c = '2022-12-01',
            HERST__c = 'Manufacturer X',
            M_ATWRT__c = 'NC Type A',
            ATWRT__c = 'NC No 1',
            M_ATWRT2__c = 'Char Value 1',
            BAUJJ__c = '2022',
            BAUMM__c = '12',
            KDAUF__c = 'ORDER001',
            PERSON_RES__c = 'ENG0',
            RES_MN_WK_CTR__c = 'WC0',
            IsComplete__c = false,
            ParameterName__c = 'T_ITEM'
        );

        IF_Material__c ifMaterial2 = new IF_Material__c(
            EQUNR__c = 'ASSET002',
            HERLD__c = 'USA',
            EQKTX__c = 'Test Equipment 2',
            MATNR__c = 'MAT002',
            SERNR__c = 'SERIAL002',
            TXT04__c = 'Inactive',
            INTERNAL_NOTE__c = 'Test Internal Note 2',
            CLASS__c = 'Class B',
            EQART__c = 'EQ Type 2',
            INBDT__c = '2023-02-01',
            ANSDT__c = '2023-01-01',
            HERST__c = 'Manufacturer Y',
            M_ATWRT__c = 'NC Type B',
            ATWRT__c = 'NC No 2',
            M_ATWRT2__c = 'Char Value 2',
            BAUJJ__c = '2023',
            BAUMM__c = '01',
            KDAUF__c = 'ORDER001',
            PERSON_RES__c = 'ENG001',
            RES_MN_WK_CTR__c = 'WC0',
            IsComplete__c = false,
            ParameterName__c = 'T_ITEM'
        );

        insert new List<IF_Material__c>{ifMaterial1, ifMaterial2};

        Test.startTest();

        // 배치 클래스 실행
        DN_UpdateAssetFromERPBatch batch = new DN_UpdateAssetFromERPBatch();
        Database.executeBatch(batch, 10);

        Test.stopTest();
    }
    @isTest
    static void DN_UpdateAssetFromERPBatch_ErrorHandling_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', 'IF_ERP_Material');
        
        IF_Material__c ifMaterial1 = new IF_Material__c(
            EQUNR__c = null,
            HERLD__c = 'Korea',
            EQKTX__c = 'Test Equipment',
            MATNR__c = 'MAT001',
            SERNR__c = 'SERIAL001',
            TXT04__c = 'Active',
            INTERNAL_NOTE__c = 'Test Internal Note',
            CLASS__c = 'Class A',
            EQART__c = 'EQ Type 1',
            INBDT__c = '2023-01-01',
            ANSDT__c = '2022-12-01',
            HERST__c = 'Manufacturer X',
            M_ATWRT__c = 'NC Type A',
            ATWRT__c = 'NC No 1',
            M_ATWRT2__c = 'Char Value 1',
            BAUJJ__c = '2022',
            BAUMM__c = '12',
            KDAUF__c = 'ORDER001',
            PERSON_RES__c = 'ENG0',
            RES_MN_WK_CTR__c = 'WC0',
            IsComplete__c = false,
            ParameterName__c = 'T_ITEM'
        );

        IF_Material__c ifMaterial2 = new IF_Material__c(
            EQUNR__c = null,
            HERLD__c = 'USA',
            EQKTX__c = 'Test Equipment 2',
            MATNR__c = 'MAT002',
            SERNR__c = 'SERIAL002',
            TXT04__c = 'Inactive',
            INTERNAL_NOTE__c = 'Test Internal Note 2',
            CLASS__c = 'Class B',
            EQART__c = 'EQ Type 2',
            INBDT__c = '2023-02-01',
            ANSDT__c = '2023-01-01',
            HERST__c = 'Manufacturer Y',
            M_ATWRT__c = 'NC Type B',
            ATWRT__c = 'NC No 2',
            M_ATWRT2__c = 'Char Value 2',
            BAUJJ__c = '2023',
            BAUMM__c = '01',
            KDAUF__c = 'ORDER001',
            PERSON_RES__c = 'ENG001',
            RES_MN_WK_CTR__c = 'WC0',
            IsComplete__c = false,
            ParameterName__c = 'T_ITEM'
        );

        insert new List<IF_Material__c>{ifMaterial1, ifMaterial2};

        Test.startTest();

        // 배치 클래스 실행
        DN_UpdateAssetFromERPBatch batch = new DN_UpdateAssetFromERPBatch();
        Database.executeBatch(batch, 10);

        Test.stopTest();
    }
    @isTest
    static void DN_UploadFileToAssetFromERPBatch_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', 'IF_ERP_Material');

        // Asset 데이터 생성
        Asset testAsset = new Asset(
            Name = 'ASSET001',
            Description = 'Test Asset',
            SerialNumber = 'SERIAL001',
            Status = 'Active'
        );
        insert testAsset;

        Datetime batchTime = System.now();

        // IF_Material__c 데이터 생성 (T_DOCUMENT)
        IF_Material__c ifMaterial1 = new IF_Material__c(
            OBJKY__c = 'ASSET001',
            DOKNR__c = 'DOC001',
            DKTXT__c = 'Test Document 1',
            BUFFER__c = EncodingUtil.base64Encode(Blob.valueOf('Test PDF Data')),
            BatchExecuteTime__c = batchTime,
            ParameterName__c = 'T_DOCUMENT',
            IsComplete__c = false
        );

        insert new List<IF_Material__c>{ifMaterial1};

        // IF_Material__c 데이터 생성 (T_DOCUMENT_FILE)
        IF_Material__c ifMaterialFile = new IF_Material__c(
            OBJKY__c = 'ASSET001',
            DOKNR__c = 'DOC001',
            FileSequence__c = 1,
            BUFFER__c = EncodingUtil.base64Encode(Blob.valueOf('Test File Content')),
            BatchExecuteTime__c = batchTime,
            ParameterName__c = 'T_DOCUMENT_FILE',
            IsComplete__c = false
        );

        insert ifMaterialFile;

        IF_Material__c queryMaterial = [
            SELECT Id, BatchExecuteTime__c
            FROM IF_Material__c
            LIMIT 1
        ];

        Map<String, Datetime> batchExecuteTimeForName = new Map<String, Datetime>{ 'ASSET001' => queryMaterial.BatchExecuteTime__c };
        Map<String, String> assetIdForName = new Map<String, String>{'ASSET001' => testAsset.Id};

        Test.startTest();

        // 배치 클래스 실행
        DN_UploadFileToAssetFromERPBatch batch = new DN_UploadFileToAssetFromERPBatch(batchExecuteTimeForName, assetIdForName);
        Database.executeBatch(batch, 10);

        Test.stopTest();
    }
    @isTest
    static void DN_UploadFileToAssetFromERPBatch_ErrorHandling_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', 'IF_ERP_Material');

        // Asset 데이터 생성
        Asset testAsset = new Asset(
            Name = 'ASSET001',
            Description = 'Test Asset',
            SerialNumber = 'SERIAL001',
            Status = 'Active'
        );
        insert testAsset;

        Datetime batchTime = System.now();

        // IF_Material__c 데이터 생성 (T_DOCUMENT)
        IF_Material__c ifMaterial1 = new IF_Material__c(
            OBJKY__c = 'ASSET001',
            DOKNR__c = 'DOC001',
            DKTXT__c = 'Test Document 1',
            BUFFER__c = EncodingUtil.base64Encode(Blob.valueOf('Test PDF Data')),
            BatchExecuteTime__c = batchTime,
            ParameterName__c = 'T_DOCUMENT',
            IsComplete__c = false
        );

        insert new List<IF_Material__c>{ifMaterial1};

        // IF_Material__c 데이터 생성 (T_DOCUMENT_FILE)
        IF_Material__c ifMaterialFile = new IF_Material__c(
            OBJKY__c = 'ASSET001',
            DOKNR__c = 'DOC001',
            FileSequence__c = 1,
            BUFFER__c = EncodingUtil.base64Encode(Blob.valueOf('Test File Content')),
            BatchExecuteTime__c = batchTime,
            ParameterName__c = 'T_DOCUMENT_FILE',
            IsComplete__c = false
        );

        insert ifMaterialFile;

        Map<String, Datetime> batchExecuteTimeForName = null;
        Map<String, String> assetIdForName = null;

        Test.startTest();

        // 배치 클래스 실행
        DN_UploadFileToAssetFromERPBatch batch = new DN_UploadFileToAssetFromERPBatch(batchExecuteTimeForName, assetIdForName);
        Database.executeBatch(batch, 10);

        Test.stopTest();
    }
    @isTest
    static void IF_MaterialBatch_Schedule_Test() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', 'IF_ERP_Material');
        Test.startTest();
        IF_ERP_Material_Classes.IF_CSPLUS_018_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_018_Req();
        IF_MaterialBatch scheduler = new IF_MaterialBatch();
        scheduler.req = req;
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);
        Test.stopTest();

        // 스케줄 실행 확인
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE CronExpression = '0 0 12 * * ?' LIMIT 1];
        System.assertNotEquals(null, ct, '스케줄러가 정상적으로 등록되지 않았습니다.');
    }

}