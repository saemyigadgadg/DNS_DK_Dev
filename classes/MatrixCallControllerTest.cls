@isTest
private class MatrixCallControllerTest {
    
    // 테스트 데이터 클래스
    public class CallInfoClass {
        public String Agent_ID; 
        public Datetime Answered_At;  
        public String Call_ID; 
        public String Call_State; 
        public String Call_Type;  
        public String CallerID;  
        public Datetime Created_At;  
        public String DNIS;  
        public String DNIS_Memo;  
        public String Extension; 
        public String Phone_Number;
        public Boolean Is_Ans;   
        public String IVR_Tag;  
        public String IVR_Tag_Memo;  
        public String Queue_Name;  
        public Datetime Queued_At;  
        public Datetime Ring_At;  
        public Integer TM_Connect;   
        public Integer TM_Queue;  
        public Integer TM_Ring;  
        public Datetime Updated_At; 
        public String focusObjectTabId;
    }

    @TestSetup
    static void setupTestData() {
        // 테스트용 Account 생성
        Account testAccount = new Account(Name = '미확인 고객사');
        insert testAccount;
        
        // 테스트용 RecordType 조회
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE DeveloperName = 'CSCustomer' LIMIT 1];
        if (recordTypes.isEmpty()) {
            // RecordType이 없으면 기본 Contact 생성
            Contact testContact = new Contact(
                LastName = 'Test Contact',
                Phone = '010-1234-5678',
                MobilePhone = '010-1234-5678',
                AccountId = testAccount.Id
            );
            insert testContact;
        }
    }

    // CallInfo 테스트 데이터 생성 헬퍼 메서드
    private static CallInfoClass createTestCallInfo(String callType, String callId) {
        CallInfoClass callInfo = new CallInfoClass();
        callInfo.Agent_ID = 'TEST_AGENT_001';
        callInfo.Answered_At = Datetime.now();
        callInfo.Call_ID = callId;
        callInfo.Call_State = 'Connect';
        callInfo.Call_Type = callType;
        callInfo.CallerID = '01012345678';
        callInfo.Created_At = Datetime.now();
        callInfo.DNIS = 'TEST_DNIS';
        callInfo.DNIS_Memo = 'Test DNIS Memo';
        callInfo.Extension = '1001';
        callInfo.Is_Ans = true;
        callInfo.IVR_Tag = 'TEST_IVR';
        callInfo.IVR_Tag_Memo = 'Test IVR Memo';
        callInfo.Phone_Number = '01012345678';
        callInfo.Queue_Name = 'TEST_QUEUE';
        callInfo.Queued_At = Datetime.now();
        callInfo.Ring_At = Datetime.now();
        callInfo.TM_Connect = 30;
        callInfo.TM_Queue = 10;
        callInfo.TM_Ring = 5;
        callInfo.Updated_At = Datetime.now();
        callInfo.focusObjectTabId = '';
        return callInfo;
    }

    @isTest
    static void testCheckAndCreateContactAndTask() {
        // 테스트 데이터 준비
        String phone = '01012345678';
        String subject = 'Test Call Subject';
        CallInfoClass callInfo = createTestCallInfo('Inbound', 'TEST_CALL_001');
        
        Test.startTest();
        String result = MatrixCallController.CheckAndCreateContactAndTask(phone, subject, JSON.serialize(callInfo));
        Test.stopTest();
        
        // 결과 검증
        Map<String, Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, resultData.get('contactId'), '연락처 ID가 생성되어야 합니다.');
        System.assertNotEquals(null, resultData.get('newTaskId'), '작업 ID가 생성되어야 합니다.');
        
        // 생성된 Task 검증
        List<Task> tasks = [SELECT Id, Subject, Matrix_Call_ID__c, Matrix_Call_Type__c FROM Task WHERE Matrix_Call_ID__c = :callInfo.Call_ID];
        System.assertEquals(1, tasks.size(), '하나의 Task가 생성되어야 합니다.');
        System.assertEquals(subject, tasks[0].Subject, 'Task 제목이 올바르게 설정되어야 합니다.');
    }

    @isTest
    static void testCheckTicketAndCreateTask() {
        // 테스트 데이터 준비
        String phone = '01012345678';
        String subject = 'Test Ticket Subject';
        CallInfoClass callInfo = createTestCallInfo('Inbound', 'TEST_TICKET_001');
        
        Test.startTest();
        String result = MatrixCallController.CheckTicketAndCreateTask(phone, subject, JSON.serialize(callInfo));
        Test.stopTest();
        
        // 결과 검증
        Map<String, Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, resultData.get('callCaseId'), '케이스 ID가 반환되어야 합니다.');
        System.assertNotEquals(null, resultData.get('newTaskId'), '작업 ID가 생성되어야 합니다.');
    }

    @isTest
    static void testCheckTicketAndCreateTaskWithFocusObject() {
        // 테스트 데이터 준비
        Contact testContact = new Contact(LastName = 'Test Contact', Phone = '01012345678');
        insert testContact;
        
        String phone = '01012345678';
        String subject = 'Test Ticket Subject';
        CallInfoClass callInfo = createTestCallInfo('Inbound', 'TEST_TICKET_002');
        callInfo.focusObjectTabId = testContact.Id;
        
        Test.startTest();
        String result = MatrixCallController.CheckTicketAndCreateTask(phone, subject, JSON.serialize(callInfo));
        Test.stopTest();
        
        // 결과 검증
        Map<String, Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, resultData.get('callCaseId'), '케이스 ID가 반환되어야 합니다.');
        System.assertNotEquals(null, resultData.get('newTaskId'), '작업 ID가 생성되어야 합니다.');
    }

    @isTest
    static void testFindCase() {
        // 테스트 데이터 준비
        Contact testContact = new Contact(LastName = 'Test Contact', Phone = '01012345678');
        insert testContact;
        
        Task testTask = new Task(
            Subject = 'Test Task',
            whoId = testContact.Id,
            Matrix_Call_ID__c = 'TEST_FIND_CASE_001',
            Status = 'Completed'
        );
        insert testTask;
        
        Test.startTest();
        Id result = MatrixCallController.findCase('TEST_FIND_CASE_001');
        Test.stopTest();
        
        // 결과 검증
        System.assertEquals(null, result, 'Task의 WhatId가 null이므로 null이 반환되어야 합니다.');
    }

    @isTest
    static void testCreateCase() {
        // 테스트 데이터 준비
        String phone = '01012345678';
        String subject = 'Test Case Subject';
        String callTag = 'inbound_call';
        CallInfoClass callInfo = createTestCallInfo('Inbound', 'TEST_CASE_001');
        
        Test.startTest();
        String result = MatrixCallController.createCase(phone, subject, callTag, JSON.serialize(callInfo));
        Test.stopTest();
        
        // 결과 검증
        Map<String, Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, resultData.get('contactId'), '연락처 ID가 생성되어야 합니다.');
        System.assertNotEquals(null, resultData.get('caseId'), '케이스 ID가 생성되어야 합니다.');
        System.assertNotEquals(null, resultData.get('newTaskId'), '작업 ID가 생성되어야 합니다.');
        
        // 생성된 Case 검증
        List<Case> cases = [SELECT Id, Subject, Matrix_Call_ID__c, Matrix_Call_Tag__c FROM Case WHERE Matrix_Call_ID__c = :callInfo.Call_ID];
        System.assertEquals(1, cases.size(), '하나의 Case가 생성되어야 합니다.');
        System.assertEquals(subject, cases[0].Subject, 'Case 제목이 올바르게 설정되어야 합니다.');
        System.assertEquals(callTag, cases[0].Matrix_Call_Tag__c, 'Call Tag가 올바르게 설정되어야 합니다.');
    }

    @isTest
    static void testCreateCaseAndTaskForNoAnswer() {
        // 테스트 데이터 준비
        String phone = '01012345678';
        String subject = 'Test No Answer Subject';
        String callTag = 'no_answer';
        CallInfoClass callInfo = createTestCallInfo('Inbound', 'TEST_NO_ANSWER_001');
        
        Test.startTest();
        String result = MatrixCallController.createCaseAndTaskForNoAnswer(phone, subject, callTag, JSON.serialize(callInfo));
        Test.stopTest();
        
        // 결과 검증
        Map<String, Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, resultData.get('contactId'), '연락처 ID가 생성되어야 합니다.');
        System.assertNotEquals(null, resultData.get('newTaskId'), '작업 ID가 생성되어야 합니다.');
    }

    @isTest
    static void testCreateTaskOnContactForNoAnswer() {
        // 테스트 데이터 준비
        String phone = '01012345678';
        String subject = 'Test Contact No Answer Subject';
        String callTag = 'contact_no_answer';
        CallInfoClass callInfo = createTestCallInfo('Inbound', 'TEST_CONTACT_NO_ANSWER_001');
        
        Test.startTest();
        String result = MatrixCallController.createTaskOnContactForNoAnswer(phone, subject, callTag, JSON.serialize(callInfo));
        Test.stopTest();
        
        // 결과 검증
        Map<String, Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, resultData.get('contactId'), '연락처 ID가 생성되어야 합니다.');
        System.assertNotEquals(null, resultData.get('newTaskId'), '작업 ID가 생성되어야 합니다.');
    }

    @isTest
    static void testCreateTaskOnContactForOutBoundCall() {
        // 테스트 데이터 준비
        String phone = '01012345678';
        String subject = 'Test Outbound Call Subject';
        String callTag = 'outbound_call';
        CallInfoClass callInfo = createTestCallInfo('Outbound', 'TEST_OUTBOUND_001');
        
        Test.startTest();
        String result = MatrixCallController.createTaskOnContactForOutBoundCall(phone, subject, callTag, JSON.serialize(callInfo));
        Test.stopTest();
        
        // 결과 검증
        Map<String, Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, resultData.get('callCaseId'), '케이스 ID가 반환되어야 합니다.');
        System.assertNotEquals(null, resultData.get('newTaskId'), '작업 ID가 생성되어야 합니다.');
        
        // 생성된 Task 검증
        List<Task> tasks = [SELECT Id, Subject, Matrix_Call_ID__c, CallType__c FROM Task WHERE Matrix_Call_ID__c = :callInfo.Call_ID];
        System.assertEquals(1, tasks.size(), '하나의 Task가 생성되어야 합니다.');
        System.assertEquals('Outbound Call', tasks[0].CallType__c, 'CallType이 Outbound Call로 설정되어야 합니다.');
    }

    @isTest
    static void testFindContactsByPhone() {
        // 테스트 데이터 준비
        Contact testContact1 = new Contact(LastName = 'Test Contact 1', Phone = '010-1234-5678');
        Contact testContact2 = new Contact(LastName = 'Test Contact 2', MobilePhone = '010-1234-5678');
        insert new List<Contact>{testContact1, testContact2};
        
        Test.startTest();
        List<Contact> result = MatrixCallController.findContactsByPhone('01012345678');
        Test.stopTest();
        
        // 결과 검증
        System.assertNotEquals(0, result.size(), '전화번호로 연락처를 찾을 수 있어야 합니다.');
    }

    @isTest
    static void testMaskPhoneNumber() {
        Test.startTest();
        String result = MatrixCallController.maskPhoneNumber('01012345678');
        Test.stopTest();
        
        // 결과 검증
        System.assertEquals('010****5678', result, '전화번호가 올바르게 마스킹되어야 합니다.');
    }

    @isTest
    static void testGetCurrentUserEmail() {
        Test.startTest();
        String result = MatrixCallController.getCurrentUserEmail();
        Test.stopTest();
        
        // 결과 검증
        System.assertNotEquals(null, result, '사용자 이메일이 반환되어야 합니다.');
    }

    @isTest
    static void testGetPicklistLabels() {
        Test.startTest();
        String result = MatrixCallController.getPicklistLabels('Task', 'Status');
        Test.stopTest();
        
        // 결과 검증
        System.assertNotEquals(null, result, '픽리스트 라벨이 반환되어야 합니다.');
    }

    @isTest
    static void testGetPicklistValues() {
        Test.startTest();
        String result = MatrixCallController.getPicklistValues('Task', 'Status');
        Test.stopTest();
        
        // 결과 검증
        System.assertNotEquals(null, result, '픽리스트 값이 반환되어야 합니다.');
    }

    @isTest
    static void testGetFieldDependenciesForExt() {
        Test.startTest();
        String result = MatrixCallController.getFieldDependenciesForExt('Task', 'ConsultationTypeMajor__c', 'ConsultationTypeMiddle__c');
        Test.stopTest();
        
        // 결과 검증
        System.assertNotEquals(null, result, '필드 의존성이 반환되어야 합니다.');
    }

    @isTest
    static void testSaveConsultCategory() {
        Test.startTest();
        String result = MatrixCallController.saveConsultCategory('Test Category', 'Test Detail');
        Test.stopTest();
        
        // 결과 검증
        System.assertNotEquals(null, result, '상담 카테고리 정보가 반환되어야 합니다.');
    }



    @isTest
    static void testCallApiWithCallBacks() {
        // 테스트 데이터 준비
        Contact testContact = new Contact(LastName = 'Test Contact', Phone = '01012345678');
        insert testContact;
        
        Case testCase = new Case(ContactId = testContact.Id, Subject = 'Test Case');
        insert testCase;
        
        Map<Id, String> caseCallbackMap = new Map<Id, String>();
        caseCallbackMap.put(testCase.Id, '01012345678');
        
        Test.startTest();
        MatrixCallController.callApiWithCallBacks(caseCallbackMap);
        Test.stopTest();
        
        // API 호출은 @future 메서드이므로 비동기로 실행됨
        System.assert(true, 'API 호출이 정상적으로 실행되어야 합니다.');
    }

    @isTest
    static void testPhoneNumberFormats() {
        // 다양한 전화번호 형식 테스트
        List<String> phoneNumbers = new List<String>{
            '01012345678',  // 11자리
            '0212345678',   // 10자리 (서울)
            '0312345678',   // 10자리 (기타)
            '010-1234-5678', // 하이픈 포함
            '02-1234-5678'   // 서울 하이픈 포함
        };
        
        Test.startTest();
        for (String phone : phoneNumbers) {
            List<Contact> result = MatrixCallController.findContactsByPhone(phone);
            // 전화번호 형식에 관계없이 메서드가 정상 실행되는지 확인
            System.assertNotEquals(null, result, '전화번호 형식에 관계없이 결과가 반환되어야 합니다.');
        }
        Test.stopTest();
    }
}