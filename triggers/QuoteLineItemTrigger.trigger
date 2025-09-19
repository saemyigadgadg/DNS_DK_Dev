/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 12-08-2024
 * @last modified by  : Hanyeong Choi
**/
trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new QuoteLineItemTriggerHandler())
    .execute();
}