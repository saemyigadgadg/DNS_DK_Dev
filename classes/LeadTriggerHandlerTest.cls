/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-12
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-24   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class LeadTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        
        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'UserTriggerHandler', 'LeadTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Date today = Date.today();

        User dealer;
        System.runAs(thisUser) {
            Lead dnsLead = TestDataFactoryForSales.createLead('DNS', country);
            insert dnsLead;

            Lead dnsaLead = TestDataFactoryForSales.createLead('DNSA', country);
            dnsaLead.LastName = 'dnsaNewLead';
            dnsaLead.Company = 'dnsaCompany';
            dnsaLead.MobilePhone = '1-0111-33';
            dnsaLead.Email = 'newDnsaLead@email.com';
            insert dnsaLead;

            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;

            Event_Management__c evtMg = new Event_Management__c();
            evtMg.EventName__c = 'EVENT01';
            evtMg.From__c = today;
            evtMg.To__c = today;
            evtMg.Country__c = 'Korea';
            insert evtMg;

            LeadEvent__c evt = new LeadEvent__c();
            evt.EventManagement__c = evtMg.Id;
            evt.Lead__c = dnsLead.Id;
            insert evt;
        }

        System.runAs(dealer) {
            Account acc = TestDataFactoryForSales.createAccount('ProspectCustomer', country, null);
            insert acc;

            Account dnsaAcc = TestDataFactoryForSales.createAccount('DNSACustomer', country, null);
            insert dnsaAcc;
        }
    }


    @isTest
    static void testInsert(){

        Test.startTest();

        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];

        System.runAs(dealer) {
            Lead dnsLead = TestDataFactoryForSales.createLead('DNS', null);
            dnsLead.IsWebtoLead__c = true;
            dnsLead.LastName = 'newLead';
            dnsLead.Company = 'newCompany';
            dnsLead.MobilePhone = '11-33';
            dnsLead.Email = 'newLead@email.com';
            dnsLead.Country__c = 'Etc';

            insert dnsLead;
        }

        Test.stopTest();
    }


    @isTest
    static void testUpdate(){

        Test.startTest();

        User dealer = [SELECT Id, AccountId, SalesOffice__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        Lead lead = [SELECT Id  FROM Lead WHERE Company = 'testCompany' LIMIT 1];
        Country__c country = [SELECT Id FROM Country__c WHERE CountryCode__c = 'KR' LIMIT 1];

        lead.Representative__c = 'SampleRep';
        lead.MainCategory__c = 'MB';
        lead.SubCategory__c = 'MB3';
        lead.IsTooling__c = 'MN';
        lead.CountryLookup__c = country.Id;
        lead.SalesOrganization__c = '1800';
        lead.SalesDistrict__c = 'A1KR';
        lead.DistributionChannel__c = '10';
        lead.SalesOffice__c = '114B';
        lead.Division__c = '40';
        lead.OwnerId = dealer.Id;
        lead.IsERPValidated__c = true;

        update lead;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setConvertedStatus('Qualified'); // Ensure this status is a valid converted status for your org
        lc.setOwnerId(dealer.Id);
    
        // Convert the lead and capture the result
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Test.stopTest();

    }



}