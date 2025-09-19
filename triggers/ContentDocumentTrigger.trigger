/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2024-12-05
 * @last modified by  : suheon.ha@sobetec.com
**/
trigger ContentDocumentTrigger on ContentDocument (before insert, after insert, before delete, after delete) {
    TriggerManager.prepare()
    .bind(new ContentDocumentTriggerHandler())
    .execute(); 
}