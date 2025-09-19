/**
 * @description       : Order에서 Payment Schedule 등록
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-11-27   yeongju.yun   Initial Version
 * 1.1   2025-04-23   yeongju.yun   Edit01. Draft No 수정 가능 기준 변경, Incentive 제외 > 포함함
 * 1.2   2025-05-12   yeongju.yun   Edit02. ERP전송 후에 Price정보는 적재된 데이터 기준으로 보이도록 변경
**/
public with sharing class DN_OrderPaymentScheduleController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    public static final List<String> CAPITALS = new List<String>{'C006', 'CC01', 'CC02', 'CC03', 'CC04', 'CC05', 'CC07'};

    /**
    * @description 수금스케줄 초기값, 기존에 등록한 적 있으면 기존값 조회
    **/
    @AuraEnabled
    public static Map<String, DN_OrderService.FieldWrapper> fetchFieldInfo(String recordId){
        try {

            List<String> paymentTarget = new List<String>{
                'DocumentDate__c'
                , 'ReqDeliveryDate__c'

                , 'DraftNo__c'
                , 'DraftNoText__c'
                , 'DraftCheck__c'

                , 'CurrencyIsoCode'
                , 'TotalAmount__c'
                , 'Subtotal__c'
                , 'Tax__c'
            };
            List<DN_OrderService.FieldWrapper> paymentFields = ordSvc.getFieldInfo('PaymentSchedule__c', paymentTarget, paymentTarget);

            List<String> itemTarget = new List<String>{
                'Type__c'
                , 'ScheduledDate__c'
                , 'PaymentTerms__c'
                , 'Days__c'
                , 'CapitalCompany__c'
                , 'InstallmentPrincipal__c'
                , 'ReceivedAmount__c'
            };
            List<DN_OrderService.FieldWrapper> itemFields = ordSvc.getFieldInfo('PaymentScheduleItem__c', itemTarget, itemTarget);
            
            Map<String, DN_OrderService.FieldWrapper> fieldMap = new Map<String, DN_OrderService.FieldWrapper>();
            for(DN_OrderService.FieldWrapper field : paymentFields) {
                fieldMap.put(field.apiName, field);
            }
            for(DN_OrderService.FieldWrapper field : itemFields) {
                fieldMap.put(field.apiName, field);
            }

            return fieldMap;

        } catch (Exception e) {
            System.debug('fetchFieldInfo : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 수금 스케줄과 수금 스케줄 하위 데이터 맵핑
    **/
    @AuraEnabled
    public static Map<String, Object> fetchInitData(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        try {

            Order order = [
                SELECT  Id, CurrencyIsoCode, ReqDeliveryDate__c, TotalAmount, HasPricingProcessed__c, ERPOrderNo__c, DCAmount__c, OwnerId, Status
                FROM    Order 
                WHERE   Id =: recordId
            ];

            Boolean isManager = ordSvc.isManager(order.OwnerId);
            Boolean isSentERP = String.isNotBlank(order.ERPOrderNo__c);
            Boolean isAdmin   = ordSvc.getAdminFlag();

            Boolean preventEdit = (!isManager && order.Status != ordSvc.ORDER_CREATE) || isSentERP;
            result.put('preventEdit', preventEdit);

            // Edit01. Draft No 수정 가능 기준 변경, Incentive 제외 > 포함함
            List<OrderPricingSelected__c> selectedPromo = [SELECT Id FROM OrderPricingSelected__c WHERE Order__c =: recordId];
            result.put('preventDraft', selectedPromo.isEmpty());
            
            List<PaymentSchedule__c> psList = [
                SELECT  Id, Order__c, CurrencyIsoCode, DraftNo__c, DraftNoText__c, DraftCheck__c
                        , DocumentDate__c, ReqDeliveryDate__c, TotalAmount__c, PlanNo__c, Tax__c, Subtotal__c
                FROM    PaymentSchedule__c 
                WHERE   Order__c =: recordId
            ];

            Boolean isNew = psList.isEmpty();
            result.put('isNew', isNew);

            PaymentSchedule__c ps = isNew ? new PaymentSchedule__c() : psList[0];
            if(isSentERP) {
                ps.Subtotal__c = ps.TotalAmount__c / 1.1;
                ps.Subtotal__c = ps.Subtotal__c.round();

                ps.Tax__c      = ps.Subtotal__c * 0.1;
                ps.Tax__c      = ps.Tax__c.round();
            } else {
                ps.Subtotal__c        = (order.DCAmount__c == 0 || order.DCAmount__c == null) ? order.TotalAmount : order.DCAmount__c;
                ps.Tax__c             = ps.Subtotal__c * 0.1;
                ps.TotalAmount__c     = ps.Subtotal__c + ps.Tax__c;
                ps.CurrencyIsoCode    = order.CurrencyIsoCode;
                ps.ReqDeliveryDate__c = order.ReqDeliveryDate__c;
            }
            
            List<ItemWrapper> psItems = new List<ItemWrapper>();
            if(isNew) {
                ps.Order__c        = recordId;
                ps.DocumentDate__c = order.ReqDeliveryDate__c;
                ps.DraftCheck__c   = 'NotRequested';

                ItemWrapper itemWrap = new ItemWrapper(order.CurrencyIsoCode);
                psItems.add(itemWrap);

            } else {
                List<PaymentScheduleItem__c> prevPsItems = [
                    SELECT  Id, PaymentSchedule__c, CurrencyIsoCode, Type__c, ScheduledDate__c, PaymentTerms__c
                            , CapitalCompany__c, InstallmentPrincipal__c, Days__c, ReceivedAmount__c
                    FROM    PaymentScheduleItem__c
                    WHERE   PaymentSchedule__c =: ps.Id
                    ORDER BY Type__c, ScheduledDate__c
                ];
                if(prevPsItems.isEmpty()) {
                    psItems.add(new ItemWrapper(order.CurrencyIsoCode));
                } else {
                    for(PaymentScheduleItem__c item : prevPsItems) {
                        ItemWrapper itemWrap = new ItemWrapper(item, order.CurrencyIsoCode);
                        psItems.add(itemWrap);
                    }
                }
            }
            result.put('ps', new HeaderWrapper(ps, order.HasPricingProcessed__c));
            result.put('planNo',  ps.PlanNo__c);
            result.put('psItems', psItems);
            result.put('itemEmptyRow', new ItemWrapper(order.CurrencyIsoCode));

            result.put('capitals', CAPITALS);

            List<OrderDCDraft__c> draftNo = [SELECT Id, Name, DraftSubject__c FROM OrderDCDraft__c WHERE IsActive__c = TRUE ORDER BY Name];
            List<Map<String, String>> draftOption = new List<Map<String, String>>();
            draftOption.add(new Map<String, String>{'label'=> System.Label.DNS_P_NONE, 'value'=> ''});
            for(OrderDCDraft__c draft : draftNo) {
                Map<String, String> option = new Map<String, String>{
                    'label'   => draft.DraftSubject__c
                    , 'value' => draft.Name
                };
                draftOption.add(option);
            }
            draftOption.add(new Map<String, String>{
                'label' => System.Label.DNS_FSL_ETC
                , 'value' => 'etc'
            });
            result.put('draftOption', draftOption);

            return result;
            
        } catch (Exception e) {
            System.debug('fetchInitData : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    /**
    * @description 수금스케줄 저장
    **/
    @AuraEnabled
    public static void savePaymentSchedule(String recordId, HeaderWrapper psInfo, String itemWrapStr){
        SavePoint sp = Database.setSavePoint();
        try {
            List<ItemWrapper> itemInfoList = (List<ItemWrapper>) JSON.deserialize(itemWrapStr, List<ItemWrapper>.class);

            Order order = [SELECT Id, CurrencyIsoCode, ReqDeliveryDate__c, TotalAmount, HasScheduleCompleted__c FROM Order WHERE Id =: recordId];

            List<PaymentSchedule__c> psList = [
                SELECT  Id, Order__c, CurrencyIsoCode, DraftNo__c, DraftNoText__c, DraftCheck__c
                        , DocumentDate__c, ReqDeliveryDate__c, TotalAmount__c
                FROM    PaymentSchedule__c 
                WHERE   Order__c =: recordId
            ];

            Boolean isNew = psList.isEmpty();

            PaymentSchedule__c ps = isNew ? new PaymentSchedule__c() : psList[0];
            ps.DraftNo__c         = psInfo.draftPick;
            ps.DraftNoText__c     = psInfo.draftText;
            ps.DraftCheck__c      = psInfo.draftcheck;
            ps.DocumentDate__c    = psInfo.docuDate;
            ps.TotalAmount__c     = psInfo.totalAmt;
            ps.CurrencyIsoCode    = psInfo.curr;
            ps.ReqDeliveryDate__c = psInfo.reqDDate;
            if(isNew) {
                ps.Order__c = recordId;
            } else {
                List<PaymentScheduleItem__c> toDelete = [SELECT Id FROM PaymentScheduleItem__c WHERE PaymentSchedule__c =: ps.Id];
                delete toDelete;

            }
            upsert ps;

            List<PaymentScheduleItem__c> toInsertList = new List<PaymentScheduleItem__c>();            
            for(ItemWrapper itemWrap : itemInfoList) {
                PaymentScheduleItem__c item  = new PaymentScheduleItem__c();
                item.Type__c                 = itemWrap.type;
                item.ScheduledDate__c        = itemWrap.scheduleDate;
                item.PaymentTerms__c         = itemWrap.paymentTerms;
                item.Days__c                 = itemWrap.days;
                item.CapitalCompany__c       = itemWrap.capitalCom;
                item.InstallmentPrincipal__c = itemWrap.principal;
                item.ReceivedAmount__c       = itemWrap.receivedAmt;

                item.PaymentSchedule__c = ps.Id;
                item.CurrencyIsoCode    = order.CurrencyIsoCode;
                toInsertList.add(item);
            }

            insert toInsertList;

            if(order.HasScheduleCompleted__c) { 
                order.HasScheduleCompleted__c = false; 
                order.IF_FreePass__c = true;
                update order;
            }
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('savePaymentSchedule : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 수금스케줄 Wrapper
    **/
    public class HeaderWrapper {
        @AuraEnabled public String  recordId   {get;set;}
        @AuraEnabled public Date    docuDate   {get;set;}
        @AuraEnabled public Date    reqDDate   {get;set;}

        @AuraEnabled public String  draftPick  {get;set;}
        @AuraEnabled public String  draftText  {get;set;}
        @AuraEnabled public String  draftcheck {get;set;}

        @AuraEnabled public Decimal subTotal   {get;set;}
        @AuraEnabled public Decimal tax        {get;set;}
        @AuraEnabled public Decimal totalAmt   {get;set;}

        @AuraEnabled public String  curr       {get;set;}
        @AuraEnabled public Decimal inputAmt   {get;set;}
        @AuraEnabled public Decimal balance    {get;set;}

        @AuraEnabled public Boolean hasPricingProcessed {get;set;}

        public HeaderWrapper(){}
        public HeaderWrapper(PaymentSchedule__c ps, Boolean isProcessed){
            this.docuDate   = ps.DocumentDate__c;
            this.reqDDate   = ps.ReqDeliveryDate__c;

            this.draftPick  = ps.DraftNo__c;
            this.draftText  = ps.DraftNoText__c;
            this.draftcheck = ps.DraftCheck__c;

            this.subTotal   = ps.Subtotal__c;
            this.tax        = ps.Tax__c;
            this.totalAmt   = ps.TotalAmount__c;

            this.curr       = ps.CurrencyIsoCode;
            this.inputAmt   = 0;
            this.balance    = 0;

            this.hasPricingProcessed = isProcessed;
        }
    }

    /**
    * @description 수금스케줄 아이템 Wrapper
    **/
    public class ItemWrapper {
        @AuraEnabled public String  type         {get;set;}
        @AuraEnabled public Date    scheduleDate {get;set;}
        @AuraEnabled public String  paymentTerms {get;set;}
        @AuraEnabled public Decimal days         {get;set;}
        @AuraEnabled public String  capitalCom   {get;set;}
        @AuraEnabled public Decimal inputAmt     {get;set;}
        @AuraEnabled public Decimal principal    {get;set;}
        @AuraEnabled public Decimal receivedAmt  {get;set;}
        
        @AuraEnabled public Boolean paymentDisabled {get;set;}
        @AuraEnabled public Boolean capitalDisabled {get;set;}
        @AuraEnabled public Boolean isChecked       {get;set;}
        
        @AuraEnabled public Decimal num  {get;set;}
        @AuraEnabled public String  curr {get;set;}

        public ItemWrapper(String curr){
            this.type         = '';
            this.scheduleDate = null;
            this.paymentTerms = '';
            this.days         = 0;
            this.capitalCom   = '';
            this.inputAmt     = 0;
            this.principal    = 0;
            this.receivedAmt  = 0;
            this.curr         = curr;

            this.paymentDisabled = false;
            this.capitalDisabled = true;
            this.isChecked = false;
        }

        public ItemWrapper(PaymentScheduleItem__c item, String curr){
            this.type         = item.Type__c;
            this.scheduleDate = item.ScheduledDate__c;
            this.paymentTerms = item.PaymentTerms__c;
            this.days         = item.Days__c;
            this.capitalCom   = item.CapitalCompany__c;
            this.inputAmt     = 0;
            this.principal    = item.InstallmentPrincipal__c;
            this.receivedAmt  = item.ReceivedAmount__c;
            this.curr         = curr;

            this.paymentDisabled = false;
            this.capitalDisabled = !CAPITALS.contains(item.PaymentTerms__c);
            this.isChecked = false;
        }
    }

    /**
    * @description Draft No가 유효한지 확인하는 I/F 호출
    **/
    @AuraEnabled
    public static ResultWrapper checkDraftNo(String draftNo, String draftLabel, String recordId){
        ResultWrapper result = new ResultWrapper();
        try {
            IF_ERP_Order_Classes.IF_ORDER_015_Req parameters = new IF_ERP_Order_Classes.IF_ORDER_015_Req();
            parameters.I_DRAFTNO = draftNo;
            IF_ERP_Order method = new IF_ERP_Order();
            IF_ERP_Order_Classes.IF_ORDER_015_Res response = method.IF_ORDER_015(parameters);

            if(response.O_RETURN.TYPE == 'E') {
                result.isSuccess = false;
                result.errorMsg  = response.O_RETURN.MESSAGE;
            } else {
                List<PaymentSchedule__c> psList = [SELECT Id, DraftNoText__c, DraftCheck__c, DraftNo__c, Order__c, Order__r.HasScheduleCompleted__c FROM PaymentSchedule__c WHERE Order__c =: recordId];
                Boolean isNew = psList.isEmpty();

                PaymentSchedule__c ps = isNew ? new PaymentSchedule__c() : psList[0];
                ps.DraftNoText__c = draftNo;
                ps.DraftNo__c     = draftLabel;
                ps.DraftCheck__c  = 'Success';
                if(isNew) ps.Order__c = recordId;

                List<PaymentSchedule__c> toUpsert = new List<PaymentSchedule__c>{ps};
                upsert toUpsert;

                if(toUpsert[0].Order__r.HasScheduleCompleted__c) {
                    Order order = new Order(Id = recordId, HasScheduleCompleted__c = false, IF_FreePass__c = true);
                    update order;
                }
            }

            return result;
        } catch (Exception e) {
            System.debug('checkDraftNo : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 결과 반환 Wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String errorMsg  {get;set;}
        public ResultWrapper(){
            this.isSuccess = true;
            this.errorMsg  = '';
        }
    }

    /**
    * @description ERP로 수금 스케줄 전송
    **/
    @AuraEnabled
    public static Map<String, Object> sendScheduleToERP(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        try {
            
            List<PaymentSchedule__c> psList = [
                SELECT  Id, TotalAmount__c, DraftCheck__c, PlanNo__c 
                        , Order__r.HasPricingProcessed__c, Order__r.DCAmount__c, Order__r.TotalAmount
                FROM    PaymentSchedule__c 
                WHERE   Order__c =: recordId
            ];

            if(psList.isEmpty()) {
                result.put('isSuccess', false);
                result.put('errorMsg', System.Label.DNS_M_AddPaymentSchedule); // Please complete the payment schedule first.
                return result;
            } 

            PaymentSchedule__c ps = psList[0];

            Decimal tempSubTotal  = (ps.Order__r.DCAmount__c == 0 || ps.Order__r.DCAmount__c == null) ? ps.Order__r.TotalAmount : ps.Order__r.DCAmount__c;
            Decimal tempTax       = tempSubTotal * 0.1;
            Decimal tempTotal     = tempSubTotal + tempTax;
            Decimal tempItemTotal = 0;
            List<PaymentScheduleItem__c> pItems = [SELECT InstallmentPrincipal__c FROM PaymentScheduleItem__c WHERE PaymentSchedule__c =: ps.Id];
            for(PaymentScheduleItem__c item : pItems) {
                tempItemTotal += item.InstallmentPrincipal__c ?? 0;
            }

            if(tempTotal != tempItemTotal) {
                result.put('isSuccess', false);
                result.put('errorMsg', System.Label.DNS_M_RemainAmt); // There are amounts with unspecified payment methods.
                return result;
            }
            
            List<OrderPricingSelected__c> orderSelecteds = [SELECT Id FROM OrderPricingSelected__c WHERE Order__c =: recordId];

            if(!orderSelecteds.isEmpty() && ps.DraftCheck__c != 'Success') {
                result.put('isSuccess', false);
                result.put('errorMsg', System.Label.DNS_M_ValidationDraftNo); // Validation is required to ensure that the Draft No is valid.
                return result;
            }
            
            IF_ERP_Order_Classes.IF_ORDER_014_Res response = sendToERP(recordId);
            if(response.O_MESSAGE.startsWith('E')) {
                result.put('isSuccess', false);
                result.put('errorMsg', response.O_MESSAGE);
                return result;
            } else {
                ps.PlanNo__c = response.O_IPLAN;
                update ps;

                Order order = new Order(Id = recordId, HasScheduleCompleted__c = true, IF_FreePass__c = true);
                update order;
                
                result.put('isSuccess', true);
            }
            
            return result;
            
        } catch (Exception e) {
            System.debug('sendScheduleToERP : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description ERP전송 데이터 맵핑
    **/
    private static IF_ERP_Order_Classes.IF_ORDER_014_Res sendToERP(String recordId){

        List<PaymentSchedule__c> psList = [
            SELECT  Id
                    , ReqDeliveryDate__c
                    , PlanNo__c
                    , TotalAmount__c
                    , CurrencyIsoCode
                    , Order__r.Owner__c
                    , Order__r.Owner__r.CustomerCode__c
                    , Order__r.Owner__r.Account.CustomerCode__c
                    , Order__r.SalesOrganization__c
                    , Order__r.DistributionChannel__c
                    , Order__r.Division__c
                    , Order__r.OrderType__c
                    , (
                        SELECT  Id, CurrencyIsoCode, CapitalCompany__c, InstallmentPrincipal__c, Days__c, ScheduledDate__c, PaymentTerms__c, Type__c
                        FROM    PaymentScheduleItem__r
                    )
            FROM    PaymentSchedule__c 
            WHERE   Order__c =: recordId
        ];
        PaymentSchedule__c ps = psList[0];
        Map<Id, Boolean> flagMap = ordSvc.getUserFlag(new Set<Id>{ps.Order__r.Owner__c});
        Boolean isUser = flagMap.get(ps.Order__r.Owner__c);

        List<IF_ERP_Order_Classes.IF_ORDER_014_Req_ITAB> ITAB_List = new List<IF_ERP_Order_Classes.IF_ORDER_014_Req_ITAB>();
        for(PaymentScheduleItem__c psItem : ps.PaymentScheduleItem__r) {
            IF_ERP_Order_Classes.IF_ORDER_014_Req_ITAB ITAB = new IF_ERP_Order_Classes.IF_ORDER_014_Req_ITAB();
            ITAB.INCOM_CODE = psItem.Type__c;
            ITAB.ZTERM      = psItem.PaymentTerms__c;
            ITAB.EST_DAT    = ordSvc.formatDateForSAP(psItem.ScheduledDate__c, true);
            ITAB.EST_AMT    = String.valueOf(psItem.InstallmentPrincipal__c);
            ITAB.ZBD1T      = String.valueOf(psItem.Days__c);
            ITAB.FA_CODE    = psItem.CapitalCompany__c;
            ITAB.WAERK      = psItem.CurrencyIsoCode;
            ITAB_List.add(ITAB);
        }

        IF_ERP_Order_Classes.IF_ORDER_014_Req req = new IF_ERP_Order_Classes.IF_ORDER_014_Req();
        req.I_VKORG = ps.Order__r.SalesOrganization__c;
        req.I_VTWEG = ps.Order__r.DistributionChannel__c;
        req.I_SPART = ps.Order__r.Division__c;
        req.I_AUART = ps.Order__r.OrderType__c;
        req.I_BUKRS = ps.Order__r.SalesOrganization__c.substring(0, 2) + '00';
        req.I_BDATE = ordSvc.formatDateForSAP(ps.ReqDeliveryDate__c, true);
        if(!Test.isRunningTest()) {

            req.I_KUNNR = isUser ? ps.Order__r.Owner__r.CustomerCode__c : ps.Order__r.Owner__r.Account.CustomerCode__c;
        }
        req.I_NETWR = String.valueOf(ps.TotalAmount__c);
        req.I_WAERK = ps.CurrencyIsoCode;
        if(String.isNotBlank(ps.PlanNo__c)) req.I_IPLAN = ps.PlanNo__c;
        req.ITAB    = ITAB_List;

        IF_ERP_Order instance = new IF_ERP_Order();
        IF_ERP_Order_Classes.IF_ORDER_014_Res response = instance.IF_ORDER_014(req);
        return response;
    }
}