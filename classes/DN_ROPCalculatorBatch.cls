/** 
 * @Class :  DN_ROPCalculatorBatch
 * 
 * @Test: DN_ROPCalculatorBatch_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 02. 07. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-07 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_ROPCalculatorBatch implements Database.Batchable<SObject>, Database.Stateful {
    public enum SummaryType {
        DEALER, REGION
    }
    
    final private Decimal DEMAND_FORECAST_RANGE = 18; //
    
    private DN_AsyncApexErrorLogger logger {
        get {
            if(logger == null) logger = new DN_AsyncApexErrorLogger();
            return logger;
        }
        set;
    }
    private SummaryType type {get; set;}
    private String recordTypeDeveloperName {get; set;}
    private Map<String, Factor> factorMap {
        get {
            if(factorMap == null) factorMap = new Map<String, Factor>();
            return factorMap;
        }
        set;
    }
    private Double period {get; set;}
    private String plant {   
        get {
            if(plant == null) plant = '1846';
            return plant;
        }
        set;
    }
    private String targetId {get; set;}
    private Set<String> externalKeys {
        get {
            if(externalKeys == null) externalKeys = new Set<String>();
            return externalKeys;
        }
        set;
    }

    private Set<String> remainIds {
        get {
            if(remainIds == null) {
                remainIds = new Set<String>();
            }
            return remainIds;
        }
        set;
    }

    /*
    * @ 생성자 : DN_ROPCalculatorBatch
    * @ Description : type 설정
    */
    public DN_ROPCalculatorBatch(SummaryType type) {
        this.type = type;
    }
    /*
    * @ 생성자 : DN_ROPCalculatorBatch
    * @ Description : type,externalKeys 설정
    */
    public DN_ROPCalculatorBatch(SummaryType type ,Set<String> externalKeys) {
        this(type);
        this.externalKeys = externalKeys;
    }
    /*
    * @ 생성자 : DN_ROPCalculatorBatch
    * @ Description : type,plant,externalKeys 설정
    */
    public DN_ROPCalculatorBatch(SummaryType type, String plant, Set<String> externalKeys) {
        this.type = type;
        this.plant = plant;
        this.externalKeys = externalKeys;
    }
    /*
    * @ 생성자 : setTargetId
    * @ Description : targetId 설정
    */
    public DN_ROPCalculatorBatch setTargetId(String targetId) {
        this.targetId = targetId;
        return this;
    }
    /*
    * @ 생성자 : setRemainIds
    * @ Description : remainIds 설정
    */
    public DN_ROPCalculatorBatch setRemainIds(Set<String> remainIds) {
        this.remainIds = remainIds;
        return this;
    }
    
    /*
    * @ Method : start
    * @ Description : 배치 시작
    */
    public Database.QueryLocator start(Database.BatchableContext context){
        System.debug(' =============== DN_ROPCalculatorBatch Batch start ================');
        return Database.getQueryLocator(getQuery());
    }

    /*
    * @ Method : getObjectInfo
    * @ Description : objectType,addtionalFields,orderBy,keyField 반환
    */
    private Map<String,String> getObjectInfo() {
        Map<String,String> objectInfoMap = new Map<String,String>();
        String objectType;
        String addtionalFields;
        String orderBy = ' ORDER BY ';
        String keyField;

        switch on this.type{
            when DEALER {
                recordTypeDeveloperName = 'Dealer';
                objectType = 'DealerPartMasterByMPPS__c'; //'MonthlyDemandSummaryByDealer__c';
                addtionalFields = ', Dealer__r.CustomerCode__c, Part__r.ProductCode ';
                orderBy += ' FM_PartCode__c, FM_DealerCode__c  ';
                keyField = 'Dealer__c';
            }
            when REGION {
                recordTypeDeveloperName = 'Region';
                objectType = 'AreaPartMasterByMPPS__c'; //'MonthlyDemandSummaryByRegion__c';
                addtionalFields = ', Area__r.Area__c, Part__r.ProductCode ';
                orderBy += ' FM_PartCode__c, FM_AreaCode__c ';
                keyField = 'Area__c';
            }
            when else {
                throw new CustomException('Type is Null');
            }   
        }

        objectInfoMap.put('objectType', objectType);
        objectInfoMap.put('addtionalFields', addtionalFields);
        objectInfoMap.put('orderBy', orderBy);
        objectInfoMap.put('keyField', keyField);
        
        return objectInfoMap;
    }

    /*
    * @ Method : setFactors
    * @ Description : period 설정
    */
    private void setFactors() {

        String ropQuery = ' SELECT '
                        + '             Id,  Name,  '
                        + '             RecordType.DeveloperName,   '
                        + '             Dealer__r.CustomerCode__c, '
                        + '             FM_DealerCode__c, '
                        + '             Area__r.Area__c,  '
                        + '             FM_AreaCode__c, '
                        + '             Plant__c,  '
                        + '             ABCIndicator__c,  '
                        + '             TargetServiceLevel__c,  '
                        + '             SVCFactor__c,  '
                        + '             AddSFTFlag__c, '
                        + '             ApplyMaxFlag__c, '
                        + '             PriceFrom__c,  '
                        + '             PriceTo__c,  '
                        + '             Weight__c,  '
                        + '             AMDType__c,  '
                        + '             DemandPeriod__c '
                        + ' FROM ROPAndStockFactorConfig__c  '
                        + ' WHERE Id != null ';
        
        if(String.isNotBlank(recordTypeDeveloperName)) ropQuery += ' AND '+ getKeyFieldByRecordType()+' != null';

        Set<Decimal> periodSet = new Set<Decimal>();
        for(ROPAndStockFactorConfig__c ropAndStockFactor : Database.query(ropQuery)) {
            String ropRecordTypeDeveloperName = ropAndStockFactor.RecordType.DeveloperName;
            Factor factor;
            switch on ropRecordTypeDeveloperName {
                when 'AreaROPCalculationFactorConfiguration' {
                    // 'AreaROPCalculationFactorConfiguration' // 등급별 ROP 가중치  
                    factor = new RopFactor(ropAndStockFactor);
                }
                when 'AreaMaxStockWeightingFactor' {
                    // 'AreaMaxStockWeightingFactor' // 등급별 가격 가중치        
                    factor = new StockFactor(ropAndStockFactor);
                    String key = factor.getTypeKey();
                    if(factorMap.containsKey(key)) factor = factorMap.get(key);
                    ((StockFactor)factor).addPriceWeight(Double.valueOf(ropAndStockFactor.PriceFrom__c), Double.valueOf(ropAndStockFactor.PriceTo__c), Double.valueOf(ropAndStockFactor.Weight__c));

                }
            }
            factorMap.put(factor.getTypeKey(), factor);
            periodSet.add(factor.getDemandPeriod());
        }
        if(periodSet.size() > 1) throw new CustomException('The target period count is only one.');
        else if(periodSet.size() == 0) throw new CustomException('The target period count is empty.');
        period = (new List<Decimal>(periodSet)).get(0);
    }

    /*
    * @ Method : getKeyFieldByRecordType
    * @ Description : 레코드 타입별 키필드 반환
    */
    private String getKeyFieldByRecordType() {
        String keyField;
        switch on recordTypeDeveloperName {
            when 'Dealer' {
                keyField = 'FM_DealerCode__c';
            }
            when 'Region' {
                keyField = 'FM_AreaCode__c';
            }
        }
        return keyField;
    }

    /*
    * @ Method : getQuery
    * @ Description : 쿼리 반환
    */
    private String getQuery() {
        Map<String, String> objInfo = getObjectInfo();
        setFactors();   //수요 기간 및 해당 기간에 따른 Factor 설정
        String sObjectApi = objInfo.get('objectType');
        String addtionalFields = objInfo.get('addtionalFields');
        String queryOrderBy = objInfo.get('orderBy');
        String keyField = objInfo.get('keyField');

        SchemaInfo objSchema = new SchemaInfo(sObjectApi);
        String queryFields = objSchema.getAllFieldsForQuery();
        if(String.isNotBlank(addtionalFields)) queryFields += addtionalFields;
        String query = ' SELECT '
                     + queryFields
                     + ' FROM ' +sObjectApi
                     + ' WHERE Id != null ';
        if(String.isNotBlank(targetId)) {
            query += 'AND ' +keyField+ '= \''+targetId+'\'';
        }
        else if(externalKeys.size() > 0) {
            query += ' AND ExternalKey__c IN :externalKeys ';
        }
        query += queryOrderBy;
        return query;
    }

    /*
    * @ Method : getYearMonthFrom
    * @ Description : yyyyMM 형태로 변환
    */
    @TestVisible
    private static String getYearMonthFrom(DateTime targetTime) {
        return targetTime.format('yyyyMM');
    }

    /*
    * @ Method : execute
    * @ Description : 배치 실행
    */
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.debug(' =============== DN_ROPCalculatorBatch Batch Execute ================');

        DateTime today = System.now();
        Integer finalTargetPeriod = Integer.valueOf(period); //Integer.valueOf(DEMAND_FORECAST_RANGE) + Integer.valueOf(period);
        DateTime beforeMonth = today.addMonths(Integer.valueOf(-1 * (finalTargetPeriod)));

        DateTime before24Month = today.addMonths(-24);
        DateTime before36Month = today.addMonths(-36);

        String targetWhere = ' AND AnalysisPeriodMonth__c >= \''+getYearMonthFrom(beforeMonth)+'\''
                           + ' AND AnalysisPeriodMonth__c < \''+getYearMonthFrom(today)+'\'';

        String target24Where = ' AND AnalysisPeriodMonth__c >= \''+getYearMonthFrom(before24Month)+'\''
        + ' AND AnalysisPeriodMonth__c < \''+getYearMonthFrom(today)+'\'';

        String target36Where = ' AND AnalysisPeriodMonth__c >= \''+getYearMonthFrom(before36Month)+'\''
        + ' AND AnalysisPeriodMonth__c < \''+getYearMonthFrom(today)+'\'';

        Map<String, DN_ROPCalculatorBatch.ForcastDemandData> demandSummaryMap = new Map<String, DN_ROPCalculatorBatch.ForcastDemandData>();

        try {

            switch on type {
                when DEALER {
                    Set<String> dealerIds = new Set<String>();
                    Set<String> partIds = new Set<String>();
                    for(DealerPartMasterByMPPS__c dealerPart : (List<DealerPartMasterByMPPS__c>) scope) {
                        // dealerCodes.add(dealerPart.FM_DealerCode__c);
                        // partCodes.add(dealerPart.FM_PartCode__c);
                        if(dealerPart.Dealer__c != null)dealerIds.add(dealerPart.Dealer__c);
                        if(dealerPart.Part__c != null)partIds.add(dealerPart.Part__c);
                    }
                    if(dealerIds.size() > 0) {
                        targetWhere += ' AND Dealer__c IN :dealerIds';
                        target24Where += ' AND Dealer__c IN :dealerIds';
                        target36Where += ' AND Dealer__c IN :dealerIds';
                    }
                    if(partIds.size() > 0)  {
                        targetWhere += ' AND Part__c IN :partIds';
                        target24Where += ' AND Part__c IN :partIds';
                        target36Where += ' AND Part__c IN :partIds';
                    }

                    String summaryQuery = ' SELECT  '
                                        + ' Dealer__r.CustomerCode__c, Part__r.ProductCode, '
                                        + ' SUM(Quantity__c) totalQty, SUM(ReplacementQuantitiy__c) totalReQty, '
                                        + ' SUM(Frequency__c) totalFqy, SUM(ReplacementFrequency__c) totalReFqy, '
                                        + ' MAX(CustomerPrice__c) custeomrPrice FROM MonthlyDemandSummaryByDealer__c WHERE Id != null ';

                    String groupBy = ' GROUP BY Dealer__r.CustomerCode__c, Part__r.ProductCode ';

                    Map<String, Decimal> demand24SummaryMap = new Map<String, Decimal>();
                    for(AggregateResult demand24Summary : Database.query(summaryQuery + target24Where + groupBy)) {
                        String key = (String)demand24Summary.get('CustomerCode__c') +'_'+ (String)demand24Summary.get('ProductCode');
                        demand24SummaryMap.put(key, (Decimal)demand24Summary.get('totalQty') + (Decimal)demand24Summary.get('totalReQty'));
                    }

                    Map<String, Decimal> demand36SummaryMap = new Map<String, Decimal>();
                    for(AggregateResult demand36Summary : Database.query(summaryQuery + target36Where + groupBy)) {
                        String key = (String)demand36Summary.get('CustomerCode__c') +'_'+ (String)demand36Summary.get('ProductCode');
                        demand36SummaryMap.put(key, (Decimal)demand36Summary.get('totalQty') + (Decimal)demand36Summary.get('totalReQty'));
                    }
                    
                    for(MonthlyDemandSummaryByDealer__c demandSummary : Database.query(getDemandQuery('MonthlyDemandSummaryByDealer__c', targetWhere))) {
                        String key = demandSummary.FM_DealerCode__c + '_' + demandSummary.FM_PartCode__c;

                        DN_ROPCalculatorBatch.ForcastDemandData forcastData;
                        if(demandSummaryMap.containsKey(key)) {
                            forcastData = demandSummaryMap.get(key);
                            if(forcastData.price == null)
                                forcastData.price = demandSummary.CustomerPrice__c;
                        }else {
                            //forcastData = new DN_ROPCalculatorBatch.ForcastDemandData(24);
                            forcastData = new DN_ROPCalculatorBatch.ForcastDemandData(18);
                            forcastData.period = Integer.valueOf(period);
                            forcastData.key = key;
                            forcastData.price = demandSummary.CustomerPrice__c;
                        }

                        forcastData.changeDemandForValue(demandSummary.AnalysisPeriodMonth__c, Integer.valueOf(demandSummary.FM_TotalQuantity__c));
                        demandSummaryMap.put(key, forcastData);
                    }

                    if(demandSummaryMap.size() > 0)  {
                        for(String key : demandSummaryMap.keySet()) {
                            System.debug(' demandSummaryMap key: '+ key);
                            DN_ROPCalculatorBatch.ForcastDemandData forcastData = demandSummaryMap.get(key);
                            // forcastData.calculateMonthDemandUpTo(36); //표준편차 계산
                            forcastData.calculateMonthDemandUpTo(18); //표준편차 계산
                            if(demand24SummaryMap.containsKey(key)) {
                                forcastData.forecast24MonthsDemand = Double.valueOf(demand24SummaryMap.get(key));
                            }

                            if(demand36SummaryMap.containsKey(key)) {
                                forcastData.forecast36MonthsDemand = Double.valueOf(demand36SummaryMap.get(key));
                            }
                        }
                        // Map<String, Double> dealerLeadTimeMap = getDealerLeadTimeMap(plant, partCodes);
                        Map<String, Double> dealerLeadTimeMap = getDealerLeadTimeMap(plant, partIds);
                        // Map<String, ProductByPlant__c> productMap = getPlantByProductMap(plant, partCodes);
                        Map<String, ProductByPlant__c> productMap = getPlantByProductMap(plant, partIds);
                        for(DealerPartMasterByMPPS__c dealerPart : (List<DealerPartMasterByMPPS__c>) scope) {
                            String key = dealerPart.FM_DealerCode__c + '_' + dealerPart.FM_PartCode__c;
                            System.debug('key : '+ key);
                            if(!demandSummaryMap.containsKey(key)) continue;
                            
                            Double lt;
                            // System.debug(JSON.serializePretty(dealerLeadTimeMap));
                            //PDT
                            //1. DealerLeadTimeManagement__c(ZSPT2510-PLIFZ) 대리점 PDT 우선
                            //2. Material Master 의 PDT  (1 이 없을 경우, MARC-PLIFZ)
                            if(dealerLeadTimeMap.containsKey(dealerPart.FM_PartCode__c)) lt = dealerLeadTimeMap.get(dealerPart.FM_PartCode__c);
                            ProductByPlant__c productInfo = productMap.get(dealerPart.FM_PartCode__c);
                            if(lt == null) lt = productInfo?.PlannedDeliveryDay__c;
                            if(lt == null) lt = 0.0;

                            dealerPart.PlannedDeliveryDays__c = lt;
    
                            DN_ROPCalculatorBatch.ForcastDemandData forcastData = demandSummaryMap.get(key);
                            dealerPart.STDEV__c = forcastData.standardDeviation; //표준편차
                            if(dealerPart.STDEV__c != null) dealerPart.STDEV__c = ((Decimal)dealerPart.STDEV__c).setScale(3, RoundingMode.HALF_UP);
                            dealerPart.AMD__c = forcastData.amd;
                            if(dealerPart.AMD__c != null) dealerPart.AMD__c = ((Decimal)dealerPart.AMD__c).setScale(3, RoundingMode.HALF_UP);
                            dealerPart.WAMD__c = forcastData.wamd;
                            if(dealerPart.WAMD__c != null) dealerPart.WAMD__c = ((Decimal)dealerPart.WAMD__c).setScale(3, RoundingMode.HALF_UP);
                            dealerPart.M12__c = (forcastData.forecast12MonthsDemand != null) ? forcastData.forecast12MonthsDemand : 0;
                            dealerPart.M18__c = (forcastData.forecast18MonthsDemand != null) ? forcastData.forecast18MonthsDemand : 0;
                            dealerPart.M24__c = (forcastData.forecast24MonthsDemand != null) ? forcastData.forecast24MonthsDemand : 0;
                            dealerPart.M36__c = (forcastData.forecast36MonthsDemand != null) ? forcastData.forecast36MonthsDemand : 0;
                            setSpeicailGrade(dealerPart, productInfo);
                            setMRPType(dealerPart);
    
                            String factorKey = dealerPart.ABCIndicator__c+'_'+ dealerPart.FM_DealerCode__c;
                            
                            Double svcFactor = 0, targetServiceLevel = 0;
                            Double amd = 0;
                            Double price = 0, weight = 0;
                            RopFactor factor;
                            if(factorMap.containsKey(factorKey)) {
                                factor = (RopFactor)factorMap.get(factorKey);
                                svcFactor = factor.svcFactor;
                                targetServiceLevel = factor.targetServiceLevel;
                            }
                            

                            dealerPart.ServiceFactor__c = svcFactor;
                            Double safetyStock = calculateSafetyStock(svcFactor, forcastData.standardDeviation, Math.sqrt((lt/30)));
                            dealerPart.TargetServiceLevel__c = targetServiceLevel;

                            //AMDType__c
                            if('W.AMD'.equals(factor?.amdType) && dealerPart.WAMD__c != null) {
                                // System.debug('if: WAMD');
                                amd = Double.valueOf(dealerPart.WAMD__c);
                            } else if('AMD'.equals(factor?.amdType) && dealerPart.AMD__c != null) {
                                // System.debug('else if: AMD');
                                //AMD
                                amd = Double.valueOf(dealerPart.AMD__c);
                            }
                            System.debug('target amd : '+ amd);

                            factorKey += '_price';
                            StockFactor stockFactor;
                            if(factorMap.containsKey(factorKey)) {
                                stockFactor = (StockFactor)factorMap.get(factorKey);
                                weight = stockFactor.getPriceWeight(forcastData.price).weight;
                            }
                            dealerPart.weight__c = weight;
                            System.debug('lt ' + lt);
                            Double rop, maxStockLevel = 0;
                            //ZSPT2490-APPMAX 가 'X' 일 경우만 Max Stock Level 계산    
                            if('X'.equals(factor?.applyMaxFlag)) {
                                System.debug('Max Level Rounding Mode.');
                                    
                                if('X'.equals(factor?.addSFTFlag)) {
                                    //ROPAndStockFactorConfig__c-AddSFTFlag__c (ZSPT2490-ADDSFT) 가 'X' 일 경우 ROP  Safety Stock 사용
                                    rop = calculateROPMax(amd, lT, safetyStock);

                                }else {
                                    //ZSPT2490-ADDSFT 가 '' 일 경우 ROP = ROP 
                                    rop = calculateROPMax(amd, lT, 0);
                                }
                                rop = Math.ceil(rop);
                                
                                //Max. level Rounding Mode?
                                maxStockLevel = calculateMaxSafetyStock(rop, amd, Double.valueOf(dealerPart.weight__c));
                                
                            }else {
                                //ZSPT2490-APPMAX 가 '' 일 경우 ROP 만 계산
                                System.debug('Fixed Mode.');
                                //Fixed Mode
                                Double calculateLt = Double.valueOf((lT/30) + dealerPart.weight__c);
                                //AddSFTFlag__c 
                                if('X'.equals(factor?.addSFTFlag)) {
                                    //ZSPT2490-ADDSFT 가 'X' 일 경우 ROP = ROP + Safety Stock
                                    rop = calculateROPFixed(amd, calculateLt, safetyStock);

                                }else {
                                    //ZSPT2490-ADDSFT 가 '' 일 경우 ROP = ROP 
                                    rop = calculateROPFixed(amd, calculateLt, 0);
                                }
                                rop = Math.ceil(rop);
                            }
                            System.debug(' 계산 완료 ReorderPoint__c : '+ rop);
                            System.debug(' 계산 완료 SafetyStock__c : '+ Math.ceil(rop / 3));
                            System.debug(' 계산 완료 MaximumStock__c : '+ Math.ceil(maxStockLevel));

                            //계산된 ROP, Max Stock Level 은 소수점 자리에서 올림 처리
                            //계산된 값 업데이트 (FIX 적용된 품번은 SafetyStock__c(EISBE), ReorderPoint__c(NINBE), MaximumStock__c(MABST) 업데이트 대상에서 제외)
                            if(!dealerPart.IsFixedROP__c) {
                                dealerPart.ReorderPoint__c = rop;//Math.ceil(rop);
                                // if(dealerPart.ReorderPoint__c != null) dealerPart.ReorderPoint__c = ((Decimal)dealerPart.ReorderPoint__c).setScale(3, RoundingMode.HALF_UP);
                                dealerPart.SafetyStock__c =  Math.ceil(dealerPart.ReorderPoint__c / 3);// safetyStock;
                                dealerPart.MaximumStock__c = Math.ceil(maxStockLevel);
                            }

                            if(String.isNotBlank(dealerPart.ABCIndicator__c) && 'N,R,S'.contains(dealerPart.ABCIndicator__c)) {
                                // N, R, S 등급인 경우 0 으로 초기화
                                dealerPart.ReorderPoint__c = 0;
                                dealerPart.SafetyStock__c = 0;
                                dealerPart.MaximumStock__c = 0;
                            }

                        }
                    }

                }
                when REGION {
                    // Set<String> areaCodes = new Set<String>();
                    // Set<String> partCodes = new Set<String>();
                    Set<String> areaIds = new Set<String>();
                    Set<String> partIds = new Set<String>();
                    for(AreaPartMasterByMPPS__c areaPart : (List<AreaPartMasterByMPPS__c>) scope) {
                        // areaCodes.add(areaPart.FM_AreaCode__c);
                        // partCodes.add(areaPart.FM_PartCode__c);
                        if(areaPart.Area__c != null) areaIds.add(areaPart.Area__c);
                        if(areaPart.Part__c != null) partIds.add(areaPart.Part__c);
                    }

                    if(areaIds.size() > 0) {
                        // targetWhere += ' AND FM_AreaCode__c IN :areaCodes';
                        targetWhere += ' AND Area__c IN :areaIds';
                        target24Where += ' AND Area__c IN :areaIds';
                        target36Where += ' AND Area__c IN :areaIds';
                    }
                    if(partIds.size() > 0) {
                        // targetWhere += ' AND FM_PartCode__c IN :partCodes';
                        targetWhere += ' AND Part__c IN :partIds';
                        target24Where += ' AND Part__c IN :partIds';
                        target36Where += ' AND Part__c IN :partIds';
                    }

                    
                    String summaryQuery = ' SELECT  '
                                        + ' Area__r.Area__c, Part__r.ProductCode, '
                                        + ' SUM(Quantity__c) totalQty, SUM(ReplacementQuantitiy__c) totalReQty, '
                                        + ' SUM(Frequency__c) totalFqy, SUM(ReplacementFrequency__c) totalReFqy, '
                                        + ' MAX(CustomerPrice__c) customerPrice FROM MonthlyDemandSummaryByRegion__c  WHERE Id != null ';

                    String groupBy = ' GROUP BY Area__r.Area__c, Part__r.ProductCode ';

                    Map<String, Decimal> demand24SummaryMap = new Map<String, Decimal>();
                    for(AggregateResult demand24Summary : Database.query(summaryQuery + target24Where + groupBy)) {
                        String key = (String)demand24Summary.get('Area__c') +'_'+ (String)demand24Summary.get('ProductCode');
                        demand24SummaryMap.put(key, (Decimal)demand24Summary.get('totalQty') + (Decimal)demand24Summary.get('totalReQty'));
                    }

                    Map<String, Decimal> demand36SummaryMap = new Map<String, Decimal>();
                    for(AggregateResult demand36Summary : Database.query(summaryQuery + target36Where + groupBy)) {
                        String key = (String)demand36Summary.get('Area__c') +'_'+ (String)demand36Summary.get('ProductCode');
                        demand36SummaryMap.put(key, (Decimal)demand36Summary.get('totalQty') + (Decimal)demand36Summary.get('totalReQty'));
                    }
                    
                    for(MonthlyDemandSummaryByRegion__c demandSummary : Database.query(getDemandQuery('MonthlyDemandSummaryByRegion__c', targetWhere))) {
                        String key = demandSummary.FM_AreaCode__c + '_' + demandSummary.FM_PartCode__c;

                        DN_ROPCalculatorBatch.ForcastDemandData forcastData;
                        if(demandSummaryMap.containsKey(key)) {
                            forcastData = demandSummaryMap.get(key);
                            if(forcastData.price == null)
                                forcastData.price = demandSummary.CustomerPrice__c;
                        }else {
                            forcastData = new DN_ROPCalculatorBatch.ForcastDemandData(24);
                            forcastData.period = Integer.valueOf(period);
                            forcastData.key = key;
                            forcastData.price = demandSummary.CustomerPrice__c;
                        }
                        
                        forcastData.changeDemandForValue(demandSummary.AnalysisPeriodMonth__c, Integer.valueOf(demandSummary.FM_TotalQuantity__c));
                        demandSummaryMap.put(key, forcastData);
                    }

                    if(demandSummaryMap.size() > 0)  {
                        for(String key : demandSummaryMap.keySet()) {
                            System.debug(' demandSummaryMap key: '+ key);
                            DN_ROPCalculatorBatch.ForcastDemandData forcastData = demandSummaryMap.get(key);
                            // forcastData.calculateMonthDemandUpTo(36); //표준편차 계산
                            forcastData.calculateMonthDemandUpTo(18); //표준편차 계산

                            if(demand24SummaryMap.containsKey(key)) {
                                forcastData.forecast24MonthsDemand = Double.valueOf(demand24SummaryMap.get(key));
                            }

                            if(demand36SummaryMap.containsKey(key)) {
                                forcastData.forecast36MonthsDemand = Double.valueOf(demand36SummaryMap.get(key));
                            }
                        }

                        System.debug('demandSummaryMap : ');
                        System.debug(JSON.serializePretty(demandSummaryMap));

                        // Map<String, Double> dealerLeadTimeMap = getDealerLeadTimeMap(plant, partCodes);
                        Map<String, Double> dealerLeadTimeMap = getDealerLeadTimeMap(plant, partIds);
                        // Map<String, ProductByPlant__c> productMap = getPlantByProductMap(plant, partCodes);
                        Map<String, ProductByPlant__c> productMap = getPlantByProductMap(plant, partIds);
                        for(AreaPartMasterByMPPS__c areaPart : (List<AreaPartMasterByMPPS__c>) scope) {
                            String key = areaPart.FM_AreaCode__c + '_' + areaPart.FM_PartCode__c;
                            System.debug('key : '+ key);
                            if(!demandSummaryMap.containsKey(key)) continue;
                            
                            Double lt;
                            
                            //PDT
                            //1. DealerLeadTimeManagement__c(ZSPT2510-PLIFZ) 대리점 PDT 우선
                            //2. Material Master 의 PDT  (1 이 없을 경우, MARC-PLIFZ)
                            if(dealerLeadTimeMap.containsKey(areaPart.FM_PartCode__c)) lt = dealerLeadTimeMap.get(areaPart.FM_PartCode__c);
                            ProductByPlant__c productInfo = productMap.get(areaPart.FM_PartCode__c);
                            if(lt == null) lt = productInfo?.PlannedDeliveryDay__c;
                            if(lt == null) lt = 0.0;
                            areaPart.PlannedDeliveryDays__c = lt;
    
                            DN_ROPCalculatorBatch.ForcastDemandData forcastData = demandSummaryMap.get(key);
                            areaPart.STDEV__c = forcastData.standardDeviation; //표준편차
                            if(areaPart.STDEV__c != null) areaPart.STDEV__c = ((Decimal)areaPart.STDEV__c).setScale(3, RoundingMode.HALF_UP);
                            areaPart.AMD__c = forcastData.amd;
                            if(areaPart.AMD__c != null) areaPart.AMD__c = ((Decimal)areaPart.AMD__c).setScale(3, RoundingMode.HALF_UP);
                            areaPart.WAMD__c = forcastData.wamd;
                            if(areaPart.WAMD__c != null) areaPart.WAMD__c = ((Decimal)areaPart.WAMD__c).setScale(3, RoundingMode.HALF_UP);
                            areaPart.M12__c = (forcastData.forecast12MonthsDemand != null) ? forcastData.forecast12MonthsDemand : 0;
                            areaPart.M18__c = (forcastData.forecast18MonthsDemand != null) ? forcastData.forecast18MonthsDemand : 0;
                            areaPart.M24__c = (forcastData.forecast24MonthsDemand != null) ? forcastData.forecast24MonthsDemand : 0;
                            areaPart.M36__c = (forcastData.forecast36MonthsDemand != null) ? forcastData.forecast36MonthsDemand : 0;
                            setSpeicailGrade(areaPart, productInfo);
                            setMRPType(areaPart);
    
                            String factorKey = areaPart.ABCIndicator__c+'_'+ areaPart.FM_AreaCode__c;
                            
                            Double svcFactor = 0, targetServiceLevel = 0;
                            Double amd = 0;
                            Double price = 0, weight = 0;
                            RopFactor factor;
                            if(factorMap.containsKey(factorKey)) {
                                factor = (RopFactor)factorMap.get(factorKey);
                                svcFactor = factor.svcFactor;
                                targetServiceLevel = factor.targetServiceLevel;
                            }
                            areaPart.ServiceFactor__c = svcFactor;
                            Double safetyStock = calculateSafetyStock(svcFactor, forcastData.standardDeviation, Math.sqrt((lt/30)));
                            areaPart.TargetServiceLevel__c = targetServiceLevel;

                            if('W.AMD'.equals(factor?.amdType) && areaPart.WAMD__c != null) {
                                amd = Double.valueOf(areaPart.WAMD__c);
                            } else if('AMD'.equals(factor?.amdType) && areaPart.AMD__c != null) {
                                //AMD
                                amd = Double.valueOf(areaPart.AMD__c);
                            }

                            factorKey += '_price';
                            StockFactor stockFactor;
                            if(factorMap.containsKey(factorKey)) {
                                stockFactor = (StockFactor)factorMap.get(factorKey);
                                weight = stockFactor.getPriceWeight(forcastData.price).weight;
                            }

                            areaPart.weight__c = weight;
                            System.debug('lt ' + lt);
                            Double rop , maxStockLevel = 0;
                            //ZSPT2490-APPMAX 가 'X' 일 경우만 Max Stock Level 계산    
                            if('X'.equals(factor?.applyMaxFlag)) {
                                if('X'.equals(factor?.addSFTFlag)) {
                                    //ROPAndStockFactorConfig__c-AddSFTFlag__c (ZSPT2490-ADDSFT) 가 'X' 일 경우 ROP  Safety Stock 사용
                                    rop = calculateROPMax(amd, (lT/30), safetyStock);
                                    
                                }else {
                                    //ZSPT2490-ADDSFT 가 '' 일 경우 ROP = ROP 
                                    rop = calculateROPMax(amd, (lT/30), 0);
                                }
                                rop = Math.ceil(rop);
                                
                                //Max. level Rounding Mode?
                                maxStockLevel = calculateMaxSafetyStock(rop, amd, Double.valueOf(areaPart.weight__c));
                                
                            }else {
                                //ZSPT2490-APPMAX 가 '' 일 경우 ROP 만 계산
                                //Fixed Mode
                                Double calculateLt = Double.valueOf((lT/30) + areaPart.weight__c);
                                //AddSFTFlag__c 
                                if('X'.equals(factor?.addSFTFlag)) {
                                    //ZSPT2490-ADDSFT 가 'X' 일 경우 ROP = ROP + Safety Stock
                                    rop = calculateROPFixed(amd, calculateLt, safetyStock);

                                }else {
                                    //ZSPT2490-ADDSFT 가 '' 일 경우 ROP = ROP 
                                    rop = calculateROPFixed(amd, calculateLt, 0);
                                }
                                rop = Math.ceil(rop);
                            }

                            System.debug(' 계산 완료 ReorderPoint__c : '+ rop);
                            System.debug(' 계산 완료 SafetyStock__c : '+ Math.ceil(rop / 3));
                            System.debug(' 계산 완료 MaximumStock__c : '+ Math.ceil(maxStockLevel));

                            //계산된 ROP, Max Stock Level 은 소수점 자리에서 올림 처리
                            //계산된 값 업데이트 (FIX 적용된 품번은 SafetyStock__c(EISBE), ReorderPoint__c(NINBE), MaximumStock__c(MABST) 업데이트 대상에서 제외)
                            if(!areaPart.IsFixedROP__c) {
                                areaPart.ReorderPoint__c = rop; //Math.ceil(rop);
                                // if(areaPart.ReorderPoint__c != null) areaPart.ReorderPoint__c = ((Decimal)areaPart.ReorderPoint__c).setScale(3, RoundingMode.HALF_UP);
                                areaPart.SafetyStock__c  = Math.ceil((areaPart.ReorderPoint__c / 3));// safetyStock;
                                areaPart.MaximumStock__c = Math.ceil((maxStockLevel));
                            }
                            
                            if(String.isNotBlank(areaPart.ABCIndicator__c) && 'N,R,S'.contains(areaPart.ABCIndicator__c)) {
                                // N, R, S 등급인 경우
                                areaPart.ReorderPoint__c = 0;
                                areaPart.SafetyStock__c = 0;
                                areaPart.MaximumStock__c = 0;
                            }
                            
                        }
                    }
                    
                }
            }
            update scope;
        } catch (Exception e) {
            String log = 'Type : '+type + '\n' //' query : ' +getQuery() + '\n' 
                       + ' externalKeys : ' + JSON.serialize(externalKeys) + '\n'
                       + ' Exception : ' + e.getStackTraceString() + '\n'
                       + ' Message : ' + e.getMessage();
            System.debug('Caculation Error : ' + log);
            logger.addLog(context.getJobId() , 'DN_ROPCalculatorBatch', 'execute', 'BatchApex', log);
        } finally {
            logger.insertLog();
        }

    }

    /*
    * @ Method : calculateSafetyStock
    * @ Description : svcFactor * satndardDeviation * rootLT
    */
    public Double calculateSafetyStock(Double svcFactor, Double satndardDeviation, Double rootLT) {
        return svcFactor * satndardDeviation * rootLT;
    }

    /*
    * @ Method : calculateROPMax
    * @ Description : wmd * planLeadTime / 30 + safetyStock
    */
    public Double calculateROPMax(Double wmd, Double planLeadTime, Double safetyStock) {
        System.debug('wmd : '+ wmd + ' planLeadTime : ' + planLeadTime + ' safetyStock : '+safetyStock);
        return wmd * planLeadTime / 30 + safetyStock;
    }

    /*
    * @ Method : calculateROPFixed
    * @ Description : wmd * planLeadTime + safetyStock
    */
    public Double calculateROPFixed(Double wmd, Double planLeadTime, Double safetyStock) {
        return wmd * planLeadTime + safetyStock;
    }

    /*
    * @ Method : calculateMaxSafetyStock
    * @ Description : rop + wmd * weight
    */
    public Double calculateMaxSafetyStock(Double rop, Double wmd, Double weight) {
        //Max. Stock Level =  ROP + WMD * Stock Weight
        return rop + wmd * weight;
    }

    /*
    * @ Method : setSpeicailGrade
    * @ Description : ABC 특별한 등급 산정
    */
    private void setSpeicailGrade(SObject partMPPS, ProductByPlant__c productInfo) {
        /**
         * Special Grade
         *  - M : Replaced item by supersession. (대체가 설정된 부품으로 대체 전 품목을 의미함)
         *  - P : Procure to Ordered item. (재고를 보유하지 않고 오더가 오면 확보하는 품목을 의미함)
         *        대체전 품목이 P등급이면 대체 후 등급도 P 등급
         * 
         *  - Z : Non planning item (수요계획을 하지 않는 부품)
         *         Material Master 에 Order Block 이 설정 되었을 경우
         *        36개월동안 수요가 없고, 품번이 생성된지 36개월이 지난 부품
         * - N : No demand in ABC Calculation period
         *         Material Master 에 Purchase Block 이 설정 되었을 경우 ('ZE' (NEW Newly Designed Item) 제외)
         *         24개월 동안 수요가 없고, 품번이 생성된지 24개월이 지난 부품
         * 
         * - R : 18개월 동안 수요가 없고, 품번이 생성된지 18개월이 지난 부품
         */
        Integer m18;
        if(partMPPS.get('M18__c') != null) m18 = Integer.valueOf(partMPPS.get('M18__c'));
        Integer m24;
        if(partMPPS.get('M24__c') != null) m24 = Integer.valueOf(partMPPS.get('M24__c'));
        Integer m36;
        if(partMPPS.get('M36__c') != null) m36 = Integer.valueOf(partMPPS.get('M36__c'));

        if(productInfo != null && productInfo.LastPart__r.ProductCode != null && productInfo.LastPart__r.ProductCode != productInfo.Part__r.ProductCode ) {
            //* MARC-LSTNR IS NOT INITIAL AND MARC-MATNR NE MARC-LSTNR
            partMPPS.put('ABCIndicator__c','M');
        }
        else if(m36 == 0 && m24 == 0 && m18 == 0) {
            partMPPS.put('ABCIndicator__c','Z');
        }
        else if(m24 == 0 && m18 == 0) {
            partMPPS.put('ABCIndicator__c','N');
        }
        else if(m18 == 0) {
            partMPPS.put('ABCIndicator__c','R');
        } 
    }

    /*
    * @ Method : setMRPType
    * @ Description : MRP Type (안전재고) 대상 설정
    */
    private void setMRPType(SObject partMPPS) {
        /**
         * MRP Type (안전재고 대상)
         * - 대체가 설정되었을 경우 대체전 품목이 'VB' (안전재고 대상) 이면 대체 후 품번도 'VB' 가 된다.
         * - 산정된 등급이 P, S, Z, M, W 일 경우 'ND'
         */
        String abcGrade;
        String mrpType;
        if(partMPPS.get('ABCIndicator__c') != null) abcGrade = String.valueOf(partMPPS.get('ABCIndicator__c'));
        if(partMPPS.get('MRPType__c') != null) mrpType = String.valueOf(partMPPS.get('MRPType__c'));

        if(mrpType == 'VB') return;

        switch on abcGrade {
            when 'P','S','Z', 'M', 'W' {
                partMPPS.put('MRPType__c','ND');
            }
            when else {
                
            }
        }

    }

    /*
    * @ Method : getDemandQuery
    * @ Description : DemandQuery 반환
    */
    private String getDemandQuery(String objectApi, String whereClause) {
        SchemaInfo targetSchema = new SchemaInfo(objectApi);
        String orderBy = ' ORDER BY ExternalKey__c ';
        String query = ' SELECT '
                     + targetSchema.getAllFieldsForQuery()
                     + ' FROM ' + objectApi
                     + ' WHERE Id != null '
                     + whereClause
                     + orderBy;
        return query;
    }

    /*
    * @ Method : finish
    * @ Description : 배치 종료
    */
    public void finish(Database.BatchableContext context){
        System.debug(' =============== DN_ROPCalculatorBatch Batch finish ================');
        System.debug('배치 실행 완료');
        try {
             if(remainIds.size() > 0)   {
                //다른 남아있는 Dealer 수행
                switch on type {
                    when DEALER {
                        //dealer 별로 계산
                        DN_ABCGradeLimitGeneratorBatch abcCalculateBatch = new DN_ABCGradeLimitGeneratorBatch(DN_ABCGradeLimitGeneratorBatch.SummaryType.DEALER, remainIds);
                        Database.executeBatch(abcCalculateBatch, 200);
                    }
                    when REGION {
                        //region
                        DN_ABCGradeLimitGeneratorBatch abcCalculateBatch = new DN_ABCGradeLimitGeneratorBatch(DN_ABCGradeLimitGeneratorBatch.SummaryType.REGION, remainIds);
                        Database.executeBatch(abcCalculateBatch, 200);
                    }
                }
             }else {
                switch on type {
                    when DEALER {
                        
                    }
                }
             }
        } catch (Exception e) {
            String log = ''
                       + ' Exception : ' + e.getStackTraceString()
                       + ' Message : ' + e.getMessage();
            logger.addLog(context.getJobId() , 'DN_ROPCalculatorBatch', 'finish', 'BatchApex', log);
        } finally {
            logger.insertLog();
        }
    }

    /*
    * @ Method : getDealerLeadTimeMap
    * @ Description : DealerLeadTimeManagement 데이터 맵으로 반환
    */
    private Map<String, Double> getDealerLeadTimeMap(String plantCode, Set<String> partIdSet) {
        Map<String, Double> leadTimeMap = new Map<String, Double>();
        for(DealerLeadTimeManagement__c pdt : [
                    SELECT 
                        Plant__c, Part__c, Part__r.ProductCode, PlannedDeliveryDays__c 
                    FROM DealerLeadTimeManagement__c
                    WHERE Plant__c = :plantCode AND Part__c IN :partIdSet
        ]) {
            if(pdt.PlannedDeliveryDays__c != null)
                leadTimeMap.put(pdt.Part__r.ProductCode, pdt.PlannedDeliveryDays__c);
        }	
        return leadTimeMap;
    }

    /*
    * @ Method : getPlantByProductMap
    * @ Description : ProductByPlant 데이터 맵으로 반환
    */
    private Map<String, ProductByPlant__c> getPlantByProductMap(String plantCode, Set<String> partIdSet) {
        Map<String, ProductByPlant__c> productMap = new Map<String, ProductByPlant__c>();
        for(ProductByPlant__c productInfo : [
            SELECT
                Part__r.ProductCode, PlannedDeliveryDay__c, LastPart__r.ProductCode,
                RoundingValue__c, MinLotSize__c
            FROM ProductByPlant__c 
            WHERE Plant__c = :plantCode AND Part__c IN :partIdSet
            
        ]) {
            productMap.put(productInfo.Part__r.ProductCode, productInfo);
        }
        return productMap;
    }

    /*
    * @ Class : ForcastDemandData
    * @ Description : ForcastDemandData Class
    */
    public class ForcastDemandData {
        private String key     {get; set;}
        private Double price   {get; set;}
        private Integer period {
            get {
                if(period == null) period = 18; //AS-IS: M-1 ~ M-18까지 기간으로 측정됨
                return period;
            }
            set;
        }
        private Double forecast12MonthsDemand;//이번달을 포함하지 않고 과거 12개월동안 수요
        private Double forecast18MonthsDemand;//이번달을 포함하지 않고 과거 18개월동안 수요
        private Double forecast24MonthsDemand;//이번달을 포함하지 않고 과거 24개월동안 수요
        private Double forecast36MonthsDemand;//이번달을 포함하지 않고 과거 36개월동안 수요

        private Double sumDemandWeight {get; set;}
        private Double sumWeight       {get; set;}
        public Double wamd            {get; set;} //W.AMD
        public Double amd             {get; set;} //AMD
        public Double avgDemand       {get; set;} //AVG Demand
        
        private Double sumDemand           {get; set;}
        private Double sumDemandCount      {get; set;}
        private Double sumSquaredDeviation {get; set;} 
        public Double standardDeviation   {get; set;} //표본표준편차


        Map<String, DemandData> demandMap {
            get {
                if(demandMap == null) demandMap = new Map<String, DemandData>{};
                return demandMap;
            }
            set;
        }

        /*
        * @ Method : ForcastDemandData
        * @ Description : M-1 ~ M-(N) 달까지 맵으로 반환
        */
        public ForcastDemandData(Integer finalTargetPeriod) {
            DateTime currentDate = System.now();
            DateTime today = DateTime.newInstance(currentDate.year(), currentDate.month(), 2);
            System.debug(today);
            //M-1 ~ M-(N) 달까지
            for(Integer i = finalTargetPeriod; i >= 1; i--) {
                DateTime beforeMonth = today.addMonths(-1 * i);
                System.debug(' i: '+i + ' , beforeMonth : '+ beforeMonth);
                
                String key = getYearMonthFrom(beforeMonth);
                System.debug('key : '+ key);
                DemandData beforeMonthDemand = new DemandData();
                beforeMonthDemand.demandDateTime = beforeMonth;
                beforeMonthDemand.differenceFromCurrentMonth = -1 * i; //today.date().monthsBetween(beforeMonth.date());
                demandMap.put(key, beforeMonthDemand);
            }
        }

        /*
        * @ Method : setDefaultPeriod
        * @ Description : period 설정
        */
        public void setDefaultPeriod(Integer period) {
            this.period = period;
        }

        /*
        * @ Method : changeDemandForValue
        * @ Description : Key에 해당하는 demand 설정
        */
        public void changeDemandForValue(String key, Double demand) {
            // demandMap.get(key).setDemand(demand);
            if(demandMap.containsKey(key))
                demandMap.get(key).demand = demand;
        }

         /*
        * @ Method : changeDemandForValue
        * @ Description : Key에 해당하는 demand 설정
        */
        public void setDemandForDateTime(DateTime targetDateTime, DemandData demand) {
            String key = getYearMonthFrom(targetDateTime);
            demandMap.put(key, demand);
        }

        /*
        * @ Method : calculateMonthDemandUpTo
        * @ Description : Demand 가 있는 개월 수 목록 반환
        */
        public void calculateMonthDemandUpTo(Integer lastMonth) {
            Integer loopCount = 1;
            Double totalDemand = forecast12MonthsDemand = forecast18MonthsDemand = forecast24MonthsDemand = sumWeight = sumDemand = sumDemandCount = sumSquaredDeviation = standardDeviation = wamd = amd = 0;

            sumDemandWeight = 0.0; //분자(Weighted Demand 합)
            sumWeight       = Double.valueOf(calculateSum(period)); //분모(SUM Weight)
            List<Double> activeDemands = new List<Double>();        //Demand 가 있는 개월 수
            List<DemandData> demandsList = demandMap.values();
            
            for(Integer idx = demandsList.size()-1; idx >= 0; idx--) {
                DemandData demand = demandsList.get(idx);
                System.debug(' before M : ' + demand.differenceFromCurrentMonth);
                //0은 수요에서 제외
                if(demand.demand != null && demand.demand > 0) {
                    totalDemand += demand.demand;

                    if(loopCount <= period) {
                        //Period 기간동안 Demand 값 추가
                        // Weight, Weighted Demand 계산
                        sumDemandWeight += demand.calculateWeightDemand();
                        activeDemands.add(demand.demand); 
                    }
                }

                System.debug(' loopCount : '+ loopCount + ' , totalDemand : ' +totalDemand + ' , sumDemandWeight : '+ sumDemandWeight);
                if(lastMonth != null && lastMonth < loopCount) break;

                switch on loopCount {
                    when 12 {
                        forecast12MonthsDemand = totalDemand;
                        System.debug('forecast12MonthsDemand : '+ forecast12MonthsDemand);
                        // amd = forecast12MonthsDemand / 12;
                    }
                    when 18 {
                        forecast18MonthsDemand = totalDemand;
                        System.debug('forecast18MonthsDemand : '+ forecast18MonthsDemand);
                        amd = forecast18MonthsDemand / Double.valueOf(period);
                    }
                    when 24 {
                        forecast24MonthsDemand = totalDemand;
                        System.debug('forecast24MonthsDemand : '+ forecast24MonthsDemand);
                        // amd = forecast24MonthsDemand / Double.valueOf(period);
                    }
                    when 36 {
                        forecast36MonthsDemand = totalDemand;
                    }
                }
                loopCount++;
            }
            System.debug(' sumDemandWeight : '+ sumDemandWeight + ' / '+ sumWeight);
            wamd = sumDemandWeight / sumWeight;
            
            calculateStandardDeviation(activeDemands);
        }

        /*
        * @ Method : calculateStandardDeviation
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
        public void calculateStandardDeviation(List<Double> demands) {

            demands.sort(); //정렬
            Integer demandSize = demands.size();
            System.debug('demandSize : '+demandSize);

            if(demandSize > 12) {
                //Case 1 (수요가 있는 개월 수 > 12)
                //최상위 2건 삭제
                demands.remove(0);
                demands.remove(0);

                //최하위 2건 삭제
                demands.remove(demands.size() - 1);
                demands.remove(demands.size() - 1);
                
            }else if(demandSize > 6) {
                //Case 2 (수요가 있는 개월 수 > 6)

                //최상위 1건 삭제
                demands.remove(0);

                //최하위 1건 삭제
                demands.remove(demands.size() - 1);
                
            }else {
                //Case 3 (수요가 있는 개월 수 <= 6)
                //18개월 데이터 모두 사용 - By Pass
            }

            sumDemandCount = Double.valueOf(period) -  Double.valueOf(( demandSize - demands.size())); // 전체 개수에서 로직

            sumDemand =  0;
            for(Double demand : demands) {
                sumDemand += Double.valueOf(demand);
            }

            // 평균 수요 계산
            System.debug('sumDemand : '+sumDemand + ' / sumDemandCount : '+sumDemandCount);
            avgDemand = sumDemand / sumDemandCount; 

            //평균으로부터 떨어진 거리를 제곱한 값
            sumSquaredDeviation = 0; 
            for(Integer startIdx = 0; startIdx < sumDemandCount; startIdx++) {
                Double demand = startIdx < demands.size() ? demands.get(startIdx) : 0.0; //
                Double squaredDeviation = (demand - avgDemand) * (demand - avgDemand);
                sumSquaredDeviation += squaredDeviation;
            }

            standardDeviation = Math.sqrt(sumSquaredDeviation / (sumDemandCount - 1));
        }

        /*
        * @ Method : getforecastMonthsDemand
        * @ Description : 개월수에 따른 forecastMonthsDemand 반환
        */
        public Double getforecastMonthsDemand() {
            Double forecastMonthsDemand = 0;

            switch on period {
                when 12 {
                    forecastMonthsDemand = forecast12MonthsDemand; 
                }
                when 18 {
                    forecastMonthsDemand = forecast18MonthsDemand; 
                }
                when 24 {
                    forecastMonthsDemand = forecast24MonthsDemand; 
                }
            }

            return forecastMonthsDemand;
        }

        /*
        * @ Method : calculateSum
        * @ Description : sum = (n * (1 + n)) / 2 공식으로 계산하여 반환
        */
        public Integer calculateSum(Integer n) {
            // 등차수열 합 공식 사용: S_n = n * (a_1 + a_n) / 2
            Integer sum = (n * (1 + n)) / 2;
            return sum;
        }
        
    }

    public class DemandData {
        private DateTime demandDateTime {get; set;}
        private Integer differenceFromCurrentMonth {
            get; 
            set{
                differenceFromCurrentMonth = value;

                //가중치는 18개월 기준으로 고정
                /*
                *가중치는 고정?
                M-18	M-17	M-16	M-15	M-14	M-13	M-12	M-11	M-10	M-9	M-8	M-7	M-6	M-5	M-4	M-3	M-2	M-1
                1	    2	    3	    4	    5	    6	    7	    8	    9	    10	11	12	13	14	15	16	17	18
                */
                weight = 19 + differenceFromCurrentMonth;
            }
        }
        private Double demand {get; set;}
        private Double weight {get; set;}

        /*
        * @ Method : calculateWeightDemand
        * @ Description : amd = demand * weight 계산하여 반환
        */
        public Double calculateWeightDemand() {
            // 수요 * 가중치
            Double amd = demand * weight;
            return amd;
        }
    }

    /*
    * @ Class : Factor
    * @ Description : Factor Class
         * 0. Safety Stock
     * = Service Factor(ROPAndStockFactorConfig__c) * 표준편차 * ROOT(LT/30)
     * 
     * 1. ROP(Reorder Point)는 안전재고의 재발주 시점을 의미한다.
     * -가용재고 = RO-1 이 되면 안전재고 PO가 생성됩니다.
     * -PO 수량은 Max. Stock Level - (ROP-1)
     * ROP (Reorder Point)
     * = WMD * (LT/30) + Safety Stock
     * 
     * 2. Max. Stock Level은 수요량의 변동에 따른 안전재고 확보량 입니다.
     * Max. Sotck Level
     * = ROP + WMD * Stock Weight
     * 
     * 3. 안전재고량 결정은 Safety Stock -> ROP -> Max. Stock Level 순서로 계산 됩니다.
     *
     * 표준편차 (기준 18개월)
     * Case 1 (수요가 있는 개월 수 > 12)
     * = SQRT( 18개월의 제품별 수요의 합 /(18 - (18개월 수요 최상/최하 2개씩 제외한 수요월 개수 (=4)) - 1))
     * 
     * Case 2 (수요가 있는 개월 수 > 6)
     * = SQRT( 18개월의 제품별 수요의 합 /(18 - (18개월 수요 가장 최상/최하 수요월 개수 (=2)) - 1))
     * 
     * Case 3 (수요가 있는 개월 수 <= 6)
     * = SQRT( 18개월의 제품별 수요의 합 /(18 - 1))
     *
     * 
     * ROP값을 증가시키려면 Service Factor 를 상향 조정하고
     * Max. Stock Level을 높이려면 Stock Weight 값을 상향 조정해야합니다.
     * 
    */
    public virtual class Factor {
        protected String  plant                    {get; set;}
        protected String  dealer                   {get; set;}
        protected String  dealerCode               {get; set;}
        protected String  region                   {get; set;}
        protected String  regionCode               {get; set;}
        protected String  abcIndicator             {get; set;}
        protected Double demandPeriod            {
            get {
                if(demandPeriod == null) demandPeriod = 18;
                return demandPeriod;
            }
            set;
        }

        /*
        * @ Method : getType
        * @ Description : dealer 또는 region 반환
        */
        public String getType() {
            String type;
            if(String.isNotBlank(dealerCode)) {
                type = 'dealer';
            }else if(String.isNotBlank(regionCode)) {
                type = 'region';
            }
            return type;
        }
        
        /*
        * @ Method : getTypeKey
        * @ Description : typeKey 반환
        */
        public virtual String getTypeKey() {
            String type = getType();
            String typeKey = abcIndicator+'_';
            switch on type {
                when 'dealer'{
                    typeKey += dealerCode;
                }
                when 'region' {
                    typeKey += regionCode;
                }
            }
            return typeKey;
        }

        /*
        * @ Method : getDemandPeriod
        * @ Description : demandPeriod 반환
        */
        public Double getDemandPeriod() {
            return this.demandPeriod;
        }
    }

    public class RopFactor extends Factor {
        private String amdType                  {get; set;}
        private Double targetServiceLevel      {
            get { 
                if(targetServiceLevel == null) targetServiceLevel = 0;
                return targetServiceLevel;
            }
            set;
        }
        private Double svcFactor      {
            get {
                if(svcFactor == null) svcFactor = 0;
                return svcFactor;
            }
            set;
        }
        private String addSFTFlag   {get; set;}
        private String applyMaxFlag {get; set;}
        
        /*
        * @ 생성자 : RopFactor
        * @ Description : ROPAndStockFactorConfig__c 데이터 변환
        */
        public RopFactor(ROPAndStockFactorConfig__c ropFactorSObject) {
            if(!'AreaROPCalculationFactorConfiguration'.equals(ropFactorSObject.RecordType.DeveloperName)) throw new CustomException('Not Available Record Type : '+ ropFactorSObject.RecordType.DeveloperName);
            
            this.plant        = ropFactorSObject.Plant__c;
            this.dealer       = ropFactorSObject.Dealer__c;
            this.dealerCode   = ropFactorSObject.FM_DealerCode__c;
            this.region       = ropFactorSObject.Area__c;
            this.regionCode   = ropFactorSObject.FM_AreaCode__c;
            this.abcIndicator = ropFactorSObject.ABCIndicator__c;
            this.demandPeriod = ropFactorSObject.DemandPeriod__c;
            this.svcFactor    = ropFactorSObject.SVCFactor__c;
            this.targetServiceLevel = ropFactorSObject.TargetServiceLevel__c;
            this.addSFTFlag   = ropFactorSObject.AddSFTFlag__c;
            this.applyMaxFlag = ropFactorSObject.ApplyMaxFlag__c;
            this.amdType = ropFactorSObject.AMDType__c;
        }
    }

    public class PriceWeight {
        private Double priceFrom      {
            get {
                if(priceFrom == null) priceFrom = 0;
                return priceFrom;
            }
            set;
        }
        private Double priceTo      {
            get {
                if(priceTo == null) priceTo = 0;
                return priceTo;
            }
            set;
        }
        private Double weight      {
            get {
                if(weight == null) weight = 0;
                return weight;
            }
            set;
        }
        public PriceWeight() {}
        /*
        * @ 생성자 : PriceWeight
        * @ Description : priceFrom,priceTo,weight 데이터 변환
        */
        public PriceWeight(Double priceFrom, Double priceTo, Double weight) {
            this.priceFrom = priceFrom;
            this.priceTo = priceTo;
            this.weight = weight;
        }
    }

    public class StockFactor extends Factor {

        private List<PriceWeight> priceWeights {
            get {
                if(priceWeights == null) priceWeights = new List<PriceWeight>();
                return priceWeights;
            }
            set;
        }

        /*
        * @ 생성자 : StockFactor
        * @ Description : ROPAndStockFactorConfig__c 데이터 변환
        */
        public StockFactor(ROPAndStockFactorConfig__c stockFactorSObject) {
            if(!'AreaMaxStockWeightingFactor'.equals(stockFactorSObject.RecordType.DeveloperName)) throw new CustomException('Not Available Record Type : '+ stockFactorSObject.RecordType.DeveloperName);

            this.plant        = stockFactorSObject.Plant__c;
            this.dealer       = stockFactorSObject.Dealer__c;
            this.dealerCode   = stockFactorSObject.FM_DealerCode__c;
            this.region       = stockFactorSObject.Area__c;
            this.regionCode   = stockFactorSObject.FM_AreaCode__c;
            this.abcIndicator = stockFactorSObject.ABCIndicator__c;
            this.demandPeriod = stockFactorSObject.DemandPeriod__c;
        }

        /*
        * @ Method : getTypeKey
        * @ Description : typeKey 반환
        */
        public override String getTypeKey() {
            String type = getType();
            String typeKey = abcIndicator+'_';
            switch on type {
                when 'dealer'{
                    typeKey += dealerCode;
                }
                when 'region' {
                    typeKey += regionCode;
                }
            }
            typeKey += '_price';
            return typeKey;
        }

        /*
        * @ Method : addPriceWeight
        * @ Description : priceWeights에 담기
        */
        public void addPriceWeight(Double priceFrom, Double priceTo, Double weight) {
            priceWeights.add(new PriceWeight(priceFrom, priceTo, weight));
        }

        /*
        * @ Method : getPriceWeight
        * @ Description : priceInRange 반환
        */
        public PriceWeight getPriceWeight(Double price) {
            PriceWeight priceInRange;
            if(price == null) {
                priceInRange = new PriceWeight();
                return priceInRange;
            }

            for(PriceWeight priceWeight : priceWeights) {
                if(priceWeight.priceFrom <= price && price <= priceWeight.priceTo) {
                    priceInRange = priceWeight;
                }
            }

            return priceInRange;
        }
    }

    public class CustomException extends Exception {}
}