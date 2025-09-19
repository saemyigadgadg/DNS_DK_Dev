/**
 * @related           : DN_OrderCancelBtn
 * @description       : 주문 취소 버튼 컨트롤러
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-17
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-03-07   yeongju.yun   Initial Version
**/
public with sharing class DN_OrderCancelController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description 주문 취소 Validate
    **/
    @AuraEnabled
    public static ResultWrapper validateOrderCancel(String recordId){
        ResultWrapper result = new ResultWrapper();

        try {
            
            Order order = [SELECT Id, OrderNumber, Status, Owner__c, Owner__r.ManagerId FROM Order WHERE Id =: recordId];

            Set<Id> userSet = new Set<Id>{order.Owner__c, order.Owner__r.ManagerId};
            Boolean isAdmin = ordSvc.getAdminFlag();

            if(order.Status != ordSvc.ORDER_CREATE) {
                result.isSuccess = false;
                result.errorMsg  = System.Label.DNS_M_OrderCancelError02; // The order can only be cancel from CRM in the 'Created' stage.
            } else if(!(userSet.contains(UserInfo.getUserId()) || isAdmin)) {
                result.isSuccess = false;
                result.errorMsg  = System.Label.DNS_M_OrderCancelError01; // You do not have permission to cancel the order. Please contact the administrator.
            }

            return result;
            
        } catch (Exception e) {
            System.debug('validateOrderCancel : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 주문 상태 업데이트
    **/
    @AuraEnabled
    public static void cancelOrder(String recordId){
        try {

            Order order = new Order(
                Id = recordId
                , Status = ordSvc.ORDER_CANCELED
                , CancelReason__c = 'CRM'
            );
            update order;
            
        } catch (Exception e) {
            System.debug('cancelOrder : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 결과 반환 Wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String  errorMsg  {get;set;}
        public ResultWrapper(){
            this.isSuccess = true;
            this.errorMsg  = '';
        }
    }
}