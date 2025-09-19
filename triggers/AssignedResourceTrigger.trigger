trigger AssignedResourceTrigger on AssignedResource (after insert, after update) {
    TriggerManager.prepare()
    .bind(new AssignedResourceTriggerHandler())
    .execute(); 
}