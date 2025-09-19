/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-12
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-04-12   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class IF_ETTriggerHandlerTest {

    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        // Country__c country = TestDataFactoryForSales.createCountry('USA', 'USD', 'US');
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Region__c region = TestDataFactoryForSales.createRegion('KRRegion', 'KRW', 'KRR', country.Id);
        insert region;

        DNSAModel__c model = new DNSAModel__c(
            Name = 'ModelA',
            ModelName__c = 'ModelA'
        );
        insert model;

        Competitor__c comp = new Competitor__c(
            Name = 'CompetitorX'
        );
        insert comp;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler' ,'UserTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dnsaAcc = TestDataFactoryForSales.createAccount('DNSACustomer', country, null);
            dnsaAcc.CustomerCode__c = '11111';
            dnsaAcc.Name = 'DNSACustomer';
            dnsaAcc.Representative__c = 'DNSARep';
            dnsaAcc.ETAccountId__c = 'TESTUSER1';
            insert dnsaAcc; 

            Contact contactPerson = TestDataFactoryForSales.createContact('ContactPerson', dnsaAcc.Id);
            insert contactPerson;

            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.Name = 'test Dealer';
            dealerAcc.CustomerCode__c = '22222';
            dealerAcc.Phone = '111-222';
            insert dealerAcc;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer.SalesOrganization__c = '4140';
            dealer.ETUserId__c = 'TESTUSER1';
            insert dealer;
        }
    }


    @isTest
    static void testIF_ETTriggerHandler() {
        
        // IF_ET__c 레코드 생성 시 필요한 모든 필드를 설정합니다.
        // (필드 이름은 귀하의 코드 기준으로 작성되었으며 실제 이름과 다를 수 있으므로 필요한 경우 조정)
        List<IF_ET__c> etRecords = new List<IF_ET__c>();
        
        // 새 Account, Contact, Opportunity를 생성하는 케이스
        IF_ET__c rec1 = new IF_ET__c();
        rec1.OpportunityOwnerId__c = 'TESTUSER1';  // User의 ETUserId__c
        rec1.AccountOwnerId__c = 'TESTUSER1';
        rec1.ContactOwnerId__c = 'TESTUSER1';
        rec1.DNSAModel__c = 'Test Model';
        rec1.Competitor__c = 'Test Competitor';
        rec1.CountryLookup__c = 'United States'; // countryMapping: 'United States' -> 'US'
        rec1.ShippingState__c = 'NC';
        // Account 관련:
        rec1.AccountId__c = 'ACC001';  // 외부 Id (텍스트 값)
        rec1.AccountName__c = 'Test Account';
        rec1.AccountPhone__c = '123-456-7890';
        rec1.AccountEmail__c = 'acct@example.com';
        // Contact 관련:
        rec1.ContactAccountId__c = 'ACC001';
        rec1.FirstName__c = 'John';
        rec1.LastName__c = 'Doe';
        rec1.ContactEmail__c = 'johndoe@example.com';
        rec1.ContactPhone__c = '111-222-3333';
        rec1.MobilePhone__c = '444-555-6666';
        // Opportunity 관련:
        rec1.OpportunityId__c = 'OPP001';
        rec1.CloseDate__c = '2025-04-15';
        rec1.Probability__c = '95';
        rec1.PO__c = 'PO12345';
        rec1.RequestDelieveryDate__c = '2025-06-15';
        etRecords.add(rec1);
        
        // Update case: 같은 Account 및 Opportunity 외부 Id에 대해 값 변경
        IF_ET__c rec2 = new IF_ET__c();
        rec2.OpportunityOwnerId__c = 'TESTUSER1';
        rec2.AccountOwnerId__c = 'TESTUSER1';
        rec2.ContactOwnerId__c = 'TESTUSER1';
        rec2.DNSAModel__c = 'Test Model';
        rec2.Competitor__c = 'Test Competitor';  // 동일 Competitor로 중복 매핑 없이 처리되어야 함
        rec2.CountryLookup__c = 'United States';
        rec2.ShippingState__c = 'NC';
        rec2.AccountId__c = 'ACC001';  // 같은 외부 Id
        rec2.AccountName__c = 'Test Account Updated';
        rec2.AccountPhone__c = '999-888-7777';
        rec2.AccountEmail__c = 'newacct@example.com';
        rec2.ContactAccountId__c = 'ACC001';
        rec2.FirstName__c = 'John';
        rec2.LastName__c = 'Doe';
        rec2.ContactEmail__c = 'johndoe_updated@example.com';
        rec2.ContactPhone__c = '111-222-3333';
        rec2.MobilePhone__c = '444-555-6666';
        rec2.OpportunityId__c = 'OPP001'; // same opportunity -> update
        rec2.CloseDate__c = '2025-04-20';
        rec2.Probability__c = '90';
        rec2.PO__c = 'PO54321';
        rec2.RequestDelieveryDate__c = '2025-06-20';
        etRecords.add(rec2);
        
        Test.startTest();
        insert etRecords;
        Test.stopTest();

    }


    



}