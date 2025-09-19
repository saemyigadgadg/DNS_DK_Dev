/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 02-03-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   02-03-2025   Hanyeong Choi   Initial Version
**/
trigger AccessoryTrigger on Accessory__c (after insert, after update) {
    TriggerManager.prepare()
    .bind(new AccessoryTriggerHandler())
    .execute();
}