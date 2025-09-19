/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2024-10-10
 * @last modified by  : suheon.ha@sobetec.com
**/
trigger ResourceAbsenceTrigger on ResourceAbsence (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new ResourceAbsenceTriggerHandler())
    .execute(); 
}