@isTest
public with sharing class DN_Order_CreateControllerTest {
    
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
        
        TestDataFactoryForSales.activatePriceBook();

        User dealer;
        Account dealerAcc;
        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
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

            SQRegistration__c sqReg = TestDataFactoryForSales.createSQReg(opty.Id, prod.Id, acc.Id, dealer.Id, dealerAcc.Id);
            insert sqReg;

            SQ__c sq = TestDataFactoryForSales.createSQ(sqReg.Id, 20);
            insert sq;

            Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, 30);
            insert accessory;

            SQ_QuoteLineitem_Junction__c sqJunction = new SQ_QuoteLineitem_Junction__c();
            sqJunction.QuoteLineItem__c = qItem.Id;
            sqJunction.SQ__c            = sq.Id;
            insert sqJunction;
        }
    }

    @IsTest
    static void fetchInitTest(){

        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        QuoteLineItem qItem = [SELECT Id FROM QuoteLineItem LIMIT 1];
        
        Test.startTest();

        DN_Order_CreateController.fetchInit(quote.Id, new List<String>{qItem.Id});

        try {
            DN_Order_CreateController.fetchInit(quote.Id, null);
        } catch (Exception e) {
            System.debug('fetchInitTest error : ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void getAccountAddressTest(){

        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();

        DN_Order_CreateController.getAccountAddress(new List<String>{acc.Id});
        try {
            DN_Order_CreateController.getAccountAddress(null);
        } catch (Exception e) {
            System.debug('getAccountAddress error : ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void saveOrdersTest(){

        User dealer         = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Account acc         = [SELECT Id, SalesOffice__c, OwnerId, RecordType.DeveloperName FROM Account WHERE CustomerCode__c = '123456' LIMIT 1]; 
        Quote quote         = [SELECT Id, CurrencyIsoCode FROM Quote WHERE RecordType.name = 'Korea' LIMIT 1];
        Opportunity opty    = [SELECT Id FROM Opportunity LIMIT 1];
        QuoteLineItem qItem = [
            SELECT  Id
                    , OpportunityLineItemId
                    , Product2Id
                    , Product2.Name
                    , Product2.Name__c
                    , Product2.IsStrategicMaterial__c
                    , UnitPrice
                    , CV_Total__c
                    , SQ_Total__c
                    , Accessory_Total__c
                    , DC__c
                    , DC_Price__c
                    , Dealer_Price__c
                    , Adjustment_Price__c
                    , Warranty__c
                    , Warranty_Price__c
                    , Final_Quotation_Price__c
                    , RequestedDelivDate__c
            FROM    QuoteLineItem 
            LIMIT 1
        ];
        
        Test.startTest();

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};
        
        Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');

        DN_Order_CreateController.ProductWrapper prodWrap = new DN_Order_CreateController.ProductWrapper(qItem);

        DN_Order_CreateController.saveOrders(order, new List<DN_Order_CreateController.ProductWrapper>{prodWrap});
        try {
            DN_Order_CreateController.saveOrders(order, null);
        } catch (Exception e) {
            System.debug('saveOrdersTest error : ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void getSalesAreaDataTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();

        DN_Order_CreateController.getSalesAreaData(acc.Id);
        try {
            DN_Order_CreateController.getSalesAreaData(null);
        } catch (Exception e) {
            System.debug('getSalesAreaDataTest error : ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void getDefalutValuesTest(){
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        Test.startTest();

        DN_Order_CreateController.getDefalutValues(q.Id);
        try {
            DN_Order_CreateController.getDefalutValues(null);
        } catch (Exception e) {
            System.debug('getDefalutValuesTest error : ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void getQuoteLineItemInfoTest(){
        
        Test.startTest();

        QuoteLineItem qItem = [SELECT Id, Order__c, CVComplete__c FROM QuoteLineItem LIMIT 1];
        qItem.CVComplete__c = true;
        update qItem;
        System.debug('qItem ::: ' + qItem);

        DN_Order_CreateController.getQuoteLineItemInfo(new List<String>{qItem.Id}, 'Overseas');
        try {
            DN_Order_CreateController.getQuoteLineItemInfo(null, 'Overseas');
        } catch (Exception e) {
            System.debug('getQuoteLineItemInfoTest error : ' + e.getMessage());
        }

        Test.stopTest();
    }
}