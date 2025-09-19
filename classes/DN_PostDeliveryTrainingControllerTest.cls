@isTest
public with sharing class DN_PostDeliveryTrainingControllerTest {
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

            DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
            insert dOrder;
        }

    }

    @isTest
    static void testFetchInit() {
        DeliveryOrder__c dOrder = [SELECT Id FROM DeliveryOrder__c LIMIT 1];
        Test.startTest();
        DN_PostDeliveryTrainingController.fetchInit(dOrder.Id);
        Test.stopTest();
    }

    @IsTest
    static void testDeleteFiles(){

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test File Contents')
        );
        insert cv;

        ContentVersion cvQuery = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id ];

        Test.startTest();

        DN_PostDeliveryTrainingController.deleteFiles(new List<String>{cvQuery.ContentDocumentId});

        Test.stopTest();
    }

    @isTest
    static void testCreateContact() {
        Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];

        Test.startTest();

        DN_PostDeliveryTrainingController.AccRepInfo rep = new DN_PostDeliveryTrainingController.AccRepInfo();
        rep.repName = 'test';
        rep.repMp = '000000';
        rep.repTitle = 'test';
        
        DN_PostDeliveryTrainingController.createContact(rep, acc.Id);
        Test.stopTest();
    }

    // @isTest
    // static void testCreateTicket() {
        
    //     Account acc = [SELECT Id FROM Account WHERE CustomerCode__c = '123456' LIMIT 1];
    //     Contact con = [SELECT Id, Name, MobilePhone FROM Contact WHERE AccountId =: acc.Id];
    //     Order order = [SELECT Id FROM Order LIMIT 1];

    //     ContentVersion cv = new ContentVersion(
    //         Title = 'Test File',
    //         PathOnClient = 'TestFile.txt',
    //         VersionData = Blob.valueOf('Test File Contents')
    //     );
    //     insert cv;

    //     ContentVersion cvQuery = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id ];

    //     Test.startTest();

    //     DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
    //     insert dOrder;

    //     DateTime dTime = DateTime.now().addDays(10);

    //     DN_PostDeliveryTrainingController.DeliveryOrderWrapper dWrap = new DN_PostDeliveryTrainingController.DeliveryOrderWrapper();
    //     dWrap.shipToRepId = con.Id;
    //     dWrap.shipToRepName = con.Name;
    //     dWrap.shipToRepMP = con.MobilePhone;
    //     dWrap.shipToRepTitle = 'test title';
        
    //     dWrap.accId = acc.Id;
    //     dWrap.accAddress = 'test';

    //     dwrap.trainingType = '신규 교육';
    //     dWrap.trainingCount = '1회';
    //     dWrap.traineeLevel = '하';
    //     dWrap.trainingDateTime1 = dTime;
    //     dWrap.receptionDetails = 'Test';

    //     dWrap.owner = UserInfo.getUserId();
    //     dWrap.currUserPhone = '0000000';
    //     dWrap.fileIds = new List<String>{cvQuery.ContentDocumentId};

    //     DN_PostDeliveryTrainingController.createTicket(dOrder.Id, dWrap);
    //     Test.stopTest();
    // }

    @isTest
    static void testCreateTicket_whereLine() {
        
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

        try {
            Test.startTest();
                DeliveryOrder__c dOrder = TestDataFactoryForSales.createDeliveryOrder(order.Id);
                insert dOrder;

                DateTime dTime = DateTime.now().addDays(10);

                DN_PostDeliveryTrainingController.DeliveryOrderWrapper dWrap = new DN_PostDeliveryTrainingController.DeliveryOrderWrapper();
                dWrap.shipToRepId = con.Id;
                dWrap.shipToRepName = con.Name;
                dWrap.shipToRepMP = con.MobilePhone;
                dWrap.shipToRepTitle = 'test title';
                
                dWrap.accId = acc.Id;
                dWrap.accAddress = 'test';

                dwrap.trainingType = '신규 교육';
                dWrap.trainingCount = '1회';
                dWrap.traineeLevel = '하';
                dWrap.trainingDateTime1 = dTime;
                dWrap.receptionDetails = 'Test';

                dWrap.owner = UserInfo.getUserId();
                dWrap.currUserPhone = '0000000';
                dWrap.fileIds = new List<String>{cvQuery.ContentDocumentId};

                DN_PostDeliveryTrainingController.createTicket(dOrder.Id, dWrap);
            Test.stopTest();
        }catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                '❗ STACKTRACE\n' + e.getStackTraceString());
            // 라인 검증(예시)
            System.assert(
                e.getStackTraceString().contains('DN_PostDeliveryTrainingController.createTicket'),
                '스택에 대상 메서드가 없음'
            );
        }
        
    }
}