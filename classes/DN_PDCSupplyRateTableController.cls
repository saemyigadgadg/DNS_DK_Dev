/** 
 * @Class :  DN_PDCSupplyRateTableController
 * 
 * @Test: 
 * @Author : Kyongyun Jung
 * @Date : 2025. 01. 07. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-07 | KYONGYUN JUNG  | 최초작성 (대리점별 공급율)
 */ 
public with sharing class DN_PDCSupplyRateTableController {
    public DN_PDCSupplyRateTableController() {}
   
    @AuraEnabled
    public static Map<String,Object> getSupplyList(String accountId, Date supplyDateStart, Date supplyDateEnd){
        System.debug(accountId + ' :: accountId');
        SYstem.debug(supplyDateStart + ' :: : supplyDateStart');
        SYstem.debug(supplyDateEnd + ' :: : supplyDateEnd');
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {  
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
           
            //주문번호별
           
            String query = ' SELECT   Id  '
                                + ' ,Name  '
                                + ' ,Order__r.Id  '
                                + ' ,Order__r.Dealer__r.Name  '
                                + ' ,Order__r.Dealer__c  '
                                + ' ,Order__r.FM_OrderDate__c  '
                                + ' ,Order__r.FM_CustomerName__c  '
                                + ' ,Order__r.OrderNumber__c  '
                                + ' ,Order__r.TotalItemQtyCount__c  '
                                + ' ,Order__r.TotalItemCount__c  '
                                + ' ,FM_OrderNumber__c  '
                                + ' ,OrderItemNumber__c  '
                                + ' ,Part__r.ProductCode '
                                + ' ,Part__r.FM_MaterialDetails__c '
                                + ' ,ReplacingPart__r.ProductCode  '
                                + ' ,ReplacingPart__r.FM_MaterialDetails__c   '
                                + ' ,Quantity__c  '
                                + ' ,Order__r.CreatedDate  '
                                + ' FROM    DealerOrderItem__c '
                                + ' WHERE   Id != null'
                                + ' AND     (Order__r.FM_OrderDate__c >= :supplyDateStart AND Order__r.FM_OrderDate__c <= :supplyDateEnd) AND Delete__c =\'N\'';
           
            String querySentence = query + queryAnd + ' ORDER BY FM_OrderNumber__c ASC, OrderItemNumber__c DESC';
            System.debug(querySentence + ' :::querySentence');
            Map<Id, DealerOrderItem__c> orderItemMap = new map<Id, DealerOrderItem__c>();
            List<SupplyWrapper> supplyList = new List<SupplyWrapper>();
            Set<Id> dOItemsIds = new Set<Id>();
            
            for(DealerOrderItem__c pdoList :  Database.query(querySentence)){
                dOItemsIds.add(pdoList.Id);
                orderItemMap.put(pdoList.Id, pdoList);
            }
            //출고내역
            List<DealerInventoryMovements__c> dimList = [
                SELECT   Id
                        ,DealerOrderItem__c
                        ,FM_CreatedDate__c
                        ,Quantity__c
                        ,DealerOrderItem__r.Order__c
                FROM    DealerInventoryMovements__c
                WHERE   RecordType.DeveloperName = 'GoodsIssue' //출고정보만만
                AND     DealerOrderItem__c IN :dOItemsIds
            ];
            System.debug( dimList + ' : dimList');
            for(DealerInventoryMovements__c sDimList : dimList){
                SupplyWrapper supList = new SupplyWrapper();
                DealerOrderItem__c doiObj = new DealerOrderItem__c();
                doiObj = orderItemMap.get(sDimList.DealerOrderItem__c);
                if(doiObj!=null){
                    supList.dimId           = sDimList.Id;
                    supList.doitId          = sDimList.DealerOrderItem__c;
                    supList.exportDate      = sDimList.FM_CreatedDate__c;
                    supList.exportQty       = sDimList.Quantity__c;
                    supList.doId            = doiObj.Order__r.Id;
                    supList.dealerId        = doiObj.Order__r.Dealer__c;
                    supList.dealerName      = doiObj.Order__r.Dealer__r.Name;
                    supList.orderDate       = doiObj.Order__r.FM_OrderDate__c;
                    supList.customerName    = doiObj.Order__r.FM_CustomerName__c;
                    supList.orderNumber     = doiObj.Order__r.OrderNumber__c;
                    supList.orderQty        = doiObj.Quantity__c;
                    supList.totalOrderQty   = doiObj.Order__r.TotalItemQtyCount__c; 
                    supList.totalOItemQty   = doiObj.Order__r.TotalItemCount__c;
                    supList.orderItemNumber = doiObj.OrderItemNumber__c;
                    supList.partNumber      = doiObj.ReplacingPart__r.ProductCode;//doiObj.Part__r.ProductCode;
                    supList.partName        = doiObj.ReplacingPart__r.FM_MaterialDetails__c;//doiObj.Part__r.FM_MaterialDetails__c;
                    supList.standDate       = doiObj.Order__r.CreatedDate.date().addDays(1);
                    supList.createdDate     = doiObj.Order__r.CreatedDate;
                    supList.dateGap         = supList.orderDate.daysBetween(supList.exportDate);
                    supList.exQtyWiOneday   = supList.dateGap > 1 ? 0 : supList.exportQty; // 1일이내 출고수량/요청수량 
                    supList.rowPerOrderItem = Math.round(supList.dateGap > 1 ? 0 : (supList.exportQty/supList.orderQty) *100.0); // 1일이내 출고수량/요청수량 
                    supList.rowPerOrder     = Math.round(supList.dateGap > 1 ? 0 : (supList.exportQty/supList.totalOrderQty) *100.0); // 1일이내 총 출고수량/총 주문수량 
                    //supList.totalExQty      = rowMap.get(doiObj.Order__r.Id);
                    //supList.exportQtySum    = countMap.get(doiObj.Order__r.Id);
                    //supList.perOrderItem    = Math.round((supList.exportQtySum / supList.totalOrderQty) * 100.0); //소요일 1일내 총 출고수량 / 총 주문수량
                    //supList.perOrder        = Math.round((supList.exportQtySum / supList.totalOrderQty) * 100.0);
                    //supList.totalOItemCnt   = rowitemMap.get(sDimList.DealerOrderItem__c);
                }  
                supplyList.add(supList); 
            }
            
            List<SupplyWrapper> newSupplyWrappers = new List<SupplyWrapper>();
            for (SupplyWrapper sw : supplyList) {
                if (orderItemMap.containsKey(sw.doitId)) {
                    orderItemMap.remove(sw.doitId);
                }
            }
            for (Id remainingKey : orderItemMap.keySet()) {
                DealerOrderItem__c remainingDoiObj = orderItemMap.get(remainingKey);
                newSupplyWrappers.add(new SupplyWrapper(remainingDoiObj));
            }
            supplyList.addAll(newSupplyWrappers);
            
            //Map<Id, Decimal> countMap = new Map<Id, Decimal>();
            Map<String, Decimal> countMap = new Map<String, Decimal>();
            Map<Id, Integer> rowMap   = new Map<Id, Integer>();
            Map<Id, Decimal> orderMap = new Map<Id, Decimal>();
            Map<String, Integer> rowitemMap = new Map<String, Integer>();
           // Map<String, Decimal> rowitOrderQMap = new Map<String, Decimal>(); //<-주문수량합산
            //System.debug(supplyList + ' ::: supplyList');
            for(SupplyWrapper sup : supplyList){  
                Id orderId = sup.doId;        // 해당 주문 ID를 저장
                Id orderItemId = sup.doitId;  // 해당 아이템 ID를 저장
                String plusId = orderId+'_'+orderItemId; //
                if(orderMap.containsKey(orderId)){
                    orderMap.put(orderId, orderMap.get(orderId) + (sup.dateGap > 1 ? 0 :sup.exportQty));
                    rowMap.put(orderId, rowMap.get(orderId)+1);
                } else {
                    orderMap.put(orderId, (sup.dateGap > 1 ? 0 :sup.exportQty));
                    rowMap.put(orderId, 1);
                }

                if (countMap.containsKey(plusId)) {
                    countMap.put(plusId, countMap.get(plusId) + (sup.dateGap > 1 ? 0 :sup.exportQty));
                    rowitemMap.put(plusId, rowitemMap.get(plusId)+1);
                  //  rowitOrderQMap.put(plusId, countMap.get(plusId) + (sup.orderQty));
                } else {
                    countMap.put(plusId, (sup.dateGap > 1 ? 0 :sup.exportQty));
                   // rowitOrderQMap.put(plusId, sup.orderQty);
                    rowitemMap.put(plusId, 1);
                }
            }
            System.debug(countMap + ' ::: countMap');

            for (SupplyWrapper swr : supplyList) {
                String keyName = swr.doId+'_'+swr.doitId;
                //주문별  출고 수량 -> 주문별 화면 머지용
                swr.totalExQty      = rowMap.get(swr.doId);
                //주문별 항목 수량 -> 항목별 화면 머지용
                swr.totalOItemCnt   = rowitemMap.get(keyName);
                //총 아이템별 출고수량 
                swr.exportItQtySum  = countMap.get(keyName);//countMap.get(swr.doId);
               // swr.orderItQtySum   = rowitOrderQMap.get(keyName);
                //주문별 총 출고수량
                swr.exportQtySum    = orderMap.get(swr.doId);
                //항목별공급율: 항목별 총 출고수량/ 항목별 요청수량 (화면머지용)
                System.debug(swr.exportItQtySum + ' :: swr.exportItQtySum');
                System.debug(swr.orderQty + ' :: swr.orderQty');

                swr.perOrderItem    =swr.orderQty == 0 ? 0 : ((swr.exportItQtySum/ swr.orderQty ) * 100.0).setScale(2,RoundingMode.DOWN); //Math.round((swr.exportItQtySum/ swr.orderQty ) * 100.0);//swr.totalOrderQty) * 100.0); swr.orderItQtySum
                //주문별공급율: 총 출고수량 / 총 주문수량 (화면머지용)
                swr.perOrder        = swr.totalOrderQty==0 ? 0 :  ((swr.exportQtySum  / swr.totalOrderQty) * 100.0).setScale(2,RoundingMode.DOWN);//Math.round((swr.exportQtySum  / swr.totalOrderQty) * 100.0);
            }

            supplyList.sort();
          
            result.put('supplyList', supplyList); // 전체리스트
            //System.debug(supplyList);
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    public class SupplyWrapper implements Comparable {
        @AuraEnabled public Id       doId            { get; set; } //DealerOrder__c.Id
        @AuraEnabled public Id       dealerId 		 { get; set; } //DealerOrder__c.Dealer__c = Account
        @AuraEnabled public String   dealerName 	 { get; set; } //대리점명
        @AuraEnabled public Date     orderDate	     { get; set; } //주문일
        @AuraEnabled public String   customerName	 { get; set; } //고객사명
        @AuraEnabled public Decimal  totalOrderQty   { get; set; } //주문당 총 item수랑
        @AuraEnabled public Decimal  totalOItemQty   { get; set; } //주문당 총 요청수량
        @AuraEnabled public Id       doitId 		 { get; set; } //DealerOrderItem .Id
        @AuraEnabled public String   orderNumber	 { get; set; } //주문번호
        @AuraEnabled public String   orderItemNumber { get; set; } //항목
        @AuraEnabled public String   partNumber      { get; set; } //품번
        @AuraEnabled public String   partName        { get; set; } //품명
        @AuraEnabled public Decimal  orderQty        { get; set; } //요청수량
        @AuraEnabled public Id       dimId           { get; set; } //DealerInventoryMovements__c.Id
        @AuraEnabled public Decimal  exportQty       { get; set; } //출고수량
        @AuraEnabled public Decimal  exQtyWiOneday   { get; set; } //1일이내 출고수량
        @AuraEnabled public Integer  totalExQty      { get; set; } //출고ROW 
        @AuraEnabled public Date     exportDate      { get; set; } //출고일
        @AuraEnabled public Decimal  dateGap         { get; set; } //소요일 (출고일-주문일)
        @AuraEnabled public Decimal  rowPerOrderItem { get; set; } //row공급율
        @AuraEnabled public Decimal  perOrderItem    { get; set; } //항목별공급율
        @AuraEnabled public Decimal  rowPerOrder     { get; set; } //row주문공급율
        @AuraEnabled public Decimal  perOrder        { get; set; } //주문별공급율
        @AuraEnabled public Decimal  exportItQtySum  { get; set; } //항목별출하주문건수
        @AuraEnabled public Decimal  exportQtySum    { get; set; } //전체주문별출하건수
        @AuraEnabled public Date     standDate       { get; set; } //기준일자
        @AuraEnabled public Decimal  totalOItemCnt   { get; set; } //주문당 항목수량
        @AuraEnabled public Datetime createdDate     { get; set; } //for ordering
      //  @AuraEnabled public Decimal  orderItQtySum   { get; set; } //항목별총주문건수

        public SupplyWrapper() {}
        public SupplyWrapper(DealerOrderItem__c doItem) {
            this.doId            = doItem.Order__r.Id;
            this.dealerId        = doItem.Order__r.Dealer__c;
            this.dealerName      = doItem.Order__r.Dealer__r.Name;
            this.orderDate       = doItem.Order__r.FM_OrderDate__c;
            this.customerName    = doItem.Order__r.FM_CustomerName__c;
            this.doitId          = doItem.Id;
            this.orderNumber     = doItem.Order__r.OrderNumber__c;
            this.orderQty        = doItem.Quantity__c;
            this.totalOrderQty   = doItem.Order__r.TotalItemQtyCount__c; 
            this.totalOItemQty   = doItem.Order__r.TotalItemCount__c;
            this.orderItemNumber = doItem.OrderItemNumber__c;
            this.partNumber      = doItem.ReplacingPart__r.ProductCode;//doItem.Part__r.ProductCode;
            this.partName        = doItem.ReplacingPart__r.FM_MaterialDetails__c;//doItem.Part__r.FM_MaterialDetails__c;
            this.createdDate     = doItem.Order__r.CreatedDate;   
            this.standDate       = doItem.Order__r.CreatedDate.date().addDays(1);     
            this.dateGap         = 0;
            this.exportQty       = 0;
            this.exQtyWiOneday   = 0;
            this.rowPerOrderItem = 0; 
            this.perOrderItem    = 0;
            this.rowPerOrder     = 0;
            this.perOrder        = 0;
            this.exportQtySum    = 0;
            this.exportItQtySum  = 0;
            this.totalExQty      = 0;
            this.totalOItemCnt   = 0; 
           // this.orderItQtySum   = 0; 
        }

        public Integer compareTo(Object cmparTo) {
            SupplyWrapper cmtp = (SupplyWrapper)cmparTo;
            
            if (createdDate < cmtp.createdDate) return 1;
            if (createdDate > cmtp.createdDate) return -1;

            // 모든 값이 같다면 오더아이템순서
            return orderItemNumber.compareTo(cmtp.orderItemNumber);
        }
    }

    public enum StatusCode { SUCCESS, ERROR }

    public class StatusInfo {
        @AuraEnabled public Integer code      {get; set;}
        @AuraEnabled public String msg        {get; set;}
        @AuraEnabled public StatusCode status {get; set;}

        public StatusInfo() {
            code = 200;
            status = StatusCode.SUCCESS;
        }

        public void setCode(Integer code) {
            this.code = code;
        }

        public void setMessage(String msg) {
            this.msg = msg;
        }

        public void setError(String msg, Integer code) {
            this.status = StatusCode.ERROR;
            this.code = (code == null) ? 400 : code;
            setMessage(msg);
        }

    }

    public class DN_PDCSupplyRateTableControllerException extends Exception {}
}