@IsTest
public with sharing class DN_CustomerManagementModalCon_TEST {
    static Account acc;
    static DealerCustomer__c customer;
    static DealerCustomerShipTo__c shipto;

    static {
        acc = TestDataFactoryForDealerPortal.dealer;
        insert acc;

        customer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
        customer.Address__Street__s = 'test';
        customer.PartManagerName__c = 'test';

        insert customer;
        
        shipto = TestDataFactoryForDealerPortal.getCustomerShipTO(customer.Id);
        insert shipto;
    }

    @IsTest
    static void test1(){
        
        Test.startTest();
        DN_CustomerManagementModalController.getSiteUrlList();
        DN_CustomerManagementModalController.getInit(customer.Id);
        DN_CustomerManagementModalController.getDealerCustomer(customer.Id);
        DN_CustomerManagementModalController.saveRecord(customer.Id,customer, new List<DealerCustomerShipTo__c>{shipto},new List<String>{shipto.Id});
        Test.stopTest();
    }

    @IsTest // catch
    static void test2(){
        try {
            Test.startTest();
                customer.Name ='';
                List<DealerCustomerShipTo__c> shipList = new List<DealerCustomerShipTo__c>();
                DN_CustomerManagementModalController.setRequiredCheck(customer,shipList);
                customer.Name = 'test';
                customer.PartManagerName__c ='';
                DN_CustomerManagementModalController.setRequiredCheck(customer,shipList);
                customer.PartManagerName__c ='test';
                customer.Address__Street__s = '';
                DN_CustomerManagementModalController.setRequiredCheck(customer,shipList);
                customer.Address__Street__s ='test';
                DealerCustomerShipTo__c shipTo = new DealerCustomerShipTo__c(
                    Address__Street__s=''
                );
                shipList.add(shipTo);
                DN_CustomerManagementModalController.setRequiredCheck(customer,shipList);
                DN_CustomerManagementModalController.saveRecord('tsetset',customer, new List<DealerCustomerShipTo__c>{shipto},new List<String>{shipto.Id});
            Test.stopTest();
        } catch (Exception e) {
            
        }         
    }

    @IsTest
    static void test3(){
        Test.startTest();
        try {
            DN_CustomerManagementModalController.saveRecord(customer.Id,customer, new List<DealerCustomerShipTo__c>{shipto},new List<String>{shipto.Id});    
        } catch (Exception e) {
            
        } 
        Test.stopTest();
    }

}