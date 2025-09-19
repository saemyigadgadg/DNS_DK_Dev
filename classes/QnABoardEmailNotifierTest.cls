/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 04-09-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-02-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class QnABoardEmailNotifierTest {
    private static Id question = Schema.SObjectType.QnABoard__c.getRecordTypeInfosByDeveloperName().get('Question').getRecordTypeId();
    private static Id answer   = Schema.SObjectType.QnABoard__c.getRecordTypeInfosByDeveloperName().get('Answer').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Profile adminPf = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
        UserRole dealerRole = new UserRole(Name = 'partDealerRole');
        insert dealerRole;
        
        User u = new User (
            UserName                 = 'testOwner@testDealer.com'
            ,Email                   = 'testOwner@testDealer.com'
            ,Alias                   = 'testOwn'
            ,TimeZoneSidKey          = 'Asia/Seoul'
            ,LocaleSidKey            = 'ko'
            ,EmailEncodingKey        = 'UTF-8'
            ,LastName                = 'Owner'
            ,LanguageLocaleKey       = 'en_US'
            ,ProfileId               = adminPf.Id
            ,UserRoleId              = dealerRole.Id  
            ,SalesOrganization__c    = '1846'
            ,DistributionChannel__c  = '10'
            ,Division__c             = '40'
        );

        insert u;

        system.runAs(u) {
            QnABoard__c parentQ = new QnABoard__c(
                Title__c     = 'Test Question',
                Email__c     = u.Email,
                RecordTypeId = question,
                Contents__c  = 'Contents',
                OwnerId      = u.Id
            );
            insert parentQ;

            QnABoard__c childA = new QnABoard__c(
                RecordTypeId  = answer,
                Contents__c   = 'Contents answer',
                Status__c     = '진행중',
                MainParent__c = parentQ.Id,
                Parent__c     = parentQ.Id,
                OwnerId       = u.Id
            );
            insert childA;

            AlertManager__c am = new AlertManager__c(
                Name         = 'QnA Notification Email'
                ,Part__c     = 'Partner'
                ,IsActive__c = true
            );
            insert am;
        }
    }

    @isTest
    static void Test_Send_Email() {
        List<String> repEmailList = new List<String>{'test@test.com'};
        List<String> repEmailListCC = new List<String>{'test@test.com'};
        String qnaId = [SELECT Id, Title__c FROM QnABoard__c WHERE Title__c = 'Test Question' LIMIT 1].Id;
        String recordType = 'Question';
        String recordType2 = 'Answer';

        Test.startTest();
        QnABoardEmailNotifier.SendCreationNotification(repEmailList, repEmailListCC, qnaId, recordType);
        QnABoardEmailNotifier.SendCreationNotification(repEmailList, repEmailListCC, qnaId, recordType);
        QnABoardEmailNotifier.getAnswersByMainParent(qnaId);
        Test.stopTest();
    }
}