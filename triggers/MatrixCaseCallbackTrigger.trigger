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
trigger MatrixCaseCallbackTrigger on Case (after update) {
    // 변경된 Owner를 감지
    Map<Id, String>  caseCallbackMap = new Map<Id, String>();
    
    for (Case newCase : Trigger.new) {
        Case oldCase = Trigger.oldMap.get(newCase.Id);
        
        // Status가 ClosMap<Id, Id> ed로 변경되었고, Matrix_Call_Type__c가 'Callback'인 케이스 확인
        if (newCase.Status == 'Closed' && 
            oldCase.Status != 'Closed' && 
            newCase.Matrix_Call_Type__c == 'Callback') {
            String ani = '';
            if(newCase.ContactMobile != null){
                ani = newCase.ContactMobile;
            } else if(newCase.ContactPhone != null){
                ani = newCase.ContactPhone;
            }
            caseCallbackMap.put(newCase.Id, ani);
        }
    }
    
    // 조건에 맞는 케이스가 있을 경우에만 API 호출
    if (!caseCallbackMap.isEmpty()) {
        MatrixCallController.callApiWithCallBacks(caseCallbackMap);
    }    
}