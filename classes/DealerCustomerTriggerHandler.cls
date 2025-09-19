/** 
 * @Class :  DealerCustomerTriggerHandler
 * 
 * @Test: DealerCustomerTriggerHandler_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2024. 12. 19. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-19 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DealerCustomerTriggerHandler extends TriggerHandler {    
    public DealerCustomerTriggerHandler() {}

    /*
     * @ Method : onBeforeInsert
     * @ Description : CustomerCode__c에 SourceSystem이 CRM이며 CustomerCode__c에 채번정보가 없는 경우 채번 설정
     * @ Description : 채번 규칙 - C5{000000} / ERP에서 마이그의 경우 5{000000}
     */
    public override void onBeforeInsert(List<sObject> news){
        // System.debug('DealerCustomerTriggerHandler.onBeforeInsert');
        SequenceGenerator seqGenerator = new SequenceGenerator('DealerCustomer__c');
        for(DealerCustomer__c newDealerCustomer : (List<DealerCustomer__c>)news) {
            if('CRM'.equals(newDealerCustomer.SourceSystem__c) && String.isBlank(newDealerCustomer.CustomerCode__c)) {
                newDealerCustomer.CustomerCode__c = seqGenerator.generate('Customer');
                // System.debug('newDealerCustomer.CustomerCode__c : ' +newDealerCustomer.CustomerCode__c);
            }
        }
        seqGenerator.updateNextSequenceInfo();
    }   
}