/**
* @Class : CampaignTrigger
*
* @Author : Junyeong, Choi
* @Date : 2024. 08. 21.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-08-21 | Junyeong, Choi   | 최초작성
*
*/
trigger CampaignTrigger on Campaign (before insert, before update, after insert, after update) {
    TriggerManager.prepare()
    .bind(new CampaignTriggerHandler())
    .execute(); 
}