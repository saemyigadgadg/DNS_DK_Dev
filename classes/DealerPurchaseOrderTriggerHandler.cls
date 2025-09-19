/** 
 * @Class : DealerPurchaseOrderTriggerHandler
 * 
 * @Test: DealerPurchaseOrderTriggerHandler_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 01. 08. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-08 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DealerPurchaseOrderTriggerHandler extends TriggerHandler {    
    public DealerPurchaseOrderTriggerHandler() {

    }

    /*
    * @ Method : onBeforeInsert
    * @ Description : CRM채번 로직에 따라 채번 부여
    */
    public override void onBeforeInsert(List<sObject> news){
        SequenceGenerator seqGenerator = new SequenceGenerator('DealerPurchaseOrder__c');
        for(DealerPurchaseOrder__c newPurchaseOrder : (List<DealerPurchaseOrder__c>)news) {
            if('CRM'.equals(newPurchaseOrder.SourceSystem__c) && String.isBlank(newPurchaseOrder.OrderNumber__c)) {
                newPurchaseOrder.OrderNumber__c = seqGenerator.generate('DealerPO');        
            }
        }
        seqGenerator.updateNextSequenceInfo();
    }
    
    /*
    * @ Method : onBeforeUpdate
    * @ Description : 조건에 따른 삭제플래그 처리
    */
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        for(DealerPurchaseOrder__c newDealerPurchaseOrder : (List<DealerPurchaseOrder__c>)news) {
            if(newDealerPurchaseOrder.TotalItemCount__c > 0 && newDealerPurchaseOrder.TotalItemCount__c == newDealerPurchaseOrder.DeletedItemCount__c ) 
                newDealerPurchaseOrder.Delete__c = 'Y';
        }
    }
}