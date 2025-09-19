/** 
 * @Class : DN_ShipInstructionManagementController
 * 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 06. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-06 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_ShipInstructionManagementController {
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
    public static PageReturn getDataListQuery(PageReturn page, Integer nextPage){
        try {
            System.debug(page +' <= ==page');
            System.debug(nextPage + ' < ==nextPage');
            
            // limit 2000건
            PageReturn returnPages = page;
            
            returnPages.recordList = new List<sObject>();
            returnPages.excelReturnList = new List<ExcelReturn>();
            String strQuery ='';
            String whereQ ='';
            // 출고지시일자
            List<String> startSet = String.valueOf(page.strQuery.get('dateStart')).split('-');
            List<String> endSet = String.valueOf(page.strQuery.get('dateEnd')).split('-');
            DateTime startDate = DateTime.newInstanceGMT(Integer.valueOf(startSet[0]), Integer.valueOf(startSet[1]), Integer.valueOf(startSet[2]));
            DateTime endDate = DateTime.newInstanceGMT(Integer.valueOf(endSet[0]), Integer.valueOf(endSet[1]), Integer.valueOf(endSet[2]),23,59,59);// 설정한 날짜의 마지막 시간
            
            strQuery += 'select Id,DealerOrderItem__r.Part__r.FM_MaterialDetails__c,DealerOrderItem__r.Order__r.CustomerPurchaseOrderNumber__c , Name '; //FM_MaterialDetails__c 
            strQuery += ' ,FM_DeliveryDate__c, DealerOrderItem__r.OrderItemNumber__c,DealerOrderItem__r.Part__r.Name,DealerOrderItem__r.Part__r.ProductCode,CreatedDate, format(CreatedDate) formatDate, FM_DeliveryTime__c';
            strQuery += ' ,Quantity__c,DiscountAmount__c,CurrencyIsoCode,DealerOrderItem__r.Order__r.OrderNumber__c,FM_OrderItemNumber__c, DealerOrderItem__c, DealerOrderItem__r.Part__c';
            strQuery += ' ,toLabel(DealerOrderItem__r.Order__r.ShippingType__c) ShippingType__c';
            strQuery += ' ,DealerOrderItem__r.Order__r.Customer__c';
            strQuery += ' ,DealerOrderItem__r.Order__r.FM_ShipToName__c';
            strQuery += ' ,DealerOrderItem__r.Order__r.FM_CustomerName__c';
            strQuery += ' ,DealerOrderItem__r.Order__r.FM_Representative__c';
            strQuery += ' ,DealerOrderItem__r.Order__r.FM_PostalCode__c';
            strQuery += ' ,DealerOrderItem__r.Order__r.FM_Phone__c';
            strQuery += ' ,DealerOrderItem__r.Order__r.FM_CustomerCode__c,ShipmentOrderNumber__c';
            strQuery += ' ,DeliveryOrder__c';
            whereQ += ' from ShipmentOrder__c where Delete__c = \'N\'';
            whereQ += ' AND Dealer__c = \''+currentUser.getAgencyId()+'\'';
            whereQ += ' AND (CreatedDate >=:startDate AND CreatedDate <=:endDate )';
            //whereQ += ' AND DealerOrderItem__r.Status__c !=\'C\'';
            whereQ += ' AND DealerOrderItem__r.FM_PendingQuantity__c > 0';
            System.debug(page.strQuery + ' :::: page.strQuery');
            // 출고지시번호
            if( String.isNotBlank((String) page.strQuery.get('DeliveryOrder__c'))) {
                whereQ += ' AND DeliveryOrder__c =\''+ (String) page.strQuery.get('DeliveryOrder__c') +'\'';    
            }
            // 고객코드
            if( String.isNotBlank((String) page.strQuery.get('FM_CustomerCode__c'))) {
                whereQ += ' AND DealerOrderItem__r.Order__r.FM_CustomerCode__c=\''+  (String) page.strQuery.get('FM_CustomerCode__c') +'\'';    
            }
            // 주문번호
            if( String.isNotBlank((String) page.strQuery.get('FM_DealerOrder__c'))) {
                whereQ += ' AND FM_DealerOrder__c=\''+  (String) page.strQuery.get('FM_DealerOrder__c') +'\'';    
            }
            System.debug(whereQ + ' :: whereQ');
            // 재고위치Map
            Map<String,String> stockMap = new Map<String,String>();
            System.debug(strQuery +whereQ+' '+returnPages.orderByField+' '+returnPages.orderBy +' limit 2000' + ' query ::');
            returnPages.recordList = Database.query(strQuery +whereQ+' '+returnPages.orderByField+' '+returnPages.orderBy +' limit 2000');
            for(ShipmentOrder__c rec : returnPages.recordList) {
                System.debug(rec + ' rec');
                stockMap.put(rec.DealerOrderItem__r.Part__c,'');
            }
            List<DealerStock__c> locationList = [select Part__c,DealerLocation__r.FM_Loc__c,Dealer__c from DealerStock__c where Dealer__c =:currentUser.getAgencyId() AND Part__c IN : stockMap.keySet()];
            for(DealerStock__c stock : locationList) {
                stockMap.put(stock.Part__c, stock.DealerLocation__r.FM_Loc__c);
            }

            returnPages.totalRecordSize = Database.countQuery('select count() '+whereQ+' limit 50000');
            List<ShipmentOrder__c> recordListSet = new List<ShipmentOrder__c>();
            // Stage Idx, Last Idx
            Integer startIdx = 0;
            Integer endIdx = 0;
            // 같은 경우 뒤로가기 또는 현재 페이지 클릭
            if(returnPages.currentPage == nextPage) {
                startIdx = (returnPages.currentPage * returnPages.itemsPerPage);
                startIdx = (startIdx - returnPages.itemsPerPage) + 1;
                endIdx = (nextPage*returnPages.itemsPerPage);    
            } else {
                startIdx = (nextPage*returnPages.itemsPerPage -returnPages.itemsPerPage) +1;//(returnPages.currentPage * returnPages.itemsPerPage)+1;
                endIdx = (nextPage*returnPages.itemsPerPage);    
                
            }
            for(Integer i=startIdx-1; i<returnPages.recordList.size(); i++) {
                // 시작 데이터 Indx 부터 End Indx까지
                if(i < endIdx) {
                    recordListSet.add(returnPages.recordList[i]);
                } else {
                    break;
                }
            }
            for(ShipmentOrder__c obj : recordListSet) {
                ExcelReturn excel = new ExcelReturn();
                excel.id = obj.Id;
                excel.deliveryTime = obj.CreatedDate.format('HH:mm:ss');//DateTime.valueOf(obj.get('CreatedDate')).format('HH:mm:ss');
                excel.location = stockMap.get( obj.DealerOrderItem__r.Part__c) == null ? '' : stockMap.get( obj.DealerOrderItem__r.Part__c);
                returnPages.excelReturnList.add(excel);
            }
            System.debug(recordListSet + ' :returnPages.recordList');
            //리스트 정리 후 재할당
            returnPages.recordList = recordListSet;
            returnPages.startIdx = startIdx;
            returnPages.endIdx = endIdx;
            returnPages.currentPage = nextPage;
            
            return returnPages;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' :::e.getMessage()');
            System.debug(e.getStackTraceString() + ' :::e.getMessage()');
            throw new DN_ShipInstructionManagementControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 저장 - 출고지시 수량 업데이트,체크박스 유무 상관없이 화면에서 수정한 값 업데이트
    **/ 
    @AuraEnabled
    public static void updateQuantity(List<ShipmentOrder> shipList){
        try {
            Map<String,Decimal> shipMap = new Map<String,Decimal>();
            Map<String,OrderGroup> orderNumberGroupMap = new Map<String,OrderGroup>();
            Map<String,Decimal> orderNumberByTotal = new Map<String,Decimal>();
            for(ShipmentOrder ship : shipList) {
                shipMap.put(ship.id, ship.quantity);
            }
            List<AggregateResult> orderNumberGroupList = 
            [
                select  DealerOrderItem__r.Order__r.OrderNumber__c, 
                MAX(DealerOrderItem__r.Quantity__c) OrderQuantity, 
                SUM(Quantity__c) Quantity__c 
                from ShipmentOrder__c where Id IN:shipMap.keySet()
                GROUP BY DealerOrderItem__r.Order__r.OrderNumber__c
            ];
            for(AggregateResult result : orderNumberGroupList) {
                OrderGroup orderGroup = new OrderGroup(result);
                orderNumberGroupMap.put((String)result.get('OrderNumber__c'), orderGroup); 
            }
            List<ShipmentOrder__c> updateList = [select Id,Name,Quantity__c,DealerOrderItem__r.Order__r.OrderNumber__c,DeliveryOrder__c from ShipmentOrder__c where Id IN:shipMap.keySet() FOR UPDATE];
            for(ShipmentOrder__c shipUpdate : updateList) {
                OrderGroup currentOrder = orderNumberGroupMap.get(shipUpdate.DealerOrderItem__r.Order__r.OrderNumber__c);
                //출고지시 가능수량보다 해당 출고지시의 수량을 높게 입력한 경우
                if(currentOrder.orderQuantity < shipMap.get(shipUpdate.Id)) {
                    throw new DN_ShipInstructionManagementControllerException('출고지시번호 : ' + shipUpdate.DeliveryOrder__c + ' 출고지시 가능 수량을 초과했습니다.');        
                }
                Decimal totalQTY = orderNumberByTotal.get(shipUpdate.DealerOrderItem__r.Order__r.OrderNumber__c) == null ? shipMap.get(shipUpdate.Id) : orderNumberByTotal.get(shipUpdate.DealerOrderItem__r.Order__r.OrderNumber__c) + shipMap.get(shipUpdate.Id);
                orderNumberByTotal.put(shipUpdate.DealerOrderItem__r.Order__r.OrderNumber__c,totalQTY);
                shipUpdate.Quantity__c = shipMap.get(shipUpdate.Id);
            }
            System.debug(orderNumberByTotal + ' < ==orderNumberByTotal');
            for(String orderNubmer : orderNumberByTotal.keySet()) {
                OrderGroup order = orderNumberGroupMap.get(orderNubmer);
                if(order.orderQuantity < orderNumberByTotal.get(orderNubmer)) {
                    throw new DN_ShipInstructionManagementControllerException('주문번호 : ' + orderNubmer + ' 출고지시 가능 수량을 초과했습니다.');        
                }
            }
            update updateList;
        } catch (Exception e) {
            throw new DN_ShipInstructionManagementControllerException(e.getMessage());
        }
    }
    
    /**
     * @Description
     * 	- GROUP By Order Class
    **/
    public class OrderGroup {
        public Decimal orderQuantity {get;set;} 
        public Decimal quantity {get;set;} 
        public OrderGroup() {}
        public OrderGroup(AggregateResult result) {
            this.orderQuantity = (Decimal)result.get('OrderQuantity');
            this.quantity = (Decimal)result.get('Quantity__c');
        }
    }

    /**
     * @Description
     * 	- 출고지시 Class
    **/
    public class ShipmentOrder {
        @AuraEnabled public String id {get;set;} // id
        @AuraEnabled public Decimal quantity {get;set;} // quantity
    }

    /**
     * @Description
     * 	- 데이터 리턴 페이징 처리까지
    **/
    public class PageReturn {
        @AuraEnabled public Map<String,Object> strQuery { get; set; } // 전체 데이터 쿼리
        @AuraEnabled public Integer totalRecordSize { get; set; } // 전체 레코드 사이즈
        @AuraEnabled public List<ShipmentOrder__c> recordList { get; set; } // 현재 페이지 데이터
        
        @AuraEnabled public Integer itemsPerPage { get; set; } // 한 페이지당 표시할 데이터 수
        @AuraEnabled public Integer currentPage { get; set; } // 현재 페이지
        @AuraEnabled public Integer pagesPerGroup {get;set;} // 현재 화면에 표시할 페이지 갯수
        @AuraEnabled public Integer startIdx {get;set;} // 시작인덱스
        @AuraEnabled public Integer endIdx {get;set;} // 마지막인덱스
        @AuraEnabled public String orderByField {get;set;} // 정렬 필드,
        @AuraEnabled public String orderBy {get;set;} // 정렬 필드,
        @AuraEnabled public List<ExcelReturn> excelReturnList {get;set;} // 엑셀데이터         
        public PageReturn() {

        } 
    }

    /**
     * @Description
     * 	- 엑셀 데이터
    **/
    public class ExcelReturn {
        @AuraEnabled public String id { get; set; } 
        @AuraEnabled public String deliveryTime { get; set; } 
        @AuraEnabled public String location { get; set; } 
    }
    public class DN_ShipInstructionManagementControllerException extends Exception {}
}