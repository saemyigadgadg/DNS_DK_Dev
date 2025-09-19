@IsTest
public with sharing class IF_PromotionBatchScheduleTest {
    public IF_PromotionBatchScheduleTest() {}


    @IsTest
    static void promotionBatchSchedule(){
        InterfaceCommonUtil.setInterface('IF-ORDER-016', 'IF_ERP_Order');
        Test.startTest();
            String cronExp = '0 0 2 * * ?'; 
            String jobName = 'PromotionBatch_02';
            IF_PromotionBatchSchedule scheduler = new IF_PromotionBatchSchedule();
            System.schedule(jobName, cronExp, scheduler);
        Test.stopTest();
    }
}