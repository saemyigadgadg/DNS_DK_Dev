/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2025-02-03
 * @last modified by  : suheon.ha@sobetec.com
**/
trigger AssetTrigger on Asset (before insert, after update, before update) {
    TriggerManager.prepare()
    .bind(new AssetTriggerHandler())
    .execute();
}