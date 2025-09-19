@isTest
private class IF_ERP_PermittedItemBatchAPI_Test {
    
    @isTest
    static void testCallOut() {
        InterfaceCommonUtil.setInterface('IF-OPTY-030', 'IF_ERP_Product');
        // Given: 테스트용 데이터 구성
        List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST> testList = new List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST>();
        IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST testItem = new IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST();

        testItem.MANDT = '';
        testItem.VKORG = '';
        testItem.VTWEG = '';
        testItem.SPART = '';
        testItem.KUNNR = '';
        testItem.MATNR = '';
        testItem.MALNR = '';
        testItem.DEIND = '';
        testItem.ERDAT = '';
        testItem.ERNAM = '';
        testItem.ERZET = '';
        testItem.AEDAT = '';
        testItem.AENAM = '';
        testItem.AEZET = '';

        // JSON 직렬화
        String jsonBody = JSON.serialize(testList);

        // When: RestContext를 설정하고 callOut 메서드 호출
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/active_product_batch/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);

        RestContext.request = req;
        RestContext.response = res;

        // Then: 결과 검증
        Test.startTest();
        Map<String, String> result = IF_ERP_PermittedItemBatchAPI.callOut();
        Test.stopTest();

        System.assertEquals('201', result.get('code'));
        System.assertEquals('success', result.get('message'));
    }

    @isTest
    static void testBatchExecution() {
        // Given: 테스트용 T_LIST 데이터 생성
        List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST> testList = new List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST>();

        IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST item = new IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST();
        item.MANDT = '100';
        item.VKORG = '2000';
        item.VTWEG = '10';
        item.SPART = '01';
        item.KUNNR = '123456';
        item.MATNR = 'MAT-001';
        item.MALNR = 'MALT-001';
        item.DEIND = 'N';
        item.ERDAT = 'Date.today()';
        item.ERNAM = 'tester';
        item.ERZET = '120000';
        item.AEDAT = 'Date.today()';
        item.AENAM = 'tester';
        item.AEZET = '123000';

        testList.add(item);

        // When: 배치 클래스 인스턴스 생성 및 T_LIST 설정
        Test.startTest();
        IF_ERP_PermittedItemBatchAPIBatch batch = new IF_ERP_PermittedItemBatchAPIBatch();
        batch.T_LIST = testList;
        Database.executeBatch(batch);  // 작은 배치 사이즈로 테스트
        Test.stopTest();
    }
}