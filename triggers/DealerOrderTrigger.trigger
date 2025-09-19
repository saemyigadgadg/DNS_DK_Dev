/** 
 * @Class :  DealerOrderTrigger
 * 
 * @Test: 
 * @Author : Hyunwook Jin 
 * @Date : 2024. 12. 30. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-30 | Hyunwook Jin   | 최초작성 
 */ 
trigger DealerOrderTrigger on DealerOrder__c (before insert, before update) {
    TriggerManager.prepare()
    .bind(new DealerOrderTriggerHandler())
    .execute(); 
}