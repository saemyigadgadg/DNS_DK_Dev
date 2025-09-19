/**
 * @description       : DN_CheckSpindleInfoController_TEST
 * @author            : Hayeong Min
 * @last test date    : 2025-03-25
 * @last modified by  : Hayeong Min
 * @Percentage        :
**/
@isTest
public with sharing class DN_CheckSpindleInfoControllerTest {
    @TestSetup
    static void makeData(){
        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;

        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TradeCustomer Company', korea);
        insert account;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;
    
    }

    @isTest
    static void testGetSpindleInfo(){ 
        InterfaceCommonUtil.setInterface('IF-CSPLUS-031', 'IF_ERP_Material');    
        Asset asset = [SELECT ID, MachineName__c FROM Asset LIMIT 1];

        Test.startTest();
        DN_CheckSpindleInfoController.getSpindleInfo(asset.Id);
        DN_CheckSpindleInfoController.getSpindleInfo('Exception');
        Test.stopTest();
    }
}