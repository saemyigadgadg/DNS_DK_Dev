@RestResource(urlMapping='/get_ative_product_info/*')
global with sharing class IF_ERP_ProductBatchForPermittedItemAPI {
    public IF_ERP_ProductBatchForPermittedItemAPI() {}

    @HttpPost
    global static Map<String,String> callOut(){
        RestRequest  request   = RestContext.request;
        RestResponse response  = RestContext.response;

        // GET Request QueryString
        String urlInfo      = request.requestURI;

        // Get Request Body
        String requestBody = request.requestBody.toString();
        IF_ERP_Product_Classes.IF_OPTY_030_Res resultDto  = (IF_ERP_Product_Classes.IF_OPTY_030_Res) JSON.deserialize(requestBody, IF_ERP_Product_Classes.IF_OPTY_030_Res.class);

        IF_ERP_ProductBatchForPermittedItem batch = new IF_ERP_ProductBatchForPermittedItem();
        batch.res = resultDto;
        if(!Test.isRunningTest()) Database.executeBatch(batch);

        Map<String,String> returnMap = new Map<String,String>();
        returnMap.put('code','201');
        returnMap.put('message','success');
        return returnMap;
    }
}