/**
* @Class : CollaboratorTrigger
*
* @Author : Hayeong, Min
* @Date : 2024. 06. 13.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-06-13 | Hayeong, Min   | 최초작성
*
*/
trigger CollaboratorTrigger on Collaborator__c (before insert, after insert, before update, before delete) {
    TriggerManager.prepare()
    .bind(new CollaboratorTriggerHandler())
    .execute(); 
}