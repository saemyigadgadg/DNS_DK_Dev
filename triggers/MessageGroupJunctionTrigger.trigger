trigger MessageGroupJunctionTrigger on Message_Group_Junction__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new MessageGroupJunctionTriggerHandler())
    .execute(); 
}