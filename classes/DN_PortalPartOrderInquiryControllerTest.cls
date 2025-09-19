/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 09-02-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-26-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PortalPartOrderInquiryControllerTest {
    private static final Id accDealerId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id conDealerId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id product2Id  = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    private static final Id pcOrderId   = SObjectType.PurchaseOrder__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
    static String partnerUserName ='partACOCC@test.test.com';

    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'partDealerRole');
        insert dealerRole;

        Profile adminPF = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];

        User testAdmin = new User(
            UserName = 'testAdmin@dncompany.com.test',
            Email    = 'testAdmin@dncompany.com.test',
            EmailEncodingKey = 'UTF-8',
            Alias            = 'TestAD',
            TimeZoneSidKey   = 'Asia/Seoul',
            LocaleSidKey     = 'ko',
            LastName         = 'Owner',
            LanguageLocaleKey = 'en_US',
            ProfileId         = adminPF.Id,
            UserRoleId        = dealerRole.Id,
            SalesOrganization__c    = '1846',
            DistributionChannel__c  = '10',
            Division__c             = '40'
        );
        insert testAdmin;

        Contact con;
        Account acc;
        Product2 pr2;
        System.runAs(testAdmin) {
            acc = new Account(
                Name             = 'TestDealerAccount',
                RecordTypeId     = accDealerId,
                Representative__c = 'TestAccCEO',
                Phone            = '051-555-5555',
                AccountNameEnglish__c = 'TestDealerAccount',
                BusinessNumber__c     = '1234567890',
                CustomerCode__c       = '1218163602',
                DealerGrade__c        = 'A',
                SalesOrganization__c    = '1846',
                SalesDistrict__c        = 'A1KR',
                SalesOffice__c          = '114C',
                DistributionChannel__c  = '10',
                Division__c             = '40'
            );
            insert acc;

            con = new Contact(
                AccountId = acc.Id,
                RecordTypeId = conDealerId,
                LastName     = 'conDealer',
                Email        = 'conDealer@TestDealerAccount.com',
                Position__c  = '사원',
                Role__c      = '영업',
                DistributionChannel__c = '10',
                Division__c            = '40',
                SalesOffice__c         = '114E',
                SalesDistrict__c       = 'A1KR',
                SalesOrganization__c   = '1846'
            );
            insert con;

            pr2 = new Product2(
                Name        = 'R18181',
                ProductCode = 'R18181',
                IsActive    = true,
                MaterialDetailsKO__c = 'CENTER,LIVE',
                MaterialDetailsEN__c = 'CENTER,LIVE',
                RecordTypeId = product2Id
            );
            insert pr2;
        }

        User partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
        partnerTestUser.SalesOrganization__c = '1846';
        partnerTestUser.DistributionChannel__c = '10';
        partnerTestUser.Division__c = '40';
        partnerTestUser.Username = partnerUserName;
        insert partnerTestUser;

        System.runAs(partnerTestUser) {
            DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(acc.Id);
            customer.Name = 'dealerCustomer';
            customer.RoadAddr__c = '부산광역시 강서구 유통단지1로 41';
            customer.DetailInfo__c = '대저2동 부산티플렉스131동 117,217,118,218호';
            
            insert customer;

            DealerCustomerShipTo__c shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(customer.Id);
            shipTo.IsDealer__c = true;
            insert shipTo;

            PurchaseOrder__c por = new PurchaseOrder__c(
                RecordTypeId       = pcOrderId,
                PartOrderNo__c     = '3001989256',
                CustomerOrderNo__c = 'testCodeNo',
                OrderType__c = 'YDOR',
                Buyer__c     = acc.Id,
                OwnerId = partnerTestUser.Id
            );
            insert por;

            PurchaseOrderItems__c poi = new PurchaseOrderItems__c(
                PurchaseOrder__c = por.Id,   // MD Id
                ItemNo__c        = '000011', // 항목
                OrderPartNo__c   = 'R18181', // 주문품번
                OrderPartId__c   = pr2.Id,   // 부품 Id
                PartName__c  = 'CENTER,LIVE', // 품명
                Quantity__c  = 1,    // 요청 수량
                Unit__c      = 'EA', // 요청 단위
                UnitPrice__c = 1000  // 단가
            );
            insert poi;

            Interface__c ifc037 = new Interface__c(
                Name              = 'IF-SERVICE-037',
                ProcessingType__c = 'Real-Time',
                Description__c    = '오더조회>상세조회>기본정보(TEST)',
                IsActive__c       = true,
                HttpMethod__c     = 'POST',
                EndpointURL__c    = 'http://temp',
                System__c         = 'ERP',
                ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8',
                Timeout__c        = 120000
            );
            insert ifc037;

            InterfaceClasses__c ifClass037 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Service_PartsDetail',
                Interface__c = ifc037.Id
            );
            insert ifClass037;

            Interface__c ifc038 = new Interface__c(
                Name              = 'IF-SERVICE-038',
                ProcessingType__c = 'Real-Time',
                Description__c    = '오더조회>상세조회>기본정보-대체품(TEST)',
                IsActive__c       = true,
                HttpMethod__c     = 'POST',
                EndpointURL__c    = 'http://temp',
                System__c         = 'ERP',
                ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8',
                Timeout__c        = 120000
            );
            insert ifc038;

            InterfaceClasses__c ifClass038 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Service_PartsDetail',
                Interface__c = ifc038.Id
            );
            insert ifClass038;   
        }
    }

    @IsTest
    static void coverConstructor() {
        Test.startTest();
        DN_PortalPartOrderInquiryController c = new DN_PortalPartOrderInquiryController();
        System.assertNotEquals(null, c);
        Test.stopTest();
    }

    // 사용자 정보 확인 테스트
    @isTest
    static void testGetUserInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            DN_PortalPartOrderInquiryController.GetUserInfo();
        }
        Test.stopTest();
    }

    // 오더 조회 테스트
    @isTest
    static void GetPurchaseOrderList_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        Account accId = [SELECT Id FROM Account WHERE Name = 'TestDealerAccount' LIMIT 1];
        Product2 pr2Id = [SELECT Id FROM Product2 WHERE Name = 'R18181' LIMIT 1];
        PurchaseOrder__c poi = [SELECT Id, RecordTypeId FROM PurchaseOrder__c WHERE PartOrderNo__c = '3001989256' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        Date today = Date.today();
        
        DN_PortalPartOrderInquiryController.PurchaseOrderTerm poTerm = new DN_PortalPartOrderInquiryController.PurchaseOrderTerm();
        poTerm.dealerInfo = dealerInfo;
        poTerm.partOrderNo = '3001989256';
        poTerm.customerOrderNo = 'testCodeNo';
        poTerm.orderType = 'YDOR';
        poTerm.startDate = '2025-08-28';
        poTerm.endDate = '2025-09-02';

        Test.startTest();
        System.runAs(userId) {
            DN_PortalPartOrderInquiryController.GetPurchaseOrderList(poTerm);
        }
        Test.stopTest();
    }

    @isTest
    static void GetPurchaseOrderList_Fail() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        Account accId = [SELECT Id FROM Account WHERE Name = 'TestDealerAccount' LIMIT 1];
        Product2 pr2Id = [SELECT Id FROM Product2 WHERE Name = 'R18181' LIMIT 1];
        PurchaseOrder__c poi = [SELECT Id, RecordTypeId FROM PurchaseOrder__c WHERE PartOrderNo__c = '3001989256' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        Date today = Date.today();
        
        DN_PortalPartOrderInquiryController.PurchaseOrderTerm poTerm = new DN_PortalPartOrderInquiryController.PurchaseOrderTerm();

        Test.startTest();
        System.runAs(userId) {
            try {
                DN_PortalPartOrderInquiryController.GetPurchaseOrderList(poTerm);
            }catch(Exception e){
                system.debug(e);
            }
        }
        Test.stopTest();
    }    

    @isTest
    static void GetDetailInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        String pon = '3001989256';
        Test.startTest();
        System.runAs(userId) {
            DN_PortalPartOrderInquiryController.GetDetailInfo(pon);
        }
        Test.stopTest();
    }

    @isTest
    static void GetDetailInfo_Fail() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        String pon = '300198925600';
        Test.startTest();
        System.runAs(userId) {
            try {
                DN_PortalPartOrderInquiryController.GetDetailInfo(pon);
            }catch(Exception e){
                system.debug(e);
            }
            
        }
        Test.stopTest();
    }

    @isTest
    static void GetBasicPartInfo_Fail() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        String pon = '3001989256';
        Test.startTest();
        System.runAs(userId) {
            try{
                Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Service_037());
                DN_PortalPartOrderInquiryController.GetBasicPartInfo(dealerInfo, pon);
            }catch(Exception e){
                system.debug(e);
            }

        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Service_037 implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_THREAD":"#GLC 5BN","O_RETURN":{"TYPE":"S","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","CODE":""},"O_RESULT":{"ZPRAT":"N","VTEXT":"P Pricing Type","SVRCD_TEXT":"Service","SVRCD":"S","SVC_FLAG":"Y","REMARK2":"","PRODH_T":"OTHERS","PRODH":"SP3003016030160001","PLIFZ":"30","NTGEW":"4.422","NOTCD_TEXT":"","NOTCD":"","NETPR_ETC":"159110.00","NETPR":"205300.00","MEINS":"EA","MAKTX":"CENTER,LIVE","M_MATNR":"","LFMNG":"0.000","KWMENG":"227.000","KONDM":"P","IF_CURRENCY":null,"HERKL":"KR","GROES":"","GEWEI":"KG","DATAB":"2024-03-02","CURRENCY2":"KRW","COND_VALUE":"205300.000000000","C_MTPOS":"N","BULET":"","BRGEW":"90.000","AVRLT":"19","AVA_FLAG":"Y","AUMNG":"0.000"},"O_MESG":"Successfully finished.[ZSS90101]","O_MATERIAL":"M. DES-S7051","O_MANUFACT":"","O_AVAIL_QTY":"18.000","ET_CROSS":[{"SVRCD_TEXT":"Not service","SVRCD":"N","SEQ":" 1-1","NOTCD":"CPS","MXNE":null,"MATNR":"430210-00262","MAKTX":"COUPLING,FLEXIBLE","LABST":"1.000","ITCCD":"I","DDTEXT":"Component parts serviced"},{"SVRCD_TEXT":"Service","SVRCD":"S","SEQ":" 1-2","NOTCD":"","MXNE":null,"MATNR":"R18181","MAKTX":"CENTER,LIVE","LABST":"18.000","ITCCD":"Y","DDTEXT":""},{"SVRCD_TEXT":"Service","SVRCD":"S","SEQ":" 1-3","NOTCD":"","MXNE":null,"MATNR":"R18182","MAKTX":"CENTER,LIVE","LABST":"0.000","ITCCD":"","DDTEXT":""}],"ET_AVAIL":[{"NONMV":"Moving","NAME1":"영진기계","DEALER_CD":"0001057455","AVQTY":"4.000"},{"NONMV":"Moving","NAME1":"링엔지니어링","DEALER_CD":"0001057644","AVQTY":"10.000"},{"NONMV":"Moving","NAME1":"명성기계","DEALER_CD":"0001244220","AVQTY":"1.000"}]}'
            );
            return res;
        }
    }

    @isTest
    static void GetReplacePart_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        String pon = '3001989256';
        Test.startTest();
        System.runAs(userId) {
            try{
                Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Service_037());
                DN_PortalPartOrderInquiryController.GetReplacePart(pon, dealerInfo);
            }catch(Exception e) {
                
            }
        }
        Test.stopTest();
    }

    @isTest
    static void GetReplacePart_fail() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = null;
        // DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        String pon = null;
        Test.startTest();
        System.runAs(userId) {
            try{
                Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Service_037());
                DN_PortalPartOrderInquiryController.GetReplacePart(pon, dealerInfo);
            }catch(Exception e) {
                
            }
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Service_038 implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"T_LIST":[{"MATNR":"R18181","MAKTX":"라이브센터","AVA_FLAG":"N"},{"MATNR":"R18182","MAKTX":"라이브센터","AVA_FLAG":"N"}],"O_RETURN":{"TYPE":"S","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","CODE":""},"O_MESG":"Successfully finished.[ZSS90101]","O_COUNT":"2"}'
            );
            return res;
        }
    }
}