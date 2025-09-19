/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 03-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-21-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_priceEscalationStatusPrintCtrTest {
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

            Interface__c ifc029 = new Interface__c(
                Name               = 'IF-PARTS-029'
                ,ProcessingType__c = 'Real-Time'
                ,Description__c    = '판매가 전체 조회(test)'
                ,IsActive__c       = true
                ,HttpMethod__c     = 'POST'
                ,EndpointURL__c    = 'http://temp'
                ,System__c         = 'ERP'
                ,ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8'
                ,Timeout__c        = 120000
            );
            insert ifc029;

            InterfaceClasses__c ifClass029 = new InterfaceClasses__c(
                Name = 'IF_ERP_PE_Inquery'
                ,Interface__c = ifc029.Id
            );
            insert ifClass029;
        }
    }

    @isTest
    static void Test_PDF_GetStatusList_Success() {
        User testUser = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        Date today = Date.today();
        Date twoDay = today.addDays(1);

        System.runAs(testUser) {
            // VF 페이지 파라미터 세팅
            ApexPages.currentPage().getParameters().put('sDate', String.valueOf(today));
            ApexPages.currentPage().getParameters().put('eDate', String.valueOf(twoDay));
            ApexPages.currentPage().getParameters().put('pon', '');
            ApexPages.currentPage().getParameters().put('pen', '5000000234');
            ApexPages.currentPage().getParameters().put('page', '1');
            ApexPages.currentPage().getParameters().put('status', '');

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_029_Success());
            DN_priceEscalationStatusPrintController controller = new DN_priceEscalationStatusPrintController();
            Test.stopTest();

            // 검증
            // System.assertEquals('All', controller.statusValue);
            // System.assertNotEquals(null, controller.prs);
            // System.assertNotEquals(null, controller.listSize);
        }
    }

    private class MockIF_ERP_Parts_029_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"T_LIST":[{"RJ_REASON":"거절 내용 입력","PENUM":"5000000234","ATTACH":"","STAT":"A","STAT_TXT":"Accepted","EMAIL":"jingi.kim@dncompany.com","PERSON":"홍길동","REMARK":"리마크 내용 입력","DOCDT":"2025-03-17","INQUIRY":"","SERNR":"장비번호","TYPBZ":"기종"}],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":""},"O_LINES":"1"}'
            );
            return res;
        }
    }

    @isTest
    static void Test_PDF_GetStatusList_Success2() {
        User testUser = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        Date today = Date.today();
        Date twoDay = today.addDays(1);

        System.runAs(testUser) {
            // VF 페이지 파라미터 세팅
            ApexPages.currentPage().getParameters().put('sDate', String.valueOf(today));
            ApexPages.currentPage().getParameters().put('eDate', String.valueOf(twoDay));
            ApexPages.currentPage().getParameters().put('pon', '');
            ApexPages.currentPage().getParameters().put('pen', '');
            ApexPages.currentPage().getParameters().put('page', '1');
            ApexPages.currentPage().getParameters().put('status', '');

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_029_Success2());
            DN_priceEscalationStatusPrintController controller = new DN_priceEscalationStatusPrintController();
            Test.stopTest();

            // 검증
            // System.assertEquals('All', controller.statusValue);
            // System.assertNotEquals(null, controller.prs);
            // System.assertNotEquals(null, controller.listSize);
        }
    }

    private class MockIF_ERP_Parts_029_Success2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"T_LIST":[],"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":""},"O_LINES":"0"}'
            );
            return res;
        }
    }
}