/**
* @Class : SurveyInvitationTrigger
*
* @Author : Junyeong, Choi
* @Date : 2024. 12. 02.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-12-02 | Junyeong, Choi   | ver.1
*
*/
trigger SurveyInvitationTrigger on SurveyInvitation (before insert, after insert, before update, after update, before delete) {
    TriggerManager.prepare()
    .bind(new SurveyInvitationTriggerHandler())
    .execute(); 
}