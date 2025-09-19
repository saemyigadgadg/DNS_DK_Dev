/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-10-29   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class DealerSalesPlanTriggerHandler extends TriggerHandler{

    public override void onBeforeInsert(List<sObject> news){
        try {
            if (isExecuting) {
                List<DealerSalesPlan__c>    dspList     = (List<DealerSalesPlan__c>) news;
                Set<String>                 monthSet    = new Set<String>();
                Set<Id>                     parentIdSet = new Set<Id>();
    
                for (DealerSalesPlan__c dsp : dspList) {
                    monthSet.add(dsp.Month__c);
                    parentIdSet.add(dsp.DealerSalesGoal__c);
                }
                checkMonthDuplicate(dspList, monthSet, parentIdSet);
                setting(false, TriggerOperation.BEFORE_INSERT);
            }
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- DealerSalesPlan__c의 Month__c필드 duplicate check
     * @author Yuhyun Park | 10-29-2024
     * @Parameter
     *  - dspList       : insert 되는 DealerSalesPlan__c 레코드 List
     *  - monthSet	    : dspList 레코드의 Month__c Set
     *  - parentIdSet   : DealerSalesPlan__c의 Parent(DealerSalesGoal__c) Id Set
    **/ 
    private static void checkMonthDuplicate(List<DealerSalesPlan__c> dspList, Set<String> monthSet, Set<Id> parentIdSet) {
        List<DealerSalesPlan__c> existingDspList = [
            SELECT Id, Month__c, DealerSalesGoal__c
            FROM DealerSalesPlan__c 
            WHERE Month__c IN :monthSet
            AND DealerSalesGoal__c IN :parentIdSet
        ];
    
        // Month와 DealerSalesGoal__c 조합으로 중복 확인
        Map<String, DealerSalesPlan__c> existingDspMap = new Map<String, DealerSalesPlan__c>();
        for (DealerSalesPlan__c existingDsp : existingDspList) {
            String key = existingDsp.DealerSalesGoal__c + '-' + existingDsp.Month__c;
            existingDspMap.put(key, existingDsp);
        }
    
        // 새로운 레코드의 Month와 DealerSalesGoal__c 조합이 중복인지 확인
        for (DealerSalesPlan__c dsp : dspList) {
            String key = dsp.DealerSalesGoal__c + '-' + dsp.Month__c;
            if (existingDspMap.containsKey(key)) {
                dsp.addError('The month already exists for this Dealer Sales Goal.');
            }
        }
    }
    

}