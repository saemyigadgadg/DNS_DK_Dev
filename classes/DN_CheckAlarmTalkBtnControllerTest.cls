/**
 * @description       : DN_CheckAlarmTalkBtnControllerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : Hayeong Min
 * @Percentage        : 
**/
@isTest
public with sharing class DN_CheckAlarmTalkBtnControllerTest {
    @TestSetup
    static void makeData(){
 
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
 
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' LIMIT 1];
 
        User u = new User();
        u.Alias               = 'SBTAdmin';
        u.Phone               = '01012345678';
        u.Email               = 'sbtAdmin@test.com';
        u.EmailEncodingKey    = 'UTF-8';
        u.LastName            = 'testAdmin';
        u.LanguageLocaleKey   = 'en_US';
        u.LocaleSidKey        = 'ko';
        u.ProfileId           = testProfile.Id;
        u.TimeZoneSidKey      = 'Asia/Seoul';
        u.UserName            = 'sbtAdmin3@solution.com';
        insert u;
        
        Account account = TestDataFactoryForService.createAccount('TradeCustomer', 'TradeCustomer Company', country);
        insert account;

        Asset asset = TestDataFactoryForService.createAsset(account.Id);
        insert asset;

        Contact contact = TestDataFactoryForService.createContact('CSCustomer', account.Id);
        insert contact;

        List<Case> caseList = new List<Case>();
        Case ticket1 = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, null, 'Technical inquiry' , 'Technical consultation');
        ticket1.ReceptionPath__c = 'Alarm Talk';
        caseList.add(ticket1);

        Case ticket2 = TestDataFactoryForService.createCase('Ticket_Domestic', account.Id, asset.Id, contact.Id, 'Technical inquiry', 'Failure receipt');
        ticket2.ReceptionPath__c = 'Alarm Talk';
        caseList.add(ticket2);

        insert caseList;
        
        List<AlarmTalk__c> alarmTalkList = new List<AlarmTalk__c>();
        AlarmTalk__c alarmTalk1 = new AlarmTalk__c(
            Name = '[알림톡] 고객 문의', 
            Account__c = account.Id,
            Contact__c = contact.Id,
            Phone__c = '00000000000',
            Symptom__c = 'TEST',
            RequestedTerm__c = 'TEST',
            ServicePart__c = 'TEST',
            TheWayOfProceeding__c = 'Technical inquiry',
            Address__c = 'TEST',
            DetailAddress__c = 'TEST',
            Ticket__c = ticket1.Id
        );
        alarmTalkList.add(alarmTalk1);

        AlarmTalk__c alarmTalk2 = new AlarmTalk__c(
            Name = '[알림톡] 고객 문의', 
            Account__c = account.Id,
            Contact__c = contact.Id,
            Phone__c = '00000000000',
            Symptom__c = 'TEST',
            RequestedTerm__c = 'TEST',
            ServicePart__c = 'TEST',
            TheWayOfProceeding__c = 'Dispatch repair',
            RepairRequestDateTime__c = Date.newInstance(2025, 5, 20),
            Address__c = 'TEST',
            DetailAddress__c = 'TEST',
            Ticket__c = ticket2.Id
        );
        alarmTalkList.add(alarmTalk2);

        insert alarmTalkList;

        List<OperatingHours> operatingList = TestDataFactoryForService.createOperatingHours();
        insert operatingList;

        List<ServiceTerritory> territoryList = TestDataFactoryForService.createTerritory();
        insert territoryList;

        ServiceResource worker = TestDataFactoryForService.createResource(territoryList[0].Id, u.Id);
        insert worker;

        List<WorkOrder> woList = new List<WorkOrder>();
        WorkOrder wo1 = TestDataFactoryForService.createDNSWorkOrder('WorkOrder_Domestic', ticket2.Id, '201', worker.Service_Territory__c, worker.Id);
        wo1.TicketType__c = 'Failure receipt';
        wo1.ServiceOrderNumber__c = '403908702';
        wo1.TimeAgreedOnSite__c = System.now().addHours(4);
        System.debug('WorkOrder :: '+ wo1);
        woList.add(wo1);
        insert woList;
        
    }

    @isTest
    static void testGetAlarmTalkInfo(){        
        Case ticket1 = [SELECT Id FROM CASE WHERE InternalTicketType__c = 'Technical consultation' LIMIT 1];
        Case ticket2 = [SELECT Id FROM CASE WHERE InternalTicketType__c = 'Failure receipt' LIMIT 1];
        Test.startTest();
        DN_CheckAlarmTalkBtnController.getAlarmTalkInfo(ticket1.Id);
        DN_CheckAlarmTalkBtnController.getAlarmTalkInfo(ticket2.Id);
        DN_CheckAlarmTalkBtnController.getAlarmTalkInfo('Exception');
        Test.stopTest();
    }
}