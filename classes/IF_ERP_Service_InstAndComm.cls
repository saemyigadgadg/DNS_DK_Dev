public with sharing class IF_ERP_Service_InstAndComm {
    public IF_ERP_Service_InstAndComm() {}

    
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Service_InstAndComm';
    private Boolean isResponseXml = true;  
    private String  interfaceId;


/** IF-SERVICE-045    
    */  
    /**
         * Apex Class           : IF_ERP_Service_InstAndComm
         * Wrapper Class        : IF_ERP_Service_InstAndComm_Classes
         * Wrapper Name         : IF-SERVICE-045
         * SFDC interface Id    : IF_SERVICE_045
         * AS-IS RFC            : Z_CS_WEB_PERIODIC_INSP_SAVE_MT
         * New I/F              : ZCRM_CS_WEB_PERIODIC_SAVE_MT
         * Description          : 설치/시운전 내역 생성-설치/시운전 완료 후 설치/시운전 리포트 작성 발송
         * KeyValue             : DESC -> IF_DESC
         * NOT NULL             : X
     */
    public IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res IF_SERVICE_045(IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req parmeters){
        List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_TMP>    T_TMP     = parmeters.T_TMP;

        for (IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_TMP T_TMP_E : T_TMP) {
            if(T_TMP_E.FILENAME != null) T_TMP_E.FILENAME      = EncodingUtil.urlEncode(T_TMP_E.FILENAME, 'UTF-8');
            if(T_TMP_E.IF_DESC  != null) T_TMP_E.IF_DESC       = EncodingUtil.urlEncode(T_TMP_E.IF_DESC, 'UTF-8');
        }

        parmeters.T_TMP = new List<IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Req_T_TMP>();

        interfaceId = 'IF-SERVICE-045';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        parmetersString = encodeForSAP(parmetersString);

        parmetersString = parmetersString.replace('"T_TMP":[]', '"T_TMP":' + Json.serialize(T_TMP));
        interfaceUtil.isIF_Case = true;             
        interfaceUtil.isCustomURLEncode = true;
        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res response = 
            (IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WEB_PERIODIC_SAVE_MT');
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