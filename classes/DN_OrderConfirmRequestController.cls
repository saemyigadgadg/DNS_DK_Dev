/**
 * @class             : DN_OrderConfirmRequestController
 * @description       : [SLS-ORD-012, SLS-ORD-023] CRM에서 생성 된 Order를 ERP로 전송 및 Status 변경하기 위한 Controller
 * @author            : yeongju.yun
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-10-25   yeongju.yun   Initial Version
**/
public without sharing class DN_OrderConfirmRequestController {
    
    public static DN_OrderService ordSvc = new DN_OrderService();


    // /**
    // * @description  Order와 연결 된 Opportunity가 Closed이고, 
    //                 Order의 Status가 'Order Create'일 때 버튼 클릭 가능
    //                 (= ERP에 전송한 적 없을 때)
    // * @author yeongju.yun | 2024-10-25 
    // * @param orderId 
    // * @return ResultWrapper 
    // **/
    // @AuraEnabled
    // public static ResultWrapper validateOrderConfrim(String orderId){
    //     ResultWrapper result = new ResultWrapper();
    //     System.debug('validateOrderConfrim - orderId ::: ' + orderId);

    //     try {
            
    //         Order order = [
    //             SELECT Id, OrderNumber, Status, OpportunityId, Opportunity.StageName
    //                     , HasPricingProcessed__c, HasScheduleCompleted__c, OrderSegmentation__c
    //                     , SalesChannelType__c
    //             FROM Order 
    //             WHERE Id =: orderId
    //         ];
    //         Opportunity opty = [SELECT Id, StageName FROM Opportunity WHERE Id =: order.OpportunityId WITH SECURITY_ENFORCED];
    //         Boolean isDomestic = ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c);

    //         List<String> closedStatus = new List<String>{ordSvc.ORDER_CANCELED, ordSvc.ORDER_Returned};
    //         List<String> confirmedStatus = new List<String>{ordSvc.ORDER_CONFIRMED, ordSvc.ORDER_MAPPED, ordSvc.ORDER_DELIVERY};

    //         List<PaymentSchedule__c> psList = [SELECT Id, DraftCheck__c FROM PaymentSchedule__c WHERE Order__c =: orderId];

    //         if(order.Status == ordSvc.ORDER_CREATE) {
    //             result.isSuccess  = false;
    //             result.errMessage = System.Label.DNS_M_OrderInternalApprovalFirst; // Please complete the internal order approval first.
    //         } else if(order.Status == ordSvc.ORDER_PROGRESS) {
    //             result.isSuccess  = false;
    //             result.errMessage = System.Label.DNS_M_AlreadyRequested; // This order has already been requested for confirmation.
    //         } else if(closedStatus.contains(order.Status)) {
    //             result.isSuccess  = false;
    //             result.errMessage = System.Label.DNS_M_CancelRequestConfirmError; // Orders that are canceled or returned cannot request confirm.
    //         } else if(confirmedStatus.contains(order.Status)) {
    //             result.isSuccess  = false;
    //             result.errMessage = System.Label.DNS_M_AlreadyConfirmed; // This order has already been confirmed.
    //         } else if(opty.StageName != 'Closed Won') { // SLS-ORD-023
    //             result.isSuccess  = false;
    //             result.errMessage = System.Label.DNS_M_RequestOptyClosed; // Please close the associated Opportunity to proceed with the order confirmation.
    //         } else if(isDomestic && !order.HasScheduleCompleted__c) {
    //             result.isSuccess  = false;
    //             result.errMessage = System.Label.DNS_M_AddPaymentSchedule; // Please complete the payment schedule first.
    //         } else if(isDomestic && order.HasPricingProcessed__c && psList[0].DraftCheck__c != 'Success') {
    //             result.isSuccess  = false;
    //             result.errMessage = System.Label.DNS_M_ValidationDraftNo; // Validation is required to ensure that the Draft No is valid.
    //         }
    //     } catch (Exception e) {
    //         System.debug('validateOrderConfrim : ' + e.getLineNumber() + ' / ' + e.getMessage());
    //         result.isSuccess  = false;
    //         result.errMessage = e.getMessage();
    //     }
    //     return result;
    // }

    // /**
    // * @description Order Create > Order Confirmation in Progress, CRM > ERP I/F 호출 
    // * @author yeongju.yun | 2024-10-25 
    // * @return ResultWrapper 
    // **/
    // @AuraEnabled
    // public static ResultWrapper requestConfirm(String orderId){
        
    //     IF_ERP_Order_Classes.IF_ORDER_001_Res response = callOrderCreationIF(orderId);
    //     System.debug(' response ::: ' + response);

    //     SavePoint sp = Database.setSavePoint();

    //     ResultWrapper result = new ResultWrapper();
    //     try {
    //         if(response.O_RETURN.TYPE == 'E') {
    //             System.debug('requestConfirm - response error : ' + response.O_RETURN.MESSAGE);
    //             AuraHandledException e = new AuraHandledException('error');
    //             e.setMessage(response.O_RETURN.MESSAGE);
    //             throw e;
    //         } 

    //         // Order order          = new Order();
    //         // order.Id             = orderId;
    //         // order.Status         = ordSvc.ORDER_PROGRESS;
    //         // order.ERPOrderNo__c  = response.O_VBELN;
    //         // order.IF_FreePass__c = true;
    //         // update order;

    //         // mappingPriceInfo(orderId, response); // Mapping Price

    //         result.data.put('erpNo', response.O_VBELN);

    //     } catch (Exception e) {
    //         Database.rollback(sp);
    //         System.debug('requestConfirm : ' + e.getLineNumber() + ' / ' + e.getMessage());
    //         result.isSuccess  = false;
    //         result.errMessage = e.getMessage();
    //     }
    //     return result;
    // }

    // @AuraEnabled
    // public static ResultWrapper fetchCVInfo(String orderId, String erpNo){
    //     System.debug('fetchCVInfo ::: ' + orderId + ' / ' + erpNo);

    //     IF_ERP_Order_Classes.IF_ORDER_021_Res response = callCVPriceIF(orderId, erpNo);
    //     System.debug('fetchCVInfo - response ::: ' + response);

    //     SavePoint sp = Database.setSavePoint();

    //     ResultWrapper result = new ResultWrapper();
    //     try {
    //         if(response.O_RETURN.TYPE == 'E') {
    //             System.debug('fetchCVInfo - response error : ' + response.O_RETURN.MESSAGE);
    //             AuraHandledException e = new AuraHandledException('error');
    //             e.setMessage(response.O_RETURN.MESSAGE);
    //             throw e;
    //         } 

    //         Order order          = new Order();
    //         order.Id             = orderId;
    //         order.Status         = ordSvc.ORDER_PROGRESS;
    //         order.ERPOrderNo__c  = erpNo;
    //         order.IF_FreePass__c = true;
    //         update order;

    //         mappingCVPriceInfo(orderId, response); // Mapping Price
            
    //         return result;
    //     } catch (Exception e) {
    //         System.debug('fetchCVInfo : ' + e.getLineNumber() + ' / ' + e.getMessage());
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    

    // /**
    // * @description 
    // * @author yeongju.yun | 2024-12-09 
    // * @param orderId 
    // * @return IF_ERP_Order_Classes.IF_ORDER_001_Res 
    // String orderId = '801F7000001RVEyIAO'; // test
    // IF_ERP_Order_Classes.IF_ORDER_001_Res response = DN_OrderConfirmRequestController.callOrderCreationIF(orderId);
    // System.debug('test0001 : ' + response);
    // **/
    // public static IF_ERP_Order_Classes.IF_ORDER_001_Res callOrderCreationIF(String orderId){

    //     Order order = [
    //         SELECT  Id
    //                 , OwnerId, Owner__r.CustomerCode__c, Owner__r.Account.CustomerCode__c, Owner__r.SalesDistrict__c
    //                 , Owner__r.Account.Name, Owner__r.Name, Owner__r.ERP_Key__c

    //                 , SalesOrganization__c, DistributionChannel__c, Division__c, SalesOffice__c

    //                 , CreatedDate, ReqDeliveryDate__c
    //                 , CurrencyIsoCode
    //                 , IsExport__c, ExportTo__c
    //                 , OrderType__c
    //                 , Description
    //                 , OverallStatus__c
    //                 , HasSpecialDC__c
    //                 , CustomerOrderNo__c
    //                 , Incoterms__c
    //                 , PaymentTerms__c
    //                 , PurchaseType__c
    //                 , Contractor__c
    //                 , EndUser__c
    //                 , MainCategory__c
    //                 , SubCategory__c
    //                 , IsTooling__c
    //                 , PriceList__c
    //                 , ShippingConditions__c
    //                 , DealerCommission__c
    //                 , Warranty__c
    //                 , Vendor__c
    //                 , OrderSegmentation__c
    //                 , SalesChannelType__c

    //                 , Opportunity.ERP_Inquiry_No__c

    //                 , Account.Name, Account.SalesDistrict__c, Account.CustomerCode__c
    //                 , SoldTo__c,        SoldTo__r.Name,   SoldTo__r.CustomerCode__c
    //                 , ShipTo__c,        ShipTo__r.Name,   ShipTo__r.CustomerCode__c
    //                 , BillTo__c,        BillTo__r.Name,   BillTo__r.CustomerCode__c
    //                 , Payer__c,         Payer__r.Name,    Payer__r.CustomerCode__c
    //                 , SalesRep__c,      SalesRep__r.Name, SalesRep__r.DealerGrade__c
    //                 , CreditDealer__c,  CreditDealer__r.Name
    //                 , ServiceDealer__c, ServiceDealer__r.Name

    //                 , ERPOrderNo__c
    //                 , Quote.Account.AccountGroup__c
                    
    //         FROM    Order
    //         WHERE   Id = : orderId
    //     ];
    //     System.debug('callOrderCreationIF - order ::: ' + order);

    //     List<OrderItem> items = [
    //         SELECT  Id
    //                 , Quantity
    //                 , CurrencyIsoCode
    //                 , IF_POSNR__c
    //                 , UnitPrice
    //                 , TotalPrice
    //                 , StandardPrice__c
    //                 , AdjustmentPrice__c
    //                 , ItemCategory__c
    //                 , Unit__c
    //                 , Product2Id, Product2.ProductCode, Product2.Name, Product2.Name__c, Product2.Plant__c
    //                 , SQ__c, SQ__r.Name, SQ__r.SQCode__c, F_SQStage__c
    //                 , QuoteLineItemId, QuoteLineItem.ERPQuotationNo__c
    //                 , Accessory__r.Name, Accessory__r.Description__c
    //         FROM    OrderItem
    //         WHERE   OrderId =: orderId
    //     ];
    //     System.debug('callOrderCreationIF - items ::: ' + items);

    //     // get plant
    //     List<ProductByPlant__c> plantList = [
    //         SELECT  Id, Part__c, Plant__c
    //         FROM    ProductByPlant__c
    //         WHERE   Part__c = :items[0].Product2Id
    //         AND     Plant__c IN ('1840', '1842')
    //     ];

    //     Map<Id, Boolean> userTypeMap = ordSvc.getUserFlag(new Set<Id>{order.OwnerId});
    //     Boolean isCRMUser = userTypeMap.get(order.OwnerId);
    //     Boolean isGlobal  = order.SalesChannelType__c == ordSvc.CHANNER_OVERSEAS;

    //     String customerCode = isCRMUser ? ordSvc.formatCodeForSAP(10, order.Owner__r.CustomerCode__c) : ordSvc.formatCodeForSAP(10, order.Owner__r.Account.CustomerCode__c);
    //     String customerName = isCRMUser ? order.Owner__r.Name : order.Owner__r.Account.Name;
    //     System.debug('callOrderCreationIF - values isCRMUser : ' + isCRMUser + ' , customerCode : ' + customerCode);

    //     // I_USERINFO
    //     IF_ERP_Order_Classes.IF_ORDER_001_Req_I_USERINFO I_USERINFO = new  IF_ERP_Order_Classes.IF_ORDER_001_Req_I_USERINFO();
    //     I_USERINFO.BNAME = order.OwnerId;
    //     I_USERINFO.RNAME = ordSvc.formatCodeForSAP(12, String.valueOf(order.Owner__r.ERP_Key__c));
    //     I_USERINFO.HIER  = 'A';
    //     I_USERINFO.KUNNR = customerCode;
    //     I_USERINFO.VKORG = order.SalesOrganization__c;

    //     // I_HEAD
    //     IF_ERP_Order_Classes.IF_ORDER_001_Req_I_HEAD I_HEAD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_HEAD();
    //     I_HEAD.AUART = order.OrderType__c; // REQUIRED
    //     I_HEAD.VKORG = order.SalesOrganization__c; // REQUIRED
    //     I_HEAD.VTWEG = order.DistributionChannel__c; // REQUIRED
    //     I_HEAD.SPART = order.Division__c; // REQUIRED
    //     I_HEAD.KUNNR = ordSvc.formatCodeForSAP(10, order.SoldTo__r.CustomerCode__c); // REQUIRED
    //     I_HEAD.KUNAG = ordSvc.formatCodeForSAP(10, order.ShipTo__r.CustomerCode__c); // REQUIRED
    //     I_HEAD.VKBUR = order.SalesOffice__c;

    //     // T_ITEM
    //     Id itemId;
    //     String erpQuoteNo;
    //     OrderItem prodItems;
    //     Boolean hasSQ = false;
    //     List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM> T_ITEM_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM>();
    //     for(OrderItem item : items) {
    //         IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM T_ITEM = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM();
    //         if(item.ItemCategory__c == ordSvc.ITEM_PRODUCT) {
    //             T_ITEM.MATNR  = item.Product2.ProductCode;
    //             T_ITEM.ARKTX  = item.Product2.Name__c;

    //             itemId     = item.Id;
    //             prodItems  = item;
    //             erpQuoteNo = item.QuoteLineItem.ERPQuotationNo__c;
    //         } else if(item.ItemCategory__c == ordSvc.ITEM_SQ) {
    //             hasSQ = true;
    //             T_ITEM.MATNR     = 'SQ100';
    //             T_ITEM.ZZSQCOD   = item.SQ__r.SQCode__c;
    //             T_ITEM.ZZSQTITLE = item.SQ__r.Name;

    //             Decimal toSendPrice = item.StandardPrice__c * item.Quantity;
    //             if(toSendPrice == 0) { T_ITEM.PSTYV = 'ZFOC'; } // 20250221 ZFOQ > ZFOC
    //             // if(toSendPrice == 0) { T_ITEM.PSTYV = 'ZFOQ'; }
    //             // PSTYV : 무료 SQ Flag
                
    //             String toSendPriceStr = String.valueOf(toSendPrice);
    //             T_ITEM.NETPR = toSendPriceStr;

    //         } else if(item.ItemCategory__c == ordSvc.ITEM_ACCESSORY) {
    //             T_ITEM.MATNR = item.Accessory__r.Name;
    //             T_ITEM.ARKTX = item.Accessory__r.Description__c;
    //             if(item.UnitPrice == 0) { 
    //                 T_ITEM.PSTYV = 'ZFOC';
    //                 T_ITEM.NETPR = '0';
    //                 // PSTYV : 무료 추가자재 Flag
    //             }
    //         }
    //         T_ITEM.POSNR  = item.IF_POSNR__c;
    //         T_ITEM.KWMENG = Integer.valueOf(item.Quantity) + '.000';
    //         T_ITEM.VRKME  = item.Unit__c;
            
    //         if(!plantList.isEmpty()) { T_ITEM.WERKS  = plantList[0].Plant__c; }

    //         T_ITEM_LIST.add(T_ITEM);
    //     }

    //     // I_GENERAL
    //     IF_ERP_Order_Classes.IF_ORDER_001_Req_I_GENERAL I_GENERAL = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_GENERAL();
    //     I_GENERAL.BSTNK    = order.CustomerOrderNo__c;
    //     I_GENERAL.VDATU    = ordSvc.formatDateForSAP(order.ReqDeliveryDate__c, false); // REQUIRED
    //     I_GENERAL.INCO1    = order.Incoterms__c;
    //     I_GENERAL.INCO2    = ordSvc.getPicklistLabel('Order', 'Incoterms__c', order.Incoterms__c);
    //     I_GENERAL.ABRVW    = order.PurchaseType__c;
    //     I_GENERAL.BZIRK    = order.Owner__r.SalesDistrict__c;
    //     I_GENERAL.BZIRK_TX = ordSvc.getPicklistLabel('User', 'SalesDistrict__c', order.Owner__r.SalesDistrict__c);
    //     I_GENERAL.WAERK    = order.CurrencyIsoCode;
    //     I_GENERAL.ZTERM    = order.PaymentTerms__c;
    //     I_GENERAL.PLTYP    = order.PriceList__c;
    //     I_GENERAL.AUGRU    = '001';
    //     I_GENERAL.ZZSQITEM = '';
    //     if(hasSQ) { 
    //         I_GENERAL.ZZSQITEM = 'Y';
    //         I_GENERAL.ZZSQNO = order.Opportunity.ERP_Inquiry_No__c;
    //     }
    //     if(!plantList.isEmpty()) { I_GENERAL.WERK = plantList[0].Plant__c; }

    //     // I_PARTNER
    //     // KUNNR1(Z1) - ServiceDealer__c*
    //     // KUNNR2(ZM) - SalesRep__c*
    //     // KUNNR3(RE) - BillTo__c
    //     // KUNNR4(Z2) - CreditDealer__c*
    //     // KUNNR5(RG) - Payer__c
    //     // KUNNR7(ZI) - RelatedDealer__c : 전송값 X, ERP에서 받아옴
    //     IF_ERP_Order_Classes.IF_ORDER_001_Req_I_PARTNER I_PARTNER = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_PARTNER();
    //     I_PARTNER.KVGRP1    = order.MainCategory__c; // REQUIRED
    //     I_PARTNER.KVGRP2    = order.SubCategory__c; // REQUIRED
    //     I_PARTNER.KVGRP3    = order.IsTooling__c; // REQUIRED

    //     I_PARTNER.KUNNR1    = customerCode; // REQUIRED
    //     I_PARTNER.KUNNR1_TX = customerName; // REQUIRED
    //     I_PARTNER.KUNNR2    = customerCode; // REQUIRED
    //     I_PARTNER.KUNNR2_TX = customerName; // REQUIRED
    //     I_PARTNER.KUNNR3    = ordSvc.formatCodeForSAP(10, order.BillTo__r.CustomerCode__c); // REQUIRED
    //     I_PARTNER.KUNNR3_TX = order.BillTo__r.Name; // REQUIRED
    //     I_PARTNER.KUNNR4    = customerCode; // REQUIRED
    //     I_PARTNER.KUNNR4_TX = customerName; // REQUIRED
    //     I_PARTNER.KUNNR5    = ordSvc.formatCodeForSAP(10, order.Payer__r.CustomerCode__c); // REQUIRED
    //     I_PARTNER.KUNNR5_TX = order.Payer__r.Name; // REQUIRED

    //     // I_COLLECTION
    //     List<PaymentSchedule__c> psList = [
    //         SELECT  Id, PlanNo__c, ReqDeliveryDate__c, TotalAmount__c, DraftNoText__c, CurrencyIsoCode
    //         FROM    PaymentSchedule__c
    //         WHERE   Order__c =: orderId
    //     ];
        
    //     IF_ERP_Order_Classes.IF_ORDER_001_Req_I_COLLECTION I_COLLECTION = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_COLLECTION();
    //     if(!psList.isEmpty()) {
    //         PaymentSchedule__c paymentSchedule = psList[0];
    
    //         I_COLLECTION.BASE_DATE  = ordSvc.formatDateForSAP(paymentSchedule.ReqDeliveryDate__c, false);
    //         I_COLLECTION.ZZINCOM_NO = paymentSchedule.PlanNo__c;
    //         I_COLLECTION.NETWR      = String.valueOf(paymentSchedule.TotalAmount__c);
    //         I_COLLECTION.WAERK      = paymentSchedule.CurrencyIsoCode;
    //     }

    //     // I_WARRANT_OPT
    //     // String warrantyVTWEG = isGlobal ? '20' : '10';
    //     // List<Warranty__c> warrantyList = [
    //     //     SELECT  Id, ZZWARRPER__c, ZZWARHRS__c, ZZPR_WAR__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c
    //     //     FROM    Warranty__c 
    //     //     WHERE   VTWEG__c = :warrantyVTWEG
    //     //     AND     ZZPR_WAR__c = : order.Warranty__c
    //     // ];
    //     // IF_ERP_Order_Classes.IF_ORDER_001_Req_I_WARRANT_OPT  I_WARRANT_OPT = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_WARRANT_OPT();
    //     // if(!warrantyList.isEmpty()) {
    //     //     Warranty__c warr = warrantyList[0];

    //     //     I_WARRANT_OPT.ZZWARRPER     = warr.ZZWARRPER__c;
    //     //     I_WARRANT_OPT.ZZWARHRS      = warr.ZZWARHRS__c;
    //     //     I_WARRANT_OPT.ZZPR_WAR      = warr.ZZPR_WAR__c;
    //     //     I_WARRANT_OPT.ZZCOVERAGE    = warr.ZZCOVERAGE__c;
    //     //     I_WARRANT_OPT.ZZCOVERAGE_B  = warr.ZZCOVERAGE_B__c;

    //     // }

    //     // I_NOTE
    //     IF_ERP_Order_Classes.IF_ORDER_001_Req_I_NOTE I_NOTE = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_NOTE();
    //     I_NOTE.HEAD = order.Description;

    //     // I_COM_DEALER
    //     IF_ERP_Order_Classes.IF_ORDER_001_Req_I_COM_DEALER I_COM_DEALER = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_COM_DEALER();
    //     if(isGlobal) {
    //         I_COM_DEALER.ZDLRCOM_AMT = String.valueOf(order.DealerCommission__c);
    //         I_COM_DEALER.WAERS       = order.CurrencyIsoCode;
    //         if(order.DealerCommission__c != 0 && order.DealerCommission__c != null) {

    //             List<Vendor__c> vendorList = [SELECT LIFNR__c FROM Vendor__c WHERE Id =: order.Vendor__c];
                
    //             I_COM_DEALER.KONDA = '40';
    //             I_COM_DEALER.LIFNR = vendorList[0].LIFNR__c;
    //         }
    //     }
    //     if(isGlobal && order.DealerCommission__c != 0 && order.DealerCommission__c != null) { I_COM_DEALER.KONDA = '40'; }

    //     // T_CONFIG, T_SEL_CONFIG
    //     List<CVOrderItem__c> cvList = [
    //         SELECT  Id
    //                 , CharacteristicValue__c
    //                 , F_CCode__c
    //                 , F_CValue__c
    //                 , F_VCode__c
    //                 , F_VValue__c
    //                 , OrderProduct__c
    //                 , OrderProduct__r.Product2.name
    //                 , OrderProduct__r.Product2.name__c
    //         FROM    CVOrderItem__c
    //         WHERE   OrderProduct__c =: itemId
    //     ];
    //     System.debug('callOrderCreationIF - cvList ::: ' + cvList);

    //     List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_CONFIG> T_CONFIG_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_CONFIG>();
    //     List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_SEL_CONFIG> T_SEL_CONFIG_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_SEL_CONFIG>();
    //     for(CVOrderItem__c cv : cvList) {
    //         IF_ERP_Order_Classes.IF_ORDER_001_Req_T_CONFIG T_CONFIG = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_CONFIG();
    //         T_CONFIG.ATNAM = cv.F_CCode__c;
    //         T_CONFIG.ATBEZ = cv.F_CValue__c;
    //         T_CONFIG_LIST.add(T_CONFIG);

    //         IF_ERP_Order_Classes.IF_ORDER_001_Req_T_SEL_CONFIG T_SEL_CONFIG = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_SEL_CONFIG();
    //         T_SEL_CONFIG.MATNR = cv.OrderProduct__r.Product2.name__c;
    //         T_SEL_CONFIG.ATNAM = cv.F_CCode__c;
    //         T_SEL_CONFIG.ATWRT = cv.F_VCode__c;
    //         T_SEL_CONFIG_LIST.add(T_SEL_CONFIG);
    //     }

    //     // T_PRICING_ADD, T_MULTICOND
    //     List<OrderPricingSelected__c> selPromotions = [
    //         SELECT  Id, Type__c, Key__c, Amount__c, SpecialAmount__c, Rate__c, IsAuto__c, CurrencyIsoCode
    //         FROM    OrderPricingSelected__c
    //         WHERE   Type__c IN ('Special', 'Promotion')
    //         AND     Order__c = : orderId
    //     ];
        

    //     List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD> T_PRICING_ADD_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD>();
    //     List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND> T_MULTICOND_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND>();
    //     for(OrderPricingSelected__c selPro : selPromotions) {
    //         Boolean isAdd = selPro.Type__c == 'Special' && selPro.Key__c.startsWith('ZPRC');
    //         if(isAdd) {
    //             IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD T_PRICING_ADD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD();
    //             T_PRICING_ADD.POSNR = '000010';
    //             T_PRICING_ADD.KSCHL = 'ZPRC';
    //             T_PRICING_ADD.KWERT = String.valueOf(selPro.SpecialAmount__c);
    //             T_PRICING_ADD.WAERK = selPro.CurrencyIsoCode;
    //             T_PRICING_ADD_LIST.add(T_PRICING_ADD);
    //         } else if(selPro.Type__c == 'Special') {
    //             IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND T_MULTICOND = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND();
    //             T_MULTICOND.CHAK    = 'X';
    //             T_MULTICOND.VARCOND = selPro.Key__c;
    //             T_MULTICOND.KWERT   = String.valueOf(selPro.SpecialAmount__c);
    //             T_MULTICOND.WAERK   = selPro.CurrencyIsoCode;
    //             T_MULTICOND_LIST.add(T_MULTICOND);
    //         }else {
    //             IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND T_MULTICOND = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND();
    //             T_MULTICOND.CHAK    = 'X';
    //             T_MULTICOND.VARCOND = selPro.Key__c;
    //             if(selPro.IsAuto__c) { T_MULTICOND.KBETR = String.valueOf(selPro.Rate__c); }
    //             else { T_MULTICOND.KWERT = String.valueOf(selPro.Amount__c); }
    //             T_MULTICOND.WAERK = selPro.CurrencyIsoCode;
    //             T_MULTICOND_LIST.add(T_MULTICOND);
    //         }
    //     }

    //     if(
    //         (isGlobal || order.SalesChannelType__c == ordSvc.SEG_WHOLESALE) 
    //         && prodItems.AdjustmentPrice__c != 0 && prodItems.AdjustmentPrice__c != null
    //     ) {
    //         IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD T_PRICING_ADD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD();
    //         T_PRICING_ADD.POSNR = '000010';
    //         T_PRICING_ADD.KSCHL = 'ZVPA';
    //         T_PRICING_ADD.KWERT = String.valueOf(prodItems.AdjustmentPrice__c);
    //         T_PRICING_ADD.WAERK = order.CurrencyIsoCode;
    //         T_PRICING_ADD_LIST.add(T_PRICING_ADD);
    //     }

    //     if(isGlobal && order.DealerCommission__c != null && order.DealerCommission__c != 0) {
    //         IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD T_PRICING_ADD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD();
    //         T_PRICING_ADD.POSNR = '000010';
    //         T_PRICING_ADD.KSCHL = 'ZSXB';
    //         T_PRICING_ADD.KWERT = String.valueOf(order.DealerCommission__c);
    //         T_PRICING_ADD.WAERK = order.CurrencyIsoCode;
    //         T_PRICING_ADD_LIST.add(T_PRICING_ADD);
    //     }
        
    //     // T_ADD_DATA
    //     List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ADD_DATA> T_ADD_DATA_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ADD_DATA>();
    //     IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ADD_DATA T_ADD_DATA = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ADD_DATA();
    //     T_ADD_DATA.ZFMAINP = order.Contractor__c;
    //     T_ADD_DATA.ZFLASTP = order.EndUser__c;
    //     T_ADD_DATA_LIST.add(T_ADD_DATA);

    //     IF_ERP_Order_Classes.IF_ORDER_001_Req wrapper_ORDER_001 = new IF_ERP_Order_Classes.IF_ORDER_001_Req();
    //     wrapper_ORDER_001.I_REF_ORDER   = erpQuoteNo;
    //     wrapper_ORDER_001.I_GUBUN       = 'C'; // 'C' = Create, 'U' = Change, 'D' = Delete
    //     wrapper_ORDER_001.I_TESTRUN     = '';
    //     wrapper_ORDER_001.I_STATUS      = order.OverallStatus__c;
    //     wrapper_ORDER_001.I_EXPORT      = order.IsExport__c == 'Y' ? 'X' : ''; // Export or not : X means Export
    //     wrapper_ORDER_001.I_LAND1       = order.ExportTo__c;
    //     wrapper_ORDER_001.I_SPDC        = order.HasSpecialDC__c;
    //     if(order.OrderSegmentation__c != ordSvc.SEG_DIRECTSALES) { wrapper_ORDER_001.I_ZZKVGR4 = order.SalesRep__r.DealerGrade__c; }

    //     wrapper_ORDER_001.I_USERINFO    = I_USERINFO;
    //     wrapper_ORDER_001.I_HEAD        = I_HEAD;
    //     wrapper_ORDER_001.I_GENERAL     = I_GENERAL;
    //     wrapper_ORDER_001.I_PARTNER     = I_PARTNER;
    //     wrapper_ORDER_001.I_COLLECTION  = I_COLLECTION;
    //     // wrapper_ORDER_001.I_WARRANT_OPT = I_WARRANT_OPT;
    //     wrapper_ORDER_001.I_NOTE        = I_NOTE;
    //     wrapper_ORDER_001.I_COM_DEALER  = I_COM_DEALER;
    //     wrapper_ORDER_001.T_ITEM        = T_ITEM_LIST;
    //     wrapper_ORDER_001.T_CONFIG      = T_CONFIG_LIST;
    //     wrapper_ORDER_001.T_SEL_CONFIG  = T_SEL_CONFIG_LIST;
    //     wrapper_ORDER_001.T_PRICING_ADD = T_PRICING_ADD_LIST;
    //     wrapper_ORDER_001.T_ADD_DATA    = T_ADD_DATA_LIST;
    //     wrapper_ORDER_001.T_MULTICOND   = T_MULTICOND_LIST;

    //     // 250213 warranty 필드 변경
    //     String warrantyVTWEG = isGlobal ? '20' : '10';
    //     List<Warranty__c> warrantyList = [
    //         SELECT  Id, ZZWARRPER__c, ZZPERUNIT__c, ZZWARHRS__c, ZZPR_WAR__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c
    //         FROM    Warranty__c 
    //         WHERE   VTWEG__c = :warrantyVTWEG
    //         AND     ZZPR_WAR__c = : order.Warranty__c
    //     ];

    //     if(!warrantyList.isEmpty()) {
    //         Warranty__c warr = warrantyList[0];
    //         wrapper_ORDER_001.I_ZZWARRPER  = warr.ZZWARRPER__c;
    //         wrapper_ORDER_001.I_ZZPERUNIT    = warr.ZZPERUNIT__c;
    //         wrapper_ORDER_001.I_ZZWARHRS     = warr.ZZWARHRS__c;
    //         wrapper_ORDER_001.I_ZZPR_WAR     = warr.ZZPR_WAR__c;
    //         wrapper_ORDER_001.I_ZZCOVERAGE   = warr.ZZCOVERAGE__c;
    //         wrapper_ORDER_001.I_ZZCOVERAGE_B = warr.ZZCOVERAGE_B__c;
    //     }

    //     IF_ERP_Order Obj_ORDER_001 = new IF_ERP_Order();
    //     IF_ERP_Order_Classes.IF_ORDER_001_Res response = Obj_ORDER_001.IF_ORDER_001(wrapper_ORDER_001);
        
    //     return response;
    // }

    // public static IF_ERP_Order_Classes.IF_ORDER_021_Res callCVPriceIF(String orderId, String erpNo) {
    //     System.debug('callCVPriceIF ::: ' + orderId + ' / ' + erpNo);

    //     OrderItem oItem = [SELECT Id FROM OrderItem WHERE OrderId =: orderId AND ItemCategory__c =: ordSvc.ITEM_PRODUCT];
    //     System.debug('callCVPriceIF - oItem ::: ' + oItem);

    //     List<CVOrderItem__c> cvList = [SELECT Id, F_CCode__c, F_VCode__c FROM CVOrderItem__c WHERE OrderProduct__c =: oItem.Id];
    //     System.debug('callCVPriceIF - cvList ::: ' + cvList);

    //     List<IF_ERP_Order_Classes.IF_ORDER_021_Req_T_VARIANT> T_VARIANT_LIST= new List<IF_ERP_Order_Classes.IF_ORDER_021_Req_T_VARIANT>();
    //     for(CVOrderItem__c cv : cvList) {

    //         IF_ERP_Order_Classes.IF_ORDER_021_Req_T_VARIANT T_VARIANT = new IF_ERP_Order_Classes.IF_ORDER_021_Req_T_VARIANT();
    //         T_VARIANT.POSNR = '000010'; // FIXED
    //         T_VARIANT.ATNAM = cv.F_CCode__c;
    //         T_VARIANT.ATWRT = cv.F_VCode__c;
    //         T_VARIANT_LIST.add(T_VARIANT);
    //     }

    //     IF_ERP_Order_Classes.IF_ORDER_021_Req request = new IF_ERP_Order_Classes.IF_ORDER_021_Req();
    //     request.I_VBELN   = erpNo;
    //     request.T_VARIANT = T_VARIANT_LIST;

    //     IF_ERP_Order rfc021 = new IF_ERP_Order();
    //     IF_ERP_Order_Classes.IF_ORDER_021_Res response = rfc021.IF_ORDER_021(request);

    //     return response;
    // }

    

    // private static void mappingCVPriceInfo(String orderId, IF_ERP_Order_Classes.IF_ORDER_021_Res response) {
    //     System.debug('mappingCVPriceInfo');

    //     Map<String, PriceWrapper> priceMap = new Map<String, PriceWrapper>();

    //     for(IF_ERP_Order_Classes.IF_ORDER_021_Res_T_PRICING T_PRICING : response.T_PRICING) {
    //         System.debug('mappingCVPriceInfo - T_PRICING ::: ' + T_PRICING);
    //         PriceWrapper innerWrap = priceMap.containsKey(T_PRICING.POSNR) ? priceMap.get(T_PRICING.POSNR) : new PriceWrapper();
    //         innerWrap.posnr = T_PRICING.POSNR;
            
    //         if(T_PRICING.KSCHL == 'ZSUM') {
    //             innerWrap.price = Decimal.valueOf(T_PRICING.KWERT);
    //         } else if (T_PRICING.KSCHL == 'MWST') {
    //             innerWrap.tax   = Decimal.valueOf(T_PRICING.KWERT);
    //         }
            
    //         priceMap.put(T_PRICING.POSNR, innerWrap);
    //     }
    //     System.debug('mappingCVPriceInfo - priceMap ::: ' + priceMap);
            
    //     Order order = [SELECT Id, SalesChannelType__c FROM Order WHERE Id =:orderId];
            
    //     Decimal cvSum = 0;
    //     if(ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c)) {
    //         Map<String, Decimal> cvMap = new Map<String, Decimal>();

    //         System.debug('mappingCVPriceInfo - response.T_COND_EX ::: ' + response.T_COND_EX);
    //         for(IF_ERP_Order_Classes.IF_ORDER_021_Res_T_COND_EX T_COND_EX : response.T_COND_EX) {

    //             if(T_COND_EX.COND_TYPE == 'ZVA1') {
    //                 Decimal cvPrice = Decimal.valueOf(T_COND_EX.CONDVALUE);
    //                 cvMap.put(T_COND_EX.VARCOND, cvPrice);
    //                 cvSum += cvPrice;
    //             }
    //         }

    //         List<CVOrderItem__c> cvList = [SELECT Id, CharacteristicValue__c, F_CCode__c, F_VCode__c, F_Price__c FROM CVOrderItem__c WHERE OrderProduct__r.OrderId =: orderId];
            
    //         List<CharacteristicValue__c> toUpdateCVs = new List<CharacteristicValue__c>();
    //         for(CVOrderItem__c cv : cvList) {
    //             String cvKey = cv.F_CCode__c + '-' + cv.F_VCode__c;
    //             Decimal newPrice = cvMap.containsKey(cvKey) ? cvMap.get(cvKey) : 0;
    //             System.debug('mappingCVPriceInfo - cvList ::: ' + cvKey + ' / ' + newPrice + ' / ' + cv.F_Price__c);
    //             if(cv.F_Price__c != newPrice) { 
    //                 CharacteristicValue__c newCV = new CharacteristicValue__c();
    //                 newCV.Id       = cv.CharacteristicValue__c;
    //                 newCV.Price__c = newPrice;
    //                 toUpdateCVs.add(newCV); 
    //             }
    //         }
    //         System.debug('mappingCVPriceInfo - toUpdateCVs ::: ' + toUpdateCVs);
    //         if(!toUpdateCVs.isEmpty()) { update toUpdateCVs; }
    //     }

    //     List<OrderItem> orderItems = [SELECT Id, IF_POSNR__c, Quantity, UnitPrice, Tax__c, ItemCategory__c FROM OrderItem WHERE OrderId =: orderId];
    //     System.debug('mappingCVPriceInfo - orderItems ::: ' + orderItems);
    //     List<OrderItem> toUpdateItems = new List<OrderItem>();
    //     for(OrderItem item : orderItems) {
    //         String posnr = ordSvc.formatCodeForSAP(6, item.IF_POSNR__c);
            
    //         if(priceMap.containsKey(posnr)) {
    //             PriceWrapper innerWrap = priceMap.get(posnr);
                
    //             Decimal tempPrice = innerWrap.price ?? 0;
    //             Decimal tempTax   = innerWrap.tax ?? 0;
            
    //             if(item.Quantity > 1 && tempPrice > 0) {
    //                 tempPrice = (tempPrice / item.Quantity).setScale(2, System.RoundingMode.HALF_UP);
    //                 tempTax   = (tempTax / item.Quantity).setScale(2, System.RoundingMode.HALF_UP);
    //             }
            
    //             item.UnitPrice      = tempPrice;
    //             item.Tax__c         = tempTax;
    //             item.IF_FreePass__c = true;
            
    //             if(item.ItemCategory__c == ordSvc.ITEM_PRODUCT) { 
    //                 item.CVSummary__c = cvSum; 
    //             }

    //             toUpdateItems.add(item);
    //         }
    //     }
    //     System.debug('mappingCVPriceInfo - toUpdateItems ::: ' + toUpdateItems);
    //     if(!toUpdateItems.isEmpty()) { update toUpdateItems; }
            
    // }

    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess  {get;set;}
        @AuraEnabled public String  errMessage {get;set;}

        @AuraEnabled public Map<String, Object> data {get;set;}
        
        public ResultWrapper(){
            this.isSuccess  = true;
            this.errMessage = '';
            this.data = new Map<String, Object>();
        }
    }

    public class PriceWrapper{
        public String  posnr    {get;set;}
        public Decimal price    {get;set;}
        public Decimal tax      {get;set;}
        
        public PriceWrapper(){}
    }


    // ============ Service ===========================================================================================

    /**
    * @description  Order와 연결 된 Opportunity가 Closed이고, 
                    Order의 Status가 'Order Create'일 때 버튼 클릭 가능
                    (= ERP에 전송한 적 없을 때 / Service(CS) 전용)
    * @author Suheon.Ha | 2025-01-12 
    * @param orderId
    * @return ResultWrapper 
    **/
    @AuraEnabled
    public static ResultWrapper serviceValidateOrderConfrim(String orderId){
        ResultWrapper result = new ResultWrapper();
        System.debug('serviceValidateOrderConfrim - orderId ::: ' + orderId);

        try {
            Order order = [SELECT Id, OrderNumber, Status, OpportunityId, Opportunity.StageName, HasPricingProcessed__c, HasScheduleCompleted__c FROM Order WHERE Id =: orderId];
            Opportunity opty = [SELECT Id, StageName FROM Opportunity WHERE Id =: order.OpportunityId WITH SECURITY_ENFORCED];

            List<String> pickValues = ordSvc.getPicklist('Order', 'Status');
            pickValues.remove(pickValues.indexOf(ordSvc.ORDER_CREATE));
            pickValues.remove(pickValues.indexOf(ordSvc.ORDER_PROGRESS));

            List<PaymentSchedule__c> psList = [SELECT Id, DraftCheck__c FROM PaymentSchedule__c WHERE Order__c =: orderId];

            // if(order.Status == ordSvc.ORDER_PROGRESS) {
            //     result.isSuccess  = false;
            //     result.errMessage = System.Label.DNS_M_AlreadyRequested; // This order has already been requested for confirmation.
            // } else if(opty.StageName != 'Closed Won') { // SLS-ORD-023
            //     result.isSuccess  = false;
            //     result.errMessage = System.Label.DNS_M_RequestOptyClosed; // Please close the associated Opportunity to proceed with the order confirmation.
            // }
        } catch (Exception e) {
            System.debug('serviceValidateOrderConfrim : ' + e.getLineNumber() + ' / ' + e.getMessage());
            result.isSuccess  = false;
            result.errMessage = e.getMessage();
        }
        return result;
    }
    /**
    * @description QuoteLineItems의 RecordType가 Service Package면 ServicePackageProduct__c생성
    * @author Suheon.Ha | 2024-12-19 
    * @param  
    **/
    public static void createServicePackage(List<Order> orderList) {
        Set<Id> quoteIdSet = new Set<Id>();
        Map<Id, Order> orderMap = new Map<Id, Order>(); // Order Id -> Order 매핑
        for (Order ord : orderList) {
            if (ord.QuoteId != null) {
                quoteIdSet.add(ord.QuoteId);
            }
            orderMap.put(ord.Id, ord);
        }
    
        if (quoteIdSet.isEmpty()) {
            System.debug('quoteIdSet:::' + quoteIdSet);
            return;
        }
    
        // QuoteLineItem과 Product2 정보 조회
        List<QuoteLineItem> qliList = [
            SELECT Id, QuoteId, Product2Id, Product2.Name, Quote.EquipmentId__c
            FROM QuoteLineItem
            WHERE QuoteId IN :quoteIdSet
            AND Product2.RecordType.Name = 'Service Package'
        ];
    
        System.debug('qliList size ::: ' + qliList.size());
    
        if (!qliList.isEmpty()) {
            List<ServicePackageProduct__c> sppList = new List<ServicePackageProduct__c>();
    
            for (QuoteLineItem qli : qliList) {
                // qli의 QuoteId로 Order 찾기
                Order order;
                for (Order ord : orderList) {
                    if (ord.QuoteId == qli.QuoteId) {
                        order = ord;
                        break;
                    }
                }

                ServicePackageProduct__c spp = new ServicePackageProduct__c();
                spp.Name = qli.Product2.Name;
                spp.Product__c = qli.Product2Id;
                spp.Equipments__c = qli.Quote.EquipmentId__c;
                spp.Order__c = order.Id;
                spp.StartServiceDate__c = order.ReqDeliveryDate_PSO__c;
                sppList.add(spp);
            }
    
            if (!sppList.isEmpty()) {
                // insert sppList;
                System.debug('Inserted sppList:::' + sppList);

                // 2025-05-28 서영덕 장비와 연결된 ServicePackage 생성 시 장비의 IsPurchaseServicePackage__c를 True로 업데이트트
                Set<String> successSppIds = new Set<String>();
                Database.SaveResult[] srList = Database.insert(sppList);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        successSppIds.add(sr.getId());
                    }
                }

                if (successSppIds.size() > 0) {
                    Set<String> sppAssetIds = new Set<String>();
                    List<ServicePackageProduct__c> successSppList = [SELECT Id, Equipments__c FROM ServicePackageProduct__c WHERE Id IN :successSppIds AND Equipments__c != null AND Equipments__r.IsPurchaseServicePackage__c = false];

                    for (ServicePackageProduct__c sp : successSppList) {
                        sppAssetIds.add(sp.Equipments__c);
                    }

                    List<Asset> equipmentList = [SELECT Id FROM Asset WHERE Id IN :sppAssetIds];
                    
                    List<Asset> updateEquipmentList = new List<Asset>();
                    for (Asset asset :equipmentList) {
                        asset.IsPurchaseServicePackage__c = true;
                        updateEquipmentList.add(asset);
                    }

                    TriggerHandler.bypass('AssetTriggerHandler');
                    if (updateEquipmentList.size() > 0) update updateEquipmentList;
                    TriggerHandler.clearBypass('AssetTriggerHandler');

                }
            }
        } else {
            System.debug('RecordType Service Package가 있는 QuoteLineItems를 찾을 수 없습니다.');
        }
    }
    /**
    * @description Order Create > Order Confirmation in Progress, CRM > ERP I/F 호출 
    * @author Suheon.Ha | 2025-01-12 
    * @return ResultWrapper 
    **/
    @AuraEnabled
    public static ResultWrapper serviceRequestConfrim(String orderId) {
        SavePoint sp;
        ResultWrapper result = new ResultWrapper();
        
        try {
            // Order 조회
            Order order = [
                SELECT Id, ServiceOpportunityType__c, OpportunityId, Opportunity.Equipment__r.WarrantyEndWages__c, Opportunity.Equipment__r.WarrantyEnd__c
                FROM Order 
                WHERE Id = :orderId 
                ORDER BY CreatedDate DESC 
                LIMIT 1
            ];

            List<Order> orderList = [
                SELECT Id, ServiceOpportunityType__c, OpportunityId, Opportunity.Equipment__r.WarrantyEndWages__c, Opportunity.Equipment__r.WarrantyEnd__c, QuoteId, ReqDeliveryDate_PSO__c
                FROM Order 
                WHERE Id = :orderId 
                ORDER BY CreatedDate DESC 
                LIMIT 1
            ];

            // OrderItem 추가 : 2025.03.26
            List<OrderItem> oitemList = 
            [
                SELECT Id, Product2Id, OrderId, Product2.EquipmentGuarantee__c, Product2.PartsGuarantee__c
                FROM OrderItem
                WHERE OrderId =: orderId
                AND Product2.ServicePackage__c = '보증연장'
            ];
            OrderItem oitem = (oitemList.isEmpty()) ? null : oitemList[0];
            
            if (order.ServiceOpportunityType__c == 'Parts' || order.ServiceOpportunityType__c == 'Spindle') {
                System.debug('Parts or Spindle');
                IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res res = servicePartOrderIF(orderId);
                System.debug('res ::: ' + res);
                System.debug('res ::: ' + JSON.serialize(res));
                sp = Database.setSavePoint();
            
                String errorMessage = null;
                for (IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res_LT_BAPIRET2 err : res.LT_BAPIRET2) {
                    if (err.TYPE == 'E') {
                        errorMessage = err.MESSAGE;
                        System.debug('requestConfrim - response error : ' + err.MESSAGE);
                        AuraHandledException e = new AuraHandledException('error');
                        e.setMessage(err.MESSAGE);
                        throw e;
                        // break; // 첫 번째 에러 메시지만 사용
                    }
                }
            
                // if (errorMessage != null) {
                //     System.debug('requestConfrim - res error : ' + errorMessage);
                //     Database.rollback(sp); // 상태 변경 방지
                //     throw new AuraHandledException(errorMessage); // 예외 던지기
                // }

                // if (response.O_RETURN.TYPE == 'E') {
                //     System.debug('requestConfrim - response error : ' + response.O_RETURN.MESSAGE);
                //     AuraHandledException e = new AuraHandledException('error');
                //     e.setMessage(response.O_RETURN.MESSAGE);
                //     throw e;
                // } 
            
                order.Status         = ordSvc.ORDER_PROGRESS;
                order.ERPOrderNo__c  = res.LV_VENLR;
                order.IF_FreePass__c = true;
                update order;
            // } else if (order.ServiceOpportunityType__c == 'Others') {
            } else {
                System.debug('Others');
                IF_ERP_Order_Classes.IF_ORDER_001_Res response = serviceCallOrderCreationIF(orderId);
                System.debug('response ::: ' + response);
                sp = Database.setSavePoint();
                
                if (response.O_RETURN.TYPE == 'E') {
                    System.debug('requestConfrim - response error : ' + response.O_RETURN.MESSAGE);
                    AuraHandledException e = new AuraHandledException('error');
                    e.setMessage(response.O_RETURN.MESSAGE);
                    throw e;
                } 
    
                order.Status         = ordSvc.ORDER_PROGRESS;
                order.ERPOrderNo__c  = response.O_VBELN;
                order.IF_FreePass__c = true;
                update order;
    
                mappingPriceInfo(orderId, response); // Mapping Price
            }

            if(order.ERPOrderNo__c != null) {
                // OrderItem 추가 : 2025.03.26
                // 보증연장 Product 가 존재시
                if(oitem != null) {
                    Asset equipment = order.Opportunity.Equipment__r;
                    Date laborEnd = order.Opportunity.Equipment__r.WarrantyEndWages__c;
                    Date partsEnd = order.Opportunity.Equipment__r.WarrantyEnd__c;
                    String laborGuarantee = oitem.Product2.EquipmentGuarantee__c;
                    String partsGuarantee = oitem.Product2.PartsGuarantee__c;
                    if(laborEnd != null) {
                        if(!String.isEmpty(laborGuarantee)) {
                            Integer lg = Integer.valueOf(laborGuarantee.replaceAll('[^0-9]', ''));
                            laborEnd = laborEnd.addMonths(lg);
                            equipment.WarrantyEndWages__c = laborEnd;
                        }
                    }
                    if(partsEnd != null) {
                        if(!String.isEmpty(partsGuarantee)) {
                            Integer pg = Integer.valueOf(partsGuarantee.replaceAll('[^0-9]', ''));
                            partsEnd = partsEnd.addMonths(pg);
                            equipment.WarrantyEnd__c = partsEnd;
                        }
                    }
                    update equipment;
                    System.debug('Updated Equipment : ' + equipment);
                }

                if(orderList != null || orderList.size() > 0) {
                    createServicePackage(orderList);
                }
            }
            result.isSuccess = true;
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('requestConfrim : ' + e.getLineNumber() + ' / ' + e.getMessage());
            result.isSuccess  = false;
            result.errMessage = e.getMessage();
        }
    
        return result;
    }
    
    // YDOR 오더 I/F 호출
    public static IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res servicePartOrderIF(String orderId) {
        List<OrderItem> orderItems = [
            SELECT Id, OrderId, Order.Account.ShippingCity, Order.Account.Name, Order.OrderReason__c,
                   Order.Account.ShippingPostalCode, Order.Account.ShippingStreet, 
                   Order.Account.Representative__c, Order.Account.Phone, 
                   Order.SoldTo__r.DistributionChannel__c, Order.SoldTo__r.Division__c,
                   Order.Account.CustomerCode__c, Product2.Name, Quantity, Product2.ProductCode,
                   Order.DistributionChannel__c, Order.SalesOrganization__c, Order.OrderType__c, Order.Division__c
            FROM OrderItem
            WHERE OrderId = :orderId
        ];
        
        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req();
        req.I_LANGU = 'ko';
        
        if (!orderItems.isEmpty()) {
            OrderItem orderItem = orderItems[0]; // 첫 번째 OrderItem을 사용하여 Order 관련 데이터 가져오기
            req.LV_AUART = 'YDOR'; // 오더 유형
            req.I_VKORG = '1846';
            req.I_VTWEG = orderItem.Order.SoldTo__r.DistributionChannel__c;
            req.I_SPART = orderItem.Order.SoldTo__r.Division__c;
            req.I_KUNNR = orderItem.Order.Account.CustomerCode__c; // 딜러코드        
    
            // 주소 입력(수기)
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_EP_ONETIME LS_EP_ONETIME = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_EP_ONETIME();
            LS_EP_ONETIME.CITY = orderItem.Order.Account.ShippingCity; // 도시
            LS_EP_ONETIME.NAME = orderItem.Order.Account.Name; // 고객사 이름
            LS_EP_ONETIME.POSTL_CODE = orderItem.Order.Account.ShippingPostalCode; // 우편 번호
            LS_EP_ONETIME.STREET = orderItem.Order.Account.ShippingStreet; // 상세 주소
            LS_EP_ONETIME.NAME_2 = orderItem.Order.Account.Representative__c; // 담당자 이름
            LS_EP_ONETIME.TELEPHONE = orderItem.Order.Account.Phone; // 담당자 전화번호
            req.LS_EP_ONETIME = LS_EP_ONETIME;
    
            // 배송처 선택시
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_MAIN_HEAD LS_MAIN_HEAD = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_MAIN_HEAD();
            LS_MAIN_HEAD.KONDA = '28'; // 일반-28, 긴급-20, 스톡-40
            LS_MAIN_HEAD.KUNNR = orderItem.Order.Account.CustomerCode__c; // 고객 코드
            LS_MAIN_HEAD.KUNAG = orderItem.Order.Account.CustomerCode__c; // 딜러코드
            LS_MAIN_HEAD.KVGR5 = '40'; // 딜러부서
            LS_MAIN_HEAD.ORD_REASON = orderItem.Order.OrderReason__c; // OrderReason

            req.LS_MAIN_HEAD = LS_MAIN_HEAD;

            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_GENERAL LS_GENERAL = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LS_GENERAL();
            LS_GENERAL.BSTNK            = orderItem.Order.Account.CustomerCode__c;                       // 고객주문번호
            // LS_GENERAL.COMPLETE_DELIVERY= orderItem.consolidatedShipping == 'YES' ? 'X' : ''; //일괄배송 여부
            // LS_GENERAL.INCO1            = orderItem.shippingInfo.transportationTermOne;    // 배송조건 1
            // LS_GENERAL.INCO2            = orderItem.shippingInfo.transportationTermTwo;    // 배송조건 2
            // LS_GENERAL.VDATU            = String.valueOf(orderItem.shippingInfo.requestedDeliveryDate);  // 요청날짜
            // LS_GENERAL.VSBED            = orderItem.shippingInfo.shippingCode;             // 배송조건 아이디 (택배, 트럭, 퀵, 수령)
        
            req.LS_GENERAL              = LS_GENERAL;
        
            // ??
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_I_ORG I_ORG = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_I_ORG();
            req.I_ORG                   = I_ORG;

            List<IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_GERNERAL_ZTERM> LT_GERNERAL_ZTERM_List = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_GERNERAL_ZTERM>();
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_GERNERAL_ZTERM LT_GERNERAL_ZTERM = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_GERNERAL_ZTERM();
            // LT_GERNERAL_ZTERM.ZTERM     = orderItem.shippingInfo.paymentTerm2;
        
            LT_GERNERAL_ZTERM_List.add(LT_GERNERAL_ZTERM);
            req.LT_GERNERAL_ZTERM = LT_GERNERAL_ZTERM_List;
        }
        
        // parts List 생성
        List<IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_ITEM> LT_ITEM_List = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_ITEM>();
        Integer posnrItemIndex = 10;
        
        for (OrderItem item : orderItems) {
            IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_ITEM re = new IF_ERP_Parts_Order_Classes.IF_PARTS_005_Req_LT_ITEM();
            re.ITEM = String.valueOf(posnrItemIndex).leftPad(6, '0');
            posnrItemIndex += 10;
            re.MATERIAL = item.Product2.Name; // 주문품번
            re.QTY = String.valueOf(item.Quantity); // 수량 (Decimal → String 변환)
            re.REQ_QTY = String.valueOf(item.Quantity); // 수량2 (Decimal → String 변환)
            re.ZZEQMASTER = item.Product2.ProductCode; // 장비번호
            
            LT_ITEM_List.add(re);
        }
        
        req.LT_ITEM = LT_ITEM_List;
        System.debug('req:::' + JSON.serialize(req));
        IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
        IF_ERP_Parts_Order_Classes.IF_PARTS_005_Res result = instance.IF_PARTS_005(req);
        System.debug('result:::' + JSON.serialize(result));
        // String req = result.LV_VENLR;
        return result;
    }
    

    /**
    * @description 
    * @author Suheon.Ha | 2024-12-09 
    * @param orderId 
    * @return IF_ERP_Order_Classes.IF_ORDER_001_Res 
    String orderId = '801F7000001RVEyIAO'; // test
    IF_ERP_Order_Classes.IF_ORDER_001_Res response = DN_OrderConfirmRequestController.callOrderCreationIF(orderId);
    System.debug('test0001 : ' + response);
    **/
    public static IF_ERP_Order_Classes.IF_ORDER_001_Res serviceCallOrderCreationIF(String orderId){

        Order order = [
            SELECT  Id
                    , OwnerId, Owner__r.CustomerCode__c, Owner__r.Account.CustomerCode__c, Owner__r.SalesDistrict__c
                    , Owner__r.Account.Name, Owner__r.Name, Owner__r.ERP_Key__c

                    , SalesOrganization__c, DistributionChannel__c, Division__c, SalesOffice__c

                    , CreatedDate, ReqDeliveryDate_PSO__c
                    , CurrencyIsoCode
                    , IsExport__c, ExportTo__c
                    , OrderType__c
                    , Description
                    , OverallStatus__c
                    , HasSpecialDC__c
                    , CustomerOrderNo__c
                    , Incoterms__c
                    , PaymentTerms__c
                    , PurchaseType__c
                    , Contractor__c
                    , EndUser__c
                    , MainCategory__c
                    , SubCategory__c
                    , IsTooling__c
                    , PriceList__c
                    , ShippingConditions__c
                    , DealerCommission__c
                    , Warranty__c
                    , Vendor__c
                    , OrderSegmentation__c
                    , SalesChannelType__c
                    , OrderReason__c
                    , SoldTo__r.DistributionChannel__c
                    , SoldTo__r.Division__c
                    , Opportunity.ERP_Inquiry_No__c

                    , Account.Name, Account.SalesDistrict__c, Account.CustomerCode__c
                    , SoldTo__c,        SoldTo__r.Name,   SoldTo__r.CustomerCode__c
                    , ShipTo_PSO__c,        ShipTo__r.Name,   ShipTo__r.CustomerCode__c
                    , BillTo__c,        BillTo__r.Name,   BillTo__r.CustomerCode__c
                    , Payer__c,         Payer__r.Name,    Payer__r.CustomerCode__c
                    , SalesRep__c,      SalesRep__r.Name
                    , CreditDealer__c,  CreditDealer__r.Name
                    , ServiceDealer__c, ServiceDealer__r.Name

                    , ERPOrderNo__c
                    , Quote.Account.AccountGroup__c
                    , ServiceOpportunityType__c
                    
            FROM    Order
            WHERE   Id = : orderId
        ];
        System.debug('callOrderCreationIF - order ::: ' + order);

        List<OrderItem> items = [
            SELECT  Id
                    , Quantity
                    , CurrencyIsoCode
                    , IF_POSNR__c
                    , UnitPrice
                    , TotalPrice
                    , StandardPrice__c
                    , ItemCategory__c
                    , CSTotalPrice__c
                    , Unit__c
                    , Product2.ProductCode, Product2.Name, Product2.Name__c, Product2.Plant__c
                    , SQ__c, SQ__r.Name, SQ__r.SQCode__c, F_SQStage__c
                    , QuoteLineItemId, QuoteLineItem.ERPQuotationNo__c
                    , Accessory__r.Name, Accessory__r.Description__c
            FROM    OrderItem
            WHERE   OrderId =: orderId
        ];
        System.debug('callOrderCreationIF - items ::: ' + items);

        Map<Id, Boolean> userTypeMap = ordSvc.getUserFlag(new Set<Id>{order.OwnerId});
        Boolean isCRMUser = userTypeMap.get(order.OwnerId);
        Boolean isGlobal  = order.SalesChannelType__c == ordSvc.CHANNER_OVERSEAS;

        String customerCode = isCRMUser ? ordSvc.formatCodeForSAP(10, order.Owner__r.CustomerCode__c) : ordSvc.formatCodeForSAP(10, order.Owner__r.Account.CustomerCode__c);
        String customerName = isCRMUser ? order.Owner__r.Name : order.Owner__r.Account.Name;
        System.debug('callOrderCreationIF - values isCRMUser : ' + isCRMUser + ' , customerCode : ' + customerCode);

        // I_USERINFO
        IF_ERP_Order_Classes.IF_ORDER_001_Req_I_USERINFO I_USERINFO = new  IF_ERP_Order_Classes.IF_ORDER_001_Req_I_USERINFO();
        I_USERINFO.BNAME = order.OwnerId;
        I_USERINFO.RNAME = ordSvc.formatCodeForSAP(12, String.valueOf(order.Owner__r.ERP_Key__c));
        I_USERINFO.HIER  = 'A';
        I_USERINFO.KUNNR = customerCode;
        I_USERINFO.VKORG = '1800';
        // I_USERINFO.VKORG = order.SalesOrganization__c;

        // I_HEAD
        IF_ERP_Order_Classes.IF_ORDER_001_Req_I_HEAD I_HEAD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_HEAD();
        I_HEAD.AUART = 'ZCS'; // REQUIRED
        I_HEAD.VKORG = '1800'; // REQUIRED
        // I_HEAD.VKORG = order.SalesOrganization__c; // REQUIRED
        I_HEAD.VTWEG = order.SoldTo__r.DistributionChannel__c; // REQUIRED
        I_HEAD.SPART = order.SoldTo__r.Division__c; // REQUIRED
        I_HEAD.KUNNR = ordSvc.formatCodeForSAP(10, order.SoldTo__r.CustomerCode__c); // REQUIRED
        I_HEAD.KUNAG = ordSvc.formatCodeForSAP(10, order.ShipTo__r.CustomerCode__c); // REQUIRED
        I_HEAD.VKBUR = '';
        // I_HEAD.VKBUR = order.SalesOffice__c;

        // T_ITEM
        Id itemId;
        String erpQuoteNo;
        Boolean hasSQ = false;
        List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM> T_ITEM_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM>();
        List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD> T_PRICING_ADD_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD>();
        Integer posnrItemIndex = 10;
        Integer posnrPriceIndex = 10;
        for(OrderItem item : items) {
            IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM T_ITEM = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM();
            if(item.ItemCategory__c == ordSvc.ITEM_PRODUCT) {
                T_ITEM.MATNR  = item.Product2.ProductCode;
                T_ITEM.ARKTX  = item.Product2.Name__c;
                T_ITEM.WERKS  = item.Product2.Plant__c;

                itemId     = item.Id;
                erpQuoteNo = item.QuoteLineItem.ERPQuotationNo__c;
            } else if(item.ItemCategory__c == ordSvc.ITEM_SQ) {
                hasSQ = true;
                T_ITEM.MATNR     = 'SQ100';
                T_ITEM.ZZSQCOD   = item.SQ__r.SQCode__c;
                T_ITEM.ZZSQTITLE = item.SQ__r.Name;

            } else if(item.ItemCategory__c == ordSvc.ITEM_ACCESSORY) {
                T_ITEM.MATNR = item.Accessory__r.Name;
                T_ITEM.ARKTX = item.Accessory__r.Description__c;
            }
            // T_ITEM.POSNR  = item.IF_POSNR__c;
            T_ITEM.POSNR  = String.valueOf(posnrItemIndex).leftPad(6, '0');
            posnrItemIndex += 10;
            T_ITEM.KWMENG = Integer.valueOf(item.Quantity) + '.000';
            T_ITEM.VRKME  = item.Unit__c;
            T_ITEM.NETPR  = String.valueOf(item.CSTotalPrice__c);

            T_ITEM_LIST.add(T_ITEM);

            // T_PRICING
            IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD T_PRICING_ADD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD();
            // T_PRICING.POSNR = String.valueOf(posnrPriceIndex).leftPad(6, '0');
            // posnrPriceIndex += 10;
            // T_PRICING.KWMENG = Integer.valueOf(item.Quantity) + '.000';
            // T_PRICING.VRKME = item.Unit__c;
            // T_PRICING.KWERT = String.valueOf(item.TotalPrice);
            // T_PRICING.WAERK = item.CurrencyIsoCode;
            // T_PRICING.KSCHL = 'ZSUM';
            
            // T_PRICING_LIST.add(T_PRICING);

            T_PRICING_ADD.POSNR = String.valueOf(posnrPriceIndex).leftPad(6, '0');
            posnrPriceIndex += 10;
            // T_PRICING_ADD.KSCHL = 'ZSUM';
            // T_PRICING_ADD.KSCHL = 'ZRPP';
            T_PRICING_ADD.KSCHL = 'ZRSP';
            T_PRICING_ADD.KWERT = String.valueOf(item.CSTotalPrice__c);
            T_PRICING_ADD.WAERK = item.CurrencyIsoCode;
            T_PRICING_ADD_LIST.add(T_PRICING_ADD);

        }

        // I_GENERAL
        IF_ERP_Order_Classes.IF_ORDER_001_Req_I_GENERAL I_GENERAL = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_GENERAL();
        I_GENERAL.BSTNK    = order.CustomerOrderNo__c;
        I_GENERAL.VDATU    = ordSvc.formatDateForSAP(order.ReqDeliveryDate_PSO__c, false); // REQUIRED
        I_GENERAL.INCO1    = order.Incoterms__c;
        I_GENERAL.INCO2    = ordSvc.getPicklistLabel('Order', 'Incoterms__c', order.Incoterms__c);
        I_GENERAL.ABRVW    = order.PurchaseType__c;
        I_GENERAL.BZIRK    = order.Owner__r.SalesDistrict__c;
        I_GENERAL.BZIRK_TX = ordSvc.getPicklistLabel('User', 'SalesDistrict__c', order.Owner__r.SalesDistrict__c);
        I_GENERAL.WAERK    = order.CurrencyIsoCode;
        I_GENERAL.ZTERM    = order.PaymentTerms__c;
        I_GENERAL.PLTYP    = order.PriceList__c;
        
        // else {
        //     I_GENERAL.KONDA    = order.PriceList__c;
        // }

        // I_GENERAL.AUGRU    = 'SRP'; // CS Test
        I_GENERAL.AUGRU    = order.OrderReason__c; // CS Test 확인 필요
        I_GENERAL.ZZSQITEM = '';
        if(hasSQ) { 
            I_GENERAL.ZZSQITEM = 'Y';
            I_GENERAL.ZZSQNO = order.Opportunity.ERP_Inquiry_No__c;
        }

        // I_PARTNER
        IF_ERP_Order_Classes.IF_ORDER_001_Req_I_PARTNER I_PARTNER = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_PARTNER();
        I_PARTNER.KVGRP1    = order.MainCategory__c; // REQUIRED
        I_PARTNER.KVGRP2    = order.SubCategory__c; // REQUIRED
        I_PARTNER.KVGRP3    = order.IsTooling__c; // REQUIRED

        if(!isCRMUser) {
            I_PARTNER.KUNNR1    = customerCode; // REQUIRED
            I_PARTNER.KUNNR1_TX = order.ServiceDealer__r.Name; // REQUIRED
            I_PARTNER.KUNNR2    = customerCode; // REQUIRED
            I_PARTNER.KUNNR2_TX = order.SalesRep__r.Name; // REQUIRED
            I_PARTNER.KUNNR4    = customerCode; // REQUIRED
            I_PARTNER.KUNNR4_TX = customerName; // REQUIRED
        }else{
            //직영인 경우 KUNNR1은 9997, KUNNR4는 9999 _250709 
            I_PARTNER.KUNNR1    = '9997'; // REQUIRED
            I_PARTNER.KUNNR1_TX = order.ServiceDealer__r.Name; // REQUIRED
            I_PARTNER.KUNNR4    = '9999'; // REQUIRED
            I_PARTNER.KUNNR4_TX = customerName; // REQUIRED
        }

        I_PARTNER.KUNNR3    = ordSvc.formatCodeForSAP(10, order.BillTo__r.CustomerCode__c); // REQUIRED
        I_PARTNER.KUNNR3_TX = order.BillTo__r.Name; // REQUIRED
        // I_PARTNER.KUNNR4    = customerCode; // REQUIRED
        // I_PARTNER.KUNNR4_TX = customerName; // REQUIRED
        I_PARTNER.KUNNR5    = ordSvc.formatCodeForSAP(10, order.Payer__r.CustomerCode__c); // REQUIRED
        I_PARTNER.KUNNR5_TX = order.Payer__r.Name; // REQUIRED

        // I_COLLECTION
        List<PaymentSchedule__c> psList = [
            SELECT  Id, PlanNo__c, ReqDeliveryDate__c, TotalAmount__c, DraftNoText__c, CurrencyIsoCode
            FROM    PaymentSchedule__c
            WHERE   Order__c =: orderId
        ];
        
        IF_ERP_Order_Classes.IF_ORDER_001_Req_I_COLLECTION I_COLLECTION = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_COLLECTION();
        if(!psList.isEmpty()) {
            PaymentSchedule__c paymentSchedule = psList[0];
    
            I_COLLECTION.BASE_DATE  = ordSvc.formatDateForSAP(paymentSchedule.ReqDeliveryDate__c, false);
            I_COLLECTION.ZZINCOM_NO = paymentSchedule.PlanNo__c;
            I_COLLECTION.NETWR      = String.valueOf(paymentSchedule.TotalAmount__c);
            I_COLLECTION.WAERK      = paymentSchedule.CurrencyIsoCode;
        }

        // I_WARRANT_OPT
        // String warrantyVTWEG = isGlobal ? '20' : '10';
        // List<Warranty__c> warrantyList = [
        //     SELECT  Id, ZZWARRPER__c, ZZWARHRS__c, ZZPR_WAR__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c
        //     FROM    Warranty__c 
        //     WHERE   VTWEG__c = :warrantyVTWEG
        //     AND     ZZPR_WAR__c = : order.Warranty__c
        // ];
        // IF_ERP_Order_Classes.IF_ORDER_001_Req_I_WARRANT_OPT  I_WARRANT_OPT = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_WARRANT_OPT();
        // if(!warrantyList.isEmpty()) {
        //     Warranty__c warr = warrantyList[0];

        //     I_WARRANT_OPT.ZZWARRPER     = warr.ZZWARRPER__c;
        //     I_WARRANT_OPT.ZZWARHRS      = warr.ZZWARHRS__c;
        //     I_WARRANT_OPT.ZZPR_WAR      = warr.ZZPR_WAR__c;
        //     I_WARRANT_OPT.ZZCOVERAGE    = warr.ZZCOVERAGE__c;
        //     I_WARRANT_OPT.ZZCOVERAGE_B  = warr.ZZCOVERAGE_B__c;

        // }

        // I_NOTE
        IF_ERP_Order_Classes.IF_ORDER_001_Req_I_NOTE I_NOTE = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_NOTE();
        I_NOTE.HEAD = order.Description;

        // I_COM_DEALER
        IF_ERP_Order_Classes.IF_ORDER_001_Req_I_COM_DEALER I_COM_DEALER = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_COM_DEALER();
        I_COM_DEALER.ZDLRCOM_AMT = String.valueOf(order.DealerCommission__c);
        I_COM_DEALER.WAERS       = order.CurrencyIsoCode;
        if(order.ServiceOpportunityType__c == 'Parts' || order.ServiceOpportunityType__c == 'Spindle') {
            I_COM_DEALER.KONDA    = '28';
        } 
        if(isGlobal && order.DealerCommission__c != 0 && order.DealerCommission__c != null) { I_COM_DEALER.KONDA = '40'; }

        // T_CONFIG, T_SEL_CONFIG
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
        System.debug('callOrderCreationIF - cvList ::: ' + cvList);

        List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_CONFIG> T_CONFIG_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_CONFIG>();
        List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_SEL_CONFIG> T_SEL_CONFIG_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_SEL_CONFIG>();
        for(CVOrderItem__c cv : cvList) {
            IF_ERP_Order_Classes.IF_ORDER_001_Req_T_CONFIG T_CONFIG = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_CONFIG();
            T_CONFIG.ATNAM = cv.F_CCode__c;
            T_CONFIG.ATBEZ = cv.F_CValue__c;
            T_CONFIG_LIST.add(T_CONFIG);

            IF_ERP_Order_Classes.IF_ORDER_001_Req_T_SEL_CONFIG T_SEL_CONFIG = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_SEL_CONFIG();
            T_SEL_CONFIG.MATNR = cv.OrderProduct__r.Product2.name__c;
            T_SEL_CONFIG.ATNAM = cv.F_CCode__c;
            T_SEL_CONFIG.ATWRT = cv.F_VCode__c;
            T_SEL_CONFIG_LIST.add(T_SEL_CONFIG);
        }

        // T_PRICING_ADD, T_MULTICOND
        List<OrderPricingSelected__c> selPromotions = [
            SELECT  Id, Type__c, Key__c, Amount__c, Rate__c, IsAuto__c, CurrencyIsoCode
            FROM    OrderPricingSelected__c
            WHERE   Type__c IN ('Special', 'Promotion')
            AND     Order__c = : orderId
        ];
        

        // List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD> T_PRICING_ADD_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD>();
        // List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND> T_MULTICOND_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND>();
        // for(OrderPricingSelected__c selPro : selPromotions) {
        //     Boolean isAdd = selPro.Type__c == 'Special' && selPro.Key__c.startsWith('ZPRC');
        //     if(isAdd) {
        //         IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD T_PRICING_ADD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD();
        //         T_PRICING_ADD.POSNR = '000010';
        //         T_PRICING_ADD.KSCHL = 'ZPRC';
        //         T_PRICING_ADD.KWERT = String.valueOf(selPro.Amount__c);
        //         T_PRICING_ADD.WAERK = selPro.CurrencyIsoCode;
        //         T_PRICING_ADD_LIST.add(T_PRICING_ADD);
        //     } else {
        //         IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND T_MULTICOND = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND();
        //         T_MULTICOND.CHAK    = 'X';
        //         T_MULTICOND.VARCOND = selPro.Key__c;
        //         if(selPro.IsAuto__c) { T_MULTICOND.KBETR = String.valueOf(selPro.Rate__c); }
        //         else { T_MULTICOND.KWERT = String.valueOf(selPro.Amount__c); }
        //         T_MULTICOND.WAERK = selPro.CurrencyIsoCode;
        //         T_MULTICOND_LIST.add(T_MULTICOND);
        //     }
        // }
        
        
        // T_ADD_DATA
        List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ADD_DATA> T_ADD_DATA_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ADD_DATA>();
        IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ADD_DATA T_ADD_DATA = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ADD_DATA();
        T_ADD_DATA.ZFMAINP = order.Contractor__c;
        T_ADD_DATA.ZFLASTP = order.EndUser__c;
        T_ADD_DATA_LIST.add(T_ADD_DATA);

        IF_ERP_Order_Classes.IF_ORDER_001_Req wrapper_ORDER_001 = new IF_ERP_Order_Classes.IF_ORDER_001_Req();
        wrapper_ORDER_001.I_REF_ORDER   = erpQuoteNo;
        wrapper_ORDER_001.I_GUBUN       = 'C'; // 'C' = Create, 'U' = Change, 'D' = Delete
        wrapper_ORDER_001.I_TESTRUN     = '';
        wrapper_ORDER_001.I_STATUS      = order.OverallStatus__c;
        wrapper_ORDER_001.I_EXPORT      = order.IsExport__c == 'Y' ? 'X' : ''; // Export or not : X means Export
        wrapper_ORDER_001.I_LAND1       = order.ExportTo__c;
        wrapper_ORDER_001.I_SPDC        = order.HasSpecialDC__c;

        wrapper_ORDER_001.I_USERINFO    = I_USERINFO;
        wrapper_ORDER_001.I_HEAD        = I_HEAD;
        wrapper_ORDER_001.I_GENERAL     = I_GENERAL;
        wrapper_ORDER_001.I_PARTNER     = I_PARTNER;
        wrapper_ORDER_001.I_COLLECTION  = I_COLLECTION;
        // wrapper_ORDER_001.I_WARRANT_OPT = I_WARRANT_OPT;
        wrapper_ORDER_001.I_NOTE        = I_NOTE;
        wrapper_ORDER_001.I_COM_DEALER  = I_COM_DEALER;
        wrapper_ORDER_001.T_ITEM        = T_ITEM_LIST;
        wrapper_ORDER_001.T_CONFIG      = T_CONFIG_LIST;
        wrapper_ORDER_001.T_SEL_CONFIG  = T_SEL_CONFIG_LIST;
        wrapper_ORDER_001.T_PRICING_ADD = T_PRICING_ADD_LIST;
        wrapper_ORDER_001.T_ADD_DATA    = T_ADD_DATA_LIST;
        // wrapper_ORDER_001.T_MULTICOND   = T_MULTICOND_LIST;
        // wrapper_ORDER_001.T_PRICING     = T_PRICING_LIST;

        // 250213 warranty 필드 변경
        String warrantyVTWEG = isGlobal ? '20' : '10';
        List<Warranty__c> warrantyList = [
            SELECT  Id, ZZWARRPER__c, ZZPERUNIT__c, ZZWARHRS__c, ZZPR_WAR__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c
            FROM    Warranty__c 
            WHERE   VTWEG__c = :warrantyVTWEG
            AND     ZZPR_WAR__c = : order.Warranty__c
        ];

        if(!warrantyList.isEmpty()) {
            Warranty__c warr = warrantyList[0];
            wrapper_ORDER_001.I_ZZWARRPER  = warr.ZZWARRPER__c;
            wrapper_ORDER_001.I_ZZPERUNIT    = warr.ZZPERUNIT__c;
            wrapper_ORDER_001.I_ZZWARHRS     = warr.ZZWARHRS__c;
            wrapper_ORDER_001.I_ZZPR_WAR     = warr.ZZPR_WAR__c;
            wrapper_ORDER_001.I_ZZCOVERAGE   = warr.ZZCOVERAGE__c;
            wrapper_ORDER_001.I_ZZCOVERAGE_B = warr.ZZCOVERAGE_B__c;
        }

        IF_ERP_Order Obj_ORDER_001 = new IF_ERP_Order();
        IF_ERP_Order_Classes.IF_ORDER_001_Res response = Obj_ORDER_001.IF_ORDER_001(wrapper_ORDER_001);
        
        return response;
    }

    private static void mappingPriceInfo(String orderId, IF_ERP_Order_Classes.IF_ORDER_001_Res response) {
        System.debug('mappingPriceInfo');

        Map<String, PriceWrapper> priceMap = new Map<String, PriceWrapper>();
        List<IF_ERP_Order_Classes.IF_ORDER_001_Res_T_PRICING_RETURN> T_PRICING_RETURN = response.T_PRICING_RETURN;
        System.debug('mappingPriceInfo - T_PRICING_RETURN ::: ' + T_PRICING_RETURN);

        for(IF_ERP_Order_Classes.IF_ORDER_001_Res_T_PRICING_RETURN T_PRICING : T_PRICING_RETURN) {

            if(priceMap.containsKey(T_PRICING.POSNR)) {
                PriceWrapper innerWrap = priceMap.get(T_PRICING.POSNR);
                if(T_PRICING.KSCHL == 'ZSUM') {
                    innerWrap.price = Decimal.valueOf(T_PRICING.KWERT);
                } else if (T_PRICING.KSCHL == 'MWST') {
                    innerWrap.tax   = Decimal.valueOf(T_PRICING.KWERT);
                }
                priceMap.put(T_PRICING.POSNR, innerWrap);
            } else {
                PriceWrapper innerWrap = new PriceWrapper();
                innerWrap.posnr = T_PRICING.POSNR;
                if(T_PRICING.KSCHL == 'ZSUM') {
                    innerWrap.price = Decimal.valueOf(T_PRICING.KWERT);
                } else if (T_PRICING.KSCHL == 'MWST') {
                    innerWrap.tax   = Decimal.valueOf(T_PRICING.KWERT);
                }
                priceMap.put(T_PRICING.POSNR, innerWrap);
            }
        }
        System.debug('mappingPriceInfo - priceMap ::: ' + priceMap);

        // 20250203 add cv update function
        Order order = [SELECT Id, SalesChannelType__c FROM Order WHERE Id =:orderId];

        Decimal cvSum = 0;
        if(ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c)) {

            Map<String, Decimal> cvMap = new Map<String, Decimal>();
            for(IF_ERP_Order_Classes.IF_ORDER_001_Res_T_COND_EX T_COND_EX : response.T_COND_EX) {
                if(T_COND_EX.COND_TYPE == 'ZVA1') {
                    Decimal cvPrice = Decimal.valueOf(T_COND_EX.CONDVALUE);
                    cvMap.put(T_COND_EX.VARCOND, cvPrice);
                    cvSum += cvPrice;
                }
            }
            
            List<CVOrderItem__c> cvList = [SELECT Id, CharacteristicValue__c, F_CCode__c, F_VCode__c, F_Price__c FROM CVOrderItem__c WHERE OrderProduct__r.OrderId =: orderId];
            List<CharacteristicValue__c> toUpdateCVs = new List<CharacteristicValue__c>();
            for(CVOrderItem__c cv : cvList) {
                String cvKey = cv.F_CCode__c + '-' + cv.F_VCode__c;
                Decimal newPrice = cvMap.containsKey(cvKey) ? cvMap.get(cvKey) : 0;
                if(cv.F_Price__c != newPrice) { 
                    CharacteristicValue__c newCV = new CharacteristicValue__c();
                    newCV.Id       = cv.CharacteristicValue__c;
                    newCV.Price__c = newPrice;
                    toUpdateCVs.add(newCV); 
                }
            }

            if(!toUpdateCVs.isEmpty()) { update toUpdateCVs; }
        }

        List<OrderItem> orderItems = [SELECT Id, IF_POSNR__c, Quantity, UnitPrice, Tax__c, ItemCategory__c FROM OrderItem WHERE OrderId =: orderId];
        

        List<OrderItem> toUpdateItems = new List<OrderItem>();
        for(OrderItem item : orderItems) {
            String posnr = ordSvc.formatCodeForSAP(6, item.IF_POSNR__c);
            if(priceMap.containsKey(posnr)) {
                
                PriceWrapper innerWrap = priceMap.get(posnr);

                Decimal tempPrice = innerWrap.price ?? 0;
                Decimal tempTax   = innerWrap.tax ?? 0;

                if(item.Quantity > 1 && tempPrice > 0) {
                    tempPrice = (tempPrice / item.Quantity).setScale(2, System.RoundingMode.HALF_UP);
                    tempTax   = (tempTax / item.Quantity).setScale(2, System.RoundingMode.HALF_UP);
                }

                item.UnitPrice      = tempPrice;
                item.Tax__c         = tempTax;
                item.IF_FreePass__c = true;

                if(item.ItemCategory__c == ordSvc.ITEM_PRODUCT) { 
                    item.CVSummary__c = cvSum; 
                    // item.UnitPrice   += item.CVSummary__c;
                }

                toUpdateItems.add(item);
            }
        }
        if(!toUpdateItems.isEmpty()) { update toUpdateItems; }
    }
}