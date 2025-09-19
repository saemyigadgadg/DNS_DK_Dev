@isTest
public with sharing class DeliveryOrderTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TestDataFactoryForSales.activatePriceBook();

        User dealer;
        Set<String> bypassSet2 = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet2; // Too many SOQL queries 대응
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
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

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveryOrderConfirmed'));
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveryOrderInternalApproved'));
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveryOrderInternalRejected'));
        insert alertList;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        
        System.runAs(dealer) {
            Account parentAcc = TestDataFactoryForSales.createParentAccount(country);
            insert parentAcc;

            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, parentAcc);
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

            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            insert order;

            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;
        }
    }

    @isTest
    static void testInsert() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();

        DeliveryOrder__c dOrder;
        System.runAs(dealer) {

            dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
            insert dOrder;
    
            try {
                dOrder.ERPDONo__c = 'test01';
                update dOrder;
            } catch (Exception e) {
                System.debug('ERROR ::: ' + e.getMessage());
            }

        }

        dOrder.Status__c = 'DOConfirmed';
        update dOrder;

        Test.stopTest();
    }

    @isTest
    static void testApproval() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        User kaUser = [SELECT Id FROM User WHERE Profile.Name = '영업 KA' LIMIT 1];

        Test.startTest();

        DeliveryOrder__c dOrder;
        Approval.ProcessResult requestedResult;

        System.runAs(dealer) {

            TriggerHandler.bypassedHandlers = new Set<String>{'DeliveryOrderTriggerHandler'};

            dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
            dOrder.InternalApprover__c = kaUser.Id;
            insert dOrder;

            TriggerHandler.bypassedHandlers = new Set<String>();
    
            requestedResult = TestDataFactoryForSales.runApproval(dOrder.Id, kaUser.Id);
        }

        Approval.ProcessResult rejectedResult = TestDataFactoryForSales.actionApproval(requestedResult, 'Reject');
        Approval.ProcessResult requestedResult2;
        System.runAs(dealer) {
            requestedResult2 = TestDataFactoryForSales.runApproval(dOrder.Id, kaUser.Id);
        }
        Approval.ProcessResult approvedResult = TestDataFactoryForSales.actionApproval(requestedResult2, 'Approve');
        
        Test.stopTest();

    }

    @isTest
    static void testDelete() {
        Order order = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();

        TriggerHandler.bypassedHandlers = new Set<String>{'DeliveryOrderTriggerHandler'};

        DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
        insert dOrder;

        TriggerHandler.bypassedHandlers = new Set<String>();

        delete dOrder;
        
        Test.stopTest();

    }
}