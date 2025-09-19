/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-07-23
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-08-07   Yuhyun Park   Initial Version
 * 1.1   2025-02-17   Yeongju.yun   Product의 HEIndicator__c기준으로 Order Category업데이트
**/

public with sharing class ProductTriggerHandler extends TriggerHandler{
    private static final Id GeneralRT  = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();


    /**
    * @description IsStrategicMaterial__c 변경 시 관련된 OpportunityLineItem을 조회하여 메서드 호출
    **/
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting){
            List<Product2> prodList = (List<Product2>) news;
            Map<Id, Product2> prodOldMap = (Map<Id, Product2>) oldMap;
            
            Set<Id> prodIds = new Set<Id>();
            Set<Id> optyIds = new Set<Id>();

            for(Product2 prod : prodList){
                Product2 oldProd = (Product2) oldMap.get(prod.Id);

                // Product의 IsStrategicMaterial__c 값이 변경되었을 때만 Update 실행
                if(oldProd.IsStrategicMaterial__c != prod.IsStrategicMaterial__c){
                    prodIds.add(prod.Id);
                }
            }
            
            // OpportunityLineItem 조회
            List<OpportunityLineItem> itemList = new List<OpportunityLineItem>();
            itemList = [SELECT Id, Name, Product2Id, OpportunityId FROM OpportunityLineItem WHERE Product2Id IN: prodIds];
                    
            for(OpportunityLineItem item : itemList){
                optyIds.add(item.OpportunityId);
            }

            if(!optyIds.isEmpty() && !prodIds.isEmpty() && !itemList.isEmpty()){
                checkStrategicMaterial(optyIds, prodIds, itemList);
            }

            syncOrderCategory(prodList, prodOldMap);
        }
    }


    /**
     * @Description
     * 	- Product의 IsStrategicMaterial__c필드가 true 일때, Opportunity의 IsStrategicMaterial__c필드도 true, 아니면 false.
     * @author Yuhyun Park | 08-07-2024
     * @Parameter
     *  - prodIds	        : Update된 Product의 Id Set
     *  - itemList	        : 하위 Product가 Update된 OpportunityLineItem List
     *  - optyIds	        : 하위 Product가 Update된 Opportunity의 Id Set
    **/ 
    private void checkStrategicMaterial (Set<Id> optyIds, Set<Id> prodIds, List<OpportunityLineItem> itemList){
        
        // Update할 Opportunity를 담을 List
        List<Opportunity> optyToUpdateList = new List<Opportunity>();
        
        // Opportunity 조회
        Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>();
        Map<Id, Product2> prodMap = new Map<Id, Product2>();
        
        // Opportunity와 Product 조회
        List<Opportunity> optyList = [SELECT Id, Name, IsStrategicMaterial__c, RecordTypeId FROM Opportunity WHERE Id IN : optyIds];
        List<Product2> prodOfOptyList = [SELECT Id, Name, IsStrategicMaterial__c FROM Product2 WHERE Id IN : prodIds];

        for(Opportunity opty : optyList) {
            optyMap.put(opty.Id, opty);
        }
        
        for(Product2 prod : prodOfOptyList) {
            prodMap.put(prod.Id, prod);
        }

        // Opportunity의 제품 중 하나라도 전략 물자인지 확인하기 위한 맵 생성
        Map<Id, Boolean> optyStrategicFlagMap = new Map<Id, Boolean>();

        for(OpportunityLineItem item : itemList) {
            Product2 prod = prodMap.get(item.Product2Id);
            if (prod != null) {
                Boolean isStrategic = prod.IsStrategicMaterial__c;
                if (isStrategic) {
                    if (!optyStrategicFlagMap.containsKey(item.OpportunityId)) {
                        optyStrategicFlagMap.put(item.OpportunityId, true);
                    }
                }
            }
        }

        // 전략 자재 플래그를 기반으로 Opportunity 업데이트 & Opportunity가 General Type일 때만
        for(Opportunity opty : optyMap.values()) {
            if (optyStrategicFlagMap.containsKey(opty.Id) && opty.RecordTypeId == GeneralRT) {
                opty.IsStrategicMaterial__c = true;
            } else {
                opty.IsStrategicMaterial__c = false;
            }
            optyToUpdateList.add(opty);
        }

        // Opportunity를 데이터베이스에 업데이트
        if (!optyToUpdateList.isEmpty()) {
            update optyToUpdateList;
        }
        
        
    }


    /**
    * @description Product의 HEIndicator__c기준으로 Order Category업데이트
                   HEIndicator__c - true : HE, false : CP
    * @author yeongju.yun | 2025-02-17 
    * @param news 
    * @param oldMap 
    **/
    private void syncOrderCategory(List<Product2> news, Map<Id, Product2> oldMap){

        List<Product2> target = new List<Product2>();
        for(Product2 prod : news) {
            if(oldMap.get(prod.Id).HEIndicator__c != prod.HEIndicator__c) { target.add(prod); }
        }

        if(!target.isEmpty()) {
            List<Order> toUpdateOrders = new List<Order>();

            Map<Id, Product2> prodMap = new Map<Id, Product2>(target);
            List<OrderItem> oItemList = [SELECT Id, OrderId, Product2.HEIndicator__c FROM OrderItem WHERE Product2Id =: prodMap.keySet()];

            Set<Id> preventIds = new Set<Id>();
            for(OrderItem oItem : oItemList) {
                if(preventIds.add(oItem.OrderId)) continue;
                preventIds.add(oItem.OrderId);

                Order order = new Order();
                order.Id    = oItem.OrderId;
                order.Type  = oItem.Product2.HEIndicator__c ? 'HE' : 'CP';
                toUpdateOrders.add(order);
            }

            if(!toUpdateOrders.isEmpty()) { update toUpdateOrders; }
        }
    }
}