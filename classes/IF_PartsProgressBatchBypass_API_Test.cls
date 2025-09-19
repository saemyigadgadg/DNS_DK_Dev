/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-17-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-17-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
@isTest
private  with sharing class IF_PartsProgressBatchBypass_API_Test {

    @isTest
    static void testCallout_withValidRequestBody(){
        // 요청 바디용 JSON 문자열 준비 (예시 구조)
        String mockJson = '{"partId":"P001","status":"IN_PROGRESS"}';

        // RestRequest 모킹
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/bypass_part_progress_batch/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Map<String, String> result = IF_PartsProgressBatchBypass_API.callOut();
        Test.stopTest();
    }

    @isTest
    static void testCallout_withEmptyRequestBody() {
        // 빈 요청 바디 설정
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/bypass_part_progress_batch/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Map<String, String> result = IF_PartsProgressBatchBypass_API.callOut();
        Test.stopTest();
    }

}