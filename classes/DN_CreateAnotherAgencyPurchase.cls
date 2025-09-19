/** 
 * @Class : DN_CreateAnotherAgencyPurchase
 * 
 * @Test: 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 01. 04. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-04 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_CreateAnotherAgencyPurchase {
    public DN_CreateAnotherAgencyPurchase() {}

    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /*******************************************  타 대리점 구매 생성 화면 ********************************************************/
    /*
    * @ Method : init
    * @ Description : Id에 따라 대리점 주문 OR 대리점 구매 데이터
    */
    @AuraEnabled
    public static Map<String,Object> init(List<String> sourceIdList){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();

        try {
            Order orderWrapper;
            orderWrapper = new Order();

            if(sourceIdList != null && sourceIdList.size() > 0) {
                String sourceId = sourceIdList[0];
                String sObjectTypeName = Id.valueOf(sourceId).getSobjectType().getDescribe().getLocalName();
                result.put('sObjectTypeName', sObjectTypeName);

                switch on sObjectTypeName {
                    when 'DealerOrderItem__c' {
                        orderWrapper.itemList = getOrderItemByDealerOrderItem(sourceIdList);
                    }
                    when 'DealerPurchaseOrder__c' {
                        orderWrapper =  new Order(sourceId);
                    }
                    when else {
                        throw new CustomException('Does Not permission sourceId');
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
    * @ Method : getOrderItemByDealerOrderItem
    * @ Description : 대리점 주문 아이템 목록
    */
    private static List<OrderItem> getOrderItemByDealerOrderItem(List<String> orderItemIdList) {
        List<OrderItem> orderItemList = new List<OrderITem>();
        for(DealerOrderItem__c dealerOrderItem :[ SELECT
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
                                                    , DiscountRate__c
                                                    , FM_DiscountAmount__c
                                                    , DealerPurchaseOrderItem__c
                                                    , FM_DealerPurchaseOrder__c
                                                    // , GICompletedQuantity__c
                                                    , Equipment__c
                                                    , MachineName__c
                                                    , CurrencyIsoCode
                                                FROM DealerOrderItem__c WHERE Delete__c != 'Y' AND  Id IN :orderItemIdList
        ]) {
            OrderItem poItem = new OrderItem();
            poItem.part                 = dealerOrderItem.Part__c;
            poItem.partName             = dealerOrderItem.Part__r.Name;
            poItem.partDetails          = dealerOrderItem.Part__r.FM_MaterialDetails__c;
            poItem.replacingPart        = dealerOrderItem.ReplacingPart__c;
            poItem.replacingPartName    = dealerOrderItem.ReplacingPart__r.Name;
            poItem.replacingPartDetails = dealerOrderItem.ReplacingPart__r.FM_MaterialDetails__c;
            poItem.quantity             = dealerOrderItem.Quantity__c;
            poItem.unit                 = dealerOrderItem.FM_Unit__c;
            poItem.currencyCode         = dealerOrderItem.CurrencyIsoCode;
            poItem.customerPrice        = dealerOrderItem.CustomerPrice__c;
            poItem.discountPrice        = dealerOrderItem.DiscountPrice__c;
            poItem.discountAmount       = dealerOrderItem.FM_DiscountAmount__c;
            poItem.discountRate         = dealerOrderItem.DiscountRate__c;
            poItem.currentStockQuantity = dealerOrderItem.CurrentStockQuantity__c;
            poItem.machineName          = dealerOrderItem.MachineName__c;
            poItem.equipment            = dealerOrderItem.Equipment__c;
            orderItemList.add(poItem);
        }
        return orderItemList;
    }

    /*
    * @ Method : doSimulation
    * @ Description : 부품별 가격 정보 조회
    */
    @AuraEnabled
    public static Map<String,Object> doSimulation(List<String> partCodeList, Map<String,String> partDealerMap){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            String agencyId = currentUser.getAgencyId();
            Map<String, String> customerCodeGradeMap = new Map<String,String>();
            Map<String, Decimal> purchasingGradeMap = new Map<String, Decimal>();

            DN_SimulationManager simulator = new DN_SimulationManager(
                DN_SimulationManager.Type.CUSTOMERORDER
                , partCodeList
                , agencyId
            );
            //
            String purchaseGrade = currentUser.getDealerGrade();
            result.put('purchaseGrade', purchaseGrade);
            if(String.isNotBlank(purchaseGrade)) {
                List<String> customerCodes = partDealerMap.values();
                Set<String> customerCodeSet = customerCodes.size() > 0 ? new Set<String>(customerCodes) : new Set<String>();

                for(SalesAreaData__c salesAreaData :[
                    SELECT Account__c, Account__r.CustomerCode__c, Account__r.Name, Account__r.DealerGrade__c, Account__r.DealerGrade_Parts__c
                    FROM SalesAreaData__c
                    WHERE 
                        Account__r.CustomerCode__c IN :customerCodeSet AND Account__r.RecordType.DeveloperName = 'Dealer'
                    AND SalesOrganization__c = :currentUser.getSalesOranization() AND CustomerGroup__c = '02'
                ]) {
                    customerCodeGradeMap.put(salesAreaData.Account__r.CustomerCode__c, salesAreaData.Account__r.DealerGrade_Parts__c); //DealerGrade__c > DealerGrade_Parts__c
                }

                if(customerCodeGradeMap.size() > 0) {
                    Set<String> salesGradeSet = new Set<String>(customerCodeGradeMap.values());
                    for(DealerDiscountRate__c rate : [ SELECT
                                PurchasingDealerGrade__c,
                                SalesDealerGrade__c,
                                Rate__c
                        FROM DealerDiscountRate__c 
                        WHERE 
                            SalesDealerGrade__c IN :salesGradeSet
                            AND PurchasingDealerGrade__c = :purchaseGrade  ]) {
                                purchasingGradeMap.put(rate.SalesDealerGrade__c, rate.Rate__c);
                    }
                }
            }

            result.put('customerCodeGradeMap', customerCodeGradeMap);
            result.put('purchasingGradeMap', purchasingGradeMap);
            result.put('partDetailsMap' , simulator.simulation(currentUser, partDealerMap));
            
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
    * @ Description : 대리점 구매 생성 및 요청 대리점에 메일 발송
    */
    @AuraEnabled
    public static Map<String,Object> createOrder(List<Order> orderList){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        
        try {
            String agencyId = currentUser.getAgencyId();
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();
            
            Map<String, List<OrderItem>> customerOrderItemMap = new Map<String, List<OrderItem>>(); //구매 요청 대리점 별 주문 Item
            List<DealerPurchaseOrder__c> orderSObjectList = new List<DealerPurchaseOrder__c>();
            for(Order order : orderList) {
                DealerPurchaseOrder__c orderSObject = order.convertToSObject();
                orderSObjectList.add(orderSObject);

                customerOrderItemMap.put(orderSObject.Customer__c, order.itemList);

            }
            insert orderSObjectList;
            String orderIds='';
            List<DealerPurchaseOrderItem__c> orderItemSObjectList = new List<DealerPurchaseOrderItem__c>();
            
            Map<String, String> orderIdDealerMap = new Map<String, String>(); //오더Id별 Dealer
            // Map<String, String> productIdCodeMap = new Map<String, String>(); //부품Id별 ProductCode
            for(DealerPurchaseOrder__c order : orderSObjectList) {
                orderIds = order.Id;
                if(customerOrderItemMap.containsKey(order.Customer__c)) {
                    orderIdDealerMap.put(order.Id, order.Customer__c);
                    for(OrderItem orderItem : customerOrderItemMap.get(order.Customer__c)) {
                        orderItemSObjectList.add(orderItem.convertToSObject(order.Id));
                        // productIdCodeMap.put(orderItem.replacingPart, orderItem.replacingPartName);
                    }
                }
            }

            
            if(orderItemSObjectList.size() > 0) {
                insert orderItemSObjectList;
            }
            DealerPurchaseOrder__c orders = [SELECT Id,Dealer__r.name, Name ,Customer__r.SourceAccount__c,OrderNumber__c FROM DealerPurchaseOrder__c WHERE Id =:orderIds];
            System.debug(orders.Customer__r.SourceAccount__c);
            String query = 'SELECT Id, Name, UserName, Email, UserType, AccountId, Account.RecordType.DeveloperName, Account.CustomerCode__c, Profile.Name, ContactId, Plant__c FROM User WHERE AccountId=\''+orders.Customer__r.SourceAccount__c+'\'';
            query +=' AND AccountId !=null';
            query +=' AND UserType = \'PowerPartner\' ';
            query +=' AND Profile.Name =\'DNS CS Parts_Partner\' AND IsActive =true ';
            String dealerCustomerQ ='SELECT Id, Name, PartsManagerEmail__c FROM DealerCustomer__c WHERE SourceAccount__c =\''+orders.Customer__r.SourceAccount__c+'\' AND IsActive__c =true';
            List<DealerCustomer__c> dealerCustomerList = DN_WithoutSharingDealerPortal.withoutObjectList(dealerCustomerQ);
            System.debug(dealerCustomerList + ' ::: dealerCustomerList');
            List<User> targetUser= DN_WithoutSharingDealerPortal.withoutObjectList(query);

          
            System.debug(orderItemSObjectList + ' ::: orderItemSObjectList');
            result.put('orderList', orderSObjectList);
            if(targetUser.size() > 0) {
                String targetEmail = '';
                if(dealerCustomerList.size() > 0) {
                    targetEmail = dealerCustomerList[0].PartsManagerEmail__c ==null ?  targetUser[0].Email : dealerCustomerList[0].PartsManagerEmail__c;
                } else {
                    targetEmail = targetUser[0].Email;
                }
                //이메일 보내기
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                System.debug(targetUser[0].Email + ' ::: targetUser[0].Email');
                email.setToAddresses(new String[] { targetEmail});
                email.setSubject(orders.Dealer__r.name + ' 대리점의 구매주문번호 '+orders.OrderNumber__c +'로 신규 구매 요청이 왔습니다.'); //영진기계 대리점의 구매주문번호 4000035370 로 신규 구매 요청이 왔습니다
                //email.setSenderDisplayName(targetEmail);
                String html = '';
                        html += '<table border="1" style="border-collapse: collapse; text-align: center; font-family: Arial; font-size: 14px;">';
                        html += '<thead>';
                        html += '<tr>';
                        html += '<th>구매주문번호</th>';
                        html += '<th>항번</th>';
                        html += '<th>품번</th>';
                        html += '<th>품명</th>';
                        html += '<th>요청수량</th>';
                        html += '<th>구매금액</th>';
                        html += '<th>통화</th>';
                        html += '</tr>';
                        html += '</thead>';
                        html += '<tbody>';
                String htmlBody ='';
                for(DealerPurchaseOrderItem__c orderItems : [SELECT Id,DealerPurchaseOrder__r.OrderNumber__c
                    ,OrderItemNumber__c
                    ,ReplacingPart__r.ProductCode
                    ,ReplacingPart__r.FM_MaterialDetails__c
                    ,Quantity__c
                    ,DiscountPrice__c
                    ,ReplacingPart__r.CurrencyIsoCode
                    FROM DealerPurchaseOrderItem__c WHERE DealerPurchaseOrder__c=:orders.Id
                ]) 
                {
                    htmlBody +=  '<tr>';
                    htmlBody +=  '<td>'+ orderItems.DealerPurchaseOrder__r.OrderNumber__c + '</td>';
                    htmlBody +=  '<td>'+ Decimal.valueOf(orderItems.OrderItemNumber__c)+'</td>';
                    htmlBody +=  '<td>'+orderItems.ReplacingPart__r.ProductCode+'</td>';
                    htmlBody +=  '<td>'+orderItems.ReplacingPart__r.FM_MaterialDetails__c+'</td>';
                    htmlBody +=  '<td>'+orderItems.Quantity__c+'</td>';
                    htmlBody +=  '<td>'+orderItems.DiscountPrice__c+'</td>';
                    htmlBody +=  '<td>'+orderItems.ReplacingPart__r.CurrencyIsoCode+'</td>';
                    htmlBody +=  '</tr>';
                }        
                htmlBody +=  '</tbody>';
                htmlBody +=  '</table>';
                email.setHtmlBody(html + htmlBody);
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                System.debug(results  +' :: results');
                
        }
            
        } catch (Exception e) {
            //Database.rollback(sp);
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*******************************************  타 대리점 구매 상세 화면 ********************************************************/
    /*
    * @ Method : detailInit
    * @ Description : 타 대리점 구매 상세 아이템 목록
    */
    @AuraEnabled
    public static Map<String,Object> detailInit(String recordId, String pageType){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();

        try {
            Order orderWrapper= new Order(recordId);
            
            //대리점간 승인시 현재 데이터 Deaelr, Customer 값 스위칭
            //1. 딜러는 DealerCustomer Id 로 변경
            DealerCustomer__c dealerCustomer = [ SELECT Id, Name FROM DealerCustomer__c WHERE SourceAccount__c = :orderWrapper.dealer LIMIT 1];
            orderWrapper.dealer = dealerCustomer.Id;

            //2. 고객은 Account Id 로 변경
            DealerCustomer__c customer = [ SELECT Id, SourceAccount__c, SourceAccount__r.CustomerCode__c, Name FROM DealerCustomer__c WHERE Id = :orderWrapper.customer LIMIT 1];
            orderWrapper.customer = customer.SourceAccount__c;
            orderWrapper.customerCode = customer.SourceAccount__r.CustomerCode__c;

            result.put('isReadOnly', currentUser.getAgencyId() == customer.SourceAccount__c);
            System.debug('pageType : '+pageType);

            if('APPROVAL'.equals(pageType)) {
                Set<String> itemIdList = new Set<String>();
                Set<String> partIdSet = new Set<String>();
                for(OrderItem item : orderWrapper.itemList) {
                    itemIdList.add(item.itemId);
                    if(String.isNotBlank(item.replacingPart)) {
                        partIdSet.add(item.replacingPart);
                    }
                }

                // 승인할 대리점 재고 

                Map<String, DealerStock__c> stockMap = DN_DealerStockManager.getAvailableStockMap(currentUser.getAgencyId(), currentUser.getSalesOranization(), currentUser.getDistributionChannel(), currentUser.getDivision(), partIdSet);

                Map<String, DealerOrderItem__c> dealerOrderItemMap = new Map<String, DealerOrderItem__c>();
                for(DealerOrderItem__c dealerOrderItem :[
                    SELECT Id, DealerPurchaseOrderItem__c, FM_OrderNumber__c FROM DealerOrderItem__c WHERE DealerPurchaseOrderItem__c IN :itemIdList
                ]) {
                    dealerOrderItemMap.put(dealerOrderItem.DealerPurchaseOrderItem__c , dealerOrderItem);
                }

                for(OrderItem item : orderWrapper.itemList) {
                    item.customerOrderSeq = dealerOrderItemMap.get(item.itemId)?.FM_OrderNumber__c;
                    item.customerOrderItemId  = dealerOrderItemMap.get(item.itemId)?.Id;
                    if(String.isNotBlank(item.replacingpart) && stockMap.containsKey(item.replacingPart)) {
                        item.avaiableQuantity = stockMap.get(item.replacingPart).AvailableQuantity__c;
                    }
                }
            }else {
                //Detail 화면
                System.debug('Detail ');
                Set<String> productCodeSet = new Set<String>();
                Map<String, OrderItem> partOrderItemMap = new Map<String, OrderItem>();
                for(OrderItem item : orderWrapper.itemList) {
                    productCodeSet.add(item.replacingPartName);
                    partOrderItemMap.put(item.replacingPartName, item);
                }
                

                Map<String, DealerStock__c> stockMap = DN_DealerStockManager.getAvailableStockMapMutipleForCode(new Set<String>{orderWrapper.customerCode}, currentUser.getSalesOranization(), currentUser.getDistributionChannel(), currentUser.getDivision(), productCodeSet);
                for(DealerStock__c stock : stockMap.values() ) {
                    if(partOrderItemMap.containsKey(stock.Part__r.Name)) {
                        OrderItem item = partOrderItemMap.get(stock.Part__r.Name);
                        item.currentStockQuantity = stock.AvailableQuantity__c;
                    }
                }

            }


            result.put('order', orderWrapper);
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
    * @ Method : doUpdateRequest
    * @ Description : 대리점 구매 상세  - 변경요청
    */
    @AuraEnabled
    public static Map<String,Object> doUpdateRequest(List<OrderItem> requestOrderItemList){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        Savepoint sp = Database.setSavepoint(); 
        try {
           List<DealerPurchaseOrderItem__c> requestUpdatePOItemList = new List<DealerPurchaseOrderItem__c>();
           for(OrderItem requestOrderItem : requestOrderItemList) {
                DealerPurchaseOrderItem__c requestUpdatePOItem = new DealerPurchaseOrderItem__c(
                    Id = requestOrderItem.itemId
                    ,Status__c = '2'
                    ,ChangeQuantity__c = requestOrderItem.changeQuantity
                );
                requestUpdatePOItemList.add(requestUpdatePOItem);
           }
           if(requestUpdatePOItemList.size() > 0) update requestUpdatePOItemList;
           result.put('requestUpdatePOItemList', requestUpdatePOItemList);

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
    * @ Method : doUpdateRequest
    * @ Description : 대리점 구매 상세  - 삭제요청
    */
    @AuraEnabled
    public static Map<String,Object> doDeleteRequest(List<OrderItem> requestOrderItemList){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        Savepoint sp = Database.setSavepoint(); 
        try {
           List<DealerPurchaseOrderItem__c> requestUpdatePOItemList = new List<DealerPurchaseOrderItem__c>();
           for(OrderItem requestOrderItem : requestOrderItemList) {
                DealerPurchaseOrderItem__c requestUpdatePOItem = new DealerPurchaseOrderItem__c(
                    Id = requestOrderItem.itemId
                    ,Status__c = '3'
                );
                requestUpdatePOItemList.add(requestUpdatePOItem);
           }
           if(requestUpdatePOItemList.size() > 0) update requestUpdatePOItemList;
           result.put('requestDeletePOItemList', requestUpdatePOItemList);

        } catch (Exception e) {
            Database.rollback(sp);
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*******************************************  타 대리점 거래 승인 화면 ********************************************************/
    /*
    * @ Method : getDealerPurchaseOrderList
    * @ Description : 대리점 구매 데이터 조회
    */
    @AuraEnabled
    public static Map<String,Object> getDealerPurchaseOrderList(String dealerId){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            String agencyId = currentUser.getAgencyId();

            

            List<Order> poList = new List<Order>();
            String querySelectForItem = '     SELECT '
                                    +'     Id, '
                                    +'     DealerPurchaseOrder__c, '
                                    +'     DealerPurchaseOrder__r.Id, '
                                    +'     DealerPurchaseOrder__r.OrderNumber__c, '
                                    +'     DealerPurchaseOrder__r.FM_OrderDate__c, '
                                    +'     DealerPurchaseOrder__r.SalesOrganization__c, '
                                    +'     DealerPurchaseOrder__r.DistributionChannel__c, '
                                    +'     DealerPurchaseOrder__r.Division__c, '
                                    +'     DealerPurchaseOrder__r.CustomerPurchaseOrderNumber__c, '
                                    +'     DealerPurchaseOrder__r.Dealer__c, '
                                    +'     DealerPurchaseOrder__r.Dealer__r.Name, '
                                    +'     DealerPurchaseOrder__r.Customer__c, '
                                    +'     DealerPurchaseOrder__r.Customer__r.Name, '
                                    +'     DealerPurchaseOrder__r.CustomerCode__c, '
                                    +'     DealerPurchaseOrder__r.FM_CustomerName__c, '
                                    +'     DealerPurchaseOrder__r.BulkShipping__c, '
                                    +'     DealerPurchaseOrder__r.Address__City__s, '
                                    +'     DealerPurchaseOrder__r.Address__PostalCode__s, '
                                    +'     DealerPurchaseOrder__r.Address__CountryCode__s, '
                                    +'     DealerPurchaseOrder__r.Phone__c, '
                                    +'     DealerPurchaseOrder__r.Representative__c, '
                                    +'     DealerPurchaseOrder__r.ShippingType__c, '
                                    +'     DealerPurchaseOrder__r.Priority__c, '
                                    +'     DealerPurchaseOrder__r.RoadAddr__c,  '
                                    +'     DealerPurchaseOrder__r.DetailInfo__c, '
                                    +'     DealerPurchaseOrder__r.CustomerShipTo__c, '
                                    +'     DealerPurchaseOrder__r.CustomerShipToCode__c, '
                                    //+ ' DealerPurchaseOrderCustomerShipTo__r.Address__PostalCode__s,
                                    //+ ' DealerPurchaseOrderCustomerShipTo__r.RoadAddr__c, 
                                    //+ ' DealerPurchaseOrderCustomerShipTo__r.DetailInfo__c,
                                    +'     DealerPurchaseOrder__r.FM_ShipToName__c, '
                                    +'     DealerPurchaseOrder__r.Delete__c, '
                                    +'     FM_OrderNumber__c, '
                                    +'     OrderItemNumber__c, '
                                    +'     Part__c, '
                                    +'     Part__r.Name, '
                                    +'     Part__r.FM_MaterialDetails__c, '
                                    +'     ReplacingPart__c, '
                                    +'     ReplacingPart__r.Name, '
                                    +'     ReplacingPart__r.FM_MaterialDetails__c, '
                                    +'     Quantity__c, '
                                    +'     FM_Unit__c, '
                                    +'     CurrentStockQuantity__c, '
                                    +'     GICompletedQuantity__c, '
                                    +'     SaleQuantityUnit__c, '
                                    +'     CustomerPrice__c, '
                                    +'     DiscountPrice__c, '
                                    +'     FM_DiscountAmount__c, '
                                    +'     DiscountRate__c, '
                                    +'     Status__c, '
                                    +'     toLabel(Status__c) statusLabel, '
                                    +'     FM_DeliveryStatus__c,'
                                    +'     Delete__c, '
                                    +'     GRStatus__c, '
                                    +'     MachineName__c, '
                                    +'     Equipment__c, '
                                    +'     ChangeQuantity__c, '
                                    +'     LastHistory__c, '
                                    +'     CurrencyIsoCode '
                                    +'     FROM DealerPurchaseOrderItem__c WHERE Status__c IN (\'1\', \'2\', \'3\') AND Delete__c != \'Y\' AND DealerPurchaseOrder__r.Customer__r.SourceAccount__c =\''+ agencyId +'\' ';
                
            String additionalWhereClauseForItem = '';
            String orderBy = ' ORDER BY LastModifiedDate desc';
            if(String.isNotBlank(dealerId)) {
                String dealerAccountId = [SELECT SourceAccount__c FROM DealerCustomer__c WHERE Id = :dealerId LIMIT 1].SourceAccount__c;

                additionalWhereClauseForItem += ' AND DealerPurchaseOrder__r.Dealer__c = :dealerAccountId ';
            }
            if(String.isNotBlank(additionalWhereClauseForItem)) querySelectForItem += additionalWhereClauseForItem;

            Map<Id, DealerPurchaseOrderItem__c> orderItemMap = new Map<Id, DealerPurchaseOrderItem__c>((List<DealerPurchaseOrderItem__c>)Database.query(querySelectForItem + orderBy + ' LIMIT 2000 '));
            
            Map<String, DealerOrderItem__c> mappingItemMap = new Map<String, DealerOrderItem__c>();
            for(DealerOrderItem__c dealerOrderItem : [
                SELECT Id, DealerPurchaseOrderItem__c, FM_OrderNumber__c, OrderItemNumber__c, GICompletedQuantity__c, Delete__c 
                FROM DealerOrderItem__c
                WHERE DealerPurchaseOrderItem__c IN :orderItemMap.keySet() AND Delete__c != 'Y'
            ]) {
                mappingItemMap.put(dealerOrderItem.DealerPurchaseOrderItem__c, dealerOrderItem);
            }

            Map<String, OrderSummary> pendingApprovalOrderMap = new Map<String, OrderSummary>();
            for(DealerPurchaseOrderItem__c orderItem : orderItemMap.values()) {
                String key = orderItem.DealerPurchaseOrder__c;
                OrderSummary pendingApprovalOrder;
                if(mappingItemMap.containsKey(orderItem.Id)) {
                    // System.debug('승인건!');
                    //대리점 구매 승인건
                    DealerOrderItem__c dealerOrderItem = mappingItemMap.get(orderItem.Id);
                    key += '_' +dealerOrderItem.FM_OrderNumber__c;

                    if(pendingApprovalOrderMap.containsKey(key)) {
                        pendingApprovalOrder = pendingApprovalOrderMap.get(key);
                    }else {
                        pendingApprovalOrder = new OrderSummary((DealerPurchaseOrder__c)orderItem.getSObject('DealerPurchaseOrder__r'));
                        pendingApprovalOrderMap.put(key, pendingApprovalOrder);
                        pendingApprovalOrder.status = orderItem.Status__c;
                        pendingApprovalOrder.statusLabel = (String)orderItem.get('statusLabel');
                        pendingApprovalOrder.customerOrderSeq = dealerOrderItem.FM_OrderNumber__c;
                    }

                }else {
                    //대리점 구매 미승인건
                    // System.debug('미승인건 ! ');
                    if(pendingApprovalOrderMap.containsKey(key)) {
                        // System.debug('pendingApprovalOrderMap.containsKey(key) :  ' + key);
                        pendingApprovalOrder = pendingApprovalOrderMap.get(key);
                    }else {
                        // System.debug('!pendingApprovalOrderMap.containsKey(key) > 최초 Put ' );
                        pendingApprovalOrder = new OrderSummary((DealerPurchaseOrder__c)orderItem.getSObject('DealerPurchaseOrder__r'));
                        pendingApprovalOrder.status = orderItem.Status__c;
                        pendingApprovalOrder.statusLabel = (String)orderItem.get('statusLabel');
                        pendingApprovalOrderMap.put(key, pendingApprovalOrder);
                    }
                }
                pendingApprovalOrder.currencyCode = orderItem.CurrencyIsoCode;
                pendingApprovalOrder.totalItemCount += orderItem.Quantity__c; //1;
                pendingApprovalOrder.totalItemAmount += orderItem.FM_DiscountAmount__c;
                pendingApprovalOrder.orderItemIdList.add(orderItem.Id);
            }
            
            result.put('pendingApprovalOrderList', pendingApprovalOrderMap.values());

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
    * @ Method : getDealerPurchaseOrderList
    * @ Description : 타 대리전간 거래 승인 - 승인
    */
    @AuraEnabled
    public static Map<String,Object> doApproval(Order approvalOrder){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        Savepoint sp = Database.setSavepoint(); 
        try {
            String dmlType = 'CREATE';
            List<DealerPurchaseOrderItem__c> orderItemList = new List<DealerPurchaseOrderItem__c>();
            List<DealerPurchaseOrderItemHistory__c> historyList = new List<DealerPurchaseOrderItemHistory__c>();
            for(OrderItem approvalOrderItem : approvalOrder.itemList) {
                //승인 Case
                //  -생성일 경우('1') -> '0' (진행중)
                //  -변경요청일 경우('2') -> '0' (진행중) && '4' (승인) 히스토리 업데이트
                //      - 대리점 구매 요청수량이 최종 요청수량으 로변경
                //      - 주문서 수량도 최종 요청수량으로 변경, 출고 수량과 변경 수량 동일하면 Staus 'C' 로 변경
                //  -삭제요청일 경우('3') -> '' Delete필드 변경...  && '5' (거절) 히스토리 업데이트
                
                DealerPurchaseOrderItem__c changeStatusOrderItem = new DealerPurchaseOrderItem__c(Id = approvalOrderItem.itemId);
                switch on approvalOrderItem.status {
                    when '1' {
                        changeStatusOrderItem.Status__c = '0';
                        dmlType = 'CREATE';
                    }
                    when '2' {
                        if(String.isNotBlank(approvalOrderItem.customerOrderSeq)) {
                            approvalOrderItem.quantity = approvalOrderItem.finalChangeQuantity;
                            changeStatusOrderItem.Status__c = '0';
                            changeStatusOrderItem.Quantity__c = approvalOrderItem.quantity;
                            changeStatusOrderItem.ChangeQuantity__c = 0;
                            dmlType = 'UPDATE';
                            historyList.add(new DealerPurchaseOrderItemHistory__c(Id = approvalOrderItem.lastHistoryId, Status__c = '4'));
                        }else {
                            //최초에 생성요청한 주문을 거절 후 다시 변경 요청할 경우
                            changeStatusOrderItem.Status__c = '0';
                            dmlType = 'CREATE';
                        }
                    }
                    when '3' {
                        changeStatusOrderItem.Delete__c = 'Y';
                        approvalOrderItem.deleteYN = 'Y';
                        dmlType = 'DELETE';
                        historyList.add(new DealerPurchaseOrderItemHistory__c(Id = approvalOrderItem.lastHistoryId, Status__c = '4'));
                        
                    }
                }
                orderItemList.add(changeStatusOrderItem);
            }

            DN_AgencyCustomerOrderCreateController.Order dealerOrder = new DN_AgencyCustomerOrderCreateController.Order(approvalOrder);
            Map<String,Object> dmlOrderResult;
            switch on dmlType {
                when  'CREATE'{
                    dmlOrderResult = DN_AgencyCustomerOrderCreateController.createOrder(dealerOrder);
                }
                when  'UPDATE'{
                    dmlOrderResult = DN_AgencyCustomerOrderCreateController.updateOrder(dealerOrder, true);
                }
                when  'DELETE'{
                    dmlOrderResult = DN_AgencyCustomerOrderCreateController.deleteOrderItems(dealerOrder.itemList);
                }
            }
            
            StatusInfo dmlOrderResultStatus = (StatusInfo)JSON.deserialize(JSON.serialize(dmlOrderResult.get('status')), StatusInfo.class);
            if(dmlOrderResultStatus.code == 200) {

                if(dmlOrderResult.containsKey('orderId')) {
                    result.put('orderId', dmlOrderResult.get('orderId'));
                }

                if(dmlOrderResult.containsKey('Order')) {
                    result.put('deleteOrder' ,dmlOrderResult.get('Order'));
                }

            }else {
                throw new CustomException(dmlOrderResultStatus.msg);
            }

            if(orderItemList.size() > 0) update orderItemList;
            if(historyList.size() > 0) update historyList;

        } catch (Exception e) {
            Database.rollback(sp);
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Method : getDealerPurchaseOrderList
    * @ Description : 타 대리전간 거래 승인 - 거절
    */
    @AuraEnabled
    public static Map<String,Object> doReject(Order rejectOrder){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        Savepoint sp = Database.setSavepoint(); 
        try {
            List<DealerPurchaseOrderItem__c> orderItemList = new List<DealerPurchaseOrderItem__c>();
            List<DealerPurchaseOrderItemHistory__c> historyList = new List<DealerPurchaseOrderItemHistory__c>();
            for(OrderItem rejectOrderItem : rejectOrder.itemList) {
                //거절 Case
                //  -생성일 경우('1') -> '5' (거부)
                //  -변경요청일 경우('2'), 삭제요청('3') -> '0' (진행중), 히스토리에 '5' 업데이트
                DealerPurchaseOrderItem__c changeStatusOrderItem = new DealerPurchaseOrderItem__c(Id = rejectOrderItem.itemId);
                switch on rejectOrderItem.status {
                    when '1' {
                        changeStatusOrderItem.Status__c = '5';
                    }
                    when '2', '3' {
                        changeStatusOrderItem.Status__c = '0';
                        changeStatusOrderItem.ChangeQuantity__c = 0;
                        DealerPurchaseOrderItemHistory__c history = new DealerPurchaseOrderItemHistory__c(Status__c = '5');
                        if(rejectOrderItem.lastHistoryId != null) history.Id = rejectOrderItem.lastHistoryId;
                        historyList.add(history);
                    }
                }
                orderItemList.add(changeStatusOrderItem);
            }
            if(historyList.size() > 0) update historyList;
            if(orderItemList.size() > 0) update orderItemList;

        } catch (Exception e) {
            Database.rollback(sp);
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
    public class OrderSummary {
        @AuraEnabled public String id                   {get; set;}
        @AuraEnabled public String seq                  {get; set;} //대리점 구매 요청 주문번호
        @AuraEnabled public String orderId              {get; set;}
        @AuraEnabled public String customerOrderSeq     {get; set;} //대리점 주문번호
        @AuraEnabled public String customerOrerNumber   {get; set;} //고객용주문번호 CustomerPurchaseOrderNumber__c
        @AuraEnabled public String dealerName           {get; set;} //구매요청 대리점.
        @AuraEnabled public String customerName         {get; set;} //로그인한 대리점
        @AuraEnabled public String priority             {get; set;}
        @AuraEnabled public Date orderDate              {get; set;}
        @AuraEnabled public Decimal totalItemCount      {get; set;}
        @AuraEnabled public Decimal totalItemAmount     {get; set;} //할인판매가의 총합
        @AuraEnabled public String currencyCode         {get; set;}
        @AuraEnabled public String status               {get; set;} //타대리점 거래 승인 화면 노출 값: 1: 생성, 2: 변경  Picklist 값 - 1: 구매요청, 2: 변경 요청, 3: 삭제 요청, 4: 승인, 5: 거부
        @AuraEnabled public String statusLabel          {get; set;}
        @AuraEnabled public List<String> orderItemIdList{
            get {
                if(orderItemIdList == null) orderItemIdList = new List<String>();
                return orderItemIdList;
            } 
            set;
        }
        //납입 지연

        public OrderSummary() {}
        public OrderSummary(DealerPurchaseOrder__c orderSObject) {
            this.id                 = orderSObject.Id;
            this.seq                = orderSObject.OrderNumber__c;
            this.customerOrerNumber = orderSObject.CustomerPurchaseOrderNumber__c;
            this.dealerName         = orderSObject.Dealer__r.Name;
            this.customerName       = orderSObject.FM_CustomerName__c;
            this.orderDate          = orderSObject.FM_OrderDate__c;
            this.priority           = orderSObject.Priority__c;
            this.totalItemCount     = 0;
            this.totalItemAmount    = 0;
        }
    }

    /*
    * @ Class : Order
    * @ Description : Order Class
    */
    public class Order {
        @AuraEnabled public String id                   {get; set;}
        @AuraEnabled public String seq                  {get; set;} //대리점 구매 요청 주문번호
        @AuraEnabled public String customerOrderSeq       {get; set;} //DealerOrder 주문번호
        @AuraEnabled public String customerOrerNumber   {get; set;} //구매요청번호 CustomerPurchaseOrderNumber__c
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
        @AuraEnabled public String dealer               {get; set;} //Dealer__c
        @AuraEnabled public String dealerName           {get; set;} //Dealer__r.Name
        @AuraEnabled public String customerCode         {get; set;} //요청 대리점고객
        @AuraEnabled public String customer             {get; set;} //요청 대리점고객 DealerCustomer__c
        @AuraEnabled public String customerName         {get; set;} //요청 대리점고객 DealerCustomer__r.Name
        @AuraEnabled public String bulkShipping         {
            get {
                if(String.isBlank(this.bulkShipping)) this.bulkShipping = 'N';
                return this.bulkShipping;
            }
            set;
        }
        @AuraEnabled public String customerShipToCode   {get; set;} //일반고객일 경우만 값이 존재 (9999999999)
        @AuraEnabled public String customerShipTo       {get; set;} //ShipToCode__c
        @AuraEnabled public String customerShipToName   {get; set;} //일반 고객 및 대리점 고객의  FullAddress
        @AuraEnabled public String shipToName           {get; set;}
        @AuraEnabled public String postalCode           {get; set;} //우편번호
        @AuraEnabled public String city                 {get; set;} //CITY1 기본주소
        @AuraEnabled public String street               {get; set;} //STREET 상세주소
        @AuraEnabled public String phone                {get; set;} //
        @AuraEnabled public String representative       {get; set;} //대표자명
        @AuraEnabled public String shippingType         {
            get {
                if(String.isBlank(this.shippingType)) this.shippingType = '1';
                return this.shippingType;
            } 
            set;
        } //배송방법
        @AuraEnabled public String priority             {get; set;}
        @AuraEnabled public Date orderDate              {get; set;}
        @AuraEnabled public List<OrderItem> itemList    {
            get {
                if(itemList == null) itemList = new List<OrderItem>();
                return itemList;
            }
            set;
        }

        /*
        * @ Class : Order
        * @ Description : Order Class
        */
        public Order() {}
        public Order(String purchaseRecordId) {
            DealerPurchaseOrder__c orderSObject = [
                SELECT
                    Id,
                    OrderNumber__c,
                    FM_OrderDate__c,
                    SalesOrganization__c,
                    DistributionChannel__c,
                    Division__c,
                    CustomerPurchaseOrderNumber__c,
                    Dealer__c,
                    Dealer__r.Name,
                    Customer__c,
                    Customer__r.Name,
                    CustomerCode__c,
                    FM_CustomerName__c,
                    BulkShipping__c,
                    Address__City__s,
                    Address__PostalCode__s,
                    Address__CountryCode__s,
                    Phone__c,
                    Representative__c,
                    ShippingType__c,
                    Priority__c,
                    RoadAddr__c, 
                    DetailInfo__c,
                    CustomerShipTo__c,
                    CustomerShipToCode__c,
                    CustomerShipTo__r.Address__PostalCode__s,
                    CustomerShipTo__r.RoadAddr__c, 
                    CustomerShipTo__r.DetailInfo__c,
                    FM_ShipToName__c,
                    Delete__c,
                    (
                        SELECT
                        Id,
                        DealerPurchaseOrder__c,
                        FM_OrderNumber__c,
                        OrderItemNumber__c,
                        Part__c,
                        Part__r.Name,
                        Part__r.FM_MaterialDetails__c,
                        ReplacingPart__c,
                        ReplacingPart__r.Name,
                        ReplacingPart__r.FM_MaterialDetails__c,
                        Quantity__c,
                        FM_Unit__c,
                        CurrentStockQuantity__c,
                        GICompletedQuantity__c,
                        FM_PendingQuantity__c,
                        SaleQuantityUnit__c,
                        CustomerPrice__c,
                        DiscountPrice__c,
                        FM_DiscountAmount__c,
                        DiscountRate__c,
                        Status__c,
                        toLabel(Status__c) statusLabel,
                        FM_DeliveryStatus__c,
                        Delete__c,
                        GRStatus__c,
                        MachineName__c,
                        Equipment__c,
                        ChangeQuantity__c, 
                        LastHistory__c,
                        CurrencyIsoCode
                        FROM Item__r 
                        WHERE Delete__c != 'Y' 
                    )
                FROM DealerPurchaseOrder__c
                WHERE Id = :purchaseRecordId
            ];
            this.initialize(orderSObject);

            for(DealerPurchaseOrderItem__c item : orderSObject.Item__r) {   
                itemList.add(new OrderItem(item));
            }
            
        }

        public Order(DealerPurchaseOrder__c po) {
            this.initialize(po);

            for(DealerPurchaseOrderItem__c item : po.Item__r) {
                itemList.add(new OrderItem(item));
            }
        }

        /*
        * @ Method : initialize
        * @ Description : DealerPurchaseOrder__c를 Class에 매핑
        */
        private void initialize(DealerPurchaseOrder__c order) {
            this.id                      =  order.Id;
            this.seq                     =  order.OrderNumber__c;
            this.customerOrerNumber      =  order.CustomerPurchaseOrderNumber__c;
            this.customerCode            =  order.CustomerCode__c;
            this.customer                =  order.Customer__c;
            this.customerName            =  order.FM_CustomerName__c;
            this.bulkShipping            =  order.BulkShipping__c;
            this.customerShipToCode      =  order.CustomerShipToCode__c;
            this.customerShipTo          =  order.CustomerShipTo__c;
            this.customerShipToName      =  order.FM_ShipToName__c;
            this.postalCode              =  order.Address__PostalCode__s;
            this.city                    =  order.RoadAddr__c;
            this.street                  =  order.DetailInfo__c;
            this.phone                   =  order.Phone__c;
            this.representative          =  order.Representative__c;
            this.shippingType            =  order.ShippingType__c;
            this.priority                =  order.Priority__c;
            this.salesOrganization       =  order.SalesOrganization__c;
            this.distributionChannel     =  order.DistributionChannel__c;
            this.division                =  order.Division__c;
            this.dealer                  =  order.Dealer__c;
            this.dealerName              =  order.Dealer__r.Name;
            this.orderDate               =  order.FM_OrderDate__c;
            Map<String, Object> fieldsValueMap = order.getPopulatedFieldsAsMap();
            if(fieldsValueMap.containsKey('CustomerShipTo__r')) {
                this.postalCode              =  order.CustomerShipTo__r.Address__PostalCode__s;
                this.city                    =  order.CustomerShipTo__r.RoadAddr__c;
                this.street                  =  order.CustomerShipTo__r.DetailInfo__c;
            }
        }

        /*
        * @ Method : convertToSObject
        * @ Description : Class에 데이터를 DealerPurchaseOrder__c로 변환
        */
        public DealerPurchaseOrder__c convertToSObject() {
            DealerPurchaseOrder__c order = new DealerPurchaseOrder__c(
                Id                              = id,
                OrderNumber__c                  = seq,          
                CustomerPurchaseOrderNumber__c  = customerOrerNumber,
                SalesOrganization__c            = salesOrganization,
                DistributionChannel__c          = distributionChannel,
                Division__c                     = division,
                Customer__c                     = customer,
                BulkShipping__c                 = bulkShipping,
                CustomerShipToCode__c           = customerShipToCode,
                CustomerShipTo__c               = customerShipTo,
                CustomerShipToName__c           = shipToName,
                Address__PostalCode__s          = postalCode,
                RoadAddr__c                     = city,              
                DetailInfo__c                   = street,            
                Phone__c                        = phone,             
                Representative__c               = representative,    
                ShippingType__c                 = shippingType,
                Priority__c                     = priority,       
                Address__CountryCode__s         = 'KR'   
            );
            System.debug('order.CustomerShipToName__c : ' + order.CustomerShipToName__c);

            order.SalesOrganization__c      = (String.isBlank(salesOrganization)) ? currentUser.getSalesOranization() : salesOrganization;
            order.DistributionChannel__c    = (String.isBlank(distributionChannel)) ? currentUser.getDistributionChannel() : distributionChannel;
            order.Division__c               = (String.isBlank(division)) ? currentUser.getDivision() : division;
            order.Dealer__c                 = (String.isBlank(dealer)) ? currentUser.getAgencyId() : dealer;

            //TODO: 화면 로직에서 처리한다면 제거가능
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
        }//출고량
        @AuraEnabled public Decimal currentStockQuantity {
            get{
                if(currentStockQuantity == null) currentStockQuantity = 0;
                return currentStockQuantity;
            } 
            set;
        } //현재고
        @AuraEnabled public Decimal pendingQuantity {
            get{
                if(pendingQuantity == null) pendingQuantity = 0;
                return pendingQuantity;
            } 
            set;
        } //미결 수량
        
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
        @AuraEnabled public String deliveryStatus        {get; set;}
        @AuraEnabled public Boolean isDisabledChange = false; //항목 선택 및 요청 수량 입력 불가
        @AuraEnabled public Decimal changeQuantity       {
            get{
                if(changeQuantity == null) changeQuantity = 0;
                 return changeQuantity;
            }
            set;
        }//변경요청
        @AuraEnabled public Decimal finalChangeQuantity       {
            get{
                if(finalChangeQuantity == null) finalChangeQuantity = 0;
                 return finalChangeQuantity;
            }
            set;
        }// 최종요청수량 = 수량 + 변경요청수량
        @AuraEnabled public String lastHistoryId {get; set;}
        @AuraEnabled public String deleteYN              {get; set;} // Y/N

        /*
        * @ Class : OrderItem
        * @ Description : OrderItem Class
        */
        public OrderItem(){}
        public OrderItem(DealerPurchaseOrderItem__c orderItem){
            this.orderId              = orderItem.DealerPurchaseOrder__c;
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
            this.unit                 = orderItem.FM_Unit__c;
            this.salesUnit            = orderItem.SaleQuantityUnit__c;
            this.currencyCode         = orderItem.CurrencyIsoCode;
            this.customerPrice        = orderItem.CustomerPrice__c;
            this.discountPrice        = orderItem.DiscountPrice__c;
            this.discountAmount       = orderItem.FM_DiscountAmount__c;
            this.discountRate         = orderItem.DiscountRate__c;
            this.machineName          = orderItem.MachineName__c;
            this.equipment            = orderItem.Equipment__c;
            this.currentStockQuantity = orderItem.CurrentStockQuantity__c;
            this.status               = orderItem.Status__c;
            this.statusLabel          = String.valueOf(orderItem.get('statusLabel'));

            this.giQuantity           = orderItem.GICompletedQuantity__c;
            this.changeQuantity       = orderItem.ChangeQuantity__c;
            this.lastHistoryId        = orderItem.LastHistory__c;
            this.finalChangeQuantity  = quantity + changeQuantity;
            this.pendingQuantity      = orderItem.getPopulatedFieldsAsMap().containsKey('FM_PendingQuantity__c') ? orderItem.FM_PendingQuantity__c : null;
            this.deliveryStatus       = orderItem.getPopulatedFieldsAsMap().containsKey('FM_DeliveryStatus__c') ? orderItem.FM_DeliveryStatus__c : '';

            switch on status {
                when '1','2','5' { //생성요청, 변경 요청일 경우 항목 선택 및 요청 수량 입력 불가
                    isDisabledChange = true;
                }
            }
            //고객 주문서 출고시 변경요청 및 삭제요청 불가능
            if(giQuantity != null && giQuantity > 0) isDisabledChange = true;
        }

        /*
        * @ Class : convertToSObject
        * @ Description : DealerPurchaseOrderItem__c로 변환
        */
        public DealerPurchaseOrderItem__c convertToSObject() {
            DealerPurchaseOrderItem__c orderItem = new DealerPurchaseOrderItem__c(
                OrderItemNumber__c      = this.itemSeq,
                Part__c                 = this.part,
                ReplacingPart__c        = this.replacingPart,
                Quantity__c             = this.quantity,
                CurrencyIsoCode         = this.currencyCode,
                SaleQuantityUnit__c     = this.salesUnit,
                CustomerPrice__c        = this.customerPrice,
                DiscountPrice__c        = this.discountPrice,
                DiscountRate__c         = this.discountRate,
                MachineName__c          = this.machineName,
                Equipment__c            = this.equipment,
                ChangeQuantity__c       = this.changeQuantity
            );
            if(String.isNotBlank(itemId)) orderItem.Id          = this.itemId;
            
            if(orderItem.DiscountRate__c == null || orderItem.DiscountRate__c == 0) {
                orderItem.DiscountPrice__c = orderItem.CustomerPrice__c;
            }

            // orderItem.DiscountPrice__c = roundAndFloorToTen(orderItem.DiscountPrice__c);

            return orderItem;
        }

        public DealerPurchaseOrderItem__c convertToSObject(String orderId) {
            DealerPurchaseOrderItem__c orderItem = convertToSObject();
            orderItem.DealerPurchaseOrder__c = orderId;
            return orderItem;
        }
    }

    public enum StatusCode { SUCCESS, ERROR }
    /*
    * @ Class : StatusInfo
    * @ Description : StatusInfo Class
    */
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