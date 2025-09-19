public with sharing class IF_ERP_Board_Classes {
    public IF_ERP_Board_Classes() {}

/** IF-CSPLUS-030
    */  
    /**
         * Apex Class           : IF_ERP_Board
         * Wrapper Class        : IF_ERP_Board_Classes
         * Wrapper Name         : IF-CSPLUS-030
         * SFDC interface Id    : IF_CSPLUS_030
         * AS-IS RFC            : Z_CS_MT_WORK_RESULT_CANCEL
         * New I/F              : ZCRM_CS_WORK_TIME_CANCEL
         * Description          : 출동 수리-서비스요원 출발/도착 취소
         * KeyValue             : X
         * NOT NULL             : X
     */   

    /** REQUEST 
      */     
        public class IF_CSPLUS_030_Req { 
            public IF_CSPLUS_030_Req(){
                this.I_ZCRMS0016 = new IF_CSPLUS_030_Req_I_ZCRMS0016(); 
            }
            @AuraEnabled public String I_FLAG {get;set;} // ? A:출발 B:도착 C: 출빌&도착
    
            @AuraEnabled public IF_CSPLUS_030_Req_I_ZCRMS0016  I_ZCRMS0016  {get;set;} 
    
        }
  
      public class IF_CSPLUS_030_Req_I_ZCRMS0016  {
        public IF_CSPLUS_030_Req_I_ZCRMS0016(){} 
        @AuraEnabled public String AUFNR {get;set;} // ? Order Number
        @AuraEnabled public String SEQNO {get;set;} // ? Order Number Sequence
        @AuraEnabled public String PERNR {get;set;} // ? Personnel number
        }
  
  
    /** RESPONSE 
      */             
      public class IF_CSPLUS_030_Res { 
        public IF_CSPLUS_030_Res(){
            this.O_RETURN = new IF_CSPLUS_030_Res_O_RETURN();
            this.T_O_LIST = new List<IF_CSPLUS_030_Res_T_O_LIST>();
        }
        @AuraEnabled public IF_CSPLUS_030_Res_O_RETURN O_RETURN {get;set;} 
        @AuraEnabled public List<IF_CSPLUS_030_Res_T_O_LIST> T_O_LIST {get;set;} 
       }
  
      public class IF_CSPLUS_030_Res_O_RETURN { 
        public IF_CSPLUS_030_Res_O_RETURN(){}
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
  
       }
  
      public class IF_CSPLUS_030_Res_T_O_LIST {
        public IF_CSPLUS_030_Res_T_O_LIST(){}
        @AuraEnabled public String AUFNR   {get;set;} // ? Order Number
        @AuraEnabled public String SEQNO   {get;set;} // ? Sequence Number
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
  
  
  

    
     

}