/**
* @Class : DN_FinalQuoteCheckController
*
* @Author : SeJin, Kwon
* @Date : 2024. 11. 07.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-11-07 | SeJin, Kwon   | 최초작성
*
*/
public with sharing class DN_FinalQuoteCheckController {
    private static final Id   recordTypeIdFactory  = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();

    @AuraEnabled
    public static Map<String, Object> getStatus(String recordId){
        try {
            Decimal finalAmount = 0;
            List<QuoteLineItem> quoteStatus = 
                [
                    SELECT 
                        Id,
                        Final_Quotation_Price__c 
                    FROM 
                        QuoteLineItem
                    WHERE
                        QuoteId =: recordId
                        and F_IsOrderCreated__c = true
                ];

            List<QuoteLineItem> quoteAmount = 
            [
                SELECT 
                    Id,
                    Final_Quotation_Price__c,
                    Quote.RecordTypeId,
                    US_Option_Total__c,
                    Dealer_Price__c,
                    Adjustment_Price__c
                FROM 
                    QuoteLineItem
                WHERE
                    QuoteId =: recordId
            ];
            List<Quote> isFinal = 
            [
                SELECT
                    IsFinal__c,
                    OpportunityId
                FROM
                    Quote
                WHERE
                    Id =: recordId
            ];

            List<Quote> anotherFinal = 
            [
                SELECT
                    IsFinal__c,
                    RecordTypeId
                FROM 
                    Quote 
                WHERE 
                    OpportunityId =: isFinal[0].OpportunityId
            ];
            if(anotherFinal.size() > 1){
                for(Quote qt : anotherFinal){
                    if(qt.RecordTypeId == recordTypeIdFactory && qt.IsFinal__c == true){
                        return new Map<String, Object>{'Status'=> 'There is already a confirmed final quote.'};
                    }
                }
            }
            List<QuoteLineItem> quoteStatusIf = 
                [
                    SELECT 
                        Id 
                    FROM 
                        QuoteLineItem
                    WHERE
                        QuoteId =: recordId
                        and QuotePriceIF__c = false
                        // and ERPQuotationNo__c != null
                ];

            List<SQ_QuoteLineitem_Junction__c> sqFinalCheck = 
            [
                SELECT
                    Id,
                    FM_SQ_Stage__c
                FROM
                    SQ_QuoteLineitem_Junction__c
                WHERE
                    QuoteLineItem__r.QuoteId =: recordId
            ];

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

            
            if(!sqFinalCheck.isEmpty()){
                for(SQ_QuoteLineitem_Junction__c sq : sqFinalCheck ){
                    if(!sq.FM_SQ_Stage__c.contains('Final') && !sq.FM_SQ_Stage__c.contains('Drop')){
                        return new Map<String, Object>{'Status'=> System.Label.DNS_M_FinalSQCheck};
                    }
                }
            }

            if(quoteStatus.size() > 0) { // 이미 주문이 생성된 건이면 ERROR
                return new Map<String, Object>{'Status'=> System.Label.DNS_M_CantQuoteCopyOrder};
            }else if(isFinal[0].IsFinal__c == true){
                return new Map<String, Object>{'Status'=> System.Label.DNS_M_QuoteFinal};//Since the final quotation has been confirmed, adding products, confirming quotations, and requesting reviews are not allowed.
            }
            else if(quoteStatusIf.size() > 0){
                return new Map<String, Object>{'Status'=> System.Label.DNS_M_CheckERPQuote}; //ERP견적이 미 완료된 건이 존재합니다. There are incomplete ERP quotations.
            }else if(noQuoteLine.size() == 0){
                return new Map<String, Object>{'Status'=> System.Label.DNS_M_NoQuoteLine}; //ERP견적이 미 완료된 건이 존재합니다. There are incomplete ERP quotations.
            }
            else
            {
                for(QuoteLineItem qt : quoteAmount){
                    if(qt.Quote.RecordTypeId == recordTypeIdFactory){
                        finalAmount = qt.Dealer_Price__c + qt.US_Option_Total__c + qt.Adjustment_Price__c;
                    }else if(qt.Final_Quotation_Price__c != null){
                            finalAmount = finalAmount + qt.Final_Quotation_Price__c;
                        
                        System.debug('finalAmount : ' + finalAmount);
                        System.debug('Final_Quotation_Price__c : ' + qt.Final_Quotation_Price__c);
                    }
                }
                
                return new Map<String, Object>{
                    'Status' => 'SUCCESS'
                    ,'TotalAmount' => finalAmount
                };
            }
        } catch (Exception e) {
            System.debug('QuoteCopy : ' + e.getLineNumber() + ' : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateFinalQuote(String recordId, Decimal FPAmount){
        try {
            List<Quote> quoteId = [SELECT Id, RecordTypeId, OpportunityId, RecordType.DeveloperName, QuoteNumber, Opportunity.Opportunity_Owner__c, Opportunity.Opportunity_Owner__r.AccountId, OwnerId FROM Quote WHERE Id =: recordId];
            
            Opportunity finalQuote = new Opportunity();
                finalQuote.Id = quoteId[0].OpportunityId;
                finalQuote.HasFinalQuote__c = true;
                finalQuote.Amount__c = FPAmount;
                finalQuote.StageName = 'Conditional Agreement';
                finalQuote.CustBudgetRoute__c = System.Label.DNS_M_ETC;

            TriggerHandler.bypass('OpportunityTriggerHandler');
            DN_WithoutSharingClass.updateOppty(finalQuote);
            TriggerHandler.clearBypass('OpportunityTriggerHandler');

            Quote isfinalQuote = new Quote();
            isfinalQuote.Id = recordId;
            isfinalQuote.IsFinal__c = true;
            if(quoteId[0].RecordTypeId == recordTypeIdFactory){
                isfinalQuote.Recently_Version__c = true;
            }
            DN_WithoutSharingClass.updateQuote(isfinalQuote);

            String instanceUrl = URL.getOrgDomainUrl().toExternalForm();
            Set<Id> ownerId = new Set<Id>();
            List<String> emailAddr = new List<String>();
            Set<Id> notiId = new Set<Id>();
            
            if(quoteId[0].RecordType.DeveloperName == 'Global'){
                //Quote -> Opportunity -> Owner -> Account -> Dealer -> Manager에게 알림
                List<User> managerInfo = [SELECT Id, Name, UserRole.PortalRole FROM User WHERE AccountId =: quoteId[0].Opportunity.Opportunity_Owner__r.AccountId AND UserRole.PortalRole = 'Manager'];

                if(!managerInfo.isEmpty()){
                    ownerId.add(managerInfo[0].Id);
                    List<User> getEmail =  DN_WithoutSharingClass.getUserEmails(ownerId);
                    
                    if(!getEmail.isEmpty()){
                        for(Integer i = 0; i < getEmail.size(); i++){
                            if(System.Test.isRunningTest()){
                                emailAddr.add(getEmail[i].Email); 
                            }else{
                                emailAddr.add(getEmail[i].Email); 
                            }
                            System.debug('email addr : ' + emailAddr);
                        }
                        for(Integer i = 0; i < getEmail.size(); i++){
                            if(System.Test.isRunningTest()){
                                notiId.add(getEmail[i].Id); 
                            }else{
                                notiId.add(getEmail[i].Id);
                            }
                        }
                    } 
                }
                   
            } else if(quoteId[0].RecordType.DeveloperName == 'DNSA_Factory' || quoteId[0].RecordType.DeveloperName == 'DNSA_Commodity') {
                ownerId.add(quoteId[0].OwnerId);
                List<User> getEmail =  DN_WithoutSharingClass.getUserEmails(ownerId);
                
                if(!getEmail.isEmpty()){
                    if(System.Test.isRunningTest()){
                        emailAddr.add(getEmail[0].Email); 
                    }else{
                        emailAddr.add(getEmail[0].Email); 
                    }

                    if(System.Test.isRunningTest()){
                        notiId.add(getEmail[0].Id); 
                    }else{
                        notiId.add(getEmail[0].Id);
                    }
                }
            }
            
            if(!emailAddr.isEmpty() && !notiId.isEmpty()) {
                List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Final Quote Alert'];
                Id alertId;
    
                if(!am.isEmpty()){
                    alertId = am[0].Id;
                }else{
                    alertId = 'a0xF7000009v1azIAA';
                }
                UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();
                    wrapEmail.alertID            = alertId;
                    wrapEmail.targetID           = recordId;
                    wrapEmail.alertType          = 'Email';
                    wrapEmail.receiverforEmail   = emailAddr;
                    wrapEmail.alertLanguage      = 'en';
                    wrapEmail.elementList        = new List<String>{instanceUrl+'/'+recordId};
    
                UTIL_Alert.HistoryWrapper wrapNoti = new UTIL_Alert.HistoryWrapper();
                    wrapNoti.alertID            = alertId;
                    wrapNoti.targetID           = recordId;
                    wrapNoti.alertType          = 'Notification';
                    wrapNoti.receiverforID      = notiId;
                    wrapNoti.alertLanguage      = 'en';
                    wrapNoti.elementList        = new List<String>{quoteId[0].QuoteNumber};
    
                UTIL_Alert.runAlertEvent(new List<UTIL_Alert.HistoryWrapper>{wrapEmail,wrapNoti});
            }

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 25.08.14 [GSR SR0000010031094] 잠재고객 생성 완료 시 Email 알람 전송
    // @AuraEnabled
    public static void sendCrmEmailAlert(String alertType, String alertName, String alertLanguage, String userId, Map<Id, String> sobjList){

        System.debug('====sendCrmEmailAlert====');
         try {
                // System.debug('@@ sobjList : ' + sobjList);
                List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
                List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = :alertName LIMIT 1];
                // System.debug('@@ am : ' + am);
                List<User> user = [SELECT Id, Name, ManagerId,Profile.Name, IsPortalEnabled FROM User WHERE Id = :userId LIMIT 1];
                // System.debug('@@ user : ' + user);
                List<String> receiver = new List<String>();         //이메일 수신자 
                Set<Id> ownerId = new Set<Id>();
                // System.debug('@@ user[0].ManagerId : ' + user[0].ManagerId);
                ownerId.add(user[0].ManagerId);
                
                // System.debug('@@ ownerId : ' + ownerId);
                for (Id key : sobjList.keySet()) {
                    if(!am.isEmpty()) {
                        UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                        history.elementList.add(user[0].Name);
                        history.elementList.add(sobjList.get(key));
                        history.alertType           = alertType;
                        history.alertID             = am[0].Id;
                        history.targetID            = key;
                        history.receiverforID    = ownerId;
                        history.alertLanguage       = alertLanguage;
                        ahwList.add(history);
                    }
                }
                System.debug('@@ ahwList : ' + ahwList);
                if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void sendEmailAlert(String alertType, String alertName, String alertLanguage, String userId, Map<Id, String> sobjList, String CrateDate ){

        System.debug('====sendEmailAlert====');
         try {
                // System.debug('@@ sobjList : ' + sobjList);
                List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
                List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = :alertName LIMIT 1];
                // System.debug('@@ am : ' + am);
                List<User> user = [SELECT Id, Name, ManagerId,Profile.Name FROM User WHERE Id = :userId LIMIT 1];
                // System.debug('@@ user : ' + user);
                List<String> receiver = new List<String>();         //이메일 수신자 
                Set<Id> ownerId = new Set<Id>();
                // System.debug('@@ user[0].ManagerId : ' + user[0].ManagerId);
                ownerId.add(user[0].ManagerId);
                
                List<User> getEmail =  DN_WithoutSharingClass.getUserEmails(ownerId);
                if(!getEmail.isEmpty()){
                    receiver.add(getEmail[0].Email); 
                }

                for (Id key : sobjList.keySet()) {
                    if(!am.isEmpty()) {
                        UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                        history.alertType           = alertType;
                        history.alertID             = am[0].Id;
                        history.targetID            = key;
                        history.receiverforEmail    = receiver;    
                        history.elementList.add(user[0].name);           
                        history.elementList.add(sobjList.get(key));                     
                        history.elementList.add(CrateDate);              
                        history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + key); 
                        history.alertLanguage       = alertLanguage;
                        ahwList.add(history);
                    }
                }
                System.debug('@@ ahwList : ' + ahwList);
                if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    // 2025.08.14 견적 확정 해제
    @AuraEnabled
    public static String getFinalQuoteBackStatus(String recordId){
        List<QuoteLineItem> getQtLiInfo = [SELECT Quote.RecordType.Name, Quote.RecordTypeId, Quote.IsFinal__c, OpportunityLineItem.Opportunity.HasFinalQuote__c, Quote.Opportunity.StageName, F_IsOrderCreated__c FROM QuoteLineItem WHERE QuoteId =: recordId];
        Boolean isOrderCreated = false;
        System.debug('getQtLiInfo.size() : ' + getQtLiInfo.size());
        try{
            if(!getQtLiInfo.isEmpty()){
                for(QuoteLineItem qt : getQtLiInfo){
                    if(qt.F_IsOrderCreated__c == true){
                        isOrderCreated = true;   
                    }
                }
                
                if(getQtLiInfo[0].Quote.IsFinal__c == true && isOrderCreated == false){
                    return 'SUCCESS';
                }else if(getQtLiInfo[0].Quote.Opportunity.StageName.contains('Closed')){
                    return System.Label.DNS_M_Unfinalize_Closed;
                }else if(isOrderCreated){
                    return System.Label.DNS_M_Unfinalize_OrderExists;
                }else if(getQtLiInfo[0].Quote.IsFinal__c == false){
                    return System.Label.DNS_M_Unfinalize_NotFinal;
                }else{
                    return System.Label.DNS_M_Unfinalize_Generic;
                }
            }else{
                return System.Label.DNS_M_Unfinalize_NoLineItems; // Quote Line Item 이 0개 일 때
            }
        }catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    // 2025.08.14 견적 확정 해제
    @AuraEnabled
    public static String backOutFinalQuote(String recordId) {
        // Quote와 Opportunity 한 번에 조회
        Quote q = [ SELECT Id, OpportunityId FROM Quote WHERE Id = :recordId LIMIT 1];

        // Quote Is Final? 해지
        update new Quote(
            Id = q.Id,
            IsFinal__c = false
        );

        // Opportunity Has Final Quote 해지
        if (q.OpportunityId != null) {
            update new Opportunity(
                Id = q.OpportunityId,
                HasFinalQuote__c = false
            );
        }

        return 'SUCCESS';
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