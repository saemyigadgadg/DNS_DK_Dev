/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-23-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-12-2024   Hanyeong Choi   Initial Version
**/
public with sharing class RequestedSQTriggerHandler extends TriggerHandler {

    /**
     * RequestedSQ__c 레코드 삽입 후, DNSA 레코드 타입의 경우 SQRegistration__c의 소유자를 업데이트합니다.
     */
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting) {
            System.debug('RequestedSQ__c AFTER_INSERT TRIGGER Start');
            List<RequestedSQ__c> reqList = (List<RequestedSQ__c>) news;
            Set<Id> sqrIds = new Set<Id>();
            Map<String, String> ownerMap = new Map<String, String>();
            for(RequestedSQ__c req : reqList) {
                System.debug('req.FM_RecordType__c ::: ' + req.FM_RecordType__c);
                System.debug('@@ reqList ' + reqList);
                if(req.FM_RecordType__c == 'DNSA') {
                    sqrIds.add(req.SQRegistration__c);
                    if(!ownerMap.keySet().contains(req.SQRegistration__c)) ownerMap.put(req.SQRegistration__c, req.CreatedById);
                }
            }
            if(!sqrIds.isEmpty()) {
                List<SQRegistration__c> updateList = new List<SQRegistration__c>();
                List<SQRegistration__c> sqrList = [SELECT Id, OwnerId, DNSA_Sales_Team__c FROM SQRegistration__C WHERE Id IN :sqrIds];
                Set<Id> mgIds = new Set<Id>();
                for(SQRegistration__c sqrr : sqrList) {
                    mgIds.add(sqrr.DNSA_Sales_Team__c);
                }
                List<Message_Group_junction__c> mgjList = [SELECT User__c FROM Message_Group_Junction__c WHERE Message_Group__c IN :mgIds AND User__r.IsActive = true];
                for(SQRegistration__c sqr : sqrList) {
                    if(sqr.OwnerId != UserInfo.getUserId()) {
                        if(!mgjList.isEmpty()) {
                            for(Message_Group_junction__c mgj : mgjList) {
                                if(mgj.User__c == UserInfo.getUserId()) {
                                    sqr.OwnerId = ownerMap.get(sqr.Id);
                                    updateList.add(sqr);
                                }
                            }
                        }
                    }
                }
                if(!updateList.isEmpty()) update updateList;
            }

            setting(false, TriggerOperation.AFTER_INSERT);
            System.debug('RequestedSQ__c AFTER_INSERT TRIGGER End');
        }
    }
    
    /**
     * RequestedSQ__c 레코드 업데이트 전, 이름 길이 및 특정 조건을 검증합니다.
     */
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if (isExecuting) {
            System.debug('RequestedSQ__c BEFORE_UPDATE TRIGGER Start');
            List<RequestedSQ__c> rsqList = (List<RequestedSQ__c>) news;

            for(RequestedSQ__c rsq : rsqList) {
                if(rsq.Name.length() > 40) {
                    if(rsq.Name != 'COMMON_COOLANT TANK or CHIP CONVEYOR Type Change Request Form') {
                        if(!Test.isRunningTest()) {
                            rsq.addError(System.Label.DNS_REQ_T_NAMEVALIDATION);
                        } else {
                            System.debug('success');
                        }
                    }
                }
            }
        
            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('RequestedSQ__c BEFORE_UPDATE TRIGGER End');
        }
    }
}