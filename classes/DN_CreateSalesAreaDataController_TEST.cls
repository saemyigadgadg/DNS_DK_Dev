/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 05-30-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-13-2025   Hanyeong Choi   Initial Version
**/
@isTEST
public with sharing class DN_CreateSalesAreaDataController_TEST {
    @TestSetup
    static void setUp() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        TriggerHandler.bypass('AccountTriggerHandler');
        Country__c krCountry = TestDataFactoryForSales.createKRCountry();
        insert new List<Country__c>{krCountry};
        
        // Region 생성
        Region__c krRegion = TestDataFactoryForSales.createRegion('제주도', 'KRW', '01', krCountry.Id);
        insert new List<Region__c>{krRegion};

        Account tradeAccount = TestDataFactoryForSales.createAccount('TradeCustomer', krCountry, null);
        tradeAccount.Name = 'asdasd';
        tradeAccount.RegionLookup__c = krRegion.Id;
        insert tradeAccount;

        SalesAreaData__c sad = TestDataFactoryForSales.createAreaData(tradeAccount);
        sad.SalesOrganization__c = '1846';
        sad.SalesOffice__c = '114E';
        insert sad;

        Account tradeAccount2 = TestDataFactoryForSales.createAccount('TradeCustomer', krCountry, null);
        tradeAccount2.Name = 'test2';
        tradeAccount2.BusinessNumber__c = '5148171779';
        tradeAccount2.RegionLookup__c = krRegion.Id;
        insert tradeAccount2;

        SalesAreaData__c sad1 = TestDataFactoryForSales.createAreaData(tradeAccount2);
        sad1.SalesOrganization__c = '4146';
        sad1.SalesOffice__c = '114E';
        insert sad1;
    }

    @isTest
    static void initSalesAreaData_Test() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'asdasd' LIMIT 1];

        Test.startTest();
        DN_CreateSalesAreaDataController.initSalesAreaData(acc.Id);
        Test.stopTest();
    }

    @isTest
    static void insertSalesAreaData_Test() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-018', 'IF_ERP_Account');
        Account acc = [SELECT Id FROM Account WHERE Name = 'asdasd' LIMIT 1];

        Test.startTest();
        DN_CreateSalesAreaDataController.insertSalesAreaData(acc.Id);
        Test.stopTest();
    }

    @isTest
    static void insertSalesAreaData_Test2() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-018', 'IF_ERP_Account');
        Account acc = [SELECT Id FROM Account WHERE Name = 'test2' LIMIT 1];

        Test.startTest();
        DN_CreateSalesAreaDataController.insertSalesAreaData(acc.Id);
        Test.stopTest();
    }
}