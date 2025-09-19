global with sharing class IF_PromotionBatchSchedule implements Schedulable{
    public IF_PromotionBatchSchedule() {}

    global void execute(SchedulableContext sc){
        Date      today    = Date.today();
        String    todatStr = today.year() +  String.valueOf(today.month()).leftPad(2, '0') + String.valueOf(today.day()).leftPad(2, '0');

        IF_ERP_Order_Classes.IF_ORDER_016_Req request = new IF_ERP_Order_Classes.IF_ORDER_016_Req();
        request.I_VKORG      = '1800';
        request.I_VTWEG      = '10';
        request.I_WAERK      = 'KRW';
        request.I_VALID_ON   = todatStr;

        IF_ERP_PromotionBatch batchZSSY = new IF_ERP_PromotionBatch(request, 'T_O_ZSSY');
        IF_ERP_PromotionBatch batchZSSX = new IF_ERP_PromotionBatch(request, 'T_O_ZSSX');

        Database.executeBatch(batchZSSY,50);
        Database.executeBatch(batchZSSX,50);
    }   
}