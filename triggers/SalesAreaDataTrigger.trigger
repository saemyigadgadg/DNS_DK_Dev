/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   10-22-2024   Hanyeong Choi   Initial Version
**/
trigger SalesAreaDataTrigger on SalesAreaData__c (before insert, before update, before delete, after insert, after update, after delete) {
    TriggerManager.prepare()
    .bind(new SalesAreaDataTriggerHandler())
    .execute(); 
}