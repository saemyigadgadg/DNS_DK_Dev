global with sharing class IF_ERP_DeliveryBatchSchedule implements Schedulable{
    public IF_ERP_DeliveryBatchSchedule() {}
    global void execute(SchedulableContext sc){

        IF_ERP_DELIV_Classes.IF_DELIV_002_Req_I_USERINFO i_userInfo =
        new IF_ERP_DELIV_Classes.IF_DELIV_002_Req_I_USERINFO();
        
        i_userInfo.VKORG = '1800';
        i_userInfo.VTWEG = '10';
        i_userInfo.SPART = '40';
        
        Date      today    = Date.today();
        String    todatStr = today.year() +  String.valueOf(today.month()).leftPad(2, '0') + String.valueOf(today.day()).leftPad(2, '0');
        
        IF_ERP_DELIV_Classes.IF_DELIV_002_Req req = new IF_ERP_DELIV_Classes.IF_DELIV_002_Req();
        req.I_AEDAT_FR = todatStr;
        req.I_AEDAT_TO = todatStr;
        req.I_USERINFO = i_userInfo;
        
        IF_ERP_DeliveryOrderBatch batch = new IF_ERP_DeliveryOrderBatch(req,'');
        Database.executeBatch(batch, 50);
    }
}