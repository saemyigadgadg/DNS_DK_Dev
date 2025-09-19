@IsTest
public with sharing class DN_DealerLeadTimeManagementCont_TEST {
    static Account acc;
    static Contact con;
    static Product2 prod;
    static ProductByPlant__c prodByPlant;
    static DealerLeadTimeManagement__c leadTime;
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
            partnerTestUser.Username = 'tes2afoeic@test.test.com';
            partnerTestUser.SalesOrganization__c = '1846';
            partnerTestUser.DistributionChannel__c = '10';
            partnerTestUser.Division__c = '40';

            insert partnerTestUser;
        }
        System.runAs(adminTestUser) {
            prod = TestDataFactoryForDealerPortal.getPart('R18181','R18181','R18181');
            insert prod;
            prodByPlant = TestDataFactoryForDealerPortal.getProductByPlant(prod.Id,prod.Id);
            prodByPlant.OwnerId = partnerTestUser.Id;
            insert prodByPlant;
            leadTime = TestDataFactoryForDealerPortal.createLeadTime(prod.Id);
            leadTime.ExternalKey__c = '1846_'+prod.ProductCode;
            leadTime.OwnerId = partnerTestUser.Id;
            insert leadTime;

        }   
        
    }

    @IsTest
    static void test1(){
        DealerLeadTimeManagement__c ltTime = [
            SELECT Id,Part__r.ProductCode,
            Part__r.FM_MaterialDetails__c,Part__r.MaterialGroupCode__c,
            Plant__c,PlannedDeliveryDays__c,LastModifiedDate,
            LastModifiedBy.Name,ExternalKey__c
            FROM DealerLeadTimeManagement__c LIMIT 1
        ];
        DN_DealerLeadTimeManagementController.LeadTimeManagement leadTimeClass = new DN_DealerLeadTimeManagementController.LeadTimeManagement(ltTime);
        DN_DealerLeadTimeManagementController.LeadTimeManagement leadTimeClass2 = new DN_DealerLeadTimeManagementController.LeadTimeManagement(ltTime);
        leadTimeClass2.material ='R18182';
        leadTimeClass2.externalKey = '1846_R18182';
        leadTimeClass.isStatus = true;
        Test.startTest();
        System.runAs(partnerTestUser){
            Map<String,Object> whereCondition = new Map<String,Object>();
            whereCondition.put('plant','1846');
            whereCondition.put('productCode',prod.Id);
            DN_DealerLeadTimeManagementController.getDataList(whereCondition);
            DN_DealerLeadTimeManagementController.leadTimeSave(new List<DN_DealerLeadTimeManagementController.LeadTimeManagement>{leadTimeClass});
            
            DN_DealerLeadTimeManagementController.uploadDataCheck(new List<DN_DealerLeadTimeManagementController.LeadTimeManagement>{leadTimeClass,leadTimeClass2});
        }
        Test.stopTest();
        
    }
}