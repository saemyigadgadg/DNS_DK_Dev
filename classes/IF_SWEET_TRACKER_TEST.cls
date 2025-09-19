/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 09-08-2025
 * @last modified by  : JangJunHee
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-31   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class IF_SWEET_TRACKER_TEST {
    private static String className = 'IF_SWEET_TRACKER';
    public IF_SWEET_TRACKER_TEST() {}

    @TestSetup
    static void makeData(){

        Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('Sweet_Tracker_SendMessage_Op', 'Real-Time');
        insert ifObj;

        InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('IF_SWEET_TRACKER', ifObj.Id);
        insert ifClass;
    }

    public class IF_SWEET_TRACKER_HttpMock implements HttpCalloutMock {
        public IF_SWEET_TRACKER_HttpMock() {}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse(); 
            
            String resBody = '[{"result":"Y","code":"K000","kind":"K","msgid":"20250404_134650_44","originCode":null,"error":"","sendtime":"2025-04-04 13:46:50","originError":null}]';
            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    @IsTest 
    static void SWEET_TRACKER(){
        
        Test.startTest();        
        String apiType        = 'AT';
        String phNum          = '01099999999';
        String templateCode   = 'crm_template_105';
        String apiNm          = 'test';
        Map<String,String> elementMap = new Map<String,String>();
        IF_SWEET_TRACKER.invoke(apiType, phNum, apiNm, templateCode, elementMap);

        Test.stopTest();
    }

}