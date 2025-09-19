global with sharing class IF_WarrantyBatchSchedule implements Schedulable{
    public IF_WarrantyBatchSchedule() {
    }

    global void execute(SchedulableContext sc){
        List<IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG> vkorg_list = new List<IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG>();  
        IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG vkorg_01 = new IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG(); 
        vkorg_01.VKORG = '1140';
        IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG vkorg_02 = new IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG(); 
        vkorg_02.VKORG = '4140';
        IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG vkorg_03 = new IF_ERP_Order_Classes.IF_ORDER_017_Req_T_VKORG(); 
        vkorg_03.VKORG = '1800';
        
        vkorg_list.add(vkorg_01);
        vkorg_list.add(vkorg_02);
        vkorg_list.add(vkorg_03);
        
        IF_ERP_Order_Classes.IF_ORDER_017_Req request = new IF_ERP_Order_Classes.IF_ORDER_017_Req();
        request.T_VKORG = vkorg_list;

        IF_ERP_WarrantyBatch batch = new IF_ERP_WarrantyBatch(request,'T_DATA');
        Database.executeBatch(batch,200);
    }
}