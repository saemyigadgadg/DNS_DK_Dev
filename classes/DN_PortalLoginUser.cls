/**
 * @description       : (포탈) 부품 사용자 정보
 * @author            : daewook.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 07-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
**/
public with sharing class DN_PortalLoginUser {
    public DN_PortalLoginUser() {}

    // 로그인에 필요한 사용자 정보 조회
    @AuraEnabled
    public static DealerInfo GetUserInfo(String userId){
        system.debug('userId >> '+userId);
        try{
            User userInfo = 
            [
                SELECT  Id, Name, Profile.Name, MobilePhone, LanguageLocaleKey, Country__c, ContactId, ERP_Key__c, UserRole.Name,
                        SalesOrganization__c, Division__c, DistributionChannel__c, Account.ShippingAddress, 
                        AccountId, Account.Name, Account.CustomerCode__c, Account.Representative__c, Account.FM_Address__c, Account.Phone, 
                        Account.ShippingCity, Account.ShippingPostalCode, Account.ShippingStreet
                FROM User
                WHERE Id = :userId
                LIMIT 1
            ];
            system.debug('userInfo >> '+userInfo);
            String code = userInfo.Account.CustomerCode__c;

            system.debug('customerCode >> '+code);
            DealerCustomerShipTo__c dealerAddress = new DealerCustomerShipTo__c();
            if(userInfo.Profile.Name == 'DNS CS Parts_Partner' && !Test.isRunningTest()) {
                dealerAddress = [
                    SELECT Customer__r.Name, Customer__r.CustomerCode__c, Customer__r.RoadAddr__c, Customer__r.DetailInfo__c, Customer__r.Address__PostalCode__s
                    FROM DealerCustomerShipTo__c 
                    WHERE IsDealer__c = True
                    AND Customer__r.CustomerCode__c =: code
                    LIMIT 1
                ];
            }

            system.debug('dealerAddress >> '+dealerAddress);
            DealerInfo dealerInfo = new DealerInfo(userInfo, dealerAddress);
            return dealerInfo;

        }catch(Exception e){
            system.debug('messgae>> '+e.getmessage());
            system.debug('track>>  '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    } 

    public class DealerInfo {
        @AuraEnabled public String dealerName           {get; set;}
        @AuraEnabled public String dealerId             {get; set;}
        @AuraEnabled public String erpKey               {get; set;}
        @AuraEnabled public String userProfile          {get; set;}
        @AuraEnabled public String userRole             {get; set;}
        @AuraEnabled public String dealerCode           {get; set;}
        @AuraEnabled public String userMobilePhone      {get; set;}
        @AuraEnabled public String salesOrganization    {get; set;}
        @AuraEnabled public String division             {get; set;}
        @AuraEnabled public String distributionChannel  {get; set;}
        @AuraEnabled public String contactId            {get; set;}
        @AuraEnabled public String accountId            {get; set;}
        @AuraEnabled public String accountName          {get; set;}
        @AuraEnabled public String accountCEO           {get; set;}
        @AuraEnabled public String accountAddress       {get; set;}
        @AuraEnabled public String accountPhone         {get; set;}
        @AuraEnabled public String country              {get; set;}
        @AuraEnabled public String language             {get; set;}
        @AuraEnabled public Object ShippingAddress      {get; set;}

        @AuraEnabled public String city     {get; set;}
        @AuraEnabled public String street   {get; set;}
        @AuraEnabled public String zipCode  {get; set;}

        public DealerInfo(User ui, DealerCustomerShipTo__c da) {
            this.dealerName           = ui.Name;
            this.dealerId             = ui.Id;
            this.erpKey               = String.valueOf(ui.ERP_Key__c);
            this.userProfile          = ui.Profile.Name;
            this.userRole             = ui.UserRole != null ? ui.UserRole.Name : null;
            this.dealerCode           = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? '1057644'       : ui.Account.CustomerCode__c;
            this.userMobilePhone      = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? '000-0000-0000' : ui.MobilePhone;
            this.salesOrganization    = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? '1846'          : ui.SalesOrganization__c;
            this.division             = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? '40'            : ui.Division__c;
            this.distributionChannel  = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? '10'            : ui.DistributionChannel__c;
            this.contactId            = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? ''              : ui.ContactId;
            this.accountId            = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? ''              : ui.AccountId;
            this.accountAddress       = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? ''              : ui.Account.FM_Address__c;
            this.accountPhone         = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? ''              : ui.Account.Phone;
            this.accountName          = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? '어드민회사'     : ui.Account.Name;
            this.accountCEO           = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? '어드민대표'     : ui.Account.Representative__c;
            this.country              = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? 'KR'            : ui.Country__c;
            this.language             = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? 'ko'            : ui.LanguageLocaleKey;
            this.ShippingAddress      = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ?  new System.Address()  : ui.Account.ShippingAddress;

            this.city    = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? '서울 구로구 시흥대로 525' : da.Customer__r.RoadAddr__c;
            this.street  = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? '1층 DN 공작실'          : da.Customer__r.DetailInfo__c;
            this.zipCode = ui.Profile.Name == 'System Administrator' || ui.Profile.Name == '시스템 관리자' ? '08392'                 : da.Customer__r.Address__PostalCode__s;

        }
    
        public DealerInfo() {}
    }
}