/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : deokjun.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-23-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_DELIV_Classes {
    public IF_ERP_DELIV_Classes() {}

    // SFDC interface Id    : IF_DELIV_001
    // AS-IS RFC            : Z_SD_CREATE_DELIVERY_ORDER_ME       
    // New I/F              : ZCRM_SD_CREATE_DELIVERY_ORDER				
    // Description          : DO 생성    
    public class IF_DELIV_001_Req { 
        @AuraEnabled public String I_CHK        {get;set;} // ? Boolean Variable (X=True, -=False, Space=Unknown)
        @AuraEnabled public String I_VBELN      {get;set;} // ? Sales and Distribution Document Number
        @AuraEnabled public String I_CAPITAL_NO {get;set;} // ? Capital No.
        @AuraEnabled public String I_DEST       {get;set;} // ? City Code
        @AuraEnabled public String I_WADAT      {get;set;} // ? Planned goods movement date

        @AuraEnabled public String I_WAUHR      {get;set;} // ? Time of Goods Issue (Local, Relating to a Plant)
        @AuraEnabled public String I_LFDAT      {get;set;} // ? Delivery Date
        @AuraEnabled public String I_LFUHR      {get;set;} // ? Time of delivery
        @AuraEnabled public String I_NOTE       {get;set;} // ? Long Text
        @AuraEnabled public String I_UNAME      {get;set;} // ? User Name
  
        @AuraEnabled public IF_DELIV_001_Req_I_USERINFO      I_USERINFO     {get;set;}
        @AuraEnabled public IF_DELIV_001_Req_I_ORG           I_ORG          {get;set;} 
        @AuraEnabled public List<IF_DELIV_001_Req_T_PARTNER> T_PARTNER      {get;set;} 
        @AuraEnabled public List<IF_DELIV_001_Req_T_ITEM>    T_ITEM         {get;set;} 
        @AuraEnabled public List<IF_DELIV_001_Req_T_DEL>     T_DEL          {get;set;} 
        @AuraEnabled public List<IF_DELIV_001_Req_T_TMP>     T_TMP          {get;set;} 
  
        public IF_DELIV_001_Req(
           IF_DELIV_001_Req_I_ORG           I_ORG       , 
           List<IF_DELIV_001_Req_T_PARTNER> T_PARTNER   , 
           List<IF_DELIV_001_Req_T_ITEM>    T_ITEM      , 
           List<IF_DELIV_001_Req_T_DEL>     T_DEL       , 
           List<IF_DELIV_001_Req_T_TMP>     T_TMP       , 
           String                          I_CHK       , 
           String                          I_VBELN     , 
           String                          I_CAPITAL_NO, 
           String                          I_DEST      , 
           String                          I_WADAT     , 
           String                          I_WAUHR     , 
           String                          I_LFDAT     , 
           String                          I_LFUHR     , 
           String                          I_NOTE      , 
           String                          I_UNAME      ){
             this.I_ORG        = I_ORG        ;
             this.T_PARTNER    = T_PARTNER    ;
             this.T_ITEM       = T_ITEM       ;
             this.T_DEL        = T_DEL        ;
             this.T_TMP        = T_TMP        ;
             this.I_CHK        = I_CHK        ;
             this.I_VBELN      = I_VBELN      ;
             this.I_CAPITAL_NO = I_CAPITAL_NO ;
             this.I_DEST       = I_DEST       ;
             this.I_WADAT      = I_WADAT      ;
             this.I_WAUHR      = I_WAUHR      ;
             this.I_LFDAT      = I_LFDAT      ;
             this.I_LFUHR      = I_LFUHR      ;
             this.I_NOTE       = I_NOTE       ;
             this.I_UNAME      = I_UNAME      ;
        }

        public IF_DELIV_001_Req(){
            this.I_ORG      = new IF_DELIV_001_Req_I_ORG();
            this.T_PARTNER  = new List<IF_DELIV_001_Req_T_PARTNER>();
            this.T_ITEM     = new List<IF_DELIV_001_Req_T_ITEM>();
            this.T_DEL      = new List<IF_DELIV_001_Req_T_DEL>();
            this.T_TMP      = new List<IF_DELIV_001_Req_T_TMP>();
            this.I_USERINFO = new IF_DELIV_001_Req_I_USERINFO();      
        }
      }
  
    public class IF_DELIV_001_Req_I_ORG { 
        public IF_DELIV_001_Req_I_ORG(){}
        public IF_DELIV_001_Req_I_ORG(
           String VKORG  , 
           String VTWEG  , 
           String SPART  , 
           String WERKS  , 
           String ARBPL  , 
           String AMSCCTL ){
             this.VKORG   = VKORG   ;
             this.VTWEG   = VTWEG   ;
             this.SPART   = SPART   ;
             this.WERKS   = WERKS   ;
             this.ARBPL   = ARBPL   ;
             this.AMSCCTL = AMSCCTL ;
        }
        @AuraEnabled public String VKORG   {get;set;} // ? Sales Organization
        @AuraEnabled public String VTWEG   {get;set;} // ? Distribution Channel
        @AuraEnabled public String SPART   {get;set;} // ? Division
        @AuraEnabled public String WERKS   {get;set;} // ? Plant
        @AuraEnabled public String ARBPL   {get;set;} // ? Work center
  
        @AuraEnabled public String AMSCCTL {get;set;} // ? M : MMI
    }
  
    public class IF_DELIV_001_Req_T_PARTNER {
        public IF_DELIV_001_Req_T_PARTNER(){} 
        public IF_DELIV_001_Req_T_PARTNER(
           String PARVW       , 
           String NAME1       , 
           String CITY1       , 
           String STREET      , 
           String POST_CODE1  , 
           String VTEXT       , 
           String READ        , 
           String KUNNR       , 
           String M_NAME1     , 
           String M_CITY1     , 
           String M_STREET    , 
           String M_POST_CODE1 ){
             this.PARVW        = PARVW        ;
             this.NAME1        = NAME1        ;
             this.CITY1        = CITY1        ;
             this.STREET       = STREET       ;
             this.POST_CODE1   = POST_CODE1   ;
             this.VTEXT        = VTEXT        ;
             this.READ         = READ         ;
             this.KUNNR        = KUNNR        ;
             this.M_NAME1      = M_NAME1      ;
             this.M_CITY1      = M_CITY1      ;
             this.M_STREET     = M_STREET     ;
             this.M_POST_CODE1 = M_POST_CODE1 ;
          }
        @AuraEnabled public String PARVW        {get;set;} // ? Partner Function
        @AuraEnabled public String NAME1        {get;set;} // ? Name 1
        @AuraEnabled public String CITY1        {get;set;} // ? City
        @AuraEnabled public String STREET       {get;set;} // ? Street
        @AuraEnabled public String POST_CODE1   {get;set;} // ? City postal code
  
        @AuraEnabled public String VTEXT        {get;set;} // ? Description
        @AuraEnabled public String READ         {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
        @AuraEnabled public String KUNNR        {get;set;} // ? Customer Number 1
        @AuraEnabled public String M_NAME1      {get;set;} // ? Name 1
        @AuraEnabled public String M_CITY1      {get;set;} // ? City
  
        @AuraEnabled public String M_STREET     {get;set;} // ? Street
        @AuraEnabled public String M_POST_CODE1 {get;set;} // ? City postal code
    }
  
    public class IF_DELIV_001_Req_T_ITEM { 
      public IF_DELIV_001_Req_T_ITEM(){}  
      public IF_DELIV_001_Req_T_ITEM(
           String POSNR , 
           String MATNR , 
           String KWMENG, 
           String VRKME  ){
             this.POSNR  = POSNR  ;
             this.MATNR  = MATNR  ;
             this.KWMENG = KWMENG ;
             this.VRKME  = VRKME  ;
        }
        @AuraEnabled public String POSNR {get;set;} // ? Sales Document Item
        @AuraEnabled public String MATNR {get;set;} // ? Material Number
        @AuraEnabled public String KWMENG {get;set;} // ? Cumulative Order Quantity in Sales Units
        @AuraEnabled public String VRKME {get;set;} // ? Sales unit
    }
  
    public class IF_DELIV_001_Req_T_DEL { 
        public IF_DELIV_001_Req_T_DEL(String DOCNO, String FILENAME){
             this.DOCNO    = DOCNO    ;
             this.FILENAME = FILENAME ;
        }
        @AuraEnabled public String DOCNO    {get;set;} // ? Document number
        @AuraEnabled public String FILENAME {get;set;} // ?                                                             
    }
  
    public class IF_DELIV_001_Req_T_TMP { 
      public IF_DELIV_001_Req_T_TMP(){}    
      public IF_DELIV_001_Req_T_TMP(
           String FILENAME , 
           String IF_DESC  , 
           String EVISEQX  , 
           String LINE     , 
           String FILE_SIZE ){
             this.FILENAME  = FILENAME  ;
             this.IF_DESC   = IF_DESC      ;
             this.EVISEQX   = EVISEQX   ;
             this.LINE      = LINE      ;
             this.FILE_SIZE = FILE_SIZE ;
          }
        @AuraEnabled public String FILENAME  {get;set;} // ? 
        @AuraEnabled public String IF_DESC   {get;set;} // ? 
        @AuraEnabled public String EVISEQX   {get;set;} // ? Sequence
        @AuraEnabled public String LINE      {get;set;} // ? Table analysis: For external table data up to length 1024
        @AuraEnabled public String FILE_SIZE {get;set;} // ? File Size
    }

    public class IF_DELIV_001_Req_I_USERINFO{
        @AuraEnabled public String BNAME {get;set;} // ? S/F CRM User ID 
        @AuraEnabled public String RNAME {get;set;} // ? User Name in User Master Record 
        @AuraEnabled public String HIER {get;set;} // ? [SS] User Hierrchy (Portal) 
        @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1 
        @AuraEnabled public String LIFNR {get;set;} // ? Account Number of Vendor or Creditor 
        @AuraEnabled public String VKORG {get;set;} // ? Sales Organization 
        @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel 
        @AuraEnabled public String SPART {get;set;} // ? Division 
        @AuraEnabled public String WERKS {get;set;} // ? Plant 
        @AuraEnabled public String ARBPL {get;set;} // ? Work center 
        @AuraEnabled public String PARNR {get;set;} // ? Partner 
        @AuraEnabled public String ENAME {get;set;} // ? Formatted Name of Employee or Applicant 
        @AuraEnabled public String KUNN2 {get;set;} // ? Customer Number 1 
        @AuraEnabled public String LAND1 {get;set;} // ? Country Key 
        @AuraEnabled public String LGORT {get;set;} // ? Storage Location 
        @AuraEnabled public String DF_CHK {get;set;} // ? Default Check 
        @AuraEnabled public String CO_CHK {get;set;} // ? corporation check       
    }
    
    public class IF_DELIV_001_Res { 
        @AuraEnabled public String O_VBELN   {get;set;} // ? Delivery
        @AuraEnabled public String O_DEL_MSG {get;set;} // ? Message Text
        @AuraEnabled public String O_UPD_MSG {get;set;} // ? Message Text
  
        @AuraEnabled public IF_DELIV_001_Res_O_RETURN       O_RETURN {get;set;} 
        @AuraEnabled public List<IF_DELIV_001_Res_T_RETURN> T_RETURN {get;set;} 
        public IF_DELIV_001_Res(){}
      }
  
      public class IF_DELIV_001_Res_O_RETURN { 
          public IF_DELIV_001_Res_O_RETURN(String TYPE, String CODE, String MESSAGE){
             this.TYPE    = TYPE    ;
             this.CODE    = CODE    ;
             this.MESSAGE = MESSAGE ;
          }
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        public IF_DELIV_001_Res_O_RETURN(){}
    }
  
    public class IF_DELIV_001_Res_T_RETURN { 
        public IF_DELIV_001_Res_T_RETURN(String TYPE, String CODE, String MESSAGE){
             this.TYPE    = TYPE    ;
             this.CODE    = CODE    ;
             this.MESSAGE = MESSAGE ;
        }
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        public IF_DELIV_001_Res_T_RETURN(){}
    }
 
    
/** IF-DELIV-004
    */  
    /**
         * Apex Class           : IF_ERP_DELIV
         * Wrapper Class        : IF_ERP_DELIV_Classes
         * Wrapper Name         : IF-
         * SFDC interface Id    : IF_DELIV_004
         * AS-IS RFC            : Z_SD_GOOD_ISSUE_INFO
         * New I/F              : ZCRM_SD_GOOD_ISSUE_INFO
         * Description          : 고객/딜러 내륙 운송 현황 및 정보 조회 - 배차 번호 운전수 연락처 도착예상시간 등 정보 조회
         * KeyValue             : X
         * NOT NULL             : X
     */            
    /** REQUEST 
      */
        public class IF_DELIV_004_Req { 
          public IF_DELIV_004_Req(){}
          @AuraEnabled public String I_VBELN {get;set;} // ? Sales Order Document
        }      
    
   /** RESPONSE 
    */    
      public class IF_DELIV_004_Res { 
        public IF_DELIV_004_Res(){}
        @AuraEnabled public IF_DELIV_004_Res_O_RETURN O_RETURN {get;set;} 
        @AuraEnabled public List<IF_DELIV_004_Res_T_OUTPUT> T_OUTPUT {get;set;} 
        }
  
      public class IF_DELIV_004_Res_O_RETURN { 
        public IF_DELIV_004_Res_O_RETURN(){}
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }
  
        public class IF_DELIV_004_Res_T_OUTPUT { 
          @AuraEnabled public String VBELN_R {get;set;} // ? S/O No
          @AuraEnabled public String MATNR_R {get;set;} // ? Material Number / 검색한 Sales order document에 있는 material
          @AuraEnabled public String SERNR {get;set;} // ? Serial number / 호기
          @AuraEnabled public String POSNR {get;set;} // ? S/O item
          @AuraEnabled public String ZSSRED {get;set;} // ? Sales shipping request date

          @AuraEnabled public String KUNNR_S {get;set;} // ? Sort-to-Party
          @AuraEnabled public String NAME1_S {get;set;} // ? Sort-to-Party name
          @AuraEnabled public String KUNNR_H {get;set;} // ? Ship-to-Party
          @AuraEnabled public String NAME1_H {get;set;} // ? Ship-to-Party name
          @AuraEnabled public String COUNTRY_1 {get;set;} // ? Ship-to-Party의 Country Key / 국가 (COUNTRY_S와 같은 값)

          @AuraEnabled public String CITY1 {get;set;} // ? 주소
          @AuraEnabled public String LZONE {get;set;} // ? Transportation zone / Port
          @AuraEnabled public String LZONE_T {get;set;} // ? LZONE Description / Port명
          @AuraEnabled public String B_CDATE {get;set;} // ? Booking Closing Date
          @AuraEnabled public String B_CTIME {get;set;} // ? Closing Time

          @AuraEnabled public String B_ETD {get;set;} // ? Booking ETD
          @AuraEnabled public String B_ETA {get;set;} // ? Booking ETA
          @AuraEnabled public String VBELN_V {get;set;} // ? Referenced Sales document (IHREZ) / 해당 SO생성시 참조한 문서
          @AuraEnabled public String MATNR_V {get;set;} // ? 계획오더의 Material / Referenced Sales document에 있는 material
          @AuraEnabled public String VBELN {get;set;} // ? Delivery Order

          @AuraEnabled public String ZFBOXSEQ {get;set;} // ? Box Seq.
          @AuraEnabled public String WADAT_IST {get;set;} // ? Actual Goods Movement Date // G/I Date
          @AuraEnabled public String VTWEG {get;set;} // ? Distribution Channel
          @AuraEnabled public String BZIRK {get;set;} // ? Sales district
          @AuraEnabled public String COUNTRY_2 {get;set;} // ? Sort-to-Party의 Country Key / 국가 

          @AuraEnabled public String COUNTRY_S {get;set;} // ? Ship-to-Party의 Country Key / 국가 (COUNTRY_1과 같은 값)
          @AuraEnabled public String COUNTRY_ST {get;set;} // ? Ship-to-Party의 Country Key Description
          @AuraEnabled public String INCO1 {get;set;} // ? Incoterms (Part 1)
          @AuraEnabled public String INCO2 {get;set;} // ? Incoterms (Part 2) / INCO1에 대한 추가적인 설명
          @AuraEnabled public String CARLC {get;set;} // ? Car License / 배차번호

          @AuraEnabled public String EXDRVR {get;set;} // ? Driver(Ext.) / 운전수
          @AuraEnabled public String HPNO {get;set;} // ? Mobile phone / 운전수 전화번호
          @AuraEnabled public String GIREQ_DT {get;set;} // ? GI Request Date / 요청출하일
          @AuraEnabled public String WERKS {get;set;} // ? Plant
          @AuraEnabled public String VERID {get;set;} // ? Production Version

          @AuraEnabled public String LGORT {get;set;} // ? Storage Location (S/Location)
          @AuraEnabled public String LGORT_REAL {get;set;} // ? Stock Storage Location (Stock S/Location)
          @AuraEnabled public String VGBEL {get;set;} // ? Sales Document
          @AuraEnabled public String VKBUR {get;set;} // ? Sales Office
          @AuraEnabled public String LAND1 {get;set;} // ? Country Key

          @AuraEnabled public String LTRMI {get;set;} // ? Actual delivery/finish date // G/R Date
          @AuraEnabled public String LGORT_1 {get;set;} // ? Storage Location (S.Location)
          @AuraEnabled public String WADAT {get;set;} // ? Del. Req. Date
          @AuraEnabled public String LFDAT {get;set;} // ? Del. Arr. Date
          @AuraEnabled public String LFUHR {get;set;} // ? Del. Arr. Time

          @AuraEnabled public String AUFNR {get;set;} // ? Order Number / Product Order
          @AuraEnabled public String ZINVNO {get;set;} // ? Invoice No
          @AuraEnabled public String TRANS_EXP {get;set;} // ? Transportation Expense
          @AuraEnabled public String ZFTRANSTP {get;set;} // ? Carriage Type
          @AuraEnabled public String ZFSETTLE {get;set;} // ? Charge Dicision element / Tonnage

          @AuraEnabled public String CARGO_DETAIL {get;set;} // ? 화물내역 Cargo Detail
          @AuraEnabled public String ZZAPPROVAL {get;set;} // ? Approval Status
          @AuraEnabled public String ZZAPPDT {get;set;} // ? Approval Date. 승인일자
          @AuraEnabled public String ZZAPPUSER {get;set;} // ? Approval User
          @AuraEnabled public String APP_NAME {get;set;} // ? Approval Name

          @AuraEnabled public String EMP_NAME {get;set;} // ? Issuer
          @AuraEnabled public String ZZISSUEDT {get;set;} // ? Departure Expected Date / Issue Date
          @AuraEnabled public String ZFBGNO {get;set;} // ? Booking Document No.
          @AuraEnabled public String ZFCDNM {get;set;} // ? CY Text
          @AuraEnabled public String ZZPRINT {get;set;} // ? GI Flag

          @AuraEnabled public String CL_DATE {get;set;} // ? Closing Date
          @AuraEnabled public String ETD  {get;set;} // ? ETD
          @AuraEnabled public String ZSPADDR {get;set;} // ? Ship-to Address
          @AuraEnabled public String TRANAG {get;set;} // ? Transportation Agent
          @AuraEnabled public String TRANAG_T {get;set;} // ? Transportation Agent Name

          @AuraEnabled public String ZSEQ {get;set;} // ? Serial Sequence No
          @AuraEnabled public String WBSTK {get;set;} // ? Total goods movement status
          @AuraEnabled public String VGPOS {get;set;} // ? Item number of the reference item
          @AuraEnabled public String VKORG {get;set;} // ? Sales Organization
          @AuraEnabled public String SPART {get;set;} // ? Division

          @AuraEnabled public String AUART {get;set;} // ? Sales Document Type
          @AuraEnabled public String ZZISSUER {get;set;} // ? Issuer
          @AuraEnabled public String LFART {get;set;} // ? Delivery Type
          @AuraEnabled public String ZZSTATUS {get;set;} // ? Approval Status
          @AuraEnabled public String ZSDFUNC {get;set;} // ? Sales Function

          @AuraEnabled public String ZZAPPNO {get;set;} // ? Strategic Material Approval Number
          @AuraEnabled public String ZZCOUNTRY {get;set;} // ? Country code
          @AuraEnabled public String ZZMACHIN {get;set;} // ? Machine No
          @AuraEnabled public String GLTRI {get;set;} // ? Actual finish date // G/R Date
          @AuraEnabled public String ERDAT {get;set;} // ? Delivery Created Date

          @AuraEnabled public String GI_FLAG {get;set;} // ? GI Flag
          @AuraEnabled public String ZSMS {get;set;} // ? SMS Log
        }

/** IF-DELIV-002
    */  
    /**
         * Apex Class           : IF_ERP_DELIV
         * Wrapper Class        : IF_ERP_DELIV_Classes
         * Wrapper Name         : IF-DELIV-002
         * SFDC interface Id    : IF_DELIV_002
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_SEARCH_DELIVERY_LIST
         * Description          : DO 전송 (ERP -> CRM) - DO ERP & CRM 데이터 동기화 (생성, 수정)
         * KeyValue             : X
         * NOT NULL             : X
     */            
     // FROM -> IF_FROM
    /** REQUEST 
      */
        public class IF_DELIV_002_Req { 
          @AuraEnabled public String I_AEDAT_FR {get;set;} // ? 수정일 FROM
          @AuraEnabled public String I_AEDAT_TO {get;set;} // ? 수정일 TO

          @AuraEnabled public IF_DELIV_002_Req_I_USERINFO I_USERINFO {get;set;} 
          @AuraEnabled public IF_DELIV_002_Req_I_ORG I_ORG {get;set;} 
          @AuraEnabled public List<IF_DELIV_002_Req_T_I_DELIVERY> T_I_DELIVERY {get;set;} 
          }

        public class IF_DELIV_002_Req_I_USERINFO { 
          @AuraEnabled public String BNAME  {get;set;} // ? S/F CRM User ID 
          @AuraEnabled public String RNAME  {get;set;} // ? User Name in User Master Record
          @AuraEnabled public String HIER   {get;set;} // ? [SS] User Hierrchy (Portal)
          @AuraEnabled public String KUNNR  {get;set;} // ? Customer Number 1
          @AuraEnabled public String LIFNR  {get;set;} // ? Account Number of Vendor or Creditor

          @AuraEnabled public String VKORG  {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG  {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART  {get;set;} // ? Division
          @AuraEnabled public String WERKS  {get;set;} // ? Plant
          @AuraEnabled public String ARBPL  {get;set;} // ? Work center

          @AuraEnabled public String PARNR  {get;set;} // ? Partner
          @AuraEnabled public String ENAME  {get;set;} // ? Formatted Name of Employee or Applicant
          @AuraEnabled public String KUNN2  {get;set;} // ? Customer Number 1
          @AuraEnabled public String LAND1  {get;set;} // ? Country Key
          @AuraEnabled public String LGORT  {get;set;} // ? Storage Location

          @AuraEnabled public String DF_CHK {get;set;} // ? Default Check
          @AuraEnabled public String CO_CHK {get;set;} // ? corporation check
        }

        public class IF_DELIV_002_Req_I_ORG { 
          @AuraEnabled public String VKORG   {get;set;} // ? Sales Organization
          @AuraEnabled public String VTWEG   {get;set;} // ? Distribution Channel
          @AuraEnabled public String SPART   {get;set;} // ? Division
          @AuraEnabled public String WERKS   {get;set;} // ? Plant
          @AuraEnabled public String ARBPL   {get;set;} // ? Work center

          @AuraEnabled public String AMSCCTL {get;set;} // ? M : MMI
        }

        public class IF_DELIV_002_Req_T_I_DELIVERY { 
          @AuraEnabled public String SIGN {get;set;} // ? Single-Character Indicator
          @AuraEnabled public String OPTION {get;set;} // ? Version Number Component
          @AuraEnabled public String LOW  {get;set;} // ? DO 입력 필드 : Delivery 
          @AuraEnabled public String HIGH {get;set;} // ? Character field length 24
        }


    /** RESPONSE 
      */
        public class IF_DELIV_002_Res { 

          @AuraEnabled public List<IF_DELIV_002_Res_T_MATERIAL> T_MATERIAL {get;set;} 
          @AuraEnabled public List<IF_DELIV_002_Res_T_PARTNER> T_PARTNER {get;set;} 
          @AuraEnabled public List<IF_DELIV_002_Res_T_DOC> T_DOC {get;set;} 
          @AuraEnabled public List<IF_DELIV_002_Res_T_ZCRMS0062> T_ZCRMS0062 {get;set;} 
          @AuraEnabled public List<IF_DELIV_002_Res_T_HEADER> T_HEADER {get;set;} 
          @AuraEnabled public List<IF_DELIV_002_Res_T_CREDIT> T_CREDIT {get;set;} 
          @AuraEnabled public List<IF_DELIV_002_Res_T_COND> T_COND {get;set;} 
          @AuraEnabled public List<IF_DELIV_002_Res_T_NOTE> T_NOTE {get;set;} 
          @AuraEnabled public List<IF_DELIV_002_Res_T_CHANGE> T_CHANGE {get;set;} 
          @AuraEnabled public List<IF_DELIV_002_Res_T_DELINFO> T_DELINFO {get;set;} 
          @AuraEnabled public IF_DELIV_002_Res_O_RETURN O_RETURN {get;set;} 
        }


        public class IF_DELIV_002_Res_T_MATERIAL { 
          @AuraEnabled public String VBELN     {get;set;} // ? Delivery
          @AuraEnabled public String POSNR     {get;set;} // ? Sales Document Item
          @AuraEnabled public String MATNR     {get;set;} // ? Material Number
          @AuraEnabled public String ABGRU     {get;set;} // ? Reason for rejection of quotations and sales orders
          @AuraEnabled public String VKAUS     {get;set;} // ? Usage Indicator

          @AuraEnabled public String NETWR     {get;set;} // ? Net value of the order item in document currency
          @AuraEnabled public String NETPR     {get;set;} // ? Net price
          @AuraEnabled public String WAERK     {get;set;} // ? SD Document Currency
          @AuraEnabled public String KWMENG    {get;set;} // ? Cumulative Order Quantity in Sales Units
          @AuraEnabled public String KBMENG    {get;set;} // ? Cumulative confirmed quantity in sales unit

          @AuraEnabled public String KLMENG    {get;set;} // ? Cumulative confirmed quantity in base unit
          @AuraEnabled public String VRKME     {get;set;} // ? Sales unit
          @AuraEnabled public String MEINS     {get;set;} // ? Base Unit of Measure
          @AuraEnabled public String WERKS     {get;set;} // ? Plant (Own or External)
          @AuraEnabled public String ROUTE     {get;set;} // ? Route

          @AuraEnabled public String ANZSN     {get;set;} // ? Number of serial numbers
          @AuraEnabled public String UPDATEFLAG {get;set;} // ? Update indicator
          @AuraEnabled public String KZWI1     {get;set;} // ? Subtotal 1 from pricing procedure for condition
          @AuraEnabled public String PSTYV     {get;set;} // ? Sales document item category
          @AuraEnabled public String REF_DOC   {get;set;} // ? Document number of the reference document

          @AuraEnabled public String REF_DOC_IT {get;set;} // ? Item number of the reference item
          @AuraEnabled public String REF_DOC_CA {get;set;} // ? Document category of preceding SD document
          @AuraEnabled public String POSEX     {get;set;} // ? Item Number of the Underlying Purchase Order
          @AuraEnabled public String MAKTX     {get;set;} // ? Material Description (Short Text)
          @AuraEnabled public String KDMAT     {get;set;} // ? Material Number Used by Customer

          @AuraEnabled public String VSTEL     {get;set;} // ? Shipping Point/Receiving Point
          @AuraEnabled public String ZZSQCOD   {get;set;} // ? SQ Code
          @AuraEnabled public String ZZSQTITLE {get;set;} // ? SQ Title
        }

        public class IF_DELIV_002_Res_T_PARTNER { 
          @AuraEnabled public String VBELN {get;set;} // ? Delivery
          @AuraEnabled public String PARVW {get;set;} // ? Partner Function
          @AuraEnabled public String NAME1 {get;set;} // ? Name 1
          @AuraEnabled public String CITY1 {get;set;} // ? City
          @AuraEnabled public String STREET {get;set;} // ? Street

          @AuraEnabled public String POST_CODE1 {get;set;} // ? City postal code
          @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
          @AuraEnabled public String ADRNR {get;set;} // ? Address
          @AuraEnabled public String VTEXT {get;set;} // ? Description
          @AuraEnabled public String READ {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
        }

        public class IF_DELIV_002_Res_T_DOC { 
          @AuraEnabled public String VBELV {get;set;} // ? SO
          @AuraEnabled public String VBELN {get;set;} // ? Delivery
          @AuraEnabled public String DOKNR {get;set;} // ? Document number
          @AuraEnabled public String FILENAME {get;set;} // ? File name
          @AuraEnabled public String MIMETYPE {get;set;} // ? MIMETYPE

          @AuraEnabled public String FILEDATA {get;set;} // ? File Data
          @AuraEnabled public String DESCRIPTION {get;set;} // ? Short description of the original
          @AuraEnabled public String FLAG  {get;set;} // ? Flag Code for Deletion
          @AuraEnabled public String DOCNO {get;set;} // ? Document number
        }

        public class IF_DELIV_002_Res_T_ZCRMS0062 { 
          @AuraEnabled public String VBELN   {get;set;} // ? Delivery
          @AuraEnabled public String WADAT   {get;set;} // ? Planned goods movement date
          @AuraEnabled public String WAUHR   {get;set;} // ? Time of Goods Issue (Local, Relating to a Plant)
          @AuraEnabled public String LFDAT   {get;set;} // ? Delivery Date
          @AuraEnabled public String LFUHR   {get;set;} // ? Time of delivery

          @AuraEnabled public String WADAT_IST {get;set;} // ? Actual Goods Movement Date / Actual GI Date
          @AuraEnabled public String ZZSTATUS {get;set;} // ? Approval Status
          @AuraEnabled public String ZFETD   {get;set;} // ? Departure Expected Date(ETD)
          @AuraEnabled public String ZFETA   {get;set;} // ? Arrival(ETA)
          @AuraEnabled public String ZFCSHCP {get;set;} // ? Shipping Company(Confirm)

          @AuraEnabled public String ZFCARNM {get;set;} // ? Vessel Name
          @AuraEnabled public String ZFPLDVLD {get;set;} // ? Place of Delivery Land
          @AuraEnabled public String ZFPLDVCD {get;set;} // ? Place of Delivery Port
          @AuraEnabled public String ZFPLDV   {get;set;} // ? Place of Delivery
        }

        public class IF_DELIV_002_Res_T_HEADER { 
          @AuraEnabled public String VBELN {get;set;} // ? Delivery
          @AuraEnabled public String ZTERM {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String TEXT1 {get;set;} // ? Own Explanation of Term of Payment
          @AuraEnabled public String T_EST_AMT {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String WAERK {get;set;} // ? SD Document Currency

          @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
          @AuraEnabled public String BEZEI {get;set;} // ? Name of the controlling area
          @AuraEnabled public String NAME1 {get;set;} // ? Name
          @AuraEnabled public String VDATU {get;set;} // ? Requested delivery date
        }

        public class IF_DELIV_002_Res_T_CREDIT { 
          @AuraEnabled public String VBELN {get;set;} // ? Delivery
          @AuraEnabled public String CREDIT_LIMIT {get;set;} // ? Credit Limit
          @AuraEnabled public String OPEN_SALES {get;set;} // ? Open Sales
          @AuraEnabled public String SALES_AMT {get;set;} // ? Sales Amt
          @AuraEnabled public String CREDIT {get;set;} // ? Credit

          @AuraEnabled public String WAERK {get;set;} // ? Waerk
        }

        public class IF_DELIV_002_Res_T_COND { 
          @AuraEnabled public String VBELN    {get;set;} // ? Sales Document
          @AuraEnabled public String CAPITAL_NO {get;set;} // ? Capital No.
          @AuraEnabled public String IF_FROM     {get;set;} // ? Departure Zone
          @AuraEnabled public String TO       {get;set;} // ? Destination Zone
          @AuraEnabled public String FROM_TXT {get;set;} // ? From Txt

          @AuraEnabled public String TO_TXT   {get;set;} // ? To Txt
          @AuraEnabled public String AUBEL    {get;set;} // ? Delivery
          @AuraEnabled public String VBELN_VA {get;set;} // ? CPO number(Customer Purchase Order)
        }

        public class IF_DELIV_002_Res_T_NOTE { 
          @AuraEnabled public String VBELN  {get;set;} // ? Delivery
          @AuraEnabled public String TDFORMAT {get;set;} // ? Tag column
          @AuraEnabled public String TDLINE {get;set;} // ? Long Text(Comment)
        }

        public class IF_DELIV_002_Res_T_CHANGE { 
          @AuraEnabled public String VBELN  {get;set;} // ? Delivery
          @AuraEnabled public String CHANGE {get;set;} // ? Change Flag('X','')
        }

        public class IF_DELIV_002_Res_T_DELINFO { 
          @AuraEnabled public String VBELN_VL {get;set;} // ? Delivery
          @AuraEnabled public String SRDATE {get;set;} // ? [DIV] 출하 요청일자
          @AuraEnabled public String ARDATE {get;set;} // ? [DIV] 도착 요청일자
          @AuraEnabled public String STTEXT {get;set;} // ? Delivery item text
        }

        public class IF_DELIV_002_Res_O_RETURN { 
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }







/** IF-DELIV-003
    */  
    /**
         * Apex Class           : IF_ERP_DELIV
         * Wrapper Class        : IF_ERP_DELIV_Classes
         * Wrapper Name         : IF-DELIV-003
         * SFDC interface Id    : IF_DELIV_003
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_GET_INCOMING_PLAN_LST
         * Description          : 선수금 입금 여부
         * KeyValue             : X
         * NOT NULL             : X
     */    
    /** REQUEST 
      */
        public class IF_DELIV_003_Req { 
          @AuraEnabled public String I_INCOMING   {get;set;} // ? Incoming Plan NO
          @AuraEnabled public String I_VBELN      {get;set;} // ? Sales Document
        }

    /** RESPONSE   
      */
        public class IF_DELIV_003_Res { 
          @AuraEnabled public IF_DELIV_003_Res_O_RETURN     O_RETURN {get;set;}
          @AuraEnabled public List<IF_DELIV_003_Res_T_LIST> T_LIST   {get;set;} 
        }

        public class IF_DELIV_003_Res_O_RETURN{
          @AuraEnabled public String TYPE {get;set;}
          @AuraEnabled public String CODE {get;set;}
          @AuraEnabled public String MESSAGE {get;set;}
        }

        public class IF_DELIV_003_Res_T_LIST { 
          @AuraEnabled public String ZZINCOM_NO {get;set;} // ? Incoming Plan NO
          @AuraEnabled public String ZZINCOM_VER {get;set;} // ? Incoming Plan Version
          @AuraEnabled public String INCOM_CODE {get;set;} // ? Incoming Plan Code
          @AuraEnabled public String SERIAL_NO {get;set;} // ? Sequence No
          @AuraEnabled public String ZTERM {get;set;} // ? Terms of Payment Key
          @AuraEnabled public String ZZTERM {get;set;} // ? Payment Terms(Extension)
          @AuraEnabled public String FA_CODE {get;set;} // ? Financial Agency Code
          @AuraEnabled public String EST_DAT {get;set;} // ? Est.Incoming Date
          @AuraEnabled public String EST_AMT {get;set;} // ? Est.Incoming AMT
          @AuraEnabled public String PRI_AMT {get;set;} // ? Principal AMT 
          @AuraEnabled public String NOTAX_INT_AMT {get;set;} // ? Interest AMT
          @AuraEnabled public String DOWN_REQ_NO {get;set;} // ? Downpayment Req.NO
          @AuraEnabled public String ZRESCHE {get;set;} // ? Rescheduling Flag
          @AuraEnabled public String WAERK {get;set;} // ? SD Document Currency
          @AuraEnabled public String BASE_DATE {get;set;} // ? Incoming Plan Base Date
          @AuraEnabled public String ZBD1T {get;set;} // ? Days
          @AuraEnabled public String FKDAT {get;set;} // ? Billing date for billing index and printout
          @AuraEnabled public String ZPARTIAL_BILLNO {get;set;} // ? Billing Document
          @AuraEnabled public String DPCL_AMT {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String EST_DAT_OLD {get;set;} // ? Old Est.Incoming Date
          @AuraEnabled public String ZCLASS {get;set;} // ? 변경구분 
          @AuraEnabled public String CLRAMT {get;set;} // ? Net Value in Document Currency
          @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
          @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
          @AuraEnabled public String ERZET {get;set;} // ? Entry time
          @AuraEnabled public String AEDAT {get;set;} // ? Changed On
          @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
          @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
        }






}