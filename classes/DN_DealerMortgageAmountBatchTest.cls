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
public with sharing class DN_DealerMortgageAmountBatchTest {

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

        Interface__c ifc = TestDataFactoryForSales.createinterface('IF-DEALER-004', 'Real-Time');
        insert ifc;

        InterfaceClasses__c ifClass = TestDataFactoryForSales.createIFClass('IF_ERP_Dealer', ifc.Id);
        insert ifClass;
    }


    @isTest
    static void testBatchExecution(){
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_Dealer());
        Test.startTest();
        DN_DealerMortgageAmountBatch batchJob = new DN_DealerMortgageAmountBatch();
        String jobId = System.schedule('Test Scheduled Batch', '0 0 0 1 1 ? 2050', batchJob);
        Database.ExecuteBatch(batchJob, 5);
        Test.stopTest();
    }


    private class MockIF_ERP_Dealer implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            String responseBody = '{'
            + '"O_RETURN": {'
                + '"TYPE": "S",'
                + '"CODE": "230",'
                + '"MESSAGE": "Successfully finished."'
            + '},'
            + '"T_RETURN": ['
                + '{'
                    + '"ALT_INFO": "",'
                    + '"MORTSIZE": "1008",'
                    + '"LEA_DATE": "0000-00-00",'
                    + '"AGR_DATE": "0000-00-00",'
                    + '"VAL_AMT": "1674650.00",'
                    + '"FI_ORG": "",'
                    + '"PRI_INFO": "소액임대차",'
                    + '"ESTA_RANK": "1",'
                    + '"MNGNO": "000000001",'
                    + '"ENG_DATE": "2011-08-04",'
                    + '"MORT_TEXT": "Real estate",'
                    + '"REG_DATE": "2011-08-04",'
                    + '"AMOUNT": "900000.00",'
                    + '"ESTA_AMT": "2210000.00",'
                    + '"CANC_DATE": "0000-00-00",'
                    + '"EST_DOC_DAT": "2014.10.28",'
                    + '"PROVIDER": "토탈머신(주)",'
                    + '"J_1KFREPRE": "김준표",'
                    + '"SP_REASON": "",'
                    + '"DUE_DATE": "2030-12-31",'
                    + '"FI_NUM": "",'
                    + '"OWNER": "김채수",'
                    + '"MORTTYPE": "0003",'
                    + '"PAGR_DATE": "0000-00-00",'
                    + '"ADD_DATA": "2023년 11월 담보 재평가",'
                    + '"ALT_MNGNO": "",'
                    + '"WAERS": "KRW",'
                    + '"PRI_AMT": "100000.00",'
                    + '"NAME1": "토탈머신 주식회사",'
                    + '"MORT_CODE": "AM10",'
                    + '"KUNNR": "0001124140",'
                    + '"STMP_DATE": "0000-00-00",'
                    + '"TYPE_TEXT": "Store",'
                    + '"EST_AMT": "1774650.00",'
                    + '"PLED_DATE": "0000-00-00"'
                + '}'
            + ']'
        + '}';

        res.setBody(responseBody);
            return res;
        }
    }
}