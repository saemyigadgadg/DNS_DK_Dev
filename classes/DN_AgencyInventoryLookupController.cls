/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 20. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-20 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_AgencyInventoryLookupController {
    /**
     * @Description
     * 	- 현재 페이지 정보 조회 - 인터페이스로 판매가정보도 조회
    **/ 
    @AuraEnabled
    public static PageReturn getDataListQuery(PageReturn page, Integer nextPage){
        try {
            System.debug(page+' :::: page');
            PageReturn returnPages = page;
            Map<String,Integer> pageMap = setpageSetting(returnPages,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            Map<String,String> queryMap = getData(returnPages,limitSet);
            // //데이터 조회 
            List<DealerStock__c> dataList = Database.query(queryMap.get('dataQuery'));
           
            //total size
            String countQ = 'select count() from DealerStock__c';
            returnPages.totalRecordSize = Database.countQuery(queryMap.get('countQuery'));
            
            returnPages.recordList = new List<StorageChange>();
            returnPages.allData = new List<StorageChange>();
            set<String> productCodeList = new set<String>();
            // 시작 데이터 Indx 부터 End Indx까지
            for(Integer i=startIdx-1; i<dataList.size(); i++) {
                if(i < endIdx) {
                    productCodeList.add(dataList[i].Part__r.ProductCode.toUpperCase());
                    StorageChange wrapper = new StorageChange(dataList[i]);
                    returnPages.recordList.add(wrapper);
                } else {
                    break;
                }
            }

            // 화면에 데이터 세팅
            returnPages.recordList = getIFDataSetting(returnPages.recordList,productCodeList);
            returnPages.startIdx = startIdx;
            returnPages.endIdx = endIdx;
            returnPages.currentPage = nextPage;

            return returnPages;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' :::e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: message');
            throw new DN_AgencyInventoryLookupControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 엑셀데이터 불러오기
    **/
    @AuraEnabled
    public static PageReturn setExcelData(PageReturn page, Integer nextPage){
        try {
            System.debug(nextPage + ' ::: nextPage');
            PageReturn returnPages = page;
            Map<String,Integer> pageMap = setpageSetting(returnPages,nextPage);
            Integer limitSet = pageMap.get('limit');
            System.debug(limitSet + ' ::: limitSet');
            Integer startIdx = pageMap.get('startIdx');
            System.debug(startIdx + ' ::: startIdx');
            Integer endIdx = pageMap.get('endIdx');
            System.debug(endIdx + ' ::: endIdx');
            Map<String,String> queryMap = getData(returnPages,limitSet);
            // //데이터 조회 
            List<DealerStock__c> dataList = Database.query(queryMap.get('dataQuery'));
            returnPages.allData = new List<StorageChange>();
            set<String> productCodeList = new set<String>();
            // 시작 데이터 Indx 부터 End Indx까지
            for(Integer i=startIdx-1; i<dataList.size(); i++) {
                if(i < endIdx) {
                    productCodeList.add(dataList[i].Part__r.ProductCode);
                    StorageChange wrapper = new StorageChange(dataList[i]);
                    //returnMap.put(wrapper.id,wrapper);
                    returnPages.allData.add(wrapper);
                } else {
                    break;
                }
            }
            returnPages.allData = getIFDataSetting(returnPages.allData,productCodeList);
            return returnPages;
        } catch (Exception e) {
            System.debug(e.getMessage()+ ' getMessage');
            System.debug(e.getStackTraceString()+ ' getStackTraceString');
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    /**
     * @Description
     * 	- 저장위치 상세 정보
    **/
    @AuraEnabled
    public static List<DealerStock__c> storageBinDetailInfo(String fmLoc, String dealerId){
        try {
            System.debug(dealerId + ' ::: dealerId');
            List<DealerStock__c> returnDealerStockList = [
                select Id, Name,
                Part__r.ProductCode,  
                DealerLocation__r.FM_Loc__c,
                DealerLocation__r.Description__c 
                from DealerStock__c 
                where Dealer__c =:dealerId
                AND DealerLocation__r.FM_Loc__c =:fmLoc
            ];
            return returnDealerStockList;
            //select Id, Name, DealerLocation__r.FM_Loc__c,DealerLocation__r.Description__c from DealerStock__c where Dealer__c = AND DealerLocation__r.FM_Loc__c =''
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 조회조건 쿼리
    **/
    public static Map<String,String> getData(PageReturn returnPages,Integer limitSet) {
        String strQuery ='';
        String whereQ ='';
        String countQ = 'select count() from DealerStock__c';
        strQuery += 'select Id, Name,';
        strQuery += ' Part__c,';
        strQuery += ' Part__r.Weight__c,';
        strQuery += ' Part__r.WeightUnit__c,';
        strQuery += ' Part__r.FM_MaterialDetails__c,';
        strQuery += ' Part__r.ProductCode,';
        strQuery += ' Part__r.ProductSpec__c,';
        strQuery += ' CurrentStockQuantity__c,';
        strQuery += ' AvailableQuantity__c,';
        strQuery += ' LastImportDateTime__c,';
        strQuery += ' DealerLocation__c,';
        strQuery += ' DealerLocation__r.Description__c,';
        strQuery += ' Dealer__r.Name,';
        strQuery += ' Dealer__r.Id,';
        strQuery += ' DealerLocation__r.FM_Loc__c from DealerStock__c';
        whereQ += ' WHERE Id !=null AND Part__c !=null ';
        
        if((String) returnPages.strQuery.get('CustomerName') !='All') {
            String customerId =(String) returnPages.strQuery.get('CustomerName');
            System.debug(customerId + ' ::: customerId');
            List<DealerCustomer__c> customer = [select SourceAccount__c  from DealerCustomer__c where Id =:customerId];
            System.debug(customer + ' ::: customer');
            set<String> accIds = new set<String>();
            for(DealerCustomer__c cust : customer) {
                accIds.add(cust.SourceAccount__c);
            }
            System.debug(accIds + ' ::: accIds');
            whereQ += ' AND Dealer__c=\''+customer[0].SourceAccount__c+'\'';
        }

        //stockOption
        if( (String) returnPages.strQuery.get('stockOption') !='All') {
            String stockOption =(String) returnPages.strQuery.get('stockOption');
            whereQ += stockOption == '0' ? ' AND CurrentStockQuantity__c =0': ' AND CurrentStockQuantity__c !=0';
        }
        
        // productCode
        List<String> productCodeSet = new List<String>();
        if( (String) returnPages.strQuery.get('productCode') !=null) {
            String productCode =(String) returnPages.strQuery.get('productCode');
            productCodeSet = productCode.split(',');
            whereQ += ' AND Part__c IN(\''+String.join(productCodeSet, '\',\'') + '\')';
        }
        // location
        if( (String) returnPages.strQuery.get('location') !=null) {
            String location =(String) returnPages.strQuery.get('location');
            whereQ += ' AND DealerLocation__c=\''+location+'\'';
        }
        // binOption
        if( (String) returnPages.strQuery.get('binOption') !='All') {
            String binOption =(String) returnPages.strQuery.get('binOption');
            if(binOption != 'Multi') {
                whereQ += ' AND DealerLocation__c =null';  
            } else {
                List<AggregateResult> agees = Database.query('SELECT COUNT(Id),DealerLocation__c FROM DealerStock__c WHERE DealerLocation__c!=null GROUP BY DealerLocation__c having COUNT(Id) > 1 LIMIT 2000');
                System.debug('SELECT COUNT(Id),DealerLocation__c FROM DealerStock__c' + ' WHERE DealerLocation__c!=null GROUP BY DealerLocation__c having COUNT(Id) > 1' + ' DEBUG __222');
                set<String> locationIds = new set<String>();
                for(AggregateResult result : agees) {
                    locationIds.add((String)result.get('DealerLocation__c'));
                }
                whereQ += ' AND DealerLocation__c IN(\''+String.join(locationIds, '\',\'') + '\')';
            }
        }
        System.debug(strQuery +whereQ+' '+returnPages.orderByField+' '+returnPages.orderBy +' limit ' + limitSet + ' DEBUG __'); 
        Map<String,String> returnMap = new Map<String,String>();
        returnMap.put('dataQuery',strQuery +whereQ+' '+returnPages.orderByField+' '+returnPages.orderBy +' limit ' + limitSet);
        returnMap.put('countQuery',countQ + whereQ +' limit 50000');
        return returnMap;
    }

    /**
     * @Description
     * 	- 인터페이스 데이터 매핑
    **/
    public static List<StorageChange> getIFDataSetting(List<StorageChange> recordList,set<String> productCodeList) {
        //데이터가 있을 경우 인터페이스 호출
        if(recordList.size() >0) {
            System.debug(productCodeList + ' ::: productCodeList');
            Map<String,IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL> partPriceMap = new Map<String,IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL>();
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res res = DN_DealerStockManager.getPartSearch(productCodeList);
            System.debug(res + ' :: res');
            if(res.D_DETAIL !=null) {
                // 고객 판매가 매핑 - 현재 화면 ERP와 CRM의 부품데이터가 일치해야하는 전제조건이 따름
                for(IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL detail : res.D_DETAIL) {
                    partPriceMap.put(detail.MATNR,detail);
                }
                System.debug(partPriceMap + ' ::: partPriceMap');
                for(StorageChange storage : recordList) {
                    if(partPriceMap.get(storage.partNumber) !=null) {
                        storage.listPrice = Decimal.valueOf(partPriceMap.get(storage.partNumber).NETPR);
                    } else {
                        storage.listPrice = 1;
                    }
                }
            }
            
        } 
        return recordList;
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
        @AuraEnabled public List<StorageChange> recordList { get; set; } // 현재 페이지 데이터
        @AuraEnabled public List<StorageChange> allData { get; set; } // 전체데이터
        @AuraEnabled public Integer itemsPerPage { get; set; } // 한 페이지당 표시할 데이터 수
        @AuraEnabled public Integer currentPage { get; set; } // 현재 페이지
        @AuraEnabled public Integer pagesPerGroup {get;set;} // 현재 화면에 표시할 페이지 갯수
        @AuraEnabled public Integer startIdx {get;set;} // 시작인덱스
        @AuraEnabled public Integer endIdx {get;set;} // 마지막인덱스
        @AuraEnabled public String orderByField {get;set;} // 정렬 필드,
        @AuraEnabled public String orderBy {get;set;} // 정렬 필드,
        public PageReturn() {} 
    }

    /**
     * @Description
     * 	- 구매단가, 판매단가 추가 예정 DealerLocation__r.Description__c
    **/
    public class StorageChange {
        @AuraEnabled public String id { get; set; } // id
        @AuraEnabled public String dealerName { get; set; } // 대리점명
        @AuraEnabled public String dealerCode { get; set; } // 대리점Id
        @AuraEnabled public String partId { get; set; } // Part
        @AuraEnabled public String partName { get; set; } // 품번
        @AuraEnabled public String partNumber { get; set; } // 품명
        @AuraEnabled public String partSpec { get; set; } // 규격(스펙)
        @AuraEnabled public Decimal currentStockQuantity  { get; set; } // 재고량
        @AuraEnabled public String locationId { get; set; } // 저장위치 Id
        @AuraEnabled public String location { get; set; } // 저장위치
        @AuraEnabled public String description { get; set; } // 저장위치 설명
        @AuraEnabled public Decimal listPrice  { get; set; } // 판매단가
        public StorageChange() {}
        public StorageChange(DealerStock__c stock) {
            this.id = stock.Id;
            this.partId = stock.Part__c;
            this.partName = stock.Part__r.FM_MaterialDetails__c;
            this.dealerName = stock.Dealer__r.Name;
            this.dealerCode = stock.Dealer__r.Id;
            this.partNumber = stock.Part__r.ProductCode;
            this.partSpec = String.isNotBlank(stock.Part__r.ProductSpec__c) ? stock.Part__r.ProductSpec__c : '';
            this.currentStockQuantity = stock.CurrentStockQuantity__c;
            if(stock.get('DealerLocation__c') !=null) {
                this.locationId = stock.DealerLocation__c;
                this.location = String.isNotBlank(stock.DealerLocation__r.FM_Loc__c) ? stock.DealerLocation__r.FM_Loc__c :'';
                this.description = String.isNotBlank(stock.DealerLocation__r.Description__c) ? stock.DealerLocation__r.Description__c :'';
            } else {
                this.locationId = '';
                this.location = '';
                this.description = '';
            }
        }
    }

    public class DN_AgencyInventoryLookupControllerException extends Exception {}
}