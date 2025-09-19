/**
* @Class : TicketEscalationRuleTrigger
*
* @Author : Junyeong, Choi
* @Date : 2025. 02. 11.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2025-02-11 | Junyeong, Choi   | 최초작성
*
*/
trigger TicketEscalationRuleTrigger on TicketEscalationRule__c (before insert) {
    TriggerManager.prepare()
    .bind(new TicketEscalationRuleTriggerHandler())
    .execute(); 
}