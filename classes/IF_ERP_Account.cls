public with sharing class IF_ERP_Account {
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String apexClassName        = 'IF_ERP_Account';
    private Boolean isResponseXml       = true;    
    private String interfaceId;
    public IF_ERP_Account() {}

    // public IF_ERP_Classes.LookupAccountInfoRes lookupAccountInfo(IF_ERP_Classes.LookupAccountInfoReq parmeters){
    //     interfaceId = 'DICS_MT_CUSTOMER_INFO';            
    //     String parmetersString = 'inputParam=' 
    //                         + '{"Input":' 
    //                         + JSON.serialize(parmeters) 
    //                         + '}'; 

    //     String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
    //     responseString  = responseString.substringAfter('"Output":').substringBeforeLast('}');                
    //     String O_RETURN = responseString.substringAfter('"O_RETURN":').substringBefore('},')  + '}';        
    //     String T_O_LIST = responseString.substringAfter('"T_O_LIST":').substringBeforeLast('}');

    //     System.debug('responseString ::: ' + responseString);
    //     System.debug('O_RETURN ::: ' + O_RETURN);
    //     System.debug('T_O_LIST ::: ' + T_O_LIST);

    //     IF_ERP_Classes.LookupAccountInfoRes response = (IF_ERP_Classes.LookupAccountInfoRes) JSON.deserialize(T_O_LIST, IF_ERP_Classes.LookupAccountInfoRes.class);

    //     return response;
    // }

    
    // SFDC interface Id    : IF_ACCOUNT_001
    // AS-IS RFC            : Z_SD_MS_SP_CRE    
    // New I/F              : ZCRM_SD_MS_SP_CRE		
    // Description          : CRM 잠재고객 정보를 ERP 고객 마스터에 전송  
    public IF_ERP_Account_Classes.IF_ACCOUNT_001_Res IF_ACCOUNT_001(IF_ERP_Account_Classes.IF_Account_001_Req parmeters){
        interfaceId = 'IF-ACCOUNT-001';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 
    // interfaceUtil.isu0024Case = true;
    // interfaceUtil.isu005CCase = true;
    // interfaceUtil.isu002BCase = true;
        // System.debug(' parmetersString : '+parmetersString);
        // parmetersString = EncodingUtil.urlEncode(parmetersString, 'UTF-8');
        // parmetersString = parmetersString.replaceAll('%3D', '=');
        // parmetersString = parmetersString.replaceAll('%7B', '{');
        // parmetersString = parmetersString.replaceAll('%22', '"');
        // parmetersString = parmetersString.replaceAll('%3A', ':');
        // parmetersString = parmetersString.replaceAll('%7D', '}');  
        // parmetersString = parmetersString.replaceAll('%5B', '[');  
        // parmetersString = parmetersString.replaceAll('%5D', ']');  
        interfaceUtil.isURLEncode = true;

        System.debug(' encodStr : '+parmetersString);
        // String decodStr = EncodingUtil.urlDecode(encodStr, 'UTF-8');
        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        // System.debug(' decodStr : '+decodStr);
        

     try{
        
        IF_ERP_Account_Classes.IF_ACCOUNT_001_Res response = 
                (IF_ERP_Account_Classes.IF_ACCOUNT_001_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Account_Classes.IF_ACCOUNT_001_Res.class);

            System.debug(':::::::::::::    RESULT');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');     
            System.debug(':::::::::::::  REQUEST =>');
            System.debug(':::::::::::::    {');
            System.debug(':::::::::::::    '+parmetersString);
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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_SP_CRE');
            return response;

        }
        catch(Exception e){
            System.debug('Exception Manager : '+e.getMessage());
            System.debug('Exception Manager Line : '+e.getLineNumber());
            return null;
        }
    }    

    // SFDC interface Id    : IF_ACCOUNT_002
    // AS-IS RFC            : Z_SD_MS_SP_CHG       
    // New I/F              : ZCRM_SD_MS_SP_CHG				
    // Description          : CRM에서 잠재고객의 데이터가 변경되면 ERP 고객 마스터 데이터와 동기화  
    public IF_ERP_Account_Classes.IF_ACCOUNT_002_Res IF_ACCOUNT_002(IF_ERP_Account_Classes.IF_ACCOUNT_002_Req parmeters){
        interfaceId = 'IF-ACCOUNT-002';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        interfaceUtil.isURLEncode = true;
        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);

        try{
        
            IF_ERP_Account_Classes.IF_ACCOUNT_002_Res response = 
                    (IF_ERP_Account_Classes.IF_ACCOUNT_002_Res) JSON.deserialize(
                        responseString, 
                        IF_ERP_Account_Classes.IF_ACCOUNT_002_Res.class);
    
            System.debug(':::::::::::::    RESULT');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');     
            System.debug(':::::::::::::  REQUEST =>');
            System.debug(':::::::::::::    {');
            System.debug(':::::::::::::    '+parmetersString);
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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_SP_CHG');
            return response;

        }
        catch(Exception e){
            System.debug('Exception Manager : '+e.getMessage());
            System.debug('Exception Manager Line : '+e.getLineNumber());
            return null;
        }
    }


    
    // SFDC interface Id    : IF_ACCOUNT_006
    // AS-IS RFC            : Z_SD_MS_TC_CHG       
    // New I/F              : ZCRM_SD_MS_SP_TO_TC				
    // Description          : 잠재고객에서 실고객 전환 요청  
    public IF_ERP_Account_Classes.IF_ACCOUNT_006_Res IF_ACCOUNT_006(IF_ERP_Account_Classes.IF_ACCOUNT_006_Req parmeters){
        interfaceId = 'IF-ACCOUNT-006';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 
        try{

            String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

            IF_ERP_Account_Classes.IF_ACCOUNT_006_Res response = 
                    (IF_ERP_Account_Classes.IF_ACCOUNT_006_Res) JSON.deserialize(
                        responseString, 
                        IF_ERP_Account_Classes.IF_ACCOUNT_006_Res.class);
    
    
            System.debug(':::::::::::::    RESULT');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');
            System.debug(':::::::::::::    ');     
            System.debug(':::::::::::::  REQUEST =>');
            System.debug(':::::::::::::    {');
            System.debug(':::::::::::::    '+parmetersString);
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
            System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_SP_TO_TC');
            return response;

        }
        catch(Exception e){
            System.debug('Exception Manager : '+e.getMessage());
            System.debug('Exception Manager Line : '+e.getLineNumber());
            return null;
        }
    }

    // SFDC interface Id    : IF_ACCOUNT_003
    // AS-IS RFC            : NEW       
    // New I/F              : ZCRM_SD_MS_TC_CHG				
    // Description          : CRM에서 실고객의 데이터가 변경되면 ERP 고객 마스터 데이터와 동기화  
    public IF_ERP_Account_Classes.IF_ACCOUNT_003_Res IF_ACCOUNT_003(IF_ERP_Account_Classes.IF_ACCOUNT_003_Req parmeters){
        interfaceId = 'IF-ACCOUNT-003';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        interfaceUtil.isURLEncode = true;
        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {

            IF_ERP_Account_Classes.IF_ACCOUNT_003_Res response = 
            (IF_ERP_Account_Classes.IF_ACCOUNT_003_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Account_Classes.IF_ACCOUNT_003_Res.class);
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_TC_CHG');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }

// ** IF_ACCOUNT_004
    /**
         * Wrapper Name         : IF_ACCOUNT_004
         * SFDC interface Id    : IF-ACCOUNT-004
         * AS-IS RFC            : 	
         * New I/F              : ZCRM_SD_MS_SH_CRE
         * Description          : CRM에서 Ship-to의 데이터가 생성되면 ERP 고객 마스터 데이터와 동기화
     */
    public IF_ERP_Account_Classes.IF_ACCOUNT_004_Res IF_ACCOUNT_004(IF_ERP_Account_Classes.IF_ACCOUNT_004_Req parmeters){
        interfaceId = 'IF-ACCOUNT-004';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_Account_Classes.IF_ACCOUNT_004_Res response = 
            (IF_ERP_Account_Classes.IF_ACCOUNT_004_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Account_Classes.IF_ACCOUNT_004_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_SH_CRE');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }

/** IF_ACCOUNT_013
    */  
    /**
         * Wrapper Name         : IF_ACCOUNT_013
         * SFDC interface Id    : IF-ACCOUNT-013
         * AS-IS RFC            : 	
         * New I/F              : ZCRM_SD_MS_SH_CHG
         * Description          : CRM에서 Ship-to의 데이터가 변경되면 ERP 고객 마스터 데이터와 동기화
     */
    public IF_ERP_Account_Classes.IF_ACCOUNT_013_Res IF_ACCOUNT_013(IF_ERP_Account_Classes.IF_ACCOUNT_013_Req parmeters){
        interfaceId = 'IF-ACCOUNT-013';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        
        try {
            System.debug('responseString :: '+responseString);

            IF_ERP_Account_Classes.IF_ACCOUNT_013_Res response = 
            (IF_ERP_Account_Classes.IF_ACCOUNT_013_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Account_Classes.IF_ACCOUNT_013_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_SH_CHG');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }

/** IF_ACCOUNT_015
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_015
         * SFDC interface Id    : IF-ACCOUNT-015
         * AS-IS RFC            : Z_SD_CREATE_CUSTOMER_DIA	
         * New I/F              : ZCRM_SD_CREATE_CUSTOMER_USA
         * Description          : 고객 생성 (CRM -> ERP)-실고객 생성/Care of에 대한 RFC Copy
         * KeyValue             : X
         * NOT NULL             : X
     */        
    public IF_ERP_Account_Classes.IF_ACCOUNT_015_Res IF_ACCOUNT_015(IF_ERP_Account_Classes.IF_ACCOUNT_015_Req parmeters){
        interfaceId = 'IF-ACCOUNT-015';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            IF_ERP_Account_Classes.IF_ACCOUNT_015_Res response = 
            (IF_ERP_Account_Classes.IF_ACCOUNT_015_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Account_Classes.IF_ACCOUNT_015_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_CREATE_CUSTOMER_USA');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }    

/** IF_ACCOUNT_016 
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_016
         * SFDC interface Id    : IF-ACCOUNT-016
         * AS-IS RFC            : Z_SD_CUSTOMER_LIST_DIA
         * New I/F              : ZCRM_SD_CUSTOMER_LIST_USA
         * Description          : Sales Person 조회 (CRM -> ERP)-Sales Person-Dealer Code 연결에 대한 RFC
         * KeyValue             : X
         * NOT NULL             : X
     */   
    public IF_ERP_Account_Classes.IF_ACCOUNT_016_Res IF_ACCOUNT_016(IF_ERP_Account_Classes.IF_ACCOUNT_016_Req parmeters){
        interfaceId = 'IF-ACCOUNT-016';            
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parmeters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parmetersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            IF_ERP_Account_Classes.IF_ACCOUNT_016_Res response = 
            (IF_ERP_Account_Classes.IF_ACCOUNT_016_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Account_Classes.IF_ACCOUNT_016_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_CUSTOMER_LIST_USA');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }    

/** IF-ACCOUNT-005
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF-ACCOUNT-005
         * SFDC interface Id    : IF_ACCOUNT_005 
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_MS_SP_LST
         * Description          : 고객마스터 전송 - 고객 마스터 정보 반환하여 ERP & CRM 데이터 동기화 (생성, 수정 삭제) 실고객, 잠재고객, 대리점, 딜러 
         * KeyValue             : X
         * NOT NULL             : X
     */                
        public IF_ERP_Account_Classes.IF_ACCOUNT_005_Res IF_ACCOUNT_005(IF_ERP_Account_Classes.IF_ACCOUNT_005_Req parameters){
            interfaceId = 'IF-ACCOUNT-005';            
            String parametersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parameters) 
                                + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            
            System.debug('responseString : '+responseString);

            try {
                IF_ERP_Account_Classes.IF_ACCOUNT_005_Res response = 
                (IF_ERP_Account_Classes.IF_ACCOUNT_005_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Account_Classes.IF_ACCOUNT_005_Res.class);    
        
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_SP_LST');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }        
          
/** IF_ACCOUNT_014 
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_014
         * SFDC interface Id    : IF-ACCOUNT-014
         * AS-IS RFC            : Z_SD_MS_CU_CHK
         * New I/F              : ZCRM_SD_MS_CU_CHK
         * Description          : 잠재 고객 중복 조회 => 잠재 고객이 ERP상에 존재여부 확인
         * KeyValue             : X
         * NOT NULL             : X
     */            
    public IF_ERP_Account_Classes.IF_ACCOUNT_014_Res IF_ACCOUNT_014(IF_ERP_Account_Classes.IF_ACCOUNT_014_Req parameters){
        interfaceId = 'IF-ACCOUNT-014';            
        String parametersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parameters) 
                            + '}'; 

        interfaceUtil.isURLEncode = true;
        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            IF_ERP_Account_Classes.IF_ACCOUNT_014_Res response = 
            (IF_ERP_Account_Classes.IF_ACCOUNT_014_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Account_Classes.IF_ACCOUNT_014_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_CU_CHK');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }   

/** IF_ACCOUNT_017
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_017
         * SFDC interface Id    : IF-ACCOUNT-017
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_GET_DEALER_GRADE_LIST
         * Description          : 고객 마스터-대리점 등급 정보 조회 
         * KeyValue             : X
         * NOT NULL             : X
         * Batch                : X
         * 
         분석 
          유효 일자 범위를 기준으로 딜러 등급 데이터를 조회 
     */            
    public IF_ERP_Account_Classes.IF_ACCOUNT_017_Res IF_ACCOUNT_017(IF_ERP_Account_Classes.IF_ACCOUNT_017_Req parameters){
        interfaceId = 'IF-ACCOUNT-017';            
        String parametersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parameters) 
                            + '}'; 

        String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
        

        try {
            IF_ERP_Account_Classes.IF_ACCOUNT_017_Res response = 
            (IF_ERP_Account_Classes.IF_ACCOUNT_017_Res) JSON.deserialize(
                responseString, 
                IF_ERP_Account_Classes.IF_ACCOUNT_017_Res.class);    
    
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
                System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_GET_DEALER_GRADE_LIST');
                return response;        

        } catch (Exception e) {
            System.debug('ERROR MESSAGE : '+e.getMessage());
            System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
            return null;        
        }
    }   

/** IF_ACCOUNT_012
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_012
         * SFDC interface Id    : IF-ACCOUNT-012
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_MS_TC_CRE
         * Description          : 실고객 생성 - 신규 고객 마스터 정보 반환하여 ERP & CRM 데이터 동기화
         * KeyValue             : X
         * NOT NULL             : X
         * Batch                : X
     */            
        public IF_ERP_Account_Classes.IF_ACCOUNT_012_Res IF_ACCOUNT_012(IF_ERP_Account_Classes.IF_ACCOUNT_012_Req parameters){
            interfaceId = 'IF-ACCOUNT-012';            
            String parametersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parameters) 
                                + '}'; 

            interfaceUtil.isURLEncode = true;
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);

            try {
                IF_ERP_Account_Classes.IF_ACCOUNT_012_Res response = 
                (IF_ERP_Account_Classes.IF_ACCOUNT_012_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Account_Classes.IF_ACCOUNT_012_Res.class);    
        
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_MS_TC_CRE');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }        

/** IF_ACCOUNT_018
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_018
         * SFDC interface Id    : IF-ACCOUNT-018
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_CUSTOMER_SA_CRE				
         * Description          : Sales Area Data 생성
         * KeyValue             : X
         * NOT NULL             : X
         * Batch                : X
     */            
        public IF_ERP_Account_Classes.IF_ACCOUNT_018_Res IF_ACCOUNT_018(IF_ERP_Account_Classes.IF_ACCOUNT_018_Req parameters){
            interfaceId = 'IF-ACCOUNT-018';            
            String parametersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parameters) 
                                + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            

            try {
                IF_ERP_Account_Classes.IF_ACCOUNT_018_Res response = 
                (IF_ERP_Account_Classes.IF_ACCOUNT_018_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Account_Classes.IF_ACCOUNT_018_Res.class);    
        
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_CUSTOMER_SA_CRE');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }

/** IF_ACCOUNT_019
    */  
    /**
         * Apex Class           : IF_ERP_Account
         * Wrapper Class        : IF_ERP_Account_Classes
         * Wrapper Name         : IF_ACCOUNT_019
         * SFDC interface Id    : IF-ACCOUNT-019
         * AS-IS RFC            : 
         * New I/F              : ZCRM_SD_CUSTOMER_SA_CHG 				
         * Description          : 고객 마스터 Sales Area 수정
         * KeyValue             : X
         * NOT NULL             : X
         * Batch                : X
     */            
        public IF_ERP_Account_Classes.IF_ACCOUNT_019_Res IF_ACCOUNT_019(IF_ERP_Account_Classes.IF_ACCOUNT_019_Req parameters){
            interfaceId = 'IF-ACCOUNT-019';            
            String parametersString = 'InputParam=' 
                                + '{"Input":' 
                                + JSON.serialize(parameters) 
                                + '}'; 

            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
            

            try {
                IF_ERP_Account_Classes.IF_ACCOUNT_019_Res response = 
                (IF_ERP_Account_Classes.IF_ACCOUNT_019_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Account_Classes.IF_ACCOUNT_019_Res.class);    
        
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
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_CUSTOMER_SA_CHG');
                    return response;        

            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }
        }                


}