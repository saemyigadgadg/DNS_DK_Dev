@RestResource(urlMapping='/get_product_info/*')
global with sharing class IF_ERP_ProductBatchAPI {
    public IF_ERP_ProductBatchAPI() {}

    @HttpPost
    global static Map<String,String> callOut(){
        RestRequest  request   = RestContext.request;
        RestResponse response  = RestContext.response;

        // GET Request QueryString
        String urlInfo      = request.requestURI;

        // Get Request Body
        String requestBody = request.requestBody.toString();
        
        IF_ERP_Product_Classes.IF_OPTY_002_Res result = (IF_ERP_Product_Classes.IF_OPTY_002_Res) JSON.deserialize(requestBody, IF_ERP_Product_Classes.IF_OPTY_002_Res.class);

        IF_ERP_ProductBatch batch = new IF_ERP_ProductBatch();
        batch.res = result;
        if(!Test.isRunningTest()) Database.executeBatch(batch);

        Map<String,String> returnMap = new Map<String,String>();
        returnMap.put('code','201');
        returnMap.put('message','success');
        return returnMap;
    }
}