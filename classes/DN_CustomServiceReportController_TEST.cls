/**
 * @description       : 
 * @author            : geonsang.park@sobetec.com
 * @group             : 
 * @last modified on  : 04-02-2025
 * @last modified by  : geonsang.park@sobetec.com
**/
@isTest
private class DN_CustomServiceReportController_TEST {

    @isTest
    static void testSaveServiceSignatures() {
        // 준비: WorkOrder 더미 생성
        WorkOrder wo = new WorkOrder(
            Subject = 'Test WO',
            Status = 'New',
            Priority = 'Medium'
        );
        insert wo;

        // 실행: Controller 메서드 호출
        String testEngineer = 'Test Engineer';
        String testCustomer = 'Test Customer';

        Test.startTest();
        DN_CustomServiceReportController.saveServiceSignatures(wo.Id, testEngineer, testCustomer);
        Test.stopTest();

    }
}