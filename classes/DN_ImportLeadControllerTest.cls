/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-20
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-20   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_ImportLeadControllerTest {

    @TestSetup
    static void makeData(){

        Date today = Date.today();

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'UserTriggerHandler', 'LeadTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account prospectAcc = TestDataFactoryForSales.createAccount('ProspectCustomer', country, null);
            prospectAcc.CustomerCode__c = '11111';
            insert prospectAcc; 

            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.Name = 'test Dealer';
            dealerAcc.CustomerCode__c = '22222';
            dealerAcc.Phone = '111-222';

            insert dealerAcc;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;

            Lead testLead = TestDataFactoryForSales.createLead('DNS', country);
            testLead.Representative__c = '김김대표';
            insert testLead;

            Lead testLead2 = TestDataFactoryForSales.createLead('DNS', country);
            // Company + LastName + MobilePhone
            // leadkey = anotherCompanyanother010-111-222
            testLead2.Company = 'anotherCompany';
            testLead2.LastName = 'another';
            testLead2.MobilePhone = '010-111-222';
            testLead2.Email = 'another@email.com';
            testLead2.Phone = '010-111-222';
            testLead2.IsERPValidated__c =  true;
            insert testLead2;

            Event_Management__c em = new Event_Management__c();
            em.EventName__c = 'testEvent';
            em.From__c = today;
            em.To__c = today;
            em.Country__c ='USA';
            insert em;
            
        }
    }


    @isTest
    static void testGetSalesOrg() {
        Test.startTest();
        DN_ImportLeadController.getSalesOrg();
        Test.stopTest();
    }


    @isTest
    static void testGetLeadMetadata() {
        Test.startTest();
        List<String> headersDNS = DN_ImportLeadController.getImportLeadMetadata('Catalog Downloader', false);
        List<String> headersDNSA = DN_ImportLeadController.getImportLeadMetadata('Catalog Downloader', true);
        Test.stopTest();
    }
        

    @isTest
    static void testCatalogDownloaderInsert() {
        String jsonInput = '[' +
            '{' +

                '"Column_0": "22222", ' +
                '"FileName__c": "TestFile.pdf", ' + 
                '"LastName": "Smith", ' +
                '"Company": "Acme Corp", ' +
                '"Address1__c": "123 Main St", ' +
                '"MobilePhone": "555-1234", ' +
                '"Email": "test@example.com", ' +
                '"IsDNSolutionsAvailable__c": "Y", ' +
                '"IsMarketingConsentPhone__c": "동의", ' +
                '"IsMarketingConsentSMS__c": "동의", ' +
                '"IsMarketingConsentEmail__c": "동의", ' +
                '"IsMarketingConsentPost__c": "동의", ' +
                '"MarketingConsentDate__c": "2025-01-01", ' +
                '"LeadSourceCatalog__c": "Online", ' +
                '"DownloadDate__c": "2025-01-02", ' +

                '"TemplateType": "Catalog Downloader", ' +
                '"Year": "2025", ' +
                '"Period": "Annual", ' +
                '"Column_3": "Acme Corp", ' +
                '"Column_2": "Smith", ' +
                '"Column_5": "555-1234"' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportLeadController.upsertRecords(jsonInput, 'Catalog Downloader', 'Catalog Downloader', false);
        Test.stopTest();
    }

    @isTest
    static void testEventVisitorInsert() {

        Event_Management__c em = [
            SELECT  Name
            FROM    Event_Management__c
            WHERE   EventName__c =: 'testEvent'
            LIMIT   1
        ];

        String jsonInput = '[' +
            '{' +
                // 필수 필드: 이벤트 코드, 그리고 lead key 생성에 필요한 값
                '"Column_0": "' + em.Name + '", ' + // 이벤트 코드 (Event_Management__c.Name)
                // 아래부터는 index 기반 할당 (Event Visitor에 대한 필드들은 upsertRecords의 else 분기에서 처리)
                '"EventName__c": "Annual Event", ' +      // index 1 for Event Visitor update branch
                '"VisitTime__c": "2025-02-01 10:00:00", ' +
                '"Company": "Acme Corp", ' +
                '"LastName": "John", ' +
                '"Title": "Manager", ' +
                '"Phone": "555-1234", ' +
                '"MobilePhone": "555-6789", ' +
                '"Email": "john@example.com", ' +
                '"Industry_EventVisitor__c": "IT", ' +
                '"InterestedItem__c": "", ' +
                '"Country__c": "KR", ' +

                '"Region__c": "35", ' +
                '"PostalCode": "12345", ' +
                '"Address1__c": "456 Secondary St", ' +
                '"Address2__c": "Suite 100", ' +
                '"IsDNSolutionsAvailable__c": "Y", ' +
                '"Rating": "Warm", ' +
                '"RequestQuote__c": "Y", ' +
                '"RequestQuoteDate__c": "2025-02-02", ' +
                '"Description": "Interested in our products", ' +
                '"ExcludeLead__c": "N", ' +

                '"TemplateType": "Event Visitor", ' +
                '"Year": "2025", ' +
                '"Column_3": "Acme Corp", ' +  // leadKey: Company
                '"Column_4": "John", ' +       // leadKey: Name (예: First Name)
                '"Column_7": "555-6789"' +   // leadKey: Phone
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportLeadController.upsertRecords(jsonInput, 'Event Visitor', 'Event Visitor', false);
        Test.stopTest();
    }


    @isTest
    static void testEventVisitorDNSAInsert() {

        Event_Management__c em = [
            SELECT  Name
            FROM    Event_Management__c
            WHERE   EventName__c =: 'testEvent'
            LIMIT   1
        ];

        String jsonInput = '[' +
            '{' +
                // 필수 필드: 이벤트 코드, 그리고 lead key 생성에 필요한 값
                '"Column_0": "' + em.Name + '", ' + // 이벤트 코드 (Event_Management__c.Name)
                // 아래부터는 index 기반 할당 (Event Visitor에 대한 필드들은 upsertRecords의 else 분기에서 처리)
                '"EventName__c": "Annual Event", ' +      // index 1 for Event Visitor update branch
                '"VisitTime__c": "2025-02-01 10:00:00", ' +
                '"Company": "Acme Corp2", ' +
                '"LastName": "John2", ' +
                '"Title": "Manager", ' +
                '"Phone": "555-1234", ' +
                '"MobilePhone": "555-67891", ' +
                '"Email": "john@example.com", ' +
                '"Industry_EventVisitor__c": "IT", ' +
                '"InterestedItem__c": "", ' +
                '"Country__c": "KR", ' +

                '"PostalCode": "12345", ' +
                '"Address1__c": "456 Secondary St", ' +
                '"Address2__c": "Suite 100", ' +
                '"IsDNSolutionsAvailable__c": "Y", ' +
                '"Rating": "Warm", ' +
                '"RequestQuote__c": "Y", ' +
                '"RequestQuoteDate__c": "2025-02-02", ' +
                '"Description": "Interested in our products", ' +
                '"ExcludeLead__c": "N", ' +

                '"TemplateType": "Event Visitor", ' +
                '"Year": "2025", ' +
                '"Column_3": "Acme Corp", ' +  // leadKey: Company
                '"Column_4": "John", ' +       // leadKey: Name (예: First Name)
                '"Column_7": "555-6789"' +   // leadKey: Phone
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportLeadController.upsertRecords(jsonInput, 'Event Visitor', 'Event Visitor', true);
        Test.stopTest();
    }


    @isTest
    static void testCatalogDownloaderUpdate() {
        // Company + LastName + MobilePhone
        // leadkey = anotherCompany another 010-111-222
        String jsonInput = '[' +
            '{' +

                '"Column_0": "22222", ' +
                '"FileName__c": "TestFile.pdf", ' + 
                '"LastName": "another", ' +
                '"Company": "anotherCompany", ' +
                '"Address1__c": "123 Main St", ' +
                '"MobilePhone": "010-111-222", ' +
                '"Email": "test@example.com", ' +
                '"IsDNSolutionsAvailable__c": "Y", ' +
                '"IsMarketingConsentPhone__c": "동의", ' +
                '"IsMarketingConsentSMS__c": "동의", ' +
                '"IsMarketingConsentEmail__c": "동의", ' +
                '"IsMarketingConsentPost__c": "동의", ' +
                '"MarketingConsentDate__c": "2025-01-01", ' +
                '"LeadSourceCatalog__c": "Online", ' +
                '"DownloadDate__c": "2025-01-02", ' +

                '"TemplateType": "Catalog Downloader", ' +
                '"Year": "2025", ' +
                '"Period": "Annual", ' +
                '"Column_3": "anotherCompany", ' +
                '"Column_2": "another", ' +
                '"Column_5": "010-111-222"' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportLeadController.upsertRecords(jsonInput, 'Catalog Downloader', 'Catalog Downloader', false);
        Test.stopTest();
    }

    @isTest
    static void testEventVisitorUpdate() {
        // Company + LastName + MobilePhone
        // leadkey = anotherCompany another 010-111-222
        Event_Management__c em = [
            SELECT  Name
            FROM    Event_Management__c
            WHERE   EventName__c =: 'testEvent'
            LIMIT   1
        ];

        String jsonInput = '[' +
            '{' +
                // 필수 필드: 이벤트 코드, 그리고 lead key 생성에 필요한 값
                '"Column_0": "' + em.Name + '", ' + // 이벤트 코드 (Event_Management__c.Name)
                // 아래부터는 index 기반 할당 (Event Visitor에 대한 필드들은 upsertRecords의 else 분기에서 처리)
                '"EventName__c": "Annual Event", ' +      // index 1 for Event Visitor update branch
                '"VisitTime__c": "2025-02-01 10:00:00", ' +
                '"Company": "anotherCompany", ' +
                '"LastName": "another", ' +
                '"Title": "Manager", ' +
                '"Phone": "555-1234", ' +
                '"MobilePhone": "010-111-222", ' +
                '"Email": "john@example.com", ' +
                '"Industry_EventVisitor__c": "IT", ' +
                '"InterestedItem__c": "", ' +
                '"Country__c": "KR", ' +

                '"Region__c": "35", ' +
                '"PostalCode": "12345", ' +
                '"Address1__c": "456 Secondary St", ' +
                '"Address2__c": "Suite 100", ' +
                '"IsDNSolutionsAvailable__c": "Y", ' +
                '"Rating": "Warm", ' +
                '"RequestQuote__c": "Y", ' +
                '"RequestQuoteDate__c": "2025-02-02", ' +
                '"Description": "Interested in our products", ' +
                '"ExcludeLead__c": "N", ' +

                '"TemplateType": "Event Visitor", ' +
                '"Year": "2025", ' +
                '"Column_3": "anotherCompany", ' +  // leadKey: Company
                '"Column_4": "another", ' +       // leadKey: Name (예: First Name)
                '"Column_7": "010-111-222"' +   // leadKey: Phone
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportLeadController.upsertRecords(jsonInput, 'Event Visitor', 'Event Visitor', false);
        Test.stopTest();
    }


    @isTest
    static void testEventVisitorDNSAUpdate() {
        // Company + LastName + MobilePhone
        // leadkey = anotherCompany another 010-111-222
        Event_Management__c em = [
            SELECT  Name
            FROM    Event_Management__c
            WHERE   EventName__c =: 'testEvent'
            LIMIT   1
        ];

        String jsonInput = '[' +
            '{' +
                // 필수 필드: 이벤트 코드, 그리고 lead key 생성에 필요한 값
                '"Column_0": "' + em.Name + '", ' + // 이벤트 코드 (Event_Management__c.Name)
                // 아래부터는 index 기반 할당 (Event Visitor에 대한 필드들은 upsertRecords의 else 분기에서 처리)
                '"EventName__c": "Annual Event", ' +      // index 1 for Event Visitor update branch
                '"VisitTime__c": "2025-02-01 10:00:00", ' +
                '"Company": "anotherCompany", ' +
                '"LastName": "another", ' +
                '"Title": "Manager", ' +
                '"Phone": "555-1234", ' +
                '"MobilePhone": "010-111-222", ' +
                '"Email": "john@example.com", ' +
                '"Industry_EventVisitor__c": "IT", ' +
                '"InterestedItem__c": "", ' +
                '"Country__c": "KR", ' +

                '"PostalCode": "12345", ' +
                '"Address1__c": "456 Secondary St", ' +
                '"Address2__c": "Suite 100", ' +
                '"IsDNSolutionsAvailable__c": "Y", ' +
                '"Rating": "Warm", ' +
                '"RequestQuote__c": "Y", ' +
                '"RequestQuoteDate__c": "2025-02-02", ' +
                '"Description": "Interested in our products", ' +
                '"ExcludeLead__c": "N", ' +

                '"TemplateType": "Event Visitor", ' +
                '"Year": "2025", ' +
                '"Column_3": "anotherCompany", ' +  // leadKey: Company
                '"Column_4": "another", ' +       // leadKey: Name (예: First Name)
                '"Column_7": "010-111-222"' +   // leadKey: Phone

            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportLeadController.upsertRecords(jsonInput, 'Event Visitor', 'Event Visitor', true);
        Test.stopTest();
    }




}