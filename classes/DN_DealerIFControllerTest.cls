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
public with sharing class DN_DealerIFControllerTest {

    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        Interface__c ifc004 = TestDataFactoryForSales.createinterface('IF-DEALER-004', 'Real-Time');
        insert ifc004;
        InterfaceClasses__c ifClass004 = TestDataFactoryForSales.createIFClass('IF_ERP_Dealer', ifc004.Id);
        insert ifClass004;

        Interface__c ifc003 = TestDataFactoryForSales.createinterface('IF-DEALER-003', 'Real-Time');
        insert ifc003;
        InterfaceClasses__c ifClass003 = TestDataFactoryForSales.createIFClass('IF_ERP_Dealer', ifc003.Id);
        insert ifClass003;

        Interface__c ifc010 = TestDataFactoryForSales.createinterface('IF-DEALER-010', 'Real-Time');
        insert ifc010;
        InterfaceClasses__c ifClass010 = TestDataFactoryForSales.createIFClass('IF_ERP_Dealer', ifc010.Id);
        insert ifClass010;

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
            System.debug('dealer.Account.Name :: ' + dealer.Account.Name);
            System.debug('dealer.UserType :: ' + dealer.UserType);
            insert dealer;
        }
    }



    @isTest
    static void testGetDealerInfoInternal(){
        Account prospectAcc = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c = '11111' LIMIT 1];

        Map<String, Object> internalResult = DN_DealerIFController.getDealerInfo(prospectAcc.Id);
        System.debug('InternalUser 결과 :: ' + internalResult);
    }


    @isTest
    static void testGetDealerInfoDealer(){

        Account dealerAcc = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c = '22222' LIMIT 1];
        User dealer = [SELECT Id, UserType, AccountId  FROM User WHERE AccountId =: dealerAcc.Id LIMIT 1 ]; 

        System.runAs(dealer) {
            Map<String, Object> dealerResult = DN_DealerIFController.getDealerInfo(dealerAcc.Id);
            System.debug('dealerUser 결과 :: ' + dealerResult);
        }
    }


    @isTest
    static void testCallinterfaceDealer004(){

        Account dealerAcc = [SELECT Id, CustomerCode__c, Name, SalesOrganization__c, DistributionChannel__c, Division__c, Representative__c FROM Account WHERE CustomerCode__c = '22222' LIMIT 1];

        // 입력값 설정
        Map<String, Object> fieldMap = new Map<String, Object>{
            'dealerCode'  => dealerAcc.CustomerCode__c,
            'companyCode' => dealerAcc.SalesOrganization__c,
            'salesArea2'  => dealerAcc.Division__c
        };

        String processOption = 'Process';
        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_DEALER004());

        Test.startTest();
        IF_ERP_Dealer_Classes.IF_DEALER_004_Res res004 = DN_DealerIFController.interfaceDealer004(fieldMap, processOption);

        Decimal amountFromResponse = Decimal.valueOf((String) res004.T_RETURN[0].AMOUNT);

        List<Map<String, Object>> fieldMapList = new List<Map<String, Object>>();
        fieldMapList.add(new Map<String, Object>{ 'AMOUNT' => amountFromResponse });
        fieldMapList.add(new Map<String, Object>{ 'AMOUNT' => 100000.00 });

        TriggerHandler.bypassedHandlers = new Set<String>{'AccountTriggerHandler'};

        DN_DealerIFController.updateTotalMortgageAmount(fieldMapList, dealerAcc.Id);
        Test.stopTest();
    }


    @isTest
    static void testCallinterfaceDealer003(){

        Account dealerAcc = [SELECT Id, CustomerCode__c, Name, SalesOrganization__c, DistributionChannel__c, Division__c, Representative__c FROM Account WHERE CustomerCode__c = '22222' LIMIT 1];

        // 입력값 설정
        Map<String, Object> fieldMap = new Map<String, Object>{
            'dealerCode'  => dealerAcc.CustomerCode__c,
            'companyCode' => dealerAcc.SalesOrganization__c,
            'salesArea1'  => dealerAcc.DistributionChannel__c,
            'salesArea2'  => dealerAcc.Division__c
        };

        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_DEALER003());
        Test.startTest();
        DN_DealerIFController.interfaceDealer003(fieldMap);
        Test.stopTest();
    }



    @isTest
    static void testCallinterfaceDealer010(){

        Account dealerAcc = [SELECT Id, CustomerCode__c, Name, SalesOrganization__c, DistributionChannel__c, Division__c, Representative__c FROM Account WHERE CustomerCode__c = '22222' LIMIT 1];

        // 입력값 설정
        Map<String, Object> fieldMap = new Map<String, Object>{
            'dealerCode'  => dealerAcc.CustomerCode__c,
            'companyCode' => dealerAcc.SalesOrganization__c,
            'salesArea2'  => dealerAcc.Division__c
        };

        Test.setMock(HttpCalloutMock.class, new MockIF_ERP_DEALER010());
        Test.startTest();
        DN_DealerIFController.interfaceDealer010(fieldMap);
        Test.stopTest();
    }
    

    public class MockIF_ERP_DEALER004 implements HttpCalloutMock{
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


    public class MockIF_ERP_DEALER003 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            String responseBody = '{'
            + '"O_DLTOTAL": "0.00",'
            + '"O_HEADER": {'
                + '"CNT": "4",'
                + '"NETWR": "611413000.00",'
                + '"CLAMT": "28400000.00",'
                + '"ICAMT": "583013000.00",'
                + '"FBAMT": "0.00",'
                + '"MRAMT": "583013000.00",'
                + '"WAERS": "KRW"'
            + '},'
            + '"O_RETURN": {'
                + '"TYPE": "S",'
                + '"CODE": "",'
                + '"MESSAGE": "Successfully finished !"'
            + '}'
        + '}';
            res.setBody(responseBody);
            return res;
        }
    }


    public class MockIF_ERP_DEALER010 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            String responseBody = '{'
            + '"O_RETURN": {'
                + '"TYPE": "S",'
                + '"CODE": "",'
                + '"MESSAGE": "Successfully finished !"'
            + '},'
            + '"T_LIST": ['
                + '{'
                    + '"CLS_AMT": "0.00",'
                    + '"EST_DAT": "202306",'
                    + '"EST_AMT": "140000.00"'
                + '},'
                + '{'
                    + '"CLS_AMT": "0.00",'
                    + '"EST_DAT": "202501",'
                    + '"EST_AMT": "4742100.00"'
                + '}'
            + ']'
        + '}';
        res.setBody(responseBody);
        return res;
        }
    }
}