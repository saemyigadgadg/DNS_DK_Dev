/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2025-04-04
 * @last modified by  : suheon.ha@sobetec.com
**/
@isTest
public with sharing class ContentDocumentTriggerTest {
    public ContentDocumentTriggerTest() {}

    @TestSetup
    static void makeData(){
        Country__c country = TestDataFactoryForService.createKRCountry();
        insert country;

        List<Account> insertAccountList = new List<Account>();
        Account dealerAcc = TestDataFactoryForService.createAccount('Dealer', 'Test Dealer', country);
        dealerAcc.CustomerCode__c = '1311191';
        insertAccountList.add(dealerAcc);
        
        Account shipToAcc = TestDataFactoryForService.createAccount('ShipToParty', 'Test Account', country);
        shipToAcc.CustomerCode__c = '1237758';
        insertAccountList.add(shipToAcc);
        insert insertAccountList;
    }

    @isTest
    static void testContentDocumentTrigger() {
        Test.startTest();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test File';
        contentVersion.PathOnClient = 'TestFile.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        insert contentVersion;
        Test.stopTest();
    }
}