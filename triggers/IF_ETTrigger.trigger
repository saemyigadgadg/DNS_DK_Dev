/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-10
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-04-10   yuhyun.park@sbtglobal.com   Initial Version
**/

trigger IF_ETTrigger on IF_ET__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new IF_ETTriggerHandler())
    .execute(); 
}