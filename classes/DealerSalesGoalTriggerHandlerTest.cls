/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-17
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-01-14   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public class DealerSalesGoalTriggerHandlerTest {

    @isTest
    static void testBeforeInsert() {
        // 테스트 데이터 생성
        RecordType dnsKGoalRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'DNS_Korea' AND SObjectType = 'DealerSalesGoal__c' LIMIT 1];
        RecordType dealerRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Dealer' AND SObjectType = 'Account' LIMIT 1];

        Account dealer = new Account(Name = 'Test Dealer', RecordTypeId = dealerRecordType.Id);
        insert dealer;

        DealerSalesGoal__c dsg = new DealerSalesGoal__c(
            Year__c = '2024',
            Dealer__c = dealer.Id,
            Target_OrderUnit__c = 120,
            Target_OrderAmount__c = 2400,
            RecordTypeId = dnsKGoalRT.Id
        );

        Test.startTest();
        insert dsg;
        Test.stopTest();

        // Assertions
        DealerSalesGoal__c insertedDsg = [SELECT Id, Year__c FROM DealerSalesGoal__c WHERE Id = :dsg.Id];
        System.assertEquals('2024', insertedDsg.Year__c);
    }

    @isTest
    static void testAfterInsert() {
        // 테스트 데이터 생성
        RecordType dnsaGoalRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'DNSA' AND SObjectType = 'DealerSalesGoal__c' LIMIT 1];
        RecordType dnsaPlanRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'DNSA' AND SObjectType = 'DealerSalesPlan__c' LIMIT 1];
        RecordType dealerRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Dealer' AND SObjectType = 'Account' LIMIT 1];

        Account dealer = new Account(Name = 'Test Dealer', RecordTypeId = dealerRecordType.Id);
        insert dealer;

        DealerSalesGoal__c dsg = new DealerSalesGoal__c(
            Year__c = '2024',
            Dealer__c = dealer.Id,
            Target_OrderUnit__c = 120,
            Target_OrderAmount__c = 2400,
            RecordTypeId = dnsaGoalRT.Id
        );

        Test.startTest();
        insert dsg;
        Test.stopTest();

        // Assertions for DealerSalesPlan__c creation
        List<DealerSalesPlan__c> plans = [
            SELECT Id, Month__c, Target_OrderUnit__c, Target_OrderAmount__c
            FROM DealerSalesPlan__c
            WHERE DealerSalesGoal__c = :dsg.Id
        ];

        System.assertEquals(12, plans.size());
        System.assertEquals(10, plans[0].Target_OrderUnit__c); // Example assertion
    }

    @isTest
    static void testBeforeUpdate() {
        // 테스트 데이터 생성
        RecordType dnsKGoalRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'DNS_Korea' AND SObjectType = 'DealerSalesGoal__c' LIMIT 1];
        RecordType dealerRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Dealer' AND SObjectType = 'Account' LIMIT 1];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account dealer;

        dealer = TestDataFactoryForSales.createAccount('Dealer', country, null);
        insert dealer;

        DealerSalesGoal__c dsg = new DealerSalesGoal__c(
            Year__c = '2024',
            Dealer__c = dealer.Id,
            Target_OrderUnit__c = 120,
            RecordTypeId = dnsKGoalRT.Id
        );
        insert dsg;

        dsg.Year__c = '2025';

        Test.startTest();
        update dsg;
        Test.stopTest();

        // Assertions
        DealerSalesGoal__c updatedDsg = [SELECT Id, Year__c FROM DealerSalesGoal__c WHERE Id = :dsg.Id];
        System.assertEquals('2025', updatedDsg.Year__c);
    }

    @isTest
    static void testYearDuplicateCheck() {
        // 테스트 데이터 생성
        RecordType dnsKGoalRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'DNS_Korea' AND SObjectType = 'DealerSalesGoal__c' LIMIT 1];
        RecordType dealerRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Dealer' AND SObjectType = 'Account' LIMIT 1];

        Account dealer = new Account(Name = 'Test Dealer', RecordTypeId = dealerRecordType.Id);
        insert dealer;

        DealerSalesGoal__c dsg1 = new DealerSalesGoal__c(
            Year__c = '2024',
            Dealer__c = dealer.Id,
            RecordTypeId = dnsKGoalRT.Id
        );
        insert dsg1;

        DealerSalesGoal__c dsg2 = new DealerSalesGoal__c(
            Year__c = '2024',
            Dealer__c = dealer.Id,
            RecordTypeId = dnsKGoalRT.Id
        );

        Test.startTest();
        try {
            insert dsg2;
            System.assert(false, 'Duplicate year check failed. Exception expected.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('The year already exists.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertPreviousActualValues() {
        // 테스트 데이터 생성
        RecordType dnsaGoalRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'DNSA' AND SObjectType = 'DealerSalesGoal__c' LIMIT 1];
        RecordType dealerRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Dealer' AND SObjectType = 'Account' LIMIT 1];

        Account dealer = new Account(Name = 'Test Dealer', RecordTypeId = dealerRecordType.Id);
        insert dealer;

        DealerSalesGoal__c previousDsg = new DealerSalesGoal__c(
            Year__c = '2023',
            Dealer__c = dealer.Id,
            // Actual_OrderUnit__c = 100,
            // Actual_OrderAmount__c = 2000,
            RecordTypeId = dnsaGoalRT.Id
        );
        insert previousDsg;

        DealerSalesGoal__c newDsg = new DealerSalesGoal__c(
            Year__c = '2024',
            Dealer__c = dealer.Id,
            RecordTypeId = dnsaGoalRT.Id
        );

        Test.startTest();
        insert newDsg;
        Test.stopTest();

        // Assertions
        DealerSalesGoal__c insertedDsg = [SELECT PreviousActual_OrderUnit__c, PreviousActual_OrderAmount__c
                                          FROM DealerSalesGoal__c
                                          WHERE Id = :newDsg.Id];
        // System.assertEquals(100, insertedDsg.PreviousActual_OrderUnit__c);
        // System.assertEquals(2000, insertedDsg.PreviousActual_OrderAmount__c);
    }
}