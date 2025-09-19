/** 
 * @Class :  DN_DMLBatchProcessing_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 21. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-21 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_DMLBatchProcessing_TEST {
    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void craeteBatch() {
        Test.startTest();
        List<Account> accList = new List<Account>();
        accList.add(TestDataFactoryForDealerPortal.dealer);
        accList[0].SalesOffice__c = '1146';
        Database.executeBatch(new DN_DMLBatchProcessing(DN_DMLBatchProcessing.DmlType.ADD, accList));
        
        Test.stopTest();
    }

    @isTest
    static void craeteBatch_Fail() {
        Test.startTest();
        List<Account> accList = new List<Account>();
        accList.add(new Account());
        Database.executeBatch(new DN_DMLBatchProcessing(DN_DMLBatchProcessing.DmlType.ADD, accList));
        
        Test.stopTest();
    }

    
    @isTest
    static void updateBatch_Fail() {
        List<Account> accList = new List<Account>();
        accList.add(TestDataFactoryForDealerPortal.dealer);
        accList[0].SalesOffice__c = '1146';
        insert accList;
        Test.startTest();
        accList[0].Name = 'Test';
        Database.executeBatch(new DN_DMLBatchProcessing(DN_DMLBatchProcessing.DmlType.MODIFY, accList));
        
        Test.stopTest();
    }

    @isTest
    static void upsertBatch() {
        Test.startTest();
        List<Product2> proudctList = new List<Product2>();
        Product2 product = TestDataFactoryForDealerPortal.getPart('R18181', 'R18181','R18181');
        proudctList.add(product);
        insert product;

        List<DealerStock__c> stockList = new List<DealerStock__c>();
        DealerStock__c stock = TestDataFactoryForDealerPortal.getStock(product.Id, null);
        stock.ExternalKey__c = '1846_10_40_R18181';
        stockList.add(stock);
        DealerStock__c stock2 = TestDataFactoryForDealerPortal.getStock(product.Id, null);
        stockList.add(stock2);
        
        Database.executeBatch(new DN_DMLBatchProcessing(DN_DMLBatchProcessing.DmlType.ADDORMODIFY, stockList, 'ExternalKey__c'));
        
        Test.stopTest();
    }
}