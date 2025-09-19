@isTest
public with sharing class TicketManagerTriggerHandlerTest {
    @isTest
    static void makeData(){
        TicketEscalationRule__c ter = new TicketEscalationRule__c();
        ter.Name = 'test';
        insert ter;

        TicketManager__c tm = new TicketManager__c();
        tm.TicketEscalationRule__c = ter.Id;
        insert tm;

        TicketManager__c tm2 = new TicketManager__c();
        tm2.TicketEscalationRule__c = ter.Id;

        Test.startTest();
        Database.SaveResult result = Database.insert(tm2, false);
        Test.stopTest();

    }

    @isTest
    static void makeData2(){
        TicketEscalationRule__c ter = new TicketEscalationRule__c();
        ter.Name = 'test';
        insert ter;

        TicketEscalationRule__c ter2 = new TicketEscalationRule__c();
        ter2.Name = 'test2';
        insert ter2;

        TicketManager__c tm = new TicketManager__c();
        tm.TicketEscalationRule__c = ter.Id;
        insert tm;

        TicketManager__c tm2 = new TicketManager__c();
        tm2.TicketEscalationRule__c = ter2.Id;

        Test.startTest();
        Database.SaveResult result = Database.insert(tm2, false);
        Test.stopTest();

    }
}