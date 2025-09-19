@isTest
public with sharing class DN_DealerPortalMigSettingController_TEST {
    
    @IsTest
    static void test1(){
        Test.startTest();
            DN_DealerPortalMigSettingController cont = new DN_DealerPortalMigSettingController();
        Test.stopTest();
    }   

    

    @isTest
    static void test2() {
        Account acc = TestDataFactoryForDealerPortal.dealer;
        acc.CustomerCode__c = '112200';
        acc.SalesOffice__c = '1146';
        insert acc;
        DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
        // customer.SourceAccount__c = acc.Id;
        customer.CustomerCode__c ='112200';
        customer.SourceAccountCode__c = '112200';
        insert customer;
        DealerLocation__c location = TestDataFactoryForDealerPortal.getLocation(acc.Id);
        location.DealerCode__c = customer.CustomerCode__c;
        insert location;
        Test.startTest();
            DN_DealerPortalMigSettingController cont = new DN_DealerPortalMigSettingController('DealerLocation');
            
            cont.convertBatch(new List<DealerLocation__c>{location});
            cont.convertBatch2(new List<DealerLocation__c>{location});
            
        Test.stopTest();
    }
}