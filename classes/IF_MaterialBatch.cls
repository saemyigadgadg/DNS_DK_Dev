/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-12-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-19-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_MaterialBatch 
                    implements Database.Batchable<ifObject>, 
                    Database.AllowsCallouts, 
                    Database.Stateful,
                    Schedulable{

    /** 
     * Schedule
     *  String cronExp = '1 30 0 * * ?'; // 매일 01:30
     *  String jobName = 'IF_MaterialBatch_Schedule';
     *  IF_ERP_Material_Classes.IF_CSPLUS_018_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_018_Req();
     *  System.schedule(jobName, cronExp, new IF_MaterialBatch(req));
        */
        public void execute(SchedulableContext sc) {
            IF_ERP_Material_Classes.IF_CSPLUS_018_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_018_Req();
  
            Date today = Date.today().addDays(-1);
            String requestParameter = today.year() + '-' + String.valueOf(today.month()).leftPad(2, '0') + '-' + String.valueOf(today.day()).leftPad(2, '0');
            req.I_FROM     = requestParameter;
            req.I_TO       = requestParameter;

            IF_MaterialBatch instance = new IF_MaterialBatch();
            instance.req = req;

            Database.executeBatch(instance);
        } 

    /**
     * Constructor
        */
        public IF_MaterialBatch() {}

    /**
     * Wrapper
        */
        private class ifObject{
            private String objectName;
            private IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_ITEM              T_ITEM;
            private IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_PARTNERS_INFO     T_PARTNERS_INFO;
            private IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT          T_DOCUMENT;
            private IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT_FILE     T_DOCUMENT_FILE;
        }

    /**
     * fields
        - request
            * startDateStr
            * endDateStr
        */
        public IF_ERP_Material_Classes.IF_CSPLUS_018_Req req;
        public IF_ERP_Material_Classes.IF_CSPLUS_018_Res res;
        private final String parameter;
        private Datetime batchExecuteTime;
        private Map<String, Integer> seqForDOKNR = new Map<String, Integer>();

    /**
     * Batch Start
        */
        public Iterable<ifObject> start(Database.BatchableContext BC){
            System.debug('IF_MaterialBatch Start');
            List<ifObject> returnList = new List<ifObject>();
            IF_ERP_Material call = new IF_ERP_Material();
            this.batchExecuteTime = Datetime.now();

            if(this.res == null) this.res = call.IF_CSPLUS_018(this.req);

            for (IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_ITEM T_ITEM : this.res.T_ITEM) {
                System.debug('T_ITEM');
                ifObject ifObject = new ifObject();
                ifObject.objectName        = 'T_ITEM';
                ifObject.T_ITEM            = T_ITEM;
                returnList.add(ifObject);
                System.debug('returnList.size ::: ' + returnList.size());
            }
            for (IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_PARTNERS_INFO T_PARTNERS_INFO : this.res.T_PARTNERS_INFO) {
                System.debug('T_PARTNERS_INFO');
                ifObject ifObject = new ifObject();
                ifObject.objectName        = 'T_PARTNERS_INFO';
                ifObject.T_PARTNERS_INFO   = T_PARTNERS_INFO;
                returnList.add(ifObject);
                System.debug('returnList.size ::: ' + returnList.size());
            }
            for (IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT T_DOCUMENT : this.res.T_DOCUMENT) {
                System.debug('T_DOCUMENT');
                ifObject ifObject = new ifObject();
                ifObject.objectName        = 'T_DOCUMENT';
                ifObject.T_DOCUMENT        = T_DOCUMENT;
                returnList.add(ifObject);
                System.debug('returnList.size ::: ' + returnList.size());
            }
            for (IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT_FILE T_DOCUMENT_FILE : this.res.T_DOCUMENT_FILE) {
                System.debug('T_DOCUMENT_FILE');
                ifObject ifObject = new ifObject();
                ifObject.objectName        = 'T_DOCUMENT_FILE';
                ifObject.T_DOCUMENT_FILE   = T_DOCUMENT_FILE;
                returnList.add(ifObject);
                System.debug('returnList.size ::: ' + returnList.size());
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
            System.debug('IF_MaterialBatch Execute');
            List<IF_Material__c> insertMList = new List<IF_Material__c>();
            for (ifObject ifObject : scope) {
                if(ifObject.objectName == 'T_ITEM'){
                    IF_Material__c m = new IF_Material__c();
                    IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_ITEM i = ifObject.T_ITEM;
                    m.EQUNR__c = i.EQUNR;
                    m.EQKTX__c = i.EQKTX;
                    m.TXT04__c = i.TXT04;
                    m.ATWRT__c = i.ATWRT;
                    m.INTERNAL_NOTE__c = i.INTERNAL_NOTE;
                    m.CLASS__c = i.IF_CLASS;
                    m.EQART__c = i.EQART;
                    m.EARTX__c = i.EARTX;
                    m.INBDT__c = i.INBDT;
                    m.ANSDT__c = i.ANSDT;
                    m.HERST__c = i.HERST;
                    m.HERLD__c = i.HERLD;
                    m.TYPBZ__c = i.TYPBZ;
                    m.BAUJJ__c = i.BAUJJ;
                    m.BAUMM__c = i.BAUMM;
                    m.ZZ_INST_START__c = i.ZZ_INST_START;
                    m.ZZ_INST_FINISH__c = i.ZZ_INST_FINISH;
                    m.SWERK__c = i.SWERK;
                    m.SWERK_TXT__c = i.SWERK_TXT;
                    m.BEBER__c = i.BEBER;
                    m.BEBER_TXT__c = i.BEBER_TXT;
                    m.LOC_ARBPL__c = i.LOC_ARBPL;
                    m.LOC_ARBPL_TXT__c = i.LOC_ARBPL_TXT;
                    m.NAME1__c = i.NAME1;
                    m.NAME2__c = i.NAME2;
                    m.STREET__c = i.STREET;
                    m.POST_CODE1__c = i.POST_CODE1;
                    m.CITY1__c = i.CITY1;
                    m.COUNTRY__c = i.COUNTRY;
                    m.REGION__c = i.REGION;
                    m.TEL_NUMBER__c = i.TEL_NUMBER;
                    m.BUKRS__c = i.BUKRS;
                    m.BUTXT__c = i.BUTXT;
                    m.GSBER__c = i.GSBER;
                    m.GTEXT__c = i.GTEXT;
                    m.IWERK__c = i.IWERK;
                    m.IWERK_TXT__c = i.IWERK_TXT;
                    m.INGRP__c = i.INGRP;
                    m.INNAM__c = i.INNAM;
                    m.ORG_ARBPL__c = i.ORG_ARBPL;
                    m.ORG_ARBPL_TXT__c = i.ORG_ARBPL_TXT;
                    m.WERKS__c = i.WERKS;
                    m.RBNR__c = i.RBNR;
                    m.RBNRX__c = i.RBNRX;
                    m.GWLDT__c = i.GWLDT;
                    m.GWLEN__c = i.GWLEN;
                    m.MGANR__c = i.MGANR;
                    m.GAKTX__c = i.GAKTX;
                    m.STRATEGIC_EQUIP_FLAG__c = i.STRATEGIC_EQUIP_FLAG;
                    m.MATNR__c = i.MATNR;
                    m.SERNR__c = i.SERNR;
                    m.V_GWLDT__c = i.V_GWLDT;
                    m.V_GWLEN__c = i.V_GWLEN;
                    m.M_ATWRT__c = i.M_ATWRT;
                    m.M_ATWRT2__c = i.M_ATWRT2;
                    m.KDAUF__c = i.KDAUF;
                    m.RES_MN_WK_CTR__c = i.RES_MN_WK_CTR;
                    m.RES_PLANT__c = i.RES_PLANT;
                    m.PERSON_RES__c = i.PERSON_RES;
                    m.PERSON_RES_NAME__c = i.PERSON_RES_NAME;
                    m.DO_VBELN__c = i.DO_VBELN;
                    m.ZI_KUNNR__c = i.ZI_KUNNR;
                    m.ZI_NAME1__c = i.ZI_NAME1;
                    m.ZI_STRAS__c = i.ZI_STRAS;
                    m.ZI_PSTLZ__c = i.ZI_PSTLZ;
                    m.ZI_ORT01__c = i.ZI_ORT01;
                    
                    m.ParameterName__c      = 'T_ITEM';
                    m.BatchExecuteTime__c   = this.batchExecuteTime;
                    insertMList.add(m);
                    System.debug('IF_Material__c-T_PARTNERS_INFO ::: ' + m);
                }
                else if(ifObject.objectName == 'T_PARTNERS_INFO'){
                    IF_Material__c m = new IF_Material__c();
                    IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_PARTNERS_INFO pi = ifObject.T_PARTNERS_INFO;
                    m.EQUNR__c = pi.EQUNR;
                    m.VTEXT__c = pi.VTEXT;
                    m.PARNR__c = pi.PARNR;
                    m.NAME1__c = pi.NAME1;
                    m.ORT01__c = pi.ORT01;

                    m.ParameterName__c      = 'T_PARTNERS_INFO';
                    m.BatchExecuteTime__c   = this.batchExecuteTime;
                    insertMList.add(m);
                    System.debug('IF_Material__c-T_PARTNERS_INFO ::: ' + m);
                }
                else if(ifObject.objectName == 'T_DOCUMENT'){
                    IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT d = ifObject.T_DOCUMENT;
                    IF_Material__c m = new IF_Material__c();
                    m.OBJKY__c = d.OBJKY;
                    m.DOKAR__c = d.DOKAR;
                    m.DOKNR__c = d.DOKNR;
                    m.DOKTL__c = d.DOKTL;
                    m.DOKVR__c = d.DOKVR;
                    m.DKTXT__c = d.DKTXT;

                    m.ParameterName__c      = 'T_DOCUMENT';
                    m.BatchExecuteTime__c   = this.batchExecuteTime;
                    insertMList.add(m);
                    System.debug('IF_Material__c-T_DOCUMENT ::: ' + m);
                }
                else if(ifObject.objectName == 'T_DOCUMENT_FILE'){
                    IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_DOCUMENT_FILE df = ifObject.T_DOCUMENT_FILE;
                    IF_Material__c m = new IF_Material__c();
                    m.OBJKY__c  = df.OBJKY;
                    m.DOKAR__c  = df.DOKAR;
                    m.DOKNR__c  = df.DOKNR;

                    m.DOKTL__c  = df.DOKTL;
                    m.DOKVR__c  = df.DOKVR;
                    m.BUFFER__c = df.BUFFER;

                    m.ParameterName__c      = 'T_DOCUMENT_FILE';
                    m.BatchExecuteTime__c   = this.batchExecuteTime;
                    if (this.seqForDOKNR.get(df.DOKNR) == null) this.seqForDOKNR.put(df.DOKNR, 1);
                    else this.seqForDOKNR.put(df.DOKNR, this.seqForDOKNR.get(df.DOKNR) + 1);
                    
                    m.FileSequence__c       = this.seqForDOKNR.get(df.DOKNR);
                    insertMList.add(m);
                    System.debug('IF_Material__c-T_DOCUMENT_FILE ::: ' + m);
                }
            }
            
            if(insertMList.size() > 0) insert insertMList;
        }

    /**
     * Batch finish
        */            
        public void finish(Database.BatchableContext BC){
            DN_UpdateAssetFromERPBatch batch = new DN_UpdateAssetFromERPBatch();
            if(!Test.isRunningTest()) Database.executeBatch(batch);
            System.debug('IF_MaterialBatch Finish');
        }
}