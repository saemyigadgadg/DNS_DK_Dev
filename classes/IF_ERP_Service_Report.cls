/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 02-10-2025
 * @last modified by  : Chungwoo Lee
**/
public with sharing class IF_ERP_Service_Report {
    public IF_ERP_Service_Report() {}

    public InterfaceCommonUtil interfaceUtil  = InterfaceCommonUtil.getInterfaceUtil();
    private String              apexClassName = 'IF_ERP_Service_Report';
    private Boolean             isResponseXml = true;  
    private String              interfaceId;


    /**
         * Wrapper Name         : IF_SERVICE_011
         * SFDC interface Id    : IF-SERVICE-011
         * AS-IS RFC            : Z_CS_SEARCH_CAUSE_TO_BLAME	
         * New I/F              : ZCRM_CS_SEARCH_CAUSE_TO_BLAME
         * Description          : 귀책부서 Picklist 가져오기 
     */
    public IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res IF_SERVICE_011(IF_ERP_Service_Report_Classes.IF_SERVICE_011_Req parameters){
        interfaceId = 'IF-SERVICE-011';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try {
                System.debug('responseString :: '+responseString);
    
                IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res response = 
                (IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Service_Report_Classes.IF_SERVICE_011_Res.class);
            
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_SEARCH_CAUSE_TO_BLAME');
                    return response;        
    
            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }     
    }

    /**
     * Wrapper Name         : IF_SERVICE_049
     * SFDC interface Id    : IF-SERVICE-049
     * New I/F              : ZCRM_CS_WEB_REQ_RES_SAVE_MT
     * Description          : 유상 리포트 정보 조회
        */
        public IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res IF_SERVICE_049(IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req parameters){
            List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_TMP>    T_TMP     = parameters.T_TMP;

            for (IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_TMP T_TMP_E : T_TMP) {
                if(T_TMP_E.FILENAME != null) T_TMP_E.FILENAME      = EncodingUtil.urlEncode(T_TMP_E.FILENAME, 'UTF-8');
                if(T_TMP_E.IF_DESC  != null) T_TMP_E.IF_DESC       = EncodingUtil.urlEncode(T_TMP_E.IF_DESC, 'UTF-8');
            }

            parameters.T_TMP     = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_049_Req_T_TMP>();

            interfaceId = 'IF-SERVICE-049';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 

            parametersString = encodeForSAP(parametersString);

            parametersString = parametersString.replace('"T_TMP":[]', '"T_TMP":' + Json.serialize(T_TMP));
                                    
            // interfaceUtil.isIF_Case = true;
            parametersString = parametersString.replaceAll('IF_DESC','DESC');
            interfaceUtil.isCustomURLEncode = true;
            String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            responseString = responseString.replaceAll('DESC','IF_DESC');

            try {
                IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res response = 
                    (IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res) JSON.deserialize(
                        responseString, 
                        IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res.class);
            
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
                        System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WEB_REQ_RES_SAVE_MT');
                        return response;            
    
            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }     
        }


// ** IF-SERVICE-050				
/**
  */
  /**
         * Wrapper Name         : IF_SERVICE_050
         * SFDC interface Id    : IF-SERVICE-050
         * New I/F              : ZCRM_CS_WEB_JOB_RESULT_CONF
         * Description          : 서비스리포트 확정
  */    
   public IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res IF_SERVICE_050(IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req parameters){
        List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_TMP>        T_TMP       = parameters.T_TMP;
        List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_TMP_SR>     T_TMP_SR    = parameters.T_TMP_SR;

        parameters.T_TMP     = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_TMP>();
        parameters.T_TMP_SR  = new List<IF_ERP_Service_Report_Classes.IF_SERVICE_050_Req_T_TMP_SR>();

        interfaceId = 'IF-SERVICE-050';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        parametersString = encodeForSAP(parametersString);

        parametersString = parametersString.replace('"T_TMP":[]', '"T_TMP":' + Json.serialize(T_TMP));
        parametersString = parametersString.replace('"T_TMP_SR":[]', '"T_TMP_SR":' + Json.serialize(T_TMP_SR));

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try {
                System.debug('responseString :: '+responseString);
    
                IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res response = 
                (IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Service_Report_Classes.IF_SERVICE_050_Res.class);
            
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WEB_JOB_RESULT_CONF');
                    return response;        
    
            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }     
    }

    
// ** IF-SERVICE-052				
/**
  */
  /**
         * Wrapper Name         : IF_SERVICE_052
         * SFDC interface Id    : IF-SERVICE-052
         * New I/F              : ZCRM_CS_WEB_JOB_CONF_CANC
         * Description          :  DNS 국내 서비스리포트 확정을 취소하기 위한 기능
  */ 
  public IF_ERP_Service_Report_Classes.IF_SERVICE_052_Res IF_SERVICE_052(IF_ERP_Service_Report_Classes.IF_SERVICE_052_Req parameters){
    interfaceId = 'IF-SERVICE-052';
    String parametersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parameters) 
                                + '}'; 

    String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_Service_Report_Classes.IF_SERVICE_052_Res response = 
            (IF_ERP_Service_Report_Classes.IF_SERVICE_052_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Service_Report_Classes.IF_SERVICE_052_Res.class);
        
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_WEB_JOB_CONF_CANC');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }     
}


/**
 * Wrapper Name         : IF_SERVICE_054
 * SFDC interface Id    : IF-SERVICE-054
 * New I/F              : ZCRM_CS_SEARCH_CLAIM_RECEIPT
 * Description          : 서비스리포트 조회
    */ 
    public IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res IF_SERVICE_054(IF_ERP_Service_Report_Classes.IF_SERVICE_054_Req parameters){
        interfaceId = 'IF-SERVICE-054';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 

        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        try {
            System.debug('responseString :: '+responseString);
            responseString.replace('".INCLUDE"', '"INCLUDE"');

            IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res response = 
            (IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res.class);
        
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_CS_SEARCH_CLAIM_RECEIPT');
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