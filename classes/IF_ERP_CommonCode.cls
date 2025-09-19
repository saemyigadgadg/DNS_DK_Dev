/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-19-2024
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-19-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_CommonCode {
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_CommonCode';
    private Boolean isResponseXml = true;  
    private String  interfaceId;
    public IF_ERP_CommonCode() {}

    public IF_COMMONCODE_Res MIG_006(IF_COMMONCODE_Req parameters){
            // interfaceUtil.isInsertLog = false;
            interfaceId = 'MIG-006';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            try {
                System.debug('responseString :: '+responseString);
    
                IF_COMMONCODE_Res response = (IF_COMMONCODE_Res) JSON.deserialize(responseString, IF_COMMONCODE_Res.class);

                return response;        
    
            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }                        
    }

    public class IF_COMMONCODE_Req {
        public IF_COMMONCODE_Req(){
            this.I_CURRCODE  = '';
            this.I_COUNTNAM  = '';
            this.I_MTMAJCAT  = '';
            this.I_SALESORG  = '';
            this.I_DISTCHNL  = '';
            this.I_DIVISION  = '';
            this.I_INCOTERMS = '';
            this.I_ACCOUNTGR = '';
            this.I_PAYTERMS  = '';
            this.I_FIAGENCY  = '';
            this.I_SALESDIS  = '';
            this.I_USAGE     = '';
            this.I_CUSTOMGR  = '';
            this.I_SALESOFF  = '';
            this.I_ORDERRSN  = '';
            this.I_ORDERTYPE = '';
            this.I_TRNSPZONE = '';
            this.I_CUSTPPRC  = '';
            this.I_PRICELIST = '';
            this.I_SHIPCOND  = '';
            this.I_DELPALNT  = '';
            this.I_DESTINATION = '';
            this.I_REGION    = '';
            this.I_REJECTRSN = '';
            this.I_LANGU     = '';
        } 
        public String I_CURRCODE {get;set;}
        public String I_COUNTNAM {get;set;}
        public String I_MTMAJCAT {get;set;}
        public String I_SALESORG {get;set;}
        public String I_DISTCHNL {get;set;}

        public String I_DIVISION {get;set;}
        public String I_INCOTERMS {get;set;}
        public String I_ACCOUNTGR {get;set;}
        public String I_PAYTERMS {get;set;}
        public String I_FIAGENCY {get;set;}

        public String I_SALESDIS {get;set;}
        public String I_USAGE   {get;set;} //
        public String I_CUSTOMGR {get;set;}
        public String I_SALESOFF {get;set;}
        public String I_ORDERTYPE {get;set;}

        public String I_CUSTPPRC {get;set;}
        public String I_PRICELIST {get;set;}
        public String I_SHIPCOND {get;set;}
        public String I_DELPALNT {get;set;}
        public String I_REGION {get;set;}

        public String I_REJECTRSN {get;set;}
        public String I_LANGU {get;set;}
        
        public String I_TRNSPZONE {get;set;}
        public String I_DESTINATION {get;set;}
        public String I_ORDERRSN {get;set;}
    }

    public class IF_COMMONCODE_Res{
        public IF_COMMONCODE_Res(){} 
        public List<T_CURRCODE> T_CURRCODE   {get;set;}
        public List<T_COUNTNAM> T_COUNTNAM   {get;set;}
        public List<T_MTMAJCAT1> T_MTMAJCAT1  {get;set;}
        public List<T_MTMAJCAT2> T_MTMAJCAT2  {get;set;}
        public List<T_SALESORG> T_SALESORG   {get;set;}

        public List<T_DISTCHNL> T_DISTCHNL   {get;set;}
        public List<T_DIVISION> T_DIVISION   {get;set;}
        public List<T_INCOTERMS> T_INCOTERMS  {get;set;}
        public List<T_ACCOUNTGR> T_ACCOUNTGR  {get;set;}
        public List<T_PAYTERMS> T_PAYTERMS   {get;set;}

        public List<T_FIAGENCY> T_FIAGENCY   {get;set;}
        public List<T_SALESDIS> T_SALESDIS   {get;set;}
        public List<T_CUSTOMGR> T_CUSTOMGR   {get;set;}
        public List<T_SALESOFF> T_SALESOFF   {get;set;}
        public List<T_ORDERTYPE > T_ORDERTYPE  {get;set;}

        public List<T_ORDERTYPE2> T_ORDERTYPE2 {get;set;}
        public List<T_CUSTPPRC> T_CUSTPPRC   {get;set;}
        public List<T_PRICELIST> T_PRICELIST  {get;set;}
        public List<T_SHIPCOND> T_SHIPCOND   {get;set;}
        public List<T_DELPALNT> T_DELPALNT   {get;set;}

        public List<T_REGION> T_REGION     {get;set;}
        public List<T_REJECTRSN > T_REJECTRSN  {get;set;}
    }

    // Currency Code Return Table
    public class T_CURRCODE{
        public String MANDT {get;set;} // ? Client
        public String WAERS {get;set;} // ? Currency Key
        public String ISOCD {get;set;} // ? ISO currency code
        public String LTEXT {get;set;} // ? Long Text
        public String KTEXT {get;set;} // ? Short text
    }

    //Country Names Return Table
    public class T_COUNTNAM{
        public String MANDT      {get;set;} // ? Client
        public String SPRAS      {get;set;} // ? Language Key
        public String LAND1      {get;set;} // ? Country Key
        public String LANDX      {get;set;} // ? Country Name
        public String NATIO      {get;set;} // ? Nationality     
        public String LANDX50    {get;set;} // ? Country Name (Max. 50 Characters)
        public String NATIO50    {get;set;} // ? Nationality (Max. 50 Characters)
        public String PRQ_SPREGT {get;set;} // ? Super region per country text
     
    }
    
    // [CRM] SD 수요산업구분 대 Return Table
    public class T_MTMAJCAT1{        
        public String ZCRM_INDUS   {get;set;} // ? 수요산업구분 코드 - 대
        public String ZCRM_INDUS_T {get;set;} // ? Description        
    }
    
    // [CRM] SD 수요산업구분 소 Return Table
    public class T_MTMAJCAT2{
        public String ZCRM_INDUS   {get;set;} // ? 수요산업구분 코드 - 소
        public String ZCRM_INDUS_T {get;set;} // ? Description        
    }
    
    // Sales Org. Return Table
    public class T_SALESORG{
        public String MANDT        {get;set;} // ? Client     
        public String SPRAS        {get;set;} // ? Language Key
        public String VKORG        {get;set;} // ? Sales Organization
        public String VTEXT        {get;set;} // ? Description        
    }
    
    // Distribution Channel Return Table
    public class T_DISTCHNL{
        public String MANDT        {get;set;} // ? Client
        public String SPRAS        {get;set;} // ? Language Key     
        public String VTWEG        {get;set;} // ? Distribution Channel
        public String VTEXT        {get;set;} // ? Description        
    }    
    
    // Division Return Table
    public class T_DIVISION{
        public String MANDT        {get;set;} // ? Client
        public String SPRAS        {get;set;} // ? Language Key
        public String SPART        {get;set;} // ? Division     
        public String VTEXT        {get;set;} // ? Description
        
    }
    
    // 인도조건 Return Table
    public class T_INCOTERMS{
        public String MANDT        {get;set;} // ? Client
        public String SPRAS        {get;set;} // ? Language Key
        public String INCO1        {get;set;} // ? Incoterms (Part 1)
        public String BEZEI        {get;set;} // ? Description             
    }    
    
    // Account Group Return Table
    public class T_ACCOUNTGR{
        public String MANDT        {get;set;} // ? Client
        public String KTOKD        {get;set;} // ? Customer Account Group
        public String SPRAS        {get;set;} // ? Language Key
        public String TXT30        {get;set;} // ? Account Group Name
        
    }
    
    // Terms of Payment Return Table
    public class T_PAYTERMS{
        public String MANDT        {get;set;} // ? Client     
        public String SPRAS        {get;set;} // ? Language Key
        public String ZTERM        {get;set;} // ? Terms of Payment Key
        public String ZTAGG        {get;set;} // ? Day Limit
        public String TEXT1        {get;set;} // ? Description
        
    }
    
    // Fiencial Agency Code Return Table
    public class T_FIAGENCY{
        public String MANDT        {get;set;} // ? Client     
        public String BUKRS        {get;set;} // ? Company Code
        public String FA_CODE      {get;set;} // ? Financial Agency Code
        public String FA_TEXT      {get;set;} // ? Code Text
        public String ERDAT        {get;set;} // ? Date on Which Record Was Created
        public String ERNAM        {get;set;} // ? Name of Person who Created the Object     
        public String ERZET        {get;set;} // ? Entry time
        public String AEDAT        {get;set;} // ? Changed On
        public String AENAM        {get;set;} // ? Name of Person Who Changed Object
        public String AEZET        {get;set;} // ? Time last change was made
        
    }
    
    // Sales district Return Table
    public class T_SALESDIS{
        public String MANDT        {get;set;} // ? Client     
        public String SPRAS        {get;set;} // ? Language Key
        public String BZIRK        {get;set;} // ? Sales district
        public String BZTXT        {get;set;} // ? Name of the district        
    }
    
    // Customer group Return Table
    public class T_CUSTOMGR{
        public String MANDT        {get;set;} // ? Client
        public String SPRAS        {get;set;} // ? Language Key     
        public String KDGRP        {get;set;} // ? Customer group
        public String KTEXT        {get;set;} // ? Description
        
    }
    
    // Sales Office Return Table
    public class T_SALESOFF{
        public String MANDT        {get;set;} // ? Client
        public String SPRAS        {get;set;} // ? Language Key
        public String VKBUR        {get;set;} // ? Sales Office     
        public String BEZEI        {get;set;} // ? Description
        
    }
    
    // Order Type Return Table.. 무엇을 보여줄지 조건
    public class T_ORDERTYPE{
        public String MANDT        {get;set;} // ? Client
        public String VKORG        {get;set;} // ? Sales Organization
        public String VTWEG        {get;set;} // ? Distribution Channel
        public String SPART        {get;set;} // ? Division     
        public String KDGRP        {get;set;} // ? Customer group
        public String AUART        {get;set;} // ? Sales Document Type
        public String VBTYP        {get;set;} // ? [SS] Sales Document Category
        public String STATUS       {get;set;} // ? [SS] Status (Portal)
        
    }
    
    // Order Type Return Table. Order Type List
    public class T_ORDERTYPE2{
        public String AUART        {get;set;} // ? Sales Document Type     
        public String BEZEI        {get;set;} // ? Description
    }
    
    // Customer Pricing Procedures Return Table
    public class T_CUSTPPRC{
        public String MANDT        {get;set;} // ? Client
        public String SPRAS        {get;set;} // ? Language Key
        public String KALKS        {get;set;} // ? Pricing procedure assigned to this customer
        public String VTEXT        {get;set;} // ? Description
    }
    
    // Price List Return Table
    public class T_PRICELIST{             
        public String MANDT        {get;set;} // ? Client
        public String SPRAS        {get;set;} // ? Language Key
        public String PLTYP        {get;set;} // ? Price list type
        public String PTEXT        {get;set;} // ? Description
    }    
    
    // Shipping Conditions Return Table
    public class T_SHIPCOND{        
        public String MANDT        {get;set;} // ? Client     
        public String SPRAS        {get;set;} // ? Language Key
        public String VSBED        {get;set;} // ? Shipping Conditions
        public String VTEXT        {get;set;} // ? Description of the shipping conditions
    }
    
    // Delivering Plant Return Table
    public class T_DELPALNT{        
        public String MANDT        {get;set;} // ? Client
        public String VKORG        {get;set;} // ? Sales Organization     
        public String VTWEG        {get;set;} // ? Reference distrib.channel for cust.and material masters
        public String WERKS        {get;set;} // ? Plant (Own or External)
        public String NAME1        {get;set;} // ? Description
    }
    
    // Region Return Table
    public class T_REGION{        
        public String MANDT        {get;set;} // ? Client
        public String SPRAS        {get;set;} // ? Language Key     
        public String LAND1        {get;set;} // ? Country Key
        public String BLAND        {get;set;} // ? Region (State, Province, County)
        public String BEZEI        {get;set;} // ? Description
    }
    
    // Order Reject Reason Return Table
    public class T_REJECTRSN{        
        public String ABGRU        {get;set;} // ? Reason for rejection of quotations and sales orders
        public String BEZEI        {get;set;} // ? Description
    }   
    
}