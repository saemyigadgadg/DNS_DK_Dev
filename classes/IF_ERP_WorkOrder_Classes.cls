public with sharing class IF_ERP_WorkOrder_Classes {
    public IF_ERP_WorkOrder_Classes() {}

    // SFDC interface Id    : IF-CSPLUS-004
    // AS-IS RFC            : Z_CS_MT_WORK_RESULT_CONFIRM
    // New I/F              : ZCRM_CS_MT_WORK_RESULT_CONFIRM       
    // Description          : 작업 내역 및 조치내역 조회/수정/삭제 
    public class IF_CSPLUS_004_Req{
        @AuraEnabled public String I_PARNR       {get;set;}
        @AuraEnabled public String I_FLAG        {get;set;}
        @AuraEnabled public IF_CSPLUS_004_Req_I_HEADER I_HEADER      {get;set;}

        public IF_CSPLUS_004_Req(){}
    }
    public class IF_CSPLUS_004_Req_I_HEADER{
        @AuraEnabled public String AUFNR        {get;set;}
        @AuraEnabled public String OTGRP        {get;set;}
        @AuraEnabled public String OTEIL        {get;set;}
        @AuraEnabled public String FEGRP        {get;set;}

        @AuraEnabled public String FECOD        {get;set;}
        @AuraEnabled public String FETXT        {get;set;}
        @AuraEnabled public String URGRP        {get;set;}
        @AuraEnabled public String URCOD        {get;set;}

        @AuraEnabled public String URTXT        {get;set;}
        @AuraEnabled public String MNGRP        {get;set;}
        @AuraEnabled public String MNCOD        {get;set;}
        @AuraEnabled public String MATXT        {get;set;}

        @AuraEnabled public String ISMNW_2      {get;set;}
        @AuraEnabled public String IEDD         {get;set;}
        @AuraEnabled public String IEDZ         {get;set;}
        @AuraEnabled public String LTXA1        {get;set;}

        @AuraEnabled public String GRUND        {get;set;}

        public IF_CSPLUS_004_Req_I_HEADER(){}
    }
    public class IF_CSPLUS_004_Res{
        @AuraEnabled public IF_CSPLUS_004_Res_O_RETURN O_RETURN {get;set;}
        @AuraEnabled public IF_CSPLUS_004_Res_T_O_LIST T_O_LIST {get;set;}

        public IF_CSPLUS_004_Res(){}
    }
    public class IF_CSPLUS_004_Res_O_RETURN{
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_CSPLUS_004_Res_O_RETURN(){}
    }
    public class IF_CSPLUS_004_Res_T_O_LIST{
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_CSPLUS_004_Res_T_O_LIST(){}
    }

    // SFDC interface Id    : IF-CSPLUS-034
    // AS-IS RFC            : ZSS_RECV_EP_SIMULATION
    // New I/F              : ZCRM_SS_RECV_EP_SIMULATION       
    // Description          : 메인작업자 변경 및 조치내역 업데이트 (관리자)
    public class IF_CSPLUS_034_Req{
        @AuraEnabled public String I_USERID                     {get;set;}
        @AuraEnabled public IF_CSPLUS_034_Req_I_ORG I_ORG       {get;set;}
        @AuraEnabled public String I_CUST_NO                    {get;set;}
        @AuraEnabled public String I_OTHERS                     {get;set;}

        @AuraEnabled public List<IF_CSPLUS_034_Req_IT_ITEM> IT_ITEM   {get;set;}

        public IF_CSPLUS_034_Req(){}
    }
    public class IF_CSPLUS_034_Req_I_ORG{
        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String WERKS        {get;set;}

        @AuraEnabled public String ARBPL        {get;set;}
        @AuraEnabled public String AMSCCTL      {get;set;}

        public IF_CSPLUS_034_Req_I_ORG(){}
    }
    public class IF_CSPLUS_034_Req_IT_ITEM{
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String KUNNR        {get;set;}

        public IF_CSPLUS_034_Req_IT_ITEM(){}
    }
    public class IF_CSPLUS_034_Res{
        @AuraEnabled public List<IF_CSPLUS_034_Res_ET_MAT> ET_MAT   {get;set;}
        @AuraEnabled public IF_CSPLUS_034_Res_ES_RETURN ES_RETURN   {get;set;}

        public IF_CSPLUS_034_Res(){}
    }
    public class IF_CSPLUS_034_Res_ET_MAT{
        @AuraEnabled public String MATNR    {get;set;}
        @AuraEnabled public String REPNR    {get;set;}
        @AuraEnabled public String MAKTX    {get;set;}
        @AuraEnabled public String KPEIN    {get;set;}
        
        @AuraEnabled public String KMEIN    {get;set;}
        @AuraEnabled public String KBETR    {get;set;}
        @AuraEnabled public String KONWA    {get;set;}
        @AuraEnabled public String CUQTY    {get;set;}
        
        @AuraEnabled public String NOTCD    {get;set;}
        @AuraEnabled public String AVQTY    {get;set;}
        @AuraEnabled public String NONMV    {get;set;}
        @AuraEnabled public String KUNNR    {get;set;}
        
        @AuraEnabled public String RATE     {get;set;}
        @AuraEnabled public String HSCODE   {get;set;}
        @AuraEnabled public String IGST     {get;set;}
        @AuraEnabled public String CGST     {get;set;}
        
        @AuraEnabled public String OTHER    {get;set;}
        @AuraEnabled public String SGST     {get;set;}
        @AuraEnabled public String NETPR    {get;set;}

        public IF_CSPLUS_034_Res_ET_MAT(){}
    }
    public class IF_CSPLUS_034_Res_ES_RETURN{
        @AuraEnabled public String TYPE         {get;set;}
        @AuraEnabled public String ID           {get;set;}
        @AuraEnabled public String IF_NUMBER    {get;set;}
        @AuraEnabled public String MESSAGE      {get;set;}
        
        @AuraEnabled public String LOG_NO       {get;set;}
        @AuraEnabled public String LOG_MSG_NO   {get;set;}
        @AuraEnabled public String MESSAGE_V1   {get;set;}
        @AuraEnabled public String MESSAGE_V2   {get;set;}

        @AuraEnabled public String MESSAGE_V3   {get;set;}
        @AuraEnabled public String MESSAGE_V4   {get;set;}
        @AuraEnabled public String PARAMETER    {get;set;}
        @AuraEnabled public String ROW          {get;set;}

        @AuraEnabled public String FIELD        {get;set;}
        @AuraEnabled public String IF_SYSTEM    {get;set;}

        public IF_CSPLUS_034_Res_ES_RETURN(){}        
    }

/** IF_CSPLUS_005
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF_CSPLUS_005
         * SFDC interface Id    : IF-CSPLUS-005
         * AS-IS RFC            : ZCS_RECV_PROC_EDU_SAVE	
         * New I/F              : ZCRM_CS_RECV_PROC_EDU_SAVE
         * Description          : 납품후 교육 관련 Ticket 및 WorkOrder 조회/수정/삭제 
         * KeyValue             : X
         * NOT NULL             : X
     */            
    /** REQUEST 
      */
      public class IF_CSPLUS_005_Req { 
        public IF_CSPLUS_005_Req(){
            this.T_I_LIST  = new List<IF_CSPLUS_005_Req_T_I_LIST>();
            this.T_I_LIST2 = new List<IF_CSPLUS_005_Req_T_I_LIST2>();
        }
        @AuraEnabled public String I_EQUNR {get;set;} // ? Equipment Number
        @AuraEnabled public String I_KTEXT {get;set;} // ? Description
        @AuraEnabled public String I_PERNR {get;set;} // ? Partner
        @AuraEnabled public String I_ILART {get;set;} // ? Maintenance activity type
        @AuraEnabled public String I_VAPLZ {get;set;} // ? Main work center for maintenance tasks
        @AuraEnabled public String I_AUFNR {get;set;} // ? Order Number
        @AuraEnabled public String I_MANAGER {get;set;} // ? Manager Name
        @AuraEnabled public String I_TELF1 {get;set;} // ? telephone number
        @AuraEnabled public String I_PSTLZ {get;set;} // ? Postal Code
        @AuraEnabled public String I_ADDR1 {get;set;} // ? Address 1
        @AuraEnabled public String I_ADDR2 {get;set;}  // ? Address 2
        @AuraEnabled public String I_GSTRP  {get;set;} // ? Basic start date 
        @AuraEnabled public String I_GLTRP  {get;set;} // ? Basic finish date
        @AuraEnabled public String I_SOLDTO {get;set;} // ? Account Number of Customer
        @AuraEnabled public String I_SWERKS     {get;set;}

  
        @AuraEnabled public List<IF_CSPLUS_005_Req_T_I_LIST> T_I_LIST {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_005_Req_T_I_LIST2> T_I_LIST2 {get;set;} 
  
      }
  
      public class IF_CSPLUS_005_Req_T_I_LIST {
        public IF_CSPLUS_005_Req_T_I_LIST(){}
        @AuraEnabled public String LINE {get;set;} // ? Long text
  
        }
  
      public class IF_CSPLUS_005_Req_T_I_LIST2 {
        public IF_CSPLUS_005_Req_T_I_LIST2(){}
        @AuraEnabled public String LINE {get;set;} // ? Long text
  
        }
      
    /** RESPONSE 
      */
      public class IF_CSPLUS_005_Res { 
        public IF_CSPLUS_005_Res(){}

        @AuraEnabled public String O_AUFNR {get;set;} // ? Order Number
  
        @AuraEnabled public IF_CSPLUS_005_Res_O_RETURN O_RETURN {get;set;} 
  
      }
  
      public class IF_CSPLUS_005_Res_O_RETURN { 
        public IF_CSPLUS_005_Res_O_RETURN(){}
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
  
      }

/** IF-CSPLUS-010
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-010
         * SFDC interface Id    : IF_CSPLUS_010
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_MT_AS_RECEIPT_SAVE				
         * Description          : WorkOrder정보 생성
     */     
    /** REQUEST 
      */      
        public class IF_CSPLUS_010_Req { 
          @AuraEnabled public String I_QMNUM {get;set;} // ? Notification No
          @AuraEnabled public String I_AUFNR {get;set;} // ? Order Number
          @AuraEnabled public String I_EQUNR {get;set;} // ? Equipment Number
          @AuraEnabled public String I_WARR_YN {get;set;} // ? Warranty type ('Y': Under warranty, 'N': Out of warra
          @AuraEnabled public String I_STATUS {get;set;} // ? System Status
          @AuraEnabled public String I_NEW_CLICK {get;set;} // ? New Create Flag('I':New create, 'C': Change)
          @AuraEnabled public String I_MAT_CLICK {get;set;} // ? Material Create Flag(Y)
          @AuraEnabled public String I_MAT_CONFIRM {get;set;} // ? Sales order creation flag(Y)
          @AuraEnabled public String I_SOLDTO {get;set;} // ? Customer Number 1
          @AuraEnabled public String I_SKIP_SBOM {get;set;} // ? Skip to check SBOM logic(X/'')
          @AuraEnabled public String I_SAFETY {get;set;} // ? Safety
          @AuraEnabled public String I_OUT_WARR {get;set;} // ? 'X' : Out warranty
          @AuraEnabled public String I_DIRECT {get;set;} // ? 'X' : Out warranty(Direct)
          @AuraEnabled public String I_TASKLIST {get;set;} // ? Key for Task List Group
          @AuraEnabled public String I_DOC_TYPE {get;set;} // ? Sales Document Type
          @AuraEnabled public String I_SERIES_CODE {get;set;} // ? Series Code
          @AuraEnabled public String I_SERIES_NAME {get;set;} // ? Series Name
          @AuraEnabled public String I_UNIT_CODE {get;set;} // ? UNIT Code
          @AuraEnabled public String I_UNIT_NAME {get;set;} // ? UNIT Name
          @AuraEnabled public String I_UNIT_SUB_CODE {get;set;} // ? 서비스 항목 Code
          @AuraEnabled public String I_UNIT_SUB_NAME {get;set;} // ? 서비스 항목 Name
          @AuraEnabled public String I_UNIT_SUB_DESC {get;set;} // ? 세부 작업 내용
          @AuraEnabled public String I_MANHOUR_VAL {get;set;} // ? 단수 또는 공수(H/M) 값 
          @AuraEnabled public String I_HUMAN_VAL {get;set;} // ? 인원 값 
          @AuraEnabled public String I_WORK_ITEM_CODE {get;set;} // ? 표준작업 항목 Code
          @AuraEnabled public String I_WORK_ITEM_NAME {get;set;} // ? 표준작업 항목 Name
          @AuraEnabled public String I_BILL_CATEGORY {get;set;} // ? 청구 구분 (Y/S)
          @AuraEnabled public String I_MANHOUR_USE_YN {get;set;} // ? 표준공수 사용 여부 (Y/N)
          @AuraEnabled public String I_LOEKZ {get;set;} // ? 표준공수 삭제 여부(삭제 : X)
          @AuraEnabled public String I_PART_OUT_WARR {get;set;} // ? 부품보증 / 'X' : Out warranty


          @AuraEnabled public IF_CSPLUS_010_Req_I_HEADER I_HEADER {get;set;} 
          @AuraEnabled public IF_CSPLUS_010_Req_I_HEADER2 I_HEADER2 {get;set;} 
          @AuraEnabled public List<IF_CSPLUS_010_Req_T_I_LIST> T_I_LIST {get;set;} 
          @AuraEnabled public List<IF_CSPLUS_010_Req_T_I_LIST2> T_I_LIST2 {get;set;} 
          @AuraEnabled public List<IF_CSPLUS_010_Req_T_I_PERNR> T_I_PERNR {get;set;} 
        }

        public class IF_CSPLUS_010_Req_I_HEADER { 
          @AuraEnabled public String QMCOD  {get;set;} // ? Coding
          @AuraEnabled public String WHR_YN  {get;set;} // P-Claim 입고처리 : Y / P - Claim : N
          @AuraEnabled public String OTGRP  {get;set;} // ? Code Group - Object Parts
          @AuraEnabled public String OTEIL  {get;set;} // ? Part of Object
          @AuraEnabled public String FEGRP  {get;set;} // ? Code Group - Problem
          @AuraEnabled public String FECOD  {get;set;} // ? Problem or Damage Code
          @AuraEnabled public String FETXT  {get;set;} // ? Notification Item Short Text
          @AuraEnabled public String TRBL_DT {get;set;} // ? Start of Malfunction (Date)
          @AuraEnabled public String TRBL_TM {get;set;} // ? Start of Malfunction (Time)
          @AuraEnabled public String RECV_DT {get;set;} // ? Date of Notification
          @AuraEnabled public String RECV_TM {get;set;} // ? Time of Notification
          @AuraEnabled public String LTRMN  {get;set;} // ? Required End Date
          @AuraEnabled public String LTRUR  {get;set;} // ? Requested End Time
          @AuraEnabled public String QMNAM  {get;set;} // ? Name of Person Reporting Notification
          @AuraEnabled public String ARBPL  {get;set;} // ? Work center
          @AuraEnabled public String DAUNO  {get;set;} // ? Normal duration of the activity
          @AuraEnabled public String S_DATE {get;set;} // ? Basic Start Date
          @AuraEnabled public String W_DETAIL {get;set;} // ? Operation short text
          @AuraEnabled public String INPUT_NO {get;set;} // ? Number of capacities required
          @AuraEnabled public String PERNR  {get;set;} // ? Partner
          @AuraEnabled public String TYPBZ  {get;set;} // ? Manufacturer model number
          @AuraEnabled public String SERNR  {get;set;} // ? Serial number
          @AuraEnabled public String REP_DEPT {get;set;} // ? Responsible Department
          @AuraEnabled public String SAFETY {get;set;} // ? SAFETY Y or N
        }

        public class IF_CSPLUS_010_Req_I_HEADER2 { 
          @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
          @AuraEnabled public String SEQNO {get;set;} // ? Sequential number
          @AuraEnabled public String NAME  {get;set;} // ? Name 1
          @AuraEnabled public String NAME1 {get;set;} // ? Name 1
          @AuraEnabled public String POST_CODE1 {get;set;} // ? City postal code
          @AuraEnabled public String CITY1 {get;set;} // ? City
          @AuraEnabled public String STREET {get;set;} // ? Street
          @AuraEnabled public String TEL_NUMBER {get;set;} // ? First telephone no.: dialling code+number
          @AuraEnabled public String TEL_NUMBER2 {get;set;} // ? First telephone no.: dialling code+number
          @AuraEnabled public String TEL_NUMBER3 {get;set;} // ? First telephone no.: dialling code+number
          @AuraEnabled public String DELT  {get;set;} // ? Delete flag(X)
          @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
          @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
          @AuraEnabled public String AEDAT {get;set;} // ? Changed On
          @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
        }

        public class IF_CSPLUS_010_Req_T_I_LIST { 
          @AuraEnabled public String MATNR {get;set;} // ? Material Number
          @AuraEnabled public String MENGE {get;set;} // ? Quantity
          @AuraEnabled public String SUPPLY_TP {get;set;} // ? Supply Type
          @AuraEnabled public String VENDOR {get;set;} // ? Account Number of Vendor or Creditor
          @AuraEnabled public String VSBED {get;set;} // ? Shipping Conditions
          @AuraEnabled public String RSNUM {get;set;} // ? Number of Reservation/Dependent Requirement
          @AuraEnabled public String RSPOS {get;set;} // ? Item Number of Reservation/Dependent Requirement
          @AuraEnabled public String MFLAG {get;set;} // ? Modify Flag
          @AuraEnabled public String RETURN_YN {get;set;} // ? Return Y or N
          @AuraEnabled public String POSNR {get;set;} // ? BOM item number
          @AuraEnabled public String SPIND {get;set;} // ? Spindle Type('R':Replacement, 'N':New)
        }

        public class IF_CSPLUS_010_Req_T_I_LIST2 { 
          @AuraEnabled public String TEXT {get;set;} // ? Text Line
        }

        public class IF_CSPLUS_010_Req_T_I_PERNR { 
          @AuraEnabled public String PERSNO {get;set;} // ? Personnel number
        }

    /** RESPONSE 
      */      
        public class IF_CSPLUS_010_Res { 
          @AuraEnabled public String O_AUFNR {get;set;} // ? Order Number
          @AuraEnabled public String O_QMNUM {get;set;} // ? Notification No
          @AuraEnabled public String O_RSNUM {get;set;} // ? Number of Reservation/Dependent Requirement

          @AuraEnabled public IF_CSPLUS_010_Res_O_RETURN O_RETURN {get;set;} 
          @AuraEnabled public List<IF_CSPLUS_010_Res_T_O_LIST> T_O_LIST {get;set;} 
        }

        public class IF_CSPLUS_010_Res_O_RETURN { 
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

        public class IF_CSPLUS_010_Res_T_O_LIST { 
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

/** IF-CSPLUS-015
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-015
         * SFDC interface Id    : IF_CSPLUS_015
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_MT_SUB_ENGINEER_SAVE				
         * Description          : 공동 작업자 생성
     */     
    /** REQUEST 
      */      
        public class IF_CSPLUS_015_Req { 
          @AuraEnabled public String I_AUFNR {get;set;} // ? Order Number
          @AuraEnabled public List<IF_CSPLUS_015_Req_T_I_LIST> T_I_LIST {get;set;} 
        }

        public class IF_CSPLUS_015_Req_T_I_LIST { 
          @AuraEnabled public String PERNR {get;set;} // ? Personnel number
        }

    /** RESPONSE 
      */      
        public class IF_CSPLUS_015_Res { 
          @AuraEnabled public IF_CSPLUS_015_Res_O_RETURN O_RETURN {get;set;} 
        }

        public class IF_CSPLUS_015_Res_O_RETURN { 
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

/** IF-CSPLUS-019
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF_CSPLUS_019
         * SFDC interface Id    : IF_CSPLUS_019
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_WORKWORDER_MANAGE				
         * Description          : Work Order 생성/수정/취소 - 신규 Work Order 생성 시 ERP로 데이터 전송
         * IF_CSPLUS_019_Res_ES_HEADER -> IF_CURRENCY
         * IF_CSPLUS_019_Res_ET_OPERATIONS -> IF_CURRENCY
     */     
    /** REQUEST 
      */      
      public class IF_CSPLUS_019_Req { 
        public IF_CSPLUS_019_Req(){
            this.T_I_LIST = new List<IF_CSPLUS_019_Req_T_I_LIST>(); 
        }
        @AuraEnabled public String I_AUFNR   {get;set;} // ? Order Number
        @AuraEnabled public String I_EQUNR   {get;set;} // ? Equipment Number
        @AuraEnabled public String I_PERNR   {get;set;} // ? Personnel number of the person who is responsible for the order/notification.
        @AuraEnabled public String I_ILART   {get;set;} // ? Maintenance activity type
        @AuraEnabled public String I_KTEXT   {get;set;} // ? Short description of the order (language-independent).
        @AuraEnabled public String I_DOC_TYPE {get;set;} // ? Order Document Type
        @AuraEnabled public String I_LTXA1   {get;set;} // ? Describes the operation or sub-operation.
        @AuraEnabled public String I_ARBEI   {get;set;} // ? Work involved in the activity
        @AuraEnabled public String I_ANZZL   {get;set;} // ? Number of capacities required
        @AuraEnabled public String I_F_PERNR {get;set;} // ? Personnel number of the person to whom the confirmed data relates.
        @AuraEnabled public String I_SOLD_TO {get;set;} // ? SOLD TO PARTY NUMBER
        @AuraEnabled public List<IF_CSPLUS_019_Req_T_I_LIST> T_I_LIST {get;set;} 
      }
  
      public class IF_CSPLUS_019_Req_T_I_LIST { 
        public IF_CSPLUS_019_Req_T_I_LIST(){}
        @AuraEnabled public String AUFNR {get;set;} // ? Order Number
        @AuraEnabled public String PERNR {get;set;} // ? Personnel number
        @AuraEnabled public String MSDD  {get;set;} // ? Moving start date
        @AuraEnabled public String MSDZ  {get;set;} // ? Moving start time
        @AuraEnabled public String ISDD  {get;set;} // ? Confirmed date for start of execution
        @AuraEnabled public String ISDZ  {get;set;} // ? Confirmed time for 'Execution start'
        @AuraEnabled public String IEDD  {get;set;} // ? Confirmed date for execution finish
        @AuraEnabled public String IEDZ  {get;set;} // ? Confirmed time for 'Execution finish'
        @AuraEnabled public String LTXA1 {get;set;} // ? Active Text
  
        }
  
  
    /** RESPONSE 
      */              
      public class IF_CSPLUS_019_Res { 
        public IF_CSPLUS_019_Res(){
                this.O_RETURN = new IF_CSPLUS_019_Res_O_RETURN();
                this.ES_HEADER = new IF_CSPLUS_019_Res_ES_HEADER();
                this.ES_SRVDATA = new IF_CSPLUS_019_Res_ES_SRVDATA();            
                this.ET_PARTNER = new List<IF_CSPLUS_019_Res_ET_PARTNER>();
                this.ET_OPERATIONS = new List<IF_CSPLUS_019_Res_ET_OPERATIONS>();
                this.T_O_LIST = new List<IF_CSPLUS_019_Res_T_O_LIST>();             
        }
        @AuraEnabled public String O_AUFNR                                      {get;set;}
        @AuraEnabled public IF_CSPLUS_019_Res_O_RETURN            O_RETURN      {get;set;} 
        @AuraEnabled public IF_CSPLUS_019_Res_ES_HEADER           ES_HEADER     {get;set;} 
        @AuraEnabled public IF_CSPLUS_019_Res_ES_SRVDATA          ES_SRVDATA    {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_019_Res_ET_PARTNER>    ET_PARTNER    {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_019_Res_ET_OPERATIONS> ET_OPERATIONS {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_019_Res_T_O_LIST>      T_O_LIST      {get;set;} 
        }
  
      public class IF_CSPLUS_019_Res_O_RETURN { 
        public IF_CSPLUS_019_Res_O_RETURN(){}
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
  
        }
  
      public class IF_CSPLUS_019_Res_ES_HEADER { 
        public IF_CSPLUS_019_Res_ES_HEADER(){}
        @AuraEnabled public String ORDERID {get;set;} // ? Order Number
        @AuraEnabled public String ORDER_TYPE {get;set;} // ? Order Type
        @AuraEnabled public String PLANPLANT {get;set;} // ? Maintenance Planning Plant
        @AuraEnabled public String BUS_AREA {get;set;} // ? Business Area
        @AuraEnabled public String MN_WK_CTR {get;set;} // ? Main work center for maintenance tasks
        @AuraEnabled public String PLANT {get;set;} // ? Plant associated with main work center
        @AuraEnabled public String MN_WKCTR_ID {get;set;} // ? Object ID of the Work Center
        @AuraEnabled public String PMACTTYPE {get;set;} // ? Maintenance activity type
        @AuraEnabled public String PLANGROUP {get;set;} // ? Planner Group for Customer Service and Plant Maintenance
        @AuraEnabled public String SYSTCOND {get;set;} // ? Syst.Condition
        @AuraEnabled public String FUNCT_LOC {get;set;} // ? Functional Location
        @AuraEnabled public String EQUIPMENT {get;set;} // ? Equipment Number
        @AuraEnabled public String SERIALNO {get;set;} // ? Serial number
        @AuraEnabled public String MATERIAL {get;set;} // ? Material Number
        @AuraEnabled public String ASSEMBLY {get;set;} // ? Assembly
        @AuraEnabled public String DEVICEDATA {get;set;} // ? Additional Device Data
        @AuraEnabled public String MAINTPLANT {get;set;} // ? Maintenance plant
        @AuraEnabled public String LOCATION {get;set;} // ? Asset location
        @AuraEnabled public String MAINTROOM {get;set;} // ? Room
        @AuraEnabled public String PLSECTN {get;set;} // ? Plant section
        @AuraEnabled public String LOC_WK_CTR {get;set;} // ? Work center
        @AuraEnabled public String LOC_WKCTR_ID {get;set;} // ? Object ID of PP work center
        @AuraEnabled public String ABCINDIC {get;set;} // ? ABC indicator for technical object
        @AuraEnabled public String SORTFIELD {get;set;} // ? Sort field
        @AuraEnabled public String COMP_CODE {get;set;} // ? Company Code
        @AuraEnabled public String PROFIT_CTR {get;set;} // ? Profit Center
        @AuraEnabled public String CO_AREA {get;set;} // ? Controlling Area
        @AuraEnabled public String RESPCCTR {get;set;} // ? Responsible cost center
        @AuraEnabled public String FUNC_AREA {get;set;} // ? Functional Area
        @AuraEnabled public String SUPERIOR_NETWORK {get;set;} // ? Number of superior network
        @AuraEnabled public String SUPERIOR_ACTIVITY {get;set;} // ? Activity number in network and standard network
        @AuraEnabled public String SUPERIOR_ROUTING_NO {get;set;} // ? Routing number of operations in the order
        @AuraEnabled public String SUPERIOR_COUNTER {get;set;} // ? General counter for order
        @AuraEnabled public String WBS_ELEM {get;set;} // ? Work Breakdown Structure Element (WBS Element)
        @AuraEnabled public String PROJ_DEF {get;set;} // ? Project definition
        @AuraEnabled public String PROCESSING_GROUP {get;set;} // ? Processing group
        @AuraEnabled public String OBJECTCLASS {get;set;} // ? Object Class
        @AuraEnabled public String TAXJURCODE {get;set;} // ? Tax Jurisdiction
        @AuraEnabled public String LOC_COMP_CODE {get;set;} // ? Company Code
        @AuraEnabled public String LOC_CO_AREA {get;set;} // ? Controlling Area
        @AuraEnabled public String ASSET_NO {get;set;} // ? Main Asset Number
        @AuraEnabled public String SUB_NUMBER {get;set;} // ? Asset Subnumber
        @AuraEnabled public String LOC_BUS_AREA {get;set;} // ? Business Area
        @AuraEnabled public String COSTCENTER {get;set;} // ? Cost Center
        @AuraEnabled public String LOC_WBS_ELEM {get;set;} // ? Work Breakdown Structure Element (WBS Element)
        @AuraEnabled public String STANDORDER {get;set;} // ? Standing order number
        @AuraEnabled public String SETTLORDER {get;set;} // ? Settlement order
        @AuraEnabled public String SALESORG {get;set;} // ? Sales Organization
        @AuraEnabled public String DISTR_CHAN {get;set;} // ? Distribution Channel
        @AuraEnabled public String DIVISION {get;set;} // ? Division
        @AuraEnabled public String ORDPLANID {get;set;} // ? Maintenance order planning indicator
        @AuraEnabled public String START_DATE {get;set;} // ? Basic start date
        @AuraEnabled public String FINISH_DATE {get;set;} // ? Basic finish date
        @AuraEnabled public String BASICSTART {get;set;} // ? Basic start time
        @AuraEnabled public String BASIC_FIN {get;set;} // ? Basic finish (time)
        @AuraEnabled public String PRIORITY {get;set;} // ? Priority
        @AuraEnabled public String REVISION {get;set;} // ? Revision for Plant Maintenance and Customer Service
        @AuraEnabled public String VERSION {get;set;} // ? Version of Available Capacity
        @AuraEnabled public String SCHED_TYPE {get;set;} // ? Scheduling type
        @AuraEnabled public String AUTOSCHED {get;set;} // ? Indicator: Schedule automatically
        @AuraEnabled public String CAP_REQMTS {get;set;} // ? Indicator: Calculate capacity requirements
        @AuraEnabled public String SCHEDULING_EXACT_BREAK_TIMES {get;set;} // ? Indicator:  Scheduling allowing for breaks
        @AuraEnabled public String MRP_RELEVANT {get;set;} // ? Reservation Relevance/Generation of Purchase Requisition
        @AuraEnabled public String PRODUCTION_START_DATE {get;set;} // ? Scheduled start
        @AuraEnabled public String PRODUCTION_FINISH_DATE {get;set;} // ? Scheduled finish
        @AuraEnabled public String PRODUCTION_START_TIME {get;set;} // ? Scheduled start time
        @AuraEnabled public String PRODUCTION_FINISH_TIME {get;set;} // ? Scheduled finish time
        @AuraEnabled public String ACTUAL_START_DATE {get;set;} // ? Actual start date
        @AuraEnabled public String ACTUAL_FINISH_DATE {get;set;} // ? Confirmed Order Finish Date
        @AuraEnabled public String ACTUAL_START_TIME {get;set;} // ? Actual start time
        @AuraEnabled public String ACTUAL_FINISH_TIME {get;set;} // ? Confirmed order finish (time)
        @AuraEnabled public String REFDATE {get;set;} // ? PM Order: Reference Date
        @AuraEnabled public String SALES_ORD {get;set;} // ? Sales Order Number
        @AuraEnabled public String S_ORD_ITEM {get;set;} // ? Item Number in Sales Order
        @AuraEnabled public String CALC_MOTIVE {get;set;} // ? Accounting Indicator
        @AuraEnabled public String INVEST_PROFILE {get;set;} // ? Investment measure profile
        @AuraEnabled public String SCALE {get;set;} // ? Scale of investment objects
        @AuraEnabled public String INV_REASON {get;set;} // ? Reason for investment
        @AuraEnabled public String ENVIR_INVEST {get;set;} // ? Reason for environmental investment
        @AuraEnabled public String ESTIMATED_COSTS {get;set;} // ? Estimated total costs of order
        @AuraEnabled public String IF_CURRENCY {get;set;} // ? Order Currency
        @AuraEnabled public String CURRENCY_ISO {get;set;} // ? ISO currency code
        @AuraEnabled public String CSTG_SHEET {get;set;} // ? Costing Sheet
        @AuraEnabled public String OVERHEAD_KEY {get;set;} // ? Overhead key
        @AuraEnabled public String RES_ANAL_KEY {get;set;} // ? Results Analysis Key
        @AuraEnabled public String NETWORK_PROFILE {get;set;} // ? Network profile
        @AuraEnabled public String CSTGVAPPLN {get;set;} // ? Costing variant for planned costs
        @AuraEnabled public String CSTGVARACT {get;set;} // ? Costing variant for actual costs
        @AuraEnabled public String TASK_LIST_GROUP {get;set;} // ? Key for Task List Group
        @AuraEnabled public String GROUP_COUNTER {get;set;} // ? Group Counter
        @AuraEnabled public String TASK_LIST_TYPE {get;set;} // ? Task List Type
        @AuraEnabled public String RESP_PLANNER_GROUP {get;set;} // ? Responsible planner group/department
        @AuraEnabled public String MNTPLAN {get;set;} // ? Maintenance Plan
        @AuraEnabled public String MAINTITEM {get;set;} // ? Maintenance item
        @AuraEnabled public String CALL_NO {get;set;} // ? Maintenance Plan Call Number
        @AuraEnabled public String LAST_ORD {get;set;} // ? Order number
        @AuraEnabled public String ENTERED_BY {get;set;} // ? Entered by
        @AuraEnabled public String ENTER_DATE {get;set;} // ? Created on
        @AuraEnabled public String CHANGED_BY {get;set;} // ? Last changed by
        @AuraEnabled public String CHANGE_DATE {get;set;} // ? Change date for Order Master
        @AuraEnabled public String SCENARIO {get;set;} // ? Scenario or Subscreen Category
        @AuraEnabled public String SYS_STATUS {get;set;} // ? System Status
        @AuraEnabled public String USER_ST {get;set;} // ? User status active
        @AuraEnabled public String USERSTATUS {get;set;} // ? Field displaying user status
        @AuraEnabled public String STAT_PROF {get;set;} // ? Status Profile
        @AuraEnabled public String OBJECT_NO {get;set;} // ? Object number
        @AuraEnabled public String ROUTING_NO {get;set;} // ? Routing number of operations in the order
        @AuraEnabled public String RESERV_NO {get;set;} // ? Number of Reservation/Dependent Requirement
        @AuraEnabled public String SHORT_TEXT {get;set;} // ? Description
        @AuraEnabled public String LONG_TEXT {get;set;} // ? Long text exists
        @AuraEnabled public String NOTIF_NO {get;set;} // ? Notification No
        @AuraEnabled public String ASSEMBLY_EXTERNAL {get;set;} // ? Long Material Number for Field ASSEMBLY
        @AuraEnabled public String ASSEMBLY_GUID {get;set;} // ? External GUID for ASSEMBLY Field
        @AuraEnabled public String ASSEMBLY_VERSION {get;set;} // ? Version Number for ASSEMBLY Field
        @AuraEnabled public String MATERIAL_EXTERNAL {get;set;} // ? Long Material Number for MATERIAL Field
        @AuraEnabled public String MATERIAL_GUID {get;set;} // ? External GUID for MATERIAL Field
        @AuraEnabled public String MATERIAL_VERSION {get;set;} // ? Version Number for MATERIAL Field
        @AuraEnabled public String CALID {get;set;} // ? Factory Calendar
        @AuraEnabled public String KALSN {get;set;} // ? Calendar Selection for Order
  
        }
  
      public class IF_CSPLUS_019_Res_ES_SRVDATA { 
        public IF_CSPLUS_019_Res_ES_SRVDATA(){}
        @AuraEnabled public String OBJECT_NO        {get;set;} // ? Object number
        @AuraEnabled public String SALESORG         {get;set;} // ? Sales Organization
        @AuraEnabled public String DISTR_CHAN       {get;set;} // ? Distribution Channel
        @AuraEnabled public String DIVISION         {get;set;} // ? Division
        @AuraEnabled public String SALES_GRP        {get;set;} // ? Sales Group
        @AuraEnabled public String SALES_OFF        {get;set;} // ? Sales Office
        @AuraEnabled public String PURCH_NO_C       {get;set;} // ? Customer purchase order number
        @AuraEnabled public String PURCH_DATE       {get;set;} // ? Customer purchase order date
        @AuraEnabled public String MATERIAL         {get;set;} // ? Service product
        @AuraEnabled public String QUANTITY         {get;set;} // ? Service product quantity
        @AuraEnabled public String BASE_UOM         {get;set;} // ? Base Unit of Measure
        @AuraEnabled public String BASE_UOM_ISO     {get;set;} // ? ISO code for unit of measurement
        @AuraEnabled public String CONFIGURATION    {get;set;} // ? Configuration
        @AuraEnabled public String DLI_PROFILE      {get;set;} // ? Dynamic Item Processor Profile
        @AuraEnabled public String BILLING_FORM     {get;set;} // ? Billing form
        @AuraEnabled public String MATERIAL_EXTERNAL {get;set;} // ? Long Material Number for MATERIAL Field
        @AuraEnabled public String MATERIAL_GUID    {get;set;} // ? External GUID for MATERIAL Field
        @AuraEnabled public String MATERIAL_VERSION {get;set;} // ? Version Number for MATERIAL Field
  
        }
  
      public class IF_CSPLUS_019_Res_ET_PARTNER { 
        public IF_CSPLUS_019_Res_ET_PARTNER(){}
        
        @AuraEnabled public String PARTN_ROLE  {get;set;} // ? Partner Function
        @AuraEnabled public String PARTN_ROLE_OLD {get;set;} // ? Partner Function
        @AuraEnabled public String PARTNER     {get;set;} // ? Partner
        @AuraEnabled public String PARTNER_OLD {get;set;} // ? Partner
        }
  
      public class IF_CSPLUS_019_Res_ET_OPERATIONS { 
        public IF_CSPLUS_019_Res_ET_OPERATIONS(){}

        @AuraEnabled public String ACTIVITY         {get;set;} // ? Operation/Activity Number
        @AuraEnabled public String SUB_ACTIVITY     {get;set;} // ? Suboperation
        @AuraEnabled public String CONTROL_KEY      {get;set;} // ? Control key
        @AuraEnabled public String WORK_CNTR        {get;set;} // ? Work center
        @AuraEnabled public String PLANT            {get;set;} // ? Plant
        @AuraEnabled public String STANDARD_TEXT_KEY {get;set;} // ? Standard text key
        @AuraEnabled public String DESCRIPTION      {get;set;} // ? Operation short text
        @AuraEnabled public String LANGU            {get;set;} // ? Language Key
        @AuraEnabled public String LANGU_ISO        {get;set;} // ? Language according to ISO 639
        @AuraEnabled public String NO_OF_TIME_TICKETS {get;set;} // ? Number of Time Tickets
        @AuraEnabled public String WAGETYPE         {get;set;} // ? Wage Type
        @AuraEnabled public String SUITABILITY      {get;set;} // ? Suitability
        @AuraEnabled public String WAGEGROUP        {get;set;} // ? Wage group
        @AuraEnabled public String SORT_FLD         {get;set;} // ? Sort field
        @AuraEnabled public String VENDOR_NO        {get;set;} // ? Account Number of Vendor or Creditor
        @AuraEnabled public String QUANTITY         {get;set;} // ? Operation quantity in order unit of measure
        @AuraEnabled public String BASE_UOM         {get;set;} // ? Base Unit of Measure
        @AuraEnabled public String BASE_UOM_ISO     {get;set;} // ? ISO code for unit of measurement
        @AuraEnabled public String PRICE            {get;set;} // ? Price
        @AuraEnabled public String PRICE_UNIT       {get;set;} // ? Price Unit
        @AuraEnabled public String COST_ELEMENT     {get;set;} // ? Cost Element
        @AuraEnabled public String IF_CURRENCY         {get;set;} // ? Currency Key
        @AuraEnabled public String CURRENCY_ISO     {get;set;} // ? ISO currency code
        @AuraEnabled public String INFO_REC         {get;set;} // ? Number of Purchasing Info Record
        @AuraEnabled public String PURCH_ORG        {get;set;} // ? Purchasing Organization
        @AuraEnabled public String PUR_GROUP        {get;set;} // ? Purchasing group for external processing
        @AuraEnabled public String MATL_GROUP       {get;set;} // ? Material Group
        @AuraEnabled public String AGREEMENT        {get;set;} // ? Number of Principal Purchase Agreement
        @AuraEnabled public String AGMT_ITEM        {get;set;} // ? Item Number of Principal Purchase Agreement
        @AuraEnabled public String PREQ_NAME        {get;set;} // ? Name of Requisitioner/Requester
        @AuraEnabled public String TRACKINGNO       {get;set;} // ? Requirement Tracking Number
        @AuraEnabled public String NUMBER_OF_CAPACITIES {get;set;} // ? Number of capacities required
        @AuraEnabled public String PERCENT_OF_WORK  {get;set;} // ? Work percentage
        @AuraEnabled public String CALC_KEY         {get;set;} // ? Key for calculation
        @AuraEnabled public String ACTTYPE          {get;set;} // ? Activity Type
        @AuraEnabled public String SYSTCOND         {get;set;} // ? Syst.Condition
        @AuraEnabled public String ASSEMBLY         {get;set;} // ? Assembly
        @AuraEnabled public String INT_DISTR        {get;set;} // ? Distr.cap.reqmts (plant maint.,process order, network)
        @AuraEnabled public String GR_RCPT          {get;set;} // ? Goods Recipient/Ship-To Party
        @AuraEnabled public String UNLOAD_PT        {get;set;} // ? Unloading Point
        @AuraEnabled public String PERS_NO          {get;set;} // ? Personnel number
        @AuraEnabled public String FW_ORDER         {get;set;} // ? Framework Order
        @AuraEnabled public String ORDER_ITEM       {get;set;} // ? Item of framework order
        @AuraEnabled public String PLND_DELRY       {get;set;} // ? Planned Delivery Time in Days
        @AuraEnabled public String DURATION_NORMAL  {get;set;} // ? Normal duration of the activity
        @AuraEnabled public String DURATION_NORMAL_UNIT {get;set;} // ? Normal duration/unit
        @AuraEnabled public String DURATION_NORMAL_UNIT_ISO {get;set;} // ? ISO code for unit of measurement
        @AuraEnabled public String CONSTRAINT_TYPE_START {get;set;} // ? Constraint on the basic start date for the activity
        @AuraEnabled public String CONSTRAINT_TYPE_FINISH {get;set;} // ? Constraint on the finish date of the activity
        @AuraEnabled public String WORK_ACTIVITY    {get;set;} // ? Work involved in the activity
        @AuraEnabled public String UN_WORK          {get;set;} // ? Unit for work
        @AuraEnabled public String UN_WORK_ISO      {get;set;} // ? ISO code for unit of measurement
        @AuraEnabled public String START_CONS       {get;set;} // ? Constraint for activity start (Basic)
        @AuraEnabled public String STRTTIMCON       {get;set;} // ? Constraint for activity start time (Basic)
        @AuraEnabled public String FIN_CONSTR       {get;set;} // ? Constraint for finish of activity (Basic)
        @AuraEnabled public String FINTIMCONS       {get;set;} // ? Basic finish time of the activity
        @AuraEnabled public String EXECFACTOR       {get;set;} // ? Execution Factor
        @AuraEnabled public String MRP_RELEVANT     {get;set;} // ? Reservation Relevance/Generation of Purchase Requisition
        @AuraEnabled public String FIELD_KEY        {get;set;} // ? Key word ID for user-defined fields
        @AuraEnabled public String USR00            {get;set;} // ? User field with 20 characters
        @AuraEnabled public String USR01            {get;set;} // ? User field with 20 characters
        @AuraEnabled public String USR02            {get;set;} // ? User field with 10 characters
        @AuraEnabled public String USR03            {get;set;} // ? User field with 10 characters
        @AuraEnabled public String USR04            {get;set;} // ? User field for quantity (length 10.3)
        @AuraEnabled public String USE04            {get;set;} // ? User field: Unit for quantity fields
        @AuraEnabled public String USE04_ISO        {get;set;} // ? ISO code for unit of measurement
        @AuraEnabled public String USR05            {get;set;} // ? User field for quantity (length 10.3)
        @AuraEnabled public String USE05            {get;set;} // ? User field: Unit for quantity fields
        @AuraEnabled public String USE05_ISO        {get;set;} // ? ISO code for unit of measurement
        @AuraEnabled public String USR06            {get;set;} // ? User-defined field for values (length 10,3)
        @AuraEnabled public String USE06            {get;set;} // ? User field: Unit for value fields
        @AuraEnabled public String USE06_ISO        {get;set;} // ? ISO currency code
        @AuraEnabled public String USR07            {get;set;} // ? User-defined field for values (length 10,3)
        @AuraEnabled public String USE07            {get;set;} // ? User field: Unit for value fields
        @AuraEnabled public String USE07_ISO        {get;set;} // ? ISO currency code
        @AuraEnabled public String USR08            {get;set;} // ? User field for date
        @AuraEnabled public String USR09            {get;set;} // ? User field for date
        @AuraEnabled public String USR10            {get;set;} // ? User-defined field: Indicator for reports
        @AuraEnabled public String USR11            {get;set;} // ? User-defined field: Indicator for reports
        @AuraEnabled public String CONF_NO          {get;set;} // ? Completion confirmation number for the operation
        @AuraEnabled public String PREQ_NO          {get;set;} // ? Purchase requisition number
        @AuraEnabled public String PREQ_ITEM        {get;set;} // ? Item number of the purchase requisition in the order
        @AuraEnabled public String COMPLETE         {get;set;} // ? Indicator: No Remaining Work Expected
        @AuraEnabled public String WORK_ACTUAL      {get;set;} // ? Actual work
        @AuraEnabled public String EARL_SCHED_START_DATE {get;set;} // ? Earliest scheduled start: Execution (date)
        @AuraEnabled public String EARL_SCHED_START_TIME {get;set;} // ? Earliest scheduled start: Execution (time)
        @AuraEnabled public String EARL_SCHED_FIN_DATE {get;set;} // ? Earliest scheduled finish: Execution (date)
        @AuraEnabled public String EARL_SCHED_FIN_TIME {get;set;} // ? Earliest scheduled finish: Execution (time)
        @AuraEnabled public String LATE_SCHED_START_DATE {get;set;} // ? Latest scheduled start: Execution (date)
        @AuraEnabled public String LATE_SCHED_START_TIME {get;set;} // ? Latest scheduled start: Execution (time)
        @AuraEnabled public String LATE_SCHED_FIN_DATE {get;set;} // ? Latest scheduled finish: Execution (date)
        @AuraEnabled public String LATE_SCHED_FIN_TIME {get;set;} // ? Latest scheduled finish: Execution (time)
        @AuraEnabled public String ACT_START_DATE   {get;set;} // ? Actual start: Execution (date)
        @AuraEnabled public String ACT_START_TIME   {get;set;} // ? Actual start: Execution/setup (time)
        @AuraEnabled public String ACT_END_DATE     {get;set;} // ? Actual finish: Execution (date)
        @AuraEnabled public String ACT_END_TIME     {get;set;} // ? Actual finish: Execution (time)
        @AuraEnabled public String FCST_FIN_DATE    {get;set;} // ? Forecast finish date of operation from confirmation
        @AuraEnabled public String FCST_FIN_TIME    {get;set;} // ? Forecast finish time of operation from confirmation
        @AuraEnabled public String FREE_BUFFER      {get;set;} // ? Free float
        @AuraEnabled public String TOTAL_BUFFER     {get;set;} // ? Total float
        @AuraEnabled public String WORK_FORECAST    {get;set;} // ? Forecasted work (actual + remaining)
        @AuraEnabled public String SYSTEM_STATUS_TEXT {get;set;} // ? System Status
        @AuraEnabled public String ASSEMBLY_EXTERNAL {get;set;} // ? Long Material Number for Field ASSEMBLY
        @AuraEnabled public String ASSEMBLY_GUID    {get;set;} // ? External GUID for ASSEMBLY Field
        @AuraEnabled public String ASSEMBLY_VERSION {get;set;} // ? Version Number for ASSEMBLY Field
        }
  
      public class IF_CSPLUS_019_Res_T_O_LIST { 
        public IF_CSPLUS_019_Res_T_O_LIST(){}
        
        @AuraEnabled public String AUFNR   {get;set;} // ? Order Number
        @AuraEnabled public String PERNR   {get;set;} // ? Personnel number
        @AuraEnabled public String MSDD    {get;set;} // ? Moving start date
        @AuraEnabled public String MSDZ    {get;set;} // ? Moving start time
        @AuraEnabled public String ISDD    {get;set;} // ? Confirmed date for start of execution
        @AuraEnabled public String ISDZ    {get;set;} // ? Confirmed time for 'Execution start'
        @AuraEnabled public String IEDD    {get;set;} // ? Confirmed date for execution finish
        @AuraEnabled public String IEDZ    {get;set;} // ? Confirmed time for 'Execution finish'
        @AuraEnabled public String LTXA1   {get;set;} // ? Active Text
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

/** IF-CSPLUS-028
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-028
         * SFDC interface Id    : IF_CSPLUS_028
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_RECV_WORK_DATE_REGIST				
         * Description          : 서비스 요원 출동/도착
     */     
    /** REQUEST 
      */     
        public class IF_CSPLUS_028_Req { 
          @AuraEnabled public List<IF_CSPLUS_028_Req_T_I_LIST> T_I_LIST {get;set;} 
        }

        public class IF_CSPLUS_028_Req_T_I_LIST { 
          @AuraEnabled public String AUFNR {get;set;} // ? Order Number
          @AuraEnabled public String PERNR {get;set;} // ? Personnel number
          @AuraEnabled public String MSDD  {get;set;} // ? Moving start date
          @AuraEnabled public String MSDZ  {get;set;} // ? Moving start time
          @AuraEnabled public String ISDD  {get;set;} // ? Confirmed date for start of execution
          @AuraEnabled public String ISDZ  {get;set;} // ? Confirmed time for 'Execution start'
          @AuraEnabled public String IEDD  {get;set;} // ? Confirmed date for execution finish
          @AuraEnabled public String IEDZ  {get;set;} // ? Confirmed time for 'Execution finish'
          @AuraEnabled public String LTXA1 {get;set;} // ? Active Text
        }

    /** RESPONSE 
      */     
        public class IF_CSPLUS_028_Res { 
          @AuraEnabled public IF_CSPLUS_028_Res_O_RETURN O_RETURN {get;set;} 
          @AuraEnabled public List<IF_CSPLUS_028_Res_T_O_LIST> T_O_LIST {get;set;} 
        }

        public class IF_CSPLUS_028_Res_O_RETURN { 
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

        public class IF_CSPLUS_028_Res_T_O_LIST { 
          @AuraEnabled public String AUFNR   {get;set;} // ? Order Number
          @AuraEnabled public String PERNR   {get;set;} // ? Personnel number
          @AuraEnabled public String MSDD    {get;set;} // ? Moving start date
          @AuraEnabled public String MSDZ    {get;set;} // ? Moving start time
          @AuraEnabled public String ISDD    {get;set;} // ? Confirmed date for start of execution
          @AuraEnabled public String ISDZ    {get;set;} // ? Confirmed time for 'Execution start'
          @AuraEnabled public String IEDD    {get;set;} // ? Confirmed date for execution finish
          @AuraEnabled public String IEDZ    {get;set;} // ? Confirmed time for 'Execution finish'
          @AuraEnabled public String LTXA1   {get;set;} // ? Active Text
          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }



/** IF-CSPLUS-037
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-037
         * SFDC interface Id    : IF_CSPLUS_037
         * New I/F              : ZCRM_CS_CREATE_SRV_ORDER_USA				
         * Description          : A/S접수 생성
     */     
    /** REQUEST 
      */     
        public class IF_CSPLUS_037_Req { 
          @AuraEnabled public String I_EQUNR      {get;set;} // ? Equipment Number
          @AuraEnabled public String I_RES_PERSON {get;set;} // ? Responsible Partner

          @AuraEnabled public IF_CSPLUS_037_Req_I_HEADER I_HEADER {get;set;} 
          @AuraEnabled public IF_CSPLUS_037_Req_I_OPERATION I_OPERATION {get;set;} 
          @AuraEnabled public IF_CSPLUS_037_Req_I_NOTI I_NOTI {get;set;} 
        }

        public class IF_CSPLUS_037_Req_I_HEADER { 
          @AuraEnabled public String PLANPLANT  {get;set;} // ? Maintenance Planning Plant
          @AuraEnabled public String PLANGROUP  {get;set;} // ? Planner Group for Customer Service and Plant Maintenance
          @AuraEnabled public String MN_WK_CTR  {get;set;} // ? Main work center for maintenance tasks
          @AuraEnabled public String PLANT      {get;set;} // ? Plant associated with main work center
          @AuraEnabled public String PMACTTYPE  {get;set;} // ? Maintenance activity type
          @AuraEnabled public String START_DATE {get;set;} // ? Basic start date
          @AuraEnabled public String SHORT_TEXT {get;set;} // ? Description
        }

        public class IF_CSPLUS_037_Req_I_OPERATION { 
          @AuraEnabled public String CONTROL_KEY {get;set;} // ? Control key
          @AuraEnabled public String SHORT_TEXT {get;set;} // ? Operation short text
        }

        public class IF_CSPLUS_037_Req_I_NOTI { 
          @AuraEnabled public String DESSTDATE  {get;set;} // ? Required start date
          @AuraEnabled public String DESENDDATE {get;set;} // ? Required End Date
          @AuraEnabled public String PLANPLANT  {get;set;} // ? Maintenance Planning Plant
          @AuraEnabled public String PLANGROUP  {get;set;} // ? Planner Group for Customer Service and Plant Maintenance
          @AuraEnabled public String STRMLFNDATE {get;set;} // ? Start of Malfunction (Date)
          @AuraEnabled public String ENDMLFNDATE {get;set;} // ? End of Malfunction (Date)
          @AuraEnabled public String REPORTEDBY {get;set;} // ? Name of Person Reporting Notification
          @AuraEnabled public String NOTIF_DATE {get;set;} // ? Date of Notification
          @AuraEnabled public String CODE_GROUP {get;set;} // ? Code Group - Coding
          @AuraEnabled public String CODING     {get;set;} // ? Coding
          @AuraEnabled public String MAINTPLANT {get;set;} // ? Maintenance plant
        }

    /** RESPONSE 
      */     
        public class IF_CSPLUS_037_Res { 
          @AuraEnabled public String E_NOTI_NUMB     {get;set;} // ? Notification No
          @AuraEnabled public String E_SERVICE_ORDER {get;set;} // ? Order Number

          @AuraEnabled public List<IF_CSPLUS_037_Res_T_RETURN> T_RETURN {get;set;} 
        }

        public class IF_CSPLUS_037_Res_T_RETURN { 
          @AuraEnabled public String TYPE   {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String ID     {get;set;} // ? Message Class
          @AuraEnabled public String IF_NUMBER {get;set;} // ? Message Number
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
          @AuraEnabled public String LOG_NO {get;set;} // ? Application log: log number
          @AuraEnabled public String LOG_MSG_NO {get;set;} // ? Application log: Internal message serial number
          @AuraEnabled public String MESSAGE_V1 {get;set;} // ? Message Variable
          @AuraEnabled public String MESSAGE_V2 {get;set;} // ? Message Variable
          @AuraEnabled public String MESSAGE_V3 {get;set;} // ? Message Variable
          @AuraEnabled public String MESSAGE_V4 {get;set;} // ? Message Variable
          @AuraEnabled public String PARAMETER {get;set;} // ? Parameter Name
          @AuraEnabled public String ROW    {get;set;} // ? Lines in parameter
          @AuraEnabled public String FIELD  {get;set;} // ? Field in parameter
          @AuraEnabled public String IF_SYSTEM {get;set;} // ? Logical system from which message originates
        }





/** IF-CSPLUS-042
    */  
    /**
         * Apex Class           : IF_ERP_WorkOrder
         * Wrapper Class        : IF_ERP_WorkOrder_Classes
         * Wrapper Name         : IF-CSPLUS-042
         * SFDC interface Id    : IF_CSPLUS_042
         * AS-IS RFC            : 통합
         * New I/F              : ZCRM_CS_RECV_SP_CLAIM_SAVE				
         * Description          : 설치검수 정기점검 및 기획/순회서비스 생성
    */
    public class IF_CSPLUS_042_Req{
        @AuraEnabled public String I_EQUNR      {get;set;}
        @AuraEnabled public String I_KTEXT      {get;set;}
        @AuraEnabled public String I_PERNR      {get;set;}
        @AuraEnabled public String I_ILART      {get;set;}
        @AuraEnabled public String I_VAPLZ      {get;set;}
        @AuraEnabled public String I_AUFNR      {get;set;}
        @AuraEnabled public String I_GSTRP      {get;set;}
        @AuraEnabled public String I_KUNUM      {get;set;}
        @AuraEnabled public String I_COWORKER1  {get;set;}
        @AuraEnabled public String I_COWORKER2  {get;set;}
        @AuraEnabled public String I_COWORKER3  {get;set;}
        @AuraEnabled public String I_COWORKER4  {get;set;}
        @AuraEnabled public String I_SWERKS     {get;set;}
        @AuraEnabled public List<IF_CSPLUS_042_Req_T_I_LIST>    T_I_LIST  {get;set;}
        @AuraEnabled public List<IF_CSPLUS_042_Req_T_I_LIST2>   T_I_LIST2 {get;set;}
        
        public IF_CSPLUS_042_Req(){}
    }
    public class IF_CSPLUS_042_Req_T_I_LIST{
        @AuraEnabled public String LINE     {get;set;}

        public IF_CSPLUS_042_Req_T_I_LIST(){}
    }
    public class IF_CSPLUS_042_Req_T_I_LIST2{
        @AuraEnabled public String LINE     {get;set;}

        public IF_CSPLUS_042_Req_T_I_LIST2(){}
    }
    public class IF_CSPLUS_042_Res{
        @AuraEnabled public IF_CSPLUS_042_Res_O_RETURN O_RETURN {get;set;}
        @AuraEnabled public String O_AUFNR {get;set;}

        public IF_CSPLUS_042_Res(){}
    }
    public class IF_CSPLUS_042_Res_O_RETURN{
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_CSPLUS_042_Res_O_RETURN(){}
    }

/** SFDC interface Id   : IF-CSPLUS-046
 * New I/F              : ZCRM_CS_WORK_ORDER_FILE
 * Description          : 서비스오더 파일 데이터 조회 (CRM -> ERP)
    */
    public class IF_CSPLUS_046_Req{
        @AuraEnabled public String  I_AUFNR {get;set;}
        @AuraEnabled public String  I_SIZE  {get;set;}


        public IF_CSPLUS_046_Req(){}
    }
    public class IF_CSPLUS_046_Res{
        @AuraEnabled public List<IF_CSPLUS_046_Res_T_DOCUMENT>          T_DOCUMENT        {get;set;}
        @AuraEnabled public List<IF_CSPLUS_046_Res_T_DOCUMENT_FILE>     T_DOCUMENT_FILE   {get;set;}
        @AuraEnabled public IF_CSPLUS_046_Res_O_RETURN                  O_RETURN          {get;set;}

        public IF_CSPLUS_046_Res(){}
    }
    public class IF_CSPLUS_046_Res_T_DOCUMENT{
        @AuraEnabled public String OBJKY    {get;set;}
        @AuraEnabled public String DOKAR    {get;set;}
        @AuraEnabled public String DOKNR    {get;set;}
        @AuraEnabled public String DOKTL    {get;set;}
        @AuraEnabled public String DOKVR    {get;set;}
        @AuraEnabled public String DKTXT    {get;set;}

        public IF_CSPLUS_046_Res_T_DOCUMENT(){}
    }
    public class IF_CSPLUS_046_Res_T_DOCUMENT_FILE{
        @AuraEnabled public String OBJKY            {get;set;}
        @AuraEnabled public String DOKAR            {get;set;}
        @AuraEnabled public String DOKNR            {get;set;}
        @AuraEnabled public String DOKTL            {get;set;}
        @AuraEnabled public String DOKVR            {get;set;}
        @AuraEnabled public String BUFFER           {get;set;}
        @AuraEnabled public String WSAPPLICATION    {get;set;}

        public IF_CSPLUS_046_Res_T_DOCUMENT_FILE(){}
    }
    public class IF_CSPLUS_046_Res_O_RETURN{
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_CSPLUS_046_Res_O_RETURN(){}
    }

}