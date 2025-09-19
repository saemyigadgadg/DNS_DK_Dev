/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 2025-05-30
 * @last modified by  : yuhyun.park@sbtglobal.com
**/
@isTest
private class MessageGroupJunctionTriggerHandlerTest {
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler', 'DealerSalesGoalTriggerHandler', 'DealerSalesPlanTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        Account dealerAcc;
        Contact dealerCon;
        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.IsDNSDirectAccount__c = false;
            insert dealerAcc;
    
            dealerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert dealerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerCon);
            insert dealer;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '0000000';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'TradeAcc';
            insert acc;

            SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
            insert area;
    
            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.Status = 'Confirmed';
            order.ERPOrderNo__c = 'test';
            order.RelatedDealer__c = dealerAcc.Id;
            order.OrderConfirmedDate__c = Date.today();
            order.Type  = 'HE';
            order.DealerContact__c  = dealerCon.Id;
            insert order;

            Order orderDNSA = TestDataFactoryForSales.createDNSAOrder(acc, opty, quote, dealer);
            orderDNSA.Status = 'Confirmed';
            orderDNSA.ERPOrderNo__c = 'test2';
            orderDNSA.RelatedDealer__c = dealerAcc.Id;
            orderDNSA.RequestedShipDate__c = Date.today();
            orderDNSA.Type  = 'HE';
            orderDNSA.DealerContact__c  = dealerCon.Id;
            insert orderDNSA;
    
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;
    
            OrderItem oItemProdDNSA = TestDataFactoryForSales.createOrderProduct(orderDNSA.Id, prod.Id, entry.Id, qItem.Id, '000011');
            insert oItemProdDNSA;

            PaymentSchedule__c payment = TestDataFactoryForSales.createPaymentSchedule(order.Id);
            insert payment;

            PaymentScheduleItem__c paymentItem = TestDataFactoryForSales.createPaymentItem(payment.Id);
            insert paymentItem;

            PS__c rfq = new PS__c();
            rfq.Opportunity__c = opty.Id;
            rfq.Name__c = 'testRfq';
            insert rfq;

            MessageGroup__c mg = new MessageGroup__c();
            mg.Name = 'TestMG';
            mg.SalesDistrict__c = 'Korea';
            insert mg;

            Message_Group_Junction__c mgj1 = new Message_Group_Junction__c();
            mgj1.User__c = dealer.Id;
            mgj1.RFQ_Specification__c = rfq.Id;
            mgj1.Message_Group__c = mg.Id;
            insert mgj1;

        }
    }
    
    @isTest
    static void insertMGJ() {
        Test.startTest();

        PS__c testRfq   = [SELECT Id, Name__c FROM PS__c WHERE Name__c = 'testRfq' LIMIT 1];

        Message_Group_Junction__c mgj = new Message_Group_Junction__c();
        mgj.RFQ_Specification__c = testRfq.Id;
        insert mgj;

        System.debug('mgj :: '+ mgj );
        Test.stopTest();

    }
}