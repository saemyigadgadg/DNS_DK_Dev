@IsTest
public with sharing class DN_WithoutSharingDealerPortal_TEST {
    static Account acc;
    static {
        acc = TestDataFactoryForDealerPortal.dealer;
        insert acc;
    }
    @IsTest
    static void test1(){
        
        Test.startTest();
        DN_WithoutSharingDealerPortal.withoutSearchSeller('SELECT Id,Name,CustomerCode__c FROM Account');
        Test.stopTest();
        
    }
}