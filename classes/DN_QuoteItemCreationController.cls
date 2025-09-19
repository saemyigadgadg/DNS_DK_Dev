/**
 * @description       : Quote에서 Quotelineitem 생성 버튼 Controller
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-11-20   yeongju.yun   Initial Version
 * 1.1   2025-05-07   yeongju.yun   EDIT01. RegionForProductSub__c, Proto 조건 추가
 * 1.2   2025-05-21   yeongju.yun   EDIT02. Admin은 전체 조회 되도록 예외 처리리
**/
public with sharing class DN_QuoteItemCreationController {
    private static final Id   recordTypeIdCommo = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
    private static final Id   recordTypeIdFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();
    public static DN_OrderService ordSvc = new DN_OrderService();

    /**
    * @description 견적 제품 추가 가능 여부 판단
    **/
    @AuraEnabled
    public static string getStatus(String recordId){
        try {
            List<QuoteLineItem> quoteStatus = [SELECT Id FROM QuoteLineItem WHERE QuoteId =: recordId and F_IsOrderCreated__c = true];
            List<Quote> isFinal = [SELECT IsFinal__c FROM Quote WHERE Id =: recordId];
            
            if(quoteStatus.size() > 0) { // 이미 주문이 생성된 건이면 ERROR
                return System.Label.DNS_M_CantQuoteCopyOrder;
            } else if(isFinal.size() > 0){
                if(isFinal[0].IsFinal__c == true){
                    return System.Label.DNS_M_QuoteFinal;//Since the final quotation has been confirmed, adding products, confirming quotations, and requesting reviews are not allowed.
                }else{
                    return 'SUCCESS';
                }
            } else {
                return 'SUCCESS';
            }
        } catch (Exception e) {
            System.debug('QuoteCopy : ' + e.getLineNumber() + ' : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 조건 (param)에 따라 제품 정보 조회
    **/
    @AuraEnabled
    public static Map<String, Object> findProducts(String recordId, String objName, String searchKey, Integer recordLimit){
        Map<String, Object> result = new Map<String, Object>();
        try {

            String userType = getUserType(recordId); // Domestic, DomesticCRM, Global, GlobalCRM, DNSA, Admin

            Id priceBook;
            String curr;
            if(objName == 'Quote') {
                Quote q = [SELECT Id, Pricebook2Id, Pricebook2.Name, CurrencyIsoCode FROM Quote WHERE Id =: recordId];
                curr = q.CurrencyIsoCode;
                if(q.Pricebook2Id != null) { 
                    priceBook = q.Pricebook2Id;
                } else {
                    Pricebook2 book = [SELECT Id, Name FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
                    priceBook = book.Id;
                }
            } else {
                Opportunity opty = [SELECT Id, Pricebook2Id, Pricebook2.Name, CurrencyIsoCode FROM Opportunity WHERE Id =: recordId];
                curr = opty.CurrencyIsoCode;
                if(opty.Pricebook2Id != null) { 
                    priceBook = opty.Pricebook2Id;
                } else {
                    Pricebook2 book = [SELECT Id, Name FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
                    priceBook = book.Id;
                }
            }

            String prodTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('BaseCode').getRecordTypeId();

            String queryStr = ' SELECT Id, Name, Pricebook2Id '
                            + ' , Product2.Model__r.Name, Product2.Name, Product2.Name__c, Product2.NCSystem__c, Product2.Motor__c '
                            + ' , Product2.Spindle__c, Product2.ToolStorageCapacity__c, Product2.MonitorSize__c, Product2.F_RegionText__c '
                            + ' , Product2.ETC__c, Product2.IsStrategicMaterial__c, Product2.Region__c, Product2Id '
                            + ' FROM PricebookEntry '

                            + ' WHERE IsActive = TRUE '
                            + ' AND Product2.IsActive = TRUE '
                            + ' AND CurrencyIsoCode = \'' + curr + '\' '
                            + ' AND Pricebook2Id = \'' + priceBook + '\' '
                            + ' AND Product2.RecordTypeId = \'' + prodTypeId + '\' ';

            if(String.isNotBlank(searchKey)) {
                String val = '\'%' + String.escapeSingleQuotes(searchKey.trim()) + '%\'';

                queryStr += ' AND ( '
                         + ' ProductCode LIKE ' + val
                         + ' OR  Product2.Model__r.Name LIKE ' + val
                         + ' OR  Product2.Name__c LIKE ' + val
                         + ' OR  Product2.NCSystem__c LIKE ' + val
                         + ' OR  Product2.Motor__c LIKE ' + val
                         + ' OR  Product2.Spindle__c LIKE ' + val
                         + ' OR  Product2.ToolStorageCapacity__c LIKE ' + val
                         + ' OR  Product2.MonitorSize__c LIKE ' + val
                         + ' OR  Product2.F_RegionText__c LIKE ' + val
                         + ' OR  Product2.ETC__c LIKE ' + val
                         + ' ) ';
            }
            
            String protoStr = '\'%P__\'';
            if(userType.contains('Global')) {
                User globalDealer = [SELECT Id, Account.RegionForProduct__c, Account.RegionForProductSub__c FROM User WHERE Id =: UserInfo.getUserId()];
                String region     = globalDealer.Account.RegionForProduct__c;
                String regionSub  = globalDealer.Account.RegionForProductSub__c;
                
                String regionStr     = '\'%' + region + '__\'';
                String regionSubStr  = '\'%' + regionSub + '__\'';

                queryStr += ' AND Product2.IsGlobal__c = TRUE ';
                if(!userType.contains('CRM')) {

                    queryStr += ' AND ( ProductCode LIKE ' + protoStr;

                    if(region != null) {
                        queryStr += ' OR ProductCode LIKE ' + regionStr;
                    }

                    if(regionSub != null) {
                        queryStr += ' OR ProductCode LIKE ' + regionSubStr;
                    }

                    queryStr += ' ) ';
                }

            } else if(userType.contains('Domestic')) {
                queryStr += ' AND Product2.IsKorea__c = TRUE ';
            } else if(userType == 'DNSA') {
                String amerikaStr = '\'%U__\'';
                queryStr += ' AND ( ProductCode LIKE ' + protoStr + ' OR ProductCode LIKE ' + amerikaStr + ' OR Product2.Region__c = NULL ) ';
            }

            queryStr += ' ORDER BY ProductCode, Product2.NCSystem__c ';

            if(recordLimit != null && recordLimit != 0) {
                queryStr += ' LIMIT ' + recordLimit;
            }

            List<PricebookEntry> entryList = (List<PricebookEntry>) Database.query(queryStr);

            String baseUrl = ordSvc.getBaseUrl(!ordSvc.IS_USER);

            List<ProductWrapper> prods = new List<ProductWrapper>();
            for(PricebookEntry entry : entryList) {
                ProductWrapper prodWrap = new ProductWrapper(entry, baseUrl);
                prods.add(prodWrap);
            }
            result.put('prods', prods);

            return result;

        } catch (Exception e) {
            System.debug('findProducts : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 기회 제품, 견적 제품 wrapper
    **/
    public class ProductWrapper{
        @AuraEnabled public String entryId      {get;set;} // PricebookEntry.Id
        @AuraEnabled public String entryName    {get;set;} // PricebookEntry.Name
        @AuraEnabled public String pricebook2Id {get;set;} // PricebookEntry.pricebook2Id

        @AuraEnabled public String prodId   {get;set;} // PricebookEntry.Product2.Id
        @AuraEnabled public String prodCode {get;set;} // PricebookEntry.ProductCode
        @AuraEnabled public String prodUrl  {get;set;}

        @AuraEnabled public Integer quantity        {get;set;} 
        @AuraEnabled public String  model           {get;set;} // PricebookEntry.Product2.Model__r.Name
        @AuraEnabled public String  prodDescription {get;set;} // PricebookEntry.Product2.Name__c
        @AuraEnabled public String  ncSystem        {get;set;} // PricebookEntry.Product2.NCSystem__c
        @AuraEnabled public String  motor           {get;set;} // PricebookEntry.Product2.Motor__c
        @AuraEnabled public String  spindle         {get;set;} // PricebookEntry.Product2.Spindle__c
        @AuraEnabled public String  tool            {get;set;} // PricebookEntry.Product2.ToolStorageCapacity__c
        @AuraEnabled public String  monitorSize     {get;set;} // PricebookEntry.Product2.MonitorSize__c
        @AuraEnabled public String  region          {get;set;} // PricebookEntry.Product2.F_RegionText__c
        @AuraEnabled public String  etc             {get;set;} // PricebookEntry.Product2.ETC__c
        @AuraEnabled public Boolean prodStrategic   {get;set;} // PricebookEntry.Product2.IsStrategicMaterial__c

        public ProductWrapper(){}
        public ProductWrapper(PricebookEntry entry, String baseUrl){
            this.entryId      = entry.Id;
            this.entryName    = entry.Name;
            this.pricebook2Id = entry.Pricebook2Id;

            this.prodId   = entry.Product2Id;
            this.prodCode = entry.Product2.Name;
            this.prodUrl  = baseUrl + '/' + entry.Product2Id;
            
            this.quantity        = 1;
            this.model           = entry.Product2.Model__r.Name;
            this.prodDescription = entry.Product2.Name__c;
            this.ncSystem        = entry.Product2.NCSystem__c;
            this.motor           = entry.Product2.Motor__c;
            this.spindle         = entry.Product2.Spindle__c;
            this.tool            = entry.Product2.ToolStorageCapacity__c;
            this.monitorSize     = entry.Product2.MonitorSize__c;
            this.region          = entry.Product2.F_RegionText__c;
            this.etc             = entry.Product2.ETC__c;
            this.prodStrategic   = entry.Product2.IsStrategicMaterial__c;
        }
    }

    /**
    * @description 결과 반환 Wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isPass   {get;set;}
        @AuraEnabled public String  errorMsg {get;set;}

        @AuraEnabled public Map<String, Object> data {get;set;}

        public ResultWrapper(){
            this.isPass   = true;
            this.errorMsg = '';
            this.data = new Map<String, Object>();
        }
    }

    /**
    * @description 견적 레코드 타입별 아이템 개수 반환
    **/
    @AuraEnabled
    public static Map<String, Object> getRecordType(String recordId){
        try {
            List<Quote> recordType = [SELECT RecordType.Name FROM Quote WHERE Id =: recordId];
            List<QuoteLineItem> count = [SELECT Id FROM QuoteLineItem WHERE QuoteId =: recordId];
            Map<String, Object> result = new Map<String, Object>();
            if(recordType.size() > 0){
                result.put('Type', recordType[0].RecordType.Name);
                result.put('Count', count.size());
            }
            return  result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 견적 제품 추가, Warranty 설정, 견적 제품을 기회 제품으로 등록
    **/
    @AuraEnabled
    public static void addQuoteProducts(String recordId, List<ProductWrapper> prods){
        try {
            Quote q = [
                SELECT  Id
                        , Opportunity.Opportunity_Owner__c
                        , Opportunity.AccountId
                        , Opportunity.Inquiry_Type__c
                        , ExpectedDelivDate__c
                        , Opportunity.RequestDelieveryDate__c
                        , OpportunityId 
                        , Pricebook2Id
                        , RecordTypeId
                        , RecordType.Name
                        , MachinePartsWarranty__c
                        , Opportunity.RecordTypeId
                        , Account.CountryLookup__r.Name
                        , Account.CountryLookup__r.CountryCode__c
                        , RequestedShipDate__c
                FROM    Quote 
                WHERE   Id =: recordId
            ];

            if(q.Pricebook2Id == null) {
                Pricebook2 book = [SELECT Id, Name FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];

                Opportunity opty = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id =: q.OpportunityId];
                if(opty.Pricebook2Id == null) {
                    opty.Pricebook2Id = book.Id;
                    update opty;
                }

                q.Pricebook2Id = book.Id;
                update q;
            }
            
            List<QuoteLineItem> itmeList = new List<QuoteLineItem>();
            List<OpportunityLineItem> optyitemList = new List<OpportunityLineItem>();
            
            for(ProductWrapper prod : prods) {
                for(Integer i = 0; i < prod.quantity; i++) {
                    
                    OpportunityLineItem optyitem = new OpportunityLineItem();
                    optyitem.Product2Id           = prod.prodId;
                    optyitem.OpportunityId        = q.OpportunityId;
                    optyitem.PricebookEntryId     = prod.entryId;
                    optyitem.Quantity             = 1;
                    optyitem.UnitPrice            = 0;
                    optyitemList.add(optyitem);
                }
            }
            List<Warranty__c> globalWar = [SELECT Id, KSCHL__c, VKORG__c, SPART__c, VTWEG__c, ZZPR_WAR__c, Percent__c, DATBI__c, DATAB__c, ZZWARRPER__c, ZZPERUNIT__c, ZZWARHRS__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c FROM Warranty__c WHERE VTWEG__c = '20'];
            Map<String, Warranty__c> globalWarMap = new Map<String, Warranty__c>();
            for(Warranty__c glo : globalWar){
                globalWarMap.put(glo.ZZPR_WAR__c, glo);
            }

            if(!optyitemList.isEmpty()) { 
                insert optyitemList; 

                for(Integer i = 0; i < optyitemList.size(); i++) {
                    
                    QuoteLineItem item         = new QuoteLineItem();
                    item.QuoteId               = recordId;
                    item.PricebookEntryId      = optyitemList[i].PricebookEntryId;
                    item.Product2Id            = optyitemList[i].Product2Id;
                    item.Quantity              = 1;
                    item.UnitPrice             = 0;
                    item.OpportunityLineItemId   = optyitemList[i].Id;
                    item.RequestedDelivDate__c = q.Opportunity.RequestDelieveryDate__c;
                    item.ExpectedDelivDate__c  = q.ExpectedDelivDate__c;

                    item.Quote_RecordType__c = q.RecordType.Name;
                    if(q.RecordTypeId == recordTypeIdCommo || q.RecordTypeId == recordTypeIdFactory){
                        item.Warranty__c = q.MachinePartsWarranty__c != null ? q.MachinePartsWarranty__c : 'M12';
                    }else if(q.Account.CountryLookup__r.CountryCode__c == 'KR'){//국가가 한국이면 Warranty 12개월 Default
                        item.Warranty__c = 'B1D';
                    }
                    else if(q.Account.CountryLookup__r.CountryCode__c == 'GB' || q.Account.CountryLookup__r.CountryCode__c == 'IT'){//영국, 이탈리아는 24개월
                        item.Warranty__c = 'B24';
                        item.Warranty_Percent__c = globalWarMap.get('B24').Percent__c;
                    }else{ //나머지는 12개월
                        item.Warranty__c = 'B12';
                        item.Warranty_Percent__c = globalWarMap.get('B12').Percent__c;
                    }
                    if(q.RequestedShipDate__c != null){
                        item.Requested_Ship_Date__c = q.RequestedShipDate__c;
                    }

                    itmeList.add(item);
                }
                if(q.RecordTypeId != recordTypeIdCommo && q.RecordTypeId != recordTypeIdFactory){
                    DN_OpportunityCallout.createInquiry(q.Opportunity.Opportunity_Owner__c, q.Opportunity.AccountId, q.OpportunityId, q.Opportunity.Inquiry_Type__c);
                }
            }
                
            if(!itmeList.isEmpty()) { 
                insert itmeList; 
                
                if(q.RecordTypeId == recordTypeIdFactory){
                    List<SQRegistration__c> sqList = [SELECT Id FROM SQRegistration__c WHERE Quote__c =:recordId];

                    if(!sqList.isEmpty()){
                        QuoteLineItem qlItem = [SELECT Id, Product2Id, Product2.Model__r.Name, CurrencyIsoCode FROM QuoteLineItem WHERE Id =: itmeList[0].Id];
                        SQRegistration__c sqInfo = [SELECT Id FROM SQRegistration__c WHERE Quote__c =:recordId];
                        SQRegistration__c sqUpdate = new SQRegistration__c();
                        sqUpdate.Id = sqInfo.Id;
                        sqUpdate.Model__c = qlItem.Product2.Model__r.Name;
                        sqUpdate.BaseCode__c =  qlItem.Product2Id;
                        sqUpdate.CurrencyIsoCode = qlItem.CurrencyIsoCode;
                        update sqUPdate;

                        SQ_Registration_Junction__c newsqregJun = new SQ_Registration_Junction__c();
                        newsqregJun.SQRegistration__c = sqInfo.Id;
                        newsqregJun.QuoteLineItem__c = itmeList[0].Id;
                        insert newsqregJun;
                    }
                    
                }
            }

        } catch (Exception e) {
            System.debug('addQuoteProducts : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 기회에 제품 추가, Pricebook이 없다면 업데이트
    **/
    @AuraEnabled
    public static void addOptyProduct(String recordId, List<ProductWrapper> prods){
        
        try {

            Opportunity opty = [
                SELECT  Id, Opportunity_Owner__c, AccountId, Inquiry_Type__c, Pricebook2Id, RecordType.Name
                FROM    Opportunity
                WHERE   Id =: recordId
            ];

            if(opty.Pricebook2Id == null) {
                Pricebook2 book = [SELECT Id, Name FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
                opty.Pricebook2Id = book.Id;
                update opty;
            }

            List<OpportunityLineItem> optyitemList = new List<OpportunityLineItem>();
            for(ProductWrapper prod : prods) {
                for(Integer i = 0; i < prod.quantity; i++) {
                    
                    OpportunityLineItem optyitem = new OpportunityLineItem();
                    optyitem.Product2Id           = prod.prodId;
                    optyitem.OpportunityId        = recordId;
                    optyitem.PricebookEntryId     = prod.entryId;
                    optyitem.Quantity             = 1;
                    optyitem.UnitPrice            = 0;
                    optyitemList.add(optyitem);
                }
            }
            if(!optyitemList.isEmpty() && opty.RecordType.Name != 'DNSA' && !System.Test.isRunningTest()) { 
                insert optyitemList; 
                DN_OpportunityCallout.createInquiry(opty.Opportunity_Owner__c, opty.AccountId, opty.Id, opty.Inquiry_Type__c);
            }
            
        } catch (Exception e) {
            System.debug('addOptyProduct : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 사용자 타입 반환 (국내,글로벌,DNSA,어드민)
    **/
    @AuraEnabled
    public static String getUserType(String recordId){
        
        try {
            String type = 'Domestic'; // Domestic, DomesticCRM, Global, GlobalCRM, DNSA, Admin
            Boolean isDNSA = false;

            // EDIT02. Admin은 전체 조회 되도록 예외 처리리
            User currUser = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            Boolean isAdmin = ordSvc.ADMINS.contains(currUser.Profile.Name);

            Id targetId = Id.valueOf(recordId);
            String sObjName = targetId.getSObjectType().getDescribe().getName();

            if(sObjName == 'Opportunity') {
                Id recordType_DNSA = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();
                Opportunity opty = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id =: recordId];
                isDNSA = opty.RecordTypeId == recordType_DNSA;

            } else if(sObjName == 'Quote') {
                Quote q = [SELECT Id, RecordType.DeveloperName FROM Quote WHERE Id =: recordId];
                isDNSA = q.RecordType.DeveloperName.startsWith('DNSA');
            }

            if(isDNSA) {
                type = 'DNSA';
            } else  if(isAdmin) {
                type = 'Admin';
            } else {

                List<Profile> globalProfiles = [SELECT Id FROM Profile WHERE Name LIKE '%글로벌%'];
                Map<Id, Profile> profileMap = new Map<Id, Profile>(globalProfiles);
                Set<Id> globalProfileIds = profileMap.keySet();

                Boolean isGlobal = globalProfileIds.contains(UserInfo.getProfileId());
                type = isGlobal ? 'Global' : 'Domestic';

                if(ordSvc.getUserFlag(UserInfo.getUserType())) type += 'CRM';
            }

            return type;
            
        } catch (Exception e) {
            System.debug('getUserType : ' + e.getLineNumber() + ' : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 견적이 이미 생성 되어있으면 기회에서 제품 생성 불가
    **/
    @AuraEnabled
    public static ResultWrapper validateProducts(String recordId){
        ResultWrapper result = new ResultWrapper();
        try {
            Id targetId = Id.valueOf(recordId);
            String sObjName = targetId.getSObjectType().getDescribe().getName();

            if(sObjName == 'Opportunity') {
                List<Quote> quoteList = [
                    SELECT  Id
                    FROM    Quote 
                    WHERE   OpportunityId =: recordId
                ];

                if(!quoteList.isEmpty()) {
                    result.isPass   = false;
                    result.errorMsg = System.Label.DNS_M_AddProductQuote; // Please add a product to the quote.
                }
            } 

            return result;
        } catch (Exception e) {
            System.debug('validateProducts : ' + e.getLineNumber() + ' : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

}