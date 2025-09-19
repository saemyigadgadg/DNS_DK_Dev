/**
 * @description       : (포탈) 영업 > 채권 관리 > 주문별 수금 일정
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 05-15-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-24-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_ScheduleCollectionofOrderCtrTest {
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

            Interface__c ifc007 = new Interface__c(
                Name               = 'IF-DEALER-007'
                ,ProcessingType__c = 'Real-Time'
                ,Description__c    = '주문별 수금일정 조회(test)'
                ,IsActive__c       = true
                ,HttpMethod__c     = 'POST'
                ,EndpointURL__c    = 'http://temp'
                ,System__c         = 'ERP'
                ,ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8'
                ,Timeout__c        = 120000
            );
            insert ifc007;

            InterfaceClasses__c ifClass007 = new InterfaceClasses__c(
                Name = 'IF_ERP_Dealer'
                ,Interface__c = ifc007.Id
            );
            insert ifClass007;
        }
    }

    @isTest
    static void Test_GetUserInfo_Success() {
        User userS = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];

        Test.startTest();
        System.runAs(userS) {
            DN_ScheduleCollectionofOrderController psc = new DN_ScheduleCollectionofOrderController();
            DN_ScheduleCollectionofOrderController.GetUserInfo();
        }
        Test.stopTest();
    }

    @isTest
    static void Test_GetOrderSchedule_Success() {
        User userS = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userS.Id);
        String cc  = '1092766'; // customerCode
        String cNo = '0100471121'; // Contract code
        Boolean rev = false;
        Test.startTest();
        System.runAs(userS) {
            Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Dealer_007_Success());
            DN_ScheduleCollectionofOrderController.GetOrderSchedule(dli, cc, cNo, rev);
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Dealer_007_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"T_ORDER2":[],"T_ORDER":[{"ZZTERM":"","ZUONR":"0100471121","ZTERM":"","WRBTR":"1375000.00","WAERS":"KRW","VTWEG":"10","VTEXT2":"","VTEXT1":"","VKORG":"1800","VKBUR_NAME":"인천지사","VKBUR":"114B","VBELV":"0100471121","SPART":"40","REDUCE_INT":"0.00","REC_INT":"0.00","PAPH2":"","PAPH1":"","OVER_INCOM":"125000.00","OPEN_SUM":"0.00","OPEN_INT":"0.00","NETWR":"1250000.00","NAME1":"(주)뉴젠텍","MTART":"","MATNR":"","MAKTX":"","KUNNR":"0001092766","GSBER":"","FKDAT":"0000-00-00","DOWN_PAY":"125000.00","DMBTR":"0.00","CL_WRBTR":"0.00","CL_DMBTR":"0.00","CEO":"강동원","BUKRS":"1800","BOE_AMT":"0.00","AUDAT":"2024-02-01"}],"T_MSG":[],"T_LIST":[{"ZUONR":"0100471121","ZTERM":"CP00","ZFBDT":"2024-04-27","XREF1":"P0101","WRBTR":"250000.00","WAERS":"KRW","VTEXT2":"","VTEXT1":"","VBELV":"","VBELN_VF":"","SHKZG":"","SGTXT":"","SERNR":"","REDAMT":"0.00","REC_INT":"0.00","POSNR_VF":"000000","POSNR":"000000","PAPH2":"","PAPH1":"","OVDUE":"0","NETWR":"0.00","MWSKZ":"","MTART":"","METHOD":"","MATNR":"","LINE_TYPE":"","KURSF":"0.00000","KUNNR":"","INT_AMT":"0.00","INDAT":"0000-00-00","HLEVEL":"1","HKONT":"","GJAHR":"0000","FAEDT":"2024-04-27","DMBTR":"0.00","CL_WRBTR":"0.00","CL_DMBTR":"0.00","CAL_DAY":"0000-00-00","BUZEI":"000","BUDAT":"0000-00-00","BSCHL":"","BLDAT":"0000-00-00","BLART":"","BILLAMT":"0.00","BELNR":"","B2_GJAHR":"0000","B2_BELNR":"","AUGZZ":"000","AUGGJ":"0000","AUGDT":"0000-00-00","AUGBL":""},{"ZUONR":"0100471121","ZTERM":"C004","ZFBDT":"2024-05-30","XREF1":"P0201","WRBTR":"1125000.00","WAERS":"KRW","VTEXT2":"","VTEXT1":"","VBELV":"","VBELN_VF":"","SHKZG":"","SGTXT":"","SERNR":"","REDAMT":"0.00","REC_INT":"0.00","POSNR_VF":"000000","POSNR":"000000","PAPH2":"","PAPH1":"","OVDUE":"0","NETWR":"0.00","MWSKZ":"","MTART":"","METHOD":"","MATNR":"","LINE_TYPE":"","KURSF":"0.00000","KUNNR":"","INT_AMT":"0.00","INDAT":"0000-00-00","HLEVEL":"1","HKONT":"","GJAHR":"0000","FAEDT":"2024-05-30","DMBTR":"0.00","CL_WRBTR":"0.00","CL_DMBTR":"0.00","CAL_DAY":"0000-00-00","BUZEI":"000","BUDAT":"0000-00-00","BSCHL":"","BLDAT":"0000-00-00","BLART":"","BILLAMT":"0.00","BELNR":"","B2_GJAHR":"0000","B2_BELNR":"","AUGZZ":"000","AUGGJ":"0000","AUGDT":"0000-00-00","AUGBL":""}],"T_DOWN":[{"ZUONR":"0100471121","ZTERM":"","ZFBDT":"0000-00-00","XREF1":"01","WRBTR":"0.00","WAERS":"KRW","VTEXT2":"","VTEXT1":"","VBELV":"","VBELN_VF":"","SHKZG":"","SGTXT":"","SERNR":"","REDAMT":"0.00","REC_INT":"0.00","POSNR_VF":"000000","POSNR":"000000","PAPH2":"","PAPH1":"","OVDUE":"0","NETWR":"0.00","MWSKZ":"","MTART":"","METHOD":"","MATNR":"","LINE_TYPE":"","KURSF":"0.00000","KUNNR":"","INT_AMT":"0.00","INDAT":"0000-00-00","HLEVEL":"0","HKONT":"","GJAHR":"0000","FAEDT":"0000-00-00","DMBTR":"0.00","CL_WRBTR":"125000.00","CL_DMBTR":"125000.00","CAL_DAY":"0000-00-00","BUZEI":"000","BUDAT":"2024-02-02","BSCHL":"","BLDAT":"2024-01-31","BLART":"","BILLAMT":"0.00","BELNR":"","B2_GJAHR":"0000","B2_BELNR":"","AUGZZ":"001","AUGGJ":"2024","AUGDT":"0000-00-00","AUGBL":"1400001221"}],"T_ARSTATUS":[{"ZTERM":"CP00","ZFBDT":"2024-04-27","ZBD1T":"0","WRBTR":"250000.00","WAERS":"KRW","TEXT1":"","REM_INT":"0.00","RECIVE_DAT":"0000-00-00","REC_INT":"0.00","OVDUE":"0","LINE_NO":"001","INT_AMT":"0.00","GJAHR":"0000","FAEDT":"2024-04-27","DMBTR":"0.00","CLEAR":"0.00","BUZEI":"000","BUKRS":"","BUDAT":"0000-00-00","BSCHL":"","BOENO":"","BOE_ITM":"000","BOE_DOC":"","BILLAMT":"0.00","BELNR":"","AUJAH":"0000","AUGDT":"0000-00-00","AUGBL":""},{"ZTERM":"C004","ZFBDT":"2024-05-30","ZBD1T":"0","WRBTR":"1125000.00","WAERS":"KRW","TEXT1":"","REM_INT":"0.00","RECIVE_DAT":"0000-00-00","REC_INT":"0.00","OVDUE":"0","LINE_NO":"002","INT_AMT":"0.00","GJAHR":"0000","FAEDT":"2024-05-30","DMBTR":"0.00","CLEAR":"0.00","BUZEI":"000","BUKRS":"","BUDAT":"0000-00-00","BSCHL":"","BOENO":"","BOE_ITM":"000","BOE_DOC":"","BILLAMT":"0.00","BELNR":"","AUJAH":"0000","AUGDT":"0000-00-00","AUGBL":""}]}'
            );
            return res;
        }
    }

    @isTest
    static void Test_GetOrderSchedule_Success2() {
        User userS = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userS.Id);
        String cc  = '1092766'; // customerCode
        String cNo = '0100471121'; // Contract code
        Boolean rev = false;
        Test.startTest();
        System.runAs(userS) {
            Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Dealer_007_Success2());
            DN_ScheduleCollectionofOrderController.GetOrderSchedule(dli, cc, cNo, rev);
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Dealer_007_Success2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"T_ORDER2":[],"T_ORDER":[],"T_MSG":[],"T_LIST":[],"T_DOWN":[],"T_ARSTATUS":[]}'
            );
            return res;
        }
    }

    @isTest
    static void Test_GetOrderSchedule_Fail() {
        User userS = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userS.Id);
        String cc  = '1092766'; // customerCode
        String cNo = '0100471121'; // Contract code
        Boolean rev = false;
        Test.startTest();
        System.runAs(userS) {
            Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Dealer_007_Fail());
            try{
                DN_ScheduleCollectionofOrderController.GetOrderSchedule(dli, cc, cNo, rev);
            }catch(Exception e){
                system.debug(e);
            }
            
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Dealer_007_Fail implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"T_ORDER2":[],"T_ORDER":[{}],"T_MSG":[],"T_LIST":[],"T_DOWN":[],"T_ARSTATUS":[]}'
            );
            return res;
        }
    }
}