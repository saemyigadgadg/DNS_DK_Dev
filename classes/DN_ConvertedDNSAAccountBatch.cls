/**
 * @author            : Yu-Hyun Park
 * @description       : 
 *  - Customer Code가 없는 DNSA Account를 IF_ACCOUNT_015을 통해 CustomerCode를 받아옴
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-05   yuhyun.park@sbtglobal.com   Initial Version
**/
global with sharing class DN_ConvertedDNSAAccountBatch implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {

    private static final Id   accDnsaRT     = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT  Id, 
                    CustomerCode__c,
                    Representative__c,
                    Name, 
                    AccountNameEnglish__c,

                    SearchTerm__c,
                    CountryLookup__c,
                    RegionLookup__c,
                    ShippingPostalCode,
                    ShippingStreet,

                    ShippingCity,
                    Phone,
                    Mobile__c,
                    Fax,
                    Website,

                    MainCategory__c,
                    SubCategory__c,
                    IsTooling__c,
                    TypeOfBusiness__c,
                    TypeOfIndustry__c,

                    SalesOffice__c,
                    SalesDistrict__c,
                    SalesOrganization__c,
                    DistributionChannel__c,
                    Division__c,

                    Owner.Account.CustomerCode__c,
                    Owner.CustomerCode__c,
                    Language__c,
                    BusinessNumber__c,
                    Email__c,

                    RecordTypeId,
                    CurrencyIsoCode,
                    OwnerId,
                    Owner.Plant__c,
                    Owner.Name

            FROM    Account
            WHERE   CustomerCode__c = null 
            AND     RecordTypeId = :accDnsaRT
        ]);
    }


    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('scope :: ' + scope);

        if(!scope.isEmpty()){

            Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
            TriggerHandler.bypassedHandlers = bypassSet;

            Account acc = (Account) scope.get(0);

            // Interface 전송할 FieldMap
            Map<String, Object> fieldMap = new Map<String, Object>();

            fieldMap.put('CurrencyIsoCode'          , acc.CurrencyIsoCode);
            fieldMap.put('BusinessNumber__c'        , acc.BusinessNumber__c);
            fieldMap.put('Name'                     , acc.Name);
            fieldMap.put('Email__c'                 , acc.Email__c);
            fieldMap.put('CountryLookup__c'         , acc.CountryLookup__c);

            fieldMap.put('RegionLookup__c'          , acc.RegionLookup__c);
            fieldMap.put('ShippingPostalCode'       , acc.ShippingPostalCode);
            fieldMap.put('ShippingStreet'           , acc.ShippingStreet);
            fieldMap.put('ShippingCity'             , acc.ShippingCity);
            fieldMap.put('Phone'                    , acc.Phone);

            fieldMap.put('Representative__c'        , acc.Representative__c);
            fieldMap.put('OwnerId'                  , acc.OwnerId);
            fieldMap.put('SalesOrganization__c'     , acc.SalesOrganization__c);
            fieldMap.put('DistributionChannel__c'   , acc.DistributionChannel__c);
            fieldMap.put('Division__c'              , acc.Division__c);
            fieldMap.put('SalesDistrict__c'         , acc.SalesDistrict__c);
            
            fieldMap.put('Owner.Name'               , acc.Owner.Name);
            fieldMap.put('Owner.Plant__c'           , acc.Owner.Plant__c);
            fieldMap.put('Owner.Account.CustomerCode__c'      , acc.Owner.Account.CustomerCode__c);
            fieldMap.put('Owner.CustomerCode__c'              , acc.Owner.CustomerCode__c);

            IF_ERP_Account_Classes.IF_ACCOUNT_015_Res erpResponse = interfaceAccount015(fieldMap);

            System.debug('erpResponse ::: ' + erpResponse);

            if (erpResponse.O_RETURN.TYPE == 'S') { // ERP 응답 성공 시 진행
                System.debug('erpResponse.O_PERSON :: ' + erpResponse.O_PERSON);
                acc.CustomerCode__c = erpResponse.O_PERSON;
            }
            update acc;

        }
    }

    global void finish(Database.BatchableContext bc) {

        System.debug('Batch processing completed.');
        DateTime nextRunTime = System.now().addMinutes(10);
        String cronExp = generateCronExpression(nextRunTime);
        // 고유한 잡 이름 생성: 현재 시각의 타임스탬프를 접미사로 추가
        String jobName = 'DN_ConvertedDNSAAccountBatch_next_' + String.valueOf(nextRunTime.getTime());
        System.debug('Next run scheduled at: ' + nextRunTime + ', jobName: ' + jobName);
        System.schedule(jobName, cronExp, new DN_ConvertedDNSAAccountBatch());
    }


    global void execute(SchedulableContext sc) {
        // 배치 클래스 실행
        DN_ConvertedDNSAAccountBatch batch = new DN_ConvertedDNSAAccountBatch();
        Database.executeBatch(batch, 1);
    }

    public static void scheduleBatchJob() {
        DateTime nextRunTime = System.now().addMinutes(10);
        String cronExp = generateCronExpression(nextRunTime);
        System.schedule('DN_ConvertedDNSAAccountBatch', cronExp, new DN_ConvertedDNSAAccountBatch());
        System.debug('Initial schedule set for: ' + nextRunTime);
    }

    private static String generateCronExpression(DateTime dt) {
        String sec   = String.valueOf(dt.second());
        String min   = String.valueOf(dt.minute());
        String hour  = String.valueOf(dt.hour());
        String day   = String.valueOf(dt.day());
        String month = String.valueOf(dt.month());
        String year  = String.valueOf(dt.year());
        return sec + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
    }


    private static IF_ERP_Account_Classes.IF_ACCOUNT_015_Res interfaceAccount015(Map<String, Object> fieldMap) {

        IF_ERP_Account_Classes.IF_ACCOUNT_015_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_015_Req();

        erpParameters.I_CHECK               = 'X'; // 중복체크 'X' 하드코딩 
        erpParameters.I_CUSTOMER_TYPE       = 'S'; // 'S' - ShipTo (DNSA Customer)
        erpParameters.I_BZIRK               = (String) fieldMap.get('SalesDistrict__c');

        erpParameters.I_WAERS               = (String) fieldMap.get('CurrencyIsoCode');  // 예제 값 (통화 단위)
    
        // I_BASIC
        erpParameters.I_BASIC               = new IF_ERP_Account_Classes.IF_ACCOUNT_015_Req_I_BASIC();
        erpParameters.I_BASIC.STCD1         = (String) fieldMap.get('BusinessNumber__c'); 
        erpParameters.I_BASIC.NAME1         = (String) fieldMap.get('Name');
        erpParameters.I_BASIC.SMTP_ADDR     = (String) fieldMap.get('Email__c');
        
        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE Id = :(String) fieldMap.get('CountryLookup__c') LIMIT 1];
        Region__c region = null;
        if(fieldMap.get('RegionLookup__c') != null) {
            region = [SELECT Id, RegionCode__c FROM Region__c WHERE Id = :(String) fieldMap.get('RegionLookup__c') LIMIT 1];
        }

        erpParameters.I_BASIC.COUNTRY       = country.CountryCode__c;
        erpParameters.I_BASIC.POST_CODE1    = (String) fieldMap.get('ShippingPostalCode');
        erpParameters.I_BASIC.CITY1         = (String) fieldMap.get('ShippingCity');
        erpParameters.I_BASIC.REGION        = fieldMap.get('RegionLookup__c') != null ? region.RegionCode__c : '';
        
        if((String) fieldMap.get('ShippingStreet') != '' && (String) fieldMap.get('ShippingStreet') != null) {
            Integer maxLength = 60;
            String street = (String) fieldMap.get('ShippingStreet') != '' ? (String) fieldMap.get('ShippingStreet') : '';
            if(street != '') {
                erpParameters.I_BASIC.STREET = street.length() > maxLength 
                    ? street.substring(0, maxLength) 
                    : street;
    
                String remainingText = street.length() > maxLength 
                    ? street.substring(maxLength) 
                    : null;
    
                if (remainingText != null) {
                    erpParameters.I_BASIC.STR_SUPPL1 = remainingText.length() > maxLength 
                        ? remainingText.substring(0, maxLength) 
                        : remainingText;
                }
            }
        }

        erpParameters.I_BASIC.MOB_NUMBER    = (String) fieldMap.get('Phone');
        erpParameters.I_BASIC.J_1KFREPRE    = (String) fieldMap.get('Representative__c');
    
        // I_USERINFO
        erpParameters.I_USERINFO            = new IF_ERP_Account_Classes.IF_ACCOUNT_015_I_USERINFO();
        erpParameters.I_USERINFO.BNAME      = (String) fieldMap.get('OwnerId');
        erpParameters.I_USERINFO.VKORG      = (String) fieldMap.get('SalesOrganization__c');
        erpParameters.I_USERINFO.VTWEG      = (String) fieldMap.get('DistributionChannel__c');
        erpParameters.I_USERINFO.SPART      = (String) fieldMap.get('Division__c');
        erpParameters.I_USERINFO.RNAME      = (String) fieldMap.get('Owner.Name');

        // KUNNR : 필수 값
        if((String) fieldMap.get('Owner.Account.CustomerCode__c') != null) {
            erpParameters.I_USERINFO.KUNNR      = (String) fieldMap.get('Owner.Account.CustomerCode__c');
        } else {
            erpParameters.I_USERINFO.KUNNR      = (String) fieldMap.get('Owner.CustomerCode__c');
        }

        erpParameters.I_USERINFO.WERKS = (String) fieldMap.get('Owner.Plant__c');
        erpParameters.I_USERINFO.LAND1 = country.CountryCode__c;
    
        // ERP 서비스 호출
        IF_ERP_Account erpService = new IF_ERP_Account();
        return erpService.IF_ACCOUNT_015(erpParameters);
    }

}