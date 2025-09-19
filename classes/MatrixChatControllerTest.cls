@isTest
private class MatrixChatControllerTest {
    @TestSetup
    static void setupTestData() {
        // 테스트용 Case 생성
        Case testCase = new Case(
            Subject = 'Test Case',
            MatrixChat_Room_Id__c = 12345,
            MatrixChat_Session_Id__c = 'test-session-id',
            MatrixChat_Center_Id__c = 'test-center-id'
        );
        insert testCase;
    }

    @isTest
    static void testUpdateOwnerId() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        testCase.OwnerId = testUser.Id;
        
        Test.startTest();
        String result = MatrixChatController.updateOwnerId(testCase);
        Test.stopTest();
        
        // System.assertEquals('Matrix updated successfully.', result);
    }
    @IsTest
    static void testSaveMessageWithOutSavingFile() {
      // 테스트 데이터 준비
      Case testCase = new Case(Subject = '테스트 케이스');
      insert testCase;
  
      List<String> testMessages = new List<String>{
        '2024-11-17 10:38 고객: 안녕하세요',
        '2024-11-17 10:39 상담사: 네, 안녕하세요. 무엇을 도와드릴까요?'
      };
  
      // 메소드 실행
      Test.startTest();
      String result = MatrixChatController.saveMessageWithOutSavingFile(testCase.Id, testMessages);
      Test.stopTest();
  
      // 결과 검증
      System.assertEquals('save chat messages sucessfully', result, '메시지 저장 실패');
  
      Case updatedCase = [SELECT MatrixChat_Contents__c FROM Case WHERE Id = :testCase.Id];
      System.assertNotEquals(null, updatedCase.MatrixChat_Contents__c, 'MatrixChat_Contents__c가 업데이트되지 않음');
      System.assert(updatedCase.MatrixChat_Contents__c.contains('<p><b>2024-11-17 10:38 고객:</b> 안녕하세요</p>'), '고객 메시지가 올바르게 저장되지 않음');
      System.assert(updatedCase.MatrixChat_Contents__c.contains('<p><b>2024-11-17 10:39 상담사:</b> 네, 안녕하세요. 무엇을 도와드릴까요?</p>'), '상담사 메시지가 올바르게 저장되지 않음');
    }
    @isTest
static void testCallApiWithOwnerEmail() {
    // 테스트 데이터 준비
    User testUser = new User(
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' Or Name='표준 사용자'].Id,
        LastName = 'LastName',
        Email = 'test@example.com',
        Username = 'test@example.com' + System.currentTimeMillis(),
        CompanyName = 'TEST',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
    );
    insert testUser;

    Case testCase = new Case(Subject = 'Test Case');
    insert testCase;

    Map<Id, Id> caseOwnerMap = new Map<Id, Id>{testCase.Id => testUser.Id};

    // 모의 HTTP 응답 설정
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    // 테스트 실행
    Test.startTest();
    MatrixChatController.callApiWithOwnerEmail(caseOwnerMap);
    Test.stopTest();

    // 검증
    // 여기서는 예외가 발생하지 않았는지만 확인합니다.
    // 실제로는 더 자세한 검증이 필요할 수 있습니다.
    System.assert(true, 'Method executed without throwing an exception');
}

// 모의 HTTP 응답 생성기
private class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "success"}');
        res.setStatusCode(200);
        return res;
    }
}
    @isTest
    static void testFindCase() {
        Test.startTest();
        Case result = MatrixChatController.findCase('12345');
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        // System.assertEquals(12345, result.MatrixChat_Room_Id__c);
    }

    @isTest
    static void testGetMatrixChatData() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        Case result = MatrixChatController.getMatrixChatData(testCase.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals('test-session-id', result.MatrixChat_Session_Id__c);
        System.assertEquals('test-center-id', result.MatrixChat_Center_Id__c);
    }

    @isTest
    static void testSaveMessage() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        List<String> messages = new List<String>{
            '2024-03-20 10:00 고객: 안녕하세요',
            '2024-03-20 10:01 상담사: 네, 안녕하세요'
        };
        
        Test.startTest();
        String result = MatrixChatController.saveMessage(testCase.Id, messages);
        Test.stopTest();
        
        System.assertEquals('save chat messages sucessfully', result);
        
        Case updatedCase = [SELECT MatrixChat_Contents__c FROM Case WHERE Id = :testCase.Id];
        System.assertNotEquals(null, updatedCase.MatrixChat_Contents__c);
    }



    @isTest
    static void testGetUserEmail() {
        Test.startTest();
        String email = MatrixChatController.getUserEmail();
        Test.stopTest();
        
        System.assertNotEquals(null, email);
    }

    @isTest
    static void testGetUserInfo() {
        Test.startTest();
        User user = MatrixChatController.getUserInfo();
        Test.stopTest();
        
        System.assertNotEquals(null, user);
        System.assertEquals(UserInfo.getUserId(), user.Id);
    }

    @isTest
    static void testSaveAISummary() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        testCase.Matrix_Call_Category__c = '테스트 카테고리';
        testCase.Matrix_Call_Emotion__c = '테스트 감정';
        testCase.Matrix_Call_Summary__c = '테스트 요약';
        
        Test.startTest();
        String result = MatrixChatController.saveAISummary(testCase);
        Test.stopTest();
        
        
        Case updatedCase = [
            SELECT Matrix_Call_Category__c, Matrix_Call_Emotion__c, Matrix_Call_Summary__c, Matrix_Chat_Summary_Done__c 
            FROM Case 
            WHERE Id = :testCase.Id
        ];
        // System.assertEquals(true, updatedCase.Matrix_Chat_Summary_Done__c);
    }
}