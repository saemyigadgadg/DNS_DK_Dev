/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 09-04-2025
 * @last modified by  : deokjun.kim@sobetec.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-14-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
@IsTest
public with sharing class IF_ERP_OrderBatch_Test {
    public IF_ERP_OrderBatch_Test() {}

    @IsTest 
    static void orderBatchTest(){
        InterfaceCommonUtil.setInterface('IF-ORDER-002', 'IF_ERP_Order');
        Test.startTest();
        IF_ERP_Order_Classes.IF_ORDER_002_Req_I_ORG req_I_org =
        new IF_ERP_Order_Classes.IF_ORDER_002_Req_I_ORG(); 
        req_I_org.VKORG = '1800';
        req_I_org.VTWEG = '10';
        req_I_org.SPART = '40';

        IF_ERP_Order_Classes.IF_ORDER_002_Req req = new IF_ERP_Order_Classes.IF_ORDER_002_Req(); 
        req.I_ERDAT_F = '20230110';
        req.I_ERDAT_T = '20230531';
        req.I_ORG     =  req_I_org;        


        IF_ERP_OrderBatch batchJob = new IF_ERP_OrderBatch(req,'T_LIST','ZRE');

        batchJob.assignOrderIncentive(new IF_ERP_OrderBatch.OrderDTO(), new IF_Order__c());
        batchJob.changeOrder(new IF_ERP_OrderBatch.OrderDTO(), new IF_Order__c());
        Database.executeBatch(batchJob, 50);
        Test.stopTest();
    }

    @IsTest 
    static void orderAPIBatchTest(){
        InterfaceCommonUtil.setInterface('IF-ORDER-002', 'IF_ERP_Order');
        Test.startTest();
        IF_ERP_Order_Classes.IF_ORDER_002_Req_I_ORG req_I_org =
        new IF_ERP_Order_Classes.IF_ORDER_002_Req_I_ORG(); 
        req_I_org.VKORG = '1800';
        req_I_org.VTWEG = '10';
        req_I_org.SPART = '40';

        IF_ERP_Order_Classes.IF_ORDER_002_Req req = new IF_ERP_Order_Classes.IF_ORDER_002_Req(); 
        req.I_ERDAT_F = '20230110';
        req.I_ERDAT_T = '20230531';
        req.I_ORG     =  req_I_org;        

        IF_ERP_Order_Classes.IF_ORDER_002_Res res = new IF_ERP_Order().IF_ORDER_002(req);

        IF_ERP_OrderBatchAPIBatch batch = new IF_ERP_OrderBatchAPIBatch();
        batch.response = res;
        Database.executeBatch(batch);

        batch.assignOrderIncentive(new IF_ERP_OrderBatchAPIBatch.OrderDTO(), new IF_Order__c());
        batch.changeOrder(new IF_ERP_OrderBatchAPIBatch.OrderDTO(), new IF_Order__c());

        Test.stopTest();
    }

    @IsTest
    static void IF_ERP_OrderBatchAPI_Test(){
         // 1) 요청/응답 컨텍스트 준비
        RestRequest req = new RestRequest();
        req.requestURI  = '/services/apexrest/insert_ifOrder_batch/';
        req.httpMethod  = 'POST';

        // DTO 샘플 생성 (필드가 필수라면 실제 필드에 맞게 값 세팅하세요)
        IF_ERP_Order_Classes.IF_ORDER_002_Res dto =
            new IF_ERP_Order_Classes.IF_ORDER_002_Res();
        // 예) dto.orderNo = 'ORD-0001'; dto.items = new List<...>{ ... };

        req.requestBody = Blob.valueOf(JSON.serialize(dto));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        // 배치 잡 수 카운트(전/후 비교)
        Test.startTest();
        Map<String,String> result = IF_ERP_OrderBatchAPI.callOut();
        Test.stopTest(); // 여기서 executeBatch가 실제로 실행됨
    }

    @IsTest 
    static void promotionBatchTest(){
        InterfaceCommonUtil.setInterface('IF-ORDER-016', 'IF_ERP_Order');
        Test.startTest();
            List<String> tableNmList = new List<String>{'T_O_ZSSY','T_O_ZSSX'}; 
            IF_ERP_Order_Classes.IF_ORDER_016_Req request = new IF_ERP_Order_Classes.IF_ORDER_016_Req();
            request.I_VKORG      = '1800';
            request.I_VTWEG      = '10';
            request.I_WAERK      = 'KRW';
            request.I_VALID_ON   = '20250207';
            
            for(String title : tableNmList){
                IF_ERP_PromotionBatch batch = new IF_ERP_PromotionBatch(request, title);
                Database.executeBatch(batch,50);
            }
        Test.stopTest();        
    }


    @IsTest 
    static void warrantyBatchTest(){
        InterfaceCommonUtil.setInterface('IF-ORDER-017', 'IF_ERP_Order');
        Test.startTest();
        List<IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG> vkorg_list = new List<IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG>();  

        IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG vkorg_01 = new IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG(); 
        vkorg_01.VKORG = '1140';
        
        IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG vkorg_02 = new IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG(); 
        vkorg_02.VKORG = '4140';
        
        IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG vkorg_03 = new IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG(); 
        vkorg_03.VKORG = '1800';
        
        
        vkorg_list.add(vkorg_01);
        vkorg_list.add(vkorg_02);
        vkorg_list.add(vkorg_03);
        
        // REQUEST
        IF_ERP_Order_Classes.IF_ORDER_017_Req request = new IF_ERP_Order_Classes.IF_ORDER_017_Req();
        request.T_VKORG = vkorg_list;
        
        // execute
        List<String> tableNmList = new List<String>();
        tableNmList.add('T_DATA');
        
        for(String tableNm  : tableNmList){
            IF_ERP_WarrantyBatch batch = new IF_ERP_WarrantyBatch(request,tableNm);
            Database.executeBatch(batch,200);
        }
        Test.stopTest();        
    }
    
    @IsTest 
    static void warrantyBatchMethodTest(){
        Test.startTest();
        
        Warranty__c warranty1 = new Warranty__c(
            warrantyKey__c = 'KEY_001',
            KSCHL__c = 'A',
            VKORG__c = '1800'
        );
        Warranty__c warranty2 = new Warranty__c(
            warrantyKey__c = 'KEY_002',
            KSCHL__c = 'B',
            VKORG__c = '4140'
        );
        Warranty__c warranty3 = new Warranty__c(
            warrantyKey__c = '',
            KSCHL__c = 'B',
            VKORG__c = '4140'
        );
        insert new List<Warranty__c>{warranty1, warranty2, warranty3};

        Set<String> keySet = new Set<String>{'KEY_001', 'KEY_002'};
        new IF_ERP_WarrantyBatch(new IF_ERP_Order_Classes.IF_ORDER_017_Req(),'').getWarrantyMapFromSFDC(keySet);

        new IF_ERP_WarrantyBatch(new IF_ERP_Order_Classes.IF_ORDER_017_Req(),'').getAllWarrantyInOrgs();

        Test.stopTest();        
    }
}