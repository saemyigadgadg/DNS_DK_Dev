/**
 * @description       : [DN_InspectionConfrimCmp]
 *                      [SLS-DLV-007] Inspection(입회검사)에서 품질팀이 Confirm하는 컨트롤러
 * @author            : yeongju.yun
 * @last modified on  : 2024-10-31
 * @last modified by  : yeongju.yun 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-10-31   yeongju.yun   Initial Version
**/
public with sharing class DN_InspectionConfirmController {
    
    public static DN_OrderService ordSvc = new DN_OrderService();

    @AuraEnabled
    public static ResultWrapper validateConfirm(String inspectionId){
        ResultWrapper result = new ResultWrapper();

        try {

            Inspection__c ins = [SELECT Id, QMRep__c FROM Inspection__c WHERE Id =: inspectionId];
            if(ins.QMRep__c != UserInfo.getUserId()) {
                result.isSuccess  = false;
                result.errMessage = SYstem.Label.DNS_M_QMOnlyConfirm; // Only the assigned QM Representative can confirm this.
            } 

        } catch (Exception e) {
            System.debug('validateOrderConfrim : ' + e.getLineNumber() + ' / ' + e.getMessage());
            result.isSuccess  = false;
            result.errMessage = e.getMessage();
        }
        return result;
    }
    
    @AuraEnabled
    public static ResultWrapper confirmInspection(String inspectionId){
        ResultWrapper result = new ResultWrapper();
        try {

            System.debug('inspectionId : ' + inspectionId);
            Inspection__c ins = new Inspection__c(Id = inspectionId, QualityConfirm__c = 'Y');
            update ins;
            
        } catch (Exception e) {
            System.debug('confirmInspection : ' + e.getLineNumber() + ' / ' + e.getMessage());
            result.isSuccess  = false;
            result.errMessage = e.getMessage();
        }
        return result;
    }

    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess  {get;set;}
        @AuraEnabled public String  errMessage {get;set;}
        
        public ResultWrapper(){
            this.isSuccess = true;
        }
    }
}