/**
 * @description       : (포탈) 채무 > 외상매입금 리스트
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 03-26-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-25-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_APControllerTest {
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

            Interface__c if020 = new Interface__c(
                Name               = 'IF-PARTS-020'
                ,ProcessingType__c = 'Real-Time'
                ,Description__c    = '채무 외상매입금 리스트 조회(TEST)'
                ,IsActive__c       = true
                ,HttpMethod__c     = 'POST'
                ,EndpointURL__c    = 'http://temp'
                ,System__c         = 'ERP'
                ,ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8'
                ,Timeout__c        = 120000
            );
            insert if020;

            InterfaceClasses__c IF_Class_020 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Parts_receivable'
                ,Interface__c = if020.Id
            );
            insert IF_Class_020;

            Interface__c if023 = new Interface__c(
                Name               = 'IF-PARTS-023'
                ,ProcessingType__c = 'Real-Time'
                ,Description__c    = '채무 외상매입금 상세 조회(TEST)'
                ,IsActive__c       = true
                ,HttpMethod__c     = 'POST'
                ,EndpointURL__c    = 'http://temp'
                ,System__c         = 'ERP'
                ,ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8'
                ,Timeout__c        = 120000
            );
            insert if023;

            InterfaceClasses__c IF_Class_023 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Parts_receivable'
                ,Interface__c = if023.Id
    
            );
            insert IF_Class_023;
        }
    }

    @isTest
    static void Test_getLoginUserInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username = 'dealerA@testDealer.com' LIMIT 1];
        Test.startTest();
        System.runAs(userId) {
        DN_APController.getLoginUserInfo();
        }
        Test.stopTest();
    }


    @isTest
    static void Test_GetInvoiceList_Success() {
        User userId = [SELECT Id, Account.Name, Account.CustomerCode__c, Division__c, SalesOrganization__c, DistributionChannel__c FROM User WHERE Username = 'dealerA@testDealer.com' LIMIT 1];
        DN_APController.InvoiceSearch search = new DN_APController.InvoiceSearch();
        search.I_KUNNR = '000'+userId.Account.CustomerCode__c;
        search.I_SPART = userId.Division__c;
        search.I_VKORG = userId.SalesOrganization__c;
        search.I_VTWEG = userId.DistributionChannel__c;
        search.I_F_VBELN = '';
        search.I_T_VBELN = '';
        search.I_F_BLDAT = '20250301';
        search.I_T_BLDAT = '20250325';

        Test.startTest();
        System.runAs(userId) {
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_020_Success());
            DN_APController.getInvoiceList(search);
        }
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_020_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_COUNT":"4","O_MESG":"Successfully finished.[ZSS90101]","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_INVOICE":[{"WRSHB":"1643873.00","VTEXT":"Sales:1~31, Due on 3 m end","ZTERM":"CPBC","BUZEI":"001","VBELN":"9006383072","WRBTR":"1643873.00","ZFCIVNO":"","VERZN":"-97","FAEDT":"2025-06-29","WAERK":"KRW","SEQNO":"000000","SHKZG":"S","WRBTR2":"0.00","BLDAT":"2025-03-24"},{"WRSHB":"-234267.00","VTEXT":"Sales:1~31, Due on 3 m end","ZTERM":"CPBC","BUZEI":"001","VBELN":"9006383073","WRBTR":"-234267.00","ZFCIVNO":"","VERZN":"-97","FAEDT":"2025-06-29","WAERK":"KRW","SEQNO":"000000","SHKZG":"H","WRBTR2":"0.00","BLDAT":"2025-03-24"},{"WRSHB":"626593.00","VTEXT":"Sales:1~31, Due on 3 m end","ZTERM":"CPBC","BUZEI":"001","VBELN":"9006383074","WRBTR":"626593.00","ZFCIVNO":"","VERZN":"-97","FAEDT":"2025-06-29","WAERK":"KRW","SEQNO":"000000","SHKZG":"S","WRBTR2":"0.00","BLDAT":"2025-03-24"},{"WRSHB":"108438.00","VTEXT":"Sales:1~31, Due on 3 m end","ZTERM":"CPBC","BUZEI":"001","VBELN":"9006383075","WRBTR":"108438.00","ZFCIVNO":"","VERZN":"-97","FAEDT":"2025-06-29","WAERK":"KRW","SEQNO":"000000","SHKZG":"S","WRBTR2":"0.00","BLDAT":"2025-03-24"}],"T_INVOICE1":[{"WRSHB":"23789.04","VTEXT":"Sales:1~31, Due on 3 m end","ZTERM":"CPBC","BUZEI":"001","VBELN":"","WRBTR":"23789.04","ZFCIVNO":"","VERZN":"-291","FAEDT":"2025-06-29","WAERK":"KRW","SEQNO":"000000","SHKZG":"S","WRBTR2":"0.00","BLDAT":"2025-03-24"},{"WRSHB":"-2342.67","VTEXT":"Sales:1~31, Due on 3 m end","ZTERM":"CPBC","BUZEI":"001","VBELN":"","WRBTR":"-2342.67","ZFCIVNO":"","VERZN":"-97","FAEDT":"2025-06-29","WAERK":"KRW","SEQNO":"000000","SHKZG":"H","WRBTR2":"0.00","BLDAT":"2025-03-24"}]}'
            );
            return res;
        }
    }

    @isTest
    static void Test_getDetail_Success() {
        User userId = [SELECT Id, Account.Name, Account.CustomerCode__c, Division__c, SalesOrganization__c, DistributionChannel__c FROM User WHERE Username = 'dealerA@testDealer.com' LIMIT 1];
        String vbeln = '9006383072';


        Test.startTest();
        System.runAs(userId) {
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_023_Success());
            DN_APController.getDetail(vbeln);
        }
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_023_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"E_TOTAL":"1,643,873","ES_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"select completed.","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""},"ET_LIST":[{"VGBEL":"8006466385","AUBEL":"3001955496","MWSBP":"128,146","FKIMG":"1","TOTAL":"1,409,606","MAKTX":"BEARING","VRKME":"SET","NETWR":"1,281,460","WAERK":"KRW","POSNR":"000011","MATNR":"140105-01262"},{"VGBEL":"8006466385","AUBEL":"3001955496","MWSBP":"21,297","FKIMG":"1","TOTAL":"234,267","MAKTX":"BEARING","VRKME":"SET","NETWR":"212,970","WAERK":"KRW","POSNR":"000021","MATNR":"140105-01319"}]}'
            );
            return res;
        }
    }    
}