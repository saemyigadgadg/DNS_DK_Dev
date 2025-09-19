/**
 * @description       : DN_GRGIManagementControllerTest | 입출고내역 모달
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 02-06-2025
 * @last modified by  : kyjung@yangwoodatapotion.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0  02-06-2025   Kyongyun Jung    Initial Version
*/
@istest
public with sharing class DN_GRGIDetailModalControllerTest {
    private static final Id dealerId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
   
    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'dealerOwnerRole');
        insert dealerRole;
       
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name IN  ('System Administrator','시스템 관리자')];
       
        User partnerAccOwner = new User (
            UserName                 = 'partnerAccOwner@grgigrgi.com'
            ,Email                   = 'partnerAccOwner@grgigrgi.com'
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
            
            Product2 prd1 = new Product2( RecordTypeId = partId, Name = 'TESTModal1',ProductCode='TESTModal1',MaterialDetailsKO__c ='TESTModal1', Description = 'TESTModal1' ,IsActive = true);
            insert prd1;
            Product2 prd2 = new Product2( RecordTypeId = partId, Name = 'TESTModal2',ProductCode='TESTModal2',MaterialDetailsKO__c ='TESTModal2', Description = 'TESTModal2' ,IsActive = true);
            insert prd2; 

            Account acc1 = new Account(
                 Name                    = 'Modal TEST1'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'Modal Test1 Company'
                ,BusinessNumber__c       = '10068454188'
                ,CustomerCode__c         = '1056457888'
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
                 Name                    = 'Modal Test2'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'Modal Test2 Company'
                ,BusinessNumber__c       = '8287887188'
                ,CustomerCode__c         = '105645199'
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
                Name = 'M1 Test 대리점'
               ,SourceAccount__c = acc1.Id
               ,CustomerCode__c = '1056457888'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c    ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc1;

            DealerCustomer__c dc2 = new DealerCustomer__c(
                Name = 'M2 Test 대리점'
               ,SourceAccount__c = acc1.Id
               ,CustomerCode__c = '105645199'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c    ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc2;

            Contact cont = new Contact(
                 AccountId    = acc1.Id
                ,LastName     = 'Edword'
                ,RecordTypeId = dealerConId
                ,Email        = 'Edword@testcompanytest.com'
                // ,Position__c  = '대리'
                ,Role__c      = '영업'
                ,DistributionChannel__c = '10'
                ,Division__c            = '40'
                ,SalesOffice__c         = '114E'
                ,SalesDistrict__c       = 'A1KR'
                ,SalesOrganization__c   = '1800'
            );
            insert cont;
            System.debug('cont >>> '+cont);
 

            Profile pf = [SELECT Id, Name FROM Profile WHERE Name IN  ('DNS CS Parts_Partner')];
            User dealerUser  = new User(
                 ContactId          = cont.Id
                ,ProfileId          = pf.id
                ,Username           = 'Edword@testcompanytest.com'
                ,Email              = 'Edword@testcompanytest.com'
                ,EmailEncodingKey   = 'UTF-8'
                ,Alias              = 'ulee'
                ,TimeZoneSidKey     = 'Asia/Seoul'
                ,LocaleSidKey       = 'en_US'
                ,LanguageLocaleKey  = 'en_Us'
                ,LastName           = 'Swart'
            );
            insert dealerUser;

            DealerOrder__c do1 = new DealerOrder__c(Dealer__c = acc1.Id ,Customer__c = dc2.Id ,OrderType__c = 'S' ,OwnerId = dealerUser.Id);
            insert do1;
      
            DealerOrder__c do2 = new DealerOrder__c(Dealer__c = acc1.Id ,Customer__c = dc2.Id ,OrderType__c = 'S' ,OwnerId = dealerUser.Id);
            insert do2;
           

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
                ,AvailableQuantity__c = 30
                ,CustomerPrice__c = 10000
                ,DiscountPrice__c = 1000
            );
            insert doi2;

            ///입고데이터 (H:입고취소 / S:입고) // 123 
            Id grId = SObjectType.DealerInventoryMovements__c.getRecordTypeInfosByDeveloperName().get('GoodsReceipt').getRecordTypeId();
            ///출고데이터 (H:출고 / S:출고취소) // SWO
            Id giId = SObjectType.DealerInventoryMovements__c.getRecordTypeInfosByDeveloperName().get('GoodsIssue').getRecordTypeId();
            //부품주문
            //Id poIdO = SObjectType.PurchaseOrder__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
            // //부품반품
            // Id poIdR = SObjectType.PurchaseOrder__c.getRecordTypeInfosByDeveloperName().get('ReturnOrder').getRecordTypeId();
            
            // PurchaseOrder__c po1 = new PurchaseOrder__c(
            //      Buyer__c = acc1.Id ,OrderType__c = 'YDOR' ,RecordTypeId = poIdO ,OwnerId = dealerUser.Id
            // );
            // insert po1;
            // PurchaseOrder__c po2 = new PurchaseOrder__c(
            //      Buyer__c = acc1.Id ,OrderType__c = 'YDOR' ,RecordTypeId = poIdO ,OwnerId = dealerUser.Id
            // );
            // insert po2;

            // PurchaseOrderItems__c pos1 = new PurchaseOrderItems__c(
            //      PurchaseOrder__c = po1.Id ,OrderPartId__c = prd1.Id ,Part__c = prd1.Id 
            // );
            // insert pos1;
            // PurchaseOrderItems__c pos2 = new PurchaseOrderItems__c(
            //     PurchaseOrder__c = po2.Id ,OrderPartId__c = prd2.Id ,Part__c = prd2.Id 
            // );
            // insert pos2;

            DealerInventoryMovements__c dim1 = new DealerInventoryMovements__c(
                RecordTypeId = grId
                ,DealerOrderItem__c = doi1.Id
                ,Dealer__c = acc1.Id
                ,Type__c = '3' 
                ,InventoryChange__c = 'S'
                ,Part__c = prd1.Id
                ,Quantity__c = 1
             //,PurchaseOrderItem__c = pos1.Id
                ,OwnerId = dealerUser.Id
                ,InventoryNumber__c ='C500000001'
            );
            insert dim1; 
           
            DealerInventoryMovements__c dim2 = new DealerInventoryMovements__c(
                 RecordTypeId = grId
                ,DealerOrderItem__c = doi2.Id
                ,Dealer__c = acc1.Id
                ,Type__c = '3' 
                ,InventoryChange__c = 'H'
                ,Part__c = prd2.Id
                ,Quantity__c = null
                ,OwnerId = dealerUser.Id
           );
           insert dim2; 
          
            DealerReturnOrderItem__c droi = new DealerReturnOrderItem__c(
                Dealer__c = acc1.Id
                ,OrderItem__c = doi2.Id
                ,ReturnQuantity__c = 1
                ,Note__c = 'Test'
                ,CurrencyIsoCode = 'KRW'
                ,ReturnOrderNumber__c = 'C700000001'
            );
            insert droi;

            System.debug(droi);
            ShipmentOrder__c sho = new ShipmentOrder__c(
                Dealer__c = acc1.Id
                ,DealerOrderItem__c = doi1.Id
            );
            insert sho;
        }
    }

    @isTest
    static void modalTest() {
        User userId = [SELECT Id FROM User WHERE Username = 'Edword@testcompanytest.com' LIMIT 1];
        Account accId  = [SELECT Id FROM Account WHERE Name='Modal TEST1' LIMIT 1];
        
        Test.startTest();
            System.runAs(userId){
                DealerReturnOrderItem__c c7 = [SELECT ReturnOrderNumber__c FROM DealerReturnOrderItem__c WHERE ReturnOrderNumber__c= 'C700000001'];
                DealerInventoryMovements__c sh = [SELECT InventoryNumber__c  FROM  DealerInventoryMovements__c WHERE Type__c = '3' AND  InventoryChange__c = 'S' LIMIT 1];
                DN_GRGIDetailModalController.getGRGIInformation(c7.ReturnOrderNumber__c);
                DN_GRGIDetailModalController.getGRGIInformation(sh.InventoryNumber__c);
                DN_GRGIDetailModalController.getGRGIInformation('');
            }
        Test.stopTest();
    }
}