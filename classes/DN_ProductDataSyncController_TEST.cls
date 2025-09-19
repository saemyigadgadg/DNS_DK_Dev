/**
 * @author            : Yeong-Deok Seo
 * @description       : 
 * @last modified on  : 07-25-2025
 * @last modified by  : JangJunHee
**/
@isTest
public with sharing class DN_ProductDataSyncController_TEST {
    
    @TestSetup
    static void makeData(){
        TriggerHandler.bypass('ProductTriggerHandler');
        Product2 pro = TestDataFactoryForService.createProduct();
        insert pro;
        TriggerHandler.clearAllBypasses();
    }

    @isTest
    static void testProductDataSync(){

        InterfaceCommonUtil.setInterface('IF-OPTY-002', 'IF_ERP_Product');

        Product2 pro = [SELECT Id, ERP_Key__c FROM Product2 LIMIT 1];
        pro.ERP_Key__c = '300746-00677';
        update pro;

        Test.startTest();
        ApexPages.standardController controller = new ApexPages.standardController(pro);
        DN_ProductDataSyncController className = new DN_ProductDataSyncController(controller);
        PageReference page1 = className.clickCancel();
        className.productCodeValue = 'R18181';
        PageReference page2 = className.clickConfirm();
        Test.stopTest();
    }

}