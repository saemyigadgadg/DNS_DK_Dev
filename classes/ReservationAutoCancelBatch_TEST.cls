/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-16-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-02-2025   Hanyeong Choi   Initial Version
**/
@isTest(SeeAllData=true)
public with sharing class ReservationAutoCancelBatch_TEST {
    @isTest
    static void testCoverage() {
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'SalesAreaDataTrigger', 'AccessoryTriggerHandler', 'OpportunityTriggerHandler', 'OpportunityLineImteTriggerHandler', 'OrderTriggerHandler', 'QuoteTriggerHandler', 'QuoteLineItemTriggerHanlder'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응
        AlertManager__c am1 = TestDataFactoryForSales.createAlertManager('Booking Auto Cancel Alert');
        insert am1;
        InterfaceCommonUtil.setInterface('IF-ORDER-011', 'IF_ERP_Order');

        Test.startTest();
        ReservationAutoCancelBatch rva = new ReservationAutoCancelBatch();
        Database.executeBatch(rva);
        Test.stopTest();
    }
}