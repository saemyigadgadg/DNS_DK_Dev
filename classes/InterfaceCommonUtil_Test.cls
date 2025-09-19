/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 06-17-2025
 * @last modified by  : JangJunHee
**/
@isTest
public with sharing class InterfaceCommonUtil_Test {
    public InterfaceCommonUtil_Test() {}


/* Mock Classes
    */
    public class InterfaceCommonUtilTest_HttpMock implements HttpCalloutMock {
        public InterfaceCommonUtilTest_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"I_VBELN":"1087710"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    private static void utilMethod_Test () {
        
        Test.startTest();

        InterfaceCommonUtil util = InterfaceCommonUtil.getInterfaceUtil();
        util.getLanguageKey('KO');
        util.getERPKey();
        util.getParmetersString('{"example" : "test"}');
        util.getResponseString('{"Output": "test"}');

        Test.stopTest();
    }
    @isTest
    private static void setHttpRequest_Test () {

        List<Interface__c> insertIFList = new List<Interface__c>();

        Interface__c NTSIF = new Interface__c();
        NTSIF.Name                = 'SystemNTS';
        NTSIF.EndpointURL__c      = 'endpointUrl';
        NTSIF.System__c           = 'NTS';
        NTSIF.HttpMethod__c       = 'POST';
        NTSIF.IsActive__c         = true;
        NTSIF.Timeout__c          = 100;
        NTSIF.ContentType__c      = 'json';
        insertIFList.add(NTSIF);

        Interface__c NaverIF = new Interface__c();
        NaverIF.Name                = 'SystemNaver';
        NaverIF.EndpointURL__c      = 'endpointUrl';
        NaverIF.System__c           = 'Naver';
        NaverIF.HttpMethod__c       = 'POST';
        NaverIF.IsActive__c         = true;
        NaverIF.Timeout__c          = 100;
        NaverIF.ContentType__c      = 'json';
        insertIFList.add(NaverIF);

        Interface__c MOISIF = new Interface__c();
        MOISIF.Name                = 'SystemMOIS';
        MOISIF.EndpointURL__c      = 'endpointUrl';
        MOISIF.System__c           = 'MOIS';
        MOISIF.HttpMethod__c       = 'POST';
        MOISIF.IsActive__c         = true;
        MOISIF.Timeout__c          = 100;
        MOISIF.ContentType__c      = 'json';
        insertIFList.add(MOISIF);
        
        Interface__c SWEET_TRAKERIF = new Interface__c();
        SWEET_TRAKERIF.Name                = 'SystemSWEET_TRAKER';
        SWEET_TRAKERIF.EndpointURL__c      = 'endpointUrl';
        SWEET_TRAKERIF.System__c           = 'SWEET TRAKER';
        SWEET_TRAKERIF.HttpMethod__c       = 'POST';
        SWEET_TRAKERIF.IsActive__c         = true;
        SWEET_TRAKERIF.Timeout__c          = 100;
        SWEET_TRAKERIF.ContentType__c      = 'json';
        insertIFList.add(SWEET_TRAKERIF);
        
        Interface__c CTI_DNIS_G002IF = new Interface__c();
        CTI_DNIS_G002IF.Name                = 'SystemCTI_DNIS_G002';
        CTI_DNIS_G002IF.EndpointURL__c      = 'endpointUrl';
        CTI_DNIS_G002IF.System__c           = 'CTI_DNIS_G002';
        CTI_DNIS_G002IF.HttpMethod__c       = 'POST';
        CTI_DNIS_G002IF.IsActive__c         = true;
        CTI_DNIS_G002IF.Timeout__c          = 100;
        CTI_DNIS_G002IF.ContentType__c      = 'json';
        insertIFList.add(CTI_DNIS_G002IF);

        Database.insert(insertIFList);

        Test.startTest();
        
        InterfaceCommonUtil util = InterfaceCommonUtil.getInterfaceUtil();

        util.queryStringParams   = new Map<String, String>{
            'X-Naver-Client-Id'         => 'Id',
            'X-Naver-Client-Secret'     => 'Secret',
            'Add-Others'                => 'Add-Others',
            'userId'                    => 'userId',
            'profileKey'                => 'profileKey',
            'apiNm'                     => 'apiNm',
            'mt-api-token'              => 'mt-api-token',
            'trace-id'                  => 'trace-id',
            'dnis'                      => 'dnis'
        };

        util.setHttpRequest('SystemNTS', 'param');
        util.setHttpRequest('SystemNaver', 'param');
        util.setHttpRequest('SystemMOIS', 'param');
        util.setHttpRequest('SystemSWEET_TRAKER', 'param');
        util.setHttpRequest('SystemCTI_DNIS_G002', 'param');
        util.setHttpRequest('SystemNTS');
        util.setHttpRequest('SystemNaver');
        util.setHttpRequest('SystemMOIS');
        util.setHttpRequest('SystemSWEET_TRAKER');
        util.setHttpRequest('SystemCTI_DNIS_G002');

        Test.stopTest();
    }
    @isTest
    private static void sendHttp_Test () {
        InterfaceCommonUtil.setInterface('InterfaceCommonUtilTest', 'InterfaceCommonUtil');

        Test.startTest();

        InterfaceCommonUtil util = InterfaceCommonUtil.getInterfaceUtil();
        util.isURLEncode    = true;
        util.isSAPIF        = true;

        util.sendHttp('param', 'InterfaceCommonUtilTest', 'InterfaceCommonUtil', true);

        Test.stopTest();
    }
    @isTest
    private static void sendHttpCaseI_VBELN_Test () {
        InterfaceCommonUtil.setInterface('InterfaceCommonUtilTest', 'InterfaceCommonUtil');

        Test.startTest();

        InterfaceCommonUtil util = InterfaceCommonUtil.getInterfaceUtil();
        util.isURLEncode    = true;
        util.isSAPIF        = true;

        util.sendHttpCaseI_VBELN(new List<String>{'{"Input":{"I_VBELN":"1087710"}}'}, 'InterfaceCommonUtilTest', 'InterfaceCommonUtil', false);

        Test.stopTest();
    }
    @isTest
    private static void sendHttpList_Test () {
        InterfaceCommonUtil.setInterface('InterfaceCommonUtilTest', 'InterfaceCommonUtil');

        Test.startTest();

        InterfaceCommonUtil util = InterfaceCommonUtil.getInterfaceUtil();
        util.isURLEncode    = true;
        util.isSAPIF        = true;

        util.sendHttp(new List<String>{'param'}, 'InterfaceCommonUtilTest', 'InterfaceCommonUtil', true);

        Test.stopTest();
    }
    @isTest
    private static void sendHttpCaseI_VBELNList_Test () {
        InterfaceCommonUtil.setInterface('InterfaceCommonUtilTest', 'InterfaceCommonUtil');

        Test.startTest();

        InterfaceCommonUtil util = InterfaceCommonUtil.getInterfaceUtil();
        util.isURLEncode    = true;
        util.isSAPIF        = true;

        util.sendHttpCaseI_VBELN(new List<String>{'{"Input":{"I_VBELN":"1087710"}}'}, 'InterfaceCommonUtilTest', 'InterfaceCommonUtil', false);

        Test.stopTest();
    }
}