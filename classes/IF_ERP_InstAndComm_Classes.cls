public with sharing class IF_ERP_InstAndComm_Classes {
    public IF_ERP_InstAndComm_Classes() {}


/** IF-CSPLUS-036
    */  
    /**
         * Apex Class           : IF_ERP_InstAndComm
         * Wrapper Class        : IF_ERP_InstAndComm_Classes
         * Wrapper Name         : IF-CSPLUS-036
         * SFDC interface Id    : IF_CSPLUS_036
         * New I/F              : ZCRM_CS_WORKORDER_INSTALL
         * Description          : WorkOrder 생성 및 수정
         * KeyValue             : X
         * NOT NULL             : X
     */         
        public class IF_CSPLUS_036_Req{
            public IF_CSPLUS_036_Req(){}
            @AuraEnabled public String I_EQUNR {get;set;}
            @AuraEnabled public String I_SWERKS {get;set;}
            @AuraEnabled public String I_ARBPL {get;set;}
            @AuraEnabled public String I_GSTRP {get;set;}
            @AuraEnabled public String I_PARNR {get;set;}
            @AuraEnabled public String I_VBELN {get;set;}
            @AuraEnabled public String I_WADAT {get;set;}
            @AuraEnabled public String I_LFDAT {get;set;}
            @AuraEnabled public String I_VKBUR {get;set;}
            @AuraEnabled public String I_AUGRU {get;set;}
            @AuraEnabled public String I_SOLDTO {get;set;}

        }
        public class IF_CSPLUS_036_Res{
            public IF_CSPLUS_036_Res(){}
            @AuraEnabled public List<IF_CSPLUS_036_Res_OT_RETURN> OT_RETURN {get;set;}
            @AuraEnabled public String O_AUFNR {get;set;}
        }
        public class IF_CSPLUS_036_Res_OT_RETURN{
            public IF_CSPLUS_036_Res_OT_RETURN(){}
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String CODE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}
        }

    /** SFDC interface Id   : IF-CSPLUS-043
     * RFC Name             : ZCRM_CS_WORKORDER_INSTALL_CHG
     * Description          : 설치시운전 오더 수정
        */
        public class IF_CSPLUS_043_Req{
            @AuraEnabled public String I_EQUNR    {get;set;}     
            @AuraEnabled public String I_SWERKS   {get;set;}     
            @AuraEnabled public String I_ARBPL    {get;set;}     
            @AuraEnabled public String I_GSTRP    {get;set;}     
            @AuraEnabled public String I_PARNR    {get;set;}     

            @AuraEnabled public String I_VBELN    {get;set;}     
            @AuraEnabled public String I_WADAT    {get;set;}     
            @AuraEnabled public String I_LFDAT    {get;set;}     
            @AuraEnabled public String I_VKBUR    {get;set;}     
            @AuraEnabled public String I_AUGRU    {get;set;}     
            
            @AuraEnabled public String I_SOLDTO   {get;set;}     
            @AuraEnabled public String I_AUFNR    {get;set;}                 
            
            public IF_CSPLUS_043_Req(){}
        }
        public class IF_CSPLUS_043_Res{
            @AuraEnabled public List<IF_CSPLUS_043_Res_OT_RETURN>   OT_RETURN   {get;set;}
            @AuraEnabled public String                              O_AUFNR     {get;set;}

            public IF_CSPLUS_043_Res(){}
        }
        public class IF_CSPLUS_043_Res_OT_RETURN{
            @AuraEnabled public String TYPE      {get;set;}   
            @AuraEnabled public String CODE      {get;set;}   
            @AuraEnabled public String MESSAGE   {get;set;}                   

            public IF_CSPLUS_043_Res_OT_RETURN(){}
        }
}