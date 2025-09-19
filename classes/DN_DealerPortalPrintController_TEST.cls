@IsTest
public with sharing class DN_DealerPortalPrintController_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;
    static DealerLocation__c location;
    static DealerPurchaseOrder__c dealerPurOrder;
    static DealerPurchaseOrderItem__c dealerPurOrderItem;
    static PurchaseOrder__c purOrder;
    static PurchaseOrderItems__c purOrderItems;
    static DealerStock__c stock;
    static ShipmentOrder__c shipOrder;
    static DealerCustomer__c customer;
    static DealerOrderItem__c orderItem;
    static DealerOrder__c order;
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
        }
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = '4532567788part@test.test.com';
            insert partnerTestUser;
        }
        System.runAs(adminTestUser) {
            location = TestDataFactoryForDealerPortal.getLocation(acc.Id);
            location.OwnerId = partnerTestUser.Id;
            insert location;
            customer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
            customer.OwnerId = partnerTestUser.Id;
            insert customer;
            prod = TestDataFactoryForDealerPortal.getPart('R18181','R18181','R18181');
            insert prod;
            dealerPurOrder = TestDataFactoryForDealerPortal.getDealerPur(acc.Id,customer.Id);
            dealerPurOrder.OwnerId = partnerTestUser.Id;
            insert dealerPurOrder;
            dealerPurOrderItem = TestDataFactoryForDealerPortal.getDealerPurItem(dealerPurOrder.Id,prod.Id,prod.Id);
            insert dealerPurOrderItem;
            purOrder = TestDataFactoryForDealerPortal.getPurOrder(acc.Id);
            purOrder.OwnerId = partnerTestUser.Id;
            insert purOrder;
            purOrderItems = TestDataFactoryForDealerPortal.getPurOrderItem(purOrder.Id,prod.Id);
            insert purOrderItems;
            stock = TestDataFactoryForDealerPortal.getStock(prod.Id, acc.Id);
            stock.OwnerId = partnerTestUser.Id;
            insert stock;
            order = TestDataFactoryForDealerPortal.getOrder(acc.Id, customer.Id);
            order.OwnerId = partnerTestUser.Id;
            insert order;
            orderItem = TestDataFactoryForDealerPortal.getOrderItem(order.id, prod.Id, prod.Id);
            insert orderItem;
        }

        
    }

    @IsTest
    static void test1(){
        
        Test.startTest();
        System.runAs(partnerTestUser) {
            DN_DealerPortalPrintController.getGRGIListPrint(new List<String>{dealerPurOrderItem.Id,purOrderItems.Id},
            new List<Decimal>{1,1},'입고'
            );
            DN_DealerPortalPrintController.getOrderPrint(new List<String>{orderItem.Id});
            DN_DealerPortalPrintController.getStockInfoPrint(new List<String>{prod.ProductCode});
            DN_DealerPortalPrintController.getLocation(new List<String>{location.Id});
            DN_DealerPortalPrintController.StockInfo stockInfo = new DN_DealerPortalPrintController.StockInfo(stock);
        }
        Test.stopTest();
        
    }
    
}