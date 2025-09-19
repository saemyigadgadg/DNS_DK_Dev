/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2025-04-04
 * @last modified by  : suheon.ha@sobetec.com
**/
@isTest
public with sharing class FeedItemTriggerTest {
    public FeedItemTriggerTest() {}

    @TestSetup
    static void makeData() {
        CollaborationGroup group2 = new CollaborationGroup(
            Name = 'Test Group',
            CollaborationType = 'Private'
        );
        insert group2;

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
    static void testFeedItemTrigger() {
        CollaborationGroup group1 = [SELECT Id FROM CollaborationGroup LIMIT 1];
        Account testacc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        FeedItem feedItem = new FeedItem(
            ParentId = group1.Id,
            Body = 'This is a test feed item.',
            Type = 'TextPost'
        );
        insert feedItem;

        FeedItem recordFeed = new FeedItem(
            ParentId = testacc.Id, 
            Body = 'This is a test record feed item.',
            Type = 'TextPost'
        );
        insert recordFeed;
        Test.stopTest();
    }
}