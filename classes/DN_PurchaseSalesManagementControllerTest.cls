/**
 * @description       : 입출고관리 - DN_PDCHittingRateTableController_TEST 
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 02-05-2025
 * @last modified by  : Kyongyun Jung
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-05-2025   Kyongyun Jung   Initial Version
 */
@isTest
public with sharing class DN_PurchaseSalesManagementControllerTest {
    private static final Id dealerId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
   
    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'dealerOwnerRole');
        insert dealerRole;
       
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name IN  ('System Administrator','시스템 관리자')];
       
        User partnerAccOwner = new User (
            UserName                 = 'partAOwner@aodlqaocnf.com'
            ,Email                   = 'partAOwner@aodlqaocnf.com'
            ,Alias                   = 'partners'
            ,TimeZoneSidKey          = 'Asia/Seoul'
            ,LocaleSidKey            = 'ko'
            ,EmailEncodingKey        = 'UTF-8'
            ,LastName                = 'Owner'
            ,LanguageLocaleKey       = 'en_US'
            ,ProfileId               = adminProfile.Id
            ,UserRoleId              = dealerRole.Id  
            ,SalesOrganization__c    = '1800'
            ,DistributionChannel__c  = '10'
            ,Division__c             = '40'
        );
        insert partnerAccOwner;
        

        System.runAs(partnerAccOwner){
            Id partId = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
            
            Product2 prd1 = new Product2( RecordTypeId = partId, Name = 'TEST10000',ProductCode='TEST10000',MaterialDetailsKO__c ='TEST10000', Description = 'TEST10000' ,IsActive = true);
            insert prd1;
            Product2 prd2 = new Product2( RecordTypeId = partId, Name = 'TEST20000',ProductCode='TEST20000',MaterialDetailsKO__c ='TEST20000', Description = 'TEST20000' ,IsActive = true);
            insert prd2;
            Product2 prd3 = new Product2( RecordTypeId = partId, Name = 'TEST30000',ProductCode='TEST30000',MaterialDetailsKO__c ='TEST30000', Description = 'TEST30000' ,IsActive = true);  
            insert prd3;  
            Product2 prd4 = new Product2( RecordTypeId = partId, Name = 'TEST40000',ProductCode='TEST40000',MaterialDetailsKO__c ='TEST40000', Description = 'TEST40000' ,IsActive = true);  
            insert prd4;   

            Account acc1 = new Account(
                 Name                    = 'P Test1'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'P Test1 Company'
                ,BusinessNumber__c       = '1006845518'
                ,CustomerCode__c         = '105645728'
                ,DealerGrade__c          = 'A'
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
                 Name                    = 'P Test2'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'P Test2 Company'
                ,BusinessNumber__c       = '8287887188'
                ,CustomerCode__c         = '105645729'
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
           
            DealerCustomer__c dc1 = new DealerCustomer__c(
                Name = 'P1 Test 대리점'
               ,SourceAccount__c = acc1.Id
               ,CustomerCode__c = '105645728'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c    ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc1;

            DealerCustomer__c dc2 = new DealerCustomer__c(
                Name = 'P2 Test 대리점'
               ,SourceAccount__c = acc1.Id
               ,CustomerCode__c = '105645729'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c    ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc2;

            Contact cont = new Contact(
                 AccountId    = acc1.Id
                ,LastName     = 'Poo'
                ,RecordTypeId = dealerConId
                ,Email        = 'poo@aodlqaocnf.com'
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
                ,Username           = 'poo@aodlqaocnf.com'
                ,Email              = 'poo@aodlqaocnf.com'
                ,EmailEncodingKey   = 'UTF-8'
                ,Alias              = 'poooo'
                ,TimeZoneSidKey     = 'Asia/Seoul'
                ,LocaleSidKey       = 'en_US'
                ,LanguageLocaleKey  = 'en_Us'
                ,LastName           = 'Poo'
            );
            insert dealerUser;
            //일반오더 : 입고
            DealerOrder__c do1 = new DealerOrder__c(Dealer__c = acc1.Id ,Customer__c = dc2.Id ,OrderType__c = 'S' ,OwnerId = dealerUser.Id);
            insert do1;
            //일반오더 : 입고취소
            DealerOrder__c do2 = new DealerOrder__c(Dealer__c = acc1.Id ,Customer__c = dc2.Id ,OrderType__c = 'S' ,OwnerId = dealerUser.Id);
            insert do2;
            //일반오더 : 출고 
            DealerOrder__c do3 = new DealerOrder__c(Dealer__c = acc1.Id ,Customer__c = dc2.Id ,OrderType__c = 'S' ,OwnerId = dealerUser.Id);
            insert do3;
            //일반오더 : 출고취소
            DealerOrder__c do4 = new DealerOrder__c(Dealer__c = acc1.Id ,Customer__c = dc2.Id ,OrderType__c = 'S' ,OwnerId = dealerUser.Id);
            insert do4;

            DealerOrderItem__c doi1 = new DealerOrderItem__c(
                 Order__c = do1.id
                ,Part__c = prd1.Id
                ,ReplacingPart__c = prd1.Id
                ,Quantity__c = 2
                ,AvailableQuantity__c = 4
                ,CustomerPrice__c = 1000
            );
            insert doi1;
            
            DealerOrderItem__c doi2 = new DealerOrderItem__c(
                Order__c = do2.id
                ,Part__c = prd2.Id
                ,ReplacingPart__c = prd2.Id
                ,Quantity__c = 1
                ,AvailableQuantity__c = 0
                ,CustomerPrice__c = 10000
            );
            insert doi2;

            DealerOrderItem__c doi3 = new DealerOrderItem__c(
                 Order__c = do3.id
                ,Part__c = prd3.Id
                ,ReplacingPart__c = prd3.Id
                ,Quantity__c = 10
                ,AvailableQuantity__c = 40
                ,CustomerPrice__c = 1000
            );
            insert doi3;

            DealerOrderItem__c doi4 = new DealerOrderItem__c(
                Order__c = do4.id
                ,Part__c = prd4.Id
                ,ReplacingPart__c = prd4.Id
                ,Quantity__c = 2
                ,AvailableQuantity__c = 1
                ,CustomerPrice__c = 10000
            );
            insert doi4;

            DealerOrderItem__c doi5 = new DealerOrderItem__c(
                 Order__c = do3.id
                ,Part__c = prd3.Id
                ,ReplacingPart__c = prd3.Id
                ,Quantity__c = 1
                ,AvailableQuantity__c = 30
                ,CustomerPrice__c = 10000
                ,DiscountPrice__c = 1000
            );
            insert doi5;

            ///입고데이터 (H:입고취소 / S:입고) // 123 
            Id grId = SObjectType.DealerInventoryMovements__c.getRecordTypeInfosByDeveloperName().get('GoodsReceipt').getRecordTypeId();
            ///출고데이터 (H:출고 / S:출고취소) // SWO
            Id giId = SObjectType.DealerInventoryMovements__c.getRecordTypeInfosByDeveloperName().get('GoodsIssue').getRecordTypeId();
            //부품주문
            Id poIdO = SObjectType.PurchaseOrder__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
            //부품반품
            Id poIdR = SObjectType.PurchaseOrder__c.getRecordTypeInfosByDeveloperName().get('ReturnOrder').getRecordTypeId();
            
            PurchaseOrder__c po1 = new PurchaseOrder__c(
                 Buyer__c = acc1.Id ,OrderType__c = 'YDOR' ,RecordTypeId = poIdO ,OwnerId = dealerUser.Id
            );
            insert po1;
            PurchaseOrder__c po2 = new PurchaseOrder__c(
                 Buyer__c = acc1.Id ,OrderType__c = 'YDOR' ,RecordTypeId = poIdO ,OwnerId = dealerUser.Id
            );
            insert po2;

            PurchaseOrderItems__c pos1 = new PurchaseOrderItems__c(
                 PurchaseOrder__c = po1.Id ,OrderPartId__c = prd1.Id ,Part__c = prd1.Id 
            );
            insert pos1;
            PurchaseOrderItems__c pos2 = new PurchaseOrderItems__c(
                PurchaseOrder__c = po2.Id ,OrderPartId__c = prd2.Id ,Part__c = prd2.Id 
            );
            insert pos2;

            DealerInventoryMovements__c dim1 = new DealerInventoryMovements__c(
                RecordTypeId = grId
                ,DealerOrderItem__c = doi1.Id
                ,Dealer__c = acc1.Id
                ,Type__c = '2' 
                ,InventoryChange__c = 'S'
                ,Part__c = prd1.Id
                ,Quantity__c = 1
                ,PurchaseOrderItem__c = pos1.Id
                ,OwnerId = dealerUser.Id
            );
            insert dim1; 
            system.debug('OwnerId >> '+dim1.OwnerId);
            DealerInventoryMovements__c dim2 = new DealerInventoryMovements__c(
                RecordTypeId = grId
                ,DealerOrderItem__c = doi2.Id
                ,Dealer__c = acc1.Id
                ,Type__c = '3' 
                ,InventoryChange__c = 'H'
                ,Part__c = prd2.Id
                ,Quantity__c = null
                ,PurchaseOrderItem__c = pos2.Id
                ,OwnerId = dealerUser.Id
            );
            insert dim2; 
          
            DealerInventoryMovements__c dim3 = new DealerInventoryMovements__c(
                RecordTypeId = giId
                ,DealerOrderItem__c = doi3.Id
                ,Dealer__c = acc1.Id
                ,Type__c = 'S'
                ,InventoryChange__c = 'H'
                ,Part__c = prd3.Id
                ,Quantity__c = 9
                ,OwnerId = dealerUser.Id
            );
            insert dim3; 

            DealerInventoryMovements__c dim4 = new DealerInventoryMovements__c(
                RecordTypeId = giId
                ,DealerOrderItem__c = doi4.Id
                ,Dealer__c = acc1.Id
                ,Type__c = 'O'
                ,InventoryChange__c = 'S'
                ,Part__c = prd4.Id
                ,Quantity__c = 1
                ,OwnerId = dealerUser.Id
            );
            insert dim4; 

            DealerInventoryMovements__c dim5 = new DealerInventoryMovements__c(
                RecordTypeId = giId
                ,DealerOrderItem__c = doi5.Id
                ,Dealer__c = acc1.Id
                ,Type__c = 'S'
                ,InventoryChange__c = 'H'
                ,Part__c = prd3.Id
                ,Quantity__c = 1
                ,OwnerId = dealerUser.Id
            );
            insert dim5; 

            DealerReturnOrderItem__c droi = new DealerReturnOrderItem__c(
                Dealer__c = acc1.Id
                ,OrderItem__c = doi5.Id
                ,ReturnQuantity__c = 1
                ,Note__c = 'Test'
                ,CurrencyIsoCode = 'KRW'
            );
            insert droi;
        }
    }

    @isTest
    static void dealerPurchaseSalesTest() {
        User userId = [SELECT Id FROM User WHERE Username = 'poo@aodlqaocnf.com' LIMIT 1];
        Account accId  = [SELECT Id FROM Account WHERE Name='P Test1' LIMIT 1];
      
        Date searchDateStart = Date.today();
        Date searchDateEnd   = Date.today();
        Date wrongDateEnd = Date.today().addDays(-2);
        Test.startTest();
            System.runAs(userId){
                DN_PurchaseSalesManagementController.getData(accId.Id ,'All','All' ,searchDateStart ,searchDateEnd);
                DN_PurchaseSalesManagementController.getData(accId.Id ,'GR' ,'All' ,searchDateStart ,searchDateEnd);
                DN_PurchaseSalesManagementController.getData(accId.Id ,'GR' ,'S1'  ,searchDateStart ,searchDateEnd);
                DN_PurchaseSalesManagementController.getData(accId.Id ,'GI' ,'All'  ,searchDateStart ,searchDateEnd);
                DN_PurchaseSalesManagementController.getData(accId.Id ,'GI' ,'HS'  ,searchDateStart ,searchDateEnd);
                DN_PurchaseSalesManagementController.getData(accId.Id ,'GI' , null  ,searchDateStart ,wrongDateEnd);
          }
        Test.stopTest();
    }
}