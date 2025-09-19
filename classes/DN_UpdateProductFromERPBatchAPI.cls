@RestResource(urlMapping='/start_product_batch/*')
global with sharing class DN_UpdateProductFromERPBatchAPI {
    public DN_UpdateProductFromERPBatchAPI() {}

    @HttpPost
    global static Map<String,String> callOut(){
        RestRequest  request   = RestContext.request;
        RestResponse response  = RestContext.response;

        DN_UpdateProductFromERPBatch batch = new DN_UpdateProductFromERPBatch();
        if(!Test.isRunningTest()) Database.executeBatch(batch);

        Map<String,String> returnMap = new Map<String,String>();
        returnMap.put('code','201');
        returnMap.put('message','success');
        return returnMap;
    }
}