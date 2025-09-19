trigger OpptyCompetitorMappingTrigger on OpptyCompetitorMapping__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new OpptyCompetitorMappingTriggerHandler())
    .execute();
}