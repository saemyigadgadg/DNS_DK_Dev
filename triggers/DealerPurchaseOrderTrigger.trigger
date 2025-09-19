/** 
 * @Class :  DealerPurchaseOrderTrigger
 * 
 * @Test: 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 01. 08. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-08 | Hyunwook Jin   | 최초작성 
 */ 
trigger DealerPurchaseOrderTrigger on DealerPurchaseOrder__c (before insert, before update) {
    TriggerManager.prepare()
    .bind(new DealerPurchaseOrderTriggerHandler())
    .execute(); 
}