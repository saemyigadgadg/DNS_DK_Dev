@isTest
public with sharing class DN_DealerPortalSettings_TEST {
    @IsTest
    static void test1(){
        
        Test.startTest();
        //DealerAdminPermission
            DN_DealerPortalSettings settings = new DN_DealerPortalSettings('DealerAdminPermission');
            settings.getSettings();
            settings.getSettings().getHasCustomPermission();
            settings.getSettings().getIsSourceMeta();
            DN_DealerPortalSettings.getHighPrioritySettings();
            // try {
            //     DN_DealerPortalSettings settings2 = new DN_DealerPortalSettings('TestPermission');
            //     settings2.getSettings();    
            // } catch (Exception e) {
                
            // } 
            
            // Account dealer = TestDataFactoryForDealerPortal.dealer;
            // insert dealer;
            // Contact con = TestDataFactoryForDealerPortal.createContact(dealer.Id);
            // insert con;
            // User partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
            // partnerTestUser.Username = 'part@test.test.com';
            // insert partnerTestUser;
            // System.runAs(partnerTestUser) {
            //     DN_DealerPortalSettings partnerSettings = new DN_DealerPortalSettings('DealerAdminPermission');
            //     partnerSettings.getSettings();
            //     partnerSettings.getSettings().getHasCustomPermission();
            // }   
        Test.stopTest();
        
    }
}