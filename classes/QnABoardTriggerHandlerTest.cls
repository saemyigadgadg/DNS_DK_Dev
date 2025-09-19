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
public with sharing class QnABoardTriggerHandlerTest {
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
            // 부모 QnA (질문)
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

            Email_Recipient__c eRep = new Email_Recipient__c(
                isActive__c = true
                ,Category__c = '82'
                ,RecipientType__c = 'To'
                ,RecipientName__c = 'testRepUser'
                ,RecipientEmail__c = 'test@test.test'
            );
            insert eRep;

            Email_Recipient__c eRep2 = new Email_Recipient__c(
                isActive__c = true
                ,Category__c = '82'
                ,RecipientType__c = 'Cc'
                ,RecipientName__c = 'testRepUser2'
                ,RecipientEmail__c = 'test2@test.test'
            );
            insert eRep2;
        }
    }

    @isTest
    static void Test_Insert_Question() {
        User testUser = [SELECT Id, Email FROM User WHERE Email = 'testOwner@testDealer.com' LIMIT 1];
        
        QnABoard__c que = new QnABoard__c(
            Title__c = '신규 질문',
            Category__c = '82',
            RecordTypeId = question,
            Email__c = testUser.Email,
            OwnerId = testUser.Id
        );

        Test.startTest();
        insert que;
        Test.stopTest();
    }

    @isTest
    static void Test_Upsert_Answer() {
        User testUser = [SELECT Id, Email FROM User WHERE Email = 'testOwner@testDealer.com' LIMIT 1];
        QnABoard__c ans = [SELECT Id, Status__c, Parent__r.Name, RecordTypeId FROM QnABoard__c WHERE Status__c = '진행중' LIMIT 1];
        ans.Status__c = '완료';

        
        Test.startTest();
        update ans;
        Test.stopTest();
    }
}