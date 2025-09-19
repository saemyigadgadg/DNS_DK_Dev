/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 06-05-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class DN_PartBillingControllerTest {

    @TestSetup
    static void makeData(){
        // Profile 생성
        // Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
        String testProfile = UserInfo.getProfileId();
        User user1 = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;
        
        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        insert account;

        
        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;
        
        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;

        List<OperatingHours> hours = TestDataFactoryForService.createOperatingHours();        
        insert hours;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();       
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ServiceResource resource = TestDataFactoryForService.createResource(territory.Id);       
        insert resource;

        WorkOrder wo = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', technicalTicket.Id, '201', territory.Id, resource.Id);
        insert wo;

        TestDataFactoryForSales.activatePriceBook();

        Product2 prod = TestDataFactoryForService.createProduct();
        insert prod;

        PricebookEntry entry = TestDataFactoryForSales.createPriceBookEntry(prod, 'KRW');
        insert entry;

        ProductRequest pr = TestDataFactoryForService.createProductRequest(prod, wo, territory);
        pr.Status = 'New';
        insert pr;

        NotiReceptionList__c noti = new NotiReceptionList__c(
            Name = 'IndirectReception',
            UserName__c = UserInfo.getUserName()
        );
        insert noti;
        AlertManager__c alert = new AlertManager__c(
            Name = 'CS Part Billing Noti',
            IsActive__c = true
        );
        insert alert;
        AlertManager__c alertDelete = new AlertManager__c(
            Name = 'CS Part Delete Billing Noti',
            IsActive__c = true
        );
        insert alertDelete;
    }

    @isTest
    static void searchProductsTest_productNumber() {
        Product2 pro = [SELECT Id, Name FROM Product2 WHERE Name = 'R18181' LIMIT 1];

        Test.startTest();
        DN_PartBillingController.searchProducts(pro.Id, 'productNumber');
        Test.stopTest();
    }

    @isTest
    static void searchProductsTest_MaterialDetails() {
        Product2 pro = [SELECT Id, Name FROM Product2 WHERE Name = 'R18181' LIMIT 1];

        Test.startTest();
        DN_PartBillingController.searchProducts(pro.Id, 'FM_MaterialDetails__c');
        Test.stopTest();
    }

    @isTest
    static void searchProductsTest_productSpec() {
        Product2 pro = [SELECT Id, Name FROM Product2 WHERE Name = 'R18181' LIMIT 1];

        Test.startTest();
        DN_PartBillingController.searchProducts(pro.Id, 'productSpec');
        Test.stopTest();
    }

    @isTest
    static void getDealerStocksTest() {
        Product2 pro = [SELECT Id, Name FROM Product2 WHERE Name = 'R18181' LIMIT 1];

        Test.startTest();
        DN_PartBillingController.getDealerStocks(pro.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getWorkOrderTest() {
        // Product2 pro = [SELECT Id, Name FROM Product2 WHERE Name = 'R18181' LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        DN_PartBillingController.getWorkOrder(wo.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getPartRequestsTest() {
        Product2 pro = [SELECT Id, Name FROM Product2 WHERE Name = 'R18181' LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        ProductRequest pr = [SELECT Id FROM ProductRequest LIMIT 1];

        Test.startTest();
        DN_PartBillingController.getPartRequests(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void getWorkOrdersTest() {
        // Product2 pro = [SELECT Id, Name FROM Product2 WHERE Name = 'R18181' LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];

        Test.startTest();
        DN_PartBillingController.getWorkOrders(wo.Id);
        Test.stopTest();
    }

    @isTest
    static void getPartProgressTest() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-007', 'IF_ERP_Material');

        String notiNum = '403908682';

        Test.startTest();
        DN_PartBillingController.getPartProgress(notiNum);
        Test.stopTest();
    }

    @isTest
    static void getDealerInventoryTest() {
        Product2 pro = [SELECT Id, Name FROM Product2 WHERE Name = 'R18181' LIMIT 1];
        InterfaceCommonUtil.setInterface('IF-CSPLUS-021', 'IF_ERP_Material');

        // String notiNum = '403908682';

        Test.startTest();
        DN_PartBillingController.getDealerInventory(pro.Id);
        Test.stopTest();
    }
    
    @isTest
    static void createProductRequestTest() {
        Product2 pro = [SELECT Id, Name FROM Product2 WHERE Name = 'R18181' LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        NotiReceptionList__c noti = [SELECT Id FROM NotiReceptionList__c WHERE Name = 'IndirectReception' LIMIT 1];
        AlertManager__c alert = [SELECT Id FROM AlertManager__c WHERE Name = 'CS Part Billing Noti' LIMIT 1];

        Test.startTest();
        DN_PartBillingController.createProductRequest(pro.Id, wo.Id, 1);
        Test.stopTest();
    }
    
    @isTest
    static void deleteProductRequestTest() {
        Product2 pro = [SELECT Id, Name FROM Product2 WHERE Name = 'R18181' LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        ProductRequest pr = [SELECT Id FROM ProductRequest WHERE Status = 'New' LIMIT 1];
        NotiReceptionList__c noti = [SELECT Id FROM NotiReceptionList__c WHERE Name = 'IndirectReception' LIMIT 1];
        AlertManager__c alertDelete = [SELECT Id FROM AlertManager__c WHERE Name = 'CS Part Delete Billing Noti' LIMIT 1];

        Test.startTest();
        DN_PartBillingController.deleteProductRequest(pr.Id, wo.Id);
        Test.stopTest();
    }

}