public with sharing class IF_ERP_SalesOrder_Classes {
    public IF_ERP_SalesOrder_Classes() {}

    /** SFDC interface Id   : IF-OPTY-033
     * RFC Name             : ZCRM_SD_DNSA_MODEL_LST_US
     * Description          : DNSA Service Order 생성/수정
        */
        public class IF_OPTY_033_Req {
            @AuraEnabled public String I_FROM   {get;set;}
            @AuraEnabled public String I_TO     {get;set;}

            public IF_OPTY_033_Req(){}
        }
        public class IF_OPTY_033_Res {
            @AuraEnabled public IF_OPTY_033_Res_O_RETURN        O_RETURN   {get;set;}
            @AuraEnabled public List<IF_OPTY_033_Res_T_LIST>    T_LIST     {get;set;}

            public IF_OPTY_033_Res(){}
        }
        public class IF_OPTY_033_Res_O_RETURN{
            @AuraEnabled public String TYPE     {get;set;}
            @AuraEnabled public String CODE     {get;set;}
            @AuraEnabled public String MESSAGE  {get;set;}

            public IF_OPTY_033_Res_O_RETURN(){}
        }
        public class IF_OPTY_033_Res_T_LIST{
            @AuraEnabled public String BASE_CODE    {get;set;}
            @AuraEnabled public String ZZSQ         {get;set;}
            @AuraEnabled public String MDLNM        {get;set;}
            @AuraEnabled public String SATNR        {get;set;}
            @AuraEnabled public String AEDAT        {get;set;}

            public IF_OPTY_033_Res_T_LIST(){}
        }

    /** SFDC interface Id   : IF-CSPLUS-038
     * RFC Name             : ZCRM_CS_SERVICE_ORDER_DEL
     * Description          : Service Order 취소 (삭제)
        */
        public class IF_CSPLUS_038_Req {
            @AuraEnabled public String I_AUFNR      {get;set;}

            public IF_CSPLUS_038_Req(){}
        }
        public class IF_CSPLUS_038_Res {
            @AuraEnabled public String                           E_AUFNR   {get;set;}
            @AuraEnabled public List<IF_CSPLUS_038_Res_T_RETURN> T_RETURN  {get;set;}

            public IF_CSPLUS_038_Res(){}
        }
        public class IF_CSPLUS_038_Res_T_RETURN{
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String ID           {get;set;}
            @AuraEnabled public String IF_NUMBER    {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}
            @AuraEnabled public String LOG_NO       {get;set;}

            @AuraEnabled public String LOG_MSG_NO   {get;set;}
            @AuraEnabled public String MESSAGE_V1   {get;set;}
            @AuraEnabled public String MESSAGE_V2   {get;set;}
            @AuraEnabled public String MESSAGE_V3   {get;set;}
            @AuraEnabled public String MESSAGE_V4   {get;set;}
            
            @AuraEnabled public String PARAMETER    {get;set;}
            @AuraEnabled public String ROW          {get;set;}
            @AuraEnabled public String FIELD        {get;set;}
            @AuraEnabled public String IF_SYSTEM    {get;set;}

            public IF_CSPLUS_038_Res_T_RETURN(){}
        }

    /** SFDC interface Id   : IF-CSPLUS-040
     * RFC Name             : ZCRM_CS_A_CLAIM_RESULT_SVC_SAV
     * Description          : DNSA 서비스리포트 결과 저장
        */
        public class IF_CSPLUS_040_Req{
            @AuraEnabled public String                              I_LANGU     {get;set;}
            @AuraEnabled public IF_CSPLUS_040_Req_I_HEADER          I_HEADER    {get;set;}
            @AuraEnabled public IF_CSPLUS_040_Req_I_USERINFO        I_USERINFO  {get;set;}
            @AuraEnabled public List<IF_CSPLUS_040_Req_T_CLAIM>     T_CLAIM     {get;set;}
            @AuraEnabled public List<IF_CSPLUS_040_Req_T_OTHER>     T_OTHER     {get;set;}
            
            @AuraEnabled public List<IF_CSPLUS_040_Req_T_DATE>      T_DATE      {get;set;}
            @AuraEnabled public List<IF_CSPLUS_040_Req_T_PART>      T_PART      {get;set;}
            @AuraEnabled public List<IF_CSPLUS_040_Req_T_DEL>       T_DEL       {get;set;}
            @AuraEnabled public List<IF_CSPLUS_040_Req_T_TMP>       T_TMP       {get;set;}
            @AuraEnabled public List<IF_CSPLUS_040_Req_T_TEXT_S>    T_TEXT_S    {get;set;}
            
            @AuraEnabled public List<IF_CSPLUS_040_Req_T_TEXT_C>    T_TEXT_C    {get;set;}
            @AuraEnabled public List<IF_CSPLUS_040_Req_T_TEXT_A>    T_TEXT_A    {get;set;}

            public IF_CSPLUS_040_Req(){
                this.I_HEADER       = new IF_CSPLUS_040_Req_I_HEADER();
                this.I_USERINFO     = new IF_CSPLUS_040_Req_I_USERINFO();

                this.T_CLAIM        = new List<IF_CSPLUS_040_Req_T_CLAIM>();
                this.T_OTHER        = new List<IF_CSPLUS_040_Req_T_OTHER>();
                this.T_DATE         = new List<IF_CSPLUS_040_Req_T_DATE>();
                this.T_PART         = new List<IF_CSPLUS_040_Req_T_PART>();
                this.T_DEL          = new List<IF_CSPLUS_040_Req_T_DEL>();
                this.T_TMP          = new List<IF_CSPLUS_040_Req_T_TMP>();
                this.T_TEXT_S       = new List<IF_CSPLUS_040_Req_T_TEXT_S>();
                this.T_TEXT_C       = new List<IF_CSPLUS_040_Req_T_TEXT_C>();
                this.T_TEXT_A       = new List<IF_CSPLUS_040_Req_T_TEXT_A>();
            }
        }
        public class IF_CSPLUS_040_Req_I_HEADER{
            @AuraEnabled public String QMNUM               {get;set;}         
            @AuraEnabled public String TYPBZ               {get;set;}         
            @AuraEnabled public String SERNR               {get;set;}         
            @AuraEnabled public String WORKING_HR          {get;set;}             
            @AuraEnabled public String ARRVAL_DT           {get;set;}    

            @AuraEnabled public String FAIL_END_DT         {get;set;}                 
            @AuraEnabled public String BREAKDOWN           {get;set;}             
            @AuraEnabled public String REF_NO              {get;set;}         
            @AuraEnabled public String SHIP_TO             {get;set;}             
            @AuraEnabled public String VSBED               {get;set;}         
            
            @AuraEnabled public String AUTLF               {get;set;}         
            @AuraEnabled public String CARRIER             {get;set;}             
            @AuraEnabled public String ACCT_NO             {get;set;}             
            @AuraEnabled public String PARTS_INST_DT       {get;set;}                 

            public IF_CSPLUS_040_Req_I_HEADER(){}
        }
        public class IF_CSPLUS_040_Req_I_USERINFO{
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

            public IF_CSPLUS_040_Req_I_USERINFO(){}
        }
        public class IF_CSPLUS_040_Req_T_CLAIM{
            @AuraEnabled public String CLAIM_SEQ          {get;set;}                 
            @AuraEnabled public String CODE_01            {get;set;}             
            @AuraEnabled public String CODE_02            {get;set;}             
            @AuraEnabled public String CODE_03            {get;set;}             
            @AuraEnabled public String OTGRP              {get;set;} 

            @AuraEnabled public String OTEIL              {get;set;}             
            @AuraEnabled public String KURZTEXT           {get;set;}             
            @AuraEnabled public String KURZTEXT_L         {get;set;}                 
            @AuraEnabled public String FEGRP              {get;set;}             
            @AuraEnabled public String FECOD              {get;set;}             
            
            @AuraEnabled public String TXTCDFE            {get;set;}             
            @AuraEnabled public String FETXT              {get;set;}             
            @AuraEnabled public String SYMPTOM_ADD_TXT    {get;set;}                     
            @AuraEnabled public String URGRP              {get;set;}             
            @AuraEnabled public String URCOD              {get;set;}             
            
            @AuraEnabled public String TXTCDUR            {get;set;}             
            @AuraEnabled public String URTXT              {get;set;}             
            @AuraEnabled public String CAUSE_ADD_TXT      {get;set;}                     
            @AuraEnabled public String MNGRP              {get;set;}             
            @AuraEnabled public String MNCOD              {get;set;}             
            
            @AuraEnabled public String TXTCDMA            {get;set;}             
            @AuraEnabled public String MATXT              {get;set;}             
            @AuraEnabled public String ACT_ADD_TXT        {get;set;}                 
            @AuraEnabled public String FAULT_CAUSE        {get;set;}                 
            @AuraEnabled public String PHENO_ADD_TXT      {get;set;}                     
            
            @AuraEnabled public String BLCOD              {get;set;}             
            @AuraEnabled public String BLCOD_T            {get;set;}             

            public IF_CSPLUS_040_Req_T_CLAIM(){}
        }
        public class IF_CSPLUS_040_Req_T_OTHER{
            @AuraEnabled public String SEQNO          {get;set;}          
            @AuraEnabled public String TYPE           {get;set;}      
            @AuraEnabled public String CATEGORY       {get;set;}          
            @AuraEnabled public String DESCRIPTION    {get;set;}              
            @AuraEnabled public String VALUE          {get;set;}    
                  
            @AuraEnabled public String UNIT           {get;set;}      
            @AuraEnabled public String AMOUNT         {get;set;}          
            @AuraEnabled public String TOT_AMT        {get;set;}          
            @AuraEnabled public String WAERS          {get;set;}          

            public IF_CSPLUS_040_Req_T_OTHER(){}
        }
        public class IF_CSPLUS_040_Req_T_DATE{
            @AuraEnabled public String MANDT       {get;set;}        
            @AuraEnabled public String AUFNR       {get;set;}        
            @AuraEnabled public String QMNUM       {get;set;}        
            @AuraEnabled public String SEQNO       {get;set;}        
            @AuraEnabled public String REP_FR_DT   {get;set;}  

            @AuraEnabled public String REP_FR_TM   {get;set;}            
            @AuraEnabled public String REP_TO_DT   {get;set;}            
            @AuraEnabled public String REP_TO_TM   {get;set;}            
            @AuraEnabled public String ISMNW       {get;set;}        
            @AuraEnabled public String ISMNW_PDK   {get;set;}            
            
            @AuraEnabled public String ISMNE       {get;set;}        
            @AuraEnabled public String AIR_TRIP    {get;set;}        

            public IF_CSPLUS_040_Req_T_DATE(){}
        }
        public class IF_CSPLUS_040_Req_T_PART{
            @AuraEnabled public String SEQNO             {get;set;}       
            @AuraEnabled public String MATNR             {get;set;}       
            @AuraEnabled public String MAKTX             {get;set;}       
            @AuraEnabled public String MEINS             {get;set;}       
            @AuraEnabled public String MENGE             {get;set;}
            
            @AuraEnabled public String FOC_FLAG          {get;set;}       
            @AuraEnabled public String CAUSE_PRT         {get;set;}           
            @AuraEnabled public String RESP_FACTOR       {get;set;}           
            @AuraEnabled public String LOT_NO            {get;set;}       
            @AuraEnabled public String RETURN_YN         {get;set;}           
            
            @AuraEnabled public String RETURN_TYPE       {get;set;}           
            @AuraEnabled public String RETURN_TYPE_T     {get;set;}               
            @AuraEnabled public String RETURN_TEXT       {get;set;}           
            @AuraEnabled public String VSBED             {get;set;}       
            @AuraEnabled public String VTEXT             {get;set;}       
            
            @AuraEnabled public String APPNO             {get;set;}       
            @AuraEnabled public String WORKNO            {get;set;}       
            @AuraEnabled public String WAERS             {get;set;}       
            @AuraEnabled public String UNIT_PRICE        {get;set;}           
            @AuraEnabled public String AMOUNT            {get;set;}       
            
            @AuraEnabled public String SALESPRICE        {get;set;}           
            @AuraEnabled public String CON_MENGE         {get;set;}           
            @AuraEnabled public String STAN_PRICE        {get;set;}           
            @AuraEnabled public String PART_RATE         {get;set;}           
            @AuraEnabled public String DEPART_RATE       {get;set;}           
            
            @AuraEnabled public String RETURN_END_YN     {get;set;}               
            @AuraEnabled public String RETURN_QTY        {get;set;}           
            @AuraEnabled public String RETURN_DT         {get;set;}           
            @AuraEnabled public String CNF_QTY           {get;set;}       
            @AuraEnabled public String CNF_NETPR         {get;set;}           
            
            @AuraEnabled public String VERPR             {get;set;}       
            @AuraEnabled public String LIFNR             {get;set;}       
            @AuraEnabled public String ZSUPPLY           {get;set;}       
            @AuraEnabled public String DOCNUM            {get;set;}       
            @AuraEnabled public String NFNUM             {get;set;}       
            
            @AuraEnabled public String ENTRAD            {get;set;}       
            @AuraEnabled public String FATURA            {get;set;}       
            @AuraEnabled public String NFNUM2            {get;set;}       
            @AuraEnabled public String ERDAT             {get;set;}       
            @AuraEnabled public String ERNAM             {get;set;}       
            
            @AuraEnabled public String ERZET             {get;set;}       
            @AuraEnabled public String AEDAT             {get;set;}       
            @AuraEnabled public String AENAM             {get;set;}       
            @AuraEnabled public String AEZET             {get;set;}       
            @AuraEnabled public String AUFNR             {get;set;}       
            
            @AuraEnabled public String DNET_PRICE        {get;set;}           
            @AuraEnabled public String ZZWAGRP           {get;set;}       
            @AuraEnabled public String ZZWAGRPNM         {get;set;}           
            @AuraEnabled public String VKORG             {get;set;}       
            @AuraEnabled public String VTWEG             {get;set;}       
            
            @AuraEnabled public String SPART             {get;set;}       
            @AuraEnabled public String GWLDT             {get;set;}       
            @AuraEnabled public String MGANR_UE          {get;set;}       
            @AuraEnabled public String INVOICE_NO        {get;set;}           

            public IF_CSPLUS_040_Req_T_PART(){}
        }
        public class IF_CSPLUS_040_Req_T_DEL{
            @AuraEnabled public String DOCNO        {get;set;}
            @AuraEnabled public String FILENAME     {get;set;}

            public IF_CSPLUS_040_Req_T_DEL(){}
        }
        public class IF_CSPLUS_040_Req_T_TMP{
            @AuraEnabled public String FILENAME     {get;set;}            
            @AuraEnabled public String IF_DESC      {get;set;}        
            @AuraEnabled public String EVISEQX      {get;set;}            
            @AuraEnabled public String LINE         {get;set;}        
            @AuraEnabled public String FILE_SIZE    {get;set;}                

            public IF_CSPLUS_040_Req_T_TMP(){}
        }
        public class IF_CSPLUS_040_Req_T_TEXT_S{
            @AuraEnabled public String CLAIM_SEQ    {get;set;}
            @AuraEnabled public String TDFORMAT     {get;set;}
            @AuraEnabled public String TDLINE       {get;set;}

            public IF_CSPLUS_040_Req_T_TEXT_S(){}
        }
        public class IF_CSPLUS_040_Req_T_TEXT_C{
            @AuraEnabled public String CLAIM_SEQ    {get;set;}
            @AuraEnabled public String TDFORMAT     {get;set;}
            @AuraEnabled public String TDLINE       {get;set;}

            public IF_CSPLUS_040_Req_T_TEXT_C(){}
        }
        public class IF_CSPLUS_040_Req_T_TEXT_A{
            @AuraEnabled public String CLAIM_SEQ    {get;set;}
            @AuraEnabled public String TDFORMAT     {get;set;}
            @AuraEnabled public String TDLINE       {get;set;}

            public IF_CSPLUS_040_Req_T_TEXT_A(){}
        }
        public class IF_CSPLUS_040_Res{
            @AuraEnabled public List<IF_CSPLUS_040_Res_T_RETURN>    T_DATE      {get;set;}
            @AuraEnabled public IF_CSPLUS_040_Res_O_RETURN          O_RETURN    {get;set;}
            @AuraEnabled public String                              O_DEL_MSG   {get;set;}
            @AuraEnabled public String                              O_UPD_MSG   {get;set;}

            public IF_CSPLUS_040_Res(){}
        }
        public class IF_CSPLUS_040_Res_T_RETURN{
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}

            public IF_CSPLUS_040_Res_T_RETURN(){}
        }
        public class IF_CSPLUS_040_Res_O_RETURN{
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}

            public IF_CSPLUS_040_Res_O_RETURN(){}
        }

// ** IF-CSPLUS-044
/**
  */
  /**
         * SFDC interface Id    : IF-CSPLUS-044
         * RFC                  : ZCRM_CSACLAIM_RECEIPT_SVC_SAV2
         * Description          : DNSA Service Order 생성/수정
  */ 
    // REQUEST
        public class IF_CSPLUS_044_Req {
            @AuraEnabled public String I_UNAME  {get;set;}
            @AuraEnabled public String I_LANGU  {get;set;}
            @AuraEnabled public IF_CSPLUS_044_Req_I_HEADER       I_HEADER   {get;set;}
            @AuraEnabled public IF_CSPLUS_044_Req_I_USERINFO     I_USERINFO {get;set;}            
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_RETURN> T_RETURN {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_CLAIM>  T_CLAIM {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_DATE>   T_DATE {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_PART>   T_PART {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_OTHER>  T_OTHER {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_TMP>    T_TMP {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_DOC>    T_DOC {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_DEL>    T_DEL {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_TEXT_A> T_TEXT_A {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_TEXT_C> T_TEXT_C {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_TEXT_S> T_TEXT_S {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_TEXT_P> T_TEXT_P {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_FILE>   T_FILE {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_SIGN1>  T_SIGN1 {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Req_T_SIGN2>  T_SIGN2 {get;set;}            
        }
        public class IF_CSPLUS_044_Req_I_HEADER {
            @AuraEnabled public String CLAIM_NO {get;set;}
            @AuraEnabled public String QMNUM {get;set;}
            @AuraEnabled public String AUFNR {get;set;}
            @AuraEnabled public String NAME {get;set;}
            @AuraEnabled public String INBDT {get;set;}
            @AuraEnabled public String GWLDT_O {get;set;}
            @AuraEnabled public String WTY_TYPE {get;set;}
            @AuraEnabled public String GWLEN_O {get;set;}
            @AuraEnabled public String ZZ_EX_TERM_VL {get;set;}
            @AuraEnabled public String ZZ_EX_OPH {get;set;}
            @AuraEnabled public String ZZ_CS_CAPA {get;set;}
            @AuraEnabled public String ZZ_CS_EWRNT_MM {get;set;}
            @AuraEnabled public String ZZ_CS_EWRNT_HR {get;set;}
            @AuraEnabled public String ZZ_EX_TERM_TYP {get;set;}
            @AuraEnabled public String ZZ_EX_TERM_TYP_TXT {get;set;}
            @AuraEnabled public String ZZ_EX_TERM_TYP_B {get;set;}
            @AuraEnabled public String ZZ_EX_TERM_TYP_B_TXT {get;set;}
            @AuraEnabled public String ZZ_EX_END_DTZZ_EX_END_DT {get;set;}
            @AuraEnabled public String ZZ_WARR_S_DT {get;set;}
            @AuraEnabled public String ZZ_WARR_E_DT {get;set;}
            @AuraEnabled public String ILART {get;set;}
            @AuraEnabled public String ILATX {get;set;}
            @AuraEnabled public String WORKING_HR {get;set;}
            @AuraEnabled public String PARTS_INST_DT {get;set;}
            @AuraEnabled public String FAIL_DT {get;set;}
            @AuraEnabled public String FAIL_TM {get;set;}
            @AuraEnabled public String QMDAT {get;set;}
            @AuraEnabled public String REG_TIME {get;set;}
            @AuraEnabled public String REQUIRE_DAT {get;set;}
            @AuraEnabled public String REQUIRE_TIM {get;set;}
            @AuraEnabled public String ARRVAL_DT {get;set;}
            @AuraEnabled public String ARRVAL_TM {get;set;}
            @AuraEnabled public String FAIL_END_DT {get;set;}
            @AuraEnabled public String FAIL_END_TM {get;set;}
            @AuraEnabled public String REPAIR_DT {get;set;}
            @AuraEnabled public String WARR_END_DT {get;set;}
            @AuraEnabled public String BEBER {get;set;}
            @AuraEnabled public String BEBER_T {get;set;}
            @AuraEnabled public String STORT {get;set;}
            @AuraEnabled public String STORT_T {get;set;}
            @AuraEnabled public String ABCKZ {get;set;}
            @AuraEnabled public String ABCKZ_T {get;set;}
            @AuraEnabled public String MSGRP {get;set;}
            @AuraEnabled public String REPORTEDBY {get;set;}
            @AuraEnabled public String BREAKDOWN {get;set;}
            @AuraEnabled public String EQUNR {get;set;}
            @AuraEnabled public String RBNR {get;set;}
            @AuraEnabled public String TYPBZ {get;set;}
            @AuraEnabled public String SERNR {get;set;}
            @AuraEnabled public String WERKS {get;set;}
            @AuraEnabled public String WARR_COUNTER {get;set;}
            @AuraEnabled public String CODING {get;set;}
            @AuraEnabled public String CODE_TEXT {get;set;}
            @AuraEnabled public String ATTACHMENT_CODE {get;set;}
            @AuraEnabled public String ATTACHMENT {get;set;}
            @AuraEnabled public String WORK_AREA_CODE {get;set;}
            @AuraEnabled public String WORK_AREA {get;set;}
            @AuraEnabled public String WORK_TYPE_CODE {get;set;}
            @AuraEnabled public String WORK_TYPE {get;set;}
            @AuraEnabled public String MAINTROOM {get;set;}
            @AuraEnabled public String MAINTROOM_CODE {get;set;}
            @AuraEnabled public String NOTIF_DATE {get;set;}
            @AuraEnabled public String NOTIFTIME {get;set;}
            @AuraEnabled public String STRMLFNDATE {get;set;}
            @AuraEnabled public String STRMLFNTIME {get;set;}
            @AuraEnabled public String DESENDDATE {get;set;}
            @AuraEnabled public String DESENDTM {get;set;}
            @AuraEnabled public String STAND_WE {get;set;}
            @AuraEnabled public String PHENOMENA {get;set;}
            @AuraEnabled public String CODE_01 {get;set;}
            @AuraEnabled public String CODE_02 {get;set;}
            @AuraEnabled public String CODE_03 {get;set;}
            @AuraEnabled public String DL_CODEGRP {get;set;}
            @AuraEnabled public String DL_CODE {get;set;}
            @AuraEnabled public String STXT_GRPCD {get;set;}
            @AuraEnabled public String D_CODEGRP {get;set;}
            @AuraEnabled public String D_CODE {get;set;}
            @AuraEnabled public String TXT_PROBCD {get;set;}
            @AuraEnabled public String POWERTRAIN {get;set;}
            @AuraEnabled public String SHIP_TO {get;set;}
            @AuraEnabled public String DESCRIPT {get;set;}
            @AuraEnabled public String TXTQM {get;set;}
            @AuraEnabled public String REF_NO {get;set;}
            @AuraEnabled public String INACT_STAT {get;set;}
            @AuraEnabled public String NOCO_STAT {get;set;}
            @AuraEnabled public String SMTP_ADDR {get;set;}
            @AuraEnabled public String CHECK_SAVED {get;set;}
            @AuraEnabled public String STREET {get;set;}
            @AuraEnabled public String CITY1 {get;set;}
            @AuraEnabled public String POST_CODE1 {get;set;}
            @AuraEnabled public String TEL_NUMBER {get;set;}
            @AuraEnabled public String CONTROL_TYP {get;set;}
            @AuraEnabled public String CONTROL_SN {get;set;}
            @AuraEnabled public String VSBED {get;set;}
            @AuraEnabled public String AUTLF {get;set;}
            @AuraEnabled public String CARRIER {get;set;}
            @AuraEnabled public String ACCT_NO {get;set;}
            @AuraEnabled public String SIGNED_DATE {get;set;}
            @AuraEnabled public String CUSTOMER_NAME {get;set;}
            @AuraEnabled public String CUSTOMER_TITLE {get;set;}
        }
        public class IF_CSPLUS_044_Req_I_USERINFO {
            @AuraEnabled public String BNAME {get;set;}
            @AuraEnabled public String RNAME {get;set;}
            @AuraEnabled public String HIER {get;set;}
            @AuraEnabled public String KUNNR {get;set;}
            @AuraEnabled public String NAME1 {get;set;}
            @AuraEnabled public String LIFNR {get;set;}
            @AuraEnabled public String VKORG {get;set;}
            @AuraEnabled public String VTWEG {get;set;}
            @AuraEnabled public String SPART {get;set;}
            @AuraEnabled public String WERKS {get;set;}
            @AuraEnabled public String WAERS {get;set;}
            @AuraEnabled public String ARBPL {get;set;}
            @AuraEnabled public String PARNR {get;set;}
            @AuraEnabled public String ENAME {get;set;}
            @AuraEnabled public String KUNN2 {get;set;}
            @AuraEnabled public String LAND1 {get;set;}
            @AuraEnabled public String REGIO {get;set;}
            @AuraEnabled public String LGORT {get;set;}
            @AuraEnabled public String VERAN {get;set;}
            @AuraEnabled public String DF_CHK {get;set;}
            @AuraEnabled public String CO_CHK {get;set;}
            @AuraEnabled public String DEL_CHK {get;set;}
            @AuraEnabled public String FOREIGN {get;set;}
            @AuraEnabled public String BZIRK {get;set;}
            @AuraEnabled public String ERDAT {get;set;}
            @AuraEnabled public String ERNAM {get;set;}
            @AuraEnabled public String AEDAT {get;set;}
            @AuraEnabled public String AENAM {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_RETURN {
            @AuraEnabled public String TYPE {get;set;}
            @AuraEnabled public String MESSAGE {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_CLAIM {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String CODE_01 {get;set;}
            @AuraEnabled public String CODE_02 {get;set;}
            @AuraEnabled public String CODE_03 {get;set;}
            @AuraEnabled public String OTGRP {get;set;}
            @AuraEnabled public String OTEIL {get;set;}
            @AuraEnabled public String KURZTEXT {get;set;}
            @AuraEnabled public String KURZTEXT_L {get;set;}
            @AuraEnabled public String FEGRP {get;set;}
            @AuraEnabled public String FECOD {get;set;}
            @AuraEnabled public String TXTCDFE {get;set;}
            @AuraEnabled public String FETXT {get;set;}
            @AuraEnabled public String SYMPTOM_ADD_TXT {get;set;}
            @AuraEnabled public String URGRP {get;set;}
            @AuraEnabled public String URCOD {get;set;}
            @AuraEnabled public String TXTCDUR {get;set;}
            @AuraEnabled public String URTXT {get;set;}
            @AuraEnabled public String CAUSE_ADD_TXT {get;set;}
            @AuraEnabled public String MNGRP {get;set;}
            @AuraEnabled public String MNCOD {get;set;}
            @AuraEnabled public String TXTCDMA {get;set;}
            @AuraEnabled public String MATXT {get;set;}
            @AuraEnabled public String ACT_ADD_TXT {get;set;}
            @AuraEnabled public String FAULT_CAUSE {get;set;}
            @AuraEnabled public String PHENO_ADD_TXT {get;set;}
            @AuraEnabled public String BLCOD {get;set;}
            @AuraEnabled public String BLCOD_T {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_DATE {
            @AuraEnabled public String AUFNR {get;set;}
            @AuraEnabled public String QMNUM {get;set;}
            @AuraEnabled public String SEQNO {get;set;}
            @AuraEnabled public String REP_FR_DT {get;set;}
            @AuraEnabled public String REP_FR_TM {get;set;}
            @AuraEnabled public String REP_TO_DT {get;set;}
            @AuraEnabled public String REP_TO_TM {get;set;}
            @AuraEnabled public String ISMNW {get;set;}
            @AuraEnabled public String ISMNW_PDK {get;set;}
            @AuraEnabled public String ISMNE {get;set;}
            @AuraEnabled public String AIR_TRIP {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_PART {
            @AuraEnabled public String SEQNO {get;set;}
            @AuraEnabled public String MATNR {get;set;}
            @AuraEnabled public String MAKTX {get;set;}
            @AuraEnabled public String MEINS {get;set;}
            @AuraEnabled public String MENGE {get;set;}
            @AuraEnabled public String FOC_FLAG {get;set;}
            @AuraEnabled public String CAUSE_PRT {get;set;}
            @AuraEnabled public String RESP_FACTOR {get;set;}
            @AuraEnabled public String LOT_NO {get;set;}
            @AuraEnabled public String RETURN_YN {get;set;}
            @AuraEnabled public String RETURN_TYPE {get;set;}
            @AuraEnabled public String RETURN_TYPE_T {get;set;}
            @AuraEnabled public String RETURN_TEXT {get;set;}
            @AuraEnabled public String VSBED {get;set;}
            @AuraEnabled public String VTEXT {get;set;}
            @AuraEnabled public String APPNO {get;set;}
            @AuraEnabled public String WORKNO {get;set;}
            @AuraEnabled public String WAERS {get;set;}
            @AuraEnabled public String UNIT_PRICE {get;set;}
            @AuraEnabled public String AMOUNT {get;set;}
            @AuraEnabled public String SALESPRICE {get;set;}
            @AuraEnabled public String CON_MENGE {get;set;}
            @AuraEnabled public String STAN_PRICE {get;set;}
            @AuraEnabled public String PART_RATE {get;set;}
            @AuraEnabled public String DEPART_RATE {get;set;}
            @AuraEnabled public String RETURN_END_YN {get;set;}
            @AuraEnabled public String RETURN_QTY {get;set;}
            @AuraEnabled public String RETURN_DT {get;set;}
            @AuraEnabled public String CNF_QTY {get;set;}
            @AuraEnabled public String CNF_NETPR {get;set;}
            @AuraEnabled public String VERPR {get;set;}
            @AuraEnabled public String LIFNR {get;set;}
            @AuraEnabled public String ZSUPPLY {get;set;}
            @AuraEnabled public String DOCNUM {get;set;}
            @AuraEnabled public String NFNUM {get;set;}
            @AuraEnabled public String ENTRAD {get;set;}
            @AuraEnabled public String FATURA {get;set;}
            @AuraEnabled public String NFNUM2 {get;set;}
            @AuraEnabled public String ERDAT {get;set;}
            @AuraEnabled public String ERNAM {get;set;}
            @AuraEnabled public String ERZET {get;set;}
            @AuraEnabled public String AEDAT {get;set;}
            @AuraEnabled public String AENAM {get;set;}
            @AuraEnabled public String AEZET {get;set;}
            @AuraEnabled public String AUFNR {get;set;}
            @AuraEnabled public String DNET_PRICE {get;set;}
            @AuraEnabled public String ZZWAGRP {get;set;}
            @AuraEnabled public String ZZWAGRPNM {get;set;}
            @AuraEnabled public String VKORG {get;set;}
            @AuraEnabled public String VTWEG {get;set;}
            @AuraEnabled public String SPART {get;set;}
            @AuraEnabled public String GWLDT {get;set;}
            @AuraEnabled public String MGANR_UE {get;set;}
            @AuraEnabled public String INVOICE_NO {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_OTHER {
            @AuraEnabled public String SEQNO {get;set;}
            @AuraEnabled public String TYPE {get;set;}
            @AuraEnabled public String CATEGORY {get;set;}
            @AuraEnabled public String DESCRIPTION {get;set;}
            @AuraEnabled public String VALUE {get;set;}
            @AuraEnabled public String UNIT {get;set;}
            @AuraEnabled public String AMOUNT {get;set;}
            @AuraEnabled public String TOT_AMT {get;set;}
            @AuraEnabled public String WAERS {get;set;}            
        }
        public class IF_CSPLUS_044_Req_T_TMP {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String IF_DESC {get;set;}
            @AuraEnabled public String EVISEQX {get;set;}
            @AuraEnabled public String LINE {get;set;}
            @AuraEnabled public String FILE_SIZE {get;set;}          
        }
        public class IF_CSPLUS_044_Req_T_DOC {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String MIMETYPE {get;set;}
            @AuraEnabled public String FILEDATA {get;set;}
            @AuraEnabled public String DESCRIPTION {get;set;}
            @AuraEnabled public String FLAG {get;set;}
            @AuraEnabled public String DOCNO {get;set;}        
        }
        public class IF_CSPLUS_044_Req_T_DEL {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String DOCNO {get;set;}        
        }
        public class IF_CSPLUS_044_Req_T_TEXT_A {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_TEXT_C {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_TEXT_S {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_TEXT_P {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_FILE {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String IF_DESC {get;set;}
            @AuraEnabled public String EVISEQX {get;set;}
            @AuraEnabled public String LINE {get;set;}
            @AuraEnabled public String FILE_SIZE {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_SIGN1 {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_CSPLUS_044_Req_T_SIGN2 {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }


    // RESPONSE         
        public class IF_CSPLUS_044_Res {
            @AuraEnabled public String O_ORDER {get;set;}
            @AuraEnabled public String O_NOTIFICATION {get;set;}
            @AuraEnabled public String O_DEL_MSG {get;set;}
            @AuraEnabled public String O_UPD_MSG {get;set;}

            @AuraEnabled public IF_CSPLUS_044_Res_O_RETURN O_RETURN {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_RETURN> T_RETURN {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_CLAIM>  T_CLAIM {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_DATE>   T_DATE {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_PART>   T_PART {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_OTHER>  T_OTHER {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_TMP>    T_TMP {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_DOC>    T_DOC {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_DEL>    T_DEL {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_TEXT_A> T_TEXT_A {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_TEXT_C> T_TEXT_C {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_TEXT_S> T_TEXT_S {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_TEXT_P> T_TEXT_P {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_FILE>   T_FILE {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_SIGN1>  T_SIGN1 {get;set;}
            @AuraEnabled public List<IF_CSPLUS_044_Res_T_SIGN2>  T_SIGN2 {get;set;}      
        }

        public class IF_CSPLUS_044_Res_O_RETURN{
            @AuraEnabled public String TYPE {get;set;}
            @AuraEnabled public String MESSAGE {get;set;}             
        }
        public class IF_CSPLUS_044_Res_T_RETURN{
            @AuraEnabled public String TYPE    {get;set;}
            @AuraEnabled public String MESSAGE {get;set;}             
        }
        public class IF_CSPLUS_044_Res_T_CLAIM{
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String CODE_01 {get;set;}
            @AuraEnabled public String CODE_02 {get;set;}
            @AuraEnabled public String CODE_03 {get;set;}
            @AuraEnabled public String OTGRP {get;set;}
            @AuraEnabled public String OTEIL {get;set;}
            @AuraEnabled public String KURZTEXT {get;set;}
            @AuraEnabled public String KURZTEXT_L {get;set;}
            @AuraEnabled public String FEGRP {get;set;}
            @AuraEnabled public String FECOD {get;set;}
            @AuraEnabled public String TXTCDFE {get;set;}
            @AuraEnabled public String FETXT {get;set;}
            @AuraEnabled public String SYMPTOM_ADD_TXT {get;set;}
            @AuraEnabled public String URGRP {get;set;}
            @AuraEnabled public String URCOD {get;set;}
            @AuraEnabled public String TXTCDUR {get;set;}
            @AuraEnabled public String URTXT {get;set;}
            @AuraEnabled public String CAUSE_ADD_TXT {get;set;}
            @AuraEnabled public String MNGRP {get;set;}
            @AuraEnabled public String MNCOD {get;set;}
            @AuraEnabled public String TXTCDMA {get;set;}
            @AuraEnabled public String MATXT {get;set;}
            @AuraEnabled public String ACT_ADD_TXT {get;set;}
            @AuraEnabled public String FAULT_CAUSE {get;set;}
            @AuraEnabled public String PHENO_ADD_TXT {get;set;}
            @AuraEnabled public String BLCOD {get;set;}
            @AuraEnabled public String BLCOD_T {get;set;}            
        }
        public class IF_CSPLUS_044_Res_T_DATE{
            @AuraEnabled public String AUFNR {get;set;}
            @AuraEnabled public String QMNUM {get;set;}
            @AuraEnabled public String SEQNO {get;set;}
            @AuraEnabled public String REP_FR_DT {get;set;}
            @AuraEnabled public String REP_FR_TM {get;set;}
            @AuraEnabled public String REP_TO_DT {get;set;}
            @AuraEnabled public String REP_TO_TM {get;set;}
            @AuraEnabled public String ISMNW {get;set;}
            @AuraEnabled public String ISMNW_PDK {get;set;}
            @AuraEnabled public String ISMNE {get;set;}
            @AuraEnabled public String AIR_TRIP {get;set;}           
        }        
        public class IF_CSPLUS_044_Res_T_PART{
            @AuraEnabled public String SEQNO {get;set;}
            @AuraEnabled public String MATNR {get;set;}
            @AuraEnabled public String MAKTX {get;set;}
            @AuraEnabled public String MEINS {get;set;}
            @AuraEnabled public String MENGE {get;set;}
            @AuraEnabled public String FOC_FLAG {get;set;}
            @AuraEnabled public String CAUSE_PRT {get;set;}
            @AuraEnabled public String RESP_FACTOR {get;set;}
            @AuraEnabled public String LOT_NO {get;set;}
            @AuraEnabled public String RETURN_YN {get;set;}
            @AuraEnabled public String RETURN_TYPE {get;set;}
            @AuraEnabled public String RETURN_TYPE_T {get;set;}
            @AuraEnabled public String RETURN_TEXT {get;set;}
            @AuraEnabled public String VSBED {get;set;}
            @AuraEnabled public String VTEXT {get;set;}
            @AuraEnabled public String APPNO {get;set;}
            @AuraEnabled public String WORKNO {get;set;}
            @AuraEnabled public String WAERS {get;set;}
            @AuraEnabled public String UNIT_PRICE {get;set;}
            @AuraEnabled public String AMOUNT {get;set;}
            @AuraEnabled public String SALESPRICE {get;set;}
            @AuraEnabled public String CON_MENGE {get;set;}
            @AuraEnabled public String STAN_PRICE {get;set;}
            @AuraEnabled public String PART_RATE {get;set;}
            @AuraEnabled public String DEPART_RATE {get;set;}
            @AuraEnabled public String RETURN_END_YN {get;set;}
            @AuraEnabled public String RETURN_QTY {get;set;}
            @AuraEnabled public String RETURN_DT {get;set;}
            @AuraEnabled public String CNF_QTY {get;set;}
            @AuraEnabled public String CNF_NETPR {get;set;}
            @AuraEnabled public String VERPR {get;set;}
            @AuraEnabled public String LIFNR {get;set;}
            @AuraEnabled public String ZSUPPLY {get;set;}
            @AuraEnabled public String DOCNUM {get;set;}
            @AuraEnabled public String NFNUM {get;set;}
            @AuraEnabled public String ENTRAD {get;set;}
            @AuraEnabled public String FATURA {get;set;}
            @AuraEnabled public String NFNUM2 {get;set;}
            @AuraEnabled public String ERDAT {get;set;}
            @AuraEnabled public String ERNAM {get;set;}
            @AuraEnabled public String ERZET {get;set;}
            @AuraEnabled public String AEDAT {get;set;}
            @AuraEnabled public String AENAM {get;set;}
            @AuraEnabled public String AEZET {get;set;}
            @AuraEnabled public String AUFNR {get;set;}
            @AuraEnabled public String DNET_PRICE {get;set;}
            @AuraEnabled public String ZZWAGRP {get;set;}
            @AuraEnabled public String ZZWAGRPNM {get;set;}
            @AuraEnabled public String VKORG {get;set;}
            @AuraEnabled public String VTWEG {get;set;}
            @AuraEnabled public String SPART {get;set;}
            @AuraEnabled public String GWLDT {get;set;}
            @AuraEnabled public String MGANR_UE {get;set;}
            @AuraEnabled public String INVOICE_NO {get;set;}
        }           
        public class IF_CSPLUS_044_Res_T_OTHER{
            @AuraEnabled public String SEQNO {get;set;}
            @AuraEnabled public String TYPE {get;set;}
            @AuraEnabled public String CATEGORY {get;set;}
            @AuraEnabled public String DESCRIPTION {get;set;}
            @AuraEnabled public String VALUE {get;set;}
            @AuraEnabled public String UNIT {get;set;}
            @AuraEnabled public String AMOUNT {get;set;}
            @AuraEnabled public String TOT_AMT {get;set;}
            @AuraEnabled public String WAERS {get;set;}
        }
        public class IF_CSPLUS_044_Res_T_TMP {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String IF_DESC {get;set;}
            @AuraEnabled public String EVISEQX {get;set;}
            @AuraEnabled public String LINE {get;set;}
            @AuraEnabled public String FILE_SIZE {get;set;}          
        }
        public class IF_CSPLUS_044_Res_T_DOC {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String MIMETYPE {get;set;}
            @AuraEnabled public String FILEDATA {get;set;}
            @AuraEnabled public String DESCRIPTION {get;set;}
            @AuraEnabled public String FLAG {get;set;}
            @AuraEnabled public String DOCNO {get;set;}        
        }
        public class IF_CSPLUS_044_Res_T_DEL {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String DOCNO {get;set;}        
        }
        public class IF_CSPLUS_044_Res_T_TEXT_A {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_CSPLUS_044_Res_T_TEXT_C {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_CSPLUS_044_Res_T_TEXT_S {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_CSPLUS_044_Res_T_TEXT_P {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_CSPLUS_044_Res_T_FILE {
            @AuraEnabled public String FILENAME {get;set;}
            @AuraEnabled public String IF_DESC {get;set;}
            @AuraEnabled public String EVISEQX {get;set;}
            @AuraEnabled public String LINE {get;set;}
            @AuraEnabled public String FILE_SIZE {get;set;}
        }
        public class IF_CSPLUS_044_Res_T_SIGN1 {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        }
        public class IF_CSPLUS_044_Res_T_SIGN2 {
            @AuraEnabled public String CLAIM_SEQ {get;set;}
            @AuraEnabled public String TDFORMAT {get;set;}
            @AuraEnabled public String TDLINE {get;set;}
        } 
        
}