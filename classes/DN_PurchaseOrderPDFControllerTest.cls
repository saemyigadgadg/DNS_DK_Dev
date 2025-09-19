/**
 * @description       : 반품조회 >> 상세 >> 프린트 테스트 코드
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 03-26-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-21-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PurchaseOrderPDFControllerTest {
    private static final Id dealerId    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id productId   = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    private static User dealerUser;

    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'partDealerRole');
        insert dealerRole;

        Profile adminPf = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
       
        User testAdminUser = new User (
            UserName                 = 'testOwner@testDealer.com'
            ,Email                   = 'testOwner@testDealer.com'
            ,Alias                   = 'testOwn'
            ,TimeZoneSidKey          = 'Asia/Seoul'
            ,LocaleSidKey            = 'ko'
            ,EmailEncodingKey        = 'UTF-8'
            ,LastName                = 'Owner'
            ,LanguageLocaleKey       = 'en_US'
            ,ProfileId               = adminPf.Id
            ,UserRoleId              = dealerRole.Id  
            ,SalesOrganization__c    = '1846'
            ,DistributionChannel__c  = '10'
            ,Division__c             = '40'
        );
        insert testAdminUser;

        System.runAs(testAdminUser) {
            // 회사 세우기
            Account testAcc = new Account(
                Name               = 'TestAccount'
                ,Representative__c = 'TestCEO'
                ,RecordTypeId            =  dealerId
                ,Phone                   = '02-555-5555'
                ,AccountNameEnglish__c   = 'TestDealerAccount'
                ,BusinessNumber__c       = '1111111111'
                ,CustomerCode__c         = '0001057644'
                ,DealerGrade__c          = 'A'
                // ,TypeOfBusiness__c       = '제조업'
                // ,TypeOfIndustry__c       = '기타 기계 및 장비 제조업'
                ,SalesOrganization__c    = '1846'
                ,SalesDistrict__c        = 'A1KR'
                ,SalesOffice__c          = '114C'
                ,DistributionChannel__c  = '10'
                ,Division__c             = '40'
            );
            insert testAcc;

            Contact testCon = new Contact(
                AccountId = testAcc.Id
                ,LastName = 'DealerContact'
                ,RecordTypeId = dealerConId
                ,Email        = 'dealCon@testDealer.com'
                ,Position__c  = '대리'
                ,Role__c      = '영업'
                ,DistributionChannel__c = '10'
                ,Division__c            = '40'
                ,SalesOffice__c         = '114E'
                ,SalesDistrict__c       = 'A1KR'
                ,SalesOrganization__c   = '1846'
            );
            insert testCon;

            Profile pf = [SELECT Id, Name FROM Profile WHERE Name = 'DNS CS Parts_Partner' LIMIT 1];
            
            User testUser = new User(
                ContactId  = testCon.Id
                ,ProfileId = pf.Id
                ,Username  = 'DealerUser@TestAccount.com'
                ,Email     = 'DealerUser@TestAccount.com'
                ,EmailEncodingKey    = 'UTF-8'
                ,Alias               = 'ulee'
                ,TimeZoneSidKey      = 'Asia/Seoul'
                ,LocaleSidKey        = 'ko'
                ,LanguageLocaleKey   = 'ko'
                ,LastName            = 'dealer'
                ,CommunityNickname   = 'DealerNickname'
                ,MobilePhone         = '010-5555-5555'
                ,Country__c          = 'KR'
                ,SalesOrganization__c = '1846'
                ,Division__c          = '40'
                ,DistributionChannel__c = '10'
            );
            insert testUser;

            PurchaseOrder__c pco = new PurchaseOrder__c(
                PartOrderNo__c      = '7100253598'
                ,CustomerOrderNo__c = 'TestCONo'
                ,OriginDocDate__c   = Date.valueOf('2024-03-29')
                ,CurrencyIsoCode    = 'KRW'
            );
            insert pco;

            PurchaseOrderItems__c pci = new PurchaseOrderItems__c(
                PurchaseOrder__c = pco.Id
                ,ItemNo__c       = '000011'
                ,Invoice__c      = '9006380060'
                ,OrderPartNo__c  = 'R46946'
                ,Description__c  = 'ELBOW;ONE TOUCH(COMPACT)'
                ,Quantity__c     = Decimal.valueOf('20')
                ,Unit__c         = 'EA'
                ,UnitPrice__c    = Decimal.valueOf('1400')
                ,CurrencyIsoCode = 'KRW'
                ,Note__c         = '반품 생성 확장자 확인'
                ,OriginDocDate__c    = Date.valueOf('2024-03-29')
                ,ComplaintReason1__c = 'B'
                ,ComplaintReason2__c = 'B01'
            );
            insert pci;
        }
    }

    @isTest
    static void testGetStatusList_Success() {
        User userT = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        PurchaseOrder__c testOrder = new PurchaseOrder__c();
        ApexPages.currentPage().getParameters().put('returnOrderNo', '7100253598');
        ApexPages.StandardController sc = new ApexPages.StandardController(testOrder);


        Test.startTest();
        System.runAs(userT) {
            DN_PurchaseOrderPDFController controller = new DN_PurchaseOrderPDFController(sc);
        }
        Test.stopTest();
    }    
}