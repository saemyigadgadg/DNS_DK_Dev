// IF-OPTY-032
public with sharing class IF_ERP_ProductBatchForRegionBaseCode 
                        implements Database.Batchable<IF_ERP_Product_Classes.IF_OPTY_032_Res_T_LIST> , 
                            Database.AllowsCallouts, 
                            Database.Stateful,
                            Schedulable{
                                
    /** Schedule
     *  String cronExp = '0 30 4 * * ?'; // 매일 04:30
     *  String jobName = 'IF_ERP_ProductBatchForPermittedItem_Schedule';
     *  IF_ERP_Product_Classes.IF_OPTY_032_Req req = new IF_ERP_Product_Classes.IF_OPTY_032_Req();
     *  System.schedule(jobName, cronExp, new IF_ERP_ProductBatch(req));
        */
        public void execute(SchedulableContext sc) {
            IF_ERP_Product_Classes.IF_OPTY_032_Req req = new IF_ERP_Product_Classes.IF_OPTY_032_Req();
  
            Date today = Date.today().addDays(-1);
            String requestParameter = today.year() + '-' + String.valueOf(today.month()).leftPad(2, '0') + '-' + String.valueOf(today.day()).leftPad(2, '0');
            req.I_SDATE     = requestParameter;
            req.I_EDATE     = requestParameter;

            IF_ERP_ProductBatchForRegionBaseCode instance = new IF_ERP_ProductBatchForRegionBaseCode(req);
            if(!Test.isRunningTest()) Database.executeBatch(instance);
        }


    /** Constructor
        */
        public IF_ERP_ProductBatchForRegionBaseCode(IF_ERP_Product_Classes.IF_OPTY_032_Req parameters) {
            this.parameters = parameters; 
        }

    /** Fields
        */
        private final IF_ERP_Product_Classes.IF_OPTY_032_Req parameters;   

    /** Batch Start
        */
        public Iterable<IF_ERP_Product_Classes.IF_OPTY_032_Res_T_LIST> start(Database.BatchableContext BC){
            IF_ERP_Product call = new IF_ERP_Product();
            IF_ERP_Product_Classes.IF_OPTY_032_Res resultDto  = call.IF_OPTY_032(parameters);
            
            // ** 성공 CASE
            if(resultDto.T_LIST.size() > 0){
               System.debug('call out success');
            } 
            // ** 실패 CASE
            
            System.debug('size : ' +  resultDto.T_LIST.size());
            return resultDto.T_LIST;
        }

    /** Batch execute
        */        
        public void execute(Database.BatchableContext BC, List<IF_ERP_Product_Classes.IF_OPTY_032_Res_T_LIST> scope){

            List<IF_Product__c> insertProductList = new List<IF_Product__c>();
            for(IF_ERP_Product_Classes.IF_OPTY_032_Res_T_LIST item : scope){
                IF_Product__c p = new IF_Product__c();
                p.REGION__c        = item.REGION;
                p.SATNR__c         = item.SATNR;
                p.SAKTX__c         = item.SAKTX;
                p.MATNR__c         = item.MATNR;
                p.MAKTX__c         = item.MAKTX;
                p.ATWTB__c         = item.ATWTB;
                p.ATWTB2__c        = item.ATWTB2;
                p.ATWTB5__c        = item.ATWTB5;
                p.ATWTB3__c        = item.ATWTB3;
                p.ATWTB4__c        = item.ATWTB4;
                
                p.FromInterfaceId__c = 'IF-OPTY-032';
                insertProductList.add(p);
            }
            
            if(insertProductList.size() > 0) insert insertProductList;
        }

    /**
     * Batch finish
        */            
        public void finish(Database.BatchableContext BC){
            DN_UpdateProductSpindleFromERPBatch batch = new DN_UpdateProductSpindleFromERPBatch();
            if(!Test.isRunningTest()) Database.executeBatch(batch);
        }

}