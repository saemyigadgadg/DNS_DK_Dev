/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 05-30-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-18-2025   Hanyeong Choi   Initial Version
**/
@isTEST
public with sharing class DN_SQController_TEST {
    @TestSetup
    static void setUp() {
        List<Warranty__c> warrantyrecords = TestDataFactoryForSales.getWarranty();
        insert warrantyrecords;

        AlertManager__c am = TestDataFactoryForSales.createAlertManager('New SQ Alert');
        AlertManager__c am2 = TestDataFactoryForSales.createAlertManager('Requested SQ Refine Alert');
        AlertManager__c am3 = TestDataFactoryForSales.createAlertManager('Re Review SQ Alert');
        AlertManager__c am4 = TestDataFactoryForSales.createAlertManager('Refine Complete Alert');
        insert am;
        insert am2;
        insert am3;
        insert am4;

        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Content',
            VersionData = Blob.valueOf('Test Data'),
            PathOnClient = 'Test.png'
        );
        insert testContentVersion;

        Model__c model = new Model__c();
        model.Name = 'DN_Common';
        model.contentVersionId__c = testContentVersion.Id;
        insert model;
        
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


        Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler'};
        bypassSet.add('AccountTriggerHandler');
        bypassSet.add('ContactTriggerHandler');
        bypassSet.add('QuoteTriggerHandler');
        bypassSet.add('OpportunityLineItemTriggerHandler');
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
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

            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            conList.add(con);

            Contact con2 = TestDataFactoryForSales.createContact('ContactPerson', acc2.Id);
            conList.add(con2);
            insert conList;

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
            qItem.Warranty__c           = 'B24';
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
            qItem2.Warranty__c           = 'B12';
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
            qItem3.Warranty__c           = 'B12';
            qItem3.UnitPrice             = 0;
            qItem3.Quantity              = 1;
            qItem3.ERPInquiryNo__c       = 'inquiry1';
            qItem3.Adjustment_Price__c   = 123.4;

            qitemList.add(qItem3);

            insert qitemList;
        }
    }

    @isTest
    static void getInit_Test() {
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        Quote quote2 = [SELECT Id FROM Quote WHERE Name = 'globalQuote' LIMIT 1];
        Quote quote3 = [SELECT Id FROM Quote WHERE Name = 'serviceQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem WHERE ERPInquiryNo__c = '600203599' LIMIT 1];
        QuoteLineItem qli2 = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :quote2.Id LIMIT 1];
        QuoteLineItem qli3 = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :quote3.Id LIMIT 1];

        Test.startTest();
        DN_SQController.getInit(quote.Id, qli.Id, 'SQRegistration__c');
        DN_SQController.getInit(quote.Id, qli.Id, 'RequestedSQ__c');
        DN_SQController.getInit(quote2.Id, qli2.Id, 'SQRegistration__c');
        DN_SQController.getInit(quote3.Id, qli3.Id, 'SQRegistration__c');
        Test.stopTest();
    }

    @isTest
    static void getFieldInfo_Test() {
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];

        Test.startTest();
        DN_SQController.getFieldInfo(quote.Id);
        Test.stopTest();
    }

    @isTest
    static void insertSQRegistration_Test() {
        AlertManager__c am = TestDataFactoryForSales.createAlertManager('New SQ Registration Alert');
        insert am;
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        List<Map<String, String>> searchDatas = new List<Map<String, String>>();
        Map<String, String> searchData = new Map<String, String>{'key' => 'value'};
        searchDatas.add(searchData);
        String jsonInput = '[{"Id": "' + qli.Id + '" , "ProductName": "Laptop", "Quantity": 10}]';
        String requestedSQ = '[{"sqTitle": "TEST" , "sqCategory": "기타"}]';

        MessageGroup__c mg = new MessageGroup__c();
        mg.Name = 'test';
        mg.SalesDistrict__c = 'Korea';
        insert mg;

        List<Message_Group_Junction__c> j = new List<Message_Group_Junction__c>();
        Message_Group_Junction__c j1 = new Message_Group_Junction__c();
        j1.User__c = UserInfo.getUserId();
        j1.Message_Group__c = mg.Id;
        j.add(j1);
        Message_Group_Junction__c j2 = new Message_Group_Junction__c();
        User user = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];
        j2.User__c = user.Id;
        j2.Message_Group__c = mg.Id;
        j.add(j2);
        insert j;

        SQRegistration__c testSQReg = new SQRegistration__c(Name = 'Test SQReg', Message_Group__c = mg.Id);
        insert testSQReg;


        Test.startTest();
        DN_SQController.insertSQRegistration(quote.Id, jsonInput, requestedSQ, searchDatas, testSQReg.Id);
        Test.stopTest();
    }

    @isTest
    static void changeCategory_Test() {
        SQ_Template__c sqt = new  SQ_Template__c();
        sqt.Name = 'VMC_Additional Axis SQ Request Form';
        sqt.Description__c = 'test123';
        insert sqt;

        Test.startTest();
        DN_SQController.changeCategory('기타', '기타', 'ko');
        DN_SQController.changeCategory('test', '테스트', 'en');
        DN_SQController.changeCategory('VMC_부가 축 SQ의뢰 양식', 'VMC_부가 축 SQ의뢰 양식', 'ko');
        DN_SQController.changeCategory('VMC기종_치구라인 SQ의뢰 양식', 'VMC기종_치구라인 SQ의뢰 양식', 'ko');
        Test.stopTest();
    }

    @isTest
    static void initSearchButton_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineitem qli = [SELECT Id, Product2Id FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Id,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id
        );
        insert sqr;

        Test.startTest();
        DN_SQController.initSearchButton(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void initSearchCheckGlobal_Test() {
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'globalQuote' LIMIT 1];
        Quote quote1 = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];

        Test.startTest();
        DN_SQController.initSearchCheckGlobal(quote.Id);
        DN_SQController.initSearchCheckGlobal(quote1.Id);
        Test.stopTest();
    }

    @isTest
    static void initSearchModal_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2.ProductCode FROM QUoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];

        Test.startTest();
        DN_SQController.initSearchModal('DNM 4500', quote.Id, qli.Product2.ProductCode);
        Test.stopTest();
    }

    @isTest
    static void searchSQ_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        SQ_Template__c sqt = new  SQ_Template__c();
        sqt.Name = 'VMC_Additional Axis SQ Request Form';
        sqt.Description__c = 'test123';
        insert sqt;

        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW',
            Stage__c = 'Request'
        );
        insert sqr;

        SQ_Pricing__c sqp = new SQ_Pricing__c(
            Name = 'U10',
            CurrencyIsoCode = 'USD',
            Rate__c = 1120,
            Markup__c = 0.25,
            Land__c = 'US',
            RegionName__c = '미주(DMTA)',
            UsingConditionTable__c = 'A833'
        );
        insert sqp;

        SQ__c sq = new SQ__c(
            Name = 'test',
            SQ_Comments__c = 'wdawdwadasdwasd \\n adwda <br /> awdadd',
            Price__c = 1000,
            Category__c = 'VMC_부가 축 SQ의뢰 양식',
            ReviewApprovalDate__c = Date.valueOf('2025-02-19'),
            Delivery_Date_months__c = 10,
            CurrencyIsoCode = 'KRW',
            IsDelete__c = false,
            SQ_Registration__c = sqr.Id
        );
        insert sq;

        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'SalesSQ__c' AND DeveloperName = 'Domestic' LIMIT 1];

        SalesSQ__c salesSQ = new SalesSQ__c(
            Name = 'test',
            Description__c = 'test',
            List_Price__c = 1000,
            Category__c = '기타',
            Base_Code__c = qli.Product2Id,
            Model_Name__c = 'MV0176',
            Cost__c = 100000,
            RecordTypeId = rt.Id
        );
        insert salesSQ;

        Test.startTest();
        DN_SQController.searchSQ('', '', sqr.Id, qli.Product2.ProductCode);
        DN_SQController.searchSQ('test', 'DNM 4500', sqr.Id, qli.Product2.ProductCode);

        DN_SQController.searchSQ('test', 'DNM 4500', quote.Id, qli.Product2.ProductCode);
        Test.stopTest();
    }

    @isTest
    static void DNSAsearchSQ_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        SQ_Template__c sqt = new  SQ_Template__c();
        sqt.Name = 'VMC_Additional Axis SQ Request Form';
        sqt.Description__c = 'test123';
        insert sqt;

        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Pricing__c sqp = new SQ_Pricing__c(
            Name = 'U10',
            CurrencyIsoCode = 'USD',
            Rate__c = 1120,
            Markup__c = 0.25,
            Land__c = 'US',
            RegionName__c = '미주(DMTA)',
            UsingConditionTable__c = 'A833'
        );
        insert sqp;

        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'SalesSQ__c' AND DeveloperName = 'Global' LIMIT 1];

        SalesSQ__c salesSQ = new SalesSQ__c(
            Name = 'test',
            Description__c = 'test',
            List_Price__c = 1000,
            Category__c = '기타',
            Base_Code__c = qli.Product2Id,
            Model_Name__c = 'DNM 4500',
            Cost__c = 100000,
            RecordTypeId = rt.Id
        );
        insert salesSQ;

        Test.startTest();
        DN_SQController.DNSAsearchSQ('DNM 4500', 'test', sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void updateRequestedSQ_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'SalesSQ__c' AND DeveloperName = 'Domestic' LIMIT 1];
        SalesSQ__c salesSQ = new SalesSQ__c(
            Name = 'test',
            Description__c = 'test',
            List_Price__c = 1000,
            Category__c = '기타',
            Base_Code__c = qli.Product2Id,
            Model_Name__c = 'DNM 4500',
            Cost__c = 100000,
            RecordTypeId = rt.Id
        );
        insert salesSQ;

        SQ__c sq = new SQ__c(
            Name = 'test',
            CurrencyIsoCode = 'KRW',
            Category__c = '기타',
            SQ_Registration__c = sqr.Id
        );
        insert sq;

        List<DN_SQController.SearchModalWrapper> sts = new List<DN_SQController.SearchModalWrapper>();
        List<DN_SQController.SearchModalWrapper> sts2 = new List<DN_SQController.SearchModalWrapper>();
        List<DN_SQController.SearchModalWrapper> salesSRs = new List<DN_SQController.SearchModalWrapper>();
        List<DN_SQController.SearchModalWrapper> rndSRs = new List<DN_SQController.SearchModalWrapper>();
        DN_SQController.SearchModalWrapper st = new DN_SQController.SearchModalWrapper();
        st.Id = req.Id;
        sts.add(st);
        DN_SQController.SearchModalWrapper salesSr = new DN_SQController.SearchModalWrapper();
        salesSr.salesSQ = salesSQ.Id;
        salesSr.sqType = 'Sales SQ';
        salesSrs.add(salesSr);
        DN_SQController.SearchModalWrapper rndSr = new DN_SQController.SearchModalWrapper();
        rndSr.Id = sq.Id;
        rndSrs.add(rndSr);


        Test.startTest();
        DN_SQController.updateRequestedSQ(sts, salesSrs, String.valueOf(sqr.Id));
        DN_SQController.updateRequestedSQ(sts, rndSrs, String.valueOf(sqr.Id));
        DN_SQController.updateRequestedSQ(sts2, salesSrs, String.valueOf(sqr.Id));
        Test.stopTest();
    }

    @isTest
    static void getRelatedListInit_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        Test.startTest();
        DN_SQController.getRelatedListInit(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void sendDNSSalesTeamRequestedSQ_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        AlertManager__c am = TestDataFactoryForSales.createAlertManager('Requested SQ DNS Sales Team Alert');
        insert am;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];

        MessageGroup__c mg = new MessageGroup__c();
        mg.Name = 'test';
        mg.SalesDistrict__c = 'Korea';
        insert mg;

        List<Message_Group_Junction__c> j = new List<Message_Group_Junction__c>();
        Message_Group_Junction__c j1 = new Message_Group_Junction__c();
        j1.User__c = UserInfo.getUserId();
        j1.Message_Group__c = mg.Id;
        j.add(j1);
        Message_Group_Junction__c j2 = new Message_Group_Junction__c();
        User user = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];
        j2.User__c = user.Id;
        j2.Message_Group__c = mg.Id;
        j.add(j2);
        insert j;

        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW',
            Message_Group__c = mg.Id
        );
        insert sqr;

        Test.startTest();
        DN_SQController.sendDNSSalesTeamRequestedSQ(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void saveRichTextValue_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        Test.startTest();
        DN_SQController.saveRichTextValue('wwwwwwwwdwdwdddddddwwwwwwwddwda', sqr.Id, 'requested');
        DN_SQController.saveRichTextValue('wwwwwwwwdwdwdddddddwwwwwwwddwda', sqr.Id, 'review');
        DN_SQController.saveRichTextValue('wwwwwwwwdwdwdddddddwwwwwwwddwda', sqr.Id, 'sq');
        Test.stopTest();
    }

    @isTest
    static void getRequestedSQFieldSet_Test() {
        Test.startTest();
        DN_SQController.getRequestedSQFieldSet('SQRegistration__c', '기타');
        DN_SQController.getRequestedSQFieldSet('RequestedSQ__c', '기타');
        DN_SQController.getRequestedSQFieldSet('RequestedSQ__c', '입회검사');
        Test.stopTest();
    }

    @isTest
    static void newReqInit_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;
        Test.startTest();
        DN_SQController.newReqInit(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void editRequestedInit_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        Test.startTest();
        DN_SQController.editRequestedInit(req.Id, 'RequestedSQ__c');
        Test.stopTest();
    }

    @isTest
    static void deleteRequestedSQ_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        Test.startTest();
        DN_SQController.deleteRequestedSQ(req.Id);
        Test.stopTest();
    }

    @isTest
    static void cloneSQ_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        Test.startTest();
        DN_SQController.cloneSQ(sqr.Id, '');
        DN_SQController.cloneSQ(sqr.Id, 'true');
        Test.stopTest();
    }

    @isTest
    static void updateSQRegistrationStage_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        Test.startTest();
        DN_SQController.updateSQRegistrationStage(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void sendRefineRequirements_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        Test.startTest();
        DN_SQController.sendRefineRequirements(sqr.Id, req.Id, 'TEST');
        Test.stopTest();
    }

    @isTest
    static void getSQInit_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        SQ__c sq = new SQ__c(
            Name = 'test',
            CurrencyIsoCode = 'KRW',
            Category__c = '기타',
            SQ_Registration__c = sqr.Id
        );
        insert sq;

        Test.startTest();
        DN_SQController.getSQInit(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void getSQFieldSet_Test() {
        Test.startTest();
        DN_SQController.getSQFieldSet();
        Test.stopTest();
    }

    @isTest
    static void deleteSQ_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        SQ__c sq = new SQ__c(
            Name = 'test',
            CurrencyIsoCode = 'KRW',
            Category__c = '기타',
            SQ_Registration__c = sqr.Id
        );
        insert sq;
        SQ__c sq2 = new SQ__c(
            Name = 'test2',
            CurrencyIsoCode = 'KRW',
            Category__c = '기타',
            SQ_Registration__c = sqr.Id
        );
        insert sq2;

        SQ_QuoteLineitem_Junction__c asd = new SQ_QuoteLineitem_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQ__c = sq.Id;
        asd.POSNR__c = 20;
        insert asd;
        SQ_QuoteLineitem_Junction__c asd2 = new SQ_QuoteLineitem_Junction__c();
        asd2.QuoteLineItem__c = qli.Id;
        asd2.SQ__c = sq2.Id;
        insert asd2;

        Test.startTest();
        DN_SQController.deleteSQ(sq.Id);
        DN_SQController.deleteSQ(sq2.Id);
        Test.stopTest();
    }

    @isTest
    static void getCVInit_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        Test.startTest();
        DN_SQController.getCVInit(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void createReviewSQ_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        RequestedSQ__c req2 = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '입회검사',
            Description__c = 'test'
        );
        insert req2;

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = UserInfo.getUserId();
        insert qwe;

        Test.startTest();
        DN_SQController.createReviewSQ(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void getReviewInitDatas_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        insert review2;

        Test.startTest();
        DN_SQController.getReviewInitDatas(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void getReviewEditLayout_Test() {
        Test.startTest();
        DN_SQController.getReviewEditLayout();
        Test.stopTest();
    }

    @isTest
    static void setSQReviewComments_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        insert review2;

        Test.startTest();
        DN_SQController.setSQReviewComments(review.Id);
        Test.stopTest();
    }

    @isTest
    static void setRejectBackGroundColor_Test() {
        AlertManager__c am = TestDataFactoryForSales.createAlertManager('SQ Review Reject Alert');
        insert am;
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];

        MessageGroup__c mg = new MessageGroup__c();
        mg.Name = 'test';
        mg.SalesDistrict__c = 'Korea';
        insert mg;

        List<Message_Group_Junction__c> j = new List<Message_Group_Junction__c>();
        Message_Group_Junction__c j1 = new Message_Group_Junction__c();
        j1.User__c = UserInfo.getUserId();
        j1.Message_Group__c = mg.Id;
        j.add(j1);
        Message_Group_Junction__c j2 = new Message_Group_Junction__c();
        User user = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];
        j2.User__c = user.Id;
        j2.Message_Group__c = mg.Id;
        j.add(j2);
        insert j;

        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW',
            Message_Group__c = mg.Id
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        insert review2;

        Test.startTest();
        DN_SQController.setRejectBackGroundColor(review.Id, false, 'TEST');
        Test.stopTest();
    }

    @isTest
    static void searchSQReviewInit_Test() {
        Test.startTest();
        DN_SQController.searchSQReviewInit();
        Test.stopTest();
    }

    @isTest
    static void searchSQReview_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        Test.startTest();
        DN_SQController.searchSQReview('test', model.Name, sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void getSQReviewEditInit_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        Test.startTest();
        DN_SQController.getSQReviewEditInit(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void insertSQReview_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = UserInfo.getUserId();
        insert qwe;

        List<Map<String, String>> records = new List<Map<String, String>>{
            new Map<String, String>{ 'title' => 'Sales Report', 'type' => 'SQ' },
            new Map<String, String>{ 'title' => 'User Guide', 'type' => 'SQ' },
            new Map<String, String>{ 'title' => 'Invoice', 'type' => 'test' }
        };

        Test.startTest();
        DN_SQController.insertSQReview(records, sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void deleteSQReview_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        List<String> asdwdaw = new List<String>();
        asdwdaw.add(review.Id);

        Test.startTest();
        DN_SQController.deleteSQReview(asdwdaw);
        Test.stopTest();
    }

    @isTest
    static void clearSQReview_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test'
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        Test.startTest();
        DN_SQController.clearSQReview(review.Id, review2.Id);
        Test.stopTest();
    }

    @isTest
    static void reRequestSQReview_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test',
            IsReRequest__c = true
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = UserInfo.getUserId();
        insert qwe;

        Test.startTest();
        DN_SQController.reRequestSQReview(review.Id);
        Test.stopTest();
    }

    @isTest
    static void searchManagerInit_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        User user = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = user.Id;
        insert qwe;

        Test.startTest();
        DN_SQController.searchManagerInit();
        Test.stopTest();
    }

    @isTest
    static void searchManager_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        User user = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = user.Id;
        insert qwe;

        Test.startTest();
        DN_SQController.searchManager('dealer');
        Test.stopTest();
    }

    @isTest
    static void setChangeReviewManager_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test',
            IsReRequest__c = true
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = UserInfo.getUserId();
        insert qwe;

        List<DN_SQController.ManagerWrapper> zcList = new List<DN_SQController.ManagerWrapper>();
        DN_SQController.ManagerWrapper zc = new DN_SQController.ManagerWrapper();
        zc.id = qwe.Id;
        zc.part = '제어 담당';
        zcList.add(zc);

        Test.startTest();
        DN_SQController.setChangeReviewManager(review.Id, zcList);
        Test.stopTest();
    }

    @isTest
    static void getDescriptionData_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test',
            IsReRequest__c = true
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = UserInfo.getUserId();
        insert qwe;

        Test.startTest();
        DN_SQController.getDescriptionData(review.Id);
        Test.stopTest();
    }

    @isTest
    static void setSQReviewDescription_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test',
            IsReRequest__c = true
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = UserInfo.getUserId();
        insert qwe;

        Test.startTest();
        DN_SQController.setSQReviewDescription(review.Id, review2.Id, 'adawda');
        Test.stopTest();
    }

    @isTest
    static void checkDropAuth_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        Test.startTest();
        DN_SQController.checkDropAuth(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void dropSQ_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ__c sq = new SQ__c(
            Name = 'test',
            SQ_Comments__c = 'wdawdwadasdwasd \\n adwda <br /> awdadd',
            Price__c = 1000,
            Category__c = 'VMC_부가 축 SQ의뢰 양식',
            ReviewApprovalDate__c = Date.valueOf('2025-02-19'),
            Delivery_Date_months__c = 10,
            CurrencyIsoCode = 'KRW',
            IsDelete__c = false,
            SQ_Registration__c = sqr.Id
        );
        insert sq;

        Test.startTest();
        DN_SQController.dropSQ(sqr.Id, 'TESTSdadwdasd');
        Test.stopTest();
    }

    @isTest
    static void sendCompleteNotiAndEmail_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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
            Description__c = 'test',
            IsReRequest__c = true
        );
        insert req;

        SQ__c sq = new SQ__c(
            Name = 'test',
            SQ_Comments__c = 'wdawdwadasdwasd \\n adwda <br /> awdadd',
            Price__c = 1000,
            Category__c = 'VMC_부가 축 SQ의뢰 양식',
            ReviewApprovalDate__c = Date.valueOf('2025-02-19'),
            Delivery_Date_months__c = 10,
            CurrencyIsoCode = 'KRW',
            IsDelete__c = false,
            SQ_Registration__c = sqr.Id
        );
        insert sq;

        Test.startTest();
        DN_SQController.sendCompleteNotiAndEmail(req.Id);
        Test.stopTest();
    }

    @isTest
    static void updateRefineComplete_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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
            Description__c = 'test',
            IsReRequest__c = true
        );
        insert req;

        Test.startTest();
        DN_SQController.updateRefineComplete(req.Id);
        Test.stopTest();
    }

    @isTest
    static void reviewReqInit_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        Test.startTest();
        DN_SQController.reviewReqInit(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void setComplete_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        SQ_Registration_Junction__c asd = new SQ_Registration_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQRegistration__c = sqr.Id;
        insert asd;

        RequestedSQ__c req = new RequestedSQ__c(
            Name = 'test',
            SQRegistration__c = sqr.Id,
            Category__c = '기타',
            Description__c = 'test',
            IsReRequest__c = true
        );
        insert req;

        SQReview__c review = new SQReview__c();
        review.SQTitle__c = 'test1';
        review.SQRegistration__c = sqr.Id;
        review.RequestedSQ__c = req.Id;
        review.Category__c = '기타';
        review.Comments__c = 'test ttesfseffw adwd wadasd wadwadasd was wdasdwa\\n <br /> adwdasd';
        review.Description__c = 'test ttesfseffw adwd wadasd wadwadasd was dwadasdwa\\n <br /> adwdasd';
        insert review;
        SQReview__c review2 = new SQReview__c();
        review2.SQTitle__c = 'test2';
        review2.SQRegistration__c = sqr.Id;
        review2.RequestedSQ__c = req.Id;
        review2.Category__c = '기타';
        review2.Comments__c = 'test wadwadasd was dwad wad wdasdwa\\n <br /> adwdasd';
        review2.Description__c = 'test ttesfseffw adwd was dwad wad wdasdwa\\n <br /> adwdasd';
        insert review2;

        Product_Representative__c qwe = new Product_Representative__c();
        qwe.Product__c = qli.Product2Id;
        qwe.User__c = UserInfo.getUserId();
        qwe.ControlUser__c = UserInfo.getUserId();
        insert qwe;

        Test.startTest();
        DN_SQController.setComplete(review.Id);
        Test.stopTest();
    }

    @isTest
    static void sqConfirmInite_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
        SQRegistration__c sqr = new SQRegistration__c(
            Name = 'test',
            Model__c = model.Name,
            BaseCode__c = qli.Product2Id,
            Quote__c  = quote.Id,
            CurrencyIsoCode = 'KRW'
        );
        insert sqr;

        Test.startTest();
        DN_SQController.sqConfirmInite(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void getQuoteLineItems_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        SQ__c sq = new SQ__c(
            Name = 'test',
            CurrencyIsoCode = 'KRW',
            Category__c = '기타',
            SQ_Registration__c = sqr.Id
        );
        insert sq;
        SQ__c sq2 = new SQ__c(
            Name = 'test2',
            CurrencyIsoCode = 'KRW',
            Category__c = '기타',
            SQ_Registration__c = sqr.Id
        );
        insert sq2;

        SQ_QuoteLineitem_Junction__c asd = new SQ_QuoteLineitem_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQ__c = sq.Id;
        asd.POSNR__c = 20;
        insert asd;
        SQ_QuoteLineitem_Junction__c asd2 = new SQ_QuoteLineitem_Junction__c();
        asd2.QuoteLineItem__c = qli.Id;
        asd2.SQ__c = sq2.Id;
        insert asd2;

        Test.startTest();
        DN_SQController.getQuoteLineItems(sq.Id);
        Test.stopTest();
    }

    @isTest
    static void cloneSQQuoteLineItem_Test() {
        Model__c mod = TestDataFactoryForSales.createModel();
        insert mod;
        Model__c model = [SELECT Id, Name FROM Model__c WHERE Name = 'DNM 4500' LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'koreaQuote' LIMIT 1];
        QuoteLineItem qli = [SELECT Id, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quote.Id LIMIT 1];
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

        SQ__c sq = new SQ__c(
            Name = 'test',
            CurrencyIsoCode = 'KRW',
            Category__c = '기타',
            SQ_Registration__c = sqr.Id
        );
        insert sq;
        SQ__c sq2 = new SQ__c(
            Name = 'test2',
            CurrencyIsoCode = 'KRW',
            Category__c = '기타',
            SQ_Registration__c = sqr.Id
        );
        insert sq2;

        SQ_QuoteLineitem_Junction__c asd = new SQ_QuoteLineitem_Junction__c();
        asd.QuoteLineItem__c = qli.Id;
        asd.SQ__c = sq.Id;
        asd.POSNR__c = 20;
        insert asd;
        SQ_QuoteLineitem_Junction__c asd2 = new SQ_QuoteLineitem_Junction__c();
        asd2.QuoteLineItem__c = qli.Id;
        asd2.SQ__c = sq2.Id;
        insert asd2;

        Test.startTest();
        DN_SQController.cloneSQQuoteLineItem(sq.Id, qli.Id, qli.Id);
        Test.stopTest();
    }
}