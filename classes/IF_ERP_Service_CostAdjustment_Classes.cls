public with sharing class IF_ERP_Service_CostAdjustment_Classes {
    public IF_ERP_Service_CostAdjustment_Classes() {}


    // SFDC interface Id    : IF_SERVICE_044
    // AS-IS RFC            : ZCS_RECV_SVC_LABOR_SAVE       
    // New I/F              : ZCRM_CS_RECV_SVC_LABOR_SAVE				
    // Description          : 비용정산 저장(Order 번호를 기준으로 테이블 업데이트)
    public class IF_SERVICE_044_Req{
        @AuraEnabled public List<IF_SERVICE_044_Req_IT_ITEM> IT_ITEM {get;set;} 
        public IF_SERVICE_044_Req(){}
    }

    public class IF_SERVICE_044_Req_IT_ITEM { 
        @AuraEnabled public String AUFNR   {get;set;} // ? Order Number
        @AuraEnabled public String SEQNO   {get;set;} // ? Sequential no
        @AuraEnabled public String WEB_CHK {get;set;} // ? General Flag
        public IF_SERVICE_044_Req_IT_ITEM(){}
    }


    public class IF_SERVICE_044_Res { 
      @AuraEnabled public IF_SERVICE_044_Res_O_RETURN O_RETURN {get;set;} 
      public IF_SERVICE_044_Res(){}
    }

    public class IF_SERVICE_044_Res_O_RETURN { 
      @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
      @AuraEnabled public String CODE    {get;set;} // ? Message code
      @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
      public IF_SERVICE_044_Res_O_RETURN(){}
  }


// ** IF-SERVICE-043
/**
  */
  /**
     * Class Name           : IF_ERP_Service_CostAdjustment 
     * Wrapper Name         : IF-SERVICE-043
     * SFDC interface Id    : IF-SERVICE-043
     * AS-IS RFC            : ZCS_SEND_WEB_SVC_LABOR_COST      
     * New I/F              : ZCRM_CS_SEND_WEB_SVC_LABOR_COS
     * Description          : 비용정산 목록 조회
     * REAL                 : Y  
  */ 
    // ** REQUEST   
    /**
        */
        public class IF_SERVICE_043_Req { 
          @AuraEnabled public String I_AUFNR {get;set;} // ? Order Number
          @AuraEnabled public String I_DATE_FR {get;set;} // ? Date From
          @AuraEnabled public String I_DATE_TO {get;set;} // ? Date To
          @AuraEnabled public String I_TYPE  {get;set;} // ? S' - Service order, 'I' - Install & Test Run, 'A' - All
          @AuraEnabled public IF_SERVICE_043_Req_I_USERINFO I_USERINFO {get;set;}
          public IF_SERVICE_043_Req(){}
        }

        public class IF_SERVICE_043_Req_I_USERINFO{
          @AuraEnabled public String BNAME {get;set;}                
          @AuraEnabled public String WERKS {get;set;} 
          @AuraEnabled public String ARBPL {get;set;}
        }

    // ** RESPONSE   
    /**
        */        
        public class IF_SERVICE_043_Res { 
          @AuraEnabled public IF_SERVICE_043_Res_O_RETURN O_RETURN {get;set;} 
          @AuraEnabled public List<IF_SERVICE_043_Res_ET_ITEM> ET_ITEM {get;set;} 
          @AuraEnabled public List<IF_SERVICE_043_Res_ET_HD> ET_HD {get;set;} 

          public IF_SERVICE_043_Res(){}
        }

        public class IF_SERVICE_043_Res_O_RETURN {
          public IF_SERVICE_043_Res_O_RETURN(){}

          @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
          @AuraEnabled public String CODE    {get;set;} // ? Message code
          @AuraEnabled public String MESSAGE {get;set;} // ? Message Text

        }

        public class IF_SERVICE_043_Res_ET_ITEM {
          public IF_SERVICE_043_Res_ET_ITEM(){}

          @AuraEnabled public String AUART  {get;set;} // ? Order Type
          @AuraEnabled public String TXT    {get;set;} // ? Short Text
          @AuraEnabled public String AUFNR  {get;set;} // ? Order Number
          @AuraEnabled public String SEQNO  {get;set;} // ? Sequential no
          @AuraEnabled public String RMZHL  {get;set;} // ? Confirmation counter
          @AuraEnabled public String ILART  {get;set;} // ? Maintenance activity type
          @AuraEnabled public String ILATX  {get;set;} // ? Description of maintenance activity type
          @AuraEnabled public String KUNUM  {get;set;} // ? Customer Number
          @AuraEnabled public String NAME1  {get;set;} // ? Name
          @AuraEnabled public String TYPBZ  {get;set;} // ? Manufacturer model number
          @AuraEnabled public String SERNR  {get;set;} // ? Serial number
          @AuraEnabled public String ERDAT  {get;set;} // ? Date on Which Record Was Created
          @AuraEnabled public String ERSDA  {get;set;} // ? Confirmation entry date
          @AuraEnabled public String ARBPL  {get;set;} // ? Work center
          @AuraEnabled public String KTEXT  {get;set;} // ? Short description
          @AuraEnabled public String RESP_MAN_NM {get;set;} // ? Responsible person name
          @AuraEnabled public String SVCMAN_NAME {get;set;} // ? Name
          @AuraEnabled public String LTXA1  {get;set;} // ? Text for translation
          @AuraEnabled public String ISDD   {get;set;} // ? Confirmed date for start of execution
          @AuraEnabled public String ISDZ   {get;set;} // ? Confirmed time for 'Execution start'
          @AuraEnabled public String AUSBS  {get;set;} // ? End of Malfunction (Date)
          @AuraEnabled public String AUZTB  {get;set;} // ? End of Malfunction (Time)
          @AuraEnabled public String MAINHR {get;set;} // ? Actual work
          @AuraEnabled public String TEMPHR {get;set;} // ? Actual work
          @AuraEnabled public String OPTNHR {get;set;} // ? Actual work
          @AuraEnabled public String ETC_HR {get;set;} // ? Actual work
          @AuraEnabled public String ISMNW  {get;set;} // ? Actual work
          @AuraEnabled public String ISMNE  {get;set;} // ? Unit for work
          @AuraEnabled public String EXFLG  {get;set;} // ? Extra Flag
          @AuraEnabled public String TLCST  {get;set;} // ? Total Labor Cost
          @AuraEnabled public String WAERS  {get;set;} // ? Currency Key
          @AuraEnabled public String AEDAT  {get;set;} // ? Changed On
          @AuraEnabled public String WEB_CHK {get;set;} // ? General Flag
          @AuraEnabled public String WORKCD {get;set;} // ? Work Code
          @AuraEnabled public String WORKCD_NM {get;set;} // ? Work Code Name
          @AuraEnabled public String WORK_SUM {get;set;} // ? Actual work
          @AuraEnabled public String STD_MH {get;set;} // ? Actual work
          @AuraEnabled public String PAY_MH {get;set;} // ? Actual work

        }

        public class IF_SERVICE_043_Res_ET_HD {
          public IF_SERVICE_043_Res_ET_HD(){}    
          
          @AuraEnabled public String SPMON {get;set;} // ? Period to analyze - month
          @AuraEnabled public String TLCST {get;set;} // ? Total Service Order Labor Cost
          @AuraEnabled public String INCST {get;set;} // ? Total Install & Test run Labor Cost
          @AuraEnabled public String EDCST {get;set;} // ? Education Cost
          @AuraEnabled public String COCST {get;set;} // ? Consignment Cost

          @AuraEnabled public String TTCST {get;set;} // ? Total Labor Cost

        }

}