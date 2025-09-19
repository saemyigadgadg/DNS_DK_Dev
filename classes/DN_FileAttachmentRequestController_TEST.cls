/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-28
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-04-02   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_FileAttachmentRequestController_TEST {
    public DN_FileAttachmentRequestController_TEST() {}

    public class IF_SWEET_TRACKER_HttpMock implements HttpCalloutMock {
        public IF_SWEET_TRACKER_HttpMock() {}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse(); 
            
            String resBody = '[{"result":"Y","code":"K000","kind":"K","msgid":"20250404_134650_44","originCode":null,"error":"","sendtime":"2025-04-04 13:46:50","originError":null}]';
            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    @TestSetup
    static void makeData(){

        Interface__c testInterface = new Interface__c();
        testInterface.Name = 'Sweet_Tracker_SendMessage_Op';
        testInterface.EndpointURL__c = 'https://alimtalk-api.sweettracker.net/v2';
        testInterface.HttpMethod__c = 'POST';
        testInterface.ContentType__c = 'application/json; charset=UTF-8';
        testInterface.Timeout__c = 120000;
        testInterface.System__c = 'SWEET TRAKER';
        testInterface.IsActive__c = true;
        insert testInterface;

        InterfaceClasses__c testInterface2 = new InterfaceClasses__c();
        testInterface2.Name = 'IF_SWEET_TRACKER';
        insert testInterface2;

        Alimtalk_Tamplate__mdt alarmTem = [SELECT Id, TemplateCode__c FROM Alimtalk_Tamplate__mdt LIMIT 1];
        
        AlertManager__c alertManager = new AlertManager__c();
        alertManager.Name = 'AS File Attachment Request';
        alertManager.Part__c = 'Service';
        alertManager.IsActive__c = true;
        alertManager.Description__c = 'Test';
        insert alertManager;

        AlertAlarmTalkTemplate__c alertAlarm = new AlertAlarmTalkTemplate__c();
        alertAlarm.Name = 'TestAlarm';
        alertAlarm.AlertManagerID__c = alertManager.Id;
        alertAlarm.AlarmTalkTemplateCode__c = alarmTem.TemplateCode__c;
        alertAlarm.Language__c = 'ko';
        alertAlarm.Name = 'TestAlarm';
        insert alertAlarm;


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
        }
    }

    @isTest
    static void testSendFileAlarmtalk() {

        Case ticket = [SELECT Id FROM Case LIMIT 1];

        DN_FileAttachmentRequestController.ResultWrapper result = DN_FileAttachmentRequestController.sendFileAlarmtalk(ticket.Id);
    }
}