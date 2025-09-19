/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-18-2024
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   06-18-2024   Hanyeong Choi   Initial Version
**/
trigger OrderTrigger on Order (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new OrderTriggerHandler())
    .execute(); 
}