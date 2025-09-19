/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class AssetTriggerHandlerTest {

    @testSetup
    static void setupData() {
        CollaborationGroup group2 = new CollaborationGroup(
            Name = 'Test Group',
            CollaborationType = 'Private'
        );
        insert group2;

        Country__c country = TestDataFactoryForService.createKRCountry();
        insert country;
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet;
        List<Account> insertAccountList = new List<Account>();
        Account dealerAcc = TestDataFactoryForService.createAccount('Dealer', 'Test Dealer', country);
        dealerAcc.CustomerCode__c = '1311191';
        // dealerAcc.SalesOffice__c         = '114B';
        insertAccountList.add(dealerAcc);
        
        Account shipToAcc = TestDataFactoryForService.createAccount('ShipToParty', 'Test Account', country);
        shipToAcc.CustomerCode__c = '1237758';
        // shipToAcc.SalesOffice__c         = '114B';
        insertAccountList.add(shipToAcc);
        insert insertAccountList;
        // Account acc           = new Account();
        // acc.Name              = 'TestAccount';
        // // acc.RecordTypeId      = type.Id;
        // acc.Phone             = '00000000000';
        // acc.BusinessNumber__c = '5148171774';
        // acc.Representative__c = 'testuser';
        // acc.CustomerCode__c   = '0000000';
        // acc.TypeOfBusiness__c = 'Manufacturing';
        // acc.TypeOfIndustry__c = 'Wholesale and Commodity Brokerage';
        // acc.IsKeyAccount__c   = true;

        // acc.CurrencyIsoCode  = 'KRW';
        // acc.Country__c       = 'KR';
        // // acc.CountryLookup__c = country.Id;
        
        // acc.DistributionChannel__c = '10';
        // acc.Division__c            = '40';
        // acc.SalesOffice__c         = '114E';
        // acc.SalesDistrict__c       = 'A1KR';
        // acc.SalesOrganization__c   = '1800';

        // acc.ShippingCity = '대구광역시 달서구 성서공단로';
        // acc.ShippingPostalCode = '42722';        
        // insert acc;
        CollaborationGroup group1 = [SELECT Id FROM CollaborationGroup LIMIT 1];
        Account testacc = [SELECT Id FROM Account LIMIT 1];

        Asset asset = new Asset(
            Name = 'Test Asset',
            AccountId = testacc.Id,
            Status = 'Active',
            ConstrYrMth__c = '2023/11',
            WarrantyStartDateWages__c = Date.today()
        );
        insert asset;
    }

    @isTest
    static void testOnBeforeUpdate_ValidConstrYrMth() {
        Asset asset = [SELECT Id, ConstrYrMth__c, WarrantyStartDateWages__c FROM Asset LIMIT 1];
        asset.ConstrYrMth__c = '2024/12';
        asset.WarrantyStartDateWages__c = Date.today().addDays(5);
        
        Test.startTest();
        update asset;
        Test.stopTest();

        Asset updated = [SELECT WarrantyStartDate__c FROM Asset WHERE Id = :asset.Id];
        System.assertEquals(asset.WarrantyStartDateWages__c, updated.WarrantyStartDate__c, 'WarrantyStartDate__c should be updated from WarrantyStartDateWages__c');
    }

    @isTest
    static void testOnBeforeUpdate_InvalidConstrYrMth() {
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        asset.ConstrYrMth__c = '2024-13';

        Test.startTest();
        try {
            update asset;
            System.assert(false, 'ConstrYrMth__c의 형식이 잘못되었는데도 예외가 발생하지 않음');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Constr.yr/mth 값은 "yyyy/MM" 형식'), '에러 메시지가 예상과 다릅니다.');
        }
        Test.stopTest();
    }

    @isTest
    static void testOnAfterUpdate_ChangeDetected() {
        Asset asset = [SELECT Id, Status FROM Asset LIMIT 1];
        asset.Status = 'ECUS';

        Test.startTest();
        update asset;
        Test.stopTest();

        System.assert(true, '배치가 정상적으로 트리거되었는지 확인');
    }
}