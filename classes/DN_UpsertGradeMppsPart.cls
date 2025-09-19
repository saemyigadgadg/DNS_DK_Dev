/** 
 * @Class :  DN_UpsertGradeMppsPart
 * 
 * @Test: DN_UpsertGradeMppsPart_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 28. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-28 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_UpsertGradeMppsPart implements Database.batchable<SObject>, Database.Stateful {
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
    private List<SObject> upsertList;
    private Set<String> externalKeys {
        get {
            if(externalKeys == null) externalKeys = new Set<String>();
            return externalKeys;
        }
        set;
    }
    private String targetId {
        get; set;
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
    * @ Method : DN_UpsertGradeMppsPart
    * @ Description : type, upsertList 설정
    */
    public DN_UpsertGradeMppsPart(SummaryType type, List<SObject> upsertList) {
        this.type = type;
        this.upsertList = upsertList;
    }

    /*
    * @ Method : setTargetId
    * @ Description : targetId 설정
    */
    public DN_UpsertGradeMppsPart setTargetId(String targetId) {
        this.targetId = targetId;
        return this;
    }

    /*
    * @ Method : setRemainIds
    * @ Description : remainIds 설정
    */
    public DN_UpsertGradeMppsPart setRemainIds(Set<String> remainIds) {
        this.remainIds = remainIds;
        return this;
    }

    /*
    * @ Method : start
    * @ Description : 배치 시작
    */
    public Iterable<sObject> start(Database.BatchableContext context){
        System.debug(' =============== DN_UpsertGradeMppsPart Batch start ================');
        return upsertList;
    }

    /*
    * @ Method : execute
    * @ Description : 배치 실행
    */
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.debug(' =============== DN_UpsertGradeMppsPart Batch Execute ================');
        try {
            upsertMPPSPart((List<ABCGradeCalculationResult__c>)scope);
        } catch (Exception e) {
            String log = ' Exception : ' + e.getStackTraceString() + '\n'
                       + ' Message : ' + e.getMessage();
            logger.addLog(context.getJobId() , 'DN_UpsertGradeMppsPart', 'execute', 'BatchApex', log);
        } finally {
            logger.insertLog();
        }

    }

    /*
    * @ Method : upsertMPPSPart
    * @ Description : MPPS 데이터 ExternalKey__c 기준 Upsert 처리
    */
    private void upsertMPPSPart(List<ABCGradeCalculationResult__c> calculateResultList) {
        System.debug('upsertMPPSPart : ');
        Set<String> matrixKeySet = new Set<String>();
        Set<String> mppsKeySet = new Set<String>();
        for(ABCGradeCalculationResult__c calculateResult : calculateResultList) {
            matrixKeySet.add(calculateResult.ABCIndicator__r.ExternalKey__c);
            List<String> externalKeys = calculateResult.ExternalKey__c.split('_');
            
            String mppsKey = externalKeys[0]+'_'+externalKeys[1]; 
            //externalKeys[0]_externalKeys[1] == DealerPartMasterByMPPS__c.ExternalKey__c <== '부품코드'_'대리점코드', AreaPartMasterByMPPS__c.ExternalKey__c <== '부품코드'_'지역코드'
            mppsKeySet.add(mppsKey);
        }
        
        Set<String> alreadyMppsKeySet = new Set<String>();
        switch on this.type{
            when DEALER {
                for(DealerPartMasterByMPPS__c mpps : [SELECT ExternalKey__c FROM DealerPartMasterByMPPS__c WHERE ExternalKey__c IN :mppsKeySet ]) {
                    alreadyMppsKeySet.add(mpps.ExternalKey__c);
                }
            }
            when REGION {
                for(AreaPartMasterByMPPS__c mpps : [SELECT ExternalKey__c FROM AreaPartMasterByMPPS__c WHERE ExternalKey__c IN :mppsKeySet ]) {
                    alreadyMppsKeySet.add(mpps.ExternalKey__c);
                }
            }
        }
        
        Map<String, ABCIndicatorMatrix__c> matrixMap = new Map<String, ABCIndicatorMatrix__c>();
        for(ABCIndicatorMatrix__c matrix  :[
            SELECT
                ABCIndicator__c, ExternalKey__c,
                Dealer__r.CustomerCode__c, Region__r.Area__c, Plant__c, AmountGrade__c, FrequencyGrade__c, FM_AreaCode__c, FM_DealerCode__c
            FROM ABCIndicatorMatrix__c WHERE ExternalKey__c IN :matrixKeySet
        ]) {
            matrixMap.put(matrix.ExternalKey__c, matrix);
        }

        List<DealerPartMasterByMPPS__c> dealerMPPSList = new List<DealerPartMasterByMPPS__c>();
        List<AreaPartMasterByMPPS__c> areaMPPSList = new List<AreaPartMasterByMPPS__c>();
        for(ABCGradeCalculationResult__c calculateResult : calculateResultList) {
            String matrixKey = calculateResult.ABCIndicator__r.ExternalKey__c;
            ABCIndicatorMatrix__c matrix = matrixMap.get(matrixKey);
            List<String> externalKeys = calculateResult.ExternalKey__c.split('_');
            String mppsKey = externalKeys[0]+'_'+externalKeys[1]; // DealerPartMasterByMPPS__c.ExternalKey__c <== '부품코드'_'대리점코드', AreaPartMasterByMPPS__c.ExternalKey__c <== '부품코드'_'지역코드'
            if(!alreadyMppsKeySet.contains(mppsKey)) continue; //TEST 할때만 잠시 주석처리

            switch on this.type{
                when DEALER {
                    DealerPartMasterByMPPS__c dealerMPPS = new DealerPartMasterByMPPS__c(
                        ExternalKey__c = mppsKey,
                        AmountGrade__c = calculateResult.AmountGrade__c,
                        FrequencyGrade__c = calculateResult.FrequencyGrade__c,
                        // Dealer__c = calculateResult.Dealer__c,
                        // DealerCode__c = calculateResult.DealerCode__c,
                        // Part__c = calculateResult.Part__c,
                        // PartCode__c = calculateResult.PartCode__c,
                        // Plant__c = calculateResult.Plant__c,
                        ABCIndicator__c = matrix.ABCIndicator__c
                    );
                    dealerMPPSList.add(dealerMPPS);
                }
                when REGION {
                    AreaPartMasterByMPPS__c areaMPPS = new AreaPartMasterByMPPS__c(
                        ExternalKey__c = mppsKey,
                        AmountGrade__c = calculateResult.AmountGrade__c,
                        FrequencyGrade__c = calculateResult.FrequencyGrade__c,
                        // Area__c = calculateResult.Region__c,
                        // AreaCode__c = calculateResult.AreaCode__c,
                        // Plant__c = calculateResult.Plant__c,
                        // Part__c = calculateResult.Part__c,
                        // PartCode__c = calculateResult.PartCode__c,
                        ABCIndicator__c = matrix.ABCIndicator__c
                    );
                    areaMPPSList.add(areaMPPS);
                }
            }

        }
        if(dealerMPPSList.size() > 0) {
            try {
                upsert dealerMPPSList ExternalKey__c;    
                externalKeys.addAll(alreadyMppsKeySet);
            } catch (Exception e) {
                throw new CustomException(e);
            }
        }
        if(areaMPPSList.size() > 0) {
            try {
                upsert areaMPPSList ExternalKey__c;
                externalKeys.addAll(alreadyMppsKeySet);
            } catch (Exception e) {
                throw new CustomException(e);
            }
        }
    }

    /*
    * @ Method : finish
    * @ Description : 배치 종료 후 후속배치 실행
    */
    public void finish(Database.BatchableContext context){
        System.debug(' =============== DN_UpsertGradeMppsPart Batch finish ================');
        System.debug('배치 실행 완료');
        
        logger.insertLog();

        if(!Test.isRunningTest()) {
            //ROP 배치 계산
            switch on this.type{
                when DEALER {
                    DN_ROPCalculatorBatch ropCalBatch = new DN_ROPCalculatorBatch(DN_ROPCalculatorBatch.SummaryType.DEALER, externalKeys);
                    ropCalBatch.setTargetId(targetId).setRemainIds(remainIds);
                    Database.executeBatch(ropCalBatch);
                }
                when REGION {
                    DN_ROPCalculatorBatch ropCalBatch = new DN_ROPCalculatorBatch(DN_ROPCalculatorBatch.SummaryType.REGION, externalKeys);
                    ropCalBatch.setTargetId(targetId).setRemainIds(remainIds);
                    Database.executeBatch(ropCalBatch);
                }
            }
            
        }
    }

    public class CustomException extends Exception {}
}