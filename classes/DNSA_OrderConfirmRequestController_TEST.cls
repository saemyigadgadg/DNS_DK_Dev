/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-06-09
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-02-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class DNSA_OrderConfirmRequestController_TEST {
    
    @testSetup
    static void setupTestData() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('test01 - thisUser ::: ' + thisUser);

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        // TestDataFactoryForSales.activatePriceBook();

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

        Warranty__c warr = new Warranty__c(KSCHL__c = 'ZMWAR', VKORG__c = '4140', SPART__c = '40', VTWEG__c = '', ZZPR_WAR__c = 'S24', Percent__c = 1.5, DATBI__c = Date.newInstance(2099, 12, 31), DATAB__c = Date.newInstance(2010, 12, 1), ZZWARRPER__c = '24', ZZPERUNIT__c = '2', ZZWARHRS__c = '0', ZZCOVERAGE__c = '10', ZZCOVERAGE_B__c = '10', BZIRK__c = 'M3US');
        insert warr;

        List<Warranty__c> warrantyrecords = TestDataFactoryForSales.getWarranty();
        insert warrantyrecords;

        Interface__c ifc06 = TestDataFactoryForSales.createinterface('IF-ORDER-006', 'Real-Time');
        insert ifc06;

        InterfaceClasses__c ifClass06 = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc06.Id);
        insert ifClass06;

        Interface__c ifc07 = TestDataFactoryForSales.createinterface('IF-ORDER-007', 'Real-Time');
        insert ifc07;

        InterfaceClasses__c ifClass07 = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc07.Id);
        insert ifClass07;

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('Commodity ERP Order Alert'));
        alertList.add(TestDataFactoryForSales.createAlertManager('Send Already Create Commodity ERP Order'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderRequestConfirmDNSA_F'));
        insert alertList;

        MessageGroup__c mGroup01 = new MessageGroup__c(
            Name = 'Order Request'
            , SalesOffice__c = '414A'
            , SalesDistrict__c = 'DNSA'
        );
        insert mGroup01;

        Message_Group_Junction__c mGroup01Member = new Message_Group_Junction__c(
            Message_Group__c = mGroup01.Id
            , User__c = thisUser.Id
        );
        insert mGroup01Member;

        MessageGroup__c mGroup02 = new MessageGroup__c(
            Name = 'Order Request'
            , SalesOffice__c = '414P'
            , SalesDistrict__c = 'DNSA'
        );
        insert mGroup02;

        Message_Group_Junction__c mGroup02Member = new Message_Group_Junction__c(
            Message_Group__c = mGroup02.Id
            , User__c = thisUser.Id
        );
        insert mGroup02Member;

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
            order.OrderNotes__c = '111111111111';
            order.ShippingInstructions__c = '111111111111';
            order.PromotionalPackage__c = 1000;
            order.ServiceReimbursement__c = 'Y';
            order.ServiceReimbursementPrice__c = 1000;
            order.ProfitMarginSubsidyPlan__c = 1000;
            order.DiscountfromSalesAvailabilityList__c = 10;
            insert order;

            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            oItemProd.ShipTo__c = acc.Id;
            insert oItemProd;
        }
    }

    @IsTest
    static void validate01(){
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        order.Status = 'Submitted';
        update order;
        
        try {
            DNSA_OrderConfirmRequestController.dnsaValidateOrderConfrim(order.Id);
        } catch (Exception e) {
            System.debug('ERROR');
        }
        Test.stopTest();
    }

    @IsTest
    static void validate02(){
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        order.Status = 'Canceled';
        update order;
        
        try {
            DNSA_OrderConfirmRequestController.dnsaValidateOrderConfrim(order.Id);
        } catch (Exception e) {
            System.debug('ERROR');
        }
        Test.stopTest();
    }

    @IsTest
    static void validate03(){
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        order.Status = 'Confirmed';
        update order;
        
        try {
            DNSA_OrderConfirmRequestController.dnsaValidateOrderConfrim(order.Id);
        } catch (Exception e) {
            System.debug('ERROR');
        }
        Test.stopTest();
    }

    @IsTest
    static void validate04(){
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler', 'OrderItemTriggerHandler'};

        List<OrderItem> oItems = [SELECT Id FROM OrderItem];
        delete oItems;
        
        try {
            DNSA_OrderConfirmRequestController.dnsaValidateOrderConfrim(order.Id);
        } catch (Exception e) {
            System.debug('ERROR');
        }
        Test.stopTest();
    }

    @IsTest
    static void validate05(){
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler', 'OrderItemTriggerHandler'};

        order.PurchaseOrderNo__c = null;
        update order;
        
        try {
            DNSA_OrderConfirmRequestController.dnsaValidateOrderConfrim(order.Id);
        } catch (Exception e) {
            System.debug('ERROR');
        }
        Test.stopTest();
    }

    @IsTest
    static void validate06(){
        Test.startTest();
        try {
            DNSA_OrderConfirmRequestController.dnsaValidateOrderConfrim(null);
        } catch (Exception e) {
            System.debug('ERROR');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void confirm01(){
        Order order = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Fail());
        DNSA_OrderConfirmRequestController.requestConfirm(order.Id);
        Test.stopTest();
    }

    private class MockIF_ERP_Fail implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "E", "MESSAGE": "ERROR" } }'
            );
            return res;
        }
    }

    @IsTest
    static void confirm02(){
        Order order = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Success());
        DNSA_OrderConfirmRequestController.requestConfirm(order.Id);
        Test.stopTest();
    }

    private class MockIF_ERP_Success implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "S", "MESSAGE": "Success" } }'
            );
            return res;
        }
    }

    @IsTest
    static void confirm03(){
        Order order = [SELECT Id FROM Order LIMIT 1];
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        
        Id commodityRT = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
        
        TriggerHandler.bypassedHandlers = new Set<String>{'QuoteTriggerHandler', 'OrderTriggerHandler'};

        quote.RecordTypeId = commodityRT;
        update quote;

        order.MachinePartsWarranty__c = 'S24';
        update order;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Comm());

        DNSA_OrderConfirmRequestController.requestConfirm(order.Id);
        Test.stopTest();
    }

    private class MockIF_ERP_Comm implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ '
                + ' "E_VBELN" : "TEST01" '
                + ' , "T_PRICING_RETURN" : [ '
                + ' {"KSCHL":"ZSUM", "VTEXT":"Net Sales Price", "KWERT":"101900000.00", "VISIBLE":"", "POSNR":"000010", "WAERK":"KRW"} '
                + ' , { "KSCHL":"MWST", "VTEXT":"Input Tax Round.up", "KWERT":"10190000.00", "VISIBLE":"", "POSNR":"000010", "WAERK":"KRW"} ] '
                + ' , "T_COND_EX": [ '
                + ' { "COND_TYPE":"ZVA1", "CONDVALUE":"0", "VARCOND":"MT5281-V0060"}]'
                +' }'
            );
            return res;
        }
    }

    
}