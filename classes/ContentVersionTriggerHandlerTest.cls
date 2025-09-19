@isTest
public with sharing class ContentVersionTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        TriggerHandler.bypassedHandlers = new Set<String>{
            'AccountTriggerHandler'
            , 'SalesAreaDataTrigger'
            , 'OpportunityTriggerHandler'
            , 'PSTriggerHandler'
        };

        Product2 prod = TestDataFactoryForSales.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        insert acc;

        SalesAreaData__c area = TestDataFactoryForSales.createAreaData(acc);
        insert area;

        Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        insert con;

        Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, thisUser, 'General');
        insert opty;

        OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
        insert oItem;

        PS__c newPs = new PS__c();
        newPs.Opportunity__c = opty.Id;
        newPs.RequiredDelivryDate__c = Date.today();
        insert newPs;

    }

    @isTest
    static void testPrefixBizReg() {
        PS__c ps = [SELECT Id FROM PS__c LIMIT 1];

        ContentVersion cv = new ContentVersion(
            Title                   = 'MyBondFile',
            PathOnClient            = 'MyBondFile.docx',
            VersionData             = Blob.valueOf('Test'),
            FileType__c             = 'bond',
            FirstPublishLocationId  = ps.Id
        );

        Test.startTest();
        insert cv;
        Test.stopTest();
    }

    @isTest
    static void testDuplicateFileError() {
        PS__c ps = [SELECT Id FROM PS__c LIMIT 1];
        Test.startTest();

        ContentVersion cv1 = new ContentVersion(
            Title                   = 'DupFile',
            PathOnClient            = 'DupFile1.txt',
            VersionData             = Blob.valueOf('Test'),
            FileType__c             = 'map',
            FirstPublishLocationId  = ps.Id
        );
        insert cv1;

        ContentVersion cv2 = new ContentVersion(
            Title                   = 'DupFile',
            PathOnClient            = 'DupFile2.txt',
            VersionData             = Blob.valueOf('Test'),
            FileType__c             = 'map',
            FirstPublishLocationId  = ps.Id
        );

        try {
            insert cv2;
        } catch (Exception e) {
            System.debug('ERROR');
        }
        Test.stopTest();
    }

    @isTest
    static void testStatusError() {
        PS__c ps = [SELECT Id FROM PS__c LIMIT 1];
        Test.startTest();

        TriggerHandler.bypassedHandlers = new Set<String>{'PSTriggerHandler'};

        ps.Status__c = 'SalesReview';
        update ps;

        ContentVersion cv1 = new ContentVersion(
            Title                   = 'DupFile',
            PathOnClient            = 'DupFile1.txt',
            VersionData             = Blob.valueOf('Test'),
            FileType__c             = 'map',
            FirstPublishLocationId  = ps.Id
        );

        try {
            insert cv1;
        } catch (Exception e) {
            System.debug('ERROR');
        }

        Test.stopTest();
    }

    @isTest
    static void testCDLINK() {
        PS__c ps = [SELECT Id FROM PS__c LIMIT 1];
        Test.startTest();

        ContentVersion cv1 = new ContentVersion(
            Title                   = 'DupFile',
            PathOnClient            = 'DupFile1.txt',
            VersionData             = Blob.valueOf('Test'),
            FileType__c             = 'map'
        );
        insert cv1;

        ContentVersion cvInserted = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        ContentDocumentLink cdLink = new ContentDocumentLink(
            ContentDocumentId = cvInserted.ContentDocumentId,
            LinkedEntityId = ps.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdLink;

        Test.stopTest();
    }

    @isTest
    static void testDistribution() {
        PS__c ps = [SELECT Id FROM PS__c LIMIT 1];
        Test.startTest();

        ContentVersion cv1 = new ContentVersion(
            Title                   = 'DupFile',
            PathOnClient            = 'DupFile1.txt',
            VersionData             = Blob.valueOf('Test'),
            FileType__c             = 'map',
            FirstPublishLocationId  = ps.Id
        );

        insert cv1;
        Test.stopTest();
    }
}