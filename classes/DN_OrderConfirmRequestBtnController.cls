/**
 * @related           : DN_OrderConfirmRequestBtn
 * @description       : Order CRM TO ERP 에러 시 재전송 버튼
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-05-16   yeongju.yun   Initial Version
**/
public with sharing class DN_OrderConfirmRequestBtnController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description 주문 승인 전 Validate
    **/
    @AuraEnabled
    public static ResultWrapper validateDeliveryConfrim(String recordId){
        ResultWrapper result = new ResultWrapper();
        try {

            Order order = [SELECT Id, ERPOrderNo__c, ApprovalStatus__c, IF_ERROR__c FROM Order WHERE Id =: recordId];

            if(String.isNotBlank(order.ERPOrderNo__c)) {
                result.isSuccess = false;
                result.errorMsg  = System.Label.DNS_M_AlreadyRequested; // This order has already been requested for confirmation.
            } else if(order.ApprovalStatus__c == ordSvc.APPROVAL_NOTSTARTED || order.ApprovalStatus__c == ordSvc.APPROVAL_INTERNALREQUESTED || order.ApprovalStatus__c == ordSvc.APPROVAL_REJECTED) {
                result.isSuccess = false;
                result.errorMsg  = System.Label.DNS_M_InternalApprovalFirst; // Please proceed with internal approval first.
            } else if(String.isBlank(order.IF_ERROR__c)) {
                result.isSuccess = false;
                result.errorMsg  = System.Label.DNS_M_NOError; // No error occurred for this item, so no further action is required.
            }
            
            return result;
        } catch (Exception e) {
            System.debug('validateDeliveryConfrim : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 주문 승인 요청 (ERP에 주문 전송)
    **/
    @AuraEnabled
    public static ResultWrapper requestConfirm(String recordId){
        ResultWrapper result = new ResultWrapper();
        try {

            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Order').getDescribe().fields.getMap();
            String queryFields = String.join(new List<String>(fieldMap.keySet()), ', ');
            String query = 'SELECT ' + queryFields + ' FROM Order WHERE Id =:recordId ';
            List<Order> orders = Database.query(query);
            Order thisOrder = orders[0];

            List<OrderLog__c> orderLogs = [SELECT Id, OrderNo__c FROM OrderLog__c WHERE Order__c =: recordId];

            if(orderLogs.isEmpty()) {
                
                IF_ERP_Order_Classes.IF_ORDER_001_Res response_order = DN_OrderCRMToERPBatch.callOrderCreationIF(recordId);

                if(response_order.O_RETURN.TYPE == 'E') {
                    String errorMsg = response_order.O_RETURN.MESSAGE;
                    thisOrder.IF_ERROR__c = errorMsg;
                    thisOrder.IF_FreePass__c = true;
                    update thisOrder;

                    result.isSuccess = false;
                    result.errorMsg  = errorMsg;

                    if(!Test.isRunningTest()) { DN_OrderCRMToERPBatch.sendErrorNoti(thisOrder); }
                    if(!Test.isRunningTest()) { DN_OrderCRMToERPBatch.sendSupportNoti(thisOrder); }

                } else {

                    String erpNo = response_order.O_VBELN;

                    thisOrder.IF_ERROR__c        = '';
                    thisOrder.Status             = ordSvc.ORDER_PROGRESS;
                    thisOrder.ERPOrderNo__c      = erpNo;
                    thisOrder.IF_CreatedInCRM__c = true;
                    thisOrder.IF_FreePass__c     = true;

                    Database.SaveResult sr = Database.update(thisOrder, false);
                    OrderLog__c newLog = new OrderLog__c();
                    newLog.Order__c    = thisOrder.Id;
                    newLog.OrderNo__c  = erpNo;

                    if(sr.isSuccess()) {
                        if(!Test.isRunningTest()) { DN_OrderCRMToERPBatch.mappingPriceInfo(thisOrder.Id, response_order); }
                        if(!Test.isRunningTest()) { DN_OrderCRMToERPBatch.sendEmailNoti(thisOrder); }
                    } else {
                        newLog.Description__c = String.valueOf(sr.getErrors());
                    }
                    insert newLog;
                }
            } else {
                thisOrder.IF_ERROR__c        = '';
                thisOrder.Status             = ordSvc.ORDER_PROGRESS;
                thisOrder.ERPOrderNo__c      = orderLogs[0].OrderNo__c;
                thisOrder.IF_CreatedInCRM__c = true;
                thisOrder.IF_FreePass__c     = true;
                update thisOrder;
            }
            
            return result;
        } catch (Exception e) {
            System.debug('requestConfirm : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 결과 반환 Wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess  {get;set;}
        @AuraEnabled public String  errorMsg   {get;set;}
        
        public ResultWrapper(){
            this.isSuccess = true;
            this.errorMsg  = '';
        }
    }

    /**
    * @description 가격 정보 Wrapper
    **/
    public class PriceWrapper{
        public String  posnr    {get;set;}
        public Decimal price    {get;set;}
        public Decimal tax      {get;set;}
        
        public PriceWrapper(){}
    }
}