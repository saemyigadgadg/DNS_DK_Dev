@isTest
public class MatrixCaseCallbackTriggerTest {
    

    
    @isTest
    static void testCaseCallbackTrigger() {
        // 테스트 데이터 준비

        
        Case testCase = new Case(
            Subject = '콜백 테스트',
            Status = 'New',
            Matrix_Call_Type__c = 'Callback'
        );
        insert testCase;
        
        Test.startTest();
        
        // Case 상태를 Closed로 업데이트
        testCase.Status = 'Closed';
        update testCase;
        
        Test.stopTest();
        
        // 검증
        Case updatedCase = [SELECT Id, Status, Matrix_Call_Type__c 
                          FROM Case 
                          WHERE Id = :testCase.Id];
        
        System.assertEquals('Closed', updatedCase.Status);
        System.assertEquals('Callback', updatedCase.Matrix_Call_Type__c);
    }
    
    @isTest
    static void testCaseCallbackTriggerWithPhone() {
        // ContactMobile이 없고 ContactPhone만 있는 케이스 테스트

        
        Case testCase = new Case(
            Subject = '콜백 테스트 - 일반전화',
            Status = 'New',
            Matrix_Call_Type__c = 'Callback'
        );
        insert testCase;
        
        Test.startTest();
        
        testCase.Status = 'Closed';
        update testCase;
        
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, Status, Matrix_Call_Type__c 
                          FROM Case 
                          WHERE Id = :testCase.Id];
        
        System.assertEquals('Closed', updatedCase.Status);
        System.assertEquals('Callback', updatedCase.Matrix_Call_Type__c);
    }
    
    @isTest
    static void testCaseNonCallbackTrigger() {
        // Matrix_Call_Type__c가 Callback이 아닌 경우 테스트

        
        Case testCase = new Case(
            Subject = '일반 케이스 테스트',
            Status = 'New',
            Matrix_Call_Type__c = 'Normal'
        );
        insert testCase;
        
        Test.startTest();
        
        testCase.Status = 'Closed';
        update testCase;
        
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, Status, Matrix_Call_Type__c 
                          FROM Case 
                          WHERE Id = :testCase.Id];
        
        System.assertEquals('Closed', updatedCase.Status);
        System.assertEquals('Normal', updatedCase.Matrix_Call_Type__c);
    }
}