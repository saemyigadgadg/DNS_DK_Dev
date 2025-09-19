/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-20-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-10-2024   deokjun.kim@sbtglobal.com   Initial Version
**/

public without sharing class InterfaceCommonUtil {
    // METADATA API VERSION
    private static final Double METADATA_API_VERSION = 61;        
    // interfaceCommonUtil instance
    public static InterfaceCommonUtil instance;
    // 예약어 list 불러오는 변수
    public List<String> reservedKeywords = getReservedKeywords();

    // insertLog flag값
    public Boolean isInsertLog = true;

    // util class 내부에서 변경됨 
    public Boolean isMulti = true;
    // null -> 공백 으로 바꿔줄 필요가 없는 경우에 true 로 변경
    public Boolean isFieldNotNull = false;
    // 특수 문자로 인해 URL Encode 가 필요한 경우 true
    public Boolean isURLEncode = false;
    // 인터페이스 호출 클래스 안에서 encoding 한 경우에 true
    public Boolean isCustomURLEncode = false;
    // 예약어가 포함된 경우에 true
    public Boolean isIF_Case   = false;

    // SAP interface 인 경우에 내부에서 true 로 변경됨
    public Boolean isSAPIF     = false;
    // log 를 저장하는 list 
    public List<InterfaceCommonLog.interfaceLog> saveLog = new List<InterfaceCommonLog.interfaceLog>();

    // test 용 분기처리 flag
    public Boolean isTest = false;

    // 외부에서 특수한 parameter 나 header 정보를 넣어 줄 때 쓰는 전역 변수
    public Map<String,String> queryStringParams {get;set;}
    public String queryStringParam {get;set;}

    public InterfaceCommonUtil(){}
 
/** Method : getInterfaceUtil()
 * 
 * utilclass instance를 single ton 으로 생성해 메모리 절약 및 서로 다른 호출 클래스 동시 호출 시 interface log 관리
    */
    public static InterfaceCommonUtil getInterfaceUtil(){
        if(instance == null) instance = new InterfaceCommonUtil();
        return instance;
    }

/** Class : InterfaceCommonLog
 * 
 * interfaceLog 를 위한 util class
    */
    private InterfaceCommonLog InterfaceCommonLog = new InterfaceCommonLog();

/** Class : InterfaceUtilException
 * 
 * interfaceLog__c Exception Class
    */
    public class InterfaceUtilException extends Exception {}

/** Method : getLanguageKey(String language)
 * 
 * 특정 인터페이스에서 language 코드가 달라서 일반적으로 쓰는 코드로 통일 시켜줌
 * ex) EN -> E, KR -> 3
    */
    public String getLanguageKey(String language){
        SAP_Language_Key__mdt SAPLK = [
            SELECT Value__c
            FROM SAP_Language_Key__mdt
            WHERE Key__c = :language
            LIMIT 1
        ];

        return SAPLK.Value__c;
    }

/** Method : getERPKey()
 * 
 * 특정 인터페이스에서 User 마다 Unique 한 key 가 필요해서 만든 임의 필드 ERP_Key__c를 가져오는 method
    */
    public String getERPKey(){
        Decimal erpKeyNumber    = 0;
        String  userId          = UserInfo.getUserId();

        List<User> userList = [
            SELECT Id, ERP_Key__c
            FROM User
            WHERE Id = :userId
        ];

        if (userList.size() > 0) erpKeyNumber = userList[0].ERP_Key__c;
        String erpKey = String.valueOf(erpKeyNumber);
        return erpKey.leftPad(12, '0');
    }

/** Method : getReservedKeywords(), convertInputJSON(String jsonString), convertOutputJSON(String jsonString)
 * 
 * APEX에서 사용 불가한 예약어 변수를 변환시켜주기 위한 예약어들을 가져오는 method
    */
    public List<String> getReservedKeywords(){
        return new List<String> {
            'ABSTRACT', 'ACTIVATE', 'AND', 'ANY', 'ARRAY', 'AS', 'ASC', 'AUTONOMOUS', 'BEGIN', 'BIGDECIMAL',
            'BLOB', 'BOOLEAN', 'BREAK', 'BULK', 'BY', 'BYTE', 'CASE', 'CAST', 'CATCH', 'CHAR', 'CLASS', 'COLLECT',
            'COMMIT', 'CONST', 'CONTINUE', 'CURRENCY', 'DATE', 'DATETIME', 'DECIMAL', 'DEFAULT', 'DELETE', 'DESC', 
            'DO', 'DOUBLE', 'ELSE', 'END', 'ENUM', 'EXCEPTION', 'EXIT', 'EXPORT', 'EXTENDS', 'FALSE', 'FINAL', 'FINALLY', 
            'FLOAT', 'FOR', 'FROM', 'GLOBAL', 'GOTO', 'GROUP', 'HAVING', 'HINT', 'IF', 'IMPLEMENTS', 'IMPORT', 'IN', 'INNER', 
            'INSERT', 'INSTANCEOF', 'INT', 'INTEGER', 'INTERFACE', 'INTO', 'JOIN', 'LIKE', 'LIMIT', 'LIST', 'LONG', 'LOOP', 
            'MAP', 'MERGE', 'NEW', 'NOT', 'NULL', 'NULLS', 'NUMBER', 'OBJECT', 'OF', 'ON', 'OR', 'OUTER', 'OVERRIDE', 
            'PACKAGE', 'PARALLEL', 'PRAGMA', 'PRIVATE', 'PROTECTED', 'PUBLIC', 'RETRIEVE','ROLLBACK', 'SELECT', 
            'SET', 'SHORT', 'SOBJECT', 'SORT', 'STATIC', 'STRING', 'SUPER', 'SWITCH', 'SYNCHRONIZED', 'SYSTEM', 'TESTMETHOD', 
            'THEN', 'THIS', 'THROW', 'TIME', 'TRANSACTION', 'TRIGGER', 'TRUE', 'TRY', 'UNDELETE', 'UPDATE', 'UPSERT', 'USING', 
            'VIRTUAL', 'VOID', 'WEBSERVICE', 'WHEN', 'WHERE', 'WHILE','RETURN'
        };
    }
    public String convertInputJSON(String jsonString){
        for (String reservedKeyword : this.reservedKeywords) {
            jsonString = jsonString.replaceAll('IF_' + reservedKeyword, reservedKeyword);
        }
        return jsonString;
    }
    public String convertOutputJSON(String jsonString){
        for (String reservedKeyword : this.reservedKeywords) {
            jsonString = jsonString.replaceAll('"' + reservedKeyword + '":', '"IF_' + reservedKeyword + '":');
        }
        return jsonString;
    }

/** Method : convertERPInputJSON(String jsonString)
 * 
 * APEX에서 사용 불가한 예약어 변수를 변환시켜주기 위한 예약어들을 가져오는 method
    */
    private String convertERPInputJSON(String jsonString){
        return convertInputJSON(jsonString.replaceAll(':null', ':""'));
    }
    public String encodeForSAP(String jsonString){
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

/** Class : MultiRequestDto
 * 
 * 여러건의 interface 를 List 로 한번에 처리하기 위한 request 보관용 Dto
    */    
    public class MultiRequestDto{
        public MultiRequestDto(HttpRequest request,String systemType){
            this.request = request;
            this.systemType = systemType;
        }
        public MultiRequestDto(){}
        public HttpRequest request {get;set;}
        public String systemType   {get;set;}
    }

/** Method : getBasicAutorization()
 * 
 * meta data 에 저장된 Id와 password 로 Auth header를 생성해줌 현재는 SAP 정보만 쓰고있음
    **/
    private String getBasicAutorization(String systemName){
        String username;
        String password;

        if (Test.isRunningTest()) {
            username = 'sfadmin';
            password = 'sf2024!@IF';
        } else {
            IF_Authentication__mdt autenticationInfo = [SELECT Id,  SystemId__c, Password__c FROM IF_Authentication__mdt WHERE System__c = :systemName AND IsActive__c = TRUE LIMIT 1];
            username = autenticationInfo.SystemId__c;
            password = autenticationInfo.Password__c;
        }

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        
        return authorizationHeader;
    }

/** Method : setHttpRequest(String interfaceId, String parameters)
 * 
 * interface Id 로 interface__c Object 를 query 해 필요한 정보를 HttpRequest 에 set
    **/
    public HttpRequest setHttpRequest(String interfaceId, String parameters){        
        try{
            Interface__c interfaceInfo = [SELECT Id, EndpointURL__c, HttpMethod__c, ContentType__c, Timeout__c, System__c FROM Interface__c WHERE Name = :interfaceId AND IsActive__c = TRUE][0];        
            String endpointURL  = interfaceInfo.EndpointURL__c;        
            String httpMethod   = interfaceInfo.HttpMethod__c;        
            String contentType  = interfaceInfo.ContentType__c;       
            Integer timeout     = Integer.valueOf(interfaceInfo.Timeout__c);       
            
            HttpRequest request = new HttpRequest();
            request.setMethod(httpMethod);
            request.setEndpoint(endpointURL);        
            request.setTimeout(timeout);
            if(!parameters.equals('') && parameters != null){
                request.setBody(parameters);
            }
            
            System.debug('interfaceInfo.System__c : ' + interfaceInfo.System__c);

            switch on interfaceInfo.System__c {
                when 'ERP' {
                    request.setHeader('Authorization', getBasicAutorization(interfaceInfo.System__c));                
                    request.setHeader('Content-Type', contentType);
                    if(!parameters.equals('')){
                        this.isSAPIF = true;
                        
                        if(!this.isFieldNotNull)    request.setBody(parameters.replaceAll(':null', ':""'));
                        if(this.isIF_Case)          request.setBody(convertInputJSON(request.getBody()));
                        
                        System.debug('requestBody ::: ' + request.getBody());
                        System.debug(':::::::::::::  REQUEST =>');
                        System.debug(':::::::::::::    {');
                        System.debug(':::::::::::::    '+request.getBody());
                        System.debug(':::::::::::::    } ');

                        if(this.isURLEncode)        request.setBody(encodeForSAP(request.getBody()));
                    }
                }
                when 'NTS' {
                    request.setHeader('Content-Type', contentType);
                    request.setEndpoint(request.getEndpoint()+ this.queryStringParam);
                }
                // when 'Naver_Address'{
                when 'Naver'{
                    request.setHeader('X-Naver-Client-Id'    , queryStringParams.get('X-Naver-Client-Id') );                
                    request.setHeader('X-Naver-Client-Secret', queryStringParams.get('X-Naver-Client-Secret'));
                    request.setEndpoint(request.getEndpoint()+queryStringParam+queryStringParams.get('Add-Others'));
                }
                // when 'MOIS_Address'{
                when 'MOIS'{
                    request.setEndpoint(request.getEndpoint()+queryStringParam);
                }
                // when 'Sweet_Tracker_SendMessage_Op'{
                when 'SWEET TRAKER'{
                    request.setHeader('Content-Type',contentType);
                    request.setHeader('userId',queryStringParams.get('userId'));
                    request.setEndpoint(request.getEndpoint()+'/'+queryStringParams.get('profileKey')+'/'+queryStringParams.get('apiNm'));
                }

                // CTI -> find schedule
                when 'CTI_DNIS_G002'{
                    request.setHeader('mt-api-token',queryStringParams.get('mt-api-token'));
                    request.setHeader('trace-id',queryStringParams.get('trace-id'));
                    request.setEndpoint(request.getEndpoint()+queryStringParams.get('dnis'));
                    System.debug(' mt-api-token :: '+request.getHeader('mt-api-token'));
                    System.debug(' trace-id :: '+request.getHeader('trace-id'));
                }
            }
            return request;
        }
        catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
            throw new InterfaceUtilException('Please check the \'' + interfaceId +'\' in the Interface__c object.');            
        }        
    }

/** Method : getReponseJsonString(String bodyString)
 * 
 * response 가 html 첫번째 td 안에 담겨져 오기 때문에 꺼내서 unescapeHtml4() 사용
    **/
    private String getReponseJsonString(String bodyString){        
        return bodyString.substringAfter('<TD>').substringBefore('</TD>').unescapeHtml4();
    }

/** Method : sendHttp(String parameters, String interfaceId, String apexClassName, Boolean isResponseXml)
 *  
 * parameter 및 interface Id 등의 정보를 넣어주고 http 통신 후 response를 return 해줌
    **/
    public String sendHttp(String parameters, String interfaceId, String apexClassName, Boolean isResponseXml){
        String result = '';
        InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog(interfaceId, apexClassName);
        
        HttpRequest request = setHttpRequest(interfaceId, parameters);
        interfaceLog.requestBody = this.isSAPIF && (this.isCustomURLEncode || this.isURLEncode) ? EncodingUtil.urlDecode(request.getBody(), 'UTF-8'): request.getBody();
        interfaceLog.requestTime = System.now();

        try{
            Http http = new Http();
            HttpResponse response   = http.send(request);
            String bodyString       = response.getBody();
            String jsonString       = isResponseXml == TRUE ? getReponseJsonString(bodyString) : bodyString;
            if(this.isIF_Case)  jsonString  = convertOutputJSON(jsonString);
            System.debug('response ::: ' + jsonString);
            System.debug('response ::: ' + request.getEndpoint());
            System.debug('response ::: ' + request.getMethod());
            result                  = Test.isRunningTest()? bodyString : jsonString;

            interfaceLog.responseBody  = jsonString;
            interfaceLog.responseTime  = System.now();     
            
            this.saveLog.add(interfaceLog);
            if(this.isInsertLog) saveInterfaceLog();
            else isInsertLog = true;
        }
        catch(Exception e){
            interfaceLog.responseTime  = System.now();
            interfaceLog.errorText = new List<String>();
            interfaceLog.errorText.add(e.getLineNumber() + e.getMessage());   

            this.saveLog.add(interfaceLog);
            saveInterfaceLog();
        }   
        return result;
    }

/** sendHttp(List<String> parametersList, String interfaceId, String apexClassName, Boolean isResponseXml)
 * 
 *  기존 sendHttp 를 Overloading 해서 parameter를 List로 받아 인터페이스를 여러번 태우는 Method
    */
    public List<String> sendHttp(List<String> parametersList, String interfaceId, String apexClassName, Boolean isResponseXml){
        List<String> result = new List<String>();
        // ** Declare Interface Log
        InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog(interfaceId, apexClassName);
        interfaceLog.requestTime  = System.now();
        interfaceLog.requestBody  = '';
        interfaceLog.responseBody = '';

        // ** Declare HttpRequest 
        MultiRequestDto multiReqDto = setHttpRequest(interfaceId);
            HttpRequest request     = multiReqDto.request;
            String      systemType  = multiReqDto.systemType;
            Integer    requestCount = parametersList.size(); // ** request Count

        try{
            // ** Interate
            for(Integer index = 0; index<requestCount; index++){

                // ** Set Request Body
                String currentRequestBody = parametersList.get(index);

                if( systemType.equals('ERP') &&!currentRequestBody.equals('') ){
                    if(!this.isFieldNotNull) currentRequestBody = convertERPInputJSON(currentRequestBody);

                    if(this.isURLEncode) {
                        currentRequestBody = encodeForSAP(currentRequestBody);
                        interfaceLog.requestBody += EncodingUtil.urlDecode(currentRequestBody+'\n', 'UTF-8');
                    }else{
                        interfaceLog.requestBody += currentRequestBody+'\n';
                    }
                }
                request.setBody(currentRequestBody);
                
                Http http = new Http();
                HttpResponse response   = http.send(request);     
                String bodyString       = response.getBody();
                String jsonString       = isResponseXml == TRUE ? getReponseJsonString(bodyString) : bodyString;
                jsonString              = convertOutputJSON(jsonString);
                result.add(jsonString);

                interfaceLog.responseBody += jsonString+'\n';
            }
            // 변경된 로직
            this.saveLog.add(interfaceLog);
            if(isInsertLog) saveInterfaceLog();  
            else isInsertLog = true;
        }
        catch(Exception e){
            interfaceLog.errorText = new List<String>();
            interfaceLog.errorText.add(e.getLineNumber() + e.getMessage()); 

            this.saveLog.add(interfaceLog);
            saveInterfaceLog();  
        }

        interfaceLog.responseTime = System.now();
        
        return result;
    }

/** sendHttpCaseI_VBELN(List<String> parametersList, String interfaceId, String apexClassName, Boolean isResponseXml)
 *
 * I_VBELN 을 response에 넣어주기 위해 sendHttp 를 Overloading 해서 만든 Method
    */
    public List<String> sendHttpCaseI_VBELN(List<String> parametersList, String interfaceId, String apexClassName, Boolean isResponseXml){
        List<String> result = new List<String>();
        // ** Declare Interface Log
        InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog(interfaceId, apexClassName);
        interfaceLog.requestTime  = System.now();
        interfaceLog.requestBody  = '';
        interfaceLog.responseBody = '';

        // ** Declare HttpRequest 
        MultiRequestDto multiReqDto = setHttpRequest(interfaceId);
            HttpRequest request     = multiReqDto.request;
            String      systemType  = multiReqDto.systemType;
            Integer    requestCount = parametersList.size(); // ** request Count

        try{
            // ** Interate
            for(Integer index = 0; index<requestCount; index++){

                // ** Set Request Body 
                String currentRequestBody = parametersList.get(index);
                
                if(!this.isFieldNotNull) currentRequestBody = convertERPInputJSON(currentRequestBody);
                
                if(this.isURLEncode) {
                    currentRequestBody = encodeForSAP(currentRequestBody);
                    System.debug('currentRequestBody : ' + currentRequestBody);
                    interfaceLog.requestBody += EncodingUtil.urlDecode(currentRequestBody+'\n', 'UTF-8');
                }else{
                    interfaceLog.requestBody += currentRequestBody+'\n';
                }
                request.setBody(currentRequestBody);

                System.debug('request ::: ' + request);
                
                Http http = new Http();
                HttpResponse response   = http.send(request);     
                String bodyString       = response.getBody();
                String jsonString       = isResponseXml == TRUE ? getReponseJsonString(bodyString) : bodyString;
                jsonString              = convertOutputJSON(jsonString);

                System.debug('jsonString ::: ' + jsonString);

                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
                Map<String, Object> requestMap  = (Map<String, Object>) JSON.deserializeUntyped(parametersList.get(index).remove('InputParam='));
                
                Map<String, Object> requestInput = (Map<String, Object>) requestMap.get('Input');
                responseMap.put('I_VBELN', String.valueOf(requestInput.get('I_VBELN')));

                result.add(JSON.serialize(responseMap));

                interfaceLog.responseBody += jsonString+'\n';
            }
            // 변경된 로직
            this.saveLog.add(interfaceLog);
            if(isInsertLog) saveInterfaceLog();  
            else isInsertLog = true;
        }
        catch(Exception e){
            interfaceLog.errorText = new List<String>();
            interfaceLog.errorText.add(e.getLineNumber() + e.getMessage()); 

            this.saveLog.add(interfaceLog);
            saveInterfaceLog();  
        }

        interfaceLog.responseTime = System.now();

        // 기존 로직
        // if(isInsertLog) InterfaceCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{interfaceLog});

        return result;
    }
    
/** Method : setHttpRequest(String interfaceId)
 * 
 *  interface Id 를 Key 로 interface__c 를 불러와 필요한 정보를 채워준다
    */
    public MultiRequestDto setHttpRequest(String interfaceId){        
        try{
            Interface__c interfaceInfo = [SELECT Id, EndpointURL__c, HttpMethod__c, ContentType__c, Timeout__c, System__c FROM Interface__c WHERE Name = :interfaceId AND IsActive__c = TRUE][0];        
            String endpointURL  = interfaceInfo.EndpointURL__c;
            String httpMethod   = interfaceInfo.HttpMethod__c;
            String contentType  = interfaceInfo.ContentType__c;
            Integer timeout     = Integer.valueOf(interfaceInfo.Timeout__c);       
            
            HttpRequest request = new HttpRequest();
            request.setMethod(httpMethod);
            request.setEndpoint(endpointURL);        
            request.setTimeout(timeout);

            switch on interfaceInfo.System__c {
                when 'ERP' {
                    request.setHeader('Authorization', getBasicAutorization(interfaceInfo.System__c));                
                    request.setHeader('Content-Type', contentType);
                }
                when 'NTS' {
                    request.setHeader('Content-Type', contentType);
                    request.setEndpoint(request.getEndpoint()+ this.queryStringParam);
                }
                when 'Naver'{
                    request.setHeader('X-Naver-Client-Id'    , queryStringParams.get('X-Naver-Client-Id') );                
                    request.setHeader('X-Naver-Client-Secret', queryStringParams.get('X-Naver-Client-Secret'));
                    request.setEndpoint(request.getEndpoint()+queryStringParam+queryStringParams.get('Add-Others'));
                }
                when 'MOIS'{
                    request.setEndpoint(request.getEndpoint()+queryStringParam);
                }
                when 'SWEET TRAKER'{
                    request.setHeader('Content-Type',contentType);
                    request.setHeader('userId',queryStringParams.get('userId'));
                    request.setEndpoint(request.getEndpoint()+'/'+queryStringParams.get('profileKey')+'/'+queryStringParams.get('apiNm'));
                }
                when 'CTI_DNIS_G002'{
                    request.setHeader('mt-api-token',queryStringParams.get('mt-api-token'));
                    request.setHeader('trace-id',queryStringParams.get('trace-id'));
                    request.setEndpoint(request.getEndpoint()+queryStringParams.get('dnis'));
                }
            }
            MultiRequestDto multiRequestDto = new MultiRequestDto();
            multiRequestDto.request = request;  
            multiRequestDto.systemType = interfaceInfo.System__c;
            
            return MultiRequestDto;
        }
        catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
            throw new InterfaceUtilException('Please check the \'' + interfaceId +'\' in the Interface__c object.');            
        }        
    }    


    public void saveInterfaceLog() {
        InterfaceCommonLog.insertLog(this.saveLog);
        instance = new InterfaceCommonUtil();       
    }

    /**
    * @description 
    * @author deokjun.kim@sbtglobal.com | 06-20-2024 
    * @param String parameters 
    * @return String 
    **/
    public String getParmetersString(Object parameters){
        String parmetersString = 'InputParam=' 
                            + '{"Input":' 
                            + JSON.serialize(parameters) 
                            + '}'; 

        return parmetersString;
    }

    /**
    * @description 
    * @author deokjun.kim@sbtglobal.com | 06-20-2024 
    * @param String responseString 
    * @return String 
    **/
    public String getResponseString(String responseString){
        return responseString.substringAfter('"Output":').substringBeforeLast('}');  
    }

/**  
 * @TestCode
    */
    public class MockHttpResponseGenerator_Address implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            String mockResponse = '{' +
                '"results": {' +
                    '"common": {"totalCount": "5"},' +
                    '"juso": [' +
                        '{"roadAddr": "서울특별시 강남구 대왕판교로 10길", "zipNo": "12345"},' +
                        '{"roadAddr": "서울특별시 강남구 대왕판교로 11길", "zipNo": "12346"}' +
                    ']' +
                '}' +
            '}';
            
            res.setBody(mockResponse);
            return res;
        }
    }
    
    /**
    * @TestCode
    **/
    public static void setInterface(String interfaceId, String interfaceClassName){
        Interface__c ifObj      = new Interface__c();
        
        ifObj.Name              = interfaceId;
        ifObj.IsActive__c       = true;
        ifObj.HttpMethod__c     = 'POST';
        ifObj.EndpointURL__c    = 'http://temp';
        ifObj.System__c         = 'ERP';
        ifObj.ContentType__c    = 'application/x-www-form-urlencoded';
        ifObj.Timeout__c        = 120000;

        insert ifObj;

        interfaceClasses__c ifCls   = new interfaceClasses__c();

        ifCls.Name              = interfaceClassName;
        ifCls.Interface__c      = ifObj.Id;

        insert ifCls;

        String mockClass = interfaceClassName + '_Test.' + interfaceId.replace('-', '_') + '_HttpMock';

        System.debug('mockClass ::: ' + mockClass);

        Test.setMock(HttpCalloutMock.class, Type.forName(mockClass).newInstance());
    }

    /**
    * @TestCode
    **/
    public static void setInterface(String interfaceId, String interfaceClassName, String mockName){
        Interface__c ifObj      = new Interface__c();
        
        ifObj.Name              = interfaceId;
        ifObj.IsActive__c       = true;
        ifObj.HttpMethod__c     = 'POST';
        ifObj.EndpointURL__c    = 'http://temp';
        ifObj.System__c         = 'ERP';
        ifObj.ContentType__c    = 'application/x-www-form-urlencoded';
        ifObj.Timeout__c        = 120000;

        insert ifObj;

        interfaceClasses__c ifCls   = new interfaceClasses__c();

        ifCls.Name              = interfaceClassName;
        ifCls.Interface__c      = ifObj.Id;

        insert ifCls;

        String mockClass = interfaceClassName + '_Test.' + interfaceId.replace('-', '_') + '_' + mockName + '_HttpMock';

        System.debug('mockClass ::: ' + mockClass);

        Test.setMock(HttpCalloutMock.class, Type.forName(mockClass).newInstance());
    }

}