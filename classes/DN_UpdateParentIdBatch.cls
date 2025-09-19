/**
 * @author            : Yu-Hyun Park
 * @description       : 
 *  - Order와 Opportunity의 ParentId에 값을 넣어주기 위한 배치
 *  - Account Trigger에서 BatchTargetRecord__c 레코드 생성
 * @last modified on  : 2025-02-24
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-11-22   yuhyun.park@sbtglobal.com   Initial Version
**/

global class DN_UpdateParentIdBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {

    private List<BatchTargetRecord__c> batchScope;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('QueryLocator Executing');
        return Database.getQueryLocator([
            SELECT  TargetObject__c, TargetDate__c, RecordId__c, IsCompleted__c
            FROM    BatchTargetRecord__c
            WHERE   TargetDate__c = :System.today()
            AND     IsCompleted__c != true
            ORDER BY RecordId__c, TargetDate__c DESC
        ]); 
    }

    global void execute(Database.BatchableContext bc, List<BatchTargetRecord__c> scope) {
        System.debug('Scope :: ' + scope);

        this.batchScope = scope;
    
        try {
    
            Set<Id> accIds = new Set<Id>();
            Map<Id, Id> parentIdMap = new Map<Id, ID>();
    
            List<Opportunity> optyToUpdate = new List<Opportunity>();
            List<Order> orderToUpdate = new List<Order>();
    
            for(BatchTargetRecord__c record : scope) {
                accIds.add(record.RecordId__c);
            }
    
            if(!accIds.isEmpty()) {
                List<Account> accList = [
                    SELECT Id, ParentId
                    FROM Account
                    WHERE Id IN: accIds
                ];
    
                List<Opportunity> optyList = [
                    SELECT Id, AccountId, ParentAccount__c 
                    FROM Opportunity
                    WHERE AccountId IN: accIds
                ];
                System.debug('optyList :: ' + optyList);

    
                List<Order> orderList = [
                    SELECT Id, AccountId, ParentAccount__c 
                    FROM Order
                    WHERE AccountId IN: accIds
                ];
                System.debug('orderList :: ' + orderList);
    
                for(Account acc : accList) {
                    parentIdMap.put(acc.Id, acc.ParentId);
                }
    

                for(Opportunity opty : optyList) {
                    if(opty.ParentAccount__c != parentIdMap.get(opty.AccountId)) {
                        opty.ParentAccount__c = parentIdMap.get(opty.AccountId);
                        optyToUpdate.add(opty);
                    }
                }
                
                for(Order order : orderList) {
                    if(order.ParentAccount__c != parentIdMap.get(order.AccountId)) {
                        order.ParentAccount__c = parentIdMap.get(order.AccountId);
                        orderToUpdate.add(order);
                    }
                }
                
                TriggerHandler.bypass('OpportunityTriggerHandler');
                TriggerHandler.bypass('OrderTriggerHandler');
                System.debug('<< TriggerHandler.bypass On >>');
    
                if(!optyToUpdate.isEmpty()) {
                    System.debug('optyToUpdate :: ' + optyToUpdate);
                    update optyToUpdate;
                }
    
                if(!orderToUpdate.isEmpty()) {
                    System.debug('orderToUpdate :: ' + orderToUpdate);
                    update orderToUpdate;
                }
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
    
        } finally {
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
            TriggerHandler.clearBypass('OrderTriggerHandler');
            System.debug('<< TriggerHandler.bypass Off >>');
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch job completed!');

        try {
            if (batchScope != null && !batchScope.isEmpty()) {
                for (BatchTargetRecord__c record : batchScope) {
                    record.IsCompleted__c = true;
                }
                
                update batchScope;
                System.debug('Updated IsCompleted__c to true for ' + batchScope.size() + ' records.');
            }
        } catch (Exception e) {
            System.debug('Error in finish method: ' + e.getMessage());
        }
    }

    global void execute(SchedulableContext sc) {
        // 배치 클래스 실행
        DN_UpdateParentIdBatch batch = new DN_UpdateParentIdBatch();
        Database.executeBatch(batch);
    }
}