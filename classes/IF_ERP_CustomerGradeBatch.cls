/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2024-12-20
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-20   yuhyun.park@sbtglobal.com   Initial Version
**/
global with sharing class IF_ERP_CustomerGradeBatch 
                    implements Database.Batchable<IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST>, 
                            Database.AllowsCallouts, 
                            Database.Stateful,
                            Schedulable{
    /** Schedule
     *  String cronExp = '0 0 1 * * ?'; // 매일 04:30
     *  String jobName = 'IF_ERP_CustomerGradeBatch_Schedule';
     *  IF_ERP_Account_Classes.IF_ACCOUNT_017_Req req = new IF_ERP_Account_Classes.IF_ACCOUNT_017_Req();
     *  System.schedule(jobName, cronExp, new IF_ERP_CustomerGradeBatch(req));
        */
        public void execute(SchedulableContext sc) {
            IF_ERP_Account_Classes.IF_ACCOUNT_017_Req req = new IF_ERP_Account_Classes.IF_ACCOUNT_017_Req();
  
            Date today = Date.today().addDays(-1);
            String requestParameter = today.year() + '-' + String.valueOf(today.month()).leftPad(2, '0') + '-' + String.valueOf(today.day()).leftPad(2, '0');
            req.I_FROMDATE     = requestParameter;
            req.I_TODATE       = requestParameter;

            IF_ERP_CustomerGradeBatch instance = new IF_ERP_CustomerGradeBatch(req);
            if(!Test.isRunningTest()) Database.executeBatch(instance);
        }

    /**
     * Constructor        
        */      
        public IF_ERP_CustomerGradeBatch(IF_ERP_Account_Classes.IF_ACCOUNT_017_Req parameters) {
            this.parameters = parameters;
            // this.parameters.I_FROMDATE  = '2024-01-01';
            // this.parameters.I_TODATE    = '2024-06-30';
        }

    /**
     * fields
        - request
            * I_FROMDATE
            * I_TODATE
        */
        private final IF_ERP_Account_Classes.IF_ACCOUNT_017_Req parameters; 

    /**
     * Batch Start
        */
        public Iterable<IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST> start(Database.BatchableContext BC){
            
            IF_ERP_Account call = new IF_ERP_Account();
            IF_ERP_Account_Classes.IF_ACCOUNT_017_Res result  = call.IF_ACCOUNT_017(parameters);
            List<IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST> returnList = new List<IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST>(); 
            returnList = result.T_LIST;
            // ** 성공 CASE
            return returnList;
        }

    /**
     * Batch execute
        */        
        public void execute(Database.BatchableContext BC, List<IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST> scope){

            List<IF_CustomerGrade__c>                               insertCGList = new List<IF_CustomerGrade__c>();
            List<IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST>  T_LIST       = (List<IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST>) scope;
            Set<String>                                             keys         = new Set<String>();

            if(T_LIST.size() > 0){
                for(IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST tl : T_LIST){
                    keys.add(tl.KUNNR);
                }
    
                Map<String,IF_CustomerGrade__c> findMap     = findIfCustomerGrade(keys);
                Map<String,IF_CustomerGrade__c> resultMap   = new Map<String,IF_CustomerGrade__c>();
                
                for(IF_ERP_Account_Classes.IF_ACCOUNT_017_Res_T_LIST tl : T_LIST){
                    
                    String key = tl.KUNNR;
                    IF_CustomerGrade__c customerGrade;
                    if( resultMap.containsKey(key) ){
                        customerGrade = resultMap.get(key);
                    }
                    else if(findMap.containsKey(key)){
                        customerGrade = findMap.get(key);
                        if( customerGrade.KVGR4__c != tl.KVGR4 ){
                            customerGrade.MANDT__c = tl.MANDT;customerGrade.VKORG__c = tl.VKORG;customerGrade.VTWEG__c = tl.VTWEG;customerGrade.SPART__c = tl.SPART;customerGrade.KUNNR__c = tl.KUNNR;customerGrade.NAME1__c = tl.NAME1;customerGrade.KVGR4__c = tl.KVGR4;customerGrade.DATBI__c = tl.DATBI;customerGrade.DATAB__c = tl.DATAB;customerGrade.IsConverted__c = false;
                        } 
                    }
                    else{
                        customerGrade = new IF_CustomerGrade__c();
                        customerGrade.MANDT__c = tl.MANDT;customerGrade.VKORG__c = tl.VKORG;customerGrade.VTWEG__c = tl.VTWEG;customerGrade.SPART__c = tl.SPART;customerGrade.KUNNR__c = tl.KUNNR;customerGrade.NAME1__c = tl.NAME1;customerGrade.KVGR4__c = tl.KVGR4;customerGrade.DATBI__c = tl.DATBI;customerGrade.DATAB__c = tl.DATAB;customerGrade.IsConverted__c = false;
                    }
    
                    if( !customerGrade.IsConverted__c ){
                        resultMap.put(customerGrade.KUNNR__c,customerGrade);
                    }
                }
    
                insertCGList = resultMap.values();
    
                upsert insertCGList;
            }
            else{
                System.debug('There is no customer grade information available : list size 0');
            }
        }

    /**
     * Batch finish
        */            
        public void finish(Database.BatchableContext BC){
            DN_DealerGradeUpdateBatch batch = new DN_DealerGradeUpdateBatch();
            if(!Test.isRunningTest()) Database.executeBatch(batch);
        }

        public Map<String,IF_CustomerGrade__c> findIfCustomerGrade(Set<String> keys){
            Map<String,IF_CustomerGrade__c> findIfCustomerGrade = new Map<String,IF_CustomerGrade__c>();
            for(IF_CustomerGrade__c ifObj : [
                SELECT MANDT__c, VKORG__c, VTWEG__c, SPART__c, KUNNR__c, NAME1__c, KVGR4__c, DATBI__c, DATAB__c, CreatedDate,LastModifiedDate
                FROM IF_CustomerGrade__c
                WHERE KUNNR__c IN :keys
                AND (CreatedDate = TODAY OR LastModifiedDate = TODAY)
            ]){
                findIfCustomerGrade.put(ifObj.KUNNR__c, ifObj);
            }
            return findIfCustomerGrade;
        } 
}