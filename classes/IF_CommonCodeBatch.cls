/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-19-2024
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-19-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_CommonCodeBatch 
                    implements Database.Batchable<ifObject>, 
                    Database.AllowsCallouts, 
                    Database.Stateful,
                    Schedulable {
    /**
     * Constructor        
        */
        public IF_CommonCodeBatch(IF_ERP_CommonCode.IF_COMMONCODE_Req parameters) {
            this.parameters = parameters;
        }

    /**
     * Wrapper
        */
        private class ifObject{
            private String objectName;
            private IF_ERP_CommonCode.T_CURRCODE        T_CURRCODE;
            private IF_ERP_CommonCode.T_COUNTNAM        T_COUNTNAM;
            private IF_ERP_CommonCode.T_MTMAJCAT1       T_MTMAJCAT1;
            private IF_ERP_CommonCode.T_MTMAJCAT2       T_MTMAJCAT2;
            private IF_ERP_CommonCode.T_SALESORG        T_SALESORG;
            private IF_ERP_CommonCode.T_DISTCHNL        T_DISTCHNL;
            private IF_ERP_CommonCode.T_DIVISION        T_DIVISION;
            private IF_ERP_CommonCode.T_INCOTERMS       T_INCOTERMS;
            private IF_ERP_CommonCode.T_ACCOUNTGR       T_ACCOUNTGR;
            private IF_ERP_CommonCode.T_PAYTERMS        T_PAYTERMS;
            private IF_ERP_CommonCode.T_FIAGENCY        T_FIAGENCY;
            private IF_ERP_CommonCode.T_SALESDIS        T_SALESDIS;
            private IF_ERP_CommonCode.T_CUSTOMGR        T_CUSTOMGR;
            private IF_ERP_CommonCode.T_SALESOFF        T_SALESOFF;
            private IF_ERP_CommonCode.T_ORDERTYPE       T_ORDERTYPE;
            private IF_ERP_CommonCode.T_ORDERTYPE2      T_ORDERTYPE2;
            private IF_ERP_CommonCode.T_CUSTPPRC        T_CUSTPPRC;
            private IF_ERP_CommonCode.T_PRICELIST       T_PRICELIST;
            private IF_ERP_CommonCode.T_SHIPCOND        T_SHIPCOND;
            private IF_ERP_CommonCode.T_DELPALNT        T_DELPALNT;
            private IF_ERP_CommonCode.T_REGION          T_REGION;
            private IF_ERP_CommonCode.T_REJECTRSN       T_REJECTRSN;
        }

    /** schedule
     *  String cronExp = '0 0 * * * ?'; // 매시간 정각
     *  String jobName = 'IF_CommonCodeBatch_Schedule';
     *  System.schedule(jobName, cronExp, new IF_CommonCodeBatch());
        */
        public void execute(SchedulableContext sc) {
            IF_ERP_CommonCode.IF_COMMONCODE_Req req = new IF_ERP_CommonCode.IF_COMMONCODE_Req();
            req.I_CURRCODE = 'X';
            req.I_COUNTNAM = 'X';
            req.I_MTMAJCAT = 'X';
    
            IF_CommonCodeBatch batch = new IF_CommonCodeBatch(req);
            Database.executeBatch(batch);
        }

    /**
     * fields
        - request
            * startDateStr
            * endDateStr

        */
        private final IF_ERP_CommonCode.IF_COMMONCODE_Req parameters;  

    /**
     * Batch Start
        */
        public Iterable<ifObject> start(Database.BatchableContext BC){
            List<ifObject> returnList = new List<ifObject>();
            IF_ERP_CommonCode call = new IF_ERP_CommonCode();
            IF_ERP_CommonCode.IF_COMMONCODE_Res result  = call.MIG_006(parameters);

            for (IF_ERP_CommonCode.T_CURRCODE T_CURRCODE : result.T_CURRCODE) {
                System.debug('T_CURRCODE');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_CURRCODE';
                ifObject.T_CURRCODE         = T_CURRCODE;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_COUNTNAM T_COUNTNAM : result.T_COUNTNAM) {
                System.debug('T_COUNTNAM');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_COUNTNAM';
                ifObject.T_COUNTNAM         = T_COUNTNAM;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_MTMAJCAT1 T_MTMAJCAT1 : result.T_MTMAJCAT1) {
                System.debug('T_MTMAJCAT1');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_MTMAJCAT1';
                ifObject.T_MTMAJCAT1        = T_MTMAJCAT1;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_MTMAJCAT2 T_MTMAJCAT2 : result.T_MTMAJCAT2) {
                System.debug('T_MTMAJCAT2');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_MTMAJCAT2';
                ifObject.T_MTMAJCAT2        = T_MTMAJCAT2;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_SALESORG T_SALESORG : result.T_SALESORG) {
                System.debug('T_SALESORG');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_SALESORG';
                ifObject.T_SALESORG         = T_SALESORG;
                returnList.add(ifObject);
            }
            
            for (IF_ERP_CommonCode.T_DISTCHNL T_DISTCHNL : result.T_DISTCHNL) {
                System.debug('T_DISTCHNL');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_DISTCHNL';
                ifObject.T_DISTCHNL         = T_DISTCHNL;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_DIVISION T_DIVISION : result.T_DIVISION) {
                System.debug('T_DIVISION');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_DIVISION';
                ifObject.T_DIVISION         = T_DIVISION;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_INCOTERMS T_INCOTERMS : result.T_INCOTERMS) {
                System.debug('T_INCOTERMS');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_INCOTERMS';
                ifObject.T_INCOTERMS        = T_INCOTERMS;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_ACCOUNTGR T_ACCOUNTGR : result.T_ACCOUNTGR) {
                System.debug('T_ACCOUNTGR');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_ACCOUNTGR';
                ifObject.T_ACCOUNTGR        = T_ACCOUNTGR;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_PAYTERMS T_PAYTERMS : result.T_PAYTERMS) {
                System.debug('T_PAYTERMS');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_PAYTERMS';
                ifObject.T_PAYTERMS         = T_PAYTERMS;
                returnList.add(ifObject);
            }
            
            for (IF_ERP_CommonCode.T_FIAGENCY T_FIAGENCY : result.T_FIAGENCY) {
                System.debug('T_FIAGENCY');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_FIAGENCY';
                ifObject.T_FIAGENCY         = T_FIAGENCY;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_SALESDIS T_SALESDIS : result.T_SALESDIS) {
                System.debug('T_SALESDIS');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_SALESDIS';
                ifObject.T_SALESDIS         = T_SALESDIS;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_CUSTOMGR T_CUSTOMGR : result.T_CUSTOMGR) {
                System.debug('T_CUSTOMGR');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_CUSTOMGR';
                ifObject.T_CUSTOMGR         = T_CUSTOMGR;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_SALESOFF T_SALESOFF : result.T_SALESOFF) {
                System.debug('T_SALESOFF');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_SALESOFF';
                ifObject.T_SALESOFF         = T_SALESOFF;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_ORDERTYPE T_ORDERTYPE : result.T_ORDERTYPE) {
                System.debug('T_ORDERTYPE');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_ORDERTYPE';
                ifObject.T_ORDERTYPE        = T_ORDERTYPE;
                returnList.add(ifObject);
            }
            
            for (IF_ERP_CommonCode.T_ORDERTYPE2 T_ORDERTYPE2 : result.T_ORDERTYPE2) {
                System.debug('T_ORDERTYPE2');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_ORDERTYPE2';
                ifObject.T_ORDERTYPE2       = T_ORDERTYPE2;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_CUSTPPRC T_CUSTPPRC : result.T_CUSTPPRC) {
                System.debug('T_CUSTPPRC');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_CUSTPPRC';
                ifObject.T_CUSTPPRC         = T_CUSTPPRC;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_PRICELIST T_PRICELIST : result.T_PRICELIST) {
                System.debug('T_PRICELIST');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_PRICELIST';
                ifObject.T_PRICELIST        = T_PRICELIST;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_SHIPCOND T_SHIPCOND : result.T_SHIPCOND) {
                System.debug('T_SHIPCOND');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_SHIPCOND';
                ifObject.T_SHIPCOND         = T_SHIPCOND;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_DELPALNT T_DELPALNT : result.T_DELPALNT) {
                System.debug('T_DELPALNT');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_DELPALNT';
                ifObject.T_DELPALNT         = T_DELPALNT;
                returnList.add(ifObject);
            }
            
            for (IF_ERP_CommonCode.T_REGION T_REGION : result.T_REGION) {
                System.debug('T_REGION');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_REGION';
                ifObject.T_REGION           = T_REGION;
                returnList.add(ifObject);
            }
            for (IF_ERP_CommonCode.T_REJECTRSN T_REJECTRSN : result.T_REJECTRSN) {
                System.debug('T_REJECTRSN');
                ifObject ifObject = new ifObject();
                ifObject.objectName         = 'T_REJECTRSN';
                ifObject.T_REJECTRSN        = T_REJECTRSN;
                returnList.add(ifObject);
            }

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
        public void execute(Database.BatchableContext BC, List<ifObject> scope){
            
            List<IF_CommonCode__c> insertCList = new List<IF_CommonCode__c>();
            for(ifObject ifObject : scope) {
                if(ifObject.objectName == 'T_CURRCODE'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_CURRCODE i = ifObject.T_CURRCODE;
                    c.MANDT__c = i.MANDT;
                    c.WAERS__c = i.WAERS;
                    c.ISOCD__c = i.ISOCD;
                    c.LTEXT__c = i.LTEXT;
                    c.KTEXT__c = i.KTEXT;

                    c.ParameterName__c = 'T_CURRCODE';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_COUNTNAM'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_COUNTNAM i = ifObject.T_COUNTNAM;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.LAND1__c = i.LAND1;
                    c.LANDX__c = i.LANDX;
                    c.NATIO__c = i.NATIO;
                    c.LANDX50__c = i.LANDX50;
                    c.NATIO50__c = i.NATIO50;
                    c.PRQ_SPREGT__c = i.PRQ_SPREGT;

                    c.ParameterName__c = 'T_COUNTNAM';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_MTMAJCAT1'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_MTMAJCAT1 i = ifObject.T_MTMAJCAT1;
                    c.ZCRM_INDUS__c = i.ZCRM_INDUS;
                    c.ZCRM_INDUS_T__c = i.ZCRM_INDUS_T;

                    c.ParameterName__c = 'T_MTMAJCAT1';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_MTMAJCAT2'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_MTMAJCAT2 i = ifObject.T_MTMAJCAT2;
                    c.ZCRM_INDUS__c   = i.ZCRM_INDUS;
                    c.ZCRM_INDUS_T__c = i.ZCRM_INDUS_T;

                    c.ParameterName__c = 'T_MTMAJCAT2';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_SALESORG'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_SALESORG i = ifObject.T_SALESORG;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.VKORG__c = i.VKORG;
                    c.VTEXT__c = i.VTEXT;

                    c.ParameterName__c = 'T_SALESORG';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_DISTCHNL'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_DISTCHNL i = ifObject.T_DISTCHNL;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.VTWEG__c = i.VTWEG;
                    c.VTEXT__c = i.VTEXT;

                    c.ParameterName__c = 'T_DISTCHNL';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_DIVISION'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_DIVISION i = ifObject.T_DIVISION;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.SPART__c = i.SPART;
                    c.VTEXT__c = i.VTEXT;

                    c.ParameterName__c = 'T_DIVISION';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_INCOTERMS'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_INCOTERMS i = ifObject.T_INCOTERMS;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.INCO1__c = i.INCO1;
                    c.BEZEI__c = i.BEZEI;

                    c.ParameterName__c = 'T_INCOTERMS';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_ACCOUNTGR'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_ACCOUNTGR i = ifObject.T_ACCOUNTGR;
                    c.MANDT__c = i.MANDT;
                    c.KTOKD__c = i.KTOKD;
                    c.SPRAS__c = i.SPRAS;
                    c.TXT30__c = i.TXT30;

                    c.ParameterName__c = 'T_ACCOUNTGR';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_PAYTERMS'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_PAYTERMS i = ifObject.T_PAYTERMS;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.ZTERM__c = i.ZTERM;
                    c.ZTAGG__c = i.ZTAGG;
                    c.TEXT1__c = i.TEXT1;

                    c.ParameterName__c = 'T_PAYTERMS';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_FIAGENCY'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_FIAGENCY i = ifObject.T_FIAGENCY;
                    c.MANDT__c = i.MANDT;
                    c.BUKRS__c = i.BUKRS;
                    c.FA_CODE__c = i.FA_CODE;
                    c.FA_TEXT__c = i.FA_TEXT;
                    c.ERDAT__c = i.ERDAT;
                    c.ERNAM__c = i.ERNAM;
                    c.ERZET__c = i.ERZET;
                    c.AEDAT__c = i.AEDAT;
                    c.AENAM__c = i.AENAM;
                    c.AEZET__c = i.AEZET;

                    c.ParameterName__c = 'T_FIAGENCY';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_SALESDIS'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_SALESDIS i = ifObject.T_SALESDIS;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.BZIRK__c = i.BZIRK;
                    c.BZTXT__c = i.BZTXT;

                    c.ParameterName__c = 'T_SALESDIS';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_CUSTOMGR'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_CUSTOMGR i = ifObject.T_CUSTOMGR;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.KDGRP__c = i.KDGRP;
                    c.KTEXT__c = i.KTEXT;

                    c.ParameterName__c = 'T_CUSTOMGR';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_SALESOFF'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_SALESOFF i = ifObject.T_SALESOFF;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.VKBUR__c = i.VKBUR;
                    c.BEZEI__c = i.BEZEI;

                    c.ParameterName__c = 'T_SALESOFF';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_ORDERTYPE'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_ORDERTYPE i = ifObject.T_ORDERTYPE;
                    c.MANDT__c = i.MANDT;
                    c.VKORG__c = i.VKORG;
                    c.VTWEG__c = i.VTWEG;
                    c.SPART__c = i.SPART;
                    c.KDGRP__c = i.KDGRP;
                    c.AUART__c = i.AUART;
                    c.VBTYP__c = i.VBTYP;
                    c.STATUS__c = i.STATUS;

                    c.ParameterName__c = 'T_ORDERTYPE';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_ORDERTYPE2'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_ORDERTYPE2 i = ifObject.T_ORDERTYPE2;
                    c.AUART__c = i.AUART;
                    c.BEZEI__c = i.BEZEI;

                    c.ParameterName__c = 'T_ORDERTYPE2';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_CUSTPPRC'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_CUSTPPRC i = ifObject.T_CUSTPPRC;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.KALKS__c = i.KALKS;
                    c.VTEXT__c = i.VTEXT;

                    c.ParameterName__c = 'T_CUSTPPRC';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_PRICELIST'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_PRICELIST i = ifObject.T_PRICELIST;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.PLTYP__c = i.PLTYP;
                    c.PTEXT__c = i.PTEXT;

                    c.ParameterName__c = 'T_PRICELIST';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_SHIPCOND'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_SHIPCOND i = ifObject.T_SHIPCOND;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.VSBED__c = i.VSBED;
                    c.VTEXT__c = i.VTEXT;

                    c.ParameterName__c = 'T_SHIPCOND';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_DELPALNT'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_DELPALNT i = ifObject.T_DELPALNT;
                    c.MANDT__c = i.MANDT;
                    c.VKORG__c = i.VKORG;
                    c.VTWEG__c = i.VTWEG;
                    c.WERKS__c = i.WERKS;
                    c.NAME1__c = i.NAME1;

                    c.ParameterName__c = 'T_DELPALNT';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_REGION'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_REGION i = ifObject.T_REGION;
                    c.MANDT__c = i.MANDT;
                    c.SPRAS__c = i.SPRAS;
                    c.LAND1__c = i.LAND1;
                    c.BLAND__c = i.BLAND;
                    c.BEZEI__c = i.BEZEI;

                    c.ParameterName__c = 'T_REGION';
                    insertCList.add(c);
                }
                else if(ifObject.objectName == 'T_REJECTRSN'){
                    IF_CommonCode__c c = new IF_CommonCode__c();
                    IF_ERP_CommonCode.T_REJECTRSN i = ifObject.T_REJECTRSN;
                    c.ABGRU__c = i.ABGRU;
                    c.BEZEI__c = i.BEZEI;

                    c.ParameterName__c = 'T_REJECTRSN';
                    insertCList.add(c);
                }

            }
            
            if(insertCList.size() > 0) insert insertCList;
        }

    /**
     * Batch finish
        */            
        public void finish(Database.BatchableContext BC){
        }
}