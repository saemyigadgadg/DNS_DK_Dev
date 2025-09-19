/**
 * @component         : DNSA_OrderConfirmRequest
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-01-20   yeongju.yun   Initial Version
**/
public with sharing class DNSA_OrderConfirmRequestController {
    private static final Id commodityRT = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description  Order와 연결 된 Opportunity가 Closed이고, 
                    Order의 Status가 'Order Create'일 때 버튼 클릭 가능
                    (= ERP에 전송한 적 없을 때 / DNS-A 전용)
    * @author hanyeong choi | 2024-12-31
    * @param orderId
    * @return ResultWrapper
    **/
    @AuraEnabled
    public static ResultWrapper dnsaValidateOrderConfrim(String orderId){
        ResultWrapper result = new ResultWrapper();

        try {
            Order order = [SELECT Id, OrderNumber, Status, OpportunityId, Opportunity.StageName, HasPricingProcessed__c, PurchaseOrderNo__c, HasScheduleCompleted__c, Quote.RecordTypeId, IsPricing__c, OrderType__c FROM Order WHERE Id =: orderId];

            List<String> closedStatus = new List<String>{ordSvc.ORDER_CANCELED, ordSvc.ORDER_Returned};
            List<String> confirmedStatus = new List<String>{ordSvc.ORDER_CONFIRMED, ordSvc.ORDER_MAPPED};

            List<PaymentSchedule__c> psList = [SELECT Id, DraftCheck__c FROM PaymentSchedule__c WHERE Order__c =: orderId];

            List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId =: orderId];

            List<ContentDocumentLink> links = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :orderId];

            if(order.Status == ordSvc.ORDER_SUBMITTED) {
                result.isSuccess = false;
                result.errorMsg  = System.Label.DNS_M_AlreadyRequested; // This order has already been requested for confirmation.
            } else if(closedStatus.contains(order.Status)) {
                result.isSuccess = false;
                result.errorMsg  = System.Label.DNS_M_CancelRequestConfirmError; // Orders that are canceled or returned cannot request confirm.
            } else if(confirmedStatus.contains(order.Status)) {
                result.isSuccess = false;
                result.errorMsg  = System.Label.DNS_M_AlreadyConfirmed; // This order has already been confirmed.
            } else if(orderItems.isEmpty()) {
                result.isSuccess = false;
                result.errorMsg  = 'No order products found. Please add products first.';
            } else if(String.isBlank(order.PurchaseOrderNo__c)) {
                result.isSuccess = false;
                result.errorMsg  = 'Purchase Order# is required.';
            } else if(order.Quote.RecordTypeId == commodityRT && !order.IsPricing__c && order.OrderType__c != 'ZUSO') {
                result.isSuccess = false;
                result.errorMsg  = 'Please apply pricing and try it out.';
            } else if(links.isEmpty() && order.Quote.RecordTypeId == commodityRT) {
                result.isSuccess = false;
                result.errorMsg  = 'Please upload relevant file.';
            } else if(order.Quote.RecordTypeId == commodityRT && order.Status != ordSvc.ORDER_APPROVED && order.OrderType__c != 'ZUSO') {
                result.isSuccess = false;
                result.errorMsg  = 'A Commodity Order can only be Request Confirmed when it is in Approved Status.';
            }

        } catch (Exception e) {
            System.debug('dnsaValidateOrderConfrim : ' + e.getLineNumber() + ' / ' + e.getMessage());
            result.isSuccess  = false;
            result.errorMsg = e.getMessage();
        }
        return result;
    }

    /**
    * @description 주문 승인 요청, 주문의 데이터 ERP 전송, 주문의 타입에 따라 호출 I/F 상이함
    **/
    @AuraEnabled
    public static ResultWrapper requestConfirm(String orderId){
        Order ord = [
            SELECT  Id
                    , Name
                    , QuoteId
                    , Quote.RecordTypeId
                    , Quote.Waiting_Seq__c
                    , Quote.TotalPrice__c
                    , RequestedShipDate__c
                    , OrderType__c
                    , DNSA_SalesOffice__c
                    , SoldTo__r.CustomerCode__c
                    , SoldTo__r.Name
                    , ShipTo__r.CustomerCode__c
                    , ShipTo__r.Name
                    , ShipTo__r.CountryLookup__r.CountryCode__c
                    , PurchaseOrderNo__c
                    , Owner__r.Account.CustomerCode__c
                    , Owner__r.SalesDistrict__c
                    , Owner__r.CustomerCode__c
                    , Owner__r.Account.MainCategory__c
                    , Owner__r.Account.SubCategory__c
                    , Owner__r.Account.IsTooling__c
                    , OrderNotes__c
                    , ShippingInstructions__c
                    , PaymentTerms_DNSA__c
                    , PUBldgConstruction__c
                    , PUNewFoundation__c
                    , PUAccessoryDelivery__c
                    , PUFinancialApproval__c
                    , PUContractApproval__c
                    , PUExportLicense__c
                    , PromotionalPackage__c
                    , Other__c
                    , MachinePartsWarranty__c
                    , FOBPoint__c
                    , ServiceReimbursement__c
                    , OtherDiscount__c
                    , ProfitMarginSubsidyPlan__c
                    , DiscountfromSalesAvailabilityList__c
                    , ServiceReimbursementPrice__c
                    , ExtWarranty__c
                    , R_AdjustmentPrice__c

                    , OrderNumber
            FROM Order 
            WHERE Id = :orderId 
            LIMIT 1
        ];

        List<OrderItem> oliList = [
            SELECT  Id
                    , StockResSO__c
                    , UnitPrice
                    , IF_FreePass__c

                    , TotalPrice
                    , ItemCategory__c
            FROM OrderItem 
            WHERE OrderId = :orderId 
            AND Accessory__c = null 
            LIMIT 1
        ];

        List<OrderItem> accList = [
            SELECT  Id
                    , StockResSO__c
                    , UnitPrice
                    , IF_FreePass__c
                    , TotalPrice
                    , ItemCategory__c
                    , Accessory__c
                    , Accessory__r.Name
                    , Quantity
            FROM OrderItem 
            WHERE OrderId = :orderId 
            AND Accessory__c != null
        ];

        if(ord.Quote.RecordTypeId == commodityRT && ord.OrderType__c != 'ZUSO') {
            IF_ERP_Order_Classes.IF_ORDER_006_Res response = callOrderCreationIF006(ord, oliList);
    
            SavePoint sp = Database.setSavePoint();
            ResultWrapper result = new ResultWrapper();
    
            try {
                if(response.E_VBELN == '') {
                    AuraHandledException e = new AuraHandledException('error');
                    e.setMessage(response.O_RETURN.MESSAGE != '' ? response.O_RETURN.MESSAGE : 'ERP Error.');
                    throw e;
                } 
    
                Order newOrder          = new Order();
                newOrder.Id             = orderId;
                newOrder.Status         = ordSvc.ORDER_SUBMITTED;
                newOrder.ERPRSONo__c    = response.E_VBELN;
                newOrder.IF_FreePass__c = true;
                update newOrder;

                if(!oliList.isEmpty()) {
                    if(oliList[0].UnitPrice != Decimal.valueOf(response.T_PRICING_RETURN[0].KWERT)) {
                        oliList[0].IF_FreePass__c = true;
                        oliList[0].UnitPrice = Decimal.valueOf(response.T_PRICING_RETURN[0].KWERT);
                        DN_WithoutSharingClass.updateOrderItems(oliList);
                    }
                }

                Quote quote = [SELECT Id, ReserveStatus__c FROM Quote WHERE Id = :ord.QuoteId LIMIT 1];
                quote.ReserveStatus__c = 'ORDERED';
                update quote;

                List<QuoteLineItem> deleteQliList = new List<QuoteLineItem>();
                Set<Id> quoteIds = new Set<Id>();
                QuoteLineItem qli = [SELECT Id, StockResSO__c FROM QuoteLineItem WHERE QuoteId = :ord.QuoteId LIMIT 1];
                List<QuoteLineItem> qliList = DN_WithoutSharingClass.queryQuoteLineItems(qli.StockResSO__c);
                for(QuoteLineItem ql : qliList) {
                    if(ql.Quote.Waiting_Seq__c != '1') {
                        deleteQliList.add(ql);
                        quoteIds.add(ql.QuoteId);
                    }
                }

                List<Quote> quoteList = DN_WithoutSharingClass.queryQuotes(quoteIds);
                if(!quoteList.isEmpty()) {
                    List<Quote> updateQuoteList = new List<Quote>();
                    for(Quote q : quoteList) {
                        q.ReserveStatus__c          = null;
                        q.Waiting_Seq__c            = null;
                        q.ReserveExpirationDate__c  = null;
                        q.PendingExpirationDate__c  = null;
                        q.Pending_Reason__c         = null;
                        q.StockResSO__c             = null;
                        updateQuoteList.add(q);
                    }
                    if(!updateQuoteList.isEmpty()) DN_WithoutSharingClass.updateQuotes(updateQuoteList);
                }

                List<OrderItem> qliUpdateList = new List<OrderItem>();
                if(!accList.isEmpty()) {
                    for(OrderItem acc : accList) {
                        for(IF_ERP_Order_Classes.IF_ORDER_006_Res_T_PRICING_RETURN res : response.T_PRICING_RETURN) {
                            if(acc.Accessory__r.Name == res.MATNR && res.KSCHL == 'ZSUM') {
                                acc.IF_POSNR__c = res.POSNR;
                                if(acc.UnitPrice != Decimal.valueOf(res.KWERT)) {
                                    if(acc.Quantity > 1) {
                                        acc.UnitPrice = Decimal.valueOf(res.KWERT) / acc.Quantity;
                                    } else {
                                        acc.UnitPrice = Decimal.valueOf(res.KWERT);
                                    }
                                }
                                acc.IF_FreePass__c = true;
                                qliUpdateList.add(acc);
                            }
                        }
                    }
                }

                if(!qliUpdateList.isEmpty()) DN_WithoutSharingClass.updateOrderItems(qliUpdateList);
                sendCreateCommodityERPOrder(ord, response.E_VBELN);
                sendAlreadyCreateCommodityERPOrder(ord, deleteQliList);
                DN_WithoutSharingClass.deleteQuoteLineItems(deleteQliList);
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug('requestConfirm : ' + e.getLineNumber() + ' / ' + e.getMessage());
                result.isSuccess = false;
                result.errorMsg  = e.getMessage();
            }
            return result;
        } else {
            IF_ERP_Order_Classes.IF_ORDER_007_Res response = callOrderCreationIF(orderId);
    
            SavePoint sp = Database.setSavePoint();
            ResultWrapper result = new ResultWrapper();
    
            try {
                if(response.O_RETURN.TYPE == 'E') {
                    System.debug('requestConfirm - response error : ' + response.O_RETURN.MESSAGE);
                    AuraHandledException e = new AuraHandledException('error');
                    e.setMessage(response.O_RETURN.MESSAGE);
                    throw e;
                } 
    
                Order order          = new Order();
                order.Id             = orderId;
                order.Status         = ordSvc.ORDER_SUBMITTED;
                order.ERPRSONo__c    = response.O_VBELN;
                order.IF_FreePass__c = true;
                update order;

                sendAlertForConfirm(ord, response.O_VBELN);
    
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug('requestConfirm : ' + e.getLineNumber() + ' / ' + e.getMessage());
                result.isSuccess = false;
                result.errorMsg  = e.getMessage();
            }
            return result;
        }
    }

    

    /**
    * @description Commodity Order를 ERP로 전송, 전송 시 승인 요청 이메일 발송
    **/
    private static void sendCreateCommodityERPOrder(Order order, String rsoNo) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiverEN = new Set<Id>();
        List<String> receiverEmailEN = new List<String>();

        List<Message_Group_Junction__c> mgJuncList = [SELECT Id, User__c, FM_UserEmail__c FROM Message_Group_Junction__c WHERE Message_Group__r.SalesOffice__c = :order.DNSA_SalesOffice__c AND Message_Group__r.Name LIKE '%Order Request%'];
        if(!mgJuncList.isEmpty()) {
            for(Message_Group_Junction__c mgj : mgJuncList) {
                receiverEN.add(mgj.User__c);
                receiverEmailEN.add(mgj.FM_UserEmail__c);
            }
        }
        
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Commodity ERP Order Alert' LIMIT 1];

        if(!am.isEmpty()) {

            List<OrderItem> itemList = [
                SELECT  Id, TotalPrice, ItemCategory__c, DealerPrice__c, UnitPrice
                FROM    OrderItem 
                WHERE   OrderId = :order.Id 
            ];

            Decimal prodPrice   = 0;
            Decimal optionTotal = 0;
            Decimal dealerPrice = 0;
            for(OrderItem item : itemList) {
                if(item.ItemCategory__c == ordSvc.ITEM_PRODUCT) {
                    prodPrice   = item.TotalPrice;
                    dealerPrice = item.DealerPrice__c;
                } else if(item.ItemCategory__c == ordSvc.ITEM_ACCESSORY) {
                    optionTotal += item.TotalPrice;
                }
            }

            Decimal totalListPrice = prodPrice + optionTotal;
            Decimal discountPrice  = dealerPrice * (order.DiscountfromSalesAvailabilityList__c / 100) * -1;

            List<String> eleList = new List<String>();
            eleList.add(order.OrderNumber);                                     // {0} CRM Order Number
            eleList.add(rsoNo);                                                 // {1} ERP Order Number
            eleList.add(order.SoldTo__r.Name ?? '');                            // {2} Sold To
            eleList.add(order.ShipTo__r.Name ?? '');                            // {3} Ship To
            eleList.add(convertToStr(prodPrice));                               // {4} Product Price
            eleList.add(convertToStr(optionTotal));                             // {5} US Option Total
            eleList.add(order.MachinePartsWarranty__c ?? '');                    // {6} Machine Warranty
            eleList.add(convertToStr(order.DiscountfromSalesAvailabilityList__c ?? 0) + '%'); // {7} Discount from Sales Availability List (%)
            eleList.add(convertToStr(discountPrice));                           // {8} Discount from Sales Availability List
            eleList.add(convertToStr(order.PromotionalPackage__c ?? 0));        // {9} Promotional Package
            eleList.add(convertToStr(order.ProfitMarginSubsidyPlan__c ?? 0));   // {10} Profit Margin Subsidy Plan
            eleList.add(convertToStr(order.OtherDiscount__c ?? 0));             // {11} Other Discount
            eleList.add(order.ServiceReimbursement__c ?? '');                   // {12} Service Reimbursement (Yes/No)
            eleList.add(convertToStr(order.ServiceReimbursementPrice__c ?? 0)); // {13} Service Reimbursement
            
            String openStr  = order.ServiceReimbursement__c == 'Y' ? '' : '<!--';
            String closeStr = order.ServiceReimbursement__c == 'Y' ? '' : '-->';

            eleList.add(openStr);  // {14}
            eleList.add(closeStr); // {15}
            
            eleList.add(convertToStr(totalListPrice)); // {16} Total List Price

            if(!receiverEmailEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType           = 'Email';
                history.elementList         = eleList;
                history.alertID             = am[0].Id;
                history.targetID            = order.Id;
                history.receiverforEmail    = receiverEmailEN;
                history.alertLanguage       = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
    * @description 승인 요청 알림 발송
    **/
    public static void sendAlertForConfirm(Order order, String rsoNo) {

        Set<Id> userIds = new Set<Id>();
        List<Message_Group_Junction__c> mgJuncList = [SELECT Id, User__c, FM_UserEmail__c FROM Message_Group_Junction__c WHERE Message_Group__r.SalesOffice__c = :order.DNSA_SalesOffice__c AND Message_Group__r.Name LIKE '%Order Request%'];
        for(Message_Group_Junction__c member : mgJuncList) {
            userIds.add(member.User__c);
        }

        if(userIds.isEmpty()) { return; }

        List<OrderItem> itemList = [
            SELECT  Id, TotalPrice, ItemCategory__c, DealerPrice__c, UnitPrice
            FROM    OrderItem 
            WHERE   OrderId = :order.Id 
        ];

        Decimal prodPrice   = 0;
        Decimal optionTotal = 0;
        for(OrderItem item : itemList) {
            if(item.ItemCategory__c == ordSvc.ITEM_PRODUCT) {
                prodPrice   = item.TotalPrice;
            } else if(item.ItemCategory__c == ordSvc.ITEM_ACCESSORY) {
                optionTotal += item.TotalPrice;
            }
        }
        
        List<String> eleList = new List<String>();
        eleList.add(order.OrderNumber);
        eleList.add(rsoNo);
        eleList.add(order.SoldTo__r.Name ?? '');
        eleList.add(order.ShipTo__r.Name ?? '');
        eleList.add(convertToStr(prodPrice));
        eleList.add(convertToStr(optionTotal));
        eleList.add(convertToStr(prodPrice + optionTotal));

        String openStr  = order.OrderType__c == 'ZUSO' ? '<!--' : '';
        String closeStr = order.OrderType__c == 'ZUSO' ? '-->'  : '';
        eleList.add(openStr);
        eleList.add(closeStr);

        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        targetUserMap.put(order.Id, userIds);

        UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
            'OrderRequestConfirmDNSA_F'
            , 'email'
            , new List<Order>{order}
            , targetUserMap
            , new Map<String, Object>{'eleList' => eleList}
        );

        if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
            System.debug('OrderRequestConfirmDNSA_F result ::: ' + emailAlertResult.errMessage);
        }
    }

    /**
    * @description Decimal > String 형변환
    **/
    private static String convertToStr(Decimal amt){
        if(amt == null) { amt = 0; }
        return amt.format();
    }

    /**
    * @description Send Already Create Commodity ERP Order 벨, 이메일 발송
    **/
    private static void sendAlreadyCreateCommodityERPOrder(Order order, List<QuoteLineItem> qlis) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> quoteIds = new Set<Id>();
        List<Quote> updateList = new List<Quote>();
        Set<Id> createdByIds = new Set<Id>();
    
        List<QuoteLineItem> qliList = [SELECT Id, StockResSO__c FROM QuoteLineItem WHERE QuoteId = :order.QuoteId];
        String stockNumber = qliList[0].StockResSO__c;
        
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Send Already Create Commodity ERP Order' LIMIT 1];
    
        if(!am.isEmpty() && !qliList.isEmpty()) {
            List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
            String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
            
            if(!qlis.isEmpty()) {
                for(QuoteLineItem qli : qlis) {
                    createdByIds.add(qli.CreatedById);
                }
                
                Map<Id, String> userMap = new Map<Id, String>();
                List<User> users = DN_WithoutSharingClass.getUserEmails(createdByIds);
                for(User u : users) {
                    userMap.put(u.Id, u.Email);
                }
    
                for(QuoteLineItem qli : qlis) {
                    UTIL_Alert.HistoryWrapper notificationHistory = new UTIL_Alert.HistoryWrapper();
                    notificationHistory.alertType = 'Notification';
                    notificationHistory.elementList.add(stockNumber);
                    notificationHistory.alertID = am[0].Id;
                    notificationHistory.targetID = qli.QuoteId;
                    notificationHistory.receiverforID = new Set<Id>{qli.CreatedById};
                    notificationHistory.alertLanguage = 'en';
                    ahwList.add(notificationHistory);
                    
                    String email = userMap.get(qli.CreatedById);
                    if(email != null && email != '') {
                        UTIL_Alert.HistoryWrapper emailHistory = new UTIL_Alert.HistoryWrapper();
                        emailHistory.alertType = 'Email';
                        emailHistory.elementList.add(stockNumber);
                        emailHistory.elementList.add(baseUrl + '/' + qli.QuoteId);
                        emailHistory.alertID = am[0].Id;
                        emailHistory.targetID = qli.QuoteId;
                        emailHistory.receiverforEmail = new List<String>{email};
                        emailHistory.alertLanguage = 'en';
                        ahwList.add(emailHistory);
                    }
                    
                    quoteIds.add(qli.QuoteId);
                }
    
                if(!quoteIds.isEmpty()) {
                    List<Quote> quoteList = [
                        SELECT Id, ReserveStatus__c, Waiting_Seq__c, ReserveExpirationDate__c 
                        FROM Quote 
                        WHERE Id IN :quoteIds
                    ];
                    for(Quote quote : quoteList) {
                        quote.ReserveStatus__c = null;
                        quote.Waiting_Seq__c = null;
                        quote.ReserveExpirationDate__c = null;
                        updateList.add(quote);
                    }
                }
    
                if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
                if(!updateList.isEmpty()) update updateList;
            }
        }
        return;
    }

    /**
    * @description Factory, Option Only 주문 ERP 전송
    **/
    public static IF_ERP_Order_Classes.IF_ORDER_007_Res callOrderCreationIF(String orderId){

        Order order = [
            SELECT  Id, SalesOrganization__c, DistributionChannel__c, Division__c, DNSA_SalesOffice__c, SalesDistrict__c
                    , OrderType__c, toLabel(OrderType__c) oType
                    , PaymentTerms_DNSA__c, toLabel(PaymentTerms_DNSA__c) pTerms
                    , DNSAZTERM_Hide__c
                    , PurchaseType__c, toLabel(PurchaseType__c) pType
                    , ShippingConditions__c, toLabel(ShippingConditions__c) sCon

                    , RequestedShipDate__c, PurchaseOrderNo__c
                    , CurrencyIsoCode, ActualShippingDate__c
                    , PriceList__c, Warranty__c
                    , OwnerId, Owner__r.ERP_Key__c, Owner__r.CustomerCode__c, Owner__r.AccountId, Owner__r.Account.CustomerCode__c

                    , AccountId, Account.CustomerCode__c
                    , ShipTo__c, ShipTo__r.CustomerCode__c
                    
                    , OrderNotes__c, ShippingInstructions__c

                    , QuoteId

                    ,Account.CountryLookup__r.CountryCode__c

                    ,SoldTo__c
                    ,SoldTo__r.CustomerCode__c
            FROM    Order
            WHERE Id =: orderId
        ];

        List<OrderItem> items = [
            SELECT  Id, IF_POSNR__c, Quantity, Unit__c, TotalPrice, ReqShipDate__c
                    , Product2Id, Product2.ProductCode, Product2.Name__c
                    , AccessoryCode__c, AccessoryName__c
                    , QuoteLineItem.ERPQuotationNo__c, QuoteLineItem.ERPInquiryNo__c
                    , ShipTo__c, ShipTo__r.CustomerCode__c
                    , ItemCategory__c
                    , SQTitle__c
            FROM    OrderItem
            WHERE   OrderId =: orderId
        ];

        List<Warranty__c> warrantyList = [
            SELECT  Id, ZZWARRPER__c, ZZPERUNIT__c, ZZWARHRS__c, ZZPR_WAR__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c
            FROM    Warranty__c
            WHERE   VKORG__c = '4140'
            AND     ZZPR_WAR__c =: order.Warranty__c
        ];

        List<SalesAreaData__c> salesAreaDatas = [
            SELECT  Id, Incoterms__c
            FROM    SalesAreaData__c
            WHERE   SalesOrganization__c = '4140'
            AND     Account__c = : order.Owner__r.AccountId
        ];

        QuoteLineItem qtli = [
            SELECT 
                Id,
                UnitPrice,
                Final_Quotation_Price__c,
                ZSSS__c,
                ZSSD__c
            FROM
                QuoteLineItem
            WHERE
                QuoteId =: order.QuoteId
        ];

        String KSCHL;
        String KWERT;
        String VTWEG;
        Boolean tPricingadd = false;
        Decimal zsssPrice = 0;
        Decimal zssdPrice = 0;
        if(qtli != null){
            tPricingadd = true;
            zsssPrice = qtli.ZSSS__c;
            zssdPrice = qtli.ZSSD__c;
            KWERT =  String.valueOf(Math.abs(qtli.Final_Quotation_Price__c - qtli.UnitPrice));
        }
        if(order.Account.CountryLookup__r.CountryCode__c == 'US'){
            VTWEG = '10';
        }else{
            VTWEG = '20';
        }
        // T_ITEM
        Id itemId;
        Boolean hasSQ = false;
        String erpInqNo;
        Boolean isDiffShipTo = false;
        List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_ITEM> T_ITEM_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_ITEM>();
        for(OrderItem item : items) {
            IF_ERP_Order_Classes.IF_ORDER_007_Req_T_ITEM T_ITEM = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_ITEM();
            if(item.ItemCategory__c == ordSvc.ITEM_PRODUCT) {
                T_ITEM.MATNR  = item.Product2.ProductCode;
                T_ITEM.ARKTX  = item.Product2.Name__c;

                itemId = item.Id;
            } else if(item.ItemCategory__c == ordSvc.ITEM_SQ) {
                T_ITEM.MATNR = 'SQ100'; // FIXED
                T_ITEM.ARKTX = item.SQTitle__c;

                hasSQ = true;
                erpInqNo = item.QuoteLineItem.ERPInquiryNo__c;
            } else if(item.ItemCategory__c == ordSvc.ITEM_ACCESSORY) {
                T_ITEM.MATNR = item.AccessoryCode__c;
                T_ITEM.ARKTX = item.AccessoryName__c;
            }

            T_ITEM.POSNR  = item.IF_POSNR__c;
            T_ITEM.NETPR  = String.valueOf(item.TotalPrice);
            T_ITEM.WAERK  = order.CurrencyIsoCode;
            T_ITEM.KWMENG = String.valueOf(Integer.valueOf(item.Quantity));
            T_ITEM.VRKME  = item.Unit__c;
            T_ITEM.WERKS  = '4140'; // FIXED
            T_ITEM.REQ_DATE = ordSvc.formatDateForSAP(item.ReqShipDate__c, false);
            T_ITEM_LIST.add(T_ITEM);

            if(item.ShipTo__c != null && item.ShipTo__c != order.ShipTo__c) { isDiffShipTo = true; }
        }

        // I_HEAD
        IF_ERP_Order_Classes.IF_ORDER_007_Req_I_HEAD I_HEAD = new IF_ERP_Order_Classes.IF_ORDER_007_Req_I_HEAD();
        I_HEAD.AUART        = order.OrderType__c;
        I_HEAD.VKORG        = order.SalesOrganization__c;
        I_HEAD.VTWEG        = VTWEG;
        I_HEAD.SPART        = order.Division__c;
        I_HEAD.VKBUR        = order.DNSA_SalesOffice__c;
        I_HEAD.VDATU        = ordSvc.formatDateForSAP(order.RequestedShipDate__c, false);
        I_HEAD.BSTKD        = order.PurchaseOrderNo__c;
        I_HEAD.BZIRK        = order.SalesDistrict__c;
        I_HEAD.ZTERM        = order.DNSAZTERM_Hide__c;
        I_HEAD.AUGRU        = '001'; // FIXED
        I_HEAD.WAERK        = order.CurrencyIsoCode;
        I_HEAD.GI_DATE      = ordSvc.formatDateForSAP(order.ActualShippingDate__c, false);
        I_HEAD.BUKRS_VF     = '4100'; // FIXED
        I_HEAD.ABRVW        = order.PurchaseType__c;
        I_HEAD.PLTYP        = order.PriceList__c;
        I_HEAD.AUART_T      = String.valueOf(order.get('oType'));
        I_HEAD.ABRVW_T      = String.valueOf(order.get('pType'));
        I_HEAD.ZZCAPITAL_NO = order.PaymentTerms_DNSA__c;
        I_HEAD.VSBED        = order.ShippingConditions__c;
        I_HEAD.VSBED_T      = String.valueOf(order.get('sCon'));

        if(salesAreaDatas.isEmpty()) {
            I_HEAD.INCO1 = 'FOB';
        } else {
            I_HEAD.INCO1 = salesAreaDatas[0].Incoterms__c == null ? 'FOB' : salesAreaDatas[0].Incoterms__c;
        }
        I_HEAD.INCO2 = ordSvc.getPicklistLabel('SalesAreaData__c', 'Incoterms__c', I_HEAD.INCO1);

        if(hasSQ) {
            I_HEAD.ZZSQNO = erpInqNo;
        }

        if(!warrantyList.isEmpty()) {
            Warranty__c warr   = warrantyList[0];
            I_HEAD.ZZWARRPER   = warr.ZZWARRPER__c;
            I_HEAD.ZZPERUNIT   = warr.ZZPERUNIT__c;
            I_HEAD.ZZWARHRS    = warr.ZZWARHRS__c;
            I_HEAD.ZZPR_WAR    = warr.ZZPR_WAR__c;
            I_HEAD.ZZCOVERAGE = warr.ZZCOVERAGE__c;
            I_HEAD.ZZCOVERAGE_B = warr.ZZCOVERAGE_B__c;
        }

        // T_PARTNER
        // Sold to. Billl to. Payer, Service Dealer, Credit Resps. - Distributor (대리점)
        // Ship to - Order Account (고객) == Opportunity &Quote의 Account == Order의 Ship To
        // Sales Resps. - Order Owner
        List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER> T_PARTNER_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER>();

        IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER T_PARTNER_AG = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER();
        T_PARTNER_AG.PARVW = 'AG'; // Sold To
        T_PARTNER_AG.KUNNR = order.Owner__r.Account.CustomerCode__c;
        T_PARTNER_LIST.add(T_PARTNER_AG);

        IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER T_PARTNER_WE = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER();
        T_PARTNER_WE.PARVW = 'WE'; // Ship To
        T_PARTNER_WE.KUNNR = order.ShipTo__r.CustomerCode__c;
        T_PARTNER_LIST.add(T_PARTNER_WE);
        
        if(order.OrderType__c != 'ZUSO') {
            IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER T_PARTNER_Z1 = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER();
            T_PARTNER_Z1.PARVW = 'Z1'; // Service Dealer
            T_PARTNER_Z1.KUNNR = order.Owner__r.Account.CustomerCode__c;
            T_PARTNER_LIST.add(T_PARTNER_Z1);
        }
        
        IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER T_PARTNER_ZM = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER();
        T_PARTNER_ZM.PARVW = 'ZM'; // Sales Reps.
        T_PARTNER_ZM.KUNNR = order.SoldTo__r.CustomerCode__c;
        T_PARTNER_LIST.add(T_PARTNER_ZM);

        IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER T_PARTNER_RE = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER();
        T_PARTNER_RE.PARVW = 'RE'; // Bill To
        T_PARTNER_RE.KUNNR = order.Owner__r.Account.CustomerCode__c;
        T_PARTNER_LIST.add(T_PARTNER_RE);

        IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER T_PARTNER_RG = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER();
        T_PARTNER_RG.PARVW = 'RG'; // Payer
        T_PARTNER_RG.KUNNR = order.Owner__r.Account.CustomerCode__c;
        T_PARTNER_LIST.add(T_PARTNER_RG);
        
        IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER T_PARTNER_Z2 = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER();
        T_PARTNER_Z2.PARVW = 'Z2'; // Credit Reps.
        T_PARTNER_Z2.KUNNR = order.Owner__r.Account.CustomerCode__c;
        T_PARTNER_LIST.add(T_PARTNER_Z2);
        
        if(isDiffShipTo) {
            for(OrderItem item : items) {
                IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER T_PARTNER = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PARTNER();
                T_PARTNER.POSNR = item.IF_POSNR__c;
                T_PARTNER.PARVW = 'WE'; // SHIP TO
                T_PARTNER.KUNNR = item.ShipTo__r.CustomerCode__c;
                T_PARTNER_LIST.add(T_PARTNER);
            }
        }

        // T_CONFIG, T_SEL_CONFIG
        Boolean hasCV = false;
        List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_CONFIG> T_CONFIG_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_CONFIG>();
        List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_SEL_CONFIG> T_SEL_CONFIG_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_SEL_CONFIG>();
        if(itemId != null) {
            List<CVOrderItem__c> cvList = [
                SELECT  Id
                        , CharacteristicValue__c
                        , F_CCode__c
                        , F_CValue__c
                        , F_VCode__c
                        , F_VValue__c
                        , OrderProduct__c
                        , OrderProduct__r.Product2.name
                        , OrderProduct__r.Product2.name__c
                FROM    CVOrderItem__c
                WHERE   OrderProduct__c =: itemId
            ];
            hasCV = !cvList.isEmpty();

            for(CVOrderItem__c cv : cvList) {
                IF_ERP_Order_Classes.IF_ORDER_007_Req_T_CONFIG T_CONFIG = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_CONFIG();
                T_CONFIG.POSNR = '000010'; // FIXED
                T_CONFIG.ATNAM = cv.F_CCode__c;
                T_CONFIG.ATBEZ = cv.F_CValue__c;
                T_CONFIG_LIST.add(T_CONFIG);

                IF_ERP_Order_Classes.IF_ORDER_007_Req_T_SEL_CONFIG T_SEL_CONFIG = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_SEL_CONFIG();
                T_SEL_CONFIG.POSNR = '000010'; // FIXED
                T_SEL_CONFIG.MATNR = cv.OrderProduct__r.Product2.name__c;
                T_SEL_CONFIG.ATNAM = cv.F_CCode__c;
                T_SEL_CONFIG.ATWRT = cv.F_VCode__c;
                T_SEL_CONFIG_LIST.add(T_SEL_CONFIG);
            }
        }

        // T_PRICING_ADD
        List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PRICING_ADD> T_PRICING_ADD_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PRICING_ADD>();
        if(tPricingadd && order.OrderType__c != 'ZUSO'){
            IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PRICING_ADD t_pricingAdd_ZSSS = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PRICING_ADD();
            IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PRICING_ADD t_pricingAdd_ZSSD = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PRICING_ADD();
            t_pricingAdd_ZSSS.POSNR = '000010';
            t_pricingAdd_ZSSS.KSCHL = 'ZSSS';
            t_pricingAdd_ZSSS.KWERT = String.valueOf(zsssPrice.setScale(2));
            t_pricingAdd_ZSSS.WAERK = 'USD';
            T_PRICING_ADD_LIST.add(t_pricingAdd_ZSSS);

            t_pricingAdd_ZSSD.POSNR = '000010';
            t_pricingAdd_ZSSD.KSCHL = 'ZSSD';
            t_pricingAdd_ZSSD.KWERT = String.valueOf(zssdPrice.setScale(2));
            t_pricingAdd_ZSSD.WAERK = 'USD';
            T_PRICING_ADD_LIST.add(t_pricingAdd_ZSSD);
        }
        // T_PRICING_RATE
        List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PRICING_RATE> T_PRICING_RATE_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_PRICING_RATE>();

        // T_NOTES
        List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_NOTES> T_NOTES_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_007_Req_T_NOTES>();
        if(order.OrderNotes__c != null && order.OrderNotes__c != '') {

            List<String> orderNotesList = order.OrderNotes__c.split('\n');
            for(String noteRow : orderNotesList) {
                while (noteRow.length() > 132) {
                    IF_ERP_Order_Classes.IF_ORDER_007_Req_T_NOTES T_NOTES = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_NOTES();
                    T_NOTES.TDID = 'ZH01';
                    T_NOTES.LINE = noteRow.substring(0, 132);
                    T_NOTES_LIST.add(T_NOTES);

                    noteRow = noteRow.substring(132);
                }

                IF_ERP_Order_Classes.IF_ORDER_007_Req_T_NOTES T_NOTES_LAST = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_NOTES();
                T_NOTES_LAST.TDID = 'ZH01';
                T_NOTES_LAST.LINE = noteRow;
                T_NOTES_LIST.add(T_NOTES_LAST);
            }
        }

        if(order.ShippingInstructions__c != null && order.ShippingInstructions__c != '') {

            List<String> orderInstList = order.ShippingInstructions__c.split('\n');
            for(String instRow : orderInstList) {
                while (instRow.length() > 132) {
                    IF_ERP_Order_Classes.IF_ORDER_007_Req_T_NOTES T_NOTES = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_NOTES();
                    T_NOTES.TDID = 'ZH08';
                    T_NOTES.LINE = instRow.substring(0, 132);
                    T_NOTES_LIST.add(T_NOTES);

                    instRow = instRow.substring(132);
                }

                IF_ERP_Order_Classes.IF_ORDER_007_Req_T_NOTES T_NOTES_LAST = new IF_ERP_Order_Classes.IF_ORDER_007_Req_T_NOTES();
                T_NOTES_LAST.TDID = 'ZH08';
                T_NOTES_LAST.LINE = instRow;
                T_NOTES_LIST.add(T_NOTES_LAST);
            }
        }

        IF_ERP_Order_Classes.IF_ORDER_007_Req_I_USERINFO I_USERINFO = new IF_ERP_Order_Classes.IF_ORDER_007_Req_I_USERINFO();
        I_USERINFO.BNAME = order.OwnerId;
        I_USERINFO.RNAME = ordSvc.formatCodeForSAP(12, String.valueOf(order.Owner__r.ERP_Key__c));
        I_USERINFO.HIER  = 'A'; // FIXED
        I_USERINFO.KUNNR = order.Owner__r.CustomerCode__c;
        I_USERINFO.VKORG = order.SalesOrganization__c;
        I_USERINFO.VTWEG = VTWEG;
        I_USERINFO.SPART = order.Division__c;

        IF_ERP_Order_Classes.IF_ORDER_007_Req request = new IF_ERP_Order_Classes.IF_ORDER_007_Req();
        request.I_REF_ORDER = items[0].QuoteLineItem.ERPQuotationNo__c;
        request.I_COMPLAIN  = '';  // FIXED
        request.I_GUBUN     = 'C'; // FIXED
        request.I_TESTRUN   = '';  // FIXED

        request.I_HEAD    = I_HEAD;
        request.T_ITEM    = T_ITEM_LIST;
        request.T_PARTNER = T_PARTNER_LIST;
        if(hasCV) { 
            request.T_CONFIG     = T_CONFIG_LIST; 
            request.T_SEL_CONFIG = T_SEL_CONFIG_LIST; 
        }
        request.T_PRICING_ADD  = T_PRICING_ADD_LIST;
        request.T_PRICING_RATE = T_PRICING_RATE_LIST;
        request.T_NOTES        = T_NOTES_LIST;
        request.I_USERINFO     = I_USERINFO;

        IF_ERP_Order instance = new IF_ERP_Order();
        IF_ERP_Order_Classes.IF_ORDER_007_Res response = instance.IF_ORDER_007(request);

        return response;
    }

    /**
    * @description Commodity Order ERP 전송
    **/
    public static IF_ERP_Order_Classes.IF_ORDER_006_Res callOrderCreationIF006(Order order, List<OrderItem> oliList) {
        User currentUser = [SELECT Id, SalesOrganization__c, DistributionChannel__c, Division__c, SalesDistrict__c, AccountId, Account.CustomerCode__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<OrderItem> accList = [
            SELECT  Id
                    , StockResSO__c
                    , IF_POSNR__c 
                    , Accessory__c
                    , AccessoryCode__c
                    , AccessoryName__c
                    , AccessoryCategory__c
                    , UnitPrice
                    , Quantity
                    , ShipTo__c
                    , ShipTo__r.CustomerCode__c
                    , ReqShipDate__c
                    , Order.ShipTo__c
            FROM OrderItem 
            WHERE OrderId = :order.Id 
            AND Accessory__c != null
        ];

        Warranty__c warranty = [
            SELECT  Id, ZZWARRPER__c, ZZPERUNIT__c, ZZWARHRS__c, ZZPR_WAR__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c
            FROM    Warranty__c
            WHERE   VKORG__c = '4140'
            AND     ZZPR_WAR__c =: order.MachinePartsWarranty__c
            LIMIT 1
        ];

        // 🎉wrapper patner
        IF_ERP_Order_Classes.IF_ORDER_006_Req_IS_PARTNER partner = new IF_ERP_Order_Classes.IF_ORDER_006_Req_IS_PARTNER();
        partner.KUNNR1 = order.Owner__r.Account.CustomerCode__c;   
        partner.KUNNR2 = order.Owner__r.Account.CustomerCode__c;
        partner.KUNNR3 = order.Owner__r.Account.CustomerCode__c;
        partner.KUNNR4 = order.Owner__r.Account.CustomerCode__c;
        partner.KUNNR5 = order.Owner__r.CustomerCode__c;
    
        // 🎉wrapper header
        IF_ERP_Order_Classes.IF_ORDER_006_Req_IS_HEADER header = new IF_ERP_Order_Classes.IF_ORDER_006_Req_IS_HEADER();
        header.VDATU        = ordSvc.formatDateForSAP(order.RequestedShipDate__c, false);
        header.ZTERM        = order.PaymentTerms_DNSA__c == 'D&AU' ? 'CC90' : 'C001';
        
        header.ZZPR_WAR     = String.valueOf(order.MachinePartsWarranty__c);
        header.ZZWARRPER    = String.valueOf(warranty.ZZWARRPER__c);
        header.ZZPERUNIT    = String.valueOf(warranty.ZZPERUNIT__c);
        header.ZZWARHRS     = String.valueOf(warranty.ZZWARHRS__c);
        header.ZZCAPITAL_NO = order.PaymentTerms_DNSA__c;

        // 🎉note on
        IF_ERP_Order_Classes.IF_ORDER_006_Req_IS_NOTE_ON note_on = new IF_ERP_Order_Classes.IF_ORDER_006_Req_IS_NOTE_ON();
        note_on.HEAD = (order.OrderNotes__c != null && order.OrderNotes__c.length() > 1024) ? order.OrderNotes__c.substring(0, 1024) : order.OrderNotes__c;
    
        // 🎉note_si
        IF_ERP_Order_Classes.IF_ORDER_006_Req_IS_NOTE_SI note_si = new IF_ERP_Order_Classes.IF_ORDER_006_Req_IS_NOTE_SI();
        note_si.HEAD = (order.ShippingInstructions__c != null && order.ShippingInstructions__c.length() > 1024) ? order.ShippingInstructions__c.substring(0, 1024) : order.ShippingInstructions__c;
    
        // 🎉note_cc
        IF_ERP_Order_Classes.IF_ORDER_006_Req_IS_NOTE_CC note_cc = new IF_ERP_Order_Classes.IF_ORDER_006_Req_IS_NOTE_CC();
        // note_cc.HEAD = 'CIRCUMSTANCE TEST 11.11.11';
        List<String> fieldNames = new List<String>{
            'PUBldgConstruction__c', 'PUNewFoundation__c', 'PUAccessoryDelivery__c',
            'PUFinancialApproval__c', 'PUContractApproval__c', 'PUExportLicense__c'
        };
        List<String> helpTexts = new List<String>();

        for (String fieldName : fieldNames) {
            Schema.DescribeFieldResult fieldDescribe = Order.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe();
            if ((Boolean) order.get(fieldName)) {
                helpTexts.add(fieldDescribe.getInlineHelpText());
            }
        }

        if (order.Other__c != null) {
            helpTexts.add(order.Other__c);
        }
        if(!helpTexts.isEmpty()) {
            String finalText = String.join(helpTexts, '\n ');
            note_cc.HEAD = (finalText.length() > 1024) ? finalText.substring(0, 1024) : finalText;
        } else {
            note_cc.HEAD = '';
        }

        // 🎉Item List
        List<IF_ERP_Order_Classes.IF_ORDER_006_Req_T_ITEM> item_list = new List<IF_ERP_Order_Classes.IF_ORDER_006_Req_T_ITEM>();
        for(OrderItem acc : accList) {
            IF_ERP_Order_Classes.IF_ORDER_006_Req_T_ITEM item = new IF_ERP_Order_Classes.IF_ORDER_006_Req_T_ITEM();
            item.POSNR = acc.IF_POSNR__c;
            item.MATNR = acc.AccessoryName__c;
            item.ARKTX = acc.AccessoryName__c;
            item.KWMENG = String.valueOf(Integer.valueOf(acc.Quantity));
            item.WERKS = '4140';
            item.REQ_DATE = ordSvc.formatDateForSAP(acc.ReqShipDate__c, false);
            item_list.add(item);
        }
        if(!accList.isEmpty()) {
        }

        // 🎉Partner List
        List<IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PARTNERS> partner_list = new List<IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PARTNERS>();
        for(OrderItem acc : accList) {
            if(acc.ShipTo__c != acc.Order.ShipTo__c){
                IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PARTNERS t_partner = new IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PARTNERS();    
                t_partner.POSNR = acc.IF_POSNR__c;
                t_partner.PARVW = 'WE';
                t_partner.KUNNR = acc.ShipTo__r.CustomerCode__c;
                partner_list.add(t_partner);
            } 
        }
        if(!accList.isEmpty()) {
        }

        // 🎉Pricing List
        List<IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING> pricing_list = new List<IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING>();

        // 🎉Pricing Add List
        List<IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_ADD> pricingAdd_list = new List<IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_ADD>();
        if(order.PromotionalPackage__c != null && order.PromotionalPackage__c != 0) {
            IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_ADD t_pricingAdd = new IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_ADD();    
            t_pricingAdd.POSNR = '000010';
            t_pricingAdd.KSCHL = 'ZPKG';
            t_pricingAdd.KWERT = String.valueOf(Math.abs(order.PromotionalPackage__c));
            t_pricingAdd.WAERK = 'USD';
            pricingAdd_list.add(t_pricingAdd);
        }
        if(order.ServiceReimbursement__c == 'Y') {
            IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_ADD t_pricingAdd = new IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_ADD();    
            t_pricingAdd.POSNR = '000010';
            t_pricingAdd.KSCHL = 'ZMRD';
            t_pricingAdd.KWERT = String.valueOf(Math.abs(order.ServiceReimbursementPrice__c));
            t_pricingAdd.WAERK = 'USD';
            pricingAdd_list.add(t_pricingAdd);
        }
        if(order.OtherDiscount__c != null && order.OtherDiscount__c != 0) {
            IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_ADD t_pricingAdd = new IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_ADD();    
            t_pricingAdd.POSNR = '000010';
            t_pricingAdd.KSCHL = 'ZOTH';
            t_pricingAdd.KWERT = String.valueOf(Math.abs(order.OtherDiscount__c));
            t_pricingAdd.WAERK = 'USD';
            pricingAdd_list.add(t_pricingAdd);
        }
        if(order.ProfitMarginSubsidyPlan__c != null && order.ProfitMarginSubsidyPlan__c != 0) {
            IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_ADD t_pricingAdd = new IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_ADD();    
            t_pricingAdd.POSNR = '000010';
            t_pricingAdd.KSCHL = 'ZPMS';
            t_pricingAdd.KWERT = String.valueOf(Math.abs(order.ProfitMarginSubsidyPlan__c));
            t_pricingAdd.WAERK = 'USD';
            pricingAdd_list.add(t_pricingAdd);
        }
        
        // 🎉Pricing Rate List
        List<IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_RATE> pricingRate_list = new List<IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_RATE>();
        IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_RATE t_pricingRate = new IF_ERP_Order_Classes.IF_ORDER_006_Req_T_PRICING_RATE();    
        if(order.DiscountfromSalesAvailabilityList__c != null) {
            t_pricingRate.POSNR = '00010';
            t_pricingRate.KSCHL = 'ZMSC';
            t_pricingRate.RATE = String.valueOf(order.DiscountfromSalesAvailabilityList__c);
            t_pricingRate.WAERK = 'USD';
            pricingRate_list.add(t_pricingRate);
        }
    
        // 🎉execute wrapper
        IF_ERP_Order_Classes.IF_ORDER_006_Req request = new IF_ERP_Order_Classes.IF_ORDER_006_Req();
        request.I_DOC_NUMB      = oliList[0].StockResSO__c;
        request.I_DOC_TYPE      = order.ShipTo__r.CountryLookup__r.CountryCode__c == 'US' ? 'ZDOB' : 'ZEXB';
        request.I_RDD           = ordSvc.formatDateForSAP(order.RequestedShipDate__c, false);
        request.I_KUNNR_SOLD    = currentUser.Account.CustomerCode__c;
        request.I_KUNNR_SHIP    = order.ShipTo__r.CustomerCode__c;
        request.I_BSTKD         = order.PurchaseOrderNo__c;
        request.I_LGORT         = order.FOBPoint__c == 'Other' ? '' : order.FOBPoint__c;
        request.IS_PARTNER      = partner;                    
        request.IS_HEADER       = header ;
        request.IS_NOTE_ON      = note_on;
        request.IS_NOTE_SI      = note_si;
        request.IS_NOTE_CC      = note_cc;
        request.T_ITEM          = item_list;
        request.T_PARTNERS      = partner_list;
        request.T_PRICING       = pricing_list;
        request.T_PRICING_ADD   = pricingAdd_list;
        request.T_PRICING_RATE  = pricingRate_list;

        IF_ERP_Order instance = new IF_ERP_Order();
        IF_ERP_Order_Classes.IF_ORDER_006_Res response = instance.IF_ORDER_006(request);

        return response;
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

    /**
    * @description 결과 반환 Wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess  {get;set;}
        @AuraEnabled public String  errorMsg {get;set;}
        
        public ResultWrapper(){
            this.isSuccess  = true;
            this.errorMsg = '';
        }
    }
}