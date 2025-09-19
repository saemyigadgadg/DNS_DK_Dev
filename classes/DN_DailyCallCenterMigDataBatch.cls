/**
 * @author            : Yeong-Deok Seo
 * @description       : Daily Call Center Report용 Migration DATA 적재 Batch
 * @last modified on  : 2025-06-09
 * @last modified by  : yeongdeok.seo@sbtglobal.com
**/
public with sharing class DN_DailyCallCenterMigDataBatch implements Database.Batchable<String>, Database.Stateful, Schedulable{

    public Map<String, List<Task>> taskMap = new Map<String, List<Task>>();
    public Date taskStartDate;
    public Date taskEndDate;

    public DN_DailyCallCenterMigDataBatch() {}

    public List<String> start(Database.BatchableContext context){
        List<Task> taskList = [SELECT Id, ActivityDate, WhatId 
                                FROM Task
                                WHERE CreatedBy.Name LIKE '%admin%'
                                AND ActivityDate >= :taskStartDate
                                AND ActivityDate <= :taskEndDate
                                AND CallType__c = 'Inbound Call' 
                                AND RecordType.Name = 'Service'];

        for (Task task : taskList) {
            String key = String.valueOf(task.ActivityDate);
            if (taskMap.containsKey(key)) {
                List<Task> valueList = taskMap.get(key);
                valueList.add(task);
                taskMap.put(key, valueList);
            } else {
                taskMap.put(key, new List<Task>{task});
            }
        }

        // String testKey = String.valueOf(taskList[1].ActivityDate);

        if (!Test.isRunningTest()) return new List<String>(taskMap.keySet());
        else return new List<String>{'2024-12-23'};
    }

    public void execute(Database.BatchableContext context, List<String> scope) {
        System.debug(' =============== Batch Execute ================');
        System.debug('scope.Size() : ' + scope.size());
        System.debug('scope : ' + scope);
        System.debug('scope : ' + scope[0]);

        String key = scope[0];

        Datetime startDate = getStartDatetime(key);
        Datetime endDate = getEndDatetime(key);

        List<Task> valueList = taskMap.get(key);

        Savepoint sp;
        try{
            //--------------------- 상담 Section Field ----------------------
            Integer inboundCnt = valueList.size(); //인입콜 건수
            Integer newTicketCnt = 0; //새로 생서된 Ticket 건수
            Integer techCnt = 0; //기술상담 건수
            Integer callServiceCnt = 0; //기술상담 중 콜서비스 건수
            Integer noOutboundCnt = 0; //기술상담 중 미상담 건수
            Integer failureCnt = 0; //기술상담 중 고장접수 건수
            Integer noAssignCnt = 0; //고장접수 중 미배정 건수

            Integer replyCnt = 0; //미배정 중 고객회신대기 건수
            Integer warrantyCnt = 0; //미배정 중 유무상판정 건수
            Integer techChknCnt = 0; //미배정 중 기술검토 건수
            Integer delayAssignCnt = 0; //미배정 중 배정지연 건수
            Integer noCustomerCnt = 0; //미배정 중 고객부재 건수

            Integer over20minCnt = 0; //새로 생성된 Ticket 중 Outbound 하는데 20분 초과건수

            //--------------------- 배정 Section Field ----------------------
            Integer assignCnt = 0; //총 배정건수
            Integer branchCnt = 0; //지사에게 배정된 건수(POST 포함)
            Integer wcCnt = 0; //정비업체에 배정된 건수
            Integer woOver20Cnt = 0; //상담 후 20분 지나서 배정된 건수

            //--------------------- 접수 Section Field ----------------------
            //접수건수는 배정건수와 동일일
            Integer incheon = 0; //인천지사에 배정된 건수
            Integer suwon = 0; //수원지사에 배정된 건수
            Integer deajeon = 0; //대전전지사에 배정된 건수
            Integer deagu = 0; //대구구지사에 배정된 건수
            Integer busan = 0; //부산지사에 배정된 건수
            Integer changwon = 0; //창원지사에 배정된 건수
            Integer cheonan = 0; //천안지사에 배정된 건수
            Integer gwangju = 0; //광주지사에 배정된 건수
            Integer ulsan = 0; //울산지사에 배정된 건수

            //--------------------- 출동 Section Field ----------------------
            //총 출동 대상건수는 배정건수와 동일일
            Integer todayCnt = 0; //당일 출동 건수
            Integer tomorrowCnt = 0; //익일 출동 건수

            //-------------------- 마감관리 Section Field ---------------------
            Integer scheduleCnt = 0; //예약관리 건수
            Integer closedTodayCnt = 0; //당일 종결 건수
            Integer confirmCnt = 0; //일일 모니터링 확인
            Integer unconfirmCnt = 0; //일일 모니터링 미확인




            //WhatId 목록에서 새로생성된건지 확인
            Set<Id> ticketIDs = new Set<Id>();
            for(Task obj : valueList){ 
                ticketIDs.add(obj.WhatId);
            }

            //어제 생성된 Ticket 존재유무
            if(ticketIDs.size() > 0){
                List<Case> ticketList = [SELECT Id, TicketType__c
                                            FROM Case
                                            WHERE ID IN :ticketIDs
                                            AND ApplicationDateTime__c >= :startDate
                                            AND ApplicationDateTime__c <= :endDate];
                newTicketCnt = ticketList.size();
            }

           
            if(newTicketCnt > 0){
                //생성된 Ticket 중 기술상담 건수
                List<Case> techList = [SELECT Id, TicketType__c, Status 
                                        FROM Case 
                                        WHERE ID IN :ticketIDs 
                                        AND ApplicationDateTime__c >= :startDate
                                        AND ApplicationDateTime__c <= :endDate
                                        AND TicketType__c = 'Technical inquiry'];
                techCnt = techList.size();

                //20분 초과 건수 => over20minCnt / newTicketCnt * 100
                List<Case> over20minList = [SELECT Id, FM_FirstOutbound__c, FM_Over20Min__c FROM Case
                                                    WHERE ID IN :ticketIDs 
                                                    AND ApplicationDateTime__c >= :startDate
                                                    AND ApplicationDateTime__c <= :endDate
                                                    AND FM_Over20Min__c = TRUE];
                over20minCnt = over20minList.size();
            }

            if(techCnt > 0){
                //콜서비스란? WorkOrder 생성되지 않고 종결된 것 
                //기술상담 중 콜서비스 건수
                List<Case> callServiceList = [SELECT Id FROM Case WHERE ID IN :ticketIDs 
                                                        AND ApplicationDateTime__c >= :startDate
                                                        AND ApplicationDateTime__c <= :endDate
                                                        AND TicketType__c = 'Technical inquiry' 
                                                        AND Status = 'Closed'
                                                        AND EndOfReason__c = 'Call Service']; 
                callServiceCnt = callServiceList.size();

                //미상담 건수 = 기술상담사가 outbound 안한 건수
                List<Case> noOutboundList = [SELECT Id FROM Case WHERE ID IN :ticketIDs 
                                                        AND ApplicationDateTime__c >= :startDate
                                                        AND ApplicationDateTime__c <= :endDate
                                                        AND TicketType__c = 'Technical inquiry' 
                                                        AND TechnicalCallDatetime__c = NULL];
                noOutboundCnt = noOutboundList.size();

                //고장접수 건수
                List<Case> failureList = [SELECT Id, InternalTicketType__c, AssignHoldingReason__c FROM Case WHERE ID IN :ticketIDs 
                                                        AND ApplicationDateTime__c >= :startDate
                                                        AND ApplicationDateTime__c <= :endDate
                                                        AND TicketType__c = 'Technical inquiry' 
                                                        AND InternalTicketType__c = 'Failure receipt'];
                failureCnt = failureList.size();

                //고장접수 중 미배정 건수 + 배정지연사유
                if(failureCnt > 0){
                    for(Case c : failureList){
                        if(c.InternalTicketType__c == 'Failure receipt'){
                            noAssignCnt++;
                            
                            //배정지연사유
                            String holdingReason = String.isNotEmpty(c.AssignHoldingReason__c) ? c.AssignHoldingReason__c : '';
                            switch on holdingReason {
                                when 'Assignment delay'  {//배정지연
                                    delayAssignCnt ++;
                                }                        
                                when 'Waiting for customer reply' {//고객회신대기
                                    replyCnt ++;
                                }
                                when 'Determination of paid free' {//유무상판정
                                    warrantyCnt ++;
                                }
                                when 'Technical review' {//기술검토
                                    techChknCnt ++;
                                }
                                when 'Customer absence'{//고객부재
                                    noCustomerCnt ++;
                                }
                            }
                        }
                    }
                }
            }


            
            if(newTicketCnt > 0){
                //어제 생성된 배정 건수
                List<WorkOrder> assignList = [SELECT Id, Status, CreatedDate, TimeAgreedOnSite__c,
                                                Case.TechnicalCallDatetime__c, FM_Over20Min__c,
                                                ServiceTerritory.classify__c, ServiceTerritory.ControlWorkcenter__c, 
                                                ServiceTerritory.ControlWorkcenter__r.Name, ServiceTerritory.Name
                                                FROM WorkOrder WHERE CaseId IN : ticketIDs
                                                AND Case.ApplicationDateTime__c >= :startDate
                                                AND Case.ApplicationDateTime__c <= :endDate
                                                AND Status != 'AssignedRefused'];
                assignCnt= assignList.size();

                if(assignCnt > 0){
                    //============================================ 배정 Section ================================================

                    //상담 후 20분 넘게 지나서 배정된 Work Order 수수 
                    AggregateResult[] over20ar = [SELECT FM_Over20Min__c, COUNT(ID) Cnt 
                                                    FROM WorkOrder 
                                                    WHERE CaseId IN : ticketIDs
                                                    AND Case.ApplicationDateTime__c >= :startDate
                                                    AND Case.ApplicationDateTime__c <= :endDate
                                                    AND Status != 'AssignedRefused'
                                                    GROUP BY FM_Over20Min__c];
                    for (AggregateResult ar : over20ar) {
                        Boolean isOver20 = (Boolean) ar.get('FM_Over20Min__c');
                        Integer Cnt = (Integer) ar.get('Cnt');
                        if(isOver20) woOver20Cnt = Cnt;
                    }
    
                    //지사 & 정비업체 건수
                    AggregateResult[] branchAr = [SELECT ServiceTerritory.classify__c, COUNT(ID) Cnt 
                                                FROM WorkOrder 
                                                WHERE CaseId IN : ticketIDs
                                                AND Case.ApplicationDateTime__c >= :startDate
                                                AND Case.ApplicationDateTime__c <= :endDate
                                                AND Status != 'AssignedRefused'
                                                GROUP BY ServiceTerritory.classify__c];
    
                    for (AggregateResult ar : branchAr) {
                        String classify = (String) ar.get('classify__c');
                        Integer Cnt = (Integer) ar.get('Cnt');
                        if(classify == 'W/C'){
                            wcCnt = Cnt;
                        }else{
                            branchCnt = Cnt;
                        }  
                    }

                    //============================================ 접수 Section ================================================
                    for(WorkOrder wo : assignList){
                        String branch = '';
                        if(wo.ServiceTerritory.classify__c == 'W/C'){//정비업체
                            branch = wo.ServiceTerritory.ControlWorkcenter__r.Name;
                        }else {//지사, POST
                            branch = wo.ServiceTerritory.Name;
                        }

                        switch on branch {
                            when '인천지사'  {
                                incheon ++;
                            }                        
                            when '수원지사' {
                                suwon ++;
                            }
                            when '대전지사' {
                                deajeon ++;
                            }
                            when '대구지사'{
                                deagu ++;
                            }
                            when '부산지사' {
                                busan ++;
                            }
                            when '창원지사'{
                                changwon ++;
                            }
                            when '천안POST' {
                                cheonan ++;
                            }
                            when '광주POST' {
                                gwangju ++;
                            }
                            when '울산POST' {
                                ulsan ++;
                            }
                        }
                    }

                    //============================================ 출동 Section ================================================
                    //출동예정일 기준으로 WorkOrder Count
                    AggregateResult[] dayAr = [SELECT DAY_ONLY(TimeAgreedOnSite__c) diaptchDate, COUNT(ID) Cnt
                                                    FROM WorkOrder 
                                                    WHERE CaseId IN : ticketIDs
                                                    AND Case.ApplicationDateTime__c >= :startDate
                                                    AND Case.ApplicationDateTime__c <= :endDate
                                                    AND Status != 'AssignedRefused'
                                                    AND ((TimeAgreedOnSite__c >= :startDate AND TimeAgreedOnSite__c <= :endDate) OR (TimeAgreedOnSite__c >= :startDate.addDays(1) AND TimeAgreedOnSite__c <= :endDate.addDays(1))) 
                                                    GROUP BY DAY_ONLY(TimeAgreedOnSite__c)];
                    if(dayAr.size() > 0){
                        for (AggregateResult ar : dayAr) {
                            Date dispatchDate = (Date) ar.get('dispatchDate');
                            Integer Cnt = (Integer) ar.get('Cnt');
                            if(dispatchDate == Date.today().addDays(-1)){
                                todayCnt = Cnt;
                            }else{
                                tomorrowCnt = Cnt;
                            }
                        }
                    }
                }

                //============================================ 마감관리 Section ================================================
                scheduleCnt = [SELECT COUNT() FROM WorkOrder 
                                                WHERE CaseId IN : ticketIDs
                                                AND Case.ApplicationDateTime__c >= :startDate
                                                AND Case.ApplicationDateTime__c <= :endDate
                                                AND Status != 'AssignedRefused'
                                                AND TimeAgreedOnSite__c != null];

                closedTodayCnt = [SELECT COUNT() FROM WorkOrder 
                                                WHERE CaseId IN : ticketIDs
                                                AND Case.ApplicationDateTime__c >= :startDate
                                                AND Case.ApplicationDateTime__c <= :endDate
                                                AND Status != 'AssignedRefused'
                                                AND completionTime__c >= :startDate
                                                AND completionTime__c <= :endDate];                        
                                                      
                AggregateResult[] monitorAr = [SELECT CheckResults__c, COUNT(ID) Cnt
                                                FROM WorkOrder 
                                                WHERE CaseId IN : ticketIDs
                                                AND Case.ApplicationDateTime__c >= :startDate
                                                AND Case.ApplicationDateTime__c <= :endDate
                                                AND Status != 'AssignedRefused'
                                                GROUP BY CheckResults__c];
                for (AggregateResult ar : monitorAr) {
                    String value = (String) ar.get('CheckResults__c'); 
                    Integer Cnt = (Integer) ar.get('Cnt');
                    if(value == 'Confirmed'){
                        confirmCnt = Cnt;
                    }else{
                        unconfirmCnt = Cnt;
                    }
                }                                
            }

            DailyCallCenter__c newRecord = new DailyCallCenter__c();
            newRecord.RecordDate__c =  convertDateString(key); //일자
            newRecord.InboundCallNum__c = inboundCnt; //인입콜 건수
            newRecord.ServiceReception__c = newTicketCnt; //새로 생성된 Ticket 건수
            newRecord.TechnicalInquiry__c = techCnt; //기술상담 건수 --> 새로 만들어야 함
            newRecord.CallService__c = callServiceCnt; //기술상담 중 콜서비스 건수
            newRecord.NoCall__c = noOutboundCnt; //기술상담 중 미상담 건수
            newRecord.FailureReceipt__c = failureCnt; //기술상담 중 고장접수 건수 --> 새로 만들어야 함
            newRecord.NoAssign__c = noAssignCnt; //고장접수 중 미배정 건수
            newRecord.WaitingForCustomerResponse__c = replyCnt; //미배정 중 고객회신대기 건수
            newRecord.WarrantyDetermination__c = warrantyCnt; //미배정 중 유무상판정 건수
            newRecord.TechnicalReview__c = techChknCnt; //미배정 중 기술검토 건수
            newRecord.AssignHolding__c	 = delayAssignCnt; //미배정 중 배정지연 건수
            newRecord.CustomerAbsence__c = noCustomerCnt; //미배정 중 고객부재 건수
            newRecord.Exceeding20Min__c = over20minCnt; //새로 생성된 Ticket 중 Outbound 하는데 20분 초과건수
            newRecord.AssignNumAll__c = assignCnt; //총 배정건수
            newRecord.Branch__c = branchCnt; //지사에게 배정된 건수(POST 포함)
            newRecord.WorkCenter__c = wcCnt; //정비업체에 배정된 건수
            newRecord.AssignExceeding20Min__c = woOver20Cnt; //상담 후 20분 지나서 배정된 건수
            newRecord.ReceptionNum__c = assignCnt;
            newRecord.Incheon__c = incheon; //인천지사에 배정된 건수
            newRecord.Suwon__c = suwon; //수원지사에 배정된 건수
            newRecord.Daejeon__c = deajeon; //대전전지사에 배정된 건수
            newRecord.Deagu__c = deagu; //대구구지사에 배정된 건수
            newRecord.Busan__c = busan; //부산지사에 배정된 건수
            newRecord.Changwon__c = changwon; //창원지사에 배정된 건수
            newRecord.Cheonan__c = cheonan; //천안지사에 배정된 건수
            newRecord.Gwangju__c = gwangju; //광주지사에 배정된 건수
            newRecord.Ulsan__c = ulsan; //울산지사에 배정된 건수
            newRecord.AllDispatchNum__c = assignCnt; //당일 출동 건수
            newRecord.DispatchOntheDay__c = todayCnt; //당일 출동 건수
            newRecord.DispatchTomorrow__c = tomorrowCnt; //익일 출동 건수
            newRecord.OnsiteManagement__c = scheduleCnt; //예약관리 건수
            newRecord.ClosedToday__c	 = closedTodayCnt; //당일 종결 건수
            newRecord.DailyMonitoringCheck__c = confirmCnt; //일일 모니터링 확인
            newRecord.DailyMonitoringUnCheck__c = unconfirmCnt; //일일 모니터링 미확인
            insert newRecord;

                  
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context){
        System.debug('배치 실행 완료');
    }

    public void execute(SchedulableContext sc) {
        DN_DailyCallCenterMigDataBatch batch = new DN_DailyCallCenterMigDataBatch();
        Database.executeBatch(batch, 200);        
    }

    private static Datetime getStartDatetime(String dateString){
        Integer year = Integer.valueOf(dateString.split('-')[0]);
        Integer month = Integer.valueOf(dateString.split('-')[1]);
        Integer day = Integer.valueOf(dateString.split('-')[2]);

        Datetime dt = Datetime.newInstance(year, month, day, 0, 0, 0);

        return dt;
    }

    private static Datetime getEndDatetime(String dateString){
        Integer year = Integer.valueOf(dateString.split('-')[0]);
        Integer month = Integer.valueOf(dateString.split('-')[1]);
        Integer day = Integer.valueOf(dateString.split('-')[2]);

        Datetime dt = Datetime.newInstance(year, month, day, 11, 59, 59);

        return dt;
    }

    private static Date convertDateString(String dateString){
        Integer year = Integer.valueOf(dateString.split('-')[0]);
        Integer month = Integer.valueOf(dateString.split('-')[1]);
        Integer day = Integer.valueOf(dateString.split('-')[2]);

        Date dt = Date.newInstance(year, month, day);

        return dt;
    }
}