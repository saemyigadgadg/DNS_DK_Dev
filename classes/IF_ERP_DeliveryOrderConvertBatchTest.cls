/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 09-04-2025
 * @last modified by  : deokjun.kim@sobetec.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-17-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
@IsTest
public with sharing class IF_ERP_DeliveryOrderConvertBatchTest {
    public IF_ERP_DeliveryOrderConvertBatchTest() {}

    @TestSetup
    static void setUp() {
        DeliveryOrder__c deliveryOrder = new DeliveryOrder__c();

        insert deliveryOrder;

        List<IF_DeliveryOrder__c> deliveryOrders = new List<IF_DeliveryOrder__c>();
            deliveryOrders.add(new IF_DeliveryOrder__c(
                Name = 'a3rJO000000DZJJ',
                CurrencyIsoCode = 'KRW',
                IsConverted__c = false,
                VBELN__c = '0201752032',
                AUBEL__c = '0081328477',
                ObjectType__c = 'T_COND',
                VBELN_VA__C = '01'
            ));

            deliveryOrders.add(new IF_DeliveryOrder__c(
                Name = 'a3rJO000000DZHh',
                CurrencyIsoCode = 'KRW',
                IsConverted__c = false,
                BEZEI__c = '인천지사',
                T_EST_AMT__c = '0.00',
                TEXT1__c = 'Wholesale selling (30 Days)',
                VDATU__c = '2024-04-06',
                ZTERM__c = 'C007',
                VBELN__c = '0081328477',
                ObjectType__c = 'T_HEADER'
            ));

            deliveryOrders.add(new IF_DeliveryOrder__c(
                Name = 'a3rJO000000DZMX',
                CurrencyIsoCode = 'KRW',
                IsConverted__c = false,
                VBELN__c = '0081328477',
                TDLINE__c = '123',
                ObjectType__c = 'T_NOTE'
            ));

            deliveryOrders.add(new IF_DeliveryOrder__c(
                Name = 'a3rJO000000DZG5',
                CurrencyIsoCode = 'KRW',
                IsConverted__c = false,
                VBELN__c = '0081328477',
                WADAT__c = '2025-03-08',
                LFDAT__c = '2025-04-18',
                ZZSTATUS__c = 'A',
                ZFETD__c = '0000-00-00',
                ZFETA__c = '0000-00-00',
                ObjectType__c = 'T_ZCRMS0062'
            ));
            insert deliveryOrders;
    }

    @IsTest 
    static void deliveryOrderConvertBatchTest() {   
        Test.startTest();        
        IF_ERP_DeliveryOrderConvertBatch batchInstance = new IF_ERP_DeliveryOrderConvertBatch();
        Database.executeBatch(batchInstance,50);
        Test.stopTest();
    }

    @IsTest 
    static void convertDateTest() {   
        Test.startTest();        
        IF_DeliveryOrder__c do1 = new IF_DeliveryOrder__c(
                Name = 'a3rJO000000DZG5',
                CurrencyIsoCode = 'KRW',
                IsConverted__c = false,
                VBELN__c = '0081328477',
                WADAT__c = '2025-03-08',
                LFDAT__c = '2025-04-18',
                ZZSTATUS__c = 'A',
                ZFETD__c = '0000-00-00',
                ZFETA__c = '0000-00-00',
                ObjectType__c = 'T_ZCRMS0062'
            );

        IF_ERP_DeliveryOrderConvertBatch batchInstance = new IF_ERP_DeliveryOrderConvertBatch();
        batchInstance.fromCOND(new DeliveryOrder__c(), do1);
        batchInstance.fromHEADER(new DeliveryOrder__c(), do1);
        batchInstance.fromNOTE(new DeliveryOrder__c(), do1);
        batchInstance.fromZCRMS0062(new DeliveryOrder__c(), do1);

        batchInstance.convertDate('2025-09-04');
        batchInstance.convertDateTime('2025-09-04-000000');
        batchInstance.convertDateTime('2025-09-04','00:00:00');
        Test.stopTest();
    }
}