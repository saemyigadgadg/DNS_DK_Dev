/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-06
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-06   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public class DealerSalesPlanTriggerHandlerTest {

    @isTest
    static void testBeforeInsert() {
        // 테스트 데이터 생성
        RecordType dealerRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Dealer' AND SObjectType = 'Account' LIMIT 1];
        RecordType dnsaGoalRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'DNSA' AND SObjectType = 'DealerSalesGoal__c' LIMIT 1];
        RecordType dnsaPlanRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'DNSA' AND SObjectType = 'DealerSalesPlan__c' LIMIT 1];

        Account dealer = new Account(Name = 'Test Dealer', RecordTypeId = dealerRecordType.Id);
        insert dealer;

        DealerSalesGoal__c dealerGoal = new DealerSalesGoal__c(
            Year__c = '2024',
            Dealer__c = dealer.Id,
            RecordTypeId = dnsaGoalRT.Id
        );
        insert dealerGoal;

        DealerSalesPlan__c dsp1 = new DealerSalesPlan__c(
            Name = 'January Plan',
            Month__c = '01',
            DealerSalesGoal__c = dealerGoal.Id,
            RecordTypeId = dnsaPlanRT.Id
        );

        DealerSalesPlan__c dsp2 = new DealerSalesPlan__c(
            Name = 'Duplicate January Plan',
            Month__c = '01',
            DealerSalesGoal__c = dealerGoal.Id,
            RecordTypeId = dnsaPlanRT.Id
        );

        Test.startTest();
        try {
            insert new List<DealerSalesPlan__c>{dsp1, dsp2};
            System.assert(false, 'Duplicate month check failed. Exception expected.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('The month already exists for this Dealer Sales Goal.'));
        }
        Test.stopTest();
    }

}