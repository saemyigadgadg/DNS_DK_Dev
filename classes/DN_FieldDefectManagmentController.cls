/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-25
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-02-05   yeongdeok.seo@sbtglobal.com   Initial Version
**/

public with sharing class DN_FieldDefectManagmentController {

    public static Schema.DescribeSObjectResult schemaReady        = Schema.getGlobalDescribe().get('Case').getDescribe();
    public static Map<String, Schema.SObjectField> schemaFieldMap = schemaReady.fields.getMap();

    public DN_FieldDefectManagmentController() {}

    // Init에 필요한 정보를 담아서 Component에 전달하는 메서드
    @AuraEnabled
    public static Map<String, Object> getInit(String ticketId, List<String> fieldApiNames){
        try {
            Map<String, Object> result = new Map<String, Object>();

            result.put('getTicketInfo', getTicketInfo(ticketId));

            for (String apiName : fieldApiNames) {
                
                result.put(apiName, getPicklistfield(apiName));

            }

            TicketObject ticketObj = (TicketObject) result.get('getTicketInfo');
            List<Object> pendingList = (List<Object>) result.get('Pendingprocessing__c');
            for (Object obj : pendingList) {
                Map<String, String> labelMap = (Map<String, String>) obj;
                if (labelMap.get('value') == ticketObj.pendingProcessing) {
                    ticketObj.pendingProcessingLabel = labelMap.get('label');
                    break;
                }
            }

            ticketObj.pendingProcessingLabel = ticketObj.pendingProcessingLabel == '--None--' ? '' : ticketObj.pendingProcessingLabel;

            result.put('getTicketInfo', ticketObj);

            return result;

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    // TicketId로 해당 Ticket과 관련된 오브젝트들의 정보를 담는 메서드
    private static TicketObject getTicketInfo(String ticketId) {
        System.debug('ticketId ::: ' + ticketId);

        Case caseInfo = [
            SELECT  Id, Owner.Name, Requester__r.Name, IsUrgency__c, IsReGenerate__c, toLabel(Severity__c), Urgency__c, Asset.FM_SalesRep__c,
                    Requester__r.MobilePhone, Asset.FM_Address__c, toLabel(InternalTicketType__c), InstallationDefect__c, Complaint__c,
                    Asset.InstEngineer__r.Name, Asset.InstEngineer__r.Service_Territory__r.Name, Asset.InstallationFinish__c,
                    CreatedDate, ApplicationDateTime__c, Countermeasure__c, AssetId, CSMember__c, CSMember__r.Name, CSDueDate__c, ReceptionDetails__c,
                    CooperationDate__c, CooperationTeam__c, CooperationPerson__c, SkillCheck__c, Asset.MachineName__c, Asset.Order__r.OwnerId,
                    Pendingprocessing__c, PendingProcessingLabel__c, PendingDetail__c, CSMemberMig__c, AfterResponsePlan__c, Asset.SalesAgency__c
            FROM Case
            WHERE Id = :ticketId
        ];

        List<WorkOrder> ticketWorkOrderList = [
            SELECT  Id, Worker__r.Service_Territory__r.classify__c, Worker__r.Service_Territory__r.Name, Worker__r.Service_Territory__r.ControlWorkcenter__r.Name,
                    Worker__r.Name, Worker__r.PhoneNumber__c, WorkOrderNumber, FM_RepairRequestDateTime__c, InspectionDetails__c, CreatedDate, Noti_Number__c, ServiceOrderNumber__c, PendingOrCustomerMatters__c
            FROM WorkOrder
            WHERE CaseId = :ticketId AND Status != 'Canceled'
            ORDER BY CreatedDate DESC
        ];

        Set<String> ticketWorkOrderIds = new Set<String>();
        for (WorkOrder order : ticketWorkOrderList) {
            ticketWorkOrderIds.add(order.Id);
        }

        List<ProductRequest> ticketProductRequestList = [SELECT Id, Seq__c, PartsRequestDate__c, CreatedDate, WorkOrderId FROM ProductRequest WHERE WorkOrderId IN :ticketWorkOrderIds];

        Map<String, List<ProductRequest>> workOrderPRMap = new Map<String, List<ProductRequest>>();
        for (ProductRequest orderPR : ticketProductRequestList) {
            List<ProductRequest> valueList = new List<ProductRequest>();
            if (workOrderPRMap.get(orderPR.WorkOrderId) != null) valueList = workOrderPRMap.get(orderPR.WorkOrderId);
            valueList.add(orderPR);
            workOrderPRMap.put(orderPR.WorkOrderId, valueList);
        }

        List<ServiceAppointment> ticketServiceAppointmentList = [SELECT Id, OnsiteDate__c, Department__c, ParentRecordId FROM ServiceAppointment WHERE WorkerType__c = 'Service Resource (Main)' AND ParentRecordId IN :ticketWorkOrderIds ORDER BY CreatedDate DESC];

        Map<String, ServiceAppointment> ticketMainASMap = new Map<String, ServiceAppointment>();
        for (ServiceAppointment mainSA : ticketServiceAppointmentList) {
            if (ticketMainASMap.get(mainSA.ParentRecordId) == null) {
                ticketMainASMap.put(mainSA.ParentRecordId, mainSA);
            }
        }

        // String assetOrderOwnerId = caseInfo.Asset.Order__r.OwnerId;
        // User orderDealer = new User();
        // if (assetOrderOwnerId != null) {
        //     orderDealer = [SELECT Id, AccountId, Account.Name FROM User WHERE Id = :assetOrderOwnerId LIMIT 1];
        // }

        String assetModelName = caseInfo.Asset.MachineName__c;

        List<ModelManager__c> modelList = [SELECT Id, Name, toLabel(ModelCategory__c) FROM ModelManager__c WHERE Name = :assetModelName];
        
        ModelManager__c model = modelList.size() > 0 ? modelList[0] : new ModelManager__c();

        String assetId = caseInfo.AssetId;
        Date today = Date.today();
        Date installDate = caseInfo.Asset.InstallationFinish__c == null ? Date.today() : Date.valueOf(caseInfo.Asset.InstallationFinish__c);
        Decimal betweenMonth = installDate.monthsBetween(today);

        List<WorkOrder> workOrderList = [SELECT Id, CreatedDate FROM WorkOrder WHERE AssetId = :assetId];
        List<WorkOrder> betweenWorkOrderList = new List<WorkOrder>();

        for (WorkOrder wo : workOrderList) {
            if (wo.CreatedDate > installDate && wo.CreatedDate < installDate.addDays(30)) {
                betweenWorkOrderList.add(wo);
            }
        }

        Decimal averageOrder = betweenMonth > 0 ? (workOrderList.size() / betweenMonth) : workOrderList.size();

        TicketObject ticket = new TicketObject();
        ticket.ownerName = caseInfo.Owner.Name;
        ticket.requester = caseInfo.Requester__r.Name;
        ticket.isUrgency = caseInfo.IsUrgency__c;
        ticket.isReGenerate = caseInfo.IsReGenerate__c;
        ticket.severity = caseInfo.Severity__c == null ? '' : caseInfo.Severity__c;
        ticket.urgency = caseInfo.Urgency__c == null ? '' : caseInfo.Urgency__c;
        ticket.requesterPhone = caseInfo.Requester__r.MobilePhone;
        ticket.address = caseInfo.Asset.FM_Address__c;
        ticket.middleType = caseInfo.InternalTicketType__c;
        ticket.installer = caseInfo.Asset.InstEngineer__r.Name;
        ticket.installerWC = caseInfo.Asset.InstEngineer__r.Service_Territory__r.Name;
        ticket.installFinishDate = caseInfo.Asset.InstallationFinish__c == null ? '' : Date.valueOf(caseInfo.Asset.InstallationFinish__c).format();
        ticket.createdDate = caseInfo.ApplicationDateTime__c == null ? '' : Datetime.valueOf(caseInfo.ApplicationDateTime__c).format('yyyy-MM-dd a hh:mm');
        ticket.installationDefect = caseInfo.InstallationDefect__c == null ? 'N' : caseInfo.InstallationDefect__c;
        ticket.countermeasure = caseInfo.AfterResponsePlan__c;
        ticket.reservation = 'N';
        ticket.csMemberMig = caseInfo.CSMemberMig__c;
        ticket.csMemberName = caseInfo.CSMember__r.Name;
        ticket.csMemberId = caseInfo.CSMember__c;
        ticket.csDueDate = caseInfo.CSDueDate__c;
        ticket.cooperationTeam = caseInfo.CooperationTeam__c;
        ticket.cooperationPerson = caseInfo.CooperationPerson__c;
        ticket.cooperationDate = caseInfo.CooperationDate__c;
        ticket.allOrderCount = workOrderList.size();
        ticket.orderCount = betweenWorkOrderList.size();
        ticket.orderAverage = averageOrder;
        ticket.technicalReview = caseInfo.SkillCheck__c == null ? 'N' : caseInfo.SkillCheck__c;
        ticket.productCategory = model.ModelCategory__c == null ? '' : model.ModelCategory__c;
        ticket.receptionDetail = caseInfo.ReceptionDetails__c;
        // ticket.dealer = orderDealer.Account.Name == null ? '' : orderDealer.Account.Name;
        ticket.complaint = caseInfo.Complaint__c;
        ticket.pendingProcessing = caseInfo.Pendingprocessing__c;
        ticket.pendingProcessingLabel = caseInfo.PendingProcessingLabel__c;
        ticket.pendingProcessingDetail = caseInfo.PendingDetail__c;
        ticket.urgencyEquip = '';
        ticket.dealer = caseInfo.Asset.SalesAgency__c;
        ticket.workOrderCount = ticketWorkOrderList.size();

        List<Case> urgencyTicketList = [SELECT Id, ApplicationDateTime__c FROM Case WHERE AssetId = :assetId];

        if (urgencyTicketList.size() > 0) {
            List<Case> between30DaysList = new List<Case>();
            List<Case> between90DaysList = new List<Case>();
            for (Case urgencyTicket : urgencyTicketList) {
                Datetime dt = Datetime.now();
                if (urgencyTicket.ApplicationDateTime__c >= dt.addDays(-30) && urgencyTicket.ApplicationDateTime__c <= dt) {
                    between30DaysList.add(urgencyTicket);
                }

                if (urgencyTicket.ApplicationDateTime__c >= dt.addDays(-90) && urgencyTicket.ApplicationDateTime__c <= dt) {
                    between90DaysList.add(urgencyTicket);
                }
            }

            if (between30DaysList.size() > 1  &&  between90DaysList.size() > 3  && averageOrder >= 1.2) {
                ticket.urgencyEquip = '긴급';
            }
        }
        
        if (ticketWorkOrderList.size() > 0) {
            List<String> notiNumList = new List<String>();

            Map<String, String> partsCreatedDateMap = new Map<String, String>();
            Map<String, SADateWrapper> saDateMap = new Map<String, SADateWrapper>();

            for (WorkOrder wo : ticketWorkOrderList) {
                notiNumList.add(wo.ServiceOrderNumber__c);
                
                if (workOrderPRMap.get(wo.Id) != null) {
                    for (ProductRequest pr : workOrderPRMap.get(wo.Id)) {
                        // String cDate = pr.CreatedDate.format('yyyy-MM-dd');

                        String cDate = pr.PartsRequestDate__c == null ? '0000-00-00' : pr.PartsRequestDate__c.year() + '-' + pr.PartsRequestDate__c.month() + '-' + pr.PartsRequestDate__c.day();

                        partsCreatedDateMap.put(wo.ServiceOrderNumber__c + '!' + pr.Seq__c, cDate);
                    }
                }

                if (ticketMainASMap.get(wo.Id) != null) {
                    ServiceAppointment sa = ticketMainASMap.get(wo.Id);
                    SADateWrapper sadw = new SADateWrapper();
                    sadw.sDate = sa.Department__c == null ? '' : sa.Department__c.format('yyyy-MM-dd');
                    sadw.oDate = sa.OnsiteDate__c == null ? '' : sa.OnsiteDate__c.format('yyyy-MM-dd');
                    saDateMap.put(wo.ServiceOrderNumber__c, sadw);
                }
            }

            ticket.saDateMap = saDateMap;
            ticket.partsCreatedDateMap = partsCreatedDateMap;
            ticket.notiNumList = notiNumList;
            WorkOrder lastWO = ticketWorkOrderList[0];
            ticket.notiNum = lastWO.ServiceOrderNumber__c;
            ticket.reservation = 'Y';
            ticket.orderNumber = lastWO.ServiceOrderNumber__c;
            ticket.repairRequestDate = Datetime.valueOf(lastWO.FM_RepairRequestDateTime__c).format('yyyy-MM-dd a hh:mm');
            ticket.srName = lastWO.Worker__r.Name;
            ticket.srPhone = lastWO.Worker__r.PhoneNumber__c;
            ticket.srWC = lastWO.Worker__r.Service_Territory__r.Name;
            if (lastWO.worker__r.Service_Territory__r.classify__c == 'W/C') {
                ticket.srTopWC = lastWO.Worker__r.Service_Territory__r.ControlWorkcenter__r.Name;
            } else {
                ticket.srTopWC = lastWO.Worker__r.Service_Territory__r.Name;
            }
            ticket.orderSrName = lastWO.Worker__r.Name;
            ticket.repairDate = Datetime.valueOf(lastWO.FM_RepairRequestDateTime__c).format('yyyy-MM-dd a hh:mm');
            ticket.ticketDetail = lastWO.PendingOrCustomerMatters__c;

            Decimal count = getDayBetween(Date.valueOf(ticketWorkOrderList[ticketWorkOrderList.size() - 1].CreatedDate));
            
            ticket.elapsedDate = count;

            String workOrderId = lastWO.Id;

            List<ServiceAppointment> saList = [
                SELECT  Id, Pendingprocessing__c, PendingDetail__c, Department__c, Arrival__c, WorkCompletionTime__c, OnsiteDate__c
                FROM ServiceAppointment 
                WHERE ParentRecordId = :workOrderId AND WorkerType__c = 'Service Resource (Main)'
                ORDER BY createdDate DESC
            ];

            if (saList.size() > 0) {
                ticket.lastDispatchDate = saList[0].Department__c == null ? '' : Datetime.valueOf(saList[0].Department__c).format('yyyy-MM-dd a hh:mm');
                ticket.lastArrivalDate = saList[0].Arrival__c == null ? '' : Datetime.valueOf(saList[0].Arrival__c).format('yyyy-MM-dd a hh:mm');
                ticket.lastCompletionDate = saList[0].WorkCompletionTime__c == null ? '' : Datetime.valueOf(saList[0].WorkCompletionTime__c).format('yyyy-MM-dd a hh:mm');
                ticket.dispatchedDate = saList[0].OnsiteDate__c == null ? '' : saList[0].OnsiteDate__c.format('yyyy-MM-dd');
                ticket.dispatchedTime = saList[0].OnsiteDate__c == null ? '' : saList[0].OnsiteDate__c.format('a hh:mm');
                ticket.dispatchedCount = saList.size();
            }
        }

        return ticket;
    }

    // 연결된  component에서 가져온 정보로 해당 Ticket을 업데이트하는 메서드
    @AuraEnabled
    public static ResultWrapper saveTicket(String recordId, String saveObject) {

        ResultWrapper result = new ResultWrapper();

        try {

            Case updateTicket = [
                SELECT  Id, IsUrgency__c, IsReGenerate__c, Severity__c, Urgency__c, InstallationDefect__c,
                        Countermeasure__c, CSMember__c, CSDueDate__c, CooperationTeam__c, CooperationPerson__c,
                        CooperationDate__c, Complaint__c, SkillCheck__c, PendingProcessing__c, PendingDetail__c,
                        (SELECT Id, ServiceOrderNumber__c, Noti_Number__c FROM WorkOrders)
                FROM Case 
                WHERE Id = :recordId
            ];
            String memberId = updateTicket.CSMember__c;
            Map<String, Object> updateMap = (Map<String, Object>) JSON.deserializeUntyped(saveObject);

            updateTicket.IsUrgency__c = Boolean.valueOf(updateMap.get('isUrgency'));
            updateTicket.Severity__c = String.valueOf(updateMap.get('severity'));
            updateTicket.IsReGenerate__c = Boolean.valueOf(updateMap.get('isReGenerate'));
            updateTicket.Urgency__c = String.valueOf(updateMap.get('urgency'));
            if (updateTicket.InstallationDefect__c != String.valueOf(updateMap.get('installationDefect'))) {
                if (updateTicket.WorkOrders.size() > 0) {
                    Set<String> woNotiNums = new Set<String>();
                    for (WorkOrder wo : updateTicket.WorkOrders) {
                        if (wo.ServiceOrderNumber__c != null) woNotiNums.add(wo.ServiceOrderNumber__c);
                    }

                    getIF032(woNotiNums, String.valueOf(updateMap.get('installationDefect')));
                }
            }
            updateTicket.InstallationDefect__c = String.valueOf(updateMap.get('installationDefect'));
            updateTicket.AfterResponsePlan__c = String.valueOf(updateMap.get('countermeasure'));
            updateTicket.CooperationTeam__c = String.valueOf(updateMap.get('cooperationTeam'));
            updateTicket.CooperationPerson__c = String.valueOf(updateMap.get('cooperationPerson'));
            updateTicket.CSMember__c = updateMap.get('csMemberId') == '' ? null : String.valueOf(updateMap.get('csMemberId'));
            updateTicket.SkillCheck__c = String.valueOf(updateMap.get('technicalReview'));
            updateTicket.Complaint__c = String.valueOf(updateMap.get('complaint'));
            updateTicket.Pendingprocessing__c = String.valueOf(updateMap.get('pendingProcessing'));
            updateTicket.PendingProcessingLabel__c = String.valueOf(updateMap.get('pendingProcessingLabel'));
            if (updateTicket.Pendingprocessing__c  == 'Closing') {
                updateTicket.Status = 'Closed';
                updateTicket.EndOfReason__c = 'Dispatch completed';
            }
            updateTicket.PendingDetail__c = String.valueOf(updateMap.get('pendingProcessingDetail'));

            if (updateMap.get('csDueDate') == null) {
                updateTicket.CSDueDate__c = null;
            } else {
                String dueDate = String.valueOf(updateMap.get('csDueDate'));
                updateTicket.CSDueDate__c = Date.newInstance(Integer.valueOf(dueDate.split('-')[0]), Integer.valueOf(dueDate.split('-')[1]), Integer.valueOf(dueDate.split('-')[2]));
            }

            if (updateMap.get('cooperationDate') == null) {
                updateTicket.CooperationDate__c = null;
            } else {
                String dueDate = String.valueOf(updateMap.get('cooperationDate'));
                updateTicket.CooperationDate__c = Date.newInstance(Integer.valueOf(dueDate.split('-')[0]), Integer.valueOf(dueDate.split('-')[1]), Integer.valueOf(dueDate.split('-')[2]));
            }
            
            Database.SaveResult sr = Database.update(updateTicket);

            if (sr.isSuccess()) {

                String teamRoleId = [SELECT Id, Name FROM CaseTeamRole WHERE Name = 'ETC' LIMIT 1].Id;

                System.debug('memberId2 ::: ' + memberId);
                if (memberId != null) deleteTeamMember(sr.getId(), memberId, teamRoleId);

                Case caseInfo = [
                    SELECT  Id, IsUrgency__c, CSMember__c, CSMember__r.Name, CooperationDate__c, CooperationTeam__c, AfterResponsePlan__c, 
                            CooperationPerson__c, Complaint__c, SkillCheck__c, PendingProcessing__c, PendingProcessingLabel__c, PendingDetail__c
                    FROM Case 
                    WHERE Id = :sr.getId()
                ];

                if (caseInfo.CSMember__c != null) {
                    CaseTeamMember ctm = new CaseTeamMember();
                    ctm.ParentId = sr.getId();
                    ctm.MemberId = caseInfo.CSMember__c;
                    ctm.TeamRoleId = teamRoleId;

                    insert ctm;
                }
                
                TicketObject obj = new TicketObject();
                obj.csMemberId = caseInfo.CSMember__c;
                obj.csMemberName = caseInfo.CSMember__r.Name;
                obj.cooperationTeam = caseInfo.CooperationTeam__c;
                obj.cooperationPerson = caseInfo.CooperationPerson__c;
                obj.cooperationDate = caseInfo.CooperationDate__c;
                obj.urgencyEquip = caseInfo.IsUrgency__c ? '긴급' : '';
                obj.technicalReview = caseInfo.SkillCheck__c;
                obj.complaint = caseInfo.Complaint__c;
                obj.pendingProcessing = caseInfo.Pendingprocessing__c;
                obj.pendingProcessingLabel = caseInfo.PendingProcessingLabel__c;
                obj.pendingProcessingDetail = caseInfo.PendingDetail__c;
                obj.countermeasure = caseInfo.AfterResponsePlan__c;


                result.updateTicket = obj;
                result.isSuccess = true;
                result.message = 'Success';

            } else {
                result.isSuccess = false;
                result.message = 'Ticket Update Fail';
            }

            return result;
            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            result.isSuccess = false;
            result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
            return result;
        }
    }

    // 해당 Ticket의 CS담당자 변경시 기존의 CS담당자를 Case Team Member에서 제거하는 메서드
    private static void deleteTeamMember(String caseId, String memberId, String teamRoleId) {

        List<CaseTeamMember> ctmList = [SELECT Id FROM CaseTeamMember WHERE ParentId = :caseId AND MemberId = :memberId AND TeamRoleId =:teamRoleId];

        if (ctmList.size() > 0) {
            delete ctmList;
        }


    }

    // private static String formatPhoneNumber(String phoneNumber) {
    //     if (phoneNumber != null && phoneNumber.length() == 11) {
    //         // 전화번호를 "010-1234-1234" 형식으로 변환
    //         return phoneNumber.substring(0, 3) + '-' + phoneNumber.substring(3, 7) + '-' + phoneNumber.substring(7);
    //     } else {
    //         // 전화번호가 유효하지 않으면 그대로 리턴하거나 처리
    //         return '';
    //     }
    // }

    // 오늘 날짜와 Date값 사이의 일수를 계산하는 메서드
    private static Decimal getDayBetween(Date calculDate) {
        Date today = Date.today();

        Decimal daysBetween = calculDate.daysBetween(today);

        return daysBetween;
    }

    // field Name으로 픽리스트 필드의 값들을 가져오는 메서드
    private static List<Object> getPicklistfield(String fieldName) {
        // Schema.DescribeSObjectResult schemaReady        = Schema.getGlobalDescribe().get('Case').getDescribe();
        // Map<String, Schema.SObjectField> schemaFieldMap = schemaReady.fields.getMap();

        Schema.sObjectField token           = schemaFieldMap.get(fieldName);
        List<Schema.PicklistEntry> Entries  = token.getDescribe().getPicklistValues();

        List<Object> picklist = new List<Object>();

        if (fieldName != 'InstallationDefect__c' && fieldName != 'SkillCheck__c') {
            Map<String, String> obj = new Map<String, String>();
            obj.put('label', '--None--');
            obj.put('value', '');
            picklist.add(obj);
        }

        for (Schema.PicklistEntry entry : Entries) {
            Map<String, String> obj = new Map<String, String>();
            obj.put('label', entry.getLabel());
            obj.put('value', entry.getValue());
            picklist.add(obj);
        }

        return picklist;
    }

    // 진행사항관리의 전체리스트 모달의 Init에 필요한 정보를 component에 전달하는 메서드
    @AuraEnabled
    public static Map<String, Object> getListviewModalInit() {

        Map<String, Object> result = new Map<String, Object>();

        try {

            result.put('getListviewPicklist', getListviewPicklist());
            result.put('getListviewWorkcenters', getListviewWorkcenters());


            
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    // 전체리스트 모달의 지사, Work Center의 검색 조건을 Picklist화 하기위한 메서드
    private static Map<String, List<PicklistWrapper>> getListviewWorkcenters() {

        Map<String, List<PicklistWrapper>> result = new Map<String, List<PicklistWrapper>>();

        List<ServiceTerritory> workcenterList = [SELECT Id, classify__c, Name FROM ServiceTerritory WHERE PlanningPlant__c = '184S' AND IsActive = true];
        Set<String> stNameSet = new Set<String>();
        Map<String, ServiceTerritory> stMap = new Map<String, ServiceTerritory>();
        for (ServiceTerritory st : workcenterList) {
            stNameSet.add(st.Name);
            stMap.put(st.Name, st);
        }

        List<String> stNameList = new List<String>(stNameSet);
        stNameList.sort();

        List<PicklistWrapper> topWorkcenterOption = new List<PicklistWrapper>();
        List<PicklistWrapper> workcenterOption = new List<PicklistWrapper>();

        PicklistWrapper firstObj = new PicklistWrapper();
        firstObj.label = '== 선택 ==';
        firstObj.value = '';
        topWorkcenterOption.add(firstObj);
        workcenterOption.add(firstObj);

        for (String name : stNameList) {
            ServiceTerritory wc = stMap.get(name);
            PicklistWrapper obj = new PicklistWrapper();
            if (wc.classify__c == '지사' || wc.classify__c == 'POST') {
                obj.label = wc.Name;
                obj.value = wc.Id;
                topWorkcenterOption.add(obj);
            } else if (wc.classify__c == 'W/C') {
                obj.label = wc.Name;
                obj.value = wc.Id;
                workcenterOption.add(obj);
            }
        }

        result.put('topWorkcenterOption', topWorkcenterOption);
        result.put('workcenterOption', workcenterOption);

        return result;
    }
    
    // 전체리스트 모달의 미결사유의 검색조건을 Picklist화 하기위한 메서드
    private static List<Object> getListviewPicklist() {

        Schema.sObjectField token           = schemaFieldMap.get('Pendingprocessing__c');
        List<Schema.PicklistEntry> Entries  = token.getDescribe().getPicklistValues();

        List<Object> picklist = new List<Object>();

        Map<String, String> firstObj = new Map<String, String>();
        firstObj.put('label', 'All');
        firstObj.put('value', '');
        picklist.add(firstObj);

        for (Schema.PicklistEntry entry : Entries) {
            Map<String, String> obj = new Map<String, String>();
            obj.put('label', entry.getLabel());
            obj.put('value', entry.getValue());
            picklist.add(obj);
        }

        return picklist;
    }

    // 전체리스트 모달에서 입력한 검색조건으로 필터링해서 정보를 담는 메서드 1 (검색량이 많아서 2개의 메서드로 분리)
    @AuraEnabled
    public static List<WorkOrder> searchData(String jsonString){

        Map<String, String> filterMap = (Map<String, String>) JSON.deserialize(jsonString, Map<String, String>.class);

        List<WorkOrder> orderList = new List<WorkOrder>();

        try {
            // Ticket
            Datetime startDate = Datetime.valueOf(filterMap.get('listviewStart') + ' 00:00:00');
            Datetime endDate = Datetime.valueOf(filterMap.get('listviewEnd') + ' 23:59:59');
            String pendingProcessing = filterMap.get('listviewPenddingvalue');
            String instDefect = filterMap.get('listviewInstDefectValue');
            String technicalReview = filterMap.get('listviewTechnicalReviewValue');
            String warrantyPath = filterMap.get('listviewWarrantyValue');
            String ticketStatus = filterMap.get('listviewTicketCompleValue');

            // Order
            String orderNumber = filterMap.get('listviewOrderNumber');
            String orderStatus = filterMap.get('listviewCompleValue');
            String workcenterId = filterMap.get('listviewWorkcenterValue');
            String topWorkcenterId = filterMap.get('listviewTopWorkcenterValue');

            String orderQuery = 'SELECT Id, CaseId, AssetId, Asset.InstallationFinish__c, FM_RepairRequestDateTime__c, CreatedDate, ServiceTerritory.ControlWorkcenter__r.Name, ServiceTerritory.classify__c, InspectionDetails__c, ';
            orderQuery += 'ServiceTerritory.Name, Worker__r.FM_ServiceWorkCenter__c, TimeAgreedOnSite__c, Worker__r.Name, ScheduledDispatchTime__c, toLabel(Status), ServiceOrderNumber__c, PendingOrCustomerMatters__c, ';
            orderQuery += '(SELECT Id FROM ServiceAppointments WHERE WorkerType__c = \'Service Resource (Main)\')';
            orderQuery += ' FROM WorkOrder WHERE PMActivityType__c = \'CS02\' AND Case.RecordType.DeveloperName = \'Ticket_Domestic\' AND Case.ApplicationDateTime__c >= :startDate AND Case.ApplicationDateTime__c <= :endDate';
            if (orderNumber != '') orderQuery += ' AND ServiceOrderNumber__c = :orderNumber';
            if (orderStatus != '') {
                if (orderStatus == '종결') {
                    orderQuery += ' AND (Status = \'Confirm\' OR Status = \'Completed\' OR Status = \'Canceled\')';
                } else if (orderStatus == '미결') {
                    orderQuery += ' AND (Status != \'Confirm\' AND Status != \'Completed\' AND Status != \'Canceled\')';
                }
            }
            if (workcenterId != '') orderQuery += ' AND ServiceTerritoryId = :workcenterId';
            if (topWorkcenterId != '') {
                orderQuery += ' AND (ServiceTerritory.ControlWorkcenter__c = :topWorkcenterId OR ServiceTerritoryId = :topWorkcenterId)';
            }

            if (pendingProcessing != '') orderQuery += ' AND Case.Pendingprocessing__c = :pendingProcessing';
            if (instDefect != '') orderQuery += ' AND Case.InstallationDefect__c = :instDefect';
            if (technicalReview != '') orderQuery += ' AND Case.SkillCheck__c = :technicalReview';

            if (warrantyPath != '') {
                orderQuery += ' AND Case.ReceptionPath__c = :warrantyPath';
            }
            // else {
            //     orderQuery += ' AND Case.ReceptionPath__c IN (\'Call Center(Representative)\', \'Dealer portal\')';
            // }

            if (ticketStatus != '') {
                if (ticketStatus == '종결') {
                    orderQuery += ' AND (Case.Status = \'Closed\' OR Case.Status = \'Reject\')';
                } else if (ticketStatus == '미결') {
                    orderQuery += 'AND (Case.Status != \'Closed\' AND Case.Status != \'Reject\')';
                }
            }

            orderQuery += ' ORDER BY Case.ApplicationDateTime__c, Case.CaseNumber';
            // orderQuery += ' LIMIT 50000';
            System.debug('orderQuery ::: ' + orderQuery);

            orderList = Database.query(orderQuery);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return orderList;
    }

    // 전체리스트 모달에서 입력한 검색조건으로 필터링해서 정보를 담는 메서드 2 (검색량이 많아서 2개의 메서드로 분리)
    @AuraEnabled
    public static ListviewResultWrapper searchData2(List<WorkOrder> orderList) {
        // System.debug('jsonString ::: ' + jsonString);
        // Map<String, String> filterMap = (Map<String, String>) JSON.deserialize(jsonString, Map<String, String>.class);

        ListviewResultWrapper result = new ListviewResultWrapper();

        try {

            Set<String> assetIds = new Set<String>();
            Set<String> orderIds = new Set<String>();
            Set<String> ticketIds = new Set<String>();
            if (Test.isRunningTest()) {
                Asset testAsset = [SELECT Id FROM Asset LIMIT 1];
                WorkOrder testServiceOrder = [SELECT Id, CaseId, AssetId, Asset.InstallationFinish__c, FM_RepairRequestDateTime__c, CreatedDate, ServiceTerritory.ControlWorkcenter__r.Name, InspectionDetails__c, ServiceTerritory.Name, Worker__r.FM_ServiceWorkCenter__c, TimeAgreedOnSite__c, Worker__r.Name, ScheduledDispatchTime__c, Status, ServiceOrderNumber__c, (SELECT Id FROM ServiceAppointments WHERE WorkerType__c = 'Service Resource (Main)') FROM WorkOrder LIMIT 1];
                assetIds.add(testAsset.Id);
                orderIds.add(testServiceOrder.Id);
                ticketIds.add(testServiceOrder.CaseId);
                orderList.add(testServiceOrder);
            }
            if (orderList.size() > 0) {
                for (WorkOrder order : orderList) {
                    // List<WorkOrder> valueList = new List<WorkOrder>();
                    // if (orderMap.get(order.CaseId) != null) valueList = orderMap.get(order.CaseId);
                    // valueList.add(order);
                    // orderMap.put(order.CaseId, valueList);
                    assetIds.add(order.AssetId);
                    orderIds.add(order.Id);
                    ticketIds.add(order.CaseId);
                }
            }

            String ticketQuery = 'SELECT Id, toLabel(Status), IsUrgency__c, IsReGenerate__c, Severity__c, Asset.FM_SalesRep__c, Asset.InstEngineer__r.Name, CaseNumber, Asset.MachineName__c, Asset.Name, Asset.NCType__c, Asset.StartUpDate__c, Asset.InstallationFinish__c, Asset.WarrantyStartDateWages__c, Asset.WorkCenter__r.Name,';
            ticketQuery += 'ApplicationDateTime__c, Owner.Name, toLabel(Pendingprocessing__c), ReceptionDetails__c, Countermeasure__c, AfterResponsePlan__c, Asset.InstWorkCenter__r.Name, Urgency__c, Complaint__c, CooperationTeam__c, CooperationPerson__c, CooperationDate__c, Asset.SalesAgency__c, ';
            ticketQuery += 'CSMember__r.Name, CSDueDate__c, AssetId, Account.Name';
            ticketQuery += ' FROM Case WHERE Id IN :ticketIds';

            System.debug('ticketQuery ::: ' + ticketQuery);
            System.debug('!!!!!!!!');

            List<Case> ticketList = Database.query(ticketQuery);
            Map<String, Case> ticketMap = new Map<String, Case>();
            System.debug('@@ ticketList.size()' + ticketList.size());
            if (ticketList.size() > 0) {
                for (Case ticket : ticketList) {
                    ticketMap.put(ticket.Id, ticket);
                }
            }

            List<WorkOrder> assetOrderList = [SELECT Id, AssetId, Asset.InstallationFinish__c, CreatedDate FROM WorkOrder WHERE AssetId IN :assetIds];

            Map<String, List<WorkOrder>> assetOrderMap = new Map<String, List<WorkOrder>>();
            Map<String, List<WorkOrder>> asset30DaysOrderMap = new Map<String, List<WorkOrder>>();
            Map<String, List<WorkOrder>> asset90DaysOrderMap = new Map<String, List<WorkOrder>>();
            if (assetOrderList.size() > 0) {
                for (WorkOrder order : assetOrderList) {
                    List<WorkOrder> valueList = new List<WorkOrder>();
                    if (assetOrderMap.get(order.AssetId) != null) valueList = assetOrderMap.get(order.AssetId);
                    valueList.add(order);
                    assetOrderMap.put(order.AssetId, valueList);

                    //최근 30일이내 클레임 2건이상
                    if (order.Asset.InstallationFinish__c != null && order.CreatedDate >= order.Asset.InstallationFinish__c && order.CreatedDate <= order.Asset.InstallationFinish__c.addDays(30)) {
                        List<WorkOrder> value30DayList = new List<WorkOrder>();
                        if (asset30DaysOrderMap.get(order.AssetId) != null) value30DayList = asset30DaysOrderMap.get(order.AssetId);
                        value30DayList.add(order);
                        asset30DaysOrderMap.put(order.AssetId, value30DayList);
                    }

                    //최근 90일이내 클레임 4건이상
                    if (order.Asset.InstallationFinish__c != null && order.CreatedDate >= order.Asset.InstallationFinish__c && order.CreatedDate <= order.Asset.InstallationFinish__c.addDays(90)) {
                        List<WorkOrder> value90DayList = new List<WorkOrder>();
                        if (asset90DaysOrderMap.get(order.AssetId) != null) value90DayList = asset90DaysOrderMap.get(order.AssetId);
                        value90DayList.add(order);
                        asset90DaysOrderMap.put(order.AssetId, value90DayList);
                    }
                }
            }

            List<ProductRequest> prList = [SELECT Id, ProgressStatus__c, PRETD__c, WorkOrderId FROM ProductRequest WHERE WorkOrderId IN :orderIds];

            Map<String, List<ProductRequest>> prMap = new Map<String, List<ProductRequest>>();
            if (prList.size() > 0) {
                for (ProductRequest pr : prList) {
                    List<ProductRequest> valueList = new List<ProductRequest>();
                    if (prMap.get(pr.WorkOrderId) != null) valueList = prMap.get(pr.WorkOrderId);
                    valueList.add(pr);
                    prMap.put(pr.WorkOrderId, valueList);
                }
            }

            Map<String, ProductRequest> orderPrMap = new Map<String, ProductRequest>();
            for (String key : prMap.keySet()) {
                Integer value = 4;
                for (ProductRequest pr : prMap.get(key)) {
                    if (pr.ProgressStatus__c != null && pr.ProgressStatus__c != '') {
                        Integer currentValue;
                        switch on pr.ProgressStatus__c {
                            when '확보 중' {
                                currentValue = 1;
                            }
                            when '재고보유' {
                                currentValue = 2;
                            }
                            when '포장완료' {
                                currentValue = 3;
                            }
                            when '배송완료' {
                                currentValue = 4;
                            }
                        }
                        if (currentValue <= value) {
                            value = currentValue;
                            orderPrMap.put(pr.WorkOrderId, pr);
                        }
                    }
                }
            }

            List<ServiceAppointment> saList = [
                SELECT  Id, toLabel(Pendingprocessing__c), PendingDetail__c, Department__c, Arrival__c, WorkCompletionTime__c, OnsiteDate__c, WorkOrder__c, WorkerType__c, ServiceResource__r.Name
                FROM ServiceAppointment 
                WHERE WorkOrder__c IN :orderIds
                ORDER BY createdDate DESC
            ];

            Map<String, List<ServiceAppointment>> mainSAListMap = new Map<String, List<ServiceAppointment>>();
            Map<String, List<ServiceAppointment>> subSAListMap = new Map<String, List<ServiceAppointment>>();
            Map<String, ServiceAppointment> mainSAMap = new Map<String, ServiceAppointment>();
            Map<String, ServiceAppointment> subSAMap = new Map<String, ServiceAppointment>();

            for (ServiceAppointment sa : saList) {
                List<ServiceAppointment> valueList = new List<ServiceAppointment>();
                if (sa.WorkerType__c == 'Service Resource (Main)') {
                    if (mainSAListMap.get(sa.WorkOrder__c) != null) valueList = mainSAListMap.get(sa.WorkOrder__c);
                    valueList.add(sa);
                    mainSAListMap.put(sa.WorkOrder__c, valueList);
                } else if (sa.WorkerType__c == 'Service Resource (Sub)') {
                    if (subSAListMap.get(sa.WorkOrder__c) != null) valueList = subSAListMap.get(sa.WorkOrder__c);
                    valueList.add(sa);
                    subSAListMap.put(sa.WorkOrder__c, valueList);
                }
            }

            for (String key : mainSAListMap.keySet()) {
                List<ServiceAppointment> mainSAList = mainSAListMap.get(key);
                if (mainSAList.size() > 1) {
                    ServiceAppointment sa = mainSAList[1];
                    mainSAMap.put(sa.WorkOrder__c, sa);
                } else {
                    ServiceAppointment sa = mainSAList[0];
                    mainSAMap.put(sa.WorkOrder__c, sa);
                }
            }

            for (String key : subSAListMap.keySet()) {
                ServiceAppointment sa = subSAListMap.get(key)[0];
                subSAMap.put(sa.WorkOrder__c, sa);
            }

            // for (ServiceAppointment sa : saList) {
            //     if (sa.WorkerType__c == 'Service Resource (Main)') {
            //         if (mainSAMap.get(sa.WorkOrder__c) == null) {
            //             mainSAMap.put(sa.WorkOrder__c, sa);
            //         }
            //     } else if (sa.WorkerType__c == 'Service Resource (Sub)') {
            //         if (subSAMap.get(sa.WorkOrder__c) == null) {
            //             subSAMap.put(sa.WorkOrder__c, sa);
            //         }
            //     }
            // }

            List<Case> urgencyTicketList = [SELECT Id, ApplicationDateTime__c, AssetId FROM Case WHERE AssetId IN :assetIds ORDER BY ApplicationDateTime__c DESC];
            Map<String, List<Case>> assetCaseMap = new Map<String, List<Case>>();
            if (urgencyTicketList.size() > 0) {
                for (Case ticket : urgencyTicketList) {
                    List<Case> valueList = new List<Case>();
                    if (assetCaseMap.get(ticket.AssetId) != null) valueList = assetCaseMap.get(ticket.AssetId);
                    valueList.add(ticket);
                    assetCaseMap.put(ticket.AssetId, valueList);
                }
            }

            Map<String, String> urgencyAssetMap = new Map<String, String>();
            for (String key : assetCaseMap.keySet()) {
                List<Case> between30DaysList = new List<Case>();
                List<Case> between90DaysList = new List<Case>();
                for (Case urgencyTicket : assetCaseMap.get(key)) {
                    Datetime dt = Datetime.now();
                    //최근 30일이내 클레임
                    if (urgencyTicket.ApplicationDateTime__c >= dt.addDays(-30) && urgencyTicket.ApplicationDateTime__c <= dt) {
                        between30DaysList.add(urgencyTicket);
                    }
    
                    //최근 90일이내 클레임
                    if (urgencyTicket.ApplicationDateTime__c >= dt.addDays(-90) && urgencyTicket.ApplicationDateTime__c <= dt) {
                        between90DaysList.add(urgencyTicket);
                    }
                }
    
                //월평균 클레임 
                if (between30DaysList.size() > 1 && between90DaysList.size() > 3) {
                    urgencyAssetMap.put(key, 'Y');
                }
            }

            if (orderList.size() > 0) {
                for (WorkOrder order : orderList) {
                    Case ticket = ticketMap.get(order.CaseId);
                    System.debug('ticketMap : ' + ticket.ApplicationDateTime__c);
                    ListviewLineItem lineItem = new ListviewLineItem();
                    lineItem.ticketStatus = ticket.Status;
                    lineItem.urgencyNY = ticket.IsUrgency__c ? 'Y' : 'N';
                    lineItem.reGenerateNY = ticket.IsReGenerate__c ? 'Y' : 'N';
                    lineItem.severity = ticket.Severity__c == null ? '' : ticket.Severity__c;
                    lineItem.urgency = ticket.Urgency__c == null ? '' : ticket.Urgency__c;
                    lineItem.elapsedDate = String.valueOf(getDayBetween(Date.valueOf(ticket.ApplicationDateTime__c)));
                    // lineItem.topWorkcenterName = order.ServiceTerritory.classify__c == 'W/C' ? order.ServiceTerritory.ControlWorkcenter__r.Name : order.ServiceTerritory.Name;
                    lineItem.topWorkcenterName = ticket.Asset.WorkCenter__r.Name;
                    lineItem.workcenterName = order.ServiceTerritory.Name;
                    lineItem.dealerName = ticket.Asset.SalesAgency__c;
                    lineItem.installer = ticket.Asset.InstEngineer__r.Name;
                    lineItem.ticketNumber = order.ServiceOrderNumber__c;
                    lineItem.srWC = ticket.Account.Name;
                    lineItem.assetModelName = ticket.Asset.MachineName__c;
                    lineItem.assetName = ticket.Asset.Name;
                    lineItem.assetNcType = ticket.Asset.NCType__c;
                    lineItem.assetStartUpDate = ticket.Asset.StartUpDate__c == null ? '' : convertDateString(ticket.Asset.StartUpDate__c);
                    lineItem.installFinishDate = ticket.Asset.InstallationFinish__c == null ? '' : convertDateString(ticket.Asset.InstallationFinish__c);
                    lineItem.createdDate = ticket.ApplicationDateTime__c == null ? '' : ticket.ApplicationDateTime__c.format('yyyy-MM-dd');
                    lineItem.ownerName = ticket.Owner.Name;
                    lineItem.lastDispatchDate = mainSAMap.get(order.Id) == null ? '' : mainSAMap.get(order.Id).Department__c == null ? '' : mainSAMap.get(order.Id).Department__c.format('yyyy-MM-dd');
                    lineItem.reservationNY = order.TimeAgreedOnSite__c == null ? 'N' : 'Y';
                    lineItem.pendingProcessing = ticket.Pendingprocessing__c == null ? '인원' : ticket.Pendingprocessing__c;
                    lineItem.receptionDetail = ticket.ReceptionDetails__c;
                    // System.debug('order.InspectionDetails__c ::: ' + order.InspectionDetails__c);
                    lineItem.ticketDetail = order.PendingOrCustomerMatters__c;
                    lineItem.countermeasure = ticket.AfterResponsePlan__c;
                    lineItem.assetInstallWC = ticket.Asset.InstWorkCenter__r.Name == null ? '' : ticket.Asset.InstWorkCenter__r.Name;
                    lineItem.collaboWorkerName = subSAMap.get(order.Id) == null ? '' : subSAMap.get(order.Id).ServiceResource__r.Name;
                    
                    // 출동계획
                    lineItem.srName = order.Worker__r.Name;
                    lineItem.repairRequestDate = order.ScheduledDispatchTime__c == null ? '' : Datetime.valueOf(order.ScheduledDispatchTime__c).format('yyyy-MM-dd a hh:mm');

                    // 미결하자관리
                    lineItem.orderStatus = order.Status;
                    lineItem.pendingStatus = mainSAMap.get(order.Id) == null ? '인원' : mainSAMap.get(order.Id).Pendingprocessing__c == null ? '인원' : mainSAMap.get(order.Id).Pendingprocessing__c;
                    lineItem.complaint = ticket.Complaint__c;
                    // lineItem.dispatchedCount = String.valueOf(order.ServiceAppointments.size());
                    lineItem.dispatchedCount = mainSAListMap.get(order.Id) == null ? '0' : String.valueOf(mainSAListMap.get(order.Id).size());
                    
                    // CS
                    lineItem.csMemberName = ticket.CSMember__r.Name;
                    lineItem.csDueDate = ticket.CSDueDate__c == null ? '' : convertDateString(ticket.CSDueDate__c);
                    
                    // 협조부서
                    lineItem.cooperationTeam = ticket.CooperationTeam__c;
                    lineItem.cooperationPerson = ticket.CooperationPerson__c;
                    lineItem.cooperationDate = ticket.CooperationDate__c == null ? '' : convertDateString(ticket.CooperationDate__c);
                    
                    // 부품
                    lineItem.partState = orderPrMap.get(order.Id) == null ? '' : orderPrMap.get(order.Id).ProgressStatus__c;
                    lineItem.supplyDate = orderPrMap.get(order.Id) == null ? '' : (orderPrMap.get(order.Id).PRETD__c == null ? '' : convertDateString(orderPrMap.get(order.Id).PRETD__c));
                    
                    // 수리
                    lineItem.orderSrName = order.Worker__r.Name;
                    lineItem.repairDate = Datetime.valueOf(order.FM_RepairRequestDateTime__c).format('yyyy-MM-dd a hh:mm');
                    
                    // 장비기준 오더현황
                    lineItem.assetInstElapsedDate = ticket.Asset.InstallationFinish__c == null ? ticket.Asset.WarrantyStartDateWages__c == null ? '' : getBetweenInstallAfterDays(ticket.Asset.WarrantyStartDateWages__c) : getBetweenInstallAfterDays(ticket.Asset.InstallationFinish__c);
                    lineItem.allOrderCount = assetOrderMap.get(order.AssetId) == null ? '0' : String.valueOf(assetOrderMap.get(order.AssetId).size());
                    lineItem.orderCount30 = asset30DaysOrderMap.get(order.AssetId) == null ? '0' : String.valueOf(asset30DaysOrderMap.get(order.AssetId).size());
                    lineItem.orderCount90 = asset90DaysOrderMap.get(order.AssetId) == null ? '0' : String.valueOf(asset90DaysOrderMap.get(order.AssetId).size());
                    Decimal betweenMonth = ticket.Asset.InstallationFinish__c == null ? 0 : ticket.Asset.InstallationFinish__c.monthsBetween(Date.today());
                    Decimal averageOrder = betweenMonth > 0 ? (assetOrderMap.get(order.AssetId) == null ? 0 : (assetOrderMap.get(order.AssetId).size() / betweenMonth)) : (assetOrderMap.get(order.AssetId) == null ? 0 : assetOrderMap.get(order.AssetId).size());
                    //String urgencyEquipYN = 'N';
                    String urgencyEquipYN = '';

                    // if (urgencyAssetMap.get(order.AssetId) != null) {
                    //     if (urgencyAssetMap.get(order.AssetId) == 'Y') {
                    //         if (averageOrder >= 1.2) {
                    //             urgencyEquipYN = 'Y';
                    //         }
                    //     }
                    // }
                    
                    Boolean isOrderCount30 = Integer.valueOf(lineItem.orderCount30) >= 2;
                    Boolean isOrderCount90 = Integer.valueOf(lineItem.orderCount90) >= 4;
                    Boolean isAverageOrder = averageOrder >= 1.2;
                    
                    if (isOrderCount30 && isOrderCount90 && isAverageOrder) {
                        urgencyEquipYN = 'Y';
                        //System.debug('@@urgencyEquipYN :' + urgencyEquipYN);
                    }else{
                        urgencyEquipYN = 'N';
                    }

                    // lineItem.urgencyEquip = urgencyAssetMap.get(order.AssetId) == null ? 'N' : urgencyAssetMap.get(order.AssetId);
                    lineItem.orderAverage = String.valueOf(averageOrder);
                    lineItem.urgencyEquip = urgencyEquipYN;

                    if (lineItem.pendingProcessing != '종결' && lineItem.lastDispatchDate == '' && lineItem.reservationNY == 'N') {
                        lineItem.isYellow = true;
                    } else if (order.ScheduledDispatchTime__c != null && Date.valueOf(order.ScheduledDispatchTime__c) > Date.today() && (order.Status == 'New' || order.Status == 'Assigned')) {
                        lineItem.isYellow = true;
                    }

                    if (lineItem.lastDispatchDate == '' && (lineItem.ticketDetail == '' || lineItem.ticketDetail == null) && Date.valueOf(order.ScheduledDispatchTime__c) < Date.today()) {
                        lineItem.isRed = true;
                    } else if (lineItem.lastDispatchDate == '' && Date.valueOf(order.ScheduledDispatchTime__c) > Date.today()) {
                        lineItem.isRed = true;
                    } else if (lineItem.lastDispatchDate == '' && order.ScheduledDispatchTime__c == null) {
                        lineItem.isRed = true;
                    }

                    result.resultList.add(lineItem);

                }
                // for (Case ticket : ticketList) { 
                //     if (orderMap.get(ticket.Id) != null) {
                //     }
                // }
            }
            
        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
            result.isSuccess = false;
            result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
            result.resultList = new List<ListviewLineItem>();
        }

        return result;
    }

    // 해당 Ticket의 모든 Service Order의 부품진행 테이블을 위해 Interface로 가져오는 메서드
    @AuraEnabled
    public static Object getIF007(String notiNum) {

        IF_ERP_Material_Classes.IF_CSPLUS_007_Req req = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req();

        List<IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2> t_i_list2_list = new List<IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2>();
        IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2 t_i_list2 = new IF_ERP_Material_Classes.IF_CSPLUS_007_Req_T_I_LIST2();
        t_i_list2.SIGN = 'I';
        t_i_list2.OPTION = 'EQ';
        t_i_list2.LOW = notiNum;

        t_i_list2_list.add(t_i_list2);

        req.T_I_LIST2 = t_i_list2_list;
     
        IF_ERP_Material instance = new IF_ERP_Material();
        IF_ERP_Material_Classes.IF_CSPLUS_007_Res response = instance.IF_CSPLUS_007(req);
        System.debug('response007 ::: ' + response);

        return response;
    }

    // 해당 Ticket의 모든 Service Order의 부품확보 테이블을 위해 Interface로 가져오는 메서드 1 (getIF033과 합쳐서 진행)
    @AuraEnabled
    public static Map<String, Object> getIF008(String notiNum) {

        IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req req = new IF_ERP_Receipt_Classes.IF_CSPLUS_008_Req();
        req.I_ORDER_NO = notiNum;
     
        IF_ERP_Receipt instance = new IF_ERP_Receipt();
        IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res response = instance.IF_CSPLUS_008(req);
        System.debug('response008 ::: ' + response);

        Map<String, Object> responseMap = new Map<String, Object>();

        if (response.O_RETURN.TYPE == 'S') {
            for (IF_ERP_Receipt_Classes.IF_CSPLUS_008_Res_T_O_LIST obj : response.T_O_LIST) {
                System.debug('obj ::: ' + obj);
                System.debug('obj.QMNUM ::: ' + obj.QMNUM);
                System.debug('obj.QMSEQ ::: ' + obj.QMSEQ);

                responseMap.put(obj.QMNUM + '!' + obj.QMSEQ, obj);
            }
        }

        return responseMap;
    }

    // 해당 Ticket의 모든 Service Order의 부품확보 테이블을 위해 Interface로 가져오는 메서드 1 (getIF008과 합쳐서 진행)
    @AuraEnabled
    public static Object getIF033(String notiNum) {
        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req req = new IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req();
        List<IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR> reqItemList = new List<IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR>();
        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR reqItem = new IF_ERP_Receipt_Classes.IF_CSPLUS_033_Req_T_I_AUFNR();
        reqItem.LOW = notiNum;

        reqItemList.add(reqItem);

        req.T_I_AUFNR = reqItemList;

        IF_ERP_Receipt instance = new IF_ERP_Receipt();
        IF_ERP_Receipt_Classes.IF_CSPLUS_033_Res response = instance.IF_CSPLUS_033(req);
        System.debug('response033 ::: ' + response);

        return response;
    }

    // 해당 Ticket의 설치하자 Y,N을 Interface로 전송하는 메서드
    // @AuraEnabled
    public static void getIF032(Set<String> notiNumList, String InstallDefect) {
        System.debug('notiNumList032 ::: ' + notiNumList);
        List<IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req> reqList = new List<IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req>();

        for (String notiNum : notiNumList) {
            IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req req = new IF_ERP_Receipt_Classes.IF_CSPLUS_032_Req();
            req.I_AUFNR = notiNum;
            req.I_IPLBM = InstallDefect;
            reqList.add(req);
        }
    
        IF_ERP_Receipt instance = new IF_ERP_Receipt();
        List<IF_ERP_Receipt_Classes.IF_CSPLUS_032_Res> response = instance.IF_CSPLUS_032(reqList);

        System.debug('response032 ::: ' + response);

        // return response;
    }

    // Date값을 yyyy-MM-dd의 String 형태로 변경하는 메서드
    private static String convertDateString(Date requestDate) {

        String year = String.valueOf(requestDate.year());
        String month = String.valueOf(requestDate.month()).leftPad(2, '0');
        String day = String.valueOf(requestDate.day()).leftPad(2, '0');

        String dateString = year + '-' + month + '-' + day;

        return dateString;
    }

    // 설치완료일과 현재 날짜의 경과일을 계산하는 메서드
    private static String getBetweenInstallAfterDays(Date installDate) {

        Date today = Date.today();

        String daysBetween = String.valueOf(installDate.daysBetween(today));

        return daysBetween;
    }

    public class TicketObject {
        
        // 접수내용
        @AuraEnabled public String  ownerName               { get; set;} // 상담원
        @AuraEnabled public String  requester               { get; set;} // 신청자

        @AuraEnabled public Boolean isUrgency               { get; set;} // 긴급/ 독촉
        @AuraEnabled public Boolean isReGenerate            { get; set;} // 재발생

        @AuraEnabled public String  severity                { get; set;} // 심각도
        @AuraEnabled public String  urgency                 { get; set;} // 긴급도

        @AuraEnabled public String  srTopWC                 { get; set;} // 지사 (출동자)
        @AuraEnabled public String  orderNumber             { get; set;} // 오더번호
        
        @AuraEnabled public String  srName                  { get; set;} // 출동자
        @AuraEnabled public String  srPhone                 { get; set;} // 출동자 연락처
        @AuraEnabled public String  srWC                    { get; set;} // 업체명(출동자 W/C)

        @AuraEnabled public String  requesterPhone          { get; set;} // 연락처(신청자)
        @AuraEnabled public String  address                 { get; set;} // 위치

        @AuraEnabled public String  middleType              { get; set;} // 하자유형
        @AuraEnabled public String  installationDefect      { get; set;} // 설치하자

        @AuraEnabled public String  installer               { get; set;} // 설치자
        @AuraEnabled public String  installerWC             { get; set;} // 설치자소속

        @AuraEnabled public String  installFinishDate       { get; set;} // 설치완료일
        @AuraEnabled public String  technicalReview         { get; set;} // 기술검토

        @AuraEnabled public String  pendingProcessing       { get; set;} // 종결미결원인
        @AuraEnabled public String  pendingProcessingLabel  { get; set;} // 종결미결원인 라벨
        @AuraEnabled public String  pendingProcessingDetail { get; set;} // 미결내용

        @AuraEnabled public String  reservation             { get; set;} // 예약상태 (Y/N)
        @AuraEnabled public String  lastDispatchDate        { get; set;} // 최종출동일시 

        @AuraEnabled public String  lastArrivalDate         { get; set;} // 최종도착일시
        @AuraEnabled public String  lastCompletionDate      { get; set;} // 최종완료일시

        @AuraEnabled public String  dealer                  { get; set;} // 판매대리점
        @AuraEnabled public String  productCategory         { get; set;} // 기종군

        @AuraEnabled public String  createdDate             { get; set;} // 접수일시
        @AuraEnabled public String  receptionDetail         { get; set;} // 고장내용(상담)
        
        @AuraEnabled public String  ticketDetail            { get; set;} // 조치/수리내용
        @AuraEnabled public String  countermeasure          { get; set;} // 향후대응방안


        // 오더현황
        @AuraEnabled public String  partState               { get; set;} // 부품상태
        @AuraEnabled public String  supplyDate              { get; set;} // 공급예정일

        @AuraEnabled public String  orderSrName             { get; set;} // 수리담당자 (출동자)
        @AuraEnabled public String  repairDate              { get; set;} // 수리예정일

        @AuraEnabled public String  dispatchedDate          { get; set;} // 출발예정일
        @AuraEnabled public String  dispatchedTime          { get; set;} // 출발예정시간

        @AuraEnabled public Decimal allOrderCount           { get; set;} // 전체오더건수
        @AuraEnabled public Decimal orderCount              { get; set;} // 오더건수(30일)

        @AuraEnabled public Decimal orderAverage            { get; set;} // 오더평균
        @AuraEnabled public String  urgencyEquip            { get; set;} // 긴급대응장비


        // 미결관리
        @AuraEnabled public Decimal dispatchedCount         { get; set;} // 출동횟수
        @AuraEnabled public Decimal elapsedDate             { get; set;} // 경과일

        @AuraEnabled public String  complaint               { get; set;} // 고객불만/요구사항


        // CS
        @AuraEnabled public String  csMemberMig            { get; set;} // 담당자 UserName (마이그레이션용)
        @AuraEnabled public String  csMemberName            { get; set;} // 담당자 UserName
        @AuraEnabled public String  csMemberId              { get; set;} // 담당자 UserId
        @AuraEnabled public Date    csDueDate               { get; set;} // 처리기한


        // 협조부서
        @AuraEnabled public String  cooperationTeam         { get; set;} // 팀
        @AuraEnabled public String  cooperationPerson       { get; set;} // 담당자

        @AuraEnabled public Date    cooperationDate         { get; set;} // 처리기한
        

        // 출동계획
        @AuraEnabled public String  repairRequestDate       { get; set;} // 수리요청일시

        // etc
        @AuraEnabled public String          notiNum                 { get; set;} // Noti Number
        @AuraEnabled public List<String>    notiNumList             { get; set;} // Noti Number List
        @AuraEnabled public Map<String, String> partsCreatedDateMap { get; set;}
        @AuraEnabled public Map<String, SADateWrapper> saDateMap    { get; set;}
        @AuraEnabled public Integer workOrderCount                  { get; set;}

        public TicketObject() {
            this.severity = '';
            this.urgency = '';
            this.pendingProcessing = '';
            this.pendingProcessingLabel = '';
            this.workOrderCount = 0;
            this.notiNumList = new List<String>();
        }
    }

    public class ListviewLineItem {
        @AuraEnabled public String ticketStatus { get; set;} // Ticket 상태
        @AuraEnabled public String urgencyNY { get; set;} // 긴급/독촉
        @AuraEnabled public String reGenerateNY { get; set;} // 재발생
        @AuraEnabled public String severity { get; set;} // 심각도
        @AuraEnabled public String urgency { get; set;} // 긴급도
        @AuraEnabled public String elapsedDate { get; set;} // 경과일
        @AuraEnabled public String topWorkcenterName { get; set;} // 지사
        @AuraEnabled public String workcenterName { get; set;} // 서비스W/C
        @AuraEnabled public String dealerName { get; set;} // 판매자
        @AuraEnabled public String installer { get; set;} // 설치자
        @AuraEnabled public String ticketNumber { get; set;} // 접수번호
        @AuraEnabled public String srWC { get; set;} // 업체명
        @AuraEnabled public String assetModelName { get; set;} // 기종
        @AuraEnabled public String assetName { get; set;} // 호기
        @AuraEnabled public String assetNcType { get; set;} // 제어장치
        @AuraEnabled public String assetStartUpDate { get; set;} // 출하일
        @AuraEnabled public String installFinishDate { get; set;} // 설치완료일
        @AuraEnabled public String createdDate { get; set;} // 접수일
        @AuraEnabled public String ownerName { get; set;} // 상담원
        @AuraEnabled public String lastDispatchDate { get; set;} // 출동일
        @AuraEnabled public String reservationNY { get; set;} // 예약상태
        @AuraEnabled public String pendingProcessing { get; set;} // 종결미결원인
        @AuraEnabled public String receptionDetail { get; set;} // 고장내용(상담)
        @AuraEnabled public String ticketDetail { get; set;} // 수리내용
        @AuraEnabled public String countermeasure { get; set;} // 향후대응방안
        @AuraEnabled public String assetInstallWC { get; set;} // 설치W/C
        @AuraEnabled public String collaboWorkerName { get; set;} // 공동작업자

        // 출동계획
        @AuraEnabled public String srName { get; set;} // 출동자
        @AuraEnabled public String srPhone { get; set;} // 출동자
        @AuraEnabled public String repairRequestDate { get; set;} // 출동예정일

        // 미결하자관리
        @AuraEnabled public String orderStatus { get; set;} // 상태
        @AuraEnabled public String pendingStatus { get; set;} // 미결사유
        @AuraEnabled public String complaint { get; set;} // 고객불만
        @AuraEnabled public String dispatchedCount { get; set;} // 출동횟수

        // CS
        @AuraEnabled public String csMemberName { get; set;} // 담당자
        @AuraEnabled public String csDueDate { get; set;} // 처리기한

        // 협조부서
        @AuraEnabled public String cooperationTeam { get; set;} // 팀
        @AuraEnabled public String cooperationPerson { get; set;} // 담당자
        @AuraEnabled public String cooperationDate { get; set;} // 처리기한

        // 부품
        @AuraEnabled public String partState { get; set;} // 상태
        @AuraEnabled public String supplyDate { get; set;} // 공급예정일/출고일자

        // 수리
        @AuraEnabled public String orderSrName { get; set;} // 담당자
        @AuraEnabled public String repairDate { get; set;} // 수리요청일

        // 장비기준 오더현황
        @AuraEnabled public String assetInstElapsedDate { get; set;} // 설치경과일
        @AuraEnabled public String allOrderCount { get; set;} // 전체오더건수
        @AuraEnabled public String orderCount30 { get; set;} // 오더건수(30일)
        @AuraEnabled public String orderCount90 { get; set;} // 오더건수(90일)
        @AuraEnabled public String orderAverage { get; set;} // 오더평균
        @AuraEnabled public String urgencyEquip { get; set;} // 긴급대응장비
        
        // 컬러링
        @AuraEnabled public Boolean isYellow { get; set;} // 노란 행
        @AuraEnabled public Boolean isRed { get; set;} // 빨간 셀


        public ListviewLineItem() {
            this.isYellow = false;
            this.isRed = false;
        }
    }

    public class ResultWrapper {
        @AuraEnabled public String          message         { get; set;}
        @AuraEnabled public Boolean         isSuccess       { get; set;}
        @AuraEnabled public TicketObject    updateTicket    { get; set;}

        public ResultWrapper() {}
    }

    public class ListviewResultWrapper {
        @AuraEnabled public String                  message     { get; set;}
        @AuraEnabled public Boolean                 isSuccess   { get; set;}
        @AuraEnabled public List<ListviewLineItem>  resultList  { get; set;}

        public ListviewResultWrapper() {
            this.message = '';
            this.isSuccess = true;
            this.resultList = new List<ListviewLineItem>();
        }
    }

    public class SADateWrapper {
        @AuraEnabled public String          sDate         { get; set;}
        @AuraEnabled public String          oDate         { get; set;}

        public SADateWrapper() {}
    }

    public class PicklistWrapper {
        @AuraEnabled public String label    { get; set; }
        @AuraEnabled public String value    { get; set; }

        public PicklistWrapper() {
            this.label = '';
            this.value = '';
        }
    }

}