/**
 * @description       : CollaboratorTriggerHandlerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class CollaboratorTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        List<AlertManager__c> amList = new List<AlertManager__c>();
        AlertManager__c am1 = TestDataFactoryForService.createAlertManager('CS Sub Worker Create Noti');
        AlertManager__c am2 = TestDataFactoryForSales.createAlertManager('WorkOrder Assignment Cancel Noti');

        amList.add(am1);
        amList.add(am2);
        insert amList;

        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;
        
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'UserTriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        
        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        account.BusinessNumber__c = '8278100291';
        insert account;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;

        List<OperatingHours> hours = TestDataFactoryForService.createOperatingHours();        
        insert hours;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();       
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);       
        insert resource;

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        User dealer1;
        User dealer2;
        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', korea, null);
            insert dealerAcc;
   
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
   
            dealer1 = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert dealer1;

            dealer2 = TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
            insert dealer2;

            ServiceResource resource2 = TestDataFactoryForService.createResource(territory.Id);
            resource2.Name = 'TEST2';
            resource2.RelatedRecordId = dealer1.Id;
            insert resource2;

            ServiceResource resource3 = TestDataFactoryForService.createResource(territory.Id);
            resource3.Name = 'TEST3';
            resource3.RelatedRecordId = dealer2.Id;
            insert resource3;
        }

        ServiceResource resource2 = [SELECT Id FROM ServiceResource WHERE Name = 'TEST2' LIMIT 1];
        List<WorkOrder> woList = new List<WorkOrder>();
        WorkOrder wo1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', territory.Id, resource.Id);
        WorkOrder wo2 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '202');
        wo2.Worker__c = resource2.Id;
        woList.add(wo1);
        woList.add(wo2);
        insert woList;

        Collaborator__c co = new Collaborator__c();
        co.ServiceResource__c = resource.Id;
        co.WorkOrder__c = wo2.Id;
        insert co;
    }

    @isTest
    static void testTriggerCollaborator(){     
        WorkOrder wo1 = [SELECT Id, Worker__c FROM WorkOrder WHERE OrderType__c = '201' LIMIT 1];
        // WorkOrder wo2 = [SELECT Id, Worker__c FROM WorkOrder WHERE OrderType__c = '202' LIMIT 1];
        ServiceResource resource2 = [SELECT Id FROM ServiceResource WHERE Name = 'TEST2'];
        ServiceResource resource3 = [SELECT Id FROM ServiceResource WHERE Name = 'TEST3'];

        Collaborator__c co = new Collaborator__c();
        co.ServiceResource__c = resource2.Id;
        System.debug('resource2.Id :: '+resource2.Id);
        co.WorkOrder__c = wo1.Id;
        
        Test.startTest();
        insert co;

        co.ServiceResource__c = resource3.Id;
        System.debug('wo1.Worker__c :: '+resource3.Id);

        update co;

        delete co;
        Test.stopTest();
    }

}