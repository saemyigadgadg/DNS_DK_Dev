/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-06-02
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-20-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class AccountTriggerHandler_TEST {
    private static final Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
    private static final Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
    private static final Id dealerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final Id shipToPartyRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipToParty').getRecordTypeId();
    private static final Id DNSACustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();

    @TestSetup
    static void setUp() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        AlertManager__c am = TestDataFactoryForSales.createAlertManager('New Key Account Alert');
        AlertManager__c am1 = TestDataFactoryForSales.createAlertManager('Customer System Date Alert');
        AlertManager__c am2 = TestDataFactoryForSales.createAlertManager('Convert Trade Customer Success Alert');
        insert am;
        insert am1;
        insert am2;
        
        // Country 생성
        Country__c krCountry = TestDataFactoryForSales.createKRCountry();
        krCountry.Country_Picklist__c  = 'KR';
        Country__c usCountry = TestDataFactoryForSales.createCountry('USA', 'USD', 'US');
        insert new List<Country__c>{krCountry, usCountry};

        // Region 생성
        Region__c krRegion = TestDataFactoryForSales.createRegion('제주도', 'KRW', '01', krCountry.Id);
        Region__c usRegion = TestDataFactoryForSales.createRegion('California', 'USD', 'CA', usCountry.Id);
        insert new List<Region__c>{krRegion, usRegion};

        Date nowDate = System.today().addDays(30);
        User dealer;
        Account dealerAcc;

        List<Account> accounts = new List<Account>{
            new Account(
                Name='Test Account 1', ResidentRegistrationNumber__c = '990811',  CountryLookup__c = krCountry.Id, RegionLookup__c = krRegion.Id, RecordTypeId=prospectCustomerRT, BusinessNumber__c='123-45-67890', Representative__c='Rep1',
                SalesOrganization__c = '1800', SalesDistrict__c = 'A1KR', SalesOffice__c = '114E', Division__c = '40', DistributionChannel__c = '10', Competitor__c = 'None;현대위아', CustomerSystem__c = 'MVC', IsBVC__c = 'N', CustomerSystemEndDate__c = System.today()
            ),
            new Account(
                Name='Test Account 2', Is_Migration__c = false, ResidentRegistrationNumber__c = '990811', CountryLookup__c = krCountry.Id, RegionLookup__c = krRegion.Id, RecordTypeId=tradeCustomerRT, BusinessNumber__c='987-65-43210', Representative__c='Rep2'
            ),
            new Account(
                Name='Test Account 3', IsKeyAccount__c = true, CountryLookup__c = krCountry.Id, RegionLookup__c = krRegion.Id, RecordTypeId=prospectCustomerRT, BusinessNumber__c='123-45-67890', Representative__c='Rep1',
                SalesOrganization__c = '1800', SalesDistrict__c =  'A1KR', SalesOffice__c = '114E', Division__c = '40', DistributionChannel__c = '10'
            ),
            new Account(
                Name='Test Account dw3', CountryLookup__c = krCountry.Id, RegionLookup__c = krRegion.Id, RecordTypeId=dealerRT, BusinessNumber__c='123-45-67893', Representative__c='Rep12',
                SalesOrganization__c = '1800', SalesDistrict__c = 'A1KR', SalesOffice__c = '114E', Division__c = '40', DistributionChannel__c = '10'
            ),

            new Account(
                Name='Test Account as', IsVirtualParent__c = true, ResidentRegistrationNumber__c = '990811',  CountryLookup__c = krCountry.Id, RegionLookup__c = krRegion.Id, RecordTypeId=prospectCustomerRT, BusinessNumber__c='123-45-67890', Representative__c='Rep1',
                SalesOrganization__c = '1800', SalesDistrict__c = 'A1KR', SalesOffice__c = '114E', Division__c = '40', DistributionChannel__c = '10'
            ),
            new Account(
                Name='Test Account adrgs', IsVirtualParent__c = true, ResidentRegistrationNumber__c = '990811',  CountryLookup__c = krCountry.Id, RegionLookup__c = krRegion.Id, RecordTypeId=DNSACustomerRT, BusinessNumber__c='123-45-67890', Representative__c='Rep1',
                SalesOrganization__c = '1800', SalesDistrict__c = 'A1KR', SalesOffice__c = '114E', Division__c = '40', DistributionChannel__c = '10'
            ),
            new Account(
                Name='Test Accountafe 1', ResidentRegistrationNumber__c = '990811',  CountryLookup__c = krCountry.Id, RegionLookup__c = krRegion.Id, RecordTypeId=shipToPartyRT, BusinessNumber__c='123-45-412890', Representative__c='Rep1',
                SalesOrganization__c = '1800', SalesDistrict__c = 'A1KR', SalesOffice__c = '114E', Division__c = '40', DistributionChannel__c = '10', Competitor__c = 'None;현대위아', CustomerSystem__c = 'MVC', IsBVC__c = 'N', CustomerSystemEndDate__c = nowDate
            )
        };
        insert accounts;
    }

    @isTest
    static void triggerUpdateTest() {
        Set<String> bypassSet = new Set<String>{'ContactTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet;

        Country__c krCountry = TestDataFactoryForSales.createKRCountry();
        krCountry.Country_Picklist__c  = 'KR';
        Country__c usCountry = TestDataFactoryForSales.createCountry('USA', 'USD', 'US');
        insert new List<Country__c>{krCountry, usCountry};

        Region__c krRegion = TestDataFactoryForSales.createRegion('제주도', 'KRW', '01', krCountry.Id);
        Region__c usRegion = TestDataFactoryForSales.createRegion('California', 'USD', 'CA', usCountry.Id);
        insert new List<Region__c>{krRegion, usRegion};

        Account pacc = TestDataFactoryForSales.createParentAccount(krCountry);
        insert pacc;

        Account acc = [SELECT Id, Name, BusinessNumber__c, IsBVC__c, CustomerSystem__c, FM_notificationCheck__c, ParentId FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        acc.BusinessNumber__c = '835-07-03270';
        acc.IsBVC__c = 'Y';
        acc.CustomerSystemEndDate__c =  Date.today().addDays(30);
        acc.ParentId = pacc.Id;

        Account acc2 = [SELECT Id, RecordTypeId, ResidentRegistrationNumber__c FROM Account WHERE Name = 'Test Account 3' LIMIT 1];
        acc2.RecordTypeId = tradeCustomerRT;
        acc2.ResidentRegistrationNumber__c = '951212';
        acc2.Competitor__c = 'None;현대위아';

        Account acc3 = [SELECT Id, Inactive__c FROM Account WHERE Name = 'Test Account dw3' LIMIT 1];
        acc3.Inactive__c = true;
        
        Test.startTest();
        update acc;
        update acc2;
        update acc3;

        Test.stopTest();
    }

    @isTest
    static void dealerInsertAccount() {
        // 1. Country 및 Region 데이터 생성
        Country__c krCountry = TestDataFactoryForSales.createKRCountry();
        krCountry.Country_Picklist__c = 'KR';
        insert krCountry;

        Region__c krRegion = TestDataFactoryForSales.createRegion('제주도', 'KRW', '01', krCountry.Id);
        insert krRegion;

        // 2. Account 생성 (Dealer용)
        Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', krCountry, null);
        dealerAcc.SalesDistrict__c = 'M3UL';
        insert dealerAcc;

        // 3. Contact 생성
        Contact dealerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
        insert dealerCon;

        // 4. 포털 유저 생성
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '영업 국내 대리점' LIMIT 1]; // 포털 프로필 확인
        User dealer = new User(
            Alias = 'dealer',
            Email = 'dealer@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Dealer',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = portalProfile.Id, // 포털 유저 프로필
            ContactId = dealerCon.Id, // 필수: Contact와 연결
            TimeZoneSidKey = 'Asia/Seoul',
            Username = 'dealer@test.com' + System.currentTimeMillis(),
            SalesOrganization__c = '1800',
            DistributionChannel__c = '10',
            Division__c = '40',
            IsActive = true
        );
        insert dealer;

        // 5. SalesAreaData__c 데이터 생성 (트리거 커버리지 보장)
        SalesAreaData__c salesArea = new SalesAreaData__c(
            Account__c = dealerAcc.Id,
            SalesOrganization__c = '1800',
            DistributionChannel__c = '10',
            Division__c = '40'
            // 기타 필수 필드 추가
        );
        insert salesArea;

        // 6. System.runAs로 포털 유저로 실행
        System.runAs(dealer) {
            Test.startTest();
            Account asdsdwa = new Account(
                Name = 'Test fadfAccount 1',
                ResidentRegistrationNumber__c = '990811',
                CountryLookup__c = krCountry.Id,
                RegionLookup__c = krRegion.Id,
                RecordTypeId = prospectCustomerRT,
                BusinessNumber__c = '123-45-65890',
                Representative__c = 'Rep1',
                SalesOrganization__c = '1800',
                SalesDistrict__c = 'A1KR',
                SalesOffice__c = '114E',
                Division__c = '40',
                DistributionChannel__c = '10',
                Competitor__c = 'None;현대위아'
            );
            insert asdsdwa;
            Test.stopTest();
        }
    }

    @isTest
    static void triggerDeleteTest() {
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        Account acc2 = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        Test.startTest();
        delete acc1;
        delete acc2;
        Test.stopTest();
    }

}