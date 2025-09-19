/**
 * @test              : PreparationCheckListTriggerHandlerTest
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-23
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-11-04   yeongju.yun   Initial Version
**/
public with sharing class PreparationCheckListTriggerHandler extends TriggerHandler{
    DN_OrderService ordSvc = new DN_OrderService();

    /**
    * @description 해당 Order에 Serial 정보가 없거나 이미 사전설치점검표가 존재하는 경우 생성을 차단
    **/
    public override void onBeforeInsert(List<sObject> news){
        if (isExecuting) {
            System.debug('PreparationCheckList__c BEFORE_INSERT TRIGGER Start');

            List<PreparationCheckList__c> preList = (List<PreparationCheckList__c>)news;

            Set<Id> orderIdSet = new Set<Id>();
            for(PreparationCheckList__c pre : preList) {
                orderIdSet.add(pre.Order__c);
            }

            List<PreparationChecklist__c> pastCreatedList = [SELECT Id, Order__c FROM PreparationChecklist__c WHERE Order__c =:orderIdSet ];
            Set<Id> alreadyCreated = new Set<Id>();
            for(PreparationChecklist__c past : pastCreatedList) {
                alreadyCreated.add(past.Order__c);
            }

            List<Order> orderList = [SELECT Id, Status, SerialNumber__c, SOSerialNumber__c FROM Order WHERE Id =: orderIdSet];
            
            if(!orderList.isEmpty()) {
                Map<Id, Boolean> passMap = new Map<Id, Boolean>();
                for(Order order : orderList){
                    passMap.put(order.Id, String.isNotBlank(order.SerialNumber__c) && order.SOSerialNumber__c != null);
                }

                for(PreparationCheckList__c pre : preList) {
                    if(!passMap.get(pre.Order__c)) { pre.addError(System.Label.DNS_M_PreparationCreationError); }
                    // The Preparation Checklist cannot be created without an SO serial number.
                    else if(alreadyCreated.contains(pre.Order__c)) { pre.addError(System.label.DNS_OnlyOnePreparationChecklist); }
                    // Only one Preparation Checklist can be created per order. If there are changes, please update the existing Preparation Checklist.
                }
            }
            
            setting(false, TriggerOperation.BEFORE_INSERT);
            System.debug('PreparationCheckList__c BEFORE_INSERT TRIGGER End');
        }
    }
    
    /**
    * @description 연결된 Ticket의 상태가 Reject이 아니라면 수정 차단
    **/
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if (isExecuting) {
            System.debug('PreparationCheckList__c BEFORE_UPDATE TRIGGER Start');

            List<PreparationCheckList__c> preList = (List<PreparationCheckList__c>) news;
            Map<Id, PreparationCheckList__c> preNewMap = (Map<Id, PreparationCheckList__c>) newMap;
            Map<Id, PreparationCheckList__c> preOldMap = (Map<Id, PreparationCheckList__c>) oldMap;

            List<Case> ticketList = [SELECT Id, Status, PreparationChecklist__c FROM Case WHERE PreparationChecklist__c =: preNewMap.keySet()];
            if(!ticketList.isEmpty()) {
                Map<Id, Boolean> passMap = new Map<Id, Boolean>(); // key : PreparationChecklist__c id, value : editable
                for(Case t : ticketList) {
                    passMap.put(t.PreparationChecklist__c, t.Status != ordSvc.TICKET_REJECT);
                }

                for(PreparationChecklist__c pre : preList) {
                    if(pre.DeliveryOrder__c != preOldMap.get(pre.Id).DeliveryOrder__c) continue;
                    
                    if(passMap.containsKey(pre.Id)) {

                        if(passMap.get(pre.Id)) { pre.addError(System.Label.DNS_M_PreparationEditError); }
                        // The Preparation Checklist can only be edited when the ticket status is 'Reject'.
                    }
                }
            }

            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('PreparationCheckList__c BEFORE_UPDATE TRIGGER End');
        }
    }
}