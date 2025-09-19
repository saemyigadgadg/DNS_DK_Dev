/** 
 * @Class :  DealerPurchaseOrderItemTriggerHan_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 24. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-24 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DealerPurchaseOrderItemTriggerHan_TEST {
    static String partnerUserName ='partPoIt@test.test.com';
    static String partnerUserName2 ='part2PoIt@test.test.com';

    @TestSetup
    static void makeData(){
        List<User> userList = new List<User>();
        User adminTestUser = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser.SalesOrganization__c = '1800';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';
        adminTestUser.SalesOffice__c = '1146';
        // adminTestUser.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser);

        User adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser2.SalesOrganization__c = '1800';
        adminTestUser2.DistributionChannel__c = '10';
        adminTestUser2.Division__c = '40';
        adminTestUser2.SalesOffice__c = '1146';
        // adminTestUser2.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser2);

        insert userList;

        Contact con;
        System.runAs(adminTestUser) {
            List<Account> accList = new List<Account>();
            Account dealer = TestDataFactoryForDealerPortal.dealer;
            dealer.DealerGrade__c = 'A';
            System.debug('dealer.CustomerCode__c: ' + dealer.CustomerCode__c);
            accList.add(dealer);

            Account dealer2 = TestDataFactoryForDealerPortal.dealer2;
            dealer2.CustomerCode__c = '1233';
            dealer2.DealerGrade__c = 'B';
            accList.add(dealer2);

            Account dealer3 = TestDataFactoryForDealerPortal.createAccountDelear('Test3');
            dealer3.CustomerCode__c = '1234';
            dealer3.DealerGrade__c = 'C';
            accList.add(dealer3);
            insert accList;
    
            con = TestDataFactoryForDealerPortal.createContact(dealer.Id);
            insert con;
    
            List<Sequence__c> sequenceList = new List<Sequence__c>();
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerCustomer_Customer', 'DealerCustomer__c', 'Customer', 'C5{000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerOrder_General', 'DealerOrder__c', 'General', 'C8{000000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerOrder_Emergency', 'DealerOrder__c', 'Emergency', 'C9{000000000}'));
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerPurchaseOrder', 'DealerPurchaseOrder__c', 'DealerPO', 'C4{000000000}'));
            insert sequenceList;

            List<DealerCustomer__c> dealerList = new List<DealerCustomer__c>();
            DealerCustomer__c dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(dealer.Id);
            dealerList.add(dealerCustomer);
            DealerCustomer__c dealerCustomer2 = TestDataFactoryForDealerPortal.getCustomer(dealer2.Id);
            dealerList.add(dealerCustomer2);
            DealerCustomer__c dealerCustomer3 = TestDataFactoryForDealerPortal.getCustomer(dealer3.Id);
            dealerList.add(dealerCustomer3);
            insert dealerList;
    
            List<Product2> partList = new List<Product2>();
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18181', 'R18181영문', 'R18181국문')
            );
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18182', 'R18182영문', 'R18182국문')
            );
            insert partList;
        
            List<ProductByPlant__c> plantByProductList = new List<ProductByPlant__c>();
            plantByProductList.add(TestDataFactoryForDealerPortal.getProductByPlant(partList[0].Id,partList[1].Id));
            plantByProductList.add(TestDataFactoryForDealerPortal.getProductByPlant(partList[1].Id,partList[1].Id));
            insert plantByProductList;
            
        }
    
        User partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
        partnerTestUser.SalesOrganization__c = '1846';
        partnerTestUser.DistributionChannel__c = '10';
        partnerTestUser.Division__c = '40';
        partnerTestUser.Username = partnerUserName;
        insert partnerTestUser;

        System.runAs(adminTestUser) {
        
            List<DealerCustomer__c> dealerCustomerList =  [SELECT Id, OwnerId FROM DealerCustomer__c];
            for(DealerCustomer__c dealderCustomer : dealerCustomerList) {
                dealderCustomer.OwnerId = partnerTestUser.Id;
            }
            update dealerCustomerList;
        }

        System.runAs(partnerTestUser) {
            DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(null);
            customer.Name = 'test';
            insert customer;

            DealerCustomerShipTo__c shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(customer.id);
            insert shipTo;
        }
    }

    @isTest
    static void execute_TEST() {
        Test.startTest();

        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();

            List<Account> accList = [SELECT Id FROM Account];
            System.debug('accList.size : '+accList.size());
        
            String currAccountId = currentUser.getAgencyId();
            List<DealerCustomer__c> dealers = [SELECT Id FROM DealerCustomer__c WHERE IsDealer__c = true AND SourceAccount__c != :currAccountId ];
            List<Product2> partList = [SELECT Id FROM Product2];

            DealerPurchaseOrder__c po = TestDataFactoryForDealerPortal.getDealerPur(currAccountId, dealers[0].Id);
            insert po;

            DealerPurchaseOrderItem__c poItem = TestDataFactoryForDealerPortal.getDealerPurItem(po.Id, partList[0].Id, partList[0].Id);
            poItem.Status__c = '0';
            insert poItem;


            // DealerPurchaseOrderItemTriggerHandler handler = new DealerPurchaseOrderItemTriggerHandler();
            // handler.generateStatusHistory()
            // 변경요청('2')으로 변경시 -> History적재
            poItem.Status__c = '2';
            poItem.Quantity__c = 1;
            poItem.ChangeQuantity__c = 2;
            update poItem;

            // 삭제요청('3')으로 변경시 -> History적재
            poItem.Status__c = '3';
            poItem.Quantity__c = 1;
            poItem.ChangeQuantity__c = 2;
            update poItem;
        }

        Test.stopTest();
    }
}