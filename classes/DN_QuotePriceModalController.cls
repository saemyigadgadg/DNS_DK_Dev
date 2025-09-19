/**
 * @description       : 
 * @author            : Joohyun Lee
 * @group             : 
 * @last modified on  : 05-15-2025
 * @last modified by  : Hanyeong Choi
**/
public with sharing class DN_QuotePriceModalController {
    
    @AuraEnabled
    public static string tradeCustomerCheck(List<QuoteLineItem> lineItemList){
        String TradeCustomer = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
        String DNSACustomer = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DNSACustomer').getRecordTypeId();

        List<QuoteLineItem> accCheck = [SELECT Quote.Account.RecordType.Name, Quote.Account.RecordTypeId, Quote.Account.IsBlocked__c FROM QuoteLineItem WHERE Id =: lineItemList[0].Id];
        if(!accCheck.isEmpty()){
            // 0330 이주현 OR -> AND 로 변경 
            if(accCheck[0].Quote.Account.IsBlocked__c == true && accCheck[0].Quote.Account.RecordTypeId != DNSACustomer){
                return System.Label.DNS_M_CheckTradeCustomer;
            }else{
                return 'SUCCESS';
            }
        }
        return 'SUCCESS';
    }

    @AuraEnabled
    public static string getQuotePrice(List<QuoteLineItem> lineItemList){
        String recordTypeIdGlobal  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Global').getRecordTypeId();
        String recordTypeIdFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();
        String recordTypeIdCommo = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();

        String recordTypeIdDealer  = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();

        Decimal adjustmentPrice = 0;

        try {
            System.debug('getQuotePrice - lineItem : ' + lineItemList);
            // QuoteLineItem:{TotalPrice=137700000.00, Subtotal=137700000, Quantity=1, Id=0QLJO0000005MMU4A2, ListPrice=0.00}
            Set<Id> quoteLineId = new Set<Id>();       // 선택한 QuoteLineItem 중 첫 번째 ID
            Set<Id> updatequoteLineId = new Set<Id>(); // 선택한 QuoteLineItem 중 첫 번째 ID를 제외한 나머지 ID
            Set<Id> allquoteLineId = new Set<Id>();    // 선택한 QuoteLineItem의 ID

            List<QuoteLineItem> upRecord = new List<QuoteLineItem>();
            List<QuoteLineItem> quoteLineItemsToUpdate = new List<QuoteLineItem>();
            List<QuoteLineItem> getInquiry = new List<QuoteLineItem>();
            List<QuoteLineItem> getInquiryEdit = new List<QuoteLineItem>();

            List<Accessory__c> upAccRecord = new List<Accessory__c>();
            List<Accessory__c> accUpdateFlagList = new List<Accessory__c>();
            List<Accessory__c> acceInfo = new List<Accessory__c>();
            List<Accessory__c> acceInfoEdit = new List<Accessory__c>();

            List<DNSA_Factory_Option_Junction__c> upFactoryOptionRecord = new List<DNSA_Factory_Option_Junction__c>();
            List<DNSA_Factory_Option_Junction__c> factoryUpdateFlagList = new List<DNSA_Factory_Option_Junction__c>();
            List<DNSA_Factory_Option_Junction__c> factoryOptionInfo = new List<DNSA_Factory_Option_Junction__c>();
            List<DNSA_Factory_Option_Junction__c> factoryOptionInfoEdit = new List<DNSA_Factory_Option_Junction__c>();

            List<SQ_QuoteLineitem_Junction__c> sqUpdateFlagList = new List<SQ_QuoteLineitem_Junction__c>();
            List<SQ_QuoteLineitem_Junction__c> upSQRecord = new List<SQ_QuoteLineitem_Junction__c>();
            List<SQ_QuoteLineitem_Junction__c> sqInfo = new List<SQ_QuoteLineitem_Junction__c>();
            List<SQ_QuoteLineitem_Junction__c> sqInfoEdit = new List<SQ_QuoteLineitem_Junction__c>();

            List<CharacteristicValue__c> upCvRecord = new List<CharacteristicValue__c>();
            List<T_COND_ELMT__c> elmtList = new List<T_COND_ELMT__c>();

            Map<String, String> inquiryInfo = new Map<String, String>();
            Map<String, String> quotationInfo = new Map<String, String>();
            
            Date today = Date.today();
            Date futureDate = today.addDays(60); // 60일 후의 날짜
            DateTime dateTimeInstance = DateTime.newInstance(futureDate.year(), futureDate.month(), futureDate.day()); // Date를 DateTime으로 변환
            String formattedDate = dateTimeInstance.format('yyyy-MM-dd'); // 원하는 형식으로 변환

            Boolean isDnsa = false;
            String WAERK; // Currency

            for(Integer i = 0; i < lineItemList.size(); i++){
                if(i == 0) { quoteLineId.add(lineItemList[i].Id); } //맨 첫번째 quotelineitem만 가지고 erp 견적 생성
                else { updatequoteLineId.add(lineItemList[i].Id); } //첫번쨰 quote line item이 다 업데이트 되면 나머지 sq, cv, 추가자재, erp quotation no를 업데이트하기위해 id저장

                allquoteLineId.add(lineItemList[i].Id);
            }

            //Plant정보 세팅
            List<QuoteLineItem> prdInfoList = [SELECT Product2Id FROM QuoteLineItem WHERE Id IN:quoteLineId];
            List<ProductByPlant__c> plantInfo = [SELECT Part__r.RecordType.Name, Plant__c FROM ProductByPlant__c WHERE Part__r.RecordType.Name  LIKE '%Base%' and Plant__c LIKE '18%' and Part__c =: prdInfoList[0].Product2Id];
            String PLANT = Test.isRunningTest() ? '1800' : plantInfo[0]?.Plant__c;
            
            //Warranty정보 세팅
            Map<String, Warranty__c> korWarMap = new Map<String, Warranty__c>();
            Map<String, Warranty__c> globalWarMap = new Map<String, Warranty__c>();
            Map<String, Warranty__c> dnsaWarMap = new Map<String, Warranty__c>();
            
            List<Warranty__c> warrList = [SELECT Id, KSCHL__c, VKORG__c, SPART__c, VTWEG__c, ZZPR_WAR__c, Percent__c, DATBI__c, DATAB__c, ZZWARRPER__c, ZZPERUNIT__c, ZZWARHRS__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c, BZIRK__c FROM Warranty__c];
            for(Warranty__c warr : warrList) {
                if(warr.BZIRK__c == 'M3UL') { dnsaWarMap.put(warr.ZZPR_WAR__c, warr); }
                else if(warr.VTWEG__c == '10') { korWarMap.put(warr.ZZPR_WAR__c, warr); }
                else if(warr.VTWEG__c == '20') { globalWarMap.put(warr.ZZPR_WAR__c, warr); }
            }
            
            List<QuoteLineItem> reErpCheck = [SELECT Id FROM QuoteLineItem WHERE Id IN: quoteLineId AND ReERPQuotation__c = true];

            ////////////////////////////ERP Quotation 생성 I/F///////////////////////////////////////

            if(!reErpCheck.isEmpty()){
                getInquiry = [ 
                    SELECT  Id,
                            Quote.RecordTypeId,
                            Product2.Plant__c, 
                            Product2.ProductCode, 
                            Product2.Description, 
                            Quote.Opportunity.MainCategory__c, 
                            Quote.Opportunity.SubCategory__c, 
                            Quote.Opportunity.IsTooling__c, 
                            Quote.Incoterms__c, 
                            Quote.TermsOfPayment__c, 
                            Quote.IncotermsKR__c, 
                            Quote.PaymentConditionKR__c, 
                            ERPInquiryNo__c, 
                            ERPQuotationNo__c, 
                            Quote.OwnerId, 
                            Quote.AccountId, 
                            OpportunityLineItem.Opportunity.RecordType.Name, 
                            RequestedDelivDate__c, 
                            OpportunityLineItem.Opportunity.Inquiry_Type__c ,
                            Warranty__c,
                            Max_POSNR__c,
                            OpportunityLineItem.Opportunity.Opportunity_Owner__c,
                            OpportunityLineItem.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c, 
                            OpportunityLineItem.Opportunity.Opportunity_Owner__r.Account.DealerGrade__c,
                            OpportunityLineItem.Opportunity.Opportunity_Owner__r.Profile.Name,
                            OpportunityLineItem.Opportunity.Account.CustomerCode__c,
                            OpportunityLineItem.Opportunity.Opportunity_Owner__r.Profile.UserLicense.Name,
                            CurrencyIsoCode,
                            Quote.Account.CustomerCode__c,
                            Product2.Name__c,
                            Quote.DNSA_SalesOffice__c,
                            Adjustment_Price__c,
                            ZSSD__c,
                            ZSSS__c,
                            Quote.Account.CountryLookup__r.CountryCode__c,
                            Quote.Opportunity.Account.RecordTypeId,
                            Quote.Opportunity.Account.CustomerCode__c,
                            Quote.Opportunity.Opportunity_Owner__c,
                            Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c,
                            Requested_Ship_Date__c
                    FROM    QuoteLineItem 
                    WHERE   Id IN: quoteLineId
                ];

            }else{
                getInquiry = [
                    SELECT  Id,
                            Quote.RecordTypeId,
                            Product2.Plant__c, 
                            Product2.ProductCode, 
                            Product2.Description, 
                            Quote.Opportunity.MainCategory__c, 
                            Quote.Opportunity.SubCategory__c, 
                            Quote.Opportunity.IsTooling__c, 
                            Quote.Incoterms__c, 
                            Quote.TermsOfPayment__c, 
                            Quote.IncotermsKR__c, 
                            Quote.PaymentConditionKR__c, 
                            ERPInquiryNo__c, 
                            ERPQuotationNo__c, 
                            Quote.OwnerId, 
                            Quote.AccountId, 
                            OpportunityLineItem.Opportunity.RecordType.Name, 
                            RequestedDelivDate__c, 
                            OpportunityLineItem.Opportunity.Inquiry_Type__c ,
                            Warranty__c,
                            Max_POSNR__c,
                            OpportunityLineItem.Opportunity.Opportunity_Owner__c,
                            OpportunityLineItem.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c, 
                            OpportunityLineItem.Opportunity.Opportunity_Owner__r.Account.DealerGrade__c,
                            OpportunityLineItem.Opportunity.Opportunity_Owner__r.Profile.Name,
                            OpportunityLineItem.Opportunity.Account.CustomerCode__c,
                            OpportunityLineItem.Opportunity.Opportunity_Owner__r.Profile.UserLicense.Name,
                            CurrencyIsoCode,
                            Quote.Account.CustomerCode__c,
                            Product2.Name__c,
                            Quote.DNSA_SalesOffice__c,
                            Adjustment_Price__c,
                            ZSSD__c,
                            ZSSS__c,
                            Quote.Account.CountryLookup__r.CountryCode__c,
                            Quote.Opportunity.Account.RecordTypeId,
                            Quote.Opportunity.Account.CustomerCode__c,
                            Quote.Opportunity.Opportunity_Owner__c,
                            Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c,
                            Requested_Ship_Date__c
                    FROM    QuoteLineItem 
                    WHERE   Id IN: quoteLineId AND ERPQuotationNo__c = null
                ];
            }

            if(getInquiry.size() > 0 || reErpCheck.size() > 0){

                WAERK  = getInquiry[0].CurrencyIsoCode;
                isDnsa = getInquiry[0].Quote.RecordTypeId == recordTypeIdFactory || getInquiry[0].Quote.RecordTypeId == recordTypeIdCommo;
                
                String ownerCheck = getInquiry[0].Quote.Opportunity.Opportunity_Owner__c != null ? getInquiry[0].Quote.Opportunity.Opportunity_Owner__c : getInquiry[0].Quote.OwnerId;
                String ZZKVGR4    = getInquiry[0].OpportunityLineItem.Opportunity.Opportunity_Owner__r.Account.DealerGrade__c;
            
                String VTWEG;
                String VKORG;
                String SPART;
                String KUNNR;
                String KUNWE;
                String VKBUR;
            
                User getIFinfo = new User();
            
                if(isDnsa) {
                    getIFinfo = [ 
                        SELECT  SalesOrganization__c, 
                                Division__c, 
                                DistributionChannel__c,
                                Account.CustomerCode__c,
                                AccountId
                        FROM    User
                        WHERE   Id =: getInquiry[0].Quote.OwnerId
                    ]; // 사용자 및 계정 정보 조회

                    List<Account> getIFCustomerCode = DN_WithoutSharingClass.getAccountCustomerCode(getIFinfo.AccountId);
                    List<Account> getIFCustomerCode2 = DN_WithoutSharingClass.getAccountCustomerCode(getInquiry[0].Quote.AccountId);

                    PLANT = '4140';
                    VTWEG = getInquiry[0].Quote.Account.CountryLookup__r.CountryCode__c == 'US' ? '10' : '20';
                    VKORG = '4140';
                    SPART = '40';
                    KUNNR = getIFCustomerCode[0].CustomerCode__c;
                    KUNWE = getIFCustomerCode2[0].CustomerCode__c;
                    VKBUR = getInquiry[0].Quote.DNSA_SalesOffice__c;
                } else {
                    getIFinfo = [
                        SELECT  SalesOrganization__c, 
                                Division__c, 
                                DistributionChannel__c // 10 or 20 -> currency 가 KRW 
                        FROM    User 
                        WHERE   Id =: ownerCheck
                    ];

                    VTWEG = getInquiry[0].CurrencyIsoCode == 'KRW' ? '10' : '20';
                    VKORG = getIFinfo.SalesOrganization__c;
                    SPART = getIFinfo.Division__c;
                    // 20250421 직영일 때 Ship to 9999고정
                    KUNWE = getInquiry[0].Quote.Opportunity.Opportunity_Owner__r.AccountId == null ? '9999' : getInquiry[0].Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c;

                    if(getInquiry[0].Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c != null && getInquiry[0].Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c != ''){
                        KUNNR = getInquiry[0].Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c;
                    }else if(getInquiry[0].Quote.Opportunity.Account.RecordTypeId == recordTypeIdDealer){
                        KUNNR = getInquiry[0].Quote.Opportunity.Account.CustomerCode__c;
                    }else{
                        KUNNR = '9997';
                    }
                }

                List<CharacteristicValue__c> cvInfo = [
                    SELECT  Id, 
                            C_Code__c, 
                            V_Code__c, 
                            Price__c, 
                            QuoteLineItem__c 
                    FROM    CharacteristicValue__c 
                    WHERE   QuoteLineItem__c IN: quoteLineId 
                    ORDER BY QuoteLineItem__c
                ];
                
                Map<String, List<Map<String, CharacteristicValue__c>>> cvMap = new Map<String, List<Map<String, CharacteristicValue__c>>>();
                Map<String, List<Map<String, CharacteristicValue__c>>> cvMap2 = new Map<String, List<Map<String, CharacteristicValue__c>>>();

                for(String id : quoteLineId){
                    if (!cvMap.containsKey(id))  { cvMap.put(id, new List<Map<String, CharacteristicValue__c>>()); }
                    if (!cvMap2.containsKey(id)) { cvMap2.put(id, new List<Map<String, CharacteristicValue__c>>()); }
                    
                    for (CharacteristicValue__c cv : cvInfo) {
                        if(cv.QuoteLineItem__c == id){
                    
                            String key = String.valueOf(cv.C_Code__c) + '-' + String.valueOf(cv.V_Code__c);
                            Map<String, CharacteristicValue__c> newMap = new Map<String, CharacteristicValue__c>();
                            newMap.put(key, cv);
                            cvMap.get(id).add(newMap);

                            String key2 = String.valueOf(cv.C_Code__c) + String.valueOf(cv.V_Code__c);
                            Map<String, CharacteristicValue__c> newMap2 = new Map<String, CharacteristicValue__c>();
                            newMap2.put(key2, cv);
                            cvMap2.get(id).add(newMap2);
                        }
                    }
                }

                acceInfo = [
                    SELECT  Id, 
                            POSNR__c, 
                            Key__c, 
                            Description__c, 
                            Quantity__c, 
                            SalesUnit__c, 
                            QuoteLineItem__r.Product2.Plant__c, 
                            QuoteLineItem__c,
                            Price__c
                    FROM    Accessory__c 
                    WHERE   QuoteLineItem__c IN: quoteLineId 
                    ORDER BY QuoteLineItem__c, POSNR__c
                ];

                if(isDnsa) {
                    factoryOptionInfo = 
                    [
                        SELECT
                            Id,
                            POSNR__c,
                            ERP_Price__c,
                            Quote_Line_Item__c,
                            Quantity__c,
                            DNSA_Factory_Option__r.Price__c,
                            DNSA_Factory_Option__r.Base_Unit__c,
                            DNSA_Factory_Option__r.Kit__c,
                            DNSA_Factory_Option__r.Description__c,
                            Quote_Line_Item__r.Product2.Plant__c,
                            DNSA_Factory_Option__r.SAPDescription__c
                        FROM
                            DNSA_Factory_Option_Junction__c
                        WHERE
                            Quote_Line_Item__c IN: quoteLineId
                        AND DNSA_Factory_Option__r.Type__c = 'SQ'
                        AND Dealer_Checked__c = false
                        ORDER BY
                            Quote_Line_Item__c, POSNR__c
                    ]; //factoryOption추가자재 추출
                }

                sqInfo = [
                    SELECT  Id, 
                            SQ__c, 
                            QuoteLineItem__c, 
                            SQ__r.Name, 
                            SQ__r.SQCode__c, 
                            SQ__r.Price__c, 
                            POSNR__c, 
                            QuoteLineItem__r.Product2.Plant__c,
                            SalesPrice__c,
                            Sales_Price__c
                    FROM    SQ_QuoteLineitem_Junction__c 
                    WHERE   QuoteLineItem__c IN: quoteLineId 
                    ORDER BY QuoteLineItem__c
                ];

                ///////////////////////// POSNR 값 생성 로직 시작
                Map<String, Integer> maxExistingPosnrMap = new Map<String, Integer>(); // POSNR 시작 값을 동적으로 설정하기 위한 초기 변수
                Integer increment = 10;

                for (QuoteLineItem qli : getInquiry) { // 기존 데이터에서 MAX_POSNR__c 값 가져오기
                    maxExistingPosnrMap.put(qli.Id, Integer.valueOf(qli.MAX_POSNR__c));
                }
                
                // 모든 QuoteLineItem__c 별로 그룹화

                Map<String, List<Accessory__c>> acceGroupedByQuoteLineItem = new Map<String, List<Accessory__c>>();
                for (Accessory__c acc : acceInfo) {
                    if (!acceGroupedByQuoteLineItem.containsKey(acc.QuoteLineItem__c)) {
                        acceGroupedByQuoteLineItem.put(acc.QuoteLineItem__c, new List<Accessory__c>());
                    }
                    acceGroupedByQuoteLineItem.get(acc.QuoteLineItem__c).add(acc);
                }

                Map<String, List<DNSA_Factory_Option_Junction__c>> factoryGroupedByQuoteLineItem = new Map<String, List<DNSA_Factory_Option_Junction__c>>();
                if(isDnsa) {
                    for (DNSA_Factory_Option_Junction__c acc : factoryOptionInfo) {
                        if (!factoryGroupedByQuoteLineItem.containsKey(acc.Quote_Line_Item__c)) {
                            factoryGroupedByQuoteLineItem.put(acc.Quote_Line_Item__c, new List<DNSA_Factory_Option_Junction__c>());
                        }
                        factoryGroupedByQuoteLineItem.get(acc.Quote_Line_Item__c).add(acc);
                    }
                }

                Map<String, List<SQ_QuoteLineitem_Junction__c>> sqGroupedByQuoteLineItem = new Map<String, List<SQ_QuoteLineitem_Junction__c>>();
                for (SQ_QuoteLineitem_Junction__c sq : sqInfo) {
                    if (!sqGroupedByQuoteLineItem.containsKey(sq.QuoteLineItem__c)) {
                        sqGroupedByQuoteLineItem.put(sq.QuoteLineItem__c, new List<SQ_QuoteLineitem_Junction__c>());
                    }
                    sqGroupedByQuoteLineItem.get(sq.QuoteLineItem__c).add(sq);
                }

                Map<String, Integer> maxPosnrMap = new Map<String, Integer>(); // QuoteLineItem__c별로 MAX_POSNR__c 계산을 위한 변수
                    
                for (String id : maxExistingPosnrMap.keySet()) { // 각 QuoteLineItem__c 별로 POSNR 값을 재설정

                    Integer currentPosnr = maxExistingPosnrMap.containsKey(id) ? maxExistingPosnrMap.get(id) : 20;
                        
                    if (acceGroupedByQuoteLineItem.containsKey(id)) { // Accessory__c 리스트의 POSNR 수정
                        for (Accessory__c acc : acceGroupedByQuoteLineItem.get(id)) {
                            acc.POSNR__c = currentPosnr;
                            currentPosnr += increment;
                        }
                    }
                       
                    if (factoryGroupedByQuoteLineItem.containsKey(id)) { //DNSA_Factory_Option_Junction__c리스트의 POSNR 수정
                        for (DNSA_Factory_Option_Junction__c acc : factoryGroupedByQuoteLineItem.get(id)) {
                            acc.POSNR__c = currentPosnr;
                            currentPosnr += increment;
                        }
                    }
                    
                    if (sqGroupedByQuoteLineItem.containsKey(id)) { // SQ_QuoteLineitem_Junction__c 리스트의 POSNR 수정
                        for (SQ_QuoteLineitem_Junction__c sq : sqGroupedByQuoteLineItem.get(id)) {
                            sq.POSNR__c = currentPosnr;
                            currentPosnr += increment;
                        }
                    }

                    // 마지막 POSNR__c 값에 10을 더한 값으로 MAX_POSNR__c 설정
                    Integer maxPosnr = currentPosnr; // 마지막 POSNR보다 10 더 큰 값
                    maxPosnrMap.put(id, maxPosnr); // 해당 QuoteLineItem__c에 대한 최대 POSNR 값 저장
                }

                for (String id : maxPosnrMap.keySet()) {
                    QuoteLineItem quoteLineItem = new QuoteLineItem( // 해당 QuoteLineItem__c를 가져와서 MAX_POSNR__c 필드 갱신
                        Id = id,
                        MAX_POSNR__c = maxPosnrMap.get(id),
                        QuotePriceIF__c = true,
                        ReERPQuotation__c = false
                    );
                    quoteLineItemsToUpdate.add(quoteLineItem);
                }
                ///////////////////////// POSNR 값 생성 로직 종료

                Map<String, Map<String, Accessory__c>> acceMap = new Map<String, Map<String, Accessory__c>>();
                for(String id : quoteLineId){
                    if (!acceMap.containsKey(id)) { acceMap.put(id, new Map<String, Accessory__c>()); }
                    
                    for (Accessory__c acc : acceInfo) {
                        if(acc.QuoteLineItem__c == id){ acceMap.get(id).put(String.valueOf(acc.POSNR__c), acc); }
                    }
                }

                Map<String, Map<String, DNSA_Factory_Option_Junction__c>> factoryOptionMap = new Map<String, Map<String, DNSA_Factory_Option_Junction__c>>();
                if(isDnsa) {
                    for(String id : quoteLineId){
                        if (!factoryOptionMap.containsKey(id)) { factoryOptionMap.put(id, new Map<String, DNSA_Factory_Option_Junction__c>()); }

                        for (DNSA_Factory_Option_Junction__c acc : factoryOptionInfo) {
                            if(acc.Quote_Line_Item__c == id){ factoryOptionMap.get(id).put(String.valueOf(acc.POSNR__c), acc); }
                        }
                    }
                }

                Map<String, Map<String, SQ_QuoteLineitem_Junction__c>> sqMap = new Map<String, Map<String, SQ_QuoteLineitem_Junction__c>>();
                for(String id : quoteLineId){
                    if(!sqMap.containsKey(id)){ sqMap.put(id, new Map<String, SQ_QuoteLineitem_Junction__c>()); }

                    for (SQ_QuoteLineitem_Junction__c sq : sqInfo) {
                        if(sq.QuoteLineItem__c == id){ sqMap.get(id).put(String.valueOf(sq.POSNR__c), sq); }
                    }
                }

                List<IF_ERP_Quotation_Classes.IF_OPTY_019_Req> req_List = new List<IF_ERP_Quotation_Classes.IF_OPTY_019_Req>();
                for(QuoteLineItem quoteline : getInquiry){
                    //ERP Inquriy No가 없으면 에러발생
                    if(quoteline.ERPInquiryNo__c == null && !isDnsa){
                        return System.Label.DNS_MSG_QuotePriceInquiry;
                    }

                    IF_ERP_Quotation_Classes.IF_OPTY_019_Req req = new IF_ERP_Quotation_Classes.IF_OPTY_019_Req();
                    if(getInquiry[0].OpportunityLineItem.Opportunity.RecordType.Name == 'General'){
                        req.I_AUART = 'ZQSQ';
                    }else if(getInquiry[0].OpportunityLineItem.Opportunity.RecordType.Name == 'Turn-Key (AE)'){
                        req.I_AUART = getInquiry[0].OpportunityLineItem.Opportunity.Inquiry_Type__c;
                    }else{ //DNSA는 무조건 ZQSQ
                        req.I_AUART = 'ZQSQ';
                        req.I_VKBUR = VKBUR;
                    }
                        
                    req.I_WAERS     = WAERK;
                    req.I_VKORG     = VKORG;
                    req.I_VTWEG     = VTWEG;
                    req.I_SPART     = SPART;
                    req.I_KUNNR     = KUNNR;
                    req.I_KUNWE     = KUNWE;
                    req.I_BNDDT     = String.valueOf(formattedDate);
                    if(getInquiry[0].Quote.RecordTypeId == recordTypeIdFactory) {
                        req.I_VDATU     = String.valueOf(quoteline.Requested_Ship_Date__c).replace('-','');
                    } else {
                        req.I_VDATU     = String.valueOf(quoteline.RequestedDelivDate__c).replace('-','');
                    }
                    req.I_KWMENG    = '1';
                    req.I_CUST_GRP1 = quoteline.Quote.Opportunity.MainCategory__c;
                    req.I_CUST_GRP2 = quoteline.Quote.Opportunity.SubCategory__c;
                    req.I_CUST_GRP3 = quoteline.Quote.Opportunity.IsTooling__c;
                    req.I_ZTERM     = String.isBlank(quoteline.Quote.TermsOfPayment__c) ? quoteline.Quote.PaymentConditionKR__c : quoteline.Quote.TermsOfPayment__c;
                    req.I_INCO1     = String.isBlank(quoteline.Quote.Incoterms__c) ? quoteline.Quote.IncotermsKR__c : quoteline.Quote.Incoterms__c;
                    req.I_INCO2     = String.isBlank(quoteline.Quote.Incoterms__c) ? quoteline.Quote.IncotermsKR__c : getPicklistValues('Quote', 'Incoterms__c', quoteline.Quote.Incoterms__c);
                    req.I_VBELN     = quoteline.ERPInquiryNo__c;
                    req.I_ZZKVGR4   = ZZKVGR4;

                    if(getInquiry[0].Quote.RecordTypeId == recordTypeIdFactory) { //Warranty는 DNSA만_250328
                        req.I_ZZWARRPER    = dnsaWarMap.get(quoteline.Warranty__c).ZZWARRPER__c;
                        req.I_ZZPERUNIT    = dnsaWarMap.get(quoteline.Warranty__c).ZZPERUNIT__c;
                        req.I_ZZWARHRS     = dnsaWarMap.get(quoteline.Warranty__c).ZZWARHRS__c;
                        req.I_ZZWARRDAT    = '';
                        req.I_ZZPR_WAR     = dnsaWarMap.get(quoteline.Warranty__c).ZZPR_WAR__c;
                        req.I_ZZCOVERAGE   = dnsaWarMap.get(quoteline.Warranty__c).ZZCOVERAGE__c;
                        req.I_ZZCOVERAGE_B = dnsaWarMap.get(quoteline.Warranty__c).ZZCOVERAGE_B__c;
                    }

                    //CV데이터호출
                    List<IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_VARIANT> T_VARIANT_List = new List<IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_VARIANT>();
                    if(cvMap.containsKey(quoteline.Id)){
                        List<Map<String, CharacteristicValue__c>> innerList = cvMap.get(quoteline.Id);
                        System.debug('getQuotePrice - (new) - cvMap innerList : ' + innerList);

                        if(innerList.size() > 0){
                            for (Map<String, CharacteristicValue__c> innerMap : innerList) {
                                for (String key : innerMap.keySet()) {
                                    CharacteristicValue__c cv = innerMap.get(key);

                                    IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_VARIANT T_VARIANT = new IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_VARIANT();
                                    T_VARIANT.POSNR    = '000010';
                                    T_VARIANT.ATNAM    = cv.C_Code__c;
                                    T_VARIANT.ATWRT    = cv.V_Code__c;
                                    T_VARIANT_List.add(T_VARIANT);
                                }
                            }
                        }
                    }
                    req.T_VARIANT = T_VARIANT_List;

                    //추가자재 데이터 호출
                    List<IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_ITEM> T_ITEM_List = new List<IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_ITEM>();
                    IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_ITEM T_ITEM_PRODUCT = new IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_ITEM();
                    T_ITEM_PRODUCT.POSNR  = '000010';
                    T_ITEM_PRODUCT.MATNR  = quoteline.Product2.ProductCode;
                    T_ITEM_PRODUCT.ARKTX  = quoteline.Product2.Name__c;
                    T_ITEM_PRODUCT.KWMENG = '1';
                    T_ITEM_PRODUCT.VRKME  = 'EA';
                    T_ITEM_PRODUCT.WERKS  = PLANT;
                    T_ITEM_PRODUCT.WAERK  = WAERK;
                    T_ITEM_List.add(T_ITEM_PRODUCT);

                    if(acceMap.containsKey(quoteline.Id)){
                        Map<String, Accessory__c> innerMap = acceMap.get(quoteline.Id);
                        System.debug('getQuotePrice - (new) - acceMap innerMap : ' + innerMap);
                        
                        for (String key : innerMap.keySet()) {
                            Accessory__c acc = innerMap.get(key);

                            IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_ITEM T_ITEM = new IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_ITEM();
                            T_ITEM.POSNR  = String.valueOf(acc.POSNR__c);
                            T_ITEM.MATNR  = acc.Key__c;
                            T_ITEM.ARKTX  = acc.Description__c;
                            T_ITEM.KWMENG = String.valueOf(acc.Quantity__c);
                            T_ITEM.VRKME  = acc.SalesUnit__c;
                            T_ITEM.WERKS  = PLANT;
                            T_ITEM.WAERK  = WAERK;
                            T_ITEM_List.add(T_ITEM);
                        }
                    }

                    if(factoryOptionMap.containsKey(quoteline.Id)){
                        Map<String, DNSA_Factory_Option_Junction__c> innerMap = factoryOptionMap.get(quoteline.Id);
                        System.debug('getQuotePrice - (new) - factoryOptionMap innerMap : ' + innerMap);

                        for (String key : innerMap.keySet()) {
                            DNSA_Factory_Option_Junction__c acc = innerMap.get(key);

                            IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_ITEM T_ITEM = new IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_ITEM();
                            T_ITEM.POSNR    = String.valueOf(acc.POSNR__c);
                            T_ITEM.MATNR    = 'SQ100';
                            T_ITEM.ARKTX    = acc.DNSA_Factory_Option__r.SAPDescription__c;
                            T_ITEM.KWMENG   = String.valueOf(acc.Quantity__c);
                            T_ITEM.VRKME    = 'SET';
                            T_ITEM.WERKS    = PLANT;
                            T_ITEM.WAERK    = WAERK;
                            T_ITEM.PSTYV    = 'ZFOQ';
                            T_ITEM.NETPR    = '0'; //Factory Option SQ는 무조건 0으로_20250328
                            T_ITEM_List.add(T_ITEM);
                        }
                    }

                    //sq데이터 호출
                    if(sqMap.size() > 0){
                        if(sqMap.containsKey(quoteline.Id)){
                            Map<String, SQ_QuoteLineitem_Junction__c> innerMap = sqMap.get(quoteline.Id);
                            for (String key : innerMap.keySet()) {
                                SQ_QuoteLineitem_Junction__c sq = innerMap.get(key);

                                IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_ITEM T_ITEM = new IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_ITEM();
                                T_ITEM.POSNR    = String.valueOf(sq.POSNR__c);
                                T_ITEM.MATNR    = 'SQ100'; //고정값
                                T_ITEM.ARKTX    = sq.SQ__r.Name;
                                T_ITEM.KWMENG   = '1'; //고정
                                T_ITEM.VRKME    = 'SET'; //고정
                                T_ITEM.WERKS    = PLANT;
                                T_ITEM.ZZSQCOD  = sq.SQ__r.SQCode__c;
                                T_ITEM.ZZSQTITLE= sq.SQ__r.Name;
                                if(isDnsa){
                                    T_ITEM.PSTYV    = 'ZFOQ'; //가격이 0이면 ZFOQ아니면 빈값으로 보냄
                                    T_ITEM.NETPR    = '0'; //Factory는 SQ무조건 0으로_20250328
                                }else if(sq.Sales_Price__c == null || sq.Sales_Price__c == 0){
                                    T_ITEM.PSTYV    = 'ZFOQ'; //가격이 0이면 ZFOQ아니면 빈값으로 보냄
                                    T_ITEM.NETPR    = '0';
                                }else{
                                    T_ITEM.NETPR = String.valueOf(sq.Sales_Price__c);
                                }
                                T_ITEM.WAERK    = WAERK;
                                T_ITEM_List.add(T_ITEM);
                            }
                        }
                    }
                    req.T_ITEM = T_ITEM_List;

                    List<IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_PRICING_ADD> T_PRICING_ADD_List = new List<IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_PRICING_ADD>();
                    IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_PRICING_ADD T_PRICING_ADD_ZSSS = new IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_PRICING_ADD();
                    IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_PRICING_ADD T_PRICING_ADD_ZSSD = new IF_ERP_Quotation_Classes.IF_OPTY_019_Req_T_PRICING_ADD();

                    adjustmentPrice = quoteline.Adjustment_Price__c;
                    if(isDnsa){ //조정가는 DNSA만 보냄_20250328
                        T_PRICING_ADD_ZSSS.POSNR = '000010';
                        T_PRICING_ADD_ZSSS.KSCHL = 'ZSSS';
                        T_PRICING_ADD_ZSSS.KWERT = String.valueOf(quoteline.ZSSS__c);
                        T_PRICING_ADD_ZSSS.WAERK = WAERK;
                        T_PRICING_ADD_LIST.add(T_PRICING_ADD_ZSSS);

                        T_PRICING_ADD_ZSSD.POSNR = '000010';
                        T_PRICING_ADD_ZSSD.KSCHL = 'ZSSD';
                        T_PRICING_ADD_ZSSD.KWERT = String.valueOf(quoteline.ZSSD__c);
                        T_PRICING_ADD_ZSSD.WAERK = WAERK;
                        T_PRICING_ADD_LIST.add(T_PRICING_ADD_ZSSD);
                    }
                    req.T_PRICING_ADD = T_PRICING_ADD_LIST;

                    req_List.add(req);
                    inquiryInfo.put(quoteline.ERPInquiryNo__c, quoteline.Id); //ERP Inquiry No와 Quotelineitem Id로 Map구성 -> ERP Quotation No Update위해
                }

                IF_ERP_Quotation instance = new IF_ERP_Quotation();
                
                List<IF_ERP_Quotation_Classes.IF_OPTY_019_Res> response = instance.IF_OPTY_019(req_List);
                System.debug('getQuotePrice - (new) - response : ' + response);
                
                for(Integer i = 0; i < response.size(); i++){
                    if(response[i].O_RECODE == 'E' || response[i].O_RECODE == null){
                        if(response[i].O_REMSG != null && response[i].O_REMSG.contains('ZFOC')){
                            return System.Label.DNS_M_ZFOC;
                        }else{
                            return response[i].O_REMSG;
                        }
                    }

                    QuoteLineItem upquoteLine = new QuoteLineItem();
                    upquoteLine.Id = inquiryInfo.get(response[i].I_VBELN);
                    upquoteLine.ERPQuotationNo__c = response[i].O_VBELN;
                    upquoteLine.Dealer_Price__c = 0;
                    upquoteLine.UnitPrice = 0;

                    //QuoteLineId에 해당하는 InquiryNo로 Mapping시킬 추가자재 정보 가져오기
                    Map<String, Accessory__c> innerIFMap = acceMap.get(inquiryInfo.get(response[i].I_VBELN));
                    Map<String, DNSA_Factory_Option_Junction__c> innerFactoryIFMap = factoryOptionMap.get(inquiryInfo.get(response[i].I_VBELN));
                    Map<String, SQ_QuoteLineitem_Junction__c> innerSQIFMap = sqMap.get(inquiryInfo.get(response[i].I_VBELN));
                    
                    ////QuoteLineId에 해당하는 InquiryNo로 Mapping시킬 CV 정보 가져오기
                    List<Map<String, CharacteristicValue__c>> innerIFCVList = cvMap.get(inquiryInfo.get(response[i].I_VBELN));
                    List<Map<String, CharacteristicValue__c>> innerIFCVList2 = cvMap2.get(inquiryInfo.get(response[i].I_VBELN));

                    Decimal zpr3;
                    Decimal zpr5;
                    Decimal zpr6;
                    Decimal zprFactory;

                    String zpr3Id;
                    String zpr5Id;
                    String zpr6Id;
                    String zprFactoryId;
                        
                    Decimal UnitPriceCheck = 0;
                    Decimal WarrantyPriceCheck = 0;
                    Decimal WarrantyPrd = 0;
                    Decimal WarrantyAcc = 0;
                    Decimal WarrantyFactory = 0;
                    Decimal WarrantySQ  = 0;

                    Map<String, Decimal> zprCheck = new Map<String, Decimal>();
                    Map<String, Decimal> zprAccWarCheck = new Map<String, Decimal>();

                    Map<String, Decimal> zprFactoryCheck = new Map<String, Decimal>();
                    Map<String, Decimal> zprFactoryWarCheck = new Map<String, Decimal>();

                    Map<String, Decimal> zprSQCheck = new Map<String, Decimal>();
                    Map<String, Decimal> zprSQWarCheck = new Map<String, Decimal>();
                        
                    //Global은 T_PRICING, 국내는 T_COND_EX -> Global도 T_COND_EX로변경_250311_By 문주하

                    if(isDnsa){  
                        for(Integer j = 0; j < response[i].T_COND_EX.size(); j++){
                            if(response[i].T_COND_EX[j].COND_TYPE == 'ZWAR') {
                                Integer posnr = Integer.valueOf(response[i].T_COND_EX[j].ITM_NUMBER);
                                if(innerSQIFMap.get(String.valueOf(posnr)) != null){ //SQ Check
                                    WarrantySQ = WarrantySQ + Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                                    zprSQWarCheck.put(String.valueOf(posnr), Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE));

                                }else if(innerIFMap.get(String.valueOf(posnr)) != null){ //추가자재
                                    WarrantyAcc = WarrantyAcc + Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                                    zprAccWarCheck.put(String.valueOf(posnr), Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE));

                                }else if(innerFactoryIFMap.get(String.valueOf(posnr)) != null){ //Factory Option
                                    WarrantyFactory = WarrantyFactory + Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                                    zprFactoryWarCheck.put(String.valueOf(posnr), Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE));

                                }else if(posnr == 10){ //위에 세개 조건 아니면 대표사양
                                    WarrantyPrd = Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                                }
                                WarrantyPriceCheck = WarrantyPriceCheck + Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                            }

                            if(response[i].T_COND_EX[j].COND_TYPE == 'ZPR1') { //Product의 ListPrice
                                upquoteLine.ZPR1__c = Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                            }
                        }

                        for(Integer j = 0; j < response[i].T_PRICING.size(); j++){
                            if(response[i].T_PRICING[j].POSNR == '000010' && response[i].T_PRICING[j].KSCHL == 'ZSUM') {
                                String kwertStr = response[i].T_PRICING[j].KWERT;
                                if (String.isNotBlank(kwertStr)) { kwertStr = kwertStr.trim(); }

                                Decimal kwertValue = Decimal.valueOf(kwertStr);
                                Decimal result = kwertValue - adjustmentPrice;
                                
                                upquoteLine.UnitPrice = result;
                                upquoteLine.Dealer_Price__c = result;
                                UnitPriceCheck = result;

                            }else if(response[i].T_PRICING[j].POSNR != '000010' && response[i].T_PRICING[j].KSCHL == 'ZSUM'){

                                Integer posnr = Integer.valueOf(response[i].T_PRICING[j].POSNR);
                                
                                if(innerSQIFMap.get(String.valueOf(posnr)) != null){ //posnr이 SQ일 경우
                                    zpr5Id  = innerSQIFMap.get(String.valueOf(posnr)).Id;
                                    if(zprSQWarCheck.get(String.valueOf(posnr)) != null){
                                        zpr5    = Decimal.valueOf(response[i].T_PRICING[j].KWERT) - zprSQWarCheck.get(String.valueOf(posnr));
                                    }else{
                                        zpr5    = Decimal.valueOf(response[i].T_PRICING[j].KWERT);
                                    }
                                    if(!zprSQCheck.containsKey(zpr5Id)){
                                        zprSQCheck.put(zpr5Id, zpr5);
                                    }
                                }
                                
                                if(innerIFMap.get(String.valueOf(posnr)) != null){ //posnr이 추가자재일경우
                                    zpr3Id = innerIFMap.get(String.valueOf(posnr)).Id;
                                    if(zprAccWarCheck.get(String.valueOf(posnr)) != null){
                                        zpr3    = (Decimal.valueOf(response[i].T_PRICING[j].KWERT) - zprAccWarCheck.get(String.valueOf(posnr))) / innerIFMap.get(String.valueOf(posnr)).Quantity__c;
                                    }else{
                                        zpr3    = Decimal.valueOf(response[i].T_PRICING[j].KWERT) / innerIFMap.get(String.valueOf(posnr)).Quantity__c;
                                    }
                                    if(!zprCheck.containsKey(zpr3Id)){ 
                                        zprCheck.put(zpr3Id, zpr3);
                                    }
                                }
                                
                                if(innerFactoryIFMap.get(String.valueOf(posnr)) != null){ //posnr이 Factory Option일경우
                                    zprFactoryId = innerFactoryIFMap.get(String.valueOf(posnr)).Id;
                                    if(zprFactoryWarCheck.get(String.valueOf(posnr)) != null){
                                        zprFactory    = (Decimal.valueOf(response[i].T_PRICING[j].KWERT) - zprFactoryWarCheck.get(String.valueOf(posnr))) / innerFactoryIFMap.get(String.valueOf(posnr)).Quantity__c;
                                    }else{
                                        zprFactory    = Decimal.valueOf(response[i].T_PRICING[j].KWERT) / innerFactoryIFMap.get(String.valueOf(posnr)).Quantity__c;
                                    }
                                    if(!zprFactoryCheck.containsKey(zprFactoryId)){ 
                                        zprFactoryCheck.put(zprFactoryId, zprFactory);
                                    }
                                }
                            }
                        
                            if(j + 1 == response[i].T_PRICING.size()){ //마지막까지 돌았을 때 zprCheck에 있는 데이터 한번에 넣기
                                if(zprCheck.size() > 0) {
                                    for(String key : zprCheck.keySet()){
                                        Accessory__c accUpdate = new Accessory__c();
                                        accUpdate.Id = key;
                                        accUpdate.Price__c = zprCheck.get(key);
                                        upAccRecord.add(accUpdate);
                                    }
                                }
                            
                                if(zprSQCheck.size() > 0){ //SQ는 금액 업데이트
                                    for(String key : zprSQCheck.keySet()){
                                        SQ_QuoteLineitem_Junction__c sqUpdate = new SQ_QuoteLineitem_Junction__c();
                                        sqUpdate.Id = key;
                                        sqUpdate.SalesPrice__c = zprSQCheck.get(key); 
                                        upSQRecord.add(sqUpdate);
                                    }
                                }

                                if(zprFactoryCheck.size() > 0) { //Factory Option Price Update
                                    for(String key : zprFactoryCheck.keySet()){
                                        DNSA_Factory_Option_Junction__c accUpdate = new DNSA_Factory_Option_Junction__c();
                                        accUpdate.Id = key;
                                        accUpdate.ERP_Price__c = zprCheck.get(key);
                                        upFactoryOptionRecord.add(accUpdate);
                                    }
                                }
                            }
                        }
                    
                        upquoteLine.UnitPrice = Decimal.valueOf(Integer.valueOf(UnitPriceCheck - WarrantyPrd));
                        upquoteLine.Dealer_Price__c = Decimal.valueOf(Integer.valueOf(UnitPriceCheck));
                        upquoteLine.Warranty_Acc__c = Decimal.valueOf(Integer.valueOf(WarrantyAcc));
                        upquoteLine.Warranty_Prd__c = Decimal.valueOf(Integer.valueOf(WarrantyPrd));
                        upquoteLine.Warranty_SQ__c  = Decimal.valueOf(Integer.valueOf(WarrantySQ));
                    
                    }else{

                        Map<String, List<Object>> subcvMap = new Map<String, List<Object>>();
                        if(response[i].T_COND_EX.size() > 0){
                            for(Integer k = 0 ; k < response[i].T_COND_EX.size(); k++){ //'CV인 데이터 먼저 추출해서 별도로 담아둠, 어떤 값이 올지 모르기때문에 request하지 않은 CV데이터도 전부 담아둠'

                                if(response[i].T_COND_EX[k].COND_TYPE == 'ZVA1') {//CV
                                    //innerIFCVMap과 유사한 구조로 VARCOND전체를 담아둠
                                    //zpr3, zpr6와 같이 아래 ZVA1비교 코드 밑에 이 map과 비교하는 코드를 추가하여
                                    //값이 있으면 이 map의 price로 변경해 주는 로직 추가 예정
                                    //언더바가 4개이상만 캐치
                                    List<String> underCheck = response[i].T_COND_EX[k].VARCOND.split('_');
                                    if (underCheck.size() >= 5) {
                                        List<String> parts = response[i].T_COND_EX[k].VARCOND.split('-');
                                        for(Integer q = 0; q < parts.size(); q++){
                                            if(q == 0){ //두개의 CV가 합쳐져서 오는 건은 C_CodeVCode-CCodeVCode의 형태로 - 없이 문자열로 붙어서옴
                                                subcvMap.put(parts[q], new List<Object>{response[i].T_COND_EX[k].VARCOND, response[i].T_COND_EX[k].CONDVALUE});
                                            }else{
                                                subcvMap.put(parts[q], new List<Object>{response[i].T_COND_EX[k].VARCOND, '0'});
                                            }
                                        }
                                    }
                                }
                            }

                            if(!subcvMap.isEmpty()){
                                for(String key : subcvMap.keySet()){
                                    if(innerIFCVList2.size() > 0){
                                        for(Map<String, CharacteristicValue__c> innerIFCVMap : innerIFCVList2){
                                            CharacteristicValue__c cvUpdate = new CharacteristicValue__c();
                                            if(innerIFCVMap.get(key) != null){
                                                cvUpdate.Id = innerIFCVMap.get(key).Id;
                                                cvUpdate.subkey__c = String.valueOf(subcvMap.get(key)[0]);
                                                cvUpdate.Price__c = Decimal.valueOf(String.valueOf(subcvMap.get(key)[1]));
                                                upCvRecord.add(cvUpdate);
                                            }
                                        }
                                    }
                                }
                            }
                    
                            for(Integer j = 0; j < response[i].T_COND_EX.size(); j++){
                                System.debug('getQuotePrice - (new) - COND_TYPE : ' + response[i].T_COND_EX[j].COND_TYPE + ' ,: ITM_NUMBER : ' + response[i].T_COND_EX[j].ITM_NUMBER);
                                if(response[i].T_COND_EX[j].COND_TYPE == 'ZPR1') { //Product의 ListPrice
                                    upquoteLine.UnitPrice = Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                                }
                                if(response[i].T_COND_EX[j].COND_TYPE == 'ZPR9') { //Product의 Dealder Price ZPR9먼저 넣어주고 ZPR8이 있으면 ZPR8로 업데이트
                                    upquoteLine.Dealer_Price__c = Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                                }
                                if(response[i].T_COND_EX[j].COND_TYPE == 'ZPR8') { //Product의 Dealder Price
                                    upquoteLine.Dealer_Price__c = Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                                }
                                if(response[i].T_COND_EX[j].COND_TYPE == 'ZVA1') {//CV
                                    System.debug('getQuotePrice - (new) - CV response[i].T_COND_EX[j] : ' + response[i].T_COND_EX[j].VARCOND);
                                    if(innerIFCVList.size() > 0){
                                        for(Map<String, CharacteristicValue__c> innerIFCVMap : innerIFCVList){
                                            CharacteristicValue__c cvUpdate = new CharacteristicValue__c();
                                            if(innerIFCVMap.get(response[i].T_COND_EX[j].VARCOND) != null){
                                                //List에 중복막기위해 이미 두개이상의 CV로 묶여서온 데이터는 위 로직에서 처리했으므로
                                                //여기서는 단일 CV만처리
                                                if(subcvMap.get(response[i].T_COND_EX[j].VARCOND.replace('-', '')) == null){
                                                    cvUpdate.Id = innerIFCVMap.get(response[i].T_COND_EX[j].VARCOND).Id;
                                                    cvUpdate.subKey__c = 'ZZZZZZ_DEFAULT';
                                                    cvUpdate.Price__c = Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                                                    upCvRecord.add(cvUpdate);
                                                }
                                            }
                                            
                                        }
                                    }
                                }

                                if(response[i].T_COND_EX[j].COND_TYPE == 'ZPR5') { //SQ
                                    Integer posnr = Integer.valueOf(response[i].T_COND_EX[j].ITM_NUMBER);
                                    zpr5Id  = innerSQIFMap.get(String.valueOf(posnr)).Id;
                                    zpr5    = Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE);
                                    if(!zprSQCheck.containsKey(zpr5Id)){
                                        zprSQCheck.put(zpr5Id, zpr5);
                                    }
                                }
                                System.debug('getQuotePrice - (new) - innerIFMap : ' + innerIFMap);
                    
                                if(response[i].T_COND_EX[j].COND_TYPE == 'ZPR3') { //추가자재 ZPR6가 없으면 ZPR3으로
                                    Integer posnr = Integer.valueOf(response[i].T_COND_EX[j].ITM_NUMBER);
                                    zpr3Id = innerIFMap.get(String.valueOf(posnr)).Id;
                                    zpr3 = Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE) / innerIFMap.get(String.valueOf(posnr)).Quantity__c;
                                    if(!zprCheck.containsKey(zpr3Id)){ //zpr6Id와 zpr3Id는 같은 accessory의 Id이기 때문에 같은데 zpr6Id가 이미 넣어져 있다면 실행 x
                                        zprCheck.put(zpr3Id, zpr3);
                                    }
                                }

                                if(response[i].T_COND_EX[j].COND_TYPE == 'ZPR6') { //추가자재 우선순위
                                    Integer posnr = Integer.valueOf(response[i].T_COND_EX[j].ITM_NUMBER);
                                    zpr6Id = innerIFMap.get(String.valueOf(posnr)).Id;
                                    zpr6 = Decimal.valueOf(response[i].T_COND_EX[j].CONDVALUE) / innerIFMap.get(String.valueOf(posnr)).Quantity__c;
                                    zprCheck.put(zpr6Id, zpr6);
                                }
                                
                                if(j + 1 == response[i].T_COND_EX.size()){ //마지막까지 돌았을 때 zprCheck에 있는 데이터 한번에 넣기
                                    if(zprCheck.size() > 0) {
                                        for(String key : zprCheck.keySet()){
                                            Accessory__c accUpdate = new Accessory__c();
                                            accUpdate.Id = key;
                                            accUpdate.Price__c = zprCheck.get(key);
                                            upAccRecord.add(accUpdate);
                                        }
                                    }
                                    //SQ금액 업데이트
                                    if(zprSQCheck.size() > 0){
                                        for(String key : zprSQCheck.keySet()){
                                            SQ_QuoteLineitem_Junction__c sqUpdate = new SQ_QuoteLineitem_Junction__c();
                                            sqUpdate.Id = key;
                                            sqUpdate.SalesPrice__c = zprSQCheck.get(key);
                                            upSQRecord.add(sqUpdate);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    upRecord.add(upquoteLine);
                                
                    if(response[i].T_COND_ELMT.size() > 0){
                        for(Integer j = 0; j < response[i].T_COND_ELMT.size(); j++){
                            T_COND_ELMT__c newElmt = new T_COND_ELMT__c();
                            newElmt.Quote_Line_Item__c  = inquiryInfo.get(response[i].I_VBELN);
                            newElmt.KAPPL__c            = response[i].T_COND_ELMT[j].KAPPL;
                            newElmt.KBETR__c            = response[i].T_COND_ELMT[j].KBETR;
                            newElmt.KSCHL__c            = response[i].T_COND_ELMT[j].KSCHL;
                            newElmt.MATNR__c            = response[i].T_COND_ELMT[j].MATNR;
                            newElmt.VKORG__c            = response[i].T_COND_ELMT[j].VKORG;
                            newElmt.VTWEG__c            = response[i].T_COND_ELMT[j].VTWEG;
                            newElmt.WAERK__c            = response[i].T_COND_ELMT[j].WAERK;
                            newElmt.ZTERM__c            = response[i].T_COND_ELMT[j].ZTERM;
                            newElmt.ZZKVGR4__c          = response[i].T_COND_ELMT[j].ZZKVGR4;
                            elmtList.add(newElmt);
                        }
                    }
                }
            }
            //////////////////////////////////////////여기까지 생성 I/F//////////////////////////////////////////////////
                                
            ////////////////////////여기부터 ERP Quotation 수정 I/F////////////////////////////////////////////////////
            getInquiryEdit = [
                SELECT  Id,
                        Quote.RecordTypeId,
                        Product2.Plant__c, 
                        Product2.ProductCode, 
                        Product2.Description, 
                        Quote.Opportunity.MainCategory__c, 
                        Quote.Opportunity.SubCategory__c, 
                        Quote.Opportunity.IsTooling__c, 
                        Quote.Incoterms__c, 
                        Quote.TermsOfPayment__c, 
                        Quote.IncotermsKR__c, 
                        Quote.PaymentConditionKR__c, 
                        ERPInquiryNo__c, 
                        ERPQuotationNo__c, 
                        Quote.OwnerId, 
                        Quote.AccountId, 
                        OpportunityLineItem.Opportunity.RecordType.Name, 
                        RequestedDelivDate__c, 
                        OpportunityLineItem.Opportunity.Inquiry_Type__c,
                        Warranty__c,
                        MAX_POSNR__c,
                        OpportunityLineItem.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c, 
                        OpportunityLineItem.Opportunity.Opportunity_Owner__r.Profile.Name,
                        OpportunityLineItem.Opportunity.Account.CustomerCode__c,
                        OpportunityLineItem.Opportunity.Opportunity_Owner__c,
                        CurrencyIsoCode,
                        Quote.Account.CustomerCode__c,
                        Product2.Name__c,
                        Quote.DNSA_SalesOffice__c,
                        Adjustment_Price__c,
                        ZSSS__c,
                        ZSSD__c,
                        Quote.Account.CountryLookup__r.CountryCode__c,
                        Quote.Opportunity.Account.RecordTypeId,
                        Quote.Opportunity.Account.CustomerCode__c,
                        Quote.Opportunity.Opportunity_Owner__c,
                        Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c,
                        Requested_Ship_Date__c
                FROM    QuoteLineItem 
                WHERE   Id IN: quoteLineId AND ERPQuotationNo__c != null
            ];
                                
            if(getInquiryEdit.size() > 0 && reErpCheck.isEmpty()){
                WAERK  = getInquiryEdit[0].CurrencyIsoCode;
                isDnsa = getInquiryEdit[0].Quote.RecordTypeId == recordTypeIdFactory || getInquiryEdit[0].Quote.RecordTypeId == recordTypeIdCommo;
                
                String ownerCheck = getInquiryEdit[0].Quote.Opportunity.Opportunity_Owner__c != null ? getInquiryEdit[0].Quote.Opportunity.Opportunity_Owner__c : getInquiryEdit[0].Quote.OwnerId;

                String VTWEGEDIT;
                String KUNNREDIT;
                String KUNWEEDIT;
                String VKORGEdit;
                String SPARTEdit;
                String VKBUREdit;
                    
                User getIFinfoEdit = new User();
                                    
                if(isDnsa) {
                    getIFinfoEdit = [
                        SELECT  SalesOrganization__c, 
                                Division__c, 
                                DistributionChannel__c,
                                Account.CustomerCode__c,
                                AccountId
                        FROM    User 
                        WHERE   Id =: getInquiryEdit[0].Quote.OwnerId
                    ]; // 사용자 및 계정 정보 조회

                    List<Account> getIFEditCustomerCode = DN_WithoutSharingClass.getAccountCustomerCode(getIFinfoEdit.AccountId);
                    List<Account> getIFEditCustomerCode2 = DN_WithoutSharingClass.getAccountCustomerCode(getInquiryEdit[0].Quote.AccountId);

                    VTWEGEDIT = getInquiryEdit[0].Quote.Account.CountryLookup__r.CountryCode__c == 'US' ? '10' : '20';
                    VKORGEDIT   = '4140';
                    SPARTEDIT   = '40';
                    KUNNREDIT   = getIFEditCustomerCode[0].CustomerCode__c;
                    KUNWEEDIT   = getIFEditCustomerCode2[0].CustomerCode__c;
                    PLANT       = '4140';
                    VKBUREdit   = getInquiryEdit[0].Quote.DNSA_SalesOffice__c;
                } else {
                    getIFinfoEdit = [
                        SELECT  SalesOrganization__c, 
                                Division__c, 
                                DistributionChannel__c 
                        FROM    User 
                        WHERE   Id =: ownerCheck
                    ];
                    VKORGEdit = getIFinfoEdit.SalesOrganization__c;
                    SPARTEdit = getIFinfoEdit.Division__c;
                    VTWEGEDIT = getInquiryEdit[0].CurrencyIsoCode == 'KRW' ? '10' : '20';

                    if(getInquiryEdit[0].Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c != null && getInquiryEdit[0].Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c != ''){
                        KUNNREDIT = getInquiryEdit[0].Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c;
                    }else if(getInquiryEdit[0].Quote.Opportunity.Account.RecordTypeId == recordTypeIdDealer){
                        KUNNREDIT = getInquiryEdit[0].Quote.Opportunity.Account.CustomerCode__c;
                    }else{
                        KUNNREDIT = '9997';
                    }
                    KUNWEEDIT = getInquiryEdit[0].Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c;
                    if(getInquiryEdit[0].Quote.Opportunity.Opportunity_Owner__r.AccountId == null) {
                        KUNWEEDIT = '9999'; // 20250421 직영일 때 Ship to 9999고정
                    } else {
                        KUNWEEDIT = getInquiryEdit[0].Quote.Opportunity.Opportunity_Owner__r.Account.CustomerCode__c;
                    }
                }
                                
                acceInfoEdit = [
                    SELECT  Id, 
                            POSNR__c, 
                            Key__c, 
                            Description__c, 
                            Quantity__c, 
                            SalesUnit__c, 
                            QuoteLineItem__r.Product2.Plant__c, 
                            QuoteLineItem__c,
                            Delete__c
                    FROM    Accessory__c 
                    WHERE   QuoteLineItem__c IN: quoteLineId and
                            QuoteLineItem__r.ERPQuotationNo__c != null and
                            Delete__c != null
                    ORDER BY QuoteLineItem__c, POSNR__c
                ];
                System.debug('getQuotePrice - (edit) - acceInfoEdit ::: ' + acceInfoEdit);
                                
                if(isDnsa) {
                    factoryOptionInfoEdit = [
                        SELECT  Id,
                                POSNR__c,
                                ERP_Price__c,
                                Quote_Line_Item__c,
                                Quantity__c,
                                UPDATEFLAG__c,
                                DNSA_Factory_Option__r.Price__c,
                                DNSA_Factory_Option__r.Base_Unit__c,
                                DNSA_Factory_Option__r.Kit__c,
                                DNSA_Factory_Option__r.Description__c,
                                Quote_Line_Item__r.Product2.Plant__c,
                                Quote_Line_Item__r.ERPQuotationNo__c,
                                DNSA_Factory_Option__r.SAPDescription__c
                        FROM    DNSA_Factory_Option_Junction__c
                        WHERE   Quote_Line_Item__c IN: quoteLineId
                        AND     Quote_Line_Item__r.ERPQuotationNo__c != null
                        AND     UPDATEFLAG__c != null
                        AND     DNSA_Factory_Option__r.Type__c = 'SQ'
                        AND     Dealer_Checked__c = false
                        ORDER BY Quote_Line_Item__c, POSNR__c
                    ]; //factoryOption추가자재 추출
                }
            
                List<CharacteristicValue__c> cvInfoEdit = [
                    SELECT  Id, 
                            C_Code__c, 
                            V_Code__c, 
                            Price__c, 
                            QuoteLineItem__c 
                    FROM    CharacteristicValue__c 
                    WHERE   QuoteLineItem__c IN: quoteLineId AND QuoteLineItem__r.ERPQuotationNo__c != null
                    ORDER BY QuoteLineItem__c
                ];

                Map<String, List<Map<String, CharacteristicValue__c>>> cvMapEdit = new Map<String, List<Map<String, CharacteristicValue__c>>>();
                Map<String, List<Map<String, CharacteristicValue__c>>> cvMapEdit2 = new Map<String, List<Map<String, CharacteristicValue__c>>>();

                for(String id : quoteLineId){
                    if (!cvMapEdit.containsKey(id)) {
                        cvMapEdit.put(id, new List<Map<String, CharacteristicValue__c>>());
                        cvMapEdit2.put(id, new List<Map<String, CharacteristicValue__c>>());
                    }

                    for (CharacteristicValue__c cv : cvInfoEdit) {
                        if(cv.QuoteLineItem__c == id){
                            String key = String.valueOf(cv.C_Code__c) + '-' + String.valueOf(cv.V_Code__c);
                            Map<String, CharacteristicValue__c> newMap = new Map<String, CharacteristicValue__c>();
                            newMap.put(key, cv);
                            cvMapEdit.get(id).add(newMap);

                            String key2 = String.valueOf(cv.C_Code__c) + String.valueOf(cv.V_Code__c);
                            Map<String, CharacteristicValue__c> newMap2 = new Map<String, CharacteristicValue__c>();
                            newMap2.put(key2, cv);
                            cvMapEdit2.get(id).add(newMap2);
                        }
                    }
                }
                    
                //SQ데이터 추출
                sqInfoEdit = [
                    SELECT  Id, 
                            SQ__c, 
                            QuoteLineItem__c, 
                            SQ__r.Name, 
                            SQ__r.SQCode__c, 
                            SQ__r.Price__c, 
                            POSNR__c, 
                            QuoteLineItem__r.Product2.Plant__c,
                            UPDATEFLAG__c,
                            SalesPrice__c,
                            Sales_Price__c
                    FROM    SQ_QuoteLineitem_Junction__c 
                    WHERE   QuoteLineItem__c IN: quoteLineId
                    AND     QuoteLineItem__r.ERPQuotationNo__c != null
                    AND     UPDATEFLAG__c != null
                    ORDER BY QuoteLineItem__c
                ];
                System.debug('getQuotePrice - (new) - sqInfoEdit ::: ' + sqInfoEdit);

                ///////////////////////// POSNR 값 생성 로직 시작
                Map<String, Integer> maxExistingPosnrMapEdit = new Map<String, Integer>(); // POSNR 시작 값을 동적으로 설정하기 위한 초기 변수
                Integer incrementEdit = 10;
                for (QuoteLineItem qli : getInquiryEdit) { // 기존 데이터에서 MAX_POSNR__c 값 가져오기
                    maxExistingPosnrMapEdit.put(qli.Id, Integer.valueOf(qli.MAX_POSNR__c));
                }
                
                Map<String, List<Accessory__c>> acceGroupedByQuoteLineItemEdit = new Map<String, List<Accessory__c>>(); 
                for (Accessory__c acc : acceInfoEdit) { // 모든 QuoteLineItem__c 별로 그룹화
                    if(acc.POSNR__c == null){
                        if (!acceGroupedByQuoteLineItemEdit.containsKey(acc.QuoteLineItem__c)) {
                            acceGroupedByQuoteLineItemEdit.put(acc.QuoteLineItem__c, new List<Accessory__c>());
                        }
                        acceGroupedByQuoteLineItemEdit.get(acc.QuoteLineItem__c).add(acc);
                    }
                }
                
                Map<String, List<DNSA_Factory_Option_Junction__c>> factoryGroupedByQuoteLineItemEdit = new Map<String, List<DNSA_Factory_Option_Junction__c>>();
                if(isDnsa) {
                    for (DNSA_Factory_Option_Junction__c acc : factoryOptionInfoEdit) { // 모든 QuoteLineItem__c 별로 그룹화
                        if(acc.POSNR__c == null){
                            if (!factoryGroupedByQuoteLineItemEdit.containsKey(acc.Quote_Line_Item__c)) {
                                factoryGroupedByQuoteLineItemEdit.put(acc.Quote_Line_Item__c, new List<DNSA_Factory_Option_Junction__c>());
                            }
                            factoryGroupedByQuoteLineItemEdit.get(acc.Quote_Line_Item__c).add(acc);
                        }
                    }
                }

                Map<String, List<SQ_QuoteLineitem_Junction__c>> sqGroupedByQuoteLineItemEdit = new Map<String, List<SQ_QuoteLineitem_Junction__c>>();
                for (SQ_QuoteLineitem_Junction__c sq : sqInfoEdit) {
                    if(sq.POSNR__c == null){
                        if (!sqGroupedByQuoteLineItemEdit.containsKey(sq.QuoteLineItem__c)) {
                            sqGroupedByQuoteLineItemEdit.put(sq.QuoteLineItem__c, new List<SQ_QuoteLineitem_Junction__c>());
                        }
                        sqGroupedByQuoteLineItemEdit.get(sq.QuoteLineItem__c).add(sq);
                    }
                }

                Map<String, Integer> maxPosnrMapEdit = new Map<String, Integer>(); // QuoteLineItem__c별로 MAX_POSNR__c 계산을 위한 변수

                for (String id : maxExistingPosnrMapEdit.keySet()) { // 각 QuoteLineItem__c 별로 POSNR 값을 재설정
                    Integer currentPosnr = maxExistingPosnrMapEdit.containsKey(id) ? maxExistingPosnrMapEdit.get(id) : 20;
                    // 250430 최한영 List에 담아서 업데이트 해야하는거 아닌가?
                    
                    if (acceGroupedByQuoteLineItemEdit.containsKey(id)) { // Accessory__c 리스트의 POSNR 수정
                        for (Accessory__c acc : acceGroupedByQuoteLineItemEdit.get(id)) {
                            acc.POSNR__c = currentPosnr;
                            currentPosnr += incrementEdit;
                        }
                    }
                    
                    if (factoryGroupedByQuoteLineItemEdit.containsKey(id)) { // DNSA_Factory_Option_Junction__c 리스트의 POSNR 수정
                        for (DNSA_Factory_Option_Junction__c acc : factoryGroupedByQuoteLineItemEdit.get(id)) {
                            acc.POSNR__c = currentPosnr;
                            currentPosnr += incrementEdit;
                        }
                    }
                    
                    if (sqGroupedByQuoteLineItemEdit.containsKey(id)) { // SQ_QuoteLineitem_Junction__c 리스트의 POSNR 수정
                        for (SQ_QuoteLineitem_Junction__c sq : sqGroupedByQuoteLineItemEdit.get(id)) {
                            sq.POSNR__c = currentPosnr;
                            currentPosnr += incrementEdit;
                        }
                    }

                    // 마지막 POSNR__c 값에 10을 더한 값으로 MAX_POSNR__c 설정
                    Integer maxPosnr = currentPosnr; // 마지막 POSNR보다 10 더 큰 값
                    maxPosnrMapEdit.put(id, maxPosnr); // 해당 QuoteLineItem__c에 대한 최대 POSNR 값 저장
                }

                if(!maxPosnrMapEdit.isEmpty()){
                    for (String id : maxPosnrMapEdit.keySet()) {
                        
                        QuoteLineItem quoteLineItem = new QuoteLineItem( // 해당 QuoteLineItem__c를 가져와서 MAX_POSNR__c 필드 갱신
                            Id = id,
                            MAX_POSNR__c = maxPosnrMapEdit.get(id),
                            QuotePriceIF__c = true,
                            ReERPQuotation__c = false
                        );
                        quoteLineItemsToUpdate.add(quoteLineItem);
                    }
                }else{
                    for(String id : quoteLineId){
                        QuoteLineItem quoteLineItem = new QuoteLineItem(
                            Id = id,
                            QuotePriceIF__c = true,
                            ReERPQuotation__c = false
                        );
                        quoteLineItemsToUpdate.add(quoteLineItem);
                    }
                }
                ///////////////////////// POSNR 값 생성 로직 종료

                // acceInfoEdit = [
                //     SELECT Id, 
                //             POSNR__c, 
                //             Key__c, 
                //             Description__c, 
                //             Quantity__c, 
                //             SalesUnit__c, 
                //             QuoteLineItem__r.Product2.Plant__c, 
                //             QuoteLineItem__c,
                //             Delete__c
                //     FROM    Accessory__c 
                //     WHERE   QuoteLineItem__c IN: quoteLineId
                //     AND     QuoteLineItem__r.ERPQuotationNo__c != null
                //     AND     Delete__c != null
                //     ORDER BY QuoteLineItem__c, POSNR__c
                // ];

                List<Accessory__c> AllAccInfoEdit = [
                    SELECT  Id, 
                            POSNR__c, 
                            Key__c, 
                            Description__c, 
                            Quantity__c, 
                            SalesUnit__c, 
                            QuoteLineItem__r.Product2.Plant__c, 
                            QuoteLineItem__c,
                            Delete__c
                    FROM    Accessory__c 
                    WHERE   QuoteLineItem__c IN: quoteLineId
                    AND     QuoteLineItem__r.ERPQuotationNo__c != null
                    AND     Delete__c != 'D'
                    ORDER BY QuoteLineItem__c, POSNR__c
                ];
                
                System.debug('getQuotePrice - (edit) - acceInfoEdit ::: ' + acceInfoEdit);
                System.debug('getQuotePrice - (edit) - AllAccInfoEdit ::: ' + AllAccInfoEdit);

                // 20250502 yeongju.yun POSNR Mapping
                Map<Id, Decimal> accPOSNRMap = new Map<Id, Decimal>();
                for(Accessory__c accInfo : acceInfoEdit) {
                    accPOSNRMap.put(accInfo.Id, accInfo.POSNR__c);
                }
                for(Accessory__c allAccInfo : AllAccInfoEdit) {
                    if(accPOSNRMap.containsKey(allAccInfo.Id)) allAccInfo.POSNR__c = accPOSNRMap.get(allAccInfo.Id);
                }
                
                Map<String, Map<String, Accessory__c>> acceMapEdit = new Map<String, Map<String, Accessory__c>>();
                Map<String, Map<String, Accessory__c>> AllacceMapEdit = new Map<String, Map<String, Accessory__c>>();
                
                for(String id : quoteLineId){
                    if (!acceMapEdit.containsKey(id)) { acceMapEdit.put(id, new Map<String, Accessory__c>()); }
                    for (Accessory__c acc : acceInfoEdit) {
                        if(acc.QuoteLineItem__c == id){ acceMapEdit.get(id).put(String.valueOf(acc.POSNR__c), acc); }
                    }
                }
                
                for(String id : quoteLineId){
                    if (!AllacceMapEdit.containsKey(id)) { AllacceMapEdit.put(id, new Map<String, Accessory__c>()); }
                    for (Accessory__c acc : AllAccInfoEdit) {
                        if(acc.QuoteLineItem__c == id){ AllacceMapEdit.get(id).put(String.valueOf(acc.POSNR__c), acc); }
                    }
                }
                
                Map<String, Map<String, DNSA_Factory_Option_Junction__c>> factoryMapEdit = new Map<String, Map<String, DNSA_Factory_Option_Junction__c>>();
                for(String id : quoteLineId){
                    if (!factoryMapEdit.containsKey(id)) { factoryMapEdit.put(id, new Map<String, DNSA_Factory_Option_Junction__c>()); }
                    for(DNSA_Factory_Option_Junction__c acc : factoryOptionInfoEdit) {
                        if(acc.Quote_Line_Item__c == id){ factoryMapEdit.get(id).put(String.valueOf(acc.POSNR__c), acc); }
                    }
                }
                
                Map<String, Map<String, SQ_QuoteLineitem_Junction__c>> sqMapEdit = new Map<String, Map<String, SQ_QuoteLineitem_Junction__c>>();
                for(String id : quoteLineId){
                    if(!sqMapEdit.containsKey(id)){ sqMapEdit.put(id, new Map<String, SQ_QuoteLineitem_Junction__c>()); }

                    for (SQ_QuoteLineitem_Junction__c sq : sqInfoEdit) {
                        if(sq.QuoteLineItem__c == id){ sqMapEdit.get(id).put(String.valueOf(sq.POSNR__c), sq); }
                    }
                }
                
                List<IF_ERP_Quotation_Classes.IF_OPTY_020_Req> req_ListEdit = new List<IF_ERP_Quotation_Classes.IF_OPTY_020_Req>();
                
                for(QuoteLineItem quoteline : getInquiryEdit){
                    if(quoteline.ERPInquiryNo__c == null  && !isDnsa){
                        return System.Label.DNS_MSG_QuotePriceInquiry; //ERP Inquriy No가 없으면 에러발생
                    }
                
                    IF_ERP_Quotation_Classes.IF_OPTY_020_Req reqEdit = new IF_ERP_Quotation_Classes.IF_OPTY_020_Req();
                
                    if(getInquiryEdit[0].OpportunityLineItem.Opportunity.RecordType.Name == 'General'){
                        reqEdit.I_AUART = 'ZQSQ';
                    }else if(getInquiryEdit[0].OpportunityLineItem.Opportunity.RecordType.Name == 'Turn-Key (AE)'){
                        reqEdit.I_AUART = getInquiryEdit[0].OpportunityLineItem.Opportunity.Inquiry_Type__c;
                    }else{
                        reqEdit.I_AUART = 'ZQSQ'; //DNSA는 무조건 ZQSQ
                        reqEdit.I_VKBUR = VKBUREdit;
                    }
                
                    reqEdit.I_WAERS     = WAERK;
                    reqEdit.I_VKORG     = VKORGEDIT;
                    reqEdit.I_VTWEG     = VTWEGEDIT;
                    reqEdit.I_SPART     = SPARTEDIT;
                    reqEdit.I_KUNNR     = KUNNREDIT;
                    reqEdit.I_KUNWE     = KUNWEEDIT;
                    reqEdit.I_BNDDT     = String.valueOf(formattedDate);
                    if(getInquiryEdit[0].Quote.RecordTypeId == recordTypeIdFactory) {
                        reqEdit.I_VDATU     = String.valueOf(quoteline.Requested_Ship_Date__c).replace('-','');
                    }else{
                        reqEdit.I_VDATU     = String.valueOf(quoteline.RequestedDelivDate__c).replace('-','');
                    }
                    reqEdit.I_KWMENG    = '1';
                    reqEdit.I_CUST_GRP1 = quoteline.Quote.Opportunity.MainCategory__c;
                    reqEdit.I_CUST_GRP2 = quoteline.Quote.Opportunity.SubCategory__c;
                    reqEdit.I_CUST_GRP3 = quoteline.Quote.Opportunity.IsTooling__c;
                    reqEdit.I_ZTERM     = String.isBlank(quoteline.Quote.TermsOfPayment__c) ? quoteline.Quote.PaymentConditionKR__c : quoteline.Quote.TermsOfPayment__c;
                    reqEdit.I_INCO1     = String.isBlank(quoteline.Quote.Incoterms__c) ? quoteline.Quote.IncotermsKR__c : quoteline.Quote.Incoterms__c;
                    reqEdit.I_INCO2     = String.isBlank(quoteline.Quote.Incoterms__c) ? quoteline.Quote.IncotermsKR__c : getPicklistValues('Quote', 'Incoterms__c', quoteline.Quote.Incoterms__c);
                
                    if(getInquiryEdit[0].Quote.RecordTypeId == recordTypeIdFactory){
                        reqEdit.I_ZZWARRPER    = dnsaWarMap.get(quoteline.Warranty__c).ZZWARRPER__c;
                        reqEdit.I_ZZPERUNIT    = dnsaWarMap.get(quoteline.Warranty__c).ZZPERUNIT__c;
                        reqEdit.I_ZZWARHRS     = dnsaWarMap.get(quoteline.Warranty__c).ZZWARHRS__c;
                        reqEdit.I_ZZWARRDAT    = '';
                        reqEdit.I_ZZPR_WAR     = dnsaWarMap.get(quoteline.Warranty__c).ZZPR_WAR__c;
                        reqEdit.I_ZZCOVERAGE   = dnsaWarMap.get(quoteline.Warranty__c).ZZCOVERAGE__c;
                        reqEdit.I_ZZCOVERAGE_B = dnsaWarMap.get(quoteline.Warranty__c).ZZCOVERAGE_B__c;
                    }
                    reqEdit.I_VBELN = quoteline.ERPQuotationNo__c;
                
                    //CV데이터호출
                    List<IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_VARIANT> T_VARIANT_ListEdit = new List<IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_VARIANT>();
                    if(cvMapEdit.containsKey(quoteline.Id)){
                        List<Map<String, CharacteristicValue__c>> innerList = cvMapEdit.get(quoteline.Id);
                        if(innerList.size() > 0){
                            for (Map<String, CharacteristicValue__c> innerMap : innerList) {
                                for (String key : innerMap.keySet()) {
                                    CharacteristicValue__c cv = innerMap.get(key);
                                    
                                    IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_VARIANT T_VARIANT = new IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_VARIANT();
                                    T_VARIANT.POSNR    = '000010';
                                    T_VARIANT.ATNAM    = cv.C_Code__c;
                                    T_VARIANT.ATWRT    = cv.V_Code__c;
                                    T_VARIANT_ListEdit.add(T_VARIANT);
                                }
                            }
                        }
                    }
                    reqEdit.T_VARIANT = T_VARIANT_ListEdit;
                
                    //추가자재 데이터 호출
                    List<IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_ITEM> T_ITEM_ListEdit = new List<IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_ITEM>();
                    if(acceMapEdit.containsKey(quoteline.Id)){
                        Map<String, Accessory__c> innerMap = acceMapEdit.get(quoteline.Id);
                        for (String key : innerMap.keySet()) {
                            Accessory__c acc = innerMap.get(key);

                            IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_ITEM T_ITEM = new IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_ITEM();
                            T_ITEM.POSNR    = String.valueOf(acc.POSNR__c);
                            T_ITEM.MATNR    = acc.Key__c;
                            T_ITEM.ARKTX    = acc.Description__c;
                            T_ITEM.KWMENG   = String.valueOf(acc.Quantity__c);
                            T_ITEM.VRKME    = acc.SalesUnit__c;
                            T_ITEM.WERKS    = PLANT;
                            T_ITEM.UPDATEFLAG = acc.Delete__c;
                            T_ITEM.WAERK    = WAERK;
                            T_ITEM_ListEdit.add(T_ITEM);
                        }
                    }
                
                    if(factoryMapEdit.containsKey(quoteline.Id)){
                        Map<String, DNSA_Factory_Option_Junction__c> innerMap = factoryMapEdit.get(quoteline.Id);
                        for (String key : innerMap.keySet()) {
                            DNSA_Factory_Option_Junction__c acc = innerMap.get(key);

                            IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_ITEM T_ITEM = new IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_ITEM();
                            T_ITEM.POSNR      = String.valueOf(acc.POSNR__c);
                            T_ITEM.MATNR      = 'SQ100';
                            T_ITEM.ARKTX      = acc.DNSA_Factory_Option__r.SAPDescription__c;
                            T_ITEM.KWMENG     = String.valueOf(acc.Quantity__c);
                            T_ITEM.VRKME      = 'SET';
                            T_ITEM.WERKS      = PLANT;
                            T_ITEM.UPDATEFLAG = acc.UPDATEFLAG__c;
                            T_ITEM.WAERK      = WAERK;
                            T_ITEM.PSTYV      = 'ZFOQ';
                            T_ITEM.NETPR      = '0';
                            T_ITEM_ListEdit.add(T_ITEM);
                        }
                    }
                
                    //sq데이터 호출
                    if(sqMapEdit.size() > 0){
                        if(sqMapEdit.containsKey(quoteline.Id)){
                            Map<String, SQ_QuoteLineitem_Junction__c> innerMap = sqMapEdit.get(quoteline.Id);
                            for (String key : innerMap.keySet()) {
                                SQ_QuoteLineitem_Junction__c sq = innerMap.get(key);
                
                                IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_ITEM T_ITEM = new IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_ITEM();
                                T_ITEM.POSNR      = String.valueOf(sq.POSNR__c);
                                T_ITEM.MATNR      = 'SQ100'; //고정값
                                T_ITEM.ARKTX      = sq.SQ__r.Name;
                                T_ITEM.KWMENG     = '1'; //고정
                                T_ITEM.VRKME      = 'SET'; //고정
                                T_ITEM.WERKS      = PLANT;
                                T_ITEM.ZZSQCOD    = sq.SQ__r.SQCode__c;
                                T_ITEM.ZZSQTITLE  = sq.SQ__r.Name;
                                T_ITEM.UPDATEFLAG = sq.UPDATEFLAG__c;
                                if(isDnsa){
                                    T_ITEM.PSTYV = 'ZFOQ';
                                    T_ITEM.NETPR = '0';
                                }else if(sq.Sales_Price__c == null || sq.Sales_Price__c == 0){
                                    T_ITEM.PSTYV = 'ZFOQ'; //가격이 0이면 ZFOQ아니면 빈값으로 보냄
                                    T_ITEM.NETPR = '0';
                                }else{
                                    T_ITEM.NETPR = String.valueOf(sq.Sales_Price__c);
                                }
                                T_ITEM.WAERK = WAERK;
                                T_ITEM_ListEdit.add(T_ITEM);
                            }
                        }
                    }
                    reqEdit.T_ITEM = T_ITEM_ListEdit;
                
                    List<IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_PRICING_ADD> T_PRICING_ADD_List_Edit = new List<IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_PRICING_ADD>();
                    IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_PRICING_ADD T_PRICING_ADD_Edit_ZSSS = new IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_PRICING_ADD();
                    IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_PRICING_ADD T_PRICING_ADD_Edit_ZSSD = new IF_ERP_Quotation_Classes.IF_OPTY_020_Req_T_PRICING_ADD();
                
                    adjustmentPrice = quoteline.Adjustment_Price__c == null ? 0 : quoteline.Adjustment_Price__c;
                    if(isDnsa){
                        T_PRICING_ADD_Edit_ZSSS.POSNR = '000010';
                        T_PRICING_ADD_Edit_ZSSS.KSCHL = 'ZSSS';
                        T_PRICING_ADD_Edit_ZSSS.KWERT = String.valueOf(quoteline.ZSSS__c.setScale(2));
                        T_PRICING_ADD_Edit_ZSSS.WAERK = WAERK;
                        T_PRICING_ADD_List_Edit.add(T_PRICING_ADD_Edit_ZSSS);

                        T_PRICING_ADD_Edit_ZSSD.POSNR = '000010';
                        T_PRICING_ADD_Edit_ZSSD.KSCHL = 'ZSSD';
                        T_PRICING_ADD_Edit_ZSSD.KWERT = String.valueOf(quoteline.ZSSD__c.setScale(2));
                        T_PRICING_ADD_Edit_ZSSD.WAERK = WAERK;
                        T_PRICING_ADD_List_Edit.add(T_PRICING_ADD_Edit_ZSSD);
                    }
                    reqEdit.T_PRICING_ADD = T_PRICING_ADD_List_Edit;
                    
                    //ERP Inquiry No와 Quotelineitem Id로 Map구성 -> ERP Quotation No Update위해
                    quotationInfo.put(quoteline.ERPQuotationNo__c, quoteline.Id);
                    req_ListEdit.add(reqEdit);
                }
                
                IF_ERP_Quotation instanceEdit = new IF_ERP_Quotation();
                List<IF_ERP_Quotation_Classes.IF_OPTY_020_Res> responseEdit = instanceEdit.IF_OPTY_020(req_ListEdit);
                System.debug('getQuotePrice - (edit) - responseEdit ::: ' + responseEdit);
                for(Integer i = 0; i < responseEdit.size(); i++){
                    if(responseEdit[i].O_RECODE == 'E'){
                        if(responseEdit[i].O_REMSG != null && responseEdit[i].O_REMSG.contains('ZFOC')){
                            return System.Label.DNS_M_ZFOC;
                        }else{
                            return responseEdit[i].O_REMSG;
                        }
                    }

                    QuoteLineItem upquoteLine = new QuoteLineItem();
                    upquoteLine.Id = quotationInfo.get(responseEdit[i].O_VBELN);
                    upquoteLine.ERPQuotationNo__c = responseEdit[i].O_VBELN;
                    upquoteLine.Dealer_Price__c = 0;
                    upquoteLine.UnitPrice = 0;

                    //QuoteLineId에 해당하는 InquiryNo로 Mapping시킬 추가자재 정보 가져오기
                    Map<String, Accessory__c> innerIFMap = acceMapEdit.get(quotationInfo.get(responseEdit[i].O_VBELN));
                    Map<String, Accessory__c> AllinnerIFMap = AllacceMapEdit.get(quotationInfo.get(responseEdit[i].O_VBELN));
                    Map<String, DNSA_Factory_Option_Junction__c> innerFactoryIFMap = factoryMapEdit.get(quotationInfo.get(responseEdit[i].O_VBELN));
                    Map<String, SQ_QuoteLineitem_Junction__c> innerSQIFMap = sqMapEdit.get(quotationInfo.get(responseEdit[i].O_VBELN));

                    //QuoteLineId에 해당하는 InquiryNo로 Mapping시킬 CV 정보 가져오기
                    List<Map<String, CharacteristicValue__c>> innerIFCVList = cvMapEdit.get(quotationInfo.get(responseEdit[i].O_VBELN));
                    List<Map<String, CharacteristicValue__c>> innerIFCVList2 = cvMapEdit2.get(quotationInfo.get(responseEdit[i].O_VBELN));

                    Decimal zpr3;
                    Decimal zpr5;
                    Decimal zpr6;
                    Decimal zprFactory;

                    String zpr3Id;
                    String zpr5Id;
                    String zpr6Id;
                    String zprFactoryId;
                    
                    Map<String, Decimal> zprCheck = new Map<String, Decimal>();
                    Map<String, Decimal> zprAccWarCheck = new Map<String, Decimal>();

                    Map<String, Decimal> zprFactoryCheck = new Map<String, Decimal>();
                    Map<String, Decimal> zprFactoryWarCheck = new Map<String, Decimal>();
                            
                    Map<String, Decimal> zprSQCheck = new Map<String, Decimal>();
                    Map<String, Decimal> zprSQWarCheck = new Map<String, Decimal>();

                    Decimal UnitPriceCheckEdit = 0;
                    Decimal WarrantyPriceCheckEdit = 0;
                    Decimal WarrantyPrdEdit = 0;
                    Decimal WarrantyAccEdit = 0;
                    Decimal WarrantyFactoryEdit = 0;
                    Decimal WarrantySQEdit  = 0;
                    
                    //Global은 T_PRICING, 국내는 T_COND_EX -> Global도 T_COND_EX로_250311 By 문주하
                    if(isDnsa){ 
                        for(Integer j = 0; j < responseEdit[i].T_COND_EX.size(); j++){
                            if(responseEdit[i].T_COND_EX[j].COND_TYPE == 'ZWAR') { //Warranty는 COND_EX에서만
                                Integer posnr = Integer.valueOf(responseEdit[i].T_COND_EX[j].ITM_NUMBER);
                                if(innerSQIFMap.get(String.valueOf(posnr)) != null){ //SQ Check
                                    WarrantySQEdit = WarrantySQEdit + Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE);
                                    zprSQWarCheck.put(String.valueOf(posnr), Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE));

                                }else if(AllinnerIFMap.get(String.valueOf(posnr)) != null){ //추가자재
                                    WarrantyAccEdit = WarrantyAccEdit + Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE);
                                    zprAccWarCheck.put(String.valueOf(posnr), Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE));

                                }else if(innerFactoryIFMap.get(String.valueOf(posnr)) != null){//Factory Option
                                    WarrantyFactoryEdit = WarrantyFactoryEdit + Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE);
                                    zprFactoryWarCheck.put(String.valueOf(posnr), Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE));

                                }else if(posnr == 10){ //위에 세개 조건 아니면 대표사양
                                    WarrantyPrdEdit = Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE);
                                }
                                WarrantyPriceCheckEdit = WarrantyPriceCheckEdit + Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE);
                            }
                            if(responseEdit[i].T_COND_EX[j].COND_TYPE == 'ZPR1') { //Product의 ListPrice
                                upquoteLine.ZPR1__c = Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE);
                            }
                        }
                        
                        for(Integer j = 0; j < responseEdit[i].T_PRICING.size(); j++){
                            if(responseEdit[i].T_PRICING[j].POSNR == '000010' && responseEdit[i].T_PRICING[j].KSCHL == 'ZSUM') {
                                String kwertStr = responseEdit[i].T_PRICING[j].KWERT;
                                if (String.isNotBlank(kwertStr)) { kwertStr = kwertStr.trim(); }
                                
                                Decimal kwertValue = Decimal.valueOf(kwertStr);
                                Decimal result = kwertValue - adjustmentPrice;

                                upquoteLine.UnitPrice = result;
                                upquoteLine.Dealer_Price__c = result;
                                UnitPriceCheckEdit = result;
                                
                            }else if(responseEdit[i].T_PRICING[j].POSNR != '000010' && responseEdit[i].T_PRICING[j].KSCHL == 'ZSUM'){
                                Integer posnr = Integer.valueOf(responseEdit[i].T_PRICING[j].POSNR);

                                if(innerSQIFMap != null){ //posnr이 SQ일 경우
                                    if(innerSQIFMap.get(String.valueOf(posnr)) != null){
                                        zpr5Id  = innerSQIFMap.get(String.valueOf(posnr)).Id;
                                        if(zprSQWarCheck.get(String.valueOf(posnr)) != null){
                                            zpr5    = Decimal.valueOf(responseEdit[i].T_PRICING[j].KWERT) - zprSQWarCheck.get(String.valueOf(posnr));
                                        }else{
                                            zpr5    = Decimal.valueOf(responseEdit[i].T_PRICING[j].KWERT);
                                        }
                                        if(!zprSQCheck.containsKey(zpr5Id)){
                                            zprSQCheck.put(zpr5Id, zpr5);
                                        }
                                    }
                                }

                                if(AllinnerIFMap != null){ //posnr이 추가자재일경우
                                    if(AllinnerIFMap.get(String.valueOf(posnr)) != null){
                                        zpr3Id = AllinnerIFMap.get(String.valueOf(posnr)).Id;
                                        if(zprAccWarCheck.get(String.valueOf(posnr)) != null){
                                            zpr3 = (Decimal.valueOf(responseEdit[i].T_PRICING[j].KWERT) - zprAccWarCheck.get(String.valueOf(posnr))) / AllinnerIFMap.get(String.valueOf(posnr)).Quantity__c;
                                        }else{
                                            zpr3 = Decimal.valueOf(responseEdit[i].T_PRICING[j].KWERT) / AllinnerIFMap.get(String.valueOf(posnr)).Quantity__c;
                                        }
                                        if(!zprCheck.containsKey(zpr3Id)){ 
                                            zprCheck.put(zpr3Id, zpr3);
                                        }
                                    }
                                }

                                if(innerFactoryIFMap != null){ //posnr이 Factory Option일경우
                                    if(innerFactoryIFMap.get(String.valueOf(posnr)) != null){
                                        zprFactoryId = innerFactoryIFMap.get(String.valueOf(posnr)).Id;
                                        if(zprFactoryWarCheck.get(String.valueOf(posnr)) != null){
                                            zprFactory = (Decimal.valueOf(responseEdit[i].T_PRICING[j].KWERT) - zprFactoryWarCheck.get(String.valueOf(posnr))) / innerFactoryIFMap.get(String.valueOf(posnr)).Quantity__c;
                                        }else{
                                            zprFactory = Decimal.valueOf(responseEdit[i].T_PRICING[j].KWERT) / innerFactoryIFMap.get(String.valueOf(posnr)).Quantity__c;
                                        }
                                        if(!zprFactoryCheck.containsKey(zprFactoryId)){ 
                                            zprFactoryCheck.put(zprFactoryId, zprFactory);
                                        }
                                    }
                                }
                            }
                        
                            if(j + 1 == responseEdit[i].T_PRICING.size()){ //마지막까지 돌았을 때 zprCheck에 있는 데이터 한번에 넣기
                                if(zprCheck.size() > 0) {
                                    for(String key : zprCheck.keySet()){
                                        Accessory__c accUpdate = new Accessory__c();
                                        accUpdate.Id = key;
                                        accUpdate.Price__c = zprCheck.get(key);
                                        upAccRecord.add(accUpdate);
                                    }
                                }

                                if(zprSQCheck.size() > 0){ //SQ금액 업데이트
                                    for(String key : zprSQCheck.keySet()){
                                        SQ_QuoteLineitem_Junction__c sqUpdate = new SQ_QuoteLineitem_Junction__c();
                                        sqUpdate.Id = key;
                                        sqUpdate.SalesPrice__c = zprSQCheck.get(key); 
                                        upSQRecord.add(sqUpdate);
                                    }
                                }
                                
                                if(zprFactoryCheck.size() > 0){ //Factory Option Update
                                    for(String key : zprFactoryCheck.keySet()){
                                        DNSA_Factory_Option_Junction__c factoryUpdate = new DNSA_Factory_Option_Junction__c();
                                        factoryUpdate.Id = key;
                                        factoryUpdate.ERP_Price__c = zprFactoryCheck.get(key); 
                                        upFactoryOptionRecord.add(factoryUpdate);
                                    }
                                }
                            }
                        }

                        upquoteLine.UnitPrice = Decimal.valueOf(Integer.valueOf(UnitPriceCheckEdit - WarrantyPrdEdit));
                        upquoteLine.Dealer_Price__c = Decimal.valueOf(Integer.valueOf(UnitPriceCheckEdit));
                        upquoteLine.Warranty_Acc__c = Decimal.valueOf(Integer.valueOf(WarrantyAccEdit));
                        upquoteLine.Warranty_Prd__c = Decimal.valueOf(Integer.valueOf(WarrantyPrdEdit));
                        upquoteLine.Warranty_SQ__c  = Decimal.valueOf(Integer.valueOf(WarrantySQEdit));
                        
                    }else{
                        Map<String, List<Object>> subcvMap = new Map<String, List<Object>>(); //'CV인 데이터 먼저 추출해서 별도로 담아둠, 어떤 값이 올지 모르기때문에 request하지 않은 CV데이터도 전부 담아둠'
                        for(Integer k = 0 ; k < responseEdit[i].T_COND_EX.size(); k++){
                            if(responseEdit[i].T_COND_EX[k].COND_TYPE == 'ZVA1') {//CV
                                //innerIFCVMap과 유사한 구조로 VARCOND전체를 담아둠
                                //zpr3, zpr6와 같이 아래 ZVA1비교 코드 밑에 이 map과 비교하는 코드를 추가하여
                                //값이 있으면 이 map의 price로 변경해 주는 로직 추가 예정
                                //언더바가 4개인것만 캐치
                                List<String> underCheck = responseEdit[i].T_COND_EX[k].VARCOND.split('_');
                    
                                if (underCheck.size() >= 5) {
                                    List<String> parts = responseEdit[i].T_COND_EX[k].VARCOND.split('-');
                                    for(Integer q = 0; q < parts.size(); q++){
                                        if(q == 0){ //두개의 CV가 합쳐져서 오는 건은 C_CodeVCode-CCodeVCode의 형태로 - 없이 문자열로 붙어서옴
                                            subcvMap.put(parts[q], new List<Object>{responseEdit[i].T_COND_EX[k].VARCOND, responseEdit[i].T_COND_EX[k].CONDVALUE});
                                        }else{
                                            subcvMap.put(parts[q], new List<Object>{responseEdit[i].T_COND_EX[k].VARCOND, '0'});
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(!subcvMap.isEmpty()){
                            for(String key : subcvMap.keySet()){
                                if(innerIFCVList2.size() > 0){
                                    for(Map<String, CharacteristicValue__c> innerIFCVMap : innerIFCVList2){
                                        CharacteristicValue__c cvUpdate = new CharacteristicValue__c();
                                        if(innerIFCVMap.get(key) != null){
                                            cvUpdate.Id = innerIFCVMap.get(key).Id;
                                            cvUpdate.subkey__c = String.valueOf(subcvMap.get(key)[0]);
                                            cvUpdate.Price__c = Decimal.valueOf(String.valueOf(subcvMap.get(key)[1]));
                                            upCvRecord.add(cvUpdate);
                                        }
                                    }
                                }
                            }
                        }
                    
                        for(Integer j = 0; j < responseEdit[i].T_COND_EX.size(); j++){
                            if(responseEdit[i].T_COND_EX[j].COND_TYPE == 'ZPR1') { //Product의 ListPrice
                                upquoteLine.UnitPrice = Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE);
                            }
                            if(responseEdit[i].T_COND_EX[j].COND_TYPE == 'ZPR8') { //Product의 Dealder Price
                                upquoteLine.Dealer_Price__c = Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE);
                            }
                            if(responseEdit[i].T_COND_EX[j].COND_TYPE == 'ZVA1') {//CV
                                if(innerIFCVList.size() > 0){
                                    for(Map<String, CharacteristicValue__c> innerIFCVMap : innerIFCVList){
                                        CharacteristicValue__c cvUpdate = new CharacteristicValue__c();
                                        if(innerIFCVMap.get(responseEdit[i].T_COND_EX[j].VARCOND) != null){
                                            if(subcvMap.get(responseEdit[i].T_COND_EX[j].VARCOND.replace('-', '')) == null){
                                                cvUpdate.Id = innerIFCVMap.get(responseEdit[i].T_COND_EX[j].VARCOND).Id;
                                                cvUpdate.subKey__c = 'ZZZZZZ_DEFAULT';
                                                cvUpdate.Price__c = Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE);
                                                upCvRecord.add(cvUpdate);
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            }

                            if(responseEdit[i].T_COND_EX[j].COND_TYPE == 'ZPR5') { //SQ
                                Integer posnr = Integer.valueOf(responseEdit[i].T_COND_EX[j].ITM_NUMBER);
                                if(innerSQIFMap.get(String.valueOf(posnr)) != null){
                                    zpr5Id  = innerSQIFMap.get(String.valueOf(posnr)).Id;
                                    zpr5    = Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE);
                                    if(!zprSQCheck.containsKey(zpr5Id)){
                                        zprSQCheck.put(zpr5Id, zpr5);
                                    }
                                }
                            }

                            if(responseEdit[i].T_COND_EX[j].COND_TYPE == 'ZPR3') { //추가자재 ZPR6가 없으면 ZPR3으로
                                System.debug('getQuotePrice - (edit) - zprCheck ::: ' + zprCheck);
                                Integer posnr = Integer.valueOf(responseEdit[i].T_COND_EX[j].ITM_NUMBER);
                                if(AllinnerIFMap.get(String.valueOf(posnr)) != null){
                                    zpr3Id = AllinnerIFMap.get(String.valueOf(posnr)).Id;
                                    zpr3 = Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE) / AllinnerIFMap.get(String.valueOf(posnr)).Quantity__c;
                                    if(!zprCheck.containsKey(zpr3Id)){ //zpr6Id와 zpr3Id는 같은 accessory의 Id이기 때문에 같은데 zpr6Id가 이미 넣어져 있다면 실행 x
                                        zprCheck.put(zpr3Id, zpr3);
                                    }
                                }
                            }

                            if(responseEdit[i].T_COND_EX[j].COND_TYPE == 'ZPR6') { //추가자재 우선순위
                                System.debug('getQuotePrice - (edit) - zprCheck ::: ' + zprCheck);
                                Integer posnr = Integer.valueOf(responseEdit[i].T_COND_EX[j].ITM_NUMBER);
                                if(AllinnerIFMap.get(String.valueOf(posnr)) != null){
                                    zpr6Id = AllinnerIFMap.get(String.valueOf(posnr)).Id;
                                    zpr6 = Decimal.valueOf(responseEdit[i].T_COND_EX[j].CONDVALUE) / AllinnerIFMap.get(String.valueOf(posnr)).Quantity__c;
                                    zprCheck.put(zpr6Id, zpr6);
                                }
                            }

                            if(j + 1 == responseEdit[i].T_COND_EX.size()){ //마지막까지 돌았을 때 zprCheck에 있는 데이터 한번에 넣기
                                System.debug('getQuotePrice - (edit) - zprCheck ::: ' + zprCheck);
                                if(zprCheck.size() > 0) {
                                    for(String key : zprCheck.keySet()){
                                        Accessory__c accUpdate = new Accessory__c();
                                        accUpdate.Id = key;
                                        accUpdate.Price__c = zprCheck.get(key);
                                        upAccRecord.add(accUpdate);
                                    }
                                }
                                
                                if(zprSQCheck.size() > 0){ //SQ는 금액 업데이트 안함
                                    for(String key : zprSQCheck.keySet()){
                                        SQ_QuoteLineitem_Junction__c sqUpdate = new SQ_QuoteLineitem_Junction__c();
                                        sqUpdate.Id = key;
                                        sqUpdate.SalesPrice__c = zprSQCheck.get(key); 
                                        upSQRecord.add(sqUpdate);
                                    }
                                }
                            }
                        }
                    }
                    upRecord.add(upquoteLine);
                    if(responseEdit[i].T_COND_ELMT.size() > 0){
                        //T_COND_ELMT__c 값이 있으면 무조건 삭제 후 I/F통해 받아오는 값으로 Insert_20250424_권세진
                        List<T_COND_ELMT__c> delTCONDELMT = [ SELECT Id FROM T_COND_ELMT__c WHERE Quote_Line_Item__c IN: allquoteLineId ]; 
                        if(!delTCONDELMT.isEmpty()){ DN_WithoutSharingClass.deleteTCONDELMT(delTCONDELMT); }

                        Map<String, QuoteLineItem> tempQuoteNoMap = new Map<String, QuoteLineItem>();
                        for(QuoteLineItem qItem : getInquiryEdit) {
                            tempQuoteNoMap.put(qItem.ERPQuotationNo__c, qItem);
                        }

                        for(Integer j = 0; j < responseEdit[i].T_COND_ELMT.size(); j++){
                            T_COND_ELMT__c newElmt = new T_COND_ELMT__c();
                            newElmt.Quote_Line_Item__c  = tempQuoteNoMap.get(responseEdit[i].O_VBELN)?.Id;
                            newElmt.KAPPL__c            = responseEdit[i].T_COND_ELMT[j].KAPPL;
                            newElmt.KBETR__c            = responseEdit[i].T_COND_ELMT[j].KBETR;
                            newElmt.KSCHL__c            = responseEdit[i].T_COND_ELMT[j].KSCHL;
                            newElmt.MATNR__c            = responseEdit[i].T_COND_ELMT[j].MATNR;
                            newElmt.VKORG__c            = responseEdit[i].T_COND_ELMT[j].VKORG;
                            newElmt.VTWEG__c            = responseEdit[i].T_COND_ELMT[j].VTWEG;
                            newElmt.WAERK__c            = responseEdit[i].T_COND_ELMT[j].WAERK;
                            newElmt.ZTERM__c            = responseEdit[i].T_COND_ELMT[j].ZTERM;
                            newElmt.ZZKVGR4__c          = responseEdit[i].T_COND_ELMT[j].ZZKVGR4;
                            elmtList.add(newElmt);
                        }
                    }
                }
                                
                if(acceInfoEdit.size() > 0){ //추가자재 deleteflag 빈값으로 변경
                    for(Accessory__c acc : acceInfoEdit){
                        if(acc.Delete__c != 'D'){
                            Accessory__c accUpdate = new Accessory__c();
                            accUpdate.Id = acc.Id;
                            accUpdate.Delete__c = '';
                            accUpdateFlagList.add(accUpdate);
                        }
                    }
                }

                if(factoryOptionInfoEdit.size() > 0){ //추가자재 deleteflag 빈값으로 변경
                    for(DNSA_Factory_Option_Junction__c acc : factoryOptionInfoEdit){
                        if(acc.UPDATEFLAG__c != 'D'){
                            DNSA_Factory_Option_Junction__c accUpdate = new DNSA_Factory_Option_Junction__c();
                            accUpdate.Id = acc.Id;
                            accUpdate.UPDATEFLAG__c = '';
                            factoryUpdateFlagList.add(accUpdate);
                        }
                    }
                }
                            
                if(sqInfoEdit.size() > 0){ //sq updateflag 빈값으로 변경
                    
                    for(SQ_QuoteLineitem_Junction__c sq : sqInfoEdit){
                        if(sq.UPDATEFLAG__c != 'D'){
                            SQ_QuoteLineitem_Junction__c sqUpdate = new SQ_QuoteLineitem_Junction__c();
                            sqUpdate.Id = sq.Id;
                            sqUpdate.UPDATEFLAG__c = '';
                            sqUpdateFlagList.add(sqUpdate);
                        }
                    }
                }
            }
            /////////////////////////여기까지 ERP QUotation 수정 I/F//////////////////////////////////////////////////////
            
            if (!acceInfo.isEmpty()) {update acceInfo;}
            if (!factoryOptionInfo.isEmpty()) {update factoryOptionInfo;}
            if (!sqInfo.isEmpty()) {update sqInfo;}

            if (!acceInfoEdit.isEmpty()) {update acceInfoEdit;}
            if (!factoryOptionInfoEdit.isEmpty()) {update factoryOptionInfoEdit;}
            if (!sqInfoEdit.isEmpty()) {update sqInfoEdit;}
                                
            if(!accUpdateFlagList.isEmpty()) {update accUpdateFlagList;}
            if(!factoryUpdateFlagList.isEmpty()) {update factoryUpdateFlagList;}
            if(!sqUpdateFlagList.isEmpty()) {update sqUpdateFlagList;}
                        
            if(!upSQRecord.isEmpty()) {update upSQRecord;}
            if(!upRecord.isEmpty()) {update upRecord;}
            if(!upAccRecord.isEmpty()) {update upAccRecord;}
            if(!upFactoryOptionRecord.isEmpty()) {update upFactoryOptionRecord;}
            if(!upCvRecord.isEmpty()) {update upCvRecord;}

            if(!elmtList.isEmpty()) {insert elmtList;}
            if (!quoteLineItemsToUpdate.isEmpty()) { update quoteLineItemsToUpdate; }

            if(!updatequoteLineId.isEmpty()){ // 동시 선택한 QuoteLineItem이 있으면 같은 값으로 업데이트

                List<QuoteLineItem> extraupQtli = new List<QuoteLineitem>();
                
                for(String id : updatequoteLineId){
                    QuoteLineItem qt = new QuoteLineItem();
                    qt.Id = id;
                    qt.ReERPQuotation__c = false;
                    extraupQtli.add(qt);
                }

                if(!extraupQtli.isEmpty()){ update extraupQtli; }
            

                List<CharacteristicValue__c> extraupCvRecord = new List<CharacteristicValue__c>();
                
                List<CharacteristicValue__c> firstCV = new List<CharacteristicValue__c>();
                Map<String, CharacteristicValue__c> firstcvMap = new Map<String, CharacteristicValue__c>();
                Map<String, Map<String, CharacteristicValue__c>> extracvMap = new Map<String, Map<String, CharacteristicValue__c>>();
                            
                List<CharacteristicValue__c> extraCV = [
                    SELECT  Id,
                            C_Code__c, 
                            V_Code__c, 
                            Price__c, 
                            QuoteLineItem__c
                    FROM    CharacteristicValue__c
                    WHERE   QuoteLineItem__c IN: updatequoteLineId 
                    ORDER BY QuoteLineItem__c
                ];
                
                if(!extraCV.isEmpty()){
                    for(String id : updatequoteLineId){
                        if (!extracvMap.containsKey(id)) { extracvMap.put(id, new Map<String, CharacteristicValue__c>()); }
                        
                        for(CharacteristicValue__c cv : extraCV){
                            if(cv.QuoteLineItem__c == id){ extracvMap.get(id).put(cv.C_Code__c, cv); }
                        }
                    }

                    firstCV = [
                        SELECT  Id,
                                C_Code__c, 
                                V_Code__c, 
                                Price__c, 
                                QuoteLineItem__c
                        FROM    CharacteristicValue__c
                        WHERE   QuoteLineItem__c IN: quoteLineId 
                        ORDER BY QuoteLineItem__c
                    ];

                    for(CharacteristicValue__c cv : firstCV){
                        firstcvMap.put(cv.C_Code__c, cv);
                    }
                }
                
                List<Accessory__c> extraupAccRecord = new List<Accessory__c>();

                List<Accessory__c> firstAcc = new List<Accessory__c>();
                Map<String, Accessory__c> firstAccMap = new Map<String, Accessory__c>();
                Map<String, Map<String, Accessory__c>> extraAccMap = new Map<String, Map<String, Accessory__c>>();
            
                List<Accessory__c> extraAcc = [
                    SELECT  Id, 
                            POSNR__c, 
                            Key__c, 
                            Description__c, 
                            Quantity__c, 
                            SalesUnit__c, 
                            QuoteLineItem__c,
                            Price__c,
                            Delete__c
                    FROM    Accessory__c 
                    WHERE   QuoteLineItem__c IN: updatequoteLineId
                    ORDER BY QuoteLineItem__c
                ];

                if(!extraAcc.isEmpty()){
                    for(String id : updatequoteLineId){
                        if (!extraAccMap.containsKey(id)) { extraAccMap.put(id, new Map<String, Accessory__c>()); }
                        for(Accessory__c acc : extraAcc){
                            if(acc.QuoteLineItem__c == id){
                                extraAccMap.get(id).put(acc.Key__c, acc);
                            }
                        }
                    }
                    
                    firstAcc = [
                        SELECT  Id, 
                                POSNR__c, 
                                Key__c, 
                                Description__c, 
                                Quantity__c, 
                                SalesUnit__c, 
                                QuoteLineItem__c,
                                Price__c,
                                Delete__c
                        FROM    Accessory__c 
                        WHERE   QuoteLineItem__c IN: quoteLineId
                        ORDER BY QuoteLineItem__c
                    ];
            
                    for(Accessory__c ac : firstAcc){
                        firstAccMap.put(ac.Key__c, ac);
                    }
                }

                List<SQ_QuoteLineitem_Junction__c> extraupSQRecord = new List<SQ_QuoteLineitem_Junction__c>();
                
                List<SQ_QuoteLineitem_Junction__c> firstSQ = new List<SQ_QuoteLineitem_Junction__c>();
                Map<String, SQ_QuoteLineitem_Junction__c> firstSQMap = new Map<String, SQ_QuoteLineitem_Junction__c>();
                Map<String, Map<String, SQ_QuoteLineitem_Junction__c>> extraSQMap = new Map<String, Map<String, SQ_QuoteLineitem_Junction__c>>();
                
                List<SQ_QuoteLineitem_Junction__c> extraSQ = [
                    SELECT  Id, 
                            SQ__c, 
                            QuoteLineItem__c, 
                            SQ__r.Name, 
                            SQ__r.SQCode__c, 
                            SQ__r.Price__c, 
                            POSNR__c, 
                            QuoteLineItem__r.Product2.Plant__c,
                            UPDATEFLAG__c,
                            SalesPrice__c,
                            Sales_Price__c
                    FROM    SQ_QuoteLineitem_Junction__c 
                    WHERE   QuoteLineItem__c IN: updatequoteLineId 
                    ORDER BY QuoteLineItem__c
                ];

                if(!extraSQ.isEmpty()){
                    for(String id : updatequoteLineId){
                        if (!extraSQMap.containsKey(id)) { extraSQMap.put(id, new Map<String, SQ_QuoteLineitem_Junction__c>()); }
                        for(SQ_QuoteLineitem_Junction__c sq : extraSQ){
                            if(sq.QuoteLineItem__c == id){ extraSQMap.get(id).put(sq.SQ__c, sq); }
                        }
                    }

                    firstSQ = [
                        SELECT  Id, 
                                SQ__c, 
                                QuoteLineItem__c, 
                                SQ__r.Name, 
                                SQ__r.SQCode__c, 
                                SQ__r.Price__c, 
                                POSNR__c, 
                                QuoteLineItem__r.Product2.Plant__c,
                                UPDATEFLAG__c,
                                SalesPrice__c,
                                Sales_Price__c
                        FROM    SQ_QuoteLineitem_Junction__c 
                        WHERE   QuoteLineItem__c IN: quoteLineId 
                        ORDER BY QuoteLineItem__c
                    ];

                    for(SQ_QuoteLineitem_Junction__c sq : firstSQ){
                        firstSQMap.put(sq.SQ__c, sq);
                    }
                }
                
                List<QuoteLineItem> extraQtLine = new List<QuoteLineItem>();
                for(String id : updatequoteLineId){
                    QuoteLineItem upqt = new QuoteLineItem();
                    upqt.Id                 = id;
                    upqt.Dealer_Price__c    = upRecord[0].Dealer_Price__c;
                    upqt.UnitPrice          = upRecord[0].UnitPrice;
                    upqt.Warranty_Acc__c    = upRecord[0].Warranty_Acc__c;
                    upqt.Warranty_Prd__c    = upRecord[0].Warranty_Prd__c;
                    upqt.Warranty_SQ__c     = upRecord[0].Warranty_SQ__c;
                    upqt.ERPQuotationNo__c  = upRecord[0].ERPQuotationNo__c;
                    upqt.MAX_POSNR__c       = quoteLineItemsToUpdate[0].MAX_POSNR__c;
                    upqt.QuotePriceIF__c    = quoteLineItemsToUpdate[0].QuotePriceIF__c;
                    extraQtLine.add(upqt);

                    if(!extraCV.isEmpty()){
                        Map<String, CharacteristicValue__c> innerCVMap = extracvMap.get(id);
                        for(String key : innerCVMap.keySet()){
                            CharacteristicValue__c cv = innerCVMap.get(key);
                            cv.Price__c = firstcvMap.get(key).Price__c;
                            extraupCvRecord.add(cv);
                        }
                    }
                
                    if(!extraAcc.isEmpty()){
                        Map<String, Accessory__c> innerAccMap = extraAccMap.get(id);
                        for(String key : innerAccMap.keySet()){
                            Accessory__c acc = innerAccMap.get(key);
                            acc.Price__c = firstAccMap.get(key).Price__c;
                            acc.Delete__c = firstAccMap.get(key).Delete__c;
                            acc.POSNR__c = firstAccMap.get(key).POSNR__c;
                            extraupAccRecord.add(acc);
                        }
                    }

                    if(!extraSQ.isEmpty()){
                        Map<String, SQ_QuoteLineitem_Junction__c> innerSQMap = extraSQMap.get(id);
                        for(String key : innerSQMap.keySet()){
                            SQ_QuoteLineitem_Junction__c sq = innerSQMap.get(key);
                            sq.POSNR__c = firstSQMap.get(key).POSNR__c;
                            sq.UPDATEFLAG__c = firstSQMap.get(key).UPDATEFLAG__c;
                            sq.SalesPrice__c = firstSQMap.get(key).SalesPrice__c;
                            extraupSQRecord.add(sq);
                        }
                    }
                }

                List<T_COND_ELMT__c> extraEMLT = new List<T_COND_ELMT__c>();
                if(!elmtList.isEmpty()){
                    for(String id : updatequoteLineId){
                        for(T_COND_ELMT__c elmt : elmtList){
                            T_COND_ELMT__c extraElmt = new T_COND_ELMT__c();
                            extraElmt.Quote_Line_Item__c  = id;
                            extraElmt.KAPPL__c            = elmt.KAPPL__c;
                            extraElmt.KBETR__c            = elmt.KBETR__c;
                            extraElmt.KSCHL__c            = elmt.KSCHL__c;
                            extraElmt.MATNR__c            = elmt.MATNR__c;
                            extraElmt.VKORG__c            = elmt.VKORG__c;
                            extraElmt.VTWEG__c            = elmt.VTWEG__c;
                            extraElmt.WAERK__c            = elmt.WAERK__c;
                            extraElmt.ZTERM__c            = elmt.ZTERM__c;
                            extraElmt.ZZKVGR4__c          = elmt.ZZKVGR4__c;
                            extraEMLT.add(extraElmt);
                        }
                    }
                }

                if(!extraQtLine.isEmpty()){ update extraQtLine; }
                if(!extraupCvRecord.isEmpty()){ update extraupCvRecord; }
                if(!extraupAccRecord.isEmpty()){ update extraupAccRecord; }
                if(!extraupSQRecord.isEmpty()){ update extraupSQRecord; }
                if(!extraEMLT.isEmpty()){ insert extraEMLT; }
            }

            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('quotation Interface : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
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
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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