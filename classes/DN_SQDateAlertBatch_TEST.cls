/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 05-30-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-02-2025   Hanyeong Choi   Initial Version
**/
@isTest(SeeAllData=true)
public with sharing class DN_SQDateAlertBatch_TEST {
    @isTest
    static void testCoverage() {
        Test.startTest();
        DN_SQDateAlertBatch batch = new DN_SQDateAlertBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void testGetMessageGroupJunctions() {
        List<MessageGroup__c> mg = [SELECT Id FROM MessageGroup__c LIMIT 1];
        Set<Id> asd = new Set<Id>();
        asd.add(mg[0].Id);
        Test.startTest();
        DN_SQDateAlertBatch batch = new DN_SQDateAlertBatch();
        if (!mg.isEmpty()) {
            batch.getMessageGroupJunctions(asd);
        }
        Test.stopTest();
    }

    @isTest
    static void testAddFromManagers() {
        List<User> userList = [SELECT Id, Email, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Test.startTest();
        DN_SQDateAlertBatch batch = new DN_SQDateAlertBatch();
        DN_SQDateAlertBatch.Recipients recTest = new DN_SQDateAlertBatch.Recipients();
        recTest.addFromManagers(userList);
        Test.stopTest();
    }

    @isTest
    static void testAddFromMessageGroups() {
        List<Message_Group_Junction__c> mgjList = [SELECT Id, User__c, FM_UserEmail__c, FM_UserLanguage__c FROM Message_Group_Junction__c LIMIT 1];
        Test.startTest();
        DN_SQDateAlertBatch batch = new DN_SQDateAlertBatch();
        DN_SQDateAlertBatch.Recipients recTest = new DN_SQDateAlertBatch.Recipients();
        if (!mgjList.isEmpty()) {
            recTest.addFromMessageGroups(mgjList);
        }
        Test.stopTest();
    }
}