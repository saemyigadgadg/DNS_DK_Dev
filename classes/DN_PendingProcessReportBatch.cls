/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2025-04-03
 * @last modified by  : suheon.ha@sobetec.com
**/
public with sharing class DN_PendingProcessReportBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable { 
    // 연도-월별 카운트를 저장할 Map
    private Map<String, Map<String, Integer>> monthMap = new Map<String, Map<String, Integer>>();

    public DN_PendingProcessReportBatch() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, ParentRecordId, Status, Pendingprocessing__c, LastModifiedDate, CreatedDate 
            FROM ServiceAppointment 
            WHERE Pendingprocessing__c != null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        for (ServiceAppointment sa : scope) {
            if (sa.Pendingprocessing__c == null || sa.LastModifiedDate == null) {
                continue;
            }

            // 날짜 조건 계산
            Boolean isLessThan7Days = sa.LastModifiedDate >= System.now().addDays(-6);
            Boolean is7DaysorMore = sa.LastModifiedDate < System.now().addDays(-6);
            Boolean is15DaysorMore = sa.LastModifiedDate < System.now().addDays(-14);
            Boolean is30DaysorMore = sa.LastModifiedDate < System.now().addDays(-29);

            String yearMonth = sa.CreatedDate.format('yyyy-MM');
            String category = picklistValue(sa.Pendingprocessing__c);

            if (category == null) continue;

            // 날짜Map 초기화
            if (!monthMap.containsKey(yearMonth)) {
                monthMap.put(yearMonth, new Map<String, Integer>());
            }
            Map<String, Integer> saCount = monthMap.get(yearMonth);

            // category 초기화
            if (!saCount.containsKey(category + 'LessThan7Days')) {
                saCount.put(category + 'LessThan7Days', 0);
                saCount.put(category + '7DaysorMore', 0);
                saCount.put(category + '15DaysorMore', 0);
                saCount.put(category + '30DaysorMore', 0);
                saCount.put(category + 'Total', 0);
            }

            if (!saCount.containsKey('ALLLessThan7Days')) {
                saCount.put('ALLLessThan7Days', 0);
                saCount.put('ALL7DaysorMore', 0);
                saCount.put('ALL15DaysorMore', 0);
                saCount.put('ALL30DaysorMore', 0);
            }

            // 날짜 및 Picklist 값에 따른 카운트 증가
            if (isLessThan7Days) {
                saCount.put(category + 'LessThan7Days', saCount.get(category + 'LessThan7Days') + 1);
                saCount.put('ALLLessThan7Days', saCount.get('ALLLessThan7Days') + 1);
            } else if (is7DaysorMore) {
                saCount.put(category + '7DaysorMore', saCount.get(category + '7DaysorMore') + 1);
                saCount.put('ALL7DaysorMore', saCount.get('ALL7DaysorMore') + 1);
            } else if (is15DaysorMore) {
                saCount.put(category + '15DaysorMore', saCount.get(category + '15DaysorMore') + 1);
                saCount.put('ALL15DaysorMore', saCount.get('ALL15DaysorMore') + 1);
            } else if (is30DaysorMore) {
                saCount.put(category + '30DaysorMore', saCount.get(category + '30DaysorMore') + 1);
                saCount.put('ALL30DaysorMore', saCount.get('ALL30DaysorMore') + 1);
            }
            saCount.put(category + 'Total', saCount.get(category + 'Total') + 1);
        }
    }

    public void finish(Database.BatchableContext bc) {
        List<PendingprocessingReport__c> reportList = new List<PendingprocessingReport__c>();
        Set<String> yearMonths = new Set<String>(monthMap.keySet());
        
        // Division__c(날짜)으로 판단
        List<PendingprocessingReport__c> existingReports = [
            SELECT Id, Name, Division__c FROM PendingprocessingReport__c WHERE Division__c IN :yearMonths
        ];
    
        if (!existingReports.isEmpty()) {
            delete existingReports;
        }
    
        for (String yearMonth : monthMap.keySet()) {
            Map<String, Integer> saCount = monthMap.get(yearMonth);
    
            Integer allLessThan7Days = saCount.get('ALLLessThan7Days') != null ? saCount.get('ALLLessThan7Days') : 0;
            Integer all7DaysorMore = saCount.get('ALL7DaysorMore') != null ? saCount.get('ALL7DaysorMore') : 0;
            Integer all15DaysorMore = saCount.get('ALL15DaysorMore') != null ? saCount.get('ALL15DaysorMore') : 0;
            Integer all30DaysorMore = saCount.get('ALL30DaysorMore') != null ? saCount.get('ALL30DaysorMore') : 0;
            Integer allTotal = allLessThan7Days + all7DaysorMore + all15DaysorMore + all30DaysorMore;
    
            PendingprocessingReport__c report = new PendingprocessingReport__c();
            report.Name = yearMonth; // Division__c 값
            report.Division__c = yearMonth;
    
            // Parts 합계 계산
            report.PartsTotal__c = (
                (saCount.get('PartsLessThan7Days') != null ? saCount.get('PartsLessThan7Days') : 0) +
                (saCount.get('Parts7DaysorMore') != null ? saCount.get('Parts7DaysorMore') : 0) +
                (saCount.get('Parts15DaysorMore') != null ? saCount.get('Parts15DaysorMore') : 0) +
                (saCount.get('Parts30DaysorMore') != null ? saCount.get('Parts30DaysorMore') : 0)
            );
    
            // calculateTotal 합계 계산
            report.ClosingTotal__c = calculateTotal(saCount, 'Closing');
            report.CustomerTotal__c = calculateTotal(saCount, 'Customer');
            report.PersonTotal__c = calculateTotal(saCount, 'Person');
            report.InstallationTotal__c = calculateTotal(saCount, 'Installation');
            report.TechnicalTotal__c = calculateTotal(saCount, 'Technical');
            report.ETCTotal__c = calculateTotal(saCount, 'ETC');
    
            report.ALLLessThan7Days__c = allLessThan7Days;
            report.ALL7DaysorMore__c = all7DaysorMore;
            report.ALL15DaysorMore__c = all15DaysorMore;
            report.ALL30DaysorMore__c = all30DaysorMore;
            report.ALLTotal__c = allTotal;
    
            reportList.add(report);
        }
    
        if (!reportList.isEmpty()) {
            insert reportList;
        }
    }
    

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 200);
    }

    // Picklist 값에 맞는 카테고리 반환
    private String picklistValue(String processingType) {
        if (processingType == 'Parts') {
            return 'Parts';
        } else if (processingType == 'Closing') {
            return 'Closing';
        } else if (processingType == 'Customer') {
            return 'Customer';
        } else if (processingType == 'Person') {
            return 'Person';
        } else if (processingType == 'ETC') {
            return 'ETC';
        } else if (processingType == 'Installation') {
            return 'Installation';
        } else if (processingType.startsWith('Technical')) {
            return 'Technical';
        }
        return null;
    }

    // 합계 계산 함수
    private Integer calculateTotal(Map<String, Integer> saCount, String category) {
        return (
            (saCount.get(category + 'LessThan7Days') != null ? saCount.get(category + 'LessThan7Days') : 0) +
            (saCount.get(category + '7DaysorMore') != null ? saCount.get(category + '7DaysorMore') : 0) +
            (saCount.get(category + '15DaysorMore') != null ? saCount.get(category + '15DaysorMore') : 0) +
            (saCount.get(category + '30DaysorMore') != null ? saCount.get(category + '30DaysorMore') : 0)
        );
    }

    public static void dummy() {
        Integer i = 0;
        i++;
    }
}