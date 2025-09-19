public with sharing class IF_ERP_DeliveryTraining {
    public IF_ERP_DeliveryTraining() {}
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_DeliveryTraining';
    private Boolean isResponseXml = true;  
    private String  interfaceId;


/** IF_PARTS_025
    */  
    /**
         * Apex Class           : IF_ERP_DeliveryTraining
         * Wrapper Class        : IF_ERP_DeliveryTraining_Classes
         * Wrapper Name         : IF_PARTS_025
         * SFDC interface Id    : IF_PARTS_025
         * AS-IS RFC            : Z_CS_WEB_PERIODIC_INSP_SAVE_ME
         * New I/F              : ZCRM_CS_WEB_PERIODIC_INSP_SAVE
         * Description          : 납품 후 교육/ 직영 서비스 결과 입력 저장/확정
         * IF_PARTS_025_Req_T_TMP => IF_DESC
         * IF_PARTS_025_Res_T_TMP => IF_DESC
     */     
    /** REQUEST 
      */      
    public IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res IF_PARTS_025(IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req parameters){
        List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_TMP> T_TMP = parameters.T_TMP;

        for (IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_TMP T_TMP_E : T_TMP) {
            if(T_TMP_E.FILENAME != null) T_TMP_E.FILENAME    = T_TMP_E.FILENAME.replaceAll('&', '%26').replaceALl('&', '%25');
            if(T_TMP_E.IF_DESC  != null) T_TMP_E.IF_DESC     = T_TMP_E.IF_DESC.replaceAll('&', '%26').replaceALl('&', '%25');
        }

        parameters.T_TMP     = new List<IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Req_T_TMP>();

        interfaceId = 'IF-PARTS-025';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        parametersString = encodeForSAP(parametersString);

        parametersString = parametersString.replace('"T_TMP":[]', '"T_TMP":' + Json.serialize(T_TMP));

        interfaceUtil.isIF_Case = true;
        interfaceUtil.isCustomURLEncode = true;
        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res response = 
            (IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res) JSON.deserialize(responseString, IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res.class);

        System.debug(':::::::::::::    ');
        System.debug(':::::::::::::    ');     
        System.debug(':::::::::::::  REQUEST =>');
        System.debug(':::::::::::::    {');
        System.debug(':::::::::::::    '+parametersString);
        System.debug(':::::::::::::    } ');
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
        System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WEB_PERIODIC_INSP_SAVE');
        
        
        return response;
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