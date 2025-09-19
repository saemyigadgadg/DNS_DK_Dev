/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class DN_MonthlyDispatchStatusReportBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    public Map<String, PendingprocessingReport__c> reportMap = new Map<String, PendingprocessingReport__c>();
    public Map<String, Integer> monthlyTotalCountsMap = new Map<String, Integer>();

    public List<SObject> start(Database.BatchableContext bc) {
        List<WorkOrder> woList = [
            SELECT Id, ServiceTerritory.Name, FM_RepairRequestDateTime__c 
            FROM WorkOrder 
            WHERE FM_RepairRequestDateTime__c != NULL AND FM_RepairRequestDateTime__c >= LAST_N_YEARS:1
        ];
        System.debug('Start woList:::' + woList);
        return woList;
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<WorkOrder> woList = (List<WorkOrder>) scope;
        System.debug('Execute woList:::' + woList);

        // 각 연도별 월별 전체 출동 건수 초기화
        for (Integer year = Date.today().year() - 1; year <= Date.today().year(); year++) {
            for (Integer month = 1; month <= 12; month++) {
                monthlyTotalCountsMap.put(year + '-' + month, 0);
            }
        }

        // 연도별 월별 전체 출동 건수 계산
        for (WorkOrder wo : woList) {
            DateTime fmRequestDateTime = wo.FM_RepairRequestDateTime__c;
            Integer month = fmRequestDateTime.month();
            Integer year = fmRequestDateTime.year();

            String totalCountKey = year + '-' + month;
            if (monthlyTotalCountsMap.containsKey(totalCountKey)) {
                monthlyTotalCountsMap.put(totalCountKey, monthlyTotalCountsMap.get(totalCountKey) + 1);
            }
        }
        System.debug('monthlyTotalCountsMap:::' + monthlyTotalCountsMap);

        for (WorkOrder wo : woList) {
            DateTime fmRequestDateTime = wo.FM_RepairRequestDateTime__c;
            Integer month = fmRequestDateTime.month();
            Integer year = fmRequestDateTime.year();
            String dayOfWeek = fmRequestDateTime.format('E');
            String serviceCenter = wo.ServiceTerritory.Name;
            String dispatchType = determineDispatchType(fmRequestDateTime); 
            String dispatchYear = String.valueOf(year);

            if (String.isEmpty(serviceCenter)) {
                continue;
            }

            // 연도별로 데이터가 나뉘도록 Key값 변경
            // String reportKey = serviceCenter + '-' + dispatchType + '-' + dispatchYear + '-' + month;
            // String reportKey = serviceCenter + '-' + dispatchYear + '-' + month;
            String reportKey = serviceCenter + '-' + dispatchYear;
            if (!reportMap.containsKey(reportKey)) {
                PendingprocessingReport__c newReport = new PendingprocessingReport__c();
                newReport.ServiceCenter__c = serviceCenter;
                newReport.DispatchType__c = dispatchType;
                newReport.DispatchYear__c = dispatchYear;
                reportMap.put(reportKey, newReport);
            }
            PendingprocessingReport__c report = reportMap.get(reportKey);

            // 월별 필드 계산
            String countField = new String[] {
                'JanCount__c', 'FebCount__c', 'MarCount__c', 'AprCount__c',
                'MayCount__c', 'JunCount__c', 'JulCount__c', 'AugCount__c',
                'SepCount__c', 'OctCount__c', 'NovCount__c', 'DecCount__c'
            }[month - 1];

            if (dayOfWeek == 'Sat' || dayOfWeek == 'Sun' || (fmRequestDateTime.hour() >= 17 && fmRequestDateTime.hour() < 24)) {
                report.put(countField, (report.get(countField) == null ? 0 : (Decimal) report.get(countField)) + 1);
            }

            // 월의 출동률 계산
            String totalCountKey = year + '-' + month;
            if (monthlyTotalCountsMap.containsKey(totalCountKey) && monthlyTotalCountsMap.get(totalCountKey) > 0) {
                Decimal nightCount = report.get(countField) == null ? 0 : (Decimal) report.get(countField);
                Decimal dispatchRate = nightCount / monthlyTotalCountsMap.get(totalCountKey);
                report.put(countField.replace('Count', 'DispatchRate'), dispatchRate);
            }
        }

        // 최종 건수 및 출동률 계산
        for (PendingprocessingReport__c report : reportMap.values()) {
            // 출동 건수 합산
            report.TotalCount__c = (report.JanCount__c == null ? 0 : report.JanCount__c) +
                                    (report.FebCount__c == null ? 0 : report.FebCount__c) +
                                    (report.MarCount__c == null ? 0 : report.MarCount__c) +
                                    (report.AprCount__c == null ? 0 : report.AprCount__c) +
                                    (report.MayCount__c == null ? 0 : report.MayCount__c) +
                                    (report.JunCount__c == null ? 0 : report.JunCount__c) +
                                    (report.JulCount__c == null ? 0 : report.JulCount__c) +
                                    (report.AugCount__c == null ? 0 : report.AugCount__c) +
                                    (report.SepCount__c == null ? 0 : report.SepCount__c) +
                                    (report.OctCount__c == null ? 0 : report.OctCount__c) +
                                    (report.NovCount__c == null ? 0 : report.NovCount__c) +
                                    (report.DecCount__c == null ? 0 : report.DecCount__c);

            // 출동률 평균 계산
            report.TotalDispatchRate__c = ((report.JanDispatchRate__c == null ? 0 : report.JanDispatchRate__c) +
                                            (report.FebDispatchRate__c == null ? 0 : report.FebDispatchRate__c) +
                                            (report.MarDispatchRate__c == null ? 0 : report.MarDispatchRate__c) +
                                            (report.AprDispatchRate__c == null ? 0 : report.AprDispatchRate__c) +
                                            (report.MayDispatchRate__c == null ? 0 : report.MayDispatchRate__c) +
                                            (report.JunDispatchRate__c == null ? 0 : report.JunDispatchRate__c) +
                                            (report.JulDispatchRate__c == null ? 0 : report.JulDispatchRate__c) +
                                            (report.AugDispatchRate__c == null ? 0 : report.AugDispatchRate__c) +
                                            (report.SepDispatchRate__c == null ? 0 : report.SepDispatchRate__c) +
                                            (report.OctDispatchRate__c == null ? 0 : report.OctDispatchRate__c) +
                                            (report.NovDispatchRate__c == null ? 0 : report.NovDispatchRate__c) +
                                            (report.DecDispatchRate__c == null ? 0 : report.DecDispatchRate__c)) / 12;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch Finish Started');
    
        List<PendingprocessingReport__c> existingReports = [
            SELECT Id FROM PendingprocessingReport__c WHERE ServiceCenter__c != NULL
        ];
        if (!existingReports.isEmpty()) {
            delete existingReports;
            System.debug('Deleted Reports:::' + existingReports);
        }
    
        System.debug('reportList:::' + reportMap.values());
    
        // 전체 TotalCount__c 합산
        Decimal totalSum = 0;
        for (PendingprocessingReport__c report : reportMap.values()) {
            if (report.TotalCount__c != null) {
                totalSum += report.TotalCount__c;
            }
        }
    
        // Score__c 계산
        for (PendingprocessingReport__c report : reportMap.values()) {
            if (totalSum > 0 && report.TotalCount__c != null) {
                Decimal percentage = (report.TotalCount__c / totalSum) * 100;
                
                if (percentage <= 20) {
                    report.Score__c = 5;
                } else if (percentage > 20 && percentage <= 50) {
                    report.Score__c = 4;
                } else if (percentage > 50 && percentage <= 80) {
                    report.Score__c = 2;
                } else if (percentage > 80) {
                    report.Score__c = 1;
                } else {
                    report.Score__c = null;
                }
            } else {
                report.Score__c = null;
            }
        }

        // 순위 계산

        // 연도별로 나누기
        Map<String, List<PendingprocessingReport__c>> yearListMap = new Map<String, List<PendingprocessingReport__c>>();
        for (PendingprocessingReport__c report : reportMap.values()) {
            List<PendingprocessingReport__c> yearList = new List<PendingprocessingReport__c>();
            if (report.DispatchType__c != null && report.DispatchType__c != '') {
                if (yearListMap.get(report.DispatchYear__c + '!' + report.DispatchType__c) != null) yearList = yearListMap.get(report.DispatchYear__c + '!' + report.DispatchType__c);
                yearList.add(report);
                yearListMap.put(report.DispatchYear__c + '!' + report.DispatchType__c, yearList);
            }
        }

        List<PendingprocessingReport__c> insertList = new List<PendingprocessingReport__c>();
        for (String key : yearListMap.keySet()) {
            List<PendingprocessingReport__c> yearList = yearListMap.get(key);
            ScoreCompare scoreCompare = new ScoreCompare();
            yearList.sort(ScoreCompare);
    
            Integer rank = 1;
            for (PendingprocessingReport__c report : yearList) {
                report.Ranking__c = rank;
                rank ++;
            }
            insertList.addAll(yearList);
        }
    
        insert insertList;
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 200);
    }

    // 휴일, 야간 출동 유형 결정 메서드
    private String determineDispatchType(DateTime fmRequestDateTime) {
        String dayOfWeek = fmRequestDateTime.format('E');
        if (dayOfWeek == 'Sat' || dayOfWeek == 'Sun') {
            return '휴일';
        } else if (fmRequestDateTime.hour() >= 17 && fmRequestDateTime.hour() < 24) {
            return '야간';
        }
        return null;
    }

    // 점수계산 클래스 정의
    public class ScoreCompare implements Comparator<PendingprocessingReport__c> {
        public Integer compare(PendingprocessingReport__c e1, PendingprocessingReport__c e2) {
            Integer result;
            if(e1?.Score__c == null && e2?.Score__c == null) {
                result = 0;
            } else if(e1?.Score__c == null) { 
                  result = -1; 
            } else if(e2?.Score__c == null) {
                  result = 1;
            } else if (e1.Score__c < e2.Score__c) {
                  result = -1;
            } else if (e1.Score__c > e2.Score__c) {
                  result = 1;
            } else if (e1.Score__c == e2.Score__c) {
                if(e1?.TotalDispatchRate__c == null && e2?.TotalDispatchRate__c == null) {
                    result = 0;
                } else if(e1?.TotalDispatchRate__c == null) { 
                      result = -1; 
                } else if(e2?.TotalDispatchRate__c == null) {
                      result = 1;
                } else if (e1.TotalDispatchRate__c > e2.TotalDispatchRate__c) {
                      result = -1;
                } else if (e1.TotalDispatchRate__c < e2.TotalDispatchRate__c) {
                      result = 1;
                } else if (e1.TotalDispatchRate__c == e2.TotalDispatchRate__c) {
                      result = 0;  
                }
            }
            return result;
        }
    }
}