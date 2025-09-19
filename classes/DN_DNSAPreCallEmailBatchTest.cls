@isTest
public with sharing class DN_DNSAPreCallEmailBatchTest {
    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        User dealer;
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
        RecordType product_recordType = TestDataFactoryForSales.getRecordType('ServicePackage', 'Product2');
        Product2 prod = TestDataFactoryForSales.createProduct();
        prod.RecordTypeId = product_recordType.Id;
        prod.Field2__c = '1개월;2개월;3개월;4개월;';
        prod.OilChangeCycle__c = '1개월;2개월;3개월;4개월;';
        prod.StandardDay__c = '판매일';
        prod.IsActive = true;
        prod.ServicePackage__c = '각종 오일 교체';
        prod.StandardOilDay__c = '판매일';
        insert prod;
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'OpportunityTriggerHandler', 'QuoteTriggerHandler', 'OrderTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert dealer;
        }

        RecordType campaign_recordType = TestDataFactoryForSales.getRecordType('DNSAPreCall', 'Campaign');
        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
            acc.CustomerCode__c   = '123456';
            acc.BusinessNumber__c = '5148171773';
            acc.Representative__c = 'realAcc';
            acc.ServiceManager__c = 'test011@email.com';
            acc.PartsManagerEmail__c = 'test012@email.com';
            insert acc;

            Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
            insert con;
    
            PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
            insert entry;    

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'General');
            insert opty;

            OpportunityLineItem oItem = TestDataFactoryForSales.createOptyItem(opty, entry, prod);
            insert oItem;

            Quote quote = TestDataFactoryForSales.createDNSDomesticQuote(dealer, opty, 'Korea');
            insert quote;

            QuoteLineItem qItem = TestDataFactoryForService.createQuoteItem(quote, entry, oItem, prod);
            insert qItem;

            Order order = TestDataFactoryForService.createDNSDomesticOrder(acc, opty, quote, dealer, 'DNS');
            order.CreatedDate = Date.newInstance(2025, 1, 22);
            insert order;
            Asset ass = new Asset();
            ass.Name            = 'ML0006-006231';
            ass.MachineName__c  = 'LYNX 220A-NT';
            ass.Material__c     = 'L22ANT-F0TP-0-K30';
            ass.SerialNumber    = 'ML0006-006231';
            ass.Status          = 'AVLB';
            ass.AccountId       = acc.Id;
            ass.SoldTo__c       = acc.Id;
            ass.Order__c        = order.Id;
            insert ass;

            Asset ass2 = new Asset();
            ass2.Name            = 'ML0006-006233';
            ass2.MachineName__c  = 'LYNX 221A-NT';
            ass2.Material__c     = 'L22ANT-F0TP-0-K31';
            ass2.SerialNumber    = 'ML0006-006232';
            ass2.Status          = 'AVLB';
            ass2.AccountId       = acc.Id;
            ass2.SoldTo__c       = acc.Id;
            ass2.Order__c        = order.Id;
            insert ass2;

            Campaign cp = new Campaign();
            cp.Name = 'Test Campaign';
            cp.ExtractCheck__c = false;
            cp.CampaignType__c = 'ServiceCampaign';
            cp.Purpose__c = 'test';
            cp.Description = 'test';
            cp.MailContents__c = 'mail text';
            cp.Pre__c = 'Pre-call';
            insert cp;

            Campaign cp2 = new Campaign();
            cp2.Name = 'Test Campaign';
            cp2.ExtractCheck__c = false;
            cp2.CampaignType__c = 'ServiceCampaign';
            cp2.Purpose__c = 'test';
            cp2.Description = 'test';
            cp2.Pre__c = 'Pre-call';
            insert cp2;

            CampaignAsset__c ca = new CampaignAsset__c();
            ca.Campaign__c = cp.Id;
            ca.Equipment__c = ass.Id;
            insert ca;

            CampaignAsset__c ca2 = new CampaignAsset__c();
            ca2.Campaign__c = cp.Id;
            ca2.Equipment__c = ass2.Id;
            insert ca2;

            CommonPart__c comPart = new CommonPart__c();
            comPart.PartsNo__c = '123';
            comPart.Quantity__c = 1;
            comPart.Campaign__c = cp.Id;
            insert comPart;

            ContentVersion cv = new ContentVersion();
            cv.Title = '파일2';
            cv.VersionData = Blob.valueOf('Test Content Data');
            cv.PathOnClient = '파일1.png';
            insert cv;

            String contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = contentDocumentId,
                LinkedEntityId = cp.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            insert cdl;
        }

        OperatingHours oh = new OperatingHours();
        oh.Name     = 'DNSA Operating Hours_ Los Angeles';
        oh.TimeZone = 'America/Los_Angeles';
        insert oh;
    }

    @isTest
    static void testBatch() {
        Test.startTest();
        System.schedule('Test Scheduled Batch', '0 0 0 * * ?', new DN_DNSAPreCallEmailBatch());
        Database.ExecuteBatch(new DN_DNSAPreCallEmailBatch());
        Test.stopTest();
    }

    // @isTest
    // static void testGetRecordInfo(){        
    //     Test.startTest();
    //     DN_DNSAPreCallEmailBatch.dummy();
    //     Test.stopTest();
    // }
}