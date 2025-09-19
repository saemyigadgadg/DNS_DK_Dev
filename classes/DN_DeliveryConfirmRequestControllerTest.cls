@isTest
public with sharing class DN_DeliveryConfirmRequestControllerTest {

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
            , 'ContentVersionTriggerHandler'
            , 'ContentDocumentTriggerHandler'
            , 'ContentDocumentLinkTriggerHandler'
        };
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

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-DELIV-001', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_DELIV', ifc.Id);
        insert ifClass;

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveyOrderERPSent'));
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveryOrderERPFail'));
        alertList.add(TestDataFactoryForSales.createAlertManager('DeliveryOrderERPFailSupport'));
        insert alertList;
        
        DeliveryOrder__c dOrder;
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
            order.ERPPSONo__c  = 'test';
            insert order;

            dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
            insert dOrder;

        }
        ContentVersion testVersion = new ContentVersion(
            Title = 'Test File'
            , VersionData = Blob.valueOf('Test File Content')
            , PathOnClient = 'TestFile.pdf'
        );
        insert testVersion;

        ContentVersion queryVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        ContentDocumentLink testLink = new ContentDocumentLink(
            LinkedEntityId = dOrder.Id
            , ContentDocumentId = queryVersion.ContentDocumentId
            , ShareType = 'V'
        );
        insert testLink;
    }

    @isTest
    static void testValidateDeliveryConfrim() {
        DeliveryOrder__c dOrder = [SELECT Id, Name, Order__c, CapitalNo__c, DestinationZone__c, PlannedGI__c, DeliveryDate__c, Note__c, OwnerId, SalesOffice__c FROM DeliveryOrder__c LIMIT 1];
        Test.startTest();

        DN_DeliveryConfirmRequestController.validateDeliveryConfrim(dOrder.Id);

        dOrder.ERPDONo__c = 'test';
        update dOrder;

        DN_DeliveryConfirmRequestController.validateDeliveryConfrim(dOrder.Id);

        try{
            DN_DeliveryConfirmRequestController.validateDeliveryConfrim(null);
        } catch (Exception e) {
            System.debug('ERROR ::: ' + e.getMessage());
        }
        
        Test.stopTest();
    }

    @isTest
    static void testSetConfirmData() {
        DeliveryOrder__c dOrder = [SELECT Id, Name, Order__c, CapitalNo__c, DestinationZone__c, PlannedGI__c, DeliveryDate__c, Note__c, OwnerId, SalesOffice__c FROM DeliveryOrder__c LIMIT 1];
        Test.startTest();

        DN_DeliveryConfirmRequestController.setConfirmData(dOrder.Id);

        try{
            DN_DeliveryConfirmRequestController.setConfirmData(null);
        } catch (Exception e) {
            System.debug('ERROR ::: ' + e.getMessage());
        }
        
        Test.stopTest();
    }

    @isTest
    static void testRequestConfrim() {
        DeliveryOrder__c dOrder = [SELECT Id, Name, Order__c, CapitalNo__c, DestinationZone__c, PlannedGI__c, DeliveryDate__c, Note__c, OwnerId, SalesOffice__c FROM DeliveryOrder__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_01());
        
        DN_DeliveryConfirmRequestController.requestConfrim(dOrder.Id, null);

        try{
            DN_DeliveryConfirmRequestController.requestConfrim(null, null);
        } catch (Exception e) {
            System.debug('ERROR ::: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    private class MockIF_ERP_01 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "S", "MESSAGE": "Success" } }'
            );
            return res;
        }
    }

}