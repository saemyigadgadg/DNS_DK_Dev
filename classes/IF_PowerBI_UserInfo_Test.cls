/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 06-11-2025
 * @last modified by  : JangJunHee
**/
@isTest
public with sharing class IF_PowerBI_UserInfo_Test {
    public IF_PowerBI_UserInfo_Test() {}

    public class IF_OPTY_036_HttpMock implements HttpCalloutMock {
        public IF_OPTY_036_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"E_MSGTY":"S","E_MSGTX":"Success"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
    }

    @isTest
    static void IF_PowerBI_UserInfo_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-036', 'IF_PowerBI_UserInfo');

        Test.startTest();

        // 배치 실행
        IF_PowerBI_UserInfo instance = new IF_PowerBI_UserInfo();
        instance.interfacePowerBI();

        Test.stopTest();
    }
}