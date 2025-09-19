/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 04-23-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-07-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
private class DN_PortalPartsInfoControllerTest {
    private static final Id dealerId    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id productId   = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    static String partnerUserName ='partACOCC@test.test.com';

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

        Contact con;
        Account acc;
        Product2 pr2;
        System.runAs(testAdminUser) {
            acc = new Account(
                Name                     = 'TestDealerAccount'
                ,Representative__c       = 'TestAccCEO'
                ,RecordTypeId            =  dealerId
                ,Phone                   = '02-555-5555'
                ,AccountNameEnglish__c   = 'TestDealerAccount'
                ,BusinessNumber__c       = '1111111111'
                ,CustomerCode__c         = '1218163602'
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

            con = new Contact(
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
           insert con;

        //    Profile pf = [SELECT Id, Name FROM Profile WHERE Name = 'DNS CS Parts_Partner' LIMIT 1];
        //     // Dealer User 생성
        //     User dealerUser  = new User(
        //         ContactId           = cont.Id,
        //         ProfileId           = pf.Id,
        //         Username            = 'dealer@testDealer.com',
        //         Email               = 'dealer@testDealer.com',
        //         EmailEncodingKey    = 'UTF-8',
        //         Alias               = 'ulee',
        //         TimeZoneSidKey      = 'Asia/Seoul',
        //         LocaleSidKey        = 'ko',
        //         LanguageLocaleKey   = 'ko',
        //         LastName            = 'dealer',
        //         CommunityNickname   = 'DealerNickname',
        //         MobilePhone         = '010-5555-5555',
        //         Country__c          = 'KR',
        //         SalesOrganization__c = '1846',
        //         Division__c          = '40',
        //         DistributionChannel__c = '10'

        //     );
        //     insert dealerUser;

            Interface__c ifc1 = new Interface__c();
            ifc1.Name              = 'IF-SERVICE-037';
            ifc1.ProcessingType__c = 'Real-Time';
            ifc1.Description__c    = '부품 기본 정보 조회(TEST)';
            ifc1.IsActive__c       = true;
            ifc1.HttpMethod__c     = 'POST';
            ifc1.EndpointURL__c    = 'http://temp';
            ifc1.System__c         = 'ERP';
            ifc1.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            ifc1.Timeout__c        = 120000;
            insert ifc1;
            
            InterfaceClasses__c ifClass1 = new InterfaceClasses__c();
            ifClass1.Name         = 'IF_ERP_Service_PartsDetail';
            ifClass1.Interface__c = ifc1.Id;
            insert ifClass1;
            
            Interface__c ifc2 = new Interface__c();
            ifc2.Name              = 'IF-SERVICE-038';
            ifc2.ProcessingType__c = 'Real-Time';
            ifc2.Description__c    = '부품 대체품 조회(TEST)';
            ifc2.IsActive__c       = true;
            ifc2.HttpMethod__c     = 'POST';
            ifc2.EndpointURL__c    = 'http://temp';
            ifc2.System__c         = 'ERP';
            ifc2.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            ifc2.Timeout__c        = 120000;
            insert ifc2;
            
            InterfaceClasses__c ifClass2 = new InterfaceClasses__c();
            ifClass2.Name         = 'IF_ERP_Service_PartsDetail';
            ifClass2.Interface__c = ifc2.Id;
            insert ifClass2;

            Interface__c ifc3 = new Interface__c();
            ifc3.Name              = 'IF-PARTS-022';
            ifc3.ProcessingType__c = 'Real-Time';
            ifc3.Description__c    = '멀티 부품 조회(TEST)';
            ifc3.IsActive__c       = true;
            ifc3.HttpMethod__c     = 'POST';
            ifc3.EndpointURL__c    = 'http://temp';
            ifc3.System__c         = 'ERP';
            ifc3.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            ifc3.Timeout__c        = 120000;
            insert ifc3;
            
            InterfaceClasses__c ifClass3 = new InterfaceClasses__c();
            ifClass3.Name         = 'IF_ERP_Parts_Multipart';
            ifClass3.Interface__c = ifc3.Id;
            insert ifClass3;

            pr2 = new Product2();
            pr2.Name        = 'R18181';
            pr2.ProductCode = 'R18181';
            pr2.IsActive    = true;
            pr2.RecordTypeId  = productId;

            insert pr2;

            DealerStock__c ds001 = new DealerStock__c();
            ds001.Dealer__c = acc.Id;
            ds001.CurrentStockQuantity__c = 16;
            ds001.SalesOrganization__c = '1846';
            ds001.DistributionChannel__c = '10';
            ds001.Division__c = '40';
            ds001.Part__c = pr2.Id;

            insert ds001;
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

            // Interface__c ifc1 = new Interface__c();
            // ifc1.Name              = 'IF-SERVICE-037';
            // ifc1.ProcessingType__c = 'Real-Time';
            // ifc1.Description__c    = '부품 기본 정보 조회(TEST)';
            // ifc1.IsActive__c       = true;
            // ifc1.HttpMethod__c     = 'POST';
            // ifc1.EndpointURL__c    = 'http://temp';
            // ifc1.System__c         = 'ERP';
            // ifc1.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            // ifc1.Timeout__c        = 120000;
            // insert ifc1;
            
            // InterfaceClasses__c ifClass1 = new InterfaceClasses__c();
            // ifClass1.Name         = 'IF_ERP_Service_PartsDetail';
            // ifClass1.Interface__c = ifc1.Id;
            // insert ifClass1;
            
            // Interface__c ifc2 = new Interface__c();
            // ifc2.Name              = 'IF-SERVICE-038';
            // ifc2.ProcessingType__c = 'Real-Time';
            // ifc2.Description__c    = '부품 대체품 조회(TEST)';
            // ifc2.IsActive__c       = true;
            // ifc2.HttpMethod__c     = 'POST';
            // ifc2.EndpointURL__c    = 'http://temp';
            // ifc2.System__c         = 'ERP';
            // ifc2.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            // ifc2.Timeout__c        = 120000;
            // insert ifc2;
            
            // InterfaceClasses__c ifClass2 = new InterfaceClasses__c();
            // ifClass2.Name         = 'IF_ERP_Service_PartsDetail';
            // ifClass2.Interface__c = ifc2.Id;
            // insert ifClass2;

            // Interface__c ifc3 = new Interface__c();
            // ifc3.Name              = 'IF-PARTS-022';
            // ifc3.ProcessingType__c = 'Real-Time';
            // ifc3.Description__c    = '멀티 부품 조회(TEST)';
            // ifc3.IsActive__c       = true;
            // ifc3.HttpMethod__c     = 'POST';
            // ifc3.EndpointURL__c    = 'http://temp';
            // ifc3.System__c         = 'ERP';
            // ifc3.ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8';
            // ifc3.Timeout__c        = 120000;
            // insert ifc3;
            
            // InterfaceClasses__c ifClass3 = new InterfaceClasses__c();
            // ifClass3.Name         = 'IF_ERP_Parts_Multipart';
            // ifClass3.Interface__c = ifc3.Id;
            // insert ifClass3;

        }
    }

    @isTest
    static void testGetUserInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalPartsInfoController.GetUserInfo();
            }catch(Exception e){

            }
        }
        Test.stopTest();
    }

    @isTest
    static void SeachPart_Success() {
        String partNo = 'R18181';
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        Test.startTest();
        System.runAs(userId) {
            try{
                Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Service_037_Success());
                DN_PortalPartsInfoController.SeachPart(partNo, dealerInfo);    
            }catch(Exception e){

            }
        }
        
        Test.stopTest();
    }

    private class MockIF_ERP_Service_037_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"O_AVAIL_QTY":"0.000","O_MANUFACT":"","O_MATERIAL":"DY-II","O_MESG":"Successfully finished.[ZSS90101]","O_RESULT":{"MAKTX":"WIPER","SVC_FLAG":"Y","AVA_FLAG":"N","NOTCD":"","COND_VALUE":"26700.000000000","NETPR":"26700.00","CURRENCY":"KRW","NETPR_ETC":"23500.00","CURRENCY2":"KRW","KWMENG":"0.000","AUMNG":"0.000","LFMNG":"0.000","MEINS":"EA","BRGEW":"0.000","NTGEW":"0.084","GEWEI":"KG","GROES":"","PRODH":"NEW00NEW00NEW00000","PRODH_T":"New Released Parts","BULET":"","ZPRAT":"N","HERKL":"KR","PLIFZ":"25","M_MATNR":"","C_MTPOS":"N","DATAB":"2024-03-02","KONDM":"O","VTEXT":"O Pricing Type","NOTCD_TEXT":"","SVRCD":"S","SVRCD_TEXT":"Service","AVRLT":"11","REMARK2":""},"O_THREAD":"","ET_AVAIL":[],"ET_CROSS":[{"ITCCD":"I","LABST2":"0.000","LABST":"0.000","SVRCD_TEXT":"Not service","SEQ":" 1-1","NOTCD":"","MAKTX":"WIPER","DDTEXT":"","MXNET":"","SVRCD":"N","MATNR":"220210-00677"},{"ITCCD":"","LABST2":"0.000","LABST":"0.000","SVRCD_TEXT":"Service","SEQ":" 1-2","NOTCD":"","MAKTX":"WIPER","DDTEXT":"","MXNET":"","SVRCD":"S","MATNR":"220210-00677A"}],"O_AVAIL_QTY2":"0.000"}'
            );
            return res;
        }
    }

    @isTest
    static void SeachPart2_Success() {
        String partNo = 'R18181';
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        Test.startTest();
        System.runAs(userId) {
            try{
                Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Service_038_Success());
                DN_PortalPartsInfoController.SeachPart2(partNo, dealerInfo);    
            }catch(Exception e){

            }
        }
        
        Test.stopTest();
    }

    private class MockIF_ERP_Service_038_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_MESG":"Successfully finished.[ZSS90101]","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Successfully finished.[ZSS90101]","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":""},"T_LIST":[{"MAKTX":"라이브센터","MATNR":"R18181","AVA_FLAG":"N"},{"MAKTX":"라이브센터","MATNR":"R18182","AVA_FLAG":"N"}],"O_COUNT":"2"}'
            );
            return res;
        }
    }

    @isTest
    static void CheckProduct_Success() {
        List<String> partNo = new List<String>();
        partNo.add('100101-00065A');

        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalPartsInfoController.CheckProduct(partNo);
            }catch(Exception e) {
                system.debug(e);
            }   
        }
        Test.stopTest();
    }

    @isTest
    static void GetCurrentStock_Success() {
        String partNo = 'R18181';
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalPartsInfoController.GetCurrentStock(dealerInfo, partNo);
            }catch(Exception e){

            }
            
        }
        
        Test.stopTest();
    }


    @isTest
    static void MultiSearch_Success() {
        List<String> partNo = new List<String>();
        partNo.add('R18181');
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);

        Test.startTest();
        System.runAs(userId) {
            try{
                Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_022_Success());
                DN_PortalPartsInfoController.MultiSearch(partNo, dealerInfo);    
            }catch(Exception e) {

            }
        }
        
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_022_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_RETURN":{"TYPE":"S","CODE":"010","MESSAGE":"Successfully finished."},"D_DETAIL":[{"PLIFZ":"90","SVCLT":"76","SVC_FLAG":"Y","NETPR":"47600.00","KWMENG":"0.000","VTEXT":"O Pricing Type","THREAD":"A06B-6114-K504_S","DATAB":"2021-02-01","D_MATERIAL":"","MEINS":"EA","NTGEW":"0.060","SVRCD":"S","CURRENCY2":"KRW","GEWEI":"KG","MATNR":"301803-00224","AVAIL_QTY2":"0.000","NOTCD_TEXT":"","MAKTX":"BATTERY,CNC;BATTERY","NETPR_ETC":"36890.00","PRODH_T":"OTHERS","ZPRAT":"N","BULET":"","MANUFACT":"FANUC","PRODH":"SP3003016030160001","C_MTPOS":"N","GROES":"","AVAIL_QTY":"906.000","COND_VALUE":"47600.000000000","MIN_QTY":"0.000","NOTCD":"","M_MATNR":"","LFMNG":"0.000","CURRENCY":"KRW","AVA_FLAG":"Y","HERKL":"JP","SUB_MATERIAL":"","KONDM":"O","BRGEW":"0.067","REPLACE":"","AUMNG":"0.000"}],"T_RETURN":[]}'
            );
            return res;
        }
    }

}