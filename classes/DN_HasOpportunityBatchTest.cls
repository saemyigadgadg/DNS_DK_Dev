/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-05-29
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-05-29   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_HasOpportunityBatchTest {
    
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        // Country__c country = TestDataFactoryForSales.createCountry('USA', 'USD', 'US');
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Region__c region = TestDataFactoryForSales.createRegion('KRRegion', 'KRW', 'KRR', country.Id);
        insert region;


        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dnsaAcc = TestDataFactoryForSales.createAccount('DNSACustomer', country, null);
            dnsaAcc.CustomerCode__c = '11111';
            dnsaAcc.Name = 'DNSACustomer';
            dnsaAcc.Representative__c = 'DNSARep';
            dnsaAcc.Converted__c = true;
            insert dnsaAcc; 

            Contact contactPerson = TestDataFactoryForSales.createContact('ContactPerson', dnsaAcc.Id);
            insert contactPerson;

            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.Name = 'test Dealer';
            dealerAcc.CustomerCode__c = '22222';
            dealerAcc.Phone = '111-222';
            insert dealerAcc;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer.SalesOrganization__c = '4140';
            insert dealer;

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(dnsaAcc, dealer, 'DNSA');
            opty.ETOpportunityId__c = 'Id';
            insert opty;
    
            Date yesterdayDate = Date.today().addDays(-1);
            DateTime yesterdayAtNoon = DateTime.newInstance(
                yesterdayDate.year(), 
                yesterdayDate.month(), 
                yesterdayDate.day(), 
                12, 0, 0
            );
    
            Test.setCreatedDate(opty.Id, yesterdayAtNoon);
        }
    }


    @isTest
    static void testBatchExecution(){
        Test.startTest();
        DN_HasOpportunityBatch batchJob = new DN_HasOpportunityBatch();
        String jobId = System.schedule('Test Scheduled Batch', '0 0 0 1 1 ? 2050', batchJob);
        Database.ExecuteBatch(batchJob, 5);
        Test.stopTest();
    }
}