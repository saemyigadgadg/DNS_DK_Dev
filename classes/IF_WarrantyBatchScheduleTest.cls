@IsTest
public with sharing class IF_WarrantyBatchScheduleTest {
    public IF_WarrantyBatchScheduleTest() {}
    
    @isTest
    static void warrantyBatchSchedule(){
        InterfaceCommonUtil.setInterface('IF-ORDER-017', 'IF_ERP_Order');
        Test.startTest();
        String cronExp = '0 0 * * * ?';
        String jobName = 'WarrantyBatchSchedule';
        String jobId = System.schedule(jobName, cronExp, new IF_WarrantyBatchSchedule());
        Test.stopTest();
    }
}