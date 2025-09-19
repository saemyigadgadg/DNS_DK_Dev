/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-08-25
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-24   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_ResourceTrackingController_TEST {
    public DN_ResourceTrackingController_TEST() {}

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
            insert wo;

        }
    }

    @isTest
    static void getInitCaseTest() {
        Case ticket = [SELECT Id FROM Case LIMIT 1];

        Map<String, Object> result = DN_ResourceTrackingController.getInit(ticket.Id);

    }

    @isTest
    static void getSearchTechniciansTest() {

        Map<String, Object> result = DN_ResourceTrackingController.getSearchTechnicians('전체', '전체', '');

    }

    @isTest
    static void getDistanceTechniciansTest() {

        Map<String, Object> result = DN_ResourceTrackingController.getDistanceTechnicians('0', 127.1149905, 36.8622178);

    }

    @isTest
    static void getSearchAddressTest() {
        InterfaceCommonUtil.setInterface('MOIS_ADDRESS', 'IF_MOIS_ADDRESS', 'SUCCESS');
        Test.startTest();
        Map<String, Object> result = DN_ResourceTrackingController.getSearchAddress('대왕판교로');
        Test.stopTest();

    }

    @isTest
    static void getSelectAddressEquipmentTest() {

        // Test.setMock(HttpCalloutMock.class, GetAddressEquipment.respond());

        Map<String, Object> result = DN_ResourceTrackingController.getSelectAddressEquipment('대왕판교로');

    }

    @isTest
    static void getTechnicianSortingListTest() {

        Map<String, Object> technicianListResult = DN_ResourceTrackingController.getSearchTechnicians('전체', '전체', '');
        List<DN_ResourceTrackingController.Technician> technicianList = (List<DN_ResourceTrackingController.Technician>) technicianListResult.get('getTechnicians');

        Map<String, Object> result = DN_ResourceTrackingController.getTechnicianSortingList(technicianList, 'name', 1);
        Map<String, Object> result2 = DN_ResourceTrackingController.getTechnicianSortingList(technicianList, 'name', 2);

    }

    @isTest
    static void getAddressRegioncodeTest() {

        String result = DN_ResourceTrackingController.getAddressRegioncode(127.1149905, 36.8622178);

    }

    @isTest
    static void getObjectTypeTest() {

        Case ticket = [SELECT Id FROM Case LIMIT 1];

        String result = DN_ResourceTrackingController.getObjectType(ticket.Id);

    }

    @isTest
    static void updateServiceOrderTest() {

        WorkOrder serviceOrder = [SELECT Id FROM WorkOrder LIMIT 1];
        ServiceResource sr = [SELECT Id FROM ServiceResource LIMIT 1];
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];

        DN_ResourceTrackingController.ResultWrapper result = DN_ResourceTrackingController.updateServiceOrder(serviceOrder.Id, sr.Id, st.Id);

    }



}