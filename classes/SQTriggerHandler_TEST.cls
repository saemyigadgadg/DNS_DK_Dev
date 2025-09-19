/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-20-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class SQTriggerHandler_TEST {
    @testSetup
    static void setUp() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler'
        ,'OpportunityLineItemTriggerHandler', 'QuoteTriggerHandler', 'QuoteLineItemTriggerHandler', 'SQRegistrationTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        List<Country__c> countryList = new List<Country__c>();
        List<Account> dealerAccList = new List<Account>();
        List<Contact> dealerConList = new List<Contact>();
        Country__c country = TestDataFactoryForSales.createKRCountry();
        countryList.add(country);

        Country__c country2      = new Country__c();
        country2.Name            = 'USA';
        country2.CurrencyIsoCode = 'USD';
        country2.CountryCode__c  = 'US';
        countryList.add(country2);
        insert countryList;

        TestDataFactoryForSales.activatePriceBook();

        User dealer;
        User dealer2;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAccList.add(dealerAcc);

            RecordType type = TestDataFactoryForSales.getRecordType('Dealer', 'Account');

            Account dealerAcc2           = new Account();
            dealerAcc2.Name              = 'test company';
            dealerAcc2.RecordTypeId      = type.Id;
            dealerAcc2.Phone             = '00000000001';
            dealerAcc2.BusinessNumber__c = '5148171771';
            dealerAcc2.Representative__c = 'testuser1';
            dealerAcc2.CustomerCode__c   = '0000001';
            dealerAcc2.TypeOfBusiness__c = 'Manufacturing';
            dealerAcc2.TypeOfIndustry__c = 'Wholesale and Commodity Brokerage';
            dealerAcc2.IsKeyAccount__c   = true;
            dealerAcc2.ParentId          = null;
    
            dealerAcc2.CurrencyIsoCode  = 'USD';
            dealerAcc2.Country__c       = 'US';
            dealerAcc2.CountryLookup__c = country2.Id;
            
            dealerAcc2.DistributionChannel__c = '20';
            dealerAcc2.Division__c            = '40';
            dealerAcc2.SalesOffice__c         = '114E';
            dealerAcc2.SalesDistrict__c       = 'A1KR';
            dealerAcc2.SalesOrganization__c   = '1800';
    
            dealerAcc2.ShippingCity = '대구광역시 달서구 성서공단로';
            dealerAcc2.ShippingPostalCode = '42722';
    
            dealerAccList.add(dealerAcc2);
            insert dealerAccList;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            dealerConList.add(delaerCon);

            Contact delaerCon2 = TestDataFactoryForSales.createContact('Dealer', dealerAcc2.Id);
            dealerConList.add(delaerCon2);

            insert dealerConList;

            Test.startTest();
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer2 = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc2, delaerCon2);
            insert dealer;
            insert dealer2;
            Test.stopTest();
            User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert kaUser;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        ProductByPlant__c pbnew = new ProductByPlant__c();
        pbnew.Plant__c = '1840';
        pbnew.Part__c = prod.Id;
        insert pbnew;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        List<Account> parentAccList = new List<Account>();
        List<SalesAreaData__c> areaList = new List<SalesAreaData__c>();
        List<Contact> conList = new List<Contact>();
        List<Opportunity> optyList = new List<Opportunity>();
        
        System.runAs(dealer) {
            Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
            parentAccList.add(parentAcc);

            Account parentAcc2 = TestDataFactoryForSales.createParentAccount(country2);
            parentAccList.add(parentAcc2);
            
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            parentAccList.add(acc);

            RecordType type2 = TestDataFactoryForSales.getRecordType('Dealer', 'Account');

            Account acc2           = new Account();
            acc2.Name              = 'test company';
            acc2.RecordTypeId      = type2.Id;
            acc2.Phone             = '00000000002';
            acc2.BusinessNumber__c = '5148171772';
            acc2.Representative__c = 'testuser2';
            acc2.CustomerCode__c   = '0000002';
            acc2.TypeOfBusiness__c = 'Manufacturing';
            acc2.TypeOfIndustry__c = 'Wholesale and Commodity Brokerage';
            acc2.IsKeyAccount__c   = true;
            acc2.ParentId          = parentAcc2 == null ? null : parentAcc2.Id;
    
            acc2.CurrencyIsoCode  = 'USD';
            acc2.Country__c       = 'US';
            acc2.CountryLookup__c = country2.Id;
            
            acc2.DistributionChannel__c = '20';
            acc2.Division__c            = '40';
            acc2.SalesOffice__c         = '114E';
            acc2.SalesDistrict__c       = 'A1KR';
            acc2.SalesOrganization__c   = '1800';
    
            acc2.ShippingCity = '대구광역시 달서구 성서공단로';
            acc2.ShippingPostalCode = '42722';
    
            parentAccList.add(acc2);
            insert parentAccList;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            areaList.add(area);

            SalesAreaData__c area2       = new SalesAreaData__c();
            area2.CurrencyIsoCode        = 'USD';
            area2.Account__c             = acc2.Id;
            area2.SalesOrganization__c   = '1800';
            area2.DistributionChannel__c = '20';
            area2.Division__c            = '40';
            area2.SalesDistrict__c       = 'A1KR';
            area2.SalesOffice__c         = '114E';
            area2.Currency__c            = 'USD';
            area2.Incoterms__c           = 'Y03';
            area2.TermsOfPayment__c      = 'C001';
            area2.ShippingConditions__c  = '10';
            area2.Country__c             = 'US';
            areaList.add(area2);
            insert areaList;

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            optyList.add(opty);

            Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
            insert newCompetitor;

            OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty, newCompetitor);
            insert optyCompetitor;

            Id pBookId = Test.getStandardPricebookId();
            Date today = Date.today();

            Opportunity opty1             = new Opportunity();
            opty1.AccountId               = acc2.Id;
            opty1.RecordTypeId            = opty.RecordTypeId;
            opty1.Name                    = 'test opportunity';
            opty1.StageName               = 'Qualified';
            opty1.LeadSource              = 'Employee Referral';
            opty1.CurrencyIsoCode         = 'KRW';
            opty1.Pricebook2Id            = pBookId;
            opty1.OwnerId                 = dealer.Id;
            opty1.MainCategory__c         = 'MB';
            opty1.SubCategory__c          = 'MB2';
            opty1.IsTooling__c            = 'MY';
            opty1.Country__c              = 'US';
            opty1.Budget__c               = 100000000;
            opty1.RequestDelieveryDate__c = today.addMonths(2);
            opty1.CloseDate               = today.addMonths(1);
            opty1.OpportunityIdentifier__c = dealer.Id;
            opty1.Opportunity_Owner__c    = dealer.Id;
            optyList.add(opty1);

            Opportunity opty2             = new Opportunity();
            opty2.AccountId               = acc2.Id;
            opty2.RecordTypeId            = opty.RecordTypeId;
            opty2.Name                    = 'test opportunity';
            opty2.StageName               = 'Qualified';
            opty2.LeadSource              = 'Employee Referral';
            opty2.CurrencyIsoCode         = 'KRW';
            opty2.Pricebook2Id            = pBookId;
            opty2.OwnerId                 = dealer.Id;
            opty2.MainCategory__c         = 'MB';
            opty2.SubCategory__c          = 'MB2';
            opty2.IsTooling__c            = 'MY';
            opty2.Country__c              = 'US';
            opty2.Budget__c               = 100000000;
            opty2.RequestDelieveryDate__c = today.addMonths(2);
            opty2.CloseDate               = today.addMonths(1);
            opty2.OpportunityIdentifier__c = dealer.Id;
            opty2.Opportunity_Owner__c    = dealer.Id;
            optyList.add(opty2);
            insert optyList;
    
            List<OpportunityLineItem> optyliList = new List<OpportunityLineItem>();
            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            optyliList.add(oItem);

            OpportunityLineItem oItem2 = TestDataFactoryForSales.createOptyItem(opty1, entry, prod);
            OpportunityLineItem oItem3 = TestDataFactoryForSales.createOptyItem(opty2, entry, prod);
            optyliList.add(oItem2);
            optyliList.add(oItem3);
            insert optyliList;

            PS__c newPs = new PS__c();
            newPs.Opportunity__c = opty1.Id;
            insert newPs;

            List<Quote> qtList = new List<Quote>();
            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            quote.Name = 'koreaQuote';
            qtList.add(quote);
            Quote quote2 = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty1, 'Global');
            quote2.Name = 'globalQuote';
            qtList.add(quote2);
            Quote quote3 = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty2, 'Service');
            quote3.Name = 'serviceQuote';
            qtList.add(quote3);
            insert qtList;
            
            List<QuoteLineItem> qitemList = new List<QuoteLineItem>();
            QuoteLineItem qItem        = new QuoteLineItem();
            qItem.QuoteId               = quote.Id;
            qItem.PricebookEntryId      = entry.Id;
            qItem.OpportunityLineItemId = oItem.Id;
            qItem.Product2Id            = prod.Id;
            qItem.RequestedDelivDate__c = today.addMonths(2);
            qItem.ExpectedDelivDate__c  = '계약 후 5개월 내';
            qItem.UnitPrice             = 0;
            qItem.Quantity              = 1;
            qItem.ERPInquiryNo__c       = '600203599';
            qItem.Adjustment_Price__c   = 123.4;
            qitemList.add(qItem);
            
            QuoteLineItem qItem2        = new QuoteLineItem();
            qItem2.QuoteId               = quote2.Id;
            qItem2.PricebookEntryId      = entry.Id;
            qItem2.OpportunityLineItemId = oItem2.Id;
            qItem2.Product2Id            = prod.Id;
            qItem2.RequestedDelivDate__c = today.addMonths(2);
            qItem2.ExpectedDelivDate__c  = '계약 후 5개월 내';
            qItem2.UnitPrice             = 0;
            qItem2.Quantity              = 1;
            qItem2.ERPInquiryNo__c       = 'inquiry1';
            qItem2.Adjustment_Price__c   = 123.4;

            qitemList.add(qItem2);

            QuoteLineItem qItem3        = new QuoteLineItem();
            qItem3.QuoteId               = quote3.Id;
            qItem3.PricebookEntryId      = entry.Id;
            qItem3.OpportunityLineItemId = oItem3.Id;
            qItem3.Product2Id            = prod.Id;
            qItem3.RequestedDelivDate__c = today.addMonths(2);
            qItem3.ExpectedDelivDate__c  = '계약 후 5개월 내';
            qItem3.UnitPrice             = 0;
            qItem3.Quantity              = 1;
            qItem3.ERPInquiryNo__c       = 'inquiry1';
            qItem3.Adjustment_Price__c   = 123.4;

            qitemList.add(qItem3);

            insert qitemList;
        }
    }

    @isTest
    static void triggerInsertTest() {
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode, ERPQuotationNo__c FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        qli.ERPQuotationNo__c = '1231312312';
        update qli;
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = UserInfo.getUserId();
        insert qwe;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Product_Representative__c = qwe.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review.Product_Representative__c = qwe.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        Test.startTest();
        SQ__c sq = new SQ__c(
            Name = 'test',
            SQ_Comments__c = 'wdawdwadasdwasd \\n adwda <br /> awdadd',
            Price__c = 1000,
            Category__c = 'VMC_부가 축 SQ의뢰 양식',
            ReviewApprovalDate__c = Date.valueOf('2025-02-19'),
            Delivery_Date_months__c = 10,
            CurrencyIsoCode = 'KRW',
            IsDelete__c = false,
            SQ_Registration__c = sqr.Id,
            RequestedSQ__c = req.Id
        );
        insert sq;
        Test.stopTest();
    }

    @isTest
    static void triggerUpdateTest() {
        AlertManager__c am = TestDataFactoryForSales.createAlertManager('New Review SQ Alert');
        insert am;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode, ERPQuotationNo__c FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        qli.ERPQuotationNo__c = '1231312312';
        update qli;
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = UserInfo.getUserId();
        insert qwe;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Product_Representative__c = qwe.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review.Product_Representative__c = qwe.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        SQ__c sq = new SQ__c(
            Name = 'test',
            SQ_Comments__c = 'wdawdwadasdwasd \\n adwda <br /> awdadd',
            Price__c = 1000,
            Category__c = 'VMC_부가 축 SQ의뢰 양식',
            ReviewApprovalDate__c = Date.valueOf('2025-02-19'),
            Delivery_Date_months__c = 10,
            CurrencyIsoCode = 'KRW',
            IsDelete__c = false,
            SQ_Registration__c = sqr.Id,
            RequestedSQ__c = req.Id
        );
        insert sq;

        SQ__c sq2 = new SQ__c(
            Name = 'test2',
            SQ_Comments__c = 'wdawdwadasdwasd \\n adwda <br /> awdadd',
            Price__c = 1000,
            Category__c = 'VMC_부가 축 SQ의뢰 양식',
            ReviewApprovalDate__c = Date.valueOf('2025-02-19'),
            Delivery_Date_months__c = 10,
            CurrencyIsoCode = 'KRW',
            IsDelete__c = false,
            SQ_Registration__c = sqr.Id,
            RequestedSQ__c = req.Id
        );
        insert sq2;

        SQ__c sq3 = new SQ__c(
            Name = 'test2',
            SQ_Comments__c = 'wdawdwadasdwasd \\n adwda <br /> awdadd',
            Price__c = 1000,
            Category__c = 'VMC_부가 축 SQ의뢰 양식',
            ReviewApprovalDate__c = Date.valueOf('2025-02-19'),
            Delivery_Date_months__c = 10,
            CurrencyIsoCode = 'KRW',
            IsDelete__c = false,
            SQ_Registration__c = sqr.Id,
            RequestedSQ__c = req.Id
        );
        insert sq3;

        SQ_QuoteLineitem_Junction__c dwdw = new SQ_QuoteLineitem_Junction__c();
        dwdw.QuoteLineItem__c = qli.Id;
        dwdw.SQ__c = sq.Id;
        dwdw.POSNR__c = 20;
        insert dwdw;

        Test.startTest();
        sq.Name = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        sq.IsFinal__c =  true;
        update sq;
        sq2.Name = 'tt';
        update sq2;
        sq3.IsDelete__c = true;
        update sq3;
        Test.stopTest();
    }

    @isTest
    static void triggerDeleteTest() {
        AlertManager__c am = TestDataFactoryForSales.createAlertManager('New Review SQ Alert');
        insert am;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode, ERPQuotationNo__c FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        qli.ERPQuotationNo__c = '1231312312';
        update qli;
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = UserInfo.getUserId();
        insert qwe;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Product_Representative__c = qwe.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review.Product_Representative__c = qwe.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        SQ__c sq = new SQ__c(
            Name = 'test',
            SQ_Comments__c = 'wdawdwadasdwasd \\n adwda <br /> awdadd',
            Price__c = 1000,
            Category__c = 'VMC_부가 축 SQ의뢰 양식',
            ReviewApprovalDate__c = Date.valueOf('2025-02-19'),
            Delivery_Date_months__c = 10,
            CurrencyIsoCode = 'KRW',
            IsDelete__c = false,
            SQ_Registration__c = sqr.Id,
            RequestedSQ__c = req.Id
        );
        insert sq;

        SQ_QuoteLineitem_Junction__c dwdw = new SQ_QuoteLineitem_Junction__c();
        dwdw.QuoteLineItem__c = qli.Id;
        dwdw.SQ__c = sq.Id;
        dwdw.POSNR__c = 20;
        insert dwdw;

        Test.startTest();
        delete sq;
        Test.stopTest();
    }
}