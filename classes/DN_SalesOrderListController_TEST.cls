@isTest
public with sharing class DN_SalesOrderListController_TEST {
    @IsTest
    static void test1(){
        RecordType type = [SELECT Id FROM RecordType WHERE DeveloperName ='DNS' AND SobjectType	='Order'];
        Account acc = TestDataFactoryForDealerPortal.dealer;
        //acc.ShippingStreet
        insert acc;
        Order order = new Order(
            ERPOrderNo__c ='test1234',
            ERPPSONo__c = 'test1234',
            AccountId = acc.Id,
            PaymentTerms__c=null,
            RecordTypeId = type.Id,
            Status = 'Created',
            EffectiveDate = date.today()
        );
        insert order;
        Test.startTest();
            DN_SalesOrderListController.getOrder(acc.Id);
        Test.stopTest();       
    }

    @IsTest // catch
    static void test2(){
        try {
            
            Test.startTest();
                DN_SalesOrderListController.getOrder('test Ids');
            Test.stopTest();    
        } catch (Exception e) {
            
        } 
        
        
    }
}