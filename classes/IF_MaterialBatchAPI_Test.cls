@isTest
private class IF_MaterialBatchAPI_Test {
    @isTest
    static void testCallOut() {
        // 1. Mock 데이터 생성
        IF_ERP_Material_Classes.IF_CSPLUS_018_Res mockRes = new IF_ERP_Material_Classes.IF_CSPLUS_018_Res();

        // 2. JSON 직렬화
        String jsonBody = JSON.serialize(mockRes);

        // 3. RestContext 설정
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/get_asset_info/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);

        RestContext.request = req;
        RestContext.response = res;

        // 4. 테스트 실행
        Test.startTest();
        Map<String, String> result = IF_MaterialBatchAPI.callOut();
        Test.stopTest();
    }
}