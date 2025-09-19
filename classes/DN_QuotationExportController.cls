/**
 * @description       : 
 * @author            : Sejin Kwon
 * @group             : 
 * @last modified on  : 2025-05-26
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-05-2024   Sejin Kwon     Initial Version
 * 2.0   07-15-2024   Sejin Kwon     Add Divide Korea/Global
**/
public with sharing class DN_QuotationExportController {

    @AuraEnabled
    public static Map<String, Object> getInfo(String recordId){
        Quote recordType = [
                            SELECT 
                                RecordType.DeveloperName
                            FROM
                                Quote
                            WHERE
                                 Id =: recordId
                            LIMIT 1
                            ];
        System.debug('recordType : ' + recordType.RecordType.DeveloperName);
        Map<String, Object> result = new Map<String, Object>();

        if(recordType.RecordType.DeveloperName == 'Korea'){
            try {
                List<Quote> quoteInfo = [SELECT 
                                            Id, 
                                            QuoteNumber,
                                            Account.Name, 
                                            ExpectedDelivDate__c, 
                                            IncotermsKR__c,
                                            PaymentConditionKR__c, 
                                            CreatedDate,
                                            Opportunity.Opportunity_Owner__r.SalesOffice__c,
                                            Opportunity.Opportunity_Owner__r.Title,
                                            Opportunity.Opportunity_Owner__r.LastName,
                                            Opportunity.Opportunity_Owner__r.Account.ShippingStreet,
                                            Opportunity.Opportunity_Owner__r.Account.fm_address__c,
                                            Opportunity.Opportunity_Owner__r.Account.Phone,
                                            Opportunity.Opportunity_Owner__r.Phone,
                                            Opportunity.Opportunity_Owner__r.Contact.Phone,
                                            Opportunity.Opportunity_Owner__r.Profile.UserLicense.Name,
                                            Opportunity.Opportunity_Owner__r.Address_PDF__c,
                                            Opportunity.Opportunity_Owner__r.MobilePhone,
                                            Opportunity.Opportunity_Owner__r.Account.Mobile__c,
                                            Opportunity.Owner.UserRole.PortalRole,
                                            Opportunity.Owner.Account.Name,
                                            Opportunity.Owner.Account.Email__c,
                                            Opportunity.Owner.Account.Representative__c,
                                            Opportunity.Opportunity_Owner__r.Email,
                                            Opportunity.Opportunity_Owner__r.Account.Email__c,
                                            OwnerId
                                        FROM Quote 
                                        WHERE Id =:recordId];
                
                String keyField = DN_QuotationPDFController.getKeyfield(recordId);
                String title = '';
                User owner = DN_WithoutSharingClass.getUserEmail(quoteInfo[0].OwnerId);
                if(quoteInfo[0].Opportunity.Opportunity_Owner__r.Title != null){
                    title = quoteInfo[0].Opportunity.Opportunity_Owner__r.Title;
                }
                if(String.valueOf(quoteInfo[0].Opportunity.Opportunity_Owner__r.Profile.UserLicense.Name).contains('Partner')){
                    //포탈유저인데 직원인경우
                    if(quoteInfo[0].Opportunity.Owner.UserRole.PortalRole == 'Worker'){
                        result.put('roleType', 'Worker');
                        result.put('quotesalesoffice', '영업 담당자 : ' + quoteInfo[0].Opportunity.Opportunity_Owner__r.LastName + ' ' + title);
                        if(owner.MobilePhone != null) {
                            result.put('mobilephone', '휴대폰 : ' + owner.MobilePhone);
                        }else{
                            result.put('mobilephone', '휴대폰 : ');
                        }
                        if(quoteInfo[0].Opportunity.Opportunity_Owner__r.Email != null && quoteInfo[0].Opportunity.Opportunity_Owner__r.Email != ''){
                            result.put('mainEmail', 'E-mail : ' + quoteInfo[0].Opportunity.Opportunity_Owner__r.Email);
                        }else{
                            result.put('mainEmail', 'E-mail : ');
                        }
                        
                    }
                    //포탈유저인데 대리점대표인 경우
                    else{
                        result.put('roleType', 'Manager');
                    }
                    // result.put('quotesalesoffice', '영업지사 - ' + DN_QuotationPDFController.getPicklistValues('User', 'SalesOffice__c', quoteInfo[0].Opportunity.Opportunity_Owner__r.SalesOffice__c) + ' ' + quoteInfo[0].Opportunity.Opportunity_Owner__r.LastName + ' ' + title);
                    //포탈유저 대리점대표 & 직원 공통
                    if(quoteInfo[0].Opportunity.Owner.Account.Name != null && quoteInfo[0].Opportunity.Owner.Account.Name != ''){
                        result.put('distiName', quoteInfo[0].Opportunity.Owner.Account.Name);
                    }else{
                        result.put('distiName', '');
                    }
                    if(quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.fm_address__c != null){
                        result.put('quoteaddress', quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.fm_address__c);
                    }else{
                        result.put('quoteaddress', '');
                    }
                    if(quoteInfo[0].Opportunity.Owner.Account.Representative__c != null && quoteInfo[0].Opportunity.Owner.Account.Representative__c != ''){
                        result.put('distiRep', '대표자 : ' + quoteInfo[0].Opportunity.Owner.Account.Representative__c);
                    }else{
                        result.put('distiRep', '대표자 : ');
                    }
                    if(quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.Phone != null && quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.Phone != ''){
                        result.put('mainphoneRep', '대표번호 : ' + quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.Phone);
                    }else{
                        result.put('mainphoneRep', '대표번호 : ');
                    }
                    if(quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.Mobile__c != null && quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.Mobile__c != ''){
                        result.put('mobilephoneRep', '휴대폰 : ' + quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.Mobile__c);
                    }else{
                        result.put('mobilephoneRep', '휴대폰 : ');
                    }
                    if(quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.Email__c != null && quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.Email__c != ''){
                        result.put('mailRep', 'E-mail : ' + quoteInfo[0].Opportunity.Opportunity_Owner__r.Account.Email__c);
                    }else{
                        result.put('mailRep', 'E-mail : ');
                    }
                }else{
                    //직영일경우
                    result.put('roleType', 'Direct');
                    result.put('quotesalesoffice', '영업지사 - ' + DN_QuotationPDFController.getPicklistValues('User', 'SalesOffice__c', quoteInfo[0].Opportunity.Opportunity_Owner__r.SalesOffice__c) + ' ' + quoteInfo[0].Opportunity.Opportunity_Owner__r.LastName + ' ' + title);
                    if(quoteInfo[0].Opportunity.Opportunity_Owner__r.Address_PDF__c != null){
                        result.put('quoteaddress', quoteInfo[0].Opportunity.Opportunity_Owner__r.Address_PDF__c);
                    }else{
                        result.put('quoteaddress', '');
                    }
                    if(quoteInfo[0].Opportunity.Opportunity_Owner__r.Phone != null){
                        result.put('mainphone', '대표번호 : ' + quoteInfo[0].Opportunity.Opportunity_Owner__r.Phone);
                    }else{
                        result.put('mainphone', '대표번호 : ');
                    }
                    if(owner.MobilePhone != null) {
                        result.put('mobilephone', '휴대폰 : ' + owner.MobilePhone);
                    }else{
                        result.put('mobilephone', '휴대폰 : ');
                    }
                    if(owner.Email != null) {
                        result.put('mainEmail', 'E-mail : ' + owner.Email);
                    }else{
                        result.put('mainEmail', 'E-mail : ');
                    }
                }

                result.put('keyField', keyField);
                result.put('QuoteNumber', quoteInfo[0].QuoteNumber);
                result.put('AccountName', quoteInfo[0].Account.Name);
                result.put('ExpirationDate', quoteInfo[0].ExpectedDelivDate__c);
                result.put('Incoterms', quoteInfo[0].IncotermsKR__c);
                result.put('TermsOfPayment', quoteInfo[0].PaymentConditionKR__c);
                result.put('CreatedDate', quoteInfo[0].CreatedDate);
                
                ///////////////////중복체크 logic 시작/////////////////////////////
                List<AggregateResult> dupquoteLineInfo = 
                [
                    SELECT 
                        MAX(Id) Id,
                        Product2.ProductCode ProductCode, 
                        ExpectedDelivDate__c,
                        SUM(Quantity) Quantity, 
                        MAX(UnitPrice) ERPPrice,
                        SUM(TotalPrice) TotalPrice,
                        MAX(Product2.Model__r.Name) ModelName,
                        MAX(Product2.Model__c) Model__c,
                        // ModelDescription__c
                        MAX(Product2.ModelDescription__c) ModelDescription,
                        MAX(Product2.Sub_Description__c) Description
                    FROM QuoteLineItem 
                    WHERE QuoteId =: recordId
                    GROUP BY Product2.ProductCode , ExpectedDelivDate__c
                    ORDER BY Product2.ProductCode, ExpectedDelivDate__c];
            
                List<AggregateResult> charValList = 
                [
                    SELECT
                        // Id,
                        QuoteLineItem__r.Product2.ProductCode ProductCode,
                        QuoteLineItem__r.ExpectedDelivDate__c ExpectedDelivDate__c,
                        COUNT(Id) Quantity,
                        MAX(C_Value__c) C_Value__c,
                        MAX(V_Value__c) V_Value__c,
                        // QuoteLineItem__c,
                        MIN(subkey__c) subkey__c,
                        MAX(Price__c) Price__c
                    FROM 
                        CharacteristicValue__c
                    WHERE 
                        QuoteLineItem__r.QuoteId =: recordId 
                        and (defChange__c = true 
                        or (
                        Price__c != 0
                        and Price__c != null))
                        and ShowData__c = true
                    GROUP BY 
                        QuoteLineItem__r.Product2.ProductCode, QuoteLineItem__r.ExpectedDelivDate__c, C_Code__c , V_Code__c
                    ORDER BY 
                        MIN(subkey__c) asc, MAX(Price__c) Desc,QuoteLineItem__r.Product2.ProductCode, QuoteLineItem__r.ExpectedDelivDate__c, C_Code__c, V_Code__c
                    
                ];

                List<AggregateResult> accessoryList = 
                [
                    SELECT
                        QuoteLineItem__r.Product2.ProductCode ProductCode,
                        QuoteLineItem__r.ExpectedDelivDate__c ExpectedDelivDate__c,
                        MAX(Description__c) Description__c,
                        SUM(Quantity__c) Quantity,
                        MAX(Name) Name,
                        MAX(Price__c) Price__c
                    FROM
                        Accessory__c
                    WHERE 
                        QuoteLineItem__r.QuoteId =: recordId
                        and Delete__c != 'D'
                    GROUP BY 
                        QuoteLineItem__r.Product2.ProductCode, 
                        QuoteLineItem__r.ExpectedDelivDate__c, 
                        Key__c
                    ORDER BY 
                        QuoteLineItem__r.Product2.ProductCode, 
                        QuoteLineItem__r.ExpectedDelivDate__c, 
                        Key__c
                ];
                List<AggregateResult> sqList = 
                [
                    SELECT
                        QuoteLineItem__r.Product2.ProductCode ProductCode, 
                        QuoteLineItem__r.ExpectedDelivDate__c ExpectedDelivDate__c, 
                        COUNT(Id) Quantity,   
                        // MAX(SQ__r.Name) Name, 
                        SQ__r.Name Name, 
                        MAX(SalesPrice__c) Price__c
                    FROM
                        SQ_QuoteLineitem_Junction__c
                    WHERE
                        QuoteLineItem__r.QuoteId =: recordId
                        and UPDATEFLAG__c != 'D'
                    GROUP BY
                        QuoteLineItem__r.Product2.ProductCode, 
                        QuoteLineItem__r.ExpectedDelivDate__c,
                        SQ__r.Name
                ];
                ///////////////////중복체크 logic 끝/////////////////////////////

                // Create a list to hold quote line item details
                List<Map<String, Object>> quoteLineItemList = new List<Map<String, Object>>();
                
                // Loop through quoteLineInfo and add each item as a map to the list
                for (AggregateResult item : dupquoteLineInfo) {
                    Map<String, Object> lineItemMap = new Map<String, Object>();
                    lineItemMap.put('QuoteLineId', item.get('Id'));  
                    lineItemMap.put('ModelName', item.get('ModelName'));
                    lineItemMap.put('ProductCode', '(' + item.get('ProductCode') + ')');

                    lineItemMap.put('ModelDescription', item.get('ModelDescription'));
                    lineItemMap.put('Description', item.get('Description'));

                    lineItemMap.put('RDD', item.get('ExpectedDelivDate__c'));
                    lineItemMap.put('Quantity', Integer.valueOf(item.get('Quantity')));
                    lineItemMap.put('TotalPrice', Decimal.valueOf(String.valueOf(item.get('ERPPrice'))).format());
                    lineItemMap.put('Desc', '-');
                    lineItemMap.put('DescLength', 15);
                    
                    List<Map<String, Object>> characteristicValuesList = new List<Map<String, Object>>();
                    
                    Map<String, Object> cvinitItemMap = new Map<String, Object>();
                        cvinitItemMap.put('Option', 'Option');
                        cvinitItemMap.put('Character', '');
                        cvinitItemMap.put('Value', '');
                        cvinitItemMap.put('cvQty', '');
                        cvinitItemMap.put('Price', '');
                        cvinitItemMap.put('Descrip', '');

                    characteristicValuesList.add(cvinitItemMap);
                    if(charValList.size() > 0){
                        for(AggregateResult cvItem : charValList) {
                            Map<String, Object> cvItemMap = new Map<String, Object>();
                            if((String)item.get('ProductCode') + item.get('ExpectedDelivDate__c') == (String)cvItem.get('ProductCode') + cvItem.get('ExpectedDelivDate__c')) {
                                cvItemMap.put('Option', '');
                                cvItemMap.put('Character', cvItem.get('C_Value__c') +  ' - ' + cvItem.get('V_Value__c'));
                                cvItemMap.put('Descrip', '');

                                cvItemMap.put('Value', cvItem.get('V_Value__c'));
                                cvItemMap.put('cvQty', Integer.valueOf(cvItem.get('Quantity')));
                                if(cvItem.get('Price__c') != null){
                                    cvItemMap.put('Price', Integer.valueOf(cvItem.get('Price__c')));
                                }else{
                                    cvItemMap.put('Price', 0);
                                }
                                characteristicValuesList.add(cvItemMap);
                            }
                        }
                    }
                    
                    Map<String, Object> sqinitItemMap = new Map<String, Object>();
                        sqinitItemMap.put('Option', 'SQ');
                        sqinitItemMap.put('Character', '');
                        sqinitItemMap.put('Value', '');
                        sqinitItemMap.put('cvQty', '');
                        sqinitItemMap.put('Price', '');
                        sqinitItemMap.put('Descrip', '');

                        characteristicValuesList.add(sqinitItemMap);
                    if(sqList.size() > 0) {
                        for(AggregateResult sqItem : sqList) {
                            Map<String, Object> sqItemMap = new Map<String, Object>();
                            if((String)item.get('ProductCode') + item.get('ExpectedDelivDate__c') == (String)sqItem.get('ProductCode') + sqItem.get('ExpectedDelivDate__c')) {
                                sqItemMap.put('Option', '');
                                sqItemMap.put('Character', sqItem.get('Name'));
                                sqItemMap.put('Descrip', '');

                                sqItemMap.put('Value', '');
                                sqItemMap.put('cvQty', Integer.valueOf(sqItem.get('Quantity')));
                                if(sqItem.get('Price__c') != null){
                                    sqItemMap.put('Price', Integer.valueOf(sqItem.get('Price__c')));
                                }else{
                                    sqItemMap.put('Price', 0);
                                }
                                characteristicValuesList.add(sqItemMap);
                            }
                        }
                    }

                    Map<String, Object> acsinitItemMap = new Map<String, Object>();
                        acsinitItemMap.put('Option', 'Accessory');
                        acsinitItemMap.put('Character', '');
                        acsinitItemMap.put('Value', '');
                        acsinitItemMap.put('cvQty', '');
                        acsinitItemMap.put('Price', '');
                        acsinitItemMap.put('Descrip', '');

                        characteristicValuesList.add(acsinitItemMap);
                    if(accessoryList.size() > 0) {
                        for(AggregateResult acsItem : accessoryList) {
                            Map<String, Object> acsItemMap = new Map<String, Object>();
                            if((String)item.get('ProductCode') + item.get('ExpectedDelivDate__c') == (String)acsItem.get('ProductCode') + acsItem.get('ExpectedDelivDate__c')) {
                                acsItemMap.put('Option', '');
                                System.debug('확인임 : ' + acsItem.get('Description__c'));
                                if(acsItem.get('Description__c') != null){
                                    acsItemMap.put('Character', acsItem.get('Name') + '     ' + acsItem.get('Description__c'));
                                }else{
                                    acsItemMap.put('Character', acsItem.get('Name'));
                                }
                                acsItemMap.put('Value', '');
                                acsItemMap.put('cvQty', Integer.valueOf(acsItem.get('Quantity')));
                                if(acsItem.get('Price__c') != null){
                                    acsItemMap.put('Price', Integer.valueOf(acsItem.get('Price__c')));
                                }else{
                                    acsItemMap.put('Price', 0);
                                }
                                characteristicValuesList.add(acsItemMap);
                            }
                        }
                    }
                    
                    lineItemMap.put('CharacteristicValues', characteristicValuesList);
                    quoteLineItemList.add(lineItemMap);
                    System.debug('quoteLineItemList' + lineItemMap);
                }
    
                // Add the list of quote line items to the result map
                result.put('QuoteLineItems', quoteLineItemList);
                System.debug(result);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            
        }else if(recordType.RecordType.DeveloperName == 'Global'){
            try {
                List<Quote> quoteInfo = [SELECT 
                                            Id,
                                            QuoteNumber,
                                            Owner.Name,
                                            CreatedDate,
                                            Account.Name,
                                            NewExist__c,
                                            Account.ShippingAddress,
                                            Account.Representative__c,
                                            Account.MainCategory__c,
                                            Port__c,
                                            ExistingMachine__c,
                                            Incoterms__c,
                                            TermsOfPayment__c,
                                            ProductType__c,
                                            Competition__c,
                                            PurposeOfUse__c,
                                            UsageOfProduct__c,
                                            PreInspection__c,
                                            Account.ShippingStreet, 
                                            Account.ShippingCity,
                                            Account.ShippingState,
                                            Opportunity.CurrencyIsoCode
                                        FROM Quote 
                                        WHERE Id =:recordId];

                //////////////중복체크 logic 시작//////////////////////////
                List<QuoteLineItem> dupquoteLineInfo = [SELECT
                                                        Id,
                                                        Product2.ProductCode,
                                                        RequestedDelivDate__c,
                                                        Warranty__c, 
                                                        Warranty_Price__c,
                                                        Adjustment_Price__c,
                                                        AdjustmentPercent__c,
                                                        CurrencyIsoCode,
                                                        DC__c,
                                                        DC_Price__c,
                                                        Final_Quotation_Price__c,
                                                        CV_Total__c,
                                                        SQ_Total__c,
                                                        Accessory_Total__c,
                                                        LeadTime_In_Months__c
                                                        FROM
                                                        QuoteLineItem
                                                        WHERE QuoteId =: quoteInfo[0].Id
                                                        ORDER BY Product2.ProductCode
                                                        ];
                Map<String, String> dupquoteLineInfoMap = new Map<String, String>();

                //Quote Line Item Id 를 key, ProductCode와 RDD를 문자열로 합침
                //key를 만드는 문자열에 LeadTime_In_Months__c 추가 250622 By 우상철
                if(dupquoteLineInfo.size() > 0) {
                    for(QuoteLineItem item : dupquoteLineInfo){
                        String leadTime = '0';
                        if(item.LeadTime_In_Months__c != null){
                            leadTime = String.valueOf(item.LeadTime_In_Months__c);
                        }
                        dupquoteLineInfoMap.put(item.Id, 
                                                    String.valueOf(item.Product2.ProductCode) + 
                                                    String.valueOf(item.RequestedDelivDate__c) +
                                                    item.Warranty__c + 
                                                    String.valueOf(item.Adjustment_Price__c) + 
                                                    String.valueOf(item.DC_Price__c) + 
                                                    leadTime
                                                    );
                    }
                }

                //Quote Line Itme Id 적재
                Set<Id> dupquoteLineId = new Set<Id>();
                for(Integer i = 0; i < dupquoteLineInfo.size(); i++) {
                    dupquoteLineId.add(dupquoteLineInfo[i].Id);
                }

                //Quote Line Item으로 CV데이터 가져오기
                List<CharacteristicValue__c> dupcharValList = new List<CharacteristicValue__c>();
                if(dupquoteLineId.size() > 0){
                    dupcharValList = 
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
                            QuoteLineItem__c IN :dupquoteLineId 
                            and (defChange__c = true 
                            or (
                            Price__c != 0
                            and Price__c != null))
                            and ShowData__c = true
                        ORDER BY QuoteLineItem__c, C_Code__c, V_Code__c
                    ];
                }

                //CV데이터를 담을 때 Quote Line Item의 Id가 key로 등록 되어있을 경우 기존 값에 C code와 V Code 문자열로 합쳐서 넣기 없으면 새로 input
                if(dupcharValList.size() > 0){
                    for(CharacteristicValue__c item : dupcharValList){
                        String key = item.QuoteLineItem__c;
                        if(dupquoteLineInfoMap.containsKey(key)){
                            dupquoteLineInfoMap.put(key, dupquoteLineInfoMap.get(key) + item.C_Code__c + item.V_Code__c);
                        }else{
                            dupquoteLineInfoMap.put(key, item.C_Code__c + item.V_Code__c);
                        }
                    }
                }

                //Quote Line Item Id로 SQ Quote Line Item Junction objet에서 데이터 불러오기   
                List<SQ_QuoteLineitem_Junction__c> dupsqlinejuncList = new List<SQ_QuoteLineitem_Junction__c>();
                if(dupquoteLineId.size() > 0){
                    dupsqlinejuncList = 
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
                            QuoteLineItem__c IN :dupquoteLineId
                            and UPDATEFLAG__c != 'D'
                        ORDER BY
                            QuoteLineItem__c, SQ__r.Name
                    ];
                } 

                //SQ 데이터 담을 때 Quote Line Item의 Id가 key로 등록 되어있을 경우 기존 값에 SQ__r.Name, SQ__r.Price__c 문자열로 합쳐서 넣기 없으면 새로 input
                if(dupsqlinejuncList.size() > 0){
                    for(SQ_QuoteLineitem_Junction__c item : dupsqlinejuncList){
                        String key = item.QuoteLineItem__c;
                        if(dupquoteLineInfoMap.containsKey(key)){
                            dupquoteLineInfoMap.put(key, dupquoteLineInfoMap.get(key) + item.SQ__r.Name + item.SalesPrice__c);
                        }else{
                            dupquoteLineInfoMap.put(key, item.SQ__r.Name + item.SalesPrice__c);
                        }
                    }
                }

                //Quote Line Item Id로 Accessory objet에서 데이터 불러오기   
                List<Accessory__c> dupaccessoryList = new List<Accessory__c>();
                if(dupquoteLineId.size() > 0){
                    dupaccessoryList = 
                    [
                        SELECT
                            Id,
                            Name,
                            QuoteLineItem__c,
                            Key__c,
                            Description__c,
                            Quantity__c,
                            Price__c
                        FROM
                            Accessory__c
                        WHERE
                            QuoteLineItem__c IN :dupquoteLineId
                            and Delete__c != 'D'
                        ORDER BY
                            QuoteLineItem__c, Key__c
                    ];
                }

                //Accessory 데이터 담을 때 Quote Line Item의 Id가 Key로 등록 되어 있을 경우 기존 값에 Key__c 문자열로 합쳐서 넣기 없으면 새로 input
                if(dupaccessoryList.size() > 0){
                    for(Accessory__c item : dupaccessoryList){
                        String key = item.QuoteLineItem__c;
                        if(dupquoteLineInfoMap.containsKey(key)){
                            dupquoteLineInfoMap.put(key, dupquoteLineInfoMap.get(key) + item.Key__c);
                        }else{
                            dupquoteLineInfoMap.put(key, item.Key__c);
                        }
                    }
                }

                //Map에서 value가 같은 Key Count
                Map<String, Integer> dupresultMap = new Map<String, Integer>();
                MAP<String, String> dupCheck = new Map<String, String>();
                MAP<String, String> dupQuoteLineIdInfo = new Map<String, String>();
                List<String> quoteLineitemId =  new List<String>();

                // if(dupquoteLineInfoMap.size() > 0){
                //     for(String key : dupquoteLineInfoMap.keySet()){
                //         String value = dupquoteLineInfoMap.get(key);
                //         String dupKey = dupCheck.get(value);
                //         if(dupCheck.size() > 0){
                //             if(dupCheck.containsKey(value)){
                //                 Integer cnt = dupresultMap.get(dupKey) + 1;
                //                 dupresultMap.put(dupCheck.get(value), cnt);
                //                 dupQuoteLineIdInfo.put(dupCheck.get(value), dupCheck.get(value) + ','+ key);

                //             }else{
                //                 dupCheck.put(value, key);
                //                 dupresultMap.put(dupCheck.get(value), 1);
                //                 quoteLineitemId.add(dupCheck.get(value));
                //                 dupQuoteLineIdInfo.put(key, key);

                //             }
                //         }else{
                //             dupCheck.put(value, key);
                //             dupresultMap.put(dupCheck.get(value), 1);
                //             quoteLineitemId.add(dupCheck.get(value));
                //             dupQuoteLineIdInfo.put(key, key);

                //         }
                //     }
                // }
                if (!dupquoteLineInfoMap.isEmpty()) {
                    for (String key : dupquoteLineInfoMap.keySet()) {
                        String value = dupquoteLineInfoMap.get(key);

                        if (dupCheck.containsKey(value)) {
                            String dupKey = dupCheck.get(value);
                            Integer cnt = dupresultMap.get(dupKey) != null ? dupresultMap.get(dupKey) + 1 : 1;
                            dupresultMap.put(dupKey, cnt);

                            String existingIds = dupQuoteLineIdInfo.get(dupKey);
                            dupQuoteLineIdInfo.put(dupKey, existingIds + ',' + key);

                        } else {
                            dupCheck.put(value, key);
                            dupresultMap.put(key, 1);
                            quoteLineitemId.add(key);
                            dupQuoteLineIdInfo.put(key, key);
                        }

                        System.debug('dupQuoteLineIdInfo!!! : ' + dupQuoteLineIdInfo);
                    }
                }

                System.debug('dupquoteLineInfoMap : ' + dupquoteLineInfoMap);
                System.debug('dupquoteLineInfoMapsize : ' + dupquoteLineInfoMap.size());
                for(Integer i = 0; i < dupquoteLineInfoMap.size(); i++) {
                    System.debug('keyvalueQuoteLine : ' + dupquoteLineInfoMap.values().get(i));
                }

                System.debug('dupresultMapsize : ' + dupresultMap.size());

                for(Integer i = 0; i < quoteLineitemId.size(); i++) {
                    System.debug('keyvaluedupresultMap : ' + quoteLineitemId[i]);
                }
                //////////////중복체크 logic 끝//////////////////////////

                String keyField = DN_QuotationPDFController.getKeyfield(recordId);

                result.put('keyField', keyField);
                
                List<QuoteLineItem> quoteLineInfo = [SELECT 
                                                        Id,
                                                        Product2.Name, 
                                                        Quantity, 
                                                        ListPrice,
                                                        UnitPrice,
                                                        RequestedDelivDate__c,
                                                        Product2.Model__r.Name,
                                                        Warranty__c, 
                                                        Warranty_Price__c,
                                                        Adjustment_Price__c,
                                                        AdjustmentPercent__c,
                                                        Dealer_Price__c,
                                                        CurrencyIsoCode,
                                                        DC__c,
                                                        DC_Price__c,
                                                        Final_Quotation_Price__c,
                                                        CV_Total__c,
                                                        SQ_Total__c,
                                                        Accessory_Total__c,
                                                        LeadTime_In_Months__c
                                                    FROM QuoteLineItem 
                                                    WHERE Id IN: quoteLineitemId];

                String TermsOfPayment;
                for (Schema.PicklistEntry entry : Quote.TermsOfPayment__c.getDescribe().getPicklistValues()) {
                    if (entry.getValue() == quoteInfo[0].TermsOfPayment__c) {
                        TermsOfPayment = entry.getLabel();
                        break;
                    }
                }

                
                result.put('QuoteNumber', quoteInfo[0].QuoteNumber);
                result.put('Dealer', quoteInfo[0].Owner.Name);
                result.put('AccountName', quoteInfo[0].Account.Name);
                result.put('CreatedDate', quoteInfo[0].CreatedDate);
                result.put('Incoterms', quoteInfo[0].Incoterms__c);
                result.put('ProductType', quoteInfo[0].ProductType__c);
                result.put('TermsOfPayment', TermsOfPayment);
                result.put('NewExist', quoteInfo[0].NewExist__c);
                String ShippingStreet = '';
                String ShippingCity = '';
                String ShippingState = '';
                if(quoteInfo[0].Account.ShippingStreet != null){
                    ShippingStreet = quoteInfo[0].Account.ShippingStreet;
                }
                if(quoteInfo[0].Account.ShippingCity != null){
                    ShippingCity = quoteInfo[0].Account.ShippingCity;
                }
                if(quoteInfo[0].Account.ShippingState != null){
                    ShippingState = quoteInfo[0].Account.ShippingState;
                }
                result.put('Address', ShippingStreet + ' ' + ShippingCity + ' ' + ShippingState);
                result.put('Representative', quoteInfo[0].Account.Representative__c);
                result.put('Industry', quoteInfo[0].Account.MainCategory__c);
                result.put('PurposeofUse', quoteInfo[0].PurposeOfUse__c);
                result.put('UsageofProduct', quoteInfo[0].UsageOfProduct__c);
                result.put('PreInspection', quoteInfo[0].PreInspection__c);
                result.put('Competition', quoteInfo[0].Competition__c);
                result.put('ExMachine', quoteInfo[0].ExistingMachine__c);
                result.put('Port', quoteInfo[0].Port__c);
                result.put('Currency', quoteInfo[0].Opportunity.CurrencyIsoCode);

                Set<Id> quoteLineId = new Set<Id>();
                for(Integer i = 0; i < quoteLineInfo.size(); i++) {
                    quoteLineId.add(quoteLineInfo[i].Id);
                }
                System.debug(quoteLineId);
                
                List<CharacteristicValue__c> charValList = 
                    [
                        SELECT
                            Id,
                            C_Value__c,
                            V_Value__c,
                            QuoteLineItem__c,
                            subkey__c,
                            Price__c
                        FROM CharacteristicValue__c
                        WHERE 
                            QuoteLineItem__c IN :quoteLineitemId 
                            and (defChange__c = true 
                            or (
                            Price__c != 0
                            and Price__c != null))
                            and ShowData__c = true
                        ORDER BY
                            subkey__c asc, Price__c desc, C_Value__c

                    ];
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
                            QuoteLineItem__c IN :quoteLineitemId
                            and SQ__c != null
                            and UPDATEFLAG__c != 'D'
                        ORDER BY
                            QuoteLineItem__c, SQ__r.Name
                    ];
                List<Accessory__c> accessoryList = 
                    [
                        SELECT
                                Id,
                                Name,
                                QuoteLineItem__c,
                                Key__c,
                                Description__c,
                                Price__c
                            FROM
                                Accessory__c
                            WHERE
                                QuoteLineItem__c IN :quoteLineitemId
                                and Delete__c != 'D'
                            ORDER BY
                                QuoteLineItem__c, Key__c
                    ];

                List<Accessory__c> allaccessoryList = 
                [
                    SELECT
                            Id,
                            Name,
                            QuoteLineItem__c,
                            Key__c,
                            Description__c,
                            Price__c,
                            Quantity__c
                        FROM
                            Accessory__c
                        WHERE
                            QuoteLineItem__r.QuoteId =:quoteInfo[0].Id
                            and Delete__c != 'D'
                        ORDER BY
                            QuoteLineItem__c, Key__c
                ];
                Map<String, Decimal> accSum = new Map<String, Decimal>();
                if(allaccessoryList.size() > 0){
                    for(Accessory__c acc : allaccessoryList){
                        for(String key : dupQuoteLineIdInfo.keySet()){
                            String valueStr = dupQuoteLineIdInfo.get(key);
                            if(valueStr.contains(acc.QuoteLineItem__c)){
                                if(accSum.size() > 0){
                                    if(accSum.containsKey(key+acc.Name)){
                                        accSum.put(key+acc.Name, accSum.get(key+acc.Name) + acc.Quantity__c);
                                    }else{
                                        accSum.put(key+acc.Name, acc.Quantity__c);
                                    }
                                }else{
                                    accSum.put(key+acc.Name, acc.Quantity__c);
                                }
                            }
                        }
                    }
                }

                System.debug('charValList' + charValList);
                for(Integer i = 0; i < sqList.size(); i++){
                    System.debug('sqList' + sqList[i].SQ__r.Name);
                }
                
                // Create a list to hold quote line item details
                List<Map<String, Object>> quoteLineItemList = new List<Map<String, Object>>();
                
                // Loop through quoteLineInfo and add each item as a map to the list
                for (QuoteLineItem item : quoteLineInfo) {
                    Map<String, Object> lineItemMap = new Map<String, Object>();
                    lineItemMap.put('QuoteLineId', item.Id);                
                    //ProductCode대신 Model Name으로 변경
                    lineItemMap.put('ProductName', item.Product2.Model__r.Name);
                    lineItemMap.put('Quantity', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id))).format());
                    if(item.UnitPrice != 0){
                        lineItemMap.put('ListPrice', Decimal.valueOf(String.valueOf(item.UnitPrice)).format());
                        lineItemMap.put('Amount', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * item.UnitPrice)).format());
                    }else{
                        lineItemMap.put('ListPrice', 0);
                        lineItemMap.put('Amount', 0);
                    }
                    lineItemMap.put('RDD', item.RequestedDelivDate__c);
                    if(item.LeadTime_In_Months__c != null && item.LeadTime_In_Months__c != 0){
                        lineItemMap.put('leadTime', String.valueOf(item.LeadTime_In_Months__c));
                    }else{
                        lineItemMap.put('leadTime','**');
                    }
                    if(item.Adjustment_Price__c != null && item.Adjustment_Price__c != 0){
                        lineItemMap.put('Adjustment',dupresultMap.get(item.Id) * item.Adjustment_Price__c.setScale(2));
                    }else{
                        lineItemMap.put('Adjustment', 0);
                    }
                    if(item.Adjustment_Price__c != null && item.Adjustment_Price__c != 0){
                        lineItemMap.put('AdjustPercent', item.AdjustmentPercent__c.setScale(2));
                    }else{
                        lineItemMap.put('AdjustPercent', 0);
                    }
                    if(item.DC_Price__c != null && item.DC_Price__c != 0){
                        lineItemMap.put('DCPrice', dupresultMap.get(item.Id) * item.DC_Price__c.setScale(2));
                        lineItemMap.put('DCPercent', item.DC__c.setScale(2));
                    }else{
                        lineItemMap.put('DCPrice', 0);
                        lineItemMap.put('DCPercent', 0);
                    }
                    lineItemMap.put('Warranty', DN_QuotationPDFController.getPicklistValues('QuoteLineItem', 'Warranty__c', item.Warranty__c));
                    if(item.Warranty_Price__c != null){
                        lineItemMap.put('WarrantyPrice', dupresultMap.get(item.Id) * item.Warranty_Price__c.setScale(2));
                    }else{
                        lineItemMap.put('WarrantyPrice', 0);
                    }
                    List<Map<String, Object>> characteristicValuesList = new List<Map<String, Object>>();
                    for(CharacteristicValue__c cvItem : charValList) {
                        Map<String, Object> cvItemMap = new Map<String, Object>();
                        System.debug(cvItem.QuoteLineItem__c);
                        if(item.Id == cvItem.QuoteLineItem__c) {
                            cvItemMap.put('cvId', cvItem.Id);
                            cvItemMap.put('Character', cvItem.C_Value__c + ' - ' + cvItem.V_Value__c);
                            cvItemMap.put('Value', cvItem.V_Value__c);
                            cvItemMap.put('cvQty', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id))).format());
                            if(cvItem.Price__c != null){
                                cvItemMap.put('Price', Decimal.valueOf(String.valueOf(cvItem.Price__c)).format());
                                cvItemMap.put('Amount', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * cvItem.Price__c)).format());
                            }else{
                                cvItemMap.put('Price', '');
                                cvItemMap.put('Amount', 0);
                            }
                            characteristicValuesList.add(cvItemMap);
                        }
                    }
                    Map<String, Object> sqLineMap = new Map<String,Object>();
                    sqLineMap.put('cvId', '');
                    sqLineMap.put('Character', 'SQ');
                    sqLineMap.put('Value', '');
                    sqLineMap.put('cvQty', '');
                    sqLineMap.put('Price', '');
                    sqLineMap.put('Amount', '');
                    characteristicValuesList.add(sqLineMap);

                    for(SQ_QuoteLineitem_Junction__c sqItem : sqList) {
                        Map<String, Object> sqItemMap = new Map<String, Object>();
                        if(item.Id == sqItem.QuoteLineItem__c) {
                            sqItemMap.put('cvId', sqItem.Id);
                            sqItemMap.put('Character', sqItem.SQ__r.Name);
                            sqItemMap.put('Value', '');
                            sqItemMap.put('cvQty', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id))).format());
                            if(sqItem.SalesPrice__c != null){
                                sqItemMap.put('Price', Decimal.valueOf(String.valueOf(sqItem.SalesPrice__c)).format());
                                sqItemMap.put('Amount', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * sqItem.SalesPrice__c)).format());
                            }else{
                                sqItemMap.put('Price', 0);
                                sqItemMap.put('Amount', 0);
                            }
                            characteristicValuesList.add(sqItemMap);
                            System.debug('sqItemMap' + sqItemMap);
                        }
                    }

                    Map<String, Object> acsLineMap = new Map<String,Object>();
                    acsLineMap.put('cvId', '');
                    acsLineMap.put('Character', 'Accessory');
                    acsLineMap.put('Value', '');
                    acsLineMap.put('cvQty', '');
                    acsLineMap.put('Price', '');
                    acsLineMap.put('Amount', '');
                    characteristicValuesList.add(acsLineMap);

                    for(Accessory__c acsItem : accessoryList){
                        Map<String, Object> acsItemMap = new Map<String, Object>();
                        if(item.Id == acsItem.QuoteLineItem__c) {
                            acsItemMap.put('cvId', acsItem.Id);
                            if(acsItem.Description__c == null){
                                acsItemMap.put('Character', acsItem.Name);
                            }else{
                                acsItemMap.put('Character', acsItem.Name + '     ' + acsItem.Description__c);
                            }
                            acsItemMap.put('Value', '');
                            // acsItemMap.put('cvQty', dupresultMap.get(item.Id));
                            acsItemMap.put('cvQty', accSum.get(acsItem.QuoteLineItem__c+acsItem.Name));

                            if(acsItem.get('Price__c') != null){
                                acsItemMap.put('Price', Decimal.valueOf(String.valueOf(acsItem.Price__c)).format());
                                // acsItemMap.put('Amount', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * acsItem.Price__c)).format());
                                acsItemMap.put('Amount', Decimal.valueOf(String.valueOf(accSum.get(acsItem.QuoteLineItem__c+acsItem.Name) * acsItem.Price__c)).format());
                            }else{
                                acsItemMap.put('Price', 0);
                                acsItemMap.put('Amount', 0);
                            }
                            characteristicValuesList.add(acsItemMap);
                            System.debug('acsItemMap' + acsItemMap);
                        }
                    }

                    lineItemMap.put('CharacteristicValues', characteristicValuesList);
                    quoteLineItemList.add(lineItemMap);
                    System.debug('quoteLineItemList' + lineItemMap);

                }
    
                // Add the list of quote line items to the result map
                result.put('QuoteLineItems', quoteLineItemList);
                System.debug(result);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }else if(recordType.RecordType.DeveloperName == 'DNSA_Factory'){
            QuoteLineItem quoteInfo = [SELECT Id, Product2.Name FROM QuoteLineItem WHERE QuoteId =: recordId];
            result.put('ProductName', quoteInfo.Product2.Name);
            List<CharacteristicValue__c> cvInfo = [
                SELECT
                    C_Code__c,
                    C_Value__c,
                    V_Code__c,
                    V_Value__c,
                    defChange__c
                FROM
                    CharacteristicValue__c
                WHERE
                    QuoteLineItem__c =: quoteInfo.Id
                AND ShowData__c = true
            ];
            result.put('CVInfo', cvInfo);
            System.debug('cvInfo : ' + cvInfo);
        }
        return result;
    }

    //이미지 넣기 위한 method
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getStaticResourceBody_KR(String recordId) {
        List<QuoteLineItem> imageData = [SELECT Id, Product2.Model__c FROM QuoteLineItem WHERE Id =:recordId];
        String dnLogo = 'DN_Logo';
        String dnSeal = 'DN_Seal';
        String dnPrd  = 'DN_Product';
        String dnCommon = 'DN_Common';
        String dnLogoGlobal = 'DN_Logo_Global';
        String dnDealerLogo = 'DN_Dealer_LOGO';
        StaticResource dnSRPrdCv;
        ContentVersion dnCVPrdCv;
        // ContentVersion dnCVPrdCv;
        List<Model__c> modelCommon = [SELECT contentVersionId__c FROM Model__c WHERE Name = 'DN_Common' LIMIT 1];
        List<ContentVersion> modelCommonURL = [SELECT VersionData FROM ContentVersion WHERE Id =: modelCommon[0].contentVersionId__c];
        
        Map<String, String> mapCv = new Map<String, String>();
        try {
            if(imageData[0].Product2.Model__c != null){
                List<Model__c> modelName = [SELECT Id, Name, contentVersionId__c FROM Model__c WHERE Id =:imageData[0].Product2.Model__c LIMIT 1];
                System.debug('이거 나오는거야1? : ' + imageData[0].Product2.Model__c);
                System.debug('이거 나오는거야2? : ' + modelName);
            if(modelName[0].contentVersionId__c != null){
                dnCVPrdCv = [SELECT VersionData FROM ContentVersion WHERE Id = :modelName[0].contentVersionId__c LIMIT 1];
                //model은 있는데 model에 contentversion이 없을 때
                if(dnCVPrdCV.VersionData == null){
                    dnSRPrdCv = [SELECT Body FROM StaticResource WHERE Name =:dnCommon LIMIT 1];
                    mapCv.put('dnPrdCv', EncodingUtil.base64Encode(modelCommonURL[0].VersionData));
                }else{
                    mapCv.put('dnPrdCv', EncodingUtil.base64Encode(dnCVPrdCv.VersionData));
    
                }
            }else{
                mapCv.put('dnPrdCv', EncodingUtil.base64Encode(modelCommonURL[0].VersionData));
            }
            
            }
            else
            {
                mapCv.put('dnPrdCv', EncodingUtil.base64Encode(modelCommonURL[0].VersionData));
            }

            //ContentVersion에있는 데이터를 접근하려면 권한을 줘야 하는데 partner community 프로필에는 해당 권한을 줄 수 없음
            //그래서 static resource에 넣어서 진행
            StaticResource dnLogoCv = [SELECT Body FROM StaticResource WHERE Name = :dnLogo LIMIT 1];
            StaticResource dnSealCv = [SELECT Body FROM StaticResource WHERE Name = :dnSeal LIMIT 1];
            StaticResource dnLogoGlobalCv = [SELECT Body FROM StaticResource WHERE Name = :dnLogoGlobal LIMIT 1];
            StaticResource dnDealerLogoCv = [SELECT Body FROM StaticResource WHERE Name =: dnDealerLogo LIMIT 1];
            mapCv.put('dnLogoCv', EncodingUtil.base64Encode(dnLogoCv.Body));
            mapCv.put('dnSealCv', EncodingUtil.base64Encode(dnSealCv.Body));
            mapCv.put('dnLogoGlobalCv', EncodingUtil.base64Encode(dnLogoGlobalCv.Body));
            mapCv.put('dnDealerLogoCv', EncodingUtil.base64Encode(dnDealerLogoCv.Body));

            return mapCv;
        } catch (Exception e) {
            System.debug('Error getting ContentVersion data: ' + e.getMessage());
            mapCv.put('error', e.getMessage());
            return mapCv;
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
}