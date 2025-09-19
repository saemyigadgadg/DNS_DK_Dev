/**
 * @description       : 대리점별공급율 - DN_PDCSupplyRateTableControllerTest 
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : Kyongyun Jung
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-04-2025   Kyongyun Jung   Initial Version
**/
@isTest
public with sharing class DN_PDCSupplyRateTableControllerTest {
    private static final Id giId = SObjectType.DealerInventoryMovements__c.getRecordTypeInfosByDeveloperName().get('GoodsIssue').getRecordTypeId();
    private static final Id dealerId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
   
    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'TestPartnerRole');
        insert dealerRole;
        // User //Admin //PartnerUser
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name IN  ('System Administrator','시스템 관리자')];
       
        User partnerAccOwner = new User (
            UserName            = 'partnerOwner@test.com'
            ,Email              = 'partnerOwner@test.com'
            ,Alias              = 'partner'
            ,TimeZoneSidKey     = 'Asia/Seoul'
            ,LocaleSidKey       = 'ko'
            ,EmailEncodingKey   = 'UTF-8'
            ,LastName           = 'Owner'
            ,LanguageLocaleKey  = 'en_US'
            ,ProfileId          = adminProfile.Id
            ,UserRoleId         = dealerRole.Id  
            ,SalesOrganization__c    = '1800'
            ,DistributionChannel__c  = '10'
            ,Division__c             = '40'
        );
        insert partnerAccOwner;

     
        System.runAs(partnerAccOwner){
            // Account - ispartner도 만들어야함 
            Id partId = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
           
            Product2 prd1 = new Product2( RecordTypeId = partId, Name = 'DNS 100',ProductCode='DNS 100',MaterialDetailsKO__c ='DNS 0001', Description = 'TEST 100' ,IsActive = true);
            insert prd1;
            Product2 prd2 = new Product2( RecordTypeId = partId, Name = 'DNS 200',ProductCode='DNS 200',MaterialDetailsKO__c ='DNS 0002',Description = 'TEST 200' ,IsActive = true);
            insert prd2;
            Product2 prd3 = new Product2( RecordTypeId = partId, Name = 'DNS 300',ProductCode='DNS 200',MaterialDetailsKO__c ='DNS 0003',Description = 'TEST 300' ,IsActive = true);  
            insert prd3;   
            
            Account acc1 = new Account(
                 Name                    = 'Test Company'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'Test Company'
                ,BusinessNumber__c       = '82888287456'
                ,CustomerCode__c         = '10565555'
                ,DealerGrade__c          = 'B'
                // ,TypeOfBusiness__c       = '제조업'
                // ,TypeOfIndustry__c       = '기타 기계 및 장비 제조업'
                ,SalesOrganization__c    = '1800'
                ,SalesDistrict__c        = 'A1KR'
                ,SalesOffice__c          = '114C'
                ,DistributionChannel__c  = '10'
                ,Division__c             = '40'
            );
            insert acc1;

            Account acc2 = new Account(
                 Name                    = 'Test2 Company'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'Test2 Company'
                ,BusinessNumber__c       = '828828287456'
                ,CustomerCode__c         = '1056555522'
                ,DealerGrade__c          = 'B'
                // ,TypeOfBusiness__c       = '제조업'
                // ,TypeOfIndustry__c       = '기타 기계 및 장비 제조업'
                ,SalesOrganization__c    = '1800'
                ,SalesDistrict__c        = 'A1KR'
                ,SalesOffice__c          = '114C'
                ,DistributionChannel__c  = '10'
                ,Division__c             = '40'
            );
            insert acc2;
             // DealerCustomer__c 
            DealerCustomer__c dc1 = new DealerCustomer__c(
                Name = 'Test Company 대리점'
               ,SourceAccount__c = acc1.Id
               ,CustomerCode__c = '10565555'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc1;

            DealerCustomer__c dc2 = new DealerCustomer__c(
                Name = 'Test2 Company 대리점'
               ,SourceAccount__c = acc2.Id
               ,CustomerCode__c = '1056555522'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc2;

            Contact cont = new Contact(
                 AccountId    = acc1.Id
                ,LastName     = 'testUSer'
                ,RecordTypeId = dealerConId
                ,Email        = 'test'+acc1.Id+'@test.com'
                ,Position__c  = '대리'
                ,Role__c      = '영업'
                ,DistributionChannel__c = '10'
                ,Division__c            = '40'
                ,SalesOffice__c         = '114E'
                ,SalesDistrict__c       = 'A1KR'
                ,SalesOrganization__c   = '1800'
            );
            insert cont;

            Profile pf = [SELECT Id, Name FROM Profile WHERE Name IN  ('DNS CS Parts_Partner')];
            User dealerUser  = new User(
                 ContactId          = cont.Id
                ,ProfileId          = pf.id
                ,Username           = 'tes11asdxcvds@testtest.com'
                ,Email              = 'partnerUser@testtest.com'
                ,EmailEncodingKey   = 'UTF-8'
                ,Alias              = 'pUser'
                ,TimeZoneSidKey     = 'Asia/Seoul'
                ,LocaleSidKey       = 'en_US'
                ,LanguageLocaleKey  = 'en_Us'
                ,LastName           = 'Partner'
                // ,SalesOrganization__c    = '1800'
                // ,DistributionChannel__c  = '10'
                // ,Division__c             = '40'
            );
            insert dealerUser;

            DealerOrder__c do1 = new DealerOrder__c(
                 Dealer__c = acc1.Id
                ,Customer__c = dc2.Id
                ,OrderType__c = 'S'
            );
            insert do1;

            DealerOrder__c do2 = new DealerOrder__c(
                Dealer__c = acc2.Id
                ,Customer__c = dc1.Id
                ,OrderType__c = 'P'
            );
            insert do2;

            DealerOrderItem__c doi1 = new DealerOrderItem__c(
                Order__c = do1.id
                ,Part__c = prd1.Id
                ,ReplacingPart__c = prd1.Id
                ,Quantity__c = 2
                ,AvailableQuantity__c =4
                ,CustomerPrice__c = 1000
            );
            insert doi1;

            DealerOrderItem__c doi11 = new DealerOrderItem__c(
                Order__c = do1.id
                ,Part__c = prd2.Id
                ,ReplacingPart__c = prd2.Id
                ,Quantity__c = 1
                ,AvailableQuantity__c = 40
                ,CustomerPrice__c = 10000
            );
            insert doi11;
            //Id grId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('GoodsIssue').getRecordTypeId(); 
        
            DealerInventoryMovements__c dim1 = new DealerInventoryMovements__c(
                 RecordTypeId = giId
                ,DealerOrderItem__c = doi1.Id
                ,InventoryItemNumber__c = '000010'
                ,Dealer__c = acc1.Id
                ,Type__c = 'S'
                ,InventoryChange__c = 'H'
                ,Part__c = prd1.Id
                ,Quantity__c = 1
            );
            insert dim1; 

            DealerInventoryMovements__c dim2 = new DealerInventoryMovements__c(
                RecordTypeId = giId
               ,DealerOrderItem__c = doi1.Id
               ,InventoryItemNumber__c = '000010'
               ,Dealer__c = acc1.Id
               ,Type__c = 'S'
               ,InventoryChange__c = 'H'
               ,Part__c = prd1.Id
               ,Quantity__c = 2
           );
           insert dim2; 
        }
    }

    @isTest
    static void getSupplyRateTableAdmin() {
        Account accId  = [SELECT Id FROM Account WHERE Name='Test Company' LIMIT 1];
        Account accId2 = [SELECT Id FROM Account WHERE Name='Test2 Company' LIMIT 1];
        DealerCustomer__c dcOne = [SELECT Id FROM DealerCustomer__c WHERE Name = 'Test Company 대리점'];
        DealerCustomer__c dcTwo= [SELECT Id FROM DealerCustomer__c WHERE Name = 'Test2 Company 대리점'];

        Date supplyDateStart = Date.today();
        Date supplyDateEnd   = Date.today();
        Date wrongDateEnd    = Date.today().addDays(-2);
        Test.startTest();
            DN_PDCSupplyRateTableController.getSupplyList(accId.Id,supplyDateStart,supplyDateEnd);
            //dealer customer
            DN_PDCSupplyRateTableController.getSupplyList(dcOne.Id,supplyDateStart,supplyDateEnd);
            DN_PDCSupplyRateTableController.getSupplyList(dcTwo.Id,supplyDateStart,supplyDateEnd);
            //Account
            DN_PDCSupplyRateTableController.getSupplyList('All',supplyDateStart,wrongDateEnd);
            //Error
            DN_PDCSupplyRateTableController.getSupplyList(accId.Id,supplyDateStart,wrongDateEnd);
            DN_PDCSupplyRateTableController.getSupplyList(null,supplyDateStart,supplyDateEnd);
        Test.stopTest();
    }
}