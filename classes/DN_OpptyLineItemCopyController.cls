/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 06-02-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class DN_OpptyLineItemCopyController {

    // 중복 확인 안하는 메서드
    @AuraEnabled
    public static Map<String, Object> loadLineItems(List<Map<String, Object>> productList) {
        if (productList == null || productList.isEmpty()) {
            throw new AuraHandledException('No data.');
        }

        List<String> productCodes = new List<String>();
        for (Map<String, Object> product : productList) {
            String productCode = (String) product.get('code');
            if (!String.isBlank(productCode)) {
                productCodes.add(productCode);
            }
        }

        Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();
        List<PricebookEntry> pricebookEntries = [
            SELECT Id, Product2.Id, Product2.Name, Product2.ProductCode
            FROM PricebookEntry
            WHERE Product2.ProductCode IN :productCodes
            AND IsActive = true
        ];

        for (PricebookEntry entry : pricebookEntries) {
            pricebookEntryMap.put(entry.Product2.ProductCode, entry);
        }

        // 결과를 저장할 리스트
        List<Map<String, Object>> lineItems = new List<Map<String, Object>>();
        List<String> unmatchedCodes = new List<String>();

        for (Map<String, Object> product : productList) {
            String productCode = (String) product.get('code');
            Decimal quantity = (Decimal) product.get('quantity');

            if (!String.isBlank(productCode)) {
                Map<String, Object> lineItem = new Map<String, Object>();

                if (pricebookEntryMap.containsKey(productCode)) {
                    PricebookEntry matchedEntry = pricebookEntryMap.get(productCode);
                    lineItem.put('productName', matchedEntry.Product2.Name);
                    lineItem.put('pricebookEntryId', matchedEntry.Id);
                    lineItem.put('ProductId', matchedEntry.Product2.Id);
                    lineItem.put('ProductCode', matchedEntry.Product2.Name);

                } else {
                    lineItem.put('productName', productCode);
                    unmatchedCodes.add(productCode);
                }

                lineItem.put('quantity', quantity != null ? quantity : 1);
                lineItems.add(lineItem);
            }
        }

        // 결과 반환
        Map<String, Object> result = new Map<String, Object>();
        result.put('lineItems', lineItems);
        result.put('unmatchedCodes', unmatchedCodes);

        System.debug('lineItems:::' + lineItems);
        System.debug('unmatchedCodes:::' + unmatchedCodes);
        System.debug('result:::' + result);

        return result;
    }

    // 중복 확인하고 중복 삭제하는 코드
    // @AuraEnabled
    // public static Map<String, Object> loadLineItems(List<Map<String, Object>> productList) {
    //     if (productList == null || productList.isEmpty()) {
    //         throw new AuraHandledException('No data.');
    //     }
    
    //     Set<String> copyProductCodes = new Set<String>();
    //     Map<String, Decimal> productQuantities = new Map<String, Decimal>();
    
    //     for (Map<String, Object> product : productList) {
    //         String productCode = (String) product.get('code');
    //         Decimal quantity = (Decimal) product.get('quantity');
    
    //         if (!String.isBlank(productCode)) {
    //             copyProductCodes.add(productCode);
    //             productQuantities.put(productCode, quantity != null ? quantity : 1);
    //             // productQuantities.put() 대신 +=하면 중복값 수량 합계 
    //         }
    //     }
    
    //     // PricebookEntry에서 제품 정보 조회
    //     Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();
    //     List<PricebookEntry> pricebookEntries = [
    //         SELECT Id, Product2.Name, Product2.ProductCode
    //         FROM PricebookEntry
    //         WHERE Product2.ProductCode IN :copyProductCodes
    //         AND IsActive = TRUE
    //     ];
    
    //     for (PricebookEntry entry : pricebookEntries) {
    //         pricebookEntryMap.put(entry.Product2.ProductCode, entry);
    //     }
    
    //     List<Map<String, Object>> lineItems = new List<Map<String, Object>>();
    //     List<String> unmatchedCodes = new List<String>();
    
    //     for (String productCode : copyProductCodes) {
    //         if (pricebookEntryMap.containsKey(productCode)) {
    //             PricebookEntry matchedEntry = pricebookEntryMap.get(productCode);
    //             Map<String, Object> lineItem = new Map<String, Object>();
    //             lineItem.put('productName', matchedEntry.Product2.Name);
    //             lineItem.put('pricebookEntryId', matchedEntry.Id);
    //             lineItem.put('quantity', productQuantities.get(productCode));
    //             lineItems.add(lineItem);
    //         } else {
    //             unmatchedCodes.add(productCode);
    //         }
    //     }
    
    //     // 결과 반환
    //     Map<String, Object> result = new Map<String, Object>();
    //     result.put('lineItems', lineItems);
    //     result.put('unmatchedCodes', unmatchedCodes);
    
    //     System.debug('lineItems:::' + lineItems);
    //     System.debug('unmatchedCodes:::' + unmatchedCodes);
    //     System.debug('result:::' + result);
    
    //     return result;
    // }

    // @AuraEnabled
    // public static void saveLineItems(List<Map<String, Object>> lineItems, String recordId) {
    //     System.debug('recordId:::' + recordId);
    //     System.debug('Received lineItems:::' + lineItems);
    
    //     // if (lineItems.isEmpty()) {
    //     //     throw new AuraHandledException('No line items to save.');
    //     // }
    
    //     // Opportunity 정보 조회
    //     Opportunity opp = [SELECT Id, CurrencyIsoCode, Pricebook2Id FROM Opportunity WHERE Id = :recordId LIMIT 1];
    
    //     // if (opp == null) {
    //     //     throw new AuraHandledException('Invalid Opportunity ID.');
    //     // }
    
    //     System.debug('Opportunity CurrencyIsoCode:::' + opp.CurrencyIsoCode);
    //     System.debug('Opportunity Pricebook2Id:::' + opp.Pricebook2Id);
    
    //     // PricebookEntryId 목록 수집
    //     Set<String> pricebookEntryIds = new Set<String>();
    //     for (Map<String, Object> lineItem : lineItems) {
    //         if (lineItem.containsKey('pricebookEntryId')) {
    //             pricebookEntryIds.add((String) lineItem.get('pricebookEntryId'));
    //         }
    //     }
    
    //     // PricebookEntry 조회 (기존의 통화 코드가 다른 경우도 포함)
    //     Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();
    //     Map<String, String> productToPricebookEntryMap = new Map<String, String>(); // Product2Id -> PricebookEntryId 매핑
    
    //     for (PricebookEntry pbe : [
    //         SELECT Id, CurrencyIsoCode, Pricebook2Id, Product2Id
    //         FROM PricebookEntry
    //         WHERE Id IN :pricebookEntryIds
    //     ]) {
    //         pricebookEntryMap.put(pbe.Id, pbe);
    //         productToPricebookEntryMap.put(pbe.Product2Id, pbe.Id); // Product2Id 기준으로 저장
    //     }
    
    //     // 같은 제품(Product2Id)에서 Opportunity의 CurrencyIsoCode와 일치하는 PricebookEntry 조회
    //     Map<String, String> alternativePricebookEntryMap = new Map<String, String>();
    
    //     for (PricebookEntry pbe : [
    //         SELECT Id, CurrencyIsoCode, Pricebook2Id, Product2Id
    //         FROM PricebookEntry
    //         WHERE Product2Id IN :productToPricebookEntryMap.keySet() 
    //               AND CurrencyIsoCode = :opp.CurrencyIsoCode 
    //               AND Pricebook2Id = :opp.Pricebook2Id
    //     ]) {
    //         alternativePricebookEntryMap.put(pbe.Product2Id, pbe.Id); // 올바른 통화 코드의 PricebookEntry 저장
    //     }
    
    //     // OpportunityLineItem 생성
    //     List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
    
    //     for (Map<String, Object> lineItem : lineItems) {
    //         String pricebookEntryId = (String) lineItem.get('pricebookEntryId');
    //         PricebookEntry pbe = pricebookEntryMap.get(pricebookEntryId);
    //         System.debug('pricebookEntryId:::'+pricebookEntryId);
    
    //         // 통화 코드가 다른 경우 대체할 PricebookEntry 찾기
    //         if (pbe != null && pbe.CurrencyIsoCode != opp.CurrencyIsoCode) {
    //             if (alternativePricebookEntryMap.containsKey(pbe.Product2Id)) {
    //                 System.debug('통화 코드 불일치로 대체 PricebookEntry 사용: ' + alternativePricebookEntryMap.get(pbe.Product2Id));
    //                 pricebookEntryId = alternativePricebookEntryMap.get(pbe.Product2Id);
    //             } else {
    //                 System.debug('PricebookEntry 통화 코드가 Opportunity 통화 코드와 일치하지 않습니다.');
    //                 throw new AuraHandledException('PricebookEntry 통화 코드가 Opportunity 통화 코드와 일치하지 않습니다.');
    //             }
    //         }
    
    //         OpportunityLineItem oli = new OpportunityLineItem();
    //         oli.OpportunityId = recordId;
    //         oli.PricebookEntryId = pricebookEntryId;
    //         oli.Quantity = (lineItem.get('quantity') != null) ? Decimal.valueOf(String.valueOf(lineItem.get('quantity'))) : null;            
    //         oli.UnitPrice = (lineItem.get('UnitPrice') != null) ? Integer.valueOf(String.valueOf(lineItem.get('UnitPrice'))) : null;            
    //         oli.CSTotalPrice__c = (lineItem.get('Amount') != null) ? Integer.valueOf(String.valueOf(lineItem.get('Amount'))) : null;            
    //         oli.Description = lineItem.containsKey('description') ? (String)lineItem.get('description') : null;
    //         oli.SupplyProduct__c = (String)lineItem.get('SupplyProduct');
    //         oli.OptyProdCurrency__c = (String)lineItem.get('OptyProdCurrency');
    //         // 자동 계산됨
    //         oli.AvailableStock__c = (String)(lineItem.get('AvailableStock'));
    //         oli.Unit__c = (String)lineItem.get('Unit');
    //         // 최종 디버깅
    //         System.debug('oli:::' + oli);
            
    
    //         // 수량 확인 및 디버깅
    //         // System.debug('Quantity before casting:::' + lineItem.get('quantity'));
    //         // oli.Quantity = (lineItem.get('quantity') != null) ? Decimal.valueOf(String.valueOf(lineItem.get('quantity'))) : null;
    //         // System.debug('Quantity after casting:::' + oli.Quantity);
    
    //         // // 가격 확인 및 디버깅
    //         // System.debug('Expected Price before casting:::' + lineItem.get('UnitPrice'));
    //         // oli.UnitPrice = (lineItem.get('UnitPrice') != null) ? Decimal.valueOf(String.valueOf(lineItem.get('UnitPrice'))) : null;
    //         // System.debug('Expected Price after casting:::' + oli.UnitPrice);
    
    //         // oli.Description = lineItem.containsKey('description') ? (String)lineItem.get('description') : null;
    //         // System.debug('lineItem:::' + lineItem);
    
    //         opportunityLineItems.add(oli);
    //     }
    
    //     // 최종 Insert 실행
    //     insert opportunityLineItems;
    // }

    // @AuraEnabled
    // public static void saveQuoteLineItems(List<Map<String, Object>> lineItems, String recordId) {
    //     System.debug('recordId:::' + recordId);
    //     System.debug('Received lineItems:::' + lineItems);

    //     Quote quote = [SELECT Id, CurrencyIsoCode, Pricebook2Id FROM Quote WHERE Id = :recordId LIMIT 1];
    
    //     System.debug('Quote CurrencyIsoCode:::' + quote.CurrencyIsoCode);
    //     System.debug('Quote Pricebook2Id:::' + quote.Pricebook2Id);
    
    //     // PricebookEntryId 목록 수집
    //     Set<String> pricebookEntryIds = new Set<String>();
    //     for (Map<String, Object> lineItem : lineItems) {
    //         if (lineItem.containsKey('pricebookEntryId')) {
    //             pricebookEntryIds.add((String) lineItem.get('pricebookEntryId'));
    //         }
    //     }
    
    //     // PricebookEntry 조회 (기존의 통화 코드가 다른 경우도 포함)
    //     Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();
    //     Map<String, String> productToPricebookEntryMap = new Map<String, String>(); // Product2Id -> PricebookEntryId 매핑
    
    //     for (PricebookEntry pbe : [
    //         SELECT Id, CurrencyIsoCode, Pricebook2Id, Product2Id
    //         FROM PricebookEntry
    //         WHERE Id IN :pricebookEntryIds
    //     ]) {
    //         pricebookEntryMap.put(pbe.Id, pbe);
    //         productToPricebookEntryMap.put(pbe.Product2Id, pbe.Id); // Product2Id 기준으로 저장
    //     }
    
    //     // 같은 제품(Product2Id)에서 Opportunity의 CurrencyIsoCode와 일치하는 PricebookEntry 조회
    //     Map<String, String> alternativePricebookEntryMap = new Map<String, String>();
    
    //     for (PricebookEntry pbe : [
    //         SELECT Id, CurrencyIsoCode, Pricebook2Id, Product2Id
    //         FROM PricebookEntry
    //         WHERE Product2Id IN :productToPricebookEntryMap.keySet() 
    //               AND CurrencyIsoCode = :quote.CurrencyIsoCode 
    //               AND Pricebook2Id = :quote.Pricebook2Id
    //     ]) {
    //         alternativePricebookEntryMap.put(pbe.Product2Id, pbe.Id); // 올바른 통화 코드의 PricebookEntry 저장
    //     }
    
    //     // QuoteLineItem 생성
    //     List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
    
    //     for (Map<String, Object> lineItem : lineItems) {
    //         String pricebookEntryId = (String) lineItem.get('pricebookEntryId');
    //         PricebookEntry pbe = pricebookEntryMap.get(pricebookEntryId);
    
    //         // 통화 코드가 다른 경우 대체할 PricebookEntry 찾기
    //         if (pbe != null && pbe.CurrencyIsoCode != quote.CurrencyIsoCode) {
    //             if (alternativePricebookEntryMap.containsKey(pbe.Product2Id)) {
    //                 System.debug('통화 코드 불일치로 대체 PricebookEntry 사용: ' + alternativePricebookEntryMap.get(pbe.Product2Id));
    //                 pricebookEntryId = alternativePricebookEntryMap.get(pbe.Product2Id);
    //             } else {
    //                 throw new AuraHandledException('PricebookEntry 통화 코드가 Quote 통화 코드와 일치하지 않습니다.');
    //             }
    //         }
    
    //         QuoteLineItem qli = new QuoteLineItem();
    //         qli.QuoteId = recordId;
    //         qli.PricebookEntryId = pricebookEntryId;
    //         qli.Quantity = (lineItem.get('quantity') != null) ? Decimal.valueOf(String.valueOf(lineItem.get('quantity'))) : null;            
    //         qli.UnitPrice = (lineItem.get('UnitPrice') != null) ? Integer.valueOf(String.valueOf(lineItem.get('UnitPrice'))) : null;            
    //         qli.CSTotalPrice__c = (lineItem.get('Amount') != null) ? Integer.valueOf(String.valueOf(lineItem.get('Amount'))) : null;            
    //         qli.Description = lineItem.containsKey('description') ? (String)lineItem.get('description') : null;
    //         qli.SupplyProduct__c = (String)lineItem.get('SupplyProduct');
    //         qli.QuoteProdCurrency__c = (String)lineItem.get('QuoteProdCurrency');
    //         // 자동 계산됨
    //         qli.AvailableStock__c = (String)(lineItem.get('AvailableStock'));
    //         qli.Unit__c = (String)lineItem.get('Unit');
    //         // 최종 디버깅
    //         System.debug('qli:::' + qli);

    //         quoteLineItems.add(qli);
    //     }
    
    //     // 최종 Insert 실행
    //     insert quoteLineItems;
    // }
}