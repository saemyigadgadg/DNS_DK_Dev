/**
* @Class : TicketEscalationRuleTriggerHandler
* @Version : 1.0
* @description : Ticket Escalation Rule 등록시 자동 Rule Index 부여 Trigger
*/
public with sharing class TicketEscalationRuleTriggerHandler extends TriggerHandler{

    public override void onBeforeInsert(List<sObject> news){
        try {
            if (isExecuting) {   
                // Rule 생성할 때 현재 생성된 Rule Index 가 어디까지 만들어져있는지 확인 후 다음 Index 값으로 처리             
                List<TicketEscalationRule__c> erList   = (List<TicketEscalationRule__c>) news;
                Map<String, Decimal> maxIndexMap = new Map<String, Decimal>();

                List<AggregateResult> existERList = [
                    SELECT EscalationLv__c, MAX(IndexNumber__c) maxIndex
                    FROM TicketEscalationRule__c
                    WHERE IsActive__c = true
                    GROUP BY EscalationLv__c
                ];

                for (AggregateResult ar : existERList) {
                    String escLevel = (String) ar.get('EscalationLv__c');
                    Decimal maxIndex = (ar.get('maxIndex') != null) ? (Decimal) ar.get('maxIndex') : 0;
                    maxIndexMap.put(escLevel, maxIndex);
                }

                for (TicketEscalationRule__c obj : erList) {
                    Decimal currentMaxIndex = maxIndexMap.containsKey(obj.EscalationLv__c) ? maxIndexMap.get(obj.EscalationLv__c) : 0;
                    obj.IndexNumber__c = currentMaxIndex + 1;

                    // Map의 최대값도 갱신
                    maxIndexMap.put(obj.EscalationLv__c, obj.IndexNumber__c);
                }
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}