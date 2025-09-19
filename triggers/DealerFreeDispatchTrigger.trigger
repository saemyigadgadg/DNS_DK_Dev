/** 
 * @Class :  DealerFreeDispatchTrigger
 * 
 * @Test: 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 02. 02. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-02 | Hyunwook Jin   | 최초작성 
 */ 
trigger DealerFreeDispatchTrigger on DealerFreeDispatch__c (before update) {
    TriggerManager.prepare()
    .bind(new DealerFreeDispatchTriggerHandler())
    .execute(); 
}