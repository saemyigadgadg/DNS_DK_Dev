public class DN_TicketEscalationRule {
    @AuraEnabled
    public static void executeBatch(String recordId) {
        System.debug('배치 실행');
        Id currentUserId = [SELECT Id, Division, Profile.name FROM User WHERE Id = :UserInfo.getUserId()].Id;
        DN_TicketEscalationRuleBatch batchInstance = new DN_TicketEscalationRuleBatch(recordId, currentUserId);
        Database.executeBatch(batchInstance, 1);
    }
}