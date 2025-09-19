/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 05-29-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-07-2025   Hanyeong Choi   Initial Version
**/
@isTEST
public with sharing class DN_AccountLayoutController_TEST {
    @TestSetup
    static void setUp() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        // Country 생성
        Country__c krCountry = TestDataFactoryForSales.createKRCountry();
        Country__c usCountry = TestDataFactoryForSales.createCountry('USA', 'USD', 'US');
        insert new List<Country__c>{krCountry, usCountry};
        
        // Region 생성
        Region__c krRegion = TestDataFactoryForSales.createRegion('제주도', 'KRW', '01', krCountry.Id);
        Region__c usRegion = TestDataFactoryForSales.createRegion('California', 'USD', 'CA', usCountry.Id);
        insert new List<Region__c>{krRegion, usRegion};
        
        User dealer;
        System.runAs(thisUser) {
            // Dealer Account 생성
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', krCountry, null);
            insert dealerAcc;
            
            // Dealer Contact 생성
            Contact dealerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert dealerCon;
            
            // Dealer 생성
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerCon);
            insert dealer;
            
            // User 생성
            insert TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
        }
        
        // Too many SOQL queries 방지
        TriggerHandler.bypassedHandlers = new Set<String>{'AccountTriggerHandler'};
        
        System.runAs(dealer) {
            // Prospect Account 생성
            List<Account> prospectAccounts = new List<Account>{
                createProspectAccount(krCountry, 'MVC', '2025-01-01', '2025-02-01', null, null, false, null),
                createProspectAccount(krCountry, null, null, null, 'TEST2TEST2', 'TESTT', true, krRegion.Id),
                createProspectAccount(usCountry, null, null, null, 'TEST3TEST3', 'TESTT3', true, null),
                createProspectAccount(usCountry, null, null, null, 'TEST4TEST4', 'TESTT4', true, usRegion.Id)
            };
            insert prospectAccounts;
            
            // Parent Account 생성
            Account parentAcc = TestDataFactoryForSales.createParentAccount(krCountry);
            insert parentAcc;
            
            // Trade Account 생성
            Account tradeAcc = TestDataFactoryForSales.createAccount('TradeCustomer', krCountry, parentAcc);
            tradeAcc.CustomerCode__c    = '123456';
            tradeAcc.BusinessNumber__c  = '5148171773';
            tradeAcc.Representative__c  = 'realAcc';
            insert tradeAcc;
            
            // SalesAreaData 생성
            List<SalesAreaData__c> salesAreas = new List<SalesAreaData__c>();
            for (Account acc : prospectAccounts) {
                salesAreas.add(TestDataFactoryForSales.createAreaData(acc));
            }
            salesAreas.add(TestDataFactoryForSales.createAreaData(tradeAcc));
            insert salesAreas;
            
            // Contact 생성
            insert TestDataFactoryForSales.createContact('ContactPerson', tradeAcc.Id);
        }
    }

    @isTest
    static void getUserRecordType_Test() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        DN_AccountLayoutController.getUserRecordType();
        Test.stopTest();
    }

    @isTest
    static void getNextInit_Test() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        DN_AccountLayoutController.getNextInit('Account', 'ProspectCustomer');
        DN_AccountLayoutController.getNextInit('Account', 'Dealer');
        DN_AccountLayoutController.getNextInit('Account', 'ShipToParty');
        DN_AccountLayoutController.getNextInit('Account', 'TradeCustomer');
        DN_AccountLayoutController.getNextInit('Account', 'DNSACustomer');
        Test.stopTest();
    }

    @isTest
    static void saveAccountRecord_Test() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-001', 'IF_ERP_Account');
        Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
        Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
        Id shipToPartyRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipToParty').getRecordTypeId();
        Id DNSACustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE CountryCode__c = 'KR' LIMIT 1];
        Region__c region = [SELECT Id, Country__c FROM Region__c WHERE Country__c = :country.Id LIMIT 1];
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('Name', 'Test Accountwadadawd');
        fieldMap.put('Representative__c', 'Test Accou');
        fieldMap.put('CountryLookup__c', country.Id);
        fieldMap.put('RegionLookup__c', region.Id);
        fieldMap.put('IsBusinessLicense__c', true);
        fieldMap.put('BusinessNumber__c', '5148171777');
        fieldMap.put('CareOfRigger__c', true);
        fieldMap.put('ShippingStreet', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
        fieldMap.put('ShippingCity', 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
        User dealer = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();
        DN_AccountLayoutController.saveAccountRecord('Account', fieldMap, (String) prospectCustomerRT);
        Test.stopTest();
    }
    @isTest
    static void saveAccountRecord_Test2() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-015', 'IF_ERP_Account');
        Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
        Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
        Id shipToPartyRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipToParty').getRecordTypeId();
        Id DNSACustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE CountryCode__c = 'KR' LIMIT 1];
        Region__c region = [SELECT Id, Country__c FROM Region__c WHERE Country__c = :country.Id LIMIT 1];
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('Name', 'Test Accountwadadawd');
        fieldMap.put('Representative__c', 'Test Accou');
        fieldMap.put('CountryLookup__c', country.Id);
        fieldMap.put('RegionLookup__c', region.Id);
        fieldMap.put('IsBusinessLicense__c', true);
        fieldMap.put('BusinessNumber__c', '5148171778');
        fieldMap.put('CareOfRigger__c', true);
        fieldMap.put('ShippingStreet', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
        fieldMap.put('ShippingCity', 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
        User dealer = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();
        DN_AccountLayoutController.saveAccountRecord('Account', fieldMap, (String) DNSACustomerRT);
        Test.stopTest();
    }
    @isTest
    static void saveAccountRecord_Test3() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-004', 'IF_ERP_Account');
        Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
        Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
        Id shipToPartyRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipToParty').getRecordTypeId();
        Id DNSACustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE CountryCode__c = 'KR' LIMIT 1];
        Region__c region = [SELECT Id, Country__c FROM Region__c WHERE Country__c = :country.Id LIMIT 1];
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('Name', 'Test Accountwadadawd');
        fieldMap.put('Representative__c', 'Test Accou');
        fieldMap.put('CountryLookup__c', country.Id);
        fieldMap.put('RegionLookup__c', region.Id);
        fieldMap.put('IsBusinessLicense__c', true);
        fieldMap.put('BusinessNumber__c', '5148171779');
        fieldMap.put('CareOfRigger__c', true);
        fieldMap.put('ShippingStreet', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
        fieldMap.put('ShippingCity', 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
        User dealer = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();
        DN_AccountLayoutController.saveAccountRecord('Account', fieldMap, (String) shipToPartyRT);
        Test.stopTest();
    }
    @isTest
    static void saveAccountRecord_Test4() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-012', 'IF_ERP_Account');
        Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
        Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
        Id shipToPartyRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipToParty').getRecordTypeId();
        Id DNSACustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE CountryCode__c = 'KR' LIMIT 1];
        Region__c region = [SELECT Id, Country__c FROM Region__c WHERE Country__c = :country.Id LIMIT 1];
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('Name', 'Test Accountwadadawd');
        fieldMap.put('Representative__c', 'Test Accou');
        fieldMap.put('CountryLookup__c', country.Id);
        fieldMap.put('RegionLookup__c', region.Id);
        fieldMap.put('IsBusinessLicense__c', true);
        fieldMap.put('BusinessNumber__c', '5148171774');
        fieldMap.put('CareOfRigger__c', true);
        fieldMap.put('ShippingStreet', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
        fieldMap.put('ShippingCity', 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
        User dealer = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();
        DN_AccountLayoutController.saveAccountRecord('Account', fieldMap, (String) tradeCustomerRT);
        Test.stopTest();
    }

    @isTest
    static void saveAccountRecord_Test5() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-012', 'IF_ERP_Account');
        Id prospectCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
        Id tradeCustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
        Id shipToPartyRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipToParty').getRecordTypeId();
        Id DNSACustomerRT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();

        User user = [SELECT Id, SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()];
        user.SalesOrganization__c = '4140';
        update user;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Country__c country = [SELECT Id, CountryCode__c FROM Country__c WHERE CountryCode__c = 'KR' LIMIT 1];
        Region__c region = [SELECT Id, Country__c FROM Region__c WHERE Country__c = :country.Id LIMIT 1];
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('Name', 'Test Accountwadadawd');
        fieldMap.put('Representative__c', 'Test Accou');
        fieldMap.put('CountryLookup__c', country.Id);
        fieldMap.put('RegionLookup__c', region.Id);
        fieldMap.put('IsBusinessLicense__c', true);
        fieldMap.put('BusinessNumber__c', '5148171770');
        fieldMap.put('CareOfRigger__c', true);
        fieldMap.put('ShippingStreet', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
        fieldMap.put('ShippingCity', 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb');
        User dealer = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();
        DN_AccountLayoutController.saveAccountRecord('Account', fieldMap, (String) tradeCustomerRT);
        Test.stopTest();
    }

    @isTest
    static void searchAccount_TEST() {
        Test.startTest();
        DN_AccountLayoutController.searchAccount('TEST');
        Test.stopTest();
    }

    @isTest
    static void checkShareAcc_TEST() {
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'ProspectCustomer' LIMIT 1];
        Test.startTest();
        DN_AccountLayoutController.checkShareAcc(acc.Id);
        Test.stopTest();
    }

    @isTest
    static void insertRequestCustomer_TEST() {
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'ProspectCustomer' LIMIT 1];
        Test.startTest();
        DN_AccountLayoutController.insertRequestCustomer('TEST', acc.Id);
        Test.stopTest();
    }

    @isTest
    static void getLabel_TEST() {
        Test.startTest();
        DN_AccountLayoutController.getLabel('Name');
        Test.stopTest();
    }

    private static Account createProspectAccount(Country__c country, String customerSystem, String startDate, String endDate,
                                                String name, String production, Boolean isBusinessLicense, String regionId) {
        Account acc = TestDataFactoryForSales.createAccount('ProspectCustomer', country, null);
        
        acc.Name                        = (name != null)                ? name                      : acc.Name;
        acc.Production__c               = (production != null)          ? production                : null;
        acc.CustomerSystem__c           = (customerSystem != null)      ? customerSystem            : null;
        acc.CustomerSystemStartDate__c  = (startDate != null)           ? Date.valueOf(startDate)   : null;
        acc.CustomerSystemEndDate__c    = (endDate != null)             ? Date.valueOf(endDate)     : null;
        acc.IsBusinessLicense__c        = (isBusinessLicense != null)   ? isBusinessLicense         : false;
        acc.RegionLookup__c             = (regionId != null)            ? regionId                  : null;
        acc.BusinessNumber__c           = '5148171135';
        return acc;
    }
}