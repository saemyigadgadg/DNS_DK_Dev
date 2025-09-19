/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-31-2024
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-31-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_CTI_DNIS_G002 {
    public IF_CTI_DNIS_G002(){}
    public static final String apexClassName = 'IF_CTI_DNIS_GOO2'; 

    private InterfaceCommonUtil utils = new InterfaceCommonUtil();  

    public String staticCallOut(){
        HttpRequest request = new HttpRequest();  
        request.setEndpoint('https://desk.matrixcloud.kr/matrixIpcc/G002/api/ext/center-schedules/now?dnis=16004522');
        request.setMethod('GET');
        request.setHeader('mt-api-token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NDUyLCJjZW50ZXJJZCI6NDUyLCJjZW50ZXJpZCI6ImRucyIsImNlbnRlck5hbWUiOiLrlJTsl5TshpTro6jshZjspogiLCJpYXQiOjE3MzMxMjE1ODIsImV4cCI6MjA0ODQ4MTU4Mn0.SE0o4fc9_KTfl-Wa1ySiRHrRZ1Kc8NlhH_SNPZjlZ74');
        request.setHeader('trace-id', '67382c2c-fec0-d36e-3b54-38ee2aaedf1b');

        Http http = new Http();
        HttpResponse response =  http.send(request);
        System.debug('endpoint ::: ' + request.getEndpoint());
        System.debug('method ::: ' + request.getMethod());
        System.debug('mt-api-token ::: ' + request.getHeader('mt-api-token'));
        System.debug('trace-id ::: ' + request.getHeader('trace-id'));

        System.debug('response body : '+response.getBody());

        return response.getBody();
    }

    public String callOut(RequestDto parameters){
        String interfaceId = 'IF-CTI-DNIS-G002';

        /**
         * Meta Data
         */
        IF_Authentication__mdt ifAuthMdt = [
            SELECT  Id, SecretKey__c
            FROM    IF_Authentication__mdt
            WHERE   System__c = 'CTI_DNIS_G002'
            LIMIT   1 ];

        /**
         * Request Data
         */
        // Map<String,String> requestMap = new Map<String,String>();  
        // requestMap.put('mt-api-token', ifAuthMdt.SecretKey__c);
        // requestMap.put('dnis',parameters.dnisId);
        // requestMap.put('trace-id',generateUUID());
        // utils.queryStringParams = requestMap;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://desk.matrixcloud.kr/matrixIpcc/G002/api/ext/center-schedules/now?dnis=' + parameters.dnisId);
        request.setMethod('GET');
        request.setHeader('mt-api-token', ifAuthMdt.SecretKey__c);
        request.setHeader('trace-id', generateUUID());

        Http http = new Http();
        HttpResponse response =  http.send(request);
        // String result = utils.sendHttp('', interfaceId, apexClassName, false);
        System.debug('response : '+ response.getBody());

        return response.getBody();
    }

    /**
     * 
     */
    public class RequestDto{
        public String dnisId {get;set;} 
    }

    /**
     * RESPONSE EXAMPLE
        "status": 200,
        "code": "SUCCESS",
        "message": "Request is successfully done",
        "data": {
            "code": "WORK",
            "name": "업무시간",
            "isWork": true,
            "scheduleType": "routine",
            "scheduleName": "업무시간",
            "cidState": null
        },
        "remark": null
     */
    public class ResponseDto{
        private Integer status;
        private String code;
        private String message;
        private Map<String,Object> data;
        private String remark;
    }
 
    private String generateUUID(){
        Blob randomBlob = Crypto.generateAesKey(128); // 128비트 랜덤 값 생성
        String uuid = EncodingUtil.convertToHex(randomBlob); // 16진수 문자열로 변환
        return uuid.substring(0, 8) + '-' +
               uuid.substring(8, 12) + '-' +
               uuid.substring(12, 16) + '-' +
               uuid.substring(16, 20) + '-' +
               uuid.substring(20, 32);
    }
}