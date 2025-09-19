@isTest
public with sharing class IF_AEPortal_PS_Test {
    private static String className = 'IF_AEPortal_PS';

    public IF_AEPortal_PS_Test() {}

/* Mock Classes
    */
    public class IF_OPTY_013_HttpMock implements HttpCalloutMock {
        public IF_OPTY_013_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"o_MSGTX":"Success","o_MSGTY":"S"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }
    public class IF_OPTY_016_HttpMock implements HttpCalloutMock {
        public IF_OPTY_016_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '{"o_MSGTX":"Success","o_MSGTY":"S"}';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Method
    */
    @isTest
    private static void IF_OPTY_013_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-013', className);
        
        Test.startTest();
        
        // 요청 객체 생성 및 필드 값 설정
        IF_AEPortal_PS_Classes.IF_OPTY_013_Req request = new IF_AEPortal_PS_Classes.IF_OPTY_013_Req();
        request.TB_MTS_PROP_IF = new List<IF_AEPortal_PS_Classes.IF_OPTY_013_Req_TB_MTS_PROP_IF>();

        // TB_MTS_PROP_IF 항목 추가
        IF_AEPortal_PS_Classes.IF_OPTY_013_Req_TB_MTS_PROP_IF requestItem = new IF_AEPortal_PS_Classes.IF_OPTY_013_Req_TB_MTS_PROP_IF();
        requestItem.I_INQUIRY_NO = '12345';
        requestItem.I_VERSION = '1.0';
        requestItem.I_RFQ_ACCEPT_DATE = '2024-03-11';
        requestItem.I_REVIEW_REQUEST_DATE = '2024-03-12';
        requestItem.I_BRANCH_NAME = 'Seoul';
        requestItem.I_SALES_PERSON = 'John Doe';
        requestItem.I_SE_PERSON = 'Jane Smith';
        requestItem.I_CUSTOMER_COMPANY = 'ABC Corp';
        requestItem.I_DEALER_CODE = 'D123';
        requestItem.I_PRODUCT_NAME = 'CNC Machine';
        requestItem.I_CATEGORY = 'Machinery';
        requestItem.I_MATERIAL_QUALITY = 'High';
        requestItem.I_PRE_PROCESS = 'Cutting';
        requestItem.I_OUTPUT = '500 units/day';
        requestItem.I_WORKING_HOURS = '8';
        requestItem.I_DUTY_DAY = 'Monday-Friday';
        requestItem.I_OPERATION_RATE = '85%';
        requestItem.I_CYCLE_IME_REQUEST = '2 mins';
        requestItem.I_BODY_TYPE = 'Steel';
        requestItem.I_MODEL_NAME = 'XYZ-500';
        requestItem.I_MACHINE_AMOUNT = '3';
        requestItem.I_MEASURE_TYPE = 'Precision';
        requestItem.I_CLAMP = 'Automatic';
        requestItem.I_RECOMD_COMPANY = 'BestCorp';
        requestItem.I_AUTO_TYPE = 'Fully Automated';
        requestItem.I_LOADAGE = '2 Tons';
        requestItem.I_REMARK = 'Urgent order';
        requestItem.I_EMAIL = 'customer@example.com';
        requestItem.I_TEL = '+82-10-1234-5678';
        requestItem.I_WRITER = 'Admin';
        requestItem.I_IF_DATE = '2024-03-11';
        requestItem.I_INQUIRY_SEQ = '001';
        requestItem.I_INQUIRY_DATE = '2024-03-10';
        requestItem.I_SE_PERSON_NO = 'SP123';
        requestItem.I_STATUS = 'Pending';
        requestItem.I_ORDER_STATUS = 'New';
        requestItem.I_ADDRESS = 'Seoul, South Korea';
        requestItem.I_INQUIRY_ID = 'INQ-20240311';

        // 리스트에 추가
        request.TB_MTS_PROP_IF.add(requestItem);

        // 응답 객체 생성 및 필드 값 설정
        IF_AEPortal_PS_Classes.IF_OPTY_013_Res response = new IF_AEPortal_PS_Classes.IF_OPTY_013_Res();
        response.O_MSGTY = 'S';  // 성공 (Success)
        response.O_MSGTX = 'Request processed successfully';

        IF_AEPortal_PS instance = new IF_AEPortal_PS();
        instance.IF_OPTY_013(request);

        Test.stopTest();
    }
    @isTest
    private static void IF_OPTY_016_Test() {
        InterfaceCommonUtil.setInterface('IF-OPTY-016', className);
        
        Test.startTest();
        
        IF_AEPortal_PS_Classes.IF_OPTY_016_Req request = new IF_AEPortal_PS_Classes.IF_OPTY_016_Req();
        request.ATTACH_SEQ      = 0;
        request.FILE_NAME       = 'test';
        request.INQUIRY_SEQ     = 'test';
        request.DOWNLOAD_URL    = 'test';
        request.INQUIRY_ID      = 'test';

        IF_AEPortal_PS instance = new IF_AEPortal_PS();
        instance.IF_OPTY_016(new List<IF_AEPortal_PS_Classes.IF_OPTY_016_Req>{request});

        Test.stopTest();
    }
}