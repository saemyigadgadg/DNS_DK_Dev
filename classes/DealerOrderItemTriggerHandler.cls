/**
*
* @Author : iltae, Seo
* @Date : 2025. 01. 06.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2025-01-06 | iltae, Seo     | 최초작성
*
*/
public with sharing class DealerOrderItemTriggerHandler  extends TriggerHandler{
    public DealerOrderItemTriggerHandler() {

    }
    // 입출고 처리 및 취소에 따른 수량 업데이트
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        purchaseOrderItemUpdate(olds,news);
    }

    /**
     * @Description
     * 	- 로직에 따른 입출고 처리 및 취소에 따른 수량 업데이트
    **/ 
    @TestVisible
    private static void purchaseOrderItemUpdate(List<sObject> olds, List<sObject> news) {
        Map<String, DealerOrderItem__c> purchaseOrderItemMap = new Map<String, DealerOrderItem__c>();
        for(DealerOrderItem__c obj : (List<DealerOrderItem__c>) news) {
            if(obj.get('DealerPurchaseOrderItem__c') !=null) {
                purchaseOrderItemMap.put(obj.DealerPurchaseOrderItem__c, obj);
            }
        }
        List<DealerPurchaseOrderItem__c> purchaseItemList = [select Id,GICompletedQuantity__c,GICompletedDateTime__c, Name from DealerPurchaseOrderItem__c where Id IN: purchaseOrderItemMap.keySet()];
        for(DealerPurchaseOrderItem__c item :purchaseItemList) {
            DealerOrderItem__c orderItem = purchaseOrderItemMap.get(item.Id);
            item.GICompletedDateTime__c = orderItem.GICompletedDateTime__c;
            item.GICompletedQuantity__c = orderItem.GICompletedQuantity__c; // 출고완료 수량 GICompletedQuantity__c
        }
        update purchaseItemList;
    }
    
}