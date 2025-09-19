@RestResource(urlMapping='/insert_ifOrder_batch/*')
global with sharing class IF_ERP_OrderBatchAPI {
    public IF_ERP_OrderBatchAPI() {}

    public class NotExistTableException  extends Exception{}    

    @HttpPost
    global static Map<String,String> callOut(){
        RestRequest  request   = RestContext.request;
        RestResponse response  = RestContext.response;

        // GET Request QueryString
        String urlInfo      = request.requestURI;

        // Get Request Body
        String requestBody = request.requestBody.toString();
        IF_ERP_Order_Classes.IF_ORDER_002_Res resultDto  = 
            (IF_ERP_Order_Classes.IF_ORDER_002_Res) JSON.deserialize(requestBody, IF_ERP_Order_Classes.IF_ORDER_002_Res.class);

        IF_ERP_OrderBatchAPIBatch batch = new IF_ERP_OrderBatchAPIBatch();
        batch.response = resultDto;
        Database.executeBatch(batch);

        Map<String,String> returnMap = new Map<String,String>();
        returnMap.put('code','201');
        returnMap.put('message','success');
        return returnMap;
    }
}