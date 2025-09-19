/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 08. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-08 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_StorageBinCreateChangeController {
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
            System.debug(page + ' ::: page');
            PageReturn returnPages = page;
            Map<String,Integer> pageMap = setpageSetting(returnPages,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            Map<String,String> queryMap = getData(returnPages,limitSet);
            System.debug(queryMap.get('dataQuery') +' :: dataQuery');
            // //데이터 조회 
            List<DealerStock__c> dataList = Database.query(queryMap.get('dataQuery')+ ' LIMIT 2000');
            System.debug(dataList + ' :":: dataList');
            //total size
            returnPages.totalRecordSize = Database.countQuery(queryMap.get('countQuery'));
            returnPages.recordList = new List<StorageChange>();
            returnPages.allData = new List<StorageChange>();
            set<String> productCodeList = new set<String>();
            
            // 시작 데이터 Indx 부터 End Indx까지
            for(Integer i=startIdx-1; i<dataList.size(); i++) {
                if(i < endIdx) {
                    productCodeList.add(dataList[i].Part__r.ProductCode);
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
            throw new DN_StorageBinCreateChangeControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 엑셀 데이터 불러오기
    **/ 
    @AuraEnabled
    public static PageReturn setExcelData(PageReturn page, Integer nextPage){
        try {
            PageReturn returnPages = page;
            //returnPages.itemsPerPage = 50;
            Map<String,Integer> pageMap = setpageSetting(returnPages,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            Map<String,String> queryMap = getData(returnPages,limitSet);
            // //데이터 조회 
            List<DealerStock__c> dataList = Database.query(queryMap.get('dataQuery')+ ' LIMIT '+limitSet);
            
            returnPages.recordList = new List<StorageChange>();
            returnPages.allData = new List<StorageChange>();
            set<String> productCodeList = new set<String>();            
            // 시작 데이터 Indx 부터 End Indx까지
            for(Integer i=startIdx-1; i<dataList.size(); i++) {
                if(i < endIdx) {
                    productCodeList.add(dataList[i].Part__r.ProductCode);
                    StorageChange wrapper = new StorageChange(dataList[i]);
                    returnPages.allData.add(wrapper);
                } else {
                    break;
                }
            }
            //System.debug(recordListSet[0] + ' :::recordListSet[0]');
            System.debug(productCodeList.size());
           // 화면에 데이터 세팅
           returnPages.allData = getIFDataSetting(returnPages.allData,productCodeList);
           System.debug(returnPages.allData + ' :: returnPages.allData');
            return returnPages;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' :::e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: message');
            throw new DN_StorageBinCreateChangeControllerException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- 액셀 업로드 - 저장위치 생성
    **/ 
    @AuraEnabled
    public static void excelUpload(Map<String,String> uploadMap){
        try {
            // 1. 해당부품이 부품조회가 안되면 에러 발생
            // 2. 재고 위치가 없으면 재고 위치 생성
            // 3. 해당부품이 딜러재고에 없으면 새로 생성
            // 4. 재고 위치가 있으면 해당 위치로 설정
            List<DealerStock__c> dmlStockList = new List<DealerStock__c>();
            List<DealerLocation__c> dmlLocationList = new List<DealerLocation__c>();
            Map<String,String> prodMap = new Map<String,String>();
            Map<String,String> locationMap = new Map<String,String>();            
            // 부품 정보 조회
            List<Product2> productList = [select Id, Name,ProductCode from Product2 where ProductCode IN : uploadMap.keySet() AND RecordType.DeveloperName='Part'];
            for(Product2 prod :productList) {
                prodMap.put(prod.ProductCode, prod.Id);
            }
            // 부품 없으면 에러
            List<String> errorMsg = new List<String>();
            for(String ex : uploadMap.keySet()) {
                System.debug(ex.toUpperCase() + ' ::::ex.toUpperCase()');
                SYstem.debug(prodMap + ' ::: prodMap');
                if(prodMap.get(ex.toUpperCase()) ==null) {
                    errorMsg.add(ex.toUpperCase());
                }
            }
            if(errorMsg.size()>0) {
                throw new DN_StorageBinCreateChangeControllerException( errorMsg+' 부품정보가 올바르지 않습니다.');    
            }
            System.debug(uploadMap.values());
            // 저장 위치 조회
            List<DealerLocation__c> locationList = [select Id, Name, FM_Loc__c from DealerLocation__c where FM_Loc__c IN:uploadMap.values()];
            System.debug(locationList + ' :::::locationList');
            for(DealerLocation__c loc : locationList) {
                locationMap.put(loc.FM_Loc__c, loc.Id);
            }
            // 저장 위치 없는 경우 생성
            for(String fmLoc : uploadMap.values()) {
                
                if(locationMap.get(fmLoc) ==null) {
                    List<String> fmList = fmLoc.split('-');
                    DealerLocation__c location = new DealerLocation__c();
                    for(Integer i=0; i<fmList.size(); i++) {
                        String locSet = 'Loc'+(i+1)+'__c';
                        location.put(locSet, fmList[i]);
                    }
                    location.Dealer__c = currentUser.getAgencyId();
                    location.Division__c = currentUser.getDivision();
                    location.DistributionChannel__c = currentUser.getDistributionChannel();
                    location.SalesOrganization__c = currentUser.getSalesOranization();
                    dmlLocationList.add(location);
                   
                }
            }
            System.debug(dmlLocationList + ' :::::dmlLocationList');
            if(dmlLocationList.size() >0) {
                insert dmlLocationList;
            }
            // 저장위치 생성 후 재조회
            List<DealerLocation__c> afterLocationList = [select Id, Name, FM_Loc__c from DealerLocation__c where FM_Loc__c IN:uploadMap.values() FOR UPDATE];
            for(DealerLocation__c loc : afterLocationList) {
                locationMap.put(loc.FM_Loc__c, loc.Id);
            }

            //딜러 재고 조회
            List<DealerStock__c> stockList = [
                select Id, Name,Part__c,
                Part__r.ProductCode,DealerLocation__c,
                DealerLocation__r.FM_Loc__c,ExternalKey__c 
                from DealerStock__c 
                where Part__c IN : prodMap.keySet() 
                AND Dealer__c =:currentUser.getAgencyId() 
                FOR UPDATE
            ];        
            SySTem.debug(uploadMap + ' :: uploadMap');    
            for(String upload : uploadMap.keySet() ) {
                DealerStock__c dec = new DealerStock__c(
                    SalesOrganization__c    = currentUser.getSalesOranization(),
                    DistributionChannel__c  = currentUser.getDistributionChannel(),
                    Division__c             = currentUser.getDivision(),
                    Dealer__c               = currentUser.getAgencyId(),
                    Part__c                 = prodMap.get(upload.toUpperCase()),
                    DealerLocation__c       = locationMap.get(uploadMap.get(upload)),
                    ExternalKey__c          = currentUser.getSalesOranization() +'-'+currentUser.getDistributionChannel() +'-'+currentUser.getDivision()+'-'+currentUser.getAgencyCustomerCode()+'-'+upload
                );
                dmlStockList.add(dec);
            }
            upsert dmlStockList ExternalKey__c;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' :::e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: message');
            throw new DN_StorageBinCreateChangeControllerException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- 저장위치 상세 정보
    **/ 
    @AuraEnabled
    public static List<DealerStock__c> storageBinDetailInfo(String fmLoc){
        try {
            List<DealerStock__c> returnDealerStockList = [
                select Id, Name,
                Part__r.ProductCode,  
                DealerLocation__r.FM_Loc__c,
                DealerLocation__r.Description__c 
                from DealerStock__c 
                where Dealer__c =:currentUser.getAgencyId()
                AND DealerLocation__r.FM_Loc__c =:fmLoc
            ];
            return returnDealerStockList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- 저장위치 삭제
    **/ 
    @AuraEnabled
    public static void deleteBin(List<String> stockIds){
        try {
            System.debug(stockIds + ' < ==stockIds');
            List<DealerStock__c> binDeleteStockList = [select Id, DealerLocation__c from DealerStock__c where Id IN: stockIds FOR UPDATE];
            for(DealerStock__c stock : binDeleteStockList) {
                stock.DealerLocation__c =null;
            }
            update binDeleteStockList;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' :::e.getStackTraceString()');
            System.debug(e.getMessage() + ' ::: message');
            throw new DN_StorageBinCreateChangeControllerException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- 데이터 조회 쿼리 설정
    **/ 
    public static Map<String,String> getData(PageReturn returnPages,Integer limitSet) {
        User user = [select Id, Name, Account.Name,Account.Id, DistributionChannel__c,Division__c,SalesOrganization__c,SalesDistrict__c,SalesOffice__c,Plant__c,Account.CustomerCode__c from User where Id=:UserInfo.getUserId()];
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
        whereQ += ' WHERE Dealer__c =\''+currentUser.getAgencyId()+'\'';
        whereQ += ' AND SalesOrganization__c =\''+currentUser.getSalesOranization()+'\''; 
        whereQ += ' AND DistributionChannel__c =\''+currentUser.getDistributionChannel()+'\''; 
        whereQ += ' AND Division__c =\''+currentUser.getDivision()+'\''; 
        whereQ += ' AND Part__c !=null '; 
        //stockOption
        if( (String) returnPages.strQuery.get('stockOption') !='All') {
            String stockOption =(String) returnPages.strQuery.get('stockOption');
            whereQ += stockOption == '0' ? ' AND CurrentStockQuantity__c =0': ' AND CurrentStockQuantity__c !=0';
        }
        
        // productCode
        List<String> productCodeList = new List<String>();
        if( (String) returnPages.strQuery.get('productCode') !=null) {
            
            String productCode =(String) returnPages.strQuery.get('productCode');
            productCodeList = productCode.split(',');
            //whereQ += ' AND Part__c=\''+productCode+'\'';
            whereQ += ' AND Part__c IN(\''+String.Join(productCodeList,'\',\'') +'\')';
        }
        // location
        List<String> locationSet = new List<String>();
        if( (String) returnPages.strQuery.get('location') !=null) {
            String location =(String) returnPages.strQuery.get('location');
            locationSet = location.split(',');
            whereQ += ' AND DealerLocation__c IN(\''+String.Join(locationSet,'\',\'') +'\')';
        }

        // binOption
        if( (String) returnPages.strQuery.get('binOption') !='All') {
            String binOption =(String) returnPages.strQuery.get('binOption');
            if(binOption != '1') {
                whereQ += ' AND DealerLocation__c =null';  
            } else {
                List<AggregateResult> agees = Database.query('SELECT COUNT(Id),DealerLocation__c FROM DealerStock__c' + ' WHERE DealerLocation__c!=null AND Dealer__c =\''+currentUser.getAgencyId()+'\' GROUP BY DealerLocation__c having COUNT(Id) > 1 LIMIT 2000');
                set<String> locationIds = new set<String>();
                for(AggregateResult result : agees) {
                    locationIds.add((String)result.get('DealerLocation__c'));
                }
                whereQ += ' AND DealerLocation__c IN(\''+String.join(locationIds, '\',\'') + '\')';
            }
        }
        Map<String,String> returnMap = new Map<String,String>();
        // if(limitSet > 2000) {
        //     limitSet = 2000;
        // }
        returnMap.put('dataQuery',strQuery +whereQ+' '+returnPages.orderByField+' '+returnPages.orderBy); //+' limit ' + limitSet);
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
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res res = DN_DealerStockManager.dealerStock011(productCodeList);
            Map<String,IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST> partPriceMap = new Map<String,IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST>();
            
            // 고객 판매가 매핑 - 현재 화면 ERP와 CRM의 부품데이터가 일치해야하는 전제조건이 따름
            for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST detail : res.ET_LIST) {
                partPriceMap.put(detail.MATNR,detail);
            }
            

            for(StorageChange storage : recordList) {
                if(partPriceMap.get(storage.partNumber) !=null) {
                    storage.dispr = Decimal.valueOf(partPriceMap.get(storage.partNumber).DISPR);
                    storage.price = Decimal.valueOf(partPriceMap.get(storage.partNumber).NETPR);
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
        @AuraEnabled public Boolean isAllData { get; set; } // 전체데이터 조회 유무
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
     * 	- 부품별 단가 및 재고위치 등
    **/ 
    public class StorageChange {
        @AuraEnabled public String id { get; set; } // id
        @AuraEnabled public String dealerName { get; set; } // 대리점명
        @AuraEnabled public String dealerCode { get; set; } // 대리점명
        @AuraEnabled public String partId { get; set; } // Part
        @AuraEnabled public String partName { get; set; } // 품번
        @AuraEnabled public String partNumber { get; set; } // 품명
        @AuraEnabled public String partSpec { get; set; } // 규격(스펙)
        @AuraEnabled public String weight { get; set; } // weight
        @AuraEnabled public String weightUnit { get; set; } // WeightUnit
        @AuraEnabled public Decimal availableQuantity  { get; set; } // 가용재고
        @AuraEnabled public String lastImportDateTime { get; set; } // 최종입고일
        @AuraEnabled public Decimal currentStockQuantity  { get; set; } // 재고량
        @AuraEnabled public Decimal dispr { get; set; } // 구매단가
        @AuraEnabled public Decimal price { get; set; } // 판매단가
        @AuraEnabled public String locationId { get; set; } // 저장위치 Id
        @AuraEnabled public String location { get; set; } // 저장위치
        @AuraEnabled public String description { get; set; } // 저장위치 설명
        
        public StorageChange() {}
        public StorageChange(DealerStock__c stock) {
            this.id = stock.Id;
            this.partId = stock.Part__c;
            this.partName = stock.Part__r.FM_MaterialDetails__c;
            this.dealerName = stock.Dealer__r.Name;
            this.dealerCode = stock.Dealer__r.Id;
            this.partNumber = stock.Part__r.ProductCode;
            this.partSpec = String.isNotBlank(stock.Part__r.ProductSpec__c) ? stock.Part__r.ProductSpec__c : '';
            this.availableQuantity = stock.AvailableQuantity__c;
            if(stock.get('LastImportDateTime__c') !=null) {
                this.lastImportDateTime = stock.LastImportDateTime__c.format('YYYY.MM.dd');
            } else {
                this.lastImportDateTime = '';
            }
            this.currentStockQuantity = stock.CurrentStockQuantity__c;
            this.weight = String.isNotBlank(String.valueOf(stock.Part__r.Weight__c)) ? String.valueOf(stock.Part__r.Weight__c) :'';
            this.weightUnit = String.isNotBlank(stock.Part__r.WeightUnit__c) ? stock.Part__r.WeightUnit__c :'';
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
    public class DN_StorageBinCreateChangeControllerException extends Exception {}
}