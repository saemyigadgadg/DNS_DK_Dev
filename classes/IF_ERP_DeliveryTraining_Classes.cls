public with sharing class IF_ERP_DeliveryTraining_Classes {
    public IF_ERP_DeliveryTraining_Classes() {}


/** IF-PARTS-025
    */  
    /**
         * Apex Class           : IF_ERP_DeliveryTraining
         * Wrapper Class        : IF_ERP_DeliveryTraining_Classes
         * Wrapper Name         : IF_PARTS_025
         * SFDC interface Id    : IF_PARTS_025
         * AS-IS RFC            : Z_CS_WEB_PERIODIC_INSP_SAVE_ME
         * New I/F              : ZCRM_CS_WEB_PERIODIC_INSP_SAVE => ZCRM_CS_WORKWORDER_MANAGE				
         * Description          : 납품 후 교육/ 직영 서비스 결과 입력 저장/확정
         * IF_PARTS_025_Req_T_TMP => IF_DESC
         * IF_PARTS_025_Res_T_TMP => IF_DESC
     */     
    /** 
    * REQUEST
    */
      public class IF_PARTS_025_Req { 
        // @AuraEnabled public String I_UNAME  {get;set;} // ? User Name
        @AuraEnabled public String I_COUNSEL {get;set;} // ? 
        @AuraEnabled public String I_CONF   {get;set;} // ? Confirm = 'X', Save = SPACE
        @AuraEnabled public String I_IPOINT {get;set;} // ? 검수점수

        @AuraEnabled public IF_PARTS_025_Req_I_USERINFO I_USERINFO {get;set;} 
        @AuraEnabled public IF_PARTS_025_Req_I_SEL I_SEL {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Req_T_DOC2> T_DOC2 {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Req_T_INSPEC> T_INSPEC {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Req_T_DEL> T_DEL {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Req_T_TMP> T_TMP {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Req_T_MOTION> T_MOTION {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Req_T_DEL2> T_DEL2 {get;set;} 

        // public IF_PARTS_025_Req(){
        //   T_TMP = new List<IF_PARTS_025_Req_T_TMP>();
        // }
      }

      public class IF_PARTS_025_Req_I_USERINFO {
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
      }

      public class IF_PARTS_025_Req_I_SEL { 
        @AuraEnabled public String AUFNR  {get;set;} // ? Order Number
        @AuraEnabled public String KTEXT  {get;set;} // ? Description
        @AuraEnabled public String SYS_STATUS {get;set;} // ? System Status
        @AuraEnabled public String EQUNR  {get;set;} // ? Equipment Number
        @AuraEnabled public String TYPBZ  {get;set;} // ? Manufacturer model number

        @AuraEnabled public String SERNR  {get;set;} // ? Serial number
        @AuraEnabled public String INSPECTION_TP {get;set;} // ? Inspection Type
        @AuraEnabled public String INSPN_TP_TXT {get;set;} // ? Inspection Type Text
        @AuraEnabled public String DEALER {get;set;} // ? Dealer(Work Center)
        @AuraEnabled public String DEALER_NM {get;set;} // ? Short description

        @AuraEnabled public String INBDT  {get;set;} // ? Start-up Date of the Technical Object
        @AuraEnabled public String WORKING_HR {get;set;} // ? Operation Hours
        @AuraEnabled public String MDOCM  {get;set;} // ? Measurement Document
        @AuraEnabled public String MOVING_MAN {get;set;} // ? Moving man
        @AuraEnabled public String MOVING_MAN_NM {get;set;} // ? Moving man name

        @AuraEnabled public String RESP_MAN {get;set;} // ? Responsible person
        @AuraEnabled public String RESP_MAN_NM {get;set;} // ? Responsible person name
        @AuraEnabled public String INSPN_DT {get;set;} // ? Inspection date
        @AuraEnabled public String MOVING_S_TM {get;set;} // ? Moving start time
        @AuraEnabled public String MOVING_E_TM {get;set;} // ? Moving end time

        @AuraEnabled public String MOVING_HR {get;set;} // ? Moving work hours
        @AuraEnabled public String DATUM_FR {get;set;} // ? Start Date
        @AuraEnabled public String TIME_FR {get;set;} // ? Start Time
        @AuraEnabled public String DATUM_TO {get;set;} // ? End Date
        @AuraEnabled public String TIME_TO {get;set;} // ? End Time

        @AuraEnabled public String CUST_NM {get;set;} // ? Customer Name(CS)
        @AuraEnabled public String OWNER  {get;set;} // ? Owner Name
        @AuraEnabled public String TEL_NUMBER {get;set;} // ? First telephone no.: dialling code+number
        @AuraEnabled public String WORK_PLACE {get;set;} // ? Working place
        @AuraEnabled public String WORK_CONTENTS {get;set;} // ? Working contents

        @AuraEnabled public String RUECK  {get;set;} // ? Completion confirmation number for the operation
        @AuraEnabled public String RMZHL  {get;set;} // ? Confirmation counter
        @AuraEnabled public String CONF_TEXT {get;set;} // ? Confirmation text
        @AuraEnabled public String MOBILE {get;set;} // ? Search Term 2
        @AuraEnabled public String PERNR  {get;set;} // ? Personnel Number

        @AuraEnabled public String SVCMAN_NAME {get;set;} // ? Formatted Name of Employee or Applicant
        @AuraEnabled public String GENTYPE {get;set;} // ? GEN.TYPE
        @AuraEnabled public String MOVING_DIST {get;set;} // ? Distance
        @AuraEnabled public String DIST_UNIT {get;set;} // ? Mass unit of distance (kms, miles)
        @AuraEnabled public String ROUND_CHK {get;set;} // ? Round Flag

        @AuraEnabled public String HOLIDAY_CHK {get;set;} // ? Holiday Flag
        @AuraEnabled public String TOT_HOURS {get;set;} // ? Total hours
        @AuraEnabled public String LTXA1  {get;set;} // ? Operation short text
        @AuraEnabled public String CONTACTOR_NM {get;set;} // ? Contactor name
        @AuraEnabled public String CONTACTOR_TEL {get;set;} // ? Contactor telephone no

        @AuraEnabled public String ACTWAY {get;set;} // ? Catalog
        @AuraEnabled public String UDATE  {get;set;} // ? Creation date of the change document
        @AuraEnabled public String UTIME  {get;set;} // ? Time changed
        @AuraEnabled public String NAME1  {get;set;} // ? Name 1
        @AuraEnabled public String TELF1  {get;set;} // ? First telephone number

        @AuraEnabled public String WO_NAME1 {get;set;} // ? Name 1
        @AuraEnabled public String WO_TELF1 {get;set;} // ? First telephone number
        @AuraEnabled public String IPOINT {get;set;} // ? 검수점수 
      }

      public class IF_PARTS_025_Req_T_DOC2 { 
        @AuraEnabled public String FILENAME {get;set;} // ?                                                             
        @AuraEnabled public String MIMETYPE {get;set;} // ? MIMETYPE
        @AuraEnabled public String FILEDATA {get;set;} // ? Table analysis: For external table data up to length 1024
        @AuraEnabled public String DESCRIPTION {get;set;} // ? Short description of the original
        @AuraEnabled public String FLAG  {get;set;} // ? Flag Code for Deletion

        @AuraEnabled public String DOCNO {get;set;} // ? Document number
      }

      public class IF_PARTS_025_Req_T_INSPEC { 
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

      public class IF_PARTS_025_Req_T_DEL { 
        @AuraEnabled public String DOCNO    {get;set;} // ? Document number
        @AuraEnabled public String FILENAME {get;set;} // ?                                                             
      }

      public class IF_PARTS_025_Req_T_TMP { 
        @AuraEnabled public String FILENAME  {get;set;} // ?                                                             
        @AuraEnabled public String IF_DESC      {get;set;} // ?                                                             
        @AuraEnabled public String EVISEQX   {get;set;} // ? Sequence
        @AuraEnabled public String LINE      {get;set;} // ? Table analysis: For external table data up to length 1024
        @AuraEnabled public String FILE_SIZE {get;set;} // ? File Size
      }

      public class IF_PARTS_025_Req_T_MOTION { 
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

      public class IF_PARTS_025_Req_T_DEL2 { 
        @AuraEnabled public String DOCNO    {get;set;} // ? SAP ArchiveLink: Document ID
        @AuraEnabled public String FILENAME {get;set;} // ?                                                             
      }


    /** 
    * RESPONSE
    */
      public class IF_PARTS_025_Res { 
        @AuraEnabled public String O_DEL_MSG {get;set;} // ? Message Text
        @AuraEnabled public String O_UPD_MSG {get;set;} // ? Message Text

        @AuraEnabled public IF_PARTS_025_Res_O_RETURN O_RETURN {get;set;}
        @AuraEnabled public List<IF_PARTS_025_Res_T_DOC2> T_DOC2 {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Res_T_INSPEC> T_INSPEC {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Res_T_DEL> T_DEL {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Res_T_TMP> T_TMP {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Res_T_MOTION> T_MOTION {get;set;} 
        @AuraEnabled public List<IF_PARTS_025_Res_T_DEL2> T_DEL2 {get;set;}  
      }

      public class IF_PARTS_025_Res_O_RETURN { 
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
      }
      public class IF_PARTS_025_Res_T_DOC2 { 
        @AuraEnabled public String FILENAME {get;set;} // ?                                                             
        @AuraEnabled public String MIMETYPE {get;set;} // ? MIMETYPE
        @AuraEnabled public String FILEDATA {get;set;} // ? Table analysis: For external table data up to length 1024
        @AuraEnabled public String DESCRIPTION {get;set;} // ? Short description of the original
        @AuraEnabled public String FLAG  {get;set;} // ? Flag Code for Deletion

        @AuraEnabled public String DOCNO {get;set;} // ? Document number
      }
      public class IF_PARTS_025_Res_T_INSPEC { 
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
      public class IF_PARTS_025_Res_T_DEL { 
        @AuraEnabled public String DOCNO    {get;set;} // ? Document number
        @AuraEnabled public String FILENAME {get;set;} // ?                                                             
      }
      public class IF_PARTS_025_Res_T_TMP { 
        @AuraEnabled public String FILENAME  {get;set;} // ?                                                             
        @AuraEnabled public String IF_DESC      {get;set;} // ?                                                             
        @AuraEnabled public String EVISEQX   {get;set;} // ? Sequence
        @AuraEnabled public String LINE      {get;set;} // ? Table analysis: For external table data up to length 1024
        @AuraEnabled public String FILE_SIZE {get;set;} // ? File Size
      }
      public class IF_PARTS_025_Res_T_MOTION { 
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
      public class IF_PARTS_025_Res_T_DEL2 { 
        @AuraEnabled public String DOCNO    {get;set;} // ? SAP ArchiveLink: Document ID
        @AuraEnabled public String FILENAME {get;set;} // ?                                                             
      }

  
}