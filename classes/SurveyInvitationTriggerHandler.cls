/**
* @Class : SurveyInvitationTriggerHandler
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
global with sharing class SurveyInvitationTriggerHandler extends TriggerHandler {
    global override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if (isExecuting) {
            System.debug('UpdateInvitation1');
            // 설문 완료된 URL ExpiryTime 설정
            for (SurveyInvitation obj : (List<SurveyInvitation>) news) {
                SurveyInvitation oldObj = (SurveyInvitation) oldMap.get(obj.Id);
                
                if (obj.Status__c == 'Completed' && oldObj.Status__c != 'Completed') {
                    System.debug('UpdateInvitation2');
                    obj.InviteExpiryDateTime = System.now().addSeconds(3); // ✅
                }
            }
        }    
    }
}