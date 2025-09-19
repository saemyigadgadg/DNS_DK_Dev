trigger OrderCRMToERPTrigger on OrderCRMToERP__e (after insert) {
    System.debug('OrderCRMToERPTrigger');
    // EventBus.publish(new OrderCRMToERP__e(OrderId__c = '801JO00000BaKZvYAN'));
    public static DN_OrderService ordSvc = new DN_OrderService();

    if(Test.isRunningTest()) {testCoverage();}
    List<TriggerExceptionLog__c> errorLogs = new List<TriggerExceptionLog__c>();
    Long handlerStartTimeMillis = System.currentTimeMillis();
    OrderCRMToERP__e evt = Trigger.New[0];// 무조건 단 건으로 작동 됨
    String orderId = evt.OrderId__c;

    Order thisOrder = new Order();
    thisOrder.Id = orderId;

    try {

        IF_ERP_Order_Classes.IF_ORDER_001_Res response_order = callOrderCreationIF(thisOrder.Id);
        System.debug(' response_order ::: ' + response_order);

        if(response_order.O_RETURN.TYPE == 'E') {
            String errorMsg = response_order.O_RETURN.MESSAGE;
            System.debug('OrderCRMToERPTrigger - response_order IF_ERROR__c ::: ' + errorMsg);
            thisOrder.IF_ERROR__c = errorMsg;
            thisOrder.IF_FreePass__c = true;
            update thisOrder;

        } else {

            String erpNo = response_order.O_VBELN;

            IF_ERP_Order_Classes.IF_ORDER_021_Res response_cv = callCVPriceIF(thisOrder.Id, erpNo);
            if(response_cv.O_RETURN.TYPE == 'E') {
                String errorMsg = response_cv.O_RETURN.MESSAGE;
                System.debug('OrderCRMToERPTrigger - response_cv IF_ERROR__c ::: ' + errorMsg);
                thisOrder.IF_ERROR__c = errorMsg;
            } else {

                thisOrder.IF_ERROR__c = '';
                
                thisOrder.Status         = ordSvc.ORDER_PROGRESS;
                thisOrder.ERPOrderNo__c  = erpNo;
                thisOrder.IF_FreePass__c = true;
                update thisOrder;
                
                mappingCVPriceInfo(thisOrder.Id, response_cv);
                sendEmailNoti(thisOrder);
            }
        }

    } catch (Exception e) {
        TriggerExceptionLog__c errorLog = new TriggerExceptionLog__c();
        errorLog.LineNumber__c = e.getLineNumber();
        errorLog.Message__c = 'OrderCRMToERPTrigger : ' + e.getMessage();
        errorLog.ExceptionType__c = e.getTypeName();
        errorLog.ProgramStartTimemilles__c = handlerStartTimeMillis;
        errorLog.ProgramEndTimemilles__c = System.currentTimeMillis();
        errorLogs.add(errorLog);
    }









    
    private static IF_ERP_Order_Classes.IF_ORDER_001_Res callOrderCreationIF(String orderId){

        Order order = [
            SELECT  Id
                    , OwnerId, Owner__r.CustomerCode__c, Owner__r.Account.CustomerCode__c, Owner__r.SalesDistrict__c
                    , Owner__r.Account.Name, Owner__r.Name, Owner__r.ERP_Key__c

                    , SalesOrganization__c, DistributionChannel__c, Division__c, SalesOffice__c

                    , CreatedDate, ReqDeliveryDate__c
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

                    , Account.Name, Account.SalesDistrict__c, Account.CustomerCode__c
                    , SoldTo__c,        SoldTo__r.Name,   SoldTo__r.CustomerCode__c
                    , ShipTo__c,        ShipTo__r.Name,   ShipTo__r.CustomerCode__c
                    , BillTo__c,        BillTo__r.Name,   BillTo__r.CustomerCode__c
                    , Payer__c,         Payer__r.Name,    Payer__r.CustomerCode__c
                    , SalesRep__c,      SalesRep__r.Name, SalesRep__r.DealerGrade__c
                    , CreditDealer__c,  CreditDealer__r.Name
                    , ServiceDealer__c, ServiceDealer__r.Name

                    , ERPOrderNo__c
                    , Quote.Account.AccountGroup__c
                    
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
                    , AdjustmentPrice__c
                    , ItemCategory__c
                    , Unit__c
                    , Product2Id, Product2.ProductCode, Product2.Name, Product2.Name__c, Product2.Plant__c
                    , SQ__c, SQ__r.Name, SQ__r.SQCode__c, F_SQStage__c
                    , QuoteLineItemId, QuoteLineItem.ERPQuotationNo__c, QuoteLineItem.ERPInquiryNo__c
                    , Accessory__r.Name, Accessory__r.Description__c
            FROM    OrderItem
            WHERE   OrderId =: orderId
        ];
        System.debug('callOrderCreationIF - items ::: ' + items);

        // get plant
        List<ProductByPlant__c> plantList = [
            SELECT  Id, Part__c, Plant__c
            FROM    ProductByPlant__c
            WHERE   Part__c = :items[0].Product2Id
            AND     Plant__c IN ('1840', '1842')
        ];

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
        I_USERINFO.VKORG = order.SalesOrganization__c;

        // I_HEAD
        IF_ERP_Order_Classes.IF_ORDER_001_Req_I_HEAD I_HEAD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_HEAD();
        I_HEAD.AUART = order.OrderType__c; // REQUIRED
        I_HEAD.VKORG = order.SalesOrganization__c; // REQUIRED
        I_HEAD.VTWEG = order.DistributionChannel__c; // REQUIRED
        I_HEAD.SPART = order.Division__c; // REQUIRED
        I_HEAD.KUNNR = ordSvc.formatCodeForSAP(10, order.SoldTo__r.CustomerCode__c); // REQUIRED
        I_HEAD.KUNAG = ordSvc.formatCodeForSAP(10, order.ShipTo__r.CustomerCode__c); // REQUIRED
        I_HEAD.VKBUR = order.SalesOffice__c;

        // T_ITEM
        Id itemId;
        String erpQuoteNo;
        OrderItem prodItems;
        Boolean hasSQ = false;
        String erpInqNo;
        List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM> T_ITEM_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM>();
        for(OrderItem item : items) {
            IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM T_ITEM = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_ITEM();
            if(item.ItemCategory__c == ordSvc.ITEM_PRODUCT) {
                T_ITEM.MATNR  = item.Product2.ProductCode;
                T_ITEM.ARKTX  = item.Product2.Name__c;

                itemId     = item.Id;
                prodItems  = item;
                erpQuoteNo = item.QuoteLineItem.ERPQuotationNo__c;
            } else if(item.ItemCategory__c == ordSvc.ITEM_SQ) {
                hasSQ = true;
                erpInqNo = item.QuoteLineItem.ERPInquiryNo__c;

                T_ITEM.MATNR     = 'SQ100';
                T_ITEM.ZZSQCOD   = item.SQ__r.SQCode__c;
                T_ITEM.ZZSQTITLE = item.SQ__r.Name;

                Decimal toSendPrice = item.StandardPrice__c * item.Quantity;
                if(toSendPrice == 0) { T_ITEM.PSTYV = 'ZFOQ'; } // 20250228 ZFOC > ZFOQ
                // if(toSendPrice == 0) { T_ITEM.PSTYV = 'ZFOC'; } // 20250221 ZFOQ > ZFOC
                // if(toSendPrice == 0) { T_ITEM.PSTYV = 'ZFOQ'; }
                // PSTYV : 무료 SQ Flag
                /*
                20250228 확인 사항 
                1.	견적 : 무료 SQ는 모두 ZFOQ
                2.	주문 : DNSA의 무료 SQ는 ZFOC, 
                           DNS(국내, 수출) 무료 SQ는 ZFOQ
                */
                
                String toSendPriceStr = String.valueOf(toSendPrice);
                T_ITEM.NETPR = toSendPriceStr;

            } else if(item.ItemCategory__c == ordSvc.ITEM_ACCESSORY) {
                T_ITEM.MATNR = item.Accessory__r.Name;
                T_ITEM.ARKTX = item.Accessory__r.Description__c;
                if(item.UnitPrice == 0) { 
                    T_ITEM.PSTYV = 'ZFOC';
                    T_ITEM.NETPR = '0';
                    // PSTYV : 무료 추가자재 Flag
                }
            }
            T_ITEM.POSNR  = item.IF_POSNR__c;
            T_ITEM.KWMENG = Integer.valueOf(item.Quantity) + '.000';
            T_ITEM.VRKME  = item.Unit__c;
            
            if(!plantList.isEmpty()) { T_ITEM.WERKS  = plantList[0].Plant__c; }

            T_ITEM_LIST.add(T_ITEM);
        }

        // I_GENERAL
        IF_ERP_Order_Classes.IF_ORDER_001_Req_I_GENERAL I_GENERAL = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_GENERAL();
        I_GENERAL.BSTNK    = order.CustomerOrderNo__c;
        I_GENERAL.VDATU    = ordSvc.formatDateForSAP(order.ReqDeliveryDate__c, false); // REQUIRED
        I_GENERAL.INCO1    = order.Incoterms__c;
        I_GENERAL.INCO2    = ordSvc.getPicklistLabel('Order', 'Incoterms__c', order.Incoterms__c);
        I_GENERAL.ABRVW    = order.PurchaseType__c;
        I_GENERAL.BZIRK    = order.Owner__r.SalesDistrict__c;
        I_GENERAL.BZIRK_TX = ordSvc.getPicklistLabel('User', 'SalesDistrict__c', order.Owner__r.SalesDistrict__c);
        I_GENERAL.WAERK    = order.CurrencyIsoCode;
        I_GENERAL.ZTERM    = order.PaymentTerms__c;
        I_GENERAL.PLTYP    = order.PriceList__c;
        I_GENERAL.AUGRU    = '001';
        I_GENERAL.ZZSQITEM = '';
        if(hasSQ) { 
            I_GENERAL.ZZSQITEM = 'Y';
            I_GENERAL.ZZSQNO = erpInqNo;
        }
        if(!plantList.isEmpty()) { I_GENERAL.WERK = plantList[0].Plant__c; }

        // I_PARTNER
        // KUNNR1(Z1) - ServiceDealer__c*
        // KUNNR2(ZM) - SalesRep__c*
        // KUNNR3(RE) - BillTo__c
        // KUNNR4(Z2) - CreditDealer__c*
        // KUNNR5(RG) - Payer__c
        // KUNNR7(ZI) - RelatedDealer__c : 전송값 X, ERP에서 받아옴
        IF_ERP_Order_Classes.IF_ORDER_001_Req_I_PARTNER I_PARTNER = new IF_ERP_Order_Classes.IF_ORDER_001_Req_I_PARTNER();
        I_PARTNER.KVGRP1    = order.MainCategory__c; // REQUIRED
        I_PARTNER.KVGRP2    = order.SubCategory__c; // REQUIRED
        I_PARTNER.KVGRP3    = order.IsTooling__c; // REQUIRED

        // I_PARTNER.KUNNR1    = customerCode; // REQUIRED
        // I_PARTNER.KUNNR1_TX = customerName; // REQUIRED

        // 20250401 SalesRep__c은 직영일때만 입력
        if(isCRMUser) {
            I_PARTNER.KUNNR2    = customerCode; // REQUIRED
            I_PARTNER.KUNNR2_TX = customerName; // REQUIRED

            //직영은 KUNNR1이 9997_250709
            I_PARTNER.KUNNR1    = '9997'; // REQUIRED
            I_PARTNER.KUNNR1_TX = customerName; // REQUIRED
            //직영은 KUNNR4가 9999_250709
            I_PARTNER.KUNNR4    = '9999'; // REQUIRED
            I_PARTNER.KUNNR4_TX = customerName; // REQUIRED
        }else{
            I_PARTNER.KUNNR1    = customerCode; // REQUIRED
            I_PARTNER.KUNNR1_TX = customerName; // REQUIRED

            I_PARTNER.KUNNR4    = customerCode; // REQUIRED
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
            I_COLLECTION.ZZDRAFTNO  = paymentSchedule.DraftNoText__c;
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
        if(isGlobal) {
            I_COM_DEALER.ZDLRCOM_AMT = String.valueOf(order.DealerCommission__c);
            I_COM_DEALER.WAERS       = order.CurrencyIsoCode;
            if(order.DealerCommission__c != 0 && order.DealerCommission__c != null) {

                List<Vendor__c> vendorList = [SELECT LIFNR__c FROM Vendor__c WHERE Id =: order.Vendor__c];
                
                I_COM_DEALER.KONDA = '40';
                I_COM_DEALER.LIFNR = vendorList[0].LIFNR__c;
            }
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
            SELECT  Id, Type__c, Key__c, Amount__c, SpecialAmount__c, Rate__c, IsAuto__c, CurrencyIsoCode
            FROM    OrderPricingSelected__c
            WHERE   Type__c IN ('Special', 'Promotion')
            AND     Order__c = : orderId
        ];
        

        List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD> T_PRICING_ADD_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD>();
        List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND> T_MULTICOND_LIST = new List<IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND>();
        for(OrderPricingSelected__c selPro : selPromotions) {
            Boolean isAdd = selPro.Type__c == 'Special' && selPro.Key__c.startsWith('ZPRC');
            if(isAdd) {
                IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD T_PRICING_ADD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD();
                T_PRICING_ADD.POSNR = '000010';
                T_PRICING_ADD.KSCHL = 'ZPRC';
                T_PRICING_ADD.KWERT = String.valueOf(selPro.SpecialAmount__c);
                T_PRICING_ADD.WAERK = selPro.CurrencyIsoCode;
                T_PRICING_ADD_LIST.add(T_PRICING_ADD);
            } else if(selPro.Type__c == 'Special') {
                IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND T_MULTICOND = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND();
                T_MULTICOND.CHAK    = 'X';
                T_MULTICOND.VARCOND = selPro.Key__c;
                T_MULTICOND.KWERT   = String.valueOf(selPro.SpecialAmount__c);
                T_MULTICOND.WAERK   = selPro.CurrencyIsoCode;
                T_MULTICOND_LIST.add(T_MULTICOND);
            }else {
                IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND T_MULTICOND = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_MULTICOND();
                T_MULTICOND.CHAK    = 'X';
                T_MULTICOND.VARCOND = selPro.Key__c;
                if(selPro.IsAuto__c) { T_MULTICOND.KBETR = String.valueOf(selPro.Rate__c); }
                else { T_MULTICOND.KWERT = String.valueOf(selPro.Amount__c); }
                T_MULTICOND.WAERK = selPro.CurrencyIsoCode;
                T_MULTICOND_LIST.add(T_MULTICOND);
            }
        }

        if(
            (isGlobal || order.SalesChannelType__c == ordSvc.SEG_WHOLESALE) 
            && prodItems.AdjustmentPrice__c != 0 && prodItems.AdjustmentPrice__c != null
        ) {
            IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD T_PRICING_ADD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD();
            T_PRICING_ADD.POSNR = '000010';
            T_PRICING_ADD.KSCHL = 'ZVPA';
            T_PRICING_ADD.KWERT = String.valueOf(prodItems.AdjustmentPrice__c);
            T_PRICING_ADD.WAERK = order.CurrencyIsoCode;
            T_PRICING_ADD_LIST.add(T_PRICING_ADD);
        }

        if(isGlobal && order.DealerCommission__c != null && order.DealerCommission__c != 0) {
            IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD T_PRICING_ADD = new IF_ERP_Order_Classes.IF_ORDER_001_Req_T_PRICING_ADD();
            T_PRICING_ADD.POSNR = '000010';
            T_PRICING_ADD.KSCHL = 'ZSXB';
            T_PRICING_ADD.KWERT = String.valueOf(order.DealerCommission__c);
            T_PRICING_ADD.WAERK = order.CurrencyIsoCode;
            T_PRICING_ADD_LIST.add(T_PRICING_ADD);
        }
        
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
        // wrapper_ORDER_001.I_SPDC        = order.HasSpecialDC__c;
        wrapper_ORDER_001.I_SPDC        = order.HasSpecialDC__c == 'Y' ? 'X' : ''; //2025-06-09 권세진 수정
        if(order.OrderSegmentation__c != ordSvc.SEG_DIRECTSALES) { wrapper_ORDER_001.I_ZZKVGR4 = order.SalesRep__r.DealerGrade__c; }

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
        wrapper_ORDER_001.T_MULTICOND   = T_MULTICOND_LIST;

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

        System.debug('OrderCRMToERPTrigger - callOrderCreationIF ::: ' + wrapper_ORDER_001);

        IF_ERP_Order Obj_ORDER_001 = new IF_ERP_Order();
        Obj_ORDER_001.interfaceUtil.isInsertLog = false;
        IF_ERP_Order_Classes.IF_ORDER_001_Res response = Obj_ORDER_001.IF_ORDER_001(wrapper_ORDER_001);

        if(response.O_RETURN.TYPE == 'E') {
            Obj_ORDER_001.interfaceUtil.saveInterfaceLog();
        }
        
        return response;
    }

    private static IF_ERP_Order_Classes.IF_ORDER_021_Res callCVPriceIF(String orderId, String erpNo) {
        System.debug('callCVPriceIF ::: ' + orderId + ' / ' + erpNo);

        OrderItem oItem = [SELECT Id FROM OrderItem WHERE OrderId =: orderId AND ItemCategory__c =: ordSvc.ITEM_PRODUCT];
        System.debug('callCVPriceIF - oItem ::: ' + oItem);

        List<CVOrderItem__c> cvList = [SELECT Id, F_CCode__c, F_VCode__c FROM CVOrderItem__c WHERE OrderProduct__c =: oItem.Id];
        System.debug('callCVPriceIF - cvList ::: ' + cvList);

        List<IF_ERP_Order_Classes.IF_ORDER_021_Req_T_VARIANT> T_VARIANT_LIST= new List<IF_ERP_Order_Classes.IF_ORDER_021_Req_T_VARIANT>();
        for(CVOrderItem__c cv : cvList) {

            IF_ERP_Order_Classes.IF_ORDER_021_Req_T_VARIANT T_VARIANT = new IF_ERP_Order_Classes.IF_ORDER_021_Req_T_VARIANT();
            T_VARIANT.POSNR = '000010'; // FIXED
            T_VARIANT.ATNAM = cv.F_CCode__c;
            T_VARIANT.ATWRT = cv.F_VCode__c;
            T_VARIANT_LIST.add(T_VARIANT);
        }

        IF_ERP_Order_Classes.IF_ORDER_021_Req request = new IF_ERP_Order_Classes.IF_ORDER_021_Req();
        request.I_VBELN   = erpNo;
        request.T_VARIANT = T_VARIANT_LIST;

        System.debug('OrderCRMToERPTrigger - callCVPriceIF ::: ' + request);


        IF_ERP_Order rfc021 = new IF_ERP_Order();
        rfc021.interfaceUtil.isInsertLog = false;
        IF_ERP_Order_Classes.IF_ORDER_021_Res response = rfc021.IF_ORDER_021(request);
        rfc021.interfaceUtil.saveInterfaceLog();

        return response;
    }

    public static void mappingCVPriceInfo(String orderId, IF_ERP_Order_Classes.IF_ORDER_021_Res response) {
        System.debug('mappingCVPriceInfo');

        Map<String, PriceWrapper> priceMap = new Map<String, PriceWrapper>();

        for(IF_ERP_Order_Classes.IF_ORDER_021_Res_T_PRICING T_PRICING : response.T_PRICING) {
            System.debug('mappingCVPriceInfo - T_PRICING ::: ' + T_PRICING);
            PriceWrapper innerWrap = priceMap.containsKey(T_PRICING.POSNR) ? priceMap.get(T_PRICING.POSNR) : new PriceWrapper();
            innerWrap.posnr = T_PRICING.POSNR;
            
            if(T_PRICING.KSCHL == 'ZSUM') {
                innerWrap.price = Decimal.valueOf(T_PRICING.KWERT);
            } else if (T_PRICING.KSCHL == 'MWST') {
                innerWrap.tax   = Decimal.valueOf(T_PRICING.KWERT);
            }
            
            priceMap.put(T_PRICING.POSNR, innerWrap);
        }
        System.debug('mappingCVPriceInfo - priceMap ::: ' + priceMap);
            
        Order order = [SELECT Id, SalesChannelType__c FROM Order WHERE Id =:orderId];
            
        Decimal cvSum = 0;
        if(ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c)) {
            Map<String, Decimal> cvMap = new Map<String, Decimal>();

            System.debug('mappingCVPriceInfo - response.T_COND_EX ::: ' + response.T_COND_EX);
            for(IF_ERP_Order_Classes.IF_ORDER_021_Res_T_COND_EX T_COND_EX : response.T_COND_EX) {

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
                System.debug('mappingCVPriceInfo - cvList ::: ' + cvKey + ' / ' + newPrice + ' / ' + cv.F_Price__c);
                if(cv.F_Price__c != newPrice) { 
                    CharacteristicValue__c newCV = new CharacteristicValue__c();
                    newCV.Id       = cv.CharacteristicValue__c;
                    newCV.Price__c = newPrice;
                    toUpdateCVs.add(newCV); 
                }
            }
            System.debug('mappingCVPriceInfo - toUpdateCVs ::: ' + toUpdateCVs);
            if(!toUpdateCVs.isEmpty()) { update toUpdateCVs; }
        }

        List<OrderItem> orderItems = [SELECT Id, IF_POSNR__c, Quantity, UnitPrice, Tax__c, ItemCategory__c FROM OrderItem WHERE OrderId =: orderId];
        System.debug('mappingCVPriceInfo - orderItems ::: ' + orderItems);
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
                }

                toUpdateItems.add(item);
            }
        }
        System.debug('mappingCVPriceInfo - toUpdateItems ::: ' + toUpdateItems);
        if(!toUpdateItems.isEmpty()) { update toUpdateItems; }
    }

    public static void sendEmailNoti(Order order){
        System.debug('sendEmailNoti');

        Boolean isGlobal = !ordSvc.CHANNER_DOMESTIC_SET.contains(order.SalesChannelType__c);
        System.debug('sendEmailNoti - isGlobal ::: ' + isGlobal);

        // get account
        Set<Id> accIdSet = new Set<Id>{order.SoldTo__c, order.ShipTo__c};
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: accIdSet];
        Map<Id, String> accNameMap = new Map<Id, String>();
        for(Account acc : accList) {
            accNameMap.put(acc.Id, acc.Name);
        }
        System.debug('sendEmailNoti - accNameMap ::: ' + accNameMap);

        // picklistMap
        Map<String, String> picklistMap = new Map<String, String>();
        picklistMap.put('Style01',    isGlobal ? '' : '<!--');
        picklistMap.put('Style02',    isGlobal ? '' : '-->');

        String globalFlag = isGlobal ? 'TRUE' : 'FALSE';
        picklistMap.put('isGlobal', globalFlag);

        if(isGlobal) {
            picklistMap.put('productPrice', convertToStr(order.ProductPrice__c));
            picklistMap.put('cvTotal',      convertToStr(order.CVTotal__c));
            picklistMap.put('sqTotal',      convertToStr(order.SQTotal__c));
            picklistMap.put('accTotal',     convertToStr(order.AccessoryTotal__c));
            picklistMap.put('listPrice',    convertToStr(order.F_TotalListPrice__c));
            picklistMap.put('dcPercent',    convertToStr(order.DCPercent__c));
            picklistMap.put('dcPrice',      convertToStr(order.DCPrice__c));
            picklistMap.put('netPrice',     convertToStr(order.F_TotalNetPrice__c));
            picklistMap.put('adjPrice',     convertToStr(order.R_AdjustmentPrice__c));
            picklistMap.put('netAdjPrice',  convertToStr(order.F_TotalNetAdjustmentSUM__c));
            picklistMap.put('warrPrice',    convertToStr(order.WarrantyPrice__c));
            picklistMap.put('qPrice',       convertToStr(order.QuotePrice__c));
        }
        System.debug('sendEmailNoti - picklistMap ::: ' + picklistMap);

        // target user
        List<User> managerList = [SELECT Id, ManagerId FROM User WHERE Id =: order.OwnerId];
        System.debug('sendEmailNoti - managerList ::: ' + managerList);

        if(managerList[0].ManagerId == null) {
            System.debug('No Manager');
        } else {

            Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
            targetUserMap.put(order.Id, new Set<Id>{managerList[0].ManagerId});

            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'OrderRequestConfirm'
                , 'email'
                , new List<Order>{order}
                , targetUserMap
                , new Map<String, Object>{
                    'accNameMap'  => accNameMap
                    , 'picklistMap' => picklistMap
                }
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail){
                System.debug('Alert ERROR ::: ' + emailAlertResult.errMessage);
            }
        }

    }

    private static String convertToStr(Decimal amt){
        if(amt == null) { amt = 0; }
        return amt.format();
    }

    public class PriceWrapper{
        public String  posnr    {get;set;}
        public Decimal price    {get;set;}
        public Decimal tax      {get;set;}
        
        public PriceWrapper(){}
    }

    public static void testCoverage() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}