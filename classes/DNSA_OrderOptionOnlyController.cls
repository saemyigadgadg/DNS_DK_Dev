/**
 * @component         : DNSA_OrderOptionOnlyBtn
 * @description       : DNSA에서 최근 6개월 주문 중 Accessory만 따로 구매하는 버튼 컨트롤러
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-01-08   yeongju.yun   Initial Version
**/
public with sharing class DNSA_OrderOptionOnlyController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description Validation and Default Value Setting for Option-Only Orders
                    Valudation Rule : 일반 주문, 배송일 기준 6개월 이내의 주문
    * @author yeongju.yun | 2025-01-08 
    * @param recordId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> fetchInit(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        try {

            Boolean isPass  = true;
            String errorMsg = '';

            Order order = [SELECT Id, OrderType__c, ActualShippingDate__c, OwnerId, AccountId  FROM Order WHERE Id =: recordId];
            Date sixMonthsAgo = Date.today().addMonths(-6);

            // Valudation Rule
            if(order.OrderType__c == 'ZUSO') { // 'ZUSO' == Option Only Order
                isPass  = false;
                errorMsg = 'You cannot create an Option Only Order from another Option Only Order.';
            } else if(order.ActualShippingDate__c < sixMonthsAgo || order.ActualShippingDate__c == null) {
                isPass  = false;
                errorMsg = 'Option Only Orders can only be created for orders placed within the last 6 months from the actual shipping date.';
            } 

            if(!isPass) {
                result.put('isPass', isPass);
                result.put('errorMsg', errorMsg);
                return result;
            }
            
            result.put('AccountId', order.AccountId);

            result.put('isPass', isPass);
            result.put('errorMsg', errorMsg);
            return result;
            
        } catch (Exception e) {
            System.debug('fetchInit : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Option Only 주문 생성
    **/
    @AuraEnabled
    public static String saveOptionOnlyOrder(String recordId, Order newOrder){
        try {

            String sObjName     = 'Order';
            String fieldSetName = 'DNSA_OptionOnly';

            List<String> fieldList = new List<String>();
            for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get(sObjName).getDescribe().fieldSets.getMap().get(fieldSetName).getFields()) {
                fieldList.add(f.getFieldPath());
            }

            String query = ' SELECT ' + String.join(fieldList, ', ') + ' FROM ' + sObjName + ' WHERE Id = :recordId ';
            Order prevOrder = (Order) Database.query(query);

            Order toInsertOrder = prevOrder.clone(false, false, false, false);
            toInsertOrder.ReferenceOrder__c   = recordId; // 이후 제품 추가 시 참조하기 위함
            toInsertOrder.Status              = ordSvc.ORDER_CREATE;
            toInsertOrder.RequestedShipDate__c= newOrder.RequestedShipDate__c;
            toInsertOrder.OrderType__c        = 'ZUSO'; // FIXED
            toInsertOrder.DNSA_SalesOffice__c = '414A'; // FIXED
            toInsertOrder.EffectiveDate       = Date.today();
            toInsertOrder.PurchaseOrderNo__c  = newOrder.PurchaseOrderNo__c;

            toInsertOrder.AccountId           = newOrder.AccountId;
            toInsertOrder.ShipTo__c           = newOrder.AccountId;

            User u = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
            toInsertOrder.SalesRep__c = u.AccountId;

            insert toInsertOrder;
            
            return toInsertOrder.Id;
        } catch (Exception e) {
            System.debug('saveOptionOnlyOrder : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}