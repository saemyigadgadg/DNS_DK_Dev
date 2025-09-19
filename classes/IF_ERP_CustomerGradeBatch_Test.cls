@isTest
public with sharing class IF_ERP_CustomerGradeBatch_Test {
    public IF_ERP_CustomerGradeBatch_Test() {}

/* Test Method
    */
    @isTest
    private static void IF_ERP_CustomerGradeBatch_Test () {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-017', 'IF_ERP_Account', 'Testcode');
        Test.startTest();

        IF_ERP_Account_Classes.IF_ACCOUNT_017_Req req = new IF_ERP_Account_Classes.IF_ACCOUNT_017_Req();
        req.I_FROMDATE  = '2024-01-01';
        req.I_TODATE    = '2024-06-30';

        IF_ERP_CustomerGradeBatch batch = new IF_ERP_CustomerGradeBatch(req);
        Database.executeBatch(batch);

        Test.stopTest();
    }
    @isTest
    static void IF_ERP_CustomerGradeBatch_Schedule_Test() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-017', 'IF_ERP_Account');
        Test.startTest();
        IF_ERP_Account_Classes.IF_ACCOUNT_017_Req req = new IF_ERP_Account_Classes.IF_ACCOUNT_017_Req();
        IF_ERP_CustomerGradeBatch scheduler = new IF_ERP_CustomerGradeBatch(req);
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);
        Test.stopTest();
    }

}