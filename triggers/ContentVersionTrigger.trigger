/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2024-11-12
 * @last modified by  : suheon.ha@sobetec.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-12   yeongdeok.seo@sbtglobal.com   Initial Version
**/
trigger ContentVersionTrigger on ContentVersion (before insert, after insert, after delete) {
    // return;
    TriggerManager.prepare()
    .bind(new ContentVersionTriggerHandler())
    .execute(); 
}