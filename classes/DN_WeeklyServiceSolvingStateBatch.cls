/**
* @Class : DN_WeeklyServiceSolvingStateBatch
* @Version : 1.0
* @description : 주간서비스처리현황 Report Batch
*/
public with sharing class DN_WeeklyServiceSolvingStateBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, Schedulable{

    private String weekly;  // 주차
    private Integer orderCount                 = 0;   // 어제 order 접수건수
    private Integer repairCompleted 	       = 0;   // 수리종료
    private Integer dispatchSuspense 	       = 0;   // 출동미결
    private Integer notDispatch 	           = 0;   // 미출동
    private Integer parts 	                   = 0;   // 출동미결사유 : 부품
    private Integer closing 	               = 0;   // 출동미결사유 : 종결
    private Integer technical 	               = 0;   // 출동미결사유 : 기술
    private Integer account                    = 0;   // 출동미결사유 : 고객
    private Integer personal                   = 0;   // 출동미결사유 : 인원
    private Integer installation               = 0;   // 출동미결사유 : 설치
    private Integer notInputResult             = 0;   // 출동미결사유 : 결과미입력
    private Integer etc                        = 0;   // 출동미결사유 : 기타
    private Integer directFree 	               = 0;   // 직영무상
    private Integer salesSupport 	           = 0;   // 직영유상
    private Integer wcFree 	                   = 0;   // 업체무상
    private Integer wcIsPay 	               = 0;   // 업체유상
    private Date manageDate                    = System.today().addDays(-1); // 기준일자
    private Date sampleDate                    = Date.newInstance(2025, 01, 12);

    public DN_WeeklyServiceSolvingStateBatch(){
        System.debug('manageDate: ' + manageDate);

        Integer year = this.manageDate.year();
        Integer month = this.manageDate.month();
    
        // 해당 월의 첫 번째 날 가져오기
        Date firstDayOfMonth = Date.newInstance(year, month, 1);
        System.debug('firstDayOfMonth: ' + firstDayOfMonth);
    
        // 해당 월의 첫 번째 일요일 계산
        Date firstSunday = firstDayOfMonth.toStartOfWeek();
        if (firstSunday < firstDayOfMonth) {
            firstSunday = firstSunday.addDays(7); // 첫 번째 일요일이 전 달에 포함된 경우 보정  // 첫번째 일요일보다 이후면 -days
        }
        System.debug('firstSunday: ' + firstSunday);

        // 주차 계산: manageDate가 firstSunday 이후일 때만 계산
        Integer weeks = 0;
        Integer daysDiff = manageDate.daysBetween(firstSunday); // 날짜 차이 계산
        System.debug('daysDiff: ' + daysDiff);

        if ((daysDiff > 0 || daysDiff == 0 && (firstDayOfMonth == firstSunday)) || (daysDiff < 0 && daysDiff > -7 && (firstDayOfMonth == firstSunday))) {
            weeks = 1;
        } else if ((daysDiff <= 0 && daysDiff > -7 && firstDayOfMonth != firstSunday) || (daysDiff < -7 && daysDiff > -14 && (firstDayOfMonth == firstSunday))) {
            weeks = 2;
        } else if(((firstDayOfMonth != firstSunday) && daysDiff < -6 && daysDiff > -14) || ((firstDayOfMonth == firstSunday) && daysDiff < -13 && daysDiff > -21)) {
            weeks = 3;
        } else if(((firstDayOfMonth != firstSunday) && daysDiff < -13 && daysDiff > -21) || ((firstDayOfMonth == firstSunday) && daysDiff < -20 && daysDiff > -28)) {
            weeks = 4;
        } else {
            weeks = 5;
        }
            
        System.debug('weeks: ' + weeks);
    
        // 주차 포맷 설정
        String monthStr = month < 10 ? '0' + String.valueOf(month) : String.valueOf(month);
        this.weekly = year + '-' + monthStr + ' ' + weeks + '주차';
        System.debug('weekly: ' + weekly);
    }

    public List<SObject> start(Database.BatchableContext context){
        return [SELECT Id, CreatedDate, completionTime__c, Status, ServiceTerritory.classify__c, OrderType__c FROM WorkOrder WHERE CreatedDate = Yesterday];
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.debug(' =============== Batch Execute ================');
        System.debug('scope.Size() : ' + scope.size());
        System.debug('scope : ' + scope);
        Savepoint sp;
        try{
            List<WorkOrder> woList = (List<WorkOrder>) scope;
            Set<Id> woIds = new Set<Id>();
            for(WorkOrder wo : woList) {
                woIds.add(wo.Id);
            }
            Map<Id, List<ServiceAppointment>> saMap = new Map<Id, List<ServiceAppointment>>();
            List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Pendingprocessing__c FROM ServiceAppointment WHERE ParentRecordId IN :woIds];
            for (ServiceAppointment sa : saList) {
                if (!saMap.containsKey(sa.ParentRecordId)) {
                    saMap.put(sa.ParentRecordId, new List<ServiceAppointment>());
                }
                saMap.get(sa.ParentRecordId).add(sa);
            }
            
            for(WorkOrder wo : woList) {
                orderCount++;
                List<ServiceAppointment> objList = saMap.get(wo.Id);
                // 수리종료 Count
                if(wo.completionTime__c != null || wo.Status == 'Completed') {
                    repairCompleted++;
                }
                // 미출동 Count
                if(wo.Status == 'Assigned' || wo.Status == 'AssignedRefused') {
                    notDispatch++;
                }
                // 출동미결 Count
                if(wo.Status == 'Started' || wo.Status == 'Arrived' || wo.Status == 'Uncompleted') {
                    dispatchSuspense++;
                }
                // 출동미결사유 Count
                if(objList != null && objList.size() > 0) {
                    for(ServiceAppointment sa : objList) {
                        // 부품
                        if(sa.Pendingprocessing__c == 'Parts') {
                            parts++;
                        }
                        // 종결
                        if(sa.Pendingprocessing__c == 'Closing') {
                            closing++;
                        }
                        // 고객
                        if(sa.Pendingprocessing__c == 'Customer') {
                            account++;
                        }
                        // 인원
                        if(sa.Pendingprocessing__c == 'Person') {
                            personal++;
                        }
                        // 기술
                        if(sa.Pendingprocessing__c == 'Technical Review' || sa.Pendingprocessing__c == 'Technical Design' || sa.Pendingprocessing__c == 'Technical Customer' || sa.Pendingprocessing__c == 'Technical Personnel' || sa.Pendingprocessing__c == 'Technical Parts') {
                            technical++;
                        }
                        // 설치
                        if(sa.Pendingprocessing__c == 'Installation') {
                            installation++;
                        }
                        // 결과미입력
                        if(sa.Pendingprocessing__c == 'Result Not entered') {
                            notInputResult++;
                        }
                        // 기타
                        if(sa.Pendingprocessing__c == 'ETC') {
                            etc++;
                        }
                    }
                }
                // 출동건수 - 직영무상 Count
                if((wo.ServiceTerritory.classify__c == '지사' || wo.ServiceTerritory.classify__c == 'POST') && wo.OrderType__c == '202') {
                    directFree++;
                }
                // 출동건수 - 직영유상 Count
                if((wo.ServiceTerritory.classify__c == '지사' || wo.ServiceTerritory.classify__c == 'POST') && wo.OrderType__c == '201') {
                    salesSupport++;
                }
                // 출동건수 - 업체무상 Count
                if(wo.ServiceTerritory.classify__c == 'W/C' && wo.OrderType__c == '202') {
                    wcFree++;
                }
                // 출동건수 - 업체유상 Count
                if(wo.ServiceTerritory.classify__c == 'W/C' && wo.OrderType__c == '201') {
                    wcIsPay++;
                }
            }
            System.debug('orderCount'+orderCount);
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context){
        System.debug('배치 실행 완료');
        System.debug('orderCount'+orderCount);
        WeeklyServiceSolvingHistory__c insertWeeklyList = new WeeklyServiceSolvingHistory__c();
        insertWeeklyList.ManageDate__c         = System.today().addDays(-1);
        insertWeeklyList.Weekly__c             = weekly;
        insertWeeklyList.Reception__c          = orderCount;
        insertWeeklyList.RepairCompleted__c	   = repairCompleted;
        insertWeeklyList.DispatchSuspense__c   = dispatchSuspense;
        insertWeeklyList.DoNotDispatch__c	   = notDispatch;
        insertWeeklyList.SuspenseTotal__c	   = dispatchSuspense + notDispatch;
        insertWeeklyList.Parts__c              = parts;
        insertWeeklyList.Technology__c	       = technical;
        insertWeeklyList.Account__c	           = account;
        insertWeeklyList.Installation__c	   = installation;
        insertWeeklyList.NumberPerson__c	   = personal;
        insertWeeklyList.Closing__c	           = closing;
        insertWeeklyList.NotResultInput__c	   = notInputResult;
        insertWeeklyList.ETC__c	               = etc;
        insertWeeklyList.DirectFree__c         = directFree;
        insertWeeklyList.SalesSupport__c	   = salesSupport;
        insertWeeklyList.BranchTotal__c	       = directFree + salesSupport;
        insertWeeklyList.WCFree__c             = wcFree;
        insertWeeklyList.WCisPaying__c	       = wcIsPay;
        insertWeeklyList.WCTotal__c  	       = wcFree + wcIsPay;
        System.debug('insertWeeklyList'+insertWeeklyList);

        insert insertWeeklyList;
    }

    public void execute(SchedulableContext sc) {
        DN_WeeklyServiceSolvingStateBatch batch = new DN_WeeklyServiceSolvingStateBatch();
        Database.executeBatch(batch, 200);        
    }
}