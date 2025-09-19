@isTest
public with sharing class DN_DealerPortalMigBatch_TEST {
    public static DealerOrder__c order;
    public static DealerOrderItem__c orderItem;
    public static ShipmentOrder__c shipment;
    public static DealerCustomer__c customer;


    @IsTest
    static void test1(){
        order = new DealerOrder__c(
            CustomerCode__c = '12345'
        );
        insert order;

        orderItem = new DealerOrderItem__c(
            DealerOrderItemCode__c = 'TEST1234',
            Order__c = order.Id,
            SourceSystem__c = 'ERP'
        );
        insert orderItem;
        
        shipment = new ShipmentOrder__c(
            DealerOrderItemCode__c = 'TEST1234',
            IsConvert__c = false,
            DealerCode__c = 'tset111'
        );
        insert shipment;
        customer = new DealerCustomer__c(
            CustomerCode__c = 'aaaaaa'
        );
        insert customer;
        Test.startTest();
            Database.executeBatch(new DN_DealerPortalMigBatch('ShipmentOrder', 'ShipmentOrder__c'));
            new DN_DealerPortalMigBatch();
            ShipmentOrder__c shipments = [SELECT Id, DealerOrderItemCode__c, IsConvert__c FROM ShipmentOrder__c WHERE DealerOrderItemCode__c = 'TEST1234' LIMIT 1];
            shipments.IsConvert__c = false;
            update shipments;
            DN_DealerPortalMigBatch batch = new DN_DealerPortalMigBatch('ShipmentOrder', 'ShipmentOrder__c');
            batch.isTest = true;
            Database.executeBatch(batch);
        Test.stopTest();
        
    }
}