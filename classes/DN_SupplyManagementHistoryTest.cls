@isTest
public with sharing class DN_SupplyManagementHistoryTest {
    @TestSetup
    static void makeData(){
        Asset asset = new Asset(Name = 'ML0006-006231');
        insert asset;

        Case caseObj = new Case(
            // RecordTypeId        = ticketRT,
            Status              = 'New',
            AssetId             = asset.Id,
            ReceptionDetails__c = 'Test',
            TicketType__c       = 'Technical inquiry',
            InternalTicketType__c = 'Program Inquiry'
        );
        insert caseObj;

        RecordType product_recordType = TestDataFactoryForSales.getRecordType('Part', 'Product2');

        Product2 products = new Product2(
            Name = 'DNM5000', ProductCode = 'DNM5000', RecordTypeId = product_recordType.Id
        );
        insert products;


        ProductionManagementHistory__c pmh = new ProductionManagementHistory__c(
            Ticket__c = caseObj.Id,
            Product__c = products.Id
        );
        insert pmh;

    }

    @isTest
    static void testGetRecordInfo(){
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        ProductionManagementHistory__c pmhObj = [SELECT Id FROM ProductionManagementHistory__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        DN_SupplyManagementHistory.ChargingPartWrapper wrapper = new DN_SupplyManagementHistory.ChargingPartWrapper();
        wrapper.ProductId = product.Id;
        wrapper.PartAmount = 5;
        List<DN_SupplyManagementHistory.ChargingPartWrapper> wrapperList = new List<DN_SupplyManagementHistory.ChargingPartWrapper>{wrapper};
        
        Test.startTest();
        DN_SupplyManagementHistory.getChargingPartList(caseObj.Id);
        DN_SupplyManagementHistory.deletePMHistory(pmhObj.Id);
        DN_SupplyManagementHistory.upsertRequestProduct(wrapperList, caseObj.Id);
        DN_SupplyManagementHistory.getProductDetails(product.Id);
        Test.stopTest();
    }
}