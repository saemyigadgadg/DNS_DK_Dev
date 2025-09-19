/**
 * @description       : DN_LaunchingExcellenceUploadTest
 * @author            : Hayeong Min
 * @last test date    : 2025-04-01
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_LaunchingExcellenceUploadTest {
    @TestSetup
    static void makeData(){
        String scheduleId = Schema.SObjectType.LaunchingExcellenceDoc__c.getRecordTypeInfosByDeveloperName().get('InstallSchedule').getRecordTypeId();

        LaunchingExcellenceDoc__c lcDoc = new LaunchingExcellenceDoc__c();
        lcDoc.RecordTypeId = scheduleId;
        insert lcDoc;

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test File';
        contentVersion.PathOnClient = 'testfile.txt';
        contentVersion.VersionData = Blob.valueOf('This is a test file.');
        contentVersion.IsMajorVersion = true;
        insert contentVersion;

        ContentVersion insertedVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id
            LIMIT 1
        ];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = insertedVersion.ContentDocumentId;
        cdl.LinkedEntityId = lcDoc.Id;
        cdl.ShareType = 'V'; // Viewer access
        cdl.Visibility = 'AllUsers';
        insert cdl;

    }

    @isTest
    static void testCreatePublicLink(){  
        String scheduleId = Schema.SObjectType.LaunchingExcellenceDoc__c.getRecordTypeInfosByDeveloperName().get('InstallSchedule').getRecordTypeId();  
        LaunchingExcellenceDoc__c lcDoc = [SELECT Id FROM LaunchingExcellenceDoc__c WHERE RecordTypeId = :scheduleId LIMIT 1];
        ContentVersion doc = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Title = 'Test File' LIMIT 1];
        Test.startTest();
        DN_LaunchingExcellenceUploadController.createPublicLink(lcDoc.Id, doc.Id, 'Test File');
        Test.stopTest();
    }

    @isTest
    static void testInitInfo(){    
        String scheduleId = Schema.SObjectType.LaunchingExcellenceDoc__c.getRecordTypeInfosByDeveloperName().get('InstallSchedule').getRecordTypeId();
        LaunchingExcellenceDoc__c doc = [SELECT Id FROM LaunchingExcellenceDoc__c WHERE RecordTypeId = :scheduleId LIMIT 1];
        Test.startTest();
        DN_LaunchingExcellenceUploadController.getInitInfo(scheduleId);
        DN_LaunchingExcellenceUploadController.getInitInfo('');
        Test.stopTest();
    } 
    
    @isTest
    static void testDeleteRec(){   
        String scheduleId = Schema.SObjectType.LaunchingExcellenceDoc__c.getRecordTypeInfosByDeveloperName().get('InstallSchedule').getRecordTypeId();
        LaunchingExcellenceDoc__c doc = [SELECT Id FROM LaunchingExcellenceDoc__c WHERE RecordTypeId = :scheduleId LIMIT 1];
        Test.startTest();
        DN_LaunchingExcellenceUploadController.deleteRec(doc.Id);
        DN_LaunchingExcellenceUploadController.deleteRec('');
        Test.stopTest();
    }

    @isTest
    static void testDeleteDoc(){    
        ContentVersion doc = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test File' LIMIT 1];
        Test.startTest();
        DN_LaunchingExcellenceUploadController.deleteDoc(doc.ContentDocumentId);
        DN_LaunchingExcellenceUploadController.deleteDoc('');
        Test.stopTest();
    }
}