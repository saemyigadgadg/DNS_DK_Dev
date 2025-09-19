/** 
 * @Class :  DealerOrderTriggerHandler
 * 
 * @Test: DealerOrderTriggerHandler_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2024. 12. 30. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-30 | Hyunwook Jin   | 최초작성 
 */ 
public inherited sharing class DealerOrderTriggerHandler extends TriggerHandler {    
    public DealerOrderTriggerHandler() {

    }

    /*
    * @ Method : onBeforeInsert
    * @ Description : CRM에서 생성한 경우 CRM 채번룰 부여
    */
    public override void onBeforeInsert(List<sObject> news){
        SequenceGenerator seqGenerator = new SequenceGenerator('DealerOrder__c');
        for(DealerOrder__c newDealerOrder : (List<DealerOrder__c>)news) {
            if('CRM'.equals(newDealerOrder.SourceSystem__c) && String.isBlank(newDealerOrder.OrderNumber__c)) {
                switch on newDealerOrder.OrderType__c {
                    when 'S', 'P'{
                        newDealerOrder.OrderNumber__c = seqGenerator.generate('General');        
                    }
                    when 'E' {
                        newDealerOrder.OrderNumber__c = seqGenerator.generate('Emergency');
                    }
                }
                
            }
        }
        seqGenerator.updateNextSequenceInfo();
    }   

    /*
    * @ Method : onBeforeUpdate
    * @ Description : 조건에 따른 삭제플래그 변경 및 IsDemandCapture 변경
    */
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        for(DealerOrder__c newDealerOrder : (List<DealerOrder__c>)news) {
            DealerOrder__c oldDealerOrder = (DealerOrder__c)oldMap.get(newDealerOrder.Id);
            if(newDealerOrder.TotalItemCount__c > 0 && newDealerOrder.TotalItemCount__c == newDealerOrder.DeletedItemCount__c ) 
                newDealerOrder.Delete__c = 'Y';
            if(newDealerOrder.IsDemandCapture__c == oldDealerOrder.IsDemandCapture__c && !newDealerOrder.IsDemandCapture__c)
                newDealerOrder.IsDemandCapture__c = true;
        }
       
    }
    
}