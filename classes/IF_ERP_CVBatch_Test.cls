@isTest
private class IF_ERP_CVBatch_Test {
    @isTest
    static void test_IF_ERP_CVBatch() {
        InterfaceCommonUtil.setInterface('IF-OPTY-027', 'IF_ERP_Product');

        Test.startTest();

        IF_ERP_CVBatch batchInstance = new IF_ERP_CVBatch();
        Database.executeBatch(batchInstance, 10);

        Test.stopTest();
    }
    @isTest
    static void test_IF_ERP_CVBatch_Schedule() {
        Test.startTest();
        IF_ERP_CVBatch scheduler = new IF_ERP_CVBatch();
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);
    }
}