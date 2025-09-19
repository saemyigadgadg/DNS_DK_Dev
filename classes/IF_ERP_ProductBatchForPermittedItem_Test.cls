@isTest
private class IF_ERP_ProductBatchForPermittedItem_Test {
    @isTest
    static void testCallOut() {
        // 1. Mock 데이터 생성
        IF_ERP_Product_Classes.IF_OPTY_030_Res mockRes = new IF_ERP_Product_Classes.IF_OPTY_030_Res();

        // 2. JSON 직렬화
        String jsonBody = JSON.serialize(mockRes);

        // 3. RestContext 설정
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/get_ative_product_info/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);

        RestContext.request = req;
        RestContext.response = res;

        // 4. 테스트 실행
        Test.startTest();
        Map<String, String> result = IF_ERP_ProductBatchForPermittedItemAPI.callOut();
        Test.stopTest();
    }
}