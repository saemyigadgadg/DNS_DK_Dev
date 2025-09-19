public with sharing class IF_ERP_ProductBatchForDNSAModel 
                    implements Database.Batchable<IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res_T_LIST> , 
                        Database.AllowsCallouts, 
                        Database.Stateful,
                        Schedulable{

    /** Schedule
     *  String cronExp = '0 30 0 * * ?'; // 매일 00:30
     *  String jobName = 'IF_ERP_ProductBatchForDNSAModel_Schedule';
     *  IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req req = new IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req();
     *  System.schedule(jobName, cronExp, new IF_ERP_ProductBatch(req));
        */
        public void execute(SchedulableContext sc) {
            IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req req = new IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req();
            
            // String yearString = String.valueOf(year);
            DateTime toDatetime = DateTime.newInstanceGmt(System.today(), Time.newInstance(0, 0, 0, 0));            
            String toDateString = toDatetime.formatGmt('yyyy-MM-dd');

            String I_F = toDateString;
            String I_T = toDateString;

            req.I_FROM     = I_F;
            req.I_TO       = I_T;  

            IF_ERP_ProductBatchForDNSAModel instance = new IF_ERP_ProductBatchForDNSAModel();
            instance.req = req;
            if(!Test.isRunningTest()) Database.executeBatch(instance);
        }

    /** Constructor
        */
        public IF_ERP_ProductBatchForDNSAModel() {}

    /** Fields
        */
        public IF_ERP_SalesOrder_Classes.IF_OPTY_033_Req req;   
        public IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res res;   

    /** Batch Start
        */
        public Iterable<IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res_T_LIST> start(Database.BatchableContext BC){
            
            IF_ERP_SalesOrder call = new IF_ERP_SalesOrder();
            if(this.res == null) this.res  = call.IF_OPTY_033(this.req);
            
            return this.res.T_LIST;
        }
 
    /** Batch execute
        */
        public void execute(Database.BatchableContext BC, List<IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res_T_LIST> scope){

            List<IF_Product__c> insertProductList = new List<IF_Product__c>();
            for(IF_ERP_SalesOrder_Classes.IF_OPTY_033_Res_T_LIST item : scope){
                IF_Product__c p = new IF_Product__c();

                p.BASE_CODE__c  = item.BASE_CODE;
                p.ZZSQ__c       = item.ZZSQ;
                p.MDLNM__c      = item.MDLNM;
                p.SATNR__c      = item.SATNR;
                p.AEDAT__c      = item.AEDAT;
                
                p.FromInterfaceId__c = 'IF-OPTY-033';
                insertProductList.add(p);
            }
            
            if(insertProductList.size() > 0) insert insertProductList;
        }

    /** Batch finish
        */
        public void finish(Database.BatchableContext BC){
            DN_UpdateDNSAModelFromERPBatch batch = new DN_UpdateDNSAModelFromERPBatch();
            if(!Test.isRunningTest()) Database.executeBatch(batch);
        }

}