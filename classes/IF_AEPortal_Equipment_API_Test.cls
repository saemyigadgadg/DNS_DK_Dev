@isTest
private class IF_AEPortal_Equipment_API_Test {
    
/* Mock Classes
    */
    public class IF_CSPLUS_035_HttpMock implements HttpCalloutMock {
        public IF_CSPLUS_035_HttpMock(){}

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
        // 테스트용 Asset 데이터 삽입
        Asset testAsset = new Asset(
            Name = 'Test Asset',
            SerialNumber = 'SN123456'
        );
        insert testAsset;
    }
    @isTest
    static void testPostHttp_Success() {
        InterfaceCommonUtil.setInterface('IF-CSPLUS-035', 'IF_AEPortal_Equipment_API');
        // 1. 테스트 요청 데이터 생성
        String requestBody = JSON.serialize(new List<Map<String, Object>>{
            new Map<String, Object>{
                'PJT_CODE' => 'PJT001',
                'MTRL_CODE_SN' => 'SN123456',
                'SHIPPING_DATE' => '2025-04-01',
                'CONTRACT_SCOPE' => 'Full Contract',
                'CUSTOMER_CONTRACT' => 'Customer A',
                'CONTRACT_UNIT_TYPE' => 'UnitType1',
                'CONTRACT_UNIT_DESC' => 'Unit Description'
            }
        });

        // 2. REST 요청 및 응답 모의 생성
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AEPortal/equipmentUpdate';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        // 3. API 호출 실행
        IF_AEPortal_Equipment_API.ResponseDto response = IF_AEPortal_Equipment_API.postHttp();
        Test.stopTest();
    }
}