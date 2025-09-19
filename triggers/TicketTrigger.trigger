/**
* @Class : TicketTrigger
*
* @Author : Hayeong, Min
* @Date : 2024. 06. 14.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-06-14 | Hayeong, Min   | 최초작성
*
*/
trigger TicketTrigger on Case (before insert, after insert, before update, after update) {
    TriggerManager.prepare()
    .bind(new TicketTriggerHandler())
    .execute(); 
}