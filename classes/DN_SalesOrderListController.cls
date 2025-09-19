/**
 * @author            : iltea.seo
 * @Description       : 
 * @last modified on  : 2024-11-21
 * @last modified by  : iltae.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-21   iltae.seo@sbtglobal.com       Initial Version
**/
public with sharing class DN_SalesOrderListController {
    /**
    * @description 오더 목록 조회
    * @author iltae.seo | 2024-11-21 
    **/
    @AuraEnabled
    public static List<Orders> getOrder(String accountId){
        try {
            List<Orders> orderList = new List<Orders>();
            List<Order> orders = [select Id, ERPOrderNo__c, ERPPSONo__c, Account.Name, ShippingStreet, AccountId from Order 
                                    where AccountId =:accountId 
                                    AND (ERPPSONo__c != null OR ERPOrderNo__c != null)];
            for(Order ord : orders) {
                orderList.add(new Orders(ord));
            }
            return orderList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 오더 클래스
    * @author iltae.seo | 2024-11-21 
    **/
    public class Orders {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String orderNumber {get;set;}
        @AuraEnabled public String customer {get;set;}
        @AuraEnabled public String shipping {get;set;}
        public Orders(Order order) {
            this.id = order.Id;
            this.orderNumber = String.isNotBlank(order.ERPPSONo__c) ? order.ERPPSONo__c : order.ERPOrderNo__c;
            // this.orderNumber = order.ERPPSONo__c;
            this.customer = order.Account.Name;
            this.shipping = order.ShippingStreet;
        }
        
    }
}