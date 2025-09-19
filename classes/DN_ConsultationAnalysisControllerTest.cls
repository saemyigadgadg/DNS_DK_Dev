/**
 * @description       : DN_WorkOrderCancelController_TEST
 * @author            : Hayeong Min
 * @last test date    : 2025-06-05
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_ConsultationAnalysisControllerTest {
    @TestSetup
    static void makeData(){
        String serviceId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        List<Task> taskList = new List<Task>();

        Task task1 = new Task();
        task1.ActivityDate = Date.newInstance(2025, 6, 20);
        task1.ConsultationTypeMajor__c = 'Failure Receipt';
        task1.TaskSubtype = 'Call';
        task1.RecordTypeId = serviceId;
        taskList.add(task1);
        
        Task task2 = new Task();
        task2.ActivityDate = Date.newInstance(2025, 6, 20);
        task2.ConsultationTypeMajor__c = 'Product Inquiry';
        task2.TaskSubtype = 'Call';
        task2.RecordTypeId = serviceId;
        taskList.add(task2);

        Task task3 = new Task();
        task3.ActivityDate = Date.newInstance(2025, 6, 20);
        task3.ConsultationTypeMajor__c = 'Customer Complaints';
        task3.TaskSubtype = 'Call';
        task3.RecordTypeId = serviceId;
        taskList.add(task3);
        
        Task task4 = new Task();
        task4.ActivityDate = Date.newInstance(2025, 6, 20);
        task4.ConsultationTypeMajor__c = 'Call Service';
        task4.TaskSubtype = 'Call';
        task4.RecordTypeId = serviceId;
        taskList.add(task4);
        
        Task task5 = new Task();
        task5.ActivityDate = Date.newInstance(2025, 6, 20);
        task5.ConsultationTypeMajor__c = 'Scheduled Call';
        task5.TaskSubtype = 'Call';
        task5.RecordTypeId = serviceId;
        taskList.add(task5);
        
        Task task6 = new Task();
        task6.ActivityDate = Date.newInstance(2025, 6, 20);
        task6.ConsultationTypeMajor__c = 'Other';
        task6.TaskSubtype = 'Call';
        task6.RecordTypeId = serviceId;
        taskList.add(task6);
        
        Task task7 = new Task();
        task7.ActivityDate = Date.newInstance(2025, 6, 20);
        task7.ConsultationTypeMajor__c = 'VOC';
        task7.TaskSubtype = 'Call';
        task7.RecordTypeId = serviceId;
        taskList.add(task7);
        
        Task task8 = new Task();
        task8.ActivityDate = Date.newInstance(2025, 6, 20);
        task8.TaskSubtype = 'Call';
        task8.RecordTypeId = serviceId;
        taskList.add(task8);
        
        insert taskList;
    }

    @isTest
    static void testGetPersonData(){     
        Date startDate = Date.newInstance(2025, 6, 20);
        Date endDate = Date.newInstance(2025, 6, 25);
        
        Test.startTest();
        DN_ConsultationTypeAnalysisController.getPersonData(startDate, endDate);
        DN_ConsultationTypeAnalysisController.getPersonData(null, null);
        Test.stopTest();
    }

    @isTest
    static void testGetDailyData(){     
        Date startDate = Date.newInstance(2025, 6, 20);
        Date endDate = Date.newInstance(2025, 6, 25);
        
        Test.startTest();
        DN_ConsultationTypeAnalysisController.getDailyData(startDate, endDate);
        DN_ConsultationTypeAnalysisController.getDailyData(null, null);
        Test.stopTest();
    }
}