@isTest
public with sharing class DN_OrderApprovalControllerTest {
    
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

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderRequestApproval'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalRejected'));
        alertList.add(TestDataFactoryForSales.createAlertManager('OrderInternalApproved'));
        insert alertList;

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
    static void initRelatedListTest(){

        Order order = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
    
        DN_OrderApprovalController.initRelatedList(order.Id);
        try {
            DN_OrderApprovalController.initRelatedList(null);
        } catch (Exception e) {
            System.debug('initRelatedListTest error : ' + e.getMessage());
        }
    
        Test.stopTest();
    }

    @IsTest
    static void validateApprovalTest(){

        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
    
        DN_OrderApprovalController.validateApproval(order.Id, true);
        DN_OrderApprovalController.validateApproval(order.Id, false);
        try {
            DN_OrderApprovalController.validateApproval(null, null);
        } catch (Exception e) {
            System.debug('validateApprovalTest error : ' + e.getMessage());
        }
    
        Test.stopTest();
    }

    @IsTest
    static void doInternalApprovalTest(){

        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
    
        DN_OrderApprovalController.doInternalApproval(order.Id, 'test');
        try {
            DN_OrderApprovalController.doInternalApproval(null, null);
        } catch (Exception e) {
            System.debug('doInternalApprovalTest error : ' + e.getMessage());
        }
    
        Test.stopTest();
    }

    @IsTest
    static void rejectApprovalTest(){

        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        DN_OrderApprovalController.doInternalApproval(order.Id, 'test');
        DN_OrderApprovalController.rejectApproval(order.Id, 'test');
        try {
            DN_OrderApprovalController.rejectApproval(null, null);
        } catch (Exception e) {
            System.debug('rejectApprovalTest error : ' + e.getMessage());
        }
    
        Test.stopTest();
    }

    @IsTest
    static void approveApprovalTest(){

        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        DN_OrderApprovalController.doInternalApproval(order.Id, 'test');
        DN_OrderApprovalController.approveApproval(order.Id, 'test', true);
        try {
            DN_OrderApprovalController.approveApproval(null, null, null);
        } catch (Exception e) {
            System.debug('approveApprovalTest error : ' + e.getMessage());
        }
    
        Test.stopTest();
    }

    @IsTest
    static void wrapperTest(){

        Order order = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();

        DN_OrderApprovalController.doInternalApproval(order.Id, 'test');
        OrderApproval__c appv = [
            SELECT  Id, Status__c, StepName__c, Requester__r.Name, RequestDate__c, RequesterComments__c
                    , Approver__r.Name, DecisionDate__c, ApproverComments__c
            FROM    OrderApproval__c
        ];

        DN_OrderApprovalController.TableWrapper tWrap01 = new DN_OrderApprovalController.TableWrapper();
        DN_OrderApprovalController.TableWrapper tWrap02 = new DN_OrderApprovalController.TableWrapper(appv, 'test');
        DN_OrderApprovalController.PriceWrapper pWrap = new DN_OrderApprovalController.PriceWrapper();
        pWrap.posnr = '';
        pWrap.price = 0;
        pWrap.tax   = 0;
        Test.stopTest();
    }
}