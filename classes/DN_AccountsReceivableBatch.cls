/**
 * @author            : Yu-Hyun Park
 * @description       : 
 *  - ERP의 딜러별 매출채권잔액을 Accounts Receivable 필드에 합산
 *  - 매출채권잔액 수식 : IF_ERP_Dealer에서 계산(confirmed by 김경무 위원)
 * @last modified on  : 2025-05-13
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-19   yuhyun.park@sbtglobal.com   Initial Version
**/
global class DN_AccountsReceivableBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful, Database.AllowsCallouts  {

    private static final Id   accDealerRT   = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('QueryLocator Executing');
        return Database.getQueryLocator([
            SELECT  Id, Name, CustomerCode__c, RecordTypeId, SalesOrganization__c, AccountsReceivable__c, SalesDistrict__c
            FROM    Account 
            WHERE   RecordTypeId =: accDealerRT
            AND     CustomerCode__c != null
            AND     SalesDistrict__c = 'A1KR'
            ]); 
    }


    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('scope :: ' + scope);

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; 

        if(!scope.isEmpty()){
            List<Account> acc = (List<Account>) scope;

            Map<String, Object> fieldMap = new Map<String, Object>();
            fieldMap.put('SalesOrganization__c' , acc[0].SalesOrganization__c);
            fieldMap.put('CustomerCode__c'      , acc[0].CustomerCode__c);

            IF_ERP_Dealer_Classes.IF_DEALER_001_Res erpResponse = interfaceDealer001(fieldMap);

            System.debug('erpResponse ::: ' + erpResponse);

            if(erpResponse.TotalAmount != null){
                System.debug('erpResponse.TotalAmount :: ' + erpResponse.TotalAmount);
                System.debug('Account Info' + acc[0].Id + '-' + acc[0].Name + '-' + acc[0].CustomerCode__c);

                acc[0].AccountsReceivable__c = erpResponse.TotalAmount;

            }
            update acc[0];
        }

    }


    global void finish(Database.BatchableContext bc) {
        System.debug('Batch processing completed.');
    }


    global void execute(SchedulableContext sc) {
        // 배치 클래스 실행
        DN_AccountsReceivableBatch batch = new DN_AccountsReceivableBatch();
        Database.executeBatch(batch, 1);
    }


    private static IF_ERP_Dealer_Classes.IF_DEALER_001_Res interfaceDealer001(Map<String, Object> fieldMap) {

        IF_ERP_Dealer_Classes.IF_DEALER_001_Req erpParameters = new IF_ERP_Dealer_Classes.IF_DEALER_001_Req();

        erpParameters.I_BUKRS = (String) fieldMap.get('SalesOrganization__c');
        erpParameters.I_KUNNR = (String) fieldMap.get('CustomerCode__c');

        IF_ERP_Dealer erpService = new IF_ERP_Dealer();
        return erpService.IF_DEALER_001(erpParameters);
    }




}