public with sharing class IF_ERP_Service_Scrap {
    public IF_ERP_Service_Scrap() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Service_Scrap';
    private Boolean isResponseXml = true; 
    private String  interfaceId;

    /** SFDC interface Id   : IF-SERVICE-047
     * AS-IS RFC            : Z_CS_WEB_ITEM_TO_BE_RETURN_ME
     * New I/F              : ZCRM_CS_WEB_ITEM_TO_BE_RETURN
     * Description          : Parts > 부품정보 > 멀티부품정보조회
        */
        public IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res IF_SERVICE_047(IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Req parameters){
            interfaceId = 'IF-SERVICE-047';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            
                try {
                    IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res response = 
                    (IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res) JSON.deserialize(
                        responseString, 
                        IF_ERP_Service_Scrap_Classes.IF_SERVICE_047_Res.class);
                
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
                        System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WEB_ITEM_TO_BE_RETURN');
                        return response;        
        
                } catch (Exception e) {
                    System.debug('ERROR MESSAGE : '+e.getMessage());
                    System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                    return null;        
                }
        }

    /** SFDC interface Id   : IF-SERVICE-048
     * AS-IS RFC            : Z_CS_WEB_RETURN_PARTS_PRINT
     * New I/F              : ZCRM_CS_WEB_RETURN_PARTS_PRINT
     * Description          : Service > Service > 관리 > 폐품미반납리스트
        */
        public IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res IF_SERVICE_048(IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Req parameters){
            interfaceId = 'IF-SERVICE-048';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters)
                                        + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            
                try {
                    System.debug('responseString :: '+responseString);
        
                    IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res response = 
                    (IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res) JSON.deserialize(
                        responseString, 
                        IF_ERP_Service_Scrap_Classes.IF_SERVICE_048_Res.class);
                    
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
                        System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WEB_RETURN_PARTS_PRINT');
                        return response;        
        
                } catch (Exception e) {
                    System.debug('ERROR MESSAGE : '+e.getMessage());
                    System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                    return null;        
                }
        }
}