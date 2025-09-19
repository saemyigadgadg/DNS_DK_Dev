/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 06-17-2025
 * @last modified by  : JangJunHee
**/
@isTest
public with sharing class DN_UpdateReturnPurchaseOrderItem_Test {
    public DN_UpdateReturnPurchaseOrderItem_Test() {}

    @isTest
    public Static void IF_ERP_productBatch_Test(){
        InterfaceCommonUtil.setInterface('IF-PARTS-019', 'IF_ERP_Parts_Return');
        Test.startTest();

        IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req req = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req();
        DN_UpdateReturnPurchaseOrderItem batch = new DN_UpdateReturnPurchaseOrderItem(req);
        Database.executeBatch(batch);

        Test.stopTest();
    }
    @isTest
    private static void IF_ERP_productBatch_Schedule_Test(){
        InterfaceCommonUtil.setInterface('IF-PARTS-019', 'IF_ERP_Parts_Return');
        Test.startTest();

        IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req req = new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req();
        DN_UpdateReturnPurchaseOrderItem scheduler = new DN_UpdateReturnPurchaseOrderItem(req);
        System.schedule('Test Scheduled Batch', '0 0 12 * * ?', scheduler);

        Test.stopTest();
    }

    @isTest
    static void testMappingPurchaseOrderItem() {
        PurchaseOrder__c po = new PurchaseOrder__c(Name = 'Test PO', PartOrderNo__c = 'PON12345');
        insert po;

        PurchaseOrderItems__c poi = new PurchaseOrderItems__c(
            PurchaseOrder__c = po.Id,
            OrderNo__c = 'ORD67890'
        );
        insert poi;

        IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2 mockSearch2 = 
            new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2();
        mockSearch2.VGBEL = 'INV12345';
        mockSearch2.VBELN2 = 'HQ12345';
        mockSearch2.RFGSK_TX_T1 = 'Returned';

        String key = po.PartOrderNo__c + '/' + poi.OrderNo__c;
        Map<String, IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2> mockMap = 
            new Map<String, IF_ERP_Parts_Return_Classes.IF_PARTS_019_Res_LT_SEARCH2>{
                key => mockSearch2
            };

        poi = [SELECT Id, OrderNo__c, PurchaseOrder__r.PartOrderNo__c FROM PurchaseOrderItems__c WHERE Id = :poi.Id];

        InterfaceCommonUtil.setInterface('IF-PARTS-019', 'IF_ERP_Parts_Return');

        Test.startTest();
        new DN_UpdateReturnPurchaseOrderItem(new IF_ERP_Parts_Return_Classes.IF_PARTS_019_Req()).mappingPurchaseOrderItem(poi, mockMap);
        Test.stopTest();
    }
}