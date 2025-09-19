/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-03-19
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-03-19   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public without sharing class DN_AssignManagerButtonControllerTest {

    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'UserTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        User dealerWorker;
        Account dealerAcc;
        System.runAs(thisUser) {

            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.Name = 'test Dealer';
            dealerAcc.CustomerCode__c = '22222';
            dealerAcc.Phone = '111-222';
            insert dealerAcc;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;

            Contact dealerConWorker = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            dealerConWorker.Lastname = 'Worker User';
            insert dealerConWorker;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer.portalRole = 'Manager';
            insert dealer;

            dealerWorker = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerConWorker);
            dealerWorker.portalRole = 'Worker';
            insert dealerWorker;

            //User
            User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            kaUser.Lastname = 'ManagerUser';
            insert kaUser;

            //MessageGroup__c
            MessageGroup__c msgKR = new MessageGroup__c(
                Name = 'KA MSG', 
                Country__c = country.Id, 
                SalesDistrict__c = 'Korea',
                SalesOffice__c = '114E'
            );
            insert msgKR;
    
            //MessageGroup__c
            MessageGroup__c msgGlobal = new MessageGroup__c(
                Name = 'KA MSG Global', 
                Country__c = country.Id, 
                SalesDistrict__c = 'Global',
                SalesOffice__c = '114E'
            );
            insert msgGlobal;
    
            //MessageGroup__c
            MessageGroup__c msgNoJunc = new MessageGroup__c(
                Name = 'KA MSG NoJunc', 
                Country__c = country.Id, 
                SalesDistrict__c = 'Korea',
                SalesOffice__c = '114E'
            );
            insert msgNoJunc;
    
            //MessageGroup__c
            MessageGroup__c msgTwoJunc = new MessageGroup__c(
                Name = 'KA MSG TwoJunc', 
                Country__c = country.Id, 
                SalesDistrict__c = 'Korea',
                SalesOffice__c = '114E'
            );
            insert msgTwoJunc;
    
            //Message_Group_Junction__c
            Message_Group_Junction__c msgJunc = new Message_Group_Junction__c(
                Message_Group__c = msgKR.Id,
                User__c = kaUser.Id
            );
            insert msgJunc;
    
            //Message_Group_Junction__c
            Message_Group_Junction__c msgJunc1 = new Message_Group_Junction__c(
                Message_Group__c = msgTwoJunc.Id,
                User__c = kaUser.Id
            );
            insert msgJunc1;
    
            //Message_Group_Junction__c
            Message_Group_Junction__c msgJunc2 = new Message_Group_Junction__c(
                Message_Group__c = msgTwoJunc.Id,
                User__c = kaUser.Id
            );
            insert msgJunc2;
        }
    }


    @isTest
    static void testcheckManagerInfo(){

        MessageGroup__c msgKR = [SELECT Id, Name, Country__c, SalesDistrict__c, SalesOffice__c FROM MessageGroup__c WHERE Name = 'KA MSG'];

        Test.startTest();
        DN_AssignManagerButtonController.checkManagerInfo(msgKR.Id);
        Test.stopTest();
    }


    @isTest
    static void testcheckNoJunction(){

        MessageGroup__c msgNoJunc = [SELECT Id, Name, Country__c, SalesDistrict__c, SalesOffice__c FROM MessageGroup__c WHERE Name = 'KA MSG NoJunc'];

        Test.startTest();
        DN_AssignManagerButtonController.checkManagerInfo(msgNoJunc.Id);
        Test.stopTest();
    }


    @isTest
    static void testAssignManagertoUserKorea(){

        MessageGroup__c msgKR = [SELECT Id, Name, Country__c, SalesDistrict__c, SalesOffice__c FROM MessageGroup__c WHERE Name = 'KA MSG'];
        User kaUser = [SELECT Id, UserRole.PortalRole FROM User WHERE Lastname = 'ManagerUser'  ];

        Test.startTest();
        DN_AssignManagerButtonController.assignManagertoUser(msgKR, kaUser);
        Test.stopTest();
    
    }


    @isTest
    static void testAssignManagertoUserGlobal(){

        MessageGroup__c msgGlobal = [SELECT Id, Name, Country__c, SalesDistrict__c, SalesOffice__c FROM MessageGroup__c WHERE Name = 'KA MSG Global'];
        User kaUser = [SELECT Id, UserRole.PortalRole FROM User WHERE Lastname = 'ManagerUser'  ];

        Test.startTest();
        DN_AssignManagerButtonController.assignManagertoUser(msgGlobal, kaUser);
        Test.stopTest();
    
    }


}