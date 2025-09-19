/**
 * @description       : [DN_Order_NoticePage] 수주통지서
 * @test              : DN_OrderNoticeControllerTest
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-12   yeongju.yun   Initial Version
**/
public with sharing class DN_OrderNoticeController {
    public static DN_OrderService ordSvc = new DN_OrderService();

    public IF_ERP_Order_Classes.IF_ORDER_003_Res_OS_TITLE        title    {get;set;}
    public IF_ERP_Order_Classes.IF_ORDER_003_Res_OS_HEADER       header   {get;set;}
    public List<IF_ERP_Order_Classes.IF_ORDER_003_Res_OT_DATA>   prodData {get;set;}
    public List<IF_ERP_Order_Classes.IF_ORDER_003_Res_OT_INCOMH> incomeH  {get;set;}
    public List<IF_ERP_Order_Classes.IF_ORDER_003_Res_OT_TEXT>   text01   {get;set;}
    public List<IF_ERP_Order_Classes.IF_ORDER_003_Res_OT_TEXT02> text02   {get;set;}
    
    public List<IncomeWrapper> incom {get;set;}

    /**
    * @description Visualforce Page (수주통지서) 데이터 조회 (order에 적재 되어있음)
    **/
    public DN_OrderNoticeController(ApexPages.StandardController controller) {

        try{
            Id orderId = ApexPages.CurrentPage().getparameters().get('Id');

            Order order = [SELECT Id, ERPOrderNo__c, ERPPSONo__c, OrderNotice__c, CurrencyIsoCode FROM Order WHERE Id =: orderId];

            IF_ERP_Order_Classes.IF_ORDER_003_Res wrapper = (IF_ERP_Order_Classes.IF_ORDER_003_Res) JSON.deserialize(order.OrderNotice__c, IF_ERP_Order_Classes.IF_ORDER_003_Res.class);
            title = wrapper.OS_TITLE;
            header = wrapper.OS_HEADER;

            // Code
            if(String.isNotBlank(header.VBELN)) { header.VBELN = header.VBELN.replaceFirst('^0+', ''); }
            
            // Date
            if(String.isNotBlank(header.APP_DATE)) { header.APP_DATE = header.APP_DATE.replace('-', '.'); }
            if(String.isNotBlank(header.PRT_DATE)) { header.PRT_DATE = header.PRT_DATE.replace('-', '.'); }
            if(String.isNotBlank(header.ERDAT))    { header.ERDAT    = header.ERDAT.replace('-', '.'); }
            if(String.isNotBlank(header.AEDAT))    { header.AEDAT    = header.AEDAT.replace('-', '.'); }
            if(String.isNotBlank(header.VDATU))    { header.VDATU    = header.VDATU.replace('-', '.'); }

            prodData = wrapper.OT_DATA;
            
            Map<String, String> paymentMap = ordSvc.getPicklistMap('Order', 'PaymentTerms__c');
            List<IncomeWrapper> wrapList = new List<IncomeWrapper>();
            Decimal totalAmt = 0;
            for(IF_ERP_Order_Classes.IF_ORDER_003_Res_OT_INCOM iRow : wrapper.OT_INCOM) {
                totalAmt += Decimal.valueOf(iRow.EST_AMT);
            }
            for(IF_ERP_Order_Classes.IF_ORDER_003_Res_OT_INCOM iRow : wrapper.OT_INCOM) {
                wrapList.add(new IncomeWrapper(iRow, paymentMap, totalAmt, order.CurrencyIsoCode));
            }
            incom = wrapList;

            incomeH  = wrapper.OT_INCOMH;
            text01   = wrapper.OT_TEXT;
            text02   = wrapper.OT_TEXT02;
        } catch (Exception e) {
            System.debug('constructor : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 수주통지서 조회 가능 여부 확인 및 실시간 I/F 호출하여 주문에 임시 적재
    **/
    @AuraEnabled
    public static Map<String, Object> validateOrder(String recordId, Boolean isCPO){
        try {
            Boolean isPass   = true;
            String errorMsg  = '';
            String vfPageUrl = '';
            
            Order order = [
                SELECT  Id, ERPOrderNo__c, ERPPSONo__c, OrderNotice__c 
                FROM    Order 
                WHERE   Id =: recordId
            ];
            if(isCPO && String.isBlank(order.ERPOrderNo__c)) {
                isPass   = false;
                errorMsg = System.label.DNS_M_OrderNoticeConfirmed; // The order notice is only allowed starting from the 'Order Confirmed' status.
            } else if(!isCPO && String.isBlank(order.ERPPSONo__c)) {
                isPass   = false;
                errorMsg = System.label.DNS_M_OrderNoticeMapped; // The order notice(PSO) is only allowed starting from the 'Order Mapped' status.
            }

            if(isPass) {

                IF_ERP_Order_Classes.IF_ORDER_003_Req IF_ORDER_003 = new IF_ERP_Order_Classes.IF_ORDER_003_Req();
                IF_ORDER_003.I_VBELN = isCPO ? order.ERPOrderNo__c : order.ERPPSONo__c;
    
                IF_ERP_Order method = new IF_ERP_Order();
                IF_ERP_Order_Classes.IF_ORDER_003_Res response = method.IF_ORDER_003(IF_ORDER_003);
    
                if(response.O_RETURN.TYPE == 'E') {
                    isPass   = false;
                    errorMsg = response.O_RETURN.MESSAGE;
                } else {
                    order.OrderNotice__c = JSON.serialize(response);
                    order.IF_FreePass__c = true;
                    update order;
                }

                if(ordSvc.IS_USER) {
                    vfPageUrl = '/apex/DN_Order_NoticePage';
                } else {
                    Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                    if(isSandbox) { vfPageUrl = '/' + ordSvc.PORTAL_NAME + '/DN_Order_NoticePage'; }
                    else { vfPageUrl = '/DN_Order_NoticePage'; }
                }
                
            }

            return new Map<String, Object>{
                'isPass'      => isPass
                , 'errorMsg'  => errorMsg
                , 'vfPageUrl' => vfPageUrl
            };
            
        } catch (Exception e) {
            System.debug('validateOrder : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 수주통지서 데이터 가공 Wrapper
    **/
    public class IncomeWrapper{
        public String  col1 {get;set;} // INCOM_CODE
        public String  col2 {get;set;} // ZTERM
        public String  col3 {get;set;} // ZBD1T
        public String  col4 {get;set;} // EST_DAT
        public Decimal col5 {get;set;} // EST_AMT
        public Decimal col6 {get;set;} // EST_AMT %
        public String  col7 {get;set;} // curruncy
        
        public IncomeWrapper(){}
        public IncomeWrapper(IF_ERP_Order_Classes.IF_ORDER_003_Res_OT_INCOM i, Map<String, String> paymentMap, Decimal totalAmt, String curr){
            this.col1 = i.INCOM_CODE;
            this.col2 = paymentMap.get(i.ZTERM);
            this.col3 = i.ZBD1T;
            this.col4 = i.EST_DAT.replace('-', '.');
            this.col5 = Decimal.valueOf(i.EST_AMT) * 100;
            this.col6 = (Decimal.valueOf(i.EST_AMT) / totalAmt * 100).setScale(2);
            this.col7 = curr;
        }

    }
}