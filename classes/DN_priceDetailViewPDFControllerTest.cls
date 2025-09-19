/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 03-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-24-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_priceDetailViewPDFControllerTest {
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

            Interface__c ifc032 = new Interface__c(
                Name               = 'IF-PARTS-032'
                ,ProcessingType__c = 'Real-Time'
                ,Description__c    = '판매가 상세 조회(test)'
                ,IsActive__c       = true
                ,HttpMethod__c     = 'POST'
                ,EndpointURL__c    = 'http://temp'
                ,System__c         = 'ERP'
                ,ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8'
                ,Timeout__c        = 120000
            );
            insert ifc032;

            InterfaceClasses__c ifClass032 = new InterfaceClasses__c(
                Name = 'IF_ERP_PE_Inquery'
                ,Interface__c = ifc032.Id
            );
            insert ifClass032;
        }
    }

    @isTest
    static void Test_PDF_GetStatusDetail_Success () {
        ApexPages.currentPage().getParameters().put('peNo', '5000000234');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_032_Success());
        DN_priceDetailViewPDFController controller = new DN_priceDetailViewPDFController();
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_032_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"ET_ITEM":[{"WAERS":"KRW","SPRICE":"275100","PEITEM":"10","NPRICE":"100000","MPRICE":"270000","MATNR":"R18182","MAKTX":"CENTER,LIVE","COMMNT":"요청사항"}],"ET_ATTACH":[],"ES_RETURN":{"TYPE":"S","MESSAGE":"","CODE":""},"ES_HD":{"TYPBZ":"기종","STAT":"A","SERNR":"장비번호","RJ_REASON":"거절 내용 입력","REMARK":"리마크 내용 입력","PERSON":"홍길동","PENUM":"5000000234","NAME1":"링엔지니어링 부품 대리점","KUNNR":"0001057644","INQUIRY":"","EMAIL":"jingi.kim@dncompany.com","DOCDT":"2025-03-17"}}'
            );
            return res;
        }
    }

    @isTest
    static void Test_PDF_GetStatusDetail_Success2 () {
        ApexPages.currentPage().getParameters().put('peNo', '5000000234');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_032_Success2());
        DN_priceDetailViewPDFController controller = new DN_priceDetailViewPDFController();
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_032_Success2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"ET_ITEM":[{"WAERS":"KRW","SPRICE":"275100","PEITEM":"10","NPRICE":"100000a","MPRICE":"270000a","MATNR":"R18182","MAKTX":"CENTER,LIVE","COMMNT":"요청사항"}],"ET_ATTACH":[],"ES_RETURN":{"TYPE":"S","MESSAGE":"","CODE":""},"ES_HD":{"TYPBZ":"기종","STAT":"A","SERNR":"장비번호","RJ_REASON":"거절 내용 입력","REMARK":"리마크 내용 입력","PERSON":"홍길동","PENUM":"5000000234","NAME1":"링엔지니어링 부품 대리점","KUNNR":"0001057644","INQUIRY":"","EMAIL":"jingi.kim@dncompany.com","DOCDT":"2025-03-17"}}'
            );
            return res;
        }
    }

    

}