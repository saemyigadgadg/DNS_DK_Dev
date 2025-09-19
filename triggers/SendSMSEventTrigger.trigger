trigger SendSMSEventTrigger on SendSMS__e (after insert) {
    for (SendSMS__e obj : Trigger.New) {
        System.debug('SendSMSEventTriggerHandler');
        System.debug('obj.WorkOrderId__c :: '+obj.WorkOrderId__c);
        WorkOrderTriggerHandler.sendSMS(new Set<Id>{obj.WorkOrderId__c});
    }
}