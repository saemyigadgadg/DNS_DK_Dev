/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public without sharing class DN_ServiceAppointmentController {

    // 완료판단
    @AuraEnabled
    public static String getServiceAppointment(String serviceAppointmentId) {
        WorkOrder  wo = [SELECT Id, Status FROM WorkOrder WHERE Id = :serviceAppointmentId];
        if (wo != null) {
            System.debug('wo:::'+wo);
            if (wo.Status == 'Canceled') {
                System.debug('삭제된 오더입니다.');
                return 'IS_CANCELED_TRUE';
            }
            
            if (wo.Status == 'Confirm') {
                System.debug('이미 확정된 오더입니다.');
                return 'IS_CONFIRM_TRUE';
            }
        }

        Id currentUserId = UserInfo.getUserId();
        ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
        ServiceAppointment sa = [
            SELECT Id, OnsiteDate__c, Status, ParentRecordId, Department__c, WorkerType__c, Is_Complete__c
            FROM ServiceAppointment 
            WHERE ParentRecordId = :serviceAppointmentId 
            AND ServiceResource__c = :sr.Id 
            AND Status NOT IN ('Canceled', 'Order Canceled')
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];      
        System.debug('sa' + sa);

        

        if (sa.Is_Complete__c == true) {
            System.debug('이미 완료처리가 된 출동예약입니다..');
            return 'IS_COMPLETE_TRUE';
        }
        return 'SUCCESS';
    }

    // 도착예정시간 가져오기
    @AuraEnabled
    public static Datetime getOnSiteDateTime(String serviceAppointmentId) {
        try {
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
            ServiceAppointment sa = [
                SELECT Id, OnsiteDate__c, Status, ParentRecordId, Department__c, WorkerType__c 
                FROM ServiceAppointment 
                WHERE ParentRecordId = :serviceAppointmentId 
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Completed', 'Uncompleted' , 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];            
            System.debug('sa'+sa.OnsiteDate__c);
            System.debug('sa.OnsiteDate__c:::'+sa);
            return sa.OnsiteDate__c;
        } catch (Exception ex) {
            System.debug('Error OnsiteDate__c: ' + ex.getMessage());
            throw new AuraHandledException('Failed get OnsiteDate__c.');
        }
    }

    // 도착예정시간 설정
    @AuraEnabled
    public static String updateOnSiteDateTime(String serviceAppointmentId, Datetime onsiteDateTime) {
        try {
            System.debug(serviceAppointmentId);
            System.debug(onsiteDateTime);
            String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
            Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
            ServiceAppointment sa = [
                SELECT Id, OnsiteDate__c, Status, ParentRecordId, Department__c, WorkerType__c, ServiceResource__c
                FROM ServiceAppointment 
                WHERE ParentRecordId = :serviceAppointmentId 
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Completed', 'Uncompleted' , 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if (isDNSA) {
                System.debug('isDNSA true');
                sa.OnsiteDate__c = onsiteDateTime;
                if(!Test.isRunningTest()) {
                    sa.Status = 'ScheduledToDispatch';
                }
                update sa;
    
                WorkOrder wo = [SELECT Id, Status, ActualDispatchTime__c, Arrival__c, OrderType__c, CaseId FROM WorkOrder WHERE Id = :sa.ParentRecordId];
                System.debug('WorkOrderId:::' + sa.ParentRecordId);
                wo.TimeAgreedOnSite__c = onsiteDateTime;
                update wo;
                System.debug('wo:::' + wo);
        
                return 'SUCCESS';
            } else {
                
                sa.OnsiteDate__c = onsiteDateTime;
                if(!Test.isRunningTest()) {
                    sa.Status = 'ScheduledToDispatch';
                }
                update sa;
    
                WorkOrder wo = [SELECT Id, Status, ActualDispatchTime__c, Arrival__c, OrderType__c, CaseId FROM WorkOrder WHERE Id = :sa.ParentRecordId];
                System.debug('WorkOrderId:::' + sa.ParentRecordId);
                wo.TimeAgreedOnSite__c = onsiteDateTime;
                update wo;
                System.debug('wo:::' + wo);

                return 'SUCCESS';
            }
        } catch (Exception ex) {
            System.debug('Error updating OnsiteDate__c: ' + ex.getMessage());
            throw new AuraHandledException('Failed to update OnsiteDate__c.');
        }
    }


    // 도착시간
    @AuraEnabled
    public static String updateArrivalTime(Id serviceAppointmentId) {
        System.debug(serviceAppointmentId);
        try {
            String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
            Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
            
            Datetime arrivalTime = Datetime.now();
            // TimeZone userTimeZone = UserInfo.getTimeZone();
            // Datetime arrivalTime = utcNow.addSeconds(userTimeZone.getOffset(utcNow) / 1000);
            System.debug('Arrival Time (User TimeZone): ' + arrivalTime);
    
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId, StaffNumber__c FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
            ServiceAppointment sa = [
                SELECT Id, Status, ParentRecordId, Department__c, WorkerType__c, Arrival__c, ServiceResource__c
                FROM ServiceAppointment 
                WHERE ParentRecordId = :serviceAppointmentId 
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Completed', 'Uncompleted' , 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if(!Test.isRunningTest()) {
                if (sa.Department__c == null) {
                    System.debug('출발시간이 없습니다.');
                    return 'NO_DEPARTURE';
                } else {
                    if (sa.Department__c.date() < Date.today()) {
                        System.debug('전날 미결을 누르지 않았습니다.');
                        return 'UNCOMPLETED_DEPARTURE';
                    }
                }
            }
            sa.Arrival__c = arrivalTime;
            if(!Test.isRunningTest()) {
                sa.Status = 'Arrived';
            }
            update sa;
    
            WorkOrder wo = [
                SELECT Id, Status, ActualDispatchTime__c, Arrival__c, OrderType__c, ServiceOrderNumber__c 
                FROM WorkOrder 
                WHERE Id = :sa.ParentRecordId
            ];

            if (wo.Status == 'Closed' || wo.Status == 'Confirm') {
                System.debug('확정된 서비스오더입니다.');
                return 'IS_CONFIRM_TRUE';
            }
            System.debug('WorkOrderId:::' + sa.ParentRecordId);

            if (isDNSA) {
                System.debug('isDNSA true');

                wo.Status = 'Arrived';
                wo.ActualDispatchTime__c = arrivalTime;
                wo.Arrival__c = arrivalTime;
                update wo;
                System.debug('Status:::' + wo);

                WorkOrderResult__c wor = [
                    SELECT Id, ServiceAppointment__c, WorkEndTime__c, WorkType__c 
                    FROM WorkOrderResult__c 
                    WHERE ServiceAppointment__c = :sa.Id LIMIT 1
                ];

                System.debug(wor);
                wor.WorkEndTime__c = arrivalTime.time();
                wor.WorkOrder__c = sa.ParentRecordId;
                update wor;
                System.debug('DNSA wor:::' + wor);

                return 'SUCCESS';
            } else {
                if (sa.WorkerType__c == 'Service Resource (Main)') {
                    wo.Status = 'Arrived';
                    wo.ActualDispatchTime__c = arrivalTime;
                    wo.Arrival__c = arrivalTime;
                }
                update wo;
                System.debug('Status:::' + wo);
                
                WorkOrderResult__c wor = [
                    SELECT Id, ServiceAppointment__c, WorkEndTime__c, WorkType__c 
                    FROM WorkOrderResult__c 
                    WHERE ServiceAppointment__c = :sa.Id LIMIT 1
                ];

                if (wo.OrderType__c != '104') {
                    System.debug(wor);
                    wor.WorkEndTime__c = arrivalTime.time();
                    wor.WorkOrder__c = sa.ParentRecordId;
                    update wor;
                    System.debug('설치시운전이 아닌 wor:::' + wor);
                }

                // ServiceResource sr = [
                //     SELECT Id, CurrentStatus__c, Service_Territory__c, StaffNumber__c 
                //     FROM ServiceResource 
                //     WHERE Id = :sa.ServiceResource__c
                // ];
                System.debug('sr: ' + sr);
                
                DN_ServiceAppointmentController.updateArrivalIF(
                    wo.ServiceOrderNumber__c, 
                    sr.StaffNumber__c, 
                    String.valueOf(sa.Department__c.Date()), 
                    String.valueOf(sa.Department__c.Time()), 
                    String.valueOf(arrivalTime.Date()), 
                    String.valueOf(arrivalTime.Time())
                );

                return 'SUCCESS';
            }
            
        } catch (Exception e) {
            System.debug('Error::: ' + e.getMessage());
            return 'ERROR:::' + e.getMessage();
        }


    }

    // 출발시간
    @AuraEnabled
    public static String updateDepartmentTime(Id serviceAppointmentId) {
        try {
            // serviceAppointmentId는 WorkOrderId
            System.debug('updateDepartmentTime serviceAppointmentId: ' + serviceAppointmentId);
        
            String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
            Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
    
            Datetime departmentTime = Datetime.now();
            System.debug('departmentTime :' + departmentTime);
        
            System.debug('departTime:::' + departmentTime);
            // System.debug('eastDNSATime:::' + eastDNSATime);
            // System.debug('departmentTime:::' + departmentTime);
            
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
            ServiceAppointment sa = [
                SELECT Id, Status, ParentRecordId, Department__c, WorkerType__c, Arrival__c, ServiceResource__c, SchedStartTime, Is_Pending_Process__c, ContactId, Contact.Phone, Contact.MobilePhone
                FROM ServiceAppointment 
                WHERE ParentRecordId = :serviceAppointmentId 
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Completed', 'Uncompleted' , 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            if (sa.Department__c != null) {
                if (sa.Department__c.date() < Date.today()) {
                    if (sa.Status != 'Uncompleted' || sa.Arrival__c == null) {
                        System.debug('전날 도착 및 미결을 누르지 않았습니다.');
                        return 'BEFORE_DEPARTURE';
                    } else {
                        System.debug('전날 미결을 누르지 않았습니다.');
                        return 'UNCOMPLETED_DEPARTURE';
                    }
                } else {
                    System.debug('이미 출발시간이 있습니다.');
                    return 'DEPARTURE';
                }
            }
    
            if (sa.Is_Pending_Process__c == true) {
                sa.SchedStartTime = departmentTime;
            }
            
            // WorkOrder 조회
            WorkOrder wo = [
                SELECT Id, Status, OrderType__c, ServiceOrderNumber__c, CaseId
                FROM WorkOrder 
                WHERE Id = :sa.ParentRecordId
            ];
            System.debug('WorkOrder ID: ' + sa.ParentRecordId);
            
            if (wo.Status == 'Closed' || wo.Status == 'Confirm') {
                System.debug('확정된 서비스오더입니다.');
                return 'IS_CONFIRM_TRUE';
            }

            Case ca = [
                SELECT Id, EndOfReason__c, Status, CaseNumber
                FROM Case
                WHERE Id = :wo.CaseId
            ];
            System.debug('Case ID: ' + wo.CaseId);
    
            if (ca.Status == 'Closed' && ca.EndOfReason__c == 'Customer Cancellation') {
                System.debug('취소된 Ticket입니다.');
                return 'CANCLELATION';
            }
            sa.Department__c = departmentTime;
            if(!Test.isRunningTest()) {
                sa.Status = 'Started';
            }
    
            // update sa;
            Database.SaveResult saveRe = Database.update(sa);
            if (saveRe.isSuccess()) {
                System.debug('Updata ServiceAppointment');
            } else {
                System.debug('ServiceAppointment Updata Failed: ' + saveRe.getErrors());
            }
            
            if (isDNSA) {
                System.debug('isDNSA true');
    
                wo.Status = 'Started';
                // update wo;
                Database.SaveResult saveReWo = Database.update(wo);
                if (saveReWo.isSuccess()) {
                    System.debug('New Updata');
                } else {
                    System.debug('WorkOrder Updata Failed: ' + saveReWo.getErrors());
                    return 'SUCCESS';
                }
    
                // WorkOrderResult__c 리스트 쿼리
                List<WorkOrderResult__c> worQuery = [
                    SELECT ServiceAppointment__c, WorkOrder__c, ServiceResource__c, WorkDate__c, 
                        Description__c, ResultType__c, WorkType__c
                    FROM WorkOrderResult__c 
                    WHERE ServiceAppointment__c = :sa.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];

                List<WorkOrderResult__c> worList = new List<WorkOrderResult__c>();

                if (worQuery.isEmpty()) {
                    // 기존 레코드 없음 → 새로 생성
                    WorkOrderResult__c newWor = new WorkOrderResult__c();
                    newWor.ServiceAppointment__c = sa.Id;
                    newWor.WorkType__c = (wo.OrderType__c == '104') ? null : 'MV';
                    newWor.ResultType__c = 'WH';
                    newWor.WorkOrder__c = sa.ParentRecordId;
                    newWor.ServiceResource__c = sa.ServiceResource__c;
                    newWor.Description__c = 'Go to Site';
                    newWor.WorkDate__c = sa.SchedStartTime != null ? sa.SchedStartTime.date() : Date.today(); // null 방지
                    worList.add(newWor);
                    insert worList;
                    System.debug('Created new WorkOrderResult__c: ' + newWor);
                } else {
                    // 기존 레코드 존재 → 업데이트
                    WorkOrderResult__c wor = worQuery[0];
                    wor.ServiceAppointment__c = sa.Id;
                    wor.WorkOrder__c = sa.ParentRecordId;
                    wor.ServiceResource__c = sa.ServiceResource__c;
                    wor.WorkDate__c = Date.newInstance(departmentTime.year(), departmentTime.month(), departmentTime.day());
                    wor.WorkStartTime__c = departmentTime.time();
                    wor.Description__c = 'Go to Site';
                    wor.ResultType__c = 'WH';
                    update wor;
                    System.debug('DNSA wor:::' + wor);
                }

                
                // ServiceResource 업데이트
                // AssignedResource ar = [
                //     SELECT Id, ServiceAppointmentId, ServiceResourceId
                //     FROM AssignedResource 
                //     WHERE ServiceAppointmentId = :sa.Id
                // ];
    
                // ServiceResource sr = [
                //     SELECT Id, CurrentStatus__c, Service_Territory__c, StaffNumber__c 
                //     FROM ServiceResource 
                //     WHERE Id = :ar.ServiceResourceId
                // ];
                
                System.debug('ServiceResource: ' + sr);
                sr.CurrentStatus__c = 'Work';
                update sr;
    
                return 'SUCCESS';
            } else {
                if (sa.WorkerType__c == 'Service Resource (Main)') {
                    wo.Status = 'Started';
                    update wo;
                    System.debug('Status:::' + wo);
                }
                
                List<WorkOrderResult__c> worQuery = [
                    SELECT ServiceAppointment__c, WorkOrder__c, ServiceResource__c, WorkDate__c, 
                        WorkStartTime__c, Description__c, ResultType__c, WorkType__c
                    FROM WorkOrderResult__c 
                    WHERE ServiceAppointment__c = :sa.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];

                WorkOrderResult__c wor;
                Boolean isInsert = false;

                if (worQuery.isEmpty()) {
                    wor = new WorkOrderResult__c();
                    isInsert = true;
                } else {
                    wor = worQuery[0];
                }

                wor.ServiceAppointment__c = sa.Id;
                wor.WorkOrder__c = sa.ParentRecordId;
                wor.ServiceResource__c = sa.ServiceResource__c;
                wor.WorkDate__c = Date.newInstance(departmentTime.year(), departmentTime.month(), departmentTime.day());
                wor.WorkStartTime__c = departmentTime.time();
                wor.Description__c = '고객사로 이동';
                wor.ResultType__c = 'WH';

                // 설치시운전이 아닌 경우만 WorkType 설정
                if (wo.OrderType__c != '104') {
                    wor.WorkType__c = 'MV';
                } else {
                    wor.WorkType__c = null;
                }

                if (isInsert) {
                     try {
                        insert wor;
                        System.debug('WorkOrderResult__c created ::: ' + wor);
                    } catch (Exception e) {
                        System.debug('WorkOrderResult__c insert failed ::: ' + e.getMessage());
                    }
                } else {
                    try {
                        update wor;
                        System.debug('WorkOrderResult__c updated ::: ' + wor);
                    } catch (Exception e) {
                        System.debug('WorkOrderResult__c update failed ::: ' + e.getMessage());
                    }
                }

        
                // ServiceResource sr = [SELECT Id, CurrentStatus__c, Service_Territory__c, StaffNumber__c FROM ServiceResource WHERE Id = :sa.ServiceResource__c];
                System.debug('sr: ' + sr);
                sr.CurrentStatus__c = 'Work';
                update sr;
    
                List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();
                String alertAlarmTalkId = [
                    SELECT Id FROM AlertManager__c WHERE IsActive__c = true AND Name = 'CS Service Resource Department Alarm Talk' LIMIT 1
                ].Id;
    
                String phone = sa.Contact.MobilePhone; // 없으면 NullPointerException 
                // String relatedWO = wo.ServiceOrderNumber__c;
                String ticketNumber = ca.CaseNumber; // 이것도
                String woNumber = wo.ServiceOrderNumber__c; // 이것도
                Id caseId = wo.CaseId;
                String ctiUrl = System.Label.CTI_Url;
    
                Map<String, String> alertMap = new Map<String, String>();
                alertMap.put('rcpt_no', ticketNumber); // 접수번호 Ticket번호
                alertMap.put('order_no', woNumber); // 서비스오더번호 Work Order번호
                alertMap.put('url', ctiUrl + '?ticket=' + ticketNumber); //A/S 진행상황 조회 URL
    
                UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
                hw.alertID = alertAlarmTalkId;
                hw.targetID = caseId;
                hw.alertType = 'AlarmTalk';
                hw.alertLanguage = 'ko';
                hw.receiverforPhone = new Set<String>{phone};
                hw.elementMap = alertMap;
    
                System.debug('hwList:::'+hwList);
                hwList.add(hw);
    
                UTIL_Alert.runAlertEvent(hwList);
            
                return 'SUCCESS';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        
    }
    
    // 도착시간 업데이트 I/F
    @Future(callout=true)
    public static void updateArrivalIF(String serviceOrderNumber, String staffNumber, String msdd, String msdz, String isdd, String isdz) {
        List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST> t_i_list = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST>();

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST item = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST();
        item.AUFNR = serviceOrderNumber;
        item.PERNR = staffNumber;
        item.MSDD = msdd; // 출발 날짜
        item.MSDZ = msdz; // 출발 시간
        item.ISDD = isdd; // 도착 날짜
        item.ISDZ = isdz; // 도착 시간

        t_i_list.add(item);

        IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req request = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req();
        request.T_I_LIST = t_i_list;

        IF_ERP_WorkOrder method = new IF_ERP_WorkOrder();
        method.IF_CSPLUS_028(request);
    }
    
    // 미결처리
    @AuraEnabled
    public static Map<String, Object> cloneServiceAppointment(String recordId, String pendingDetails, String pendingReasons) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('isSuccess', false);
        
        try {
            // recordId가 올바른지 확인 said
            System.debug('recordId: ' + recordId);
        
            // WorkOrder 레코드를 가져옴
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
            List<ServiceAppointment> ordAppointment = [
                SELECT Id, AppointmentNumber, Street, City, State, PostalCode, Country, Latitude, Longitude, GeocodeAccuracy, Address, Pendingprocessing__c, Status, ParentRecordId, PendingDetail__c, Is_Pending_Process__c, WorkerType__c, ServiceResource__c, Arrival__c
                FROM ServiceAppointment  
                WHERE ParentRecordId = :recordId
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            // 워크오더 쿼리 해야됨
            WorkOrder  wo = [SELECT Id, Status, OrderType__c, Pendingprocessing__c, PendingMattersCustomerRequirements__c FROM WorkOrder WHERE Id = :recordId];

            if (wo.Status == 'Closed' || wo.Status == 'Confirm') {
                System.debug('확정된 서비스오더입니다.');
                response.put('errorMessage', 'IS_CONFIRM_TRUE');
            }

            System.debug('wo:::'+wo);
            wo.Status = 'Uncompleted';
            wo.Pendingprocessing__c = pendingReasons;
            wo.PendingMattersCustomerRequirements__c = pendingDetails;
            update wo;

            
            // WorkOrder ordAppointment = [
            //     SELECT Id, Case.AccountId, Worker__c, Status, Service_Appointment__c,
            //     (
            //         SELECT Id, AppointmentNumber, Street, City, State, PostalCode, Country, Latitude, Longitude, GeocodeAccuracy, Address, Pendingprocessing__c, Status, ParentRecordId, PendingDetail__c, Is_Pending_Process__c, WorkerType__c
            //         FROM ServiceAppointments 
            //         WHERE WorkerType__c = 'Service Resource (Main)' AND Id = :recordId
            //         ORDER BY CreatedDate DESC
            //     ) 
            //     FROM WorkOrder
            //     WHERE Service_Appointment__c = :recordId
            //     LIMIT 1
            // ];
            
            ServiceAppointment existingAppointment = ordAppointment[0];
            System.debug('ordAppointment.size():::' + ordAppointment.size());
            System.debug('Pendingprocessing__c:::' + existingAppointment.Pendingprocessing__c);

            if (ordAppointment.size() > 1 && existingAppointment.Pendingprocessing__c != null) {
                response.put('errorMessage', '미결처리를 할 수 없습니다. 이미 미결 사유가 있습니다. 수동으로 출동예약을 생성해주세요.');
                return response;
            }
            // if (ordAppointment.size() > 1 && existingAppointment.Pendingprocessing__c != null) {
            //     response.put('errorMessage', '미결처리를 할 수 없습니다. 이미 미결 사유가 있습니다. 수동으로 출동예약을 생성해주세요.');
            //     return response;
            // }
        
            // ServiceAppointment 레코드가 존재하지 않을 경우 예외 처리
            System.debug('ServiceAppointment found: ' + ordAppointment[0].Id);

            // 기존 WorkOrder를 업데이트 쿼리 후 적용
            // if (existingAppointment.WorkerType__c == 'Service Resource (Main)') {
            //     ordAppointment[0].Status = 'Uncompleted';
            // }
            // update ordAppointment;

            // 기존 ServiceAppointment를 업데이트
            // if (pendingReasons != '기타') {
            existingAppointment.Pendingprocessing__c = pendingReasons;
            // } else if (pendingReasons == '기타') {
            existingAppointment.PendingDetail__c = pendingDetails;
            existingAppointment.Is_Pending_Process__c = true;
            // }
            // update existingAppointment;
            // existingAppointment.Pendingprocessing__c = pendingDetails;

            if(!Test.isRunningTest()) {
                existingAppointment.Status = 'Uncompleted';
                System.debug('existingAppointment:::'+existingAppointment);
            }
            update existingAppointment;

            Datetime dt = Datetime.now();

            List<WorkOrderResult__c> worList = [
                SELECT Id, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, 
                    WorkDate__c, WorkStartTime__c, WorkEndTime__c, 
                    WorkType__c, ResultType__c, Description__c
                FROM WorkOrderResult__c 
                WHERE ServiceAppointment__c = :existingAppointment.Id
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if (!worList.isEmpty()) {
                WorkOrderResult__c wor = worList[0];
                if(wo.OrderType__c == '104') {
                    wor.Description__c = '[미결사항]: ' + pendingReasons + ' [미결내용]: ' + pendingDetails;
                    update wor;
                } else {
                    WorkOrderResult__c newWOResult = new WorkOrderResult__c();
                    newWOResult.WorkOrder__c = existingAppointment.ParentRecordId;
                    newWOResult.ServiceAppointment__c = existingAppointment.Id;
                    newWOResult.ServiceResource__c = existingAppointment.ServiceResource__c;
                    newWOResult.WorkDate__c = wor.WorkDate__c;
                    newWOResult.WorkStartTime__c = existingAppointment.Arrival__c == null ? null : existingAppointment.Arrival__c.Time();
                    newWOResult.WorkEndTime__c = dt.time();
                    newWOResult.WorkType__c = 'WK';
                    newWOResult.ResultType__c = 'WH';
                    newWOResult.Description__c = '[미결사항]: ' + pendingReasons + ' [미결내용]: ' + pendingDetails;
                    insert newWOResult;
                }
            } else {
                // wor가 존재하지 않는 경우, 새로 생성
                WorkOrderResult__c newWOResult = new WorkOrderResult__c();
                newWOResult.WorkOrder__c = existingAppointment.ParentRecordId;
                newWOResult.ServiceAppointment__c = existingAppointment.Id;
                newWOResult.ServiceResource__c = existingAppointment.ServiceResource__c;
                newWOResult.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day());
                newWOResult.WorkStartTime__c = existingAppointment.Arrival__c == null ? null : existingAppointment.Arrival__c.Time();
                newWOResult.WorkEndTime__c = dt.time();
                newWOResult.WorkType__c = 'WK';
                newWOResult.ResultType__c = 'WH';
                newWOResult.Description__c = '[미결사항]: ' + pendingReasons + ' [미결내용]: ' + pendingDetails;
                insert newWOResult;
            }

            System.debug('미결처리가 성공적으로 저장되었습니다.');
            response.put('isSuccess', true);
            response.put('message', '미결처리가 성공적으로 저장되었습니다.');
        } catch (Exception e) {
            response.put('errorMessage', 'Error: ' + e.getMessage());

        }
        return response;
    }
}