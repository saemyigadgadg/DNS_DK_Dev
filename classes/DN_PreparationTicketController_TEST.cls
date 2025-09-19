/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-06-09
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-03-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class DN_PreparationTicketController_TEST {
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

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('PreparationChecklistEdited'));
        insert alertList;

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

            String richTextImg = '<img src="/servlet/servlet.FileDownload?file=12345&amp;refid=ABC123">';

            PreparationCheckList__c preparation = TestDataFactoryForSales.createPreparation(order.Id, acc.Id, con.Id, dealer.Id);
            preparation.Map__c = richTextImg;
            insert preparation;
        }
    }

    @isTest
    static void testUploadFile_NewTicket() {

        User u = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        Order order = [SELECT Id FROM Order LIMIT 1];
        PreparationChecklist__c pre = [SELECT Id FROM PreparationChecklist__c LIMIT 1];

        ContentVersion cv = new ContentVersion(
            Title = '테스트파일.pdf',
            PathOnClient = '테스트파일.pdf',
            VersionData = Blob.valueOf('dummy content')
        );
        insert cv;

        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;

        insert new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = pre.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        Test.startTest();
        DN_PreparationTicketController.uploadFile(
            '테스트파일.pdf',
            EncodingUtil.base64Encode(Blob.valueOf('dummy content')),
            pre.Id
        );
        Test.stopTest();
    }
    

    @isTest
    static void testUploadFile_UpdateTicket_Rejected() {
        User u = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        Order order = [SELECT Id FROM Order LIMIT 1];
        PreparationChecklist__c pre = [SELECT Id FROM PreparationChecklist__c LIMIT 1];

        TriggerHandler.bypassedHandlers = new Set<String>{'TicketTriggerHandler'};
        Case c = new Case(
            Status = 'Reject',
            PreparationChecklist__c = pre.Id
        );
        insert c;

        ContentVersion cv = new ContentVersion(
            Title = 'Checklist Old File',
            PathOnClient = 'Checklist Old File.pdf',
            VersionData = Blob.valueOf('old')
        );
        insert cv;

        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;

        insert new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = pre.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        Test.startTest();
        DN_PreparationTicketController.uploadFile(
            'Checklist New File.pdf',
            EncodingUtil.base64Encode(Blob.valueOf('new file content')),
            pre.Id
        );
        Test.stopTest();
    }

    @isTest
    static void testFetchPreChecklist() {
        User u = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        Order order = [SELECT Id FROM Order LIMIT 1];
        PreparationChecklist__c pre = [SELECT Id FROM PreparationChecklist__c LIMIT 1];

        TriggerHandler.bypassedHandlers = new Set<String>{'TicketTriggerHandler'};
        Case c = new Case(
            Status = 'Reject',
            PreparationChecklist__c = pre.Id
        );
        insert c;


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        DN_PreparationTicketController.fetchPreChecklist(pre.Id);
        Test.stopTest();
    }

    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'image/jpeg');
            res.setBody('mock image content');
            res.setStatusCode(200);
            return res;
        }
    }
}