@isTest
public with sharing class DN_CustomerListModalController_TEST {
    @IsTest
    static void test1(){
        Test.startTest();
            Account acc = TestDataFactoryForDealerPortal.dealer;
            acc.BusinessNumber__c = '1244220';
            //acc.Incoterms__c = null;
            insert acc;
            acc.RecordTypeId = TestDataFactoryForDealerPortal.getRecordType('TradeCustomer','Account').Id;
            update acc;
            System.debug(acc + ' :: acc');
            DN_CustomerListModalController.getCustomList('1244220','Test Dealer');
        
        Test.stopTest();
        
    }

    @IsTest // catch
    static void test2(){
        Test.startTest();
            Account acc = TestDataFactoryForDealerPortal.dealer;
            acc.BusinessNumber__c = '1244220';
            //acc.Incoterms__c = null;
            insert acc;
            acc.RecordTypeId = TestDataFactoryForDealerPortal.getRecordType('TradeCustomer','Account').Id;
            acc.CustomerCode__c =null;
            update acc;
            System.debug(acc + ' :: acc');
            DN_CustomerListModalController.getCustomList('1244220','Test Dealer');
        Test.stopTest();
        
    }
}