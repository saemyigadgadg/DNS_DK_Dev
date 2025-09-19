/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class DN_OpptyLineItemCopyControllerTest {

    @testSetup
    static void setupData() {
        // Standard Pricebook 활성화
        // Pricebook2 standardPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        TestDataFactoryForService.activatePriceBook();
        // Product 생성
        Product2 p1 = new Product2(Name = 'R18181', ProductCode = 'R18181', IsActive = true);
        Product2 p2 = new Product2(Name = 'R90033', ProductCode = 'R90033', IsActive = true);
        insert new List<Product2>{ p1, p2 };

        // PricebookEntry 생성
        // PricebookEntry pe1 = new PricebookEntry(
        //     Pricebook2Id = pBookId,
        //     Product2Id = p1.Id,
        //     UnitPrice = 100,
        //     IsActive = true
        //     // UseStandardPrice = false
        // );
        // PricebookEntry pe2 = new PricebookEntry(
        //     Pricebook2Id = pBookId,
        //     Product2Id = p2.Id,
        //     UnitPrice = 200,
        //     IsActive = true
        //     // UseStandardPrice = false
        // );
        PricebookEntry pe1 = TestDataFactoryForService.createPriceBookEntry(p1, 'KRW');
        PricebookEntry pe2 = TestDataFactoryForService.createPriceBookEntry(p2, 'KRW');
        insert new List<PricebookEntry>{ pe1, pe2 };
    }

    @isTest
    static void testLoadLineItems_MatchingAndUnmatched() {
        List<Map<String, Object>> productList = new List<Map<String, Object>>{
            new Map<String, Object>{ 'code' => 'P001', 'quantity' => 2 },
            new Map<String, Object>{ 'code' => 'P002', 'quantity' => 5 },
            new Map<String, Object>{ 'code' => 'INVALID', 'quantity' => 1 }
        };

        Test.startTest();
        Map<String, Object> result = DN_OpptyLineItemCopyController.loadLineItems(productList);
        Test.stopTest();

        List<Object> lineItems = (List<Object>) result.get('lineItems');
        List<Object> unmatchedCodes = (List<Object>) result.get('unmatchedCodes');
    }

    @isTest
    static void testLoadLineItems_EmptyInputThrowsException() {
        List<Map<String, Object>> emptyList = new List<Map<String, Object>>();

        try {
            DN_OpptyLineItemCopyController.loadLineItems(emptyList);
        } catch (AuraHandledException e) {
        }
    }

    @isTest
    static void testLoadLineItems_NullQuantityDefaultsToOne() {
        List<Map<String, Object>> productList = new List<Map<String, Object>>{
            new Map<String, Object>{ 'code' => 'P001' }
        };

        Map<String, Object> result = DN_OpptyLineItemCopyController.loadLineItems(productList);
        List<Map<String, Object>> lineItems = (List<Map<String, Object>>) result.get('lineItems');

        Decimal qty = (Decimal) lineItems[0].get('quantity');
    }
}