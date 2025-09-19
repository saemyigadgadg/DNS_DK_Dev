global with sharing class IF_ERP_DeliveryConvertBatchSchedule implements Schedulable{
    public IF_ERP_DeliveryConvertBatchSchedule() {}
    
    global void execute(SchedulableContext sc){

        IF_ERP_DeliveryOrderConvertBatch batch = new IF_ERP_DeliveryOrderConvertBatch();
        Database.executeBatch(batch, 50);
    }    
}