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
public with sharing class DN_ShareFileForPortalController_TEST {

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
    
            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, dealer, 'Turn_Key');
            insert opty;
        }
    }
    
    @isTest
    static void testFetchInit_Upload_Delete() {
        
        Opportunity opty = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Map<String, String>> testFiles = new List<Map<String, String>>();
        testFiles.add(new Map<String, String>{
            'fileName' => 'TestFile1.txt',
            'base64Data' => EncodingUtil.base64Encode(Blob.valueOf('Sample Text'))
        });

        Test.startTest();
        DN_ShareFileForPortalController.uploadFiles(opty.Id, testFiles);
        DN_ShareFileForPortalController.fetchInit(opty.Id);

        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Title = 'TestFile1.txt'];
        Id cdId = cvList[0].ContentDocumentId;

        DN_ShareFileForPortalController.deleteFile(cdId);
        Test.stopTest();
    }
}