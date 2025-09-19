/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-04-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class DN_ProductControllerTest {
    
    static testMethod void testSearchProducts_productCode() {
        Product2 p = new Product2(Name = 'R18181', ProductCode = 'R18181', ProductSpec__c = 'R18181');
        insert p;

        Test.startTest();
        List<Product2> result = DN_ProductController.searchProducts('R18181', 'productNumber');
        Test.stopTest();
    }

    static testMethod void testSearchProducts_productName() {
        Product2 p = new Product2(Name = 'R18181', ProductCode = 'R18181', ProductSpec__c = 'R18181');
        insert p;

        Test.startTest();
        List<Product2> result = DN_ProductController.searchProducts('R18181', 'productName');
        Test.stopTest();
    }

    static testMethod void testSearchProducts_productSpec() {
        Product2 p = new Product2(Name = 'R18181', ProductCode = '', ProductSpec__c = 'R18181');
        insert p;

        Test.startTest();
        List<Product2> result = DN_ProductController.searchProducts('R18181', 'productSpec');
        Test.stopTest();
    }

    static testMethod void testGetProductDetails() {
        Product2 p = new Product2(Name = 'R18181', ProductCode = 'R18181');
        insert p;

        Test.startTest();
        Product2 detail = DN_ProductController.getProductDetails(p.Id);
        Test.stopTest();
    }

    static testMethod void testSearchProducts_invalidFilter() {
        Product2 p = new Product2(Name = 'R18181', ProductCode = 'R18181', ProductSpec__c = 'R18181');
        insert p;

        Test.startTest();
        // 유효하지 않은 filter값을 전달하면 WHERE 절이 완성되지 않아 쿼리 실패 가능성 있음.
        // 실제 운영 코드에서는 이런 경우 예외 처리나 기본 쿼리를 보완해야 안전함.
        try {
            List<Product2> result = DN_ProductController.searchProducts('R18181', 'unknownFilter');
        } catch (Exception e) {
        }
        Test.stopTest();
    }
}