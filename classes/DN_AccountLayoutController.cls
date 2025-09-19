/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-22-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   10-16-2024   Hanyeong Choi   Initial Version
**/
public with sharing class DN_AccountLayoutController {
    private static final Id prospectCustomerRT                  = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id tradeCustomerRT                     = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
    private static final Id shipToPartyRT                       = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipToParty').getRecordTypeId();
    private static final Id DNSACustomerRT                      = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();
    private static final Id dealerRT                            = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final User currentUser                       = setCurrentUser();
    
    /* 유저 정보 확인 */
    @AuraEnabled
    public static Map<String, Object> getUserRecordType() {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            List<UserAppInfo> userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
            if(!userAppInfo.isEmpty()) {
                AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition Where DurableId = :userAppInfo[0].AppDefinitionId LIMIT 1];
                resMap.put('appName', appDefinition.Label);
            }

            Map<String, String> valueForName = new Map<String, String>();

            Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
            
            for (String recordTypeName : recordTypeInfoMap.keySet()) {
                Schema.RecordTypeInfo recordTypeInfo = recordTypeInfoMap.get(recordTypeName);
                if (recordTypeInfo.isAvailable() && (recordTypeName != 'Master' && recordTypeName != '마스터' )) {
                    valueForName.put(recordTypeName, recordTypeInfo.developername);
                }
            }

            ListView lv =  [SELECT Id FROM ListView WHERE SobjectType = 'Account' AND DeveloperName = 'RecentlyViewedAccounts' LIMIT 1];
            
            resMap.put('profile', currentUser.Profile.Name);
            resMap.put('recordType', valueForName);
            resMap.put('listId', lv.Id);
            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- Account List View에 New Account 버튼을 누르고 Next버튼을 누를 때 Init
     * @author Hanyeong Choi | 10-15-2024
     * @Parameter
     *  - objectName        : Account
     *  - recordTypeName    : Account의 RecordType Name
    **/ 
    @AuraEnabled
    public static Map<String, Object> getNextInit(String objectName, String recordTypeName) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            result.put('getRecordTypeId',       getRecordTypeId(recordTypeName));
            result.put('getUserCountry',        getUserCountry());
            result.put('getUserCurrencyCode',   getUserCurrencyCode());
            
            return result;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- Map정보를 바탕으로 Account 레코드 insert
     * @author Hanyeong Choi | 10-15-2024
     * @Parameter
     *  - fieldMap      : Account 생성 모달에서 입력한 각 key 필드명, value 필드값 Map
    **/ 
    @AuraEnabled
    public static Map<String, String> saveAccountRecord(String objectName, Map<String, Object> fieldMap, String recordTypeId) {
        Map<String, String> result = new Map<String, String>();
        try {
            String check = validationInsertAccount(Id.valueOf(recordTypeId), fieldMap);
            System.debug('check ::: ' + check);
            Boolean ifCheck = false;
            Account newRecord = new Account();

            if(check == 'success') {
                if(recordTypeId == prospectCustomerRT) {
                    IF_ERP_Account_Classes.IF_ACCOUNT_001_Res erpResponse = interfaceAccount001(fieldMap);

                    if (erpResponse.O_RECODE == 'S') { // ERP 응답 성공 시 진행
                        ifCheck = true;
                        newRecord.put('CustomerCode__c', erpResponse.O_KUNNR);
                    } else {
                        if(erpResponse.O_DUP == 'X') {
                            result.put('code', 'error');
                            result.put('message', System.Label.DNS_ACC_T_ERPDUPL);
                        } else {
                            String m = 'ERP validation failed: ' + (erpResponse.O_REMSG != null ? erpResponse.O_REMSG : 'Unknown error');
                            result.put('code', 'error');
                            result.put('message', m);
                        }
                        return result;
                    }
                } else if(recordTypeId == shipToPartyRT) {
                    IF_ERP_Account_Classes.IF_ACCOUNT_004_Res erpResponse = interfaceAccount004(fieldMap);

                    if (erpResponse.O_RECODE == 'S') { // ERP 응답 성공 시 진행
                        ifCheck = true;
                        newRecord.put('CustomerCode__c', erpResponse.O_KUNNR);
                    } else {
                        if(erpResponse.O_DUP == 'X') {
                            result.put('code', 'error');
                            result.put('message', System.Label.DNS_ACC_T_ERPDUPL);
                        } else {
                            String m = 'ERP validation failed: ' + (erpResponse.O_REMSG != null ? erpResponse.O_REMSG : 'Unknown error');
                            result.put('code', 'error');
                            result.put('message', m);
                        }
                        return result;
                    }
                } else if(recordTypeId == tradeCustomerRT) {
                    IF_ERP_Account_Classes.IF_ACCOUNT_012_Res erpResponse = interfaceAccount012(fieldMap);

                    if (erpResponse.O_RECODE == 'S') { // ERP 응답 성공 시 진행
                        ifCheck = true;
                        newRecord.put('CustomerCode__c', erpResponse.O_KUNNR);
                    } else {
                        if(erpResponse.O_DUP == 'X') {
                            result.put('code', 'error');
                            result.put('message', System.Label.DNS_ACC_T_ERPDUPL);
                        } else {
                            String m = 'ERP validation failed: ' + (erpResponse.O_REMSG != null ? erpResponse.O_REMSG : 'Unknown error');
                            result.put('code', 'error');
                            result.put('message', m);
                        }
                        return result;
                    }
                } else if(recordTypeId == DNSACustomerRT) {
                    IF_ERP_Account_Classes.IF_ACCOUNT_015_Res erpResponse = interfaceAccount015(fieldMap);

                    if (erpResponse.O_RETURN.TYPE == 'S') { // ERP 응답 성공 시 진행
                        ifCheck = true;
                        newRecord.put('CustomerCode__c', erpResponse.O_PERSON);
                    } else {
                        if(erpResponse.O_RETURN.TYPE == 'X') {
                            result.put('code', 'error');
                            result.put('message', System.Label.DNS_ACC_T_ERPDUPL);
                        } else {
                            String m = 'ERP validation failed: ' + (erpResponse.O_RETURN.MESSAGE != null ? erpResponse.O_RETURN.MESSAGE : 'Unknown error');
                            result.put('code', 'error');
                            result.put('message', m);
                        }
                        return result;
                    }
                }
            }

            if (
                (check == 'success' && (ifCheck))
                || check != 'success'
                // || (recordTypeId == DNSACustomerRT)
            ) {
            
                newRecord.put('RecordTypeId', Id.valueOf(recordTypeId));
                for (String fieldName : fieldMap.keySet()) {
                    String fieldType = getFieldType(fieldName);
    
                    if(fieldType != 'formula' && fieldMap.get(fieldName) != null) {
                        switch on fieldType {
                            when 'LONG', 'INTEGER'{
                                String IntegerValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Integer.valueOf(IntegerValue));
                            }
                            when 'DOUBLE', 'CURRENCY', 'PERCENT'{
                                String decimalValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Double.valueOf(decimalValue));
                            }
                            when 'DATE' {
                                String dateValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Date.valueOf(dateValue));
                            }
                            when 'DATETIME'  {
                                String datetimeValue = (String) fieldMap.get(fieldName);
        
                                if (datetimeValue.endsWith('Z')) {
                                    datetimeValue = datetimeValue.substring(0, datetimeValue.length() - 1);
                                }
                                newRecord.put(fieldName, Datetime.valueOf(datetimeValue.replace('T', ' ')));
                            }
                            when 'BOOLEAN' {
                                String booleanValue = String.valueOf(fieldMap.get(fieldName));

                                if (fieldName == 'CareOfRigger__c') {
                                    if(Boolean.valueOf(booleanValue)) {
                                        newRecord.put('AccountGroup__c', '1130');
                                    } else {
                                        newRecord.put('AccountGroup__c', '1030');
                                    }
                                }
                                newRecord.put(fieldName, Boolean.valueOf(booleanValue));
                            }
                            when 'ADDRESS' {
                                if (fieldName == 'ShippingAddress') {
                                    Object addressObject = fieldMap.get(fieldName);
                                    Map<Object, Object> address = (Map<Object, Object>) addressObject;
                        
                                    if (address.get('ShippingStreet') != null) {
                                        newRecord.ShippingStreet = (String) address.get('ShippingStreet');
                                    }
                                    if (address.get('ShippingCity') != null) {
                                        newRecord.ShippingCity = (String) address.get('ShippingCity');
                                    }
                                    if (address.get('ShippingState') != null) {
                                        newRecord.ShippingState = (String) address.get('ShippingState');
                                    }
                                    if (address.get('ShippingPostalCode') != null) {
                                        newRecord.ShippingPostalCode = (String) address.get('ShippingPostalCode');
                                    }
                                    if (address.get('ShippingCountry') != null) {
                                        newRecord.ShippingCountry = (String) address.get('ShippingCountry');
                                    }
                                }
                            }
                            when else {
                                if (fieldName != 'AccountGroup__c') {
                                    newRecord.put(fieldName, fieldMap.get(fieldName));
                                }
                            }
                        }
                    }
                }
    
                insert newRecord;

                String baseUrl = URL.getOrgDomainURL().toExternalForm();
                String recordUrl = baseUrl + '/' + newRecord.Id;
                // result = recordUrl;
                result.put('code', 'success');
                result.put('message', recordUrl);
                // result = newRecord.Id;
                return result;
            }

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            String m = e.getMessage().substringAfter('error:');
            result.put('code', 'error');
            result.put('message', m);
        }
        return result;
    }

    /* 고객사 조회 */
    @AuraEnabled
    public static List<SearchWrapper> searchAccount(String keyword) {
        try {
            keyword = '%' + keyword + '%';
            return DN_WithoutSharingClass.searchAccount(keyword);
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* 고객사 권한 확인 */
    @AuraEnabled
    public static String checkShareAcc(String recordId) {
        try {
            List<Account> acc = [SELECT Id, OwnerId FROM Account WHERE Id = :recordId LIMIT 1];
            List<DNS_RequestToUseCustomer__c> rtu = [SELECT Id FROM DNS_RequestToUseCustomer__c WHERE TargetAccount__c = :recordId AND FM_CreatedByDealer__c = :currentUser.Account.Name LIMIT 1];
            if(!acc.isEmpty()) {
                return 'auth';
            } else if (!rtu.isEmpty()) {
                return 'already';
            }
            return 'success';
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* 사용요청 생성 */
    @AuraEnabled
    public static String insertRequestCustomer(String reason, String selectedId) {
        try {
            DNS_RequestToUseCustomer__c ruc = new DNS_RequestToUseCustomer__c();
            ruc.TargetAccount__c = selectedId;
            ruc.RequestReason__c = reason;
            String result = DN_WithoutSharingClass.insertRQU(ruc);
            // insert ruc;

            if(result == 'success') {
                String baseUrl = URL.getOrgDomainURL().toExternalForm();
                String recordUrl = baseUrl + '/' + ruc.Id;
                return recordUrl;
            } else {
                System.debug('insertRQU Error ::: ' + result);
                return 'Error';
            }
            
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            return 'Error';
        }
    }

    /* 유저 국가 조회 */
    private static String getUserCountry() {
        return [SELECT Country__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Country__c;
    }

    /* 유저 통화 조회 */
    private static String getUserCurrencyCode() {
        return [SELECT CurrencyIsoCode FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].CurrencyIsoCode;
    }

    /* 잠재고객 생성 */
    private static IF_ERP_Account_Classes.IF_ACCOUNT_001_Res interfaceAccount001(Map<String, Object> fieldMap) {
        IF_ERP_Account_Classes.IF_ACCOUNT_001_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_001_Req();

        String numericBusinessNumber    = '';
        if(fieldMap.get('BusinessNumber__c') != '' && fieldMap.get('BusinessNumber__c') != null) {
            String businessNumber           = (String) fieldMap.get('BusinessNumber__c');
    
            Pattern p = Pattern.compile('\\d+');
            Matcher m = p.matcher(businessNumber);
    
            while (m.find()) {
                numericBusinessNumber += m.group();
            }
        }

        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE Id = :(String) fieldMap.get('CountryLookup__c') LIMIT 1];
        Region__c region = null;
        if(fieldMap.get('RegionLookup__c') != null) {
            region = [SELECT Id, RegionCode__c FROM Region__c WHERE Id = :(String) fieldMap.get('RegionLookup__c') LIMIT 1];
        }
            
            erpParameters.I_ANRED      = 'Company';
            erpParameters.I_NAME1      = ((String) fieldMap.get('Name')).length() > 35 ? ((String) fieldMap.get('Name')).substring(0,35) : ((String) fieldMap.get('Name'));
            erpParameters.I_NAME      = (String) fieldMap.get('Representative__c');
            erpParameters.I_NAME3      = (String) fieldMap.get('AccountNameEnglish__c');
            erpParameters.I_SORT1      = (String) fieldMap.get('SearchTerm__c');
            erpParameters.I_COUNTRY    = country.CountryCode__c;
            erpParameters.I_REGION     = fieldMap.get('RegionLookup__c') != null ? region.RegionCode__c : '';
            erpParameters.I_PSTLZ      = (String) fieldMap.get('ShippingPostalCode');

            if((String) fieldMap.get('ShippingCity') != '' && (String) fieldMap.get('ShippingCity') != null) {
                Integer maxLength = 40;
                String street = (String) fieldMap.get('ShippingCity');
                erpParameters.I_CITY1 = street.length() > maxLength 
                    ? street.substring(0, maxLength) 
                    : street;
    
                String remainingText = street.length() > maxLength 
                    ? street.substring(maxLength) 
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

            erpParameters.I_STREET     = (String) fieldMap.get('ShippingStreet');
            erpParameters.I_TEL_NUMBER = (String) fieldMap.get('Phone');
            erpParameters.I_MOB_NUMBER = (String) fieldMap.get('Mobile__c');
            erpParameters.I_FAX_NUMBER = (String) fieldMap.get('Fax');
            erpParameters.I_SMTP_ADDR  = (String) fieldMap.get('Website');
            erpParameters.I_KATR1      = (String) fieldMap.get('MainCategory__c');
            erpParameters.I_KATR2      = (String) fieldMap.get('SubCategory__c');
            erpParameters.I_KATR3      = (String) fieldMap.get('IsTooling__c');
            erpParameters.I_J_1KFTBUS  = (String) fieldMap.get('TypeOfBusiness__c');
            erpParameters.I_J_1KFTIND  = (String) fieldMap.get('TypeOfIndustry__c');
            erpParameters.I_VKBUR      = currentUser.SalesOffice__c;
            erpParameters.I_BZIRK      = currentUser.SalesDistrict__c;
            if(country.CountryCode__c == 'KR') {
                erpParameters.I_TAXNUMBER1 = numericBusinessNumber;
            } else {
                erpParameters.I_TAXNUMBER1 = (String) fieldMap.get('BusinessNumber__c');
            }

            if(currentUser.AccountId != null) {
                erpParameters.I_KTONR      = currentUser.Account.CustomerCode__c;
            } else {
                erpParameters.I_KTONR2      = currentUser.CustomerCode__c;
            }
            erpParameters.I_VKORG      = currentUser.SalesOrganization__c;
            erpParameters.I_VTWEG      = currentUser.DistributionChannel__c;
            erpParameters.I_SPART      = currentUser.Division__c;
            erpParameters.I_DEALER     = currentUser.AccountId != null ? currentUser.Account.CustomerCode__c : currentUser.CustomerCode__c;
            erpParameters.I_SPRAS      = (String) fieldMap.get('Language__c');
            erpParameters.I_EMAIL      = (String) fieldMap.get('Email__c');
            erpParameters.I_WAERS      = (String) fieldMap.get('CurrencyIsoCode');

            IF_ERP_Account erpService = new IF_ERP_Account();
            return erpService.IF_ACCOUNT_001(erpParameters);
    }

    /* Ship to party 생성 */
    private static IF_ERP_Account_Classes.IF_ACCOUNT_004_Res interfaceAccount004(Map<String, Object> fieldMap) {
        IF_ERP_Account_Classes.IF_ACCOUNT_004_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_004_Req();

        String numericBusinessNumber    = '';
        if(fieldMap.get('BusinessNumber__c') != '' && fieldMap.get('BusinessNumber__c') != null) {
            String businessNumber           = (String) fieldMap.get('BusinessNumber__c');
    
            Pattern p = Pattern.compile('\\d+');
            Matcher m = p.matcher(businessNumber);
    
            while (m.find()) {
                numericBusinessNumber += m.group();
            }
        }

        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE Id = :(String) fieldMap.get('CountryLookup__c') LIMIT 1];
        Region__c region = [SELECT Id, RegionCode__c FROM Region__c WHERE Id = :(String) fieldMap.get('RegionLookup__c') LIMIT 1];
            
            erpParameters.I_ANRED      = 'Company';
            // erpParameters.I_NAME1      = (String) fieldMap.get('Name');
            erpParameters.I_NAME1      = ((String) fieldMap.get('Name')).length() > 35 ? ((String) fieldMap.get('Name')).substring(0,35) : ((String) fieldMap.get('Name'));
            erpParameters.I_NAME3      = (String) fieldMap.get('AccountNameEnglish__c');
            erpParameters.I_NAME      = (String) fieldMap.get('Representative__c');
            erpParameters.I_SORT1      = (String) fieldMap.get('SearchTerm__c');
            erpParameters.I_COUNTRY    = country.CountryCode__c;
            erpParameters.I_REGION     = region.RegionCode__c;
            erpParameters.I_PSTLZ      = (String) fieldMap.get('ShippingPostalCode');

            if((String) fieldMap.get('ShippingCity') != '' && (String) fieldMap.get('ShippingCity') != null) {
                Integer maxLength = 40;
                String street = (String) fieldMap.get('ShippingCity');
                erpParameters.I_CITY1 = street.length() > maxLength 
                    ? street.substring(0, maxLength) 
                    : street;
    
                String remainingText = street.length() > maxLength 
                    ? street.substring(maxLength) 
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

            erpParameters.I_STREET     = (String) fieldMap.get('ShippingStreet');
            erpParameters.I_TEL_NUMBER = (String) fieldMap.get('Phone');
            erpParameters.I_MOB_NUMBER = (String) fieldMap.get('Mobile__c');
            erpParameters.I_FAX_NUMBER = (String) fieldMap.get('Fax');
            erpParameters.I_SMTP_ADDR  = (String) fieldMap.get('Website');
            erpParameters.I_KATR1      = (String) fieldMap.get('MainCategory__c');
            erpParameters.I_KATR2      = (String) fieldMap.get('SubCategory__c');
            erpParameters.I_KATR3      = (String) fieldMap.get('IsTooling__c');
            erpParameters.I_J_1KFTBUS  = (String) fieldMap.get('TypeOfBusiness__c');
            erpParameters.I_J_1KFTIND  = (String) fieldMap.get('TypeOfIndustry__c');
            erpParameters.I_VKBUR      = currentUser.SalesOffice__c;
            erpParameters.I_BZIRK      = currentUser.SalesDistrict__c;
            
            if(country.CountryCode__c == 'KR') {
                erpParameters.I_TAXNUMBER1 = numericBusinessNumber;
            } else {
                erpParameters.I_TAXNUMBER1 = (String) fieldMap.get('BusinessNumber__c');
            }
            erpParameters.I_VKORG      = currentUser.SalesOrganization__c;
            erpParameters.I_VTWEG      = currentUser.DistributionChannel__c;
            erpParameters.I_SPART      = currentUser.Division__c;
            erpParameters.I_DEALER     = currentUser.AccountId != null ? currentUser.AccountId : currentUser.CustomerCode__c;
            erpParameters.I_SPRAS      = (String) fieldMap.get('Language__c');
            erpParameters.I_EMAIL      = (String) fieldMap.get('Email__c');
            erpParameters.I_WAERS      = (String) fieldMap.get('CurrencyIsoCode');

            IF_ERP_Account erpService = new IF_ERP_Account();
            return erpService.IF_ACCOUNT_004(erpParameters);
    }

    /* 실고객 생성 */
    private static IF_ERP_Account_Classes.IF_ACCOUNT_012_Res interfaceAccount012(Map<String, Object> fieldMap) {
        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE Id = :(String) fieldMap.get('CountryLookup__c') LIMIT 1];
        Region__c region = null;
        if(fieldMap.get('RegionLookup__c') != null) {
            region = [SELECT Id, RegionCode__c FROM Region__c WHERE Id = :(String) fieldMap.get('RegionLookup__c') LIMIT 1];
        }
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

        String numericBusinessNumber    = '';
        if(fieldMap.get('BusinessNumber__c') != '' && fieldMap.get('BusinessNumber__c') != null) {
            String businessNumber           = (String) fieldMap.get('BusinessNumber__c');
    
            Pattern p = Pattern.compile('\\d+');
            Matcher m = p.matcher(businessNumber);
    
            while (m.find()) {
                numericBusinessNumber += m.group();
            }
        }

        IF_ERP_Account_Classes.IF_ACCOUNT_012_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_012_Req();
            
            erpParameters.I_ANRED      = 'Company';
            erpParameters.I_NAME      = (String) fieldMap.get('Representative__c');
            erpParameters.I_NAME1      = ((String) fieldMap.get('Name')).length() > 35 ? ((String) fieldMap.get('Name')).substring(0,35) : ((String) fieldMap.get('Name'));
            // erpParameters.I_NAME1      = (String) fieldMap.get('Name');
            erpParameters.I_NAME3      = (String) fieldMap.get('AccountNameEnglish__c');
            erpParameters.I_SORT1      = (String) fieldMap.get('SearchTerm__c');
            erpParameters.I_COUNTRY    = country.CountryCode__c;
            if(fieldMap.get('RegionLookup__c') != null) {
                erpParameters.I_REGION     = region.RegionCode__c;
            }
            erpParameters.I_PSTLZ      = (String) fieldMap.get('ShippingPostalCode');

            if((String) fieldMap.get('ShippingCity') != '' && (String) fieldMap.get('ShippingCity') != null) {
                Integer maxLength = 40;
                String street = (String) fieldMap.get('ShippingCity') != '' ? (String) fieldMap.get('ShippingCity') : '';
                if(street != '') {
                    erpParameters.I_CITY1 = street.length() > maxLength 
                        ? street.substring(0, maxLength) 
                        : street;
        
                    String remainingText = street.length() > maxLength 
                        ? street.substring(maxLength) 
                        : null;
        
                    if (remainingText != null) {
                        erpParameters.I_LOCATION = remainingText.length() > maxLength 
                            ? remainingText.substring(0, maxLength) 
                            : remainingText;
                    }
                }
            }

            erpParameters.I_STREET     = (String) fieldMap.get('ShippingStreet');
            erpParameters.I_TEL_NUMBER = (String) fieldMap.get('Mobile__c');
            erpParameters.I_MOB_NUMBER = (String) fieldMap.get('Phone');
            erpParameters.I_SMTP_ADDR  = (String) fieldMap.get('Website');
            erpParameters.I_KATR1      = (String) fieldMap.get('MainCategory__c');
            erpParameters.I_KATR2      = (String) fieldMap.get('SubCategory__c');
            erpParameters.I_KATR3      = (String) fieldMap.get('IsTooling__c');
            erpParameters.I_J_1KFTBUS  = (String) fieldMap.get('TypeOfBusiness__c');
            erpParameters.I_J_1KFTIND  = (String) fieldMap.get('TypeOfIndustry__c');
            erpParameters.I_TAXNUMBER1 = numericBusinessNumber;
            if(currentUser.SalesOrganization__c != '4146' && currentUser.SalesOrganization__c != '4140') {
                erpParameters.I_BZIRK      = tcd.SalesDistrict__c;
                erpParameters.I_VKORG      = tcd.SalesOrganization__c;
                erpParameters.I_VTWEG      = tcd.DistributionChannel__c;
                erpParameters.I_SPART      = tcd.Division__c;
                erpParameters.I_SPRAS      = tcd.Language__c;
    
                erpParameters.I_KATR5      = tcd.CustomerGrp5__c;
                erpParameters.I_PLTYP      = tcd.PriceList__c;
    
                erpParameters.I_VSBED      = tcd.ShippingConditions__c;
                erpParameters.I_INCO1      = tcd.Incoterms1__c;
                erpParameters.I_INCO2      = tcd.Incoterms2__c;
                erpParameters.I_ZTERM      = tcd.TermsOfPayment__c;
                erpParameters.I_KTGRD      = tcd.AcctAssgmtGroup__c;
                erpParameters.I_WAERS      = 'KRW';
            } else {
                erpParameters.I_BZIRK      = currentUser.SalesDistrict__c;
                erpParameters.I_VKORG      = '4146';
                erpParameters.I_VKBUR      = '4146';
                erpParameters.I_VTWEG      = currentUser.DistributionChannel__c;
                erpParameters.I_SPART      = currentUser.Division__c;
                erpParameters.I_SPRAS      = 'EN';
    
                erpParameters.I_KATR5      = tcd.CustomerGrp5__c;
                erpParameters.I_PLTYP      = tcd.PriceList__c;
    
                erpParameters.I_VSBED      = tcd.ShippingConditions__c;
                erpParameters.I_INCO1      = tcd.Incoterms1__c;
                erpParameters.I_INCO2      = tcd.Incoterms2__c;
                erpParameters.I_ZTERM      = tcd.TermsOfPayment__c;
                erpParameters.I_KTGRD      = tcd.AcctAssgmtGroup__c;
                erpParameters.I_WAERS      = 'USD';

                if((String) fieldMap.get('ShippingStreet') != '' && (String) fieldMap.get('ShippingStreet') != null) {
                    Integer maxLength = 35;
                    String street = (String) fieldMap.get('ShippingStreet') != '' ? (String) fieldMap.get('ShippingStreet') : '';
                    if(street != '') {
                        erpParameters.I_NAME_CO = street.length() > maxLength 
                            ? street.substring(0, maxLength) 
                            : street;
            
                        String remainingText = street.length() > maxLength 
                            ? street.substring(maxLength) 
                            : null;
            
                        if (remainingText != null) {
                            erpParameters.I_STR_SUPPL1 = remainingText.length() > maxLength 
                                ? remainingText.substring(0, maxLength) 
                                : remainingText;
                        }
                    }
                }
            }
            erpParameters.I_EMAIL      = (String) fieldMap.get('Email__c');

            IF_ERP_Account erpService = new IF_ERP_Account();
            return erpService.IF_ACCOUNT_012(erpParameters);
    }

    /* DNSA 고객사 생성 */
    public static IF_ERP_Account_Classes.IF_ACCOUNT_015_Res interfaceAccount015(Map<String, Object> fieldMap) {
        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE Id = :(String) fieldMap.get('CountryLookup__c') LIMIT 1];
        Region__c region = null;
        if(fieldMap.get('RegionLookup__c') != null) {
            region = [SELECT Id, RegionCode__c FROM Region__c WHERE Id = :(String) fieldMap.get('RegionLookup__c') LIMIT 1];
        }

        String numericBusinessNumber    = '';
        if(fieldMap.get('BusinessNumber__c') != '' && fieldMap.get('BusinessNumber__c') != null) {
            String businessNumber           = (String) fieldMap.get('BusinessNumber__c');
    
            Pattern p = Pattern.compile('\\d+');
            Matcher m = p.matcher(businessNumber);
    
            while (m.find()) {
                numericBusinessNumber += m.group();
            }
        }

        IF_ERP_Account_Classes.IF_ACCOUNT_015_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_015_Req();
            
        erpParameters.I_CHECK = 'X';
        erpParameters.I_CUSTOMER_TYPE = Boolean.valueOf(fieldMap.get('CareOfRigger__c')) ? 'C' : 'S';
        erpParameters.I_WAERS = (String) fieldMap.get('CurrencyIsoCode');
        erpParameters.I_BZIRK = currentUser.SalesDistrict__c; // 필수
    
        List<IF_ERP_Account_Classes.IF_ACCOUNT_015_Req_I_BASIC> basicParameters = new List<IF_ERP_Account_Classes.IF_ACCOUNT_015_Req_I_BASIC>();
        IF_ERP_Account_Classes.IF_ACCOUNT_015_Req_I_BASIC basic = new IF_ERP_Account_Classes.IF_ACCOUNT_015_Req_I_BASIC();
        basic.NAME1 = (String) fieldMap.get('Name');
        basic.J_1KFREPRE = (String) fieldMap.get('Representative__c');
        basic.COUNTRY = country.CountryCode__c;
        basic.SMTP_ADDR = (String) fieldMap.get('Email__c');
        basic.POST_CODE1 = (String) fieldMap.get('ShippingPostalCode');
        basic.STREET     = (String) fieldMap.get('ShippingStreet');
        basic.COUNC = country.CountryCode__c;
        if(fieldMap.get('RegionLookup__c') != null) {
            basic.REGION = region.RegionCode__c;
        }
        if((String) fieldMap.get('ShippingCity') != '' && (String) fieldMap.get('ShippingCity') != null) {
            Integer maxLength = 40;
            String street = (String) fieldMap.get('ShippingCity') != '' ? (String) fieldMap.get('ShippingCity') : '';
            if(street != '') {
                basic.CITY1 = street.length() > maxLength 
                    ? street.substring(0, maxLength) 
                    : street;
    
                String remainingText = street.length() > maxLength 
                    ? street.substring(maxLength) 
                    : null;
    
                if (remainingText != null) {
                    basic.STR_SUPPL1 = remainingText.length() > maxLength 
                        ? remainingText.substring(0, maxLength) 
                        : remainingText;
                }
            }
        }
        basic.TEL_NUMBER = (String) fieldMap.get('Mobile__c');
        basic.MOB_NUMBER = (String) fieldMap.get('Phone');
        basicParameters.add(basic);
    
        List<IF_ERP_Account_Classes.IF_ACCOUNT_015_I_USERINFO> userParameters = new List<IF_ERP_Account_Classes.IF_ACCOUNT_015_I_USERINFO>();
        IF_ERP_Account_Classes.IF_ACCOUNT_015_I_USERINFO user = new IF_ERP_Account_Classes.IF_ACCOUNT_015_I_USERINFO();
        user.VKORG = currentUser.SalesOrganization__c;
        user.VTWEG = currentUser.DistributionChannel__c;
        user.SPART = currentUser.Division__c;
        user.RNAME = currentUser.Name;

        if(currentUser.AccountId != null) {
            user.KUNNR = currentUser.Account.CustomerCode__c;
            user.KUNN2 = currentUser.Account.CustomerCode__c;
        } else {
            user.KUNNR = currentUser.CustomerCode__c;
            user.KUNN2 = currentUser.CustomerCode__c;
        }
        user.WERKS = currentUser.Plant__c;
        user.LAND1 = country.CountryCode__c;
        userParameters.add(user);
    
        erpParameters.I_BASIC = basic;
        erpParameters.I_USERINFO = user;
    
        IF_ERP_Account erpService = new IF_ERP_Account();
        return erpService.IF_ACCOUNT_015(erpParameters);
    }

    /* 사업자등록번호 '-' 빼기 */
    private static String businessNumberDuplCheck(String bsNum) {
        String numericBusinessNumber    = '';

        Pattern p = Pattern.compile('\\d+');
        Matcher m = p.matcher(bsNum);

        while (m.find()) {
            numericBusinessNumber += m.group();
        }

        return numericBusinessNumber;
    }

    /* 고객사 생성시 제한사항 */
    public static String validationInsertAccount(Id recordTypeId, Map<String, Object> fieldMap) {
        String countryId = (String) fieldMap.get('CountryLookup__c');
        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE Id = :countryId LIMIT 1];
        String name = (String) fieldMap.get('Name');
        String representative = (String) fieldMap.get('Representative__c');
        String bsNum = (String) fieldMap.get('BusinessNumber__c');
        if(bsNum != null) {
            String numCheck = businessNumberDuplCheck(bsNum);
            if(numCheck != null && numCheck != '') {
                System.debug('DN_WithoutSharingClass.checkBusinessNumberDuplicate(numCheck) ::: ' + DN_WithoutSharingClass.checkBusinessNumberDuplicate(numCheck));
                if(DN_WithoutSharingClass.checkBusinessNumberDuplicate(numCheck)) {
                    return 'fail1';
                }
            }
        }
        List<Account> duplCheck = [
            SELECT Id 
            FROM Account 
            WHERE Name = :name
            AND Representative__c = :representative
        ];

        Map<String, String> regionIdForCountryMap = new Map<String, String>();
        if(fieldMap.get('RegionLookup__c') != null) {
            Region__c region = [
                SELECT Id, Country__c 
                FROM Region__c
                WHERE Id = :(String) fieldMap.get('RegionLookup__c')
                LIMIT 1
            ];

            regionIdForCountryMap.put(region.Id, region.Country__c);
        }

        if(!duplCheck.isEmpty()) {
            return 'fail2';
        }

        String nameValue = (String) fieldMap.get('Name');
        if (nameValue != null && nameValue.length() > 40) {
            return 'fail3';
        }

        String representativeValue = (String) fieldMap.get('Representative__c');
        if (representativeValue != null && representativeValue.length() > 10) {
            return 'fail4';
        }

        if(!regionIdForCountryMap.isEmpty()) {
            if ((String) fieldMap.get('CountryLookup__c') != regionIdForCountryMap.get((String) fieldMap.get('RegionLookup__c'))) {
                return 'fail5';
            }
        }

        if((Boolean) fieldMap.get('IsVirtualParent__c') != null) {
            if(
                (String) fieldMap.get('ParentId') != null
                && (Boolean) fieldMap.get('IsVirtualParent__c')
            ) {
                return 'fail6';
            }
    
            if(
                recordTypeId == prospectCustomerRT
                && (Boolean) fieldmap.get('IsVirtualParent__c')
            ) {
                return 'fail7';
            } else if(
                recordTypeId == DNSACustomerRT
                && (Boolean) fieldMap.get('IsVirtualParent__c')
            ) {
                return 'fail8';
            }
        }

        if(
            currentUser.SalesOrganization__c    == null || 
            currentUser.DistributionChannel__c  == null || 
            currentUser.Division__c             == null
        ) {
            return 'fail9';
        }

        if(recordTypeId == tradeCustomerRT){
            if(currentUser.Profile.Name != 'System Administrator' && currentUser.Profile.Name != '시스템 관리자' && currentUser.Profile.Name != 'DNS CS Technical Consultant' && currentUser.Profile.Name != 'CS 상담사' && currentUser.Profile.Name != 'DNS CS Receptionist' && currentUser.Profile.Name != 'DNSA CS Service') {
                return 'fail';
            } else {
                if(country.CountryCode__c == 'KR') {
                    if (
                        (String) fieldMap.get('BusinessNumber__c') == null 
                        && (String) fieldMap.get('ResidentRegistrationNumber__c') == null
                    ) {
                        return 'fail10';
                    }
                } 
            }
        }

        if((String) fieldMap.get('ResidentRegistrationNumber__c') != null) {
            String numberPattern = '^[0-9]{6}$';
            if (Pattern.matches(numberPattern, (String) fieldMap.get('ResidentRegistrationNumber__c'))) {
                
            }else{
                return 'fail11';
            }
        }

        if(
            (String) fieldMap.get('IsBVC__c') == 'Y' &&
            (Date) fieldMap.get('BVCStartDate__c') != null && 
            (Date) fieldMap.get('BVCEndDate__c') != null && 
            (Date) fieldMap.get('BVCStartDate__c') > (Date) fieldMap.get('BVCEndDate__c')
        ) {
            return 'fail12';
        }

        if(
            (Date) fieldMap.get('CustomerSystemStartDate__c') != null &&
            (Date) fieldMap.get('CustomerSystemEndDate__c') != null &&
            (Date) fieldMap.get('CustomerSystemStartDate__c') > (Date) fieldMap.get('CustomerSystemEndDate__c')
        ) {
            return 'fail13';
        }
        return 'success';
    }

    /**
     * @Description
     * 	- Account의 RecordTypeId
     * @author Hanyeong Choi | 10-15-2024
     * @Parameter
     *  - recordTypeName    : 선택한 Account의 RecordType Name
    **/ 
    private static String getRecordTypeId(String recordTypeName) {
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :recordTypeName
            AND SobjectType = 'Account'
            LIMIT 1
        ];

        return rt.Id;
    }

    /**
     * @Description
     * 	- Account Field Type
     * @author Hanyeong Choi | 10-15-2024
     * @Parameter
     *  - fieldName     : 타입을 조회할 Field Name
    **/ 
    private static String getFieldType(String fieldName){
        Schema.DescribeFieldResult  fieldDescribe   = Schema.SObjectType.Account.fields.getMap().get(fieldName).getDescribe();
        Schema.DisplayType          fieldType       = fieldDescribe.getType();
        
        if (fieldDescribe.isCalculated()) {
            return 'formula';
        } else {
            return fieldType.name();
        }
    }

    /* 현재 로그인 유저 정보 */
    private static User setCurrentUser() {
        User u = [
            SELECT  Id
                    , Name
                    , Email
                    , SalesOrganization__c
                    , SalesOffice__c
                    , SalesDistrict__c
                    , DistributionChannel__c
                    , Division__c 
                    , Country__c
                    , Profile.Name
                    , IsPortalEnabled
                    , CustomerCode__c
                    , AccountId
                    , Account.CustomerCode__c
                    , Account.Name
                    , Plant__c
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];
        return u;
    }

    /* 필드 라벨 추출 */
    @AuraEnabled
    public static String getLabel(String fieldName) {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
        if (fieldMap.containsKey(fieldName)) {
            return fieldMap.get(fieldName).getDescribe().getLabel();
        }
        return fieldName;
    }

    /* 검색 결과 wrapper */
    public class SearchWrapper {
        @AuraEnabled public String accId            {get; set;}
        @AuraEnabled public String accName          {get; set;}
        @AuraEnabled public String representative   {get; set;}
        @AuraEnabled public String recordTypeName   {get; set;}
        @AuraEnabled public String address          {get; set;}
        @AuraEnabled public String accOwner         {get; set;}
        @AuraEnabled public String isBVC            {get; set;}

        public SearchWrapper() {}
    }
}