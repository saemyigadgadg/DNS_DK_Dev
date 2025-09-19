/**
 * @description       : EmailMessageTriggerHandlerTest
 * @author            : Hayeong Min
 * @last test date    : 2025-03-26
 * @last modified by  : yeongju.yun
 * @Percentage        : 
**/
@isTest
public with sharing class EmailMessageTriggerHandlerTest {

    @testSetup
    static void setupData() {


        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Username = 'worker@test.com',
            LastName = 'Worker',
            Email = 'worker@test.com',
            Alias = 'wkr1',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Seoul',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'ko'
        );
        insert u;

        NotiReceptionList__c noti = new NotiReceptionList__c();
        noti.Name = 'AlarmTalk';
        noti.UserName__c = u.Username;
        insert noti;


        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;
        // 계정과 자산
        Account acc = TestDataFactoryForService.createAccount('TradeCustomer', 'TEST', country);
        insert acc;
        Asset asset = TestDataFactoryForService.createAsset(acc.Id);
        insert asset;
        Contact con = TestDataFactoryForService.createContact('CSCustomer', acc.Id);
        insert con;

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        List<AlertManager__c> alertList = new List<AlertManager__c>();
        alertList.add(TestDataFactoryForSales.createAlertManager('Ticket Assignment Alert'));
        alertList.add(TestDataFactoryForSales.createAlertManager('Homepage Ticket Assignment Receptionist Alert'));
        insert alertList;

        String jsonStr = '{'+
            '"country":"Korea, South",'+
            '"srNumber":"SN123456",'+
            '"inqType":"A/S Inquiry",'+
            '"prdName":"XYZ-500",'+
            '"cpName":"DN Company",'+
            '"prdClass":"Lathe",'+
            '"receptionType":"고객의 소리",'+
            '"industry":"자동차",'+
            '"pdCategory":"기계",'+
            '"drInput":"N",'+
            '"title":"기계 고장 문의",'+
            '"content":"기계에서 이상한 소리가 납니다.",'+
            '"receptionChannel":"홈페이지",'+
            '"prdSeries":"XYZ Series",'+
            '"phone":"010-1234-5678",'+
            '"name":"홍길동",'+
            '"region":"서울특별시;강남구",'+
            '"email":"hong@dncompany.com"'+
        '}';

        Id ticketType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();
        Case ticket = TestDataFactoryForService.createCase('Ticket_Domestic',acc.Id, asset.Id, con.Id, 'General inquiry', 'Other inquiry');
        ticket.Description = jsonStr;
        insert ticket;

        AssignmentRule__c rule01 = new AssignmentRule__c(Name = 'DNSA_TicketTeam', AssignmentType__c = 'Owner');
        insert rule01;
        AssignmentRule__c rule02 = new AssignmentRule__c(Name = 'VOC_홈페이지접수', AssignmentType__c = 'Owner');
        insert rule02;
        AssignmentRule__c rule03 = new AssignmentRule__c(Name = '일반상담사 순차배정', AssignmentType__c = 'Owner');
        insert rule03;

        List<AssignmentMember__c> memList = new List<AssignmentMember__c>{
            new AssignmentMember__c(
                AssignmentRule__c = rule01.Id,
                User__c = u.Id,
                CurrentAssignment__c = true
            )
            , new AssignmentMember__c(
                AssignmentRule__c = rule02.Id,
                User__c = u.Id,
                CurrentAssignment__c = true
            )
            , new AssignmentMember__c(
                AssignmentRule__c = rule03.Id,
                User__c = u.Id,
                CurrentAssignment__c = true
            )
        };
        insert memList;
        
        Datetime now = System.now();
        String startHHMM = now.addMinutes(-10).format('HHmm');
        String endHHMM = now.addMinutes(10).format('HHmm');

        ConsultationAttendance__c ca = new ConsultationAttendance__c(
            Consultant__c = thisUser.Id,
            AttendanceDate__c = Date.today(),
            OffStartTime__c = startHHMM,
            OffEndTime__c = endHHMM
        );
        insert ca;
    }

    @isTest
    static void testInsert01() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@dncompany.com';
        email.FromName = 'TEST';
        email.MessageDate = System.today();
        email.Subject = '[MH0014-000391]Test';
        email.ToAddress = 'test.test@dncompany.com';
        email.CcAddress = 'test2@dncompany.com';
        email.ParentId = c.Id;

        Test.startTest();
        TriggerHandler.bypassedHandlers = new Set<String>{'TicketTriggerHandler'};
        insert email;
        Test.stopTest();
    }

    @isTest
    static void testInsert02() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        EmailRoutingAddress rAdd = [SELECT Id FROM EmailRoutingAddress WHERE Address = 'cs.dnsawebinq@dncompany.com' LIMIT 1];

        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@dncompany.com';
        email.FromName = 'TEST';
        email.MessageDate = System.today();
        email.Subject = '[MH0014-000391]Test';
        email.ToAddress = 'test.test@dncompany.com';
        email.CcAddress = 'test2@dncompany.com';
        email.ParentId = c.Id;
        email.EmailRoutingAddressId = rAdd.Id;
        email.Incoming = true;

        Test.startTest();
        TriggerHandler.bypassedHandlers = new Set<String>{'TicketTriggerHandler'};
        insert email;
        Test.stopTest();
    }
    
    // @isTest
    // static void testInsert03() {
    //     Case c = [SELECT Id FROM Case LIMIT 1];
    //     EmailRoutingAddress rAdd = [SELECT Id FROM EmailRoutingAddress WHERE Address = 'cs.dnswebinq@dncompany.com' LIMIT 1];

    //     EmailMessage email = new EmailMessage();
    //     email.FromAddress = 'test@dncompany.com';
    //     email.FromName = 'TEST';
    //     email.MessageDate = System.today();
    //     email.Subject = '[MH0014-000391]Test';
    //     email.ToAddress = 'test.test@dncompany.com';
    //     email.CcAddress = 'test2@dncompany.com';
    //     email.ParentId = c.Id;
    //     email.EmailRoutingAddressId = rAdd.Id;
    //     email.Incoming = true;

    //     Test.startTest();
    //     TriggerHandler.bypassedHandlers = new Set<String>{'TicketTriggerHandler'};
    //     insert email;
    //     Test.stopTest();
    // }
    
    @isTest
    static void testInsert04() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        EmailRoutingAddress rAdd = [SELECT Id FROM EmailRoutingAddress WHERE Address = 'cs.dnsacrm@dncompany.com' LIMIT 1];

        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@dncompany.com';
        email.FromName = 'TEST';
        email.MessageDate = System.today();
        email.Subject = '[MH0014-000391]Test';
        email.ToAddress = 'test.test@dncompany.com';
        email.CcAddress = 'test2@dncompany.com';
        email.ParentId = c.Id;
        email.EmailRoutingAddressId = rAdd.Id;
        email.Incoming = true;

        Test.startTest();
        TriggerHandler.bypassedHandlers = new Set<String>{'TicketTriggerHandler'};
        insert email;
        Test.stopTest();
    }
    
    
    
    /*
    @TestSetup
    static void makeData(){
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@dncompany.com';
        email.FromName = 'TEST';
        email.MessageDate = System.today();
        email.Subject = 'TEST';
        email.ToAddress = 'test.test@dncompany.com';
        insert email;
    }

    @isTest
    static void testDummny(){        
        Test.startTest();
        EmailMessageTriggerHandler.dummy();
        EmailMessageTriggerHandler.dummy2();
        Test.stopTest();
    }
    */
}