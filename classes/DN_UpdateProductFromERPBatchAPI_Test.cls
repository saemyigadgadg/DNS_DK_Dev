@isTest
public with sharing class DN_UpdateProductFromERPBatchAPI_Test {

    @isTest
    static void testCallOut() {
        InterfaceCommonUtil.setInterface('IF-OPTY-002', 'IF_ERP_Product');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/start_product_batch/';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Map<String, String> result = DN_UpdateProductFromERPBatchAPI.callOut();
        Test.stopTest();
    }
}