/**
* @Class : TicketManagerTrigger
*
* @Author : Junyeong, Choi
* @Date : 2025. 02. 12.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2025-02-12 | Junyeong, Choi   | 최초작성
*
*/
trigger TicketManagerTrigger on TicketManager__c (before insert) {
    TriggerManager.prepare()
    .bind(new TicketManagerTriggerHandler())
    .execute();
}