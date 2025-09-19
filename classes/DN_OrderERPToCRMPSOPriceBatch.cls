/**
 * @description       : Order PSO Price ERP To CRM
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-17
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-03-28   yeongju.yun   Initial Version
**/
global without sharing class DN_OrderERPToCRMPSOPriceBatch implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful, Schedulable{
    public static DN_OrderService ordSvc = new DN_OrderService();
    public String startDate; 
    public String endDate; 

    public DN_OrderERPToCRMPSOPriceBatch() {
        Date today = Date.today().addDays(-1);
        this.startDate = ordSvc.formatDateForSAP(today, false);
        this.endDate   = ordSvc.formatDateForSAP(today, false);
    }

    /**
     * @param sDate start date, from date, format : YYYYMMDD
     * @param eDate end date, to date, format : YYYYMMDD
     */
    public DN_OrderERPToCRMPSOPriceBatch(String sDate, String eDate) { 
        this.startDate = sDate;
        this.endDate   = eDate;
    }
    
    global Iterable<Object> start(Database.BatchableContext BC){
        
        IF_ERP_Order_Classes.IF_ORDER_022_Req request = new IF_ERP_Order_Classes.IF_ORDER_022_Req();
        request.I_FROM_DATE = this.startDate;
        request.I_TO_DATE   = this.endDate;

        IF_ERP_Order service = new IF_ERP_Order();
        IF_ERP_Order_Classes.IF_ORDER_022_Res response = service.IF_ORDER_022(request);

        return response.OT_NET_VALUE;
    }

    global void execute(Database.BatchableContext BC, List<Object> scope){

        List<IF_ERP_Order_Classes.IF_ORDER_022_Res_OT_NET_VALUE> response = (List<IF_ERP_Order_Classes.IF_ORDER_022_Res_OT_NET_VALUE>) scope;

        Map<String, IF_ERP_Order_Classes.IF_ORDER_022_Res_OT_NET_VALUE> order22Map = new Map<String, IF_ERP_Order_Classes.IF_ORDER_022_Res_OT_NET_VALUE>();
        for(IF_ERP_Order_Classes.IF_ORDER_022_Res_OT_NET_VALUE row : response) {
            order22Map.put(String.valueOf(row.VBELN), row);
        }

        List<Order> orderList = [SELECT Id, ERPPSONo__c, PSOAmount__c, PSOTax__c, IF_FreePass__c FROM Order WHERE ERPPSONo__c = : order22Map.keySet()];

        if(!orderList.isEmpty()) {

            for(Order order : orderList) {
                IF_ERP_Order_Classes.IF_ORDER_022_Res_OT_NET_VALUE order22Row = order22Map.get(order.ERPPSONo__c);
                order.PSOAmount__c   = Decimal.valueOf(order22Row.NETWR);
                order.PSOTax__c      = Decimal.valueOf(order22Row.MWST);
                order.IF_FreePass__c = true;
            }
            update orderList;
        }
    }

    global void finish(Database.BatchableContext bc){
        System.debug('DN_OrderERPToCRMPSOPriceBatch - finished');
    }

    global void execute( SchedulableContext SC){
        DataBase.executeBatch( new DN_OrderERPToCRMPSOPriceBatch());
    }
}