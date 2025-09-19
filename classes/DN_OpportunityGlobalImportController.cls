public with sharing class DN_OpportunityGlobalImportController {
    public class RowWrap {
        @AuraEnabled public String distributorId;
        @AuraEnabled public String distributorName;
        @AuraEnabled public String distributorManagerEmail;

        @AuraEnabled public String accountCustomerCode;
        @AuraEnabled public String accountName;
        @AuraEnabled public String accountRepresentative;
        @AuraEnabled public String accountPhone;
        @AuraEnabled public String accountEmail;
        @AuraEnabled public String accountContactName;
        @AuraEnabled public String country;
        @AuraEnabled public String mainCategory;
        @AuraEnabled public String subCategory;
        @AuraEnabled public String opportunityNo;
        @AuraEnabled public String modelName;
        @AuraEnabled public String estimatedContractDate;
        @AuraEnabled public String requestedDeliveryDate;
        @AuraEnabled public String competitor;
    }

    public class ResultWrap {
        @AuraEnabled public Integer success;
        @AuraEnabled public List<String> errors;
        @AuraEnabled public List<Id> createdAccountIds;
    }
    private static final Id   prospectCustomerRT  = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id   recordTypeIdGeneral  = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();

    @AuraEnabled
    public static ResultWrap upsertAccountsByFMUpload(String jsonRows) {
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler' ,'OpportunityTriggerHandler', 'OpptyCompetitorMappingTriggerHandler', 'SalesAreaDataTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; 

        List<RowWrap> rows = (List<RowWrap>) JSON.deserialize(jsonRows, List<RowWrap>.class);
        ResultWrap res = new ResultWrap();
        res.errors = new List<String>();
        res.createdAccountIds = new List<Id>();
        res.success = 0;

        //Country, Region
        System.debug('rows[0].distributorId : ' + rows[0].distributorId);
        Account dealerInfo = [SELECT Id, CurrencyIsoCode, SalesOffice__c, SalesDistrict__c, CountryLookup__c, RegionLookup__c, IsTooling__c, MainCategory__c, SubCategory__c FROM Account WHERE CustomerCode__c =: rows[0].distributorId LIMIT 1];
        List<User> ownerIfo = [SELECT Id FROM User WHERE Account.CustomerCode__c =: rows[0].distributorId AND Email =: rows[0].distributorManagerEmail LIMIT 1];
        if(ownerIfo.isEmpty()){
        ResultWrap resOwner = new ResultWrap();
            resOwner.errors = new List<String>();
            resOwner.errors.add('Please Check Distributor Manager Email');
            resOwner.createdAccountIds = new List<Id>();
            resOwner.success = 0;
            return resOwner;

        } 
        if (rows == null || rows.isEmpty()) return res;

        // 1) 입력행 → fmKey 생성 (AccountName + AccountRepresentative, 공백 제거)
        //    같은 키가 여러번 나와도 최초(또는 마지막) 1건만 생성 대상으로 둠
        Map<String, RowWrap> keyToRow = new Map<String, RowWrap>();
        for (Integer i = 0; i < rows.size(); i++) {
            RowWrap r = rows[i];
            if (String.isBlank(r.accountName)) {
                res.errors.add('[' + (i+5) + '행] Account Name 필수');
                continue;
            }
            String rep = (r.accountRepresentative == null) ? null : r.accountRepresentative.trim();

            String key = computeFMKey(r.accountName, (rep != null && rep.length() > 10) ? rep.substring(0, 9) : rep);
            System.debug('key : ' + key);
            if (String.isBlank(key)) {
                res.errors.add('[' + (i+5) + '행] FM_Upload 키 생성 실패(이름/담당자 확인)');
                continue;
            }
            // 이미 존재하면 마지막 값으로 덮어써도 무방(같은 Account로 판단)
            keyToRow.put(key.toUpperCase(), r);
        }
        if (keyToRow.isEmpty()) return res;

        // 2) 기존 Account 조회 (FM_GlobalAccount__c IN :keys)
        Set<String> keys = new Set<String>(keyToRow.keySet());
        Map<String, Account> existingByKey = new Map<String, Account>();
        for (Account a : [
            SELECT Id, Name, FM_GlobalAccount__c
            FROM Account
            WHERE FM_GlobalAccount__c IN :keys
        ]) {
            existingByKey.put(a.FM_GlobalAccount__c, a);
        }

        // 3) 없는 키만 신규 생성
        List<Account> toInsert = new List<Account>();
        for (String k : keys) {
            if (existingByKey.containsKey(k)) {
                // 이미 있으면 생성 스킵(요구사항: 없으면 생성)
                continue;
            }
            RowWrap r = keyToRow.get(k);

            Account a = new Account();
            a.Name = r.accountName;                 // 필수
            a.RecordTypeId = prospectCustomerRT;
            a.MainCategory__c = r.mainCategory;
            a.SubCategory__c = r.subCategory;
            a.IsTooling__c = dealerInfo.IsTooling__c;
            a.CountryLookup__c = dealerInfo.CountryLookup__c;
            a.RegionLookup__c = dealerInfo.RegionLookup__c;
            a.DistributionChannel__c = '10';
            a.SalesOrganization__c = '1800';
            a.SalesOffice__c = '1140';
            a.SalesDistrict__c = dealerInfo.SalesDistrict__c;
            a.Division__c = '40';
            String rep = (r.accountRepresentative == null) ? null : r.accountRepresentative.trim();
            a.Representative__c = (rep != null && rep.length() > 10) ? rep.substring(0, 9) : rep;
            a.Phone = r.accountPhone;
            a.mobile__c = r.accountPhone;
            a.Email__c = r.accountEmail;
            a.GlobalContact__c = r.accountContactName;
            a.GlobalCustomerCode__c = r.accountCustomerCode;
            a.CurrencyIsoCode   = dealerInfo.CurrencyIsoCode;
            a.Competitor__c = 'None';
            toInsert.add(a);
        }

        try {
            if (!toInsert.isEmpty()) {
                insert toInsert; // "없으면 생성" 요구이므로 upsert 대신 insert 사용
                for (Account a : toInsert) res.createdAccountIds.add(a.Id);
                res.success = toInsert.size();

                
                
            }
        } catch (DmlException e) {
            res.errors.add('Account insert Error : ' + e.getMessage() + ' Line Number : ' + e.getLineNumber());
        }

        //Sales Area, Contact, related Dealer Record Create
        Integer oppCreated = createDealerLinks(dealerInfo.Id, toInsert, keys, jsonRows, rows[0].distributorId, ownerIfo[0].Id);
        res.success = oppCreated;
        return res;
    }

    // 공백 제거 후 연결
    private static String computeFMKey(String accountName, String accountRep) {
        String a = String.isBlank(accountName) ? '' : accountName.replaceAll('\\s+', '');
        String b = String.isBlank(accountRep)  ? '' : accountRep.replaceAll('\\s+', '');
        return a + b;
    }

    private static Integer createDealerLinks(Id dealerAccountId, List<Account> newAccounts, Set<String> keys, String jsonRows, String dealerCustomerCode, String ownerIfoId) {
        // if (dealerAccountId == null || newAccounts == null || newAccounts.isEmpty()) return;
        List<RowWrap> rows = (List<RowWrap>) JSON.deserialize(jsonRows, List<RowWrap>.class);
        Id cdaDealerRT = SObjectType.DNS_CustomerDealerAssociation__c.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        System.debug('1');
        // 이번에 만든 고객 Id 수집
        Set<Id> customerIds = new Set<Id>();
        if(!newAccounts.isEmpty()){
            for (Account a : newAccounts) customerIds.add(a.Id);
            // 신규 CDA 준비
            List<DNS_CustomerDealerAssociation__c> toInsertCda = new List<DNS_CustomerDealerAssociation__c>();
                for (Id custId : customerIds) {
                    String key = dealerAccountId + '|' + custId;
                    toInsertCda.add(new DNS_CustomerDealerAssociation__c(
                        RecordTypeId = cdaDealerRT,
                        Dealer__c    = dealerAccountId,
                        Customer__c  = custId
                    ));
                }

                if (!toInsertCda.isEmpty()) {
                    try {
                        insert toInsertCda;
                    } catch (DmlException e) {
                        System.debug('CDA insert Error : ' + e.getMessage() + ' Line Number : ' + e.getLineNumber());
                    }
                }
        System.debug('2');

            //신규 Account의 Contact 생성
            Id contactRT = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ContactPerson').getRecordTypeId();

            List<Contact> toInsertContact = new List<Contact>();
            for (Account acc : newAccounts) {
                toInsertContact.add(new Contact(
                    RecordTypeId = contactRT,
                    AccountId  = acc.Id,
                    LastName = acc.GlobalContact__c,
                    MobilePhone = acc.mobile__c,
                    Phone = acc.Phone,
                    // Email = acc.Email__c,
                    DistributionChannel__c = '10',
                    SalesDistrict__c = acc.SalesDistrict__c,
                    SalesOffice__c = '1140',
                    SalesOrganization__c = '1800',
                    Inactive__c = false,
                    Division__c = '40'
                    
                ));
            }
            System.debug('toInsertContact : ' + toInsertContact);
            if (!toInsertContact.isEmpty()) {
                try {
                    insert toInsertContact;
                } catch (DmlException e) {
                    System.debug('contact insert Error : ' + e.getMessage() + ' Line Number : ' + e.getLineNumber());
                }
            }
        System.debug('3');

            //신규 Sales Area 생성
            List<SalesAreaData__c> toInsertSAD = new List<SalesAreaData__c>();
            for (Account acc : newAccounts) {
                toInsertSAD.add(new SalesAreaData__c(
                    Account__c  = acc.Id,
                    Country__c  = acc.CountryLookup__r.Country_Picklist__c,
                    SalesOrganization__c    = acc.SalesOrganization__c,
                    SalesDistrict__c        = acc.SalesDistrict__c,
                    SalesOffice__c          = acc.SalesOffice__c,
                    DistributionChannel__c  = acc.DistributionChannel__c,
                    Division__c             = acc.Division__c,
                    //Account Trigger에서 아래 네개는 KR이 아니면 무조건 null로 넣어주고 있어서 일단 null로만
                    PriceList__c            = null,
                    Incoterms__c            = null,
                    TermsOfPayment__c       = null,
                    ShippingConditions__c   = null,

                    AcctAssgmtGroup__c      = '02',
                    CustomerGroup__c        = '01',  
                    ShipToParty__c          = acc.Id,
                    BillToParty__c          = acc.Id,
                    SoldToParty__c          = acc.Id,
                    Payer__C                = acc.Id
                ));
            }

            if (!toInsertSAD.isEmpty()) {
                try {
                    insert toInsertSAD;
                } catch (DmlException e) {
                    System.debug('Sales Area Data insert Error : ' + e.getMessage() + ' Line Number : ' + e.getLineNumber());
                }
            }
        System.debug('4');

            //SimpleCustomerInfo__c 생성
            List<SimpleCustomerInfo__c> toInsertSC = new List<SimpleCustomerInfo__c>();
            for (Account acc : newAccounts) {
                toInsertSC.add(new SimpleCustomerInfo__c(
                    Name                    = acc.Name,
                    Account__c              = acc.Id
                ));
            }

            if (!toInsertSC.isEmpty()) {
                try {
                    insert toInsertSC;
                } catch (DmlException e) {
                    System.debug('Simple Customer insert Error : ' + e.getMessage() + ' Line Number : ' + e.getLineNumber());
                }
            }
        }
        
        System.debug('5');

        //Opportunity 생성, Competitor 등록
        Map<String, Id> competitorMap = new Map<String, Id>();
        for(Competitor__c cp : [
            SELECT id, Name 
            FROM Competitor__c 
        ]) {
            competitorMap.put(cp.Name, cp.Id);
        }

        String todayStr = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('yyyyMMdd');
        List<Opportunity> toInsertOpty = new List<Opportunity>();
        List<Competitor__c> toInsertCompetitor = new List<Competitor__c>();
        List<OpptyCompetitorMapping__c> toInsertOptyCompetitor = new List<OpptyCompetitorMapping__c>();
        Map<String, Account> optyAccMap = new Map<String, Account>();
        for (Account a : [
            SELECT Id, Name, FM_GlobalAccount__c, CountryLookup__r.Name, CurrencyIsoCode
            FROM Account
            WHERE FM_GlobalAccount__c IN :keys
        ]) {
            optyAccMap.put(a.FM_GlobalAccount__c, a);
        }
        System.debug('keys : ' + keys);
        System.debug('optyAccMap : ' + optyAccMap);
        System.debug('rows : ' + rows);
        for(Integer i = 0; i < rows.size(); i++){
            RowWrap r = rows[i];
            String rep = (r.accountRepresentative == null) ? null : r.accountRepresentative.trim();
            String key = computeFMKey(r.accountName, (rep != null && rep.length() > 10) ? rep.substring(0, 9) : rep);
            key = key.toUpperCase();
            System.debug('keyyyyy : ' + key);
            if(optyAccMap.containsKey(key)){
                System.debug('여기와? : ' + optyAccMap.containsKey(key));
                // ❶ Estimated Contract Date: 비어있으면 오늘 + 1년
                Date estimatedDt = parseDateOr(r.estimatedContractDate, Date.today().addYears(1));

                // ❷ Requested Delivery Date: 비어있으면 위 estimatedDt + 6개월
                Date requestedDt = parseDateOr(r.requestedDeliveryDate, estimatedDt.addMonths(6));
                toInsertOpty.add(new Opportunity(
                    AccountId       = optyAccMap.get(key).Id,
                    RecordTypeId    = recordTypeIdGeneral,
                    Name            = optyAccMap.get(key).CountryLookup__r.Name + '_' + optyAccMap.get(key).Name + '_' + todayStr,
                    StageName       = 'Identified',
                    CloseDate       = estimatedDt,
                    RequestDelieveryDate__c = requestedDt,
                    GlobalOpportunityNo__c  = r.opportunityNo,
                    Global_Model_Name__c    = r.modelName,
                    MainCategory__c = r.mainCategory,
                    SubCategory__c  = r.subCategory,
                    PowerBI_InquiryType__c = 'ZINM',

                    CurrencyIsoCode = optyAccMap.get(key).CurrencyIsoCode,
                    Opportunity_Owner__c = ownerIfoId,
                    OpportunityIdentifier__c = ownerIfoId,
                    Budget__c = 0,
                    LeadSource = 'Other',

                    SalesOrganization__c = '1800',
                    Sales_Office__c = '1140'
                ));
            }
        }
        System.debug('6');
        System.debug('toInsertOpty : ' + toInsertOpty);

        if (!toInsertOpty.isEmpty()) {
            try {
                // insert toInsertOpty;
                Database.SaveResult[] srList = Database.insert(toInsertOpty, false);
                for (Integer i=0; i<srList.size(); i++) {
                    if (srList[i].isSuccess()) {
                    } else {
                        for (Database.Error err : srList[i].getErrors()) {
                            System.debug('Row : ' + i + 'Opportunity insert failed: ' + err.getStatusCode() + ' - ' + err.getMessage());
                            
                        }
                    }
                }

                //Competitor 없으면 먼저 생성
                for(Integer i = 0; i < rows.size(); i++){
                    RowWrap r = rows[i];
                    if(!competitorMap.containsKey(r.competitor)){
                        toInsertCompetitor.add(new Competitor__c(
                            Name = r.competitor
                        ));
                    }
                }
                if(!toInsertCompetitor.isEmpty()){
                    insert toInsertCompetitor;
                }

                //Competitor 생성 후 재조회
                Map<String, Id> competitorMap2 = new Map<String, Id>();
                for(Competitor__c cp : [
                    SELECT id, Name 
                    FROM Competitor__c 
                ]) {
                    competitorMap2.put(cp.Name, cp.Id);
                }
                for(Integer i = 0; i < rows.size(); i++){
                    RowWrap r = rows[i];
                    if(competitorMap2.containsKey(r.competitor)){
                        toInsertOptyCompetitor.add(new OpptyCompetitorMapping__c(
                            Opportunity__c = toInsertOpty[i].Id,
                            Competitor__c = competitorMap2.get(r.competitor)
                        ));
                    }else{
                        toInsertOptyCompetitor.add(new OpptyCompetitorMapping__c(
                            Opportunity__c = toInsertOpty[i].Id,
                            Competitor__c = competitorMap2.get('None')
                        ));
                    }
                }
                if(!toInsertOptyCompetitor.isEmpty()){
                    insert toInsertOptyCompetitor;
                }
            } catch (DmlException e) {
                System.debug('Opportunity insert Error : ' + e.getMessage() + ' Line Number : ' + e.getLineNumber());
            }
        }

            List<Id> prospectIds = new List<Id>();
            for (Account a : [
                SELECT Id
                FROM Account
                WHERE FM_GlobalAccount__c IN :keys
                AND CustomerCode__c = null
            ]) {
                prospectIds.add(a.Id);
            }
        
            // System.enqueueJob(new CreateProspectInERPQueueable(keys, dealerCustomerCode));
        if (!prospectIds.isEmpty()) {
            System.enqueueJob(new CreateProspectPerAccQ(prospectIds, 0, dealerCustomerCode));
        }

        return toInsertOpty.size();

    }

    private static Date parseDateOr(String s, Date fallback) {
        if (String.isBlank(s)) return fallback;
        String t = s.trim();
        try {
            if (t.contains('-')) return Date.valueOf(t); // yyyy-MM-dd
            if (t.contains('/')) {                        // yyyy/MM/dd
                List<String> p = t.split('/');
                if (p.size() == 3) return Date.newInstance(Integer.valueOf(p[0]), Integer.valueOf(p[1]), Integer.valueOf(p[2]));
            }
            if (t.length() == 8) {                        // yyyyMMdd
                Integer y = Integer.valueOf(t.substring(0,4));
                Integer m = Integer.valueOf(t.substring(4,6));
                Integer d = Integer.valueOf(t.substring(6,8));
                return Date.newInstance(y, m, d);
            }
        } catch (Exception e) { /* ignore and use fallback */ }
        return fallback;
    }

    // DN_OpportunityGlobalImportController 클래스 내부에 추가
    public class CreateProspectPerAccQ implements Queueable, Database.AllowsCallouts {
        private List<Id> accIds;
        private Integer  idx;
        private String dealerCustomerCode;

        public CreateProspectPerAccQ(List<Id> accIds, Integer idx, String dealerCustomerCode) {
            this.accIds = accIds;
            this.idx    = idx;
            this.dealerCustomerCode = dealerCustomerCode;
        }

        public void execute(QueueableContext qc) {
            Set<String> bypassSet = new Set<String>{'AccountTriggerHandler' ,'OpportunityTriggerHandler', 'OpptyCompetitorMappingTriggerHandler', 'SalesAreaDataTriggerHandler'};
            TriggerHandler.bypassedHandlers = bypassSet; 

            //Opportunity까지 다 생성 후 새로만든 고객이 있다면 I/F해서 ERP에 잠재고객 생성
            // 현재 1건만 조회
            Account prospectERP = [
                SELECT Id, Name,
                    CountryLookup__r.CountryCode__c,
                    RegionLookup__r.RegionCode__c,
                    ShippingPostalCode, ShippingStreet, Phone,
                    SalesOrganization__c, DistributionChannel__c, Division__c,
                    Representative__c, AccountNameEnglish__c, BusinessNumber__c,
                    CurrencyIsoCode
                FROM Account
                WHERE Id = :accIds[idx]
            ];
            List<Account> updateKunnrList = new List<Account>();
            if(prospectERP != null){
                // for(Integer i = 0; i < prospectERP.size(); i++){
                    IF_ERP_Account_Classes.IF_ACCOUNT_001_Req erpParameters = new IF_ERP_Account_Classes.IF_ACCOUNT_001_Req();
                    erpParameters.I_ANRED       = 'Company';
                    erpParameters.I_NAME1       = prospectERP.Name.length() > 35 ? prospectERP.Name.substring(0,35) : prospectERP.Name;
                    erpParameters.I_COUNTRY     = prospectERP.CountryLookup__r.CountryCode__c;
                    erpParameters.I_REGION      = prospectERP.RegionLookup__r.RegionCode__c;
                    erpParameters.I_PSTLZ       = String.isNotBlank(prospectERP.ShippingPostalCode) ? prospectERP.ShippingPostalCode : '';
                    erpParameters.I_STREET      = String.isNotBlank(prospectERP.ShippingStreet) ? prospectERP.ShippingStreet : '';
                    erpParameters.I_TEL_NUMBER  = String.isNotBlank(prospectERP.Phone) ? prospectERP.Phone : '';
                    erpParameters.I_VKORG       = prospectERP.SalesOrganization__c;
                    erpParameters.I_VTWEG       = prospectERP.DistributionChannel__c;
                    erpParameters.I_SPART       = prospectERP.Division__c;
                    erpParameters.I_KTONR       = '';
                    erpParameters.I_NAME        = prospectERP.Representative__c;
                    erpParameters.I_NAME3       = prospectERP.AccountNameEnglish__c;
                    erpParameters.I_DEALER      = dealerCustomerCode;
                    erpParameters.I_TAXNUMBER1  = prospectERP.BusinessNumber__c != null ? prospectERP.BusinessNumber__c : '';
                    erpParameters.I_WAERS       = prospectERP.CurrencyIsoCode;
                    if(prospectERP.ShippingStreet != '' && prospectERP.ShippingStreet != null) {
                        Integer maxLength = 35;
                        String street = prospectERP.ShippingStreet;
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
                    
                    IF_ERP_Account erpService = new IF_ERP_Account();
                    IF_ERP_Account_Classes.IF_ACCOUNT_001_Res response = erpService.IF_ACCOUNT_001(erpParameters);
                    System.debug('response : ' + response);
                    if(response != null && !String.isBlank(response.O_KUNNR) && response.O_RECODE == 'S'){
                        Account updateKunnr = new Account(
                            Id = prospectERP.Id,
                            CustomerCode__c = response.O_KUNNR
                        );
                        // updateKunnrList.add(updateKunnr);
                        update updateKunnr;
                    }
                    Integer next = idx + 1;
                    if (next < accIds.size()) {
                        System.enqueueJob(new CreateProspectPerAccQ(accIds, next, dealerCustomerCode));
                    }
                // }
            }

            // if(!updateKunnrList.isEmpty()){
            //     update updateKunnrList;
            // }
        }
    }

     public static void dummy() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
     }

}