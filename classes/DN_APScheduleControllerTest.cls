/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 09-01-2025
 * @last modified by  : daewook.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-20-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_APScheduleControllerTest {
    // Account recordType
    private static final Id accRT_Dealer = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id conRT_Dealer = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static User testDealer;

    @TestSetup
    static void makeData(){
        // 유저 역할 생성
        UserRole dealerRole = new UserRole(); 
        dealerRole.Name = 'PartsDealerRole';
        insert dealerRole;
 
        // 프로필 쿼리
        Profile adminProfile = [
            SELECT Id, Name 
            FROM Profile 
            WHERE Name = 'System Administrator' 
            OR Name = '시스템 관리자'
        ];

        // 관리자 유저 생성
        User adminTester = new User();
        adminTester.LastName = 'Owner';
        adminTester.UserName = 'ownerTester@test.com';
        adminTester.Email    = 'ownerTester@test.com';
        adminTester.Alias    = 'testOwn';

        adminTester.TimeZoneSidKey    = 'Asia/Seoul';
        adminTester.LocaleSidKey      = 'ko';
        adminTester.EmailEncodingKey  = 'UTF-8';
        adminTester.LanguageLocaleKey = 'en_US';        

        adminTester.ProfileId = adminProfile.Id;
        adminTester.UserRoleId  = dealerRole.Id;

        adminTester.SalesOrganization__c   = '1846';
        adminTester.DistributionChannel__c = '10';
        adminTester.Division__c            = '40';

        insert adminTester;

        // 관리자 유저의 행동
        System.runAs(adminTester) {
            // 회사 만들기
            Account testAcc = new Account();
            testAcc.Name                = 'TD Center';
            testAcc.Representative__c   = 'TestCEO';
            testAcc.RecordTypeId        = accRT_Dealer;
            testAcc.Phone               = '051-111-2222';
            testAcc.AccountNameEnglish__c = 'TD Center';
            testAcc.BusinessNumber__c     = '1000012345';
            testAcc.DealerGrade__c        = 'A';
            testAcc.SalesOrganization__c  = '1846';
            testAcc.SalesDistrict__c      = 'A1KR';
            testAcc.SalesOffice__c        = '114C';
            testAcc.DistributionChannel__c = '10';
            testAcc.Division__c           = '40';
            insert testAcc;

            // 연락처(=딜러) 만들기
            Contact testCon = new Contact();
            testCon.AccountId    = testAcc.Id;
            testCon.LastName     = 'DealerA';
            testCon.RecordTypeId = conRT_Dealer;
            testCon.Email        = 'DealerA@test.com';
            testCon.Position__c  = '대리';
            testCon.Role__c      = '영업';
            testCon.SalesOrganization__c = '1846';
            testCon.Division__c          = '40';
            testCon.DistributionChannel__c = '10';
            testCon.SalesOffice__c       = '114E';
            testCon.SalesDistrict__c     = 'A1KR';
            insert testCon;

            // 딜러 유저용 프로필
            Profile dealerProfile = [
                SELECT Id, Name
                FROM Profile
                WHERE Name = 'DNS CS Parts_Partner'
                LIMIT 1
            ];

            // 딜러 유저 생성
            User  testDealer = new User();
            testDealer.ContactId           = testCon.Id;
            testDealer.ProfileId           = dealerProfile.Id;
            testDealer.Username            = 'dealerA@testDealer.com';
            testDealer.Email               = 'dealerA@testDealer.com';
            testDealer.EmailEncodingKey    = 'UTF-8';
            testDealer.Alias               = 'ulee';
            testDealer.TimeZoneSidKey      = 'Asia/Seoul';
            testDealer.LocaleSidKey        = 'ko';
            testDealer.LanguageLocaleKey   = 'ko';
            testDealer.LastName            = 'dealerLastA';
            testDealer.CommunityNickname   = 'DealerNickname';
            testDealer.MobilePhone         = '010-5555-5555';
            testDealer.Country__c          = 'KR';
            testDealer.SalesOrganization__c = '1846';
            testDealer.Division__c          = '40';
            testDealer.DistributionChannel__c = '10';
            insert testDealer;

            // 목 인터페이스 생성
            Interface__c if021 = new Interface__c();
            if021.Name              = 'IF-PARTS-021';
            if021.ProcessingType__c = 'Real-Time';
            if021.Description__c    = '채무 스케줄(TEST)';
            if021.IsActive__c       = true;
            if021.HttpMethod__c     = 'POST';
            if021.EndpointURL__c    = 'http://temp';
            if021.System__c         = 'ERP';
            if021.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            if021.Timeout__c        = 120000;
            insert if021;

            InterfaceClasses__c ifCls = new InterfaceClasses__c();
            ifCls.Name         = 'IF_ERP_Parts_Pending';
            ifCls.Interface__c = if021.Id;
            insert ifCls;
        }
    }

    @isTest
    static void Ctor_Coverage() {
        Test.startTest();
        DN_APScheduleController ctrl = new DN_APScheduleController();
        System.assertNotEquals(null, ctrl, '인스턴스가 생성되어야 합니다.');
        Test.stopTest();
    }

    @isTest
    static void GetUserInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username = 'dealerA@testDealer.com' LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            DN_APScheduleController.GetUserInfo();
        }
        Test.stopTest();
    }    

    @isTest
    static void GetApList_Success() {
        User userId = [SELECT Id FROM User WHERE Username = 'dealerA@testDealer.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        Test.startTest();
        System.runAs(userId) {
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_021_Success());
            DN_APScheduleController.GetApList(dealerInfo);
        }
        
        Test.stopTest();
    }

    @isTest
    static void GetApList_Fail() {
        User userId = [SELECT Id FROM User WHERE Username = 'dealerA@testDealer.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = null;

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_APScheduleController.GetApList(dealerInfo);
            }catch(Exception e) {
                system.debug(e);
            }
        }
        
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_021_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{'
                +'"O_MESG":"Successfully finished.[ZSS90101]",'
                +'"O_RETURN":{'
                    +'"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""'
                +'},'
                +'"T_RECEIPT":['
                    +'{"FAEDT":"2024-04-29","WRBTR_OVERDUE":"0.00","SHKZG":"H","WAERK":"KRW","WRBTR3":"0.00","WRBTR2":"0.00","WRBTR":"-225753.00","WRSHB":"-225753.00"}'
                +'],'
                +'"T_LIST":['
                    +'{"WRSHB":"193193.00","VBELN":"9006358970","WRBTR":"193193.00","FAEDT":"2024-04-29","WAERK":"KRW","FKDAT":"2024-01-17","WRBTR3":"0.00","WRBTR2":"0.00","XBLNR":"9006358970"}'
                +'],'
                +'"O_COUNT":"1"'
                +'}'
            );
            return res;
        }
    }

}