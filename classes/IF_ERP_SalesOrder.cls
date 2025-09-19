public with sharing class IF_ERP_SalesOrder {
    public IF_ERP_SalesOrder() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_SalesOrder';
    private Boolean isResponseXml = true;  
    private String  interfaceId;

    

    /** SFDC interface Id   : IF-OPTY-033
     * RFC Name             : ZCRM_SD_DNSA_MODEL_LST_US
     * Description          : DNSA Service Order 생성/수정
        */
        public IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res IF_OPTY_033(IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req parameters){
            interfaceId = 'IF-OPTY-033';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';
                                        
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try {
    
                IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res response = 
                    (IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res) JSON.deserialize(
                        responseString, 
                        IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res.class);
            
                return response;        
    
            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }


    /** SFDC interface Id   : IF-CSPLUS-038
     * RFC Name             : ZCRM_CS_EQUIPMNT_CHANGE
     * Description          : 장비 정보 수정(CRM -> ERP)
        */
        public IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res IF_CSPLUS_038(IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Req parameters){
            interfaceId = 'IF-CSPLUS-038';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';
                                        
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

                try {
        
                    IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res response = 
                    (IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res) JSON.deserialize(
                        responseString, 
                        IF_ERP_SalesOrder_Classes.IF_CSPLUS_038_Res.class);
                
                    return response;        
        
                } catch (Exception e) {
                    System.debug('ERROR MESSAGE : '+e.getMessage());
                    System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                    return null;        
                }
        }

    /** SFDC interface Id   : IF-CSPLUS-040
     * RFC Name             : ZCRM_CS_A_CLAIM_RESULT_SVC_SAV
     * Description          : DNSA 서비스리포트 결과 저장
        */
        public IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Res IF_CSPLUS_040(IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Req parameters){
            interfaceId = 'IF-CSPLUS-040';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';
                                        
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try {
    
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Res response = 
                (IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_SalesOrder_Classes.IF_CSPLUS_040_Res.class);
            
                return response;        
    
            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }
       /**
         * SFDC interface Id    : IF-CSPLUS-044
         * RFC                  : ZCRM_CSACLAIM_RECEIPT_SVC_SAV2
         * Description          : DNSA Service Order 생성/수정
        */ 
        public IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res IF_CSPLUS_044(IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req parameters){
            List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP>    T_TMP     = parameters.T_TMP;
            List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE>   T_FILE    = parameters.T_FILE;

            for (IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP T_TMP_E : T_TMP) {
                if(T_TMP_E.FILENAME != null) T_TMP_E.FILENAME      = EncodingUtil.urlEncode(T_TMP_E.FILENAME, 'UTF-8');
                if(T_TMP_E.IF_DESC != null) T_TMP_E.IF_DESC       = EncodingUtil.urlEncode(T_TMP_E.IF_DESC, 'UTF-8');
            }

            for (IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE T_FILE_E : T_FILE) {
                if(T_FILE_E.FILENAME != null) T_FILE_E.FILENAME      = EncodingUtil.urlEncode(T_FILE_E.FILENAME, 'UTF-8');
                if(T_FILE_E.IF_DESC  != null) T_FILE_E.IF_DESC       = EncodingUtil.urlEncode(T_FILE_E.IF_DESC, 'UTF-8');
            }

            parameters.T_TMP     = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP>();
            parameters.T_FILE    = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE>();

            interfaceId = 'IF-CSPLUS-044';
            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(parameters)
                                        + '}';
            System.debug('parametersString : '+parametersString);
            System.debug('parameters : '+parameters);
            parametersString = encodeForSAP(parametersString);

            parametersString = parametersString.replace('"T_TMP":[]', '"T_TMP":' + Json.serialize(T_TMP));   
            parametersString = parametersString.replace('"T_FILE":[]', '"T_FILE":' + Json.serialize(T_FILE));   

            parametersString = parametersString.replaceAll('IF_DESC', 'DESC');   
            
            interfaceUtil.isCustomURLEncode = true;
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            responseString   = responseString.replaceAll('DESC', 'IF_DESC`');                                        

            try {
    
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res response = 
                (IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res.class);


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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_CSACLAIM_RECEIPT_SVC_SAV2');
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