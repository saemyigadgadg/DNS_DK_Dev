/**
 * @description       : User Trigger
 * @author            : Joohyun Lee
 * @group             : 
 * @last modified on  : 07-02-2024
 * @last modified by  : Joohyun Lee
**/

trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new UserTriggerHandler())
    .execute(); 
}