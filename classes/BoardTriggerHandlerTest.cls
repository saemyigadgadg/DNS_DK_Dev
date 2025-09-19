/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-12-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class BoardTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, Type.forName('DN_ServiceAppointmentControllerTest.IF_SWEET_TRACKER_HttpMock').newInstance());

        EmailTemplate eTem = [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 1];
        CustomNotificationType noti = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        Alimtalk_Tamplate__mdt alarmTem = [SELECT Id, TemplateCode__c FROM Alimtalk_Tamplate__mdt LIMIT 1];
        
        List<AlertManager__c> insertAlertList = new List<AlertManager__c>();
        AlertManager__c alertManager1 = new AlertManager__c();
        alertManager1.Name = 'CS Announcement Noti';
        alertManager1.Part__c = 'Service';
        alertManager1.IsActive__c = true;
        alertManager1.Description__c = 'Test';
        insertAlertList.add(alertManager1);
        AlertManager__c alertManager2 = new AlertManager__c();
        alertManager2.Name = 'CS QnA Noti';
        alertManager2.Part__c = 'Service';
        alertManager2.IsActive__c = true;
        alertManager2.Description__c = 'Test';
        insertAlertList.add(alertManager2);
        insert insertAlertList;

        AlertAlarmTalkTemplate__c alertAlarm = new AlertAlarmTalkTemplate__c();
        alertAlarm.Name = 'TestAlarm';
        alertAlarm.AlertManagerID__c = alertManager1.Id;
        alertAlarm.AlarmTalkTemplateCode__c = alarmTem.TemplateCode__c;
        alertAlarm.Language__c = 'ko';
        alertAlarm.Name = 'TestAlarm';
        insert alertAlarm;

        Interface__c testInterface = new Interface__c();
        testInterface.Name = 'Sweet_Tracker_SendMessage_Op';
        testInterface.EndpointURL__c = 'https://alimtalk-api.sweettracker.net/v2';
        testInterface.HttpMethod__c = 'POST';
        testInterface.ContentType__c = 'application/json; charset=UTF-8';
        testInterface.Timeout__c = 120000;
        testInterface.System__c = 'SWEET TRAKER';
        testInterface.IsActive__c = true;
        insert testInterface;

        InterfaceClasses__c testInterface2 = new InterfaceClasses__c();
        testInterface2.Name = 'IF_SWEET_TRACKER';
        insert testInterface2;
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        // 알림 매니저 생성
        insert new AlertManager__c(Name = 'CS Announcement Noti', IsActive__c = true);
        insert new AlertManager__c(Name = 'CS QnA Noti', IsActive__c = true);
    }

    @isTest
    static void testInsertTrigger() {
        // RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Q & A' AND SObjectType = 'Board__c' LIMIT 1];
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        AlertManager__c alert = [SELECT Id FROM AlertManager__c WHERE Name = 'CS Announcement Noti' LIMIT 1];

        Test.startTest();
        Board__c b = new Board__c(
            Name = 'Test Post',
            ContentTextarea__c = 'This is test content.',
            // RecordTypeId = rt.Id,
            OwnerId = user1.Id
        );
        insert b;
        Test.stopTest();

        Board__c inserted = [SELECT Id, PostingDate__c FROM Board__c WHERE Id = :b.Id];
    }

    @isTest
    static void testUpdateTriggerSetAnswer() {

        // RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Q & A' AND SObjectType = 'Board__c' LIMIT 1];
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        AlertManager__c alert = [SELECT Id FROM AlertManager__c WHERE Name = 'CS QnA Noti' LIMIT 1];


        Board__c b = new Board__c(
            Name = 'Test Q',
            ContentTextarea__c = 'Test?',
            // RecordTypeId = rt.Id,
            OwnerId = user1.Id
        );
        insert b;

        Test.startTest();
        b.AnswerContent__c = 'This is an answer.';
        update b;
        Test.stopTest();

        Board__c updated = [SELECT AnswerContent__c, DateOfReply__c, Respondent__c FROM Board__c WHERE Id = :b.Id];
    }

    @isTest
    static void testNoAlertIfNotQnA() {
        // Q & A 아닌 레코드타입
        // RecordType rt = new RecordType(
        //     SObjectType = Board__c.SObjectType,
        //     DeveloperName = 'General',
        //     Name = 'General',
        //     IsActive = true
        // );
        // insert rt;

        Board__c b = new Board__c(
            Name = 'Not QnA',
            ContentTextarea__c = 'Some content.'
            // RecordTypeId = rt.Id
        );

        Test.startTest();
        insert b;
        Test.stopTest();

        Board__c inserted = [SELECT Id FROM Board__c WHERE Id = :b.Id];
    }
}