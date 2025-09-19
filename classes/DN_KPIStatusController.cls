/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-25
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-13   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_KPIStatusController {

    // - 클레임완료L/T : ∑(완료일자–접수일자)/전체 출동오더 완료건수 cf)∑(완료일자–접수일자) = 15일 이하 건만(평균)
    // - 고객회신율 : 10' 이내 회신건수/전체 접수건수 cf)회신=첫번째 상담한 시간 들어온것
    // - 알림톡접수율 : 알림톡/QR-code로 고객이 접수한 건수/(콜서비스 건수+출동배정 건수)
    // - 1일이내수리완료율 : (24시간이내 완료건수)/(전체접수 건수+콜서비스건수)
    // - 1회출동수리완료율 : 1회 출동 완료건/서비스 전체 접수 완료건(무상기준)
    // - 콜서비스처리율 : 콜서비스건수/(전체 접수건수) cf)스핀들, Pre-call, 협력사 오더 제외
    // - 수리만족도 : 서비스 해피콜점수 총합계/해피콜 건수 cf)점수가 입력된 건수로 집계
    // - 설치만족도 : 설치만족도점수 총합계/설치 해피콜건수 cf)점수가 입력된 건수로 집계
    // - 대당Warranty Cost : 무상서비스 위탁수수료/평균 보증대수(TC), 무상서비스 위탁수수료/평균 보증대수(MC) cf)년가 대상장비
    // - 고객 예약률 : 고객 예약 건수/전체 접수건수
    // - 고객예약준수율 : 전체 접수건수 중 고객과 예약한 시간 +1시간 내 출동한 비율
    // - 직영배정율 : 본사(직영/지사)배정건/전체배정건수

    // 검색조건의 지사, Work Center를 Picklist화 하기위한 메서드
    @AuraEnabled
    public static InitWrapper getPicklistLabelValue() {

        InitWrapper result = new InitWrapper();

        try {
            List<ServiceTerritory> workcenterList = [SELECT Id, classify__c, Name FROM ServiceTerritory WHERE PlanningPlant__c = '184S' AND IsActive = true];
            Set<String> stNameSet = new Set<String>();
            Map<String, ServiceTerritory> stMap = new Map<String, ServiceTerritory>();
            for (ServiceTerritory st : workcenterList) {
                stNameSet.add(st.Name);
                stMap.put(st.Name, st);
            }

            List<String> stNameList = new List<String>(stNameSet);
            stNameList.sort();

            PicklistWrapper firstObj = new PicklistWrapper();
            firstObj.label = '== 선택 ==';
            firstObj.value = 'all';
            result.topWorkcenterList.add(firstObj);
            result.workcenterList.add(firstObj);

            for (String name : stNameList) {
                ServiceTerritory wc = stMap.get(name);
                PicklistWrapper obj = new PicklistWrapper();
                if (wc.classify__c == '지사' || wc.classify__c == 'POST') {
                    obj.label = wc.Name;
                    obj.value = wc.Id;
                    result.topWorkcenterList.add(obj);
                } else if (wc.classify__c == 'W/C') {
                    obj.label = wc.Name;
                    obj.value = wc.Id;
                    result.workcenterList.add(obj);
                }
            }
        } catch (Exception e) {
            result.result.isSuccess = false;
            result.result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
        }

        return result;
    }

    // 검색조건으로 Ticket을 필터링해서 전달하는 메서드 1 (데이터 량이 많아 getData와 분리해서 진행)
    @AuraEnabled
    public static List<Case> getTicketList(String startDate, String endDate){
        List<Case> fullTicketList = new List<Case>();
        try {
            Datetime start = makeStartDatetime(startDate);
            Datetime last = makeEndDatetime(endDate);
    
            fullTicketList = [  SELECT  Id, ApplicationDateTime__c, ClosedDate, GeneralCallDatetime__c, TechnicalCallDatetime__c, ReceptionPath__c, Status, InternalTicketType__c
                                FROM Case
                                WHERE ApplicationDateTime__c >= :start AND ApplicationDateTime__c <= :last AND ApplicationDateTime__c != null
            ];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return fullTicketList;
    }

    // 검색조건으로 Ticket을 필터링해서 전달하는 메서드 2 (데이터 량이 많아 getTicketList와 분리해서 진행)
    @AuraEnabled
    public static List<KPIWrapper> getData(List<Case> fullTicketList, String startDate, String endDate, String workcenterId, String type, String keyType) {

        // Datetime start = makeStartDatetime(startDate);
        // Datetime last = makeEndDatetime(endDate);

        // // List<Case> ticketList = new List<Case>();
        // List<Case> fullTicketList = [   SELECT  Id, ApplicationDateTime__c, ClosedDate, GeneralCallDatetime__c, TechnicalCallDatetime__c, ReceptionPath__c, Status, InternalTicketType__c
        //                                 FROM Case
        //                                 WHERE ApplicationDateTime__c >= :start AND ApplicationDateTime__c <= :last AND ApplicationDateTime__c != null
        // ];
        List<KPIWrapper> resultList = new List<KPIWrapper>();
        
        Set<String> ticketIds = new Set<String>();
        for (Case ticket : fullTicketList) {
            ticketIds.add(ticket.Id);
        }

        List<WorkOrder> serviceOrderList = [SELECT Id, CaseId, completionTime__c, Status, ServiceTerritoryId, ServiceTerritory.Name, ServiceTerritory.classify__c, ServiceTerritory.ControlWorkcenter__c, ServiceTerritory.ControlWorkcenter__r.Name, OrderType__c, TimeAgreedOnSite__c
                                            FROM WorkOrder
                                            WHERE CaseId IN :ticketIds
                                            ORDER BY CreatedDate DESC
        ];

        Map<String, List<WorkOrder>> serviceOrderMap = new Map<String, List<WorkOrder>>();
        Set<String> serviceOrderIds = new Set<String>();
        for (WorkOrder wo : serviceOrderList) {
            List<WorkOrder> valueList = new List<WorkOrder>();
            if (serviceOrderMap.containsKey(wo.CaseId)) valueList = serviceOrderMap.get(wo.CaseId);
            valueList.add(wo);
            serviceOrderMap.put(wo.CaseId, valueList);
            serviceOrderIds.add(wo.Id);
        }

        List<ServiceAppointment> saList = [ SELECT Id, WorkCompletionTime__c, Status, Department__c, ParentRecordId
                                            FROM ServiceAppointment
                                            WHERE WorkerType__c = 'Service Resource (Main)' AND ParentRecordId IN :serviceOrderIds
                                            ORDER BY CreatedDate DESC
        ];

        Map<String, List<ServiceAppointment>> saMap = new Map<String, List<ServiceAppointment>>();
        for (ServiceAppointment sa : saList) {
            List<ServiceAppointment> valueList = new List<ServiceAppointment>();
            if (saMap.containsKey(sa.ParentRecordId)) valueList = saMap.get(sa.ParentRecordId);
            valueList.add(sa);
            saMap.put(sa.ParentRecordId, valueList);
        }

        List<Case> ticketList = new List<Case>();
        if (type == 'TopWC') {
            for (Case ticket : fullTicketList) {
                if (serviceOrderMap.containsKey(ticket.Id)) {
                    WorkOrder order = serviceOrderMap.get(ticket.Id)[0];
                    if (order.ServiceTerritory.classify__c == 'W/C') {
                        if (order.ServiceTerritory.ControlWorkcenter__c == workcenterId) {
                            ticketList.add(ticket);
                        }
                    } else {
                        if (order.ServiceTerritoryId == workcenterId) {
                            ticketList.add(ticket);
                        }
                    }
                }
            }
        } else if (type == 'WC') {
            for (Case ticket : fullTicketList) {
                if (serviceOrderMap.containsKey(ticket.Id)) {
                    WorkOrder order = serviceOrderMap.get(ticket.Id)[0];
                    if (order.ServiceTerritoryId == workcenterId) {
                        ticketList.add(ticket);
                    }
                }
            }
        } else if (type == 'all') {
            for (Case ticket : fullTicketList) {
                if (serviceOrderMap.containsKey(ticket.Id)) {
                    ticketList.add(ticket);
                }
            }
            // ticketList = fullTicketList;
        }


                                
        Map<String, KPIWrapper> kpiMap = new Map<String, KPIWrapper>();

        if (ticketList.size() > 0) {

            Map<String, Case> ticketMap = new Map<String, Case>();
            Map<String, List<CampaignTarget__c>> campaignListMap = new Map<String, List<CampaignTarget__c>>();

            for (Case ticket : ticketList) {
                ticketMap.put(ticket.Id, ticket);
            }

            List<CampaignTarget__c> campaignTargetList = [SELECT Id, Score__c, Campaign__c, Campaign__r.CampaignMaster__r.Survey__c, Ticket__c FROM CampaignTarget__c WHERE Score__c != null AND Campaign__c != null AND Ticket__c IN :ticketMap.keySet()];

            for (CampaignTarget__c target : campaignTargetList) {
                List<CampaignTarget__c> valueList = new List<CampaignTarget__c>();
                if (campaignListMap.get(target.Ticket__c) != null) valueList = campaignListMap.get(target.Ticket__c);
                valueList.add(target);
                campaignListMap.put(target.Ticket__c, valueList);
            }

            List<Survey> surveyList = [SELECT Id, Name FROM Survey];
            Map<String, String> surveyMap = new Map<String, String>();

            for (Survey survey : surveyList) {
                surveyMap.put(survey.Name, survey.Id);
            }

            Map<String, ClaimWrapper> claimMap = new Map<String, ClaimWrapper>();
            Map<String, ReplyWrapper> replyMap = new Map<String, ReplyWrapper>();
            Map<String, AlarmtalkWrapper> alarmtalkMap = new Map<String, AlarmtalkWrapper>();
            Map<String, CompletedIn24Wrapper> completedIn24Map = new Map<String, CompletedIn24Wrapper>();
            Map<String, CompletedIn1DispatchWrapper> completedIn1DispatchMap = new Map<String, CompletedIn1DispatchWrapper>();
            Map<String, CallServiceWrapper> callServiceMap = new Map<String, CallServiceWrapper>();
            Map<String, CustomerReservationWrapper> customerReservationMap = new Map<String, CustomerReservationWrapper>();
            Map<String, CustomerReservationObeyWrapper> customerReservationObeyMap = new Map<String, CustomerReservationObeyWrapper>();
            Map<String, DirectWCAllotmentWrapper> directWCAllotmentMap = new Map<String, DirectWCAllotmentWrapper>();
            Map<String, RepairSatisfactionWrapper> repairSatisfactionMap = new Map<String, RepairSatisfactionWrapper>();
            Map<String, InstallSatisfactionWrapper> installSatisfactionMap = new Map<String, InstallSatisfactionWrapper>();

            for (Case ticket : ticketList) {
                String key = '';
                if (keyType == 'monthly') {
                    key = ticket.ApplicationDateTime__c.format('yyyy년 MM월');
                } else if (keyType == 'weekly') {
                    key = ticket.ApplicationDateTime__c.format('yyyy년 MM월 W주차');
                }

                // - 클레임완료L/T : ∑(완료일자–접수일자)/전체 출동오더 완료건수 cf)∑(완료일자–접수일자) = 15일 이하 건만(평균)
                // (Ticket의 접수일과 Ticket의 종료일이 15일 이내 완료인 건수)  / (Ticket의 Status가 Closed인 건수)
                
                ClaimWrapper cw = new ClaimWrapper();

                if (claimMap.get(key) != null) cw = claimMap.get(key);

                if (serviceOrderMap.containsKey(ticket.Id)) {
                    if (ticket.Status == 'Closed') {
                        cw.claimAllCount += 1;
                        Date firstDate = Date.valueOf(ticket.ApplicationDateTime__c);
                        Date secondDate = Date.valueOf(ticket.ClosedDate);
    
                        if (ticket.ApplicationDateTime__c.addDays(15) >= ticket.ClosedDate) {
                            cw.claimBetweenDayCount += 1;
                        }
                        // if (firstDate.daysBetween(secondDate) < 15) {
                        //     cw.claimBetweenDayCount += 1;
                        // }
                    }
                }              
                claimMap.put(key, cw);

                
                // - 고객회신율 : 10' 이내 회신건수/전체 접수건수 cf)회신=첫번째 상담한 시간 들어온것
                // (Ticket의 접수 시간이랑 첫번째 상담한시간이 10' 이내 건수) / (Ticket의 모든 접수 건수)

                ReplyWrapper rw = new ReplyWrapper();

                if (replyMap.get(key) != null) rw = replyMap.get(key);

                rw.replyAllCount += 1;
                Datetime firstCallDatetime;
                Boolean timeDifferenceRW = false;

                if (ticket.GeneralCallDatetime__c != null && ticket.TechnicalCallDatetime__c == null) {
                    firstCallDatetime = ticket.GeneralCallDatetime__c;
                    timeDifferenceRW = dates10MinutesApart(ticket.ApplicationDateTime__c, firstCallDatetime);
                } else if (ticket.GeneralCallDatetime__c == null && ticket.TechnicalCallDatetime__c != null) {
                    firstCallDatetime = ticket.TechnicalCallDatetime__c;
                    timeDifferenceRW = dates10MinutesApart(ticket.ApplicationDateTime__c, firstCallDatetime);
                } else if (ticket.GeneralCallDatetime__c != null && ticket.TechnicalCallDatetime__c != null) {
                    firstCallDatetime = ticket.GeneralCallDatetime__c <= ticket.TechnicalCallDatetime__c ? ticket.GeneralCallDatetime__c : ticket.TechnicalCallDatetime__c;
                    timeDifferenceRW = dates10MinutesApart(ticket.ApplicationDateTime__c, firstCallDatetime);
                }

                if (timeDifferenceRW) {
                    rw.replyCount += 1;
                }
                replyMap.put(key, rw);


                // - 알림톡접수율 : 알림톡/QR-code로 고객이 접수한 건수/(콜서비스 건수+출동배정 건수)
                // (접수경로가 알림톡인 건수) / (Ticket의 Status가 Call Service거나 배정 완료인 상태인 건수)

                AlarmtalkWrapper aw = new AlarmtalkWrapper();

                if (alarmtalkMap.get(key) != null) aw = alarmtalkMap.get(key);

                if (ticket.ReceptionPath__c == 'Alarm Talk') {
                    aw.alarmtalkCount += 1;
                }
                if ((ticket.Status == 'Call Service' || ticket.Status == 'Assignment completed')) {
                    aw.alarmtalkAllCount += 1;
                }
                alarmtalkMap.put(key, aw);


                // - 1일이내수리완료율 : (24시간이내 완료건수) / (전체접수 건수 + 콜서비스건수)
                // (Ticket접수일과 Ticket종료일이 24시간 이내인 건수 ) / (Ticket의 모든 접수 건수)

                CompletedIn24Wrapper ciw = new CompletedIn24Wrapper();
                
                if (completedIn24Map.get(key) != null) ciw = completedIn24Map.get(key);

                ciw.allCount += 1;
                Boolean timeDifferenceCIW = false;
                if (ticket.Status == 'Closed') {
                    if (ticket.ApplicationDateTime__c.addHours(24) >= ticket.ClosedDate) {
                        ciw.completedIn24Count += 1;
                    }
                }

                // if (ticket.ClosedDate != null) {
                //     timeDifferenceCIW = dates24HoursApart(ticket.ClosedDate, ticket.ApplicationDateTime__c);
                // }                            

                // if (timeDifferenceCIW) {
                //     ciw.completedIn24Count += 1;
                // }
                completedIn24Map.put(key, ciw);

                
                // - 1회출동수리완료율 : 1회 출동 완료건/서비스 전체 접수 완료건(무상기준 (Work Order - OrderType = 201))
                // (Ticket의 접수일자와 최근오더(Work Order - OrderType = 201)가 1개고 최근 Appointment가 1개로 완료인 건) / (Ticket의 접수일자와 최근오더(Work Order - OrderType = 201)의 최근 Appointment가 완료인 건)
                CompletedIn1DispatchWrapper cidw = new CompletedIn1DispatchWrapper();

                if (completedIn1DispatchMap.get(key) != null) cidw = completedIn1DispatchMap.get(key);

                if (serviceOrderMap.get(ticket.Id).size() > 1) {

                    WorkOrder order = serviceOrderMap.get(ticket.Id)[0];
                    if (order.Status == 'Confirm' && order.OrderType__c == '201') {
                        if (saMap.get(order.Id).size() > 0) {
                            if (saMap.get(order.Id)[0].Status == 'Completed') {
                                cidw.allCount += 1;
                            }
                        }
                    }
                } else if (serviceOrderMap.get(ticket.Id).size() == 1) {
                    WorkOrder order = serviceOrderMap.get(ticket.Id)[0];
                    if (order.Status == 'Confirm' && order.OrderType__c == '201') {
                        if (saMap.get(order.Id) != null && saMap.get(order.Id).size() > 1) {
                            if (saMap.get(order.Id)[0].Status == 'Completed') {
                                cidw.allCount += 1;
                            }
                        } else if (saMap.get(order.Id) != null && saMap.get(order.Id).size() == 1) {
                            if (saMap.get(order.Id)[0].Status == 'Completed') {
                                cidw.allCount += 1;
                                cidw.completedIn1DispatchCount += 1;
                            }
                        }
                    }
                }
                completedIn1DispatchMap.put(key, cidw);


                // - 콜서비스처리율 : 콜서비스건수/(전체 접수건수) cf)스핀들(Work Order - OrderType = 215, 214), Pre-call(Ticket - Type Middle = Pre-call), 협력사 오더(W/C - Name = 협력업체) 제외
                // (콜서비스건수(Ticket - Status = Call Service))/(전체 접수건수(스핀들(work order - OrderType = 215, 214), Pre-call(Ticket - Type Middle = Pre-call), 협력사 오더(W/C - Name = 협력업체) 제외))
                CallServiceWrapper csw = new CallServiceWrapper();

                if (callServiceMap.get(key) != null) csw = callServiceMap.get(key);

                if (ticket.InternalTicketType__c != 'Pre-Call') {
                    if (serviceOrderMap.get(ticket.Id).size() > 0) {
                        WorkOrder order = serviceOrderMap.get(ticket.Id)[0];
                        if (order.ServiceTerritory.Name != '협력업체' && order.OrderType__c != '215' && order.OrderType__c != '214') {
                            csw.allCount += 1;
                            if (ticket.Status == 'Call Service') {
                                csw.callserviceCount += 1;
                            }
                        }
                    } else {
                        csw.allCount += 1;
                        if (ticket.Status == 'Call Service') {
                            csw.callserviceCount += 1;
                        }
                    }
                }
                callServiceMap.put(key, csw);



                // - 수리만족도 : 서비스 해피콜점수 총합계/해피콜 건수 cf)점수가 입력된 건수로 집계
                // - 설치만족도 : 설치만족도점수 총합계/설치 해피콜건수 cf)점수가 입력된 건수로 집계
                RepairSatisfactionWrapper rsw = new RepairSatisfactionWrapper();
                InstallSatisfactionWrapper isw = new InstallSatisfactionWrapper();
                
                if (repairSatisfactionMap.get(key) != null) rsw = repairSatisfactionMap.get(key);
                if (installSatisfactionMap.get(key) != null) isw = installSatisfactionMap.get(key);

                if (campaignListMap.get(ticket.Id) != null) {
                    for (CampaignTarget__c target : campaignListMap.get(ticket.Id)) {
                        if (target.Campaign__r.CampaignMaster__r.Survey__c == surveyMap.get('설치알림톡')) {
                            isw.allCount += 1;
                            isw.score += target.Score__c;
                        } else if (target.Campaign__r.CampaignMaster__r.Survey__c == surveyMap.get('서비스 알림톡')) {
                            rsw.allCount += 1;
                            rsw.score += target.Score__c;
                        }
                    }
                }
                repairSatisfactionMap.put(key, rsw);
                installSatisfactionMap.put(key, isw);

                // - 고객 예약률 : 고객 예약 건수/전체 접수건수
                // ((First) WorkOrder - TimeAgreedOnSite__c 가있는 Ticket 건수) / (전체 Ticket 건수)
                CustomerReservationWrapper crw = new CustomerReservationWrapper();

                if (customerReservationMap.get(key) != null) crw = customerReservationMap.get(key);

                crw.allCount += 1;
                if (serviceOrderMap.get(ticket.Id).size() > 0) {
                    WorkOrder order = serviceOrderMap.get(ticket.Id)[serviceOrderMap.get(ticket.Id).size() - 1];
                    if (order.TimeAgreedOnSite__c != null) {
                        crw.customerReservationCount += 1;
                    }
                }
                customerReservationMap.put(key, crw);


                // - 고객예약준수율 : 전체 접수건수 중 고객과 예약한 시간 +1시간 내 출동한 비율
                // (ServiceAppointment.Department__c이 (First)WorkOrder.TimeAgreedOnSite__c + 1시간 이내인 Ticket 건수) / (전체 Ticket 건수)
                CustomerReservationObeyWrapper crow = new CustomerReservationObeyWrapper();

                if (customerReservationObeyMap.get(key) != null) crow = customerReservationObeyMap.get(key);

                crow.allCount += 1;
                if (serviceOrderMap.get(ticket.Id).size() > 0) {
                    WorkOrder order = serviceOrderMap.get(ticket.Id)[serviceOrderMap.get(ticket.Id).size() - 1];
                    if (saMap.get(order.Id) != null && saMap.get(order.Id).size() > 0) {
                        if (order.TimeAgreedOnSite__c != null && saMap.get(order.Id)[0].Department__c != null && order.TimeAgreedOnSite__c.addHours(1) >= saMap.get(order.Id)[0].Department__c) {
                            crow.customerReservationObeyCount += 1;
                        }
                    }
                }
                customerReservationObeyMap.put(key, crow);


                // - 직영배정율 : 본사(직영/지사)배정건/전체배정건수
                // 지사, POST 배정 건 수 / 전체배정건수
                DirectWCAllotmentWrapper dwcaw = new DirectWCAllotmentWrapper();

                if (directWCAllotmentMap.get(key) != null) dwcaw = directWCAllotmentMap.get(key);

                if (serviceOrderMap.get(ticket.Id).size() > 0) {
                    for (WorkOrder wo : serviceOrderMap.get(ticket.Id)) {
                        dwcaw.allCount += 1;
                        if (wo.ServiceTerritory.classify__c == '지사' || wo.ServiceTerritory.classify__c == 'POST') {
                            dwcaw.directWCAllotmentCount += 1;
                        }
                    }
                }
                directWCAllotmentMap.put(key, dwcaw);
            }



            for (String key : claimMap.keySet()) {
                
                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }
    
                ClaimWrapper cw = claimMap.get(key);
                // System.debug('Test1 ::: ' + key + ' ::: ' + cw.claimBetweenDayCount + ' ::: ' + cw.claimAllCount);
                wrapper.claimLT = cw.claimAllCount == 0 ? 0 : (cw.claimBetweenDayCount / cw.claimAllCount) * 100;
                kpiMap.put(key, wrapper);
            }

            for (String key : replyMap.keySet()) {
                
                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }
    
                ReplyWrapper rw = replyMap.get(key);
                // System.debug('Test2 ::: ' + key + ' ::: ' + rw.replyCount + ' ::: ' + rw.replyAllCount);
                wrapper.replyRate = rw.replyAllCount == 0 ? 0 : (rw.replyCount / rw.replyAllCount) * 100;
                kpiMap.put(key, wrapper);                
            }

            for (String key : alarmtalkMap.keySet()) {

                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }

                AlarmtalkWrapper aw = alarmtalkMap.get(key);
                // System.debug('Test3 ::: ' + key + ' ::: ' + aw.alarmtalkCount + ' ::: ' + aw.alarmtalkAllCount);
                wrapper.alarmtalkRate = aw.alarmtalkAllCount == 0 ? 0 : (aw.alarmtalkCount / aw.alarmtalkAllCount) * 100;
                kpiMap.put(key, wrapper);
            }

            for (String key : completedIn24Map.keySet()) {

                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }

                CompletedIn24Wrapper ciw = completedIn24Map.get(key);
                // System.debug('Test4 ::: ' + key + ' ::: ' + ciw.completedIn24Count + ' ::: ' + ciw.allCount);
                wrapper.completedIn24Rate = ciw.allCount == 0 ? 0 : (ciw.completedIn24Count / ciw.allCount) * 100;
                kpiMap.put(key, wrapper);
            }

            for (String key : completedIn1DispatchMap.keySet()) {

                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }

                CompletedIn1DispatchWrapper cidw = completedIn1DispatchMap.get(key);
                // System.debug('Test5 ::: ' + key + ' ::: ' + cidw.completedIn1DispatchCount + ' ::: ' + cidw.allCount);
                wrapper.completedIn1DispatchRate = cidw.allCount == 0 ? 0 : (cidw.completedIn1DispatchCount / cidw.allCount) * 100;
                kpiMap.put(key, wrapper);
            }

            for (String key : callServiceMap.keySet()) {

                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }

                CallServiceWrapper csw = callServiceMap.get(key);
                // System.debug('Test6 ::: ' + key + ' ::: ' + csw.callserviceCount + ' ::: ' + csw.allCount);
                wrapper.callServiceRate = csw.allCount == 0 ? 0 : (csw.callserviceCount / csw.allCount) * 100;
                kpiMap.put(key, wrapper);
            }

            for (String key : customerReservationMap.keySet()) {

                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }

                CustomerReservationWrapper crw = customerReservationMap.get(key);
                // System.debug('Test7 ::: ' + key + ' ::: ' + crw.customerReservationCount + ' ::: ' + crw.allCount);
                wrapper.customerReservationRate = crw.allCount == 0 ? 0 : (crw.customerReservationCount / crw.allCount) * 100;
                kpiMap.put(key, wrapper);
            }

            for (String key : customerReservationObeyMap.keySet()) {

                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }

                CustomerReservationObeyWrapper crow = customerReservationObeyMap.get(key);
                // System.debug('Test8 ::: ' + key + ' ::: ' + crow.customerReservationObeyCount + ' ::: ' + crow.allCount);
                wrapper.customerReservationObeyRate = crow.allCount == 0 ? 0 : (crow.customerReservationObeyCount / crow.allCount) * 100;
                kpiMap.put(key, wrapper);
            }

            for (String key : directWCAllotmentMap.keySet()) {

                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }

                DirectWCAllotmentWrapper dwcaw = directWCAllotmentMap.get(key);
                // System.debug('Test9 ::: ' + key + ' ::: ' + dwcaw.directWCAllotmentCount + ' ::: ' + dwcaw.allCount);
                wrapper.directWCAllotmentRate = dwcaw.allCount == 0 ? 0 : (dwcaw.directWCAllotmentCount / dwcaw.allCount) * 100;
                kpiMap.put(key, wrapper);
            }

            for (String key : repairSatisfactionMap.keySet()) {

                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }

                RepairSatisfactionWrapper rsw = repairSatisfactionMap.get(key);
                // System.debug('Test10 ::: ' + key + ' ::: ' + dwcaw.score + ' ::: ' + dwcaw.allCount);
                wrapper.repairSatisfactionScore = rsw.allCount == 0 ? 0 : (rsw.score / rsw.allCount);
                kpiMap.put(key, wrapper);
            }

            for (String key : installSatisfactionMap.keySet()) {

                KPIWrapper wrapper = new KPIWrapper();

                if (kpiMap.containsKey(key)) {
                    wrapper = kpiMap.get(key);
                } else {
                    wrapper.name = key;
                }

                InstallSatisfactionWrapper isw = installSatisfactionMap.get(key);
                // System.debug('Test11 ::: ' + key + ' ::: ' + isw.score + ' ::: ' + isw.allCount);
                wrapper.installSatisfactionScore = isw.allCount == 0 ? 0 : (isw.score / isw.allCount);
                kpiMap.put(key, wrapper);
            }

        }

        // resultList = kpiMap.values();
        resultList = sortingList(kpiMap.values());

        // System.debug('TicketList ::: '+ ticketList);
        // System.debug('TicketList Size ::: '+ ticketList.size());
        // System.debug('startDate ::: ' + startDate);
        // System.debug('endDate ::: ' + endDate);
        // System.debug('workcenterId ::: ' + workcenterId);
        // System.debug('type ::: ' + type);

        return resultList;
    }

    // yyyy-MM-dd 형태의 String을 Datetime(해당 년월의 1일 00시00분00초)으로 변경하는 메서드
    private static Datetime makeStartDatetime(String dateString) {
        Integer year = Integer.valueOf(dateString.split('-')[0]);
        Integer month = Integer.valueOf(dateString.split('-')[1]);

        Datetime result = Datetime.newInstance(year, month, 1);

        return result;
    }

    // yyyy-MM-dd 형태의 String을 Datetime(해당 년월의 마지막일 23시59분59초)으로 변경하는 메서드
    private static Datetime makeEndDatetime(String dateString) {
        Integer year = Integer.valueOf(dateString.split('-')[0]);
        Integer month = Integer.valueOf(dateString.split('-')[1]);

        Datetime result = Datetime.newInstance(year, month, Date.daysInMonth(year, month), 23, 59, 59);

        return result;
    }

    // 두 개의 Datetime값의 차이가 10분 이내인지 확인하는 메서드
    private static Boolean dates10MinutesApart(Datetime date1, Datetime date2) {
        // 두 DateTime 객체 간의 차이를 구함
        Long differenceInMillis = date2.getTime() - date1.getTime();

        // 밀리초를 분 단위로 변환
        Long differenceInMinutes = differenceInMillis / (1000 * 60);

        // System.debug('Math.abs(differenceInMinutes) ::: ' + Math.abs(differenceInMinutes));

        // 10분 차이가 나는지 확인
        if (Math.abs(differenceInMinutes) <= 10) {
            return true;
        }
        return false;
    }

    // private static Boolean dates24HoursApart(Datetime date1, Datetime date2) {
    //     // 두 DateTime 객체 간의 차이를 구함
    //     Long differenceInMillis = date2.getTime() - date1.getTime();

    //     // 밀리초를 시간 단위로 변환
    //     Long differenceInHours = differenceInMillis / (1000 * 60 * 60);

    //     // System.debug('Math.abs(differenceInHours) ::: ' + Math.abs(differenceInHours));

    //     // 24시간 차이가 나는지 확인
    //     if (Math.abs(differenceInHours) <= 24) {
    //         return true;
    //     }
    //     return false;
    // }

    // List를 sort하는 메서드
    public static List<KPIWrapper> sortingList(List<KPIWrapper> kpiList) {

        Map<String, KPIWrapper> kpiMap = new Map<String, KPIWrapper>();

        List<String> keyList = new List<String>();

        for (KPIWrapper kpi : kpiList) {
            List<String> valueList = new List<String>();

            keyList.add(kpi.name);
            kpiMap.put(kpi.name, kpi);
        }
        
        keyList.sort();

        List<KPIWrapper> resultList = new List<KPIWrapper>();

        for (String key : keyList) {
            resultList.add(kpiMap.get(key));
        }

        return resultList;

    }

    public class InitWrapper {
        @AuraEnabled public List<PicklistWrapper>   topWorkcenterList   { get; set; }
        @AuraEnabled public List<PicklistWrapper>   workcenterList      { get; set; }
        @AuraEnabled public ResultWrapper           result              { get; set; }

        public InitWrapper() {
            this.topWorkcenterList  = new List<PicklistWrapper>();
            this.workcenterList     = new List<PicklistWrapper>();
            this.result             = new ResultWrapper();
        }
    }

    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess   { get; set; }
        @AuraEnabled public String message      { get; set; }

        public ResultWrapper() {
            this.isSuccess = true;
            this.message = '';
        }
    }

    public class PicklistWrapper {
        @AuraEnabled public String label    { get; set; }
        @AuraEnabled public String value    { get; set; }

        public PicklistWrapper() {
            this.label = '';
            this.value = '';
        }
    }

    // 클레임L/T
    public class ClaimWrapper {
        public Decimal claimAllCount            { get; set; }
        public Decimal claimBetweenDayCount     { get; set; }

        public ClaimWrapper() {
            this.claimAllCount = 0;
            this.claimBetweenDayCount = 0;
        }
    }

    // 고객회신율
    public class ReplyWrapper {
        public Decimal replyAllCount    { get; set; }
        public Decimal replyCount       { get; set; }

        public ReplyWrapper() {
            this.replyAllCount = 0;
            this.replyCount = 0;
        }
    }

    // 알림톡접수율
    public class AlarmtalkWrapper {
        public Decimal alarmtalkAllCount    { get; set; }
        public Decimal alarmtalkCount       { get; set; }

        public AlarmtalkWrapper() {
            this.alarmtalkAllCount = 0;
            this.alarmtalkCount = 0;
        }
    }

    // 1일이내 수리완료율
    public class CompletedIn24Wrapper {
        public Decimal allCount             { get; set; }
        public Decimal completedIn24Count   { get; set; }

        public CompletedIn24Wrapper() {
            this.allCount = 0;
            this.completedIn24Count = 0;
        }
    }

    // 1회출동 수리완료율
    public class CompletedIn1DispatchWrapper {
        public Decimal allCount                     { get; set; }
        public Decimal completedIn1DispatchCount    { get; set; }

        public CompletedIn1DispatchWrapper() {
            this.allCount = 0;
            this.completedIn1DispatchCount = 0;
        }
    }

    // 콜서비스처리율
    public class CallServiceWrapper {
        public Decimal allCount             { get; set; }
        public Decimal callserviceCount     { get; set; }

        public CallServiceWrapper() {
            this.allCount = 0;
            this.callserviceCount = 0;
        }
    }

    // 고객 예약률
    public class CustomerReservationWrapper {
        public Decimal allCount                 { get; set; }
        public Decimal customerReservationCount { get; set; }

        public CustomerReservationWrapper() {
            this.allCount = 0;
            this.customerReservationCount = 0;
        }
    }

    // 고객예약준수율
    public class CustomerReservationObeyWrapper {
        public Decimal allCount                     { get; set; }
        public Decimal customerReservationObeyCount { get; set; }

        public CustomerReservationObeyWrapper() {
            this.allCount = 0;
            this.customerReservationObeyCount = 0;
        }
    }

    // 직영배정율
    public class DirectWCAllotmentWrapper {
        public Decimal allCount                 { get; set; }
        public Decimal directWCAllotmentCount   { get; set; }

        public DirectWCAllotmentWrapper() {
            this.allCount = 0;
            this.directWCAllotmentCount = 0;
        }
    }

    // 수리만족도
    public class RepairSatisfactionWrapper {
        public Decimal allCount     { get; set; }
        public Decimal score        { get; set; }

        public RepairSatisfactionWrapper() {
            this.allCount = 0;
            this.score = 0;
        }
    }

    // 설치만족도
    public class InstallSatisfactionWrapper {
        public Decimal allCount     { get; set; }
        public Decimal score        { get; set; }

        public InstallSatisfactionWrapper() {
            this.allCount = 0;
            this.score = 0;
        }
    }

    public class KPIWrapper{
        
        @AuraEnabled public String  name                        { get; set; }
        @AuraEnabled public Decimal claimLT                     { get; set; }
        @AuraEnabled public Decimal replyRate                   { get; set; }
        @AuraEnabled public Decimal alarmtalkRate               { get; set; }
        @AuraEnabled public Decimal completedIn24Rate           { get; set; }
        @AuraEnabled public Decimal completedIn1DispatchRate    { get; set; }
        @AuraEnabled public Decimal callServiceRate             { get; set; }
        @AuraEnabled public Decimal customerReservationRate     { get; set; }
        @AuraEnabled public Decimal customerReservationObeyRate { get; set; }
        @AuraEnabled public Decimal directWCAllotmentRate       { get; set; }
        @AuraEnabled public Decimal repairSatisfactionScore     { get; set; }
        @AuraEnabled public Decimal installSatisfactionScore    { get; set; }

        public KPIWrapper() {
            this.claimLT = 0;
            this.replyRate = 0;
            this.alarmtalkRate = 0;
            this.completedIn24Rate = 0;
            this.completedIn1DispatchRate = 0;
            this.callServiceRate = 0;
            this.customerReservationRate = 0;
            this.customerReservationObeyRate = 0;
            this.directWCAllotmentRate = 0;
            this.repairSatisfactionScore = 0;
            this.installSatisfactionScore = 0;
        }
    }

}