/**
 * @description       : 입출고관리 - DN_GRGIManagementControllerTest 
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 02-05-2025
 * @last modified by  : Kyongyun Jung
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-05-2025   Kyongyun Jung   Initial Version
 */
@isTest
public with sharing class DN_GRGIManagementControllerTest {
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
            
            Product2 prd1 = new Product2( RecordTypeId = partId, Name = 'TEST1000',ProductCode='TEST1000',MaterialDetailsKO__c ='TEST1000', Description = 'TEST1000' ,IsActive = true);
            insert prd1;
            Product2 prd2 = new Product2( RecordTypeId = partId, Name = 'TEST2000',ProductCode='TEST2000',MaterialDetailsKO__c ='TEST2000', Description = 'TEST2000' ,IsActive = true);
            insert prd2;
            Product2 prd3 = new Product2( RecordTypeId = partId, Name = 'TEST3000',ProductCode='TEST3000',MaterialDetailsKO__c ='TEST3000', Description = 'TEST3000' ,IsActive = true);  
            insert prd3;  
            Product2 prd4 = new Product2( RecordTypeId = partId, Name = 'TEST4000',ProductCode='TEST4000',MaterialDetailsKO__c ='TEST4000', Description = 'TEST4000' ,IsActive = true);  
            insert prd4;   

            Account acc1 = new Account(
                 Name                    = 'IU Test Company'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'IU Test Company'
                ,BusinessNumber__c       = '1006845418'
                ,CustomerCode__c         = '105645718'
                ,DealerGrade__c          = 'A'
                //,TypeOfBusiness__c       = '제조업'
               // ,TypeOfIndustry__c       = '기타 기계 및 장비 제조업'
                ,SalesOrganization__c    = '1800'
                ,SalesDistrict__c        = 'A1KR'
                ,SalesOffice__c          = '114C'
                ,DistributionChannel__c  = '10'
                ,Division__c             = '40'
            );
            insert acc1;

            Account acc2 = new Account(
                 Name                    = 'ST Test Company'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'ST Test Company'
                ,BusinessNumber__c       = '828788718'
                ,CustomerCode__c         = '105645719'
                ,DealerGrade__c          = 'B'
				//,TypeOfBusiness__c       = '제조업'
               // ,TypeOfIndustry__c       = '기타 기계 및 장비 제조업'
                ,SalesOrganization__c    = '1800'
                ,SalesDistrict__c        = 'A1KR'
                ,SalesOffice__c          = '114C'
                ,DistributionChannel__c  = '10'
                ,Division__c             = '40'
            );
            insert acc2;
           
            DealerCustomer__c dc1 = new DealerCustomer__c(
                Name = 'IU Test 대리점'
               ,SourceAccount__c = acc1.Id
               ,CustomerCode__c = '105645718'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c    ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc1;

            DealerCustomer__c dc2 = new DealerCustomer__c(
                Name = 'ST Test 대리점'
               ,SourceAccount__c = acc1.Id
               ,CustomerCode__c = '105645719'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c    ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc2;

            Contact cont = new Contact(
                 AccountId    = acc1.Id
                ,LastName     = 'LEE'
                ,RecordTypeId = dealerConId
                ,Email        = 'leeu@iutestcompany.com'
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
                ,Username           = 'leeu@iutestcompany.com'
                ,Email              = 'leeu@iutestcompany.com'
                ,EmailEncodingKey   = 'UTF-8'
                ,Alias              = 'ulee'
                ,TimeZoneSidKey     = 'Asia/Seoul'
                ,LocaleSidKey       = 'en_US'
                ,LanguageLocaleKey  = 'en_Us'
                ,LastName           = 'LEE'
            );
            insert dealerUser;
            System.debug('dealer User >> '+dealerUser.Id);
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
    static void dealerPortalUserTest() {
        User userId = [SELECT Id FROM User WHERE Username = 'leeu@iutestcompany.com' LIMIT 1];
        Account accId  = [SELECT Id FROM Account WHERE Name='IU Test Company' LIMIT 1];
        DealerCustomer__c dc = [SELECT Id FROM DealerCustomer__c WHERE Name = 'IU Test 대리점'  LIMIT 1];
        DealerCustomer__c st = [SELECT Id FROM DealerCustomer__c WHERE Name = 'ST Test 대리점'  LIMIT 1];
        System.debug(dc.Id);
        System.debug(st.Id);
        Date searchDateStart = Date.today();
        Date searchDateEnd   = Date.today();
        Date wrongDateEnd = Date.today().addDays(-2);
        Test.startTest();
            System.runAs(userId){
           // (String agencyId, String type ,String detailType ,Date searchDateStart ,Date searchDateEnd ,String productCode ,String customerId) 
                DN_GRGIManagementController.getSearchData(accId.Id ,'All','All' ,searchDateStart ,searchDateEnd ,'' ,'','');
                DN_GRGIManagementController.getSearchData(accId.Id ,'GR' ,'All' ,searchDateStart ,searchDateEnd ,'' ,st.Id,'');
                DN_GRGIManagementController.getSearchData(accId.Id ,'GR' ,'S3'  ,searchDateStart ,searchDateEnd ,'' ,'','');
                DN_GRGIManagementController.getSearchData(accId.Id ,'GI' ,'All'  ,searchDateStart ,searchDateEnd ,'' ,'','');
                DN_GRGIManagementController.getSearchData(accId.Id ,'GI' ,'HS'  ,searchDateStart ,searchDateEnd ,'' ,'','');
                DN_GRGIManagementController.getSearchData(accId.Id ,'GI' , null  ,searchDateStart ,wrongDateEnd ,'' ,'','');
               // DN_GRGIManagementController.getSearchData(accId.Id ,'' ,''  ,searchDateStart ,searchDateEnd ,'' ,'');
                //Error
              //  DN_GRGIManagementController.getSearchData(null ,null,null ,null ,null ,'' ,'');
          }
        Test.stopTest();
    }

}