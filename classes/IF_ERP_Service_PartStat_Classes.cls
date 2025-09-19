public with sharing class IF_ERP_Service_PartStat_Classes {
    public IF_ERP_Service_PartStat_Classes() {}

/** IF_SERVICE_035
    */  
    /**
         * ClassName            : IF_ERP_Service_PartStat 
         * Wrapper Name         : IF_SERVICE_035
         * SFDC interface Id    : IF-SERVICE-035
         * AS-IS RFC            : Z_CS_WEB_SVC_PARTS
         * New I/F              : ZCRM_CS_WEB_SVC_PARTS
         * Description          : 청구부품 불출 현황 조회
     */
 
    /** REQUEST 
      */
        public class IF_SERVICE_035_Req { 
        public IF_SERVICE_035_Req(){
          this.I_USERINFO = new IF_SERVICE_035_Req_I_USERINFO();
        }        
        @AuraEnabled public String I_UNAME   {get;set;} // ? 사번
        @AuraEnabled public String I_AUART   {get;set;} // ? Sales Document Type
        @AuraEnabled public String I_EQUNR   {get;set;} // ? Equipment Number
        @AuraEnabled public String I_TYPBZ   {get;set;} // ? Manufacturer model number
        @AuraEnabled public String I_SERNR   {get;set;} // ? Serial number

        @AuraEnabled public String I_RPDAT_F {get;set;} // ? Current Date of Application Server :: essential
        @AuraEnabled public String I_RPDAT_T {get;set;} // ? Current Date of Application Server :: essential
        @AuraEnabled public String I_AUFNR_F {get;set;} // ? Order Number
        @AuraEnabled public String I_AUFNR_T {get;set;} // ? Order Number
        @AuraEnabled public String I_VBELN_F {get;set;} // ? Sales Document

        @AuraEnabled public String I_VBELN_T {get;set;} // ? Sales Document
        @AuraEnabled public String I_ARBPL_F {get;set;} // ? Work center
        @AuraEnabled public String I_ARBPL_T {get;set;} // ? Work center
        @AuraEnabled public String I_EQFNR_F {get;set;} // ? Ref. No.
        @AuraEnabled public String I_EQFNR_T {get;set;} // ? Ref. No.
        
        @AuraEnabled public IF_SERVICE_035_Req_I_USERINFO I_USERINFO {get;set;} 
        }

        public class IF_SERVICE_035_Req_I_USERINFO {
           public IF_SERVICE_035_Req_I_USERINFO(){}
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


    /** RESPONSE 
      */      
        public class IF_SERVICE_035_Res { 
        public IF_SERVICE_035_Res(){}
        @AuraEnabled public IF_SERVICE_035_Res_O_RETURN O_RETURN {get;set;} 
        @AuraEnabled public List<IF_SERVICE_035_Res_T_TAB> T_TAB {get;set;} 
        }

        public class IF_SERVICE_035_Res_O_RETURN {
        public IF_SERVICE_035_Res_O_RETURN(){}
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text

        }

        public class IF_SERVICE_035_Res_T_TAB { 
        public IF_SERVICE_035_Res_T_TAB(){}
        @AuraEnabled public String WERKS   {get;set;} // ? Plant
        @AuraEnabled public String AUFNR   {get;set;} // ? Order Number
        @AuraEnabled public String QMNUM   {get;set;} // ? Notification No
        @AuraEnabled public String EQFNR   {get;set;} // ? Sort field
        @AuraEnabled public String VBELN   {get;set;} // ? Sales Document

        @AuraEnabled public String AUDAT   {get;set;} // ? Document Date (Date Received/Sent)
        @AuraEnabled public String POSNR   {get;set;} // ? Item number of the SD document
        @AuraEnabled public String MATNR   {get;set;} // ? Material Number
        @AuraEnabled public String MAKTX   {get;set;} // ? Material Description (Short Text)
        @AuraEnabled public String MATWA   {get;set;} // ? Material entered

        @AuraEnabled public String KWMENG  {get;set;} // ? Cumulative Order Quantity in Sales Units  BigDecimal
        @AuraEnabled public String MEINS   {get;set;} // ? Base Unit of Measure
        @AuraEnabled public String EDATU   {get;set;} // ? Schedule line date
        @AuraEnabled public String LFIMG   {get;set;} // ? Actual quantity delivered (in sales units) BigDecimal
        @AuraEnabled public String REQTY   {get;set;} // ? Actual quantity delivered (in sales units) BigDecimal

        @AuraEnabled public String VBELN_ST {get;set;} // ? D/O Status
        @AuraEnabled public String LVSTA_ST {get;set;} // ? T/O Status
        @AuraEnabled public String KOSTA_ST {get;set;} // ? pick  Status
        @AuraEnabled public String PKSTA_ST {get;set;} // ? Pack Status
        @AuraEnabled public String TKNUM_ST {get;set;} // ? Ship Status

        @AuraEnabled public String WBSTA_ST {get;set;} // ? G/I Status
        @AuraEnabled public String WADAT   {get;set;} // ? Goods Issue Date
        @AuraEnabled public String VBELN_DO {get;set;} // ? Delivery
        @AuraEnabled public String TKNUM   {get;set;} // ? Shipment Number
        @AuraEnabled public String BEZEI   {get;set;} // ? Name of the controlling area

        @AuraEnabled public String VTEXT   {get;set;} // ? Description
        @AuraEnabled public String EXTI1   {get;set;} // ? Seal Number
        @AuraEnabled public String VBELN_IN {get;set;} // ? Billing Document
        @AuraEnabled public String ZFCIVNO {get;set;} // ? Commercial Invoice Number
        @AuraEnabled public String ZFBLNO  {get;set;} // ? B/L No.

        @AuraEnabled public String VSTEL   {get;set;} // ? Shipping Point/Receiving Point
        @AuraEnabled public String VSTEL_T {get;set;} // ? Description
        @AuraEnabled public String TDLNR   {get;set;} // ? Number of forwarding agent
        @AuraEnabled public String TDLNR_T {get;set;} // ? Name 1
        @AuraEnabled public String EXIDV   {get;set;} // ? External Handling Unit Identification

        @AuraEnabled public String PRETD   {get;set;} // ? Proposed ETD
        @AuraEnabled public String CALBASE {get;set;} // ? calculated basis
        @AuraEnabled public String ZFHBLNO {get;set;} // ? House B/L No.
        @AuraEnabled public String ZFMBLNO {get;set;} // ? Master B/L No.

        }
      
}