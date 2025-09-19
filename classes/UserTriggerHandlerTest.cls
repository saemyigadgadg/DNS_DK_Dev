/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-03-06
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-03-06   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class UserTriggerHandlerTest {

    @TestSetup
    static void makeData(){

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'UserTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account dealerAcc;
        Contact dealerCon;
        User dealer;

        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            dealerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert dealerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerCon);
            dealer.LastName = 'dealerUser';
            insert dealer;
        }
    }


    @isTest
    static void testInsert(){

        Test.startTest();

        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        String uniqueSuffix = String.valueOf(Datetime.now().getTime());
        
        User newUser = new User(
            Alias = 'newusr',
            Email = 'newuser' + uniqueSuffix + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'newuser' + uniqueSuffix + '@example.com'
        );
        
        insert newUser;

        Test.stopTest();
    }


    @isTest
    static void testUpdatePhone(){

        Test.startTest();
        User user = [SELECT Id, Phone FROM User WHERE LastName = 'dealerUser'];
        user.Phone  = '02-1111-2222';
        update user;
        Test.stopTest();
    }


    @isTest
    static void testUpdateFax(){

        Test.startTest();
        User user = [SELECT Id, Phone FROM User WHERE LastName = 'dealerUser'];
        user.Fax = '02-1111-2222';
        update user;
        Test.stopTest();
    }


    @isTest
    static void testUpdateMobile(){

        Test.startTest();
        User user = [SELECT Id, Phone FROM User WHERE LastName = 'dealerUser'];
        user.MobilePhone = '02-1111-2222';
        update user;
        Test.stopTest();
    }


    @isTest
    static void testUpdateEmail(){

        Test.startTest();
        User user = [SELECT Id, Phone FROM User WHERE LastName = 'dealerUser'];
        user.Email = 'newEmail@email.com';
        update user;
        Test.stopTest();
    }


    @isTest
    static void testUpdateActive(){

        Test.startTest();
        User user = [SELECT Id, Phone FROM User WHERE LastName = 'dealerUser'];
        user.IsActive = false;
        update user;
        Test.stopTest();
    }

}