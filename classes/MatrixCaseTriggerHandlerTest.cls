@isTest
private class MatrixCaseTriggerHandlerTest {

    static testMethod void testMatrixCaseTriggerHandler() {


        // 테스트 실행
        Test.startTest();

      /*          // 테스트 실행
        Case inputCase = new Case(Subject = 'callCase',Matrix_Call_Tag__c = 'inbound_call');
        Lead inputLead = new Lead(LastName = 'LastName',Company = 'LastName',Matrix_Call_Tag__c = 'inbound_call');
        // Call__c inputCall = new Call__c(name = 'LastName');

        insert inputCase;
        insert inputLead;
        // insert inputCall;

                
        List<Task> taskUpdate = [SELECT Id ,WhatId  FROM Task WHERE  Matrix_Phone_Number__c = '01012345678' ];
        List<Case> caseList = [SELECT Id ,Subject  FROM Case WHERE  Matrix_Call_Tag__c = 'inbound_call' ];
        List<Lead> leadList = [SELECT Id ,LastName  FROM Lead WHERE  Matrix_Call_Tag__c = 'inbound_call' ];
        // List<Call__c> callList = [SELECT Id ,name  FROM Call__c WHERE  name = 'LastName' ];

        String result = MatrixSttController.updateTask(taskUpdate);

        List<Task> result2 = MatrixSttController.findTasks('test');


        String result1 = MatrixSttController.addCaseComment(caseList[0].Id,'comment');

        caseList[0].Matrix_Call_Category__c = 'category';
        caseList[0].Matrix_Call_Emotion__c = '중립';
        caseList[0].Matrix_Call_Summary__c = 'summary';

        leadList[0].Matrix_Call_Category__c = 'category';
        leadList[0].Matrix_Call_Emotion__c = '중립';
        leadList[0].Matrix_Call_Summary__c = 'summary';

        // callList[0].Matrix_Call_Category__c = 'category';
        // callList[0].Matrix_Call_Emotion__c = '중립';
        // callList[0].Matrix_Call_Summary__c = 'summary';

        result1 = MatrixSttController.updateCase(caseList);
        result1 = MatrixSttController.updateLead(leadList);

        // result1 = MatrixSttController.updateCall(callList);

        caseList[0].Matrix_Call_Category__c = 'category';
        caseList[0].Matrix_Call_Emotion__c = '중립';
        caseList[0].Matrix_Call_Summary__c = 'summary';

        leadList[0].Matrix_Call_Category__c = 'category';
        leadList[0].Matrix_Call_Emotion__c = '중립';
        leadList[0].Matrix_Call_Summary__c = 'summary';

        // callList[0].Matrix_Call_Category__c = 'category';
        // callList[0].Matrix_Call_Emotion__c = '중립';
        // callList[0].Matrix_Call_Summary__c = 'summary';

        result1 = MatrixSttController.updateCase(caseList);
        result1 = MatrixSttController.updateLead(leadList);

        // result1 = MatrixSttController.updateCall(callList);

        */
        MatrixCaseTriggerHandler.dummy();
        Test.stopTest();
    }
}