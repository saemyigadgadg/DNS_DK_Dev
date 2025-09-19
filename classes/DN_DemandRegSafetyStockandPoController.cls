/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 02. 21. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-21 | Iltae seo      | 최초작성 
 */ 
public without sharing class DN_DemandRegSafetyStockandPoController {
    /**
     * ZSPT2420 // DealerPartMasterByMPPS__c 
     * ZSPT2360 // MonthlyDemandSummaryByDealer__c
        ZSPT2510 // DealerLeadTimeManagement__c
        ZSLT0310 // DealerStock__c
     */
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    /**
     * @Description
     * 	- 데이터 조회 - 안전재고 대상 & ROP 등록 조회
    **/ 
    @AuraEnabled
    public static PageReturns getSafetyStockList(PageReturns page, Integer nextPage, Boolean isExcel) {
        try {
            System.debug(page + ' :: page');
            PageReturns returnPage = page;
            Map<String,Integer> pageMap = setpageSetting(returnPage,nextPage);
            Integer limitSet = pageMap.get('limit');
            Integer startIdx = pageMap.get('startIdx');
            Integer endIdx = pageMap.get('endIdx');
            Map<String,String> getDateQuery = new Map<String,String>();
            
            String dealerId = currentUser.getAgencyId();
            // ZSPT 2420 Query
            String dealerPartMasterByMPPSQ = 'select Id, Part__c,Dealer__r.Name,Part__r.ProductCode,Part__r.FM_MaterialDetails__c,Part__r.Unit__c, ';
            dealerPartMasterByMPPSQ += 'ABCIndicator__c, MRPType__c, SafetyStock__c,';
            dealerPartMasterByMPPSQ += 'MaximumStock__c, ReorderPoint__c, RoundingValue__c,';
            dealerPartMasterByMPPSQ += 'MinimumLotSize__c, FM_Unit__c, FM_ExtentionDate__c,';
            dealerPartMasterByMPPSQ += 'TargetServiceLevel__c, ServiceFactor__c, AMD__c,';
            dealerPartMasterByMPPSQ += 'WAMD__c, STDEV__c, Weight__c,';
            dealerPartMasterByMPPSQ += 'IsFixedROP__c, Dealer__c,';
            dealerPartMasterByMPPSQ += 'IsExcludeStockMonitoring__c from DealerPartMasterByMPPS__c where Dealer__c=\''+dealerId+'\' AND Part__c !=null AND Part__r.RecordType.DeveloperName =\'Part\' ';
            
            String dealerPartMasterByMPPSQCount = 'SELECT COUNT(Id) totalCount FROM DealerPartMasterByMPPS__c where Dealer__c=\''+dealerId+'\' AND Part__c !=null AND Part__r.RecordType.DeveloperName =\'Part\' ';
            // 부품코드
            String products = (String) returnPage.strQuery.get('productCode');
            //String nameList = '\'' + String.join(accountNames, '\',\'') + '\''; 
            if(String.isNotBlank(products)) {
                List<String> productCodeList = products.split(',');
                dealerPartMasterByMPPSQ += ' AND Part__c IN(\''+String.join(productCodeList, '\',\'') +'\')';
                dealerPartMasterByMPPSQCount += ' AND Part__c IN(\''+String.join(productCodeList, '\',\'') +'\')';
            }

            // ABC Indicator
            if((String) returnPage.strQuery.get('ABCIndicator') !='ALL') {
                String abc = (String)returnPage.strQuery.get('ABCIndicator');
                dealerPartMasterByMPPSQ += ' AND ABCIndicator__c =\''+abc+'\'';
                dealerPartMasterByMPPSQCount += ' AND ABCIndicator__c =\''+abc+'\'';
            }
            
            //MRP Type
            if((String) returnPage.strQuery.get('MRPType') !='ALL') {
                String mrpType = (String)returnPage.strQuery.get('MRPType');
                dealerPartMasterByMPPSQ += ' AND MRPType__c =\''+mrpType+'\'';
                dealerPartMasterByMPPSQCount += ' AND MRPType__c =\''+mrpType+'\'';
            }
            // ZSPT 2420
            set<String> partIds = new set<String>();
            set<String> partCode = new set<String>();
            // System.debug(dealerPartMasterByMPPSQ + returnPage.orderByField+' '+returnPage.orderBy +' limit ' + limitSet + ' test1111');
            System.debug('@@@@ : ' + dealerPartMasterByMPPSQ 
                + returnPage.orderByField + ' ' + returnPage.orderBy 
                + ' LIMIT ' + returnPage.itemsPerPage
                + ' OFFSET ' + ((nextPage - 1) * returnPage.itemsPerPage));
                System.debug('@@LIMIT : ' + nextPage);
            // List<DealerPartMasterByMPPS__c> dealerByMppsList = Database.query(dealerPartMasterByMPPSQ + returnPage.orderByField+' '+returnPage.orderBy +' limit ' + limitSet);
            List<DealerPartMasterByMPPS__c> dealerByMppsList = Database.query(
                dealerPartMasterByMPPSQ 
                + returnPage.orderByField + ' ' + returnPage.orderBy 
                + ' LIMIT ' + returnPage.itemsPerPage
                + ' OFFSET ' + ((nextPage - 1) * returnPage.itemsPerPage)
            );
            System.debug('@@Count SQL : ' + dealerPartMasterByMPPSQCount);
            AggregateResult dpmbm = (AggregateResult) Database.query(dealerPartMasterByMPPSQCount);
            Integer totalCount = (Integer) dpmbm.get('totalCount');
            System.debug('@@Count : ' + totalCount);
        
            for(DealerPartMasterByMPPS__c mpps : dealerByMppsList) {
                partIds.add(mpps.Part__c);
                partCode.add(mpps.Part__r.ProductCode);
            }
            Map<String,String> totalMap = getTotalQuery(partIds);
            System.debug(totalMap.get('6mQuery') + ' :::6mQuery');
            List<AggregateResult> m6List = Database.query(totalMap.get('6mQuery'));
            Map<String,Decimal> m6Map = new Map<String,Decimal>();
            for(AggregateResult age : m6List) {
                System.debug(age + '::: 6mQuery');
                m6Map.put( (String)age.get('Part__c'), (Decimal)age.get('FM_TotalFrequency__c'));
            }

            List<AggregateResult> m12List = Database.query(totalMap.get('12mQuery'));
            Map<String,Decimal> m12Map = new Map<String,Decimal>();
            for(AggregateResult age : m12List) {
                System.debug(age + '::: 12mQuery');
                m12Map.put( (String)age.get('Part__c'), (Decimal)age.get('FM_TotalFrequency__c'));
            }
            List<AggregateResult> m18List = Database.query(totalMap.get('18mQuery'));
            Map<String,Decimal> m18Map = new Map<String,Decimal>();
            for(AggregateResult age : m18List) {
                System.debug(age + '::: m18List');
                m18Map.put( (String)age.get('Part__c'), (Decimal)age.get('FM_TotalFrequency__c'));
            }
            System.debug(totalMap.get('MonQuery') + ' monQUERY');
            List<AggregateResult> monList = Database.query(totalMap.get('MonQuery'));
            Map<String,Decimal> mTotalMap = new Map<String,Decimal>();
            for(AggregateResult ages : monList) { //AnalysisPeriodMonth__c
                String mapkey = (String) ages.get('Part__c') + (String)ages.get('AnalysisPeriodMonth__c');
                mTotalMap.put(mapkey, (Decimal) ages.get('FM_TotalQuantity__c'));
            }
            //PDT - SPT 2510 DealerLeadTime
            System.debug(partIds + ' ::: partIds');
            Map<String,Decimal> pdtMap = new Map<String,Decimal>();
            List<DealerLeadTimeManagement__c> pdtList = [
                SELECT Part__c, PlannedDeliveryDays__c,Part__r.ProductCode 
                FROM DealerLeadTimeManagement__c
                WHERE Part__c IN:partIds
            ];
            System.debug(pdtList + ' :: pdtList');
            for(DealerLeadTimeManagement__c dealerTime : pdtList) {
                System.debug(dealerTime + ' ::: dealerTime');
                pdtMap.put(dealerTime.Part__c, dealerTime.PlannedDeliveryDays__c);
            }

            // ZSPT2490 등급별 ROP Factor 조회
            Map<String, ROPAndStockFactorConfig__c> ropFactorMap = new Map<String, ROPAndStockFactorConfig__c>();
            for(ROPAndStockFactorConfig__c ropFactor :[   SELECT
                Dealer__c, ABCIndicator__c, TargetServiceLevel__c, SVCFactor__c
                FROM ROPAndStockFactorConfig__c WHERE RecordType.DeveloperName = 'AreaROPCalculationFactorConfiguration'
                AND Dealer__c = :dealerId
            ]) {
                ropFactorMap.put(ropFactor.ABCIndicator__c, ropFactor);
            }

            // Dealer Stock
            Map<String,String> stockMap = new Map<String,String>();
            List<DealerStock__c> stockList = [
                SELECT Id,Part__c,Note__c FROM DealerStock__c
                where Part__c IN:partIds
                AND Dealer__c =:currentUser.getAgencyId()
            ];
            for(DealerStock__c stock : stockList) {
                stockMap.put(stock.Part__c,stock.Note__c);
            }
            Map<String,Decimal> priceMap = new Map<String,Decimal>();
            if(partCode.size() > 0) {
                priceMap = getIFDataSetting(partCode);
            }
            
            // price 
            // partNote
            //returnPage.recordList = new 
            // 인덱스 기준으로 데이터 목록
            DateTime currentDate = DateTime.now();
            currentDate = currentDate.addDays(-1);
            returnPage.recordList = new List<SafetyStock>();
            for(Integer i=0; i<dealerByMppsList.size(); i++) {
                if(i < endIdx) {
                    String partKey = dealerByMppsList[i].Part__c;
                    Decimal sft = dealerByMppsList[i].ServiceFactor__c;
                    if(ropFactorMap.containsKey(dealerByMppsList[i].ABCIndicator__c)) {
                        sft = ropFactorMap.get(dealerByMppsList[i].ABCIndicator__c).SVCFactor__c;
                    }
                    if(sft == null) sft = 0;

                    SafetyStock safetyStock = new SafetyStock(dealerByMppsList[i]);
                    safetyStock.m6          = m6Map.get(partKey) ==null ? 0 : m6Map.get(partKey);
                    safetyStock.m12         = m12Map.get(partKey) ==null ? 0 : m12Map.get(partKey);
                    safetyStock.m18         = m18Map.get(partKey) ==null ? 0 : m18Map.get(partKey);
                    safetyStock.pdt         = pdtMap.get(partKey) == null ? 0 : pdtMap.get(partKey);
                    safetyStock.partsNote   = stockMap.get(partKey);
                    safetyStock.monthlyList = new List<Monthly>();
                    safetyStock.price       = priceMap.get(dealerByMppsList[i].Part__r.ProductCode); 
                    List<ROPAndStockFactorConfig__c> priceWeights = [ 
                        SELECT
                            ABCIndicator__c, PriceFrom__c, PriceTo__c, Weight__c, AMDType__c
                        FROM ROPAndStockFactorConfig__c 
                        WHERE RecordType.DeveloperName = 'AreaMaxStockWeightingFactor' AND Dealer__c != null AND Dealer__c = :dealerId
                        AND ABCIndicator__c = :dealerByMppsList[i].ABCIndicator__c AND ( PriceFrom__c <= :safetyStock.price AND PriceTo__c >=: safetyStock.price)
                        LIMIT 1
                    ];

                    if(priceWeights.size() > 0) {
                        safetyStock.weight = priceWeights[0].Weight__c;
                    }
                    if(safetyStock.weight == null) safetyStock.weight = 0;

                    List<Decimal> qtyList = new List<Decimal>();
                    for (Integer j = 18; j >= 0; j--) {
                        Decimal qty = 0;
                        String mKey = 'm' + String.valueOf(j);
                        String yyyymm = DN_DealerStockManager.getPastMonths(currentDate, -j);
                        if(mTotalMap.get(partKey + yyyymm) !=null) {
                            qty = mTotalMap.get(partKey + yyyymm);
                            qtyList.add(qty);
                            if(j != 0) {
                                safetyStock.sumdWeight += qty * (19-j);
                            }
                        }
                        Monthly mon = new Monthly(mKey,qty,yyyymm);
                        System.debug(mon  +' ::: mon');
                        safetyStock.monthlyList.add(mon);
                    }  
                    safetyStock.wAMD = (safetyStock.sumdWeight / safetyStock.sumWeight).setScale(3, RoundingMode.HALF_UP);
                    //표준편차 구하기
                    /*
                    * 표준편차 (기준 18개월)
                    * Case 1 (수요가 있는 개월 수 > 12)
                    * = SQRT( 18개월의 제품중 최상/최하위 2개씩 제외한 수요의 합 /(18 - (18개월 수요 최상/최하 2개씩 제외한 수요월 개수 (=4)) - 1))
                    * 
                    * Case 2 (수요가 있는 개월 수 > 6)
                    * = SQRT( 18개월의 제품중 최상/최하위 1개씩 제외한 수요의 합 /(18 - (18개월 수요 최상/최하 수요월 개수 (=2)) - 1))
                    * 
                    * Case 3 (수요가 있는 개월 수 <= 6)
                    * = SQRT( 18개월의 제품별 수요의 합 /(18 - 1))
                    */

                    qtyList.sort(); //정렬
                    Integer demandSize = qtyList.size();
                    System.debug('demandSize : '+demandSize);

                    if(demandSize > 12) {
                        //Case 1 (수요가 있는 개월 수 > 12)
                        //최상위 2건 삭제
                        qtyList.remove(0);
                        qtyList.remove(0);

                        //최하위 2건 삭제
                        qtyList.remove(qtyList.size() - 1);
                        qtyList.remove(qtyList.size() - 1);
                        
                    }else if(demandSize > 6) {
                        //Case 2 (수요가 있는 개월 수 > 6)

                        //최상위 1건 삭제
                        qtyList.remove(0);

                        //최하위 1건 삭제
                        qtyList.remove(qtyList.size() - 1);
                        
                    }else {
                        //Case 3 (수요가 있는 개월 수 <= 6)
                        //18개월 데이터 모두 사용 - By Pass
                    }

                    Decimal sumDemandCount = 18 -  Decimal.valueOf(( demandSize - qtyList.size())); // 전체 개수에서 로직
                    Decimal sumDemand =  0;
                    for(Decimal demand : qtyList) {
                        sumDemand += demand;
                    }

                    // // 평균 수요 계산
                    // System.debug('sumDemand : '+sumDemand + ' / sumDemandCount : '+sumDemandCount);
                    Decimal avgDemand = sumDemand / sumDemandCount; 

                    // //평균으로부터 떨어진 거리를 제곱한 값
                    Decimal sumSquaredDeviation = 0; 
                    for(Integer idx = 0; idx < sumDemandCount; idx++) {
                        Decimal demand = idx < qtyList.size() ? qtyList.get(idx) : 0.0; //
                        Decimal squaredDeviation = (demand - avgDemand) * (demand - avgDemand);
                        sumSquaredDeviation += squaredDeviation;
                    }

                    safetyStock.sTDEV = Math.sqrt(sumSquaredDeviation / (sumDemandCount - 1)).setScale(3, RoundingMode.HALF_UP);
                    Decimal ropSafetyStock = (sft * safetyStock.sTDEV * Math.sqrt((safetyStock.pdt/30))).setScale(3, RoundingMode.HALF_UP);
                    safetyStock.nROP = Math.ceil(safetyStock.wAMD * (safetyStock.pdt/30) +ropSafetyStock);
                    safetyStock.nMaxLv = Math.ceil(safetyStock.nROP + (safetyStock.weight * safetyStock.wAMD));

                    returnPage.recordList.add(safetyStock);
                    
                } else {
                    break;
                }
            }
            System.debug(returnPage.recordList.size() + ' ::: isExcel');
            System.debug(returnPage.recordList + 'test tetst');
            if(!isExcel) {
                
                // 페이지 설정
                // returnPage.totalRecordSize = returnPage.recordList.size();
                returnPage.totalRecordSize = totalCount;
                returnPage.startIdx = startIdx;
                returnPage.endIdx = endIdx;
                returnPage.currentPage = nextPage;
            }
            
            return returnPage;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            throw new DN_DemandRegSafetyStockandPoControllerException(e.getMessage());
        }
    }

    /**
    * @description 안전재고 대상 & ROP 등록 저장
    * @author iltae.seo | 2025-02-25 
    **/
    @AuraEnabled
    public static void ropSave(List<SafetyStock> saveData){
        try {
            System.debug(saveData + ' ::: saveData');
            List<DealerPartMasterByMPPS__c> mppsList = new List<DealerPartMasterByMPPS__c>();
            List<DealerStock__c> stockList = new List<DealerStock__c>();
            for(SafetyStock safe : saveData) {
                
                DealerPartMasterByMPPS__c mpps = new DealerPartMasterByMPPS__c();
                mpps.Id                         = safe.id;
                mpps.MaximumStock__c            = safe.nMaxLv;
                mpps.ReorderPoint__c            = safe.nROP;
                mpps.MRPType__c                 = safe.mrpType;
                mpps.IsFixedROP__c              = safe.fix;
                mpps.RoundingValue__c           = safe.nRVal;
                mpps.MinimumLotSize__c          = safe.nMinLot;
                mpps.Part__c                    = safe.materialId;
                mppsList.add(mpps);
                // 딜러 재고 업데이트
                DealerStock__c stock = new DealerStock__c();
                stock.Part__c = safe.materialId;
                stock.Dealer__c = currentUser.getAgencyId();
                stock.Division__c = currentUser.getDivision();
                stock.DistributionChannel__c = currentUser.getDistributionChannel();
                stock.SalesOrganization__c = currentUser.getSalesOranization();
                stock.ExternalKey__c = stock.SalesOrganization__c+'-'+stock.DistributionChannel__c+'-'+stock.Division__c+'-'+currentUser.getAgencyCustomerCode()+'-'+safe.material;
                stock.Note__c = safe.partsNote;
                System.debug(stock.ExternalKey__c + ' ::: stock.ExternalKey__c');
                stockList.add(stock);
            }
            if(stockList.size() > 0) { 
                upsert stockList ExternalKey__c;
                Map<String,String> stockMap = new Map<String,String>();
                for(DealerStock__c stock :stockList) {
                    stockMap.put(stock.Part__c, stock.Id);
                }
                for(DealerPartMasterByMPPS__c mpps : mppsList) {
                    mpps.DealerStock__c = stockMap.get(mpps.Part__c);
                }
            }
            if(mppsList.size() > 0) update mppsList;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message');
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            throw new DN_DemandRegSafetyStockandPoControllerException(e.getMessage());
        }
    }



    /**
    * @description 안전재고 대상 & ROP 등록 
    * @author iltae.seo | 2025-02-21 
    **/
    public static Map<String,String> getTotalQuery(set<String> partIds) {
        Map<String,String> returnMap = new Map<String,String>();
        String monthlyDemandSummaryByDealerQ = ' select Part__c,MAX(StartPart__c) StartPart__c,';
        monthlyDemandSummaryByDealerQ +=' MAX(StartPart__r.ProductCode) StartPart,';
        monthlyDemandSummaryByDealerQ +=' MAX(LastPart__r.ProductCode) LastPart,';
        monthlyDemandSummaryByDealerQ +=' SUM(FM_TotalQuantity__c) FM_TotalQuantity__c,';
        monthlyDemandSummaryByDealerQ +=' SUM(FM_TotalFrequency__c) FM_TotalFrequency__c from MonthlyDemandSummaryByDealer__c ';
        monthlyDemandSummaryByDealerQ +=' where Dealer__c=\''+currentUser.getAgencyId()+'\' ';
        monthlyDemandSummaryByDealerQ +=' AND Part__c IN(\''+String.join(partIds, '\',\'')+'\') ';
        monthlyDemandSummaryByDealerQ += ' AND Part__c !=null ';
        // 현재 날짜 기준으로 연도와 월 계산
        Date today = System.today();
        
        Date date6M = today.addMonths(-6);  
        Date date12M = today.addMonths(-12);
        Date date18M = today.addMonths(-18);
        // "YYYYMM" 포맷으로 변환 (텍스트 필드 비교용)
        String todayStr     = today.year() + String.valueOf(today.month()).leftPad(2, '0');
        String period6M = date6M.year() + String.valueOf(date6M.month()).leftPad(2, '0');
        String period12M = date12M.year() + String.valueOf(date12M.month()).leftPad(2, '0');
        String period18M = date18M.year() + String.valueOf(date18M.month()).leftPad(2, '0');
        
        String where6M = ' AND AnalysisPeriodMonth__c >=\''+period6M+'\' AND AnalysisPeriodMonth__c <\''+todayStr+'\'';
        String where12M = ' AND AnalysisPeriodMonth__c >=\''+period12M+'\' AND AnalysisPeriodMonth__c <\''+todayStr+'\'';
        String where18M = ' AND AnalysisPeriodMonth__c >=\''+period18M+'\' AND AnalysisPeriodMonth__c <\''+todayStr+'\'';
        String groupBy =' group by Part__c';
        // M6 M12 M18 Query
        returnMap.put('6mQuery', monthlyDemandSummaryByDealerQ + where6M + groupBy);
        returnMap.put('12mQuery', monthlyDemandSummaryByDealerQ + where12M + groupBy);
        returnMap.put('18mQuery', monthlyDemandSummaryByDealerQ + where18M + groupBy);    
        
        // 월별
        String strQuery = ' select Part__c,AnalysisPeriodMonth__c, SUM(FM_TotalQuantity__c) FM_TotalQuantity__c,';
            strQuery += ' MAX(CustomerPrice__c)CustomerPrice ';
            strQuery += ' FROM MonthlyDemandSummaryByDealer__c ';
            strQuery += ' where Dealer__c=\''+currentUser.getAgencyId()+'\' ';
            strQuery += ' AND Part__c IN(\''+String.join(partIds, '\',\'')+'\') ';        
            strQuery += ' group by Part__c,AnalysisPeriodMonth__c ';
        System.debug(strQuery + ' ::: strQuery');
        returnMap.put ('MonQuery',strQuery);

        return returnMap;
    }

    /**
    * @description 페이지 설정 - 안전재고 대상 & ROP 등록 / PO List View
    * @author iltae.seo | 2025-02-21 
    **/
    public static Map<String,Integer> setpageSetting(PageReturns returnPages, Integer nextPage) {
        Map<String,Integer> returnMap = new Map<String,Integer>();
        Integer startIdx = ((nextPage - 1) * returnPages.itemsPerPage) + 1;
        Integer endIdx   = (nextPage * returnPages.itemsPerPage);
        returnMap.put('startIdx', startIdx);
        returnMap.put('endIdx', endIdx);
        return returnMap;
    }
    // public static Map<string,Integer> setpageSetting(PageReturns returnPages, Integer nextPage) {
    //     Map<String,Integer> returnMap = new Map<String,Integer>();
        
    //     // Stage Idx, Last Idx - 인덱스 설정
    //     Integer startIdx = 0;
    //     Integer endIdx = 0;
    //     //페이지 클릭한 경우 처리로직 - 같은 경우 뒤로가기 또는 현재 페이지 클릭
    //     if(returnPages.currentPage == nextPage) {
    //         startIdx = (returnPages.currentPage * returnPages.itemsPerPage);
    //         startIdx = (startIdx - returnPages.itemsPerPage) + 1;
    //         endIdx = (nextPage*returnPages.itemsPerPage);    
    //     } else {
    //         startIdx = (nextPage*returnPages.itemsPerPage -returnPages.itemsPerPage) +1;//(returnPages.currentPage * returnPages.itemsPerPage)+1;
    //         endIdx = (nextPage*returnPages.itemsPerPage);       
    //     }
    //     Integer limitSet = startIdx + endIdx + returnPages.itemsPerPage;
    //     returnMap.put('limit',limitSet);
    //     returnMap.put('startIdx',startIdx);
    //     returnMap.put('endIdx',endIdx);
    //     return returnMap;
    // }


    // 인터페이스 데이터 매핑
    public static Map<String,Decimal> getIFDataSetting(set<String> partIds) {
        //데이터가 있을 경우 인터페이스 호출
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res res = DN_DealerStockManager.dealerStock011(partIds);
        Map<String,Decimal> returnMap = new Map<String,Decimal>();
        // 고객 판매가 매핑 - 현재 화면 ERP와 CRM의 부품데이터가 일치해야하는 전제조건이 따름
        for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST detail : res.ET_LIST) {
            System.debug(detail + ' :: :detail');
            returnMap.put(detail.MATNR.trim(), Decimal.valueOf(detail.NETPR));
        }
        System.debug(returnMap + ' ::: returnMap');
        return returnMap;
    }


    /**
    * @description 월별 설정
    * @author iltae.seo | 2025-02-05 
    **/
    @AuraEnabled
    public static List<String> getMonth(){
        try {
            List<String> returnList = new List<String>();
            DateTime currentDate = DateTime.now();
            currentDate = currentDate.addDays(-1);
            for (Integer j = 18; j >= 0; j--) {
                String yyymm =DN_DealerStockManager.getPastMonths(currentDate, -j);
                String mm = yyymm.subString(yyymm.length() -2);
                returnList.add(mm);
            }
            return returnList;
        } catch (Exception e) {
            throw new DN_DemandRegSafetyStockandPoControllerException(e.getMessage());
        }
    }


    /**
     * 안전재고 대상 & ROP 등록 / PO List View
     * @author iltae.seo | 2025-02-22 
     */
    // 데이터 리턴 페이징 처리까지
    public class PageReturns {
        @AuraEnabled public Map<String,Object> strQuery { get; set; } // 전체 데이터 쿼리
        @AuraEnabled public Integer totalRecordSize { get; set; } // 전체 레코드 사이즈
        @AuraEnabled public List<SafetyStock> recordList { get; set; } // 현재 페이지 데이터
        @AuraEnabled public List<SafetyStock> allData { get; set; } // 전체데이터
        @AuraEnabled public Integer itemsPerPage { get; set; } // 한 페이지당 표시할 데이터 수
        @AuraEnabled public Integer currentPage { get; set; } // 현재 페이지
        @AuraEnabled public Integer pagesPerGroup {get;set;} // 현재 화면에 표시할 페이지 갯수
        @AuraEnabled public Integer startIdx {get;set;} // 시작인덱스
        @AuraEnabled public Integer endIdx {get;set;} // 마지막인덱스
        @AuraEnabled public String orderByField {get;set;} // 정렬 필드,
        @AuraEnabled public String orderBy {get;set;} // 정렬 필드,
        public PageReturns() {} 
    }


    public class SafetyStock{
        @AuraEnabled public String id {get;set;} 
        @AuraEnabled public String materialId {get;set;} 
        @AuraEnabled public String material {get;set;} 
        @AuraEnabled public String materialDesc {get;set;} 
        @AuraEnabled public List<Monthly> monthlyList {get;set;} 
        @AuraEnabled public String unit {get;set;} 
        @AuraEnabled public Decimal cROP {get;set;} 
        @AuraEnabled public Decimal nROP {get;set;} 
        @AuraEnabled public Decimal cMaxLv {get;set;} 
        @AuraEnabled public Decimal nMaxLv {get;set;} 
        @AuraEnabled public String mrpType	{get;set;} 
        @AuraEnabled public Boolean fix {get;set;} 
        @AuraEnabled public Decimal cRVal {get;set;} 
        @AuraEnabled public Decimal nRVal {get;set;} 
        @AuraEnabled public Decimal cMinLot {get;set;} 
        @AuraEnabled public Decimal nMinLot {get;set;} 
        @AuraEnabled public Decimal m6 {get;set;} 
        @AuraEnabled public Decimal m12 {get;set;} 
        @AuraEnabled public Decimal m18 {get;set;} 
        @AuraEnabled public Decimal price {get;set;} 
        @AuraEnabled public String abc {get;set;} 
        @AuraEnabled public Decimal pdt {get;set;} 
        @AuraEnabled public Decimal weight {get;set;} 
        @AuraEnabled public Decimal wAMD {get;set;} 
        @AuraEnabled public Decimal sTDEV {get;set;} 
        @AuraEnabled public String partsNote {get;set;} 
        @AuraEnabled public Decimal sumdWeight {get; set;}
        @AuraEnabled public Decimal sumWeight = 171; 

        public SafetyStock() {}
        public SafetyStock(DealerPartMasterByMPPS__c mpps) {
            this.id                     = mpps.Id;
            this.materialId             = mpps.Part__c;
            this.material               = mpps.Part__r.ProductCode;
            this.materialDesc           = mpps.Part__r.FM_MaterialDetails__c;                                
            this.unit                   = mpps.Part__r.Unit__c;                        
            this.cROP                   = mpps.ReorderPoint__c;                        
            this.nROP                   = mpps.ReorderPoint__c;                        
            this.cMaxLv                 = mpps.MaximumStock__c;                        
            this.nMaxLv                 = mpps.MaximumStock__c;                        
            this.mrpType                = mpps.MRPType__c;                            
            this.fix                    = mpps.IsFixedROP__c;                        
            this.cRVal                  = mpps.RoundingValue__c;                        
            this.nRVal                  = mpps.RoundingValue__c;                        
            this.cMinLot                = mpps.MinimumLotSize__c;                            
            this.nMinLot                = mpps.MinimumLotSize__c;                            
            this.abc                    = mpps.ABCIndicator__c;                        
            this.weight                 = mpps.Weight__c;                        
            this.wAMD                   = mpps.WAMD__c;                        
            this.sTDEV                  = mpps.STDEV__c; 
            this.price                  = 0;         
            this.pdt                    = 0; 
            this.sumdWeight             = 0;             
        }
    }

    public class Monthly {
        @AuraEnabled public String monthKey {get;set;} // Monthly 키값,
        @AuraEnabled public Decimal quantity {get;set;} // Quantity 수량,
        @AuraEnabled public String yyyymm {get;set;} //  yyyymm 년월,
        
        public Monthly() {}
        public Monthly(String monKey, Decimal quantity, String yyyymm) {
            this.monthKey           = monKey;
            this.quantity           = quantity;
            this.yyyymm             = yyyymm;            
        }

    }

    public class DN_DemandRegSafetyStockandPoControllerException extends Exception {}    
}