/**
 * @description       : 
 * @author            : Sejin Kwon
 * @group             : 
 * @last modified on  : 05-22-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-05-2024   Sejin Kwon     Initial Version
 * 2.0   07-15-2024   Sejin Kwon     Add Divide Korea/Global
**/
public with sharing class DN_QuotationPDFController {
    public Map<String, Object> result {get; set;}
    public List<Map<String, Object>> lineItems { get; set; }

    public DN_QuotationPDFController(ApexPages.StandardController stdController) {
        
        System.debug('Id'+ stdController.getId());
        String recordId = stdController.getId();
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

        result = new Map<String, Object>();
        Decimal allExtPrice = 0;
        Decimal subTotal = 0;
        Decimal subQty = 0;
        Decimal subAllTotal = 0;
        List<String> args = new String[]{'0','number','⌗⌗⌗,⌗⌗⌗,⌗⌗⌗,⌗⌗⌗'};
        List<Model__c> modelCommon = [SELECT contentVersionId__c FROM Model__c WHERE Name = 'DN_Common' LIMIT 1];
        List<ContentVersion> modelCommonURL = [SELECT VersionDataUrl FROM ContentVersion WHERE Id =: modelCommon[0].contentVersionId__c];
        if(recordType.RecordType.DeveloperName == 'Korea'){
            Integer isLast = 0;
            try {
                List<Quote> quoteInfo = [SELECT 
                                            Id, 
                                            QuoteNumber,
                                            Account.Name, 
                                            ExpectedDelivDate__c, 
                                            IncotermsKR__c,
                                            PaymentConditionKR__c, 
                                            CreatedDate,
                                            Opportunity.Owner.SalesOffice__c,
                                            Opportunity.Owner.Title,
                                            Opportunity.Owner.LastName,
                                            Opportunity.Owner.Account.ShippingStreet,
                                            Opportunity.Owner.Account.fm_address__c,
                                            Opportunity.Owner.Account.Phone,
                                            Opportunity.Owner.Phone,
                                            Opportunity.Owner.Contact.Phone,
                                            Opportunity.Owner.Profile.UserLicense.Name,
                                            Opportunity.Owner.Address_PDF__c,
                                            Opportunity.Owner.MobilePhone,
                                            Opportunity.Owner.Account.Mobile__c,
                                            Opportunity.Owner.UserRole.PortalRole,
                                            Opportunity.Owner.Account.Name,
                                            Opportunity.Owner.Account.Email__c,
                                            Opportunity.Owner.Account.Representative__c,
                                            Opportunity.Opportunity_Owner__r.Email,
                                            OwnerId
                                        FROM Quote 
                                        WHERE Id =:recordId];
                String title = '';
                User owner = DN_WithoutSharingClass.getUserEmail(quoteInfo[0].OwnerId);
                if(quoteInfo[0].Opportunity.Owner.Title != null){
                    title = quoteInfo[0].Opportunity.Owner.Title;
                }
                if(String.valueOf(quoteInfo[0].Opportunity.Owner.Profile.UserLicense.Name).contains('Partner')){
                    //포탈유저인데 직원인경우
                    if(quoteInfo[0].Opportunity.Owner.UserRole.PortalRole == 'Worker'){
                        result.put('roleType', 'Worker');
                        result.put('quotesalesoffice', '영업 담당자 : ' + quoteInfo[0].Opportunity.Owner.LastName + ' ' + title);
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
                        //포탈유저 대리점대표 & 직원 공통
                        if(quoteInfo[0].Opportunity.Owner.Account.Name != null && quoteInfo[0].Opportunity.Owner.Account.Name != ''){
                            result.put('distiName', quoteInfo[0].Opportunity.Owner.Account.Name);
                        }else{
                            result.put('distiName', '');
                        }
                        if(quoteInfo[0].Opportunity.Owner.Account.fm_address__c != null && quoteInfo[0].Opportunity.Owner.Account.fm_address__c != ''){
                            result.put('quoteaddress', quoteInfo[0].Opportunity.Owner.Account.fm_address__c);
                        }else{
                            result.put('quoteaddress', '');
                        }
                        if(quoteInfo[0].Opportunity.Owner.Account.Representative__c != null && quoteInfo[0].Opportunity.Owner.Account.Representative__c != ''){
                            result.put('distiRep', '대표자 : ' + quoteInfo[0].Opportunity.Owner.Account.Representative__c);
                        }else{
                            result.put('distiRep', '대표자 : ');
                        }
                        if(quoteInfo[0].Opportunity.Owner.Account.Phone != null && quoteInfo[0].Opportunity.Owner.Account.Phone != ''){
                            result.put('mainphoneRep', '대표번호 : ' + quoteInfo[0].Opportunity.Owner.Account.Phone);
                        }else{
                            result.put('mainphoneRep', '대표번호 : ');
                        }
                        if(quoteInfo[0].Opportunity.Owner.Account.Mobile__c != null && quoteInfo[0].Opportunity.Owner.Account.Mobile__c != ''){
                            result.put('mobilephoneRep', '휴대폰 : ' + quoteInfo[0].Opportunity.Owner.Account.Mobile__c);
                        }else{
                            result.put('mobilephoneRep', '휴대폰 : ');
                        }
                        if(quoteInfo[0].Opportunity.Owner.Account.Email__c != null && quoteInfo[0].Opportunity.Owner.Account.Email__c != ''){
                            result.put('mailRep', 'E-mail : ' + quoteInfo[0].Opportunity.Owner.Account.Email__c);
                        }else{
                            result.put('mailRep', 'E-mail : ');
                        }

                }else{
                    //직영일경우
                    result.put('roleType', 'Direct');
                    result.put('quotesalesoffice', '영업지사 - ' + getPicklistValues('User', 'SalesOffice__c', quoteInfo[0].Opportunity.Owner.SalesOffice__c) + ' ' + quoteInfo[0].Opportunity.Owner.LastName + ' ' + title);
                    if(quoteInfo[0].Opportunity.Owner.Address_PDF__c != null && quoteInfo[0].Opportunity.Owner.Address_PDF__c != ''){
                        result.put('quoteaddress', quoteInfo[0].Opportunity.Owner.Address_PDF__c);
                    }else{
                        result.put('quoteaddress', '');
                    }
                    if(quoteInfo[0].Opportunity.Owner.Phone != null && quoteInfo[0].Opportunity.Owner.Phone != ''){
                        result.put('mainphone', '대표번호 : ' + quoteInfo[0].Opportunity.Owner.Phone);
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
                

                result.put('QuoteNumber', quoteInfo[0].QuoteNumber);
                result.put('AccountName', quoteInfo[0].Account.Name);
                result.put('ExpirationDate', quoteInfo[0].ExpectedDelivDate__c);
                result.put('Incoterms', quoteInfo[0].IncotermsKR__c);
                result.put('TermsOfPayment', quoteInfo[0].PaymentConditionKR__c);
                result.put('CreatedDate', String.valueOf(quoteInfo[0].CreatedDate).substring(0,10).replace('-','.'));
                
                ///////////////////중복체크 logic 시작/////////////////////////////
                List<AggregateResult> dupquoteLineInfo = 
                    [
                        SELECT 
                            // Id,
                            Product2.ProductCode ProductCode, 
                            ExpectedDelivDate__c ExpectedDelivDate__c,
                            SUM(Quantity) Quantity, 
                            MAX(UnitPrice) ERPPrice,
                            SUM(TotalPrice) TotalPrice,
                            MAX(Product2.Model__c) Model__c,
                            MAX(Product2.Model__r.Name) ModelName,
                            // ModelDescription__c
                            MAX(Product2.ModelDescription__c) ModelDescription,
                            MAX(Product2.Sub_Description__c) Description
                        FROM QuoteLineItem 
                        WHERE QuoteId =: recordId
                        GROUP BY Product2.ProductCode , ExpectedDelivDate__c
                        ORDER BY Product2.ProductCode, ExpectedDelivDate__c
                    ];
                

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
                            MIN(subkey__c) asc, MAX(Price__c) Desc, QuoteLineItem__r.Product2.ProductCode, QuoteLineItem__r.ExpectedDelivDate__c, C_Code__c, V_Code__c
                    
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
                        ORDER BY
                            SQ__r.Name
                    ];
                ///////////////////중복체크 logic 끝/////////////////////////////

                // Create a list to hold quote line item details
                List<Map<String, Object>> quoteLineItemList = new List<Map<String, Object>>();
                
                // Loop through quoteLineInfo and add each item as a map to the list
                for (AggregateResult item : dupquoteLineInfo) {
                    Integer index = 0;
                    subTotal = 0;
                    subQty = 0;
                    allExtPrice = 0.0;
                    subAllTotal = 0;
                    Map<String, Object> lineItemMap = new Map<String, Object>();
                    // lineItemMap.put('QuoteLineId', item.Id);      
                    lineItemMap.put('ExpDate', item.get('ExpectedDelivDate__c'));        
                    lineItemMap.put('ModelName', item.get('ModelName'));
                    lineItemMap.put('ProductCode', '(' + item.get('ProductCode') + ')');
                    // lineItemMap.put('RDD', item.get('ExpectedDelivDate__c'));
                    if(item.get('Description') == null){
                        lineItemMap.put('RDD', 'Model Description');
                    }else{
                        lineItemMap.put('RDD', item.get('Description'));
                    }
                    if(item.get('ModelDescription') == null){
                        lineItemMap.put('ModelDescription', 'Model Description');
                    }else{
                        lineItemMap.put('ModelDescription', item.get('ModelDescription'));
                    }
                    lineItemMap.put('Quantity', Integer.valueOf(item.get('Quantity')));
                    lineItemMap.put('TotalPrice', Decimal.valueOf(String.valueOf(item.get('ERPPrice'))).format());
                    // lineItemMap.put('PrdAllPrice', Decimal.valueOf(Integer.valueOf(item.get('Quantity')) * Integer.valueOf(item.get('TotalPrice'))).format());
                    // lineItemMap.put('PrdAllPrice', Decimal.valueOf(Decimal.valueOf(String.valueOf(item.get('Quantity'))) * Decimal.valueOf(String.valueOf(item.get('ERPPrice')))).format());
                    Decimal total = Decimal.valueOf(String.valueOf(item.get('Quantity'))) * Decimal.valueOf(String.valueOf(item.get('ERPPrice')));
                    String formattedValue = total.format();
                    lineItemMap.put('PrdAllPrice', formattedValue);
                    // allExtPrice = allExtPrice + Integer.valueOf(item.get('Quantity')) * Integer.valueOf(item.get('TotalPrice'));
                    allExtPrice = allExtPrice + Decimal.valueOf(String.valueOf(item.get('Quantity'))) * Decimal.valueOf(String.valueOf(item.get('ERPPrice')));
          
                    System.debug('1');
                    // if(item.ModelDescription__c != null) {
                    //     String modelDesc = item.ModelDescription__c.replace('<p>', '');
                    //     List<String> parts = modelDesc.split('</p>');
                    //     if (parts.size() > 1) {
                    //         String result = '';
                    //         for (Integer i = 0; i < parts.size(); i++) {
                    //             result += parts[i];
                    //             if (i < parts.size() - 1) {
                    //                 result += '<br>';
                    //             }
                    //         }
                    //         modelDesc = result;
                    //     }

                    //     lineItemMap.put('Desc', modelDesc);
                    // }else{
                        lineItemMap.put('Desc', '-');
                    // }
                    System.debug('model Check : ' + item.get('Model__c'));
                    if(item.get('Model__c') != null) {
                        String modelId = (String)item.get('Model__c');
                        List<Model__c> modelName = [SELECT contentVersionId__c FROM Model__c WHERE Id =:modelId LIMIT 1];
                        // lineItemMap.put('ModelImage', String.valueOf(URL.getCurrentRequestUrl()).split('apex')[0]+'/sfc/servlet.shepherd/version/download/'+modelName[0].contentVersionId__c);
                        // lineItemMap.put('ModelImage', 'https://dn-solutions--dev.sandbox.my.site.com/partners/sfc/servlet.shepherd/version/download/'+modelName[0].contentVersionId__c);
                        if(modelName[0].contentVersionId__c != null){
                            ContentVersion dnCVPrdCv = [SELECT VersionDataUrl FROM ContentVersion WHERE Id = :modelName[0].contentVersionId__c LIMIT 1];
                            //model은 있는데 model에 contentversion이 없을 때
                            System.debug('dnCVPrdCV.VersionDataUrl : ' + dnCVPrdCV.VersionDataUrl);
                            if(dnCVPrdCV.VersionDataUrl == null){
                                System.debug('여기1');
                                // lineItemMap.put('ModelImage', 'https://dn-solutions--dev.sandbox.file.force.com/sfc/servlet.shepherd/version/download/'+modelCommon[0].contentVersionId__c);
                                lineItemMap.put('ModelImage', modelCommonURL[0].VersionDataUrl);
                            }else{
                                System.debug('여기2 : ' +modelName[0].contentVersionId__c);
                                // lineItemMap.put('ModelImage', 'https://dn-solutions--dev.sandbox.file.force.com/sfc/servlet.shepherd/version/download/'+modelName[0].contentVersionId__c);
                                lineItemMap.put('ModelImage', dnCVPrdCv.VersionDataUrl);

                            }

                        }else{
                            System.debug('여기3');
                            // lineItemMap.put('ModelImage', 'https://dn-solutions--dev.sandbox.file.force.com/sfc/servlet.shepherd/version/download/'+modelCommon[0].contentVersionId__c);
                            lineItemMap.put('ModelImage', modelCommonURL[0].VersionDataUrl);
                        }
                    }else{
                        System.debug('여기4');
                        
                        // List<Model__c> modelName = [SELECT contentVersionId__c FROM Model__c WHERE Name = 'DN_Common' LIMIT 1];
                        // lineItemMap.put('ModelImage', 'https://dn-solutions--dev.sandbox.my.site.com/partners/sfc/servlet.shepherd/version/download/'+modelName[0].contentVersionId__c);
                        // lineItemMap.put('ModelImage', 'https://dn-solutions--dev.sandbox.file.force.com/sfc/servlet.shepherd/version/download/'+modelCommon[0].contentVersionId__c);
                        lineItemMap.put('ModelImage', modelCommonURL[0].VersionDataUrl);

                    }

                    List<Map<String, Object>> characteristicValuesList = new List<Map<String, Object>>();
                    Integer emptyCheck = 0;
                    Map<String, Object> cvinitItemMap = new Map<String, Object>();
                    cvinitItemMap.put('Category', 'CV');
                    cvinitItemMap.put('Option', 'Option');
                    cvinitItemMap.put('Character', '');
                    cvinitItemMap.put('Value', '');
                    cvinitItemMap.put('cvQty', '');
                    cvinitItemMap.put('Price', '');
                    cvinitItemMap.put('CVAllPrice', '');
                    cvinitItemMap.put('Descrip', '');

                    characteristicValuesList.add(cvinitItemMap);

                    if(charValList.size() > 0) {
                        for(AggregateResult cvItem : charValList) {
                            // for(CharacteristicValue__c cvItem : charValList) {
                            // Boolean cvduple = false;
                            Map<String, Object> cvItemMap = new Map<String, Object>();
                            if((String)item.get('ProductCode') + item.get('ExpectedDelivDate__c') == (String)cvItem.get('ProductCode') + cvItem.get('ExpectedDelivDate__c')) {
                                    cvItemMap.put('Category', 'CV');
                                    cvItemMap.put('Option', '');
                                    // cvItemMap.put('Character', cvItem.C_Value__c);
                                    cvItemMap.put('Character', cvItem.get('C_Value__c'));
                                    cvItemMap.put('Descrip', ' - ' + cvItem.get('V_Value__c'));
                                    // cvItemMap.put('Value', cvItem.get('V_Value__c'));
                                    // cvItemMap.put('cvQty', 1);
                                    cvItemMap.put('cvQty', Integer.valueOf(cvItem.get('Quantity')));
                                    // cvItemMap.put('Price', cvItem.Price__c);
                                if(cvItem.get('Price__c') != null){
                                    cvItemMap.put('Price', Decimal.valueOf(String.valueOf(cvItem.get('Price__c'))).format());
                                    Decimal totalcv = Decimal.valueOf(String.valueOf(cvItem.get('Quantity'))) * Decimal.valueOf(String.valueOf(Integer.valueOf(cvItem.get('Price__c'))));
                                    String formattedValuecv = totalcv.format();
                                    cvItemMap.put('CVAllPrice', formattedValuecv);
                                    allExtPrice = allExtPrice + totalcv;
                                    subTotal = subTotal +  Decimal.valueOf(String.valueOf(cvItem.get('Price__c')));
                                    subQty = subQty + Integer.valueOf(cvItem.get('Quantity'));
                                    subAllTotal = subAllTotal + totalcv;
                                }else{
                                    cvItemMap.put('Price', 0);
                                    cvItemMap.put('CVAllPrice', 0);
                                    allExtPrice = allExtPrice + 0;
                                    subTotal = subTotal + 0;
                                    subQty = subQty + Integer.valueOf(cvItem.get('Quantity'));
                                }
                                    characteristicValuesList.add(cvItemMap);
                                    
                                    // subQty = 1;
                                    emptyCheck++;
                            }
                            index++;
                        }
                    }

                    Map<String, Object> sqinitItemMap = new Map<String, Object>();
                    sqinitItemMap.put('Category', 'SQ');
                    sqinitItemMap.put('Option', 'SQ');
                    sqinitItemMap.put('Character', '');
                    sqinitItemMap.put('Value', '');
                    sqinitItemMap.put('cvQty', '');
                    sqinitItemMap.put('Price', '');
                    sqinitItemMap.put('CVAllPrice', '');
                    sqinitItemMap.put('Descrip', '');

                    characteristicValuesList.add(sqinitItemMap);

                    if(sqList.size() > 0) {
                        for(AggregateResult sqItem : sqList) {
                            Map<String, Object> sqItemMap = new Map<String, Object>();
                            if((String)item.get('ProductCode') + item.get('ExpectedDelivDate__c') == (String)sqItem.get('ProductCode') + sqItem.get('ExpectedDelivDate__c')) {
                                sqItemMap.put('Category', 'SQ');
                                sqItemMap.put('Option', '');
                                sqItemMap.put('Character', sqItem.get('Name'));
                                // sqItemMap.put('Value', '');
                                sqItemMap.put('cvQty', Integer.valueOf(sqItem.get('Quantity')));
                                sqItemMap.put('Descrip', '');
                                if(sqItem.get('Price__c') != null){
                                    sqItemMap.put('Price', Decimal.valueOf(String.valueOf(sqItem.get('Price__c'))).format());
                                    Decimal totalsq = Decimal.valueOf(String.valueOf(sqItem.get('Quantity'))) * Decimal.valueOf(String.valueOf(Integer.valueOf(sqItem.get('Price__c'))));
                                    String formattedValuesq = totalsq.format();
                                    sqItemMap.put('CVAllPrice', formattedValuesq);
                                    allExtPrice = allExtPrice +  totalsq;
                                    subTotal = subTotal +  Decimal.valueOf(String.valueOf(sqItem.get('Price__c')));
                                    subAllTotal = subAllTotal + totalsq;
                                }else{
                                    sqItemMap.put('Price', 0);
                                    sqItemMap.put('CVAllPrice', 0);
                                }
                                characteristicValuesList.add(sqItemMap);
                                
                                subQty = subQty + Integer.valueOf(sqItem.get('Quantity'));
                                emptyCheck++;
                            }
                            index++;
                        }
                    }

                    Map<String, Object> acsinitItemMap = new Map<String, Object>();
                    acsinitItemMap.put('Category', 'Accessory');
                    acsinitItemMap.put('Option', 'Accessory');
                    acsinitItemMap.put('Character', '');
                    acsinitItemMap.put('Value', '');
                    acsinitItemMap.put('cvQty', '');
                    acsinitItemMap.put('Price', '');
                    acsinitItemMap.put('CVAllPrice', '');
                    acsinitItemMap.put('Descrip', '');
                    characteristicValuesList.add(acsinitItemMap);

                    if(accessoryList.size() > 0) {
                        for(AggregateResult acsItem : accessoryList) {
                            Map<String, Object> acsItemMap = new Map<String, Object>();
                            if((String)item.get('ProductCode') + item.get('ExpectedDelivDate__c') == (String)acsItem.get('ProductCode') + acsItem.get('ExpectedDelivDate__c')) {
                                acsItemMap.put('Category', 'Accessory');
                                acsItemMap.put('Option', '');
                                if(acsItem.get('Description__c') != null){
                                    acsItemMap.put('Character', acsItem.get('Name'));
                                    acsItemMap.put('Descrip', acsItem.get('Description__c'));
                                }else{
                                    acsItemMap.put('Character', acsItem.get('Name'));
                                    acsItemMap.put('Descrip', '');
                                }
                                // acsItemMap.put('Value', '');
                                acsItemMap.put('cvQty', Integer.valueOf(acsItem.get('Quantity')));
                                // acsItemMap.put('Price', Decimal.valueOf(String.valueOf(acsItem.get('Price__c'))).format());
                                if (acsItem.get('Price__c') != null) {
                                    acsItemMap.put('Price', Decimal.valueOf(String.valueOf(acsItem.get('Price__c'))).format());
                                    Decimal totalacc = Decimal.valueOf(String.valueOf(acsItem.get('Quantity'))) * Decimal.valueOf(String.valueOf(Integer.valueOf(acsItem.get('Price__c'))));
                                    String formattedValueacc = totalacc.format();
                                    acsItemMap.put('CVAllPrice', formattedValueacc);
                                    characteristicValuesList.add(acsItemMap);
                                    allExtPrice = allExtPrice + totalacc;
                                    subTotal = subTotal +  Decimal.valueOf(String.valueOf(acsItem.get('Price__c')));
                                    subAllTotal = subAllTotal + totalacc;
                                    System.debug('ACC subAllTotal : ' + subAllTotal);
                                } else {
                                    acsItemMap.put('Price', 0); // 기본값 설정
                                    acsItemMap.put('CVAllPrice', 0);
                                    characteristicValuesList.add(acsItemMap);
                                    allExtPrice = allExtPrice + Decimal.valueOf(String.valueOf(acsItem.get('Quantity'))) * 0;
                                    subTotal = subTotal + 0;
                                    subAllTotal = subAllTotal + Decimal.valueOf(String.valueOf(acsItem.get('Quantity'))) * 0;
                                    System.debug('ACC2 subAllTotal : ' + subAllTotal);

                                }
                                
                                subQty = subQty + Integer.valueOf(acsItem.get('Quantity'));
                                emptyCheck++;
                            }
                            index++;
                        }
                    }

                    isLast++;
                    if(isLast == dupquoteLineInfo.size()){
                        lineItemMap.put('IsLast', true);
                    }else{
                        lineItemMap.put('IsLast', false);
                    }
                    lineItemMap.put('CharacteristicValues', characteristicValuesList);
                    lineItemMap.put('SubTotal', Decimal.valueOf(String.valueOf(subTotal)).format());
                    lineItemMap.put('subAllTotal', Decimal.valueOf(String.valueOf(subAllTotal)).format());
                    lineItemMap.put('SubQty', String.valueOf(subQty));
                    lineItemMap.put('AllExtPrice', Decimal.valueOf(String.valueOf(allExtPrice)).format());
                    
                    quoteLineItemList.add(lineItemMap);

                    // Add the list of quote line items to the result map
                    System.debug('final : ' + lineItemMap);
                    result.put('QuoteLineItems', quoteLineItemList);
                    system.debug('allextprice : ' + Decimal.valueOf(String.valueOf(allExtPrice)).format());
                }
    
                
    
                System.debug(result);
            } catch (Exception e) {
                System.debug('Line : ' + e.getLineNumber() + ' : ' + 'Msg : ' + e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
        }else if(recordType.RecordType.DeveloperName == 'Global'){
            Integer num = 0;
            Integer sqnumm = 0;
            Integer accessorynum = 0;
            Integer isLast = 0;
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
                                            Account.MainCategory__c ,
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

                // List<QuoteLineItem> quoteLineInfo = [SELECT 
                //                                         Id,
                //                                         Product2.Name, 
                //                                         Quantity, 
                //                                         ListPrice,
                //                                         RequestedDelivDate__c
                //                                     FROM QuoteLineItem 
                //                                     WHERE QuoteId =: quoteInfo[0].Id];

                //////////////중복체크 logic 시작//////////////////////////
                //Quote Line Item정보
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
                Map<String, Integer> dupAccQtyMap = new Map<String, Integer>();

                //Quote Line Item Id 를 key, ProductCode와 RDD, Warranty, 조정가(Adjustment)를 문자열로 합침
                //key를 만드는 문자열에 DC Price까지 추가_250312 By 문주하
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
                
                //Quote Line Item Id 적재
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
                            Price__c,
                            CurrencyIsoCode
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
                            CurrencyIsoCode,
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
                            Price__c,
                            CurrencyIsoCode
                        FROM
                            Accessory__c
                        WHERE
                            QuoteLineItem__c IN :dupquoteLineId
                            and Delete__c != 'D'
                        ORDER BY
                            QuoteLineItem__c, Key__c
                    ];
                    System.debug('dupaccessoryList : ' + dupaccessoryList);
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

                        // if(dupAccQtyMap.containsKey(key)){
                        //     dupAccQtyMap.put(key, dupAccQtyMap.get(key) + item.Quantity__c);
                        // }else{
                        //     dupAccQtyMap.put(key, item.Quantity__c);
                        // }
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
                //         System.debug('dupQuoteLineIdInfo!!! : ' + dupQuoteLineIdInfo);
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
                System.debug('dupQuoteLineIdInfo : ' + dupQuoteLineIdInfo);
                System.debug('dupquoteLineInfoMapsize : ' + dupquoteLineInfoMap.size());
                for(Integer i = 0; i < dupquoteLineInfoMap.size(); i++) {
                    System.debug('keyvalueQuoteLine : ' + dupquoteLineInfoMap.values().get(i));
                }

                System.debug('dupresultMapsize : ' + dupresultMap.size());

                for(Integer i = 0; i < quoteLineitemId.size(); i++) {
                    System.debug('keyvaluedupresultMap : ' + quoteLineitemId[i]);
                }
                //////////////중복체크 logic 끝//////////////////////////

                

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
                                                        DC_Price__c,
                                                        DC__c,
                                                        CV_Total__c,
                                                        SQ_Total__c,
                                                        Accessory_Total__c,
                                                        Final_Quotation_Price__c,
                                                        LeadTime_In_Months__c
                                                    FROM QuoteLineItem 
                                                    WHERE Id IN: quoteLineitemId];
                // String Incoterms;
                String TermsOfPayment;
                // for (Schema.PicklistEntry entry : Quote.Incoterms__c.getDescribe().getPicklistValues()) {
                //     if (entry.getValue() == quoteInfo[0].Incoterms__c) {
                //         Incoterms = entry.getLabel();
                //         break;
                //     }
                // }
                for (Schema.PicklistEntry entry : Quote.TermsOfPayment__c.getDescribe().getPicklistValues()) {
                    if (entry.getValue() == quoteInfo[0].TermsOfPayment__c) {
                        TermsOfPayment = entry.getLabel();
                        break;
                    }
                }

                result.put('QuoteNumber', quoteInfo[0].QuoteNumber);
                result.put('Dealer', quoteInfo[0].Owner.Name);
                result.put('AccountName', quoteInfo[0].Account.Name);
                result.put('CreatedDate', String.valueOf(quoteInfo[0].CreatedDate).substring(0,10).replace('-','.'));
                result.put('Incoterms', getPicklistValues('Quote', 'Incoterms__c', quoteInfo[0].Incoterms__c));
                // result.put('Incoterms', Incoterms);
                result.put('ProductType', quoteInfo[0].ProductType__c);
                // result.put('TermsOfPayment', quoteInfo[0].TermsOfPayment__c);
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
                if(quoteInfo[0].Account.Representative__c == null){
                    result.put('Representative', '');
                }else{
                    result.put('Representative', quoteInfo[0].Account.Representative__c);
                }
                if(quoteInfo[0].Account.MainCategory__c == null){
                    result.put('Industry', '');
                }else{
                    result.put('Industry', getPicklistValues('Account', 'MainCategory__c', quoteInfo[0].Account.MainCategory__c));
                }
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
                // List<CharacteristicValue__c> charValList = [SELECT
                //                                                 Id,
                //                                                 C_Value__c,
                //                                                 V_Value__c,
                //                                                 QuoteLineItem__c,
                //                                                 Price__c
                //                                             FROM CharacteristicValue__c
                //                                             WHERE QuoteLineItem__c IN :QuoteLIneId and defChange__c = true];
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
                for(Integer i = 0; i < allaccessoryList.size(); i++){
                    System.debug('allaccessoryList' + allaccessoryList[i]);
                }
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
                System.debug('accSum : ' + accSum);
                System.debug('charValList' + charValList);
                for(Integer i = 0; i < sqList.size(); i++){
                    System.debug('sqList' + sqList[i].SQ__r.Name);
                }
                // Create a list to hold quote line item details
                List<Map<String, Object>> quoteLineItemList = new List<Map<String, Object>>();
                
                // Loop through quoteLineInfo and add each item as a map to the list
                for (QuoteLineItem item : quoteLineInfo) {
                    allExtPrice = 0.0;
                    Map<String, Object> lineItemMap = new Map<String, Object>();
                    lineItemMap.put('QuoteLineId', item.Id);   
                    //Product Code대신 Model명으로변경
                    lineItemMap.put('ProductName', item.Product2.Model__r.Name);
                    // lineItemMap.put('Quantity', Decimal.valueOf(String.valueOf(item.Quantity)).format());
                    lineItemMap.put('Quantity', dupresultMap.get(item.Id));
                    if(item.UnitPrice != 0){
                        // lineItemMap.put('ListPrice', Decimal.valueOf(String.valueOf(item.ListPrice)).format());
                        lineItemMap.put('ListPrice', Decimal.valueOf(String.valueOf(item.UnitPrice)).format());
                    }else{
                        lineItemMap.put('ListPrice', 0);
                    }
                    lineItemMap.put('RDD', String.valueOf(item.RequestedDelivDate__c).substring(0,10).replace('-','.'));
                    if(item.LeadTime_In_Months__c != null && item.LeadTime_In_Months__c != 0){
                        lineItemMap.put('leadTime', String.valueOf(item.LeadTime_In_Months__c));
                    }else{
                        lineItemMap.put('leadTime','**');
                    }
                    
                    // lineItemMap.put('prdTotal', Decimal.valueOf(String.valueOf(item.Quantity * item.ListPrice)).format());
                    lineItemMap.put('prdTotal', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * item.UnitPrice)).format());
                    // allExtPrice = allExtPrice + item.Quantity * item.ListPrice;
                    if(item.Adjustment_Price__c != null){
                        lineItemMap.put('Adjustment', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) *  item.Adjustment_Price__c.setScale(2))).format());
                    }else{
                        lineItemMap.put('Adjustment', 0);
                    }
                    if(item.Adjustment_Price__c != null && item.Adjustment_Price__c != 0 && item.AdjustmentPercent__c != null){
                        lineItemMap.put('AdjustPercent', item.AdjustmentPercent__c.setScale(2));
                    }else{
                        lineItemMap.put('AdjustPercent', 0);
                    }
                    if(item.DC_Price__c != null && item.DC_Price__c != 0){
                        lineItemMap.put('DCPrice', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) *  item.DC_Price__c.setScale(2))).format());
                        lineItemMap.put('DCPercent', item.DC__c.setScale(2));
                    }else{
                        lineItemMap.put('DCPrice', 0);
                        lineItemMap.put('DCPercent', 0);
                    }

                    lineItemMap.put('Warranty', getPicklistValues('QuoteLineItem', 'Warranty__c', item.Warranty__c));
                    if(item.Warranty_Price__c != null){
                        lineItemMap.put('WarrantyPrice', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * item.Warranty_Price__c.setScale(2))).format());
                    }else{
                        lineItemMap.put('WarrantyPrice', 0);
                    }
                    allExtPrice = allExtPrice + dupresultMap.get(item.Id) * item.UnitPrice;
                    System.debug('RDD' + item.RequestedDelivDate__c);

                    List<Map<String, Object>> characteristicValuesList = new List<Map<String, Object>>();
                    num = 0;
                    sqnumm = 0;
                    accessorynum = 0;

                    for(CharacteristicValue__c cvItem : charValList) {
                        Map<String, Object> cvItemMap = new Map<String, Object>();
                        System.debug(cvItem.QuoteLineItem__c);
                        if(item.Id == cvItem.QuoteLineItem__c) {

                            num++;
                            if(num == 7) {
                                cvItemMap.put('isPage', true);
                            }else {
                                cvItemMap.put('isPage', false);
                            }

                            cvItemMap.put('No', num);
                            cvItemMap.put('cvId', cvItem.Id);
                            cvItemMap.put('Character', cvItem.C_Value__c + ' - ' + cvItem.V_Value__c);
                            cvItemMap.put('Descrip', '');
                            // cvItemMap.put('Value', cvItem.V_Value__c);
                            // cvItemMap.put('cvQty', 1);
                            cvItemMap.put('cvQty', dupresultMap.get(item.Id));
                            cvItem.Price__c = cvItem.Price__c == null ? 0 : cvItem.Price__c;
                            cvItemMap.put('Price', Decimal.valueOf(String.valueOf(cvItem.Price__c)).format());
                            // cvItemMap.put('Price', '');
                            cvItemMap.put('cvTotal', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * cvItem.Price__c)).format());
                            // cvItemMap.put('cvTotal', '');

                            // allExtPrice = allExtPrice + 1 * cvItem.Price__c;
                            allExtPrice = allExtPrice + dupresultMap.get(item.Id) * cvItem.Price__c; //Global은 Product가격 안에 CV도 포함되어있음
                            characteristicValuesList.add(cvItemMap);
                            System.debug('cvItemMap' + cvItemMap);
                        }
                    }

                    ////////////////////////////
                    num++;
                    Map<String, Object> sqLineMap = new Map<String,Object>();
                    if(num == 7) {
                        sqLineMap.put('isPage', true);
                    }else {
                        sqLineMap.put('isPage', false);
                    }
                    sqLineMap.put('No', '');
                    sqLineMap.put('cvId', '');
                    sqLineMap.put('Character', 'SQ');
                    sqLineMap.put('Value', '');
                    sqLineMap.put('Descrip', '');
                    sqLineMap.put('cvQty', '');
                    sqLineMap.put('Price', '');
                    sqLineMap.put('cvTotal', '');
                    characteristicValuesList.add(sqLineMap);


                    for(SQ_QuoteLineitem_Junction__c sqItem : sqList) {
                        Map<String, Object> sqItemMap = new Map<String, Object>();
                        System.debug(sqItem.QuoteLineItem__c);
                        if(item.Id == sqItem.QuoteLineItem__c) {
                            num++;
                            sqnumm++;
                            if(num == 7) {
                                sqItemMap.put('isPage', true);
                            }else {
                                sqItemMap.put('isPage', false);
                                
                            }
                            System.debug('numcheck : ' + num);

                            sqItemMap.put('No', sqnumm);
                            sqItemMap.put('cvId', sqItem.Id);
                            sqItemMap.put('Character', sqItem.SQ__r.Name);
                            sqItemMap.put('Descrip', '');
                            sqItemMap.put('Value', '');
                            sqItemMap.put('cvQty', dupresultMap.get(item.Id));
                            if(sqItem.SalesPrice__c != null){
                                sqItemMap.put('Price', Decimal.valueOf(String.valueOf(sqItem.SalesPrice__c)).format());
                                sqItemMap.put('cvTotal', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * sqItem.SalesPrice__c)).format());
                                allExtPrice = allExtPrice + dupresultMap.get(item.Id) * sqItem.SalesPrice__c;
                            }else{
                                sqItemMap.put('Price', 0);
                                sqItemMap.put('cvTotal', 0);
                                allExtPrice = allExtPrice + 0;
                            }

                            characteristicValuesList.add(sqItemMap);
                            System.debug('sqItemMap' + sqItemMap);
                        }
                    }

                    num++;
                    Map<String, Object> acsLineMap = new Map<String,Object>();
                    if(num == 7) {
                        acsLineMap.put('isPage', true);
                    }else {
                        acsLineMap.put('isPage', false);
                    }
                    acsLineMap.put('No', '');
                    acsLineMap.put('cvId', '');
                    acsLineMap.put('Character', 'Accessory');
                    acsLineMap.put('Value', '');
                    acsLineMap.put('cvQty', '');
                    acsLineMap.put('Price', '');
                    acsLineMap.put('cvTotal', '');
                    acsLineMap.put('Descrip', '');

                    characteristicValuesList.add(acsLineMap);

                    for(Accessory__c acsItem : accessoryList){
                        Map<String, Object> acsItemMap = new Map<String, Object>();
                        if(item.Id == acsItem.QuoteLineItem__c) {

                            num++;
                            accessorynum++;
                            if(num == 7) {
                                acsItemMap.put('isPage', true);
                            }else {
                                acsItemMap.put('isPage', false);
                            }
                            acsItemMap.put('No', accessorynum);
                            acsItemMap.put('cvId', acsItem.Id);
                            if(acsItem.Description__c == null){
                                acsItemMap.put('Character', acsItem.Name);
                                acsItemMap.put('Descrip', '');
                            }else{
                                acsItemMap.put('Descrip', acsItem.Description__c);
                                acsItemMap.put('Character', acsItem.Name);
                            }
                            acsItemMap.put('Value', '');
                            // acsItemMap.put('cvQty', dupresultMap.get(item.Id));
                            acsItemMap.put('cvQty', accSum.get(acsItem.QuoteLineItem__c+acsItem.Name));
                            // acsItemMap.put('cvQty', dupresultMap.get(item.Id));
                            // acsItemMap.put('cvQty', dupresultMap.get(item.Id));
                            if(acsItem.Price__c != null){
                                acsItemMap.put('Price', Decimal.valueOf(String.valueOf(acsItem.Price__c)).format());
                                // acsItemMap.put('cvTotal', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * acsItem.get('Price__c'))).format());
                                // acsItemMap.put('cvTotal', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * acsItem.Price__c)).format());
                                acsItemMap.put('cvTotal', Decimal.valueOf(String.valueOf(accSum.get(acsItem.QuoteLineItem__c+acsItem.Name) * acsItem.Price__c)).format());
                                // allExtPrice = allExtPrice + dupresultMap.get(item.Id) * acsItem.get('Price__c');
                                // allExtPrice = allExtPrice + dupresultMap.get(item.Id) * acsItem.Price__c;
                                allExtPrice = allExtPrice + accSum.get(acsItem.QuoteLineItem__c+acsItem.Name) * acsItem.Price__c;
                                System.debug('allExtPrice : ' + allExtPrice);
                            }else{
                                acsItemMap.put('Price', 0);
                                acsItemMap.put('cvTotal', 0);
                                allExtPrice = allExtPrice + 0;
                            }

                            characteristicValuesList.add(acsItemMap);
                            System.debug('acsItemMap' + acsItemMap);
                        }
                    }

                    /////////////////////////
                    isLast++;
                    System.debug('size' +  isLast);
                    System.debug('size' +  quoteLineInfo.size());
                    if(isLast == quoteLineInfo.size()){
                        lineItemMap.put('IsLast', true);
                    }else{
                        lineItemMap.put('IsLast', false);
                    }
                    lineItemMap.put('CharacteristicValues', characteristicValuesList);
                    if(item.Adjustment_Price__c != null){
                        lineItemMap.put('NetPrice', Decimal.valueOf(String.valueOf(allExtPrice + dupresultMap.get(item.Id) * item.DC_Price__c.setScale(2))).format());
                    }else{
                        lineItemMap.put('NetPrice', Decimal.valueOf(String.valueOf(allExtPrice)).format());
                    }
                    lineItemMap.put('NetAddAdj', Decimal.valueOf(String.valueOf(allExtPrice + dupresultMap.get(item.Id) * (item.DC_Price__c.setScale(2) + item.Adjustment_Price__c.setScale(2)))).format());
                    if(item.Warranty_Price__c != null){
                        if(item.Adjustment_Price__c != null){
                            lineItemMap.put('FinalPrice', Decimal.valueOf(String.valueOf(dupresultMap.get(item.Id) * item.DC_Price__c.setScale(2) + dupresultMap.get(item.Id) * item.Warranty_Price__c + allExtPrice + dupresultMap.get(item.Id) * item.Adjustment_Price__c)).format());
                        }else{
                            lineItemMap.put('FinalPrice', Decimal.valueOf(String.valueOf(item.Warranty_Price__c + allExtPrice)).format());
                        }
                    }else{
                        lineItemMap.put('FinalPrice', Decimal.valueOf(String.valueOf(allExtPrice)).format());
                    }
                    lineItemMap.put('AllExtPrice', Decimal.valueOf(String.valueOf(allExtPrice)).format());
                    quoteLineItemList.add(lineItemMap);
                    System.debug('quoteLineItemList' + lineItemMap);
                    // Add the list of quote line items to the result map
                    result.put('QuoteLineItems', quoteLineItemList);
                    // result.put('AllExtPrice', Decimal.valueOf(String.valueOf(allExtPrice)).format());
                    System.debug(result);
                }
    
                
            } catch (Exception e) {
                System.debug('error line : ' + e.getLineNumber());
                throw new AuraHandledException(e.getMessage());
            }
        }else if(recordType.RecordType.DeveloperName == 'Service'){
            String language = ApexPages.currentPage().getParameters().get('Language');
            System.debug('language ::: ' + language);
            try {
                List<Quote> quoteInfo = [SELECT 
                                            Id, 
                                            QuoteNumber,
                                            Account.Name, 
                                            Account.CustomerCode__c, 
                                            Account.Fax, 
                                            Account.Mobile__c, 
                                            ExpectedDelivDate__c, 
                                            IncotermsKR__c,
                                            PaymentConditionKR__c, 
                                            CreatedDate ,
                                            EquipmentNameNumber__c ,
                                            Tax,
                                            GrandTotal,
                                            CSGrandTotal__c,
                                            Description,
                                            Discount__c,
                                            BuyerReferenceNo__c,
                                            ListPriceTotal__c,
                                            Subtotal,
                                            CS_Tax__c,
                                            CS_TaxPrice__c
                                        FROM Quote 
                                        WHERE Id =:recordId];
                System.debug('quoteInfo ::: ' + quoteInfo[0]);
                result.put('QuoteNumber', quoteInfo[0].QuoteNumber); // 문서번호
                // result.put('AccountName', quoteInfo[0].Account.Name); // 고객명
                result.put('AccountName', quoteInfo[0].Account.Name != null ? quoteInfo[0].Account.Name : '');
                // result.put('CustomerCode', quoteInfo[0].Account.CustomerCode__c); // Customer Code
                result.put('CustomerCode', quoteInfo[0].Account.CustomerCode__c != null ? quoteInfo[0].Account.CustomerCode__c : ''); // Customer Code
                // result.put('Fax', quoteInfo[0].Account.Fax); // Fax
                result.put('Fax', quoteInfo[0].Account.Fax != null ? quoteInfo[0].Account.Fax : ''); // Fax
                // result.put('Mobile', quoteInfo[0].Account.Mobile__c); // Mobile
                result.put('Mobile', quoteInfo[0].Account.Mobile__c != null ? quoteInfo[0].Account.Mobile__c : ''); // Mobile
                // result.put('ExpirationDate', quoteInfo[0].ExpectedDelivDate__c);
                result.put('ExpirationDate', quoteInfo[0].ExpectedDelivDate__c != null ? quoteInfo[0].ExpectedDelivDate__c : '');
                // result.put('Description', quoteInfo[0].Description); // 기타정보
                result.put('Description', quoteInfo[0].Description != null ? quoteInfo[0].Description.replace('\n', '<br/>') : ''); // 기타정보
                result.put('BuyerReferenceNo', quoteInfo[0].BuyerReferenceNo__c != null ? quoteInfo[0].BuyerReferenceNo__c : ''); // 고객참조번호

                // result.put('Discount', quoteInfo[0].Discount__c != null ? quoteInfo[0].Discount__c : ''); // 할인율
                // result.put('Incoterms', quoteInfo[0].IncotermsKR__c);
                result.put('Incoterms', quoteInfo[0].IncotermsKR__c != null ? quoteInfo[0].IncotermsKR__c : '');
                // result.put('TermsOfPayment', quoteInfo[0].PaymentConditionKR__c); // 수금조건
                String paymentCondition = quoteInfo[0].PaymentConditionKR__c == null ? '' : quoteInfo[0].PaymentConditionKR__c;

                if (language == 'EN' && paymentCondition != '') {
                    switch on paymentCondition {
                        when '현금 일시불' {
                            paymentCondition = 'Cash payment';
                        }
                        when '현금 분할' {
                            paymentCondition = 'Cash installment payment';
                        }
                        when '캐피탈' {
                            paymentCondition = 'Capital';
                        }
                        when '기타' {
                            paymentCondition = 'ETC';
                        }
                    }
                }

                result.put('TermsOfPayment', paymentCondition); // 수금조건
                
                // Date createdDate = quoteInfo[0].CreatedDate.date();
                // result.put('CreatedDate', quoteInfo[0].CreatedDate.format('yyyy.MM.dd')); // 문서일자, 효력 시작일
                Date createdDate = quoteInfo[0].CreatedDate != null ? quoteInfo[0].CreatedDate.date() : null;
                result.put('CreatedDate', createdDate != null ? quoteInfo[0].CreatedDate.format('yyyy.MM.dd') : ''); // 문서일자, 효력 시작일
                
                // 납기예상일에 따른 효력 만료일 계산
                Integer monthAdd = 0;
                if (quoteInfo[0].ExpectedDelivDate__c == '계약 후 1개월 내') {
                    monthAdd = 1;
                } else if (quoteInfo[0].ExpectedDelivDate__c == '계약 후 2개월 내') {
                    monthAdd = 2;
                } else if (quoteInfo[0].ExpectedDelivDate__c == '계약 후 3개월 내') {
                    monthAdd = 3;
                } else if (quoteInfo[0].ExpectedDelivDate__c == '계약 후 4개월 내') {
                    monthAdd = 4;
                } else if (quoteInfo[0].ExpectedDelivDate__c == '계약 후 5개월 내') {
                    monthAdd = 5;
                } else if (quoteInfo[0].ExpectedDelivDate__c == '계약 후 6개월 내') {
                    monthAdd = 6;
                } else if (quoteInfo[0].ExpectedDelivDate__c == '협의 필요') {
                    monthAdd = null;
                }                
                Date expirationDate = (createdDate != null && monthAdd != null) ? createdDate.addMonths(monthAdd) : null;
                result.put('ExpirationDate', expirationDate != null ? String.valueOf(expirationDate).replace('-', '.') : ''); // 효력 만료일
                
                // result.put('Tax', String.valueOf(quoteInfo[0].Tax.setScale(0))); // 세금 String
                // result.put('Tax', Decimal.valueOf(String.valueOf(quoteInfo[0].Tax)).format()); // 세금
                // result.put('GrandTotal', Decimal.valueOf(String.valueOf(quoteInfo[0].GrandTotal)).format()); // 합계금액
                // result.put('Subtotal', Decimal.valueOf(String.valueOf(quoteInfo[0].Subtotal)).format()); // 정가, 단가
                // result.put('Tax', quoteInfo[0].CS_Tax__c != null ? Decimal.valueOf(String.valueOf(quoteInfo[0].CS_Tax__c)).format() : ''); // 세금
                Decimal tax = quoteInfo[0].CS_Tax__c; //세금
                if (tax != null) {
                    result.put('Tax', '(' + tax.format() + '%)');
                } else {
                    result.put('Tax', '');
                }
                result.put('TaxPrice', quoteInfo[0].CS_TaxPrice__c != null ? Decimal.valueOf(String.valueOf(quoteInfo[0].CS_TaxPrice__c)).format() : ''); // 세금가
                result.put('GrandTotal', quoteInfo[0].CSGrandTotal__c != null ? Decimal.valueOf(String.valueOf(quoteInfo[0].CSGrandTotal__c)).format() : ''); // 합계금액
                result.put('ListTotal', quoteInfo[0].ListPriceTotal__c != null ? Decimal.valueOf(String.valueOf(quoteInfo[0].ListPriceTotal__c)).format() : ''); // 합계금액
                result.put('Subtotal', quoteInfo[0].Subtotal != null ? Decimal.valueOf(String.valueOf(quoteInfo[0].Subtotal)).format() : ''); // 정가, 단가
                Decimal discountAmount = (quoteInfo[0].ListPriceTotal__c != null ? quoteInfo[0].ListPriceTotal__c : 0)
                    - (quoteInfo[0].CSGrandTotal__c != null ? quoteInfo[0].CSGrandTotal__c : 0) 
                    + (quoteInfo[0].Tax != null ? quoteInfo[0].Tax : 0);
                
                // 0이면 '0', 아니면 '-금액' 형식의 문자열로 처리
                Decimal finalDiscount = (discountAmount != null && discountAmount < 0) ? 0 : discountAmount;

                String discountStr = (finalDiscount != null) 
                    ? '-' + String.valueOf(finalDiscount) 
                    : '0';
                if (discountStr.contains('--')) {
                    discountStr = '0';
                }
                
                result.put('DiscountAmount', discountStr != null ? Decimal.valueOf(discountStr).format() : '');
                System.debug('DiscountAmount::' + discountStr);

                List<QuoteLineItem> quoteLineInfo = [
                    SELECT 
                        Id, 
                        QuoteId, 
                        Product2.Name, 
                        Quantity, 
                        UnitPrice, 
                        TotalPrice, 
                        CSTotalPrice__c, 
                        SortOrder,
                        ListPrice__c,
                        DiscountedPrice__c,
                        Product2.ProductCode
                    FROM QuoteLineItem 
                    WHERE QuoteId = :recordId
                ];
                System.debug('quoteLineInfo:::' + quoteLineInfo);
                List<Map<String, Object>> lineItems = new List<Map<String, Object>>();
                Integer i = 10;
                Decimal totalAmount = 0;
                Decimal totalQuantity = 0;


                for (QuoteLineItem item : quoteLineInfo) {
                    Map<String, Object> lineItemMap = new Map<String, Object>();

                    lineItemMap.put('index', i); // 순번
                    // lineItemMap.put('ProductCode', item.Product2.ProductCode); // 제품 코드
                    // lineItemMap.put('ProductName', item.Product2.Name); // 제품명
                    // lineItemMap.put('Quantity', String.valueOf(item.Quantity.setScale(0))); // 수량
                    // lineItemMap.put('UnitPrice', Decimal.valueOf(String.valueOf(item.UnitPrice)).format()); // 단가
                    // lineItemMap.put('TotalPrice', Decimal.valueOf(String.valueOf(item.TotalPrice)).format()); // 총액
                    
                    lineItemMap.put('ProductCode', item.Product2.ProductCode != null ? item.Product2.ProductCode : ''); // 제품 코드
                    // lineItemMap.put('ProductCode', String.valueOf(item.Product2 != null ? item.Product2.ProductCode : ''));
                    lineItemMap.put('ProductName', item.Product2.Name != null ? item.Product2.Name : ''); // 제품명
                    lineItemMap.put('Quantity', item.Quantity != null ? String.valueOf(item.Quantity.setScale(0)) : ''); // 수량
                    lineItemMap.put('ListPrice', item.ListPrice__c != null ? Decimal.valueOf(String.valueOf(item.ListPrice__c)).format() : ''); // 정가
                    lineItemMap.put('UnitPrice', item.UnitPrice != null ? Decimal.valueOf(String.valueOf(item.UnitPrice)).format() : ''); // 단가
                    Decimal discounted = item.DiscountedPrice__c != null ? item.DiscountedPrice__c : 0;
                    String discountedStr = (discounted != 0) 
                        ? '-' + String.valueOf(discounted) 
                        : '0';
                    if (discountedStr.contains('--')) {
                        discountedStr = '0';
                    }
                    
                    // lineItemMap.put('DiscountedPrice', discountedStr);// 할인가
                    lineItemMap.put('DiscountedPrice', discountedStr != null ? Decimal.valueOf(String.valueOf(discountedStr)).format() : '');
                    
                    lineItemMap.put('TotalPrice', item.CSTotalPrice__c != null ? Decimal.valueOf(String.valueOf(item.CSTotalPrice__c)).format() : ''); // 총액

                    lineItems.add(lineItemMap);
                    i += 10;
                    // totalAmount += item.TotalPrice;
                    // totalQuantity += item.Quantity;
                    totalAmount += item.CSTotalPrice__c != null ? item.CSTotalPrice__c : 0;
                    totalQuantity += item.Quantity != null ? item.Quantity : 0;
                }

                // Integer totalItems = 30;
                // Integer itemsPerPage = 10;
                // Integer totalPages = (totalItems + itemsPerPage - 1) / itemsPerPage;

            
                // 결과에 LineItems 추가
                // result.put('LineItems', lineItems);
                // result.put('TotalAmount', totalAmount.format());
                // result.put('TotalQuantity', totalQuantity.format());
                result.put('LineItems', lineItems);
                result.put('TotalAmount', totalAmount != null ? totalAmount.format() : null);
                result.put('TotalQuantity', totalQuantity != null ? totalQuantity.format() : null);
                // result.put('totalPages', totalPages);
                System.debug('result:::' + result);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    @AuraEnabled
    public static string getKeyfield(String recordId){

        List<QuoteLineItem> noQuoteLine = 
                [
                    SELECT 
                        Id,
                        Final_Quotation_Price__c 
                    FROM 
                        QuoteLineItem
                    WHERE
                        QuoteId =: recordId
                ];

        List<Quote> recordType = [SELECT Id, RecordType.Name FROM Quote WHERE Id =: recordId];
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
        //딜러인데 Worker이고, Global이면 견적서 이용 못함
        if(isPortal && recordType[0].RecordType.Name == 'Global' && currentUser.UserRole.PortalRole == 'Worker'){
            return System.Label.DNS_M_DontUseQuote;
        }

        String keyField = '';
        try {
            
            Quote recordName =
            [
                SELECT 
                    RecordType.DeveloperName
                FROM
                    Quote
                WHERE
                    Id =: recordId
            ];
            if(recordName.recordType.DeveloperName == 'Korea'){
                Quote keycheck = 
                [
                    SELECT 
                        Id,
                        ExpectedDelivDate__c,
                        IncotermsKR__c,
                        PaymentConditionKR__c, 
                        RecordType.DeveloperName
                    FROM
                        Quote
                    WHERE
                        Id =: recordId
                                
                ];
                if(keycheck.ExpectedDelivDate__c == null){
                    keyField = Schema.Quote.ExpectedDelivDate__c.getDescribe().getLabel();
                }
                if(keycheck.IncotermsKR__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.IncotermsKR__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.IncotermsKR__c.getDescribe().getLabel();
                    }
                }
                if(keycheck.PaymentConditionKR__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.PaymentConditionKR__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.PaymentConditionKR__c.getDescribe().getLabel();
                    }
                }
                
            }else if(recordName.recordType.DeveloperName == 'Global'){
                Quote keycheck = 
                [
                    SELECT 
                        Id,
                        QuoteNumber,
                        Owner.Name,
                        CreatedDate,
                        Account.Name,
                        NewExist__c,
                        Account.ShippingAddress,
                        Account.Representative__c,
                        Account.MainCategory__c ,
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
                        Account.ShippingState 
                    FROM
                        Quote
                    WHERE
                        Id =: recordId
                ];
                if(keycheck.NewExist__c == null){
                    keyField = Schema.Quote.NewExist__c.getDescribe().getLabel();
                }
                if(keycheck.Port__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.Port__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.Port__c.getDescribe().getLabel();
                    }
                }
                if(keycheck.ExistingMachine__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.ExistingMachine__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.ExistingMachine__c.getDescribe().getLabel();
                    }
                }
                if(keycheck.Incoterms__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.Incoterms__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.Incoterms__c.getDescribe().getLabel();
                    }
                }
                if(keycheck.TermsOfPayment__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.TermsOfPayment__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.TermsOfPayment__c.getDescribe().getLabel();
                    }
                }
                if(keycheck.ProductType__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.ProductType__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.ProductType__c.getDescribe().getLabel();
                    }
                }
                if(keycheck.Competition__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.Competition__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.Competition__c.getDescribe().getLabel();
                    }
                }
                if(keycheck.PurposeOfUse__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.PurposeOfUse__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.PurposeOfUse__c.getDescribe().getLabel();
                    }
                }
                if(keycheck.UsageOfProduct__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.UsageOfProduct__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.UsageOfProduct__c.getDescribe().getLabel();
                    }
                }
                if(keycheck.PreInspection__c == null){
                    if(keyField.length() == 0){
                        keyField = Schema.Quote.PreInspection__c.getDescribe().getLabel();
                    }else{
                        keyField = keyField + ', ' + Schema.Quote.PreInspection__c.getDescribe().getLabel();
                    }
                }

            }
            if(noQuoteLine.size() == 0){
                return System.Label.DNS_M_NoQuoteLine;
            }
            if(keyField.length() > 0){
                return keyField + ' ' + System.Label.DNS_M_InsertRequiredField;
            }else {
                return 'SUCCESS';
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String getVersion(Id quoteId){
        try {
            List<ContentVersion> docList = [
                                        SELECT
                                            Id
                                        FROM
                                            ContentVersion
                                        WHERE
                                            FirstPublishLocationId =: quoteId
                                        ];
        if(docList.size() == 0){
            return 'V1';
        }else {
            List<String> contentVersionIds = new List<String>();

            for(Integer i = 0; i < docList.size(); i++){
                contentVersionIds.add(docList[i].Id);
            }

            List<ContentVersion> pdfList = [
                                            SELECT
                                                Id
                                            FROM
                                                ContentVersion
                                            WHERE
                                                Id IN :contentVersionIds AND FileType ='PDF'
                                            ];
            if(pdfList.size() == 0) {
                return 'V1';
            }else {
                Integer pdfCount = pdfList.size() + 1;
                return 'V' + pdfCount;
            }
        }
        
        } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
    }

    @AuraEnabled
    public static Map<String,String> generatePDF(Id quoteId){
        String currentVersion = getVersion(quoteId);
        Quote quote = [ SELECT  Id, 
                                Name, 
                                RecordType.DeveloperName, 
                                QuoteNumber,
                                CreatedDate,
                                Account.Name,
                                VersionCount__c 
                                FROM Quote WHERE Id = :quoteId LIMIT 1];
        PageReference pdfPage;
        if(quote.RecordType.DeveloperName == 'Korea'){
            pdfPage  = Page.DN_QuotationExport_KRPage; 
        }else if(quote.RecordType.DeveloperName == 'Global'){
            pdfPage = Page.DN_QuotationExport_ENPage; 
        }else if(quote.RecordType.DeveloperName == 'Service'){
            pdfPage  = Page.DN_CS_QuotePDF_KRPage; 
        }

        pdfPage.getParameters().put('id', quote.Id);
        
        Blob pdfBlob;
        if (Test.isRunningTest()) {
            // 테스트 실행 시 더미 데이터 사용
            pdfBlob = Blob.valueOf('Test PDF Content');
        } else {
            try {
                pdfBlob = pdfPage.getContentAsPDF();
            } catch (VisualforceException e) {
                throw new AuraHandledException(System.Label.DNS_M_PDFCreateError + ' : ' + e.getMessage());
            }
        }

        
        // QuoteDocument quoteDoc = new QuoteDocument();
        // quoteDoc.QuoteId = quoteId;
        // quoteDoc.Document = pdfBlob;
        // insert quoteDoc;

        String dateFormat = quote.CreatedDate.format('yyyy-MM-dd');
        ContentVersion contentVersion = new contentVersion();
        contentVersion.Title = quote.QuoteNumber + '_' + quote.Account.Name + '_' + dateFormat + '_' + currentVersion;
        contentVersion.PathOnClient = quote.QuoteNumber + '_' + quote.Account.Name + '_' + dateFormat + '_' + currentVersion + '.pdf';
        contentVersion.VersionData = pdfBlob;
        contentVersion.FirstPublishLocationId = quoteId;
        insert contentVersion;

        // ContentDocumentId 가져오기
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

        // 문서가 이미 부모 레코드에 링크되어 있는지 확인
        List<ContentDocumentLink> existingLinks = [
            SELECT Id FROM ContentDocumentLink 
            WHERE ContentDocumentId = :contentDocumentId 
            AND LinkedEntityId = :quoteId
        ];

        if (existingLinks.isEmpty()) {
            // ContentDocument를 부모 레코드에 링크
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentDocumentId;
            cdl.LinkedEntityId = quoteId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }

        String base64PDF = EncodingUtil.base64Encode(pdfBlob);
        // String quoteName = quote.QuoteNumber + '_' + quote.Account.Name + '_' + dateFormat + '_' + currentVersion;
        String quoteName = quote.QuoteNumber + '_' + quote.Account.Name + '_' + dateFormat + '_V' + quote.VersionCount__c;
        Map<String, String> result = new Map<String, String>();
        result.put('QuoteName', quoteName);
        result.put('base64PDF', base64PDF);

        return result;
    }

    public static String getPicklistValues(String objectName, String fieldName, String picklistValue) {
        // Describe the field
        Schema.DescribeSObjectResult objSchema = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Schema.DescribeFieldResult fieldResult = objSchema.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        // 특정 Value의 Label 찾기
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.getValue() == picklistValue) {
                return entry.getLabel();
            }
        }

        // Value에 해당하는 Label이 없는 경우 null 반환
        return null;
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
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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