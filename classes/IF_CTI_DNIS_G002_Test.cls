@IsTest
public with sharing class IF_CTI_DNIS_G002_Test {
        // Mock 클래스 정의
        public class CTIHttpMock implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"status":200,"code":"SUCCESS","message":"Request is successfully done","data":{"code":"WORK","name":"업무시간","isWork":true,"scheduleType":"routine","scheduleName":"업무시간","cidState":null},"remark":null}');
                res.setStatusCode(200);
                return res;
            }
        }

        @isTest
        static void testStaticCallOut() {
            Test.setMock(HttpCalloutMock.class, new CTIHttpMock());

            Test.startTest();
            String response = new IF_CTI_DNIS_G002().staticCallOut();
            Test.stopTest();
        }

        @isTest
        static void testCallOut() {
            // CTI 호출 mock 설정
            Test.setMock(HttpCalloutMock.class, new CTIHttpMock());
            // DTO 셋팅
            IF_CTI_DNIS_G002.RequestDto reqDto = new IF_CTI_DNIS_G002.RequestDto();
            reqDto.dnisId = '16004522';

            Test.startTest();
            String result = new IF_CTI_DNIS_G002().callOut(reqDto);
            Test.stopTest();
        }
}