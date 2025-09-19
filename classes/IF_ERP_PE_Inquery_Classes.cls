public with sharing class IF_ERP_PE_Inquery_Classes {
    public IF_ERP_PE_Inquery_Classes() {}


// ** IF-PARTS-029
/**
  */
  /**
         * Wrapper Name         : IF_PARTS_029
         * SFDC interface Id    : IF-PARTS-029
         * New I/F              : ZCRM_SS_RECV_PE_INQUIRY_LIST
         * Description          : PE Inquiry list 조회
         * Endpoint             : http://218.147.24.51:4148/invoke/di_salesforce.adpt.PARTS:ZCRM_SS_RECV_PE_INQUIRY_LIST
    */    
    public class IF_PARTS_029_Req{
        @AuraEnabled public IF_PARTS_029_Req_I_USERINFO I_USERINFO   {get;set;}
        @AuraEnabled public String                      I_PENUM      {get;set;}                                  
        @AuraEnabled public String                      I_INQUIRY    {get;set;}                                      
        @AuraEnabled public String                      I_DOCDT_FR   {get;set;}                                      
        @AuraEnabled public String                      I_DOCDT_TO   {get;set;}    

        @AuraEnabled public String                      I_MATNR      {get;set;}                                  
        @AuraEnabled public String                      I_STAT       {get;set;}                                  
        @AuraEnabled public String                      I_PAGENO     {get;set;}                                  
        @AuraEnabled public String                      I_ROWNO      {get;set;}                                  

        public IF_PARTS_029_Req(){}
    }
    public class IF_PARTS_029_Req_I_USERINFO{
        @AuraEnabled public String BNAME        {get;set;}
        @AuraEnabled public String RNAME        {get;set;}
        @AuraEnabled public String HIER         {get;set;}
        @AuraEnabled public String KUNNR        {get;set;}
        @AuraEnabled public String LIFNR        {get;set;}

        @AuraEnabled public String VKORG        {get;set;}
        @AuraEnabled public String VTWEG        {get;set;}
        @AuraEnabled public String SPART        {get;set;}
        @AuraEnabled public String WERKS        {get;set;}
        @AuraEnabled public String ARBPL        {get;set;}
        
        @AuraEnabled public String PARNR        {get;set;}
        @AuraEnabled public String ENAME        {get;set;}
        @AuraEnabled public String KUNN2        {get;set;}
        @AuraEnabled public String LAND1        {get;set;}
        @AuraEnabled public String LGORT        {get;set;}
        
        @AuraEnabled public String DF_CHK       {get;set;}
        @AuraEnabled public String CO_CHK       {get;set;}

        public IF_PARTS_029_Req_I_USERINFO(){}
    }
    public class IF_PARTS_029_Res{
        @AuraEnabled public IF_PARTS_029_Res_O_RETURN       O_RETURN  {get;set;}
        @AuraEnabled public String                          O_LINES   {get;set;}
        @AuraEnabled public List<IF_PARTS_029_Res_T_LIST>   T_LIST    {get;set;}
        public IF_PARTS_029_Res(){}
    }
    public class IF_PARTS_029_Res_O_RETURN{
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_PARTS_029_Res_O_RETURN(){}
    }
    public class IF_PARTS_029_Res_T_LIST{
        @AuraEnabled public String PENUM      {get;set;}             
        @AuraEnabled public String INQUIRY    {get;set;}             
        @AuraEnabled public String STAT       {get;set;}         
        @AuraEnabled public String STAT_TXT   {get;set;}             
        @AuraEnabled public String DOCDT      {get;set;}             

        @AuraEnabled public String PERSON     {get;set;}             
        @AuraEnabled public String EMAIL      {get;set;}             
        @AuraEnabled public String TYPBZ      {get;set;}             
        @AuraEnabled public String SERNR      {get;set;}             
        @AuraEnabled public String REMARK     {get;set;}             
        
        @AuraEnabled public String RJ_REASON  {get;set;}                 
        @AuraEnabled public String ATTACH     {get;set;}             

        public IF_PARTS_029_Res_T_LIST(){}
    }

// ** IF-PARTS-030
/**
  */
  /**
         * Wrapper Name         : IF_PARTS_030
         * SFDC interface Id    : IF-PARTS-030
         * New I/F              : ZCRM_SS_PE_INQUIRY_SIMULATION
         * Description          : Parts 가격 조회
         * Endpoint             : http://218.147.24.51:4148/invoke/di_salesforce.adpt.PARTS:ZCRM_SS_PE_INQUIRY_SIMULATION
    */    
    public class IF_PARTS_030_Req{
        @AuraEnabled public IF_PARTS_030_Req_I_USERINFO     I_USERINFO  {get;set;}
        @AuraEnabled public List<IF_PARTS_030_Req_IT_MAT>   IT_MAT      {get;set;}

        public IF_PARTS_030_Req(){}
    }
    public class IF_PARTS_030_Req_I_USERINFO{
        @AuraEnabled public String BNAME     {get;set;}           
        @AuraEnabled public String RNAME     {get;set;}           
        @AuraEnabled public String HIER      {get;set;}       
        @AuraEnabled public String KUNNR     {get;set;}           
        @AuraEnabled public String LIFNR     {get;set;}           

        @AuraEnabled public String VKORG     {get;set;}           
        @AuraEnabled public String VTWEG     {get;set;}           
        @AuraEnabled public String SPART     {get;set;}           
        @AuraEnabled public String WERKS     {get;set;}           
        @AuraEnabled public String ARBPL     {get;set;}           
        
        @AuraEnabled public String PARNR     {get;set;}           
        @AuraEnabled public String ENAME     {get;set;}           
        @AuraEnabled public String KUNN2     {get;set;}           
        @AuraEnabled public String LAND1     {get;set;}           
        @AuraEnabled public String LGORT     {get;set;}           
        
        @AuraEnabled public String DF_CHK    {get;set;}           
        @AuraEnabled public String CO_CHK    {get;set;}                   

        public IF_PARTS_030_Req_I_USERINFO(){}
    }
    public class IF_PARTS_030_Req_IT_MAT{
        @AuraEnabled public String PEITEM    {get;set;}  
        @AuraEnabled public String MATNR     {get;set;}  
        @AuraEnabled public String MAKTX     {get;set;}  
        @AuraEnabled public String WAERS     {get;set;}  
        @AuraEnabled public String SPRICE    {get;set;}          

        public IF_PARTS_030_Req_IT_MAT(){}
    }
    public class IF_PARTS_030_Res{
        @AuraEnabled public IF_PARTS_030_Res_ES_RETURN      ES_RETURN   {get;set;}
        @AuraEnabled public List<IF_PARTS_030_Res_ET_SIMUL> ET_SIMUL    {get;set;}
        @AuraEnabled public List<IF_PARTS_030_Res_ET_SAP>   ET_SAP      {get;set;}

        public IF_PARTS_030_Res(){}
    }
    public class IF_PARTS_030_Res_ES_RETURN{
        @AuraEnabled public String TYPE      {get;set;}   
        @AuraEnabled public String CODE      {get;set;}   
        @AuraEnabled public String MESSAGE   {get;set;}               

        public IF_PARTS_030_Res_ES_RETURN(){}
    }
    public class IF_PARTS_030_Res_ET_SIMUL{
        @AuraEnabled public String PEITEM    {get;set;}   
        @AuraEnabled public String MATNR     {get;set;}   
        @AuraEnabled public String MAKTX     {get;set;}   
        @AuraEnabled public String WAERS     {get;set;}   
        @AuraEnabled public String SPRICE    {get;set;}                       

        public IF_PARTS_030_Res_ET_SIMUL(){}
    }
    public class IF_PARTS_030_Res_ET_SAP{
        @AuraEnabled public String PEITEM    {get;set;}   
        @AuraEnabled public String MATNR     {get;set;}   
        @AuraEnabled public String MAKTX     {get;set;}   
        @AuraEnabled public String WAERS     {get;set;}   
        @AuraEnabled public String SPRICE    {get;set;}                       

        public IF_PARTS_030_Res_ET_SAP(){}
    }

// ** IF-PARTS-031
/**
  */
  /**
         * Wrapper Name         : IF_PARTS_031
         * SFDC interface Id    : IF-PARTS-031
         * New I/F              : ZCRM_SS_RECV_PE_INQUIRY_CREATE
         * Description          : PE Inquiry 생성
  */    
    // ** REQUEST
    /**
     */
        public class IF_PARTS_031_Req { 
            public IF_PARTS_031_Req(){
                this.IS_USERINFO = new IF_PARTS_031_Req_I_USERINFO();
                this.IS_HD      = new IF_PARTS_031_Req_IS_HD();
                this.IT_ITEM    = new List<IF_PARTS_031_Req_IT_ITEM>  ();
                this.IT_ATTACH  = new List<IF_PARTS_031_Req_IT_ATTACH>(); 
            }
            @AuraEnabled public IF_PARTS_031_Req_I_USERINFO         IS_USERINFO  {get;set;} 
            @AuraEnabled public IF_PARTS_031_Req_IS_HD              IS_HD       {get;set;} 
            @AuraEnabled public List<IF_PARTS_031_Req_IT_ITEM>      IT_ITEM     {get;set;} 
            @AuraEnabled public List<IF_PARTS_031_Req_IT_ATTACH>    IT_ATTACH   {get;set;} 
        }
    
        public class IF_PARTS_031_Req_I_USERINFO { 
            public IF_PARTS_031_Req_I_USERINFO(){}
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
    
        public class IF_PARTS_031_Req_IS_HD { 
            public IF_PARTS_031_Req_IS_HD(){}
            @AuraEnabled public String PENUM {get;set;} // ? PE Inquiry No.
            @AuraEnabled public String INQUIRY {get;set;} // ? Inquiry PO No
            @AuraEnabled public String KUNNR {get;set;} // ? Dealer 
            @AuraEnabled public String NAME1 {get;set;} // ? Dealer Name
            @AuraEnabled public String PERSON {get;set;} // ? DNSEU( In charge )
            @AuraEnabled public String EMAIL {get;set;} // ? Email
            @AuraEnabled public String DOCDT {get;set;} // ? Entry Date
            @AuraEnabled public String TYPBZ {get;set;} // ? Model number
            @AuraEnabled public String SERNR {get;set;} // ? Serial number
            @AuraEnabled public String REMARK {get;set;} // ? Remark
            @AuraEnabled public String RJ_REASON {get;set;} // ? Reject Reason
            @AuraEnabled public String STAT {get;set;} // ? Status
        }
    
        public class IF_PARTS_031_Req_IT_ITEM { 
            public IF_PARTS_031_Req_IT_ITEM(){}
            @AuraEnabled public String PEITEM {get;set;} // ? Item No.
            @AuraEnabled public String MATNR  {get;set;} // ? Parts No.
            @AuraEnabled public String MAKTX  {get;set;} // ? Parts Description
            @AuraEnabled public String COMMNT {get;set;} // ? Comments
            @AuraEnabled public String WAERS  {get;set;} // ? Currency Key
    
            @AuraEnabled public String MPRICE {get;set;} // ? Market Price
            @AuraEnabled public String SPRICE {get;set;} // ? System Price
            @AuraEnabled public String NPRICE {get;set;} // ? New Price
        }
    
        public class IF_PARTS_031_Req_IT_ATTACH { 
            public IF_PARTS_031_Req_IT_ATTACH(){}
            @AuraEnabled public String FILE_NO {get;set;} // ? File No.
            @AuraEnabled public String FILE_SEQ {get;set;} // ? Seq.
            @AuraEnabled public String FILE_NAME {get;set;} // ? File Name
            @AuraEnabled public String CLUSTR {get;set;} // ? Length field for user data in EXPORT/IMPORT tables
            @AuraEnabled public String CLUSTD {get;set;} // ? SAPscript: LONG RAW field for table STXL
        }

    // ** RESPONSE
    /**
     */        
        public class IF_PARTS_031_Res{
            @AuraEnabled public IF_PARTS_031_Res_ES_RETURN ES_RETURN {get;set;}
            @AuraEnabled public String E_PENUM {get;set;} // PE Inquiry No.
        }

        public class IF_PARTS_031_Res_ES_RETURN{
            @AuraEnabled public String TYPE     {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE     {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE  {get;set;} // ? Message Text
        }
    

// ** IF-PARTS-032
/**
  */
  /**
         * Wrapper Name         : IF_PARTS_032
         * SFDC interface Id    : IF-PARTS-032
         * New I/F              : ZCRM_SS_RECV_PE_INQUIRY_DETAIL
         * Description          : PE Inquiry 상세 화면 조회
  */    
    // ** REQUEST
    /**
        */
        public class IF_PARTS_032_Req { 
            @AuraEnabled public String I_PENUM {get;set;} // ? PE Inquiry No. (Required)
            @AuraEnabled public IF_PARTS_032_Req_I_USERINFO I_USERINFO {get;set;} 
        }
      
        public class IF_PARTS_032_Req_I_USERINFO { 
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
      
    // ** RESPONSE
    /**
        */      
        public class IF_PARTS_032_Res { 
            @AuraEnabled public IF_PARTS_032_Res_ES_RETURN ES_RETURN {get;set;} 
            @AuraEnabled public IF_PARTS_032_Res_ES_HD ES_HD {get;set;} 
            @AuraEnabled public List<IF_PARTS_032_Res_ET_ITEM> ET_ITEM {get;set;} 
            @AuraEnabled public List<IF_PARTS_032_Res_ET_ATTACH> ET_ATTACH {get;set;} 
        }
      
        public class IF_PARTS_032_Res_ES_RETURN { 
            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }
      
        public class IF_PARTS_032_Res_ES_HD { 
            @AuraEnabled public String PENUM {get;set;} // ? PE Inquiry No.
            @AuraEnabled public String INQUIRY {get;set;} // ? Inquiry PO No.
            @AuraEnabled public String KUNNR {get;set;} // ? Dealer Code
            @AuraEnabled public String NAME1 {get;set;} // ? Dealer Name
            @AuraEnabled public String PERSON {get;set;} // ? DNSEU( In charge )
      
            @AuraEnabled public String EMAIL {get;set;} // ? E-Mail
            @AuraEnabled public String DOCDT {get;set;} // ? Entry Date
            @AuraEnabled public String TYPBZ {get;set;} // ? Motel Number
            @AuraEnabled public String SERNR {get;set;} // ? Serial Number
            @AuraEnabled public String REMARK {get;set;} // ? Remark
      
            @AuraEnabled public String RJ_REASON {get;set;} // ? Reject Reason
            @AuraEnabled public String STAT {get;set;} // ? Status Q - In Progressing A - Accepted R - Rejected"
        }
      
        public class IF_PARTS_032_Res_ET_ITEM { 
            @AuraEnabled public String PEITEM {get;set;} // ? Item No.
            @AuraEnabled public String MATNR  {get;set;} // ? Material Number
            @AuraEnabled public String MAKTX  {get;set;} // ? Material Description
            @AuraEnabled public String COMMNT {get;set;} // ? Comments
            @AuraEnabled public String WAERS  {get;set;} // ? Currency Key
      
            @AuraEnabled public String MPRICE {get;set;} // ? Market Price
            @AuraEnabled public String SPRICE {get;set;} // ? System Price
            @AuraEnabled public String NPRICE {get;set;} // ? New Price
        }
      
        public class IF_PARTS_032_Res_ET_ATTACH { 
            @AuraEnabled public String FILE_NO   {get;set;} // ? File No.
            @AuraEnabled public String FILE_NAME {get;set;} // ? File Name
        }
      

// ** IF-PARTS-033
/**
  */
  /**
         * Wrapper Name         : IF_PARTS_033
         * SFDC interface Id    : IF-PARTS-033
         * New I/F              : ZCRM_SS_PE_INQUIRY_FILE_DOWN
         * Description          : PE Inquiry 첨부 파일 조회
  */    
    // ** REQUEST
    /**
        */
         public class IF_PARTS_033_Req { 
            @AuraEnabled public String I_PENUM   {get;set;} // ? PE Inquiry No.
            @AuraEnabled public String I_FILE_NO {get;set;} // ? File No.
      
            @AuraEnabled public IF_PARTS_033_Req_I_USERINFO I_USERINFO {get;set;} 
         }
      
         public class IF_PARTS_033_Req_I_USERINFO { 
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
      
    // ** RESPONSE
    /**
        */      
          public class IF_PARTS_033_Res { 
            @AuraEnabled public IF_PARTS_033_Res_ES_RETURN ES_RETURN {get;set;} 
            @AuraEnabled public List<IF_PARTS_033_Res_ET_ATTACH> ET_ATTACH {get;set;} 
          }
      
          public class IF_PARTS_033_Res_ES_RETURN { 
            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
          }
      
          public class IF_PARTS_033_Res_ET_ATTACH { 
            @AuraEnabled public String FILE_NO {get;set;} // ? File No.
            @AuraEnabled public String FILE_SEQ {get;set;} // ? Seq.
            @AuraEnabled public String FILE_NAME {get;set;} // ? File Name
            @AuraEnabled public String CLUSTR {get;set;} // ? Length field for user data in EXPORT/IMPORT tables
            @AuraEnabled public String CLUSTD {get;set;} // ? SAPscript: LONG RAW field for table STXL
          }
      
}