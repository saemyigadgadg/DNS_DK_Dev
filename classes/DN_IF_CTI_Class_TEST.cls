/**
 * @author            : Yeong-Deok Seo
 * @description       : 
 * @last modified on  : 2025-06-17
 * @last modified by  : yeongdeok.seo@sbtglobal.com
**/
@isTest
public with sharing class DN_IF_CTI_Class_TEST {
    public DN_IF_CTI_Class_TEST() {}

    @TestSetup
    static void makeData(){

        String profileId = UserInfo.getProfileId();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :profileId];

        User thisUser = [SELECT Id, UserName FROM User WHERE Id =: UserInfo.getUserId()];

        User user;
        System.runAs(thisUser) {
            user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
            user.LastName = 'Test User Test';
            insert user;
        }

        Alimtalk_Tamplate__mdt alarmTem = [SELECT Id, TemplateCode__c FROM Alimtalk_Tamplate__mdt LIMIT 1];
        AlertManager__c alertManager = new AlertManager__c();
        alertManager.Name = 'Call AS AlarmTalk';
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

        List<NotiReceptionList__c> insertNotiRecepList = new List<NotiReceptionList__c>();
        NotiReceptionList__c notiRecep1 = new NotiReceptionList__c();
        notiRecep1.Name = 'IndirectReception';
        notiRecep1.UserName__c = thisUser.UserName;
        insertNotiRecepList.add(notiRecep1);
        NotiReceptionList__c notiRecep2 = new NotiReceptionList__c();
        notiRecep2.Name = 'AlarmTalk';
        notiRecep2.UserName__c = thisUser.UserName;
        insertNotiRecepList.add(notiRecep2);
        NotiReceptionList__c notiRecep3 = new NotiReceptionList__c();
        notiRecep3.Name = 'PClaimPermission';
        notiRecep3.UserName__c = thisUser.UserName;
        insertNotiRecepList.add(notiRecep3);
        insert insertNotiRecepList;

        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;
        Country__c us = TestDataFactoryForService.createUSCountry();
        insert us;

        List<OperatingHours> hours = TestDataFactoryForService.createOperatingHours();        
        insert hours;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();       
        insert territoryList;

        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory WHERE Name = '창원지사'];
        List<ServiceResource> insertResourceList = new List<ServiceResource>();
        ServiceResource resource1 = TestDataFactoryForService.createResource(territory.Id);
        insertResourceList.add(resource1);
        ServiceResource resource2 = TestDataFactoryForService.createResource(territory.Id, user.Id);
        insertResourceList.add(resource2);
        insert insertResourceList;
        
        List<Account> insertAccountList = new List<Account>();
        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        insertAccountList.add(account);
        Account account2 = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company2', korea);
        insertAccountList.add(account2);
        insert insertAccountList;

        List<Asset> insertAssetList = new List<Asset>();
        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        asset.InstEngineer__c   = resource1.Id;
        insertAssetList.add(asset);
        Asset asset2 = TestDataFactoryForService.createAsset(account2.Id);
        asset2.Name           = 'MH0013-000391';
        asset2.SerialNumber   = 'MH0013-000391';
        insertAssetList.add(asset2);
        Asset asset3 = TestDataFactoryForService.createAsset(account.Id);
        insertAssetList.add(asset3);
        insert insertAssetList;

        List<Contact> insertContactList = new List<Contact>();
        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insertContactList.add(contact);
        Contact contact2 = TestDataFactoryForService.createContact('CSCustomer', account2.Id);
        contact2.LastName = 'testuser2';
        contact2.MobilePhone = '00000000002';
        insertContactList.add(contact2);
        Contact contact3 = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        contact3.LastName = 'testuser3';
        contact3.MobilePhone = '00000000003';
        insertContactList.add(contact3);
        insert insertContactList;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

        List<Case> insertTicketList = new List<Case>();
        Case technicalTicket1 = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insertTicketList.add(technicalTicket1);
        Case technicalTicket2 = TestDataFactoryForService.createCase('Ticket_Domestic', account2.Id, null, contact2.Id, 'Technical inquiry', 'Failure receipt');
        insertTicketList.add(technicalTicket2);
        Case technicalTicket3 = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset3.Id, contact3.Id, 'Technical inquiry', 'Failure receipt');
        insertTicketList.add(technicalTicket3);
        insert insertTicketList;


    }

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

    @isTest
    static void IfCTIAlarmExistTest() {
        Test.setMock(HttpCalloutMock.class, Type.forName('DN_IF_CTI_Class_TEST.IF_SWEET_TRACKER_HttpMock').newInstance());
        RestContext.request = new RestRequest();
        IF_CTI_IsAlarmExist_API.isAlarmExist();
    }

    @isTest
    static void IfCTIReceptionTest() {
        IF_CTI_Reception_API.getReception();
    }

    @isTest
    static void IfCTITicketTest1() {
        RestContext.request = new RestRequest();
        IF_CTI_Ticket_API.getPCPNumberByCSNumber();
    }

    @isTest
    static void IfCTITicketTest2() {
        RestContext.request = new RestRequest();
        RestContext.request.params.put('phoneNumber', '00000000001');
        IF_CTI_Ticket_API.getPCPNumberByCSNumber();
    }

    @isTest
    static void IfCTITicketTest3() {
        RestContext.request = new RestRequest();
        RestContext.request.params.put('phoneNumber', '00000000002');
        IF_CTI_Ticket_API.getPCPNumberByCSNumber();
    }

    @isTest
    static void IfCTITicketTest4() {
        RestContext.request = new RestRequest();
        RestContext.request.params.put('phoneNumber', '00000000000');
        IF_CTI_Ticket_API.getPCPNumberByCSNumber();
    }

    @isTest
    static void IfCTITicketTest5() {
        RestContext.request = new RestRequest();
        RestContext.request.params.put('phoneNumber', '00000000003');
        IF_CTI_Ticket_API.getPCPNumberByCSNumber();
    }

    @isTest
    static void IFCTIUserInfoTest() {
        IF_CTI_UserInfo_API.getPhoneNumber();
    }
}