@isTest
global with sharing class IF_ERP_DeliveryBatchScheduleTest {
    public IF_ERP_DeliveryBatchScheduleTest() {}

    @IsTest
    static void deliveryOrderBatchSchedule(){
        InterfaceCommonUtil.setInterface('IF-DELIV-002', 'IF_ERP_DELIV');
        Test.startTest();
        String cronExp = '0 0 * * * ?';
        String jobName = 'Test_IF_ERP_DeliveryBatchSchedule';
        String jobId = System.schedule(jobName, cronExp, new IF_ERP_DeliveryBatchSchedule());
        Test.stopTest();
    }
}