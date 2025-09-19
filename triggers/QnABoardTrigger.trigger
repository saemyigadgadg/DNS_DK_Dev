/**
 * @description       : (포탈) Support > [T]Q&A
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 04-09-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-31-2025   daewook.kim@sbtglobal.com   Initial Version
**/
trigger QnABoardTrigger on QnABoard__c (before insert, after insert, before update, after update) {
    TriggerManager.prepare()
    .bind( new QnABoardTriggerHandler() )
    .execute();
}