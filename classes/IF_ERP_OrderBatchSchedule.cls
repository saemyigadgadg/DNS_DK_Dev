/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-10-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-14-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
global with sharing class IF_ERP_OrderBatchSchedule implements Schedulable{
    public String AUART;
    public String VTWEG;

    public IF_ERP_OrderBatchSchedule(String auart, String vtweg){
        this.AUART = auart;
        this.VTWEG = vtweg;
    }
    global void execute(SchedulableContext sc) {
        IF_ERP_Order_Classes.IF_ORDER_002_Req request = new IF_ERP_Order_Classes.IF_ORDER_002_Req();
        IF_ERP_Order_Classes.IF_ORDER_002_Req_I_ORG org  = new IF_ERP_Order_Classes.IF_ORDER_002_Req_I_ORG();
        org.VKORG = '1800';        
        org.VTWEG = this.VTWEG;
        org.SPART = '40';
        
        request.I_ORG = org;
        Date      today    = Date.today();
        String    todatStr = today.year() +  String.valueOf(today.month()).leftPad(2, '0') + String.valueOf(today.day()).leftPad(2, '0');
        request.I_ERDAT_F = todatStr;
        request.I_ERDAT_T = todatStr;
        request.I_AUART   = this.AUART;
        
        IF_ERP_OrderBatch batch = new IF_ERP_OrderBatch(request, '', this.AUART);
        Database.executeBatch(batch,50);
    }
}