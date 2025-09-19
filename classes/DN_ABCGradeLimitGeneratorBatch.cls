/** 
 * @Class :  DN_ABCGradeLimitGeneratorBatch
 * 
 * @Test: DN_ABCGradeLimitGeneratorBatch_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 02. 04. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-04 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_ABCGradeLimitGeneratorBatch implements Database.Batchable<SObject>, Database.Stateful {
    public enum SummaryType {
        DEALER, REGION
    }
    
    private DN_AsyncApexErrorLogger logger {
        get {
            if(logger == null) logger = new DN_AsyncApexErrorLogger();
            return logger;
        }
        set;
    }
    private SummaryType type {get; set;}
    private String dealerId {get; set;} //DealerId
    private Set<String> dealerIds {get; set;} //DealerIds
    private Set<String> regionIds {get; set;} //DealerIds
    private String targetId {get; set;}
    private String recordTypeDeveloperName {get; set;}
    private String plantCode {
        get {
            if(String.isBlank(plantCode)) plantCode = '1846';
            return plantCode;
        } 
        set;
    }

    private Map<String, GradeCalculationData> calculateMap {
        get {
            if(calculateMap == null) calculateMap = new Map<String,GradeCalculationData>();
            return calculateMap;
        }
        set;
    }
    private Map<String, Decimal> totalAmountAccumulateMap {
        get {
            if(totalAmountAccumulateMap == null) totalAmountAccumulateMap = new Map<String,Decimal>();
            return totalAmountAccumulateMap;
        }
        set;
    }

    private List<String> targetDebugIds {get; set;}

    /*
    * @ 생성자 : DN_ABCGradeLimitGeneratorBatch
    * @ Description : Type 설정
    */
    public DN_ABCGradeLimitGeneratorBatch(SummaryType type) {
        this.type = type;
    }

    /*
    * @ 생성자 : DN_ABCGradeLimitGeneratorBatch
    * @ Description : Type,remainIds 설정
    */
    public DN_ABCGradeLimitGeneratorBatch(SummaryType type, Set<String> remainIds) {
        this.type = type;

        switch on type {
            when DEALER {
                this.dealerIds = remainIds;        
            }
            when REGION {
                this.regionIds = remainIds;        
            }
        }
    }

    /*
    * @ Method : start
    * @ Description : 배치 시작
    */
    public Database.QueryLocator start(Database.BatchableContext context){
        System.debug(' =============== DN_ABCGradeLimitGeneratorBatch Batch start ================');
        return Database.getQueryLocator(getQuery());
    }

    /*
    * @ Method : getObjectInfo
    * @ Description : objectType,addtionalFields,orderBy 반환
    */
    private Map<String,String> getObjectInfo() {
        Map<String,String> objectInfoMap = new Map<String,String>();
        String objectType;
        String addtionalFields;
        String orderBy = ' ORDER BY ';

        switch on this.type{
            when DEALER {
                recordTypeDeveloperName = 'Dealer';
                objectType = 'MonthlyDemandSummaryByDealer__c';
                addtionalFields = ', Dealer__r.CustomerCode__c, Part__r.ProductCode ';
                orderBy += ' FM_DealerCode__c desc , CustomerPrice__c desc, AnalysisPeriodMonth__c desc ';
            }
            when REGION {
                recordTypeDeveloperName = 'Region';
                objectType = 'MonthlyDemandSummaryByRegion__c';
                addtionalFields = ', Area__r.Area__c, Part__r.ProductCode ';
                orderBy += ' FM_AreaCode__c desc , CustomerPrice__c desc, AnalysisPeriodMonth__c desc ';
            }
        }

        objectInfoMap.put('objectType', objectType);
        objectInfoMap.put('addtionalFields', addtionalFields);
        objectInfoMap.put('orderBy', orderBy);
        
        return objectInfoMap;
    }

    /*
    * @ Method : getQuery
    * @ Description : 쿼리 반환
    */
    private String getQuery() {
        Map<String, String> objInfo = getObjectInfo();
        String sObjectApi = objInfo.get('objectType');
        String addtionalFields = objInfo.get('addtionalFields');
        String queryOrderBy = objInfo.get('orderBy');

        SchemaInfo objSchema = new SchemaInfo(sObjectApi);
        String queryFields = objSchema.getAllFieldsForQuery();
        if(String.isNotBlank(addtionalFields)) queryFields += addtionalFields;
        String query = ' SELECT '
                     + queryFields
                     + ' FROM ' +sObjectApi
                     + ' WHERE Id != null AND Frequency__c > 0 ';
        
        if(String.isNotBlank(dealerId))
            query += ' AND Dealer__c = \''+dealerId+'\'';

        if(dealerIds != null && dealerIds.size() > 0) {
            List<String> remainDealerIds = new List<String>(dealerIds);
            List<String> targetDealerIds = new List<String>();
            Integer dealerIdSize = remainDealerIds.size();
            
            String titile = '';
            String message = '';
            for(Integer i = dealerIdSize-1; i >= 0; i--) {
                targetId = remainDealerIds.get(i);
                titile += targetId + ' ABC 등급 계산';
                targetDealerIds.add(targetId);
                remainDealerIds.remove(i);
                System.debug(' New : ' +targetDealerIds.size() + ' : Before : '+remainDealerIds.size());
                if(targetDealerIds.size() == 1) break;
            }
            targetDebugIds = targetDealerIds;
            dealerIds = new Set<String>(remainDealerIds);
            if(dealerIds.size() > 0 ) {
                message += '다음 배치때 계산할 대리점: ' + JSON.serialize(dealerIds);
            }else {
                message += 'ABC 등급 계산 끝 ';
            }

            sendAppNoti(titile ,message, targetId);

            query += ' AND Dealer__c IN (\''+String.join(targetDealerIds, '\',\'')+'\')';
        }

        if(regionIds != null && regionIds.size() > 0) {
            List<String> remainRegionIds = new List<String>(regionIds);
            List<String> targetRegionIds = new List<String>();
            Integer regionIdSize = remainRegionIds.size();
            
            String titile = '';
            String message = '';
            for(Integer i = regionIdSize-1; i >= 0; i--) {
                targetId = remainRegionIds.get(i);
                titile += targetId + ' ABC 등급 계산';
                targetRegionIds.add(targetId);
                remainRegionIds.remove(i);
                System.debug(' New : ' +targetRegionIds.size() + ' : Before : '+remainRegionIds.size());
                if(targetRegionIds.size() == 1) break;
            }
            targetDebugIds = targetRegionIds;
            regionIds = new Set<String>(remainRegionIds);
            if(regionIds.size() > 0 ) {
                message += '다음 배치때 계산할 지역: ' + JSON.serialize(regionIds);
            }else {
                message += 'ABC 등급 계산 끝 ';
            }

            sendAppNoti(titile ,message, targetId);

            query += ' AND Area__c IN (\''+String.join(targetRegionIds, '\',\'')+'\')';
        }

        DateTime today = System.now();
        List<ABCCriteriaPeriod__c> period = [ SELECT Period__c FROM ABCCriteriaPeriod__c WHERE Plant__c = :plantCode];
        DateTime beforeMonth = today.addMonths(Integer.valueOf(-1 * period[0].Period__c));
        System.debug(beforeMonth);

        query += ' AND AnalysisPeriodMonth__c >= \''+getYearMonthFrom(beforeMonth)+'\''
              + ' AND AnalysisPeriodMonth__c < \''+getYearMonthFrom(today)+'\'';

        query += queryOrderBy;
            //   + ' LIMIT 50000000 ';

        System.debug('start query ==> '+ query);
        return query;
    }

    /*
    * @ Method : sendAppNoti
    * @ Description : DealerABCCalculateNoti 알람 발송
    */
    private void sendAppNoti(String title, String body, String targetId) {
        try {
            CustomNotificationType notificationType = 
            [ SELECT Id FROM CustomNotificationType  WHERE DeveloperName='DealerABCCalculateNoti']; 
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();

            notification.setTitle(title);
            notification.setBody(body);
            Id currentUserId = UserInfo.getUserId();
            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(targetId);
            notification.send(new Set<String>{currentUserId});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

    /*
    * @ Method : getYearMonthFrom
    * @ Description : yyyyMM으로 변환
    */
    @TestVisible
    private String getYearMonthFrom(DateTime targetTime) {
        return targetTime.format('yyyyMM');
    }

    /*
    * @ Method : execute
    * @ Description : 배치 실행
    */
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.debug(' =============== DN_ABCGradeLimitGeneratorBatch Batch Execute ================');
        System.debug('targetDebugIds : ' + targetDebugIds);
        try {
            switch on this.type{
                when DEALER {
                    setGenerateCalculation((List<MonthlyDemandSummaryByDealer__c>)scope);
                }
                when REGION {
                    setGenerateCalculation((List<MonthlyDemandSummaryByRegion__c>)scope);
                }
            }
        } catch (Exception e) {
            String log = ' query : ' +getQuery() + '\n'
                       + ' Exception : ' + e.getStackTraceString() + '\n'
                       + ' Message : ' + e.getMessage();
            logger.addLog(context.getJobId() , 'DN_ABCGradeLimitGeneratorBatch', 'execute', 'BatchApex', log);
        }

    }

    /*
    * @ Method : setGenerateCalculation
    * @ Description : 대리점용 산출 데이터
    */
    private void setGenerateCalculation(List<MonthlyDemandSummaryByDealer__c> summaryDealerList) {
        System.debug('setGenerateCalculation Dealer: ');
        for(MonthlyDemandSummaryByDealer__c summaryDealer : summaryDealerList) {
            String defaultKey = summaryDealer.FM_DealerCode__c+'_'+summaryDealer.FM_PartCode__c;  //기본Key: DealerCode_PartProductCode
            System.debug('defaultKey : '+ defaultKey + ', Id: '+summaryDealer.Id);
            if(defaultKey.indexOf('null') != -1) continue;
            GradeCalculationData calculationData;
            if(calculateMap.containsKey(defaultKey)) {
                calculationData = calculateMap.get(defaultKey);
                calculationData.frequency                += summaryDealer.FM_TotalFrequency__c;
                calculationData.quantity                 += summaryDealer.FM_TotalQuantity__c;
                System.debug('calculationData.analysisPeriodMonthStart :' + calculationData.analysisPeriodMonthStart);
                System.debug('calculationData.analysisPeriodMonthEnd :' + calculationData.analysisPeriodMonthEnd);
                if(calculationData.analysisPeriodMonthStart.compareTo(summaryDealer.AnalysisPeriodMonth__c) == -1 ) calculationData.analysisPeriodMonthStart = summaryDealer.AnalysisPeriodMonth__c;
                if(calculationData.analysisPeriodMonthEnd.compareTo(summaryDealer.AnalysisPeriodMonth__c) == 1) calculationData.analysisPeriodMonthEnd = summaryDealer.AnalysisPeriodMonth__c;
                
            }else {
                calculationData = new GradeCalculationData();
                calculationData.analysisPeriodMonthStart = calculationData.analysisPeriodMonthEnd = summaryDealer.AnalysisPeriodMonth__c;
                calculationData.dealer                   = summaryDealer.Dealer__c;
                calculationData.dealerCode               = summaryDealer.FM_DealerCode__c;
                calculationData.part                     = summaryDealer.Part__c;
                calculationData.partCode                 = summaryDealer.FM_PartCode__c;
                calculationData.frequency                = summaryDealer.FM_TotalFrequency__c;
                calculationData.quantity                 = summaryDealer.FM_TotalQuantity__c;
                calculationData.amount                   = summaryDealer.CustomerPrice__c;
                calculationData.key                      = summaryDealer.FM_DealerCode__c;
                calculationData.plant                    = summaryDealer.Plant__c;
                calculateMap.put(defaultKey, calculationData);
            }
        }
    }

    /*
    * @ Method : setGenerateCalculation
    * @ Description : 지역용 산출 데이터
    */
    private void setGenerateCalculation(List<MonthlyDemandSummaryByRegion__c> summaryRegionList) {
        System.debug('setGenerateCalculation Region: ');
        for(MonthlyDemandSummaryByRegion__c summaryRegion : summaryRegionList) {
            String defaultKey = summaryRegion.FM_AreaCode__c+'_'+summaryRegion.FM_PartCode__c;  //기본Key: RegionCode_PartProductCode
            System.debug('defaultKey : '+ defaultKey + ', Id: '+summaryRegion.Id);
            if(defaultKey.indexOf('null') != -1) continue;
            if(calculateMap.containsKey(defaultKey)) {
                GradeCalculationData calculationData = calculateMap.get(defaultKey);
                calculationData.frequency                += summaryRegion.FM_TotalFrequency__c;
                calculationData.quantity                 += summaryRegion.FM_TotalQuantity__c;
                if(calculationData.analysisPeriodMonthStart.compareTo(summaryRegion.AnalysisPeriodMonth__c) == -1 ) calculationData.analysisPeriodMonthStart = summaryRegion.AnalysisPeriodMonth__c;
                if(calculationData.analysisPeriodMonthEnd.compareTo(summaryRegion.AnalysisPeriodMonth__c) == 1) calculationData.analysisPeriodMonthEnd = summaryRegion.AnalysisPeriodMonth__c;
            }else {
                GradeCalculationData calculationData = new GradeCalculationData();
                calculationData.analysisPeriodMonthStart = calculationData.analysisPeriodMonthEnd = summaryRegion.AnalysisPeriodMonth__c;
                calculationData.region                   = summaryRegion.Area__c;
                calculationData.regionCode               = summaryRegion.FM_AreaCode__c;
                calculationData.part                     = summaryRegion.Part__c;
                calculationData.partCode                 = summaryRegion.FM_PartCode__c;
                calculationData.frequency                = summaryRegion.FM_TotalFrequency__c;
                calculationData.quantity                 = summaryRegion.FM_TotalQuantity__c;
                calculationData.amount                   = summaryRegion.CustomerPrice__c;
                calculationData.key                      = summaryRegion.FM_AreaCode__c;
                calculationData.plant                    = summaryRegion.Plant__c;
                calculateMap.put(defaultKey, calculationData);
            }
        }
    }

    /*
    * @ Method : finish
    * @ Description : 배치 종료
    */
    public void finish(Database.BatchableContext context){
        System.debug(' =============== DN_ABCGradeLimitGeneratorBatch Batch finish ================');
        System.debug('배치 실행 완료');
        try {
            if(calculateMap.size() > 0) {
                insertABCLimit();
            }
                
        } catch (Exception e) {
            String log = ''
                       + ' Exception : ' + e.getStackTraceString()
                       + ' Message : ' + e.getMessage();
            System.debug(log);
            logger.addLog(context.getJobId() , 'DN_ABCGradeLimitGeneratorBatch', 'finish.insertABCLimit', 'BatchApex', log);
        } finally {
            logger.insertLog();
        }
    }

    /*
    * @ Method : getKeyFieldByRecordType
    * @ Description : 레코드 타입에 따른 키필드 반환
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
    * @ Method : getABCCriteria
    * @ Description : ABCCriteria 데이터 반환
    */
    private Map<String,Object> getABCCriteria() {
        Map<String, Object> criteriaMap = new Map<String,Object>();

        Map<String, Map<String,ABCGradeFrequencyCriteria__c>> frequencyMap = new Map<String, Map<String,ABCGradeFrequencyCriteria__c>>();
        Map<String, Map<String,ABCGradeAmountCriteria__c>> amountMap = new Map<String, Map<String,ABCGradeAmountCriteria__c>>();
        String key;

        //ABCGradeFrequencyCriteria__c
        String frequencyCriteriaQuery = ' SELECT '
                                   + ' Dealer__c, Region__c, Grade__c, Frequency__c, Plant__c, FM_DealerCode__c, FM_AreaCode__c '
                                   + ' FROM ABCGradeFrequencyCriteria__c '
                                   + ' WHERE Id != null ';
        String frequencyCriteriaQueryOrderBy = ' ORDER BY Grade__c ';

        //ABCGradeAmountCriteria__c
        String amountCriteriaQuery = ' SELECT '
                                   + ' Dealer__c, Region__c, Grade__c, Rate__c, Plant__c, FM_DealerCode__c, FM_AreaCode__c '
                                   + ' FROM ABCGradeAmountCriteria__c '
                                   + ' WHERE Id != null ';
        String amountCriteriaQueryOrderBy = ' ORDER BY Grade__c ';

        key = getKeyFieldByRecordType();
        frequencyCriteriaQuery += ' AND '+key+' != null ';
        amountCriteriaQuery += ' AND '+key+' != null ';
        frequencyCriteriaQueryOrderBy += ' , '+key+' ';
        amountCriteriaQueryOrderBy += ' , '+key+' ';

        System.debug(' gradeFrequency query : '+ frequencyCriteriaQuery+frequencyCriteriaQueryOrderBy);
        for(ABCGradeFrequencyCriteria__c frequency : Database.query(frequencyCriteriaQuery+frequencyCriteriaQueryOrderBy)) {
            String keyValue = (String)frequency.get(key);
            if(!frequencyMap.containsKey(keyValue))
                frequencyMap.put(keyValue, new Map<String,ABCGradeFrequencyCriteria__c>());
            
            frequencyMap.get(keyValue).put(frequency.Grade__c, frequency);
        }

        System.debug(' gradeAmount query : '+ amountCriteriaQuery+amountCriteriaQueryOrderBy);
        for(ABCGradeAmountCriteria__c amount : Database.query(amountCriteriaQuery+amountCriteriaQueryOrderBy)) {
            String keyValue = (String)amount.get(key);
            if(!amountMap.containsKey(keyValue))
                amountMap.put(keyValue, new Map<String,ABCGradeAmountCriteria__c>());
            
            amountMap.get(keyValue).put(amount.Grade__c, amount);
        }
    
        criteriaMap.put('frequecyCriteria', frequencyMap);
        criteriaMap.put('amountCriteria', amountMap);

        return criteriaMap;
    }

    /*
    * @ Method : insertABCLimit
    * @ Description : ExternalKey__c 기준 업설트 및 조건에 따른 후속 배치 실행
    */
    private void insertABCLimit() {
        Map<String,ABCCriteriaLimit__c> dmlMap = new Map<String,ABCCriteriaLimit__c>();
        List<GradeCalculationData> calculateList = calculateMap.values();
        
        Map<String, List<GradeCalculationData>> calculateListMap = new Map<String, List<GradeCalculationData>>();
        for(String key : calculateMap.keySet()) {
            GradeCalculationData targetData = calculateMap.get(key);
            String keyValue = targetData.getKeyValue();
            
            System.debug('insertABCLimit , calculateListMap key1 : '+ key);
            System.debug('insertABCLimit , keyValue : '+ keyValue);
            
            if(!calculateListMap.containsKey(keyValue))
                calculateListMap.put(keyValue, new List<GradeCalculationData>());

            calculateListMap.get(keyValue).add(targetData);

            //누적 금액 합계
            if(!totalAmountAccumulateMap.containsKey(keyValue))
                totalAmountAccumulateMap.put(keyValue, 0);
            // System.debug(' totalAmountAccumulateMap.get(keyValue) : ' + totalAmountAccumulateMap.get(keyValue) +' , targetData.getTotalAmount() : '+targetData.getTotalAmount());
            Decimal totalAmountAccumulate = totalAmountAccumulateMap.get(keyValue) + targetData.getTotalAmount();
            totalAmountAccumulateMap.put(keyValue, totalAmountAccumulate);
        }
        calculateList = null;

        if(calculateListMap.size() > 0) {
            for(List<GradeCalculationData> tmpCalculateList : calculateListMap.values()) {
                tmpCalculateList.sort();
            }
        }
        

        SchemaInfo objSchema = new SchemaInfo('ABCCriteriaLimit__c');
        Id recordTypeId = objSchema.getRecordTypeByDeveloperName(recordTypeDeveloperName).getRecordTypeId();
        
        Map<String, Object> criteriaInfo = getABCCriteria();
        Map<String, Map<String,ABCGradeFrequencyCriteria__c>> frequencyCriteria = (Map<String, Map<String,ABCGradeFrequencyCriteria__c>>)criteriaInfo.get('frequecyCriteria');
        Map<String, Map<String,ABCGradeAmountCriteria__c>> amountCriteria = (Map<String, Map<String,ABCGradeAmountCriteria__c>>)criteriaInfo.get('amountCriteria');

        Map<String, ABCCriteriaLimit__c> criteriaLimitMap = new Map<String, ABCCriteriaLimit__c>();
        List<ABCGradeCalculationResult__c> calculateResultList = new List<ABCGradeCalculationResult__c>();

        // System.debug(JSON.serializePretty(calculateListMap));

        for(String key : calculateListMap.keySet()) {
            System.debug('calculateListMap key : '+ key);
            Map<String,ABCGradeFrequencyCriteria__c> frequencyMap = frequencyCriteria.get(key);
            Map<String,ABCGradeAmountCriteria__c> amountMap = amountCriteria.get(key);
            if(frequencyMap == null || amountMap == null) continue;

            calculateList = calculateListMap.get(key);
            Decimal totalAmountAccumulate = totalAmountAccumulateMap.get(key);
            Integer totalSize = calculateList.size(); 
            Decimal currentAmount = 0; //누적 비율
            Double currentSize = 0; 
            String lastGrade;       //등수
            Double lastAmount = 0;  //등수
            Double firstAmount = 0; //비율에서 가장 높은 값
            String limitField = getKeyFieldByRecordType().replace('FM_', '');
            for(GradeCalculationData calculateData : calculateList) {
                //등수
                if(currentSize == firstAmount) firstAmount = calculateData.getTotalAmount();
                calculateData.rank = Integer.valueOf(++currentSize);
                // Double percentage = ++currentSize / totalSize * 100;
                // System.debug('currentSize : '+ currentSize + ' / totalSize : '+totalSize);
                currentAmount += calculateData.getTotalAmount();
                Double percentage = totalAmountAccumulate != 0 ? currentAmount / totalAmountAccumulate * 100 : 0;
                System.debug('currentAmount : '+ currentAmount + ' / totalAmountAccumulate : '+totalAmountAccumulate);

                String externalKey = calculateData.key;// + '_'+ calculateData.analysisPeriodMonthStart + '_' +calculateData.analysisPeriodMonthEnd;
                System.debug('externalKey : '+externalKey);
                ABCCriteriaLimit__c criteraiLimit;
                if(!criteriaLimitMap.containsKey(externalKey)) {
                    criteraiLimit = new ABCCriteriaLimit__c(
                        RecordTypeId = recordTypeId,
                        Type__c = 'Amount',
                        AnalysisPeriodMonthStart__c = calculateData.analysisPeriodMonthStart,
                        AnalysisPeriodMonthEnd__c = calculateData.analysisPeriodMonthEnd
                        // ,
                        // ExternalKey__c = externalKey
                    );
                    
                    criteraiLimit.put(limitField, key); //TODO:
                    criteriaLimitMap.put(externalKey, criteraiLimit);
                    criteraiLimit.ExternalKey__c = externalKey + '_'+ criteraiLimit.AnalysisPeriodMonthStart__c + '_' +criteraiLimit.AnalysisPeriodMonthEnd__c;
                }else {
                    criteraiLimit = criteriaLimitMap.get(externalKey);
                    if(criteraiLimit.AnalysisPeriodMonthStart__c.compareTo(calculateData.analysisPeriodMonthStart) == -1 ) criteraiLimit.AnalysisPeriodMonthStart__c = calculateData.analysisPeriodMonthStart;
                    if(criteraiLimit.AnalysisPeriodMonthEnd__c.compareTo(calculateData.analysisPeriodMonthEnd) == 1) criteraiLimit.AnalysisPeriodMonthEnd__c = calculateData.analysisPeriodMonthEnd;
                    criteraiLimit.ExternalKey__c = externalKey + '_'+ criteraiLimit.AnalysisPeriodMonthStart__c + '_' +criteraiLimit.AnalysisPeriodMonthEnd__c;
                    
                    for(String grade : amountMap.keySet()) {
                        ABCGradeAmountCriteria__c criteriaAmount = amountMap.get(grade);
                        System.debug(grade + ' Grade > ' + totalAmountAccumulate * criteriaAmount.Rate__c);
                        switch on criteriaAmount.Grade__c {
                            when 'H' {
                                criteraiLimit.HLimit__c = totalAmountAccumulate * criteriaAmount.Rate__c; //누적비율
                                // criteraiLimit.HLimit__c = (firstAmount != 0) ?  firstAmount * criteriaAmount.Rate__c : 0;
                            }
                            when 'M' {
                                criteraiLimit.MLimit__c = totalAmountAccumulate * criteriaAmount.Rate__c; //누적비율
                                // criteraiLimit.MLimit__c = (firstAmount != 0) ?  firstAmount * criteriaAmount.Rate__c : 0;
                            }
                            when 'L' {
                                criteraiLimit.LLimit__c = totalAmountAccumulate * criteriaAmount.Rate__c; //누적비율
                                // criteraiLimit.LLimit__c = (firstAmount != 0) ?  firstAmount * criteriaAmount.Rate__c : 0;
                            }
                        }

                    }
                }

                for(ABCGradeAmountCriteria__c criteriaAmount : amountMap.values()) {
                    System.debug('percentage => ' + percentage);
                    System.debug('criteriaAmount.Rate__c => ' + criteriaAmount.Rate__c);
                    if(percentage <= criteriaAmount.Rate__c) {
                        calculateData.amountGrade = criteriaAmount.Id;
                        calculateData.amountGradeLabel = criteriaAmount.Grade__c;
                        break;
                    }
                }
    
                // Frequency로 등급 계산
                for(ABCGradeFrequencyCriteria__c criteriaFrequency : frequencyMap.values()) {
                    if(calculateData.frequency >= criteriaFrequency.Frequency__c) {
                        calculateData.frequencyGrade = criteriaFrequency.Id;
                        calculateData.frequencyGradeLabel = criteriaFrequency.Grade__c;
                        break;
                    }
                }
                
                calculateResultList.add((ABCGradeCalculationResult__c)calculateData.convertTo());
            }
        }

        if(calculateResultList.size() > 0) {
            System.debug('calculateResultList.size(): '+ calculateResultList.size());
            if(!Test.isRunningTest()) {
                // 데이터 적재 주석처리
                Database.executeBatch(new DN_DMLBatchProcessing(DN_DMLBatchProcessing.DmlType.ADDORMODIFY, calculateResultList, 'ExternalKey__c'), 5000);
                switch on this.type{
                    when DEALER {
                        DN_UpsertGradeMppsPart dealerBatch = new DN_UpsertGradeMppsPart(DN_UpsertGradeMppsPart.SummaryType.DEALER, calculateResultList);
                        dealerBatch.setTargetId(targetId).setRemainIds(dealerIds);
                        Database.executeBatch(dealerBatch);
                    }
                    when REGION {
                        DN_UpsertGradeMppsPart regionBatch = new DN_UpsertGradeMppsPart(DN_UpsertGradeMppsPart.SummaryType.REGION, calculateResultList);
                        regionBatch.setTargetId(targetId).setRemainIds(regionIds);
                        Database.executeBatch(regionBatch);
                    }
                }   
            }
        }

        System.debug(
            JSON.serializePretty(criteriaLimitMap)
        );
        if(criteriaLimitMap.size() > 0) {
            upsert criteriaLimitMap.values() ExternalKey__c;
        }
    }

    /*
    * @ Class : GradeCalculationData
    * @ Description : GradeCalculationData Class 
    */
    public class GradeCalculationData implements Comparable {
        String key                      {get; set;}
        String analysisPeriodMonthStart {get; set;}
        String analysisPeriodMonthEnd   {get; set;}
        String plant                    {get; set;}
        String dealer                   {get; set;}
        String dealerCode               {get; set;}
        String part                     {get; set;}
        String partCode                 {get; set;}
        String region                   {get; set;}
        String regionCode               {get; set;}
        String amountGrade              {get; set;}
        String amountGradeLabel         {get; set;}
        String frequencyGrade           {get; set;}
        String frequencyGradeLabel      {get; set;}
        Integer rank                    {get; set;}
        Decimal quantity {
            get {
                if(quantity == null) quantity = 0;
                return quantity;
            }
            set;
        }
        Decimal amount {
            get {
                if(amount == null) amount = 0;
                return amount;
            }
            set;
        }
        Decimal frequency {
            get {
                if(frequency == null) frequency = 0;
                return frequency;
            }
            set;
        }

        /*
        * @ Class : getTotalAmount
        * @ Description : 수량 * 금액 = 총 금액
        */
        public Decimal getTotalAmount() {
            return quantity * amount;
        }

        /*
        * @ Class : compareTo
        * @ Description : 금액에 따른 정렬
        */
        public Integer compareTo(Object compareTo) {
            GradeCalculationData compareToTarget = (GradeCalculationData)compareTo;
            Decimal totalAmount = getTotalAmount();
            Decimal compareTotalAmount = compareToTarget.getTotalAmount();
            if (totalAmount < compareTotalAmount) return 1;
            if (totalAmount > compareTotalAmount) return -1;

            // 모든 값이 같다면 0 반환
            return 0;
        }

        /*
        * @ Class : getKeyValue
        * @ Description : 지역 OR 대리점별에 따른 keyValue 반환
        */
        public String getKeyValue() {
            String keyValue;
            if(String.isNotBlank(this.dealerCode)) keyValue = this.dealerCode;
            if(String.isNotBlank(this.regionCode)) keyValue = this.regionCode;
            return keyValue;
        }

        /*
        * @ Method : convertTo
        * @ Description : ABCGradeCalculationResult__c 형태로 변환
        */
        public SObject convertTo() {
            ABCGradeCalculationResult__c convertSObject = new ABCGradeCalculationResult__c(
                AnalysisPeriodMonthStart__c = this.analysisPeriodMonthStart, 
                AnalysisPeriodMonthEnd__c = this.analysisPeriodMonthEnd, 
                AmountGrade__c = this.amountGrade, 
                FrequencyGrade__c = this.frequencyGrade, 
                Quantity__c = this.quantity, 
                Amount__c = this.amount, 
                Frequency__c = this.frequency, 
                ExternalKey__c = this.partCode +'_'+ this.key +'_'+this.analysisPeriodMonthStart+'_'+this.analysisPeriodMonthEnd, 
                Part__c = this.part,
                PartCode__c = this.partCode,
                Rank__c = this.rank,
                Plant__c = this.plant
            );
            
            String key = this.amountGradeLabel + '_'+this.frequencyGradeLabel;
            if(String.isNotBlank(this.dealerCode)) {
                convertSObject.Dealer__c = this.dealer; 
                convertSObject.DealerCode__c = this.dealerCode;
                key += '_'+ dealerCode;
            }
            if(String.isNotBlank(this.regionCode)) {
                convertSObject.Region__c = this.region;
                convertSObject.AreaCode__c = this.regionCode;
                key += '_'+ regionCode;
            }
            System.debug('ABCIndicatorMatrix__c ExternalKey__c : '+ key);
            ABCIndicatorMatrix__c matrixResult = new ABCIndicatorMatrix__c(ExternalKey__c = key);
            convertSObject.ABCIndicator__r = matrixResult;
            return convertSObject;
        }
        
    }

    public class CustomException extends Exception {}
}