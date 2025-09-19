/**
 * @author            : Yu-Hyun Park
 * @description       : Opportunity 엑셀 임포트 컨트롤러
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-23   yuhyun.park@sbtglobal.com   Initial Version
**/
public without sharing class DN_ImportOpportunityController {

    private static final Id   optyRT        = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();
    private static final Id   accDealerRT   = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id   accCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();
    private static final Id   conDealerRT   = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id   conCustomerRT = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ContactPerson').getRecordTypeId();

    //  Opportunity Metadata 조회
    @AuraEnabled
    public static List<String> getImportOpportunityMetadata() {

        try {
            
            System.debug('getImportOpportunityMetadata 호출');
    
            String query = 'SELECT DeveloperName, ColumnName__c, MappingFieldAPI__c, Order__c, TargetObject__c FROM ImportOpportunity__mdt ORDER BY Order__c ASC';
            System.debug('query: ' + query);
    
            // 동적 쿼리 실행
            List<ImportOpportunity__mdt> allMeta = Database.query(query);
            System.debug('allMeta: ' + allMeta);
    
            List<String> expectedHeaders = new List<String>();
    
            for (ImportOpportunity__mdt meta : allMeta) {
                System.debug('meta: ' + meta);
                expectedHeaders.add(meta.ColumnName__c);
            }
    
            System.debug('expectedHeaders: ' + expectedHeaders);
            return expectedHeaders;
            
        } catch (Exception e) {
            System.debug('Error in getImportLeadMetadata: ' + e.getMessage());
            System.debug('Line Number: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }

    }

    // 레코드 업서트
    @AuraEnabled
    public static String upsertRecords(String records) {

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler' ,'OpportunityTriggerHandler', 'OpptyCompetitorMappingTriggerHandler', 'SalesAreaDataTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; 

        try{
            System.debug('upsertRecords Controller 진입 ::  ');
            System.debug('records :: ' + records);
    
    
            // JSON 문자열을 Map 형태로 역직렬화
            List<Object> recordObjects = (List<Object>) JSON.deserializeUntyped(records);
            List<Map<String, Object>> recordMaps = new List<Map<String, Object>>();
            System.debug('recordObjects :: ' + recordObjects);
    
            for (Object obj : recordObjects) {
                recordMaps.add((Map<String, Object>) obj);
            }
            System.debug('recordMaps :: ' + recordMaps);
    
            
            Set<String> dealerCodeSet                   = new Set<String>();
            Set<String> conNameSet                      = new Set<String>();    // Contact Person
            Set<String> userNameSet                     = new Set<String>();    // Dealer User
            Set<String> accNameSet                      = new Set<String>();
            Set<String> accRepsSet                      = new Set<String>();
            Set<String> optyKeySet                      = new Set<String>();
            Map<String, Integer> optyKeyBaseCountMap    = new Map<String, Integer>();
            Set<String> modelNameSet                    = new Set<String>();
            Set<String> competitorNameSet               = new Set<String>();
            Set<String> accKeySet                       = new Set<String>();
            Set<String> countryCodeSet                  = new Set<String>();
            Set<String> regionCodeSet                   = new Set<String>();
            Set<String> updateOptyIdSet                 = new Set<String>();    //for Opty Update : 2025-04-29
    
            Integer rowNumber = 4; // 행 번호 추적

            for (Map<String, Object> recordMap : recordMaps) {
                
                // Key 만들기
                String accName      = String.valueOf(recordMap.get('Column_3'));
                String modelName    = String.valueOf(recordMap.get('Column_5'));
    
                Date today      = Date.today();
                String month    = String.valueOf(today.month());
                String day      = String.valueOf(today.day());
                String year     = String.valueOf(today.year()).substring(2, 4);
                String dateStr  = (month.length() == 1 ? '0' + month : month)   // MMDDYY 형식으로 변환
                                    + (day.length() == 1 ? '0' + day : day)
                                    + year;
    
                // Opty Key
                String optyKeyBase;
                if(String.isBlank(modelName)) {
                    optyKeyBase = accName + '_' + dateStr;
                } else {
                    optyKeyBase = accName + '_' + modelName + '_' + dateStr;
                }
                System.debug('optyKeyBase :: ' + optyKeyBase);

    
                if (!optyKeyBaseCountMap.containsKey(optyKeyBase)) {
                    System.debug('optyKeyBaseCountMap Put :: ' + optyKeyBase);

                    optyKeyBaseCountMap.put(optyKeyBase, 0);
                }
                optyKeyBaseCountMap.put(optyKeyBase, optyKeyBaseCountMap.get(optyKeyBase) + 1);
                System.debug('optyKeyBaseCountMap :: ' + optyKeyBaseCountMap);


                // 필수 필드 체크(0~9, 13~17)
                // 2025-03-18 : Column_14 제외
                // 0330 이주현 수정 : Column_5 (DNSA Model) 제외
                // 0423 Column_8 필수값 해제
                List<String> requiredFields = new List<String>{
                    'Column_0', 'Column_1', 'Column_2', 'Column_3', 'Column_4', 'Column_6', 'Column_7',
                    'Column_9', 'Column_10' , 'Column_15', 'Column_16', 'Column_17', 'Column_18'
                };

                rowNumber++; // 현재 행 번호 증가
                for (String field : requiredFields) {
                    Object fieldValue = recordMap.get(field);
                    if (fieldValue == null || String.valueOf(fieldValue).trim() == '') {
                        // 누락된 필드 정보와 행 번호 포함
                        String recordDetails = 'Required value is empty in Row ' + rowNumber;
                        return recordDetails;
                    }
                }

                // 날짜 체크 : Requested Delivery Date(Column_8) > Close Date(Column_7)
                // 0423 수정
                if(recordMap.get('Column_8') != '') {
                    if (!dateValidCheck(recordMap)) {
                        String recordDetails = '[Requested Delivery Date] must be after [Expected Contract Date] in Row ' + rowNumber;
                        return recordDetails;
                    }
                }
    
                // 딜러 코드 (Distributor Id)
                String dealerCode = String.valueOf(recordMap.get('Column_0'));
                dealerCodeSet.add(dealerCode);
    
                // Contact 딜러 이름 (Opportunity Owner Name)
                String userName = String.valueOf(recordMap.get('Column_2'));
                userNameSet.add(userName);

                // Contact Person 이름
                String conName = String.valueOf(recordMap.get('Column_21'));
                if (!String.isBlank(conName)) { 
                    conNameSet.add(conName);
                }
    
                // Account(Customer) Name & Representative 
                accNameSet.add(accName);
                String accReps = String.valueOf(recordMap.get('Column_4'));
                // 수정: Representative 10자리 초과 시 자르기
                if (accReps.length() > 10) {
                    accReps = accReps.substring(0, 10);
                }
                accRepsSet.add(accReps);
                String accKey = accName + accReps;
                accKeySet.add(accKey);
    
                // Model Name
                String model = String.valueOf(recordMap.get('Column_5'));
                modelNameSet.add(model);
    
                // Competitor
                String competitorName = String.valueOf(recordMap.get('Column_22'));
                if (!String.isBlank(competitorName)) { 
                    competitorNameSet.add(competitorName);
                }

                // Coutnry
                String countryCode = String.valueOf(recordMap.get('Column_9'));
                countryCodeSet.add(countryCode);

                // Region
                String regionCode = String.valueOf(recordMap.get('Column_10'));
                regionCodeSet.add(regionCode);

                // for Opty Update : 2025-04-29
                System.debug('Opty Id in Template :: ' + recordMap.get('Column_26'));
                if(recordMap.get('Column_26') != null && String.valueOf(recordMap.get('Column_26')).trim().length() > 0) {
                    String optyId = String.valueOf(recordMap.get('Column_26')); 
                    updateOptyIdSet.add(optyId);
                }
            }

    
            // 기존 Opty 쿼리 - LIKE 조건을 만족하도록 변환
            Map<String, List<String>> existingKeysMap = new Map<String, List<String>>();
            List<String> likeKeys = new List<String>();

            // keySet()의 각 값을 와일드카드로 변환
            for (String key : optyKeyBaseCountMap.keySet()) {
                likeKeys.add(key + '%'); // 와일드카드 추가
            }

            List<Opportunity> existingOpps = [
                SELECT  Name, RecordTypeId
                FROM    Opportunity
                WHERE   RecordTypeId = :optyRT
                AND     Name LIKE :likeKeys
            ];

            System.debug('existingOpps :: ' + existingOpps);

            if(!existingOpps.isEmpty()){
                for (Opportunity opp : existingOpps) {
                    List<String> nameParts = opp.Name.split('_');
                    System.debug('nameParts :: ' + nameParts);
                    String baseKey;

                    if (nameParts.size() > 3) {
                        baseKey = nameParts[0] + '_' + nameParts[1] + '_' + nameParts[2];
                        System.debug('3 basekey :: ' + basekey);

                    } else if (nameParts.size() == 3 ) {
                        baseKey = nameParts[0] + '_' + nameParts[1];
                        System.debug('2 basekey :: ' + basekey);

                    }

                    if (!existingKeysMap.containsKey(baseKey)) {
                        existingKeysMap.put(baseKey, new List<String>());
                    }
                    existingKeysMap.get(baseKey).add(opp.Name);
                }
            }
    
            // 딜러 코드 (Distributor Id)
            Map<String, Account> dealerIdMap = new Map<String, Account>();
            List<Account> dealerList = [SELECT Id, RecordTypeId, Name, CustomerCode__c FROM Account WHERE CustomerCode__c IN :dealerCodeSet AND RecordTypeId =: accDealerRT];
            for (Account acc : dealerList) {
                dealerIdMap.put(acc.CustomerCode__c, acc);
            }
    
            // DNSA 딜러 이름 (Account Owner Name : user) usernameMap
            Map<String, User> usernameMap = new Map<String, User>();
            List<User> userList = [SELECT Id, Username, SalesOrganization__c, UserRole.PortalRole, Account.SalesOrganization__c, Account.SalesDistrict__c, Account.DistributionChannel__c, Account.Division__c, Account.SalesOffice__c
                                   FROM User 
                                   WHERE Username IN :userNameSet 
                                   AND SalesOrganization__c = '4140' 
                                   AND UserRole.PortalRole != null];
            for (User user : userList){
                usernameMap.put(user.Username, user);
            }

            // Contact Person
            Map<String, Contact> conNameMap = new Map<String, Contact>();
            // List<Contact> conList = [SELECT Id, RecordTypeId, Name, LastName FROM Contact WHERE LastName IN :conNameSet AND RecordTypeId =: conCustomerRT];
            List<Contact> conList = [SELECT Id, RecordTypeId, Name, LastName, Account.Name, Account.Representative__c FROM Contact WHERE LastName IN :conNameSet AND RecordTypeId =: conCustomerRT AND Account.Name IN :accNameSet AND Account.Representative__c IN: accRepsSet ];
            for (Contact con : conList){
                conNameMap.put(con.LastName, con);
            }
    
            // Account(Customer) Name & Representative 
            Map<String, Account> accMap = new Map<String, Account>();
            List<Account> customerList = [
                SELECT  Id,
                        RecordTypeId,
                        OwnerId,
                        AccountGroup__c,
                        Name,
                        Representative__c, 
                        CountryLookup__c,
                        RegionLookup__c,
                        MainCategory__c,
                        SubCategory__c,
                        IsTooling__c,
                        ShippingStreet,
                        ShippingCity,
                        ShippingState,
                        ShippingPostalCode,
                        Phone,
                        Email__c
                FROM    Account 
                WHERE   Name IN :accNameSet 
                AND     Representative__c IN :accRepsSet
                AND     RecordTypeId =: accCustomerRT
                ];

            for (Account acc : customerList){
                accMap.put(acc.Name+acc.Representative__c, acc);
            }
    
            // Model Name
            Map<String, DNSAModel__c> modelMap = new Map<String, DNSAModel__c>();
            List<DNSAModel__c> modelList = [SELECT Id, Name, ModelName__c FROM DNSAModel__c WHERE Name IN :modelNameSet];
            for (DNSAModel__c model : modelList){
                // modelMap.put(model.ModelName__c, model);
                // 2025-04-19 변경
                modelMap.put(model.Name, model);
            }
    
            // Competitor
            Map<String, Competitor__c> competitorMap = new Map<String, Competitor__c>();
            List<Competitor__c> competitorList = [SELECT Id, Name FROM Competitor__c WHERE Name IN :competitorNameSet];
            for (Competitor__c competitor : competitorList){
                competitorMap.put(competitor.Name, competitor);
            }
    
            // Comptitor for Junction
            Map<String, Competitor__c> optyCompetitorMap = new Map<String, Competitor__c>();


            // Country & Region
            Map<String, Id> countryMap = new Map<String, Id>();
            Map<String, Region__c> regionMap = new Map<String, Region__c>();
            List<Region__c> regionList = [SELECT Id, Country__c, Country__r.CountryCode__c, RegionCode__c, Region__c FROM Region__c WHERE RegionCode__c IN :regionCodeSet AND Country__r.CountryCode__c IN :countryCodeSet];
            for(Region__c region : regionList){
                countryMap.put(region.Country__r.CountryCode__c, region.Country__c);
                regionMap.put(region.RegionCode__c, region);
            }

            // for Opty Update : 2025-04-29
            Map<String, Opportunity> updateOptyMap = new Map<String, Opportunity>();
            List<Opportunity> updateOptyList = 
            [
                SELECT 
                    Id,
                    Name, 
                    RecordTypeId, 
                    Dealer__c, 
                    OwnerId, 
                    Opportunity_Owner__c, 
                    StageName, 
                    AccountId, 
                    DNSAModel__c, 
                    Probability, 
                    CloseDate, 
                    RequestDelieveryDate__c, 
                    MainCategory__c, 
                    SubCategory__c, 
                    IsTooling__c, 
                    PO__c, 
                    LeadSourceDNSA__c, 
                    CustomerContact__c, 
                    SalesOrganization__c, 
                    Sales_Office__c, 
                    Country__c, 
                    Description__c, 
                    ProjectTypes__c,
                    ETOpportunityId__c
                    
                FROM    Opportunity
                WHERE   ETOpportunityId__c IN: updateOptyIdSet
            ];
            for(Opportunity opty : updateOptyList){
                updateOptyMap.put(opty.ETOpportunityId__c, opty);
            }

            // Account(Customer) Upsert Map (Key: Name + Representative__c, Value: Account)
            Map<String, Account> accToUpsertMap         = new Map<String, Account>();
    
            // Account(Customer) Upsert List
            List<Account> accToUpsert                   = new List<Account>();
    
            // Contact Person Insert List
            List<Contact> conToInsert                   = new List<Contact>();
    
            // Opportunity Update List
            List<Opportunity> optyToUpdate              = new List<Opportunity>();
    
            // Opportunity Insert List
            List<Opportunity> optyToInsert              = new List<Opportunity>();
    
            // for Opty Update : 2025-04-29
            Map<String, Opportunity> optyToUpdateMap    = new Map<String, Opportunity>();
    
            // Competitor Insert List
            List<OpptyCompetitorMapping__c> compToInsert = new List<OpptyCompetitorMapping__c>();

            // Delaer Code Map for DNS_CustomerDealerAssociation__c (Key: accKey, Value: DelaerCode)
            Map<String, String> dealerCodeMap           = new Map<String, String>();


            // 다시 행 번호 초기화(for Portal User Check)
            rowNumber = 4; 

            // New Account List : 신규 Account는 SalesAreaData 생성
            List<Account> newAccForSalesArea = new List<Account>();

            // Account > Contact > Opportunity > Model 순서대로 돌려서 생성
            // Account 
            for (Map<String, Object> recordMap : recordMaps) {

                // Portal User check : Opportunity Owner Name(Column_2)
                rowNumber++;
                String userName = String.valueOf(recordMap.get('Column_2'));
                if (!String.isBlank(userName)) {
                    User user = usernameMap.get(userName);
                    System.debug('user :: ' + user);

                    if (user == null || user.UserRole.PortalRole == null || user.SalesOrganization__c != '4140') {
                        String recordDetails = 'Undefined [Opportunity Owner Name] in Row ' + rowNumber;
                        return recordDetails; // 에러 반환
                    }
                }


                // DNSA Model Check (* DNSA Model Name)
                String modelName = String.valueOf(recordMap.get('Column_5'));
                if (!String.isBlank(modelName)) {
                    DNSAModel__c dnsaModel = modelMap.get(modelName);
                }


                // Key 만들기
                String accName      = String.valueOf(recordMap.get('Column_3'));
                String accReps      = String.valueOf(recordMap.get('Column_4'));
                // 수정: Representative 10자리 초과 시 자르기
                if (accReps.length() > 10) {
                    accReps = accReps.substring(0, 10);
                }
                String accKey       = accName + accReps;
    
                // 기존 Account(Customer) Update
                if (accMap.containsKey(accKey)) {
                    System.debug('<< Account Udpate >>');
    
                    Account existingCustomer = accMap.get(accKey);
    
                    // Import할 Account(Customer)의 필드 값
                    String dealerCode   = String.valueOf(recordMap.get('Column_0')); 
                    String country      = countryMap.get(String.valueOf(recordMap.get('Column_9')));
                    String region       = regionMap.get(String.valueOf(recordMap.get('Column_10'))).Id;
                    String owner        = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Id;
                    String mainCategory = String.valueOf(recordMap.get('Column_11'));
                    String subCategory  = String.valueOf(recordMap.get('Column_12'));
                    String isMold       = String.valueOf(recordMap.get('Column_13'));
                    String street       = String.valueOf(recordMap.get('Column_15'));
                    String city         = String.valueOf(recordMap.get('Column_16'));
                    String state        = String.valueOf(recordMap.get('Column_17'));
                    String postalCode   = String.valueOf(recordMap.get('Column_18'));
                    String phone        = String.valueOf(recordMap.get('Column_19'));
                    String email        = String.valueOf(recordMap.get('Column_20'));
    
                    Boolean isUpdated = false;
                    Boolean isOwnerChange = false;

                    // 기존 필드 값과 비교 및 할당
                    // owner 임시 주석
                    if (isFieldUpdated(existingCustomer.OwnerId, owner))                    { existingCustomer.OwnerId = owner;                 isUpdated = true; isOwnerChange = true; System.debug('<< Account owner Update >>'); }
                    if (isFieldUpdated(existingCustomer.CountryLookup__c, country))         { existingCustomer.CountryLookup__c = country;      isUpdated = true; System.debug('<< Account country Update >>'); }
                    if (isFieldUpdated(existingCustomer.RegionLookup__c, region))           { existingCustomer.RegionLookup__c = region;        isUpdated = true; System.debug('<< Account region Update >>'); }
                    if (isFieldUpdated(existingCustomer.MainCategory__c, mainCategory))     { existingCustomer.MainCategory__c = mainCategory;  isUpdated = true; System.debug('<< Account mainCategory Update >>'); }
                    if (isFieldUpdated(existingCustomer.SubCategory__c, subCategory))       { existingCustomer.SubCategory__c = subCategory;    isUpdated = true; System.debug('<< Account subCategory Update >>'); }
                    if (isFieldUpdated(existingCustomer.IsTooling__c, isMold))              { existingCustomer.IsTooling__c = isMold;           isUpdated = true; System.debug('<< Account isMold Update >>'); }
                    if (isFieldUpdated(existingCustomer.ShippingStreet, street))            { existingCustomer.ShippingStreet = street;         isUpdated = true; System.debug('<< Account street Update >>'); }
                    if (isFieldUpdated(existingCustomer.ShippingCity, city))                { existingCustomer.ShippingCity = city;             isUpdated = true; System.debug('<< Account city Update >>'); }
                    if (isFieldUpdated(existingCustomer.ShippingState, state))              { existingCustomer.ShippingState = state;           isUpdated = true; System.debug('<< Account state Update >>'); }
                    if (isFieldUpdated(existingCustomer.ShippingPostalCode, postalCode))    { existingCustomer.ShippingPostalCode = postalCode; isUpdated = true; System.debug('<< Account postalCode Update >>'); }
                    if (isFieldUpdated(existingCustomer.Phone, phone))                      { existingCustomer.Phone = phone;                   isUpdated = true; System.debug('<< Account phone Update >>'); }
                    if (isFieldUpdated(existingCustomer.Email__c, email))                   { existingCustomer.Email__c = email;                isUpdated = true; System.debug('<< Account email Update >>'); }
    
                    if (isUpdated) {
                        System.debug('<< Account Real Udpate >>');
                        accToUpsertMap.put(accKey, existingCustomer); // Map에 저장 (중복 제거 및 최신 값 유지)
                    }

                    if (isOwnerChange){
                        System.debug('<< Account Owner Change >>');
                        dealerCodeMap.put(accKey, dealerCode);
                    }

    
                // 신규 Account(Customer) 생성
                } else {
                    System.debug('<< Account Create >>');
                    String dealerCode               = String.valueOf(recordMap.get('Column_0')); 
                    
                    Account newCustomer             = new Account();
                    newCustomer.RecordTypeId        = accCustomerRT;
                    newCustomer.Name                = accName;
                    // 수정: Representative 10자리 초과 시 자르기
                    newCustomer.Representative__c   = accReps;
                    newCustomer.OwnerId             = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Id;
                    newCustomer.AccountGroup__c     = '1030';   // (Global) Ship to Party
                    newCustomer.CountryLookup__c    = countryMap.get(String.valueOf(recordMap.get('Column_9')));
                    newCustomer.RegionLookup__c     = regionMap.get(String.valueOf(recordMap.get('Column_10'))).Id;
                    newCustomer.MainCategory__c     = String.valueOf(recordMap.get('Column_11'));
                    newCustomer.SubCategory__c      = String.valueOf(recordMap.get('Column_12'));
                    newCustomer.IsTooling__c        = String.valueOf(recordMap.get('Column_13'));
                    newCustomer.ShippingStreet      = String.valueOf(recordMap.get('Column_15'));
                    newCustomer.ShippingCity        = String.valueOf(recordMap.get('Column_16'));
                    newCustomer.ShippingState       = String.valueOf(recordMap.get('Column_17'));
                    newCustomer.ShippingPostalCode  = String.valueOf(recordMap.get('Column_18'));
                    newCustomer.Phone               = String.valueOf(recordMap.get('Column_19'));
                    newCustomer.Email__c            = String.valueOf(recordMap.get('Column_20'));

                    newCustomer.SalesOrganization__c    = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Account.SalesOrganization__c;
                    newCustomer.SalesDistrict__c        = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Account.SalesDistrict__c;
                    newCustomer.DistributionChannel__c  = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Account.DistributionChannel__c;
                    newCustomer.Division__c             = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Account.Division__c;
                    newCustomer.SalesOffice__c          = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Account.SalesOffice__c;
    
                    dealerCodeMap.put(accKey, dealerCode);
                    accMap.put(accKey, newCustomer); // 새로 생성된 Account를 Map에 추가
                    newAccForSalesArea.add(newCustomer);
                }
            }

            // update : List<Account>로 변환 후, 최종 upsert 실행.
            if (!accToUpsertMap.isEmpty()) {
                accToUpsert = new List<Account>(accToUpsertMap.values());
                System.debug('update -> Upsert');
            }

            // insert : List<Account>로 변환 후, 최종 upsert 실행.
            if (!accMap.isEmpty()) {
                accToUpsert = new List<Account>(accMap.values());
                System.debug('insert -> Upsert');
            }

            List<SalesAreaData__c> salesAreaDataToInsert = new List<SalesAreaData__c>();
            List<DNS_CustomerDealerAssociation__c> cdaToInsert = new List<DNS_CustomerDealerAssociation__c>();

            // Account(Customer) Upsert
            if(!accToUpsert.isEmpty()){

                System.debug('accToUpsert Final size :: ' + accToUpsert.size());
                System.debug('acc To upsert :: ' + accToUpsert);
                upsert accToUpsert;

                if(newAccForSalesArea.size() > 0){

                    // for acc.CountryLookup__r.Country_Picklist__c Query
                    List<Id> newAccIds = new List<Id>();
                    for (Account acc : newAccForSalesArea) {
                        newAccIds.add(acc.Id);
                    }

                    newAccForSalesArea = [
                        SELECT Id,
                               CountryLookup__c,
                               CountryLookup__r.Country_Picklist__c,
                               SalesOrganization__c,
                               SalesDistrict__c,
                               SalesOffice__c,
                               DistributionChannel__c,
                               Division__c,
                               CareOfRigger__c
                        FROM Account
                        WHERE Id IN :newAccIds
                    ];
                }

                for (Account acc : newAccForSalesArea) {
                    SalesAreaData__c salesAreaData = new SalesAreaData__c();
                    salesAreaData.Account__c = acc.Id;

                    salesAreaData.Country__c              = acc.CountryLookup__r.Country_Picklist__c;
                    salesAreaData.Currency__c             = 'USD';
                    salesAreaData.SalesOrganization__c    = acc.SalesOrganization__c;
                    salesAreaData.SalesDistrict__c        = acc.SalesDistrict__c;
                    salesAreaData.SalesOffice__c          = acc.SalesOffice__c;
                    salesAreaData.DistributionChannel__c  = acc.DistributionChannel__c;
                    salesAreaData.Division__c             = acc.Division__c;
                    salesAreaData.CustomerGroup__c        = acc.CareOfRigger__c ? '09' : '01';  
                    salesAreaData.ShipToParty__c          = acc.Id;
                    salesAreaData.BillToParty__c          = acc.CareOfRigger__c ? acc.Id : null;
                    salesAreaData.SoldToParty__c          = acc.CareOfRigger__c ? acc.Id : null;
                    salesAreaData.Payer__C                = acc.CareOfRigger__c ? acc.Id : null;

                    salesAreaDataToInsert.add(salesAreaData);
                }

                if (!salesAreaDataToInsert.isEmpty()) {
                    insert salesAreaDataToInsert;
                }

                // CustomerDealerAssociation 생성
                for (Account acc : accToUpsert) {

                    String accKey = acc.Name + acc.Representative__c;
                    String dealerCode = dealerCodeMap.get(accKey);


                    if(!String.isBlank(dealerCode) && dealerIdMap.containsKey(dealerCode)){
                        DNS_CustomerDealerAssociation__c newCda = new DNS_CustomerDealerAssociation__c();
                        newCda.Dealer__c = dealerIdMap.get(dealerCode).Id;
                        newCda.Customer__c = acc.Id;
                        // owner 임시 주석
                        newCda.OwnerId = acc.OwnerId;
                        cdaToInsert.add(newCda);
                    }
                }
            }

            if(!cdaToInsert.isEmpty()){
                System.debug('TriggerHandler.bypassedHandlers :: ' + TriggerHandler.bypassedHandlers);

                System.debug('cdaToInsert :: ' + cdaToInsert);
                insert cdaToInsert;
            }
    
            // Contact Person 생성
            for (Map<String, Object> recordMap : recordMaps) {
                String contactName = String.valueOf(recordMap.get('Column_21')); // Contact의 LastName 값

                if(!String.isBlank(contactName) && !conNameMap.containsKey(contactName)){
                    System.debug('<< Contact Create >>');
                    // Key 만들기
                    String accName      = String.valueOf(recordMap.get('Column_3'));
                    String accReps      = String.valueOf(recordMap.get('Column_4'));
                    // 수정: Representative 10자리 초과 시 자르기
                    if (accReps.length() > 10) {
                        accReps = accReps.substring(0, 10);
                    }
                    String accKey       = accName + accReps;
    
                    Contact newCon      = new Contact();
                    newCon.LastName     = String.valueOf(recordMap.get('Column_21'));
                    newCon.RecordTypeId = conCustomerRT;
                    newCon.MobilePhone  = String.valueOf(recordMap.get('Column_19'));
                    newCon.Email        = String.valueOf(recordMap.get('Column_20'));
                    newCon.AccountId    = accMap.get(accKey).Id;
                    newCon.OwnerId      = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Id;             // 2024-12-31 : Owner 추가
    
                    conToInsert.add(newCon);
                    conNameMap.put(newCon.LastName, newCon); // 새로 생성된 Contact을 Map에 추가
                }
            }
    
            // Contact Insert
            if(!conToInsert.isEmpty()){
                System.debug('cotact To insert :: ' + conToInsert);
                insert conToInsert;
            }
    
            // 최종 Opportunity 생성
            for (Map<String, Object> recordMap : recordMaps) {
                String accName      = String.valueOf(recordMap.get('Column_3'));
                String accReps      = String.valueOf(recordMap.get('Column_4'));
                // 수정: Representative 10자리 초과 시 자르기
                if (accReps.length() > 10) {
                    accReps = accReps.substring(0, 10);
                }
                String accKey       = accName + accReps;
                String modelName    = String.valueOf(recordMap.get('Column_5'));
    
                Date today      = Date.today();
                String month    = String.valueOf(today.month());
                String day      = String.valueOf(today.day());
                String year     = String.valueOf(today.year()).substring(2, 4);
                String dateStr  = (month.length() == 1 ? '0' + month : month)   // MMDDYY 형식으로 변환
                                    + (day.length() == 1 ? '0' + day : day)
                                    + year;
    
                String optyKeyBase;
                if(String.isBlank(modelName)) {
                    optyKeyBase = accName + '_' + dateStr;
                } else {
                    optyKeyBase = accName + '_' + modelName + '_' + dateStr;
                }
    
                Integer seqNum = 1;
                if (existingKeysMap.containsKey(optyKeyBase)) {
                    System.debug('중복된 Opty Key!');
                    List<String> existingKeys = existingKeysMap.get(optyKeyBase);
                    
                    // seqNum을 2자리로 포맷
                    String seqNumStr = seqNum < 10 ? '0' + String.valueOf(seqNum) : String.valueOf(seqNum);
                    
                    while (existingKeys.contains(optyKeyBase + '_' + seqNumStr)) {
                        seqNum++;
                        System.debug('seqNum :: ' + seqNum);
                        seqNumStr = seqNum < 10 ? '0' + String.valueOf(seqNum) : String.valueOf(seqNum);
                    }
                }
    
                // 엑셀 파일 내부 중복 처리
                Integer duplicateCount = optyKeyBaseCountMap.get(optyKeyBase);
                if (duplicateCount > 1) {
                    seqNum = Math.max(seqNum, duplicateCount);
                    optyKeyBaseCountMap.put(optyKeyBase, seqNum + 1); 
                }
    
                // seqNum을 2자리 형식으로 변환
                String seqNumStr = seqNum < 10 ? '0' + String.valueOf(seqNum) : String.valueOf(seqNum);
    
                // Opportunity 생성
                String optyKey = optyKeyBase + '_' + seqNumStr;
                System.debug('Generated optyKey: ' + optyKey);

                // 수정: 날짜 형식을 문자열로 받아서 파싱
                String closeDateStr = String.valueOf(recordMap.get('Column_7'));
                String requestDateStr = String.valueOf(recordMap.get('Column_8'));
                
                Date closeDate = parseDate(closeDateStr);
                Date requestDate = parseDate(requestDateStr);

                // for Opty Update : 2025-04-29
                String updateOptyId = String.valueOf(recordMap.get('Column_26')); 

                // Update - Insert 분기
                if(updateOptyMap.containsKey(updateOptyId)){
                    System.debug('<< Opportunity Udpate >>');

                    Opportunity updateOpty = updateOptyMap.get(updateOptyId);

                    String dealerId               = dealerIdMap.get(String.valueOf(recordMap.get('Column_0'))).Id;
                    String ownerId                = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Id;
                    String opportunityOwnerId     = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Id;
                    String accountId              = accMap.get(accKey).Id;
                    String dnsamodelId            = String.isNotEmpty(String.valueOf(recordMap.get('Column_5')))
                                                    ? modelMap.get(String.valueOf(recordMap.get('Column_5'))).Id
                                                    : null;
                    String probability            = String.valueOf(recordMap.get('Column_6'));
                    String mainCategory           = String.valueOf(recordMap.get('Column_11'));
                    String subCategory            = String.valueOf(recordMap.get('Column_12'));
                    String isTooling              = String.valueOf(recordMap.get('Column_13'));
                    String po                     = String.valueOf(recordMap.get('Column_14'));
                    String leadSourceDNSA         = String.valueOf(recordMap.get('Column_23'));
                    String customerContactId      = String.isNotEmpty(String.valueOf(recordMap.get('Column_21')))
                                                    ? conNameMap.get(String.valueOf(recordMap.get('Column_21'))).Id
                                                    : null;
                    String salesOrganization      = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Account.SalesOrganization__c;
                    String salesOffice            = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Account.SalesOffice__c;
                    String country                = String.valueOf(recordMap.get('Column_9'));
                    String description            = String.valueOf(recordMap.get('Column_24'));
                    String projectTypes           = String.valueOf(recordMap.get('Column_25'));

                    Boolean isUpdated = false;

                    if (isFieldUpdated(updateOpty.Dealer__c, dealerId)) {
                        updateOpty.Dealer__c = dealerId;
                        isUpdated = true;
                        System.debug('<< Opportunity Dealer__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.OwnerId, ownerId)) {
                        updateOpty.OwnerId = ownerId;
                        isUpdated = true;
                        System.debug('<< Opportunity OwnerId Update >>');
                    }
                    if (isFieldUpdated(updateOpty.Opportunity_Owner__c, opportunityOwnerId)) {
                        updateOpty.Opportunity_Owner__c = opportunityOwnerId;
                        isUpdated = true;
                        System.debug('<< Opportunity_Owner__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.AccountId, accountId)) {
                        updateOpty.AccountId = accountId;
                        isUpdated = true;
                        System.debug('<< Opportunity AccountId Update >>');
                    }
                    if (isFieldUpdated(updateOpty.DNSAModel__c, dnsamodelId)) {
                        updateOpty.DNSAModel__c = dnsamodelId;
                        isUpdated = true;
                        System.debug('<< Opportunity DNSAModel__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.Probability, Decimal.valueOf(probability))) {
                        updateOpty.Probability = Decimal.valueOf(probability);
                        isUpdated = true;
                        System.debug('<< Opportunity Probability Update >>');
                    }
                    if (isFieldUpdated(updateOpty.CloseDate, closeDate)) {
                        updateOpty.CloseDate = closeDate;
                        isUpdated = true;
                        System.debug('<< Opportunity CloseDate Update >>');
                    }
                    if (isFieldUpdated(updateOpty.RequestDelieveryDate__c, requestDate)) {
                        updateOpty.RequestDelieveryDate__c = requestDate;
                        isUpdated = true;
                        System.debug('<< Opportunity RequestDelieveryDate__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.MainCategory__c, mainCategory)) {
                        updateOpty.MainCategory__c = mainCategory;
                        isUpdated = true;
                        System.debug('<< Opportunity MainCategory__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.SubCategory__c, subCategory)) {
                        updateOpty.SubCategory__c = subCategory;
                        isUpdated = true;
                        System.debug('<< Opportunity SubCategory__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.IsTooling__c, isTooling)) {
                        updateOpty.IsTooling__c = isTooling;
                        isUpdated = true;
                        System.debug('<< Opportunity IsTooling__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.PO__c, po)) {
                        updateOpty.PO__c = po;
                        isUpdated = true;
                        System.debug('<< Opportunity PO__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.LeadSourceDNSA__c, leadSourceDNSA)) {
                        updateOpty.LeadSourceDNSA__c = leadSourceDNSA;
                        isUpdated = true;
                        System.debug('<< Opportunity LeadSourceDNSA__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.CustomerContact__c, customerContactId)) {
                        updateOpty.CustomerContact__c = customerContactId;
                        isUpdated = true;
                        System.debug('<< Opportunity CustomerContact__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.SalesOrganization__c, salesOrganization)) {
                        updateOpty.SalesOrganization__c = salesOrganization;
                        isUpdated = true;
                        System.debug('<< Opportunity SalesOrganization__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.Sales_Office__c, salesOffice)) {
                        updateOpty.Sales_Office__c = salesOffice;
                        isUpdated = true;
                        System.debug('<< Opportunity Sales_Office__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.Country__c, country)) {
                        updateOpty.Country__c = country;
                        isUpdated = true;
                        System.debug('<< Opportunity Country__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.Description__c, description)) {
                        updateOpty.Description__c = description;
                        isUpdated = true;
                        System.debug('<< Opportunity Description__c Update >>');
                    }
                    if (isFieldUpdated(updateOpty.ProjectTypes__c, projectTypes)) {
                        updateOpty.ProjectTypes__c = projectTypes;
                        isUpdated = true;
                        System.debug('<< Opportunity ProjectTypes__c Update >>');
                    }

                    if (isUpdated) {
                        System.debug('<< Opportunity Real Udpate >>');
                        optyToUpdateMap.put(updateOptyId, updateOpty); // Map에 저장 (중복 제거 및 최신 값 유지)
                    }


                } else {
                    System.debug('<< Opportunity Create >>');

                    Opportunity opty                = new Opportunity();
                    opty.Name                       = optyKey;
                    opty.RecordTypeId               = optyRT;
                    opty.Dealer__c                  = dealerIdMap.get(String.valueOf(recordMap.get('Column_0'))).Id;
                    opty.OwnerId                    = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Id;
                    // 2025-03-31 추가
                    opty.Opportunity_Owner__c       = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Id;
                    opty.StageName                  = 'Qualified';
                    opty.AccountId                  = accMap.get(accKey).Id;
                    // 0330 이주현 수정
                    opty.DNSAModel__c               = String.isNotEmpty(String.valueOf(recordMap.get('Column_5'))) ? modelMap.get(String.valueOf(recordMap.get('Column_5'))).Id : null;
                    opty.Probability                = Decimal.valueOf(String.valueOf(recordMap.get('Column_6')));
                    opty.CloseDate                  = closeDate;
                    opty.RequestDelieveryDate__c    = requestDate;      
                    opty.MainCategory__c            = String.valueOf(recordMap.get('Column_11'));
                    opty.SubCategory__c             = String.valueOf(recordMap.get('Column_12'));
                    opty.IsTooling__c               = String.valueOf(recordMap.get('Column_13'));
                    opty.PO__c                      = String.valueOf(recordMap.get('Column_14'));
                    opty.LeadSourceDNSA__c          = String.valueOf(recordMap.get('Column_23'));
                    // 2025-03-31 추가
                    opty.CustomerContact__c         = String.isNotEmpty(String.valueOf(recordMap.get('Column_21'))) ? conNameMap.get(String.valueOf(recordMap.get('Column_21'))).Id : null;
                    opty.SalesOrganization__c       = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Account.SalesOrganization__c;
                    opty.Sales_Office__c            = usernameMap.get(String.valueOf(recordMap.get('Column_2'))).Account.SalesOffice__c;
                    // 0409 이주현 추가
                    opty.Country__c                 = String.valueOf(recordMap.get('Column_9'));
                    opty.Description__c             = String.valueOf(recordMap.get('Column_24'));
                    opty.ProjectTypes__c            = String.valueOf(recordMap.get('Column_25'));

                    // 2025-04-29 추가
                    String DNSAOptyId = String.valueOf(recordMap.get('Column_26'));
                    if(!String.isBlank(DNSAOptyId)){opty.ETOpportunityId__c = DNSAOptyId;}
                    
                    // opty Name으로 Competitor 다시 Map에 할당
                    String competitor = String.valueOf(recordMap.get('Column_22'));
                    if (!String.isBlank(competitor)) { 
                        optyCompetitorMap.put(optyKey, competitorMap.get(String.valueOf(recordMap.get('Column_22'))));
                    }
                    optyToInsert.add(opty);
                }
            }

            // Opportunity Update
            if (!optyToUpdateMap.isEmpty()) {
                optyToUpdate = new List<Opportunity>(optyToUpdateMap.values());
                System.debug('update -> Upsert');
                upsert optyToUpdate;
            }

            // Opportunity Insert
            if(!optyToInsert.isEmpty()){
                System.debug('optyToInsert :: ' + optyToInsert);
                insert optyToInsert;
            }
    
            for (Opportunity opty : optyToInsert) {
                // optyCompetitorMap에 해당 키가 있는지 확인
                if (optyCompetitorMap.containsKey(opty.Name) && optyCompetitorMap.get(opty.Name) != null) {
                    // opty 생성 이후 시점에 처리 (Junction Object)
                    OpptyCompetitorMapping__c optyComp  = new OpptyCompetitorMapping__c();
                    optyComp.Opportunity__c             = opty.Id;
                    optyComp.Competitor__c              = optyCompetitorMap.get(opty.Name).Id;
                    // owner 임시 주석
                    optyComp.OwnerId                    = opty.OwnerId;
            
                    compToInsert.add(optyComp);
                }
            }

    
            if(!compToInsert.isEmpty()){
                // OpptyCompetitorMappingTriggerHandler
                System.debug('compToInsert :: ' + compToInsert);
                insert compToInsert;
            }
   
            return 'Success';

        } catch (Exception e) {
                
            System.debug('Error occurred while processing record: ' + e.getMessage());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Failed to upsert records: ' + e.getMessage());

        }

    }


    // 기존 값과 새 값이 null이나 빈 문자열인지 확인하고 비교
    private static Boolean isFieldUpdated(Object existingValue, Object newValue) {

        String existingStr = (existingValue == null ? '' : String.valueOf(existingValue));
        String newStr = (newValue == null ? '' : String.valueOf(newValue));
        return existingStr != newStr;
    }


    // 수정: 날짜 형식을 MM/DD/YYYY로 처리하도록 변경
    private static Boolean dateValidCheck(Map<String, Object> recordMap) {
        Date closeDate = parseDate(String.valueOf(recordMap.get('Column_7')));
        Date reqDelivDate = parseDate(String.valueOf(recordMap.get('Column_8')));
        return reqDelivDate > closeDate;
    }

    // 수정: 날짜 파싱 메서드 추가 (MM/DD/YYYY 및 YYYY-MM-DD 지원)
    private static Date parseDate(String dateStr) {
        if (String.isBlank(dateStr)) return null;
        
        // MM/DD/YYYY 형식 먼저 시도
        if (dateStr.contains('/')) {
            List<String> parts = dateStr.split('/');
            if (parts.size() == 3) {
                try {
                    Integer month = Integer.valueOf(parts[0]);
                    Integer day = Integer.valueOf(parts[1]);
                    Integer year = Integer.valueOf(parts[2]);
                    return Date.newInstance(year, month, day);
                } catch (Exception e) {
                    System.debug('Error parsing date in MM/DD/YYYY format: ' + dateStr);
                }
            }
        }
        
        // YYYY-MM-DD 형식 시도
        if (dateStr.contains('-')) {
            List<String> parts = dateStr.split('-');
            if (parts.size() == 3) {
                try {
                    Integer year = Integer.valueOf(parts[0]);
                    Integer month = Integer.valueOf(parts[1]);
                    Integer day = Integer.valueOf(parts[2]);
                    return Date.newInstance(year, month, day);
                } catch (Exception e) {
                    System.debug('Error parsing date in YYYY-MM-DD format: ' + dateStr);
                }
            }
        }
        
        return null;
    }
    
}