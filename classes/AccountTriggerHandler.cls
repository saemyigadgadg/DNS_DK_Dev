/**
 * @author            : Yeong-Deok Seo
 * @Description       : Account Trigger Handler
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-05-28   yeongdeok.seo@sbtglobal.com   Initial Version
 * 1.0   2024-06-19   Hanyeong Choi                 IsVirtualParent__c, ParentId 관련 Validation 추가, insert SimpleCustomerInfo__c
 * 1.0   2024-06-25   Hanyeong Choi                 SimpleCustomerInfo__c, Account 필드 update
 * 1.0   2024-06-26   Hanyeong Choi                 Contact 필드 update, IsBlocked__c
 * 1.0   2024-07-02   Joohyun Lee                   Sales Area 확인
 * 1.0   2024-07-04   Yuhyun Park                   FM_Address__c & Text_Address__c 추가 (afterinsert & afterupdate)
 * 1.0   2024-07-05   Yuhyun Park                   실고객 전환 시, 주민등록번호 및 사업자등록번호 제약조건 & 주민등록번호 정규식 추가
 * 1.0   2024-07-18   Hanyeong Choi                 NotERPIF__c 추가, 내용 정리
 * 1.0   2024-07-24   Yuhyun Park                   sendNotification (Draft)
 * 1.0   2025-04-24   Hayeong Min                   고객특성 필드 수정권한 Validation 추가
**/
public with sharing class AccountTriggerHandler extends TriggerHandler {
    private static final Id   prospectCustomerRT  = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id   tradeCustomerRT     = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
    private static final Id   dealerRT            = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id   shipToPartyRT         = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipToParty').getRecordTypeId();
    private static final Id   DNSACustomerRT  = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();
    private static final User currentUser         = setCurrentUser();

    /**
    * @description 
    *  - Account Before Insert Method
    *  - isNullSalesArea 추가 : joohyun Lee
    *  - 실고객 전환 시, 주민등록번호 및 사업자등록번호 제약조건 & 주민등록번호 정규식 추가 : yuhyun Park
    **/
    public override void onBeforeInsert(List<sObject> news){
        if (isExecuting) {
            System.debug('Account BEFORE_INSERT TRIGGER Start');
            List<Account>               accountList = (List<Account>) news;
            List<SimpleCustomerInfo__c> sciList     = new List<SimpleCustomerInfo__c>();
            Set<Id>                     sciAccIds   = new Set<Id>();
            List<Account> partnerList = new List<Account>();
            
            Map<String, Account> existingAccountMap = new Map<String, Account>();
            Map<String, Account> newAccountMap = new Map<String, Account>();
            Map<String, String> countryIdForCountryCodeMap = new Map<String, String>();
            Map<String, String> regionIdForCountryMap = new Map<String, String>();
            
            for(Account acc : accountList) {
                if(acc.CountryLookup__c != null) {
                    countryIdForCountryCodeMap.put(acc.CountryLookup__c, null);
                }
                if(acc.RegionLookup__c != null) {
                    regionIdForCountryMap.put(acc.RegionLookup__c, null);
                }
            }
            if(!countryIdForCountryCodeMap.isEmpty() && !regionIdForCountryMap.isEmpty()) {
                List<Country__c> countryList = [SELECT Id, CountryCode__c FROM Country__c WHERE Id IN :countryIdForCountryCodeMap.keySet()];
                List<Region__c> regionList = [SELECT Id, Country__c FROM Region__c WHERE Id IN :regionIdForCountryMap.keySet()];
                for(Country__c country : countryList) {
                    countryIdForCountryCodeMap.put(country.Id, country.CountryCode__c);
                }
                for(Region__c region : regionList) {
                    regionIdForCountryMap.put(region.Id, region.Country__c);
                }
            }

            Map<String, Account> bsNumByAccId = new Map<String, Account>();
            List<String> bsNumList = new List<String>();
            for(Account acc : accountList){
                if(acc.BusinessNumber__c != null) {
                    bsNumList.add(acc.BusinessNumber__c);
                    bsNumByAccId.put(extractNumbers(acc.BusinessNumber__c), acc);
                }
                validationCheck(acc, null, currentUser, countryIdForCountryCodeMap, regionIdForCountryMap);
                
                String key = acc.Name + ':' + acc.Representative__c;
                if (newAccountMap.containsKey(key)) {
                    acc.addError(System.Label.DNS_ACC_E_DUPL);
                } else {
                    newAccountMap.put(key, acc);
                }

                // if(acc.IsPartner__c) partnerList.add(acc);
            }

            if(!bsNumList.isEmpty()) {
                businessNumberDuplCheck(bsNumByAccId, bsNumList);
                
                for(Account accc : bsNumByAccId.values()) {
                    accc.put('BusinessNumberDuplCheck__c', extractNumbers(accc.BusinessNumber__c));
                }
            }

            Set<String> keySet = newAccountMap.keySet();
            List<Account> matchingAccounts = [
                SELECT Id, Name, Representative__c
                FROM Account
                WHERE Name IN :getNamesFromKeys(keySet)
                AND Representative__c IN :getRepresentativesFromKeys(keySet)
                WITH SECURITY_ENFORCED
            ];
        
            for (Account existingAcc : matchingAccounts) {
                String key = existingAcc.Name + ':' + existingAcc.Representative__c;
                existingAccountMap.put(key, existingAcc);
            }

            for (Account acc : accountList) {
                String key = acc.Name + ':' + acc.Representative__c;
                if (existingAccountMap.containsKey(key)) {
                    acc.addError(System.Label.DNS_ACC_T_DUPL);
                }
            }

            // if(!partnerList.isEmpty()) {
            //     for(Account partnerAcc : partnerList) {
            //         partnerAcc.put('IsPartner', true);
            //     }
            // }
        
            setting(false, TriggerOperation.BEFORE_INSERT);
            System.debug('Account BEFORE_INSERT TRIGGER End');
        }
    }

    /* Account After Insert Method */
    // 07-25 이주현
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting) {
            System.debug('Account AFTER_INSERT TRIGGER Start');
            List<Account>               accList     = (List<Account>) news;
            Set<Id>                     accIds      = new Set<Id>();
            Set<Id>                     crmAccIds      = new Set<Id>();
            List<SimpleCustomerInfo__c> sciList     = new List<SimpleCustomerInfo__c>();
            List<Account>               keyAccList  = new List<Account>();
            List<String> juminList = new List<String>();
            List<Account> juminAccList = new List<Account>();
            
            for(Account acc : accList) {
                if(!acc.IsVirtualParent__c && acc.RecordTypeId != dealerRT) {
                    SimpleCustomerInfo__c sci = setSimpleCustomerInfo(acc);
                    sciList.add(sci);
                }

                System.debug('currentUser.AccountId ::: ' + currentUser.AccountId);
                if(currentUser.AccountId != null) accIds.add(acc.Id);
                else crmAccIds.add(acc.Id);
                if(acc.IsKeyAccount__c) keyAccList.add(acc);

                if(acc.ResidentRegistrationNumber__c != null) {
                    juminAccList.add(acc);
                }
            }

            if(!sciList.isEmpty()) insert sciList;
            if(!accIds.isEmpty()) insertCustomerDealerAssociation(currentUser, accIds);
            if(!crmAccIds.isEmpty()) insertAccountTeam(currentUser, crmAccIds);
            if(!juminAccList.isEmpty()) insertIFJumin(juminAccList);
            insertSalesAreaData(accList);
            if(!keyAccList.isEmpty()) sendKeyAccountNotification(keyAccList);
            if(!keyAccList.isEmpty()) sendKeyAccountEmail(keyAccList);

            setting(false, TriggerOperation.AFTER_INSERT);
            System.debug('Account AFTER_INSERT TRIGGER End');
        }
    }

    /* Account Before Update Method */
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('Account BEFORE_UPDATE TRIGGER Start');
            List<Account>   accList         = (List<Account>) news;
            Set<Id>         inactiveAccIds  = new Set<Id>();
            Map<Id, String> accIdNameMap    = new Map<Id, String>();
            List<Account> changeRecordTypeAcc = new List<Account>();
            List<Account>   juminAccList  = new List<Account>();
            Map<String, String> countryIdForCountryCodeMap = new Map<String, String>();
            Map<String, String> regionIdForCountryMap = new Map<String, String>();

            for(Account acc : accList) {
                if(acc.CountryLookup__c != null) {
                    countryIdForCountryCodeMap.put(acc.CountryLookup__c, null);
                }
                if(acc.RegionLookup__c != null) {
                    regionIdForCountryMap.put(acc.RegionLookup__c, null);
                }
            }

            System.debug('regionIdForCountryMap ::: ' + regionIdForCountryMap);
            if(!countryIdForCountryCodeMap.isEmpty() || !regionIdForCountryMap.isEmpty()) {
                List<Country__c> countryList = [SELECT Id, CountryCode__c FROM Country__c WHERE Id IN :countryIdForCountryCodeMap.keySet()];
                List<Region__c> regionList = [SELECT Id, Country__c FROM Region__c WHERE Id IN :regionIdForCountryMap.keySet()];
                for(Country__c country : countryList) {
                    countryIdForCountryCodeMap.put(country.Id, country.CountryCode__c);
                }
                for(Region__c region : regionList) {
                    System.debug('region ::: ' + region);
                    regionIdForCountryMap.put(region.Id, region.Country__c);
                }
            }

            Map<String, Account> bsNumByAccId = new Map<String, Account>();
            List<String> bsNumList = new List<String>();
            for(Account acc : accList) {
                validationCheck(acc, oldMap, currentUser, countryIdForCountryCodeMap, regionIdForCountryMap);
                if(acc.Inactive__c && acc.RecordTypeId == dealerRT) inactiveAccIds.add(acc.Id);
                if(acc.IsVirtualParent__c && !acc.NotERPIF__c)  acc.put('NotERPIF__c', true);
                if(!acc.IsVirtualParent__c && acc.NotERPIF__c)  acc.put('NotERPIF__c', false);

                if(acc.BusinessNumber__c != null && oldMap.get(acc.Id).get('BusinessNumber__c') != acc.BusinessNumber__c) {
                    bsNumList.add(acc.BusinessNumber__c);
                    bsNumByAccId.put(extractNumbers(acc.BusinessNumber__c), acc);
                }

                if(oldMap.get(acc.Id).get('ResidentRegistrationNumber__c') == null && acc.ResidentRegistrationNumber__c != null) {
                    juminAccList.add(acc);
                }
            }
            if(!inactiveAccIds.isEmpty()) updateContactInActive(inactiveAccIds);
            // if(!accIdNameMap.isEmpty()) updateSciName(accIdNameMap);
            if(!juminAccList.isEmpty()) insertIFJumin(juminAccList);

            if(!bsNumList.isEmpty()) {
                businessNumberDuplCheck(bsNumByAccId, bsNumList);

                for(Account accc : bsNumByAccId.values()) {
                    accc.put('BusinessNumberDuplCheck__c', extractNumbers(accc.BusinessNumber__c));
                    // 2925-02-03 추가 : Yuhyun Park
                    if((Boolean) oldMap.get(accc.Id).get('IsBusinessLicense__c')){
                        accc.IsBusinessLicense__c = false;
                    }
                }
            }

            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('Account BEFORE_UPDATE TRIGGER End');
        }
    }

    /* Account After Update Method */
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('Account AFTER_UPDATE TRIGGER Start');
            List<Account>   accList     = (List<Account>) news;
            Map<Id, String> dnscoltdMap = new Map<Id, String>();
            Map<Id, Account> updateMap  = new Map<Id, Account>();
            List<Account>   keyAccList  = new List<Account>();
            List<Account> sendDateNotiAcc = new List<Account>();
            List<Account> sendBatchList = new List<Account>();
            List<Account> interfaceAcc002 = new List<Account>();
            List<Account> interfaceAcc003 = new List<Account>();
            List<Account> interfaceAcc013 = new List<Account>();
            Set<Id> tradeIds = new Set<Id>();

            for(Account acc : accList) {
                if(oldMap.get(acc.Id).get('DNSCOLtd__c') != acc.DNSCOLtd__c) dnscoltdMap.put(acc.Id, acc.DNSCOLtd__c);
                if(oldMap.get(acc.Id).get('IsKeyAccount__c') == false && acc.IsKeyAccount__c) keyAccList.add(acc);
                if(oldMap.get(acc.Id).get('ParentId') != acc.ParentId) sendBatchList.add(acc);

                if(
                    oldMap.get(acc.Id).get('FM_notificationCheck__c') == false 
                    && acc.FM_notificationCheck__c
                    && acc.IsBVC__c == 'Y'
                    && acc.CustomerSystem__c != null
                ) {
                    sendDateNotiAcc.add(acc);
                }
                if(oldMap.get(acc.Id).get('RecordTypeId') != acc.RecordTypeId && acc.RecordTypeId == tradeCustomerRT) tradeIds.add(acc.Id);
                if(oldMap.get(acc.Id).get('IsErpDelete__c') == acc.IsErpDelete__c && oldMap.get(acc.Id).get('IsErpDelete__c') == false) {
                    if(oldMap.get(acc.Id).get('RecordTypeId') == prospectCustomerRT && oldMap.get(acc.Id).get('CustomerCode__c') != null) interfaceAcc002.add(acc);
                    if(oldMap.get(acc.Id).get('RecordTypeId') == tradeCustomerRT && oldMap.get(acc.Id).get('CustomerCode__c') != null) interfaceAcc003.add(acc);
                    if(oldMap.get(acc.Id).get('RecordTypeId') == shipToPartyRT && oldMap.get(acc.Id).get('CustomerCode__c') != null) interfaceAcc013.add(acc);
                    // if(oldMap.get(acc.Id).get('RecordTypeId') == DNSACustomerRT && oldMap.get(acc.Id).get('CustomerCode__c') != null && !acc.CareOfRigger__c) interfaceAcc013.add(acc);
                    if(oldMap.get(acc.Id).get('RecordTypeId') == DNSACustomerRT && oldMap.get(acc.Id).get('CustomerCode__c') != null) interfaceAcc013.add(acc);
                }
            }

            if(!keyAccList.isEmpty()) sendKeyAccountNotification(keyAccList);
            if(!keyAccList.isEmpty()) sendKeyAccountEmail(keyAccList);
            if(!sendBatchList.isEmpty()) sendBatchRecord(sendBatchList);
            if(!sendDateNotiAcc.isEmpty()) sendCustomerSystemNotification(sendDateNotiAcc);
            if(!sendDateNotiAcc.isEmpty()) sendCustomerSystemEmail(sendDateNotiAcc);
            if(!tradeIds.isEmpty()) {
                sendConvertSuccessNoti(tradeIds);
                // sendConvertSuccessEmail(tradeIds);  //[GSR SR0000010031094] 잠재고객 > 실고객 전환 요청 시
            }

            if(!Test.isRunningTest()) {// 250123 윤영주 테스트 코드 예외 처리
                if(!interfaceAcc002.isEmpty()) Database.executeBatch(new DN_InterfaceAccountUpdateBatch(interfaceAcc002, 'ProspectCustomer'));
                if(!interfaceAcc003.isEmpty()) Database.executeBatch(new DN_InterfaceAccountUpdateBatch(interfaceAcc003, 'TradeCustomer'));
                if(!interfaceAcc013.isEmpty()) Database.executeBatch(new DN_InterfaceAccountUpdateBatch(interfaceAcc013, 'ShipToParty'));
            }

            setting(false, TriggerOperation.AFTER_UPDATE);
            System.debug('Account AFTER_UPDATE TRIGGER End');
        }
    }

    /* Account Before Delete Method */
    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap) {
        if(isExecuting) {
            System.debug('Account BEFORE_DELETE TRIGGER Start');
            List<Account>   accList             = (List<Account>) dels;
            Set<Id>         delAccIds           = new Set<Id>();

            for(Account acc : accList) {
                delAccIds.add(acc.Id);
            }

            if(!delAccIds.isEmpty()) {
                deleteDealerAssociation(delAccIds);
                deleteSimpleCustomerInfo(delAccIds);
            }
            
            setting(false, TriggerOperation.BEFORE_DELETE);
            System.debug('Account BEFORE_DELETE TRIGGER End');
        }
    }

    /**
     * @Description
     * 	- Account validation check
     * @author Hanyeong Choi | 06-19-2024
     * @Parameter
     *  - acc	            : Account Record
     *  - oldMap	        : (Update 경우) Account Id, Account Record Map
     *  - currentUser       : loginUser info
    **/ 
    private void validationCheck(Account acc, Map<Id, sObject> oldMap, User currentUser, Map<String, String> countryIdForCountryCodeMap, Map<String, String> regionIdForCountryMap) {
        if(oldMap == null) {
            System.debug('INSERT validation check');

            if (acc.Name != null && acc.Name.length() > 40) {
                acc.addError(System.Label.DNS_ACC_T_NAMEERROR);
            }
            if(acc.Representative__c != null && acc.Representative__c.length() > 10) {
                acc.addError(System.Label.DNS_ACC_T_REPRERROR);
            }

            if (acc.Competitor__c != null) {
                List<String> competitorValues = acc.Competitor__c.split(';');
                if (competitorValues.size() > 1 && competitorValues.contains('None')) {
                    competitorValues.remove(competitorValues.indexOf('None'));
                    acc.Competitor__c = String.join(competitorValues, ';');
                }
            }

            System.debug('regionIdForCountryMap ::: ' + regionIdForCountryMap);
            System.debug('acc.CountryLookup__c ::: ' + acc.CountryLookup__c);
            if(!regionIdForCountryMap.isEmpty() &&  acc.CountryLookup__c != regionIdForCountryMap.get(acc.RegionLookup__c)) {
                acc.addError(System.Label.DNS_ACC_T_REGIONERROR);
            }

            if(!countryIdForCountryCodeMap.isEmpty()) {
                acc.put('Country__c', countryIdForCountryCodeMap.get(acc.CountryLookup__c));
            }
            
            if(acc.ParentId != null && acc.IsVirtualParent__c) {
                acc.addError(System.Label.DNS_ACC_E_VIRTUALPARENT);
            }

            if(acc.RecordTypeId == prospectCustomerRT && acc.IsVirtualParent__c) {
                String tempName = acc.Name;
                if(acc.Name.contains('(Virtual)')) tempName = acc.Name.replace('(Virtual)', '');
                acc.Name = '(Virtual) ' + tempName;
                acc.put('NotERPIF__c', true);
            } else if(acc.RecordTypeId == DNSACustomerRT && acc.IsVirtualParent__c) {
                String tempName = acc.Name;
                if(acc.Name.contains('(Virtual)')) tempName = acc.Name.replace('(Virtual)', '');
                acc.Name = '(Virtual) ' + tempName;
                acc.put('NotERPIF__c', true);
            }
            else if(acc.RecordTypeId != prospectCustomerRT && acc.IsVirtualParent__c) {
                acc.addError(System.Label.DNS_ACC_E_VIRTUALONLY);
            }

            if(isNullSalesArea(acc, currentUser)){
                acc.addError(System.Label.DNS_M_NoMatchSalesAreaData);
            }

            if(!acc.Is_Migration__c) {
                if (acc.RecordTypeId == tradeCustomerRT) {
                    // if (currentUser.Profile.Name != 'System Administrator' && currentUser.SalesOrganization__c != '1846') {
                    if (currentUser.Profile.Name != 'System Administrator' && currentUser.Profile.Name != '시스템 관리자' && currentUser.Profile.Name != 'DNS CS Technical Consultant' && currentUser.Profile.Name != 'CS 상담사' && currentUser.Profile.Name != 'DNS CS Receptionist' && currentUser.Profile.Name != 'DNSA CS Service') { //  임시
                        // acc.addError('Trade Customer cannot be created diretly.');
                        if (countryIdForCountryCodeMap.get(acc.CountryLookup__c) == 'KR') {
                            if (acc.BusinessNumber__c == null && acc.ResidentRegistrationNumber__c == null) {
                                acc.addError('사업자등록번호 또는 주민등록번호를 입력해주세요.');
                            }
                        } else if (acc.BusinessNumber__c == null) {
                            acc.addError('Please enter the Business Number/VAT Code.');
                        }
                    } else {
    
                        if (countryIdForCountryCodeMap.get(acc.CountryLookup__c) == 'KR') {
                            if (acc.BusinessNumber__c == null && acc.ResidentRegistrationNumber__c == null) {
                                acc.addError('사업자등록번호 또는 주민등록번호를 입력해주세요.');
                            }
                        } 
                    }
                }
            }

            // 주민등록번호 정규식
            if(acc.ResidentRegistrationNumber__c != null){
                String numberPattern = '^[0-9]{6}$';
                if (Pattern.matches(numberPattern, acc.ResidentRegistrationNumber__c)) {
                    acc.ResidentRegistrationNumber__c += '-⁎⁎⁎⁎⁎⁎⁎'; 
                }else{
                    acc.addError('주민등록번호는 6자리의 숫자로 입력해주세요.');
                }
            }

            if(
                acc.IsBVC__c == 'Y' &&
                acc.BVCStartDate__c != null && 
                acc.BVCEndDate__c != null && 
                acc.BVCStartDate__c > acc.BVCEndDate__c
            ) {
                acc.addError(System.Label.DNS_ACC_E_BVCDATE);
            }

            if(
                acc.CustomerSystemStartDate__c != null &&
                acc.CustomerSystemEndDate__c != null &&
                acc.CustomerSystemStartDate__c > acc.CustomerSystemEndDate__c
            ) {
                acc.addError(System.Label.DNS_ACC_E_CUSTOMERSYSTEMDATE);
            }

            if(acc.IsBVC__c == 'N' || acc.IsBVC__c == null) {
                acc.BVCDealer__c = null;
                acc.BVCStartDate__c = null;
                acc.BVCEndDate__c = null;
            }
        } else {
            System.debug('UPDATE validation check');

            System.debug('regionIdForCountryMap ::: ' + regionIdForCountryMap);
            System.debug('acc.CountryLookup__c ::: ' + acc.CountryLookup__c);
            System.debug('regionIdForCountryMap.get(acc.RegionLookup__c) ::: ' + regionIdForCountryMap.get(acc.RegionLookup__c));
            if(!regionIdForCountryMap.isEmpty() && acc.CountryLookup__c != regionIdForCountryMap.get(acc.RegionLookup__c)) {
                acc.addError(System.Label.DNS_ACC_T_REGIONERROR);
            }

            if(!countryIdForCountryCodeMap.isEmpty()) {
                if(oldMap.get(acc.Id).get('CountryLookup__c') != acc.CountryLookup__c) {
                    acc.put('Country__c', countryIdForCountryCodeMap.get(acc.CountryLookup__c));
                }
            }

            if(isNullSalesArea(acc, currentUser)){
                acc.addError(System.Label.DNS_M_NoMatchSalesAreaData);
            }

            if (oldMap.get(acc.Id).get('Competitor__c') != acc.Competitor__c && acc.Competitor__c != null) {
                List<String> competitorValues = acc.Competitor__c.split(';');
                if (competitorValues.size() > 1 && competitorValues.contains('None')) {
                    competitorValues.remove(competitorValues.indexOf('None'));
                    acc.Competitor__c = String.join(competitorValues, ';');
                }
            }

            if(
                (Boolean) oldMap.get(acc.Id).get('IsBlocked__c') 
                && acc.IsBlocked__c
            ) {
                acc.addError(System.Label.DNS_ACC_E_LOCK);
            }
    
            if(
                (Boolean) oldMap.get(acc.Id).get('IsVirtualParent__c') 
                && !acc.IsVirtualParent__c
            ) {
                acc.addError(System.Label.DNS_ACC_E_VIRTUALNOTCHANGE);
            }
    
            if(
                (Boolean) oldMap.get(acc.Id).get('IsVirtualParent__c')
                && oldMap.get(acc.Id).get('RecordTypeId') != acc.RecordTypeId
            ) {
                acc.addError(System.Label.DNS_ACC_E_VIRTUALRECORDTYPE);
            }
    
            if(acc.ParentId != null && acc.IsVirtualParent__c) {
                acc.addError(System.Label.DNS_ACC_E_VIRTUALPARENT);
            }
    
            if(
                acc.IsVirtualParent__c
                && acc.RecordTypeId == prospectCustomerRT
            ) {
                String tempName = acc.Name;
                if(acc.Name.contains('(Virtual)')) tempName = acc.Name.replace('(Virtual)', '');
                acc.put('Name', '(Virtual) ' + tempName);
            } else if (
                acc.IsVirtualParent__c
                && (acc.RecordTypeId != prospectCustomerRT && acc.RecordTypeId != DNSACustomerRT)
            ) {
                acc.addError(System.Label.DNS_ACC_E_VIRTUALONLY);
            }
    
            if(
                oldMap.get(acc.Id).get('Name') != null
                && oldMap.get(acc.Id).get('Name') != acc.Name
                && acc.IsVirtualParent__c == false
            ) {
                acc.addError(System.Label.DNS_ACC_E_NAMECHANGE);
            }
    
            if(
                oldMap.get(acc.Id).get('Representative__c') != null
                && oldMap.get(acc.Id).get('Representative__c') != acc.get('Representative__c')
                && oldMap.get(acc.Id).get('IsVirtualParent__c') == false
            ) {
                acc.addError(System.Label.DNS_ACC_E_RepresentativeCHANGE);
            }
    
            // Trade Customer일 경우, 주민등록번호 또는 사업자등록번호 필수 입력
            if(!acc.Is_Migration__c) {
                if(acc.RecordTypeId == tradeCustomerRT){
                    if(countryIdForCountryCodeMap.get(acc.CountryLookup__c) == 'KR') {
                        if(acc.BusinessNumber__c == null && acc.ResidentRegistrationNumber__c == null) {
                            acc.addError('사업자등록번호 또는 주민등록번호를 입력해주세요.');
                        }
                    }else if(acc.BusinessNumber__c == null){
                        acc.addError('Please enter the Business Number/VAT Code.');
                    }
                }
            }
    
            // 주민등록번호 정규식
            if(oldMap.get(acc.Id).get('ResidentRegistrationNumber__c') == null && acc.ResidentRegistrationNumber__c != null) {
                String residentRegistrationNumber = acc.ResidentRegistrationNumber__c;
                if (residentRegistrationNumber != null) {
                    String numberPattern = '^[0-9]{6}$';
                    if (Pattern.matches(numberPattern, residentRegistrationNumber)) {
                        residentRegistrationNumber += '-⁎⁎⁎⁎⁎⁎⁎';
                        acc.put('ResidentRegistrationNumber__c', residentRegistrationNumber);
                    } else {
                        acc.addError('주민등록번호는 6자리의 숫자로 입력해주세요.');
                    }
                }
            }

            if(
                acc.IsBVC__c == 'Y' &&
                acc.BVCStartDate__c != null && 
                acc.BVCEndDate__c != null && 
                acc.BVCStartDate__c > acc.BVCEndDate__c
            ) {
                acc.addError(System.Label.DNS_ACC_E_BVCDATE);
            }

            if(
                acc.CustomerSystemStartDate__c != null &&
                acc.CustomerSystemEndDate__c != null &&
                acc.CustomerSystemStartDate__c > acc.CustomerSystemEndDate__c
            ) {
                acc.addError(System.Label.DNS_ACC_E_CUSTOMERSYSTEMDATE);
            }

            if(acc.IsBVC__c == 'N' || acc.IsBVC__c == null) {
                acc.BVCDealer__c = null;
                acc.BVCStartDate__c = null;
                acc.BVCEndDate__c = null;
            }
        }
        return;
    }

    /**
     * @Description
     * 	- Account Insert, Update 시, BusinessNumber__c 정보가 있으면 BusinessNumberDuplCheck__c에 정보를 넣어 중복 logic에 사용
     * @author Hanyeong Choi | 07-18-2024
     * @Parameter
     *  - acc	        : Account Record
    **/ 
    private static void businessNumberDuplCheck(Map<String, Account> accBsNumMap, List<String> bsNumList) {
        List<String> formatBsNumList = new List<String>();
        for(String bsNum: bsNumList) {
            String numericBusinessNumber = extractNumbers(bsNum);
            formatBsNumList.add(numericBusinessNumber);
            System.debug('formatBsNumList ::: ' + formatBsNumList);
        }

        if(!formatBsNumList.isEmpty()) {
            List<String> catchList = DN_WithoutSharingClass.checkBusinessNumberDuplicateList(formatBsNumList);
            System.debug('catchList ::: ' + catchList);

            if(!catchList.isEmpty()) {
                for(String ac : catchList) {
                    Account errorAcc = accBsNumMap.get(ac);
                    System.debug('errorAcc ::: ' + errorAcc);
                    errorAcc.addError(System.Label.DNS_M_DuplBusinessNum);
                }
            }
        }

        return;
    }

    /**
     * @Description
     * 	- Account 생성 시, SimpleCustomerInfo__c 레코드 insert
     *  - FM_Address__c 추가 : Yuhyun Park 
     * @author Hanyeong Choi | 06-19-2024
     * @Parameter
     *  - sObj	        : Account Record
    **/ 
    private static SimpleCustomerInfo__c setSimpleCustomerInfo(Account acc) {
        SimpleCustomerInfo__c sci   = new SimpleCustomerInfo__c();
        sci.Name                    = acc.Name;
        sci.Account__c              = acc.Id;
        
        return sci;
    }

    /**
    * @Description
    *  - Inactive__c 필드가 True가 되면 Contact의 Inactive__c 필드 True로 Update (only Dealer Account)
    * @author Hanyeong Choi | 06-26-2024
    * @Parameter
    *  - accIds	        : Inactive__c가 변경된 Account Ids
    **/
    private static void updateContactInActive(Set<Id> accIds) {
        List<Contact> updateContactList = new List<Contact>();
        List<Contact> cList = [
            SELECT Id
                    , Inactive__c
            FROM Contact
            WHERE AccountId IN :accIds
            AND Inactive__c = false
        ];

        if(!cList.isEmpty()) {
            for(Contact c : cList) {
                c.Inactive__c = true;
                updateContactList.add(c);
            }

            if(!updateContactList.isEmpty()) update updateContactList;
        }
        return;
    }

    /**
    * @description 
        딜러가 생성한 고객의 Sales Area 할당 및 확인
    * @author Joohyun Lee | 07-02-2024 
    * @return boolean True : Sales Area Null 존재
    **/
    private boolean isNullSalesArea(Account acc, User usr){
        if(
            usr.SalesOrganization__c    == null || 
            usr.DistributionChannel__c  == null || 
            usr.Division__c             == null
            // usr.SalesDistrict__c        == null ||
            // usr.SalesOffice__c          == null
        ) {
            return true;
        }

        if(acc.RecordTypeId != tradeCustomerRT) {
            System.debug('acc.SalesOrganization__c ::: ' + acc.SalesOrganization__c);
            System.debug('usr.SalesOrganization__c ::: ' + usr.SalesOrganization__c);

            if (usr.SalesOrganization__c != null) {
                acc.SalesOrganization__c = usr.SalesOrganization__c;
                System.debug('acc.SalesOrganization__c ::: ' + acc.SalesOrganization__c);
            }
            if (usr.DistributionChannel__c != null) {
                acc.DistributionChannel__c = usr.DistributionChannel__c;
            }
            if (usr.Division__c != null) {
                acc.Division__c = usr.Division__c;
            }
            if (usr.SalesDistrict__c != null) {
                acc.SalesDistrict__c = usr.SalesDistrict__c;
            }
            if (usr.SalesOffice__c != null) {
                acc.SalesOffice__c = usr.SalesOffice__c;
            }
        } else {
            if (acc.SalesOrganization__c == null && usr.SalesOrganization__c != null && usr.SalesOrganization__c == '1800') {
                acc.SalesOrganization__c = usr.SalesOrganization__c;
            }
            if (acc.DistributionChannel__c == null && usr.DistributionChannel__c != null) {
                acc.DistributionChannel__c = usr.DistributionChannel__c;
            }
            if (acc.Division__c == null && usr.Division__c != null) {
                acc.Division__c = usr.Division__c;
            }
            if (acc.SalesDistrict__c == null && usr.SalesDistrict__c != null) {
                acc.SalesDistrict__c = usr.SalesDistrict__c;
            }
        }
        
        return false;
    }

    /**
    * @Description
    *  - Current User Info
    * @author Hanyeong Choi | 07-25-2024
    * @Parameter
    *  - 
    **/
    private static User setCurrentUser() {
        Id loginUserId = UserInfo.getUserId();
        User loginUser = [
            SELECT id
                    , Name
                    , Username
                    , IsPortalEnabled
                    , AccountId
                    , ContactId
                    , SalesOrganization__c
                    , DistributionChannel__c
                    , Division__c
                    , SalesDistrict__c
                    , SalesOffice__c
                    , FM_ProfileName__c
                    , Profile.Name
            FROM User 
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        return loginUser;
    }

    /**
    * @Description
    *  - Create DNS_CustomerDealerAssociation__c record
    * @author Hanyeong Choi | 07-25-2024
    * @Parameter
    *  - currentUser        : Current login user info
    *  - accIds             : insert되는 Account Id set
    **/
    private static void insertCustomerDealerAssociation(User currentUser, Set<Id> accIds) {
        Id cdaDealerRT = SObjectType.DNS_CustomerDealerAssociation__c.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        List<DNS_CustomerDealerAssociation__c> cdaList = new List<DNS_CustomerDealerAssociation__c>();
        for(Id accId : accIds) {
            DNS_CustomerDealerAssociation__c cda = new DNS_CustomerDealerAssociation__c();
            cda.Dealer__c               = currentUser.AccountId;
            cda.Customer__c             = accId;
            // cda.RelatedDealerContact__c = currentUser.ContactId;
            cda.RecordTypeId            = cdaDealerRT;
            
            cdaList.add(cda);
        }
        if(!cdaList.isEmpty()) insert cdaList;
        
        return;
    }

    /* Account의 Sales Reps. 생성 */
    private static void insertAccountTeam(User currentUser, Set<Id> accIds) {
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        for(Id accId : accIds) {
            AccountTeamMember atm = new AccountTeamMember();
            atm.AccountId               = accId;
            atm.UserId                  = currentUser.Id;
            atm.TeamMemberRole          = 'Sales Manager';
            atm.AccountAccessLevel      = 'Edit';
            atm.OpportunityAccessLevel  = 'None';
            atm.CaseAccessLevel         = 'None';
            atmList.add(atm);
        }
        if(!atmList.isEmpty()) insert atmList;
        return;
    }

    /**
    * @Description
    *  - Account 삭제 시,DNS_CustomerDealerAssociation__c 삭제
    * @author Hanyeong Choi | 07-25-2024
    * @Parameter
    *  - delAccIds             : delete되는 Account Id set
    **/
    private static void deleteDealerAssociation(Set<Id> delAccIds) {
        List<DNS_CustomerDealerAssociation__c> cdaList = [
            SELECT Id
            FROM DNS_CustomerDealerAssociation__c
            WHERE Dealer__c IN :delAccIds
            OR Customer__C IN :delAccIds
        ];

        if(!cdaList.isEmpty()) delete cdaList;
        return;
    }

    /**
    * @Description
    *  - Account 삭제 시,SimpleCustomerInfo__c 삭제
    * @author Hanyeong Choi | 10-08-2024
    * @Parameter
    *  - delAccIds             : delete되는 Account Id set
    **/
    private static void deleteSimpleCustomerInfo(Set<Id> delAccIds) {
        Set<Id> sciIds = new Set<Id>();

        List<SimpleCustomerInfo__c> sciList = [
            SELECT Id
            FROM SimpleCustomerInfo__c
            WHERE Account__c IN :delAccIds
        ];

        for(SimpleCustomerInfo__c sci : sciList) {
            sciIds.add(sci.Id);
        }
        deleteRequestToUseCustomer(sciIds);
        if(!sciList.isEmpty()) delete sciList;
        return;
    }

    /* Account의 Related Dealer 삭제 */
    private static void deleteRequestToUseCustomer(Set<Id> sciIds) {
        List<DNS_RequestToUseCustomer__c> rtucList = [
            SELECT Id
            FROM DNS_RequestToUseCustomer__c
            WHERE SimpleCustomerInfo__c IN :sciIds
        ];

        if(!rtucList.isEmpty()) delete rtucList;
        return;
    }

    /**
     * @Description
     * 	- 사업자등록번호 숫자만 뽑기
     * @author Hanyeong Choi | 07-25-2024
     * @Parameter
     *  - businessNumber        : Account의 BusinessNumber__c
    **/ 
    private static String extractNumbers(String businessNumber) {
        String numericString = '';
        Pattern p = Pattern.compile('\\d+');
        Matcher m = p.matcher(businessNumber);

        while (m.find()) {
            numericString += m.group();
        }

        return numericString;
    }

    /**
     * @Description
     * 	- Account 생성 시, Sales Area Data 레코드 생성
     * @author Hanyeong Choi | 10-18-2024
     * @Parameter
     *  - accList       : Insert Account List
    **/ 
    private static void insertSalesAreaData(List<Account> accList) {
        Set<Id> accIds = new Set<Id>();

        for(Account acc : accList) {
            accIds.add(acc.Id);
        }
        List<Account> accListList = [
            SELECT  Id
                    , CountryLookup__c
                    , CountryLookup__r.CountryCode__c
                    , CountryLookup__r.Country_Picklist__c
                    , RegionLookup__c
                    , RegionLookup__r.RegionCode__c 
                    , SalesOrganization__c
                    , SalesDistrict__c
                    , SalesOffice__c
                    , DistributionChannel__c
                    , Division__c
                    , CareOfRigger__c
                    , RecordTypeId
                    , Sales_Office_CS__c
            FROM Account 
            WHERE Id IN :accIds
        ];

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

        System.debug('currentUser ::: ' + currentUser);
        if(currentUser.IsPortalEnabled) {
            String objectName = 'SalesAreaData__c';
            Map<String, Schema.SObjectField>    objectFields    = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            List<String>                        fieldsToQuery   = new List<String>(objectFields.keySet());
            String query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName + ' WHERE Account__c = \'' + currentUser.AccountId + '\'' + ' AND SalesOrganization__c = \'' + currentUser.SalesOrganization__c + '\'' + ' AND DistributionChannel__c = \'' + currentUser.DistributionChannel__c + '\'' + ' AND Division__c = \'' + currentUser.Division__c + '\'';
            List<SObject> sObj = Database.query(query);
            List<SalesAreaData__c> salesList = (List<SalesAreaData__c>) sObj;
            List<SalesAreaData__c> clonedRecords = new List<SalesAreaData__c>();

            for(Account acc : accListList) {
                for (SalesAreaData__c record : salesList) {
                    SalesAreaData__c clonedRecord = record.clone(false, true, false);
                    clonedRecord.Account__c = acc.Id;
                    clonedRecords.add(clonedRecord);
                }
            }
            System.debug('clonedRecords : ' + clonedRecords);
            if(!clonedRecords.isEmpty()) insert clonedRecords;
        } else {
            List<SalesAreaData__c> sadList = new List<SalesAreaData__c>();
            for(Account acc : accListList) {
                if(acc.RecordTypeId == DNSACustomerRT) {
                    sadList.add(new SalesAreaData__c(
                        Account__c              = acc.Id,
                        Country__c              = acc.CountryLookup__r.Country_Picklist__c,
                        SalesOrganization__c    = acc.SalesOrganization__c,
                        SalesDistrict__c        = acc.SalesDistrict__c,
                        SalesOffice__c          = acc.SalesOffice__c,
                        DistributionChannel__c  = acc.DistributionChannel__c,
                        Division__c             = acc.Division__c,
                        CustomerGroup__c        = acc.CareOfRigger__c ? '09' : '01',  
                        AcctAssgmtGroup__c      = currentUser.SalesDistrict__c == 'A1KR' ? '01' : '02',
                        ShipToParty__c          = acc.Id,
                        BillToParty__c          = acc.CareOfRigger__c ? acc.Id : null,
                        SoldToParty__c          = acc.CareOfRigger__c ? acc.Id : null,
                        Payer__C                = acc.CareOfRigger__c ? acc.Id : null
                    ));
                } else if(acc.RecordTypeId == prospectCustomerRT) {
                    sadList.add(new SalesAreaData__c(
                        Account__c              = acc.Id,
                        Country__c              = acc.CountryLookup__r.Country_Picklist__c,
                        SalesOrganization__c    = acc.SalesOrganization__c,
                        SalesDistrict__c        = acc.SalesDistrict__c,
                        SalesOffice__c          = acc.SalesOffice__c,
                        DistributionChannel__c  = acc.DistributionChannel__c,
                        Division__c             = acc.Division__c,

                        PriceList__c            = acc.CountryLookup__r.CountryCode__c == 'KR' ? '10' : null,
                        Incoterms__c            = acc.CountryLookup__r.CountryCode__c == 'KR' ? 'Y01' : null,
                        TermsOfPayment__c       = acc.CountryLookup__r.CountryCode__c == 'KR' ? 'C001' : null,
                        ShippingConditions__c   = acc.CountryLookup__r.CountryCode__c == 'KR' ? '10' : null,

                        AcctAssgmtGroup__c      = currentUser.SalesDistrict__c == 'A1KR' ? '01' : '02',
                        CustomerGroup__c        = '01',  
                        ShipToParty__c          = null,
                        BillToParty__c          = null,
                        SoldToParty__c          = null,
                        Payer__C                = null
                    ));
                } else if(acc.RecordTypeId == shipToPartyRT) {
                    sadList.add(new SalesAreaData__c(
                        Account__c              = acc.Id,
                        Country__c              = acc.CountryLookup__r.Country_Picklist__c,
                        SalesOrganization__c    = acc.SalesOrganization__c,
                        SalesDistrict__c        = acc.SalesDistrict__c,
                        SalesOffice__c          = acc.SalesOffice__c,
                        DistributionChannel__c  = acc.DistributionChannel__c,
                        Division__c             = acc.Division__c,
                        PriceList__c            = acc.CountryLookup__r.CountryCode__c == 'KR' ? '10' : null,
                        Incoterms__c            = acc.CountryLookup__r.CountryCode__c == 'KR' ? 'Y01' : null,
                        TermsOfPayment__c       = acc.CountryLookup__r.CountryCode__c == 'KR' ? 'C001' : null,
                        ShippingConditions__c   = acc.CountryLookup__r.CountryCode__c == 'KR' ? '10' : null,
                        AcctAssgmtGroup__c      = currentUser.SalesDistrict__c == 'A1KR' ? '01' : '02',
                        CustomerGroup__c        = '01',  
                        ShipToParty__c          = null,
                        BillToParty__c          = null,
                        SoldToParty__c          = acc.Id,
                        Payer__C                = null
                    ));
                } else if(acc.RecordTypeId == tradeCustomerRT) {
                    if(currentUser.SalesOrganization__c != '4146' && currentUser.SalesOrganization__c != '4140') {
                        sadList.add(new SalesAreaData__c(
                            Account__c              = acc.Id,
                            Currency__c             = tcd.Currency__c,
                            PriceList__c            = tcd.PriceList__c,
                            ShippingConditions__c   = tcd.ShippingConditions__c,
                            Incoterms__c            = tcd.Incoterms1__c,
                            TermsOfPayment__c       = tcd.TermsOfPayment__c,
                            CustPricProc__c         = tcd.CustPricProc__c,
                            Country__c              = acc.CountryLookup__r.Country_Picklist__c,
                            SalesOrganization__c    = tcd.SalesOrganization__c,
                            SalesDistrict__c        = tcd.SalesDistrict__c,
                            DistributionChannel__c  = tcd.DistributionChannel__c,
                            Division__c             = tcd.Division__c,
                            AcctAssgmtGroup__c      = tcd.AcctAssgmtGroup__c,
                            CustomerGroup__c        = tcd.CustomerGroup__c,
                            ShipToParty__c          = acc.Id,
                            BillToParty__c          = acc.Id,
                            SoldToParty__c          = acc.Id,
                            Payer__C                = acc.Id
                        ));
                    } 

                }else {
                    sadList.add(new SalesAreaData__c(
                        Account__c              = acc.Id,
                        Country__c              = acc.CountryLookup__r.Country_Picklist__c,
                        SalesOrganization__c    = acc.SalesOrganization__c,
                        SalesDistrict__c        = acc.SalesDistrict__c,
                        SalesOffice__c          = acc.SalesOffice__c,
                        DistributionChannel__c  = acc.DistributionChannel__c,
                        Division__c             = acc.Division__c,
                        AcctAssgmtGroup__c      = currentUser.SalesDistrict__c == 'A1KR' ? '01' : '02',
                        CustomerGroup__c        = '01',  
                        ShipToParty__c          = acc.Id,
                        BillToParty__c          = acc.Id,
                        SoldToParty__c          = acc.Id,
                        Payer__C                = acc.Id
                    ));
                }
            }
            System.debug('sadList ::: ' + sadList);
            if(!sadList.isEmpty()) insert sadList;
        }
        return;
    }

    /**
     * @Description
     * 	- Account의 IsKeyAccount__c가 true이면, KA 부문 전원에게 알람
     * @author Hanyeong Choi | 10-21-2024
     * @Parameter
     *  - keyAccList       : Account List
    **/ 
    private static void sendKeyAccountNotification(List<Account> keyAccList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New Key Account Alert' LIMIT 1];
        List<User> userList = [SELECT Id, LanguageLocaleKey FROM User WHERE Profile.Name = '영업 KA'];
        if(!userList.isEmpty()) {
            for(User u : userList) {
                if(u.LanguageLocaleKey == 'ko') {
                    receiver.add(u.Id);
                } else {
                    receiverEN.add(u.Id);
                }
            }
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(Account keyAcc : keyAccList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(keyAcc.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = keyAcc.Id;
                    history.receiverforID   = receiver;
                    history.alertLanguage   = 'ko';
                    ahwList.add(history);
                }
            }

            if(!receiverEN.isEmpty()) {
                for(Account keyAcc : keyAccList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(keyAcc.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = keyAcc.Id;
                    history.receiverforID   = receiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* Key Account로 지정 되었을때 KA에게 이메일 알람 */
    private static void sendKeyAccountEmail(List<Account> keyAccList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New Key Account Alert' LIMIT 1];
        List<User> userList = [SELECT Id, Email, LanguageLocaleKey FROM User WHERE Profile.Name = '영업 KA'];
        if(!userList.isEmpty()) {
            for(User u : userList) {
                if(u.LanguageLocaleKey == 'ko') {
                    receiver.add(u.Email);
                } else {
                    receiverEN.add(u.Email);
                }
            }
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(Account keyAcc : keyAccList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Email';
                    history.elementList.add(keyAcc.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + keyAcc.Id);
                    history.alertID         = am[0].Id;
                    history.targetID        = keyAcc.Id;
                    history.receiverforEmail   = receiver;
                    history.alertLanguage   = 'ko';
                    ahwList.add(history);
                }
            }

            if(!receiverEN.isEmpty()) {
                for(Account keyAcc : keyAccList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Email';
                    history.elementList.add(keyAcc.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + keyAcc.Id);
                    history.alertID         = am[0].Id;
                    history.targetID        = keyAcc.Id;
                    history.receiverforEmail   = receiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 고객 시스템 시작일, 종료일 알림 */
    private static void sendCustomerSystemNotification(List<Account> sendDateNotiAcc) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();
        Set<Id> accIds = new Set<Id>();

        for(Account accId: sendDateNotiAcc) {
            accIds.add(accId.Id);
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Customer System Date Alert' LIMIT 1];
        List<User> userList = [SELECT Id, LanguageLocaleKey FROM User WHERE Profile.Name = '영업 지사장' OR Profile.Name = '영업 지원' OR AccountId IN :accIds];
        if(!userList.isEmpty()) {
            for(User u : userList) {
                if(u.LanguageLocaleKey == 'ko') {
                    receiver.add(u.Id);
                } else {
                    receiverEN.add(u.Id);
                }
            }
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(Account acc : sendDateNotiAcc) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(acc.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = acc.Id;
                    history.receiverforID   = receiver;
                    history.alertLanguage   = 'ko';
                    ahwList.add(history);
                }
            }

            if(!receiverEN.isEmpty()) {
                for(Account acc : sendDateNotiAcc) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(acc.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = acc.Id;
                    history.receiverforID   = receiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }
            }
            System.debug('ahwList ::: ' + ahwList);
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 고객 시스템 이메일 알림 */
    private static void sendCustomerSystemEmail(List<Account> sendDateNotiAcc) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();
        Set<Id> accIds = new Set<Id>();

        for(Account accId: sendDateNotiAcc) {
            accIds.add(accId.Id);
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Customer System Date Alert' LIMIT 1];
        List<User> userList = [SELECT Id, Email, LanguageLocaleKey FROM User WHERE Profile.Name = '영업 지사장' OR Profile.Name = '영업 지원' OR AccountId IN :accIds];
        if(!userList.isEmpty()) {
            for(User u : userList) {
                if(u.LanguageLocaleKey == 'ko') {
                    receiver.add(u.Email);
                } else {
                    receiverEN.add(u.Email);
                }
            }
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(Account acc : sendDateNotiAcc) {
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
            }

            if(!receiverEN.isEmpty()) {
                for(Account acc : sendDateNotiAcc) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Email';
                    history.elementList.add(acc.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + acc.Id);
                    history.alertID         = am[0].Id;
                    history.targetID        = acc.Id;
                    history.receiverforEmail   = receiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }
            }

            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 실고객전환 성공 알람 */
    private static void sendConvertSuccessNoti(Set<Id> tradeIds) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Convert Trade Customer Success Alert' LIMIT 1];
        List<Account> accList = [SELECT Id, Name, OwnerId FROM Account WHERE Id IN :tradeIds];
        for(Account a : accList) {
            ownerIds.add(a.OwnerId);
        }
        List<User> userList = DN_WithoutSharingClass.getUserEmails(ownerIds);
        if(!userList.isEmpty()) {
            for(User u : userList) {
                if(u.LanguageLocaleKey == 'ko') {
                    receiver.add(u.Id);
                } else {
                    receiverEN.add(u.Id);
                }
            }
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(Account acc : accList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(acc.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = acc.Id;
                    history.receiverforID   = receiver;
                    history.alertLanguage   = 'ko';
                    ahwList.add(history);
                }
            }

            if(!receiverEN.isEmpty()) {
                for(Account acc : accList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(acc.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = acc.Id;
                    history.receiverforID   = receiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }
            }
            System.debug('ahwList ::: ' + ahwList);
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /* 실고객전환 성공 이메일 */
    private static void sendConvertSuccessEmail(Set<Id> tradeIds) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> ownerIds = new Set<Id>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Convert Trade Customer Success Alert' LIMIT 1];
        List<Account> accList = [SELECT Id, Name, OwnerId FROM Account WHERE Id IN :tradeIds];
        for(Account a : accList) {
            ownerIds.add(a.OwnerId);
        }
        List<User> userList = DN_WithoutSharingClass.getUserEmails(ownerIds);
        if(!userList.isEmpty()) {
            for(User u : userList) {
                if(u.LanguageLocaleKey == 'ko') {
                    receiver.add(u.Email);
                } else {
                    receiverEN.add(u.Email);
                }
            }
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(Account acc : accList) {
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
            }

            if(!receiverEN.isEmpty()) {
                for(Account acc : accList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Email';
                    history.elementList.add(acc.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + acc.Id);
                    history.alertID         = am[0].Id;
                    history.targetID        = acc.Id;
                    history.receiverforEmail   = receiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }
            }

            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }


    /**
     * @Description
     * 	- Account의 ParentId가 변경되면, BatchTargetRecord__c Object에 레코드 생성
     *  - Order와 Opportunity의 ParentId에 값을 넣어주기 위한 배치(DN_UpdateParentIdBatch)와 연결
     * @author Yuhyun Park | 11-22-2024
     * @Parameter
     *  - accList       : Account List
    **/ 
    private static void sendBatchRecord(List<Account> accList) {

        System.debug('accList ::: ' + accList);
        
        BatchTargetRecord__c        newRecord       = new BatchTargetRecord__c();
        List<BatchTargetRecord__c>  insertToRecord  = new List<BatchTargetRecord__c>();

        for(Account acc : accList){
            newRecord.Name              = 'DN_UpdateParentIdBatch';
            newRecord.TargetObject__c   = 'Account';
            newRecord.TargetDate__c     = System.today().addDays(1);
            newRecord.RecordId__c       = acc.Id;

            insertToRecord.add(newRecord);
        }

        if(!insertToRecord.isEmpty()){
            insert insertToRecord;
        }
    }

    /* key에서 name 추출 */
    private static Set<String> getNamesFromKeys(Set<String> keys) {
        Set<String> names = new Set<String>();
        for (String key : keys) {
            names.add(key.split(':')[0]);
        }
        return names;
    }
    
    /* key에서 대표자명 추출 */
    private static Set<String> getRepresentativesFromKeys(Set<String> keys) {
        Set<String> representatives = new Set<String>();
        for (String key : keys) {
            representatives.add(key.split(':')[1]);
        }
        return representatives;
    }

    /* 인터페이스용 주민등록번호 insert */
    private static void insertIFJumin(List<Account> accList) {
        List<String> juminList = new List<String>();
        Map<Account, String> accountToJuminMap = new Map<Account, String>();
    
        for (Account acc : accList) {
            if (String.isNotBlank(acc.ResidentRegistrationNumber__c) && acc.ResidentRegistrationNumber__c.length() >= 6) {
                String month = (Date.today().month() < 10 ? '0' : '') + Date.today().month();
                String day = (Date.today().day() < 10 ? '0' : '') + Date.today().day();
                String mmdd = month + day;
                Integer randomNumber = Math.mod(Math.abs(Crypto.getRandomInteger()), 900) + 100; // 100~999 범위
                String jumin = acc.ResidentRegistrationNumber__c.substring(0, 6) + mmdd + String.valueOf(randomNumber);
                juminList.add(jumin);
                accountToJuminMap.put(acc, jumin);
            }
        }
    
        List<Account> duplAcc = [
            SELECT Id, IF_Jumin__c
            FROM Account
            WHERE IF_Jumin__c IN :juminList
        ];
    
        Set<String> duplJuminSet = new Set<String>();
        if(!duplAcc.isEmpty()) {
            for (Account duplicate : duplAcc) {
                duplJuminSet.add(duplicate.IF_Jumin__c);
            }
        }
    
        if(!duplJuminSet.isEmpty()) {
            for (Account acc : accList) {
                if (duplJuminSet.contains(accountToJuminMap.get(acc))) {
                    String newRandomJumin;
                    do {
                        String month = (Date.today().month() < 10 ? '0' : '') + Date.today().month();
                        String day = (Date.today().day() < 10 ? '0' : '') + Date.today().day();
                        String mmdd = month + day;
                        Integer randomNumber = Math.mod(Math.abs(Crypto.getRandomInteger()), 900) + 100;
                        newRandomJumin = acc.ResidentRegistrationNumber__c.substring(0, 6) + mmdd + String.valueOf(randomNumber);
                    } while (duplJuminSet.contains(newRandomJumin));
        
                    accountToJuminMap.put(acc, newRandomJumin);
                }
            }
        }
    
        for (Account acc : accList) {
            // acc.IF_Jumin__c = accountToJuminMap.get(acc);
            if(!Test.isRunningTest()) {
                acc.put('IF_Jumin__c', accountToJuminMap.get(acc));
            } else {
                System.debug('success');
            }
        }
        return;
    }

}