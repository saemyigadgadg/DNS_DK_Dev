/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-03-18
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-24   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_RefreshDealerSalesGoalControllerTest {

    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'DealerSalesGoalTriggerHandler' ,'DealerSalesPlanTriggerHandler'};
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
            insert dealer;
        }

        System.runAs(dealer) {
            RecordType dsgRT = TestDataFactoryForSales.getRecordType('DNSA', 'DealerSalesGoal__c');
            RecordType dspRT = TestDataFactoryForSales.getRecordType('DNSA', 'DealerSalesPlan__c');

            DealerSalesGoal__c dsgCurrent = new DealerSalesGoal__c(
                Year__c = String.valueOf(Date.today().year()),
                Dealer__c = dealerAcc.Id,
                PreviousActual_OrderUnit__c = 120,
                PreviousActual_OrderAmount__c = 2400,
                PreviousActual_HEOrderUnit__c = 150,
                PreviousActual_AutomationOrderUnit__c = 3500,
                PreviousMarketShare__c = 0.2,
                RecordTypeId = dsgRT.Id
            );
            insert dsgCurrent;

            DealerSalesPlan__c dspCurrent = new DealerSalesPlan__c(
                Name = 'CurrentPlan',
                Month__c = Date.today().month() < 10 ? '0' + String.valueOf(Date.today().month()) : String.valueOf(Date.today().month()),
                DealerSalesGoal__c = dsgCurrent.Id,
                Actual_OrderUnit__c = 100,
                Actual_OrderAmount__c = 1000,
                Actual_HEOrderUnit__c = 30,
                Actual_AutomationOrderUnit__c = 500,
                MarketShare__c = 0.12,
                RecordTypeId = dspRT.Id
            );
            insert dspCurrent;


            DealerSalesGoal__c dsgLast = new DealerSalesGoal__c(
                Year__c = String.valueOf(Date.today().year() - 1),
                Dealer__c = dealerAcc.Id,
                RecordTypeId = dsgRT.Id
            );
            insert dsgLast;

            DealerSalesPlan__c dpsLast = new DealerSalesPlan__c(
                Name = 'FirstJanPlan',
                Month__c = Date.today().month() < 10 ? '0' + String.valueOf(Date.today().month()) : String.valueOf(Date.today().month()),
                DealerSalesGoal__c = dsgLast.Id,
                Actual_OrderUnit__c = 300,
                Actual_OrderAmount__c = 3000,
                Actual_HEOrderUnit__c = 10,
                Actual_AutomationOrderUnit__c = 5600,
                MarketShare__c = 0.4,
                RecordTypeId = dspRT.Id
            );
            insert dpsLast;
        }
    }

    @IsTest
    static void validationTest(){

        TriggerHandler.bypassedHandlers = new Set<String>{'DealerSalesGoalTriggerHandler'};

        DealerSalesGoal__c dsg = [SELECT Id FROM DealerSalesGoal__c WHERE PreviousActual_OrderUnit__c = 120 LIMIT 1];

        Test.startTest();
        DN_RefreshDealerSalesGoalController.updateSalesGoal(dsg.Id);
        Test.stopTest();

    
    }




}