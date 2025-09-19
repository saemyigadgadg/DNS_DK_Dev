@isTest
public with sharing class DN_DeliveryRequestRegistrationTest {
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        // TestDataFactoryForSales.activatePriceBook();

        TriggerHandler.bypassedHandlers = new Set<String>{
            'AccountTriggerHandler'
            , 'OpportunityTriggerHandler'
            , 'QuoteTriggerHandler'
        }; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer.portalRole = 'Manager';
            insert dealer;
        }

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        Interface__c ifc003 = TestDataFactoryForSales.createinterface('IF-DEALER-003', 'Real-Time');
        insert ifc003;

        InterfaceClasses__c ifClass003 = TestDataFactoryForSales.createIFClass('IF_ERP_Dealer', ifc003.Id);
        insert ifClass003;
        
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
    static void testGetOrderInfos() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();

        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHanlder', 'DeliveryOrderTriggerHandler'};
        
        order.SalesChannelType__c = 'Overseas';
        update order;
        DN_DeliveryRequestRegistrationController.getOrderInfos(order.Id);

        order.SalesChannelType__c = 'DomesticPartner';
        update order;
        DN_DeliveryRequestRegistrationController.getOrderInfos(order.Id);

        order.Status = 'OrderMapped';
        order.IsDOBlock__c = true;
        update order;
        DN_DeliveryRequestRegistrationController.getOrderInfos(order.Id);

        order.IsDOBlock__c = false;
        update order;
        DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
        insert dOrder;
        DN_DeliveryRequestRegistrationController.getOrderInfos(order.Id);

        Test.stopTest();
    }

    @isTest
    static void testGetOrderInfos02() {
        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHanlder'};

        Order order = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];
        order.Status = 'OrderMapped';
        order.ShipTo_PSO__c = acc.Id;
        update order;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_DEALER003());
        DN_DeliveryRequestRegistrationController.getOrderInfos(order.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetOrderInfos03() {
        TriggerHandler.bypassedHandlers = new Set<String>{'OrderTriggerHanlder'};

        Order order = [SELECT Id FROM Order LIMIT 1];
        order.Status = 'OrderMapped';
        update order;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_DEALER003E());
        DN_DeliveryRequestRegistrationController.getOrderInfos(order.Id);
        Test.stopTest();
    }

    public class MockIF_ERP_DEALER003 implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "S" }, '
                + '"T_TCREDIT": [ '
                + ' {"RCLAT": "2580840000.00"} '
                + ' ]}'
            );
            return res;
        }
    }

    public class MockIF_ERP_DEALER003E implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{ "O_RETURN": { "TYPE": "E", "MESSAGE": "ERROR" }} '
            );
            return res;
        }
    }

    @isTest
    static void testSaveDO() {
        TriggerHandler.bypassedHandlers = new Set<String>{'PreparationCheckListTriggerHandler', 'ContentDocumentLinkTriggerHandler'};

        Order order = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        User dealer = [SELECT Id FROM User WHERE LastName =: 'dealer' LIMIT 1];

        PreparationCheckList__c preparation = TestDataFactoryForSales.createPreparation(order.Id, acc.Id, con.Id, dealer.Id);
        insert preparation;

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test File Contents')
        );
        insert cv;

        ContentVersion cvQuery = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id ];

        Test.startTest();
        
        DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
        System.runAs(dealer) {

            DN_DeliveryRequestRegistrationController.saveDO(dOrder, new List<String>{cvQuery.ContentDocumentId});
        }
        Test.stopTest();
    }

    @isTest
    static void testCreateContact() {
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];

        Test.startTest();
        DN_DeliveryRequestRegistrationController.createContact('test', '000000', '없음', acc.Id);
        Test.stopTest();
    }

    @isTest
    static void testSaveTicket() {
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];
        Contact con = [SELECT Id, Name, MobilePhone FROM Contact WHERE AccountId =: acc.Id];
        Order order = [SELECT Id FROM Order LIMIT 1];

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test File Contents')
        );
        insert cv;

        ContentVersion cvQuery = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id ];

        Test.startTest();
        DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
        insert dOrder;

        DateTime dTime = DateTime.now().addDays(10);

        DN_DeliveryRequestRegistrationController.DeliveryOrderWrapper dWrap = new DN_DeliveryRequestRegistrationController.DeliveryOrderWrapper();
        dWrap.shipToRepId = con.Id;
        dWrap.shipToRepName = con.Name;
        dWrap.shipToRepMP = con.MobilePhone;
        dWrap.shipToRepTitle = 'test title';
        dWrap.AccountId = acc.Id;
        dWrap.accountShippingAddress = 'test';
        dwrap.trainingType = '신규 교육';
        dWrap.trainingCount = '1회';
        dWrap.traineeLevel = '하';
        dWrap.trainingDateTime1 = dTime;
        dWrap.receptionDetails = 'Test';
        dWrap.trainingDateTime1 = dTime;
        dWrap.owner = UserInfo.getUserId();
        dWrap.FM_ReceptionistMP = '0000000';
        dWrap.fileId = new List<String>{cvQuery.ContentDocumentId};

        DN_DeliveryRequestRegistrationController.saveTicket(dOrder, dWrap);
        Test.stopTest();
    }

    @isTest
    static void testUploadFile() {
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];
        String fileName = 'TestFile.pdf';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        String contentType = 'application/pdf';
        String fileType = 'bizReg';

        Test.startTest();
        DN_DeliveryRequestRegistrationController.uploadFile(fileName, base64Data, contentType, fileType);
        Test.stopTest();
    }

    @IsTest
    static void deleteFileTest(){

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test File Contents')
        );
        insert cv;

        ContentVersion cvQuery = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id ];

        Test.startTest();

        DN_DeliveryRequestRegistrationController.deleteFiles(new List<String>{cvQuery.ContentDocumentId});

        Test.stopTest();
    }

    // @IsTest
    // static void testSendDoToERP(){

    //     ContentVersion cv = new ContentVersion(
    //         Title = 'Test File',
    //         PathOnClient = 'TestFile.txt',
    //         VersionData = Blob.valueOf('Test File Contents')
    //     );
    //     insert cv;

    //     ContentVersion cvQuery = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id ];

    //     Order order = [SELECT Id FROM Order LIMIT 1];
    //     DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
    //     insert dOrder;

    //     Test.startTest();

    //     DN_DeliveryRequestRegistrationController.sendDoToERP(new List<String>{cvQuery.ContentDocumentId});

    //     Test.stopTest();
    // }
}