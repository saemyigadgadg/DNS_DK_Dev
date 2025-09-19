/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-29
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-26   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PartProgressController_TEST {
    public DN_PartProgressController_TEST() {}
    
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
            insert technicalTicket;
    
            WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', stList[1].Id, sr.Id);
            wo.ServiceOrderNumber__c = '403908682';
            insert wo;

            Model__c model = TestDataFactoryForService.createModel();
            insert model;

            ModelManager__c modelManager = TestDataFactoryForService.createModelManager();
            insert modelManager;

            TestDataFactoryForService.activatePriceBook();

            Product2 prod = TestDataFactoryForService.createProduct();
            insert prod;

        }
    }

    @isTest
    static void getInitTest() {
        
        DN_PartProgressController.SearchObject result = DN_PartProgressController.getInit();

    }

    @isTest
    static void searchGijongListTest() {

        DN_PartProgressController.ResultWrapper result = DN_PartProgressController.searchGijongList('DNM');
        DN_PartProgressController.ResultWrapper result2 = DN_PartProgressController.searchGijongList('Test');
    }

    @isTest
    static void getPartsListZeroTest() {
        
        DN_PartProgressController.SearchObject searchObject = new DN_PartProgressController.SearchObject();
        searchObject.searchStartDate = Datetime.now().format('yyyy-MM-dd');
        searchObject.searchEndDate = Datetime.now().format('yyyy-MM-dd');
        searchObject.searchStatus = '0';
        searchObject.CNFCheck = false;

        DN_PartProgressController.PartsResultWrapper result = DN_PartProgressController.getPartsList(searchObject);
    }

    @isTest
    static void getPartsListTest() {

        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];

        ProductRequest pr = new ProductRequest();
        pr.Product__c = prod.Id;
        pr.WorkOrderId = wo.Id;
        pr.TransportsDivision__c = '20';
        pr.DeliveryDate__c = Date.today();
        pr.ProgressStatus__c = '배송완료';
        pr.OrderQuantity__c = 1;
        pr.Inventory__c = '1';
        pr.PackagingCompleted__c = 1;
        pr.VNDNM__c = 'Test';
        pr.ReturnStatus__c = 'N';
        pr.SALES__c = '';
        pr.TrackingNumber__c = '';
        pr.WarehouseReleaseNumber__c = '';
        pr.ShipToName__c = 'Test';
        pr.CompanyName__c = 'Test';
        pr.WorkCenter__c = st.Id;
        pr.RECV_DT__c = Date.today();
        pr.PartsRequestDate__c = Date.today();
        pr.Seq__c = '0010';
        pr.IsDealerPortalDelete__c = false;
        pr.Status = 'Approved';

        insert pr;

        
        DN_PartProgressController.SearchObject searchObject = new DN_PartProgressController.SearchObject();
        searchObject.searchStartDate = Datetime.now().format('yyyy-MM-dd');
        searchObject.searchEndDate = Datetime.now().format('yyyy-MM-dd');
        searchObject.searchStatus = '0';
        searchObject.CNFCheck = false;

        DN_PartProgressController.PartsResultWrapper result = DN_PartProgressController.getPartsList(searchObject);
    }

    @isTest
    static void getPartsListInterfaceTest() {

        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];

        ProductRequest pr = new ProductRequest();
        pr.Product__c = prod.Id;
        pr.WorkOrderId = wo.Id;
        pr.TransportsDivision__c = '20';
        pr.DeliveryDate__c = Date.today();
        pr.ProgressStatus__c = '배송완료';
        pr.OrderQuantity__c = 1;
        pr.Inventory__c = '1';
        pr.PackagingCompleted__c = 1;
        pr.VNDNM__c = 'Test';
        pr.ReturnStatus__c = 'N';
        pr.SALES__c = '';
        pr.TrackingNumber__c = '';
        pr.WarehouseReleaseNumber__c = '';
        pr.ShipToName__c = 'Test';
        pr.CompanyName__c = 'Test';
        pr.WorkCenter__c = st.Id;
        pr.RECV_DT__c = Date.today();
        pr.PartsRequestDate__c = Date.today();
        pr.Seq__c = '0010';
        pr.IsDealerPortalDelete__c = false;
        pr.Status = 'Approved';

        insert pr;

        InterfaceCommonUtil.setInterface('IF-CSPLUS-007', 'IF_ERP_Material');
        
        DN_PartProgressController.SearchObject searchObject = new DN_PartProgressController.SearchObject();
        searchObject.searchStartDate = Datetime.now().format('yyyy-MM-dd');
        searchObject.searchEndDate = Datetime.now().format('yyyy-MM-dd');
        searchObject.searchStatus = '0';
        searchObject.searchOrderNumber = '403908682';
        searchObject.CNFCheck = false;

        Test.startTest();
        DN_PartProgressController.PartsResultWrapper result = DN_PartProgressController.getPartsList(searchObject);
        Test.stopTest();
    }

    @isTest
    static void getPartsInfoTest() {

        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        WorkOrder wo = [SELECT Id, ServiceOrderNumber__c FROM WorkOrder LIMIT 1];
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];

        ProductRequest pr = new ProductRequest();
        pr.Product__c = prod.Id;
        pr.WorkOrderId = wo.Id;
        pr.TransportsDivision__c = '20';
        pr.DeliveryDate__c = Date.today();
        pr.ProgressStatus__c = '배송완료';
        pr.OrderQuantity__c = 1;
        pr.Inventory__c = '1';
        pr.PackagingCompleted__c = 1;
        pr.VNDNM__c = 'Test';
        pr.ReturnStatus__c = 'N';
        pr.SALES__c = '';
        pr.TrackingNumber__c = '';
        pr.WarehouseReleaseNumber__c = '';
        pr.ShipToName__c = 'Test';
        pr.CompanyName__c = 'Test';
        pr.WorkCenter__c = st.Id;
        pr.RECV_DT__c = Date.today();
        pr.PartsRequestDate__c = Date.today();
        pr.Seq__c = '0010';
        pr.IsDealerPortalDelete__c = false;
        pr.Status = 'Approved';

        insert pr;

        List<String> numList = new List<String>{'403908682'};

        Map<String, DN_PartProgressController.PartsInfo> result = DN_PartProgressController.getPartsInfo(numList);
    }
}