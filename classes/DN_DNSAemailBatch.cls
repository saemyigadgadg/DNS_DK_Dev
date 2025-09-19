/**
 * @description       : DNSA Pre-Call 및 Missing Part 시행 확인 메일 배치
 * @author            : junyeong.choi@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-01-22
 * @last modified by  : junyeong.choi@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-22-2025   junyeong.choi@sbtglobal   Initial Version
**/
public with sharing class DN_DNSAemailBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable{
    public String alertId;

    public DN_DNSAemailBatch() {
        this.alertId = [SELECT Id FROM AlertManager__c WHERE Name = 'DNSA Pre-call & Missing Part Email Alert' LIMIT 1].Id;
    }

    public List<SObject> start(Database.BatchableContext context){
        Date today         = Date.today();
        Date oneMonthAgo   = today.addMonths(-1);
        System.debug('oneMonthAgo'+oneMonthAgo);
        return [
            SELECT Id, Equipment__c, SendDate__c, EmailStatus__c, EmailType__c, ElapsedDate__c, Email__c, Reason__c, Equipment__r.Name, Campaign__c, RecentlySendDate__c, Campaign__r.Name
            FROM CampaignAsset__c 
            WHERE (SendDate__c =: oneMonthAgo AND EmailStatus__c IN ('Send')) OR (RecentlySendDate__c =: oneMonthAgo AND EmailStatus__c IN ('Not Completed', 'Remind Confirm'))
            // SELECT Id, Equipment__c, SendDate__c, EmailStatus__c, EmailType__c, ElapsedDate__c, Email__c, Reason__c, Equipment__r.Name, Campaign__c, RecentlySendDate__c, Campaign__r.Name
            // FROM CampaignAsset__c 
            // WHERE EmailStatus__c IN ('Send')
        ];
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.debug(' =============== Batch Execute ================');
        System.debug('scope.Size() : ' + scope.size());
        System.debug('scope : ' + scope);
        Savepoint sp;
        try {
            List<CampaignAsset__c> caList = (List<CampaignAsset__c>) scope;
            String crmBaseUrl = System.Label.DNSA_PRECALL_URL;
            List<CampaignAsset__c> updateList                = new List<CampaignAsset__c>();
            List<PreCallEmailHistory__c> insertHistoryList   = new List<PreCallEmailHistory__c>();
            List<UTIL_Alert.historyWrapper> wrappers         = new List<UTIL_Alert.historyWrapper>();
            Map<Id, String> idFOREmailListMap                = new Map<Id, String>();
            for(CampaignAsset__c ca : caList) {
                if(!idFOREmailListMap.containsKey(ca.Equipment__c)) {
                    idFOREmailListMap.put(ca.Equipment__c, ca.Email__c);
                }
            }

            for(CampaignAsset__c ca : caList) {
                String originalEmail     = idFOREmailListMap.get(ca.Equipment__c);
                List<String> emailList   = originalEmail.split('[,;]');
                String crmURL            = crmBaseUrl + ca.Id;

                for(String singleEmail : emailList) {
                    UTIL_Alert.historyWrapper wrapper = new UTIL_Alert.historyWrapper();
                    wrapper.title              = 'DNSA Pre-Call & Missing Part Confirm Mail';
                    wrapper.alertID            = alertId;
                    wrapper.targetID           = ca.Id;  
                    wrapper.alertType          = 'Email';
                    wrapper.elementList        = new List<String>{ ca.Campaign__r.Name, ca.EmailType__c, String.valueOf(ca.SendDate__c), ca.Equipment__r.Name, crmURL };
                    wrapper.receiverforEmail   = new List<String>{ singleEmail };
                    wrapper.alertLanguage      = 'en';
                    wrappers.add(wrapper);
    
                    PreCallEmailHistory__c eh = new PreCallEmailHistory__c();
                    eh.SendDate__c            = System.now().date();
                    eh.SendTo__c              = ca.Email__c;
                    eh.EmailType__c           = ca.EmailType__c == 'Pre-Call Request' ? 'Pre-Call Confirm' : 'Missing Part Confirm';
                    eh.Campaign__c            = ca.Campaign__c;
                    insertHistoryList.add(eh);
                }

                // Target Equipment 상태 Update
                ca.EmailStatus__c      = 'Remind Confirm';
                ca.RecentlySendDate__c = System.now().date();
                updateList.add(ca);
            }

            // 메일 전송
            System.debug('wrappers'+wrappers);
            UTIL_Alert.runAlertEvent(wrappers);

            if(!updateList.isEmpty()) update updateList;
            if(!insertHistoryList.isEmpty()) insert insertHistoryList;

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
        }
    }
    public void finish(Database.BatchableContext context){
        System.debug('배치실행완료');
    }

    public void execute(SchedulableContext sc) {
        DN_DNSAemailBatch batch = new DN_DNSAemailBatch();
        Database.executeBatch(batch, 200);        
    }
}