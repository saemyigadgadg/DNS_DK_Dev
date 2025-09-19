/** 
 * @Class :  DealerPurchaseOrderItemTrigger
 * 
 * @Test: 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 01. 09. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-09 | Hyunwook Jin   | 최초작성 
 */ 
trigger DealerPurchaseOrderItemTrigger on DealerPurchaseOrderItem__c (before update) {
    TriggerManager.prepare()
    .bind(new DealerPurchaseOrderItemTriggerHandler())
    .execute(); 
}