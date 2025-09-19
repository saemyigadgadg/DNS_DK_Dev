@isTest
public with sharing class DN_TicketEscalationRuleTest {
    @isTest
    static void testGetRecordInfo(){        
        Test.startTest();
        DN_TicketEscalationRule.executeBatch('test');
        Test.stopTest();
    }
}