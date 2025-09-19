/**
 * @description       : (포탈) 영업 > 채권관리 > 기간별 수금실적 테스트 코드
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 03-24-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-20-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@IsTest
public with sharing class DN_PortalSalesBondsControllerTest {
    private static final Id dealerId    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id productId   = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    private static User dealerUser;

    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'saleDealerRole');
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
            ,SalesOrganization__c    = '1800'
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
                ,CustomerCode__c         = '0001124140'
                ,DealerGrade__c          = 'A'
                // ,TypeOfBusiness__c       = '제조업'
                // ,TypeOfIndustry__c       = '기타 기계 및 장비 제조업'
                ,SalesOrganization__c    = '1800'
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
                ,SalesOrganization__c   = '1800'
            );
            insert testCon;

            Profile pf = [SELECT Id, Name FROM Profile WHERE Name = '영업 국내 대리점' LIMIT 1];
            
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
                ,SalesOrganization__c = '1800'
                ,Division__c          = '40'
                ,DistributionChannel__c = '10'
            );
            insert testUser;

            Interface__c ifc005 = new Interface__c(
                Name               = 'IF-DEALER-005'
                ,ProcessingType__c = 'Real-Time'
                ,Description__c    = '기간별 수금 실적 조회(test)'
                ,IsActive__c       = true
                ,HttpMethod__c     = 'POST'
                ,EndpointURL__c    = 'http://temp'
                ,System__c         = 'ERP'
                ,ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8'
                ,Timeout__c        = 120000
            );
            insert ifc005;

            InterfaceClasses__c ifClass005 = new InterfaceClasses__c(
                Name = 'IF_ERP_Dealer'
                ,Interface__c = ifc005.Id
            );
            insert ifClass005;
        }
    }

    @isTest
    static void Test_GetUserInfo_Success() {
        User userS = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];

        Test.startTest();
        System.runAs(userS) {
            DN_PortalSalesBondsController psc = new DN_PortalSalesBondsController();
            DN_PortalSalesBondsController.GetUserInfo();
        }
        Test.stopTest();
    }

    @isTest
    static void Test_GetArInfo_Success() {
        User userS = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userS.Id);

        DN_PortalSalesBondsController.paramWrapper param = new DN_PortalSalesBondsController.paramWrapper();
        param.startDate = '20240101';
        param.endDate = '20240328';

        Test.startTest();
        System.runAs(userS) {
            Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Dealer_005_Success());
            DN_PortalSalesBondsController.GetArInfo(param, dli);
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Dealer_005_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"T_OUT":[{"ZUONR":"0100470951","ZTERM":"","ZFBDT":"2024-01-31","XREVERSAL":"","WRBTR":"-425000.00","WAERS":"KRW","VKBUR":"114D","USNAM":"I0212115","UMSKZ":"A","TXT20":"Ad.Received_Local","TOTAL":"-425000.00","TEXT1":"","STJAH":"0000","STBLG":"","SHKZG":"H","SHIP_TO_PARTY_NUM":"0001253988","SHIP_NAME":"한국유니콤밸브(주)당진","SALEDT":"2024-01-31","REPRE":"이석우","REBZZ":"000","REBZJ":"0000","REBZG":"","NAME_LAST":"김진원","NAME1":"한국유니콤밸브(주)당진","KWAERS":"KRW","KUNNR":"0001253988","HKONT":"0021080100","GUBUN":"Local","GSBER":"B140","GJAHR":"2024","FAEDT":"2024-01-31","DMBTR":"-425000.00","BUZEI":"001","BUKRS":"1800","BUDAT":"2024-02-01","BSCHL":"19","BLDAT":"2024-01-31","BLART":"DZ","BELNR":"1400001155","AUGGJ":"0000","AUGDT":"0000-00-00","AUGBL":"","ARREAR":"0.00","ADVJHR":"0000","ADVDOC":""}],"T_MSG":[],"T_LOG":[],"O_RETURN":{"TYPE":"S","MESSAGE":"Data found.","CODE":""}}'
            );
            return res;
        }
    }

    @isTest
    static void Test_GetArInfo_Success2() {
        User userS = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userS.Id);

        DN_PortalSalesBondsController.paramWrapper param = new DN_PortalSalesBondsController.paramWrapper();
        param.startDate = '20240101';
        param.endDate = '20240328';

        Test.startTest();
        System.runAs(userS) {
            Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Dealer_005_Success2());
            DN_PortalSalesBondsController.GetArInfo(param, dli);
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Dealer_005_Success2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"T_OUT":[{"ZUONR":"0100470951","ZTERM":"","ZFBDT":"2024-01-31","XREVERSAL":"","WRBTR":"-425000.00","WAERS":"","VKBUR":"114D","USNAM":"I0212115","UMSKZ":"A","TXT20":"Ad.Received_Local","TOTAL":"-425000.00","TEXT1":"","STJAH":"0000","STBLG":"","SHKZG":"H","SHIP_TO_PARTY_NUM":"0001253988","SHIP_NAME":"한국유니콤밸브(주)당진","SALEDT":"2024-01-31","REPRE":"이석우","REBZZ":"000","REBZJ":"0000","REBZG":"","NAME_LAST":"김진원","NAME1":"한국유니콤밸브(주)당진","KWAERS":"KRW","KUNNR":"0001253988","HKONT":"0021080100","GUBUN":"Local","GSBER":"B140","GJAHR":"2024","FAEDT":"2024-01-31","DMBTR":"-425000.00","BUZEI":"001","BUKRS":"1800","BUDAT":"2024-02-01","BSCHL":"19","BLDAT":"2024-01-31","BLART":"DZ","BELNR":"1400001155","AUGGJ":"0000","AUGDT":"0000-00-00","AUGBL":"","ARREAR":"0.00","ADVJHR":"0000","ADVDOC":""}],"T_MSG":[],"T_LOG":[],"O_RETURN":{"TYPE":"S","MESSAGE":"Data found.","CODE":""}}'
            );
            return res;
        }
    }
}