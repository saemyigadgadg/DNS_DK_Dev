@isTest
public with sharing class TaskTriggerHandler_Test {

    @isTest
    static void testOnAfterInsert_OutboundCall_CaseUpdate() {
        Case generalCase = new Case(
            Subject = 'General Inquiry',
            TicketType__c = 'General inquiry'
        );
        insert generalCase;

        Case technicalCase = new Case(
            Subject = 'Technical Inquiry',
            TicketType__c = 'Technical inquiry'
        );
        insert technicalCase;

        Task task1 = new Task(
            Subject = 'Call for General Case',
            WhatId = generalCase.Id,
            CallType__c = 'Outbound Call',
            Matrix_Ring_At__c = DateTime.now().addMinutes(-5),
            Status = 'Completed'
        );

        Task task2 = new Task(
            Subject = 'Call for Technical Case',
            WhatId = technicalCase.Id,
            CallType__c = 'Outbound Call',
            Matrix_Ring_At__c = DateTime.now().addMinutes(-10),
            Status = 'Completed'
        );

        insert new List<Task>{ task1, task2 };

        generalCase = [SELECT Id, GeneralCallDatetime__c, ConsultationTime__c FROM Case WHERE Id = :generalCase.Id];
        technicalCase = [SELECT Id, TechnicalCallDatetime__c, ConsultationTime__c FROM Case WHERE Id = :technicalCase.Id];

        update task1;
    }
}