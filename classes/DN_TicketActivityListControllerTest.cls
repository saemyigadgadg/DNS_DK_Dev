/**
 * @description       : DN_TicketActivityListControllerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_TicketActivityListControllerTest {
    @TestSetup
    static void makeData(){
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

        STT__c stt = new STT__c();
        stt.STTDescription__c = 'TEST';
        insert stt;


        String serviceId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        List<Task> taskList = new List<Task>();

        Task task1 = new Task();
        task1.ActivityDate = Date.newInstance(2025, 6, 20);
        task1.ConsultationTypeMajor__c = 'Failure Receipt';
        task1.TaskSubtype = 'Call';
        task1.STT__c = stt.Id;
        task1.Matrix_Is_Ans__c = TRUE;
        task1.Matrix_Phone_Number__c = '00000000000';
        task1.Matrix_Call_Type__c = 'Inbound';
        task1.Matrix_Answered_At__c = Date.newInstance(2025, 6, 20);
        task1.Matrix_Updated_At__c = Date.newInstance(2025, 6, 20);
        task1.WhatId = technicalTicket.Id;
        task1.RecordTypeId = serviceId;
        taskList.add(task1);

        Task task2 = new Task();
        task2.ActivityDate = Date.newInstance(2025, 6, 20);
        task2.ConsultationTypeMajor__c = 'Failure Receipt';
        task2.TaskSubtype = 'Call';
        task2.STT__c = stt.Id;
        task2.Matrix_Is_Ans__c = TRUE;
        task2.Matrix_Phone_Number__c = '00000000000';
        task2.Matrix_Call_Type__c = 'Inbound';
        task2.WhatId = technicalTicket.Id;
        task2.RecordTypeId = serviceId;
        taskList.add(task2);

        insert taskList;
    }

    @isTest
    static void testConsultationList(){   
        Case ticket = [SELECT Id FROM Case LIMIT 1];     
        Test.startTest();
        DN_TicketActivityListController.getActivityList(ticket.Id);
        DN_TicketActivityListController.getAllActivityList(ticket.Id);
        Test.stopTest();
    }
}