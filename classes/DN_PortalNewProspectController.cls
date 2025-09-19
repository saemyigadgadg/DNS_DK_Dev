/**
 * @description       : 고객사 조회 / 사용 요청
 * @author            : Chungwoo Lee
 * @group             : 
 * @last modified on  : 05-27-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   10-23-2024   Chungwoo Lee   Initial Version
 * 1.0   10-31-2024   Chungwoo Lee   Related Dealer 있는 경우 요청 X
 * 1.0   11-05-2024   Chungwoo Lee   국내 영업 유저 확인 로직 추가 
**/
public with sharing class DN_PortalNewProspectController {
    private static final Id   prospectCustomerRT  = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id   tradeCustomerRT     = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
    private static final Id   dnsaCustomerRT     = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();
    
    /**
    * @description 로그인 사용자 정보 조회
    * @author Chungwoo Lee | 11-05-2024 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> getLoginUserInfo() {
        Map<String, Object> resMap = new Map<String, Object>();
        Boolean isDomesticUser = false;

        try {
            User loginUser = getLoginUser();
            if (loginUser.Profile.Name == 'System Administrator' || loginUser.Profile.Name == '영업 국내 대리점' || loginUser.Profile.Name == '영업 국내 대리점 Login') {
                isDomesticUser = true;
            }
            resMap.put('isDomesticUser', isDomesticUser);
            resMap.put('loginUser',loginUser);
            // if (User.Account.Region__c != null) {
            //     resMap.put('loginUserRegion', User.Account.Region__c);
            // }
            
        } catch (Exception e) {
            System.debug('Error in getLoginUserInfo: ' + e.getMessage());
            resMap.put('flag', 'error');
        }
        return resMap;
    }

    // 로그인 사용자 정보 가져오기
    private static User getLoginUser() {
        return [
            SELECT AccountId
            , ContactId
            , Profile.Name
            , IsPortalEnabled
            , SalesOrganization__c
            , DistributionChannel__c
            , Division__c
            , SalesDistrict__c
            , SalesOffice__c
            , Account.CustomerCode__c
            , Account.CurrencyIsoCode
            , Account.RegionLookup__c
            , Account.CountryLookup__c
            , Account.CountryLookup__r.CurrencyIsoCode
            , Account.CountryLookup__r.CountryCode__c         
            , Account.RegionLookup__r.RegionCode__c
            FROM User 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1
        ];
    }

    /**
    * @description 고객사 조회 
    * @author Chungwoo Lee | 10-24-2024 
    * @param searchCustomerId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled  
    public static Map<String, Object> searchProspectAccount(String searchCustomerName, String searchRepresentative, String searchBusiness) {
        Map<String, Object> resMap = new Map<String, Object>();
        ProspectInfoWrapper prospect;
        List<ProspectInfoWrapper> prospectList = new List<ProspectInfoWrapper>();

        try {
            User loginUser = getLoginUser();
            List<Account> searchedAccountList = DN_WithoutSharingClass.isAccountbyPortal(searchCustomerName, searchRepresentative, searchBusiness);
            
            if (searchedAccountList.size() > 0) {
                for(Account searchedAccount : searchedAccountList){
                    if (!searchedAccount.Name.contains('삭제')) {
                        prospect = new ProspectInfoWrapper();
                        prospect.accountId = searchedAccount.Id;
                        prospect.accountName = searchedAccount.Name;
                        prospect.representative = searchedAccount.Representative__c;
                        prospect.accountCreatedDate = searchedAccount.CreatedDate.date();
                        prospect.isBVC = searchedAccount.IsBVC__c;
                        //prospect.isRequest = (searchedAccount.IsBVC__c == 'Y') ? '보호 고객' : checkRequestStatus(loginUser, searchedAccount);
                        prospect.isRequest = (searchedAccount.IsBVC__c == 'Y') ? '보호 고객' : '';
                        
                        prospectList.add(prospect);
                    }
                }

                resMap.put('flag', 'success');
                resMap.put('resultData', prospectList);
            } else {
                resMap.put('flag', 'Create');
                return resMap;
            }
        } catch (Exception e) {
            System.debug('Error in searchProspectAccount: ' + e.getMessage());
            System.debug('Error StackTrace ::: ' + e.getStackTraceString());
            resMap.put('flag', 'error');
        }
        return resMap;
    }

    /**
    * @description 고객사 사용 요청
    * @author Chungwoo Lee | 10-24-2024 
    * @param prospect 
    * @return Map<String, Object> 
    **/
   @AuraEnabled
    public static Map<String, Object> requestToUse(ProspectInfoWrapper prospect) {
        User loginUser = getLoginUser();
        Map<String, Object> resMap = new Map<String, Object>();
        
        try {
            System.debug('@@ 고객사 사용 요청');
            
            String accountId = prospect.accountId;
            system.debug('apex prospect ::: ' + JSON.serialize(prospect) + '::: ID ===' + accountId);
            if (prospect == null || String.isBlank(prospect.accountId) || String.isBlank(prospect.requestReason)) {
                resMap.put('flag', 'error');
                resMap.put('message', 'Invalid input data. AccountId and RequestReason are required.');
                return resMap;
            }

            // 25/01/02 이주현 추가
            if(isMyAccount(loginUser, accountId)){
                resMap.put('flag', 'auth');
                resMap.put('message', System.Label.DNS_ACC_T_AUTH);
                return resMap;
            }
            if(isAlreadyRequest(loginUser, accountId)){
                resMap.put('flag', 'already');
                resMap.put('message', System.Label.DNS_ACC_T_ALREADY);
                return resMap;
            }

            // List<SimpleCustomerInfo__c> simpleCustomerList = [
            //     SELECT Id, Name, FM_AccountName__c
            //     FROM SimpleCustomerInfo__c 
            //     WHERE Account__c = :accountId
            //     LIMIT 1
            // ];

            // if (simpleCustomerList.isEmpty()) {
            //     resMap.put('flag', 'error');
            //     resMap.put('message', 'No SimpleCustomerInfo record found for the given AccountId.');
            //     return resMap;
            // }

            // SimpleCustomerInfo__c simpleCustomer = simpleCustomerList[0];

            // System.debug('Customer ::: ' + JSON.serialize(simpleCustomer));

            // DNS_RequestToUseCustomer__c requestToUse = new DNS_RequestToUseCustomer__c();
            // requestToUse.SimpleCustomerInfo__c = simpleCustomer.Id;
            // requestToUse.RequestReason__c = prospect.requestReason;

            // insert requestToUse;

            DNS_RequestToUseCustomer__c requestToUse = new DNS_RequestToUseCustomer__c();
            requestToUse.TargetAccount__c = accountId;
            requestToUse.RequestReason__c = prospect.requestReason;

            String rs = DN_WithoutSharingClass.insertRQU(requestToUse);
            if(rs == 'success') {
                Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
                submitReq.setComments('Customer request to use: ' + prospect.accountName + '.');
                submitReq.setObjectId(requestToUse.Id);
                Approval.ProcessResult result = Approval.process(submitReq);

                resMap.put('resultString', requestToUse.Id);
                resMap.put('flag', 'success');
            } else {
                resMap.put('flag', 'error');
                resMap.put('message', rs);
            }
        } catch (Exception e) {
            System.debug('Error in requestToUse: ' + e.getMessage());
            resMap.put('flag', 'error');
            resMap.put('message', e.getMessage());
        }

        return resMap;
    }


    /**
    * @description SAP 통신 후 고객사 등록 
    * @author Chungwoo Lee | 11-19-2024 
    * @param objectName 
    * @param fieldMap 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> saveProspectAccount(String objectName, Map<String, Object> fieldMap) {
        Map<String, Object> resMap = new Map<String, Object>();
        Map<Id, String> accountAlertMap = new Map<Id, String>();
        String result;
        User loginUser = getLoginUser();
        try {
            String check = validationInsertAccount(prospectCustomerRT, fieldMap);
            Boolean ifCheck = false;
            Account newRecord = new Account();
            String loginUserCurrency= '';

            // List<Account> accountList = [
            //     SELECT Id, Name, 
            //         (SELECT Id, Currency__c FROM SalesAreaData__r)
            //     FROM Account 
            //     WHERE Id = :loginUser.AccountId
            // ];

            // if (!accountList.isEmpty() && !accountList[0].SalesAreaData__r.isEmpty()) {
            //     loginUserCurrency = accountList[0].SalesAreaData__r[0].Currency__c;
            // }


            if (check == 'already' || check == 'dupl' || check == 'virtual' || check =='fail') {
                resMap.put('flag'   , check);
                return resMap;
            }
            String test = (String) fieldMap.get('CountryLookup__c');
            System.debug('check ::: ' + check);

            if(check == 'success') {
                System.debug('fieldMap ::: ' + fieldMap);
                IF_ERP_Account_Classes.IF_ACCOUNT_001_Res erpResponse = interfaceAccount001(fieldMap);
                System.debug('erpResponse ::: ' + erpResponse);
                if (erpResponse.O_RECODE == 'S') { 
                    ifCheck = true;
                    newRecord.put('CustomerCode__c', erpResponse.O_KUNNR);
                } else {

                    if(erpResponse.O_DUP == 'X') {
                        result = System.Label.DNS_ACC_T_ERPDUPL;
                        resMap.put('flag', 'ERPDUPLICATE');
                        resMap.put('result', result);

                    } else if(erpResponse.O_REMSG != null && erpResponse.O_REMSG.contains('Postal Code')){
                        resMap.put('flag', 'Postal Code');
                        resMap.put('result', result);
                    
                    } else {
                        result = 'ERP validation failed: ' + (erpResponse.O_REMSG != null ? erpResponse.O_REMSG : 'Unknown error');
                        resMap.put('result', result);
                    }
                    return resMap;

                    // if(erpResponse.O_DUP == 'X') {
                    //     result = System.Label.DNS_ACC_T_ERPDUPL;
                    //     resMap.put('flag', 'ERPDUPLICATE');
                    //     resMap.put('result', result);
                    // } else {
                    //     result = 'ERP validation failed: ' + (erpResponse.O_REMSG != null ? erpResponse.O_REMSG : 'Unknown error');
                    //     resMap.put('result', result);
                    // }
                    // return resMap;
                }
            }
            
            System.debug('check ::: ' + check);
            
            if ((check == 'success' && ifCheck) || check != 'success') {
                newRecord.put('RecordTypeId', prospectCustomerRT);
                
                for (String fieldName : fieldMap.keySet()) {
                    String fieldType = getFieldType(fieldName);
                    System.debug('>>> ' + fieldName + ' _ ' + fieldMap.get(fieldName) );
    
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
                                newRecord.put(fieldName, fieldMap.get(fieldName));
                            }
                        }
                    }
                }
                System.debug('>>> fieldMap DATA is ::: ' + JSON.serialize(fieldMap));

                // String countryId = (String) fieldMap.get('CountryLookup__c');

                // if (String.isNotBlank(countryId)) {
                //     Country__c getCode =[SELECT 
                //                         Id, CountryCode__c
                //                         FROM Country__c WHERE Id =:countryId];
                //     newRecord.Country__c = getCode.CountryCode__c;
                // }
                // if (String.isNotBlank(loginUserCurrency)) {
                //     newRecord.Currency__c = loginUserCurrency;
                // }

                if (newRecord != null) {
                    insert newRecord;
                }
                resMap.put('newRecordId', newRecord.Id);
                resMap.put('flag', 'success');

                accountAlertMap.put(newRecord.Id, newRecord.Name);

                Set<Id> userIds = new Set<Id>();
                userIds.add(UserInfo.getUserId());
                List<User> getProfile =  DN_WithoutSharingClass.getUserEmails(userIds);
                
                if(getProfile[0].Profile.Name == '영업 글로벌 대리점' || getProfile[0].Profile.Name == '영업 글로벌 대리점 Login'){
                    //[GSR SR0000010031094] 잠재고객 생성 완료 시 Email 알람 전송_250815 이원정
                    String alertName        = 'Create Prospect Customer Alert';
                    String alertType        = 'Notification';
                    String userId           = UserInfo.getUserId();
                    String alertLanguage    = 'ko';

                    DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,accountAlertMap);
                }
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('errorString' , e.getMessage().substringAfter('error:'));
            resMap.put('stackTrace', e.getStackTraceString());
            resMap.put('flag'   , 'error');
            throw new AuraHandledException(e.getMessage());
        }
        return resMap;
    }

    // Interface Call
    public static IF_ERP_Account_Classes.IF_ACCOUNT_001_Res interfaceAccount001(Map<String, Object> fieldMap) {
        try {
            String numericBusinessNumber    = '';
            
            if(fieldMap.get('BusinessNumber__c') != '' && fieldMap.get('BusinessNumber__c') != null) {
                String businessNumber           = (String) fieldMap.get('BusinessNumber__c');
                Pattern p = Pattern.compile('\\d+');
                Matcher m = p.matcher(businessNumber);
    
                while (m.find()) {
                    numericBusinessNumber += m.group();
                }
            }
            
            IF_ERP_Account_Classes.IF_ACCOUNT_001_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_001_Req();
            User loginUser = getLoginUser();

            String countryId = (String) fieldMap.get('CountryLookup__c');
            Country__c countryCode = null;
            if (String.isNotBlank(countryId)) {
                countryCode = [SELECT CountryCode__c FROM Country__c WHERE Id = :countryId LIMIT 1];
            } else {
                throw new AuraHandledException('CountryLookup__c is Null.');
            }
            
            Region__c region = null;
            if(fieldMap.get('RegionLookup__c') != null){
                String regionId = (String) fieldMap.get('RegionLookup__c');
                region = [SELECT RegionCode__c FROM Region__c WHERE Id = :regionId LIMIT 1];
            }

            erpParameters.I_ANRED      = 'Company'; //(String) fieldMap.get('Representative__c');
            erpParameters.I_NAME1      = ((String) fieldMap.get('Name')).length() > 35 ? ((String) fieldMap.get('Name')).substring(0,35) : ((String) fieldMap.get('Name'));
            erpParameters.I_COUNTRY    = countryCode.CountryCode__c;
            erpParameters.I_REGION     = (region != null) ? region.RegionCode__c : '';
            erpParameters.I_PSTLZ      = String.isNotBlank((String) fieldMap.get('ShippingPostalCode')) ? (String) fieldMap.get('ShippingPostalCode') : '';
            erpParameters.I_STREET     = String.isNotBlank((String) fieldMap.get('ShippingStreet')) ? (String) fieldMap.get('ShippingStreet') : '';
            // erpParameters.I_CITY1      = String.isNotBlank((String) fieldMap.get('ShippingCity')) ? (String) fieldMap.get('ShippingCity') : '';
            erpParameters.I_TEL_NUMBER = String.isNotBlank((String) fieldMap.get('Phone')) ? (String) fieldMap.get('Phone') : '';
            erpParameters.I_VKORG      = (String) loginUser.SalesOrganization__c;
            erpParameters.I_VTWEG      = (String) loginUser.DistributionChannel__c;
            erpParameters.I_SPART      = (String) loginUser.Division__c;
            erpParameters.I_KTONR      = (loginUser.Account != null && String.isNotBlank(loginUser.Account.CustomerCode__c)) ? loginUser.Account.CustomerCode__c : '';

            // 25/01/02 이주현 추가
            erpParameters.I_NAME      = (String) fieldMap.get('Representative__c');
            erpParameters.I_NAME3     = (String) fieldMap.get('AccountNameEnglish__c');
            erpParameters.I_DEALER     = loginUser.Account.CustomerCode__c;
            erpParameters.I_TAXNUMBER1 = (String) fieldMap.get('BusinessNumber__c');
            erpParameters.I_WAERS      = loginUser.Account.CurrencyIsoCode;
            if(countryCode.CountryCode__c == 'KR') {
                erpParameters.I_TAXNUMBER1 = numericBusinessNumber;

                if((String) fieldMap.get('ShippingCity') != '' && (String) fieldMap.get('ShippingCity') != null) {
                    Integer maxLength = 35;
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
            } else {
                erpParameters.I_TAXNUMBER1 = fieldMap.get('BusinessNumber__c') != null ? (String) fieldMap.get('BusinessNumber__c') : '';

                if((String) fieldMap.get('ShippingStreet') != '' && (String) fieldMap.get('ShippingStreet') != null) {
                    Integer maxLength = 35;
                    String street = (String) fieldMap.get('ShippingStreet');
                    erpParameters.I_STREET = street.length() > maxLength 
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
            }

            System.debug('erpParameters to ERP ::: ' + JSON.serialize(erpParameters));
            IF_ERP_Account erpService = new IF_ERP_Account();
            return erpService.IF_ACCOUNT_001(erpParameters);
        } catch (Exception e) {
            throw new AuraHandledException('Error in Interface ::: ' + e.getMessage());
        }
    }

    // CRM Insert 하기전 Validation
    private static String validationInsertAccount(String recordTypeId, Map<String, Object> fieldMap) {
        User loginUser = getLoginUser();
        
        String newCustomerName = (String) fieldMap.get('Name');
        String newRepresentative = (String) fieldMap.get('Representative__c');
        String businessNumber = (String) fieldMap.get('BusinessNumber__c');
        

        String parentId = (String) fieldMap.get('ParentId');

        System.debug('fieldMap :: ' + fieldMap);
        System.debug('businessNumber in fieldMap :: ' + businessNumber);
        
        if (parentId != null && parentId != '') {
            Account account = [SELECT  Id , IsVirtualParent__c FROM Account WHERE Id = :parentId LIMIT 1];    
            if(account.IsVirtualParent__c) return 'virtual';
        }
        // if(loginUser.SalesOrganization__c == null || loginUser.DistributionChannel__c == null || loginUser.Division__c == null) {
        //     return 'fail';
        // } 
        if (prospectValidationCheck(newCustomerName, newRepresentative) == 'already') {
            return 'already';
        }
        if (loginUser.Account.CountryLookup__r.CountryCode__c == 'KR') {
            if (checkBusinessNumber(businessNumber) == 'dupl') {
                return 'dupl';
            } 
        }
        return 'success';
    }

    // 타입 조회
    private static String getFieldType(String fieldName){
        Schema.DescribeFieldResult  fieldDescribe   = Schema.SObjectType.Account.fields.getMap().get(fieldName).getDescribe();
        Schema.DisplayType          fieldType       = fieldDescribe.getType();
        
        if (fieldDescribe.isCalculated()) {
            return 'formula';
        } else {
            return fieldType.name();
        }
    }

    // Related Dealer 존재 여부 확인
    private static Boolean isMyAccount(User loginUser, String accountId) {
        if (loginUser.AccountId != null && loginUser.ContactId != null && accountId != null) {
            Id loginUserAccountId = loginUser.AccountId;
            // Id loginUserContactId = loginUser.ContactId;

            System.debug('isMyAccount :: ');

            List<DNS_CustomerDealerAssociation__c> relatedDealer = [
                SELECT Id 
                FROM DNS_CustomerDealerAssociation__c 
                WHERE Dealer__c = :loginUserAccountId
                // AND RelatedDealerContact__c = :loginUserContactId 
                AND Customer__c = :accountId
                LIMIT 1
            ];

            System.debug('relatedDealer :: ' + relatedDealer);

            if (!relatedDealer.isEmpty()) {
                return true;
            } 
        }
        return false;
    }

    // 사용 요청 여부 확인
    private static Boolean isAlreadyRequest(User loginUser, String accountId) {
        if (loginUser.AccountId != null && loginUser.ContactId != null && accountId != null) {
            List<DNS_RequestToUseCustomer__c> requestUse = [
                SELECT Id 
                FROM DNS_RequestToUseCustomer__c 
                WHERE CreatedById = :UserInfo.getUserId()
                AND ApprovalStage__c != 'Rejected'
                AND 	TargetAccount__c = :accountId
                LIMIT 1
            ];
            if (!requestUse.isEmpty()) {
                return true;
            } 
        }
        return false;
    }

    // 고객사 등록 전 중복 체크
    private static String prospectValidationCheck(String newCustomerName, String newRepresentative) {
        try {
            System.debug('newCustomerName : ' + newCustomerName);
            System.debug('newRepresentative : ' + newRepresentative);
            List<SimpleCustomerInfo__c> validationCustomer = [
                SELECT Id, FM_AccountName__c, FM_Representative__c
                FROM SimpleCustomerInfo__c 
                WHERE FM_AccountName__c = :newCustomerName 
                AND FM_Representative__c = :newRepresentative
            ];
            System.debug('validationCustomer : ' + validationCustomer);
            if (!validationCustomer.isEmpty()) {
                return 'already';
            } else {
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // BusinessNumberDuplCheck__c 확인
    private static string checkBusinessNumber(String businessNumber) {

        System.debug('businessNumber :: ' + businessNumber);
        try {
            String result;
            String duplBn = '';
            if(businessNumber != null) {
                duplBn = businessNumberDuplCheck(businessNumber);
                System.debug('duplBn :: ' + duplBn);
            }

            if(duplBn != '')  result = DN_WithoutSharingClass.searchDupl(duplBn);
            return result;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    private static String businessNumberDuplCheck(String search) {
        List<String> businessCheck = new List<String>();
        String businessNumber           = search;
        String numericBusinessNumber    = '';

        Pattern p = Pattern.compile('\\d+');
        Matcher m = p.matcher(businessNumber);

        while (m.find()) {
            numericBusinessNumber += m.group();
        }

        System.debug('numericBusinessNumber :: ' + numericBusinessNumber);


        return numericBusinessNumber;
    }
    
    public class ProspectInfoWrapper {
        @AuraEnabled public String      accountId               {get; set;} // 잠재고객사 ID
        @AuraEnabled public String      accountName             {get; set;} // 잠재고객사 명
        @AuraEnabled public String      representative          {get; set;} // 대표자 명
        @AuraEnabled public Date        accountCreatedDate      {get; set;} // 잠재고객 등록 일자
        @AuraEnabled public String      isBVC                   {get; set;} // 보호고객 여부
        @AuraEnabled public String      isRequest               {get; set;} // 잠재고객 요청 상태 구분
        @AuraEnabled public String      requestReason           {get; set;} // 잠재고객 요청 사유
        @AuraEnabled public String      simpleCustomerId        {get; set;} // Simple Customer Info ID
        
        public ProspectInfoWrapper() {}

        public ProspectInfoWrapper(
            String accountId, String accountName, String representative, Date accountCreatedDate, String isBVC, String isRequest, String requestReason, String simpleCustomerId) {

            this.accountId             = accountId;
            this.accountName           = accountName;
            this.representative        = representative;
            this.accountCreatedDate    = accountCreatedDate;
            this.isBVC                 = isBVC;
            this.isRequest             = isRequest;
            this.requestReason         = requestReason;
            this.simpleCustomerId      = simpleCustomerId;
        }
    }

    /* ************************************************************************************ DNS A ************************************************************************************ */
    @AuraEnabled
    public static Map<String, Object> getDNSAInit() {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            resMap.put('getUserInfo', A_getUserInfo());
            resMap.put('getRecordTypeId', A_getRecordTypeId());

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static User A_getUserInfo() {
        User loginUser = getLoginUser();
        return loginUser;
    }

    private static Id A_getRecordTypeId() {
        Id DNSACustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();
        return DNSACustomerRT;
    }

    @AuraEnabled
    public static string insertDnsaAccount(String objectName, Map<String, Object> fieldMap, String recordTypeId) {
        String result;
        User loginUser = getLoginUser();
        try {
            String check = DN_AccountLayoutController.validationInsertAccount(Id.valueOf(recordTypeId), fieldMap);
            Boolean ifCheck = false;
            Account newRecord = new Account();
            System.debug('check ::: ' + check);

            if(check == 'success') {
                IF_ERP_Account_Classes.IF_ACCOUNT_015_Res erpResponse = DN_AccountLayoutController.interfaceAccount015(fieldMap);

                if (erpResponse.O_RETURN.TYPE == 'S') { // ERP 응답 성공 시 진행
                    ifCheck = true;
                    newRecord.put('CustomerCode__c', erpResponse.O_PERSON);
                } else {
                    if(erpResponse.O_RETURN.TYPE == 'X') {
                        result = System.Label.DNS_ACC_T_ERPDUPL;
                    } else {
                        result = 'ERP validation failed: ' + (erpResponse.O_RETURN.MESSAGE != null ? erpResponse.O_RETURN.MESSAGE : 'Unknown error');
                    }
                    return result;
                }
            }

            if (
                (check == 'success' && (ifCheck))
                || check != 'success'
            ) {
            
                newRecord.put('RecordTypeId', Id.valueOf(recordTypeId));
                for (String fieldName : fieldMap.keySet()) {
                    String fieldType = getFieldType(fieldName);

                    System.debug('>>> ' + fieldName + ' _ ' + fieldMap.get(fieldName) );
    
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

                // String baseUrl = URL.getOrgDomainURL().toExternalForm();
                String baseUrl = 'https://dn-solutions--dev.sandbox.my.site.com/partners';
                String recordUrl = baseUrl + '/' + newRecord.Id;
                result = recordUrl;
                return result;
            }

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            result = e.getMessage().substringAfter('error:');
        }
        return result;
    }
}