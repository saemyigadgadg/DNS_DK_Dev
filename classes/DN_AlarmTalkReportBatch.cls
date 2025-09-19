/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-28
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-08   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public class DN_AlarmTalkReportBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable{

    public List<SObject> start(Database.BatchableContext context){
        List<AlarmTalk__c> alarmtalkList = new List<AlarmTalk__c>();
        if (!Test.isRunningTest()) {
            alarmtalkList = [SELECT Id, Ticket__c, Ticket__r.CaseNumber, FM_Account__c, FM_Equipment__c, Equipment__c, Equipment__r.SerialNumber,
                                    Contact__c, Contact__r.Name, ReceiptMethod__c, Phone__c, Model__c, Symptom__c, RequestedTerm__c, RepairRequestDateTime__c,
                                    W_C__c, W_C__r.Name
                            FROM AlarmTalk__c
                            WHERE CreatedDate = YESTERDAY
            ];
        } else {
            alarmtalkList = [SELECT Id, Ticket__c, Ticket__r.CaseNumber, FM_Account__c, FM_Equipment__c, Equipment__c, Equipment__r.SerialNumber,
                                    Contact__c, Contact__r.Name, ReceiptMethod__c, Phone__c, Model__c, Symptom__c, RequestedTerm__c, RepairRequestDateTime__c,
                                    W_C__c, W_C__r.Name
                            FROM AlarmTalk__c
                            LIMIT 100
            ];
        }

        return alarmtalkList;
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {

        List<AlarmTalk__c> alarmtalkList = (List<AlarmTalk__c>)scope;

        Set<String> ticketIds = new Set<String>();

        for (AlarmTalk__c alarmtalk : alarmtalkList) {
            ticketIds.add(alarmtalk.Ticket__c);
        }

        Map<Id, Case> ticketMap = new Map<Id, Case>(
            [   SELECT  Id, CaseNumber, AssetId, Asset.MachineName__c, Asset.SerialNumber, ApplicationDateTime__c, RepairRequestDateTime__c, Status, EndOfReason__c,
                        OwnerId, Owner.Name, InternalTicketType__c, Requester__c, Requester__r.Name,
                        (   SELECT  Id, WorkOrderNumber, Worker__c, Worker__r.Name, TimeAgreedOnSite__c, ServiceTerritoryId, ServiceTerritory.Name, ServiceTerritory.classify__c, ServiceTerritory.ControlWorkcenter__r.Name, InspectionDetails__c, FM_RepairRequestDateTime__c,
                                    (SELECT Id, Department__c, Arrival__c, WorkCompletionTime__c FROM ServiceAppointments WHERE WorkerType__c = 'Service Resource (Main)' ORDER BY CreatedDate DESC)
                            FROM WorkOrders
                            ORDER BY CreatedDate DESC)
                FROM Case
                WHERE Id IN :ticketIds]
        );


        Set<String> userIds = new Set<String>();
        if (ticketMap.values().size() > 0) {
            for (Case ticket : ticketMap.values()) {
                userIds.add(ticket.OwnerId);
            }
        }

        List<User> userList= [SELECT Id, Name, UserCode__c FROM User WHERE Id IN :userIds];
        Map<String, String> userCodeMap = new Map<String, String>();
        for (User user : userList) {
            userCodeMap.put(user.Id, user.UserCode__c);
        }

        Map<String, AlarmTalkReport__c> reportMap = new Map<String, AlarmTalkReport__c>();
        List<AlarmTalkReport__c> alarmtalkReportList = [SELECT Id, AlarmTalkId__c FROM AlarmTalkReport__c];
        for (AlarmTalkReport__c report : alarmtalkReportList) {
            reportMap.put(report.AlarmTalkId__c, report);
        }
        
        List<AlarmTalkReport__c> upsertList = new List<AlarmTalkReport__c>();

        for (AlarmTalk__c alarmtalk : alarmTalkList) {
            if (alarmtalk.Ticket__c == null) continue;

            AlarmTalkReport__c alarmtalkReport = new AlarmTalkReport__c();

            if (reportMap.get(alarmtalk.Id) != null) {
                alarmtalkReport = reportMap.get(alarmtalk.Id);
            }
            
            Case ticket = ticketMap.get(alarmtalk.Ticket__c);
            
            alarmtalkReport.Name = '알림톡 모니터링 리포트';

            alarmtalkReport.AlarmTalkId__c = alarmtalk.Id;

            // 접수번호
            alarmtalkReport.TicketNumber__c = alarmtalk.Ticket__r.CaseNumber;

            // 상태표시
            alarmtalkReport.Status__c = ticket.Status == 'Closed' && ticket.EndOfReason__c == 'Customer Cancellation' ? '고객취소' : '접수';

            // 채널구분
            alarmtalkReport.Channel__c = alarmtalk.ReceiptMethod__c == null ? '' : alarmtalk.ReceiptMethod__c + '접수';

            // 서비스W/C
            alarmtalkReport.Workcenter__c = alarmtalk.W_C__c == null ? '' : alarmtalk.W_C__r.Name;

            // 준수여부
            alarmtalkReport.IsCompliance__c = 'N';

            // 오더번호
            if (ticket.WorkOrders.size() > 0) {
                alarmtalkReport.WorkOrderNumber__c = ticket.WorkOrders[0].WorkOrderNumber;

                // 서비스요원
                alarmtalkReport.ServiceResource__c = ticket.WorkOrders[0].Worker__r.Name;

                // 방문예정
                alarmtalkReport.ScheduledDatetime__c = ticket.WorkOrders[0].TimeAgreedOnSite__c == null ? '' : ticket.WorkOrders[0].TimeAgreedOnSite__c.format('yyyy-MM-dd HH:mm:ss');

                // 출발
                alarmtalkReport.DepartmentDatetime__c = ticket.WorkOrders[0].ServiceAppointments[0].Department__c == null ? '' : ticket.WorkOrders[0].ServiceAppointments[0].Department__c.format('yyyy-MM-dd HH:mm:ss');

                // 도착
                alarmtalkReport.ArrivalDatetime__c = ticket.WorkOrders[0].ServiceAppointments[0].Arrival__c == null ? '' : ticket.WorkOrders[0].ServiceAppointments[0].Arrival__c.format('yyyy-MM-dd HH:mm:ss');

                // 완료
                alarmtalkReport.CompleteDatetime__c = ticket.WorkOrders[0].ServiceAppointments[0].WorkCompletionTime__c == null ? '' : ticket.WorkOrders[0].ServiceAppointments[0].WorkCompletionTime__c.format('yyyy-MM-dd HH:mm:ss');

                // 서비스W/C
                alarmtalkReport.Workcenter__c = ticket.WorkOrders[0].ServiceTerritory.Name;
                if (ticket.WorkOrders[0].ServiceTerritory.classify__c == 'W/C' ) {
                    alarmtalkReport.TopWorkcenter__c = ticket.WorkOrders[0].ServiceTerritory.ControlWorkcenter__r.Name == null ? '' : ticket.WorkOrders[0].ServiceTerritory.ControlWorkcenter__r.Name;
                } else {
                    alarmtalkReport.TopWorkcenter__c = ticket.WorkOrders[0].ServiceTerritory.Name;
                }
                            
                // 처리내용?
                alarmtalkReport.ProcessingDetail__c = ticket.WorkOrders[0].InspectionDetails__c;

                if (ticket.WorkOrders[0].TimeAgreedOnSite__c != null && ticket.WorkOrders[0].ServiceAppointments[0].Arrival__c != null) {
                    // 준수여부
                    alarmtalkReport.IsCompliance__c = ticket.WorkOrders[0].TimeAgreedOnSite__c > ticket.WorkOrders[0].ServiceAppointments[0].Arrival__c ? 'Y' : 'N';
                } else if (ticket.WorkOrders[0].TimeAgreedOnSite__c == null && ticket.WorkOrders[0].ServiceAppointments[0].Arrival__c != null) {
                    alarmtalkReport.IsCompliance__c = ticket.WorkOrders[0].FM_RepairRequestDateTime__c > ticket.WorkOrders[0].ServiceAppointments[0].Arrival__c  ? 'Y' : 'N';
                }
            }

            // 업체명
            alarmtalkReport.Account__c = alarmtalk.FM_Account__c;
            
            // 제조번호
            alarmtalkReport.Equipment__c = alarmtalk.FM_Equipment__c;
            
            // 기종
            alarmtalkReport.Gijong__c = alarmtalk.Equipment__c == null ? '' : alarmtalk.Model__c;
            
            // 호기
            alarmtalkReport.Hogi__c = alarmtalk.Equipment__c == null ? alarmtalk.FM_Equipment__c : alarmtalk.Equipment__r.SerialNumber;
            
            // 접수자?
            // alarmtalkReport.Receptionist__c = '';
            
            // 접수일시
            alarmtalkReport.ApplicationDateTime__c = ticket.ApplicationDateTime__c == null ? '' : ticket.ApplicationDateTime__c.format('yyyy-MM-dd HH:mm:ss');
            alarmtalkReport.ApplicationDate__c = ticket.ApplicationDateTime__c == null ? null : Date.valueOf(ticket.ApplicationDateTime__c);

            // 요청일시
            alarmtalkReport.RequestDatetime__c = alarmtalk.RepairRequestDateTime__c == null ? (ticket.RepairRequestDateTime__c == null ? '' : ticket.RepairRequestDateTime__c.format('yyyy-MM-dd HH:mm:ss')) : alarmtalk.RepairRequestDateTime__c.format('yyyy-MM-dd HH:mm:ss');

            // 요청자
            alarmtalkReport.Requester__c = alarmtalk.Contact__c == null ? (ticket.Requester__c == null ? '' : ticket.Requester__r.Name) : alarmtalk.Contact__r.Name;

            // 연락처
            alarmtalkReport.Phone__c = alarmtalk.Phone__c;

            // 상담유형 대분류
            alarmtalkReport.TicketType__c = ticket.InternalTicketType__c;
            
            // 상담유형?
            alarmtalkReport.TicketTypeDetail__c = ticket.InternalTicketType__c == 'Failure receipt' ? '클레임접수' : null;

            // 증상내용
            alarmtalkReport.Symptom__c = alarmtalk.Symptom__c;
            
            // 요청사항
            alarmtalkReport.RequestedTerm__c = alarmtalk.RequestedTerm__c;

            // 첨부유무?
            alarmtalkReport.HasAttachiment__c = '';

            // 상담원id(추후 추가)
            alarmtalkReport.OwnerPotalId__c = userCodeMap.get(ticket.OwnerId) == null ? '' : userCodeMap.get(ticket.OwnerId);

            // 상담원
            alarmtalkReport.TicketOwner__c = ticket.Owner.Name;

            upsertList.add(alarmtalkReport);
        }

        upsert upsertList;

    }

    public void finish(Database.BatchableContext context){
        System.debug('알림톡 모니터링 배치 끝!');
    }

    public void execute(SchedulableContext sc) {
        DN_AlarmTalkReportBatch batch = new DN_AlarmTalkReportBatch();
        Database.executeBatch(batch);
    }

}