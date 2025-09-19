/**
 * @description       : 
 * @author            : sunwoong.han@dkbmc.com
 * @group             : 
 * @last modified on  : 2025-09-19
 * @last modified by  : sunwoong.han@dkbmc.com
**/
@isTest
public with sharing class DN_C_ExceptionManager_Test {
    class TestException extends Exception{}

    @TestSetup
    static void makeData(){
        insert new ExceptionManager__c(
            Name = 'test',
            Email__c = 'test01@testcode01.com.dev',
            IsActive__c = true
        );
    }

    @IsTest
    static void test01(){
        Test.startTest();
        try {
            throw new TestException('test exception...');
        } catch (TestException e) {
            DN_C_ExceptionManager.doCatch(
                e,
                new List<String>{'test1', 'test2', 'test3'}
            );
            DN_C_ExceptionManager.finishCatch();
        }
        Test.stopTest();
    }
}