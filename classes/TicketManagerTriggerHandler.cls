/**
* @Class : TicketManagerTriggerHandler
* @Version : 1.0
* @description : Ticket Escalation Rule 내 Ticket Manager 등록 Validation Trigger
*/
public with sharing class TicketManagerTriggerHandler extends TriggerHandler{
    public override void onBeforeInsert(List<sObject> news){
        try {
            if (isExecuting) {                
                List<TicketManager__c> tmList = (List<TicketManager__c>) news;
                Set<Id> tmIds = new Set<Id>();
    
                for (TicketManager__c tm : tmList) {
                    if (tm.TicketEscalationRule__c != null) {
                        System.debug('tm.TicketEscalationRule__c'+tm.TicketEscalationRule__c);
                        tmIds.add(tm.TicketEscalationRule__c);
                    }
                }
                System.debug('tmIds'+tmIds);
    
                if (!tmIds.isEmpty()) {
                    Integer existingCount = [SELECT COUNT() FROM TicketManager__c WHERE TicketEscalationRule__c IN :tmIds];
                    System.debug('existingCount'+existingCount);

                    if (existingCount > 0) {
                        for (TicketManager__c tm : tmList) {
                            tm.addError('이미 Ticket Manager 가 등록되어 있습니다.');
                        }
                    }
                }
            }
            } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}