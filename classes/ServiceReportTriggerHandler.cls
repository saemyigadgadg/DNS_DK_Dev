/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class ServiceReportTriggerHandler extends TriggerHandler {

    public override void onBeforeInsert(List<sObject> news) {
        System.debug('ServiceReportTriggerHandler_onBeforeInsert');
        String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
        Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');

        List<ServiceReport> reportList = (List<ServiceReport>) news;
        Set<Id> parentIds = new Set<Id>();
        
        for (ServiceReport report : reportList) {
            System.debug('ParentId : ' + report.ParentId);
            if (report.ParentId != null) {
                System.debug('ParentId : ' + report.ParentId);
                parentIds.add(report.ParentId);
            }
        }

        Map<Id, ServiceReport> srMap = new Map<Id, ServiceReport>([
            SELECT Id, ParentId 
            FROM ServiceReport 
            WHERE ParentId IN :parentIds
        ]);
        System.debug('srMap:::' + srMap);

        Map<Id, ServiceAppointment> appointmentsMap = new Map<Id, ServiceAppointment>([
            SELECT Id, ParentRecordId, WorkerType__c FROM ServiceAppointment WHERE Id IN :parentIds
        ]);
        
        Set<Id> woId = new Set<Id>();
        for (ServiceAppointment appointment : appointmentsMap.values()) {
            if (appointment.ParentRecordId != null) {
                woId.add(appointment.ParentRecordId);
            }
        }
        System.debug('woId : '+ woId );
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([
            SELECT Id, PMActivityType__c FROM WorkOrder WHERE Id IN :woId
        ]);
        System.debug('woMap : '+ woMap );

        for (ServiceReport report : reportList) {
            if (report.ParentId != null && appointmentsMap.containsKey(report.ParentId)) {
            // if (report.ParentId != null && appointmentsMap.containsKey(report.ParentId)) {
                ServiceAppointment appointment = appointmentsMap.get(report.ParentId);

                // ServiceAppointment WorkerType__c 조건 확인
                System.debug('Service Resource (Main):::');
                if (isDNSA) {
                    System.debug('isDNSA True1');
                    // report.ServiceReportNumber.addError('DNSA Cannot Generate Service Report.');
                    
                } else {
                    // 이상태가 맞는지 확인
                    if (srMap.size()>0) {
                        System.debug('이미 ServiceReport가 존재');
                        report.ServiceReportNumber.addError('이미 해당 ServiceAppointment에 관련된 ServiceReport가 존재합니다.');
                    } 
                    if (appointment.WorkerType__c != 'Service Resource (Main)') {
                        System.debug('Service Resource 22(Main):::');
                        report.ServiceReportNumber.addError('Worker Type이 "Service Resource (Main)"이 아니므로 Service Report를 생성할 수 없습니다.');
                        // report.addError('Worker Type이 "Service Resource (Main)"이 아니므로 Service Report를 생성할 수 없습니다.');
                    }
                }
    
                // WorkOrder PMActivityType__c 조건 확인
                System.debug('PMActivityType__c:::');
                if (isDNSA) {
                    System.debug('isDNSA True2');
                } else if (appointment.ParentRecordId != null) {
                    System.debug('PMActivityType__c:::22');
                    WorkOrder wo = woMap.get(appointment.ParentRecordId);
                    if (wo.PMActivityType__c != 'CS02') {
                        System.debug('PMActivityType__c:::33');
                        report.ServiceReportNumber.addError('CS02 유형의 Order Type만 서비스 보고서를 생성할 수 있습니다.');
                    }
                }
            }
        }
    }
    

    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
        System.debug('ServiceReportTriggerHandler_onAfterInsert');
        String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
        Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
        List<ServiceReport> reportList = (List<ServiceReport>) news;
        Set<Id> contentDocIDs = new Set<Id>();
        
        // ServiceReport에서 ParentId찾기
        Set<Id> parentIds = new Set<Id>();
        for (ServiceReport report : reportList) {
            if (report.ParentId != null) {
                parentIds.add(report.ParentId);
            }

            
        }
        
        //250211 ServiceReport__c 자동 생성 & Auto Number mapping by Hayeong Min 
        // List<ServiceReport> objList = [SELECT Id, ServiceReportNumber, ParentId FROM ServiceReport WHERE ParentId IN : parentIds AND Parent.Type = 'ServiceAppointment'];
        // Map<ID, ServiceReport> reportMap = new Map<Id, ServiceReport>();
        // if(objList.size()>0){
        //     for(ServiceReport sr : objList){
        //         reportMap.put(sr.ParentId, sr);
        //     }
        //     Id dnsaRecTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ServiceAppointment_DNSA' LIMIT 1].Id;
        //     List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment WHERE ID IN :reportMap.keySet() AND RecordTypeId = :dnsaRecTypeId];
        //     List<ServiceReport__c> srList = new List<ServiceReport__c>();
        //     if(saList.size()>0){
        //         for(ServiceAppointment sa : saList){
        //             ServiceReport__c sr = new ServiceReport__c();
        //             sr.ServiceReportNo__c = reportMap.get(sa.Id).ServiceReportNumber;
        //             sr.ServiceAppointment__c = sa.Id;
        //             srList.add(sr);
        //         }
        //         if(srList.size()>0){
        //             insert srList;
        //             // if (!Test.isRunningTest()) {
        //             // }
        //         }
        //     }
        // }        



        // 찾은 ParentId로 ServiceReport쿼리
        Map<Id, ServiceAppointment> appointmentsMap = new Map<Id, ServiceAppointment>([
            SELECT Id, ParentRecordId, WorkCompletionTime__c, ServiceResource__c FROM ServiceAppointment WHERE Id IN :parentIds
        ]);
        System.debug('appointmentsMap::: ' + appointmentsMap);
        
        // Work Order ID 목록 수집
        Set<Id> workOrderIds = new Set<Id>();
        for (ServiceReport report : reportList) {
            if (report.ParentId != null && appointmentsMap.containsKey(report.ParentId)) {
                ServiceAppointment appointment = appointmentsMap.get(report.ParentId);
                
                if (appointment != null && appointment.ParentRecordId != null) {
                    workOrderIds.add(appointment.ParentRecordId);
                }
            }
        }
    
        // Work Order ID 목록으로 ContentDocumentLink 쿼리
        Map<Id, List<ContentDocumentLink>> workOrderFileLinksMap = new Map<Id, List<ContentDocumentLink>>();
        if (!workOrderIds.isEmpty()) {
            List<ContentDocumentLink> existingFileLinks = [
                SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :workOrderIds
            ];
        
            // 쿼리된 파일 링크를 맵으로 정리
            for (ContentDocumentLink link : existingFileLinks) {
                if (!workOrderFileLinksMap.containsKey(link.LinkedEntityId)) {
                    workOrderFileLinksMap.put(link.LinkedEntityId, new List<ContentDocumentLink>());
                }
                workOrderFileLinksMap.get(link.LinkedEntityId).add(link);
                contentDocIDs.add(link.ContentDocumentId);
            }
        }

        // WorkOrder 매핑 (ServiceAppointment → WorkOrder)
        Map<Id, Id> appointmentToWorkOrderMap = new Map<Id, Id>();
        for (ServiceAppointment appointment : appointmentsMap.values()) {
            if (appointment.ParentRecordId != null) {
                appointmentToWorkOrderMap.put(appointment.Id, appointment.ParentRecordId);
            }
        }

        // Worker__c 별 가장 최신 ServiceReport 찾기
        Map<Id, ServiceReport> latestReportPerWorker = new Map<Id, ServiceReport>();
        for (ServiceReport report : reportList) {
            if (report.ParentId != null && appointmentsMap.containsKey(report.ParentId)) {
                Id workerId = appointmentsMap.get(report.ParentId).ServiceResource__c;
                if (workerId != null) {
                    if (!latestReportPerWorker.containsKey(workerId) || 
                        report.CreatedDate > latestReportPerWorker.get(workerId).CreatedDate) {
                        latestReportPerWorker.put(workerId, report);
                    }
                }
            }
        }
        
        for (ServiceReport report : reportList) { 
            if (report.ParentId != null && appointmentsMap.containsKey(report.ParentId)) {
                ServiceAppointment appointment = appointmentsMap.get(report.ParentId);
                
                if (appointment != null && appointment.ParentRecordId != null) {
                    if (isDNSA) {
                        System.debug('isDNSA fterInsert');

                        Set<Id> processedWorkOrders = new Set<Id>();
                        for (Id workerId : latestReportPerWorker.keySet()) {
                            ServiceReport latestReport = latestReportPerWorker.get(workerId);
                            Id appointmentId = latestReport.ParentId;
                            
                            if (appointmentToWorkOrderMap.containsKey(appointmentId)) {
                                Id workOrderId = appointmentToWorkOrderMap.get(appointmentId);
                
                                // 동일 WorkOrder에 중복 저장 방지
                                if (!processedWorkOrders.contains(workOrderId)) {
                                    handleServiceReport(appointment.ParentRecordId, report, workOrderFileLinksMap);
                                    processedWorkOrders.add(workOrderId);
                                }
                            }
                        }
                    } else {
                        // WorkOrder에 파일 링크 및 ServiceReport 클론 생성
                        handleServiceReport(appointment.ParentRecordId, report, workOrderFileLinksMap);
                    }

                    System.debug('WorkCompletionTime__c::: ' + appointment);
                }
            }
        }
        System.debug('Appointments to update::: ' + appointmentsMap.values());
        // 추가된 ContentDistribution 생성 로직
        if (!contentDocIDs.isEmpty()) {
            createDistribution(contentDocIDs);
        }
        update appointmentsMap.values();
        System.debug('update appointmentsMap.values:::'+appointmentsMap.values());

    }

    // public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
    //     ///250211 ServiceReport 삭제 시 연결된 ServiceReport__c 자동 삭제 by Hayeong Min 
    //     List<ServiceReport> objList = (List<ServiceReport>) dels;
    //     Set<String> srNumber = new Set<String>();
    //     for(ServiceReport obj : objList){
    //         srNumber.add(obj.ServiceReportNumber);
    //     }

    //     List<ServiceReport__c> srList = [SELECT ID FROM ServiceReport__c WHERE ServiceReportNo__c IN : srNumber];
    //     if(srList.size()>0){delete srList;}
    // }
    
    // ServiceReport 생성 및 파일 링크 처리 메서드
    private void handleServiceReport(Id workOrderId, ServiceReport originalReport, Map<Id, List<ContentDocumentLink>> workOrderFileLinksMap) {
        String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
        Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
        if (isDNSA) {
            System.debug('dnsaServiceReport');
        
            // 기존 WorkOrder에 링크된 파일 삭제
            List<ContentDocumentLink> existingLinks = [
                SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :workOrderId
            ];
            // 삭제 권한이 없어서 잠깐 주석
            // if (!existingLinks.isEmpty()) {
            //     delete existingLinks;
            // }
    
            // 요원별 최신 ServiceReport 유지 로직 추가
            // updateOrdertReport(workOrderId, originalReport);
            ServiceReportTriggerHandler.cloneReport(workOrderId, originalReport.Id);
        } else {
            
            // 기존 WorkOrder에 링크된 파일 삭제
            if (workOrderFileLinksMap.containsKey(workOrderId)) {
                delete workOrderFileLinksMap.get(workOrderId);
            }
            ServiceReportTriggerHandler.cloneReport(workOrderId, originalReport.Id);
        }
    }

    // WorkOrder에 ServiceReport 클론 생성 메서드
    private static void cloneReport(Id workOrderId, Id originalReportId) {
        String salesOrg = [SELECT Id, SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
        Id currentUserId = UserInfo.getUserId();
        Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
        System.debug('cloneReport');
        if (isDNSA) {
            System.debug('isDNSA cloneReport');
            // dnsa일 때 if를 사용해서 기존 리포트를 생성자로 판단해서 있으면 삭제하고 인서트 없으면 인서트
            // if (originalReportId == null) {

            // } else {
            //     List<ServiceReport> existingReportLinks = [SELECT ParentId FROM ServiceReport WHERE ParentId = :workOrderId AND CreatedById =: currentUserId];
            //     delete existingReportLinks;
            // }
            
            ServiceReport sr = [
                SELECT Id, IsDeleted, ServiceReportNumber, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                SystemModstamp, ParentId, ContentVersionDocumentId, DocumentName, DocumentContentType,  
                DocumentBody, Template, ServiceReportLanguage, IsSigned 
                FROM ServiceReport
                WHERE Id = :originalReportId
                LIMIT 1
                ];
                
                ServiceReport clonedReport = sr.clone(false, false, false, false);
                clonedReport.ParentId = workOrderId;
                // clonedReport.DocumentName = 'TESTHASU';
                insert clonedReport;
                // if (!Test.isRunningTest()) {
                // }
        } else {
            System.debug('No isDNSA cloneReport');

            // 기존 코드
            // 기존 보고사 삭제
            List<ServiceReport> existingReportLinks = [SELECT ParentId FROM ServiceReport WHERE ParentId = :workOrderId];
            delete existingReportLinks;
        
            ServiceReport sr = [
                SELECT Id, IsDeleted, ServiceReportNumber, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                    SystemModstamp, ParentId, ContentVersionDocumentId, DocumentName, DocumentContentType,  
                    DocumentBody, Template, ServiceReportLanguage, IsSigned 
                FROM ServiceReport
                WHERE Id = :originalReportId
                LIMIT 1
            ];
        
            ServiceReport clonedReport = sr.clone(false, false, false, false);
            clonedReport.ParentId = workOrderId;
            // clonedReport.DocumentName = 'TESTHASU';
            insert clonedReport;
            // if (!Test.isRunningTest()) {
            // }
        }
    
    }

    // WorkOrder에 ServiceReport 클론 생성 메서드
    @testVisible private static void updateOrdertReport(Id workOrderId, ServiceReport newReport) {
        System.debug('updateOrdertReport');
    
        // 기존 WorkOrder에 속한 ServiceReport 조회 요원별 최신 리포트 유지
        List<ServiceReport> existingReports = [
            SELECT Id, CreatedById, CreatedDate, ParentId 
            FROM ServiceReport 
            WHERE ParentId = :workOrderId 
            ORDER BY CreatedDate DESC
        ];
        
        Map<Id, ServiceReport> latestReportPerWorker = new Map<Id, ServiceReport>();
    
        for (ServiceReport report : existingReports) {
            if (!latestReportPerWorker.containsKey(report.CreatedById)) {
                latestReportPerWorker.put(report.CreatedById, report);
            }
        }
    
        if (!latestReportPerWorker.containsKey(newReport.CreatedById) || 
            newReport.CreatedDate > latestReportPerWorker.get(newReport.CreatedById).CreatedDate) {
            
            // 기존 요원의 ServiceReport 삭제
            if (latestReportPerWorker.containsKey(newReport.CreatedById)) {
                delete latestReportPerWorker.get(newReport.CreatedById);
            }
    
            // 새 리포트 복제 후 삽입
            ServiceReportTriggerHandler.cloneReport(workOrderId, newReport.Id);
        }
    }

    // ContentDistribution 생성 메서드 추가
    private static void createDistribution(Set<Id> contentDocIDs) {
        if (contentDocIDs.isEmpty()) {
            return;
        }
    
        // ContentVersion 조회
        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId, PathOnClient 
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN :contentDocIDs
                                        ORDER BY CreatedDate DESC];
    
        List<ContentDistribution> insertCDBList = new List<ContentDistribution>();
        for (ContentVersion cv : cvList) {
            ContentDistribution cdb = new ContentDistribution();
            cdb.Name = cv.PathOnClient;
            cdb.ContentVersionId = cv.Id;
            cdb.PreferencesNotifyOnVisit = false;
            insertCDBList.add(cdb);
        }
    
        if (!insertCDBList.isEmpty()) {
            insert insertCDBList;
        }        
    
        System.debug('ContentDistribution records created: ' + insertCDBList.size());
    }
}