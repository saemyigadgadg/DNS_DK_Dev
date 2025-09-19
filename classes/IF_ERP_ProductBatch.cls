/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-18-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-18-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_ProductBatch 
                    implements Database.Batchable<IF_ERP_Product_Classes.IF_OPTY_002_Res_T_LIST> , 
                    Database.AllowsCallouts, 
                    Database.Stateful,  
                    Schedulable{
    /** 
     * Schedule
     *  String cronExp = '0 30 0 * * ?'; // 매일 00:30
     *  String jobName = 'MidnightBatchJob';
     *  IF_ERP_Product_Classes.IF_OPTY_002_Req req = new IF_ERP_Product_Classes.IF_OPTY_002_Req();
     *  System.schedule(jobName, cronExp, new IF_ERP_ProductBatch(req));
        */
        public void execute(SchedulableContext sc) {
            IF_ERP_Product_Classes.IF_OPTY_002_Req req = new IF_ERP_Product_Classes.IF_OPTY_002_Req();
  
            Date today = Date.today();

            String requestParameter = today.year() + '-' + String.valueOf(today.month()).leftPad(2, '0') + '-' + String.valueOf(today.day()).leftPad(2, '0');
            req.I_SDATE     = requestParameter;
            req.I_EDATE     = requestParameter;
            req.I_CODE      = 'R';
            req.I_ROW       = '5000';

            IF_ERP_ProductBatch instance = new IF_ERP_ProductBatch();
            instance.req = req;
            Database.executeBatch(instance);
        }

    /**
     * Constructor        
        */
        public IF_ERP_ProductBatch() {}

    /**
     * fields
        - request
            * startDateStr
            * endDateStr

        */
        public IF_ERP_Product_Classes.IF_OPTY_002_Req req;   
        public List<IF_ERP_Product_Classes.IF_OPTY_002_Res_T_LIST> resT_LIST; 

    /**
     * Batch Start
        */
        public Iterable<IF_ERP_Product_Classes.IF_OPTY_002_Res_T_LIST> start(Database.BatchableContext BC){
            IF_ERP_Product call = new IF_ERP_Product();
            this.resT_LIST = call.IF_OPTY_002(this.req).T_LIST;

            return this.resT_LIST;
        }

    /**
     * Batch execute
        */        
        public void execute(Database.BatchableContext BC, List<IF_ERP_Product_Classes.IF_OPTY_002_Res_T_LIST> scope){

            List<IF_Product__c> insertProductList = new List<IF_Product__c>();
            for(IF_ERP_Product_Classes.IF_OPTY_002_Res_T_LIST m : scope){
                System.debug(m);
                IF_Product__c p = new IF_Product__c();
                p.MATNR__c = m.MATNR;
                p.MAKTX__c = m.MAKTX;
                p.MATKL__c = m.MATKL;
                p.WGBEZ__c = m.WGBEZ;
                p.MTART__c = m.MTART;
                p.MTBEZ__c = m.MTBEZ;
                p.MEINS__c = m.MEINS;
                p.SATNR__c = m.SATNR;
                p.WERKS__c = m.WERKS;
                p.LGPRO__c = m.LGPRO;
                p.EKGRP__c = m.EKGRP;
                p.VKORG__c = m.VKORG;
                p.VTWEG__c = m.VTWEG;
                p.SPART__c = m.SPART;
                p.MILVE__c = m.MILVE;
                p.HE_INDICATOR__c	 = m.HE_INDICATOR;
                p.FromInterfaceId__c = 'IF-OPTY-002';
                insertProductList.add(p);
            }
            System.debug(JSON.serialize(insertProductList));
            if(insertProductList.size() > 0) insert insertProductList;
        }

    /**
     * Batch finish
        */            
        public void finish(Database.BatchableContext BC){

            if(resT_LIST.size() > 0 && this.req.I_CODE == 'R'){
                IF_ERP_ProductBatch batch = new IF_ERP_ProductBatch();
                batch.req = this.req;
                if(!Test.isRunningTest()) Database.executeBatch(batch);
            }else{

                if(!isProductUpdateBatchRunning()){
                    DN_UpdateProductFromERPBatch batch = new DN_UpdateProductFromERPBatch();
                    if(!Test.isRunningTest()) Database.executeBatch(batch, 10);
                }
            }
        }

    public static Boolean isProductUpdateBatchRunning() {
        List<AsyncApexJob> jobs = [
            SELECT Id, ApexClass.Name, Status
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'DN_UpdateProductFromERPBatch'
            AND Status IN ('Processing', 'Queued', 'Preparing')
        ];

        return !jobs.isEmpty();
    }
}