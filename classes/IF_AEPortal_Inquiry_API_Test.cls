@isTest
private class IF_AEPortal_Inquiry_API_Test {

/* Mock Classes
    */
    public class IF_OPTY_017_HttpMock implements HttpCalloutMock {
        public IF_OPTY_017_HttpMock(){}

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();

            String resBody = '';

            res.setBody(resBody);
            res.setStatusCode(200);
    
            System.debug(res.getBody());
            return res;
        }
    }

/* Test Code
    */
    @testSetup
    static void setupTestData() {
        // 테스트를 위한 데이터 설정
        IF_AEPortal__c testInquiry = new IF_AEPortal__c(
            I_INQUIRY_NO__c = 'INQ12345',
            I_VERSION__c = '1.0',
            I_RFQ_ACCEPT_DATE__c = '2025-03-01',
            I_REVIEW_REQUEST_DATE__c = '2025-03-05',
            I_BRANCH_NAME__c = 'Seoul Branch',
            I_SALES_PERSON__c = 'John Doe',
            I_CUSTOMER_COMPANY__c = 'ABC Corp',
            I_PRODUCT_NAME__c = 'Test Product',
            I_CATEGORY__c = 'Machinery',
            I_OUTPUT__c = '1000 Units',
            I_OPERATION_RATE__c = '95%',
            I_STATUS__c = 'Pending'
        );
        insert testInquiry;
    }
    @isTest
    static void testPostHttp() {
        InterfaceCommonUtil.setInterface('IF-OPTY-017', 'IF_AEPortal_Inquiry_API');
        // 1. 테스트 요청 데이터 생성
        String requestBody = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'I_INQUIRY_NO' => 'INQ12345',
                'I_VERSION' => '1.0',
                'I_RFQ_ACCEPT_DATE' => '2025-03-01',
                'I_REVIEW_REQUEST_DATE' => '2025-03-05',
                'I_BRANCH_NAME' => 'Seoul Branch',
                'I_SALES_PERSON' => 'John Doe',
                'I_CUSTOMER_COMPANY' => 'ABC Corp',
                'I_PRODUCT_NAME' => 'Test Product',
                'I_CATEGORY' => 'Machinery',
                'I_OUTPUT' => '1000 Units',
                'I_OPERATION_RATE' => '95%',
                'I_STATUS' => 'Pending'
            }
        });

        // 2. REST 요청 및 응답 모의 생성
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AEPortal/inquiryUpdate';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        // 3. API 호출 실행
        IF_AEPortal_Inquiry_API.ResponseDto response = IF_AEPortal_Inquiry_API.postHttp();
        Test.stopTest();
    }
}