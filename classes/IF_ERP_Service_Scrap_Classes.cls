public with sharing class IF_ERP_Service_Scrap_Classes {
    public IF_ERP_Service_Scrap_Classes() {}

    /** SFDC interface Id   : IF-SERVICE-047
     * AS-IS RFC            : Z_CS_WEB_ITEM_TO_BE_RETURN_ME
     * New I/F              : ZCRM_CS_WEB_ITEM_TO_BE_RETURN
     * Description          : 폐품 반납 목록 조회
        */
        /**
            REQUEST
        */
            public class IF_SERVICE_047_Req{
                @AuraEnabled public String I_DATUM_TO {get;set;} // ? Date
                @AuraEnabled public String I_DATUM_FROM {get;set;} // ? Date
                @AuraEnabled public String I_ARBPL {get;set;} // ? Work center
                @AuraEnabled public String I_KTEXT {get;set;} // ? General Name
                @AuraEnabled public String I_RETURN_TYPE {get;set;} // ? Return Type

                @AuraEnabled public String I_RETURN_YN {get;set;} // ? Character Field Length 1
                @AuraEnabled public String I_PARNR {get;set;} // ? Partner
                @AuraEnabled public String I_ENAME {get;set;} // ? Formatted Name of Employee or Applicant
                @AuraEnabled public String I_LANGU {get;set;} // ? Language Key of Current Text Environment
                @AuraEnabled public String I_AUFNR {get;set;} // ? Order Number

                @AuraEnabled public String I_MATNR {get;set;} // ? Material Number

                @AuraEnabled public IF_SERVICE_047_Req_I_USERINFO I_USERINFO {get;set;} 
    
                public IF_SERVICE_047_Req(){
                    this.I_USERINFO = new IF_SERVICE_047_Req_I_USERINFO();
                }
            }
            public class IF_SERVICE_047_Req_I_USERINFO { 
                public IF_SERVICE_047_Req_I_USERINFO(){}
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

        /**
            RESPONSE
        */
            public class IF_SERVICE_047_Res{
                @AuraEnabled public IF_SERVICE_047_Res_O_RETURN     O_RETURN    {get;set;}
                @AuraEnabled public List<IF_SERVICE_047_Res_T_LIST> T_LIST      {get;set;}

                public IF_SERVICE_047_Res(){}
            }
            public class IF_SERVICE_047_Res_O_RETURN{
                @AuraEnabled public String TYPE    {get;set;} // ? "Message type: S Success, E Error, W Warning, I Info, A Abort"
                @AuraEnabled public String CODE    {get;set;} // ? Message code
                @AuraEnabled public String MESSAGE {get;set;} // ? Message Text

                public IF_SERVICE_047_Res_O_RETURN(){}
            }
            public class IF_SERVICE_047_Res_T_LIST{
                @AuraEnabled public String AUFNR {get;set;} // ? Order Number
                @AuraEnabled public String SERNR {get;set;} // ? Serial number
                @AuraEnabled public String TYPBZ {get;set;} // ? Manufacturer model number
                @AuraEnabled public String REP_NAME {get;set;} // ? Name of Representative
                @AuraEnabled public String MATNR {get;set;} // ? Material Number

                @AuraEnabled public String MAKTX {get;set;} // ? Material Description (Short Text)
                @AuraEnabled public String MENGE {get;set;} // ? Quantity in Unit of Entry
                @AuraEnabled public String MEINS {get;set;} // ? Base Unit of Measure
                @AuraEnabled public String RETURN_TYPE {get;set;} // ? Return Type
                @AuraEnabled public String RETURN_TYPE_T {get;set;} // ? Short Text for Fixed Values

                @AuraEnabled public String SUPPLY_TYPE {get;set;} // ? 부품센타/대리점/정비센타
                @AuraEnabled public String RETURN_END_YN {get;set;} // ? Character Field Length 1
                @AuraEnabled public String ARBPL {get;set;} // ? Work center
                @AuraEnabled public String KTEXT {get;set;} // ? General Name
                @AuraEnabled public String TEXT  {get;set;} // ? Text field

                @AuraEnabled public String ISSUE_QTY {get;set;} // ? Quantity in Unit of Entry
                @AuraEnabled public String RETURN_YN {get;set;} // ? Return Y or N
                @AuraEnabled public String NO_QTY {get;set;} // ? Quantity in Unit of Entry
                @AuraEnabled public String SVCMAN {get;set;} // ? Name
                @AuraEnabled public String PRT_DATE {get;set;} // ? Changed On

                @AuraEnabled public String PRT_TIME {get;set;} // ? Time last change was made
                @AuraEnabled public String NAME1 {get;set;} // ? Name
                @AuraEnabled public String NAME2 {get;set;} // ? Name
                @AuraEnabled public String SEQNO {get;set;} // ? Sequential no
                @AuraEnabled public String QMNUM {get;set;} // ? Notification No

                public IF_SERVICE_047_Res_T_LIST(){}
            }

    /** SFDC interface Id   : IF-SERVICE-048
     * AS-IS RFC            : Z_CS_WEB_RETURN_PARTS_PRINT
     * New I/F              : ZCRM_CS_WEB_RETURN_PARTS_PRINT
     * Description          : Service > Service > 관리 > 폐품미반납리스트
        */
        public class IF_SERVICE_048_Req{
            @AuraEnabled public List<IF_SERVICE_048_Req_T_INPUT>  T_INPUT {get;set;}

            public IF_SERVICE_048_Req(){}
        }
        public class IF_SERVICE_048_Req_T_INPUT{
            @AuraEnabled public String MATNR    {get;set;}
            @AuraEnabled public String AUFNR    {get;set;}
                        
            public IF_SERVICE_048_Req_T_INPUT(){}
        }
        public class IF_SERVICE_048_Res{
            @AuraEnabled public IF_SERVICE_048_Res_O_RETURN         O_RETURN    {get;set;}
            @AuraEnabled public List<IF_SERVICE_048_Res_T_OUTPUT>   T_OUTPUT    {get;set;}

            public IF_SERVICE_048_Res(){}
        }
        public class IF_SERVICE_048_Res_O_RETURN{
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String CODE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}

            public IF_SERVICE_048_Res_O_RETURN(){}
        }
        public class IF_SERVICE_048_Res_T_OUTPUT{
            @AuraEnabled public String AUFNR        {get;set;}
            @AuraEnabled public String TYPBZ        {get;set;}
            @AuraEnabled public String SERNR        {get;set;}
            @AuraEnabled public String KTEXT        {get;set;}
            @AuraEnabled public String ENAME        {get;set;}
            @AuraEnabled public String NAME1        {get;set;}
            @AuraEnabled public String WADAT_IST    {get;set;}
            @AuraEnabled public String MATNR        {get;set;}
            @AuraEnabled public String MAKTX        {get;set;}
            @AuraEnabled public String MATXT        {get;set;}
            @AuraEnabled public String MENGE        {get;set;}
            @AuraEnabled public String RETURN_TYPE  {get;set;}
            @AuraEnabled public String RETURN_DT    {get;set;}
            @AuraEnabled public String MEINS        {get;set;}
            @AuraEnabled public String SUPPLY_TYPE  {get;set;}
            @AuraEnabled public String NAME2        {get;set;}
            @AuraEnabled public String QMNUM        {get;set;}
            @AuraEnabled public String SEQNO        {get;set;}
            @AuraEnabled public String RETURN_TEXT  {get;set;}
            @AuraEnabled public String PRT_DATE     {get;set;}
            @AuraEnabled public String PRT_TIME     {get;set;}
            @AuraEnabled public String QMDAT        {get;set;}
            @AuraEnabled public String MZEIT        {get;set;}

            public IF_SERVICE_048_Res_T_OUTPUT(){}
        }
}