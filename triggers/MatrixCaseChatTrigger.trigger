/**
* @Class : MatrixCaseTrigger
*
* @Author : Hayeong, Min
* @Date : 2024. 12. 27.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-12-27 | Jun Kim        | 최초작성
*
*/
trigger MatrixCaseChatTrigger on Case (after update) {
    // 변경된 Owner를 감지
    Map<Id, Id> caseOwnerMap = new Map<Id, Id>();
    for (Case c : Trigger.new) {
        Case oldCase = Trigger.oldMap.get(c.Id);
        if (c.OwnerId != oldCase.OwnerId) {
            caseOwnerMap.put(c.Id, c.OwnerId);
        }
    }

    if (!caseOwnerMap.isEmpty()) {
        MatrixChatController.callApiWithOwnerEmail(caseOwnerMap);
    }
}