/**
 * @author            : yeongju.yun
 * @last modified on  : 2024-10-29
 * @last modified by  : yeongju.yun 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-10-29   yeongju.yun   Initial Version
**/
trigger OrderItemTrigger on OrderItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new OrderItemTriggerHandler())
    .execute(); 
}