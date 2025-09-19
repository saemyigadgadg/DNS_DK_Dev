/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-14-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-18-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_DeviceManagerBatch 
                    implements Database.Batchable<Object>, 
                               Database.AllowsCallouts, 
                               Database.Stateful  {
    /**
     * Constructor        
        */
        public IF_DeviceManagerBatch(IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req parameters, String parameter) {
            this.parameters = parameters;
            this.parameter = parameter;
        }
    /**
     * fields
        - request
            * startDateStr
            * endDateStr

        */
        private final IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req parameters;   
        private final String parameter;  

    /**
     * Batch Start
        */
        public Iterable<Object> start(Database.BatchableContext BC){
            List<Object> returnList = new List<Object>();
            IF_ERP_Opty_DeviceManager call = new IF_ERP_Opty_DeviceManager();
            IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res result  = call.IF_OPTY_001(parameters);
            if(parameter == 'T_ZCRMS0001') returnList = result.T_ZCRMS0001;
            else if(parameter == 'T_ZCRMS0002') returnList = result.T_ZCRMS0002;
            else if(parameter == 'T_ZCRMS0003') returnList = result.T_ZCRMS0003;
            // ** 성공 CASE
            return returnList;
        }

    /**
     * Batch execute
        */        
        public void execute(Database.BatchableContext BC, List<Object> scope){
            
            List<IF_DeviceManager__c> insertDMList = new List<IF_DeviceManager__c>();
            if(parameter == 'T_ZCRMS0002'){
                List<IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0002> zcrms0002 = (List<IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0002>) scope;         

                Map<String,IF_DeviceManager__c> ifObjMap  = findMap();
                Map<String,IF_DeviceManager__c> resultMap = new Map<String,IF_DeviceManager__c>();

                for(IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res_T_ZCRMS0002 z : zcrms0002){
                    String key = z.SATNR+'_'+z.WERKS;
                    
                    IF_DeviceManager__c dm;
                    if(resultMap.containsKey(key)){
                        dm = resultMap.get(key);
                    }
                    else if(ifObjMap.containsKey(key)){
                        dm = ifObjMap.get(key);
                    }
                    else{
                        dm = new IF_DeviceManager__c();
                    }
                    dm.IsConverted__c = false;
                    dm.WERKS__c     = z.WERKS    ;
                    dm.SATNR__c     = z.SATNR    ;
                    dm.MAKTX__c     = z.MAKTX    ;      
                    dm.EMPNO_RD1__c = z.EMPNO_RD1;
                    dm.EMPNM_RD1__c = z.EMPNM_RD1;
                    dm.EMPNO_RD2__c = z.EMPNO_RD2;
                    dm.EMPNM_RD2__c = z.EMPNM_RD2;
                    dm.EMPNO_RD3__c = z.EMPNO_RD3;
                    dm.EMPNM_RD3__c = z.EMPNM_RD3;
                    dm.EMPNO_RD4__c = z.EMPNO_RD4;
                    dm.EMPNM_RD4__c = z.EMPNM_RD4;
                    dm.EMPNO_RD5__c = z.EMPNO_RD5;
                    dm.EMPNM_RD5__c = z.EMPNM_RD5;
                    dm.EMPNO_RD6__c = z.EMPNO_RD6;
                    dm.EMPNM_RD6__c = z.EMPNM_RD6;
                    dm.EMPNO_RD7__c = z.EMPNO_RD7;
                    dm.EMPNM_RD7__c = z.EMPNM_RD7;
                    dm.EMPNO_RD8__c = z.EMPNO_RD8;
                    dm.EMPNM_RD8__c = z.EMPNM_RD8;
                    dm.EMPNO_RDA__c = z.EMPNO_RDA;
                    dm.EMPNM_RDA__c = z.EMPNM_RDA;
                    dm.EMPNO_RDB__c = z.EMPNO_RDB;
                    dm.EMPNM_RDB__c = z.EMPNM_RDB;
                    dm.EMPNO_RDC__c = z.EMPNO_RDC;
                    dm.EMPNM_RDC__c = z.EMPNM_RDC;
                    dm.EPMAIL_RD1__c = z.EPMAIL_RD1 ;
                    dm.DEPNM_RD1__c  = z.DEPNM_RD1; 
                    dm.DEPHD_RD1__c  = z.DEPHD_RD1; 
                    dm.EPMAIL_RD2__c = z.EPMAIL_RD2; 
                    dm.DEPNM_RD2__c  = z.DEPNM_RD2; 
                    dm.DEPHD_RD2__c  = z.DEPHD_RD2; 
                    dm.EPMAIL_RD3__c = z.EPMAIL_RD3; 
                    dm.DEPNM_RD3__c  = z.DEPNM_RD3; 
                    dm.DEPHD_RD3__c  = z.DEPHD_RD3; 
                    dm.EPMAIL_RD4__c = z.EPMAIL_RD4; 
                    dm.DEPNM_RD4__c  = z.DEPNM_RD4; 
                    dm.DEPHD_RD4__c  = z.DEPHD_RD4; 
                    dm.EPMAIL_RD5__c = z.EPMAIL_RD5; 
                    dm.DEPNM_RD5__c  = z.DEPNM_RD5; 
                    dm.DEPHD_RD5__c  = z.DEPHD_RD5; 
                    dm.EPMAIL_RD6__c = z.EPMAIL_RD6; 
                    dm.DEPNM_RD6__c  = z.DEPNM_RD6; 
                    dm.DEPHD_RD6__c  = z.DEPHD_RD6; 
                    dm.EPMAIL_RD7__c = z.EPMAIL_RD7; 
                    dm.DEPNM_RD7__c  = z.DEPNM_RD7; 
                    dm.DEPHD_RD7__c  = z.DEPHD_RD7; 
                    dm.EPMAIL_RD8__c = z.EPMAIL_RD8; 
                    dm.DEPNM_RD8__c  = z.DEPNM_RD8; 
                    dm.DEPHD_RD8__c  = z.DEPHD_RD8; 
                    dm.EPMAIL_RDA__c = z.EPMAIL_RDA; 
                    dm.DEPNM_RDA__c  = z.DEPNM_RDA; 
                    dm.DEPHD_RDA__c  = z.DEPHD_RDA; 
                    dm.EPMAIL_RDB__c = z.EPMAIL_RDB; 
                    dm.DEPNM_RDB__c  = z.DEPNM_RDB; 
                    dm.DEPHD_RDB__c  = z.DEPHD_RDB; 
                    dm.EPMAIL_RDC__c = z.EPMAIL_RDC; 
                    dm.DEPNM_RDC__c  = z.DEPNM_RDC; 
                    dm.DEPHD_RDC__c  = z.DEPHD_RDC;            
                    dm.DEPNO_RD1__c  = z.DEPNO_RD1; // ?v1.3     
                    dm.DPMAIL_RD1__c = z.DPMAIL_RD1;// ?v1.3     
                    dm.DEPNO_RD2__c  = z.DEPNO_RD2; // ?v1.3    
                    dm.DPMAIL_RD2__c = z.DPMAIL_RD2;// ?v1.3                                          
                    resultMap.put(key,dm);
                }
                
                insertDMList = resultMap.values();
            }
            else{
                System.debug('TABLE NAME : '+parameter+' is not applied');
            }

            
            if(insertDMList.size() > 0) upsert insertDMList;
        }

    /**
     * Batch finish
        */            
        public void finish(Database.BatchableContext BC){
            DN_DeviceManagerBatch device = new DN_DeviceManagerBatch();
            Database.executeBatch(device);
        }

    
    public Map<String,IF_DeviceManager__c> findMap(){
        Map<String,IF_DeviceManager__c> ifObjMap = new Map<String,IF_DeviceManager__c>();

        for(IF_DeviceManager__c  ifObj : [
            SELECT 
                WERKS__c, SATNR__c, MAKTX__c, EMPNO_RD1__c, EMPNM_RD1__c, EMPNO_RD2__c,
                EMPNM_RD2__c, EMPNO_RD3__c, EMPNM_RD3__c, EMPNO_RD4__c, EMPNM_RD4__c, EMPNO_RD5__c,
                EMPNM_RD5__c, EMPNO_RD6__c, EMPNM_RD6__c, EMPNO_RD7__c, EMPNM_RD7__c, EMPNO_RD8__c,
                EMPNM_RD8__c, EMPNO_RDA__c, EMPNM_RDA__c, EMPNO_RDB__c, EMPNM_RDB__c, EMPNO_RDC__c,
                EMPNM_RDC__c, EPMAIL_RD1__c, DEPNM_RD1__c, DEPHD_RD1__c, EPMAIL_RD2__c, DEPNM_RD2__c,
                DEPHD_RD2__c, EPMAIL_RD3__c, DEPNM_RD3__c, DEPHD_RD3__c, EPMAIL_RD4__c, DEPNM_RD4__c,
                DEPHD_RD4__c, EPMAIL_RD5__c, DEPNM_RD5__c, DEPHD_RD5__c, EPMAIL_RD6__c, DEPNM_RD6__c,
                DEPHD_RD6__c, EPMAIL_RD7__c, DEPNM_RD7__c, DEPHD_RD7__c, EPMAIL_RD8__c, DEPNM_RD8__c,
                DEPHD_RD8__c, EPMAIL_RDA__c, DEPNM_RDA__c, DEPHD_RDA__c, EPMAIL_RDB__c, DEPNM_RDB__c,
                DEPHD_RDB__c, EPMAIL_RDC__c, DEPNM_RDC__c, DEPHD_RDC__c, DEPNO_RD1__c, DPMAIL_RD1__c,
                DEPNO_RD2__c, DPMAIL_RD2__c, VERID__c, TEXT1__c, UNAME__c, EMP_NAME__c, BLOCK__c,
                STLAN__c, MFGNM__c, MFGNM2__c, EMP_NAME2__c, MFGNM3__c, EMP_NAME3__c,
                CreatedDate, LastModifiedDate, IsConverted__c
            FROM IF_DeviceManager__c 
            WHERE (CreatedDate = TODAY OR LastModifiedDate = TODAY)
        ]){
            ifObjMap.put(ifObj.SATNR__c+'_'+ifObj.WERKS__c,ifObj);
        }
        return ifObjMap;
    }
}