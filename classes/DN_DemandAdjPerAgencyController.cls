/**
* @Class : DN_DemandAdjPerAgencyController
*
* @Author : Junhyo Hwang
* @Date : 2024. 06. 22.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-06-22 | Junhyo Hwang   | 최초작성
*  2. | 2025-02-05 | iltae seo      | 화면 로직 구현
*/

public without sharing class DN_DemandAdjPerAgencyController {
    public static Map<String,DealerPartMasterByMPPS__c> partByMppsMap = new Map<String,DealerPartMasterByMPPS__c>();
    public static Map<String,AggregateResult> abcMap = new Map<String,AggregateResult>();
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    /**
     ********************************************************************** Stock Monitoring ******************************************************************************************
     */
    /**
     * @Description
     * 	- Stock Monitoring 데이터 조회
    **/ 
    @AuraEnabled
    public static PageReturns getStockMonitoringList(PageReturns page, Integer nextPage){
        try {
            PageReturns returnPage = page;
            
            Map<String,Integer> pageMap = setpageSetting(returnPage,nextPage);
            
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            
            Map<String,String> queryMap = getStockDataQuery(returnPage,limitSet);
            //System.debug(queryMap.get('12mQuery') + ' :12mQuery');
            //System.debug(queryMap.get('18mQuery') + ' :18mQuery');
            //System.debug(queryMap.get('24mQuery') + ' :24mQuery');
            List<AggregateResult> m12List = Database.query(queryMap.get('12mQuery'));
            List<AggregateResult> m18List = Database.query(queryMap.get('18mQuery'));
            List<AggregateResult> m24List = Database.query(queryMap.get('24mQuery'));
            System.debug(page + ' ::: page');
            System.debug(limitSet + ' :: limitSet');
            System.debug(pageMap + ' ::: pageMap');
            // System.debug(m12List.size() + ' m12List');
            // System.debug(m18List.size() + ' m18List');
            // System.debug(m24List.size() + ' m24List');
            Integer totalSize = Database.countQuery(queryMap.get('countQuery'));
            Map<String,AggregateResult> monthMap = new Map<String,AggregateResult>();
            //System.debug(queryMap.get('dataQuery') + ' dataQyery 1111');
            List<DealerPartMasterByMPPS__c> dataList = Database.query(queryMap.get('dataQuery')); //
            //System.debug(dataList  +' ::: dataList');
            returnPage.recordList = new List<StockMonitoring>();
            for(AggregateResult m12 : m12List) {
                String key = (String) m12.get('Part__c');
                monthMap.put('m12'+key, m12);
            }
            for(AggregateResult m18 : m18List) {
                String key = (String) m18.get('Part__c');
                monthMap.put('m18'+key, m18);
            }
            for(AggregateResult m24 : m24List) {
                String key = (String) m24.get('Part__c');
                monthMap.put('m24'+key, m24);
            }
            Map<String,String> noteMap = getPartNote();
            
            for(Integer i=startIdx-1; i<dataList.size(); i++) {
                if(i < endIdx) {
                    String partKey = dataList[i].Part__c;
                    System.debug(partKey + ' ::partKey');
                    StockMonitoring monitoring = new StockMonitoring(dataList[i]);
                    System.debug(monitoring + ' :: monitoring');
                    monitoring.convert(monthMap.get('m12'+partKey),monthMap.get('m18'+partKey),monthMap.get('m24'+partKey));
                    monitoring.partsNote = noteMap.get(partKey) == null ? '' : noteMap.get(partKey);
                    //convert(AggregateResult m12, AggregateResult m18, AggregateResult m24)
                    System.debug(monitoring + ' ::: monitoring');
                    
                
                    returnPage.recordList.add(monitoring);
                } else {
                    break;
                }
            }
             
            //returnPage.recordList.sort();
            returnPage.totalRecordSize = totalSize;
            returnPage.startIdx = startIdx;
            returnPage.endIdx = endIdx;
            returnPage.currentPage = nextPage;
            return returnPage;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DemandAdjPerAgencyControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 엑셀 데이터 조회
    **/ 
    @AuraEnabled
    public static PageReturns getStockMonitoringExcel(PageReturns page, Integer nextPage){
        try {
            PageReturns returnPage = page;
            Map<String,Integer> pageMap = setpageSetting(returnPage,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            Map<String,String> queryMap = getStockDataQuery(returnPage,limitSet);
            List<AggregateResult> m12List = Database.query(queryMap.get('12mQuery'));
            List<AggregateResult> m18List = Database.query(queryMap.get('18mQuery'));
            List<AggregateResult> m24List = Database.query(queryMap.get('24mQuery'));
            Map<String,AggregateResult> monthMap = new Map<String,AggregateResult>();
            List<DealerPartMasterByMPPS__c> dataList = Database.query(queryMap.get('dataQuery')); //
            
            returnPage.allData = new List<StockMonitoring>();
            for(AggregateResult m12 : m12List) {
                String key = (String) m12.get('Part__c');
                monthMap.put('m12'+key, m12);
            }
            for(AggregateResult m18 : m18List) {
                String key = (String) m18.get('Part__c');
                monthMap.put('m18'+key, m18);
            }
            for(AggregateResult m24 : m24List) {
                String key = (String) m24.get('Part__c');
                monthMap.put('m24'+key, m24);
            }
            Map<String,String> noteMap = getPartNote();
            for(Integer i=startIdx-1; i<dataList.size(); i++) {
                if(i < endIdx) {
                    System.debug(dataList.size() + ' size');
                    System.debug(endIdx + ' endIdx');
                    String partKey = dataList[i].Part__c;
                    StockMonitoring monitoring = new StockMonitoring(dataList[i]);
                    //convert(AggregateResult m12, AggregateResult m18, AggregateResult m24)
                    monitoring.convert(monthMap.get('m12'+partKey),monthMap.get('m18'+partKey),monthMap.get('m24'+partKey));
                    monitoring.partsNote = noteMap.get(partKey) == null ? '' : noteMap.get(partKey);
                    returnPage.allData.add(monitoring);
                } else {
                    break;
                }
            }
            return returnPage;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DemandAdjPerAgencyControllerException(e.getMessage());
        }
    }

    /**
    * @description Stock Monitoring 데이터 Save
    * @author iltae.seo | 2025-02-19 
    * @param  List<StockMonitoring> saveList
    * @return void
    **/
    @AuraEnabled
    public static void stockMonitoringSave(List<StockMonitoring> saveList){
        try {
            List<DealerPartMasterByMPPS__c> dealerPartMasterByMPPSList = new List<DealerPartMasterByMPPS__c>();
            for(StockMonitoring stock : saveList) {
                DealerPartMasterByMPPS__c mpps = new DealerPartMasterByMPPS__c();
                mpps.Id = stock.id;
                mpps.IsExcludeStockMonitoring__c = stock.isExcludeStockMonitoring;
                dealerPartMasterByMPPSList.add(mpps);
            }
            update dealerPartMasterByMPPSList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DemandAdjPerAgencyControllerException(e.getMessage());
        }
    }

    /**
    * @description PartNote 리턴
    * @author iltae.seo | 2025-02-19 
    * @return Map<String,String> returnMap
    **/
    public static Map<String,String> getPartNote() {
        Map<String,String> returnMap = new Map<String,String>();
        List<DealerStock__c> stockList = [SELECT Id, Part__c,Note__c FROM DealerStock__c where Part__c IN:partByMppsMap.keyset() AND Dealer__c =: currentUser.getAgencyId()];
        for(DealerStock__c stock : stockList) {
            returnMap.put(stock.Part__c, stock.Note__c);
        }
        return returnMap;
    }

    /**
    * @description Stock Monitoring 데이터 쿼리
    * @author iltae.seo | 2025-02-07 
    * @param  PageReturn,limitSet
    * @return Map<String,String> returnMap
    **/
    public static Map<String,String> getStockDataQuery(PageReturns returnPages,Integer limitSet) {
        System.debug(limitSet + ' ::: limitSet');
        Map<String,String> returnMap = new Map<String,String>();
        // ZSPT 2420 Query
        String dealerPartMasterByMPPSQ = 'select Id, Dealer__r.Name,Part__r.ProductCode,Part__r.FM_MaterialDetails__c,';
        dealerPartMasterByMPPSQ += 'ABCIndicator__c, MRPType__c, SafetyStock__c,StartPart__r.ProductCode, LastPart__r.ProductCode,';
        dealerPartMasterByMPPSQ += 'MaximumStock__c, ReorderPoint__c, RoundingValue__c,';
        dealerPartMasterByMPPSQ += 'MinimumLotSize__c, FM_Unit__c, FM_ExtentionDate__c,';
        dealerPartMasterByMPPSQ += 'TargetServiceLevel__c, ServiceFactor__c, AMD__c,';
        dealerPartMasterByMPPSQ += 'WAMD__c, STDEV__c, Weight__c,';
        dealerPartMasterByMPPSQ += 'IsFixedROP__c, Part__c, Dealer__c,';
        dealerPartMasterByMPPSQ += 'IsExcludeStockMonitoring__c ';
        String dealerPartMasterByMPPWQ =' FROM DealerPartMasterByMPPS__c where Dealer__c=\''+currentUser.getAgencyId()+'\'';
        // 년도 추가
        List<String> monthList = getYYYYMM();
        dealerPartMasterByMPPWQ += ' AND Part__c !=null ';
        
        // 부품코드
        //System.debug(returnPages.strQuery + ' ::: returnPages.strQuery');
        String products = (String) returnPages.strQuery.get('productCode');
        //String nameList = '\'' + String.join(accountNames, '\',\'') + '\''; 
        if(String.isNotBlank(products)) {
            List<String> productCodeList = products.split(',');
            dealerPartMasterByMPPWQ += ' AND Part__c IN(\''+String.join(productCodeList, '\',\'') +'\')';
        } else {
            dealerPartMasterByMPPWQ += ' AND Part__c IN (SELECT Part__c FROM MonthlyDemandSummaryByDealer__c WHERE FM_TotalFrequency__c >0 AND AnalysisPeriodMonth__c IN(\''+String.join(monthList, '\',\'') +'\') AND Dealer__c=\''+currentUser.getAgencyId()+'\') ';
        }

        // ABC Indicator
        if((String) returnPages.strQuery.get('ABCIndicator') !='ALL') {
            String abc = (String)returnPages.strQuery.get('ABCIndicator');
            dealerPartMasterByMPPWQ += ' AND ABCIndicator__c =\''+abc+'\'';
        }
        
        //MRP Type
        if((String) returnPages.strQuery.get('MRPType') !='ALL') {
            String mrpType = (String)returnPages.strQuery.get('MRPType');
            dealerPartMasterByMPPWQ += ' AND MRPType__c =\''+mrpType+'\'';
        }

        //안전재고 
        if((String) returnPages.strQuery.get('IsSaveStock') !=null) {
            Boolean isSaveStock = String.valueOf(returnPages.strQuery.get('IsSaveStock'))=='1'? false : true;
            dealerPartMasterByMPPWQ += ' AND IsExcludeStockMonitoring__c ='+isSaveStock;
        }
        
        // DealerPartMasterByMPPS__c
        set<String> partIds = new set<String>();
        System.debug(dealerPartMasterByMPPSQ + dealerPartMasterByMPPWQ + ' LIMIT ' + limitSet + ' ::: 1212312312');
        List<DealerPartMasterByMPPS__c> dealerPartMasterList = Database.query(dealerPartMasterByMPPSQ + dealerPartMasterByMPPWQ + ' LIMIT ' + limitSet);
        
        for(DealerPartMasterByMPPS__c dealer : dealerPartMasterList) {
            partByMppsMap.put(dealer.Part__c, dealer);
            partIds.add(dealer.Part__c);
        }
        
        String monthlyDemandSummaryByDealerQ = ' select Part__c,MAX(StartPart__c) StartPart__c,';
        monthlyDemandSummaryByDealerQ +=' MAX(StartPart__r.ProductCode) StartPart,';
        monthlyDemandSummaryByDealerQ +=' MAX(LastPart__r.ProductCode) LastPart,';
        monthlyDemandSummaryByDealerQ +=' SUM(FM_TotalQuantity__c) FM_TotalQuantity__c,';
        monthlyDemandSummaryByDealerQ +=' SUM(FM_TotalFrequency__c) FM_TotalFrequency__c from MonthlyDemandSummaryByDealer__c ';
        monthlyDemandSummaryByDealerQ +=' where Dealer__c=\''+currentUser.getAgencyId()+'\' ';
        monthlyDemandSummaryByDealerQ += ' AND Part__c IN(\''+String.join(partIds, '\',\'')+'\') ';
        monthlyDemandSummaryByDealerQ += ' AND Part__c !=null';
        // 현재 날짜 기준으로 연도와 월 계산
        Date today = System.today();
        
        Date date12M = today.addMonths(-12);  // 12개월 전
        Date date18M = today.addMonths(-18);  // 18개월 전
        Date date24M = today.addMonths(-24);  // 24개월 전
        // "YYYYMM" 포맷으로 변환 (텍스트 필드 비교용)
        String todayStr     = today.year() + String.valueOf(today.month()).leftPad(2, '0');
        String period12M = date12M.year() + String.valueOf(date12M.month()).leftPad(2, '0');
        String period18M = date18M.year() + String.valueOf(date18M.month()).leftPad(2, '0');
        String period24M = date24M.year() + String.valueOf(date24M.month()).leftPad(2, '0');
        
        String where12M = ' AND AnalysisPeriodMonth__c >=\''+period12M+'\' AND AnalysisPeriodMonth__c <\''+todayStr+'\'';
        String where18M = ' AND AnalysisPeriodMonth__c >=\''+period18M+'\' AND AnalysisPeriodMonth__c <\''+todayStr+'\'';
        String where24M = ' AND AnalysisPeriodMonth__c >=\''+period24M+'\' AND AnalysisPeriodMonth__c <\''+todayStr+'\'';
        String groupBy =' group by Part__c';
        // M12 M18 M24 Query
        returnMap.put('12mQuery', monthlyDemandSummaryByDealerQ + where12M + groupBy);
        returnMap.put('18mQuery', monthlyDemandSummaryByDealerQ + where18M + groupBy);
        returnMap.put('24mQuery', monthlyDemandSummaryByDealerQ + where24M + groupBy);     
        returnMap.put('dataQuery', dealerPartMasterByMPPSQ + dealerPartMasterByMPPWQ+' LIMIT ' + limitSet);
        returnMap.put('countQuery', +'SELECT COUNT() ' + dealerPartMasterByMPPWQ);
        /**
         *  ZSPT 2420 // DealerPartMasterByMPPS__c 
            ZSPT 2360 // MonthlyDemandSummaryByDealer__c - 기간동안 빈도
            ZSLT0310 // DealerStock__c
         */
               
        return returnMap;
    }

    /**
    * @description 페이지 설정 - Stock Monitoring
    * @author iltae.seo | 2025-02-19 
    **/
    public static Map<string,Integer> setpageSetting(PageReturns returnPages, Integer nextPage) {
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
     ********************************************************************** 지역별 수요조회 ******************************************************************************************
     */
    /**
    /**
    * @description 지역별 수요조회 데이터 조회 
    * @author iltae.seo | 2025-02-13 
    **/
    @AuraEnabled
    public static PageReturn getAreaListQuery(PageReturn page, Integer nextPage, String type){
        try {
            PageReturn returnPage = page;
            returnPage.itemsPerPage = 10;
            Map<String,Integer> pageMap = setpageSetting(returnPage,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            
            Map<String,String> queryMap = getAreaDataQuery(returnPage,limitSet,startIdx,endIdx);
            System.debug(abcMap + ' abcMap :::: ');
            System.debug(abcMap.size() + ' abcMap.size ');
            
            System.debug(limitSet + ' :: limitSet');
            System.debug(startIdx + ' :: startIdx');
            System.debug(endIdx + ' :: endIdx');
            System.debug(nextPage + ' ::: nextPage');
            List<String> partList = new List<String>();
            List<String> yyyymmList = new List<String>();
            
            //Map<String,Decimal> partByLastPatMap = getLastPartByMap('MonthlyDemandSummaryByRegion__c',abcMap.keySet());
            //데이터 조회
            List<AggregateResult> currentAreaList = Database.query(queryMap.get('dataQuery'));
            List<AggregateResult> otherAreaList = Database.query(queryMap.get('dataQuery2'));
            List<AggregateResult> totalList = new List<AggregateResult>();
            Map<String,AggregateResult> plusOtherAreaMap = new Map<String,AggregateResult>();
            totalList.addAll(currentAreaList);
            totalList.addAll(otherAreaList);
            Map<String,Decimal> summaryMap = new Map<String,Decimal>();
            Map<String,AggregateResult> summaryByResultMap = new Map<String,AggregateResult>();
            String areaName = queryMap.get('currentArea');
            

            for(AggregateResult age : totalList) {
                Object areaValue = age.get('Area__c');
                String productCode = (String)age.get('ProductCode');
                String area = age.get('Area__c') != areaName ? '국내전체' : (String)age.get('Area__c');
                String yyyy = String.valueOf(age.get('AnalysisPeriodMonth__c')).substring(0, 4);  
                String mm = String.valueOf(age.get('AnalysisPeriodMonth__c')).substring(4, 6); 
                mm = mm.length() ==1? '0'+mm : mm; 
                String yyyymm = yyyy + mm;

                if(summaryMap.get(productCode+area+yyyymm) !=null) {
                    Decimal total= summaryMap.get(productCode+area+yyyymm) +(Decimal)age.get('FM_TotalQuantity__c');
                    summaryMap.put(productCode+area+yyyymm,total);
                    // if(areaName !='국내전체') {
                    //     plusOtherAreaMap.put(productCode+'국내전체'+yyyymm,age);
                    // }
                } else {
                    summaryMap.put(productCode+area+yyyymm,(Decimal)age.get('FM_TotalQuantity__c'));
                    // if(areaName !='국내전체') {
                    //     plusOtherAreaMap.put(productCode+'국내전체'+yyyymm,age);
                    // }
                }
            }
            List<DemandAdjPerAgency> recordSet = new List<DemandAdjPerAgency>();
            for(String prodCode : abcMap.keySet())  { //LastProductCode
                DateTime currentDate = DateTime.now();
                DemandAdjPerAgency allArea = new DemandAdjPerAgency();
                allArea.convert(prodCode,'국내전체');
                DemandAdjPerAgency currentArea = new DemandAdjPerAgency();
                currentArea.convert(prodCode,areaName);
                for (Integer j = 24; j >= 0; j--) {
                    String yyyymm =DN_DealerStockManager.getPastMonths(currentDate, -j);
                    String mKey = 'm' + String.valueOf(j);
                    Decimal allAreaQTY = 0;
                    Decimal currentAreaQTY = 0;
                    if(summaryMap.get(String.valueOf(prodCode + areaName +yyyymm)) !=null) {                          
                        currentAreaQTY = summaryMap.get(String.valueOf(prodCode + areaName +yyyymm));   
                    }
                    Monthly monthBycurrent  = new Monthly(mKey,currentAreaQTY,yyyymm);
                    currentArea.monthlyList.add(monthBycurrent);
                    
                    if(summaryMap.get(String.valueOf(prodCode + '국내전체' +yyyymm)) !=null) {                          
                        allAreaQTY = (Decimal) summaryMap.get(String.valueOf(prodCode + '국내전체' +yyyymm));   
                    }
                    if(currentAreaQTY > 0) {
                        allAreaQTY +=currentAreaQTY;
                    }
                    Monthly monthByAll  = new Monthly(mKey,allAreaQTY,yyyymm);
                    allArea.monthlyList.add(monthByAll);                    
                }
                recordSet.add(currentArea);
                recordSet.add(allArea);

            }
            recordSet.sort();
            returnPage.recordList = new List<DemandAdjPerAgency>();
            returnPage.recordList = recordSet;
            if(type == 'Seach') {
                returnPage.totalRecordSize = Integer.valueOf(queryMap.get('Count'))*2;
            }
            Map<String,Integer> pageMapSet = setpageSetting(returnPage,nextPage);
            startIdx = pageMapSet.get('startIdx');
            endIdx = pageMapSet.get('endIdx');
            returnPage.itemsPerPage = 20;
            returnPage.startIdx = startIdx;
            returnPage.endIdx = endIdx;
            returnPage.currentPage = nextPage;
            System.debug(returnPage.recordList.size() + ' :: size');
            return returnPage;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DemandAdjPerAgencyControllerException(e.getMessage() + ' : '+e.getStackTraceString());
        }
    }

    /**
    * @description 엑셀데이터
    * @author iltae.seo | 2025-02-17 
    **/
    @AuraEnabled
    public static PageReturn getAreaExcelData(PageReturn page, Integer nextPage){
        try {
            PageReturn returnPage = page;
            Map<String,Integer> pageMap = setpageSetting(returnPage,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            Map<String,String> queryMap = getAreaDataQuery(returnPage,limitSet,startIdx,endIdx);
            System.debug(limitSet + ' :: limitSet');
            System.debug(startIdx + ' :: startIdx');
            System.debug(endIdx + ' :: endIdx');
            System.debug(nextPage + ' ::: nextPage');
            List<String> partList = new List<String>();
            List<String> yyyymmList = new List<String>();
            
            //Map<String,Decimal> partByLastPatMap = getLastPartByMap('MonthlyDemandSummaryByRegion__c',abcMap.keySet());
            //데이터 조회
            List<AggregateResult> currentAreaList = Database.query(queryMap.get('dataQuery'));
            List<AggregateResult> otherAreaList = Database.query(queryMap.get('dataQuery2'));
            List<AggregateResult> totalList = new List<AggregateResult>();
            Map<String,AggregateResult> plusOtherAreaMap = new Map<String,AggregateResult>();
            totalList.addAll(currentAreaList);
            totalList.addAll(otherAreaList);
            Map<String,Decimal> summaryMap = new Map<String,Decimal>();
            Map<String,AggregateResult> summaryByResultMap = new Map<String,AggregateResult>();
            String areaName = queryMap.get('currentArea');
            for(AggregateResult age : totalList) {
                Object areaValue = age.get('Area__c');
                String productCode = (String)age.get('ProductCode');
                String area = age.get('Area__c') != areaName ? '국내전체' : (String)age.get('Area__c');
                String yyyy = String.valueOf(age.get('AnalysisPeriodMonth__c')).substring(0, 4);  
                String mm = String.valueOf(age.get('AnalysisPeriodMonth__c')).substring(4, 6); 
                mm = mm.length() ==1? '0'+mm : mm; 
                String yyyymm = yyyy + mm;

                if(summaryMap.get(productCode+area+yyyymm) !=null) {
                    Decimal total= summaryMap.get(productCode+area+yyyymm) +(Decimal)age.get('FM_TotalQuantity__c');
                    summaryMap.put(productCode+area+yyyymm,total);
                    // if(areaName !='국내전체') {
                    //     plusOtherAreaMap.put(productCode+'국내전체'+yyyymm,age);
                    // }
                } else {
                    summaryMap.put(productCode+area+yyyymm,(Decimal)age.get('FM_TotalQuantity__c'));
                    // if(areaName !='국내전체') {
                    //     plusOtherAreaMap.put(productCode+'국내전체'+yyyymm,age);
                    // }
                }
            }
            List<DemandAdjPerAgency> recordSet = new List<DemandAdjPerAgency>();
            for(String prodCode : abcMap.keySet())  { //LastProductCode
                DateTime currentDate = DateTime.now();
                DemandAdjPerAgency allArea = new DemandAdjPerAgency();
                allArea.convert(prodCode,'국내전체');
                DemandAdjPerAgency currentArea = new DemandAdjPerAgency();
                currentArea.convert(prodCode,areaName);
                for (Integer j = 24; j >= 0; j--) {
                    String yyyymm =DN_DealerStockManager.getPastMonths(currentDate, -j);
                    String mKey = 'm' + String.valueOf(j);
                    Decimal allAreaQTY = 0;
                    Decimal currentAreaQTY = 0;
                    if(summaryMap.get(String.valueOf(prodCode + areaName +yyyymm)) !=null) {                          
                        currentAreaQTY = summaryMap.get(String.valueOf(prodCode + areaName +yyyymm));   
                    }
                    Monthly monthBycurrent  = new Monthly(mKey,currentAreaQTY,yyyymm);
                    currentArea.monthlyList.add(monthBycurrent);
                    
                    if(summaryMap.get(String.valueOf(prodCode + '국내전체' +yyyymm)) !=null) {                          
                        allAreaQTY = (Decimal) summaryMap.get(String.valueOf(prodCode + '국내전체' +yyyymm));   
                    }
                    if(currentAreaQTY > 0) {
                        allAreaQTY +=currentAreaQTY;
                    }
                    Monthly monthByAll  = new Monthly(mKey,allAreaQTY,yyyymm);
                    allArea.monthlyList.add(monthByAll);                    
                }
                recordSet.add(currentArea);
                recordSet.add(allArea);

            }
            recordSet.sort();
            returnPage.allData = new List<DemandAdjPerAgency>();
            returnPage.allData = recordSet;
            
            return returnPage;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DemandAdjPerAgencyControllerException(e.getMessage());
        }
    }



    /**
    * @description 지역별 데이터 쿼리
    * @author iltae.seo | 2025-02-07 
    * @param  PageReturn,limitSet
    * @return Map<String,String> returnMap
    **/
    public static Map<String,String> getAreaDataQuery(PageReturn returnPages,Integer limitSet, Integer startIdx, Integer endIdx) {
        Map<String,String> returnMap = new Map<String,String>();
        List<DealerAreaByMPPS__c> dealerAreaBy = [select Id, Name, Dealer__r.Name, Area__r.Name,Area__r.Area__c from DealerAreaByMPPS__c where Dealer__c =:currentUser.getAgencyId()];
        String areaName = '';
        if(dealerAreaBy.size() > 0) {
            areaName = '\''+dealerAreaBy[0].Area__r.Name+'\' ';
            returnMap.put('currentArea',dealerAreaBy[0].Area__r.Name);
        } else {
            throw new DN_DemandAdjPerAgencyControllerException('현재 지역정보가 없습니다. 관리자에게 문의하세요');
        }        
        String whereQ = ' WHERE Part__c !=null ';
        // 부품코드
        String products = (String) returnPages.strQuery.get('productCode');
        if(String.isNotBlank(products)) {
            List<String> productCodeList = products.split(',');
            whereQ += ' AND Part__c IN(\''+String.join(productCodeList, '\',\'') +'\')';
            
        }
        // ABC Indicatior
        if((String) returnPages.strQuery.get('abcIndicatior') !='ALL') {
            String abcIndicatior = (String) returnPages.strQuery.get('abcIndicatior');
            whereQ += ' AND ABCIndicator__c =\''+abcIndicatior+'\'';
        }

        // MRP TYPE
        if((String) returnPages.strQuery.get('MRPType') !='All') {
            String mrpType = (String) returnPages.strQuery.get('MRPType');
            whereQ += ' AND MRPType__c =\''+mrpType+'\' ';
        }
        
        List<AggregateResult> byMppsList = DataBase.query('SELECT Part__r.ProductCode, MAX(Part__r.FM_MaterialDetails__c) FM_MaterialDetails__c,MAX(LastPart__r.ProductCode) LastProductCode,MAX(Part__r.Unit__c) Unit__c, MAX(ABCIndicator__c) ABCIndicator__c,MAX(MRPType__c) MRPType__c FROM AreaPartMasterByMPPS__c '+whereQ+' AND Area__r.name ='+areaName + ' GROUP BY Part__r.ProductCode LIMIT 4000');
        System.debug('SELECT Part__r.ProductCode ,MAX(Part__r.FM_MaterialDetails__c) MaterialDetails__c,MAX(FM_Unit__c)Unit__c, MAX(ABCIndicator__c) ABCIndicator__c,MAX(MRPType__c)MRPType__c FROM AreaPartMasterByMPPS__c '+whereQ+' AND Area__r.name ='+areaName+' group by Part__r.ProductCode');
        System.debug(byMppsList.size() + ' ::: byMppsList');
        System.debug( endIdx + ' byMpps endIdx');
        abcMap = new Map<String,AggregateResult>();
        for(Integer i=startIdx-1; i<byMppsList.size(); i++) {
            if(i < endIdx) {
                abcMap.put((String)byMppsList[i].get('ProductCode'), byMppsList[i]);
            } else {
                break;
            }
        }
       

        returnMap.put('Count', String.valueOf(byMppsList.size()));
       
        if(byMppsList.size() ==0) {
            throw new DN_DemandAdjPerAgencyControllerException('검색결과가 없습니다.');
        }
        
        

        // 지역별 쿼리
        String areaQuery = 'SELECT Area__r.Name Area__c,Part__r.ProductCode,AnalysisPeriodMonth__c, SUM(Quantity__c) OrderQuantity__c,MAX(LastPart__r.ProductCode) maxLastProduct,';
        areaQuery +=' SUM(FM_TotalQuantity__c) FM_TotalQuantity__c, SUM(FM_TotalFrequency__c) FM_TotalFrequency__c,SUM(AdjustQuantity__c) AdjustQuantity__c FROM MonthlyDemandSummaryByRegion__c ';
        String groupBy = ' group by Part__r.ProductCode,Area__r.Name ,AnalysisPeriodMonth__c ';
        String areawhere = '';
        if(abcMap.size() > 0) {
            areawhere += ' AND Part__r.ProductCode IN(\''+String.join(abcMap.keyset(), '\',\'') +'\') ';
        }
        

        
        returnMap.put('dataQuery',areaQuery + ' WHERE Part__c !=null AND Area__c !=null '+areawhere + ' AND Area__r.Name='+areaName+ groupBy + ' ORDER BY Part__r.ProductCode LIMIT 2000');
        returnMap.put('dataQuery2',areaQuery +' WHERE Part__c !=null AND Area__c !=null '+ areawhere + ' AND Area__r.Name!='+areaName+ groupBy+ ' ORDER BY Part__r.ProductCode  LIMIT 2000');
        
        return returnMap;
    }
    
    
    


    /**
     ********************************************************************** 대리점별 수요조정 ******************************************************************************************
     */
    /**
    * @description 월별 설정
    * @author iltae.seo | 2025-02-05 
    **/
    @AuraEnabled
    public static List<String> getMonth(){
        try {
            List<String> returnList = new List<String>();
            DateTime currentDate = DateTime.now();
            for (Integer j = 24; j >= 0; j--) {
                String yyymm =DN_DealerStockManager.getPastMonths(currentDate, -j);
                String mm = yyymm.subString(yyymm.length() -2);
                returnList.add(mm);
            }
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 월별 설정
    * @author iltae.seo | 2025-02-05 
    **/
    @AuraEnabled
    public static List<String> getYYYYMM(){
        try {
            List<String> returnList = new List<String>();
            DateTime currentDate = DateTime.now();
            for (Integer j = 24; j >= 0; j--) {
                String yyymm =DN_DealerStockManager.getPastMonths(currentDate, -j);
                returnList.add(yyymm);
            }
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     /**
    * @description 검색 조건에 따른 대리점별 수요조정 데이터 조회
    * @author iltae.seo | 2025-02-05 
    **/
    @AuraEnabled
    public static PageReturn getDataListQuery(PageReturn page, Integer nextPage){
        try {
            
            PageReturn returnPage = page;
            Map<String,Integer> pageMap = setpageSetting(returnPage,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            Map<String,String> queryMap = setDataQuery(returnPage,limitSet);
            
            List<String> partList = new List<String>();
            List<String> yyyymmList = new List<String>();
            //데이터 조회
            List<MonthlyDemandSummaryByDealer__c> dataList =Database.query(queryMap.get('dataQuery')); //curQtyQuery
            
            
            //lastPartsMap
            Map<String,Decimal> lastPartsMap = new Map<String,Decimal>();
            List<ProductByPlant__c> lastPartsList = [
                SELECT Id,Name,LastPart__c,Part__c
                FROM ProductByPlant__c  where LastPart__r.ProductCode IN: abcMap.keySet() 
            ];
            
            System.debug(queryMap.get('curQtyQuery') + ' ::: curQty');
            System.debug(queryMap.get('dataQuery') + ' data QUERY ');
            Map<String,Decimal> summaryMap = new Map<String,Decimal>();
            Map<String,Decimal> adjustQTYMap = new Map<String,Decimal>();
            for(MonthlyDemandSummaryByDealer__c demaned : dataList) {
                if(summaryMap.get(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c) !=null) {
                    Decimal total = summaryMap.get(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c) + demaned.FM_TotalQuantity__c;
                    Decimal adJust = summaryMap.get(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c) + demaned.AdjustQuantity__c ;
                    summaryMap.put(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c,total);
                    adjustQTYMap.put(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c,adJust);
                } else {
                    summaryMap.put(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c, demaned.FM_TotalQuantity__c);
                    adjustQTYMap.put(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c,demaned.AdjustQuantity__c);
                }
            }
            System.debug(queryMap.get('summaryQuery') + ' :: summaryQuery');
            List<AggregateResult> aggreateList = Database.query(queryMap.get('summaryQuery'));
            // Last Part의 이전 부품들의 수량을 가져옴
            set<String> partCodeSet = new Set<String>();
            for(AggregateResult ages :aggreateList) {
                partCodeSet.add((String)ages.get('maxLastProduct'));
            }
            returnPage.totalRecordSize = Database.query(queryMap.get('countQuery')).size();
            returnPage.recordList = new List<DemandAdjPerAgency>();
            
            for(Integer i=startIdx-1; i<aggreateList.size(); i++) {
                if(i < endIdx) {
                    DateTime currentDate = DateTime.now();
                    DemandAdjPerAgency wrapper = new DemandAdjPerAgency(aggreateList[i]);
                    for (Integer j = 24; j >= 0; j--) {
                        String yyymm =DN_DealerStockManager.getPastMonths(currentDate, -j);
                        String mKey = 'm' + String.valueOf(j);
                        Decimal qty = 0;
                        Decimal adjustQTY = 0;//(Decimal) aggreateList[i].get('AdjustQuantity__c'); //maxLastProduct
                        if(adjustQTYMap.get(aggreateList[i].get('ProductCode')+'!'+yyymm) !=null) {
                            adjustQTY = adjustQTYMap.get(aggreateList[i].get('ProductCode')+'!'+yyymm);
                        }
                        if(summaryMap.get(aggreateList[i].get('ProductCode')+'!'+yyymm) !=null) {                            
                            qty = summaryMap.get(aggreateList[i].get('ProductCode')+'!'+yyymm);
                            
                        }
                        
                        Monthly monthBy  = new Monthly(mKey,qty,yyymm);
                        System.debug(adjustQTY + ' ::: adjustQTY');
                        monthBy.isEdit = adjustQTY==0 ? false : true;
                        wrapper.monthlyList.add(monthBy);
                       
                        if(monthBy.quantity > 0) {
                            partList.add(wrapper.partCode);
                            yyyymmList.add(monthBy.yyyymm);
                        }
                      
                    }
                    
                    returnPage.recordList.add(wrapper);
                } else {
                    break;
                }
            }
            if(returnPage.recordList.size() <= 0) {
                throw new DN_DemandAdjPerAgencyControllerException('해당 부품으로 조회되는 데이터가 없습니다.');
            }
            returnPage.startIdx = startIdx;
            returnPage.endIdx = endIdx;
            returnPage.currentPage = nextPage;
            System.debug(returnPage + ' :: returnPage');
            return returnPage;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DemandAdjPerAgencyControllerException(e.getMessage());
        }
    }

    /**
    * @description 검색 조건에 따른 대리점별 수요조정 엑셀데이터
    * @author iltae.seo | 2025-02-07 
    **/
    @AuraEnabled
    public static PageReturn setExcelData(PageReturn page, Integer nextPage){
        try {
            PageReturn returnPage = page;
            Map<String,Integer> pageMap = setpageSetting(returnPage,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            Map<String,String> queryMap = setDataQuery(returnPage,limitSet);
            
            List<String> partList = new List<String>();
            List<String> yyyymmList = new List<String>();
            //데이터 조회
            List<MonthlyDemandSummaryByDealer__c> dataList =Database.query(queryMap.get('dataQuery')); //curQtyQuery
            
            System.debug(queryMap.get('curQtyQuery') + ' ::: curQty');
            System.debug(queryMap.get('dataQuery') + ' data QUERY ');
             Map<String,Decimal> summaryMap = new Map<String,Decimal>();
            for(MonthlyDemandSummaryByDealer__c demaned : dataList) {
                if(summaryMap.get(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c) !=null) {
                    Decimal total = summaryMap.get(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c) + demaned.FM_TotalQuantity__c;
                    summaryMap.put(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c,total);
                } else {
                    summaryMap.put(demaned.Part__r.ProductCode+'!'+demaned.AnalysisPeriodMonth__c, demaned.FM_TotalQuantity__c);
                }
            }
            System.debug(queryMap.get('summaryQuery') + ' :: summaryQuery');
            List<AggregateResult> aggreateList = Database.query(queryMap.get('summaryQuery'));
            // Last Part의 이전 부품들의 수량을 가져옴
            set<String> partCodeSet = new Set<String>();
            for(AggregateResult ages :aggreateList) {
                partCodeSet.add((String)ages.get('maxLastProduct'));
            }
            returnPage.totalRecordSize = Database.query(queryMap.get('countQuery')).size();
            returnPage.allData = new List<DemandAdjPerAgency>();
            for(Integer i=startIdx-1; i<aggreateList.size(); i++) {
                if(i < endIdx) {
                    DateTime currentDate = DateTime.now();
                    DemandAdjPerAgency wrapper = new DemandAdjPerAgency(aggreateList[i]);
                    for (Integer j = 24; j >= 0; j--) {
                        String yyymm =DN_DealerStockManager.getPastMonths(currentDate, -j);
                        String mKey = 'm' + String.valueOf(j);
                        Decimal qty = 0;
                        Decimal adjustQTY = (Decimal) aggreateList[i].get('AdjustQuantity__c'); //maxLastProduct
                        if(summaryMap.get(aggreateList[i].get('ProductCode')+'!'+yyymm) !=null) {                            
                            qty = summaryMap.get(aggreateList[i].get('ProductCode')+'!'+yyymm);
                            
                        }
                        Monthly monthBy  = new Monthly(mKey,qty,yyymm);
                        monthBy.isEdit = adjustQTY==0 ? false : true;
                        wrapper.monthlyList.add(monthBy);
                        if(monthBy.quantity > 0) {
                            partList.add(wrapper.partCode);
                            yyyymmList.add(monthBy.yyyymm);
                        }
                      
                    }
                    returnPage.allData.add(wrapper);
                } else {
                    break;
                }
            }
            System.debug(returnPage.allData + ' ::: returnPage.allData');
            return returnPage;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DemandAdjPerAgencyControllerException(e.getMessage());
        }
    }

    /**
    * @description 상세 데이터 검색
    * @author iltae.seo | 2025-02-10
    **/
    @AuraEnabled
    public static List<Details> getDetails(Map<String,Object> seleted, String type){
        try {
            String partCode = (String) seleted.get('Part');
            String yyyymm = (String) seleted.get('yyyymm');
            String lastParts = (String) seleted.get('lastParts');
            System.debug(seleted + ' ::: seleted');
            set<String> partSet = new set<String>{partCode};
            if(lastParts ==partCode) {
                List<ProductByPlant__c> prodByPlant = [
                    SELECT Id, Name, 
                    Part__c,Part__r.ProductCode, 
                    StartPart__c,StartPart__r.ProductCode,
                    LastPart__c,LastPart__r.ProductCode 
                    FROM ProductByPlant__c 
                    WHERE LastPart__r.ProductCode =:partCode
                    AND Plant__c ='1846'
                ];
                SYstem.debug(prodByPlant + ' :: prodByPlant');
                for(ProductByPlant__c prod : prodByPlant) {
                    partSet.add(prod.Part__r.ProductCode);
                }
            }
            List<AggregateResult> aggreate = [
                select Part__r.ProductCode,AnalysisPeriodMonth__c, 
                MAX(CustomerPrice__c)CustomerPrice  
                FROM MonthlyDemandSummaryByDealer__c
                where Part__r.ProductCode =:partCode
                AND AnalysisPeriodMonth__c =:yyyymm
                AND Dealer__c =: currentUser.getAgencyId()
                group by Part__r.ProductCode,AnalysisPeriodMonth__c
            ];
            String query = 'select Id,FM_OrderNumber__c,';
            query += 'FM_OrderItemNumber__c,toLabel(DemandType__c) DemandType__c,';
            query += 'FM_OrderDate__c,Part__r.ProductCode,';
            query +=  'Part__r.FM_MaterialDetails__c,';
            query +=  'OrderQuantity__c,CurrentQuantity__c,';
            query +=  'FM_Unit__c,SoldToCode__c,';
            query +=  'RoadAddr__c,DetailInfo__c,';
            query +=  'FM_SoldToName__c ';
            query +=  'from DealerOrderSummary__c ';
            query +=  ' where Part__r.ProductCode IN(\''+String.join(partSet, '\',\'')+'\')'; 
            
            if(type == 'Dealer') {
                query +=  ' AND Dealer__c =\''+ currentUser.getAgencyId()+ '\''; 
            }
            query +=  ' AND FM_CreatedDateTime__c =\''+yyyymm+'\'';
            // query +=  ' AND Dealer__c =\''+ currentUser.getAgencyId()+ '\'';
            if(seleted.get('area') !=null) {
                List<DealerAreaByMPPS__c> dealerAreaBy = [select Id, Name, Dealer__r.Name, Area__r.Name from DealerAreaByMPPS__c where Dealer__c =:currentUser.getAgencyId()];
                if(seleted.get('area') !='국내전체') {
                    query +=  ' AND Dealer__c =\''+ currentUser.getAgencyId()+ '\'';
                    if(dealerAreaBy.size() >0) {
                        query +=  ' AND Area__r.Name = \''+dealerAreaBy[0].Area__r.Name+'\'';
                    }
                } 
            }
            List<DealerOrderSummary__c> detailList = Database.query(query);
            System.debug(detailList+' :: detailList');
            List<Details> returnList = new List<Details>();
            for(DealerOrderSummary__c orders : detailList) {
                Details details = new Details(orders);
                if(aggreate.size() > 0) {
                    details.customerPrice = (Decimal) aggreate[0].get('CustomerPrice');
                }
                details.lastParts = lastParts;
                returnList.add(details);
            }
            return returnList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DemandAdjPerAgencyControllerException(e.getMessage());
        }
    }

    /**
    * @description 디테일 Map
    * @author iltae.seo | 2025-02-10
    **/
    public static Map<String,String> getDetailMap(List<String> partList, List<String> yyyymmList){ // return Key Part_yyyyMM
        Map<String,String> returnMap = new Map<String,String>();
        List<DealerOrderSummary__c> detailList = [
            select Id,FM_OrderNumber__c,
            FM_OrderItemNumber__c,toLabel(DemandType__c) DemandType__c,
            FM_OrderDate__c,Part__r.ProductCode,
            Part__r.FM_MaterialDetails__c,FM_CreatedDateTime__c,
            OrderQuantity__c,CurrentQuantity__c,
            FM_Unit__c,SoldToCode__c,
            RoadAddr__c,DetailInfo__c,
            FM_SoldToName__c
            from DealerOrderSummary__c 
            where Part__r.ProductCode IN:partList
            AND FM_CreatedDateTime__c IN:yyyymmList
        ];
        for(DealerOrderSummary__c details : detailList) {
            if(details.OrderQuantity__c != details.CurrentQuantity__c) {
                returnMap.put(details.Part__r.ProductCode + details.FM_CreatedDateTime__c,details.FM_CreatedDateTime__c);
            } 
        }
        System.debug(returnMap + ' ::: returnMap');
        return returnMap;
    }

    /**
    * @description CurrentQTY 저장
    * @author iltae.seo | 2025-02-10
    **/
    @AuraEnabled
    public static void dealerOrderSummarySave(List<Details> detailList, Map<String,Object> seleted){
        try {
            System.debug(seleted + ' ::: seleted');
            String partCode = (String) seleted.get('Part');
            String yyyymm = (String) seleted.get('yyyymm');
            String lastParts = (String) seleted.get('lastParts');
            set<String> partSet = new set<String>{partCode};
            if(lastParts ==partCode) {
                List<ProductByPlant__c> prodByPlant = [
                    SELECT Id, Name, 
                    Part__c,Part__r.ProductCode, 
                    StartPart__c,StartPart__r.ProductCode,
                    LastPart__c,LastPart__r.ProductCode 
                    FROM ProductByPlant__c 
                    WHERE LastPart__r.ProductCode =:partCode
                ];
                for(ProductByPlant__c prod : prodByPlant) {
                    partSet.add(prod.Part__r.ProductCode);
                }
            }
            
            /**
             * MonthlyDemandSummaryByDealer__c
                Quantity__c 
                MonthlyDemandSummaryByRegion__c
                Quantity__c 
                에 반영해준다.
                *반영 시 LastPart가 아닌경우 LastPart의 ReplacementQuantitiy__c에도 반영해준다.
                
                
                대리점 수요조정에서 수정한 수량의 값 
                DealerOrderSummary__c
                OrderQuantity__c - CurrentQuantity__c = AdjustQuantity__c
            */
            // YYYYMM + Part + 지역
            System.debug(detailList + ' :: detailList');
            set<String> orderIds = new set<String>();//adJustQuantity
            List<DealerOrderSummary__c> updateList = new List<DealerOrderSummary__c>();
            for(Details det : detailList) {
                DealerOrderSummary__c order = new DealerOrderSummary__c();
                order.Id = det.id;
                order.CurrentQuantity__c = det.currentQuantity;
                order.AdjustQuantity__c = det.adJustQuantity;
                updateList.add(order);
                orderIds.add(order.Id);
            }
            update updateList;
            Map<String,Decimal> orderSummaryByDealerMap = new Map<String,Decimal>();
            Map<String,Decimal> orderSummaryByRegionMap = new Map<String,Decimal>();
            set<String> areaCode = new set<String>();
            List<AggregateResult> orderDealerResult = [
                SELECT  
                Part__r.ProductCode ProductCode, 
                Dealer__r.CustomerCode__c CustomerCode__c,
                MAX(FM_CreatedDateTime__c) FM_CreatedDateTime__c,
                SUM(AdjustQuantity__c) AdjustQuantity__c
                
                FROM DealerOrderSummary__c      
                WHERE Id IN: orderIds group by Part__r.ProductCode,DAY_ONLY(CreatedDateTime__c),Dealer__r.CustomerCode__c
            ];
            
            List<AggregateResult> orderAreaResult = [
                SELECT  
                Part__r.ProductCode ProductCode, 
                Area__r.Area__c Area__c,
                MAX(FM_CreatedDateTime__c) FM_CreatedDateTime__c,
                SUM(AdjustQuantity__c) AdjustQuantity__c
                FROM DealerOrderSummary__c      
                WHERE Id IN: orderIds group by Part__r.ProductCode,DAY_ONLY(CreatedDateTime__c),Area__r.Area__c 
            ];
            for(AggregateResult orderSum :orderDealerResult) {
                String createdDateTime =  (String)orderSum.get('FM_CreatedDateTime__c');
                String productCode =  (String)orderSum.get('ProductCode');
                String customerCode =  (String)orderSum.get('CustomerCode__c');
                Decimal adjustQuantity = (Decimal) orderSum.get('AdjustQuantity__c');
                orderSummaryByDealerMap.put(createdDateTime + productCode + customerCode,adjustQuantity);
            }
            for(AggregateResult orderAreaSum :orderAreaResult) {
                String createdDateTime =  (String)orderAreaSum.get('FM_CreatedDateTime__c');
                String productCode =  (String)orderAreaSum.get('ProductCode');
                String area =  (String)orderAreaSum.get('Area__c');
                areaCode.add(area);
                Decimal adjustQuantity = (Decimal) orderAreaSum.get('AdjustQuantity__c');
                orderSummaryByRegionMap.put(createdDateTime + productCode + area,adjustQuantity);
            }
            
            List<sObject> summaryByList = new List<sObject>();
            // 지역별 합계, 대리점별 합계 반영
            List<MonthlyDemandSummaryByDealer__c> monthByDealer =[
                SELECT  Id, Part__r.ProductCode,Dealer__c,
                LastPart__r.ProductCode,Dealer__r.CustomerCode__c,
                ReplacementQuantitiy__c,Quantity__c,
                AnalysisPeriodMonth__c
                FROM MonthlyDemandSummaryByDealer__c 
                WHERE Part__r.ProductCode IN : partSet 
                AND AnalysisPeriodMonth__c=:yyyymm
                AND Dealer__c =: currentUser.getAgencyId()
            ];
            List<MonthlyDemandSummaryByRegion__c> monthByRegin = [
                SELECT Id, Part__r.ProductCode,
                LastPart__r.ProductCode,
                Area__r.Area__c,ReplacementQuantitiy__c,Quantity__c
                ,AnalysisPeriodMonth__c
                FROM MonthlyDemandSummaryByRegion__c 
                WHERE AnalysisPeriodMonth__c=:yyyymm
                AND Part__r.ProductCode IN : partSet 
                AND Area__r.Area__c IN :areaCode
            ];
            for(MonthlyDemandSummaryByDealer__c monDealer : monthByDealer) {
                if(orderSummaryByDealerMap.get(monDealer.AnalysisPeriodMonth__c+monDealer.Part__r.ProductCode+monDealer.Dealer__r.CustomerCode__c)!=null) {
                    Decimal adJustQuantity = orderSummaryByDealerMap.get(monDealer.AnalysisPeriodMonth__c+monDealer.Part__r.ProductCode+monDealer.Dealer__r.CustomerCode__c);
                    // Last Part인 경우 ReplacementQuantitiy__c 업데이트
                    if(monDealer.Part__r.ProductCode == monDealer.LastPart__r.ProductCode) {
                        monDealer.AdjustQuantity__c = adJustQuantity;
                    } else {
                        monDealer.AdjustQuantity__c = adJustQuantity;
                    }
                }
            }
            System.debug(monthByRegin + ' ::: monthByRegin');
            for(MonthlyDemandSummaryByRegion__c monArea : monthByRegin) {
                System.debug(orderSummaryByRegionMap.get(monArea.AnalysisPeriodMonth__c+monArea.Part__r.ProductCode+monArea.Area__r.Area__c) + ' adjust1111');
                if(orderSummaryByRegionMap.get(monArea.AnalysisPeriodMonth__c+monArea.Part__r.ProductCode+monArea.Area__r.Area__c)!=null) {
                    Decimal adJustQuantity = orderSummaryByRegionMap.get(monArea.AnalysisPeriodMonth__c+monArea.Part__r.ProductCode+monArea.Area__r.Area__c);
                    
                    // Last Part인 경우 ReplacementQuantitiy__c 업데이트
                    if(monArea.Part__r.ProductCode == monArea.LastPart__r.ProductCode) {
                        monArea.AdjustQuantity__c = adJustQuantity;
                    } else {
                        monArea.AdjustQuantity__c = adJustQuantity;
                    }
                }
            }
            summaryByList.addAll(monthByRegin);
            summaryByList.addAll(monthByDealer);
            update summaryByList;

        } catch (Exception e) {
            System.debug(e.getMessage() + ' ::: e.getMessage()');
            System.debug(e.getStackTraceString() + ' ::: e.getStackTraceString()');
            throw new DN_DemandAdjPerAgencyControllerException(e.getMessage());
        }
    }


    /**
    * @description 페이지 설정
    * @author iltae.seo | 2025-02-07 
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
    * @description 대리점별 조회조건 쿼리
    * @author iltae.seo | 2025-02-07 
    * @param  PageReturn,limitSet
    * @return Map<String,String> returnMap
    **/
    public static Map<String,String> setDataQuery(PageReturn returnPages,Integer limitSet) {
        Map<String,String> returnMap = new Map<String,String>();
        
        String partByMppsQ = 'SELECT Id,ABCIndicator__c,MRPType__c,Part__c,Dealer__c,Part__r.FM_MaterialDetails__c FROM DealerPartMasterByMPPS__c';
        String summaryByDelerQ = 'SELECT Id,Dealer__c,AnalysisPeriodMonth__c,LastPart__c,CustomerPrice__c,';
        summaryByDelerQ +=' Quantity__c,Frequency__c,ReplacementQuantitiy__c,ReplacementFrequency__c, FM_TotalQuantity__c,FM_TotalFrequency__c,';
        summaryByDelerQ += ' Part__r.FM_MaterialDetails__c, Part__r.ProductCode,FM_Unit__c,LastPart__r.ProductCode, AdjustQuantity__c ';
        summaryByDelerQ += ' FROM MonthlyDemandSummaryByDealer__c';
        //집계쿼리
        String aggregateQuery = ' SELECT Part__r.ProductCode,';
        aggregateQuery += ' MAX(LastPart__c) maxLastPart,';
        aggregateQuery += ' MAX(Part__r.FM_MaterialDetails__c) maxFMDetails,';
        aggregateQuery += ' MAX(FM_Unit__c) maxUnit,';
        aggregateQuery += ' MAX(LastPart__r.ProductCode) maxLastProduct,';
        aggregateQuery += ' MAX(CustomerPrice__c) maxCustomerPrice,';
        aggregateQuery += ' MAX(Dealer__c) maxDealer,';
        aggregateQuery += ' MAX(Part__c) maxPart,';
        aggregateQuery += ' SUM(AdjustQuantity__c) AdjustQuantity__c';
        aggregateQuery += ' FROM MonthlyDemandSummaryByDealer__c';
        String groupWhere = ' GROUP BY Part__r.ProductCode '; 

        String whereQ =' where Part__c !=null';
        String countQ = 'select count(Id) from MonthlyDemandSummaryByDealer__c ';
        String countWhereQ = ' where Part__c IN (select Part__c from DealerPartMasterByMPPS__c WHERE Part__c !=null '; //)

        // 화면에 보여줄 Cur 수량 //DealerOrderSummary__c 
        String dealerOrderQ = ' SELECT FM_CreatedDateTime__c , Id, Name, Part__r.ProductCode, OrderQuantity__c,CurrentQuantity__c from DealerOrderSummary__c ';
        

        // 부품코드
        String products = (String) returnPages.strQuery.get('productCode');
        //String nameList = '\'' + String.join(accountNames, '\',\'') + '\''; 
        if(String.isNotBlank(products)) {
            List<String> productCodeList = products.split(',');
            System.debug(productCodeList + ' :: productCodeList');
            whereQ += ' AND Part__c IN(\''+String.join(productCodeList, '\',\'') +'\')';
            countWhereQ += ' AND Part__c IN(\''+String.join(productCodeList, '\',\'')+'\')';
        }
        // ABC Indicatior
        if((String) returnPages.strQuery.get('abcIndicatior') !='ALL') {
            String abcIndicatior = (String) returnPages.strQuery.get('abcIndicatior');
            whereQ += ' AND ABCIndicator__c =\''+abcIndicatior+'\'';
            countWhereQ += ' AND ABCIndicator__c =\''+abcIndicatior+'\'';
        }

        // MRP TYPE
        if((String) returnPages.strQuery.get('MRPType') !='All') {
            String mrpType = (String) returnPages.strQuery.get('MRPType');
            whereQ += ' AND MRPType__c =\''+mrpType+'\'';
            countWhereQ += ' AND MRPType__c =\''+mrpType+'\'';
        }
        // 현재 유저 딜러
        String accountId = currentUser.getAgencyId();
        if(accountId !=null) {
            whereQ += ' AND Dealer__c =\''+accountId+'\'';
            countWhereQ += ' AND Dealer__c =\''+accountId+'\'';
        }
        countWhereQ += ')';
        System.debug(partByMppsQ + whereQ + ' :: whereQ');
        // DealerPartMasterByMPPS__c 기준으로 먼저 필터링 
        List<DealerPartMasterByMPPS__c> byMppsList = Database.query(partByMppsQ + whereQ);
        if(byMppsList.size() ==0) {
            throw new DN_DemandAdjPerAgencyControllerException('조건에 해당하는 부품정보가 없습니다.');
        }
        set<String> summaryByDelerQDealer = new set<String>();
        List<String> summaryByDelerQPart = new List<String>();
        String summaryByDelerQWhere = ' WHERE Id !=null AND Part__c !=null ';
        for(DealerPartMasterByMPPS__c byMpps : byMppsList) {
            String mapKey = String.valueOf(byMpps.Part__c);
            partByMppsMap.put(mapKey, byMpps);
            summaryByDelerQDealer.add(byMpps.Dealer__c);
            summaryByDelerQPart.add(byMpps.Part__c);
        }
        if(byMppsList.size() ==0) {
            List<String> productCodeList = products.split(',');
            summaryByDelerQWhere +=' AND Part__c IN(\''+String.join(productCodeList, '\',\'')+'\')'; 
            summaryByDelerQWhere += ' AND Dealer__c =\''+accountId+'\'';
        }
        if(summaryByDelerQDealer.size() > 0) {
            summaryByDelerQWhere += ' AND Dealer__c IN(\''+String.join(summaryByDelerQDealer, '\',\'')+'\')';
        }
        if(summaryByDelerQPart.size() > 0) {
            summaryByDelerQWhere += ' AND Part__c IN(\''+String.join(summaryByDelerQPart, '\',\'')+'\')';
        }
        List<String> monthList = getYYYYMM();
        Integer totalSize = Database.query(countQ + countWhereQ+' '+ groupWhere+' limit 50000').size();
        Integer dataLimit = 50000;
        if(totalSize > 10000) {
            dataLimit = 10000;
        }
        returnMap.put('dataQuery',summaryByDelerQ +summaryByDelerQWhere+' AND AnalysisPeriodMonth__c >=\''+monthList[0]+'\' '+returnPages.orderByField+' '+returnPages.orderBy + ' LIMIT '+dataLimit); //+' limit ' + limitSet);
        returnMap.put('curQtyQuery',dealerOrderQ+summaryByDelerQWhere+' AND FM_CreatedDateTime__c >=\''+monthList[0]+'\' '+returnPages.orderByField+' '+returnPages.orderBy + ' LIMIT '+dataLimit); //+' limit ' + limitSet);
        returnMap.put('summaryQuery',aggregateQuery +summaryByDelerQWhere+groupWhere+returnPages.orderByField+' '+returnPages.orderBy +' limit ' + limitSet);
        returnMap.put('countQuery',countQ + countWhereQ+' '+ groupWhere+' limit 50000');
          
        return returnMap;
    }

    
    public static Map<String,Decimal> getLastPartByMap(String sObjectName, set<String> partList){
        Map<String,Decimal> returnMap = new Map<String,Decimal>();
        List<String> monthList = getYYYYMM();
        String selectQ = 'SELECT AnalysisPeriodMonth__c,Part__r.ProductCode, LastPart__r.ProductCode,FM_TotalQuantity__c ';
        String fromQ = ' FROM '+sObjectName; 
        String whereQ = ' WHERE Id !=null ';
        if(sObjectName !='MonthlyDemandSummaryByRegion__c') {
            whereQ +=' AND Dealer__c =\''+currentUser.getAgencyId()+'\'';
        } 
        
        whereQ +=' AND LastPart__r.ProductCode IN(\''+String.join(partList, '\',\'') +'\')';
        whereQ +=' AND AnalysisPeriodMonth__c >=\''+monthList[0]+'\'';
        System.debug(selectQ+fromQ+whereQ + ' ::: whereQ');
        
        for(sObject obj :Database.query(selectQ+fromQ+whereQ)) {
            String partCode = obj.getSObject('Part__r').get('ProductCode') ==null ? '' : (String) obj.getSObject('Part__r').get('ProductCode');
            String month = obj.get('AnalysisPeriodMonth__c') == null ? '' : (String) obj.get('AnalysisPeriodMonth__c');
            String lastPart = obj.getSObject('LastPart__r').get('ProductCode') ==null? '': (String) obj.getSObject('LastPart__r').get('ProductCode');
            Decimal total = obj.get('FM_TotalQuantity__c') == null ? 0 : (Decimal) obj.get('FM_TotalQuantity__c');
            if(partCode !=lastPart) {
                Decimal totalQty = returnMap.get(lastPart+month) ==null ? total : returnMap.get(lastPart+month) + total;
                returnMap.put(lastPart+month,totalQty);
            }
        }
        System.debug(returnMap + ' ::: returnMap');
        return returnMap;
    }


    /**
     * 지역별 수요조회, 대리점별 수요조정
     */
    // 데이터 리턴 페이징 처리까지 
    public class PageReturn {
        @AuraEnabled public Map<String,Object> strQuery { get; set; } // 전체 데이터 쿼리
        @AuraEnabled public Integer totalRecordSize { get; set; } // 전체 레코드 사이즈
        @AuraEnabled public List<DemandAdjPerAgency> recordList { get; set; } // 현재 페이지 데이터
        @AuraEnabled public List<DemandAdjPerAgency> allData { get; set; } // 전체데이터
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
     * Stock Monitoring
     */
    // 데이터 리턴 페이징 처리까지
    public class PageReturns {
        @AuraEnabled public Map<String,Object> strQuery { get; set; } // 전체 데이터 쿼리
        @AuraEnabled public Integer totalRecordSize { get; set; } // 전체 레코드 사이즈
        @AuraEnabled public List<StockMonitoring> recordList { get; set; } // 현재 페이지 데이터
        @AuraEnabled public List<StockMonitoring> allData { get; set; } // 전체데이터
        @AuraEnabled public Integer itemsPerPage { get; set; } // 한 페이지당 표시할 데이터 수
        @AuraEnabled public Integer currentPage { get; set; } // 현재 페이지
        @AuraEnabled public Integer pagesPerGroup {get;set;} // 현재 화면에 표시할 페이지 갯수
        @AuraEnabled public Integer startIdx {get;set;} // 시작인덱스
        @AuraEnabled public Integer endIdx {get;set;} // 마지막인덱스
        @AuraEnabled public String orderByField {get;set;} // 정렬 필드,
        @AuraEnabled public String orderBy {get;set;} // 정렬 필드,
        public PageReturns() {} 
    }


    public class DemandAdjPerAgency implements Comparable {
        
        @AuraEnabled public String partCode {get;set;} 
        @AuraEnabled public String repl {get;set;} // Last Part 일 경우 빨간색 아이콘 표시
        @AuraEnabled public String area {get;set;} 
        @AuraEnabled public String partDetails {get;set;} 
        @AuraEnabled public String lastParts {get;set;} 
        @AuraEnabled public List<Monthly> monthlyList {get;set;}
        @AUraEnabled public String unit {get;set;}
        @AUraEnabled public String aBC {get;set;}
        @AUraEnabled public String mrpType {get;set;}
        @AuraEnabled public Decimal customerPrice {get;set;}
        public DemandAdjPerAgency() {
        }
        public DemandAdjPerAgency(MonthlyDemandSummaryByDealer__c monthBy) {
            System.debug(monthBy.Part__r.ProductCode + ' ~~~~123');
            System.debug(monthBy.LastPart__r.ProductCode + ' !!!!123');
            this.repl          =  monthBy.Part__r.ProductCode ==monthBy.LastPart__r.ProductCode ? '' : 'RED';
            this.partCode      =  monthBy.Part__r.ProductCode;    
            this.partDetails   =  monthBy.Part__r.FM_MaterialDetails__c;    
            this.unit          =  monthBy.FM_Unit__c;
            this.lastParts     =  monthBy.LastPart__r.ProductCode;
            this.customerPrice =  monthBy.CustomerPrice__c;
            String exKey = String.valueOf(monthBy.Part__c);
            if(partByMppsMap.get(exKey) !=null) {
                this.aBC           =  partByMppsMap.get(exKey).ABCIndicator__c;  
                this.mrpType       =  partByMppsMap.get(exKey).MRPType__c;          
            }      
            this.monthlyList = new List<Monthly>();
        }
        // 대리점별 수요조정
        public DemandAdjPerAgency(AggregateResult monthBy) {
            System.debug(monthBy.get('ProductCode') + ' ~~~');
            System.debug(monthBy.get('maxLastProduct') + ' !!!!');
            this.repl          =  monthBy.get('ProductCode') ==monthBy.get('maxLastProduct') ? '' : 'RED';
            this.partCode      =  (String) monthBy.get('ProductCode');    
            this.partDetails   =  (String) monthBy.get('maxFMDetails');    
            this.unit          =  (String) monthBy.get('maxUnit');
            this.lastParts     =  (String) monthBy.get('maxLastProduct');
            String exKey = String.valueOf(monthBy.get('maxPart'));
            if(partByMppsMap.get(exKey) !=null) {
                this.aBC           =  partByMppsMap.get(exKey).ABCIndicator__c;  
                this.mrpType       =  partByMppsMap.get(exKey).MRPType__c;          
            }      
            this.monthlyList = new List<Monthly>();
        }
        // 지역별 수요조회
        public void convert(AggregateResult monthBy, String areaName) {
            this.repl = monthBy.get('maxLastProduct') ==monthBy.get('ProductCode') ? '' : 'RED';
            this.lastParts     =  (String) monthBy.get('maxLastProduct');
            this.partCode      =  (String)monthBy.get('ProductCode'); 
            if(abcMap.get(this.partCode) !=null) {
                AggregateResult abcAge = abcMap.get(this.partCode);
                this.partDetails   = (String)abcAge.get('FM_MaterialDetails__c');
                this.unit          = (String)abcAge.get('Unit__c');
                this.aBC           = (String)abcAge.get('ABCIndicator__c');
                this.mrpType       = (String)abcAge.get('MRPType__c');
            }
            if(areaName == String.valueOf(monthBy.get('Area__c'))) {
                this.area              =  areaName;
            } else {
                this.area              = '국내전체';
            }
            this.monthlyList = new List<Monthly>();
        }
        public void convert(String productCode,String areaName) {
            AggregateResult partResult =  abcMap.get(productCode);
            this.repl          =  partResult.get('LastProductCode') == partResult.get('ProductCode') ? '' : 'RED';
            this.partCode      =  (String) partResult.get('ProductCode');    
            this.partDetails   =  (String) partResult.get('FM_MaterialDetails__c');    
            this.unit          =  (String) partResult.get('Unit__c');
            this.lastParts     =  (String) partResult.get('LastProductCode');
            this.aBC           =  (String) partResult.get('ABCIndicator__c');  
            this.mrpType       =  (String) partResult.get('MRPType__c');
            this.area              = areaName;
            this.monthlyList = new List<Monthly>();
        }


        public DemandAdjPerAgency deepClone() {
            System.debug(this + ' ::: this');
            return (DemandAdjPerAgency) JSON.deserialize(JSON.serialize(this), DemandAdjPerAgency.class);
        }

        // 정렬
        public Integer compareTo(Object compareTo) {
            DemandAdjPerAgency compareToTarget = (DemandAdjPerAgency)compareTo;
            // 1. 부품 코드 기준 정렬
            // 1. 부품 코드 기준 정렬
            if (this.partCode < compareToTarget.partCode) return -1;
            if (this.partCode > compareToTarget.partCode) return 1;
        
            // 2. 같은 부품 코드 내에서 area 정렬 ("국내전체"를 항상 위로)
            if (this.area == '국내전체' && compareToTarget.area != '국내전체') return 1;
            if (this.area != '국내전체' && compareToTarget.area == '국내전체') return -1;
            
            return 0; // 같은 값이면 0 반환
        }


    }

    public class Monthly {
        @AuraEnabled public String monthKey {get;set;}
        @AuraEnabled public String yyyymm {get;set;}
        @AuraEnabled public Decimal quantity {get;set;}
        @AuraEnabled public Boolean isEdit {get;set;}
        @AuraEnabled public Integer index {get;set;}
        public Monthly() {
        }
        public Monthly(String monKey, Decimal quantity, String yyyymm) {
            this.monthKey           = monKey;
            this.quantity           = quantity;
            this.yyyymm             = yyyymm;
            this.isEdit             = false;
        }
        public Monthly(String monKey, Decimal quantity, String yyyymm, Integer index) {
            this.monthKey           = monKey;
            this.quantity           = quantity;
            this.yyyymm             = yyyymm;
            this.isEdit             = false;
            this.index              = index;

        }
    }

    public class Details {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String orderNumber {get;set;}
        @AuraEnabled public String orderItemNumber {get;set;}
        @AuraEnabled public String orderType {get;set;}
        @AuraEnabled public String orderDate {get;set;}
        @AuraEnabled public String partCode {get;set;}
        @AuraEnabled public String lastParts {get;set;}
        @AuraEnabled public String partDetails {get;set;}
        @AuraEnabled public Decimal orderQuantity {get;set;}
        @AuraEnabled public Decimal currentQuantity {get;set;}
        @AuraEnabled public Decimal adJustQuantity {get;set;}
        @AuraEnabled public String unit {get;set;}
        @AuraEnabled public String soldToCode {get;set;}
        @AuraEnabled public String soldToName {get;set;}
        @AuraEnabled public String soldToAddress {get;set;}
        @AuraEnabled public Decimal customerPrice {get;set;}
        public Details(){}
        public Details(DealerOrderSummary__c details) {
            this.id                   = details.Id;                          
            this.orderNumber          = details.FM_OrderNumber__c;                                
            this.orderItemNumber      = details.FM_OrderItemNumber__c;                                      
            this.orderType            = details.DemandType__c;                              
            this.partCode             = details.Part__r.ProductCode;                              
            this.partDetails          = details.Part__r.FM_MaterialDetails__c;                                  
            this.orderQuantity        = details.OrderQuantity__c;                                  
            this.currentQuantity      = details.CurrentQuantity__c;                                      
            this.adJustQuantity       = details.CurrentQuantity__c - details.OrderQuantity__c;                                 
            this.unit                 = details.FM_Unit__c;                          
            this.soldToCode           = details.SoldToCode__c;                              
            this.soldToName           = String.isNotBlank(details.FM_SoldToName__c)? details.FM_SoldToName__c : '';     
            String address =  String.isNotBlank(details.RoadAddr__c)? details.RoadAddr__c : '';
            address +=  String.isNotBlank(details.DetailInfo__c)? details.DetailInfo__c : '';                        
            this.soldToAddress        = address;      
            this.orderDate            = details.FM_OrderDate__c;     
            this.customerPrice        = 0;                                                   
        }
    }
    
    /**
     * Stock Monitoring Class
     * 
     */
    public class StockMonitoring {
        @AuraEnabled public String id {get;set;}                                                            
        @AuraEnabled public String material {get;set;}                                                          
        @AuraEnabled public String materialDesc {get;set;}                                                          
        @AuraEnabled public String startParts {get;set;}                                                            
        @AuraEnabled public String lastParts {get;set;}                                                         
        @AuraEnabled public String mrpType {get;set;}                                                           
        @AuraEnabled public Decimal rop {get;set;}                                                          
        @AuraEnabled public Decimal minLot {get;set;}                                                           
        @AuraEnabled public Decimal maxLv {get;set;}                                                            
        @AuraEnabled public String abc {get;set;}                                                           
        @AuraEnabled public Decimal m12 {get;set;}                                                          
        @AuraEnabled public Decimal m18 {get;set;}                                                          
        @AuraEnabled public Decimal m24 {get;set;}                                                          
        @AuraEnabled public String type {get;set;} // 
        
        @AuraEnabled public Boolean isExcludeStockMonitoring {get;set;}  
        @AuraEnabled public String partsNote {get;set;}                                                         
        public StockMonitoring() {}

        public StockMonitoring(DealerPartMasterByMPPS__c mpps) {
            this.id                         = mpps.Id;
            this.material                   = mpps.Part__r.ProductCode;
            this.materialDesc               = mpps.Part__r.FM_MaterialDetails__c;
            this.mrpType                    = mpps.MRPType__c;
            this.rop                        = Math.round(mpps.ReorderPoint__c);
            this.minLot                     = mpps.MinimumLotSize__c;
            this.maxLv                      = Math.round(mpps.MaximumStock__c);
            this.abc                        = mpps.ABCIndicator__c;
            this.isExcludeStockMonitoring   = mpps.IsExcludeStockMonitoring__c; //StartPart__r.ProductCode, LastPart__r.ProductCode
            this.startParts                 = mpps.StartPart__r.ProductCode;
            this.lastParts                  = mpps.LastPart__r.ProductCode;
        }                   

        public void convert(AggregateResult m12, AggregateResult m18, AggregateResult m24) {
            this.startParts         = m12 == null? '' : (String) m12.get('StartPart');
            this.lastParts          = m12 == null? '' : (String) m12.get('LastPart');
            System.debug(m18 + ' ::: m18');
            this.m12                = m12 == null? 0 : (Decimal) m12.get('FM_TotalFrequency__c');
            this.m18                = m18 == null? 0 : (Decimal) m18.get('FM_TotalFrequency__c');
            this.m24                = m24 == null? 0 : (Decimal) m24.get('FM_TotalFrequency__c');
            /**
             * - MRP Type 이 'ND' 이고 (M-1) ~ (M-24) 기간 동안 빈도가 3회 이상일 경우 'VB' 변경 대상 ( ABC 등급 W, P, M, Z, S, N 은 제외)
                - MRP Type 이 'VB' 이고 (M-1) ~ (M-18) 동안의 빈도가 0 이하인 경우 'ND' 변경 대상
             */
            if(this.mrpType =='ND') {
                if(this.m24 > 3) {
                    switch on this.abc {
                        when 'A' { this.type = 'VB'; }
                        when 'B' { this.type = 'VB'; }
                        when 'C' { this.type = 'VB'; }
                        when 'D' { this.type = 'VB'; }
                        when 'E' { this.type = 'VB'; }
                        when 'F' { this.type = 'VB'; }
                        when 'G' { this.type = 'VB'; }
                        when 'H' { this.type = 'VB'; }
                        when 'I' { this.type = 'VB'; }
                        when 'M' { this.type = 'VB'; }
                        when 'r' { this.type = 'VB'; }
                    }
                } else {
                    this.type = 'ND'; 
                }
            } else { // VB
                if(this.m18 <= 0 ) {
                    this.type='ND';
                } else {
                    this.type='VB';
                }
            }
        }
    }
    public class DN_DemandAdjPerAgencyControllerException extends Exception {}    
}