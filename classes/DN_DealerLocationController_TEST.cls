@isTest
public with sharing class DN_DealerLocationController_TEST {
    static Account acc;
    static Contact con;
    static Account acc2;
    static Contact con2;
    static User adminTestUser;
    static User adminTestUser2;
    static User partnerTestUser;
    static DealerLocation__c location;
    static Product2 prod;
    static
    {
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
            location = TestDataFactoryForDealerPortal.getLocation(acc.Id);
            insert location;
            prod = TestDataFactoryForDealerPortal.getPart('R18181', 'R18181','R18181');
            insert prod;
        }

        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'part@test.test.com';
            insert partnerTestUser;
        }
    }

    @IsTest
    static void test1(){
        System.debug([select Id, Name, Description__c, Loc6__c, Loc5__c, Loc4__c, Loc3__c, Loc2__c, Loc1__c, Dealer__c, Division__c, DistributionChannel__c, SalesOrganization__c, FM_Loc__c from DealerLocation__c ] + ' test111');
        System.debug(acc.Id+ ' test2222');
        DealerLocation__c location =[select Id, Name, Description__c, Loc6__c, Loc5__c, Loc4__c, Loc3__c, Loc2__c, Loc1__c, Dealer__c, Division__c, DistributionChannel__c, SalesOrganization__c, FM_Loc__c 
                                                        from DealerLocation__c 
                                                        where Dealer__c =:acc.Id LIMIT 1];
        Test.startTest();
        System.debug(location + ' ::: location');
        System.runAs(partnerTestUser){
            DN_DealerLocationController.getInit();
            DN_DealerLocationController.getSettingCheck(location.FM_Loc__c,prod.Id);
            DealerLocation__c loc = new DealerLocation__c(
                Loc1__c ='test11',
                Loc2__c ='test22',
                Loc3__c ='test33',
                Loc4__c ='test44',
                Loc5__c ='',
                Loc6__c ='',
                Dealer__c = acc.Id
            );
            DN_DealerLocationController.insertLocationCheck(new List<DealerLocation__c>{loc});
            loc.Loc4__c = 'aaaaaaa';
            DN_DealerLocationController.insertLocation(new List<DealerLocation__c>{loc}); 
        }
        System.runAs(adminTestUser) {
            DN_DealerLocationController.deleteLocation(location.Id);
        }
        Test.stopTest();   
    }

    @IsTest
    static void test2(){
        Test.startTest();
        System.runAs(partnerTestUser){
            DealerLocation__c dupLoc = new DealerLocation__c(
                Loc1__c = 'TESTABC11',
                Loc2__c = '11',
                Loc3__c ='',
                Loc4__c ='',
                Loc5__c ='',
                Loc6__c ='',
                Dealer__c = acc.Id
            );
            try {
                DN_DealerLocationController.insertLocationCheck(new List<DealerLocation__c>{dupLoc});
            } catch (Exception e) {
                
            } 
            try {
                DN_DealerLocationController.insertLocation(new List<DealerLocation__c>{dupLoc});
            } catch (Exception e) {
                
            }
            try {
                DN_DealerLocationController.insertLocationCheck(new List<DealerLocation__c>());
            } catch (Exception e) {
                
            } 
            try {
                DN_DealerLocationController.insertLocation(new List<DealerLocation__c>());
            } catch (Exception e) {
                
            }
            try {
                DN_DealerLocationController.getSettingCheck('test11asdas',prod.Id);
            } catch (Exception e) {
                
            }
        }
        Test.stopTest();
    }

   

}