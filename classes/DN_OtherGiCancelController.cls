/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 09. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-09 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_OtherGiCancelController {
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
    public static List<OtherGiCancel> getData(Map<String,Object> whereCondition,String orderByField,String orderBy){
        try {
            System.debug(whereCondition + ' <<==whereCondition');
            String agencyId = currentUser.getAgencyId();
            List<OtherGiCancel> returnList = new List<OtherGiCancel>();
            set<String> giIds = new set<String>();
            String strQ =' select Id, Name,Part__r.FM_MaterialDetails__c,';
            strQ += 'InventoryNumber__c,InventoryItemNumber__c,CreatedDate,';
            strQ += 'Part__c,Part__r.Name,Part__r.ProductCode,';
            strQ += 'Part__r.ProductSpec__c,Quantity__c';
            strQ += ' from DealerInventoryMovements__c';
            String whereQ =' where RecordType.DeveloperName =\'GoodsIssue\'';
            whereQ +=' AND InventoryChange__c =\'H\'';
            whereQ +=' AND Type__c =\'O\'';
            whereQ +=' AND Dealer__c =\''+agencyId+'\' '; 
            //날짜
            List<String> startSet = String.valueOf(whereCondition.get('dateGIStart')).split('-');
            List<String> endSet = String.valueOf(whereCondition.get('dateGIEnd')).split('-');
            DateTime startDate = DateTime.newInstanceGMT(Integer.valueOf(startSet[0]), Integer.valueOf(startSet[1]), Integer.valueOf(startSet[2]));
            DateTime endDate = DateTime.newInstanceGMT(Integer.valueOf(endSet[0]), Integer.valueOf(endSet[1]), Integer.valueOf(endSet[2]),23,59,59);// 설정한 날짜의 마지막 시간
            whereQ += ' AND (CreatedDate >=:startDate AND CreatedDate <=:endDate ) ';
            System.debug(startDate + ' : ::startDate');
            System.debug(endDate + ' : ::endDate');
            //출고문서
            if(whereCondition.get('docNumber') !=null) {
                String docNum = (String) whereCondition.get('docNumber');
                whereQ +=' AND InventoryNumber__c LIKE \'%'+docNum + '%\'';
            }
            //품번
            if(whereCondition.get('productCode') !=null) {
                String productCode = (String) whereCondition.get('productCode');
                whereQ +=' AND Part__c =\''+productCode+'\'';
            }
            
            set<String> partIds = new set<String>();
            System.debug(strQ + whereQ + orderByField+' '+orderBy + ' limit 2000');
            List<DealerInventoryMovements__c> giList = Database.query(strQ + whereQ + orderByField+' '+orderBy + ' limit 2000');
            for(DealerInventoryMovements__c inven: giList) {
                partIds.add(inven.Part__c);
                giIds.add(inven.Id);
            }
            // 현재고 
            Map<String,DealerStock__c> stockMap = new Map<String,DealerStock__c>();
            List<DealerStock__c> stockList = 
                [
                    select 
                        Id, CurrentStockQuantity__c,
                        AvailableQuantity__c, 
                        DealerLocation__c,
                        DealerLocation__r.FM_Loc__c,
                        Part__c
                    from DealerStock__c 
                    where Part__c IN: partIds AND Dealer__c = :agencyId
                ];
            for(DealerStock__c stock : stockList) {
                stockMap.put(stock.Part__c, stock);
            }
            //취소된 목록 조회
            Map<String,Decimal> cancelQTYMap = new Map<String,Decimal>();
            List<AggregateResult> canelResult = 
            [
                select 
                    GoodsIssue__c, 
                    SUM(Quantity__c) Quantity__c 
                from DealerInventoryMovements__c 
                where GoodsIssue__c IN:giIds 
                AND Type__c ='O'
                AND InventoryChange__c ='S'
                group by GoodsIssue__c
            ];
            System.debug(canelResult + ' ::: canelResult');
            for(AggregateResult ages : canelResult) {
                cancelQTYMap.put((String) ages.get('GoodsIssue__c'), (Decimal)ages.get('Quantity__c'));
            }

            // 데이터 매핑
            for(DealerInventoryMovements__c gi: giList) {
                Decimal cancelAvailableQty = cancelQTYMap.get(gi.Id) == null ? gi.Quantity__c  : (gi.Quantity__c - cancelQTYMap.get(gi.Id));
                System.debug(cancelQTYMap.get(gi.Id) + ' :::cancelQTYMap.get(gi.Id)');
                System.debug(cancelAvailableQty + ' :::cancelAvailableQty');
                DealerStock__c stock = stockMap.get(gi.Part__c) == null ? new DealerStock__c() : stockMap.get(gi.Part__c);
                
                if(cancelAvailableQty >0) {
                    
                    OtherGiCancel orders = new OtherGiCancel();
                    orders.id = gi.Id;
                    orders.inventoryNumber          = gi.InventoryNumber__c;
                    orders.itemNumber               = gi.InventoryItemNumber__c;
                    orders.part                     = gi.Part__c;
                    orders.partNumber               = gi.Part__r.ProductCode;
                    orders.partName                 = gi.Part__r.FM_MaterialDetails__c;
                    orders.partSpec                 = gi.Part__r.ProductSpec__c;
                    orders.quantity                 = gi.Quantity__c;
                    orders.location                 = stock.get('DealerLocation__c') == null ? '' : stock.DealerLocation__r.FM_Loc__c;
                    orders.currentStockQuantity     = stock.get('CurrentStockQuantity__c') == null ? 0 : stock.CurrentStockQuantity__c;
                    orders.cancelAvailableQty       = cancelAvailableQty;
                    orders.cancelRequestQty         = 0;
                    orders.goodsIssueDate            = gi.CreatedDate.format('YYYY.MM.dd');
                    returnList.add(orders);
                }
                
            }
            System.debug(returnList + ' :::returnList');
            return returnList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new AuraHandledException(e.getMessage());
        }
    }   
    
    /**
     * @Description
     * 	- 출고 취소
    **/ 
    @AuraEnabled
    public static GIExcel cancelGI(List<OtherGiCancel> otherGiList){
        try {
            System.debug(otherGiList + ' ::: otherGiList');
            set<String> giIds = new set<String>();
            List<DealerInventoryMovements__c> cancelInsertList = new List<DealerInventoryMovements__c>();
            RecordType rec = [select Id, Name, DeveloperName,SobjectType from RecordType where SobjectType ='DealerInventoryMovements__c' AND DeveloperName='GoodsIssue'];
            Map<String,OtherGiCancel> cancelMap = new Map<String,OtherGiCancel>();
            set<String> partIds = new set<String>();
            for(OtherGiCancel gi : otherGiList) {
                //취소가능 수량이 큰 경우
                if(gi.cancelAvailableQty < gi.cancelRequestQty) {
                    throw new DN_OtherGiCancelControllerException(gi.inventoryNumber + ' 취소가능 수량보다 취소 요청 수량이 많습니다.');
                }
                // 취소수량 0인경우
                if(gi.cancelRequestQty ==0) {
                    throw new DN_OtherGiCancelControllerException(gi.inventoryNumber + ' 취소수량을 입력해주세요.');
                }
                cancelMap.put(gi.id,gi);
                giIds.add(gi.id);
                partIds.add(gi.partNumber);
            }
            System.debug(giIds  +' ::: giIds');
            List<DealerInventoryMovements__c> giLIst = 
            [
                select 
                Id,Name ,Part__c,
                CustomerPrice__c,
                DiscountPrice__c,
                DiscountAmount__c
                from DealerInventoryMovements__c where Id IN: giIds FOR UPDATE
            ];
            // 딜러 재고 확인
            Map<String,DealerStock__c> stockMap = new Map<String,DealerStock__c>();
            List<DealerStock__c> stockList = 
                [
                    select 
                        Id, CurrentStockQuantity__c,
                        AvailableQuantity__c, 
                        DealerLocation__c,
                        DealerLocation__r.FM_Loc__c,
                        Part__c
                    from DealerStock__c 
                    where Part__r.ProductCode IN: partIds
                    AND Dealer__c =:currentUser.getAgencyId()
                ];
            for(DealerStock__c stock : stockList) {
                stockMap.put(stock.Part__c, stock);
            }
            System.debug(stockMap + ' :: stockMap');
            //가용재고
            Map<String,Decimal> availableMap = new Map<String,Decimal>();
            //채번
            SequenceGenerator seqGenerator = new SequenceGenerator('DealerInventoryMovements__c');
            String grNumber = seqGenerator.generate(rec.DeveloperName);
            // 출고 취소 CustomerPrice__c는 출고 시점 기준인지 현재시점 기준인지에 따라 추후 인터페이스로 해야할 수 있음
            for(DealerInventoryMovements__c dealerInven : giLIst) {
                DealerInventoryMovements__c inven = new DealerInventoryMovements__c();
                OtherGiCancel cancel = cancelMap.get(dealerInven.Id);
                inven.GoodsIssue__c = dealerInven.Id;
                inven.Type__c = 'O';
                inven.InventoryNumber__c =grNumber;
                inven.Part__c = dealerInven.Part__c;
                inven.RecordTypeId = rec.Id;
                inven.Quantity__c = cancel.cancelRequestQty;
                if(stockMap.get(dealerInven.Part__c) !=null) {
                    inven.DealerStock__c  = stockMap.get(dealerInven.Part__c).Id; 
                }
                inven.CurrencyIsoCode = 'KRW';
                inven.InventoryChange__c = 'S';
                inven.CustomerPrice__c = dealerInven.CustomerPrice__c;
                inven.DiscountPrice__c = dealerInven.DiscountPrice__c;
                inven.DiscountAmount__c = dealerInven.DiscountAmount__c;
                inven.SalesOrganization__c = currentUser.getSalesOranization();
                inven.DistributionChannel__c = currentUser.getDistributionChannel();
                inven.Division__c = currentUser.getDivision();
                inven.Dealer__c  = currentUser.getAgencyId();
                cancelInsertList.add(inven);
                if(availableMap.get(dealerInven.Part__c) == null) {
                    availableMap.put(dealerInven.Part__c,cancel.cancelRequestQty);
                } else {
                    availableMap.put(dealerInven.Part__c,cancel.cancelRequestQty +availableMap.get(dealerInven.Part__c));
                }
                
            }
            insert cancelInsertList;
            set<String> cancelIds = new set<String>();
            for(DealerInventoryMovements__c cancels : cancelInsertList) {
                cancelIds.add(cancels.Id);
            }
            List<DealerInventoryMovements__c> cancelForUpdateList = [
                select Id,
                GoodsIssue__r.InventoryNumber__c,
                Name,
                InventoryNumber__c,Part__r.Name,Part__r.FM_MaterialDetails__c, 
                Part__r.ProductCode, 
                Quantity__c,
                Location__r.FM_Loc__c,
                DealerStock__r.DealerLocation__r.FM_Loc__c,
                CreatedDate,
                Part__c 
                from DealerInventoryMovements__c where Id IN:cancelIds
            ];
            // 채번 업데이트
            seqGenerator.updateNextSequenceInfo();
            System.debug(cancelInsertList + ' ::: cancelInsertList');
            // 출고 취소이므로 가용재고 + 해주기 위해 GR
            DN_DealerStockManager.getAvailable(availableMap,'GR','');
            GIExcel giExcel = new GIExcel();
            giExcel.returnGIList = cancelForUpdateList;
            giExcel.agencyName = currentUser.getAgencyName();
            
            for(DealerInventoryMovements__c cance : cancelForUpdateList) {
                giExcel.createdDate = cance.CreatedDate.format('yyyy-MM-dd'); 
                giExcel.createdTime = cance.CreatedDate.format('HH:mm:ss'); 
                giExcel.doc = cance.InventoryNumber__c;    
            }
            return giExcel;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            System.debug(e.getMessage() + ' Message');
            throw new DN_OtherGiCancelControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 엑셀 헤더 데이터
    **/ 
    public class GIExcel {
        @AuraEnabled public String agencyName {get;set;} // 대리점명
        @AuraEnabled public String doc {get;set;} // 참고문서
        @AuraEnabled public String createdDate {get;set;} 
        @AuraEnabled public String createdTime {get;set;} 
        @AuraEnabled public List<DealerInventoryMovements__c> returnGIList {get;set;} 
        public GIExcel() {
            this.returnGIList = new List<DealerInventoryMovements__c>();
        }
    }

    /**
     * @Description
     * 	- 엑셀 데이터 취소 목록
    **/ 
    public class OtherGiCancel { //GoodsIssue__c
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String inventoryNumber {get;set;}           // 출고번호
        @AuraEnabled public String itemNumber {get;set;}                // 항목
        @AuraEnabled public String part {get;set;}                      // Part 
        @AuraEnabled public String partNumber {get;set;}                // 품번
        @AuraEnabled public String partName {get;set;}                  // 품명
        @AuraEnabled public String partSpec {get;set;}                  // 규격
        @AuraEnabled public Decimal quantity {get;set;}                  // 출고수량

        // 딜러 재고
        @AuraEnabled public String location {get;set;}                  // 저장위치
        @AuraEnabled public Decimal currentStockQuantity {get;set;}      // 현재고
        
        // 계산식
        @AuraEnabled public Decimal cancelAvailableQty {get;set;}        // 취소가능수량
        @AuraEnabled public Decimal cancelRequestQty {get;set;}         // 취소요청수량
        @AuraEnabled public String goodsIssueDate {get;set;}            // 출고일
        
    }

    public class DN_OtherGiCancelControllerException extends Exception {}
}