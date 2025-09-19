/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-06-14
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-14   yuhyun.park@sbtglobal.com   Initial Version
**/
trigger RequestToUseCustomerTrigger on DNS_RequestToUseCustomer__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
        .bind(new RequestToUseCustomerTriggerHandler())
        .execute();
}