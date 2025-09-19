/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-10
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-10   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_DealerGradeUpdateBatchTest {
    
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        IF_CustomerGrade__c gradeInfo = new IF_CustomerGrade__c();
        gradeInfo.KUNNR__c = '12345';
        gradeInfo.KVGR4__c = 'A';
        insert gradeInfo;

        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.CustomerCode__c = '12345';
            insert dealerAcc;
        }

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

    }

    @isTest
    static void testBatchExecution(){
        Test.startTest();

        DN_DealerGradeUpdateBatch batchJob = new DN_DealerGradeUpdateBatch();

        String jobId = System.schedule('Test Scheduled Batch', '0 0 0 1 1 ? 2050', batchJob);
        
        Database.ExecuteBatch(batchJob, 5);
        Test.stopTest();

    }

}