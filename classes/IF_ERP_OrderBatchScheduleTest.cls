/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-10-2025
 * @last modified by  : deokjun.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-10-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
@IsTest
global with sharing class IF_ERP_OrderBatchScheduleTest {
    public IF_ERP_OrderBatchScheduleTest() {}

    @IsTest
    static void orderBatchSchedule(){
        InterfaceCommonUtil.setInterface('IF-ORDER-002', 'IF_ERP_Order');
        Test.startTest();
        String cronExp = '0 0 * * * ?';
        String jobName = 'Test_IF_ERP_OrderBatchScheduler';
        String jobId = System.schedule(jobName, cronExp, new IF_ERP_OrderBatchSchedule('',''));
        Test.stopTest();
    }
}