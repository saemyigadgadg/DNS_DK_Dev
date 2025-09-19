/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-12-07
 * @last modified by  : yuhyun.park@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-07   yuhyun.park@sbtglobal.com   Initial Version
**/
trigger DealerBonusTrigger on DealerBonus__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new DealerBonusTriggerHandler())
    .execute(); 
}