/**
 * @description       : DN_ShippingInstructionBtnController_TEST
 * @author            : Hayeong Min
 * @last test date    : 2025-03-25
 * @last modified by  : Hayeong Min
 * @Percentage        :
**/
@isTest
public with sharing class DN_ShippingInstructionBtnControllerTest {
    @TestSetup
    static void makeData(){
        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;

        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TradeCustomer Company', korea);
        insert account;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;

        Case ticket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, null, 'Technical inquiry', 'Failure receipt');
        insert ticket;
    }

    @isTest
    static void testGetInitInfo(){   
        Asset asset = [SELECT ID, MachineName__c FROM Asset LIMIT 1];
        Case ticket = [SELECT Id FROM Case LIMIT 1];

        InterfaceCommonUtil.setInterface('IF-CSPLUS-029', 'IF_ERP_ShipmentOrder');
        Test.startTest();
        DN_ShippingInstructionBtnController.getInitInfo(ticket.Id, 'Case');
        DN_ShippingInstructionBtnController.getInitInfo(asset.Id, 'Asset');
        DN_ShippingInstructionBtnController.getInitInfo('Exception', 'Asset');
        DN_ShippingInstructionBtnController.getAssetInfo(asset.Id);
        DN_ShippingInstructionBtnController.getAssetInfo('Exception');
        DN_ShippingInstructionBtnController.getShippingInstructionInfo(asset.Id, asset.MachineName__c);
        DN_ShippingInstructionBtnController.getShippingInstructionInfo('Exception', asset.MachineName__c);

        Test.stopTest();
    }
}