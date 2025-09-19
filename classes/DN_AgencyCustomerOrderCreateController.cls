/** 
 * @Class :  DN_AgencyCustomerOrderCreateController
 * 
 * @Test: DN_AgencyCustomerOrderCreateCon_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2024. 12. 26. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-26 | Hyunwook Jin   | 최초작성 (고객 주문 생성 및 수정, 상세페이지)
 */ 
public with sharing class DN_AgencyCustomerOrderCreateController {
    public DN_AgencyCustomerOrderCreateController() {}

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
    * @ Method : init
    * @ Description : Id 기준으로 대리점 주문 OR 대리점 견젹서 정보
    */
    @AuraEnabled
    public static Map<String,Object> init(String sourceId){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();

        try {
            Order orderWrapper;

            orderWrapper = new Order();
            if(String.isNotBlank(sourceId)) {
                String sObjectTypeName = Id.valueOf(sourceId).getSobjectType().getDescribe().getLocalName();

                switch on sObjectTypeName {
                    when 'DealerOrder__c' {
                        orderWrapper = new Order(sourceId);
                        if(String.isNotBlank(orderWrapper.customer)) {
                            result.put('customerInfo', [SELECT Id, CustomerCode__c, DiscountRate__c FROM DealerCustomer__c WHERE Id = :orderWrapper.customer]);
                        }
                    }
                    when 'DealerQuote__c' {
                        orderWrapper = new Order(new DN_DealerPortalQuoteCreateController.Quote(sourceId));
                    }
                    when else {
                        throw new CustomException('Does Not use sourceId');
                    }
                }
            }

            result.put('order', orderWrapper);
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : doSimulation
    * @ Description : 부품 리스트의 부품별 가격정보 조회
    */
    @AuraEnabled
    public static Map<String,Object> doSimulation(List<String> partCodeList){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        System.debug(partCodeList + ' ::: partCodeList');
        try {
            String agencyId = currentUser.getAgencyId();

            DN_SimulationManager simulator = new DN_SimulationManager(
                DN_SimulationManager.Type.CUSTOMERORDER
                , partCodeList
                , agencyId
            );
            // result.put('partDetailsMap' ,simulator.simulation());
            result.put('partDetailsMap' ,simulator.simulation(currentUser, null));
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug(e.getStackTraceString());
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, 500);
           
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : createOrder
    * @ Description : 대리점 주문 생성
    */
    @AuraEnabled
    public static Map<String,Object> createOrder(Order order){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        
        Savepoint sp = Database.setSavepoint(); 
        try {
            String agencyId = currentUser.getAgencyId();
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();
            String customerCode = currentUser.getAgencyCustomerCode();
            
            DealerOrder__c orderSObject = order.convertToSObject();

            if(orderSObject.CustomerShipTo__c != null) {
                SchemaInfo schema = new SchemaInfo();
                Map<String, UserRecordAccess> recordAccess = schema.getUserAccesses(UserInfo.getUserId(), new Set<String>{orderSObject.CustomerShipTo__c});
                if(recordAccess.containsKey(orderSObject.CustomerShipTo__c) && !recordAccess.get(orderSObject.CustomerShipTo__c).HasReadAccess) {
                    //타대리점 승인으로 생성시 CustomerShipToId 값 권한 문제로 OneTimeCustomer Shipto 코드로 강제적으로 변경
                    orderSObject.CustomerShipTo__c = null;
                    orderSObject.CustomerShipToCode__c = '9999999999';
                    
                }
            }
            insert orderSObject;
            
            if(orderSObject.Quote__c != null) {
                update new DealerQuote__c(Id = orderSObject.Quote__c, Status__c = 'C');
            }

            System.debug('orderId :: '+ orderSObject.Id);

            List<DealerOrderItem__c> orderItemSObjectList = new List<DealerOrderItem__c>();
            Map<String, String> productIdCodeMap = new Map<String, String>(); //부품Id별 ProductCode
            for(OrderItem orderItem : order.itemList) {
                orderItemSObjectList.add(orderItem.convertToSObject(orderSObject.Id));
                productIdCodeMap.put(orderItem.replacingPart, orderItem.replacingPartName);
            }

            //공급품목의 재고 변환
            Map<String, DealerStock__c> stockMap = DN_DealerStockManager.getAvailableStockMap(agencyId, salesOranization, distributionChannel, division, productIdCodeMap.keySet());
            for(DealerOrderItem__c orderItemSObject : orderItemSObjectList) {
                DealerStock__c stock;
                if(stockMap.containsKey(orderItemSObject.ReplacingPart__c)) {
                    stock = stockMap.get(orderItemSObject.ReplacingPart__c);
                    //최초 Insert 시 대리점 공급율 계산
                    orderItemSObject.AvailableQuantity__c = stock.AvailableQuantity__c;
                    orderItemSObject.CurrentStockQuantity__c = stock.CurrentStockQuantity__c;

                    stock.OrderRequiredQuantity__c += orderItemSObject.Quantity__c;
                    //가용재고 = 현재고 - 주문서 예약 - 서비스 오더 예약 - Block
                    stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                }else {
                    stock = new DealerStock__c(
                        Dealer__c = agencyId,
                        Part__c = orderItemSObject.ReplacingPart__c,
                        SalesOrganization__c = salesOranization,
                        DistributionChannel__c = distributionChannel,
                        Division__c = division,
                        AvailableQuantity__c = 0,
                        CurrentStockQuantity__c = 0,
                        OrderRequiredQuantity__c = orderItemSObject.Quantity__c,
                        WarrantyRequiredQuantity__c = 0,
                        BlockQuantity__c = 0
                    );
                    //최초 Insert 시 대리점 공급율 계산
                    orderItemSObject.AvailableQuantity__c = 0;
                    orderItemSObject.CurrentStockQuantity__c = 0;

                    stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                    stock.ExternalKey__c = salesOranization+'-'+distributionChannel+'-'+division+'-'+customerCode+'-'+productIdCodeMap.get(orderItemSObject.ReplacingPart__c);
                    stockMap.put(orderItemSObject.ReplacingPart__c, stock);
                }             
            }

            if(stockMap.size() > 0) upsert stockMap.values() ExternalKey__c;
            if(orderItemSObjectList.size() > 0) insert orderItemSObjectList;

            result.put('orderId', orderSObject.Id);

        } catch (Exception e) {
            Database.rollback(sp);
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : updateOrder
    * @ Description : 대리점 주문 업데이트
    */
    @AuraEnabled
    public static Map<String,Object> updateOrder(Order order, Boolean isOnlyItemUpdate){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        Savepoint sp = Database.setSavepoint(); 
        try {
            String agencyId = currentUser.getAgencyId();
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();
            String customerCode = currentUser.getAgencyCustomerCode();
            
            System.debug(JSON.serializePretty(order)+ ' ::::: Order ::::');
            DealerOrder__c orderSObject = order.convertToSObject();
            if(isOnlyItemUpdate == null || isOnlyItemUpdate == false) {
                update orderSObject;
            }

            System.debug('orderId :: '+ orderSObject.Id);

            List<DealerOrderItem__c> orderItemSObjectList = new List<DealerOrderItem__c>();
            Set<String> beforeUpdateOrderItem = new Set<String>();
            // Set<String> partIdList = new Set<String>();
            Map<String,String> productIdCodeMap = new Map<String,String>(); // Product Id별 ProductCode Mapping
            for(OrderItem orderItem : order.itemList) {
                orderItemSObjectList.add(orderItem.convertToSObject());
                // partIdList.add(orderItem.replacingPart);
                productIdCodeMap.put(orderItem.replacingPart, orderItem.replacingPartName);
                System.debug('orderItem.itemId :: '+orderItem.itemId);
                beforeUpdateOrderItem.add(orderItem.itemId);
            }

            Map<Id, DealerOrderItem__c> beforeUpdateOrderItemMap = new Map<Id, DealerOrderItem__c>([
                SELECT Id, Part__c, Part__r.Name, Quantity__c
                FROM DealerOrderItem__c
                WHERE Id IN :beforeUpdateOrderItem
            ]);

            //공급품목의 재고 변환
            Map<String, DealerStock__c> stockMap = DN_DealerStockManager.getAvailableStockMap(agencyId, salesOranization, distributionChannel, division, productIdCodeMap.keySet());

            for(DealerOrderItem__c orderItemSObject : orderItemSObjectList) {
                DealerStock__c stock;
                if(stockMap.containsKey(orderItemSObject.ReplacingPart__c)) {
                    stock = stockMap.get(orderItemSObject.ReplacingPart__c);
                    
                    DealerOrderItem__c beforeOrderItem = beforeUpdateOrderItemMap.get(orderItemSObject.Id);
                    stock.OrderRequiredQuantity__c -= beforeOrderItem.Quantity__c;

                    stock.OrderRequiredQuantity__c += orderItemSObject.Quantity__c;
                    //가용재고 = 현재고 - 주문서 예약 - 서비스 오더 예약 - Block
                    stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                }else {
                    stock = new DealerStock__c(
                        Dealer__c = agencyId,
                        Part__c = orderItemSObject.ReplacingPart__c,
                        SalesOrganization__c = salesOranization,
                        DistributionChannel__c = distributionChannel,
                        Division__c = division,
                        AvailableQuantity__c = 0,
                        CurrentStockQuantity__c = 0,
                        OrderRequiredQuantity__c = orderItemSObject.Quantity__c,
                        WarrantyRequiredQuantity__c = 0,
                        BlockQuantity__c = 0
                    );
                    stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                    stock.ExternalKey__c = salesOranization+'-'+distributionChannel+'-'+division+'-'+customerCode+'-'+productIdCodeMap.get(orderItemSObject.ReplacingPart__c);
                    stockMap.put(orderItemSObject.ReplacingPart__c, stock);
                }
                
            }

            if(stockMap.size() > 0) {
                upsert stockMap.values() ExternalKey__c;
                update orderItemSObjectList;
                System.debug('update :: ');
                System.debug(JSON.serializePretty(orderItemSObjectList));
            }

            result.put('orderId', orderSObject.Id);

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getStackTraceString());
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : deleteOrderItems
    * @ Description : 대리점 주문 아이템 목록 삭제
    */
    @AuraEnabled
    public static Map<String,Object> deleteOrderItems(List<OrderItem> orderItems){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        Savepoint sp = Database.setSavepoint(); 
        try {
            String agencyId = currentUser.getAgencyId();
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();

            String orderId;
            Set<String> partIdList = new Set<String>();
            Set<String> orderItemIdList = new Set<String>();
            for(OrderItem orderItem : orderItems) {
                partIdList.add(orderItem.replacingPart);
                if(orderItem.itemId != null)orderItemIdList.add(orderItem.itemId);
            }
            List<DealerOrderItem__c> updateDeletedItems = new List<DealerOrderItem__c>();

            String orderItemId;
            Map<String, DealerStock__c> stockMap = DN_DealerStockManager.getAvailableStockMap(agencyId, salesOranization, distributionChannel, division, partIdList);
            for(OrderItem orderItem : orderItems) {
                if(stockMap.containsKey(orderItem.replacingPart)) {
                    DealerStock__c stock =  stockMap.get(orderItem.replacingPart);
                    stock.OrderRequiredQuantity__c -= orderItem.quantity;
                    //가용재고
                    stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);

                    updateDeletedItems.add(new DealerOrderItem__c (
                        Delete__c = 'Y',
                        Id = orderItem.itemId
                    ));

                    orderId = orderItem.orderId;
                    orderItemId = orderItem.itemId;
                }
            }
            DealerOrder__c order;
            if(stockMap.size() > 0) {
                upsert stockMap.values() ExternalKey__c;
                update updateDeletedItems;

                
                if(String.isNotBlank(orderId))
                    order = [SELECT Id, Delete__c FROM DealerOrder__c WHERE Id = :orderId];
                else {
                    //타대리점 승인 요청건들은 해당 고객 주문서 Id 가 없음.
                    order = [SELECT Id, Delete__c FROM DealerOrder__c WHERE Id IN  (SELECT Order__c FROM DealerOrderItem__c WHERE Id = :orderItemId)];
                }
            }

            result.put('order', order);

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getStackTraceString());
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : deleteOrder
    * @ Description : 대리점 주문 삭제
    */
    public static Boolean deleteOrder(String recordId) {
        Boolean isDelete = false;

        String agencyId = currentUser.getAgencyId();
        String salesOranization = currentUser.getSalesOranization();
        String distributionChannel = currentUser.getDistributionChannel();
        String division = currentUser.getDivision();

        DealerOrder__c orderSObject = [
                SELECT
                    Id
                    , OrderNumber__c
                    , OrderType__c
                    , toLabel(OrderType__c) orderTypeLabel
                    , FM_OrderDate__c
                    , SalesOrganization__c
                    , DistributionChannel__c
                    , Division__c
                    , CustomerPurchaseOrderNumber__c
                    , Dealer__c
                    , Dealer__r.Name
                    , Customer__c
                    , FM_CustomerName__c
                    , CustomerShipToCode__c
                    , BulkShipping__c
                    , Address__Street__s
                    , Address__PostalCode__s
                    , Address__CountryCode__s
                    , RoadAddr__c
                    , DetailInfo__c
                    , Representative__c
                    , Phone__c
                    , ShippingType__c
                    , ShippingCompany__c
                    , Invoice__c
                    , Memo__c
                    , Status__c
                    , Priority__c
                    , CustomerShipTo__c
                    , Quote__c
                    , CustomerCode__c
                    , FM_ShipToName__c
                    , (
                        SELECT
                            Id
                            , Order__c
                            , FM_OrderNumber__c
                            , OrderItemNumber__c
                            , Part__c
                            , Part__r.Name
                            , Part__r.FM_MaterialDetails__c
                            , ReplacingPart__c
                            , ReplacingPart__r.Name
                            , ReplacingPart__r.FM_MaterialDetails__c
                            , Quantity__c
                            , FM_Unit__c
                            , AvailableQuantity__c
                            , CurrentStockQuantity__c
                            , SaleQuantityUnit__c
                            , CustomerPrice__c
                            , DiscountPrice__c
                            // , DiscountAmount__c
                            , DiscountRate__c
                            , FM_DiscountAmount__c
                            , DealerPurchaseOrderItem__c
                            , FM_DealerPurchaseOrder__c
                            , GICompletedQuantity__c
                            , FM_PendingQuantity__c
                            , FM_GICompletedDate__c
                            , FM_DeliveryStatus__c
                            , Equipment__c
                            , MachineName__c
                            , CurrencyIsoCode
                        FROM item__r
                        WHERE Delete__c != 'Y'
                    )
                FROM DealerOrder__c
                WHERE Id = :recordId
                LIMIT 1
                FOR UPDATE
        ];
        
        Set<String> partIdList = new Set<String>();
        for(DealerOrderItem__c orderItemSObject : orderSObject.item__r) {
            partIdList.add(orderItemSObject.ReplacingPart__c);
        }

        List<DealerOrderItem__c> updateDeletedItems = new List<DealerOrderItem__c>();
        //공급품목의 재고 변환
        Map<String, DealerStock__c> stockMap = DN_DealerStockManager.getAvailableStockMap(agencyId, salesOranization, distributionChannel, division, partIdList);
        for(DealerOrderItem__c orderItemSObject : orderSObject.item__r) {
            if(stockMap.containsKey(orderItemSObject.ReplacingPart__c)) {
                DealerStock__c stock =  stockMap.get(orderItemSObject.ReplacingPart__c);
                stock.OrderRequiredQuantity__c -= orderItemSObject.Quantity__c;
                //가용재고
                stock.AvailableQuantity__c = DN_DealerStockManager.getAvailableStock(stock);
                updateDeletedItems.add(new DealerOrderItem__c (
                        Delete__c = 'Y',
                        Id = orderItemSObject.Id
                ));
            }
        }
        if(stockMap.size() > 0) {
            upsert stockMap.values() ExternalKey__c;
            update updateDeletedItems;
        }

        isDelete = true;
        return isDelete;
    }

    
/*******************************************  고객 주문 상세 화면 ********************************************************/
    /*
    * @ Method : detailInit
    * @ Description : 대리점 주문 아이템 상세 정보
    */
    @AuraEnabled
    public static Map<String,Object> detailInit(String recordId){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            String agencyId = currentUser.getAgencyId();
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();

            Order orderWrapper = new Order(recordId);

            Set<String> partIdList = new Set<String>();
            for(OrderItem orderItemWrapper : orderWrapper.itemList) {
                partIdList.add(orderItemWrapper.replacingPart);
            }

            //공급품목의 재고 변환
            Map<String, DealerStock__c> stockMap = DN_DealerStockManager.getAvailableStockMap(agencyId, salesOranization, distributionChannel, division, partIdList);
            //조회 화면으로 단순 재고 조회
            for(OrderItem orderItemWrapper : orderWrapper.itemList) {
                if(stockMap.containsKey(orderItemWrapper.replacingPart)) {
                    DealerStock__c stock = stockMap.get(orderItemWrapper.replacingPart);
                    orderItemWrapper.avaiableQuantity = stock.AvailableQuantity__c;
                    orderItemWrapper.reservedQuantity = stock.OrderRequiredQuantity__c + stock.WarrantyRequiredQuantity__c;
                    orderItemWrapper.isOutOfStock = stock.AvailableQuantity__c <= 0;
                    //TODO: giQuantity 출고이력의 합 x
                }
            }
            System.debug('orderWrapper.dealer :: ');
            System.debug(orderWrapper.dealer);
            //Dealer 정보는 Account 정보로
            // 사업자 번호, 이름, 대표자, 주소, 업태, 종목
            Account orderDealer = [ 
              SELECT
                Id, Name,
                Representative__c,
                BusinessNumber__c,
                TypeOfBusiness__c,      //업종
                TypeOfIndustry__c       //업태
              FROM Account WHERE Id = :orderWrapper.dealer
              Limit 1
            ];

            result.put('order', orderWrapper);
            result.put('orderDealer', orderDealer);
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

/*******************************************  고객 주문 ListView 화면 ********************************************************/
    /*
    * @ Method : getOrderSummaryQuery
    * @ Description : 대리점 주문 및 주문 아이템 쿼리
    */
    @AuraEnabled
    public static Map<String,String> getOrderSummaryQuery(
        String seq,
        String orderType,
        List<String> partNameList,
        String customerOrerNumber,
        Date orderDateStart, 
        Date orderDateEnd,
        String customerName,
        String customerId,
        String status,
        String dealerPoNo
    ){
        List<String> fields = new List<String> {
            'Id'
            ,'FM_Representative__c'
            ,'OrderNumber__c'
            ,'OrderType__c'
            , 'Dealer__r.FM_Address__c'
            ,'toLabel(OrderType__c) orderTypeLabel'
            ,'FM_OrderDate__c'
            ,'FM_OrderStatus__c'
            ,'FM_OrderStatusLabel__c'
            ,'FM_LastModifiedDate__c'
            ,'CustomerPurchaseOrderNumber__c'
            ,'Customer__c'
            ,'CustomerCode__c'
            ,'FM_CustomerName__c'
            ,'Status__c'
            ,'toLabel(Priority__c)'
            ,'CurrencyIsoCode'
            ,'TotalItemReturnQtyCount__c'
        };

        String querySelect = ' SELECT ';
                     
        //주문 Item 부품 정보로 조회
        String queryItem =  '  SELECT '
                            +' Id '
                            +' , Order__r.TotalItemQtyCount__c'
                            +' , Order__r.TotalItemReturnQtyCount__c'
                            +' , TotalReturnQtyCount__c'
                            +' , Order__c '
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
                            +' , AvailableQuantity__c '
                            +' , CurrentStockQuantity__c '
                            +' , SaleQuantityUnit__c '
                            +' , CustomerPrice__c '
                            +' , DiscountPrice__c '
                            +' , DiscountRate__c '
                            +' , FM_DiscountAmount__c '
                            +' , DealerPurchaseOrderItem__c '
                            +' , FM_DealerPurchaseOrder__c '
                            +' , GICompletedQuantity__c '
                            +' , FM_PendingQuantity__c '
                            +' , FM_GICompletedDate__c '
                            +' , FM_DeliveryStatus__c '
                            +' , Equipment__c '
                            +' , MachineName__c '
                            +' , CurrencyIsoCode '
                            +' FROM DealerOrderItem__c WHERE Id != null and Delete__c != \'Y\' ';

        String orderItemQuery = '';
        if(partNameList?.size() > 0) {
            List<String> partNameWhereClauseList = new List<String>();
            for(String partName : partNameList) {
                partNameWhereClauseList.add(' ReplacingPart__c  = \''+partName+'\' ');
            }
            orderItemQuery =  ' SELECT Order__c FROM DealerOrderItem__c  WHERE ('+ String.join(partNameWhereClauseList, 'OR') +')';
        }

        // fields.add('(' + queryItem +')');

        String query = querySelect + String.join(fields, ',');
        String queryFrom =' FROM DealerOrder__c '
                         +' WHERE Id != null and Delete__c != \'Y\' ';
        String additionalWhereClause = '';

        if(String.isNotBlank(seq))
            additionalWhereClause += ' AND OrderNumber__c like \'%' + seq + '%\'';
        if(String.isNotBlank(orderType) && !'All'.equals(orderType))
            additionalWhereClause += ' AND OrderType__c = :orderType ';
        if(String.isNotBlank(customerOrerNumber))
            additionalWhereClause += ' AND CustomerPurchaseOrderNumber__c like \'%'+ customerOrerNumber +'%\'';
        if(String.isNotBlank(customerName))
            additionalWhereClause += ' AND FM_CustomerName__c like \'%' + customerName + '%\'';
        if(String.isNotBlank(customerId)) 
            additionalWhereClause += ' AND Customer__c = :customerId ';
        // if(String.isNotBlank(dealerPoNo))
                    
        if(orderDateStart != null && orderDateEnd != null) 
            additionalWhereClause += ' AND ( FM_OrderDate__c >= :orderDateStart AND FM_OrderDate__c <= :orderDateEnd ) ';

        if(String.isNotBlank(orderItemQuery))
            additionalWhereClause += ' AND Id IN ('+orderItemQuery+')';

        //Order 에 대리점간거래로 생성된 케이스에서 Customer.SourceAccount 고객한테 Read/Write 권한을 부여하여 다른 고객의 주문을 볼 수 있음.
        //조건문에 Dealer 와 현재 사용자 Account 와 같은 주문건만 조회
        if(String.isNotBlank(currentUser.getAgencyId())) // if(!currentUser.getIsAdmin()) < Admin 도 볼 수 있게끔 변경
            additionalWhereClause  += ' AND Dealer__c = \''+currentUser.getAgencyId()+'\'';
        
        
        //납입지연은 인도법인에서만
        switch on status {
            when  'N', 'P', 'C'{
                //미출고, 부분출고, 출고완료시
                additionalWhereClause += ' AND FM_OrderStatus__c = :status ';
            }
            when 'R' {
                additionalWhereClause += ' AND 	TotalItemReturnQtyCount__c > 0 ';
            }
        }
        return new Map<String,String>{
            'query' => querySelect + String.join(fields, ',') + queryFrom + additionalWhereClause + ' ORDER BY FM_OrderDate__c desc, OrderNumber__c desc LIMIT 30000 ',
            'queryCount' => querySelect + ' count() ' + queryFrom + additionalWhereClause + ' LIMIT 20000 ',
            'queryItem' => queryItem
        };
    }

    /*
    * @ Method : getOrderSummaryList
    * @ Description : 고객 주문서 관리 조회
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
                                                         String dealerPoNo,
                                                         DN_DealerPortalDisplayController.PageReturn page,
                                                         Integer nextPage,
                                                         Object lastKeyValue
    ){
        System.debug('orderDateStart : '+ orderDateStart);
        System.debug('orderDateEnd : '+ orderDateEnd);
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
        Map<String,String> queryMap = getOrderSummaryQuery(seq, orderType, partNameList, customerOrerNumber, orderDateStart, orderDateEnd, customerName, customerId, status, dealerPoNo);
        String query = queryMap.get('query');
        String totalQuery = queryMap.get('queryCount');
        String itemQuery = queryMap.get('queryItem');
        
        System.debug('page : ' +JSON.serializePretty(page));

        System.debug('totalQuery :: '+ totalQuery);
        Integer totalSize = Database.countQuery(totalQuery);
        page.totalRecordSize = totalSize;
        result.put('totalQuery', totalQuery);

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

        System.debug('query :: '+ query);
        List<DealerOrder__c> rawOrderList = Database.query(query);
        Map<String, OrderSummary> recordMapSet = new Map<String, OrderSummary>();
        for(Integer i=startIdx-1; i<rawOrderList.size(); i++) {
            // 시작 데이터 Indx 부터 End Indx까지
            if(i < endIdx) {
                // recordListSet.add(orderSummaryList[i]);
                OrderSummary orderSummary = new OrderSummary(rawOrderList[i]);
                recordMapSet.put(orderSummary.id, orderSummary);
            } else {
                break;
            }
        }

        if(recordMapSet.size() > 0) {
            Set<String> orderIdSet = recordMapSet.keySet();
            itemQuery += ' AND Order__c IN :orderIdSet';
            itemQuery += ' ORDER BY OrderItemNumber__c ';
        
            //Total 값 계산
            for(DealerOrderItem__c orderItemSObject : Database.query(itemQuery)) {
                OrderSummary viewSummary = recordMapSet.get(orderItemSObject.Order__c);
                viewSummary.totalItemAmount += Integer.valueOf(orderItemSObject.FM_DiscountAmount__c); //Integer 로 형변환
                viewSummary.totalItemCount += 1;
                viewSummary.dealerPoNo = orderItemSObject.FM_DealerPurchaseOrder__c;
                viewSummary.totalOrderQuantity += orderItemSObject.Quantity__c;
                viewSummary.totalGICompletedQuantity += orderItemSObject.GICompletedQuantity__c;
                viewSummary.itemList.add(new OrderItem(orderItemSObject));
            }
        }

        page.startIdx = startIdx;
        page.endIdx = endIdx;
        page.currentPage = nextPage;

        result.put('query', query);
        // result.put('orderSummaryList', orderSummaryList);
        result.put('recordListSet', recordMapSet.values());
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
    * @ Method : getReturnListFromOrderSummary
    * @ Description : 고객주문서 관리에서 반품 목록 조회
    */
    @AuraEnabled
    public static Map<String,Object> getReturnListFromOrderSummary(String orderId){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            List<DN_AgencyCustomerReturnController.ReturnOrderItem> returnOrderList = new List<DN_AgencyCustomerReturnController.ReturnOrderItem>();
            // DN_AgencyCustomerReturnController.searchReturnOrder 참조 (생성자 공통으로 사용해서)
            for(DealerReturnOrderItem__c returnSObject : [    
                SELECT 
                    Id,
                    SalesOrganization__c ,
                    DistributionChannel__c ,
                    Division__c ,
                    ReturnOrderNumber__c ,
                    ReturnOrderItemNumber__c ,
                    OrderItem__r.Order__r.Customer__c ,
                    OrderItem__r.Order__r.CustomerCode__c ,
                    OrderItem__r.Order__r.FM_CustomerName__c ,
                    OrderItem__c ,
                    OrderItem__r.OrderItemNumber__c ,
                    FM_Order__c ,
                    OrderItem__r.Order__c ,
                    OrderItem__r.ReplacingPart__c ,
                    OrderItem__r.ReplacingPart__r.Name ,
                    OrderItem__r.ReplacingPart__r.FM_MaterialDetails__c ,
                    OrderItem__r.FM_Unit__c ,
                    OrderItem__r.Quantity__c ,
                    ReturnQuantity__c ,
                    Reason1__c ,
                    toLabel(Reason1__c) reason1Label , 
                    Reason2__c ,
                    FM_ReturnDate__c, 
                    FM_ReturnNumber__c, 
                    Note__c 
                 FROM DealerReturnOrderItem__c 
                 WHERE OrderItem__c IN ( SELECT Id FROM DealerOrderItem__c WHERE Order__c = :orderId)
                    AND Delete__c != 'Y'
            ]) {
                returnOrderList.add(new DN_AgencyCustomerReturnController.ReturnOrderItem(returnSObject));
            }

            result.put('returnOrderList', returnOrderList);
        
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
    * @ Method : getInventoryStatusList
    * @ Description : 고객주문서 관리 > 주문서 상태 > 재고 현황
    */
    @AuraEnabled
    public static Map<String,Object> getInventoryStatusList(String ordeItemId){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            String agencyId;
            String salesOranization;
            String distributionChannel;
            String division;

            Set<String> partIdList = new Set<String>();
            for(DealerOrderItem__c orderItem : [
                SELECT ReplacingPart__c, Order__r.SalesOrganization__c, Order__r.DistributionChannel__c, Order__r.Division__c, Order__r.Dealer__c
                FROM DealerOrderItem__c
                WHERE Id = :ordeItemId AND Delete__c != 'Y' 
            ]) {
                partIdList.add(orderItem.ReplacingPart__c);
                agencyId = orderItem.Order__r.Dealer__c;
                salesOranization = orderItem.Order__r.SalesOrganization__c;
                distributionChannel = orderItem.Order__r.DistributionChannel__c;
                division = orderItem.Order__r.Division__c;
            }
            System.debug('key : '+salesOranization+'_'+distributionChannel+'_'+division);
            Map<String,DealerStock__c> stockMap = DN_DealerStockManager.getAvailableStockMap(agencyId, salesOranization, distributionChannel, division, partIdList);
            System.debug('stockMap : '+JSON.serialize(stockMap));
            List<OrderItem> orderItemList = new List<OrderItem>();
            //현재는 SalesOrder TODO : 무상부품 출고 추가시 ServiceOrder 도 추가
            for(DealerOrderItem__c orderItemSObject : [
                SELECT 
                       Id,
                       FM_OrderDate__c,
                       FM_OrderNumber__c,
                       OrderItemNumber__c,
                       Quantity__c,
                       GICompletedQuantity__c,
                       ReplacingPart__c, 
                       ReplacingPart__r.ProductCode
                FROM DealerOrderItem__c
                WHERE ReplacingPart__c IN :partIdList AND Delete__c != 'Y' AND FM_PendingQuantity__c > 0
                ORDER BY CreatedDate desc
            ]) {
                DealerStock__c stock = stockMap.get(orderItemSObject.ReplacingPart__c);
                if(stock != null) {
                    OrderItem orderItem = new OrderItem();
                    //stock.CurrentStockQuantity__c + stock.OrderRequiredQuantity__c + stock.WarrantyRequiredQuantity__c + stock.BlockQuantity__c
                    orderItem.itemId                    = orderItemSObject.Id;
                    orderItem.orderSeq                  = orderItemSObject.FM_OrderNumber__c;
                    orderItem.orderDate                 = orderItemSObject.FM_OrderDate__c;
                    orderItem.replacingPart             = orderItemSObject.ReplacingPart__c;
                    orderItem.replacingPartName         = orderItemSObject.ReplacingPart__r.ProductCode;
                    orderItem.avaiableQuantity          = stock.AvailableQuantity__c;
                    orderItem.reservedQuantity          = orderItemSObject.Quantity__c - orderItemSObject.GICompletedQuantity__c; //예약수량
                    orderItem.currentStockQuantity      = orderItem.avaiableQuantity + orderItem.reservedQuantity;
                    stock.AvailableQuantity__c          = orderItem.currentStockQuantity;
                    orderItem.blockQuantity             = stock.BlockQuantity__c;
                    orderItemList.add(orderItem);
                }
            }

            result.put('orderItemList', orderItemList);
        
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }


/*******************************************  고객 주문 관련 Flow 화면 ********************************************************/
    /*
    * @ Method : deleteOrder
    * @ Description : 고객 주문 관련 Flow에서 주문 삭제
    */
    @InvocableMethod(label='Delete Delaer Order' description='Update deleted status' category='Dealer')
    public static List<String> deleteOrder(List<String> recordIds) {
       Boolean isDelete = DN_AgencyCustomerOrderCreateController.deleteOrder(recordIds[0]);

       if(!isDelete) throw new CustomException('Update Status deleted  DML Error');

       return recordIds;
    }

    /*
    * @ Class : OrderSummary
    * @ Description : OrderSummary Class
    */
    public class OrderSummary {
        @AuraEnabled public String id                   {get; set;}
        @AuraEnabled public String seq                  {get; set;} //주문번호
        @AuraEnabled public String customerOrerNumber   {get; set;} //고객용주문번호 CustomerPurchaseOrderNumber__c
        @AuraEnabled public String orderType            {get; set;}
        @AuraEnabled public String customerName         {get; set;} //DealerCustomer__r.Name
        @AuraEnabled public Date orderDate              {get; set;}
        @AuraEnabled public Date lastModifiedDate       {get; set;}
        @AuraEnabled public Integer totalItemCount      {get; set;}
        @AuraEnabled public Integer totalItemAmount     {get; set;} //할인판매가의 총합
        @AuraEnabled public String currencyCode         {get; set;}
        @AuraEnabled public String status               {get; set;} //
        @AuraEnabled public String statusLabel          {get; set;} //미출고, 부분출고, 출고완료, 반품, 납입지연
        @AuraEnabled public String priority             {get; set;}
        @AuraEnabled public String returnOrder          {get; set;} //?
        @AuraEnabled public List<String> partNameList   {get; set;}
        @AuraEnabled public String dealerPoNo           {get; set;}//대리점간 거래 번호
        @AuraEnabled public Decimal totalOrderQuantity {
            get {
                if(totalOrderQuantity == null) totalOrderQuantity =  0;
                return totalOrderQuantity;
            } 
            set;
        }//총 주문수량
        @AuraEnabled public Decimal totalGICompletedQuantity {
            get {
                if(totalGICompletedQuantity == null) totalGICompletedQuantity =  0;
                return totalGICompletedQuantity;
            } 
            set;
        }//총 출고수량
        //납입 지연
        @AuraEnabled public List<OrderItem> itemList {
            get {
                if(itemList == null) itemList = new List<OrderItem>();
                return itemList;
            }
            set;
        }

        /*
        * @ Class : OrderSummary
        * @ Description : OrderSummary Class
        */
        public OrderSummary() {}
        public OrderSummary(DealerOrder__c orderSObject) {
            this.id                 = orderSObject.Id;
            this.seq                = orderSObject.OrderNumber__c;
            this.customerOrerNumber = orderSObject.CustomerPurchaseOrderNumber__c;
            this.orderType          = orderSObject.OrderType__c;
            this.customerName       = orderSObject.FM_CustomerName__c;
            this.orderDate          = orderSObject.FM_OrderDate__c;
            this.totalItemCount     = 0;
            this.totalItemAmount    = 0;
            this.currencyCode       = orderSObject.CurrencyIsoCode;
            this.priority           = orderSObject.Priority__c;
            this.returnOrder        = orderSObject.TotalItemReturnQtyCount__c > 0 ? 'Y' : '';
            this.status             = orderSObject.FM_OrderStatus__c;
            this.statusLabel        = orderSObject.FM_OrderStatusLabel__c;
        }

    }

    /*
    * @ Class : Order
    * @ Description : Order Class
    */
    public class Order {
        @AuraEnabled public String id                   {get; set;}
        @AuraEnabled public String seq                  {get; set;} //주문번호
        @AuraEnabled public String customerOrerNumber   {get; set;} //고객용주문번호 CustomerPurchaseOrderNumber__c
        @AuraEnabled public String salesOrganization    {get; set;}
        @AuraEnabled public String distributionChannel  {get; set;}
        @AuraEnabled public String division             {get; set;}
        
        @AuraEnabled public String orderType            {
            get {
                if(String.isBlank(this.orderType)) this.orderType = 'S';
                return this.orderType;
            }
            set;
        }
        @AuraEnabled public String orderTypeLabel       {get; set;} //주문 유형 Label
        @AuraEnabled public String dealer               {get; set;} //Dealer__c
        @AuraEnabled public String dealerName           {get; set;} //Dealer__r.Name
        @AuraEnabled public String customerCode         {get; set;} //일반고객일 경우만 값이 존재 (9999999999)
        @AuraEnabled public String customer             {get; set;} //DealerCustomer__c
        @AuraEnabled public String customerName         {get; set;} //DealerCustomer__r.Name
        @AuraEnabled public String bulkShipping         {
            get {
                if(String.isBlank(this.bulkShipping)) this.bulkShipping = 'N';
                return this.bulkShipping;
            }
            set;
        }
        @AuraEnabled public String dealerAddress        {get; set;} // 대리점의 주소정보
        @AuraEnabled public String customerShipToCode   {get; set;} //일반고객일 경우만 값이 존재 (9999999999)
        @AuraEnabled public String customerShipTo       {get; set;} //ShipToCode__c
        @AuraEnabled public String customerShipToName   {get; set;} //일반 고객 및 대리점 고객의  FullAddress
        @AuraEnabled public String postalCode           {get; set;} //우편번호
        @AuraEnabled public String city                 {get; set;} //CITY1 기본주소
        @AuraEnabled public String street               {get; set;} //STREET 상세주소
        @AuraEnabled public String phone                {get; set;} //
        @AuraEnabled public String representative       {get; set;} //대표자명
        @AuraEnabled public String shippingType         {
            get {
                if(String.isBlank(this.shippingType)) this.shippingType = '4';
                return this.shippingType;
            } 
            set;
        } //배송방법
        @AuraEnabled public String shippingCompany      {get; set;} 
        @AuraEnabled public String invoice              {get; set;} 
        @AuraEnabled public String memo                 {get; set;} 
        @AuraEnabled public String priority             {get; set;}
        @AuraEnabled public String quoteId              {get; set;}
        @AuraEnabled public List<OrderItem> itemList    {
            get {
                if(itemList == null) itemList = new List<OrderItem>();
                return itemList;
            }
            set;
        }
        @AuraEnabled public Date orderDate              {get; set;}
        @AuraEnabled public Date lastModifiedDate       {get; set;}
        @AuraEnabled public String soldToParty          {get; set;}
        @AuraEnabled public String shipToName           {get; set;}
        @AuraEnabled public String shippingTypeLabel    {get; set;}
        @AuraEnabled public String lastModifiedByName   {get; set;}
        public Order() {}
        /*
        * @ 생성자 : Order
        * @ Description : recordId 기준으로 오더 정보
        */
        public Order(String recordId) {
            DealerOrder__c orderSObject = [
                SELECT
                    Id
                    , LastModifiedBy.Name
                    , toLabel(ShippingType__c) shippingTypeLabel
                    , FM_SoldToParty__c
                    , OrderNumber__c
                    , Dealer__r.FM_Address__c
                    , OrderType__c
                    , toLabel(OrderType__c) orderTypeLabel
                    , FM_OrderDate__c
                    , FM_LastModifiedDate__c
                    , SalesOrganization__c
                    , DistributionChannel__c
                    , Division__c
                    , CustomerPurchaseOrderNumber__c
                    , Dealer__c
                    , Dealer__r.Name
                    , Customer__c
                    , FM_CustomerName__c
                    , CustomerShipToCode__c
                    , BulkShipping__c
                    , Address__Street__s
                    , Address__PostalCode__s
                    , Address__CountryCode__s
                    , RoadAddr__c
                    , DetailInfo__c
                    , Representative__c
                    , Phone__c
                    , ShippingType__c
                    , ShippingCompany__c
                    , Invoice__c
                    , Memo__c
                    , Status__c
                    , Priority__c
                    , CustomerShipTo__c
                    , Quote__c
                    , CustomerCode__c
                    , FM_ShipToName__c
                    , Customer__r.RoadAddr__c
                    , Customer__r.DetailInfo__c
                    , (
                        SELECT
                            Id
                            , Order__c
                            , FM_OrderNumber__c
                            , OrderItemNumber__c
                            , Part__c
                            , Part__r.Name
                            , Part__r.FM_MaterialDetails__c
                            , ReplacingPart__c
                            , ReplacingPart__r.Name
                            , ReplacingPart__r.FM_MaterialDetails__c
                            , FM_ReplacingPartSpec__c
                            , Quantity__c
                            , FM_Unit__c
                            , AvailableQuantity__c
                            , CurrentStockQuantity__c
                            , SaleQuantityUnit__c
                            , CustomerPrice__c
                            , DiscountPrice__c
                            // , DiscountAmount__c
                            , DiscountRate__c
                            , FM_DiscountAmount__c
                            , DealerPurchaseOrderItem__c
                            , FM_DealerPurchaseOrder__c
                            , GICompletedQuantity__c
                            , FM_PendingQuantity__c
                            , FM_GICompletedDate__c
                            , FM_DeliveryStatus__c
                            , Equipment__c
                            , MachineName__c
                            , TotalReturnQtyCount__c
                            , CurrencyIsoCode
                        FROM item__r WHERE Delete__c != 'Y'
                        ORDER BY OrderItemNumber__c
                    )
                FROM DealerOrder__c
                WHERE Id = :recordId 
                
                LIMIT 1
            ];
            this.initialize(orderSObject);

            for(DealerOrderItem__c orderItemSObject : orderSObject.item__r) {
                itemList.add(new OrderItem(orderItemSObject));
            }

        }

        /*
        * @ 생성자 : Order
        * @ Description : 견적서 확정
        */
        public Order(DN_DealerPortalQuoteCreateController.Quote quote) {
            this.quoteId             = quote.Id;
            this.salesOrganization   = quote.salesOrganization;
            this.distributionChannel = quote.distributionChannel;
            this.division            = quote.division;
            this.dealer              = quote.dealer;
            this.dealerName          = quote.dealerName;
            this.customerCode        = quote.customerCode;
            this.customer            = quote.customer;
            this.customerName        = quote.customerName;
            this.orderType           = 'S'; //S: 일반오더
            this.bulkShipping        = 'N';
            this.shippingType        = '4';
            
            for(DealerCustomerShipTo__c shipTo : [
                SELECT 
                Id
                , Customer__c 
                , Customer__r.CustomerCode__c 
                , Customer__r.Name 
                , Customer__r.ShippingType__c 
                , Customer__r.FM_PartsManagerName__c 
                , Customer__r.FM_PartsManagerContact__c 
                , Address__PostalCode__s 
                , DetailInfo__c
                , RoadAddr__c 
                FROM DealerCustomerShipTo__c
                WHERE Customer__c = :customer
                LIMIT 1
            ]) {
                this.shippingType = shipTo.Customer__r.ShippingType__c;
                this.customerShipToName = shipTo.Address__PostalCode__s + ' '+ shipTo.RoadAddr__c;
                if(String.isNotBlank(shipTo.DetailInfo__c)) this.customerShipToName += ' '+shipTo.DetailInfo__c;
                this.customerShipTo = shipTo.Id;
            }

            for(DN_DealerPortalQuoteCreateController.QuoteItem item : quote.itemList) {
                OrderItem orderItem = new OrderItem(item);
                orderItem.equipment = quote.equipment;
                orderItem.machineName = quote.machineName;
                itemList.add(orderItem);
            }
        }
        
        /*
        * @ 생성자 : Order
        * @ Description : 대리점 구매 생성에서 승인시
        */
        public Order(DN_CreateAnotherAgencyPurchase.Order purchaseOrder) {
            this.salesOrganization   = purchaseOrder.salesOrganization;
            this.distributionChannel = purchaseOrder.distributionChannel;
            this.division            = purchaseOrder.division;
            this.customerOrerNumber  = purchaseOrder.customerOrerNumber;
            //대리점 구매 요청 대리점은 Dealer, 구매 요청 받은 대리점 Customer 
            //**매개변수 값 AccountId, DealerCustomerId 값 스위칭 필요 
            //미 스위칭시 Exception 발생
            this.dealer              = purchaseOrder.customer;
            this.dealerName          = purchaseOrder.customerName;
            this.customer            = purchaseOrder.dealer;
            this.customerName        = purchaseOrder.dealerName;
            this.orderType           = 'P'; //대리점간 거래
            this.bulkShipping        = purchaseOrder.bulkShipping;
            this.shippingType        = purchaseOrder.shippingType;
            this.priority            = purchaseOrder.priority;
            this.customerShipToCode  = purchaseOrder.customerShipToCode;
            this.customerShipTo      = purchaseOrder.customerShipTo;
            this.customerShipToName  = purchaseOrder.customerShipToName;
            this.postalCode          = purchaseOrder.postalCode;
            this.city                = purchaseOrder.city;
            this.street              = purchaseOrder.street;
            this.phone               = purchaseOrder.phone;
            this.representative      = purchaseOrder.representative;

            for(DN_CreateAnotherAgencyPurchase.OrderItem item : purchaseOrder.itemList) {
                OrderItem itemWrapper= new OrderItem(item);
                itemList.add(itemWrapper);
            }
        }

        /*
        * @ Method : initialize
        * @ Description : 대리점 주문 기준으로 Class에 데이터 매핑
        */
        private void initialize(DealerOrder__c order) {
            this.id                      =  order.Id;
            this.seq                     =  order.OrderNumber__c;
            this.customerOrerNumber      =  order.CustomerPurchaseOrderNumber__c;
            this.orderType               =  order.OrderType__c;
            this.orderTypeLabel          =  order.getPopulatedFieldsAsMap().containsKey('orderTypeLabel') ? String.valueOf(order.get('orderTypeLabel')) : '';
            this.customerCode            =  order.CustomerCode__c;
            this.customer                =  order.Customer__c;
            this.customerName            =  order.FM_CustomerName__c;
            this.bulkShipping            =  order.BulkShipping__c;
            this.customerShipToCode      =  order.CustomerShipToCode__c;
            this.customerShipTo          =  order.CustomerShipTo__c;
            this.customerShipToName      =  order.Address__PostalCode__s;
            this.soldToParty             =  order.FM_SoldToParty__c;
            this.shipToName              =  order.FM_ShipToName__c;
            this.dealerAddress           =  order.Dealer__r.FM_Address__c;
            
            if(String.isNotBlank(order.RoadAddr__c)) {
                this.customerShipToName  += ' '+  order.RoadAddr__c; 
            }
            if(String.isNotBlank(order.DetailInfo__c)) {
                this.customerShipToName  += ' '+ order.DetailInfo__c;//order.FM_ShipToName__c;   
            }
            
            this.postalCode              =  order.Address__PostalCode__s;
            this.city                    =  order.RoadAddr__c;
            this.street                  =  order.DetailInfo__c;
            this.phone                   =  order.Phone__c;
            this.representative          =  order.Representative__c;
            this.shippingType            =  order.ShippingType__c;
            this.shippingTypeLabel       =  order.getPopulatedFieldsAsMap().containsKey('shippingTypeLabel') ? String.valueOf(order.get('shippingTypeLabel')) : '';
            this.shippingCompany         =  order.ShippingCompany__c;
            this.invoice                 =  order.Invoice__c;
            this.memo                    =  order.Memo__c;
            this.priority                =  order.Priority__c;
            this.quoteId                 =  order.Quote__c;
            this.salesOrganization       =  order.SalesOrganization__c;
            this.distributionChannel     =  order.DistributionChannel__c;
            this.division                =  order.Division__c;
            this.dealer                  =  order.Dealer__c;
            this.dealerName              =  order.Dealer__r.Name;
            this.orderDate               =  order.FM_OrderDate__c;
            this.lastModifiedByName      =  order.LastModifiedBy.Name;
            this.lastModifiedDate        =  order.getPopulatedFieldsAsMap().containsKey('FM_LastModifiedDate__c') ? order.FM_LastModifiedDate__c : null;
        }

        /*
        * @ Method : convertToSObject
        * @ Description : Class 기준으로 DealerOrder__c에 매핑
        */
        public DealerOrder__c convertToSObject() {
            DealerOrder__c order = new 	DealerOrder__c(
                Id                              = id,
                OrderNumber__c                  = seq,
                CustomerPurchaseOrderNumber__c  = customerOrerNumber,
                OrderType__c                    = orderType,
                CustomerCode__c                 = customerCode,
                Customer__c                     = customer,
                CustomerName__c                 = customerName,
                BulkShipping__c                 = bulkShipping,
                CustomerShipToCode__c           = customerShipToCode,
                CustomerShipTo__c               = customerShipTo,
                Address__PostalCode__s          = postalCode,
                RoadAddr__c                     = city,              
                DetailInfo__c                   = street,            
                Phone__c                        = phone,             
                Representative__c               = representative,    
                ShippingType__c                 = shippingType,
                ShippingCompany__c              = shippingCompany,
                Invoice__c                      = invoice,        
                Memo__c                         = memo,           
                Priority__c                     = priority,       
                Quote__c                        = quoteId,
                Address__CountryCode__s         = 'KR'        
            );

            order.SalesOrganization__c      = (String.isBlank(salesOrganization)) ? currentUser.getSalesOranization() : salesOrganization;
            order.DistributionChannel__c    = (String.isBlank(distributionChannel)) ? currentUser.getDistributionChannel() : distributionChannel;
            order.Division__c               = (String.isBlank(division)) ? currentUser.getDivision() : division;
            order.Dealer__c                 = (String.isBlank(dealer)) ? currentUser.getAgencyId() : dealer;
            String fullAddress = (String.isNotBlank(order.DetailInfo__c)) ? order.RoadAddr__c + ', ' + order.DetailInfo__c : order.RoadAddr__c;
            order.Address__Street__s = fullAddress;
            
            return order;
        }
        
    }

    /*
    * @ Class : OrderItem
    * @ Description : OrderItem Class
    */
    public class OrderItem {
        @AuraEnabled public String  orderId              {get; set;} //주문Id
        @AuraEnabled public String  orderSeq             {get; set;}
        @AuraEnabled public String  itemId               {get; set;}
        @AuraEnabled public String  itemSeq              {get; set;}
        @AuraEnabled public String  part                 {get; set;}
        @AuraEnabled public String  partName             {get; set;}
        @AuraEnabled public String  partDetails          {get; set;}
        @AuraEnabled public String  replacingPart        {get; set;}
        @AuraEnabled public String  replacingPartName    {get; set;}
        @AuraEnabled public String  replacingPartDetails {get; set;}
        @AuraEnabled public String  replacingPartSpec    {get; set;} //스펙
        @AuraEnabled public Decimal quantity             {get; set;}
        @AuraEnabled public String  unit                 {get; set;}
        @AuraEnabled public Decimal salesUnit            {get; set;}
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
        }//출고수량
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
        }//미결수량 
        @AuraEnabled public Decimal blockQuantity           {
            get{
                if(blockQuantity == null) blockQuantity = 0;
                return blockQuantity;
            } 
            set;
        }//Block수량 
        @AuraEnabled public String  currencyCode         {get; set;}
        @AuraEnabled public Decimal customerPrice        {get; set;} 
        @AuraEnabled public Decimal discountPrice        {get; set;} 
        @AuraEnabled public Decimal discountAmount       {get; set;} 
        @AuraEnabled public Decimal discountRate         {get; set;}
        @AuraEnabled public String machineName           {get; set;}
        @AuraEnabled public String equipment             {get; set;}
        @AuraEnabled public String purchaseOrderItemId   {get; set;}
        @AuraEnabled public String deleteYN              {get; set;} // Y/N
        @AuraEnabled public String deliveryStatus        {get; set;}
        @AuraEnabled public Date giDate                  {get; set;}
        @AuraEnabled public Date orderDate               {get; set;}
        @AuraEnabled public Boolean isComplete = false;   //출고 완료 여부
        @AuraEnabled public Boolean isOutOfStock = false; //현재 가용재고가 0 이하 일 경우 (결품수량)

        /*
        * @ 생성자 : OrderItem
        * @ Description : DealerOrderItem__c 기준으로 클래스에 매핑
        */
        public OrderItem(){}
        public OrderItem(DealerOrderItem__c orderItem){
            Boolean isReturn = orderItem.TotalReturnQtyCount__c == orderItem.Quantity__c ? true : false;
            this.orderId              = orderItem.Order__c;
            this.orderSeq             = orderItem.FM_OrderNumber__c;
            this.itemId               = orderItem.Id;
            this.itemSeq              = orderItem.OrderItemNumber__c;
            this.part                 = orderItem.Part__c;
            this.partName             = orderItem.Part__r.Name;
            this.partDetails          = orderItem.Part__r.FM_MaterialDetails__c;
            this.replacingPart        = orderItem.ReplacingPart__c;
            this.replacingPartName    = orderItem.ReplacingPart__r.Name;
            this.replacingPartDetails = orderItem.ReplacingPart__r.FM_MaterialDetails__c;
            this.quantity             = orderItem.Quantity__c;
            this.salesUnit            = orderItem.SaleQuantityUnit__c;
            this.unit                 = orderItem.FM_Unit__c;
            this.currencyCode         = orderItem.CurrencyIsoCode;
            this.customerPrice        = orderItem.CustomerPrice__c;
            this.discountPrice        = orderItem.DiscountPrice__c;
            this.discountAmount       = orderItem.FM_DiscountAmount__c;
            this.discountRate         = orderItem.DiscountRate__c;
            this.machineName          = orderItem.MachineName__c;
            this.equipment            = orderItem.Equipment__c;
            this.giQuantity           = orderItem.GICompletedQuantity__c;
            this.pendingQuantity      = orderItem.FM_PendingQuantity__c;
            this.giDate               = isReturn? null : orderItem.FM_GICompletedDate__c;
            this.deliveryStatus       = orderItem.FM_DeliveryStatus__c;
            this.replacingPartSpec    = orderItem.getPopulatedFieldsAsMap().containsKey('FM_ReplacingPartSpec__c') ?  orderItem.FM_ReplacingPartSpec__c : '';
            this.isComplete           = pendingQuantity < 1;
        }

        /*
        * @ 생성자 : OrderItem
        * @ Description : 견적서 확정
        */
        public OrderItem(DN_DealerPortalQuoteCreateController.QuoteItem quoteItem) {
            this.itemSeq              = quoteItem.itemSeq;
            // this.part                 = quoteItem.part;
            // this.partName             = quoteItem.partName;
            // this.partDetails          = quoteItem.partDetails;
            this.part                 = this.replacingPart        = quoteItem.replacingPart;
            this.partName             = this.replacingPartName    = quoteItem.replacingPartName;
            this.partDetails          = this.replacingPartDetails = quoteItem.replacingPartDetails;
            this.unit                 = quoteItem.unit;
            this.quantity             = quoteItem.quantity;
            this.customerPrice        = quoteItem.customerPrice;
            this.discountPrice        = quoteItem.discountPrice;
            this.discountAmount       = quoteItem.discountAmount;
            this.discountRate         = quoteItem.discountRate;
        }

        /*
        * @ 생성자 : OrderItem
        * @ Description : 대리점 구매 생성에서 승인시
        */
        public OrderItem(DN_CreateAnotherAgencyPurchase.OrderItem purchaseOrderItem) {
            this.itemId               = purchaseOrderItem.customerOrderItemId;
            this.itemSeq              = purchaseOrderItem.itemSeq;
            this.part                 = purchaseOrderItem.part;
            this.partName             = purchaseOrderItem.partName;
            this.partDetails          = purchaseOrderItem.partDetails;
            this.replacingPart        = purchaseOrderItem.replacingPart;
            this.replacingPartName    = purchaseOrderItem.replacingPartName;
            this.replacingPartDetails = purchaseOrderItem.replacingPartDetails;
            if(String.isBlank(purchaseOrderItem.replacingPart)) {
                //대체품이 비어있을경우 주문품번(사용자가 검색한 품번)
                this.replacingPart        = purchaseOrderItem.part;
                this.replacingPartName    = purchaseOrderItem.partName;
                this.replacingPartDetails = purchaseOrderItem.partDetails;
            }
            this.unit                 = purchaseOrderItem.unit;
            this.quantity             = purchaseOrderItem.quantity;
            this.customerPrice        = purchaseOrderItem.customerPrice;
            this.discountPrice        = purchaseOrderItem.discountPrice;
            this.discountAmount       = purchaseOrderItem.discountAmount;
            this.discountRate         = purchaseOrderItem.discountRate;
            this.machineName          = purchaseOrderItem.machineName;
            this.equipment            = purchaseOrderItem.equipment;
            this.currencyCode         = purchaseOrderItem.currencyCode;
            this.salesUnit            = purchaseOrderItem.salesUnit;
            this.currentStockQuantity = purchaseOrderItem.currentStockQuantity;
            this.avaiableQuantity     = purchaseOrderItem.avaiableQuantity;
            this.purchaseOrderItemId  = purchaseOrderItem.itemId;
            this.deleteYN             = purchaseOrderItem.deleteYN;
            
        }
        

        /*
        * @ Method : convertToSObject
        * @ Description : 클래스 데이터 기준으로 DealerOrderItem__c 변환
        */
        public DealerOrderItem__c convertToSObject() {
            DealerOrderItem__c orderItem = new DealerOrderItem__c(
                OrderItemNumber__c      = this.itemSeq,
                Part__c                 = this.part,
                ReplacingPart__c        = this.replacingPart,
                SaleQuantityUnit__c     = this.salesUnit,
                Quantity__c             = this.quantity,
                CurrencyIsoCode         = this.currencyCode,
                CustomerPrice__c        = this.customerPrice,
                DiscountPrice__c        = this.discountPrice,
                DiscountRate__c         = this.discountRate,
                MachineName__c          = this.machineName,
                Equipment__c            = this.equipment
            );

            if(String.isNotBlank(this.itemId))           orderItem.Id                      = this.itemId;
            if(String.isNotBlank(this.purchaseOrderItemId)) orderItem.DealerPurchaseOrderItem__c = this.purchaseOrderItemId;
            System.debug('orderItem.DealerPurchaseOrderItem__c :: '+ orderItem.DealerPurchaseOrderItem__c);

            if(orderItem.DiscountRate__c == null || orderItem.DiscountRate__c == 0) {
                orderItem.DiscountPrice__c = orderItem.CustomerPrice__c;
            }
            return orderItem;
        }

        public DealerOrderItem__c convertToSObject(String orderId) {
            DealerOrderItem__c orderItem = convertToSObject();
            orderItem.Order__c = orderId;
            return orderItem;
        }
    }

    public enum StatusCode { SUCCESS, ERROR }

    /*
    * @ class : StatusInfo
    * @ Description : 상태값 Class
    */
    public class StatusInfo {
        @AuraEnabled public Integer code      {get; set;}
        @AuraEnabled public String msg        {get; set;}
        @AuraEnabled public StatusCode status {get; set;}

        /*
        * @ 생성자 : StatusInfo
        * @ Description : 초기값 설정
        */
        public StatusInfo() {
            code = 200;
            status = StatusCode.SUCCESS;
        }

        /*
        * @ Method : setCode
        * @ Description : 코드값 설정
        */
        public void setCode(Integer code) {
            this.code = code;
        }

        /*
        * @ Method : setCode
        * @ Description : 메세지 설정
        */
        public void setMessage(String msg) {
            this.msg = msg;
        }

        /*
        * @ Method : setError
        * @ Description : 에러인 경우 메세지 및 코드 반환
        */
        public void setError(String msg, Integer code) {
            this.status = StatusCode.ERROR;
            this.code = (code == null) ? 400 : code;
            setMessage(msg);
        }

    }

    public class CustomException extends Exception {}
}