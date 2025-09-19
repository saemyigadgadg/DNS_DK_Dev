/**
 * @description       : (포탈) 영업 > 채권 관리 > 주문별 수금 일정
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 09-01-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-13-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_ScheduleCollectionofOrderController {
    public DN_ScheduleCollectionofOrderController() {}

    // 로그인 사용자 정보 조회
    @AuraEnabled
    public static DN_PortalLoginUser.DealerInfo GetUserInfo(){
            String userId = System.UserInfo.getUserId();
            // DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId);
            // return dealerInfo;
            return DN_PortalLoginUser.GetUserInfo(userId);
    }

    // 수금 일정 조회
    @AuraEnabled
    public static orderSchedule GetOrderSchedule(DN_PortalLoginUser.DealerInfo dli, String cc, String oNo, Boolean rev){
        try {
            IF_ERP_Dealer_Classes.IF_DEALER_007_Req res007 = new IF_ERP_Dealer_Classes.IF_DEALER_007_Req();

            system.debug('회사 코드 >>> '+dli.salesOrganization);
            system.debug('고객 코드 >>> '+cc);
            system.debug('계약 코드 >>> '+oNo);


            res007.I_BUKRS = dli.salesOrganization; // 회사 코드
            res007.I_KUNNR = cc;                    // 고객 코드
            res007.I_ZUONR = oNo;                   // 계약 번호
            // res007.I_BASE = '';
            if(rev) {
                res007.I_REVERSE = 'X';
            }
            // res007.I_ALT = '';

            IF_ERP_Dealer method = new IF_ERP_Dealer();
            IF_ERP_Dealer_Classes.IF_DEALER_007_Res result = method.IF_DEALER_007(res007);
            system.debug('딜러 007 >>> '+result);
            system.debug('length >> '+ result.T_ORDER.size());
            if(result.T_ORDER.size() > 0) {
            // 판매정보
            LIST<IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_ORDER> t_order = (LIST<IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_ORDER>) result.T_ORDER;
            
            // 재조정 매출 채권 모달
            LIST<IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_DOWN> t_down = (LIST<IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_DOWN>) result.T_DOWN;
            
            // List
            LIST<IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_LIST> t_list = (LIST<IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_LIST>) result.T_LIST;

            orderSchedule orderSchedule = new OrderSchedule(t_order[0], t_down, t_list);
            return orderSchedule;

            } else {
                return new orderSchedule();
            }
            
        } catch (Exception e) {
            system.debug('007 E Msg :: '+e.getMessage());
            system.debug('007 T Line :: '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }


    /* _________________________________________________________________________________________________________________________ */
    /* ------------------------------------------------------------------------------------------------------------------------- */

    public class OrderSchedule {
        // 판매 정보
        @AuraEnabled public String contractNo       {get; set;}  // 계약번호
        @AuraEnabled public String customerCode     {get; set;}  // 고객코드
        @AuraEnabled public String saleOrganization {get; set;}  // 판매부서
        @AuraEnabled public String saleCEO          {get; set;}  // 대표자
        @AuraEnabled public String rescheduleBond   {get; set;}  // 재조정 매출채권
        @AuraEnabled public String salePrice        {get; set;}  // 판매금액
        @AuraEnabled public String billingDate      {get; set;}  // 발령일자

        // 매출채권금액
        @AuraEnabled public String colExpAmt     {get; set;} // 수금예정금액
        @AuraEnabled public String colAmt        {get; set;} // 수금금액
        @AuraEnabled public String balAmt        {get; set;} // 미결잔액

        @AuraEnabled public Boolean isCollection {get; set;} // 수금완료
        @AuraEnabled public Decimal isCheck      {get; set;} // ???    

        // 재조정 매출채권 (Adjusted Accounts Receivable)
        @AuraEnabled public List<AAR> aar        {get; set;} // 재조정 매출채권 값

        // 계약 상세            
        @AuraEnabled public List<ContractDetail> ContractDetail   {get; set;}  // 계약 상세

        public OrderSchedule () {}

        public OrderSchedule (IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_ORDER t_order, List<IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_DOWN> t_down, LIST<IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_LIST> t_list) {

            // 판매 정보(t_order)
            this.contractNo       = t_order.VBELV;       // 오더번호 (or ZUONR)
            this.customerCode     = t_order.KUNNR;       // 고객
            this.saleOrganization = t_order.VKBUR_NAME;  // 판매부서
            this.saleCEO          = t_order.CEO;         // 대표자
            this.rescheduleBond   = formatPrice('No',t_order.OVER_INCOM, t_order.WAERS); // 재조정 매출채권  // OVER_INCOM or DOWN_PAY  // 통화 = WAERS
            this.salePrice        = ''; // 판매금액
            this.billingDate      = t_order.AUDAT.replace('-','.'); // 빌링일자

            // 매출채권금액(t_order)
            this.colExpAmt    = t_order.WAERS; // 수금예정금액
            this.colAmt       = formatPrice('Yes', t_order.CL_DMBTR, t_order.WAERS); // 수금금액 CL_DMBTR or CL_WRBTR or DMBTR
            this.balAmt       = formatPrice('Yes', t_order.WRBTR, t_order.WAERS);  // 미결잔액
            this.isCollection = (Decimal.valueOf(t_order.WRBTR) - Decimal.valueOf(t_order.CL_WRBTR)) == 0;
            this.isCheck      = Decimal.valueOf(t_order.WRBTR) - Decimal.valueOf(t_order.CL_WRBTR);

            // 재조정 매출채권 (Adjusted Accounts Receivable)
            this.aar = new List<AAR>();
            for(IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_DOWN down : t_down) {
                this.aar.add(new AAR(down));
            }

            // 계약 상세            
            this.ContractDetail = new List<ContractDetail>();
            for (IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_LIST tlist : t_list) {
                this.ContractDetail.add(new ContractDetail(tlist));
            }
        }
    }

    // 재조정 매출채권 (Adjusted Accounts Receivable)    
    public class AAR {
        @AuraEnabled public String amount       {get; set;} // 금액
        @AuraEnabled public String confirmAmt   {get; set;} // 확정금액
        @AuraEnabled public String docNo        {get; set;} // 청산 문서 번호
        @AuraEnabled public String fiscalYear   {get; set;} // 회계 연도 청산
        @AuraEnabled public String curr         {get; set;} // 통화

        public AAR(IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_DOWN down) {
            amount      = down.DMBTR; // 금액  DMBTR or NETWR or WRBTR 중에 하나일 뜻. 값 보고 X100 해야 할 수도 있음.
            confirmAmt  = plusPrice(down.CL_DMBTR, down.WAERS); // 확정금액
            docNo       = down.AUGBL; // 청산 문서 번호
            fiscalYear  = down.AUGGJ; // 회계 연도 청산
            curr        = down.WAERS; // 통화
        }
    }    

    public class ContractDetail {
        // card 01
        @AuraEnabled public String docNo       {get; set;}  // 문서번호
        @AuraEnabled public String itemNo      {get; set;}  // 번호
        @AuraEnabled public String colExpDt    {get; set;}  // 수금예정일
        @AuraEnabled public String payTerm     {get; set;}  // 지급조건

        // card 02
        @AuraEnabled public String amount      {get; set;}  // 금액
        @AuraEnabled public String fixedAmt    {get; set;}  // 확정금액
        @AuraEnabled public String docDate     {get; set;}  // 문서일자
        @AuraEnabled public String soYear      {get; set;}  // 년도
        @AuraEnabled public String clearSlip   {get; set;}  // 반제전표
        @AuraEnabled public String soDate      {get; set;}  // 일자
        @AuraEnabled public String payDate     {get; set;}  // 입금일자
        @AuraEnabled public String calcRefDate {get; set;}  // 계산 기준일자
        @AuraEnabled public String docType     {get; set;}  // 문서유형
        @AuraEnabled public String odIntAmt    {get; set;}  // 연체이자 발생액
        @AuraEnabled public String noteInt     {get; set;}  // 어음이자

        public ContractDetail (IF_ERP_Dealer_Classes.IF_DEALER_007_Res_T_LIST tlist) {
            // // card 01
            this.docNo       = tlist.BELNR; // 문서번호
            this.itemNo      = tlist.BUZEI; // 번호
            this.colExpDt    = tlist.FAEDT.replace('-','.'); // 수금예정일
            this.payTerm     = tlist.ZTERM; // 지급조건

            // // card 02
            this.amount      = formatPrice('Yes', tlist.WRBTR, tlist.WAERS); // 금액
            this.fixedAmt    = formatPrice('Yes', tlist.DMBTR, tlist.WAERS); // 확정금액
            this.docDate     = tlist.BUDAT.split('-')[0] == '0000' ? '' : tlist.BUDAT.replace('-','.'); // 문서일자
            this.soYear      = tlist.AUGGJ; // 년도
            this.clearSlip   = tlist.AUGBL; // 반제전표
            this.soDate      = tlist.BLDAT.split('-')[0] == '0000' ? '' : tlist.BLDAT.replace('-','.'); // 일자
            this.payDate     = tlist.INDAT.split('-')[0] == '0000' ? '' : tlist.INDAT.replace('-','.'); // 입금일자
            this.calcRefDate = tlist.CAL_DAY.split('-')[0] == '0000' ? '' : tlist.CAL_DAY.replace('-','.'); // 계산 기준일자
            this.docType     = tlist.BLART; // 문서유형
            this.odIntAmt    = tlist.OVDUE; // 연체이자 발생액 (or INT_AMT)
            this.noteInt     = String.valueOf(Integer.valueOf(tlist.REC_INT)); // 어음이자
            // this.noteInt     = String.valueOf(tlist.REC_INT) == '0.00' ? '0' : tlist.REC_INT; // 어음이자
        }

        public ContractDetail () {}
    }

    /* _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- */
    /* _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- */
    
    private static String plusPrice(String valueStr, String curr) {
        if(curr == 'KRW') {
            Decimal value = Decimal.valueOf(valueStr) * -100;
            return String.valueOf(value);
        } else {
            Decimal value = Decimal.valueOf(valueStr) * -1;
            return String.valueOf(value);
        }
    }

    private static String formatPrice(String re, String valueStr, String curr) {
        try {
            Decimal value;
            if(curr == 'KRW') {
                if(re == 'Yes') {
                    value = Decimal.valueOf(valueStr) * 100;    
                }else if(re == 'No'){
                    value = Decimal.valueOf(valueStr) * -100;
                }
            }
            else{
                if(re == 'Yes') {
                    value = Decimal.valueOf(valueStr) * 1;    
                }else if(re == 'No') {
                    value = Decimal.valueOf(valueStr) * -1;
                }
            }

            Long roundedValue = value.longValue();
            system.debug('length : ' +valueStr.length());
            if(valueStr.length() > 4) {
                String formattedValue = InputComma(roundedValue);
                return formattedValue;    
            } else {
                return String.valueOf(roundedValue);
            }
        } catch (Exception e) {
            system.debug('Emsg : '+e.getMessage());
            system.debug('Line : '+e.getLineNumber());
            return 'fail';
        }
    }

    private static String InputComma(Long value) {
        try {
            String price = Decimal.valueOf(value).format();
            system.debug(price);
            return price;
        } catch (Exception e) {
            system.debug('Emsg : ' + e.getMessage());
            system.debug('Line : ' + e.getLineNumber());
            return 'three fail';
        }
    }
}