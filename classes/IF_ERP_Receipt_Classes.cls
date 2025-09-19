public with sharing class IF_ERP_Receipt_Classes {
    public IF_ERP_Receipt_Classes() {}

    /**
    IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req wrapper = new IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req();
    wrapper.I_ORDER_NO = '403907561';
    
    IF_ERP_Receipt invokeClass = new IF_ERP_Receipt();
    invokeClass.IF_CSPLUS_008(wrapper); 
     */

/** SFDC interface Id   : IF-CSPLUS-008
 * AS-IS RFC            : ZCS_SEND_MT_GET_PACKING_DATE 
 * New I/F              : ZCRM_CS_MT_GET_PACKING_DATE       
 * Description          : 포장완료일 조회
    */ 
    public class IF_CSPLUS_008_Req{
        @AuraEnabled public String I_ORDER_NO {get;set;}
    }
    public class IF_CSPLUS_008_Res{
        @AuraEnabled public IF_CSPLUS_008_Res_O_RETURN O_RETURN {get;set;}
        @AuraEnabled public List<IF_CSPLUS_008_Res_T_O_LIST> T_O_LIST {get;set;}
    }
    public class IF_CSPLUS_008_Res_O_RETURN{
        @AuraEnabled public String TYPE     {get;set;}
        @AuraEnabled public String CODE     {get;set;}
        @AuraEnabled public String MESSAGE  {get;set;}

        public IF_CSPLUS_008_Res_O_RETURN(){}
    }
    public class IF_CSPLUS_008_Res_T_O_LIST{
        @AuraEnabled public String MATNR {get;set;}
        @AuraEnabled public String MENGE {get;set;}
        @AuraEnabled public String DAREG {get;set;}
        @AuraEnabled public String UAREG {get;set;}

        @AuraEnabled public String DAYYN {get;set;}
        @AuraEnabled public String QMNUM {get;set;}
        @AuraEnabled public String QMSEQ {get;set;}

        public IF_CSPLUS_008_Res_T_O_LIST(){}
    }

/** SFDC interface Id   : IF-CSPLUS-025
 * AS-IS RFC            : Z_CS_MT_AS_RECEIPT_LIST3 
 * New I/F              : ZCRM_CS_MT_AS_RECEIPT_LIST3       
 * Description          : * 필드하자 관리 대상 장비의 출하정보 매출정보 등 다양한 정보 조회
    */ 
    public class IF_CSPLUS_025_Req{
        @AuraEnabled public String FR_RECV_DT    {get;set;}
        @AuraEnabled public String TO_RECV_DT    {get;set;}
        @AuraEnabled public String I_STATUS      {get;set;}
        @AuraEnabled public String I_AUFNR       {get;set;}

        @AuraEnabled public String I_OF_CC_DP    {get;set;}
        @AuraEnabled public String I_ARBPL2      {get;set;}

        public IF_CSPLUS_025_Req(){}
    }
    public class IF_CSPLUS_025_Res{
        @AuraEnabled public IF_CSPLUS_025_Res_O_RETURN       O_RETURN {get;set;}
        @AuraEnabled public List<IF_CSPLUS_025_Res_T_O_LIST> T_O_LIST {get;set;}
        
        public IF_CSPLUS_025_Res(){}
    }
    public class IF_CSPLUS_025_Res_O_RETURN{
        @AuraEnabled public String TYPE          {get;set;} 
        @AuraEnabled public String CODE          {get;set;} 
        @AuraEnabled public String MESSAGE       {get;set;} 

        public IF_CSPLUS_025_Res_O_RETURN(){}
    }
    public class IF_CSPLUS_025_Res_T_O_LIST{
        @AuraEnabled public String AUFNR         {get;set;}
        @AuraEnabled public String QMNAM         {get;set;}
        @AuraEnabled public String NAME2         {get;set;}
        @AuraEnabled public String TYPBZ         {get;set;}

        @AuraEnabled public String SERNR         {get;set;}
        @AuraEnabled public String RECV_DT       {get;set;}
        @AuraEnabled public String ARBPL         {get;set;}
        @AuraEnabled public String ENAME         {get;set;}

        @AuraEnabled public String NC_UNIT       {get;set;}
        @AuraEnabled public String INBDT         {get;set;}
        @AuraEnabled public String MNCOD_TXT     {get;set;}
        @AuraEnabled public String MATXT         {get;set;}

        @AuraEnabled public String PARNR         {get;set;}
        @AuraEnabled public String WARRANT_BG    {get;set;}
        @AuraEnabled public String KTEXT         {get;set;}
        @AuraEnabled public String AGENT         {get;set;}

        @AuraEnabled public String AGENT_NAME    {get;set;}
        @AuraEnabled public String ENAME2        {get;set;}
        @AuraEnabled public String PERNR         {get;set;}
        @AuraEnabled public String E_WC          {get;set;}

        @AuraEnabled public String E_MAINWC      {get;set;}
        @AuraEnabled public String PRETD2        {get;set;}
        @AuraEnabled public String MATNR_TXT     {get;set;}
        @AuraEnabled public String ARBPL2        {get;set;}

        @AuraEnabled public String QDATU         {get;set;}

        public IF_CSPLUS_025_Res_T_O_LIST(){}    
    }

/** SFDC interface Id   : IF-CSPLUS-032
 * AS-IS RFC            : Z_CS_INSTALL_PRBM_SAVE
 * New I/F              : ZCRM_CS_INSTALL_PRBM_SAVE
 * Description          : * 설치 하자로 생성된 WorkOrder인지 여부 전송
    */ 
    public class IF_CSPLUS_032_Req{
        @AuraEnabled public String I_AUFNR  {get;set;}
        @AuraEnabled public String I_IPLBM  {get;set;}

        public IF_CSPLUS_032_Req(){}
    }
    public class IF_CSPLUS_032_Res{
        @AuraEnabled public IF_CSPLUS_032_Res_O_RETURN  O_RETURN {get;set;}
        
        public IF_CSPLUS_032_Res(){}
    }
    public class IF_CSPLUS_032_Res_O_RETURN{
        @AuraEnabled public String TYPE          {get;set;} 
        @AuraEnabled public String CODE          {get;set;} 
        @AuraEnabled public String MESSAGE       {get;set;} 

        public IF_CSPLUS_032_Res_O_RETURN(){}
    }

/** SFDC interface Id   : IF-CSPLUS-033
 * AS-IS RFC            : Z_CS_MT_MAT_REQUEST_LIST
 * New I/F              : ZCRM_CS_MT_MAT_REQUEST_LIST
 * Description          : * 필드하자 관리 부품 확보상태 조회
    */ 
    public class IF_CSPLUS_033_Req{
        @AuraEnabled public List<IF_CSPLUS_033_Req_T_I_AUFNR> T_I_AUFNR  {get;set;}

        public IF_CSPLUS_033_Req(){}
    }
    public class IF_CSPLUS_033_Req_T_I_AUFNR{
        @AuraEnabled public String SIGN     {get;set;}
        @AuraEnabled public String OPTION   {get;set;}
        @AuraEnabled public String LOW      {get;set;}
        @AuraEnabled public String HIGH     {get;set;}
                
        public IF_CSPLUS_033_Req_T_I_AUFNR(){}
    }
    public class IF_CSPLUS_033_Res{
        @AuraEnabled public IF_CSPLUS_033_Res_O_RETURN       O_RETURN {get;set;}
        @AuraEnabled public List<IF_CSPLUS_033_Res_T_O_LIST> T_O_LIST {get;set;}
        
        public IF_CSPLUS_033_Res(){}
    }
    public class IF_CSPLUS_033_Res_O_RETURN{
        @AuraEnabled public String TYPE          {get;set;} 
        @AuraEnabled public String CODE          {get;set;} 
        @AuraEnabled public String MESSAGE       {get;set;} 

        public IF_CSPLUS_033_Res_O_RETURN(){}
    }
    public class IF_CSPLUS_033_Res_T_O_LIST{
        @AuraEnabled public String MATNR        {get;set;}
        @AuraEnabled public String MAKTX        {get;set;}
        @AuraEnabled public String MENGE        {get;set;}
        @AuraEnabled public String MEINS        {get;set;}

        @AuraEnabled public String SUPPLY_TP    {get;set;}
        @AuraEnabled public String VENDOR       {get;set;}
        @AuraEnabled public String NAME1        {get;set;}
        @AuraEnabled public String VSBED        {get;set;}
        
        @AuraEnabled public String MATNR_TXT    {get;set;}
        @AuraEnabled public String MFLAG        {get;set;}
        @AuraEnabled public String RSNUM        {get;set;}
        @AuraEnabled public String RSPOS        {get;set;}
        
        @AuraEnabled public String QMNUM        {get;set;}
        @AuraEnabled public String QMSEQ        {get;set;}
        @AuraEnabled public String VBELN        {get;set;}
        @AuraEnabled public String NETWR        {get;set;}
        
        @AuraEnabled public String RETURN_YN    {get;set;}
        @AuraEnabled public String SOLDTO       {get;set;}
        @AuraEnabled public String SLTD         {get;set;}
        @AuraEnabled public String PLIFZ        {get;set;}
        
        @AuraEnabled public String SPIND        {get;set;}

        public IF_CSPLUS_033_Res_T_O_LIST(){}
    }
}