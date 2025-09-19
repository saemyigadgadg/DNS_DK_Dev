@IsTest
public with sharing class DN_OrderedGITableController_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;
    static DealerCustomer__c customer;
    static DealerOrder__c dealerOrder;
    static DealerOrderItem__c dealerOrderItem;
    static DealerStock__c stock;
    static ShipmentOrder__c shipmentOrder;
    static DealerInventoryMovements__c goodsIssue;
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
            Sequence__c seq =TestDataFactoryForDealerPortal.getSequence('ShipmentOrder__c', 'ShipmentOrder__c', 'ShipmentOrder', 'C2{000000000}');
            insert seq;
            Sequence__c seq2 =TestDataFactoryForDealerPortal.getSequence('DealerCustomer', 'DealerCustomer__c', 'Customer', 'C5{000000}');
            insert seq2;
            Sequence__c seq3 =TestDataFactoryForDealerPortal.getSequence('DealerOrder_General', 'DealerOrder__c', 'General', 'C8{000000000}');
            insert seq3;
            Sequence__c seq4 =TestDataFactoryForDealerPortal.getSequence('DealerInventoryMovements_GI', 'DealerInventoryMovements__c', 'GoodsIssue', 'C6{000000000}');
            insert seq4;
        }   
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = '111111part@test.test.com';
            insert partnerTestUser;
        }
        System.runAs(partnerTestUser) {
            

            customer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
            insert customer;
            prod = TestDataFactoryForDealerPortal.getPart('R18181','R18181','R18181');
            insert prod;

            dealerOrder = TestDataFactoryForDealerPortal.getOrder(acc.Id,customer.Id);
            insert dealerOrder;
            //System.debug(dealerOrder  + ' ::: dealerOrder');
            dealerOrderItem = TestDataFactoryForDealerPortal.getOrderItem(dealerOrder.Id,prod.Id,prod.Id);
            insert dealerOrderItem;
            stock = TestDataFactoryForDealerPortal.getStock(prod.Id,acc.Id);
            insert stock;
            shipmentOrder = TestDataFactoryForDealerPortal.getShipmentOrder(acc.Id,dealerOrderItem.Id);
            insert shipmentOrder;
            goodsIssue = TestDataFactoryForDealerPortal.getGoodsIssue(acc.Id,prod.Id);
            insert goodsIssue;
        }
            
        
    }

    @IsTest
    static void test1(){
        
        
        DN_OrderedGITableController.SearchFilter search = new DN_OrderedGITableController.SearchFilter();
        search.orderNumber = 'TESTORDER';
        Datetime dateStart = Datetime.now().addDays(-7);
        Datetime dateEnd = Datetime.now().addDays(7);
        search.dateStart = dateStart.format('YYYY-MM-dd');
        search.dateEnd = dateEnd.format('YYYY-MM-dd');
        search.productCode = prod.Id;
        search.accountId = customer.Id;
        System.runAs(partnerTestUser){
            try {
                 
                Test.startTest();
                    DN_OrderedGITableController.getDataList(search, new List<String>());
                    List<DN_OrderedGITableController.ShipmentOrder> shipList = new List<DN_OrderedGITableController.ShipmentOrder>();
                    DN_OrderedGITableController.ShipmentOrder ship = new DN_OrderedGITableController.ShipmentOrder();
                    ship.quantity =1;
                    ship.goodsIssueHistory = 'test11';
                    ship.orderItemId = dealerOrderItem.Id; 
                    shipList.add(ship);
                    DealerOrderItem__c orderItem = [ 
                        select Id,FM_OrderNumber__c,Order__r.Dealer__r.Name,OrderItemNumber__c,
                        Part__r.ProductCode,Part__r.Name,Part__r.FM_MaterialDetails__c,
                        Quantity__c ,Order__r.Customer__r.Name,Order__r.FM_CustomerName__c, 
                        Part__c,Order__r.Id,Order__r.Customer__c ,Order__r.FM_ShipToCode__c,
                        Order__r.FM_Phone__c,ReplacingPart__r.ProductCode, ReplacingPart__r.FM_MaterialDetails__c,ReplacingPart__c
                        from DealerOrderItem__c limit 1
                    ];
                    DN_OrderedGITableController.GoodsIssue good = new DN_OrderedGITableController.GoodsIssue(orderItem);
                    good.gIPossibleQty = 1;
                    DN_OrderedGITableController.insertShipmentOrder(shipList);
                    DN_OrderedGITableController.insertGoodsIssue(new List<DN_OrderedGITableController.GoodsIssue>{good});
                Test.stopTest();    
            } catch (Exception e) {
                
            } 
            
        }
        
    }
}