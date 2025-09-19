/**
 * @author            : Yeong-Deok Seo
 * @Description       : 관리자통계 Report 화면
 * @last modified on  : 2025-03-28
 * @last modified by  : yeongdeok.seo@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-28   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_MonitoringAdminController {
    private static final Id caseVocRT = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VOC_Domestic').getRecordTypeId();

    //조건에 부합하는 관리자통계 DATA 반환
    @AuraEnabled
    public static reportWrapper getData(){
        reportWrapper res = new reportWrapper();

        //////////////콜센터 상세정보/////////////////
        List<case> caseList = [SELECT Id ,VOCType__c ,InternalTicketType__c ,EndOfReason__c ,RecordTypeId
                                FROM case
                                WHERE CreatedDate = THIS_MONTH];

        double callcenterTotalCount = 0; //콜센터 상세정보 전체 건수
        double failReceiptCount = 0; //고장접수 건수
        double customerComplainCount = 0; //고객불만
        double callServiceCount = 0; //콜서비스
        double vocCount = 0; //VOC

        for(Case c : caseList){
            callcenterTotalCount++;
            if(c.InternalTicketType__c == 'Failure receipt'){
                failReceiptCount++;
            }
            if(c.VOCType__c == '고객불만'){
                customerComplainCount++;
            }
            if(c.EndOfReason__c == 'Call Service'){
                callServiceCount++;
            }
            if(c.RecordTypeId == caseVocRT){
                vocCount++;
            }         
        }

        //////////////서비스업무 계획대비 실행률/////////////////
        //하자 당월
        List<WorkOrder> woResults = [SELECT CaseId, case.Status
                                     FROM WorkOrder
                                     WHERE CaseId != NULL AND CreatedDate = THIS_MONTH];

        //하자 전월미결
        List<WorkOrder> woPreResults = [SELECT CaseId, case.Status
                                        FROM WorkOrder
                                        WHERE CaseId != NULL AND CreatedDate = LAST_MONTH AND case.Status = 'Uncompleted'];

        double workOrderCount = 0; //발생수
        double woCompletedCount = 0; //처리수
        double woNotCompletedCount = 0; //미결수
        double woPreNotCompletedCount = 0; //전월 미결수
        
        for (WorkOrder wo : woResults) {
            workOrderCount++;
            
            if(wo.case.Status=='Completed'){
                woCompletedCount++;
            } else if(wo.case.Status=='Uncompleted'){
                woNotCompletedCount++;
            }
        }
        //전월
        woPreNotCompletedCount = woPreResults.size();
        
        //PM Activity Type 별
        Set<String> excludeOrderTypes = new Set<String>{'201','203','204','218','214','216','217','218'};

        Map<String, String> orderTypeLabels = new Map<String, String>();
        Schema.DescribeFieldResult orderTypeField = WorkOrder.OrderType__c.getDescribe();
        for (Schema.PicklistEntry entry : orderTypeField.getPicklistValues()) {
            String value = entry.getValue();
            if (!excludeOrderTypes.contains(value)) {
                orderTypeLabels.put(value, entry.getLabel());
            }
        }

        //PM 별 당월월
        List<AggregateResult> woList = [SELECT OrderType__c, Status, COUNT(Id) recordCount
                                        FROM WorkOrder
                                        WHERE OrderType__c NOT IN :excludeOrderTypes
                                        AND CreatedDate = THIS_MONTH
                                        GROUP BY OrderType__c, Status];
        //PM 별 전월미결
        List<AggregateResult> woPreList = [SELECT OrderType__c, COUNT(Id) recordCount
                                            FROM WorkOrder
                                            WHERE OrderType__c NOT IN :excludeOrderTypes
                                            AND CreatedDate = LAST_MONTH
                                            AND Status = 'Uncompleted'
                                            GROUP BY OrderType__c];

        Map<String, Map<String, Integer>> dataMap = new Map<String, Map<String, Integer>>();
        //당월
        for (AggregateResult ar : woList) {
            String orderType = (String)ar.get('OrderType__c');
            String status = (String)ar.get('Status');
            Integer count = (Integer)ar.get('recordCount');

            if (!dataMap.containsKey(orderType)) {
                dataMap.put(orderType, new Map<String, Integer>());
            }
            dataMap.get(orderType).put(status, count);
        }
        //전월
        Map<String, Integer> preMonthMap = new Map<String, Integer>();
        for (AggregateResult ar : woPreList) {
            String orderType = (String)ar.get('OrderType__c');
            Integer count = (Integer)ar.get('recordCount');
            preMonthMap.put(orderType, count);
        }

        List<String> completedStatuses = new List<String>{'Completed'};
        List<String> notCompletedStatuses = new List<String>{'Uncompleted'}; 

        List<OrderTypeWrapper> summary = new List<OrderTypeWrapper>();
        for (String orderType : orderTypeLabels.keySet()) {
            OrderTypeWrapper wrapper = new OrderTypeWrapper();
            wrapper.orderType = orderTypeLabels.get(orderType);
            Map<String, Integer> statusMap = dataMap.containsKey(orderType) ? dataMap.get(orderType) : new Map<String, Integer>();

            // 상태별 집계
            double total = 0;
            double completed = 0;
            double notCompleted = 0;
            double preNotCompleted = preMonthMap.containsKey(orderType) ? preMonthMap.get(orderType) : 0;

            for (String status : statusMap.keySet()) {
                Integer count = statusMap.get(status);
                total += count;

                if (completedStatuses.contains(status)) {
                    completed += count;
                } else if (notCompletedStatuses.contains(status)) {
                    notCompleted += count;
                }
            }

            wrapper.otTotal_count = Integer.valueOf(total);
            wrapper.otCompleted_count = Integer.valueOf(completed);
            wrapper.otNotCompleted_count = Integer.valueOf(notCompleted);
            wrapper.otTotalCompleted_rate = (total > 0) ? Integer.valueOf(completed/total* 100) : 0;
            wrapper.otNotCompleted_preM = Integer.valueOf(preNotCompleted);

            // 결과에 추가
            summary.add(wrapper);
        }

        //합계
        double totalWorkOrderCount = 0;
        double totalWoCompletedCount = 0;
        double totalWoNotCompletedCount = 0;
        double totalWoNotCompletedPreM = 0;

        for (OrderTypeWrapper wrapper : summary) {
            totalWorkOrderCount += wrapper.otTotal_count;
            totalWoCompletedCount += wrapper.otCompleted_count;
            totalWoNotCompletedCount += wrapper.otNotCompleted_count;
            totalWoNotCompletedPreM += wrapper.otNotCompleted_preM;
        } //pm별 합계
        
        //pm별 합계 + 하자
        totalWorkOrderCount+=workOrderCount;
        totalWoCompletedCount+=woCompletedCount;
        totalWoNotCompletedCount+=woNotCompletedCount;
        totalWoNotCompletedPreM+=woPreNotCompletedCount;

        //////////////////////////////////// KPI 현황 /////////////////////////////////

        //2시간or1일이내
        List<WorkOrder> towHourList = [SELECT Id ,caseId ,Case.RepairRequestDateTime__c, ActualDispatchTime__c 
                                             ,CreatedDate ,completionTime__c
                                             ,(SELECT Department__c, Status FROM ServiceAppointments WHERE Department__c != null)
                                       FROM WorkOrder 
                                       WHERE caseId != '' AND CreatedDate = THIS_MONTH];


        double towHrTotalCount = 0; //발생
        double towHrCompletedCount = 0; //2시간 처리
        double towHrNotCompletedCount = 0; //2시간 지연
        double hr24CompletedCount = 0; //1일이내 처리
        double hr24NotCompletedCount = 0; //1일이내 지연

        for(WorkOrder w : towHourList){
            towHrTotalCount++;
            //2시간
            if(w.ActualDispatchTime__c != null && w.Case.RepairRequestDateTime__c != null){
                Integer ti = Integer.valueOf((w.ActualDispatchTime__c.getTime() - w.Case.RepairRequestDateTime__c.getTime()) / (1000 * 60));
                if(ti <= 120){
                    towHrCompletedCount++;
                } else {
                    towHrNotCompletedCount++;
                }
            } else { //날짜가 없는것도 미결
                towHrNotCompletedCount++;
            }
            
            //1일이내
            if(w.completionTime__c != null){
                Integer ti2 = Integer.valueOf((w.completionTime__c.getTime() - w.CreatedDate.getTime()) / (1000 * 60));
                if(ti2 <= 1440){
                    hr24CompletedCount++;
                } else {
                    hr24NotCompletedCount++;
                }
            } else { //날짜가 없는것도 미결
                hr24NotCompletedCount++;
            }
        }


        //콜서비스처리율
        List<Case> callList = [SELECT Id, (SELECT Id FROM WorkOrders), Status, EndOfReason__c
                               FROM Case 
                               WHERE Id NOT IN (SELECT CaseId FROM WorkOrder) AND ApplicationDateTime__c = THIS_MONTH LIMIT 50000];

        double callTotalCount = 0; //발생수
        double callCompletedCount = 0; //처리수
        double callNotCompletedCount = 0; //지연수
        for(Case c : callList){
            callTotalCount++;
            if(c.EndOfReason__c =='Call Service' && c.Status =='Closed'){
                callCompletedCount++;
            } else {
                callNotCompletedCount++;
            }
        }
        
        //야간/휴일
        Set<Date> holidays = new Set<Date>();

        double nightTotalCount = 0;            //야간 발생 수
        double nightCompletedCount = 0;        //야간 처리 수
        double nightNotCompletedCount = 0;     //야간 지연 수
        double holidayTotalCount = 0;          //휴일 발생 수
        double holidayCompletedCount = 0;      //휴일 처리 수
        double holidayNotCompletedCount = 0;   //휴일 지연 수
        for (Holiday h : [SELECT ActivityDate FROM Holiday WHERE IsAllDay = TRUE]) {
            holidays.add(h.ActivityDate);
        }

        for (WorkOrder w : towHourList) {
            for(ServiceAppointment sa : w.ServiceAppointments){
                if (sa.Department__c != null) {
                    //야간
                    if (sa.Department__c.hour() >= 17) {
                        nightTotalCount++;
                        if(sa.Status == 'Completed'){
                            nightCompletedCount++;
                        } else {
                            nightNotCompletedCount++;
                        }
                    }

                    //휴일 
                    String dayOfWeekStr = sa.Department__c.format('u');
                    Integer dayOfWeek = Integer.valueOf(dayOfWeekStr);
                    Date departmentDate = sa.Department__c.date(); 

                    // 토요일(6) or 일요일(7) or Holiday 체크
                    if (dayOfWeek == 6 || dayOfWeek == 7 || holidays.contains(departmentDate)) {
                        holidayTotalCount++;
                        if(sa.Status == 'Completed'){
                            holidayCompletedCount++;
                        } else {
                            holidayNotCompletedCount++;
                        }
                    }
                }
            }
        }



        //콜센터 상세정보
        res.failureReceipt_count = Integer.valueOf(failReceiptCount);
        res.failureReceipt_rate = Integer.valueOf(callcenterTotalCount>0?(failReceiptCount/callcenterTotalCount)*100:0);
        res.customerComplain_count = Integer.valueOf(customerComplainCount);
        res.customerComplain_rate = Integer.valueOf(callcenterTotalCount>0?(customerComplainCount/callcenterTotalCount)*100:0);
        res.callService_count = Integer.valueOf(callServiceCount);
        res.callService_rate = Integer.valueOf(callcenterTotalCount>0?(callServiceCount/callcenterTotalCount)*100:0);
        res.voc_count = Integer.valueOf(vocCount);
        res.voc_rate = Integer.valueOf(callcenterTotalCount>0?(vocCount/callcenterTotalCount)*100:0);
        //서비스업무 계획대비 실행률
        res.workOrder_count = Integer.valueOf(workOrderCount);
        res.woCompleted_count = Integer.valueOf(woCompletedCount);
        res.woNotCompleted_count = Integer.valueOf(woNotCompletedCount);
        res.woNotCompleted_rate = Integer.valueOf(workOrderCount>0?(woCompletedCount/workOrderCount)*100:0);
        res.woNotCompleted_preM = Integer.valueOf(woPreNotCompletedCount);
        res.orderTypeWrap = summary;
        res.total_count = Integer.valueOf(totalWorkOrderCount);
        res.totalCompleted_count = Integer.valueOf(totalWoCompletedCount);
        res.totalNotCompleted_count = Integer.valueOf(totalWoNotCompletedCount);
        res.totalNotCompleted_rate = Integer.valueOf(totalWorkOrderCount>0 ? (totalWoCompletedCount/totalWorkOrderCount)*100 : 0);
        res.totalNotCompleted_preM = Integer.valueOf(totalWoNotCompletedPreM);

        //KPI 현황
        res.towHrTotal_count = Integer.valueOf(towHrTotalCount);
        res.towHrCompleted_count = Integer.valueOf(towHrCompletedCount);
        res.towHrNotCompleted_count = Integer.valueOf(towHrNotCompletedCount);
        res.towHrCompleted_rate = Integer.valueOf(towHrTotalCount>0?(towHrCompletedCount/towHrTotalCount)*100:0);
        res.hr24Total_count = Integer.valueOf(towHrTotalCount);
        res.hr24Completed_count = Integer.valueOf(hr24CompletedCount);
        res.hr24NotCompleted_count = Integer.valueOf(hr24NotCompletedCount);
        res.hr24Total_rate = Integer.valueOf(towHrTotalCount>0?(hr24CompletedCount/towHrTotalCount)*100:0);
        res.callTotal_count = Integer.valueOf(callTotalCount);
        res.callCompleted_count = Integer.valueOf(callCompletedCount);
        res.callNotCompleted_count = Integer.valueOf(callNotCompletedCount);
        res.callTotalCompleted_count = Integer.valueOf(callTotalCount>0?(callCompletedCount/callTotalCount)*100:0);
        res.nightTotal_count = Integer.valueOf(nightTotalCount);
        res.nightCompleted_count = Integer.valueOf(nightCompletedCount);
        res.nightNotCompleted_count = Integer.valueOf(nightNotCompletedCount);
        res.nightTotal_rate = Integer.valueOf(nightTotalCount>0?(nightCompletedCount/nightTotalCount)*100:0);
        res.holidayTotal_count = Integer.valueOf(holidayTotalCount);
        res.holidayCompleted_count = Integer.valueOf(holidayCompletedCount);
        res.holidayNotCompleted_count = Integer.valueOf(holidayNotCompletedCount);
        res.holidayTotalCompleted_rate = Integer.valueOf(holidayTotalCount>0?(holidayCompletedCount/holidayTotalCount)*100:0);



        System.debug('::::::::::::::::'+caseList);


        return res;
    }

    //관리자통계 반환 DATA Mapping
    public class reportWrapper{
        //콜센터 상세정보
        @AuraEnabled public Integer failureReceipt_count    { get;set; } // 고장접수 건수
        @AuraEnabled public Integer failureReceipt_rate     { get;set; } // 고장접수 비율
        @AuraEnabled public Integer customerComplain_count  { get;set; } // 고객불만 건수
        @AuraEnabled public Integer customerComplain_rate   { get;set; } // 고객불만 비율
        @AuraEnabled public Integer callService_count       { get;set; } // 콜서비스 건수
        @AuraEnabled public Integer callService_rate        { get;set; } // 콜서비스 비율
        @AuraEnabled public Integer voc_count               { get;set; } // VOC 건수
        @AuraEnabled public Integer voc_rate                { get;set; } // VOC 비율
        
        //서비스업무 계획대비 실행률
        @AuraEnabled public Integer workOrder_count         { get;set; } //하자 발생
        @AuraEnabled public Integer woCompleted_count       { get;set; } //하자 처리
        @AuraEnabled public Integer woNotCompleted_count    { get;set; } //하자 미결
        @AuraEnabled public Integer woNotCompleted_rate     { get;set; } //하자 실행율
        @AuraEnabled public Integer woNotCompleted_preM     { get;set; } //하자 전월미결
        @AuraEnabled public List<OrderTypeWrapper> orderTypeWrap { get;set; } //order type 별 집계
        @AuraEnabled public Integer total_count                  { get;set; } //합계 발생
        @AuraEnabled public Integer totalCompleted_count         { get;set; } //합계 처리
        @AuraEnabled public Integer totalNotCompleted_count      { get;set; } //합계 미결
        @AuraEnabled public Integer totalNotCompleted_rate       { get;set; } //합계 실행율
        @AuraEnabled public Integer totalNotCompleted_preM       { get;set; } //합계 전월미결

        //KPI 현황
        @AuraEnabled public Integer towHrTotal_count            { get;set; } // 2시간 발생
        @AuraEnabled public Integer towHrCompleted_count        { get;set; } // 2시간 처리
        @AuraEnabled public Integer towHrNotCompleted_count     { get;set; } // 2시간 지연
        @AuraEnabled public Integer towHrCompleted_rate         { get;set; } // 2시간 처리율
        @AuraEnabled public Integer hr24Total_count             { get;set; } // 1시간 발생
        @AuraEnabled public Integer hr24Completed_count         { get;set; } // 1시간 처리
        @AuraEnabled public Integer hr24NotCompleted_count      { get;set; } // 1시간 지연
        @AuraEnabled public Integer hr24Total_rate              { get;set; } // 1시간 처리율
        @AuraEnabled public Integer callTotal_count             { get;set; } // 콜서비스 발생
        @AuraEnabled public Integer callCompleted_count         { get;set; } // 콜서비스 처리
        @AuraEnabled public Integer callNotCompleted_count      { get;set; } // 콜서비스 지연
        @AuraEnabled public Integer callTotalCompleted_count    { get;set; } // 콜서비스 처리율
        @AuraEnabled public Integer nightTotal_count            { get;set; } // 야간출동 발생
        @AuraEnabled public Integer nightCompleted_count        { get;set; } // 야간출동 처리
        @AuraEnabled public Integer nightNotCompleted_count     { get;set; } // 야간출동 지연
        @AuraEnabled public Integer nightTotal_rate             { get;set; } // 야간출동 처리율
        @AuraEnabled public Integer holidayTotal_count          { get;set; } // 휴일출동 발생
        @AuraEnabled public Integer holidayCompleted_count      { get;set; } // 휴일출동 처리
        @AuraEnabled public Integer holidayNotCompleted_count   { get;set; } // 휴일출동 지연
        @AuraEnabled public Integer holidayTotalCompleted_rate  { get;set; } // 휴일출동 처리율
        

        public reportWrapper(){
            //콜센터 상세정보
            this.failureReceipt_count = 0;
            this.failureReceipt_rate = 0;
            this.customerComplain_count = 0;
            this.customerComplain_rate = 0;
            this.callService_count = 0;
            this.callService_rate = 0;
            this.voc_count = 0;
            //서비스업무 계획대비 실행률
            this.workOrder_count = 0;
            this.woCompleted_count = 0;
            this.woNotCompleted_count = 0;
            this.woNotCompleted_rate = 0;
            this.woNotCompleted_preM = 0;
            this.orderTypeWrap = new List<OrderTypeWrapper>();
            this.total_count = 0;
            this.totalCompleted_count = 0;
            this.totalNotCompleted_count = 0;
            this.totalNotCompleted_rate = 0;
            this.totalNotCompleted_preM = 0;

            //KPI 현황
            this.towHrTotal_count = 0;
            this.towHrCompleted_count = 0;
            this.towHrNotCompleted_count = 0;
            this.towHrCompleted_rate = 0;
            this.hr24Total_count = 0;
            this.hr24Completed_count = 0;
            this.hr24NotCompleted_count = 0;
            this.hr24Total_rate = 0;
            this.callTotal_count = 0;
            this.callCompleted_count = 0;
            this.callNotCompleted_count = 0;
            this.callTotalCompleted_count = 0;
            this.nightTotal_count = 0;
            this.nightCompleted_count = 0;
            this.nightNotCompleted_count = 0;
            this.nightTotal_rate = 0;
            this.holidayTotal_count = 0;
            this.holidayCompleted_count = 0;
            this.holidayNotCompleted_count = 0;
            this.holidayTotalCompleted_rate = 0;
        }
    }

    public class OrderTypeWrapper{
        @AuraEnabled public String orderType              { get; set;} // order type 명
        @AuraEnabled public Integer otTotal_count         { get; set;} // order type 발생
        @AuraEnabled public Integer otCompleted_count     { get; set;} // order type 처리
        @AuraEnabled public Integer otNotCompleted_count  { get; set;} // order type 미결
        @AuraEnabled public Integer otTotalCompleted_rate { get; set;} // order type 실행율
        @AuraEnabled public Integer otNotCompleted_preM   { get; set;} // order type 전월미결

        public OrderTypeWrapper(){
            this.orderType = '';
            this.otTotal_count = 0;
            this.otCompleted_count = 0;
            this.otNotCompleted_count = 0;
            this.otTotalCompleted_rate = 0;
            this.otNotCompleted_preM = 0;
        }
    }    
}