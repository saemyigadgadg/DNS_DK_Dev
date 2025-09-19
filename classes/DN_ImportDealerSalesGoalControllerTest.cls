/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-20
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-20   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_ImportDealerSalesGoalControllerTest {

    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account prospectAcc = TestDataFactoryForSales.createAccount('ProspectCustomer', country, null);
            prospectAcc.CustomerCode__c = '11111';
            insert prospectAcc; 

            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.Name = 'test Dealer';
            dealerAcc.CustomerCode__c = '22222';
            dealerAcc.Phone = '111-222';

            insert dealerAcc;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;
            
        }
    }


    @isTest
    static void testGetUserInfo(){
        Test.startTest();
        User u = DN_ImportDealerSalesGoalController.getUserInfo();
        Test.stopTest();
    }

    
    @isTest
    static void testKoreaInsert() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "22222", ' +
                '"Column_2": 3000, ' +
                '"Column_3": 3000, ' +
                '"Column_4": 3000, ' +
                '"Column_5": 3000, ' +
                '"Column_6": 3000, ' +
                '"Column_7": 3000, ' +
                '"Column_8": 2000, ' +
                '"Column_9": 2000, ' +
                '"Column_10": 2000, ' +
                '"Column_11": 2000, ' +
                '"Column_12": 2000, ' +
                '"Column_13": 5000' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerSalesGoalController.insertRecords(jsonInput, 'Korea', '2025');
        Test.stopTest();
    }

    
    @isTest
    static void testGlobalInsert() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "22222", ' +
                '"Column_2": 10000' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerSalesGoalController.insertRecords(jsonInput, 'Global', '2025');
        Test.stopTest();
    }
    
    @isTest
    static void testKoreaUndefined() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "", ' +
                '"Column_2": 10000' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerSalesGoalController.insertRecords(jsonInput, 'Korea', '2025');
        Test.stopTest();
    }

    
    @isTest
    static void testGlobalUndefined() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "", ' +
                '"Column_2": 10000' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerSalesGoalController.insertRecords(jsonInput, 'Global', '2025');
        Test.stopTest();
    }

    
}