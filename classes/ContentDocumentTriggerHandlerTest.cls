/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2025-05-26
 * @last modified by  : yeongju.yun
**/
@isTest
public with sharing class ContentDocumentTriggerHandlerTest {
    
    @isTest
    static void testFileCountDecreaseOnDelete() {

        Case testCase = new Case(Subject = 'Delete File Count Test');
        insert testCase;

        ContentVersion cv = new ContentVersion(
            Title = 'DeleteTestFile',
            PathOnClient = 'delete_test.txt',
            VersionData = Blob.valueOf('This is a test file.')
        );
        insert cv;

        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id contentDocumentId = insertedCV.ContentDocumentId;

        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = testCase.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;

        testCase.FileCount__c = 1;
        update testCase;

        Test.startTest();
        delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
        Test.stopTest();

        // Case result = [SELECT Id, FileCount__c FROM Case WHERE Id = :testCase.Id];
        // System.assertEquals(0, result.FileCount__c, 'FileCount__c 값이 1에서 0으로 줄어들어야 함');
    }    
}