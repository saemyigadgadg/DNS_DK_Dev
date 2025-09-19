/**
 * @description       : DN_NewTicketBtnController_TEST
 * @author            : Hayeong Min
 * @last test date    : 2025-03-21
 * @last modified by  : Hayeong Min
 * @Percentage        : 93%
**/
@isTest
public with sharing class DN_NewTicketBtnControllerTest {
    @TestSetup
    static void makeData(){

        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;
        Country__c us = TestDataFactoryForService.createUSCountry();
        insert us;

        // User dnsaUser = TestDataFactoryForService.createDNSAUser('4140', 'DNSA CS Service', 'DNSA_CS');
        // insert dnsaUser;
        
        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        insert account;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        Case generalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'General inquiry', 'Other inquiry');
        insert generalTicket;

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;

        Case dnsaTicket = TestDataFactoryForService.createCase('Ticket_DNSA', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert dnsaTicket;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;

    }

    @isTest
    static void testGetRecordInfo(){        
        Test.startTest();
        DN_NewTicketBtnController.getRecordInfo();
        Test.stopTest();
    }

    @isTest
    static void testGetInfoRelatedAccount(){
        Account account = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        String newConData = '{"Name":"TEST Contact","MobilePhone":"00000000000"}';

        Test.startTest();

        DN_NewTicketBtnController.getEquipmentOfAccount(account.Id);
        DN_NewTicketBtnController.getEquipmentOfAccount('Exception');
        DN_NewTicketBtnController.getContactOfAccount(account.Id);
        DN_NewTicketBtnController.getContactOfAccount('000000000000000');
        DN_NewTicketBtnController.getAccount(asset.Id);
        DN_NewTicketBtnController.getAccount('Exception');
        DN_NewTicketBtnController.contactSave(account.Id, newConData);
        DN_NewTicketBtnController.contactSave(account.Id, '');

        Test.stopTest();
    }

    @isTest
    static void testGetFailureInfo(){
        Asset asset = [SELECT Id FROM Asset LIMIT 1];
        
        Test.startTest();

        DN_NewTicketBtnController.getMajorFailureArea(asset.Id, 'DNS');
        DN_NewTicketBtnController.getMajorFailureArea('Exception', 'DNS');
        DN_NewTicketBtnController.getMiddleFailureArea('4T0');
        DN_NewTicketBtnController.getMiddleFailureArea('');
        DN_NewTicketBtnController.getPhenomenonFailure('4T0', '001');
        DN_NewTicketBtnController.getPhenomenonFailure('Exception', 'Exception');

        Test.stopTest();
    }

    @isTest
    static void testGetTicketInfo(){    
        Case generalCase = [SELECT Id FROM Case WHERE TicketType__c = 'General inquiry' LIMIT 1];
        Case technicalCase = [SELECT Id FROM Case WHERE TicketType__c = 'Technical inquiry' LIMIT 1];

        Test.startTest();
        DN_NewTicketBtnController.getTicketInfo(generalCase.Id);
        DN_NewTicketBtnController.getTicketInfo(technicalCase.Id);
        DN_NewTicketBtnController.getTicketInfo('Exception');
        Test.stopTest();
    }

    @isTest
    static void testGetAvailableRecordType(){    
        Case dnsCase = [SELECT Id FROM Case WHERE FM_Country__c = 'DNS' LIMIT 1];
        Case dnsaCase = [SELECT Id, RecordTypeId FROM Case WHERE FM_Country__c = 'DNSA' LIMIT 1];

        Test.startTest();
        DN_NewTicketBtnController.getAvailableRecordType(dnsCase.Id);
        

        // User dnsaUser = TestDataFactoryForService.createDNSAUser('4140', 'DNSA CS Service', 'DNSA_CS');
        // insert dnsaUser;
        // System.runAs(dnsaUser) {
        //     System.debug('dnsaUser :: '+dnsaUser);
        //     System.debug('dnsaCase :: '+dnsaCase);
        //     DN_NewTicketBtnController.getAvailableRecordType(dnsaCase.Id);
        // }

        Test.stopTest();
    }

    @isTest
    static void testSaveTicket(){    
        Case dnsCase = [SELECT Id, RecordTypeId, AssetId, AccountId, Requester__c FROM Case WHERE FM_Country__c = 'DNS' LIMIT 1];
        String dnsData = '{"ApplicationDateTime__c":"2025-03-24T05:05:29.008Z","FailureArea__c":"4T0","FailureAreaDetail__c":"001","FailurePhenomenon__c":"01","TicketType__c":"Technical inquiry","ReceptionPath__c":"Indirect application","AssetId":"'+dnsCase.AssetId+'","AccountId":"'+dnsCase.AccountId+'","Requester__c":"'+dnsCase.Requester__c+'","ReceptionDetails__c":"test","InternalTicketType__c":"Failure receipt","BreakdownDateTime__c":"2025-03-24T05:05:29.008Z","RepairRequestDateTime__c":"2025-03-24T23:30:00.000Z","FailureAreaValue__c":"4T0","FailureAreaDetailValue__c":"001","FailurePhenomenonValue__c":"01", "IsUrgency__c":true, "checkBillingStatus__c":"Y", "CooperationDate__c":"2024-11-26", "FileCount__c":"1"}';
        String checkAssetAccount = '{"ApplicationDateTime__c":"2025-03-24T05:05:29.008Z","FailureArea__c":"4T0","FailureAreaDetail__c":"001","FailurePhenomenon__c":"01","TicketType__c":"Technical inquiry","ReceptionPath__c":"Indirect application","AssetId":"'+dnsCase.AssetId+'","AccountId":"TEST Account","Requester__c":"'+dnsCase.Requester__c+'","ReceptionDetails__c":"test","InternalTicketType__c":"Failure receipt","BreakdownDateTime__c":"2025-03-24T05:05:29.008Z","RepairRequestDateTime__c":"2025-03-24T23:30:00.000Z","FailureAreaValue__c":"4T0","FailureAreaDetailValue__c":"001","FailurePhenomenonValue__c":"01", "IsUrgency__c":true, "checkBillingStatus__c":"Y"}';
        Case dnsaCase = [SELECT Id, RecordTypeId, AssetId, AccountId, Requester__c FROM Case WHERE FM_Country__c = 'DNSA' LIMIT 1];
        String dnsaData = '{"ApplicationDateTime__c":"2025-03-24T05:05:29.008Z","FailureArea__c":"4T0","FailureAreaDetail__c":"001","FailurePhenomenon__c":"01","TicketType__c":"Technical inquiry","ReceptionPath__c":"Indirect application","AssetId":"'+dnsaCase.AssetId+'","AccountId":"'+dnsaCase.AccountId+'","Dealer__c":"'+dnsaCase.AccountId+'","Requester__c":"'+dnsaCase.Requester__c+'","ReceptionDetails__c":"test","InternalTicketType__c":"Failure receipt","BreakdownDateTime__c":"2025-03-24T05:05:29.008Z","RepairRequestDateTime__c":"2025-03-24T23:30:00.000Z","FailureAreaValue__c":"4T0","FailureAreaDetailValue__c":"001","FailurePhenomenonValue__c":"01"}';
        
        Test.startTest();
        DN_NewTicketBtnController.getRecordTypeId('Ticket_Domestic');
        DN_NewTicketBtnController.saveTicket(dnsCase.RecordTypeId, dnsData);
        DN_NewTicketBtnController.saveTicket(dnsaCase.RecordTypeId, dnsaData);
        DN_NewTicketBtnController.saveTicket(dnsCase.RecordTypeId, checkAssetAccount);
        DN_NewTicketBtnController.saveTicket(dnsCase.RecordTypeId, '');
        DN_NewTicketBtnController.changeRecordType(dnsCase.Id, dnsCase.RecordTypeId, dnsData);
        DN_NewTicketBtnController.changeRecordType('Exception', dnsCase.RecordTypeId, dnsData);
        
        Test.stopTest();
    }
}