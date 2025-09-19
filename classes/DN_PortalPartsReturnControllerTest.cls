/**
 * @description       : (포탈) 부품 주문 > 반품 생성 & 조회
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 05-13-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-27-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PortalPartsReturnControllerTest {

    private static final Id accDealerId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id conDealerId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id product2Id  = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    private static final Id pcOrderId   = SObjectType.PurchaseOrder__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
    private static final Id returnPoId  = SObjectType.PurchaseOrder__c.getRecordTypeInfosByDeveloperName().get('ReturnOrder').getRecordTypeId();
    static String partnerUserName ='partACOCC@test.test.com';

    @TestSetup
    static void makeData(){
        UserRole adminRole = new UserRole(Name = 'PortalAdminRole');
        insert adminRole;

        Profile adminPF = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
        User adminUser = new User(
            LastName           = 'PortalAdmin'
            ,Username          = 'AdminPortal@tester.com'    
            ,Email             = 'AdminPortal@tester.com'
            ,Alias             = 'TestAD'
            ,TimeZoneSidKey    = 'Asia/Seoul'
            ,LocaleSidKey      = 'ko'
            ,EmailEncodingKey  = 'UTF-8'
            ,LanguageLocaleKey = 'en_US'
            ,ProfileId         = adminPF.Id
            ,UserRoleId        = adminRole.Id
            ,SalesOrganization__c    = '1846'
            ,DistributionChannel__c  = '10'
            ,Division__c             = '40'
        );
        insert adminUser;
        
        Contact con;
        Account acc;
        Product2 pr2;

        System.runAs(adminUser) {
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

            // Account testAcc = new Account(
            //     Name                     = 'TestReturnPartsAccount'
            //     ,RecordTypeId            = accDealerId
            //     ,Representative__c       = 'TestAccCEO'
            //     ,Phone                   = '000-0000-0000'
            //     ,AccountNameEnglish__c   = 'TestReturnPartsAccount'
            //     ,BusinessNumber__c       = '10000000000'
            //     ,CustomerCode__c         = '0001057644'
            //     ,DealerGrade__c          = 'A'
            //     ,SalesOrganization__c    = '1846'
            //     ,DistributionChannel__c  = '10'
            //     ,Division__c             = '40'
            //     ,SalesDistrict__c        = 'A1KR'
            //     ,SalesOffice__c          = '114C'
            // );
            // insert testAcc;

            // Contact testCon = new Contact(
            //     AccountId               = testAcc.Id
            //     ,RecordTypeId           = conDealerId
            //     ,LastName               = 'ConDealer'
            //     ,Email                  = 'ContDealer@TestReturnPartsAcc.com'
            //     ,Position__c            = '매니저'
            //     ,Role__c                = '딜러'
            //     ,SalesOrganization__c   = '1846'
            //     ,DistributionChannel__c = '10'
            //     ,Division__c            = '40'
            //     ,SalesOffice__c         = '114E'
            //     ,SalesDistrict__c       = 'A1KR'
            // ); 
            // insert testCon;

            // Profile dealerPF = [SELECT Id FROM Profile WHERE Name = 'DNS CS Parts_Partner' LIMIT 1];
            // User testDealer = new User(
            //     ContactId = testCon.Id
            //     ,ProfileId = dealerPF.Id
            //     ,LastName = 'PartsDealer'
            //     ,Username = 'partsDealer@TestReturnPartsAcc.com'
            //     ,Email = 'partsDealer@TestReturnPartsAcc.com'
            //     ,EmailEncodingKey = 'UTF-8'
            //     ,Alias = 'PartsDel'
            //     ,TimeZoneSidKey = 'Asia/Seoul'
            //     ,LocaleSidKey        = 'ko'
            //     ,LanguageLocaleKey   = 'ko'
            //     ,CommunityNickname   = 'DealerNickname'
            //     ,MobilePhone         = '010-5555-5555'
            //     ,Country__c          = 'KR'
            //     ,SalesOrganization__c = '1846'
            //     ,Division__c          = '40'
            //     ,DistributionChannel__c = '10'
            //     ,ERP_Key__c = 999
            // ); 
            // insert testDealer;

            pr2 = new Product2(
                Name         = 'S6500101'
                ,ProductCode = 'S6500101'
                ,IsActive    = true
                ,MaterialDetailsKO__c = 'RING,RETAINING;SHAFT'
                ,MaterialDetailsEN__c = 'RING,RETAINING;SHAFT'
                ,RecordTypeId = product2Id
            );
            insert pr2;

            PurchaseOrder__c por = new PurchaseOrder__c(
                RecordTypeId        = returnPoId
                ,PartOrderNo__c     = '3001954559'
                ,CustomerOrderNo__c = '_20240329'
                ,OrderType__c = 'YDIR'
                ,Buyer__c     = acc.Id
                // ,OwnerId      = testDealer.Id
            );
            insert por;

            PurchaseOrderItems__c poi = new PurchaseOrderItems__c(
                PurchaseOrder__c = por.Id
                ,ItemNo__c        = '000040'
                ,OrderPartNo__c   = 'S6500101'
                ,OrderPartId__c   = pr2.Id
                ,PartName__c  = 'CENTER,LIVE'
                ,Quantity__c  = 10
                ,Unit__c      = 'EA'
                ,UnitPrice__c = 80
            );
            insert poi;

            Interface__c ifc017 = new Interface__c(
                Name              = 'IF-PARTS-017',
                ProcessingType__c = 'Real-Time',
                Description__c    = '반품 부품 대상 조회(TEST)',
                IsActive__c       = true,
                HttpMethod__c     = 'POST',
                EndpointURL__c    = 'http://temp',
                System__c         = 'ERP',
                ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8',
                Timeout__c        = 120000
            );
            insert ifc017;

            InterfaceClasses__c ifClass017 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Parts_Return',
                Interface__c = ifc017.Id
            );
            insert ifClass017;

            Interface__c ifc018 = new Interface__c(
                Name              = 'IF-PARTS-018',
                ProcessingType__c = 'Real-Time',
                Description__c    = '반품 부품 대상 저장(TEST)',
                IsActive__c       = true,
                HttpMethod__c     = 'POST',
                EndpointURL__c    = 'http://temp',
                System__c         = 'ERP',
                ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8',
                Timeout__c        = 120000
            );
            insert ifc018;

            InterfaceClasses__c ifClass018 = new InterfaceClasses__c(
                Name         = 'IF_ERP_Parts_Return',
                Interface__c = ifc018.Id
            );
            insert ifClass018;            
        } // admin user 가 생성하는 부분

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
    } // TestSetup 부분

    @isTest
    static void Test_GetUserInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalPartsReturnController prc = new DN_PortalPartsReturnController();
                DN_PortalPartsReturnController.GetUserInfo();
                DN_PortalPartsReturnController.GetPicklistInfo();    
            }catch(Exception e) {}
        }
        Test.stopTest();
    }

    @isTest
    static void Test_GetReturnOrder_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userId.Id);
        String son = '3001989256';
        String sop = null;

        Test.startTest();
        System.runAs(userId) {
            try{
                Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_PARTS_017());
                DN_PortalPartsReturnController.GetReturnOrder(dli, son, sop);
            }catch(Exception e) {}
            
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_PARTS_017 implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"LV_MSG":"","LT_SEARCH2":[{"CL_QTY":"0.000","MWSBP":"0.80","AUPOS":"000000","AUBEL":"","SPART":"40","VBELN":"9006380060","BUDAT":"2024-03-29","VKORG":"1846","NETPR":"80.00","KWMENG":"10.000","MAKTX":"RING,RETAINING;SHAFT","FKIMG":"10.000","MATNR":"S6500101","KZWI2_N":"0.80","VRKME":"EA","VBTYP_VF":"M","KZWI2":"8.00","BSTKD":"_20240329","WAERS":"KRW","VTWEG":"10","NETWR":"800.00","ERDAT":"2024-03-29","POSNR":"000040","WAERK":"","MATWA":"S6500101","COUNT":"0","KONDA":"28","VBELN2":"","RFGSK":"","VBTYP":"C","XBLNR":"9006380060","VSBED":"20"}]}'
            );
            return res;
        }
    }

    @isTest
    static void Test_GetReturnOrder_Fail() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userId.Id);
        String son = '3001989256';
        String sop = null;

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalPartsReturnController.GetReturnOrder(dli, son, sop);
            }catch(Exception e){
                system.debug(e);
            }
        }
        Test.stopTest();
    }

    @isTest
    static void Test_GetReturnOrderItems_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userId.Id);

        Test.startTest();
        System.runAs(userId) {
            DN_PortalPartsReturnController.GetReturnOrderItems(dli);
        }
        Test.stopTest();
    }

    @isTest
    static void Test_UploadFile_Success() {
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('This is test file content.'),
            IsMajorVersion = true
        );
        insert cv;

        ContentVersion cv2 = new ContentVersion(
            Title = 'html File2',
            PathOnClient = 'TestFile2.html',
            VersionData = Blob.valueOf('This is test file2 content.'),
            IsMajorVersion = true
        );
        insert cv2;

        List<ContentVersion> cdId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test File'];
        List<ContentVersion> cvId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'html File2'];

        List<Id> fId = new List<Id>{cdId[0].ContentDocumentId};
        List<Id> uId = new List<Id>{cvId[0].Id};

        Test.startTest();
        DN_PortalPartsReturnController.checkFileSize(fId);
        DN_PortalPartsReturnController.DeleteFiles(fId, null);
        DN_PortalPartsReturnController.ConvertFile(fId);
        DN_PortalPartsReturnController.SplitFile(uId);
        Test.stopTest();
    }

    @isTest
    static void Test_saveRefundOrder_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userId.Id);
        List<DN_PortalPartWrapper.RefundDetail> refundList = new List<DN_PortalPartWrapper.RefundDetail>();
        DN_PortalPartWrapper.RefundDetail rfr = new DN_PortalPartWrapper.RefundDetail();
        rfr.customerOrderNo = '_20240329';
        rfr.partOrderId = '';
        rfr.machineName = '';
        rfr.equipmentNo = '';
        rfr.purchaseOrder = '';
        rfr.poiId = '';
        rfr.urgency = '';
        
        rfr.invoice = '9006380060';
        rfr.itemNo = '000040';
        rfr.orderPartNo = 'S6500101';
        rfr.note = '테스트 코드 작성용 레코드 생성';
        rfr.orderQty = '10';
        rfr.unit = 'EA';
        rfr.unitPrice = 80;
        rfr.netValue = '800.00';
        rfr.complaintReason1 = 'A';
        rfr.complaintReason2 = 'A01';
        rfr.description = 'RING,RETAINING;SHAFT';
        rfr.originDocDate = Date.valueOf('2024-03-29');
        rfr.orderDate = Date.valueOf('2024-03-29');
        refundList.add(rfr);

        DN_PortalPartWrapper.RefundOrderInfo roi = new DN_PortalPartWrapper.RefundOrderInfo();
        roi.dealerInfo    = dli;
        roi.refundOrderNo = '9006380060';
        roi.partOrderNo   = '';
        roi.refundCustomerOrderNo = 'testCustomerOrderNo';
        roi.refundList            = refundList;

        Test.startTest();
        System.runAs(userId) {
            Test.setMock(HttpCalloutMock.class, new Mock_IF_ERP_PARTS_018());
            DN_PortalPartsReturnController.saveRefundOrder(roi);
        }
        Test.stopTest();
    }

    private class Mock_IF_ERP_PARTS_018 implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Document 7100253613 created."},"O_VBELN":"7100253613"}'
            );
            return res;
        }
    }

/* ===========================================================조회 테스트 코드=========================================================== */
/* ===========================================================조회 테스트 코드=========================================================== */
/* ===========================================================조회 테스트 코드=========================================================== */

    @isTest
    static void Test_GetReturnOrderInfo_Success() {
        Date today = Date.today();
        Date twoDay = today.addDays(2);        

        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userId.Id);
        DN_PortalPartWrapper.ReturnOrderTerms rot = new DN_PortalPartWrapper.ReturnOrderTerms();
        rot.dealerInfo = dli;
        rot.returnOrderNo = '';
        rot.referenceNo = '';
        rot.orderPartNo = '';
        rot.startDate = today;
        rot.endDate = twoDay;

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalPartsReturnController.GetReturnOrderInfo(rot);
            }catch(Exception e) {}
            
        }
        Test.stopTest();
    }
}