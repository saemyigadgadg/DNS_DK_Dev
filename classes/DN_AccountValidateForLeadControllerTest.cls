/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-07
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-07   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_AccountValidateForLeadControllerTest {

    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'LeadTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        System.runAs(thisUser) {

            Lead testLead = TestDataFactoryForSales.createLead('DNS', country);
            testLead.Representative__c = '김김대표';
            insert testLead;


            Lead testLead2 = TestDataFactoryForSales.createLead('DNS', country);
            testLead2.Company = 'anotherCompany';
            testLead2.Email = 'another@email.com';
            testLead2.Phone = '010-111-222';
            testLead2.MobilePhone = '010-111-222';
            testLead2.IsERPValidated__c =  true;

            insert testLead2;
        }

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-ACCOUNT-014', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Account', ifc.Id);
        insert ifClass;
        
    }

    @isTest
    static void validationTest(){

        TriggerHandler.bypassedHandlers = new Set<String>{'LeadTriggerHandler'};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Account());

        Lead lead = [SELECT Id, Company, Representative__c, IsERPValidated__c FROM Lead WHERE IsERPValidated__c = false  LIMIT 1];

        DN_AccountValidateForLeadController.checkAccountDuplication(lead.Id);

        Test.stopTest();
    }

    @isTest
    static void testMissing(){

        TriggerHandler.bypassedHandlers = new Set<String>{'LeadTriggerHandler'};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Account());

        Lead lead = [SELECT Id, Company, Representative__c, IsERPValidated__c FROM Lead WHERE IsERPValidated__c = true LIMIT 1];

        DN_AccountValidateForLeadController.checkAccountDuplication(lead.Id);
        Test.stopTest();
    }



    @isTest
    static void testDuplicateAccount(){

        TriggerHandler.bypassedHandlers = new Set<String>{'LeadTriggerHandler'};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_AccountDuplicate());

        Lead lead = [SELECT Id, Company, Representative__c, IsERPValidated__c FROM Lead LIMIT 1];

        DN_AccountValidateForLeadController.checkAccountDuplication(lead.Id);


        Test.stopTest();
    }


    @isTest
    static void testERPFailure(){

        TriggerHandler.bypassedHandlers = new Set<String>{'LeadTriggerHandler'};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_AccountFailure());

        Lead lead = [SELECT Id, Company, Representative__c, IsERPValidated__c FROM Lead LIMIT 1];

        DN_AccountValidateForLeadController.checkAccountDuplication(lead.Id);


        Test.stopTest();
    }

    // Mock ERP API Call - Success
    private class MockIF_ERP_Account implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                // '{' +
                //     '"O_RECODE": "S",' +
                //     '"O_REMSG": "광어회사;No data found.",' +
                //     '"O_RETURN": "N",' +
                //     '"T_KNA1": []' +
                // '}'

                '{"O_RECODE":"S","O_REMSG":"Malta Test;No data found.","O_RETURN":"N","T_KNA1":[]}'

            );
            return res;
        }
    }

    // Mock ERP API Call - Duplicate
    private class MockIF_ERP_AccountDuplicate implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                // '{' +
                //     '"O_RECODE": "F",' +
                //     '"O_RETURN": "Y"' +
                // '}'

                '{"O_RECODE":"F","O_REMSG":"Malta Test;No data found.","O_RETURN":"Y","T_KNA1":[]}'

            );
            return res;
        }
    }

    // Mock ERP API Call - Failure
    private class MockIF_ERP_AccountFailure implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            res.setBody(
                // '{' +
                //     '"O_RECODE": "E",' +
                //     '"O_RETURN": "Error Occurred"' +
                // '}'
                '{"O_RECODE":"F","O_REMSG":"Malta Test;No data found.","O_RETURN":"","T_KNA1":[]}'

            );
            return res;
        }
    }



}