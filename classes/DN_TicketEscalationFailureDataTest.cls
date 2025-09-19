@isTest
public with sharing class DN_TicketEscalationFailureDataTest {
    @TestSetup
    static void makeData(){

        TicketEscalationRule__c ter = new TicketEscalationRule__c();
        ter.IsActive__c = true;
        insert ter;
        TicketEscalationRule__c ter2 = new TicketEscalationRule__c();
        ter.IsActive__c = false;
        insert ter2;
        TicketEscalationFailureArea__c tefa = new TicketEscalationFailureArea__c();
        tefa.TicketEscalationRule__c = ter.Id;
        insert tefa;
        TicketEscalationFailureArea__c tefa2 = new TicketEscalationFailureArea__c();
        tefa2.TicketEscalationRule__c = ter.Id;
        insert tefa2;
        TicketEscalationQueue__c teq = new TicketEscalationQueue__c();
        teq.TicketEscalationRule__c = ter.Id;
        insert teq;
        TicketEscalationRole__c terole = new TicketEscalationRole__c();
        terole.TicketEscalationRule__c = ter.Id;
        insert terole;

    }

    @isTest
    static void DN_RegisterCommonParts_Test() {
        TicketEscalationRule__c ter = [SELECT Id FROM TicketEscalationRule__c LIMIT 1];
        TicketEscalationRule__c ter2 = [SELECT Id FROM TicketEscalationRule__c WHERE IsActive__c = False LIMIT 1];
        TicketEscalationFailureArea__c tefa = [SELECT Id FROM TicketEscalationFailureArea__c LIMIT 1];
        TicketEscalationQueue__c teq = [SELECT Id FROM TicketEscalationQueue__c LIMIT 1];
        TicketEscalationRole__c teRole = [SELECT Id FROM TicketEscalationRole__c LIMIT 1];

        Map<String, String> dataMap = new Map<String, String>{
            'selectedObjectType'            => 'Hardware',
            'selectedFailureMain'           => 'Power Issue',
            'selectedFailureMiddle'         => 'Battery',
            'selectedFailurePhenomenon'     => 'Overheating',
            'selectedFailureMainLabel'      => '전원 문제',
            'selectedFailureMiddleLabel'    => '배터리',
            'selectedFailurePhenomenonLabel'=> '과열'
        };
        String jsonData = JSON.serialize(dataMap);

        test.startTest();
        DN_TicketEscalationFailureDataController.initFailureData(ter.Id);
        DN_TicketEscalationFailureDataController.deletefailureArea(tefa.Id);
        DN_TicketEscalationFailureDataController.getObjectType();
        DN_TicketEscalationFailureDataController.initQueueList(ter.Id);
        DN_TicketEscalationFailureDataController.deleteQueue(teq.Id);
        DN_TicketEscalationFailureDataController.getQueueList();
        DN_TicketEscalationFailureDataController.submitQueue(ter.Id, 'Test', 'Test');
        DN_TicketEscalationFailureDataController.initRoleList(ter.Id);
        DN_TicketEscalationFailureDataController.getRoleList();
        DN_TicketEscalationFailureDataController.getPhenomenon('Test', 'Test');
        DN_TicketEscalationFailureDataController.getFailureMain('Test');
        DN_TicketEscalationFailureDataController.getFailureMiddle('Test');
        DN_TicketEscalationFailureDataController.getFailureList(ter.Id);
        DN_TicketEscalationFailureDataController.submitRole(ter.Id, 'Test', 'Test');
        DN_TicketEscalationFailureDataController.submitRole(ter2.Id, 'Test', 'Test');
        DN_TicketEscalationFailureDataController.deleteRole(teRole.Id);
        DN_TicketEscalationFailureDataController.failureSave(jsonData, ter.Id);
        test.stopTest();
    }
}