/**
 * @author            : Hayeong Min
 * @description       : 상담 유형 분석 Report용 DATA 추출
 * @last modified on  : 2025-04-14
 * @last modified by  : Hayeong Min
**/
public with sharing class DN_ConsultationTypeAnalysisController {
   
    /**
     * @Description
     * 	- 상담 유형 분석 Report에서 상담원별 DATA 추출
     * @author Hayeong Min 
    **/ 
    @AuraEnabled
    public static CommonWrapper getPersonData(Date startDate, Date endDate){
        System.debug('startDate :: '+startDate );
        System.debug('endDate :: '+endDate );
        CommonWrapper cw = new CommonWrapper();
        try {
            List<Task> taskList = [SELECT ActivityDate, ConsultationTypeMajor__c, OwnerId, Owner.Name
                                    FROM Task 
                                    WHERE (ActivityDate >= :startDate AND ActivityDate <= :endDate)
                                    AND TaskSubtype = 'Call' AND RecordType.Name = 'Service' 
                                    ORDER BY ActivityDate];

            if(!taskList.isEmpty()){
                Map<Id, List<Task>> taskMap = new Map<Id, List<Task>>();
                for(Task t : taskList){
                    List<Task> recordList = new List<Task>();
                    if(taskMap.containsKey(t.OwnerId)){
                        recordList = taskMap.get(t.OwnerId);
                    }
                    recordList.add(t);
                    taskMap.put(t.OwnerId, recordList);
                }
                System.debug('taskMap :::'+taskMap);

                //Task Type 구분하기
                List<DateWrapper> dateList = new List<DateWrapper>();
                for(Id owner : taskMap.keySet()){
                    DateWrapper ownerWrapper = seperateTaskType(taskMap.get(owner));
                    ownerWrapper.ownerId = owner;
                    ownerWrapper.ownerName = taskMap.get(owner)[0].Owner.Name;
                    dateList.add(ownerWrapper);
                }
                cw.dateList = dateList;
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     * 	- 상담 유형 분석 Report에서 일자별 DATA 추출
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper getDailyData(Date startDate, Date endDate){
        CommonWrapper cw = new CommonWrapper();
        try {
            List<Task> taskList = [SELECT ActivityDate, ConsultationTypeMajor__c
                                    FROM Task 
                                    WHERE (ActivityDate >= :startDate AND ActivityDate <= :endDate)
                                    AND TaskSubtype = 'Call' AND RecordType.Name = 'Service' 
                                    ORDER BY ActivityDate];

            if(!taskList.isEmpty()){
                Map<Date, List<Task>> taskMap = new Map<Date, List<Task>>();
                for(Task t : taskList){
                    List<Task> recordList = new List<Task>();
                    if(taskMap.containsKey(t.ActivityDate)){
                        recordList = taskMap.get(t.ActivityDate);
                    }
                    recordList.add(t);
                    taskMap.put(t.ActivityDate, recordList);
                }
                System.debug('taskMap :::'+taskMap);

                //Task Type 구분하기
                List<DateWrapper> dateList = new List<DateWrapper>();
                for(Date d : taskMap.keySet()){
                    DateWrapper dateWrapper = seperateTaskType(taskMap.get(d));
                    dateWrapper.activityDate = d;
                    dateList.add(dateWrapper);
                }
                cw.dateList = dateList;
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }


    /**
     * @Description
     * 	- Task의 상담유형 별 개수 Count
     * @author Hayeong Min 
    **/
    private static DateWrapper seperateTaskType(List<Task> taskList){
        //상담유형 : 고장접수(Failure Receipt), 제품문의(Product Inquiry), 고객불만(Customer Complaints), 콜서비스(Call Service), 예약통화(Scheduled Call), 기타(Other), VOC(VOC)

        DataWrapper failureReceipt = new DataWrapper();
        failureReceipt.type = 'Failure Receipt';
        DataWrapper productInquiry = new DataWrapper();
        productInquiry.type='Product Inquiry';
        DataWrapper customerComplaints = new DataWrapper();
        customerComplaints.type='Customer Complaints';
        DataWrapper callService = new DataWrapper();
        callService.type='Call Service';
        DataWrapper scheduledCall = new DataWrapper();
        scheduledCall.type='Scheduled Call';
        DataWrapper other = new DataWrapper();
        other.type='Other';
        DataWrapper voc = new DataWrapper();
        voc.type='VOC';
        DataWrapper noData = new DataWrapper();//미입력
        noData.type='noData';
        
        List<DataWrapper> dwList = new List<DataWrapper>{
            failureReceipt,
            productInquiry,
            customerComplaints,
            callService,
            scheduledCall,
            other,
            voc,
            noData
        };

        for(Task t : taskList){
            String consultType = String.isNotEmpty(t.ConsultationTypeMajor__c) ? t.ConsultationTypeMajor__c : '';
            switch on consultType {
                when 'Failure Receipt'{
                    failureReceipt.type = consultType;
                    failureReceipt.dataCnt ++;
                }
                when 'Product Inquiry'{
                    productInquiry.dataCnt ++;
                }
                when 'Customer Complaints' {
                    customerComplaints.dataCnt ++;
                }
                when 'Call Service'  {
                    callService.dataCnt ++;
                }
                when 'Scheduled Call' {
                    scheduledCall.dataCnt ++;
                }
                when 'Other' {
                    other.dataCnt ++;
                }
                when 'VOC' {
                    voc.dataCnt ++;
                }
                when else {//미입력
                    noData.dataCnt ++;
                }
            }
        }



        Integer total = taskList.size();
        for(DataWrapper dw : dwList){
            System.debug(dw.dataCnt);
            Decimal result = (Decimal.valueOf(dw.dataCnt) / total) * 100;
            dw.dataPercent = result.setScale(0, RoundingMode.HALF_UP);
        }
        System.debug('dwList : '+dwList);
        DateWrapper dateWrapper = setDateWrapper(total, dwList);
        
        return dateWrapper;
    
    }

    /**
     * @Description
     * 	- 최종 반환 DATA를 Wrapper 형태로 정리
     * @author Hayeong Min 
    **/
    private static DateWrapper setDateWrapper(Integer total, List<DataWrapper> dwList){
        // List<DateWrapper> dateList = new List<DateWrapper>();
        DateWrapper dateWrapper = new DateWrapper();
        for(DataWrapper dw : dwList){
            switch on dw.type {
                when 'Failure Receipt'{
                    dateWrapper.failureCnt = dw.dataCnt;
                    dateWrapper.failurePercent = dw.dataPercent;
                }
                when 'Product Inquiry'{
                    dateWrapper.pdInquiryCnt = dw.dataCnt;
                    dateWrapper.pdInquiryPercent = dw.dataPercent;
                }
                when 'Customer Complaints' {
                    dateWrapper.complainCnt = dw.dataCnt;
                    dateWrapper.complainPercent = dw.dataPercent;
                }
                when 'Call Service'  {
                    dateWrapper.callServiceCnt = dw.dataCnt;
                    dateWrapper.callServicePercent = dw.dataPercent;
                }
                when 'Scheduled Call' {
                    dateWrapper.scheduledCallCnt = dw.dataCnt;
                    dateWrapper.scheduledCallPercent = dw.dataPercent;
                }
                when 'Other' {
                    dateWrapper.otherCnt = dw.dataCnt;
                    dateWrapper.otherPercent = dw.dataPercent;
                }
                when 'VOC' {
                    dateWrapper.vocCnt = dw.dataCnt;
                    dateWrapper.vocPercent = dw.dataPercent;
                }
                when else {//미입력
                    dateWrapper.noDataCnt = dw.dataCnt;
                    dateWrapper.noDataPercent = dw.dataPercent;
                }
            }
        }
        return dateWrapper;
    }

    /*
     * @Description
     * 		- 공용 Wrapper
     * 
     * @Variable
     *  	- isSuccess 		: 성공 여부
     *  	- errMessage 		: 결과가 에러일 때 에러 Message
     *  	- returnValue 		: 결과가 성공일 때 반환 값
     *  	- dateList 			: 
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		          {get; set;}
        @AuraEnabled
        public String errMessage		          {get; set;} 
        @AuraEnabled
        public String returnValue		          {get; set;}
        @AuraEnabled
        public List<DateWrapper> dateList		          {get; set;}
        
        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
            this.returnValue 	= '';
            this.dateList 	    = new List<DateWrapper>();
        }
    }

    /*
     * @Description
     * 		- 상담유형별 Data 갯수 Wrapper
     * 
     * @Variable
     *  	- type 		    : 상담유형
     *  	- dataCnt 	    : 상담유형별 Data 갯수
     *  	- dataPercent 	: 상담유형별 Data Percent
     */
    public class DataWrapper {
        @AuraEnabled
        public String type		          {get; set;} 
        @AuraEnabled
        public Integer dataCnt		          {get; set;} 
        @AuraEnabled
        public Decimal dataPercent		      {get; set;}
        
        public DataWrapper(){
            this.type 	        = '';
            this.dataCnt 	    = 0;
            this.dataPercent 	= 0;
        }
    }

    public class DateWrapper {
        @AuraEnabled
        public String ownerId		          {get; set;} 
        @AuraEnabled
        public String ownerName		          {get; set;} 
        @AuraEnabled
        public Date activityDate		          {get; set;} 
        @AuraEnabled
        public Integer failureCnt		          {get; set;} 
        @AuraEnabled
        public Decimal failurePercent		          {get; set;} 
        @AuraEnabled
        public Integer pdInquiryCnt		      {get; set;}
        @AuraEnabled
        public Decimal pdInquiryPercent	      {get; set;}
        @AuraEnabled
        public Integer complainCnt		      {get; set;}
        @AuraEnabled
        public Decimal complainPercent	      {get; set;}
        @AuraEnabled
        public Integer callServiceCnt		      {get; set;}
        @AuraEnabled
        public Decimal callServicePercent	      {get; set;}
        @AuraEnabled
        public Integer scheduledCallCnt		      {get; set;}
        @AuraEnabled
        public Decimal scheduledCallPercent	      {get; set;}
        @AuraEnabled
        public Integer otherCnt		      {get; set;}
        @AuraEnabled
        public Decimal otherPercent	      {get; set;}
        @AuraEnabled
        public Integer vocCnt		      {get; set;}
        @AuraEnabled
        public Decimal vocPercent	      {get; set;}
        @AuraEnabled
        public Integer noDataCnt		      {get; set;}
        @AuraEnabled
        public Decimal noDataPercent	      {get; set;}
        
        public DateWrapper(){
            this.ownerId 	            = '';
            this.ownerName 	            = '';
            this.activityDate 	            = null;
            this.failureCnt 	    = 0;
            this.failurePercent 	= 0;
            this.pdInquiryCnt 	    = 0;
            this.pdInquiryPercent 	= 0;
            this.complainCnt 	    = 0;
            this.complainPercent 	= 0;
            this.callServiceCnt 	    = 0;
            this.callServicePercent 	= 0;
            this.scheduledCallCnt 	    = 0;
            this.scheduledCallPercent 	= 0;
            this.otherCnt 	    = 0;
            this.otherPercent 	= 0;
            this.vocCnt 	    = 0;
            this.vocPercent 	= 0;
            this.noDataCnt 	    = 0;
            this.noDataPercent 	= 0;
        }
    }



    

}