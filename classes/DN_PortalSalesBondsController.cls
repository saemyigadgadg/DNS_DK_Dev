/**
 * @description       : (포탈) 영업 > 채권관리 > 기간별 수금실적
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 07-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-09-2024   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_PortalSalesBondsController {
    public DN_PortalSalesBondsController() {}

    // 로그인 사용자 정보 조회
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
        String userId = System.UserInfo.getUserId();
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId);
        return dealerInfo;
    } 

    // 기간별 수금실적 조회
    @AuraEnabled
    public static List<BondsInfo> GetArInfo (paramWrapper param, DN_PortalLoginUser.DealerInfo dli){
        try {
            IF_ERP_Dealer_Classes.IF_DEALER_005_Req_IR_DATE temp_ir_date = new IF_ERP_Dealer_Classes.IF_DEALER_005_Req_IR_DATE();

            temp_ir_date.SIGN       = 'I';
            temp_ir_date.OPTION     = 'BT';
            temp_ir_date.LOW        = param.startDate;
            temp_ir_date.HIGH       = param.endDate;

            // 고객 코드
            List<IF_ERP_Dealer_Classes.IF_DEALER_005_Req_T_KUNNR> t_kunnr = new List<IF_ERP_Dealer_Classes.IF_DEALER_005_Req_T_KUNNR>();
            
            /* 
            IF_DEALER_005_Req_T_KUNNR 에 대한 입력값이 초기 디자인과 달라지면서 급하게 수정되었습니다.
            IF_DEALER_005_Req_T_KUNNR 의 필드가 빈값으로 들어가면 수천건이 조회되어 멈추거나 조회 실패하기 때문에 
            if 문을 사용하여 코드가 있는 경우에만 값을 넣도록 만들었습니다. 
            */
            if(param.customerCode != '') {
                IF_ERP_Dealer_Classes.IF_DEALER_005_Req_T_KUNNR kunnr = new IF_ERP_Dealer_Classes.IF_DEALER_005_Req_T_KUNNR();
                kunnr.LOW     = param.customerCode;
                t_kunnr.add(kunnr);
            }


            // 딜러 코드
            IF_ERP_Dealer_Classes.IF_DEALER_005_Req wrapper = new IF_ERP_Dealer_Classes.IF_DEALER_005_Req();
     
            wrapper.I_BUKRS   = dli.salesOrganization;  // 판매 조직
            wrapper.I_KUNNR   = dli.dealerCode;         // 딜러 코드

            wrapper.I_LOCAL   = 'X'; // ko, KR, KO, kr 인 경우 조회 X >> X 만 인식. 
            // wrapper.I_LOCAL   = dli.country;
            wrapper.I_VKORG   = dli.salesOrganization;
            wrapper.I_VTWEG   = dli.distributionChannel;
            wrapper.I_SPART   = dli.division;
            

            wrapper.IR_DATE  = temp_ir_date;
            wrapper.T_KUNNR  = t_kunnr;

            IF_ERP_Dealer method = new IF_ERP_Dealer();
            IF_ERP_Dealer_Classes.IF_DEALER_005_Res result = method.IF_DEALER_005(wrapper);

            List<IF_ERP_Dealer_Classes.IF_DEALER_005_Res_T_OUT> t_out = (List<IF_ERP_Dealer_Classes.IF_DEALER_005_Res_T_OUT>) result.T_OUT;
            List<BondsInfo> bList = new List<BondsInfo>();
            
            for(IF_ERP_Dealer_Classes.IF_DEALER_005_Res_T_OUT out : t_out) {
                BondsInfo bRecord = new BondsInfo(out);
                bList.add(bRecord);
            }

            return bList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class paramWrapper {
        @AuraEnabled public String startDate    {get; set;}
        @AuraEnabled public String endDate      {get; set;}
        @AuraEnabled public String customerCode {get; set;}

        public paramWrapper() {}
    }

    public class BondsInfo {
        @AuraEnabled public String salesOffice        {get; set;}  // 판매부서
        @AuraEnabled public String customerCode       {get; set;}  // 고객코드
        @AuraEnabled public String customerName       {get; set;}  // 수금처
        @AuraEnabled public String ceoName            {get; set;}  // 대표자명
        @AuraEnabled public String shipToParty        {get; set;}  // Ship to party
        @AuraEnabled public String saleDate           {get; set;}  // 판매일
        @AuraEnabled public String orderNo            {get; set;}  // 오더번호
        @AuraEnabled public String netDueDate         {get; set;}  // 수금예정일
        @AuraEnabled public String issueDate          {get; set;}  // 발행일
        @AuraEnabled public String postingDate        {get; set;}  // 반제일자
        @AuraEnabled public String paymentTerm        {get; set;}  // 지급조건
        @AuraEnabled public String recTotal           {get; set;}  // 총액
        @AuraEnabled public String recAmount          {get; set;}  // 금액
        @AuraEnabled public String overdueInterest    {get; set;}  // 연체이자
        @AuraEnabled public String bondType           {get; set;}  // 타입
        @AuraEnabled public String docNo              {get; set;}  // 문서번호
        @AuraEnabled public String userId             {get; set;}  // 유저 ID
        @AuraEnabled public String userName           {get; set;}  // 유저명
        @AuraEnabled public String currenyKey         {get; set;}  // 통화

        public BondsInfo(IF_ERP_Dealer_Classes.IF_DEALER_005_Res_T_OUT out) {
            this.salesOffice        = out.VKBUR;     // 판매부서
            this.customerCode       = out.KUNNR;     // 고객코드
            this.customerName       = out.NAME1;     // 수금처
            this.ceoName            = out.REPRE;     // 대표자명
            this.shipToParty        = out.SHIP_NAME; // Ship to party
            this.saleDate           = out.SALEDT;    // 판매일
            this.orderNo            = out.ZUONR;     // 오더번호
            this.netDueDate         = out.FAEDT;     // 수금예정일
            this.issueDate          = out.BLDAT;     // 발행일
            this.postingDate        = out.BUDAT;     // 반제일자
            this.paymentTerm        = out.ZTERM;     // 지급조건
            this.recTotal           = plusPrice(out.TOTAL, out.WAERS);     // 총액
            this.recAmount          = plusPrice(out.WRBTR, out.WAERS);     // 금액
            this.overdueInterest    = out.ARREAR;    // 연체이자
            this.bondType           = out.BLART;     // 타입
            this.docNo              = out.AUGBL;     // 문서번호
            this.userId             = out.USNAM;     // 유저 ID
            this.userName           = out.NAME_LAST; // 유저명
            this.currenyKey         = out.WAERS;     // 통화

        }        
        public BondsInfo() {}
    }

    private static String plusPrice(String valueStr, String curr) {
        if(curr == 'KRW') {
            Decimal value = Decimal.valueOf(valueStr) * -100;
            return String.valueOf(value);
        } else {
            Decimal value = Decimal.valueOf(valueStr) * -1;
            return String.valueOf(value);
        }
    }
}