/**
 * @related           : DN_OrderCloneBtn
 * @description       : Order와 제품, Pricing, Payment Schdule 복제
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-01-14   yeongju.yun   Initial Version
 * 1.1   2025-03-24   yeongju.yun   EDIT01. 글로벌은 Clone기능 사용 X, 국내는 제품,CV,SQ,ACC기준으로 조회
**/
public with sharing class DN_OrderCloneController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description 복제 대상 견적 제품 조회
    * @author yeongju.yun | 2024-12-23 
    * @param recordId order Id
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> fetchInit(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        try {

            Order order = [SELECT Id, QuoteId, OwnerId, Status, OrderSegmentation__c, SalesChannelType__c FROM Order WHERE Id =: recordId];
            if(order.OwnerId != UserInfo.getUserId()) {
                result.put('isPass', false);
                result.put('errorMsg', System.Label.DNS_E_OnlyOnwerClone); // Only the owner can clone the current order.
                return result;
            } else if(order.Status == ordSvc.ORDER_CANCELED) {
                result.put('isPass', false);
                result.put('errorMsg', System.Label.DNS_M_CannotClone); // Cancelled orders cannot be cloned.
                return result;
            }

            OrderItem oItem = [SELECT Id, QuoteLineItemId, Order.Warranty__c, AdjustmentPrice__c FROM OrderItem WHERE ItemCategory__c = :ordSvc.ITEM_PRODUCT AND OrderId = :recordId];

            List<QuoteLineItem> quoteLineList = [
                SELECT  Id 
                        , Product2Id
                        , Product2.Name
                        , Product2.Name__c
                        , Product2.IsStrategicMaterial__c
                        , RequestedDelivDate__c
                        , ExpectedDelivDate__c
                        , ERPQuotationNo__c
                        , UnitPrice
                        , ListPrice
                        , Dealer_Price__c
                        , Warranty__c
                        , Adjustment_Price__c
                        , (SELECT SQ__c FROM SQ_QuoteLineitem_Junction__r ORDER BY SQ__c)
                        , (SELECT C_Code__c, V_Code__c FROM CharacteristicValue__r ORDER BY C_Code__c, V_Code__c)
                        , (SELECT Name FROM Accessories__r ORDER BY Name)
                FROM    QuoteLineItem 
                WHERE   (QuoteId =:order.QuoteId
                            AND Order__c = null
                            AND CVComplete__c = TRUE
                            AND ERPQuotationNo__c <> null)
                OR      (Id =: oItem.QuoteLineItemId)
                ORDER BY CreatedDate
            ];

            Boolean isUser = ordSvc.IS_USER;
            String baseUrl = ordSvc.getBaseUrl(!isUser);
            Boolean isDomestic = ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c);

            String baseKey;
            List<ProductWrapper> allProdWrapList = new List<ProductWrapper>();
            for(QuoteLineItem item : quoteLineList) {
                ProductWrapper wrap = new ProductWrapper(item, baseUrl);
                wrap.key = 'prod_' + wrap.productId + '_sq_' + wrap.sq + '_cv_' + wrap.cv + '_acc_' + wrap.acc;

                if(item.Id == oItem.QuoteLineItemId) { 
                    baseKey = wrap.key; 
                } else { 
                    allProdWrapList.add(wrap); 
                }
            }

            List<ProductWrapper> prodWrapList = new List<ProductWrapper>();
            for(ProductWrapper wrap : allProdWrapList) {
                if(wrap.key == baseKey) { prodWrapList.add(wrap); }
            }

            if(prodWrapList.isEmpty()) {
                result.put('isPass', false);
                result.put('errorMsg', System.Label.DNS_M_SameProdsClone); // Only quote products with the same main specification, CV, SQ, and accessories can be duplicated.
                return result;
            }

            result.put('isPass', true);
            result.put('prods', prodWrapList);
            return result;
            
        } catch (Exception e) {
            System.debug('fetchInit : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 복제할 견적 제품 Wrapper
    **/
    public class ProductWrapper{
        @AuraEnabled public String  quoteItemId    {get;set;}
        @AuraEnabled public String  quoteItemLink  {get;set;}
        @AuraEnabled public String  productId      {get;set;}
        @AuraEnabled public String  productName    {get;set;}
        @AuraEnabled public String  qERPNo         {get;set;}
        @AuraEnabled public Date    rdd            {get;set;}
        @AuraEnabled public Decimal qListPrice     {get;set;}
        @AuraEnabled public Decimal qDealerPrice   {get;set;}

        @AuraEnabled public String  sq             {get;set;}
        @AuraEnabled public String  cv             {get;set;}
        @AuraEnabled public String  acc            {get;set;}
        @AuraEnabled public String  key            {get;set;}

        public ProductWrapper(){}
        public ProductWrapper(QuoteLineItem item, String baseUrl){
            this.quoteItemId    = item.Id;
            this.quoteItemLink  = baseUrl + '/' + item.Id;
            this.productId      = item.Product2Id;
            this.productName    = item.Product2.Name__c;
            this.qERPNo         = item.ERPQuotationNo__c;
            this.rdd            = item.RequestedDelivDate__c;
            this.qListPrice     = item.ListPrice;
            this.qDealerPrice   = item.Dealer_Price__c;

            // sq
            String sqStr = '';
            for(SQ_QuoteLineitem_Junction__c sqRow : item.SQ_QuoteLineitem_Junction__r) {
                sqStr += sqRow.SQ__c;
            }
            this.sq = sqStr;

            // cv
            String cvStr = '';
            for(CharacteristicValue__c cvRow : item.CharacteristicValue__r) {
                cvStr += cvRow.C_Code__c + cvRow.V_Code__c;
            }
            this.cv = cvStr;

            // acc
            String accStr = '';
            for(Accessory__c accRow : item.Accessories__r) {
                accStr += accRow.Name;
            }
            this.acc = accStr;
        }
    }

    /**
    * @description 견적 및 기존 주문 정보로 신규 주문 생성
    **/
    @AuraEnabled
    public static ResultWrapper cloneCurrOrder(String recordId, Date reqDeliveryDate, List<ProductWrapper> prodList){
        ResultWrapper resultWrap = new ResultWrapper();
        
        Savepoint sp = Database.setSavepoint();

        try {

            String sObjName     = 'Order';
            String fieldSetName = 'DNS_OrderClone';

            List<String> fieldList = new List<String>();
            for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get(sObjName).getDescribe().fieldSets.getMap().get(fieldSetName).getFields()) {
                fieldList.add(f.getFieldPath());
            }

            String query = ' SELECT ' + String.join(fieldList, ', ') + ' FROM ' + sObjName + ' WHERE Id = :recordId ';
            Order prevOrder = (Order) Database.query(query);

            List<Order> newOrders = new List<Order>();
            for(Integer i = 0; i < prodList.size(); i++) {
                Order newOrder                = prevOrder.clone(false, false, false, false);
                newOrder.Status               = ordSvc.ORDER_CREATE;
                newOrder.ReqDeliveryDate__c   = reqDeliveryDate;
                newOrder.EffectiveDate        = Date.today();
                newOrders.add(newOrder);
            }
            if(!newOrders.isEmpty()) { insert newOrders; }

            List<String> oItemFields = new List<String>();
            for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get('OrderItem').getDescribe().fieldSets.getMap().get('DNS_OrderClone').getFields()) {
                oItemFields.add(f.getFieldPath());
            }

            String itemQuery = ' SELECT ' + String.join(oItemFields, ', ') + ' FROM OrderItem WHERE OrderId = :recordId ';
            List<OrderItem> items = (List<OrderItem>) Database.query(itemQuery);

            List<OrderPricingSelected__c> selPriceList = [
                SELECT Id, CurrencyIsoCode, Order__c, Key__c, Type__c, Amount__c, SpecialAmount__c, Rate__c
                FROM OrderPricingSelected__c 
                WHERE Order__c =: recordId
            ];

            List<OrderItem> newItems = new List<OrderItem>();
            List<OrderPricingSelected__c> newPricings = new List<OrderPricingSelected__c>();
            Map<Id, Id> quoteLineMap = new Map<Id, Id>(); // key : quotelineitem id, value : order id
            Id productItemId;
            Integer idx = 0;
            for(Order o : newOrders) {
                ProductWrapper wrap = prodList[idx];

                quoteLineMap.put(wrap.quoteItemId, o.Id);
                idx++;

                for(OrderItem oi : items) {
                    if(oi.ItemCategory__c == ordSvc.ITEM_PRODUCT) { productItemId = oi.Id; }
                    Orderitem clonedItem = oi.clone(false, false, false, false);
                    clonedItem.OrderId   = o.Id;
                    newItems.add(clonedItem);
                }

                for(OrderPricingSelected__c selPrice : selPriceList) {
                    OrderPricingSelected__c clonedPrice = selPrice.clone(false, false, false, false);
                    clonedPrice.Order__c = o.Id;
                    newPricings.add(clonedPrice);
                }
            }
            if(!newItems.isEmpty()) { insert newItems; }
            if(!newPricings.isEmpty()) { insert newPricings; }

            // connect the quote line item width order
            List<QuoteLineItem> toUpdateItemList = new List<QuoteLineItem>();
            for(Id quoteItemId : quoteLineMap.keySet()) {
                toUpdateItemList.add(new QuoteLineItem(
                    Id = quoteItemId
                    , Order__c = quoteLineMap.get(quoteItemId)
                ));
            }
            if(!toUpdateItemList.isEmpty()) { update toUpdateItemList; }

            // CV
            if(productItemId != null) {
                List<CVOrderItem__c> cvList = [SELECT Id, CharacteristicValue__c FROM CVOrderItem__c WHERE OrderProduct__c =: productItemId];

                List<CVOrderItem__c> toInsertCV = new List<CVOrderItem__c>();
                for(OrderItem nItem : newItems) {
                    if(nItem.ItemCategory__c != ordSvc.ITEM_PRODUCT) continue;

                    for(CVOrderItem__c cv : cvList) {
                        CVOrderItem__c clonedCV  = cv.clone(false, false, false, false);
                        clonedCV.OrderProduct__c = nItem.Id;
                        toInsertCV.add(clonedCV);
                    }
                }
                if(!toInsertCV.isEmpty()) { insert toInsertCV; }
            }

            // payment schedule
            List<PaymentSchedule__c> pScheduleList = [
                SELECT  Id, CurrencyIsoCode, Order__c, DraftNo__c, DocumentDate__c, ReqDeliveryDate__c, TotalAmount__c, DraftNoText__c, DraftCheck__c
                FROM    PaymentSchedule__c
                WHERE   Order__c =: recordId
            ];

            if(!pScheduleList.isEmpty()) {
                PaymentSchedule__c pSchedule = pScheduleList[0];
                List<PaymentSchedule__c> toInsertPSList = new List<PaymentSchedule__c>();
                for(Order o : newOrders) {
                    PaymentSchedule__c clonedPS = pSchedule.clone(false, false, false, false);
                    clonedPS.Order__c = o.Id;
                    toInsertPSList.add(clonedPS);
                }

                if(!toInsertPSList.isEmpty()) { insert toInsertPSList; }
                
                List<PaymentScheduleItem__c> psItemList = [
                    SELECT  Id, PaymentSchedule__c, Type__c, ScheduledDate__c, PaymentTerms__c, CapitalCompany__c, InputAmount__c, InstallmentPrincipal__c, Days__c
                    FROM    PaymentScheduleItem__c
                    WHERE   PaymentSchedule__c = : pSchedule.Id
                ];

                if(!psItemList.isEmpty()) {
                    List<PaymentScheduleItem__c> toInsertPSItemList = new List<PaymentScheduleItem__c>();
                    for(PaymentSchedule__c ps : toInsertPSList) {
                        for(PaymentScheduleItem__c psItem : psItemList) {
                            PaymentScheduleItem__c clonedPSItem = psItem.clone(false, false, false, false);
                            clonedPSItem.PaymentSchedule__c = ps.Id;
                            toInsertPSItemList.add(clonedPSItem);
                        }
                    }
                    if(!toInsertPSItemList.isEmpty()) { insert toInsertPSItemList; }
                }
            }

            resultWrap.data.put('newOrderId', newOrders[0].Id);

            return resultWrap;
            
        } catch (Exception e) {
            System.debug('cloneCurrOrder : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
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
}