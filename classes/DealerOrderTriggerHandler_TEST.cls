/** 
 * @Class :  DealerOrderTriggerHandler_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 22. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-22 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DealerOrderTriggerHandler_TEST {
    static String partnerUserName ='partDo@test.test.com';
    static String partnerUserName2 ='part2Do@test.test.com';

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
            Account dealer = TestDataFactoryForDealerPortal.dealer;
            System.debug('dealer.CustomerCode__c: ' + dealer.CustomerCode__c);
            insert dealer;
    
            con = TestDataFactoryForDealerPortal.createContact(dealer.Id);
            insert con;
    
            List<Sequence__c> sequenceList = new List<Sequence__c>();
            Sequence__c seq0 = new Sequence__c(
                Name ='DealerCustomer_Dealer',
                Type__c = 'Dealer', 
                Pattern__c = 'C1{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq0);

            Sequence__c seq1 = new Sequence__c(
                Name ='DealerCustomer_Customer',
                Type__c = 'Customer', 
                Pattern__c = 'C5{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq1);

            Sequence__c seq2 = new Sequence__c(
                Name ='DealerOrder_General',
                Type__c = 'General', 
                Pattern__c = 'C8{000000000}',
                SObjectAPI__c = 'DealerOrder__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq2);

            Sequence__c seq3 = new Sequence__c(
                Name ='DealerOrder_Emergency',
                Type__c = 'Emergency', 
                Pattern__c = 'C9{000000000}',
                SObjectAPI__c = 'DealerOrder__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq3);
            insert sequenceList;

            DealerCustomer__c dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(dealer.Id);
            insert dealerCustomer;
    
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
        System.runAs(partnerTestUser) {
            DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(null);
            customer.Name = 'test';
            insert customer;

            DealerCustomerShipTo__c shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(customer.id);
            insert shipTo;
        }
    }

    @isTest
    static void insert_Update_TEST() {
        
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

        System.runAs(partPortalUser) {
            DN_UserDetails currentUser = new DN_UserDetails();

            List<DealerCustomer__c> customers = [ SELECT Id, Name FROM DealerCustomer__c WHERE IsDealer__c = false ];

            List<Product2> partList = [ SELECT Id, ProductCode, FM_MaterialDetails__c FROM Product2 ];
            List<DealerOrder__c> ordreList = new List<DealerOrder__c>();
            DealerOrder__c order = TestDataFactoryForDealerPortal.getOrder(currentUser.getAgencyId(), customers[0].id);
            order.OrderType__c = 'E';
            order.OrderNumber__c = null;
            ordreList.add(order);
            DealerOrder__c order2 = TestDataFactoryForDealerPortal.getOrder(currentUser.getAgencyId(), customers[0].id);
            order2.OrderType__c = 'S';
            order2.OrderNumber__c = null;
            ordreList.add(order2);
            insert ordreList;

            List<DealerOrderItem__c> orderItemList = new List<DealerOrderItem__c>();
            DealerOrderItem__c orderItem = TestDataFactoryForDealerPortal.getOrderItem(order.id, partList[0].id, partList[0].id);
            orderItemList.add(orderItem);
            DealerOrderItem__c orderItem2 = TestDataFactoryForDealerPortal.getOrderItem(order2.id, partList[0].id, partList[0].id);
            orderItemList.add(orderItem2);
            insert orderItemList;

            orderItem2.Delete__c = 'Y';
            update orderItem2;
        }

    }
}