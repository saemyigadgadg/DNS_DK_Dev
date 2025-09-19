/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 05-08-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-26-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PortalPartOrderCreateControllerTest {
    private static final Id accDealerId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id conDealerId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id product2Id  = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    static String partnerUserName ='partACOCC@test.test.com';
    
    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'partDealerRole');
        insert dealerRole;

        Profile adminPF = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];

        User testAdmin = new User(
            UserName = 'testAdmin@dncompany.com.test1',
            Email    = 'testAdmin@dncompany.com.test1',
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
                CustomerCode__c       = '0001057644',
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

            // Profile dealerPF = [SELECT Id FROM Profile WHERE Name = 'DNS CS Parts_Partner' LIMIT 1];
            // User dealer = new User(
            //     ContactId = con.Id,
            //     ProfileId = dealerPF.Id,
            //     UserName  = 'dealer@TestDealerAccount.com',
            //     Email     = 'dealer@TestDealerAccount.com',
            //     EmailEncodingKey = 'UTF-8',
            //     Alias            = 'Dealer',
            //     TimeZoneSidKey      = 'Asia/Seoul',
            //     LocaleSidKey        = 'ko',
            //     LanguageLocaleKey   = 'ko',
            //     LastName            = 'dealer',
            //     CommunityNickname   = 'DealerNickname',
            //     MobilePhone         = '010-5555-5555',
            //     Country__c          = 'KR',
            //     SalesOrganization__c = '1846',
            //     Division__c          = '40',
            //     DistributionChannel__c = '10',
            //     ERP_Key__c = 777
            // );
            // insert dealer;

            pr2 = new Product2(
                Name        = 'R18181',
                ProductCode = 'R18181',
                IsActive    = true,
                MaterialDetailsKO__c = 'CENTER,LIVE',
                MaterialDetailsEN__c = 'CENTER,LIVE',
                RecordTypeId = product2Id
            );
            insert pr2;

            Interface__c ifc002 = new Interface__c(
                Name              = 'IF-PARTS-002',
                ProcessingType__c = 'Real-Time',
                Description__c    = '오더생성>배송정보(TEST)',
                IsActive__c       = true,
                HttpMethod__c     = 'POST',
                EndpointURL__c    = 'http://temp',
                System__c         = 'ERP',
                ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8',
                Timeout__c        = 120000
            );
            insert ifc002;

            InterfaceClasses__c ifClass002 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Parts_Shipping',
                Interface__c = ifc002.Id
            );
            insert ifClass002;

            Interface__c ifc004 = new Interface__c(
                Name              = 'IF-PARTS-004',
                ProcessingType__c = 'Real-Time',
                Description__c    = '오더생성>시뮬전대체품(TEST)',
                IsActive__c       = true,
                HttpMethod__c     = 'POST',
                EndpointURL__c    = 'http://temp',
                System__c         = 'ERP',
                ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8',
                Timeout__c        = 120000
            );
            insert ifc004;

            InterfaceClasses__c ifClass004 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Parts_Substitute',
                Interface__c = ifc004.Id
            );
            insert ifClass004;

            Interface__c ifc003 = new Interface__c(
                Name              = 'IF-PARTS-003',
                ProcessingType__c = 'Real-Time',
                Description__c    = '오더생성>시뮬(TEST)',
                IsActive__c       = true,
                HttpMethod__c     = 'POST',
                EndpointURL__c    = 'http://temp',
                System__c         = 'ERP',
                ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8',
                Timeout__c        = 120000
            );
            insert ifc003;

            InterfaceClasses__c ifClass003 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Parts_Order',
                Interface__c = ifc003.Id
            );
            insert ifClass003;

            Interface__c ifc009 = new Interface__c(
                Name              = 'IF-PARTS-009',
                ProcessingType__c = 'Real-Time',
                Description__c    = '오더생성>시뮬(TEST)',
                IsActive__c       = true,
                HttpMethod__c     = 'POST',
                EndpointURL__c    = 'http://temp',
                System__c         = 'ERP',
                ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8',
                Timeout__c        = 120000
            );
            insert ifc009;

            InterfaceClasses__c ifClass009 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Parts_Order',
                Interface__c = ifc009.Id
            );
            insert ifClass009;
            Interface__c ifc005 = new Interface__c(
                Name              = 'IF-PARTS-005',
                ProcessingType__c = 'Real-Time',
                Description__c    = '오더생성>저장(TEST)',
                IsActive__c       = true,
                HttpMethod__c     = 'POST',
                EndpointURL__c    = 'http://temp',
                System__c         = 'ERP',
                ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8',
                Timeout__c        = 120000
            );
            insert ifc005;

            InterfaceClasses__c ifClass005 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Parts_Order',
                Interface__c = ifc005.Id
            );
            insert ifClass005;
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
        }
    }

    // 사용자 정보 확인 테스트
    @isTest
    static void testGetUserInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalPartOrderCreateController.GetUserInfo();
            }catch(Exception e) {}
            
        }
        Test.stopTest();
    }

    // 오더 유형 불러오기
    @isTest
    static void GetOrderTypeList_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            DN_PortalPartOrderCreateController.GetOrderTypeList();
        }
        Test.stopTest();
    }

    // 배송방법 선택 테스트
    @isTest
    static void GetShippingInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        Test.startTest();
        System.runAs(userId) {
            try{
                Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Parts_002());
                DN_PortalPartOrderCreateController.GetShippingInfo(dealerInfo);
            }catch(Exception e) {}
            
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Parts_002 implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"T_LIST":[{"INCO2":"공장 인도 가격","VSBED":"10","INCO1":"EXW","ZTERM":"CPBC","VTWEG":"10","ROUTE_TX":"","ROUTE":"","VKORG":"1846","KUNNR":"0001057644","VSBED_TX":"내수 택배","ZTERM_TX":"","SPART":"40"}]}'
            );
            return res;
        }
    }

    // 부품 CRM 등록 확인 테스트
    @isTest
    static void SearchPartNo_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        List<String> pn = new List<String> {'R18181'};

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalPartOrderCreateController.SearchPartNo(pn);
            }catch(Exception e) {}
            
        }
        Test.stopTest();
    }

    // 시뮬 전 대체품 검사 테스트
    @isTest
    static void CheckReplacement_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        List<String> pn = new List<String> {'R18181'};
        List<DN_PortalPartOrderCreateController.PartsList> plt = new List<DN_PortalPartOrderCreateController.PartsList>();
        DN_PortalPartOrderCreateController.PartsList pl = new DN_PortalPartOrderCreateController.PartsList();
        pl.hang        = '000010';
        pl.orderPartNo = 'R18181';
        pl.quantity    = '1.000';
        pl.machine     = '';
        pl.equipment   = '';

        plt.add(pl);
        
        Test.startTest();
        System.runAs(userId) {
            try{
                Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Parts_004());
                DN_PortalPartOrderCreateController.CheckReplacement(dealerInfo, plt);    
            }catch(Exception e){

            }
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Parts_004 implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"T_ITEM":[{"COMPLAINT":"","MATERIAL_DIA":"","CUST_MAT22":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"","HERKL":"","MATERIAL_ENT":"","UOM":"","SPEC":"","GEWEI":"","LOT_CHECK":"","BULLETIN":"","NET_PRICE":"0.00","DIEUMT":"0.000","MITEM":"X","USAGE_HILV":"","ZZEQMASTER":"","ATP_QTY":"0.000","CORE_PARTS":"0.00","MATERIAL_TEXT":"","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"","REF_ORD":"","CCHECK":"","MATERIAL":"R18181","QTY":"1.000","KBETR":"0.00","ZZDEALDT":"0000-00-00","WAERS":"","LANDX":"","KSTOCK":"","CURRENCY":"","ZZWORKHRS":"","KUNNR_SHIP":"","NET_VALUE":"0.00","KUNNR":"","MATNR_CHECK":"","MATERIAL_N":"","R":"","INPUT_QTY":"0.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"","REF_ITEM":"000000","NTGEW":"0.000","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000010","SUGRD":"","STORE_LOC":"","CHEKCABLE":"","ACCEPT":"","REQ_QTY":"1.000","PLANT":"","RT_QTY":"0.000","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000000","DIEUCE":"0.000","MIN_QTY":"0.000","DIUKL":"0.000","BO":"","HQ_QTY":"0.000","MEINS":"","MTPOS":"","MVGR5":"","BD":"","MATNR_DESIGN":"00","BULL_MATNR":"","STAWN":""}]}'
            );
            return res;
        }
    }

    // 시뮬레이션 테스트
    @isTest
    static void GetSimulationInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        List<IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM> plt = new List<IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM>();
        IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM pt = new IF_ERP_Parts_Substitute_Classes.IF_PARTS_004_Res_T_ITEM();
        pt.ITEM       = '000010';
        pt.MATERIAL   = 'R18181';
        pt.QTY        = '1.000';
        pt.REQ_QTY    = '1.000';
        pt.ZZEQMASTER = '';
        pt.ZZWORKHRS  = '';
        plt.add(pt);

        String odt = 'YDOR';
        Test.startTest();
        System.runAs(userId) {
            try{
                Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Parts_003());
                Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Parts_009());
                DN_PortalPartOrderCreateController.GetSimulationInfo(dealerInfo, plt, odt);    
            }catch(Exception e) {}
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Parts_003 implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"E_MEG":"","LS_MAIN_HEAD_RESULT":{"KONDA":"28","KUNNR":"0001057644","KUNNR_NAME":"","KUNNR_STREET":"","KUNAG":"0001057644","KUNAG_NAME":"","KUNAG_STREET":"","KUNNR_CR":"","NETWR":"175021.00","WAERK":"KRW","CREDIT":"68093898.00","CREDIT_WAERK":"KRW","TOTAL_WEIGHT":"90.000","GEWEI":"KG","VOLUM":"0.000","VOLEH":"CBM","KONDA_TEXT":"","KVGR5":"40","NAME":"","CITY":"","STREET":"","COUNTRY":"","POSTL_CODE":"","TRANSPZONE":"","ORDER_DATE":"0000-00-00","PRICE_LIST":"","COLLECT_NO":"","ZTERM":"","ORD_REASON":"","BZIRK":"","DOCUFEE":""},"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"LS_GENERAL":{"BSTNK":"","VDATU":"2025-02-27","INCO1":"","INCO2":"","VSBED":"","COMPLETE_DELIVERY":"","ROUTE":"","VSBED_TX":"","ROUTE_TX":"","SPECPROCID":"","POSSIBLE_DATE":"2025-02-27","IF_FROM":"0000-00-00","TO":"0000-00-00","AUDAT":"0000-00-00","ERZET":"00:00:00","BSTKD_E":"","ZZCFDAT":"0000-00-00"},"ERRORMSG":[],"LT_BAPIRET2":[{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"233","PARAMETER":"SALES_HEADER_IN","MESSAGE":"SALES_HEADER_IN has been processed successfully","FIELD":"","ROW":"0","TYPE":"S","ID":"V4","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":"VBAKKOM"},{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"233","PARAMETER":"SALES_ITEM_IN","MESSAGE":"SALES_ITEM_IN has been processed successfully","FIELD":"","ROW":"1","TYPE":"S","ID":"V4","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"000010","MESSAGE_V1":"VBAPKOM"},{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"555","PARAMETER":"VBUVKOM","MESSAGE":"The sales document is not yet complete: Edit data","FIELD":"","ROW":"0","TYPE":"W","ID":"V1","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"000010","MESSAGE_V1":"VBAPKOM"}],"LT_ITEM":[{"COMPLAINT":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"","HERKL":"KR","MATERIAL_ENT":"R18181","UOM":"EA","GEWEI":"KG","BULLETIN":"X","NET_PRICE":"0.00","NET_ITEM_PRICE":"0.00","MITEM":"","MEMO_MATNR":"","EMERC":"","USAGE_HILV":"","ZZEQMASTER":"","MATERIAL_TEXT":"라이브센터","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"DNS Parts","REF_ORD":"","CCHECK":"","MATERIAL":"R18181","QTY":"1.000","ZZDEALDT":"0000-00-00","BSTKD_E":"","WAERS":"","TDLNR":"","IF_CURRENCY":"KRW","ZZWORKHRS":"","NET_VALUE":"0.00","KUNNR":"","MATNR_CHECK":"X","MATERIAL_N":"","R":"","INPUT_QTY":"1.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"X","REF_ITEM":"000000","TNDR_TRKID":"","NTGEW":"0.000","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000010","SUGRD":"0006","CHEKCABLE":"","ACCEPT":"","AVAIL_QTY1":"0.000","REQ_QTY":"1.000","PLANT":"1846","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000000","DIEUCE":"0.000","MIN_QTY":"0.000","TDLNR_NAME":"","DIUKL":"0.000","BO":"","MEINS":"","STATUS":"","MVGR5":"","BD":"","MEMO":"","MATNR_DESIGN":"00","BULL_MATNR":"R18181","BSTDK_E":"0000-00-00"},{"COMPLAINT":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"N","HERKL":"KR","MATERIAL_ENT":"R18181","UOM":"EA","GEWEI":"KG","BULLETIN":"X","NET_PRICE":"159110.00","NET_ITEM_PRICE":"159110.00","MITEM":"","MEMO_MATNR":"","EMERC":"","USAGE_HILV":"A","ZZEQMASTER":"","MATERIAL_TEXT":"라이브센터","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"DNS Parts","REF_ORD":"","CCHECK":"","MATERIAL":"R18181","QTY":"1.000","ZZDEALDT":"0000-00-00","BSTKD_E":"","WAERS":"","TDLNR":"","IF_CURRENCY":"KRW","ZZWORKHRS":"","NET_VALUE":"159110.00","KUNNR":"","MATNR_CHECK":"X","MATERIAL_N":"","R":"","INPUT_QTY":"1.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"X","REF_ITEM":"000000","TNDR_TRKID":"","NTGEW":"4.422","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000011","SUGRD":"0006","CHEKCABLE":"","ACCEPT":"","AVAIL_QTY1":"0.000","REQ_QTY":"1.000","PLANT":"1846","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000010","DIEUCE":"0.000","MIN_QTY":"0.000","TDLNR_NAME":"","DIUKL":"0.000","BO":"","MEINS":"","STATUS":"","MVGR5":"","BD":"","MEMO":"","MATNR_DESIGN":"00","BULL_MATNR":"R18181","BSTDK_E":"0000-00-00"}],"LT_NON_EXIST":[],"LT_NON_PRICE":[],"LT_NON_PURCHASE":[],"LT_NON_QTY":[],"LT_PRICING_01":[{"NETWR":"0.00","WAERK":"KRW","NAME":"Item Total (A)","NEWR":"159110.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Freight(B)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Insurance(C)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Handling Charge(D)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Output Tax(E)","NEWR":"15911.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Total Amt(A+B+C+D+E)","NEWR":"175021.00"}],"LT_PRICING_02":[{"NETWR":"1591.10","WAERK":"KRW","NAME":"Item Total(Doosan) (A-F)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Commission value(F)","NEWR":"0.00"}],"LT_STATUS":[],"LT_WRONG_DIVISION":[],"LT_WRONG_ITEM":[],"IF_RETURN":[]}'
            );
            return res;
        }
    }

    private class Mock_IF_ERP_Parts_009 implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"E_MEG":"","LS_MAIN_HEAD_RESULT":{"KONDA":"28","KUNNR":"0001057644","KUNNR_NAME":"","KUNNR_STREET":"","KUNAG":"0001057644","KUNAG_NAME":"","KUNAG_STREET":"","KUNNR_CR":"","NETWR":"175021.00","WAERK":"KRW","CREDIT":"68093898.00","CREDIT_WAERK":"KRW","TOTAL_WEIGHT":"90.000","GEWEI":"KG","VOLUM":"0.000","VOLEH":"CBM","KONDA_TEXT":"","KVGR5":"40","NAME":"","CITY":"","STREET":"","COUNTRY":"","POSTL_CODE":"","TRANSPZONE":"","ORDER_DATE":"0000-00-00","PRICE_LIST":"","COLLECT_NO":"","ZTERM":"","ORD_REASON":"","BZIRK":"","DOCUFEE":""},"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"LS_GENERAL":{"BSTNK":"","VDATU":"2025-02-27","INCO1":"","INCO2":"","VSBED":"","COMPLETE_DELIVERY":"","ROUTE":"","VSBED_TX":"","ROUTE_TX":"","SPECPROCID":"","POSSIBLE_DATE":"2025-02-27","IF_FROM":"0000-00-00","TO":"0000-00-00","AUDAT":"0000-00-00","ERZET":"00:00:00","BSTKD_E":"","ZZCFDAT":"0000-00-00"},"ERRORMSG":[],"LT_BAPIRET2":[{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"233","PARAMETER":"SALES_HEADER_IN","MESSAGE":"SALES_HEADER_IN has been processed successfully","FIELD":"","ROW":"0","TYPE":"S","ID":"V4","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":"VBAKKOM"},{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"233","PARAMETER":"SALES_ITEM_IN","MESSAGE":"SALES_ITEM_IN has been processed successfully","FIELD":"","ROW":"1","TYPE":"S","ID":"V4","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"000010","MESSAGE_V1":"VBAPKOM"},{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"555","PARAMETER":"VBUVKOM","MESSAGE":"The sales document is not yet complete: Edit data","FIELD":"","ROW":"0","TYPE":"W","ID":"V1","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"000010","MESSAGE_V1":"VBAPKOM"}],"LT_ITEM":[{"COMPLAINT":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"","HERKL":"KR","MATERIAL_ENT":"R18181","UOM":"EA","GEWEI":"KG","BULLETIN":"X","NET_PRICE":"0.00","NET_ITEM_PRICE":"0.00","MITEM":"","MEMO_MATNR":"","EMERC":"","USAGE_HILV":"","ZZEQMASTER":"","MATERIAL_TEXT":"라이브센터","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"DNS Parts","REF_ORD":"","CCHECK":"","MATERIAL":"R18181","QTY":"1.000","ZZDEALDT":"0000-00-00","BSTKD_E":"","WAERS":"","TDLNR":"","IF_CURRENCY":"KRW","ZZWORKHRS":"","NET_VALUE":"0.00","KUNNR":"","MATNR_CHECK":"X","MATERIAL_N":"","R":"","INPUT_QTY":"1.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"X","REF_ITEM":"000000","TNDR_TRKID":"","NTGEW":"0.000","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000010","SUGRD":"0006","CHEKCABLE":"","ACCEPT":"","AVAIL_QTY1":"0.000","REQ_QTY":"1.000","PLANT":"1846","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000000","DIEUCE":"0.000","MIN_QTY":"0.000","TDLNR_NAME":"","DIUKL":"0.000","BO":"","MEINS":"","STATUS":"","MVGR5":"","BD":"","MEMO":"","MATNR_DESIGN":"00","BULL_MATNR":"R18181","BSTDK_E":"0000-00-00"},{"COMPLAINT":"","KONDM":"","NETPR":"0.00","AVAILABILITY":"N","HERKL":"KR","MATERIAL_ENT":"R18181","UOM":"EA","GEWEI":"KG","BULLETIN":"X","NET_PRICE":"159110.00","NET_ITEM_PRICE":"159110.00","MITEM":"","MEMO_MATNR":"","EMERC":"","USAGE_HILV":"A","ZZEQMASTER":"","MATERIAL_TEXT":"라이브센터","DIID":"0.000","DIEUFL":"0.000","DIUK":"0.000","POUND":"0.000","REQ_QTY_DESIGN":"00","ERRORMSG":"","PLANT_TX":"DNS Parts","REF_ORD":"","CCHECK":"","MATERIAL":"R18181","QTY":"1.000","ZZDEALDT":"0000-00-00","BSTKD_E":"","WAERS":"","TDLNR":"","IF_CURRENCY":"KRW","ZZWORKHRS":"","NET_VALUE":"159110.00","KUNNR":"","MATNR_CHECK":"X","MATERIAL_N":"","R":"","INPUT_QTY":"1.000","COMPLAINT_DESC":"","LIST_PRICE":"0.00","DI":"0.000","O":"","EXCEL":"X","REF_ITEM":"000000","TNDR_TRKID":"","NTGEW":"4.422","DB":"","ZZAPPMACHINE":"","REASON":"","COMPLAINT_REASON":"","D":"","C":"","A":"","ITEM":"000011","SUGRD":"0006","CHEKCABLE":"","ACCEPT":"","AVAIL_QTY1":"0.000","REQ_QTY":"1.000","PLANT":"1846","TO_PART":"","ERRORCHECK":"","LOT_QTY":"0.000","HILV":"000010","DIEUCE":"0.000","MIN_QTY":"0.000","TDLNR_NAME":"","DIUKL":"0.000","BO":"","MEINS":"","STATUS":"","MVGR5":"","BD":"","MEMO":"","MATNR_DESIGN":"00","BULL_MATNR":"R18181","BSTDK_E":"0000-00-00"}],"LT_NON_EXIST":[],"LT_NON_PRICE":[],"LT_NON_PURCHASE":[],"LT_NON_QTY":[],"LT_PRICING_01":[{"NETWR":"0.00","WAERK":"KRW","NAME":"Item Total (A)","NEWR":"159110.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Freight(B)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Insurance(C)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Handling Charge(D)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Output Tax(E)","NEWR":"15911.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Total Amt(A+B+C+D+E)","NEWR":"175021.00"}],"LT_PRICING_02":[{"NETWR":"1591.10","WAERK":"KRW","NAME":"Item Total(Doosan) (A-F)","NEWR":"0.00"},{"NETWR":"0.00","WAERK":"KRW","NAME":"Commission value(F)","NEWR":"0.00"}],"LT_STATUS":[],"LT_WRONG_DIVISION":[],"LT_WRONG_ITEM":[],"IF_RETURN":[]}'
            );
            return res;
        }
    }

    @isTest
    static void SavePartOrder_Success() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestDealerAccount' LIMIT 1];
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        
        DN_PortalPartOrderCreateController.ShippingLocation spl = new DN_PortalPartOrderCreateController.ShippingLocation();
        spl.customerCode = '1057644';
        spl.customerId   = acc.Id;
        spl.partManager  = '링엔지니어링 부품 대리점';
        spl.partManagerMP   = '010-1234-1234';
        spl.shippingAddress = '(46721) 부산광역시 강서구 유통단지1로 41, 링엔지니어링';
        spl.shippingDestination = '링엔지니어링';
        spl.street              = '부산광역시 강서구 유통단지1로 41';
        spl.supplier            = 'DN Solutions';
        spl.zipCode             = '46721';

        DN_PortalPartOrderCreateController.shippingInfo spi = new DN_PortalPartOrderCreateController.shippingInfo();
        spi.paymentTerm2 = 'CPBC';
        spi.paymentTerm  = 'CPBC';
        spi.requestedDeliveryDate = Date.valueOf('2025-03-01');
        spi.shippingCode   = '10';
        spi.shippingRoute2 = null;
        spi.shippingRoute  = null;
        spi.shippingTerm   = '내수 택배';
        spi.transportationTermOne = 'EXW';
        spi.transportationTermTwo = '공장 인도 가격';

        List<DN_PortalPartOrderCreateController.PartsList> crmList = new List<DN_PortalPartOrderCreateController.PartsList>();
        DN_PortalPartOrderCreateController.PartsList crm = new DN_PortalPartOrderCreateController.PartsList();
        crm.availableStock  = '0';
        crm.bulletin        = 'X';
        crm.equipment       = '호기';
        crm.hang            = '000011';
        crm.machine         = '기종';
        crm.note            = '';
        crm.orderPartId     = '01tJO000004NsjlYAC';
        crm.orderPartNo     = 'R18181';
        crm.partId          = null;
        crm.partName        = '라이브센터';
        crm.quantity        = '1';
        crm.salesUnit       = '1';
        crm.supplyPartId    = '01tJO000004NsjlYAC';
        crm.supplyPartNo    = 'R18182';
        crm.twp             = '';
        crm.unit            = 'EA';
        crm.unitPrice       = '159110';
        crm.urgency         = false;
        crmList.add(crm);

        List<DN_PortalPartOrderCreateController.PartsList> sapList = new List<DN_PortalPartOrderCreateController.PartsList>();
        DN_PortalPartOrderCreateController.PartsList sap = new DN_PortalPartOrderCreateController.PartsList();
        sap.availableStock='0';
        sap.bulletin='X';
        sap.equipment='호기';
        sap.hang='000010';
        sap.machine='기종';
        sap.note='';
        sap.orderPartId='01tJO000004NsjlYAC';
        sap.orderPartNo='R18181';
        sap.partId=null;
        sap.partName='라이브센터';
        sap.quantity='1';
        sap.salesUnit='1';
        sap.supplyPartId='01tJO000004NsjlYAC';
        sap.supplyPartNo='R18181';
        sap.twp='';
        sap.unit='EA';
        sap.unitPrice='0';
        sap.urgency=false;
        sapList.add(sap);

        DN_PortalPartOrderCreateController.OrderCreateInfo oci = new DN_PortalPartOrderCreateController.OrderCreateInfo();
        oci.dealerInfo = dealerInfo;
        oci.orderType = 'YDOR';
        oci.customerOrderNo = 'test create';
        oci.consolidatedShipping = 'Yes';
        oci.shippingLocation = spl;
        oci.shippingInfo = spi;
        oci.crmPartsList = crmList;
        oci.sapPartsList = sapList;

        Test.startTest();
        System.runAs(userId) {

            Boolean custom = true;
            try {
                Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_Parts_005());
                DN_PortalPartOrderCreateController.SavePartOrder(oci, custom);    
            } catch(Exception e) {
                system.debug(e);
            }
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_Parts_005 implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"E_MEG":"Dom Ordinary Order 3001955384 has been saved","LS_MAIN_HEAD_RESULT":{"KONDA":"","KUNNR":"","KUNNR_NAME":"","KUNNR_STREET":"","KUNAG":"","KUNAG_NAME":"","KUNAG_STREET":"","KUNNR_CR":"","NETWR":"0.00","WAERK":"","CREDIT":"0.00","CREDIT_WAERK":"","TOTAL_WEIGHT":"0.000","GEWEI":"","VOLUM":"0.000","VOLEH":"","KONDA_TEXT":"","KVGR5":"","NAME":"","CITY":"","STREET":"","COUNTRY":"","POSTL_CODE":"","TRANSPZONE":"","ORDER_DATE":"0000-00-00","PRICE_LIST":"","COLLECT_NO":"","ZTERM":"","ORD_REASON":"","BZIRK":"","DOCUFEE":""},"LV_VENLR":"3001955384","LT_BAPIRET2":[{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"311","PARAMETER":"SALES_HEADER_IN","MESSAGE":"Dom Ordinary Order 3001955384 has been saved","FIELD":"","ROW":"0","TYPE":"S","ID":"V1","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"3001955384","MESSAGE_V1":"Dom Ordinary Order"},{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"233","PARAMETER":"SALES_HEADER_IN","MESSAGE":"SALES_HEADER_IN has been processed successfully","FIELD":"","ROW":"0","TYPE":"S","ID":"V4","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"","MESSAGE_V1":"VBAKKOM"},{"IF_SYSTEM":"GSQCLNT880","LOG_NO":"","LOG_MSG_NO":"000000","IF_NUMBER":"233","PARAMETER":"SALES_ITEM_IN","MESSAGE":"SALES_ITEM_IN has been processed successfully","FIELD":"","ROW":"1","TYPE":"S","ID":"V4","MESSAGE_V4":"","MESSAGE_V3":"","MESSAGE_V2":"000010","MESSAGE_V1":"VBAPKOM"}]}'
            );
            return res;
        }
    }
}