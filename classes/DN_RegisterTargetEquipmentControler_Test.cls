@IsTest
public with sharing class DN_RegisterTargetEquipmentControler_Test {
    @TestSetup
    static void makeData(){
        RecordType campaign_recordType = TestDataFactoryForSales.getRecordType('DNSAPreCall', 'Campaign');

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.CustomerCode__c   = '123456';
        acc.BusinessNumber__c = '5148171773';
        acc.Representative__c = 'realAcc';
        acc.ServiceManager__c = 'test@test.com';
        acc.PartsManagerEmail__c = 'test2@test.com';
        insert acc;

        Contact con = TestDataFactoryForSales.createContact('ContactPerson', acc.Id);
        con.MobilePhone = '01011112222';
        insert con;

        Asset ass1 = new Asset();
        ass1.AccountId = acc.Id;
        ass1.MachineName__c = 'ML00001';
        ass1.Name = 'ML00002';
        ass1.Maintplant__c = '184S';
        ass1.PlannerGrp__c = '180';
        ass1.SoldTo__c = acc.Id;
        insert ass1;

        Asset ass2 = new Asset();
        ass2.AccountId = acc.Id;
        ass2.MachineName__c = 'ML00003';
        ass2.Name = 'ML00004';
        ass2.Maintplant__c = '184S';
        ass2.PlannerGrp__c = '180';
        ass2.SoldTo__c = acc.Id;
        insert ass2;

        Asset ass3 = new Asset();
        ass3.AccountId = acc.Id;
        ass3.MachineName__c = 'ML00004';
        ass3.Name = 'ML00005';
        ass3.Maintplant__c = '184S';
        ass3.PlannerGrp__c = '180';
        ass3.SoldTo__c = acc.Id;
        insert ass3;

        Campaign cp = new Campaign(Name = 'Test Campaign', CampaignType__c = 'ServiceCampaign');
        cp.RecordTypeId = campaign_recordType.Id;
        cp.UseCommonParts__c = true;
        insert cp;

        CampaignAsset__c ca = new CampaignAsset__c();
        ca.Campaign__c = cp.Id;
        insert ca;

        ModelManager__c mm = new ModelManager__c(Name = 'test Model'); insert mm;

    }
    
    @isTest
    static void testBatch() {
        Account accObj = [SELECT Id FROM Account LIMIT 1];
        Campaign cp = [SELECT Id FROM Campaign LIMIT 1];
        List<Asset> assets = [SELECT Id FROM Asset LIMIT 3];
        User userObj = [SELECT Id FROM User LIMIT 1];
        List<Map<String, Object>> selectedData = new List<Map<String, Object>>();
        Map<String, Object> data1 = new Map<String, Object>();
        data1.put('AssetId', assets[0].Id);
        data1.put('Email', 'test@naver.com');
        
        Map<String, Object> data2 = new Map<String, Object>();
        data2.put('AssetId', assets[1].Id);
        data2.put('Manager__c', userObj.Id);

        selectedData.add(data1);
        selectedData.add(data2);

        // CampaignAsset__c caObj = [SELECT Id FROM CampaignAsset__c];

        List<Map<String, Object>> selectedEquipment = new List<Map<String, Object>>();
        Map<String, Object> edata1 = new Map<String, Object>();
        edata1.put('AssetId', assets[0].Id);
        edata1.put('Email', 'test@naver.com');
        
        Map<String, Object> edata2 = new Map<String, Object>();
        edata2.put('AssetId', assets[1].Id);
        edata2.put('Manager__c', userObj.Id);

        selectedEquipment.add(edata1);
        selectedEquipment.add(edata2);

        List<Map<String, Object>> notSelectedEquipment = new List<Map<String, Object>>();
        Map<String, Object> edata3 = new Map<String, Object>();
        edata3.put('AssetId', assets[2].Id);
        edata3.put('Email', 'test@naver.com');
        edata3.put('Manager__c', userObj.Id);
        notSelectedEquipment.add(edata3);

        ModelManager__c mmObj = [SELECT Name, Id FROM ModelManager__c LIMIT 1];

        Test.startTest();
        DN_RegisterTargetEquipmentController.searchTargetEquipments(accObj.Id, 'ML00001', 'ML00002', '184S', '180');
        DN_RegisterTargetEquipmentController.registerTargetEquipment(cp.Id, selectedData);
        DN_RegisterTargetEquipmentController.registerTargetEquipment(assets[0].Id, selectedData);
        DN_RegisterTargetEquipmentController.changeTargetEquipment(cp.Id, selectedEquipment);
        DN_RegisterTargetEquipmentController.changeTargetEquipment(cp.Id, notSelectedEquipment);
        DN_RegisterTargetEquipmentController.initAccountList('test company');
        DN_RegisterTargetEquipmentController.initAccountList('');
        DN_RegisterTargetEquipmentController.initModelList('test company', 'test Model');
        DN_RegisterTargetEquipmentController.initModelList('test company', '');
        DN_RegisterTargetEquipmentController.checkCommonParts(cp.Id);
        DN_RegisterTargetEquipmentController.checkCommonParts(accObj.Id);
        Test.stopTest();
    }

}