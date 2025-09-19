@IsTest
public with sharing class IF_ERP_CustomerGradeConvertBatch_Test {
    public IF_ERP_CustomerGradeConvertBatch_Test() {}

    @TestSetup
    static void makeData(){
        RecordType dealerRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Dealer' LIMIT 1];


        Account acc1 = new Account(
            Name = '링엔지니어링 1',
            RecordTypeId = dealerRecordType.Id,
            BillingStreet = '경기도 하남시',
            BillingCity = '경기도',
            Phone = '051-831-1204',
            CustomerCode__c = '0001057671'
        );

        insert acc1;


        IF_CustomerGrade__c grade = new IF_CustomerGrade__c(
            Name = 'a3AJO00000009jF',
            KVGR4__c = 'B',
            KUNNR__c = '1057671'

        );

        insert grade;

    }

    @IsTest
    static void CustomerGradeConvertBatchTest(){
        Test.startTest();
        IF_ERP_CustomerGradeConvertBatch batchInstance = new IF_ERP_CustomerGradeConvertBatch();
        Database.executeBatch(batchInstance,50); 
        Test.stopTest();

    }
}