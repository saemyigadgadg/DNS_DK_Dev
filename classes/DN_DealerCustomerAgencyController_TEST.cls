@IsTest
public with sharing class DN_DealerCustomerAgencyController_TEST {
    static Account acc;
    static {
        acc = TestDataFactoryForDealerPortal.dealer;
        insert acc;
    }

    @IsTest
    static void test1(){
        
        Test.startTest();
        List<Account> accLIst =[
            SELECT Id,Name,AccountNameEnglish__c ,
            SalesOrganization__c,DistributionChannel__c,
            Division__c,CustomerCode__c,BusinessNumber__c,
            sggNm__c,Phone,Representative__c,TypeOfBusiness__c,
            ShippingStreet,ShippingPostalCode,ShippingCity,
            DetailAddress__c
            FROM Account
        ];
        DN_DealerCustomerAgencyController.insertAgency(accLIst);
        Test.stopTest();
        
    }
}