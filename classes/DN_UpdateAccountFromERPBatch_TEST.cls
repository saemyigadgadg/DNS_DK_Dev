/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-18-2025   Hanyeong Choi   Initial Version
**/
@isTest
private class DN_UpdateAccountFromERPBatch_TEST {
    @TestSetup
    static void setup() {
        // Record Types
        Id PROSPECT_CUSTOMER_RT = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ProspectCustomer').getRecordTypeId();
        Id TRADE_CUSTOMER_RT    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
        Id SHIP_TO_PARTY_RT    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ShipToParty').getRecordTypeId();
        Id DEALER_RT           = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        Id DNSA_RT             = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();

        // Country__c
        List<Country__c> countries = new List<Country__c>();
        countries.add(new Country__c(Name = 'South Korea', CountryCode__c = 'KR'));
        countries.add(new Country__c(Name = 'China', CountryCode__c = 'CN'));
        countries.add(new Country__c(Name = 'United States', CountryCode__c = 'US'));
        insert countries;

        // Region__c
        List<Region__c> regions = new List<Region__c>();
        regions.add(new Region__c(Name = 'Seoul', RegionCode__c = 'SEO', Country__c = countries[0].Id));
        regions.add(new Region__c(Name = 'California', RegionCode__c = 'CA', Country__c = countries[2].Id));
        insert regions;

        // TransportationZone__c
        TransportationZone__c zone = new TransportationZone__c(Name = 'ZONE1', ZONE1__c = 'ZONE001');
        insert zone;

        // User for ZM
        User thisUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        User u;
        System.runAs(thisUser) {
            u = TestDataFactoryForSales.createDNSUser(thisUser.Profile.Name, 'KA');
            u.CustomerCode__c = '12345';
            insert u;
        }

        // Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
        // TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        // Existing Accounts
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(
            Name = 'Existing Trade Account',
            CustomerCode__c = '12345',
            RecordTypeId = TRADE_CUSTOMER_RT,
            CountryLookup__c = countries[0].Id,
            BusinessNumberDuplCheck__c = '123-45-67890',
            businessNumber__c = '123-45-67890'
        ));
        accounts.add(new Account(
            Name = 'Existing Dealer Account',
            CustomerCode__c = '12346',
            RecordTypeId = DEALER_RT,
            CountryLookup__c = countries[0].Id
        ));
        insert accounts;

        // IF_Account__c records
        List<IF_Account__c> ifAccounts = new List<IF_Account__c>();

        // KNA1 (Normal - TradeCustomer)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '12345',
            NAME1__c = 'Test Trade Account',
            KTOKD__c = '1010',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            REGIO_T__c = 'SEO',
            LZONE__c = 'ZONE001',
            STRAS__c = '123 Main St',
            ORT01__c = 'Seoul',
            PSTLZ__c = '12345',
            TELFX__c = '123-456-7890',
            SMTP_ADDR__c = 'test@test.com',
            ZWEBPAGE__c = 'www.test.com',
            TELF1__c = '123-456-7890',
            TELF2__c = '987-654-3210',
            VKBUR__c = '1800',
            KATR1__c = 'Main',
            KATR2__c = 'Sub',
            KATR3__c = 'Tooling',
            SORTL__c = 'Search',
            SORT1__c = 'Search1',
            SORT2__c = 'Search2',
            VTEXT2__c = 'Description',
            STCD2__c = '123-45-67890',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVV (TradeCustomer)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVV',
            KUNNR__c = '12345',
            VKORG__c = '1800',
            VTWEG__c = '10',
            SPART__c = '40',
            KDGRP__c = '01',
            VKBUR__c = '1800',
            BZIRK__c = 'DIST1',
            WAERS__c = 'KRW',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVP (ZM)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVP',
            KUNNR__c = '12345',
            PARVW__c = 'ZM',
            KUNN2__c = '12345',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVP (WE)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVP',
            KUNNR__c = '12345',
            PARVW__c = 'WE',
            KUNN2__c = '12346',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVP (ZI)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVP',
            KUNNR__c = '12345',
            PARVW__c = 'ZI',
            KUNN2__c = '12346',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVP (RE, AG, RG)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVP',
            KUNNR__c = '12345',
            PARVW__c = 'RE',
            KUNN2__c = '12346',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVP',
            KUNNR__c = '12345',
            PARVW__c = 'AG',
            KUNN2__c = '12346',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVP',
            KUNNR__c = '12345',
            PARVW__c = 'RG',
            KUNN2__c = '12346',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (Delete)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '12346',
            NAME1__c = 'Delete Account',
            KTOKD__c = '1010',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            FLAG__c = 'X',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (Dealer)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '12346',
            NAME1__c = 'Dealer Account',
            KTOKD__c = '1010',
            KDGRP__c = '02',
            LAND1__c = 'KR',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (ProspectCustomer)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '12347',
            NAME1__c = 'Prospect Account',
            KTOKD__c = '1090',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVV (ProspectCustomer)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVV',
            KUNNR__c = '12347',
            VKORG__c = '1800',
            VTWEG__c = '10',
            SPART__c = '40',
            KDGRP__c = '01',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (DNSA)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '12348',
            NAME1__c = 'DNSA Account',
            KTOKD__c = '1030',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            VKORG__c = '4140',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVV (DNSA)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVV',
            KUNNR__c = '12348',
            VKORG__c = '4140',
            VTWEG__c = '10',
            SPART__c = '40',
            KDGRP__c = '01',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (ShipToParty)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '12349',
            NAME1__c = 'ShipToParty Account',
            KTOKD__c = '1030',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVV (ShipToParty)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVV',
            KUNNR__c = '12349',
            VKORG__c = '1800',
            VTWEG__c = '10',
            SPART__c = '40',
            KDGRP__c = '01',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (CN - Skip)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '12350',
            NAME1__c = 'CN Account',
            KTOKD__c = '1010',
            KDGRP__c = '01',
            LAND1__c = 'CN',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (VKORG 27xx - Skip)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '12351',
            NAME1__c = 'VKORG 27 Account',
            KTOKD__c = '1010',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            VKORG__c = '2700',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (Invalid KTOKD)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '12352',
            NAME1__c = 'Invalid Account',
            KTOKD__c = '9999',
            KDGRP__c = '99',
            LAND1__c = 'KR',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (Korean Address)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '20000',
            NAME1__c = 'Korean Account',
            KTOKD__c = '1010',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            STRAS__c = '123 Main St',
            ORT01__c = 'Seoul',
            STR_SUPPL1__c = 'Gangnam',
            STR_SUPPL2__c = 'Gu',
            STR_SUPPL3__c = 'Dong',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVV (Korean Address)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVV',
            KUNNR__c = '20000',
            VKORG__c = '1800',
            VTWEG__c = '10',
            SPART__c = '40',
            KDGRP__c = '01',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (US Address)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '20001',
            NAME1__c = 'US Account',
            KTOKD__c = '1010',
            KDGRP__c = '01',
            LAND1__c = 'US',
            REGIO_T__c = 'CA',
            STRAS__c = '456 Oak St',
            ORT01__c = 'San Francisco',
            STR_SUPPL1__c = 'Downtown',
            PSTLZ__c = '94105',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVV (US Address)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVV',
            KUNNR__c = '20001',
            VKORG__c = '1800',
            VTWEG__c = '10',
            SPART__c = '40',
            KDGRP__c = '01',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (No KNVV)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '20002',
            NAME1__c = 'No KNVV Account',
            KTOKD__c = '1010',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (DML Failure)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '20003',
            NAME1__c = '', // Invalid: Name required
            KTOKD__c = '1010',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVV (DML Failure)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVV',
            KUNNR__c = '20003',
            VKORG__c = '1800',
            VTWEG__c = '10',
            SPART__c = '40',
            KDGRP__c = '01',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (STCD3 Business Number)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '20004',
            NAME1__c = 'STCD3 Account',
            KTOKD__c = '1010',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            STCD3__c = '987-65-43210',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVV (STCD3)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVV',
            KUNNR__c = '20004',
            VKORG__c = '1800',
            VTWEG__c = '10',
            SPART__c = '40',
            KDGRP__c = '01',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (STCD4 Business Number)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '20005',
            NAME1__c = 'STCD4 Account',
            KTOKD__c = '1010',
            KDGRP__c = '01',
            LAND1__c = 'KR',
            STCD4__c = '456-78-90123',
            VKORG__c = '1800',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVV (STCD4)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVV',
            KUNNR__c = '20005',
            VKORG__c = '1800',
            VTWEG__c = '10',
            SPART__c = '40',
            KDGRP__c = '01',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNA1 (DNSA with KTOKD 1130)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNA1',
            KUNNR__c = '20006',
            NAME1__c = 'DNSA 1130 Account',
            KTOKD__c = '1130',
            KDGRP__c = '09',
            LAND1__c = 'KR',
            VKORG__c = '4140',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        // KNVV (DNSA 1130)
        ifAccounts.add(new IF_Account__c(
            TABLE_NAME__c = 'KNVV',
            KUNNR__c = '20006',
            VKORG__c = '4140',
            VTWEG__c = '10',
            SPART__c = '40',
            KDGRP__c = '09',
            IsComplete__c = false,
            AUFSD__c = ''
        ));

        insert ifAccounts;

        // SalesAreaData__c
        SalesAreaData__c sad = new SalesAreaData__c(
            Account__c = accounts[0].Id,
            SalesOrganization__c = '1800',
            DistributionChannel__c = '10',
            Division__c = '40'
        );
        insert sad;

        // DNS_CustomerDealerAssociation__c
        DNS_CustomerDealerAssociation__c dealerAssoc = new DNS_CustomerDealerAssociation__c(
            Customer__c = accounts[0].Id,
            Dealer__c = accounts[1].Id
        );
        insert dealerAssoc;

        // AccountTeamMember
        AccountTeamMember atm = new AccountTeamMember(
            AccountId = accounts[0].Id,
            UserId = u.Id,
            TeamMemberRole = 'Sales Manager',
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'None',
            CaseAccessLevel = 'None'
        );
        insert atm;
    }

    @isTest
    static void testBatch() {
        Test.startTest();
        DN_UpdateAccountFromERPBatch batch = new DN_UpdateAccountFromERPBatch();
        Database.executeBatch(batch, 50);
        Test.stopTest();
    }

    @isTest
    static void testEmptyScope() {
        Test.startTest();
        DN_UpdateAccountFromERPBatch batch = new DN_UpdateAccountFromERPBatch();
        batch.execute(null, new List<SObject>());
        Test.stopTest();
    }
}