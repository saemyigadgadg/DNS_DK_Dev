/**
 * @description       : 
 * @author            : Chungwoo Lee
 * @last modified on  : 03-25-2025
 * @last modified by  : Chungwoo Lee
**/
@isTest
public with sharing class DN_EquipmentSpecificationController_TEST {
    @IsTest
    static void testGetShippingInstructionInfo() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-029', 'IF_ERP_ShipmentOrder');
        
        Test.setMock(HttpCalloutMock.class, new IF_ERP_ShipmentOrder_Test.IF_CSPLUS_029_HttpMock());
                
        Test.startTest();
        IF_ERP_ShipmentOrder_Classes.IF_CSPLUS_029_Res res = DN_EquipmentSpecificationController.getShippingInstructionInfo('TEST MachineName', 'TEST AssetName');
        Test.stopTest();
        
        System.debug('PartsIssuanceStatus result: ' + res);
    }

    @IsTest
    static void testGetShippingInstructionInfo_Exception() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            DN_EquipmentSpecificationController.getShippingInstructionInfo('TEST MachineName', 'TEST AssetName');
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.debug('Exception TEST ::: ' + e.getMessage());
        }
    }
}