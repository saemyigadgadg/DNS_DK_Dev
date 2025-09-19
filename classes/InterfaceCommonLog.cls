/**
 * @description       : 
 * @author            : deokjun.kim@sobetec.com
 * @group             : 
 * @last modified on  : 06-16-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
**/
public without sharing class InterfaceCommonLog {
    public class interfaceLogException extends Exception {}

    public class interfaceLog {
        @AuraEnabled public Interface__c            interfaceId         {get;set;}
        @AuraEnabled public interfaceClasses__c     interfaceClasses    {get;set;}
        @AuraEnabled public List<String>            errorText           {get;set;}
        @AuraEnabled public Integer                 exceutionTime       {get;set;}
        @AuraEnabled public String                  requestBody         {get;set;}
        @AuraEnabled public String                  requestHeader       {get;set;}
        @AuraEnabled public Integer                 requestSize         {get;set;}
        @AuraEnabled public Datetime                requestTime         {get;set;}        
        @AuraEnabled public String                  responseBody        {get;set;}
        @AuraEnabled public String                  responseHeader      {get;set;}
        @AuraEnabled public Integer                 responseSize        {get;set;}        
        @AuraEnabled public Datetime                responseTime        {get;set;}
        @AuraEnabled public String                  apexJobId           {get;set;}
        @AuraEnabled public String                  status              {get;set;}
        @AuraEnabled public Datetime                batchStartTime      {get;set;}
        @AuraEnabled public Datetime                batchEndTime        {get;set;}
        @AuraEnabled public String                  logText             {get;set;}
        @AuraEnabled public Boolean                 inbound             {get;set;}

        public interfaceLog(){}

        public interfaceLog(String interfaceName, String interfaceClassesName){
            List<Interface__c> interfaceList = [SELECT Id FROM Interface__c WHERE Name = :interfaceName LIMIT 1];
            System.debug('interfaceName : ' + interfaceName);
            System.debug('interfaceList : ' + interfaceList);
            if(interfaceList.size() > 0){
                this.interfaceId = interfaceList[0];
            }
            else{
                throw new interfaceLogException('Record does not exist. (Interface__c.Name : ' + interfaceName + ') Create this record !!!');
            }

            List<InterfaceClasses__c> interfaceClassesList = [SELECT Id FROM InterfaceClasses__c WHERE Name = :interfaceClassesName LIMIT 1];
            
            if(interfaceClassesList.size() > 0){
                this.interfaceClasses = interfaceClassesList[0];
            }
            else{
                throw new interfaceLogException('Record does not exist. (interfaceClasses__c.Name : ' + interfaceClassesName + ') Create this record !!!');
            }            

            this.status = 'SUCCESS';
        }

        public InterfaceLog__c convertLog(){
            InterfaceLog__c interfaceLog = new InterfaceLog__c();
            interfaceLog.Interface__c          = this.interfaceId != null ? this.interfaceId.Id : null;
            interfaceLog.interfaceClasses__c     = this.interfaceClasses != null ? this.interfaceClasses.Id : null;            
            interfaceLog.ErrorText__c          = longTextSubString(JSON.serialize(this.errorText), 131072);
            if(interfaceLog.ErrorText__c != null && interfaceLog.ErrorText__c != 'null' && interfaceLog.ErrorText__c != '') this.status = 'ERROR';
            else interfaceLog.ErrorText__c = null;
            // interfaceLog.ExceptionTime__c      = this.exceutionTime;
            interfaceLog.RequestBody__c        = longTextSubString(this.requestBody, 131072);
            interfaceLog.RequestHeader__c      = longTextSubString(this.requestHeader, 32768);
            interfaceLog.RequestSize__c        = this.requestSize;
            interfaceLog.RequestTime__c        = this.requestTime;
            interfaceLog.ResponseBody__c       = longTextSubString(this.responseBody, 131072);
            interfaceLog.ResponseHeader__c     = longTextSubString(this.responseHeader, 32768);
            interfaceLog.ResponseSize__c       = this.responseSize;            
            interfaceLog.ResponseTime__c       = this.responseTime;            
            interfaceLog.Status__c             = this.status;
            interfaceLog.Inbound__c            = this.inbound == null ? false : this.inbound;
            
            return interfaceLog;
        }

        private String longTextSubString(String value, Integer size){            
            if(value == null) return '';
            return value.length() > size ? value.subString(0, size) : value;
        }
    }

    public void insertLog(List<InterfaceCommonLog.interfaceLog> logList){
        System.debug('inestLog!!!');
        List<InterfaceLog__c> insertLogList = new List<InterfaceLog__c>();

        System.debug('logList ::: ' + JSON.serialize(logList));

        // apexJobMap
        List<String> apexJobIdList = new List<String>();

        for(InterfaceCommonLog.interfaceLog log : logList){
            apexJobIdList.add(log.apexJobId);
        }
        
        Map<Id, AsyncApexJob> apexJobMap = new Map<Id, AsyncApexJob>();        
    if(!apexJobIdList.isEmpty()) apexJobMap = new Map<Id, AsyncApexJob>([SELECT Id, ExtendedStatus FROM AsyncApexJob WHERE Id IN:apexJobIdList AND ExtendedStatus != null]);
        System.debug('apexJobMap : ' + apexJobMap);

        for(InterfaceCommonLog.interfaceLog log : logList){
            InterfaceLog__c insertLog = log.convertLog();
            if(apexJobMap.get(log.apexJobId) != null){
                insertLog.ErrorText__c = log.longTextSubString(String.valueOf(apexJobMap.get(log.apexJobId).ExtendedStatus + insertLog.ErrorText__c), 131072);
            }            
            insertLogList.add(insertLog);
        }

        
        if(insertLogList.size() > 0) insert insertLogList;
    }


    
}