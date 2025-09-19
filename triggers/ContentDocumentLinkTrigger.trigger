/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2025-01-23
 * @last modified by  : suheon.ha@sobetec.com
**/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, after delete, before delete, before update) {
    // return;
    if(Trigger.isInsert){
        System.debug('testInsert');
    }
    if(Trigger.isDelete){
        System.debug('testDelete');
    }
    TriggerManager.prepare()
    .bind(new ContentDocumentLinkTriggerHandler())
    .execute(); 
}