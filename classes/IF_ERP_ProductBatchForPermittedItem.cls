/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-10-2025
 * @last modified by  : JangJunHee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-14-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_ProductBatchForPermittedItem
                        implements Database.Batchable<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST> , 
                            Database.AllowsCallouts, 
                            Database.Stateful,
                            Schedulable{
    /** Schedule
     *  String cronExp = '0 0 5 * * ?'; // 매일 05:00
     *  String jobName = 'IF_ERP_ProductBatchForPermittedItem_Schedule';
     *  IF_ERP_Product_Classes.IF_OPTY_030_Req req = new IF_ERP_Product_Classes.IF_OPTY_030_Req();
     *  System.schedule(jobName, cronExp, new IF_ERP_ProductBatch(req));
        */
        public void execute(SchedulableContext sc) {
            IF_ERP_Product_Classes.IF_OPTY_030_Req req = new IF_ERP_Product_Classes.IF_OPTY_030_Req();
            
            // String yearString = String.valueOf(year);
            DateTime toDatetime = DateTime.newInstanceGmt(System.today(), Time.newInstance(0, 0, 0, 0));            
            String toDateString = toDatetime.formatGmt('yyyy-MM-dd');

            req.I_FROM     = '2010-01-01';
            req.I_TO       = toDateString;  
            req.I_VKORG    = '1800';
            req.I_LAND1    = 'KR';

            IF_ERP_ProductBatchForPermittedItem instance = new IF_ERP_ProductBatchForPermittedItem();
            instance.req = req;
            if(!Test.isRunningTest()) Database.executeBatch(instance);
        }
    
    /** Constructor
        */
        public IF_ERP_ProductBatchForPermittedItem() {}

    /** Fields
        */
        public IF_ERP_Product_Classes.IF_OPTY_030_Req req;   
        public IF_ERP_Product_Classes.IF_OPTY_030_Res res;   
        // public Integer year = 2013;
        // public Date currentDate =  Date.newInstance(2013, 01, 01);
        // public Integer quater = 1;
        // public Map<Integer, List<String>> quaterMap = new Map<Integer, List<String>>{1 => new List<String>{'01-01','03-31'},
        //                                                                            2 => new List<String>{'04-01','06-31'}, 
        //                                                                            3 => new List<String>{'07-01','09-31'}, 
        //                                                                            4 => new List<String>{'10-01','12-31'}};

    /** Batch Start
        */
        public Iterable<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST> start(Database.BatchableContext BC){
            
            IF_ERP_Product call = new IF_ERP_Product();
            if(this.res == null) this.res  = call.IF_OPTY_030(this.req);
            
            
            return this.res.T_LIST;
        }

    /** Batch execute
        */
        public void execute(Database.BatchableContext BC, List<IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST> scope){

            List<IF_Product__c> insertProductList = new List<IF_Product__c>();
            for(IF_ERP_Product_Classes.IF_OPTY_030_Res_T_LIST item : scope){
                IF_Product__c p = new IF_Product__c();
                p.MANDT__c = item.MANDT;
                p.VKORG__c = item.VKORG;
                p.VTWEG__c = item.VTWEG;
                p.SPART__c = item.SPART;
                p.KUNNR__c = item.KUNNR;
                p.MATNR__c = item.MATNR;
                p.MALNR__c = item.MALNR;
                p.ZMDDESC__c = item.ZMDDESC;
                p.DEIND__c = item.DEIND;
                p.ERDAT__c = item.ERDAT;
                p.ERNAM__c = item.ERNAM;
                p.ERZET__c = item.ERZET;
                p.AEDAT__c = item.AEDAT;
                p.AENAM__c = item.AENAM;
                p.AEZET__c = item.AEZET;
                
                p.FromInterfaceId__c = 'IF-OPTY-030';
                insertProductList.add(p);
            }
            
            if(insertProductList.size() > 0) insert insertProductList;
        }

    /** Batch finish
        */
        public void finish(Database.BatchableContext BC){
            // if(year == System.now().year()){
                DN_UpdateProductActiveFromERPBatch batch = new DN_UpdateProductActiveFromERPBatch();
                if(!Test.isRunningTest()) Database.executeBatch(batch);
            // }
            // else{
                // IF_ERP_Product_Classes.IF_OPTY_030_Req req = new IF_ERP_Product_Classes.IF_OPTY_030_Req();

                // currentDate = currentDate.addMonths(1);

                // List<String> inputList = getFromToDate(currentDate);
                // String I_F = inputList[0];
                // String I_T = inputList[1];

                // req.I_FROM     = I_F;
                // req.I_TO       = I_T;                
    
                // IF_ERP_ProductBatchForPermittedItem instance = new IF_ERP_ProductBatchForPermittedItem();
                // instance.req = req;
                // instance.year = year;
				// instance.currentDate = currentDate;
                // if(!Test.isRunningTest()) Database.executeBatch(instance);
				
				// IF_ERP_Product_Classes.IF_OPTY_030_Req req = new IF_ERP_Product_Classes.IF_OPTY_030_Req();
                
                // System.debug(quater);            
                
                // quater = (quater + 1)  / 5 == 1 ? 1 : Math.mod(quater + 1, 5);                
                // if(quater == 1) year += 1;                
                // System.debug(quater);
                // String yearString = String.valueOf(year);

                // String I_F = yearString + quaterMap.get(quater)[0];
                // String I_T = yearString + quaterMap.get(quater)[1];
                // req.I_FROM     = I_F;
                // req.I_TO       = I_T;                
    
                // IF_ERP_ProductBatchForPermittedItem instance = new IF_ERP_ProductBatchForPermittedItem();
                // instance.req = req;
                // instance.year = year;
                // instance.quater = quater;
                // if(!Test.isRunningTest()) Database.executeBatch(instance);
            // }
            
        }

//         public List<String> getFromToDate(Date currentDate){
            
//             Date fromDate = currentDate;
//             Date toDate = currentDate.addMonths(1).addDays(-1);
//             System.debug(fromDate);
//             System.debug(toDate);
//             DateTime fromDatetime = DateTime.newInstanceGmt(fromDate, Time.newInstance(0, 0, 0, 0));
//             DateTime toDatetime = DateTime.newInstanceGmt(toDate, Time.newInstance(0, 0, 0, 0));
//             System.debug(fromDatetime);
//             System.debug(toDatetime);
//             String fromDateString = fromDatetime.formatGmt('yyyy-MM-dd');
//             String toDateString = toDatetime.formatGmt('yyyy-MM-dd');

//             String I_F = fromDateString;
//             String I_T = toDateString;
//             return new List<String>{I_F,I_T};
//         }
}