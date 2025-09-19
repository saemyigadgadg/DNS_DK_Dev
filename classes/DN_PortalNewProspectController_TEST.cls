/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 2025-04-15
 * @last modified by  : chungwoo.lee@sobetec.com
**/
@isTest
private class DN_PortalNewProspectController_TEST {
    
    private static final Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
    private static final Id dealerRT        = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

    @testSetup
    static void setup() {
        // Country 생성
        Country__c krCountry = TestDataFactoryForSales.createKRCountry();
        Country__c usCountry = TestDataFactoryForSales.createCountry('USA', 'USD', 'US');
        insert new List<Country__c>{krCountry, usCountry};
        
        // Region 생성
        Region__c krRegion = TestDataFactoryForSales.createRegion('제주도', 'KRW', '01', krCountry.Id);
        Region__c usRegion = TestDataFactoryForSales.createRegion('California', 'USD', 'CA', usCountry.Id);
        insert new List<Region__c>{krRegion, usRegion};
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet;

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', '시스템 관리자') LIMIT 1];
        User adminUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            UserRole adminUserRole = new UserRole(Name = 'Admin Role');
            insert adminUserRole;
            adminUser = new User(
                FirstName         = 'Admin',
                LastName          = 'portalTest',
                Email             = 'portalTest3@portalTest3.com',
                Username          = 'portalTest3@portalTest3.com',
                Alias             = 'poTest',
                TimeZoneSidKey    = 'Asia/Seoul',
                LocaleSidKey      = 'ko',
                EmailEncodingKey  = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId         = adminProfile.Id,
                UserRoleId        = adminUserRole.Id
            );
            insert adminUser;
        }

        Account dealerAccount = new Account(
            Name                = 'Test Account dw3',
            CountryLookup__c    = krCountry.Id,
            RegionLookup__c     = krRegion.Id,
            RecordTypeId        = dealerRT,  
            BusinessNumber__c   = '123-45-67893',
            Representative__c   = 'Rep12',
            SalesOrganization__c= '1800',
            SalesDistrict__c    = 'A1KR',
            SalesOffice__c      = '114E',
            Division__c         = '40',
            DistributionChannel__c = '10',
            OwnerId             = adminUser.Id,
            CustomerCode__c    = '123456'
        );
        insert dealerAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName  = 'User',
            Email     = 'testuser@portaltest.com',
            AccountId = dealerAccount.Id
        );
        insert testContact;

        User testDomesticUser = new User(
            Username = 'testuser@example.com.test.PortalNewProspect',
            LastName = 'Test',
            Email = 'testuser@example.com.PortalNewProspect',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='영업 국내 대리점' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            ContactId         = testContact.Id,
            DistributionChannel__c = '10',
            Division__c            = '40',
            SalesOffice__c         = '114E',
            SalesDistrict__c       = 'A1KR',
            SalesOrganization__c   = '1800',
            CustomerCode__c        = '234567'
        );
        insert testDomesticUser;

        Account globalAccount = new Account(
            Name                = 'Test Account global',
            CountryLookup__c    = krCountry.Id,
            RegionLookup__c     = krRegion.Id,
            RecordTypeId        = dealerRT,  
            BusinessNumber__c   = '123-45-67890',
            Representative__c   = 'Rep12',
            SalesOrganization__c= '1800',
            SalesDistrict__c    = 'A1AE',
            SalesOffice__c      = '1140',
            Division__c         = '40',
            DistributionChannel__c = '10',
            OwnerId             = adminUser.Id,
            CustomerCode__c    = '345678'
        );
        insert globalAccount;

        Contact globalContact = new Contact(
            FirstName = 'global',
            LastName  = 'User',
            Email     = 'globaluser@portaltest.com',
            AccountId = globalAccount.Id
        );
        insert globalContact;

        User testGlobalUser = new User(
            Username = 'globaluser@example.com.test',
            LastName = 'global',
            Email = 'globaluser@example.com',
            Alias = 'guser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='영업 글로벌 대리점' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            ContactId         = globalContact.Id,
            DistributionChannel__c = '10',
            Division__c            = '40',
            SalesOffice__c         = '1140',
            SalesDistrict__c       = 'A1AE',
            SalesOrganization__c   = '1800'
        );
        insert testGlobalUser;
        
        testDomesticUser = [SELECT Id FROM User WHERE Id = :testDomesticUser.Id];
        
        System.runAs(testDomesticUser) {
            Account parentAcc = TestDataFactoryForSales.createParentAccount(krCountry);
            insert parentAcc;
            
            Account tradeAcc = TestDataFactoryForSales.createAccount('TradeCustomer', krCountry, parentAcc);
            tradeAcc.CustomerCode__c    = '123456';
            tradeAcc.BusinessNumber__c  = '5148171773';
            tradeAcc.Representative__c  = 'realAcc';
            insert tradeAcc;
        }
    }

    @IsTest
    static void testProspectInfoWrapperInstantiation() {
        DN_PortalNewProspectController.ProspectInfoWrapper wrapper1 = new DN_PortalNewProspectController.ProspectInfoWrapper();
        wrapper1.accountId = '001xx000003DHPJAA4';
        wrapper1.accountName = 'Test Account';
        wrapper1.representative = 'Test Representative';
        wrapper1.accountCreatedDate = Date.newInstance(2025, 1, 1);
        wrapper1.isBVC = 'false';
        wrapper1.isRequest = 'true';
        wrapper1.requestReason = 'Test Reason';
        wrapper1.simpleCustomerId = 'Cust-12345';

        String json1 = JSON.serialize(wrapper1);
        System.debug('Wrapper1 JSON: ' + json1);
        System.assert(json1.contains('Test Account'), 'Wrapper1 should contain the account name.');

        DN_PortalNewProspectController.ProspectInfoWrapper wrapper2 = new DN_PortalNewProspectController.ProspectInfoWrapper(
            '001xx000003DHPKAA4',
            'Parameterized Account',
            'Param Representative',
            Date.newInstance(2025, 2, 2),
            'true',
            'false',
            'Parameterized Reason',
            'Cust-54321'
        );
        
        String json2 = JSON.serialize(wrapper2);
        System.debug('Wrapper2 JSON: ' + json2);
    }

    @isTest
    static void testGetLoginUserInfo() {
        Test.startTest();
        DN_PortalNewProspectController.getLoginUserInfo();
        Test.stopTest();
    }

    @isTest
    static void testSearchProspectAccount() {
        Test.startTest();
        DN_PortalNewProspectController.searchProspectAccount('test company', 'testuser', '');
        Test.stopTest();
    }

    @isTest
    static void testRequestToUse() {
        DN_PortalNewProspectController.ProspectInfoWrapper wrapper = new DN_PortalNewProspectController.ProspectInfoWrapper();
        Account testAcc = [SELECT Id, Name FROM Account WHERE Name = 'test company' LIMIT 1];
        wrapper.accountId = testAcc.Id;
        wrapper.accountName = testAcc.Name;
        wrapper.requestReason = 'Testing';

        Test.startTest();
        DN_PortalNewProspectController.requestToUse(wrapper);
        Test.stopTest();
    }

    @isTest
    static void testRequestToUse_FailCase() {
        DN_PortalNewProspectController.ProspectInfoWrapper wrapper = new DN_PortalNewProspectController.ProspectInfoWrapper();
        Account testAcc = [SELECT Id, Name FROM Account WHERE Name = 'test company' LIMIT 1];
        wrapper.accountId = testAcc.Id;
        wrapper.accountName = testAcc.Name;
        wrapper.requestReason = '';

        Test.startTest();
        DN_PortalNewProspectController.requestToUse(wrapper);
        Test.stopTest();
    }

    @isTest
    static void testRequestToUse_FailCase_isAlreadyRequest() {
        DN_PortalNewProspectController.ProspectInfoWrapper wrapper = new DN_PortalNewProspectController.ProspectInfoWrapper();

        User testUser = [SELECT Id, Username FROM User WHERE Username ='testuser@example.com.test.PortalNewProspect'];

        Account testAcc = [SELECT Id, Name FROM Account WHERE Name = 'test company' LIMIT 1];
        wrapper.accountId = testAcc.Id;
        wrapper.accountName = testAcc.Name;
        wrapper.requestReason = 'Testing';

        System.runAs(testUser) {
            DNS_RequestToUseCustomer__c rtuCustomer = new DNS_RequestToUseCustomer__c(ApprovalStage__c = 'Request To Use', TargetAccount__c = testAcc.Id, RequestReason__c = 'TEST');
            insert rtuCustomer;

            Test.startTest();
            DN_PortalNewProspectController.requestToUse(wrapper);
            Test.stopTest();
        }
    }

    @isTest
    static void testSaveProspectAccount() {
        // IF 테스트 레코드 생성 및 IF Mock 설정
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-001', 'IF_ERP_Account');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Account_Test.IF_ACCOUNT_001_HttpMock());

        User testUser = [SELECT Id, Username FROM User WHERE Username ='testuser@example.com.test.PortalNewProspect'];

        Country__c country = [SELECT Id FROM Country__c WHERE CountryCode__c = 'KR' LIMIT 1];
        Region__c region = [SELECT Id FROM Region__c WHERE Country__c = :country.Id LIMIT 1];

        Map<String, Object> fieldMap = new Map<String, Object>{
            'Name' => 'New Prospect Co.',
            'Representative__c' => 'CEO Kim',
            'BusinessNumber__c' => '123-45-6789',
            'CountryLookup__c' => country.Id,
            'RegionLookup__c' => region.Id,
            'Phone' => '01012345678',
            'SalesTarget__c' => '123',
            'LastYearSalesAmount__c' => '123.45',
            'IF_Update__c' => 'false',
            'CustomerSystemStartDate__c' => '2025-03-25',
            'ShippingAddress' => new Map<Object, Object>{
                'ShippingStreet' => '456 Secondary St',
                'ShippingCity' => 'Busan',
                'ShippingState' => 'BS',
                'ShippingPostalCode' => '67890',
                'ShippingCountry' => 'KR'
            }
        };

        System.runAs(testUser) {
            Test.startTest();
            DN_PortalNewProspectController.saveProspectAccount('Account', fieldMap);
            Test.stopTest();
        }
    }

    @isTest
    static void testSaveProspectAccount_FailCase() {
        // IF 테스트 레코드 생성 및 IF Mock 설정
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-001', 'IF_ERP_Account', 'Fail');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Account_Test.IF_ACCOUNT_001_Fail_HttpMock());

        User testUser = [SELECT Id, Username FROM User WHERE Username ='testuser@example.com.test.PortalNewProspect'];

        Country__c country = [SELECT Id FROM Country__c WHERE CountryCode__c = 'KR' LIMIT 1];
        Region__c region = [SELECT Id FROM Region__c WHERE Country__c = :country.Id LIMIT 1];

        Map<String, Object> fieldMap = new Map<String, Object>{
            'Name' => 'New Prospect Co.',
            'Representative__c' => 'CEO Kim',
            'BusinessNumber__c' => '123-45-6789',
            'CountryLookup__c' => country.Id,
            'RegionLookup__c' => region.Id,
            'Phone' => '01012345678',
            'SalesTarget__c' => '123',
            'LastYearSalesAmount__c' => '123.45',
            'IF_Update__c' => 'false',
            'CustomerSystemStartDate__c' => '2025-03-25',
            'ShippingAddress' => new Map<Object, Object>{
                'ShippingStreet' => '456 Secondary St',
                'ShippingCity' => 'Busan',
                'ShippingState' => 'BS',
                'ShippingPostalCode' => '67890',
                'ShippingCountry' => 'KR'
            }
        };

        System.runAs(testUser) {
            Test.startTest();
            DN_PortalNewProspectController.saveProspectAccount('Account', fieldMap);
            Test.stopTest();
        }
    }

    @isTest
    static void testSaveProspectAccount_DNSA() {
        // IF 테스트 레코드 생성 및 IF Mock 설정
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-001', 'IF_ERP_Account');
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Account_Test.IF_ACCOUNT_001_HttpMock());

        Country__c country = [SELECT Id FROM Country__c WHERE CountryCode__c = 'US' LIMIT 1];
        Region__c region = [SELECT Id FROM Region__c WHERE Name = 'California' LIMIT 1];

        User testUser = [SELECT Id, Username FROM User WHERE Username ='globaluser@example.com.test'];

        Map<String, Object> fieldMap = new Map<String, Object>{
            'Name' => 'New Prospect Co.',
            'Representative__c' => 'CEO Kim',
            'BusinessNumber__c' => '123-45-6789',
            'CountryLookup__c' => country.Id,
            'RegionLookup__c' => region.Id,
            'Phone' => '01012345678',
            'SalesTarget__c' => '123',
            'LastYearSalesAmount__c' => '123.45',
            'IF_Update__c' => 'false',
            'CustomerSystemStartDate__c' => '2025-03-25',
            'ShippingStreet' => 'Test ShippingStreet'
        };

        System.runAs(testUser) {
            Test.startTest();
            DN_PortalNewProspectController.saveProspectAccount('Account', fieldMap);
            Test.stopTest();
        }
    }

    @isTest
    static void testGetDNSAInit() {
        Test.startTest();
        DN_PortalNewProspectController.getDNSAInit();
        Test.stopTest();
    }

    @isTest
    static void testInsertDnsaAccount() {
        // IF 테스트 레코드 생성
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-015', 'IF_ERP_Account');
        // IF Mock 데이터 셋팅
        Test.setMock(HttpCalloutMock.class, new IF_ERP_Account_Test.IF_ACCOUNT_015_HttpMock());
        
        Country__c country = [SELECT Id FROM Country__c WHERE CountryCode__c = 'US' LIMIT 1];
        Region__c region = [SELECT Id FROM Region__c WHERE Name = 'California' LIMIT 1];

        Id recordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();

        User testUser = [SELECT Id, Username FROM User WHERE Username ='globaluser@example.com.test'];

        Map<String, Object> fieldMap = new Map<String, Object>{
            'Name' => 'DNSA Prospect Co.',
            'Representative__c' => 'Mr. DNS',
            'BusinessNumber__c' => '456-78-9123',
            'CountryLookup__c' => country.Id,
            'RegionLookup__c' => region.Id,
            'ShippingStreet' => '456 Side Rd',
            'ShippingCity' => 'Busan',
            'ShippingPostalCode' => '54321',
            'Phone' => '01098765432',
            'SalesTarget__c' => '123',
            'LastYearSalesAmount__c' => '123.45',
            'IF_Update__c' => 'false',
            'CareOfRigger__c' => 'false',
            'BVCStartDate__c' => '2025-03-25',
            'ShippingAddress' => new Map<Object, Object>{
                'ShippingStreet' => '456 Secondary St',
                'ShippingCity' => 'Busan',
                'ShippingState' => 'BS',
                'ShippingPostalCode' => '67890',
                'ShippingCountry' => 'KR'
            }
        };

        System.runAs(testUser) {
            Test.startTest();
            DN_PortalNewProspectController.insertDnsaAccount('Account', fieldMap, recordTypeId);
            Test.stopTest();
        }
    }
}