@IsTest
public with sharing class IF_ERP_DNSA_OrderBatchSchedule_Test {
    public IF_ERP_DNSA_OrderBatchSchedule_Test() {}

    @IsTest
    static void batch(){
        InterfaceCommonUtil.setInterface('IF-ORDER-012', 'IF_ERP_Order');
        Test.startTest();
        String cronExp = '0 0 * * * ?';
        String jobName = 'DNSA_OrderBatch';
        String jobId = System.schedule(jobName, cronExp, new IF_ERP_DNSA_OrderBatchSchedule());
        Test.stopTest();
    }

}