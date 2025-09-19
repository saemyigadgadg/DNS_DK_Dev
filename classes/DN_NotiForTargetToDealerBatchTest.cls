/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-03-19
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-03-06   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_NotiForTargetToDealerBatchTest {
    
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
            order.OrderConfirmedDate__c = Date.today();
            order.Type  = 'HE';
            order.DealerContact__c  = dealerCon.Id;
            insert order;
    
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            PaymentSchedule__c payment = TestDataFactoryForSales.createPaymentSchedule(order.Id);
            insert payment;

            PaymentScheduleItem__c paymentItem = TestDataFactoryForSales.createPaymentItem(payment.Id);
            insert paymentItem;


            RecordType dsgRT = TestDataFactoryForSales.getRecordType('DNS_Korea', 'DealerSalesGoal__c');
            DealerSalesGoal__c dsg = new DealerSalesGoal__c(
                Year__c = String.valueOf(Date.today().year()),
                Dealer__c = dealerAcc.Id,
                Target_OrderUnit__c = 120,
                Target_OrderAmount__c = 2400,
                RecordTypeId = dsgRT.Id
            );
            insert dsg;

            RecordType dspRT = TestDataFactoryForSales.getRecordType('DNS_Korea', 'DealerSalesPlan__c');
            DealerSalesPlan__c dsp = new DealerSalesPlan__c(
                Name = 'FirstJanPlan',
                Month__c = Date.today().month() < 10 ? '0' + String.valueOf(Date.today().month()) : String.valueOf(Date.today().month()),
                DealerSalesGoal__c = dsg.Id,
                RecordTypeId = dspRT.Id
            );
            insert dsp;

            List<AlertManager__c> alertList = new List<AlertManager__c>();
            alertList.add(TestDataFactoryForSales.createAlertManager('SalesPlanTargetReminder'));
            insert alertList;

        }
    }


    @isTest
    static void testBatchExecution(){

        DealerSalesPlan__c dsp = [SELECT Id, DealerSalesGoal__r.OwnerId FROM DealerSalesPlan__c WHERE Name = 'FirstJanPlan'];

        Test.startTest();
        DN_NotiForTargetToDealerBatch batchJob = new DN_NotiForTargetToDealerBatch();
        String jobId = System.schedule('Test Scheduled Batch', '0 0 0 1 1 ? 2050', batchJob);
        Database.ExecuteBatch(batchJob, 5);
        Test.stopTest();
    }
}