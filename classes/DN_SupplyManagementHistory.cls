/** 
 * @Test: 
 * @Author : JY, CHoi 
 * @Date : 2025. 01. 08. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-08 | JY, CHoi      | 최초작성 
 */ 
public with sharing class DN_SupplyManagementHistory {
    @AuraEnabled
    public static List<ChargingPartWrapper> getChargingPartList(String caseId){

        List<ChargingPartWrapper> wrapperList = new List<ChargingPartWrapper>();
        try {
            List<ProductionManagementHistory__c> tempList = [SELECT Id, Product__c, ProductCode__c, Product__r.Name, Quantity__c, Product__r.FM_MaterialDetails__c, Ticket__c
                                            FROM ProductionManagementHistory__c 
                                            WHERE Ticket__c =: caseId];
            
            for(ProductionManagementHistory__c pr :  tempList){
                ChargingPartWrapper instance = new ChargingPartWrapper();
                instance.ProductRequestRecordId = pr.Id;                           // 레코드 ID
                instance.ProductId = pr.Product__c;                                // 품목 ID
                if(pr.ProductCode__c != null){
                    instance.ProductCode = pr.ProductCode__c;                      // 품번
                }
                instance.ProductName = pr.Product__r.FM_MaterialDetails__c;        // 품명
                if(pr.Quantity__c != null){
                    instance.PartAmount = Integer.valueOf(pr.Quantity__c);         // 수량
                }
                // instance.EditMode = false;                                         // 수정모드

                System.debug('ProductId: ' + instance.ProductId);
                System.debug('ProductName: ' + instance.ProductName);
                System.debug('ProductCode: ' + instance.ProductCode);
                System.debug('ProductUrl: /lightning/r/Product2/' + instance.ProductId + '/view');
                
                wrapperList.add(instance);
            }
        } catch (Exception e) {
            system.debug('에러 내역 :::: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return wrapperList;
    }

    @AuraEnabled
    public static void deletePMHistory(String recordId){
        ProductionManagementHistory__c instance = new ProductionManagementHistory__c();
        System.debug('recordId 대해 == ' + recordId);
        instance.Id = recordId;
        System.debug('instance에 대해 == ' + instance);
        delete instance;
    }

    @AuraEnabled
    public static String upsertRequestProduct(List<ChargingPartWrapper> requestProductList, String caseId) {
        List<ProductionManagementHistory__c> rpUpsertList = new List<ProductionManagementHistory__c>();
        for (ChargingPartWrapper cpw : requestProductList) {
            ProductionManagementHistory__c pmh = new ProductionManagementHistory__c();
            
            pmh.Product__c = cpw.ProductId;             // 품목 ID
            pmh.Quantity__c = cpw.PartAmount;           // 수량
            pmh.Ticket__c = caseId;                     // 관련 Case ID (Ticket__c)

            rpUpsertList.add(pmh);
        }
        
        if (!rpUpsertList.isEmpty()) {
            upsert rpUpsertList;
        }
        
        return 'SUCCESS';
    }

    @AuraEnabled
    public static Product2 getProductDetails(String productId) {
        System.debug('getProductDetails called with productId: ' + productId);
        try {
            if(String.isBlank(productId)) {
                return null;
            }
            List<Product2> products = [
                SELECT Id, ProductCode, Name, FM_MaterialDetails__c
                FROM Product2 
                WHERE Id = :productId
                LIMIT 1
            ];
            return !products.isEmpty() ? products[0] : null;
        } catch (Exception e) {
            System.debug('getProductDetails error: ' + e.getMessage());
            return null;
        }
    }


    public class ChargingPartWrapper{
        @AuraEnabled public String ProductRequestRecordId           { get;set; }    //레코드 ID
        @AuraEnabled public String ProductId                        { get;set; }    //품목 ID
        @AuraEnabled public String ProductName                      { get;set; }    //품명
        @AuraEnabled public String ProductCode                      { get;set; }    //품번
        @AuraEnabled public Integer PartAmount                      { get;set; }    //수량
    }
}