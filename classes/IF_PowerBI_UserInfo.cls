/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 06-11-2025
 * @last modified by  : JangJunHee
**/
public with sharing class IF_PowerBI_UserInfo implements Schedulable{
    public IF_PowerBI_UserInfo() {}

    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();

    public class powerBIException Extends Exception {}

    public class PowerBI_RequestDto {
        @AuraEnabled public String BRANCH_CD       {get;set;} 
        @AuraEnabled public String BRANCH_NM       {get;set;} 
        @AuraEnabled public String DEALER_CD       {get;set;} 
        @AuraEnabled public String DEALER_NM       {get;set;} 
        @AuraEnabled public String REG_USER_ID     {get;set;} 

        @AuraEnabled public String REG_USER_NM     {get;set;} 
        @AuraEnabled public String USER_TYPE       {get;set;}         
    }
    public class PowerBI_ResponseDto {
        public String E_MSGTY            {get;set;}   
        public String E_MSGTX            {get;set;}           
    }

    public void execute(SchedulableContext sc) {
        IF_PowerBI_UserInfo instance = new IF_PowerBI_UserInfo();
        instance.interfacePowerBI();
    }

    // di_doobiz.serv.main:DISD_SEND_INQUIRY_USER_INFO_TO_POWERBI_M
    public PowerBI_ResponseDto interfacePowerBI(){
        PowerBI_ResponseDto res = new PowerBI_ResponseDto();

        System.SavePoint sp = Database.setSavepoint();
        try {
            List<User> userList = [
                SELECT Id, SalesOffice__c, FM_SalesOffice__c, Account.CustomerCode__c, sendPowerBI__c,
                    Account.Name,  SalesDistrict__c, Profile.Name, isDirect__c, Name, EmployeeNumber, UserID__c 
                FROM  User 
                WHERE IsActive = true AND sendPowerBI__c = false
                    AND SalesDistrict__c = 'A1KR' 
                    AND (Profile.Name like '%대리점%' OR isDirect__c = true)
                ORDER BY isDirect__c ASC
            ];

            for (User user : userList) {
                user.sendPowerBI__c = true;
            }

            if (userList.size() > 0) update userList;

            List<PowerBI_RequestDto> reqList = new List<PowerBI_RequestDto>();
            for (User user : userList) reqList.add(mappingRequest(user));
            
            String interfaceId = 'IF-OPTY-036';

            String parametersString = 'InputParam='
                                        + '{"Input":'
                                        + JSON.serialize(reqList)
                                        + '}';
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, 'IF_PowerBI_UserInfo', false);
            res = (PowerBI_ResponseDto) JSON.deserialize(responseString, PowerBI_ResponseDto.class);
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Error Message ::: [' + e.getLineNumber() + ']' + e.getMessage());
        }
        return res;   
    }

    public PowerBI_RequestDto mappingRequest(User user){
        PowerBI_RequestDto req = new PowerBI_RequestDto();

        try {
            req.BRANCH_CD       = user.SalesOffice__c;
            req.BRANCH_NM       = user.FM_SalesOffice__c;
            req.DEALER_NM       = user.Account.Name;
            req.REG_USER_NM     = user.Name;
            req.USER_TYPE       = user.isDirect__c? '직영' : '대리점';
            
            if(user.isDirect__c){
                req.DEALER_CD   = user.UserID__c;
                req.REG_USER_ID = user.EmployeeNumber;
            }else{
                req.DEALER_CD   = user.FM_SalesOffice__c;
                req.REG_USER_ID = user.UserID__c;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw e;
        }
        return req;
    }

}