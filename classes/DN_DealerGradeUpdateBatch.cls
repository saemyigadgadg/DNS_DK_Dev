/**
 * @author            : Yu-Hyun Park
 * @description       : 
 *  - Dealer의 코드를 이용해서 딜러 등급을 업데이트
 * @last modified on  : 2025-04-02
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-20   yuhyun.park@sbtglobal.com   Initial Version
**/
global class DN_DealerGradeUpdateBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful, Database.AllowsCallouts  {

    private static final Id   accDealerRT   = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('QueryLocator Executing');
        return Database.getQueryLocator([
            SELECT  Id, 
                    KUNNR__c,               // Customer Code
                    KVGR4__c                // Grade
            FROM    IF_CustomerGrade__c 
            WHERE   KUNNR__c != null
            AND CreatedDate = TODAY
            ]); 
    }



    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('scope :: ' + scope);

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet;

        try{
            List<IF_CustomerGrade__c> ifrecordList  = (List<IF_CustomerGrade__c>) scope;
            Map<String, Account> existingAccMap     = new Map<String, Account>();
            Set<String> customerCodes               = new Set<String>();
            List<Account> accToUpdate               = new List<Account>();

            for(IF_CustomerGrade__c record : ifrecordList){
                customerCodes.add(removeFrontZero(record.KUNNR__c));
            }

            List<Account> existingAccList = [
                SELECT  Id,
                        RecordTypeId,
                        CustomerCode__c,
                        DealerGrade__c
                FROM    Account
                WHERE   CustomerCode__c IN: customerCodes
                AND     RecordTypeId =: accDealerRT
            ];

            System.debug('existingAccList ::: ' + existingAccList);


            for(Account acc : existingAccList){
                existingAccMap.put(acc.CustomerCode__c, acc);
            }

            for(IF_CustomerGrade__c record : ifrecordList){
                Account existingAcc = existingAccMap.get(removeFrontZero(record.KUNNR__c));

                if(existingAcc != null){
                    existingAcc.DealerGrade__c = record.KVGR4__c;
                    accToUpdate.add(existingAcc);
                }
            }

            System.debug('accToUpdate ::: ' + accToUpdate);

            TriggerHandler.bypass('AccountTriggerHandler');
            System.debug('<< TriggerHandler.bypass On >>');

            if (!accToUpdate.isEmpty()){
                update accToUpdate;
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
        }
    }


    global void finish(Database.BatchableContext bc) {
        TriggerHandler.clearBypass('AccountTriggerHandler');
        System.debug('<< TriggerHandler.bypass Off >>');
        System.debug('Batch processing completed.');

    }


    global void execute(SchedulableContext sc) {
        // 배치 클래스 실행
        DN_UpdateAccountFromERPBatch batch = new DN_UpdateAccountFromERPBatch();
        Database.executeBatch(batch, 200);
    }


    private String removeFrontZero(String input){
        return input.replaceAll('^0+', '');
    }


}