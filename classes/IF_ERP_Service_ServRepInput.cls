public with sharing class IF_ERP_Service_ServRepInput {
    public IF_ERP_Service_ServRepInput() {}
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Service_ServRepInput';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

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
    public IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res IF_SERVICE_046(IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req parmeters){
        List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP>    T_TMP     = parmeters.T_TMP;
        List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP_SR> T_TMP_SR  = parmeters.T_TMP_SR;

        for (IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP T_TMP_E : T_TMP) {
            if(T_TMP_E.FILENAME != null) T_TMP_E.FILENAME      = EncodingUtil.urlEncode(T_TMP_E.FILENAME, 'UTF-8');
            if(T_TMP_E.IF_DESC  != null) T_TMP_E.IF_DESC       = EncodingUtil.urlEncode(T_TMP_E.IF_DESC, 'UTF-8');
        }

        for (IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP_SR T_TMP_SR_E : T_TMP_SR) {
            if(T_TMP_SR_E.FILENAME != null) T_TMP_SR_E.FILENAME      = EncodingUtil.urlEncode(T_TMP_SR_E.FILENAME, 'UTF-8');
            if(T_TMP_SR_E.IF_DESC  != null) T_TMP_SR_E.IF_DESC       = EncodingUtil.urlEncode(T_TMP_SR_E.IF_DESC, 'UTF-8');
        }

        parmeters.T_TMP     = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP>();
        parmeters.T_TMP_SR  = new List<IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Req_T_TMP_SR>();

        interfaceId = 'IF-SERVICE-046';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        parmetersString = encodeForSAP(parmetersString);

        parmetersString = parmetersString.replace('"T_TMP":[]', '"T_TMP":' + Json.serialize(T_TMP));
        parmetersString = parmetersString.replace('"T_TMP_SR":[]', '"T_TMP_SR":' + Json.serialize(T_TMP_SR));

        parmetersString = parmetersString.replaceAll('IF_DESC', 'DESC');
        interfaceUtil.isCustomURLEncode = true;
        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        responseString  = responseString.replaceAll('DESC', 'IF_DESC');

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res response = 
            (IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Service_ServRepInput_Classes.IF_SERVICE_046_Res.class);    
    
                System.debug(':::::::::::::    ');
                System.debug(':::::::::::::    ');            
                System.debug(':::::::::::::  RESPONSE =>');
                System.debug(':::::::::::::    {');
                System.debug(':::::::::::::    '+JSON.serialize(response));
                System.debug(':::::::::::::    } ');
                System.debug(':::::::::::::    ');
                System.debug(':::::::::::::    ');
                System.debug(':::::::::::::    ');
                System.debug(':::::::::::::    INTERFACE ID : '+interfaceId);
                System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WEB_JOB_RESULT_CONFIRM');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }       

    private String encodeForSAP(String jsonString){
        jsonString = EncodingUtil.urlEncode(jsonString, 'UTF-8');
        jsonString = jsonString.replaceAll('%3D', '=');
        jsonString = jsonString.replaceAll('%7B', '{');
        jsonString = jsonString.replaceAll('%22', '"');
        jsonString = jsonString.replaceAll('%3A', ':');
        jsonString = jsonString.replaceAll('%7D', '}');  
        jsonString = jsonString.replaceAll('%5B', '[');  
        jsonString = jsonString.replaceAll('%5D', ']');  

        return jsonString;
    }
}