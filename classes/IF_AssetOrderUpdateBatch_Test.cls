/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-17-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-17-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
@isTest
private with sharing class IF_AssetOrderUpdateBatch_Test {
    
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{
            'AccountTriggerHandler'
            , 'OpportunityTriggerHandler'
            , 'QuoteTriggerHandler'
            , 'OrderTriggerHandler'
        };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer.ManagerId = thisUser.Id;
            insert dealer;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-ORDER-001', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Order', ifc.Id);
        insert ifClass;

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderRequestConfirm'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderERPFail'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderERPFailSupport'));
        insert alertList;

        List<Warranty__c> warrList = TestDataFactoryForSales.getWarranty();
        insert warrList;

        MessageGroup__c mGroup01 = new MessageGroup__c(
            Name = 'SO 알림대상'
            , SalesOffice__c = '114E'
            , SalesDistrict__c = 'Korea'
        );
        insert mGroup01;

        Message_Group_Junction__c mGroup01Member = new Message_Group_Junction__c(
            Message_Group__c = mGroup01.Id
            , User__c = thisUser.Id
        );
        insert mGroup01Member;

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '123456';
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
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForSales.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            SQ__c sq = TestDataFactoryForSales.createSQ(null, null);
            insert sq;

            Accessory__c accessory = TestDataFactoryForSales.createAccessory(qItem.Id, null);
            insert accessory;

            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.ApprovalStatus__c = 'OrderConfirmRequested';
            order.SerialNumber__c = 'test';
            insert order;

            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            OrderItem oItemSQ = TestDataFactoryForSales.createOrderSQ(order.Id, prod.Id, entry.Id, qItem.Id, sq.Id, '000020');
            insert oItemSQ;

            OrderItem oItemAccessory = TestDataFactoryForSales.createOrderAccessory(order.Id, prod.Id, entry.Id, qItem.Id, accessory.Id, '000030');
            insert oItemAccessory;

            PaymentSchedule__c payment = TestDataFactoryForSales.createPaymentSchedule(order.Id);
            insert payment;

            PaymentScheduleItem__c paymentItem = TestDataFactoryForSales.createPaymentItem(payment.Id);
            insert paymentItem;

            CharacteristicValue__c cv = TestDataFactoryForSales.createCV(qItem.Id, null, null);
            insert cv;

            CVOrderItem__c cvOItem = TestDataFactoryForSales.createCVJunction(cv.Id, oItemProd.Id);
            insert cvOItem;

            OrderPricingSelected__c selectedProm = TestDataFactoryForSales.createSelectedProm(order.Id);
            insert selectedProm;

            Asset a = new Asset();
            a.Name = 'test';
            a.SerialNumber = 'test';
            insert a;
        }
    }
    @isTest
    static void testBatchExecution() {
        
        ORDER ord = [select id from order LIMIT 1][0];
        // 배치 실행
        Test.startTest();
        IF_AssetOrderUpdateBatch batch = new IF_AssetOrderUpdateBatch(new Set<String> {ord.Id});
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }
}