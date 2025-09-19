public with sharing class IF_ERP_Service_PartsDetail_Classes {
    public IF_ERP_Service_PartsDetail_Classes() {}

/** IF_SERVICE_037
    */  
    /**
         * Apex Class           : IF_ERP_Service_PartsDetail
         * Wrapper Class        : IF_ERP_Service_PartsDetail_Classes
         * Wrapper Name         : IF_SERVICE_037
         * SFDC interface Id    : IF-SERVICE-037
         * AS-IS RFC            : Z_EP_PARTS_STANDARD_ME	
         * New I/F              : ZCRM_EP_PARTS_STANDARD_ME
         * Description          : 부품 기본 정보 조회
         * KeyValue             : IF_CURRENCY ( CURRENCY )
     */    
    /** REQUEST 
      */
      public class IF_SERVICE_037_Req { 
        public IF_SERVICE_037_Req(){} 
        @AuraEnabled public String I_MATNR   {get;set;} // ? Material Number
        @AuraEnabled public String I_LANGU   {get;set;} // ? Language Key of Current Text Environment
        @AuraEnabled public String I_KVGR5   {get;set;} // ? Customer group 5
        @AuraEnabled public String I_REPLACE {get;set;} // ? Replacement Item Flag
  
        @AuraEnabled public IF_SERVICE_037_Req_I_USERINFO I_USERINFO {get;set;} 
  
        }
  
      public class IF_SERVICE_037_Req_I_USERINFO {
        public IF_SERVICE_037_Req_I_USERINFO(){} 
          @AuraEnabled public String BNAME {get;set;} // S/F CRM User ID
          @AuraEnabled public String RNAME {get;set;} // User Name in User Master Record
          @AuraEnabled public String HIER {get;set;} // [SS] User Hierrchy (Portal)
          @AuraEnabled public String KUNNR {get;set;} // Customer Number 1
          @AuraEnabled public String LIFNR {get;set;} // Account Number of Vendor or Creditor
          @AuraEnabled public String VKORG {get;set;} // Sales Organization
          @AuraEnabled public String VTWEG {get;set;} // Distribution Channel
          @AuraEnabled public String SPART {get;set;} // Division
          @AuraEnabled public String WERKS {get;set;} // Plant
          @AuraEnabled public String ARBPL {get;set;} // Work center
          @AuraEnabled public String PARNR {get;set;} // Partner
          @AuraEnabled public String ENAME {get;set;} // Formatted Name of Employee or Applicant
          @AuraEnabled public String KUNN2 {get;set;} // Customer Number 1
          @AuraEnabled public String LAND1 {get;set;} // Country Key
          @AuraEnabled public String LGORT {get;set;} // Storage Location
          @AuraEnabled public String DF_CHK {get;set;} // Default Check
          @AuraEnabled public String CO_CHK {get;set;} // corporation check
        }
  
    /** RESPONSE 
      */  
      public class IF_SERVICE_037_Res { 
        public IF_SERVICE_037_Res(){}
        @AuraEnabled public String O_AVAIL_QTY2  {get;set;} // 천안재고
        @AuraEnabled public String O_MESG        {get;set;} // ? Message Variable
        @AuraEnabled public String O_AVAIL_QTY {get;set;} // ? 창원재고
        @AuraEnabled public String O_THREAD   {get;set;} // ? Characteristic Value
        @AuraEnabled public String O_MATERIAL {get;set;} // ? Characteristic Value
        @AuraEnabled public String O_MANUFACT {get;set;} // ? Characteristic Value
  
  
        @AuraEnabled public IF_SERVICE_037_Res_O_RESULT O_RESULT {get;set;} 
        @AuraEnabled public IF_SERVICE_037_Res_O_RETURN O_RETURN {get;set;} 
        @AuraEnabled public List<IF_SERVICE_037_Res_ET_AVAIL> ET_AVAIL {get;set;} 
        @AuraEnabled public List<IF_SERVICE_037_Res_ET_CROSS> ET_CROSS {get;set;} 
      }
      public class IF_SERVICE_037_Res_O_RESULT { 
        public IF_SERVICE_037_Res_O_RESULT(){}

        @AuraEnabled public String MAKTX   {get;set;} // ? Material Description (Short Text)
        @AuraEnabled public String SVC_FLAG {get;set;} // ? Serviceability
        @AuraEnabled public String AVA_FLAG {get;set;} // ? Availbility
        @AuraEnabled public String NOTCD   {get;set;} // ? Not-Serviced Reason
        @AuraEnabled public String COND_VALUE {get;set;} // ? Condition rate
  
        @AuraEnabled public String NETPR   {get;set;} // ? Net price
        @AuraEnabled public String IF_CURRENCY {get;set;} // ? Currency Key
        @AuraEnabled public String NETPR_ETC {get;set;} // ? Net price
        @AuraEnabled public String CURRENCY2 {get;set;} // ? Currency Key
        @AuraEnabled public String KWMENG  {get;set;} // ? Cumulative Order Quantity in Sales Units
  
        @AuraEnabled public String AUMNG   {get;set;} // ? Minimum order quantity in base unit of measure
        @AuraEnabled public String LFMNG   {get;set;} // ? Minimum delivery quantity in delivery note processing
        @AuraEnabled public String MEINS   {get;set;} // ? Base Unit of Measure
        @AuraEnabled public String BRGEW   {get;set;} // ? Gross Weight
        @AuraEnabled public String NTGEW   {get;set;} // ? Net Weight
  
        @AuraEnabled public String GEWEI   {get;set;} // ? Weight Unit
        @AuraEnabled public String GROES   {get;set;} // ? Size/dimensions
        @AuraEnabled public String PRODH   {get;set;} // ? Product hierarchy
        @AuraEnabled public String PRODH_T {get;set;} // ? Description
        @AuraEnabled public String BULET   {get;set;} // ? Bulletin
  
        @AuraEnabled public String ZPRAT   {get;set;} // ? Controlling Part
        @AuraEnabled public String HERKL   {get;set;} // ? Country of origin of the material
        @AuraEnabled public String PLIFZ   {get;set;} // ? Planned Delivery Time in Days
        @AuraEnabled public String M_MATNR {get;set;} // ? Material Number
        @AuraEnabled public String C_MTPOS {get;set;} // ? Single-Character Indicator
  
        @AuraEnabled public String DATAB   {get;set;} // ? Validity start date of the condition record
        @AuraEnabled public String KONDM   {get;set;} // ? Material Pricing Group
        @AuraEnabled public String VTEXT   {get;set;} // ? Description
        @AuraEnabled public String NOTCD_TEXT {get;set;} // ? Not-Serviced Reason
        @AuraEnabled public String SVRCD   {get;set;} // ? Service Det.
  
        @AuraEnabled public String SVRCD_TEXT {get;set;} // ? Service Det. Description
        @AuraEnabled public String AVRLT   {get;set;} // ? Planned Delivery Time in Days
        @AuraEnabled public String REMARK2 {get;set;} // ? Dealer Memo
  
        }
  
      public class IF_SERVICE_037_Res_O_RETURN { 
          public IF_SERVICE_037_Res_O_RETURN(){}
          public IF_SERVICE_037_Res_O_RETURN(
           String TYPE      , 
           String CODE      , 
           String MESSAGE   , 
           String LOG_NO    , 
           String LOG_MSG_NO, 
           String MESSAGE_V1, 
           String MESSAGE_V2, 
           String MESSAGE_V3, 
           String MESSAGE_V4 ){
             this.TYPE       = TYPE       ;
             this.CODE       = CODE       ;
             this.MESSAGE    = MESSAGE    ;
             this.LOG_NO     = LOG_NO     ;
             this.LOG_MSG_NO = LOG_MSG_NO ;
             this.MESSAGE_V1 = MESSAGE_V1 ;
             this.MESSAGE_V2 = MESSAGE_V2 ;
             this.MESSAGE_V3 = MESSAGE_V3 ;
             this.MESSAGE_V4 = MESSAGE_V4 ;
          }
        @AuraEnabled public String TYPE       {get;set;} // ? "Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE       {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE    {get;set;} // ? Message Text
        @AuraEnabled public String LOG_NO     {get;set;} // ? Application log: log number
        @AuraEnabled public String LOG_MSG_NO {get;set;} // ? Application log: Internal message serial number
  
        @AuraEnabled public String MESSAGE_V1 {get;set;} // ? Message Variable
        @AuraEnabled public String MESSAGE_V2 {get;set;} // ? Message Variable
        @AuraEnabled public String MESSAGE_V3 {get;set;} // ? Message Variable
        @AuraEnabled public String MESSAGE_V4 {get;set;} // ? Message Variable
  
        }
  
      public class IF_SERVICE_037_Res_ET_AVAIL { 
          public IF_SERVICE_037_Res_ET_AVAIL(){}
          public IF_SERVICE_037_Res_ET_AVAIL(
           String DEALER_CD, 
           String NAME1    , 
           String AVQTY    , 
           String NONMV     ){
             this.DEALER_CD = DEALER_CD ;
             this.NAME1     = NAME1     ;
             this.AVQTY     = AVQTY     ;
             this.NONMV     = NONMV     ;
          }
        @AuraEnabled public String DEALER_CD {get;set;} // ? Dealer Code
        @AuraEnabled public String NAME1 {get;set;} // ? Name
        @AuraEnabled public String AVQTY {get;set;} // ? Quantity
        @AuraEnabled public String NONMV {get;set;} // ? Non-Moving
  
        }
  
      public class IF_SERVICE_037_Res_ET_CROSS {
          public IF_SERVICE_037_Res_ET_CROSS(){}
          public IF_SERVICE_037_Res_ET_CROSS(
           String SEQ   , 
           String MATNR , 
           String MAKTX , 
           String ITCCD , 
           String LABST , 
           String LABST2 , 
           String NOTCD , 
           String DDTEXT ){
             this.SEQ    = SEQ    ;
             this.MATNR  = MATNR  ;
             this.MAKTX  = MAKTX  ;
             this.ITCCD  = ITCCD  ;
             this.LABST  = LABST  ;
             this.LABST2  = LABST2  ;
             this.NOTCD  = NOTCD  ;
             this.DDTEXT = DDTEXT ;
          }
        @AuraEnabled public String SEQ    {get;set;} // ? Character Field Length = 10
        @AuraEnabled public String MATNR  {get;set;} // ? Material Number
        @AuraEnabled public String MAKTX  {get;set;} // ? Material Description (Short Text)
        @AuraEnabled public String ITCCD  {get;set;} // ? Interchangeability Code
        @AuraEnabled public String LABST  {get;set;} // ? Quantity(창원원)
        @AuraEnabled public String LABST2  {get;set;} // ? Quantity(천안)
  
        @AuraEnabled public String NOTCD  {get;set;} // ? Not-Serviced Reason
        @AuraEnabled public String DDTEXT {get;set;} // ? Short Text for Fixed Values
        @AuraEnabled public String SVRCD  {get;set;}
        @AuraEnabled public String MXNE   {get;set;} 
        @AuraEnabled public String SVRCD_TEXT   {get;set;} 
        } 


/** IF_SERVICE_038
    */  
    /**
         * Apex Class           : IF_ERP_Service_PartsDetail
         * Wrapper Class        : IF_ERP_Service_PartsDetail_Classes
         * Wrapper Name         : IF_SERVICE_038
         * SFDC interface Id    : IF-SERVICE-038
         * AS-IS RFC            : Z_EP_ITEM_SUB_LIST_ME		
         * New I/F              : ZCRM_EP_ITEM_SUB_LIST_ME
         * Description          : 대체품 정보 조회 
         * KeyValue             : X
         * NOT NULL             : I_MATNR I_USERID I_LANGU
     */            

    /** REQUEST 
      */
        public class IF_SERVICE_038_Req { 
            public IF_SERVICE_038_Req(){}
            @AuraEnabled public String I_MATNR {get;set;} // ? Material Number                          => NOT NULL
            @AuraEnabled public String I_LANGU {get;set;} // ? Language Key of Current Text Environment => NOT NULL
    
            @AuraEnabled public IF_SERVICE_038_Req_I_USERINFO I_USERINFO {get;set;} 
    
        }
    
        public class IF_SERVICE_038_Req_I_USERINFO { 
            public IF_SERVICE_038_Req_I_USERINFO(){}
              @AuraEnabled public String BNAME {get;set;}  // ? S/F CRM User ID   
              @AuraEnabled public String RNAME {get;set;}  // ? User Name in User Master Record  
              @AuraEnabled public String HIER {get;set;}  // ? [SS] User Hierrchy (Portal)  
              @AuraEnabled public String KUNNR {get;set;}  // ? Customer Number 1  
              @AuraEnabled public String LIFNR {get;set;}  // ? Account Number of Vendor or Creditor  
              @AuraEnabled public String VKORG {get;set;}  // ? Sales Organization  
              @AuraEnabled public String VTWEG {get;set;}  // ? Distribution Channel  
              @AuraEnabled public String SPART {get;set;}  // ? Division  
              @AuraEnabled public String WERKS {get;set;}  // ? Plant  
              @AuraEnabled public String ARBPL {get;set;}  // ? Work center  
              @AuraEnabled public String PARNR {get;set;}  // ? Partner  
              @AuraEnabled public String ENAME {get;set;}  // ? Formatted Name of Employee or Applicant  
              @AuraEnabled public String KUNN2 {get;set;}  // ? Customer Number 1  
              @AuraEnabled public String LAND1 {get;set;}  // ? Country Key  
              @AuraEnabled public String LGORT {get;set;}  // ? Storage Location  
              @AuraEnabled public String DF_CHK {get;set;}  // ? Default Check
              @AuraEnabled public String CO_CHK {get;set;}  // ? corporation check
            }
  
  
    /** RESPONSE 
      */
        public class IF_SERVICE_038_Res { 
            public IF_SERVICE_038_Res(){}

            @AuraEnabled public String O_MESG  {get;set;} // ? Message Variable
            @AuraEnabled public String O_COUNT {get;set;} // ? Loop Index
    
            @AuraEnabled public IF_SERVICE_038_Res_O_RETURN O_RETURN {get;set;} 
            @AuraEnabled public List<IF_SERVICE_038_Res_T_LIST> T_LIST {get;set;} 
    
        }
    
        public class IF_SERVICE_038_Res_O_RETURN { 
            public IF_SERVICE_038_Res_O_RETURN (){}
            @AuraEnabled public String TYPE       {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE       {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE    {get;set;} // ? Message Text
            @AuraEnabled public String LOG_NO     {get;set;} // ? Application log: log number
            @AuraEnabled public String LOG_MSG_NO {get;set;} // ? Application log: Internal message serial number
    
            @AuraEnabled public String MESSAGE_V1 {get;set;} // ? Message Variable
            @AuraEnabled public String MESSAGE_V2 {get;set;} // ? Message Variable
            @AuraEnabled public String MESSAGE_V3 {get;set;} // ? Message Variable
            @AuraEnabled public String MESSAGE_V4 {get;set;} // ? Message Variable
    
        }
    
        public class IF_SERVICE_038_Res_T_LIST { 
            public IF_SERVICE_038_Res_T_LIST (){}

            @AuraEnabled public String MATNR    {get;set;} // ? Material Number
            @AuraEnabled public String MAKTX    {get;set;} // ? Material Description (Short Text)
            @AuraEnabled public String AVA_FLAG {get;set;} // ? Availbility
    
        }
  
  
  
}