/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 03-27-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-20-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PortalSalePriceRequestControllerTest {
    private static final Id dealerId    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id productId   = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    private static User dealerUser;

    @TestSetup
    static void makeData(){
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
            // 회사 세우기
            Account testAcc = new Account(
                Name               = 'TestAccount'
                ,Representative__c = 'TestCEO'
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
                ,SalesOrganization__c   = '1846'
            );
            insert testCon;

            Profile pf = [SELECT Id, Name FROM Profile WHERE Name = 'DNS CS Parts_Partner' LIMIT 1];
            
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
                ,SalesOrganization__c = '1846'
                ,Division__c          = '40'
                ,DistributionChannel__c = '10'
            );
            insert testUser;

            Product2 pr2 = new Product2(
                Name        = 'R18181',
                ProductCode = 'R18181',
                IsActive    = true,
                MaterialDetailsKO__c = 'CENTER,LIVE',
                MaterialDetailsEN__c = 'CENTER,LIVE',
                RecordTypeId = productId
            );
            insert pr2;

            // ContentVersion cv = new ContentVersion(
            //     Title = 'Test File',
            //     PathOnClient = 'TestFile.pdf',
            //     VersionData = Blob.valueOf('This is test file content.'),
            //     IsMajorVersion = true
            // );
            // insert cv;
    
            // ContentVersion cv2 = new ContentVersion(
            //     Title = 'html File2',
            //     PathOnClient = 'TestFile2.html',
            //     VersionData = Blob.valueOf('This is test file2 content.'),
            //     IsMajorVersion = true
            // );
            // insert cv2;     

            Interface__c ifc030 = new Interface__c(
                Name               = 'IF-PARTS-030'
                ,ProcessingType__c = 'Real-Time'
                ,Description__c    = '판매가 부품 가격 조회(test)'
                ,IsActive__c       = true
                ,HttpMethod__c     = 'POST'
                ,EndpointURL__c    = 'http://temp'
                ,System__c         = 'ERP'
                ,ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8'
                ,Timeout__c        = 120000
            );
            insert ifc030;

            InterfaceClasses__c ifClass030 = new InterfaceClasses__c(
                Name = 'IF_ERP_PE_Inquery'
                ,Interface__c = ifc030.Id
            );
            insert ifClass030;

            Interface__c ifc031 = new Interface__c(
                Name               = 'IF-PARTS-031'
                ,ProcessingType__c = 'Real-Time'
                ,Description__c    = '판매가 생성(test)'
                ,IsActive__c       = true
                ,HttpMethod__c     = 'POST'
                ,EndpointURL__c    = 'http://temp'
                ,System__c         = 'ERP'
                ,ContentType__c    = 'application/x-www-form-urlencoded; charset=UTF-8'
                ,Timeout__c        = 120000
            );
            insert ifc031;

            InterfaceClasses__c ifClass031 = new InterfaceClasses__c(
                Name = 'IF_ERP_PE_Inquery'
                ,Interface__c = ifc031.Id
            );
            insert ifClass031;
        }
    }

    @isTest
    static void Test_GetUserInfo_Success() {
        User userT = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userT.Id);

        String ptn = 'R18181';
        String ptn2 = '';
        List<DN_PortalSalePriceRequestController.PartsList> ptnList = new List<DN_PortalSalePriceRequestController.PartsList>();
        DN_PortalSalePriceRequestController.PartsList ptnR = new DN_PortalSalePriceRequestController.PartsList();
        ptnR.itemNo = '0010';
        ptnR.partNo = ptn;
        ptnList.add(ptnR);

        Test.startTest();
        System.runAs(userT) {
            DN_PortalSalePriceRequestController ctrl = new DN_PortalSalePriceRequestController();
            DN_PortalSalePriceRequestController.GetUserInfo();
            DN_PortalSalePriceRequestController.SearchPartCode(ptn);
            DN_PortalSalePriceRequestController.SearchPartCode(ptn2);
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_030_Success());
            DN_PortalSalePriceRequestController.GetPriceInfo(dli, ptnList);
            
        }
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_030_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"ET_SIMUL":[{"SPRICE":"205,300","MAKTX":"CENTER,LIVE","MATNR":"R18181","PEITEM":"0010","WAERS":"KRW"}],"ET_SAP":[{"SPRICE":"2053.00","MAKTX":"CENTER,LIVE","MATNR":"R18181","PEITEM":"0010","WAERS":"KRW"}],"ES_RETURN":{"TYPE":"S","CODE":"","MESSAGE":""}}'
            );
            return res;
        }
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
        List<Id> vId = new List<Id>{cdId[0].Id};
        List<Id> uId = new List<Id>{cvId[0].Id};

        system.debug('test code fId >> '+fId);
        system.debug('test code uId >> '+uId);

        Test.startTest();
        DN_PortalSalePriceRequestController.CheckFileSize(fId);
        DN_PortalSalePriceRequestController.ConvertFile(vId);
        DN_PortalSalePriceRequestController.SplitFile(uId);
        DN_PortalSalePriceRequestController.DeleteFile(fId);
        Test.stopTest();
    }

    @isTest
    static void Test_CreatePriceRequest_Fail() {
        User userT = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userT.Id);
        DN_PortalSalePriceRequestController.Params params = new DN_PortalSalePriceRequestController.Params();

        List<String> poeFile = new List<String>();
        List<DN_PortalSalePriceRequestController.Upload> upload = new List<DN_PortalSalePriceRequestController.Upload>();

        Test.startTest();
        System.runAs(userT) {
            try{
                DN_PortalSalePriceRequestController.CreatePriceRequest(dli, params, poeFile, upload);             
            }catch(Exception e) {
                system.debug(e);
            }
        }
        Test.stopTest();
    }

    @isTest
    static void Test_CreatePriceRequest_Fail2() {
        User userT = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userT.Id);
        DN_PortalSalePriceRequestController.Params params = new DN_PortalSalePriceRequestController.Params();
        List<DN_PortalSalePriceRequestController.partsList> prsList = new List<DN_PortalSalePriceRequestController.partsList>();
        DN_PortalSalePriceRequestController.partsList prs = new DN_PortalSalePriceRequestController.partsList();
        prsList.add(prs);
        params.partsList = prsList;

        List<String> poeFile = new List<String>();
        List<DN_PortalSalePriceRequestController.Upload> upload = new List<DN_PortalSalePriceRequestController.Upload>();

        Test.startTest();
        System.runAs(userT) {
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_031_Fail2());
            DN_PortalSalePriceRequestController.CreatePriceRequest(dli, params, poeFile, upload);
        }
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_031_Fail2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"E_PENUM":"4000000245"}'
            );
            return res;
        }
    }    

    @isTest
    static void Test_CreatePriceRequest_Success() {
        User userT = [SELECT Id FROM User WHERE Username = 'DealerUser@TestAccount.com' LIMIT 1];
        DN_PortalLoginUser.DealerInfo dli = DN_PortalLoginUser.GetUserInfo(userT.Id);
        DN_PortalSalePriceRequestController.Params params = new DN_PortalSalePriceRequestController.Params();
        params.equipmentName = '기종';
        params.equipmentNo   = '장비번호';
        params.inquiryPONo   = 'IpoNumber';
        params.requester     = '요청자';
        params.requesterEmail = '이메일';
        params.today          = '20250326';

        List<DN_PortalSalePriceRequestController.partsList> prsList = new List<DN_PortalSalePriceRequestController.partsList>();
        DN_PortalSalePriceRequestController.partsList prs = new DN_PortalSalePriceRequestController.partsList();
        prs.curr    = 'KRW';
        prs.itemNo  = '0010';
        prs.partName = 'CENTER,LIVE';
        prs.partNo   = 'R18181';
        prs.request  = '요청 사항';
        prs.sugestPrice = '70000';
        prs.systemPrice = '205300';
        prsList.add(prs);

        params.partsList = prsList;

        List<String> poeFile = new List<String>();
        List<DN_PortalSalePriceRequestController.Upload> upload = new List<DN_PortalSalePriceRequestController.Upload>();

        Test.startTest();
        System.runAs(userT) {
            Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Parts_031_Success());
            DN_PortalSalePriceRequestController.CreatePriceRequest(dli, params, poeFile, upload);
        }
        Test.stopTest();
    }

    private class MockIF_ERP_Parts_031_Success implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"E_PENUM":"5000000245"}'
            );
            return res;
        }
    }    
}