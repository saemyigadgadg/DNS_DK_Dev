/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-03-27
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-01-10   yuhyun.park@sbtglobal.com   Initial Version
**/

@isTest
private class DealerAssociationTriggerHandlerTest {

    private static final Id   accCustomerRT     = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id   accDealerRT       = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id   contactPersonRT   = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ContactPerson').getRecordTypeId();
    private static final Id   conDealerRT       = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();


    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'DealerBonusTriggerHandler' };
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

        System.runAs(dealer){


            DealerBonus__c db = new DealerBonus__c(
                Dealer__c = dealerAcc.Id,
                CustomerCode__c = '22222',
                Year__c = '2025',
                Month__c = '01'
            );
            insert db;
        }
    }


    @isTest
    static void testGrantAccessToCustomer() {
        // Retrieve test data
        Account customerAccount = [SELECT Id FROM Account WHERE Name = 'Test Customer' LIMIT 1];
        Account dealerAccount = [SELECT Id FROM Account WHERE Name = 'Test Dealer' LIMIT 1];
    
        // Trigger the logic by inserting a new DNS_CustomerDealerAssociation__c record
        DNS_CustomerDealerAssociation__c newCda = new DNS_CustomerDealerAssociation__c(
            Customer__c = customerAccount.Id,
            Dealer__c = dealerAccount.Id
        );
        insert newCda;
    }
    
    

    @isTest
    static void testDeleteAccessToCustomer() {
        // Get test data
        Account customerAccount = [SELECT Id FROM Account WHERE Name = 'Test Customer' LIMIT 1];
        Account dealerAccount = [SELECT Id FROM Account WHERE Name = 'Test Dealer' LIMIT 1];
        DNS_CustomerDealerAssociation__c cdaRecord = [
            SELECT Id FROM DNS_CustomerDealerAssociation__c WHERE Customer__c = :customerAccount.Id LIMIT 1
        ];

        delete cdaRecord;

    }

}