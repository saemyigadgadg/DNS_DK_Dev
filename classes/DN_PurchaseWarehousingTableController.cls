/**
 * @author            : iltae.seo
 * @last modified on  : 2025-05-21
 * @last modified by  : iltae.seo
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-16   iltae.seo     Initial Version
**/
public with sharing class DN_PurchaseWarehousingTableController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @Description
     * 	- DNS 구매 목록 반환
    **/ 
    @AuraEnabled
    public static List<ReturnItem> getDNSLIst(Map<String,Object> whereCondition){
        try {
            List<ReturnItem> returnList = new List<ReturnItem>();
            List<ReturnItem> returnSetList = new List<ReturnItem>();
            List<PurchaseOrderItems__c> dnsOrderList = new List<PurchaseOrderItems__c>();
            Map<String,DateTime> gIDateMap = new Map<String,DateTime>(); // 출고일자
            Map<String,Decimal> gIMap = new Map<String,Decimal>(); // 출고수량
            set<String> partIds = new set<String>();
            Map<String,Decimal> gRQTYMap = new Map<String,Decimal>();
            Map<String,Decimal> returnQTYMap = new Map<String,Decimal>();
            // DNS 구매아이템 쿼리
            String dnsQuery = 'select Id, OrderPartId__r.Name,OrderPartId__r.Unit__c,ItemNo__c,OrderPartId__r.ProductCode,OrderPartId__r.FM_MaterialDetails__c, Name,CreatedDate,Part__c,Part__r.Name,Part__r.Unit__c,Part__r.ProductCode,PurchaseOrder__r.CustomerOrderNo__c,PurchaseOrder__r.Buyer__r.Name,Quantity__c,LastModifiedDate ,Invoice__c,Part__r.FM_MaterialDetails__c, PurchaseOrder__r.PartOrderNo__c';
            dnsQuery += ',SupplyPartId__c ,CompletedQty__c,SupplyPartId__r.ProductCode,SupplyPartId__r.FM_MaterialDetails__c,SupplyPartId__r.Unit__c';
            System.debug(whereCondition + ' ::: whereCondition');
            // 품번
            String serialNumber = (String)whereCondition.get('productCode');
            System.debug(serialNumber + ' ::: serialNumber');
            List<String> serialNumList = new List<String>();
            if(String.isNotBlank(serialNumber)) {
                serialNumList = serialNumber.split(',');
            }
            System.debug(serialNumList + ' ::: serialNumList');
            List<Product2> prodList = [SELECT Id, Name, ProductCode FROM Product2 WHERE Id IN:serialNumList];
            List<String> prodSetCode = new List<String>();
            for( Product2 prod: prodList) {
                prodSetCode.add(prod.ProductCode);
            }
            System.debug(prodSetCode + ' ::: prodSetCode');
            Map<String,IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res_ET_LIST> dnsMap = new Map<String,IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res_ET_LIST>();
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res res = dealerStock006(whereCondition, prodSetCode);
            set<String> dnsDoc = new set<String>();
            set<String> dnsPart = new set<String>();
            for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res_ET_LIST etList : res.ET_LIST) {
                dnsDoc.add(etList.DOCNO);
                dnsMap.put(etList.DOCNO.trim()+etList.MATNR.trim() + etList.DOCIT,etList); //MATNR
                dnsPart.add(etList.MATNR.trim());
            }
            System.debug(dnsPart + ' ::: dnsPart');//ItemNo__c
            System.debug(dnsDoc+ ' :: dnsDoc');
            System.debug(dnsMap + ' ::: dnsMap');
            
            dnsQuery += ' from PurchaseOrderItems__c where PurchaseOrder__r.Buyer__c = \''+ currentUser.getAgencyId() + '\''; //AND PurchaseOrder__r.Status__c=\'출고\' 
            //dnsQuery += ' AND (CreatedDate >=:startDate AND CreatedDate <=:endDate )';
            dnsQuery += ' AND PurchaseOrder__r.RecordType.DeveloperName =\'Order\' ';
            dnsQuery += ' AND PurchaseOrder__r.PartOrderNo__c IN(\''+String.join(dnsDoc, '\',\'') +'\')';
            dnsQuery += ' AND SupplyPartId__r.ProductCode IN(\''+String.join(dnsPart, '\',\'') +'\')';
            // 주문일자 필터
            List<String> startSet = String.valueOf(whereCondition.get('OrderDateStart')).split('-');
            List<String> endSet = String.valueOf(whereCondition.get('OrderDateEnd')).split('-');
            DateTime startDate = DateTime.newInstanceGMT(Integer.valueOf(startSet[0]), Integer.valueOf(startSet[1]), Integer.valueOf(startSet[2]));
            DateTime endDate = DateTime.newInstanceGMT(Integer.valueOf(endSet[0]), Integer.valueOf(endSet[1]), Integer.valueOf(endSet[2]),23,59,59);            
            // DNS 
            dnsOrderList = Database.query(dnsQuery + ' LIMIT 5000');
            System.debug(dnsOrderList  + ' :::1 dnsOrderList');
            Map<String,PurchaseOrderItems__c> dnsQueryMap = new Map<String,PurchaseOrderItems__c>();
            // this.orderNumber = puc.PurchaseOrder__r.PartOrderNo__c;
            //this.partNumber = puc.SupplyPartId__r.ProductCode;
            for(PurchaseOrderItems__c dnOrder : dnsOrderList) {
                partIds.add(dnOrder.SupplyPartId__c);
                returnList.add(new ReturnItem(dnOrder));
                dnsQueryMap.put(dnOrder.PurchaseOrder__r.PartOrderNo__c + dnOrder.SupplyPartId__r.ProductCode + String.valueOf(Decimal.valueOf(dnOrder.ItemNo__c)), dnOrder);
            }
            List<PurchaseOrderItems__c> dnsItemList = getDnsItem(dnsDoc);
            System.debug(dnsItemList + ' ::: dnsItemList');
            for(PurchaseOrderItems__c gI : dnsItemList) {
                Decimal completedQty = 0;
                DateTime completedDate = DateTime.now();
                if(gI.CompletedQty__c !=null) {
                    completedQty = gI.CompletedQty__c;
                } else {
                    completedQty = dnsMap.get(gI.PurchaseOrder__r.PartOrderNo__c+gI.SupplyPartId__r.ProductCode + String.valueOf(Decimal.valueOf(gI.ItemNo__c)))==null ? 0 : Decimal.valueOf(dnsMap.get(gI.PurchaseOrder__r.PartOrderNo__c+gI.SupplyPartId__r.ProductCode + String.valueOf(Decimal.valueOf(gI.ItemNo__c))).KWMENG);
                }
                if(gI.ShipmentDate__c !=null) {
                    completedDate = DateTime.newInstance(gI.ShipmentDate__c,Time.newInstance(0, 0, 0, 0));
                } else {
                    //System.debug(dnsIF.GIDAT + ' :: res.GIDAT');
                    completedDate = dnsMap.get(gI.PurchaseOrder__r.PartOrderNo__c+gI.SupplyPartId__r.ProductCode + String.valueOf(Decimal.valueOf(gI.ItemNo__c))) ==null ? null :DateTime.valueOf(dnsMap.get(gI.PurchaseOrder__r.PartOrderNo__c+gI.SupplyPartId__r.ProductCode + String.valueOf(Decimal.valueOf(gI.ItemNo__c))).GIDAT + ' 00:00:00');
                    //completedDate = DateTime.newInstance(res.GIDAT,Time.newInstance(0, 0, 0, 0));
                }
                gIMap.put(gI.Id,completedQty);
                gIDateMap.put(gI.Id, completedDate);
            }
            // 부품별 재고 확인
            Map<String,AggregateResult> stockMap = getStockQty(partIds);
            
            //출고 정보
            String gIGRQuery ='select PurchaseOrderItem__r.SupplyPartId__r.ProductCode, Part__c, DealerPurchaseOrderItem__c,Type__c, RecordType.DeveloperName, InventoryChange__c, Quantity__c, CreatedDate,DealerOrderItem__c,PurchaseOrderItem__c,PurchaseOrderItem__r.Invoice__c   from DealerInventoryMovements__c'; 
            gIGRQuery += ' where Dealer__c =\''+ currentUser.getAgencyId()+ '\'';
            gIGRQuery += ' AND Type__c NOT IN('+'\'3\',\'O\',\'1\')';
            gIGRQuery += ' AND RecordType.DeveloperName !=\'GoodsIssue\'';
            //gIGRQuery += ' AND (CreatedDate >=:startDate AND CreatedDate <=:endDate )'; //DealerPurchaseOrder__r.Dealer__r.Name
            gIGRQuery += ' AND PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c IN(\''+String.join(dnsDoc, '\',\'') +'\')';
            //gIGRQuery += ' AND PurchaseOrderItem__r.OrderPartId__r.ProductCode IN(\''+String.join(dnsPart, '\',\'') +'\')';
            gIGRQuery += ' order by CreatedDate ASC LIMIT 15000';
            System.debug(gIGRQuery + ' :::gIGRQuery');
            List<DealerInventoryMovements__c> gIGRList = Database.query(gIGRQuery);
            System.debug(gIGRList + ' ::gIGRList');
            
            for(DealerInventoryMovements__c inven : gIGRList) { //1 : 대리점구매, 2: 두산구매
                // DNS 구매인경우
                if(inven.InventoryChange__c =='S') { // 입고완료
                    gRQTYMap.put(inven.PurchaseOrderItem__c + inven.PurchaseOrderItem__r.SupplyPartId__r.ProductCode, gRQTYMap.get(inven.PurchaseOrderItem__c + inven.PurchaseOrderItem__r.SupplyPartId__r.ProductCode) != null ? (gRQTYMap.get(inven.PurchaseOrderItem__c + inven.PurchaseOrderItem__r.SupplyPartId__r.ProductCode) + inven.Quantity__c)  : inven.Quantity__c);
                } else {
                    if(inven.PurchaseOrderItem__r.Invoice__c !=null) {
                        System.debug(inven.PurchaseOrderItem__r.Invoice__c + ' ::: inven.PurchaseOrderItem__r.Invoice__c');
                        returnQTYMap.put(inven.PurchaseOrderItem__r.Invoice__c, (returnQTYMap.get(inven.PurchaseOrderItem__r.Invoice__c) != null ? returnQTYMap.get(inven.PurchaseOrderItem__r.Invoice__c) : 0) + inven.Quantity__c);
                    }
                }
            }
            //데이터 세팅
            for(ReturnItem ret : returnList) {
                System.debug(ret.orderNumber + ret.partNumber + ' :::: ret.orderNumber + ret.partNumber');
                System.debug(dnsMap.get(ret.orderNumber + ret.partNumber + ret.itemNumber) + ' dns Map');
                if(dnsMap.get(ret.orderNumber + ret.partNumber + ret.itemNumber) !=null) {
                    //재고 정보
                    if(stockMap.get(ret.partId) !=null) {
                        AggregateResult stock = stockMap.get(ret.partId);
                        ret.stockQuantity = (Decimal) stock.get('CurrentStockQuantity__c');
                        ret.stockLocation = (String) stock.get('FM_Loc__c');
                        ret.stockLocationId = (String) stock.get('DealerLocation__c');
                        ret.stockId = (String) stock.get('Id');
                    }
                    ret.goodsIssueQuantity = gIMap.get(ret.Id) !=null ? gIMap.get(ret.Id) : 0; 
                    ret.gIdate = gIDateMap.get(ret.Id) == null ? '' : gIDateMap.get(ret.Id).format('yyyy.MM.dd');
                    Decimal returnQty  = returnQTYMap.get(ret.invoiceNumber) ==null ? 0 : returnQTYMap.get(ret.invoiceNumber);
                    System.debug(gRQTYMap.get(ret.id + ret.partNumber) + ' :L:: gRQTYMap.get(ret.id + ret.partNumber)');
                    System.debug(ret.id + ' :L:: ret.id');
                    System.debug(ret.partNumber + ' :L:: ret.partNumber');
                    ret.gRTemporaryQuantity = gRQTYMap.get(ret.id + ret.partNumber) ==null ? 0 : gRQTYMap.get(ret.id + ret.partNumber);
                    ret.gRTemporaryQuantity = ret.gRTemporaryQuantity -returnQty; // 기입고 수량
                    if(dnsMap.get(ret.orderNumber +ret.partNumber + ret.itemNumber) !=null) {
                        ret.text1 = String.valueOf(dnsMap.get(ret.orderNumber + ret.partNumber + ret.itemNumber).TEXT1);
                        System.debug(returnQTYMap.get(ret.invoiceNumber) + ' return Order 111');
                        System.debug(Decimal.valueOf(dnsMap.get(ret.orderNumber + ret.partNumber + ret.itemNumber).RTQTY) + ' RTQTY');
                        ret.gRReturnQuantity = returnQTYMap.get(ret.invoiceNumber) == null ? Decimal.valueOf(dnsMap.get(ret.orderNumber+ ret.partNumber + ret.itemNumber).RTQTY) : returnQTYMap.get(ret.invoiceNumber);//Decimal.valueOf(dnsMap.get(ret.orderNumber).RTQTY); //RMQTY
                        Decimal dnsGIQTY = 0;
                        if(dnsQueryMap.get(ret.orderNumber+ret.partNumber + ret.itemNumber) ==null) {
                            dnsGIQTY = Decimal.valueOf(dnsMap.get(ret.orderNumber+ret.partNumber+ ret.itemNumber).RMQTY);
                        } else {
                            PurchaseOrderItems__c orderItems = dnsQueryMap.get(ret.orderNumber+ret.partNumber + ret.itemNumber);
                            Decimal orderComQTY = (Decimal) orderItems.CompletedQty__c;
                            if(orderComQTY > Decimal.valueOf(dnsMap.get(ret.orderNumber+ret.partNumber + ret.itemNumber).RMQTY)) {
                                dnsGIQTY = dnsQueryMap.get(ret.orderNumber+ret.partNumber + ret.itemNumber).CompletedQty__c;
                            } else {
                                dnsGIQTY = Decimal.valueOf(dnsMap.get(ret.orderNumber+ret.partNumber + ret.itemNumber).RMQTY);
                            }
                        }
                        
                        ret.gRPossibleQuantity = dnsGIQTY - ret.gRTemporaryQuantity;
                        ret.orderDate = (String)dnsMap.get(ret.orderNumber+ret.partNumber + ret.itemNumber).AUDAT;
                    }
                    ret.gRQuantity = ret.gRPossibleQuantity;
                    System.debug(ret.gRPossibleQuantity + ' ::: ret.gRPossibleQuantity');
                    // 입고 가능 수량이 0보다 큰 목록만 나오도록 설정
                    if(ret.gRPossibleQuantity > 0 ){
                        returnSetList.add(ret);
                    }
                }
            }
            return returnSetList;
        } catch (Exception e) {
            System.debug(e.getMessage() +' ::: e.getMessage()');
            System.debug(e.getStackTraceString() +' ::: e.getStackTraceString()');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 대리점 구매 목록 반환
    **/ 
    @AuraEnabled
    public static List<ReturnItem> getDealerPurOrder(Map<String,Object> whereCondition){
        try {
            List<DealerPurchaseOrderItem__c> dealerOrderList = new List<DealerPurchaseOrderItem__c>();
            Map<String,String> invoiceNumberMap = new Map<String,String>();
            List<ReturnItem> returnList = new List<ReturnItem>();
            List<ReturnItem> returnSetList = new List<ReturnItem>();
            set<String> partIds = new set<String>();
            set<String> buyerIds = new set<String>();
            Map<String,Decimal> gIMap = new Map<String,Decimal>(); // 출고수량
            Map<String,DateTime> gIDateMap = new Map<String,DateTime>(); // 출고일자
            Map<String,Decimal> returnQTYMap = new Map<String,Decimal>();
            Map<String,Decimal> gRQTYMap = new Map<String,Decimal>();
            //대리점 구매 쿼리
            String dealerOrderQuery = 'select Id,DealerPurchaseOrder__r.Customer__r.SourceAccount__c, Name,CreatedDate,DealerPurchaseOrder__r.FM_OrderDate__c,Part__r.Unit__c,Part__c,Part__r.Name,Part__r.ProductCode,DealerPurchaseOrder__r.Dealer__r.Name,DealerPurchaseOrder__r.OrderNumber__c,LastModifiedDate,DealerPurchaseOrder__r.Customer__r.Dealer__c,Part__r.FM_MaterialDetails__c,';
            dealerOrderQuery += 'ReplacingPart__c, ReplacingPart__r.Name, ReplacingPart__r.ProductCode, ReplacingPart__r.Unit__c,ReplacingPart__r.FM_MaterialDetails__c,';
            dealerOrderQuery+= 'DealerPurchaseOrder__r.Customer__r.Name,DealerPurchaseOrder__r.CreatedDate from DealerPurchaseOrderItem__c ';
            dealerOrderQuery +=' where DealerPurchaseOrder__r.Dealer__c=\''+currentUser.getAgencyId()+'\' AND GICompletedQuantity__c > 0 ';
            dealerOrderQuery += ' AND (GICompletedDateTime__c >=:startDate AND GICompletedDateTime__c <=:endDate )'; //DealerPurchaseOrder__r.Dealer__r.Name
            
            // ================================필터설정=============================================
            // 주문일자 필터
            List<String> startSet = String.valueOf(whereCondition.get('OrderDateStart')).split('-');
            List<String> endSet = String.valueOf(whereCondition.get('OrderDateEnd')).split('-');
            DateTime startDate = DateTime.newInstanceGMT(Integer.valueOf(startSet[0]), Integer.valueOf(startSet[1]), Integer.valueOf(startSet[2]));
            DateTime endDate = DateTime.newInstanceGMT(Integer.valueOf(endSet[0]), Integer.valueOf(endSet[1]), Integer.valueOf(endSet[2]),23,59,59);            
            //주문번호
            String orderNumber = (String) whereCondition.get('orderNumber');
            if(String.isNotBlank(orderNumber)) {
                dealerOrderQuery += ' AND DealerPurchaseOrder__r.OrderNumber__c = \''+orderNumber +'\'';
            }
            // 구매처
            String orderType = (String)whereCondition.get('orderType');

            // 품번
            String serialNumber = (String)whereCondition.get('productCode');
            List<String> serialNumList = new List<String>();
            if(String.isNotBlank(serialNumber)) {
                serialNumList = serialNumber.split(',');
                dealerOrderQuery += ' AND ReplacingPart__c IN:serialNumList';
            }
            
            dealerOrderList = Database.query(dealerOrderQuery + ' LIMIT 6000');
            
            for(DealerPurchaseOrderItem__c dealerPur : dealerOrderList) {
                invoiceNumberMap.put(dealerPur.Id,null);
                returnList.add(new ReturnItem(dealerPur));
                partIds.add(dealerPur.ReplacingPart__c);
                buyerIds.add(dealerPur.DealerPurchaseOrder__r.Customer__r.SourceAccount__c);
            }
            List<AggregateResult> buyGIList = getAgencyGIQty(buyerIds,invoiceNumberMap);
            System.debug(buyGIList + ' :: buyGIList');
            for(AggregateResult gI : buyGIList) {
                gIMap.put((String)gI.get('DealerPurchaseOrderItem__c'), (Decimal)gI.get('Quantity__c'));
                gIDateMap.put((String) gI.get('DealerPurchaseOrderItem__c'), (DateTime)gI.get('CreatedDate'));
            }
            //대리점 송장번호
            List<DealerOrderItem__c> orderItems = [
                SELECT Id, Name,DealerPurchaseOrderItem__c,
                Order__r.Invoice__c
                FROM DealerOrderItem__c where DealerPurchaseOrderItem__c IN : invoiceNumberMap.keyset()
            ];
            SYstem.debug(orderItems + ' :: orderItems');
            for(DealerOrderItem__c order : orderItems) {
                if(order.Order__r.Invoice__c !=null) {
                    invoiceNumberMap.put(order.DealerPurchaseOrderItem__c, order.Order__r.Invoice__c);
                }
            }
            Map<String,AggregateResult> stockMap = getStockQty(partIds);
            set<String> dealerItemIds = invoiceNumberMap.keySet();
            // 현재 대리점에서 대리점구매를 통해 입고한 문서 또는 반품정보 조회
            String gIGRQuery ='select Part__c, DealerPurchaseOrderItem__c,Type__c, RecordType.DeveloperName, InventoryChange__c, Quantity__c, CreatedDate,DealerOrderItem__c,PurchaseOrderItem__c,PurchaseOrderItem__r.Invoice__c   from DealerInventoryMovements__c'; 
            gIGRQuery += ' where Dealer__c =\''+ currentUser.getAgencyId()+ '\'';
            gIGRQuery += ' AND Type__c NOT IN('+'\'3\',\'O\',\'2\')';
            gIGRQuery += ' AND RecordType.DeveloperName !=\'GoodsIssue\'';
            gIGRQuery += ' AND DealerPurchaseOrderItem__c IN:dealerItemIds'; //DealerPurchaseOrder__r.Dealer__r.Name
            gIGRQuery += ' order by CreatedDate ASC LIMIT 4000';
            System.debug(gIGRQuery + ' :::gIGRQuery');
            List<DealerInventoryMovements__c> gIGRList = Database.query(gIGRQuery);
            System.debug(gIGRList + ' ::gIGRList');
            // 대리점 기준
            
            for(DealerInventoryMovements__c inven : gIGRList) { //1 : 대리점구매, 2: 두산구매
                //입고완료
                if(inven.InventoryChange__c =='S') {
                    gRQTYMap.put(inven.DealerPurchaseOrderItem__c, gRQTYMap.get(inven.DealerPurchaseOrderItem__c) != null ? (gRQTYMap.get(inven.DealerPurchaseOrderItem__c) + inven.Quantity__c)  : inven.Quantity__c);
                } else {//입고 취소
                    System.debug(inven.DealerPurchaseOrderItem__c + ' ::: inven.DealerPurchaseOrderItem__c');
                    if(inven.DealerPurchaseOrderItem__c !=null) {
                        returnQTYMap.put(inven.DealerPurchaseOrderItem__c, (returnQTYMap.get(inven.DealerPurchaseOrderItem__c) != null ? returnQTYMap.get(inven.DealerPurchaseOrderItem__c) : 0) + inven.Quantity__c);
                    }
                }
            }

            //데이터 세팅
            for(ReturnItem ret : returnList) {
                //재고 정보
                if(stockMap.get(ret.partId) !=null) {
                    AggregateResult stock = stockMap.get(ret.partId);
                    System.debug(stock +' ::: stock');
                    ret.stockQuantity = (Decimal) stock.get('CurrentStockQuantity__c');
                    ret.stockLocation = (String) stock.get('FM_Loc__c');
                    ret.stockLocationId = (String) stock.get('DealerLocation__c');
                    ret.stockId = (String) stock.get('Id');
                }
                // 대리점 출고 수량
                
                System.debug(ret.id + ' :::ret.id'); 
                System.debug(gIMap.get(ret.id) + ' :: gIMap.get(ret.id)');
                System.debug(gIDateMap.get(ret.id) + ' :: gIDateMap.get(ret.id)');
                ret.goodsIssueQuantity = gIMap.get(ret.id) !=null ? gIMap.get(ret.id) : 0; 
                ret.gRReturnQuantity = returnQTYMap.get(ret.id) ==null ? 0 : returnQTYMap.get(ret.id);
                ret.gIdate = gIDateMap.get(ret.id) == null ? '' : gIDateMap.get(ret.id).format('yyyy.MM.dd');
                // 기입고 수량 계산
                Decimal returnQty  = returnQTYMap.get(ret.id) ==null ? 0 : returnQTYMap.get(ret.id);
                ret.gRTemporaryQuantity = gRQTYMap.get(ret.id) ==null ? 0 : gRQTYMap.get(ret.id);
                ret.gRTemporaryQuantity = ret.gRTemporaryQuantity -returnQty;
                ret.gRPossibleQuantity = ret.goodsIssueQuantity - ret.gRTemporaryQuantity;
                ret.text1 = invoiceNumberMap.get(ret.id) == null ? ''  : invoiceNumberMap.get(ret.id);
                System.debug(ret + ' ::: ret 대리점 구매');
                ret.gRQuantity = ret.gRPossibleQuantity;
                // 입고 가능 수량이 0보다 큰 목록만 나오도록 설정
                if(ret.gRPossibleQuantity > 0 ){
                    returnSetList.add(ret);
                	System.debug(returnSetList + ' :::: 입고가능수량이 0보다 큰 목록');
                }
                
            }
            return returnSetList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 구매대리점 출고 수량 - 다른대리점에서 현재 대리점으로 출고한 정보
    **/ 
    public static List<AggregateResult> getAgencyGIQty(set<String> buyerIds, Map<String,String> itemIds) {
        set<String> dealerItemIds = itemIds.keySet();
        // 구매대리점 출고 수량
        String buyerGIQuery = 'select DealerOrderItem__r.DealerPurchaseOrderItem__c,Part__c, SUM(Quantity__c) Quantity__c,MAX(CreatedDate) CreatedDate from DealerInventoryMovements__c'; 
        buyerGIQuery += ' where RecordType.DeveloperName =\'GoodsIssue\' AND Dealer__c IN:buyerIds AND DealerOrderItem__r.DealerPurchaseOrderItem__c IN:dealerItemIds AND DealerOrderItem__r.Order__r.Customer__r.SourceAccount__c =\''+currentUser.getAgencyId()+'\'';
        buyerGIQuery += ' group by DealerOrderItem__r.DealerPurchaseOrderItem__c,Part__c LIMIT 1000';
        System.debug(buyerGIQuery + ' buyerGIQuery::');
        List<AggregateResult> buyGIList = Database.query(buyerGIQuery);
        System.debug(buyGIList + ' ::: buyGIList');
        return buyGIList;
    }

    /**
     * @Description
     * 	- DNS 구매 배송완료 수량
    **/ 
    public static List<PurchaseOrderItems__c> getDnsItem(set<String> dnsDoc) {
        List<PurchaseOrderItems__c> dnsOrderItemList = [
            select Id, Name, ShipmentDate__c,
            CompletedQty__c,
            OrderPartId__c,
            OrderPartId__r.ProductCode,
            PurchaseOrder__r.PartOrderNo__c,
            SupplyPartId__c,
            SupplyPartId__r.ProductCode,
            ItemNo__c
            from PurchaseOrderItems__c 
            where PurchaseOrder__r.PartOrderNo__c IN : dnsDoc
        ];
        return dnsOrderItemList;
    }

    /**
     * @Description
     * 	- 부품별로 재고 확인
    **/ 
    public static Map<String,AggregateResult> getStockQty(set<String> partids) {
        System.debug(partids + ' ::: partids');
        // 재고 확인
        String stockQuery = 'select Part__c, SUM(CurrentStockQuantity__c) CurrentStockQuantity__c , MAX(DealerLocation__r.FM_Loc__c) FM_Loc__c,MAX(DealerLocation__c) DealerLocation__c, MAX(Id) Id from DealerStock__c';
        stockQuery += ' where Dealer__c =\''+ currentUser.getAgencyId()+ '\' AND Part__c IN:partids';
        stockQuery +=' group by Part__c LIMIT 2000';
        System.debug(stockQuery + ' :L:: stockQuery');
        List<AggregateResult> stocList = Database.query(stockQuery);
        System.debug(stocList + ' ::: stocList');
        Map<String,AggregateResult> stockMap = new Map<String,AggregateResult>();
        for(AggregateResult ages : stocList) {
            stockMap.put((String)ages.get('Part__c'), ages);
        }
        return stockMap;
    }

    /**
     * @Description
     *  -  주문번호, 품번, 기간
     */
    public static IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res dealerStock006(Map<String,Object> whereCondition,List<String> serialNumList) {
        System.debug(serialNumList + ' ::: serialNumList');
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req req = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req();
        req.IS_USERINFO         = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IS_USERINFO();
        req.IS_USERINFO.KUNNR   = '000'+currentUser.getAgencyCustomerCode();
        req.IS_USERINFO.VKORG   = currentUser.getSalesOranization();
        req.IS_USERINFO.VTWEG   = currentUser.getDistributionChannel();
        req.IS_USERINFO.SPART   = currentUser.getDivision();
        String orderNumber = (String) whereCondition.get('orderNumber');
        // 주문번호
        req.IS_INPUT            = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IS_INPUT();
        if(String.isNotBlank(orderNumber)) req.IS_INPUT.DOCNO      = orderNumber; // 문서번호
        //조회날짜
        String startDate = String.valueOf(whereCondition.get('OrderDateStart'));
        
        String endDate = String.valueOf(whereCondition.get('OrderDateEnd'));
        
        req.IS_INPUT.ERDAT_F    = startDate.replace('-',''); // 날짜조회 시작
        req.IS_INPUT.ERDAT_T    = endDate.replace('-',''); // 날짜조회 종료
        req.IS_INPUT.TYPE       = '1'; // 1은 DNS 구매
        // 부품정보 필터
        req.IT_MATNR            = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IT_MATNR>();
        for(String productCode : new set<String>(serialNumList)) {
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IT_MATNR IT_MATNR1 = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Req_IT_MATNR();
            IT_MATNR1.MATNR         = productCode;
            req.IT_MATNR.add(IT_MATNR1);
        }
        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_006_Res res = instance.IF_DEALERSTOCK_006(req);
        System.debug(JSON.serializePretty(res.ET_LIST)+ ' ::: res');
        return res;
    }

    /**
     * @Description
     *  -  입고처리
     */
    @AuraEnabled
    public static GRExcel insertGRList(List<GoodsReceipt> goodsReceiptList,List<String> dnsIds, List<String> agencyIds){
        try {
            // TYpe 2 : DNS 구매
            List<DealerInventoryMovements__c> dmlGRList = new List<DealerInventoryMovements__c>();
            List<String> grIds = new List<String>();
            Map<String,PurchaseOrderItems__c> dnsMap = new Map<String,PurchaseOrderItems__c>();
            Map<String,DealerPurchaseOrderItem__c> dealerOrderMap = new Map<String,DealerPurchaseOrderItem__c>();
            List<PurchaseOrderItems__c> dnsList = [select Id,UnitPrice__c,SupplyPartId__r.ProductCode,SupplyPartId__c,OrderPartId__c,PartAmount__c,ItemNo__c,PurchaseOrder__r.PartOrderNo__c,CompletedQty__c from PurchaseOrderItems__c where Id IN:dnsIds FOR UPDATE];
            for(PurchaseOrderItems__c pur : dnsList) {
                dnsMap.put(pur.Id, pur);
            }
            List<DealerPurchaseOrderItem__c> agencyList = [select Id,CustomerPrice__c,OrderItemNumber__c ,DiscountPrice__c from DealerPurchaseOrderItem__c where Id IN:agencyIds FOR UPDATE]; 
            for(DealerPurchaseOrderItem__c dealerOrder: agencyList) {
                dealerOrderMap.put(dealerOrder.Id, dealerOrder);
            }
            String strQuery ='SELECT SUM(Quantity__c) QTY, MAX(PurchaseOrderItem__r.CompletedQty__c) GIQTY,MAX(PurchaseOrderItem__r.Quantity__c) orderQTY, MAX(PurchaseOrderItem__r.ItemNo__c) orderItemNumber,';
                    strQuery += ' MAX(Part__r.ProductCode) ProductCode,MAX(PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c) orderNumber, PurchaseOrderItem__c  Parrent ';
                    strQuery += ' FROM DealerInventoryMovements__c WHERE PurchaseOrderItem__c !=null ';
                    strQuery += ' AND PurchaseOrderItem__c IN(\''+String.join(dnsIds, '\',\'') + '\')';
                    strQuery += ' GROUP BY PurchaseOrderItem__c ';
            String dmlQuey =' SELECT Id FROM PurchaseOrderItems__c WHERE Id IN(\''+String.join(dnsIds, '\',\'') + '\')';
            Map<String,Object> isCheck = DN_DealerStockManager.duplicationCheck(strQuery,dmlQuey);
            System.debug( isCheck + ' ::: DNS isCheck');
            String dealerQuery ='SELECT SUM(Quantity__c) QTY, MAX(DealerPurchaseOrderItem__r.GICompletedQuantity__c) GIQTY,MAX(DealerPurchaseOrderItem__r.Quantity__c) orderQTY, MAX(DealerPurchaseOrderItem__r.OrderItemNumber__c) orderItemNumber,';
                    dealerQuery +=' MAX(Part__r.ProductCode) ProductCode,MAX(DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.OrderNumber__c) orderNumber, DealerPurchaseOrderItem__c  Parrent';
                    dealerQuery +=' FROM DealerInventoryMovements__c WHERE DealerPurchaseOrderItem__c !=null';
                    dealerQuery +=' AND DealerPurchaseOrderItem__c IN(\''+String.join(agencyIds, '\',\'') + '\')';
                    dealerQuery +=' GROUP BY DealerPurchaseOrderItem__c  ';
            String dealerQueryDML = ' SELECT Id FROM DealerPurchaseOrderItem__c WHERE Id IN(\''+String.join(agencyIds, '\',\'') + '\')';
            Map<String,Object> dealerOrderisCheck = DN_DealerStockManager.duplicationCheck(dealerQuery,dealerQueryDML);
            System.debug(dealerOrderisCheck + ' :: dealerOrderisCheck');
            if((Boolean) dealerOrderisCheck.get('isCheck')) {
                AggregateResult dealerResult =  (AggregateResult) dealerOrderisCheck.get('orders');
                throw new DN_PurchaseWarehousingTableControllerException(dealerResult.get('orderNumber') +' / '+dealerResult.get('orderItemNumber')+' / '+ dealerResult.get('ProductCode')+'의 입고수량이 오더수량을 초과합니다.');
            }
            //
            Map<String,Decimal> goodQTY = new Map<String,Decimal>();
            Map<String,Decimal> goodGRQTY = new Map<String,Decimal>();
            List<AggregateResult> dnsGRList = Database.query(strQuery);
            
            for(AggregateResult dnsGR : dnsGRList) {
                System.debug(dnsGR + ' ::: dnsGR');
                goodGRQTY.put((String)dnsGR.get('Parrent'),(Decimal)dnsGR.get('QTY'));
            }
            for(GoodsReceipt dnsGood : goodsReceiptList) {
                if(dnsGood.type=='2') {
                    PurchaseOrderItems__c purs = dnsMap.get(dnsGood.purchaseOrderItem);
                    Decimal dnGRQTY = goodGRQTY.get(dnsGood.purchaseOrderItem) == null? 0 : goodGRQTY.get(dnsGood.purchaseOrderItem);
                    System.debug(dnsGood.quantity + ' ::: dnsGood.quantity');
                    System.debug(dnGRQTY + ' :: dnGRQTY');
                    System.debug(purs.CompletedQty__c + ' :: purs.CompletedQty__c');
                    if( (dnsGood.quantity+dnGRQTY) > purs.CompletedQty__c) {
                        throw new DN_PurchaseWarehousingTableControllerException(purs.PurchaseOrder__r.PartOrderNo__c +' / '+purs.ItemNo__c +' / '+ purs.SupplyPartId__r.ProductCode +'의 입고수량이 오더수량을 초과합니다.');
                    }

                }
            }
            // DNS 중복체크
            if((Boolean) isCheck.get('isCheck')) {
                AggregateResult dnsResult =  (AggregateResult) isCheck.get('orders');
                throw new DN_PurchaseWarehousingTableControllerException(dnsResult.get('orderNumber') +' / '+dnsResult.get('orderItemNumber') +' / '+ dnsResult.get('ProductCode') +'의 입고수량이 오더수량을 초과합니다.');
            } 
            
            

            
            // 입고처리 기능
            // Rec Type
            RecordType recType = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='DealerInventoryMovements__c' AND DeveloperName='GoodsReceipt'];
            //채번
            SequenceGenerator seqGenerator = new SequenceGenerator('DealerInventoryMovements__c');
            String grNumber = seqGenerator.generate(recType.DeveloperName);
            for(GoodsReceipt gR : goodsReceiptList) {
                

                

                DealerInventoryMovements__c dealerInventory = new DealerInventoryMovements__c();
                dealerInventory.RecordTypeId = recType.Id;
                dealerInventory.Dealer__c = currentUser.getAgencyId();
                dealerInventory.SalesOrganization__c = currentUser.getSalesOranization();
                dealerInventory.DistributionChannel__c = currentUser.getDistributionChannel();
                dealerInventory.Division__c = currentUser.getDivision();
                dealerInventory.InventoryNumber__c = grNumber;
                
                dealerInventory.Type__c = gR.type;
                if(String.isNotBlank(gR.inventoryChange))                           dealerInventory.InventoryChange__c = gR.inventoryChange;
                if(String.isNotBlank(gR.part))                                      dealerInventory.Part__c = gR.part;
                if(String.isNotBlank(gR.location))                                  dealerInventory.Location__c = gR.location;
                if(String.isNotBlank(String.valueOf(gR.quantity)))                  dealerInventory.Quantity__c = gR.quantity;
                if(String.isNotBlank(gR.currenc))                                   dealerInventory.CurrencyIsoCode  = gR.currenc;
                if(String.isNotBlank(gR.stockId))                                   dealerInventory.DealerStock__c  = gR.stockId;
                // DNS인 경우 가격 설정
                if(gR.type =='2') {
                    if(dnsMap.get(gR.purchaseOrderItem.trim()) !=null) {
                        PurchaseOrderItems__c dnsOrder = dnsMap.get(gR.purchaseOrderItem.trim());
                        dealerInventory.PurchaseOrderItem__c = gR.purchaseOrderItem.trim();
                        dealerInventory.Part__c = dnsOrder.SupplyPartId__c;
                        dealerInventory.CustomerPrice__c = dnsOrder.UnitPrice__c;
                        dealerInventory.DiscountPrice__c = dnsOrder.UnitPrice__c;
                        dealerInventory.DiscountAmount__c = gR.quantity*dnsOrder.UnitPrice__c;
                        dealerInventory.InventoryItemNumber__c = dnsOrder.ItemNo__c;
                    }
                } else {
                    System.debug(dealerOrderMap + ' : :dealerOrderMap');
                    System.debug(gR.dealerPurchaseOrderItem + ' :: dealerPurchaseOrderItem');
                    DealerPurchaseOrderItem__c dealerItem = dealerOrderMap.get(gR.dealerPurchaseOrderItem);
                    System.debug(dealerItem + ' :: dealerItem');
                    // 대리점 구매인 경우
                    dealerInventory.DealerPurchaseOrderItem__c = gR.dealerPurchaseOrderItem;
                    dealerInventory.CustomerPrice__c = dealerItem.CustomerPrice__c;
                    dealerInventory.DiscountPrice__c = dealerItem.DiscountPrice__c;
                    dealerInventory.DiscountAmount__c = dealerItem.DiscountPrice__c * gR.quantity;
                    dealerInventory.InventoryItemNumber__c = dealerItem.OrderItemNumber__c;
                }
                dmlGRList.add(dealerInventory);
            }
            System.debug(dmlGRList + ' < ==dmlGRList');
            insert dmlGRList;
            
            for(DealerInventoryMovements__c inventory : dmlGRList) {
                grIds.add(inventory.Id);
            }
            List<DealerInventoryMovements__c> returnList = [
                select Id,PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c,
                DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.OrderNumber__c,
                PurchaseOrderItem__r.PurchaseOrder__r.Name, 
                Name,InventoryNumber__c,Part__r.Name, 
                Part__r.ProductCode, 
                Part__r.FM_MaterialDetails__c,
                Quantity__c,Location__r.FM_Loc__c,
                CreatedDate,Part__c 
                from DealerInventoryMovements__c 
                where Id IN:GRIds FOR UPDATE
            ];
            Map<String,Decimal> grMap = new Map<String,Decimal>();
            for(DealerInventoryMovements__c deInven : returnList) {
                if(grMap.get(deInven.Part__c) ==null) {
                    grMap.put(deInven.Part__c, deInven.Quantity__c);
                } else {
                    Decimal totalQTY = deInven.Quantity__c + grMap.get(deInven.Part__c);
                    grMap.put(deInven.Part__c, totalQTY);
                }
            }
            GRExcel returnExcel = new GRExcel();
            set<String> productCodes = new set<String>();
            returnExcel.doc = grNumber;
            for(DealerInventoryMovements__c inventorys: returnList) {
                returnExcel.createdDate = inventorys.CreatedDate.format('yyyy-MM-dd'); 
                returnExcel.createdTime = inventorys.CreatedDate.format('HH:mm:ss'); 
                returnExcel.agencyName = currentUser.getAgencyName();
                productCodes.add(inventorys.Part__r.ProductCode);
            }
            
            returnExcel.returnGRList = returnList;
            
            // 재고 업데이트
            DN_DealerStockManager.getAvailable(grMap, 'GR','');
            //채번 업데이트
            seqGenerator.updateNextSequenceInfo();
            List<DealerStock__c> stockList = [
                SELECT Id, Part__r.ProductCode,Part__c,CurrentStockQuantity__c,AvailableQuantity__c 
                FROM DealerStock__c 
                WHERE Part__r.ProductCode IN:productCodes 
                AND Dealer__c =:currentUser.getAgencyId()
            ];
            for(DealerStock__c stock : stockList) {
                returnExcel.stockMap.put(stock.Part__r.ProductCode,stock);
            }
            return returnExcel;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' <===e.getMessage()');
            System.debug(e.getLineNumber() + ' <===e.getLineNumber()');
            System.debug(e.getStackTraceString() + ' <===e.System.debug(e.getLineNumber()');
            throw new AuraHandledException(e.getMessage());
        }
    }


    

    /**
     * @Description
     *  -  입고 생성 후 입고 액셀 데이터
     */
    public class GRExcel {
        @AuraEnabled public String agencyName {get;set;} // 대리점명
        @AuraEnabled public String doc {get;set;} // 참고문서
        @AuraEnabled public String createdDate {get;set;} 
        @AuraEnabled public String createdTime {get;set;} 
        @AuraEnabled public List<DealerInventoryMovements__c> returnGRList {get;set;} 
        @AuraEnabled public Map<String,DealerStock__c> stockMap {get;set;} 
        public GRExcel() {
            this.stockMap = new Map<String,DealerStock__c>();
            this.returnGRList = new List<DealerInventoryMovements__c>();
        }
    }


    public class GoodsReceipt {
        //SalesOrganization__c,DistributionChannel__c,Division__c,Dealer__c
        @AuraEnabled public String inventoryChange {get;set;} // S : 생성 , H: 취소
        @AuraEnabled public String part {get;set;} // 품번
        @AuraEnabled public String location {get;set;} //저장위치 
        @AuraEnabled public Decimal quantity {get;set;} // 입고 수량 
        @AuraEnabled public Decimal gRPossibleQuantity {get;set;} // 입고 가능수량
        @AuraEnabled public String unit {get;set;} // 단위 
        @AuraEnabled public Decimal customerPrice {get;set;} // CustomerPrice (고객판매가)
        @AuraEnabled public Decimal discountPrice {get;set;} // DiscountPrice (할인판매가)
        @AuraEnabled public Decimal discountAmount {get;set;} // 입고 금액 = 할인판매가 * 입고 수량 //Currency
        @AuraEnabled public String currenc {get;set;} // 통화 : 기본값 KRW 
        @AuraEnabled public String purchaseOrderItem {get;set;} // DNS 구매 아이템 Lookup 
        @AuraEnabled public String dealerPurchaseOrderItem {get;set;} // 대리점 구매 아이템 Lookup
        @AuraEnabled public String type {get;set;} // 1 : 대리점구매, 2 : 두산구매, 3: 자체구매
        @AuraEnabled public String stockId  {get;set;} // 저장위치Id
    }   

    public class ReturnItem {
        //주문 정보
        @AuraEnabled public String id {get;set;} // Id
        @AuraEnabled public String orderNumber {get;set;} // 구매주문번호
        @AuraEnabled public String partNumber  {get;set;} // 부품번호
        @AuraEnabled public String partName  {get;set;} // 품명
        @AuraEnabled public String partId  {get;set;} // 부품아이디
        @AuraEnabled public String unit  {get;set;} // 부품 단위
        @AuraEnabled public String orderDate {get;set;} // 주문일자 (대리점- 대리점 주문 생성일자, DNS구매생성일자)
        @AuraEnabled public Decimal goodsIssueQuantity {get;set;} // 출고수량, 대리점인 경우 대리점 출고 테이블
        @AuraEnabled public String invoiceNumber {get;set;} // InvoiceNumber
        @AuraEnabled public String text1 {get;set;} // 송장번호
        @AuraEnabled public String orderType {get;set;} // 오더 타입 : DNS OR Agency
        @AuraEnabled public String buyerName  {get;set;} // 구매처 - 대리점 OR DN
        @AuraEnabled public String itemNumber  {get;set;} // 구매처 - 대리점 OR DN


        //창고정보
        @AuraEnabled public Decimal stockQuantity {get;set;} // 창고재고
        @AuraEnabled public String stockLocation {get;set;} // 저장위치
        @AuraEnabled public String stockLocationId  {get;set;} // 저장위치Id
        @AuraEnabled public String stockId  {get;set;} // 저장위치Id
        
        //입고 정보
        @AuraEnabled public Decimal gRReturnQuantity {get;set;} // 반품수량 (입고취소 수량)
        @AuraEnabled public Decimal gRTemporaryQuantity {get;set;} // 기입고수량 (현재 입고된 수량)
        //출고정보
        @AuraEnabled public String gIdate {get;set;} // 출고일자 - 출고테이블의 가장 최근일자 
        //구매대리점인 경우 구매대리점의 출고 수량        

        //계산식
        @AuraEnabled public Decimal gRPossibleQuantity {get;set;} // 입고가능수량 (출고수량 - 기입고 수량)
        @AuraEnabled public Decimal gRQuantity {get;set;} // 입고수량 (입고 가능 수량)

        public ReturnItem() {}   
        // DNS 구매
        public ReturnItem(PurchaseOrderItems__c puc) {
            this.id = puc.Id;
            this.orderNumber = puc.PurchaseOrder__r.PartOrderNo__c;
            this.partNumber = puc.SupplyPartId__r.ProductCode;
            this.itemNumber = String.valueOf(Decimal.valueOf(puc.ItemNo__c));
            this.partName = puc.SupplyPartId__r.FM_MaterialDetails__c;
            this.partId = puc.SupplyPartId__c;
            this.unit = puc.SupplyPartId__r.Unit__c;
            this.orderDate = puc.CreatedDate.format('YYYY.MM.dd');
            this.goodsIssueQuantity = puc.Quantity__c;
            this.invoiceNumber = puc.Invoice__c;
            this.orderType ='DNS';
            this.buyerName = 'DNS 솔루션즈';
            this.stockQuantity =0;
            this.gRReturnQuantity=0;
        }
        // 대리점 구매
        public ReturnItem(DealerPurchaseOrderItem__c dealerPur ) {
            this.id = dealerPur.Id;
            this.orderNumber = dealerPur.DealerPurchaseOrder__r.OrderNumber__c;
            this.partNumber = dealerPur.ReplacingPart__r.ProductCode;
            this.partName = dealerPur.ReplacingPart__r.FM_MaterialDetails__c;
            this.partId = dealerPur.ReplacingPart__c;
            this.unit = dealerPur.ReplacingPart__r.Unit__c;
            this.orderDate = dealerPur.DealerPurchaseOrder__r.CreatedDate.format('YYYY.MM.dd');
            this.orderType = 'Agency';
            this.buyerName = dealerPur.DealerPurchaseOrder__r.Customer__r.Name;
            this.stockQuantity =0;
        }
    }

    public class DN_PurchaseWarehousingTableControllerException extends Exception {}
}