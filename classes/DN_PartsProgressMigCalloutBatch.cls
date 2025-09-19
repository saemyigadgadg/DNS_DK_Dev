/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-10
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-02-11   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_PartsProgressMigCalloutBatch implements Database.Batchable<Datetime>, Database.Stateful, Database.AllowsCallouts, Schedulable{

    private Map<String, IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST> partsProgressMap = new Map<String, IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST>();
    public Datetime startDate;
    public Datetime endDate;

    public DN_PartsProgressMigCalloutBatch() {}

    public List<Datetime> start(Database.BatchableContext bc) {

        List<Datetime> dateList = new List<Datetime>();
        Datetime currentDate = startDate;

        while (currentDate <= endDate) {
            dateList.add(currentDate);
            currentDate = currentDate.addDays(10);
        }

        return dateList;

    }
    

    public void execute(Database.BatchableContext bc, List<Datetime> scope) {

        System.debug(scope);

        Datetime startDatetime = scope[0];
        Datetime endDatetime = scope[0].addDays(10);

        IF_ERP_Material_Classes.IF_CSPLUS_007_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req();
        req.FR_RECV_DAT = startDatetime.format('yyyy-MM-dd');
        req.TO_RECV_DAT = endDatetime.format('yyyy-MM-dd');
        req.I_CHK = 'X';

        System.debug('req ::: ' + req);

        IF_ERP_Material instance = new IF_ERP_Material();
        IF_ERP_Material_Classes.IF_CSPLUS_007_Res response = instance.IF_CSPLUS_007(req);
        System.debug('response ::: ' + response);
        if (response.O_RETURN.TYPE == 'S') {
            System.debug('response Size ::: ' + response.T_O_LIST.size());
            if (response.T_O_LIST.size() > 0) {
                for (IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST obj : response.T_O_LIST) {
                    if (obj.AUFNR != '' && obj.QMSEQ != '') {
                        System.debug(obj.AUFNR + '!' + obj.QMSEQ);
                        partsProgressMap.put(obj.AUFNR + '!' + obj.QMSEQ, obj);
                    }
                    
                }
            }
        }


    }

    public void finish(Database.BatchableContext bc) {
        System.debug('flag1 ::: ' + partsProgressMap.values().size());

        DN_PartsProgressBatch batch = new DN_PartsProgressBatch();
        batch.partsProgressMap = partsProgressMap;
        Database.executeBatch(batch, 200);
        
    }

    public void execute(SchedulableContext sc) {
        DN_PartsProgressMigCalloutBatch batch = new DN_PartsProgressMigCalloutBatch();
        Database.executeBatch(batch, 1);
    }


}