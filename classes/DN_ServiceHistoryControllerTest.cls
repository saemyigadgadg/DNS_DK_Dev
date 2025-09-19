/**
 * @description       : DN_ServiceHistoryControllerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_ServiceHistoryControllerTest {
    @TestSetup
    static void makeData(){
        List<OperatingHours> hoursList = TestDataFactoryForService.createOperatingHours();
        insert hoursList;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);
        insert resource;

        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;

        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        insert account;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        WorkOrder workOrder1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', territory.Id, resource.Id);
        insert workOrder1;
    }

    @isTest
    static void testMethods(){       
        Case ticket = [SELECT Id FROM Case LIMIT 1]; 
        Test.startTest();
        DN_ServiceHistoryController.getServiceHistory(ticket.Id, true, false);
        DN_ServiceHistoryController.getServiceHistory(ticket.Id, false, true);
        DN_ServiceHistoryController.getServiceHistory('Exception', false, true);

        DN_ServiceHistoryController.getNotClosedServiceHistory(ticket.Id, true, false);
        DN_ServiceHistoryController.getNotClosedServiceHistory(ticket.Id, false, true);
        DN_ServiceHistoryController.getNotClosedServiceHistory('Exception', false, true);

        DN_ServiceHistoryController.getSameFailureHistory(ticket.Id, true, false);
        DN_ServiceHistoryController.getSameFailureHistory(ticket.Id, false, true);
        DN_ServiceHistoryController.getSameFailureHistory('Exception', false, true);
        Test.stopTest();
    }
}