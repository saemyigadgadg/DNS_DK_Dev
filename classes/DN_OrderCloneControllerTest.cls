@isTest
public with sharing class DN_OrderCloneControllerTest {
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
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
            order.Status = 'Confirmed';
            insert order;
    
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;

            OrderItem oItemSQ = TestDataFactoryForSales.createOrderSQ(order.Id, prod.Id, entry.Id, qItem.Id, sq.Id, '000020');
            insert oItemSQ;

            OrderItem oItemAccessory = TestDataFactoryForSales.createOrderAccessory(order.Id, prod.Id, entry.Id, qItem.Id, accessory.Id, '000030');
            insert oItemAccessory;
        }
    }

    @IsTest
    static void initTest(){

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        Order order = [SELECT Id FROM Order LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        
        Test.startTest();

        try {
            DN_OrderCloneController.fetchInit(order.Id);
        } catch (Exception e) {
            System.debug('ERROR : ' + e.getMessage());
        }

        System.runAs(dealer) {
            DN_OrderCloneController.fetchInit(order.Id);

            order.Status = 'Canceled';
            update order;

            DN_OrderCloneController.fetchInit(order.Id);

        }
        
        Test.stopTest();
        
    }

    @IsTest
    static void cloneTest(){

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        Order order = [SELECT Id FROM Order LIMIT 1];
        Quote quote = [SELECT Id FROM Quote LIMIT 1];
        QuoteLineItem qItem = [SELECT Id, Product2Id, Product2.Name__c, ERPQuotationNo__c, ExpectedDelivDate__c, ListPrice, Dealer_Price__c, RequestedDelivDate__c FROM QuoteLineItem LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        
        Test.startTest();

        OrderPricingSelected__c selectedProm = TestDataFactoryForSales.createSelectedProm(order.Id);
        insert selectedProm;

        PaymentSchedule__c payment = TestDataFactoryForSales.createPaymentSchedule(order.Id);
        insert payment;

        PaymentScheduleItem__c paymentItem = TestDataFactoryForSales.createPaymentItem(payment.Id);
        insert paymentItem;

        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        DN_OrderCloneController.ProductWrapper wrap = new DN_OrderCloneController.ProductWrapper(qItem, baseUrl);
        DN_OrderCloneController.cloneCurrOrder(order.Id, Date.today().addDays(10), new List<DN_OrderCloneController.ProductWrapper>{wrap});

        // try {
        //     DN_OrderCloneController.fetchInit(order.Id);
        // } catch (Exception e) {
        //     System.debug('ERROR : ' + e.getMessage());
        // }

        // System.runAs(dealer) {
        //     DN_OrderCloneController.fetchInit(order.Id);

        //     order.Status = 'Canceled';
        //     update order;

        //     DN_OrderCloneController.fetchInit(order.Id);

        // }
        
        Test.stopTest();
        
    }
}