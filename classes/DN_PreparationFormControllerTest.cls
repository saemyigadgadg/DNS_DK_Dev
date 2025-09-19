@isTest
public with sharing class DN_PreparationFormControllerTest {

    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        // TestDataFactoryForSales.activatePriceBook();

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

        Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        System.runAs(dealer) {

            Asset asset = TestDataFactoryForSales.createAsset();
            insert asset;

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
    
            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.Status = 'Confirmed';
            order.SerialNumber__c = 'MH0014-000391';
            order.SOSerialNumber__c = asset.Id;
            insert order;
    
            OrderItem oItemProd = TestDataFactoryForSales.createOrderProduct(order.Id, prod.Id, entry.Id, qItem.Id, '000010');
            insert oItemProd;
        }
    }

    
    @IsTest
    static void test01(){
        Order order = [SELECT Id, SOSerialNumber__c FROM Order LIMIT 1];

        Test.startTest();
        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHandler'};

        DN_PreparationFormController.checkCreatePermission(order.Id);

        order.SOSerialNumber__c = null;
        update order;

        try {
            DN_PreparationFormController.checkCreatePermission(order.Id);
        } catch (Exception e) {
            System.debug('test01 ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void test02(){
        Order order = [SELECT Id, ShipTo__c, OwnerId FROM Order LIMIT 1];
        User dealer = [SELECT Id, AccountId, ContactId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.CustomerCode__c = '123456' LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];

        Test.startTest();
        PreparationCheckList__c pre     = new PreparationCheckList__c();
        pre.Order__c                     = order.Id;
        pre.Account__c                   = order.ShipTo__c;
        pre.SalesReps__c                 = dealer.Id;
        pre.ContactPerson__c             = con.Id;
        pre.PreferredInstallationDate__c = Date.today().addDays(10);
        pre.SalesOrganization__c         = '1800';
        pre.SalesOffice__c               = '114E';
        insert pre;

        try {
            DN_PreparationFormController.checkCreatePermission(order.Id);
        } catch (Exception e) {
            System.debug('test01 ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void test03(){
        Order order = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();

        DN_PreparationFormController.checkEditPermission(order.Id);

        Test.stopTest();
    }

    @IsTest
    static void test04(){
        Order order = [SELECT Id, ShipTo__c, OwnerId FROM Order LIMIT 1];
        User dealer = [SELECT Id, AccountId, ContactId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.CustomerCode__c = '123456' LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];

        Test.startTest();

        DN_PreparationFormController.getDefaultValues(order.Id);

        PreparationCheckList__c pre     = new PreparationCheckList__c();
        pre.Order__c                     = order.Id;
        pre.Account__c                   = order.ShipTo__c;
        pre.SalesReps__c                 = dealer.Id;
        pre.ContactPerson__c             = con.Id;
        pre.PreferredInstallationDate__c = Date.today().addDays(10);
        pre.SalesOrganization__c         = '1800';
        pre.SalesOffice__c               = '114E';
        insert pre;

        DN_PreparationFormController.getDefaultValues(pre.Id);

        Test.stopTest();
    }

    @IsTest
    static void test05(){
        User dealer = [SELECT Id, AccountId, ContactId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();

        DN_PreparationFormController.getBelonging(new List<Id>{dealer.Id});

        Test.stopTest();
    }

    @IsTest
    static void test06(){
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();

        DN_PreparationFormController.getContactOption(acc.Id);

        Test.stopTest();
    }
}