/**
 * @description       : (포탈) 영업 > 서비스 관리 > 납품후교육 생성 및 조회 테스트 코드
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 04-23-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-25-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PortalSalesRequestEduControllerTest {
    private static final Id dealerId    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id dealerConId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id productId   = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    private static final Id orderId     = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DNS').getRecordTypeId();
    private static final Id pBookId     = Test.getStandardPricebookId();
    private static final Date today     = Date.today();
    private static User dealerUser;
    static String partnerUserName ='partACOCC@test.test.com';

    @TestSetup
    static void makeData(){
        UserRole dealerRole = new UserRole(Name = 'saleDealerRole');
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
                RecordTypeId     = dealerId,
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
                RecordTypeId = dealerConId,
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

            Asset equipment = new Asset(
                Name            = 'test'
                ,SerialNumber   = 'MH0014-000391'
                ,MachineName__c = 'HM1250'
                ,NCType__c      = 'FANUC 31I-B PLUS'
                ,AccountId      = acc.Id
                // ,Order__c       = ord.Id
            );
            insert equipment;

            Profile p = [SELECT Id FROM Profile WHERE Name = 'DNS CS Service' LIMIT 1];
            User eduUser = new User(
                Username = 'eduUser@test.com',
                Alias    = 'edu',
                Email    = 'eduUser@test.com',
                LastName = 'Tester',
                TimeZoneSidKey = 'Asia/Seoul',
                LocaleSidKey   = 'ko_KR',
                EmailEncodingKey  = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id
            );
            insert eduUser;
    
            Group eduGroup = new Group(
                Name = '교육 담당자',
                DeveloperName = 'eduRep2',
                Type = 'Regular'
            );
            insert eduGroup;
    
            GroupMember member = new GroupMember(
                GroupId = eduGroup.Id,
                UserOrGroupId = eduUser.Id
            );
            insert member;
        }

        User partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
        partnerTestUser.SalesOrganization__c = '1846';
        partnerTestUser.DistributionChannel__c = '10';
        partnerTestUser.Division__c = '40';
        partnerTestUser.Username = partnerUserName;
        insert partnerTestUser;
    }

    @isTest
    static void Test_GetUserInfo_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalSalesRequestEduController psc = new DN_PortalSalesRequestEduController();
                DN_PortalSalesRequestEduController.GetUserInfo();    
            }catch(Exception e) {

            }
        
        }
        Test.stopTest();
    }

    @isTest
    static void Test_GetEduRep_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        String eduRep = 'eduRep2';
        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalSalesRequestEduController.GetEduRep(eduRep);
            }catch(Exception e) {

            }
            
        }
        Test.stopTest();
    }

    @isTest
    static void Test_GetAssetInfo_Success() {
        User userId = [SELECT Id, Profile.Name FROM User WHERE Username =: partnerUserName LIMIT 1];
        
        String type   = 'asset';
        // String userProfile = userId.Profile.Name;
        // String uId = userId.Id;
        String erpPSONo = 'test';
        DN_PortalLoginUser.DealerInfo dealerInfo = new DN_PortalLoginUser.DealerInfo();

        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalSalesRequestEduController.GetAssetInfo(type, dealerInfo, erpPSONo);
                type = 'erp';
                DN_PortalSalesRequestEduController.GetAssetInfo(type, dealerInfo, erpPSONo);    
            }catch(Exception e){

            }
        }
        Test.stopTest();
    }

    @isTest
    static void Test_GetAccContact_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        Account accS = [SELECT Id FROM Account WHERE Name = 'TestDealerAccount' LIMIT 1];

        Test.startTest();
        System.runAs(userId) {
            try {
                String accId = accS.Id;
                DN_PortalSalesRequestEduController.GetAccContact(accId);    
            } catch(Exception e) {
                system.debug(e);
            }
        }
        Test.stopTest();
    }


    @isTest
    static void Test_insertContact_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        Account accS = [SELECT Id FROM Account WHERE Name = 'TestDealerAccount' LIMIT 1];

        Map<String, Object> si = new Map<String, Object>{
            'shipToName'=> 'ERP에 코드가 있는 고객3',
            'shipToId'=> '001F700001lKmlqIAC',
            'salesAgents'=> '에이앤티머신 주식회사',
            'dealerName'=> '장대표(에이앤티머신)',
            'dealerPhone'=> '010-7777-3333',
            'shipToRepId'=> '003JO000008wK8ZYAU',
            'shipToRepName'=> '수기 2',
            'shipToRepMP'=> '55555',
            'shipToRepTitle'=> '직책',
            'shipToAddress'=> '서울특별시, 서울특별시, Korea, Republic of'
        };


        Test.startTest();
        System.runAs(userId) {
            try {
                String accId = accS.Id;
                DN_PortalSalesRequestEduController.insertContact(si);
            } catch(Exception e) {
                system.debug(e);
            }
        }
        Test.stopTest();
    }



    @isTest
    static void Test_insertTicket_Success() {
        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        Map<String, Object> oi = new Map<String, Object>{
            'Id' => '801F7000001RjDPIA0',
            'erpNo'=> '201931545'
        };
        
        Map<String, Object> ai = new Map<String, Object>{
            'machine'       => 'HM1250',
            'equipment'     => 'MH0014-000391',
            'equipmentId'   => '02iF700000mELi5IAG',
            'finishInstall' => '2024-05-07',
            'warranty'      => 'Y / Y',
            'ncType'        => ''
        };
        
        Map<String, Object> di = new Map<String, Object>{
            'accountAddress'     => '경기도 화성시 남여울2길 24 (능동), 경기도, 18428, Korea, Republic of',
            'accountCEO'         => '서희준',
            'accountId'          => '001F700001kTSyxIAG',
            'accountName'        => '에이앤티머신 주식회사',
            'accountPhone'       => '031-613-0501',
            'contactId'          => '003F700001Z57DKIAZ',
            'country'            => 'KR',
            'dealerCode'         => '1124140',
            'dealerId'           => '005F7000006Wdq9IAC',
            'dealerName'         => '장대표(에이앤티머신)',
            'distributionChannel'=> '10',
            'division'           => '40',
            'erpKey'             => '127',
            'language'           => 'ko',
            'salesOrganization'  => '1800',
            'ShippingAddress'    => new Map<String, Object>{
                'street'     => '경기도 화성시 남여울2길 24 (능동)',
                'city'       => '경기도',
                'postalCode' => '18428',
                'country'    => 'Korea, Republic of'
            },
            'userMobilePhone'    => '010-7777-3333',
            'userProfile'        => '영업 국내 대리점'
        };
        

        Map<String, Object> si = new Map<String, Object>{
            'shipToName'=> 'ERP에 코드가 있는 고객3',
            'shipToId'=> '001F700001lKmlqIAC',
            'salesAgents'=> '에이앤티머신 주식회사',
            'dealerName'=> '장대표(에이앤티머신)',
            'dealerPhone'=> '010-7777-3333',
            'shipToRepId'=> '003JO000008wK8ZYAU',
            'shipToRepName'=> '수기 2',
            'shipToRepMP'=> '55555',
            'shipToRepTitle'=> '직책',
            'shipToAddress'=> '서울특별시, 서울특별시, Korea, Republic of'
        };


        
        Map<String, Object> ei = new Map<String, Object>{
            'eduLevel'   => '신규 교육',
            'eduCnt'     => '3회',
            'stuLevel'   => '상',
            'eduRep'     => '005F7000006Wr57IAC',
            'eduDateOne' => '2025-03-26T00:00',
            'eduDateTwo' => '2025-03-27T00:00',
            'eduDateThr' => '2025-03-28T00:00',
            'note'       => '접수내용'
        };

        String fi = '[]';
        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalSalesRequestEduController.insertTicket(oi, ai,  di, si, ei, fi);
            } catch(Exception e) {
                system.debug(e);
            }
        }
        Test.stopTest();
    }

    @isTest
    static void Test_GetTicketInfo_Success() {
        Date today = Date.today();
        Date twoDay = today.addDays(2);       

        User userId = [SELECT Id FROM User WHERE Username =: partnerUserName LIMIT 1];
        // DN_PortalLoginUser.DealerInfo dealerInfo = DN_PortalLoginUser.GetUserInfo(userId.Id);
        DN_PortalLoginUser.DealerInfo dealerInfo = new DN_PortalLoginUser.DealerInfo();
        String dealerId = userId.Id;
        String deaperPF = '';
        String erpPSONo = '00074960';
        String accId = '';
        String caseNo = '00074960';
        String machineName = 'MH0014-000391';
        String assetName = 'HM1250';
        Date startDate = today;
        Date endDate = twoDay;
        Test.startTest();
        System.runAs(userId) {
            try{
                DN_PortalSalesRequestEduController.GetTicketInfo(dealerInfo, erpPSONo, accId, caseNo, machineName, assetName, startDate, endDate);
            }catch(Exception e) {

            }
            
        }
        Test.stopTest();
    }    
}