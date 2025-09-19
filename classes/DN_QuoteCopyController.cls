public with sharing class DN_QuoteCopyController {
    private static final Id   recordTypeIdCommo = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
    private static final Id   recordTypeIdFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();

    @AuraEnabled
    public static string getStatus(String recordId){
        try {
            List<QuoteLineItem> quoteStatus = 
                [
                    SELECT 
                        Id 
                    FROM 
                        QuoteLineItem
                    WHERE
                        QuoteId =: recordId
                        and F_IsOrderCreated__c = true
                ];
            if(quoteStatus.size() > 0) { // 이미 주문이 생성된 건이면 ERROR
                return 'ERROR';
            }else {
                return 'SUCCESS';
            }
        } catch (Exception e) {
            System.debug('QuoteCopy : ' + e.getLineNumber() + ' : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String quoteCopy(String recordId, String copyReason){
        // 모든 필드 가져오기
        Map<String, Object> resMap = new Map<String, Object>();
        String Quote = 'Quote';
        String QuoteLineItem = 'QuoteLineItem';
        String CharacteristicValue = 'CharacteristicValue__c';
        String Accessory = 'Accessory__c';
        String SQ_QuoteLineitem_Junction = 'SQ_QuoteLineitem_Junction__c';
        String SQregistration_Quote = 'SQregistration_Quote__c';
        String SQ_Registration_Junction = 'SQ_Registration_Junction__c';
        String originCurrency;
        String tCondELMT = 'T_COND_ELMT__c';
        String DNSAFactoryOptionJunction = 'DNSA_Factory_Option_Junction__c';
        String SQRegistration = 'SQRegistration__c';
        String SQ_C = 'SQ__c';

        try {
            //Opportunity Line Item Delete
            List<OpportunityLineItem> deloptyItem = new List<OpportunityLineItem>();
            List<OpportunityLineItem> optyLineItem = new List<OpportunityLineItem>();
            String optyId = [SELECT OpportunityId FROM Quote WHERE Id =: recordId].OpportunityId;
            String RecordTypeId = [SELECT RecordTypeId FROM Quote WHERE Id =: recordId].RecordTypeId;

            //DNSA일 경우
            // if(RecordTypeId == recordTypeIdCommo || RecordTypeId == recordTypeIdFactory){
            //     //기존 Quote update
            //     Quote upVersionDNSA = new Quote();
            //     upVersionDNSA.Id = recordId;
            //     upVersionDNSA.Recently_Version__c = false;
            //     upVersionDNSA.CopyReason__c = copyReason;
            //     update upVersionDNSA;
            //     List<SObject> oldQuoteDNSA = getFieldValue(recordId, Quote);
            //     List<Quote> oldQuoteCastDNSA = new List<Quote>();
            //     //SObject Quote로 cast
            //     for(SObject obj : oldQuoteDNSA){
            //         oldQuoteCastDNSA.add((Quote)obj);
            //     }
            //     Quote cloneQuoteDNSA = oldQuoteCastDNSA[0].clone(false, true, false, false);
            //     cloneQuoteDNSA.CopyReason__c = '';
            //     cloneQuoteDNSA.isCloned__c = true;
            //     cloneQuoteDNSA.Recently_Version__c = true;
            //     cloneQuoteDNSA.IsFinal__c = false;
            //     if(RecordTypeId == recordTypeIdCommo){
            //         cloneQuoteDNSA.RecordTypeId = recordTypeIdFactory;
            //     }else{
            //         cloneQuoteDNSA.RecordTypeId = recordTypeIdCommo;
            //     }
            //     insert cloneQuoteDNSA;
            //     return cloneQuoteDNSA.Id;
            // }
            //Version 확인
            List<Quote> optyInfo = 
            [
                SELECT
                    OpportunityId,
                    Name,
                    CreatedDate,
                    CurrencyIsoCode
                FROM 
                    Quote
                WHERE
                    Id =: recordId
            ];
            originCurrency = optyInfo[0].CurrencyIsoCode;

            List<Quote> version = 
            [
                SELECT
                    Id,
                    Name
                FROM
                    Quote
                WHERE 
                    OpportunityId =: optyInfo[0].OpportunityId
                ORDER BY
                    CreatedDate 
                DESC
            ];
            Opportunity versionUp = new Opportunity();
            versionUp.Id = optyInfo[0].OpportunityId;
            versionUp.QuoteVersion__c = version.size() + 1;
            versionUp.RecentCopyQuoteId__c = recordId;
            update versionUp;

            optyLineItem = 
            [
                SELECT
                    Id
                FROM
                    OpportunityLineItem
                WHERE
                    OpportunityId =: optyId
            ];
            for(Integer i = 0; i < optyLineItem.size(); i++){
                OpportunityLineItem delItem = new OpportunityLineItem ();
                delItem.Id = optyLineItem[i].Id;
                deloptyItem.add(delItem);
            }
            delete deloptyItem; //대표사양 최신화 위해 삭제 후 재생성

            //기존 Quote update
            List<Quote> upQuoteList = new List<Quote>();
            List<Quote> upVersionList = [SELECT Id, Recently_Version__c FROM Quote WHERE OpportunityId =: optyInfo[0].OpportunityId];
            for(Quote qt : upVersionList){
                if(qt.Recently_Version__c == true){
                    Quote upVersion = new Quote();
                    upVersion.Id = qt.Id;
                    upVersion.Recently_Version__c = false;
                    if(qt.Id == recordId){
                        upVersion.CopyReason__c = copyReason;
                    }
                    upQuoteList.add(upVersion);
                }
            }
            if(!upQuoteList.isEmpty()){
                update upQuoteList;
            }

            
            System.debug('optyInfo[0].OpportunityId : ' + optyInfo[0].OpportunityId);
            System.debug('count : ' + version);
            System.debug('recordId : ' + recordId);
            //Quote 가공
            List<SObject> oldQuote = getFieldValue(recordId, Quote);
            List<Quote> oldQuoteCast = new List<Quote>();
            //SObject Quote로 cast
            for(SObject obj : oldQuote){
                oldQuoteCast.add((Quote)obj);
            }
            Quote cloneQuote = oldQuoteCast[0].clone(false, true, false, false);
            Integer lastUnderv = cloneQuote.Name.lastIndexOf('_');
            String lastName = cloneQuote.Name.substring(lastUnderv);
            System.debug('lastName : ' + lastName);
            String result;
            System.debug('recently : ' + cloneQuote.Recently_Version__c);
            if(recordId != version[0].Id){
                if(lastName == '_Quote'){
                    cloneQuote.Name = cloneQuote.Name + '_v' + (version.size() + 1);
                }else{
                    cloneQuote.Name = cloneQuote.Name + '_Quote_v' + (version.size() + 1);
                }
                System.debug('여긴가1');
            }else{
                if(lastUnderv != -1){
                    result = cloneQuote.Name.substring(0, lastUnderv);
                    if(lastName == '_Quote'){
                        cloneQuote.Name = result + '_Quote_v' + (version.size() + 1);
                    }else{
                        cloneQuote.Name = result + '_v' + (version.size() + 1);
                    }
                System.debug('여긴가2');

                }else{
                    if(lastName == '_Quote'){
                        cloneQuote.Name = cloneQuote.Name + '_v' + (version.size() + 1);
                    }else{
                        cloneQuote.Name = cloneQuote.Name + '_Quote_v' + (version.size() + 1);
                    }
                System.debug('여긴가3');

                }
            }
            cloneQuote.CopyReason__c = '';
            cloneQuote.isCloned__c = true;
            cloneQuote.Recently_Version__c = true;
            cloneQuote.IsFinal__c = false;
            cloneQuote.Review__c = '';
            insert cloneQuote;

            

            //QuoteLineItem 가공
            List<SObject> oldQuoteLineItem = getFieldValue(recordId, QuoteLineItem);
            List<QuoteLineItem> oldQuoteLineItemCast = new List<QuoteLineItem>();
            Map<Id, Id> priceMap = new Map<Id, Id>();
            Set<Id> prdId = new Set<Id>();
            //SObject to QuotelineItem
            for(SObject obj : oldQuoteLineItem){
                oldQuoteLineItemCast.add((QuoteLineItem)obj);
            }

            List<Id> oldquoteLineId = new List<Id>();
            for(QuoteLineItem oldQtLine : oldQuoteLineItemCast){
                oldquoteLineId.add((String)oldQtLine.get('Id'));
                prdId.add(oldQtLine.Product2Id);
            }
            List<PricebookEntry> pbEntryList = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN:prdId AND CurrencyIsoCode =:originCurrency];
            if(!pbEntryList.isEmpty()){
                for(PricebookEntry pb : pbEntryList){
                    priceMap.put(pb.Product2Id, pb.Id);
                }
            }

            // 새 OpportunityLineItem 생성
            Map<Id, OpportunityLineItem> oppLineItemMap = new Map<Id, OpportunityLineItem>();
            for (QuoteLineItem oldQtLine : oldQuoteLineItemCast) {
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.OpportunityId = cloneQuote.OpportunityId;
                oppLineItem.PricebookEntryId = priceMap.get(oldQtLine.Product2Id);
                oppLineItem.Product2Id = oldQtLine.Product2Id;
                oppLineItem.UnitPrice = oldQtLine.UnitPrice;
                oppLineItem.Quantity = oldQtLine.Quantity;
                oppLineItem.ERPInquiryNo__c = oldQtLine.ERPInquiryNo__c;
                oppLineItemMap.put(oldQtLine.Id, oppLineItem);
            }
            insert oppLineItemMap.values();

            List<QuoteLineItem> newLineItems = new List<QuoteLineItem>();
            for(QuoteLineItem item : oldQuoteLineItemCast){
                QuoteLineItem cloneItem = item.clone(false, true, false, false);
                cloneItem.QuoteId = cloneQuote.Id;
                // cloneItem.ERPQuotationNo__c = '';
                // cloneItem.UnitPrice = 0;
                // 새로 생성된 OpportunityLineItem의 ID를 설정
                if (oppLineItemMap.containsKey(item.Id)) {
                    cloneItem.OpportunityLineItemId = oppLineItemMap.get(item.Id).Id;
                }
                cloneItem.ReERPQuotation__c = false; //Quote Price IF필드는 그대로 가져가기 때문에 ReERPQuotation은 무조건 false로
                if(RecordTypeId == recordTypeIdFactory){
                    cloneItem.Accessory_Complete__c = false;
                    cloneItem.Accessory_Total__c = 0;
                    cloneItem.AdjustmentPercent__c = 0;
                    cloneItem.Adjustment_Price__c = 0;
                    cloneItem.CustomerPrice__c = 0;
                    cloneItem.CVComplete__c = false;
                    cloneItem.CV_Total__c = 0;
                    cloneItem.DC__c = 0;
                    cloneItem.ERPQuotationNo__c = '';
                    cloneItem.ERPInquiryNo__c = '';
                    cloneItem.Factory_CV_Total__c = 0;
                    cloneItem.Factory_Option_Total__c = 0;
                    cloneItem.ListPrice__c = 0;
                    cloneItem.Max_POSNR__c = 20;
                    cloneItem.UnitPrice = 0;
                    cloneItem.QuotePriceIF__c = false;
                    cloneItem.Dealer_Price__c = 0;
                    cloneItem.SQ_Total__c = 0;
                    cloneItem.TotalPrice__c = 0;
                    cloneItem.Warranty__c = 'M24';
                    cloneItem.Warranty_Percent__c = 0;
                    cloneItem.Warranty_Acc__c = 0;
                    cloneItem.Warranty_Prd__c = 0;
                    cloneItem.Warranty_Price__c = 0;
                    cloneItem.Warranty_SQ__c = 0;
                    cloneItem.ZPR1__c = 0;
                    cloneItem.ZSSD__c = 0;
                    cloneItem.ZSSS__c = 0;
                }

                newLineItems.add(cloneItem);
            }
            insert newLineItems;

            List<Id> newquoteLineId = new List<Id>();
            for(QuoteLineItem q : newLineItems){
                newquoteLineId.add(q.Id);
            }

            Map<Id, Id> oldToNewQuoteLineItemMap = new Map<Id, Id>();
            // 기존 -> 새 QuoteLineItem 매핑
            for (Integer i = 0; i < oldquoteLineId.size(); i++) {
                oldToNewQuoteLineItemMap.put(
                    oldquoteLineId[i],
                    newquoteLineId[i]
                );
            }

            //CV 가공
            List<SObject> oldCV = getFieldValue(recordId, CharacteristicValue);
            List<CharacteristicValue__c> oldCVCast = new List<CharacteristicValue__c>();
            List<CharacteristicValue__c> newCV = new List<CharacteristicValue__c>();

            //SObject to CV
            for(SObject obj : oldCV){
                oldCVCast.add((CharacteristicValue__c)obj);
            }
            if(oldCVCast.size() > 0){
                for (CharacteristicValue__c cv : oldCVCast) {
                    // CV와 관련된 QuoteLineItem만 복제
                    if (oldToNewQuoteLineItemMap.containsKey(cv.QuoteLineItem__c)) {
                        CharacteristicValue__c clonedCV = cv.clone(false, true);
                        clonedCV.QuoteLineItem__c = oldToNewQuoteLineItemMap.get(cv.QuoteLineItem__c);
                        newCV.add(clonedCV);
                    }
                }
                if(RecordTypeId != recordTypeIdFactory){
                    insert newCV;
                }
            }

            //추가자재 가공
            List<SObject> oldAccessory = getFieldValue(recordId, Accessory);
            List<Accessory__c> oldAccessoryCast = new List<Accessory__c>();
            List<Accessory__c> newAccessory = new List<Accessory__c>();

            for(SObject obj : oldAccessory){
                oldAccessoryCast.add((Accessory__c)obj);
            }
            if(oldAccessoryCast.size() > 0){
                for (Accessory__c oldasc : oldAccessoryCast) {
                    // 추가자재 관련된 QuoteLineItem만 복제
                    if (oldToNewQuoteLineItemMap.containsKey(oldasc.QuoteLineItem__c)) {
                        Accessory__c clonedAsc = oldasc.clone(false, true);
                        clonedAsc.QuoteLineItem__c = oldToNewQuoteLineItemMap.get(oldasc.QuoteLineItem__c);
                        clonedAsc.Quote__c = cloneQuote.Id;
                        newAccessory.add(clonedAsc);
                    }
                }
                if(RecordTypeId != recordTypeIdFactory){
                    insert newAccessory;
                }
            }

            //SQ Line Junction
            List<SObject> oldSQ_quotelinejunc = getFieldValue(recordId, SQ_QuoteLineitem_Junction);
            List<SQ_QuoteLineitem_Junction__c> oldSQ_quotelinejuncCast = new List<SQ_QuoteLineitem_Junction__c>();
            List<SQ_QuoteLineitem_Junction__c> newSQ_quotelinejunc = new List<SQ_QuoteLineitem_Junction__c>();
            for(SObject obj : oldSQ_quotelinejunc){
                oldSQ_quotelinejuncCast.add((SQ_QuoteLineitem_Junction__c)obj);
            }
            if(oldSQ_quotelinejuncCast.size() > 0){
                for (SQ_QuoteLineitem_Junction__c sq : oldSQ_quotelinejuncCast) {
                    // 추가자재 관련된 QuoteLineItem만 복제
                    if (oldToNewQuoteLineItemMap.containsKey(sq.QuoteLineItem__c)) {
                        SQ_QuoteLineitem_Junction__c clonedSQ = sq.clone(false, true);
                        clonedSQ.QuoteLineItem__c = oldToNewQuoteLineItemMap.get(sq.QuoteLineItem__c);
                        newSQ_quotelinejunc.add(clonedSQ);
                    }
                }
                if(RecordTypeId != recordTypeIdFactory){
                    insert newSQ_quotelinejunc;
                }
            }

            //SQregistration_Quote__c
            List<SObject> oldSQ_reg = getFieldValue(recordId, SQregistration_Quote);
            List<SQregistration_Quote__c> oldSQ_regCast = new List<SQregistration_Quote__c>();
            List<SQregistration_Quote__c> newSQ_reg = new List<SQregistration_Quote__c>();
            for(SObject obj : oldSQ_reg){
                oldSQ_regCast.add((SQregistration_Quote__c)obj);
            }
            if(oldSQ_regCast.size() > 0){
                for (SQregistration_Quote__c sq : oldSQ_regCast) {
                    // 추가자재 관련된 QuoteLineItem만 복제
                    SQregistration_Quote__c clonedSQ = sq.clone(false, true);
                    clonedSQ.Quote__c = cloneQuote.Id;
                    newSQ_reg.add(clonedSQ);
                }
                if(RecordTypeId != recordTypeIdFactory){
                    insert newSQ_reg;
                }
            }

            //SQ_Registration_Junction__c
            List<SObject> oldSQ_regjunc = getFieldValue(recordId, SQ_Registration_Junction);
            List<SQ_Registration_Junction__c> oldSQ_regjuncCast = new List<SQ_Registration_Junction__c>();
            List<SQ_Registration_Junction__c> newSQ_regjunc = new List<SQ_Registration_Junction__c>();
            for(SObject obj : oldSQ_regjunc){
                oldSQ_regjuncCast.add((SQ_Registration_Junction__c)obj);
            }
            if(oldSQ_regjuncCast.size() > 0){
                for (SQ_Registration_Junction__c sq : oldSQ_regjuncCast) {
                    // 추가자재 관련된 QuoteLineItem만 복제
                    if (oldToNewQuoteLineItemMap.containsKey(sq.QuoteLineItem__c)) {
                        SQ_Registration_Junction__c clonedSQ = sq.clone(false, true);
                        clonedSQ.QuoteLineItem__c = oldToNewQuoteLineItemMap.get(sq.QuoteLineItem__c);
                        newSQ_regjunc.add(clonedSQ);
                    }
                }
                if(RecordTypeId != recordTypeIdFactory){
                    insert newSQ_regjunc;
                }
            }

            //T_COND_ELMT
            List<SObject> oldtCondELMT = getFieldValue(recordId, tCondELMT);
            List<T_COND_ELMT__c> oldElmtCast = new List<T_COND_ELMT__c>();
            List<T_COND_ELMT__c> newElmt = new List<T_COND_ELMT__c>();
            for(SObject obj : oldtCondELMT){
                oldElmtCast.add((T_COND_ELMT__c)obj);
            }
            if(oldElmtCast.size() > 0){
                for (T_COND_ELMT__c elmt : oldElmtCast) {
                    // 추가자재 관련된 QuoteLineItem만 복제
                    if (oldToNewQuoteLineItemMap.containsKey(elmt.Quote_Line_Item__c)) {
                        T_COND_ELMT__c clonedElmt = elmt.clone(false, true);
                        clonedElmt.Quote_Line_Item__c = oldToNewQuoteLineItemMap.get(elmt.Quote_Line_Item__c);
                        newElmt.add(clonedElmt);
                    }
                }
                if(RecordTypeId != recordTypeIdFactory){
                    insert newElmt;
                }
            }

            if(RecordTypeId == recordTypeIdFactory){
                //DNSA_Factory_Option_Junction__c
                List<SObject> oldtCondFOJ = getFieldValue(recordId, DNSAFactoryOptionJunction);
                List<DNSA_Factory_Option_Junction__c> oldFOJCast = new List<DNSA_Factory_Option_Junction__c>();
                List<DNSA_Factory_Option_Junction__c> newFOJ = new List<DNSA_Factory_Option_Junction__c>();
                for(SObject obj : oldtCondFOJ){
                    oldFOJCast.add((DNSA_Factory_Option_Junction__c)obj);
                }
                if(oldFOJCast.size() > 0){
                    for (DNSA_Factory_Option_Junction__c foj : oldFOJCast) {
                        DNSA_Factory_Option_Junction__c clonedfoj = foj.clone(false, true);
                        clonedfoj.Quote_Line_Item__c = oldToNewQuoteLineItemMap.get(foj.Quote_Line_Item__c);
                        clonedfoj.Quote__c = cloneQuote.Id;
                        newFOJ.add(clonedfoj);
                    }
                    insert newFOJ;
                }

                //SQRegistration__c
                // List<SObject> oldtCondSQR = getFieldValue(recordId, SQRegistration);
                // List<SQRegistration__c> oldSQRCast = new List<SQRegistration__c>();
                // List<SQRegistration__c> newSQR = new List<SQRegistration__c>();
                // for(SObject obj : oldtCondSQR){
                //     oldSQRCast.add((SQRegistration__c)obj);
                // }
                // if(oldSQRCast.size() > 0){
                //     for (SQRegistration__c SQR : oldSQRCast) {
                //         SQRegistration__c clonedSQR = SQR.clone(false, true);
                //         clonedSQR.Quote__c = cloneQuote.Id;
                //         newSQR.add(clonedSQR);
                //     }
                //     insert newSQR;
                // }

                //SQRegistration__c
                // List<SObject> oldtCondSQ = getFieldValue(recordId, SQ_C);
                // List<SQ__c> oldSQCast = new List<SQ__c>();
                // List<SQ__c> newSQ = new List<SQ__c>();
                // for(SObject obj : oldtCondSQ){
                //     oldSQCast.add((SQ__c)obj);
                // }
                // if(oldSQCast.size() > 0){
                //     for (SQ__c SQ : oldSQCast) {
                //         SQ__c clonedSQ = SQ.clone(false, true);
                //         clonedSQ.Quote__c = cloneQuote.Id;
                //         newSQ.add(clonedSQ);
                //     }
                //     insert newSQ;
                // }
            }

            

            // 기존 QuoteLineItem의 OpportunityLineItemId__c 필드 초기화 (복제 완료 후)
            List<QuoteLineItem> quoteLineItemsToUpdate = new List<QuoteLineItem>();
            for (QuoteLineItem oldQtLine : oldQuoteLineItemCast) {
                if (oldQtLine.OpportunityLineItemId != null) {
                    oldQtLine.OpportunityLineItemId = null;
                    quoteLineItemsToUpdate.add(oldQtLine);
                }
            }

            if (!quoteLineItemsToUpdate.isEmpty()) {
                update quoteLineItemsToUpdate;
            }


            System.debug('result1' + oldQuote);
            System.debug('result2' + oldQuoteLineItem);
            System.debug('result3' + oldCV);
            System.debug('result4' + oldAccessory);
            System.debug('result5' + oldSQ_quotelinejunc);
            System.debug('result6' + oldSQ_reg);
            System.debug('result7' + oldSQ_regjunc);
            return cloneQuote.Id;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<SObject> getFieldValue(String recordId, String objectName) {
        Map<String, Object> resMap = new Map<String, Object>();
 
        try {
            Map<String, Schema.SObjectField>    objectFields    = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            List<String>                        fieldsToQuery   = new List<String>(objectFields.keySet());
            // QuoteLineItem where QuoteId 
            // CharacteristicValue__c where QuoteLineItem__c 
            // Accessory__c where QuoteLineItem__c 
            // SQ_QuoteLineitem_Junction__c where QuoteLineItem__c
            // SQ_Registration_Junction__c where QuoteLineItem__c
            // SQregistration_Quote__c where Quote__c
            String query = '';
            if(objectName == 'Quote') {
                query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName + ' WHERE Id = \'' + recordId + '\'';
            }else if(objectName == 'SQregistration_Quote__c'){
                query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName + ' WHERE Quote__c = \'' + recordId + '\'';
            }else if(objectName == 'QuoteLineItem'){
                query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName + ' WHERE QuoteId = \'' + recordId + '\'';
            }else if(objectName == 'T_COND_ELMT__c'){
                query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName + ' WHERE Quote_Line_Item__r.QuoteId = \'' + recordId + '\'';
            }else if(objectName == 'DNSA_Factory_Option_Junction__c'){
                query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName + ' WHERE Dealer_Checked__c = true AND Quote__c = \'' + recordId + '\'';
            }else if(objectName == 'SQRegistration__c'){
                query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName + ' WHERE Quote__c = \'' + recordId + '\'';
            }else if(objectName == 'SQ__c'){
                query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName + ' WHERE Quote__c = \'' + recordId + '\'';
            }else{
                // query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName + ' WHERE QuoteLineItem__c IN (\''+ quoteLineId +'\')';
                query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + objectName + ' WHERE QuoteLineItem__r.QuoteId = \''+ recordId +'\'';
            }
            
            List<SObject> sObj = Database.query(query);
 
            return sObj;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    // public static void dummy() {
    //     Integer i = 0;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //             i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    // }
}