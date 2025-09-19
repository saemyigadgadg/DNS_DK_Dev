@isTest
public with sharing class DN_InspectionConfirmControllerTest {
    
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

            Order order = TestDataFactoryForSales.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.Status = 'Confirmed';
            insert order;

            Inspection__c inspection = TestDataFactoryForSales.createInspection(order.Id, thisUser.Id);
            insert inspection;
        }

    }

    @IsTest
    static void validateConfirmTest(){

        Inspection__c testInspection = [SELECT Id FROM Inspection__c LIMIT 1];

        Test.startTest();

        DN_InspectionConfirmController.validateConfirm(testInspection.Id);

        try {
            DN_InspectionConfirmController.validateConfirm(null);
        } catch (Exception e) {
            System.debug('validateConfirmTest error : ' + e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void confirmInspectionTest(){

        Inspection__c testInspection = [SELECT Id FROM Inspection__c LIMIT 1];

        Test.startTest();

        DN_InspectionConfirmController.confirmInspection(testInspection.Id);

        try {
            DN_InspectionConfirmController.confirmInspection(null);
        } catch (Exception e) {
            System.debug('confirmInspectionTest error : ' + e.getMessage());
        }

        Test.stopTest();
    }
}