@isTest
public with sharing class OrderTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('test01 - thisUser ::: ' + thisUser);

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler', 'QuoteTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
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

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderKeyAccountCreated'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderStatusConfirmed'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderCanceled'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalApproved'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalRejected'));
        insert alertList;

        Asset asset = TestDataFactoryForSales.createAsset();
        insert asset;

        System.runAs(dealer) {
            Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
            insert parentAcc;

            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            insert area;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;

            System.debug('test01 check query count 01 : ' + Limits.getQueries());
            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            System.debug('test01 check query count 02 : ' + Limits.getQueries() + ' / ' + opty);
            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            System.debug('test01 check query count 03 : ' + Limits.getQueries() + ' / ' + oItem);
            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            System.debug('test01 check query count 04 : ' + Limits.getQueries() + ' / ' + quote);
            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            System.debug('test01 check query count 05 : ' + Limits.getQueries() + ' / ' + qItem);
            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;

            System.debug('test01 check query count 06 : ' + Limits.getQueries() + ' / ' + sq);
            Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
            insert accessory;

            Quote dnsaQuote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
            insert dnsaQuote;

            QuoteLineItem dnsaQItem = TestDataFactoryForSales.createQuoteItem(dnsaQuote, entry, oItem, prod);
            insert dnsaQItem;
        }

    }

    @isTest
    static void testInsert() {
        System.debug('testInsert is Started.');
        Test.startTest();

        User dealer      = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Account acc      = [SELECT Id, SalesOffice__c, OwnerId, RecordType.DeveloperName FROM Account WHERE CustomerCode__c = '123456' LIMIT 1]; 
        Quote quote      = [SELECT Id, CurrencyIsoCode FROM Quote WHERE RecordType.name = 'Korea' LIMIT 1];
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];

        System.runAs(dealer) {
            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            insert order;
        }

        Test.stopTest();
        System.debug('testInsert is ended.');
    }

    @isTest
    static void testUpdate01() {
        System.debug('testUpdate01 is Started.');
        Test.startTest();
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Country__c country = [SELECT Id FROM Country__c LIMIT 1];
        Account acc = [SELECT Id, SalesOffice__c, OwnerId, RecordType.DeveloperName FROM Account WHERE CustomerCode__c = '123456' LIMIT 1]; 
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry entry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id LIMIT 1];
        Asset asset = [SELECT Id, SerialNumber FROM Asset LIMIT 1];
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];
        Quote quote = [SELECT Id, CurrencyIsoCode FROM Quote WHERE RecordType.name = 'Korea' LIMIT 1];
        QuoteLineItem qItem = [SELECT Id FROM QuoteLineItem WHERE Product2Id =:prod.Id AND QuoteId =: quote.Id LIMIT 1];
        SQ__c sq = [SELECT Id FROM SQ__c LIMIT 1];
        Accessory__c accessory = [SELECT Id FROM Accessory__c LIMIT 1];
        
        System.runAs(dealer) {
            Set<String> bypassSet = new Set<String>{'OrderTriggerHandler', 'OrderItemTriggerHandler', 'AccountTriggerHandler'};
            TriggerHandler.bypassedHandlers = bypassSet; // pass the other triggers

            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            insert order;

            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            OrderItem oItemSQ = TestDataFactoryForSales.createOrderSQ(order.Id, prod.Id, entry.Id, qItem.Id, sq.Id, '000020');
            insert oItemSQ;

            OrderItem oItemAccessory = TestDataFactoryForSales.createOrderAccessory(order.Id, prod.Id, entry.Id, qItem.Id, accessory.Id, '000030');
            insert oItemAccessory;

            Account toChangeAcc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            toChangeAcc.CustomerCode__c   = '123458';
            toChangeAcc.BusinessNumber__c = '5148171775';
            toChangeAcc.Representative__c = 'cAcc';
            insert toChangeAcc;

            TriggerHandler.bypassedHandlers = new Set<String>();

            // alertOrderConfirmed, changeAddress, changeSoldTo
            order.IF_IsERPConfirmed__c = true;
            order.SoldTo__c            = toChangeAcc.Id;
            order.ShipTo__c            = toChangeAcc.Id;
            order.OrderSegmentation__c = 'Consignment';
            update order;

            // handleOrderStatus, updateItemKey
            order.ERPOrderNo__c   = '0100472733';
            order.ERPPSONo__c     = '0201932032';
            order.SerialNumber__c = asset.SerialNumber;
            update order;

            
        }

        
        Test.stopTest();
        System.debug('testUpdate01 is ended.');
    }

    @isTest
    static void testUpdate02() {
        System.debug('testUpdate02 is Started.');
        Test.startTest();
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Country__c country = [SELECT Id FROM Country__c LIMIT 1];
        Account acc = [SELECT Id, SalesOffice__c, OwnerId, RecordType.DeveloperName FROM Account WHERE CustomerCode__c = '123456' LIMIT 1]; 
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry entry = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id LIMIT 1];
        Asset asset = [SELECT Id, SerialNumber FROM Asset LIMIT 1];
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];
        Quote quote = [SELECT Id, CurrencyIsoCode FROM Quote WHERE RecordType.name = 'Korea' LIMIT 1];
        QuoteLineItem qItem = [SELECT Id FROM QuoteLineItem WHERE Product2Id =:prod.Id AND QuoteId =: quote.Id LIMIT 1];
        SQ__c sq = [SELECT Id FROM SQ__c LIMIT 1];
        Accessory__c accessory = [SELECT Id FROM Accessory__c LIMIT 1];
        
        Order order;
        System.runAs(dealer) {
            Set<String> bypassSet = new Set<String>{'OrderTriggerHandler', 'OrderItemTriggerHandler', 'AccountTriggerHandler'};
            TriggerHandler.bypassedHandlers = bypassSet; // pass the other triggers

            order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            insert order;

            TriggerHandler.bypassedHandlers = new Set<String>();

            // handleOrderCanceled
            order.IsOrderDeleted__c = true;
            update order;

        }
        // syncDealerOrder
        System.debug('test01 ::: syncDealerOrder ' + dealer.Id + ' / ' + UserInfo.getUserId());
        order.OwnerId = UserInfo.getUserId();
        update order;

        Test.stopTest();
        System.debug('testUpdate02 is ended.');
    }

    @isTest
    static void testDelete() {
        System.debug('testDelete is Started.');
        Test.startTest();

        User dealer      = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Account acc      = [SELECT Id, SalesOffice__c, OwnerId, RecordType.DeveloperName FROM Account WHERE CustomerCode__c = '123456' LIMIT 1]; 
        Quote quote      = [SELECT Id, CurrencyIsoCode FROM Quote WHERE RecordType.name = 'Korea' LIMIT 1];
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];

        
        System.runAs(dealer) {
            Set<String> bypassSet = new Set<String>{'OrderTriggerHandler'};
            TriggerHandler.bypassedHandlers = bypassSet; // pass insert again

            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            insert order;

            TriggerHandler.bypassedHandlers = new Set<String>();

            delete order;
        }
        
        Test.stopTest();
        System.debug('testDelete is ended.');
    }

    @isTest
    static void testService() {
        System.debug('testService is Started.');
        Test.startTest();

        User dealer      = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Account acc      = [SELECT Id, SalesOffice__c, OwnerId, RecordType.DeveloperName FROM Account WHERE CustomerCode__c = '123456' LIMIT 1]; 
        Quote quote      = [SELECT Id, CurrencyIsoCode FROM Quote WHERE RecordType.name = 'Korea' LIMIT 1];
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];

        
        System.runAs(dealer) {

            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'Service');
            order.SalesChannelType__c  = 'Domestic';
            order.OrderSegmentation__c = 'DirectSales';
            insert order;

        }
        
        Test.stopTest();
        System.debug('testService is ended.');
    }

    @isTest
    static void testDNSA() {
        System.debug('testDNSA is Started.');
        User dealer      = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Account acc      = [SELECT Id, SalesOffice__c, OwnerId, RecordType.DeveloperName FROM Account WHERE CustomerCode__c = '123456' LIMIT 1]; 
        Quote dnsaQuote  = [SELECT Id, CurrencyIsoCode FROM Quote WHERE RecordType.DeveloperName = 'DNSA_Commodity' LIMIT 1];
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();

        TriggerHandler.bypassedHandlers = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler'};

        opty.Country__c = 'US';
        update opty;

        System.runAs(dealer) {
            Order dnsaOrder = TestDataFactoryForSales.createDNSAOrder(acc, opty, dnsaQuote, dealer);
            insert dnsaOrder;

            dnsaOrder.MachinePartsWarranty__c = 'S24';
            update dnsaOrder;
        }

        Test.stopTest();
        System.debug('testDNSA is ended.');
    }
}