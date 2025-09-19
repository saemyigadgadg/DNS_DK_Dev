/** SFDC interface Id   : IF-OPTY-017
 * Description          : AE Portal에서 PS 변경 후 전송
*/
@RestResource(urlMapping='/AEPortal/inquiryUpdate')
global with sharing class IF_AEPortal_Inquiry_API {
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_AEPortal_Inquiry_API';
    private String  interfaceId;

    global IF_AEPortal_Inquiry_API() {}
    global class ResponseDto{
        public String O_MSGTY;
        public String O_MSGTX;

        public ResponseDto(){}
    }

    @HTTPPost
    global static ResponseDto postHttp(){
        RestRequest  restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        ResponseDto responseDto = new ResponseDto();
        InterfaceCommonLog InterfaceCommonLog = new InterfaceCommonLog();
        InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog('IF-OPTY-017', 'IF_AEPortal_Inquiry_API');

        try {
            interfaceLog.requestTime = System.now();
            interfaceLog.requestBody = restReq.requestBody.toString();

            System.debug('restReq.params ::: ' + restReq.params);
            System.debug('restReq.params ::: ' + restReq.params.get('I_INQUIRY_NO'));
            System.debug('restReq.params.toString() ::: ' + restReq.params.toString());
            System.debug('restReq.requestBody ::: ' + restReq.requestBody);
            System.debug('restReq.requestBody.toString() ::: ' + restReq.requestBody.toString());
            List<Object> dataList = (List<Object>) JSON.deserializeUntyped(restReq.requestBody.toString());

            List<IF_AEPortal__c> AEPortalDataList = new List<IF_AEPortal__c>();

            // Map<String, Object> reqMap = (List<String, Object>) JSON.deserializeUntyped(restReq.requestBody.toString());
            // List<Object> dataList = (List<Object>) reqMap.get('TB_MTS_PROP_IF');
            for (Object data : dataList) {
                Map<String, Object> dataMap = (Map<String, Object>) data;
                IF_AEPortal__c AEPortalData = new IF_AEPortal__c();

                AEPortalData.Interface_ID__c           = 'IF-OPTY-017';

                if(dataMap.get('I_INQUIRY_NO') != null)             AEPortalData.I_INQUIRY_NO__c           = String.valueOf(dataMap.get('I_INQUIRY_NO'));
                if(dataMap.get('I_INQUIRY_ID') != null)             AEPortalData.I_INQUIRY_ID__c           = String.valueOf(dataMap.get('I_INQUIRY_ID'));
                if(dataMap.get('I_VERSION') != null)                AEPortalData.I_VERSION__c              = String.valueOf(dataMap.get('I_VERSION'));
                if(dataMap.get('I_RFQ_ACCEPT_DATE') != null)        AEPortalData.I_RFQ_ACCEPT_DATE__c      = String.valueOf(dataMap.get('I_RFQ_ACCEPT_DATE'));
                if(dataMap.get('I_REVIEW_REQUEST_DATE') != null)    AEPortalData.I_REVIEW_REQUEST_DATE__c  = String.valueOf(dataMap.get('I_REVIEW_REQUEST_DATE'));
                if(dataMap.get('I_BRANCH_NAME') != null)            AEPortalData.I_BRANCH_NAME__c          = String.valueOf(dataMap.get('I_BRANCH_NAME'));
                if(dataMap.get('I_SALES_PERSON') != null)           AEPortalData.I_SALES_PERSON__c         = String.valueOf(dataMap.get('I_SALES_PERSON'));
                if(dataMap.get('I_SE_PERSON') != null)              AEPortalData.I_SE_PERSON__c            = String.valueOf(dataMap.get('I_SE_PERSON'));
                if(dataMap.get('I_CUSTOMER_COMPANY') != null)       AEPortalData.I_CUSTOMER_COMPANY__c     = String.valueOf(dataMap.get('I_CUSTOMER_COMPANY'));
                if(dataMap.get('I_DEALER_CODE') != null)            AEPortalData.I_DEALER_CODE__c          = String.valueOf(dataMap.get('I_DEALER_CODE'));
                if(dataMap.get('I_PRODUCT_NAME') != null)           AEPortalData.I_PRODUCT_NAME__c         = String.valueOf(dataMap.get('I_PRODUCT_NAME'));
                if(dataMap.get('I_CATEGORY') != null)               AEPortalData.I_CATEGORY__c             = String.valueOf(dataMap.get('I_CATEGORY'));
                if(dataMap.get('I_MATERIAL_QUALITY') != null)       AEPortalData.I_MATERIAL_QUALITY__c     = String.valueOf(dataMap.get('I_MATERIAL_QUALITY'));
                if(dataMap.get('I_PRE_PROCESS') != null)            AEPortalData.I_PRE_PROCESS__c          = String.valueOf(dataMap.get('I_PRE_PROCESS'));
                if(dataMap.get('I_OUTPUT') != null)                 AEPortalData.I_OUTPUT__c               = String.valueOf(dataMap.get('I_OUTPUT'));
                if(dataMap.get('I_WORKING_HOURS') != null)          AEPortalData.I_WORKING_HOURS__c        = String.valueOf(dataMap.get('I_WORKING_HOURS'));
                if(dataMap.get('I_DUTY_DAY') != null)               AEPortalData.I_DUTY_DAY__c             = String.valueOf(dataMap.get('I_DUTY_DAY'));
                if(dataMap.get('I_OPERATION_RATE') != null)         AEPortalData.I_OPERATION_RATE__c       = String.valueOf(dataMap.get('I_OPERATION_RATE'));
                if(dataMap.get('I_CYCLE_IME_REQUEST') != null)      AEPortalData.I_CYCLE_IME_REQUEST__c    = String.valueOf(dataMap.get('I_CYCLE_IME_REQUEST'));
                if(dataMap.get('I_BODY_TYPE') != null)              AEPortalData.I_BODY_TYPE__c            = String.valueOf(dataMap.get('I_BODY_TYPE'));
                if(dataMap.get('I_MODEL_NAME') != null)             AEPortalData.I_MODEL_NAME__c           = String.valueOf(dataMap.get('I_MODEL_NAME'));
                if(dataMap.get('I_MACHINE_AMOUNT') != null)         AEPortalData.I_MACHINE_AMOUNT__c       = String.valueOf(dataMap.get('I_MACHINE_AMOUNT'));
                if(dataMap.get('I_MEASURE_TYPE') != null)           AEPortalData.I_MEASURE_TYPE__c         = String.valueOf(dataMap.get('I_MEASURE_TYPE'));
                if(dataMap.get('I_CLAMP') != null)                  AEPortalData.I_CLAMP__c                = String.valueOf(dataMap.get('I_CLAMP'));
                if(dataMap.get('I_RECOMD_COMPANY') != null)         AEPortalData.I_RECOMD_COMPANY__c       = String.valueOf(dataMap.get('I_RECOMD_COMPANY'));
                if(dataMap.get('I_AUTO_TYPE') != null)              AEPortalData.I_AUTO_TYPE__c            = String.valueOf(dataMap.get('I_AUTO_TYPE'));
                if(dataMap.get('I_LOADAGE') != null)                AEPortalData.I_LOADAGE__c              = String.valueOf(dataMap.get('I_LOADAGE'));
                if(dataMap.get('I_REMARK') != null)                 AEPortalData.I_REMARK__c               = String.valueOf(dataMap.get('I_REMARK'));
                if(dataMap.get('I_EMAIL') != null)                  AEPortalData.I_EMAIL__c                = String.valueOf(dataMap.get('I_EMAIL'));
                if(dataMap.get('I_TEL') != null)                    AEPortalData.I_TEL__c                  = String.valueOf(dataMap.get('I_TEL'));
                if(dataMap.get('I_WRITER') != null)                 AEPortalData.I_WRITER__c               = String.valueOf(dataMap.get('I_WRITER'));
                if(dataMap.get('I_IF_DATE') != null)                AEPortalData.I_IF_DATE__c              = String.valueOf(dataMap.get('I_IF_DATE'));
                if(dataMap.get('I_INQUIRY_SEQ') != null)            AEPortalData.I_INQUIRY_SEQ__c          = String.valueOf(dataMap.get('I_INQUIRY_SEQ'));
                if(dataMap.get('I_INQUIRY_DATE') != null)           AEPortalData.I_INQUIRY_DATE__c         = String.valueOf(dataMap.get('I_INQUIRY_DATE'));
                if(dataMap.get('I_SE_PERSON_NO') != null)           AEPortalData.I_SE_PERSON_NO__c         = String.valueOf(dataMap.get('I_SE_PERSON_NO'));
                if(dataMap.get('I_STATUS') != null)                 AEPortalData.I_STATUS__c               = String.valueOf(dataMap.get('I_STATUS'));
                if(dataMap.get('I_ORDER_STATUS') != null)           AEPortalData.I_ORDER_STATUS__c         = String.valueOf(dataMap.get('I_ORDER_STATUS'));
                if(dataMap.get('I_ADDRESS') != null)                AEPortalData.I_ADDRESS__c              = String.valueOf(dataMap.get('I_ADDRESS'));

                if(dataMap.get('PROP_CODE') != null)                AEPortalData.PROP_CODE__c              = String.valueOf(dataMap.get('PROP_CODE'));
                if(dataMap.get('I_USER_ID') != null)                AEPortalData.I_USER_ID__c              = String.valueOf(dataMap.get('I_USER_ID'));
                if(dataMap.get('I_CONTENTS') != null)               AEPortalData.I_CONTENTS__c             = String.valueOf(dataMap.get('I_CONTENTS'));
                if(dataMap.get('I_WRITE_DATE') != null)             AEPortalData.I_WRITE_DATE__c           = String.valueOf(dataMap.get('I_WRITE_DATE'));
                
                if(dataMap.get('I_REMARK') != null)                 AEPortalData.I_REMARK__c               = String.valueOf(dataMap.get('I_REMARK'));
                if(dataMap.get('I_RESULT_REMARK') != null)          AEPortalData.I_RESULT_REMARK__c        = String.valueOf(dataMap.get('I_RESULT_REMARK__c'));

                AEPortalDataList.add(AEPortalData);

            }
            if (AEPortalDataList.size() > 0) insert AEPortalDataList;
            
            responseDto.O_MSGTY = 'S';
            responseDto.O_MSGTX = 'Success'; 

        } catch (Exception e) {
            responseDto.O_MSGTY = 'E';
            responseDto.O_MSGTX = 'Error Messge : ' + e.getMessage();
            interfaceLog.errorText = new List<String>(); 
            interfaceLog.errorText.add(e.getLineNumber() + e.getMessage());   
        }
        
        interfaceLog.responseBody  = JSON.serialize(responseDto);
        interfaceLog.responseTime  = System.now();

        InterfaceCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{interfaceLog});
        
        DN_UpdatePSBatch batch = new DN_UpdatePSBatch();
        if(!Test.isRunningTest()) Database.executeBatch(batch);

        return responseDto;
    }

}