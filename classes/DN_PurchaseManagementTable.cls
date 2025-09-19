/** 
 * @Class :  DN_PurchaseManagementTable
 * 
 * @Test: DN_PurchaseManagementTable_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 01. 14. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-14 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_PurchaseManagementTable {
    public DN_PurchaseManagementTable() {

    }

    /*
    * @ Description : 현재 유저 정보
    */
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /*
    * @ Method : getDealerPOOrderSummaryQuery
    * @ Description : 대리점 구매 Query
    */
    private static Map<String,String> getDealerPOOrderSummaryQuery(
        String seq,
        List<String> partNameList,
        String customerOrerNumber,
        Date orderDateStart, 
        Date orderDateEnd,
        String customerName,
        String customerId,
        String status,
        String dealerId
    ){
        List<String> fields = new List<String> {
            'Id'
            ,'OrderNumber__c'
            ,'FM_OrderDate__c'
            ,'FM_OrderStatus__c'
            ,'FM_OrderStatusLabel__c'
            ,'CustomerPurchaseOrderNumber__c'
            ,'Dealer__c'
            ,'Dealer__r.Name'
            ,'Customer__c'
            ,'CustomerCode__c'
            ,'FM_CustomerName__c'
            ,'CurrencyIsoCode'
            ,'CreatedDate'
        };

        String querySelect = ' SELECT ';
                     
        //주문 Item 부품 정보로 조회
        String queryItem =  '  SELECT '
                            +' Id '
                            +' , DealerPurchaseOrder__c '
                            +' , FM_OrderNumber__c '
                            +' , OrderItemNumber__c '
                            +' , Part__c '
                            +' , Part__r.Name '
                            +' , Part__r.FM_MaterialDetails__c '
                            +' , ReplacingPart__c '
                            +' , ReplacingPart__r.Name '
                            +' , ReplacingPart__r.FM_MaterialDetails__c '
                            +' , Quantity__c '
                            +' , FM_Unit__c '
                            +' , CustomerPrice__c '
                            +' , DiscountPrice__c '
                            +' , DiscountRate__c '
                            +' , FM_DiscountAmount__c '
                            +' , GICompletedQuantity__c '//출고수량
                            +' , FM_PendingQuantity__c '//미결수량
                            +' , FM_GICompletedDate__c '
                            +' , FM_DeliveryStatus__c '
                            +' , Equipment__c '
                            +' , MachineName__c '
                            +' , Status__c '
                            +' , toLabel(Status__c) statusLabel '
                            +' , CurrencyIsoCode '
                            +' FROM item__r WHERE Id != null and Delete__c != \'Y\' ';

        String orderItemQuery = '';
        if(partNameList?.size() > 0) {
            List<String> partNameWhereClauseList = new List<String>();
            for(String partName : partNameList) {
                partNameWhereClauseList.add(' ReplacingPart__c  = \''+partName+'\' ');
            }
            orderItemQuery =  ' SELECT DealerPurchaseOrder__c FROM DealerPurchaseOrderItem__c  WHERE Delete__c != \'Y\' AND  ('+ String.join(partNameWhereClauseList, 'OR') +')';
        }

        fields.add('(' + queryItem +')');

        String query = querySelect + String.join(fields, ',');
        String queryFrom =' FROM DealerPurchaseOrder__c '
                         +' WHERE Id != null AND Delete__c != \'Y\'  AND Dealer__c = \''+ currentUser.getAgencyId()+'\' '
                         + ' AND Customer__c != null ';
                         //CreatedById = \''+UserInfo.getUserId()+'\' ';
        String additionalWhereClause = '';

        if(String.isNotBlank(seq))
            additionalWhereClause += ' AND OrderNumber__c like \'%' + seq + '%\'';
        if(String.isNotBlank(customerOrerNumber))
            additionalWhereClause += ' AND CustomerPurchaseOrderNumber__c like \'%'+ customerOrerNumber +'%\'';
        if(String.isNotBlank(customerName))
            additionalWhereClause += ' AND FM_CustomerName__c like \'%' + customerName + '%\'';
        if(String.isNotBlank(customerId) && !'All'.equals(customerId)) 
            additionalWhereClause += ' AND Customer__c = :customerId ';
        // if(String.isNotBlank(dealerPoNo))
                    
        if(orderDateStart != null && orderDateEnd != null) 
            additionalWhereClause += ' AND ( FM_OrderDate__c >= :orderDateStart AND FM_OrderDate__c <= :orderDateEnd ) ';

        switch on status {
            when  'N', 'P', 'C'{
                //미출고, 부분출고, 출고완료시
                additionalWhereClause += ' AND FM_OrderStatus__c = :status ';
            }
            when 'R' {
                //거절

            }
        }

        if(String.isNotBlank(orderItemQuery))
            additionalWhereClause += ' AND Id IN ('+orderItemQuery+')';

        return new Map<String,String>{
            'query' => querySelect + String.join(fields, ',') + queryFrom + additionalWhereClause + ' ORDER BY FM_OrderDate__c desc ',
            'queryCount' => querySelect + ' count() ' + queryFrom + additionalWhereClause
        };
    }

    /*
    * @ Method : getDNSPOOrderSummaryQuery
    * @ Description : DNS 구매 Query
    */
    private static Map<String,String> getDNSPOOrderSummaryQuery(
        String seq,
        List<String> partNameList,
        String customerOrerNumber,
        Date orderDateStart, 
        Date orderDateEnd,
        String customerName,
        String customerId,
        String status
    ){
        List<String> fields = new List<String> {
            'Id'
            ,'PartOrderNo__c'
            ,'CustomerOrderNo__c'
            ,'FM_OrderDate__c'
            ,'TotalItems__c'
            ,'ItemsAmount__c'
            ,'CurrencyIsoCode'
            ,'Buyer__r.Name'
            ,'Buyer__c'
            ,'FM_OrderStatus__c'
            ,'FM_OrderStatusLabel__c'
            ,'CreatedDate'
            ,'Supplier__c'
        };

        String querySelect = ' SELECT ';
                     
        //DNS주문 Item 부품 정보로 조회
        String queryItem =  '  SELECT '
                            +' Id '
                            +' , ItemNo__c '
                            +' , SupplyPartNo__c  '
                            +' , PartName__c '
                            +' , Quantity__c  '
                            +' , Unit__c '
                            +' , CompletedQty__c  '
                            +' , PenddingQty__c  '
                            +' , PartAmount__c '
                            +' , CurrencyIsoCode '
                            +' , ConfirmedQty__c  '
                            +' , ExpectedSupplyDate__c '
                            +' , RevisedSupplyDate__c  '
                            +' , ShipmentDate__c  '
                            +' , DepartureSite__c '
                            +' , ReceivedStatus__c   '
                            +' FROM PurchaseOrderItems__r WHERE Id != null  ';

        String orderItemQuery = '';
        if(partNameList?.size() > 0) {
            List<String> partNameWhereClauseList = new List<String>();
            for(String partName : partNameList) {
                partNameWhereClauseList.add(' SupplyPartId__c  = \''+partName+'\' ');
            }
            orderItemQuery =  ' SELECT PurchaseOrder__c FROM PurchaseOrderItems__c  WHERE ('+ String.join(partNameWhereClauseList, 'OR') +')';
        }

        fields.add('(' + queryItem +')');

        String query = querySelect + String.join(fields, ',');
        String queryFrom =' FROM PurchaseOrder__c '
                         +' WHERE Id != null AND RecordType.DeveloperName = \'Order\' AND IsOrderVisible__c = true ';
        String additionalWhereClause = '';

        if(String.isNotBlank(seq))
            additionalWhereClause += ' AND PartOrderNo__c like \'%' + seq + '%\'';
        if(String.isNotBlank(customerOrerNumber))
            additionalWhereClause += ' AND CustomerOrderNo__c like \'%'+ customerOrerNumber +'%\'';

        if(!currentUser.getIsAdmin())
            additionalWhereClause += ' AND Buyer__c = \''+currentUser.getAgencyId()+'\'';
                    
        if(orderDateStart != null && orderDateEnd != null) 
            additionalWhereClause += ' AND ( FM_OrderDate__c >= :orderDateStart AND FM_OrderDate__c <= :orderDateEnd ) ';

        if(String.isNotBlank(orderItemQuery))
            additionalWhereClause += ' AND Id IN ('+orderItemQuery+')';
        
        switch on status {
            when  'N', 'P', 'C'{
                //미출고, 부분출고, 출고완료시
                additionalWhereClause += ' AND FM_OrderStatus__c = :status ';
            }
            when 'R' {
                //거절

            }
        }

        return new Map<String,String>{
            'query' => querySelect + String.join(fields, ',') + queryFrom + additionalWhereClause + ' ORDER BY FM_OrderDate__c desc ',
            'queryCount' => querySelect + ' count() ' + queryFrom + additionalWhereClause
        };
    }

    /*
    * @ Method : getOrderSummaryList
    * @ Description : 구매 관리 조회
    */
    @AuraEnabled
    public static Map<String,Object> getOrderSummaryList(String seq,
                                                         String orderType,
                                                         List<String> partNameList,
                                                         String customerOrerNumber,
                                                         Date orderDateStart, 
                                                         Date orderDateEnd,
                                                         String customerName,
                                                         String customerId,
                                                         String status,
                                                         DN_DealerPortalDisplayController.PageReturn page,
                                                         Integer nextPage
    ){
        System.debug('orderDateStart : '+ orderDateStart);
        System.debug('orderDateEnd : '+ orderDateEnd);
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
        
        Map<String,String> queryDealerPOMap;
        Map<String,String> queryDNSPOMap;
        
        String currentDealerId = currentUser.getAgencyId();

        switch on orderType {
            when 'All'{
                queryDealerPOMap = getDealerPOOrderSummaryQuery(seq, partNameList, customerOrerNumber, orderDateStart, orderDateEnd, customerName, customerId, status, currentDealerId);
                queryDNSPOMap = getDNSPOOrderSummaryQuery(seq, partNameList, customerOrerNumber, orderDateStart, orderDateEnd, customerName, customerId, status);
            }
            when 'F' {
                //DNS 구매 요청
                queryDNSPOMap = getDNSPOOrderSummaryQuery(seq, partNameList, customerOrerNumber, orderDateStart, orderDateEnd, customerName, customerId, status);
            }
            when 'A' {
                //대리점 구매 요청
                queryDealerPOMap = getDealerPOOrderSummaryQuery(seq, partNameList, customerOrerNumber, orderDateStart, orderDateEnd, customerName, customerId, status, currentDealerId);
            }
        }

        Integer totalSize = 0;
        
        List<OrderSummary> orderSummaryList = new List<OrderSummary>();
        if(queryDealerPOMap != null) {
            String queryDealer = queryDealerPOMap.get('query');
            String totalQueryDealer = queryDealerPOMap.get('queryCount');
            
            System.debug('totalQueryDealer :: '+ totalQueryDealer);
            System.debug('queryDealer :: '+ queryDealer);

            result.put('queryDealer', queryDealer);

            Integer totalSizeDealer = Database.countQuery(totalQueryDealer);
            totalSize += totalSizeDealer;
            Set<String> orderIdSet = new Set<String>();
            for(DealerPurchaseOrder__c orderSObject : Database.query(queryDealer)) {
                OrderSummary summaryOrder = new OrderSummary(orderSObject);
                orderSummaryList.add(summaryOrder);
                orderIdSet.addAll(summaryOrder.orderItemIdList);
            }
            Map<String, DealerOrderItem__c> orderItemMap = new Map<String, DealerOrderItem__c>();
            for(DealerOrderItem__c dealerOrderItem :[
                SELECT 
                    DealerPurchaseOrderItem__r.DealerPurchaseOrder__c, 
                    DealerPurchaseOrderItem__c, 
                    FM_OrderNumber__c 
                FROM DealerOrderItem__c 
                WHERE DealerPurchaseOrderItem__c IN :orderIdSet
            ]) {
                orderItemMap.put(dealerOrderItem.DealerPurchaseOrderItem__r.DealerPurchaseOrder__c, dealerOrderItem);
                orderItemMap.put(dealerOrderItem.DealerPurchaseOrderItem__c, dealerOrderItem);
            }
            result.put('dealerOrderItemMap', orderItemMap);
            

            for(OrderSummary summaryOrder: orderSummaryList) {
                if(orderItemMap.containsKey(summaryOrder.poId))
                    summaryOrder.customerOrderSeq = orderItemMap.get(summaryOrder.poId).FM_OrderNumber__c;
            }
        }

        if(queryDNSPOMap != null) {
            String queryDNS = queryDNSPOMap.get('query');
            String totalQueryDNS = queryDNSPOMap.get('queryCount');
            
            System.debug('totalQueryDNS :: '+ totalQueryDNS);
            System.debug('queryDNS :: '+ queryDNS);
            
            result.put('queryDNS', queryDNS);

            Integer totalSizeDNS = Database.countQuery(totalQueryDNS);
            totalSize += totalSizeDNS;
            for(PurchaseOrder__c orderSObject : Database.query(queryDNS)) {
                orderSummaryList.add(new OrderSummary(orderSObject));
            }
        }
        orderSummaryList.sort();
        
        List<OrderSummary> recordListSet = new List<OrderSummary>();
        page.totalRecordSize = totalSize;
        // Stage Idx, Last Idx
        Integer startIdx = 0;
        Integer endIdx = 0;
        // 같은 경우 뒤로가기 또는 현재 페이지 클릭
        if(page.currentPage == nextPage) {
            startIdx = (page.currentPage * page.itemsPerPage);
            startIdx = (startIdx - page.itemsPerPage) + 1;
            endIdx = (nextPage*page.itemsPerPage);    
        } else {
            startIdx = (nextPage*page.itemsPerPage -page.itemsPerPage) +1;//(page.currentPage * page.itemsPerPage)+1;
            endIdx = (nextPage*page.itemsPerPage);    
        }
        for(Integer i=startIdx-1; i<orderSummaryList.size(); i++) {
            // 시작 데이터 Indx 부터 End Indx까지
            if(i < endIdx) {
                recordListSet.add(orderSummaryList[i]);
            } else {
                break;
            }
        }

        page.startIdx = startIdx;
        page.endIdx = endIdx;
        page.currentPage = nextPage;

        // result.put('query', query);
        result.put('orderSummaryList', orderSummaryList);
        result.put('recordListSet', recordListSet);
        result.put('page', page);

        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Class : OrderSummary
    * @ Description : OrderSummary Class
    */
    public class OrderSummary implements Comparable  {
        @AuraEnabled public String type          {get; set;}
        @AuraEnabled public String poId                 {get; set;} // DNS 구매 Id, 대리점 구매요청 Id
        @AuraEnabled public String poSeq                {get; set;} // DNS 구매 Seq, 대리점 구매요청 Seq
        @AuraEnabled public String customerOrderSeq     {get; set;} //대리점 주문번호
        @AuraEnabled public String customerOrerNumber   {get; set;} //고객용주문번호 CustomerPurchaseOrderNumber__c
        @AuraEnabled public String dealerName           {get; set;} 
        @AuraEnabled public String dealer               {get; set;} 
        @AuraEnabled public String customerName         {get; set;} //구매처 DNS OR 구매요청 대리점
        @AuraEnabled public Date orderDate              {get; set;}
        @AuraEnabled public DateTime createdDateTime    {get; set;}
        @AuraEnabled public Decimal totalItemCount      {get; set;} //품목수
        @AuraEnabled public Decimal totalItemAmount     {get; set;} //할인판매가의 총합
        @AuraEnabled public String currencyCode         {get; set;}
        @AuraEnabled public String status               {get; set;} //상태: 미출고, 부분출고, 출고완료
        @AuraEnabled public String statusLabel          {get; set;} //상태: 미출고, 부분출고, 출고완료
       
        @AuraEnabled public List<String> orderItemIdList{
            get {
                if(orderItemIdList == null) orderItemIdList = new List<String>();
                return orderItemIdList;
            } 
            set;
        }
        @AuraEnabled public List<OrderItem> itemList {
            get {
                if(itemList == null) itemList = new List<OrderItem>();
                return itemList;
            }
            set;
        }

        /*
        * @ 생성자 : OrderSummary
        * @ Description : DealerPurchaseOrder__c 데이터를 매핑
        */
        public OrderSummary() {}
        public OrderSummary(DealerPurchaseOrder__c poOrderSObject) {
            this.type                 = 'Dealer';
            this.poId                 = poOrderSObject.Id;
            this.poSeq                = poOrderSObject.OrderNumber__c;
            this.customerOrerNumber   = poOrderSObject.CustomerPurchaseOrderNumber__c;
            this.dealerName           = poOrderSObject.Dealer__r.Name;
            this.customerName         = poOrderSObject.FM_CustomerName__c;
            this.orderDate            = poOrderSObject.FM_OrderDate__c;
            this.status               = poOrderSObject.FM_OrderStatus__c;
            this.statusLabel          = poOrderSObject.FM_OrderStatusLabel__c;
            this.currencyCode         = poOrderSObject.CurrencyIsoCode;
            this.createdDateTime      = poOrderSObject.CreatedDate;
            this.totalItemCount       = 0;
            this.totalItemAmount      = 0;
            //Total 값 계산
            Integer totalItemCount = 0;
            for(DealerPurchaseOrderItem__c orderItemSObject : poOrderSObject.item__r) {
                this.totalItemAmount += orderItemSObject.FM_DiscountAmount__c; //Integer 로 형변환
                totalItemCount++;
                itemList.add(new OrderItem(orderItemSObject));
                orderItemIdList.add(orderItemSObject.Id);
            }
            this.totalItemCount = totalItemCount;

        }

        /*
        * @ 생성자 : OrderSummary
        * @ Description : PurchaseOrder__c 데이터를 매핑
        */
        public OrderSummary(PurchaseOrder__c dnsOrderSObject) {
            this.type                 = 'DNS';
            this.poId                 = dnsOrderSObject.Id;
            this.poSeq                = dnsOrderSObject.PartOrderNo__c;
            this.customerOrerNumber   = dnsOrderSObject.CustomerOrderNo__c;
            this.orderDate            = dnsOrderSObject.FM_OrderDate__c;
            this.totalItemCount       = dnsOrderSObject.TotalItems__c;
            this.totalItemAmount      = dnsOrderSObject.ItemsAmount__c;
            this.currencyCode         = dnsOrderSObject.CurrencyIsoCode;
            this.dealerName           = dnsOrderSObject.Buyer__r.Name;
            this.dealer               = dnsOrderSObject.Buyer__c;
            this.customerName         = dnsOrderSObject.Supplier__c;
            this.status               =	dnsOrderSObject.FM_OrderStatus__c;
            this.statusLabel          =	dnsOrderSObject.FM_OrderStatusLabel__c;
            this.createdDateTime      = dnsOrderSObject.CreatedDate;

            for(PurchaseOrderItems__c orderItemSObject : dnsOrderSObject.PurchaseOrderItems__r) {
                itemList.add(new OrderItem(orderItemSObject));
            }
        }

        public Integer compareTo(Object compareTo) {
            OrderSummary compareToEmp = (OrderSummary)compareTo;
            
            if (createdDateTime < compareToEmp.createdDateTime) return 1;
            if (createdDateTime > compareToEmp.createdDateTime) return -1;

            // 모든 값이 같다면 0 반환
            return 0;
        }
    }

    /*
    * @ Class : OrderItem
    * @ Description : OrderItem Class
    */
    public class OrderItem {
        @AuraEnabled public String  poId                 {get; set;} //주문Id
        @AuraEnabled public String  poSeq                {get; set;}
        @AuraEnabled public String  itemId               {get; set;}
        @AuraEnabled public String  itemSeq              {get; set;}
        @AuraEnabled public String  unit                 {get; set;}
        @AuraEnabled public String  replacingPart        {get; set;}
        @AuraEnabled public String  replacingPartName    {get; set;}
        @AuraEnabled public String  replacingPartDetails {get; set;}
        @AuraEnabled public Decimal quantity             {get; set;}
        @AuraEnabled public Decimal avaiableQuantity     {
            get{
                if(avaiableQuantity == null) avaiableQuantity = 0;
                return avaiableQuantity;
            } 
            set;
        } //가용재고
        @AuraEnabled public Decimal reservedQuantity     {
            get{
                if(reservedQuantity == null) reservedQuantity = 0;
                 return reservedQuantity;
            }
            set;
        } //예약수량
        @AuraEnabled public Decimal giQuantity           {
            get{
                if(giQuantity == null) giQuantity = 0;
                return giQuantity;
            } 
            set;
        }//출고량
        @AuraEnabled public Decimal currentStockQuantity {
            get{
                if(currentStockQuantity == null) currentStockQuantity = 0;
                return currentStockQuantity;
            } 
            set;
        } //현재고
        @AuraEnabled public Decimal pendingQuantity           {
            get{
                if(pendingQuantity == null) pendingQuantity = 0;
                return pendingQuantity;
            } 
            set;
        }//대리점간 거래 미결수량 , DNS 구매 대기 수량
        @AuraEnabled public Decimal confirmQuantity           {
            get{
                if(confirmQuantity == null) confirmQuantity = 0;
                return confirmQuantity;
            } 
            set;
        }//DNS 구매 확정 수량
        @AuraEnabled public String  currencyCode         {get; set;}
        @AuraEnabled public Decimal customerPrice        {get; set;} //Decimal?
        @AuraEnabled public Decimal discountPrice        {get; set;} //Decimal?
        @AuraEnabled public Decimal discountAmount       {get; set;} //Decimal?
        @AuraEnabled public Decimal discountRate         {get; set;}
        @AuraEnabled public String machineName           {get; set;}
        @AuraEnabled public String equipment             {get; set;}
        @AuraEnabled public String customerOrderItemId   {get; set;}
        @AuraEnabled public String customerOrderItemSeq  {get; set;}
        @AuraEnabled public String customerOrderId       {get; set;} //고객 주문Id
        @AuraEnabled public String customerOrderSeq      {get; set;} //고객 주문Seq
        @AuraEnabled public String dealer                {get; set;} //
        @AuraEnabled public String dealerName            {get; set;} //
        @AuraEnabled public String status                {get; set;}
        @AuraEnabled public String statusLabel           {get; set;}
        @AuraEnabled public String deleteYN              {get; set;} // Y/N
        @AuraEnabled public Boolean isOutOfStock = false; //현재 가용재고가 0 이하 일 경우 (결품수량)
        @AuraEnabled public Date expectedSupplyDate      {get; set;} //예상공급일
        @AuraEnabled public Date revisedSupplyDate       {get; set;} //변경공급 예정일	
        @AuraEnabled public Date giDate                  {get; set;} //출하일
        @AuraEnabled public String departureSite         {get; set;} //발송지점
        	

        /*
        * @ 생성자 : OrderItem
        * @ Description : DealerPurchaseOrderItem__c 데이터를 매핑
        */
        public OrderItem(){}
        public OrderItem(DealerPurchaseOrderItem__c orderItem){
            this.itemSeq = orderItem.OrderItemNumber__c;
            this.replacingPartName = orderItem.ReplacingPart__r.Name;
            this.replacingPartDetails = orderItem.ReplacingPart__r.FM_MaterialDetails__c;
            this.quantity = orderItem.Quantity__c;
            this.unit = orderItem.FM_Unit__c;
            this.giQuantity = orderItem.GICompletedQuantity__c;
            this.pendingQuantity = orderItem.FM_PendingQuantity__c;
            this.discountAmount = orderItem.FM_DiscountAmount__c;
            this.currencyCode = orderItem.CurrencyIsoCode;
            this.status = orderItem.Status__c;
            this.statusLabel = String.valueOf(orderItem.get('statusLabel'));
        }

        /*
        * @ 생성자 : OrderItem
        * @ Description : PurchaseOrderItems__c 데이터를 매핑
        */
        public OrderItem(PurchaseOrderItems__c orderItem){
            this.itemSeq              = orderItem.ItemNo__c;
            this.replacingPartName    = orderItem.SupplyPartNo__c; // TODO: Prdocut 정보로 변경 가능
            this.replacingPartDetails = orderItem.PartName__c;
            this.quantity             = orderItem.Quantity__c; //주문수량
            this.unit                 = orderItem.Unit__c;
            this.giQuantity           = orderItem.CompletedQty__c; //완료 수량
            this.pendingQuantity      = orderItem.PenddingQty__c; //대기 수량
            this.discountAmount       = orderItem.PartAmount__c;
            this.currencyCode         = orderItem.CurrencyIsoCode;
            this.confirmQuantity      = orderItem.ConfirmedQty__c; //확정 수량
            this.expectedSupplyDate   = orderItem.ExpectedSupplyDate__c; //예상공급일	
            this.revisedSupplyDate    = orderItem.RevisedSupplyDate__c; //변경공급 예정일	
            this.giDate               = orderItem.ShipmentDate__c; //출고일	
            this.departureSite        = orderItem.DepartureSite__c;//발송지점
            this.statusLabel          = orderItem.ReceivedStatus__c;  //상태?
        }

    }

    /*
    * @ Class : StatusInfo
    * @ Description : StatusInfo Class
    */
    public enum StatusCode { SUCCESS, ERROR }

    public class StatusInfo {
        @AuraEnabled public Integer code      {get; set;}
        @AuraEnabled public String msg        {get; set;}
        @AuraEnabled public StatusCode status {get; set;}

        /*
        * @ 생성자 : StatusInfo
        * @ Description : 상태정보 반환
        */
        public StatusInfo() {
            code = 200;
            status = StatusCode.SUCCESS;
        }

        /*
        * @ Method : setCode
        * @ Description : 상태 코드 반환
        */
        public void setCode(Integer code) {
            this.code = code;
        }

        /*
        * @ Method : setMessage
        * @ Description : 상태 메세지 반환
        */
        public void setMessage(String msg) {
            this.msg = msg;
        }

        /*
        * @ Method : setError
        * @ Description : 에레 정보 반환
        */
        public void setError(String msg, Integer code) {
            this.status = StatusCode.ERROR;
            this.code = (code == null) ? 400 : code;
            setMessage(msg);
        }

    }

    public class CustomException extends Exception {}

}