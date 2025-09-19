/**
 * @author            : Yeong-Deok Seo
 * @Description       : 혁신관리지표 Report 화면
 * @last modified on  : 2025-04-04
 * @last modified by  : yeongdeok.seo@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-04-04   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_InnovationManageController {

    //조건에 부합하는 혁신관리지표 DATA 반환
    @AuraEnabled
    public static TickettWrapper getData(datetime dateTo, datetime dateFrom){
        TickettWrapper res = new TickettWrapper();

        Datetime fromDate = Datetime.newInstance(dateFrom.year(), dateFrom.month(), dateFrom.day(), 0, 0, 0);
        Datetime toDate = Datetime.newInstance(dateTo.year(), dateTo.month(), dateTo.day(), 23, 59, 59);

        System.debug('toDate:'+toDate);
        System.debug('fromDate:'+fromDate);

        List<case> cs = [SELECT Id , Status, TechAssignedDatetime__c, ApplicationDateTime__c
                                ,(SELECT Id, CreatedDate, caseID, Status, Service_Appointment__r.Department__c, TimeAgreedOnSite__c FROM WorkOrders)
                         FROM Case 
                         WHERE ApplicationDateTime__c <=: toDate AND ApplicationDateTime__c >=: fromDate];

        List<AssignReject__c> ar = [SELECT Id, Name, work_order__c
                                    FROM AssignReject__c
                                    WHERE work_order__c IN (SELECT Id FROM WorkOrder WHERE CreatedDate <=: toDate and CreatedDate >=: fromDate)];
        
        if(cs.size() == 0){
            res.TechAssigned_total = '0% = 0/0';
            res.TechAssigned_10min = '0% = 0/0';
            res.TechAssigned_20min = '0% = 0/0';
            res.TechAssigned_30min = '0% = 0/0';
            res.TechAssigned_40min = '0% = 0/0';
            res.TechAssigned_50min = '0% = 0/0';
            res.callService = '0% = 0 / (0 + 0)';
            res.WorkerAssigned = '0% = 0 / 0';
            res.WorkerNotAssigned = '0% = 0 / 0';
            res.WorkerDeclineAssigned = '0% = 0 / 0';
            res.Worker_2hour = '0% ';
            res.Worker_Departure_reply = '0%';
            res.Worker_Reservation_reply = '0%';
            return res;
        }

        /*
         * 받은전환호     : TechAssignedDatetime__c 가 있는거
         * 콜생성건       : wo가 없는 티켓 중 상태가 종결
         * 오더생성건     : wo가 있는 티켓
         * 1차접수건수    : wo가 없는 티켓
         * 출동기사배정   : wo가 있고 Status == 'Assigned'
         * 출동기사미배정 : wo가 있고 status가 'AssignedRefused', 'Uncompleted' 가 아님 +배정완료도 아니여야할듯
         * 출동배정건     : wo 있고 status가 'AssignedRefused' 아님
         * 거절           : AssignReject__c 있음음
         * 2시간이내출동건 : Service_Appointment__r.Department__c 에서 ApplicationDateTime__c 시간 차이
         * 전체배정건     : AssignedRefused, 'Uncompleted'를 제외한 wo 건수
         * 출발회신건     : Service_Appointment__c 오브젝트(ServiceAppointment) 에서 Department__c 있는거
         * 예약회신건     : workorder의 TimeAgreedOnSite__c 가 찍힌 건수
        */
        Integer dateDifference=0;
        double out_total = 0; // 받은전환호 
        double min10 = 0;
        double min20 = 0;
        double min30 = 0;
        double min40 = 0;
        double min50 = 0;
        double callCount = 0; //콜생성건 
        double orderCount = 0; //오더생성건
        double firstAccCount = 0; //1차접수건수
        double workerAssCount = 0; //출동기사배정
        double workerNoAssCount = 0; //출동기사미배정 
        double WorkerDeclineAssCount = 0; //출동배정건
        double DeclineCount = 0; //거절
        double work2hour = 0; //2시간이내 출동건
        double totalCount = 0; // 전체배정건
        double DepartureReply = 0; // 출발회신건 
        double ReservationReply = 0; // 예약회신건

        for (Case c : cs) {
            if (c.WorkOrders.size() == 0 ) { //wo 생성 X  
                firstAccCount++;
                if(c.Status == 'Closed') { //티켓 종결
                    callCount++;
                }
            } else if (c.WorkOrders.size() > 0) { // wo 생성
                for(WorkOrder w : c.WorkOrders){ //같은 기간 생성된 wo 중에 n분처리
                    orderCount++;
                    if(c.TechAssignedDatetime__c != null){
                        dateDifference = Integer.valueOf((w.CreatedDate.getTime() - c.TechAssignedDatetime__c.getTime()) / (1000 * 60));
                        if(dateDifference <= 10) {
                            min10++;
                        } 
                        if(dateDifference <= 20){
                            min20++;
                        } 
                        if(dateDifference <= 30){
                            min30++;
                        } 
                        if(dateDifference <= 40){
                            min40++;
                        } 
                        if(dateDifference <= 50){
                            min50++;
                        }
                        out_total++;
                    }

                    if(w.Status == 'Assigned'){
                        workerAssCount++;
                    }

                    if(w.Status !='AssignedRefused' && w.Status != 'Uncompleted' && w.status != 'Assigned'){
                        workerNoAssCount++;
                    }

                    if(w.Status != 'AssignedRefused' && w.Status != 'Uncompleted' ){
                        WorkerDeclineAssCount++;
                    }

                    if(w.Status != 'AssignedRefused'){
                        totalCount++;
                    }

                    if(w.Service_Appointment__r.Department__c != null){
                        DepartureReply++;
                        Integer ti = Integer.valueOf((w.Service_Appointment__r.Department__c.getTime() - c.ApplicationDateTime__c.getTime()) / (1000 * 60));
                        if(ti <= 120){
                            work2hour++;
                        }
                    }

                    if(w.TimeAgreedOnSite__c != null){
                        ReservationReply++;
                    }

                }
            }

        }


        Integer rateTotal = Integer.valueOf(out_total / orderCount * 100);
        Integer rate10 = Integer.valueOf(min10 / orderCount * 100);
        Integer rate20 = Integer.valueOf(min20 / orderCount * 100);
        Integer rate30 = Integer.valueOf(min30 / orderCount * 100);
        Integer rate40 = Integer.valueOf(min40 / orderCount * 100);
        Integer rate50 = Integer.valueOf(min50 / orderCount * 100);
        Integer rateCall = Integer.valueOf(callCount / (orderCount+callCount) * 100);
        Integer rateWorkerAssCount = Integer.valueOf(workerAssCount / (orderCount+firstAccCount) * 100);
        Integer rateWorkerNoAssCount = Integer.valueOf(workerNoAssCount / (orderCount+firstAccCount) * 100);
        Integer rateWorkerDeclineAssCount = Integer.valueOf(ar.size()/WorkerDeclineAssCount * 100);
        Integer rateWork2hour = Integer.valueOf(work2hour/WorkerDeclineAssCount * 100);
        Integer rateDepartureReply =  Integer.valueOf(DepartureReply/totalCount * 100);
        Integer rateReservationReply = Integer.valueOf(ReservationReply/totalCount * 100);
        
        //비율계산
        res.TechAssigned_total = rateTotal+'% = ' + Integer.valueOf(out_total) +' / '+ Integer.valueOf(orderCount);
        res.TechAssigned_10min = rate10 +'% = ' + Integer.valueOf(min10) +' / '+ Integer.valueOf(orderCount);
        res.TechAssigned_20min = rate20 +'% = ' + Integer.valueOf(min20) +' / '+ Integer.valueOf(orderCount);
        res.TechAssigned_30min = rate30 +'% = ' + Integer.valueOf(min30) +' / '+ Integer.valueOf(orderCount);
        res.TechAssigned_40min = rate40 +'% = ' + Integer.valueOf(min40) +' / '+ Integer.valueOf(orderCount);
        res.TechAssigned_50min = rate50 +'% = ' + Integer.valueOf(min50) +' / '+ Integer.valueOf(orderCount);
        res.callService = Integer.valueOf(callCount) +'% = '+ Integer.valueOf(callCount) + '/ '+Integer.valueOf(orderCount+callCount);
        res.WorkerAssigned = rateWorkerAssCount + '% = '+Integer.valueOf(workerAssCount)+' / '+Integer.valueOf(orderCount+firstAccCount);
        res.WorkerNotAssigned = rateWorkerNoAssCount +'% = '+Integer.valueOf(workerNoAssCount)+' / '+Integer.valueOf(orderCount+firstAccCount);
    
        res.WorkerDeclineAssigned = rateWorkerDeclineAssCount+'% = '+ar.size()+' / '+Integer.valueOf(WorkerDeclineAssCount); //거절수가 맞는지 모르겠네;
        res.Worker_2hour = rateWork2hour+'% = '+ Integer.valueOf(work2hour) +' / '+ Integer.valueOf(WorkerDeclineAssCount); //데이터생성후 확인
    
        res.Worker_Departure_reply = rateDepartureReply+'% = '+Integer.valueOf(DepartureReply)+' / '+Integer.valueOf(totalCount);
        res.Worker_Reservation_reply = rateReservationReply+'% = '+Integer.valueOf(ReservationReply)+' / '+Integer.valueOf(totalCount);


        return res;
    }

    //혁신관리지표 반환 DATA Mapping Wrapper
    public class TickettWrapper{
        @AuraEnabled public String TechAssigned_total       { get;set; } // 기술상담 직접연결율(성공율)
        @AuraEnabled public String TechAssigned_10min       { get;set; } // 1차접수후 기술상담 처리율(10분)
        @AuraEnabled public String TechAssigned_20min       { get;set; } // 1차접수후 기술상담 처리율(20분)
        @AuraEnabled public String TechAssigned_30min       { get;set; } // 1차접수후 기술상담 처리율(30분)
        @AuraEnabled public String TechAssigned_40min       { get;set; } // 1차접수후 기술상담 처리율(40분)
        @AuraEnabled public String TechAssigned_50min       { get;set; } // 1차접수후 기술상담 처리율(50분)
        @AuraEnabled public String callService              { get;set; } // 콜서비스 처리율
        @AuraEnabled public String WorkerAssigned           { get;set; } // 출동배정율-당일배정율 
        @AuraEnabled public String WorkerNotAssigned        { get;set; } // 출동배정율-당일미배정율 
        @AuraEnabled public String WorkerDeclineAssigned    { get;set; } // 출동배정 거절율
        @AuraEnabled public String Worker_2hour             { get;set; } // 출동기사 2시간이내 출동율
        @AuraEnabled public String Worker_Departure_reply   { get;set; } // 출동기사 출발/예약 회신율 -출발회신율 
        @AuraEnabled public String Worker_Reservation_reply { get;set; } // 출동기사 출발/예약 회신율 -예약회신율  
    }
}