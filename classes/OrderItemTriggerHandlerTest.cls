@isTest
public with sharing class OrderItemTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
        
        TestDataFactoryForSales.activatePriceBook();

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.SalesDistrict__c = 'M3UL';
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;

            User kaUser = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert kaUser;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        List<Warranty__c> warrantyList = TestDataFactoryForSales.getWarranty();
        insert warrantyList;

        Set<String> bypassSet = new Set<String>{'OrderTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'AccountTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        System.runAs(dealer) {

            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;
    
            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;
    
            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;
    
            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;
    
            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;
    
            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            insert order;

            Quote dnsaQuote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
            insert dnsaQuote;

            QuoteLineItem dnsaQItem = TestDataFactoryForSales.createQuoteItem(dnsaQuote, entry, oItem, prod);
            insert dnsaQItem;

            Order dnsaOrder = TestDataFactoryForSales.createDNSAOrder(acc, opty, dnsaQuote, dealer);
            insert dnsaOrder;
        }
    }

    @isTest
    static void testDealer(){

        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry entry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id LIMIT 1];
        QuoteLineItem qItem = [SELECT Id FROM QuoteLineItem WHERE Product2Id =:prod.Id LIMIT 1];
        Order order = [SELECT Id FROM Order WHERE RecordType.Name = 'DNS' LIMIT 1];
        
        Test.startTest();

        OrderItem oItemProd;
        System.runAs(dealer) {

            oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            oItemProd.IsInspection__c = true;
            oItemProd.BillingDate__c  = Date.today();
            insert oItemProd;

            TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};
            order.IsBilled__c = 'N';
            update order;
            TriggerHandler.bypassedHandlers = new Set<String>();

            oItemProd.IF_FreePass__c = true;
            oItemProd.BillingDate__c = null;
            update oItemProd;

            oItemProd.IF_FreePass__c = true;
            oItemProd.BillingDate__c  = Date.today();
            update oItemProd;

            try {
                oItemProd.IF_FreePass__c = false;
                update oItemProd;
            } catch (Exception e) {
                System.debug('ERROR01 ::: ' + e.getMessage());
            }

            try {
                delete oItemProd;
            } catch (Exception e) {
                System.debug('ERROR02 ::: ' + e.getMessage());
            }
            
        }

        delete oItemProd;


        Test.stopTest();
    }

    @isTest
    static void testDNSA(){

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry entry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id LIMIT 1];
        QuoteLineItem qItem = [SELECT Id FROM QuoteLineItem WHERE Product2Id =:prod.Id AND Quote_RecordType__c = 'DNSA Commodity' LIMIT 1];
        Order order = [SELECT Id FROM Order WHERE RecordType.Name = 'DNSA' LIMIT 1];
        order.MachinePartsWarranty__c = 'S24';
        update order;
        System.debug('testDNSA - order ::: ' + order);

        Test.startTest();

        System.runAs(dealer) {
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            oItemProd.IsInspection__c = true;
            oItemProd.BillingDate__c  = Date.today();
            insert oItemProd;
        }

        Test.stopTest();
    }
}