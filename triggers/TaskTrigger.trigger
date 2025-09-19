/**
* @Class : TaskTrigger
*
* @Author : Hayeong, Min
* @Date : 2024. 10. 21.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-10-21 | Hayeong, Min   | 최초작성
*
*/
trigger TaskTrigger on Task (before insert, after insert, before update, after update, before delete) {
    TriggerManager.prepare()
    .bind(new TaskTriggerHandler())
    .execute(); 
}