/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/

public with sharing class DN_OptyLineItemListController {
    // Opportunity Line Item에 대한 Wrapper class
    @AuraEnabled
    public static List<OptyLineItemWrapper> getOptyLI(String opportunityId) {
        try {
            String objectType = Id.valueOf(opportunityId).getSObjectType().getDescribe().getName();
            System.debug('objectType ::: ' + objectType);
            
            List<OptyLineItemWrapper> wrapperList = new List<OptyLineItemWrapper>();
    
            if (objectType == 'Opportunity') {
                List<OpportunityLineItem> optyLineItems = [
                    SELECT Id, Name, Product2Id, ProductCode, Quantity, UnitPrice, Description, 
                           Unit__c, PricebookEntryId, OpportunityId, Product2.Name, TotalPrice, ListPrice__c,
                           OptyProdCurrency__c, SupplyProduct__c, AvailableStock__c, CSTotalPrice__c, ProductName__c
                    FROM OpportunityLineItem
                    WHERE OpportunityId = :opportunityId
                ];
    
                for (OpportunityLineItem oli : optyLineItems) {
                    OptyLineItemWrapper wrapper = new OptyLineItemWrapper();
                    wrapper.OptyLineItemId = oli.Id;
                    wrapper.ProductId = oli.Product2Id;
                    // wrapper.ProductName = oli.Product2.Name;
                    wrapper.ProductName = oli.ProductName__c;
                    wrapper.ProductCode = oli.ProductCode;
                    wrapper.Quantity = oli.Quantity;
                    wrapper.UnitPrice = oli.UnitPrice;
                    wrapper.ListPrice = oli.ListPrice__c;
                    wrapper.Description = oli.Description;
                    wrapper.Unit = oli.Unit__c;
                    wrapper.SupplyProduct = oli.SupplyProduct__c;
                    wrapper.AvailableStock = oli.AvailableStock__c;
                    wrapper.OptyProdCurrency = oli.OptyProdCurrency__c;
                    wrapper.PricebookEntryId = oli.PricebookEntryId;
                    wrapper.Amount = String.valueOf(oli.CSTotalPrice__c);
                    wrapper.isApproved = true;
                    
                    if (oli.Product2.Name == 'CS_MT_MAT' || oli.Product2.Name == 'CS_MT_SVC') {
                        wrapper.isCustom = true;
                    }
    
                    wrapperList.add(wrapper);
                }
            }
            return wrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Quote Line Item에 대한 Wrapper class
    @AuraEnabled
    public static List<QuoteLineItemWrapper> getQuoteLI(String quoteId) {
        try {
            String objectType = Id.valueOf(quoteId).getSObjectType().getDescribe().getName();
            System.debug('objectType ::: ' + objectType);
            
            List<QuoteLineItemWrapper> quotewrapperList = new List<QuoteLineItemWrapper>();

            if (objectType == 'Quote') {
                List<QuoteLineItem> quoteLineItems = [
                    SELECT Id, QuoteId, Product2Id, ProductCode__c, Quantity, UnitPrice, Description, isManualAmount__c, isManualDiscount__c,
                           Unit__c, PricebookEntryId, Product2.Name, TotalPrice, ProductName__c,
                           QuoteProdCurrency__c, SupplyProduct__c, AvailableStock__c, Discount__c, CSTotalPrice__c, ListPrice__c
                    FROM QuoteLineItem
                    WHERE QuoteId = :quoteId
                ];
    
                for (QuoteLineItem qli : quoteLineItems) {
                    QuoteLineItemWrapper quoteWrapper = new QuoteLineItemWrapper();
                    quoteWrapper.QuoteLineItemId = qli.Id;
                    quoteWrapper.ProductId = qli.Product2Id;
                    quoteWrapper.ProductName = qli.ProductName__c;
                    quoteWrapper.ProductCode = qli.ProductCode__c;
                    quoteWrapper.Quantity = qli.Quantity;
                    quoteWrapper.UnitPrice = qli.UnitPrice;
                    quoteWrapper.ListPrice = qli.ListPrice__c;
                    quoteWrapper.Description = qli.Description;
                    quoteWrapper.Unit = qli.Unit__c;
                    quoteWrapper.Discount = qli.Discount__c;
                    quoteWrapper.isManualAmount = qli.isManualAmount__c;
                    quoteWrapper.isManualDiscount = qli.isManualDiscount__c;
                    quoteWrapper.SupplyProduct = qli.SupplyProduct__c;
                    quoteWrapper.AvailableStock = qli.AvailableStock__c;
                    quoteWrapper.QuoteProdCurrency = qli.QuoteProdCurrency__c;
                    quoteWrapper.PricebookEntryId = qli.PricebookEntryId;
                    quoteWrapper.Amount = String.valueOf(qli.CSTotalPrice__c);
                    quoteWrapper.isApproved = true;
                    
                    if (qli.Product2.Name == 'CS_MT_MAT' || qli.Product2.Name == 'CS_MT_SVC') {
                        quoteWrapper.isCustom = true;
                    }
    
                    quotewrapperList.add(quoteWrapper);
                }
            }
            return quotewrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Discount__c 필드 값을 가져오는 메서드
    @AuraEnabled()
    public static Decimal getQuoteDiscount(Id quoteId) {
        Quote q = [SELECT Discount__c FROM Quote WHERE Id = :quoteId LIMIT 1];
        return q.Discount__c != null ? q.Discount__c : 0;
    }

    // Opportunity 제품 가격을 가져오는 I/F 메서드
    @AuraEnabled
    public static String getProductPrice(String opportunityId, List<String> partNumbers, List<String> partNames) {
        try {
            System.debug('==> Start getProductPrice');

            Opportunity opty = [
                SELECT Id, Name, OwnerId, Account.CustomerCode__c
                FROM Opportunity WHERE Id = :opportunityId
                LIMIT 1
            ];
            System.debug('opty:::' + opty); 

            System.debug('OpportunityId:::' + opportunityId);
            System.debug('PartNumbers:::' + partNumbers);
            System.debug('partNames:::' + partNames);
    
            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req();
            req.LV_AUART = 'YDOR';
            req.I_LANGU = 'KR';
            req.I_USERID = 'MKRP0024';
    
            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_I_USERINFO();
            I_USERINFO.BNAME = opty.OwnerId;
            I_USERINFO.KUNNR = opty.Account.CustomerCode__c;
            I_USERINFO.VKORG = '1846';
            I_USERINFO.VTWEG = '10';
            I_USERINFO.SPART = '40';
            I_USERINFO.LAND1 = 'KR';
            req.I_USERINFO = I_USERINFO;
            System.debug('I_USERINFO:::' + I_USERINFO);

            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_MAIN_HEAD LS_MAIN_HEAD = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_MAIN_HEAD();
            LS_MAIN_HEAD.KONDA              = '28';
            LS_MAIN_HEAD.KUNNR              = opty.Account.CustomerCode__c;
            LS_MAIN_HEAD.KUNAG              = opty.Account.CustomerCode__c;
            // LS_MAIN_HEAD.NETWR              = '0.00';
            // LS_MAIN_HEAD.CREDIT             = '0.00';
            // LS_MAIN_HEAD.TOTAL_WEIGHT       = '0.000';
            // LS_MAIN_HEAD.VOLUM              = '0.000';
            // LS_MAIN_HEAD.KVGR5              = '40';
        
            req.LS_MAIN_HEAD                = LS_MAIN_HEAD;

            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_ERROR_IGNORE LS_ERROR_IGNORE = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_ERROR_IGNORE();
            LS_ERROR_IGNORE.IGNORE              = 'X';
            LS_ERROR_IGNORE.IGNORE_QTY          = 'X';
            LS_ERROR_IGNORE.IGNORE_PRICE        = 'X';
            LS_ERROR_IGNORE.IGNORE_DIVISION     = 'X';
            LS_ERROR_IGNORE.IGNORE_PURCHASE     = 'X';
        
            req.LS_ERROR_IGNORE                 = LS_ERROR_IGNORE;
    
            List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM> ltItemList = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM>();

            for (Integer i = 0; i < partNames.size(); i++) {
                IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM item = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM();
            
                String partNumber = partNumbers[i];
                String itemValue = String.valueOf(Integer.valueOf(partNumber));
                item.ITEM = itemValue;
                item.MATERIAL = partNames[i];
                item.QTY = '1.000';
            
                ltItemList.add(item);
                System.debug('Added Item: ' + item);
            }
            req.LT_ITEM = ltItemList;
            System.debug('Request Items: ' + ltItemList);
    
            IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res response = instance.IF_PARTS_003(req);
            System.debug('Response received from IF_PARTS_003.');
    
            // 결과 데이터 추출 및 변환
            List<Map<String, Object>> resultData = new List<Map<String, Object>>();
            for (IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_ITEM responseItem : response.LT_ITEM) {
                System.debug('Response Item: ' + responseItem);
                resultData.add(new Map<String, Object>{
                    'MATERIAL' => responseItem.MATERIAL,
                    'NET_PRICE' => responseItem.NET_PRICE,
                    'AVAILABILITY' => responseItem.AVAILABILITY,
                    'IF_CURRENCY' => responseItem.IF_CURRENCY,
                    'AVAIL_QTY1' => responseItem.AVAIL_QTY1,
                    'MATERIAL_TEXT' => responseItem.MATERIAL_TEXT,
                    'UOM' => responseItem.UOM,
                    'MATERIAL_ENT' => responseItem.MATERIAL_ENT
                });
            }
            System.debug('Result Data: ' + resultData);
    
            return JSON.serialize(resultData);
        } catch (Exception e) {
            System.debug('Exception occurred in getProductPrice: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Quote 제품 가격을 가져오는 I/F 메서드
    @AuraEnabled
    public static String getQuoteProductPrice(String quoteId, List<String> partNumbers, List<String> partNames) {
        try {
            System.debug('==> Start getQuoteProductPrice');

            Quote quote = [
                SELECT Id, Name, OwnerId, Account.CustomerCode__c
                FROM Quote WHERE Id = :quoteId
                LIMIT 1
            ];
            System.debug('quote:::' + quote); 

            System.debug('quoteId:::' + quoteId);
            System.debug('PartNumbers:::' + partNumbers);
            System.debug('partNames:::' + partNames);
    
            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req();
            req.LV_AUART = 'YDOR';
            req.I_LANGU = 'KR';
            req.I_USERID = 'MKRP0024';
    
            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_I_USERINFO();
            I_USERINFO.BNAME = quote.OwnerId;
            I_USERINFO.KUNNR = quote.Account.CustomerCode__c;
            I_USERINFO.VKORG = '1846';
            I_USERINFO.VTWEG = '10';
            I_USERINFO.SPART = '40';
            I_USERINFO.LAND1 = 'KR';
            req.I_USERINFO = I_USERINFO;
            System.debug('I_USERINFO:::' + I_USERINFO);

            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_MAIN_HEAD LS_MAIN_HEAD = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_MAIN_HEAD();
            LS_MAIN_HEAD.KONDA              = '28';
            LS_MAIN_HEAD.KUNNR              = quote.Account.CustomerCode__c;
            LS_MAIN_HEAD.KUNAG              = quote.Account.CustomerCode__c;
            // LS_MAIN_HEAD.NETWR              = '0.00';
            // LS_MAIN_HEAD.CREDIT             = '0.00';
            // LS_MAIN_HEAD.TOTAL_WEIGHT       = '0.000';
            // LS_MAIN_HEAD.VOLUM              = '0.000';
            // LS_MAIN_HEAD.KVGR5              = '40';
        
            req.LS_MAIN_HEAD                = LS_MAIN_HEAD;

            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_ERROR_IGNORE LS_ERROR_IGNORE = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LS_ERROR_IGNORE();
            LS_ERROR_IGNORE.IGNORE              = 'X';
            LS_ERROR_IGNORE.IGNORE_QTY          = 'X';
            LS_ERROR_IGNORE.IGNORE_PRICE        = 'X';
            LS_ERROR_IGNORE.IGNORE_DIVISION     = 'X';
            LS_ERROR_IGNORE.IGNORE_PURCHASE     = 'X';
        
            req.LS_ERROR_IGNORE                 = LS_ERROR_IGNORE;
    
            List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM> ltItemList = new List<IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM>();

            for (Integer i = 0; i < partNames.size(); i++) {
                IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM item = new IF_ERP_Parts_Order_Classes.IF_PARTS_003_Req_LT_ITEM();
            
                String partNumber = partNumbers[i];
                String itemValue = String.valueOf(Integer.valueOf(partNumber));
                item.ITEM = itemValue;
                item.MATERIAL = partNames[i];
                item.QTY = '1.000';
            
                ltItemList.add(item);
                System.debug('Added Item: ' + item);
            }
            req.LT_ITEM = ltItemList;
            System.debug('Request Items: ' + ltItemList);
    
            IF_ERP_Parts_Order instance = new IF_ERP_Parts_Order();
            IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res response = instance.IF_PARTS_003(req);
            System.debug('Response received from IF_PARTS_003.');
    
            // 결과 데이터 추출 및 변환
            List<Map<String, Object>> resultData = new List<Map<String, Object>>();
            for (IF_ERP_Parts_Order_Classes.IF_PARTS_003_Res_LT_ITEM responseItem : response.LT_ITEM) {
                System.debug('Response Item: ' + responseItem);
                resultData.add(new Map<String, Object>{
                    'MATERIAL' => responseItem.MATERIAL,
                    'NET_PRICE' => responseItem.NET_PRICE,
                    'AVAILABILITY' => responseItem.AVAILABILITY,
                    'IF_CURRENCY' => responseItem.IF_CURRENCY,
                    'AVAIL_QTY1' => responseItem.AVAIL_QTY1,
                    'MATERIAL_TEXT' => responseItem.MATERIAL_TEXT,
                    'UOM' => responseItem.UOM,
                    'MATERIAL_ENT' => responseItem.MATERIAL_ENT
                });
            }
            System.debug('Result Data: ' + resultData);
    
            return JSON.serialize(resultData);
        } catch (Exception e) {
            System.debug('Exception occurred in getQuoteProductPrice: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // 제품을 가져오는 메서드
    @AuraEnabled
    public static Product2 getProduct(String productId) {
        try {
            return [
                SELECT Id, Name, Unit__c,
                       (SELECT Id, Pricebook2.Name, UnitPrice, CurrencyIsoCode
                        FROM PricebookEntries)
                FROM Product2
                WHERE Id = :productId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // GPES를 이용하여 제품을 가져오는 메서드
    @AuraEnabled
    public static EventPartsResultWrapper getGPESProduct(List<Object> eventParts){
        EventPartsResultWrapper result = new EventPartsResultWrapper();
        try {
            List<EventPartsWrapper> resultEPWList = new List<EventPartsWrapper>();

            Map<String, Object> eventPartMap = new Map<String, Object>();
            Set<String> partNos = new Set<String>();
            for (Object obj : eventParts) {
                String tempJson = JSON.serialize(obj);
                Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(tempJson);
                String code = String.valueOf(objMap.get('partNo'));
                partNos.add(code);
                eventPartMap.put(code, obj);
            }

            List<Product2> productList = [SELECT Id, ProductCode, FM_MaterialDetails__c, Unit__c FROM Product2 WHERE ProductCode IN :partNos];

            if (!productList.isEmpty()) {
                
                Map<String, Product2> productMap = new Map<String, Product2>();
                Set<String> productIds = new Set<String>();
                
                for (Product2 product : productList) {
                    productMap.put(product.ProductCode, product);
                    productIds.add(product.Id);
                }
    
                List<PricebookEntry> entryList = [SELECT Id, Name, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :productIds];
                Map<String, PricebookEntry> entryMap = new Map<String, PricebookEntry>();
    
                for (PricebookEntry entry : entryList) {
                    entryMap.put(entry.Product2Id, entry);
                }
    
                Set<String> noCodeCrm = new Set<String>();
    
                for (String key : eventPartMap.keySet()) {
                    if (productMap.get(key) == null) {
                        noCodeCrm.add(key);
                        continue;
                    }
                    Product2 product = productMap.get(key);
    
                    if (entryMap.get(product.Id) == null) {
                        noCodeCrm.add(key);
                        continue;
                    }
    
                    Object obj = eventPartMap.get(key);

                    String tempJson = JSON.serialize(obj);
                    Map<String, Object> objMap = (Map<String, Object>)Json.deserializeUntyped(tempJson);

                    String code = String.valueOf(objMap.get('partNo'));
                    Decimal qty = Decimal.valueOf(String.valueOf(objMap.get('qty')));
                    EventPartsWrapper epw = new EventPartsWrapper();
                    epw.pricebookEntryId = entryMap.get(product.Id).Id;
                    epw.productCode = code;
                    epw.productId = product.Id;
                    epw.productName = product.FM_MaterialDetails__c;
                    epw.quantity = qty;
                    epw.unitPrice = entryMap.get(product.Id).UnitPrice == null ? 0 : entryMap.get(product.Id).UnitPrice;
                    epw.unit = product.Unit__c;
                    resultEPWList.add(epw);
                }
    
                if (noCodeCrm.size() > 0) {
                    String notcode = String.join(noCodeCrm, ', ');
                    result.isSuccess = false;
                    result.message = '(' + notcode + ') Product or PricebookEntry is not in CRM.';
                    result.epwList = resultEPWList;
                } else {
                    result.epwList = resultEPWList;
                }
            } else {
                result.isSuccess = false;
                result.message = 'Parts not registered in CRM.';
            }


        } catch (Exception e) {
            result.isSuccess = false;
            result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
        }
        return result;
    }

    // Opportunity Line Item 삭제 메서드
    @AuraEnabled
    public static ResultWrapper deleteOptyLineItem(List<String> oliIds){
        ResultWrapper result = new ResultWrapper();
        try {
            List<OpportunityLineItem> oliList = [SELECT Id FROM OpportunityLineItem WHERE Id IN :oliIds];
            if(oliList.size() > 0) delete oliList;
            result.message = '삭제 성공';
        } catch (Exception e) {
            result.isSuccess = false;
            result.message = '삭제실패';
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    // Opportunity 제품을 삽입 또는 업데이트하는 메서드
    @AuraEnabled
    public static String upsertOptyProduct(List<OptyLineItemWrapper> requestProductList, String opportunityId) {
        System.debug('requestProductList:::' + requestProductList);
        List<OpportunityLineItem> insertOliList = new List<OpportunityLineItem>();
        List<String> noPricebookEntries = new List<String>();
        
        try {
            // 사용되는 ProductId만 추출
            Set<Id> productIds = new Set<Id>();
            Set<String> lineIds = new Set<String>();
            for (OptyLineItemWrapper wrapper : requestProductList) {
                if (wrapper.ProductId != null) {
                    productIds.add(wrapper.ProductId);
                    lineIds.add(wrapper.OptyLineItemId);
                }
            }
    
            String pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1].Id;
            Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>(
                [SELECT Id, Product2Id
                 FROM PricebookEntry
                 WHERE Pricebook2Id = :pricebook2Id
                 AND IsActive = true
                 AND Product2Id IN :productIds]
            );
            Map<Id, Id> productToPbeMap = new Map<Id, Id>();
            for (PricebookEntry pbe : pbeMap.values()) {
                productToPbeMap.put(pbe.Product2Id, pbe.Id);
            }
            // Insert 전 Delete
            List<OpportunityLineItem> existingOliList = [
                SELECT Id FROM OpportunityLineItem WHERE Id IN :lineIds
            ];
            if (!existingOliList.isEmpty()) {
                delete existingOliList;
            }
    
            for (OptyLineItemWrapper wrapper : requestProductList) {
                if (wrapper.ProductName == 'CS_MT_SVC' || wrapper.ProductName == 'CS_MT_MAT') {
                    wrapper.Description = wrapper.ProductCode;
                }
    
                if (String.isBlank(wrapper.PricebookEntryId)) {
                    wrapper.PricebookEntryId = productToPbeMap.get(wrapper.ProductId);
                }
    
                if (String.isBlank(wrapper.PricebookEntryId)) {
                    noPricebookEntries.add(wrapper.ProductName);
                    continue;
                }
    
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opportunityId;
                oli.Product2Id = wrapper.ProductId;
                oli.PricebookEntryId = wrapper.PricebookEntryId;
                oli.ProductName__c = wrapper.ProductName;
                oli.UnitPrice = wrapper.UnitPrice;
                oli.ListPrice__c = wrapper.ListPrice;
                oli.Quantity = wrapper.Quantity;
                oli.Unit__c = wrapper.Unit;
                oli.SupplyProduct__c = wrapper.SupplyProduct;
                oli.AvailableStock__c = wrapper.AvailableStock;
                oli.OptyProdCurrency__c = wrapper.OptyProdCurrency;
    
                if (String.isNotBlank(wrapper.Amount)) {
                    oli.CSTotalPrice__c = Decimal.valueOf(wrapper.Amount);
                }
                // if (String.isNotBlank(wrapper.OptyLineItemId)) {
                //     oli.Id = wrapper.OptyLineItemId;
                // }
    
                insertOliList.add(oli);
            }
    
            if (!noPricebookEntries.isEmpty()) {
                return '다음 제품의 가격 목록이 없습니다: ' + String.join(noPricebookEntries, ', ');
            }
    
            Database.SaveResult[] insertResult = Database.insert(insertOliList, false);
            for (Database.SaveResult sr : insertResult) {
                if (!sr.isSuccess()) {
                    return '삽입 오류 발생: ' + sr.getErrors()[0].getMessage();
                }
            }
    
            return 'SUCCESS';
    
        } catch (Exception e) {
            return '오류 발생: ' + e.getMessage();
        }
    }

    // Quote Line Item 삭제 메서드
    @AuraEnabled
    public static ResultWrapper deleteQuoteLineItem(List<String> qliIds){
        ResultWrapper result = new ResultWrapper();
        try {
            List<QuoteLineItem> qliList = [SELECT Id FROM QuoteLineItem WHERE Id IN :qliIds];
            if(qliList.size() > 0) delete qliList;
            result.message = '삭제 성공';
        } catch (Exception e) {
            result.isSuccess = false;
            result.message = '삭제실패';
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    // Quote 제품을 삽입 또는 업데이트하는 메서드
    @AuraEnabled
    public static String upsertQuoteProduct(List<QuoteLineItemWrapper> requestProductList, String quoteId) {
        System.debug('requestProductList:::' + requestProductList);
        System.debug('requestProductList:::' + requestProductList[0].PricebookEntryId);
        System.debug('quoteId:::' + quoteId);
        // List<OpportunityLineItem> insertOliList = new List<OpportunityLineItem>();
        List<QuoteLineItem> updateQliList = new List<QuoteLineItem>();
        Map<Id, Quote> duplicateQuoteMap = new Map<Id, Quote>();
        String pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1].Id;
        List<String> noPricebookEntries = new List<String>();

        try {
            Set<Id> productIds = new Set<Id>();
            Set<String> lineIds = new Set<String>();
            for (QuoteLineItemWrapper wrapper : requestProductList) {
                if (wrapper.ProductId != null) {
                    productIds.add(wrapper.ProductId);
                    lineIds.add(wrapper.QuoteLineItemId);
                }
            }
            // Insert 전 Delete
            List<QuoteLineItem> existingQliList = [
                SELECT Id FROM QuoteLineItem WHERE Id IN :lineIds
            ];
            if (!existingQliList.isEmpty()) {
                delete existingQliList;
            }
            for (QuoteLineItemWrapper wrapper : requestProductList) {
                if (wrapper.ProductName == 'CS_MT_SVC' || wrapper.ProductName == 'CS_MT_MAT') {
                    System.debug('flag1::');
                    wrapper.Description = wrapper.ProductCode;
                }

                if (wrapper.PricebookEntryId == null
                ) {
                    System.debug('flag2::');
                    noPricebookEntries.add(wrapper.ProductName + '');
                    continue;
                }
                System.debug('flag3::');
                
                QuoteLineItem qli = new QuoteLineItem();
                qli.QuoteId = quoteId;
                qli.Product2Id = wrapper.ProductId;
                qli.PricebookEntryId = wrapper.PricebookEntryId;
                qli.ProductName__c = wrapper.ProductName;
                qli.UnitPrice = wrapper.UnitPrice;
                if (wrapper.ListPrice == 0) {
                    qli.ListPrice__c = wrapper.UnitPrice;
                } else {
                    qli.ListPrice__c = wrapper.ListPrice;
                }
                qli.Quantity = wrapper.Quantity;
                qli.Unit__c = wrapper.Unit;
                qli.SupplyProduct__c = wrapper.SupplyProduct;
                qli.isManualAmount__c = wrapper.isManualAmount;
                qli.isManualDiscount__c = wrapper.isManualDiscount;
                qli.AvailableStock__c = wrapper.AvailableStock;
                qli.QuoteProdCurrency__c = wrapper.QuoteProdCurrency;
                qli.Discount__c = wrapper.Discount;
                qli.CSTotalPrice__c = Decimal.valueOf(wrapper.Amount);
                wrapper.isApproved = true;
                
                // if (wrapper.QuoteLineItemId != '' && wrapper.QuoteLineItemId != null) {
                //     qli.Id = wrapper.QuoteLineItemId; 
                // } 
                updateQliList.add(qli);
                
            }
            System.debug('updateQliList::' + updateQliList);

            if (!noPricebookEntries.isEmpty()) {
                return '다음 제품의 가격 목록이 없습니다: ' + String.join(noPricebookEntries, ', ');
            }
            TriggerHandler.bypass('QuoteLineItemTriggerHandler');
            Database.SaveResult[] insertResult = Database.insert(updateQliList, false);
            for (Database.SaveResult sr : insertResult) {
                if (!sr.isSuccess()) {
                    return '삽입 오류 발생: ' + sr.getErrors()[0].getMessage();
                }
            }
            TriggerHandler.clearBypass('QuoteLineItemTriggerHandler');
 

            return 'SUCCESS';
        } catch (Exception e) {
            return '오류 발생: ' + e.getMessage();
        }
    }

    // 장비 명을 가져오는 메서드
    @AuraEnabled
    public static String getEquipmentName(String recordId) {
        
        try {
            String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            System.debug('objectType ::: ' + objectType);
            if (objectType == 'Quote') {
                Quote quote = [SELECT Id, OpportunityId FROM Quote WHERE Id = :recordId LIMIT 1];
                Opportunity oppty = [SELECT Id, Equipment__r.Name FROM Opportunity WHERE Id = :quote.OpportunityId LIMIT 1];
                return oppty.Equipment__r.Name == null ? '' : oppty.Equipment__r.Name;
            } 
            else if (objectType == 'Opportunity') {
                Opportunity oppty = [SELECT Id, Equipment__r.Name FROM Opportunity WHERE Id = :recordId LIMIT 1];
                return oppty.Equipment__r.Name == null ? '' : oppty.Equipment__r.Name;
            }

            return '';
            
        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
            return '';
        }
    }

    // OpportunityLineItem Wrapper
    public class OptyLineItemWrapper {
        @AuraEnabled public String  OptyLineItemId      { get; set; }  // Key
        @AuraEnabled public String  ProductId           { get; set; }  // 제품ID
        @AuraEnabled public String  ProductName         { get; set; }  // 품명
        @AuraEnabled public String  ProductCode         { get; set; }  // 품번
        @AuraEnabled public Decimal Quantity            { get; set; }  // 수량
        @AuraEnabled public Decimal UnitPrice           { get; set; }  // 단가
        @AuraEnabled public Decimal ListPrice           { get; set; }  // 정가
        @AuraEnabled public String  Unit                { get; set; }  // 단위
        @AuraEnabled public String  PricebookEntryId    { get; set; }  // 제품Pricebook
        @AuraEnabled public String  Amount              { get; set; }  // 총 금액
        @AuraEnabled public String  Description         { get; set; }  // 설명
        @AuraEnabled public Boolean isApproved          { get; set; }  // 설명
        @AuraEnabled public Boolean isCustom            { get; set; }  // 설명
        @AuraEnabled public Boolean isChecked           { get; set; }  // 설명
        @AuraEnabled public String  PartNo              { get; set; }  // 설명
        @AuraEnabled public String  SupplyProduct       { get; set; }  // 공급제품
        @AuraEnabled public String  OptyProdCurrency    { get; set; }  // 통화
        @AuraEnabled public String  AvailableStock      { get; set; }  // 가용재고

        public OptyLineItemWrapper() {
            this.OptyLineItemId = '';
            this.ProductId = '';
            this.ProductName = '';
            this.ProductCode = '';
            this.Quantity = 0;
            this.UnitPrice = 0;
            this.ListPrice = 0;
            this.Unit = '';
            this.PricebookEntryId = '';
            this.Amount = '';
            this.Description = '';
            this.isApproved = true;
            this.isCustom = false;
            this.isChecked = false;
            this.PartNo = '';
            this.SupplyProduct = '';
            this.OptyProdCurrency = '';
            this.AvailableStock = '';
        }
    }
    // QuoteLineItem Wrapper
    public class QuoteLineItemWrapper {
        @AuraEnabled public String  QuoteLineItemId     { get; set; }  // Key
        @AuraEnabled public String  ProductId           { get; set; }  // 제품ID
        @AuraEnabled public String  ProductName         { get; set; }  // 품명
        @AuraEnabled public String  ProductCode         { get; set; }  // 품번
        @AuraEnabled public Decimal Quantity            { get; set; }  // 수량
        @AuraEnabled public Decimal UnitPrice           { get; set; }  // 단가
        @AuraEnabled public Decimal ListPrice           { get; set; }  // 정가
        @AuraEnabled public String  Unit                { get; set; }  // 단위
        @AuraEnabled public String  PricebookEntryId    { get; set; }  // 제품Pricebook
        @AuraEnabled public String  Amount              { get; set; }  // 총 금액
        @AuraEnabled public String  Description         { get; set; }  // 설명
        @AuraEnabled public Boolean isApproved          { get; set; }  // 설명
        @AuraEnabled public Boolean isCustom            { get; set; }  // 설명
        @AuraEnabled public Boolean isChecked           { get; set; }  // 설명
        @AuraEnabled public Boolean isManualAmount      { get; set; }  // 금액수동입력확인
        @AuraEnabled public Boolean isManualDiscount    { get; set; }  // 할인수동입력확인
        @AuraEnabled public String  PartNo              { get; set; }  // 설명
        @AuraEnabled public String  SupplyProduct       { get; set; }  // 공급제품
        @AuraEnabled public String  QuoteProdCurrency    { get; set; }  // 통화
        @AuraEnabled public String  AvailableStock      { get; set; }  // 가용재고
        @AuraEnabled public Decimal Discount      { get; set; }  // 가용재고

        public QuoteLineItemWrapper() {
            this.QuoteLineItemId = '';
            this.ProductId = '';
            this.ProductName = '';
            this.ProductCode = '';
            this.Quantity = 0;
            this.UnitPrice = 0;
            this.ListPrice = 0;
            this.Unit = '';
            this.PricebookEntryId = '';
            this.Amount = '';
            this.Description = '';
            this.isApproved = true;
            this.isCustom = false;
            this.isChecked = false;
            this.isManualAmount = false;
            this.isManualDiscount = false;
            this.PartNo = '';
            this.SupplyProduct = '';
            this.QuoteProdCurrency = '';
            this.AvailableStock = '';
            this.Discount = 0;
        }
    }

    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess   { get; set; }
        @AuraEnabled public String  message     { get; set; }

        public ResultWrapper() {
            this.isSuccess = true;
            this.message = '';
        }
    }

    public class EventPartsWrapper {
        @AuraEnabled public String          productId           { get; set; }
        @AuraEnabled public String          productName         { get; set; }
        @AuraEnabled public Decimal         quantity            { get; set; }
        @AuraEnabled public Decimal         unitPrice           { get; set; }
        @AuraEnabled public String          unit                { get; set; }
        @AuraEnabled public String          pricebookEntryId    { get; set; }
        @AuraEnabled public String          productCode         { get; set; }

        public EventPartsWrapper() {
            this.productId = '';
            this.productName = '';
            this.quantity = 0;
            this.unitPrice = 0;
            this.unit = '';
            this.pricebookEntryId = '';
            this.productCode = '';
        }
    }

    public class EventPartsResultWrapper {
        @AuraEnabled public Boolean isSuccess                   { get; set; }
        @AuraEnabled public String  message                     { get; set; }
        @AuraEnabled public List<EventPartsWrapper>  epwList    { get; set; }

        public EventPartsResultWrapper() {
            this.isSuccess = true;
            this.message = '';
            this.epwList = new List<EventPartsWrapper>();
        }
    }
}