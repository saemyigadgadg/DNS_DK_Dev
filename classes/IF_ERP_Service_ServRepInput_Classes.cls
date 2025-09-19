public with sharing class IF_ERP_Service_ServRepInput_Classes {
    public IF_ERP_Service_ServRepInput_Classes() {}


/** IF-SERVICE-046
    */  
    /**
         * Apex Class           : IF_ERP_Service_ServRepInput
         * Wrapper Class        : IF_ERP_Service_ServRepInput_Classes
         * Wrapper Name         : IF_SERVICE_046
         * SFDC interface Id    : IF-SERVICE-046
         * AS-IS RFC            : Z_CS_WEB_JOB_RESULT_CONFIRM
         * New I/F              : ZCRM_CS_WEB_JOB_RESULT_CONFIRM
         * Description          : 서비스리포트 생성-출동 수리 후 서비스 리포트 작업 결과 ERP 전송
         * KeyValue             : DESC -> IF_DESC
         * NOT NULL             : X
     */            
    /** REQUEST 
      */    
        public class IF_SERVICE_046_Req { 
            public IF_SERVICE_046_Req(){
                this.I_USERINFO = new IF_SERVICE_046_Req_I_USERINFO();
                this.I_INFO = new IF_SERVICE_046_Req_I_INFO();         
                this.I_SUB  = new IF_SERVICE_046_Req_I_SUB();      
                this.I_CODE = new IF_SERVICE_046_Req_I_CODE();     
                this.I_HISTORY  = new IF_SERVICE_046_Req_I_HISTORY();
                this.T_MOTION = new List<IF_SERVICE_046_Req_T_MOTION>();
                this.T_MATERIAL = new List<IF_SERVICE_046_Req_T_MATERIAL>();
                this.T_DOC = new List<IF_SERVICE_046_Req_T_DOC>();
                this.T_DEL = new List<IF_SERVICE_046_Req_T_DEL>();
                this.T_TMP = new List<IF_SERVICE_046_Req_T_TMP>();
                this.T_DEL_SR = new List<IF_SERVICE_046_Req_T_DEL_SR>();
                this.T_TMP_SR = new List<IF_SERVICE_046_Req_T_TMP_SR>();
                // this.T_CONSIGN = new List<IF_SERVICE_046_Req_T_CONSIGN>();                
            }

            // 25.02.20 @AuraEnabled public String I_UNAME {get;set;} // ? User Name
            @AuraEnabled public String I_TIME  {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String I_NOT_DELIVERY {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String I_TEXT  {get;set;} // ? Long data part: 5000 bytes
            @AuraEnabled public String I_DESCRIPT {get;set;} // ? Descript
            @AuraEnabled public String I_CAUSE {get;set;} // ? Cause
            @AuraEnabled public String I_ACTIVITY {get;set;} // ? Activity
            @AuraEnabled public String I_CR    {get;set;} // ? IncompleteItem/Customer Request
            @AuraEnabled public String I_MANHOUR_REASON {get;set;} // ? 표준공수 초과 사유
            @AuraEnabled public String I_EXRSN {get;set;} // ? 표준공수 초과 사유(New)
    
    
            @AuraEnabled public IF_SERVICE_046_Req_I_USERINFO   I_USERINFO {get;set;}
            @AuraEnabled public IF_SERVICE_046_Req_I_INFO       I_INFO {get;set;} 
            @AuraEnabled public IF_SERVICE_046_Req_I_SUB        I_SUB {get;set;} 
            @AuraEnabled public IF_SERVICE_046_Req_I_CODE       I_CODE {get;set;} 
            @AuraEnabled public IF_SERVICE_046_Req_I_HISTORY    I_HISTORY {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Req_T_MOTION>   T_MOTION {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Req_T_MATERIAL> T_MATERIAL {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Req_T_DOC>      T_DOC {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Req_T_DEL>      T_DEL {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Req_T_TMP>      T_TMP {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Req_T_DEL_SR>   T_DEL_SR {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Req_T_TMP_SR>   T_TMP_SR {get;set;} 
            // @AuraEnabled public List<IF_SERVICE_046_Req_T_CONSIGN> T_CONSIGN {get;set;} 
        }

        public class IF_SERVICE_046_Req_I_USERINFO{
            @AuraEnabled public String BNAME  {get;set;} // ? S/F CRM User ID -> v2.0
            @AuraEnabled public String RNAME  {get;set;} // ? User Name in User Master Record -> v2.0
            @AuraEnabled public String HIER   {get;set;} // ? [SS] User Hierrchy (Portal) -> v2.0
            @AuraEnabled public String KUNNR  {get;set;} // ? Customer Number 1 -> v2.0
            @AuraEnabled public String LIFNR  {get;set;} // ? Account Number of Vendor or Creditor -> v2.0
            @AuraEnabled public String VKORG  {get;set;} // ? Sales Organization -> v2.0
            @AuraEnabled public String VTWEG  {get;set;} // ? Distribution Channel -> v2.0
            @AuraEnabled public String SPART  {get;set;} // ? Division -> v2.0
            @AuraEnabled public String WERKS  {get;set;} // ? Plant -> v2.0
            @AuraEnabled public String ARBPL  {get;set;} // ? Work center -> v2.0
            @AuraEnabled public String PARNR  {get;set;} // ? Partner -> v2.0
            @AuraEnabled public String ENAME  {get;set;} // ? Formatted Name of Employee or Applicant -> v2.0
            @AuraEnabled public String KUNN2  {get;set;} // ? Customer Number 1 -> v2.0
            @AuraEnabled public String LAND1  {get;set;} // ? Country Key -> v2.0
            @AuraEnabled public String LGORT  {get;set;} // ? Storage Location -> v2.0
            @AuraEnabled public String DF_CHK {get;set;} // ? Default Check -> v2.0
            @AuraEnabled public String CO_CHK {get;set;} // ? corporation check -> v2.0            
        }
    
        public class IF_SERVICE_046_Req_I_INFO { 
            public IF_SERVICE_046_Req_I_INFO(){}
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
    
        public class IF_SERVICE_046_Req_I_SUB { 
            public IF_SERVICE_046_Req_I_SUB(){}

            @AuraEnabled public String KEY   {get;set;} // ? Return Type
            @AuraEnabled public String VALUE {get;set;} // ? Return Type Value(Text)
        }
    
        public class IF_SERVICE_046_Req_I_CODE { 
            public IF_SERVICE_046_Req_I_CODE(){}
            @AuraEnabled public String CODE_01 {get;set;} // ? Code 1
            @AuraEnabled public String CODE_02 {get;set;} // ? Code 2
            @AuraEnabled public String CODE_03 {get;set;} // ? Code 3
            @AuraEnabled public String TEXT  {get;set;} // ? Short Text for Code (Up to 40 Characters in Length)
            @AuraEnabled public String TEXT2 {get;set;} // ? Short Text for Code (Up to 40 Characters in Length)
        }
    
        public class IF_SERVICE_046_Req_I_HISTORY { 
            public IF_SERVICE_046_Req_I_HISTORY(){}

            @AuraEnabled public String QMNUM {get;set;} // ? Notification No
            @AuraEnabled public String SEQNO {get;set;} // ? Sequence No.
            @AuraEnabled public String OTGRP {get;set;} // ? Code Group - Object Parts
            @AuraEnabled public String OTEIL {get;set;} // ? Part of Object
            @AuraEnabled public String KURZTEXT {get;set;} // ? Short Description of the Code Group
            @AuraEnabled public String FEGRP {get;set;} // ? Code Group - Problem
            @AuraEnabled public String FECOD {get;set;} // ? Problem or Damage Code
            @AuraEnabled public String TXTCDFE {get;set;} // ? Short Text for Problem or Damage Code
            @AuraEnabled public String FETXT {get;set;} // ? Notification Item Short Text
            @AuraEnabled public String SYMPTOM_ADD_TXT {get;set;} // ? Symtom Add Text
            @AuraEnabled public String URGRP {get;set;} // ? Code Group - Causes
            @AuraEnabled public String URCOD {get;set;} // ? Cause Code
            @AuraEnabled public String TXTCDUR {get;set;} // ? Short Text for Cause Code
            @AuraEnabled public String URTXT {get;set;} // ? Cause Text
            @AuraEnabled public String CAUSE_ADD_TXT {get;set;} // ? Cause Add Text
            @AuraEnabled public String MNGRP {get;set;} // ? Code Group - Activities
            @AuraEnabled public String MNCOD {get;set;} // ? Activity Code
            @AuraEnabled public String TXTCDMA {get;set;} // ? Short Text for Activity Code
            @AuraEnabled public String MATXT {get;set;} // ? Activity Text
            @AuraEnabled public String ACT_ADD_TXT {get;set;} // ? Activity Add Text
            @AuraEnabled public String FAULT_CAUSE {get;set;} // ? Fault Cause
            @AuraEnabled public String PHENO_ADD_TXT {get;set;} // ? Phenamena Text
            @AuraEnabled public String BLCOD {get;set;} // ? Cause to blame
            @AuraEnabled public String BLCOD_T {get;set;} // ? Cause to Blame Text
            @AuraEnabled public String INCLUDE {get;set;} // ? Creation & Change Date
            @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERZET {get;set;} // ? Entry time
            @AuraEnabled public String AEDAT {get;set;} // ? Changed On
            @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
            @AuraEnabled public String TXTQM {get;set;} // ? Short Text for Coding
        }
    
        public class IF_SERVICE_046_Req_T_MOTION { 
            public IF_SERVICE_046_Req_T_MOTION(){}

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
            @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERZET {get;set;} // ? Entry time
            @AuraEnabled public String AEDAT {get;set;} // ? Changed On
            @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
            @AuraEnabled public String FLAG_0060 {get;set;} // ? Flag
            @AuraEnabled public String WORKCD {get;set;} // ? Work Code
            @AuraEnabled public String EXRSN {get;set;} // ? 초과사유
        }
    
        public class IF_SERVICE_046_Req_T_MATERIAL { 
            public IF_SERVICE_046_Req_T_MATERIAL(){}

            @AuraEnabled public String AUFNR   {get;set;} // ? Order Number
            @AuraEnabled public String WORKNO  {get;set;} // ? Working time count
            @AuraEnabled public String SEQNO   {get;set;} // ? Sequential no
            @AuraEnabled public String MATNR   {get;set;} // ? Material Number for Order
            @AuraEnabled public String MEINS   {get;set;} // ? Base Unit of Measure
            @AuraEnabled public String SUPPLY_TYPE {get;set;} // ? 부품센타/대리점/정비센타
            @AuraEnabled public String CHANGE_DT {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String EBELN   {get;set;} // ? Purchasing Document Number
            @AuraEnabled public String EBELP   {get;set;} // ? Item Number of Purchasing Document
            @AuraEnabled public String MBLNR   {get;set;} // ? Number of Material Document
            @AuraEnabled public String GI_MBLNR {get;set;} // ? Good issue confirm  document
            @AuraEnabled public String LIFNR   {get;set;} // ? Account Number of Vendor or Creditor
            @AuraEnabled public String NAME1   {get;set;} // ? Name 1
            @AuraEnabled public String NETWR   {get;set;} // ? Net Order Value in PO Currency
            @AuraEnabled public String BRTWR   {get;set;} // ? Gross order value in PO currency
            @AuraEnabled public String FREIGHT {get;set;} // ? Condition value
            @AuraEnabled public String WAERS   {get;set;} // ? Currency Key
            @AuraEnabled public String BELNR   {get;set;} // ? Accounting Document Number
            @AuraEnabled public String RETURN_YN {get;set;} // ? Return Y or N
            @AuraEnabled public String ERDAT   {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String ERNAM   {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERZET   {get;set;} // ? Entry time
            @AuraEnabled public String AEDAT   {get;set;} // ? Changed On
            @AuraEnabled public String AENAM   {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEZET   {get;set;} // ? Time last change was made
            @AuraEnabled public String ITEM_CAT {get;set;} // ? Item Category (Bill of Material)
            @AuraEnabled public String RETURN_TYPE {get;set;} // ? Return Type
            @AuraEnabled public String RETURN_TEXT {get;set;} // ? Return Text
            @AuraEnabled public String PGMNG   {get;set;} // ? Total planned order quantity
            @AuraEnabled public String READ_ONLY {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String MENGE   {get;set;} // ? Quantity in Unit of Entry
            @AuraEnabled public String MENGE_GI {get;set;} // ? Quantity in Unit of Entry
            @AuraEnabled public String READ_ONLY_02 {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String READ_ONLY_03 {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String MAKTX   {get;set;} // ? Material Description (Short Text)
            @AuraEnabled public String CAUSE_PRT {get;set;} // ? Cause part
            @AuraEnabled public String READ_ONLY_04 {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String ITEM_NUMBER {get;set;} // ? BOM item number
            @AuraEnabled public String NETWR_VISIBLE {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String QDATU   {get;set;} // ? Date of confirmation
            @AuraEnabled public String QZEIT   {get;set;} // ? Time of confirmation
            @AuraEnabled public String RTYPE_ENABLE {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String GR      {get;set;} // ? GR 'Y' or 'N'
            @AuraEnabled public String REASON1 {get;set;} // ? REASON1 MT Return type Brandnew
            @AuraEnabled public String REASON2 {get;set;} // ? REASON2  MT Return type Brandnew
        }
    
        public class IF_SERVICE_046_Req_T_DOC { 
            public IF_SERVICE_046_Req_T_DOC(){}

            @AuraEnabled public String FILENAME {get;set;} // ?                                                             
            @AuraEnabled public String MIMETYPE {get;set;} // ? MIMETYPE
            @AuraEnabled public String FILEDATA {get;set;} // ? File Data
            @AuraEnabled public String DESCRIPTION {get;set;} // ? Short description of the original
            @AuraEnabled public String FLAG  {get;set;} // ? Flag Code for Deletion
            @AuraEnabled public String DOCNO {get;set;} // ? Document number
        }
    
        public class IF_SERVICE_046_Req_T_DEL { 
            public IF_SERVICE_046_Req_T_DEL(){}

            @AuraEnabled public String DOCNO    {get;set;} // ? Document number
            @AuraEnabled public String FILENAME {get;set;} // ? 
        }
    
        public class IF_SERVICE_046_Req_T_TMP { 
            public IF_SERVICE_046_Req_T_TMP(){}

            @AuraEnabled public String FILENAME  {get;set;} // ?                                                             
            @AuraEnabled public String IF_DESC      {get;set;} // ?                                                             
            @AuraEnabled public String EVISEQX   {get;set;} // ? Sequence
            @AuraEnabled public String LINE      {get;set;} // ? Table analysis: For external table data up to length 1024
            @AuraEnabled public String FILE_SIZE {get;set;} // ? File Size
        }
    
        public class IF_SERVICE_046_Req_T_DEL_SR { 
            public IF_SERVICE_046_Req_T_DEL_SR(){}
            @AuraEnabled public String DOCNO    {get;set;} // ? Document number
            @AuraEnabled public String FILENAME {get;set;} // ? 
        }
    
        public class IF_SERVICE_046_Req_T_TMP_SR { 
            public IF_SERVICE_046_Req_T_TMP_SR(){}

            @AuraEnabled public String FILENAME  {get;set;} // ?                                                             
            @AuraEnabled public String IF_DESC      {get;set;} // ?                                                             
            @AuraEnabled public String EVISEQX   {get;set;} // ? Sequence
            @AuraEnabled public String LINE      {get;set;} // ? Table analysis: For external table data up to length 1024
            @AuraEnabled public String FILE_SIZE {get;set;} // ? File Size
        }
    
        public class IF_SERVICE_046_Req_T_CONSIGN { 
            public IF_SERVICE_046_Req_T_CONSIGN(){}
            @AuraEnabled public String AUFNR  {get;set;} // ? Order Number
            @AuraEnabled public String QMNUM  {get;set;} // ? Notification No
            @AuraEnabled public String ZSEQN  {get;set;} // ? Sequence
            @AuraEnabled public String WERKS  {get;set;} // ? Plant
            @AuraEnabled public String LIFNR  {get;set;} // ? Account Number of Vendor or Creditor
            @AuraEnabled public String NAME1  {get;set;} // ? Name1
            @AuraEnabled public String ZCOSTC {get;set;} // ? Cost category
            @AuraEnabled public String ZCOSTC_T {get;set;} // ? Text
            @AuraEnabled public String ZPORD  {get;set;} // ? Part Or Distance
            @AuraEnabled public String ZPORD_T {get;set;} // ? Text
            @AuraEnabled public String ZACTIVI {get;set;} // ? Activity
            @AuraEnabled public String ZACTIVI_T {get;set;} // ? Text
            @AuraEnabled public String ZTRANF {get;set;} // ? Transportation Sector
            @AuraEnabled public String ZTRANF_T {get;set;} // ? Text
            @AuraEnabled public String ZTRANT {get;set;} // ? Transportation Sector
            @AuraEnabled public String ZDISTA {get;set;} // ? Distance(Km/Mile)
            @AuraEnabled public String ZEXPEN {get;set;} // ? Expense
            @AuraEnabled public String WAERS  {get;set;} // ? Currency Key
            @AuraEnabled public String REMARK {get;set;} // ? Remark
            @AuraEnabled public String CONFID {get;set;} // ? User Name
            @AuraEnabled public String CONFDT {get;set;} // ? Date
            @AuraEnabled public String CONFTM {get;set;} // ? Time
        }
  
    /** RESPONSE 
      */   
        public class IF_SERVICE_046_Res {
            public  IF_SERVICE_046_Res(){
                this.O_RETURN = new IF_SERVICE_046_Res_O_RETURN();
                this.T_MOTION = new  List<IF_SERVICE_046_Res_T_MOTION>();
                this.T_MATERIAL = new  List<IF_SERVICE_046_Res_T_MATERIAL>();
                this.T_DOC = new  List<IF_SERVICE_046_Res_T_DOC>();
                this.T_DEL = new  List<IF_SERVICE_046_Res_T_DEL>();
                this.T_TMP = new  List<IF_SERVICE_046_Res_T_TMP>();
                this.T_DEL_SR = new  List<IF_SERVICE_046_Res_T_DEL_SR>();
                this.T_TMP_SR = new  List<IF_SERVICE_046_Res_T_TMP_SR>();
                this.T_CONSIGN = new  List<IF_SERVICE_046_Res_T_CONSIGN>();
                this.T_RETURN = new  List<IF_SERVICE_046_Res_T_RETURN>();                
            }
            @AuraEnabled public String O_TIME    {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String O_DEL_MSG {get;set;} // ? Message Text
            @AuraEnabled public String O_UPD_MSG {get;set;} // ? Message Text
    

            @AuraEnabled public IF_SERVICE_046_Res_O_RETURN O_RETURN {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Res_T_MOTION> T_MOTION {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Res_T_MATERIAL> T_MATERIAL {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Res_T_DOC> T_DOC {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Res_T_DEL> T_DEL {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Res_T_TMP> T_TMP {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Res_T_DEL_SR> T_DEL_SR {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Res_T_TMP_SR> T_TMP_SR {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Res_T_CONSIGN> T_CONSIGN {get;set;} 
            @AuraEnabled public List<IF_SERVICE_046_Res_T_RETURN> T_RETURN {get;set;} 
    
            }
    
        public class IF_SERVICE_046_Res_O_RETURN { 
            public IF_SERVICE_046_Res_O_RETURN(){}
            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
    
            }
    
        public class IF_SERVICE_046_Res_T_MOTION { 
            public IF_SERVICE_046_Res_T_MOTION(){}

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
            @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERZET {get;set;} // ? Entry time
            @AuraEnabled public String AEDAT {get;set;} // ? Changed On
            @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
            @AuraEnabled public String FLAG_0060 {get;set;} // ? Flag
            @AuraEnabled public String WORKCD {get;set;} // ? Work Code
            @AuraEnabled public String EXRSN {get;set;} // ? 초과사유
    
            }
    
        public class IF_SERVICE_046_Res_T_MATERIAL { 
            public IF_SERVICE_046_Res_T_MATERIAL(){}

            @AuraEnabled public String AUFNR   {get;set;} // ? Order Number
            @AuraEnabled public String WORKNO  {get;set;} // ? Working time count
            @AuraEnabled public String SEQNO   {get;set;} // ? Sequential no
            @AuraEnabled public String MATNR   {get;set;} // ? Material Number for Order
            @AuraEnabled public String MEINS   {get;set;} // ? Base Unit of Measure
            @AuraEnabled public String SUPPLY_TYPE {get;set;} // ? 부품센타/대리점/정비센타
            @AuraEnabled public String CHANGE_DT {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String EBELN   {get;set;} // ? Purchasing Document Number
            @AuraEnabled public String EBELP   {get;set;} // ? Item Number of Purchasing Document
            @AuraEnabled public String MBLNR   {get;set;} // ? Number of Material Document
            @AuraEnabled public String GI_MBLNR {get;set;} // ? Good issue confirm  document
            @AuraEnabled public String LIFNR   {get;set;} // ? Account Number of Vendor or Creditor
            @AuraEnabled public String NAME1   {get;set;} // ? Name 1
            @AuraEnabled public String NETWR   {get;set;} // ? Net Order Value in PO Currency
            @AuraEnabled public String BRTWR   {get;set;} // ? Gross order value in PO currency
            @AuraEnabled public String FREIGHT {get;set;} // ? Condition value
            @AuraEnabled public String WAERS   {get;set;} // ? Currency Key
            @AuraEnabled public String BELNR   {get;set;} // ? Accounting Document Number
            @AuraEnabled public String RETURN_YN {get;set;} // ? Return Y or N
            @AuraEnabled public String ERDAT   {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String ERNAM   {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERZET   {get;set;} // ? Entry time
            @AuraEnabled public String AEDAT   {get;set;} // ? Changed On
            @AuraEnabled public String AENAM   {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEZET   {get;set;} // ? Time last change was made
            @AuraEnabled public String ITEM_CAT {get;set;} // ? Item Category (Bill of Material)
            @AuraEnabled public String RETURN_TYPE {get;set;} // ? Return Type
            @AuraEnabled public String RETURN_TEXT {get;set;} // ? Return Text
            @AuraEnabled public String PGMNG   {get;set;} // ? Total planned order quantity
            @AuraEnabled public String READ_ONLY {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String MENGE   {get;set;} // ? Quantity in Unit of Entry
            @AuraEnabled public String MENGE_GI {get;set;} // ? Quantity in Unit of Entry
            @AuraEnabled public String READ_ONLY_02 {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String READ_ONLY_03 {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String MAKTX   {get;set;} // ? Material Description (Short Text)
            @AuraEnabled public String CAUSE_PRT {get;set;} // ? Cause part
            @AuraEnabled public String READ_ONLY_04 {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String ITEM_NUMBER {get;set;} // ? BOM item number
            @AuraEnabled public String NETWR_VISIBLE {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String QDATU   {get;set;} // ? Date of confirmation
            @AuraEnabled public String QZEIT   {get;set;} // ? Time of confirmation
            @AuraEnabled public String RTYPE_ENABLE {get;set;} // ? Supplement for True Boolean Type: 'X' == True '' == False
            @AuraEnabled public String GR      {get;set;} // ? GR 'Y' or 'N'
            @AuraEnabled public String REASON1 {get;set;} // ? REASON1 MT Return type Brandnew
            @AuraEnabled public String REASON2 {get;set;} // ? REASON2  MT Return type Brandnew
    
    
            }
    
        public class IF_SERVICE_046_Res_T_DOC { 
            public IF_SERVICE_046_Res_T_DOC(){}

            @AuraEnabled public String FILENAME {get;set;} // ?                                                             
            @AuraEnabled public String MIMETYPE {get;set;} // ? MIMETYPE
            @AuraEnabled public String FILEDATA {get;set;} // ? File Data
            @AuraEnabled public String DESCRIPTION {get;set;} // ? Short description of the original
            @AuraEnabled public String FLAG  {get;set;} // ? Flag Code for Deletion
            @AuraEnabled public String DOCNO {get;set;} // ? Document number
    
            }
    
        public class IF_SERVICE_046_Res_T_DEL { 
            public IF_SERVICE_046_Res_T_DEL(){}

            @AuraEnabled public String DOCNO    {get;set;} // ? Document number
            @AuraEnabled public String FILENAME {get;set;} // ? 
    
            }
    
        public class IF_SERVICE_046_Res_T_TMP {
            public IF_SERVICE_046_Res_T_TMP(){}
            
            @AuraEnabled public String FILENAME  {get;set;} // ?                                                             
            @AuraEnabled public String IF_DESC      {get;set;} // ?                                                             
            @AuraEnabled public String EVISEQX   {get;set;} // ? Sequence
            @AuraEnabled public String LINE      {get;set;} // ? Table analysis: For external table data up to length 1024
            @AuraEnabled public String FILE_SIZE {get;set;} // ? File Size
    
    
            }
    
        public class IF_SERVICE_046_Res_T_DEL_SR { 
            public IF_SERVICE_046_Res_T_DEL_SR(){}

            @AuraEnabled public String DOCNO    {get;set;} // ? Document number
            @AuraEnabled public String FILENAME {get;set;} // ? 
    
            }
    
        public class IF_SERVICE_046_Res_T_TMP_SR { 
            public IF_SERVICE_046_Res_T_TMP_SR(){}

            @AuraEnabled public String FILENAME  {get;set;} // ?                                                             
            @AuraEnabled public String IF_DESC      {get;set;} // ?                                                             
            @AuraEnabled public String EVISEQX   {get;set;} // ? Sequence
            @AuraEnabled public String LINE      {get;set;} // ? Table analysis: For external table data up to length 1024
            @AuraEnabled public String FILE_SIZE {get;set;} // ? File Size
    
    
            }
    
        public class IF_SERVICE_046_Res_T_CONSIGN { 
            public IF_SERVICE_046_Res_T_CONSIGN(){}

            @AuraEnabled public String AUFNR  {get;set;} // ? Order Number
            @AuraEnabled public String QMNUM  {get;set;} // ? Notification No
            @AuraEnabled public String ZSEQN  {get;set;} // ? Sequence
            @AuraEnabled public String WERKS  {get;set;} // ? Plant
            @AuraEnabled public String LIFNR  {get;set;} // ? Account Number of Vendor or Creditor
            @AuraEnabled public String NAME1  {get;set;} // ? Name1
            @AuraEnabled public String ZCOSTC {get;set;} // ? Cost category
            @AuraEnabled public String ZCOSTC_T {get;set;} // ? Text
            @AuraEnabled public String ZPORD  {get;set;} // ? Part Or Distance
            @AuraEnabled public String ZPORD_T {get;set;} // ? Text
            @AuraEnabled public String ZACTIVI {get;set;} // ? Activity
            @AuraEnabled public String ZACTIVI_T {get;set;} // ? Text
            @AuraEnabled public String ZTRANF {get;set;} // ? Transportation Sector
            @AuraEnabled public String ZTRANF_T {get;set;} // ? Text
            @AuraEnabled public String ZTRANT {get;set;} // ? Transportation Sector
            @AuraEnabled public String ZDISTA {get;set;} // ? Distance(Km/Mile)
            @AuraEnabled public String ZEXPEN {get;set;} // ? Expense
            @AuraEnabled public String WAERS  {get;set;} // ? Currency Key
            @AuraEnabled public String REMARK {get;set;} // ? Remark
            @AuraEnabled public String CONFID {get;set;} // ? User Name
            @AuraEnabled public String CONFDT {get;set;} // ? Date
            @AuraEnabled public String CONFTM {get;set;} // ? Time
    
            }
    
        public class IF_SERVICE_046_Res_T_RETURN { 
            public IF_SERVICE_046_Res_T_RETURN(){}

            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
    
            }
    
    
  
}