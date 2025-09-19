/** 
 * @Class :  DealerCustomerTriggerHandler_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 21. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-21 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DealerCustomerTriggerHandler_TEST {

    @TestSetup
    static void makeData(){
        List<Sequence__c> sequenceList = new List<Sequence__c>();
        Sequence__c seq1 = new Sequence__c(
            Name ='DealerCustomer_Dealer',
            Type__c = 'Dealer', 
            Pattern__c = '1{000000}',
            SObjectAPI__c = 'DealerCustomer__c',
            StartNumber__c = 1
        );
        sequenceList.add(seq1);

        Sequence__c seq2 = new Sequence__c(
            Name ='DealerCustomer',
            Type__c = 'Customer', 
            Pattern__c = '5{000000}',
            SObjectAPI__c = 'DealerCustomer__c',
            StartNumber__c = 1
        );
        sequenceList.add(seq2);
        insert sequenceList;

        Account dealer = TestDataFactoryForDealerPortal.dealer;
        dealer.SalesOffice__c = '1146';
        insert dealer;

        
    }

    @isTest
    static void createCustomer() {
        test.startTest();

        DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(null);
        customer.CustomerCode__c = null;
        customer.SourceSystem__c = 'CRM';
        insert customer;

        test.stopTest();
    }

}