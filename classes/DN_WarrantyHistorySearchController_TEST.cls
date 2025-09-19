@IsTest
public with sharing class DN_WarrantyHistorySearchController_TEST {
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;
    static Account acc;
    static Contact con;
    static Asset asset;
    static Product2 prod;
    static ProductRequest prodRequest;
    static Case cas;
    static ServiceTerritory serviceTerritory;
    static ServiceResource serviceResource;
    static WorkOrder workOrder;
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
            partnerTestUser.Username = 'part11aass22@test.test.com';
            partnerTestUser.SalesOrganization__c = '1846';
            partnerTestUser.DistributionChannel__c = '10';
            partnerTestUser.Division__c = '40';
            insert partnerTestUser;
        }
        System.runAs(adminTestUser) {
            TestDataFactoryForDealerPortal.assignFLSPermissionSet(partnerTestUser.Id);
            prod = TestDataFactoryForDealerPortal.getPart('R18181','R18181','R18181');
            insert prod;
            asset = TestDataFactoryForDealerPortal.createEquipment(acc.Id);
            asset.OwnerId = partnerTestUser.Id;
            insert asset;
            cas = TestDataFactoryForDealerPortal.createCase(asset.Id);
            cas.OwnerId = partnerTestUser.Id;
            insert cas;
            OperatingHours operatingHours = TestDataFactoryForDealerPortal.createOperatingHours();
            insert operatingHours;
            serviceTerritory = TestDataFactoryForDealerPortal.createWorkCenter(acc.Id,operatingHours.Id);
            serviceTerritory.OwnerId = partnerTestUser.Id;
            insert serviceTerritory;
            serviceResource = TestDataFactoryForDealerPortal.createServiceWorker(partnerTestUser.Id,serviceTerritory.Id);
            serviceResource.OwnerId = partnerTestUser.Id;
            insert serviceResource;
            workOrder = TestDataFactoryForDealerPortal.createServiceOrder(cas.Id,asset.Id,acc.Id,serviceTerritory.Id,serviceResource.Id);
            workOrder.OwnerId = partnerTestUser.Id;
            workOrder.OrderType__c = '201';
            WorkOrder.PMActivityType__c ='CS02';
            
            insert workOrder;
            prodRequest = TestDataFactoryForDealerPortal.createPartClaim(workOrder.Id,prod.Id);
            prodRequest.OwnerId = partnerTestUser.Id;
            insert prodRequest;
        }   
    }

    @IsTest
    static void test1(){
        DN_WarrantyHistorySearchController.SearchOption search = new DN_WarrantyHistorySearchController.SearchOption();
        search.Type='LYNX 220A-NT';
        search.SerialNumber = 'ML0006-006231';
        search.historyStart = DateTime.now().addDays(-7);
        search.historyEnd = DateTime.now().addDays(+7);
        search.orderByField = ' ORDER BY CreatedDate';
        search.orderBy = ' ASC';
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_WarrantyHistorySearchController.getWarrantyHistory(search);
        }
        Test.stopTest();
        
    }        


}