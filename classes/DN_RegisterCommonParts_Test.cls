/**
 * Created by Junyeong Choi
 * Test Date : 2025-02-03
 * Percentage :
 */
@IsTest
public with sharing class DN_RegisterCommonParts_Test {
    @TestSetup
    static void makeData(){
        RecordType product_recordType = TestDataFactoryForSales.getRecordType('Part', 'Product2');

        List<Product2> products = new List<Product2>{
            new Product2(Name = 'DNM4500', ProductCode = 'DNM4500', RecordTypeId = product_recordType.Id),
            new Product2(Name = 'DNM4000', ProductCode = 'DNM4000', RecordTypeId = product_recordType.Id),
            new Product2(Name = 'DNM5000', ProductCode = 'DNM5000', RecordTypeId = product_recordType.Id)
        };
        insert products;

        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;

        CommonPart__c existingPart = new CommonPart__c(Campaign__c = testCampaign.Id, Product__c = products[0].Id);
        insert existingPart;
    }

    @isTest
    static void DN_RegisterCommonParts_Test() {
         Product2 testProduct = [SELECT Id, Name, ProductCode, FM_MaterialDetails__c FROM Product2 LIMIT 1];
         Campaign cp = [SELECT Id FROM Campaign LIMIT 1];
         String pdData = '{"prodId":"' + testProduct.Id + '"}';
         Product2 newProduct = new Product2(Name = 'Unique Product', ProductCode = 'UP123');
         insert newProduct;     

        List<Map<String, Object>> registerData = new List<Map<String, Object>>{
            new Map<String, Object>{
                'prodId' => newProduct.Id,
                'prodNumber' => newProduct.ProductCode,
                'prodQuantity' => 3,
                'prodNote' => 'Test Note'
            },
            new Map<String, Object>{
                'prodId' => testProduct.Id,
                'prodNumber' => testProduct.ProductCode,
                'prodQuantity' => 5,
                'prodNote' => 'Test Note 2'
            }
        };

        test.startTest();
        DN_RegisterCommonParts.searchCommonParts('DNM4500', 'DNM4500');
        DN_RegisterCommonParts.selectCommonParts(pdData);
        DN_RegisterCommonParts.saveCommonParts(cp.Id, registerData);
        test.stopTest();
    }
}