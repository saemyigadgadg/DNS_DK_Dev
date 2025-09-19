@IsTest
public with sharing class IF_ERP_CV_ConvertedBatch_Test {
    public IF_ERP_CV_ConvertedBatch_Test() {}

    @testSetup
    static void setupData() {
        // Given: IF_CV__c 레코드 생성
        IF_CV__c cvRecord = new IF_CV__c(
            MANDT__c = '880',
            REGION__c = 'B10',
            REGIONT__c = '영국',
            WAERK__c = 'GBP', // 통화코드 필드
            MAGRATE__c = '0.40',
            AOP__c = '1420',
            GSTRU__c = 'A834',
            SORTF__c = '01',
            IsConverted__c = false
        );
        insert cvRecord;
    }


    @isTest 
    static void convertCVBatch(){
        Test.startTest();
        IF_ERP_CV_ConvertedBatch cvBatch  = new IF_ERP_CV_ConvertedBatch();
        Database.executeBatch(cvBatch,50);
        Test.stopTest();
    }
}