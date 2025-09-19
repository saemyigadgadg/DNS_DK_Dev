/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-04-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class DN_AnnouncementControllerTest {

    @testSetup
    static void setupTestData() {
        String testProfile = UserInfo.getProfileId();

        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Board__c board = new Board__c(
            Name = 'Test Q&A',
            // RecordTypeId = rt.Id,
            NoticeTarget__c = 'Field Service',
            QuestionContent__c = 'What is the issue?',
            PostingDate__c = Date.today()
        );
        insert board;

        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv;

        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id LIMIT 1];
        insert new ContentDocumentLink(
            LinkedEntityId = board.Id,
            ContentDocumentId = cd.Id,
            ShareType = 'V'
        );

        // ContentDistribution dist = new ContentDistribution(
        //     Name = 'Test Distribution',
        //     ContentVersionId = cv.Id,
        //     PreferencesAllowViewInBrowser = true
        // );
        // insert dist;

        insert new AlertManager__c(
            Name = 'CS Announcement Noti',
            IsActive__c = true
        );

        insert new ServiceResource(
            Name = 'Test Resource',
            RelatedRecordId = user1.Id,
            IsActive = true,
            Branch__c = 'DNS',
            ResourceType = 'T'
        );
    }

    @isTest
    static void testGetBoard() {
        Test.startTest();
        List<Map<String, Object>> result = DN_AnnouncementController.getBoard();
        Test.stopTest();
    }

    @isTest
    static void testGetBoardsWithSortBy() {
        Test.startTest();
        List<Map<String, Object>> result = DN_AnnouncementController.getBoards('announceDate');
        Test.stopTest();
    }

    @isTest
    static void testSendNotification() {
        Board__c board = [SELECT Id FROM Board__c WHERE NoticeTarget__c = 'Field Service' LIMIT 1];
        Test.startTest();
        DN_AnnouncementController.sendNotification(board.Id);
        Test.stopTest();
    }

    @isTest
    static void testCreateQnA() {
        Test.startTest();
        DN_AnnouncementController.createQnA('Test New QnA', String.valueOf(Date.today()), 'New QnA content');
        Test.stopTest();

        List<Board__c> qnaList = [SELECT Id, Name FROM Board__c WHERE Name = 'Test New QnA'];
    }
}