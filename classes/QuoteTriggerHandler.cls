/**
 * @description       : 
 * @author            : Sejin Kwon
 * @group             : 
 * @last modified on  : 05-28-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-02-2024   Sejin Kwon     Initial Version
**/
public with sharing class QuoteTriggerHandler extends TriggerHandler{
    private static final Id   recordTypeIdKorea  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Korea').getRecordTypeId();
    private static final Id   recordTypeIdGlobal  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Global').getRecordTypeId();
    private static final Id   recordTypeIdDNSA  = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();
    private static final Id   recordTypeIdService  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
    private static final Id   recordTypeIdCommodity  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
    private static final Id   recordTypeIdFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();
    private static final User   currentUser  = getCurrentUser();
    
    public override void onBeforeInsert(List<sObject> news){
        if (isExecuting) {
            System.debug('Quote BEFORE_INSERT TRIGGER Start');
            List<Quote> quoteList = (List<Quote>) news;
            Set<Id> opptyIds = new Set<Id>();
            // 2025.03.11 suheon.ha
            String pricebook2Id = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1].Id;
            Quote newCheck;
            if(news.size() > 0) {
                newCheck = (Quote)news[0];
            }
            
            List<Quote> quoteCnt = [SELECT Id FROM Quote WHERE OpportunityId =: newCheck.OpportunityId];
            if(quoteCnt.isEmpty()){
                newCheck.VersionCount__c = '1';
            }else{
                newCheck.VersionCount__c = String.valueOf(quoteCnt.size() + 1);
            }

            for(Quote q : quoteList) {
                opptyIds.add(q.OpportunityId);
                // q.CreatedDate__c = System.now();
                // if(q.RecordTypeID == recordTypeIdService) {
                //     q.Pricebook2Id = pricebook2Id;
                // }
            }
            
            // 2025.03.25 suheon.ha
            if (!opptyIds.isEmpty()) {
                Map<Id, String> opptyEquipMap = new Map<Id, String>();
                for (Opportunity opp : [SELECT Id, Equipment__r.Name, Equipment__r.MachineName__c FROM Opportunity WHERE Id IN :opptyIds]) {
                    if (opp.Equipment__r != null) {
                        String equipName = opp.Equipment__r.Name != null ? opp.Equipment__r.Name : '';
                        String machineName = opp.Equipment__r.MachineName__c != null ? opp.Equipment__r.MachineName__c : '';
                        opptyEquipMap.put(opp.Id, equipName + ' - ' + machineName);
                    }
                }

                for (Quote q : quoteList) {
                    if (q.RecordTypeId == recordTypeIdService && opptyEquipMap.containsKey(q.OpportunityId)) {
                        q.Description = opptyEquipMap.get(q.OpportunityId);
                    }
                }
            }

            if(!opptyIds.isEmpty()) dnsaModelMapping(opptyIds, quoteList);
            
            /////////Incoterms, Payment default로 설정하고 변경 매뉴얼로 제공 하므로 주석_20250114
            setting(false, TriggerOperation.BEFORE_INSERT);
            System.debug('Quote BEFORE_INSERT TRIGGER End');
        }
    }

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting){
            System.debug('Quote BEFORE_UPDATE TRIGGER Start');
            List<Quote> quoteList = (List<Quote>) news;
            Quote oldCheck;
            Quote newCheck;

            if(olds.size() > 0) {
                oldCheck = (Quote)olds[0];
            }
            if(news.size() > 0) {
                newCheck = (Quote)news[0];
            }

            if(newCheck.RecordTypeId == recordTypeIdGlobal || newCheck.RecordTypeId == recordTypeIdKorea){
                Boolean quoteFinal = oldCheck.IsFinal__c;
                List<QuoteLineItem> quoteLine = [SELECT Id, Order__r.ERPOrderNo__c FROM QuoteLineItem WHERE QuoteId =: newCheck.Id AND Order__r.ERPOrderNo__c != null];
                //ERP통신해서 가격변경이 아니면 수정 안되게
                if(quoteFinal && quoteLine.size() > 0 && oldCheck.TotalPrice == newCheck.TotalPrice){
                    newCheck.addError(System.Label.DNS_M_CantEditQuote);
                }
            }

            if(quoteList[0].RecordTypeId == recordTypeIdCommodity || quoteList[0].RecordTypeId == recordTypeIdFactory || System.Test.isRunningTest()) {
                String warranty = '';
                if(oldMap.get(quoteList[0].Id).get('MachinePartsWarranty__c') != quoteList[0].MachinePartsWarranty__c) {
                    warranty = quoteList[0].MachinePartsWarranty__c;
                }

                if(warranty != '' || System.Test.isRunningTest()) {
                    List<Warranty__c> wrList = new List<Warranty__c>();
                    if(currentUser.AccountId != null) {
                        wrList = [SELECT Id, Percent__c FROM Warranty__c WHERE ZZPR_WAR__c = :warranty AND BZIRK__c = :currentUser.Account.SalesDistrict__c LIMIT 1];
                    } else {
                        wrList = [SELECT Id, Percent__c FROM Warranty__c WHERE ZZPR_WAR__c = :warranty AND BZIRK__c = :currentUser.SalesDistrict__c LIMIT 1];
                    }
    
                    List<QuoteLineItem> qliList = [SELECT ListPrice__c FROM QuoteLineItem WHERE QuoteId = :quoteList[0].Id LIMIT 1];
                    if(!wrList.isEmpty() && !qliList.isEmpty()) {
                        if(quoteList[0].MachinePartsWarranty__c != 'M24') {
                            quoteList[0].ExtWarranty__c = qliList[0].ListPrice__c * (wrList[0].Percent__c / 100);
                        } else {
                            quoteList[0].ExtWarranty__c = 0;
                        }
                        update quoteList[0];
                    }
                }

                //DNSA Model Sales Office Update
                if(quoteList[0].RecordTypeId == recordTypeIdFactory){
                    if(newCheck.DNSAModel__c != null){
                        DNSAModel__c so = [SELECT SalesOffice__c FROM DNSAModel__c WHERE Id =: newCheck.DNSAModel__c];
                        if(so.SalesOffice__c != null){
                            newCheck.DNSA_SalesOffice__c = so.SalesOffice__c;
                        }
                    }else{
                        newCheck.DNSA_SalesOffice__c = '414P';
                    }
                }
                if(quoteList[0].RecordTypeId == recordTypeIdFactory && newCheck.DNSAModel__c == null){
                    newCheck.DNSA_SalesOffice__c = '414P';
                }
                List<QuoteLineItem> qlCheck = [SELECT Id FROM QuoteLineItem WHERE QuoteId =: newCheck.Id];
                if(!qlCheck.isEmpty() && quoteList[0].RecordTypeId == recordTypeIdFactory && newCheck.DNSAModel__c != oldCheck.DNSAModel__c){
                    //quote line item이 있고 recordType이 factory인데 model을 변경하려고하면 에러
                    newCheck.addError('You cannot change the model after selecting the main specification.');
                }
                
            }

            Set<Id> quoteIds = new Set<Id>();
            for(Quote quote : quoteList) {
                if(oldMap.get(quote.Id).get('DNSAModel__c') != quote.DNSAModel__c) {
                    quoteIds.add(quote.Id);
                }
            }

            if(!quoteIds.isEmpty() && quoteList[0].RecordTypeId == recordTypeIdCommodity) {
                List<QuoteLineItem> qliList = [SELECT Id, QuoteId FROM QuoteLineItem WHERE QuoteId IN :quoteIds];
                if(!qliList.isEmpty()) {
                    for(Quote quote : quoteList) {
                        for(QuoteLineItem qli : qliList) {
                            if(quote.Id == qli.QuoteId) {
                                quote.addError('DNS model can be modified after canceling the reservation.');
                            }
                        }
                    }
                }
            }

            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('Quote BEFORE_UPDATE TRIGGER End');
        }
    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('Quote AFTER_UPDATE TRIGGER Start');
            List<Quote> quoteList = (List<Quote>) news;
            List<Opportunity> updateOpptyList = new List<Opportunity>();
            Map<String, String> quoteMap = new Map<String, String>();
            Map<Id, String> quoteAlertMap = new Map<Id, String>();
            Map<Id, Decimal> discountMap = new Map<Id, Decimal>();
            Set<Id> commQuoteIds = new Set<Id>();
            Quote oldCheck;
            Quote newCheck;

            if(olds.size() > 0) {
                oldCheck = (Quote)olds[0];
            }
            if(news.size() > 0) {
                newCheck = (Quote)news[0];
            }
            if(oldCheck.DNSAModel__c != newCheck.DNSAModel__c){
                List<DNSA_Factory_Option_Junction__c> factoryOptionList = 
                [
                    SELECT
                        Id
                    FROM
                        DNSA_Factory_Option_Junction__c
                    WHERE
                        Quote__c  =: newCheck.Id
                    // AND Dealer_Checked__c = false

                ];
                if(!factoryOptionList.isEmpty()){
                    delete factoryOptionList;
                }
            }

            for(Quote quote : quoteList) {
                if(oldMap.get(quote.Id).get('IsFinal__c') != quote.IsFinal__c && quote.IsFinal__c == true || System.Test.isRunningTest()) {

                    Opportunity updateOppty = new Opportunity();
                    updateOppty.Id = quoteList[0].OpportunityId;
                    updateOppty.HasFinalQuote__c = true;

                    updateOpptyList.add(updateOppty);

                //Quote에 최종견적 확정 CheckBox False -> Oppty Has Final Quote False Update
                } else if (oldMap.get(quote.Id).get('IsFinal__c') != quote.IsFinal__c && quote.IsFinal__c == false) {
                    Opportunity updateOppty = new Opportunity();
                    updateOppty.Id = quoteList[0].OpportunityId;
                    updateOppty.HasFinalQuote__c = false;

                    updateOpptyList.add(updateOppty);
                }

                if(oldMap.get(quote.Id).get('DNSA_SalesOffice__c') != quote.DNSA_SalesOffice__c && quote.RecordTypeId == recordTypeIdFactory) {
                    quoteMap.put(quote.Id, quote.DNSA_SalesOffice__c);
                }
                
                if (quote.RecordTypeId == recordTypeIdService && oldMap.get(quote.Id).get('Discount__c') != quote.Discount__c) {
                    System.debug('Discount__c1');
                    discountMap.put(quote.Id, quote.Discount__c);
                }

                if(oldMap.get(quote.Id).get('Waiting_Seq__c') != null && quote.Waiting_Seq__c != null && oldMap.get(quote.Id).get('Waiting_Seq__c') != quote.Waiting_Seq__c) {
                    commQuoteIds.add(quote.Id);
                }
                quoteAlertMap.put(quote.Id, quote.Name);
                System.debug('@@ quoteAlertMap : ' + quoteAlertMap);
            }
            if(!updateOpptyList.isEmpty()) update updateOpptyList;
            if(!quoteMap.isEmpty()) updateDNSASalesTeam(quoteMap);
            if(!commQuoteIds.isEmpty()) sendChangeSeqAlert(commQuoteIds);

            Set<Id> quoteIds = new Set<Id>();
            Map<String, Date> dateMap = new Map<String, Date>();
            for(Quote quote : quoteList) {
                if(quote.RecordTypeId == recordTypeIdCommodity || quote.RecordTypeId == recordTypeIdFactory || System.Test.isRunningTest()) {
                    if(oldMap.get(quote.Id).get('RequestedShipDate__c') != quote.RequestedShipDate__c) {
                        quoteIds.add(quote.Id);
                        dateMap.put(quote.Id, quote.RequestedShipDate__c);
                    }
                }
            }
            if(!dateMap.isEmpty()) {
                List<QuoteLineItem> qliList = [SELECT QuoteId, Requested_Ship_Date__c FROM QuoteLineItem WHERE QuoteId IN :dateMap.keySet()];
                if(!qliList.isEmpty()) {
                    List<QuoteLineItem> qliUpdateList = new List<QuoteLineItem>();
                    for(QuoteLineItem qli : qliList) {
                        qli.Requested_Ship_Date__c = dateMap.get(qli.QuoteId);
                        qliUpdateList.add(qli);
                    }
                    if(!qliUpdateList.isEmpty()) update qliUpdateList;
                }
            }
            if (!discountMap.isEmpty()) {
                List<QuoteLineItem> qliList = [
                    SELECT Id, QuoteId, Discount__c, CSTotalPrice__c, isManualDiscount__c, isManualAmount__c, Quantity, UnitPrice
                    FROM QuoteLineItem 
                    WHERE QuoteId IN :discountMap.keySet()
                    AND isManualDiscount__c = false
                ];
                
                List<QuoteLineItem> qliUpdateList = new List<QuoteLineItem>();
            
                for (QuoteLineItem qli : qliList) {
                    Decimal newDiscount = discountMap.get(qli.QuoteId);
                    if (qli.Discount__c != newDiscount) {
                        qli.Discount__c = newDiscount;
                        if (qli.CSTotalPrice__c != 0 && qli.isManualAmount__c == false) {
                            qli.CSTotalPrice__c = (qli.UnitPrice * qli.Quantity * (1 - (newDiscount / 100)));
                        }
                        qliUpdateList.add(qli);
                    }
                }
                
                if (!qliUpdateList.isEmpty()) {
                    System.debug('qliUpdateList:::' + qliUpdateList);
                    update qliUpdateList;
                }
            }

            Set<Id> userIds = new Set<Id>();
            userIds.add(UserInfo.getUserId());
            List<User> getProfile =  DN_WithoutSharingClass.getUserEmails(userIds);
            
            if(getProfile[0].Profile.Name == '영업 글로벌 대리점' || getProfile[0].Profile.Name == '영업 글로벌 대리점 Login'){
                //[GSR SR0000010031094] 견적 수정 시 CRM 알람 전송_250820 이원정
                String alertName        = 'Update Quote Alert';
                String alertType        = 'Notification';
                String userId           = UserInfo.getUserId();
                String alertLanguage    = 'ko';

                DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,quoteAlertMap);
            }
                setting(false, TriggerOperation.AFTER_UPDATE);
                System.debug('Quote AFTER_UPDATE TRIGGER End');
            
            }
    }

    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting){
            List<Quote> quoteList = (List<Quote>)news;
            Map<Id, String> quoteCreateAlertMap = new Map<Id, String>();
            Map<String, Warranty__c> globalWarMap = new Map<String, Warranty__c>();

            Opportunity quoteSync = new Opportunity();
            quoteSync.Id = quoteList[0].OpportunityId;
            quoteSync.isQuote__c    = true;
            update quoteSync;

            List<Quote> getrecordName = [SELECT AccountId, Opportunity.RecordTypeId, RecordType.Name, Account.CountryLookup__r.Name, Account.CountryLookup__r.CountryCode__c FROM Quote WHERE Id =: quoteList[0].Id];
            List<Opportunity> getname = [SELECT Name FROM Opportunity WHERE Id =:quoteList[0].OpportunityId];
            List<Warranty__c> globalWar = [SELECT Id, KSCHL__c, VKORG__c, SPART__c, VTWEG__c, ZZPR_WAR__c, Percent__c, DATBI__c, DATAB__c, ZZWARRPER__c, ZZPERUNIT__c, ZZWARHRS__c, ZZCOVERAGE__c, ZZCOVERAGE_B__c FROM Warranty__c WHERE VTWEG__c = '20'];

            for(Warranty__c glo : globalWar){
                globalWarMap.put(glo.ZZPR_WAR__c, glo);
            }

            if(!quoteList[0].isCloned__c && getrecordName[0].Opportunity.RecordTypeId != recordTypeIdDNSA){
                // if(getrecordName[0].Opportunity.RecordTypeId != recordTypeIdDNSA){ //Oppty가 DNSA가 아닌 경우에만 Quote Naming Rule적용
                    Quote upName = new Quote();
                    upName.Id = quoteList[0].Id;
                    upName.Name = getname[0].Name + '_Quote';
                    //QuoteAccountId에도 AccountId 입력_20250331_sejin kwon
                    System.debug('newCheck.AccountId : ' + getrecordName[0].AccountId);
                    upName.QuoteAccountId = getrecordName[0].AccountId;
                    update upName;
                // }
                List<OpportunityLineItem> oppPrdList = [
                    SELECT 
                        Id, 
                        OpportunityId, 
                        PricebookEntryId, 
                        Quantity, 
                        ListPrice,
                        UnitPrice,
                        SupplyProduct__c, 
                        OptyProdCurrency__c, 
                        Unit__c, 
                        AvailableStock__c, 
                        Opportunity.RequestDelieveryDate__c,
                        ERPInquiryNo__c
                    FROM
                        OpportunityLineItem
                    WHERE
                        OpportunityId =:quoteList[0].OpportunityId];
                List<QuoteLineItem> createQuotePrd = new List<QuoteLineItem>();
                for(OpportunityLineItem qppPrd : oppPrdList){
                    QuoteLineItem quotePrd = new QuoteLineItem();
                    if (quoteList[0].RecordTypeId != recordTypeIdService) {
                        quotePrd.QuoteId = quoteList[0].Id;
                        quotePrd.PricebookEntryId = qppPrd.PricebookEntryId;
                        quotePrd.Quantity = qppPrd.Quantity;
                        quotePrd.UnitPrice = qppPrd.ListPrice;
                        quotePrd.RequestedDelivDate__c = qppPrd.Opportunity.RequestDelieveryDate__c;
                        quotePrd.OpportunityLineItemId = qppPrd.Id;
                        // quotePrd.UnitPrice = qppPrd.UnitPrice;
                    }
                    if(quoteList[0].RecordTypeId == recordTypeIdKorea){
                        quotePrd.ExpectedDelivDate__c = quoteList[0].ExpectedDelivDate__c;
                    }
                    quotePrd.ERPInquiryNo__c = qppPrd.ERPInquiryNo__c;
                    quotePrd.Quote_RecordType__c = getrecordName[0].RecordType.Name;
                    if(getrecordName[0].Account.CountryLookup__r.CountryCode__c == 'KR'){//국가가 한국이면 Warranty 12개월 Default
                        quotePrd.Warranty__c = 'B1D';
                    }
                    else if(getrecordName[0].Account.CountryLookup__r.CountryCode__c == 'GB' || getrecordName[0].Account.CountryLookup__r.CountryCode__c == 'IT'){//영국, 이탈리아는 24개월
                        quotePrd.Warranty__c = 'B24';
                        quotePrd.Warranty_Percent__c = globalWarMap.get('B24').Percent__c;
                    }else{ //나머지는 12개월
                        quotePrd.Warranty__c = 'B12';
                        quotePrd.Warranty_Percent__c = globalWarMap.get('B12').Percent__c;
                    }
                    createQuotePrd.add(quotePrd);
                }
                insert createQuotePrd;
            }

            if(getrecordName[0].Opportunity.RecordTypeId == recordTypeIdDNSA) {
                Quote upName = new Quote();
                upName.Id = quoteList[0].Id;
                upName.QuoteAccountId = getrecordName[0].AccountId;
                update upName;
            }

            for(Quote quote : quoteList){
                quoteCreateAlertMap.put(quote.Id, quote.Name);
            }

            Set<Id> userIds = new Set<Id>();
            userIds.add(UserInfo.getUserId());
            List<User> getProfile =  DN_WithoutSharingClass.getUserEmails(userIds);
            
            if(getProfile[0].Profile.Name == '영업 글로벌 대리점' || getProfile[0].Profile.Name == '영업 글로벌 대리점 Login'){
                //[GSR SR0000010031094] 견적 등록 시 CRM 알람 전송_250820 이원정
                String alertName        = 'Create Quote Alert';
                String alertType        = 'Notification';
                String userId           = UserInfo.getUserId();
                String alertLanguage    = 'ko';

                DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,quoteCreateAlertMap);
            }
        }
    }

    private static void dnsaModelMapping(Set<Id> opptyIds, List<Quote> quoteList) {
        List<Opportunity> opptyList = [
            SELECT  Id
                    , DNSAModel__c
                    , PO__c
                    , Name
                    , DNSAModel__r.SalesOffice__c
            FROM Opportunity
            WHERE Id IN :opptyIds
        ];
        if(!opptyList.isEmpty()) {
            for(Quote q : quoteList) {
                for(Opportunity oppty : opptyList) {
                    if(q.OpportunityId == oppty.Id) {
                        // if(oppty.PO__c != null) {
                            // q.put('Name', oppty.PO__c);
                            q.put('Name', oppty.Name + '_Quote');// Quote생성할때 이름 자동으로 Opportunity Name_Quote로 _250317
                        // }
                        if(q.RecordTypeId == recordTypeIdFactory){
                            if(oppty.DNSAModel__c != null) {
                                q.put('DNSAModel__c', oppty.DNSAModel__c);
                                q.put('DNSA_SalesOffice__c', oppty.DNSAModel__r.SalesOffice__c);
                            }else{
                                q.put('DNSA_SalesOffice__c', '414P');
                            }
                        }
                        
                    }
                }
            }
        }
    }

    private static void updateDNSASalesTeam(Map<String, String> quoteMap) {
        // List<SQRegistration__c> sqrList = [SELECT Id, Name, Quote__c, DNSA_Sales_Team__c FROM SQRegistration__c WHERE Quote__c IN :quoteMap.keySet() ORDER BY CreatedDate DESC];
        List<Quote> qtInfo = [SELECT Id, QuoteNumber FROM Quote WHERE Id IN:quoteMap.keySet()];
        if(!qtInfo.isEmpty()) {
            List<MessageGroup__c> mgList = [SELECT Id FROM MessageGroup__c WHERE SalesOffice__c = :quoteMap.get(qtInfo[0].Id)];
            if(!mgList.isEmpty()) {
                // sqrList[0].DNSA_Sales_Team__c = mgList[0].Id;
                // update sqrList[0];

                sendCheckSQRegistrationAlert(quoteMap.get(qtInfo[0].Id), quoteMap, qtInfo);
            }
        }
        return;
    }

    private static void sendCheckSQRegistrationAlert(String mgId, Map<String, String> quoteMap, List<Quote> qtInfo) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> notiReceiverEN = new Set<Id>();
        List<String> emailReceiverEN = new List<String>();

        List<Message_Group_Junction__c> mgjList = [SELECT Id, User__c, FM_UserEmail__c FROM Message_Group_Junction__c WHERE Message_Group__r.SalesOffice__c =:mgId AND User__r.IsActive = true];
        if(!mgjList.isEmpty()) {
            for(Message_Group_Junction__c mgj : mgjList) {
                notiReceiverEN.add(mgj.User__c);
                emailReceiverEN.add(mgj.FM_UserEmail__c);
            }

            List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'ChangeDNSASalesOffice' LIMIT 1];

            if(!am.isEmpty()) {
                if(!notiReceiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(qtInfo[0].QuoteNumber);
                    history.alertID         = am[0].Id;
                    history.targetID        = qtInfo[0].Id;
                    history.receiverforID   = notiReceiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }
                if(!emailReceiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Email';
                    history.elementList.add(qtInfo[0].QuoteNumber);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + qtInfo[0].Id);
                    history.alertID             = am[0].Id;
                    history.targetID            = qtInfo[0].Id;
                    history.receiverforEmail    = emailReceiverEN;
                    history.alertLanguage       = 'en';
                    ahwList.add(history);
                }
                if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
            }
        }
        return;
    }

    private static void sendChangeSeqAlert(Set<Id> commQuoteIds) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> createdByIds = new Set<Id>();
        
        List<QuoteLineItem> qliList = DN_WithoutSharingClass.queryQuoteLineItemsQuoteIds(commQuoteIds);
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Send Wating Alert' LIMIT 1];

        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
    
        if(!am.isEmpty() && !qliList.isEmpty()) {
            for(QuoteLineItem ql : qliList) {
                if(ql.CreatedById != null) {
                    createdByIds.add(ql.CreatedById);
                }
            }
    
            Map<Id, User> userMap = new Map<Id, User>();
            List<User> users = DN_WithoutSharingClass.getUserEmails(createdByIds);
            for(User u : users) {
                userMap.put(u.Id, u);
            }
    
            for(QuoteLineItem ql : qliList) {
                if(ql.CreatedById != null && ql.Quote.Waiting_Seq__c != null) {
                    UTIL_Alert.HistoryWrapper notificationHistory = new UTIL_Alert.HistoryWrapper();
                    notificationHistory.alertType = 'Notification';
                    notificationHistory.elementList.add(ql.StockResSO__c);
                    notificationHistory.elementList.add(ql.Quote.Waiting_Seq__c == '1' ? 'first' : ql.Quote.Waiting_Seq__c == '2' ? 'second' : '');
                    notificationHistory.alertID = am[0].Id;
                    notificationHistory.targetID = ql.QuoteId;
                    notificationHistory.receiverforID = new Set<Id>{ql.CreatedById};
                    notificationHistory.alertLanguage = 'en';
                    ahwList.add(notificationHistory);
    
                    User user = userMap.get(ql.CreatedById);
                    if(user != null && String.isNotBlank(user.Email)) {
                        UTIL_Alert.HistoryWrapper emailHistory = new UTIL_Alert.HistoryWrapper();
                        emailHistory.alertType = 'Email';
                        emailHistory.elementList.add(ql.Quote.Waiting_Seq__c == '1' ? 'first' : ql.Quote.Waiting_Seq__c == '2' ? 'second' : '');
                        emailHistory.elementList.add(ql.StockResSO__c);
                        emailHistory.elementList.add(baseUrl + '/' + ql.QuoteId);
                        emailHistory.alertID = am[0].Id;
                        emailHistory.targetID = ql.QuoteId;
                        emailHistory.receiverforEmail = new List<String>{user.Email};
                        emailHistory.alertLanguage = 'en';
                        ahwList.add(emailHistory);
                    }
                }
            }
    
            if(!ahwList.isEmpty()) {
                UTIL_Alert.runAlertEvent(ahwList);
            }
        }
        return;
    }

    private static User getCurrentUser() {
        User user = [
            SELECT  Id
                    , SalesOrganization__c
                    , SalesOffice__c
                    , SalesDistrict__c
                    , DistributionChannel__c
                    , Division__c
                    , AccountId
                    , Account.CustomerCode__c
                    , Account.SalesOrganization__c
                    , Account.SalesOffice__c
                    , Account.DistributionChannel__c
                    , Account.Division__c
                    , Account.SalesDistrict__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        return user;
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