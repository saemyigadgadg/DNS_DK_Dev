/**
 * @author            : Yu-Hyun Park
 * @description       : 
 *  - Lead에서 Converted된 Account를 IF_ACCOUNT_001을 통해 CustomerCode를 받아옴 (Prospect Customer)
 * @last modified on  : 2025-04-14
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-18   yuhyun.park@sbtglobal.com   Initial Version
**/
global with sharing class DN_ConvertedAccountBatch implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {

    private static final Id   accProspectRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();

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

            FROM Account
            WHERE CustomerCode__c = null 
            AND RecordTypeId = :accProspectRT
            AND Id IN (
                SELECT ConvertedAccountId 
                FROM Lead 
                WHERE IsConverted = true AND ConvertedAccountId != null
            )
        ]);
    }


    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('scope :: ' + scope);

        if(!scope.isEmpty()){
            Account acc = (Account) scope.get(0);

            // Interface 전송할 FieldMap
            Map<String, Object> fieldMap = new Map<String, Object>();

            // DNS Prospect 타입 : interface-Account-001
            fieldMap.put('Representative__c'        , acc.Representative__c);
            fieldMap.put('Name'                     , acc.Name);
            fieldMap.put('AccountNameEnglish__c'    , acc.AccountNameEnglish__c);
            fieldMap.put('SearchTerm__c'            , acc.SearchTerm__c);
            fieldMap.put('CountryLookup__c'         , acc.CountryLookup__c);

            fieldMap.put('RegionLookup__c'          , acc.RegionLookup__c);
            fieldMap.put('ShippingPostalCode'       , acc.ShippingPostalCode);
            fieldMap.put('ShippingStreet'           , acc.ShippingStreet);
            fieldMap.put('ShippingCity'             , acc.ShippingCity);
            fieldMap.put('Phone'                    , acc.Phone);

            fieldMap.put('Mobile__c'                , acc.Mobile__c);
            fieldMap.put('Fax'                      , acc.Fax);
            fieldMap.put('Website'                  , acc.Website);
            fieldMap.put('MainCategory__c'          , acc.MainCategory__c);
            fieldMap.put('SubCategory__c'           , acc.SubCategory__c);

            fieldMap.put('IsTooling__c'             , acc.IsTooling__c);
            fieldMap.put('TypeOfBusiness__c'        , acc.TypeOfBusiness__c);
            fieldMap.put('TypeOfIndustry__c'        , acc.TypeOfIndustry__c);
            fieldMap.put('SalesOffice__c'           , acc.SalesOffice__c);
            fieldMap.put('SalesDistrict__c'         , acc.SalesDistrict__c);

            fieldMap.put('SalesOrganization__c'     , acc.SalesOrganization__c);
            fieldMap.put('DistributionChannel__c'   , acc.DistributionChannel__c);
            fieldMap.put('Division__c'              , acc.Division__c);
            fieldMap.put('Owner.Account.CustomerCode__c'      , acc.Owner.Account.CustomerCode__c);
            fieldMap.put('Owner.CustomerCode__c'              , acc.Owner.CustomerCode__c);

            fieldMap.put('Language__c'              , acc.Language__c);
            fieldMap.put('BusinessNumber__c'        , acc.BusinessNumber__c);
            fieldMap.put('Email__c'                 , acc.Email__c);

            IF_ERP_Account_Classes.IF_ACCOUNT_001_Res erpResponse = interfaceAccount001(fieldMap);

            System.debug('erpResponse ::: ' + erpResponse);

            if (erpResponse.O_RECODE == 'S') { // ERP 응답 성공 시 진행
                System.debug('erpResponse.O_KUNNR :: ' + erpResponse.O_KUNNR);
                acc.CustomerCode__c = erpResponse.O_KUNNR;
            }
            update acc;
        }
    }

    global void finish(Database.BatchableContext bc) {

        System.debug('Batch processing completed.');
        DateTime nextRunTime = System.now().addMinutes(10);
        String cronExp = generateCronExpression(nextRunTime);
        // 고유한 잡 이름 생성: 현재 시각의 타임스탬프를 접미사로 추가
        String jobName = 'DN_ConvertedAccountBatch_next_' + String.valueOf(nextRunTime.getTime());
        System.debug('Next run scheduled at: ' + nextRunTime + ', jobName: ' + jobName);
        System.schedule(jobName, cronExp, new DN_ConvertedAccountBatch());


    }


    global void execute(SchedulableContext sc) {
        // 배치 클래스 실행
        DN_ConvertedAccountBatch batch = new DN_ConvertedAccountBatch();
        Database.executeBatch(batch, 1);
    }

    public static void scheduleBatchJob() {
        DateTime nextRunTime = System.now().addMinutes(10);
        String cronExp = generateCronExpression(nextRunTime);
        System.schedule('DN_ConvertedAccountBatch', cronExp, new DN_ConvertedAccountBatch());
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


    private static IF_ERP_Account_Classes.IF_ACCOUNT_001_Res interfaceAccount001(Map<String, Object> fieldMap) {

        IF_ERP_Account_Classes.IF_ACCOUNT_001_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_001_Req();

        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE Id = :(String) fieldMap.get('CountryLookup__c') LIMIT 1];
        Region__c region = null;
        if(fieldMap.get('RegionLookup__c') != null) {
            region = [SELECT Id, RegionCode__c FROM Region__c WHERE Id = :(String) fieldMap.get('RegionLookup__c') LIMIT 1];
        }

            erpParameters.I_ANRED      = 'Company';
            // erpParameters.I_NAME1      = (String) fieldMap.get('Name');
            erpParameters.I_NAME1      = ((String) fieldMap.get('Name')).length() > 35 ? ((String) fieldMap.get('Name')).substring(0,35) : ((String) fieldMap.get('Name'));
            erpParameters.I_NAME       = (String) fieldMap.get('Representative__c');
            erpParameters.I_NAME3      = (String) fieldMap.get('AccountNameEnglish__c');

            erpParameters.I_SORT1      = (String) fieldMap.get('SearchTerm__c');
            erpParameters.I_COUNTRY    = country.CountryCode__c;
            erpParameters.I_REGION     = fieldMap.get('RegionLookup__c') != null ? region.RegionCode__c : '';
            erpParameters.I_PSTLZ      = (String) fieldMap.get('ShippingPostalCode');

            Integer maxLength = 35;
            String street = (String) fieldMap.get('ShippingStreet');
            if (street != null){
                erpParameters.I_STREET = street.length() > maxLength ? street.substring(0, maxLength) : street;
                String remainingText = street.length() > maxLength ? street.substring(maxLength) : null;
                
                if (remainingText != null) {
                    erpParameters.I_STR_SUPPL1 = remainingText.length() > maxLength ? remainingText.substring(0, maxLength) : remainingText;
                    remainingText = remainingText.length() > maxLength ? remainingText.substring(maxLength) : null;
                }
                
                if (remainingText != null) {
                    erpParameters.I_LOCATION = remainingText;
                }
            }

            erpParameters.I_CITY1      = (String) fieldMap.get('ShippingCity');
            erpParameters.I_TEL_NUMBER = (String) fieldMap.get('Phone');
            erpParameters.I_MOB_NUMBER = (String) fieldMap.get('Mobile__c');
            erpParameters.I_FAX_NUMBER = (String) fieldMap.get('Fax');
            erpParameters.I_SMTP_ADDR  = (String) fieldMap.get('Website');

            erpParameters.I_KATR1      = (String) fieldMap.get('MainCategory__c');
            erpParameters.I_KATR2      = (String) fieldMap.get('SubCategory__c');
            erpParameters.I_KATR3      = (String) fieldMap.get('IsTooling__c');
            erpParameters.I_J_1KFTBUS  = (String) fieldMap.get('TypeOfBusiness__c');
            erpParameters.I_J_1KFTIND  = (String) fieldMap.get('TypeOfIndustry__c');

            erpParameters.I_VKBUR      = (String) fieldMap.get('SalesOffice__c');
            erpParameters.I_BZIRK      = (String) fieldMap.get('SalesDistrict__c');
            if((String) fieldMap.get('Owner.Account.CustomerCode__c') != null) {
                erpParameters.I_KTONR      = (String) fieldMap.get('Owner.Account.CustomerCode__c');
            } else {
                erpParameters.I_KTONR2      = (String) fieldMap.get('Owner.CustomerCode__c');
            }

            erpParameters.I_VKORG      = (String) fieldMap.get('SalesOrganization__c');
            erpParameters.I_VTWEG      = (String) fieldMap.get('DistributionChannel__c');
            erpParameters.I_SPART      = (String) fieldMap.get('Division__c');
            erpParameters.I_DEALER     = (String) fieldMap.get('Owner.Account.CustomerCode__c') != null ? (String) fieldMap.get('Owner.Account.CustomerCode__c') : (String) fieldMap.get('Owner.CustomerCode__c');
            erpParameters.I_SPRAS      = (String) fieldMap.get('Language__c');

            erpParameters.I_TAXNUMBER4 = (String) fieldMap.get('BusinessNumber__c');
            erpParameters.I_EMAIL      = (String) fieldMap.get('Email__c');

            IF_ERP_Account erpService = new IF_ERP_Account();
            return erpService.IF_ACCOUNT_001(erpParameters);
    }
}