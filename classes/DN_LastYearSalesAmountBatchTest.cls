/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-05-13
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-21   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_LastYearSalesAmountBatchTest {

    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        Account dealerAcc;
        Contact dealerCon;
        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
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
            order.SalesRep__c = dealerAcc.Id;
            order.OrderConfirmedDate__c = Date.today().addYears(-1) ;
            order.Type  = 'HE';
            order.DealerContact__c  = dealerCon.Id;
            order.Owner__c  = dealer.Id;
            insert order;

            Order order2 = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order2.Status = 'Confirmed';
            order2.ERPOrderNo__c = 'test2';
            order2.SalesRep__c = dealerAcc.Id;
            order2.OrderConfirmedDate__c = Date.today().addYears(-1) ;
            order2.Type  = 'HE';
            order2.DealerContact__c  = dealerCon.Id;
            order2.Owner__c  = dealer.Id;
            insert order2;
    
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            PaymentSchedule__c payment = TestDataFactoryForSales.createPaymentSchedule(order.Id);
            insert payment;
    
            OrderItem oItemProd2 = TestDataFactoryForSales.createOrderProduct(order2.Id, prod.Id, entry.Id, qItem.Id, '000011');
            insert oItemProd2;

            PaymentSchedule__c payment2 = TestDataFactoryForSales.createPaymentSchedule(order2.Id);
            insert payment2;

            PaymentScheduleItem__c paymentItem = TestDataFactoryForSales.createPaymentItem(payment.Id);
            insert paymentItem;

            PaymentScheduleItem__c paymentItem2 = TestDataFactoryForSales.createPaymentItem(payment2.Id);
            insert paymentItem2;
        }
    }

    
    @isTest
    static void testBatchExecution(){
        Test.startTest();
        DN_LastYearSalesAmountBatch batchJob = new DN_LastYearSalesAmountBatch();
        String jobId = System.schedule('Test Scheduled Batch', '0 0 0 1 1 ? 2050', batchJob);
        Database.ExecuteBatch(batchJob, 5);
        Test.stopTest();
    }
    

}