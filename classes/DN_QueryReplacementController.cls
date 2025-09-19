/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 22. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-22 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_QueryReplacementController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @Description
     * 	- 대체품 해제 이력 조회
    **/
    @AuraEnabled
    public static List<ReplacementHistory> getReplacementList(Map<String,Object> search){
        try {
            set<String> partIds = new set<String>();
           
            // 인터페이스 데이터 세팅
            List<ReplacementHistory> replacementHistoryList = new List<ReplacementHistory>();
            System.debug(search + ' ::: search');
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res ifRes = ifDEALERSTOCK001(search);
            for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res_ET_HIST etHist : ifRes.ET_HIST) {
                ReplacementHistory replace = new ReplacementHistory(etHist);
                replacementHistoryList.add(replace);
                partIds.add(replace.material.trim());
            }
            
            //년도 설정
            Map<String,String> queryMap = getMonQuery(partIds);
            Map<String,Decimal> monthMap = new Map<String,Decimal>();
            Map<String,AggregateResult> monthByMap = new Map<String,AggregateResult>();
            List<AggregateResult> m6List = Database.query(queryMap.get('6MQuery'));
            for(AggregateResult ages : m6List) {
                monthMap.put( 'm6'+(String)ages.get('ProductCode'), (Decimal)ages.get('FM_TotalQuantity__c') );
            }

            // M12
            List<AggregateResult> m12List = Database.query(queryMap.get('12MQuery'));
            for(AggregateResult ages : m12List) {
                monthMap.put( 'm12'+(String)ages.get('ProductCode'), (Decimal)ages.get('FM_TotalQuantity__c') );
            }

            // M18
            List<AggregateResult> m18List = Database.query(queryMap.get('18MQuery'));
            for(AggregateResult ages : m18List) {
                monthMap.put( 'm18'+(String)ages.get('ProductCode'), (Decimal)ages.get('FM_TotalQuantity__c') );
            }

            // 월별데이터 부품 + 월별로 키값 설정
            List<AggregateResult> dataList = Database.query(queryMap.get('dataList')); //
            System.debug(queryMap.get('dataList') + ' QUERY DATA LIST');
            for(AggregateResult month : dataList) {
                String productCode =(String) month.get('ProductCode'); 
                String yyyymm = (String) month.get('AnalysisPeriodMonth__c');
                monthByMap.put( productCode + yyyymm,  month);
            }

            // ABC, ROP, Max Lv. : ABCIndicator__c, ReorderPoint__c,MaximumStock__c
            Map<String,DealerPartMasterByMPPS__c> mppsMap = new Map<String,DealerPartMasterByMPPS__c>();
            System.debug(queryMap.get('dealerPartMaster') + ' :::: dealerPartMaster');
            List<DealerPartMasterByMPPS__c> dealerPartBy = Database.query(queryMap.get('dealerPartMaster'));
            for(DealerPartMasterByMPPS__c mpps : dealerPartBy) {
                mppsMap.put(mpps.Part__r.ProductCode, mpps);
            }
            System.debug(mppsMap + ' :: mppsMap');
             
            for(ReplacementHistory repHistory : replacementHistoryList) {
                // 각 년도별 Qty 할당
                DateTime currentDate = DateTime.now();
                for (Integer j = 18; j >= 1; j--) {
                    String yyyymm =DN_DealerStockManager.getPastMonths(currentDate, -j);
                    String mKey = 'M-' + String.valueOf(j);
                    Decimal qty = 0;
                    if(monthByMap.get(repHistory.material + yyyymm) !=null) {
                        qty = (Decimal) monthByMap.get(repHistory.material + yyyymm).get('FM_TotalQuantity__c');
                    }
                    Monthly monthBy  = new Monthly(mKey,qty,yyyymm);
                    repHistory.monthlyList.add(monthBy);
                }
                // 나머지 필요부품 할당
                if(mppsMap.get(repHistory.material) !=null) {
                    repHistory.abc       = mppsMap.get(repHistory.material).ABCIndicator__c;                           
                    repHistory.rop       = mppsMap.get(repHistory.material).ReorderPoint__c;                                                      
                    repHistory.maxLv     = mppsMap.get(repHistory.material).MaximumStock__c;                                                                                      
                } else {
                    repHistory.abc       ='';
                    repHistory.rop       = 0;
                    repHistory.maxLv     = 0;
                }
                
                repHistory.m6        = new Monthly('m6',monthMap.get('m6'+repHistory.material));
                repHistory.m12       = new Monthly('m12',monthMap.get('m6'+repHistory.material));
                repHistory.m18       = new Monthly('m18',monthMap.get('m6'+repHistory.material));
            }

            return replacementHistoryList;
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + ' getStackTraceString');
            System.debug(e.getMessage() + ' getMessage');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 년도별 데이터 조회
    **/
    public static Map<String,String> getMonQuery(set<String> partIds) {
        Map<String,String> returnMap = new Map<String,String>();
        // ABC, ROP, Max Lv. : ABCIndicator__c, ReorderPoint__c,MaximumStock__c
        //DealerPartMasterByMPPS__c
        String dealerPartMasterByQ = ' select Id,Dealer__c, Part__r.ProductCode, ABCIndicator__c, ReorderPoint__c,MaximumStock__c,PartCode__c,FM_PartCode__c from DealerPartMasterByMPPS__c ';
        dealerPartMasterByQ +=  ' where Dealer__c=\''+currentUser.getAgencyId()+'\' ';
        dealerPartMasterByQ += ' AND Part__r.ProductCode IN(\''+String.join(partIds, '\',\'')+'\') ';
        

        // 부품별 월별 합산값
        String monthlyDemandSummaryByDealerQ = 'SELECT Part__r.ProductCode ProductCode,AnalysisPeriodMonth__c, ';
        monthlyDemandSummaryByDealerQ += ' SUM(FM_TotalQuantity__c) FM_TotalQuantity__c, ';
        monthlyDemandSummaryByDealerQ += ' SUM(FM_TotalFrequency__c) FM_TotalFrequency__c ';
        monthlyDemandSummaryByDealerQ += ' FROM MonthlyDemandSummaryByDealer__c ';
        monthlyDemandSummaryByDealerQ +=  ' where Dealer__c=\''+currentUser.getAgencyId()+'\' ';
        monthlyDemandSummaryByDealerQ += ' AND Part__r.ProductCode IN(\''+String.join(partIds, '\',\'')+'\') ';
        
        // 부품별 6M, 12M, 18M
        String monthlyDemandSummaryByMonQ = 'SELECT Part__r.ProductCode ProductCode, ';
        monthlyDemandSummaryByMonQ += ' SUM(FM_TotalQuantity__c) FM_TotalQuantity__c, ';
        monthlyDemandSummaryByMonQ += ' SUM(FM_TotalFrequency__c) FM_TotalFrequency__c ';
        monthlyDemandSummaryByMonQ += ' FROM MonthlyDemandSummaryByDealer__c ';
        monthlyDemandSummaryByMonQ += ' where Dealer__c=\''+currentUser.getAgencyId()+'\' ';
        monthlyDemandSummaryByMonQ += ' AND Part__r.ProductCode IN(\''+String.join(partIds, '\',\'')+'\') ';
        
        // 현재 날짜 기준으로 연도와 월 계산
        Date today = System.today();
        
        Date date6M = today.addMonths(-6);  // 12개월 전
        Date date12M = today.addMonths(-12);  // 18개월 전
        Date date18M = today.addMonths(-18);  // 24개월 전
        // "YYYYMM" 포맷으로 변환 (텍스트 필드 비교용)
        String todayStr     = today.year() + String.valueOf(today.month()).leftPad(2, '0');
        String period6M = date6M.year() + String.valueOf(date6M.month()).leftPad(2, '0');
        String period12M = date12M.year() + String.valueOf(date12M.month()).leftPad(2, '0');
        String period18M = date18M.year() + String.valueOf(date18M.month()).leftPad(2, '0');

        String where6M = ' AND AnalysisPeriodMonth__c >=\''+period6M+'\' AND AnalysisPeriodMonth__c <\''+todayStr+'\'';
        String where12M = ' AND AnalysisPeriodMonth__c >=\''+period12M+'\' AND AnalysisPeriodMonth__c <\''+todayStr+'\'';
        String where18M = ' AND AnalysisPeriodMonth__c >=\''+period18M+'\' AND AnalysisPeriodMonth__c <\''+todayStr+'\'';
        
        returnMap.put('dataList', monthlyDemandSummaryByDealerQ + where18M+' GROUP BY Part__r.ProductCode,AnalysisPeriodMonth__c ');
        returnMap.put('6MQuery', monthlyDemandSummaryByMonQ + where6M+' GROUP BY Part__r.ProductCode ');
        returnMap.put('12MQuery', monthlyDemandSummaryByMonQ + where12M+' GROUP BY Part__r.ProductCode ');
        returnMap.put('18MQuery', monthlyDemandSummaryByMonQ + where18M+' GROUP BY Part__r.ProductCode ');
        returnMap.put('dealerPartMaster', dealerPartMasterByQ);
        return returnMap;
    }
    
    /**
     * @Description
     * 	- "YYYY.MM.DD" 형식으로 반환
    **/
    public static String formatDate(String rawDate) {
        
        // 연도, 월, 일을 추출
        String year = rawDate.substring(0, 4);
        String month = rawDate.substring(4, 6);
        String day = rawDate.substring(6, 8);

        // "YYYY.MM.DD" 형식으로 반환
        return year + '.' + month + '.' + day;
    }


    /**
     * @Description
     * 	- ifDEALERSTOCK001 - 대체품 해제 이력 조회
    **/
    public static IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res ifDEALERSTOCK001(Map<String,Object> search) {
        IF_ERP_DealerStock method = new IF_ERP_DealerStock();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req_I_USERINFO req_I_userInfo =
        new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req_I_USERINFO();
       
        req_I_userInfo.KUNNR  = '000' + currentUser.getAgencyCustomerCode();
        req_I_userInfo.VKORG  = currentUser.getSalesOranization();
        req_I_userInfo.VTWEG  = currentUser.getDistributionChannel();
        req_I_userInfo.SPART  = currentUser.getDivision();
        req_I_userInfo.LAND1  = currentUser.getLanguageLocaleKey().subString(0,2);
        req_I_userInfo.DF_CHK = 'X';
     
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req req =
        new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req();
        req.I_DATE_FROM = String.valueOf(search.get('historyDateStart')).replace('-','');
        req.I_DATE_TO   = String.valueOf(search.get('historyDateEnd')).replace('-','');
        if(search.get('productCode') !=null) {
            req.IT_MATNR = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req_IT_MATNR>();
            set<String> prodIds = new set<String>( String.valueOf(search.get('productCode')).split(','));
            List<Product2> prodList = [SELECT Id,Name, ProductCode FROM Product2 WHERE Id IN:prodIds];
            for(Product2 prod : prodList) {
                IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req_IT_MATNR itMATNR = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Req_IT_MATNR();
                itMATNR.MATNR =prod.ProductCode; 
                req.IT_MATNR.add(itMATNR);
            }
        }
        
        req.I_USERINFO  = req_I_userInfo;
    
    
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res res = method.IF_DEALERSTOCK_001(req);
        return res;
    }
    
    /**
     * @Description
     * 	- 데이터 매핑하기 위한 클래스
    **/
    public class ReplacementHistory {
        @AuraEnabled public String material {get;set;}
        @AuraEnabled public String materialDesc {get;set;}
        @AuraEnabled public String lastParts {get;set;}
        @AuraEnabled public String unit {get;set;}
        @AuraEnabled public Decimal amount {get;set;}
        @AuraEnabled public String currencyCode {get;set;}
        @AuraEnabled public String abc {get;set;}
        @AuraEnabled public Decimal rop {get;set;}
        @AuraEnabled public Decimal maxLv {get;set;}
        @AuraEnabled public String changeDate {get;set;}
        @AuraEnabled public String orderBlock {get;set;}
        @AuraEnabled public String salesBlock {get;set;}
        @AuraEnabled public List<Monthly> monthlyList {get;set;}
        @AuraEnabled public Monthly m6 {get;set;}
        @AuraEnabled public Monthly m12 {get;set;}
        @AuraEnabled public Monthly m18 {get;set;}
        public ReplacementHistory() {}
        public ReplacementHistory(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_001_Res_ET_HIST ifData) {
            this.material                           = ifData.MATNR;
            this.materialDesc                       = ifData.MAKTX;
            this.lastParts                          = ifData.LSTNR;
            this.unit                               = ifData.MEINS;
            this.currencyCode                       = ifData.WAERS; 
            this.changeDate                         = formatDate(ifData.CHGDT); 
            this.orderBlock                         = ifData.SVRCD; 
            this.salesBlock                         = ifData.MMSTA; 
            this.amount                             = Decimal.valueOf(ifData.VERPR);
            this.currencyCode                       = ifData.WAERS;
            this.monthlyList                        = new List<Monthly>();
            
        }
    }
    
    /**
     * @Description
     * 	- 각 년월별 수량 클래스
    **/
    public class Monthly {
        @AuraEnabled public String monKey {get;set;}
        @AuraEnabled public Decimal qty {get;set;}
        @AuraEnabled public String yyyymm {get;set;}
        public Monthly() {
            this.qty = 0;
        }
        
        public Monthly(String monKey, Decimal quantity) {
            this.monKey             = monKey;
            this.qty                = quantity ==null ? 0 : quantity;
            
        }

        public Monthly(String monKey, Decimal quantity, String yyyymm) {
            this.monKey             = monKey;
            this.qty                = quantity;
            this.yyyymm             = yyyymm;
        }
    }
}