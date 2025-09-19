/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-24-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class DN_ServiceHistoryReportController {
    
    /**
     * @Description
     * 	- 장비번호로 장비 Like 검색
     * @author Hayeong Min 
     * @Parameter
     *  - modelSearchVal    : Search Key
    **/
    @AuraEnabled
    public static Commonwrapper getEquipmentList(String modelSearchVal){
        Commonwrapper cw = new Commonwrapper();
        String query = 'SELECT Id, Name, MachineName__c FROM Asset WHERE Name Like \'%' + modelSearchVal + '%\'';
        List<Asset> equipList = Database.query(query);
        if(equipList.size()>0){
            cw.returnList = equipList;
        }
        return cw;
    }

    /**
     * @Description
     * 	- 기종으로 장비 Like 검색
     * @author Hayeong Min 
     * @Parameter
     *  - modelTypeSearchVal    : Search Key
    **/
    @AuraEnabled
    public static Commonwrapper getTypeList(String modelTypeSearchVal){
        Commonwrapper cw = new Commonwrapper();
        String query = 'SELECT Id, Name, ModelCode__c FROM ModelManager__c WHERE Name Like \'%' + modelTypeSearchVal + '%\'';
        List<ModelManager__c> modelList = Database.query(query);
        if(modelList.size()>0){
            cw.returnList = modelList;
        }
        return cw;
    }

    /**
     * @Description
     * 	- W/C, 관할지사, 상태 Picklist 형태로 Mapping
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static Commonwrapper getSettingInfo(){
        Commonwrapper cw = new Commonwrapper();
        try {

            Map<String, String> allMap = new Map<String, String>();
            allMap.put('label', '전체');
            allMap.put('value', '');

            // W/C 목록
            List<ServiceTerritory> stList = [SELECT Id, Name FROM ServiceTerritory WHERE Branch__c = 'DNS' ORDER BY Name];
            List<Map<String, String>> wcList = new List<Map<String, String>>();
            
            wcList.add(allMap);
            for (ServiceTerritory st : stList) {
                Map<String, String> wcMap = new Map<String, String>();
                wcMap.put('label', st.Name);
                wcMap.put('value', st.Id);
                wcList.add(wcMap);
            }
            cw.workcenter = wcList;

            // 관할지사 목록
            List<ServiceTerritory> stList2 = [SELECT Id, Name FROM ServiceTerritory WHERE Branch__c = 'DNS' AND classify__c IN ('지사' ,'POST') ORDER BY Name];
            List<Map<String, String>> branchList = new List<Map<String, String>>();
            
            branchList.add(allMap);
            for (ServiceTerritory st : stList2) {
                Map<String, String> branchMap = new Map<String, String>();
                branchMap.put('label', st.Name);
                branchMap.put('value', st.Id);
                branchList.add(branchMap);
            }
            cw.branch = branchList;

            //상태 목록
            List<Map<String, String>> statusList = new List<Map<String, String>>();
            Schema.DescribeFieldResult fieldResult = WorkOrder.Status.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            statusList.add(allMap);
            for (Schema.PicklistEntry entry : picklistValues) {
                Map<String, String> statusMap = new Map<String, String>();
                statusMap.put('label', entry.getLabel()); 
                statusMap.put('value', entry.getValue()); 
                statusList.add(statusMap);
            }
            cw.status = statusList;

        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getLineNumber() +'__'+ e.getMessage();
        }
        return cw;
    }


    /**
     * @Description
     * 	- 하자접수이력 List 조회
     * @author Hayeong Min 
     * @Parameter
     *  - conditionData    : 조회 조건 String
    **/
    @AuraEnabled
    public static Commonwrapper getServiceHistoryList(String conditionData){
        Commonwrapper cw = new Commonwrapper();
        try{
            List<WorkOrder> woList = checkCondition(conditionData);
            List<ResultWrapper> rwList = new List<ResultWrapper>();
        
            if(woList.size()>0){
                WoWrapper ww = seperateMigData(woList);
                //Migration DATA
                // if(ww.beforeList.size()>0){
                //     Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>();
                //     List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Department__c, Arrival__c, WorkCompletionTime__c, 
                //                                         DepartmentReport__c, ArrivalReport__c, WorkCompletionTimeMobile__c, CreatedDate 
                //                                         FROM ServiceAppointment 
                //                                         WHERE ParentRecordId IN : ww.beforeSet AND WorkerType__c = 'Service Resource (Main)'
                //                                         ORDER BY Department__c NULLS LAST];
                //     if(saList.size()>0){
                //         for(ServiceAppointment sa : saList){
                //             if(!saMap.containsKey(sa.ParentRecordId)){
                //                 saMap.put(sa.ParentRecordId, sa);
                //             }
                //         }
                //     }

                //     //Migration DATA의 경우, 
                //     //출발, 도착 Service Report Field WorkType__c = 'MV'인 가장 먼저 시작하는 WorkOrderResult
                //     List<WorkOrderResult__c> mvList = [SELECT ID, WorkOrder__c, WorkDate__c, WorkStartTime__c, WorkEndTime__c, WorkType__c 
                //                                         FROM WorkOrderResult__c 
                //                                         WHERE WorkOrder__c IN : ww.beforeSet AND ResultType__C = 'WH' 
                //                                         AND (WorkType__c = 'MV')
                //                                         ORDER BY WorkOrder__c, WorkDate__c, WorkStartTime__c NULLS LAST];
                //     Map<ID, WorkOrderResult__c> mvMap = new Map<Id, WorkOrderResult__c>();
                //     if(mvList.size()>0){
                //         for(WorkOrderResult__c wr : mvList){
                //             if(!mvMap.containsKey(wr.WorkOrder__c)){
                //                 mvMap.put(wr.WorkOrder__c, wr);
                //             }
                //         }
                //     }
                    
                //     System.debug('@@ mvMap : ' + mvMap);

                //     //작업완료일자 Service Report Field는 WorkType__c != 'MV' 가장 마지막 WorkOrderResult
                //     List<WorkOrderResult__c> wrList = [SELECT ID, WorkOrder__c, WorkDate__c, WorkStartTime__c, WorkEndTime__c, WorkType__c 
                //                                         FROM WorkOrderResult__c 
                //                                         WHERE WorkOrder__c IN : ww.beforeSet AND ResultType__C = 'WH' 
                //                                         AND (WorkType__c ='WK' OR WorkType__c = 'DN')
                //                                         ORDER BY WorkOrder__c, WorkDate__c DESC, WorkEndTime__c DESC NULLS LAST];
                //     Map<Id, WorkOrderResult__c> wrMap = new Map<Id, WorkOrderResult__c>();
                //     if(wrList.size()>0){
                //         for(WorkOrderResult__c wr : wrList){
                //             if(!wrMap.containsKey(wr.WorkOrder__c)){
                //                 wrMap.put(wr.WorkOrder__c, wr);
                //             }
                //         }
                //     }

                //     System.debug('@@ wrMap : ' + wrMap);
                //     //공동작업자 묶기
                //     Map<Id, String> colMap = getCollaboData(ww.beforeSet);

                //     //부품 청구
                //     Map<Id, String> prMap = getProductData(ww.beforeSet);

                //     //공통 작업결과
                //     Map<Id, WorkOrderResult__c> commonMap = getCommonData(ww.beforeSet);

                //     //표준 작업결과
                //     Map<Id, List<WorkOrderResult__c>> standardMap = getStandardWorkData(ww.beforeSet);



                //     //Wrapper에 넣기
                //     for(WorkOrder wo : ww.beforeList){
                //         ResultWrapper rw = new ResultWrapper();

                //         //Work Order Fields
                //         rw.orderNum = wo.ServiceOrderNumber__c;
                //         rw.pmType = wo.OrderType__c;
                //         //workcenter가 지사/post면 관할지사에 해당 지사 넣어주기
                //         if(wo.ServiceTerritory.classify__c == 'W/C'){
                //             rw.branch = wo.ServiceTerritory.ControlWorkcenter__r.Name;
                //         }else{
                //             rw.branch = wo.ServiceTerritory.Name;
                //         }
                //         rw.workcenter = wo.ServiceTerritory.Name;
                //         rw.resourceName = wo.Worker__r.Name;
                //         rw.model = wo.Asset.MachineName__c;
                //         rw.serialNum = wo.Asset.Name;
                //         if(wo.Asset.StartUpDate__c != null){
                //             rw.shippingDate = String.valueOf(wo.Asset.StartUpDate__c);
                //         }
                //         rw.account = wo.Account.Name;
                //         rw.address = wo.Account.FM_Address__c;
                //         if(String.isNotEmpty(wo.Account.Phone)){
                //             rw.phone = wo.Account.Phone;
                //         }
                //         if(String.isNotEmpty(wo.Case.TicketType__c)){
                //             rw.ticketTypeMajor = wo.Case.TicketType__c;
                //         }
                //         if(String.isNotEmpty(wo.Case.InternalTicketType__c)){
                //             rw.ticketTypeMiddle = wo.Case.InternalTicketType__c;
                //         }
                //         if(String.isNotEmpty(wo.ReceptionDetail__c)){
                //             rw.receptionDetail = wo.ReceptionDetail__c;
                //         }
                //         if(String.isNotEmpty(wo.FailureArea__c)){
                //             rw.failureAreaMajor = wo.FailureArea__c;
                //         }
                //         if(String.isNotEmpty(wo.FailureAreaGroup__c)){
                //             rw.failureAreaMiddle = wo.FailureAreaGroup__c;
                //         }
                //         if(String.isNotEmpty(wo.FailurePhenomenon__c)){
                //             rw.failurePhenomenon = wo.FailurePhenomenon__c;
                //         }
                                                
                //         if(wo.FM_ApplicationDateTime__c != null) {
                //             rw.receptionDate = String.valueOf(wo.FM_ApplicationDateTime__c.date());
                //             rw.receptionTime = String.valueOf(wo.FM_ApplicationDateTime__c.format('HH:mm:ss'));
                //         }
                        
                //         //Service Order 생성일자 Migration DATA는 ScheduledDispatchTime__c
                //         if(wo.ScheduledDispatchTime__c != null){
                //             rw.orderCreatedDate = String.valueOf(wo.ScheduledDispatchTime__c.date());
                //             rw.orderCreatedTime = String.valueOf(wo.ScheduledDispatchTime__c.format('HH:mm:ss'));
                //         }

                //         // 고객구매날짜
                //         if(wo.TimeAgreedOnSite__c != null){
                //             rw.timeAgreedOnSiteDate = String.valueOf(wo.TimeAgreedOnSite__c.format('yyyy-MM-dd'));
                //         }

                //         // 고객구매시간
                //         if(wo.TimeAgreedOnSite__c != null){
                //             rw.timeAgreedOnSiteTime = String.valueOf(wo.TimeAgreedOnSite__c.format('HH:mm:ss'));
                //         }

                //         rw.receptionist = wo.Owner.Name;
                        
                //         if(String.isNotEmpty(wo.PendingOrCustomerMatters__c)){
                //             rw.inspectionDetail = wo.PendingOrCustomerMatters__c;
                //         }

                //         rw.status = wo.Status;

                //         if(wo.ConfirmedDate__c != null){
                //             rw.portal_completetDate = String.valueOf(wo.ConfirmedDate__c.date());
                //             rw.portal_completetTime = String.valueOf(wo.ConfirmedDate__c.format('HH:mm:ss'));
                //         }

                //         //Service Appointment Fields
                //         if(saMap.containsKey(wo.Id)){
                //             System.debug('@@ saMap.get(wo.Id).Department__c :' + saMap.get(wo.Id).Department__c);
                //             if(saMap.get(wo.Id).Department__c != null){
                //                 rw.mobile_departureDate = String.valueOf(saMap.get(wo.Id).Department__c.date());
                //                 rw.mobile_departureTime = String.valueOf(saMap.get(wo.Id).Department__c.format('HH:mm:ss'));

                //                 //2시간 내 출동
                //                 if(wo.FM_ApplicationDateTime__c != null){
                //                     Long between = (saMap.get(wo.Id).Department__c.getTime() - wo.FM_ApplicationDateTime__c.getTime()) / (60 * 1000);
                //                     rw.in2Hour = between <= 120 ? 'Y' : 'N';
                //                 }
                //             }

                //             System.debug('@@ saMap.get(wo.Id).Arrival__c :' + saMap.get(wo.Id).Arrival__c);
                //             if(saMap.get(wo.Id).Arrival__c != null && wo.FM_ApplicationDateTime__c != null){
                //                 Long between = (saMap.get(wo.Id).Arrival__c.getTime() - wo.FM_ApplicationDateTime__c.getTime()) / (60 * 1000);
                //                 rw.in24Hour = between <= 1440 ? 'Y' : 'N';
                //             }

                //             System.debug('@@ saMap.get(wo.Id).WorkCompletionTime__c :' + saMap.get(wo.Id).WorkCompletionTime__c);
                //             if(saMap.get(wo.Id).WorkCompletionTime__c!= null){
                //                 rw.mobile_completeDate = String.valueOf(saMap.get(wo.Id).WorkCompletionTime__c.date());
                //                 rw.mobile_completeTime = String.valueOf(saMap.get(wo.Id).WorkCompletionTime__c.format('HH:mm:ss'));
                //             }
                //         }

                //         //Work Order Result Fields
                //         if(mvMap.containsKey(wo.Id)){
                //             System.debug('@@ mvMap.get(wo.Id).WorkDate__c : ' + mvMap.get(wo.Id).WorkDate__c);
                //             if(mvMap.get(wo.Id).WorkDate__c != null){
                //                 rw.serviceReport_departureDate = String.valueOf(mvMap.get(wo.Id).WorkDate__c);
                //                 rw.serviceReport_arrivalDate = String.valueOf(mvMap.get(wo.Id).WorkDate__c);
                //             }

                //             System.debug('@@ mvMap.get(wo.Id).WorkStartTime__c : ' + mvMap.get(wo.Id).WorkStartTime__c);
                //             if(mvMap.get(wo.Id).WorkStartTime__c != null){
                //                 Time departureTime = mvMap.get(wo.Id).WorkStartTime__c;
                //                 rw.serviceReport_departureTime = (departureTime.hour() < 10 ? '0' : '') + departureTime.hour() + ':' +
                //                                                 (departureTime.minute() < 10 ? '0' : '') + departureTime.minute() + ':' +
                //                                                 (departureTime.second() < 10 ? '0' : '') + departureTime.second();
                //             }

                //             System.debug('@@ mvMap.get(wo.Id).WorkEndTime__c : ' + mvMap.get(wo.Id).WorkEndTime__c);
                //             if(mvMap.get(wo.Id).WorkEndTime__c != null){
                //                 Time arrivalTime = mvMap.get(wo.Id).WorkEndTime__c;
                //                 rw.serviceReport_arrivalTime = (arrivalTime.hour() < 10 ? '0' : '') + arrivalTime.hour() + ':' +
                //                                                 (arrivalTime.minute() < 10 ? '0' : '') + arrivalTime.minute() + ':' +
                //                                                 (arrivalTime.second() < 10 ? '0' : '') + arrivalTime.second();
                //             }
                //         }
                        
                //         if(wrMap.containsKey(wo.Id)){
                //             System.debug('@@ wrMap.get(wo.Id).WorkDate__c :' + wrMap.get(wo.Id).WorkDate__c);
                //             if(wrMap.get(wo.Id).WorkDate__c != null){
                //                 rw.serviceReport_completeDate = String.valueOf(wrMap.get(wo.Id).WorkDate__c);
                //             }

                //             System.debug('@@ wrMap.get(wo.Id).WorkEndTime__c : ' + wrMap.get(wo.Id).WorkEndTime__c);
                //             if(wrMap.get(wo.Id).WorkEndTime__c != null){
                //                 Time completeTime = wrMap.get(wo.Id).WorkEndTime__c;
                //                 rw.serviceReport_completeTime = (completeTime.hour() < 10 ? '0' : '') + completeTime.hour() + ':' +
                //                                                 (completeTime.minute() < 10 ? '0' : '') + completeTime.minute() + ':' +
                //                                                 (completeTime.second() < 10 ? '0' : '') + completeTime.second();
                //             }  
                //         }

                //         //ResultType = COM 인 WorkOrderResult
                //         if(commonMap.containsKey(wo.Id)){
                //             WorkOrderResult__c commonInfo = commonMap.get(wo.Id);
                //             if(commonInfo.TotalWork__c != null){
                //                 rw.totalMH = String.valueOf(commonInfo.TotalWork__c);//작업 M/H
                //             }
                //             if(commonInfo.TotalStandardWork__c != null){
                //                 rw.standardMH = String.valueOf(commonInfo.TotalStandardWork__c);//포준공수 M/H
                //             }
                //             if(commonInfo.OverReason__c != null){
                //                 rw.overReason = commonInfo.OverReason__c;//초과 사유
                //             }
                //         }

                //         //ResultType = SWT 인 WorkOrderResult
                //         if(standardMap.containsKey(wo.Id)){
                //             List<WorkOrderResult__c> standardInfo = standardMap.get(wo.Id);
                //             for(WorkOrderResult__c st : standardInfo){
                //                 if(st.StandardWorkForce__c != null){
                //                     rw.standardCnt += st.StandardWorkForce__c;
                //                     rw.standardCnt += '/';
                //                 }
                //                 if(st.StandardWorkItem__c != null){
                //                     rw.standardWork += st.StandardWorkItem__c;
                //                     rw.standardWork += '/';
                //                 }
                //             }
                            
                //             if(rw.standardCnt.right(1) == '/'){
                //                 rw.standardCnt = rw.standardCnt.substring(0, rw.standardCnt.length() - 1);
                //             }
                //             if(rw.standardWork.right(1) == '/'){
                //                 rw.standardWork = rw.standardWork.substring(0, rw.standardWork.length() - 1);
                //             }
                //         }
                        
                //         //청구여부
                //         if(prMap.containsKey(wo.Id)) rw.isBilled = prMap.get(wo.Id);
                //         //공동작업자
                //         if(colMap.containsKey(wo.Id)) rw.collaborator = colMap.get(wo.Id);

                //         rwList.add(rw);
                //     }
                // }

                
                //Production DATA
                if(ww.afterList.size()>0){
                    System.debug('@@@ ww.afterSet : ' + ww.afterSet);
                    Map<Id, AggregateResult> saMap = new Map<Id, AggregateResult>();
                    Map<Id, AggregateResult> wkMap = new Map<Id, AggregateResult>();
                    // List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, Department__c, Arrival__c, WorkCompletionTime__c, 
                    //                                     DepartmentReport__c, ArrivalReport__c, WorkCompletionTimeMobile__c, CreatedDate 
                    //                                     FROM ServiceAppointment 
                    //                                     WHERE ParentRecordId IN : ww.afterSet AND WorkerType__c = 'Service Resource (Main)'
                    //                                     ORDER BY Department__c NULLS LAST, CreatedDate];
                    // if(saList.size()>0){
                    //     for(ServiceAppointment sa : saList){
                    //         if(!saMap.containsKey(sa.ParentRecordId)){
                    //             saMap.put(sa.ParentRecordId, sa);
                    //         }
                    //     }
                    //     System.debug('@@@ saMap : ' + saMap);
                    // }

                    //=====================================================================================================
                    List<AggregateResult> worList = [SELECT WorkOrder__c, WorkType__c, MIN(FM_StartDateTime__c) ReportStartDateTime__c, MIN(FM_EndDateTime__c) ReportEndDateTime__c, 
                                                        MIN(ServiceAppointment__r.Department__c) MobileStartDateTime__c, MIN(ServiceAppointment__r.Arrival__c) MobileEndDateTime__c
                                                        FROM WorkOrderResult__c 
                                                        WHERE WorkOrder__c IN :ww.afterSet AND WorkType__c = 'MV'
                                                        GROUP BY WorkOrder__c , WorkType__c];
                    System.debug('@@@ worList.size() : ' + worList.size());

                    if(worList.size()>0){
                        for(AggregateResult sa : worList){
                            if(!saMap.containsKey((Id) sa.get('WorkOrder__c'))){
                                saMap.put((Id) sa.get('WorkOrder__c') , sa);
                            }
                        }
                        System.debug('@@@ saMap : ' + saMap);
                    }

                    List<AggregateResult> wkList = [SELECT WorkOrder__c, WorkType__c, MAX(FM_EndDateTime__c) ReportWorkEndDateTime__c,
                                                        MAX(ServiceAppointment__r.WorkCompletionTime__c) MobileWorkEndDateTime__c
                                                        FROM WorkOrderResult__c 
                                                        WHERE WorkOrder__c IN :ww.afterSet AND (WorkType__c = 'WK' OR WorkType__c = 'DN')
                                                        GROUP BY WorkOrder__c , WorkType__c];
                    if(wkList.size()>0){
                        for(AggregateResult wk : wkList){
                            if(!wkMap.containsKey((Id) wk.get('WorkOrder__c'))){
                                wkMap.put((Id) wk.get('WorkOrder__c') , wk);
                            }
                        }
                        System.debug('@@@ wkMap : ' + wkMap);
                    }
                    
                    //=====================================================================================================
                    //공동작업자 묶기
                    Map<Id, String> colMap = getCollaboData(ww.afterSet);

                    //부품 청구
                    Map<Id, String> prMap = getProductData(ww.afterSet);

                    //공통 작업결과
                    Map<Id, WorkOrderResult__c> commonMap = getCommonData(ww.afterSet);

                    //표준 작업결과
                    Map<Id, List<WorkOrderResult__c>> standardMap = getStandardWorkData(ww.afterSet);

                    //Wrapper에 넣기
                    for(WorkOrder wo : ww.afterList){
                        ResultWrapper rw = new ResultWrapper();

                        if (wo.ExpectedDepartureTime__c != null) {
                            rw.scheduledDispatchTime = String.valueOf(wo.ExpectedDepartureTime__c);
                        }
                        //Work Order Fields
                        rw.orderNum = wo.ServiceOrderNumber__c;
                        rw.pmType = wo.OrderType__c;
                        //workcenter가 지사/post면 관할지사에 해당 지사 넣어주기
                        if(wo.ServiceTerritory.classify__c == 'W/C'){
                            rw.branch = wo.ServiceTerritory.ControlWorkcenter__r.Name;
                        }else{
                            rw.branch = wo.ServiceTerritory.Name;
                        }
                        rw.workcenter = wo.ServiceTerritory.Name;
                        rw.resourceName = wo.Worker__r.Name;
                        rw.model = wo.Asset.MachineName__c;
                        rw.serialNum = wo.Asset.Name;
                        if(wo.Asset.StartUpDate__c != null){
                            rw.shippingDate = String.valueOf(wo.Asset.StartUpDate__c);
                        }
                        rw.account = wo.Account.Name;
                        rw.address = wo.Account.FM_Address__c;
                        if(String.isNotEmpty(wo.Account.Phone)){
                            rw.phone = wo.Account.Phone;
                        }
                        if(String.isNotEmpty(wo.Case.TicketType__c)){
                            rw.ticketTypeMajor = wo.Case.TicketType__c;
                        }
                        if(String.isNotEmpty(wo.Case.InternalTicketType__c)){
                            rw.ticketTypeMiddle = wo.Case.InternalTicketType__c;
                        }
                        if(String.isNotEmpty(wo.ReceptionDetail__c)){
                            rw.receptionDetail = wo.ReceptionDetail__c;
                        }

                        if(String.isNotEmpty(wo.FailureArea__c)){
                            rw.failureAreaMajor = wo.FailureArea__c;
                        }
                        if(String.isNotEmpty(wo.FailureAreaGroup__c)){
                            rw.failureAreaMiddle = wo.FailureAreaGroup__c;
                        }
                        if(String.isNotEmpty(wo.FailurePhenomenon__c)){
                            rw.failurePhenomenon = wo.FailurePhenomenon__c;
                        }
                                                
                        if(wo.FM_ApplicationDateTime__c != null) {
                            rw.receptionDate = String.valueOf(wo.FM_ApplicationDateTime__c.date());
                            rw.receptionTime = String.valueOf(wo.FM_ApplicationDateTime__c.format('HH:mm:ss'));
                        }
                        
                        //Service Order 생성일자 Production DATA는 CreatedDate
                        if (wo.ScheduledDispatchTime__c != null) {
                            rw.orderCreatedDate = wo.isMigration__c ? String.valueOf(wo.ScheduledDispatchTime__c.date()) : String.valueOf(wo.CreatedDate.date());
                            rw.orderCreatedTime =  wo.isMigration__c ? String.valueOf(wo.ScheduledDispatchTime__c.format('HH:mm:ss')) : String.valueOf(wo.CreatedDate.format('HH:mm:ss'));
                        } else {
                            rw.orderCreatedDate = String.valueOf(wo.CreatedDate.date());
                            rw.orderCreatedTime = String.valueOf(wo.CreatedDate.format('HH:mm:ss'));
                        }

                        // 고객구매날짜
                        if(wo.TimeAgreedOnSite__c != null){
                            rw.timeAgreedOnSiteDate = String.valueOf(wo.TimeAgreedOnSite__c.format('yyyy-MM-dd'));
                        }

                        // 고객구매시간
                        if(wo.TimeAgreedOnSite__c != null){
                            rw.timeAgreedOnSiteTime = String.valueOf(wo.TimeAgreedOnSite__c.format('HH:mm:ss'));
                        }
                        
                        rw.receptionist = wo.Owner.Name;
                        
                        if(String.isNotEmpty(wo.PendingOrCustomerMatters__c)){
                            rw.inspectionDetail = wo.PendingOrCustomerMatters__c;
                        }

                        rw.status = wo.Status;

                        if(wo.ConfirmedDate__c != null){
                            rw.portal_completetDate = String.valueOf(wo.ConfirmedDate__c.date());
                            rw.portal_completetTime = String.valueOf(wo.ConfirmedDate__c.format('HH:mm:ss'));
                        }

                        // Service Appointment Fields
                        if(saMap.containsKey(wo.Id)){
                            // System.debug('@@@ saMap.get(wo.Id).Department__c ' + saMap.get(wo.Id).MobileStartDateTime__c);
                            Datetime start;
                            Datetime dt;
                            Datetime startTime;
                            Datetime endTime;
                            Long betweenMinutes;
                            String dtString;
                            System.debug('MobileStartDateTime__c : ' +saMap.get(wo.Id).get('MobileStartDateTime__c'));
                            if(saMap.get(wo.Id).get('MobileStartDateTime__c') != null){
                                // rw.mobile_departureDate = String.valueOf(saMap.get(wo.Id).MobileStartDateTime__c.date());
                                dt = (Datetime)saMap.get(wo.Id).get('MobileStartDateTime__c'); 
                                dtString = String.valueOf(dt);
                                
                                rw.mobile_departureDate = dtString.substring(0, 10);  
                                rw.mobile_departureTime = dtString.substring(11, 19);  

                                //2시간 내 출동
                                if(wo.FM_ApplicationDateTime__c != null && wo.FM_ApplicationDateTime__c != null){
                                    // Long between = (saMap.get(wo.Id).Department__c.getTime() - wo.FM_ApplicationDateTime__c.getTime()) / (60 * 1000);
                                    // Long between = ((Datetime)saMap.get(wo.Id).get('MobileStartDateTime__c').getTime() - (Datetime)saMap.get(wo.Id).get('MobileStartDateTime__c').getTime()) / (60 * 1000);
                                    startTime = (Datetime)saMap.get(wo.Id).get('MobileStartDateTime__c');
                                    endTime   = (Datetime)wo.FM_ApplicationDateTime__c;

                                    betweenMinutes = endTime.getTime() - startTime.getTime();
                                    System.debug('분 차이: ' + betweenMinutes);
                                    rw.in2Hour = betweenMinutes <= 120 ? 'Y' : 'N';
                                }
                            }

                            System.debug('@@@ saMap.get(wo.Id).MobileEndDateTime__c : ' + saMap.get(wo.Id).get('MobileEndDateTime__c'));
                            if(saMap.get(wo.Id).get('MobileEndDateTime__c') != null && wo.FM_ApplicationDateTime__c != null){
                                dt = (Datetime)saMap.get(wo.Id).get('MobileEndDateTime__c'); 
                                dtString = String.valueOf(dt);

                                // Long between = (saMap.get(wo.Id).MobileEndDateTime__c.getTime() - wo.FM_ApplicationDateTime__c.getTime()) / (60 * 1000);
                                // Long between = ((Datetime)saMap.get(wo.Id).get('MobileEndDateTime__c').getTime() - (Datetime)saMap.get(wo.Id).get('MobileEndDateTime__c')) / (60 * 1000);
                                startTime = (Datetime)saMap.get(wo.Id).get('MobileStartDateTime__c');
                                endTime   = (Datetime)wo.FM_ApplicationDateTime__c;

                                betweenMinutes = endTime.getTime() - startTime.getTime();
                                System.debug('분 차이: ' + betweenMinutes);
                                rw.in24Hour = betweenMinutes <= 1440 ? 'Y' : 'N';
                            }

                            System.debug('@@@ saMap.get(wo.Id).ReportStartDateTime__c :' + saMap.get(wo.Id).get('ReportStartDateTime__c'));
                            if(saMap.get(wo.Id).get('ReportStartDateTime__c')!= null){
                                dt = (Datetime)saMap.get(wo.Id).get('ReportStartDateTime__c'); 
                                dtString = String.valueOf(dt);

                                rw.serviceReport_departureDate = dtString.substring(0, 10);  
                                rw.serviceReport_departureTime = dtString.substring(11, 19);  
                            }

                            System.debug('@@@ saMap.get(wo.Id).ReportEndDateTime__c :' + saMap.get(wo.Id).get('ReportEndDateTime__c'));
                            if(saMap.get(wo.Id).get('ReportEndDateTime__c')!= null){
                                dt = (Datetime)saMap.get(wo.Id).get('ReportEndDateTime__c'); 
                                dtString = String.valueOf(dt);
                                
                                rw.serviceReport_arrivalDate = dtString.substring(0, 10);  
                                rw.serviceReport_arrivalTime = dtString.substring(11, 19); 
                            }

                            if(wkMap.containsKey(wo.Id)){
                                System.debug('@@@ wkMap.get(wo.Id).MobileWorkEndDateTime__c : ' + wkMap.get(wo.Id).get('MobileWorkEndDateTime__c'));
                                if(wkMap.get(wo.Id).get('MobileWorkEndDateTime__c')!= null){
                                    dt = (Datetime)wkMap.get(wo.Id).get('MobileWorkEndDateTime__c'); 
                                    dtString = String.valueOf(dt);

                                    rw.mobile_completeDate = dtString.substring(0, 10);  
                                    rw.mobile_completeTime = dtString.substring(11, 19);  
                                }

                                System.debug('@@@ saMap.get(wo.Id).ReportWorkEndDateTime__c : ' + wkMap.get(wo.Id).get('ReportWorkEndDateTime__c'));
                                if(wkMap.get(wo.Id).get('ReportWorkEndDateTime__c') != null){
                                    dt = (Datetime)wkMap.get(wo.Id).get('ReportWorkEndDateTime__c'); 
                                    dtString = String.valueOf(dt);
    
                                    rw.serviceReport_completeDate = dtString.substring(0, 10);  
                                    rw.serviceReport_completeTime = dtString.substring(11, 19); 
                                }
                            }
                        }

                        //ResultType = COM 인 WorkOrderResult
                        if(commonMap.containsKey(wo.Id)){
                            WorkOrderResult__c commonInfo = commonMap.get(wo.Id);
                            if(commonInfo.TotalWork__c != null){
                                rw.totalMH = String.valueOf(commonInfo.TotalWork__c);//작업 M/H
                            }
                            if(commonInfo.TotalStandardWork__c != null){
                                rw.standardMH = String.valueOf(commonInfo.TotalStandardWork__c);//포준공수 M/H
                            }
                            if(commonInfo.OverReason__c != null){
                                rw.overReason = commonInfo.OverReason__c;//초과 사유
                            }
                        }

                        //ResultType = SWT 인 WorkOrderResult
                        if(standardMap.containsKey(wo.Id)){
                            List<WorkOrderResult__c> standardInfo = standardMap.get(wo.Id);
                            for(WorkOrderResult__c st : standardInfo){
                                if(st.StandardWorkForce__c != null){
                                    rw.standardCnt += st.StandardWorkForce__c;
                                    rw.standardCnt += '/';
                                }
                                if(st.StandardWorkItem__c != null){
                                    rw.standardWork += st.StandardWorkItem__c;
                                    rw.standardWork += '/';
                                }
                            }
                            
                            if(rw.standardCnt.right(1) == '/'){
                                rw.standardCnt = rw.standardCnt.substring(0, rw.standardCnt.length() - 1);
                            }
                            if(rw.standardWork.right(1) == '/'){
                                rw.standardWork = rw.standardWork.substring(0, rw.standardWork.length() - 1);
                            }
                        }
                        
                        //청구여부
                        if(prMap.containsKey(wo.Id)) rw.isBilled = prMap.get(wo.Id);
                        //공동작업자
                        if(colMap.containsKey(wo.Id)) rw.collaborator = colMap.get(wo.Id);

                        System.debug('@@ rw : ' + rw);

                        rwList.add(rw);
                    }
                }

                cw.returnList = rwList;
            }

        }catch(Exception e){
            cw.isSuccess = false;
            cw.errMessage= e.getLineNumber()+'__'+e.getMessage();
            System.debug('Error : ' + e.getLineNumber()+'__'+e.getMessage());
        }

        return cw;
    }

    /**
     * @Description
     * 	- 조건에 맞는 Workorder 중복 제거해서 추리기
     * @author Hayeong Min 
     * @Parameter
     *  - conditionData    : 조회 조건 String
    **/
    private static List<WorkOrder> checkCondition(String conditionData){
        List<WorkOrder> woList = new List<WorkOrder>();
        try{
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(conditionData);
            String startDate = fieldMap.get('startDate') != null ? String.valueOf(fieldMap.get('startDate')) : '';
            String endDate = fieldMap.get('endDate') != null ? String.valueOf(fieldMap.get('endDate')) : '';
            String completeStartDate = fieldMap.get('completeStartDate') != null ? String.valueOf(fieldMap.get('completeStartDate')) : '';
            String completeEndDate = fieldMap.get('completeEndDate') != null ? String.valueOf(fieldMap.get('completeEndDate')) : '';
            String confirmStartDate = fieldMap.get('confirmStartDate') != null ? String.valueOf(fieldMap.get('confirmStartDate')) : '';
            String confirmEndDate = fieldMap.get('confirmEndDate') != null ? String.valueOf(fieldMap.get('confirmEndDate')) : '';
            String orderNumber = String.valueOf(fieldMap.get('orderNumber')); 
            String workcenter = String.valueOf(fieldMap.get('workcenter')); 
            String branch = String.valueOf(fieldMap.get('branch')); 
            String status = String.valueOf(fieldMap.get('status')); 
            String account = String.valueOf(fieldMap.get('account')); 
            String customerCode = String.valueOf(fieldMap.get('customerCode')); 
            String modelValue = String.valueOf(fieldMap.get('modelValue')); 
            String modelTypeNameValue = String.valueOf(fieldMap.get('modelTypeNameValue')); 
            Boolean checkStandard = Boolean.valueOf(fieldMap.get('checkStandard'));

            String fields = 'Id, FM_ServiceOrderNumber__c, ServiceOrderNumber__c, toLabel(Status), OrderType__c, CreatedDate, ConfirmedDate__c, ';
            fields += 'ReceptionDetail__c, InspectionDetails__c, FM_DispatchIn2hr__c, FM_24HrCompleted__c, ServiceTerritoryId, ServiceTerritory.Name, ServiceTerritory.classify__c, ';
            fields += 'ServiceTerritory.ControlWorkcenter__c, ServiceTerritory.ControlWorkcenter__r.Name, Worker__c, Worker__r.Name, Worker__r.AD_ID__c, ';
            fields += 'Asset.MachineName__c, Asset.Name, Asset.StartUpDate__c, Account.Name, Account.FM_Address__c, Account.Phone, Account.CustomerCode__c, ';
            fields += 'toLabel(Case.TicketType__c), toLabel(Case.InternalTicketType__c), FailureArea__c, FailureAreaGroup__c, FailurePhenomenon__c, ';
            fields += 'FM_ApplicationDateTime__c, FM_RepairRequestDateTime__c, ScheduledDispatchTime__c, ExpectedDepartureTime__c, isMigration__c, Owner.Name, PMActivityType__c, PendingOrCustomerMatters__c, TimeAgreedOnSite__c ';
            
            String conditions = ' WHERE PMActivityType__c = \'CS02\'';
            conditions += ' AND Country__c = \'DNS\'';
            
            if(String.isNotEmpty(orderNumber)){
                conditions += ' AND ServiceOrderNumber__c = \''+orderNumber+'\'';
            }

            if(String.isNotEmpty(workcenter)){
                conditions += ' AND ServiceTerritoryId = \''+workcenter+'\'';
            }

            if(String.isNotEmpty(branch)){
                conditions += ' AND (ServiceTerritory.ControlWorkcenter__c = \''+branch+'\' OR ServiceTerritoryId = \''+branch+'\')';
            }

            if(String.isNotEmpty(status)){
                conditions += ' AND Status = \''+status+'\'';
            }
            
            if(String.isNotEmpty(account)){
                conditions += ' AND Account.Name LIKE  \'%'+account+'%\'';
            }

            if(String.isNotEmpty(customerCode)){
                conditions += ' AND Account.CustomerCode__c = \''+customerCode+'\'';
            }

            if(String.isNotEmpty(modelValue)){
                List<String> modelvalues = modelValue.split(',');
                List<String> modellist = new List<String>();
                for (String val : modelvalues) {
                    val = val.trim();
                    if (!String.isBlank(val)) {
                        modellist.add('\'' + val + '\'');
                    }
                }
                String inModel = String.join(modellist, ',');
                conditions += ' AND Asset.Name IN (' + inModel + ')';
            }

            if(String.isNotEmpty(modelTypeNameValue)){
                List<String> values = modelTypeNameValue.split(',');
                List<String> quotedValues = new List<String>();
                for (String val : values) {
                    val = val.trim();
                    if (!String.isBlank(val)) {
                        quotedValues.add('\'' + val + '\'');
                    }
                }

                String inClause = String.join(quotedValues, ',');
                conditions += ' AND Asset.MachineName__c IN (' + inClause + ')';
            }

            //확정일시
            System.debug('confirmStartDate : ' + confirmStartDate);
            System.debug('confirmEndDate : ' + confirmEndDate);
            if(String.isNotEmpty(confirmStartDate) && String.isNotEmpty(confirmEndDate)){
                Date confirmStartDate_DT = Date.valueOf(confirmStartDate);
                Date confirmEndDate_DT = Date.valueOf(confirmEndDate);
                DateTime kstconfirmStartDateTime = DateTime.newInstanceGmt(confirmStartDate_DT, Time.newInstance(0, 0, 0, 0)).addHours(-9);
                DateTime kstconfirmEndDateime = DateTime.newInstanceGmt(confirmEndDate_DT, Time.newInstance(23, 59, 59, 999)).addHours(-9);
                String formattedConfirmStart = kstconfirmStartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                String formattedConfrimEnd = kstconfirmEndDateime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
                conditions += ' AND ConfirmedDate__c >= ' + formattedConfirmStart;
                conditions += ' AND ConfirmedDate__c <= ' + formattedConfrimEnd;
            }

            //표준공수 여부
            if(checkStandard){
                conditions += ' AND ID IN (SELECT WorkOrder__c FROM WorkOrderResult__c WHERE ResultType__c = \'COM\' AND (TotalStandardWork__c != null and TotalStandardWork__c != 0))';
            }

            //접수일시, 완료일시 둘 다 입력 안된 상태(고객번호, 장비번호, 오더번호로 조회할 때) -> 5년 제한 걸기                       
            if(String.isEmpty(completeStartDate) && String.isEmpty(completeEndDate) && String.isEmpty(startDate) && String.isEmpty(endDate)){
                Date today = System.today();
                Date fiveYearsAgo = today.addYears(-5);
                DateTime startDateTimeUtc = DateTime.newInstance(fiveYearsAgo, Time.newInstance(0, 0, 0, 0)).addHours(-9);
                DateTime endDateTimeUtc = DateTime.newInstance(today, Time.newInstance(23, 59, 59, 999)).addHours(-9);
                String formattedStart = startDateTimeUtc.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                String formattedEnd = endDateTimeUtc.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

                conditions += ' AND FM_ApplicationDateTime__c >= ' + formattedStart +
                            ' AND FM_ApplicationDateTime__c <= ' + formattedEnd;
            }

            //접수일시
            if(String.isNotEmpty(startDate) && String.isNotEmpty(endDate)){
                Date startDate_DT = Date.valueOf(startDate); 
                Date endDate_DT = Date.valueOf(endDate);
                DateTime kstStartDateTime = DateTime.newInstanceGmt(startDate_DT, Time.newInstance(0, 0, 0, 0)).addHours(-9);
                DateTime kstEndDateTime = DateTime.newInstanceGmt(endDate_DT, Time.newInstance(23, 59, 59, 999)).addHours(-9);

                String formattedStart = kstStartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                String formattedEnd = kstEndDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

                conditions += ' AND (FM_ApplicationDateTime__c >= '+ formattedStart;
                conditions += ' AND FM_ApplicationDateTime__c <= '+ formattedEnd + ')';
            }

            //완료일시
            List<WorkOrder> woList1 = new List<WorkOrder>();
            List<WorkOrder> woList2 = new List<WorkOrder>();
            List<WorkOrder> woList3 = new List<WorkOrder>();
            if(String.isNotEmpty(completeStartDate) && String.isNotEmpty(completeEndDate)){

                String conditions1 = conditions;
                String conditions2 = conditions;

                Date completeStartDate_DT = Date.valueOf(completeStartDate);
                Date completeEndDate_DT = Date.valueOf(completeEndDate);
                DateTime kstStartDateTime = DateTime.newInstanceGmt(completeStartDate_DT, Time.newInstance(0, 0, 0, 0)).addHours(-9);
                DateTime kstEndDateTime = DateTime.newInstanceGmt(completeEndDate_DT, Time.newInstance(23, 59, 59, 999)).addHours(-9);
                String formattedStart = kstStartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                String formattedEnd = kstEndDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

                //1.Service Appointment의 작업완료일(Service Report) 필드로 구분 : WorkCompletionTimeMobile__c => 운영 DATA 
                conditions1 += ' AND ID IN (SELECT ParentRecordID FROM ServiceAppointment WHERE WorkCompletionTimeMobile__c >= '+ formattedStart;
                conditions1 += ' AND WorkCompletionTimeMobile__c <= '+ formattedEnd +')';

                //2. Service Order Result의 ResultType__c = 'WH' and (WorkType__c = 'WK'(표준작업) or WorkType__C = 'DN'(표준외작업))에서 WorkDate__c 와 WorkEndTime__c => Migration DATA
                conditions2 += ' AND ID IN (SELECT WorkOrder__c FROM WorkOrderResult__c WHERE ResultType__c=\'WH\' AND (WorkType__c  = \'DN\' OR WorkType__c =\'WK\') AND WorkEndTime__c != null';
                conditions2 += ' AND WorkDate__c >= '+ completeStartDate;
                conditions2 += ' AND WorkDate__c <= '+ completeEndDate +')';

                String query1 = 'SELECT '+ fields + ' FROM WorkOrder '+ conditions1 +' ORDER BY CreatedDate DESC';
                System.debug('query1 ::'+query1);
                System.debug('conditions1 ::'+conditions1);
                woList1 = Database.query(query1);

                String query2 = 'SELECT '+ fields + ' FROM WorkOrder '+ conditions2 +' ORDER BY CreatedDate DESC';
                System.debug('query2 ::'+query2);
                System.debug('conditions2 ::'+conditions2);
                woList2 = Database.query(query2);

            }else{

                String query = 'SELECT '+ fields + ' FROM WorkOrder '+ conditions +' ORDER BY CreatedDate DESC';
                System.debug('query ::'+query);
                System.debug('conditions ::'+conditions);
                woList3 = Database.query(query);
            }


            Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();
            Set<Id> woIds = new Set<Id>();
			Map<Id, Id> resourceMap = new Map<Id, Id>();
            if(woList1.size()>0){
                for(WorkOrder wo : woList1){
                    woMap.put(wo.Id, wo);
                    woIds.add(wo.Id);
                    resourceMap.put(wo.Id, wo.Worker__c);
                }
            }

            if(woList2.size()>0){
                for(WorkOrder wo : woList2){
                    woMap.put(wo.Id, wo);
                    woIds.add(wo.Id);
                    resourceMap.put(wo.Id, wo.Worker__c);
                }
            }

            if(woList3.size()>0){
                for(WorkOrder wo : woList3){
                    woIds.add(wo.Id);
                    resourceMap.put(wo.Id, wo.Worker__c);
                }
                woList = woList3;
            }

            if(!woMap.isEmpty()){
                //중복없이 합친 WorkOrder
                woList = new List<WorkOrder>(woMap.values());
            }

            System.debug('@@ woList : ' + woList);
        }catch(Exception e){
            System.debug('checkCondition ERROR :: '+e.getLineNumber()+'_'+e.getMessage());
        }

        return woList;
    }

    /**
     * @Description
     * 	- Migration 날짜 기준으로 DATA 분리
     * @author Hayeong Min 
     * @Parameter
     *  - woList    : 조회조건을 만족하는 WorkOrder 목록
    **/
    private static WoWrapper seperateMigData(List<WorkOrder> woList){
        WoWrapper result = new WoWrapper();
        //한국시간 기준 250414로 Migration DATA 구분
        Date migDate = Date.valueOf('2025-04-14');
        DateTime cutoffUtc = DateTime.newInstanceGmt(migDate, Time.newInstance(0, 0, 0, 0)).addHours(-9);
        System.debug('cutoffUtc ::: '+cutoffUtc);

        for(WorkOrder wo : woList){
            // if(wo.CreatedDate <= cutoffUtc){//Migration
            //     result.beforeList.add(wo);
            //     result.beforeSet.add(wo.Id);
            // }else{//Production
                result.afterList.add(wo);
                result.afterSet.add(wo.Id);
            // }
        }

        return result;
    }

    /**
     * @Description
     * 	- WorkOrder의 공동작업자 정보
     * @author Hayeong Min 
     * @Parameter
     *  - woIds    : 조회조건을 만족하는 WorkOrder Id 목록
    **/
    private static Map<Id, String> getCollaboData(Set<Id> woIds){
        Map<Id, String> colMap = new Map<Id, String>();
        List<Collaborator__c> collaboList = [SELECT ID, Name, ServiceResource__c, WorkOrder__c,
                                            ServiceResource__r.Name, ServiceResource__r.StaffNumber__c, 
                                            ServiceResource__r.AD_ID__c
                                            FROM Collaborator__c WHERE WorkOrder__c IN : woIds];
        if(collaboList.size()>0){
            for(Collaborator__c col : collaboList){
                // 6785/I0215438 전경민
                String collabo = col.ServiceResource__r.StaffNumber__c+'/'+
                col.ServiceResource__r.AD_ID__c+' '+
                col.ServiceResource__r.Name;

                if(colMap.containsKey(col.WorkOrder__c)){
                collabo = colMap.get(col.WorkOrder__c) + '; ' +collabo;
                }

                colMap.put(col.WorkOrder__c, collabo);
            }
        }

        return colMap;
    }

    /**
     * @Description
     * 	- WorkOrder의 부품청구 여부
     * @author Hayeong Min 
     * @Parameter
     *  - woIds    : 조회조건을 만족하는 WorkOrder Id 목록
    **/
    private static Map<Id, String> getProductData(Set<Id> woIds){
        Map<Id, String> prMap = new Map<Id, String>();
        List<ProductRequest> prList = [SELECT Id, WorkOrderId FROM ProductRequest WHERE WorkOrderId IN :woIds];
        if(prList.size()>0){
            for(ProductRequest pr : prList){
                prMap.put(pr.WorkOrderId, 'Y');
            }
        }
        
        return prMap;
    }

    /**
     * @Description
     * 	- Work Order Result의 Result Type 이 'COM'인 WorkOrderResult 목록 추출 (WorkOrder 당 1개만 존재 )
     * @author Hayeong Min 
     * @Parameter
     *  - woIds    : 조회조건을 만족하는 WorkOrder Id 목록
    **/
    private static Map<Id, WorkOrderResult__c> getCommonData(Set<Id> woIds){
        
        Map<Id, WorkOrderResult__c> wrMap = new Map<Id, WorkOrderResult__c>();
        List<WorkOrderResult__c> wrList = [SELECT Id, WorkOrder__c, TotalWork__c, Overtime__c, TotalStandardWork__c, OverReason__c 
                                            FROM WorkOrderResult__c 
                                            WHERE ResultType__c = 'COM' AND WorkOrder__c IN :woIds];
        if(wrList.size()>0){
            for(WorkOrderResult__c wr : wrList){
                if(!wrMap.containsKey(wr.WorkOrder__c)){
                    wrMap.put(wr.WorkOrder__c, wr);
                }
            }
        }
        
        return wrMap;
    }

    /**
     * @Description
     * 	- 표준공수 관련 WorkOrderResult 목록 추출
     * @author Hayeong Min 
     * @Parameter
     *  - woIds    : 조회조건을 만족하는 WorkOrder Id 목록
    **/       
    private static Map<Id, List<WorkOrderResult__c>> getStandardWorkData(Set<Id> woIds){
        
        Map<Id, List<WorkOrderResult__c>> swtMap = new Map<Id, List<WorkOrderResult__c>>();
        List<WorkOrderResult__c> swtList = [SELECT Id, StandardHour__c, StandardWorkFailureArea__c, StandardWorkForce__c, StandardWorkItem__c, StandardWorkTime__c, WorkOrder__c, CreatedDate
                                            FROM WorkOrderResult__c 
                                            WHERE ResultType__c = 'SWT' AND WorkOrder__c IN :woIds];
        if(swtList.size()>0){
            for(WorkOrderResult__c swt : swtList){
                List<WorkOrderResult__c> wrList = new List<WorkOrderResult__c>();
                if(swtMap.containsKey(swt.WorkOrder__c)){
                    wrList = swtMap.get(swt.WorkOrder__c);
                    wrList.add(swt);
                }else{
                    wrList.add(swt);
                }
                swtMap.put(swt.WorkOrder__c, wrList);
            }
        }
        
        return swtMap;
    }

    /*
     * @Description 
     *  - Workorder Migration, Production DATA 구분하기 위한 Wrapper
     * 
     * @Variable 
     *  - beforeSet 	: Migration WorkOrder ID 
     *  - beforeList 	: Migration WorkOrder List 
     *  - afterSet 	    : Production WorkOrder ID 
     *  - afterList 	: Production WorkOrder List 
     */
    public class WoWrapper {
        @AuraEnabled
        public Set<Id> beforeSet		{get; set;}
        @AuraEnabled
        public List<WorkOrder> beforeList		    {get; set;}
        @AuraEnabled
        public Set<Id> afterSet		{get; set;}
        @AuraEnabled
        public List<WorkOrder> afterList		    {get; set;}
        
        public WoWrapper(){
            this.beforeSet 	            = new Set<Id>();
            this.beforeList 	        = new List<WorkOrder>();
            this.afterSet 	            = new Set<Id>();
            this.afterList 	            = new List<WorkOrder>();
        }
    }


    /*
     * @Description 
     *  - 공용 Wrapper
     * 
     * @Variable 
     *  - isSuccess 	: 성공여부
     *  - errMessage 	: 실패 시 에러 Message
     *  - workcenter 	: W/C 목록
     *  - branch 	    : 관할지사 목록
     *  - status 	    : 상태 목록
     *  - returnList 	: 반환 SObject 목록
     */
    public class Commonwrapper{
        @AuraEnabled public Boolean isSuccess                       { get; set;} 
        @AuraEnabled public String errMessage                       { get; set;}
        @AuraEnabled public List<Map<String, String>> workcenter     { get; set;}
        @AuraEnabled public List<Map<String, String>> branch         { get; set;}
        @AuraEnabled public List<Map<String, String>> status         { get; set;}
        @AuraEnabled public List<Object> returnList          { get; set;}
        
        public Commonwrapper(){
            this.isSuccess = true;
            this.errMessage = '';
            this.workcenter = new List<Map<String, String>>();
            this.branch =   new List<Map<String, String>>();
            this.status =   new List<Map<String, String>>();
            this.returnList = new List<Object>();
        }
    }

    /*
     * @Description 
     *  - 하자접수이력 Wrapper
     */
    public class ResultWrapper{
        @AuraEnabled public String  orderNum { get; set;} //오더번호
        @AuraEnabled public String  pmType { get; set;} //PM Activity
        @AuraEnabled public String  branch { get; set;} //관할지사
        @AuraEnabled public String  workcenter { get; set;} //서비스 W/C
        @AuraEnabled public String  resourceName { get; set;} //서비스요원명
        @AuraEnabled public String  model { get; set;} //기종
        @AuraEnabled public String  serialNum { get; set;} //장비번호
        @AuraEnabled public String  shippingDate { get; set;} //출하일자
        @AuraEnabled public String  account { get; set;} //업체명
        @AuraEnabled public String  address { get; set;} //주소
        @AuraEnabled public String  phone { get; set;} //전화번호
        @AuraEnabled public String  ticketTypeMajor { get; set;} //접수유형(대)
        @AuraEnabled public String  ticketTypeMiddle { get; set;} //접수유형(중)
        @AuraEnabled public String  receptionDetail { get; set;} //접수내용
        @AuraEnabled public String  failureAreaMajor { get; set;} //고장부위(대)
        @AuraEnabled public String  failureAreaMiddle { get; set;} //고장부위(중)
        @AuraEnabled public String  failurePhenomenon { get; set;} //고장현상

        @AuraEnabled public String  receptionDate { get; set;} //Ticket 접수일자
        @AuraEnabled public String  receptionTime { get; set;} //Ticket 접수시간
        @AuraEnabled public String  orderCreatedDate { get; set;} //Service Order 생성일자
        @AuraEnabled public String  orderCreatedTime { get; set;} //Service Order 생성시간
        
        @AuraEnabled public String  mobile_departureDate { get; set;} // Mobile 출발일자
        @AuraEnabled public String  mobile_departureTime { get; set;} // Mobile 출발시간
        @AuraEnabled public String  mobile_completeDate { get; set;} // Mobile 작업완료일자
        @AuraEnabled public String  mobile_completeTime { get; set;} // Mobile 작업완료시간
        
        @AuraEnabled public String  serviceReport_departureDate { get; set;} // Service Report 출발일자
        @AuraEnabled public String  serviceReport_departureTime { get; set;} // Service Report 출발시간
        @AuraEnabled public String  serviceReport_arrivalDate { get; set;} // Service Report 도착일자
        @AuraEnabled public String  serviceReport_arrivalTime { get; set;} // Service Report 도착시간
        @AuraEnabled public String  serviceReport_completeDate { get; set;} // Service Report 작업완료일자
        @AuraEnabled public String  serviceReport_completeTime { get; set;} // Service Report 작업완료시간
        @AuraEnabled public String  timeAgreedOnSiteDate { get; set;} // 고객약속일자
        @AuraEnabled public String  timeAgreedOnSiteTime { get; set;} // 고객약속시간
        
        @AuraEnabled public String  receptionist { get; set;} //상담원
        @AuraEnabled public String  inspectionDetail { get; set;} //조치내역
        @AuraEnabled public String  in2Hour { get; set;} //2시간내 출동
        @AuraEnabled public String  in24Hour { get; set;} //24시간내 처리
        @AuraEnabled public String  totalMH { get; set;} //작업 M/H
        @AuraEnabled public String  standardMH { get; set;} //표준공수
        @AuraEnabled public String  standardCnt { get; set;} //표준인원
        @AuraEnabled public String  standardWork { get; set;} //표준작업항목

        @AuraEnabled public String  isBilled { get; set;} //청구여부
        @AuraEnabled public String  overReason { get; set;} //표준시간초과사유
        @AuraEnabled public String  status { get; set;} // 진행상태
        @AuraEnabled public String  collaborator { get; set;} // 공동작업자
        @AuraEnabled public String  portal_completetDate { get; set;} //포탈 확정일자
        @AuraEnabled public String  portal_completetTime { get; set;} //포탈 확정시간
        @AuraEnabled public String  scheduledDispatchTime { get; set;} //출발 예정일시

        public ResultWrapper(){
            this.orderNum = '';
            this.pmType = '';
            this.branch = '';
            this.workcenter = '';
            this.resourceName = '';
            this.model = '';
            this.serialNum = '';
            this.shippingDate = '0000-00-00';
            this.account = '';
            this.address = '';
            this.phone = '';
            this.ticketTypeMajor = '';
            this.ticketTypeMiddle = '';
            this.receptionDetail = '';
            this.failureAreaMajor = '';
            this.failureAreaMiddle = '';
            this.failurePhenomenon = '';
            
            this.receptionDate = '0000-00-00';
            this.receptionTime = '00:00:00';
            this.orderCreatedDate = '0000-00-00';
            this.orderCreatedTime = '00:00:00';

            this.mobile_departureDate = '0000-00-00';
            this.mobile_departureTime = '00:00:00';
            this.mobile_completeDate = '0000-00-00';
            this.mobile_completeTime = '00:00:00';
            this.serviceReport_departureDate = '0000-00-00';
            this.serviceReport_departureTime = '00:00:00';
            this.serviceReport_arrivalDate = '0000-00-00';
            this.serviceReport_arrivalTime = '00:00:00';
            this.serviceReport_completeDate = '0000-00-00';
            this.serviceReport_completeTime = '00:00:00';

            this.receptionist = '';
            this.inspectionDetail = '';
            this.in2Hour = 'Y';
            this.in24Hour = 'N';
            this.totalMH = '0.0';
            this.standardMH = '0.0';
            this.standardCnt = '';
            this.standardWork = '';
            this.isBilled = 'N';
            this.overReason = '';
            this.status = '';
            this.collaborator = '';
            this.portal_completetDate = '0000-00-00';
            this.portal_completetTime = '00:00:00';
        }
    }
}