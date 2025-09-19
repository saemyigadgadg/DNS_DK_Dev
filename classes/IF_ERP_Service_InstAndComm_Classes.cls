public with sharing class IF_ERP_Service_InstAndComm_Classes {
    public IF_ERP_Service_InstAndComm_Classes() {}

/** IF-SERVICE-045
    */  
    /**
         * Apex Class           : IF_ERP_Service_InstAndComm
         * Wrapper Class        : IF_ERP_Service_InstAndComm_Classes
         * Wrapper Name         : IF-SERVICE-045
         * SFDC interface Id    : IF_SERVICE_045
         * AS-IS RFC            : Z_CS_WEB_PERIODIC_INSP_SAVE_MT
         * New I/F              : ZCRM_CS_WEB_PERIODIC_SAVE_MT
         * Description          : 설치/시운전 내역 생성-설치/시운전 완료 후 설치/시운전 리포트 작성 발송
         * KeyValue             : DESC -> IF_DESC
         * NOT NULL             : X
     */            
    /** REQUEST 
      */
        public class IF_SERVICE_045_Req { 
            public IF_SERVICE_045_Req(){
                this.I_SEL  = new IF_SERVICE_045_Req_I_SEL();
                this.I_INFO = new IF_SERVICE_045_Req_I_INFO();
                this.I_COS  = new IF_SERVICE_045_Req_I_COS();
                this.I_OPTM = new IF_SERVICE_045_Req_I_OPTM();
                this.I_CST_PRP = new IF_SERVICE_045_Req_I_CST_PRP();
                this.T_INSPEC  = new List<IF_SERVICE_045_Req_T_INSPEC>();          
                this.T_DEL     = new List<IF_SERVICE_045_Req_T_DEL>();            
                this.T_TMP     = new List<IF_SERVICE_045_Req_T_TMP>();            
                this.T_MOTION  = new List<IF_SERVICE_045_Req_T_MOTION>();          
                this.T_CODE_INFO = new List<IF_SERVICE_045_Req_T_CODE_INFO>();                         
            }
            @AuraEnabled public String I_UNAME  {get;set;} // ? User Name
            @AuraEnabled public String I_COUNSEL {get;set;} // ? 
            @AuraEnabled public String I_CONF   {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String I_HECARE {get;set;} // ? He care1612 check
            
            @AuraEnabled public String I_WERKS  {get;set;} // ? Plant Table for National (Centrally Agreed) Contracts
            @AuraEnabled public String I_ARBPL  {get;set;} // ? Work center

    
            @AuraEnabled public IF_SERVICE_045_Req_I_SEL I_SEL {get;set;} 
            @AuraEnabled public IF_SERVICE_045_Req_I_INFO I_INFO {get;set;} 
            @AuraEnabled public IF_SERVICE_045_Req_I_COS I_COS {get;set;} 
            @AuraEnabled public IF_SERVICE_045_Req_I_OPTM I_OPTM {get;set;} 
            @AuraEnabled public IF_SERVICE_045_Req_I_CST_PRP I_CST_PRP {get;set;} 
            @AuraEnabled public List<IF_SERVICE_045_Req_T_INSPEC> T_INSPEC {get;set;} 
            @AuraEnabled public List<IF_SERVICE_045_Req_T_DEL> T_DEL {get;set;} 
            @AuraEnabled public List<IF_SERVICE_045_Req_T_TMP> T_TMP {get;set;} 
            @AuraEnabled public List<IF_SERVICE_045_Req_T_MOTION> T_MOTION {get;set;} 
            @AuraEnabled public List<IF_SERVICE_045_Req_T_CODE_INFO> T_CODE_INFO {get;set;} 
    
            }
    
            public class IF_SERVICE_045_Req_I_SEL { 
                public IF_SERVICE_045_Req_I_SEL(){}
                @AuraEnabled public String AUFNR    {get;set;} // ? Order Number
                @AuraEnabled public String EQUNR    {get;set;} // ? Equipment Number
                @AuraEnabled public String TYPBZ    {get;set;} // ? Manufacturer model number
                @AuraEnabled public String SERNR    {get;set;} // ? Serial number
                @AuraEnabled public String INSPECTION_TP {get;set;} // ? Inspection Type
        
                @AuraEnabled public String DEALER   {get;set;} // ? Dealer(Work Center)
                @AuraEnabled public String DEALER_NM {get;set;} // ? Short description
                @AuraEnabled public String INBDT    {get;set;} // ? Start-up Date of the Technical Object
                @AuraEnabled public String INSPN_DT {get;set;} // ? Inspection date
                @AuraEnabled public String WORK_PLACE {get;set;} // ? Working place
        
                @AuraEnabled public String WORK_CONTENTS {get;set;} // ? Working contents
                @AuraEnabled public String CONF_TEXT {get;set;} // ? Confirmation text
                @AuraEnabled public String RUECK    {get;set;} // ? Completion confirmation number for the operation
                @AuraEnabled public String RMZHL    {get;set;} // ? Confirmation counter
                @AuraEnabled public String NAME1    {get;set;} // ? Name 1
        
                @AuraEnabled public String TELF1    {get;set;} // ? First telephone number
                @AuraEnabled public String WO_NAME1 {get;set;} // ? Name 1
                @AuraEnabled public String WO_TELF1 {get;set;} // ? First telephone number
        
            }
    
        public class IF_SERVICE_045_Req_I_INFO { 
            public IF_SERVICE_045_Req_I_INFO(){}

            @AuraEnabled public String AUFNR {get;set;} // ? Order Number
            @AuraEnabled public String AUART {get;set;} // ? Order Type
            @AuraEnabled public String ORDER_TYPE_TXT {get;set;} // ? Short Text
            @AuraEnabled public String QMNUM {get;set;} // ? Notification No
            @AuraEnabled public String ILART {get;set;} // ? Maintenance activity type
    
            @AuraEnabled public String DMACTTYPE_TXT {get;set;} // ? Description of maintenance activity type
            @AuraEnabled public String QMDAT {get;set;} // ? Date of Notification
            @AuraEnabled public String GSTRP {get;set;} // ? Basic start date
            @AuraEnabled public String LTRMN {get;set;} // ? Required End Date
            @AuraEnabled public String QMTXT {get;set;} // ? Short Text
    
            @AuraEnabled public String TXTQM {get;set;} // ? Short Text for Coding
            @AuraEnabled public String EQUNR {get;set;} // ? Equipment Number
            @AuraEnabled public String MATNR {get;set;} // ? Material Number
            @AuraEnabled public String TYPBZ {get;set;} // ? Manufacturer model number
            @AuraEnabled public String SERNR {get;set;} // ? Serial number
    
            @AuraEnabled public String INBDT {get;set;} // ? Start-up Date of the Technical Object
            @AuraEnabled public String RBNR  {get;set;} // ? Catalog Profile
            @AuraEnabled public String IDATE {get;set;} // ? Date of the Measurement
            @AuraEnabled public String STAND_WE {get;set;} // ? Current Warranty Counter Reading
            @AuraEnabled public String MDOCM {get;set;} // ? Measurement Document
    
            @AuraEnabled public String KUNNR {get;set;} // ? Customer Number 1
            @AuraEnabled public String NAME  {get;set;} // ? Name 1
            @AuraEnabled public String TELEPHONE {get;set;} // ? First telephone number
            @AuraEnabled public String REP_NAME {get;set;} // ? Name of Representative
            @AuraEnabled public String TAX_NO_2 {get;set;} // ? Tax Number 2
    
            @AuraEnabled public String ABCKZ {get;set;} // ? ABC indicator for technical object
            @AuraEnabled public String BEBER {get;set;} // ? Plant section
            @AuraEnabled public String CONTACT_TYPE {get;set;} // ? Contact type (차주,운전기사,관리자,기타)
            @AuraEnabled public String CONTACT_NAME {get;set;} // ? Name 1
            @AuraEnabled public String CONTACT_MOBILE {get;set;} // ? First Mobile Telephone No.: Dialing Code + Number
    
            @AuraEnabled public String CONTACT_TEL {get;set;} // ? First telephone number
            @AuraEnabled public String PART_PRICE {get;set;} // ? Condition value
            @AuraEnabled public String LABOR_PRICE {get;set;} // ? Condition value
            @AuraEnabled public String TOT_AMOUNT {get;set;} // ? Condition value
            @AuraEnabled public String DISCOUNT_AMT {get;set;} // ? Condition value
    
            @AuraEnabled public String WAERS {get;set;} // ? Currency Key
            @AuraEnabled public String VBELN {get;set;} // ? Sales Document
            @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERZET {get;set;} // ? Entry time
    
            @AuraEnabled public String AEDAT {get;set;} // ? Changed On
            @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
            @AuraEnabled public String ARBPL {get;set;} // ? Work center
            @AuraEnabled public String WTY_TYPE {get;set;} // ? Under or Out of warranty
    
            @AuraEnabled public String NOTIFTIME {get;set;} // ? Time of Notification
            @AuraEnabled public String MOBILE {get;set;} // ? Search Term 2
            @AuraEnabled public String LTRUR {get;set;} // ? Requested End Time
            @AuraEnabled public String ISMNW {get;set;} // ? Actual work
            @AuraEnabled public String ZDIST {get;set;} // ? Distance
    
            @AuraEnabled public String OTHER_COST {get;set;} // ? Other cost(Request)
            @AuraEnabled public String ZENGNO {get;set;} // ? Engin No
            @AuraEnabled public String USNAM {get;set;} // ? User name of the person responsible in change document
            @AuraEnabled public String UDATE {get;set;} // ? Creation date of the change document
            @AuraEnabled public String UTIME {get;set;} // ? Time changed
    
    
        }
    
        public class IF_SERVICE_045_Req_I_COS { 
            public IF_SERVICE_045_Req_I_COS(){}

            @AuraEnabled public String AUFNR {get;set;} // ? Order Number
            @AuraEnabled public String COMPANY {get;set;} // ? Responsible person name
            @AuraEnabled public String SRV_NM {get;set;} // ? Customer Name(CS)
            @AuraEnabled public String TEL_NO {get;set;} // ? Second telephone number
            @AuraEnabled public String FAX_NO {get;set;} // ? SAPoffice: User layout set name for faxing
    
            @AuraEnabled public String MOBILE_NO {get;set;} // ? Second telephone number
            @AuraEnabled public String EMAIL {get;set;} // ? E-mail Address
            @AuraEnabled public String ADDR  {get;set;} // ? Identifier for sub-structurecontaining ZAC address structure
            @AuraEnabled public String ADDR2 {get;set;} // ? Identifier for sub-structurecontaining ZAC address structure
            @AuraEnabled public String EQUNR {get;set;} // ? Equipment Number
    
    
        }
    
        public class IF_SERVICE_045_Req_I_OPTM { 
            public IF_SERVICE_045_Req_I_OPTM(){}

            @AuraEnabled public String TEMPHR  {get;set;} // ? 
            @AuraEnabled public String CHK_FLAG {get;set;} // ? 
            @AuraEnabled public String MAINHR  {get;set;} // ? 
            @AuraEnabled public String OPTNHR1 {get;set;} // ? 
            @AuraEnabled public String OPTNHR2 {get;set;} // ? 
    
            @AuraEnabled public String OPTNHR3 {get;set;} // ? 
            @AuraEnabled public String OPTNHR4 {get;set;} // ? 
            @AuraEnabled public String OPTNHR5 {get;set;} // ? 
            @AuraEnabled public String HDAYWDV {get;set;} // ? 
            @AuraEnabled public String TOTALHR {get;set;} // ? 
    
            @AuraEnabled public String OPTCHK1 {get;set;} // ? Fense/APC Cover
            @AuraEnabled public String OPTCHK2 {get;set;} // ? Semi Splash Guard
            @AuraEnabled public String OPTCHK3 {get;set;} // ? 90 Tools 이상
            @AuraEnabled public String OPTCHK4 {get;set;} // ? 6PMG
            @AuraEnabled public String OPTCHK5 {get;set;} // ? AAC(6st 이상)
    
            @AuraEnabled public String ETC_HR  {get;set;} // ? Hours ETC
            @AuraEnabled public String ETC_TXT {get;set;} // ? Text ETC
    
        }
    
        public class IF_SERVICE_045_Req_I_CST_PRP { 
            public IF_SERVICE_045_Req_I_CST_PRP(){}

            @AuraEnabled public String WERKS {get;set;} // ? Plant
            @AuraEnabled public String AUFNR {get;set;} // ? Order Number
            @AuraEnabled public String EQUNR {get;set;} // ? Equipment Number
            @AuraEnabled public String ZELEC {get;set;} // ? Elec.
            @AuraEnabled public String ZLUB  {get;set;} // ? Lub.
    
            @AuraEnabled public String ZHYD  {get;set;} // ? Hyd.
            @AuraEnabled public String ZPNEU {get;set;} // ? Pneu.
            @AuraEnabled public String ZLAYOUT {get;set;} // ? Layout
            @AuraEnabled public String ZFOUND {get;set;} // ? Foundation
            @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
    
            @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERZET {get;set;} // ? Entry time
            @AuraEnabled public String AEDAT {get;set;} // ? Changed On
            @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
    
    
        }
    
        public class IF_SERVICE_045_Req_T_INSPEC { 
            public IF_SERVICE_045_Req_T_INSPEC(){}

            @AuraEnabled public String CK   {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String SECTN {get;set;} // ? Inspection Section
            @AuraEnabled public String INSP_CONTENTS {get;set;} // ? Inspection Contents
            @AuraEnabled public String FAULTY {get;set;} // ? Faulty
            @AuraEnabled public String RSLT {get;set;} // ? Result
    
            @AuraEnabled public String ENABLE {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String REQUIRE {get;set;} // ? WebDynpro:State
            @AuraEnabled public String SEQ  {get;set;} // ? Inspection Section Sequence
            @AuraEnabled public String SEQ2 {get;set;} // ? Inspection Contents Seq.
    
        }
    
        public class IF_SERVICE_045_Req_T_DEL { 
            public IF_SERVICE_045_Req_T_DEL(){}

            @AuraEnabled public String DOCNO    {get;set;} // ? Document number
            @AuraEnabled public String FILENAME {get;set;} // ? 
    
        }
    
        public class IF_SERVICE_045_Req_T_TMP { 
            public IF_SERVICE_045_Req_T_TMP(){}

            @AuraEnabled public String FILENAME  {get;set;} // ?                                                             
            @AuraEnabled public String IF_DESC      {get;set;} // ?                                                             
            @AuraEnabled public String EVISEQX   {get;set;} // ? Sequence
            @AuraEnabled public String LINE      {get;set;} // ? Table analysis: For external table data up to length 1024
            @AuraEnabled public String FILE_SIZE {get;set;} // ? File Size
    
    
        }
    
        public class IF_SERVICE_045_Req_T_MOTION {
            public  IF_SERVICE_045_Req_T_MOTION(){}
            @AuraEnabled public String AUFNR {get;set;} // ? Order Number
            @AuraEnabled public String RUECK {get;set;} // ? Completion confirmation number for the operation
            @AuraEnabled public String WORKNO {get;set;} // ? Working time count
            @AuraEnabled public String SEQNO {get;set;} // ? Sequential no
            @AuraEnabled public String PERNR {get;set;} // ? Personnel number
    
            @AuraEnabled public String SVCMAN_NAME {get;set;} // ? Name
            @AuraEnabled public String ISDD  {get;set;} // ? Confirmed date for start of execution
            @AuraEnabled public String ISDZ  {get;set;} // ? Confirmed time for 'Execution start'
            @AuraEnabled public String AUSBS {get;set;} // ? End of Malfunction (Date)
            @AuraEnabled public String AUZTB {get;set;} // ? End of Malfunction (Time)
    
            @AuraEnabled public String ISMNW {get;set;} // ? Actual work
            @AuraEnabled public String ISMNW_PDK {get;set;} // ? Actual work
            @AuraEnabled public String HOL_CHK {get;set;} // ? Holiday Flag
            @AuraEnabled public String OT_CHK {get;set;} // ? Overtime Flag
            @AuraEnabled public String LTXA1 {get;set;} // ? Active Text
    
            @AuraEnabled public String RMZHL {get;set;} // ? Confirmation counter
            @AuraEnabled public String ISMNE {get;set;} // ? Unit for work
            @AuraEnabled public String ZFLAG {get;set;} // ? 정산 유무('X':정산)
            @AuraEnabled public String TEMPHR {get;set;} // ? Temporary install hour(MT BG use)
            @AuraEnabled public String CHK_FLAG {get;set;} // ? Temporary install hour check flag
    
            @AuraEnabled public String MAINHR {get;set;} // ? Main install hour(MT BG use)
            @AuraEnabled public String OPTNHR1 {get;set;} // ? Option install hour1(MT BG use)
            @AuraEnabled public String OPTNHR2 {get;set;} // ? Option install hour2(MT BG use)
            @AuraEnabled public String OPTNHR3 {get;set;} // ? Option install hour3(MT BG use)
            @AuraEnabled public String OPTNHR4 {get;set;} // ? Option install hour4(MT BG use)
    
            @AuraEnabled public String OPTNHR5 {get;set;} // ? Option install hour5(MT BG use)
            @AuraEnabled public String HDAYWDV {get;set;} // ? Holiday work division(MT BG use)
            @AuraEnabled public String OPTCHK1 {get;set;} // ? Fense/APC Cover
            @AuraEnabled public String OPTCHK2 {get;set;} // ? Semi Splash Guard
            @AuraEnabled public String OPTCHK3 {get;set;} // ? 90 Tools 이상
    
            @AuraEnabled public String OPTCHK4 {get;set;} // ? 6PMG
            @AuraEnabled public String OPTCHK5 {get;set;} // ? AAC(6st 이상)
            @AuraEnabled public String ETC_HR {get;set;} // ? Hours ETC
            @AuraEnabled public String ETC_TXT {get;set;} // ? Text ETC
            @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
    
            @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERZET {get;set;} // ? Entry time
            @AuraEnabled public String AEDAT {get;set;} // ? Changed On
            @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
    
            @AuraEnabled public String WERKS {get;set;} // ? Plant
            @AuraEnabled public String CONF  {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String GRUND {get;set;} // ? Reason for Variance
            @AuraEnabled public String WORKCD {get;set;} // ? Work Code
            @AuraEnabled public String EXRSN {get;set;} // ? 초과사유
    
    
        }
    
        public class IF_SERVICE_045_Req_T_CODE_INFO { 
            public  IF_SERVICE_045_Req_T_CODE_INFO(){}

            @AuraEnabled public String WERKS {get;set;} // ? Plant
            @AuraEnabled public String AUFNR {get;set;} // ? Order Number
            @AuraEnabled public String EQUNR {get;set;} // ? Equipment Number
            @AuraEnabled public String ZSEQ  {get;set;} // ? Serial Sequence No
            @AuraEnabled public String ZCD1  {get;set;} // ? Code CD
    
            @AuraEnabled public String ZSEQ1 {get;set;} // ? Code Seq.
            @AuraEnabled public String ZCD2  {get;set;} // ? Code CD
            @AuraEnabled public String ZSEQ2 {get;set;} // ? Code Seq.
            @AuraEnabled public String ZCD3  {get;set;} // ? Code CD
            @AuraEnabled public String ZSEQ3 {get;set;} // ? Code Seq.
    
            @AuraEnabled public String ZISE  {get;set;} // ? Installation Error Description
            @AuraEnabled public String ZISR  {get;set;} // ? Installation Error Result
            @AuraEnabled public String ZECT  {get;set;} // ? ETC
            @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
    
            @AuraEnabled public String ERZET {get;set;} // ? Entry time
            @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEDAT {get;set;} // ? Changed On
            @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
    
        }

        
    /** RESPONSE 
     */  
      public class IF_SERVICE_045_Res { 
        public  IF_SERVICE_045_Res(){
            this.O_RETURN = new IF_SERVICE_045_Res_O_RETURN();
            this.T_MOTION = new List<IF_SERVICE_045_Res_T_MOTION>();
            this.T_DEL    = new List<IF_SERVICE_045_Res_T_DEL>();
            this.T_TMP    = new List<IF_SERVICE_045_Res_T_TMP>();
            this.T_RETURN = new List<IF_SERVICE_045_Res_T_RETURN>();
        }

        @AuraEnabled public String O_DEL_MSG {get;set;} // ? Message Text
        @AuraEnabled public String O_UPD_MSG {get;set;} // ? Message Text
        @AuraEnabled public String O_TIME {get;set;} // ? Single-Character Indicator
  
        @AuraEnabled public IF_SERVICE_045_Res_O_RETURN O_RETURN {get;set;} 
        @AuraEnabled public List<IF_SERVICE_045_Res_T_MOTION> T_MOTION {get;set;} 
        @AuraEnabled public List<IF_SERVICE_045_Res_T_DEL> T_DEL {get;set;} 
        @AuraEnabled public List<IF_SERVICE_045_Res_T_TMP> T_TMP {get;set;} 
        @AuraEnabled public List<IF_SERVICE_045_Res_T_RETURN> T_RETURN {get;set;} 
  
        }
  
      public class IF_SERVICE_045_Res_O_RETURN { 
        public IF_SERVICE_045_Res_O_RETURN(){}
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
  
        }
  
      public class IF_SERVICE_045_Res_T_MOTION { 
        public IF_SERVICE_045_Res_T_MOTION(){}

        @AuraEnabled public String AUFNR {get;set;} // ? Order Number
        @AuraEnabled public String RUECK {get;set;} // ? Completion confirmation number for the operation
        @AuraEnabled public String WORKNO {get;set;} // ? Working time count
        @AuraEnabled public String SEQNO {get;set;} // ? Sequential no
        @AuraEnabled public String PERNR {get;set;} // ? Personnel number
  
        @AuraEnabled public String SVCMAN_NAME {get;set;} // ? Name
        @AuraEnabled public String ISDD  {get;set;} // ? Confirmed date for start of execution
        @AuraEnabled public String ISDZ  {get;set;} // ? Confirmed time for 'Execution start'
        @AuraEnabled public String AUSBS {get;set;} // ? End of Malfunction (Date)
        @AuraEnabled public String AUZTB {get;set;} // ? End of Malfunction (Time)
  
        @AuraEnabled public String ISMNW {get;set;} // ? Actual work
        @AuraEnabled public String ISMNW_PDK {get;set;} // ? Actual work
        @AuraEnabled public String HOL_CHK {get;set;} // ? Holiday Flag
        @AuraEnabled public String OT_CHK {get;set;} // ? Overtime Flag
        @AuraEnabled public String LTXA1 {get;set;} // ? Active Text
  
        @AuraEnabled public String RMZHL {get;set;} // ? Confirmation counter
        @AuraEnabled public String ISMNE {get;set;} // ? Unit for work
        @AuraEnabled public String ZFLAG {get;set;} // ? 정산 유무('X':정산)
        @AuraEnabled public String TEMPHR {get;set;} // ? Temporary install hour(MT BG use)
        @AuraEnabled public String CHK_FLAG {get;set;} // ? Temporary install hour check flag
  
        @AuraEnabled public String MAINHR {get;set;} // ? Main install hour(MT BG use)
        @AuraEnabled public String OPTNHR1 {get;set;} // ? Option install hour1(MT BG use)
        @AuraEnabled public String OPTNHR2 {get;set;} // ? Option install hour2(MT BG use)
        @AuraEnabled public String OPTNHR3 {get;set;} // ? Option install hour3(MT BG use)
        @AuraEnabled public String OPTNHR4 {get;set;} // ? Option install hour4(MT BG use)
  
        @AuraEnabled public String OPTNHR5 {get;set;} // ? Option install hour5(MT BG use)
        @AuraEnabled public String HDAYWDV {get;set;} // ? Holiday work division(MT BG use)
        @AuraEnabled public String OPTCHK1 {get;set;} // ? Fense/APC Cover
        @AuraEnabled public String OPTCHK2 {get;set;} // ? Semi Splash Guard
        @AuraEnabled public String OPTCHK3 {get;set;} // ? 90 Tools 이상
  
        @AuraEnabled public String OPTCHK4 {get;set;} // ? 6PMG
        @AuraEnabled public String OPTCHK5 {get;set;} // ? AAC(6st 이상)
        @AuraEnabled public String ETC_HR {get;set;} // ? Hours ETC
        @AuraEnabled public String ETC_TXT {get;set;} // ? Text ETC
        @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
  
        @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
        @AuraEnabled public String ERZET {get;set;} // ? Entry time
        @AuraEnabled public String AEDAT {get;set;} // ? Changed On
        @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
        @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
  
        @AuraEnabled public String WERKS {get;set;} // ? Plant
        @AuraEnabled public String CONF  {get;set;} // ? Single-Character Indicator
        @AuraEnabled public String GRUND {get;set;} // ? Reason for Variance
        @AuraEnabled public String WORKCD {get;set;} // ? Work Code
        @AuraEnabled public String EXRSN {get;set;} // ? 초과사유
  
  
        }
  
      public class IF_SERVICE_045_Res_T_DEL {
        public IF_SERVICE_045_Res_T_DEL(){}

        @AuraEnabled public String DOCNO    {get;set;} // ? Document number
        @AuraEnabled public String FILENAME {get;set;} // ? 
  
        }
  
      public class IF_SERVICE_045_Res_T_TMP {
        public IF_SERVICE_045_Res_T_TMP(){}

        @AuraEnabled public String FILENAME  {get;set;} // ?                                                             
        @AuraEnabled public String IF_DESC      {get;set;} // ?                                                             
        @AuraEnabled public String EVISEQX   {get;set;} // ? Sequence
        @AuraEnabled public String LINE      {get;set;} // ? Table analysis: For external table data up to length 1024
        @AuraEnabled public String FILE_SIZE {get;set;} // ? File Size
  
  
        }
  
      public class IF_SERVICE_045_Res_T_RETURN {
        public IF_SERVICE_045_Res_T_RETURN(){}

        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
  
        }
      
}