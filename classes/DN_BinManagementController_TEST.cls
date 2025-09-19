@IsTest
public with sharing class DN_BinManagementController_TEST {
    static Account acc;
    static Contact con;
    static DealerLocation__c location;
    
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
            partnerTestUser.Username = 'partSeo1234@test.test.com';
            partnerTestUser.SalesOrganization__c = '1846';
            partnerTestUser.DistributionChannel__c = '10';
            partnerTestUser.Division__c = '40';

            insert partnerTestUser;
        }
        System.runAs(partnerTestUser) {
            location = TestDataFactoryForDealerPortal.getLocation(acc.Id);
            insert location;   
        }
    }

    @IsTest
    static void test1(){
        try {
            
            DN_BinManagementController.PageReturn page = new DN_BinManagementController.PageReturn();
            page.currentPage = 1;
            page.itemsPerPage = 15;
            page.orderBy = 'ASC';
            page.orderByField = 'ORDER BY FM_Loc__c';
            page.pagesPerGroup = 5;
            page.strQuery = new Map<String, String>();
            page.strQuery.put('location', location.Id);
            
            System.runAs(partnerTestUser){
                Test.startTest();
                DN_BinManagementController.setExcelData(page, 1);
                DN_BinManagementController.getDataListQuery(page, 1);
                DN_BinManagementController.locationDelete(new List<String>{location.Id});
                Test.stopTest();    
            }
            
        } catch (Exception e) {
            
        } 
    }

    @IsTest
    static void test2(){
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_BinManagementController.PageReturn page = new DN_BinManagementController.PageReturn();
            page.currentPage = 1;
            page.itemsPerPage = 15;
            page.orderBy = 'ASC';
            page.orderByField = 'ORDER BY FM_Loc__c';
            page.pagesPerGroup = 5;
            page.strQuery = new Map<String, String>();
            page.strQuery.put('location', location.Id);
            try {
                DN_BinManagementController.getDataListQuery(page, 2);
            } catch (Exception e) {
                
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void test3(){
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_BinManagementController.PageReturn page = new DN_BinManagementController.PageReturn();
            page.currentPage = 1;
            page.itemsPerPage = 15;
            page.orderBy = 'ASC';
            page.orderByField = 'ORDER BY FM_Loc__c';
            page.pagesPerGroup = 5;
            page.strQuery = new Map<String, String>();
            page.strQuery.put('location', location.Id);
            try {
                DN_BinManagementController.setExcelData(page, 2);
            } catch (Exception e) {
                
            } 
        }
        Test.stopTest();
        
    }
}