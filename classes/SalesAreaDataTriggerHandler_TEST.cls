/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-20-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class SalesAreaDataTriggerHandler_TEST {
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

        Account prospectAcc = TestDataFactoryForSales.createAccount('ProspectCustomer', krCountry, null);
        insert prospectAcc;
        
        User dealer;
        User dealer2;
        System.runAs(thisUser) {
            // Dealer Account 생성
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', krCountry, null);
            Account dealerAcc2 = TestDataFactoryForSales.createAccount('Dealer', usCountry, null);
            dealerAcc.Name = 'awdwa';
            dealerAcc.BusinessNumber__c = '151235891';
            dealerAcc2.Name = 'ExclusiveDealer';
            dealerAcc2.Representative__c = 'Exclusive';
            dealerAcc2.BusinessNumber__c = '151235341';
            dealerAcc2.IsExclusiveDealer__c = true;
            dealerAcc2.SalesOrganization__c = '4140';
            dealerAcc2.SalesOffice__c = '414A';
            dealerAcc2.SalesDistrict__c = 'M3US';
            dealerAcc2.DistributionChannel__c = '10';
            dealerAcc2.Division__c = '40';
            insert new List<Account>{dealerAcc, dealerAcc2};
            
            // Dealer Contact 생성
            Contact dealerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            Contact dealerCon2 = TestDataFactoryForSales.createContact('Dealer', dealerAcc2.Id);
            dealerCon2.LastName = 'asdas';
            dealerCon2.Email = 'qregrgdf@gmail.com';
            dealerCon2.SalesOrganization__c = '4140';
            dealerCon2.SalesOffice__c = '414A';
            dealerCon2.SalesDistrict__c = 'MP04';
            dealerCon2.DistributionChannel__c = '10';
            dealerCon2.Division__c = '40';
            insert new List<Contact>{dealerCon, dealerCon2};
            
            // Dealer 생성
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerCon);
            dealer2 = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc2, dealerCon2);
            dealer2.Email = 'qregrgdf@gmail.com';
            dealer2.LastName = 'asdas';
            dealer2.Alias = 'fwefwefw';
            dealer2.SalesDistrict__c = 'MP04';
            insert new List<User>{dealer, dealer2};
            
            // User 생성
            insert TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
        }
        
        // Too many SOQL queries 방지
        TriggerHandler.bypassedHandlers = new Set<String>{'AccountTriggerHandler'};
        
        System.runAs(dealer) {
            // Prospect Account 생성
            Account acc1 = TestDataFactoryForSales.createAccount('ProspectCustomer', krCountry, null);
            acc1.Name = 'RTC_TEST';
            insert acc1;
            
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
            // SalesAreaData__c asd = TestDataFactoryForSales.createAreaData(acc1);
            // insert asd;
            
            // Contact 생성
            insert TestDataFactoryForSales.createContact('ContactPerson', tradeAcc.Id);
        }
    }

    @isTest
    static void triggerInsertTest() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'RTC_TEST' LIMIT 1];
        SalesAreaData__c asd = TestDataFactoryForSales.createAreaData(acc);
        
        Test.startTest();
        insert asd;
        Test.stopTest();
    }

    @isTest
    static void triggerUpdateTest() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-019', 'IF_ERP_Account');
        Account acc = [SELECT Id FROM Account WHERE Name = 'RTC_TEST' LIMIT 1];
        SalesAreaData__c asd = TestDataFactoryForSales.createAreaData(acc);
        asd.SalesOffice__c = null;
        insert asd;

        asd.SalesOrganization__c = '1846';
        asd.SalesOffice__c = '114B';
        
        Test.startTest();
        update asd;
        Test.stopTest();
    }

    @isTest
    static void triggerDeleteTest() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'RTC_TEST' LIMIT 1];
        SalesAreaData__c asd = TestDataFactoryForSales.createAreaData(acc);
        insert asd;
        
        Test.startTest();
        delete asd;
        Test.stopTest();
    }
}