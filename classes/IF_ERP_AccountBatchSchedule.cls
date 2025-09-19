global with sharing class IF_ERP_AccountBatchSchedule implements Schedulable{
    public IF_ERP_AccountBatchSchedule(Integer timeSet,Boolean oneHourCall) {
      this.timeSet      = -timeSet    ;
      this.oneHourCall  = oneHourCall ;
    }
    public IF_ERP_AccountBatchSchedule() {
      this.timeSet = -20;
      this.oneHourCall = false;
    }
    private Integer timeSet;
    private Boolean oneHourCall;
    
    global void execute(SchedulableContext sc){

       IF_ERP_Account_Classes.IF_ACCOUNT_005_Req parameters = new IF_ERP_Account_Classes.IF_ACCOUNT_005_Req();
       Date      today    = Date.today();
       String    todatStr = today.year() +  String.valueOf(today.month()).leftPad(2, '0') + String.valueOf(today.day()).leftPad(2, '0');

       DateTime now       = Datetime.now();
       DateTime minusHour = now.addMinutes(this.timeSet);

       String   startAt   = minusHour.format('HH:mm:ss');
       String   endAt     =       now.format('HH:mm:ss'); 

       IF_ERP_AccountBatch.RequestDto requestKNA1 = new IF_ERP_AccountBatch.RequestDto(todatStr,todatStr,startAt,endAt,this.oneHourCall);
       Database.executeBatch(new IF_ERP_AccountBatch(requestKNA1), 30);

    }

    /**
     * 
       IF_ERP_AccountBatch.RequestDto requestKNA1 = new IF_ERP_AccountBatch.RequestDto('20250425','20250425','13:00:00','15:00:00');
       Database.executeBatch(new IF_ERP_AccountBatch(requestKNA1), 30);
     */
}