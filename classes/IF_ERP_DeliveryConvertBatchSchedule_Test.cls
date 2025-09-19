@IsTest
public with sharing class IF_ERP_DeliveryConvertBatchSchedule_Test {
    public IF_ERP_DeliveryConvertBatchSchedule_Test() {}


    @TestSetup
    static void setUp() {
        List<IF_DeliveryOrder__c> deliveryOrders = new List<IF_DeliveryOrder__c>();
            deliveryOrders.add(new IF_DeliveryOrder__c(
                Name = 'a3rJO000000DZJJ',
                CurrencyIsoCode = 'KRW',
                IsConverted__c = false,
                VBELN__c = '0201752032',
                AUBEL__c = '0081328477',
                ObjectType__c = 'T_COND'
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
        String cronExp = '0 0 * * * ?';
        String jobName = 'IF_ERP_DeliveryConvertBatchSchedule';
        String jobId = System.schedule(jobName, cronExp, new IF_ERP_DeliveryConvertBatchSchedule());
        Test.stopTest();
    }

}