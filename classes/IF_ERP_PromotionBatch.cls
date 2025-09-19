/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-21-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-21-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
global with sharing class IF_ERP_PromotionBatch 
                                        implements Database.Batchable<Object> , 
                                        Database.AllowsCallouts, 
                                        Database.Stateful  {

    public IF_ERP_PromotionBatch(IF_ERP_Order_Classes.IF_ORDER_016_Req request,  String tableNm){
        this.request = request;
        this.tableNm = tableNm;
    }

    private IF_ERP_Order_Classes.IF_ORDER_016_Req request;
    private String  tableNm;

    private String  message; 
    private Integer successCnt;
    private Integer failCnt;


// Start    
    public Iterable<Object> start(Database.BatchableContext BC) {
        // 1. CALL OUT SAP 
        IF_ERP_Order_Classes.IF_ORDER_016_Res response = new IF_ERP_Order().IF_ORDER_016(request);  

        if(tableNm.equals('T_O_ZSSY')){
            System.debug('T_O_ZSSY');
            return response.T_O_ZSSY;
        }
        
        else if(tableNm.equals('T_O_ZSSX')){
            System.debug('T_O_ZSSX');
            return response.T_O_ZSSX;
        }
        
        else {
            return new List<Object>();
        }
    }

// Execute    
    public void execute(Database.BatchableContext BC, List<Object> scope){
        
        List<OrderPromotion__c> promotionList = new List<OrderPromotion__c>();

        try{
            // convert 
            if( tableNm.equals('T_O_ZSSY') ){
                System.debug('T_O_ZSSY');
                promotionList = getPromotionListFromZSSY(scope);
            }
            else if( tableNm.equals('T_O_ZSSX') ){
                System.debug('T_O_ZSSX');
                promotionList = getPromotionListFromZSSX(scope);
            }
            else {
                throw new NotExistTableException();
            }

            System.debug('promotionList.size() : '+promotionList.size());
            System.debug('promotionList : '+promotionList);

            upsert promotionList PromotionCode__c;
        }
        catch(NotExistTableException e){
            this.message = 'BATCH EXECUTE :: NOT EXIST TABLE IN RFC - '+tableNm;
        }
        catch(Exception e){
            this.message = 'BATCH EXECUTE :: NOT CUTOMER EXCEPTION - '+e.getMessage();
        }
        finally{
            System.debug('EXCEPTION MESSAGE : '+this.message);
        }
    }

// Finish    
    public void finish(Database.BatchableContext BC){
        
        if(this.successCnt == 0){
            this.message = 'fail';
        }

        if(this.failCnt == 0){
            this.message = 'success';
        }
    }

    private List<OrderPromotion__c> getPromotionListFromZSSY(List<Object> scope){

        // 1. Return 해야할 ORDER PROMOTION LIST
        List<OrderPromotion__c>                                    promotionList = new List<OrderPromotion__c>(); 

        // 2. SCOPE를  IF_ORDER_016_Res_T_O_ZSSY 리스트로 변환
        List<IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSY>       zssyList      = (List<IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSY>) scope;
        Map<String,IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSY> zssyMap       = new Map<String,IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSY>(); 
        Set<String>                                                zssyKeys      = new Set<String>();


        // 3. SAP 호출로 부터 KEY 값을 추출  - VARCOND
        for(IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSY zssy : zssyList){
            zssyMap.put(zssy.VARCOND, zssy);
            zssyKeys.add(zssy.VARCOND);
        }

        
        // 4. SFDC ORG 에서 KEY 값 기준으로 Map 반환
        Map<String,OrderPromotion__c> promotionMap     = getPromotionMap(zssyKeys);

        
        // 5. ZSSY 필드를 순회 
        for(String key : zssyKeys){
            
            // 1. key 가 ORG MAP 에서 조회가 되지 않음 = 새로 생성 
            if(promotionMap.get(key) == null){
                promotionMap.put(key,new OrderPromotion__c());
            }

            // 2. MAP 으로 부터 OrderPromotion__c 추출 
            // 3. ZSSY 
            IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSY zssy = zssyMap.get(key);

            OrderPromotion__c promotion = promotionMap.get(key);
            promotion.PromotionCode__c          = zssy.VARCOND; 
            promotion.Name                      = zssy.VCTEXT;
            promotion.Rate__c                   = Decimal.valueOf(zssy.KBETR);             
            promotion.StartDate__c              = convertToDate(zssy.DATAB);
            promotion.EndDate__c                = convertToDate(zssy.DATBI);
            promotion.CalculateType__c          = 'A';

            promotionList.add(promotion);
        }

        return promotionList;
    }

    private List<OrderPromotion__c> getPromotionListFromZSSX(List<Object> scope){

        List<OrderPromotion__c>                                    promotionList  = new List<OrderPromotion__c>(); 
        List<IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSX>       zssxList       = (List<IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSX>) scope;
        Map<String,IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSX> zssxMap        = new Map<String,IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSX>(); 
        Set<String>                                                zssxKeys       = new Set<String>();        



        // 3. SAP 호출로 부터 KEY 값을 추출  - VARCOND
        for(IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSX zssx : zssxList){
            zssxMap.put(zssx.VARCOND, zssx);
            zssxKeys.add(zssx.VARCOND);
        }
        
        // 2. GET PROMOTION MAP 
        Map<String,OrderPromotion__c> promotionMap     = getPromotionMap(zssxKeys);

        for(String key : zssxKeys){

            if(promotionMap.get(key) == null){
                promotionMap.put(key,new OrderPromotion__c());
            }

            OrderPromotion__c promotion = promotionMap.get(key);
            IF_ERP_Order_Classes.IF_ORDER_016_Res_T_O_ZSSX zssx = zssxMap.get(key);
            promotion.PromotionCode__c          = zssx.VARCOND; 
            promotion.Name                      = (zssx.VCTEXT != null) ? zssx.VCTEXT : promotion.Name;
            promotion.Amount__c                 = (zssx.KBETR  != null) ? Decimal.valueOf(zssx.KBETR) : promotion.Amount__c;              
            promotion.StartDate__c              = convertToDate(zssx.DATAB);
            promotion.EndDate__c                = convertToDate(zssx.DATBI);
            promotion.CalculateType__c          = 'C';
            promotionList.add(promotion);
        }

        return promotionList;
    }

    private Map<String,OrderPromotion__c> getPromotionMap(Set<String> promotionCodeSet){

        Map<String,OrderPromotion__c> promotionMap = new Map<String,OrderPromotion__c>();

        for(OrderPromotion__c op :[
            SELECT Id,
            PromotionCode__c,
            Name,
            Rate__c, 
            StartDate__c,
            EndDate__c,
            CalculateType__c,Amount__c 
            FROM OrderPromotion__c
            WHERE PromotionCode__c IN :promotionCodeSet]){
                promotionMap.put(op.PromotionCode__c, op);
            }
        return promotionMap;
    }

    private Date convertToDate(String dateString){
        String[] dateInfoArray = dateString.split('-');
        if(Integer.valueOf(dateInfoArray[0]) > 2999){
            dateInfoArray[0] = '2999';
        }
        return Date.newInstance(Integer.valueOf(dateInfoArray[0]), Integer.valueOf(dateInfoArray[1]), Integer.valueOf(dateInfoArray[2]));
    }

// Custom Exception 
    public class NotExistTableException  extends Exception{}    
}