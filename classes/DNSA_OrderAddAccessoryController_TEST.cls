/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-06-09
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-03-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class DNSA_OrderAddAccessoryController_TEST {
    @testSetup
    static void setupTestData() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('test01 - thisUser ::: ' + thisUser);

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{
            'AccountTriggerHandler'
            , 'SalesAreaDataTrigger'
            , 'OpportunityTriggerHandler'
            , 'QuoteTriggerHandler'
            , 'ContactTriggerHandler'
            , 'OrderTriggerHandler'
            , 'OrderItemTriggerHandler'
        };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        Account dealerAcc;
        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
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

        Interface__c ifc08 = TestDataFactoryForSales.createinterface('IF-ORDER-008', 'Real-Time');
        insert ifc08;

        InterfaceClasses__c if08Class = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc08.Id);
        insert if08Class;

        Interface__c ifc09 = TestDataFactoryForSales.createinterface('IF-ORDER-009', 'Real-Time');
        insert ifc09;

        InterfaceClasses__c if09Class = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc09.Id);
        insert if09Class;

        System.runAs(dealer) {
            Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
            insert parentAcc;

            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
            acc.CustomerCode__c   = 'CUST001';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(dealerAcc);
            area.SalesOrganization__c = '4140';
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

            Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
            insert accessory;

            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;

            Order order = TestDataFactoryForSales.createDNSAOrder(acc, opty, quote, dealer);
            insert order;

            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            OrderItem oItemAccessory = TestDataFactoryForSales.createOrderAccessory(order.Id, prod.Id, entry.Id, qItem.Id, accessory.Id, '000020');
            insert oItemAccessory;

            Order order02 = TestDataFactoryForSales.createDNSAOrder(acc, opty, quote, dealer);
            order02.CustomerOrderNo__c = 'test02';
            order02.ReferenceOrder__c  = order.Id;
            insert order02;
        }
    }

    @isTest
    static void testFetchAccessory() {
        Order order = [SELECT Id FROM Order WHERE CustomerOrderNo__c = 'test02' LIMIT 1];
        Test.startTest();
        
        DNSA_OrderAddAccessoryController.fetchAccessory(order.Id);

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHanlder'};

        order.OrderType__c = 'ZUSO';
        order.ERPRSONo__c  = 'test';
        update order;

        DNSA_OrderAddAccessoryController.fetchAccessory(order.Id);
        Test.stopTest();
    }

    @isTest
    static void testFetchAccessory02() {
        Order order = [SELECT Id, OrderType__c, ERPRSONo__c FROM Order WHERE CustomerOrderNo__c = 'test02' LIMIT 1];

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHanlder'};
        order.OrderType__c = 'ZUSO';
        update order;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_008());
        DNSA_OrderAddAccessoryController.fetchAccessory(order.Id);

        Test.stopTest();
    }

    private class MockIF_ERP_008 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Data found"},"T_LIST":[{"KIT_CAT_DSC":"Barfeeders","KIT_CAT":"BARFEED LONG"},{"KIT_CAT_DSC":"Barfeeders","KIT_CAT":"BARFEED SERVO"},{"KIT_CAT_DSC":"Chuck Jaws","KIT_CAT":"CHUCK JAWS"},{"KIT_CAT_DSC":"Power Chucks","KIT_CAT":"CHUCK LEFT"}]}'
            );
            return res;
        }
    }

    @isTest
    static void testGetAccessoryData() {
        Order order = [SELECT Id, OrderType__c, ERPRSONo__c FROM Order WHERE CustomerOrderNo__c = 'test02' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_009());
        DNSA_OrderAddAccessoryController.getAccessoryData(order.Id, 'Test');

        Test.stopTest();
    }

    private class MockIF_ERP_009 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Data found"},"T_LIST":[{"KIT_CAT":"Test", "KIT":"Test", "KIT_T":"Test", "KBETR":"0", "MEINS":"EA", "DISCOUNT":"10"}] }'
            );
            return res;
        }
    }

    @isTest
    static void testSaveAccessories() {
        Order order = [SELECT Id, OrderType__c, ERPRSONo__c FROM Order WHERE CustomerOrderNo__c = 'test02' LIMIT 1];

        OrderItem oItem = [
            SELECT  Id, IF_POSNR__c, AccessoryCategory__c, AccessoryCode__c, AccessoryName__c
                    , Quantity, UnitPrice, Unit__c, ShipTo__c, ShipTo__r.Name, ReqShipDate__c
            FROM    OrderItem 
            WHERE   ItemCategory__c = 'Accessory' 
            LIMIT 1
        ];

        DNSA_OrderAddAccessoryController.TableWrapper wrap = new DNSA_OrderAddAccessoryController.TableWrapper(oItem);
        Test.startTest();
        DNSA_OrderAddAccessoryController.saveAccessories(order.Id, new List<DNSA_OrderAddAccessoryController.TableWrapper>{wrap});

        Test.stopTest();
    }
}