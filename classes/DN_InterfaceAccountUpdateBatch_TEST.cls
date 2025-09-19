/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 05-30-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-20-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class DN_InterfaceAccountUpdateBatch_TEST {
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

        TriggerHandler.bypassedHandlers = new Set<String>{'AccountTriggerHandler'};

        Account prospectAcc = TestDataFactoryForSales.createAccount('ProspectCustomer', krCountry, null);
        prospectAcc.Name  = 'prospectAcc';
        prospectAcc.BusinessNumber__c  = '5148171224';
        prospectAcc.ShippingStreet  = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        insert prospectAcc;
        Account shipToAcc = TestDataFactoryForSales.createAccount('ShipToParty', krCountry, null);
        shipToAcc.Name  = 'shipToAcc';
        shipToAcc.BusinessNumber__c  = '5148121224';
        shipToAcc.ShippingStreet  = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        insert shipToAcc;
        Account tradeAcc = TestDataFactoryForSales.createAccount('TradeCustomer', krCountry, null);
        tradeAcc.Name  = 'tradeAcc';
        tradeAcc.Sales_Office_CS__c  = '114B';
        tradeAcc.ShippingStreet  = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        insert tradeAcc;
    }

    @isTest
    static void prrospectBatchTest() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-002', 'IF_ERP_Account');

        AlertManager__c am = TestDataFactoryForSales.createAlertManager('Account Update Error Alert');
        insert am;

        List<Account> accList1 = [
            SELECT Id,CountryLookup__c,RegionLookup__c,CustomerCode__c,Name,Representative__c,AccountNameEnglish__c,
            SearchTerm__c,ShippingPostalCode,ShippingStreet,ShippingCity,Phone,Mobile__c,Fax,Website,MainCategory__c,
            SubCategory__c,IsTooling__c,TypeOfBusiness__c,TypeOfIndustry__c,SalesOffice__c,SalesDistrict__c,
            SalesOrganization__c,DistributionChannel__c,Division__c,Language__c,CurrencyIsoCode,
            BusinessNumberDuplCheck__c,Email__c
            FROM Account 
            WHERE Name = 'prospectAcc' 
        ];

        Test.startTest();
        DN_InterfaceAccountUpdateBatch batch1 = new DN_InterfaceAccountUpdateBatch(accList1, 'ProspectCustomer');
        Database.executeBatch(batch1, 10);
        Test.stopTest();
    }
    @isTest
    static void shiptoBatchTest() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-013', 'IF_ERP_Account');

        AlertManager__c am = TestDataFactoryForSales.createAlertManager('Account Update Error Alert');
        insert am;

        List<Account> accList2 = [
            SELECT Id,CountryLookup__c,RegionLookup__c,CustomerCode__c,Name,Representative__c,AccountNameEnglish__c,
            SearchTerm__c,ShippingPostalCode,ShippingStreet,ShippingCity,Phone,Mobile__c,Fax,Website,MainCategory__c,
            SubCategory__c,IsTooling__c,TypeOfBusiness__c,TypeOfIndustry__c,SalesOffice__c,SalesDistrict__c,
            SalesOrganization__c,DistributionChannel__c,Division__c,Language__c,CurrencyIsoCode,
            BusinessNumberDuplCheck__c,Email__c
            FROM Account 
            WHERE Name = 'shipToAcc' 
        ];

        Test.startTest();
        DN_InterfaceAccountUpdateBatch batch2 = new DN_InterfaceAccountUpdateBatch(accList2, 'ShipToParty');
        Database.executeBatch(batch2, 10);
        Test.stopTest();
    }
    @isTest
    static void batchTest() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-003', 'IF_ERP_Account');

        AlertManager__c am = TestDataFactoryForSales.createAlertManager('Account Update Error Alert');
        insert am;
        List<Account> accList3 = [
            SELECT Id,CountryLookup__c,RegionLookup__c,CustomerCode__c,Name,Representative__c,AccountNameEnglish__c,
            SearchTerm__c,ShippingPostalCode,ShippingStreet,ShippingCity,Phone,Mobile__c,Fax,Website,MainCategory__c,
            SubCategory__c,IsTooling__c,TypeOfBusiness__c,TypeOfIndustry__c,SalesOffice__c,SalesDistrict__c,
            SalesOrganization__c,DistributionChannel__c,Division__c,Language__c,CurrencyIsoCode,
            BusinessNumberDuplCheck__c,Email__c,Sales_Office_CS__c
            FROM Account 
            WHERE Name = 'tradeAcc'
        ];

        Test.startTest();
        DN_InterfaceAccountUpdateBatch batch3 = new DN_InterfaceAccountUpdateBatch(accList3, 'TradeCustomer');
        Database.executeBatch(batch3, 10);
        Test.stopTest();
    }
}