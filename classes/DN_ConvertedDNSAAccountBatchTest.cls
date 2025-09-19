/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-03-19
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-03-19   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_ConvertedDNSAAccountBatchTest {
    
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        RecordType accRT = TestDataFactoryForSales.getRecordType('DNSACustomer', 'Account');

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'LeadTriggerHandler', 'ContactTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        System.runAs(thisUser) {

            Lead testLead = TestDataFactoryForSales.createLead('DNSA', country);
            insert testLead;

            Database.LeadConvert leadConvert = new Database.LeadConvert();
            leadConvert.setLeadId(testLead.Id);
            leadConvert.setConvertedStatus('Qualified');
            leadConvert.setDoNotCreateOpportunity(true); // 기회 생성 없이 변환
            Database.LeadConvertResult result = Database.convertLead(leadConvert);
            
            if (result.isSuccess()) {
                System.debug('리드 변환 성공');

                Id convertedAccountId = result.getAccountId();
                Account acc = [
                    SELECT  Id, RecordTypeId, BusinessNumber__c, Representative__c, CurrencyIsoCode, Country__c, CountryLookup__c, CustomerCode__c,
                            DistributionChannel__c, Division__c, SalesOffice__c, SalesDistrict__c, SalesOrganization__c, ShippingCity, ShippingPostalCode
                    FROM Account 
                    WHERE Id = :convertedAccountId
                    ];

                acc.RecordTypeId      = accRT.Id;
                acc.BusinessNumber__c = '5148171774';
                acc.Representative__c = 'testuser';
                acc.CurrencyIsoCode  = 'KRW';
                acc.Country__c       = 'KR';
                acc.CountryLookup__c = country.Id;
                
                acc.DistributionChannel__c = '10';
                acc.Division__c            = '40';
                acc.SalesOffice__c         = '114E';
                acc.SalesDistrict__c       = 'A1KR';
                acc.SalesOrganization__c   = '1800';
        
                acc.ShippingCity = '대구광역시 달서구';
                acc.ShippingStreet = '성서공단로 max Length를 채우기 위해 입력하는 Street 주소 무려 60자가 넘어야 한다 성서공단로 max Length를 채우기 위해 입력하는 Street 주소 무려 60자가 넘어야 한다';
                acc.ShippingPostalCode = '42722';

                update acc;

            } else {
                System.debug('리드 변환 실패');
            }

        }

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-ACCOUNT-015', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Account', ifc.Id);
        insert ifClass;
        
    }

    
    @isTest
    static void testBatchExecution(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Account());
        
        DN_ConvertedDNSAAccountBatch batchJob = new DN_ConvertedDNSAAccountBatch();

        String jobId = System.schedule('Test Scheduled Batch', '0 0 0 1 1 ? 2050', batchJob);
        
        Database.ExecuteBatch(batchJob, 5);
        Test.stopTest();

    }

    private class MockIF_ERP_Account implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(
                '{"O_PERSON":"1330257","O_RETURN":{"TYPE":"S","CODE":"","MESSAGE":"Sales Employee0001330257was created ."}}'
                );
            return res;
        }
    }


}