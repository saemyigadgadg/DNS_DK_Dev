@RestResource(urlMapping='/get_asset_info/*')
global with sharing class IF_MaterialBatchAPI {
    public IF_MaterialBatchAPI() {}

    @HttpPost
    global static Map<String,String> callOut(){
        RestRequest  request   = RestContext.request;
        RestResponse response  = RestContext.response;

        // GET Request QueryString
        String urlInfo      = request.requestURI;

        // Get Request Body
        String requestBody = request.requestBody.toString();
        
        IF_ERP_Material_Classes.IF_CSPLUS_018_Res result = (IF_ERP_Material_Classes.IF_CSPLUS_018_Res) JSON.deserialize(requestBody, IF_ERP_Material_Classes.IF_CSPLUS_018_Res.class);

        IF_MaterialBatch batch = new IF_MaterialBatch();
        batch.res = result;
        if(!Test.isRunningTest()) Database.executeBatch(batch);

        Map<String,String> returnMap = new Map<String,String>();
        returnMap.put('code','201');
        returnMap.put('message','success');
        return returnMap;
    }
}