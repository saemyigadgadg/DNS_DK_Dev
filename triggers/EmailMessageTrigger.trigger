/**
* @Class : TicketTrigger
*
* @Author : Hayeong, Min
* @Date : 2024. 11. 29.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-11-29 | Hayeong, Min   | 최초작성
*
*/
trigger EmailMessageTrigger on EmailMessage (before insert, after insert) {
    TriggerManager.prepare()
    .bind(new EmailMessageTriggerHandler())
    .execute(); 
}