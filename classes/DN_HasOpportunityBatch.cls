/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * - Lead에서 Converted된 Account의 Opportunity 생성 여부 체크
 * - 생성된 Opporunity가 있다면 Account의 HasOpportunity__c에 Update 'True'
 * - 어제 생성된 Opportunity 기준
 * @last modified on  : 2025-05-29
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-05-29   yuhyun.park@sbtglobal.com   Initial Version
**/
public class DN_HasOpportunityBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {

    private Set<Id> accIdSet = new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('QueryLocator Executing');
        return Database.getQueryLocator([
            SELECT  Id, AccountId
            FROM    Opportunity
            WHERE   CreatedDate = YESTERDAY
            AND     Account.Converted__c  = true
        ]); 
    }


    public void execute(Database.BatchableContext bc, List<Opportunity> scope){

        for (Opportunity opty : scope) {
            if (opty.AccountId != null) {
                accIdSet.add(opty.AccountId);
            }
        }
    }


    public void finish(Database.BatchableContext bc){

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet;

        List<Account> accToUpdate = new List<Account>();
        List<Account> targetAccList = [SELECT Id, HasOpportunity__c FROM Account WHERE Id IN: accIdSet];

        for(Account acc : targetAccList){
            if(acc.HasOpportunity__c != true){
                acc.HasOpportunity__c = true;
                accToUpdate.add(acc);
            }
        }

        System.debug('accToUpdate :: ' + accToUpdate);
        System.debug('accToUpdate Size :: ' + accToUpdate.size());

        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }


    public void execute(SchedulableContext sc) {
        // 배치 클래스 실행
        DN_HasOpportunityBatch batch = new DN_HasOpportunityBatch();
        Database.executeBatch(batch, 200);
    }

}