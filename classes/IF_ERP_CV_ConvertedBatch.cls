global with sharing class IF_ERP_CV_ConvertedBatch 
                                    implements Database.Batchable<SObject>, 
                                    Database.AllowsCallouts, 
                                    Database.Stateful  {
    public IF_ERP_CV_ConvertedBatch() {}


    public Iterable<SObject> start(Database.BatchableContext BC){
        String objectNm = 'IF_CV__c';
        List<SObject> records;

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
            .get(objectNm)
            .getDescribe()
            .fields.getMap();

        String queryFields = String.join(new List<String>(fieldMap.keySet()), ', ');
        String query       = 'SELECT ' + queryFields + ' FROM ' + objectNm + ' WHERE IsConverted__c = false';

        return  Database.query(query);                
    }


    public void execute(Database.BatchableContext BC, List<SObject> scope){
        // IF_CV__c 로 변환 
        List<IF_CV__c> cvList = (List<IF_CV__c>)scope;

        // 기존에 SQ_Pricing__c 추출 
        Map<String,SQ_Pricing__c> getSqPricingMap = getSQPricingMap(cvList); 

        // UPSERT 할 리스트
        Map<String,SQ_Pricing__c> upsertMap = new Map<String,SQ_Pricing__c>();


        for(IF_CV__c cv : cvList) {
            String regionNm = cv.REGIONT__c;
            cv.IsConverted__c = true;

            SQ_Pricing__c pricing;

            if(regionNm == null){
                System.debug('regionNm 이 존재하지 않는 경우 error');
                continue;
            }
            else if(getSqPricingMap.containskey(regionNm)){
                pricing = getSqPricingMap.get(regionNm);
            }
            else{
                pricing = new SQ_Pricing__c();
            }

            try{
                pricing.Name                    = cv.REGION__c;
                pricing.CurrencyIsoCode         = cv.WAERK__c;
                pricing.Rate__c                 = Decimal.valueOf(cv.AOP__c);
                pricing.Markup__c               = Decimal.valueOf(cv.MAGRATE__c);
                pricing.Land__c                 = cv.LAND1__c;    // nullable
                pricing.RegionName__c           = cv.REGIONT__c;    // nullable
                pricing.UsingConditionTable__c  = cv.GSTRU__c;
    
                upsertMap.put(pricing.RegionName__c, pricing);
                getSqPricingMap.put(pricing.RegionName__c, pricing);
            }
            catch(Exception e){
                System.debug('IF_ERP_CV_ConvertedBatch :::: error');
                continue;
            }

        }

        upsert upsertMap.values();
        upsert cvList;

    }

    public void finish(Database.BatchableContext BC){   

    }


//? IF_CV__c Map 추출
    public Map<String,SQ_Pricing__c> getSQPricingMap(List<IF_CV__c> scope) {
        Set<String> regionTitles = new Set<String>(); 

        for(IF_CV__c cv: scope) {
            if(cv.REGIONT__c != null) {
                regionTitles.add(cv.REGIONT__c);
            }
        }

        Map<String,SQ_Pricing__c> sqPricingMap = new Map<String,SQ_Pricing__c>();

        for(SQ_Pricing__c pricing : [SELECT Id, Name, CurrencyIsoCode, Rate__c, Markup__c, 
                Land__c, RegionName__c, UsingConditionTable__c 
                FROM SQ_Pricing__c where RegionName__c IN : regionTitles] ){
            sqPricingMap.put(pricing.RegionName__c, pricing);
        }

        return sqPricingMap;
    } 
}