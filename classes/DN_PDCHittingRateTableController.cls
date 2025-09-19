/** 
 * @Class :  DN_PDCHittingRateTableController
 * 
 * @Test: 
 * @Author : Kyongyun Jung
 * @Date : 2025. 01. 07. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-07 | KYONGYUN JUNG  | 최초작성 (대리점별 적중율)
 * 
// 기간	ZSST8050-AUDAT                                   DealerOrder__c.FM_OrderDate__c
// 대리점명	"ZSST8050-DEALER_CD Customer Master 의 이름"    DealerOrder__c.Dealer__r.code
// 
// 주문일	ZSST8050-AUDAT                                  DealerOrder__c.FM_OrderDate__c
// 고객사명	ZSST8050-NAME1                                   DealerOrder__c.FM_CustomerName__c
// 주문번호	ZSST8050-VBELN                                   DealerOrder__c.FM_CustomerName__c
// 항목	ZSST8060-POSNR                                      DealerOrderItem__c.OrderItemNumber__c
// 품번	ZSST8060-REPNR                                      DealerOrderItem__c.ReplacingPart__r.ProductCode
// 품명	ZSST8060-MAKTX                                      DealerOrderItem__c.ReplacingPart__r.FM_MaterialDetails__c 
// 요청수량	ZSST8060-KWMENG                                  DealerOrderItem__c.Quantity__c
// 가용재고	ZSST8060-AVQTY                                  DealerOrderItem__c.AvailableQuantity__c
 */ 
public with sharing class DN_PDCHittingRateTableController {
    //public DN_PDCHittingRateTableController(){}

    @AuraEnabled
    public static Map<String,Object> getHitList(String accountId, Date hitDateStart, Date hitDateEnd){
        Map<String,Object> result = new Map<String,Object>();
        // - 관련 RFC 'ZSS_RECV_EP_ACCURACY_RATE'	
        // - 주문시점에 가용재고 여부로 적중률 계산 (가용재고 / 요청수량)	
        // - 100%가 넘는 것은 100%로 일괄 계산	
        // - 가용재고>요청수량의 경우 가용재고=요청수량으로 변경하여 계산	
        // - 가용재고 < 0 일 경우 가용재고 = 0 으로 변경하여 계산	

        //StatusInfo resultStatus = new StatusInfo();
        system.debug('DN_PDCHittingRateTableController');
        try {  
            Map<Id, DealerOrderItem__c> orderItemMap = new map<Id, DealerOrderItem__c>();
            List<RateWapper> rateList = new List<RateWapper>();

            Schema.DescribeSObjectResult r = DealerCustomer__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
           
            String queryAnd = '';
            if(accountId.startsWith(keyPrefix)) {
                DealerCustomer__c deal = [SELECT SourceAccount__c FROM DealerCustomer__c WHERE Id = :accountId LIMIT 1];
                accountId = deal.SourceAccount__c;
                queryAnd += 'AND Order__r.Dealer__c =:accountId' ;
            } else if (accountId =='All') {
                System.debug('Only Admin');
            } else {
                // User currentUser = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                // accountId = currentUser.AccountId;
                queryAnd += 'AND Order__r.Dealer__c =:accountId' ;
            }
            System.debug('accountId >>> '+accountId);

            //주문번호별
            String query = 'SELECT   Order__r.Id '
                                + ' ,Order__r.OrderNumber__c '
                                + ' ,Order__r.Dealer__c '
                                + ' ,Order__r.Dealer__r.Name '
                                + ' ,Order__r.FM_OrderDate__c '
                                + ' ,Order__r.FM_CustomerName__c '
                                + ' ,Order__r.TotalItemCount__c '    //주문 품목수 
                                + ' ,Order__r.TotalItemQtyCount__c ' //주문 품목요청수//totalOICnt
                                + ' ,Id  '
                                + ' ,Name  '
                                + ' ,FM_OrderNumber__c  ' 
                                + ' ,OrderItemNumber__c  ' //항목
                                + ' ,Part__r.ProductCode ' // 품번
                                + ' ,Part__r.FM_MaterialDetails__c ' //품명
                                + ' ,Order__r.DeletedItemCount__c'
                                + ' ,ReplacingPart__r.ProductCode ' // 품번
                                + ' ,ReplacingPart__r.FM_MaterialDetails__c ' //품명
                                + ' ,Quantity__c '
                                + ' ,AvailableQuantity__c '
                                + ' ,Order__r.CreatedDate  '
                        + ' FROM    DealerOrderItem__c '
                        + ' WHERE   Delete__c != \'Y\' AND (Order__r.FM_OrderDate__c >= :hitDateStart AND Order__r.FM_OrderDate__c <= :hitDateEnd) ';

            String htLit = query + queryAnd + ' ORDER BY FM_OrderNumber__c ASC, OrderItemNumber__c DESC';
            for(DealerOrderItem__c rtList : Database.query(htLit)){
                RateWapper rw = new RateWapper();
                
                rw.doId           = rtList.Order__r.Id;
                rw.dealerId       = rtList.Order__r.Dealer__c;
                rw.dealerName     = rtList.Order__r.Dealer__r.Name;
                rw.orderDate      = rtList.Order__r.FM_OrderDate__c;
                rw.customerName   = rtList.Order__r.FM_CustomerName__c;
                rw.doitId         = rtList.Id;
                rw.orderNumber    = rtList.FM_OrderNumber__c; 
                rw.orderItemNumber= rtList.OrderItemNumber__c;
                rw.partNumber     = rtList.ReplacingPart__r.ProductCode;
                rw.partName       = rtList.ReplacingPart__r.FM_MaterialDetails__c;
                rw.orderQty       = rtList?.Quantity__c == null? 0: rtList.Quantity__c;
                rw.avQty          = rtList?.AvailableQuantity__c == null? 0: rtList.AvailableQuantity__c; //< 0? 0 : rtList.AvailableQuantity__c;
                rw.totalOrderCnt  = rtList.Order__r.TotalItemCount__c; //주문 총 건수
                rw.rowspan        = rtList.Order__r.TotalItemCount__c - rtList.Order__r.DeletedItemCount__c;
                rw.calAvQty       = (rw.avQty < 0 ? 0 : (rw.avQty> rw.orderQty ? rw.orderQty : rw.avQty));
                rw.perItem        = rw.orderQty == 0 ? 0: ((rw.calAvQty / rw.orderQty)* 100.0);
                rw.calPerItem     = (rw.perItem > 100.00 ? 100.0 : rw.perItem); 
                rw.totalOICnt     = rtList.Order__r.TotalItemQtyCount__c; //주문 아이템별 총 요청 건수
                rw.perOrder       = 0;
                rw.dCreatedDate   = rtList.Order__r.CreatedDate;
                rateList.add(rw); 
            }

            Map<Id, Decimal> doIdToSumMap = new Map<Id, Decimal>();
            for (RateWapper rw : rateList) {
                if (doIdToSumMap.containsKey(rw.doId)) {
                    doIdToSumMap.put(rw.doId, doIdToSumMap.get(rw.doId) + rw.calPerItem);
                } else {
                    doIdToSumMap.put(rw.doId, rw.calPerItem);
                }
            }

            /////perOrder 업데이트 주문별적중류 row마다 쌓기
            for (RateWapper rw : rateList) {
                rw.perOrder = rw.totalOrderCnt ==0? 0: (doIdToSumMap.get(rw.doId)/rw.totalOrderCnt).setScale(2, RoundingMode.DOWN);
            }
            rateList.sort();
            result.put('rateList', rateList); // 전체리스트
   

        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            //resultStatus.setError(errorMessage, null);
        }
       // result.put('status', resultStatus);
        return result;
    }

    /////Wrapper
    public class RateWapper implements Comparable  {
        @AuraEnabled public Id doId                 { get; set; }  //DealerOrder__c.Id
        @AuraEnabled public Id dealerId 			{ get; set; }  //DealerOrder__c.Dealer__c = Account
        @AuraEnabled public String dealerName 		{ get; set; }  //대리점명
        @AuraEnabled public Date orderDate	        { get; set; }  //주문일
        @AuraEnabled public String customerName	    { get; set; }  //고객사명
        @AuraEnabled public Id doitId 			    { get; set; }  //DealerOrderItem .Id
        @AuraEnabled public String orderNumber		{ get; set; }  //주문번호
        @AuraEnabled public String orderItemNumber  { get; set; }  //항목
        @AuraEnabled public String partNumber       { get; set; }  //품번
        @AuraEnabled public String partName         { get; set; }  //품명
        @AuraEnabled public Decimal orderQty        { get; set; }  //요청수량
        @AuraEnabled public Decimal avQty           { get; set; }  //가용수량
        @AuraEnabled public Decimal calAvQty        { get; set; }  //계산 가용수량 1. 가용재고>요청수량 => 가용재고=요청수량 2. 가용재고 < 0 => 가용재고 = 0
        @AuraEnabled public Decimal perItem         { get; set; }  //아이템 적중율 100%가 넘는 것은 100%로 일괄 계산	
        @AuraEnabled public Decimal calPerItem      { get; set; }  //계산 아이템 적중율 
        @AuraEnabled public Decimal perOrder        { get; set; }  //주문 적중율
        @AuraEnabled public Decimal totalOrderCnt   { get; set; }  //각 주문의 아이템 수 dearlerOrder - delarOrderItem Count
        @AuraEnabled public Decimal rowspan         { get; set; }  //각 주문의 아이템 수 dearlerOrder - delarOrderItem Count
        @AuraEnabled public Decimal totalOICnt      { get; set; }  //각 주문 품목요청수  dearlerOrder - delarOrderItem Quantity Count
        @AuraEnabled public Datetime dCreatedDate   { get; set; } 

        public Integer compareTo(Object cObj) {
            RateWapper compareRow = (RateWapper)cObj;
            
            if (dCreatedDate < compareRow.dCreatedDate) return 1;
            if (dCreatedDate > compareRow.dCreatedDate) return -1;

            // 모든 값이 같다면 0 반환
           // return 0;
            return orderItemNumber.compareTo(compareRow.orderItemNumber);
        }
    }

    public class DN_PDCHittingRateTableControllerException extends Exception {}

}