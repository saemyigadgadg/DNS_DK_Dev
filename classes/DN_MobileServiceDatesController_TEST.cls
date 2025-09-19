/**
 * @description       :
 * @author            : sungheum.yeon@sobetec.com
 * @group             :
 * @last modified on  : 04-02-2025
 * @last modified by  : sungheum.yeon@sobetec.com
 * Converage          : 84%
**/
@isTest
public with sharing class DN_MobileServiceDatesController_TEST {
    @testSetup
    static void setupTestData() {
        WorkOrder wo = new WorkOrder(
            Subject = 'Test Work Order'
        );
        insert wo;

        insert new WorkOrderResult__c(
            WorkOrder__c = wo.Id,
            ResultType__c = 'WH',
            WorkDate__c = Date.today(),
            WorkStartTime__c = Time.newInstance(9, 0, 0, 0),
            WorkEndTime__c = Time.newInstance(10, 0, 0, 0),
            WorkTime__c = '1',
            TravelHour__c = '0.5',
            AirTrip__c = 'Yes'
        );

        insert new WorkOrderResult__c(
            WorkOrder__c = wo.Id,
            ResultType__c = 'PT',
            Note__c = 'Test Note',
            ProductNumber__c = 'P001',
            ProductName__c = 'Part Name',
            IsCause__c = true,
            Quantity__c = 2
        );
    }

    @isTest
    static void test_getWorkOrderResults() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        Map<String, Object> result = DN_MobileServiceDatesController.getWorkOrderResults(wo.Id);
        System.assertEquals('success', result.get('status'));
        System.assert(result.containsKey('workOrderResults'));
    }

    @isTest
    static void test_getWorkOrderResultParts() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        Map<String, Object> result = DN_MobileServiceDatesController.getWorkOrderResultParts(wo.Id);
        System.assertEquals('success', result.get('status'));
        System.assert(result.containsKey('workOrderResults'));
    }

    @isTest
    static void test_saveWorkOrderResults_success_and_error() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        // ✅ 정상 저장
        List<Map<String, Object>> saveList = new List<Map<String, Object>>();
        saveList.add(new Map<String, Object>{
            'WorkDate' => String.valueOf(Date.today()),
            'WorkStartTime' => '08:30:00',
            'WorkEndTime' => '09:30:00',
            'WorkTime' => '1',
            'TravelHour' => '0.3',
            'AirTrip' => 'Yes'
        });

        String jsonString = JSON.serialize(saveList);
        List<String> deleteList = new List<String>();

        DN_MobileServiceDatesController.saveResultWrapper result1 =
            DN_MobileServiceDatesController.saveWorkOrderResults(wo.Id, jsonString, deleteList);
        System.assertEquals(true, result1.isSuccess);

        // ❌ 실패 테스트 (존재하지 않는 ID로 update 유도)
        List<Map<String, Object>> errorList = new List<Map<String, Object>>();
        errorList.add(new Map<String, Object>{
            'resultId' => 'a0X999999999999', // 존재하지 않는 Id
            'WorkDate' => String.valueOf(Date.today()),
            'WorkStartTime' => '08:00:00',
            'WorkEndTime' => '09:00:00',
            'WorkTime' => '1',
            'TravelHour' => '0.5',
            'AirTrip' => 'No'
        });

        String errorJson = JSON.serialize(errorList);
        DN_MobileServiceDatesController.saveResultWrapper result2 =
            DN_MobileServiceDatesController.saveWorkOrderResults(wo.Id, errorJson, deleteList);

        System.assertEquals(false, result2.isSuccess);
        System.assert(result2.message.contains('Error'));
    }

    @isTest
    static void test_saveWorkOrderResultsParts_success_and_error() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        // ✅ 정상 저장
        List<Map<String, Object>> saveList = new List<Map<String, Object>>();
        saveList.add(new Map<String, Object>{
            'ProductNumber' => 'P002',
            'ProductName' => 'New Part',
            'IsCause' => true,
            'Quantity' => 5,
            'Note' => 'Test part usage'
        });

        String jsonString = JSON.serialize(saveList);
        List<String> deleteList = new List<String>();

        DN_MobileServiceDatesController.saveResultWrapper result1 =
            DN_MobileServiceDatesController.saveWorkOrderResultsParts(wo.Id, jsonString, deleteList);
        System.assertEquals(true, result1.isSuccess);

        // ❌ 실패 테스트 (존재하지 않는 ID로 update 유도)
        List<Map<String, Object>> errorList = new List<Map<String, Object>>();
        errorList.add(new Map<String, Object>{
            'resultId' => 'a0X888888888888', // 가짜 ID
            'ProductNumber' => 'P999',
            'ProductName' => 'Invalid Part',
            'IsCause' => true,
            'Quantity' => 1,
            'Note' => 'Invalid ID update'
        });

        String errorJson = JSON.serialize(errorList);
        DN_MobileServiceDatesController.saveResultWrapper result2 =
            DN_MobileServiceDatesController.saveWorkOrderResultsParts(wo.Id, errorJson, deleteList);

        System.assertEquals(false, result2.isSuccess);
        System.assert(result2.message.contains('Error'));
    }
}