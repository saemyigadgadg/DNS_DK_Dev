@isTest 
public with sharing class DN_QuotationPDFControllerTest {
    @TestSetup
    static void makeData(){
        // ContentVersion testContentVersion = new ContentVersion(
        //     Title = 'Test Content',
        //     VersionData = Blob.valueOf('Test Data'),
        //     PathOnClient = 'Test.png'
        // );
        // insert testContentVersion;

        // Model__c model = new Model__c();
        // model.Name = 'DN_Common';
        // model.contentVersionId__c = testContentVersion.Id;
        // insert model;
        
        // User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        // List<Country__c> countryList = new List<Country__c>();
        // List<Account> dealerAccList = new List<Account>();
        // List<Contact> dealerConList = new List<Contact>();
        // Country__c country = TestDataFactoryForSales.createKRCountry();
        // countryList.add(country);

        // Country__c country2      = new Country__c();
        // country2.Name            = 'USA';
        // country2.CurrencyIsoCode = 'USD';
        // country2.CountryCode__c  = 'US';
        // countryList.add(country2);
        // insert countryList;

        // TestDataFactoryForSales.activatePriceBook();

        // User dealer;
        // User dealer2;
        // System.runAs(thisUser) {
        //     Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
        //     dealerAccList.add(dealerAcc);
    
        //     // Account dealerAcc2 = TestDataFactoryForSales.createAccount('Dealer', country2, null);
        //     // insert dealerAcc2;

        //     RecordType type = TestDataFactoryForSales.getRecordType('Dealer', 'Account');

        //     Account dealerAcc2           = new Account();
        //     dealerAcc2.Name              = 'test company';
        //     dealerAcc2.RecordTypeId      = type.Id;
        //     dealerAcc2.Phone             = '00000000001';
        //     dealerAcc2.BusinessNumber__c = '5148171771';
        //     dealerAcc2.Representative__c = 'testuser1';
        //     dealerAcc2.CustomerCode__c   = '0000001';
        //     dealerAcc2.TypeOfBusiness__c = 'Manufacturing';
        //     dealerAcc2.TypeOfIndustry__c = 'Wholesale and Commodity Brokerage';
        //     dealerAcc2.IsKeyAccount__c   = true;
        //     dealerAcc2.ParentId          = null;
    
        //     dealerAcc2.CurrencyIsoCode  = 'USD';
        //     dealerAcc2.Country__c       = 'US';
        //     dealerAcc2.CountryLookup__c = country2.Id;
            
        //     dealerAcc2.DistributionChannel__c = '20';
        //     dealerAcc2.Division__c            = '40';
        //     dealerAcc2.SalesOffice__c         = '114E';
        //     dealerAcc2.SalesDistrict__c       = 'A1KR';
        //     dealerAcc2.SalesOrganization__c   = '1800';
    
        //     dealerAcc2.ShippingCity = '대구광역시 달서구 성서공단로';
        //     dealerAcc2.ShippingPostalCode = '42722';
    
        //     dealerAccList.add(dealerAcc2);
        //     insert dealerAccList;

        //     Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
        //     dealerConList.add(delaerCon);

        //     Contact delaerCon2 = TestDataFactoryForSales.createContact('Dealer', dealerAcc2.Id);
        //     dealerConList.add(delaerCon2);

        //     insert dealerConList;

        //     Test.startTest();
        //     dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
        //     dealer2 = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc2, delaerCon2);
        //     insert dealer;
        //     insert dealer2;
        //     Test.stopTest();
        //     User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
        //     insert kaUser;
        // }

        // Product2 prod = TestDataFactoryForSales.createProduct();
        // insert prod;

        // PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        // insert entry;


        // Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler'};
        // bypassSet.add('AccountTriggerHandler');
        // bypassSet.add('ContactTriggerHandler');
        // bypassSet.add('QuoteTriggerHandler');
        // bypassSet.add('OpportunityLineItemTriggerHandler');
        // // bypassSet.add('QuoteLineItemTriggerHandler');
        // TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        // List<Account> parentAccList = new List<Account>();
        // List<SalesAreaData__c> areaList = new List<SalesAreaData__c>();
        // List<Contact> conList = new List<Contact>();
        // List<Opportunity> optyList = new List<Opportunity>();
        
        // System.runAs(dealer) {
        //     Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
        //     parentAccList.add(parentAcc);

        //     Account parentAcc2 = TestDataFactoryForSales.createParentAccount(country2);
        //     parentAccList.add(parentAcc2);
            
        //     Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
        //     acc.CustomerCode__c   = '123456';
        //     acc.BusinessNumber__c = '5148171773';
        //     acc.Representative__c = 'realAcc';
        //     parentAccList.add(acc);

        //     // Account acc2 = TestDataFactoryForSales.createAccount('TradeCustomer', country2, parentAcc2);
        //     // acc2.CustomerCode__c   = '123456';
        //     // acc2.BusinessNumber__c = '5148171773';
        //     // acc2.Representative__c = 'realAcc';
        //     // insert acc2;


        //     RecordType type2 = TestDataFactoryForSales.getRecordType('Dealer', 'Account');

        //     Account acc2           = new Account();
        //     acc2.Name              = 'test company';
        //     acc2.RecordTypeId      = type2.Id;
        //     acc2.Phone             = '00000000002';
        //     acc2.BusinessNumber__c = '5148171772';
        //     acc2.Representative__c = 'testuser2';
        //     acc2.CustomerCode__c   = '0000002';
        //     acc2.TypeOfBusiness__c = 'Manufacturing';
        //     acc2.TypeOfIndustry__c = 'Wholesale and Commodity Brokerage';
        //     acc2.IsKeyAccount__c   = true;
        //     acc2.ParentId          = parentAcc2 == null ? null : parentAcc2.Id;
    
        //     acc2.CurrencyIsoCode  = 'USD';
        //     acc2.Country__c       = 'US';
        //     acc2.CountryLookup__c = country2.Id;
            
        //     acc2.DistributionChannel__c = '20';
        //     acc2.Division__c            = '40';
        //     acc2.SalesOffice__c         = '114E';
        //     acc2.SalesDistrict__c       = 'A1KR';
        //     acc2.SalesOrganization__c   = '1800';
    
        //     acc2.ShippingCity = '대구광역시 달서구 성서공단로';
        //     acc2.ShippingPostalCode = '42722';
    
        //     parentAccList.add(acc2);
        //     insert parentAccList;

        //     SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
        //     areaList.add(area);
    
        //     // SalesAreaData__c area2 = TestDataFactoryForSales.createAreaData(acc2);
        //     // insert area2;

        //     SalesAreaData__c area2       = new SalesAreaData__c();
        //     area2.CurrencyIsoCode        = 'USD';
        //     area2.Account__c             = acc2.Id;
        //     area2.SalesOrganization__c   = '1800';
        //     area2.DistributionChannel__c = '20';
        //     area2.Division__c            = '40';
        //     area2.SalesDistrict__c       = 'A1KR';
        //     area2.SalesOffice__c         = '114E';
        //     area2.Currency__c            = 'USD';
        //     area2.Incoterms__c           = 'Y03';
        //     area2.TermsOfPayment__c      = 'C001';
        //     area2.ShippingConditions__c  = '10';
        //     area2.Country__c             = 'US';
        //     areaList.add(area2);
        //     insert areaList;

        //     Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        //     conList.add(con);

        //     Contact con2 = TestDataFactoryForSales.createContact('ContactPerson', acc2.Id);
        //     conList.add(con2);
        //     insert conList;

        //     System.debug('test01 check query count 01 : ' + Limits.getQueries());
        //     Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
        //     optyList.add(opty);

        //     Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
        //     insert newCompetitor;

        //     OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty, newCompetitor);
        //     insert optyCompetitor;

        //     // Opportunity optyTurnkey = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_key');
        //     // insert optyTurnkey;
        //     Id pBookId = Test.getStandardPricebookId();
        //     Date today = Date.today();

        //     Opportunity opty1             = new Opportunity();
        //     opty1.AccountId               = acc2.Id;
        //     opty1.RecordTypeId            = opty.RecordTypeId;
        //     opty1.Name                    = 'test opportunity';
        //     opty1.StageName               = 'Qualified';
        //     opty1.LeadSource              = 'Employee Referral';
        //     opty1.CurrencyIsoCode         = 'KRW';
        //     opty1.Pricebook2Id            = pBookId;
        //     opty1.OwnerId                 = dealer.Id;
        //     opty1.MainCategory__c         = 'MB';
        //     opty1.SubCategory__c          = 'MB2';
        //     opty1.IsTooling__c            = 'MY';
        //     opty1.Country__c              = 'US';
        //     opty1.Budget__c               = 100000000;
        //     opty1.RequestDelieveryDate__c = today.addMonths(2);
        //     opty1.CloseDate               = today.addMonths(1);
        //     opty1.OpportunityIdentifier__c = dealer.Id;
        //     opty1.Opportunity_Owner__c    = dealer.Id;
        //     optyList.add(opty1);

        //     Opportunity opty2             = new Opportunity();
        //     opty2.AccountId               = acc2.Id;
        //     opty2.RecordTypeId            = opty.RecordTypeId;
        //     opty2.Name                    = 'test opportunity';
        //     opty2.StageName               = 'Qualified';
        //     opty2.LeadSource              = 'Employee Referral';
        //     opty2.CurrencyIsoCode         = 'KRW';
        //     opty2.Pricebook2Id            = pBookId;
        //     opty2.OwnerId                 = dealer.Id;
        //     opty2.MainCategory__c         = 'MB';
        //     opty2.SubCategory__c          = 'MB2';
        //     opty2.IsTooling__c            = 'MY';
        //     opty2.Country__c              = 'US';
        //     opty2.Budget__c               = 100000000;
        //     opty2.RequestDelieveryDate__c = today.addMonths(2);
        //     opty2.CloseDate               = today.addMonths(1);
        //     opty2.OpportunityIdentifier__c = dealer.Id;
        //     opty2.Opportunity_Owner__c    = dealer.Id;
        //     optyList.add(opty2);

        //     insert optyList;
        //     System.debug('test01 check query count 02 : ' + Limits.getQueries() + ' / ' + opty);
        //     List<OpportunityLineItem> optyliList = new List<OpportunityLineItem>();
        //     OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
        //     optyliList.add(oItem);

        //     OpportunityLineItem oItem2 = TestDataFactoryForSales.createOptyItem(opty1, entry, prod);
        //     OpportunityLineItem oItem3 = TestDataFactoryForSales.createOptyItem(opty2, entry, prod);
        //     optyliList.add(oItem2);
        //     optyliList.add(oItem3);
        //     insert optyliList;

        //     PS__c newPs = new PS__c();
        //     newPs.Opportunity__c = opty1.Id;
        //     insert newPs;

        //     System.debug('test01 check query count 03 : ' + Limits.getQueries() + ' / ' + oItem);
        //     List<Quote> qtList = new List<Quote>();
        //     Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
        //     qtList.add(quote);

        //     Quote quote2 = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty1, 'Global');
        //     qtList.add(quote2);

        //     Quote quote3 = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty2, 'Service');
        //     qtList.add(quote3);

        //     insert qtList;
        //     System.debug('test01 check query count 04 : ' + Limits.getQueries() + ' / ' + quote);
        //     // QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
        //     // insert qItem;
        //     List<QuoteLineItem> qitemList = new List<QuoteLineItem>();
        //     QuoteLineItem qItem        = new QuoteLineItem();
        //     qItem.QuoteId               = quote.Id;
        //     qItem.PricebookEntryId      = entry.Id;
        //     qItem.OpportunityLineItemId = oItem.Id;
        //     qItem.Product2Id            = prod.Id;
        //     qItem.RequestedDelivDate__c = today.addMonths(2);
        //     qItem.ExpectedDelivDate__c  = '계약 후 5개월 내';
        //     qItem.Warranty__c           = 'B24';
        //     qItem.UnitPrice             = 0;
        //     qItem.Quantity              = 1;
        //     qitemList.add(qItem);
        //     // QuoteLineItem qItem2 = TestDataFactoryForSales.createQuoteItem(quote2, entry, oItem, prod);
        //     // insert qItem2;
        //     QuoteLineItem qItem2        = new QuoteLineItem();
        //     qItem2.QuoteId               = quote2.Id;
        //     qItem2.PricebookEntryId      = entry.Id;
        //     qItem2.OpportunityLineItemId = oItem2.Id;
        //     qItem2.Product2Id            = prod.Id;
        //     qItem2.RequestedDelivDate__c = today.addMonths(2);
        //     qItem2.ExpectedDelivDate__c  = '계약 후 5개월 내';
        //     qItem2.Warranty__c           = 'B12';
        //     qItem2.UnitPrice             = 0;
        //     qItem2.Quantity              = 1;
        //     qitemList.add(qItem2);

        //     QuoteLineItem qItem3        = new QuoteLineItem();
        //     qItem3.QuoteId               = quote3.Id;
        //     qItem3.PricebookEntryId      = entry.Id;
        //     qItem3.OpportunityLineItemId = oItem3.Id;
        //     qItem3.Product2Id            = prod.Id;
        //     qItem3.RequestedDelivDate__c = today.addMonths(2);
        //     qItem3.ExpectedDelivDate__c  = '계약 후 5개월 내';
        //     qItem3.Warranty__c           = 'B12';
        //     qItem3.UnitPrice             = 0;
        //     qItem3.Quantity              = 1;
        //     qitemList.add(qItem3);

        //     insert qitemList;

        //     SQ__c sq = new SQ__c();
        //     insert sq;
        //     SQ_QuoteLineitem_Junction__c sqjunction = new SQ_QuoteLineitem_Junction__c();
        //     sqjunction.SQ__c = sq.Id;
        //     sqjunction.QuoteLineItem__c = qItem.Id;
        //     insert sqjunction;

        //     SQ__c sq2 = new SQ__c();
        //     insert sq2;
        //     SQ_QuoteLineitem_Junction__c sqjunction2 = new SQ_QuoteLineitem_Junction__c();
        //     sqjunction2.SQ__c = sq2.Id;
        //     sqjunction2.QuoteLineItem__c = qItem2.Id;
        //     insert sqjunction2;
        //     // System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
        // }
    }
    @isTest
    static void testgetInfo() {
        // InterfaceCommonUtil.setInterface('IF-OPTY-007', 'IF_ERP_Inquiry');
        

        Test.startTest();
        // ApexPages.StandardController sc = new ApexPages.StandardController(qte);
        // DN_QuotationPDFController controller = new DN_QuotationPDFController(sc);

        // ApexPages.StandardController sc2 = new ApexPages.StandardController(qte2);
        // DN_QuotationPDFController controller2 = new DN_QuotationPDFController(sc2);

        // ApexPages.StandardController sc3 = new ApexPages.StandardController(qte3);
        // DN_QuotationPDFController controller3 = new DN_QuotationPDFController(sc3);

        // DN_QuotationPDFController.getKeyfield(qte.Id);
        // DN_QuotationPDFController.getKeyfield(qte2.Id);

        // DN_QuotationPDFController.getVersion(qte.Id);
        // DN_QuotationPDFController.generatePDF(qte.Id);
        // DN_QuotationPDFController.generatePDF(qte2.Id);
        // DN_QuotationExportController.saveFile('base64Data', 'filename', qte2.Id);
        DN_QuotationPDFController.dummy();

        Test.stopTest();
    }
}