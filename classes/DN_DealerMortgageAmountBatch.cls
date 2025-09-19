/**
 * @author            : Yu-Hyun Park
 * @description       : 
 *  - Dealer의 코드를 이용해서 담보 금액의 총합을 계산
 *  - Scheduled Jobs 등록
 * @last modified on  : 2025-07-22
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-16   yuhyun.park@sbtglobal.com   Initial Version
**/
global class DN_DealerMortgageAmountBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful, Database.AllowsCallouts  {

    private static final Id   accDealerRT   = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('QueryLocator Executing');
        return Database.getQueryLocator([
            SELECT  Id, CustomerCode__c, RecordTypeId, SalesOrganization__c, Division__c
            FROM    Account 
            WHERE   RecordTypeId =: accDealerRT
            AND     CustomerCode__c != null
            ]); 
    }


    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('scope :: ' + scope);

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet;
    
        // scope에서 첫 번째 Account만 처리
        if (!scope.isEmpty()) {
            Account acc = (Account) scope.get(0);
            String dealerCode = acc.CustomerCode__c;
            String companyCode = acc.SalesOrganization__c;
            String salesArea2 = acc.Division__c;
    
            // dealerCode로 fieldMap 설정
            Map<String, Object> fieldMap = new Map<String, Object>();
            fieldMap.put('dealerCode', dealerCode);
            fieldMap.put('companyCode', companyCode);
            fieldMap.put('salesArea2', salesArea2);
    
            // DN_DealerIFController의 interfaceDealer004 호출
            IF_ERP_Dealer_Classes.IF_DEALER_004_Res response = DN_DealerIFController.interfaceDealer004(fieldMap, 'Process');
            System.debug('response :: ' + response);
    
            // 결과 처리
            Decimal totalAmount = 0;
            if (response != null && response.T_RETURN != null) {
                for (IF_ERP_Dealer_Classes.IF_DEALER_004_Res_T_RETURN result : response.T_RETURN) {

                    System.debug('result :: ' + result);
                    
                    // KUNNR : dealerCode
                    if (result.AMOUNT != null && result.KUNNR != null) {
                        System.debug('result.AMOUNT :: ' + result);
                        totalAmount += Decimal.valueOf(result.AMOUNT);
                        System.debug('totalAmount :: ' + result);

                    }
                }
            }
    
            // 해당 dealerCode에 대한 Account의 MortgageAmount__c 필드 업데이트
            acc.MortgageAmount__c = totalAmount;
            update acc;
        }
    }


    global void finish(Database.BatchableContext bc) {
        System.debug('Batch processing completed.');
    }


    global void execute(SchedulableContext sc) {
        // 배치 클래스 실행
        DN_DealerMortgageAmountBatch batch = new DN_DealerMortgageAmountBatch();
        Database.executeBatch(batch, 1);
    }
}