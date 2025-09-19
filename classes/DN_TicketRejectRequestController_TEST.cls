/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 05-30-2025
 * @last modified by  : Hanyeong Choi
**/
@isTest
public with sharing class DN_TicketRejectRequestController_TEST {
    @TestSetup
    static void setUp() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];

        AlertManager__c am = TestDataFactoryForSales.createAlertManager('Ticket Reject Request Alert');
        insert am;
        
        
        User user;
        System.runAs(thisUser) {
            user = TestDataFactoryForService.createDNSUser('1800', profile.Name, 'CSDept');
            insert user;

            Case ticket = new Case();
            insert ticket;
        }

        System.runAs(user) {
            Case ticket = new Case();
            insert ticket;
        }

    }

    @isTest
    static void sendTicketRejectRequest_Test() {
        Case ticket = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        DN_TicketRejectRequestController.sendTicketRejectRequest(String.valueOf(ticket.Id), 'test');
        Test.stopTest();
    }

    @isTest
    static void sendTicketRejectRequestKR_Test() {
        User u = [SELECT Id FROM User WHERE LastName = 'testuser' LIMIT 1];
        Case ticket = [SELECT Id FROM Case WHERE OwnerId = :u.Id LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            DN_TicketRejectRequestController.sendTicketRejectRequest(String.valueOf(ticket.Id), 'test');
            Test.stopTest();
        }
    }
}