/**
 * @author            : yeongju.yun
 * @test              : OrderItemTriggerHandlerTest
 * @last modified on  : 2025-07-23
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-10-29   yeongju.yun   Initial Version
**/
public with sharing class OrderItemTriggerHandler extends TriggerHandler {
    public static DN_OrderService ordSvc = new DN_OrderService();

    /**
    * @description Order Product 생성 시 관련 Order 데이터를 검색용으로 필드에 업데이트, 제품 코드 동기화 포함
    **/
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if (isExecuting) {

            List<OrderItem> itemList = (List<OrderItem>) news;
            Map<String, OrderItem> orderMap = new Map<String, OrderItem>();
            Map<Id, Order> toUpdateOrders = new Map<Id, Order>();

            // sync product code
            Set<Id> prodIdSet = new Set<Id>();
            for(OrderItem item : itemList) {
                if(item.ItemCategory__c == ordSvc.ITEM_PRODUCT) { prodIdSet.add(item.Product2Id); }
            }

            Map<Id, String> prodMap = new Map<Id, String>(); // key : prod id, value : prod code
            if(!prodIdSet.isEmpty()) {
                List<Product2> prodList = [SELECT Id, Name FROM Product2 WHERE Id =: prodIdSet];
                for(Product2 prod : prodList) {
                    prodMap.put(prod.Id, prod.Name);
                }
            }

            for(OrderItem item : itemList) {

                Order tempOrder = toUpdateOrders.containsKey(item.OrderId) ? toUpdateOrders.get(item.OrderId) : new Order(Id = item.OrderId);
                tempOrder.IF_FreePass__c = true;

                Boolean toUpdate = false;
                if(item.IsInspection__c) {
                    tempOrder.IsInspectionNeeded__c = true;
                    toUpdate = true;
                }

                if(item.BillingDate__c != null && item.IF_POSNR__c == '000010') {
                    tempOrder.IsBilled__c = 'Y';
                    tempOrder.BillingDate__c = item.BillingDate__c;
                    toUpdate = true;
                }

                if(item.ItemCategory__c == ordSvc.ITEM_PRODUCT && prodMap.containsKey(item.Product2Id)) {
                    tempOrder.Product__c = prodMap.get(item.Product2Id);
                    toUpdate = true;
                }

                if(toUpdate) { toUpdateOrders.put(tempOrder.Id, tempOrder); }
            }

            if(!toUpdateOrders.isEmpty()) { update toUpdateOrders.values(); }
            
            setting(false, TriggerOperation.AFTER_INSERT);
        }
    }

    /**
    * @description 일반 사용자는 Order Product 수정 불가
    **/
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            List<OrderItem> itemList = (List<OrderItem>) news;
            Map<Id, OrderItem> itemMap = (Map<Id, OrderItem>) oldMap;

            Boolean isAdmin = ordSvc.getAdminFlag();
            for(OrderItem item : itemList) {
                if(isAdmin) { continue; }
                if(item.IF_FreePass__c) { 
                    item.IF_FreePass__c = false;
                    bypass('OrderTriggerHandler'); // rollup으로 인한 업데이트 방지
                    continue;
                }

                item.addError(System.Label.DNS_E_OrderProductNeverChange); // Order products cannot be modified.
            }
        }
    }

    /**
    * @description BillingDate__c업데이트 시 주문의 빌링 상태 업데이트
    **/
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            List<OrderItem> itemList = (List<OrderItem>) news;
            Map<Id, OrderItem> itemMap = (Map<Id, OrderItem>) oldMap;

            Set<Id> orderIds = new Set<Id>();
            Map<Id, Date> billMap = new Map<Id, Date>(); // key : order id, value : billing date
            for(OrderItem item : itemList) {
                if(itemMap.get(item.Id).BillingDate__c == null && item.BillingDate__c != null) {
                    orderIds.add(item.OrderId);
                    billMap.put(item.OrderId, item.BillingDate__c);
                }
            }

            System.debug('=================');
            System.debug(!orderIds.isEmpty());
            System.debug('=================');

            if(!orderIds.isEmpty()) {
                List<Order> orders = [SELECT Id, IsBilled__c FROM Order WHERE Id =: orderIds];
                List<Order> toUpdateOrders = new List<Order>();
                for(Order order : orders) {
                    if(order.IsBilled__c == 'N' || order.IsBilled__c == null) {
                        order.IsBilled__c = 'Y';
                        order.BillingDate__c = billMap.get(order.Id);
                        order.IF_FreePass__c = true;
                        toUpdateOrders.add(order);
                    }
                }

                if(!toUpdateOrders.isEmpty()) { update toUpdateOrders; }
            }


            setting(false, TriggerOperation.AFTER_UPDATE);
        }
    }

    /**
    * @description 일반 사용자는 삭제 불가
    **/
    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
        if(isExecuting) {
            List<OrderItem> itemList = (List<OrderItem>) dels;

            Boolean isAdmin = ordSvc.getAdminFlag();
            for(OrderItem item : itemList) {

                if(isAdmin) { continue; }
                item.addError(System.Label.DNS_M_OrderProductNeverDelete); // Order products cannot be deleted.
            }
            
            setting(false, TriggerOperation.BEFORE_DELETE);
        }
    }
}