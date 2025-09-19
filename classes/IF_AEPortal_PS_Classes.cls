/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-18-2025
 * @last modified by  : deokjun.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-18-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_AEPortal_PS_Classes {
    public IF_AEPortal_PS_Classes() {}

    /** SFDC interface Id   : IF-OPTY-013
     * New I/F              : 
     * Description          : 
        */
        public class IF_OPTY_013_Req{
            @AuraEnabled public List<IF_OPTY_013_Req_TB_MTS_PROP_IF> TB_MTS_PROP_IF {get;set;}

            public IF_OPTY_013_Req(){}
        }
        public class IF_OPTY_013_Req_TB_MTS_PROP_IF{
            @AuraEnabled public String I_INQUIRY_NO {get;set;}
            @AuraEnabled public String I_VERSION {get;set;}
            @AuraEnabled public String I_RFQ_ACCEPT_DATE {get;set;}
            @AuraEnabled public String I_REVIEW_REQUEST_DATE {get;set;}

            @AuraEnabled public String I_BRANCH_NAME {get;set;}
            @AuraEnabled public String I_SALES_PERSON {get;set;}
            @AuraEnabled public String I_SE_PERSON {get;set;}
            @AuraEnabled public String I_CUSTOMER_COMPANY {get;set;}
            
            @AuraEnabled public String I_DEALER_CODE {get;set;}
            @AuraEnabled public String I_PRODUCT_NAME {get;set;}
            @AuraEnabled public String I_CATEGORY {get;set;}
            @AuraEnabled public String I_MATERIAL_QUALITY {get;set;}
            
            @AuraEnabled public String I_PRE_PROCESS {get;set;}
            @AuraEnabled public String I_OUTPUT {get;set;}
            @AuraEnabled public String I_WORKING_HOURS {get;set;}
            @AuraEnabled public String I_DUTY_DAY {get;set;}
            
            @AuraEnabled public String I_OPERATION_RATE {get;set;}
            @AuraEnabled public String I_CYCLE_IME_REQUEST {get;set;}
            @AuraEnabled public String I_BODY_TYPE {get;set;}
            @AuraEnabled public String I_MODEL_NAME {get;set;}
            
            @AuraEnabled public String I_MACHINE_AMOUNT {get;set;}
            @AuraEnabled public String I_MEASURE_TYPE {get;set;}
            @AuraEnabled public String I_CLAMP {get;set;}
            @AuraEnabled public String I_RECOMD_COMPANY {get;set;}
            
            @AuraEnabled public String I_AUTO_TYPE {get;set;}
            @AuraEnabled public String I_LOADAGE {get;set;}
            @AuraEnabled public String I_REMARK {get;set;}
            @AuraEnabled public String I_EMAIL {get;set;}
            
            @AuraEnabled public String I_TEL {get;set;}
            @AuraEnabled public String I_WRITER {get;set;}
            @AuraEnabled public String I_IF_DATE {get;set;}
            @AuraEnabled public String I_INQUIRY_SEQ {get;set;}
            
            @AuraEnabled public String I_INQUIRY_DATE {get;set;}
            @AuraEnabled public String I_SE_PERSON_NO {get;set;}
            @AuraEnabled public String I_STATUS {get;set;}
            @AuraEnabled public String I_ORDER_STATUS {get;set;}
            
            @AuraEnabled public String I_ADDRESS {get;set;}
            @AuraEnabled public String I_INQUIRY_ID {get;set;}

            // 2025.03.25 추가
            @AuraEnabled public String I_RESULT {get;set;}

            // 2025.04.01 추가
            @AuraEnabled public String I_RESULT_REMARK {get;set;}
            
            public IF_OPTY_013_Req_TB_MTS_PROP_IF(){}
        }
        public class IF_OPTY_013_Res{
            @AuraEnabled public String O_MSGTY  {get;set;}
            @AuraEnabled public String O_MSGTX  {get;set;}

            public IF_OPTY_013_Res(){}
        }

    /** SFDC interface Id   : IF-OPTY-016
     * Description          : AE Portal file 전송
     * 
     * Example 
     * FILE_NAME    : Sample.txt
     * INQUIRY_SEQ  : 15655
     * DOWNLOAD_URL : https://dn-solutions--dev.sandbox.my.salesforce.com/sfc/p/F700000020D3/a/F70000001M6F/Ch9sp_buGSsxha.n8OTlJSf3oYrPxXFZHYtQ6IF3RuY
     * INQUIRY_ID   : 006F700000HEFO1IAP
        */
        public class IF_OPTY_016_Req{
            @AuraEnabled public Integer ATTACH_SEQ      {get;set;}
            @AuraEnabled public String FILE_NAME        {get;set;}
            @AuraEnabled public String INQUIRY_SEQ      {get;set;}
            @AuraEnabled public String DOWNLOAD_URL     {get;set;}
            @AuraEnabled public String INQUIRY_ID       {get;set;}

            public IF_OPTY_016_Req(){}
        }
}