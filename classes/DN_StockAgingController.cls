/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 02. 20. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-20 | Iltae seo      | 최초작성 
 */
public with sharing class DN_StockAgingController {
    public static set<String> partIDs = new set<string>();
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    /**
     * 대리점의 재고 보유 품번만 조회 (ZSLT0310-CUQTY > 0)
        Last GI Date 가 Search Last GI Before 이후 일 경우 제외
        Last GR Date 가 Search Last GR Before 이후 일 경우 제외
         
        Stock(보유 재고) – ZSLT0310-CUQTY
        Pur.Price : DNS 내수 판매가 // 구매단가
        Sales Price : DNSI 전용 // 판매단
        Last GI Date(최종 출고일) : 출고 이력 에서 최근 출고일 조회 ZSLT0330-ERDAT, 출고 이력이 없으면 ZSLT0310-LAST_EX_DT
                  Last GR Date(최종 입고일) : 입고 이력에서 최근 입고일 조회 ZSLT0320-ERDAT, 입고 이력이 없으면 ZSLT0310-LAST_IM_DT
        GI Yr : Last GI Date 로부터 현재일까지의 경과시간 (년으로 표시 소수점 버림)
        GR Yr : Last GR Date 로부터 현재일까지의 경과시간 (년으로 표시 소수점 버림)
                  Total Value : Stock * Pur.Price
     */
    @AuraEnabled
    public static PageReturn getDataListQuery(PageReturn page, Integer nextPage){
        try {
            PageReturn returnPages = page;
            Map<String,Integer> pageMap = setpageSetting(returnPages,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            Map<String,String> queryMap = getData(returnPages,limitSet);
            System.debug(queryMap.get('dataQuery') +' :: dataQuery');
            // //데이터 조회 
            List<DealerStock__c> dataList = Database.query(queryMap.get('dataQuery'));
            //total size
            returnPages.totalRecordSize = Database.countQuery(queryMap.get('countQuery'));
            returnPages.recordList = new List<StockAging>();
            set<String> productCodeList = new set<String>();

            System.debug(startIdx + ' ::: startIdx');
            System.debug(endIdx + ' ::: endIdx');
            // 시작 데이터 Indx 부터 End Indx까지
            for(Integer i=startIdx-1; i<dataList.size(); i++) {
                if(i < endIdx) {
                    productCodeList.add(dataList[i].Part__r.ProductCode);
                    StockAging wrapper = new StockAging(dataList[i]);
                    
                    returnPages.recordList.add(wrapper);
                } else {
                    break;
                }
            }
            System.debug(returnPages.recordList.size());
            
           // 화면에 데이터 세팅
           returnPages.recordList = getIFDataSetting(returnPages.recordList,productCodeList);
           returnPages.startIdx = startIdx;
           returnPages.endIdx = endIdx;
           returnPages.currentPage = nextPage;
           return returnPages;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' :::e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: message');
            throw new DN_StockAgingControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 엑셀데이터 조회
    **/ 
    @AuraEnabled
    public static PageReturn setExcelData(PageReturn page, Integer nextPage){
        try {
            PageReturn returnPages = page;
            Map<String,Integer> pageMap = setpageSetting(returnPages,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            Map<String,String> queryMap = getData(returnPages,limitSet);
            System.debug(queryMap.get('dataQuery') +' :: dataQuery');
            // //데이터 조회 
            List<DealerStock__c> dataList = Database.query(queryMap.get('dataQuery'));
            returnPages.allData = new List<StockAging>();
            set<String> productCodeList = new set<String>();
            System.debug(startIdx + ' :: startIdx');
            System.debug(endIdx + ' :: endIdx');
            
            // 시작 데이터 Indx 부터 End Indx까지
            for(Integer i=startIdx-1; i<dataList.size(); i++) {
                if(i < endIdx) {
                    System.debug(i + ' ::: iiiii');
                    productCodeList.add(dataList[i].Part__r.ProductCode);
                    StockAging wrapper = new StockAging(dataList[i]);
                    System.debug(wrapper + ' :: wrapper'); 
                    returnPages.allData.add(wrapper);
                
                } else {
                    break;
                }
            }
           // 화면에 데이터 세팅
           returnPages.allData = getIFDataSetting(returnPages.allData,productCodeList);
           
           return returnPages;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' :::e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: message');
            throw new DN_StockAgingControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 데이터 조회 쿼리 설정
    **/ 
    public static Map<String,String> getData(PageReturn returnPages,Integer limitSet) {
        System.debug(returnPages + ' ::: returnPages');
        String strQuery ='SELECT Id,Part__c,Part__r.ProductCode,Part__r.FM_MaterialDetails__c,CurrentStockQuantity__c,';
        strQuery += 'LastImportDateTime__c, LastExportDateTime__c ';
        strQuery += ' FROM DealerStock__c';
        String countQ ='select count() from DealerStock__c ';
        //DAY_ONLY(LastImportDateTime__c) > 2024-12-19
        String whereQ =' WHERE Dealer__c =\''+currentUser.getAgencyId()+'\' AND Part__c !=null';
        whereQ +=' AND CurrentStockQuantity__c >0 ';

        // productCode 
        List<String> productCodeList = new List<String>();
        if( (String) returnPages.strQuery.get('productCode') !=null) {
            String productCode =(String) returnPages.strQuery.get('productCode');
            productCodeList = productCode.split(',');
            set<String> prodIds = new set<String>(productCodeList);
            whereQ += ' AND Part__c IN(\''+String.Join(prodIds,'\',\'') +'\')';
        }

        //LastGR
        if((String) returnPages.strQuery.get('LastGR') !=null) {
            List<String> grDateSet = String.valueOf(returnPages.strQuery.get('LastGR')).split('-');
            whereQ += ' AND (LastImportDateTime__c = null OR DAY_ONLY(LastImportDateTime__c) <= '+ (String)returnPages.strQuery.get('LastGR')+') ';
        }
        //LastGI
        if((String) returnPages.strQuery.get('LastGI') !=null) {
            List<String> giDateSet = String.valueOf(returnPages.strQuery.get('LastGI')).split('-');
            
            whereQ += ' AND (LastExportDateTime__c = null OR DAY_ONLY(LastExportDateTime__c) <= '+(String)returnPages.strQuery.get('LastGI') + ') ';
        }

        Map<String,String> returnMap = new Map<String,String>();
        returnMap.put('dataQuery',strQuery +whereQ+' '+returnPages.orderByField+' '+returnPages.orderBy +' limit ' + limitSet);
        System.debug(returnMap.get('dataQuery'));
        returnMap.put('countQuery',countQ + whereQ +' limit 50000');
        return returnMap;    
    }

    /**
     * @Description
     * 	- 인터페이스 데이터 매핑
    **/ 
    public static List<StockAging> getIFDataSetting(List<StockAging> recordList,set<String> productCodeList) {
        //데이터가 있을 경우 인터페이스 호출
        if(recordList.size() >0) {
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res res = DN_DealerStockManager.dealerStock011(productCodeList);
            Map<String,IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST> partPriceMap = new Map<String,IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST>();
            // 고객 판매가 매핑 - 현재 화면 ERP와 CRM의 부품데이터가 일치해야하는 전제조건이 따름
            for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST detail : res.ET_LIST) {
                partPriceMap.put(detail.MATNR,detail);
            }
            for(StockAging storage : recordList) {
                if(partPriceMap.get(storage.partName) !=null) {
                    storage.purPrice = Decimal.valueOf(partPriceMap.get(storage.partName).DISPR);
                    storage.salesPrice = Decimal.valueOf(partPriceMap.get(storage.partName).NETPR);
                    storage.totalValue = storage.stocQty*storage.purPrice;
                } 
            }
        } 
        return recordList;
    }

    /**
     * @Description
     * 	- param 기준 - 현재일까지 경과값
    **/ 
    public static Decimal getYR(DateTime lastYrDate) {
        Date today = Date.today();
        Date formatDate = lastYrDate.date();
        Decimal yr = formatDate.daysBetween(today);
        return yr;
    }

    /**
     * @Description
     * 	- 페이지 인덱스 설정
    **/ 
    public static Map<string,Integer> setpageSetting(PageReturn returnPages, Integer nextPage) {
        Map<String,Integer> returnMap = new Map<String,Integer>();
        
        // Stage Idx, Last Idx - 인덱스 설정
        Integer startIdx = 0;
        Integer endIdx = 0;
        //페이지 클릭한 경우 처리로직 - 같은 경우 뒤로가기 또는 현재 페이지 클릭
        if(returnPages.currentPage == nextPage) {
            startIdx = (returnPages.currentPage * returnPages.itemsPerPage);
            startIdx = (startIdx - returnPages.itemsPerPage) + 1;
            endIdx = (nextPage*returnPages.itemsPerPage);    
        } else {
            startIdx = (nextPage*returnPages.itemsPerPage -returnPages.itemsPerPage) +1;//(returnPages.currentPage * returnPages.itemsPerPage)+1;
            endIdx = (nextPage*returnPages.itemsPerPage);       
        }
        Integer limitSet = startIdx + endIdx + returnPages.itemsPerPage;
        returnMap.put('limit',limitSet);
        returnMap.put('startIdx',startIdx);
        returnMap.put('endIdx',endIdx);
        return returnMap;
    }

    /**
     * @Description
     * 	- 데이터 리턴 페이징 처리까지
    **/ 
    public class PageReturn {
        @AuraEnabled public Map<String,Object> strQuery { get; set; } // 전체 데이터 쿼리
        @AuraEnabled public Integer totalRecordSize { get; set; } // 전체 레코드 사이즈
        @AuraEnabled public List<StockAging> recordList { get; set; } // 현재 페이지 데이터
        @AuraEnabled public List<StockAging> allData { get; set; } // 전체데이터
        @AuraEnabled public Integer itemsPerPage { get; set; } // 한 페이지당 표시할 데이터 수
        @AuraEnabled public Integer currentPage { get; set; } // 현재 페이지
        @AuraEnabled public Integer pagesPerGroup {get;set;} // 현재 화면에 표시할 페이지 갯수
        @AuraEnabled public Integer startIdx {get;set;} // 시작인덱스
        @AuraEnabled public Integer endIdx {get;set;} // 마지막인덱스
        @AuraEnabled public String orderByField {get;set;} // 정렬 필드,
        @AuraEnabled public String orderBy {get;set;} // 정렬 필드,
        public PageReturn() {} 
    }

    public class StockAging {
        @AuraEnabled public String partId {get;set;}
        @AuraEnabled public String partName {get;set;}
        @AuraEnabled public String partDesc {get;set;}
        @AuraEnabled public Decimal stocQty {get;set;}
        @AuraEnabled public Decimal purPrice {get;set;} // 구매단가
        @AuraEnabled public Decimal salesPrice {get;set;} // 판매단가
        @AuraEnabled public String lastGIDate {get;set;} // Last Gi Date
        @AuraEnabled public Decimal giyr {get;set;} // GI yr
        @AuraEnabled public String lastGRDate {get;set;} // Last Gr Date
        @AuraEnabled public Decimal gryr {get;set;} // GR YR
        @AuraEnabled public Decimal totalValue {get;set;} // Total Value
        
        public StockAging() {}
        public StockAging(DealerStock__c stock) {
            this.partId         = stock.Part__c;                
            this.partName       = stock.Part__r.ProductCode;                    
            this.partDesc       = stock.Part__r.FM_MaterialDetails__c;                    
            this.stocQty        = stock.CurrentStockQuantity__c;                    
            this.purPrice       = 0;                    
            this.salesPrice     = 0;                    
            this.lastGIDate     = stock.LastExportDateTime__c == null ? '' : stock.LastExportDateTime__c.format('YYYY.MM.dd');                    
            this.giyr           = stock.LastExportDateTime__c == null ? null : getYR(stock.LastExportDateTime__c);                    
            this.lastGRDate     = stock.LastImportDateTime__c == null ? '' : stock.LastImportDateTime__c.format('YYYY.MM.dd');                    
            this.gryr           = stock.LastImportDateTime__c == null ? null : getYR(stock.LastImportDateTime__c);                    
            this.totalValue     = 0;                    
        }
        
        
        
        
        
        
        
        
        
        
        
    }

    public class DN_StockAgingControllerException extends Exception {}
}