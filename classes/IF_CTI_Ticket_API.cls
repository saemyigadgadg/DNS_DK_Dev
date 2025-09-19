/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-06-17
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-04-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
@RestResource(urlMapping='/CTI/getPCPNumberByCSNumber')
global with sharing class IF_CTI_Ticket_API {

    /**
     *  phone 번호 null 처리 
     *  Contact 없으면 error
     */
    @HttpGet
    global static  Map<String,String> getPCPNumberByCSNumber(){
        // ** 1. GET Phone Number By Query String
        String phoneNumber = RestContext.request.params.get('phoneNumber');
        
        RestReturnDto resturnDto = new RestReturnDto(); 

        if( phoneNumber == null ){
            resturnDto.code    = '400';
            resturnDto.message = 'phone number is empty';
            resturnDto.detail  = 'Query String is null';
            return resturnDto.returnGenerator();
        }


        Contact cont;
        try {
            cont  = [SELECT Id FROM Contact WHERE phone=:phoneNumber OR MobilePhone =:phoneNumber LIMIT 1];
            if( cont == null ) {
                throw new IF_CTI_Ticket_API.CTICustomException('NOT FOUND CONTACT');
            }

        } catch (Exception e) {
            // resturnDto.serverException('Not Found Contact By Number-> '+e.getMessage()+' : '+e.getLineNumber());
            resturnDto.serverException('');
            return resturnDto.returnGenerator();
        }

        Id contactId = cont.Id;

        Case pcpCase;
        try {
            pcpCase = [ 
                SELECT Id, AssetId, Asset.MainWC__c, Asset.MainWC__r.phone__c, Asset.InstEngineer__c, Asset.InstEngineer__r.PhoneNumber__c 
                         FROM CASE 
                         WHERE Requester__c =: contactId 
                         ORDER BY CreatedDate DESC
                         Limit 1];
            if( pcpCase == null ) {
                throw new IF_CTI_Ticket_API.CTICustomException('NOT FOUND CONTACT');
            }

        } catch (Exception e) {
            // resturnDto.serverException('Not Found Case -> '+e.getMessage()+' : '+e.getLineNumber());
            resturnDto.serverException('');
            return resturnDto.returnGenerator();
        }

        if( pcpCase.AssetId == null ){
            resturnDto.code    = '400';
            resturnDto.message = 'not found Asset info';
            System.debug('the Asset is not assign');
        }
        else if( pcpCase.asset.InstEngineer__c == null ){
            resturnDto.code    = '400';
            resturnDto.message = 'not found Install Engineer info';
            System.debug('the ServiceTerritory is not assign');
        }
        else if( pcpCase.asset.InstEngineer__r.PhoneNumber__c  == null  ){
            resturnDto.code    = '400';
            resturnDto.message = 'not exist this ServiceTerritory Phone number';
            System.debug('not exist this ServiceTerritory Phone number');
        }
        else{
            resturnDto.setPCPNumber(pcpCase.asset.InstEngineer__r.PhoneNumber__c );
            System.debug('number is : '+ pcpCase.asset.InstEngineer__r.PhoneNumber__c);
        }

        return resturnDto.returnGenerator();
    }

    

    global class RestReturnDto{

        public Map<String,String> returnGenerator(){
            Map<String,String> returnMap = new Map<String,String>();
            returnMap.put('code', this.code);
            returnMap.put('message', this.message);
            returnMap.put(this.code.equals('200') ? 'phoneNumber':'errorMessage', this.detail);
            return returnMap; 
        }

        public RestReturnDto(){
            this.code    = '200';
            this.message = 'SUCCESS';
        }

        public void setPCPNumber(String pcpPhoneNum){
            this.detail = pcpPhoneNum;
        }

        public RestReturnDto serverException(String exceptionMsg){
            this.code    = '500';
            this.message = 'Service Exception';
            this.detail  = exceptionMsg; 
            return this;
        }

        
        public String code    {get;set;}
        public String message {get;set;}
        public String detail  {get;set;}

    }

    global enum CTI_STATUS {
        NOT_EXIST
    }


    global class CTICustomException extends Exception{

    }
}