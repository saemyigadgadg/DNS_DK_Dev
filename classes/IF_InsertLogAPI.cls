/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-16-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-12-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
@RestResource(urlMapping='/Interface/InsertLog/*')

global with sharing class IF_InsertLogAPI {    
    global IF_InsertLogAPI() {    }

    @HttpPost
    global static Map<String,String> callOut(){
        try{
            
            
            RestRequest  request   = RestContext.request;
            RestResponse response  = RestContext.response;

            // GET Request QueryString
            String urlInfo      = request.requestURI;

            // Get Request Body
            Map<String, Object> wrapper = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            // String requestBodyApi = request.requestBody.toString();
            // String jsonString = String.unescapeJson(requestBodyApi);
            // Map<String, String> result = (Map<String, String>) JSON.deserialize(requestBodyApi, Map<String, String>.class);
            // System.debug(wrapper.get('requestBody'));
            String interfaceName      = wrapper.get('interfaceName') == null ? '' : String.valueOf(wrapper.get('interfaceName'));
            String interfaceClassesName = wrapper.get('interfaceClassesName') == null ? '' : String.valueOf(wrapper.get('interfaceClassesName'));
            String requestBody      = wrapper.get('requestBody') == null ? '' : String.valueOf(wrapper.get('requestBody'));            
            String requestTime      = wrapper.get('requestTime') == null ? '' : String.valueOf(wrapper.get('requestTime'));
            String responseBody     = wrapper.get('responseBody') == null ? '' : String.valueOf(wrapper.get('responseBody'));            
            String responseTime     = wrapper.get('responseTime') == null ? '' : String.valueOf(wrapper.get('responseTime'));

            InterfaceCommonLog.interfaceLog interfaceLog = new InterfaceCommonLog.interfaceLog(interfaceName, interfaceClassesName);
            interfaceLog.requestTime = String.isNotBlank(requestTime) ? Datetime.valueOf(requestTime) : null;
            interfaceLog.requestBody = requestBody;            
            interfaceLog.responseBody  = responseBody;
            interfaceLog.responseTime  = String.isNotBlank(responseTime) ? Datetime.valueOf(responseTime) : null;
            interfaceLog.status = 'SUCCESS';
            interfaceLog.inbound = true;            

            InterfaceCommonLog InterfaceCommonLog = new InterfaceCommonLog();
            InterfaceCommonLog.insertLog(new List<InterfaceCommonLog.interfaceLog>{interfaceLog});

            Map<String,String> returnMap = new Map<String,String>();
            returnMap.put('code','201');
            returnMap.put('message', 'SUCCESS');
            return returnMap;
        }catch (Exception e) {
            Map<String,String> returnMap = new Map<String,String>();
            returnMap.put('code','400');
            returnMap.put('message',e.getMessage());
            return returnMap;
        }        
        
    }


}