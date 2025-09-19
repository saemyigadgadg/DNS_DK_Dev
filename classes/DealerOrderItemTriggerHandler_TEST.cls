@isTest
public with sharing class DealerOrderItemTriggerHandler_TEST {
    static Account acc;
    static Contact con;
    static DealerCustomer__c dealerCustomer;
    static Product2 prod;
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;
    static DealerOrder__c dealerOrder;
    static DealerOrderItem__c dealerOrderItem;
    static DealerPurchaseOrder__c dealerPurOrder;
    static DealerPurchaseOrderItem__c dealerPurOrderItem;
    static {
        List<User> userList = new List<User>();
        adminTestUser = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser.SalesOrganization__c = '1146';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';        
        adminTestUser.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser);

        adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser2.SalesOrganization__c = '1146';
        adminTestUser2.DistributionChannel__c = '10';
        adminTestUser2.Division__c = '40';
        adminTestUser2.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser2);
        insert userList;
        System.runAs(adminTestUser) {
            acc = TestDataFactoryForDealerPortal.dealer;
            insert acc;
            con = TestDataFactoryForDealerPortal.createContact(acc.Id);
            con.SalesOrganization__c = '1846';
            insert con;
            prod = TestDataFactoryForDealerPortal.getPart('R18181','R18181','R18181');
            insert prod;
            List<Sequence__c> sequenceList = new List<Sequence__c>();
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerOrder_General', 'DealerOrder__c', 'General', 'C8{000000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerPurchaseOrder', 'DealerPurchaseOrder__c', 'DealerPO', 'C4{000000000}'));
            insert sequenceList;
        }   
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'partSeo1234@test.test.com';
            partnerTestUser.SalesOrganization__c = '1846';
            partnerTestUser.DistributionChannel__c = '10';
            partnerTestUser.Division__c = '40';
            insert partnerTestUser;
            
        }
        
    }
    @IsTest
    static void test(){
        
        Test.startTest();
        System.runAs(adminTestUser) {
            dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
            insert dealerCustomer;
            dealerPurOrder = TestDataFactoryForDealerPortal.getDealerPur(acc.Id,dealerCustomer.Id);
            insert dealerPurOrder;
            dealerPurOrderItem = TestDataFactoryForDealerPortal.getDealerPurItem(dealerPurOrder.Id,prod.Id,prod.Id);
            dealerPurOrderItem.GICompletedQuantity__c =1;
            dealerPurOrderItem.GICompletedDateTime__c =DateTIme.now();
            insert dealerPurOrderItem;
            dealerOrder = TestDataFactoryForDealerPortal.getOrder(acc.Id,dealerCustomer.Id);
            insert dealerOrder;
            dealerOrderItem = TestDataFactoryForDealerPortal.getOrderItem(dealerOrder.Id,prod.Id,prod.Id);
            dealerOrderItem.DealerPurchaseOrderItem__c = dealerPurOrderItem.Id;
            dealerOrderItem.GICompletedQuantity__c =1;
            dealerOrderItem.GICompletedDateTime__c =DateTIme.now();
            insert dealerOrderItem;
            update dealerOrderItem;
        }
        Test.stopTest();
        
    }
}