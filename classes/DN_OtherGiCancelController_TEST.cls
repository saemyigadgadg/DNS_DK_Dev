@IsTest
public with sharing class DN_OtherGiCancelController_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod; 
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;
    static DealerInventoryMovements__c goodsIssue; //3
    static DealerInventoryMovements__c goodsIssueCancel; //1
    static DealerStock__c stock;

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
            List<Sequence__c> sequenceList = new List<Sequence__c>();
            sequenceList.add(TestDataFactoryForDealerPortal.getSequence('DealerInventoryMovements_GI', 'DealerInventoryMovements__c', 'GoodsIssue', 'C6{000000000}'));
            insert sequenceList;


        }   

        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'partSeo12341@test.test.com';
            partnerTestUser.SalesOrganization__c = '1846';
            partnerTestUser.DistributionChannel__c = '10';
            partnerTestUser.Division__c = '40';
            insert partnerTestUser;
        }

        System.runAs(partnerTestUser){
            stock = TestDataFactoryForDealerPortal.createDealerStock(acc.Id,prod.Id);
            stock.CurrentStockQuantity__c = 3;
            stock.AvailableQuantity__c = 3;
            insert stock;
            goodsIssue = TestDataFactoryForDealerPortal.getGoodsIssue(acc.Id,prod.Id);
            goodsIssue.InventoryNumber__c = 'testDOC';
            goodsIssue.InventoryItemNumber__c  = '000010';
            goodsIssue.InventoryChange__c = 'H';
            goodsIssue.Type__c ='O';
            goodsIssue.Quantity__c = 3;
            insert goodsIssue;
            goodsIssueCancel = TestDataFactoryForDealerPortal.getGoodsIssue(acc.Id,prod.Id);
            goodsIssueCancel.GoodsIssue__c = goodsIssue.Id;
            goodsIssueCancel.Type__c = 'O';
            goodsIssueCancel.InventoryChange__c = 'S';
            goodsIssueCancel.Quantity__c = 1;
            insert goodsIssueCancel;
        }
    }

    @IsTest
    static void test1(){
        /**
         * {Account.Name=001F700001jPza0IAC, dateGIEnd=2025-03-26, dateGIStart=2025-03-01, docNumber=123, field=ETC, productCode=01tJO000004NsjlYAC} <<==whereCondition
         */
        Datetime dateGIStart = Datetime.now().addDays(-7);
        Datetime dateGIEnd = Datetime.now().addDays(7);
        Map<String,Object> whereCondition = new Map<String,Object>();
        whereCondition.put('dateGIStart', dateGIStart.format('yyyy-MM-dd'));
        whereCondition.put('dateGIEnd', dateGIEnd.format('yyyy-MM-dd'));
        whereCondition.put('docNumber', 'testDOC');
        whereCondition.put('productCode', prod.Id);
        DN_OtherGiCancelController.OtherGiCancel cancel = new DN_OtherGiCancelController.OtherGiCancel();
        cancel.id = goodsIssue.Id;
        cancel.cancelAvailableQty = 1;
        cancel.cancelRequestQty = 1;
        cancel.currentStockQuantity = 2;
        cancel.goodsIssueDate = Datetime.now().format('yyyy-MM-dd');
        cancel.inventoryNumber = 'testDOC';
        cancel.itemNumber = '000010';
        cancel.part = prod.Id;
        cancel.partName = prod.Name;
        cancel.quantity = 1;

        Test.startTest();
        System.runAs(partnerTestUser){
            DN_OtherGiCancelController.getData(whereCondition,'order by LastModifiedDate','desc');
            System.debug([select 
            Id,Name ,Part__c,
            CustomerPrice__c,
            DiscountPrice__c,
            DiscountAmount__c
            from DealerInventoryMovements__c]);
            DN_OtherGiCancelController.cancelGI(new List<DN_OtherGiCancelController.OtherGiCancel>{cancel});
        }
        Test.stopTest();
        
    }

}