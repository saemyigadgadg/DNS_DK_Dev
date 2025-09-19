/**
* @Class : ServiceResourcesTrigger
*
* @Author : Junyeong, Choi
* @Date : 2024. 11. 08.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-11-08 | Junyeong, Choi   | 최초작성
*
*/
trigger ServiceResourcesTrigger on ServiceResource (before insert, after insert, before update, after update, before delete) {
    TriggerManager.prepare()
    .bind(new ServiceResourcesTriggerHandler())
    .execute(); 
}