@IsTest
public with sharing class IF_DeviceManagerBatchScheduleTest {
    public IF_DeviceManagerBatchScheduleTest() {}
    
    @IsTest 
    static void deviceManagerBatchScheduleTest() {
        InterfaceCommonUtil.setInterface('IF-OPTY-001', 'IF_ERP_Opty_DeviceManager');
        Test.startTest();
        String cronExp = '0 0 * * * ?';
        String jobName = 'deviceManagerBatchSchedule';
        String jobId = System.schedule(jobName, cronExp, new IF_DeviceManagerBatchSchedule());
        Test.stopTest();      
    }
}