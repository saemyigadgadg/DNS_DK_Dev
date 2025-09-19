trigger SQRegistrationTrigger on SQRegistration__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new SQRegistrationTriggerHandler())
    .execute();
}