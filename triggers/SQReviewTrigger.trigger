/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 11-08-2024
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-08-2024   Hanyeong Choi   Initial Version
**/
trigger SQReviewTrigger on SQReview__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new SQReviewTriggerHandler())
    .execute();
}