/*
 *
 * @author : SUNG SEO UK
 * @createDate : 2024-11-06 
 */
public with sharing class IF_ERP_Dealer_Classes {
    public IF_ERP_Dealer_Classes() {}

/** IF_DEALER_001
    */  
    /**
         * ClassName            : IF_ERP_Dealer 
         * Wrapper Name         : IF_DEALER_001
         * SFDC interface Id    : IF-DEALER-001
         * AS-IS RFC            : 
         * New I/F              : ZCRM_FI_GET_AR_INCOM_DEALER
         * Description          : 담보 증액 금액 조회
     */
    /** REQUEST 
      */  
        public class IF_DEALER_001_Req {
          public IF_DEALER_001_Req(){} 
          @AuraEnabled public String I_BUKRS {get;set;} // ? Company Code
          @AuraEnabled public String I_KUNNR {get;set;} // ? Customer Number 1
        }

    /** RESPONSE 
      */      
        public class IF_DEALER_001_Res {
          public IF_DEALER_001_Res(){
            this.T_ORDER    = new List<IF_DEALER_001_Res_T_ORDER>();
            this.T_ORDER2   = new List<IF_DEALER_001_Res_T_ORDER2>();  
            this.T_LIST     = new List<IF_DEALER_001_Res_T_LIST>();
            this.T_DOWN     = new List<IF_DEALER_001_Res_T_DOWN>();
            this.T_ARSTATUS = new List<IF_DEALER_001_Res_T_ARSTATUS>(); 
            this.TotalAmount = 0;
          } 
          @AuraEnabled public List<IF_DEALER_001_Res_T_ORDER> T_ORDER {get;set;} 
          @AuraEnabled public List<IF_DEALER_001_Res_T_ORDER2> T_ORDER2 {get;set;} 
          @AuraEnabled public List<IF_DEALER_001_Res_T_LIST> T_LIST {get;set;} 
          @AuraEnabled public List<IF_DEALER_001_Res_T_DOWN> T_DOWN {get;set;} 
          @AuraEnabled public List<IF_DEALER_001_Res_T_ARSTATUS> T_ARSTATUS {get;set;} 
          @AuraEnabled public Integer TotalAmount {get;set;}
        }

        public class IF_DEALER_001_Res_T_ORDER { 
          public IF_DEALER_001_Res_T_ORDER(){}
          @AuraEnabled public String BUKRS  {get;set;} // ? Company Code
          @AuraEnabled public String ZUONR  {get;set;} // ? Assignment Number
          @AuraEnabled public String VBELV  {get;set;} // ? Originating document
          @AuraEnabled public String MATNR  {get;set;} // ? Material Number
          @AuraEnabled public String FKDAT  {get;set;} // ? Billing date for billing index and printout

          @AuraEnabled public String KUNNR  {get;set;} // ? Customer Number 1
          @AuraEnabled public String NAME1  {get;set;} // ? Name
          @AuraEnabled public String CEO    {get;set;} // ? Name of Representative
          @AuraEnabled public String GSBER  {get;set;} // ? Business Area
          @AuraEnabled public String ZTERM  {get;set;} // ? Terms of Payment Key

          @AuraEnabled public String VKBUR  {get;set;} // ? Sales Office
          @AuraEnabled public String VKBUR_NAME {get;set;} // ? Description
          @AuraEnabled public String NETWR  {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String DOWN_PAY {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String BOE_AMT {get;set;} // ? Net Value of the Sales Order in Document Currency

          @AuraEnabled public String OVER_INCOM {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String OPEN_INT {get;set;} // ? Interest amount
          @AuraEnabled public String REC_INT {get;set;} // ? Recived interest
          @AuraEnabled public String OPEN_SUM {get;set;} // ? Amount in document currency
          @AuraEnabled public String WAERS  {get;set;} // ? Currency Key

          @AuraEnabled public String REDUCE_INT {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String DMBTR  {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String WRBTR  {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String CL_DMBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String CL_WRBTR {get;set;} // ? Net Value of the Sales Order in Document Currency

          @AuraEnabled public String MTART  {get;set;} // ? Material Type
          @AuraEnabled public String MAKTX  {get;set;} // ? Material Description (Short Text)
          @AuraEnabled public String VKORG  {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG  {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART  {get;set;} // ? Division

          @AuraEnabled public String AUDAT  {get;set;} // ? Document Date (Date Received/Sent)
          @AuraEnabled public String PAPH1  {get;set;} // ? Prod.hierarchy01-1
          @AuraEnabled public String VTEXT1 {get;set;} // ? Description
          @AuraEnabled public String PAPH2  {get;set;} // ? Prod.hierarchy01-2
          @AuraEnabled public String VTEXT2 {get;set;} // ? Description

          @AuraEnabled public String ZZTERM {get;set;} // ? Payment Terms(Extension)
        }

        public class IF_DEALER_001_Res_T_ORDER2 { 
          public IF_DEALER_001_Res_T_ORDER2(){}
          @AuraEnabled public String BUKRS {get;set;} // ? Company Code
          @AuraEnabled public String ZUONR {get;set;} // ? Assignment Number
          @AuraEnabled public String VBELV {get;set;} // ? Originating document
          @AuraEnabled public String MATNR {get;set;} // ? Material Number
          @AuraEnabled public String FKDAT {get;set;} // ? Billing date for billing index and printout
          @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
          @AuraEnabled public String NAME1 {get;set;} // ? Name
          @AuraEnabled public String CEO   {get;set;} // ? Name of Representative
          @AuraEnabled public String GSBER {get;set;} // ? Business Area
          @AuraEnabled public String ZTERM {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String VKBUR {get;set;} // ? Sales Office
          @AuraEnabled public String VKBUR_NAME {get;set;} // ? Description
          @AuraEnabled public String NETWR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String DOWN_PAY {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String BOE_AMT {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String OVER_INCOM {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String OPEN_INT {get;set;} // ? Interest amount
          @AuraEnabled public String REC_INT {get;set;} // ? Recived interest
          @AuraEnabled public String OPEN_SUM {get;set;} // ? Amount in document currency
          @AuraEnabled public String WAERS {get;set;} // ? Currency Key
          @AuraEnabled public String REDUCE_INT {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String DMBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String WRBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String CL_DMBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String CL_WRBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String MTART {get;set;} // ? Material Type
          @AuraEnabled public String MAKTX {get;set;} // ? Material Description (Short Text)
          @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART {get;set;} // ? Division
          @AuraEnabled public String AUDAT {get;set;} // ? Document Date (Date Received/Sent)
          @AuraEnabled public String PAPH1 {get;set;} // ? Prod.hierarchy01-1
          @AuraEnabled public String VTEXT1 {get;set;} // ? Description
          @AuraEnabled public String PAPH2 {get;set;} // ? Prod.hierarchy01-2
          @AuraEnabled public String VTEXT2 {get;set;} // ? Description
          @AuraEnabled public String XBLNR {get;set;} // ? Reference Document Number
          @AuraEnabled public String AUGDT {get;set;} // ? Clearing Date
          @AuraEnabled public String ZFBDT {get;set;} // ? Baseline Date for Due Date Calculation
        }

        public class IF_DEALER_001_Res_T_LIST { 
          public IF_DEALER_001_Res_T_LIST(){}
          @AuraEnabled public String ZUONR    {get;set;} // ? Assignment Number
          @AuraEnabled public String VBELV    {get;set;} // ? Sales Document
          @AuraEnabled public String POSNR    {get;set;} // ? Sales Document Item
          @AuraEnabled public String VBELN_VF {get;set;} // ? Billing Document
          @AuraEnabled public String POSNR_VF {get;set;} // ? Billing item
          @AuraEnabled public String XREF1    {get;set;} // ? Business partner reference key
          @AuraEnabled public String ZTERM    {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String HLEVEL   {get;set;} // ? Hierarchy Level
          @AuraEnabled public String LINE_TYPE {get;set;} // ? Not More Closely Defined Area, Possibly Used for Patchlevels
          @AuraEnabled public String MATNR    {get;set;} // ? Material Number
          @AuraEnabled public String FAEDT    {get;set;} // ? Net Due Date
          @AuraEnabled public String WAERS    {get;set;} // ? Currency Key
          @AuraEnabled public String NETWR    {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String WRBTR    {get;set;} // ? Amount in document currency
          @AuraEnabled public String DMBTR    {get;set;} // ? Amount in Local Currency
          @AuraEnabled public String CL_WRBTR {get;set;} // ? Amount in document currency
          @AuraEnabled public String CL_DMBTR {get;set;} // ? Amount in Local Currency
          @AuraEnabled public String GJAHR    {get;set;} // ? Fiscal Year
          @AuraEnabled public String BELNR    {get;set;} // ? Accounting Document Number
          @AuraEnabled public String BUZEI    {get;set;} // ? Number of Line Item Within Accounting Document
          @AuraEnabled public String AUGBL    {get;set;} // ? Document Number of the Clearing Document
          @AuraEnabled public String AUGGJ    {get;set;} // ? Fiscal Year of Clearing Document
          @AuraEnabled public String AUGZZ    {get;set;} // ? Line Item in the Relevant Invoice
          @AuraEnabled public String OVDUE    {get;set;} // ? OVERDUE DAY
          @AuraEnabled public String INDAT    {get;set;} // ? Pay-In Date
          @AuraEnabled public String CAL_DAY  {get;set;} // ? interest caculation Due date
          @AuraEnabled public String INT_AMT  {get;set;} // ? Interest amount
          @AuraEnabled public String BILLAMT  {get;set;} // ? Overdue Bill amount
          @AuraEnabled public String REC_INT  {get;set;} // ? Recived interest
          @AuraEnabled public String REDAMT   {get;set;} // ? Reduction amount
          @AuraEnabled public String KUNNR    {get;set;} // ? Customer Number 1
          @AuraEnabled public String ZFBDT    {get;set;} // ? Baseline Date for Due Date Calculation
          @AuraEnabled public String BLDAT    {get;set;} // ? Document Date in Document
          @AuraEnabled public String SGTXT    {get;set;} // ? Item Text
          @AuraEnabled public String MWSKZ    {get;set;} // ? Sales Tax Code
          @AuraEnabled public String HKONT    {get;set;} // ? General Ledger Account
          @AuraEnabled public String KURSF    {get;set;} // ? Exchange rate
          @AuraEnabled public String AUGDT    {get;set;} // ? Clearing Date
          @AuraEnabled public String BLART    {get;set;} // ? Document Type
          @AuraEnabled public String BUDAT    {get;set;} // ? Posting Date in the Document
          @AuraEnabled public String BSCHL    {get;set;} // ? Posting Key
          @AuraEnabled public String SHKZG    {get;set;} // ? Debit/Credit Indicator
          @AuraEnabled public String METHOD   {get;set;} // ? Pay Method
          @AuraEnabled public String MTART    {get;set;} // ? Material Type
          @AuraEnabled public String SERNR    {get;set;} // ? Serial number
          @AuraEnabled public String PAPH1    {get;set;} // ? Prod.hierarchy01-1
          @AuraEnabled public String VTEXT1   {get;set;} // ? Description
          @AuraEnabled public String PAPH2    {get;set;} // ? Prod.hierarchy01-2
          @AuraEnabled public String VTEXT2   {get;set;} // ? Description
          @AuraEnabled public String B2_GJAHR {get;set;} // ? Fiscal Year
          @AuraEnabled public String B2_BELNR {get;set;} // ? Accounting Document Number
        }

        public class IF_DEALER_001_Res_T_DOWN { 
          public IF_DEALER_001_Res_T_DOWN(){}
          @AuraEnabled public String ZUONR    {get;set;} // ? Assignment Number
          @AuraEnabled public String VBELV    {get;set;} // ? Sales Document
          @AuraEnabled public String POSNR    {get;set;} // ? Sales Document Item
          @AuraEnabled public String VBELN_VF {get;set;} // ? Billing Document
          @AuraEnabled public String POSNR_VF {get;set;} // ? Billing item
          @AuraEnabled public String XREF1    {get;set;} // ? Business partner reference key
          @AuraEnabled public String ZTERM    {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String HLEVEL   {get;set;} // ? Hierarchy Level
          @AuraEnabled public String LINE_TYPE {get;set;} // ? Not More Closely Defined Area, Possibly Used for Patchlevels
          @AuraEnabled public String MATNR    {get;set;} // ? Material Number
          @AuraEnabled public String FAEDT    {get;set;} // ? Net Due Date
          @AuraEnabled public String WAERS    {get;set;} // ? Currency Key
          @AuraEnabled public String NETWR    {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String WRBTR    {get;set;} // ? Amount in document currency
          @AuraEnabled public String DMBTR    {get;set;} // ? Amount in Local Currency
          @AuraEnabled public String CL_WRBTR {get;set;} // ? Amount in document currency
          @AuraEnabled public String CL_DMBTR {get;set;} // ? Amount in Local Currency
          @AuraEnabled public String GJAHR    {get;set;} // ? Fiscal Year
          @AuraEnabled public String BELNR    {get;set;} // ? Accounting Document Number
          @AuraEnabled public String BUZEI    {get;set;} // ? Number of Line Item Within Accounting Document
          @AuraEnabled public String AUGBL    {get;set;} // ? Document Number of the Clearing Document
          @AuraEnabled public String AUGGJ    {get;set;} // ? Fiscal Year of Clearing Document
          @AuraEnabled public String AUGZZ    {get;set;} // ? Line Item in the Relevant Invoice
          @AuraEnabled public String OVDUE    {get;set;} // ? OVERDUE DAY
          @AuraEnabled public String INDAT    {get;set;} // ? Pay-In Date
          @AuraEnabled public String CAL_DAY  {get;set;} // ? interest caculation Due date
          @AuraEnabled public String INT_AMT  {get;set;} // ? Interest amount
          @AuraEnabled public String BILLAMT  {get;set;} // ? Overdue Bill amount
          @AuraEnabled public String REC_INT  {get;set;} // ? Recived interest
          @AuraEnabled public String REDAMT   {get;set;} // ? Reduction amount
          @AuraEnabled public String KUNNR    {get;set;} // ? Customer Number 1
          @AuraEnabled public String ZFBDT    {get;set;} // ? Baseline Date for Due Date Calculation
          @AuraEnabled public String BLDAT    {get;set;} // ? Document Date in Document
          @AuraEnabled public String SGTXT    {get;set;} // ? Item Text
          @AuraEnabled public String MWSKZ    {get;set;} // ? Sales Tax Code
          @AuraEnabled public String HKONT    {get;set;} // ? General Ledger Account
          @AuraEnabled public String KURSF    {get;set;} // ? Exchange rate
          @AuraEnabled public String AUGDT    {get;set;} // ? Clearing Date
          @AuraEnabled public String BLART    {get;set;} // ? Document Type
          @AuraEnabled public String BUDAT    {get;set;} // ? Posting Date in the Document
          @AuraEnabled public String BSCHL    {get;set;} // ? Posting Key
          @AuraEnabled public String SHKZG    {get;set;} // ? Debit/Credit Indicator
          @AuraEnabled public String METHOD   {get;set;} // ? Pay Method
          @AuraEnabled public String MTART    {get;set;} // ? Material Type
          @AuraEnabled public String SERNR    {get;set;} // ? Serial number
          @AuraEnabled public String PAPH1    {get;set;} // ? Prod.hierarchy01-1
          @AuraEnabled public String VTEXT1   {get;set;} // ? Description
          @AuraEnabled public String PAPH2    {get;set;} // ? Prod.hierarchy01-2
          @AuraEnabled public String VTEXT2   {get;set;} // ? Description
          @AuraEnabled public String B2_GJAHR {get;set;} // ? Fiscal Year
          @AuraEnabled public String B2_BELNR {get;set;} // ? Accounting Document Number
        }

        public class IF_DEALER_001_Res_T_ARSTATUS { 
          public IF_DEALER_001_Res_T_ARSTATUS(){}
          @AuraEnabled public String LINE_NO {get;set;} // ? Sequence Number
          @AuraEnabled public String TEXT1 {get;set;} // ? Text (20 Characters)
          @AuraEnabled public String WRBTR {get;set;} // ? Amount in document currency
          @AuraEnabled public String DMBTR {get;set;} // ? Amount in Local Currency
          @AuraEnabled public String ZFBDT {get;set;} // ? Baseline Date for Due Date Calculation
          @AuraEnabled public String ZBD1T {get;set;} // ? Cash discount days 1
          @AuraEnabled public String FAEDT {get;set;} // ? Net Due Date
          @AuraEnabled public String CLEAR {get;set;} // ? Clearing Amount
          @AuraEnabled public String AUGDT {get;set;} // ? Clearing Date
          @AuraEnabled public String BUDAT {get;set;} // ? Posting Date in the Document
          @AuraEnabled public String RECIVE_DAT {get;set;} // ? Receive date
          @AuraEnabled public String OVDUE {get;set;} // ? OVERDUE DAY
          @AuraEnabled public String INT_AMT {get;set;} // ? Interest amount
          @AuraEnabled public String REC_INT {get;set;} // ? Recived interest
          @AuraEnabled public String REM_INT {get;set;} // ? Remaining Interest
          @AuraEnabled public String BILLAMT {get;set;} // ? Overdue Bill amount
          @AuraEnabled public String BELNR {get;set;} // ? Accounting Document Number
          @AuraEnabled public String BUZEI {get;set;} // ? Number of Line Item Within Accounting Document
          @AuraEnabled public String GJAHR {get;set;} // ? Fiscal Year
          @AuraEnabled public String AUGBL {get;set;} // ? Document Number of the Clearing Document
          @AuraEnabled public String BOENO {get;set;} // ? BOE Number
          @AuraEnabled public String BOE_DOC {get;set;} // ? Accounting Document Number
          @AuraEnabled public String BOE_ITM {get;set;} // ? Number of Line Item Within Accounting Document
          @AuraEnabled public String ZTERM {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String BUKRS {get;set;} // ? Company Code
          @AuraEnabled public String WAERS {get;set;} // ? Currency Key
          @AuraEnabled public String BSCHL {get;set;} // ? Posting Key
          @AuraEnabled public String AUJAH {get;set;} // ? Clearing document fiscal year
        }


    /**
     * 
     * SFDC interface Id    : IF-DEALER-002
     * AS-IS RFC            : ZCRM_SD_GET_SAFEKEY_USING_IR        
     * New I/F              : ZSD_GET_SAFEKEY_USING_IR				
     * Description          : ERP I/F 통해 개인 및 법인의 신용정보 조회
     *                         - 담보여신, 평가여신, 일시여신, 총여신, 미수금, 잔여여신, 여신율
     */
    // public class IF_DEALER_002_Req { 
    //     @AuraEnabled public String I_BIRTH {get;set;} // ? Character Field Length = 10  => NOT NULL
    //     @AuraEnabled public String I_NAME  {get;set;} // ? Character field of length 40 => NOT NULL
    //     @AuraEnabled public String I_TELNO {get;set;} // ? Character Length 11          => NOT NULL
    //     @AuraEnabled public String I_SEX   {get;set;} // ? Single-Character Indicator   => NOT NULL
    //     public IF_DEALER_002_Req(String I_BIRTH,String I_NAME,String I_TELNO,String I_SEX){
    //         this.I_BIRTH    = I_BIRTH;
    //         this.I_NAME     = I_NAME;
    //         this.I_TELNO    = I_TELNO;
    //         this.I_SEX      = I_SEX;
    //     }

    //     public IF_DEALER_002_Req(){}

    //   }
    //   public class IF_DEALER_002_Res { 
    //     @AuraEnabled public String E_RESULT {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
    //     @AuraEnabled public String O_SAFEKEY {get;set;} // ? Character field 13 digits
    //     @AuraEnabled public String O_RETURN {get;set;} // ? Not More Closely Defined Area, Possibly Used for Patchlevels
        
    //     public IF_DEALER_002_Res(){}
    // }


  
    /**
     * 
     * SFDC interface Id    : IF-DEALER-004
     * AS-IS RFC            : Z_SD_SEARCH_MORTGAGE_LIST        
     * New I/F              : ZCRM_SD_SEARCH_MORTGAGE_LIST		
     * Description          : I/F 통해 딜러별 딜러명, 대표자, 제공자, 소유자, 담보구분, 담보크기, 담보상세, 담보평가문서, 설정계약서 등 데이터를 ERP에서 받아온다.
     */
    public class IF_DEALER_004_Req { 
        @AuraEnabled public String I_DROP {get;set;} // ? Proess = 'P' or Overdue = 'O'

        @AuraEnabled public IF_DEALER_004_Req_I_LOG       I_LOG {get;set;} 
        @AuraEnabled public IF_DEALER_004_Req_I_CONDITION I_CONDITION {get;set;} 
    
        public IF_DEALER_004_Req(){}
    }

        public class IF_DEALER_004_Req_I_LOG { 
            public IF_DEALER_004_Req_I_LOG(){}
            @AuraEnabled  public String KUNNR {get;set;} // ? Customer Number 1
            @AuraEnabled  public String NAME1 {get;set;} // ? Name 1
        }

        public class IF_DEALER_004_Req_I_CONDITION { 
            public IF_DEALER_004_Req_I_CONDITION(){}
            @AuraEnabled public String BUKRS   {get;set;} // ? Company Code
            @AuraEnabled public String VKORG   {get;set;} // ? Sales Organization
            @AuraEnabled public String SPART   {get;set;} // ? Division
            @AuraEnabled public String BUTXT   {get;set;} // ? Name of Company Code or Company
            @AuraEnabled public String VKORG_T {get;set;} // ? Object Name
            @AuraEnabled public String SPART_T {get;set;} // ? Object Name
        }

  
    public class IF_DEALER_004_Res {
    public IF_DEALER_004_Res(){} 
    @AuraEnabled public IF_DEALER_004_Res_O_RETURN        O_RETURN {get;set;} 
    @AuraEnabled public List<IF_DEALER_004_Res_T_RETURN>  T_RETURN  {get;set;} 
    }
    public class IF_DEALER_004_Res_O_RETURN { 
        public IF_DEALER_004_Res_O_RETURN(){}
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
    }
    public class IF_DEALER_004_Res_T_RETURN  { 
        public IF_DEALER_004_Res_T_RETURN(){}

        @AuraEnabled public String KUNNR     {get;set;} // ? Customer Number 1
        @AuraEnabled public String MNGNO     {get;set;} // ? Internal Manage Number
        @AuraEnabled public String PROVIDER  {get;set;} // ? Mort. Provider
        @AuraEnabled public String J_1KFREPRE {get;set;} // ? Name of Representative
        @AuraEnabled public String OWNER     {get;set;} // ? Owner

        @AuraEnabled public String EST_DOC_DAT {get;set;} // ? Mort. Estimated Amount Doc Date
        @AuraEnabled public String REG_DATE  {get;set;} // ? Mort. Registered Date
        @AuraEnabled public String ENG_DATE  {get;set;} // ? Engaged Date
        @AuraEnabled public String AGR_DATE  {get;set;} // ? Agreed Date
        @AuraEnabled public String LEA_DATE  {get;set;} // ? Mort. Confirm Leased Date

        @AuraEnabled public String STMP_DATE {get;set;} // ? Confirm Stamp Date
        @AuraEnabled public String PLED_DATE {get;set;} // ? Pledged Date
        @AuraEnabled public String PAGR_DATE {get;set;} // ? Pledge Agreed Date
        @AuraEnabled public String MORT_CODE {get;set;} // ? Mortage Code
        @AuraEnabled public String MORTTYPE  {get;set;} // ? Mort. Type

        @AuraEnabled public String MORTSIZE  {get;set;} // ? Mort. Size
        @AuraEnabled public String ADD_DATA  {get;set;} // ? Mort. additional Data
        @AuraEnabled public String FI_ORG    {get;set;} // ? Financial Office
        @AuraEnabled public String FI_NUM    {get;set;} // ? Financial Number
        @AuraEnabled public String DUE_DATE  {get;set;} // ? Mort. Due Date

        @AuraEnabled public String SP_REASON {get;set;} // ? Mort. Special Reason
        @AuraEnabled public String EST_AMT   {get;set;} // ? Mort. Estimated Amount
        @AuraEnabled public String PRI_AMT   {get;set;} // ? Priorier Amount
        @AuraEnabled public String VAL_AMT   {get;set;} // ? Validated Amount
        @AuraEnabled public String ESTA_AMT  {get;set;} // ? Established Amount

        @AuraEnabled public String WAERS     {get;set;} // ? Currency Key
        @AuraEnabled public String ESTA_RANK {get;set;} // ? Established Rank
        @AuraEnabled public String PRI_INFO  {get;set;} // ? Priorier Inform.
        @AuraEnabled public String AMOUNT    {get;set;} // ? Amount
        @AuraEnabled public String CANC_DATE {get;set;} // ? Mort. Canceled Date

        @AuraEnabled public String ALT_INFO  {get;set;} // ? Alternated Mort. Inform
        @AuraEnabled public String NAME1     {get;set;} // ? Name 1
        @AuraEnabled public String MORT_TEXT {get;set;} // ? Code Text
        @AuraEnabled public String TYPE_TEXT {get;set;} // ? TEXT OBJECT TEXT
        @AuraEnabled public String ALT_MNGNO {get;set;} // ? Alternated Manage Number
    }


    

/**
     * 
     * SFDC interface Id    : IF-DEALER-005
     * AS-IS RFC            : Z_FI_CLEARED_AR	        
     * New I/F              : ZCRM_FI_CLEARED_AR	
     * Description          : ERP I/F 통해 기간별 수금실적 정보 조회
*/

 /** REQUEST 
    */
    public class IF_DEALER_005_Req { 
        @AuraEnabled public String I_BUKRS {get;set;} // ? Company Code
        @AuraEnabled public String I_KUNNR {get;set;} // ? 딜러 코드 
        @AuraEnabled public String I_VKORG {get;set;} // ? Sales Organization
        @AuraEnabled public String I_VTWEG {get;set;} // ? Distribution Channel
        @AuraEnabled public String I_SPART {get;set;} // ? Division
        @AuraEnabled public String I_LOCAL {get;set;} // ?  Local
        @AuraEnabled public String I_ETC  {get;set;} // ?  ETC
        @AuraEnabled public String I_OTHER {get;set;} // ?  Other AR
        @AuraEnabled public String I_EXPO {get;set;} // ?  Export
  

        @AuraEnabled public IF_DEALER_005_Req_IR_GSBER      IR_GSBER  {get;set;} 
        @AuraEnabled public IF_DEALER_005_Req_IR_DATE       IR_DATE   {get;set;} 
        @AuraEnabled public IF_DEALER_005_Req_IR_ZUONR      IR_ZUONR  {get;set;} 
        @AuraEnabled public IF_DEALER_005_Req_IR_VKBUR      IR_VKBUR  {get;set;} 
        @AuraEnabled public List<IF_DEALER_005_Req_T_KUNNR> T_KUNNR {get;set;}
  
          public IF_DEALER_005_Req(){
            this.IR_GSBER = new IF_ERP_Dealer_Classes.IF_DEALER_005_Req_IR_GSBER();
            this.IR_DATE = new IF_ERP_Dealer_Classes.IF_DEALER_005_Req_IR_DATE();
            this.IR_ZUONR = new IF_ERP_Dealer_Classes.IF_DEALER_005_Req_IR_ZUONR();
            this.IR_VKBUR = new IF_ERP_Dealer_Classes.IF_DEALER_005_Req_IR_VKBUR();
            this.T_KUNNR  = new List<IF_ERP_Dealer_Classes.IF_DEALER_005_Req_T_KUNNR>();
          }
      }
  
    public class IF_DEALER_005_Req_IR_GSBER { 
        public IF_DEALER_005_Req_IR_GSBER(){}
          public IF_DEALER_005_Req_IR_GSBER(
           String SIGN  , 
           String OPTION, 
           String LOW   , 
           String HIGH   ){
             this.SIGN   = SIGN   ;
             this.OPTION = OPTION ;
             this.LOW    = LOW    ;
             this.HIGH   = HIGH   ;
          }
        @AuraEnabled public String SIGN {get;set;} // ? Type of SIGN component in row type of a Ranges type
        @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
        @AuraEnabled public String LOW  {get;set;} // ? Customer Number 1
        @AuraEnabled public String HIGH {get;set;} // ? Customer Number 1
    }
  
    public class IF_DEALER_005_Req_IR_DATE { 
        public IF_DEALER_005_Req_IR_DATE(){}
          public IF_DEALER_005_Req_IR_DATE(
           String SIGN  , 
           String OPTION, 
           String LOW   , 
           String HIGH   ){
             this.SIGN   = SIGN   ;
             this.OPTION = OPTION ;
             this.LOW    = LOW    ;
             this.HIGH   = HIGH   ;
          }
        @AuraEnabled public String SIGN {get;set;} // ? Type of SIGN component in row type of a Ranges type
        @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
        @AuraEnabled public String LOW  {get;set;} // ? Customer Number 1
        @AuraEnabled public String HIGH {get;set;} // ? Customer Number 1
    }
  
    public class IF_DEALER_005_Req_IR_ZUONR { 
        public IF_DEALER_005_Req_IR_ZUONR(){}
          public IF_DEALER_005_Req_IR_ZUONR(
           String SIGN  , 
           String OPTION, 
           String LOW   , 
           String HIGH   ){
             this.SIGN   = SIGN   ;
             this.OPTION = OPTION ;
             this.LOW    = LOW    ;
             this.HIGH   = HIGH   ;
          }
        @AuraEnabled public String SIGN {get;set;} // ? Type of SIGN component in row type of a Ranges type
        @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
        @AuraEnabled public String LOW  {get;set;} // ? Customer Number 1
        @AuraEnabled public String HIGH {get;set;} // ? Customer Number 1
    }
  
    public class IF_DEALER_005_Req_IR_VKBUR { 
        public IF_DEALER_005_Req_IR_VKBUR(){}
          public IF_DEALER_005_Req_IR_VKBUR(
           String SIGN  , 
           String OPTION, 
           String LOW   , 
           String HIGH   ){
             this.SIGN   = SIGN   ;
             this.OPTION = OPTION ;
             this.LOW    = LOW    ;
             this.HIGH   = HIGH   ;
          }
        @AuraEnabled public String SIGN {get;set;} // ? Type of SIGN component in row type of a Ranges type
        @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
        @AuraEnabled public String LOW  {get;set;} // ? Customer Number 1
        @AuraEnabled public String HIGH {get;set;} // ? Customer Number 1
    }

    public class IF_DEALER_005_Req_T_KUNNR{
      @AuraEnabled public String SIGN   {get;set;}
      @AuraEnabled public String OPTION {get;set;}
      @AuraEnabled public String LOW    {get;set;}
      @AuraEnabled public String HIGH   {get;set;}      
    }
  
    
 /** RESPONSE 
   */    
    public class IF_DEALER_005_Res { 
        public IF_DEALER_005_Res(){}
        @AuraEnabled public IF_DEALER_005_Res_O_RETURN    O_RETURN {get;set;}
        @AuraEnabled public List<IF_DEALER_005_Res_T_OUT> T_OUT    {get;set;} 
        @AuraEnabled public List<IF_DEALER_005_Res_T_LOG> T_LOG    {get;set;} 
        @AuraEnabled public List<IF_DEALER_005_Res_T_MSG> T_MSG    {get;set;} 
  
      }
  
    public class IF_DEALER_005_Res_O_RETURN{
      public IF_DEALER_005_Res_O_RETURN(){}
      @AuraEnabled public String TYPE {get;set;}
      @AuraEnabled public String CODE {get;set;}
      @AuraEnabled public String MESSAGE {get;set;}     
    }
    public class IF_DEALER_005_Res_T_OUT {
        public IF_DEALER_005_Res_T_OUT(){} 
        @AuraEnabled public String BUKRS {get;set;} // ? Company Code
        @AuraEnabled public String GSBER {get;set;} // ? Business Area
        @AuraEnabled public String GUBUN {get;set;} // ? Division
        @AuraEnabled public String HKONT {get;set;} // ? General Ledger Account
        @AuraEnabled public String TXT20 {get;set;} // ? G/L account short text
        @AuraEnabled public String KUNNR {get;set;} // ? Sold-to party
        @AuraEnabled public String NAME1 {get;set;} // ? Name
        @AuraEnabled public String REPRE {get;set;} // ? Name of Representative
        @AuraEnabled public String ZUONR {get;set;} // ? Assignment Number
        @AuraEnabled public String VKBUR {get;set;} // ? Sales Office
        @AuraEnabled public String SALEDT {get;set;} // ? Document Date in Document
        @AuraEnabled public String BLDAT {get;set;} // ? Document Date in Document
        @AuraEnabled public String BUDAT {get;set;} // ? Posting Date in the Document
        @AuraEnabled public String BLART {get;set;} // ? Document Type
        @AuraEnabled public String ZTERM {get;set;} // ? Terms of Payment Key
        @AuraEnabled public String TEXT1 {get;set;} // ? Own Explanation of Term of Payment
        @AuraEnabled public String BSCHL {get;set;} // ? Posting Key
        @AuraEnabled public String UMSKZ {get;set;} // ? Special G/L Indicator
        @AuraEnabled public String WAERS {get;set;} // ? Currency Key
        @AuraEnabled public String TOTAL {get;set;} // ? Amount in Local Currency
        @AuraEnabled public String WRBTR {get;set;} // ? Amount in document currency
        @AuraEnabled public String DMBTR {get;set;} // ? Amount in Local Currency
        @AuraEnabled public String ARREAR {get;set;} // ? Amount in Local Currency
        @AuraEnabled public String ADVDOC {get;set;} // ? Accounting Document Number
        @AuraEnabled public String BELNR {get;set;} // ? Accounting Document Number
        @AuraEnabled public String GJAHR {get;set;} // ? Fiscal Year
        @AuraEnabled public String BUZEI {get;set;} // ? Number of Line Item Within Accounting Document
        @AuraEnabled public String SHKZG {get;set;} // ? Debit/Credit Indicator
        @AuraEnabled public String ZFBDT {get;set;} // ? Baseline Date for Due Date Calculation
        @AuraEnabled public String FAEDT {get;set;} // ? Net Due Date
        @AuraEnabled public String AUGDT {get;set;} // ? Clearing Date
        @AuraEnabled public String AUGBL {get;set;} // ? Document Number of the Clearing Document
        @AuraEnabled public String AUGGJ {get;set;} // ? Fiscal Year of Clearing Document
        @AuraEnabled public String ADVJHR {get;set;} // ? Fiscal Year
        @AuraEnabled public String REBZG {get;set;} // ? Number of the Invoice the Transaction Belongs to
        @AuraEnabled public String REBZJ {get;set;} // ? Fiscal Year of the Relevant Invoice (for Credit Memo)
        @AuraEnabled public String REBZZ {get;set;} // ? Line Item in the Relevant Invoice
        @AuraEnabled public String KWAERS {get;set;} // ? Currency Key
        @AuraEnabled public String USNAM {get;set;} // ? User Name
        @AuraEnabled public String NAME_LAST {get;set;} // ? Last name
        @AuraEnabled public String STBLG {get;set;} // ? Reverse Document Number
        @AuraEnabled public String XREVERSAL {get;set;} // ? Specifies whether doc. is reversal doc. or reversed doc.
        @AuraEnabled public String STJAH {get;set;} // ? Reverse document fiscal year
        @AuraEnabled public String SHIP_TO_PARTY_NUM {get;set;} // ? Customer number of business partner
        @AuraEnabled public String SHIP_NAME {get;set;} // ? Name
    }
  
    public class IF_DEALER_005_Res_T_LOG { 
        public IF_DEALER_005_Res_T_LOG(){}
        @AuraEnabled public String MSGTY {get;set;} // ? Message Type
        @AuraEnabled public String MSGID {get;set;} // ? Message Class
        @AuraEnabled public String MSGNO {get;set;} // ? Message Number
        @AuraEnabled public String MSGV1 {get;set;} // ? Message Variable
        @AuraEnabled public String MSGV2 {get;set;} // ? Message Variable
        @AuraEnabled public String MSGV3 {get;set;} // ? Message Variable
        @AuraEnabled public String MSGV4 {get;set;} // ? Message Variable
    }
    public class IF_DEALER_005_Res_T_MSG { 
        public IF_DEALER_005_Res_T_MSG(){}
        @AuraEnabled public String TYPE   {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        @AuraEnabled public String IF_NUMBER {get;set;} // ? Message Number
    }
  
// ** IF-DEALER-006
/**
  *  IF-DEALER-006
  */
  /**
     * Wrapper Name         : IF_DEALER_006
     * SFDC interface Id    : IF-DEALER-006
     * AS-IS RFC            : Z_FB_HISTORY_OF_PAYMENT	        
     * New I/F              : ZCRM_FB_HISTORY_OF_PAYMENT
     * Description          : ERP I/F 통해 고객 및 은행별로 입금현황 조회
  */    

  // ** REQUEST
  /** 
   * REQUEST
   * 
    */  
    public class IF_DEALER_006_Req { 
      public String I_BUKRS {get;set;} // ? Company Code

      @AuraEnabled public IF_DEALER_006_Req_IR_KUNNR IR_KUNNR {get;set;} 
      @AuraEnabled public IF_DEALER_006_Req_IR_CMS   IR_CMS {get;set;} 
      @AuraEnabled public IF_DEALER_006_Req_IR_HBKID IR_HBKID {get;set;} 
      @AuraEnabled public IF_DEALER_006_Req_IR_HKTID IR_HKTID {get;set;} 
      @AuraEnabled public IF_DEALER_006_Req_IR_BANKN IR_BANKN {get;set;} 
      @AuraEnabled public IF_DEALER_006_Req_IR_DATE  IR_DATE {get;set;} 

    }

    public class IF_DEALER_006_Req_IR_KUNNR { 
        public IF_DEALER_006_Req_IR_KUNNR(
        String SIGN  , 
        String OPTION, 
        String LOW   , 
        String HIGH   ){
          this.SIGN   = SIGN   ;
          this.OPTION = OPTION ;
          this.LOW    = LOW    ;
          this.HIGH   = HIGH   ;
        }
        @AuraEnabled public String SIGN   {get;set;} // ? Type of SIGN component in row type of a Ranges type
        @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
        @AuraEnabled public String LOW    {get;set;} // ? Customer Number 1
        @AuraEnabled public String HIGH   {get;set;} // ? Customer Number 1
        public IF_DEALER_006_Req_IR_KUNNR(){}
    }

    public class IF_DEALER_006_Req_IR_CMS { 
      public IF_DEALER_006_Req_IR_CMS(){}
      public IF_DEALER_006_Req_IR_CMS(
          String SIGN  , 
          String OPTION, 
          String LOW   , 
          String HIGH         ){
            this.SIGN   = SIGN   ;
            this.OPTION = OPTION ;
            this.LOW    = LOW    ;
            this.HIGH   = HIGH   ;
        }
        @AuraEnabled public String SIGN   {get;set;} // ? Type of SIGN component in row type of a Ranges type
        @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
        @AuraEnabled public String LOW    {get;set;} // ? Customer Number 1
        @AuraEnabled public String HIGH   {get;set;} // ? Customer Number 1
    }

    public class IF_DEALER_006_Req_IR_HBKID {
      public IF_DEALER_006_Req_IR_HBKID(){} 
        public IF_DEALER_006_Req_IR_HBKID(
          String SIGN  , 
          String OPTION, 
          String LOW   , 
          String HIGH         ){
            this.SIGN   = SIGN   ;
            this.OPTION = OPTION ;
            this.LOW    = LOW    ;
            this.HIGH   = HIGH   ;
        }
        @AuraEnabled public String SIGN   {get;set;} // ? Type of SIGN component in row type of a Ranges type
        @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
        @AuraEnabled public String LOW    {get;set;} // ? Customer Number 1
        @AuraEnabled public String HIGH   {get;set;} // ? Customer Number 1
    }

    // ** ALL FIELDS  NOT NULL
    public class IF_DEALER_006_Req_IR_HKTID { 
      public IF_DEALER_006_Req_IR_HKTID(){}
        public IF_DEALER_006_Req_IR_HKTID(
          String SIGN  , 
          String OPTION, 
          String LOW   , 
          String HIGH         ){
            this.SIGN   = SIGN   ;
            this.OPTION = OPTION ;
            this.LOW    = LOW    ;
            this.HIGH   = HIGH   ;
        }
        @AuraEnabled public String SIGN   {get;set;} // ? Type of SIGN component in row type of a Ranges type    => NOT NULL
        @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type  => NOT NULL
        @AuraEnabled public String LOW    {get;set;} // ? Customer Number 1 => NOT NULL
        @AuraEnabled public String HIGH   {get;set;} // ? Customer Number 1 => NOT NULL
    }

    public class IF_DEALER_006_Req_IR_BANKN { 
      public IF_DEALER_006_Req_IR_BANKN(){}
        public IF_DEALER_006_Req_IR_BANKN(
        String SIGN  , 
        String OPTION, 
        String LOW   , 
        String HIGH  ){
          this.SIGN   = SIGN   ;
          this.OPTION = OPTION ;
          this.LOW    = LOW    ;
          this.HIGH   = HIGH   ;
        }
        @AuraEnabled public String SIGN   {get;set;} // ? Type of SIGN component in row type of a Ranges type
        @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
        @AuraEnabled public String LOW    {get;set;} // ? Customer Number 1
        @AuraEnabled public String HIGH   {get;set;} // ? Customer Number 1
    }

    public class IF_DEALER_006_Req_IR_DATE { 
      public IF_DEALER_006_Req_IR_DATE(){}
        public IF_DEALER_006_Req_IR_DATE(
        String SIGN  , 
        String OPTION, 
        String LOW   , 
        String HIGH         ){
          this.SIGN   = SIGN   ;
          this.OPTION = OPTION ;
          this.LOW    = LOW    ;
          this.HIGH   = HIGH   ;
        }
        @AuraEnabled public String SIGN   {get;set;} // ? Type of SIGN component in row type of a Ranges type
        @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
        @AuraEnabled public String LOW    {get;set;} // ? Customer Number 1
        @AuraEnabled public String HIGH   {get;set;} // ? Customer Number 1
    }

  
  // ** RESPONSE
  /**
  // ** RESPONSE
   * 
    */
    public class IF_DEALER_006_Res { 
      @AuraEnabled public List<IF_DEALER_006_Res_T_OUT>    T_OUT {get;set;} 
      @AuraEnabled public List<IF_DEALER_006_Res_T_LOG>    T_LOG {get;set;} 
      @AuraEnabled public List<IF_DEALER_006_Res_TRA_DATE> TRA_DATE {get;set;}
      public IF_DEALER_006_Res(){} 

    }

    public class IF_DEALER_006_Res_T_OUT { 
      @AuraEnabled public String TRDATE     {get;set;} // ? [FB] Orgin trade date for cancle
      @AuraEnabled public String WAERS      {get;set;} // ? Currency Key
      @AuraEnabled public String INOUT_TY   {get;set;} // ? [FB] 거래구분코드
      @AuraEnabled public String BANKACCT   {get;set;} // ? [FB] 계좌번호
      @AuraEnabled public String SERIALNO   {get;set;} // ? Sequence Number
      @AuraEnabled public String TEXT2      {get;set;} // ? Comment
      @AuraEnabled public String FB_NUMB    {get;set;} // ? [FB] Firm Banking 거래번호
      @AuraEnabled public String IN_AMT     {get;set;} // ? Amount in document currency
      @AuraEnabled public String ZSPACE     {get;set;} // ? Comment
      @AuraEnabled public String IN_NAME1   {get;set;} // ? [FB] 입금인성명(New)
      @AuraEnabled public String KUNNR      {get;set;} // ? Customer Number 1
      @AuraEnabled public String NAME1      {get;set;} // ? Name
      @AuraEnabled public String CMS_NUMB   {get;set;} // ? [FB] 가상계좌번호 
      @AuraEnabled public String PR_BELNR   {get;set;} // ? 가수금 전표번호
      @AuraEnabled public String CL_BELNR   {get;set;} // ? [FB] 정리전표번호
      @AuraEnabled public String PR_CLR_AMT {get;set;} // ? Clearing Amount
      @AuraEnabled public String PR_REM_AMT {get;set;} // ? Remaining Interest
      public IF_DEALER_006_Res_T_OUT(){} 

    }

    public class IF_DEALER_006_Res_T_LOG { 
      @AuraEnabled public String MSGTY {get;set;} // ? Message Type
      @AuraEnabled public String MSGID {get;set;} // ? Message Class
      @AuraEnabled public String MSGNO {get;set;} // ? Message Number
      @AuraEnabled public String MSGV1 {get;set;} // ? Message Variable
      @AuraEnabled public String MSGV2 {get;set;} // ? Message Variable
      @AuraEnabled public String MSGV3 {get;set;} // ? Message Variable
      @AuraEnabled public String MSGV4 {get;set;} // ? Message Variable
      public IF_DEALER_006_Res_T_LOG(){} 

    }

    public class IF_DEALER_006_Res_TRA_DATE { 
      @AuraEnabled public String SIGN {get;set;} // ? Type of SIGN component in row type of a Ranges type
      @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
      @AuraEnabled public String LOW  {get;set;} // ? Customer Number 1
      @AuraEnabled public String HIGH {get;set;} // ? Customer Number 1
      public IF_DEALER_006_Res_TRA_DATE(){}
    }

/** IF_DEALER_003
    */  
    /**
         * ClassName            : IF_ERP_Dealer 
         * Wrapper Name         : IF_DEALER_003
         * SFDC interface Id    : IF-DEALER-003
         * AS-IS RFC            : Z_SD_SEARCH_CREDIT_INFO
         * New I/F              : ZCRM_SD_SEARCH_CREDIT_INFO
         * Description          : ERP I/F 통해 계정별 여신 정보 조회
     */

    /** REQUEST 
      */
      public class IF_DEALER_003_Req { 
        @AuraEnabled public String I_BUKRS {get;set;} // ? Company Code
        @AuraEnabled public String I_VKORG {get;set;} // ? Sales Organization
        @AuraEnabled public String I_SPART {get;set;} // ? Division
        @AuraEnabled public String I_KUNNR {get;set;} // ? Dealer
        @AuraEnabled public String I_VTWEG {get;set;} // ? Distribution Channel
        public IF_DEALER_003_Req(){}
      }

    /** RESPONSE 
      */      
          public class IF_DEALER_003_Res { 
            public IF_DEALER_003_Res(){}
            @AuraEnabled public String O_WAERK   {get;set;} // ? SD Document Currency
            @AuraEnabled public String O_DLTOTAL {get;set;} // ? Amount in Local Currency
      
            @AuraEnabled public IF_DEALER_003_Res_O_HEADER         O_HEADER {get;set;} 
            @AuraEnabled public IF_DEALER_003_Res_O_RETURN         O_RETURN {get;set;} 
            @AuraEnabled public List<IF_DEALER_003_Res_T_TCREDIT>  T_TCREDIT {get;set;} 
            @AuraEnabled public List<IF_DEALER_003_Res_T_DCREDIT>  T_DCREDIT {get;set;} 
            @AuraEnabled public List<IF_DEALER_003_Res_T_OPDOLIST> T_OPDOLIST {get;set;} 
      
          }
      
          public class IF_DEALER_003_Res_O_HEADER { 
            public IF_DEALER_003_Res_O_HEADER(){}

            @AuraEnabled public String CNT   {get;set;} // ? Count
            @AuraEnabled public String NETWR {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String CLAMT {get;set;} // ? Not Cleared A/R
            @AuraEnabled public String ICAMT {get;set;} // ? Not Cleared A/R
            @AuraEnabled public String FBAMT {get;set;} // ? Capital AR
            @AuraEnabled public String MRAMT {get;set;} // ? Mort. AR
            @AuraEnabled public String WAERS {get;set;} // ? Currency Key
      
        }
      
          public class IF_DEALER_003_Res_O_RETURN { 
            public IF_DEALER_003_Res_O_RETURN(){}

            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
      
        }
      
          public class IF_DEALER_003_Res_T_TCREDIT { 
            public IF_DEALER_003_Res_T_TCREDIT(){}
              @AuraEnabled public String BUKRS {get;set;}
              @AuraEnabled public String VKORG {get;set;}
              @AuraEnabled public String SPART {get;set;}
              @AuraEnabled public String KUNNR {get;set;}
              @AuraEnabled public String WAERS {get;set;}
              @AuraEnabled public String NETWR {get;set;}
              @AuraEnabled public String SALES {get;set;}
              @AuraEnabled public String AVGAR {get;set;}
              @AuraEnabled public String TOVER {get;set;}
              @AuraEnabled public String TOVPI {get;set;}
              @AuraEnabled public String CRATE {get;set;}
              @AuraEnabled public String CRAMT {get;set;}
              @AuraEnabled public String ICAMT {get;set;}
              @AuraEnabled public String OVERDUE {get;set;}
              @AuraEnabled public String TIAMT {get;set;}
              @AuraEnabled public String TSAMT {get;set;}
              @AuraEnabled public String MTAMT {get;set;}
              @AuraEnabled public String ARAMT {get;set;}
              @AuraEnabled public String EVAMT {get;set;}
              @AuraEnabled public String LMAMT {get;set;}
              @AuraEnabled public String TCAMT {get;set;}
              @AuraEnabled public String RCLAT {get;set;}
              @AuraEnabled public String FBAMT {get;set;}
              @AuraEnabled public String MRAMT {get;set;}
              @AuraEnabled public String MRATE {get;set;}
              @AuraEnabled public String NCRAT {get;set;}
              @AuraEnabled public String THREE {get;set;}
              @AuraEnabled public String VBELN_VA {get;set;}
              @AuraEnabled public String VBELN_VF {get;set;}
              @AuraEnabled public String DOWNMT {get;set;}
              @AuraEnabled public String DELIMT {get;set;}
              @AuraEnabled public String ZOPENSO_NON {get;set;}
              @AuraEnabled public String ZOPENSO_CON {get;set;}
              @AuraEnabled public String ZOPENSO_ZDRI {get;set;}
              @AuraEnabled public String CLAMT {get;set;}
              @AuraEnabled public String NAME1 {get;set;}
              @AuraEnabled public String J_1KFREPRE {get;set;}
              @AuraEnabled public String FKDAT {get;set;}
      
        }
      
          public class IF_DEALER_003_Res_T_DCREDIT { 
            public IF_DEALER_003_Res_T_DCREDIT(){}

            @AuraEnabled public String BUKRS {get;set;} // ? Company Code
            @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
            @AuraEnabled public String SPART {get;set;} // ? Division
            @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
            @AuraEnabled public String WAERS {get;set;} // ? Currency Key
            @AuraEnabled public String NETWR {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String SALES {get;set;} // ? Last 365 days Sales Amount
            @AuraEnabled public String AVGAR {get;set;} // ? Average A/R Amount
            @AuraEnabled public String TOVER {get;set;} // ? Receivables Turnover
            @AuraEnabled public String TOVPI {get;set;} // ? Receivables Turnover Period
            @AuraEnabled public String CRATE {get;set;} // ? Calculated rate
            @AuraEnabled public String CRAMT {get;set;} // ? Credit Amount
            @AuraEnabled public String ICAMT {get;set;} // ? Not Cleared A/R
            @AuraEnabled public String OVERDUE {get;set;} // ? Overdue amt
            @AuraEnabled public String TIAMT {get;set;} // ? Today’s Incoming Amount
            @AuraEnabled public String TSAMT {get;set;} // ? Today’s Sales Amount
            @AuraEnabled public String MTAMT {get;set;} // ? Mort. Credit
            @AuraEnabled public String ARAMT {get;set;} // ? Sales Credit
            @AuraEnabled public String EVAMT {get;set;} // ? Evaluation Credit
            @AuraEnabled public String LMAMT {get;set;} // ? Temp. Credit
            @AuraEnabled public String TCAMT {get;set;} // ? Total Credit
            @AuraEnabled public String RCLAT {get;set;} // ? Credit Balance
            @AuraEnabled public String FBAMT {get;set;} // ? Capital AR
            @AuraEnabled public String MRAMT {get;set;} // ? Mort. AR
            @AuraEnabled public String MRATE {get;set;} // ? Mort. AR Rate
            @AuraEnabled public String NCRAT {get;set;} // ? Total AR Rate
            @AuraEnabled public String THREE {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String VBELN_VA {get;set;} // ? Sales Document
            @AuraEnabled public String VBELN_VF {get;set;} // ? Billing Document
            @AuraEnabled public String DOWNMT {get;set;} // ? Downpay Total Amount
            @AuraEnabled public String DELIMT {get;set;} // ? Delivery Amount
            @AuraEnabled public String ZOPENSO_NON {get;set;} // ? NON-consignment open sales amount
            @AuraEnabled public String ZOPENSO_CON {get;set;} // ? consignment open SO amount
            @AuraEnabled public String ZOPENSO_ZDRI {get;set;} // ? ZDRI open SO amount
            @AuraEnabled public String CLAMT {get;set;} // ? Not Cleared A/R
            @AuraEnabled public String NAME1 {get;set;} // ? Name 1
            @AuraEnabled public String J_1KFREPRE {get;set;} // ? Name of Representative
            @AuraEnabled public String FKDAT {get;set;} // ? Billing date for billing index and printout
      
          }
      
          public class IF_DEALER_003_Res_T_OPDOLIST { 
            public IF_DEALER_003_Res_T_OPDOLIST(){}

            @AuraEnabled public String VBELN      {get;set;} // ? Sales Document
            @AuraEnabled public String VBELN_D    {get;set;} // ? Delivery
            @AuraEnabled public String NETWR_T    {get;set;} // ? Net Value in Document Currency
            @AuraEnabled public String WAERK      {get;set;} // ? SD Document Currency
            @AuraEnabled public String KUNNR      {get;set;} // ? Customer Number 1
            @AuraEnabled public String NAME1      {get;set;} // ? Name 1
            @AuraEnabled public String J_1KFREPRE {get;set;} // ? Name of Representative
      
            }
  
  
  

/** IF_DEALER_008
    */  
    /**
         * ClassName            : IF_ERP_Dealer 
         * Wrapper Name         : IF_DEALER_008
         * SFDC interface Id    : IF-DEALER-008
         * AS-IS RFC            : Z_SD_MS_DE_ASS
         * New I/F              : ZCRM_SD_MS_DE_ASS
         * Description          : Account를 담당하는 DNS 직판인원, 딜러 Partner 정보 연동
     */
    /** REQUEST 
      */  
      public class IF_DEALER_008_Req { 
        public IF_DEALER_008_Req(){}
        @AuraEnabled public String I_KUNNR  {get;set;} // ? Customer Number 1
        @AuraEnabled public String I_VKORG  {get;set;} // ? Sales Organization
        @AuraEnabled public String I_VTWEG  {get;set;} // ? Distribution Channel
        @AuraEnabled public String I_SPART  {get;set;} // ? Division
        @AuraEnabled public String I_DEALER {get;set;} // ? Assign Dealer
        @AuraEnabled public String I_PARVW  {get;set;} // ? v1.3 : Partner Function Code
        @AuraEnabled public IF_DEALER_008_Req_T_KNA1 T_KNA1 {get;set;} 
  
      }
  
      public class IF_DEALER_008_Req_T_KNA1 { 
        public IF_DEALER_008_Req_T_KNA1(){}

        @AuraEnabled public String KUNNR     {get;set;} // ? Customer Number 1
        @AuraEnabled public String NAME1     {get;set;} // ? Name 1
        @AuraEnabled public String ORT01     {get;set;} // ? City
        @AuraEnabled public String STRAS     {get;set;} // ? House number and street
        @AuraEnabled public String LAND1     {get;set;} // ? Country Key
  
        @AuraEnabled public String LANDX     {get;set;} // ? Country Name
        @AuraEnabled public String ERNAM     {get;set;} // ? Name of Person who Created the Object
        @AuraEnabled public String ERDAT     {get;set;} // ? Date on which the Record Was Created
        @AuraEnabled public String KTOKD     {get;set;} // ? Customer Account Group
        @AuraEnabled public String KDGRP     {get;set;} // ? Customer group
  
        @AuraEnabled public String KTEXT     {get;set;} // ? Name
        @AuraEnabled public String ANRED     {get;set;} // ? Title
        @AuraEnabled public String LOCATION  {get;set;} // ? Street 5
        @AuraEnabled public String REGIO     {get;set;} // ? Region (State, Province, County)
        @AuraEnabled public String SORTL     {get;set;} // ? Sort field
  
        @AuraEnabled public String NAME3     {get;set;} // ? Name 3
        @AuraEnabled public String PSTLZ     {get;set;} // ? Postal Code
        @AuraEnabled public String TELF1     {get;set;} // ? First telephone number
        @AuraEnabled public String TELF2     {get;set;} // ? Second telephone number
        @AuraEnabled public String TELFX     {get;set;} // ? Fax Number
  
        @AuraEnabled public String KNURL     {get;set;} // ? Uniform Resource Locator
        @AuraEnabled public String KATR1     {get;set;} // ? Customer group 1
        @AuraEnabled public String VTEXT1    {get;set;} // ? Description
        @AuraEnabled public String KATR2     {get;set;} // ? Customer group 2
        @AuraEnabled public String VTEXT2    {get;set;} // ? Description
  
        @AuraEnabled public String KATR3     {get;set;} // ? Customer group 3
        @AuraEnabled public String VTEXT3    {get;set;} // ? Description
        @AuraEnabled public String STCD1     {get;set;} // ? Tax Number 1
        @AuraEnabled public String STCD2     {get;set;} // ? Tax Number 2
        @AuraEnabled public String J_1KFTBUS {get;set;} // ? Type of Business
  
        @AuraEnabled public String J_1KFTIND {get;set;} // ? Type of Industry
        @AuraEnabled public String JMZAH     {get;set;} // ? Yearly number of employees
        @AuraEnabled public String JMJAH     {get;set;} // ? Year for which the number of employees is given
        @AuraEnabled public String BZIRK     {get;set;} // ? Sales district
        @AuraEnabled public String BZTXT     {get;set;} // ? Name of the district
  
        @AuraEnabled public String VKBUR     {get;set;} // ? Sales Office
        @AuraEnabled public String BEZEI     {get;set;} // ? Name of the controlling area
        @AuraEnabled public String KTONR     {get;set;} // ? Customer number of business partner
        @AuraEnabled public String NAME22    {get;set;} // ? Name
        @AuraEnabled public String VSBED     {get;set;} // ? Shipping Conditions
  
        @AuraEnabled public String VTEXT4    {get;set;} // ? Description of the shipping conditions
        @AuraEnabled public String VKORG     {get;set;} // ? Sales Organization
        @AuraEnabled public String VTEXT5    {get;set;} // ? Description
        @AuraEnabled public String VTWEG     {get;set;} // ? Distribution Channel
        @AuraEnabled public String VTEXT6    {get;set;} // ? Description
  
        @AuraEnabled public String SPART     {get;set;} // ? Division
        @AuraEnabled public String VTEXT7    {get;set;} // ? Description
        @AuraEnabled public String MDLNM     {get;set;} // ? Model Name
        @AuraEnabled public String MATNR     {get;set;} // ? Material Number
        @AuraEnabled public String MAKTX     {get;set;} // ? Material Description (Short Text)
  
        @AuraEnabled public String MEINS     {get;set;} // ? Base Unit of Measure
        @AuraEnabled public String ADRNR     {get;set;} // ? Address
        @AuraEnabled public String FLAG      {get;set;} // ? Assign Flag(D:delete)
        @AuraEnabled public String STCD4     {get;set;} // ? Tax Number 4
        @AuraEnabled public String SATNR     {get;set;} // ? Cross-Plant Configurable Material
  
        @AuraEnabled public String AUFSD     {get;set;} // ? Customer order block (sales area)
        @AuraEnabled public String J_1KFREPRE {get;set;} // ? Name of Representative
        @AuraEnabled public String VBELN     {get;set;} // ? Sales Document
        @AuraEnabled public String WADAT_IST {get;set;} // ? Actual Goods Movement Date
        @AuraEnabled public String VRKME     {get;set;} // ? Sales unit
  
        @AuraEnabled public String LFIMG     {get;set;} // ? Actual quantity delivered (in sales units)
        @AuraEnabled public String TOTAL_LFIMG {get;set;} // ? Actual quantity delivered (in sales units)
        @AuraEnabled public String ZSEXTEN   {get;set;} // ? X : 4140 sales area extended, space : not extended
        @AuraEnabled public String ZMESSAGE  {get;set;} // ? Message: Please Extend Salea area(1140/10/10) of Ship to
        @AuraEnabled public String STCD3     {get;set;} // ? Tax Number 3
  
        @AuraEnabled public String KONZS     {get;set;} // ? Group key
        @AuraEnabled public String NAME_GR   {get;set;} // ? GKAM customer Mother text
        @AuraEnabled public String KATR10    {get;set;} // ? GKAM 수요산업 구분 1
        @AuraEnabled public String VTEXT10   {get;set;} // ? GKAM 수요산업 구분 1 TEXT
        @AuraEnabled public String KATR20    {get;set;} // ? GKAM 수요산업 구분 2
  
        @AuraEnabled public String VTEXT20   {get;set;} // ? GKAM 수요산업 구분 2 TEXT
        @AuraEnabled public String KATR30    {get;set;} // ? GKAM 수요산업 구분 3
        @AuraEnabled public String VTEXT30   {get;set;} // ? GKAM 수요산업 구분 3 TEXT
        @AuraEnabled public String GKAM_M    {get;set;} // ? M:GKAM Mother Customer
        @AuraEnabled public String ZTURNOVER {get;set;} // ? Turnover
  
        @AuraEnabled public String ZEMPL     {get;set;} // ? No. of employees
        @AuraEnabled public String ZPRESI    {get;set;} // ? President
        @AuraEnabled public String ZYEAR     {get;set;} // ? Year established
        @AuraEnabled public String ZHEADQ    {get;set;} // ? Headquarters
        @AuraEnabled public String ZVOL      {get;set;} // ? Number of manufacturing and operational sites
  
        @AuraEnabled public String ZPROD     {get;set;} // ? Production
        @AuraEnabled public String ZBUYER    {get;set;} // ? Main buyers
        @AuraEnabled public String ZWEBPAGE  {get;set;} // ? Web page
        @AuraEnabled public String REGIO_T   {get;set;} // ? Region text
        @AuraEnabled public String SMTP_ADDR {get;set;} // ? E-Mail Address
      }
  
    /** RESPONSE 
      */    
      public class IF_DEALER_008_Res { 
        public IF_DEALER_008_Res(){}

        @AuraEnabled public String O_RECODE {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String O_REMSG {get;set;} // ? Message Text
  
      }


/** IF_DEALER_007
    */  
    /**
         * ClassName            : IF_ERP_Dealer 
         * Wrapper Name         : IF_DEALER_007
         * SFDC interface Id    : IF-DEALER-007
         * AS-IS RFC            : 
         * New I/F              : ZCRM_FI_GET_AR_INCOM
         * Description          : 주문별 수금일정 조회 - ERP I/F 통해 고객 및 계약번호별로 주문별 수금일정 조회
     */
    /** REQUEST 
      */       
        public class IF_DEALER_007_Req { 
          public IF_DEALER_007_Req(){
            this.TRA_ZUONR = new List<IF_DEALER_007_Req_TRA_ZUONR>();
            this.TRA_KUNNR = new List<IF_DEALER_007_Req_TRA_KUNNR>();
            this.TRA_FKDAT = new List<IF_DEALER_007_Req_TRA_FKDAT>();
            this.TRA_GSBER = new List<IF_DEALER_007_Req_TRA_GSBER>();
            this.TRA_VKBUR = new List<IF_DEALER_007_Req_TRA_VKBUR>();            
          }
          @AuraEnabled public String I_BUKRS {get;set;} // ? Company Code
          @AuraEnabled public String I_KUNNR {get;set;} // ? Customer Number 1
          @AuraEnabled public String I_ZUONR {get;set;} // ? Assignment Number
          @AuraEnabled public String I_BASE {get;set;} // ? Field of type DATS
          @AuraEnabled public String I_REVERSE {get;set;} // ? REVERSED DOC
          @AuraEnabled public String I_ALT {get;set;} // ? ALTERNATIVE IND. ''/'D'

          @AuraEnabled public List<IF_DEALER_007_Req_TRA_ZUONR> TRA_ZUONR {get;set;} 
          @AuraEnabled public List<IF_DEALER_007_Req_TRA_KUNNR> TRA_KUNNR {get;set;} 
          @AuraEnabled public List<IF_DEALER_007_Req_TRA_FKDAT> TRA_FKDAT {get;set;} 
          @AuraEnabled public List<IF_DEALER_007_Req_TRA_GSBER> TRA_GSBER {get;set;} 
          @AuraEnabled public List<IF_DEALER_007_Req_TRA_VKBUR> TRA_VKBUR {get;set;} 

        }

        public class IF_DEALER_007_Req_TRA_ZUONR { 
          public IF_DEALER_007_Req_TRA_ZUONR(){}
          @AuraEnabled public String SIGN {get;set;} // ? Type of SIGN component in row type of a Ranges type
          @AuraEnabled public String OPTION {get;set;} // ? Type of OPTION component in row type of a Ranges type
          @AuraEnabled public String LOW  {get;set;} // ? Char 20
          @AuraEnabled public String HIGH {get;set;} // ? Char 20

        }

        public class IF_DEALER_007_Req_TRA_KUNNR {
          public IF_DEALER_007_Req_TRA_KUNNR(){}
          @AuraEnabled public String SIGN {get;set;} // ? ABAP: ID: I/E (include/exclude values)
          @AuraEnabled public String OPTION {get;set;} // ? ABAP: Selection option (EQ/BT/CP/...)
          @AuraEnabled public String LOW  {get;set;} // ? Customer Number 1
          @AuraEnabled public String HIGH {get;set;} // ? Customer Number 1

        }

        public class IF_DEALER_007_Req_TRA_FKDAT { 
          public IF_DEALER_007_Req_TRA_FKDAT(){}
          @AuraEnabled public String SIGN {get;set;} // ? Inclusion/exclusion criterion SIGN for range tables
          @AuraEnabled public String OPTION {get;set;} // ? Selection operator OPTION for range tables
          @AuraEnabled public String LOW  {get;set;} // ? Due date
          @AuraEnabled public String HIGH {get;set;} // ? Due date

        }

        public class IF_DEALER_007_Req_TRA_GSBER {
          public IF_DEALER_007_Req_TRA_GSBER(){}
          @AuraEnabled public String SIGN {get;set;} // ? ABAP: ID: I/E (include/exclude values)
          @AuraEnabled public String OPTION {get;set;} // ? ABAP: Selection option (EQ/BT/CP/...)
          @AuraEnabled public String LOW  {get;set;} // ? Business Area
          @AuraEnabled public String HIGH {get;set;} // ? Business Area

        }

        public class IF_DEALER_007_Req_TRA_VKBUR {
          public IF_DEALER_007_Req_TRA_VKBUR(){}
          @AuraEnabled public String SIGN {get;set;} // ? Inclusion/exclusion criterion SIGN for range tables
          @AuraEnabled public String OPTION {get;set;} // ? Selection operator OPTION for range tables
          @AuraEnabled public String LOW  {get;set;} // ? Sales Office
          @AuraEnabled public String HIGH {get;set;} // ? Sales Office

        }

    /** RESPONSE 
      */       
        public class IF_DEALER_007_Res {
          public IF_DEALER_007_Res(){} 
          @AuraEnabled public List<IF_DEALER_007_Res_T_ORDER>    T_ORDER {get;set;} 
          @AuraEnabled public List<IF_DEALER_007_Res_T_ORDER2>   T_ORDER2 {get;set;} 
          @AuraEnabled public List<IF_DEALER_007_Res_T_LIST>     T_LIST {get;set;} 
          @AuraEnabled public List<IF_DEALER_007_Res_T_DOWN>     T_DOWN {get;set;} 
          @AuraEnabled public List<IF_DEALER_007_Res_T_ARSTATUS> T_ARSTATUS {get;set;} 
          @AuraEnabled public List<IF_DEALER_007_Res_T_MSG>      T_MSG {get;set;} 

          }

        public class IF_DEALER_007_Res_T_ORDER {
          public IF_DEALER_007_Res_T_ORDER(){} 

          @AuraEnabled public String BUKRS  {get;set;} // ? Company Code
          @AuraEnabled public String ZUONR  {get;set;} // ? Assignment Number
          @AuraEnabled public String VBELV  {get;set;} // ? Originating document
          @AuraEnabled public String MATNR  {get;set;} // ? Material Number
          @AuraEnabled public String FKDAT  {get;set;} // ? Billing date for billing index and printout
          @AuraEnabled public String KUNNR  {get;set;} // ? Customer Number 1
          @AuraEnabled public String NAME1  {get;set;} // ? Name
          @AuraEnabled public String CEO    {get;set;} // ? Name of Representative
          @AuraEnabled public String GSBER  {get;set;} // ? Business Area
          @AuraEnabled public String ZTERM  {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String VKBUR  {get;set;} // ? Sales Office
          @AuraEnabled public String VKBUR_NAME {get;set;} // ? Description
          @AuraEnabled public String NETWR  {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String DOWN_PAY {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String BOE_AMT {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String OVER_INCOM {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String OPEN_INT {get;set;} // ? Interest amount
          @AuraEnabled public String REC_INT {get;set;} // ? Recived interest
          @AuraEnabled public String OPEN_SUM {get;set;} // ? Amount in document currency
          @AuraEnabled public String WAERS  {get;set;} // ? Currency Key
          @AuraEnabled public String REDUCE_INT {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String DMBTR  {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String WRBTR  {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String CL_DMBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String CL_WRBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String MTART  {get;set;} // ? Material Type
          @AuraEnabled public String MAKTX  {get;set;} // ? Material Description (Short Text)
          @AuraEnabled public String VKORG  {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG  {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART  {get;set;} // ? Division
          @AuraEnabled public String AUDAT  {get;set;} // ? Document Date (Date Received/Sent)
          @AuraEnabled public String PAPH1  {get;set;} // ? Prod.hierarchy01-1
          @AuraEnabled public String VTEXT1 {get;set;} // ? Description
          @AuraEnabled public String PAPH2  {get;set;} // ? Prod.hierarchy01-2
          @AuraEnabled public String VTEXT2 {get;set;} // ? Description
          @AuraEnabled public String ZZTERM {get;set;} // ? Payment Terms(Extension)

        }

        public class IF_DEALER_007_Res_T_ORDER2 {
          public IF_DEALER_007_Res_T_ORDER2(){} 
          @AuraEnabled public String BUKRS {get;set;} // ? Company Code
          @AuraEnabled public String ZUONR {get;set;} // ? Assignment Number
          @AuraEnabled public String VBELV {get;set;} // ? Originating document
          @AuraEnabled public String MATNR {get;set;} // ? Material Number
          @AuraEnabled public String FKDAT {get;set;} // ? Billing date for billing index and printout
          @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
          @AuraEnabled public String NAME1 {get;set;} // ? Name
          @AuraEnabled public String CEO   {get;set;} // ? Name of Representative
          @AuraEnabled public String GSBER {get;set;} // ? Business Area
          @AuraEnabled public String ZTERM {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String VKBUR {get;set;} // ? Sales Office
          @AuraEnabled public String VKBUR_NAME {get;set;} // ? Description
          @AuraEnabled public String NETWR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String DOWN_PAY {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String BOE_AMT {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String OVER_INCOM {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String OPEN_INT {get;set;} // ? Interest amount
          @AuraEnabled public String REC_INT {get;set;} // ? Recived interest
          @AuraEnabled public String OPEN_SUM {get;set;} // ? Amount in document currency
          @AuraEnabled public String WAERS {get;set;} // ? Currency Key
          @AuraEnabled public String REDUCE_INT {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String DMBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String WRBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String CL_DMBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String CL_WRBTR {get;set;} // ? Net Value of the Sales Order in Document Currency
          @AuraEnabled public String MTART {get;set;} // ? Material Type
          @AuraEnabled public String MAKTX {get;set;} // ? Material Description (Short Text)
          @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART {get;set;} // ? Division
          @AuraEnabled public String AUDAT {get;set;} // ? Document Date (Date Received/Sent)
          @AuraEnabled public String PAPH1 {get;set;} // ? Prod.hierarchy01-1
          @AuraEnabled public String VTEXT1 {get;set;} // ? Description
          @AuraEnabled public String PAPH2 {get;set;} // ? Prod.hierarchy01-2
          @AuraEnabled public String VTEXT2 {get;set;} // ? Description
          @AuraEnabled public String XBLNR {get;set;} // ? Reference Document Number
          @AuraEnabled public String AUGDT {get;set;} // ? Clearing Date
          @AuraEnabled public String ZFBDT {get;set;} // ? Baseline Date for Due Date Calculation

        }

        public class IF_DEALER_007_Res_T_LIST {
          public IF_DEALER_007_Res_T_LIST(){} 

          @AuraEnabled public String ZUONR    {get;set;} // ? Assignment Number
          @AuraEnabled public String VBELV    {get;set;} // ? Sales Document
          @AuraEnabled public String POSNR    {get;set;} // ? Sales Document Item
          @AuraEnabled public String VBELN_VF {get;set;} // ? Billing Document
          @AuraEnabled public String POSNR_VF {get;set;} // ? Billing item
          @AuraEnabled public String XREF1    {get;set;} // ? Business partner reference key
          @AuraEnabled public String ZTERM    {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String HLEVEL   {get;set;} // ? Hierarchy Level
          @AuraEnabled public String LINE_TYPE {get;set;} // ? Not More Closely Defined Area, Possibly Used for Patchlevels
          @AuraEnabled public String MATNR    {get;set;} // ? Material Number
          @AuraEnabled public String FAEDT    {get;set;} // ? Net Due Date
          @AuraEnabled public String WAERS    {get;set;} // ? Currency Key
          @AuraEnabled public String NETWR    {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String WRBTR    {get;set;} // ? Amount in document currency
          @AuraEnabled public String DMBTR    {get;set;} // ? Amount in Local Currency
          @AuraEnabled public String CL_WRBTR {get;set;} // ? Amount in document currency
          @AuraEnabled public String CL_DMBTR {get;set;} // ? Amount in Local Currency
          @AuraEnabled public String GJAHR    {get;set;} // ? Fiscal Year
          @AuraEnabled public String BELNR    {get;set;} // ? Accounting Document Number
          @AuraEnabled public String BUZEI    {get;set;} // ? Number of Line Item Within Accounting Document
          @AuraEnabled public String AUGBL    {get;set;} // ? Document Number of the Clearing Document
          @AuraEnabled public String AUGGJ    {get;set;} // ? Fiscal Year of Clearing Document
          @AuraEnabled public String AUGZZ    {get;set;} // ? Line Item in the Relevant Invoice
          @AuraEnabled public String OVDUE    {get;set;} // ? OVERDUE DAY
          @AuraEnabled public String INDAT    {get;set;} // ? Pay-In Date
          @AuraEnabled public String CAL_DAY  {get;set;} // ? interest caculation Due date
          @AuraEnabled public String INT_AMT  {get;set;} // ? Interest amount
          @AuraEnabled public String BILLAMT  {get;set;} // ? Overdue Bill amount
          @AuraEnabled public String REC_INT  {get;set;} // ? Recived interest
          @AuraEnabled public String REDAMT   {get;set;} // ? Reduction amount
          @AuraEnabled public String KUNNR    {get;set;} // ? Customer Number 1
          @AuraEnabled public String ZFBDT    {get;set;} // ? Baseline Date for Due Date Calculation
          @AuraEnabled public String BLDAT    {get;set;} // ? Document Date in Document
          @AuraEnabled public String SGTXT    {get;set;} // ? Item Text
          @AuraEnabled public String MWSKZ    {get;set;} // ? Sales Tax Code
          @AuraEnabled public String HKONT    {get;set;} // ? General Ledger Account
          @AuraEnabled public String KURSF    {get;set;} // ? Exchange rate
          @AuraEnabled public String AUGDT    {get;set;} // ? Clearing Date
          @AuraEnabled public String BLART    {get;set;} // ? Document Type
          @AuraEnabled public String BUDAT    {get;set;} // ? Posting Date in the Document
          @AuraEnabled public String BSCHL    {get;set;} // ? Posting Key
          @AuraEnabled public String SHKZG    {get;set;} // ? Debit/Credit Indicator
          @AuraEnabled public String METHOD   {get;set;} // ? Pay Method
          @AuraEnabled public String MTART    {get;set;} // ? Material Type
          @AuraEnabled public String SERNR    {get;set;} // ? Serial number
          @AuraEnabled public String PAPH1    {get;set;} // ? Prod.hierarchy01-1
          @AuraEnabled public String VTEXT1   {get;set;} // ? Description
          @AuraEnabled public String PAPH2    {get;set;} // ? Prod.hierarchy01-2
          @AuraEnabled public String VTEXT2   {get;set;} // ? Description
          @AuraEnabled public String B2_GJAHR {get;set;} // ? Fiscal Year
          @AuraEnabled public String B2_BELNR {get;set;} // ? Accounting Document Number

        }

        public class IF_DEALER_007_Res_T_DOWN { 
          public IF_DEALER_007_Res_T_DOWN(){} 

          @AuraEnabled public String ZUONR    {get;set;} // ? Assignment Number
          @AuraEnabled public String VBELV    {get;set;} // ? Sales Document
          @AuraEnabled public String POSNR    {get;set;} // ? Sales Document Item
          @AuraEnabled public String VBELN_VF {get;set;} // ? Billing Document
          @AuraEnabled public String POSNR_VF {get;set;} // ? Billing item
          @AuraEnabled public String XREF1    {get;set;} // ? Business partner reference key
          @AuraEnabled public String ZTERM    {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String HLEVEL   {get;set;} // ? Hierarchy Level
          @AuraEnabled public String LINE_TYPE {get;set;} // ? Not More Closely Defined Area, Possibly Used for Patchlevels
          @AuraEnabled public String MATNR    {get;set;} // ? Material Number
          @AuraEnabled public String FAEDT    {get;set;} // ? Net Due Date
          @AuraEnabled public String WAERS    {get;set;} // ? Currency Key
          @AuraEnabled public String NETWR    {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String WRBTR    {get;set;} // ? Amount in document currency
          @AuraEnabled public String DMBTR    {get;set;} // ? Amount in Local Currency
          @AuraEnabled public String CL_WRBTR {get;set;} // ? Amount in document currency
          @AuraEnabled public String CL_DMBTR {get;set;} // ? Amount in Local Currency
          @AuraEnabled public String GJAHR    {get;set;} // ? Fiscal Year
          @AuraEnabled public String BELNR    {get;set;} // ? Accounting Document Number
          @AuraEnabled public String BUZEI    {get;set;} // ? Number of Line Item Within Accounting Document
          @AuraEnabled public String AUGBL    {get;set;} // ? Document Number of the Clearing Document
          @AuraEnabled public String AUGGJ    {get;set;} // ? Fiscal Year of Clearing Document
          @AuraEnabled public String AUGZZ    {get;set;} // ? Line Item in the Relevant Invoice
          @AuraEnabled public String OVDUE    {get;set;} // ? OVERDUE DAY
          @AuraEnabled public String INDAT    {get;set;} // ? Pay-In Date
          @AuraEnabled public String CAL_DAY  {get;set;} // ? interest caculation Due date
          @AuraEnabled public String INT_AMT  {get;set;} // ? Interest amount
          @AuraEnabled public String BILLAMT  {get;set;} // ? Overdue Bill amount
          @AuraEnabled public String REC_INT  {get;set;} // ? Recived interest
          @AuraEnabled public String REDAMT   {get;set;} // ? Reduction amount
          @AuraEnabled public String KUNNR    {get;set;} // ? Customer Number 1
          @AuraEnabled public String ZFBDT    {get;set;} // ? Baseline Date for Due Date Calculation
          @AuraEnabled public String BLDAT    {get;set;} // ? Document Date in Document
          @AuraEnabled public String SGTXT    {get;set;} // ? Item Text
          @AuraEnabled public String MWSKZ    {get;set;} // ? Sales Tax Code
          @AuraEnabled public String HKONT    {get;set;} // ? General Ledger Account
          @AuraEnabled public String KURSF    {get;set;} // ? Exchange rate
          @AuraEnabled public String AUGDT    {get;set;} // ? Clearing Date
          @AuraEnabled public String BLART    {get;set;} // ? Document Type
          @AuraEnabled public String BUDAT    {get;set;} // ? Posting Date in the Document
          @AuraEnabled public String BSCHL    {get;set;} // ? Posting Key
          @AuraEnabled public String SHKZG    {get;set;} // ? Debit/Credit Indicator
          @AuraEnabled public String METHOD   {get;set;} // ? Pay Method
          @AuraEnabled public String MTART    {get;set;} // ? Material Type
          @AuraEnabled public String SERNR    {get;set;} // ? Serial number
          @AuraEnabled public String PAPH1    {get;set;} // ? Prod.hierarchy01-1
          @AuraEnabled public String VTEXT1   {get;set;} // ? Description
          @AuraEnabled public String PAPH2    {get;set;} // ? Prod.hierarchy01-2
          @AuraEnabled public String VTEXT2   {get;set;} // ? Description
          @AuraEnabled public String B2_GJAHR {get;set;} // ? Fiscal Year
          @AuraEnabled public String B2_BELNR {get;set;} // ? Accounting Document Number

        }

        public class IF_DEALER_007_Res_T_ARSTATUS { 
          public IF_DEALER_007_Res_T_ARSTATUS(){} 

          @AuraEnabled public String LINE_NO {get;set;} // ? Sequence Number
          @AuraEnabled public String TEXT1 {get;set;} // ? Text (20 Characters)
          @AuraEnabled public String WRBTR {get;set;} // ? Amount in document currency
          @AuraEnabled public String DMBTR {get;set;} // ? Amount in Local Currency
          @AuraEnabled public String ZFBDT {get;set;} // ? Baseline Date for Due Date Calculation
          @AuraEnabled public String ZBD1T {get;set;} // ? Cash discount days 1
          @AuraEnabled public String FAEDT {get;set;} // ? Net Due Date
          @AuraEnabled public String CLEAR {get;set;} // ? Clearing Amount
          @AuraEnabled public String AUGDT {get;set;} // ? Clearing Date
          @AuraEnabled public String BUDAT {get;set;} // ? Posting Date in the Document
          @AuraEnabled public String RECIVE_DAT {get;set;} // ? Receive date
          @AuraEnabled public String OVDUE {get;set;} // ? OVERDUE DAY
          @AuraEnabled public String INT_AMT {get;set;} // ? Interest amount
          @AuraEnabled public String REC_INT {get;set;} // ? Recived interest
          @AuraEnabled public String REM_INT {get;set;} // ? Remaining Interest
          @AuraEnabled public String BILLAMT {get;set;} // ? Overdue Bill amount
          @AuraEnabled public String BELNR {get;set;} // ? Accounting Document Number
          @AuraEnabled public String BUZEI {get;set;} // ? Number of Line Item Within Accounting Document
          @AuraEnabled public String GJAHR {get;set;} // ? Fiscal Year
          @AuraEnabled public String AUGBL {get;set;} // ? Document Number of the Clearing Document
          @AuraEnabled public String BOENO {get;set;} // ? BOE Number
          @AuraEnabled public String BOE_DOC {get;set;} // ? Accounting Document Number
          @AuraEnabled public String BOE_ITM {get;set;} // ? Number of Line Item Within Accounting Document
          @AuraEnabled public String ZTERM {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String BUKRS {get;set;} // ? Company Code
          @AuraEnabled public String WAERS {get;set;} // ? Currency Key
          @AuraEnabled public String BSCHL {get;set;} // ? Posting Key
          @AuraEnabled public String AUJAH {get;set;} // ? Clearing document fiscal year

        }

        // NUMBER => IF_NUMBER
        public class IF_DEALER_007_Res_T_MSG {
          public IF_DEALER_007_Res_T_MSG(){} 

          @AuraEnabled public String TYPE   {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
          @AuraEnabled public String IF_NUMBER {get;set;} // ? Message Number

        }

/** IF_DEALER_010
    */  
    /**
         * ClassName            : IF_ERP_Dealer 
         * Wrapper Name         : IF_DEALER_010
         * SFDC interface Id    : IF-DEALER-010
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_GET_INCOMING_COLLECT 
         * Description          : 월별 수금계획
     */
    /** REQUEST 
      */           
        public class IF_DEALER_010_Req { 
        @AuraEnabled public String I_DEALER     {get;set;} // ? Validity end date of the condition record
        @AuraEnabled public String I_ERDAT_F {get;set;} // ? Validity start date of the condition record
        @AuraEnabled public String I_ERDAT_T {get;set;} // ? User Name
        }

    /** RESPONSE 
      */       
        public class IF_DEALER_010_Res { 
        public IF_DEALER_010_Res(){
          this.O_RETURN = new IF_DEALER_010_Res_O_RETURN();
          this.T_LIST   = new List<IF_DEALER_010_Res_T_LIST>(); 
        }
        @AuraEnabled public IF_DEALER_010_Res_O_RETURN     O_RETURN {get;set;} 
        @AuraEnabled public List<IF_DEALER_010_Res_T_LIST> T_LIST {get;set;} 
        }

        public class IF_DEALER_010_Res_O_RETURN { 
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

        public class IF_DEALER_010_Res_T_LIST { 
        @AuraEnabled public String EST_DAT {get;set;} // ? Est.Incoming Date
        @AuraEnabled public String EST_AMT {get;set;} // ? Est.Incoming AMT
        @AuraEnabled public String CLS_AMT {get;set;} // ? Incoming amount
        }




}