/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 07-23-2025
 * @last modified by  : Hanyeong Choi
**/
global with sharing class DN_UpdateAccountFromERPBatch implements Database.Batchable<SObject>, Database.Stateful {
    // 상수 정의
    private static final Id PROSPECT_CUSTOMER_RT    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id TRADE_CUSTOMER_RT       = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
    private static final Id SHIP_TO_PARTY_RT        = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipToParty').getRecordTypeId();
    private static final Id DEALER_RT               = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id DNSA_RT                 = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();

    private static final String SALES_ORG_1800          = '1800';
    private static final String SALES_ORG_4140          = '4140';
    private static final String SALES_ORG_4146          = '4146';
    private static final String SALES_ORG_1140          = '1140';
    private static final String TEAM_ROLE_SALES_MANAGER = 'Sales Manager';

    // 인스턴스 변수
    private Map<String, List<IF_Account__c>>    customerCodeToIfAccs    = new Map<String, List<IF_Account__c>>();
    private List<IF_Account__c>                 kna1Records             = new List<IF_Account__c>();
    private Map<Id, IF_Account__c>              ifAccToUpdate           = new Map<Id, IF_Account__c>();

    /**
     * 배치 작업을 시작하며, 처리되지 않은 IF_Account__c 레코드를 조회합니다.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('DN_UpdateAccountFromERPBatch Start ------------');
        String query;
        query =  'SELECT Id, KUNNR__c, NAME1__c, TABLE_NAME__c, AUFSD__c, KTOKD__c, KDGRP__c, LAND1__c, REGIO_T__c, LANDX__c, ' +
                'STRAS__c, ORT01__c, PSTLZ__c, TELFX__c, SMTP_ADDR__c, ZWEBPAGE__c, TELF1__c, TELF2__c, VKBUR__c, ' +
                'KATR1__c, KATR2__c, KATR3__c, LZONE__c, SORTL__c, LOCATION__c, BZIRK__c, WAERS__c, IsComplete__c, STR_SUPPL1__c, STR_SUPPL2__c, STR_SUPPL3__c, ' +
                'ERROR__c, CreatedDate, J_1KFREPRE__c, SORT1__c, SORT2__c, VTEXT2__c, STCD2__c, STCD3__c, STCD4__c, VKORG__c, KUNN2__c, FLAG__c ' +
                'FROM IF_Account__c ' +
                'WHERE IsComplete__c = false AND TABLE_NAME__c = \'KNA1\' AND LAND1__c != \'CN\' AND AUFSD__c != \'X\' ' +
                'ORDER BY CreatedDate ASC LIMIT 1000';        

        return Database.getQueryLocator(query);
    }

    /**
     * 배치 작업을 실행하여 ERP 데이터를 기반으로 Account, SalesAreaData__c, DNS_CustomerDealerAssociation__c, AccountTeamMember를 처리합니다.
     */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('DN_UpdateAccountFromERPBatch Execute ------------');
        bypassTriggers();

        List<IF_Account__c> kna1List = (List<IF_Account__c>) scope;
        if (kna1List.isEmpty()) return;

        Set<String> deleteKunnrs = new Set<String>();
        Set<String> kunnrs = new Set<String>();
        for (IF_Account__c ifAcc : kna1List) {
            System.debug('ifAcc ::: ' + ifAcc.NAME1__c);
            if(ifAcc.FLAG__c == 'X') {
                deleteKunnrs.add(removeLeadingZeros(ifAcc.KUNNR__c));
            }
            else if(ifAcc.AUFSD__c == 'X'){ // Block일떄
                ifAcc.IsComplete__c = false;
                if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success' || (ifAcc.ERROR__c != null && ifAcc.ERROR__c.contains('Skipped: Account is Block'))){
                    ifAcc.ERROR__c = 'Skipped: Account is Block';
                }
                ifAccToUpdate.put(ifAcc.Id, ifAcc);
                continue;
            }

            String customerCode = removeLeadingZeros(ifAcc.KUNNR__c);
            if (ifAcc.LAND1__c == 'CN') {
                ifAcc.IsComplete__c = false;
                if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                    ifAcc.ERROR__c = 'Skipped: CountryCode is CN';
                }
                ifAccToUpdate.put(ifAcc.Id, ifAcc);
                continue;
            }
            if (String.isNotBlank(customerCode)) {
                if (!customerCodeToIfAccs.containsKey(customerCode)) {
                    customerCodeToIfAccs.put(customerCode, new List<IF_Account__c>());
                }
                customerCodeToIfAccs.get(customerCode).add(ifAcc);
                kunnrs.add(customerCode);
            }
            kna1Records.add(ifAcc);
        }

        // KNVV 레코드 동적 조회
        List<IF_Account__c> knvvList = [
            SELECT  Id
                    , KUNNR__c
                    , KUNN2__c
                    , NAME1__c
                    , TABLE_NAME__c
                    , VKORG__c
                    , VTWEG__c
                    , SPART__c
                    , KDGRP__c
                    , VKBUR__c
                    , BZIRK__c
                    , WAERS__c
                    , IsComplete__c
                    , ERROR__c
            FROM IF_Account__c
            WHERE KUNNR__c IN :kunnrs
            AND TABLE_NAME__c = 'KNVV'
            AND IsComplete__c = false
            AND AUFSD__c != 'X'
        ];
        for (IF_Account__c knvv : knvvList) {
            String customerCode = removeLeadingZeros(knvv.KUNNR__c);
            if (String.isNotBlank(customerCode)) {
                if (!customerCodeToIfAccs.containsKey(customerCode)) {
                    customerCodeToIfAccs.put(customerCode, new List<IF_Account__c>());
                }
                customerCodeToIfAccs.get(customerCode).add(knvv);
            }
        }

        // KNVP 레코드 동적 조회
        List<IF_Account__c> knvpList = [
            SELECT  Id
                    , KUNNR__c
                    , NAME1__c
                    , TABLE_NAME__c
                    , PARVW__c
                    , KUNN2__c
                    , VKORG__c
                    , IsComplete__c
                    , ERROR__c
            FROM IF_Account__c
            WHERE KUNNR__c IN :kunnrs
            AND TABLE_NAME__c = 'KNVP'
            AND IsComplete__c = false
            AND AUFSD__c != 'X'
            AND PARVW__c != 'Z1'
            AND PARVW__c != 'Z2'
        ];
        for (IF_Account__c knvp : knvpList) {
            String customerCode = removeLeadingZeros(knvp.KUNNR__c);
            String partnerCode = removeLeadingZeros(knvp.KUNN2__c);
            if (String.isNotBlank(customerCode)) {
                if (!customerCodeToIfAccs.containsKey(customerCode)) {
                    customerCodeToIfAccs.put(customerCode, new List<IF_Account__c>());
                }
                customerCodeToIfAccs.get(customerCode).add(knvp);
            }
            if (String.isNotBlank(partnerCode)) {
                if (!customerCodeToIfAccs.containsKey(partnerCode)) {
                    customerCodeToIfAccs.put(partnerCode, new List<IF_Account__c>());
                }
                customerCodeToIfAccs.get(partnerCode).add(knvp);
            }
        }

        if (!customerCodeToIfAccs.isEmpty()) {
            setAccount(customerCodeToIfAccs, kna1Records, ifAccToUpdate, deleteKunnrs);
        }

        System.debug('SOQL Queries Used: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
    }

    /**
     * 배치 작업을 완료하고 후속 배치를 실행합니다.
     */
    global void finish(Database.BatchableContext bc) {
        clearBypassTriggers();

        if(!Test.isRunningTest()) {
            List<IF_Account__c> updateIfAccList = new List<IF_Account__c>();
            for(IF_Account__c i : ifAccToUpdate.values()) {
                updateIfAccList.add(i);
            }
    
            IF_ERP_AccountAfterBatch converter = new IF_ERP_AccountAfterBatch(updateIfAccList);
            Database.executeBatch(converter);
        }

        System.debug('DN_UpdateAccountFromERPBatch Finish ------------');
    }

    /**
     * Account, SalesAreaData__c, DNS_CustomerDealerAssociation__c, AccountTeamMember를 설정하고 처리합니다.
     */
    private static void setAccount(Map<String, List<IF_Account__c>> customerCodeToIfAccs, List<IF_Account__c> kna1Records, Map<Id, IF_Account__c> ifAccToUpdate, Set<String> deleteKunnrs) {
        Map<String, Country__c>             countryMap  = fetchCountryMap(kna1Records);
        Map<String, Region__c>              regionMap   = fetchRegionMap(kna1Records);
        Map<String, TransportationZone__c>  zoneMap     = fetchZoneMap(kna1Records);
        
        Map<String, List<Account>> customerCodeToAccounts = new Map<String, List<Account>>();
        // 기존 Account 조회
        List<Account> accountList = [
            SELECT  Id
                    , CustomerCode__c
                    , RecordTypeId
                    , SalesOrganization__c
                    , SalesOrganization_CS__c
                    , CareOfRigger__c
                    , BusinessNumberDuplCheck__c
                    , businessNumber__c
                    , IsBusinessLicense__c
                    , DetailAddress__c
            FROM Account
            WHERE CustomerCode__c IN :customerCodeToIfAccs.keySet()
            AND RecordTypeId IN (:TRADE_CUSTOMER_RT, :DEALER_RT, :PROSPECT_CUSTOMER_RT, :SHIP_TO_PARTY_RT, :DNSA_RT)
            AND CountryLookup__r.CountryCode__c != 'CN'
        ];

        for (Account acc : accountList) {
            if (!customerCodeToAccounts.containsKey(acc.CustomerCode__c)) {
                customerCodeToAccounts.put(acc.CustomerCode__c, new List<Account>());
            }
            customerCodeToAccounts.get(acc.CustomerCode__c).add(acc);
        }

        List<Account> insertAccountList = new List<Account>();
        List<Account> updateAccountList = new List<Account>();

        Map<String, Account>        processedAccounts       = new Map<String, Account>();
        Map<Account, String>        accountToCustomerCode   = new Map<Account, String>();
        Map<String, IF_Account__c>  customerCodeToKna1      = new Map<String, IF_Account__c>();

        for (IF_Account__c ifAcc : kna1Records) {
            String customerCode = removeLeadingZeros(ifAcc.KUNNR__c);
            customerCodeToKna1.put(customerCode, ifAcc);
        }

        // IF_Account__c를 KDGRP__c별로 그룹화
        Map<String, Map<Id, List<IF_Account__c>>> customerCodeToRecordTypeMap = new Map<String, Map<Id, List<IF_Account__c>>>();
        for (String customerCode : customerCodeToIfAccs.keySet()) {
            Map<Id, List<IF_Account__c>> recordTypeToIfAccs = new Map<Id, List<IF_Account__c>>();
            IF_Account__c kna1Record = customerCodeToKna1.get(customerCode);

            List<IF_Account__c> knvvRecords = new List<IF_Account__c>();
            for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                if (ifAcc.TABLE_NAME__c == 'KNVV') {
                    knvvRecords.add(ifAcc);
                }
            }

            if (knvvRecords.isEmpty() && kna1Record != null) {
                for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                    ifAcc.IsComplete__c = false;
                    if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                        ifAcc.ERROR__c      = 'No KNVV record found for CustomerCode: ' + customerCode;
                    }
                    ifAccToUpdate.put(ifAcc.Id, ifAcc);
                }
                continue;
            }

            // KNVV의 KDGRP__c별로 RecordType 처리
            Map<String, List<IF_Account__c>> kdgrpToIfAccs = new Map<String, List<IF_Account__c>>();
            for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                if (ifAcc.TABLE_NAME__c == 'KNVV' && ifAcc.KDGRP__c != null) {
                    String kdgrp = ifAcc.KDGRP__c;
                    if (!kdgrpToIfAccs.containsKey(kdgrp)) {
                        kdgrpToIfAccs.put(kdgrp, new List<IF_Account__c>());
                    }
                    kdgrpToIfAccs.get(kdgrp).add(ifAcc);
                } else if (ifAcc.TABLE_NAME__c != 'KNVV') {
                    String kdgrp = 'NON_KNVV';
                    if (!kdgrpToIfAccs.containsKey(kdgrp)) {
                        kdgrpToIfAccs.put(kdgrp, new List<IF_Account__c>());
                    }
                    kdgrpToIfAccs.get(kdgrp).add(ifAcc);
                }
            }

            for (String kdgrp : kdgrpToIfAccs.keySet()) {
                if (kdgrp == 'NON_KNVV') continue; // KNVV 아닌 레코드는 RecordType 처리에서 제외
                Id recordTypeId = null;
                if (kna1Record != null && kna1Record.KDGRP__c == kdgrp) {
                    recordTypeId = determineRecordType(kna1Record.KTOKD__c, kdgrp, null);
                }
                
                if (recordTypeId != null) {
                    if (!recordTypeToIfAccs.containsKey(recordTypeId)) {
                        recordTypeToIfAccs.put(recordTypeId, new List<IF_Account__c>());
                    }
                    recordTypeToIfAccs.get(recordTypeId).addAll(kdgrpToIfAccs.get(kdgrp));
                    if (kdgrpToIfAccs.containsKey('NON_KNVV')) {
                        recordTypeToIfAccs.get(recordTypeId).addAll(kdgrpToIfAccs.get('NON_KNVV'));
                    }
                } else {
                    for (IF_Account__c ifAcc : kdgrpToIfAccs.get(kdgrp)) {
                        System.debug('No RecordType for IF_Account__c: ' + ifAcc.Id + ', CustomerCode: ' + customerCode + ', KDGRP__c: ' + kdgrp);

                        ifAcc.IsComplete__c = false;
                        if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                            ifAcc.ERROR__c      = 'Invalid RecordType: KTOKD__c=' + (kna1Record != null ? kna1Record.KTOKD__c : 'null') + ', KDGRP__c=' + kdgrp;
                        }
                        ifAccToUpdate.put(ifAcc.Id, ifAcc);
                    }
                    if (kdgrpToIfAccs.containsKey('NON_KNVV')) {
                        for (IF_Account__c ifAcc : kdgrpToIfAccs.get('NON_KNVV')) {
                            ifAcc.IsComplete__c = false;
                            if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                                ifAcc.ERROR__c      = 'Invalid RecordType: No valid KNVV for CustomerCode: ' + customerCode;
                            }
                            ifAccToUpdate.put(ifAcc.Id, ifAcc);
                        }
                    }
                }
            }
            customerCodeToRecordTypeMap.put(customerCode, recordTypeToIfAccs);
        }

        // Account 처리
        for (String customerCode : customerCodeToRecordTypeMap.keySet()) {
            Map<Id, List<IF_Account__c>> recordTypeToIfAccs = customerCodeToRecordTypeMap.get(customerCode);

            List<Account> existingAccounts = customerCodeToAccounts.get(customerCode) != null ? customerCodeToAccounts.get(customerCode) : new List<Account>();

            IF_Account__c kna1Record = customerCodeToKna1.get(customerCode);

            for (Id recordTypeId : recordTypeToIfAccs.keySet()) {
                List<IF_Account__c> ifAccList = recordTypeToIfAccs.get(recordTypeId);

                List<IF_Account__c> knvvRecords = new List<IF_Account__c>();
                List<IF_Account__c> knvpRecords = new List<IF_Account__c>();

                for (IF_Account__c ifAcc : ifAccList) {
                    if (ifAcc.TABLE_NAME__c == 'KNVV') {
                        knvvRecords.add(ifAcc);
                    } else if (ifAcc.TABLE_NAME__c == 'KNVP') {
                        knvpRecords.add(ifAcc);
                    }
                }

                if (kna1Record == null && recordTypeId != DEALER_RT) {
                    System.debug('No KNA1 for CustomerCode: ' + customerCode + ', RecordType: ' + recordTypeId);
                    for (IF_Account__c ifAcc : ifAccList) {
                        ifAcc.IsComplete__c = false;
                    if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                        ifAcc.ERROR__c      = 'No KNA1 record found for RecordType: ' + recordTypeId;
                    }
                        ifAccToUpdate.put(ifAcc.Id, ifAcc);
                    }
                    continue;
                }

                String uniqueKey = customerCode + '-' + recordTypeId;
                Account acc;

                if (recordTypeId == TRADE_CUSTOMER_RT) {
                    Account existing = null;
                    for (Account a : existingAccounts) {
                        if (a.RecordTypeId == PROSPECT_CUSTOMER_RT || a.RecordTypeId == TRADE_CUSTOMER_RT) {
                            existing = a;
                            break;
                        }
                    }
                    acc = existing != null ? existing : new Account(CustomerCode__c = customerCode);
                } else if (recordTypeId == DEALER_RT) {
                    Account existing = null;
                    for (Account a : existingAccounts) {
                        if (a.RecordTypeId == DEALER_RT) {
                            existing = a;
                            break;
                        }
                    }
                    acc = existing != null ? existing : new Account(CustomerCode__c = customerCode);
                } else {
                    acc = existingAccounts.isEmpty() ? new Account(CustomerCode__c = customerCode) : existingAccounts[0];
                }

                acc.RecordTypeId = recordTypeId;
                if (kna1Record != null) {
                    acc = mappingAccount(acc, kna1Record, countryMap, regionMap, zoneMap);
                }

                // KNVV에서 SalesOrganization__c 등 매핑
                IF_Account__c selectedKnvv = null;
                for (IF_Account__c knvv : knvvRecords) {
                    if (knvv.VKORG__c == '1800') {
                        selectedKnvv = knvv;
                        break; // 1800 찾으면 즉시 종료
                    } else if (knvv.VKORG__c == '4140' && selectedKnvv == null) {
                        selectedKnvv = knvv; // 4140 저장, 1800 나올 가능성 있음
                    }
                }
                if (selectedKnvv == null && kna1Record != null && String.isNotBlank(kna1Record.VKORG__c)) {
                    for (IF_Account__c knvv : knvvRecords) {
                        if (knvv.VKORG__c == kna1Record.VKORG__c) {
                            selectedKnvv = knvv;
                            break;
                        }
                    }
                }
                if (selectedKnvv != null) {
                    acc.SalesOrganization__c    = selectedKnvv.VKORG__c;
                    acc.DistributionChannel__c  = selectedKnvv.VTWEG__c;
                    acc.Division__c             = selectedKnvv.SPART__c;
                    acc.SalesOffice__c          = selectedKnvv.VKBUR__c;
                    acc.SalesDistrict__c        = selectedKnvv.BZIRK__c;
                }

                System.debug('Processing CustomerCode: ' + customerCode + ', RecordType: ' + recordTypeId);
                if (!processedAccounts.containsKey(uniqueKey)) {
                    processedAccounts.put(uniqueKey, acc);
                    accountToCustomerCode.put(acc, customerCode);
                    if (acc.Id != null) {
                        updateAccountList.add(acc);
                    } else {
                        insertAccountList.add(acc);
                    }
                }

                // IF_Account__c 상태 업데이트 (Account 단계)
                for (IF_Account__c ifAcc : ifAccList) {
                    if (!ifAccToUpdate.containsKey(ifAcc.Id)) {
                        ifAcc.IsComplete__c = true;
                        ifAcc.ERROR__c      = 'Success';
                        ifAccToUpdate.put(ifAcc.Id, ifAcc);
                    }
                }
            }
        }

        List<Account> deleteAccountList = new List<Account>();
        List<Account> delAccountList = new List<Account>();
        if(!deleteKunnrs.isEmpty()) {
            deleteAccountList = [SELECT Id, Name, Active_Dealer__c, Inactive__c, IsBlocked__c, IsErpDelete__c, CustomerCode__c, DetailAddress__c FROM Account WHERE CustomerCode__c IN :deleteKunnrs];
            if(!deleteAccountList.isEmpty()) {
                for(Account delAcc : deleteAccountList) {
                    if(!delAcc.Name.contains('(삭제)')) delAcc.Name = '(삭제) ' + delAcc.Name;
                    if(delAcc.Active_Dealer__c) delAcc.Active_Dealer__c = false;
                    delAcc.Inactive__c = true;
                    delAcc.IsBlocked__c = true;
                    delAcc.IsErpDelete__c = true;
                    delAccountList.add(delAcc);
                }
            }
        }
        // Account DML
        System.debug('insertAccountList: ' + insertAccountList.size());
        System.debug('updateAccountList: ' + updateAccountList.size());
        System.debug('delAccountList: ' + delAccountList.size());

        try {
            // Deduplicate insertAccountList
            Map<String, Account> insertAccountMap = new Map<String, Account>();
            for (Account acc : insertAccountList) {
                System.debug('acc ::: ' + acc.Name);
                String key = acc.CustomerCode__c + '-' + acc.RecordTypeId;
                insertAccountMap.put(key, acc);
            }
            insertAccountList = insertAccountMap.values();

            // Deduplicate updateAccountList
            Map<Id, Account> updateAccountMap = new Map<Id, Account>();
            for (Account acc : updateAccountList) {
                updateAccountMap.put(acc.Id, acc);
            }
            updateAccountList = updateAccountMap.values();

            if (!insertAccountList.isEmpty()) {
                Database.SaveResult[] results = Database.insert(insertAccountList, false);
                for (Integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr = results[i];
                    Account acc         = insertAccountList[i];
                    System.debug('acc2 ::: ' + acc.Name);
                    System.debug('sr.isSuccess() ::: ' + sr.isSuccess());
                    String customerCode = accountToCustomerCode.get(acc);
                    
                    if (!sr.isSuccess()) {
                        System.debug('sr.getErrors()[0].getMessage() ::: ' + sr.getErrors()[0].getMessage());
                        for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                            ifAcc.IsComplete__c = false;
                        if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                            ifAcc.ERROR__c      = 'Account insert failed: ' + sr.getErrors()[0].getMessage();
                        }

                            ifAccToUpdate.put(ifAcc.Id, ifAcc);
                        }
                    }
                }
            }

            if (!updateAccountList.isEmpty()) {
                Database.SaveResult[] results = Database.update(updateAccountList, false);
                for (Integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr = results[i];
                    Account acc         = updateAccountList[i];
                    String customerCode = accountToCustomerCode.get(acc);

                    if (!sr.isSuccess()) {
                        for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                            ifAcc.IsComplete__c = false;
                            if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                                ifAcc.ERROR__c      = 'Account update failed: ' + sr.getErrors()[0].getMessage();
                            }

                            ifAccToUpdate.put(ifAcc.Id, ifAcc);
                        }
                    }
                }
            }

            Map<Id, Account> deleteAccountMap = new Map<Id, Account>();
            if(!delAccountList.isEmpty()) {
                for (Account acc : delAccountList) {
                    deleteAccountMap.put(acc.Id, acc);
                }
                delAccountList = deleteAccountMap.values();

                if (!delAccountList.isEmpty()) {
                    Database.SaveResult[] results = Database.update(delAccountList, false);
                    for (Integer i = 0; i < results.size(); i++) {
                        Database.SaveResult sr = results[i];
                        Account acc         = delAccountList[i];
                        String customerCode = acc.CustomerCode__c;

                        if (sr.isSuccess()) {
                            if (customerCodeToIfAccs.containsKey(customerCode)) {
                                for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                                    ifAcc.IsComplete__c = true;
                                    ifAcc.ERROR__c      = 'Success: Account marked as deleted';
                                    ifAccToUpdate.put(ifAcc.Id, ifAcc);
                                }
                                customerCodeToIfAccs.remove(customerCode);
                                customerCodeToRecordTypeMap.remove(customerCode);
                            }
                        } else {
                            if (customerCodeToIfAccs.containsKey(customerCode)) {
                                for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                                    ifAcc.IsComplete__c = false;
                                if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                                    ifAcc.ERROR__c      = 'Account delete failed: ' + sr.getErrors()[0].getMessage();
                                }

                                    ifAccToUpdate.put(ifAcc.Id, ifAcc);
                                }
                            }
                        }
                    }
                }
            }

            // Account 재쿼리
            Map<String, Account> accountMap = new Map<String, Account>();
            accountList = [
                SELECT  Id
                        , CustomerCode__c
                        , RecordTypeId
                        , BusinessNumberDuplCheck__c
                        , businessNumber__c
                        , IsBusinessLicense__c
                        , DetailAddress__c
                FROM Account
                WHERE CustomerCode__c IN :customerCodeToIfAccs.keySet()
                AND CountryLookup__r.CountryCode__c != 'CN'
                AND Inactive__c = false
            ];
            
            for (Account acc : accountList) {
                String key = acc.CustomerCode__c + '-' + acc.RecordTypeId;
                accountMap.put(key, acc);
            }

            // SalesAreaData__c, DNS_CustomerDealerAssociation__c, AccountTeamMember 처리
            List<SalesAreaData__c> insertSadList = new List<SalesAreaData__c>();
            List<SalesAreaData__c> updateSadList = new List<SalesAreaData__c>();

            List<DNS_CustomerDealerAssociation__c> dealerToInsert = new List<DNS_CustomerDealerAssociation__c>();
            List<DNS_CustomerDealerAssociation__c> dealerToDelete = new List<DNS_CustomerDealerAssociation__c>();

            List<AccountTeamMember> teamToInsert = new List<AccountTeamMember>();
            List<AccountTeamMember> teamToDelete = new List<AccountTeamMember>();

            // SalesAreaData__c 기존 레코드 조회
            Map<String, SalesAreaData__c> sadMap = new Map<String, SalesAreaData__c>();
            List<SalesAreaData__c> sadQueryList = [
                SELECT  Id
                        , Account__c
                        , Account__r.CustomerCode__c
                        , Account__r.RecordTypeId
                        , Account__r.Inactive__c
                        , SalesOrganization__c
                        , DistributionChannel__c
                        , Division__c
                        , ShipToParty__c
                        , BillToParty__c
                        , SoldToParty__c
                        , Payer__c
                FROM SalesAreaData__c
                WHERE Account__r.CustomerCode__c IN :customerCodeToIfAccs.keySet()
                AND Account__r.Inactive__c = false
            ];
            for (SalesAreaData__c sad : sadQueryList) {
                // String key = sad.Account__r.CustomerCode__c + '-' + sad.Account__r.RecordTypeId + '-' + sad.SalesOrganization__c + '-' + sad.DistributionChannel__c + '-' + sad.Division__c;
                String key = sad.Account__r.CustomerCode__c + '-' + sad.SalesOrganization__c + '-' + sad.DistributionChannel__c + '-' + sad.Division__c;
                sadMap.put(key, sad);
            }

            // KNVP 처리용 Account 조회
            Set<String> allCustomerCodes = new Set<String>();
            for (List<IF_Account__c> ifAccList : customerCodeToIfAccs.values()) {
                for (IF_Account__c ifAcc : ifAccList) {
                    if (ifAcc.KUNN2__c != null) {
                        allCustomerCodes.add(removeLeadingZeros(ifAcc.KUNN2__c));
                    }
                }
            }

            Map<String, Account> customerCodeToAccountMap = new Map<String, Account>();
            for (Account acc : accountList) {
                if (acc.RecordTypeId == DEALER_RT) {
                    customerCodeToAccountMap.put(acc.CustomerCode__c, acc);
                    System.debug('Mapped Dealer Account: CustomerCode__c=' + acc.CustomerCode__c + ', Id=' + acc.Id);
                }
            }
            System.debug('customerCodeToAccountMap size: ' + customerCodeToAccountMap.size());

            // User 조회 (ZM 처리)
            Set<String> partnerCodes = new Set<String>();
            for (String customerCode : customerCodeToIfAccs.keySet()) {
                for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                    if (ifAcc.TABLE_NAME__c == 'KNVP' && ifAcc.PARVW__c == 'ZM' && ifAcc.KUNN2__c != null) {
                        partnerCodes.add(removeLeadingZeros(ifAcc.KUNN2__c));
                    }
                }
            }
            Map<String, User> userMap = new Map<String, User>();
            List<User> users = [
                SELECT  Id
                        , CustomerCode__c 
                FROM User 
                WHERE CustomerCode__c IN :partnerCodes
            ];
            for (User u : users) {
                userMap.put(u.CustomerCode__c, u);
            }

            // 기존 Dealer 및 Team 조회
            Map<String, List<DNS_CustomerDealerAssociation__c>> existingDealers = new Map<String, List<DNS_CustomerDealerAssociation__c>>();
            Map<String, List<AccountTeamMember>>                existingTeams   = new Map<String, List<AccountTeamMember>>();

            List<DNS_CustomerDealerAssociation__c> dealerList = [
                SELECT  Id
                        , Customer__c
                        , Dealer__c
                FROM DNS_CustomerDealerAssociation__c
                WHERE Customer__r.CustomerCode__c IN :customerCodeToIfAccs.keySet()
            ];
            for (DNS_CustomerDealerAssociation__c dealer : dealerList) {
                String key = dealer.Customer__c;
                if (!existingDealers.containsKey(key)) {
                    existingDealers.put(key, new List<DNS_CustomerDealerAssociation__c>());
                }
                existingDealers.get(key).add(dealer);
            }
            List<AccountTeamMember> accTeams = [
                SELECT  Id
                        , AccountId
                        , UserId
                        , TeamMemberRole
                FROM AccountTeamMember
                WHERE AccountId IN :accountList
            ];
            for (AccountTeamMember team : accTeams) {
                String key = team.AccountId;
                if (!existingTeams.containsKey(key)) {
                    existingTeams.put(key, new List<AccountTeamMember>());
                }
                existingTeams.get(key).add(team);
            }

            // SalesAreaData__c, KNVP, ZI, ZM 처리
            for (String customerCode : customerCodeToRecordTypeMap.keySet()) {
                Map<Id, List<IF_Account__c>> recordTypeToIfAccs = customerCodeToRecordTypeMap.get(customerCode);

                IF_Account__c kna1Record = customerCodeToKna1.get(customerCode);

                for (Id recordTypeId : recordTypeToIfAccs.keySet()) {
                    List<IF_Account__c> ifAccList = recordTypeToIfAccs.get(recordTypeId);

                    List<IF_Account__c> knvvRecords = new List<IF_Account__c>();
                    List<IF_Account__c> knvpRecords = new List<IF_Account__c>();

                    for (IF_Account__c ifAcc : ifAccList) {
                        if (ifAcc.TABLE_NAME__c == 'KNVV') {
                            knvvRecords.add(ifAcc);
                        } else if (ifAcc.TABLE_NAME__c == 'KNVP') {
                            knvpRecords.add(ifAcc);
                        }
                    }

                    String uniqueKey    = customerCode + '-' + recordTypeId;
                    Account acc         = accountMap.get(uniqueKey);
                    if (acc == null) {
                        for (IF_Account__c ifAcc : ifAccList) {
                            ifAcc.IsComplete__c = false;
                            if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                                ifAcc.ERROR__c      = 'Account not found after DML: ' + uniqueKey;
                            }
                            ifAccToUpdate.put(ifAcc.Id, ifAcc);
                        }
                        continue;
                    }

                    // SalesAreaData__c 처리
                    for (IF_Account__c knvv : knvvRecords) {
                        // String sadKey = customerCode + '-' + recordTypeId + '-' + knvv.VKORG__c + '-' + knvv.VTWEG__c + '-' + knvv.SPART__c;
                        String sadKey = customerCode + '-' + knvv.VKORG__c + '-' + knvv.VTWEG__c + '-' + knvv.SPART__c;
                        SalesAreaData__c sad;
                        if (sadMap.containsKey(sadKey) && sadMap.get(sadKey).Account__c == acc.Id) {
                            sad = sadMap.get(sadKey);
                        } else {
                            sad = new SalesAreaData__c(Account__c = acc.Id);
                        }
                        sad.SalesOrganization__c    = knvv.VKORG__c;
                        sad.DistributionChannel__c  = knvv.VTWEG__c;
                        sad.Division__c             = knvv.SPART__c;
                        sad.CustomerGroup__c        = knvv.KDGRP__c;
                        sad.SalesOffice__c          = knvv.VKBUR__c;
                        sad.SalesDistrict__c        = knvv.BZIRK__c;
                        sad.Currency__c             = knvv.WAERS__c;

                        if (sad.Id != null) {
                            updateSadList.add(sad);
                        } else {
                            insertSadList.add(sad);
                        }
                    }

                    // KNVP 처리
                    Map<String, String> roles = new Map<String, String>();

                    List<IF_Account__c> ziRecords = new List<IF_Account__c>();
                    List<IF_Account__c> zmRecords = new List<IF_Account__c>();

                    for (IF_Account__c knvp : knvpRecords) {
                        String partnerCode  = removeLeadingZeros(knvp.KUNN2__c);
                        Account partnerAcc  = customerCodeToAccountMap.get(partnerCode);
                        if (knvp.PARVW__c == 'WE' || knvp.PARVW__c == 'RE' || knvp.PARVW__c == 'AG' || knvp.PARVW__c == 'RG') {
                            if (partnerAcc != null) {
                                roles.put(knvp.PARVW__c, partnerAcc.Id);
                            }
                        } else if (knvp.PARVW__c == 'ZI') {
                            ziRecords.add(knvp);
                        } else if (knvp.PARVW__c == 'ZM') {
                            zmRecords.add(knvp);
                        }
                    }

                    // SalesAreaData__c 역할 업데이트
                    for (SalesAreaData__c sad : insertSadList) {
                        if (sad.Account__c == acc.Id) {
                            if (roles.containsKey('WE')) sad.ShipToParty__c = roles.get('WE');
                            if (roles.containsKey('RE')) sad.BillToParty__c = roles.get('RE');
                            if (roles.containsKey('AG')) sad.SoldToParty__c = roles.get('AG');
                            if (roles.containsKey('RG')) sad.Payer__c = roles.get('RG');
                        }
                    }
                    for (SalesAreaData__c sad : updateSadList) {
                        if (sad.Account__c == acc.Id) {
                            if (roles.containsKey('WE')) sad.ShipToParty__c = roles.get('WE');
                            if (roles.containsKey('RE')) sad.BillToParty__c = roles.get('RE');
                            if (roles.containsKey('AG')) sad.SoldToParty__c = roles.get('AG');
                            if (roles.containsKey('RG')) sad.Payer__c = roles.get('RG');
                        }
                    }

                    // ZI가 아예 없으면: 기존 CRM 매핑 전부 삭제 후 ZI 처리 스킵
                    if (ziRecords.isEmpty()) {
                        List<DNS_CustomerDealerAssociation__c> existing =
                            existingDealers.get(acc.Id) != null ? existingDealers.get(acc.Id) : new List<DNS_CustomerDealerAssociation__c>();

                        // 중복 방지용(로컬) — 삭제 레코드 Id를 문자열로 관리
                        Set<String> dealerRowIdsToDelete = new Set<String>();

                        for (DNS_CustomerDealerAssociation__c d : existing) {
                            String rowId = String.valueOf(d.Id);
                            if (!dealerRowIdsToDelete.contains(rowId)) {
                                dealerToDelete.add(d);
                                dealerRowIdsToDelete.add(rowId);
                            }
                        }

                        // (선택) 관련 IF_Account__c 상태 표시
                        for (IF_Account__c ifAcc : ifAccList) {
                            if (!ifAccToUpdate.containsKey(ifAcc.Id)) {
                                ifAcc.IsComplete__c = true;
                                if (ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success') {
                                    ifAcc.ERROR__c = 'Deleted dealers: no ZI in KNVP';
                                }
                                ifAccToUpdate.put(ifAcc.Id, ifAcc);
                            }
                        }

                        continue; // 아래 ZI 처리 블록은 건너뜀
                    }

                    // ZI (Related Dealer)
                    if (!ziRecords.isEmpty()) {
                        List<DNS_CustomerDealerAssociation__c> existing = existingDealers.get(acc.Id) != null ? existingDealers.get(acc.Id) : new List<DNS_CustomerDealerAssociation__c>();
            
                        Map<String, DNS_CustomerDealerAssociation__c> existingDealerMap = new Map<String, DNS_CustomerDealerAssociation__c>();
                        Set<String> expectedDealerIds = new Set<String>();
                        Set<Id> dealerIdsToDelete = new Set<Id>(); // 중복 방지용 Set

                        // 기존 딜러 매핑
                        for (DNS_CustomerDealerAssociation__c dealer : existing) {
                            existingDealerMap.put(dealer.Dealer__c, dealer);
                        }

                        for (IF_Account__c zi : ziRecords) {
                            String partnerCode = removeLeadingZeros(zi.KUNN2__c);
                            System.debug('Processing ZI for CustomerCode: ' + customerCode + ', KUNN2__c: ' + partnerCode);
                            Account dealerAcc = customerCodeToAccountMap.get(partnerCode);

                            if (zi.VKORG__c != SALES_ORG_1800 && zi.VKORG__c != SALES_ORG_4140) {
                                zi.IsComplete__c = true;
                                zi.ERROR__c = 'Skipped: KNVP for PARVW__c ZI';

                                // CRM에 이미 존재하는 Dealer 레코드 확인 및 삭제
                                if (dealerAcc != null && existingDealerMap.containsKey(dealerAcc.Id)) {
                                    DNS_CustomerDealerAssociation__c dealerToRemove = existingDealerMap.get(dealerAcc.Id);
                                    if (!dealerIdsToDelete.contains(dealerToRemove.Id)) {
                                        dealerToDelete.add(dealerToRemove);
                                        dealerIdsToDelete.add(dealerToRemove.Id);
                                    }
                                }

                                ifAccToUpdate.put(zi.Id, zi);
                                continue;
                            }

                            if (dealerAcc == null || dealerAcc.RecordTypeId != DEALER_RT) {
                                System.debug('Dealer not found or not Dealer RecordType for KUNN2__c: ' + partnerCode + ', dealerAcc: ' + dealerAcc);
                                zi.IsComplete__c = false;
                                if(zi.ERROR__c == '' || zi.ERROR__c == 'Success'){
                                    zi.ERROR__c = 'Dealer not found for KUNN2__c: ' + partnerCode;
                                }

                                ifAccToUpdate.put(zi.Id, zi);
                                continue;
                            }

                            System.debug('Found Dealer Account: Id=' + dealerAcc.Id + ', CustomerCode__c=' + dealerAcc.CustomerCode__c);
                            if (existingDealerMap.containsKey(dealerAcc.Id)) {
                                zi.IsComplete__c = true;
                                zi.ERROR__c = 'Already exists';
                                ifAccToUpdate.put(zi.Id, zi);
                                expectedDealerIds.add(dealerAcc.Id);
                                continue;
                            }

                            DNS_CustomerDealerAssociation__c dealer = new DNS_CustomerDealerAssociation__c(
                                Customer__c = acc.Id,
                                Dealer__c = dealerAcc.Id
                            );
                            dealerToInsert.add(dealer);
                            zi.IsComplete__c = true;
                            zi.ERROR__c = 'Success';
                            ifAccToUpdate.put(zi.Id, zi);
                            expectedDealerIds.add(dealerAcc.Id);
                        }

                        // 기존 레코드 중 예상되지 않은 딜러 삭제
                        for (DNS_CustomerDealerAssociation__c dealer : existing) {
                            if (!expectedDealerIds.contains(dealer.Dealer__c) && !dealerIdsToDelete.contains(dealer.Id)) {
                                dealerToDelete.add(dealer);
                                dealerIdsToDelete.add(dealer.Id);
                            }
                        }
                    }

                    // ZM (Account Team)
                    if (!zmRecords.isEmpty()) {
                        List<AccountTeamMember> existing = existingTeams.get(acc.Id) != null ? existingTeams.get(acc.Id) : new List<AccountTeamMember>();

                        Set<String> expectedUserIds = new Set<String>();

                        Map<String, AccountTeamMember> existingTeamMap = new Map<String, AccountTeamMember>();

                        for (AccountTeamMember team : existing) {
                            String key = team.UserId + '-' + team.TeamMemberRole;
                            existingTeamMap.put(key, team);
                        }

                        for (IF_Account__c zm : zmRecords) {
                            String partnerCode  = removeLeadingZeros(zm.KUNN2__c);

                            User user = userMap.get(partnerCode);

                            if (user == null) {
                                zm.IsComplete__c    = false;
                                if(zm.ERROR__c == '' || zm.ERROR__c == 'Success'){
                                    zm.ERROR__c         = 'User not found for KUNN2__c: ' + partnerCode;
                                }
                                ifAccToUpdate.put(zm.Id, zm);
                                continue;
                            }

                            String teamKey = user.Id + '-' + TEAM_ROLE_SALES_MANAGER;
                            if (existingTeamMap.containsKey(teamKey)) {
                                zm.IsComplete__c    = true;
                                zm.ERROR__c         = 'Already exists';
                                ifAccToUpdate.put(zm.Id, zm);
                                expectedUserIds.add(user.Id);
                                continue;
                            }

                            AccountTeamMember team = new AccountTeamMember(
                                AccountId               = acc.Id,
                                UserId                  = user.Id,
                                TeamMemberRole          = TEAM_ROLE_SALES_MANAGER,
                                AccountAccessLevel      = 'Edit',
                                OpportunityAccessLevel  = 'None',
                                CaseAccessLevel         = 'None'
                            );
                            teamToInsert.add(team);
                            zm.IsComplete__c    = true;
                            zm.ERROR__c         = 'Success';
                            ifAccToUpdate.put(zm.Id, zm);
                            expectedUserIds.add(user.Id);
                        }

                        for (AccountTeamMember team : existing) {
                            if (!expectedUserIds.contains(team.UserId)) {
                                teamToDelete.add(team);
                            }
                        }
                    }
                }
            }

            // Deduplicate insertSadList
            Map<String, SalesAreaData__c> insertSadMap = new Map<String, SalesAreaData__c>();
            for (SalesAreaData__c sad : insertSadList) {
                String key = sad.Account__c + '-' + sad.SalesOrganization__c + '-' + sad.DistributionChannel__c + '-' + sad.Division__c;
                insertSadMap.put(key, sad);
            }
            insertSadList = insertSadMap.values();

            // Deduplicate updateSadList
            Map<Id, SalesAreaData__c> updateSadMap = new Map<Id, SalesAreaData__c>();
            for (SalesAreaData__c sad : updateSadList) {
                updateSadMap.put(sad.Id, sad);
            }
            updateSadList = updateSadMap.values();

            // Deduplicate dealerToInsert
            Map<String, DNS_CustomerDealerAssociation__c> dealerInsertMap = new Map<String, DNS_CustomerDealerAssociation__c>();
            for (DNS_CustomerDealerAssociation__c dealer : dealerToInsert) {
                String key = dealer.Customer__c + '-' + dealer.Dealer__c;
                dealerInsertMap.put(key, dealer);
            }
            dealerToInsert = dealerInsertMap.values();

            // Deduplicate dealerToDelete
            Map<Id, DNS_CustomerDealerAssociation__c> dealerDeleteMap = new Map<Id, DNS_CustomerDealerAssociation__c>();
            for (DNS_CustomerDealerAssociation__c dealer : dealerToDelete) {
                dealerDeleteMap.put(dealer.Id, dealer);
            }
            dealerToDelete = dealerDeleteMap.values();

            // Deduplicate teamToInsert
            Map<String, AccountTeamMember> teamInsertMap = new Map<String, AccountTeamMember>();
            for (AccountTeamMember team : teamToInsert) {
                String key = team.AccountId + '-' + team.UserId + '-' + team.TeamMemberRole;
                teamInsertMap.put(key, team);
            }
            teamToInsert = teamInsertMap.values();

            // Deduplicate teamToDelete
            Map<Id, AccountTeamMember> teamDeleteMap = new Map<Id, AccountTeamMember>();
            for (AccountTeamMember team : teamToDelete) {
                teamDeleteMap.put(team.Id, team);
            }
            teamToDelete = teamDeleteMap.values();

            // DML 실행
            System.debug('insertSadList: '  + insertSadList.size());
            System.debug('updateSadList: '  + updateSadList.size());
            System.debug('dealerToInsert: ' + dealerToInsert.size());
            System.debug('dealerToDelete: ' + dealerToDelete.size());
            System.debug('teamToInsert: '   + teamToInsert.size());
            System.debug('teamToDelete: '   + teamToDelete.size());

            // SalesAreaData__c 삽입
            if (!insertSadList.isEmpty()) {
                Database.SaveResult[] results = Database.insert(insertSadList, false);
                for (Integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr  = results[i];
                    SalesAreaData__c sad    = insertSadList[i];
                    String customerCode     = null;

                    for (Account acc : accountList) {
                        if (acc.Id == sad.Account__c) {
                            customerCode = acc.CustomerCode__c;
                            break;
                        }
                    }
                    if (customerCode != null) {
                        for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                            if (ifAcc.TABLE_NAME__c == 'KNVV' && ifAcc.VKORG__c == sad.SalesOrganization__c) {
                                if (!sr.isSuccess()) {
                                    ifAcc.IsComplete__c = false;
                                    if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                                        ifAcc.ERROR__c      = 'SalesAreaData__c insert failed: ' + sr.getErrors()[0].getMessage();
                                    }
                                    ifAccToUpdate.put(ifAcc.Id, ifAcc);
                                }
                            }
                        }
                    }
                }
            }

            // SalesAreaData__c 업데이트
            if (!updateSadList.isEmpty()) {
                Database.SaveResult[] results = Database.update(updateSadList, false);
                for (Integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr = results[i];
                    SalesAreaData__c sad    = updateSadList[i];
                    String customerCode     = null;
                    for (Account acc : accountList) {
                        if (acc.Id == sad.Account__c) {
                            customerCode = acc.CustomerCode__c;
                            break;
                        }
                    }
                    if (customerCode != null) {
                        for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                            if (ifAcc.TABLE_NAME__c == 'KNVV' && ifAcc.VKORG__c == sad.SalesOrganization__c) {
                                if (!sr.isSuccess()) {
                                    ifAcc.IsComplete__c = false;
                                    if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                                        ifAcc.ERROR__c      = 'SalesAreaData__c update failed: ' + sr.getErrors()[0].getMessage();
                                    }
                                    ifAccToUpdate.put(ifAcc.Id, ifAcc);
                                }
                            }
                        }
                    }
                }
            }

            // DNS_CustomerDealerAssociation__c 삽입
            if (!dealerToInsert.isEmpty()) {
                Database.SaveResult[] results = Database.insert(dealerToInsert, false);
                for (Integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr = results[i];
                    if (!sr.isSuccess()) {
                        System.debug('DNS_CustomerDealerAssociation__c insert failed: ' + sr.getErrors()[0].getMessage());
                    }
                }
            }

            // DNS_CustomerDealerAssociation__c 삭제
            if (!dealerToDelete.isEmpty()) {
                Database.DeleteResult[] results = Database.delete(dealerToDelete, false);
                for (Integer i = 0; i < results.size(); i++) {
                    Database.DeleteResult dr = results[i];
                    if (!dr.isSuccess()) {
                        System.debug('DNS_CustomerDealerAssociation__c delete failed: ' + dr.getErrors()[0].getMessage());
                    }
                }
            }

            // AccountTeamMember 삽입
            if (!teamToInsert.isEmpty()) {
                Database.SaveResult[] results = Database.insert(teamToInsert, false);
                for (Integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr = results[i];
                    if (!sr.isSuccess()) {
                        System.debug('AccountTeamMember insert failed: ' + sr.getErrors()[0].getMessage());
                    }
                }
            }

            // AccountTeamMember 삭제
            if (!teamToDelete.isEmpty()) {
                Database.DeleteResult[] results = Database.delete(teamToDelete, false);
                for (Integer i = 0; i < results.size(); i++) {
                    Database.DeleteResult dr = results[i];
                    if (!dr.isSuccess()) {
                        System.debug('AccountTeamMember delete failed: ' + dr.getErrors()[0].getMessage());
                    }
                }
            }

            // IF_Account__c 최종 업데이트
            if (!ifAccToUpdate.isEmpty()) {
                Database.SaveResult[] results = Database.update(ifAccToUpdate.values(), false);
                for (Integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr  = results[i];
                    IF_Account__c ifAcc     = ifAccToUpdate.values()[i];
                    if (!sr.isSuccess()) {
                        ifAcc.IsComplete__c = false;
                        if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                            ifAcc.ERROR__c      = 'IF_Account__c update failed: ' + sr.getErrors()[0].getMessage();
                        
                        }
                        ifAccToUpdate.put(ifAcc.Id, ifAcc);
                    }
                }
                update ifAccToUpdate.values();
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + '\n' + e.getStackTraceString());
            for (String customerCode : customerCodeToIfAccs.keySet()) {
                for (IF_Account__c ifAcc : customerCodeToIfAccs.get(customerCode)) {
                    ifAcc.IsComplete__c = false;
                    if(ifAcc.ERROR__c == '' || ifAcc.ERROR__c == 'Success'){
                        ifAcc.ERROR__c      = 'Batch Error: ' + e.getMessage();
                    }
                    ifAccToUpdate.put(ifAcc.Id, ifAcc);
                }
            }
            update ifAccToUpdate.values();
        }
    }

    /**
     * IF_Account__c 데이터를 Account 객체에 매핑합니다.
     */
    private static Account mappingAccount(Account acc, IF_Account__c ifAcc, Map<String, Country__c> countryMap, Map<String, Region__c> regionMap, Map<String, TransportationZone__c> zoneMap) {
        // acc.Name                = ifAcc.NAME1__c;
        Boolean isNew = (acc.Id == null);
        Boolean isKR  = (ifAcc != null && ifAcc.LAND1__c == 'KR');

        if (isNew || isKR) {
            acc.Name = ifAcc.NAME1__c;                 // 새 레코드는 무조건 Name 필수, KR도 무조건 Name Upsert , KR아니면 신규만 Insert
        } 
        
        acc.Representative__c   = ifAcc.J_1KFREPRE__c;

        String regionKey = ifAcc.REGIO_T__c + '-' + ifAcc.LAND1__c;
        if (ifAcc.LAND1__c != null && ifAcc.REGIO_T__c != null && regionMap.containsKey(regionKey)) {
            Region__c region = regionMap.get(regionKey);

            acc.CountryLookup__c    = region.Country__c;
            acc.Country__c          = region.Country__r.CountryCode__c;
            acc.RegionLookup__c     = region.Id;
            if(region.Country__r.CountryCode__c == 'US') {
                acc.ShippingState   = region.RegionCode__c;
            }
        } else if (ifAcc.LAND1__c != null && countryMap.containsKey(ifAcc.LAND1__c)) {
            Country__c country = countryMap.get(ifAcc.LAND1__c);

            acc.CountryLookup__c    = country.Id;
            acc.Country__c          = country.CountryCode__c;
        }

        if (ifAcc.LZONE__c != null && zoneMap.containsKey(ifAcc.LZONE__c)) {
            TransportationZone__c zoneRec = zoneMap.get(ifAcc.LZONE__c);
            acc.TransportationZoneL__c = zoneRec.Id;
        }

        acc.ShippingCountry     = ifAcc.LANDX__c;

        System.debug('ifAcc.LAND1__c ::: ' + ifAcc.LAND1__c);
        if(ifAcc.LAND1__c == 'KR') {
            acc.DetailAddress__c    = ifAcc.STRAS__c;
            acc.ShippingStreet      = ifAcc.STRAS__c;
            if(ifAcc.STR_SUPPL3__c != null) {
                acc.ShippingCity        = ifAcc.ORT01__c + ' ' + ifAcc.STR_SUPPL1__c + ' ' + ifAcc.STR_SUPPL2__c + ' ' + ifAcc.STR_SUPPL3__c;
            } else if(ifAcc.STR_SUPPL2__c != null) {
                acc.ShippingCity        = ifAcc.ORT01__c + ' ' + ifAcc.STR_SUPPL1__c + ' ' + ifAcc.STR_SUPPL2__c;
            } else if(ifAcc.STR_SUPPL1__c != null) {
                acc.ShippingCity        = ifAcc.ORT01__c + ' ' + ifAcc.STR_SUPPL1__c;
            } else {
                acc.ShippingCity        = ifAcc.ORT01__c;
            }
        } else {
            acc.ShippingCity        = ifAcc.ORT01__c;
            System.debug('acc.ShippingCity ::: ' + acc.ShippingCity);
            acc.DetailAddress__c      = ifAcc.STRAS__c;

            if(ifAcc.STR_SUPPL3__c != null) {
                acc.ShippingStreet        = ifAcc.ORT01__c + ' ' + ifAcc.STR_SUPPL1__c + ' ' + ifAcc.STR_SUPPL2__c + ' ' + ifAcc.STR_SUPPL3__c + ' ' + ifAcc.STRAS__c;
            } else if(ifAcc.STR_SUPPL2__c != null) {
                acc.ShippingStreet        = ifAcc.ORT01__c + ' ' + ifAcc.STR_SUPPL1__c + ' ' + ifAcc.STR_SUPPL2__c + ' ' + ifAcc.STRAS__c;
            } else if(ifAcc.STR_SUPPL1__c != null) {
                acc.ShippingStreet        = ifAcc.ORT01__c + ' ' + ifAcc.STR_SUPPL1__c + ' ' + ifAcc.STRAS__c;
            } else {
                acc.ShippingStreet        = ifAcc.ORT01__c + ' ' + ifAcc.STRAS__c;
            }

        }

        acc.ShippingPostalCode  = ifAcc.PSTLZ__c;
        acc.Fax                 = ifAcc.TELFX__c;
        acc.Email__c            = ifAcc.SMTP_ADDR__c;
        acc.Website             = ifAcc.ZWEBPAGE__c;
        acc.Phone               = ifAcc.TELF1__c;
        acc.Mobile__c           = ifAcc.TELF2__c;
        acc.SearchTerm__c       = ifAcc.SORTL__c;
        acc.SearchTerm1__c      = ifAcc.SORT1__c;
        acc.SearchTerm2__c      = ifAcc.SORT2__c;
        acc.Description         = ifAcc.VTEXT2__c;
        acc.MainCategory__c     = ifAcc.KATR1__c;
        acc.SubCategory__c      = ifAcc.KATR2__c;
        acc.IsTooling__c        = ifAcc.KATR3__c;

        if (ifAcc.AUFSD__c != 'X') acc.IsBlocked__c = false;

        // Business Number 처리
        String currentDuplCheck = acc.BusinessNumberDuplCheck__c;
        System.debug('Mapping BusinessNumber for CustomerCode: ' + acc.CustomerCode__c + ', Current BusinessNumberDuplCheck__c: ' + currentDuplCheck);
        if (ifAcc.STCD2__c != null && (currentDuplCheck == null || currentDuplCheck != ifAcc.STCD2__c)) {
            acc.businessNumber__c           = ifAcc.STCD2__c;
            acc.BusinessNumberDuplCheck__c  = ifAcc.STCD2__c;
            acc.IsBusinessLicense__c        = false;
        } else if (ifAcc.STCD3__c != null && (currentDuplCheck == null || currentDuplCheck != ifAcc.STCD3__c)) {
            acc.businessNumber__c           = ifAcc.STCD3__c;
            acc.BusinessNumberDuplCheck__c  = ifAcc.STCD3__c;
            acc.IsBusinessLicense__c        = false;
        } else if (ifAcc.STCD4__c != null && (currentDuplCheck == null || currentDuplCheck != ifAcc.STCD4__c)) {
            acc.businessNumber__c           = ifAcc.STCD4__c;
            acc.BusinessNumberDuplCheck__c  = ifAcc.STCD4__c;
            acc.IsBusinessLicense__c        = false;
        }

        if (ifAcc.KTOKD__c == '1130') acc.CareOfRigger__c = true;

        return acc;
    }

    /**
     * 국가 데이터를 매핑합니다.
     */
    private static Map<String, Country__c> fetchCountryMap(List<IF_Account__c> records) {
        Set<String> countryCodes = new Set<String>();
        for (IF_Account__c ifAcc : records) {
            if (ifAcc.LAND1__c != null) countryCodes.add(ifAcc.LAND1__c);
        }
        Map<String, Country__c> countryMap = new Map<String, Country__c>();
        List<Country__c> countryList = [
            SELECT  Id
                    , CountryCode__c
            FROM Country__c
            WHERE CountryCode__c IN :countryCodes
        ];
        if (!countryList.isEmpty()) {
            for (Country__c country : countryList) {
                countryMap.put(country.CountryCode__c, country);
            }
        }
        return countryMap;
    }

    /**
     * 지역 데이터를 매핑합니다.
     */
    private static Map<String, Region__c> fetchRegionMap(List<IF_Account__c> records) {
        Set<String> regionCodes     = new Set<String>();
        Set<String> countryCodes    = new Set<String>();
        
        for (IF_Account__c ifAcc : records) {
            if (ifAcc.REGIO_T__c != null) regionCodes.add(ifAcc.REGIO_T__c);
            if (ifAcc.LAND1__c != null) countryCodes.add(ifAcc.LAND1__c);
        }
        Map<String, Region__c> regionMap = new Map<String, Region__c>();
        List<Region__c> regionList = [
            SELECT  Id
                    , RegionCode__c
                    , Country__r.CountryCode__c
            FROM Region__c
            WHERE RegionCode__c IN :regionCodes
            AND Country__r.CountryCode__c IN :countryCodes
        ];
        if (!regionList.isEmpty()) {
            for (Region__c region : regionList) {
                regionMap.put(region.RegionCode__c + '-' + region.Country__r.CountryCode__c, region);
            }
        }
        return regionMap;
    }

    /**
     * 운송 구역 데이터를 매핑합니다.
     */
    private static Map<String, TransportationZone__c> fetchZoneMap(List<IF_Account__c> records) {
        Set<String> zoneCodes = new Set<String>();
        for (IF_Account__c ifAcc : records) {
            if (ifAcc.LZONE__c != null) zoneCodes.add(ifAcc.LZONE__c);
        }
        Map<String, TransportationZone__c> zoneMap = new Map<String, TransportationZone__c>();
        List<TransportationZone__c> zoneList = [
            SELECT  Id
                    , ZONE1__c
            FROM TransportationZone__c
            WHERE ZONE1__c IN :zoneCodes
        ];
        if (!zoneList.isEmpty()) {
            for (TransportationZone__c zone : zoneList) {
                zoneMap.put(zone.ZONE1__c, zone);
            }
        }
        return zoneMap;
    }

    /**
     * KTOKD, KDGRP, VKORG를 기반으로 Account의 RecordType을 결정합니다.
     */
    private static Id determineRecordType(String ktokd, String kdgrp, String vkorg) {
        if (ktokd == '1090' && kdgrp == '01') return PROSPECT_CUSTOMER_RT;
        if (ktokd == '1010' && kdgrp == '01') return TRADE_CUSTOMER_RT;
        if (ktokd == '1010' && (kdgrp == '02' || kdgrp == '03')) return DEALER_RT;
        if (ktokd == '1030' && (vkorg == SALES_ORG_4140 || vkorg == SALES_ORG_4146) && kdgrp == '01') return DNSA_RT;
        if (ktokd == '1030') return SHIP_TO_PARTY_RT;
        if (ktokd == '4130') return DNSA_RT;
        if (ktokd == '1130' && kdgrp == '09') return DNSA_RT;
        return null;
    }

    /**
     * 입력 문자열에서 선행 0을 제거합니다.
     */
    private static String removeLeadingZeros(String input) {
        return String.isBlank(input) ? input : input.replaceFirst('^0+', '');
    }

    // 트리거 우회
    private void bypassTriggers() {
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('SalesAreaDataTriggerHandler');
    }

    // 트리거 우회 해제
    private void clearBypassTriggers() {
        TriggerHandler.clearBypass('AccountTriggerHandler');
        TriggerHandler.clearBypass('SalesAreaDataTriggerHandler');
    }
}