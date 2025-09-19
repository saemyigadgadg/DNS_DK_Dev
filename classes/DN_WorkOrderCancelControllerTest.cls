/**
 * @description       : DN_WorkOrderCancelControllerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_WorkOrderCancelControllerTest {

    @TestSetup
    static void makeData(){
         // 사용자
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Username = 'worker@test.com',
            LastName = 'Worker',
            Email = 'worker@test.com',
            Alias = 'wkr1',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Seoul',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'ko'
        );
        insert u;

        // 서비스 리소스
        ServiceResource sr = new ServiceResource(
            Name = 'Test Resource',
            RelatedRecordId = u.Id,
            IsActive = true
        );
        insert sr;

        // 계정과 자산
        String tradeCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('TradeCustomer').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account', RecordTypeId = tradeCustomer);
        insert acc;

        Asset asset = new Asset(Name = 'Test Asset', AccountId = acc.Id, MachineName__c = 'M-001');
        insert asset;

        // 알림 템플릿 2종
        insert new AlertManager__c(
            Name = 'ServiceOrder Delete Notification',
            IsActive__c = true
        );
        insert new AlertManager__c(
            Name = 'ServiceOrder Confirmation Cancel Notification',
            IsActive__c = true
        );

        // 취소용 WorkOrder (ProductRequest 없음)
        WorkOrder woCancel = new WorkOrder(
            Subject = 'WO for Cancel Test',
            Status = 'New',
            ServiceOrderNumber__c = 'ORD123456',
            AccountId = acc.Id,
            AssetId = asset.Id,
            Worker__c = sr.Id
        );
        insert woCancel;

        // 관련 ServiceAppointment (테스트 대상용)
        insert new ServiceAppointment(
            Status = 'Order Canceled',
            ParentRecordId = woCancel.Id
        );

        // 확정취소용 WorkOrder
        WorkOrder woConfirmCancel = new WorkOrder(
            Subject = 'WO for Confirm Cancel',
            Status = 'Confirmed',
            ConfirmedDate__c = Date.today(),
            ServiceOrderNumber__c = 'SO-0002',
            AccountId = acc.Id,
            AssetId = asset.Id,
            Worker__c = sr.Id
        );
        insert woConfirmCancel;
    }

    @isTest
    static void testCancelWorkOrder_Success() {
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE ServiceOrderNumber__c = 'ORD123456' LIMIT 1];
        
        InterfaceCommonUtil.setInterface('IF-CSPLUS-038', 'IF_ERP_SalesOrder');
        
        Test.startTest();
        DN_WorkOrderCancelController.getListView();
        DN_WorkOrderCancelController.cancelWorkOrder(wo.Id);
        Test.stopTest();

    }

     @isTest
    static void testCancelConfirmation_Success() {
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE ServiceOrderNumber__c = 'SO-0002' LIMIT 1];
        InterfaceCommonUtil.setInterface('IF-SERVICE-052', 'IF_ERP_Service_Report');

        Test.startTest();
        DN_WorkOrderCancelController.cancelConfirmation(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void testCancelWorkOrder_FailureDueToProductRequest() {
        WorkOrder wo1 = [SELECT Id FROM WorkOrder WHERE ServiceOrderNumber__c = 'ORD123456'  LIMIT 1];
        InterfaceCommonUtil.setInterface('IF-CSPLUS-038', 'IF_ERP_SalesOrder');

        Test.startTest();
        DN_WorkOrderCancelController.cancelWorkOrder(wo1.Id);
        DN_WorkOrderCancelController.cancelWorkOrder('Exception');
        Test.stopTest();

    }

    @isTest
    static void testCancelConfirmation_FailureDueToProductRequest() {
        WorkOrder wo2 = [SELECT Id FROM WorkOrder WHERE ServiceOrderNumber__c = 'SO-0002'  LIMIT 1];
        InterfaceCommonUtil.setInterface('IF-SERVICE-052', 'IF_ERP_Service_Report'); 

        // ProductRequest 생성 (IsDealerPortalDelete__c = false)
        insert new ProductRequest(
            WorkOrderId = wo2.Id,
            IsDealerPortalDelete__c = false,
            Status = 'Draft'
        );

        Test.startTest();
        
        DN_WorkOrderCancelController.cancelConfirmation(wo2.Id);
        DN_WorkOrderCancelController.cancelConfirmation('Exception');
        Test.stopTest();

    }
}