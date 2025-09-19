/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 06-10-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class DN_PendingDefectReportBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    public Map<String, PendingprocessingReport__c> reportMap = new Map<String, PendingprocessingReport__c>();

    public List<SObject> start(Database.BatchableContext bc) {
        System.debug('Batch start');

        List<Case> caseList = [
            SELECT Id
            FROM Case
            WHERE ApplicationDateTime__c != NULL 
            AND ApplicationDateTime__c >= LAST_N_YEARS:1
        ];
        // List<Case> caseList = [SELECT Id, 
        //                                (SELECT Id, 
        //                                        (SELECT Id, CreatedDate, ServiceTerritoryId, ServiceTerritory.Name, Pendingprocessing__c
        //                                         FROM ServiceAppointments WHERE Pendingprocessing__c != null) 
        //                                 FROM WorkOrders ORDER BY CreatedDate LIMIT 1)
        //                         FROM Case WHERE ApplicationDateTime__c != NULL AND ApplicationDateTime__c >= LAST_N_YEARS:1];
        // System.debug('caseList:::' + caseList);
        return caseList;
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Case> caseList = (List<Case>) scope;
        System.debug('Cases:::' + caseList);
        Set<Id> caseIds = new Set<Id>();
        for (Case c : caseList) {
            caseIds.add(c.Id);
        }
        // Start Case로 WorkOrder 조회
        Map<Id, List<WorkOrder>> woMap = new Map<Id, List<WorkOrder>>();
        List<WorkOrder> woList = [
            SELECT Id, CaseId
            FROM WorkOrder
            WHERE caseId IN :caseIds
        ];
        for (WorkOrder wo : woList) {
            if (!woMap.containsKey(wo.CaseId)) {
                woMap.put(wo.CaseId, new List<WorkOrder>());
            }
            woMap.get(wo.CaseId).add(wo);
        }
        // WorkOrder Id
        Set<Id> woIds = new Set<Id>();
        for (WorkOrder wo : woList) {
            woIds.add(wo.Id);
        }

        // WorkOrder로 SA 조회
        Map<Id, List<ServiceAppointment>> saMap = new Map<Id, List<ServiceAppointment>>();
        List<ServiceAppointment> saList = [
            SELECT Id, CreatedDate, Pendingprocessing__c, ServiceTerritory.Name, WorkOrder__c
            FROM ServiceAppointment
            WHERE WorkOrder__c IN :woIds
            AND Pendingprocessing__c != null
        ];
        for (ServiceAppointment sa : saList) {
            if (!saMap.containsKey(sa.WorkOrder__c)) {
                saMap.put(sa.WorkOrder__c, new List<ServiceAppointment>());
            }
            saMap.get(sa.WorkOrder__c).add(sa);
        }
    
        for (Case caseRecord : caseList) {
            if (!woMap.containsKey(caseRecord.Id)) continue;
        
            for (WorkOrder woRecord : woMap.get(caseRecord.Id)) {
                if (!saMap.containsKey(woRecord.Id)) continue;
        
                Decimal weeklyCount = 0, totalServiceAppointments = 0;
                Decimal partsTotal = 0, closingTotal = 0, customerTotal = 0, personTotal = 0, installationTotal = 0, technicalTotal = 0, etcTotal = 0;
                String DateReceived = null;
                Date DateReceive = null;
                String workCenter = null;
        
                for (ServiceAppointment sa : saMap.get(woRecord.Id)) {
                    totalServiceAppointments++;
        
                    // 특정 시간대(08:00~17:00) 집계
                    DateTime saDateTime = sa.CreatedDate;
                    Decimal hour = Integer.valueOf(saDateTime.format('HH', 'GMT+9'));
                    if (hour >= 8 && hour <= 17) {
                        weeklyCount++;
                    }
        
                    // 카테고리별 집계
                    String category = picklistValue(sa.Pendingprocessing__c);
                    if (category != null) {
                        if (category == 'Parts') partsTotal++;
                        else if (category == 'Closing') closingTotal++;
                        else if (category == 'Customer') customerTotal++;
                        else if (category == 'Person') personTotal++;
                        else if (category == 'Installation') installationTotal++;
                        else if (category == 'Technical') technicalTotal++;
                        else if (category == 'ETC') etcTotal++;
                    }
        
                    if (DateReceived == null) { 
                        DateReceived = sa.CreatedDate.format('yyyy-MM-dd');
                        DateReceive = sa.CreatedDate.Date();
                    }
                    if (workCenter == null && sa.ServiceTerritory != null) {
                        workCenter = sa.ServiceTerritory.Name;
                    }
                }
        
                String key = DateReceived + '|' + workCenter;
        
                if (reportMap.containsKey(key)) {
                    PendingprocessingReport__c existingReport = reportMap.get(key);
                    existingReport.Parts__c += partsTotal;
                    existingReport.Closing__c += closingTotal;
                    existingReport.Customer__c += customerTotal;
                    existingReport.Person__c += personTotal;
                    existingReport.Installation__c += installationTotal;
                    existingReport.Technical__c += technicalTotal;
                    existingReport.ETC__c += etcTotal;
                    existingReport.Total__c += totalServiceAppointments;
                    existingReport.WeeklyNumberReceived__c += weeklyCount;
                } else {
                    PendingprocessingReport__c report = new PendingprocessingReport__c();
                    report.DateReceived__c = DateReceived;
                    report.DateReceive__c = DateReceive;
                    report.WorkCenter__c = workCenter;
                    report.ServiceWC__c = workCenter;
                    report.Parts__c = partsTotal;
                    report.Closing__c = closingTotal;
                    report.Customer__c = customerTotal;
                    report.Person__c = personTotal;
                    report.Installation__c = installationTotal;
                    report.Technical__c = technicalTotal;
                    report.ETC__c = etcTotal;
                    report.Total__c = totalServiceAppointments;
                    report.WeeklyNumberReceived__c = weeklyCount;
                    reportMap.put(key, report);
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('PendingProcessReportBatch finish!');
        // 기존 레포트 삭제 및 새 레포트 삽입
        if (!reportMap.isEmpty()) {
            System.debug('Deleting PendingprocessingReport');
            List<PendingprocessingReport__c> existingReports = [
                SELECT Id, DateReceived__c FROM PendingprocessingReport__c WHERE DateReceived__c != null
            ];
            System.debug('existingReportsdelete:::' + existingReports);
            if (!existingReports.isEmpty()) {
                delete existingReports;
            }

            System.debug('reportList:::' + reportMap.values());
            insert reportMap.values();
        }
    }

    public void execute(SchedulableContext sc) {
        System.debug('Scheduled execution started');
        Database.executeBatch(this, 200);
    }
    
    // Picklist 값에 맞는 카테고리 반환
    private String picklistValue(String pendingProcessingValue) {
        if (pendingProcessingValue == 'Parts') {
            return 'Parts';
        } else if (pendingProcessingValue == 'Closing') {
            return 'Closing';
        } else if (pendingProcessingValue == 'Customer') {
            return 'Customer';
        } else if (pendingProcessingValue == 'Person') {
            return 'Person';
        } else if (pendingProcessingValue == 'Installation') {
            return 'Installation';
        } else if (pendingProcessingValue == 'ETC') {
            return 'ETC';
        } else if (pendingProcessingValue.startsWith('Technical')) {
            return 'Technical';
        }
        return null;
    }
}