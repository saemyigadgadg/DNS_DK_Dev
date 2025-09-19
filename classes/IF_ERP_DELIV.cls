/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-23-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_DELIV {
    public IF_ERP_DELIV() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String              apexClassName = 'IF_ERP_DELIV';
    private Boolean             isResponseXml = true;  
    private String              interfaceId;

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
    
    // SFDC interface Id    : IF_DELIV_001
    // AS-IS RFC            : Z_SD_CREATE_DELIVERY_ORDER_ME       
    // New I/F              : ZCRM_SD_CREATE_DELIVERY_ORDER		
    // Description          : DO 생성
    public IF_ERP_DELIV_Classes.IF_DELIV_001_Res IF_DELIV_001(IF_ERP_DELIV_Classes.IF_DELIV_001_Req parameters){
        List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP> T_TMP = parameters.T_TMP;
        
        parameters.T_TMP = new List<IF_ERP_DELIV_Classes.IF_DELIV_001_Req_T_TMP>();

        interfaceId = 'IF-DELIV-001';
        String parametersString = 'InputParam=' 
                                    + '{"Input":' 
                                    + JSON.serialize(parameters) 
                                    + '}'; 
        interfaceUtil.isIF_Case   = true;
        
        parametersString = encodeForSAP(parametersString);

        parametersString = parametersString.replace('"T_TMP":[]', '"T_TMP":' + Json.serialize(T_TMP));

        // interfaceUtil.isURLEncode = true;
        String responseString   = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

        IF_ERP_DELIV_Classes.IF_DELIV_001_Res response = 
            (IF_ERP_DELIV_Classes.IF_DELIV_001_Res) JSON.deserialize(responseString, IF_ERP_DELIV_Classes.IF_DELIV_001_Res.class);

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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_CREATE_DELIVERY_ORDER');            

        return response;        
    }



/** IF_DELIV_004
    */  
    /**
         * Apex Class           : IF_ERP_DELIV
         * Wrapper Class        : IF_ERP_DELIV_Classes
         * Wrapper Name         : IF-DELIV-004
         * SFDC interface Id    : IF_DELIV_004
         * AS-IS RFC            : Z_SD_GOOD_ISSUE_INFO
         * New I/F              : ZCRM_SD_GOOD_ISSUE_INFO
         * Description          : 고객/딜러 내륙 운송 현황 및 정보 조회 - 배차 번호 운전수 연락처 도착예상시간 등 정보 조회
         * KeyValue             : X
         * NOT NULL             : X
     */            
      public IF_ERP_DELIV_Classes.IF_DELIV_004_Res IF_DELIV_004(IF_ERP_DELIV_Classes.IF_DELIV_004_Req parameters){
        interfaceId = 'IF-DELIV-004';            
        String parametersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parameters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            try {
                System.debug('responseString :: '+responseString);

                IF_ERP_DELIV_Classes.IF_DELIV_004_Res response = 
                (IF_ERP_DELIV_Classes.IF_DELIV_004_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_DELIV_Classes.IF_DELIV_004_Res.class);    

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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GOOD_ISSUE_INFO');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }

/** IF-DELIV-002
    */  
    /**
         * Apex Class           : IF_ERP_DELIV
         * Wrapper Class        : IF_ERP_DELIV_Classes
         * Wrapper Name         : IF-DELIV-002
         * SFDC interface Id    : IF_DELIV_002
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_SEARCH_DELIVERY_LIST
         * Description          : DO 전송 (ERP -> CRM) - DO ERP & CRM 데이터 동기화 (생성, 수정)
         * KeyValue             : X
         * NOT NULL             : X
     */            
      public IF_ERP_DELIV_Classes.IF_DELIV_002_Res IF_DELIV_002(IF_ERP_DELIV_Classes.IF_DELIV_002_Req parameters){
        interfaceId = 'IF-DELIV-002';            
        String parametersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parameters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            try {
                System.debug('responseString :: '+responseString);

                IF_ERP_DELIV_Classes.IF_DELIV_002_Res response = 
                (IF_ERP_DELIV_Classes.IF_DELIV_002_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_DELIV_Classes.IF_DELIV_002_Res.class);    

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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_SEARCH_DELIVERY_LIST');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }

/** IF-DELIV-003
    */  
    /**
         * Apex Class           : IF_ERP_DELIV
         * Wrapper Class        : IF_ERP_DELIV_Classes
         * Wrapper Name         : IF-DELIV-003
         * SFDC interface Id    : IF_DELIV_003
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_INCOMING_PLAN_FOR_WEB
         * Description          : 선수금 입금 여부
         * KeyValue             : X
         * NOT NULL             : X
     */ 
      public IF_ERP_DELIV_Classes.IF_DELIV_003_Res IF_DELIV_003(IF_ERP_DELIV_Classes.IF_DELIV_003_Req parameters){
        interfaceId = 'IF-DELIV-003';            
        String parametersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parameters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            try {
                System.debug('responseString :: '+responseString);

                IF_ERP_DELIV_Classes.IF_DELIV_003_Res response = 
                (IF_ERP_DELIV_Classes.IF_DELIV_003_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_DELIV_Classes.IF_DELIV_003_Res.class);    

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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_INCOMING_PLAN_FOR_WEB');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }


    
}