/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-10
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-10   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_DealerTrendingBatchTest {

    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.SalesOrganization__c = '1800';
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            delaerCon.SalesOrganization__c = '1800';
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;
        }
    }


    @isTest
    static void testBatchExecution(){
        Test.startTest();
        DN_DealerTrendingBatch batchJob = new DN_DealerTrendingBatch();
        String jobId = System.schedule('Test Scheduled Batch', '0 0 0 1 1 ? 2050', batchJob);
        Database.ExecuteBatch(batchJob, 5);
        Test.stopTest();
    }


}