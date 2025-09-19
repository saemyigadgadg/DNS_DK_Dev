/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-14-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
trigger FeedItemTrigger on FeedItem (after insert) {
    TriggerManager.prepare()
    .bind(new FeedItemTriggerHandler())
    .execute(); 
}