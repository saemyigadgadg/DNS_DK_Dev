public with sharing class IF_ERP_Parts_Pending_Classes {
    public IF_ERP_Parts_Pending_Classes() {}

    /** SFDC interface Id    : IF-PARTS-021
     * RFC Name              : ZCRM_EP_SUSPENSE_LIST_ME
     * Description           : (채무현황)미결 현황 조회
        */
        public class IF_PARTS_021_Req{
            @AuraEnabled public String I_USERID                         {get;set;}
            @AuraEnabled public String I_FAEDT                          {get;set;}
            @AuraEnabled public IF_PARTS_021_Req_I_USERINFO I_USERINFO  {get;set;}

            public IF_PARTS_021_Req(){}
        }
        public class IF_PARTS_021_Req_I_USERINFO{
            @AuraEnabled public String BNAME    {get;set;}
            @AuraEnabled public String RNAME    {get;set;}
            @AuraEnabled public String HIER     {get;set;}
            @AuraEnabled public String KUNNR    {get;set;}
            @AuraEnabled public String LIFNR    {get;set;}

            @AuraEnabled public String VKORG    {get;set;}
            @AuraEnabled public String VTWEG    {get;set;}
            @AuraEnabled public String SPART    {get;set;}
            @AuraEnabled public String WERKS    {get;set;}
            @AuraEnabled public String ARBPL    {get;set;}
            
            @AuraEnabled public String PARNR    {get;set;}
            @AuraEnabled public String ENAME    {get;set;}
            @AuraEnabled public String KUNN2    {get;set;}
            @AuraEnabled public String LAND1    {get;set;}
            @AuraEnabled public String LGORT    {get;set;}
            
            @AuraEnabled public String DF_CHK   {get;set;}
            @AuraEnabled public String CO_CHK   {get;set;}

            public IF_PARTS_021_Req_I_USERINFO(){}
        }
        public class IF_PARTS_021_Res{
            @AuraEnabled public String                              O_MESG      {get;set;}
            @AuraEnabled public String                              O_COUNT     {get;set;}
            @AuraEnabled public IF_PARTS_021_Res_O_RETURN           O_RETURN    {get;set;}
            @AuraEnabled public List<IF_PARTS_021_Res_T_RECEIPT>    T_RECEIPT   {get;set;}
            @AuraEnabled public List<IF_PARTS_021_Res_T_LIST>       T_LIST      {get;set;}

            public IF_PARTS_021_Res(){}
        }
        public class IF_PARTS_021_Res_O_RETURN{
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String CODE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}
            @AuraEnabled public String LOG_NO       {get;set;}

            @AuraEnabled public String LOG_MSG_NO   {get;set;}
            @AuraEnabled public String MESSAGE_V1   {get;set;}
            @AuraEnabled public String MESSAGE_V2   {get;set;}
            @AuraEnabled public String MESSAGE_V3   {get;set;}
            
            @AuraEnabled public String MESSAGE_V4   {get;set;}

            public IF_PARTS_021_Res_O_RETURN(){}
        }
        public class IF_PARTS_021_Res_T_RECEIPT{
            @AuraEnabled public String FAEDT            {get;set;}
            @AuraEnabled public String WRBTR            {get;set;}
            @AuraEnabled public String WRBTR2           {get;set;}
            @AuraEnabled public String WRBTR3           {get;set;}

            @AuraEnabled public String WAERK            {get;set;}
            @AuraEnabled public String WRSHB            {get;set;}
            @AuraEnabled public String WRBTR_OVERDUE    {get;set;}
            @AuraEnabled public String SHKZG            {get;set;}

            public IF_PARTS_021_Res_T_RECEIPT(){}
        }
        public class IF_PARTS_021_Res_T_LIST{
            @AuraEnabled public String VBELN    {get;set;}
            @AuraEnabled public String XBLNR    {get;set;}
            @AuraEnabled public String FAEDT    {get;set;}
            @AuraEnabled public String WRBTR    {get;set;}

            @AuraEnabled public String WRBTR2   {get;set;}
            @AuraEnabled public String WRBTR3   {get;set;}
            @AuraEnabled public String WAERK    {get;set;}
            @AuraEnabled public String WRSHB    {get;set;}
            
            @AuraEnabled public String FKDAT    {get;set;}

            public IF_PARTS_021_Res_T_LIST(){}
        }
}