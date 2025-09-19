public with sharing class IF_ERP_Service_Report_Classes {
    public IF_ERP_Service_Report_Classes() {}

// ** IF-SERVICE-011				
/**
  */
  /**
     * Wrapper Name         : IF_SERVICE_011
     * SFDC interface Id    : IF-SERVICE-011
     * AS-IS RFC            : Z_CS_SEARCH_CAUSE_TO_BLAME	
     * New I/F              : ZCRM_CS_SEARCH_CAUSE_TO_BLAME
     * Description          : 귀책부서 Picklist 가져오기 
  */

    // ** REQUEST   
    /**
        */  
        public class IF_SERVICE_011_Req { 
            public IF_SERVICE_011_Req(){}
            @AuraEnabled public String I_UNAME {get;set;} // ? 사원번호
            @AuraEnabled public String I_KATALOG {get;set;} // ? 카탈로그
            @AuraEnabled public String I_LANGU {get;set;} // ? Language Key of Current Text Environment
        }

    // ** RESPONSE
    /**
        */           
        public class IF_SERVICE_011_Res {
            public IF_SERVICE_011_Res(){} 
            @AuraEnabled public IF_SERVICE_011_Res_O_RETURN     O_RETURN {get;set;} 
            @AuraEnabled public List<IF_SERVICE_011_Res_T_LIST> T_LIST {get;set;} 
        }

        
        public class IF_SERVICE_011_Res_O_RETURN { 
            public IF_SERVICE_011_Res_O_RETURN(){} 
            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

        public class IF_SERVICE_011_Res_T_LIST { 
            public IF_SERVICE_011_Res_T_LIST(){} 
            @AuraEnabled public String CODE   {get;set;} // ? CS Code 
            @AuraEnabled public String KEY1   {get;set;} // ? KEY
            @AuraEnabled public String TEXT01 {get;set;} // ? Text (100 characters)
        }

    /**
     * Wrapper Name         : IF_SERVICE_049
     * SFDC interface Id    : IF-SERVICE-049
     * New I/F              : ZCRM_CS_WEB_REQ_RES_SAVE_MT
     * Description          : 유상 리포트 정보 조회
        */
        public class IF_SERVICE_049_Req {
            
            public IF_SERVICE_049_Req(){
                this.I_INFO         = new IF_SERVICE_049_Req_I_INFO();
                this.I_INPUT        = new IF_SERVICE_049_Req_I_INPUT();
                this.I_INFOR        = new IF_SERVICE_049_Req_I_INFOR();
                this.I_HISTORY      = new IF_SERVICE_049_Req_I_HISTORY();
                this.I_CODE         = new IF_SERVICE_049_Req_I_CODE();
                this.I_USERINFO     = new IF_SERVICE_049_Req_I_USERINFO();
                this.T_MOTION       = new List<IF_SERVICE_049_Req_T_MOTION>();
                this.T_ITEM         = new List<IF_SERVICE_049_Req_T_ITEM>();
                this.T_DEL          = new List<IF_SERVICE_049_Req_T_DEL>();
                this.T_TMP          = new List<IF_SERVICE_049_Req_T_TMP>();
            }
            @AuraEnabled public IF_SERVICE_049_Req_I_INFO       I_INFO      {get;set;}
            @AuraEnabled public IF_SERVICE_049_Req_I_INPUT      I_INPUT     {get;set;}
            @AuraEnabled public IF_SERVICE_049_Req_I_INFOR      I_INFOR     {get;set;}
            @AuraEnabled public IF_SERVICE_049_Req_I_HISTORY    I_HISTORY   {get;set;}
            @AuraEnabled public IF_SERVICE_049_Req_I_CODE       I_CODE      {get;set;}
            @AuraEnabled public IF_SERVICE_049_Req_I_USERINFO   I_USERINFO  {get;set;}

            
            @AuraEnabled public String I_PHENOMENA      {get;set;}
            @AuraEnabled public String I_DESCRIPT       {get;set;}
            @AuraEnabled public String I_CAUSE          {get;set;}
            @AuraEnabled public String I_ACTIVITY       {get;set;}
            @AuraEnabled public String I_FLAG           {get;set;}
            @AuraEnabled public String I_TYPBZ          {get;set;}
            @AuraEnabled public String I_SERNR          {get;set;}
            @AuraEnabled public String I_EQUNR          {get;set;}
            @AuraEnabled public List<IF_SERVICE_049_Req_T_MOTION>   T_MOTION    {get;set;}
            @AuraEnabled public List<IF_SERVICE_049_Req_T_ITEM>     T_ITEM      {get;set;}
            @AuraEnabled public List<IF_SERVICE_049_Req_T_DEL>      T_DEL       {get;set;}
            @AuraEnabled public List<IF_SERVICE_049_Req_T_TMP>      T_TMP       {get;set;}
        }
        public class IF_SERVICE_049_Req_I_INFO {
            public IF_SERVICE_049_Req_I_INFO(){}
            @AuraEnabled public String NAME                 {get;set;}   
            @AuraEnabled public String INBDT                {get;set;}       
            @AuraEnabled public String WTY_TYPE             {get;set;}       
            @AuraEnabled public String RBNR                 {get;set;}   
            @AuraEnabled public String GWLDT_O              {get;set;}
            @AuraEnabled public String GWLEN_O              {get;set;}       
            @AuraEnabled public String CODING               {get;set;}       
            @AuraEnabled public String CODE_TEXT            {get;set;}           
            @AuraEnabled public String NOTIF_NO             {get;set;}       
            @AuraEnabled public String ATTACHMENT_CODE      {get;set;}               
            @AuraEnabled public String ATTACHMENT           {get;set;}           
            @AuraEnabled public String WORK_AREA_CODE       {get;set;}               
            @AuraEnabled public String WORK_AREA            {get;set;}           
            @AuraEnabled public String WORK_TYPE_CODE       {get;set;}               
            @AuraEnabled public String WORK_TYPE            {get;set;}           
            @AuraEnabled public String MAINTROOM            {get;set;}           
            @AuraEnabled public String NOTIF_DATE           {get;set;}           
            @AuraEnabled public String NOTIFTIME            {get;set;}           
            @AuraEnabled public String REQUIRE_DAT          {get;set;}           
            @AuraEnabled public String STRMLFNDATE          {get;set;}           
            @AuraEnabled public String STRMLFNTIME          {get;set;}           
            @AuraEnabled public String DESENDDATE           {get;set;}           
            @AuraEnabled public String DESENDTM             {get;set;}       
            @AuraEnabled public String STAND_WE             {get;set;}       
            @AuraEnabled public String PHENOMENA            {get;set;}           
            @AuraEnabled public String DL_CODEGRP           {get;set;}           
            @AuraEnabled public String DL_CODE              {get;set;}       
            @AuraEnabled public String STXT_GRPCD           {get;set;}           
            @AuraEnabled public String D_CODEGRP            {get;set;}           
            @AuraEnabled public String D_CODE               {get;set;}       
            @AuraEnabled public String TXT_PROBCD           {get;set;}           
            @AuraEnabled public String DESCRIPT             {get;set;}       
            @AuraEnabled public String REPORTEDBY           {get;set;}           
            @AuraEnabled public String EQUNR                {get;set;}       
            @AuraEnabled public String ILART                {get;set;}       
            @AuraEnabled public String ZZ_EX_TERM_TYP       {get;set;}               
            @AuraEnabled public String ZZ_EX_TERM_TYP_TXT   {get;set;}                   
            @AuraEnabled public String ZZ_EX_TERM_TYP_B     {get;set;}               
            @AuraEnabled public String ZZ_EX_TERM_TYP_B_TXT {get;set;}                   
            @AuraEnabled public String ZZ_EX_END_DT         {get;set;}
        }
        public class IF_SERVICE_049_Req_I_INPUT {
            public IF_SERVICE_049_Req_I_INPUT(){}
            @AuraEnabled public String EQUNR               {get;set;}    
            @AuraEnabled public String WTY_TYPE            {get;set;}    
            @AuraEnabled public String CODING              {get;set;}    
            @AuraEnabled public String ATTACHMENT          {get;set;}        
            @AuraEnabled public String WORK_AREA           {get;set;}
            @AuraEnabled public String WORK_TYPE           {get;set;}        
            @AuraEnabled public String MAINTROOM           {get;set;}        
            @AuraEnabled public String NOTIF_DATE          {get;set;}        
            @AuraEnabled public String NOTIFTIME           {get;set;}        
            @AuraEnabled public String REQUIRE_DAT         {get;set;}        
            @AuraEnabled public String STRMLFNDATE         {get;set;}        
            @AuraEnabled public String STRMLFNTIME         {get;set;}        
            @AuraEnabled public String DESENDDATE          {get;set;}        
            @AuraEnabled public String DESSTTIME           {get;set;}        
            @AuraEnabled public String STAND_WE            {get;set;}    
            @AuraEnabled public String PHENOMENA           {get;set;}        
            @AuraEnabled public String PHENOMENA_ADD_TXT   {get;set;}                
            @AuraEnabled public String DL_CODEGRP          {get;set;}        
            @AuraEnabled public String DL_CODE             {get;set;}    
            @AuraEnabled public String D_CODEGRP           {get;set;}        
            @AuraEnabled public String D_CODE              {get;set;}    
            @AuraEnabled public String DESCRIPT            {get;set;}    
            @AuraEnabled public String SYMPTOM_ADD_TXT     {get;set;}            
            @AuraEnabled public String REPORTEDBY          {get;set;}        
            @AuraEnabled public String QMNUM               {get;set;}    
            @AuraEnabled public String ILART               {get;set;}    
            @AuraEnabled public String CLAIM_NO            {get;set;}    
            @AuraEnabled public String POWERTRAIN          {get;set;}        
            @AuraEnabled public String SHIP_TO             {get;set;}    
            @AuraEnabled public String TXTQM               {get;set;}    
            @AuraEnabled public String REF_NO              {get;set;}    
        }
        public class IF_SERVICE_049_Req_I_INFOR {
            public IF_SERVICE_049_Req_I_INFOR(){}
            @AuraEnabled public String MANDT             {get;set;}           
            @AuraEnabled public String AUFNR             {get;set;}           
            @AuraEnabled public String AUART             {get;set;}           
            @AuraEnabled public String ORDER_TYPE_TXT    {get;set;}                   
            @AuraEnabled public String QMNUM             {get;set;}
            @AuraEnabled public String ILART             {get;set;}           
            @AuraEnabled public String DMACTTYPE_TXT     {get;set;}                   
            @AuraEnabled public String QMDAT             {get;set;}           
            @AuraEnabled public String GSTRP             {get;set;}           
            @AuraEnabled public String LTRMN             {get;set;}           
            @AuraEnabled public String QMTXT             {get;set;}           
            @AuraEnabled public String TXTQM             {get;set;}           
            @AuraEnabled public String EQUNR             {get;set;}           
            @AuraEnabled public String MATNR             {get;set;}           
            @AuraEnabled public String TYPBZ             {get;set;}           
            @AuraEnabled public String SERNR             {get;set;}           
            @AuraEnabled public String INBDT             {get;set;}           
            @AuraEnabled public String RBNR              {get;set;}       
            @AuraEnabled public String IDATE             {get;set;}           
            @AuraEnabled public String STAND_WE          {get;set;}           
            @AuraEnabled public String MDOCM             {get;set;}           
            @AuraEnabled public String KUNNR             {get;set;}           
            @AuraEnabled public String NAME              {get;set;}       
            @AuraEnabled public String TELEPHONE         {get;set;}               
            @AuraEnabled public String REP_NAME          {get;set;}           
            @AuraEnabled public String TAX_NO_2          {get;set;}           
            @AuraEnabled public String ABCKZ             {get;set;}           
            @AuraEnabled public String BEBER             {get;set;}           
            @AuraEnabled public String CONTACT_TYPE      {get;set;}               
            @AuraEnabled public String CONTACT_NAME      {get;set;}               
            @AuraEnabled public String CONTACT_MOBILE    {get;set;}                   
            @AuraEnabled public String CONTACT_TEL       {get;set;}               
            @AuraEnabled public String PART_PRICE        {get;set;}               
            @AuraEnabled public String LABOR_PRICE       {get;set;}               
            @AuraEnabled public String TOT_AMOUNT        {get;set;}               
            @AuraEnabled public String DISCOUNT_AMT      {get;set;}               
            @AuraEnabled public String WAERS             {get;set;}           
            @AuraEnabled public String VBELN             {get;set;}           
            @AuraEnabled public String ERDAT             {get;set;}           
            @AuraEnabled public String ERNAM             {get;set;}           
            @AuraEnabled public String ERZET             {get;set;}           
            @AuraEnabled public String AEDAT             {get;set;}           
            @AuraEnabled public String AENAM             {get;set;}           
            @AuraEnabled public String AEZET             {get;set;}           
            @AuraEnabled public String ARBPL             {get;set;}           
            @AuraEnabled public String WTY_TYPE          {get;set;}           
            @AuraEnabled public String NOTIFTIME         {get;set;}               
            @AuraEnabled public String MOBILE            {get;set;}           
            @AuraEnabled public String LTRUR             {get;set;}           
            @AuraEnabled public String ISMNW             {get;set;}           
            @AuraEnabled public String ZDIST             {get;set;}           
            @AuraEnabled public String OTHER_COST        {get;set;}               
            @AuraEnabled public String ZENGNO            {get;set;}           
            @AuraEnabled public String USNAM             {get;set;}           
            @AuraEnabled public String UDATE             {get;set;}           
            @AuraEnabled public String UTIME             {get;set;}           
        }
        public class IF_SERVICE_049_Req_I_HISTORY {
            public IF_SERVICE_049_Req_I_HISTORY(){}
            @AuraEnabled public String MANDT             {get;set;}      
            @AuraEnabled public String QMNUM             {get;set;}      
            @AuraEnabled public String SEQNO             {get;set;}      
            @AuraEnabled public String OTGRP             {get;set;}      
            @AuraEnabled public String OTEIL             {get;set;}
            @AuraEnabled public String KURZTEXT          {get;set;}      
            @AuraEnabled public String FEGRP             {get;set;}      
            @AuraEnabled public String FECOD             {get;set;}      
            @AuraEnabled public String TXTCDFE           {get;set;}      
            @AuraEnabled public String FETXT             {get;set;}      
            @AuraEnabled public String SYMPTOM_ADD_TXT   {get;set;}              
            @AuraEnabled public String URGRP             {get;set;}      
            @AuraEnabled public String URCOD             {get;set;}      
            @AuraEnabled public String TXTCDUR           {get;set;}      
            @AuraEnabled public String URTXT             {get;set;}      
            @AuraEnabled public String CAUSE_ADD_TXT     {get;set;}              
            @AuraEnabled public String MNGRP             {get;set;}      
            @AuraEnabled public String MNCOD             {get;set;}      
            @AuraEnabled public String TXTCDMA           {get;set;}      
            @AuraEnabled public String MATXT             {get;set;}      
            @AuraEnabled public String ACT_ADD_TXT       {get;set;}          
            @AuraEnabled public String FAULT_CAUSE       {get;set;}          
            @AuraEnabled public String PHENO_ADD_TXT     {get;set;}              
            @AuraEnabled public String BLCOD             {get;set;}      
            @AuraEnabled public String BLCOD_T           {get;set;}      
            @AuraEnabled public String ERDAT             {get;set;}      
            @AuraEnabled public String ERNAM             {get;set;}      
            @AuraEnabled public String ERZET             {get;set;}      
            @AuraEnabled public String AEDAT             {get;set;}      
            @AuraEnabled public String AENAM             {get;set;}      
            @AuraEnabled public String AEZET             {get;set;}      
            @AuraEnabled public String TXTQM             {get;set;}      
        }
        public class IF_SERVICE_049_Req_I_CODE {
            public IF_SERVICE_049_Req_I_CODE(){}
            @AuraEnabled public String CODE_01       {get;set;}       
            @AuraEnabled public String CODE_02       {get;set;}       
            @AuraEnabled public String CODE_03       {get;set;}       
            @AuraEnabled public String TEXT          {get;set;}   
            @AuraEnabled public String TEXT2         {get;set;}       
        }
        public class IF_SERVICE_049_Req_I_USERINFO {
            public IF_SERVICE_049_Req_I_USERINFO(){}
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
        }
        public class IF_SERVICE_049_Req_T_MOTION {
            public IF_SERVICE_049_Req_T_MOTION(){}
            @AuraEnabled public String MANDT         {get;set;}      
            @AuraEnabled public String AUFNR         {get;set;}      
            @AuraEnabled public String RUECK         {get;set;}      
            @AuraEnabled public String WORKNO        {get;set;}      
            @AuraEnabled public String SEQNO         {get;set;}
            @AuraEnabled public String PERNR         {get;set;}      
            @AuraEnabled public String SVCMAN_NAME   {get;set;}          
            @AuraEnabled public String ISDD          {get;set;}  
            @AuraEnabled public String ISDZ          {get;set;}  
            @AuraEnabled public String AUSBS         {get;set;}      
            @AuraEnabled public String AUZTB         {get;set;}      
            @AuraEnabled public String ISMNW         {get;set;}      
            @AuraEnabled public String ISMNW_PDK     {get;set;}          
            @AuraEnabled public String HOL_CHK       {get;set;}      
            @AuraEnabled public String OT_CHK        {get;set;}      
            @AuraEnabled public String LTXA1         {get;set;}      
            @AuraEnabled public String RMZHL         {get;set;}      
            @AuraEnabled public String ISMNE         {get;set;}      
            @AuraEnabled public String ERDAT         {get;set;}      
            @AuraEnabled public String ERNAM         {get;set;}      
            @AuraEnabled public String ERZET         {get;set;}      
            @AuraEnabled public String AEDAT         {get;set;}      
            @AuraEnabled public String AENAM         {get;set;}      
            @AuraEnabled public String AEZET         {get;set;}      
            @AuraEnabled public String FLAG_0060     {get;set;}          
            @AuraEnabled public String WORKCD        {get;set;}      
            @AuraEnabled public String EXRSN         {get;set;}      
        }
        public class IF_SERVICE_049_Req_T_ITEM {
            public IF_SERVICE_049_Req_T_ITEM(){}
            @AuraEnabled public String MATNR        {get;set;}
            @AuraEnabled public String CAUSE        {get;set;}
            @AuraEnabled public String MENGE        {get;set;}
            @AuraEnabled public String MEINS        {get;set;}
            @AuraEnabled public String LIFNR        {get;set;}
            @AuraEnabled public String ZSUPPLY      {get;set;}
            @AuraEnabled public String VSBED        {get;set;}
            @AuraEnabled public String KUNNR        {get;set;}
        }
        public class IF_SERVICE_049_Req_T_DEL {
            public IF_SERVICE_049_Req_T_DEL(){}
            @AuraEnabled public String DOCNO        {get;set;}
            @AuraEnabled public String FILENAME     {get;set;}
        }
        public class IF_SERVICE_049_Req_T_TMP {
            public IF_SERVICE_049_Req_T_TMP(){}
            @AuraEnabled public String FILENAME     {get;set;}
            @AuraEnabled public String IF_DESC      {get;set;}
            @AuraEnabled public String EVISEQX      {get;set;}
            @AuraEnabled public String LINE         {get;set;}
            @AuraEnabled public String FILE_SIZE    {get;set;}
        }
        public class IF_SERVICE_049_Res {
            public IF_SERVICE_049_Res(){}
            @AuraEnabled public IF_SERVICE_049_Res_O_RETURN O_RETURN    {get;set;}
            @AuraEnabled public String O_DEL_MSG                        {get;set;}
            @AuraEnabled public String O_UPD_MSG                        {get;set;}
            @AuraEnabled public String O_AUFNR_F                        {get;set;}
            @AuraEnabled public String O_QMNUM_F                        {get;set;}
            @AuraEnabled public IF_SERVICE_049_Res_O_INFO   O_INFO      {get;set;}
        }
        public class IF_SERVICE_049_Res_O_RETURN {
            public IF_SERVICE_049_Res_O_RETURN(){}
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String CODE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}
        }
        public class IF_SERVICE_049_Res_O_INFO {
            public IF_SERVICE_049_Res_O_INFO(){}
            @AuraEnabled public String NAME                  {get;set;}      
            @AuraEnabled public String INBDT                 {get;set;}          
            @AuraEnabled public String WTY_TYPE              {get;set;}          
            @AuraEnabled public String RBNR                  {get;set;}      
            @AuraEnabled public String GWLDT_O               {get;set;}
            @AuraEnabled public String GWLEN_O               {get;set;}          
            @AuraEnabled public String CODING                {get;set;}          
            @AuraEnabled public String CODE_TEXT             {get;set;}              
            @AuraEnabled public String NOTIF_NO              {get;set;}          
            @AuraEnabled public String ATTACHMENT_CODE       {get;set;}                  
            @AuraEnabled public String ATTACHMENT            {get;set;}              
            @AuraEnabled public String WORK_AREA_CODE        {get;set;}                  
            @AuraEnabled public String WORK_AREA             {get;set;}              
            @AuraEnabled public String WORK_TYPE_CODE        {get;set;}                  
            @AuraEnabled public String WORK_TYPE             {get;set;}              
            @AuraEnabled public String MAINTROOM_CODE        {get;set;}                  
            @AuraEnabled public String MAINTROOM             {get;set;}              
            @AuraEnabled public String NOTIF_DATE            {get;set;}              
            @AuraEnabled public String NOTIFTIME             {get;set;}              
            @AuraEnabled public String REQUIRE_DAT           {get;set;}              
            @AuraEnabled public String STRMLFNDATE           {get;set;}              
            @AuraEnabled public String STRMLFNTIME           {get;set;}              
            @AuraEnabled public String DESENDDATE            {get;set;}              
            @AuraEnabled public String DESENDTM              {get;set;}          
            @AuraEnabled public String STAND_WE              {get;set;}          
            @AuraEnabled public String PHENOMENA             {get;set;}              
            @AuraEnabled public String DL_CODEGRP            {get;set;}              
            @AuraEnabled public String DL_CODE               {get;set;}          
            @AuraEnabled public String STXT_GRPCD            {get;set;}              
            @AuraEnabled public String D_CODEGRP             {get;set;}              
            @AuraEnabled public String D_CODE                {get;set;}          
            @AuraEnabled public String TXT_PROBCD            {get;set;}              
            @AuraEnabled public String DESCRIPT              {get;set;}          
            @AuraEnabled public String REPORTEDBY            {get;set;}              
            @AuraEnabled public String EQUNR                 {get;set;}          
            @AuraEnabled public String ILART                 {get;set;}          
            @AuraEnabled public String ZZ_EX_TERM_TYP        {get;set;}                  
            @AuraEnabled public String ZZ_EX_TERM_TYP_TXT    {get;set;}                      
            @AuraEnabled public String ZZ_EX_TERM_TYP_B      {get;set;}                  
            @AuraEnabled public String ZZ_EX_TERM_TYP_B_TXT  {get;set;}                      
            @AuraEnabled public String ZZ_EX_END_DT          {get;set;}              
            @AuraEnabled public String MGANR_OUT             {get;set;}              
            @AuraEnabled public String MGANR_OUT_TXT40       {get;set;}                  
            @AuraEnabled public String ZZ_CS_PWRNT_HR        {get;set;}                  
            @AuraEnabled public String ZZ_CS_PWRNT_MM        {get;set;}                  
            @AuraEnabled public String ZZ_EX_TERM_VL         {get;set;}                  
            @AuraEnabled public String ZZ_EX_OPH             {get;set;}              
        }



// ** IF-SERVICE-050				
/**
  */
  /**
         * Wrapper Name         : IF_SERVICE_050
         * SFDC interface Id    : IF-SERVICE-050
         * New I/F              : ZCRM_CS_WEB_JOB_RESULT_CONF
         * Description          : 서비스리포트 확정
  */
  /** REQUEST
       */
        public class IF_SERVICE_050_Req { 
            @AuraEnabled public String I_UNAME {get;set;} // ? User Name
            @AuraEnabled public String I_DESCRIPT {get;set;} // ? Descript
            @AuraEnabled public String I_CAUSE {get;set;} // ? Cause
            @AuraEnabled public String I_ACTIVITY {get;set;} // ? Activity
            @AuraEnabled public String I_CR    {get;set;} // ? IncompleteItem/Customer Request
            @AuraEnabled public String I_MANHOUR_REASON {get;set;} // ? 표준공수 초과 사유
            @AuraEnabled public String I_EXRSN {get;set;} // ? 표준공수 초과 사유(New)

            @AuraEnabled public IF_SERVICE_050_Req_I_INFO       I_INFO {get;set;} 
            @AuraEnabled public IF_SERVICE_050_Req_I_HISTORY    I_HISTORY {get;set;} 
            @AuraEnabled public IF_SERVICE_050_Req_I_CODE       I_CODE {get;set;} 
            @AuraEnabled public IF_SERVICE_050_Req_I_SUB        I_SUB {get;set;} 
            @AuraEnabled public IF_SERVICE_050_Req_I_USERINFO    I_USERINFO {get;set;}
            @AuraEnabled public List<IF_SERVICE_050_Req_T_MOTION>   T_MOTION {get;set;} 
            @AuraEnabled public List<IF_SERVICE_050_Req_T_MATERIAL> T_MATERIAL {get;set;} 
            @AuraEnabled public List<IF_SERVICE_050_Req_T_DOC> T_DOC {get;set;} 
            @AuraEnabled public List<IF_SERVICE_050_Req_T_DEL> T_DEL {get;set;} 
            @AuraEnabled public List<IF_SERVICE_050_Req_T_TMP> T_TMP {get;set;} 
            @AuraEnabled public List<IF_SERVICE_050_Req_T_DEL_SR> T_DEL_SR {get;set;} 
            @AuraEnabled public List<IF_SERVICE_050_Req_T_TMP_SR> T_TMP_SR {get;set;} 
            @AuraEnabled public List<IF_SERVICE_050_Req_T_CONSIGN> T_CONSIGN {get;set;} 

        }

        public class IF_SERVICE_050_Req_I_INFO { 
            // @AuraEnabled public String MANDT {get;set;} // ? Client
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
        public class IF_SERVICE_050_Req_I_SUB{
            @AuraEnabled public String KEY   {get;set;}
            @AuraEnabled public String VALUE {get;set;}
        }
        public class IF_SERVICE_050_Req_I_CODE{
            @AuraEnabled public String CODE_01 {get;set;}
            @AuraEnabled public String CODE_02 {get;set;}
            @AuraEnabled public String CODE_03 {get;set;}
            @AuraEnabled public String TEXT {get;set;}
            @AuraEnabled public String TEXT2 {get;set;}
        }
        public class IF_SERVICE_050_Req_I_HISTORY { 
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
            @AuraEnabled public String ERDAT {get;set;} // ? Date on Which Record Was Created
            @AuraEnabled public String ERNAM {get;set;} // ? Name of Person who Created the Object
            @AuraEnabled public String ERZET {get;set;} // ? Entry time
            @AuraEnabled public String AEDAT {get;set;} // ? Changed On
            @AuraEnabled public String AENAM {get;set;} // ? Name of Person Who Changed Object
            @AuraEnabled public String AEZET {get;set;} // ? Time last change was made
            @AuraEnabled public String TXTQM {get;set;} // ? Short Text for Coding
        }
        public class IF_SERVICE_050_Req_I_USERINFO{
            @AuraEnabled public String BNAME {get;set;}
            @AuraEnabled public String RNAME {get;set;}
            @AuraEnabled public String HIER {get;set;}
            @AuraEnabled public String KUNNR {get;set;}
            @AuraEnabled public String LIFNR {get;set;}
            @AuraEnabled public String VKORG {get;set;}
            @AuraEnabled public String VTWEG {get;set;}
            @AuraEnabled public String SPART {get;set;}
            @AuraEnabled public String WERKS {get;set;}
            @AuraEnabled public String ARBPL {get;set;}
            @AuraEnabled public String PARNR {get;set;}
            @AuraEnabled public String ENAME {get;set;}
            @AuraEnabled public String KUNN2 {get;set;}
            @AuraEnabled public String LAND1 {get;set;}
            @AuraEnabled public String LGORT {get;set;}
            @AuraEnabled public String DF_CHK {get;set;}
            @AuraEnabled public String CO_CHK {get;set;}
        }
        public class IF_SERVICE_050_Req_T_MOTION { 
            @AuraEnabled public String MANDT {get;set;} // ? Client
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
        public class IF_SERVICE_050_Req_T_MATERIAL { 
            @AuraEnabled public String MANDT   {get;set;} // ? Client
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
        public class IF_SERVICE_050_Req_T_DOC {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String MIMETYPE {get;set;}
            @AuraEnabled public String FILEDATA {get;set;}
            @AuraEnabled public String DESCRIPTION {get;set;}
            @AuraEnabled public String FLAG {get;set;}
            @AuraEnabled public String DOCNO {get;set;}             
        }
        public class IF_SERVICE_050_Req_T_DEL {
            @AuraEnabled public String DOCNO {get;set;}
            @AuraEnabled public String FILENAME {get;set;}             
        }
        public class IF_SERVICE_050_Req_T_TMP { 
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String IF_DESC {get;set;}
            @AuraEnabled public String EVISEQX {get;set;}
            @AuraEnabled public String LINE {get;set;}
            @AuraEnabled public String FILE_SIZE {get;set;}            
        }
        public class IF_SERVICE_050_Req_T_DEL_SR {
            @AuraEnabled public String DOCNO {get;set;}
            @AuraEnabled public String FILENAME {get;set;}              
        }
        public class IF_SERVICE_050_Req_T_TMP_SR {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String IF_DESC {get;set;}
            @AuraEnabled public String EVISEQX {get;set;}
            @AuraEnabled public String LINE {get;set;}
            @AuraEnabled public String FILE_SIZE {get;set;}             
        }
        public class IF_SERVICE_050_Req_T_CONSIGN {
            @AuraEnabled public String AUFNR {get;set;}
            @AuraEnabled public String QMNUM {get;set;}
            @AuraEnabled public String ZSEQN {get;set;}
            @AuraEnabled public String WERKS {get;set;}
            @AuraEnabled public String LIFNR {get;set;}
            @AuraEnabled public String NAME1 {get;set;}
            @AuraEnabled public String ZCOSTC {get;set;}
            @AuraEnabled public String ZCOSTC_T {get;set;}
            @AuraEnabled public String ZPORD {get;set;}
            @AuraEnabled public String ZPORD_T {get;set;}
            @AuraEnabled public String ZACTIVI {get;set;}
            @AuraEnabled public String ZACTIVI_T {get;set;}
            @AuraEnabled public String ZTRANF {get;set;}
            @AuraEnabled public String ZTRANF_T {get;set;}
            @AuraEnabled public String ZTRANT {get;set;}
            @AuraEnabled public String ZDISTA {get;set;}
            @AuraEnabled public String ZEXPEN {get;set;}
            @AuraEnabled public String WAERS {get;set;}
            @AuraEnabled public String REMARK {get;set;}
            @AuraEnabled public String CONFID {get;set;}
            @AuraEnabled public String CONFDT {get;set;}
            @AuraEnabled public String CONFTM {get;set;}             
        }        
        


    

  /** REQUEST
       */
        public class IF_SERVICE_050_Res { 
            // @AuraEnabled public String O_ACTIVE {get;set;}
            @AuraEnabled public String O_TIME {get;set;}
            @AuraEnabled public String O_DEL_MSG {get;set;}
            @AuraEnabled public String O_UPD_MSG {get;set;}

            @AuraEnabled public List<IF_SERVICE_050_Res_T_RETURN> T_RETURN {get;set;}
            @AuraEnabled public List<IF_SERVICE_050_Res_T_MOTION> T_MOTION {get;set;}
            @AuraEnabled public List<IF_SERVICE_050_Res_T_MATERIAL> T_MATERIAL {get;set;}
            @AuraEnabled public List<IF_SERVICE_050_Res_T_DOC> T_DOC {get;set;}
            @AuraEnabled public List<IF_SERVICE_050_Res_T_DEL> T_DEL {get;set;}
            @AuraEnabled public List<IF_SERVICE_050_Res_T_TMP> T_TMP {get;set;}
            @AuraEnabled public List<IF_SERVICE_050_Res_T_DEL_SR> T_DEL_SR {get;set;}
            @AuraEnabled public List<IF_SERVICE_050_Res_T_TMP_SR> T_TMP_SR {get;set;}
            @AuraEnabled public List<IF_SERVICE_050_Res_T_CONSIGN> T_CONSIGN {get;set;}
                         
            @AuraEnabled public IF_SERVICE_050_Res_O_RETURN O_RETURN {get;set;}
        }

        public class IF_SERVICE_050_Res_T_RETURN { 
            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }

        public class IF_SERVICE_050_Res_O_RETURN{
            @AuraEnabled public String TYPE {get;set;}
            @AuraEnabled public String CODE {get;set;}
            @AuraEnabled public String MESSAGE {get;set;}
        }
        public class IF_SERVICE_050_Res_T_MOTION { 
            @AuraEnabled public String MANDT {get;set;} // ? Client
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
        public class IF_SERVICE_050_Res_T_MATERIAL { 
            @AuraEnabled public String MANDT   {get;set;} // ? Client
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
        public class IF_SERVICE_050_Res_T_DOC {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String MIMETYPE {get;set;}
            @AuraEnabled public String FILEDATA {get;set;}
            @AuraEnabled public String DESCRIPTION {get;set;}
            @AuraEnabled public String FLAG {get;set;}
            @AuraEnabled public String DOCNO {get;set;}             
        }
        public class IF_SERVICE_050_Res_T_DEL {
            @AuraEnabled public String DOCNO {get;set;}
            @AuraEnabled public String FILENAME {get;set;}             
        }
        public class IF_SERVICE_050_Res_T_TMP { 
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String IF_DESC {get;set;}
            @AuraEnabled public String EVISEQX {get;set;}
            @AuraEnabled public String LINE {get;set;}
            @AuraEnabled public String FILE_SIZE {get;set;}            
        }
        public class IF_SERVICE_050_Res_T_DEL_SR {
            @AuraEnabled public String DOCNO {get;set;}
            @AuraEnabled public String FILENAME {get;set;}              
        }
        public class IF_SERVICE_050_Res_T_TMP_SR {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String IF_DESC {get;set;}
            @AuraEnabled public String EVISEQX {get;set;}
            @AuraEnabled public String LINE {get;set;}
            @AuraEnabled public String FILE_SIZE {get;set;}             
        }
        public class IF_SERVICE_050_Res_T_CONSIGN {
            @AuraEnabled public String AUFNR {get;set;}
            @AuraEnabled public String QMNUM {get;set;}
            @AuraEnabled public String ZSEQN {get;set;}
            @AuraEnabled public String WERKS {get;set;}
            @AuraEnabled public String LIFNR {get;set;}
            @AuraEnabled public String NAME1 {get;set;}
            @AuraEnabled public String ZCOSTC {get;set;}
            @AuraEnabled public String ZCOSTC_T {get;set;}
            @AuraEnabled public String ZPORD {get;set;}
            @AuraEnabled public String ZPORD_T {get;set;}
            @AuraEnabled public String ZACTIVI {get;set;}
            @AuraEnabled public String ZACTIVI_T {get;set;}
            @AuraEnabled public String ZTRANF {get;set;}
            @AuraEnabled public String ZTRANF_T {get;set;}
            @AuraEnabled public String ZTRANT {get;set;}
            @AuraEnabled public String ZDISTA {get;set;}
            @AuraEnabled public String ZEXPEN {get;set;}
            @AuraEnabled public String WAERS {get;set;}
            @AuraEnabled public String REMARK {get;set;}
            @AuraEnabled public String CONFID {get;set;}
            @AuraEnabled public String CONFDT {get;set;}
            @AuraEnabled public String CONFTM {get;set;}             
        }        
                
        

// ** IF-SERVICE-052				
/**
  */
  /**
         * Wrapper Name         : IF_SERVICE_052
         * SFDC interface Id    : IF-SERVICE-052
         * New I/F              : ZCRM_CS_WEB_JOB_CONF_CANC
         * Description          :  DNS 국내 서비스리포트 확정을 취소하기 위한 기능
  */
  /** REQUEST
       */        
      public class IF_SERVICE_052_Req { 
        @AuraEnabled public String I_AUFNR {get;set;} // ? Order Number
    }

  /** RESPONSE
       */        
      public class IF_SERVICE_052_Res { 
        @AuraEnabled public IF_SERVICE_052_Res_O_RETURN O_RETURN {get;set;} // ? O_RETURN
    }
    
    public class IF_SERVICE_052_Res_O_RETURN { 
        @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled public String CODE    {get;set;} // ? Message code
        @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
    
    }

    
/**
 * Wrapper Name         : IF_SERVICE_054
 * SFDC interface Id    : IF-SERVICE-054
 * New I/F              : ZCRM_CS_SEARCH_CLAIM_RECEIPT
 * Description          : 서비스리포트 조회
 * Endpoint             : http://218.147.24.51:4148/invoke/di_salesforce.serv.CS.main:DICRM_CS_SEARCH_CLAIM_RECEIPT_M
    */ 
    public class IF_SERVICE_054_Req{ 
        @AuraEnabled public String                          I_CHECK     {get;set;} 
        @AuraEnabled public String                          I_REF_NO    {get;set;} 
        @AuraEnabled public String                          I_READ      {get;set;}
        @AuraEnabled public IF_SERVICE_054_Req_I_ORDER      I_ORDER     {get;set;} 
        @AuraEnabled public IF_SERVICE_054_Req_I_USERINFO   I_USERINFO  {get;set;} 

        public IF_SERVICE_054_Req(){}
    }
    public class IF_SERVICE_054_Req_I_ORDER{
        @AuraEnabled public String AUFNR    {get;set;}
        @AuraEnabled public String KTEXT    {get;set;}

        public IF_SERVICE_054_Req_I_ORDER(){}
    } 
    public class IF_SERVICE_054_Req_I_USERINFO{
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

        public IF_SERVICE_054_Req_I_USERINFO(){}
    } 
    public class IF_SERVICE_054_Res{ 
        @AuraEnabled public String                                  O_EQART           {get;set;}
        @AuraEnabled public String                                  O_ILART           {get;set;}
        @AuraEnabled public String                                  O_NOT_DELIVERY    {get;set;}
        @AuraEnabled public String                                  O_AUFNR           {get;set;}
        @AuraEnabled public String                                  O_REF_NO          {get;set;}
        @AuraEnabled public String                                  O_TEXT            {get;set;}
        @AuraEnabled public String                                  O_TEXT_RJ         {get;set;}          
        @AuraEnabled public String                                  O_BYRJD           {get;set;}      
        @AuraEnabled public String                                  O_BYRJT           {get;set;}      
        @AuraEnabled public String                                  O_BYRJM           {get;set;}      
        @AuraEnabled public String                                  O_RJXO            {get;set;}      
        @AuraEnabled public String                                  O_USR11           {get;set;}      
        @AuraEnabled public String                                  O_CITY1           {get;set;}      
        @AuraEnabled public String                                  O_STREET          {get;set;}          
        @AuraEnabled public String                                  O_SERIES_NAME     {get;set;}              
        @AuraEnabled public String                                  O_UNIT_NAME       {get;set;}          
        @AuraEnabled public String                                  O_UNIT_SUB_NAME   {get;set;}              
        @AuraEnabled public String                                  O_UNIT_SUB_DESC   {get;set;}              
        @AuraEnabled public String                                  O_MANHOUR_VAL     {get;set;}              
        @AuraEnabled public String                                  O_HUMAN_VAL       {get;set;}          
        @AuraEnabled public String                                  O_BILL_CATEGORY   {get;set;}              
        @AuraEnabled public String                                  O_MANHOUR_USE_YN  {get;set;}                  
        @AuraEnabled public String                                  O_MANHOUR_REASON  {get;set;}                  
        @AuraEnabled public String                                  O_WORK_ITEM_NAME  {get;set;}                  
        @AuraEnabled public String                                  O_LOEKZ           {get;set;}  
        @AuraEnabled public String                                  O_STATUS          {get;set;}           
        @AuraEnabled public IF_SERVICE_054_Res_O_AMOUNT             O_AMOUNT          {get;set;}
        @AuraEnabled public IF_SERVICE_054_Res_O_INFO               O_INFO            {get;set;}
        @AuraEnabled public IF_SERVICE_054_Res_O_CODE               O_CODE            {get;set;}
        @AuraEnabled public IF_SERVICE_054_Res_O_HISTORY            O_HISTORY         {get;set;}
        @AuraEnabled public IF_SERVICE_054_Res_O_RETURN             O_RETURN          {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_MATERIAL>     T_MATERIAL        {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_MOTION>       T_MOTION          {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_DOC>          T_DOC             {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_SUB>          T_SUB             {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_DATA>         T_DATA            {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_DOC_INFO>     T_DOC_INFO        {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_DOC_SR>       T_DOC_SR          {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_TEXT_D>       T_TEXT_D          {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_TEXT_C>       T_TEXT_C          {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_TEXT_A>       T_TEXT_A          {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_CONSIGN>      T_CONSIGN         {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_TEXT_CR>      T_TEXT_CR         {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_ZCST0061>     T_ZCST0061        {get;set;}
        @AuraEnabled public List<IF_SERVICE_054_Res_T_ZCST0062>     T_ZCST0062        {get;set;}
 
        public IF_SERVICE_054_Res(){}
    }
    public class IF_SERVICE_054_Res_O_RETURN{
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_SERVICE_054_Res_O_RETURN(){}
    }
    public class IF_SERVICE_054_Res_O_AMOUNT{
        @AuraEnabled public String TOTAL    {get;set;}
        @AuraEnabled public String VAT      {get;set;}
        @AuraEnabled public String WAERS    {get;set;}

        public IF_SERVICE_054_Res_O_AMOUNT(){}
    }
    public class IF_SERVICE_054_Res_O_INFO{
        @AuraEnabled public String MANDT             {get;set;}              
        @AuraEnabled public String AUFNR             {get;set;}              
        @AuraEnabled public String AUART             {get;set;}              
        @AuraEnabled public String ORDER_TYPE_TXT    {get;set;}                      
        @AuraEnabled public String QMNUM             {get;set;}      
        @AuraEnabled public String ILART             {get;set;}              
        @AuraEnabled public String DMACTTYPE_TXT     {get;set;}                      
        @AuraEnabled public String QMDAT             {get;set;}              
        @AuraEnabled public String GSTRP             {get;set;}              
        @AuraEnabled public String LTRMN             {get;set;}              
        @AuraEnabled public String QMTXT             {get;set;}              
        @AuraEnabled public String TXTQM             {get;set;}              
        @AuraEnabled public String EQUNR             {get;set;}              
        @AuraEnabled public String MATNR             {get;set;}              
        @AuraEnabled public String TYPBZ             {get;set;}              
        @AuraEnabled public String SERNR             {get;set;}              
        @AuraEnabled public String INBDT             {get;set;}              
        @AuraEnabled public String RBNR              {get;set;}          
        @AuraEnabled public String IDATE             {get;set;}              
        @AuraEnabled public String STAND_WE          {get;set;}              
        @AuraEnabled public String MDOCM             {get;set;}              
        @AuraEnabled public String KUNNR             {get;set;}              
        @AuraEnabled public String NAME              {get;set;}          
        @AuraEnabled public String TELEPHONE         {get;set;}                  
        @AuraEnabled public String REP_NAME          {get;set;}              
        @AuraEnabled public String TAX_NO_2          {get;set;}              
        @AuraEnabled public String ABCKZ             {get;set;}              
        @AuraEnabled public String BEBER             {get;set;}              
        @AuraEnabled public String CONTACT_TYPE      {get;set;}                  
        @AuraEnabled public String CONTACT_NAME      {get;set;}                  
        @AuraEnabled public String CONTACT_MOBILE    {get;set;}                      
        @AuraEnabled public String CONTACT_TEL       {get;set;}                  
        @AuraEnabled public String PART_PRICE        {get;set;}                  
        @AuraEnabled public String LABOR_PRICE       {get;set;}                  
        @AuraEnabled public String TOT_AMOUNT        {get;set;}                  
        @AuraEnabled public String DISCOUNT_AMT      {get;set;}                  
        @AuraEnabled public String WAERS             {get;set;}              
        @AuraEnabled public String VBELN             {get;set;}              
        @AuraEnabled public String ERDAT             {get;set;}              
        @AuraEnabled public String ERNAM             {get;set;}              
        @AuraEnabled public String ERZET             {get;set;}              
        @AuraEnabled public String AEDAT             {get;set;}              
        @AuraEnabled public String AENAM             {get;set;}              
        @AuraEnabled public String AEZET             {get;set;}              
        @AuraEnabled public String ARBPL             {get;set;}              
        @AuraEnabled public String WTY_TYPE          {get;set;}              
        @AuraEnabled public String NOTIFTIME         {get;set;}                  
        @AuraEnabled public String MOBILE            {get;set;}              
        @AuraEnabled public String LTRUR             {get;set;}              
        @AuraEnabled public String ISMNW             {get;set;}              
        @AuraEnabled public String ZDIST             {get;set;}              
        @AuraEnabled public String OTHER_COST        {get;set;}                  
        @AuraEnabled public String ZENGNO            {get;set;}              
        @AuraEnabled public String USNAM             {get;set;}              
        @AuraEnabled public String UDATE             {get;set;}              
        @AuraEnabled public String UTIME             {get;set;}              

        public IF_SERVICE_054_Res_O_INFO(){}
    }
    public class IF_SERVICE_054_Res_O_CODE{
        @AuraEnabled public String CODE_01  {get;set;}
        @AuraEnabled public String CODE_02  {get;set;}
        @AuraEnabled public String CODE_03  {get;set;}
        @AuraEnabled public String TEXT     {get;set;}
        @AuraEnabled public String TEXT2    {get;set;}

        public IF_SERVICE_054_Res_O_CODE(){}
    }
    public class IF_SERVICE_054_Res_O_HISTORY{
        @AuraEnabled public String MANDT           {get;set;}    
        @AuraEnabled public String QMNUM           {get;set;}    
        @AuraEnabled public String SEQNO           {get;set;}    
        @AuraEnabled public String OTGRP           {get;set;}    
        @AuraEnabled public String OTEIL           {get;set;}    
        @AuraEnabled public String KURZTEXT        {get;set;}    
        @AuraEnabled public String FEGRP           {get;set;}    
        @AuraEnabled public String FECOD           {get;set;}    
        @AuraEnabled public String TXTCDFE         {get;set;}    
        @AuraEnabled public String FETXT           {get;set;}    
        @AuraEnabled public String SYMPTOM_ADD_TXT {get;set;}            
        @AuraEnabled public String URGRP           {get;set;}    
        @AuraEnabled public String URCOD           {get;set;}    
        @AuraEnabled public String TXTCDUR         {get;set;}    
        @AuraEnabled public String URTXT           {get;set;}    
        @AuraEnabled public String CAUSE_ADD_TXT   {get;set;}            
        @AuraEnabled public String MNGRP           {get;set;}    
        @AuraEnabled public String MNCOD           {get;set;}    
        @AuraEnabled public String TXTCDMA         {get;set;}    
        @AuraEnabled public String MATXT           {get;set;}    
        @AuraEnabled public String ACT_ADD_TXT     {get;set;}        
        @AuraEnabled public String FAULT_CAUSE     {get;set;}        
        @AuraEnabled public String PHENO_ADD_TXT   {get;set;}            
        @AuraEnabled public String BLCOD           {get;set;}    
        @AuraEnabled public String BLCOD_T         {get;set;}    
        @AuraEnabled public String INCLUDE         {get;set;} // 원래 필드명은 .INCLUDE
        @AuraEnabled public String ERDAT           {get;set;}    
        @AuraEnabled public String ERNAM           {get;set;}    
        @AuraEnabled public String ERZET           {get;set;}    
        @AuraEnabled public String AEDAT           {get;set;}    
        @AuraEnabled public String AENAM           {get;set;}    
        @AuraEnabled public String AEZET           {get;set;}    
        @AuraEnabled public String TXTQM           {get;set;}    

        public IF_SERVICE_054_Res_O_HISTORY(){}
    }
    public class IF_SERVICE_054_Res_T_MATERIAL{
        @AuraEnabled public String MANDT          {get;set;}          
        @AuraEnabled public String AUFNR          {get;set;}          
        @AuraEnabled public String WORKNO         {get;set;}          
        @AuraEnabled public String SEQNO          {get;set;}          
        @AuraEnabled public String MATNR          {get;set;}      
        @AuraEnabled public String MEINS          {get;set;}          
        @AuraEnabled public String SUPPLY_TYPE    {get;set;}              
        @AuraEnabled public String CHANGE_DT      {get;set;}              
        @AuraEnabled public String EBELN          {get;set;}          
        @AuraEnabled public String EBELP          {get;set;}          
        @AuraEnabled public String MBLNR          {get;set;}          
        @AuraEnabled public String GI_MBLNR       {get;set;}          
        @AuraEnabled public String LIFNR          {get;set;}          
        @AuraEnabled public String NAME1          {get;set;}          
        @AuraEnabled public String NETWR          {get;set;}          
        @AuraEnabled public String BRTWR          {get;set;}          
        @AuraEnabled public String FREIGHT        {get;set;}          
        @AuraEnabled public String WAERS          {get;set;}          
        @AuraEnabled public String BELNR          {get;set;}          
        @AuraEnabled public String RETURN_YN      {get;set;}              
        @AuraEnabled public String ERDAT          {get;set;}          
        @AuraEnabled public String ERNAM          {get;set;}          
        @AuraEnabled public String ERZET          {get;set;}          
        @AuraEnabled public String AEDAT          {get;set;}          
        @AuraEnabled public String AENAM          {get;set;}          
        @AuraEnabled public String AEZET          {get;set;}          
        @AuraEnabled public String ITEM_CAT       {get;set;}          
        @AuraEnabled public String RETURN_TYPE    {get;set;}              
        @AuraEnabled public String RETURN_TEXT    {get;set;}              
        @AuraEnabled public String PGMNG          {get;set;}          
        @AuraEnabled public String READ_ONLY      {get;set;}              
        @AuraEnabled public String MENGE          {get;set;}          
        @AuraEnabled public String MENGE_GI       {get;set;}          
        @AuraEnabled public String READ_ONLY_02   {get;set;}              
        @AuraEnabled public String READ_ONLY_03   {get;set;}              
        @AuraEnabled public String MAKTX          {get;set;}          
        @AuraEnabled public String CAUSE_PRT      {get;set;}              
        @AuraEnabled public String READ_ONLY_04   {get;set;}              
        @AuraEnabled public String ITEM_NUMBER    {get;set;}              
        @AuraEnabled public String NETWR_VISIBLE  {get;set;}                  
        @AuraEnabled public String QDATU          {get;set;}          
        @AuraEnabled public String QZEIT          {get;set;}          
        @AuraEnabled public String RTYPE_ENABLE   {get;set;}              
        @AuraEnabled public String GR             {get;set;}      
        @AuraEnabled public String REASON1        {get;set;}          
        @AuraEnabled public String REASON2        {get;set;}          

        public IF_SERVICE_054_Res_T_MATERIAL(){}
    }
    public class IF_SERVICE_054_Res_T_MOTION{
        @AuraEnabled public String MANDT          {get;set;}          
        @AuraEnabled public String AUFNR          {get;set;}          
        @AuraEnabled public String RUECK          {get;set;}          
        @AuraEnabled public String WORKNO         {get;set;}          
        @AuraEnabled public String SEQNO          {get;set;}          
        @AuraEnabled public String PERNR          {get;set;}          
        @AuraEnabled public String SVCMAN_NAME    {get;set;}              
        @AuraEnabled public String ISDD           {get;set;}      
        @AuraEnabled public String ISDZ           {get;set;}      
        @AuraEnabled public String AUSBS          {get;set;}          
        @AuraEnabled public String AUZTB          {get;set;}          
        @AuraEnabled public String ISMNW          {get;set;}          
        @AuraEnabled public String ISMNW_PDK      {get;set;}              
        @AuraEnabled public String HOL_CHK        {get;set;}          
        @AuraEnabled public String OT_CHK         {get;set;}          
        @AuraEnabled public String LTXA1          {get;set;}          
        @AuraEnabled public String RMZHL          {get;set;}          
        @AuraEnabled public String ISMNE          {get;set;}          
        @AuraEnabled public String ERDAT          {get;set;}          
        @AuraEnabled public String ERNAM          {get;set;}          
        @AuraEnabled public String ERZET          {get;set;}          
        @AuraEnabled public String AEDAT          {get;set;}          
        @AuraEnabled public String AENAM          {get;set;}          
        @AuraEnabled public String AEZET          {get;set;}          
        @AuraEnabled public String FLAG_0060      {get;set;}              
        @AuraEnabled public String WORKCD         {get;set;}          
        @AuraEnabled public String EXRSN          {get;set;}          

        public IF_SERVICE_054_Res_T_MOTION(){}
    }
    public class IF_SERVICE_054_Res_T_DOC{
        @AuraEnabled public String FILENAME       {get;set;}         
        @AuraEnabled public String MIMETYPE       {get;set;}         
        @AuraEnabled public String FILEDATA       {get;set;}         
        @AuraEnabled public String DESCRIPTION    {get;set;}             
        @AuraEnabled public String FLAG           {get;set;}     
        @AuraEnabled public String DOCNO          {get;set;}         

        public IF_SERVICE_054_Res_T_DOC(){}
    }
    public class IF_SERVICE_054_Res_T_SUB{
        @AuraEnabled public String KEY            {get;set;}
        @AuraEnabled public String VALUE          {get;set;}

        public IF_SERVICE_054_Res_T_SUB(){}
    }
    public class IF_SERVICE_054_Res_T_DATA{
        @AuraEnabled public String FILENAME       {get;set;}
        @AuraEnabled public String EVISEQX        {get;set;}
        @AuraEnabled public String LINE           {get;set;}

        public IF_SERVICE_054_Res_T_DATA(){}
    }
    public class IF_SERVICE_054_Res_T_DOC_INFO{
        @AuraEnabled public String AUFNR          {get;set;}  
        @AuraEnabled public String SEQNO          {get;set;}  
        @AuraEnabled public String DOCNO          {get;set;}  
        @AuraEnabled public String FILENAME       {get;set;}  
        @AuraEnabled public String FILESIZE       {get;set;}  
        @AuraEnabled public String DESCRIPTION    {get;set;}      
        @AuraEnabled public String DOC_ID         {get;set;}  
        @AuraEnabled public String STOR_CAT       {get;set;}  

        public IF_SERVICE_054_Res_T_DOC_INFO(){}
    }
    public class IF_SERVICE_054_Res_T_DOC_SR{
        @AuraEnabled public String AUFNR          {get;set;}      
        @AuraEnabled public String SEQNO          {get;set;}      
        @AuraEnabled public String DOCNO          {get;set;}      
        @AuraEnabled public String FILENAME       {get;set;}      
        @AuraEnabled public String FILESIZE       {get;set;}      
        @AuraEnabled public String DESCRIPTION    {get;set;}          
        @AuraEnabled public String DOC_ID         {get;set;}      
        @AuraEnabled public String STOR_CAT       {get;set;}      

        public IF_SERVICE_054_Res_T_DOC_SR(){}
    }
    public class IF_SERVICE_054_Res_T_TEXT_D{
        @AuraEnabled public String TDFORMAT       {get;set;}
        @AuraEnabled public String TDLINE         {get;set;}

        public IF_SERVICE_054_Res_T_TEXT_D(){}
    }
    public class IF_SERVICE_054_Res_T_TEXT_C{
        @AuraEnabled public String TDFORMAT       {get;set;}
        @AuraEnabled public String TDLINE         {get;set;}

        public IF_SERVICE_054_Res_T_TEXT_C(){}
    }
    public class IF_SERVICE_054_Res_T_TEXT_A{
        @AuraEnabled public String TDFORMAT       {get;set;}
        @AuraEnabled public String TDLINE         {get;set;}

        public IF_SERVICE_054_Res_T_TEXT_A(){}
    }
    public class IF_SERVICE_054_Res_T_CONSIGN{
        @AuraEnabled public String AUFNR          {get;set;}  
        @AuraEnabled public String QMNUM          {get;set;}  
        @AuraEnabled public String ZSEQN          {get;set;}  
        @AuraEnabled public String WERKS          {get;set;}  
        @AuraEnabled public String LIFNR          {get;set;}  
        @AuraEnabled public String NAME1          {get;set;}  
        @AuraEnabled public String ZCOSTC         {get;set;}  
        @AuraEnabled public String ZCOSTC_T       {get;set;}  
        @AuraEnabled public String ZPORD          {get;set;}  
        @AuraEnabled public String ZPORD_T        {get;set;}  
        @AuraEnabled public String ZACTIVI        {get;set;}  
        @AuraEnabled public String ZACTIVI_T      {get;set;}      
        @AuraEnabled public String ZTRANF         {get;set;}  
        @AuraEnabled public String ZTRANF_T       {get;set;}  
        @AuraEnabled public String ZTRANT         {get;set;}  
        @AuraEnabled public String ZDISTA         {get;set;}  
        @AuraEnabled public String ZEXPEN         {get;set;}  
        @AuraEnabled public String WAERS          {get;set;}  
        @AuraEnabled public String REMARK         {get;set;}  
        @AuraEnabled public String CONFID         {get;set;}  
        @AuraEnabled public String CONFDT         {get;set;}  
        @AuraEnabled public String CONFTM         {get;set;}  

        public IF_SERVICE_054_Res_T_CONSIGN(){}
    }
    public class IF_SERVICE_054_Res_T_TEXT_CR{
        @AuraEnabled public String TDFORMAT       {get;set;}
        @AuraEnabled public String TDLINE         {get;set;}

        public IF_SERVICE_054_Res_T_TEXT_CR(){}
    }
    public class IF_SERVICE_054_Res_T_ZCST0061{
        @AuraEnabled public String AUFNR          {get;set;}     
        @AuraEnabled public String STDCD          {get;set;}     
        @AuraEnabled public String SERIES_NAME    {get;set;}         
        @AuraEnabled public String MODEL          {get;set;}     
        @AuraEnabled public String OBJPT          {get;set;}     
        @AuraEnabled public String STDWK          {get;set;}     
        @AuraEnabled public String MANHOUR_VAL    {get;set;}         
        @AuraEnabled public String HUMAN_VAL      {get;set;}         
        @AuraEnabled public String REGYN          {get;set;}     

        public IF_SERVICE_054_Res_T_ZCST0061(){}
    }
    public class IF_SERVICE_054_Res_T_ZCST0062{
        @AuraEnabled public String AUFNR          {get;set;}
        @AuraEnabled public String EXRSN          {get;set;}
        @AuraEnabled public String STDYN          {get;set;}
        @AuraEnabled public String SMTP_ADDR      {get;set;}

        public IF_SERVICE_054_Res_T_ZCST0062(){}
    }
}