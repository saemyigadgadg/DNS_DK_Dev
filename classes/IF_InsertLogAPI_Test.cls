/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-16-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-16-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
@isTest
private class IF_InsertLogAPI_Test {
    
    @TestSetup
    static void makeData(){

        Interface__c ifObj = TestDataFactoryForDealerPortal.createinterface('TestAPI', 'Real-Time');
        insert ifObj;

        InterfaceClasses__c ifClass = TestDataFactoryForDealerPortal.createIFClass('TestClass', ifObj.Id);
        insert ifClass;
    }

    @isTest
    static void testCallOut_Success() {
        // Given: 테스트용 JSON 요청 본문 생성
        String testJson = JSON.serialize(new Map<String, Object>{
            'interfaceName' => 'TestAPI',
            'interfaceClassesName' => 'TestClass',
            'requestBody' => '{"sampleKey":"sampleValue"}',
            'requestTime' => String.valueOf(Datetime.now()),
            'responseBody' => '{"response":"ok"}',
            'responseTime' => String.valueOf(Datetime.now())
        });

        // When: REST Context 설정
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/Interface/InsertLog/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(testJson);
        
        RestContext.request = req;
        RestContext.response = res;

        // Then: 메서드 호출
        Test.startTest();
        Map<String, String> result = IF_InsertLogAPI.callOut();
        Test.stopTest();
    }

    @isTest
    static void testCallOut_InvalidDatetime() {
        // Given: 잘못된 시간 포맷 포함
        String testJson = JSON.serialize(new Map<String, Object>{
            'interfaceName' => 'TestAPI',
            'interfaceClassesName' => 'TestClass',
            'requestBody' => '{"sampleKey":"sampleValue"}',
            'requestTime' => 'INVALID-DATETIME',
            'responseBody' => '{"response":"ok"}',
            'responseTime' => 'INVALID-DATETIME'
        });

        // When: REST 요청 셋업
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/Interface/InsertLog/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(testJson);
        
        RestContext.request = req;
        RestContext.response = res;

        // Then: 예외 상황 테스트
        Test.startTest();
        Map<String, String> result = IF_InsertLogAPI.callOut();
        Test.stopTest();
    }
}