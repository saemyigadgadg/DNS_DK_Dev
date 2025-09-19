/**
 * @component         : DNSA_OrderAddAccessoryBtn
 * @description       : 주문 Option Only Order에서 Accessory를 추가하는 버튼 컨트롤러
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-01-09   yeongju.yun   Initial Version
**/
public with sharing class DNSA_OrderAddAccessoryController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description 악세서리 추가 가능 여부 확인 및 기본 값 설정, 기존에 추가한 데이터 호출
    **/
    @AuraEnabled
    public static ResultWrapper fetchAccessory(String recordId){
        ResultWrapper result = new ResultWrapper();
        try {
            
            Order order = [
                SELECT  Id, OrderType__c, ReferenceOrder__c, ERPRSONo__c, RequestedShipDate__c
                        , ShipTo__c, Owner__r.AccountId
                FROM    Order 
                WHERE   Id =: recordId
            ];

            if(order.OrderType__c != 'ZUSO') {
                result.isPass   = false;
                result.errorMsg = 'Accrssories can only be added to Option Only Orders.';
            } else if(String.isNotBlank(order.ERPRSONo__c)) {
                result.isPass   = false;
                result.errorMsg = 'Accrssories can only be added at the \'Created\' status.';
            } else {
                // get category
                OrderItem prevItem = [
                    SELECT  Id, Product2.Model__r.Code__c, ReqShipDate__c
                    FROM    OrderItem 
                    WHERE   OrderId =: order.ReferenceOrder__c
                    AND     ItemCategory__c =: ordSvc.ITEM_PRODUCT
                    LIMIT 1
                ];

                IF_ERP_ORDER_CLASSES.IF_ORDER_008_Res response = getIFAccCategory(prevItem.Product2.Model__r.Code__c);
                
                if(response.O_RETURN.TYPE == 'E') {
                    
                    result.isPass   = false;
                    result.errorMsg = response.O_RETURN.MESSAGE;
                    return result;
                } else {

                    List<OptionWrapper> options = new List<OptionWrapper>();
                    for(IF_ERP_ORDER_CLASSES.IF_ORDER_008_Res_T_LIST row : response.T_LIST) {
                        options.add(new OptionWrapper(row.KIT_CAT_DSC, row.KIT_CAT));
                    }
                    result.data.put('category', options);
                }

                // get previous selected accessories
                List<OrderItem> items = [
                    SELECT  Id, Quantity, UnitPrice, ItemCategory__c, ShipTo__c, ShipTo__r.Name, ReqShipDate__c
                            , Unit__c, IF_POSNR__c, AccessoryCode__c, AccessoryName__c, AccessoryCategory__c
                    FROM    OrderItem
                    WHERE   OrderId =: recordId
                    AND     ItemCategory__c =: ordSvc.ITEM_ACCESSORY
                ];

                List<TableWrapper> tableWraps = new List<TableWrapper>();
                for(OrderItem item : items) {
                    tableWraps.add(new TableWrapper(item));
                }
                result.data.put('selTableData', tableWraps);

                // get ship to target
                Set<Id> targetShipToIds = new Set<Id>();
                targetShipToIds.add(order.ShipTo__c); // (1) order's ship to

                String dealerAccountId = order.Owner__r.AccountId;
                if(String.isNotBlank(dealerAccountId)) {
                    targetShipToIds.add(dealerAccountId); // (2) HQ & Subsidiary - Self

                    SalesAreaData__c salesArea = [SELECT Id, RelatedDistributor__c FROM SalesAreaData__c WHERE SalesOrganization__c = '4140' AND Account__c =:dealerAccountId LIMIT 1];
                    if(salesArea == null) {
                        result.isPass   = false;
                        result.errorMsg = 'No sales area data found for the order account. Please contact the administrator';
                        return result;
                    }

                    if(salesArea.RelatedDistributor__c == null) {
                        List<SalesAreaData__c> subAccounts = [SELECT Account__c FROM SalesAreaData__c WHERE SalesOrganization__c = '4140' AND RelatedDistributor__c =: dealerAccountId];
                        for(SalesAreaData__c acc : subAccounts) {
                            targetShipToIds.add(acc.Account__c); // (3) Subsidiary if HQ
                        }
                    }
                }

                result.data.put('targetShipToIds', targetShipToIds);

                Id dnsaRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'DNSACustomer']?.Id;
                result.data.put('dnsaRecordType', dnsaRecordType);

            }
            
            return result;
        } catch (Exception e) {
            System.debug('fetchAccessory : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 카테고리 기준으로 선택가능한 악세사리 목록 조회
    **/
    @AuraEnabled
    public static ResultWrapper getAccessoryData(String recordId, String category){
        ResultWrapper result = new ResultWrapper();
        try {
            
            Order order = [
                SELECT  Id, OrderType__c, Division__c, DistributionChannel__c, SalesOrganization__c
                        , ReferenceOrder__c, ShipTo__c, ShipTo__r.Name, RequestedShipDate__c, DNSA_SalesOffice__c
                FROM    Order
                WHERE   Id =: recordId
            ];

            OrderItem prevItem = [
                SELECT  Id, Product2.Model__r.Code__c, ReqShipDate__c
                FROM    OrderItem
                WHERE   OrderId =: order.ReferenceOrder__c
                AND     ItemCategory__c =: ordSvc.ITEM_PRODUCT
            ];

            IF_ERP_ORDER_CLASSES.IF_ORDER_009_Res response = getIFAccessories(category, prevItem, order.DNSA_SalesOffice__c);
            if(response.O_RETURN.TYPE == 'E') {
                result.isPass   = false;
                result.errorMsg = response.O_RETURN.MESSAGE;
                return result;
            } else {
                List<IF_ERP_ORDER_CLASSES.IF_ORDER_009_Res_T_LIST> accInfoList = response.T_LIST;
                List<TableWrapper> accRows = new List<TableWrapper>();
                for(IF_ERP_ORDER_CLASSES.IF_ORDER_009_Res_T_LIST T_LIST : accInfoList) {
                    accRows.add(new TableWrapper(T_LIST, order));
                }
                result.data.put('accRows', accRows);
            }
            
            return result;
        } catch (Exception e) {
            System.debug('getAccessoryData : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 선택한 악세사리 데이터 저장
    **/
    @AuraEnabled
    public static void saveAccessories(String recordId, List<TableWrapper> dataList){
        try {

            Order order = [SELECT Id, ShipTo__c, ReferenceOrder__c FROM Order WHERE Id =: recordId];
            List<OrderItem> oItems = [
                SELECT  Id, QuoteLineItemId, Product2Id, PricebookEntryId, OrderId
                        , AccessoryCategory__c, AccessoryCode__c 
                FROM    OrderItem 
                WHERE   OrderId =: recordId
            ];

            OrderItem refItem = [
                SELECT  Id, QuoteLineItemId, Product2Id, PricebookEntryId, OrderId
                FROM    OrderItem
                WHERE   OrderId =: order.ReferenceOrder__c
                AND     ItemCategory__c =: ordSvc.ITEM_PRODUCT
            ];

            Set<String> newDataKeySet = new Set<String>();
            for(TableWrapper data : dataList) {
                newDataKeySet.add(data.key);
            }

            List<OrderItem> toDeleteItems = new List<OrderItem>();
            Map<String, OrderItem> prevItemMap = new Map<String, OrderItem>();
            for(OrderItem item : oItems) {
                String key = item.AccessoryCategory__c + '/' + item.AccessoryCode__c;
                if(newDataKeySet.contains(key)) { prevItemMap.put(key, item);} // update
                else { toDeleteItems.add(item); } // delete
            }

            if(!toDeleteItems.isEmpty()) { 
                TriggerHandler.bypassedHandlers = new Set<String>{'OrderItemTriggerHandler'};
                delete toDeleteItems; 
                TriggerHandler.bypassedHandlers = new Set<String>();
            }

            List<OrderItem> toUpsertItems = new List<OrderItem>();
            Integer posnr = 10;
            for(TableWrapper data : dataList) {
                
                Boolean isNew  = !prevItemMap.containsKey(data.key);
                OrderItem item = isNew ? new OrderItem() : prevItemMap.get(data.key);
                item.AccessoryCategory__c = data.category;
                item.AccessoryCode__c     = data.accCode;
                item.AccessoryName__c     = data.accName;
                item.Quantity             = data.quantity;
                item.UnitPrice            = data.dcPrice ?? 0;
                item.Unit__c              = data.salesUnit;
                item.ItemCategory__c      = ordSvc.ITEM_ACCESSORY;
                item.IF_POSNR__c          = ordSvc.formatCodeForSAP(6, String.valueOf(posnr));

                item.ShipTo__c          = data.shipToId;
                item.ReqShipDate__c     = data.deliveryDate;
                
                if(isNew) {
                    item.OrderId          = recordId;
                    item.QuoteLineItemId  = refItem.QuoteLineItemId;
                    item.PricebookEntryId = refItem.PricebookEntryId;
                    item.Product2Id       = refItem.Product2Id;
                } else {
                    item.IF_FreePass__c = true;
                }

                toUpsertItems.add(item);
                posnr += 10;
            }

            if(!toUpsertItems.isEmpty()) { upsert toUpsertItems; }

        } catch (Exception e) {
            System.debug('saveAccessories : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }









    
    /**
    * @description 주문 제품 기준으로 선택가능한 악세사리 카테고리 리스트 I/F 실시간 호출
    **/
    public static IF_ERP_ORDER_CLASSES.IF_ORDER_008_Res getIFAccCategory(String modelCode) {
        
        IF_ERP_ORDER_CLASSES.IF_ORDER_008_Req request = new IF_ERP_ORDER_CLASSES.IF_ORDER_008_Req();
        request.I_MATNR = modelCode;

        IF_ERP_Order method = new IF_ERP_Order();
        IF_ERP_ORDER_CLASSES.IF_ORDER_008_Res response = method.IF_ORDER_008(request);
        return response;
    }

    /**
    * @description 카테고리 기준 악세사리 리스트 I/F 실시간 호출
    **/
    public static IF_ERP_ORDER_CLASSES.IF_ORDER_009_Res getIFAccessories(String category, OrderItem prevItem, String office) {

        IF_ERP_ORDER_CLASSES.IF_ORDER_009_Req request = new IF_ERP_ORDER_CLASSES.IF_ORDER_009_Req();
        request.I_KIT_CAT = category;
        request.I_MATNR   = prevItem.Product2.Model__r.Code__c;
        request.I_VKBUR   = '414A'; // 250407 가격은 414A Fixed

        IF_ERP_Order method = new IF_ERP_Order();
        IF_ERP_ORDER_CLASSES.IF_ORDER_009_Res response = method.IF_ORDER_009(request);
        return response;
    }

    /**
    * @description 결과 반환 Wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isPass   {get;set;}
        @AuraEnabled public String  errorMsg {get;set;}

        @AuraEnabled public Map<String, Object> data {get;set;}

        public ResultWrapper(){
            this.isPass   = true;
            this.errorMsg = '';
            this.data = new Map<String, Object>();
        }
    }

    /**
    * @description Picklist <> Component Option 변환 Wrapper
    **/
    public class OptionWrapper{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}

        public OptionWrapper(){
            this.label = '';
            this.value = '';
        }

        public OptionWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    /**
    * @description 주문 악세서리 조회, 선택한 데이터 테이블 wrapper
    **/
    public class TableWrapper{
        @AuraEnabled public String  recordId    {get;set;}
        @AuraEnabled public String  posnr       {get;set;}
        @AuraEnabled public String  key         {get;set;}

        @AuraEnabled public String  category    {get;set;}
        @AuraEnabled public String  accCode     {get;set;}
        @AuraEnabled public String  accName     {get;set;}
        @AuraEnabled public Decimal quantity    {get;set;}
        @AuraEnabled public Decimal price       {get;set;}
        @AuraEnabled public String  salesUnit   {get;set;}
        @AuraEnabled public Decimal dcPrice     {get;set;}

        @AuraEnabled public String  shipTo       {get;set;}
        @AuraEnabled public String  shipToId     {get;set;}
        @AuraEnabled public Date    deliveryDate {get;set;}

        public TableWrapper(){}

        public TableWrapper(OrderItem item){ // prev
            this.recordId = item.Id;
            this.posnr    = item.IF_POSNR__c;
            this.key      = item.AccessoryCategory__c + '/' + item.AccessoryCode__c;

            this.category  = item.AccessoryCategory__c;
            this.accCode   = item.AccessoryCode__c;
            this.accName   = item.AccessoryName__c;
            this.quantity  = item.Quantity;
            this.price     = item.UnitPrice;
            this.salesUnit = item.Unit__c;
            this.dcPrice   = this.price;

            this.shipTo       = item.ShipTo__r.Name;
            this.shipToId     = item.ShipTo__c;
            this.deliveryDate = item.ReqShipDate__c;
        }
        public TableWrapper(IF_ERP_ORDER_CLASSES.IF_ORDER_009_Res_T_LIST item, Order order){ // new
            this.key = item.KIT_CAT + '/' + item.KIT;
            
            this.category  = item.KIT_CAT;
            this.accCode   = item.KIT;
            this.accName   = item.KIT_T;
            this.quantity  = 1;
            this.price     = Decimal.valueOf(item.KBETR) ?? 0;
            this.salesUnit = item.MEINS;
            this.dcPrice   = this.price * (1 + (Decimal.valueOf(item.DISCOUNT) / 100));

            this.shipTo       = order.ShipTo__r.Name;
            this.shipToId     = order.ShipTo__c;
            this.deliveryDate = order.RequestedShipDate__c;
        }
    }

}