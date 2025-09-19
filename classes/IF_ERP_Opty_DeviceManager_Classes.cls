public with sharing class IF_ERP_Opty_DeviceManager_Classes {
    public IF_ERP_Opty_DeviceManager_Classes() {}


/** IF_CSPLUS_029
    */  
    /**
         * Apex Class           : IF_ERP_Opty_DeviceManager
         * Wrapper Class        : IF_ERP_Opty_DeviceManager_Classes
         * Wrapper Name         : IF_OPTY_001
         * SFDC interface Id    : IF-OPTY-001
         * AS-IS RFC            : 	
         * New I/F              : ZCRM_SD_RESPONSIBLE_4_MODEL
         * Description          : 기종별 담당자 정보 연동
         * KeyValue             : X
         * NOT NULL             : X
     */            
    /** REQUEST 
      */    
        public class IF_OPTY_001_Req { 
            public IF_OPTY_001_Req(){
                this.I_T_SATNR = new List<IF_OPTY_001_Req_I_T_SATNR>(); 
            }
            @AuraEnabled public String I_CA_PRMD {get;set;} // ? [job category]PROD.  Management Dept.
            @AuraEnabled public String I_CA_RNDD {get;set;} // ? [job category]R&D Dept.
            @AuraEnabled public String I_CA_MNFE {get;set;} // ? [job category]Manufacturing Eng.
            @AuraEnabled public String I_WERKS {get;set;} // ? Plant
    
            @AuraEnabled public List<IF_OPTY_001_Req_I_T_SATNR> I_T_SATNR {get;set;} 
    
            }
    
        public class IF_OPTY_001_Req_I_T_SATNR {
            public IF_OPTY_001_Req_I_T_SATNR(){} 
            @AuraEnabled public String SIGN {get;set;} // ? ABAP: ID: I/E (include/exclude values)
            @AuraEnabled public String OPTION {get;set;} // ? ABAP: Selection option (EQ/BT/CP/...)
            @AuraEnabled public String LOW  {get;set;} // ? 'Generic' SELECT-OPTION for Dynamic Selections
            @AuraEnabled public String HIGH {get;set;} // ? 'Generic' SELECT-OPTION for Dynamic Selections
    
            }
  
     /** RESPONSE 
      */          
        public class IF_OPTY_001_Res {
            public IF_OPTY_001_Res(){
                this.O_RETURN       = new IF_OPTY_001_Res_O_RETURN();
                this.T_ZCRMS0001    = new List<IF_OPTY_001_Res_T_ZCRMS0001>();
                this.T_ZCRMS0002    = new List<IF_OPTY_001_Res_T_ZCRMS0002>();
                this.T_ZCRMS0003    = new List<IF_OPTY_001_Res_T_ZCRMS0003>();
            } 
            @AuraEnabled public IF_OPTY_001_Res_O_RETURN O_RETURN {get;set;} 
            @AuraEnabled public List<IF_OPTY_001_Res_T_ZCRMS0001> T_ZCRMS0001 {get;set;} 
            @AuraEnabled public List<IF_OPTY_001_Res_T_ZCRMS0002> T_ZCRMS0002 {get;set;} 
            @AuraEnabled public List<IF_OPTY_001_Res_T_ZCRMS0003> T_ZCRMS0003 {get;set;} 
        }
    
        public class IF_OPTY_001_Res_O_RETURN { 
            public IF_OPTY_001_Res_O_RETURN(){}
            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
    
        }
    
        public class IF_OPTY_001_Res_T_ZCRMS0001 {
            public IF_OPTY_001_Res_T_ZCRMS0001(){}
            @AuraEnabled public String WERKS {get;set;} // ? Plant
            @AuraEnabled public String SATNR {get;set;} // ? Cross-Plant Configurable Material
            @AuraEnabled public String MAKTX {get;set;} // ? Material Description (Short Text)
            @AuraEnabled public String VERID {get;set;} // ? Production Version
            @AuraEnabled public String TEXT1 {get;set;} // ? Short text on the production version
    
            @AuraEnabled public String UNAME {get;set;} // ? User Name in User Master Record
            @AuraEnabled public String EMP_NAME {get;set;} // ? Name
            @AuraEnabled public String BLOCK {get;set;} // ? Indic.: Object blocked
    
            }
    
        public class IF_OPTY_001_Res_T_ZCRMS0002 { 
        @AuraEnabled public String WERKS     {get;set;} // ? Plant
        @AuraEnabled public String SATNR     {get;set;} // ? Cross-Plant Configurable Material
        @AuraEnabled public String MAKTX     {get;set;} // ? Material Description (Short Text)
        @AuraEnabled public String EMPNO_RD1 {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RD1 {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RD1 {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RD1 {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RD1 {get;set;} // ? 부서장
        @AuraEnabled public String EMPNO_RD2 {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RD2 {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RD2 {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RD2 {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RD2 {get;set;} // ? 부서장
        @AuraEnabled public String EMPNO_RD3 {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RD3 {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RD3 {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RD3 {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RD3 {get;set;} // ? 부서장
        @AuraEnabled public String EMPNO_RD4 {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RD4 {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RD4 {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RD4 {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RD4 {get;set;} // ? 부서장
        @AuraEnabled public String EMPNO_RD5 {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RD5 {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RD5 {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RD5 {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RD5 {get;set;} // ? 부서장
        @AuraEnabled public String EMPNO_RD6 {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RD6 {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RD6 {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RD6 {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RD6 {get;set;} // ? 부서장
        @AuraEnabled public String EMPNO_RD7 {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RD7 {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RD7 {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RD7 {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RD7 {get;set;} // ? 부서장
        @AuraEnabled public String EMPNO_RD8 {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RD8 {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RD8 {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RD8 {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RD8 {get;set;} // ? 부서장
        @AuraEnabled public String EMPNO_RDA {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RDA {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RDA {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RDA {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RDA {get;set;} // ? 부서장
        @AuraEnabled public String EMPNO_RDB {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RDB {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RDB {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RDB {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RDB {get;set;} // ? 부서장
        @AuraEnabled public String EMPNO_RDC {get;set;} // ? User Name in User Master Record
        @AuraEnabled public String EMPNM_RDC {get;set;} // ? Employee Name
        @AuraEnabled public String EPMAIL_RDC {get;set;} // ? E-Mail Address
        @AuraEnabled public String DEPNM_RDC {get;set;} // ? 팀명
        @AuraEnabled public String DEPHD_RDC {get;set;} // ? 부서장
        @AuraEnabled public String DEPNO_RD1 {get;set;} // ?1.3 v
        @AuraEnabled public String DPMAIL_RD1{get;set;} // ?1.3 v       
        @AuraEnabled public String DEPNO_RD2 {get;set;} // ?1.3 v
        @AuraEnabled public String DPMAIL_RD2{get;set;} // ?1.3 v       

        }
        public class IF_OPTY_001_Res_T_ZCRMS0003 {
            public IF_OPTY_001_Res_T_ZCRMS0003(){}

            @AuraEnabled public String WERKS     {get;set;} // ? Plant
            @AuraEnabled public String SATNR     {get;set;} // ? Cross-Plant Configurable Material
            @AuraEnabled public String MAKTX     {get;set;} // ? Material Description (Short Text)
            @AuraEnabled public String STLAN     {get;set;} // ? BOM Usage
            @AuraEnabled public String MFGNM     {get;set;} // ? Manufacturer name
    
            @AuraEnabled public String EMP_NAME  {get;set;} // ? Name
            @AuraEnabled public String MFGNM2    {get;set;} // ? Manufacturer name
            @AuraEnabled public String EMP_NAME2 {get;set;} // ? Name
            @AuraEnabled public String MFGNM3    {get;set;} // ? Manufacturer name
            @AuraEnabled public String EMP_NAME3 {get;set;} // ? Name
        }
  
  
  

}