@isTest
public with sharing class DN_TicketEscalationRuleIndexTest {

    @TestSetup
    static void makeData(){
        TicketEscalationRule__c ter1 = new TicketEscalationRule__c(IsActive__c = true, EscalationLv__c = 'Esc.Lev 1');
        insert ter1;
        TicketEscalationRule__c ter2 = new TicketEscalationRule__c(IsActive__c = true, EscalationLv__c = 'Esc.Lev 2');
        insert ter2;
        TicketEscalationRule__c ter3 = new TicketEscalationRule__c(IsActive__c = true, EscalationLv__c = 'Esc.Lev 3');
        insert ter3;
        TicketEscalationRule__c ter4 = new TicketEscalationRule__c(IsActive__c = true, EscalationLv__c = 'Esc.Lev 4');
        insert ter4;
    }

    @isTest
    static void testGetRecordInfo(){

        List<TicketEscalationRule__c> terList = [
            SELECT Id, IsActive__c, EscalationLv__c, IndexNumber__c
            FROM TicketEscalationRule__c
            WHERE IsActive__c = true
        ];

        String strTerList = JSON.serialize(terList);

        Test.startTest();
        DN_TicketEscalationRuleIndex.getLevelData('Esc.Lev 1');
        DN_TicketEscalationRuleIndex.getLevelData('Esc.Lev 2');
        DN_TicketEscalationRuleIndex.getLevelData('Esc.Lev 3');
        DN_TicketEscalationRuleIndex.getLevelData('Esc.Lev 4');
        DN_TicketEscalationRuleIndex.saveEscIndex(strTerList);
        Test.stopTest();
    }
}