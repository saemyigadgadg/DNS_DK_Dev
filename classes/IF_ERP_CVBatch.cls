global with sharing class IF_ERP_CVBatch 
                    implements Database.Batchable<Object>, 
                            Database.AllowsCallouts, 
                            Database.Stateful,
                            Schedulable{

    /** 
     * Schedule
     *  String cronExp = '0 0 3 * * ?'; // 매일 03:00
     *  String jobName = 'IF_ERP_CVBatch_Schedule';';
     *  System.schedule(jobName, cronExp, new IF_ERP_CVBatch());
        */
        public void execute(SchedulableContext sc) {
            IF_ERP_CVBatch instance = new IF_ERP_CVBatch();
            if(!Test.isRunningTest()) Database.executeBatch(instance);
        }
    
    /**
     * Constructor        
        */                            
        public IF_ERP_CVBatch() {}

    /**
     * Batch Start
        */
        public Iterable<Object> start(Database.BatchableContext BC){
            List<Object> returnList = new List<Object>();
            IF_ERP_Product call = new IF_ERP_Product();
            IF_ERP_Product_Classes.IF_OPTY_027_Res result  = call.IF_OPTY_027();
            returnList = result.T_LIST;
            // ** 성공 CASE
            if(returnList.size() > 0){
                System.debug('call out success');
                return returnList;
            } 
            // ** 실패 CASE
            return null;
        }
    
    /**
     * Batch execute
        */        
        public void execute(Database.BatchableContext BC, List<Object> scope){
            List<IF_CV__c> insertCVList = new List<IF_CV__c>();

            List<IF_ERP_Product_Classes.IF_OPTY_027_Res_T_LIST> T_LIST = (List<IF_ERP_Product_Classes.IF_OPTY_027_Res_T_LIST>) scope;
            for(IF_ERP_Product_Classes.IF_OPTY_027_Res_T_LIST tl : T_LIST){
                IF_CV__c cv = new IF_CV__c();

                cv.MANDT__c = tl.MANDT;
                cv.REGION__c = tl.REGION;
                cv.WAERK__c = tl.WAERK;
                cv.LAND1__c = tl.LAND1;
                cv.VKORG__c = tl.VKORG;
                cv.VTWEG__c = tl.VTWEG;
                cv.KUNNR__c = tl.KUNNR;
                cv.REGIONT__c = tl.REGIONT;
                cv.AOP__c = tl.AOP;
                cv.MAGRATE__c = tl.MAGRATE;
                cv.GSTRU__c = tl.GSTRU;
                cv.SORTF__c = tl.SORTF;

                insertCVList.add(cv);
            }

            if(insertCVList.size() > 0) insert insertCVList;
        }
    
    /**
     * Batch finish
        */            
        public void finish(Database.BatchableContext BC){
            IF_ERP_CV_ConvertedBatch batch = new IF_ERP_CV_ConvertedBatch();
            if(!Test.isRunningTest()) Database.executeBatch(batch);
        }
}