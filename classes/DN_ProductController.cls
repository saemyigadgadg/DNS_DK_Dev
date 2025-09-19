/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class DN_ProductController {
    // 제품 검색 메서드
    @AuraEnabled
    public static List<Product2> searchProducts(String searchKey, String filter) {
        String query = 'SELECT Id, Name, ProductSpec__c, ProductCode FROM Product2 WHERE ';
        String likeKey = '%' + searchKey + '%';

        if (filter == 'productNumber') {
            query += 'ProductCode LIKE :likeKey';
        } else if (filter == 'productName') {
            query += 'Name LIKE :likeKey';
        } else if (filter == 'productSpec') {
            query += 'ProductSpec__c LIKE :likeKey';
        }

        return Database.query(query);
    }

    // 제품 상세 정보 메서드
    @AuraEnabled
    public static Product2 getProductDetails(Id productId) {
        return [
            // 품번, 품명, 대체품, 재질, 규격, 단위, 중량, 중량단위, 납품포장 RKWUDHKDIEHLA
            SELECT Name, ProductCode
            FROM Product2 
            WHERE Id = :productId
            LIMIT 1
        ];
    }
    
    // @AuraEnabled
    // public static List<ProductRequest> getPartRequests() {
    //     return [SELECT Id FROM ProductRequest];
    // }
    
    // @AuraEnabled
    // public static void savePartRequest(ProductRequest[] partRequests) {
    //     upsert partRequests;
    // }
}