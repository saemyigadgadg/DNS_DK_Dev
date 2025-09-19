/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-18
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-04-18   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_NewContactRelationBatchTest {
    private static final Id   accCustomerRT     = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id   accDealerRT       = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id   contactPersonRT   = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ContactPerson').getRecordTypeId();
    private static final Id   conDealerRT       = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();


    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        Account dealerAcc;
        Account prospectAcc;
        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.Name = 'test Dealer';
            dealerAcc.CustomerCode__c = '22222';
            dealerAcc.Phone = '111-222';
            insert dealerAcc;

            Account anotherDealer = TestDataFactoryForSales.createAccount('Dealer', country, null);
            anotherDealer.Name = 'anotherDealer';
            anotherDealer.CustomerCode__c = '33333';
            anotherDealer.Phone = '111-222-33';
            insert anotherDealer;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;

            prospectAcc = TestDataFactoryForSales.createAccount('ProspectCustomer', country, null);
            prospectAcc.Name = 'Test Customer';
            insert prospectAcc;

            DNS_CustomerDealerAssociation__c cdaRecord = new DNS_CustomerDealerAssociation__c(
                Customer__c = prospectAcc.Id,
                Dealer__c = dealerAcc.Id
            );
            insert cdaRecord;

        }
    }

    @isTest
    static void testBatchExecution(){
        Test.startTest();
        DN_NewContactRelationBatch batchJob = new DN_NewContactRelationBatch('');
        Database.ExecuteBatch(batchJob, 5);
        Test.stopTest();

    }

}