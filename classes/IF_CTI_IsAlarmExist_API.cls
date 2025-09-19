/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-17-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-04-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
@RestResource(urlMapping='/CTI/isAlarmExist')
global with sharing class IF_CTI_IsAlarmExist_API {

    @HttpGet
    global static Map<String,String> isAlarmExist(){
        // ** 1. GET Phone Number By Query String
        String phoneNumber = RestContext.request.params.get('phoneNum');
        
        System.debug('phoneNumber : ' + phoneNumber);

        String ctiUrl = System.Label.CTI_Url;
        String buttonUrl = ctiUrl + '?tel=' + phoneNumber;
        
        AlertManager__c alertManager = [SELECT Id FROM AlertManager__c WHERE Name = 'Call AS AlarmTalk' AND IsActive__c = true LIMIT 1];

        Map<String, String> elementMap = new Map<String, String>();
        elementMap.put('url', buttonUrl);

        UTIL_Alert.HistoryWrapper wrapper = new UTIL_Alert.HistoryWrapper();
        wrapper.alertID = alertManager.Id;
        wrapper.targetID = alertManager.Id;
        wrapper.alertType = 'AlarmTalk';
        wrapper.alertLanguage = 'ko';
        wrapper.elementMap = elementMap;
        wrapper.receiverforPhone.add(phoneNumber);
        
        IF_CTI_IsAlarmExist_API.RestResponseDto responseDto =
        new IF_CTI_IsAlarmExist_API.RestResponseDto(); 
        
        UTIL_Alert.runAlertEvent(new List<UTIL_Alert.HistoryWrapper>{wrapper});

        return responseDto.generateReturn();
    }


    global class RestResponseDto{
        
        public String code      {get;set;}
        public String message   {get;set;}
        public String detail    {get;set;}


        public RestResponseDto(){
            this.code    = '200';
            this.message = '200';
            this.detail  = 'true';
        }

        public Map<String,String> generateReturn(){
            Map<String,String> responseMap = new Map<String,String>();
            responseMap.put('code', this.code);
            responseMap.put('message', this.message);
            responseMap.put('detail', this.detail);

            return responseMap;
        }
    }    
}