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
trigger DealerOrderItemTrigger on DealerOrderItem__c (before update) {
    
    TriggerManager.prepare()
    .bind(new DealerOrderItemTriggerHandler())
    .execute(); 
}