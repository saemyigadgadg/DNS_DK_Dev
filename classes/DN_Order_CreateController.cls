/**
 * @related           : [DN_Order_Create]
 * @description       : 견적에서 주문 생성
 * @author            : SeJin, Kwon
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-06-25   SeJin, Kwon   Initial Version
 * 1.1   2025-03-24   yeongju.yun   EDIT01. 중복 기준 추가. 글로벌 : RDD, Warranty, DC, Adjustment / 국내 : RDD
 * 1.2   2025-05-07   yeongju.yun   EDIT02. Port__c추가
 * 1.3   2025-05-27   yeongju.yun   EDIT03. IsPilot__c추가
**/
public with sharing class DN_Order_CreateController{
    
    public static DN_OrderService ordSvc = new DN_OrderService();

    /**
    * @description 주문 생성 시 Validate & 초기값 셋팅
    * @author yeongju.yun | 2024-10-18
    * @param quoteId 
    * @param selItemIds 
    * @return Map<String, Object> 
        System.debug('doInit : ' + DN_Order_CreateController.doInit('0Q0F7000000PbxDKAS'));
    **/
    @AuraEnabled
    public static ResultWrapper fetchInit(String quoteId, List<String> selItemIds){
        ResultWrapper result = new ResultWrapper();
        try {

            // check sq stage
            List<SQ_QuoteLineitem_Junction__c> sqItems = [
                SELECT  FM_SQ_Stage__c 
                FROM    SQ_QuoteLineitem_Junction__c 
                WHERE   QuoteLineItem__c =: selItemIds
                AND     (FM_SQ_Stage__c <> 'Final Confirm' AND FM_SQ_Stage__c <> 'Drop')
                AND     SQ__r.IsDelete__c = false
            ];

            if(!sqItems.isEmpty()) {
                result.isPass   = false;
                result.errorMsg = System.Label.DNS_M_SQRegCompleted; // SQ registration must be completed.
                return result;
            }
            
            // check / sysnc erp price
            List<QuoteLineItem> qItems = [SELECT Id, QuotePriceIF__c FROM QuoteLineItem WHERE Id =: selItemIds AND QuotePriceIF__c = false];
            if(!qItems.isEmpty()) {
                result.isPass   = false;
                result.errorMsg = System.Label.DNS_M_QuotePricingBtnPress; // Please use the Quote Price button to update the pricing information.
                return result;
            }

            String accountType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
            Quote quote = [SELECT Id, Account.RecordTypeId FROM Quote WHERE Id =: quoteId];
            if(quote.Account.RecordTypeId == accountType) {
                result.isPass   = false;
                result.errorMsg = System.Label.DNS_M_OptyAccountTradeCustomer; 
                // The Opportunity's Account is not a Trade Customer. Please convert it to a Trade Customer before proceeding with the order.
                return result;
            }

            Map<String, Object> defaultValues = getDefalutValues(quoteId);
            result.data.put('defaultValues', defaultValues);

            List<ProductWrapper> quoteLineItemInfo = getQuoteLineItemInfo(selItemIds, String.valueOf(defaultValues.get('salesChannel')));
            result.data.put('quoteLineItemInfo', quoteLineItemInfo);

            return result;
        } catch (Exception e) {
            System.debug('doInit : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 고객사의 주소 조회
    * @author yeongju.yun | 2024-10-17 
    * @param accountIds 
    * @return List<Account> 
    **/
    @AuraEnabled
    public static List<Account> getAccountAddress(List<String> accountIds){
        try {
            List<Account> accList = [
                SELECT  Id, ShippingAddress
                FROM    Account 
                WHERE   Id =: accountIds
            ];
            return accList;
            
        } catch (Exception e) {
            System.debug('getAccountAddress : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    /**
    * @description Insert Order, OrderItem(QuoteLineItem, SQ) and Update QuoteLineItem
    * @author yeongju.yun | 2024-10-22 
    * @param orderInfo 
    * @param itemInfo 
    **/
    @AuraEnabled
    public static void saveOrders(Order orderInfo, List<ProductWrapper> itemInfo){
        Savepoint sp = Database.setSavepoint();
        try {
            Id dnsRecordTypeId = SObjectType.Order.getRecordTypeInfosByDeveloperName().get(ordSvc.ORDER_TYPE_DNS).getRecordTypeId();

            List<PriceBookEntry> entryList = [SELECT Id, Pricebook2Id FROM PriceBookEntry WHERE Product2Id =: itemInfo[0].productId AND CurrencyIsoCode =:orderInfo.CurrencyIsoCode];

            orderInfo.Pricebook2Id           = entryList[0].Pricebook2Id;
            orderInfo.IsStrategicMaterial__c = itemInfo[0].isStrategic;
            orderInfo.Status                 = ordSvc.ORDER_CREATE;
            orderInfo.RecordTypeId           = dnsRecordTypeId;
            orderInfo.EffectiveDate          = Date.today();

            if(orderInfo.SalesChannelType__c == ordSvc.CHANNER_OVERSEAS) {
                orderInfo.Status            = ordSvc.ORDER_PROGRESS;
                orderInfo.ApprovalStatus__c = ordSvc.APPROVAL_CONFIRMREQUESTED;
            }

            // get SQ
            Set<String> quoteLineitemIdSet = new Set<String>();
            Set<Id> productIds = new Set<Id>();
            for(ProductWrapper wrap : itemInfo) {
                quoteLineitemIdSet.add(wrap.quoteItemId);
                productIds.add(wrap.productId);
            }

            // Order Category(Type) HE 여부
            List<Product2> prodList = [SELECT Id, HEIndicator__c FROM Product2 WHERE Id =:productIds];
            Set<Id> heProdIds = new Set<Id>();
            for(Product2 prod : prodList) {
                if(prod.HEIndicator__c) {heProdIds.add(prod.Id); }
            }

            List<SQ_QuoteLineitem_Junction__c> sqJunctionList = [
                SELECT  Id, QuoteLineItem__c, POSNR__c, SalesPrice__c
                        , SQ__c, SQ__r.Name, SQ__r.Category__c, SQ__r.Price__c
                FROM    SQ_QuoteLineitem_Junction__c 
                WHERE   SQ__r.isQuote__c = TRUE
                AND     QuoteLineItem__c =: quoteLineitemIdSet 
                AND     FM_SQ_Stage__c = 'Final Confirm'
                AND     UPDATEFLAG__c = null
                AND     SQ__r.IsDelete__c = false
            ];

            Map<Id, List<SQ_QuoteLineitem_Junction__c>> itemSQMap = new Map<Id, List<SQ_QuoteLineitem_Junction__c>>(); // key : quote line item id, value : sq list
            for(SQ_QuoteLineitem_Junction__c sq : sqJunctionList) {
                if(itemSQMap.containsKey(sq.QuoteLineItem__c)) {
                    List<SQ_QuoteLineitem_Junction__c> innerList = itemSQMap.get(sq.QuoteLineItem__c);
                    innerList.add(sq);
                    itemSQMap.put(sq.QuoteLineItem__c, innerList);
                } else {
                    itemSQMap.put(sq.QuoteLineItem__c, new List<SQ_QuoteLineitem_Junction__c>{sq});
                }
            }

            // get Accessories
            List<Accessory__c> accList = [
                SELECT  Id, Name, QuoteLineItem__c, Key__c, Description__c, Quantity__c, Price__c
                        , Category__c, POSNR__c, SalesUnit__c 
                FROM    Accessory__c 
                WHERE   QuoteLineItem__c =: quoteLineitemIdSet
                AND     Delete__c = null
            ];

            Map<Id, List<Accessory__c>> itemAccMap = new Map<Id, List<Accessory__c>>(); // key : quote line item id, value : accessory list
            for(Accessory__c acc : accList) {
                if(itemAccMap.containsKey(acc.QuoteLineItem__c)) {
                    List<Accessory__c> innerAccList = itemAccMap.get(acc.QuoteLineItem__c);
                    innerAccList.add(acc);
                    itemAccMap.put(acc.QuoteLineItem__c, innerAccList);
                } else {
                    itemAccMap.put(acc.QuoteLineItem__c, new List<Accessory__c>{acc});
                }
            }

            // create order
            Integer orderCnt = itemInfo.size();
            List<Order> toCreateOrder = new List<Order>();
            for(Integer i = 0; i < orderCnt; i++) {
                toCreateOrder.add(orderInfo.clone());
            }
            insert toCreateOrder;

            // get price from T_COND_ELMT__c table
            String oSeg          = orderInfo.OrderSegmentation__c;
            String kschl         = oSeg == ordSvc.SEG_CONSIGNMENT ? 'ZPR9' : oSeg == ordSvc.SEG_WHOLESALE ? 'ZPR8' : 'ZPR7';
            String targetQItemId = itemInfo[0].quoteItemId;
            String dealerGrade   = [SELECT DealerGrade__c FROM Account WHERE Id =: orderInfo.SalesRep__c]?.DealerGrade__c;
            Boolean isDomestic   = ordSvc.CHANNER_DOMESTIC_SET.contains(orderInfo.SalesChannelType__c);
            
            List<T_COND_ELMT__c> priceTable = [
                SELECT  Id
                        , KSCHL__c   // ZPR7, ZPR8, ZPR9
                        , ZZKVGR4__c // grade
                        , ZTERM__c   // payment terms
                        , KBETR__c   // price
                FROM    T_COND_ELMT__c
                WHERE   Quote_Line_Item__c =: targetQItemId
                AND     KSCHL__c  =: kschl
                AND     VKORG__c  = '1800'
                AND     (KSCHL__c = 'ZPR7' OR (KSCHL__c <> null AND VTWEG__c = '10'))
                AND     WAERK__c  = 'KRW'
                ORDER BY KSCHL__c
            ];

            Decimal dealerPrice = 0;
            if(!priceTable.isEmpty()) {
                for(T_COND_ELMT__c table : priceTable) {
                    if((oSeg == ordSvc.SEG_CONSIGNMENT && table.ZZKVGR4__c == dealerGrade) // ZPR9 : grade가 일치하면 사용
                        || (oSeg == ordSvc.SEG_WHOLESALE && table.ZZKVGR4__c == dealerGrade && orderInfo.PaymentTerms__c == table.ZTERM__c) // ZPR8 : grade와 payment terms가 일치하면 사용
                        || (oSeg == ordSvc.SEG_DIRECTSALES) // ZPR7 : 있으면 사용
                    ) { 
                        dealerPrice = Decimal.valueOf(table.KBETR__c);
                    } 
                }
            }

            // create order item and update quote item
            List<OrderItem>     toCreateItem  = new List<OrderItem>();
            List<QuoteLineItem> toUpdateItem  = new List<QuoteLineItem>();
            List<Order>         toUpdateOrder = new List<Order>();
            for(Integer i = 0; i < orderCnt; i++) {

                ProductWrapper thisProduct = itemInfo[i];
                Decimal basePrice = thisProduct.quoteItemPrice ?? 0;

                Order thisOrder = toCreateOrder[i];

                thisOrder.ProductPrice__c   = basePrice;
                thisOrder.CVTotal__c        = thisProduct.cvTotal ?? 0;
                thisOrder.SQTotal__c        = thisProduct.sqTotal ?? 0;
                thisOrder.AccessoryTotal__c = thisProduct.accTotal ?? 0;

                thisOrder.DCPercent__c = thisProduct.dcPrecent ?? 0;
                thisOrder.DCPrice__c   = thisProduct.dcPrice ?? 0;

                thisOrder.Warranty__c      = thisProduct.warranty;
                thisOrder.WarrantyPrice__c = thisProduct.warrantyPrice ?? 0;
                thisOrder.QuotePrice__c    = thisProduct.quoteFPrice ?? 0;
                
                thisOrder.OpportunityProduct__c = thisProduct.optyItemId;

                Id qLineItemId = thisProduct.quoteItemId;

                OrderItem orderItem = new OrderItem();
                orderItem.Quantity  = 1;

                if(isDomestic) { 
                    orderItem.UnitPrice        = basePrice;
                    orderItem.StandardPrice__c = basePrice; 
                    orderItem.DealerPrice__c   = dealerPrice == 0 ? basePrice : dealerPrice;
                } else {
                    Decimal adjPrice = thisProduct.quoteAdPrice ?? 0;
                    orderItem.AdjustmentPrice__c = adjPrice.setScale(2, System.RoundingMode.HALF_UP);
                    orderItem.DealerPrice__c     = basePrice; // = zsum - warranty
                    orderItem.UnitPrice          = orderItem.DealerPrice__c + orderItem.AdjustmentPrice__c;
                }
                orderItem.ItemCategory__c    = ordSvc.ITEM_PRODUCT;
                orderItem.IF_POSNR__c        = ordSvc.formatCodeForSAP(6, '10');
                orderItem.Unit__c            = 'EA';
                
                orderItem.OrderId            = thisOrder.Id;
                orderItem.QuoteLineItemId    = qLineItemId;
                orderItem.Product2Id         = Id.valueOf(thisProduct.productId);
                orderItem.PricebookEntryId   = entryList[0].Id;
                toCreateItem.add(orderItem);

                if(heProdIds.contains(orderItem.Product2Id)) { thisOrder.Type = 'HE'; }
                toUpdateOrder.add(thisOrder);

                QuoteLineItem quoteItem = new QuoteLineItem();
                quoteItem.Id            = qLineItemId;
                quoteItem.Order__c      = orderItem.OrderId;
                toUpdateItem.add(quoteItem);

                if(itemSQMap.containsKey(qLineItemId)) {
                    for(SQ_QuoteLineitem_Junction__c sq : itemSQMap.get(qLineItemId)) {
                        OrderItem sqItem        = new OrderItem();
                        sqItem.Quantity         = 1;
                        if(isDomestic) {
                            sqItem.UnitPrice = sq.SQ__r.Price__c ?? 0;
                        } else {
                            sqItem.UnitPrice = sq.SalesPrice__c ?? 0;
                        }
                        sqItem.StandardPrice__c = sq.SQ__r.Price__c ?? 0;
                        sqItem.ItemCategory__c  = ordSvc.ITEM_SQ;
                        sqItem.IF_POSNR__c      = ordSvc.formatCodeForSAP(6, String.valueOf(sq.POSNR__c));
                        
                        sqItem.SQ__c            = sq.SQ__r.Id;
                        sqItem.IsInspection__c  = sq.SQ__r.Category__c == '입회검사';
                        sqItem.SQTitle__c       = sq.SQ__r.Name;
                        sqItem.Unit__c          = 'SET';
                        
                        sqItem.OrderId          = orderItem.OrderId;
                        sqItem.QuoteLineItemId  = orderItem.QuoteLineItemId;
                        sqItem.Product2Id       = orderItem.Product2Id;
                        sqItem.PricebookEntryId = orderItem.PricebookEntryId;
                        toCreateItem.add(sqItem);
                    }
                }
                if(itemAccMap.containsKey(qLineItemId)) {

                    for(Accessory__c acc : itemAccMap.get(qLineItemId)) {
                        OrderItem accItem        = new OrderItem();
                        accItem.Quantity         = acc.Quantity__c ?? 0;
                        accItem.UnitPrice        = acc.Price__c ?? 0;
                        if(isDomestic) { accItem.StandardPrice__c = acc.Price__c ?? 0; }
                        accItem.ItemCategory__c  = ordSvc.ITEM_ACCESSORY;
                        accItem.IF_POSNR__c      = ordSvc.formatCodeForSAP(6, String.valueOf(acc.POSNR__c));
                        
                        accItem.Accessory__c         = acc.Id;
                        accItem.AccessoryCategory__c = acc.Category__c;
                        accItem.AccessoryCode__c     = acc.Name;
                        accItem.AccessoryName__c     = acc.Description__c;
                        accItem.Unit__c              = acc.SalesUnit__c;

                        accItem.OrderId          = orderItem.OrderId;
                        accItem.QuoteLineItemId  = orderItem.QuoteLineItemId;
                        accItem.Product2Id       = orderItem.Product2Id;
                        accItem.PricebookEntryId = orderItem.PricebookEntryId;
                        toCreateItem.add(accItem);
                    }
                }
            }

            if(!toUpdateOrder.isEmpty()) { update toUpdateOrder; }
            if(!toUpdateItem.isEmpty()) { update toUpdateItem; }
            if(!toCreateItem.isEmpty()) { 
                insert toCreateItem; 

                List<CharacteristicValue__c> cvList = [SELECT Id, QuoteLineItem__c, Price__c FROM CharacteristicValue__c  WHERE QuoteLineItem__c =:quoteLineitemIdSet];

                if(!cvList.isEmpty()) {

                    List<CVOrderItem__c> cvJunctions = new List<CVOrderItem__c>();
                    List<OrderItem> toUpdateOrderItems = new List<OrderItem>();
                    for(OrderItem item : toCreateItem) {
                        if(item.ItemCategory__c != ordSvc.ITEM_PRODUCT) continue;

                        Decimal cvSum = 0;
                        for(CharacteristicValue__c cv : cvList) {
                            if(item.QuoteLineItemId == cv.QuoteLineItem__c) {
                                CVOrderItem__c junc         = new CVOrderItem__c();
                                junc.OrderProduct__c        = item.Id;
                                junc.CharacteristicValue__c = cv.Id;
                                cvJunctions.add(junc);

                                cvSum += cv.Price__c ?? 0;
                            }
                        }
                        item.CVSummary__c   = cvSum;
                        item.UnitPrice     += cvSum;
                        item.IF_FreePass__c = true;
                        toUpdateOrderItems.add(item);
                    }

                    if(!cvJunctions.isEmpty()) { insert cvJunctions; }
                    if(!toUpdateOrderItems.isEmpty()) {update toUpdateOrderItems; }

                }
            }
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('saveOrders : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description SalesOrganization__c, Division__c, DistributionChannel__c가 일치하는 Sales area data 기준
                    Incoterms__c, TermsOfPayment__c 가져오기
    * @author yeongju.yun | 2024-10-28 
    * @return SalesAreaData__c 
    **/
    @AuraEnabled
    public static SalesAreaData__c getSalesAreaData(String accountId){
        try {

            Set<String> orgSet = new Set<String>();
            Set<String> divSet = new Set<String>();
            Set<String> dcSet = new Set<String>();

            Account acc = [
                SELECT  Id, Name, SalesOrganization__c, Division__c, DistributionChannel__c
                FROM    Account
                WHERE   Id =: accountId
            ];

            User u = [
                SELECT  Id, Name, SalesOrganization__c, Division__c, DistributionChannel__c
                FROM    User
                WHERE   Id =: UserInfo.getUserId()
            ];

            orgSet.add(acc.SalesOrganization__c);
            orgSet.add(u.SalesOrganization__c);
            
            divSet.add(acc.Division__c);
            divSet.add(u.Division__c);

            dcSet.add(acc.DistributionChannel__c);
            dcSet.add(u.DistributionChannel__c);

            List<SalesAreaData__c> dataList = [
                SELECT  Incoterms__c, TermsOfPayment__c, SalesOrganization__c, Division__c, DistributionChannel__c
                FROM    SalesAreaData__c
                WHERE   SalesOrganization__c =: orgSet
                AND     Division__c =: divSet
                AND     DistributionChannel__c =: dcSet
                AND     Account__c = :accountId
            ];

            String accKey  = acc.SalesOrganization__c + acc.Division__c + acc.DistributionChannel__c;
            String userKey = u.SalesOrganization__c + u.Division__c + u.DistributionChannel__c;
            SalesAreaData__c result;
            for(SalesAreaData__c sa : dataList) {
                String key = sa.SalesOrganization__c + sa.Division__c + sa.DistributionChannel__c;
                if(key == accKey) { 
                    result = sa;
                    break;
                 } else if(key == userKey) {
                    result = sa;
                 }
            }

            return result;
            
        } catch (Exception e) {
            System.debug('getAccountInfo : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }










    /**
    * @description Order의 기본값 설정
                   EDIT02. Port__c추가
    * @author yeongju.yun | 2024-10-16 
    * @param quoteId 
    * @return Map<String, Object> 
        System.debug('getDefalutValues : ' + DN_Order_CreateController.getDefalutValues('0Q0F7000000PbxDKAS'));
    **/
    public static Map<String, Object> getDefalutValues(String quoteId){
        Map<String, Object> result = new Map<String, Object>();
        
        Quote q = [
            SELECT  Id, Account.IsBlocked__c, IsFinal__c, CurrencyIsoCode
                    , OpportunityId, Opportunity.AccountId, Opportunity.MainCategory__c, Opportunity.SubCategory__c, Opportunity.IsTooling__c
                    , Opportunity.Country__c, Opportunity.StageName
                    , Port__c
            FROM    Quote 
            WHERE   Id =:QuoteId
        ];
        result.put('QuoteId',       q.Id);
        result.put('OpportunityId', q.OpportunityId);
        result.put('isOptyClosed',  q.Opportunity.StageName == 'Closed Won');
        result.put('quotePort',     q.Port__c);
        
        result.put('isFinal', q.IsFinal__c);
        result.put('isAccBlocked', q.Account.IsBlocked__c); // SLS-ORD-003

        result.put('optyAccount', q.Opportunity.AccountId); // SLS-ORD-026
        result.put('isUser', ordSvc.IS_USER);
        result.put('currCode', q.CurrencyIsoCode);

        result.put('categoryLv1', q.Opportunity.MainCategory__c);
        result.put('categoryLv2', q.Opportunity.SubCategory__c);
        result.put('categoryLv3', q.Opportunity.IsTooling__c);

        // SLS-ORD-034 Quote의 Account에 연결된 'Related Dealer'가 하나일 때만 주문 생성 가능
        Integer accCnt  = Database.countQuery('SELECT Count() FROM DNS_CustomerDealerAssociation__c WHERE Customer__c = \'' + q.Opportunity.AccountId + '\'');
        Integer teamCnt = Database.countQuery('SELECT Count() FROM AccountTeamMember WHERE AccountId = \'' + q.Opportunity.AccountId + '\'');
        result.put('connectedAccCnt', accCnt + teamCnt);

        User u = [
            SELECT  Id, SalesOffice__c, SalesOrganization__c, DistributionChannel__c, Division__c, SalesDistrict__c, AccountId, ContactId 
            FROM    User 
            WHERE   Id = :UserInfo.getUserId()
        ];

        DN_OrderService.ChannerWrapper cWrap = new DN_OrderService.ChannerWrapper(UserInfo.getUserId(), false);

        String salesChannelType = ordSvc.setSalesChannel(cWrap);
        result.put('salesChannel', salesChannelType);

        if(ordSvc.CHANNER_DOMESTIC_SET.contains(salesChannelType)) { result.put('country', 'KR'); }
        else { result.put('country', q.Opportunity.Country__c); }

        Boolean isGlobal = salesChannelType == ordSvc.CHANNER_OVERSEAS;
        result.put('isGlobal', isGlobal);

        if(ordSvc.IS_USER && !isGlobal) {
            List<Account> accList = [
                SELECT  Id
                FROM    Account 
                WHERE   IsDNSDirectAccount__c = true
                AND     SalesOffice__c = : u.SalesOffice__c
                AND     SalesOrganization__c =: u.SalesOrganization__c 
            ];

            if(!accList.isEmpty()) { result.put('dnsAccount', accList[0].Id); }

        } else if(!ordSvc.IS_USER){
            result.put('dealerAccount', u.AccountId);
        }

        List<DN_OrderService.OptionWrapper> optionsForSeg = ordSvc.getPicklistWrap('Order', 'OrderSegmentation__c');
        result.put('optionsForSeg', optionsForSeg);

        return result;
    }

    /**
    * @description 주문의 베이스 견적의 제품 정보 조회
    * @author SeJin, Kwon | 2024-06-25 
    * @param quoteId 
    * @return List<ProductWrapper>
    **/
    public static List<ProductWrapper> getQuoteLineItemInfo(List<String> selItemIds, String salesChannel){
        List<QuoteLineItem> quoteLineList = [
            SELECT  Id
                    , OpportunityLineItemId
                    , Product2Id
                    , Product2.Name
                    , Product2.Name__c
                    , Product2.IsPilot__c
                    , Product2.IsStrategicMaterial__c

                    , UnitPrice
                    , CV_Total__c
                    , SQ_Total__c
                    , Accessory_Total__c
                    
                    , DC__c
                    , DC_Price__c

                    , Dealer_Price__c
                    , Adjustment_Price__c
                    , Warranty__c
                    , Warranty_Price__c
                    , Final_Quotation_Price__c

                    , RequestedDelivDate__c
                    , ExpectedDelivDate__c 

                    , (SELECT SQ__c FROM SQ_QuoteLineitem_Junction__r ORDER BY SQ__c)
                    , (SELECT C_Code__c, V_Code__c FROM CharacteristicValue__r ORDER BY C_Code__c, V_Code__c)
                    , (SELECT Name FROM Accessories__r ORDER BY Name)
            FROM    QuoteLineItem 
            WHERE   Id =:selItemIds
            AND     Order__c = null // 기존에 생성 했던 QuoteItem의 경우 중복 생성 불가
            AND     (Product2.IsPilot__c = TRUE OR CVComplete__c = TRUE) // CV Complete 필드 값이 True일 때만 주문 생성 가능
            ORDER BY CreatedDate
        ]; // EDIT03. IsPilot__c추가
        
        List<ProductWrapper> prodWrapList = new List<ProductWrapper>();
        for(QuoteLineItem item : quoteLineList) {
            ProductWrapper prodWrap = new ProductWrapper(item);

            // EDIT01. 중복 기준 추가. 글로벌 : RDD, Warranty, DC, Adjustment / 국내 : RDD
            prodWrap.key = 'prod_' + prodWrap.productId + '_sq_' + prodWrap.sq + '_cv_' + prodWrap.cv + '_acc_' + prodWrap.acc;
            if(salesChannel == ordSvc.CHANNER_OVERSEAS) {
                prodWrap.key += '_RDD_' + prodWrap.quoteRDD + '_Warr_' + prodWrap.warranty + '_dc_' + prodWrap.dcPrice + '_adj_' + prodWrap.quoteAdPrice;
            } else {
                prodWrap.key += '_RDD_' + item.ExpectedDelivDate__c;
            }
            System.debug('prod key : ' + prodWrap.quoteItemId + ' / ' + prodWrap.key);
            prodWrapList.add(prodWrap);
        }

        return prodWrapList;
    }

    /**
    * @description 견적 제품 Wrapper
    **/
    public class ProductWrapper{
        @AuraEnabled public String  quoteItemId    {get;set;}
        @AuraEnabled public String  optyItemId     {get;set;}
        @AuraEnabled public String  productId      {get;set;}
        @AuraEnabled public String  productName    {get;set;}
        @AuraEnabled public String  productCode    {get;set;}
        @AuraEnabled public Boolean isStrategic    {get;set;}

        @AuraEnabled public Decimal quoteItemPrice {get;set;}
        @AuraEnabled public Decimal cvTotal        {get;set;}
        @AuraEnabled public Decimal sqTotal        {get;set;}
        @AuraEnabled public Decimal accTotal       {get;set;}

        @AuraEnabled public Decimal dcPrecent      {get;set;}
        @AuraEnabled public Decimal dcPrice        {get;set;}

        @AuraEnabled public Decimal quoteDPrice    {get;set;}
        @AuraEnabled public Decimal quoteAdPrice   {get;set;}
        @AuraEnabled public String  warranty       {get;set;}
        @AuraEnabled public Decimal warrantyPrice  {get;set;}
        @AuraEnabled public Decimal quoteFPrice    {get;set;}

        @AuraEnabled public Boolean isChecked     {get;set;}
        @AuraEnabled public Boolean isDisabled    {get;set;}
        
        @AuraEnabled public Date quoteRDD {get;set;}
        
        @AuraEnabled public String  sq  {get;set;}
        @AuraEnabled public String  cv  {get;set;}
        @AuraEnabled public String  acc {get;set;}
        @AuraEnabled public String  key {get;set;}
        
        public ProductWrapper(){}
        public ProductWrapper(QuoteLineItem item){
            this.quoteItemId    = item.Id;
            this.optyItemId     = item.OpportunityLineItemId;
            this.productId      = item.Product2Id;
            this.productName    = item.Product2.Name__c;
            this.productCode    = item.Product2.Name;
            this.isStrategic    = item.Product2.IsStrategicMaterial__c;

            this.quoteItemPrice = item.UnitPrice;
            this.cvTotal        = item.CV_Total__c;
            this.sqTotal        = item.SQ_Total__c;
            this.accTotal       = item.Accessory_Total__c;
            
            this.dcPrecent      = item.DC__c;
            this.dcPrice        = item.DC_Price__c;

            this.quoteDPrice    = item.Dealer_Price__c;
            this.quoteAdPrice   = item.Adjustment_Price__c;
            this.warranty       = item.Warranty__c;
            this.warrantyPrice  = item.Warranty_Price__c;
            this.quoteFPrice    = item.Final_Quotation_Price__c;

            this.isChecked   = false;
            this.isDisabled  = false;

            this.quoteRDD = item.RequestedDelivDate__c;

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
    * @description 결과 반환 wrapper
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