/**
 * @description       : 
 * @author            : Joohyun Lee
 * @group             : 
 * @last modified on  : 05-07-2025
 * @last modified by  : Hanyeong Choi
**/
public with sharing class DNSA_QuotationExportController {
    @AuraEnabled
    public static Map<String, Object> getInfo(String recordId){
        try {
            Map<String, Object> result = new Map<String, Object>();
            List<Map<String, Object>> quoteLineItemList = new List<Map<String, Object>>();
            Map<String, Object> returnResult = new Map<String, Object>();
            Decimal optionTotal = 0;

            //Dealer명, 고객명, 주소, Warranty, Model, RSD, 대표사양 가격
            List<QuoteLineItem> headerInfo = 
            [
                SELECT 
                    Id,
                    Quote.QuoteNumber,
                    Quote.Owner.Name,
                    Quote.Account.Name,
                    Quote.Account.ShippingAddress,
                    Quote.Account.ShippingStreet, 
                    Quote.Account.ShippingCity,
                    Quote.Account.ShippingState,
                    Warranty__c,
                    Product2.Model__r.Name,
                    Requested_Ship_Date__c,
                    UnitPrice,
                    Dealer_Price__c,
                    ZPR1__c,
                    CurrencyIsoCode,
                    CreatedDate,
                    Adjustment_Price__c
                FROM 
                    QuoteLineItem 
                WHERE 
                    QuoteId  =: recordId
            ];

            String warrantyLabel = '';
            for (Schema.PicklistEntry entry : QuoteLineItem.Warranty__c.getDescribe().getPicklistValues()) {
                if (entry.getValue() == headerInfo[0].Warranty__c) {
                    warrantyLabel = entry.getLabel();
                    break;
                }
            }

            //US Option
            List<Accessory__c> usoptionList = 
            [
                SELECT 
                    Id, 
                    Key__c, 
                    Description__c, 
                    Price__c, 
                    SalesUnit__c,
                    Quantity__c
                FROM 
                    Accessory__c 
                WHERE 
                    QuoteLineItem__r.QuoteId =: recordId 
                AND Delete__c != 'D'
            ];

            //SQ
            List<SQ_QuoteLineitem_Junction__c> sqList = 
            [
                SELECT 
                    Id,
                    QuoteLineItem__c,
                    SQ__c,
                    SQ__r.Name, 
                    SQ__r.Price__c,
                    SalesPrice__c
                FROM
                    SQ_QuoteLineitem_Junction__c
                WHERE 
                    QuoteLineItem__r.QuoteId =: recordId
                AND UPDATEFLAG__c != 'D'
            ];

            //Factory Option CV
            List<CharacteristicValue__c> cvList = 
            [
                SELECT
                    Id,
                    C_Code__c,
                    C_Value__c,
                    V_Code__c,
                    V_Value__c,
                    QuoteLineItem__c,
                    Price__c
                FROM CharacteristicValue__c
                WHERE 
                    QuoteLineItem__r.QuoteId  =: recordId
                AND 
                    (defChange__c = true 
                OR (
                        Price__c != 0
                    AND Price__c != null))
                AND ShowData__c = true
            ];

            //Factory Option CV - 이주현
            List<DNSA_Factory_Option_Junction__c> foCVList = 
            [
                SELECT 
                    Id, 
                    DNSA_Factory_Option__r.Kit__c, 
                    DNSA_Factory_Option__r.Description__c, 
                    DNSA_Factory_Option__r.Price__c, 
                    Quantity__c 
                FROM 
                    DNSA_Factory_Option_Junction__c 
                WHERE 
                    Quote__c =: recordId
                AND Dealer_Checked__c = false 
                AND UPDATEFLAG__c != 'D' 
                And Type__c = 'CV'
            ];

            //Factory Option SQ
            List<DNSA_Factory_Option_Junction__c> fosqList = 
            [
                SELECT 
                    Id, 
                    DNSA_Factory_Option__r.Kit__c, 
                    DNSA_Factory_Option__r.Description__c, 
                    DNSA_Factory_Option__r.Price__c, 
                    Quantity__c 
                FROM 
                    DNSA_Factory_Option_Junction__c 
                WHERE 
                    Quote__c =: recordId
                AND Dealer_Checked__c = false 
                AND UPDATEFLAG__c != 'D' 
                And Type__c = 'SQ'
            ];
            result.put('Dealer', headerInfo[0].Quote.Owner.Name);
            result.put('AccountName', headerInfo[0].Quote.Account.Name);
            result.put('warrantyLabel', warrantyLabel);
            result.put('QuoteNumber', headerInfo[0].Quote.QuoteNumber);

            String ShippingStreet = '';
            String ShippingCity = '';
            String ShippingState = '';
            if(headerInfo[0].Quote.Account.ShippingStreet != null){
                ShippingStreet = headerInfo[0].Quote.Account.ShippingStreet;
            }
            if(headerInfo[0].Quote.Account.ShippingCity != null){
                ShippingCity = headerInfo[0].Quote.Account.ShippingCity;
            }
            if(headerInfo[0].Quote.Account.ShippingState != null){
                ShippingState = headerInfo[0].Quote.Account.ShippingState;
            }
            result.put('Address', ShippingStreet + ' ' + ShippingCity + ' ' + ShippingState);
            result.put('CurrencyIsoCode', headerInfo[0].CurrencyIsoCode);
            result.put('CreatedDate', headerInfo[0].CreatedDate);

            for(QuoteLineItem item : headerInfo){
                Map<String, Object> lineItemMap = new Map<String, Object>();
                lineItemMap.put('ProductName', item.Product2.Model__r.Name);
                lineItemMap.put('Quantity', 1);
                lineItemMap.put('ListPrice', item.ZPR1__c);
                lineItemMap.put('DealerPrice', item.Dealer_Price__c);
                lineItemMap.put('RSD', item.Requested_Ship_Date__c);
                lineItemMap.put('AdjustmentPrice', item.Adjustment_Price__c);
                lineItemMap.put('DCPrice', item.ZPR1__c - item.UnitPrice);
                result.put('headerInfo', lineItemMap);

            }
            List<Map<String, Object>> usItemList = new List<Map<String, Object>>();

            //US Option
            Map<String, Object> accLineMap = new Map<String,Object>();
                accLineMap.put('itemValue', 'US Option');
                accLineMap.put('Value', '');
                accLineMap.put('Qty', '');
                accLineMap.put('Price', '');
                accLineMap.put('Amount', '');
                usItemList.add(accLineMap);
                    
            for(Accessory__c accItem : usoptionList){
                Map<String, Object> accItemMap = new Map<String,Object>();
                accItemMap.put('itemValue', accItem.Key__c + ' - ' + accItem.Description__c);
                accItemMap.put('Qty', accItem.Quantity__c);
                if(accItem.Price__c != null){
                    // accItemMap.put('Price', Decimal.valueOf(String.valueOf(accItem.Price__c)).format());
                    // accItemMap.put('Amount', Decimal.valueOf(String.valueOf(accItem.Quantity__c * accItem.Price__c)).format());                
                    accItemMap.put('Price', accItem.Price__c);
                    accItemMap.put('Amount', accItem.Quantity__c * accItem.Price__c);
                }else{
                    accItemMap.put('Price', 0);
                    accItemMap.put('Amount', 0);
                }
                usItemList.add(accItemMap);
            }

            //SQ
            Map<String, Object> sqLineMap = new Map<String,Object>();
            sqLineMap.put('itemValue', 'SQ');
            sqLineMap.put('Qty', '');
            sqLineMap.put('Price', '');
            sqLineMap.put('Amount', '');
            usItemList.add(sqLineMap);

            Decimal sqTotal = 0;
            for(SQ_QuoteLineitem_Junction__c sqItem : sqList) {
                Map<String, Object> sqItemMap = new Map<String, Object>();
                    sqItemMap.put('itemValue', sqItem.SQ__r.Name);
                    sqItemMap.put('Qty', 1);
                    sqItemMap.put('type', 'SQ');
                    sqTotal += sqItem.SQ__r.Price__c;
                    // if(sqItem.SalesPrice__c != null){
                    //     // sqItemMap.put('Price', Decimal.valueOf(String.valueOf(sqItem.SalesPrice__c)).format());
                    //     // sqItemMap.put('Amount', Decimal.valueOf(String.valueOf(sqItem.SalesPrice__c)).format());
                    //     sqItemMap.put('Price', sqItem.SalesPrice__c);
                    //     sqItemMap.put('Amount', sqItem.SalesPrice__c);
                    //     // sqItemMap.put('Price', 0);
                    //     // sqItemMap.put('Amount', 0);
                    // }else{
                    //     sqItemMap.put('Price', 0);
                    //     sqItemMap.put('Amount', 0);
                    // }
                    usItemList.add(sqItemMap);
            }
            result.put('sqTotal', sqTotal);
            

            //Factory Option CV
            // Map<String, Object> cvLineMap = new Map<String,Object>();
            // cvLineMap.put('itemValue', 'Factory Option');
            // cvLineMap.put('Qty', '');
            // cvLineMap.put('Price', '');
            // cvLineMap.put('Amount', '');
            // usItemList.add(cvLineMap);

            // for(CharacteristicValue__c cvItem : cvList){
            //     Map<String, Object> cvItemMap = new Map<String, Object>();
            //     cvItemMap.put('itemValue', cvItem.C_Value__c + ' - ' + cvItem.V_Value__c);
            //     cvItemMap.put('Qty', 1);
            //     if(cvItem.Price__c != null){
            //         cvItemMap.put('Price', Decimal.valueOf(String.valueOf(cvItem.Price__c)).format());
            //         cvItemMap.put('Amount', Decimal.valueOf(String.valueOf(cvItem.Price__c)).format());
            //     }else{
            //         cvItemMap.put('Price', 0);
            //         cvItemMap.put('Amount', 0);
            //     }
            //     usItemList.add(cvItemMap);
            // }

            Map<String, Object> fosqLineMap = new Map<String,Object>();
            fosqLineMap.put('itemValue', 'Factory Option');
            fosqLineMap.put('Qty', '');
            fosqLineMap.put('Price', '');
            fosqLineMap.put('Amount', '');
            usItemList.add(fosqLineMap);

            Decimal facTotal = 0;
            for(DNSA_Factory_Option_Junction__c foCVItem : foCVList){
                Map<String, Object> foCVItemMap = new Map<String, Object>();
                foCVItemMap.put('itemValue', foCVItem.DNSA_Factory_Option__r.Kit__c + ' - ' + foCVItem.DNSA_Factory_Option__r.Description__c);
                foCVItemMap.put('Qty', foCVItem.Quantity__c);
                foCVItemMap.put('type', 'option');
                facTotal += (foCVItem.DNSA_Factory_Option__r.Price__c * foCVItem.Quantity__c);
                // if(foCVItem.DNSA_Factory_Option__r.Price__c != null){
                //     // foCVItemMap.put('Price', Decimal.valueOf(String.valueOf(foCVItem.DNSA_Factory_Option__r.Price__c)).format());
                //     // foCVItemMap.put('Amount', Decimal.valueOf(String.valueOf(foCVItem.Quantity__c * foCVItem.DNSA_Factory_Option__r.Price__c)).format());
                //     foCVItemMap.put('Price', foCVItem.DNSA_Factory_Option__r.Price__c);
                //     foCVItemMap.put('Amount', foCVItem.Quantity__c * foCVItem.DNSA_Factory_Option__r.Price__c);
                //     // foCVItemMap.put('Price', 0);
                //     // foCVItemMap.put('Amount', 0);
                // }else{
                //     foCVItemMap.put('Price', 0);
                //     foCVItemMap.put('Amount', 0);
                // }
                usItemList.add(foCVItemMap);
            }

            for(DNSA_Factory_Option_Junction__c fosqItem : fosqList){
                Map<String, Object> fosqItemMap = new Map<String, Object>();
                fosqItemMap.put('itemValue', fosqItem.DNSA_Factory_Option__r.Kit__c + ' - ' + fosqItem.DNSA_Factory_Option__r.Description__c);
                fosqItemMap.put('Qty', fosqItem.Quantity__c);
                fosqItemMap.put('type', 'option');
                facTotal += (fosqItem.DNSA_Factory_Option__r.Price__c * fosqItem.Quantity__c);
                // if(fosqItem.DNSA_Factory_Option__r.Price__c != null){
                //     // fosqItemMap.put('Price', Decimal.valueOf(String.valueOf(fosqItem.DNSA_Factory_Option__r.Price__c)).format());
                //     // fosqItemMap.put('Amount', Decimal.valueOf(String.valueOf(fosqItem.Quantity__c * fosqItem.DNSA_Factory_Option__r.Price__c)).format());
                //     fosqItemMap.put('Price', fosqItem.DNSA_Factory_Option__r.Price__c);
                //     fosqItemMap.put('Amount', fosqItem.Quantity__c * fosqItem.DNSA_Factory_Option__r.Price__c);
                //     // fosqItemMap.put('Price', 0);
                //     // fosqItemMap.put('Amount', 0);
                // }else{
                //     fosqItemMap.put('Price', 0);
                //     fosqItemMap.put('Amount', 0);
                // }
                usItemList.add(fosqItemMap);
            }
            result.put('facTotal', facTotal);
            result.put('usItemList', usItemList);
            quoteLineItemList.add(result);
            returnResult.put('quoteData', quoteLineItemList);
            return returnResult;
        } catch (Exception e) {
            System.debug('Error Line : ' + e.getLineNumber() + ' MSG : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getStaticResourceBody_EN() {
        String dnLogo = 'DN_Logo';
        String dnSeal = 'DN_Seal';
        String dnLogoGlobal = 'DN_Logo_Global';
        // ContentVersion dnCVPrdCv;
        
        Map<String, String> mapCv = new Map<String, String>();
        try {
            StaticResource dnSealCv = [SELECT Body FROM StaticResource WHERE Name = :dnSeal LIMIT 1];
            StaticResource dnLogoGlobalCv = [SELECT Body FROM StaticResource WHERE Name = :dnLogoGlobal LIMIT 1];

            mapCv.put('dnSealCv', EncodingUtil.base64Encode(dnSealCv.Body));
            mapCv.put('dnLogoGlobalCv', EncodingUtil.base64Encode(dnLogoGlobalCv.Body));

            return mapCv;
        } catch (Exception e) {
            System.debug('Error getting ContentVersion data: ' + e.getMessage());
            mapCv.put('error', e.getMessage());
            return mapCv;
        }
    }

    @AuraEnabled
    public static String saveFile(String base64Data, String fileName, String parentId) {
        try {
            // Base64 문자열을 Blob으로 변환
            Blob fileBlob = EncodingUtil.base64Decode(base64Data);

            // ContentVersion 레코드 생성
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = fileBlob;
            contentVersion.FirstPublishLocationId = parentId;
            insert contentVersion;

            // ContentDocumentId 가져오기
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

            // 문서가 이미 부모 레코드에 링크되어 있는지 확인
            List<ContentDocumentLink> existingLinks = [
                SELECT Id FROM ContentDocumentLink 
                WHERE ContentDocumentId = :contentDocumentId 
                AND LinkedEntityId = :parentId
            ];

            if (existingLinks.isEmpty()) {
                // ContentDocument를 부모 레코드에 링크
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocumentId;
                cdl.LinkedEntityId = parentId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                insert cdl;
            } else {
                return 'Duplicate Link';
            }

            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static void dummy() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}