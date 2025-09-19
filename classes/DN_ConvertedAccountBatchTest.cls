/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-10
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-10   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_ConvertedAccountBatchTest {
    
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        RecordType accRT = TestDataFactoryForSales.getRecordType('ProspectCustomer', 'Account');

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'LeadTriggerHandler', 'ContactTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        System.runAs(thisUser) {

            Lead testLead = TestDataFactoryForSales.createLead('DNS', country);
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

                // acc.Name              = 'test company';
                acc.RecordTypeId      = accRT.Id;
                // acc.Phone             = '00000000000';
                acc.BusinessNumber__c = '5148171774';
                acc.Representative__c = 'testuser';
                // acc.CustomerCode__c   = '0000000';
                // acc.TypeOfBusiness__c = 'Manufacturing';
                // acc.TypeOfIndustry__c = 'Wholesale and Commodity Brokerage';
                // acc.IsKeyAccount__c   = true;
                // acc.ParentId          = parentAcc == null ? null : parentAcc.Id;
                acc.CurrencyIsoCode  = 'KRW';
                acc.Country__c       = 'KR';
                acc.CountryLookup__c = country.Id;
                
                acc.DistributionChannel__c = '10';
                acc.Division__c            = '40';
                acc.SalesOffice__c         = '114E';
                acc.SalesDistrict__c       = 'A1KR';
                acc.SalesOrganization__c   = '1800';
        
                acc.ShippingCity = '대구광역시 달서구';
                acc.ShippingStreet = '성서공단로 35 max Length를 채우기 위해 입력하는 Street 주소';
                acc.ShippingPostalCode = '42722';

                update acc;

            } else {
                System.debug('리드 변환 실패');
            }

        }

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-ACCOUNT-001', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Account', ifc.Id);
        insert ifClass;
        
    }

    @isTest
    static void testBatchExecution(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Account());
        
        DN_ConvertedAccountBatch batchJob = new DN_ConvertedAccountBatch();

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
                '{"O_DUP":"","O_KUNNR":"1330109","O_RECODE":"S","O_REMSG":"Successfully finished.","ET_DATA":[]}'
            );
            return res;
        }
    }



}