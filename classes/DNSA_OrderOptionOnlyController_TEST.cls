/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-05-27
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-02-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class DNSA_OrderOptionOnlyController_TEST {
   
    @testSetup
    static void setupTestData() {
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
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        System.runAs(dealer) {
            Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
            insert parentAcc;

            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
            acc.CustomerCode__c   = 'CUST001';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            insert area;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            oItem.ERPInquiryNo__c = '0600203414';
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Factory');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            qItem.ERPQuotationNo__c = '0701069991';
            insert qItem;

            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;

            Order order = TestDataFactoryForSales.createDNSAOrder(acc, opty, quote, dealer);
            insert order;

            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;
        }
    }

    @isTest
    static void testFetchInit() {
        Order order = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        DNSA_OrderOptionOnlyController.fetchInit(order.Id);

        order.OrderType__c = 'ZUSO';
        update order;

        DNSA_OrderOptionOnlyController.fetchInit(order.Id);

        order.OrderType__c = 'ZDOB';
        order.ActualShippingDate__c = Date.today().addDays(-10);
        update order;

        DNSA_OrderOptionOnlyController.fetchInit(order.Id);
        Test.stopTest();
    }

    @isTest
    static void testSaveOptionOnlyOrder() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = 'CUST001' LIMIT 1];
        Test.startTest();

        Order newOrder = new Order(
            AccountId            = acc.Id,
            RequestedShipDate__c = Date.today().addDays(30),
            PurchaseOrderNo__c   = 'PO-001'
        );

        DNSA_OrderOptionOnlyController.saveOptionOnlyOrder(order.Id, newOrder);
        Test.stopTest();
    }
}