/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-25-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-25-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_ProductBatchForDealerBaseCode 
                        implements Database.Batchable<IF_ERP_Product_Classes.IF_OPTY_029_Res_T_O_LIST>, 
                            Database.AllowsCallouts, 
                            Database.Stateful,  
                            Schedulable {

/** 
 * Schedule
 *  String cronExp = '0 0 4 * * ?'; // 매일 04:00
 *  String jobName = 'IF_ERP_ProductBatchForDealerBaseCode_Schedule';
 *  IF_ERP_Product_Classes.IF_OPTY_029_Req req = new IF_ERP_Product_Classes.IF_OPTY_029_Req();
 *  System.schedule(jobName, cronExp, new IF_ERP_ProductBatchForDealerBaseCode(req));
    */
    public void execute(SchedulableContext sc) {
        IF_ERP_Product_Classes.IF_OPTY_029_Req req = new IF_ERP_Product_Classes.IF_OPTY_029_Req();

        Date today = Date.today().addDays(-1);
        String requestParameter = today.year() + '-' + String.valueOf(today.month()).leftPad(2, '0') + '-' + String.valueOf(today.day()).leftPad(2, '0');
        req.I_FROM_DAT     = requestParameter;
        req.I_TO_DAT       = requestParameter;

        IF_ERP_ProductBatchForDealerBaseCode instance = new IF_ERP_ProductBatchForDealerBaseCode(req);
        Database.executeBatch(instance);
    }

    private final IF_ERP_Product_Classes.IF_OPTY_029_Req parameters;  

/**
 * Constructor        
    */
    public IF_ERP_ProductBatchForDealerBaseCode(IF_ERP_Product_Classes.IF_OPTY_029_Req parameters) {
        this.parameters = parameters;
    }

/**
 * Batch Start
    */
    public List<IF_ERP_Product_Classes.IF_OPTY_029_Res_T_O_LIST> start(Database.BatchableContext BC){
        IF_ERP_Product instnace = new IF_ERP_Product();
        IF_ERP_Product_Classes.IF_OPTY_029_Res result  = instnace.IF_OPTY_029(this.parameters);
        System.debug(result);
        if(result.T_O_LIST.size() >  0) return result.T_O_LIST;

        System.debug('데이터가 존재하지 않습니다.');

        return new List<IF_ERP_Product_Classes.IF_OPTY_029_Res_T_O_LIST>();
    }

/**
 * Batch execute
    */
    public void execute(Database.BatchableContext BC, List<IF_ERP_Product_Classes.IF_OPTY_029_Res_T_O_LIST> scope){
        List<IF_Product__c> insertProductList = new List<IF_Product__c>();
        for(IF_ERP_Product_Classes.IF_OPTY_029_Res_T_O_LIST item : scope){
            IF_Product__c p = new IF_Product__c();
            p.ATWTB19__c       = item.ATWTB19;
            p.SATNR__c         = item.SATNR;
            p.SAKTX__c         = item.SAKTX;
            p.MATNR__c         = item.MATNR;
            p.MAKTX__c         = item.MAKTX;
            p.ATWTB13__c       = item.ATWTB13;
            p.ATWTB__c         = item.ATWTB;
            p.ATWTB18__c       = item.ATWTB18;
            p.ATWTB15__c       = item.ATWTB15;
            p.ATWTB16__c       = item.ATWTB16;
            p.ATWTB17__c       = item.ATWTB17;
            p.ATWTB20__c       = item.ATWTB20;
            p.ZDATE__c         = item.ZDATE;
            
            // 2025.04.03 이전 맵핑
            // p.MANDT__c         = item.MANDT;
            // p.REGION__c        = item.REGION;
            // p.SATNR__c         = item.SATNR;
            // p.SAKTX__c         = item.SAKTX;
            // p.MATNR__c         = item.MATNR;
            // p.MAKTX__c         = item.MAKTX;
            // p.ATWTB__c         = item.ATWTB;
            // p.ATWTB2__c        = item.ATWTB2;
            // p.ATWTB5__c        = item.ATWTB5;
            // p.ATWTB3__c        = item.ATWTB3;
            // p.ATWTB4__c        = item.ATWTB4;
            
            p.FromInterfaceId__c = 'IF-OPTY-029';
            insertProductList.add(p);
        }
        
        if(insertProductList.size() > 0) insert insertProductList;
    }

/**
 * Batch finish
    */            
    public void finish(Database.BatchableContext BC){
        DN_UpdateProductSpindleFromERPBatch2 batch = new DN_UpdateProductSpindleFromERPBatch2();
        if(!Test.isRunningTest()) Database.executeBatch(batch);
    }

}