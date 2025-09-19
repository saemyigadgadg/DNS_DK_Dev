/** 
 * @Class : DN_OrderedGITableController
 * 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2024. 12. 31. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-31 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_OrderedGITableController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @Description
     * 	- 데이터 조회
    **/ 
    @AuraEnabled
    public static List<GoodsIssue> getDataList(SearchFilter search, List<String> urlParamIds){
        try {
            System.debug(search + ' :":: search');
            set<String> partIds = new set<String>();
            set<String> orderIds = new set<String>();
            List<GoodsIssue> returnGoodsIssueList = new List<GoodsIssue>();
            String query='select Id,FM_OrderNumber__c,Order__r.Dealer__r.Name,OrderItemNumber__c,Part__r.ProductCode,Part__r.Name,Part__r.FM_MaterialDetails__c,Quantity__c';
                    query+= ' ,Order__r.Customer__r.Name,Order__r.FM_CustomerName__c, Part__c,Order__r.Id,Order__r.Customer__c'; 
                    query+= ' ,Order__r.FM_ShipToCode__c,Order__r.FM_Phone__c,ReplacingPart__c,ReplacingPart__r.ProductCode,ReplacingPart__r.FM_MaterialDetails__c ';
                    query +=' from DealerOrderItem__c';
                    query +=' where Order__r.Dealer__c = \''+currentUser.getAgencyId()+'\' AND Part__c !=null ';
                    query += ' AND FM_PendingQuantity__c > 0 ';
                    query += ' AND Delete__c !=\'Y\'';
                    //query += ' AND Status__c !=\'C\'';
                    if(urlParamIds.size() > 0) {
                        query += ' AND Id IN :urlParamIds';
                    } else {
                        // 주문일자 필터
                        List<String> startSet = search.dateStart.split('-');
                        List<String> endSet = search.dateEnd.split('-');
                        Date startDate = Date.newInstance(Integer.valueOf(startSet[0]), Integer.valueOf(startSet[1]), Integer.valueOf(startSet[2]));
                        Date endDate = Date.newInstance(Integer.valueOf(endSet[0]), Integer.valueOf(endSet[1]), Integer.valueOf(endSet[2]));            
                        query +=' AND (Order__r.FM_OrderDate__c >=:startDate AND Order__r.FM_OrderDate__c <=:endDate )';
                    }
                    
                    
                    // 주문번호
                    if(String.isNotBlank(search.orderNumber)) {
                        query +=' AND FM_OrderNumber__c LIKE \'%'+search.orderNumber +'%\'';
                    }
                    // 주문품번
                    if(String.isNotBlank(search.productCode)) {
                        query += ' AND ReplacingPart__c =\''+search.productCode+ '\'';
                    }
                    // 고객사명
                    if(String.isNotBlank(search.accountId)) {
                        if(search.accountId =='9999999999') {
                            query += ' AND Order__r.CustomerCode__c =\''+search.accountId+ '\'';
                        } else {
                            query += ' AND Order__r.Customer__c =\''+search.accountId+ '\'';
                        }
                        
                    }
                    System.debug(query + ' :::: query');
                    List<DealerOrderItem__c> orderList = Database.query(query);
                    System.debug(orderList + ' < +=orderList');
                    // 주문정보
                    for(DealerOrderItem__c deal : orderList) {
                        partIds.add(deal.ReplacingPart__c);
                        orderIds.add(deal.Id);
                        GoodsIssue goods = new GoodsIssue(deal);
                        System.debug(goods + ' <==goods');
                        returnGoodsIssueList.add(goods);
                    }
                    // 재고
                    Map<String,Decimal> stockMap = new Map<String,Decimal>();
                    List<DealerStock__c> stockList = 
                    [
                        select Id, Part__c, CurrentStockQuantity__c
                        from DealerStock__c 
                        where Part__c IN : partIds 
                        AND Dealer__c =:currentUser.getAgencyId()      
                    ];
                    for(DealerStock__c stc : stockList) {
                        stockMap.put(stc.Part__c, stc.CurrentStockQuantity__c);
                    } 
                    // 출고지시 수량 합산
                    Map<String,Decimal> shipAggreMap = new Map<String,Decimal>();
                    List<AggregateResult> shipList = [
                        select DealerOrderItem__c, SUM(Quantity__c)Quantity__c
                        from ShipmentOrder__c
                        where Delete__c ='N'
                        AND DealerOrderItem__c IN : orderIds
                        AND Dealer__c =:currentUser.getAgencyId()
                        group by DealerOrderItem__c
                    ];
                    for(AggregateResult ship : shipList) {
                        shipAggreMap.put((String) ship.get('DealerOrderItem__c'), (Decimal) ship.get('Quantity__c'));
                    }
                    // 출고 정보
                    Map<String,Decimal> goodsIssueMap = new Map<String,Decimal>();
                    List<AggregateResult> goodsIssueList = [
                        select DealerOrderItem__c,SUM(Quantity__c)Quantity__c 
                        from DealerInventoryMovements__c  
                        where RecordType.DeveloperName = 'GoodsIssue' 
                        AND InventoryChange__c ='H'
                        AND DealerOrderItem__c IN : orderIds
                        group by DealerOrderItem__c 
                    ];
                    for(AggregateResult ages : goodsIssueList) {
                        goodsIssueMap.put((String) ages.get('DealerOrderItem__c'), (Decimal) ages.get('Quantity__c'));
                    }
                    // 서치옵션에 따라 데이터 담기
                    List<GoodsIssue> returnGoodsIssueSetList = new List<GoodsIssue>();
                    // 계산 필드 매핑
                    for(GoodsIssue goods : returnGoodsIssueList) {
                        
                        //DealerStock__c stock = stockMap.get(goods.partId) == null ? new DealerStock__c() : stockMap.get(goods.partId);
                        goods.currentStockQuantity = stockMap.get(goods.partId) == null ? 0 : stockMap.get(goods.partId);
                        if(goods.currentStockQuantity > 0) { // 재고가 있는 것들만
                            // 출고지시 매핑
                            goods.gIOrderCompletedQTY = shipAggreMap.get(goods.orderItemId) ==null ? 0 :shipAggreMap.get(goods.orderItemId);
                            goods.gIOrderNotQTY = goods.quantity- goods.gIOrderCompletedQTY;
                            goods.gIOrderPossibleQty = goods.quantity- goods.gIOrderCompletedQTY;
                            //출고 매핑
                            goods.gICompletedQTY = goodsIssueMap.get(goods.orderItemId) == null ? 0 : goodsIssueMap.get(goods.orderItemId);
                            goods.gIPossibleQty = goods.quantity - goods.gICompletedQTY;
                            if(goods.gIPossibleQty > goods.currentStockQuantity) {
                                goods.gIPossibleQty = goods.currentStockQuantity;
                            }
                            if(goods.gIOrderPossibleQty > goods.currentStockQuantity) {
                                goods.gIOrderPossibleQty = goods.currentStockQuantity;
                            }
                            goods.gINotQTY = goods.quantity - goods.gICompletedQTY;
                            goods.gIDescription ='';
                            goods.printDate = Date.today();
                            // searchOption
                            if(search.searchOption !='All') { //검색옵션
                                if(search.searchOption =='0') { //DO Finish QTY > 0   /// 기출고지시 수량이 !=0
                                    
                                    if(goods.gIOrderCompletedQTY != 0) {
                                        returnGoodsIssueSetList.add(goods);
                                    }
                                } else { //DO Pending QTY > 0   /// 미출고지시수량이 != 0>
                                    if(goods.gIOrderNotQTY !=0) {
                                        returnGoodsIssueSetList.add(goods);
                                    }
                                }
                            } else {
                                returnGoodsIssueSetList.add(goods);
                            }
                        }
                        
                        
                    }
                    

            return returnGoodsIssueSetList;
        } catch (Exception e) {
            System.debug(e.getMessage()+' <== message');
            System.debug(e.getLineNumber()+' <== getLineNumber');
            throw new DN_OrderedGITableControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 출고 지시
    **/ 
    @AuraEnabled
    public static List<ShipExcel> insertShipmentOrder(List<ShipmentOrder> shipList){
        try {
            if(shipList.size() ==0) {
                throw new DN_OrderedGITableControllerException('출고지시할 항목을 선택해주세요.');
            }
            List<ShipmentOrder__c> dmlShipmentOrderList = new List<ShipmentOrder__c>();            
            set<String> dealerOrderIds = new set<String>();
            Map<String,ShipmentOrder> shipMap = new Map<String,ShipmentOrder>();
            for(ShipmentOrder shipOrder : shipList) {
                dealerOrderIds.add(shipOrder.orderItemId);
                shipMap.put(shipOrder.orderItemId, shipOrder);
            }
            List<DealerOrderItem__c> orderList = 
                [ 
                    select Id,Part__c,CustomerPrice__c,
                    Part__r.Unit__c,
                    DiscountPrice__c,FM_DiscountAmount__c,CurrencyIsoCode,
                    tolabel(Order__r.ShippingType__c) ShippingType__c
                    from DealerOrderItem__c
                    where Id IN : dealerOrderIds FOR UPDATE
                ];
            //채번
            SequenceGenerator seqGenerator = new SequenceGenerator('ShipmentOrder__c');
            String grNumber = seqGenerator.generate('ShipmentOrder');
            Map<String,String> shippingMap = new Map<String,String>();
            Integer i = 10; 
            for(DealerOrderItem__c order : orderList) {
                ShipmentOrder ship = shipMap.get(order.Id);
                ShipmentOrder__c shipOrderInsert = new ShipmentOrder__c(); 
                shipOrderInsert.DealerOrderItem__c              = order.Id;
                shipOrderInsert.ShipmentOrderNumber__c          = String.valueOf(i);
                shipOrderInsert.SalesOrganization__c            = currentUser.getSalesOranization();
                shipOrderInsert.DistributionChannel__c          = currentUser.getDistributionChannel();
                shipOrderInsert.Division__c                     = currentUser.getDivision();
                shipOrderInsert.Dealer__c                       = currentUser.getAgencyId();
                shipOrderInsert.Quantity__c                     = ship.quantity;
                shipOrderInsert.GoodsIssueHistory__c            = ship.goodsIssueHistory;
                shipOrderInsert.CustomerPrice__c                = order.CustomerPrice__c;
                shipOrderInsert.DiscountPrice__c                = order.DiscountPrice__c;
                shipOrderInsert.DiscountAmount__c               = order.FM_DiscountAmount__c;
                shipOrderInsert.CurrencyIsoCode                 = order.CurrencyIsoCode;
                //shipOrderInsert.Unit__c                         = order.Part__r.Unit__c;
                shipOrderInsert.DeliveryOrder__c                = grNumber;
                System.debug(order.Order__r.ShippingType__c + ' :: order.Order__r.ShippingType__c');
                String shippingType = (String)order.Order__r.ShippingType__c;
                shippingMap.put(order.Id, shippingType);
                dmlShipmentOrderList.add(shipOrderInsert);
                i = i+ 10;
            }
            if(dmlShipmentOrderList.size() > 0) {
                insert dmlShipmentOrderList;
            }
            // 채번 업데이트
            seqGenerator.updateNextSequenceInfo();
            set<String> shipIds = new set<String>();
            for(ShipmentOrder__c ship :dmlShipmentOrderList) {
                shipIds.add(ship.Id);
            }
            List<ShipmentOrder__c> returnshipList = [
                select Id, 
                Name,
                DealerOrderItem__r.Order__r.FM_CustomerName__c,
                DeliveryOrder__c,
                FM_DeliveryDate__c,
                FM_DeliveryTime__c,
                DealerOrderItem__r.Order__r.FM_ShipToName__c,
                DealerOrderItem__r.Order__r.FM_Representative__c,
                DealerOrderItem__r.Order__r.FM_PostalCode__c,
                DealerOrderItem__r.Order__r.FM_Phone__c,
                CreatedDate,
                toLabel(DealerOrderItem__r.Order__r.ShippingType__c),
                DealerOrderItem__r.Order__r.OrderNumber__c,
                DealerOrderItem__r.Part__r.ProductCode,
                DealerOrderItem__r.Part__r.Name, //FM_MaterialDetails__c
                DealerOrderItem__r.Part__r.FM_MaterialDetails__c,
                DealerOrderItem__r.Part__c,
                Quantity__c,
                DealerOrderItem__r.Order__r.CustomerPurchaseOrderNumber__c
                from ShipmentOrder__c where Id IN : shipIds
            ];
            set<String> partIds = new set<String>();
            System.debug(returnshipList + ':::returnshipList');
            Map<String,String> locationMap = new Map<String,String>();
            for(ShipmentOrder__c shipt : returnshipList) {
                partIds.add(shipt.DealerOrderItem__r.Part__c);
            }
            List<DealerStock__c> stockList = [
                select 
                Id,Name,Part__c,
                DealerLocation__c,
                DealerLocation__r.FM_Loc__c
                from DealerStock__c 
                where Part__c IN:partIds 
                AND Dealer__c =:currentUser.getAgencyId() AND DealerLocation__c !=null
            ];
            for(DealerStock__c stock : stockList) {
                locationMap.put(stock.Part__c,stock.DealerLocation__r.FM_Loc__c);
            }

            List<ShipExcel> excelList = new List<ShipExcel>();
            for(ShipmentOrder__c orders : returnshipList) {
                System.debug(orders + ' !!!orders');
                ShipExcel excel = new ShipExcel(orders);
                System.debug(shippingMap + ' ::: shippingMap');
                //excel.shippingType = shippingMap.get(orders.Id);
                //shippingMap
                excel.location = locationMap.get(orders.DealerOrderItem__r.Part__c) == null ? '' : locationMap.get(orders.DealerOrderItem__r.Part__c);
                excelList.add(excel);
            }
            
           
            return excelList;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new DN_OrderedGITableControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 출고완료 처리
    **/ 
    @AuraEnabled
    public static List<DealerInventoryMovements__c> insertGoodsIssue(List<GoodsIssue> goodsIssue){
        try {
            set<String> orderIds = new set<String>();
            set<String> orderItemIds = new set<String>();
            Map<String,goodsIssue> goodIssueMap = new Map<String,goodsIssue>();
            Map<String,Decimal> stokMap = new Map<String,Decimal>();
            System.debug(goodsIssue  +' :: goodsIssue');
            for(GoodsIssue good : goodsIssue) {
                if(stokMap.get(good.partId) !=null) {
                    stokMap.put(good.partId, -good.gIPossibleQty + stokMap.get(good.partId));
                } else {
                    stokMap.put(good.partId, -good.gIPossibleQty);
                }
                orderIds.add(good.orderId);
                orderItemIds.add(good.orderItemId);
                goodIssueMap.put(good.orderItemId, good);
            }
            String strQuery = 'SELECT SUM(Quantity__c) QTY, MAX(DealerOrderItem__r.GICompletedQuantity__c) GIQTY,MAX(DealerOrderItem__r.Quantity__c) orderQTY, MAX(DealerOrderItem__r.OrderItemNumber__c) orderItemNumber,MAX(DealerOrderItem__r.Order__r.OrderNumber__c) orderNumber, DealerOrderItem__c Parrent FROM DealerInventoryMovements__c WHERE DealerOrderItem__c !=null ';
            strQuery += ' AND DealerOrderItem__c IN(\''+String.join(goodIssueMap.keySet(), '\',\'') + '\')';
            strQuery += ' GROUP BY DealerOrderItem__c ';
            String dmlQuey = 'SELECT Id FROM DealerOrderItem__c WHERE Id IN(\''+String.join(goodIssueMap.keySet(), '\',\'') + '\') FOR UPDATE';
            Map<String,Object> isCheck = DN_DealerStockManager.duplicationCheck(strQuery,dmlQuey);
            System.debug(isCheck + ' :: isCheck');
            if((Boolean)isCheck.get('isCheck')) {
                AggregateResult orderResult = (AggregateResult)isCheck.get('orders');
                if(orderResult.get('orderQTY') == orderResult.get('GIQTY')) {
                    throw new DN_OrderedGITableControllerException(orderResult.get('orderNumber') +' / '+orderResult.get('orderItemNumber')+'의 출고수량이 오더수량을 초과합니다.');
                }   
            }
            List<DealerOrderItem__c> orderItem = [
                select Id,
                ReplacingPart__c,
                Order__c,
                Order__r.Dealer__c,
                FM_Unit__c,
                Quantity__c,
                FM_DiscountAmount__c,
                CustomerPrice__c,
                OrderItemNumber__c,
                DiscountPrice__c,
                GICompletedQuantity__c
                from DealerOrderItem__c where Id IN:orderItemIds FOR UPDATE
            ];
            set<String> orderIdList = new set<String>();
            set<String> partIds = new set<String>();
           
            for(DealerOrderItem__c items : orderItem) {
                partIds.add(items.ReplacingPart__c);
            }

            List<AggregateResult> orderResult = [select Order__c,SUM(Quantity__c) Quantity__c, SUM(GICompletedQuantity__c) GICompletedQuantity__c  from DealerOrderItem__c where Order__c =:orderIds group by Order__c ];
            
            List<DealerStock__c> currentStock = [select Id, Name,DealerLocation__c,DealerLocation__r.FM_Loc__c,Part__c from DealerStock__c where Part__c IN: partIds AND Dealer__c =:currentUser.getAgencyId()];
            Map<String,String> currentStockMap = new Map<String,String>();
            Map<String,String> currentStockIds = new Map<String,String>();
            for(DealerStock__c stock : currentStock) {
                currentStockIds.put(stock.Part__c, stock.Id);
                if(stock.get('DealerLocation__c') !=null) {
                    currentStockMap.put(stock.Part__c, stock.DealerLocation__c); 
              }
                
            }
            System.debug( currentStockIds + ' ::: currentStockIds');
            System.debug(currentStockMap + ' :: Location__c');
            RecordType recType = [select Id, Name, DeveloperName from RecordType where RecordType.DeveloperName ='GoodsIssue'];
            //채번
            SequenceGenerator seqGenerator = new SequenceGenerator('DealerInventoryMovements__c');
            String grNumber = seqGenerator.generate(recType.DeveloperName);
            List<DealerInventoryMovements__c> inventoryList = new List<DealerInventoryMovements__c>();
            for(DealerOrderItem__c org : orderItem) {
                DealerInventoryMovements__c  insertGoodsIssue = new DealerInventoryMovements__c();    
                insertGoodsIssue.RecordTypeId = recType.Id;
                insertGoodsIssue.DealerOrderItem__c = org.Order__c;
                insertGoodsIssue.Part__c = org.ReplacingPart__c;
                insertGoodsIssue.Type__c = 'S';
                insertGoodsIssue.SalesOrganization__c = currentUser.getSalesOranization();
                insertGoodsIssue.DistributionChannel__c = currentUser.getDistributionChannel();
                insertGoodsIssue.Division__c = currentUser.getDivision();
                insertGoodsIssue.Dealer__c = currentUser.getAgencyId();
                insertGoodsIssue.Location__c = currentStockMap.get(org.ReplacingPart__c);
                insertGoodsIssue.DealerStock__c = currentStockIds.get(org.ReplacingPart__c);
                insertGoodsIssue.InventoryItemNumber__c  = goodIssueMap.get(org.Id).itemNumber;
                insertGoodsIssue.InventoryNumber__c = grNumber;
                insertGoodsIssue.InventoryChange__c = 'H';
                insertGoodsIssue.Quantity__c = goodIssueMap.get(org.Id).gIPossibleQty;
                insertGoodsIssue.DealerOrderItem__c = org.Id;
                insertGoodsIssue.Comment__c = goodIssueMap.get(org.Id).gIDescription;
                insertGoodsIssue.CustomerPrice__c = org.CustomerPrice__c;
                insertGoodsIssue.DiscountPrice__c = org.DiscountPrice__c;
                insertGoodsIssue.DiscountAmount__c = org.DiscountPrice__c * insertGoodsIssue.Quantity__c;
                inventoryList.add(insertGoodsIssue);
                // 오더 아이템 정보
                org.GICompletedQuantity__c = org.GICompletedQuantity__c + goodIssueMap.get(org.Id).gIPossibleQty;
                if(org.GICompletedQuantity__c == org.Quantity__c) {
                    org.Status__c = 'C'; //출고완료
                    org.GICompletedDateTime__c = DateTime.now();
                } else {
                    org.Status__c = 'P'; //부분출고
                }    
            }
            insert inventoryList;
            update orderItem;
            List<DealerOrder__c> delaerOrder = new List<DealerOrder__c>();
            // 오더상태값 변경
            for(AggregateResult delOrder : orderResult) {
                Boolean isOrderFlag = false;
                if((Decimal) delOrder.get('Quantity__c') == (Decimal)delOrder.get('GICompletedQuantity__c')) {
                    isOrderFlag = true;
                }
                DealerOrder__c order = new DealerOrder__c();
                order.Id = String.valueOf(delOrder.get('Order__c'));
                if(isOrderFlag) {
                    order.Status__c ='P'; //출고 완료
                } else {
                    order.Status__c ='c'; //부분 출고
                }
                delaerOrder.add(order);
            }
            update delaerOrder;
            // 재고 업데이트
            DN_DealerStockManager.getAvailable(stokMap, 'GI','');
            // 채번 업데이트
            seqGenerator.updateNextSequenceInfo();
            return inventoryList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' < ==e.getMessage()');
            System.debug(e.getStackTraceString() + ' < ==e.getStackTraceString()');
            throw new DN_OrderedGITableControllerException(e.getMessage());
        }
    }
    
    

    /**
     * @Description
     * 	- 검색조건 클래스
    **/ 
    public class SearchFilter {
        @AuraEnabled public String orderNumber {get;set;} // 주문번호
        @AuraEnabled public String productCode {get;set;} // 주문품번
        @AuraEnabled public String accountId {get;set;} // 고객사명
        @AuraEnabled public String dateStart {get;set;} // 주문일자 - 시작
        @AuraEnabled public String dateEnd {get;set;} // 주문일자 - 종료
        @AuraEnabled public String searchOption {get;set;} // searchOption (출고지시 여부)
    }


    /**
     * @Description
     * 	- 출고지시 클래스
    **/ 
    public class ShipmentOrder {
        public ShipmentOrder() {}
        @AuraEnabled public String orderItemId {get;set;} // 딜러 아이템 Id
        @AuraEnabled public String goodsIssueHistory {get;set;} // 출고지시내역
        @AuraEnabled public Decimal quantity {get;set;} // 출고지시 수량
    }


    /**
     * @Description
     * 	- 주문출고 조회 클래스
    **/
    public class GoodsIssue {
        @AuraEnabled public String orderId {get;set;} // 딜러 주문 Id 
        @AuraEnabled public String orderItemId {get;set;} // 딜러 아이템 Id
        @AuraEnabled public String orderNumber {get;set;} // 주문번호 FM_OrderNumber__c
        @AuraEnabled public String accountName {get;set;} // 고객사명 Order__r.Dealer__r.Name
        @AuraEnabled public String accountId {get;set;} // 고객사Id Order__r.Dealer__r.Name
        @AuraEnabled public String itemNumber {get;set;} // 항목 OrderItemNumber__c
        @AuraEnabled public String partNumber {get;set;} // 주문품번 Part__r.ProductCode
        @AuraEnabled public String partName {get;set;} // 품명 Part__r.FM_MaterialDetails__c
        @AuraEnabled public String partId {get;set;} // 부품 Id
        @AuraEnabled public Decimal quantity {get;set;} // 주문수량 Quantity__c
        @AuraEnabled public String gIDescription {get;set;} // 출고내역
        @AuraEnabled public Date printDate {get;set;} // 출력날짜
        @AuraEnabled public String shipToCode {get;set;} // 배송처 코드
        @AuraEnabled public String shipToPhone {get;set;} // 배송처 담당자 번호
        // 딜러재고
        @AuraEnabled public Decimal currentStockQuantity {get;set;} // 현재고
        // 출고지시
        @AuraEnabled public Decimal gIOrderCompletedQTY {get;set;} // 기출고지시수량 = 출고지시 수량 합
        @AuraEnabled public Decimal gIOrderNotQTY {get;set;} // 미출고지시수량 = 주문수량 - 기출고지시 수량
        @AuraEnabled public Decimal gIOrderPossibleQty {get;set;} //출고지시가능 = 주문수량 - 기출고지시 수량 // 현재고가 클 경우 현재고
        //출고 계산식
        @AuraEnabled public Decimal gIPossibleQty {get;set;} // 출고가능수량 = 주문수량 - 기출고수량 // 현재고가 클 경우 현재고
        @AuraEnabled public Decimal gICompletedQTY {get;set;} // 기출고수량 = 출고 수량 합
        @AuraEnabled public Decimal gINotQTY {get;set;} // 미출고수량 = 주문수량-기출고수량
        
        public GoodsIssue() {}
        // 주문정보 매핑
        public GoodsIssue(DealerOrderItem__c dealerItem) { 
            System.debug(dealerItem + ' ::: dealerItem');
            this.orderId                = dealerItem.Order__r.Id;
            this.orderItemId            = dealerItem.Id;
            this.orderNumber            = dealerItem.FM_OrderNumber__c;
            this.accountName            = dealerItem.Order__r.FM_CustomerName__c;
            this.accountId              = dealerItem.Order__r.Customer__c ==null ? '' : dealerItem.Order__r.Customer__c;
            this.itemNumber             = dealerItem.OrderItemNumber__c;
            this.partNumber             = dealerItem.ReplacingPart__r.ProductCode;
            this.partName               = dealerItem.ReplacingPart__r.FM_MaterialDetails__c;//dealerItem.Part__r.FM_MaterialDetails__c;
            this.partId                 = dealerItem.ReplacingPart__c;
            this.quantity               = dealerItem.Quantity__c; 
            this.shipToCode             = dealerItem.Order__r.FM_ShipToCode__c; //Order__r.FM_ShipToCode__c
            this.shipToPhone            = dealerItem.Order__r.FM_Phone__c; //Order__r.FM_Phone__c
        }
    }
    
    /**
     * @Description
     * 	- 출고지시 엑셀 데이터
    **/
    public class ShipExcel {
        @AuraEnabled public String accountName {get;set;}               
        @AuraEnabled public String deliveryOrderNumber {get;set;}           
        @AuraEnabled public String deliveryDate {get;set;} 
        @AuraEnabled public String deliveryTime {get;set;} 
        @AuraEnabled public String address {get;set;} 
        @AuraEnabled public String postalCode {get;set;} 
        @AuraEnabled public String representative {get;set;} 
        @AuraEnabled public String phone {get;set;} 
        @AuraEnabled public String shippingType {get;set;} 
        @AuraEnabled public String orderNumber {get;set;} 
        @AuraEnabled public String partNumber {get;set;} 
        @AuraEnabled public String partName {get;set;} 
        @AuraEnabled public Decimal quantity {get;set;} 
        @AuraEnabled public String location {get;set;} 
        @AuraEnabled public String customerOrderNumber {get;set;} 
        
        public ShipExcel() {

        }
        public ShipExcel(ShipmentOrder__c order) {
            System.debug(order  + ' ::: order');
            this.accountName = order.DealerOrderItem__r.Order__r.FM_CustomerName__c;
            this.deliveryOrderNumber = order.DeliveryOrder__c;
            this.deliveryDate = order.FM_DeliveryDate__c;
            this.deliveryTime = order.CreatedDate.format('HH:mm:ss');
            this.address = order.DealerOrderItem__r.Order__r.FM_ShipToName__c;
            this.postalCode = order.DealerOrderItem__r.Order__r.FM_PostalCode__c;
            this.representative = order.DealerOrderItem__r.Order__r.FM_Representative__c;
            this.phone = order.DealerOrderItem__r.Order__r.FM_Phone__c;
            this.orderNumber = order.DealerOrderItem__r.Order__r.OrderNumber__c;
            this.partNumber = order.DealerOrderItem__r.Part__r.ProductCode;
            this.partName = order.DealerOrderItem__r.Part__r.FM_MaterialDetails__c;
            this.quantity = order.Quantity__c;
            this.customerOrderNumber = order.DealerOrderItem__r.Order__r.CustomerPurchaseOrderNumber__c;
            this.shippingType = order.DealerOrderItem__r.Order__r.ShippingType__c;
        }
    }

    public class DN_OrderedGITableControllerException extends Exception {}
}