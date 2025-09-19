/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 02-27-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-25-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PortalPartsOrderStatusControllerTest {
    // Account recordType
    private static final Id accRT_Dealer = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id conRT_Dealer = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id porRT_Dealer = SObjectType.PurchaseOrder__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
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
            testAcc.CustomerCode__c       = '1057644';
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

            // 오더 생성
            PurchaseOrder__c por = new PurchaseOrder__c();
            por.PartOrderNo__c      = '3001955295';
            por.recordTypeId        = porRT_Dealer;
            por.CustomerOrderNo__c  = 'classTEST';
            por.OrderType__c        = 'YDOR';
            por.BLOCK__c            = '';
            por.ShippingTerm__c     = '트럭';
            insert por;

            PurchaseOrderItems__c poi = new PurchaseOrderItems__c();
            poi.PurchaseOrder__c      = por.Id;
            poi.ItemNo__c             = '000011';
            poi.OrderPartNo__c        = 'R18181';
            poi.PartName__c           = 'CENTER,LIVE';
            poi.Quantity__c           = 1;
            poi.SupplyPartNo__c       = 'R18182';
            insert poi;
    

            // 목 인터페이스 생성
            Interface__c if013 = new Interface__c();
            if013.Name              = 'IF-PARTS-013';
            if013.ProcessingType__c = 'Real-Time';
            if013.Description__c    = '오더 상태 상세(TEST)';
            if013.IsActive__c       = true;
            if013.HttpMethod__c     = 'POST';
            if013.EndpointURL__c    = 'http://temp';
            if013.System__c         = 'ERP';
            if013.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            if013.Timeout__c        = 120000;
            insert if013;

            InterfaceClasses__c ifCls013 = new InterfaceClasses__c();
            ifCls013.Name         = 'IF_ERP_Parts_Order';
            ifCls013.Interface__c = if013.Id;
            insert ifCls013;

            Interface__c if026 = new Interface__c();
            if026.Name              = 'IF-PARTS-026';
            if026.ProcessingType__c = 'Real-Time';
            if026.Description__c    = '오더 상태 상세 저장(TEST)';
            if026.IsActive__c       = true;
            if026.HttpMethod__c     = 'POST';
            if026.EndpointURL__c    = 'http://temp';
            if026.System__c         = 'ERP';
            if026.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            if026.Timeout__c        = 120000;
            insert if026;

            InterfaceClasses__c ifCls026 = new InterfaceClasses__c();
            ifCls026.Name         = 'IF_ERP_Parts_Order';
            ifCls026.Interface__c = if026.Id;
            insert ifCls026;
        }
    }

    // 오더 상태 - 사용자 정보
    @isTest
    static void GetUserInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username = 'dealerA@testDealer.com' LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            DN_PortalPartsOrderStatusController.GetUserInfo();
        }
        Test.stopTest();
    }

    // 오더 상태 - 조회
    @isTest
    static void GetOrderStatus_Success() {
        User userId = [SELECT Id FROM User WHERE Username = 'dealerA@testDealer.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        DN_PortalPartsOrderStatusController.OrderStatusTerm osi = new DN_PortalPartsOrderStatusController.OrderStatusTerm();
        osi.partOrderNo     = null;
        osi.customerOrderNo = null;
        osi.partNo          = null;
        osi.orderType       = 'All';
        osi.startDate       = '2025-02-01';
        osi.endDate         = '2025-02-23';
        osi.shippingState   = 'Carryover';
        osi.dealerInfo      = dealerInfo;

        Test.startTest();
        System.runAs(userId) {
            DN_PortalPartsOrderStatusController.GetOrderStatus(osi);
            osi.partOrderNo     = '3001955295';
            osi.customerOrderNo = 'classTEST';
            osi.partNo          = 'R18181';
            osi.shippingState   = 'Shipped';
            osi.orderType       = 'YDOR';
            DN_PortalPartsOrderStatusController.GetOrderStatus(osi);
        }
        Test.stopTest();
    }

    // 업데이트
    @isTest
    static void GetPoiList_Success() {
        User userId = [SELECT Id FROM User WHERE Username = 'dealerA@testDealer.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        String pon = '3001955295';
        List<Map<String, Object>> osi = new List<Map<String, Object>>{
            new Map<String, Object> {
                'itemNo' => '000011',
                'orderQty' => 5,
                'confirmQty' => 5,
                'packingQty' => 0,
                'stayQty' => 5,
                'completeQty' => 0,
                'urgency' => false,
                'estimatedSupplyDate' => '2025-02-25',
                'changeSupplyDate' => '2025-02-26',
                'shippingDate' => null,
                'shippingSpot' => ''
            }
        };

        Test.startTest();
        System.runAs(userId) {
            DN_PortalPartsOrderStatusController.GetPoiList(pon, osi);
        }
        Test.stopTest();
    }

    @isTest
    static void GetOrderStatusDetail_Success() {
        User userId = [SELECT Id FROM User WHERE Username = 'dealerA@testDealer.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        List<String> pon = new List<String>{'3001955295'};
        String sDate = '2025-02-01';
        String eDate = '2025-02-25';

        Test.startTest();
        System.runAs(userId) {
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_013_Success());
            DN_PortalPartsOrderStatusController.GetOrderStatusDetail(pon, sDate, eDate, dealerInfo);
        }
        Test.stopTest();        
    }

    private class MockIF_ERP_Parts_013_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_MESG":"Successfully finished.[ZSS90101]","O_COUNT":"2","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_SALES_AREA":[{"SPART":"40","VKORG":"1846","VTWEG":"10"}],"T_DETAIL":[{"MATNR_SH":"400821-00193-CS","ETENR":"0001","SH_QTY":"0.000","RE_QTY":"0.000","STB_QTY":"0.000","VBELN":"2001404733","FST_ETD":"2025-02-18","PI_QTY":"0.000","MAKTX":"HYDRAULIC UNIT;IE3","SO_QTY":"50.000","VRKME":"SET","IN_QTY":"0.000","BSTKD":"250214 오더 생성 테스트(긴급)","DODAT":"0000-00-00","EMERC":"T","AUDAT":"2025-02-14","ERDAT":"2025-02-14","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000011","AUART":"YDEO","POSNR_H":"000011","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R33100","AUART_T":"SP Domestic EO","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"20"},{"MATNR_SH":"R18181","ETENR":"0001","SH_QTY":"0.000","RE_QTY":"0.000","STB_QTY":"20.000","VBELN":"2001404733","FST_ETD":"2025-02-18","PI_QTY":"0.000","MAKTX":"CENTER,LIVE","SO_QTY":"20.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"250214 오더 생성 테스트(긴급)","DODAT":"0000-00-00","EMERC":"","AUDAT":"2025-02-14","ERDAT":"2025-02-14","VSTEL":"1846","CFM_QTY":"20.000","POSNR":"000041","AUART":"YDEO","POSNR_H":"000041","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R18181","AUART_T":"SP Domestic EO","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"20"}]}{"O_MESG":"Successfully finished.[ZSS90101]","O_COUNT":"2","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_SALES_AREA":[{"SPART":"40","VKORG":"1846","VTWEG":"10"}],"T_DETAIL":[{"MATNR_SH":"400821-00193-CS","ETENR":"0001","SH_QTY":"0.000","RE_QTY":"0.000","STB_QTY":"0.000","VBELN":"2001404733","FST_ETD":"2025-02-18","PI_QTY":"0.000","MAKTX":"HYDRAULIC UNIT;IE3","SO_QTY":"50.000","VRKME":"SET","IN_QTY":"0.000","BSTKD":"250214 오더 생성 테스트(긴급)","DODAT":"0000-00-00","EMERC":"T","AUDAT":"2025-02-14","ERDAT":"2025-02-14","VSTEL":"1846","CFM_QTY":"0.000","POSNR":"000011","AUART":"YDEO","POSNR_H":"000011","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R33100","AUART_T":"SP Domestic EO","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"20"},{"MATNR_SH":"R18181","ETENR":"0001","SH_QTY":"0.000","RE_QTY":"0.000","STB_QTY":"20.000","VBELN":"2001404733","FST_ETD":"2025-02-18","PI_QTY":"0.000","MAKTX":"CENTER,LIVE","SO_QTY":"20.000","VRKME":"EA","IN_QTY":"0.000","BSTKD":"250214 오더 생성 테스트(긴급)","DODAT":"0000-00-00","EMERC":"","AUDAT":"2025-02-14","ERDAT":"2025-02-14","VSTEL":"1846","CFM_QTY":"20.000","POSNR":"000041","AUART":"YDEO","POSNR_H":"000041","VTEXT":"DNS 부품 창원창고 출하처","MATNR_SO":"R18181","AUART_T":"SP Domestic EO","LST_ETD":"0000-00-00","KONDA_T":"","KONDA":"20"}]}'
            );
            return res;
        }
    }

    @isTest
    Static void ChangeUrgency_Success() {
        User userId = [SELECT Id FROM User WHERE UserName = 'dealerA@testDealer.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        String pon = '3001955295';
        List<PurchaseOrderItems__c> poi = [
            SELECT ItemNo__c, Quantity__c, ConfirmedQty__c, PackingCompleted__c, PenddingQty__c, CompletedQty__c, Urgency__c, ExpectedSupplyDate__c, RevisedSupplyDate__c, ShipmentDate__c, DepartureSite__c
            FROM PurchaseOrderItems__c
            WHERE PurchaseOrder__r.PartOrderNo__c =:pon
            LIMIT 1
            ];

        Test.startTest();
        System.runAs(userId) {
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_026_Success());
            DN_PortalPartsOrderStatusController.ChangeUrgency(pon, poi, dealerInfo);
        }
        Test.stopTest();        
    }

    private class MockIF_ERP_Parts_026_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"ES_RETURN":{"TYPE":"S","ID":"","NUMBER":"000","MESSAGE":"Saved successfully.","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":"0","FIELD":"","SYSTEM":""}}'
            );
            return res;
        }
    }

}