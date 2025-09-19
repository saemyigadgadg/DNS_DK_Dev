/**
 * @description       : 출하이력조회 - DN_GIHistorySearchControllerTest 
 * @author            : Kyongyun Jung
 * @group             : 
 * @last modified on  : 02-17-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-06-2025   Kyongyun Jung   Initial Version
 */
@isTest
public without sharing class DN_GIHistorySearchControllerTest {
    private static final Id dealerId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
   
    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'dealerOwnerRole');
        insert dealerRole;
       
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name IN  ('System Administrator','시스템 관리자')];
       
        User partnerAccOwner = new User (
            UserName                 = 'partAcctOwner@partneradmintest.com'
            ,Email                   = 'partAcctOwner@partneradmintest.com'
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

            Set<String> bypassSet = new Set<String>{'OpportunityTriggerHandler'};
            bypassSet.add('AccountTriggerHandler');
            bypassSet.add('ContactTriggerHandler');
            bypassSet.add('QuoteTriggerHandler');
            bypassSet.add('OpportunityLineItemTriggerHandler');
            TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
            
            Id partId = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
            
            Product2 prd1 = new Product2( RecordTypeId = partId, Name = 'TEST-10000',ProductCode='TEST-10000',MaterialDetailsKO__c ='TEST-10000', Description = 'TEST-10000' ,IsActive = true);
            insert prd1;
            Product2 prd2 = new Product2( RecordTypeId = partId, Name = 'TEST-20000',ProductCode='TEST-20000',MaterialDetailsKO__c ='TEST-20000', Description = 'TEST-20000' ,IsActive = true);
            insert prd2;

            Account acc1 = new Account(
                 Name                    = 'GITest Company'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'GITest Company'
                ,BusinessNumber__c       = '1006845558'
                ,CustomerCode__c         = '105645738'
                ,DealerGrade__c          = 'A'
                ,SalesOrganization__c    = '1800'
                ,SalesDistrict__c        = 'A1KR'
                ,SalesOffice__c          = '114C'
                ,DistributionChannel__c  = '10'
                ,Division__c             = '40'
            );
            insert acc1;

            Account acc2 = new Account(
                 Name                    = 'GI2Test Company'
                ,RecordTypeId            =  dealerId
                ,AccountNameEnglish__c   = 'GI2Test Company'
                ,BusinessNumber__c       = '8287887668'
                ,CustomerCode__c         = '105645739'
                ,DealerGrade__c          = 'B'
                ,SalesOrganization__c    = '1800'
                ,SalesDistrict__c        = 'A1KR'
                ,SalesOffice__c          = '114C'
                ,DistributionChannel__c  = '10'
                ,Division__c             = '40'
            );
            insert acc2;
           
            DealerCustomer__c dc1 = new DealerCustomer__c(
                Name                   = 'GI1 Test 대리점'
               ,SourceAccount__c       = acc1.Id
               ,CustomerCode__c        = '105645728'
               ,IsActive__c            = true
               ,IsDealer__c            = true
               ,SalesOrganization__c   ='1846'
               ,DistributionChannel__c = '10'
               ,Division__c            = '40'
            );
            insert dc1;

            DealerCustomer__c dc2 = new DealerCustomer__c(
                Name                   = 'GI2 Test 대리점'
               ,SourceAccount__c       = acc1.Id
               ,CustomerCode__c        = '105645739'
               ,IsActive__c            = true
               ,IsDealer__c            = true
               ,SalesOrganization__c   ='1846'
               ,DistributionChannel__c = '10'
               ,Division__c            = '40'
            );
            insert dc2;

            Contact cont = new Contact(
                 AccountId              = acc1.Id
                ,LastName               = 'Geek'
                ,RecordTypeId           = dealerConId
                ,Email                  = 'greek@gitestcompanytest.com'
                ,Position__c            = '대리'
                ,Role__c                = '영업'
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
                ,Username           = 'greek@gitestcompanytest.com'
                ,Email              = 'greek@gitestcompanytest.com'
                ,EmailEncodingKey   = 'UTF-8'
                ,Alias              = 'geee'
                ,TimeZoneSidKey     = 'Asia/Seoul'
                ,LocaleSidKey       = 'en_US'
                ,LanguageLocaleKey  = 'en_Us'
                ,LastName           = 'Poo'
            );
            insert dealerUser;

            PricebookEntry entry = TestDataFactoryForDealerPortal.createPriceBookEntry(prd1 ,'KRW');
            insert entry;
    
            Opportunity opty = TestDataFactoryForDealerPortal.createDNSDomesticOpty(acc1 ,dealerUser ,'General');
            insert opty;
    
            OpportunityLineItem oItem = TestDataFactoryForDealerPortal.createOptyItem(opty ,entry ,prd1); 
            insert oItem;

            Quote quote = TestDataFactoryForDealerPortal.createDNSDomesticQuote(dealerUser ,opty ,'Korea'); 
            insert quote;

            Order order = TestDataFactoryForDealerPortal.createDNSDomesticOrder(acc1 ,opty ,quote ,dealerUser ,'DNS'); 
            insert order;

            DeliveryOrder__c dOrder = new DeliveryOrder__c (
                Order__c = order.Id
                ,ActualGIDate__c = System.now()
                ,OwnerId = dealerUser.Id
            );
            insert dOrder;

            Asset ass = new Asset();
            ass.Name            = 'ML1006-006231';
            ass.MachineName__c  = 'LYNX2 220A-NT';
            ass.Material__c     = 'L222ANT-F0TP-0-K30';
            ass.SerialNumber    = 'ML00106-006231';
            ass.Status          = 'AVLB';
            ass.AccountId       = acc1.Id;
            ass.SoldTo__c       = acc1.Id;
            ass.Order__c        = order.Id;
            insert ass;
            ///DNS오더
        }
    }

    @isTest
    static void gihistoryTestUnit() {
        
        User userId = [SELECT Id FROM User WHERE Username = 'greek@gitestcompanytest.com' LIMIT 1];
        Account accId  = [SELECT Id FROM Account WHERE Name='GITest Company' LIMIT 1];
        //DealerCustomer__c dcOne = [SELECT Id FROM DealerCustomer__c WHERE Name = 'Bravo Test 대리점'  LIMIT 1];

        Date searchDateStart = Date.today();
        Date searchDateEnd   = Date.today();
        Test.startTest();
            System.runAs(userId){
                DN_GIHistorySearchController.getHistoryData(accId.Id,searchDateStart,searchDateEnd);
                DN_GIHistorySearchController.getHistoryData(accId.Id,null,null);
            }
        Test.stopTest();
    }
}