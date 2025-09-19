@IsTest
public with sharing class DN_AgencyPopupResMultiPartCont_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;   
    static DealerLocation__c location;
    static Asset asset;
    static ModelManager__c model;
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
            location = TestDataFactoryForDealerPortal.getLocation(acc.Id);
            insert location;
            asset = TestDataFactoryForDealerPortal.createEquipment(acc.Id);
            insert asset;
            model = new ModelManager__c(Name='Test Manager', ModelCode__c='Test', Manager__c=adminTestUser.Id, ModelCategory__c='CS_MT_PMA');
            insert model;

        }   
        System.runAs(adminTestUser2) {
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            partnerTestUser.Username = 'partSeo12341@test.test.com';
            partnerTestUser.SalesOrganization__c = '1846';
            partnerTestUser.DistributionChannel__c = '10';
            partnerTestUser.Division__c = '40';
            insert partnerTestUser;
        }
        System.runAs(adminTestUser) {
            asset.OwnerId = partnerTestUser.Id;
            update asset;
        }
        
    }

    @IsTest
    static void test1(){
        System.debug([SELECT Id, MachineName__c, Name FROM Asset WHERE MachineName__c != null AND Name IN('ML0006-006231')]);
        Test.startTest();
        System.runAs(partnerTestUser){
            DN_AgencyPopupResMultiPartController.getParts(new List<String>{'R18181'});
            DN_AgencyPopupResMultiPartController.getStorege(new List<String>{'TESTABC11-11'});
            DN_AgencyPopupResMultiPartController.equipmentInfo(new List<String>{'ML0006-006231'});
            DN_AgencyPopupResMultiPartController.machineInfo(new List<String>{'Test Manager'});
        }
        Test.stopTest();
        
    }
}