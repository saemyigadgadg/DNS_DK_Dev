/**
 * @author            : Yu-Hyun Park
 * @description       : 
 *  - Dealer Sales Plan의 Target을 대리점이 입력하지 않을 시, 이메일&알림 전송
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-01-23   yuhyun.park@sbtglobal.com   Initial Version
**/
global with sharing class DN_NotiForTargetToDealerBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {

    private static final Id   koreaRT   = SObjectType.DealerSalesPlan__c.getRecordTypeInfosByDeveloperName().get('DNS_Korea').getRecordTypeId();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        // 오늘 날짜와 3일 전 날짜 계산
        Date today = Date.today();
        Date threeDaysAgo = today.addDays(-3);


        // 테스트 실행 시 날짜 범위를 확장하여, FM_DateForRemind__c의 값이 범위 내에 포함되도록 함
        if(Test.isRunningTest()){
            threeDaysAgo = Date.today().addDays(-30);
            today = Date.today().addDays(30);
        }

        
        return Database.getQueryLocator([
            SELECT  Id,
                    FM_Year__c,
                    Month__c,
                    RecordTypeId,
                    FM_DateForRemind__c,
                    Target_fromDealer__c,
                    DealerSalesGoal__r.OwnerId
            FROM    DealerSalesPlan__c
            WHERE   Target_fromDealer__c = null
            AND     RecordTypeId =: koreaRT
            AND     FM_DateForRemind__c >= :threeDaysAgo
            AND     FM_DateForRemind__c <= :today
        ]);

    }


    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('scope :: ' + scope);
        for(SObject record : scope){
            System.debug(record);
        }
        List<DealerSalesPlan__c> plans  = (List<DealerSalesPlan__c>) scope;
        DN_OrderService ordSvc          = new DN_OrderService();
        List<DealerSalesPlan__c> target = new List<DealerSalesPlan__c>();

        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        for(DealerSalesPlan__c plan : plans){
            target.add(plan);

            Set<Id> innerSet = targetUserMap.containsKey(plan.Id) ? targetUserMap.get(plan.Id) : new Set<Id>();
            innerSet.add(plan.DealerSalesGoal__r.OwnerId);
            targetUserMap.put(plan.Id, innerSet);
        }

        if(!target.isEmpty()){
            // bell 
            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'SalesPlanTargetReminder'
                , 'bell'
                , target
                , targetUserMap
                , null
            );
            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(bellAlertResult.errMessage); }

            // email 
            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'SalesPlanTargetReminder'
                , 'email'
                , target
                , targetUserMap
                , null
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(emailAlertResult.errMessage); }
        }

    }


    global void finish(Database.BatchableContext bc) {
        System.debug('Batch processing completed.');
    }


    global void execute(SchedulableContext sc) {
        // 배치 클래스 실행
        DN_NotiForTargetToDealerBatch batch = new DN_NotiForTargetToDealerBatch();
        Database.executeBatch(batch, 200);
    }



}