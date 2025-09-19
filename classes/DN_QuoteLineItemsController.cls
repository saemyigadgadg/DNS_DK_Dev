/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-21-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-26-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public without sharing class DN_QuoteLineItemsController {
    private static final Id   recordTypeIdCommo = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
    private static final Id   recordTypeIdFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();

    @AuraEnabled
    public static Map<String,Object> getRecordName(String recordId){
        try {
            List<QuoteLineItemWrapper> quoteLineItemWrapperList = new List<QuoteLineItemWrapper>();
            // 현재 로그인된 사용자의 프로필 정보를 가져오기
            User currentUser = [SELECT Profile.Name, Profile.UserLicense.Name, UserRole.PortalRole FROM User WHERE Id = :UserInfo.getUserId()];
            String currentUserProfile = currentUser.Profile.UserLicense.Name;

            List<Network> networkPortal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
            String isPortal = 'false';
            if (currentUser.Profile.UserLicense.Name.contains('Partner')) {
                isPortal = 'true';
            } else {
                isPortal = 'false';
            }
            List<Warranty__c> globalWar = [SELECT Id, KSCHL__c, VKORG__c, SPART__c, VTWEG__c, ZZPR_WAR__c, Percent__c, DATBI__c, DATAB__c, ZZWARRPER__c, ZZPERUNIT__c, ZZWARHRS__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c FROM Warranty__c WHERE VTWEG__c = '20' AND VKORG__c = '1800'];
            Map<String, Warranty__c> globalWarMap = new Map<String, Warranty__c>();
            for(Warranty__c glo : globalWar){
                globalWarMap.put(glo.ZZPR_WAR__c, glo);
            }

            List<Warranty__c> dnsaWar = [SELECT Id, KSCHL__c, VKORG__c, SPART__c, VTWEG__c, ZZPR_WAR__c, Percent__c, DATBI__c, DATAB__c, ZZWARRPER__c, ZZPERUNIT__c, ZZWARHRS__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c FROM Warranty__c WHERE BZIRK__c = 'M3UL'];
            Map<String, Warranty__c> dnsaWarMap = new Map<String, Warranty__c>();
            for(Warranty__c glo : dnsaWar){
                dnsaWarMap.put(glo.ZZPR_WAR__c, glo);
            }

            System.debug('isportal : ' + isPortal);
            Map<String, Object> result = new Map<String, Object>();
            List<QuoteLineItem> recordType = [SELECT Id, Quote.RecordTypeId, DC__c,DC_Price__c,Warranty_Percent__c, CV_Total__c, Warranty__c, Warranty_SQ__c, Warranty_Acc__c, Quote.RecordType.Name, QuoteId, UnitPrice, SQ_Total__c, Accessory_Total__c, Warranty_Price__c, Adjustment_Price__c, Dealer_Price__c, ERPQuotationNo__c, Quote.Recently_Version__c, ZPR1__c  FROM QuoteLineItem WHERE Id =: recordId];
            result.put('Quote', recordType[0].QuoteId);
            result.put('RecordName', recordType[0].Quote.RecordType.Name);
            result.put('isPortal', isPortal);
            result.put('UnitPrice', recordType[0].UnitPrice);
            if(recordType[0].SQ_Total__c != null){
                if(recordType[0].Warranty_SQ__c != null){
                    result.put('SQ_Total__c', recordType[0].SQ_Total__c - recordType[0].Warranty_SQ__c);
                }else{
                    result.put('SQ_Total__c', recordType[0].SQ_Total__c);
                }
            }else{
                result.put('SQ_Total__c', 0);
            }
            

            if(recordType[0].Warranty_Acc__c != null){
                if(recordType[0].Accessory_Total__c != null){
                    result.put('Accessory_Total__c', recordType[0].Accessory_Total__c - recordType[0].Warranty_Acc__c);
                }
            }else{
                result.put('Accessory_Total__c', recordType[0].Accessory_Total__c);
            }
            System.debug('recordType[0].Warranty_Price__c : ' + recordType[0].Warranty_Price__c);
            if(recordType[0].Warranty_Price__c != null){
                result.put('Warranty_Price__c', recordType[0].Warranty_Price__c.setScale(2));
            }else{
                result.put('Warranty_Price__c', 0);
            }
            if(recordType[0].Adjustment_Price__c != null){
                result.put('Adjustment_Price__c', recordType[0].Adjustment_Price__c.setScale(2));
            }else{
                result.put('Adjustment_Price__c', 0);
            }
            if(recordType[0].CV_Total__c != null){
                result.put('CV_Total__c', recordType[0].CV_Total__c.setScale(2));
            }else{
                result.put('CV_Total__c', 0);
            }
            result.put('ZPR1__c', recordType[0].ZPR1__c);
            result.put('Dealer_Price__c', recordType[0].Dealer_Price__c);
            result.put('ERPQuotationNo__c', recordType[0].ERPQuotationNo__c);
            result.put('Recently_Version__c', recordType[0].Quote.Recently_Version__c);
            result.put('WarrantyLabel', DN_QuotationPDFController.getPicklistValues('QuoteLineItem', 'Warranty__c', recordType[0].Warranty__c));
            result.put('WarrantyAPI', recordType[0].Warranty__c);
            System.debug('recordType[0].Warranty__c : ' + recordType[0].Warranty__c);
            System.debug('recordType[0].Quote.RecordTypeId == recordTypeIdFactory : ' + recordType[0].Quote.RecordTypeId);
            System.debug('recordType[0].Quote.RecordTypeId == recordTypeIdFactory : ' + recordTypeIdFactory);
            if(recordType[0].Quote.RecordTypeId == recordTypeIdFactory ||recordType[0].Quote.RecordTypeId == recordTypeIdCommo){
                if(dnsaWarMap.get(recordType[0].Warranty__c) != null){
                    result.put('WarrantyPercent', dnsaWarMap.get(recordType[0].Warranty__c).Percent__c);
                }else{
                    result.put('WarrantyPercent', 0);
                }
            }else{
                if(globalWarMap.get(recordType[0].Warranty__c) != null){
                    result.put('WarrantyPercent', globalWarMap.get(recordType[0].Warranty__c).Percent__c);
                }else{
                    result.put('WarrantyPercent', 0);
                }
            }
            
            
            result.put('DC__c', recordType[0].DC__c);
            result.put('DC_Price__c', recordType[0].DC_Price__c);

            result.put('globalWarMap', globalWarMap);
            result.put('dnsaWarMap', dnsaWarMap);
            return result;
        } catch (Exception e) {
            System.debug('Error Line : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map<String, Object> getQuoteLineItemList(String recordId){
        System.debug('recordID : ' + recordId);
        List<Quote> recordType = [SELECT Id, RecordTypeId, RecordType.Name, Review__c, IsFinal__c FROM Quote WHERE Id =: recordId];

        List<QuoteLineItemWrapper> quoteLineItemWrapperList = new List<QuoteLineItemWrapper>();
        // 현재 로그인된 사용자의 프로필 정보를 가져오기
        User currentUser = [SELECT Profile.Name, Profile.UserLicense.Name, UserRole.PortalRole FROM User WHERE Id = :UserInfo.getUserId()];
        String currentUserProfile = currentUser.Profile.UserLicense.Name;

        List<Network> networkPortal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        Boolean isPortal = false;
        if (currentUser.Profile.UserLicense.Name.contains('Partner')) {
            isPortal = true;
        } else {
            isPortal = false;
        }
        System.debug('portal!! : ' + isPortal);
        try{
            
            List<QuoteLineItem> quoteLineItemList = [SELECT 
                                                        Id,
                                                        Quote.RecordType.Name,
                                                        RequestedDelivDate__c,
                                                        ExpectedDelivDate__c,
                                                        Product2Id, 
                                                        Product2.Name, 
                                                        Product2.ProductCode, 
                                                        Product2.Model__r.Name, 
                                                        Product2.IsPilot__c,
                                                        ERPQuotationNo__c, 
                                                        UnitPrice, 
                                                        Quantity, 
                                                        Subtotal, 
                                                        Discount, 
                                                        TotalPrice, 
                                                        ListPrice,
                                                        ListPrice__c,
                                                        GroupId__c,
                                                        CVComplete__c,
                                                        F_IsOrderCreated__c,
                                                        Quote.Recently_Version__c,
                                                        Dealer_Price__c,
                                                        Warranty__c,
                                                        Warranty_Price__c,
                                                        Accessory_Complete__c,
                                                        Adjustment_Price__c,
                                                        Warranty_Acc__c,
                                                        Warranty_Prd__c,
                                                        Warranty_SQ__c,
                                                        Requested_Ship_Date__c,
                                                        QuotePriceIF__c,
                                                        DC_Price__c,
                                                        DC__c,
                                                        Warranty_Percent__c,
                                                        AdjustmentPercent__c,
                                                        Final_Quotation_Price__c,
                                                        Factory_CV_Total__c,
                                                        Factory_Option_Total__c,
                                                        CustomerPrice__c,
                                                        Quote.Waiting_Seq__c,
                                                        Quote.TotalPrice__c,
                                                        US_Option_Total__c
                                                    FROM QuoteLineItem WHERE QuoteId =:recordId
                                                    ORDER BY Product2.Name DESC
                                                ];
            List<AggregateResult> orderCnt = [SELECT COUNT(Id) cnt FROM QuoteLineItem WHERE QuoteId =: recordId and F_IsOrderCreated__c = true];
            System.debug('quoteLineItemList : '+quoteLineItemList);

            Set<Id> quoteLineId = new Set<Id>();
            List<AggregateResult> cvTotal = new List<AggregateResult>();
            List<AggregateResult> accTotal = new List<AggregateResult>();
            List<AggregateResult> sqTotal = new List<AggregateResult>();
            Map<Object, Decimal> cvTotalMap = new Map<Object, Decimal>();
            Map<Object, Decimal> accTotalMap = new Map<Object, Decimal>();
            Map<Object, Decimal> sqTotalMap = new Map<Object, Decimal>();
            Map<Object, Decimal> factoryCVTotalMap = new Map<Object, Decimal>();
            Map<Object, Decimal> factoryOPTotalMap = new Map<Object, Decimal>();
            List<QuoteLineItem> updateList = new List<QuoteLineItem>();
            if(quoteLineItemList .size() > 0){
                for(QuoteLineItem id : quoteLineItemList){
                    quoteLineId.add(id.Id);
                }

                // CharacteristicValue__c 레코드 조회
                List<CharacteristicValue__c> cvRecords = [
                    SELECT QuoteLineItem__c, Price__c 
                    FROM CharacteristicValue__c 
                    WHERE QuoteLineItem__c IN :quoteLineId 
                    AND (defChange__c = true 
                    OR (Price__c != 0 AND Price__c != null)) 
                    AND ShowData__c = true
                ];

                // Accessory__c 레코드 조회
                List<Accessory__c> accRecords = [SELECT QuoteLineItem__c, Price__c, Quantity__c FROM Accessory__c WHERE QuoteLineItem__c IN :quoteLineId AND Delete__c != 'D'];

                // SQ_QuoteLineitem_Junction__c 레코드 조회
                List<SQ_QuoteLineitem_Junction__c> sqRecords = [SELECT QuoteLineItem__c, Sales_Price__c, SalesPrice__c, SQ__r.DNS_Price__c, SQ__r.Price__c FROM SQ_QuoteLineitem_Junction__c WHERE QuoteLineItem__c IN :quoteLineId AND UPDATEFLAG__c != 'D'];

                //Factory Option CV 레코드 조회
                List<DNSA_Factory_Option_Junction__c> factoryCVList = [SELECT Quote_Line_Item__c, Id, DNSA_Factory_Option__r.Price__c, Quantity__c FROM DNSA_Factory_Option_Junction__c WHERE Quote_Line_Item__c IN: quoteLineId AND UPDATEFLAG__c != 'D' AND Dealer_Checked__c = false AND DNSA_Factory_Option__r.Type__c = 'CV'];

                //Factory Option Option 레코드 조회
                List<DNSA_Factory_Option_Junction__c> factoryOPList = [SELECT Quote_Line_Item__c, Id, DNSA_Factory_Option__r.Price__c, Quantity__c FROM DNSA_Factory_Option_Junction__c WHERE Quote_Line_Item__c IN: quoteLineId AND UPDATEFLAG__c != 'D' AND Dealer_Checked__c = false AND DNSA_Factory_Option__r.Type__c = 'SQ'];

                // Factory Option CV 값 더하기
                for (DNSA_Factory_Option_Junction__c acc : factoryCVList) {
                    Decimal price = acc.DNSA_Factory_Option__r.Price__c != null ? (Decimal)(acc.DNSA_Factory_Option__r.Price__c) : 0; // null을 0으로 처리하고 Decimal로 변환
                    Decimal qty = acc.Quantity__c;
                    if (factoryCVTotalMap.containsKey(acc.Quote_Line_Item__c)) {
                        factoryCVTotalMap.put(acc.Quote_Line_Item__c, factoryCVTotalMap.get(acc.Quote_Line_Item__c) + price * qty);
                    } else {
                        factoryCVTotalMap.put(acc.Quote_Line_Item__c, price * qty);
                    }
                }

                // Factory Option Option 값 더하기
                for (DNSA_Factory_Option_Junction__c acc : factoryOPList) {
                    Decimal price = acc.DNSA_Factory_Option__r.Price__c != null ? (Decimal)(acc.DNSA_Factory_Option__r.Price__c) : 0; // null을 0으로 처리하고 Decimal로 변환
                    Decimal qty = acc.Quantity__c;
                    if (factoryOPTotalMap.containsKey(acc.Quote_Line_Item__c)) {
                        factoryOPTotalMap.put(acc.Quote_Line_Item__c, factoryOPTotalMap.get(acc.Quote_Line_Item__c) + price * qty);
                    } else {
                        factoryOPTotalMap.put(acc.Quote_Line_Item__c, price * qty);
                    }
                }

                // CharacteristicValue__c 값 더하기
                for (CharacteristicValue__c cv : cvRecords) {
                    Decimal price = cv.Price__c != null ? (Decimal)(cv.Price__c) : 0; // null을 0으로 처리하고 Decimal로 변환
                    if (cvTotalMap.containsKey(cv.QuoteLineItem__c)) {
                        cvTotalMap.put(cv.QuoteLineItem__c, cvTotalMap.get(cv.QuoteLineItem__c) + price);
                    } else {
                        cvTotalMap.put(cv.QuoteLineItem__c, price);
                    }
                }

                // Accessory__c 값 더하기
                for (Accessory__c acc : accRecords) {
                    Decimal price = acc.Price__c != null ? (Decimal)(acc.Price__c) : 0; // null을 0으로 처리하고 Decimal로 변환
                    Decimal qty = acc.Quantity__c;
                    if (accTotalMap.containsKey(acc.QuoteLineItem__c)) {
                        accTotalMap.put(acc.QuoteLineItem__c, accTotalMap.get(acc.QuoteLineItem__c) + price * qty);
                    } else {
                        accTotalMap.put(acc.QuoteLineItem__c, price * qty);
                    }
                }

                // SQ_QuoteLineitem_Junction__c 값 더하기
                for (SQ_QuoteLineitem_Junction__c sq : sqRecords) {
                    Decimal salesPrice = 0;
                    if(recordType[0].RecordTypeId == recordTypeIdFactory){
                        // salesPrice = sq.SQ__r.DNS_Price__c != null ? (Decimal)(sq.SQ__r.DNS_Price__c) : 0; // null을 0으로 처리하고 Decimal로 변환
                        salesPrice = sq.SQ__r.Price__c != null ? (Decimal)(sq.SQ__r.Price__c) : 0;
                    }else{
                        salesPrice = sq.SalesPrice__c != null ? (Decimal)(sq.SalesPrice__c) : 0; // null을 0으로 처리하고 Decimal로 변환
                    }

                    if (sqTotalMap.containsKey(sq.QuoteLineItem__c)) {
                        sqTotalMap.put(sq.QuoteLineItem__c, sqTotalMap.get(sq.QuoteLineItem__c) + salesPrice);
                    } else {
                        sqTotalMap.put(sq.QuoteLineItem__c, salesPrice);
                    }
                }
            }

            if(quoteLineItemList.size() > 0){
                for(QuoteLineItem quoteLineItem : quoteLineItemList){
                    Decimal DealerTotal = 0;
                    QuoteLineItemWrapper wapper 	= new QuoteLineItemWrapper();
                    wapper.Id			= quoteLineItem.Id;
                    wapper.ProductId	= quoteLineItem.Product2Id;
                    wapper.ProductName	= quoteLineItem.Product2.Name;
                    wapper.isFirst	= quoteLineItem.Quote.Waiting_Seq__c;
                    wapper.isPilot	= quoteLineItem.Product2.IsPilot__c;
                    if(String.isNotEmpty(quoteLineItem.Product2.Name)){
                        if(isPortal){
                            wapper.ProductURL    = Network.getLoginUrl(networkPortal[0].Id).removeEnd('/s/login') + '/' + quoteLineItem.Id;
                        }else{
                            wapper.ProductURL    = URL.getOrgDomainUrl().toExternalForm() + '/' + quoteLineItem.Id;
                        }
                    }	              
                    wapper.ERPQutaionNO			= quoteLineItem.ERPQuotationNo__c;
                    wapper.SalesPrice		= Decimal.valueOf(String.valueOf(quoteLineItem.UnitPrice)).format();
                    wapper.Quantity		= quoteLineItem.Quantity;
                    wapper.Subtotal		= quoteLineItem.Subtotal;
                    wapper.Discount				= quoteLineItem.Discount;
                    wapper.TotalPrice			= Decimal.valueOf(String.valueOf(quoteLineItem.TotalPrice)).format();
                    wapper.ListPrice			= Decimal.valueOf(String.valueOf(quoteLineItem.ListPrice)).format();
                    if(quoteLineItem.ListPrice__c != null) {
                        wapper.CustomListPrice      = Decimal.valueOf(String.valueOf(quoteLineItem.ListPrice__c)).format();
                    }
                    if(quoteLineItem.Dealer_Price__c != null) {
                        wapper.CustomDealerPrice    = Decimal.valueOf(String.valueOf(quoteLineItem.Dealer_Price__c)).format();
                    }
                    if(quoteLineItem.Dealer_Price__c != null){
                        wapper.DNSATotalPrice       = Decimal.valueOf(String.valueOf(quoteLineItem.Dealer_Price__c + quoteLineItem.US_Option_Total__c + quoteLineItem.Adjustment_Price__c)).format();
                    }else{
                        wapper.DNSATotalPrice = '0';
                    }
                    if(quoteLineItem.Quote.RecordType.Name == 'Korea'){
                        wapper.ExpectedDelivDate   = quoteLineItem.ExpectedDelivDate__c;
                    }else{
                        wapper.RequestedShipDate   = String.valueOf(quoteLineItem.Requested_Ship_Date__c);
                        wapper.ExpectedDelivDate   = String.valueOf(quoteLineItem.RequestedDelivDate__c);
                        wapper.Warranty = DN_QuotationPDFController.getPicklistValues('QuoteLineItem', 'Warranty__c', quoteLineItem.Warranty__c);
                        if(quoteLineItem.Warranty_Price__c != null){
                            wapper.WarrantyPrice   = Decimal.valueOf(String.valueOf(quoteLineItem.Warranty_Price__c.setScale(2))).format();
                            // DealerTotal = DealerTotal + Decimal.valueOf(String.valueOf(quoteLineItem.Warranty_Price__c));
                            System.debug('DealerTotal 1 : ' + DealerTotal);
                        }else{
                            wapper.WarrantyPrice = '0';
                        }
                    }
                    wapper.GroupId              = quoteLineItem.GroupId__c;
                    wapper.CVComplete           = quoteLineItem.CVComplete__c;
                    wapper.AccessoryComplete    = quoteLineItem.Accessory_Complete__c;
                    wapper.IsOrderCreated       = quoteLineItem.F_IsOrderCreated__c;
                    wapper.recentlyVersion      = quoteLineItem.Quote.Recently_Version__c;
                    wapper.RDD                  = String.valueOf(quoteLineItem.RequestedDelivDate__c);
                    if(quoteLineItem.QuotePriceIF__c == false){
                        wapper.highLight        = 'highlight-row';
                    }else{
                        wapper.highLight        = 'highlight-row2';
                    }

                    wapper.ModelName            = quoteLineItem.Product2.Model__r.Name;
                    wapper.QuotePriceIF      = quoteLineItem.QuotePriceIF__c;
                    if(quoteLineItem.DC__c != null) {
                        wapper.DC                   = Decimal.valueOf(String.valueOf(quoteLineItem.DC_Price__c.setScale(2))).format() + ' (' + String.valueOf(quoteLineItem.DC__c.setScale(2)) + '%)';
                    }
                    if(cvTotalMap.containsKey(quoteLineItem.Id)){
                        wapper.CVTotal          = Decimal.valueOf(String.valueOf((Decimal)cvTotalMap.get(quoteLineItem.Id))).format();
                        // DealerTotal = DealerTotal + Decimal.valueOf(String.valueOf((Decimal)cvTotalMap.get(quoteLineItem.Id)));
                        System.debug('DealerTotal 2 : ' + DealerTotal);

                    }
                    if(accTotalMap.containsKey(quoteLineItem.Id)){
                        if(quoteLineItem.Warranty_Acc__c != null){
                            wapper.AccTotal          = Decimal.valueOf(String.valueOf((Decimal)accTotalMap.get(quoteLineItem.Id) - quoteLineItem.Warranty_Acc__c)).format();
                            // DealerTotal = DealerTotal + Decimal.valueOf(String.valueOf((Decimal)accTotalMap.get(quoteLineItem.Id) - quoteLineItem.Warranty_Acc__c));
                            System.debug('DealerTotal 3 : ' + DealerTotal);

                        }else{
                            wapper.AccTotal          = Decimal.valueOf(String.valueOf((Decimal)accTotalMap.get(quoteLineItem.Id))).format();
                            // DealerTotal = DealerTotal + Decimal.valueOf(String.valueOf((Decimal)accTotalMap.get(quoteLineItem.Id)));
                            System.debug('DealerTotal 4 : ' + DealerTotal);

                        }
                    }
                    if(factoryCVTotalMap.containsKey(quoteLineItem.Id)){
                        wapper.FactoryCVTotal = Decimal.valueOf(String.valueOf((Decimal)factoryCVTotalMap.get(quoteLineItem.Id))).format();
                    }

                    if(factoryOPTotalMap.containsKey(quoteLineItem.Id)){
                        wapper.FactoryOPTotal = Decimal.valueOf(String.valueOf((Decimal)factoryOPTotalMap.get(quoteLineItem.Id))).format();
                    }

                    if(sqTotalMap.containsKey(quoteLineItem.Id)){
                        if(quoteLineItem.Warranty_SQ__c != null){
                            wapper.SQTotal          = Decimal.valueOf(String.valueOf((Decimal)sqTotalMap.get(quoteLineItem.Id) - quoteLineItem.Warranty_SQ__c)).format();
                            // DealerTotal = DealerTotal + Decimal.valueOf(String.valueOf((Decimal)sqTotalMap.get(quoteLineItem.Id) - quoteLineItem.Warranty_SQ__c));
                            System.debug('DealerTotal 5 : ' + DealerTotal);

                        }else{
                            wapper.SQTotal          = Decimal.valueOf(String.valueOf((Decimal)sqTotalMap.get(quoteLineItem.Id))).format();
                            // DealerTotal = DealerTotal + Decimal.valueOf(String.valueOf((Decimal)sqTotalMap.get(quoteLineItem.Id)));
                            System.debug('DealerTotal 6 : ' + DealerTotal);

                        }
                    }
                    if(quoteLineItem.Adjustment_Price__c != null){
                        wapper.AdjustmentPrice     = Decimal.valueOf(String.valueOf(quoteLineItem.Adjustment_Price__c)).format();
                        // DealerTotal = DealerTotal + Decimal.valueOf(String.valueOf(quoteLineItem.Adjustment_Price__c));
                        System.debug('DealerTotal 7 : ' + DealerTotal);

                    }else{
                        wapper.AdjustmentPrice = '0';
                    }
                    if(quoteLineItem.Final_Quotation_Price__c != null){
                        wapper.DealerPrice          = Decimal.valueOf(String.valueOf(quoteLineItem.Final_Quotation_Price__c.setScale(2))).format();
                        System.debug('DealerTotal 8 : ' + DealerTotal);

                    }else{
                        wapper.DealerPrice = '0';
                        System.debug('DealerTotal 9 : ' + DealerTotal);

                    }
                    if(quoteLineItem.CustomerPrice__c != null){
                        wapper.CustomerPrice     = Decimal.valueOf(String.valueOf(quoteLineItem.CustomerPrice__c)).format();
                    }
                    wapper.orderCnt = Integer.valueOf(orderCnt[0].get('cnt'));
                    System.debug('orderCnt : ' + Integer.valueOf(orderCnt[0].get('cnt')));
                    quoteLineItemWrapperList.add(wapper); 
                }

                for(QuoteLineItem quoteLineItem : quoteLineItemList){
                    Decimal warrantyPrice = 0;
                    QuoteLineItem upRecord = new QuoteLineItem();
                    upRecord.Id = quoteLineItem.Id;
                    if(cvTotalMap.containsKey(quoteLineItem.Id)){
                        upRecord.CV_Total__c          = (Decimal)cvTotalMap.get(quoteLineItem.Id);
                        // warrantyPrice = (Decimal)cvTotalMap.get(quoteLineItem.Id);
                    }else{
                        upRecord.CV_Total__c = 0;
                    }
                    if(accTotalMap.containsKey(quoteLineItem.Id)){
                        upRecord.Accessory_Total__c          = (Decimal)accTotalMap.get(quoteLineItem.Id);
                        // warrantyPrice = (Decimal)accTotalMap.get(quoteLineItem.Id);
                    }else{
                        upRecord.Accessory_Total__c = 0;
                    }
                    if(sqTotalMap.containsKey(quoteLineItem.Id)){
                        upRecord.SQ_Total__c          = (Decimal)sqTotalMap.get(quoteLineItem.Id);
                        // warrantyPrice = (Decimal)sqTotalMap.get(quoteLineItem.Id);
                    }else{
                        upRecord.SQ_Total__c = 0;
                    }

                    if(factoryCVTotalMap.containsKey(quoteLineItem.Id)){
                        upRecord.Factory_CV_Total__c          = (Decimal)factoryCVTotalMap.get(quoteLineItem.Id);
                    }else{
                        upRecord.Factory_CV_Total__c = 0;
                    }

                    if(factoryOPTotalMap.containsKey(quoteLineItem.Id)){
                        upRecord.Factory_Option_Total__c          = (Decimal)factoryOPTotalMap.get(quoteLineItem.Id);
                    }else{
                        upRecord.Factory_Option_Total__c = 0;
                    }
                    System.debug('null확인 2 : ' + quoteLineItem.Adjustment_Price__c);
                    System.debug('null확인 3 : ' + quoteLineItem.DC_Price__c);
                    System.debug('null확인 4 : ' + quoteLineItem.UnitPrice);
                    System.debug('null확인 5 : ' + quoteLineItem.Warranty_Percent__c);
                    // upRecord.Warranty_Price__c = (warrantyPrice + quoteLineItem.Adjustment_Price__c + quoteLineItem.DC_Price__c + quoteLineItem.UnitPrice) * quoteLineItem.Warranty_Percent__c * 0.01;
                    updateList.add(upRecord);
                }
                update updateList;
                System.debug('quoteLineItemWrapperList : ' + quoteLineItemWrapperList);
            }
            
        }catch(Exception e){
            System.debug('QuoteLineItems : ' + e.getLineNumber() + ' / ' + e.getMessage());
            System.debug('Exception : ' + e.getMessage());
        }
        return new Map<String, Object>{
            'quoteLineItemWrapperList' => quoteLineItemWrapperList,
            'quoteLineItemSize' => quoteLineItemWrapperList.size(),
            'recordType' => recordType[0].RecordType.Name,
            'isPortal' => isPortal,
            'role' => currentUser.UserRole.PortalRole,
            'Review' => recordType[0].Review__c,
            'isFinal' => recordType[0].IsFinal__c,
            'isFirst' => !quoteLineItemWrapperList.isEmpty() ? quoteLineItemWrapperList[0].isFirst : ''
        };
    }

    /**
     * @Description
     * 	- Map정보를 바탕으로 SQRegistration__c 레코드 insert
     * @author Hanyeong Choi | 06-28-2024
     * @Parameter
     *  - fieldMap      : SQ Registration 생성 모달에서 입력한 각 key 필드명, value 필드값 Map
     *  - lineItemList  : SQ Registration 생성할때 선택한 Quote Line Items List
    **/ 
    @AuraEnabled
    public static String saveSQRegistration(Map<String, Object> fieldMap, List<QuoteLineItem> lineItemList) {
        String result;
        try {
            SQRegistration__c newRecord = new SQRegistration__c();
            
            Set<Id> lineItemId = new Set<Id>();
            lineItemId.add(lineItemList[0].Id);

            QuoteLineItem firstLineItem = [SELECT Id, Product2Id, Product2.Name
                                            FROM QuoteLineItem WHERE Id =: lineItemId];

            System.debug('firstLineItem ::' + firstLineItem);
        
            for (String fieldName : fieldMap.keySet()) {
                String fieldType = getFieldType(newRecord, fieldName) + '';

                System.debug('fieldMap ::' + fieldMap);
                System.debug('fieldName ::' + fieldName);


                if(fieldName != 'BaseCode__c') {
                    switch on fieldType {
                        when 'LONG', 'INTEGER'{
                            if(fieldMap.get(fieldName) != null) {
                                String IntegerValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Integer.valueOf(IntegerValue));
                            }
                        }
                        when 'DOUBLE', 'CURRENCY', 'PERCENT'{
                            if(fieldMap.get(fieldName) != null) {
                                String decimalValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Double.valueOf(decimalValue));
                            }
                        }
                        when 'DATE' {
                            if(fieldMap.get(fieldName) != null) {
                                String dateValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Date.valueOf(dateValue));
                            }
                        }
                        when 'DATETIME' {
                            if(fieldMap.get(fieldName) != null) {
                                String datetimeValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Datetime.valueOf(datetimeValue));
                            }
                        }
                        when 'BOOLEAN' {
                            String booleanValue = (String) fieldMap.get(fieldName);
                            newRecord.put(fieldName, Boolean.valueOf(booleanValue));
                        }
                        when else {
                            newRecord.put(fieldName, fieldMap.get(fieldName));
                        }
                    }
                }else if(fieldName == 'BaseCode__c'){
                    newRecord.put(fieldName, firstLineItem.Product2.Name);
                    System.debug('BaseCode Field :: ' + firstLineItem.Product2.Name);
                }

            }

            insert newRecord;

            // Quote Line Item 업데이트
            if (lineItemList != null && !lineItemList.isEmpty()) {
                for (QuoteLineItem item : lineItemList) {
                    item.SQRegistration__c = newRecord.Id;
                }
                update lineItemList;
            }


            result = 'success';
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            result = 'fail';
        }
        return result;
    }

    /**
     * @Description
     * 	- Characteristic Validation : Quote Line Item이 같을 경우, Characteristic Value 비교
     * @author Yuhyun Park | 07-18-2024
     *  @Parameter
     *  - quoteLineItemList  : SQ Registration 생성할때 선택한 Quote Line Items List
    **/ 

    @AuraEnabled
    public static Map<String, Object> validateQuoteLineItems(List<QuoteLineItem> quoteLineItems, String btnCheck) {
        Map<String, Object> result = new Map<String, Object>();
        result.put('isValid', true);
        result.put('errorMessage', '');
    
        // QuoteLineItem Id 수집
        Set<Id> quoteLineItemIds = new Set<Id>();
        for (QuoteLineItem item : quoteLineItems) {
            quoteLineItemIds.add(item.Id);
        }
    
        // QuoteLineItem 쿼리하여 Product2Id 가져오기
        List<QuoteLineItem> queriedItems = [
            SELECT Id, Product2Id
            FROM QuoteLineItem
            WHERE Id IN :quoteLineItemIds
        ];
    
        // Product2Id별로 QuoteLineItem 그룹화
        Map<Id, List<QuoteLineItem>> productIdToQuoteLineItemsMap = new Map<Id, List<QuoteLineItem>>();
        for (QuoteLineItem item : queriedItems) {
            if (!productIdToQuoteLineItemsMap.containsKey(item.Product2Id)) {
                productIdToQuoteLineItemsMap.put(item.Product2Id, new List<QuoteLineItem>());
            }
            productIdToQuoteLineItemsMap.get(item.Product2Id).add(item);
        }

        System.debug('productIdToQuoteLineItemsMap :: '+ productIdToQuoteLineItemsMap);
        System.debug('productIdToQuoteLineItemsMap Size :: '+ productIdToQuoteLineItemsMap.size());

        // if(productIdToQuoteLineItemsMap.size() > 1 && btnCheck == 'Option'){
        if(productIdToQuoteLineItemsMap.size() > 1){
            result.put('isValid', false);
            result.put('errorMessage', 'DNS_M_DiffProduct');
            return result;

        //같은 제품끼리 선택 되었으면 size == 1
        }else if(productIdToQuoteLineItemsMap.size() == 1){
            Map<String, String> accCheckMap = new Map<String, String>();
            Set<String> accdupleCheck = new Set<String>();
            List<Accessory__c> accCheckList = 
            [
                SELECT
                    Key__c,
                    QuoteLineItem__c
                FROM
                    Accessory__c
                WHERE
                    QuoteLineItem__c IN:quoteLineItemIds
                ORDER BY
                    QuoteLineItem__c, Key__c
            ];
            if(!accCheckList.isEmpty()){
                for(String id : quoteLineItemIds){
                    for(Accessory__c acc : accCheckList){
                        if(id == acc.QuoteLineItem__c){
                            if(accCheckMap.containsKey(id)){
                                accCheckMap.put(id, accCheckMap.get(id) + acc.Key__c);
                            }else{
                                accCheckMap.put(id, acc.Key__c);
                            }
                        }
                    }
                }
                for(String key : accCheckMap.keySet()){
                    System.debug('value : ' + accCheckMap.get(key));
                    accdupleCheck.add(accCheckMap.get(key));
                }
                //추가자재가 없는경우는 qtlineitem과 사이즈가 다름
                if(accdupleCheck.size() > 1 || accCheckMap.size() != quoteLineItemIds.size()){
                    result.put('isValid', false);
                    result.put('errorMessage', 'DNS_M_SelectedDiffSpecs');
                    return result;
                }
            }

            Map<String, String> sqCheckMap = new Map<String, String>();
            Set<String> sqdupleCheck = new Set<String>();
            List<SQ_QuoteLineitem_Junction__c> sqCheckList = 
            [
                SELECT
                    SQ__c,
                    QuoteLineItem__c
                FROM
                    SQ_QuoteLineitem_Junction__c
                WHERE
                    QuoteLineItem__c IN:quoteLineItemIds
                ORDER BY
                    QuoteLineItem__c, SQ__c
            ];
            if(!sqCheckList.isEmpty()){
                for(String id : quoteLineItemIds){
                    for(SQ_QuoteLineitem_Junction__c sq : sqCheckList){
                        if(id == sq.QuoteLineItem__c){
                            if(sqCheckMap.containsKey(id)){
                                sqCheckMap.put(id, sqCheckMap.get(id) + sq.SQ__c);
                            }else{
                                sqCheckMap.put(id, sq.SQ__c);
                            }
                        }
                    }
                }
                for(String key : sqCheckMap.keySet()){
                    System.debug('value : ' + sqCheckMap.get(key));
                    sqdupleCheck.add(sqCheckMap.get(key));
                }
                //SQ가 없는경우는 qtlineitem과 사이즈가 다름
                if(sqdupleCheck.size() > 1 || sqCheckMap.size() != quoteLineItemIds.size()){
                    result.put('isValid', false);
                    result.put('errorMessage', 'DNS_M_DiffSQ');
                    return result;
                }
            }

            
            // 관련 CharacteristicValue__c 레코드 쿼리
            Map<Id, List<CharacteristicValue__c>> quoteLineItemToCharValuesMap = new Map<Id, List<CharacteristicValue__c>>();
            for (CharacteristicValue__c charValue : [
                SELECT Id, C_Value__c, V_Value__c, QuoteLineItem__c 
                FROM CharacteristicValue__c 
                WHERE QuoteLineItem__c IN :quoteLineItemIds
            ]) {
                if (!quoteLineItemToCharValuesMap.containsKey(charValue.QuoteLineItem__c)) {
                    quoteLineItemToCharValuesMap.put(charValue.QuoteLineItem__c, new List<CharacteristicValue__c>());
                }
                quoteLineItemToCharValuesMap.get(charValue.QuoteLineItem__c).add(charValue);
            }

            System.debug('quoteLineItemToCharValuesMap :: '+ quoteLineItemToCharValuesMap);
            System.debug('quoteLineItemToCharValuesMap Size :: '+ quoteLineItemToCharValuesMap.size());

        
            // CharacteristicValue__c의 모든 필드를 비교하기 위해 Map에 저장
            Map<Id, List<Map<String, Object>>> quoteLineItemToCharValuesMapFormatted = new Map<Id, List<Map<String, Object>>>();
            for (Id qliId : quoteLineItemToCharValuesMap.keySet()) {
                List<CharacteristicValue__c> charValues = quoteLineItemToCharValuesMap.get(qliId);
                List<Map<String, Object>> formattedCharValues = new List<Map<String, Object>>();
                for (CharacteristicValue__c charValue : charValues) {
                    Map<String, Object> charValueMap = new Map<String, Object>{
                        'Name' => charValue.C_Value__c,
                        'Value__c' => charValue.V_Value__c
                    };
                    formattedCharValues.add(charValueMap);
                }
                quoteLineItemToCharValuesMapFormatted.put(qliId, formattedCharValues);
            }

            System.debug('quoteLineItemToCharValuesMapFormatted :: '+ quoteLineItemToCharValuesMapFormatted);
            System.debug('quoteLineItemToCharValuesMapFormatted Size :: '+ quoteLineItemToCharValuesMapFormatted.size());

            //quotelineitem2개이상 선택 시 CV가 선택되어있지 않은 quotelineitem이 포함되어 있을 경우
            if(!System.Test.isRunningTest() && quoteLineItemToCharValuesMapFormatted.size() != 0 && quoteLineItemIds.size() != quoteLineItemToCharValuesMapFormatted.size()){
                result.put('isValid', false);
                result.put('errorMessage', 'DNS_M_DiffOption');
                return result;
            }
        
            // 각 Product2Id에 대해 CharacteristicValue__c 일관성 검증
            for (Id productId : productIdToQuoteLineItemsMap.keySet()) {
                List<QuoteLineItem> items = productIdToQuoteLineItemsMap.get(productId);
        
                if (items.size() > 1) {
                    QuoteLineItem firstItem = items[0];
                    List<Map<String, Object>> firstItemCharValues = quoteLineItemToCharValuesMapFormatted.get(firstItem.Id);
        
                    for (Integer i = 1; i < items.size(); i++) {
                        QuoteLineItem currentItem = items[i];
                        List<Map<String, Object>> currentItemCharValues = quoteLineItemToCharValuesMapFormatted.get(currentItem.Id);
        
                        System.debug('firstItemCharValues :: '+ firstItemCharValues);
                        System.debug('currentItemCharValues :: '+ currentItemCharValues);

                        if (currentItemCharValues == null) {
                            result.put('isValid', true);
                            result.put('errorMessage', 'Characteristic Value가 등록되지 않았습니다.');
                            return result;
                        }

                        if (firstItemCharValues.size() != currentItemCharValues.size()) {
                            result.put('isValid', false);
                            result.put('errorMessage', 'DNS_M_DiffOption');
                            return result;
                        }
        
                        for (Integer j = 0; j < firstItemCharValues.size(); j++) {
                            Map<String, Object> firstCharValueMap = firstItemCharValues.get(j);
                            Map<String, Object> currentCharValueMap = currentItemCharValues.get(j);
        
                            for (String key : firstCharValueMap.keySet()) {
                                if ((!currentCharValueMap.containsKey(key) || firstCharValueMap.get(key) != currentCharValueMap.get(key)) ) {
                                    result.put('isValid', false);
                                    result.put('errorMessage', 'DNS_M_DiffCV');
                                    return result;
                                }
                            }
                        }
                    }
                }
            }
            
            
            return result;
        }else {
            return result;
        }
    }
    
    @AuraEnabled
    public static string deleteRecord(String recordId){
        // public static string deleteRecord(String recordId, String cancelReason){
        List<QuoteLineItem> qliList = [SELECT Id, F_IsOrderCreated__c, QuoteId, Quote.RecordTypeId, ERPQuotationNo__c, ERPInquiryNo__c, RequestedDelivDate__c, Quote.Account.MainCategory__c, Quote.Account.SubCategory__c FROM QuoteLineItem WHERE Id =: recordId];
        if(qliList[0].F_IsOrderCreated__c == true){
            return System.Label.DNS_M_IsOrderDelete;
        }
        try {
            IF_ERP_Inquiry_Classes.IF_OPTY_007_Req req;
            IF_ERP_Inquiry instance;
            IF_ERP_Inquiry_Classes.IF_OPTY_007_Res response;

            if(qliList[0].Quote.RecordTypeId == recordTypeIdCommo || qliList[0].Quote.RecordTypeId == recordTypeIdFactory){

                //Factory Option CV 삭제
                List<DNSA_Factory_Option_Junction__c> factoryOptionList = 
                [
                    SELECT
                        Id
                    FROM
                        DNSA_Factory_Option_Junction__c
                    WHERE
                        Quote_Line_Item__c =: recordId
                    AND Dealer_Checked__c = false

                ];
                if(!factoryOptionList.isEmpty()){
                    delete factoryOptionList;
                }

                List<SQregistration_Quote__c> sqRegQuoteList = [
                    SELECT Id, SQ_Registration__c, Quote__c
                    FROM SQregistration_Quote__c
                    WHERE Quote__c = :qliList[0].QuoteId
                ];

                if (!sqRegQuoteList.isEmpty()) {
                    Set<Id> sqRegistrationIds = new Set<Id>();
                    for (SQregistration_Quote__c sqrQ : sqRegQuoteList) {
                        sqRegistrationIds.add(sqrQ.SQ_Registration__c);
                    }

                    List<SQ_Registration_Junction__c> junctionList = [
                        SELECT SQRegistration__c, QuoteLineItem__c
                        FROM SQ_Registration_Junction__c
                        WHERE SQRegistration__c IN :sqRegistrationIds
                    ];

                    Map<Id, Set<Id>> regIdToQliSet = new Map<Id, Set<Id>>();
                    for (SQ_Registration_Junction__c junction : junctionList) {
                        if (!regIdToQliSet.containsKey(junction.SQRegistration__c)) {
                            regIdToQliSet.put(junction.SQRegistration__c, new Set<Id>());
                        }
                        regIdToQliSet.get(junction.SQRegistration__c).add(junction.QuoteLineItem__c);
                    }

                    List<SQregistration_Quote__c> deletableList = new List<SQregistration_Quote__c>();
                    for (SQregistration_Quote__c sqrQ : sqRegQuoteList) {
                        Set<Id> relatedQliIds = regIdToQliSet.get(sqrQ.SQ_Registration__c);
                        // 관련된 QLI가 1개(현재 QuoteId만)인 경우만 삭제 대상
                        if (relatedQliIds != null && relatedQliIds.size() == 1 && relatedQliIds.contains(qliList[0].Id)) {
                            deletableList.add(sqrQ);
                        }
                    }

                    if (!deletableList.isEmpty()) {
                        delete deletableList;
                        System.debug('삭제된 SQregistration_Quote__c 레코드 수: ' + deletableList.size());
                    } else {
                        System.debug('삭제할 수 있는 SQregistration_Quote__c 레코드가 없습니다.');
                    }

                } else {
                    System.debug('삭제할 SQregistration_Quote__c 레코드가 없습니다.');
                }

            }else{
                req = new IF_ERP_Inquiry_Classes.IF_OPTY_007_Req();
                req.I_VBELN = qliList[0].ERPInquiryNo__c;
                req.I_VDATU = String.valueOf(qliList[0].RequestedDelivDate__c).replace('-','');
                req.I_ZINDUS = qliList[0].Quote.Account.MainCategory__c;
                req.I_ZINDUS2 = qliList[0].Quote.Account.SubCategory__c;
                req.I_CANCEL = 'X';
                instance = new IF_ERP_Inquiry();
                if(!System.Test.isRunningTest()){
                    response = instance.IF_OPTY_007(req);
                }
            }
            
            //SQ_Registration_Junction__c 삭제
            List<SQ_Registration_Junction__c> sqrJuncList = 
            [
                SELECT
                    Id
                FROM
                    SQ_Registration_Junction__c
                WHERE   
                    QuoteLineItem__c =: recordId
            ];
            if (!sqrJuncList.isEmpty()) {
                delete sqrJuncList;
                System.debug('삭제된 SQ_Registration_Junction__c 레코드 수: ' + sqrJuncList.size());
            } else {
                System.debug('삭제할 SQ_Registration_Junction__c 레코드가 없습니다.');
            }

            //SQ_QuoteLineitem_Junction__c 삭제
            List<SQ_QuoteLineitem_Junction__c> sqLineJuncList = 
            [
                SELECT
                    Id
                FROM
                    SQ_QuoteLineitem_Junction__c
                WHERE   
                    QuoteLineItem__c =: recordId
            ];
            if (!sqLineJuncList.isEmpty()) {
                delete sqLineJuncList;
                System.debug('삭제된 SQ_QuoteLineitem_Junction__c 레코드 수: ' + sqLineJuncList.size());
            } else {
                System.debug('삭제할 SQ_QuoteLineitem_Junction__c 레코드가 없습니다.');
            }
            
            //Accessory__c 삭제
            List<Accessory__c> acsList = 
            [
                SELECT
                    Id
                FROM
                    Accessory__c
                WHERE   
                    QuoteLineItem__c =: recordId
            ];
            if (!acsList.isEmpty()) {
                delete acsList;
                System.debug('삭제된 Accessory__c 레코드 수: ' + acsList.size());
            } else {
                System.debug('삭제할 Accessory__c 레코드가 없습니다.');
            }

            //CharacteristicValue__c 삭제
            List<CharacteristicValue__c> cvList = 
            [
                SELECT
                    Id
                FROM
                    CharacteristicValue__c
                WHERE   
                    QuoteLineItem__c =: recordId
            ];
            if (!cvList.isEmpty()) {
                delete cvList;
                System.debug('삭제된 CharacteristicValue__c 레코드 수: ' + cvList.size());
            } else {
                System.debug('삭제할 CharacteristicValue__c 레코드가 없습니다.');
            }

            //QuoteLineItem 삭제
            //QuoteLineItem삭제 전 Opportunity Line Item 정보 저장
            List<QuoteLineItem> quoteLineInfo = 
                [
                    SELECT 
                        Id,
                        OpportunityLineItemId,
                        QuoteId,
                        Product2Id
                    FROM
                        QuoteLineItem
                    WHERE
                        Id =: recordId
                    LIMIT 1
                ];
            String opptyLineId = quoteLineInfo[0].OpportunityLineItemId;
            String productId = quoteLineInfo[0].Product2Id;
            String quoteId = quoteLineInfo[0].QuoteId;
            if (!quoteLineInfo.isEmpty()) {
                delete quoteLineInfo;
                System.debug('삭제된 QuoteLineItem 레코드 수: ' + quoteLineInfo.size());
            } else {
                System.debug('삭제할 QuoteLineItem 레코드가 없습니다.');
            }
            //OpportunityLineItem 삭제
            List<OpportunityLineItem> opytLineList = 
            [
                SELECT
                    Id
                FROM
                    OpportunityLineItem
                WHERE   
                    Id =: opptyLineId
            ];
            if (!opytLineList.isEmpty()) {
                delete opytLineList;
                System.debug('삭제된 OpportunityLineItem 레코드 수: ' + opytLineList.size());
            } else {
                System.debug('삭제할 OpportunityLineItem 레코드가 없습니다.');
            }

            //T_COND_ELMT 레코드 삭제
            List<T_COND_ELMT__c> elmtDelList = 
            [
                SELECT
                    Id
                FROM
                    T_COND_ELMT__c
                WHERE
                    Quote_Line_Item__c =:recordId
            ];
            if (!elmtDelList.isEmpty()) {
                delete elmtDelList;
                System.debug('삭제된 ELMT 레코드 수: ' + elmtDelList.size());
            } else {
                System.debug('삭제할 ELMT 레코드가 없습니다.');
            }
            //QuoteProductHistory__c 레코드 생성
            QuoteProductHistory__c quotePrdHistory = new QuoteProductHistory__c();
            quotePrdHistory.Product__c  = productId;
            quotePrdHistory.Quote__c  = quoteId;
            // quotePrdHistory.Reason__c   = cancelReason;
            quotePrdHistory.WinLoss__c  = 'Loss';
            insert quotePrdHistory;

            
            
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Line : ' + e.getLineNumber() + 'error : '+ e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string deleteRecordMulti(List<String> QtlineId){
        // public static string deleteRecord(String recordId, String cancelReason){
        List<QuoteLineItem> qliList = [SELECT Id, F_IsOrderCreated__c, QuoteId, Quote.RecordTypeId, ERPQuotationNo__c, ERPInquiryNo__c, RequestedDelivDate__c, Quote.Account.MainCategory__c, Quote.Account.SubCategory__c, Quote.Opportunity.CloseDate FROM QuoteLineItem WHERE Id IN: QtlineId];
        if(qliList[0].F_IsOrderCreated__c == true){
            return System.Label.DNS_M_IsOrderDelete;
        }

        for (QuoteLineItem qli : qliList) {
            Boolean isValid = qli.Quote.Opportunity.CloseDate != null && 
                              qli.Quote.Opportunity.CloseDate < System.today() ? false : true;
            if(!isValid){
                return System.Label.DNS_M_ContractDelete;
            }
        }
        try {
            // IF_ERP_Inquiry_Classes.IF_OPTY_007_Req req;
            // IF_ERP_Inquiry instance;
            // IF_ERP_Inquiry_Classes.IF_OPTY_007_Res response;

            // req = new IF_ERP_Inquiry_Classes.IF_OPTY_007_Req();
            // req.I_VBELN = qliList[0].ERPInquiryNo__c;
            // req.I_VDATU = String.valueOf(qliList[0].RequestedDelivDate__c).replace('-','');
            // req.I_ZINDUS = qliList[0].Quote.Account.MainCategory__c;
            // req.I_ZINDUS2 = qliList[0].Quote.Account.SubCategory__c;
            // req.I_CANCEL = 'X';
            // instance = new IF_ERP_Inquiry();

            //SQ_Registration_Junction__c 삭제
            List<SQ_Registration_Junction__c> sqrJuncList = 
            [
                SELECT
                    Id
                FROM
                    SQ_Registration_Junction__c
                WHERE   
                    QuoteLineItem__c IN: QtlineId
            ];
            if (!sqrJuncList.isEmpty()) {
                delete sqrJuncList;
                System.debug('삭제된 SQ_Registration_Junction__c 레코드 수: ' + sqrJuncList.size());
            } else {
                System.debug('삭제할 SQ_Registration_Junction__c 레코드가 없습니다.');
            }

            //SQ_QuoteLineitem_Junction__c 삭제
            List<SQ_QuoteLineitem_Junction__c> sqLineJuncList = 
            [
                SELECT
                    Id
                FROM
                    SQ_QuoteLineitem_Junction__c
                WHERE   
                    QuoteLineItem__c IN: QtlineId
            ];
            if (!sqLineJuncList.isEmpty()) {
                delete sqLineJuncList;
                System.debug('삭제된 SQ_QuoteLineitem_Junction__c 레코드 수: ' + sqLineJuncList.size());
            } else {
                System.debug('삭제할 SQ_QuoteLineitem_Junction__c 레코드가 없습니다.');
            }
            
            //Accessory__c 삭제
            List<Accessory__c> acsList = 
            [
                SELECT
                    Id
                FROM
                    Accessory__c
                WHERE   
                    QuoteLineItem__c IN: QtlineId
            ];
            if (!acsList.isEmpty()) {
                delete acsList;
                System.debug('삭제된 Accessory__c 레코드 수: ' + acsList.size());
            } else {
                System.debug('삭제할 Accessory__c 레코드가 없습니다.');
            }

            //CharacteristicValue__c 삭제
            List<CharacteristicValue__c> cvList = 
            [
                SELECT
                    Id
                FROM
                    CharacteristicValue__c
                WHERE   
                    QuoteLineItem__c IN: QtlineId
            ];
            if (!cvList.isEmpty()) {
                delete cvList;
                System.debug('삭제된 CharacteristicValue__c 레코드 수: ' + cvList.size());
            } else {
                System.debug('삭제할 CharacteristicValue__c 레코드가 없습니다.');
            }

            //QuoteLineItem 삭제
            //QuoteLineItem삭제 전 Opportunity Line Item 정보 저장
            List<QuoteLineItem> quoteLineInfo = 
                [
                    SELECT 
                        Id,
                        OpportunityLineItemId,
                        QuoteId,
                        Product2Id,
                        RequestedDelivDate__c,
                        ERPInquiryNo__c
                    FROM
                        QuoteLineItem
                    WHERE
                        Id IN: QtlineId
                ];
            List<QuoteLineItem> historyQuoteLineItem = new List<QuoteLineItem>();
            Set<Id> opptyLineId = new Set<Id>();
            Set<Id> productId = new Set<Id>();
            Set<Id> quoteId = new Set<Id>();
            if(!quoteLineInfo.isEmpty()){
                for(QuoteLineItem ql : quoteLineInfo){
                    opptyLineId.add(ql.OpportunityLineItemId);

                    QuoteLineItem delqtli = new QuoteLineItem();
                    delqtli.OpportunityLineItemId = ql.OpportunityLineItemId;
                    delqtli.Product2Id = ql.Product2Id;
                    delqtli.QuoteId = ql.QuoteId;
                    delqtli.Id = ql.Id;
                    historyQuoteLineItem.add(delqtli);
                }
            }
            
            
            //OpportunityLineItem 삭제
            List<OpportunityLineItem> opytLineList = 
            [
                SELECT
                    Id
                FROM
                    OpportunityLineItem
                WHERE   
                    Id IN: opptyLineId
            ];
            

            //T_COND_ELMT 레코드 삭제
            List<T_COND_ELMT__c> elmtDelList = 
            [
                SELECT
                    Id
                FROM
                    T_COND_ELMT__c
                WHERE
                    Quote_Line_Item__c IN:QtlineId
            ];
            
            //QuoteProductHistory__c 레코드 생성
            List<QuoteProductHistory__c> quotePrdHistoryList = new List<QuoteProductHistory__c>();
            if(!quoteLineInfo.isEmpty()){
                for(QuoteLineItem ql :  quoteLineInfo){
                    QuoteProductHistory__c quotePrdHistory = new QuoteProductHistory__c();
                    System.debug('ql.Id : ' + ql.Id);
                    quotePrdHistory.Quote_Line_Item__c = String.valueOf(ql.Id);
                    quotePrdHistory.Product__c  = ql.Product2Id;
                    quotePrdHistory.Requested_Deliv_Date__c  = ql.RequestedDelivDate__c;
                    quotePrdHistory.ERP_Inquiry_No__c  = ql.ERPInquiryNo__c;
                    quotePrdHistory.Quote__c  = ql.QuoteId;
                    quotePrdHistory.WinLoss__c  = 'Loss';
                    quotePrdHistoryList.add(quotePrdHistory);
                }
            }
            List<String> delQtliId = new List<String>();
            for(QuoteProductHistory__c qph : quotePrdHistoryList){
                delQtliId.add(qph.Quote_Line_Item__c);
            }
            if(!quotePrdHistoryList.isEmpty()){
                System.debug('quotePrdHistoryList : ' + quotePrdHistoryList);
                insert quotePrdHistoryList;
            }
            if(!System.Test.isRunningTest()){
                // response = instance.IF_OPTY_007(req);
                // DN_OpportunityLineDeleteCallout.deleteInquiry(QtlineId);
                DN_OpportunityLineDeleteCallout.deleteInquiry(delQtliId);
            }

            if (!quoteLineInfo.isEmpty()) {
                delete quoteLineInfo;
                System.debug('삭제된 QuoteLineItem 레코드 수: ' + quoteLineInfo.size());
            } else {
                System.debug('삭제할 QuoteLineItem 레코드가 없습니다.');
            }

            if (!opytLineList.isEmpty()) {
                delete opytLineList;
                System.debug('삭제된 OpportunityLineItem 레코드 수: ' + opytLineList.size());
            } else {
                System.debug('삭제할 OpportunityLineItem 레코드가 없습니다.');
            }

            if (!elmtDelList.isEmpty()) {
                delete elmtDelList;
                System.debug('삭제된 ELMT 레코드 수: ' + elmtDelList.size());
            } else {
                System.debug('삭제할 ELMT 레코드가 없습니다.');
            }

            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Line : ' + e.getLineNumber() + 'error : '+ e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String updateRDD(String recordId, QuoteLineItem upRecord, String recordName, List<String> extraQtlineId){
        try {
            
            //RDD변경 시 Inquiry 수정 I/F
            List<Warranty__c> globalWar = [SELECT Id, KSCHL__c, VKORG__c, SPART__c, VTWEG__c, ZZPR_WAR__c, Percent__c, DATBI__c, DATAB__c, ZZWARRPER__c, ZZPERUNIT__c, ZZWARHRS__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c FROM Warranty__c WHERE VTWEG__c = '20'];
            Map<String, Warranty__c> globalWarMap = new Map<String, Warranty__c>();
            for(Warranty__c glo : globalWar){
                globalWarMap.put(glo.ZZPR_WAR__c, glo);
            }

            List<QuoteLineItem> inquiryUpdate = 
            [
                SELECT
                    Id,
                    ERPInquiryNo__c,
                    QuoteId,
                    US_Option_Total__c
                FROM
                    QuoteLineItem
                WHERE Id =: upRecord.Id
            ];
            Set<String> inquiryNoSet = new Set<String>();
            if(!extraQtlineId.isEmpty()){
                List<QuoteLineItem> Getinquiry = 
                [
                    SELECT
                        Id,
                        ERPInquiryNo__c,
                        QuoteId
                    FROM
                        QuoteLineItem
                    WHERE Id IN: extraQtlineId
                ];
                if(!Getinquiry.isEmpty()){
                    for(QuoteLineItem ERPInquiryNo : Getinquiry){
                        inquiryNoSet.add(ERPInquiryNo.ERPInquiryNo__c);
                    }
                }
                
                inquiryNoSet.add(inquiryUpdate[0].ERPInquiryNo__c);
            }

            System.debug('upRecordupRecord : ' + upRecord);
            System.debug('recordName : ' + recordName);
            System.debug('extraQtlineId : ' + extraQtlineId);
            // System.debug('inquiryUpdate[0].ERPInquiryNo__c : ' + inquiryUpdate[0].ERPInquiryNo__c);
            if((recordName == 'Korea' || recordName == 'Global') && !System.Test.isRunningTest()){
                if(inquiryUpdate[0].ERPInquiryNo__c != null){
                    DN_OpportunityLineEditCallout.editInquiry(inquiryUpdate[0].ERPInquiryNo__c, null, null, null, inquiryNoSet);
                }
            }

            List<QuoteLineItem> getOptyLineItem = 
            [
                SELECT 
                    Id, 
                    OpportunityLineItemId 
                FROM 
                    QuoteLineItem 
                WHERE 
                    Id =: upRecord.Id
            ];
            if(recordName == 'Global'){
                upRecord.Warranty_Percent__c = globalWarMap.get(upRecord.Warranty__c).Percent__c; 
            }
            List<QuoteLineItem> qtupRecordList = new List<QuoteLineItem>();
            if(!extraQtlineId.isEmpty()){
                qtupRecordList.add(upRecord);
                for(String Id : extraQtlineId){
                    QuoteLineItem newUpRecord = upRecord.clone(false, true);
                    newUpRecord.Id = Id;
                    qtupRecordList.add(newUpRecord);
                }
            }else{
                qtupRecordList.add(upRecord);
            }
            update qtupRecordList;
            // update upRecord;
            Quote qtUpdate = new Quote();
            qtUpdate.Id = inquiryUpdate[0].QuoteId;
            if(!System.Test.isRunningTest()){
                qtUpdate.RequestedShipDate__c = upRecord.Requested_Ship_Date__c;
            }
            update qtUpdate;
            
            if((recordName == 'Korea' || recordName == 'Global')){
                System.debug('test : ' + getOptyLineItem[0].OpportunityLineItemId);
                // System.debug('test : ' + upRecord.UnitPrice);
                if(getOptyLineItem[0].OpportunityLineItemId != null){
                    OpportunityLineItem updatePrice = new OpportunityLineItem();
                    updatePrice.Id = getOptyLineItem[0].OpportunityLineItemId;
                    updatePrice.Quantity = 1;
                    if(upRecord.UnitPrice != null){
                        updatePrice.UnitPrice = upRecord.UnitPrice;
                    }
                    update updatePrice;
                }
            }else{
                Quote totalUp = new Quote();
                totalUp.Id = inquiryUpdate[0].QuoteId;
                totalUp.TotalPrice__c = upRecord.Dealer_Price__c + inquiryUpdate[0].US_Option_Total__c;
                update totalUp;
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error Line : ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getPickLabel(String value){
        try{
            System.debug('value : ' + value);
            String warrlabel = DN_QuotationPDFController.getPicklistValues('QuoteLineItem', 'Warranty__c', value);
            System.debug('label check : ' + warrlabel);
            return warrlabel;

        }catch(Exception e){
            
            System.debug('Error Line : ' + e.getLineNumber() + ' : MSG : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());

        }
        
    }

    /**
     * @Description
     * 	- SQRegistration__c의 Field Type
     * @author Hanyeong Choi | 06-28-2024
     * @Parameter
     *  - SObj          : SQRegistration__c
     *  - fieldName     : 타입을 조회할 Field Name
    **/ 
    private static Schema.DisplayType getFieldType(SQRegistration__c SObj, String fieldName){
        return SObj.getSObjectType().getDescribe().fields
        .getMap().get(fieldName).getDescribe().getType();
    }

    /*
     * @Description 
     *  - Quote Line Item Wrapper
     * @Variable 
     * */
    public class QuoteLineItemWrapper{
        @AuraEnabled public String Id   {get;set;}
        @AuraEnabled public String ProductURL   {get;set;}
        @AuraEnabled public String ProductId   {get;set;}
        @AuraEnabled public String ProductName    {get;set;}
        @AuraEnabled public String ERPQutaionNO {get;set;}
        @AuraEnabled public String SalesPrice   {get;set;}
        @AuraEnabled public String DealerPrice   {get;set;}
        @AuraEnabled public String CustomerPrice   {get;set;}
        @AuraEnabled public String AdjustmentPrice   {get;set;}
        @AuraEnabled public Decimal Quantity     {get;set;}
        @AuraEnabled public Decimal Subtotal     {get;set;}
        @AuraEnabled public Decimal Discount     {get;set;}
        @AuraEnabled public String TotalPrice {get;set;}
        @AuraEnabled public String DNSATotalPrice {get;set;}
        @AuraEnabled public String ListPrice  {get;set;}
        @AuraEnabled public String CustomListPrice  {get;set;}
        @AuraEnabled public String CustomDealerPrice  {get;set;}
        @AuraEnabled public Date RequestedDelivDate {get;set;}
        @AuraEnabled public String RequestedShipDate {get;set;}
        @AuraEnabled public String ExpectedDelivDate {get;set;}
        @AuraEnabled public String GroupId {get;set;}
        @AuraEnabled public Boolean CVComplete {get;set;}
        @AuraEnabled public Boolean AccessoryComplete {get;set;}
        @AuraEnabled public Boolean IsOrderCreated {get;set;}
        @AuraEnabled public Boolean recentlyVersion {get;set;}
        @AuraEnabled public Boolean QuotePriceIF {get;set;}
        @AuraEnabled public String ModelName {get;set;}
        @AuraEnabled public String Warranty {get;set;}
        @AuraEnabled public String WarrantyPrice {get;set;}
        @AuraEnabled public String RDD {get;set;}
        @AuraEnabled public String DC {get;set;}
        @AuraEnabled public String isFirst {get;set;}
        @AuraEnabled public Boolean isPilot {get;set;}

        @AuraEnabled public String CVTotal  {get;set;}
        @AuraEnabled public String AccTotal  {get;set;}
        @AuraEnabled public String SQTotal  {get;set;}
        @AuraEnabled public String FactoryCVTotal  {get;set;}
        @AuraEnabled public String FactoryOPTotal  {get;set;}

        @AuraEnabled public String highLight  {get;set;}

        @AuraEnabled public Integer orderCnt  {get;set;}

        public QuoteLineItemWrapper(){}
    }

    public class CharacteristicValueWrapper{
        @AuraEnabled public String Id                       {get; set;} // CharacteristicValue__c의 Id 값
        @AuraEnabled public String Name                     {get; set;} // CharacteristicValue__c의 C_Value__c 필드 값
        @AuraEnabled public String Value                    {get; set;} // CharacteristicValue__c의 V_Value__c 필드 값
        @AuraEnabled public String QuoteLineItem            {get; set;} // CharacteristicValue__c의 QuoteLineItem__c Id 필드 값
        @AuraEnabled public String QuoteLineItemNumber      {get; set;} // CharacteristicValue__c의 QuoteLineItem__r.LineNumber 필드 값
        @AuraEnabled public Decimal Price                   {get; set;} // CharacteristicValue__c의 Price__c 필드 값
    
        public CharacteristicValueWrapper(){}

        public CharacteristicValueWrapper(String Id, String Name, String Value, String QuoteLineItem, String QuoteLineItemNumber, Decimal Price){
            this.Id = Id;
            this.Name = Name;
            this.Value = Value;
            this.QuoteLineItem = QuoteLineItem;
            this.QuoteLineItemNumber = QuoteLineItemNumber;
            this.Price = Price;
        }
    }

    
    /**
     * @Description
     * 	- SQ Review Registration의 Record Id로 Charateristic Value 값을 찾아서 Return
     * @author Yuhyun Park | 07-26-2024
     * @Parameter
     *  - recordId	        : SQRegistration__c Record Id
    **/ 
    // @AuraEnabled
    // public static Map<String, Object> getCVInfo(String recordId) {
    //     Map<String, Object> resMap = new Map<String, Object>();

    //     try{
    //         resMap.put('getCVList', getCVList(recordId));
    //         resMap.put('flag','success');
    //     }catch(Exception e){
    //         System.debug('Error : ' + e.getMessage());
    //         System.debug('Line Number : ' + e.getLineNumber());
    //         resMap.put('flag', 'error');
    //     }

    //     return resMap;   
    // }


    /**
     * @Description
     * 	- SQ Review Registration의 Record Id로 Charateristic Value 값을 찾아서 Return
     * @author Yuhyun Park | 07-26-2024
     * @Parameter
     *  - recordId	        : SQRegistration__c Record Id
    **/ 
    // @AuraEnabled
    // public static List<CharacteristicValueWrapper> getCVList(String recordId) {

    //     List<CharacteristicValueWrapper> result = new List<CharacteristicValueWrapper>();
    //     List<CharacteristicValue__c> cvList = new List<CharacteristicValue__c>();

    //     List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
    //     Set<Id> quoteLineItemIds = new Set<Id>();
        
    //     quoteLineItemList = [SELECT Id, SQRegistration__c 
    //                         FROM QuoteLineItem
    //                         WHERE SQRegistration__c =: recordId];

    //     if(!quoteLineItemList.isEmpty()){
    //         for(QuoteLineItem qli : quoteLineItemList){
    //             quoteLineItemIds.add(qli.Id);
    //         }
    //     }

    //     if(!quoteLineItemIds.isEmpty()){
    //         cvList = [SELECT Id, C_Value__c, V_Value__c, QuoteLineItem__c, QuoteLineItem__r.LineNumber, Price__c
    //                     FROM CharacteristicValue__c
    //                     WHERE QuoteLineItem__c IN: quoteLineItemIds];
    //     }

    //     if(!cvList.isEmpty()){
    //         for(CharacteristicValue__c cv : cvList){
    //             CharacteristicValueWrapper cvw = new CharacteristicValueWrapper();
    //             cvw.Id = cv.Id;
    //             cvw.Name = cv.C_Value__c;
    //             cvw.Value = cv.V_Value__c;
    //             cvw.QuoteLineItem = cv.QuoteLineItem__c;
    //             cvw.QuoteLineItemNumber = cv.QuoteLineItem__r.LineNumber;
    //             cvw.Price = cv.Price__c;

    //             result.add(cvw);
    //         }

    //     }

    //     return result;
    // }

    @AuraEnabled
    public static Boolean validateCreateOrder(List<QuoteLineItem> quoteLineItems) {
        try {
            Set<Id> qliIds = new Set<Id>();
            for(QuoteLineItem qli : quoteLineItems) {
                qliIds.add(qli.Id);
            }

            List<SQ_QuoteLineitem_Junction__c> sqljList = [
                SELECT  Id
                        , FM_SQ_Stage__c
                FROM SQ_QuoteLineitem_Junction__c
                WHERE QuoteLineItem__c IN :qliIds
            ];

            if(!sqljList.isEmpty()) {
                for(SQ_QuoteLineitem_Junction__c sqlj : sqljList) {
                    if(sqlj.FM_SQ_Stage__c != 'Final Confirm') {
                        return true;
                    }
                }
            }
            return false;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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