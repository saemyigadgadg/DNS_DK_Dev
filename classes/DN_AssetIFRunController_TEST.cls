/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-03-25
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-24   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_AssetIFRunController_TEST {
    public DN_AssetIFRunController_TEST() {}

    @TestSetup
    static void makeData(){

        Country__c country = TestDataFactoryForService.createKRCountry();
        insert country;

        List<OperatingHours> testHours = TestDataFactoryForService.createOperatingHours();
        insert testHours;

        List<ServiceTerritory> stList = TestDataFactoryForService.createTerritory();
        stList[1].WCCode__c = '1244842';
        stList[1].AvailableServiceResource__c = 0;
        insert stList;

        ServiceResource sr = TestDataFactoryForService.createResource(stList[1].Id);
        sr.RelatedRecordId = UserInfo.getUserId();
        sr.StaffNumber__c = '6527';
        insert sr;

        List<Account> insertAccountList = new List<Account>();
        Account dealerAcc = TestDataFactoryForService.createAccount('Dealer', 'Test Dealer', country);
        dealerAcc.CustomerCode__c = '1311191';
        insertAccountList.add(dealerAcc);
        Account shipToAcc = TestDataFactoryForService.createAccount('ShipToParty', 'Test Account', country);
        shipToAcc.CustomerCode__c = '1237758';
        insertAccountList.add(shipToAcc);
        insert insertAccountList;

        Asset testAsset = TestDataFactoryForService.createAsset(shipToAcc.Id);
        testAsset.Name           = 'MH0015-000307';
        testAsset.SerialNumber   = 'MH0015-000307';
        testAsset.ConstrYrMth__c = '2025/03';
        insert testAsset;

    }

    @isTest
    static void updateAssetFromERPErrorTest() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', 'IF_ERP_Material', 'Error');
        
        Asset asset = [SELECT Id FROM Asset LIMIT 1];

        IF_Material__c testDummy = new IF_Material__c();
        testDummy.EQUNR__c = 'MH0015-000307';
        testDummy.IsComplete__c = false;
        insert testDummy;
        
        Test.startTest();
        
        DN_AssetIFRunController.ResultWrapper result = DN_AssetIFRunController.updateAssetFromERP(asset.Id); // 018
        System.debug('result ::: ' + result);

        Test.stopTest();
    }
    
    @isTest
    static void updateAssetFromERPTest() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-018', 'IF_ERP_Material');
        
        Asset asset = [SELECT Id FROM Asset LIMIT 1];

        IF_Material__c testDummy = new IF_Material__c();
        testDummy.EQUNR__c = 'MH0015-000307';
        testDummy.IsComplete__c = false;
        insert testDummy;
        
        Test.startTest();
        
        DN_AssetIFRunController.ResultWrapper result = DN_AssetIFRunController.updateAssetFromERP(asset.Id); // 018
        System.debug('result ::: ' + result);

        Test.stopTest();
    }

    @isTest
    static void callAssetIFTest() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-017', 'IF_ERP_Material');
        
        Asset asset = [SELECT Id FROM Asset LIMIT 1];

        Test.startTest();

        DN_AssetIFRunController.ResultWrapper result = DN_AssetIFRunController.callAssetIF(asset.Id); // 017
        System.debug('result ::: ' + result);

        Test.stopTest();
    }

    @isTest
    static void callAssetIFErrorTest() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-017', 'IF_ERP_Material', 'Error');
        
        Asset asset = [SELECT Id FROM Asset LIMIT 1];

        Test.startTest();

        DN_AssetIFRunController.ResultWrapper result = DN_AssetIFRunController.callAssetIF(asset.Id); // 017
        System.debug('result ::: ' + result);

        Test.stopTest();
    }

    @isTest
    static void formattingDateTest() {
        Date dt = Date.today();
        String dtString = DN_AssetIFRunController.formattingDate(dt);
    }


}