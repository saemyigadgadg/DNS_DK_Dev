/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-29-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class FeedItemTriggerHandler extends TriggerHandler {
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
        System.debug('FeedItemTriggerHandler_onAfterInsert');
        
        List<Id> woIds = new List<Id>();

        for (FeedItem feed : (List<FeedItem>)news) {
            if (feed.ParentId.getSObjectType() == WorkOrder.SObjectType && feed.Type == 'TextPost') {
                woIds.add(feed.ParentId);
            }
        }
        Map<Id, WorkOrder> woDataMap = new Map<Id, WorkOrder>([
            SELECT Id, CaseId, ServiceOrderNumber__c 
            FROM WorkOrder 
            WHERE Id IN :woIds
        ]);

        Map<Id, Id> woCaseMap = new Map<Id, Id>();
        for (WorkOrder wo : [SELECT Id, CaseId FROM WorkOrder WHERE Id IN :woIds AND RecordType.Name = 'Work Order Record Type']) {
            if (wo.CaseId != null) {
                woCaseMap.put(wo.Id, wo.CaseId);
            }
        }

        Map<Id, Id> caseOwnerMap = new Map<Id, Id>();
        for (Case c : [SELECT Id, OwnerId FROM Case WHERE Id IN :woCaseMap.values()]) {
            caseOwnerMap.put(c.Id, c.OwnerId);
        }

        List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();
        String alertManagerID = [
            SELECT Id FROM AlertManager__c WHERE IsActive__c = true AND Name = 'CS Feed Noti' LIMIT 1
        ].Id;


        for (FeedItem feed : (List<FeedItem>)news) {
            Id caseId = woCaseMap.get(feed.ParentId);
            Id caseOwnerId = caseOwnerMap.get(caseId);
            String cleanBody = removeHtmlTags(feed.Body);

            UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
            hw.alertID = alertManagerID;
            hw.targetID = feed.ParentId;
            hw.alertType = 'Notification';
            hw.alertLanguage = 'ko';
            hw.elementList.add(woDataMap.get(feed.ParentId).ServiceOrderNumber__c); // Null처리
            // hw.elementList.add(feed.CreatedBy.Name);
            hw.elementList.add(cleanBody);
            hw.title = 'Service Order: ' + woDataMap.get(feed.ParentId).ServiceOrderNumber__c + ' 피드가 추가되었습니다.';
            hw.receiverforID = new Set<Id>{ caseOwnerId };

            hwList.add(hw);
        }

        if (!hwList.isEmpty()) {
            UTIL_Alert.runAlertEvent(hwList);
            System.debug('Notification Sent for Ticket Owner');
        }
    }
    // HTML 태그 제거 함수
    public static String removeHtmlTags(String html) {
        if (String.isEmpty(html)) {
            return '';
        }
        return html.replaceAll('<.*?>', '');
    }
}