@isTest
public with sharing class DN_UpdatePartsOrderFromERPBatch_Test {
    public DN_UpdatePartsOrderFromERPBatch_Test() {}

    @isTest
    public static void DN_UpdatePartsOrderFromERPBatch_Schedule_Test(){
        InterfaceCommonUtil.setInterface('IF-PARTS-034', 'IF_ERP_Parts_Order');
        Test.startTest();
        IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req();
        DN_UpdatePartsOrderFromERPBatch scheduler = new DN_UpdatePartsOrderFromERPBatch(req);
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);
        Test.stopTest();
    }

    @isTest
    static void testMappingPurchaseOrder() {
        InterfaceCommonUtil.setInterface('IF-PARTS-034', 'IF_ERP_Parts_Order');
        Test.startTest();
        PurchaseOrder__c po = new PurchaseOrder__c(
            PartOrderNo__c = 'PO12345'
        );

        IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_HEADER header = new IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_HEADER();
        header.LIFSK = 'TestBlock';

        Map<String, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_HEADER> headerMap = new Map<String, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_HEADER>{
            'PO12345' => header
        };

        IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req();
        DN_UpdatePartsOrderFromERPBatch instance = new DN_UpdatePartsOrderFromERPBatch(req);
        instance.mappingPurchaseOrder(po, headerMap);
        Test.stopTest();
    }

    @isTest
    static void testMappingPurchaseOrderItem() {
        InterfaceCommonUtil.setInterface('IF-PARTS-034', 'IF_ERP_Parts_Order');
        Test.startTest();
        PurchaseOrder__c po = new PurchaseOrder__c(
            PartOrderNo__c = 'PO12345'
        );

        PurchaseOrderItems__c item = new PurchaseOrderItems__c(
            ItemNo__c = '10'
        );
        item.putSObject('PurchaseOrder__r', po);

        IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_DETAIL detail = new IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_DETAIL();
        detail.FST_ETD   = '2025-05-01';
        detail.LST_ETD   = '2025-05-10';
        detail.DODAT     = '2025-05-15';
        detail.SO_QTY    = '100';
        detail.CFM_QTY   = '80';
        detail.STB_QTY   = '20';
        detail.PI_QTY    = '60';
        detail.SH_QTY    = '50';
        detail.INVOICE   = 'INV12345';
        detail.VBELN2    = 'HQ123456';
        detail.RFGSK_TX_T= 'Confirmed';

        String key = 'PO12345/10';
        Map<String, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_DETAIL> detailMap = new Map<String, IF_ERP_Parts_Order_Classes.IF_PARTS_034_Res_T_DETAIL>{
            key => detail
        };

        DN_UpdatePartsOrderFromERPBatch.SummaryObject summary = new DN_UpdatePartsOrderFromERPBatch.SummaryObject();
        summary.CFM_QTY = 80;
        summary.PI_QTY  = 60;
        summary.SH_QTY  = 50;

        Map<String, DN_UpdatePartsOrderFromERPBatch.SummaryObject> SummaryMap = new Map<String, DN_UpdatePartsOrderFromERPBatch.SummaryObject>{
            'PO12345/10' => summary
        };

        IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req req = new IF_ERP_Parts_Order_Classes.IF_PARTS_034_Req();
        DN_UpdatePartsOrderFromERPBatch instance = new DN_UpdatePartsOrderFromERPBatch(req);
        instance.mappingPurchaseOrderItem(item, detailMap, SummaryMap);
        Test.stopTest();
    }
}