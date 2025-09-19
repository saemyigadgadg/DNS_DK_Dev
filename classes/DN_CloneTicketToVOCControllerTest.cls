/**
 * @description       : DN_CloneTicketToVOCControllerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_CloneTicketToVOCControllerTest {
    @TestSetup
    static void makeData(){
        Country__c korea = TestDataFactoryForService.createKRCountry();
        insert korea;

        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST Company', korea);
        insert account;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        Case technicalTicket = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        insert technicalTicket;

        List<FailureArea_Major__c> failureMajorList = TestDataFactoryForService.createFailureAreaMajor();
        insert failureMajorList;
        List<FailureAreaMiddle__c> failureMiddleList = TestDataFactoryForService.createFailureAreaMiddle();
        insert failureMiddleList;
        List<FailurePhenomenon__c> phenomenonList = TestDataFactoryForService.createFailurePhenomenon();
        insert phenomenonList;
    }

    @isTest
    static void testGetTicketInfo(){   
        Case ticket = [SELECT Id FROM Case LIMIT 1];     
        Test.startTest();
        DN_CloneTicketToVOCController.getTicketInfo(ticket.Id);
        DN_CloneTicketToVOCController.getTicketInfo('Exception');
        Test.stopTest();
    }

    @isTest
    static void testGetVOCInfo(){   
        Case ticket = [SELECT Id FROM Case LIMIT 1];     
        Test.startTest();
        DN_CloneTicketToVOCController.getVOCInfo(ticket.Id);
        DN_CloneTicketToVOCController.getVOCInfo('Exception');
        Test.stopTest();
    }

    @isTest
    static void testGetMajorFailureArea(){ 
        Asset equip = [SELECT Id FROM Asset LIMIT 1]; 
        Test.startTest();
        DN_CloneTicketToVOCController.getMajorFailureArea(equip.Id);
        DN_CloneTicketToVOCController.getMajorFailureArea('Exception');
        Test.stopTest();
    }

    @isTest
    static void testGetMiddleFailureArea(){ 
        Test.startTest();
        DN_CloneTicketToVOCController.getMiddleFailureArea('4T0');
        Test.stopTest();
    }

    @isTest
    static void testGetPhenomenonFailure(){ 
        Test.startTest();
        DN_CloneTicketToVOCController.getPhenomenonFailure('4T0', '001');
        Test.stopTest();
    }

    @isTest
    static void testGetAccountInfo(){ 
        Account acc = [SELECT Id FROM Account LIMIT 1]; 
        String data = '{"Name" : "TEST", "MobilePhone" : "01012345678"}';
        Test.startTest();
        DN_CloneTicketToVOCController.getEquipmentOfAccount(acc.Id);
        DN_CloneTicketToVOCController.getEquipmentOfAccount('Exception');
        DN_CloneTicketToVOCController.getContactOfAccount(acc.Id);
        DN_CloneTicketToVOCController.getContactOfAccount('Exception');
        DN_CloneTicketToVOCController.contactSave(acc.Id, data);
        DN_CloneTicketToVOCController.contactSave('Exception', data);
        Test.stopTest();
    }

    @isTest
    static void testSaveRecord(){ 
        Account acc = [SELECT Id FROM Account LIMIT 1]; 
        Asset equip = [SELECT Id FROM Asset WHERE AccountId = :acc.Id LIMIT 1]; 
        String data1 = '{"ApplicationDateTime__c":"2025-06-05T01:41:46.309Z","FailureArea__c":"4T0","FailureAreaDetail__c":"001","FailurePhenomenon__c":"01","TicketType__c":"Technical inquiry","ReceptionPath__c":"Indirect application","AssetId":"'+equip.Id+'","AccountId":"'+acc.Id+'","Dealer__c":"","ReceptionDetails__c":"TEST","InternalTicketType__c":"Failure receipt","BreakdownDateTime__c":"2025-06-05T01:41:46.309Z","RepairRequestDateTime__c":"2025-06-05T02:41:46.309Z","FailureAreaValue__c":"4R0","FailureAreaDetailValue__c":"001","FailurePhenomenonValue__c":"01", "IsUrgency__c":true, "FileCount__c":"0", "CooperationDate__c":"2025-06-01"}';
        Test.startTest();
        DN_CloneTicketToVOCController.saveRecord(data1);
        DN_CloneTicketToVOCController.saveRecord('');
        Test.stopTest();
    }
}