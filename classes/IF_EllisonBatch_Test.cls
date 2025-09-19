@isTest
public with sharing class IF_EllisonBatch_Test {
    public IF_EllisonBatch_Test() {}

    @isTest
    static void testEllisonBatchExecution() {
        List<IF_EllisonBatch.EllisonBatchDto> testDtos = new List<IF_EllisonBatch.EllisonBatchDto>();

        IF_EllisonBatch.EllisonBatchDto dto = new IF_EllisonBatch.EllisonBatchDto();
        dto.CustomerCode = 'CUST001';
        dto.AccountName = 'Test Account';
        dto.AccountOwnerId = UserInfo.getUserId();
        dto.Representative = 'Rep1';
        dto.CountryLookup = 'USA';
        dto.RegionLookup = 'West';
        dto.ShippingCountry = 'USA';
        dto.ShippingStreet = '123 Test St';
        dto.ShippingCity = 'Testville';
        dto.ShippingState = 'CA';
        dto.ShippingPostalCode = '90001';
        dto.AccountPhone = '123-456-7890';
        dto.AccountEmail = 'test@example.com';
        dto.AccountShippingAddress = '123 Test St, Testville, CA 90001';
        dto.AlternateShipToAddress = 'Alt Address';
        dto.AltShipToName = 'Alt Name';
        dto.AccountId = '001XXXXXXXXXXXX'; 

        dto.ContactOwnerId = UserInfo.getUserId();
        dto.LastName = 'Doe';
        dto.MiddleName = 'M';
        dto.FirstName = 'John';
        dto.ContactAccountId = '001XXXXXXXXXXXX';
        dto.ContactEmail = 'john.doe@example.com';
        dto.ContactPhone = '987-654-3210';
        dto.MobilePhone = '123-321-4567';

        dto.OpportunityOwnerId = UserInfo.getUserId();
        dto.DNSAModel = 'ModelX';
        dto.Probability = '80';
        dto.CloseDate = '2025-04-30';
        dto.RequestDelieveryDate = '2025-05-10';
        dto.PO = 'PO123456';
        dto.OpportunityName = 'Test Opportunity';
        dto.Competitor = 'CompetitorX';
        dto.OpportunityId = '006XXXXXXXXXXXX';

        testDtos.add(dto);

        Test.startTest();
        IF_EllisonBatch batch = new IF_EllisonBatch(testDtos);
        Database.executeBatch(batch);
        Test.stopTest();

    }
}