/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 02-27-2025
 * @last modified by  : daewook.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-27-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PortalPartDeliveryStatusCtrTest {
    private static final Id dealerId    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id productId   = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    private static User dealerUser;

    @testSetup
    static void setup() {
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
            Account acc = new Account(
                Name                     = 'TestDealerAccount'
                ,Representative__c       = 'TestAccCEO'
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
            insert acc;

            Contact cont = new Contact(
                AccountId    = acc.Id
               ,LastName     = 'dealCon'
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
           insert cont;

           Profile pf = [SELECT Id, Name FROM Profile WHERE Name = 'DNS CS Parts_Partner' LIMIT 1];
            // Dealer User 생성
            User dealerUser  = new User(
                ContactId           = cont.Id,
                ProfileId           = pf.Id,
                Username            = 'dealer@testDealer.com',
                Email               = 'dealer@testDealer.com',
                EmailEncodingKey    = 'UTF-8',
                Alias               = 'ulee',
                TimeZoneSidKey      = 'Asia/Seoul',
                LocaleSidKey        = 'ko',
                LanguageLocaleKey   = 'ko',
                LastName            = 'dealer',
                CommunityNickname   = 'DealerNickname',
                MobilePhone         = '010-5555-5555',
                Country__c          = 'KR',
                SalesOrganization__c = '1846',
                Division__c          = '40',
                DistributionChannel__c = '10'

            );
            insert dealerUser;

            Interface__c ifc1 = new Interface__c();
            ifc1.Name              = 'IF-PARTS-015';
            ifc1.ProcessingType__c = 'Real-Time';
            ifc1.Description__c    = '배송 상태 조회(TEST)';
            ifc1.IsActive__c       = true;
            ifc1.HttpMethod__c     = 'POST';
            ifc1.EndpointURL__c    = 'http://temp';
            ifc1.System__c         = 'ERP';
            ifc1.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            ifc1.Timeout__c        = 120000;
            insert ifc1;
            
            InterfaceClasses__c ifClass1 = new InterfaceClasses__c();
            ifClass1.Name         = 'IF_ERP_Parts_Shipping';
            ifClass1.Interface__c = ifc1.Id;
            insert ifClass1;

            Interface__c ifc2 = new Interface__c();
            ifc2.Name              = 'IF-PARTS-027';
            ifc2.ProcessingType__c = 'Real-Time';
            ifc2.Description__c    = '배송 상태 상세 조회(TEST)';
            ifc2.IsActive__c       = true;
            ifc2.HttpMethod__c     = 'POST';
            ifc2.EndpointURL__c    = 'http://temp';
            ifc2.System__c         = 'ERP';
            ifc2.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            ifc2.Timeout__c        = 120000;
            insert ifc2;
            
            InterfaceClasses__c ifClass2 = new InterfaceClasses__c();
            ifClass2.Name         = 'IF_ERP_Parts_Shipping';
            ifClass2.Interface__c = ifc2.Id;
            insert ifClass2;            
        }
    }

    @isTest
    static void testGetUserInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username = 'dealer@testDealer.com' LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            DN_PortalPartDeliveryStatusController.GetUserInfo();
        }
        Test.stopTest();
    }

    @isTest
    static void GetDeliveryStateInfo_Success() {
        DN_PortalPartDeliveryStatusController.SearchTerms searchTerms = new DN_PortalPartDeliveryStatusController.SearchTerms();
        searchTerms.startDate       = '20250201';
        searchTerms.endDate         = '20250217';
        searchTerms.deliveryNo      = '0003525454';
        searchTerms.orderNo         = '';
        searchTerms.shippingNo      = '';
        searchTerms.customerOrderNo = '';
        searchTerms.partNo          = '';
        searchTerms.shippingState   = 'A'; // 예: 'A' 출하대기

        User userId = [SELECT Id FROM User WHERE Username = 'dealer@testDealer.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        Test.startTest();
        System.runAs(userId) {
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_015_Success());
            DN_PortalPartDeliveryStatusController.GetDeliveryStateInfo(dealerInfo, searchTerms);
        }    
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_015_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_COUNT":"7","O_MESG":"Successfully finished.[ZSS90101]","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_LIST":[{"VGBEL":"3001955311","BEZEI_T":"","TPLST":"184A","VBELN":"8006466231","GEWEI_MAX":"KG","ZFETA":"2025-02-11","ZFMBLNO":"","TKNUM":"0003525454","BSTNK":"20250207_test_KSS","VSART":"D0","STTRG":"5","COUNT2":"1","COUNT1":"0","STTRG_T":"Shipment completion","BEZEI20":"링엔지니어링/정대봉/051-831-1204/부산강서대저3903","BEZEI":"Dom. Express","KUNNZ":"0001057644","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2025-02-07","KDINVOICE":"","TDLNR":"0011006427","NAME2":"경동화물(창원성산웅남72영업소)","NAME1":"링엔지니어링","WAERK":"","BRGEW":"0.426","VTEXT":"Truck","DATEN":"0000-00-00","EXTI1":"","VSBED":"20"},{"VGBEL":"3001955312","BEZEI_T":"","TPLST":"184A","VBELN":"8006466233","GEWEI_MAX":"KG","ZFETA":"2025-02-11","ZFMBLNO":"","TKNUM":"0003525455","BSTNK":"20250207_02_Test_KSS","VSART":"D0","STTRG":"5","COUNT2":"1","COUNT1":"0","STTRG_T":"Shipment completion","BEZEI20":"링엔지니어링/정대봉/051-831-1204/부산광역시 강서구 유통단지1로 41/대저2동 부산티플렉스131동 117,217,118,218호/46721","BEZEI":"Dom. Express","KUNNZ":"0001057644","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2025-02-07","KDINVOICE":"","TDLNR":"0011006427","NAME2":"경동화물(창원성산웅남72영업소)","NAME1":"링엔지니어링","WAERK":"","BRGEW":"0.426","VTEXT":"Domestic Express","DATEN":"0000-00-00","EXTI1":"","VSBED":"10"},{"VGBEL":"3001955316","BEZEI_T":"","TPLST":"1846","VBELN":"8006466246","GEWEI_MAX":"KG","ZFETA":"2025-02-14","ZFMBLNO":"","TKNUM":"0003525465","BSTNK":"구매입고Test2","VSART":"D1","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"링엔지니어링/정대봉/051-831-1204/부산광역시 강서구 유통단지1로 41/대저2동 부산티플렉스131동 117,217,118,218호/46721","BEZEI":"Dom. Quick Service","KUNNZ":"0001057644","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2025-02-12","KDINVOICE":"","TDLNR":"0011000259","NAME2":"원폰로지스 퀵&화물","NAME1":"링엔지니어링","WAERK":"","BRGEW":"0.000","VTEXT":"Quick Service","DATEN":"0000-00-00","EXTI1":"","VSBED":"90"},{"VGBEL":"3001955321","BEZEI_T":"","TPLST":"1846","VBELN":"8006466250","GEWEI_MAX":"KG","ZFETA":"2025-02-15","ZFMBLNO":"","TKNUM":"0003525470","BSTNK":"반품주문Test","VSART":"D0","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"링엔지니어링/정대봉/051-831-1204/부산강서대저3903","BEZEI":"Dom. Express","KUNNZ":"0001057644","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2025-02-13","KDINVOICE":"","TDLNR":"0011006427","NAME2":"경동화물(창원성산웅남72영업소)","NAME1":"링엔지니어링","WAERK":"","BRGEW":"4.788","VTEXT":"Truck","DATEN":"0000-00-00","EXTI1":"","VSBED":"20"},{"VGBEL":"3001955330","BEZEI_T":"","TPLST":"1846","VBELN":"8006466251","GEWEI_MAX":"KG","ZFETA":"2025-02-18","ZFMBLNO":"","TKNUM":"0003525471","BSTNK":"0214반품Test2","VSART":"D0","STTRG":"5","COUNT2":"1","COUNT1":"2","STTRG_T":"Shipment completion","BEZEI20":"링엔지니어링/정대봉/051-831-1204/부산광역시 강서구 유통단지1로 41/대저2동 부산티플렉스131동 117,217,118,218호/46721","BEZEI":"Dom. Express","KUNNZ":"0001057644","ZFCIVNO":"SPX2025027004","NETWR":"0.00","ZFOBDT":"2025-02-14","KDINVOICE":"","TDLNR":"0011006427","NAME2":"경동화물(창원성산웅남72영업소)","NAME1":"링엔지니어링","WAERK":"","BRGEW":"4.788","VTEXT":"Domestic Express","DATEN":"0000-00-00","EXTI1":"","VSBED":"10"},{"VGBEL":"3001955329","BEZEI_T":"","TPLST":"1846","VBELN":"8006466252","GEWEI_MAX":"KG","ZFETA":"2025-02-18","ZFMBLNO":"","TKNUM":"0003525472","BSTNK":"0214반품Test","VSART":"","STTRG":"1","COUNT2":"1","COUNT1":"0","STTRG_T":"Planning completed","BEZEI20":"링엔지니어링/정대봉/051-831-1204/부산광역시 강서구 유통단지1로 41/대저2동 부산티플렉스131동 117,217,118,218호/46721","BEZEI":"","KUNNZ":"","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"0000-00-00","KDINVOICE":"","TDLNR":"","NAME2":"","NAME1":"","WAERK":"","BRGEW":"9.576","VTEXT":"Loco(Spot)","DATEN":"0000-00-00","EXTI1":"","VSBED":"99"},{"VGBEL":"3001955334","BEZEI_T":"","TPLST":"1846","VBELN":"8006466253","GEWEI_MAX":"KG","ZFETA":"2025-02-18","ZFMBLNO":"","TKNUM":"0003525473","BSTNK":"링엔지니어링 생성","VSART":"D0","STTRG":"5","COUNT2":"1","COUNT1":"1","STTRG_T":"Shipment completion","BEZEI20":"링엔지니어링/링엔지니어링 부품 대리점/010-1234-1234/부산광역시 강서구 유통단지1로 41/46721","BEZEI":"Dom. Express","KUNNZ":"0001057644","ZFCIVNO":"","NETWR":"0.00","ZFOBDT":"2025-02-14","KDINVOICE":"","TDLNR":"0011006427","NAME2":"경동화물(창원성산웅남72영업소)","NAME1":"링엔지니어링","WAERK":"","BRGEW":"14.364","VTEXT":"Domestic Express","DATEN":"0000-00-00","EXTI1":"","VSBED":"10"}],"T_SALES_AREA":[{"SPART":"40","VKORG":"1846","VTWEG":"10"}]}'
            );
            return res;
        }
    }

    @isTest
    static void GetDeliveryDetail_Success() {
        DN_PortalPartDeliveryStatusController.SearchTerms searchTerms = new DN_PortalPartDeliveryStatusController.SearchTerms();
        searchTerms.startDate       = '20250201';
        searchTerms.endDate         = '20250217';
        searchTerms.deliveryNo      = '0003525419';
        searchTerms.orderNo         = '';
        searchTerms.shippingNo      = '';
        searchTerms.customerOrderNo = '';
        searchTerms.partNo          = '';
        searchTerms.shippingState   = 'A'; // 예: 'A' 출하대기

        User userId = [SELECT Id FROM User WHERE Username = 'dealer@testDealer.com' LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_027_Success());
            DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalPartDeliveryStatusController.GetUserInfo();
            DN_PortalPartDeliveryStatusController.GetDeliveryDetail(dealerInfo, searchTerms);
        }    
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_027_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_MESG":"Successfully finished.[ZSS90101]","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_SALES_AREA":[{"SPART":"40","VKORG":"1846","VTWEG":"10"}],"T_DETAIL":[{"ZFOBDT":"2024-12-09","MATNR_SH":"S6080040","STAWN":"","ZFCUSAMT":"0.00","ZFTOTAL":"0.00","ZFINSAMT":"0.00","ZFETCAMT_D":"0.00","BSTKD":"20241206","STTRG_T":"","ZFSTRAMT":"0.00","TKNUM":"0003525419","KVGR5":"40","NETPR":"31.80","ZFMBLNO":"","NETPR2":"0.00","INTCA3":"KR","KWMENG":"0","WAERK":"KRW","BRGEW_T":"0.000","MEINS":"EA","NTGEW_T":"0.000","NTGEW":"0.000","NETWR2":"0.00","PO_ITM_NO":"","STTRG":"5","GEWEI":"","KWERT":"0.00","POSNR_DO":"000000","MAKTX":"BEARING,BALL;THRUST","LFIMG":"10.000","ZFDOCAMT":"0.00","VSBED":"21","ZFHBLNO":"","ZFTRSAMT":"0.00","EXIDV":"00000000001006897964","VBELN_DO":"","ZFCIVNO":"","ZFDONO":"","ZFETCAMT":"0.00","HERKL":"KR","COUNT2":"0","VBELN2":"3001955097","COUNT1":"0","ZFETCAMT_S":"0.00","MATNR_SO":"S6080040","BRGEW":"0.000","ZFCIVDT":"0000-00-00","STABF":"","NETWR":"318.00"}]}'
            );
            return res;
        }
    }      
}