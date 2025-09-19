/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2025-05-26
 * @last modified by  : yeongju.yun
**/
public with sharing class ContentDocumentTriggerHandler extends TriggerHandler {

    /**
     * @Description
     * 	- ContentDocument Before Delete
     * @author suheon.ha | 2025-05-26
    **/ 
    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap) {
        if (isExecuting) {
            System.debug('ContentDocument BEFORE_DELETE FILE COUNT TRIGGER Start');

            Set<Id> cdIds = new Set<Id>();
            Set<Id> caseIds = new Set<Id>();
            for (ContentDocument doc : (List<ContentDocument>) dels) {
                cdIds.add(doc.Id);
            }
            System.debug('cdIds::: ' + cdIds);

            List<ContentDocumentLink> cvList = [
                SELECT LinkedEntityId, ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE ContentDocumentId IN :cdIds
            ];
            System.debug('cvList::: ' + cvList);

            for (ContentDocumentLink cv : cvList) {
                if (cv.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Case') {
                    caseIds.add(cv.LinkedEntityId);
                }
            }
            System.debug('caseIds::: ' + caseIds);

            List<Case> caseList = [SELECT Id, FileCount__c FROM Case WHERE Id IN :caseIds];
            System.debug('caseList::: ' + caseList);

            List<Case> updateCaseList = new List<Case>();
            for (Case ticket : caseList) {
                System.debug('Processing Case: ' + ticket.Id + ', Current FileCount__c: ' + ticket.FileCount__c);

                Integer count = ((ticket.FileCount__c - 1) < 0 ? 0 : (ticket.FileCount__c - 1).intValue());
                System.debug('Updated FileCount__c Case: ' + ticket.Id + ' -> ' + count);
                
                ticket.FileCount__c = count;
                updateCaseList.add(ticket);
            }
            System.debug('Cases Update: ' + updateCaseList);

            if (updateCaseList.size() > 0) update updateCaseList;

            System.debug('ContentDocument BEFORE_DELETE FILE COUNT TRIGGER End');
        }
    }
}