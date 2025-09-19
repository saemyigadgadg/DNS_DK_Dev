/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 05-30-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-02-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class DN_CommodityController_TEST {

    @testSetup
    static void setupTestData() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        List<AlertManager__c> amList = new List<AlertManager__c>();
        AlertManager__c am1 = TestDataFactoryForSales.createAlertManager('Send Wating Alert');
        AlertManager__c am2 = TestDataFactoryForSales.createAlertManager('Request Pending Alert');
        AlertManager__c am3 = TestDataFactoryForSales.createAlertManager('Confirm Pending Alert');
        AlertManager__c am4 = TestDataFactoryForSales.createAlertManager('New Factory Quote Alert');
        AlertManager__c am5 = TestDataFactoryForSales.createAlertManager('Person in Charge Assigned Alert');
        AlertManager__c am6 = TestDataFactoryForSales.createAlertManager('SQ Send DSNA Sales Team Alert');
        amList.add(am1);
        amList.add(am2);
        amList.add(am3);
        amList.add(am4);
        amList.add(am5);
        amList.add(am6);
        insert amList;

        MessageGroup__c mg = new MessageGroup__c();
        mg.Name = 'Quote Request (414P)';
        mg.SalesDistrict__c = 'DNSA';
        mg.SalesOffice__c = '414P';
        MessageGroup__c mg2 = new MessageGroup__c();
        mg2.Name = 'Quote Request (414A)';
        mg2.SalesDistrict__c = 'DNSA';
        mg2.SalesOffice__c = '414A';
        MessageGroup__c mg3 = new MessageGroup__c();
        mg3.Name = 'Commodity Reserves';
        mg3.SalesDistrict__c = 'DNSA';
        mg3.SalesOffice__c = '414A';
        insert mg;
        insert mg2;
        insert mg3;

        Message_Group_Junction__c qqq = new Message_Group_Junction__c();
        qqq.User__c = thisUser.Id;
        qqq.Message_Group__c = mg.Id;
        Message_Group_Junction__c qqq2 = new Message_Group_Junction__c();
        qqq2.User__c = thisUser.Id;
        qqq2.Message_Group__c = mg2.Id;
        Message_Group_Junction__c qqq3 = new Message_Group_Junction__c();
        qqq3.User__c = thisUser.Id;
        qqq3.Message_Group__c = mg3.Id;
        insert qqq;
        insert qqq2;
        insert qqq3;

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();
        Product2 p1 = TestDataFactoryForSales.createProduct();
        p1.Name = 'P260SY2-F0TP-0-U31';
        p1.ProductCode = 'P260SY2-F0TP-0-U31'; 
        p1.CurrencyIsoCode = 'USD';
        insert p1;

        PricebookEntry pre = TestDataFactoryForSales.createPriceBookEntry(p1, 'USD');
        insert pre;
        System.debug('pre ::: ' + pre);

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'QuoteLineItemTriggerHanlder'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer.Alias = 'asd';
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

            Opportunity opty1 = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            opty1.CurrencyIsoCode = 'USD';
            insert opty1;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            oItem.ERPInquiryNo__c = '0600203414';
            insert oItem;

            Quote quote3 = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
            quote3.Name = 'tttest';
            quote3.DNSA_SalesOffice__c = '414P';
            quote3.ReserveExpirationDate__c = Date.today();
            insert quote3;
            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'DNSA_Commodity');
            insert quote;
            Quote quote2 = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty1, 'DNSA_Commodity');
            quote2.Name = 'test';
            quote2.CurrencyIsoCode = 'USD';
            insert quote2;

            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            qItem.ERPQuotationNo__c = '0701069991';
            insert qItem;

            QuoteLineItem qItem2 = TestDataFactoryForSales.createQuoteItem(quote3, entry, oItem, prod);
            qItem.ERPQuotationNo__c = '0701069992';
            insert qItem2;

            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;

            Order order = TestDataFactoryForSales.createDNSAOrder(acc, opty, quote, dealer);
            insert order;

            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            SQRegistration__c sqReg    = new SQRegistration__c();
            sqReg.Name                 = 'TEST';
            sqReg.Model__c             = 'DBC 110S';
            sqReg.BaseCode__c          = prod.Id;
            sqReg.Account__c           = quote3.AccountId;
            sqReg.Stage__c             = 'Request';
            sqReg.Owner__c             = dealer.Id;
            sqReg.Dealer__c            = dealer.AccountId;
            sqReg.SalesOrganization__c = '1800';
            sqReg.SalesOffice__c       = '114F';
            sqReg.Quote__c             = quote3.Id;
            sqReg.DNSA_Sales_Team__c   = mg.Id;
            insert sqReg;
        }
    }

    @isTest
    static void getStatus_Test() {
        Quote quote2 = [SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        DN_CommodityController.getStatus(quote2.Id);
        Test.stopTest();
    }

    @isTest
    static void dnsaModelInit_Test() {
        Quote quote2 = [SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        DN_CommodityController.dnsaModelInit(quote2.Id, 'Quote');
        Test.stopTest();
    }

    @isTest
    static void cancelInit_Test() {
        Quote quote2 = [SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        DN_CommodityController.cancelInit(quote2.Id);
        Test.stopTest();
    }

    @isTest
    static void InventoryWrapper_Test() {
        Quote quote2 = [SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        DN_CommodityController.InventoryWrapper iw = new DN_CommodityController.InventoryWrapper();
        iw.VBELN_ST       = '1';
        iw.BASE_CODE      = '2';
        iw.NC             = '3';
        iw.LIST_PRICE     = '4';
        iw.SERIAL_NUMBER  = '5';
        iw.ADJUSTED_LIST  = '6';
        iw.PERCENT_OFF    = 'a';
        iw.DEPT           = 'a';
        iw.DNSA_MODEL     = 'a';
        iw.ETA_DATE       = 'a';
        iw.INVENTORY_STS  = 'a';
        iw.LOCATION       = 'a';
        iw.MC_TC          = 'a';
        iw.ORDER_STS      = 'a';
        iw.PORT           = 'a';
        iw.PROD_DATE      = 'a';
        iw.WAERK          = 'a';
        iw.OPEN_NOTES     = 'a';
        iw.dealerName     = 'a';
        iw.userName       = 'a';
        iw.SQTXT          = 'a';
        iw.modelName      = 'a';
        Test.stopTest();
    }

    @isTest
    static void ResultWrapper_Test() {
        Test.startTest();
        DN_CommodityController.ResultWrapper rs = new DN_CommodityController.ResultWrapper();
        rs.isSuccess       = true;
        rs.errMessage      = '2';
        
        Test.stopTest();
    }

    @isTest
    static void getStockList_Test() {
        InterfaceCommonUtil.setInterface('IF-ORDER-010', 'IF_ERP_Order');
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'test' LIMIT 1];

        Test.startTest();
        DN_CommodityController.getStockList(quote.Id);
        Test.stopTest();
    }
    @isTest
    static void getStockList_Test2() {
        InterfaceCommonUtil.setInterface('IF-ORDER-010', 'IF_ERP_Order');

        Test.startTest();
        DN_CommodityController.getStockList(null);
        Test.stopTest();
    }

    @isTest
    static void insertQuoteLineItem_Test2() {
        InterfaceCommonUtil.setInterface('IF-ORDER-011', 'IF_ERP_Order');
        Quote quote = [SELECT Id, CurrencyIsoCode FROM Quote WHERE Name = 'test' LIMIT 1];

        Test.startTest();
        DN_CommodityController.insertQuoteLineItem('P260SY2-F0TP-0-U31', quote.Id, '123', 'asd');
        Test.stopTest();
    }

    @isTest
    static void cancelReservation_Test() {
        InterfaceCommonUtil.setInterface('IF-ORDER-011', 'IF_ERP_Order');
        Quote quote = [SELECT Id, CurrencyIsoCode FROM Quote WHERE Name = 'test' LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.cancelReservation(quote.Id, 'test');
        Test.stopTest();
    }

    @isTest
    static void createOrderInit_Test() {
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'tttest' LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.createOrderInit(quote.Id);
        Test.stopTest();
    }

    @isTest
    static void getQuoteInfo_Test() {
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'tttest' LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.getQuoteInfo(quote.Id);
        Test.stopTest();
    }

    @isTest
    static void getFieldSet_Test() {
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'tttest' LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.getFieldSet('Quote');
        Test.stopTest();
    }

    @isTest
    static void insertOrderItems_Test() {
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'QuoteLineItemTriggerHanlder', 'OrderTriggerHandler', 'OrderItemTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        Quote quote = [SELECT Id, AccountId, OpportunityId, CurrencyIsoCode FROM Quote WHERE Name = 'tttest' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id = :quote.AccountId LIMIT 1];
        Opportunity opty = [SELECT Id FROM Opportunity WHERE Id = :Quote.OpportunityId LIMIT 1];
        User dealer = [SELECT Id, AccountId FROM User WHERE Alias = 'asd' LIMIT 1];
        Order order = TestDataFactoryForSales.createDNSAOrder(acc, opty, quote, dealer);
        insert order;
        
        Test.startTest();
        DN_CommodityController.insertOrderItems(order.Id, quote.Id);
        Test.stopTest();
    }

    @isTest
    static void dnsaValidateOrderConfrim_Test() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.dnsaValidateOrderConfrim(order.Id);
        Test.stopTest();
    }

    @isTest
    static void initPricing_Test() {
        InterfaceCommonUtil.setInterface('IF-ORDER-018', 'IF_ERP_Order');
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.initPricing(order.Id);
        Test.stopTest();
    }

    @isTest
    static void applyPricing_Test() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Map<String, Object> fieldData = new Map<String, Object>();
        fieldData.put('DiscountfromSalesAvailabilityList__c', '10');
        fieldData.put('PromotionalPackage__c', '10');
        fieldData.put('ProfitMarginSubsidyPlan__c', '10');
        fieldData.put('OtherDiscount__c', '10');
        fieldData.put('ServiceReimbursement__c', '10');
        fieldData.put('O_Price', '10');
        fieldData.put('MachinePartsWarranty__c', '10');
        fieldData.put('ExtWarranty__c', '10');
        
        Test.startTest();
        DN_CommodityController.applyPricing(order.Id, fieldData);
        Test.stopTest();
    }

    @isTest
    static void checkPending_Test() {
        Quote quote = [SELECT Id, AccountId, OpportunityId, CurrencyIsoCode FROM Quote WHERE Name = 'tttest' LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.checkPending(quote.Id);
        Test.stopTest();
    }

    @isTest
    static void requestPending_Test() {
        InterfaceCommonUtil.setInterface('IF-ORDER-011', 'IF_ERP_Order');
        Quote quote = [SELECT Id, AccountId, OpportunityId, CurrencyIsoCode FROM Quote WHERE Name = 'tttest' LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.requestPending(quote.Id, 'fieldData', '12312');
        Test.stopTest();
    }

    @isTest
    static void pendingConfirm_Test() {
        InterfaceCommonUtil.setInterface('IF-ORDER-011', 'IF_ERP_Order');
        Quote quote = [SELECT Id, AccountId, OpportunityId, CurrencyIsoCode FROM Quote WHERE Name = 'tttest' LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.pendingConfirm(quote.Id, '12312', 'fieldData');
        Test.stopTest();
    }

    @isTest
    static void sendControlAlert_Test() {
        Quote quote = [SELECT Id, AccountId, OpportunityId, CurrencyIsoCode FROM Quote WHERE Name = 'tttest' LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.sendControlAlert(quote.Id);
        Test.stopTest();
    }

    @isTest
    static void sendQuoteDNSASalesTeamAlert_Test() {
        Quote quote = [SELECT Id, AccountId, OpportunityId, CurrencyIsoCode FROM Quote WHERE Name = 'tttest' LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.sendQuoteDNSASalesTeamAlert(quote.Id);
        Test.stopTest();
    }

    @isTest
    static void sendSQRegistrationDNSASalesTeamAlert_Test() {
        SQRegistration__c sqr = [SELECT id FROM SQRegistration__c LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.sendSQRegistrationDNSASalesTeamAlert(sqr.Id);
        Test.stopTest();
    }

    @isTest
    static void changeWarranty_Test() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.changeWarranty(order.Id, 'M48');
        Test.stopTest();
    }

    @isTest
    static void getAccountShipAddress_Test() {
        List<Id> accIds = new List<Id>();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        accIds.add(acc.Id);
        
        Test.startTest();
        DN_CommodityController.getAccountShipAddress(accIds);
        Test.stopTest();
    }

    @isTest
    static void setHolding_Test() {
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'tttest' LIMIT 1];
        
        Test.startTest();
        DN_CommodityController.setHolding(quote.Id);
        Test.stopTest();
    }
}