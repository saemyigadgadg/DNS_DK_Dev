global with sharing class IF_ERP_DNSA_OrderBatchSchedule implements Schedulable{
    public IF_ERP_DNSA_OrderBatchSchedule() {}

    global void execute(SchedulableContext sc) {

        Date      today    = Date.today();
        String    todatStr = today.year() +  String.valueOf(today.month()).leftPad(2, '0') + String.valueOf(today.day()).leftPad(2, '0');


        IF_ERP_Order_Classes.IF_ORDER_012_Req request = new IF_ERP_Order_Classes.IF_ORDER_012_Req();
        request.I_AEDAT_F = todatStr;
        request.I_AEDAT_T = todatStr;

        
        IF_ERP_DNSA_OrderBatch dnsaOrderBatch = new IF_ERP_DNSA_OrderBatch(request); 
        Database.executeBatch(dnsaOrderBatch,50);
    }
}