/**
 * @author            : Yu-Hyun Park
 * @description       : Dealer Sales Goal의 Previous Actual, YoY 값, Marketshare update. DNSA Only
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-06   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class DN_RefreshDealerSalesGoalController {

    private static final Id   dnsaGoalRT    = SObjectType.DealerSalesGoal__c.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();

    @AuraEnabled
    public static String updateSalesGoal(Id recordId) {

        try {
            System.debug('updateSalesGoal >>');
    
            List<DealerSalesGoal__c> currentRecord = [
                SELECT  Id, Dealer__c, Year__c, PreviousActual_OrderUnit__c, PreviousActual_OrderAmount__c, PreviousActual_HEOrderUnit__c, PreviousActual_AutomationOrderUnit__c, PreviousMarketShare__c, MarketShare__c
                FROM    DealerSalesGoal__c
                WHERE   Id =: recordId
                LIMIT   1
            ];
    
            System.debug('currentRecord :: ' + currentRecord[0]);  
    
            List<DealerSalesGoal__c> previousYearRecord = [
                SELECT  Id, RecordTypeId, Dealer__c, Year__c, Actual_OrderUnit__c, Actual_OrderAmount__c, Actual_HEOrderUnit__c, Actual_AutomationOrderUnit__c, MarketShare__c
                FROM    DealerSalesGoal__c 
                WHERE   RecordTypeId =: dnsaGoalRT
                AND     Dealer__c =: currentRecord[0].Dealer__c
                AND     Year__c =: String.valueOf(Integer.valueOf(currentRecord[0].Year__c) - 1)
                LIMIT   1
            ];
    
            List<DealerSalesPlan__c> childPlanList = [
                SELECT Id, DealerSalesGoal__c, MarketShare__c
                FROM   DealerSalesPlan__c
                WHERE  DealerSalesGoal__c =: currentRecord[0].Id
            ];
    
            if(!childPlanList.isEmpty()){
                System.debug('childPlanList.size :: ' + childPlanList.size());
                System.debug('childPlanList :: ' + childPlanList);
            }else{
                System.debug('No childPlanList' );  
            }
    
            if(!previousYearRecord.isEmpty()){
                System.debug('previousYearRecord :: ' + previousYearRecord[0]);  
            }else{
                System.debug('No previousYearRecord' );  
            }
    
            Boolean isUpdated = false;
    
            if( !currentRecord.isEmpty() && !previousYearRecord.isEmpty()){
    
                if (currentRecord[0].PreviousActual_OrderUnit__c != previousYearRecord[0].Actual_OrderUnit__c) {
                    currentRecord[0].PreviousActual_OrderUnit__c = previousYearRecord[0].Actual_OrderUnit__c;
                    isUpdated = true;
                    System.debug('OrderUnit__c Updated');
                }
    
                if (currentRecord[0].PreviousActual_OrderAmount__c != previousYearRecord[0].Actual_OrderAmount__c) {
                    currentRecord[0].PreviousActual_OrderAmount__c = previousYearRecord[0].Actual_OrderAmount__c;
                    isUpdated = true;
                    System.debug('OrderAmount__c Updated');
                }
    
                if (currentRecord[0].PreviousActual_HEOrderUnit__c != previousYearRecord[0].Actual_HEOrderUnit__c) {
                    currentRecord[0].PreviousActual_HEOrderUnit__c = previousYearRecord[0].Actual_HEOrderUnit__c;
                    isUpdated = true;
                    System.debug('HEOrderUnit__c Updated');
    
                }
    
                if (currentRecord[0].PreviousActual_AutomationOrderUnit__c != previousYearRecord[0].Actual_AutomationOrderUnit__c) {
                    currentRecord[0].PreviousActual_AutomationOrderUnit__c = previousYearRecord[0].Actual_AutomationOrderUnit__c;
                    isUpdated = true;
                    System.debug('AutomationOrderUnit__c Updated');
                }
    
                if (currentRecord[0].PreviousMarketShare__c != previousYearRecord[0].MarketShare__c) {
                    currentRecord[0].PreviousMarketShare__c = previousYearRecord[0].MarketShare__c;
                    isUpdated = true;
                    System.debug('MarketShare__c Updated');
                }
            }
    
    
            if(!childPlanList.isEmpty()){
                
                Decimal totalMarketShare = 0;
                Integer planSize = 0;
    
                for(DealerSalesPlan__c dsp : childPlanList){
                    if(dsp.MarketShare__c != null){
                        totalMarketShare += dsp.MarketShare__c;
                        planSize++;
                    }
                }
    
                if(planSize > 0){
                    Decimal avgMarketShare = totalMarketShare / planSize;
                    System.debug('avgMarketShare :: ' + avgMarketShare);
            
                    if(avgMarketShare != currentRecord[0].MarketShare__c){
                        currentRecord[0].MarketShare__c = avgMarketShare;
                        isUpdated = true;
                        System.debug('MarketShare__c Updated');
                    }
                } else {
                    System.debug('No valid MarketShare__c values found in childPlanList.');
                }
    
            }
            
            if (isUpdated) {
                update currentRecord;
                System.debug('Record updated');
            } 
    
            return 'success';

        } catch (Exception e) {
            System.debug('Error in updateSalesGoal: ' + e.getMessage());
            System.debug('Line Number: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }    

    }
}