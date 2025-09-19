@isTest
public class IF_BIZ_SMS_Test {
    
    // WebServiceMock 클래스 정의
    public class MockSMSWebService implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestNamespace,
            String responseNamespace,
            String operationName,
            String clientCertPasswd) {

            IF_BIZ_SMS.Z_CC_SEND_SMSReplyDocument mockResponse = new IF_BIZ_SMS.Z_CC_SEND_SMSReplyDocument();
            mockResponse.O_RETVAL = 'S'; // 성공 결과
            response.put('response_x', mockResponse);
        }
    }

    @isTest
    static void testSendSMS() {
        // 테스트용 T_SMS_DATA 객체 생성
        IF_BIZ_SMS.T_SMS_DATA smsData = new IF_BIZ_SMS.T_SMS_DATA();
        smsData.TRAN_ID = 'TEST001';
        smsData.TRAN_PHONE = '010-1234-5678';
        smsData.TRAN_CALLBACK = '1588-1896';
        smsData.TRAN_STATUS = 'READY';
        smsData.TRAN_DATE = '20250402';
        smsData.TRAN_TIME = '143000';
        smsData.TRAN_MSG = '테스트 메시지입니다.\n잘 전송되나요?';
        smsData.TRAN_ETC1 = 'CRM';
        smsData.AT_TEMPLATE_CODE = 'TPL001';
        smsData.AT_SENDER_KEY = 'SENDERKEY001';
        smsData.ATTACHED_FILE = null;

        // WebServiceMock 설정
        Test.setMock(WebServiceMock.class, new MockSMSWebService());

        Test.startTest();
        IF_BIZ_SMS.DICCSAP_SEND_SMS_WP smsService = new IF_BIZ_SMS.DICCSAP_SEND_SMS_WP();
        String result = smsService.DICCSAP_SEND_SMS_M(new IF_BIZ_SMS.T_SMS_DATA[] { smsData });
        Test.stopTest();

        System.assertEquals('S', result, 'SMS 전송 결과는 성공이어야 합니다.');
    }
}