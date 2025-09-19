/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-03-27
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-26   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_TicketDetailController_TEST {
    public DN_TicketDetailController_TEST() {}

    @TestSetup
    static void makeData(){

        String profileId = UserInfo.getProfileId();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        User user;
        System.runAs(thisUser) {
            user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
            insert user;
        }

        Country__c country = TestDataFactoryForService.createKRCountry();
        insert country;

        List<OperatingHours> testHours = TestDataFactoryForService.createOperatingHours();
        insert testHours;
        System.runAs(user) {
            List<ServiceTerritory> stList = TestDataFactoryForService.createTerritory();
            stList[0].WCCode__c = '';
            stList[0].AvailableServiceResource__c = 0;
            stList[1].WCCode__c = '1244842';
            stList[1].AvailableServiceResource__c = 0;
            insert stList;
    
            User testUser = [SELECT Id FROM User WHERE LastName = 'testuser' LIMIT 1];
    
            List<ServiceResource> insertSRList = new List<ServiceResource>();
            ServiceResource sr = TestDataFactoryForService.createResource(stList[1].Id);
            sr.RelatedRecordId = thisUser.Id;
            sr.StaffNumber__c = '6527';
            sr.LastKnownLatitude = 37.557718278300890;
            sr.LastKnownLongitude = 126.974039677136940;
            insertSRList.add(sr);
    
            ServiceResource sr2 = TestDataFactoryForService.createResource(stList[0].Id);
            sr2.RelatedRecordId = testUser.Id;
            sr2.StaffNumber__c = '6482';
            sr2.LastKnownLatitude = 37.557718278300890;
            sr2.LastKnownLongitude = 126.974039677136940;
            sr2.CurrentStatus__c = 'Work';
            insertSRList.add(sr2);
            insert insertSRList;
    
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
    
            Contact con = TestDataFactoryForService.createContact('CSCustomer', shipToAcc.Id);
            insert con;
    
            List<FailureArea_Major__c > majorList = TestDataFactoryForService.createFailureAreaMajor();
            insert majorList;
            List<FailureAreaMiddle__c > middleList = TestDataFactoryForService.createFailureAreaMiddle();
            insert middleList;
            List<FailurePhenomenon__c > phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
            insert phenomenonList;
    
            Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', shipToAcc.Id, testAsset.Id, con.Id, 'Technical inquiry', 'Failure receipt');
            technicalTicket.RepairRequestDateTime__c = Datetime.now();
            technicalTicket.ApplicationDateTime__c = Datetime.now();
            technicalTicket.ReceptionPath__c = 'Call Center(Representative)';
            insert technicalTicket;
    
            List<WorkOrder> insertWOList = new List<WorkOrder>();
            WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', stList[1].Id, sr.Id);
            wo.ServiceOrderNumber__c = '403908682';
            insertWOList.add(wo);
            WorkOrder wo2 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', stList[1].Id, sr.Id);
            wo2.ServiceOrderNumber__c = '403908683';
            insertWOList.add(wo2);
            insert insertWOList;

            Model__c model = TestDataFactoryForService.createModel();
            insert model;

            ModelManager__c modelManager = TestDataFactoryForService.createModelManager();
            insert modelManager;

            TestDataFactoryForService.activatePriceBook();

            List<Product2> insertProdList = new List<Product2>();
            Product2 prod = TestDataFactoryForService.createProduct();
            insertProdList.add(prod);
            Product2 prod2 = TestDataFactoryForService.createProduct();
            prod2.Name = '220209-00219-KIT';
            prod2.ProductCode = '220209-00219-KIT';
            insertProdList.add(prod2);
            insert insertProdList;

            ProductRequest pr = TestDataFactoryForService.createProductRequest(prod, wo, stList[1]);
            insert pr;

        }
    }

    @isTest
    static void getTicketInfoTest() {

        Case ticket = [SELECT Id FROM Case LIMIT 1];

        DN_TicketDetailController.TicketWrapper result = DN_TicketDetailController.getTicketInfo(ticket.Id);
    }

    @isTest
    static void getSelectAssetAccountTest() {

        Asset asset = [SELECT Id FROM Asset LIMIT 1];

        Asset result = DN_TicketDetailController.getSelectAssetAccount(asset.Id);
    }

    @isTest
    static void judgeAccountIdTest() {

        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name LIKE '%Dealer%' LIMIT 1];

        Test.startTest();
        DN_TicketDetailController.AssetResultWrapper result = DN_TicketDetailController.judgeAccountId(asset.Id, acc.Id);
        DN_TicketDetailController.AssetResultWrapper result2 = DN_TicketDetailController.judgeAccountId(asset.Id, '');
        Test.stopTest();
    }

    @isTest
    static void updateTicketTest() {

        Case ticket = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        Case result = DN_TicketDetailController.getTicket(ticket.Id);
        DN_TicketDetailController.ResultWrapper result2 = DN_TicketDetailController.updateTicket(ticket.Id, 'Esc.Lev 3', UserInfo.getUserId());
        Test.stopTest();
    }

    @isTest
    static void changeAssetFailureAreaMajorTest() {
        
        Asset asset = [SELECT Id FROM Asset LIMIT 1];

        Test.startTest();
        List<DN_TicketDetailController.CustomSelectOptionWrapper> result = DN_TicketDetailController.changeAssetFailureAreaMajor(asset.Id);
        Test.stopTest();
    }


}