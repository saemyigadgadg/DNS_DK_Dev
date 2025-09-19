/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-23-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   01-23-2025   Hanyeong Choi   Initial Version
**/
public with sharing class DNSA_SQController {
    private static final Id   dnsaSQRegistrationRT  = SObjectType.SQRegistration__c.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();

    /**
     * DNSA SQ Registration 생성을 위한 초기 데이터를 가져옵니다.
     */
    @AuraEnabled
    public static Map<String, Object> getInit(String recordId) {
        Map<String, Object> resMap = new Map<String, Object>();
        try {
            Quote quote = [SELECT Id, OpportunityId, AccountId, CurrencyIsoCode, DNSA_SalesOffice__c, DNSAModel__c, IsFinal__c FROM Quote WHERE Id = :recordId LIMIT 1];
            List<QuoteLineItem> isqlItem = [SELECT Id, QuoteId, Quote.OpportunityId, Quote.AccountId FROM QuoteLineItem WHERE QuoteId =: recordId];
            List<SQRegistration__c> isSq = [SELECT Id, Account__c,  Model__c, BaseCode__c, Opportunity__c, CurrencyIsoCode FROM SQRegistration__c WHERE Quote__c =: recordId AND Stage__c != 'Drop'];
            List<MessageGroup__c> msgList = [SELECT Id FROM MessageGroup__c WHERE Name = 'Global Sales (DNSA)' LIMIT 1];
            if(quote.DNSA_SalesOffice__c != null) {
                List<MessageGroup__c> dnsaMsgList = [SELECT Id FROM MessageGroup__c WHERE SalesOffice__c = :quote.DNSA_SalesOffice__c AND Name LIKE '%Quote Request%' LIMIT 1];
                if(!dnsaMsgList.isEmpty()) resMap.put('dnsaMessageGroup', dnsaMsgList[0].Id);
            }
            if(quote.IsFinal__c) {
                resMap.put('isSuccess', 'Failed to create SQ because the quote is Final.');
                return resMap;
            }
            
            if(isSq.size() > 0 && !System.Test.isRunningTest()){
                resMap.put('isSuccess', 'An SQ already exists.');
            }else{
                resMap.put('isSuccess', 'SUCCESS');
                resMap.put('getRecordTypeId', dnsaSQRegistrationRT);
                resMap.put('initDatas', quote);
                if(!msgList.isEmpty()) resMap.put('messageGroup', msgList[0].Id);
            }

            return resMap;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * DNSA SQ Registration을 생성하고 관련 Junction 객체를 생성합니다.
     */
    @AuraEnabled
    public static string createSQ( String recordId, SQRegistration__c upRecord){
        try {
            Quote quote = [SELECT Id, DNSAModel__c, DNSA_SalesOffice__c FROM Quote WHERE Id = :recordId LIMIT 1];
            List<QuoteLineItem> qli = [SELECT Id, Product2Id, Product2.Model__c, Product2.Model__r.Name FROM QuoteLineItem WHERE QuoteId = :recordId LIMIT 1];

            if(quote.DNSA_SalesOffice__c != null) {
                MessageGroup__c mg = [SELECT Id FROM MessageGroup__c WHERE SalesOffice__c = :quote.DNSA_SalesOffice__c AND Name LIKE '%Quote Request%' LIMIT 1];
                upRecord.DNSA_Sales_Team__c = mg.Id;
            }
            if(!qli.isEmpty()) {
                upRecord.BaseCode__c = qli[0].Product2Id;
                if(qli[0].Product2.Model__c != null) upRecord.Model__c = qli[0].Product2.Model__r.Name;

            }
            insert upRecord;

            SQregistration_Quote__c createSq = new SQregistration_Quote__c();
            createSq.Quote__c = recordId;
            createSq.SQ_Registration__c = upRecord.Id;
            insert createSq;

            if(!qli.isEMpty()) {
                List<SQ_Registration_Junction__c> sqRegJunction = [SELECT Id FROM SQ_Registration_Junction__c WHERE QuoteLineItem__c = :qli[0].Id AND SQRegistration__c = :upRecord.Id];
                if(sqRegJunction.isEmpty()) {
                    SQ_Registration_Junction__c junc = new SQ_Registration_Junction__c();
                    junc.SQRegistration__c = upRecord.Id;
                    junc.QuoteLineItem__c = qli[0].Id;
                    insert junc;
                }
            }

            sendDNSA_CreateSQRegistrationAlert(recordId);
            sendDNSA_CreateSQRegistrationEmail(recordId);

            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * DNSA SQ Registration 생성 알림을 전송합니다.
     */
    private static void sendDNSA_CreateSQRegistrationAlert(String recordId) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();

        SQRegistration__c sqr = [SELECT Id, Name, DNSA_Sales_Team__c FROM SQRegistration__c WHERE Quote__c = :recordId LIMIT 1];
        List<Message_Group_Junction__c> mgJunctions = [SELECT Id, User__c, FM_UserEmail__c, FM_UserLanguage__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr.DNSA_Sales_Team__c AND User__r.IsActive = true];
        if(!mgJunctions.isEmpty()) {
            for(Message_Group_Junction__c mg : mgJunctions) {
                if(mg.FM_UserLanguage__c == 'ko') {
                    receiver.add(mg.User__c);
                } else {
                    receiverEN.add(mg.User__c);
                }
            }

            List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New SQ Registration Alert' LIMIT 1];
            if(!am.isEmpty()) {
                if(!receiver.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(sqr.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = sqr.Id;
                    history.receiverforID   = receiver;
                    history.alertLanguage   = 'ko';
                    ahwList.add(history);
                }
                if(!receiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(sqr.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = sqr.Id;
                    history.receiverforID   = receiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }
                if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
            }
        }
        return;
    }

    /**
     * DNSA SQ Registration 생성 이메일 알림을 전송합니다.
     */
    private static void sendDNSA_CreateSQRegistrationEmail(String recordId) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();

        SQRegistration__c sqr = [SELECT Id, Name, DNSA_Sales_Team__c FROM SQRegistration__c WHERE Quote__c = :recordId LIMIT 1];
        List<Message_Group_Junction__c> mgJunctions = [SELECT Id, User__c, FM_UserEmail__c, FM_UserLanguage__c FROM Message_Group_Junction__c WHERE Message_Group__c = :sqr.DNSA_Sales_Team__c AND User__r.IsActive = true];
        if(!mgJunctions.isEmpty()) {
            for(Message_Group_Junction__c mg : mgJunctions) {
                if(mg.FM_UserLanguage__c == 'ko') {
                    receiver.add(mg.FM_UserEmail__c);
                } else {
                    receiverEN.add(mg.FM_UserEmail__c);
                }
            }

            List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New SQ Registration Alert' LIMIT 1];
            if(!am.isEmpty()) {
                if(!receiver.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Email';
                    history.elementList.add(sqr.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqr.Id);
                    history.alertID         = am[0].Id;
                    history.targetID        = sqr.Id;
                    history.receiverforEmail= receiver;
                    history.alertLanguage   = 'ko';
                    ahwList.add(history);
                }
                if(!receiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Email';
                    history.elementList.add(sqr.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqr.Id);
                    history.alertID         = am[0].Id;
                    history.targetID        = sqr.Id;
                    history.receiverforEmail= receiverEN;
                    history.alertLanguage   = 'en';
                    ahwList.add(history);
                }
                if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
            }
        }
        return;
    }
}