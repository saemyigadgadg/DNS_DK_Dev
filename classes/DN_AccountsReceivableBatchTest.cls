/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-07
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-06   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_AccountsReceivableBatchTest {

    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        System.runAs(thisUser) {
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null); 
            insert dealerAcc;
        }


        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-DEALER-001', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Dealer', ifc.Id);
        insert ifClass;
    }

    @isTest
    static void testBatchExecution(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Dealer());
        
        DN_AccountsReceivableBatch batchJob = new DN_AccountsReceivableBatch();

        String jobId = System.schedule('Test Scheduled Batch', '0 0 0 1 1 ? 2050', batchJob);
        
        Database.ExecuteBatch(batchJob, 5);
        Test.stopTest();

    }

    private class MockIF_ERP_Dealer implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(

                '{' +
                    '"T_ORDER": [' +
                        '{' +
                            '"WRBTR": "10000",' +
                            '"CL_WRBTR": "5000"' +
                        '},' +
                        '{' +
                            '"WRBTR": "-2000",' +
                            '"CL_WRBTR": "3000"' +
                        '}' +
                    '],' +
                    '"TotalAmount": 16000' +
                '}'

            );
            return res;
        }
    }



}