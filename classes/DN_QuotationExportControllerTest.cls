@isTest
public with sharing class DN_QuotationExportControllerTest {
    @TestSetup
    static void makeData(){

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

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'ContactTriggerHandler', 'QuoteTriggerHandler', 'OpportunityLineItemTriggerHandler', 'PSTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        User dealer2;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAccList.add(dealerAcc);
    
            // Account dealerAcc2 = TestDataFactoryForSales.createAccount('Dealer', country2, null);
            // insert dealerAcc2;

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
            acc.ShippingStreet    = 'test';
            acc.ShippingState     = 'test';
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

            Opportunity opty2 = TestDataFactoryForSales.createDNSDomesticOpty(acc2, dealer, 'General');
            optyList.add(opty2);

            Opportunity opty3 = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            optyList.add(opty3);

            insert optyList;

            Competitor__c newCompetitor = TestDataFactoryForSales.createCompetitor();
            insert newCompetitor;

            OpptyCompetitorMapping__c optyCompetitor = TestDataFactoryForSales.createOpptyCompetitorMapping(opty, newCompetitor);
            insert optyCompetitor;

            Id pBookId = Test.getStandardPricebookId();
            Date today = Date.today();

            List<OpportunityLineItem> optyliList = new List<OpportunityLineItem>();

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            optyliList.add(oItem);

            OpportunityLineItem oItem2 = TestDataFactoryForSales.createOptyItem(opty2, entry, prod);
            optyliList.add(oItem2);

            OpportunityLineItem oItem3 = TestDataFactoryForSales.createOptyItem(opty3, entry, prod);
            optyliList.add(oItem3);

            insert optyliList;

            PS__c newPs = new PS__c();
            newPs.Opportunity__c = opty2.Id;
            insert newPs;

            List<Quote> qtList = new List<Quote>();
            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            qtList.add(quote);

            Quote quote2 = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty2, 'Global');
            qtList.add(quote2);

            Quote quote3 = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty3, 'DNSA_Factory');
            qtList.add(quote3);

            insert qtList;

            // insert qItem;
            List<QuoteLineItem> qitemList = new List<QuoteLineItem>();
            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            qItem.Warranty__c = 'B24';
            qitemList.add(qItem);

            QuoteLineItem qItem_1 = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            qItem_1.Warranty__c = 'B24';
            qitemList.add(qItem_1);

            QuoteLineItem qItem_2 = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            qItem_2.Warranty__c = 'B24';
            qitemList.add(qItem_2);

            QuoteLineItem qItem2 = TestDataFactoryForSales.createQuoteItem(quote2, entry, oItem2, prod);
            qItem.Warranty__c = 'B12';
            qItem2.Adjustment_Price__c = 1000;
            qItem2.UnitPrice = 1000;
            qitemList.add(qItem2);

            QuoteLineItem qItem3 = TestDataFactoryForSales.createQuoteItem(quote3, entry, oItem3, prod);
            qItem.Warranty__c = 'M18';
            qitemList.add(qItem3);

            insert qitemList;

            SQ__c sq = new SQ__c();
            insert sq;
            SQ_QuoteLineitem_Junction__c sqjunction = new SQ_QuoteLineitem_Junction__c();
            sqjunction.SQ__c = sq.Id;
            sqjunction.QuoteLineItem__c = qItem.Id;
            insert sqjunction;

            SQ__c sq2 = new SQ__c();
            insert sq2;
            SQ_QuoteLineitem_Junction__c sqjunction2 = new SQ_QuoteLineitem_Junction__c();
            sqjunction2.SQ__c = sq2.Id;
            sqjunction2.QuoteLineItem__c = qItem2.Id;
            sqjunction2.SalesPrice__c = 1000;
            insert sqjunction2;

            Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
            insert accessory;

            Accessory__c accessory2 = TestDataFactoryForSales.createAccessory(qItem2.Id, null);
            accessory2.Price__c = null;
            insert accessory2;

            CharacteristicValue__c cv = TestDataFactoryForSales.createCV(qItem.Id, null, null);
            insert cv;

            CharacteristicValue__c cv2 = TestDataFactoryForSales.createCV(qItem2.Id, null, null);
            insert cv2;
            
        }
    }
    @isTest
    static void testgetInfo() {
        InterfaceCommonUtil.setInterface('IF-OPTY-007', 'IF_ERP_Inquiry');

        Quote qte = [SELECT Id FROM Quote WHERE RecordType.DeveloperName = 'Korea' LIMIT 1];
        Quote qte2 = [SELECT Id FROM Quote WHERE RecordType.DeveloperName = 'Global' LIMIT 1];
        Quote qte3 = [SELECT Id FROM Quote WHERE RecordType.DeveloperName = 'DNSA_Factory' LIMIT 1];
        
        Test.startTest();
        DN_QuotationExportController.getInfo(qte.Id);
        DN_QuotationExportController.getInfo(qte2.Id);
        DN_QuotationExportController.getInfo(qte3.Id);

        DN_QuotationExportController.saveFile('base64Data', 'filename', qte2.Id);

        Test.stopTest();
    }

    // @isTest
    // static void testGetStaticResourceBody_KR() {
    //     QuoteLineItem qItem = [SELECT Id FROM QuoteLineItem LIMIT 1];
        
    //     Test.startTest();
    //     DN_QuotationExportController.getStaticResourceBody_KR(qItem.Id);
    //     Test.stopTest();
    // }

    @isTest
    static void testGetStaticResourceBody_EN() {
        QuoteLineItem qItem = [SELECT Id FROM QuoteLineItem LIMIT 1];
        
        Test.startTest();
        DN_QuotationExportController.getStaticResourceBody_EN();
        Test.stopTest();
    }
}