/** 
 * @Class :  AlternativePartsManager_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 22. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-22 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class AlternativePartsManager_TEST {
    @TestSetup
    static void makeData(){
        List<Product2> partList = new List<Product2>();
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18181', 'R18181영문', 'R18181국문')
            );
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18182', 'R18182영문', 'R18182국문')
            ); //Last
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18180', 'R18180영문', 'R18180국문')
            ); //Start
            insert partList;
        
            List<ProductByPlant__c> plantByProductList = new List<ProductByPlant__c>();
            ProductByPlant__c plant1 = TestDataFactoryForDealerPortal.getProductByPlant(partList[0].Id,partList[1].Id);
            plant1.StartPart__c = partList[2].id;
            plant1.ReplacingPart__c = partList[1].id;
            plantByProductList.add(plant1);
            ProductByPlant__c plant2 = TestDataFactoryForDealerPortal.getProductByPlant(partList[1].Id,partList[1].Id);
            plant2.StartPart__c = partList[2].id;
            plantByProductList.add(plant2);
            ProductByPlant__c plant3 = TestDataFactoryForDealerPortal.getProductByPlant(partList[2].Id,partList[1].Id);
            plant3.ReplacingPart__c = partList[0].id;
            plant3.StartPart__c = partList[2].id;
            plantByProductList.add(plant3);
            insert plantByProductList;
    }

    @isTest
    static void execute() {
        Test.startTest();
        //850418-03289
        AlternativePartsManager alternativeHandler = new AlternativePartsManager(new Set<String>{'R18180'});
        alternativeHandler.setReplacementPartsForProduct();
        System.debug(JSON.serializePretty(alternativeHandler.getReplacementParts()));
        System.debug(JSON.serializePretty(alternativeHandler.getReplacingItemTypeMap()));
        System.debug(JSON.serializePretty(alternativeHandler.getReplacingPartInfo()));

        Test.stopTest();
    }
}