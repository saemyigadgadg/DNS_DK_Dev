/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 07-17-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-27-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_PortalPartDeliveryStatusController {
    public DN_PortalPartDeliveryStatusController() {}

    // 배송상태 - 로그인 사용자 정보 확인
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
        try {
            String userId = System.UserInfo.getUserId();
            DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId);
            return dealerInfo;

        } catch (Exception e) {
            system.debug('유저 에러 메세지 :: '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    } 

    // 배송상태 - 검색(조회)
    @AuraEnabled
    public static List<DeliveryStatus> GetDeliveryStateInfo(DN_PortalLoginUser.DealerInfo dli, SearchTerms sts){
        try {
            IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Req req = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Req();

            req.I_FDATE = sts.startDate;         // 시작 날짜
            req.I_TDATE = sts.endDate;           // 종료 날짜
            
            req.I_VBELN = sts.orderNo;           // 주문번호
            req.I_MATNR = sts.partNo;            // 품번
            req.I_BSTNK = sts.customerOrderNo;   // 고객 주문 번호
            req.I_LANGU = dli.language;          // 딜러 언어 코드
    
            req.I_GUBUN = sts.shippingState;     // 상태 (A : 출하대기, B : 탁송완료)

            // req.I_TKNUM = st.deliveryNo;        // 배송번호(탁송번호)

            
            IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Req_I_USERINFO();

            I_USERINFO.KUNNR        = dli.dealerCode;          // 딜러 대리점 코드 >> 1846 O
            I_USERINFO.VKORG        = dli.salesOrganization;   // 딜러 so
            I_USERINFO.VTWEG        = dli.distributionChannel; // 딜러 dc
            I_USERINFO.SPART        = dli.division;            // 딜러 ds
            I_USERINFO.LAND1        = dli.country;             // 딜러 국가 코드
            I_USERINFO.DF_CHK       = 'X';                    // 뭘까?
            req.I_USERINFO          = I_USERINFO;
        
            IF_ERP_Parts_Shipping instance = new IF_ERP_Parts_Shipping();
            IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res result = instance.IF_PARTS_015(req);
            List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_T_LIST> list015 = (List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_T_LIST>) result.T_LIST;

            List<DeliveryStatus> dsList = new List<DeliveryStatus>();
            for(IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_T_LIST ds : list015) {
                DeliveryStatus record = new DeliveryStatus(ds);
                dsList.add(record);
            }

            return dsList;
         
        } catch (Exception e) {
            system.debug('GetDeliveryStateInfo Emsg :: '+e.getMessage());
            system.debug('GetDeliveryStateInfo track :: '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class SearchTerms{
        @AuraEnabled public String startDate        {get; set;}
        @AuraEnabled public String endDate          {get; set;}
        @AuraEnabled public String deliveryNo       {get; set;}
        @AuraEnabled public String orderNo          {get; set;}
        @AuraEnabled public String shippingNo       {get; set;}
        @AuraEnabled public String customerOrderNo  {get; set;}
        @AuraEnabled public String partNo           {get; set;}
        @AuraEnabled public String shippingState    {get; set;}
        
        public SearchTerms() {}
    }

    public class DeliveryStatus {
        @AuraEnabled public String customerOrderNo          {get; set;}  // 고객주문번호
        @AuraEnabled public String orderNo                  {get; set;}  // 오더번호
        @AuraEnabled public String deliveryStatus           {get; set;}  // 상태
        @AuraEnabled public String deliveryStatusId         {get; set;}  // 상태Id
        @AuraEnabled public String deliveryNo               {get; set;}  // 배송번호
        @AuraEnabled public String shippingInstructionNo    {get; set;}  // 출하지시번호
        @AuraEnabled public String waybillNo                {get; set;}  // 운송장번호
        @AuraEnabled public String boxQty                   {get; set;}  // 박스수량
        @AuraEnabled public String totalWeight              {get; set;}  // 총중량
        @AuraEnabled public String unit                     {get; set;}  // 단위
        @AuraEnabled public String shippingType             {get; set;}  // 출하유형
        @AuraEnabled public String deliverer                {get; set;}  // 운송업자
        @AuraEnabled public String departureDate            {get; set;}  // 출발일자
        @AuraEnabled public String arrivalDate              {get; set;}  // 도착일자
        @AuraEnabled public String destination              {get; set;}  // 도착지
        @AuraEnabled public String sendTo                   {get; set;}  // 송부처

        public DeliveryStatus(IF_ERP_Parts_Shipping_Classes.IF_PARTS_015_Res_T_LIST ds) {
            this.customerOrderNo       = ds.BSTNK;      // 고객주문번호
            this.orderNo               = ds.VGBEL;      // 오더번호
            this.deliveryStatus        = ds.STTRG_T == 'Shipment completion' ? '탁송완료' : ds.STTRG_T;  // 상태 
            // this.deliveryStatus        = ds.STTRG_T == 'Shipment completion' ? '탁송완료' : ds.STTRG_T == 'Planned' ? 'Planned' : 'Planing Completed';  // 상태 
            // this.deliveryStatus        = ds.STTRG == '5' ? '탁송완료' : ds.STTRG == '0' ? 'Planned' : ds.STTRG == '0' ? 'Planing Completed' : '할당값없음';  // 상태 
            this.deliveryStatusId      = ds.STTRG;      // 상태 ID
            this.deliveryNo            = ds.TKNUM;      // 배송번호
            this.shippingInstructionNo = ds.VBELN;      // 출하지시번호
            this.waybillNo             = ds.KDINVOICE.substringBefore('/').trim();  // 운송장번호
            this.boxQty                = ds.COUNT1;     // 박스수량 >> 혹은 COUNT2
            this.totalWeight           = String.valueOf(Decimal.valueOf(ds.BRGEW).setScale(2, RoundingMode.HALF_UP));  // 총중량
            this.unit                  = ds.GEWEI_MAX;  // 단위
            this.shippingType          = ds.BEZEI == 'Bus' ? '화물' : ds.BEZEI == 'Dom. Express' ? '택배' : '';  // 출하유형
            this.deliverer             = ds.NAME2;      // 운송업자
            this.departureDate         = ds.ZFOBDT;     // 출발일자
            this.arrivalDate           = ds.ZFETA;      // 도착일자
            this.destination           = ds.BEZEI20;    // 도착지
            this.sendTo                = ds.BEZEI_T;    // 송부처
        }

        public DeliveryStatus() {}
    }

    
    // 배송상태 - 배송번호 상세 조회
    @AuraEnabled
    public static List<DeliveryDetail> GetDeliveryDetail(DN_PortalLoginUser.DealerInfo dli, SearchTerms sts){
        try {
            IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Req part027 = new IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Req();

            part027.I_KUNNR = dli.dealerCode.leftPad(10, '0');
            part027.I_VKORG = dli.salesOrganization;
            part027.I_VTWEG = dli.distributionChannel;
            part027.I_SPART = dli.division;
            part027.I_LANGU = dli.language;

            part027.I_FDATE = sts.startDate;       // 시작 날짜
            part027.I_TDATE = sts.endDate;         // 종료 날짜

            part027.I_BSTNK = sts.customerOrderNo; // 고객 주문 번호
            part027.I_VBELN = sts.orderNo;         // 주문번호

            part027.I_TKNUM = sts.deliveryNo; // 배송번호

            IF_ERP_Parts_Shipping method = new IF_ERP_Parts_Shipping();
            IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res result = method.IF_PARTS_027(part027);
            List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_T_DETAIL> list027 = (List<IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_T_DETAIL>) result.T_DETAIL;
            system.debug('list027 >>> :: '+ list027);
            List<DeliveryDetail> dsList = new List<DeliveryDetail>();
            for(IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_T_DETAIL ds : list027) {
                DeliveryDetail record = new DeliveryDetail(ds);
                dsList.add(record);
            }

            return dsList;
        } catch (Exception e) {
            system.debug('GetDeliveryDetail Emsg :: '+e.getMessage());
            system.debug('GetDeliveryDetail Track :: '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DeliveryDetail {
        @AuraEnabled public String deliveryNo      {get; set;}
        @AuraEnabled public String orderNo         {get; set;}
        @AuraEnabled public String customerOrderNo {get; set;}
        @AuraEnabled public String orderPartNo     {get; set;}
        @AuraEnabled public String supplyPartNo    {get; set;}
        @AuraEnabled public String description     {get; set;}
        @AuraEnabled public String quantity        {get; set;}
        @AuraEnabled public String unitPrice       {get; set;}
        @AuraEnabled public String ddCurrency      {get; set;}
        @AuraEnabled public String sendTo          {get; set;}

        public DeliveryDetail(IF_ERP_Parts_Shipping_Classes.IF_PARTS_027_Res_T_DETAIL dd) {
            this.deliveryNo      = String.valueOf(Integer.valueOf(dd.TKNUM)); // 탁송번호
            this.orderNo         = dd.VBELN2;   // 오더번호
            this.customerOrderNo = dd.BSTKD;    // 고객주문번호
            this.orderPartNo     = dd.MATNR_SO; // 주문품번
            this.supplyPartNo    = dd.MATNR_SH; // 공급품번
            this.description     = dd.MAKTX;    // 설명
            this.quantity        = String.valueOf(Integer.valueOf(dd.LFIMG)); // 수량
            this.unitPrice       = dd.NETPR;    // 단위가격
            this.ddCurrency      = dd.WAERK;    // 통화
            this.sendTo          = dd.VTEXT;    // 송부처
        }
    }
}