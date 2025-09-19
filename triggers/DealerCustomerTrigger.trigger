/** 
 * @Trigger : DealerCustomerTrigger
 * 
 * @Test: 
 * @Author : Hyunwook Jin 
 * @Date : 2024. 12. 19. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-19 | Hyunwook Jin   | 최초작성 
 */ 
trigger DealerCustomerTrigger on DealerCustomer__c (before insert) {
    TriggerManager.prepare()
    .bind(new DealerCustomerTriggerHandler())
    .execute(); 
}