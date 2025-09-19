global with sharing class IF_DeviceManagerBatchSchedule implements Schedulable{
    public IF_DeviceManagerBatchSchedule() {}

    global void execute(SchedulableContext sc){

        IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req request = new IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req();
        request.I_WERKS = '';
        request.I_T_SATNR = new List<IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req_I_T_SATNR>();
        request.I_CA_RNDD = 'X';
        request.I_CA_MNFE = '';
        Database.executeBatch(new IF_DeviceManagerBatch(request,'T_ZCRMS0002'),200);
     }
}