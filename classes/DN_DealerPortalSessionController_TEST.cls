@IsTest
public with sharing class DN_DealerPortalSessionController_TEST {
    static Account acc;
    static DealerCustomer__c customer;
    static {
        acc = TestDataFactoryForDealerPortal.dealer;
        insert acc;
        customer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
        insert customer;
    }

    @IsTest
    static void test1(){
        Test.startTest();
        DN_DealerPortalSessionController.getSession();
        DN_DealerPortalSessionController.getDealerCustomer(customer.Id);
        DN_DealerPortalSessionController.getDealerCustomer('test');
        Test.stopTest();
    }

    
}