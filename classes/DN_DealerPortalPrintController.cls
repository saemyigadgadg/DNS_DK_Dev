/** 
 * @Class : DN_DealerPortalPrintController
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
public with sharing class DN_DealerPortalPrintController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @Description
     * 	- 입/출고증
    **/ 
    @AuraEnabled
    public static List<PrintInfo> getGRGIListPrint(List<String> recordIds, List<Decimal> qtyList, String type){
        try {
            System.debug( qtyList + '<==qtyList');
            set<String> ids = new set<String>();
            set<String> partIds = new set<String>();
            Map<String,Decimal> recordMap = new Map<String,Decimal>();
            Map<String,String> stockMap = new Map<String,String>();
            for(Integer i=0; i<recordIds.size(); i++) {
                recordMap.put(recordIds[i],qtyList[i]);
                ids.add(recordIds[i]);
            }
            
            
            // 대리점구매
            List<DealerPurchaseOrderItem__c> itemList = [select DealerPurchaseOrder__r.Dealer__r.Name,Part__c,Part__r.FM_MaterialDetails__c,
                                                            DealerPurchaseOrder__r.OrderNumber__c,Part__r.Unit__c,Part__r.Name,Part__r.ProductCode 
                                                            from DealerPurchaseOrderItem__c
                                                            where Id IN : ids 
                                                        ];
            // DNS 구매
            List<PurchaseOrderItems__c> orderItem = [select PurchaseOrder__r.CustomerOrderNo__c,OrderPartId__r.Name,OrderPartId__c,OrderPartId__r.FM_MaterialDetails__c,
                                                        OrderPartId__r.ProductCode,OrderPartId__r.Unit__c from PurchaseOrderItems__c
                                                        where Id IN:ids
                                                    ];
    
            List<PrintInfo> returnInfo = new List<PrintInfo>();
            for(DealerPurchaseOrderItem__c dOrder : itemList) {   
                partIds.add(dOrder.Part__c);
            }
            for(PurchaseOrderItems__c orderI : orderItem) {
                partIds.add(orderI.OrderPartId__c);
            }

            // Bin
            List<DealerStock__c> dealerStockList = [select Id, Name, Part__c,DealerLocation__r.FM_Loc__c from DealerStock__c where Dealer__c =:currentUser.getAgencyId()  AND Part__c IN:partIds];
            for(DealerStock__c stock : dealerStockList) {
                stockMap.put(stock.Part__c,stock.DealerLocation__r.FM_Loc__c);
            }
            for(DealerPurchaseOrderItem__c dOrder : itemList) {   
                returnInfo.add(new PrintInfo(dOrder,type,recordMap,stockMap));
            }
            for(PurchaseOrderItems__c orderI : orderItem) {
                returnInfo.add(new PrintInfo(orderI,type,recordMap,stockMap));
            }

            return returnInfo;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' < ==e.getMessage()');
            System.debug(e.getLineNumber() + ' < ==e.getLineNumber()');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 주문출고 - 프린트
    **/
    @AuraEnabled
    public static List<OrderPrint> getOrderPrint(List<String> recordId){
        try {
            set<String> dealerOrderIds = new set<String>();
            set<String> parts = new set<String>();
            Map<String,String> stockMap = new Map<String,String>();
            List<DealerOrderItem__c> dealerOrder = 
                [
                    select Id,Part__r.Name,Part__r.ProductCode,Order__r.OrderNumber__c, Part__c,FM_Unit__c   
                    from DealerOrderItem__c 
                    where Id IN:recordId
                ];
            List<OrderPrint> printList = new List<OrderPrint>();
            for(DealerOrderItem__c orderItem: dealerOrder) {
                dealerOrderIds.add(orderItem.Id);
                parts.add(orderItem.Part__c);
                OrderPrint print = new OrderPrint(orderItem);
                print.accountName = currentUser.getAgencyName();
                printList.add(print);
            }
            
            List<ShipmentOrder__c> shipOrder = [select Id, DealerOrderItem__c,Name from ShipmentOrder__c where DealerOrderItem__c IN : dealerOrderIds order by CreatedDate desc];
            List<DealerStock__c> stockList = [select Part__c, DealerLocation__r.FM_Loc__c from DealerStock__c where Part__c IN:parts AND Dealer__c =:currentUser.getAgencyId()];
            
            for(DealerStock__c stock : stockList) {
                stockMap.put(stock.Part__c, stock.DealerLocation__r.FM_Loc__c);
            }
          
            if(shipOrder.size() > 0) { // 가장 최근 출고지시번호
                for(OrderPrint print : printList) {
                    print.shipOrderNumber = shipOrder[0].Name;
                }
            }
            if(stockList.size() > 0) {
                for(OrderPrint print : printList) {
                    print.binLocation = stockMap.get(print.partNumber) ==null? 'No Stor. Bin': stockMap.get(print.partNumber);
                }
            }
            return printList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 대리점 자재 종합조회 && 재고 위치 설정/수정 출력
    **/
    @AuraEnabled
    public static List<StockInfo> getStockInfoPrint(List<String> recordIds){
        try {
            System.debug(recordIds + ' :: recordIds');
            List<StockInfo> returnStockList = new List<StockInfo>();
            Map<String,DealerStock__c> stockMap = new Map<String,DealerStock__c>();
            List<DealerStock__c> stockList = 
                [   select
                    Dealer__r.Name,
                    Part__r.FM_MaterialDetails__c,
                    Part__r.ProductCode,
                    CurrentStockQuantity__c,
                    DealerLocation__c,
                    DealerLocation__r.FM_Loc__c,
                    Part__r.Weight__c,
                    Part__r.WeightUnit__c
                    from DealerStock__c 
                    where Part__r.ProductCode IN:recordIds
                ];
            for(DealerStock__c stock : stockList) {
                stockMap.put(stock.Part__r.ProductCode,stock);
            }   
            List<Product2> prodList = [select FM_MaterialDetails__c,ProductCode,Weight__c,WeightUnit__c,Unit__c from Product2 where ProductCode IN: recordIds AND RecordType.DeveloperName ='Part'];
            for(Product2 prod : prodList) {
                StockInfo info = new StockInfo(prod);
                info.accountName = currentUser.getAgencyName();
                if(stockMap.get(prod.ProductCode) == null ) {
                    info.currentStockQuantity = 0;
                    info.stockLocation = 'NO Stor. Bin';
                } else {
                    info.currentStockQuantity = stockMap.get(prod.ProductCode).CurrentStockQuantity__c;
                    info.stockLocation = stockMap.get(prod.ProductCode).DealerLocation__r.FM_Loc__c == null ? 'NO Stor. Bin' : stockMap.get(prod.ProductCode).DealerLocation__r.FM_Loc__c ;
                }
                returnStockList.add(info);
            }
            return returnStockList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 저장소 출력
    **/
    @AuraEnabled
    public static List<DealerLocation__c> getLocation(List<String> recordIds){
        try {
            List<DealerLocation__c> returnLocation = [select Id, FM_Loc__c from DealerLocation__c where Id IN:recordIds];
            return returnLocation;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- StockInfo Class
    **/
    public class StockInfo {
        @AuraEnabled public String accountName {get;set;} // 대리점명
        @AuraEnabled public String partName {get;set;}  // 품명
        @AuraEnabled public String partNumber {get;set;} // 품번
        @AuraEnabled public String printDate {get;set;} // 출력일자
        @AuraEnabled public Decimal currentStockQuantity {get;set;} // 재고량
        @AuraEnabled public String unit {get;set;} // 단위
        @AuraEnabled public String stockLocation {get;set;} // 재고위치
        @AuraEnabled public String weight {get;set;} // weight
        @AuraEnabled public String weightUnit {get;set;} // weightUnit
        public StockInfo() {}
        /**
         * @Description
         * 	- Product 정보 매핑
        **/
        public StockInfo(Product2 prod) {
            this.partName = prod.FM_MaterialDetails__c;
            this.partNumber = prod.ProductCode;
            this.printDate = DateTime.now().format('YYYY.MM.DD');
            this.unit = prod.Unit__c;
            this.weight = String.isNotBlank(String.valueOf(prod.Weight__c)) ? String.valueOf(prod.Weight__c) :'';
            this.weightUnit = String.isNotBlank(prod.WeightUnit__c) ? prod.WeightUnit__c :'';
        }

        /**
         * @Description
         * 	- 대리점 재고 정보 매핑
        **/
        public StockInfo(DealerStock__c dels) {
            this.accountName = dels.Dealer__r.Name;
            this.partName = dels.Part__r.FM_MaterialDetails__c;
            this.partNumber = dels.Part__r.ProductCode;
            this.printDate = DateTime.now().format('YYYY.MM.DD');
            this.currentStockQuantity = dels.CurrentStockQuantity__c;
            this.unit = dels.Part__r.Unit__c;
            if(dels.get('DealerLocation__c') !=null) {
                this.stockLocation =  String.isNotBlank(dels.DealerLocation__r.FM_Loc__c)? dels.DealerLocation__r.FM_Loc__c:'NO Stor. Bin';
            } else {
                this.stockLocation =  'NO Stor. Bin';
            }
            this.weight = String.isNotBlank(String.valueOf(dels.Part__r.Weight__c)) ? String.valueOf(dels.Part__r.Weight__c) :'';
            this.weightUnit = String.isNotBlank(dels.Part__r.WeightUnit__c) ? dels.Part__r.WeightUnit__c :'';
        }
    }

    /**
     * @Description
     * 	- OrderPrint Class
    **/
    public class OrderPrint {
        @AuraEnabled public String id {get;set;} // recordId
        @AuraEnabled public String accountName {get;set;} // 대리점명
        @AuraEnabled public String partName {get;set;} // 주문품명
        @AuraEnabled public String partNumber {get;set;} // 주문품번
        @AuraEnabled public String orderNumber {get;set;} // 오더번호
        @AuraEnabled public String unit {get;set;} // unit
        @AuraEnabled public String shipOrderNumber {get;set;} // DO(출고지시)
        @AuraEnabled public String binLocation {get;set;} // 재고위치
        @AuraEnabled public Decimal quantity {get;set;} // 출고가능수량
        @AuraEnabled public String printDate {get;set;}
        public OrderPrint() {}
        /**
         * @Description
         * 	- DealerOrderItem__c 정보 매핑
        **/
        public OrderPrint(DealerOrderItem__c items) {
            this.id                 = items.Id;
            this.partName           = items.Part__r.Name;
            this.partNumber         = items.Part__r.ProductCode;
            this.orderNumber        = items.Order__r.OrderNumber__c;
            this.quantity           = 0;
            this.printDate          = '';
            this.shipOrderNumber    = '';
            this.binLocation        = 'No Stor. Bin';
            this.unit               = items.FM_Unit__c ;
        }
    }

    /**
     * @Description
     * 	- PrintInfo Class
    **/
    public class PrintInfo{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String accountName {get;set;} // Account
        @AuraEnabled public String orderNumber {get;set;} // 오더정보
        @AuraEnabled public String partName {get;set;} // Part
        @AuraEnabled public String partNumber {get;set;} // Part정보
        @AuraEnabled public String type {get;set;} // 입고, 출고
        @AuraEnabled public String unit {get;set;} // 입고, 출고
        @AuraEnabled public Decimal quantity {get;set;} //입고 수량
        @AuraEnabled public String stockLocation {get;set;} //입고 수량
        @AuraEnabled public String printDate {get;set;} // 출력 날짜
        public PrintInfo() {

        }
        /**
         * @Description
         * 	- PrintInfo 대리점 구매 아이템 기준으로 매핑
        **/
        public PrintInfo(DealerPurchaseOrderItem__c dealerOrder, String type,Map<String,Decimal> recordMap, Map<String,String> stockMap) {
            this.id = dealerOrder.Id;
            this.accountName = dealerOrder.DealerPurchaseOrder__r.Dealer__r.Name;
            this.orderNumber = dealerOrder.DealerPurchaseOrder__r.OrderNumber__c;
            this.partName = dealerOrder.Part__r.FM_MaterialDetails__c;
            this.partNumber = dealerOrder.Part__r.ProductCode;
            this.type = type;
            this.quantity = recordMap.get(dealerOrder.Id);
            this.unit = dealerOrder.Part__r.Unit__c;
            this.stockLocation = stockMap.get(dealerOrder.Part__c);
        }

        /**
         * @Description
         * 	- PrintInfo DNS 구매 아이템 기준으로 매핑
        **/
        public PrintInfo(PurchaseOrderItems__c orderItem, String type, Map<String,Decimal> recordMap,Map<String,String> stockMap) {
            this.id = orderItem.Id;
            this.accountName = 'DNS 구매';
            this.orderNumber = orderItem.PurchaseOrder__r.CustomerOrderNo__c;
            this.partName = orderItem.OrderPartId__r.FM_MaterialDetails__c;
            this.partNumber = orderItem.OrderPartId__r.ProductCode;
            this.quantity = recordMap.get(orderItem.Id);
            this.type = type;
            this.unit = orderItem.OrderPartId__r.Unit__c;
            this.stockLocation = stockMap.get(orderItem.OrderPartId__c);
        }
    }

}