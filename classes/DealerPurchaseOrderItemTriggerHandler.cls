/** 
 * @Class :  DealerPurchaseOrderItemTriggerHandler
 * 
 * @Test: DealerPurchaseOrderItemTriggerHan_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 01. 09. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-09 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DealerPurchaseOrderItemTriggerHandler extends TriggerHandler {    
    public DealerPurchaseOrderItemTriggerHandler() {

    }

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        Map<Id, DealerPurchaseOrderItem__c> oldPOItemMap = (Map<Id, DealerPurchaseOrderItem__c>) oldMap;
        Map<Id, DealerPurchaseOrderItem__c> newPOItemMap = (Map<Id, DealerPurchaseOrderItem__c>) newMap;
        insertHistory(newPOItemMap, oldPOItemMap);
    }

    /**
    * 상태 적재 기준 
    * 변경요청('2')으로 변경시 -> History 상태 변경요청('2')
    * 삭제요청('3')으로 변경시 -> History 상태 삭제요청('3')
    *  */  
    @TestVisible
    private static void insertHistory(Map<Id, DealerPurchaseOrderItem__c> newPOItemMap, Map<Id, DealerPurchaseOrderItem__c> oldPOItemMap) {
        List<DealerPurchaseOrderItemHistory__c> historyList = new List<DealerPurchaseOrderItemHistory__c>();
        for(DealerPurchaseOrderItem__c newPOItem : newPOItemMap.values()) {   
              
            DealerPurchaseOrderItemHistory__c history;
            DealerPurchaseOrderItem__c oldPOItem = oldPOItemMap.get(newPOItem.Id);
            if(newPOItem.Status__c != oldPOItem.Status__c && '2'.equals(newPOItem.Status__c) ) { //&& '0'.equals(oldPOItem.Status__c)
                Decimal finalChangeQuantity = newPOItem.Quantity__c + newPOItem.ChangeQuantity__c;
                history = generateStatusHistory('2', oldPOItem.Quantity__c, finalChangeQuantity);
                history.PurchaseOrderItem__c = newPOItem.Id;
            }else if(newPOItem.Status__c != oldPOItem.Status__c && '3'.equals(newPOItem.Status__c) ) { //
                history = generateStatusHistory('3', newPOItem.Quantity__c, null);
                history.PurchaseOrderItem__c = newPOItem.Id;
                history.Delete__c = 'Y';
            }
            if(history != null) historyList.add(history);
        }
        if(historyList.size() > 0) {
            insert historyList;

            for(DealerPurchaseOrderItemHistory__c history : historyList) {
                if(newPOItemMap.containsKey(history.PurchaseOrderItem__c)) {
                    newPOItemMap.get(history.PurchaseOrderItem__c).LastHistory__c = history.Id;
                }
            }
        }
    }

    /*
    * @ Method : generateStatusHistory
    * @ Description : DealerPurchaseOrderItemHistory__c로 변환 후 리턴
    */
    @TestVisible
    private static DealerPurchaseOrderItemHistory__c generateStatusHistory(String status, Decimal oldQuantity, Decimal newQuantity) {
        DealerPurchaseOrderItemHistory__c history = new DealerPurchaseOrderItemHistory__c(
            Status__c = status,
            OldQuantity__c = oldQuantity,
            NewQuantity__c = newQuantity
        );
        return history;
    }
}