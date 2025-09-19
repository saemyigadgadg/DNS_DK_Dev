/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-24-2024
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-24-2024   Hanyeong Choi   Initial Version
**/
trigger CustomerDealerAssociationTrigger on DNS_CustomerDealerAssociation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerManager.prepare()
    .bind(new DealerAssociationTriggerHandler())
    .execute();
}