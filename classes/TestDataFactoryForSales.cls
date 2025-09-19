/**
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-23
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-01-21   yeongju.yun   Initial Version
**/
@isTest
public with sharing class TestDataFactoryForSales {

    //Warranty
    public static List<Warranty__c> getWarranty(){
        List<Warranty__c> warrantyrecords = new List<Warranty__c>{
            new Warranty__c(KSCHL__c = 'ZWAR', VKORG__c = '1800', SPART__c = '40', VTWEG__c = '10', ZZPR_WAR__c = 'E24', Percent__c = 1.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZWAR', VKORG__c = '1800', SPART__c = '40', VTWEG__c = '10', ZZPR_WAR__c = 'E2D', Percent__c = 3.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '30', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZWAR', VKORG__c = '1800', SPART__c = '40', VTWEG__c = '10', ZZPR_WAR__c = 'E3D', Percent__c = 7.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZWAR', VKORG__c = '1800', SPART__c = '40', VTWEG__c = '20', ZZPR_WAR__c = 'E24', Percent__c = 3.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZWAR', VKORG__c = '1800', SPART__c = '40', VTWEG__c = '20', ZZPR_WAR__c = 'E36', Percent__c = 7.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZWAR', VKORG__c = '1800', SPART__c = '40', VTWEG__c = '20', ZZPR_WAR__c = 'B12', Percent__c = 0, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZWAR', VKORG__c = '1800', SPART__c = '40', VTWEG__c = '20', ZZPR_WAR__c = 'E48', Percent__c = 0, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZWAR', VKORG__c = '1800', SPART__c = '40', VTWEG__c = '20', ZZPR_WAR__c = 'E24', Percent__c = 0, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZWAR', VKORG__c = '1800', SPART__c = '40', VTWEG__c = '10', ZZPR_WAR__c = 'B1D', Percent__c = 0, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'M12', Percent__c = 0.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'M18', Percent__c = 1.75, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'M24', Percent__c = 2.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'M30', Percent__c = 6, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = ''),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'M36', Percent__c = 7.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3UL'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'X36', Percent__c = 3, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3UL'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'X42', Percent__c = 5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3UL'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'X48', Percent__c = 7, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3UL'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'X60', Percent__c = 3, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3UL'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'M12', Percent__c = 5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3UL'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'M18', Percent__c = 7, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3UL'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'M24', Percent__c = 12, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3UL'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'M30', Percent__c = 0.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3UL'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'M36', Percent__c = 1.75, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3US'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'X36', Percent__c = 2.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3US'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'X42', Percent__c = 6, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3US'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'X48', Percent__c = 1.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3US'),
            new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'X60', Percent__c = 1.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3US')
        };
        return warrantyrecords;
    }

    /*  user info  */
    public static Profile getProfile(String profileName){

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = : profileName];
        return profile;
    }
    public static UserRole getUserRole(String roleName) {

        UserRole role = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName =: roleName];
        return role;
    }

    /**
    * @description 필요에 따라 ManagerId, UserRoleId, internal_approver__c, ProfileId, ContactId 설정하여 사용
    **/
    public static User setDomesticUser(){

        User u                   = new User();
        u.Username               = 'test001@gmail.com' + System.currentTimeMillis();
        u.LastName               = 'testuser';
        u.CompanyName            = 'DN Solutions';
        u.Department             = '한국영업본부 영업지원Part';
        u.Title                  = '책임매니저';
        u.Email                  = 'test001@gmail.com';
        u.Alias                  = 'testuser';
        u.IsActive               = true;
        u.TimeZoneSidKey         = 'Asia/Seoul';
        u.LocaleSidKey           = 'ko';
        u.LanguageLocaleKey      = 'ko';
        u.EmailEncodingKey       = 'UTF-8';

        u.SalesDistrict__c       = 'A1KR';
        u.SalesOffice__c         = '114E';
        u.DistributionChannel__c = '10';
        u.Division__c            = '40';
        u.SalesOrganization__c   = '1800';

        return u;
    }

    /**
    * @description DNS User 생성
    **/
    public static User createDNSUser(String profileName, String roleName){
        Profile profile = getProfile(profileName);
        UserRole role   = getUserRole(roleName);

        User user       = setDomesticUser();
        user.ProfileId  = profile.Id;
        user.UserRoleId = role.Id;

        return user;
    }

    /**
    * @description 국내 대리점 딜러 생성
    **/
    public static User createDomesticDealer(Boolean isManager, Account dealerAcc, Contact delaerCon){
        Profile profile = getProfile('영업 국내 대리점');

        String portalRole = isManager ? 'Manager' : 'Worker';
        UserRole role = [
            SELECT  Id 
            FROM    UserRole 
            WHERE   DeveloperName LIKE 'Partner%' 
            AND     PortalType = 'Partner' 
            AND     PortalRole =: portalRole
            LIMIT 1
        ];
        SYstem.debug('createDomesticDealer - role ::: ' + role);

        User user       = setDomesticUser();
        user.LastName   = 'dealer';
        user.ProfileId  = profile.Id;
        // user.UserRoleId = role.Id;
        user.ContactId  = delaerCon.Id;
        return user;
    }



    /*  *record type info  */
    public static RecordType getRecordType(String devName, String sObjName) {
        RecordType type = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType =: sObjName AND DeveloperName =:devName];
        return type;
    }

    public static Map<String, RecordType> getRecordType(String sObjName) {
        List<RecordType> types = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType =: sObjName];
        
        Map<String, RecordType> typeMap = new Map<String, RecordType>();
        for(RecordType type : types) {
            typeMap.put(type.DeveloperName, type);
        }
        return typeMap;
    }


    /*  *Pricebook2 info  */
    public static void activatePriceBook(){
        Pricebook2 pBook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update pBook;
    }

    public static PricebookEntry createPriceBookEntry(Product2 prod, String curr) {
        Id pBookId = Test.getStandardPricebookId();

        PricebookEntry entry  = new PricebookEntry();
        entry.Pricebook2Id    = pBookId;
        entry.Product2Id      = prod.Id;
        entry.CurrencyIsoCode = curr;
        entry.UnitPrice       = 0;
        entry.IsActive        = true;

        return entry;
    }

    

    /*  *product2 info  */
    public static Model__c createModel() {
        Model__c model             = new Model__c();
        model.Name                 = 'DNM 4500';
        model.Name__c              = 'DNM 4500';
        model.NameEN__c            = 'DNM 4500';
        model.Code__c              = 'MV0176';
        model.MaterialCode__c      = 'MV0176';
        model.MaterialGroupCode__c = '610225';
        model.MaterialGroupName__c = 'VERTICAL MACHINING C';
        model.Unit__c              = 'EA';
        model.Weight__c            = 5000;
        model.WeightUnit__c        = 'KG';
        return model;
    }
    
    /**
    * @description 제품 생성
    **/
    public static product2 createProduct() {
        RecordType type = getRecordType('BaseCode', 'Product2');

        Model__c model = createModel();
        insert model;

        product2 prod               = new product2();
        prod.Name                   = 'DNM4504-F0MP-1-K30';
        prod.ProductCode            = 'DNM4504-F0MP-1-K30';
        prod.IsActive               = true;
        prod.CurrencyIsoCode        = 'KRW';
        prod.RecordTypeId           = type.Id;
        prod.Unit__c                = 'EA';
        prod.Name__c                = 'DNM4504/F0IMP_AT8_12K;KOREA';
        prod.Model__c               = model.Id;
        prod.MaterialGroupCode__c   = '610225';
        prod.MaterialGroupName__c   = 'VERTICAL MACHINING C';
        prod.Region__c              = 'K';
        prod.MaxSpindleSpeed__c     = '12000 R/MIN';
        prod.ToolStorageCapacity__c = '30 EA';
        prod.MonitorSize__c         = '15 inch';
        prod.NCSystem__c            = 'DN SOLUTIONS-FANUC I SERIES_MC';
        return prod;
    }





    /*  *lead info  */
    public static Lead createLead(String leadType, Country__c country) {
        RecordType type = getRecordType(leadType, 'Lead');

        Date today = Date.today();
        Datetime currentDateTime = Datetime.now();

        Lead lead                             = new Lead();       
        lead.LeadSource__c                    = 'On-site Visitor'; 
        lead.FileName__c                      = 'Test File';
        lead.LastName                         = 'last';
        lead.Company                          = 'testCompany';
        lead.Address1__c                      = '서울';

        lead.MobilePhone                      = '010-123-4567';
        lead.Email                            = 'test@email.com';
        lead.IsDNSolutionsAvailable__c        = true;
        lead.IsMarketingConsentPhone__c       = true;
        lead.IsMarketingConsentSMS__c         = true;
        
        lead.IsMarketingConsentEmail__c       = true;
        lead.IsMarketingConsentPost__c        = true;
        lead.MarketingConsentDate__c          = today;
        lead.LeadSourceCatalog__c             = 'test';
        lead.DownloadDate__c                  = today;

        lead.EventName__c                 = 'test';
        lead.VisitTime__c                 = currentDateTime;
        lead.Title                        = 'test';
        lead.Phone                        = '010-123-456';
        lead.Industry_EventVisitor__c     = 'IT';
        
        lead.InterestedItem__c            = 'test';
        lead.Country__c                   = 'KR';
        lead.PostalCode                   = '00000';
        lead.Address2__c                  = 'test';
        lead.Rating                       = 'Hot';

        lead.RequestQuote__c              = true;
        lead.RequestQuoteDate__c          = today;
        lead.Description                  = 'Desc';
        lead.ExcludeLead__c               = true;

        return lead;
    }





    /*  *account info  */
    public static Account createAccount(String accType, Country__c country, Account parentAcc) {
        RecordType type = getRecordType(accType, 'Account');

        Account acc           = new Account();
        acc.Name              = 'test company';
        acc.RecordTypeId      = type.Id;
        acc.Phone             = '00000000000';
        acc.BusinessNumber__c = '5148171774';
        acc.Representative__c = 'testuser';
        acc.CustomerCode__c   = '0000000';
        acc.TypeOfBusiness__c = 'Manufacturing';
        acc.TypeOfIndustry__c = 'Wholesale and Commodity Brokerage';
        acc.IsKeyAccount__c   = true;
        acc.ParentId          = parentAcc == null ? null : parentAcc.Id;

        acc.CurrencyIsoCode  = 'KRW';
        acc.Country__c       = 'KR';
        acc.CountryLookup__c = country.Id;
        
        acc.DistributionChannel__c = '10';
        acc.Division__c            = '40';
        acc.SalesOffice__c         = '114E';
        acc.SalesDistrict__c       = 'A1KR';
        acc.SalesOrganization__c   = '1800';

        acc.ShippingCity = '대구광역시 달서구 성서공단로';
        acc.ShippingPostalCode = '42722';

        return acc;
    }

    /**
    * @description 상위 Account 생성
    **/
    public static Account createParentAccount(Country__c country) {
        RecordType type = getRecordType('ProspectCustomer', 'Account');

        Account acc                 = new Account();
        acc.Name                    = '(Virtual) test company';
        acc.RecordTypeId            = type.Id;
        acc.Representative__c       = 'testuser';
        acc.IsVirtualParent__c      = true;
        acc.AccountGroup__c         = '1090';
        acc.BusinessNumber__c       = '5148171771';

        acc.DistributionChannel__c  = '10';
        acc.Division__c             = '40';
        acc.SalesOffice__c          = '114E';
        acc.SalesOrganization__c    = '1800';

        acc.CurrencyIsoCode         = 'KRW';
        acc.Country__c              = 'KR';
        acc.CountryLookup__c        = country.Id;
        return acc;
    }




    /*  *sales area data info  */
    public static SalesAreaData__c createAreaData(Account acc){

        SalesAreaData__c area       = new SalesAreaData__c();
        area.CurrencyIsoCode        = 'KRW';
        area.Account__c             = acc.Id;
        area.SalesOrganization__c   = '1800';
        area.DistributionChannel__c = '10';
        area.Division__c            = '40';
        area.SalesDistrict__c       = 'A1KR';
        area.SalesOffice__c         = '114E';
        area.Currency__c            = 'KRW';
        area.Incoterms__c           = 'Y03';
        area.TermsOfPayment__c      = 'C001';
        area.ShippingConditions__c  = '10';
        area.Country__c             = 'KR';
        return area;
    }
    
    



    /*  *contact info  */
    public static Contact createContact(String conType, Id accId) {
        RecordType type = getRecordType(conType, 'Contact');

        Contact con      = new Contact();
        con.AccountId    = accId;
        con.LastName     = 'testuser';
        con.RecordTypeId = type.Id;
        con.Email        = 'test'+accId+'@gmail.com';
        con.Position__c  = '대리';
        con.Role__c      = '영업';

        con.DistributionChannel__c = '10';
        con.Division__c            = '40';
        con.SalesOffice__c         = '114E';
        con.SalesDistrict__c       = 'A1KR';
        con.SalesOrganization__c   = '1800';
        return con;
    }



    /*  *Country__c info  */
    public static Country__c createCountry(String counName, String counCurr, String counCode) {
        Country__c country      = new Country__c();
        country.Name            = counName;
        country.CurrencyIsoCode = counCurr;
        country.CountryCode__c  = counCode;
        return country;
    }

    /**
    * @description 한국 국가 생성
    **/
    public static Country__c createKRCountry() {
        Country__c country      = new Country__c();
        country.Name            = 'South Korea';
        country.CurrencyIsoCode = 'KRW';
        country.CountryCode__c  = 'KR';
        return country;
    }


    /*  *Region__c info  */
    public static Region__c createRegion(String regionName, String regCurr, String regCode, Id countryId) {
        Region__c region        = new Region__c();
        region.Name             = regionName;
        region.CurrencyIsoCode  = regCurr;
        region.RegionCode__c    = regCode;
        region.Region__c        = regionName;
        region.Country__c       = countryId;
        return region;
    }
    


    /*  *opportunity info  */
    public static Opportunity createDNSDomesticOpty(Account acc, User owner, String optyType){
        RecordType type  = getRecordType(optyType, 'Opportunity');
        Id pBookId = Test.getStandardPricebookId();

        Date today = Date.today();
        Opportunity opty             = new Opportunity();
        opty.AccountId               = acc.Id;
        opty.RecordTypeId            = type.Id;
        opty.Name                    = 'test opportunity';
        opty.StageName               = 'Identified';
        opty.LeadSource              = 'Employee Referral';
        opty.CurrencyIsoCode         = 'KRW';
        opty.Pricebook2Id            = pBookId;
        opty.OwnerId                 = owner.Id;
        opty.MainCategory__c         = 'MB';
        opty.SubCategory__c          = 'MB2';
        opty.IsTooling__c            = 'MY';
        opty.Country__c              = 'KR';
        opty.Budget__c               = 100000000;
        opty.RequestDelieveryDate__c = today.addMonths(2);
        opty.CloseDate               = today.addMonths(1);
        opty.OpportunityIdentifier__c = owner.Id;
        opty.Opportunity_Owner__c    = owner.Id;

        return opty;
    }

    /**
    * @description 경쟁사 생성
    **/
    public static Competitor__c createCompetitor(){
        Competitor__c newCompetitor = new Competitor__c();
        newCompetitor.Name = 'competitor';
        return newCompetitor;
    }

    /**
    * @description 경상사 & 기회 정션 생성
    **/
    public static OpptyCompetitorMapping__c createOpptyCompetitorMapping(Opportunity opty, Competitor__c newCompetitor){
        OpptyCompetitorMapping__c optyCompetitor = new OpptyCompetitorMapping__c();
        optyCompetitor.Competitor__c = newCompetitor.Id;
        optyCompetitor.Opportunity__c = opty.Id;
        return optyCompetitor;
    }

    /**
    * @description 기회 제품 생성
    **/
    public static OpportunityLineItem createOptyItem(Opportunity opty, PricebookEntry entry, Product2 prod) {

        OpportunityLineItem oItem = new OpportunityLineItem();
        oItem.OpportunityId       = opty.Id;
        oItem.PricebookEntryId    = entry.Id;
        oItem.Product2Id          = prod.Id;
        oITem.Quantity            = 1;
        oItem.UnitPrice           = 0;
        return oItem;
    }




    /*  *Quote info  */
    public static Quote createDNSDomesticQuote(User owner, Opportunity opty, String quoteType) {
        RecordType types  = getRecordType(quoteType, 'Quote');
        Id pBookId = Test.getStandardPricebookId();

        Quote quote                 = new Quote();
        quote.Name                  = 'test quote_Quote_V1';
        quote.RecordTypeId          = types.Id;
        quote.OpportunityId         = opty.Id;
        quote.Pricebook2Id          = pBookId;
        quote.Incoterms__c          = 'Y03';
        quote.ExpectedDelivDate__c  = '계약 후 5개월 내';
        quote.TermsOfPayment__c     = 'C001';
        quote.CurrencyIsoCode       = 'KRW';
        quote.Tax                   = 1234;

        return quote;
    }

    /**
    * @description 견적 제품 생성
    **/
    public static QuoteLineItem createQuoteItem(Quote quote, PricebookEntry entry, OpportunityLineItem oItem, Product2 prod) {
        Date today = Date.today();

        QuoteLineItem qItem         = new QuoteLineItem();
        qItem.QuoteId               = quote.Id;
        qItem.PricebookEntryId      = entry.Id;
        qItem.OpportunityLineItemId = oItem.Id;
        qItem.Product2Id            = prod.Id;
        qItem.RequestedDelivDate__c = today.addMonths(2);
        qItem.ExpectedDelivDate__c  = '계약 후 5개월 내';
        qItem.UnitPrice             = 0;
        qItem.Quantity              = 1;
        qItem.Max_POSNR__c          = 20;
        return qItem;
    }

    /**
    * @description SQ 등록
    **/
    public static SQRegistration__c createSQReg(Id optyId, Id prodId, Id accId, Id userId, Id dealerAcc){
        SQRegistration__c sqReg    = new SQRegistration__c();
        sqReg.Name                 = 'TEST';
        sqReg.Opportunity__c       = optyId;
        sqReg.Model__c             = 'DBC 110S';
        sqReg.BaseCode__c          = prodId;
        sqReg.Account__c           = accId;
        sqReg.Stage__c             = 'Final Confirm';
        sqReg.Owner__c             = userId;
        sqReg.Dealer__c            = dealerAcc;
        sqReg.SalesOrganization__c = '1800';
        sqReg.SalesOffice__c       = '114F';
        return sqReg;
    }



    /*  *sq info  */
    public static SQ__c createSQ(Id sqRegId, Decimal posnr){
        SQ__c sq              = new SQ__c();
        sq.Name               = '입회검사';
        sq.Category__c        = '입회검사';
        sq.Price__c           = 300000;
        sq.SQ_Registration__c = sqRegId;
        sq.POSNR__c           = posnr;
        return sq;
    }
    



    /*  *accessory info  */
    public static Accessory__c createAccessory(Id qItemId, Decimal posnr){
        Accessory__c accessory     = new Accessory__c();
        accessory.Name             = 'C50221042';
        accessory.QuoteLineItem__c = qItemId;
        accessory.Key__c           = 'C50221042';
        accessory.Description__c   = 'BUCKET,CHIP;300L';
        accessory.Quantity__c      = 1;
        accessory.Price__c         = 1200000;
        accessory.SalesUnit__c     = 'EA';
        accessory.POSNR__c         = posnr;
        return accessory;
    }




    /*  *cv info  */
    public static CharacteristicValue__c createCV(Id qItemId, String cCode, String vCode){
        CharacteristicValue__c cv = new CharacteristicValue__c();
        cv.ShowData__c            = true;
        cv.defChange__c           = true;
        cv.QuoteLineItem__c       = qItemId;
        cv.C_Code__c              = String.isBlank(cCode) ? 'MT5281' : cCode;
        cv.V_Code__c              = String.isBlank(vCode) ? 'V0060' : vCode;
        cv.C_Value__c             = 'BORING SLEEVE';
        cv.V_Value__c             = 'BORING SLEEVE_1.5 INCH';
        cv.Price__c               = 800000;
        return cv;
    }

    /**
    * @description CV & 견적 제품 정션 생성
    **/
    public static CVOrderItem__c createCVJunction(Id cvId, Id oItemId){
        CVOrderItem__c cvOItem         = new CVOrderItem__c();
        cvOItem.CharacteristicValue__c = cvId;
        cvOItem.OrderProduct__c        = oItemId;
        return cvOItem;
    }

    
    




    /*  *order info  */
    public static Order createDNSDomesticOrder(Account acc, Opportunity opty, Quote quote, User owner, String orderType){
        RecordType type  = getRecordType(orderType, 'Order');
        Id pBookId = Test.getStandardPricebookId();

        Date today = Date.today();

        Order order                  = new Order();
        order.AccountId              = acc.Id;
        order.Pricebook2Id           = pBookId;
        order.OpportunityId          = opty.Id;
        order.QuoteId                = quote.Id;
        order.RecordTypeId           = type.Id;
        order.EffectiveDate          = today;
        order.Status                 = 'Created';
        order.CurrencyIsoCode        = quote.CurrencyIsoCode;
        order.OrderType__c           = 'ZPO';
        order.ReqDeliveryDate__c     = today.addMonths(2);
        order.PurchaseType__c        = 'Z1';
        order.Country__c             = 'KR';
        order.SalesChannelType__c    = 'DomesticPartner';
        order.OrderSegmentation__c   = 'Wholesale';

        order.PaymentTerms__c        = 'C001';
        order.Incoterms__c           = 'Y03';
        order.ShippingConditions__c  = '10';

        order.EndUser__c             = 'test';
        order.Contractor__c          = 'test';
        order.MainCategory__c        = 'MB';
        order.SubCategory__c         = 'MB2';
        order.IsTooling__c           = 'MY';

        order.OwnerId                = owner.Id;
        order.SalesRep__c            = owner.AccountId;
        order.ServiceDealer__c       = owner.AccountId;
        order.CreditDealer__c        = owner.AccountId;

        order.BillTo__c              = acc.Id;
        order.ShipTo__c              = acc.Id;
        order.Payer__c               = acc.Id;
        order.SoldTo__c              = acc.Id;

        order.DistributionChannel__c = '10';
        order.Division__c            = '40';
        order.SalesDistrict__c       = 'A1KR';
        order.SalesOrganization__c   = '1800';
        return order;
    }

    /**
    * @description DNSA Order 생성
    **/
    public static Order createDNSAOrder(Account acc, Opportunity opty, Quote quote, User owner){
        RecordType type  = getRecordType('DNSA', 'Order');
        Id pBookId = Test.getStandardPricebookId();

        Date today = Date.today();

        Order order                  = new Order();
        order.AccountId              = acc.Id;
        order.Pricebook2Id           = pBookId;
        order.OpportunityId          = opty.Id;
        order.QuoteId                = quote.Id;
        order.RecordTypeId           = type.Id;
        order.EffectiveDate          = today;
        order.Status                 = 'Created';
        order.CurrencyIsoCode        = quote.CurrencyIsoCode;
        order.OrderType__c           = 'ZDOB';
        order.ReqDeliveryDate__c     = today.addMonths(2);
        order.Country__c             = 'US';
        order.SalesChannelType__c    = 'DNSA';

        order.PaymentTerms__c        = 'C001';
        order.Incoterms__c           = 'FOB';
        order.ShippingConditions__c  = '10';
        order.Warranty__c            = 'M18';

        order.OwnerId                = owner.Id;
        order.SalesRep__c            = owner.AccountId;
        order.ServiceDealer__c       = owner.AccountId;
        order.CreditDealer__c        = owner.AccountId;

        order.BillTo__c              = acc.Id;
        order.ShipTo__c              = acc.Id;
        order.Payer__c               = acc.Id;
        order.SoldTo__c              = acc.Id;

        order.DistributionChannel__c = '10';
        order.Division__c            = '40';
        order.SalesDistrict__c       = 'MP04';
        order.SalesOrganization__c   = '4140';
        return order;
    }



    /*  *orderItem info  */
    public static OrderItem createOrderProduct(
        Id orderId
        , Id prodId
        , Id entryId
        , Id qItemId
        , String posnr
    ){
        OrderItem oItem          = new OrderItem();
        oItem.OrderId            = orderId;
        oItem.Product2Id         = prodId;
        oItem.PricebookEntryId   = entryId;
        oItem.QuoteLineItemId    = qItemId;
        oItem.Quantity           = 1;
        oItem.UnitPrice          = 119600000;
        oItem.StandardPrice__c   = 113900000;
        oItem.AdjustmentPrice__c = -1480000;
        oItem.DealerPrice__c     = 113000000;
        oItem.IF_POSNR__c        = posnr;
        oItem.ItemCategory__c    = 'Product';
        oItem.Unit__c            = 'EA';

        return oItem;
    }

    /**
    * @description 주문 제품 SQ 카테고리 생성
    **/
    public static OrderItem createOrderSQ(
        Id orderId
        , Id prodId
        , Id entryId
        , Id qItemId
        , Id sqId
        , String posnr
    ){
        OrderItem oItem          = new OrderItem();
        oItem.OrderId            = orderId;
        oItem.Product2Id         = prodId;
        oItem.PricebookEntryId   = entryId;
        oItem.QuoteLineItemId    = qItemId;
        oItem.Quantity           = 1;
        oItem.UnitPrice          = 3400000;
        oItem.StandardPrice__c   = 3400000;
        oItem.IF_POSNR__c        = posnr;
        oItem.ItemCategory__c    = 'SQ';
        oItem.Unit__c            = 'SET';
        oItem.IsInspection__c    = true;
        oItem.SQ__c              = sqId;
        oItem.SQTitle__c         = '입회검사';
        return oItem;
    }

    /**
    * @description 주문 제품 악세서리 카테고리 생성
    **/
    public static OrderItem createOrderAccessory(
        Id orderId
        , Id prodId
        , Id entryId
        , Id qItemId
        , Id accessoryId
        , String posnr
    ){
        OrderItem oItem          = new OrderItem();
        oItem.OrderId            = orderId;
        oItem.Product2Id         = prodId;
        oItem.PricebookEntryId   = entryId;
        oItem.QuoteLineItemId    = qItemId;
        oItem.Quantity           = 1;
        oItem.UnitPrice          = 1200000;
        oItem.StandardPrice__c   = 1200000;
        oItem.IF_POSNR__c        = posnr;
        oItem.ItemCategory__c    = 'Accessory';
        oItem.Unit__c            = 'EA';
        oItem.AccessoryName__c   = 'BUCKET,CHIP;300L';
        oItem.Accessory__c       = accessoryId;
        return oItem;
    }




    
    /*  *order pricing selected  */
    public static OrderPricingSelected__c createSelectedProm(Id orderId){
        OrderPricingSelected__c selectedProm = new OrderPricingSelected__c();
        selectedProm.Order__c  = orderId;
        selectedProm.Rate__c   = -5;
        selectedProm.Amount__c = -6516511;
        selectedProm.IsAuto__c = false;
        return selectedProm;
    }
    
    


    /*  *order promotion  */
    public static OrderPromotion__c createOrderPromotion(){
        OrderPromotion__c oProm = new OrderPromotion__c();
        oProm.Name              = '최종 위탁/직영 계약가';
        oProm.PromotionCode__c  = 'ZPRC-0001';
        oProm.StartDate__c      = Date.today().addDays(-10);
        oProm.EndDate__c        = Date.today().addDays(100);
        oProm.CalculateType__c  = 'C';
        oProm.Amount__c         = 0;
        oProm.Rate__c           = 0;
        oProm.IsSpecial__c      = true;
        oProm.SpecialOrder__c   = 1;
        return oProm;
    }
    



    /*  *order incentice  */
    public static OrderIncentive__c createOrderIncentive(){
        OrderIncentive__c incentive     = new OrderIncentive__c();
        incentive.Name                  = '위탁판매 수수료';
        incentive.InputAutomatically__c = false;
        incentive.ApplicationRate__c    = 4;
        incentive.StartDate__c          = Date.today().addDays(-10);
        incentive.EndDate__c            = Date.today().addDays(100);
        return incentive;
    }




    /*  *delivery order info  */
    public static DeliveryOrder__c createDeliveryOrder(Id orderId){
        DeliveryOrder__c dOrder       = new DeliveryOrder__c();
        dOrder.Order__c               = orderId;
        dOrder.Status__c              = 'DOCreated';
        dOrder.DistributionChannel__c = '10';
        dOrder.SalesOrganization__c   = '1800';
        dOrder.SalesOffice__c         = '114E';
        return dOrder;
    }
    
    
    



    /*  *alert manager info  */
    public static AlertManager__c createAlertManager(String managerName){
        AlertManager__c manager = new AlertManager__c();
        manager.Name        = managerName;
        manager.IsActive__c = true;
        manager.Part__c     = 'Sales';
        return manager;
    }




    /*  *asset info  */
    public static Asset createAsset(){
        Asset asset          = new Asset();
        asset.Name           = 'MH0014-000391';
        asset.SerialNumber   = 'MH0014-000391';
        asset.MachineName__c = 'HM1250';
        asset.NCType__c      = 'FANUC 31I-B PLUS';
        return asset;
    }



    /*  *approval process */
    public static Approval.ProcessResult runApproval(Id recordId, Id approverId){
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(recordId);
        request.setSubmitterId(UserInfo.getUserId());
        request.setComments('plz !!!');
        request.setNextApproverIds(new List<Id>{approverId});
        return Approval.process(request);
    }

    /**
    * @description 승인 작동 메서드
    **/
    public static Approval.ProcessResult actionApproval(Approval.ProcessResult requested, String action){
        // requested : runApproval 그대로 전달, action : Approve, Reject, workItemId 값 있는지 꼭 확인하기
        Id workItemId = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :requested.getInstanceId() LIMIT 1].Id;

        Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
        request.setWorkitemId(workItemId);
        request.setAction(action);
        request.setComments('test');
        return Approval.process(request);
    }
    



    /*  *inspection info */
    public static Inspection__c createInspection(Id orderId, Id qmUserId){
        RecordType type = TestDataFactoryForSales.getRecordType('Inspection_TC', 'Inspection__c');
        Datetime tempDT = Datetime.now();

        Inspection__c inspection          = new Inspection__c();
        inspection.RecordTypeId           = type.Id;
        inspection.Order__c               = orderId;
        inspection.Start_Date_of_Visit__c = tempDT.addDays(10);
        inspection.End_Date_of_Visit__c   = tempDT.addDays(20);
        inspection.QMRep__c               = qmUserId;
        inspection.SalesOffice__c         = '114E';
        inspection.SalesOrganization__c   = '1800';
        return inspection;
    }




    /*  *orderchanerequest info */
    public static OrderChangeRequest__c createOrderChangeRequest(Id orderId, Id dealerAccId){
        OrderChangeRequest__c changeRequest = new OrderChangeRequest__c();
        changeRequest.OrderChangeReason__c  = 'ETC';
        changeRequest.ChangeDetail__c       = 'test';
        changeRequest.Order__c              = orderId;
        changeRequest.Dealer__c             = dealerAccId;
        changeRequest.SalesOffice__c        = '114E';
        changeRequest.SalesOrganization__c  = '1800';
        return changeRequest;
    }




    /*  *payment schedule info */
    public static PaymentSchedule__c createPaymentSchedule(Id orderId){
        Date today = Date.today();

        PaymentSchedule__c payment = new PaymentSchedule__c();
        payment.Order__c           = orderId;
        payment.DocumentDate__c    = today.addDays(10);
        payment.ReqDeliveryDate__c = today.addDays(10);
        payment.TotalAmount__c     = 132880000;
        payment.DraftNoText__c     = '[CNWFOA0]2403_0189';
        payment.DraftNo__c         = '[CNWFOA0]2403_0189';
        payment.DraftCheck__c      = 'Success';
        payment.PlanNo__c          = '0000433182';
        return payment;
    }

    /**
    * @description 수금 스케줄 상세 레코드 생성
    **/
    public static PaymentScheduleItem__c createPaymentItem(Id paymentId){
        PaymentScheduleItem__c paymentItem  = new PaymentScheduleItem__c();
        paymentItem.PaymentSchedule__c      = paymentId;
        paymentItem.Type__c                 = 'P01';
        paymentItem.ScheduledDate__c        = Date.today();
        paymentItem.PaymentTerms__c         = 'CP00';
        paymentItem.InstallmentPrincipal__c = 11510000;
        paymentItem.Days__c                 = 0;
        paymentItem.ReceivedAmount__c       = 0;
        return paymentItem;
    }


    /* *preparation checklist info */
    public static PreparationCheckList__c createPreparation(Id orderId, Id accId, Id conId, Id userId){
        PreparationCheckList__c preparation = new PreparationCheckList__c();
        preparation.Order__c   = orderId;
        preparation.Account__c = accId;
        preparation.SalesOrganization__c = '1800';
        preparation.PreferredInstallationDate__c = Date.today().addDays(10);
        preparation.ContactPerson__c = conId;
        preparation.SalesReps__c = userId;
        preparation.SalesOffice__c = '114E';
        return preparation;
    }




    /*  *interface */
    public static Interface__c createinterface(String ifName, String processingType){
        Interface__c ifc      = new Interface__c();
        ifc.Name              = ifName; // e.g. IF-DELIV-003
        ifc.ProcessingType__c = processingType; // Real-Time, Batch
        ifc.Description__c    = 'test';
        ifc.IsActive__c       = true;
        ifc.HttpMethod__c     = 'POST';
        ifc.EndpointURL__c    = 'http://temp';
        ifc.System__c         = 'ERP';
        ifc.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
        ifc.Timeout__c        = 120000;
        return ifc;
    }

    /**
    * @description 인터페이스 레코드 생성
    **/
    public static InterfaceClasses__c createIFClass(String ifClasName, Id interfaceId){
        InterfaceClasses__c ifClass = new InterfaceClasses__c();
        ifClass.Name         = ifClasName; // e.g. IF_ERP_DELIV
        ifClass.Interface__c = interfaceId;
        return ifClass;
    }

}