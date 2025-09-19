public with sharing class dealerTicketRelatedListController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getRelatedRecords(Id accountId, Id userId) {
        User userContactId = [SELECT Id, ContactId FROM User WHERE Id = :userId LIMIT 1];

        return [
            SELECT Id, CaseNumber, Subject, Status
            FROM Case
            WHERE AccountId = :accountId
              AND Requester__c = :userContactId.ContactId
            ORDER BY CreatedDate DESC
        ];
    }
}