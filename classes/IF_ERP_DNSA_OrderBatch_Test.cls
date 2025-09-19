@IsTest
public with sharing class IF_ERP_DNSA_OrderBatch_Test {
    public IF_ERP_DNSA_OrderBatch_Test() {}

    @IsTest
    static void dnsaOrderBatchTest(){
        InterfaceCommonUtil.setInterface('IF-ORDER-012', 'IF_ERP_Order');
        Test.startTest();
        IF_ERP_Order_Classes.IF_ORDER_012_Req request = new IF_ERP_Order_Classes.IF_ORDER_012_Req();
        request.I_AEDAT_F= '20250303'; 
        request.I_AEDAT_T= '20250303'; 
        
        Database.executeBatch(new IF_ERP_DNSA_OrderBatch(request),50);

        Test.stopTest();
    }

}