/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-09-01
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-02-11   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_PartsProgressCalloutBatch implements Database.Batchable<Datetime> {

    // private Map<String, IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST> partsProgressMap = new Map<String, IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST>();
    // private Map<String, List<IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST>> testMap = new Map<String, List<IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST>>();

    // public DN_PartsProgressCalloutBatch() {}

    public List<Datetime> start(Database.BatchableContext bc) {


        // List<Datetime> dateList = new List<Datetime>();
        // Datetime endDate = Datetime.now();
        // for (Integer i = -1; i > -13; i--) {
        //     dateList.add(endDate.addMonths(i));
        // }
        // System.debug(dateList);
        // for (Datetime dt : dateList) {
        //     System.debug(dt.format('yyyy-MM-dd'));
        // }

        // if (!Test.isRunningTest()) return dateList;
        // else return new List<Datetime>{Datetime.now()};
        return new List<Datetime>{Datetime.now()};
    }

    public void execute(Database.BatchableContext bc, List<Datetime> scope) {
        // System.debug(scope);
        // Datetime startDatetime = scope[0];
        // Datetime endDatetime = scope[0].addMonths(1);

        // IF_ERP_Material_Classes.IF_CSPLUS_007_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req();
        // req.FR_RECV_DAT = startDatetime.format('yyyy-MM-dd');
        // req.TO_RECV_DAT = endDatetime.format('yyyy-MM-dd');
        // req.I_CHK = 'X';

        // System.debug('req ::: ' + req);

        // IF_ERP_Material instance = new IF_ERP_Material();
        // IF_ERP_Material_Classes.IF_CSPLUS_007_Res response = instance.IF_CSPLUS_007(req);
        // System.debug('response ::: ' + response);
        // if (response.O_RETURN.TYPE == 'S') {
        //     System.debug('response Size ::: ' + response.T_O_LIST.size());
        //     for (IF_ERP_Material_Classes.IF_CSPLUS_007_Res_T_O_LIST obj : response.T_O_LIST) {
        //         if (obj.AUFNR != '' && obj.QMSEQ != '') {
        //             System.debug(obj.AUFNR + '!' + obj.QMSEQ);
        //             partsProgressMap.put(obj.AUFNR + '!' + obj.QMSEQ, obj);
        //         }
                
        //     }
        // }
    }

    public void finish(Database.BatchableContext bc) {
        // System.debug('flag1 ::: ' + partsProgressMap.values().size());

        // DN_PartsProgressBatch batch = new DN_PartsProgressBatch();
        // batch.partsProgressMap = partsProgressMap;
        // Database.executeBatch(batch, 200);

        // List<CronTrigger> ctList = [SELECT Id, CronExpression, CronJobDetailId, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'DN_PartsProgressCalloutBatch'];

        // DN_PartsProgressCalloutBatch scheduleBatch = new DN_PartsProgressCalloutBatch();
        // if (ctList.size() > 0) {
        //     CronTrigger ct = ctList[0];

        //     String cronExp = ct.CronExpression;

        //     Integer min = Integer.valueOf(ct.CronExpression.split(' ')[1]);
        //     Integer newMin = min + 20;

        //     if (newMin >= 60) {
        //         newmin = 0;
        //     }

        //     cronExp = '0 ' + newmin + ' * * * ?';

        //     System.abortJob(ctList[0].Id);

        //     System.schedule('DN_PartsProgressCalloutBatch', cronExp, scheduleBatch);

        // } else {
        //     Datetime dt = Datetime.now();
        //     Integer newmin = 0;
        //     if (dt.minute() >= 0 && dt.minute() < 20) {
        //         newmin = 20;
        //     } else if (dt.minute() >= 20 && dt.minute() < 40) {
        //         newmin = 40;
        //     }

        //     String cronExp = '0 ' + newmin + ' * * * ?';

        //     System.schedule('DN_PartsProgressCalloutBatch', cronExp, scheduleBatch);
        // }
    }

    // public void execute(SchedulableContext sc) {
    //     DN_PartsProgressCalloutBatch batch = new DN_PartsProgressCalloutBatch();
    //     Database.executeBatch(batch, 1);
    // }
}