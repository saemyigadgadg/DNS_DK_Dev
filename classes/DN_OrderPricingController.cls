/**
 * @description       : [dN_OrderPricing]
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-03   yeongju.yun   Initial Version
 * 1.1   2025-05-26   yeongju.yun   EIDT01. Order Incentive Order BY 추가
**/
public with sharing class DN_OrderPricingController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    public static Map<String, String> specialConvertMap = new Map<String, String>{
        'consignment' => 'ZPRC-0001'
        , 'wholesale' => 'ZSSX-0001'
        , 'longterm'  => 'ZSSX-0002'
        , 'ZPRC-0001' => 'consignment'
        , 'ZSSX-0001' => 'wholesale'
        , 'ZSSX-0002' => 'longterm'
    };
    
    /**
    * @description 가격 산정 정보 조회, 기준 값 전달
    * @author yeongju.yun | 2024-12-04 
    * @param recordId 
    * @return Map<String, Object> 
    * [PricingHeader] priceInfo
    * [Map<String, List<PricingDetailWrapper>>] details
    * [Boolean] isSyncPrice   : sync price 진행 여부
    * [Boolean] openWholesale : true - 도매, false - 위탁 or 직영
    * [Boolean] isSentERP     : ERP 전송 여부, 버튼 제어
    * [String] segmentation   : order segmentation label
    **/
    @AuraEnabled
    public static Map<String, Object> fetchInitData(String recordId){
        Map<String, Object> result = new Map<String, Object>();

        try {
            Order order = [
                SELECT Id, Status, IsSyncPrice__c, OrderSegmentation__c, toLabel(OrderSegmentation__c) orderSeg
                        , ERPOrderNo__c, SalesChannelType__c, OwnerId
                FROM Order 
                WHERE Id =: recordId
            ];

            Boolean isDomestic = ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c);
            PricingHeader priceInfo = getPriceInfo(recordId, isDomestic);
            result.put('priceInfo', priceInfo);
            
            Map<String, List<PricingDetailWrapper>> details = getPricingDetails(recordId);
            result.put('details', details);

            result.put('isSyncPrice',   order.IsSyncPrice__c);
            result.put('openWholesale', order.OrderSegmentation__c == ordSvc.SEG_WHOLESALE);
            result.put('segmentation',  order.get('orderSeg'));

            Boolean isManager = ordSvc.isManager(order.OwnerId);
            Boolean isSentERP = String.isNotBlank(order.ERPOrderNo__c);
            Boolean isAdmin   = ordSvc.getAdminFlag();

            Boolean prevetSave = (!isManager && order.Status != ordSvc.ORDER_CREATE) || isSentERP;
            result.put('prevetSave', prevetSave);

            return result;
        } catch (Exception e) {
            System.debug('fetchInitData : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 가격산정 기본값 & 기존값 조회
    **/
    private static PricingHeader getPriceInfo(String recordId, Boolean isDomestic){
        PricingHeader priceInfo = new PricingHeader();
        
        List<OrderItem> itemList = [SELECT Id, ItemCategory__c, StandardPrice__c, DealerPrice__c, CurrencyIsoCode, Quantity FROM OrderItem WHERE OrderId =: recordId];
        priceInfo.currCode = itemList[0].CurrencyIsoCode;
        
        for(OrderItem item : itemList) {
            if(String.isBlank(item.ItemCategory__c)) continue;
            
            String type = item.ItemCategory__c;
            if(type == ordSvc.ITEM_PRODUCT) {
                Decimal stdPrice   = item.StandardPrice__c ?? 0;
                Decimal stdDCPrice = item.DealerPrice__c ?? 0;
                priceInfo.productStd = stdPrice;
                priceInfo.productDC  = stdDCPrice - stdPrice;

            } else if(type == ordSvc.ITEM_SQ) {
                Decimal tempSQ = item.StandardPrice__c * item.Quantity ?? 0;
                priceInfo.sqStd += tempSQ;
                priceInfo.sqDC  += tempSQ * -0.2;
            } else if(type == ordSvc.ITEM_ACCESSORY) {
                Decimal tempAcc = item.StandardPrice__c * item.Quantity ?? 0;
                priceInfo.accStd += tempAcc;
                priceInfo.accDC  += tempAcc * -0.2;
            }
        }
        
        List<CVOrderItem__c> cvList = [SELECT Id, OrderProduct__c, OrderProduct__r.OrderId, CharacteristicValue__r.Price__c FROM CVOrderItem__c WHERE OrderProduct__r.OrderId =:recordId ];
        for(CVOrderItem__c cv : cvList) {
            Decimal tempCV = cv.CharacteristicValue__r.Price__c ?? 0;
            priceInfo.cvStd += tempCV;
            priceInfo.cvDC  += tempCV * -0.2;
        }

        Order order = [SELECT Id, OrderSegmentation__c, Owner__r.Account.DealerGrade__c, PaymentTerms__c FROM Order WHERE Id = :recordId];
        if(isDomestic) {
            if(priceInfo.productDC == 0) { priceInfo.dcType = '-'; } 
            else {

                if(order.OrderSegmentation__c == ordSvc.SEG_WHOLESALE) { priceInfo.dcType = ordSvc.DISCOUNTTYPE01; }
                else if(order.OrderSegmentation__c == ordSvc.SEG_CONSIGNMENT) { priceInfo.dcType = ordSvc.DISCOUNTTYPE02; }
                else { priceInfo.dcType = ordSvc.DISCOUNTTYPE05; }

                Set<String> tempType = new Set<String>();

                // PaymentTerms__c에 따라 5일 ~ 60일, 해당하지 않는 조건일 때는 생략
                if(ordSvc.DISCOUNTPAYMENT.containsKey(order.PaymentTerms__c)) {
                    tempType.add(ordSvc.DISCOUNTPAYMENT.get(order.PaymentTerms__c));
                }

                if(!tempType.isEmpty()) {
                    priceInfo.dcType += '(';
                    priceInfo.dcType += String.join(tempType, ',');
                    priceInfo.dcType += ')';
                }
            }
        } 

        return priceInfo;
    }

    /**
    * @description 가격산정 하위의 프로모션, 인센티브 정보 조회
    **/
    private static Map<String, List<PricingDetailWrapper>> getPricingDetails(String recordId){
        Map<String, List<PricingDetailWrapper>> pdMap = new Map<String, List<PricingDetailWrapper>>(); // key : type, value : details

        List<OrderPromotion__c> promotionList = [
            SELECT  Id, Name, CalculateType__c, IsSpecial__c, PromotionCode__c, Amount__c, Rate__c
            FROM OrderPromotion__c
            WHERE F_IsActive__c = TRUE
            ORDER BY SpecialOrder__c
        ];
        
        List<PricingDetailWrapper> promotionWrapList = new List<PricingDetailWrapper>();
        List<PricingDetailWrapper> specialWrapList   = new List<PricingDetailWrapper>();
        Boolean isFirst = true;
        for(OrderPromotion__c pd : promotionList) {
            if(pd.IsSpecial__c) {
                specialWrapList.add(new PricingDetailWrapper(pd));
            } else {
                promotionWrapList.add(new PricingDetailWrapper(pd, isFirst));
                isFirst = false;
            }
        }
        pdMap.put('Promotion', promotionWrapList);
        pdMap.put('Special',   specialWrapList);

        List<PricingDetailWrapper> incentiveWrapList = new List<PricingDetailWrapper>();
        List<OrderIncentive__c> incenList = [
            SELECT  Id, Name, InputAutomatically__c, ApplicationRate__c, F_IsActive__c
            FROM    OrderIncentive__c
            WHERE   F_IsActive__c = TRUE
            ORDER BY IsFirst__c DESC
        ]; // EIDT01. Order Incentive Order BY 추가
        isFirst = true;
        for(OrderIncentive__c oi : incenList) {
            incentiveWrapList.add(new PricingDetailWrapper(oi, isFirst));
            isFirst = false;
        }
        pdMap.put('Incentive', incentiveWrapList);

        // 기존 데이터 확인
        List<OrderPricingSelected__c> selectedList = [
            SELECT  Id, Name, Order__c, CurrencyIsoCode, Key__c, Type__c, Amount__c, SpecialAmount__c
            FROM    OrderPricingSelected__c 
            WHERE   Order__c =: recordId
        ];

        if(!selectedList.isEmpty()) {
            for(OrderPricingSelected__c selected : selectedList){
                if(pdMap.containsKey(selected.Type__c)) {
                    List<PricingDetailWrapper> wrapList = pdMap.get(selected.Type__c);
                    for(PricingDetailWrapper wrap : wrapList) {
                        String tempKey = wrap.Key;
                        if(selected.Type__c == 'Special') tempKey = specialConvertMap.get(wrap.Key);

                        if(tempKey != selected.Key__c) continue;
                        wrap.isChecked = true;
                        wrap.price     = selected.Amount__c;
                    }
                    pdMap.put(selected.Type__c, wrapList);
                }
            }
        }

        return pdMap;
    }

    /**
    * @description Pricing Header Information (domestic, global, dnsa)
    * @Variable
    * [String]  currCode   : currency code
    * [String]  dcType     : 정상할인 내 할인 타입, e.g. 도매 공급가 (가그룹, 30일)
    * [Decimal] productStd : product standard price
    * [Decimal] sqStd      : sq standard price
    * [Decimal] cvStd      : cv standard price
    * [Decimal] accStd     : accessory standard price
    * [Decimal] productDC  : product discount price
    * [Decimal] sqDC       : sq discount price
    * [Decimal] cvDC       : cv discount price
    * [Decimal] accDC      : accessory discount price
    */
    public class PricingHeader{
        @AuraEnabled public String  currCode {get;set;}  
        @AuraEnabled public String  dcType   {get;set;}   

        @AuraEnabled public Decimal productStd {get;set;}
        @AuraEnabled public Decimal sqStd      {get;set;}
        @AuraEnabled public Decimal cvStd      {get;set;}
        @AuraEnabled public Decimal accStd     {get;set;}

        @AuraEnabled public Decimal productDC {get;set;}
        @AuraEnabled public Decimal sqDC      {get;set;}
        @AuraEnabled public Decimal cvDC      {get;set;}
        @AuraEnabled public Decimal accDC     {get;set;}
        
        public PricingHeader(){
            this.productStd = 0;
            this.sqStd      = 0;
            this.cvStd      = 0;
            this.accStd     = 0;
            this.productDC  = 0;
            this.sqDC       = 0;
            this.cvDC       = 0;
            this.accDC      = 0;
        }
    }

    /**
     * @description Pricing 특별공급(special), 프로모션(promotion), 인센티브 (incentive)
     * @Variable
     * [String]  key        : OrderPricingDetails__c or Special (consignment, wholesale, etc)
     * [String]  title      : label
     * [Decimal] rate       : percent
     * [Decimal] price      : Special only used
     * [Boolean] price      : Special only used
     * [Boolean] isAuto     : false = input field
     * [Boolean] isChecked  
     * [Boolean] isFirstRow 
     */
    public class PricingDetailWrapper{
        @AuraEnabled public String  key        {get;set;}
        @AuraEnabled public String  title      {get;set;}
        @AuraEnabled public Decimal rate       {get;set;}
        @AuraEnabled public Decimal price      {get;set;}
        @AuraEnabled public Decimal sPrice     {get;set;}
        @AuraEnabled public Decimal dcRate     {get;set;}
        @AuraEnabled public Boolean isAuto     {get;set;}
        @AuraEnabled public Boolean isChecked  {get;set;}
        @AuraEnabled public Boolean isFirstRow {get;set;}

        public PricingDetailWrapper(){}

        public PricingDetailWrapper(OrderPromotion__c pd){
            this.key        = specialConvertMap.get(pd.PromotionCode__c);
            this.title      = pd.Name;
            this.rate       = pd.Rate__c;
            this.price      = pd.Amount__c;
            this.isAuto     = pd.CalculateType__c == 'A';
            this.isChecked  = false;
            this.isFirstRow = false;
        }

        public PricingDetailWrapper(OrderPromotion__c pd, Boolean isFirstRow){
            this.key        = pd.PromotionCode__c;
            this.title      = pd.Name;
            this.rate       = pd.Rate__c;
            this.price      = pd.Amount__c;
            this.isAuto     = pd.CalculateType__c == 'A';
            this.isChecked  = false;
            this.isFirstRow = isFirstRow;
        }

        public PricingDetailWrapper(OrderIncentive__c oi, Boolean isFirstRow){
            this.key        = oi.Id;
            this.title      = oi.Name;
            this.rate       = oi.ApplicationRate__c;
            this.isAuto     = oi.InputAutomatically__c;
            this.isChecked  = false;
            this.isFirstRow = isFirstRow;
        }
    }

    /**
    * @description 가격정보 저장
    * @author yeongju.yun | 2024-12-04 
    * @param recordId 
    * @param detailsJSON 
    * @param specialDC 
    * @param finalOrderPrice 
    **/
    @AuraEnabled
    public static void savePricing(
        String recordId
        , String detailsJSON
        , Decimal specialDC
        , Decimal finalOrderPrice
    ){
        SavePoint sp = Database.setSavePoint();
        try {
            List<OrderPricingSelected__c> prevData = [SELECT Id FROM OrderPricingSelected__c WHERE Order__c =: recordId];
            if(!prevData.isEmpty()) { delete prevData; }

            Order order = [SELECT Id, TotalAmount, CurrencyIsoCode, HasPricingProcessed__c, IsSyncPrice__c FROM Order WHERE Id =: recordId];
            
            Map<String, List<PricingDetailWrapper>> details = (Map<String, List<PricingDetailWrapper>>) JSON.deserialize(detailsJSON, Map<String, List<PricingDetailWrapper>>.class);
            
            Boolean hasSpecial = false;
            List<OrderPricingSelected__c> psList = new List<OrderPricingSelected__c>();
            if(details.containsKey('Special')) { // 특별공급
                List<PricingDetailWrapper> special = details.get('Special');
                if(!special.isEmpty()) {
                    OrderPricingSelected__c pricing = new OrderPricingSelected__c();
                    pricing.Order__c         = recordId;
                    pricing.Key__c           = specialConvertMap.get(special[0].key);
                    pricing.Amount__c        = special[0].price;
                    pricing.SpecialAmount__c = special[0].sPrice;
                    pricing.Rate__c          = special[0].rate;
                    pricing.IsAuto__c        = special[0].isAuto;
                    pricing.CurrencyIsoCode  = order.CurrencyIsoCode;
                    pricing.Type__c          = 'Special';
                    psList.add(pricing);

                    hasSpecial = true;
                }
            }
            
            if(details.containsKey('Promotion')) { // 프로모션
                List<PricingDetailWrapper> promotion = details.get('Promotion');
                if(!promotion.isEmpty()) {
                    for(PricingDetailWrapper wrap : promotion) {
                        OrderPricingSelected__c pricing = new OrderPricingSelected__c();
                        pricing.Order__c        = recordId;
                        pricing.Key__c          = wrap.key;
                        pricing.Amount__c       = wrap.price;
                        pricing.Rate__c         = wrap.rate;
                        pricing.IsAuto__c       = wrap.isAuto;
                        pricing.CurrencyIsoCode = order.CurrencyIsoCode;
                        pricing.Type__c         = 'Promotion';
                        psList.add(pricing);
                    }
                }
            }

            if(details.containsKey('Incentive')) { // 인센티브 
                List<PricingDetailWrapper> incentive = details.get('Incentive');
                if(!incentive.isEmpty()) {
                    for(PricingDetailWrapper wrap : incentive) {
                        OrderPricingSelected__c pricing = new OrderPricingSelected__c();
                        pricing.Order__c        = recordId;
                        pricing.Key__c          = wrap.key;
                        pricing.Amount__c       = wrap.price;
                        pricing.Rate__c         = wrap.rate;
                        pricing.IsAuto__c       = wrap.isAuto;
                        pricing.CurrencyIsoCode = order.CurrencyIsoCode;
                        pricing.Title__c        = wrap.title;
                        pricing.Type__c         = 'Incentive';
                        psList.add(pricing);
                    }
                }
            }

            if(!psList.isEmpty()) { insert psList; }

            // order update
            order.DCAmount__c = finalOrderPrice;
            order.HasPricingProcessed__c = true;
            order.IF_FreePass__c = true;
            order.HasSpecialDC__c = hasSpecial ? 'Y' : 'N';
            update order;

            if(hasSpecial) {
                OrderItem prodItem = [SELECT Id, AdjustmentPrice__c FROM OrderItem WHERE OrderId =: order.Id AND ItemCategory__c =: ordSvc.ITEM_PRODUCT];
                prodItem.AdjustmentPrice__c = specialDC;
                prodItem.IF_FreePass__c = true;
                update prodItem;
            }

            List<PaymentSchedule__c> paymentSchedules = [SELECT Id, DraftCheck__c, DraftNo__c, DraftNoText__c FROM PaymentSchedule__c WHERE Order__c =: recordId];
            if(!paymentSchedules.isEmpty()) {
                PaymentSchedule__c paymentSchedule = paymentSchedules[0];
                paymentSchedule.DraftCheck__c      = 'NotRequested';
                paymentSchedule.DraftNo__c         = null;
                paymentSchedule.DraftNoText__c     = null;
                update paymentSchedule;
            }
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('savePricing : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 가격정보 초기화 (Quote에서 적재한 T_COND_ELMT__c 기반)
    **/
    @AuraEnabled
    public static Map<String, Object> syncPrice(String orderId, String quoteLineItemId){
        Map<String, Object> result = new Map<String, Object>();
        try {
            String qItemId = quoteLineItemId;

            OrderItem oItem = [
                SELECT  Id, QuoteLineItemId, UnitPrice, StandardPrice__c, DealerPrice__c
                FROM    OrderItem
                WHERE   ItemCategory__c =: ordSvc.ITEM_PRODUCT
                AND     OrderId =: orderId
            ];

            if(String.isBlank(qItemId)) {
                qItemId = oItem.QuoteLineItemId;
            }

            Order order = [
                SELECT  Id, OrderSegmentation__c, PaymentTerms__c
                        , SalesRep__c, SalesRep__r.DealerGrade__c
                FROM    Order
                WHERE   Id =: orderId
            ];

            String oSeg  = order.OrderSegmentation__c;
            String kschl = oSeg == ordSvc.SEG_CONSIGNMENT ? 'ZPR9' : oSeg == ordSvc.SEG_WHOLESALE ? 'ZPR8' : 'ZPR7';

            List<T_COND_ELMT__c> priceTable = [
                SELECT  Id
                        , KSCHL__c   // ZPR7, ZPR8, ZPR9
                        , ZZKVGR4__c // grade
                        , ZTERM__c   // payment terms
                        , KBETR__c   // price
                FROM    T_COND_ELMT__c
                WHERE   Quote_Line_Item__c =:qItemId
                AND     KSCHL__c  =: kschl
                AND     VKORG__c  = '1800'
                AND     (KSCHL__c = 'ZPR7' OR (KSCHL__c <> null AND VTWEG__c = '10'))
                // AND     WAERK__c  = 'KRW'
                ORDER BY KSCHL__c
            ];

            String dealerGrade  = order.SalesRep__r.DealerGrade__c;
            Decimal dealerPrice = 0;

            if(!priceTable.isEmpty()) {
                for(T_COND_ELMT__c table : priceTable) {
                    if((oSeg == ordSvc.SEG_CONSIGNMENT && table.ZZKVGR4__c == dealerGrade) // ZPR9 : grade가 일치하면 사용
                        || (oSeg == ordSvc.SEG_WHOLESALE && table.ZZKVGR4__c == dealerGrade && order.PaymentTerms__c == table.ZTERM__c) // ZPR8 : grade와 payment terms가 일치하면 사용
                        || (oSeg == ordSvc.SEG_DIRECTSALES) // ZPR7 : 있으면 사용
                    ) { 
                        dealerPrice = Decimal.valueOf(table.KBETR__c);
                    } 
                }
            }

            if(dealerPrice == 0) {
                oItem.DealerPrice__c = oItem.StandardPrice__c;
            } else {
                oItem.DealerPrice__c = dealerPrice;
            }
            oItem.IF_FreePass__c = true;
            update oItem;

            order.IsSyncPrice__c = true;
            order.IF_FreePass__c = true;
            update order;

            result.put('isPass', true);
            return result;
            
        } catch (Exception e) {
            System.debug('syncPrice : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

}