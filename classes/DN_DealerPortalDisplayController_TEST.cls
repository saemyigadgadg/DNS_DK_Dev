@isTest
public with sharing class DN_DealerPortalDisplayController_TEST {
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactoryForDealerPortal.dealer;
        insert acc;
        DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
        customer.IsActive__c = true;
        insert customer;
    }
    
    @IsTest
    static void test1(){
        DealerCustomer__c customer = [SELECT Id FROM DealerCustomer__c LIMIT 1];
        Test.startTest();
        DN_DealerPortalDisplayController.getDisplayMdt('GRGIManagement');
        DN_DealerPortalDisplayController.getDisplayMdt('CreateAnotherAgencyPurchase');
        DN_DealerPortalDisplayController.getDisplayMdt('DemandSearchByRegion');
        DN_DealerPortalDisplayController.getDataList('SELECT Id,Name FROM Account');
        DN_DealerPortalDisplayController.getCustomerList(new List<String>{customer.Id});
        DN_DealerPortalDisplayController.isCommunity();
        Test.stopTest();
        
    }

    @IsTest // catch
    static void test2(){
        try {
            Test.startTest();
            DN_DealerPortalDisplayController.getDisplayMdt('null');
            Test.stopTest();           
        } catch (Exception e) {
            
        } 
    }

    @IsTest // catch
    static void test3(){
        try {
            Test.startTest();
            DN_DealerPortalDisplayController.getDataList('testcadsfsdaf');
            Test.stopTest();    
        } catch (Exception e) {
            
        } 
    }

    @IsTest
    static void test4(){
        DN_DealerPortalDisplayController.DisplaySetting diSettings = new DN_DealerPortalDisplayController.DisplaySetting();
        DN_DealerPortalDisplayController.PageReturn page = new DN_DealerPortalDisplayController.PageReturn();
        DealerCustomer__c customer = [SELECT Id FROM DealerCustomer__c LIMIT 1];
        page.strQuery = 'select  Id,CRMCustomerCode__c, CustomerCode__c,Name,FM_Address__c,Representative__c,Phone__c,PartManagerName__c,IsActive__c,FM_Active__c, FM_PartsManagerPhone__c,FM_CreatedDate__c,FM_PartsManagerName__c from DealerCustomer__c where Id !=null  AND IsActive__c =true';
        page.currentPage = 1;
        page.pagesPerGroup = 15;
        page.itemsPerPage = 15;
        page.orderByField = 'order by LastModifiedDate';
        page.orderBy = 'DESC';
        page.isNetwork = false;
        page.dateKeyField = '';
        Test.startTest();
        DN_DealerPortalDisplayController.getDataListQuery(page,1,false,customer.Id);
        DN_DealerPortalDisplayController.getSearchPicList('Account', 'Name, CustomerCode__c',' AND Name !=null ');
        List<String> additionalList = new List<String>();
        additionalList.add('Name');
        DN_DealerPortalDisplayController.getSearchList('Account',additionalList,'Test Dealer', ' AND Name !=null ', 'ALL');
        Test.stopTest();   
    }

    @IsTest // catch
    static void tset5(){
        try {
            Test.startTest();
                List<String> additionalList = new List<String>();
                additionalList.add('Name');
                DN_DealerPortalDisplayController.getSearchList('Accounteqat',additionalList,'Test Dealer', ' AND Name !=null ', 'ALL');
            Test.stopTest();
        } catch (Exception e) {
            
        } 
    }

    @isTest // catch
    static void tset6(){
        try {
            Test.startTest();
            DN_DealerPortalDisplayController.getSearchPicList('Accountetet', 'Name, CustomerCode__c',' AND Name !=null ');
            Test.stopTest();
        } catch (Exception e) {
            
        } 
    }
}