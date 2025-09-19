/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-20-2025
 * @last modified by  : deokjun.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-20-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_Material_Classes {
    public IF_ERP_Material_Classes() {}

    // ** IF-CSPLUS-007
    /**
     */
    /**
         * Class Name           : IF_ERP_Material 
         * Wrapper Name         : IF_CSPLUS_007
         * SFDC interface Id    : IF-CSPLUS-007
         * AS-IS RFC            : Z_CS_MT_PARTS_DELIVERY_INFO	
         * New I/F              : ZCRM_CS_MT_PARTS_DELIVERY_INFO
         * Description          : 부품 배송정보 조회
         * REAL                 : Y  
     */ 
    // ** REQUEST
    /**
        */
        public class IF_CSPLUS_007_Req { 
            public IF_CSPLUS_007_Req(){}
            @AuraEnabled public String FR_RECV_DAT {get;set;} 
            @AuraEnabled public String TO_RECV_DAT {get;set;} 
            @AuraEnabled public String I_MAKTX {get;set;} 
            @AuraEnabled public String I_STATUS {get;set;} 
            @AuraEnabled public String I_NAME2 {get;set;} 
      
            @AuraEnabled public String I_TYPBZ {get;set;} 
            @AuraEnabled public String I_EQUNR {get;set;} 
            @AuraEnabled public String I_MATNR {get;set;} 
            @AuraEnabled public String I_CHK {get;set;} 
      
            @AuraEnabled public List<IF_CSPLUS_007_Req_T_I_LIST> T_I_LIST {get;set;} 
            @AuraEnabled public List<IF_CSPLUS_007_Req_T_I_LIST2> T_I_LIST2 {get;set;} 
      
          }
      
          public class IF_CSPLUS_007_Req_T_I_LIST { 
            public IF_CSPLUS_007_Req_T_I_LIST(){}
            @AuraEnabled public String SIGN {get;set;} 
            @AuraEnabled public String OPTION {get;set;} 
            @AuraEnabled public String LOW  {get;set;} 
            @AuraEnabled public String HIGH {get;set;} 
      
        }
      
          public class IF_CSPLUS_007_Req_T_I_LIST2 {
            public IF_CSPLUS_007_Req_T_I_LIST2(){}
             
            @AuraEnabled public String SIGN {get;set;} 
            @AuraEnabled public String OPTION {get;set;} 
            @AuraEnabled public String LOW  {get;set;} 
            @AuraEnabled public String HIGH {get;set;} 
      
        }

          public class IF_CSPLUS_007_Res { 
            public IF_CSPLUS_007_Res(){}
            @AuraEnabled public IF_CSPLUS_007_Res_O_RETURN O_RETURN {get;set;} 
            @AuraEnabled public List<IF_CSPLUS_007_Res_T_O_LIST> T_O_LIST {get;set;} 
      
          }
      
          public class IF_CSPLUS_007_Res_O_RETURN { 
            public IF_CSPLUS_007_Res_O_RETURN(){}
            @AuraEnabled public String TYPE    {get;set;} 
            @AuraEnabled public String CODE    {get;set;} 
            @AuraEnabled public String MESSAGE {get;set;} 
      
            }
      
          public class IF_CSPLUS_007_Res_T_O_LIST { 
            public IF_CSPLUS_007_Res_T_O_LIST(){}

            @AuraEnabled public String AUFNR {get;set;} 
            @AuraEnabled public String QMNUM {get;set;} 
            @AuraEnabled public String RECV_DT {get;set;} 
            @AuraEnabled public String TYPBZ {get;set;} 
            @AuraEnabled public String SERNR {get;set;} 
      
            @AuraEnabled public String MATNR {get;set;} 
            @AuraEnabled public String MAKTX {get;set;} 
            @AuraEnabled public String KWMENG {get;set;} 
            @AuraEnabled public String MEINS {get;set;} 
            @AuraEnabled public String MATNR_TXT {get;set;} 
      
            @AuraEnabled public String TDLNR {get;set;} 
            @AuraEnabled public String TDLNR_NAME {get;set;} 
            @AuraEnabled public String EXTI1 {get;set;} 
            @AuraEnabled public String VBELN {get;set;} 
            @AuraEnabled public String POSNR {get;set;} 
      
            @AuraEnabled public String QDATU {get;set;} 
            @AuraEnabled public String QZEIT {get;set;} 
            @AuraEnabled public String RETURN_YN {get;set;} 
            @AuraEnabled public String RETURN_TYPE {get;set;} 
            @AuraEnabled public String RETURN_TEXT {get;set;} 
      
            @AuraEnabled public String SOLDTO {get;set;} 
            @AuraEnabled public String NAME2 {get;set;} 
            @AuraEnabled public String GWLDT {get;set;} 
            @AuraEnabled public String PRETD {get;set;} 
            @AuraEnabled public String PRETD2 {get;set;} 
      
            @AuraEnabled public String PRETD3 {get;set;} 
            @AuraEnabled public String BMENG {get;set;} 
            @AuraEnabled public String VSMNG {get;set;} 
            @AuraEnabled public String GSMNG {get;set;} 
            @AuraEnabled public String SDATE {get;set;} 
      
            @AuraEnabled public String VBELN_VL {get;set;} 
            @AuraEnabled public String POSNN_VL {get;set;} 
            @AuraEnabled public String SOLDTO1 {get;set;} 
            @AuraEnabled public String NAME3 {get;set;} 
            @AuraEnabled public String ZSUPPLY {get;set;} 
      
            @AuraEnabled public String QMSEQ {get;set;} 
            @AuraEnabled public String DEALER_CD {get;set;} 
            @AuraEnabled public String NAME1 {get;set;} 
            @AuraEnabled public String ILART {get;set;} 
            @AuraEnabled public String NAME4 {get;set;} 
      
            @AuraEnabled public String KUNUM {get;set;} 
            @AuraEnabled public String OBJNR {get;set;} 
            @AuraEnabled public String STATUS {get;set;} 
            @AuraEnabled public String POCONT_YN {get;set;} 
            @AuraEnabled public String INVOICE {get;set;} 
      
            @AuraEnabled public String TKNUM     {get;set;} 
            @AuraEnabled public String VBELN_VL1 {get;set;} 
            @AuraEnabled public String ETD       {get;set;} 
            @AuraEnabled public String DODAT     {get;set;} 
            @AuraEnabled public String LIFNR     {get;set;} 
      
            @AuraEnabled public String VNDNM     {get;set;} 
            @AuraEnabled public String VSBED     {get;set;} 
            @AuraEnabled public String REQ_DATE  {get;set;} 
            @AuraEnabled public String VTEXT     {get;set;} 

         }

    /** SFDC interface Id   : IF-CSPLUS-017
     * RFC Name             : ZCRM_CS_EQUIPMNT_CHANGE
     * Description          : 장비 정보 수정(CRM -> ERP)
        */
        public class IF_CSPLUS_017_Req{
            @AuraEnabled public String I_EQUNR              {get;set;}
            @AuraEnabled public String I_AG_PARNR           {get;set;}
            @AuraEnabled public String I_WE_PARNR           {get;set;}
            @AuraEnabled public String I_PARTNER_DEL_FLG    {get;set;}
            @AuraEnabled public String I_NOTE               {get;set;}
            
            @AuraEnabled public IF_CSPLUS_017_Req_I_ADDRESS        I_ADDRESS    {get;set;}
            @AuraEnabled public List<IF_CSPLUS_017_Req_T_DOCUMENT> T_DOCUMENT   {get;set;}
            @AuraEnabled public IF_CSPLUS_017_Req_I_GENERAL        I_GENERAL    {get;set;}
            @AuraEnabled public IF_CSPLUS_017_Req_I_LOCATION       I_LOCATION   {get;set;}
            @AuraEnabled public IF_CSPLUS_017_Req_I_ORG            I_ORG        {get;set;}

            @AuraEnabled public IF_CSPLUS_017_Req_I_WARRANTY    I_WARRANTY      {get;set;}
            @AuraEnabled public String I_CLASS_VALUE                            {get;set;}
            @AuraEnabled public String I_DESC                                   {get;set;}
            @AuraEnabled public IF_CSPLUS_017_Req_I_USERINFO    I_USERINFO      {get;set;}
            @AuraEnabled public String I_STATUS_FLG                             {get;set;}

            @AuraEnabled public List<IF_CSPLUS_017_Req_T_FILE>  T_FILE          {get;set;}

            public IF_CSPLUS_017_Req(){
                this.I_GENERAL 		= new IF_CSPLUS_017_Req_I_GENERAL();
                this.I_LOCATION		= new IF_CSPLUS_017_Req_I_LOCATION();
                this.I_ORG			= new IF_CSPLUS_017_Req_I_ORG();
                this.I_WARRANTY		= new IF_CSPLUS_017_Req_I_WARRANTY();
                this.I_ADDRESS		= new IF_CSPLUS_017_Req_I_ADDRESS();
                this.I_USERINFO		= new IF_CSPLUS_017_Req_I_USERINFO();
                this.T_FILE 		= new List<IF_CSPLUS_017_Req_T_FILE>();
            }
        }
        public class IF_CSPLUS_017_Req_I_ADDRESS{
            @AuraEnabled public String NAME1        {get;set;}
            @AuraEnabled public String NAME2        {get;set;}
            @AuraEnabled public String STREET       {get;set;}
            @AuraEnabled public String POST_CODE1   {get;set;}
            @AuraEnabled public String CITY1        {get;set;}

            @AuraEnabled public String COUNTRY      {get;set;}
            @AuraEnabled public String REGION       {get;set;}
            @AuraEnabled public String TEL_NUMBER   {get;set;}

            public IF_CSPLUS_017_Req_I_ADDRESS(){}
        }
        public class IF_CSPLUS_017_Req_T_DOCUMENT{
            @AuraEnabled public String DOKAR        {get;set;}
            @AuraEnabled public String DOKNR        {get;set;}
            @AuraEnabled public String DOKTL        {get;set;}
            @AuraEnabled public String DOKVR        {get;set;}
        
            public IF_CSPLUS_017_Req_T_DOCUMENT(){}
        }
        public class IF_CSPLUS_017_Req_I_GENERAL{
            @AuraEnabled public String OBJECTTYPE       {get;set;}
            @AuraEnabled public String START_FROM       {get;set;}
            @AuraEnabled public String ACQDATE          {get;set;}
            @AuraEnabled public String MANFACTURE       {get;set;}
            @AuraEnabled public String MANMODEL         {get;set;}

            @AuraEnabled public String MANCOUNTRY       {get;set;}
            @AuraEnabled public String CONSTYEAR        {get;set;}
            @AuraEnabled public String CONSTMONTH       {get;set;}
            @AuraEnabled public String ZZ_INST_START    {get;set;}
            @AuraEnabled public String ZZ_INST_FINISH   {get;set;}
            
            public IF_CSPLUS_017_Req_I_GENERAL(){
            	this.MANMODEL = ''; 
            }
        }
        public class IF_CSPLUS_017_Req_I_LOCATION{
            @AuraEnabled public String MAINTPLANT   {get;set;}
            @AuraEnabled public String PLSECTN      {get;set;}
            @AuraEnabled public String WERKS        {get;set;}
            @AuraEnabled public String ARBPL        {get;set;}

            public IF_CSPLUS_017_Req_I_LOCATION(){}
        }
        public class IF_CSPLUS_017_Req_I_ORG{
            @AuraEnabled public String BUS_AREA     {get;set;}
            @AuraEnabled public String PLANPLANT    {get;set;}
            @AuraEnabled public String PLANGROUP    {get;set;}
            @AuraEnabled public String WERKS        {get;set;}
            @AuraEnabled public String ARBPL        {get;set;}

            @AuraEnabled public String CATPROFILE   {get;set;}

            public IF_CSPLUS_017_Req_I_ORG(){}
        }
        public class IF_CSPLUS_017_Req_I_WARRANTY{
            @AuraEnabled public String GWLDT        {get;set;}
            @AuraEnabled public String GWLEN        {get;set;}
            @AuraEnabled public String V_GWLEN      {get;set;}
            @AuraEnabled public String DELFLAG      {get;set;}

            public IF_CSPLUS_017_Req_I_WARRANTY(){}
        }
        public class IF_CSPLUS_017_Req_I_USERINFO{
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

            public IF_CSPLUS_017_Req_I_USERINFO(){}
        }
        public class IF_CSPLUS_017_Req_T_FILE{
            @AuraEnabled public String INT_NO       {get;set;}   
            @AuraEnabled public String CHECK        {get;set;}   
            @AuraEnabled public String DOCU_ITEM    {get;set;}       
            @AuraEnabled public String VISIBLE      {get;set;}   
            @AuraEnabled public String FILE_NAME    {get;set;}       

            @AuraEnabled public String DESCRIPTION  {get;set;}       
            @AuraEnabled public String FILE_DATA    {get;set;}       
            @AuraEnabled public String FILE_NO      {get;set;}   
            @AuraEnabled public String FILESIZE     {get;set;}               

            public IF_CSPLUS_017_Req_T_FILE(){}
        }
        public class IF_CSPLUS_017_Res{
            @AuraEnabled public IF_CSPLUS_017_Res_O_RETURN       O_RETURN {get;set;}
            @AuraEnabled public List<IF_CSPLUS_017_Res_T_RETURN> T_RETURN {get;set;}

            public IF_CSPLUS_017_Res(){}
        }
        public class IF_CSPLUS_017_Res_O_RETURN{
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
        
            public IF_CSPLUS_017_Res_O_RETURN(){}
        }
        public class IF_CSPLUS_017_Res_T_RETURN{
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
            
            public IF_CSPLUS_017_Res_T_RETURN(){}
        }

    /** SFDC interface Id   : IF-CSPLUS-018
     * RFC Name             : ZCRM_CS_EQUIPMNT_MANAGEMENT
     * Description          : 장비 정보 생성 & 수정(ERP -> CRM)
        */
        public class IF_CSPLUS_018_Req{
            @AuraEnabled public String I_FROM   {get;set;}
            @AuraEnabled public String I_TO     {get;set;}
            @AuraEnabled public String I_DOCUMENT_FILE     {get;set;}
            
            @AuraEnabled public List<IF_CSPLUS_018_Req_T_ITEM> T_ITEM {get;set;}
            public IF_CSPLUS_018_Req(){
                this.T_ITEM = new List<IF_CSPLUS_018_Req_T_ITEM>();
            }
        }
        public class IF_CSPLUS_018_Req_T_ITEM{
            @AuraEnabled public String EQUNR                {get;set;}    
            @AuraEnabled public String EQKTX                {get;set;}    
            @AuraEnabled public String TXT04                {get;set;}    
            @AuraEnabled public String ATWRT                {get;set;}    
            @AuraEnabled public String INTERNAL_NOTE        {get;set;}            
            
            @AuraEnabled public String IF_CLASS             {get;set;}
            @AuraEnabled public String EQART                {get;set;}    
            @AuraEnabled public String EARTX                {get;set;}    
            @AuraEnabled public String INBDT                {get;set;}    
            @AuraEnabled public String ANSDT                {get;set;}    
            
            @AuraEnabled public String HERST                {get;set;}    
            @AuraEnabled public String HERLD                {get;set;}    
            @AuraEnabled public String TYPBZ                {get;set;}    
            @AuraEnabled public String BAUJJ                {get;set;}    
            @AuraEnabled public String BAUMM                {get;set;}    
            
            @AuraEnabled public String ZZ_INST_START        {get;set;}            
            @AuraEnabled public String ZZ_INST_FINISH       {get;set;}            
            @AuraEnabled public String SWERK                {get;set;}    
            @AuraEnabled public String SWERK_TXT            {get;set;}        
            @AuraEnabled public String BEBER                {get;set;}    
            
            @AuraEnabled public String BEBER_TXT            {get;set;}        
            @AuraEnabled public String LOC_ARBPL            {get;set;}        
            @AuraEnabled public String LOC_ARBPL_TXT        {get;set;}            
            @AuraEnabled public String NAME1                {get;set;}    
            @AuraEnabled public String NAME2                {get;set;}    
            
            @AuraEnabled public String STREET               {get;set;}    
            @AuraEnabled public String POST_CODE1           {get;set;}        
            @AuraEnabled public String CITY1                {get;set;}    
            @AuraEnabled public String COUNTRY              {get;set;}    
            @AuraEnabled public String REGION               {get;set;}    
            
            @AuraEnabled public String TEL_NUMBER           {get;set;}        
            @AuraEnabled public String BUKRS                {get;set;}    
            @AuraEnabled public String BUTXT                {get;set;}    
            @AuraEnabled public String GSBER                {get;set;}    
            @AuraEnabled public String GTEXT                {get;set;}    
            
            @AuraEnabled public String IWERK                {get;set;}    
            @AuraEnabled public String IWERK_TXT            {get;set;}        
            @AuraEnabled public String INGRP                {get;set;}    
            @AuraEnabled public String INNAM                {get;set;}    
            @AuraEnabled public String ORG_ARBPL            {get;set;}        
            
            @AuraEnabled public String ORG_ARBPL_TXT        {get;set;}            
            @AuraEnabled public String WERKS                {get;set;}    
            @AuraEnabled public String RBNR                 {get;set;}
            @AuraEnabled public String RBNRX                {get;set;}    
            @AuraEnabled public String GWLDT                {get;set;}    
            
            @AuraEnabled public String GWLEN                {get;set;}    
            @AuraEnabled public String MGANR                {get;set;}    
            @AuraEnabled public String GAKTX                {get;set;}    
            @AuraEnabled public String STRATEGIC_EQUIP_FLAG {get;set;}                
            @AuraEnabled public String MATNR                {get;set;}    
            
            @AuraEnabled public String SERNR                {get;set;}    
            @AuraEnabled public String V_GWLDT              {get;set;}    
            @AuraEnabled public String V_GWLEN              {get;set;}    
            @AuraEnabled public String M_ATWRT              {get;set;}    
            @AuraEnabled public String KDAUF                {get;set;}    
            
            @AuraEnabled public String RES_MN_WK_CTR        {get;set;}            
            @AuraEnabled public String RES_PLANT            {get;set;}        
            @AuraEnabled public String PERSON_RES           {get;set;}        
            @AuraEnabled public String PERSON_RES_NAME      {get;set;}            
            @AuraEnabled public String DO_VBELN             {get;set;}    
            
            @AuraEnabled public String ZI_KUNNR             {get;set;}    
            @AuraEnabled public String ZI_NAME1             {get;set;}    
            @AuraEnabled public String ZI_STRAS             {get;set;}    
            @AuraEnabled public String ZI_PSTLZ             {get;set;}    
            @AuraEnabled public String ZI_ORT01             {get;set;}   
            
            public IF_CSPLUS_018_Req_T_ITEM(){}
        }
        public class IF_CSPLUS_018_Res{
            @AuraEnabled public List<IF_CSPLUS_018_Res_T_ITEM>          T_ITEM          {get;set;}
            @AuraEnabled public List<IF_CSPLUS_018_Res_T_PARTNERS_INFO> T_PARTNERS_INFO {get;set;}
            @AuraEnabled public List<IF_CSPLUS_018_Res_T_DOCUMENT>      T_DOCUMENT      {get;set;}
            @AuraEnabled public IF_CSPLUS_018_Res_O_RETURN              O_RETURN        {get;set;}
            @AuraEnabled public List<IF_CSPLUS_018_Res_T_DOCUMENT_FILE> T_DOCUMENT_FILE {get;set;}

            public IF_CSPLUS_018_Res(){}
        }
        public class IF_CSPLUS_018_Res_T_ITEM{
            @AuraEnabled public String EQUNR                    {get;set;}    
            @AuraEnabled public String EQKTX                    {get;set;}    
            @AuraEnabled public String TXT04                    {get;set;}    
            @AuraEnabled public String ATWRT                    {get;set;}    
            @AuraEnabled public String INTERNAL_NOTE            {get;set;}

            @AuraEnabled public String IF_CLASS                 {get;set;}    
            @AuraEnabled public String EQART                    {get;set;}    
            @AuraEnabled public String EARTX                    {get;set;}    
            @AuraEnabled public String INBDT                    {get;set;}    
            @AuraEnabled public String ANSDT                    {get;set;}    
            
            @AuraEnabled public String HERST                    {get;set;}    
            @AuraEnabled public String HERLD                    {get;set;}    
            @AuraEnabled public String TYPBZ                    {get;set;}    
            @AuraEnabled public String BAUJJ                    {get;set;}    
            @AuraEnabled public String BAUMM                    {get;set;}    
            
            @AuraEnabled public String ZZ_INST_START            {get;set;}            
            @AuraEnabled public String ZZ_INST_FINISH           {get;set;}            
            @AuraEnabled public String SWERK                    {get;set;}    
            @AuraEnabled public String SWERK_TXT                {get;set;}        
            @AuraEnabled public String BEBER                    {get;set;}    
            
            @AuraEnabled public String BEBER_TXT                {get;set;}        
            @AuraEnabled public String LOC_ARBPL                {get;set;}        
            @AuraEnabled public String LOC_ARBPL_TXT            {get;set;}            
            @AuraEnabled public String NAME1                    {get;set;}    
            @AuraEnabled public String NAME2                    {get;set;}    
            
            @AuraEnabled public String STREET                   {get;set;}    
            @AuraEnabled public String POST_CODE1               {get;set;}        
            @AuraEnabled public String CITY1                    {get;set;}    
            @AuraEnabled public String COUNTRY                  {get;set;}    
            @AuraEnabled public String REGION                   {get;set;}    
            
            @AuraEnabled public String TEL_NUMBER               {get;set;}        
            @AuraEnabled public String BUKRS                    {get;set;}    
            @AuraEnabled public String BUTXT                    {get;set;}    
            @AuraEnabled public String GSBER                    {get;set;}    
            @AuraEnabled public String GTEXT                    {get;set;}    
            
            @AuraEnabled public String IWERK                    {get;set;}    
            @AuraEnabled public String IWERK_TXT                {get;set;}        
            @AuraEnabled public String INGRP                    {get;set;}    
            @AuraEnabled public String INNAM                    {get;set;}    
            @AuraEnabled public String ORG_ARBPL                {get;set;}        
            
            @AuraEnabled public String ORG_ARBPL_TXT            {get;set;}            
            @AuraEnabled public String WERKS                    {get;set;}    
            @AuraEnabled public String RBNR                     {get;set;}
            @AuraEnabled public String RBNRX                    {get;set;}    
            @AuraEnabled public String GWLDT                    {get;set;}    
            
            @AuraEnabled public String GWLEN                    {get;set;}    
            // @AuraEnabled public String MGANR                    {get;set;}    
            @AuraEnabled public String GAKTX                    {get;set;}    
            @AuraEnabled public String STRATEGIC_EQUIP_FLAG     {get;set;}             
            @AuraEnabled public String MATNR                    {get;set;}    
            
            @AuraEnabled public String SERNR                    {get;set;}    
            @AuraEnabled public String V_GWLDT                  {get;set;}    
            @AuraEnabled public String V_GWLEN                  {get;set;}    
            @AuraEnabled public String M_ATWRT                  {get;set;}    

            // 2025.02.24 추가
            @AuraEnabled public String KDAUF                    {get;set;} 
            @AuraEnabled public String ZI_KUNNR                 {get;set;}    
            @AuraEnabled public String RES_MN_WK_CTR            {get;set;}  
            @AuraEnabled public String PERSON_RES               {get;set;}   
            @AuraEnabled public String RES_PLANT                {get;set;}       

            // 2025.02.26 추가
            @AuraEnabled public String M_ATWRT2                 {get;set;}

            // 2025.03.06 추가
            @AuraEnabled public String PERSON_RES_NAME          {get;set;}
            @AuraEnabled public String DO_VBELN                 {get;set;}
            @AuraEnabled public String ZI_NAME1                 {get;set;}
            @AuraEnabled public String ZI_STRAS                 {get;set;}
            @AuraEnabled public String ZI_PSTLZ                 {get;set;}
            
            @AuraEnabled public String ZI_ORT01                 {get;set;}
            
            // 2025.03.25 추가
            @AuraEnabled public String WADAT_IST                {get;set;}
            
            // 2025.03.28 추가
            @AuraEnabled public String MGANR                    {get;set;}
            public IF_CSPLUS_018_Res_T_ITEM(){}
        }
        public class IF_CSPLUS_018_Res_T_PARTNERS_INFO{
            @AuraEnabled public String EQUNR    {get;set;}
            @AuraEnabled public String VTEXT    {get;set;}
            @AuraEnabled public String PARNR    {get;set;}
            @AuraEnabled public String NAME1    {get;set;}
            @AuraEnabled public String ORT01    {get;set;}

            public IF_CSPLUS_018_Res_T_PARTNERS_INFO(){}
        }
        public class IF_CSPLUS_018_Res_T_DOCUMENT{
            @AuraEnabled public String OBJKY    {get;set;}
            @AuraEnabled public String DOKAR    {get;set;}
            @AuraEnabled public String DOKNR    {get;set;}
            @AuraEnabled public String DOKTL    {get;set;}
            @AuraEnabled public String DOKVR    {get;set;}

            @AuraEnabled public String DKTXT    {get;set;}

            public IF_CSPLUS_018_Res_T_DOCUMENT(){}
        }
        public class IF_CSPLUS_018_Res_O_RETURN{
            @AuraEnabled public String TYPE     {get;set;}
            @AuraEnabled public String CODE     {get;set;}
            @AuraEnabled public String MESSAGE  {get;set;}

            public IF_CSPLUS_018_Res_O_RETURN(){}
        }
        public class IF_CSPLUS_018_Res_T_DOCUMENT_FILE{
            @AuraEnabled public String OBJKY    {get;set;}
            @AuraEnabled public String DOKAR    {get;set;}
            @AuraEnabled public String DOKNR    {get;set;}
            @AuraEnabled public String DOKTL    {get;set;}
            @AuraEnabled public String DOKVR    {get;set;}
            
            @AuraEnabled public String BUFFER   {get;set;}
            
            // 2025.03.25 추가
            @AuraEnabled public String WSAPPLICATION   {get;set;}

            public IF_CSPLUS_018_Res_T_DOCUMENT_FILE(){}
        }



    /** SFDC interface Id   : IF-CSPLUS-021
     *   AS-IS RFC            : ZSL_RECV_EP_DEALER_STOCK_INFO       
     *   New I/F              : ZCRM_SL_RECV_EP_DEALER_STOCK       
     *   Description          : * 부품 주문 및 부품 청구 생성을 위한 부품 재고조회
        */
        public class IF_CSPLUS_021_Req{
            @AuraEnabled public String                 I_USERID    {get;set;}
            @AuraEnabled public IF_CSPLUS_021_I_ORG    I_ORG       {get;set;}
            @AuraEnabled public String                 I_MATNR     {get;set;}

            public IF_CSPLUS_021_Req(){}
        }
        public class IF_CSPLUS_021_I_ORG{
            @AuraEnabled public String VKORG        {get;set;}
            @AuraEnabled public String VTWEG        {get;set;}
            @AuraEnabled public String SPART        {get;set;}
            @AuraEnabled public String WERKS        {get;set;}

            @AuraEnabled public String ARBPL        {get;set;}
            @AuraEnabled public String AMSCCTL      {get;set;}

            public IF_CSPLUS_021_I_ORG(){
                this.VKORG      = '';
                this.VTWEG      = '';
                this.SPART      = '';
                this.WERKS      = '';
                this.ARBPL      = '';
                this.AMSCCTL    = '';
            }
        }
        public class IF_CSPLUS_021_Res{
            @AuraEnabled public IF_CSPLUS_021_ES_RETURN         ES_RETURN   {get;set;}
            @AuraEnabled public IF_CSPLUS_021_ES_INFO           ES_INFO     {get;set;}
            @AuraEnabled public List<IF_CSPLUS_021_ET_AVAIL>    ET_AVAIL    {get;set;}
            @AuraEnabled public List<IF_CSPLUS_021_ET_CROSS>    ET_CROSS    {get;set;}

            public IF_CSPLUS_021_Res(){}
        }
        public class IF_CSPLUS_021_ES_RETURN{
            @AuraEnabled public String TYPE           {get;set;}
            @AuraEnabled public String ID             {get;set;}
            @AuraEnabled public String IF_NUMBER      {get;set;}
            @AuraEnabled public String MESSAGE        {get;set;}

            @AuraEnabled public String LOG_NO         {get;set;}
            @AuraEnabled public String LOG_MSG_NO     {get;set;}
            @AuraEnabled public String MESSAGE_V1     {get;set;}
            @AuraEnabled public String MESSAGE_V2     {get;set;}
            
            @AuraEnabled public String MESSAGE_V3     {get;set;}
            @AuraEnabled public String MESSAGE_V4     {get;set;}
            @AuraEnabled public String PARAMETER      {get;set;}
            @AuraEnabled public String ROW            {get;set;}
            
            @AuraEnabled public String FIELD          {get;set;}
            @AuraEnabled public String IF_SYSTEM      {get;set;}

            public IF_CSPLUS_021_ES_RETURN(){}
        }
        public class IF_CSPLUS_021_ES_INFO{
            @AuraEnabled public String MAKTX        {get;set;}
            @AuraEnabled public String REPNR        {get;set;}
            @AuraEnabled public String THREAD       {get;set;}
            @AuraEnabled public String MEINS        {get;set;}
            @AuraEnabled public String LABST        {get;set;}
            @AuraEnabled public String LABST2       {get;set;}
            
            @AuraEnabled public String NETPR        {get;set;}
            @AuraEnabled public String WAERS        {get;set;}
            @AuraEnabled public String CUQTY        {get;set;}
            @AuraEnabled public String AVQTY        {get;set;}
            
            @AuraEnabled public String SOQTY        {get;set;}
            @AuraEnabled public String PRQTY        {get;set;}
            @AuraEnabled public String DMTOP        {get;set;}
            @AuraEnabled public String OTHOP        {get;set;}
            
            @AuraEnabled public String LOC          {get;set;}
            @AuraEnabled public String DIQTY        {get;set;}
            @AuraEnabled public String STQTY        {get;set;}
            @AuraEnabled public String GIQTY        {get;set;}
            
            @AuraEnabled public String YGQTY        {get;set;}
            @AuraEnabled public String LAST_EX_DT   {get;set;}
            @AuraEnabled public String LAST_IM_DT   {get;set;}
            @AuraEnabled public String BLQTY        {get;set;}
            
            @AuraEnabled public String ZNOTE        {get;set;}
            @AuraEnabled public String MPPS_YN      {get;set;}
            @AuraEnabled public String NONMV        {get;set;}
            @AuraEnabled public String AVRLT        {get;set;}
            
            @AuraEnabled public String PLIFZ        {get;set;}
            @AuraEnabled public String DISMM        {get;set;}
            @AuraEnabled public String MAABC        {get;set;}
            @AuraEnabled public String WAMD         {get;set;}
            
            @AuraEnabled public String MINBE        {get;set;}
            @AuraEnabled public String MABST        {get;set;}
            @AuraEnabled public String BSTRF        {get;set;}
            @AuraEnabled public String BSTMI        {get;set;}

            @AuraEnabled public String HSCODE       {get;set;}
            @AuraEnabled public String IGST         {get;set;}
            @AuraEnabled public String SVRCD        {get;set;}
            @AuraEnabled public String SVRCD_T      {get;set;}

            @AuraEnabled public String NTGEW        {get;set;}
            @AuraEnabled public String GEWEI        {get;set;}
            @AuraEnabled public String HERKL        {get;set;}
            @AuraEnabled public String DENET        {get;set;}

            @AuraEnabled public String DASTK        {get;set;}
            @AuraEnabled public String LTEXT        {get;set;}

            public IF_CSPLUS_021_ES_INFO(){}
        }
        public class IF_CSPLUS_021_ET_AVAIL{
            @AuraEnabled public String DEALER_CD    {get;set;}
            @AuraEnabled public String NAME1        {get;set;}
            @AuraEnabled public String AVQTY        {get;set;}
            @AuraEnabled public String NONMV        {get;set;}

            public IF_CSPLUS_021_ET_AVAIL(){}
        }
        public class IF_CSPLUS_021_ET_CROSS{
            @AuraEnabled public String SEQ          {get;set;}
            @AuraEnabled public String MATNR        {get;set;}
            @AuraEnabled public String MAKTX        {get;set;}
            @AuraEnabled public String ITCCD        {get;set;}

            @AuraEnabled public String LABST        {get;set;}
            @AuraEnabled public String NOTCD        {get;set;}
            @AuraEnabled public String DDTEXT       {get;set;}
            @AuraEnabled public String SVRCD        {get;set;}
            
            @AuraEnabled public String MXNET        {get;set;}

            public IF_CSPLUS_021_ET_CROSS(){}
        }

    /** SFDC interface Id   : IF-CSPLUS-024
     * AS-IS RFC            : Z_CS_MT_CUSTOMER_EQUIP_INFO       
     * New I/F              : ZCRM_CS_MT_CUSTOMER_EQUIP_INFO
     * Description          : 내역 : SP-Task 목록 조회 및 저장
        */
        public class IF_CSPLUS_024_Req{
            @AuraEnabled public String I_KUNNR {get;set;}

            public IF_CSPLUS_024_Req(){}
        }
        public class IF_CSPLUS_024_Res{
            @AuraEnabled public IF_CSPLUS_024_O_RETURN       O_RETURN {get;set;}
            @AuraEnabled public List<IF_CSPLUS_024_T_O_LIST> T_O_LIST {get;set;}
            
            public IF_CSPLUS_024_Res(){}
        }
        public class IF_CSPLUS_024_O_RETURN{
            @AuraEnabled public String TYPE          {get;set;} 
            @AuraEnabled public String CODE          {get;set;} 
            @AuraEnabled public String MESSAGE       {get;set;} 

            public IF_CSPLUS_024_O_RETURN(){}
        }
        public class IF_CSPLUS_024_T_O_LIST{
            @AuraEnabled public String EQUNR        {get;set;}
            @AuraEnabled public String EQKTX        {get;set;}
            @AuraEnabled public String TYPBZ        {get;set;}
            @AuraEnabled public String SERNR        {get;set;}
            @AuraEnabled public String INBDT        {get;set;}

            @AuraEnabled public String PARNR        {get;set;}
            @AuraEnabled public String NAME1        {get;set;}
            @AuraEnabled public String RBNR         {get;set;}
            @AuraEnabled public String GWLDT        {get;set;}
            @AuraEnabled public String OBJNR        {get;set;}
            
            @AuraEnabled public String WC           {get;set;}
            @AuraEnabled public String MAINWC       {get;set;}

            public IF_CSPLUS_024_T_O_LIST(){}
        }

    /** SFDC interface Id   : IF-CSPLUS-031
     * AS-IS RFC            : ZSS_RECV_SPD_CARTRIDGE_BY_EQUI       
     * New I/F              : ZCRM_SS_SPD_CARTRIDGE_BY_EQUI       
     * Description          : 스핀들 입고수리 부품 청구를 위한 조회
        */
        public class IF_CSPLUS_031_Req { 
            @AuraEnabled public String I_VKORG {get;set;} 
            @AuraEnabled public String I_EQUNR {get;set;} 
            @AuraEnabled public String I_KUNNR {get;set;} 
    
            public IF_CSPLUS_031_Req(){}

            public IF_CSPLUS_031_Req(String I_VKORG, String I_EQUNR, String I_KUNNR){
                this.I_VKORG = I_VKORG ;
                this.I_EQUNR = I_EQUNR ;
                this.I_KUNNR = I_KUNNR ;
            }
        }
        public class IF_CSPLUS_031_Res { 
            @AuraEnabled public IF_CSPLUS_031_O_RETURN       O_RETURN {get;set;} 
            @AuraEnabled public List<IF_CSPLUS_031_T_O_LIST> T_O_LIST {get;set;} 
            
            public IF_CSPLUS_031_Res(){}
        }
        public class IF_CSPLUS_031_O_RETURN { 
            @AuraEnabled public String TYPE         {get;set;} 
            @AuraEnabled public String ID           {get;set;} 
            @AuraEnabled public String MSG_NUMBER   {get;set;} 
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
            @AuraEnabled public String MSG_SYSTEM   {get;set;} 
    
            public IF_CSPLUS_031_O_RETURN(){}
        }
        public class IF_CSPLUS_031_T_O_LIST { 
            @AuraEnabled public String ZTYPE {get;set;} 
            @AuraEnabled public String MATNR {get;set;} 
            @AuraEnabled public String MAKTX {get;set;} 
            @AuraEnabled public String NETWR {get;set;} 
            @AuraEnabled public String WAERS {get;set;} 
    
            @AuraEnabled public String MENGE {get;set;} 
            @AuraEnabled public String MEINS {get;set;} 
            @AuraEnabled public String PLIFZ {get;set;} 
    
            public IF_CSPLUS_031_T_O_LIST(){}
        }

    /** IF-CSPLUS-045
     * RFC Name             : ZCRM_CS_EQUIPMENT_FILE
     * Description          : 장비 파일 데이터 조회  (CRM -> ERP)
        */
        public class IF_CSPLUS_045_Req { 
            @AuraEnabled public String I_EQUNR {get;set;}
            @AuraEnabled public String I_SIZE  {get;set;}
            
            public IF_CSPLUS_045_Req(){}
        }
        public class IF_CSPLUS_045_Res { 
            @AuraEnabled public List<IF_CSPLUS_045_Res_T_DOCUMENT>          T_DOCUMENT          {get;set;}
            @AuraEnabled public List<IF_CSPLUS_045_Res_T_DOCUMENT_FILE>     T_DOCUMENT_FILE     {get;set;}
            @AuraEnabled public IF_CSPLUS_045_Res_O_RETURN                  O_RETURN            {get;set;}

            public IF_CSPLUS_045_Res(){}
        }
        public class IF_CSPLUS_045_Res_T_DOCUMENT {
            @AuraEnabled public String OBJKY   {get;set;}     
            @AuraEnabled public String DOKAR   {get;set;}     
            @AuraEnabled public String DOKNR   {get;set;}     
            @AuraEnabled public String DOKTL   {get;set;}     
            @AuraEnabled public String DOKVR   {get;set;}   
            
            @AuraEnabled public String DKTXT   {get;set;}                 

            public IF_CSPLUS_045_Res_T_DOCUMENT(){}
        }
        public class IF_CSPLUS_045_Res_T_DOCUMENT_FILE {
            @AuraEnabled public String OBJKY             {get;set;}     
            @AuraEnabled public String DOKAR             {get;set;}     
            @AuraEnabled public String DOKNR             {get;set;}     
            @AuraEnabled public String DOKTL             {get;set;}     
            @AuraEnabled public String DOKVR             {get;set;}     

            @AuraEnabled public String BUFFER            {get;set;}     
            @AuraEnabled public String WSAPPLICATION     {get;set;}                                         

            public IF_CSPLUS_045_Res_T_DOCUMENT_FILE(){}
        }
        public class IF_CSPLUS_045_Res_O_RETURN {
            @AuraEnabled public String TYPE        {get;set;}     
            @AuraEnabled public String CODE        {get;set;}     
            @AuraEnabled public String MESSAGE     {get;set;}                     

            public IF_CSPLUS_045_Res_O_RETURN(){}
        }

    /** IF-CSPLUS-047
     * RFC Name             : ZCRM_CS_EQUIP_ORDER_FILE
     * Description          : 장비 파일 데이터 조회  (CRM -> ERP)
        */
        public class IF_CSPLUS_047_Req { 
            @AuraEnabled public String I_VBELN {get;set;}

            public IF_CSPLUS_047_Req(){}
        }
        public class IF_CSPLUS_047_Res { 
            @AuraEnabled public List<IF_CSPLUS_047_Res_T_DOCUMENT>          T_DOCUMENT          {get;set;}
            @AuraEnabled public List<IF_CSPLUS_047_Res_T_DOCUMENT_FILE>     T_DOCUMENT_FILE     {get;set;}
            @AuraEnabled public IF_CSPLUS_047_Res_O_RETURN                  O_RETURN            {get;set;}

            public IF_CSPLUS_047_Res(){}
        }
        public class IF_CSPLUS_047_Res_T_DOCUMENT {
            @AuraEnabled public String OBJKY   {get;set;}     
            @AuraEnabled public String DOKAR   {get;set;}     
            @AuraEnabled public String DOKNR   {get;set;}     
            @AuraEnabled public String DOKTL   {get;set;}     
            @AuraEnabled public String DOKVR   {get;set;}   
            
            @AuraEnabled public String DKTXT   {get;set;}                 

            public IF_CSPLUS_047_Res_T_DOCUMENT(){}
        }
        public class IF_CSPLUS_047_Res_T_DOCUMENT_FILE {
            @AuraEnabled public String OBJKY             {get;set;}     
            @AuraEnabled public String DOKAR             {get;set;}     
            @AuraEnabled public String DOKNR             {get;set;}     
            @AuraEnabled public String DOKTL             {get;set;}     
            @AuraEnabled public String DOKVR             {get;set;}     

            @AuraEnabled public String BUFFER            {get;set;}     
            @AuraEnabled public String WSAPPLICATION     {get;set;}                                         

            public IF_CSPLUS_047_Res_T_DOCUMENT_FILE(){}
        }
        public class IF_CSPLUS_047_Res_O_RETURN {
            @AuraEnabled public String TYPE        {get;set;}     
            @AuraEnabled public String CODE        {get;set;}     
            @AuraEnabled public String MESSAGE     {get;set;}                     

            public IF_CSPLUS_047_Res_O_RETURN(){}
        }
}