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
public with sharing class DN_DealerSalesGoalControllerTest {

    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler',  'DealerSalesGoalTriggerHandler', 'DealerBonusTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        Account dealerAcc;
        Contact dealerCon;

        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            dealerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert dealerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerCon);
            dealer.Lastname = 'dealerName';
            dealer.portalRole = 'Manager';
            insert dealer;

            RecordType dsgRT = TestDataFactoryForSales.getRecordType('DNS_Korea', 'DealerSalesGoal__c');
            DealerSalesGoal__c dsg = new DealerSalesGoal__c(
                Year__c = String.valueOf(Date.today().year()),
                Dealer__c = dealerAcc.Id,
                RecordTypeId = dsgRT.Id,
                Target__c = 1000
            );
            insert dsg;

            DealerBonus__c db = new DealerBonus__c(
                Year__c = String.valueOf(Date.today().year()),
                Dealer__c = dealerAcc.Id,
                Incentive__c = 1000
            );
            insert db;

            List<AlertManager__c> alertList = new List<AlertManager__c>();
            alertList.add(TestDataFactoryForSales.createAlertManager('DealerSalesGoalOwnerUpdateAlert'));
            alertList.add(TestDataFactoryForSales.createAlertManager('DealerBonusOwnerUpdateAlert'));
            insert alertList;
        }
    }


    @isTest
    static void testInitDsg() {

        DealerSalesGoal__c dsg = [SELECT Id FROM DealerSalesGoal__c WHERE Target__c = 1000];
        
        Test.startTest();
        DN_DealerSalesGoalController.getInitSharingModal(dsg.Id);
        Test.stopTest();
    }


    @isTest
    static void testInitDB() {

        DealerBonus__c db = [SELECT Id FROM DealerBonus__c WHERE Incentive__c = 1000];
        
        Test.startTest();
        DN_DealerSalesGoalController.getInitSharingModal(db.Id);
        Test.stopTest();
    }


    @isTest
    static void testChangeOwnerGoal() {

        DealerSalesGoal__c dsg = [SELECT Id FROM DealerSalesGoal__c WHERE Target__c = 1000];
        User dealer = [SELECT Id FROM User WHERE Lastname ='dealerName'];

        Test.startTest();
        DN_DealerSalesGoalController.changeOwner(dsg.Id, dealer.Id);
        Test.stopTest();
    }


    @isTest
    static void testChangeOwnerBonus() {

        DealerBonus__c db = [SELECT Id FROM DealerBonus__c WHERE Incentive__c = 1000];
        User dealer = [SELECT Id FROM User WHERE Lastname ='dealerName'];

        Test.startTest();
        DN_DealerSalesGoalController.changeOwner(db.Id, dealer.Id);
        Test.stopTest();
    }
}