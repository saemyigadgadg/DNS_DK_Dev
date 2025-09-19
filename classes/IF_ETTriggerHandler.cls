/**
 * @author            : Yu-Hyun Park
 * @description       : IF_ET__c 레코드가 생성되면 Account, Contact, Opportunity, Competitor Mapping 등을 Update 및 Insert
 * @last modified on  : 2025-05-20
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-04-08   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class IF_ETTriggerHandler extends TriggerHandler {

    private static final Id   optyRT        = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();
    private static final Id   accCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();
    private static final Id   conCustomerRT = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ContactPerson').getRecordTypeId();


    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        try {
            if (isExecuting) {
                // Account > Contact > Opporunity > Model 순서대로 Update/Insert
                System.debug('IF_ET AFTER_INSERT TRIGGER Start');

                List<IF_ET__c> etList = (List<IF_ET__c>) news;

                // ---------------------------------------------------
                // 0. 기본 데이터 집계
                // 
                // Ellison Account Phone : 562.949.8311 
                // Ellison Account Email : info@ellisontechnologies.com
                // 
                // ---------------------------------------------------
                // Country 변환 Map
                // (Ellison Country List: Mexico, Vietnam, Saudi Arabia, Romania, Turkey, Canada, Spain, Germany, United States)
                Map<String, String> countryMapping = new Map<String, String>{
                    'Mexico'        => 'MX',
                    'Vietnam'       => 'VN',
                    'Saudi Arabia'  => 'SA',
                    'Romania'       => 'RO',
                    'Turkey'        => 'TR',
                    'Canada'        => 'CA',
                    'Spain'         => 'ES',
                    'Germany'       => 'DE',
                    'United States' => 'US'
                };

                // 집계용 Set
                Set<String> ownerETUserIds      = new Set<String>();
                Set<String> modelNameSet        = new Set<String>();
                Set<String> competitorNameSet   = new Set<String>();
                Set<String> countryCodeSet      = new Set<String>();    // CountryLookup__c Parsing
                Set<String> regionCodeSet       = new Set<String>();    // ShippingState__c

                for (IF_ET__c etRec : etList) {
                    if (etRec.OpportunityOwnerId__c != null)    ownerETUserIds.add(etRec.OpportunityOwnerId__c);
                    if (etRec.AccountOwnerId__c != null)        ownerETUserIds.add(etRec.AccountOwnerId__c);
                    if (etRec.ContactOwnerId__c != null)        ownerETUserIds.add(etRec.ContactOwnerId__c);
                    if (etRec.DNSAModel__c  != null)            modelNameSet.add(etRec.DNSAModel__c);
                    if (etRec.Competitor__c  != null)           competitorNameSet.add(etRec.Competitor__c);
                    if (etRec.CountryLookup__c != null) {
                        // CountryLookup 변환: 변환 대상이면 지정 코드 사용
                        String transformedCountry = etRec.CountryLookup__c;
                        if (countryMapping.containsKey(etRec.CountryLookup__c)) {
                            transformedCountry = countryMapping.get(etRec.CountryLookup__c);
                        }
                        countryCodeSet.add(transformedCountry);
                    }
                    if (etRec.ShippingState__c  != null)       regionCodeSet.add(etRec.ShippingState__c);
                }


                // ---------------------------------------------------
                // 1. User, Model, Competitor, Country/Region Query
                // ---------------------------------------------------
                // User 매핑: ETUserId__c 와 비교
                // Owner Ids
                Map<String, User> userByETUserId = new Map<String, User>();
                if (!ownerETUserIds.isEmpty()){
                    for (User u : [SELECT Id, ETUserId__c, SalesOrganization__c, AccountId, Account.CustomerCode__c FROM User WHERE ETUserId__c IN :ownerETUserIds]) {
                        userByETUserId.put(u.ETUserId__c, u);
                    }
                }

                // Model Name
                Map<String, DNSAModel__c> modelMap = new Map<String, DNSAModel__c>();
                if (!modelNameSet.isEmpty()){
                    for (DNSAModel__c model : [SELECT Id, Name, ModelName__c FROM DNSAModel__c WHERE Name IN :modelNameSet]) {
                        modelMap.put(model.ModelName__c, model);
                    }
                }

                // Competitor
                Map<String, Competitor__c> competitorMap = new Map<String, Competitor__c>();
                if (!competitorNameSet.isEmpty()){
                    for (Competitor__c comp : [SELECT Id, Name FROM Competitor__c WHERE Name IN :competitorNameSet]) {
                        competitorMap.put(comp.Name, comp);
                    }
                }

                // Country & Region
                Map<String, Id> countryMap = new Map<String, Id>();
                Map<String, Region__c> regionMap = new Map<String, Region__c>();
                if (!regionCodeSet.isEmpty() && !countryCodeSet.isEmpty()){
                    for (Region__c region : [SELECT Id, Country__c, Country__r.CountryCode__c, RegionCode__c 
                                              FROM Region__c 
                                              WHERE RegionCode__c IN :regionCodeSet 
                                              AND Country__r.CountryCode__c IN :countryCodeSet]) {
                        countryMap.put(region.Country__r.CountryCode__c, region.Country__c);
                        regionMap.put(region.RegionCode__c, region);
                    }
                }


                // ----------------------------------------------------
                // 2. Account 처리 (Opportunity 생성/업데이트 전에 Account가 반드시 존재해야 함)
                // ----------------------------------------------------
                Set<String> accountExtIds = new Set<String>();
                for(IF_ET__c etRec : etList) {
                    if(etRec.AccountId__c != null) {
                        accountExtIds.add(etRec.AccountId__c);
                    }
                }

                // 기존 Account 조회
                Map<String, Account> existingAccMap = new Map<String, Account>();
                if (!accountExtIds.isEmpty()){
                    List<Account> existAccList = [
                        SELECT  Id, ETAccountId__c, Name, Phone, Email__c, Representative__c, ShippingCountry,
                                ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, CountryLookup__c, RegionLookup__c, OwnerId
                        FROM    Account
                        WHERE   ETAccountId__c IN :accountExtIds];

                    for (Account acc : existAccList) {
                        existingAccMap.put(acc.ETAccountId__c, acc);
                    }
                }

                Map<String, Account> accToUpsertMap = new Map<String, Account>();
                List<Account> accToUpsert           = new List<Account>();

                for(IF_ET__c etRec : etList) {
                    if(etRec.AccountId__c != null) {
                        Account acc;

                        if(existingAccMap.containsKey(etRec.AccountId__c)) {
                            System.debug('<< Account Udpate >>');

                            acc = existingAccMap.get(etRec.AccountId__c);
                            Boolean isUpdated = false;

                            // Representative 10자 제한
                            String repValue = etRec.Representative__c != null && etRec.Representative__c.length() > 10 
                                            ? etRec.Representative__c.substring(0, 10) 
                                            : etRec.Representative__c;

                            if (isFieldUpdated(acc.Name, etRec.AccountName__c))                                 {acc.Name = etRec.AccountName__c;                                   isUpdated = true; System.debug('<< Account Name Update >>'); }
                            if (isFieldUpdated(acc.Representative__c, repValue))                                {acc.Representative__c = repValue;                                  isUpdated = true; System.debug('<< Account Representative Update >>'); }
                            if (isFieldUpdated(acc.ShippingCountry, etRec.ShippingCountry__c))                  {acc.ShippingCountry = etRec.ShippingCountry__c;                    isUpdated = true; System.debug('<< Account ShippingCountry Update >>'); }
                            if (isFieldUpdated(acc.ShippingStreet, etRec.ShippingStreet__c))                    {acc.ShippingStreet = etRec.ShippingStreet__c;                      isUpdated = true; System.debug('<< Account ShippingStreet Update >>'); }
                            if (isFieldUpdated(acc.ShippingCity, etRec.ShippingCity__c))                        {acc.ShippingCity = etRec.ShippingCity__c;                          isUpdated = true; System.debug('<< Account ShippingCity Update >>'); }
                            if (isFieldUpdated(acc.ShippingState, etRec.ShippingState__c))                      {acc.ShippingState = etRec.ShippingState__c;                        isUpdated = true; System.debug('<< Account ShippingState Update >>'); }
                            if (isFieldUpdated(acc.ShippingPostalCode, etRec.ShippingPostalCode__c))            {acc.ShippingPostalCode = etRec.ShippingPostalCode__c;              isUpdated = true; System.debug('<< Account ShippingPostalCode Update >>'); }

                            if (etRec.AccountOwnerId__c != null && userByETUserId.containsKey(etRec.AccountOwnerId__c)) {
                                String newOwnerId = userByETUserId.get(etRec.AccountOwnerId__c).Id;
                                if (isFieldUpdated(acc.OwnerId, newOwnerId)) {
                                    acc.OwnerId = newOwnerId;
                                    isUpdated = true;
                                    System.debug('<< Account OwnerId Update >>');
                                }
                            }

                            if (isFieldUpdated(acc.CountryLookup__c, countryMap.get(countryMapping.get(etRec.CountryLookup__c))))   {acc.CountryLookup__c = countryMap.get(countryMapping.get(etRec.CountryLookup__c));     isUpdated = true; System.debug('<< Account Country Update >>'); }

                            if (etRec.ShippingState__c != null && regionMap.containsKey(etRec.ShippingState__c)) {
                                Id newRegionId = regionMap.get(etRec.ShippingState__c).Id;
                                if (isFieldUpdated(acc.RegionLookup__c, newRegionId)) {
                                    acc.RegionLookup__c = newRegionId;
                                    isUpdated = true;
                                    System.debug('<< Account Region Update >>');
                                }
                            }

                            // 전화번호 및 이메일
                            if (etRec.AccountPhone__c != null) {
                                if (isFieldUpdated(acc.Phone, etRec.AccountPhone__c)) {
                                    acc.Phone = etRec.AccountPhone__c;
                                    isUpdated = true;
                                    System.debug('<< Account Phone Update >>');
                                }
                            }
                            // else {
                            //     if (isFieldUpdated(acc.Phone, etRec.ContactPhone__c)) {
                            //         acc.Phone = etRec.ContactPhone__c;
                            //         isUpdated = true;
                            //         System.debug('<< Account Phone Update - from ContactPhone >>');
                            //     }
                            // }

                            if (etRec.AccountEmail__c != null) {
                                if (isFieldUpdated(acc.Email__c, etRec.AccountEmail__c)) {
                                    acc.Email__c = etRec.AccountEmail__c;
                                    isUpdated = true;
                                    System.debug('<< Account Email Update >>');
                                }
                            }
                            // else {
                            //     if (isFieldUpdated(acc.Email__c, etRec.ContactEmail__c)) {
                            //         acc.Email__c = etRec.ContactEmail__c;
                            //         isUpdated = true;
                            //         System.debug('<< Account Email Update - from ContactEmail >>');
                            //     }
                            // }

                            if (isUpdated) {
                                System.debug('<< Account Object Udpate >>');
                                accToUpsertMap.put(etRec.AccountId__c, acc); // Map에 저장 (중복 제거 및 최신 값 유지)
                            }

                        } else {
                            System.debug('<< Account Insert >>');

                            // Representative 10자 제한
                            String repValue = etRec.Representative__c != null && etRec.Representative__c.length() > 10 
                                            ? etRec.Representative__c.substring(0, 10) 
                                            : etRec.Representative__c;

                            acc = new Account();

                            acc.ETAccountId__c      = etRec.AccountId__c;
                            acc.Name                = etRec.AccountName__c;
                            acc.Representative__c   = repValue;
                            acc.ShippingCountry     = etRec.ShippingCountry__c;
                            acc.ShippingStreet      = etRec.ShippingStreet__c;
                            acc.ShippingCity        = etRec.ShippingCity__c;
                            acc.ShippingState       = etRec.ShippingState__c;
                            acc.ShippingPostalCode  = etRec.ShippingPostalCode__c;
                            acc.CurrencyIsoCode     = 'USD';


                            if (etRec.CountryLookup__c != null && countryMap.containsKey(countryMapping.get(etRec.CountryLookup__c))) {
                                acc.CountryLookup__c = countryMap.get(countryMapping.get(etRec.CountryLookup__c));
                            }
                            if (etRec.ShippingState__c != null && regionMap.containsKey(etRec.ShippingState__c)) {
                                acc.RegionLookup__c = regionMap.get(etRec.ShippingState__c).Id;
                            }
                            if (etRec.AccountPhone__c != null){ acc.Phone = etRec.AccountPhone__c;      } else { acc.Phone = '562.949.8311';     }
                            if (etRec.AccountEmail__c != null){ acc.Email__c = etRec.AccountEmail__c;   } else { acc.Email__c = 'info@ellisontechnologies.com';  }
                            if(etRec.AccountOwnerId__c != null && userByETUserId.containsKey(etRec.AccountOwnerId__c)) {
                                acc.OwnerId = userByETUserId.get(etRec.AccountOwnerId__c).Id;
                            }
                            acc.RecordTypeId = accCustomerRT;

                            existingAccMap.put(etRec.AccountId__c, acc);
                        }
                    }
                }

                // update : List<Account>로 변환 후, 최종 upsert 실행.
                if (!accToUpsertMap.isEmpty()) {
                    accToUpsert = new List<Account>(accToUpsertMap.values());
                    System.debug('update -> Upsert');
                }

                // insert : List<Account>로 변환 후, 최종 upsert 실행.
                if (!existingAccMap.isEmpty()) {
                    accToUpsert = new List<Account>(existingAccMap.values());
                    System.debug('insert -> Upsert');
                }

                // Account(Customer) Upsert
                if(!accToUpsert.isEmpty()){

                    System.debug('accToUpsert Final size :: ' + accToUpsert.size());
                    System.debug('acc To upsert :: ' + accToUpsert);
                    upsert accToUpsert;
                }

                
                // ---------------------------------------------------
                // Account Insert 후 > Related Dealer 등록
                // ---------------------------------------------------
                List<DNS_CustomerDealerAssociation__c> cdaToInsert = new List<DNS_CustomerDealerAssociation__c>();

                Set<String> cdaKeys = new Set<String>();

                for(IF_ET__c etRec : etList) {
                    for(Account acc : accToUpsert){
                        
                        if(userByETUserId.containsKey(etRec.AccountOwnerId__c) && existingAccMap.containsKey(etRec.AccountId__c)) {
                            Id dealerId     = userByETUserId.get(etRec.AccountOwnerId__c).AccountId;
                            Id customerId   = existingAccMap.get(etRec.AccountId__c).Id;

                            String cdaKey = dealerId + '-' + customerId;
    
                            if (!cdaKeys.contains(cdaKey)) {
    
                                DNS_CustomerDealerAssociation__c newCda = new DNS_CustomerDealerAssociation__c();
                                newCda.Customer__c = customerId;
                                newCda.Dealer__c   = dealerId;
                                newCda.OwnerId     = acc.OwnerId;
                
                                cdaToInsert.add(newCda);
                                cdaKeys.add(cdaKey);
                            }
                        }

                    }
                }

                if(!cdaToInsert.isEmpty()){
                    System.debug('cdaToInsert :: ' + cdaToInsert);
                    insert cdaToInsert;
                }


                // ---------------------------------------------------
                // 3. Contact 처리 (Account와 연결된 Contact 업데이트/삽입)
                // ---------------------------------------------------

                Set<String> contactAccExtIds = new Set<String>();
                for(IF_ET__c etRec : etList) {
                    if(etRec.ContactAccountId__c != null) {
                        contactAccExtIds.add(etRec.ContactAccountId__c);
                    }
                }

                Map<String, Account> contactAccMap = new Map<String, Account>();
                if (!contactAccExtIds.isEmpty()){
                    for (Account acc : [SELECT Id, ETAccountId__c FROM Account WHERE ETAccountId__c IN :contactAccExtIds]) {
                        contactAccMap.put(acc.ETAccountId__c, acc);
                    }
                }

                // 해당 Account 하위에 있는 기존 Contact들을 조회
                Map<Id, List<Contact>> existingContactsByAccId = new Map<Id, List<Contact>>();
                if (!contactAccMap.isEmpty()) {
                    for (Contact con : [
                            SELECT Id, FirstName, LastName, MiddleName, Email, Phone, MobilePhone, OwnerId, AccountId 
                            FROM Contact 
                            WHERE AccountId IN :contactAccMap.values()
                            AND RecordTypeId = :conCustomerRT
                    ]) {
                        if (!existingContactsByAccId.containsKey(con.AccountId)) {
                            existingContactsByAccId.put(con.AccountId, new List<Contact>());
                        }
                        existingContactsByAccId.get(con.AccountId).add(con);
                    }
                }

                // Contact upsert용 Map (Key: [AccountId]_[LastName]_[FirstName])
                Map<String, Contact> contactsToUpsertMap = new Map<String, Contact>();

                for (IF_ET__c etRec : etList) {
                    // 필수 : ContactAccountId, LastName, FirstName 값이 있어야 한다.
                    if (etRec.ContactAccountId__c != null && 
                        !String.isBlank(etRec.LastName__c) && 
                        !String.isBlank(etRec.FirstName__c)
                    ) {
                        // 해당 ContactAccountId__c에 해당하는 Account를 가져온다.
                        if (contactAccMap.containsKey(etRec.ContactAccountId__c)) {
                            Account relatedAcc = contactAccMap.get(etRec.ContactAccountId__c);
                            // 컴포짓 키: [AccountId]_[LastName]_[FirstName]
                            String compKey = relatedAcc.Id + '_' + etRec.LastName__c + '_' + etRec.FirstName__c;
                            
                            Contact targetCon;
                            // 이미 처리할 대상으로 map에 담긴 경우
                            if (contactsToUpsertMap.containsKey(compKey)) {
                                targetCon = contactsToUpsertMap.get(compKey);
                            } else {
                                // 기존 Contact가 있는지, 조회된 기존 Contact Map에서 확인한다.
                                Boolean found = false;
                                if (existingContactsByAccId.containsKey(relatedAcc.Id)) {
                                    for (Contact con : existingContactsByAccId.get(relatedAcc.Id)) {
                                        if (con.LastName == etRec.LastName__c && con.FirstName == etRec.FirstName__c) {
                                            targetCon = con;
                                            found = true;
                                            break;
                                        }
                                    }
                                }
                                if (!found) {
                                    // 신규 Contact 생성
                                    targetCon = new Contact();
                                    targetCon.RecordTypeId = conCustomerRT;
                                    targetCon.AccountId = relatedAcc.Id;
                                    // OwnerId는 etRec.ContactOwnerId__c를 기준으로 할당
                                    if (etRec.ContactOwnerId__c != null && userByETUserId.containsKey(etRec.ContactOwnerId__c)) {
                                        targetCon.OwnerId = userByETUserId.get(etRec.ContactOwnerId__c).Id;
                                    }
                                }
                            }
                            
                            // Contact 필드 값 업데이트 (필요한 경우만 변경)
                            if (isFieldUpdated(targetCon.FirstName, etRec.FirstName__c)) {
                                targetCon.FirstName = etRec.FirstName__c;
                            }
                            if (isFieldUpdated(targetCon.LastName, etRec.LastName__c)) {
                                targetCon.LastName = etRec.LastName__c;
                            }
                            if (isFieldUpdated(targetCon.MiddleName, etRec.MiddleName__c)) {
                                targetCon.MiddleName = etRec.MiddleName__c;
                            }
                            if (isFieldUpdated(targetCon.Email, etRec.ContactEmail__c)) {
                                targetCon.Email = etRec.ContactEmail__c;
                            }
                            if (isFieldUpdated(targetCon.Phone, etRec.ContactPhone__c)) {
                                targetCon.Phone = etRec.ContactPhone__c;
                            }
                            if (isFieldUpdated(targetCon.MobilePhone, etRec.MobilePhone__c)) {
                                targetCon.MobilePhone = etRec.MobilePhone__c;
                            }
                            
                            contactsToUpsertMap.put(compKey, targetCon);
                        }
                    }
                }
                
                // 최종 upsert: Id값이 있는 경우 update, 없으면 insert
                List<Contact> contactsToUpsert = contactsToUpsertMap.values();
                if (!contactsToUpsert.isEmpty()) {
                    upsert contactsToUpsert;
                }


                // ----------------------------------------------------
                // 4. Opportunity 처리 (Account/Contact 처리 후)
                // ----------------------------------------------------
                Set<String> oppExtIds = new Set<String>();

                for(IF_ET__c etRec : etList) {
                    if(etRec.OpportunityId__c != null){
                        oppExtIds.add(etRec.OpportunityId__c);
                    }
                }

                Map<String, Opportunity> existingOppMap = new Map<String, Opportunity>();

                if (!oppExtIds.isEmpty()){
                    List<Opportunity> existOptyLis = [
                        SELECT  Id, ETOpportunityId__c, Name, CloseDate, OwnerId, AccountId, Dealer__c, SalesOrganization__c,
                                RequestDelieveryDate__c, Probability, PO__c, DNSAModel__c, Country__c, Opportunity_Owner__c
                        FROM    Opportunity 
                        WHERE   ETOpportunityId__c IN :oppExtIds
                    ];

                    for (Opportunity opp : existOptyLis) {
                        existingOppMap.put(opp.ETOpportunityId__c, opp);
                    }
                }

                Map<String, Opportunity> optyToUpsertMap = new Map<String, Opportunity>();
                List<Opportunity> optyToUpsert           = new List<Opportunity>();

                // 신규 Opportunity에 대해 composite prefix를 보관하기 위한 맵
                // key: Opportunity record (신규 insert 예정), value: (예: "CustomerName_DNSAModel_MMDDYY_")
                Map<String, String> newOppPrefixMap = new Map<String, String>();

                for(IF_ET__c etRec : etList) {
                    if(etRec.OpportunityId__c != null) {

                        Opportunity opp;
                        // Account 처리 결과에서 Opportunity가 참조할 Account Id 획득
                        Id relatedAccId = null;
                        if(etRec.AccountId__c != null && existingAccMap.containsKey(etRec.AccountId__c)) {
                            relatedAccId = existingAccMap.get(etRec.AccountId__c).Id;
                        }

                        if(existingOppMap.containsKey(etRec.OpportunityId__c)) {

                            System.debug('<< Opportunity Update >>');
                            opp = existingOppMap.get(etRec.OpportunityId__c);
                            Boolean isUpdated = false;

                            if (etRec.Probability__c != null && etRec.Probability__c != '') {
                                Decimal newProbability = Decimal.valueOf(etRec.Probability__c);
                                if (isFieldUpdated(String.valueOf(opp.Probability), String.valueOf(newProbability))) {
                                    opp.Probability = newProbability;
                                    isUpdated = true;
                                    System.debug('<< Opportunity Probability Update >>');
                                }
                            }
                            
                            if (etRec.CloseDate__c != null && etRec.CloseDate__c != '') {
                                Date newCloseDate = Date.valueOf(etRec.CloseDate__c);
                                if (isFieldUpdated(opp.CloseDate, newCloseDate)) {
                                     opp.CloseDate = newCloseDate;
                                     isUpdated = true;
                                     System.debug('<< Opportunity CloseDate Update >>');
                                }
                            }
                            
                            if (isFieldUpdated(opp.PO__c, etRec.PO__c))         {opp.PO__c = etRec.PO__c;       isUpdated = true; System.debug('<< Opportunity PO Update >>'); }
                            if (isFieldUpdated(opp.AccountId, relatedAccId))    {opp.AccountId = relatedAccId;  isUpdated = true; System.debug('<< Opportunity AccountId Update >>'); }

                            if (etRec.CountryLookup__c != null && countryMap.containsKey(countryMapping.get(etRec.CountryLookup__c))){
                                String newCountry = countryMapping.get(etRec.CountryLookup__c);
                                if (isFieldUpdated(opp.Country__c, newCountry)) {
                                    opp.Country__c = newCountry;
                                    isUpdated = true;
                                    System.debug('<< Opportunity Country Update >>');
                                }
                            }

                            if (etRec.OpportunityOwnerId__c != null && userByETUserId.containsKey(etRec.OpportunityOwnerId__c)) {
                                String newOwnerId   = userByETUserId.get(etRec.OpportunityOwnerId__c).Id;
                                String newDealerId  = userByETUserId.get(etRec.OpportunityOwnerId__c).AccountId;
                                String newSalesOrg  = userByETUserId.get(etRec.OpportunityOwnerId__c).SalesOrganization__c;
                                if (isFieldUpdated(opp.OwnerId, newOwnerId)) {
                                    opp.OwnerId                     = newOwnerId;
                                    opp.Opportunity_Owner__c        = newOwnerId;
                                    isUpdated = true;
                                    System.debug('<< Opportunity OwnerId Update >>');
                                }
                                if (isFieldUpdated(opp.Dealer__c, newDealerId)) {
                                    opp.Dealer__c = newDealerId;
                                    isUpdated = true;
                                    System.debug('<< Opportunity Dealer Update >>');
                                }
                                if (isFieldUpdated(opp.SalesOrganization__c, newSalesOrg)) {
                                    opp.SalesOrganization__c = newSalesOrg;
                                    isUpdated = true;
                                    System.debug('<< Opportunity SalesOrganization Update >>');
                                }
                            }

                            if (etRec.DNSAModel__c != null && modelMap.containsKey(etRec.DNSAModel__c)) {
                                String newModelId = modelMap.get(etRec.DNSAModel__c).Id;
                                if (isFieldUpdated(opp.DNSAModel__c, newModelId)) {
                                    opp.DNSAModel__c = newModelId;
                                    isUpdated = true;
                                    System.debug('<< Opportunity DNSAModel Update >>');
                                }
                            }

                            if (etRec.RequestDelieveryDate__c != null && etRec.RequestDelieveryDate__c != '') {
                                Date reqDelDate = Date.valueOf(etRec.RequestDelieveryDate__c);
                                if (isFieldUpdated(opp.RequestDelieveryDate__c, reqDelDate)) {
                                    opp.RequestDelieveryDate__c = reqDelDate;
                                    isUpdated = true;
                                    System.debug('<< Opportunity RequestDelieveryDate Update >>');
                                }
                            } else {
                                Date defaultReqDelDate = opp.CloseDate.addDays(60);
                                if (isFieldUpdated(opp.RequestDelieveryDate__c, defaultReqDelDate)) {
                                    opp.RequestDelieveryDate__c = defaultReqDelDate;
                                    isUpdated = true;
                                    System.debug('<< Opportunity RequestDelieveryDate Default (+60 Days) Update >>');
                                }
                            }

                            if (isUpdated) {
                                System.debug('<< Opportunity Object Udpate >>');
                                optyToUpsertMap.put(etRec.OpportunityId__c, opp); // Map에 저장 (중복 제거 및 최신 값 유지)
                            }

                        } else {

                            System.debug('<< Opportunity Insert >>');

                            opp = new Opportunity();

                            opp.ETOpportunityId__c      = etRec.OpportunityId__c;
                            opp.Name                    = '';
                            opp.PO__c                   = etRec.PO__c;
                            opp.RecordTypeId            = optyRT;
                            opp.StageName               = 'Qualified';
                            opp.CurrencyIsoCode         = 'USD';
                            opp.IsIF_ET__c              = true;

                            if (etRec.CloseDate__c != null && etRec.CloseDate__c != '') {
                                opp.CloseDate = Date.valueOf(etRec.CloseDate__c);
                            }

                            if (etRec.Probability__c != null && etRec.Probability__c != '') {
                                opp.Probability = Decimal.valueOf(etRec.Probability__c);
                            }

                            if (etRec.CountryLookup__c != null && countryMap.containsKey(
                                    countryMapping.containsKey(etRec.CountryLookup__c)
                                    ? countryMapping.get(etRec.CountryLookup__c)
                                    : etRec.CountryLookup__c)) {
                                opp.Country__c = countryMapping.containsKey(etRec.CountryLookup__c)
                                                ? countryMapping.get(etRec.CountryLookup__c)
                                                : etRec.CountryLookup__c;
                            }

                            if(etRec.OpportunityOwnerId__c != null && userByETUserId.containsKey(etRec.OpportunityOwnerId__c)) {
                                opp.OwnerId                     = userByETUserId.get(etRec.OpportunityOwnerId__c).Id;
                                opp.Opportunity_Owner__c        = userByETUserId.get(etRec.OpportunityOwnerId__c).Id;
                                opp.OpportunityIdentifier__c    = userByETUserId.get(etRec.OpportunityOwnerId__c).Id;
                                opp.Dealer__c                   = userByETUserId.get(etRec.OpportunityOwnerId__c).AccountId;
                                opp.SalesOrganization__c        = userByETUserId.get(etRec.OpportunityOwnerId__c).SalesOrganization__c;

                            }


                            if (etRec.RequestDelieveryDate__c != null && etRec.RequestDelieveryDate__c != '') {
                                opp.RequestDelieveryDate__c = Date.valueOf(etRec.RequestDelieveryDate__c);
                                System.debug('<< Opportunity RequestDelieveryDate Insert >>');
                            } else {
                                Date defaultReqDelDate = opp.CloseDate.addDays(60);
                                opp.RequestDelieveryDate__c = defaultReqDelDate;
                                System.debug('<< Opportunity RequestDelieveryDate Default (+60 Days) Insert >>');
                            }

                            if(relatedAccId != null) {
                                opp.AccountId = relatedAccId;
                            }

                            if(etRec.DNSAModel__c != null && modelMap.containsKey(etRec.DNSAModel__c)){
                                opp.DNSAModel__c = modelMap.get(etRec.DNSAModel__c).Id;
                            }

                            // Opportunity Name Setting
                            // 1. AccountName
                            String accountName = '';
                            if(etRec.AccountId__c != null && existingAccMap.containsKey(etRec.AccountId__c)) {
                                accountName = existingAccMap.get(etRec.AccountId__c).Name;
                            }

                             // 2. 모델명: etRec.DNSAModel__c를 기준으로 modelMap에 존재하면 model의 Name, 없으면 etRec값 사용
                            String modelName = '';
                            if(etRec.DNSAModel__c != null) {
                                if(modelMap.containsKey(etRec.DNSAModel__c) && modelMap.get(etRec.DNSAModel__c).Name != null) {
                                    modelName = modelMap.get(etRec.DNSAModel__c).Name;
                                } else {
                                    modelName = etRec.DNSAModel__c;
                                }
                            }

                            // 3. 생성일자: IF_ET__c의 CreatedDate (MMddyy 형식)
                            String createdDateStr = etRec.CreatedDate.format('MMddyy');
                            // 4. composite prefix (뒤에 '_' 추가)
                            String compositePrefix = accountName + '_' + (String.isBlank(modelName) ? '' : (modelName + '_')) + createdDateStr + '_';

                            // 이후 seq 번호를 붙일 예정이므로 임시 저장
                            newOppPrefixMap.put(opp.ETOpportunityId__c, compositePrefix);
                            existingOppMap.put(etRec.OpportunityId__c, opp);
                            // oppToInsert.add(opp);
                            
                        }
                    }
                }

                // -------------------------
                // Opportunity Name 최종 SeqNo 처리
                // -------------------------

                // 1. 신규 Opportunity Insert 대상의 composite prefix 집합 생성
                Set<String> allPrefixes = new Set<String>();
                for(String prefix : newOppPrefixMap.values()) {
                    allPrefixes.add(prefix);
                }

                // 2. 각 prefix에 대해 기존 Opportunity에서 동일 prefix를 가진 레코드들의 Name을 조회해서, 최대 SeqNo를 산출
                Map<String, Integer> prefixMaxSeqMap = new Map<String, Integer>();
                for(String prefix : allPrefixes) {
                    prefixMaxSeqMap.put(prefix, 0);
                }

                // 동적 조건으로 한 번에 조회하기 위해 각 prefix에 대한 조건 리스트 생성
                List<String> conditionList = new List<String>();
                for(String prefix : allPrefixes) {
                    // 예: Name LIKE 'Acme_DNSAModel_20250410_%'
                    conditionList.add('Name LIKE \'' + String.escapeSingleQuotes(prefix) + '%\'');
                }

                if(!conditionList.isEmpty()){
                    String condition = String.join(conditionList, ' OR ');
                    // 동적 SOQL 쿼리 실행
                    List<Opportunity> existingOpps = Database.query('SELECT Name FROM Opportunity WHERE ' + condition);
                    for(Opportunity oppExisting : existingOpps) {
                        // 각 existing Opportunity의 Name이 어느 prefix로 시작하는지 체크
                        for(String prefix : allPrefixes) {
                            if(oppExisting.Name != null && oppExisting.Name.startsWith(prefix)) {
                                // prefix 이후에 나온 부분이 SeqNo라고 가정 (예: "01", "02", …)
                                String seqPart = oppExisting.Name.substring(prefix.length());
                                try {
                                    Integer seqVal = Integer.valueOf(seqPart);
                                    if(seqVal > prefixMaxSeqMap.get(prefix)) {
                                        prefixMaxSeqMap.put(prefix, seqVal);
                                    }
                                } catch(Exception e) {
                                    // 파싱 실패시 무시
                                }
                            }
                        }
                    }
                }

                // update : List<Opportunity>로 변환 후, 최종 upsert 실행.
                if (!optyToUpsertMap.isEmpty()) {
                    optyToUpsert = new List<Opportunity>(optyToUpsertMap.values());
                    System.debug('update -> Upsert');
                }

                // insert : List<Opportunity>로 변환 후, 최종 upsert 실행.
                if (!existingOppMap.isEmpty()) {
                    optyToUpsert = new List<Opportunity>(existingOppMap.values());
                    System.debug('insert -> Upsert');
                }
                
                // 3. 신규 Opportunity에 대해 같은 prefix별로 local counter 증가시켜 최종 Name 세팅
                Map<String, Integer> newOppCounter = new Map<String, Integer>();
                for(Opportunity opp : optyToUpsert) {

                    if(newOppPrefixMap.containsKey(opp.ETOpportunityId__c)){

                        String prefix = newOppPrefixMap.get(opp.ETOpportunityId__c);
                        System.debug('prefix :: ' + prefix);
                        Integer counter = newOppCounter.containsKey(prefix) ? newOppCounter.get(prefix) : 0;
                        counter++;
                        newOppCounter.put(prefix, counter);
                        // 기존 최대 값에 신규 카운터를 더함
                        Integer finalSeq = prefixMaxSeqMap.get(prefix) + counter;
                        // 두 자리 문자열로 포맷 (예, 1 -> "01")
                        String seqStr = (finalSeq < 10 ? '0' + String.valueOf(finalSeq) : String.valueOf(finalSeq));
                        // 최종 Name 구성: prefix는 이미 뒤에 '_'가 붙어있으므로 그대로 사용
                        opp.Name = prefix + seqStr;
                    }
                }


                // Opportunity Upsert
                if(!optyToUpsert.isEmpty()){

                    System.debug('optyToUpsert Final size :: ' + optyToUpsert.size());
                    System.debug('opty To upsert :: ' + optyToUpsert);
                    upsert optyToUpsert;
                }


                // ---------------------------------------------------
                // 5. Competitor Mapping 처리
                // ---------------------------------------------------
                // 5-1. 각 IF_ET__c 레코드와 Opportunity 사이의 연계를 위해 외부 Id를 기반으로 매핑
                Map<String, IF_ET__c> etByOppExtId = new Map<String, IF_ET__c>();
                for (IF_ET__c etRec : etList) {
                    if (etRec.OpportunityId__c != null) {
                        etByOppExtId.put(etRec.OpportunityId__c, etRec);
                    }
                }

                // 5-2. Opportunity 외부 Id와 실제 Opportunity 레코드 매핑 (optyToUpsert가 최종 upsert된 Opportunity 목록)
                Map<String, Opportunity> oppByExtId = new Map<String, Opportunity>();
                for (Opportunity opp : optyToUpsert) {
                    oppByExtId.put(opp.ETOpportunityId__c, opp);
                }

                // 5-3. 필요한 Competitor 이름 수집 (IF_ET__c의 Competitor__c 값)
                Set<String> requiredCompetitorNames = new Set<String>();
                for (String oppExtId : etByOppExtId.keySet()) {
                    IF_ET__c etRec = etByOppExtId.get(oppExtId);
                    if (etRec.Competitor__c != null) {
                        requiredCompetitorNames.add(etRec.Competitor__c);
                    }
                }

                // 5-4. 신규로 생성할 Competitor 레코드 생성 (기존 competitorMap에 없는 경우)
                Set<String> newCompetitorNames = new Set<String>();
                for (String compName : requiredCompetitorNames) {
                    if (!competitorMap.containsKey(compName)) {
                        newCompetitorNames.add(compName);
                    }
                }
                List<Competitor__c> newCompetitors = new List<Competitor__c>();
                for (String compName : newCompetitorNames) {
                    Competitor__c comp = new Competitor__c();
                    comp.Name = compName;
                    newCompetitors.add(comp);
                }
                if (!newCompetitors.isEmpty()) {
                    insert newCompetitors;
                    for (Competitor__c comp : newCompetitors) {
                        competitorMap.put(comp.Name, comp);
                    }
                }

                // 5-5. 신규 또는 변경된 매핑 기록을 upsert 처리
                // 여기서 각 매핑에 대해 MappingKey__c (예: OpportunityId + '-' + CompetitorId) 값을 할당하여 upsert DML을 수행
                List<OpptyCompetitorMapping__c> mappingList = new List<OpptyCompetitorMapping__c>();
                for (String oppExtId : etByOppExtId.keySet()) {
                    IF_ET__c etRec = etByOppExtId.get(oppExtId);
                    if (etRec.Competitor__c != null && oppByExtId.containsKey(oppExtId)) {
                        Opportunity opp = oppByExtId.get(oppExtId);
                        Competitor__c comp = competitorMap.get(etRec.Competitor__c);
                        if (comp != null) {
                            // MappingKey__c는 Opportunity Id와 Competitor Id를 결합하여 고유키로 사용
                            OpptyCompetitorMapping__c mapping = new OpptyCompetitorMapping__c();
                            mapping.Opportunity__c = opp.Id;
                            mapping.Competitor__c = comp.Id;
                            mapping.OwnerId = opp.OwnerId;
                            mappingList.add(mapping);
                        }
                    }
                }
                if (!mappingList.isEmpty()) {
                    upsert mappingList;
                }

                // ---------------------------------------------------
                // 6. 후처리: IF_ET__c 레코드의 isConverted__c를 true로 업데이트
                // ---------------------------------------------------
                List<IF_ET__c> etUpdateList = new List<IF_ET__c>();
                for (IF_ET__c etRec : etList) {
                    // 필요한 경우 isConverted__c가 false인 경우만 업데이트하도록 조건 추가 가능
                    etUpdateList.add(new IF_ET__c(Id = etRec.Id, isConverted__c = true));
                }
                if (!etUpdateList.isEmpty()) {
                    update etUpdateList;
                }

                setting(false, TriggerOperation.AFTER_INSERT);
                System.debug('IF_ET AFTER_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
        }
    }


    // 기존 값과 새 값이 null이나 빈 문자열인지 확인하고 비교
    private static Boolean isFieldUpdated(Object existingValue, Object newValue) {

        String existingStr = (existingValue == null ? '' : String.valueOf(existingValue));
        String newStr = (newValue == null ? '' : String.valueOf(newValue));
        return existingStr != newStr;
    }
}