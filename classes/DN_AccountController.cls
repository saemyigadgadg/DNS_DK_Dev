/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-21-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   06-18-2024   Hanyeong Choi   Initial Version
**/
public without sharing class DN_AccountController {

    /* 포탈 Account 레코드 헤더 init시 method */
    @AuraEnabled
    public static Map<String, Object> portalHeaderInit(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();

        try {
            resMap.put('getInit', getPortalAccountInfo(recordId));
            resMap.put('getUserInfo_portalHeader', getUserInfo_portalHeader());
            
            return resMap;
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @Description
     * 	- 실 고객 전환 승인 모달
     * @author Hanyeong Choi | 06-18-2024
     * @Parameter
     *  - recordId	    : Account Record Id
    **/ 
    @AuraEnabled
    public static Map<String, Object> getConfirmInfo(String recordId, String objectName) {
        Map<String, Object> resMap = new Map<String, Object>();
        
        try {
            if(objectName == 'Account') {
                resMap.put('getConfirmInit',    getConfirmInit(recordId));
                resMap.put('getOrderList',      getOrderList(recordId));
            } else {
                resMap.put('getInit',           getInitRequestToUseCuetomer(recordId));
            }
            resMap.put('flag', 'success');
            
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'error');
        }
        return resMap;
    }

    /**
     * @Description
     * 	- trade customer로 전환하기 전 필수 필드 확인
     * @author Hanyeong Choi | 06-19-2024
     * @Parameter
     *  - recordId	    : Account Record Id
    **/ 
    @AuraEnabled
    public static Map<String, Object> checkConvertRequired(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        FieldCheckWrapper   result = new FieldCheckWrapper();
        List<SalesAreaFieldCheckWrapper> sadResultList = new List<SalesAreaFieldCheckWrapper>();
        Boolean flag;

        try {
            User u = [
                SELECT  Id
                        , SalesOrganization__c
                        , DistributionChannel__c
                        , Division__c
                        , IsPortalEnabled
                        , LanguageLocaleKey
                        , Email
                        , AccountId
                        , Account.IsExclusiveDealer__c
                        , Account.CustomerCode__c
                        , Account.Name
                        , CustomerCode__c
                        , SalesDistrict__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
                // WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
            Account acc = [
                SELECT Id
                        , RecordTypeId
                        , CustomerCode__c
                        , Representative__c
                        , BusinessNumber__c
                        , BusinessNumberDuplCheck__c
                        , Production__c
                        , IsBusinessLicense__c
                        , SalesDistrict__c
                        , SalesOffice__c
                        , SalesOrganization__c
                        , Division__c
                        , ResidentRegistrationNumber__c
                        , IsBVC__c
                        , CustomerSystem__c
                        , ShippingAddress
                        , TypeOfBusiness__c
                        , TypeOfIndustry__c
                        , CountryLookup__c
                        , CountryLookup__r.CountryCode__c
                        , Name
                        , Currency__c
                        , IF_Jumin__c
                        , RegionLookup__c
                        , RegionLookup__r.RegionCode__c
                        , DistributionChannel__c
                        , IsBlocked__c
                        , CurrencyIsoCode
                        , (
                            SELECT Id
                                    , Name
                                    , Currency__c
                                    , ShippingConditions__c
                                    , Incoterms__c
                                    , TermsOfPayment__c
                                    , ShipToParty__c
                                    , SoldToParty__c
                                    , BillToParty__c
                                    , Payer__c
                                    , SalesOffice__c
                                    , SalesDistrict__c
                                    , CustomerGroup__c
                                    , TaxClassification__c
                                    , AcctAssgmtGroup__c
                                    , BillToParty__r.CustomerCode__c
                                    , ShipToParty__r.CustomerCode__c
                                    , Payer__r.CustomerCode__c
                                    , Division__c
                                    , SalesOrganization__c
                                    , DistributionChannel__c
                                    , CustPricProc__c
                                    , CurrencyIsoCode
                            FROM SalesAreaData__r
                            WHERE SalesOrganization__c = :u.SalesOrganization__c
                            AND DistributionChannel__c = :u.DistributionChannel__c
                            AND Division__c = :u.Division__c
                            LIMIT 1
                        )
                FROM Account
                WHERE Id = :recordId
                LIMIT 1
            ];

            if(acc.CustomerCode__c == null) {
                resMap.put('flag', 'emptyCode');
                return resMap;
            }
            if(acc.IsBlocked__c) {
                resMap.put('flag', 'isblock');
                return resMap;
            }
            
            System.debug('acc.SalesAreaData__r ::: ' + acc.SalesAreaData__r);
            Boolean sqFlag = false;
            if(!acc.SalesAreaData__r.isEmpty()) {
                sadResultList = checkSalesAreaDataRequired(acc.SalesAreaData__r, u.IsPortalEnabled);
                System.debug('sadResultList ::: ' + sadResultList);
                for(SalesAreaFieldCheckWrapper sw : sadResultList) {
                    if(sw.checkResult == false) {
                        sqFlag = true;
                    }
                }
            }
            
            Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
            if(acc.CountryLookup__r.CountryCode__c == 'KR') {
                if((acc.IsBVC__c != null && acc.IsBVC__c != 'N') || acc.CustomerSystem__c != null) {
                    flag = false;
                } else {
                    if(
                        acc.Production__c != null && 
                        acc.ShippingAddress != null &&
                        acc.TypeOfBusiness__c != null &&
                        acc.TypeOfIndustry__c != null &&
                        acc.RegionLookup__c    != null
                    ) {
                        if(
                            !sqFlag &&
                            (acc.ResidentRegistrationNumber__c != null ||
                            (acc.BusinessNumber__c != null && acc.IsBusinessLicense__c == true))
                        ) {
                            if((u.Account.IsExclusiveDealer__c && u.SalesDistrict__c != 'A1KR') || !u.IsPortalEnabled) {
                                // 승인 없이 실고객 전환 I/F 호출
                                // 성공 알람
                                IF_ERP_Account_Classes.IF_ACCOUNT_006_Res response = tradeApprovalErp(acc, u, '독점');
                                if(response.O_RECODE != 'S') {
                                    resMap.put('flag', 'erpError');
                                    if (response.O_REMSG.toLowerCase().contains('duplicated with')) {
                                        resMap.put('message', System.Label.DNS_ACC_T_DUPLBUSINESS);
                                    } else if(response.O_REMSG.toLowerCase().contains('currently blocked by')) {
                                        resMap.put('message', System.Label.DNS_ACC_T_BLOCKACCOUNTERP);
                                    } else {
                                        resMap.put('message', 'ERP validation failed: ' + (response.O_REMSG != null ? response.O_REMSG : 'ERP error'));
                                    }
                                    return resMap;
                                } else {
                                    acc.RecordTypeId = tradeCustomerRT;
                                    TriggerHandler.bypass('AccountTriggerHandler');
                                    update acc;
                                    TriggerHandler.clearBypass('AccountTriggerHandler');
                                    globalDealerNotification(acc, u);
                                    globalDealerEmail(acc, u);
                                }
                            } else {
                                // ERP 실고객 전환 승인 호출
                                IF_ERP_Account_Classes.IF_ACCOUNT_006_Res response = tradeApprovalErp(acc, u, '일반');
                                System.debug('response ::: ' + response);
                                
                                // 승인 요청 실패
                                if(response.O_RECODE != 'S') {
                                    resMap.put('flag', 'erpError');
                                    if (response.O_REMSG.toLowerCase().contains('duplicated with')) {
                                        resMap.put('message', System.Label.DNS_ACC_T_DUPLBUSINESS);
                                    } else if(response.O_REMSG.toLowerCase().contains('currently blocked by')) {
                                        resMap.put('message', System.Label.DNS_ACC_T_BLOCKACCOUNTERP);
                                    } else {
                                        resMap.put('message', 'ERP validation failed: ' + (response.O_REMSG != null ? response.O_REMSG : 'ERP error'));
                                    }
                                    return resMap;
                                } else {
                                    acc.IsBlocked__c = true;
                                    TriggerHandler.bypass('AccountTriggerHandler');
                                    update acc;
                                    TriggerHandler.clearBypass('AccountTriggerHandler');
                                    // 승인 요청 알람
                                    RequestConvertNoti_kr(acc);
                                    RequestConvertEmail_kr(acc);
                                }
                            }
            
                            flag = true;
                        } else {
                            flag = false;    
                        }
                    } else {
                        flag = false;
                    }
                }
            } else {
                if(
                    acc.BusinessNumber__c   != null &&
                    acc.Production__c       != null &&
                    acc.ShippingAddress     != null &&
                    acc.CountryLookup__c    != null &&
                    acc.RegionLookup__c    != null
                ) {
                    if((u.Account.IsExclusiveDealer__c && u.SalesDistrict__c != 'A1KR') || !u.IsPortalEnabled) {
                        // 승인 없이 실고객 전환 I/F 호출
                        IF_ERP_Account_Classes.IF_ACCOUNT_006_Res response = tradeApprovalErp(acc, u, '독점');
                        if(response.O_RECODE != 'S') {
                            resMap.put('flag', 'erpError');
                            if (response.O_REMSG.toLowerCase().contains('duplicated with')) {
                                resMap.put('message', System.Label.DNS_ACC_T_DUPLBUSINESS);
                            } else if(response.O_REMSG.toLowerCase().contains('currently blocked by')) {
                                resMap.put('message', System.Label.DNS_ACC_T_BLOCKACCOUNTERP);
                            } else {
                                resMap.put('message', 'ERP validation failed: ' + (response.O_REMSG != null ? response.O_REMSG : 'ERP error'));
                            }
                            return resMap;
                        } else {
                            acc.RecordTypeId = tradeCustomerRT;
                            TriggerHandler.bypass('AccountTriggerHandler');
                            update acc;
                            TriggerHandler.clearBypass('AccountTriggerHandler');
                            globalDealerNotification(acc, u);
                            globalDealerEmail(acc, u);
                        }
                    } else {
                        // ERP 실고객 전환 승인 호출
                        IF_ERP_Account_Classes.IF_ACCOUNT_006_Res response = tradeApprovalErp(acc, u, '일반');

                        if(response.O_RECODE != 'S') {
                            resMap.put('flag', 'erpError');
                            if (response.O_REMSG.toLowerCase().contains('duplicated with')) {
                                resMap.put('message', System.Label.DNS_ACC_T_DUPLBUSINESS);
                            } else if(response.O_REMSG.toLowerCase().contains('currently blocked by')) {
                                resMap.put('message', System.Label.DNS_ACC_T_BLOCKACCOUNTERP);
                            } else {
                                resMap.put('message', 'ERP validation failed: ' + (response.O_REMSG != null ? response.O_REMSG : 'ERP error'));
                            }
                            return resMap;
                        } else {
                            acc.IsBlocked__c = true;
                            TriggerHandler.bypass('AccountTriggerHandler');
                            update acc;
                            TriggerHandler.clearBypass('AccountTriggerHandler');
                            // 승인 요청 알람
                            RequestConvertNoti_global(acc);
                            // RequestConvertEmail_global(acc); // [GSR SR0000010031094 수정]
                        }
                    }
    
                    flag = true;
                } else {
                    flag = false;
                }
            }

            if(flag) {
                result.isKorea                      = (acc.CountryLookup__r.CountryCode__c == 'KR') ? true : false;
                result.checkResult                  = true;
            } else {
                result.isKorea                      = (acc.CountryLookup__r.CountryCode__c == 'KR') ? true : false;
                result.checkResult                  = false;
                result.businessNumber               = acc.BusinessNumber__c             != null ? true : false;
                result.production                   = acc.Production__c                 != null ? true : false;
                result.isBusinessLicense            = acc.IsBusinessLicense__c;
                result.residentRegistrationNumber   = acc.ResidentRegistrationNumber__c != null ? true : false;
                result.isTotalBusinessNumber        = acc.BusinessNumber__c             != null && acc.IsBusinessLicense__c == false ? false : acc.BusinessNumber__c == null && acc.ResidentRegistrationNumber__c == null ? false : true;
                result.isBVC                        = acc.IsBVC__c                      != null || acc.CustomerSystem__c    != null ? true : false;
                result.shippingAddress              = acc.ShippingAddress               != null ? true : false;
                result.typeOfIndustry               = acc.TypeOfIndustry__c             != null ? true : false;
                result.typeOfBusiness               = acc.TypeOfBusiness__c             != null ? true : false;
                result.country                      = acc.CountryLookup__c              != null ? true : false;
                result.region                       = acc.RegionLookup__c               != null ? true : false;
            }

            resMap.put('flag',      'success');
            resMap.put('result',    result);
            resMap.put('sadResult', sadResultList);
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'error');
            resMap.put('message', e.getMessage());
        }
        return resMap;
    }

    /* 실고객 전환 요청 */
    private static IF_ERP_Account_Classes.IF_ACCOUNT_006_Res tradeApprovalErp(Account acc, User currentUser, String type) {
        IF_ERP_Account_Classes.IF_ACCOUNT_006_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_006_Req();

        erpParameters.I_KUNNR           = acc.CustomerCode__c;
        erpParameters.I_ANRED           = 'Company';
        System.debug('acc.IF_Jumin__c ::: ' + acc.IF_Jumin__c);
        erpParameters.I_STCD1           = acc.IF_Jumin__c != null ? acc.IF_Jumin__c : '';

        System.debug('acc.CountryLookup__r.CountryCode__c ::: ' + acc.CountryLookup__r.CountryCode__c);
        System.debug('acc.BusinessNumber__c ::: ' + acc.BusinessNumber__c);
        System.debug('acc.BusinessNumberDuplCheck__c ::: ' + acc.BusinessNumberDuplCheck__c);
        if(acc.CountryLookup__r.CountryCode__c == 'KR') {
            erpParameters.I_STCD2           = acc.BusinessNumber__c != null ? acc.BusinessNumberDuplCheck__c : ''; // acc.BusinessNumber__c;
        } else {
            erpParameters.I_STCD3           = acc.BusinessNumber__c != null ? acc.BusinessNumber__c : '';
        }
        // erpParameters.I_LZONE           = acc.TransportationZone__c;
        erpParameters.I_J_1KFTBUS       = acc.TypeOfBusiness__c;
        erpParameters.I_J_1KFTIND       = acc.TypeOfIndustry__c;
        erpParameters.I_KTONR           = currentUser.Account.CustomerCode__c != null ? currentUser.Account.CustomerCode__c : currentUser.CustomerCode__c;
        erpParameters.I_VKBUR           = acc.SalesOffice__c;
        erpParameters.I_BZIRK           = acc.SalesDistrict__c;
        // erpParameters.I_WAERS           = acc.SalesAreaData__r[0].Currency__c;
        erpParameters.I_WAERS           = acc.CurrencyIsoCode;
        erpParameters.I_INCO1           = acc.SalesAreaData__r[0].Incoterms__c != null ? acc.SalesAreaData__r[0].Incoterms__c : '';
        erpParameters.I_INCO2           = acc.SalesAreaData__r[0].Incoterms__c != null ? acc.SalesAreaData__r[0].Incoterms__c : '';
        erpParameters.I_VSBED           = acc.SalesAreaData__r[0].ShippingConditions__c != null ? acc.SalesAreaData__r[0].ShippingConditions__c : '';
        erpParameters.I_TAXKD           = acc.SalesAreaData__r[0].TaxClassification__c != null ? acc.SalesAreaData__r[0].TaxClassification__c : '';
        erpParameters.I_KDGRP           = '01'; // Prospect Customer ? SalesAreaData__r[0].CutomerGroup__c ???
        erpParameters.I_ZTERM           = acc.SalesAreaData__r[0].TermsOfPayment__c != null ? acc.SalesAreaData__r[0].TermsOfPayment__c : '';
        erpParameters.I_KTGRD           = acc.SalesAreaData__r[0].AcctAssgmtGroup__c != null ? acc.SalesAreaData__r[0].AcctAssgmtGroup__c : '';
        // erpParameters.I_KTONR1          = acc.SalesAreaData__r[0].BillToParty__c != null ? acc.SalesAreaData__r[0].BillToParty__r.CustomerCode__c : '';
        // erpParameters.I_KTONR2          = acc.SalesAreaData__r[0].ShipToParty__c != null ?  acc.SalesAreaData__r[0].ShipToParty__r.CustomerCode__c : '';
        // erpParameters.I_KTONR3          = 
        // erpParameters.I_KTONR4          = acc.SalesAreaData__r[0].Payer__c != null ? acc.SalesAreaData__r[0].Payer__r.CustomerCode__c : '';
        erpParameters.I_VKORG           = acc.SalesOrganization__c;
        erpParameters.I_VTWEG           = acc.DistributionChannel__c;
        erpParameters.I_SPART           = acc.Division__c;
        erpParameters.I_DEALER          = currentUser.Account.CustomerCode__c != null ? currentUser.Account.CustomerCode__c : currentUser.CustomerCode__c;
        // erpParameters.I_SPRAS           =
        erpParameters.I_REGION          = acc.RegionLookup__c != null ? (String) acc.RegionLookup__r.RegionCode__c : '';
        erpParameters.I_KALKS           = acc.SalesAreaData__r[0].CustPricProc__c != null ? acc.SalesAreaData__r[0].CustPricProc__c : '1';
        erpParameters.I_J_1KFREPRE      = acc.Representative__c;
        if(type == '독점') {
            erpParameters.I_APPROVE_CHK = 'X';
        }

        IF_ERP_Account erpService = new IF_ERP_Account();
        return erpService.IF_ACCOUNT_006(erpParameters);
    }

    /**
     * @Description
     * 	- 주소 검색
     * @author Hanyeong Choi | 06-20-2024
     * @Parameter
     *  - searchText	    : 검색어
     *  - pageNumber	    : 페이징 넘버
    **/ 
    @AuraEnabled
    public static Map<String, Object> getAddress(String searchText, Integer pagingNumber) {
        Map<String, Object> resMap      = new Map<String, Object>();
        IF_MOIS_Address     moisAddress = new IF_MOIS_Address();
        
        try {
            String              resultIF    = moisAddress.getAddressInfo(searchText, String.valueOf(pagingNumber));
            Map<String, Object> resultIFMap = (Map<String, Object>) JSON.deserializeUntyped(resultIF);
            Map<String, object> resultsMap  = (Map<String, object>) resultIFMap.get('results');
            Map<String, object> commonMap   = (Map<String, object>) resultsMap.get('common');
            List<Object>        jusoList    = (List<Object>) resultsMap.get('juso');
    
            resMap.put('totalResultCount',  commonMap.get('totalCount'));
            resMap.put('jusoList',          jusoList);
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'fail');
        }
        return resMap;
    }

    /**
     * @Description
     * 	- 주소 선택 후, Account ShippingAddress 업데이트
     * @author Hanyeong Choi | 06-25-2024
     * @Parameter
     *  - recordId	        : Account Record Id
     *  - address	        : 선택한 address 정보
    **/ 
    @AuraEnabled
    public static Map<String, String> setShippingAddress(String recordId, Map<String, Object> address, Object detailInfo) {
        Map<String, String> resMap = new Map<String, String>();
        try {
            Account acc = [
                SELECT Id
                        , ShippingStreet
                        , ShippingPostalCode
                        , sggNm__c
                        , ShippingCity
                        , ShippingCountry
                        , ShippingState
                        , DetailAddress__c
                FROM Account 
                WHERE Id = :recordId 
                LIMIT 1
            ];

            // acc.ShippingStreet      = (String) address.get('roadAddr') + '\n' + detailInfo;
            acc.ShippingStreet      = detailInfo + '';
            acc.ShippingPostalCode  = (String) address.get('zipNo');
            acc.sggNm__c            = (String) address.get('siNm') + ' ' + (String) address.get('sggNm');
            // acc.ShippingCity        = (String) address.get('siNm');
            acc.ShippingCity        = (String) address.get('roadAddr');
            acc.ShippingCountry     = 'Korea, Republic of';
            acc.ShippingState       = '';
            acc.DetailAddress__c    = detailInfo + '';

            update acc;
            
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'fail');
        }
        return resMap;
    }

    /**
     * @Description
     * 	- 사업자번호 진위 확인
     * @author Hanyeong Choi | 06-21-2024
     * @Parameter
     *  - recordId	    : Account Record Id
    **/ 
    @AuraEnabled
    public static Map<String, Object> checkBusinessNumber(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();

        try {
            Account acc = [
                SELECT Id
                        , BusinessNumber__c
                        , IsBusinessLicense__c
                FROM Account
                WHERE Id = :recordId
                LIMIT 1
            ];

            if(acc.BusinessNumber__c != null && !acc.IsBusinessLicense__c) {
                String  businessNumber  = acc.BusinessNumber__c.replace('-', '');
                        resMap          = IF_NTS_BusinessNumber.getBusinessNumber(businessNumber);
            } else if(acc.BusinessNumber__c == null) {
                resMap.put('flag', 'null');
            } else if(acc.IsBusinessLicense__c) {
                resMap.put('flag', 'already');
            }
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'error');
        }
        return resMap;
    }

    /**
     * @Description
     * 	- 사업자번호 진위 확인
     * @author Hanyeong Choi | 06-21-2024
     * @Parameter
     *  - recordId	    : Account Record Id
    **/ 
    @AuraEnabled
    public static Map<String, Object> checkBusinessNumber_ListView(String inputValue) {
        Map<String, Object> resMap = new Map<String, Object>();

        try {
            if(inputValue != null) {
                String  businessNumber  = inputValue.replace('-', '');
                        resMap          = IF_NTS_BusinessNumber.getBusinessNumber(businessNumber);
            } else {
                resMap.put('flag', 'null');
            }
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'error');
        }
        return resMap;
    }

    /**
     * @Description
     * 	- 사업자번호 진위 확인 후, IsBusinessLicense__c 업데이트
     * @author Hanyeong Choi | 06-21-2024
     * @Parameter
     *  - recordId	    : Account Record Id
    **/ 
    @AuraEnabled
    public static Map<String, String> updateIsBusinessLicense(String recordId) {
        Map<String, String> resMap = new Map<String, String>();

        try {
            Account acc = [
                SELECT Id
                        , BusinessNumber__c
                        , IsBusinessLicense__c
                FROM Account
                WHERE Id = :recordId
                LIMIT 1
            ];

            String businessNumber = extractNumbers(acc.BusinessNumber__c);
            Boolean dupl = DN_WithoutSharingClass.checkBusinessNumberDuplicate(businessNumber);

            if(dupl) {
                resMap.put('flag', 'duplicate');
            } else {
                acc.IsBusinessLicense__c = true;
                update acc;
                
                resMap.put('flag', 'success');
            }
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'fail');
        }
        return resMap;
    }

    /* Account의 Sales Area Data 정보 가져오기 */
    @AuraEnabled
    public static List<Map<String, String>> getSalesAreaData(String recordId) {
        User u = [
            SELECT Id, SalesOrganization__c, DistributionChannel__c, Division__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];

        List<SalesAreaData__c> sadList = [
            SELECT Id, 
                Name, 
                SalesOrganization__c, 
                SalesDistrict__c, 
                SalesOffice__c 
            FROM SalesAreaData__c
            WHERE Account__c = :recordId
            AND SalesOrganization__c = :u.SalesOrganization__c
            AND DistributionChannel__c = :u.DistributionChannel__c
            AND Division__c = :u.Division__c
        ];

        List<Map<String, String>> result = new List<Map<String, String>>();

        if (!sadList.isEmpty()) {
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SalesAreaData__c.fields.getMap();

            List<Schema.PicklistEntry> salesOrgPicklist = fieldMap.get('SalesOrganization__c').getDescribe().getPicklistValues();
            Map<String, String> salesOrgLabelMap = getPicklistValueLabelMap(salesOrgPicklist);

            List<Schema.PicklistEntry> salesDistPicklist = fieldMap.get('SalesDistrict__c').getDescribe().getPicklistValues();
            Map<String, String> salesDistLabelMap = getPicklistValueLabelMap(salesDistPicklist);

            List<Schema.PicklistEntry> salesOfficePicklist = fieldMap.get('SalesOffice__c').getDescribe().getPicklistValues();
            Map<String, String> salesOfficeLabelMap = getPicklistValueLabelMap(salesOfficePicklist);

            for (SalesAreaData__c sad : sadList) {
                Map<String, String> row = new Map<String, String>();

                row.put('Id', sad.Id);
                row.put('Name', sad.Name);
                row.put('SalesOrganization', salesOrgLabelMap.get(sad.SalesOrganization__c));
                row.put('SalesDistrict', salesDistLabelMap.get(sad.SalesDistrict__c));
                row.put('SalesOffice', salesOfficeLabelMap.get(sad.SalesOffice__c));

                result.add(row);
            }
        }
        return result;
    }

    /* 픽리스트 필드 라벨 추출 */
    private static Map<String, String> getPicklistValueLabelMap(List<Schema.PicklistEntry> picklistEntries) {
        Map<String, String> labelMap = new Map<String, String>();
        for (Schema.PicklistEntry entry : picklistEntries) {
            labelMap.put(entry.getValue(), entry.getLabel());
        }
        return labelMap;
    }


    /**
     * @Description
     * 	- Account의 SalesDistrict__c, CustomerSystem__c, IsBVC__c 조회
     * @author Hanyeong Choi | 06-18-2024
     * @Parameter
     *  - recordId	    : Account Record Id
    **/ 
    private static Map<String, Object> getConfirmInit(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        Account acc = [
            SELECT Id
                    , SalesDistrict__c
                    , CustomerSystem__c
                    , IsBVC__c  
                    , CountryLookup__c
                    , CountryLookup__r.CountryCode__c
            FROM Account 
            WHERE Id = :recordId 
            LIMIT 1
        ];

        if(acc.CountryLookup__r.CountryCode__c == 'KR') {
            resMap.put('isKorea', true);
        } else {
            resMap.put('isKorea', false);
        }

        if(acc.CustomerSystem__c != null) {
            resMap.put('customerSystem', acc.CustomerSystem__c);
        } else {
            resMap.put('customerSystem', null);
        }

        if(acc.IsBVC__c == 'Y') {
            resMap.put('isBVC', true);
        } else {
            resMap.put('isBVC', false);
        }

        return resMap;
    }

    /**
     * @Description
     * 	- 타 대리점 주문 이력 확인
     * @author Hanyeong Choi | 06-18-2024
     * @Parameter
     *  - accountId	    : Account Record Id
    **/ 
    private static List<OrderInfoWrapper> getOrderList(String accountId) {
        List<OrderInfoWrapper> result = new List<OrderInfoWrapper>();

        List<Order> orderList = [
            SELECT Id
                    , OrderNumber
                    , CreatedDate
                    , Status
                    , Owner__r.Account.Name
                    , ReqDeliveryDate__c
                    , (
                        SELECT Product2.Name
                        FROM OrderItems
                        LIMIT 1
                    )
            FROM Order
            WHERE AccountId = :accountId
            ORDER BY CreatedDate DESC
        ];

        if(!orderList.isEmpty()) {
            for(Order o : orderList) {
                OrderInfoWrapper ow = new OrderInfoWrapper();
                ow.orderOwner       = o.Owner__r.Account.Name;
                ow.OrderNumber      = o.OrderNumber;
                ow.orderCreatedDate = o.CreatedDate.format('yyyy-MM-dd HH:mm:ss');
                ow.orderReqDeliveryDate = o.ReqDeliveryDate__c;
                ow.orderStatus      = o.Status;

                if(!o.OrderItems.isEmpty()) {
                    for(OrderItem oi : o.OrderItems) {
                        ow.orderItem = oi.Product2.Name;
                    }
                } else {
                    ow.orderItem = null;
                }
                result.add(ow);
            }
        }
        return result;
    }

    /**
     * @Description
     * 	- DNS_RequestToUseCustomer__c 오브젝트의 레코드 Init Component
     * @author Hanyeong Choi | 07-02-2024
     * @Parameter
     *  - recordId	    : DNS_RequestToUseCustomer__c 오브젝트의 Record Id
    **/ 
    private static Map<String, Object> getInitRequestToUseCuetomer(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            DNS_RequestToUseCustomer__c rtuc = [
                SELECT Id
                        , TargetAccount__c
                FROM DNS_RequestToUseCustomer__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            if(rtuc.TargetAccount__c != null) {
                List<Account> acc = [
                    SELECT Id
                            , SalesDistrict__c
                            , CustomerSystem__c
                            , CustomerSystemStartDate__c
                            , CustomerSystemEndDate__c
                            , IsBVC__c
                            , BVCDealer__c
                            , BVCStartDate__c
                            , BVCEndDate__c
                            , CountryLookup__c
                            , CountryLookup__r.CountryCode__c
                    FROM Account
                    WHERE Id = :rtuc.TargetAccount__c
                    LIMIT 1
                ];

                if(!acc.isEmpty()) {
                    if(acc[0].CountryLookup__r.CountryCode__c == 'KR') {
                        resMap.put('isKorea', true);
                    } else {
                        resMap.put('isKorea', false);
                    }
                    resMap.put('orderList', getOrderList(acc[0].Id));

                    if(acc[0].CustomerSystem__c != null) {
                        resMap.put('customerSystem',    acc[0].CustomerSystem__c);
                        resMap.put('csStartDate',       acc[0].CustomerSystemStartDate__c);
                        resMap.put('csEndDate',         acc[0].CustomerSystemEndDate__c);
                    } else {
                        resMap.put('customerSystem', null);
                    }

                    if(acc[0].IsBVC__c == 'Y') {
                        resMap.put('isBVC', true);
                        resMap.put('BVCDealer',     acc[0].BVCDealer__c);
                        resMap.put('BVCStartDate',  acc[0].BVCStartDate__c);
                        resMap.put('BVCEndDate',    acc[0].BVCEndDate__c);
                    } else {
                        resMap.put('isBVC', false);
                    }
                }
            }
            
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resMap.put('flag', 'fail');
        }
        return resMap;
    }

    /* Sales Area Data 필수값 체크 */
    private static List<SalesAreaFieldCheckWrapper> checkSalesAreaDataRequired(List<SalesAreaData__c> sadList, Boolean isPortal) {
        List<SalesAreaFieldCheckWrapper> result = new List<SalesAreaFieldCheckWrapper>();
        for(SalesAreaData__c sad : sadList) {
            if(isPortal) {
                if(
                    // sad.Currency__c             == null ||
                    sad.ShippingConditions__c   == null ||
                    sad.Incoterms__c            == null ||
                    sad.TermsOfPayment__c       == null 
                ) {
                    SalesAreaFieldCheckWrapper sadWrapper = new SalesAreaFieldCheckWrapper();
                    sadWrapper.checkResult = false;
                    sadWrapper.name                 = sad.Name;
                    // sadWrapper.currencyField        = sad.Currency__c           != null ? true : false;
                    sadWrapper.shippingConditions   = sad.ShippingConditions__c != null ? true : false;
                    sadWrapper.incoterms            = sad.Incoterms__c          != null ? true : false;
                    sadWrapper.termsOfPayment       = sad.TermsOfPayment__c     != null ? true : false;
                    sadWrapper.district             = true;
                    sadWrapper.office               = true;
    
                    result.add(sadWrapper);
                } else {
                    SalesAreaFieldCheckWrapper sadWrapper = new SalesAreaFieldCheckWrapper();
                    sadWrapper.checkResult = true;
                    result.add(sadWrapper);
                }
            } else {
                if(
                    // sad.Currency__c             == null ||
                    sad.ShippingConditions__c   == null ||
                    sad.Incoterms__c            == null ||
                    sad.TermsOfPayment__c       == null ||
                    sad.SalesDistrict__c        == null ||
                    sad.SalesOffice__c          == null
                ) {
                    SalesAreaFieldCheckWrapper sadWrapper = new SalesAreaFieldCheckWrapper();
                    sadWrapper.checkResult = false;
                    sadWrapper.name                 = sad.Name;
                    // sadWrapper.currencyField        = sad.Currency__c           != null ? true : false;
                    sadWrapper.shippingConditions   = sad.ShippingConditions__c != null ? true : false;
                    sadWrapper.incoterms            = sad.Incoterms__c          != null ? true : false;
                    sadWrapper.termsOfPayment       = sad.TermsOfPayment__c     != null ? true : false;
                    sadWrapper.district             = sad.SalesDistrict__c      != null ? true : false;
                    sadWrapper.office               = sad.SalesOffice__c        != null ? true : false;
    
                    result.add(sadWrapper);
                } else {
                    SalesAreaFieldCheckWrapper sadWrapper = new SalesAreaFieldCheckWrapper();
                    sadWrapper.checkResult = true;
                    result.add(sadWrapper);
                }
            }
        }
        return result;
    }

    /**
     * @Description
     * 	- 사업자등록번호 숫자만 뽑기
     * @author Hanyeong Choi | 07-10-2024
     * @Parameter
     *  - input         : Account의 BusinessNumber__c
    **/ 
    private static String extractNumbers(String input) {
        String numericString = '';
        Pattern p = Pattern.compile('\\d+');
        Matcher m = p.matcher(input);

        while (m.find()) {
            numericString += m.group();
        }

        return numericString;
    }

    /* 포탈) Account 정보 조회 */
    private static portalAccountInfo getPortalAccountInfo(String recordId) {
        Account acc = [
            SELECT  Id
                    , Name
                    , RecordType.Name
                    , Representative__c
                    , CreatedBy.Name
                    , CreatedBy.Id
                    , SalesDistrict__c
                    , CountryLookup__c
                    , CountryLookup__r.CountryCode__c
            FROM Account 
            WHERE Id = :recordId 
            LIMIT 1
        ];

        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = Schema.SObjectType.Account.getRecordTypeInfosById();
        String recordTypeLabel = recordTypeInfoMap.get(acc.RecordTypeId).getName();

        portalAccountInfo pai = new portalAccountInfo();
        pai.userId          = acc.CreatedBy.Id;
        pai.accName         = acc.Name;
        pai.recordTypeName  = recordTypeLabel;
        pai.recordType      = acc.RecordType.Name;
        pai.representative  = acc.Representative__c;
        pai.accOwner        = acc.CreatedBy.Name;
        pai.country         = acc.CountryLookup__r.CountryCode__c;

        return pai;
    }

    /* 유저 정보 */
    private static Map<String, String> getUserInfo_portalHeader() {
        Map<String, String> resMap = new Map<String, String>();
        User user = [SELECT Id, Profile.Name, LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        resMap.put('language', user.LanguageLocaleKey);
        resMap.put('profileName', user.Profile.Name);
        return resMap;
    }

    /* 글로벌 팀원에게 알림 */
    private static void globalDealerNotification(Account acc, User u) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'GlobalDealerConvertTradeAlert' LIMIT 1];
        List<User> uList = DN_WithoutSharingClass.getProfileUser('영업 글로벌 팀원');
        for(User user : uList) {
            receiver.add(user.Id);
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(u.Account.Name);
                history.elementList.add(acc.Name);
                history.alertID         = am[0].Id;
                history.targetID        = acc.Id;
                history.receiverforID   = receiver;
                history.alertLanguage   = 'ko';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 글로벌 팀원에게 이메일 */
    private static void globalDealerEmail(Account acc, User u) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'GlobalDealerConvertTradeAlert' LIMIT 1];
        List<User> uList = DN_WithoutSharingClass.getProfileUser('영업 글로벌 팀원');
        if(!uList.isEmpty()) {
            for(User user : uList) {
                receiver.add(user.Email);
            }
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Email';
                history.elementList.add(u.Account.Name);
                history.elementList.add(acc.Name);
                history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + acc.Id);
                history.alertID         = am[0].Id;
                history.targetID        = acc.Id;
                history.receiverforEmail   = receiver;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 전환 요청 알람 */
    public static void RequestConvertNoti_kr(Account acc) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Convert Trade Customer Request Alert' LIMIT 1];
        User user = [SELECT Id, ManagerId, Profile.Name, IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(Test.isRunningTest()) {
            receiver.add(user.Id);
        } else {
            if(user.IsPortalEnabled || user.Profile.Name.contains('직영')) {
                receiver.add(user.ManagerId);
            } else {
                receiver.add(user.Id);
            }
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(acc.Name);
                history.alertID         = am[0].Id;
                history.targetID        = acc.Id;
                history.receiverforID   = receiver;
                history.alertLanguage   = 'ko';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 전환 요청 알람 */
    public static void RequestConvertNoti_global(Account acc) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiverEn = new Set<Id>();
        System.debug('@@UserInfo:'+UserInfo.getUserId());

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Convert Trade Customer Request Alert' LIMIT 1];
        User user = [SELECT Id, ManagerId, Profile.Name, IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(Test.isRunningTest()) {
            receiverEn.add(user.Id);
        } else {
            if(user.IsPortalEnabled || user.Profile.Name.contains('직영')) {
                receiverEn.add(user.ManagerId);
            } else {
                receiverEn.add(user.Id);
            }
        }

        if(!am.isEmpty()) {
            if(!receiverEn.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(acc.Name);
                history.alertID         = am[0].Id;
                history.targetID        = acc.Id;
                history.receiverforID   = receiverEn;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 전환 요청 이메일 */
    public static void RequestConvertEmail_kr(Account acc) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Convert Trade Customer Request Alert' LIMIT 1];
        User user = [SELECT Id, Email, ManagerId, Profile.Name, IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(Test.isRunningTest()) {
            receiver.add(user.Email);
        } else {
            if(user.IsPortalEnabled || user.Profile.Name.contains('직영')) {
                User u = DN_WithoutSharingClass.getUserEmail(user.ManagerId);
                receiver.add(u.Email);
            } else {
                User u = DN_WithoutSharingClass.getUserEmail(user.Id);
                receiver.add(u.Email);
            }
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Email';
                history.elementList.add(acc.Name);
                history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + acc.Id);
                history.alertID         = am[0].Id;
                history.targetID        = acc.Id;
                history.receiverforEmail   = receiver;
                history.alertLanguage   = 'ko';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 전환 요청 이메일 */
    public static void RequestConvertEmail_global(Account acc) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiverEn = new List<String>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Convert Trade Customer Request Alert' LIMIT 1];
        User user = [SELECT Id, Email, ManagerId, Profile.Name, IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(Test.isRunningTest()) {
            receiverEn.add(user.Email);
        } else {
            if(user.IsPortalEnabled || user.Profile.Name.contains('직영')) {
                User u = DN_WithoutSharingClass.getUserEmail(user.ManagerId);
                receiverEn.add(u.Email);
            } else {
                User u = DN_WithoutSharingClass.getUserEmail(user.Id);
                receiverEn.add(u.Email);
            }
        }

        if(!am.isEmpty()) {
            if(!receiverEn.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Email';
                history.elementList.add(acc.Name);
                history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + acc.Id);
                history.alertID         = am[0].Id;
                history.targetID        = acc.Id;
                history.receiverforEmail   = receiverEn;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * @Description
     * 	- 딜러포탈/대리점재고관리에서 사용하기 위해 URL확인
     * @author iltae.seo | 12-05-2024
     * @return 
     *  - recordId	    : List<String>
    **/ 
    @AuraEnabled
    public static List<String> getSiteUrlList(){
        try {
            set<String> ids = new set<String>();
            List<String> siteUrlList = new List<String>();
            List<Site> siteList = [select Id, Name,SiteType from Site where Status ='Active' ];
            for(Site si :siteList) {
                ids.add(si.Id);
            }
            List<SiteDetail> siteDetailList = [select Id, DurableId, IsRegistrationEnabled, SecureUrl from SiteDetail where DurableId IN : ids];
            for(SiteDetail detail : siteDetailList) {
                siteUrlList.add(detail.SecureUrl);
            }
            return siteUrlList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 주소 선택 후, DealerCustomer Update
     * @author iltae.seo | 12-05-2024
     * @Parameter
     *  - recordId	        : String recordId
     *  - address	        : 선택한 address 정보
    **/ 
    @AuraEnabled
    public static Map<String, String> setDealerCustomerAddress(String recordId, Map<String, Object> address, Object detailInfo) {
        Map<String, String> resMap = new Map<String, String>();
        try {
            DealerCustomer__c dealer = [ select Address__c,Address__Street__s,Address__PostalCode__s,sggNm__c,Address__City__s,Address__CountryCode__s,Address__StateCode__s from DealerCustomer__c where Id=:recordId limit 1];
            dealer.Address__Street__s           = (String) address.get('roadAddr') + '\n' + detailInfo;
            dealer.Address__PostalCode__s       = (String) address.get('zipNo');
            dealer.sggNm__c                     = (String) address.get('siNm') + ' ' + (String) address.get('sggNm');
            dealer.Address__City__s             = (String) address.get('siNm');
            dealer.Address__CountryCode__s      = 'KR';
            dealer.Address__StateCode__s        = '';
            update dealer;
            resMap.put('flag', 'success');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return resMap;
    }

    /* Order정보 wrapper */
    public class OrderInfoWrapper {
        @AuraEnabled public String  orderOwner              {get; set;} // Order의 Owner__c 필드값
        @AuraEnabled public String  orderNumber             {get; set;} // Order의 OrderNumber 필드값
        @AuraEnabled public String  orderCreatedDate        {get; set;} // Order의 CreatedDate 필드값
        @AuraEnabled public Date    orderReqDeliveryDate    {get; set;} // Order의 ReqDeliveryDate__c 필드값
        @AuraEnabled public String  orderStatus             {get; set;} // Order의 Status 필드값
        @AuraEnabled public String  orderItem               {get; set;} // Order의 Item

        public OrderInfoWrapper() {}

        public OrderInfoWrapper(String orderOwner, String orderNumber, String orderCreatedDate, Date orderReqDeliveryDate, String orderStatus, String orderItem) {
            this.orderOwner             = orderOwner;
            this.orderNumber            = orderNumber;
            this.orderCreatedDate       = orderCreatedDate;
            this.orderReqDeliveryDate   = orderReqDeliveryDate;
            this.orderStatus            = orderStatus;
            this.orderItem              = orderItem;
        }
    }

    /* Field 확인 wrapper */
    public class FieldCheckWrapper {
        @AuraEnabled public Boolean isKorea                     {get; set;} // 한국 영업인지 확인
        @AuraEnabled public Boolean checkResult                 {get; set;} // Convert 하기 위한 필수 필드 값 확인 결과
        @AuraEnabled public Boolean businessNumber              {get; set;} // Account의 BusinessNumber__c 필드값
        @AuraEnabled public Boolean production                  {get; set;} // Account의 Production__c 필드값
        @AuraEnabled public Boolean isBusinessLicense           {get; set;} // Account의 IsBusinessLicense__c 필드값
        @AuraEnabled public Boolean residentRegistrationNumber  {get; set;} // Account의 ResidentRegistrationNumber__c 필드값
        @AuraEnabled public Boolean isTotalBusinessNumber       {get; set;} // businessNumber, isBusinessLicense, residentRegistrationNumber 전부 null이면 false
        @AuraEnabled public Boolean isBVC                       {get; set;} // BVC 혹은 고객 제도에 값이 존재하면 true
        @AuraEnabled public Boolean shippingAddress             {get; set;} // Account의 ShippingAddress 필드값
        @AuraEnabled public Boolean typeOfBusiness              {get; set;} // Account의 TypeOfBusiness__c 필드값
        @AuraEnabled public Boolean typeOfIndustry              {get; set;} // Account의 TypeOfIndustry__c 필드값
        @AuraEnabled public Boolean country                     {get; set;} // Account의 CountryLookup__r.CountryCode__c 필드값 (global)
        @AuraEnabled public Boolean region                      {get; set;} // Account의 RegionLookup__r.RegionCode__c 필드값 

        public FieldCheckWrapper() {}
    }

    /* Sales Area Data 필드 확인 wrapper */
    public class SalesAreaFieldCheckWrapper {
        @AuraEnabled public Boolean checkResult         {get; set;}
        @AuraEnabled public String  name                {get; set;}
        @AuraEnabled public Boolean currencyField       {get; set;}
        @AuraEnabled public Boolean shippingConditions  {get; set;}
        @AuraEnabled public Boolean incoterms           {get; set;}
        @AuraEnabled public Boolean termsOfPayment      {get; set;}
        @AuraEnabled public Boolean district            {get; set;}
        @AuraEnabled public Boolean office              {get; set;}

        public SalesAreaFieldCheckWrapper() {}
    }

    /* 포탈 Account 정보 wrapper */
    public class portalAccountInfo {
        @AuraEnabled public String accName          {get; set;}
        @AuraEnabled public String recordTypeName   {get; set;}
        @AuraEnabled public String recordType       {get; set;}
        @AuraEnabled public String representative   {get; set;}
        @AuraEnabled public String accOwner         {get; set;}
        @AuraEnabled public String userId           {get; set;}
        @AuraEnabled public String country          {get; set;}

        public portalAccountInfo() {}
    }
}