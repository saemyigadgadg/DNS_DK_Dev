/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-24
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-24   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class ImportDealerBonusControllerTest {

    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'DealerBonusTriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        Account dealerAcc;
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
    static void testRecordsInsert(){

        List<Map<String, Object>> records = new List<Map<String, Object>>();

        // 판매수수료 레코드
        Map<String, Object> rec1 = new Map<String, Object>();
        rec1.put('SheetName', '판매수수료');
        rec1.put('CustomerCode__c', '33333');
        rec1.put('Year__c', '2025');
        rec1.put('Month__c', '01');
        rec1.put('SalesCommission__c', 100);
        rec1.put('Incentive__c', 0);
        rec1.put('Bounty__c', 0);
        rec1.put('SalesActivityBonus__c', 0);
        records.add(rec1);
        
        // 인센티브 레코드
        Map<String, Object> rec2 = new Map<String, Object>();
        rec2.put('SheetName', '인센티브');
        rec2.put('CustomerCode__c', '33333');
        rec2.put('Year__c', '2025');
        rec2.put('Month__c', '01');
        rec2.put('SalesCommission__c', 0);
        rec2.put('Incentive__c', 150);
        rec2.put('Bounty__c', 0);
        rec2.put('SalesActivityBonus__c', 0);
        records.add(rec2);
        
        // 포상금 레코드
        Map<String, Object> rec3 = new Map<String, Object>();
        rec3.put('SheetName', '포상금');
        rec3.put('CustomerCode__c', '33333');
        rec3.put('Year__c', '2025');
        rec3.put('Month__c', '01');
        rec3.put('SalesCommission__c', 0);
        rec3.put('Incentive__c', 0);
        rec3.put('Bounty__c', 75);
        rec3.put('SalesActivityBonus__c', 0);
        records.add(rec3);
        
        // 영업활동 장려금 레코드
        Map<String, Object> rec4 = new Map<String, Object>();
        rec4.put('SheetName', '영업활동 장려금');
        rec4.put('CustomerCode__c', '33333');
        rec4.put('Year__c', '2025');
        rec4.put('Month__c', '01');
        rec4.put('SalesCommission__c', 0);
        rec4.put('Incentive__c', 0);
        rec4.put('Bounty__c', 0);
        rec4.put('SalesActivityBonus__c', 200);
        records.add(rec4);


        String jsonInput = JSON.serialize(records);

        Test.startTest();
        String result = ImportDealerBonusController.upsertRecords(jsonInput);
        Test.stopTest();

    }

    
    @isTest
    static void testRecordsUpdate(){

        List<Map<String, Object>> records = new List<Map<String, Object>>();

       // 판매수수료 레코드
       Map<String, Object> rec1 = new Map<String, Object>();
       rec1.put('SheetName', '판매수수료');
       rec1.put('CustomerCode__c', '22222');
       rec1.put('Year__c', '2025');
       rec1.put('Month__c', '01');
       rec1.put('SalesCommission__c', 100);
       rec1.put('Incentive__c', 0);
       rec1.put('Bounty__c', 0);
       rec1.put('SalesActivityBonus__c', 0);
       records.add(rec1);
       
       // 인센티브 레코드
       Map<String, Object> rec2 = new Map<String, Object>();
       rec2.put('SheetName', '인센티브');
       rec2.put('CustomerCode__c', '22222');
       rec2.put('Year__c', '2025');
       rec2.put('Month__c', '01');
       rec2.put('SalesCommission__c', 0);
       rec2.put('Incentive__c', 150);
       rec2.put('Bounty__c', 0);
       rec2.put('SalesActivityBonus__c', 0);
       records.add(rec2);
       
       // 포상금 레코드
       Map<String, Object> rec3 = new Map<String, Object>();
       rec3.put('SheetName', '포상금');
       rec3.put('CustomerCode__c', '22222');
       rec3.put('Year__c', '2025');
       rec3.put('Month__c', '01');
       rec3.put('SalesCommission__c', 0);
       rec3.put('Incentive__c', 0);
       rec3.put('Bounty__c', 75);
       rec3.put('SalesActivityBonus__c', 0);
       records.add(rec3);
       
       // 영업활동 장려금 레코드
       Map<String, Object> rec4 = new Map<String, Object>();
       rec4.put('SheetName', '영업활동 장려금');
       rec4.put('CustomerCode__c', '22222');
       rec4.put('Year__c', '2025');
       rec4.put('Month__c', '01');
       rec4.put('SalesCommission__c', 0);
       rec4.put('Incentive__c', 0);
       rec4.put('Bounty__c', 0);
       rec4.put('SalesActivityBonus__c', 200);
       records.add(rec4);

       

        String jsonInput = JSON.serialize(records);

        Test.startTest();
        String result = ImportDealerBonusController.upsertRecords(jsonInput);
        Test.stopTest();

    }


    @isTest
    static void testRecordsUndefined(){

        List<Map<String, Object>> records = new List<Map<String, Object>>();

        // 판매수수료 레코드
        Map<String, Object> rec = new Map<String, Object>();
        rec.put('CustomerCode__c', '');
        records.add(rec);

        String jsonInput = JSON.serialize(records);

        Test.startTest();
        String result = ImportDealerBonusController.upsertRecords(jsonInput);
        Test.stopTest();




    }



    

}