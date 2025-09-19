@isTest
public class MatrixCaseChatTriggerTest {
    

    
    @isTest
    static void testCaseCallbackTrigger() {
        // 테스트 데이터 준비

        
        Case testCase = new Case(
            Subject = '콜백 테스트',
            Status = 'New',
            Matrix_Call_Type__c = 'Callback',

            OwnerId = UserInfo.getUserId()
        );
        insert testCase;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' Or Name='Standard User'];
        User newUser = new User(
            Alias = 'standt',
            Email = 'standarduser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser@test.com' + DateTime.now().getTime()
        );
        insert newUser;
        
        Test.startTest();
        
        // Case 상태를 Closed로 업데이트
        testCase.OwnerId =newUser.Id;
        update testCase;
        
        Test.stopTest();
        
    }
    

}