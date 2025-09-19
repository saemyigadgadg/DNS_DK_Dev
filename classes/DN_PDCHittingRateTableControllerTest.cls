/**
 * @description       : 대리점별적중율 - DN_PDCHittingRateTableControllerTest 
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : Kyongyun Jung
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-04-2025   Kyongyun Jung   Initial Version
 */
@isTest
public with sharing class DN_PDCHittingRateTableControllerTest {
    private static final Id dealerId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
   
    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'dealerRole');
        insert dealerRole;
        ///////
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name IN  ('System Administrator','시스템 관리자')];
       
        User partnerAccOwner = new User (
            UserName                 = 'partnerAccOwner@testh.com'
            ,Email                   = 'partnerAccOwner@testh.com'
            ,Alias                   = 'partner'
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
            // Account - ispartner도 만들어야함 
            Id partId = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
           
            Product2 prd1 = new Product2( RecordTypeId = partId, Name = 'DNC/100',ProductCode='DNC/100',MaterialDetailsKO__c ='DNC/001', Description = 'TEST/100' ,IsActive = true);
            insert prd1;
            Product2 prd2 = new Product2( RecordTypeId = partId, Name = 'DNC/200',ProductCode='DNC/200',MaterialDetailsKO__c ='DNC/002', Description = 'TEST/200' ,IsActive = true);
            insert prd2;
            Product2 prd3 = new Product2( RecordTypeId = partId, Name = 'DNC/300',ProductCode='DNC/200',MaterialDetailsKO__c ='DNC/003', Description = 'TEST/300' ,IsActive = true);  
            insert prd3;   
            
            Account acc1 = new Account(
                 Name                    = 'Bravo Test Company'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'Bravo Test Company'
                ,BusinessNumber__c       = '10068454545'
                ,CustomerCode__c         = '105645785'
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
                 Name                    = 'Row Test Company'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'Row Test Company'
                ,BusinessNumber__c       = '8287887888'
                ,CustomerCode__c         = '105645799'
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
                Name = 'Bravo Test 대리점'
               ,SourceAccount__c = acc1.Id
               ,CustomerCode__c = '105645785'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c    ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc1;

            DealerCustomer__c dc2 = new DealerCustomer__c(
                Name = 'Row Test 대리점'
               ,SourceAccount__c = acc2.Id
               ,CustomerCode__c = '105645799'
               ,IsActive__c = true
               ,IsDealer__c = true
               ,SalesOrganization__c    ='1846'
               ,DistributionChannel__c  = '10'
               ,Division__c             = '40'
            );
            insert dc2;

            Contact cont = new Contact(
                 AccountId    = acc1.Id
                ,LastName     = 'Brown'
                ,RecordTypeId = dealerConId
                ,Email        = 'brown@browntestcompany.com'
                ,Position__c  = '과장'
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
                ,Username           = 'brown@browntestcompany.com'
                ,Email              = 'brown@browntestcompany.com'
                ,EmailEncodingKey   = 'UTF-8'
                ,Alias              = 'brown'
                ,TimeZoneSidKey     = 'Asia/Seoul'
                ,LocaleSidKey       = 'en_US'
                ,LanguageLocaleKey  = 'en_Us'
                ,LastName           = 'Test'
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
                ,AvailableQuantity__c = 0
                ,CustomerPrice__c = 10000
            );
            insert doi11;
        }
    }

    @isTest
    static void myUnitTest() {
       
        User userId = [SELECT Id FROM User WHERE Username = 'brown@browntestcompany.com' LIMIT 1];
        Account accId  = [SELECT Id FROM Account WHERE Name='Bravo Test Company' LIMIT 1];
        DealerCustomer__c dcOne = [SELECT Id FROM DealerCustomer__c WHERE Name = 'Bravo Test 대리점'  LIMIT 1];

        Date hitDateStart = Date.today();
        Date hitDateEnd   = Date.today();
        Date wrongDateEnd    = Date.today().addDays(-2);
        Test.startTest();
            //System.runAs(userId){
               
            DN_PDCHittingRateTableController.getHitList(accId.Id,hitDateStart,hitDateEnd);
            //dealer customer
            DN_PDCHittingRateTableController.getHitList(dcOne.Id,hitDateStart,hitDateEnd);
            //Account
            DN_PDCHittingRateTableController.getHitList('All',hitDateStart,wrongDateEnd);
            //Error
            DN_PDCHittingRateTableController.getHitList(accId.Id,hitDateStart,wrongDateEnd);
            DN_PDCHittingRateTableController.getHitList(null,hitDateStart,hitDateEnd);
          //  }
        Test.stopTest();
    }
}