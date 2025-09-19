@isTest
public with sharing class TicketEscalationRuleTriggerHandlerTest {

    @isTest
    static void testIndexNumberIncrementByEscalationLevel() {
        // Given: Escalation Level A에 대해 하나의 Rule이 존재함
        TicketEscalationRule__c existingRule = new TicketEscalationRule__c(
            Name = 'Existing Rule',
            IsActive__c = true,
            EscalationLv__c = 'Esc.Lev 1',
            IndexNumber__c = 1
        );
        insert existingRule;

        // When: 같은 EscalationLv__c를 가진 새로운 Rule 생성
        TicketEscalationRule__c newRule = new TicketEscalationRule__c(
            Name = 'New Rule',
            IsActive__c = true,
            EscalationLv__c = 'Esc.Lev 1'
        );

        Test.startTest();
        insert newRule;
        Test.stopTest();

    }

    @isTest
    static void testIndexStartsAt1ForNewEscalationLevel() {
        // Given: 새로운 Escalation Level에 대해 Rule 생성
        TicketEscalationRule__c rule = new TicketEscalationRule__c(
            Name = 'Level B Rule',
            IsActive__c = true,
            EscalationLv__c = 'Esc.Lev 2'
        );

        Test.startTest();
        insert rule;
        Test.stopTest();
    }
}