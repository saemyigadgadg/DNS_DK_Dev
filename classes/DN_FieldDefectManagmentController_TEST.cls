/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-22
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-26   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_FieldDefectManagmentController_TEST {
    public DN_FieldDefectManagmentController_TEST() {}

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

            ProductRequest pr = TestDataFactoryForService.createProductRequest(prod, wo, stList[1]);
            insert pr;

        }
    }

    @isTest
    static void getInitTest() {

        Case ticket = [SELECT Id FROM Case LIMIT 1];

        List<String> fieldApiNames = new List<String>{'Severity__c', 'Urgency__c','InstallationDefect__c', 'SkillCheck__c', 'Pendingprocessing__c'};

        Map<String, Object> result = DN_FieldDefectManagmentController.getInit(ticket.Id, fieldApiNames);
    }

    @isTest
    static void saveTicketTest() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-032', 'IF_ERP_Receipt');

        Case ticket = [SELECT Id FROM Case LIMIT 1];

        String saveObject = '{"address":"(33181) 충청남도 천안시 서북구 직산읍 4산단3로","allOrderCount":240,"createdDate":"2025-01-02 AM 09:00","installationDefect":"Y","installer":"김동현","installerWC":"광명산업","installFinishDate":"2023. 12. 16.","isReGenerate":true,"isUrgency":true,"middleType":"미오후납","notiNumList":[],"orderAverage":16,"orderCount":0,"ownerName":"서영덕 Yeongdeok Seo","pendingProcessing":"Parts","pendingProcessingDetail":"종결테스트","pendingProcessingLabel":"부품","productCategory":"Double Column M/C","receptionDetail":"[긴급][재발생][Urgency][ReGenerate]test","requester":"서비스요원","requesterPhone":"01031797674","reservation":"N","severity":"S1","technicalReview":"N","urgency":"SP","urgencyEquip":"긴급","countermeasure":"test","complaint":"test"}';

        Test.startTest();
        DN_FieldDefectManagmentController.ResultWrapper result = DN_FieldDefectManagmentController.saveTicket(ticket.Id, saveObject);
        Test.stopTest();
    }

    @isTest
    static void getListviewModalInitTest() {

        Test.startTest();
        Map<String, Object> result = DN_FieldDefectManagmentController.getListviewModalInit();
        Test.stopTest();
    }

    @isTest
    static void searchDataTest() {

        String jsonString = '{"listviewStart":"2025-03-26","listviewEnd":"2025-03-26","listviewCompleValue":"미결","listviewOrderNumber":"","listviewPenddingvalue":"","listviewWorkcenterValue":"","listviewTopWorkcenterValue":"","listviewInstDefectValue":"","listviewTechnicalReviewValue":"","listviewWarrantyValue":"","listviewTicketCompleValue":"미결"}';

        Test.startTest();
        List<WorkOrder> result = DN_FieldDefectManagmentController.searchData(jsonString);
        DN_FieldDefectManagmentController.ListviewResultWrapper result2 = DN_FieldDefectManagmentController.searchData2(result);
        Test.stopTest();
    }

    @isTest
    static void getIF007Test() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-007', 'IF_ERP_Material');

        String num = '403908682';

        Test.startTest();
        Object result = DN_FieldDefectManagmentController.getIF007(num);
        Test.stopTest();
    }

    @isTest
    static void getIF008Test() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-008', 'IF_ERP_Receipt');

        String num = '403908682';

        Test.startTest();
        Map<String, Object> result = DN_FieldDefectManagmentController.getIF008(num);
        Test.stopTest();
    }

    @isTest
    static void getIF033Test() {

        InterfaceCommonUtil.setInterface('IF-CSPLUS-033', 'IF_ERP_Receipt');

        String num = '403908682';
        
        Test.startTest();
        Object result = DN_FieldDefectManagmentController.getIF033(num);
        Test.stopTest();
    }

    // @isTest
    // static void convertTest() {

    //     String dateString = '2025-03-26';
        
    //     Test.startTest();
    //     Date result = DN_FieldDefectManagmentController.convertDate(dateString);
    //     Datetime result2 = DN_FieldDefectManagmentController.convertDatetime(dateString);
    //     Test.stopTest();
    // }
}