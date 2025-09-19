/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-27
 * @last modified by  : yeongdeok.seo@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-27   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class TriggerManager_TEST {
    public TriggerManager_TEST() {}

    @isTest
    static void testPrepareAndExecute() {
        // Given: A mock Trigger context
        Test.startTest();

        // Trigger context 설정을 흉내 내기 위한 dummy data
        Account acc = new Account(Name='Test Account');
        insert acc;

        List<Account> newList = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        Map<Id, SObject> newMap = new Map<Id, SObject>{ acc.Id => acc };

        TriggerManager instance = TriggerManager.prepare();
        AccountTriggerHandler handler = new AccountTriggerHandler();

        instance.bind(handler).execute();

    }

    @isTest
    static void testAvoidRecursion() {
        // 초기에는 true 반환
        Boolean firstRun = TriggerManager.avoidRecursion();
        // 이후에는 false 반환
        Boolean secondRun = TriggerManager.avoidRecursion();

    }
}