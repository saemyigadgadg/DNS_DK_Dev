/** 
 * @Class :  DealerFreeDispatchTriggerHandler
 * 
 * @Test: DealerFreeDispatchTriggerHandler_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 02. 02. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-02 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DealerFreeDispatchTriggerHandler extends TriggerHandler { 
    public DealerFreeDispatchTriggerHandler() {

    }

    /*
    * @ Method : onBeforeUpdate
    * @ Description : 조건에 따른 IsDemandCapture__c 값 설정
    */
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        for(DealerFreeDispatch__c newDealerFreeDispatch : (List<DealerFreeDispatch__c>)news) {
            DealerFreeDispatch__c oldDealerFreeDispatch = (DealerFreeDispatch__c)oldMap.get(newDealerFreeDispatch.Id);
            
            //IsDemanCaputre 외의 값이 변경 될때
            if(newDealerFreeDispatch.IsDemandCapture__c == oldDealerFreeDispatch.IsDemandCapture__c && !newDealerFreeDispatch.IsDemandCapture__c)
                newDealerFreeDispatch.IsDemandCapture__c = true;
        }
    }
}