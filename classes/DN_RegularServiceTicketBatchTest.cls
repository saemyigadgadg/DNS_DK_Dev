/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 06-12-2025
 * @last modified by  : JangJunHee
**/
@isTest
public with sharing class DN_RegularServiceTicketBatchTest {
    @isTest
    static void testBatch() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        RecordType product_recordType = TestDataFactoryForSales.getRecordType('ServicePackage', 'Product2');

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert dealer;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        prod.RecordTypeId = product_recordType.Id;
        prod.Field2__c = '1개월;2개월;3개월;4개월;';
        prod.OilChangeCycle__c = '1개월;2개월;3개월;4개월;';
        prod.StandardDay__c = '설치일';
        prod.IsActive = true;
        prod.ServicePackage__c = '각종 오일 교체';
        prod.StandardOilDay__c = '설치일';
        insert prod;
        // Product2 prod2 = TestDataFactoryForSales.createProduct();
        // prod.RecordTypeId = product_recordType.Id;
        // prod2.Field2__c = '1개월;2개월;3개월;4개월;';
        // prod2.OilChangeCycle__c = '1개월;2개월;3개월;4개월;';
        // prod2.StandardDay__c = '판매일';
        // prod2.IsActive = true;
        // insert prod2;
        // Product2 prod3 = TestDataFactoryForSales.createProduct();
        // prod.RecordTypeId = product_recordType.Id;
        // prod3.Field2__c = '1개월;2개월;3개월;4개월;';
        // prod3.OilChangeCycle__c = '1개월;2개월;3개월;4개월;';
        // prod3.StandardDay__c = '지정일';
        // prod3.SelectDay__c = Date.newInstance(2025, 3, 3);
        // prod3.IsActive = true;
        // insert prod3;

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;
    
            PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
            insert entry;    

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForService.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            Order order = TestDataFactoryForService.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.CreatedDate = Date.newInstance(2025, 1, 22);
            insert order;

            Asset as1 = TestDataFactoryForService.createAsset(acc.Id);
            as1.Order__c = order.Id;
            as1.InstallationFinish__c = Date.newInstance(2025, 5, 22);
            insert as1;           

            ServicePackageProduct__c spp1 = new ServicePackageProduct__c();
            spp1.Name = 'SPP Test 1';
            spp1.Equipments__c = as1.Id;
            spp1.Product__c = prod.Id;
            spp1.Order__c = order.Id;
            insert spp1;
    
            // ServicePackageProduct__c spp2 = new ServicePackageProduct__c();
            // spp2.Name = 'SPP Test 2';
            // spp2.Equipments__c = as1.Id;
            // spp2.Product__c = prod2.Id;
            // spp2.Order__c = order.Id;
            // insert spp2;

            // ServicePackageProduct__c spp3 = new ServicePackageProduct__c();
            // spp3.Name = 'SPP Test 3';
            // spp3.Equipments__c = as1.Id;
            // spp3.Product__c = prod3.Id;
            // spp3.Order__c = order.Id;
            // insert spp3;

            Campaign cpp = new Campaign(Name = 'Campaign Test', IsActive = true, RegularServiceType__c = 'General Regular Service', CampaignType__c = 'RegularInspections');
            insert cpp;            
        }

        Test.startTest();
        System.schedule('Test Scheduled Batch', '0 0 0 * * ?', new DN_RegularServiceTicketBatch());
        Database.ExecuteBatch(new DN_RegularServiceTicketBatch());
        Test.stopTest();
    }

    @isTest
    static void testBatch2() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        RecordType product_recordType = TestDataFactoryForSales.getRecordType('ServicePackage', 'Product2');

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert dealer;
        }

        // Product2 prod = TestDataFactoryForSales.createProduct();
        // prod.RecordTypeId = product_recordType.Id;
        // prod.Field2__c = '1개월;2개월;3개월;4개월;';
        // prod.OilChangeCycle__c = '1개월;2개월;3개월;4개월;';
        // prod.StandardDay__c = '설치일';
        // prod.IsActive = true;
        // insert prod;
        Product2 prod2 = TestDataFactoryForSales.createProduct();
        prod2.RecordTypeId = product_recordType.Id;
        prod2.Field2__c = '1개월;2개월;3개월;4개월;';
        prod2.OilChangeCycle__c = '1개월;2개월;3개월;4개월;';
        prod2.StandardDay__c = '판매일';
        prod2.IsActive = true;
        prod2.ServicePackage__c = '각종 오일 교체';
        prod2.StandardOilDay__c = '판매일';
        insert prod2;
        // Product2 prod3 = TestDataFactoryForSales.createProduct();
        // prod.RecordTypeId = product_recordType.Id;
        // prod3.Field2__c = '1개월;2개월;3개월;4개월;';
        // prod3.OilChangeCycle__c = '1개월;2개월;3개월;4개월;';
        // prod3.StandardDay__c = '지정일';
        // prod3.SelectDay__c = Date.newInstance(2025, 3, 3);
        // prod3.IsActive = true;
        // insert prod3;

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;
    
            PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod2, 'KRW');
            insert entry;    

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod2);
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForService.createQuoteItem(quote, entry, oItem, prod2);
            insert qItem;

            Order order = TestDataFactoryForService.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.CreatedDate = Date.newInstance(2025, 1, 22);
            insert order;

            Asset as1 = TestDataFactoryForService.createAsset(acc.Id);
            as1.Order__c = order.Id;
            insert as1;           

            // ServicePackageProduct__c spp1 = new ServicePackageProduct__c();
            // spp1.Name = 'SPP Test 1';
            // spp1.Equipments__c = as1.Id;
            // spp1.Product__c = prod.Id;
            // spp1.Order__c = order.Id;
            // insert spp1;
    
            ServicePackageProduct__c spp2 = new ServicePackageProduct__c();
            spp2.Name = 'SPP Test 2';
            spp2.Equipments__c = as1.Id;
            spp2.Product__c = prod2.Id;
            spp2.Order__c = order.Id;
            insert spp2;

            // ServicePackageProduct__c spp3 = new ServicePackageProduct__c();
            // spp3.Name = 'SPP Test 3';
            // spp3.Equipments__c = as1.Id;
            // spp3.Product__c = prod3.Id;
            // spp3.Order__c = order.Id;
            // insert spp3;

            Campaign cpp = new Campaign(Name = 'Campaign Test', IsActive = true, RegularServiceType__c = 'General Regular Service', CampaignType__c = 'RegularInspections');
            insert cpp;            
        }

        Test.startTest();
        System.schedule('Test Scheduled Batch', '0 0 0 * * ?', new DN_RegularServiceTicketBatch());
        Database.ExecuteBatch(new DN_RegularServiceTicketBatch());
        Test.stopTest();
    }

    @isTest
    static void testBatch3() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        RecordType product_recordType = TestDataFactoryForSales.getRecordType('ServicePackage', 'Product2');

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert dealer;
        }

        // Product2 prod = TestDataFactoryForSales.createProduct();
        // prod.RecordTypeId = product_recordType.Id;
        // prod.Field2__c = '1개월;2개월;3개월;4개월;';
        // prod.OilChangeCycle__c = '1개월;2개월;3개월;4개월;';
        // prod.StandardDay__c = '설치일';
        // prod.IsActive = true;
        // insert prod;
        // Product2 prod2 = TestDataFactoryForSales.createProduct();
        // prod2.RecordTypeId = product_recordType.Id;
        // prod2.Field2__c = '1개월;2개월;3개월;4개월;';
        // prod2.OilChangeCycle__c = '1개월;2개월;3개월;4개월;';
        // prod2.StandardDay__c = '판매일';
        // prod2.IsActive = true;
        // insert prod2;
        Product2 prod3 = TestDataFactoryForSales.createProduct();
        prod3.RecordTypeId = product_recordType.Id;
        prod3.Field2__c = '1개월;2개월;3개월;4개월;';
        prod3.OilChangeCycle__c = '1개월;2개월;3개월;4개월;';
        prod3.StandardDay__c = '지정일';
        prod3.SelectDay__c = Date.newInstance(2025, 3, 3);
        prod3.IsActive = true;
        prod3.ServicePackage__c = '각종 오일 교체';
        prod3.StandardOilDay__c = '지정일';
        insert prod3;

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;
    
            PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod3, 'KRW');
            insert entry;    

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod3);
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForService.createQuoteItem(quote, entry, oItem, prod3);
            insert qItem;

            Order order = TestDataFactoryForService.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.CreatedDate = Date.newInstance(2025, 1, 22);
            order.SelectDay__c = Date.newInstance(2025, 2, 22);
            order.LastOilChangeTime__c = Date.newInstance(2025, 2, 22);
            insert order;

            Asset as1 = TestDataFactoryForService.createAsset(acc.Id);
            as1.Order__c = order.Id;
            insert as1;           

            // ServicePackageProduct__c spp1 = new ServicePackageProduct__c();
            // spp1.Name = 'SPP Test 1';
            // spp1.Equipments__c = as1.Id;
            // spp1.Product__c = prod.Id;
            // spp1.Order__c = order.Id;
            // insert spp1;
    
            // ServicePackageProduct__c spp2 = new ServicePackageProduct__c();
            // spp2.Name = 'SPP Test 2';
            // spp2.Equipments__c = as1.Id;
            // spp2.Product__c = prod2.Id;
            // spp2.Order__c = order.Id;
            // insert spp2;

            ServicePackageProduct__c spp3 = new ServicePackageProduct__c();
            spp3.Name = 'SPP Test 3';
            spp3.Equipments__c = as1.Id;
            spp3.Product__c = prod3.Id;
            spp3.Order__c = order.Id;
            insert spp3;

            Campaign cpp = new Campaign(Name = 'Campaign Test', IsActive = true, RegularServiceType__c = 'General Regular Service', CampaignType__c = 'RegularInspections');
            insert cpp;            
        }

        Test.startTest();
        System.schedule('Test Scheduled Batch', '0 0 0 * * ?', new DN_RegularServiceTicketBatch());
        Database.ExecuteBatch(new DN_RegularServiceTicketBatch());
        Test.stopTest();
    }

}