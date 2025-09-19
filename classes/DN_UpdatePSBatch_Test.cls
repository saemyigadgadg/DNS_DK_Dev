/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 06-26-2025
 * @last modified by  : JangJunHee
**/
@isTest
private class DN_UpdatePSBatch_Test {
    
    @testSetup
    static void setupTestData() {
        PS__c psRecord = new PS__c(
            ERPInquiryNo__c          = 'INQ12345',            // ERP 연동 Inquiry No
            Version__c               = 1.0,                   // 버전
            RequiredDelivryDate__c   = Date.today().addDays(30), // 요청 납기일 (30일 후)
            ResponsibleBranch__c     = 'Seoul Branch',        // 담당 지점
            CustomerName__c          = 'ABC Manufacturing',   // 고객사명
            PartsforMachining__c     = 'CNC Lathe Parts',     // 가공 부품명
            ProductionVolumeYearly__c = 50000,               // 연간 생산량
            WorkingHoursDaily__c     = 8.0,                   // 일일 작업 시간 (시간 단위)
            WorkingDaysMonthly__c    = 22,                    // 월 작업 일수
            OperationRate__c         = 90.0,                  // 가동률 (퍼센트)
            CycleTimeRequired__c     = 45.5,                  // 요구 사이클 타임 (초)
            CustomerDesc__c   = 'High precision required with tolerance ±0.005mm.', // 고객 요구사항
            CustomerEmail__c         = 'customer@email.com', // 고객 이메일
            CustomerMobileNo__c      = '010-1234-5678',      // 고객 휴대폰 번호
            // InquirySeq__c            = 'SEQ001',             // 문의 시퀀스
            // Opportunity__c           = '0065j00000ABC123',   // 관련된 기회 (Salesforce Opportunity ID)
            Status__c               = 'Draft'                 // 현재 상태 (예: Open, In Progress, Closed 등)
        );

        insert psRecord;

        PS__c ps = [
            SELECT Id, ERPInquiryNo__c
            FROM PS__c
            LIMIT 1
        ];

        System.debug('ps.ERPInquiryNo__c ::: ' + ps.ERPInquiryNo__c);

        IF_AEPortal__c aePortal = new IF_AEPortal__c(
            I_INQUIRY_NO__c = ps.ERPInquiryNo__c,
            I_VERSION__c = '1',
            I_REVIEW_REQUEST_DATE__c = '20250401',
            I_PRODUCT_NAME__c = 'Product ' + 1,
            I_OUTPUT__c = '1000',
            I_WORKING_HOURS__c = '8',
            I_DUTY_DAY__c = '22',
            I_OPERATION_RATE__c = '90',
            I_CYCLE_IME_REQUEST__c = '30',
            I_REMARK__c = 'Test Remark ' + 1,
            I_EMAIL__c = 'test' + 1 + '@email.com',
            I_TEL__c = '010-1234-567' + 1,
            I_ORDER_STATUS__c = 'Pending',
            IsComplete__c = false,
            IsConvertError__c = false,
            Interface_ID__c = 'IF-OPTY-017'
        );
        insert aePortal;
    }

    @isTest
    static void testBatchExecute_Success() {
        // 1. 배치 클래스 실행
        Test.startTest();
        DN_UpdatePSBatch batch = new DN_UpdatePSBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }
}