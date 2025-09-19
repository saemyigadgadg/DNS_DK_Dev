/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-22-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-16-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_Product_Classes {
    public IF_ERP_Product_Classes() {}

    /** SFDC interface Id    : IF-OPTY-002
     *  New I/F              : ZCRM_SD_MS_MATERIAL_LST       
     *  Description          : 자재마스터 대표사양, 모델, 부품, 서비스 패키지 정보 생성 (ERP -> CRM)
        */ 
        public class IF_OPTY_002_Req{
            @AuraEnabled public String I_SDATE  {get;set;}
            @AuraEnabled public String I_EDATE  {get;set;}
            @AuraEnabled public String I_CODE   {get;set;}
            @AuraEnabled public String I_ROW    {get;set;}
            @AuraEnabled public String I_ZSEQ   {get;set;}
            
            @AuraEnabled public List<IF_OPTY_002_Req_IT_VKORG>	IT_VKORG {get;set;}
            @AuraEnabled public List<IF_OPTY_002_Req_IT_WERKS>	IT_WERKS {get;set;}
            @AuraEnabled public List<IF_OPTY_002_Req_IT_MATNR>	IT_MATNR {get;set;}
            

            public IF_OPTY_002_Req(){
                this.IT_VKORG = new List<IF_OPTY_002_Req_IT_VKORG>();
                this.IT_WERKS = new List<IF_OPTY_002_Req_IT_WERKS>();
                this.IT_MATNR = new List<IF_OPTY_002_Req_IT_MATNR>();
            }
        }
        public class IF_OPTY_002_Req_IT_VKORG{
            @AuraEnabled public String VKORG  {get;set;}
        }
        public class IF_OPTY_002_Req_IT_WERKS{
            @AuraEnabled public String WERKS  {get;set;}
        }
        public class IF_OPTY_002_Req_IT_MATNR{
            @AuraEnabled public String MATNR  {get;set;}
        }
        public class IF_OPTY_002_Res{
            @AuraEnabled public IF_OPTY_002_Res_O_RETURN      O_RETURN   {get;set;}
            @AuraEnabled public List<IF_OPTY_002_Res_T_LIST>  T_LIST     {get;set;}

            public IF_OPTY_002_Res(){}
        }
    public class IF_OPTY_002_Res_O_RETURN{
            @AuraEnabled public String TYPE     {get;set;}
            @AuraEnabled public String CODE     {get;set;}
            @AuraEnabled public String MESSAGE  {get;set;}

            public IF_OPTY_002_Res_O_RETURN(){}
        }
        public class IF_OPTY_002_Res_T_LIST{
            @AuraEnabled public String MATNR            {get;set;}
            @AuraEnabled public String MAKTX            {get;set;}
            @AuraEnabled public String MATKL            {get;set;}
            @AuraEnabled public String WGBEZ            {get;set;}
            @AuraEnabled public String MTART            {get;set;}

            @AuraEnabled public String MTBEZ            {get;set;}
            @AuraEnabled public String MEINS            {get;set;}
            @AuraEnabled public String SATNR            {get;set;}
            @AuraEnabled public String WERKS            {get;set;}
            @AuraEnabled public String LGPRO            {get;set;}
            
            @AuraEnabled public String EKGRP            {get;set;}
            @AuraEnabled public String VKORG            {get;set;}
            @AuraEnabled public String VTWEG            {get;set;}
            @AuraEnabled public String SPART            {get;set;}
            @AuraEnabled public String MILVE            {get;set;}
            
            @AuraEnabled public String HE_INDICATOR     {get;set;}
            @AuraEnabled public String NTGEW            {get;set;}
            @AuraEnabled public String GEWEI            {get;set;}
            @AuraEnabled public String PRDHA            {get;set;}
            @AuraEnabled public String LAEDA            {get;set;}
            
            @AuraEnabled public String REPNR            {get;set;}
            @AuraEnabled public String STRNR            {get;set;}
            @AuraEnabled public String LSTNR            {get;set;}
            @AuraEnabled public String THRED            {get;set;}

            public IF_OPTY_002_Res_T_LIST(){}
        }

    /** SFDC interface Id    : IF-OPTY-004
     *  New I/F              : ZCRM_SD_GET_INCOMING_PLAN_LST       
     *  Description          : 자재마스터 부품(추가자재) 정보 조회
        */
        public class IF_OPTY_004_Req{
            @AuraEnabled public String I_PARENT                 {get;set;}
            @AuraEnabled public String I_CHILD                  {get;set;}
            @AuraEnabled public String I_CHILD_TX               {get;set;}
            @AuraEnabled public IF_OPTY_004_Req_I_HEAD I_HEAD   {get;set;}

            @AuraEnabled public String I_GUBUN                  {get;set;}
            @AuraEnabled public String I_VBELN                  {get;set;}

            public IF_OPTY_004_Req(){}
        }
        public class IF_OPTY_004_Req_I_HEAD{
            @AuraEnabled public String AUART            {get;set;}
            @AuraEnabled public String VKORG            {get;set;}
            @AuraEnabled public String VTWEG            {get;set;}
            @AuraEnabled public String SPART            {get;set;}

            @AuraEnabled public String KUNNR            {get;set;}
            @AuraEnabled public String KUNAG            {get;set;}
            @AuraEnabled public String BEZEI            {get;set;}
            @AuraEnabled public String VKORG_T          {get;set;}
            
            @AuraEnabled public String VTWEG_T          {get;set;}
            @AuraEnabled public String SPART_T          {get;set;}
            @AuraEnabled public String KUNNR_NAME       {get;set;}
            @AuraEnabled public String KUNNR_STREET     {get;set;}
            
            @AuraEnabled public String KUNAG_NAME       {get;set;}
            @AuraEnabled public String KUNAG_STREET     {get;set;}
            @AuraEnabled public String VKBUR            {get;set;}
            @AuraEnabled public String VKBUR_TX         {get;set;}
            
            @AuraEnabled public String VSBED            {get;set;}
            @AuraEnabled public String IHREZ            {get;set;}
            @AuraEnabled public String ERDAT            {get;set;}
            @AuraEnabled public String AUDAT            {get;set;}
            
            @AuraEnabled public String FKDAT            {get;set;}
            @AuraEnabled public String BUKRS            {get;set;}

            public IF_OPTY_004_Req_I_HEAD(){}
        }
        public class IF_OPTY_004_Res{
            @AuraEnabled public IF_OPTY_004_Res_O_RETURN            O_RETURN    {get;set;}
            @AuraEnabled public List<IF_OPTY_004_Res_T_MATERIAL>    T_MATERIAL  {get;set;}

            public IF_OPTY_004_Res(){}
        }
        public class IF_OPTY_004_Res_O_RETURN{
            @AuraEnabled public String TYPE     {get;set;}
            @AuraEnabled public String CODE     {get;set;}
            @AuraEnabled public String MESSAGE  {get;set;}

            public IF_OPTY_004_Res_O_RETURN(){}
        }
        public class IF_OPTY_004_Res_T_MATERIAL{
            @AuraEnabled public String PARENT       {get;set;}
            @AuraEnabled public String PARENT_TX    {get;set;}
            @AuraEnabled public String CHILD        {get;set;}
            @AuraEnabled public String CHILD_TX     {get;set;}

            @AuraEnabled public String ZZSPEC       {get;set;}
            @AuraEnabled public String CHECK        {get;set;}
            @AuraEnabled public String KWMENG       {get;set;}
            @AuraEnabled public String VRKME        {get;set;}
            
            @AuraEnabled public String BRGEW        {get;set;}
            @AuraEnabled public String GEWEI        {get;set;}
            @AuraEnabled public String KBETR        {get;set;}
            @AuraEnabled public String KONWA        {get;set;}
            
            @AuraEnabled public String ZZOPTN       {get;set;}

            public IF_OPTY_004_Res_T_MATERIAL(){}
        }

    /** SFDC interface Id    : IF-OPTY-023
     *  New I/F              : ZCRM_SD_GET_DEFAULT_ITEM_CONFI       
     *  Description          : 대표사양 별 선택된 옵션 정보, Object Dependency 정보 조회
        */
        public class IF_OPTY_023_Req{
            @AuraEnabled public String I_PARENT     {get;set;}
            @AuraEnabled public String I_PRODUCT    {get;set;}
            @AuraEnabled public String I_PLANT      {get;set;}
            @AuraEnabled public String I_RECALL     {get;set;}
            @AuraEnabled public String I_DATE       {get;set;}

            @AuraEnabled public String I_BZIRK      {get;set;}
            @AuraEnabled public String I_JOIN       {get;set;}
            @AuraEnabled public String I_AMT_CHK    {get;set;}
            @AuraEnabled public String I_WAERS      {get;set;}
            @AuraEnabled public String I_NEW        {get;set;}
            
            @AuraEnabled public String I_LONGTEXT   {get;set;}
            @AuraEnabled public String I_VBELN      {get;set;}
            @AuraEnabled public String I_UNAME      {get;set;}
            @AuraEnabled public IF_OPTY_023_Req_I_ORG I_ORG     {get;set;}
            @AuraEnabled public String I_PRICE_P    {get;set;}
            
            @AuraEnabled public String I_KUNNR      {get;set;}
            @AuraEnabled public String I_MOBILE     {get;set;}
            @AuraEnabled public String I_EMAIL      {get;set;}
            @AuraEnabled public IF_OPTY_023_Req_I_USERINFO I_USERINFO    {get;set;}
            @AuraEnabled public List<IF_OPTY_023_Req_T_SELECT> T_SELECT  {get;set;}

            public IF_OPTY_023_Req(){
                I_ORG = new IF_OPTY_023_Req_I_ORG();
                I_USERINFO = new IF_OPTY_023_Req_I_USERINFO();
                T_SELECT = new List<IF_OPTY_023_Req_T_SELECT>();
            }
        }
        public class IF_OPTY_023_Req_I_ORG{
            @AuraEnabled public String VKORG        {get;set;}
            @AuraEnabled public String VTWEG        {get;set;}
            @AuraEnabled public String SPART        {get;set;}
            @AuraEnabled public String WERKS        {get;set;}

            @AuraEnabled public String ARBPL        {get;set;}
            @AuraEnabled public String AMSCCTL      {get;set;}

            public IF_OPTY_023_Req_I_ORG(){}
        }
        public class IF_OPTY_023_Req_I_USERINFO{
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

            public IF_OPTY_023_Req_I_USERINFO(){}
        }
        public class IF_OPTY_023_Req_T_SELECT{
            @AuraEnabled public String ATNAM        {get;set;}
            @AuraEnabled public String ATBEZ        {get;set;}
            @AuraEnabled public String ATWRT        {get;set;}
            @AuraEnabled public String ATWTB        {get;set;}
            @AuraEnabled public String IF_DEFAULT   {get;set;}
            
            @AuraEnabled public String ZSEQNO       {get;set;}
            @AuraEnabled public String SHOW         {get;set;}
            @AuraEnabled public String ZCVDESC      {get;set;}

            public IF_OPTY_023_Req_T_SELECT(){}
        }
        public class IF_OPTY_023_Res{
            @AuraEnabled public IF_OPTY_023_Res_O_RETURN                O_RETURN        {get;set;}
            @AuraEnabled public List<IF_OPTY_023_Res_T_OPTION>          T_OPTION        {get;set;}
            @AuraEnabled public List<IF_OPTY_023_Res_T_VALUE>           T_VALUE         {get;set;}
            @AuraEnabled public List<IF_OPTY_023_Res_T_INITSEL>         T_INITSEL       {get;set;}
            
            @AuraEnabled public List<IF_OPTY_023_Res_T_SELECT>          T_SELECT        {get;set;}
            @AuraEnabled public List<IF_OPTY_023_Res_T_INCON_VALUE>     T_INCON_VALUE   {get;set;}
            @AuraEnabled public List<IF_OPTY_023_Res_T_INCOM_OPTION>    T_INCOM_OPTION  {get;set;}
            @AuraEnabled public List<IF_OPTY_023_Res_T_GROUP>           T_GROUP         {get;set;}
            
            @AuraEnabled public List<IF_OPTY_023_Res_T_USERSEL>         T_USERSEL       {get;set;}

            public IF_OPTY_023_Res(){}
        }
        public class IF_OPTY_023_Res_O_RETURN{
            @AuraEnabled public String TYPE     {get;set;}
            @AuraEnabled public String CODE     {get;set;}
            @AuraEnabled public String MESSAGE  {get;set;}

            public IF_OPTY_023_Res_O_RETURN(){}
        }
        public class IF_OPTY_023_Res_T_OPTION{
            @AuraEnabled public String ATNAM    {get;set;}
            @AuraEnabled public String ATBEZ    {get;set;}
            @AuraEnabled public String ZSEQNO   {get;set;}
            @AuraEnabled public String SHOW     {get;set;}
            @AuraEnabled public String READONLY {get;set;}

            @AuraEnabled public String ATEIN    {get;set;}
            @AuraEnabled public String FLREQ    {get;set;}
            @AuraEnabled public String GRNAM    {get;set;}
            @AuraEnabled public String DISPLAY  {get;set;}
            @AuraEnabled public String ZCVDESC  {get;set;}
            
            public IF_OPTY_023_Res_T_OPTION(){}
        }
        public class IF_OPTY_023_Res_T_VALUE{
            @AuraEnabled public String ATNAM    {get;set;}
            @AuraEnabled public String ATBEZ    {get;set;}
            @AuraEnabled public String ATWRT    {get;set;}
            @AuraEnabled public String ATWTB    {get;set;}
            @AuraEnabled public String IF_DEFAULT  {get;set;}

            @AuraEnabled public String ZSEQNO   {get;set;}
            @AuraEnabled public String KBETR    {get;set;}
            @AuraEnabled public String KONWA    {get;set;}
            @AuraEnabled public String SHOW     {get;set;}
            @AuraEnabled public String ZCVDESC  {get;set;}
            

            public IF_OPTY_023_Res_T_VALUE(){}
        }
        public class IF_OPTY_023_Res_T_INITSEL{
            @AuraEnabled public String ATNAM        {get;set;}
            @AuraEnabled public String ATBEZ        {get;set;}
            @AuraEnabled public String ATWRT        {get;set;}
            @AuraEnabled public String ATWTB        {get;set;}

            @AuraEnabled public String IF_DEFAULT   {get;set;}
            @AuraEnabled public String ZSEQNO       {get;set;}
            @AuraEnabled public String SHOW         {get;set;}
            @AuraEnabled public String ZCVDESC      {get;set;}

            public IF_OPTY_023_Res_T_INITSEL(){}
        }
        public class IF_OPTY_023_Res_T_SELECT{
            @AuraEnabled public String ATNAM        {get;set;}
            @AuraEnabled public String ATBEZ        {get;set;}
            @AuraEnabled public String ATWRT        {get;set;}
            @AuraEnabled public String ATWTB        {get;set;}

            @AuraEnabled public String IF_DEFAULT   {get;set;}
            @AuraEnabled public String ZSEQNO       {get;set;}
            @AuraEnabled public String SHOW         {get;set;}
            @AuraEnabled public String ZCVDESC      {get;set;}

            public IF_OPTY_023_Res_T_SELECT(){}
        }
        public class IF_OPTY_023_Res_T_INCON_VALUE{
            @AuraEnabled public String ATNAM        {get;set;}
            @AuraEnabled public String ATBEZ        {get;set;}
            @AuraEnabled public String ATWRT        {get;set;}
            @AuraEnabled public String ATWTB        {get;set;}

            @AuraEnabled public String IF_DEFAULT   {get;set;}
            @AuraEnabled public String ZSEQNO       {get;set;}
            @AuraEnabled public String SHOW         {get;set;}
            @AuraEnabled public String ZCVDESC      {get;set;}

            public IF_OPTY_023_Res_T_INCON_VALUE(){}
        }
        public class IF_OPTY_023_Res_T_INCOM_OPTION{
            @AuraEnabled public String ATNAM    {get;set;}
            @AuraEnabled public String ATBEZ    {get;set;}
            @AuraEnabled public String ZSEQNO   {get;set;}
            @AuraEnabled public String SHOW     {get;set;}

            @AuraEnabled public String READONLY {get;set;}
            @AuraEnabled public String ATEIN    {get;set;}
            @AuraEnabled public String FLREQ    {get;set;}
            @AuraEnabled public String GRNAM    {get;set;}
            
            @AuraEnabled public String DISPLAY  {get;set;}
            @AuraEnabled public String ZCVDESC  {get;set;}

            public IF_OPTY_023_Res_T_INCOM_OPTION(){}
        }
        public class IF_OPTY_023_Res_T_GROUP{
            @AuraEnabled public String GRNAM    {get;set;}
            @AuraEnabled public String ATNAM    {get;set;}
            @AuraEnabled public String ATINN    {get;set;}

            public IF_OPTY_023_Res_T_GROUP(){}
        }
        public class IF_OPTY_023_Res_T_USERSEL{
            @AuraEnabled public String ATNAM        {get;set;}
            @AuraEnabled public String ATBEZ        {get;set;}
            @AuraEnabled public String ATWRT        {get;set;}
            @AuraEnabled public String ATWTB        {get;set;}

            @AuraEnabled public String IF_DEFAULT   {get;set;}
            @AuraEnabled public String ZSEQNO       {get;set;}
            @AuraEnabled public String KBETR        {get;set;}
            @AuraEnabled public String KONWA        {get;set;}
            
            @AuraEnabled public String SHOW         {get;set;}
            @AuraEnabled public String ZCVDESC      {get;set;}

            public IF_OPTY_023_Res_T_USERSEL(){}
        }

    /** SFDC interface Id    : IF-OPTY-027
     * RFC Name              : ZCRM_SD_GET_CV_MARKUP       
     * Description           : CV Markup 조회 (CRM -> ERP)
        */
        public class IF_OPTY_027_Res{
            @AuraEnabled public IF_OPTY_027_Res_O_RETURN        O_RETURN    {get;set;}
            @AuraEnabled public List<IF_OPTY_027_Res_T_LIST>    T_LIST      {get;set;}

            public IF_OPTY_027_Res(){}
        }
        public class IF_OPTY_027_Res_O_RETURN{
            @AuraEnabled public String TYPE     {get;set;}
            @AuraEnabled public String CODE     {get;set;}
            @AuraEnabled public String MESSAGE  {get;set;}

            public IF_OPTY_027_Res_O_RETURN(){}
        }
        public class IF_OPTY_027_Res_T_LIST{
            @AuraEnabled public String MANDT    {get;set;}
            @AuraEnabled public String REGION   {get;set;}
            @AuraEnabled public String WAERK    {get;set;}
            @AuraEnabled public String LAND1    {get;set;}

            @AuraEnabled public String VKORG    {get;set;}
            @AuraEnabled public String VTWEG    {get;set;}
            @AuraEnabled public String KUNNR    {get;set;}
            @AuraEnabled public String REGIONT  {get;set;}
            
            @AuraEnabled public String AOP      {get;set;}
            @AuraEnabled public String MAGRATE  {get;set;}
            @AuraEnabled public String GSTRU    {get;set;}
            @AuraEnabled public String SORTF    {get;set;}

            public IF_OPTY_027_Res_T_LIST(){}
        }

    /** SFDC interface Id    : IF-OPTY-029
     * RFC Name              : ZCRM_SD_GLOBAL_DEALER_BASECODE       
     * Description           : 글로벌 딜러가 대표사양을 좀 더 구체적으로 식별할 수 있도록 추가 옵션 정보들을 적립해놓은 테이블 조회
     * Endpoint              : http://218.147.24.51:4148/invoke/di_salesforce.serv.SD.main:DICRM_SD_GLOBAL_DEALER_BASECODE_M
        */
        public class IF_OPTY_029_Req{
            @AuraEnabled public String I_FROM_DAT   {get;set;}
            @AuraEnabled public String I_TO_DAT     {get;set;}

            public IF_OPTY_029_Req(){}
        }
        public class IF_OPTY_029_Res{
            @AuraEnabled public IF_OPTY_029_Res_O_RETURN        O_RETURN     {get;set;}
            @AuraEnabled public String                          CNT          {get;set;}
            @AuraEnabled public List<IF_OPTY_029_Res_T_O_LIST>  T_O_LIST     {get;set;}

            public IF_OPTY_029_Res(){}
        }
        public class IF_OPTY_029_Res_O_RETURN{
            @AuraEnabled public String TYPE     {get;set;}
            @AuraEnabled public String CODE     {get;set;}
            @AuraEnabled public String MESSAGE  {get;set;}

            public IF_OPTY_029_Res_O_RETURN(){}
        }
        public class IF_OPTY_029_Res_T_O_LIST{
            @AuraEnabled public String ATWTB19  {get;set;}
            @AuraEnabled public String SATNR    {get;set;}
            @AuraEnabled public String SAKTX    {get;set;}
            @AuraEnabled public String MATNR    {get;set;}
            @AuraEnabled public String MAKTX    {get;set;}

            @AuraEnabled public String ATWTB13  {get;set;}
            @AuraEnabled public String ATWTB    {get;set;}
            @AuraEnabled public String ATWTB18  {get;set;}
            @AuraEnabled public String ATWTB15  {get;set;}
            @AuraEnabled public String ATWTB16  {get;set;}
            
            @AuraEnabled public String ATWTB17  {get;set;}
            @AuraEnabled public String ATWTB20  {get;set;}
            @AuraEnabled public String ZDATE    {get;set;}

            // 2025.04.03 변경
            // @AuraEnabled public String MANDT    {get;set;}
            // @AuraEnabled public String REGION   {get;set;}
            // @AuraEnabled public String SATNR    {get;set;}
            // @AuraEnabled public String SAKTX    {get;set;} 
            // @AuraEnabled public String MATNR    {get;set;}

            // @AuraEnabled public String MAKTX    {get;set;}
            // @AuraEnabled public String ATWTB    {get;set;}
            // @AuraEnabled public String ATWTB2   {get;set;}
            // @AuraEnabled public String ATWTB5   {get;set;}
            // @AuraEnabled public String ATWTB3   {get;set;}
            
            // @AuraEnabled public String ATWTB4   {get;set;}
            // @AuraEnabled public String ZDATE    {get;set;}

            public IF_OPTY_029_Res_T_O_LIST(){}
        }

    /** SFDC interface Id    : IF-OPTY-030
     * RFC Name              : ZCRM_SD_REG_PROD_CODE
     * Description           : Sold-to permitted item 전송
        */
        public class IF_OPTY_030_Req{
            public IF_OPTY_030_Req(){}
            @AuraEnabled public String I_FROM       {get;set;}
            @AuraEnabled public String I_TO         {get;set;}
            @AuraEnabled public String I_VKORG      {get;set;}
            @AuraEnabled public String I_VTWEG      {get;set;}
            @AuraEnabled public String I_LAND1      {get;set;}
        }
        public class IF_OPTY_030_Res{
            public IF_OPTY_030_Res(){}
            @AuraEnabled public List<IF_OPTY_030_Res_T_LIST>    T_LIST      {get;set;}
            @AuraEnabled public IF_OPTY_030_Res_O_RETURN        O_RETURN    {get;set;}
        }
        public class IF_OPTY_030_Res_T_LIST{
            public IF_OPTY_030_Res_T_LIST(){}
            @AuraEnabled public String MANDT        {get;set;}
            @AuraEnabled public String VKORG        {get;set;}
            @AuraEnabled public String VTWEG        {get;set;}
            @AuraEnabled public String SPART        {get;set;}
            @AuraEnabled public String KUNNR        {get;set;}

            @AuraEnabled public String MATNR        {get;set;}
            @AuraEnabled public String MALNR        {get;set;}
            @AuraEnabled public String DEIND        {get;set;}
            @AuraEnabled public String ERDAT        {get;set;}
            @AuraEnabled public String ERNAM        {get;set;}
            
            @AuraEnabled public String ERZET        {get;set;}
            @AuraEnabled public String AEDAT        {get;set;}
            @AuraEnabled public String AENAM        {get;set;}
            @AuraEnabled public String AEZET        {get;set;}
            @AuraEnabled public String ZMDDESC      {get;set;} // 2025-05-16 필드 추가
        }
        public class IF_OPTY_030_Res_O_RETURN{
            public IF_OPTY_030_Res_O_RETURN(){}
            @AuraEnabled public String TYPE         {get;set;}
            @AuraEnabled public String CODE         {get;set;}
            @AuraEnabled public String MESSAGE      {get;set;}
        }

// ** IF-OPTY-031				
/**
  */
  /**
         * Wrapper Name         : IF_OPTY_031
         * SFDC interface Id    : IF-OPTY-031
         * New I/F              : ZCRM_SD_PART_SALES_ORG_GET
         * Description          : 부품 판매 조직 조회
  */    
    // ** REQUEST
    /**
        */
        public class IF_OPTY_031_Req { 
            @AuraEnabled public String I_VKORG {get;set;} // ? Sales Organization
            @AuraEnabled public List<IF_OPTY_031_Req_T_MATNR> T_MATNR {get;set;} 
        }

        public class IF_OPTY_031_Req_T_MATNR { 
            @AuraEnabled public String SIGN {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String OPTION {get;set;} // ? Version Number Component
            @AuraEnabled public String LOW  {get;set;} // ? Character field length 24
            @AuraEnabled public String HIGH {get;set;} // ? Character field length 24
        }          



    // ** RESPONSE
    /**
        */          
        public class IF_OPTY_031_Res { 
            @AuraEnabled public List<IF_OPTY_031_Res_T_MATNR> T_MATNR {get;set;} 
            @AuraEnabled public IF_OPTY_031_Res_O_RETURN O_RETURN {get;set;} 
        }

        public class IF_OPTY_031_Res_T_MATNR { 
            @AuraEnabled public String SIGN {get;set;} // ? Single-Character Indicator
            @AuraEnabled public String OPTION {get;set;} // ? Version Number Component
            @AuraEnabled public String LOW  {get;set;} // ? Character field length 24
            @AuraEnabled public String HIGH {get;set;} // ? Character field length 24
        }

        public class IF_OPTY_031_Res_O_RETURN { 
            @AuraEnabled public String TYPE    {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE    {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE {get;set;} // ? Message Text
        }


// ** IF-OPTY-032				
/**
  */
  /**
         * Wrapper Name         : IF_OPTY_032
         * SFDC interface Id    : IF-OPTY-032
         * New I/F              : ZCRM_ST_BASE_CODE_LIST
         * Description          : 지역별 BASE CODE 조회
         * author               : SUNG SEO UK
  */    
    // ** REQUEST
    /**
        */
        public class IF_OPTY_032_Req{
            @AuraEnabled public String I_SDATE {get;set;}
            @AuraEnabled public String I_EDATE {get;set;} 
        }                
        
    // ** RESPONSE
    /**
        */
        public class IF_OPTY_032_Res{
            @AuraEnabled public IF_OPTY_032_Res_O_RETURN     O_RETURN {get;set;}
            @AuraEnabled public List<IF_OPTY_032_Res_T_LIST> T_LIST   {get;set;}
        }                

        public class IF_OPTY_032_Res_O_RETURN{
            @AuraEnabled public String TYPE     {get;set;} // ? Message type: S Success, E Error, W Warning, I Info, A Abort
            @AuraEnabled public String CODE     {get;set;} // ? Message code
            @AuraEnabled public String MESSAGE  {get;set;} // ? Message Text           
        }

        public class IF_OPTY_032_Res_T_LIST{
            @AuraEnabled public String REGION {get;set;} // ? REGION 
            @AuraEnabled public String SATNR  {get;set;} // ? Cross-Plant Configurable Material
            @AuraEnabled public String SAKTX  {get;set;} // ? Material Description (Short Text)
            @AuraEnabled public String MATNR  {get;set;} // ? Material Number
            @AuraEnabled public String MAKTX  {get;set;} // ? Material Description (Short Text)
            @AuraEnabled public String ATWTB  {get;set;} // ? NC SYSTEM
            @AuraEnabled public String ATWTB2 {get;set;} // ? MAX. SPINDLE SPEED
            @AuraEnabled public String ATWTB5 {get;set;} // ? MAX. MAIN SPINDLE SPEED
            @AuraEnabled public String ATWTB3 {get;set;} // ? TOOL STORAGE CAPACITY
            @AuraEnabled public String ATWTB4 {get;set;} // ? MONITOR SIZE            
        }
                

        
}