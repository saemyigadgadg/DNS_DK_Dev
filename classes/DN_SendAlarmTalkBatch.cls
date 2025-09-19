/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2024-12-10
 * @last modified by  : yeongdeok.seo@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-12-10   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_SendAlarmTalkBatch implements Database.Batchable<Object>, Database.Stateful, Database.AllowsCallouts, Schedulable{
    public List<UTIL_Alert.historyWrapper> wrappers;
    public List<DN_HappyCallBatch.CampaignTargetWrapper> ctwrappers;

    public DN_SendAlarmTalkBatch() {}

    public List<Object> start(Database.BatchableContext context) {
        System.debug('wrappers: ' + wrappers);
        return this.wrappers != null ? this.wrappers : new List<Object>();
    }

    public void execute(Database.BatchableContext context, List<Object> scope) {
        List<UTIL_Alert.historyWrapper> wrapperList = new List<UTIL_Alert.historyWrapper>();
        for (Object obj : scope) {
            wrapperList.add((UTIL_Alert.historyWrapper)obj);
        }

        UTIL_Alert.runAlertEvent(wrapperList);
        System.debug('wrappers => ' + wrappers);
        System.debug('ctwrappers => ' + ctwrappers);

        if (ctwrappers == null) return;

        Set<Id> ctIds = new Set<Id>();
        for (DN_HappyCallBatch.CampaignTargetWrapper ctWrapper : ctwrappers) {
            if (ctWrapper.Id != null) {
                ctIds.add(ctWrapper.Id);
            }
        }
        
        Datetime firstSendTime       = Datetime.valueOf(System.now());
        String formatFirstSendTime   = firstSendTime.format('yyyy-MM-dd HH:mm:ss');
        List<CampaignTarget__c> ctList = [SELECT Id, FirstSendTime__c, AlarmTalkFirstSend__c FROM CampaignTarget__c WHERE Id =: ctIds];
        List<CampaignTarget__c> updateCTList = new List<CampaignTarget__c>();
        for(CampaignTarget__c ct : ctList) {
            ct.AlarmTalkFirstSend__c     = true;
            ct.FirstSendTime__c          = formatFirstSendTime;
            updateCTList.add(ct);
        }

        if(updateCTList.size() > 0) update updateCTList;
    }

    public void finish(Database.BatchableContext context) {
        System.debug('알람톡 실행 완료');
    }

    public void execute(SchedulableContext sc) {
        System.debug('sc ' + sc);
        DN_SendAlarmTalkBatch batch = new DN_SendAlarmTalkBatch();
        batch.wrappers = wrappers;
        batch.ctwrappers = ctwrappers;
        System.debug('wrappers2 ' + wrappers);
        Database.executeBatch(batch, 10);
    }
}