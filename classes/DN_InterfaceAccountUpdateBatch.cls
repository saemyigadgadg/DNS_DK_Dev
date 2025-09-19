/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-22-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-18-2024   Hanyeong Choi   Initial Version
**/
global with sharing class DN_InterfaceAccountUpdateBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private List<Account> newsList;
    String recordType;

    /**
     * 생성자: 배치에 사용할 계정 리스트와 레코드 유형을 초기화합니다.
     */
    global DN_InterfaceAccountUpdateBatch(List<Account> news, String recordType) {
        this.newsList = news;
        this.recordType = recordType;
    }

    /**
     * 시작 메서드: 배치 작업을 시작하며, 더미 쿼리를 반환합니다. 실제 데이터는 생성자를 통해 전달됩니다.
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('DN_InterfaceAccountUpdateBatch Start ------------');
        try {
            return Database.getQueryLocator([SELECT Id FROM Account LIMIT 1]); // dummy query
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 실행 메서드: 계정 리스트를 처리하고, 국가 및 지역 코드를 매핑하며, 레코드 유형에 따라 적절한 ERP 인터페이스를 호출합니다.
     */
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug('DN_InterfaceAccountUpdateBatch Excute ------------');
        try {
            List<Account> accList = this.newsList;
            Map<String, String> countryMap = new Map<String, String>();
            Map<String, String> regionMap = new Map<String, String>();

            TradeCustomerDefault__mdt tcd = [
                SELECT  Id
                        , CompanyCode__c
                        , SalesOrganization__c
                        , DistributionChannel__c
                        , Division__c
                        , SalesDistrict__c
                        , Language__c
                        , CustomerGroup__c
                        , Currency__c
                        , CustPricProc__c
                        , PriceList__c
                        , ShippingConditions__c
                        , Incoterms1__c
                        , Incoterms2__c
                        , TermsOfPayment__c
                        , AcctAssgmtGroup__c
                        , CustomerGrp5__c 
                FROM TradeCustomerDefault__mdt 
                LIMIT 1
            ];

            if(!accList.isEmpty()) {
                Set<Id> countryIds = new Set<Id>();
                for(Account acc : accList) {
                    if(acc.CountryLookup__c != null) {
                        countryMap.put(acc.CountryLookup__c, null);
                    }
                    if(acc.RegionLookup__c != null) {
                        regionMap.put(acc.RegionLookup__c, null);
                    }
                }
                if(!countryMap.isEmpty()) {
                    List<Country__c> countryList = [SELECT Id, CountryCode__c FROM Country__c WHERE Id IN :countryMap.keySet()];
                    for(Country__c country : countryList) {
                        countryMap.put(country.Id, country.CountryCode__c);
                    }
                }
                if(!regionMap.isEmpty()) {
                    List<Region__c> regionList = [SELECT Id, RegionCode__c FROM Region__c WHERE Id IN :regionMap.keySet()];
                    for(Region__c region : regionList) {
                        regionMap.put(region.Id, region.RegionCode__c);
                    }
                }

                for(Account acc : accList) {
                    System.debug('acc ::: ' + acc);
                    if(this.recordType == 'ProspectCustomer') {
                        IF_ERP_Account_Classes.IF_ACCOUNT_002_Res erpResponse = interfaceAccount002(acc, countryMap, regionMap);
                        System.debug('erpResponse ::: ' + erpResponse);
                        if(erpResponse.O_RECODE == 'S') {
                            System.debug('Account ERP Update Success');
                            System.debug('SUCCESS ::: ' + erpResponse.O_REMSG);
                        } else {
                            System.debug('Account ERP Update Fail');
                            System.debug('FAIL ::: ' + erpResponse.O_REMSG);
                        }
                    } else if(this.recordType == 'TradeCustomer') {
                        IF_ERP_Account_Classes.IF_ACCOUNT_003_Res erpResponse = interfaceAccount003(acc, countryMap, regionMap, tcd);
                        if(erpResponse.O_RECODE == 'S') {
                            System.debug('Account ERP Update Success');
                            System.debug('SUCCESS ::: ' + erpResponse.O_REMSG);
                        } else {
                            System.debug('Account ERP Update Fail');
                            System.debug('FAIL ::: ' + erpResponse.O_REMSG);
                        }
                    } else if(this.recordType == 'ShipToParty') {
                        IF_ERP_Account_Classes.IF_ACCOUNT_013_Res erpResponse = interfaceAccount013(acc, countryMap, regionMap);
                        if(erpResponse.O_RECODE == 'S') {
                            System.debug('Account ERP Update Success');
                            System.debug('SUCCESS ::: ' + erpResponse.O_REMSG);
                        } else {
                            System.debug('Account ERP Update Fail');
                            System.debug('FAIL ::: ' + erpResponse.O_REMSG);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }

    }

    /**
     * 종료 메서드: 배치 작업이 완료되었음을 로그로 남깁니다.
     */
    global void finish(Database.BatchableContext BC) {
        System.debug('DN_InterfaceAccountUpdateBatch Finish ------------');
    }

    /**
     * ProspectCustomer용 ERP 인터페이스 호출: 계정 데이터를 ERP 시스템에 전송하기 위해 매개변수를 설정하고 호출합니다.
     */
    public static IF_ERP_Account_Classes.IF_ACCOUNT_002_Res interfaceAccount002(Account acc, Map<String, String> countryMap, Map<String, String> regionMap) {
        IF_ERP_Account_Classes.IF_ACCOUNT_002_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_002_Req();

        erpParameters.I_KUNNR = acc.CustomerCode__c;
        erpParameters.I_ANRED = 'Company';
        erpParameters.I_NAME1 = acc.Name;
        erpParameters.I_NAME = acc.Representative__c;
        erpParameters.I_NAME3 = acc.AccountNameEnglish__c;
        erpParameters.I_SORT1 = acc.SearchTerm__c;

        erpParameters.I_COUNTRY = acc.CountryLookup__c != null ? String.valueOf(countryMap.get(acc.CountryLookup__c)) : '';
        erpParameters.I_REGION = acc.RegionLookup__c != null ? regionMap.get(acc.RegionLookup__c) : '';
        erpParameters.I_PSTLZ = acc.ShippingPostalCode;

        if(acc.ShippingCity != null) {
            Integer maxLength = 40;
            erpParameters.I_CITY1 = acc.ShippingCity.length() > maxLength 
                ? acc.ShippingCity.substring(0, maxLength) 
                : acc.ShippingCity;
    
            String remainingText = acc.ShippingCity.length() > maxLength 
                ? acc.ShippingCity.substring(maxLength) 
                : null;
    
            if (remainingText != null) {
                erpParameters.I_STR_SUPPL1 = remainingText.length() > maxLength 
                    ? remainingText.substring(0, maxLength) 
                    : remainingText;
    
                remainingText = remainingText.length() > maxLength 
                    ? remainingText.substring(maxLength) 
                    : null;
            }
    
            if (remainingText != null) {
                erpParameters.I_LOCATION = remainingText;
            }
        }

        erpParameters.I_STREET = acc.ShippingStreet;
        erpParameters.I_TEL_NUMBER = acc.Phone;
        erpParameters.I_MOB_NUMBER = acc.Mobile__c;
        erpParameters.I_FAX_NUMBER = acc.Fax;

        erpParameters.I_SMTP_ADDR = acc.Website;
        erpParameters.I_KATR1 = acc.MainCategory__c;
        erpParameters.I_KATR2 = acc.SubCategory__c;
        erpParameters.I_KATR3 = acc.IsTooling__c;
        erpParameters.I_J_1KFTBUS = acc.TypeOfBusiness__c;
        erpParameters.I_J_1KFTIND = acc.TypeOfIndustry__c;
        erpParameters.I_VKBUR = acc.SalesOffice__c;
        erpParameters.I_BZIRK = acc.SalesDistrict__c;

        if(acc.CountryLookup__c != null) {
            if(String.valueOf(countryMap.get(acc.CountryLookup__c)) == 'KR') {
                erpParameters.I_TAXNUMBER1 = acc.BusinessNumberDuplCheck__c;
            } else {
                erpParameters.I_TAXNUMBER1 = acc.BusinessNumber__c;
            }
        }

        erpParameters.I_VKORG = acc.SalesOrganization__c;
        erpParameters.I_VTWEG = acc.DistributionChannel__c;
        erpParameters.I_SPART = acc.Division__c;
        erpParameters.I_SPRAS = acc.Language__c;
        erpParameters.I_WAERS = acc.CurrencyIsoCode;

        IF_ERP_Account erpService = new IF_ERP_Account();
        return erpService.IF_ACCOUNT_002(erpParameters);
    }

    /**
     * TradeCustomer용 ERP 인터페이스 호출: 계정 데이터를 ERP 시스템에 전송하기 위해 매개변수를 설정하고 호출합니다.
     */
    public static IF_ERP_Account_Classes.IF_ACCOUNT_003_Res interfaceAccount003(Account acc, Map<String, String> countryMap, Map<String, String> regionMap, TradeCustomerDefault__mdt tcd) {
        IF_ERP_Account_Classes.IF_ACCOUNT_003_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_003_Req();

        erpParameters.I_KUNNR = acc.CustomerCode__c;
        erpParameters.I_ANRED = 'Company';
        erpParameters.I_NAME1 = acc.Name;
        erpParameters.I_NAME3 = acc.AccountNameEnglish__c;
        erpParameters.I_SORT1 = acc.SearchTerm__c;
        erpParameters.I_NAME = acc.Representative__c;

        erpParameters.I_COUNTRY = acc.CountryLookup__c != null ? countryMap.get(acc.CountryLookup__c) : '';
        erpParameters.I_REGION = acc.RegionLookup__c != null ? regionMap.get(acc.RegionLookup__c) : '';
        erpParameters.I_PSTLZ = acc.ShippingPostalCode;

        if(acc.ShippingCity != null) {
            Integer maxLength = 40;
            erpParameters.I_CITY1 = acc.ShippingCity.length() > maxLength 
                ? acc.ShippingCity.substring(0, maxLength) 
                : acc.ShippingCity;
    
            String remainingText = acc.ShippingCity.length() > maxLength 
                ? acc.ShippingCity.substring(maxLength) 
                : null;
    
            if (remainingText != null) {
                erpParameters.I_STR_SUPPL1 = remainingText.length() > maxLength 
                    ? remainingText.substring(0, maxLength) 
                    : remainingText;
    
                remainingText = remainingText.length() > maxLength 
                    ? remainingText.substring(maxLength) 
                    : null;
            }
    
            if (remainingText != null) {
                erpParameters.I_LOCATION = remainingText;
            }
        }

        erpParameters.I_STREET = acc.ShippingStreet;
        erpParameters.I_TEL_NUMBER = acc.Mobile__c;
        erpParameters.I_MOB_NUMBER = acc.Phone;

        erpParameters.I_SMTP_ADDR = acc.Website;
        erpParameters.I_KATR1 = acc.MainCategory__c;
        erpParameters.I_KATR2 = acc.SubCategory__c;
        erpParameters.I_KATR3 = acc.IsTooling__c;
        erpParameters.I_J_1KFTBUS = acc.TypeOfBusiness__c;
        erpParameters.I_J_1KFTIND = acc.TypeOfIndustry__c;

        if(acc.CountryLookup__c != null) {
            if(String.valueOf(countryMap.get(acc.CountryLookup__c)) == 'KR') {
                erpParameters.I_TAXNUMBER1 = acc.BusinessNumberDuplCheck__c;
            } else {
                erpParameters.I_TAXNUMBER1 = acc.BusinessNumber__c;
            }
        }

        erpParameters.I_BZIRK      = tcd.SalesDistrict__c;
        erpParameters.I_VKORG      = tcd.SalesOrganization__c;
        erpParameters.I_VTWEG      = tcd.DistributionChannel__c;
        erpParameters.I_SPART      = tcd.Division__c;
        erpParameters.I_SPRAS      = tcd.Language__c;
        erpParameters.I_EMAIL = acc.Email__c;
        erpParameters.I_WAERS = acc.CurrencyIsoCode;

        IF_ERP_Account erpService = new IF_ERP_Account();
        return erpService.IF_ACCOUNT_003(erpParameters);
    }

    /**
     * ShipToParty용 ERP 인터페이스 호출: 계정 데이터를 ERP 시스템에 전송하기 위해 매개변수를 설정하고 호출합니다.
     */
    public static IF_ERP_Account_Classes.IF_ACCOUNT_013_Res interfaceAccount013(Account acc, Map<String, String> countryMap, Map<String, String> regionMap) {
        IF_ERP_Account_Classes.IF_ACCOUNT_013_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_013_Req();

        erpParameters.I_KUNNR = acc.CustomerCode__c;
        erpParameters.I_ANRED = 'Company';
        erpParameters.I_NAME1 = acc.Name;
        erpParameters.I_NAME3 = acc.AccountNameEnglish__c;
        erpParameters.I_SORT1 = acc.SearchTerm__c;
        erpParameters.I_COUNTRY = acc.CountryLookup__c != null ? countryMap.get(acc.CountryLookup__c) : '';
        erpParameters.I_REGION = acc.RegionLookup__c != null ? regionMap.get(acc.RegionLookup__c) : '';
        erpParameters.I_PSTLZ = acc.ShippingPostalCode;

        if(acc.ShippingCity != null) {
            Integer maxLength = 35;
            erpParameters.I_CITY1 = acc.ShippingCity.length() > maxLength 
                ? acc.ShippingCity.substring(0, maxLength) 
                : acc.ShippingCity;
    
            String remainingText = acc.ShippingCity.length() > maxLength 
                ? acc.ShippingCity.substring(maxLength) 
                : null;
    
            if (remainingText != null) {
                erpParameters.I_STR_SUPPL1 = remainingText.length() > maxLength 
                    ? remainingText.substring(0, maxLength) 
                    : remainingText;
    
                remainingText = remainingText.length() > maxLength 
                    ? remainingText.substring(maxLength) 
                    : null;
            }
    
            if (remainingText != null) {
                erpParameters.I_LOCATION = remainingText;
            }
        }

        erpParameters.I_STREET = acc.ShippingStreet;
        erpParameters.I_TEL_NUMBER = acc.Mobile__c;
        erpParameters.I_MOB_NUMBER = acc.Phone;
        erpParameters.I_FAX_NUMBER = acc.Fax;
        erpParameters.I_SMTP_ADDR = acc.Website;
        erpParameters.I_KATR1 = acc.MainCategory__c;
        erpParameters.I_KATR2 = acc.SubCategory__c;
        erpParameters.I_KATR3 = acc.IsTooling__c;
        erpParameters.I_J_1KFTBUS = acc.TypeOfBusiness__c;
        erpParameters.I_J_1KFTIND = acc.TypeOfIndustry__c;
        erpParameters.I_VKBUR = acc.SalesOffice__c;
        erpParameters.I_BZIRK = acc.SalesDistrict__c;

        if(acc.CountryLookup__c != null) {
            if(String.valueOf(countryMap.get(acc.CountryLookup__c)) == 'KR') {
                erpParameters.I_TAXNUMBER1 = acc.BusinessNumberDuplCheck__c;
            } else {
                erpParameters.I_TAXNUMBER1 = acc.BusinessNumber__c;
            }
        }
        erpParameters.I_VKORG = acc.SalesOrganization__c;
        erpParameters.I_VTWEG = acc.DistributionChannel__c;
        erpParameters.I_SPART = acc.Division__c;
        erpParameters.I_EMAIL = acc.Email__c;
        erpParameters.I_SPRAS = acc.Language__c;
        erpParameters.I_WAERS = acc.CurrencyIsoCode;

        IF_ERP_Account erpService = new IF_ERP_Account();
        return erpService.IF_ACCOUNT_013(erpParameters);
    }
}