@RestResource(urlMapping='/active_product_batch/*')
global with sharing class IF_ERP_PermittedItemBatchAPI {
    public IF_ERP_PermittedItemBatchAPI() {}

    @HttpPost
    global static Map<String,String> callOut(){
        RestRequest  request   = RestContext.request;
        RestResponse response  = RestContext.response;

        // GET Request QueryString
        String urlInfo      = request.requestURI;

        // Get Request Body
        String requestBody = request.requestBody.toString();
        List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST> T_LIST  = 
            (List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST>) JSON.deserialize(requestBody, List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST>.class);

        IF_ERP_PermittedItemBatchAPIBatch batch = new IF_ERP_PermittedItemBatchAPIBatch();
        batch.T_LIST = T_LIST;

        Database.executeBatch(batch);

        Map<String,String> returnMap = new Map<String,String>();
        returnMap.put('code','201');
        returnMap.put('message','success');
        return returnMap;
    }



}