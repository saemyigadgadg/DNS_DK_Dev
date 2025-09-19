/**
 * @author            : yeongju.yun
 * @last modified on  : 2024-11-04
 * @last modified by  : yeongju.yun 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-11-04   yeongju.yun   Initial Version
**/
trigger PreparationCheckListTrigger on PreparationCheckList__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new PreparationCheckListTriggerHandler())
    .execute(); 
}