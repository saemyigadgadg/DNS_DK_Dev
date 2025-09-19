/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 12-16-2024
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-12-2024   Hanyeong Choi   Initial Version
**/
trigger RequestedSQTrigger on RequestedSQ__c (before insert, before update, after insert, after update) {
    TriggerManager.prepare()
    .bind(new RequestedSQTriggerHandler())
    .execute();
}