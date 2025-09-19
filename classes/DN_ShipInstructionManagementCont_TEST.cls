@IsTest
public with sharing class DN_ShipInstructionManagementCont_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;
    static DealerCustomer__c customer;
    static DealerStock__c stock;
    static DealerOrder__c dealerOrder;
    static DealerOrderItem__c dealerOrderItem;
    static ShipmentOrder__c shipOrder;
   
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;
    static {
        List<User> userList = new List<User>();
        adminTestUser = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser.SalesOrganization__c = '1800';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';
        adminTestUser.SalesOffice__c = '414A';
        adminTestUser.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser);

        adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser2.SalesOrganization__c = '1800';
        adminTestUser2.DistributionChannel__c = '10';
        adminTestUser2.Division__c = '40';
        adminTestUser2.SalesOffice__c = '414A';
        adminTestUser2.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser2);
        insert userList;
        System.runAs(adminTestUser) {
            acc = TestDataFactoryForDealerPortal.dealer;
            insert acc;
            con = TestDataFactoryForDealerPortal.createContact(acc.Id);
            insert con;
            prod = TestDataFactoryForDealerPortal.getPart('R18181','R18181','R18181');
            insert prod;
            Sequence__c seq = TestDataFactoryForDealerPortal.getSequence('DealerCustomer', 'DealerCustomer__c', 'Customer', 'C5{000000}}');
            insert seq;
            Sequence__c seq2 = TestDataFactoryForDealerPortal.getSequence('DealerOrder_General', 'DealerOrder__c', 'General', 'C8{000000000}');
            insert seq2;
            Sequence__c seq3 = TestDataFactoryForDealerPortal.getSequence('ShipmentOrder__c', 'ShipmentOrder__c', 'ShipmentOrder', 'C2{000000000}');
            insert seq3;

            
            
        }   
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'partSeo11@test.test.com';
            insert partnerTestUser;
        }
        System.runAs(partnerTestUser) {
            stock = TestDataFactoryForDealerPortal.createDealerStock(acc.Id,prod.Id);
            insert stock;
            customer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
            insert customer;
            dealerOrder = TestDataFactoryForDealerPortal.getOrder(acc.Id,customer.Id);
            insert dealerOrder;
            dealerOrderItem = TestDataFactoryForDealerPortal.getOrderItem(dealerOrder.Id,prod.Id,prod.Id);
            insert dealerOrderItem;
            shipOrder = TestDataFactoryForDealerPortal.getShipmentOrder(acc.Id,dealerOrderItem.Id);
            shipOrder.DeliveryOrder__c = 'testOrder';
            insert shipOrder;
        }
            
        
    }

    @IsTest
    static void test1(){
        try {
            Datetime dateStart = Datetime.now().addDays(-7);
            Datetime dateEnd = Datetime.now().addDays(7);
            DN_ShipInstructionManagementController.PageReturn page = new DN_ShipInstructionManagementController.PageReturn();
            page.currentPage = 1;
            page.itemsPerPage = 100;
            page.orderBy = 'DESC';
            page.orderByField = 'order by LastModifiedDate';
            page.pagesPerGroup = 5;
            Map<String,Object> strQuery = new Map<String,Object>();
            strQuery.put('DeliveryOrder__c','testOrder');
            strQuery.put('dateStart',dateStart.format('yyyy-MM-dd'));
            strQuery.put('dateEnd',dateEnd.format('yyyy-MM-dd'));
            page.strQuery = strQuery;
            System.runAs(partnerTestUser){
                Test.startTest();
                    DN_ShipInstructionManagementController.getDataListQuery(page,1);
                Test.stopTest();    
            }
        } catch (Exception e) {

        } 
    }

    @IsTest
    static void test2(){
        DN_ShipInstructionManagementController.ShipmentOrder shipOrderClass = new DN_ShipInstructionManagementController.ShipmentOrder();
        shipOrderClass.id = shipOrder.Id;
        shipOrderClass.quantity = 1;
        DN_ShipInstructionManagementController.OrderGroup orderGroup = new DN_ShipInstructionManagementController.OrderGroup();
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_ShipInstructionManagementController.updateQuantity(new List<DN_ShipInstructionManagementController.ShipmentOrder>{shipOrderClass});
        }
        Test.stopTest();
        
    }
    
}