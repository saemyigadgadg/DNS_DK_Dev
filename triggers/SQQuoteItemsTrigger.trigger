/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 02-14-2025
 * @last modified by  : Hanyeong Choi
**/
trigger SQQuoteItemsTrigger on SQ_QuoteLineitem_Junction__c (after insert, before update, after update, before delete, after delete) {
    TriggerManager.prepare()
    .bind(new SQQuoteItemsTriggerHandler())
    .execute();
}