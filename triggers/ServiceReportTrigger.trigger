/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2024-12-20
 * @last modified by  : suheon.ha@sobetec.com
**/
trigger ServiceReportTrigger on ServiceReport (before insert, before update, after insert, after update) {
    TriggerManager.prepare()
    .bind(new ServiceReportTriggerHandler())
    .execute(); 
}