@RestResource(urlMapping='/accounts/*')
global with sharing class IF_ERP_AccountBatchCallOut {
    public IF_ERP_AccountBatchCallOut() {}

    @HttpPost
    global static Map<String,String> callOut(){
        RestRequest  request   = RestContext.request;
        RestResponse response  = RestContext.response;

        String urlInfo      = request.requestURI;
        String requestBody  = request.requestBody.toString();

        IF_ERP_Account_Classes.IF_ACCOUNT_005_Res resultDto  = 
            (IF_ERP_Account_Classes.IF_ACCOUNT_005_Res) JSON.deserialize(requestBody, IF_ERP_Account_Classes.IF_ACCOUNT_005_Res.class);

        IF_ERP_AccountBatchAPI batch = new IF_ERP_AccountBatchAPI(resultDto);
        Database.executeBatch(batch, 50);

        Map<String,String> returnMap = new Map<String,String>();
        returnMap.put('code','201');
        returnMap.put('message','batchSuccess');
        return returnMap;
    }
}