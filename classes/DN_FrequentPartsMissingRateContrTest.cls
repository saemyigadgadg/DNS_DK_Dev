/**
 * @description       : DN_FrequentPartsMissingRateContrTest | 다빈도 부품 결핍율
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 02-06-2025
 * @last modified by  : kyjung@yangwoodatapotion.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0  02-06-2025   Kyongyun Jung    Initial Version
*/
@istest
public without sharing class DN_FrequentPartsMissingRateContrTest {
    private static final Id dealerId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
   
    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'dealerOwnerRole');
        insert dealerRole;
       
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name IN  ('System Administrator','시스템 관리자')];
       
        User partnerAccOwner = new User (
            UserName                 = 'partAccOwner@grgigrgi.com'
            ,Email                   = 'partAccOwner@grgigrgi.com'
            ,Alias                   = 'part'
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
            
            Product2 prd1 = new Product2( RecordTypeId = partId, Name = 'frequentpart1',ProductCode='frequentpart1',MaterialDetailsKO__c ='frequentpart1', Description = 'frequentpart1' ,IsActive = true);
            insert prd1;
            Product2 prd2 = new Product2( RecordTypeId = partId, Name = 'frequentpart2',ProductCode='frequentpart2',MaterialDetailsKO__c ='frequentpart2', Description = 'frequentpart2' ,IsActive = true);
            insert prd2; 

            Account acc1 = new Account(
                 Name                    = 'Fre TEST1'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'Fre Test1 Company'
                ,BusinessNumber__c       = '10068454188'
                ,CustomerCode__c         = '1056458888'
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
                 Name                    = 'Fre Test2'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'Fre Test2 Company'
                ,BusinessNumber__c       = '8287887188'
                ,CustomerCode__c         = '105645999'
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
                Name = 'F1 Test 대리점'
               ,SourceAccount__c = acc1.Id
               ,CustomerCode__c = '1056458888'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c    ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc1;

            DealerCustomer__c dc2 = new DealerCustomer__c(
                Name = 'M2 Test 대리점'
               ,SourceAccount__c = acc2.Id
               ,CustomerCode__c = '105645999'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c    ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc2;

            Contact cont = new Contact(
                 AccountId    = acc1.Id
                ,LastName     = 'Fred'
                ,RecordTypeId = dealerConId
                ,Email        = 'Fred@testfredcompany.com'
                ,Position__c  = '대리'
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
                ,Username           = 'Fred@testfredcompany.com'
                ,Email              = 'Fred@testfredcompany.com'
                ,EmailEncodingKey   = 'UTF-8'
                ,Alias              = 'ulee'
                ,TimeZoneSidKey     = 'Asia/Seoul'
                ,LocaleSidKey       = 'en_US'
                ,LanguageLocaleKey  = 'en_Us'
                ,LastName           = 'Fred'
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
            
            Id poIdO = SObjectType.PurchaseOrder__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
            
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
                 ,OrderPartNo__c = 'OrderPartNo1',SupplyPartId__c = prd2.Id , SupplyPartNo__c ='SupplyPartNo2'
                 ,Unit__c = 'EA' ,UnitPrice__c=1000 ,Quantity__c =2 ,ItemNo__c ='0000010'
            );
            insert pos1;
            PurchaseOrderItems__c pos2 = new PurchaseOrderItems__c(
                PurchaseOrder__c = po2.Id ,OrderPartId__c = prd2.Id ,Part__c = prd2.Id
                ,OrderPartNo__c = 'OrderPartNo2',SupplyPartId__c = prd1.Id , SupplyPartNo__c ='SupplyPartNo1'
                ,Unit__c = 'EA' ,UnitPrice__c=1000 ,Quantity__c =5 ,ItemNo__c ='0000020'
            );
            insert pos2;

            DealerPartMasterByMPPS__c dmsm1 = new DealerPartMasterByMPPS__c(
                 Part__c = prd1.Id
                ,Dealer__c = acc1.Id
                ,ABCIndicator__c = 'A'
            );
            insert dmsm1;
            DealerPartMasterByMPPS__c dmsm2 = new DealerPartMasterByMPPS__c(
                Part__c = prd2.Id
               ,Dealer__c = acc1.Id
               ,ABCIndicator__c = 'F'
           );
           insert dmsm2;
        }

    }

    @isTest
    static void dealerPortalUserTest() {
        User userId = [SELECT Id FROM User WHERE Username = 'Fred@testfredcompany.com' LIMIT 1];
        Account accId  = [SELECT Id FROM Account WHERE Name='Fre TEST1' LIMIT 1];
        DealerCustomer__c dc = [SELECT Id FROM DealerCustomer__c WHERE CustomerCode__c = '1056458888' LIMIT 1];
        Date orderDateStart = Date.today();
        Date orderDateEnd   = Date.today();
        Date wrongDateEnd = Date.today().addDays(-2);
        Test.startTest();
            System.runAs(userId){
                DN_FrequentPartsMissingRateController.getDataList( 'All' ,orderDateStart ,orderDateEnd ,accId.Id);
                DN_FrequentPartsMissingRateController.getDataList( 'YDOR' ,orderDateStart ,orderDateEnd ,dc.Id);
                DN_FrequentPartsMissingRateController.getDataList( '' ,orderDateStart ,wrongDateEnd ,dc.Id);
            }
        Test.stopTest();
    }
}