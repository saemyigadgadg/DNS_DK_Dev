/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public without sharing class DN_ModelManagerController {

    // ServiceAppointment를 조회하는 메서드
    @AuraEnabled
    public static WorkOrder getWorkOrder(Id saId) {
        Id currentUserId = UserInfo.getUserId();
        ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
        ServiceAppointment sa = [
            SELECT Id, ParentRecordId 
            FROM ServiceAppointment 
            WHERE ParentRecordId = :saId 
            AND ServiceResource__c = :sr.Id 
            AND Status NOT IN ('Canceled', 'Order Canceled')
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        return [SELECT Id, FailureAreaValue__c, FailureAreaGroupValue__c, FailurePhenomenonValue__c, CauseOfFailureValue__c, RepairActionValue__c, FailurePhenomenonDetail__c, CauseOfFailureDetail__c, PendingOrCustomerMatters__c, Report_Type__c, RecordType.Name, isMachineDown__c, RepairStartDate__c, RepairEndDate__c
        FROM WorkOrder 
        WHERE Id = :sa.ParentRecordId 
        ORDER BY CreatedDate DESC
        LIMIT 1];
    }

    // 고장부위(대)
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getFailureAreaMajor(Id saId) {
        // ServiceAppointment sa = [
        //     SELECT Id, WorkOrder__r.Asset.ObjectType__c, ParentRecordType, ParentRecordId
        //     FROM ServiceAppointment
        //     WHERE Id = :saId AND ParentRecordType = 'WorkOrder'
        //     LIMIT 1
        // ];

        WorkOrder wo = [
            SELECT Id, Asset.ObjectType__c
            FROM WorkOrder 
            WHERE Id = :saId
        ];

        String objectType = wo.Asset.ObjectType__c;
        System.debug('objectType:::' + objectType);
        List<DN_FailureAreaController.CustomSelectOption> options = DN_FailureAreaController.getFailureAreaMajor(objectType);
        return DN_FailureAreaController.getFailureAreaMajor(objectType);
    }

    // 고장부위(중)
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getFailureAreaMiddle(String majorValue){
        // String majorValue;
        List<DN_FailureAreaController.CustomSelectOption> options = DN_FailureAreaController.getFailureAreaMiddle(majorValue);
        return DN_FailureAreaController.getFailureAreaMiddle(majorValue);
    }
    

    // 고장현상
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getFailurePhenomenon(String middleValue){
        List<DN_FailureAreaController.CustomSelectOption> options = DN_FailureAreaController.getFailurePhenomenon(middleValue);
        return DN_FailureAreaController.getFailurePhenomenon(middleValue);
    }

    // 고장원인 getFailureCause
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getFailureCause(String phenomenonValue){
        List<DN_FailureAreaController.CustomSelectOption> options = DN_FailureAreaController.getFailureCause(phenomenonValue);
        return DN_FailureAreaController.getFailureCause(phenomenonValue);
    }

    // 조치내역
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getRepairAction(Id saId) {
        // ServiceAppointment sa = [
        //     SELECT Id, WorkOrder__r.Asset.ObjectType__c, ParentRecordType, ParentRecordId
        //     FROM ServiceAppointment
        //     WHERE Id = :saId AND ParentRecordType = 'WorkOrder'
        //     LIMIT 1
        // ];

        WorkOrder wo = [
            SELECT Id, Asset.ObjectType__c
            FROM WorkOrder 
            WHERE Id = :saId
        ];

        String objectType = wo.Asset.ObjectType__c;
        System.debug('objectType:::' + objectType);
        List<DN_FailureAreaController.CustomSelectOption> options = DN_FailureAreaController.getRepairAction(objectType);
        return DN_FailureAreaController.getRepairAction(objectType);
    }

    // 미결판단
    @AuraEnabled
    public static String getServiceAppointment(Id saId) {
        String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
        Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
        Id currentUserId = UserInfo.getUserId();
        ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];   
        serviceAppointment sa = [
            SELECT Id, WorkOrder__r.Id, ParentRecordId, WorkerType__c, Department__c, Arrival__c, ServiceResource__c, WorkCompletionTime__c, Is_Pending_Process__c, Is_Complete__c 
            FROM serviceAppointment 
            WHERE ParentRecordId = :saId 
            AND ServiceResource__c = :sr.Id 
            AND Status NOT IN ('Canceled', 'Order Canceled')
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.debug('sa:::' + sa);

        WorkOrder wo = [SELECT Id,Status, OrderType__c FROM WorkOrder WHERE Id = :sa.ParentRecordId LIMIT 1];

        // if (sa.Is_Pending_Process__c == true) {
        //     System.debug('미결처리가 진행된 출동예약입니다.');
        //     return 'IS_PENDING_PROCESS_TRUE';
        // }

        if (wo.Status == 'Confirm') {
            System.debug('이미 확정된 오더입니다.');
            return 'IS_CONFIRM_TRUE';
        }

        if (isDNSA) {
            System.debug('DNSA Ture');
            return 'IS_DNSA';
        }else if (!wo.OrderType__c.startsWith('2')) {
            System.debug('Order Type이 CS02가 아닙니다.');
            return 'IS_ORDERTYPE_FALSE';
        } else if (sa.Is_Complete__c == true) {
            System.debug('완료처리가 진행된 출동예약입니다.');
            return 'IS_COMPLETE_TRUE';
        }
            
        
        

        return 'SUCCESS';
    }

    // 작업결과 입력
    @AuraEnabled
    public static String updateResult(Id saId, String saveObject, String reportValue, Boolean machineDown, Date repairStart, Date repairEnd) {
        System.debug('saveObject:::' + saveObject);
        System.debug('saId' + saId);

        String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
        Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');

        if (isDNSA) {
            System.debug('isDNSA true');
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
            serviceAppointment sa = [
                SELECT Id, WorkOrder__r.Id, ParentRecordId, WorkerType__c, Department__c, Arrival__c, ServiceResource__c, WorkCompletionTime__c, Is_Pending_Process__c, Is_Complete__c, Status 
                FROM serviceAppointment 
                WHERE ParentRecordId = :saId 
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            System.debug('sa' + sa);
            // if (sa.Is_Complete__c == true) {
            //     System.debug('완료처리가 진행된 출동예약입니다.');
            //     return 'IS_COMPLETE_TRUE';
            // }
    
            Datetime dt = Datetime.now();
            System.debug('Arrival Time (User TimeZone): ' + dt);    
            Time tm = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
    
            // sa.WorkCompletionTime__c = dt;
            // sa.Status = 'Completed';
            // sa.Is_Complete__c = true;
            update sa;
    
            Map<String, Object> newWOResultMap = (Map<String, Object>) JSON.deserializeUntyped(saveObject);
            System.debug('newWOResultMap:::'+newWOResultMap);
            WorkOrder wo = [
                SELECT Id, CaseId, Status, OrderType__c, FailurePhenomenonDetail__c, CauseOfFailureDetail__c, FM_WorkCompletionTime__c, FailureArea__c, FailureAreaGroup__c, FailurePhenomenon__c, CauseOfFailure__c, RepairAction__c, InspectionDetails__c, FailureAreaValue__c, FailureAreaGroupValue__c, FailurePhenomenonValue__c, CauseOfFailureValue__c, RepairActionValue__c, PendingOrCustomerMatters__c, Report_Type__c, isMachineDown__c, RepairStartDate__c, RepairEndDate__c
                FROM WorkOrder 
                WHERE Id = :sa.ParentRecordId 
                LIMIT 1
            ];
    
            Case ca = [
                SELECT Id, FailureArea__c, FailureAreaValue__c, FailureAreaDetail__c, FailureAreaDetailValue__c, FailurePhenomenon__c, FailurePhenomenonValue__c
                FROM Case 
                WHERE Id = :wo.CaseId 
                LIMIT 1
            ];
    
            if (isDNSA) {
                Map<String, Object> failureAreaMajorMap = (Map<String, Object>) newWOResultMap.get('failureAreaMajor');
                ca.FailureArea__c = String.valueOf(failureAreaMajorMap.get('label')); // 고장부위
                ca.FailureAreaValue__c = String.valueOf(failureAreaMajorMap.get('value')); // 고장부위
                Map<String, Object> failureAreaMiddleMap = (Map<String, Object>) newWOResultMap.get('failureAreaMiddle');
                ca.FailureAreaDetail__c = String.valueOf(failureAreaMiddleMap.get('label')); // 고장부위 그룹
                ca.FailureAreaDetailValue__c = String.valueOf(failureAreaMiddleMap.get('value')); // 고장부위 그룹
                Map<String, Object> failurePhenomenonMap = (Map<String, Object>) newWOResultMap.get('failurePhenomenon');
                ca.FailurePhenomenon__c = String.valueOf(failurePhenomenonMap.get('label')); // 고장현상
                ca.FailurePhenomenonValue__c = String.valueOf(failurePhenomenonMap.get('value')); // 고장현상
                update ca;
            }
    
            if (isDNSA) {
                // wo.Status = 'Completed';
                // wo.FM_WorkCompletionTime__c	 = dt; // 완료일시
                Map<String, Object> failureAreaMajorMap = (Map<String, Object>) newWOResultMap.get('failureAreaMajor');
                wo.FailureArea__c = String.valueOf(failureAreaMajorMap.get('label')); // 고장부위
                wo.FailureAreaValue__c = String.valueOf(failureAreaMajorMap.get('value')); // 고장부위
                Map<String, Object> failureAreaMiddleMap = (Map<String, Object>) newWOResultMap.get('failureAreaMiddle');
                wo.FailureAreaGroup__c = String.valueOf(failureAreaMiddleMap.get('label')); // 고장부위 그룹
                wo.FailureAreaGroupValue__c = String.valueOf(failureAreaMiddleMap.get('value')); // 고장부위 그룹
                Map<String, Object> failurePhenomenonMap = (Map<String, Object>) newWOResultMap.get('failurePhenomenon');
                wo.FailurePhenomenon__c = String.valueOf(failurePhenomenonMap.get('label')); // 고장현상
                wo.FailurePhenomenonValue__c = String.valueOf(failurePhenomenonMap.get('value')); // 고장현상
                Map<String, Object> failureCauseMap = (Map<String, Object>) newWOResultMap.get('failureCause');
                wo.CauseOfFailure__c = String.valueOf(failureCauseMap.get('label')); // 고장원인
                wo.CauseOfFailureValue__c = String.valueOf(failureCauseMap.get('value')); // 고장원인
                Map<String, Object> repairActionMap = (Map<String, Object>) newWOResultMap.get('repairAction');
                wo.RepairAction__c = String.valueOf(repairActionMap.get('label')); // 조치내역
                wo.RepairActionValue__c = String.valueOf(repairActionMap.get('value')); // 조치내역
    
                wo.PendingOrCustomerMatters__c = String.valueOf(newWOResultMap.get('pendingOrCustomerMatters')); // 조치내용
                wo.FailurePhenomenonDetail__c = String.valueOf(newWOResultMap.get('failurePhenomenonDetail')); // 고장부위/현상 상세
                wo.CauseOfFailureDetail__c = String.valueOf(newWOResultMap.get('causeOfFailureDetail')); // 고장원인 상세
                wo.Report_Type__c = reportValue;
                wo.isMachineDown__c = machineDown;
                wo.RepairStartDate__c = repairStart;
                wo.RepairEndDate__c = repairEnd;
                System.debug('wo:::' + wo);
                update wo;
    
                
            }
    
            WorkOrderResult__c wor = [
                SELECT Id, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, WorkDate__c, WorkStartTime__c, WorkEndTime__c, WorkType__c, ResultType__c 
                FROM WorkOrderResult__c 
                WHERE ServiceAppointment__c = :sa.Id 
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];        
            if (wor.WorkType__c == 'WK' && wor.ServiceAppointment__c == sa.Id) {
                wor.WorkOrder__c = sa.ParentRecordId;
                wor.ServiceAppointment__c = sa.Id; // ID
                wor.ServiceResource__c = sa.ServiceResource__c; // 작업자
                // wor.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
                // wor.WorkStartTime__c = sa.Arrival__c.time() == null ? null : sa.Arrival__c.time(); // 출발
                // wor.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
        
                // wor.WorkEndTime__c = tm; // 도착
                wor.WorkType__c = 'WK'; // 작업구분
                wor.ResultType__c = 'WH'; // 작업구분
                System.debug('wor:::' + wor);
                update wor;
            } else {
                WorkOrderResult__c newWOResult = new WorkOrderResult__c();
    
                newWOResult.WorkOrder__c = sa.ParentRecordId;
                newWOResult.ServiceAppointment__c = sa.Id; // ID
                newWOResult.ServiceResource__c = sa.ServiceResource__c; // 작업자
                newWOResult.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
                // newWOResult.WorkStartTime__c = sa.Arrival__c.time() == null ? null : sa.Arrival__c.time(); // 출발
                newWOResult.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
        
                newWOResult.WorkEndTime__c = tm; // 도착
                newWOResult.WorkType__c = 'WK'; // 작업구분
                newWOResult.ResultType__c = 'WH'; // 작업구분
                System.debug('newWOResult:::' + newWOResult);
                insert newWOResult;
            }
            
            return 'SUCCESS';
        } else {
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1]; 
            serviceAppointment sa = [
                SELECT Id, WorkOrder__r.Id, ParentRecordId, WorkerType__c, Department__c, Arrival__c, ServiceResource__c, WorkCompletionTime__c, Is_Pending_Process__c, Is_Complete__c, Status 
                FROM serviceAppointment 
                WHERE ParentRecordId = :saId 
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            System.debug('sa' + sa);
            // if (sa.Is_Complete__c == true) {
            //     System.debug('완료처리가 진행된 출동예약입니다.');
            //     return 'IS_COMPLETE_TRUE';
            // }
    
            Datetime dt = Datetime.now();
            System.debug('Arrival Time (User TimeZone): ' + dt);    
            Time tm = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
    
            // sa.WorkCompletionTime__c = dt;
            // sa.Status = 'Completed';
            // sa.Is_Complete__c = true;
            update sa;
    
            Map<String, Object> newWOResultMap = (Map<String, Object>) JSON.deserializeUntyped(saveObject);
            System.debug('newWOResultMap:::'+newWOResultMap);
            WorkOrder wo = [
                SELECT Id, CaseId, Status, OrderType__c, FailurePhenomenonDetail__c, CauseOfFailureDetail__c, FM_WorkCompletionTime__c, FailureArea__c, FailureAreaGroup__c, FailurePhenomenon__c, CauseOfFailure__c, RepairAction__c, InspectionDetails__c, FailureAreaValue__c, FailureAreaGroupValue__c, FailurePhenomenonValue__c, CauseOfFailureValue__c, RepairActionValue__c, PendingOrCustomerMatters__c
                FROM WorkOrder 
                WHERE Id = :sa.ParentRecordId 
                LIMIT 1
            ];
    
            Case ca = [
                SELECT Id, FailureArea__c, FailureAreaValue__c, FailureAreaDetail__c, FailureAreaDetailValue__c, FailurePhenomenon__c, FailurePhenomenonValue__c
                FROM Case 
                WHERE Id = :wo.CaseId 
                LIMIT 1
            ];
    
            if (sa.WorkerType__c == 'Service Resource (Main)') {
                Map<String, Object> failureAreaMajorMap = (Map<String, Object>) newWOResultMap.get('failureAreaMajor');
                ca.FailureArea__c = String.valueOf(failureAreaMajorMap.get('label')); // 고장부위
                ca.FailureAreaValue__c = String.valueOf(failureAreaMajorMap.get('value')); // 고장부위
                Map<String, Object> failureAreaMiddleMap = (Map<String, Object>) newWOResultMap.get('failureAreaMiddle');
                ca.FailureAreaDetail__c = String.valueOf(failureAreaMiddleMap.get('label')); // 고장부위 그룹
                ca.FailureAreaDetailValue__c = String.valueOf(failureAreaMiddleMap.get('value')); // 고장부위 그룹
                Map<String, Object> failurePhenomenonMap = (Map<String, Object>) newWOResultMap.get('failurePhenomenon');
                ca.FailurePhenomenon__c = String.valueOf(failurePhenomenonMap.get('label')); // 고장현상
                ca.FailurePhenomenonValue__c = String.valueOf(failurePhenomenonMap.get('value')); // 고장현상
                update ca;
            }
    
            if (sa.WorkerType__c == 'Service Resource (Main)') {
                // wo.Status = 'Completed';
                // wo.FM_WorkCompletionTime__c	 = dt; // 완료일시
                Map<String, Object> failureAreaMajorMap = (Map<String, Object>) newWOResultMap.get('failureAreaMajor');
                wo.FailureArea__c = String.valueOf(failureAreaMajorMap.get('label')); // 고장부위
                wo.FailureAreaValue__c = String.valueOf(failureAreaMajorMap.get('value')); // 고장부위
                Map<String, Object> failureAreaMiddleMap = (Map<String, Object>) newWOResultMap.get('failureAreaMiddle');
                wo.FailureAreaGroup__c = String.valueOf(failureAreaMiddleMap.get('label')); // 고장부위 그룹
                wo.FailureAreaGroupValue__c = String.valueOf(failureAreaMiddleMap.get('value')); // 고장부위 그룹
                Map<String, Object> failurePhenomenonMap = (Map<String, Object>) newWOResultMap.get('failurePhenomenon');
                wo.FailurePhenomenon__c = String.valueOf(failurePhenomenonMap.get('label')); // 고장현상
                wo.FailurePhenomenonValue__c = String.valueOf(failurePhenomenonMap.get('value')); // 고장현상
                Map<String, Object> failureCauseMap = (Map<String, Object>) newWOResultMap.get('failureCause');
                wo.CauseOfFailure__c = String.valueOf(failureCauseMap.get('label')); // 고장원인
                wo.CauseOfFailureValue__c = String.valueOf(failureCauseMap.get('value')); // 고장원인
                Map<String, Object> repairActionMap = (Map<String, Object>) newWOResultMap.get('repairAction');
                wo.RepairAction__c = String.valueOf(repairActionMap.get('label')); // 조치내역
                wo.RepairActionValue__c = String.valueOf(repairActionMap.get('value')); // 조치내역
    
                wo.PendingOrCustomerMatters__c = String.valueOf(newWOResultMap.get('pendingOrCustomerMatters')); // 조치내용
                wo.FailurePhenomenonDetail__c = String.valueOf(newWOResultMap.get('failurePhenomenonDetail')); // 고장부위/현상 상세
                wo.CauseOfFailureDetail__c = String.valueOf(newWOResultMap.get('causeOfFailureDetail')); // 고장원인 상세
                System.debug('wo:::' + wo);
                update wo;
    
                
            }
    
            WorkOrderResult__c wor = [
                SELECT Id, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, WorkDate__c, WorkStartTime__c, WorkEndTime__c, WorkType__c, ResultType__c 
                FROM WorkOrderResult__c 
                WHERE ServiceAppointment__c = :sa.Id 
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];        
            System.debug('wor:::' + wor);
            if (wor.WorkType__c == 'WK' && wor.ServiceAppointment__c == sa.Id) {
                wor.WorkOrder__c = sa.ParentRecordId;
                wor.ServiceAppointment__c = sa.Id; // ID
                wor.ServiceResource__c = sa.ServiceResource__c; // 작업자
                // wor.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
                // wor.WorkStartTime__c = sa.Arrival__c.time() == null ? null : sa.Arrival__c.time(); // 출발
                // wor.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
        
                // wor.WorkEndTime__c = tm; // 도착
                wor.WorkType__c = 'WK'; // 작업구분
                wor.ResultType__c = 'WH'; // 작업구분
                System.debug('wor:::' + wor);
                update wor;
            } else {
                WorkOrderResult__c newWOResult = new WorkOrderResult__c();
    
                newWOResult.WorkOrder__c = sa.ParentRecordId;
                newWOResult.ServiceAppointment__c = sa.Id; // ID
                newWOResult.ServiceResource__c = sa.ServiceResource__c; // 작업자
                newWOResult.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
                // newWOResult.WorkStartTime__c = sa.Arrival__c.time() == null ? null : sa.Arrival__c.time(); // 출발
                newWOResult.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
        
                newWOResult.WorkEndTime__c = tm; // 도착
                newWOResult.WorkType__c = 'WK'; // 작업구분
                newWOResult.ResultType__c = 'WH'; // 작업구분
                System.debug('newWOResult:::' + newWOResult);
                insert newWOResult;
            }
            
            return 'SUCCESS';
        }
    }

    // 완료보고 CS02가 아닐때
    @AuraEnabled
    public static String createdResult(Id saId, String saveObject) {
        String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
        Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
        if (isDNSA) {
            System.debug('isDNSA true');
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
            serviceAppointment sa = [
                SELECT Id, WorkOrder__r.Id, ParentRecordId, WorkerType__c, Department__c, Arrival__c, ServiceResource__c, WorkCompletionTime__c, Is_Pending_Process__c, Is_Complete__c, Status 
                FROM serviceAppointment 
                WHERE ParentRecordId = :saId 
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            System.debug('sa' + sa);
            WorkOrder wo = [
                SELECT Id, Status, CaseId, OrderType__c, FailurePhenomenonDetail__c, CauseOfFailureDetail__c, FM_WorkCompletionTime__c, FailureArea__c, FailureAreaGroup__c, FailurePhenomenon__c, 
                       CauseOfFailure__c, RepairAction__c, InspectionDetails__c, FailureAreaValue__c, FailureAreaGroupValue__c, FailurePhenomenonValue__c, CauseOfFailureValue__c, RepairActionValue__c, 
                       PendingOrCustomerMatters__c, ServiceOrderNumber__c
                FROM WorkOrder 
                WHERE Id = :sa.ParentRecordId 
                LIMIT 1
            ];
            System.debug('wo:::'+wo);
            if (sa.Is_Complete__c == true || wo.Status == 'Confirm') {
                System.debug('완료처리가 진행된 출동예약입니다.');
                return 'IS_COMPLETE_TRUE';
            }
            // return null; // 아무 동작도 하지 않고 바로 반환
            return 'NULL';
        } else {
            Datetime completeTime = Datetime.now();
            // Map<String, Object> saveData = (Map<String, Object>) JSON.deserializeUntyped(saveObject);
            System.debug('saveObject:::' + saveObject);
            System.debug('saId' + saId);
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, Service_Territory__c, StaffNumber__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
            serviceAppointment sa = [
                SELECT Id, WorkOrder__r.Id, ParentRecordId, WorkerType__c, Department__c, Arrival__c, ServiceResource__c, WorkCompletionTime__c, Is_Pending_Process__c, Is_Complete__c, Status 
                FROM serviceAppointment 
                WHERE ParentRecordId = :saId 
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            System.debug('sa' + sa);
    
            // Map<String, Object> newWOResultMap = (Map<String, Object>) JSON.deserializeUntyped(saveObject);
            // System.debug('newWOResultMap:::'+newWOResultMap);
            WorkOrder wo = [
                SELECT Id, Status, CaseId, OrderType__c, FailurePhenomenonDetail__c, CauseOfFailureDetail__c, FM_WorkCompletionTime__c, FailureArea__c, FailureAreaGroup__c, FailurePhenomenon__c, 
                       CauseOfFailure__c, RepairAction__c, InspectionDetails__c, FailureAreaValue__c, FailureAreaGroupValue__c, FailurePhenomenonValue__c, CauseOfFailureValue__c, RepairActionValue__c, 
                       PendingOrCustomerMatters__c, ServiceOrderNumber__c
                FROM WorkOrder 
                WHERE Id = :sa.ParentRecordId 
                LIMIT 1
            ];
            System.debug('wo:::'+wo);
            // ServiceResource sr = [SELECT Id, CurrentStatus__c, Service_Territory__c, StaffNumber__c FROM ServiceResource WHERE Id = :sa.ServiceResource__c];
            System.debug('sr: ' + sr);
            Case ca = [
                SELECT Id, FailureArea__c, FailureAreaValue__c, FailureAreaDetail__c, FailureAreaDetailValue__c, FailurePhenomenon__c, FailurePhenomenonValue__c
                FROM Case 
                WHERE Id = :wo.CaseId 
                LIMIT 1
            ];
            
            WorkOrderResult__c wor = [
                SELECT Id, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, WorkDate__c, WorkStartTime__c, WorkEndTime__c, WorkType__c, ResultType__c 
                FROM WorkOrderResult__c 
                WHERE ServiceAppointment__c = :sa.Id 
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];  
            if (sa.Is_Complete__c == true || wo.Status == 'Confirm') {
                System.debug('완료처리가 진행된 출동예약입니다.');
                return 'IS_COMPLETE_TRUE';
            }
    
            if (sa.Is_Pending_Process__c == true) {
                System.debug('미결처리가 진행된 출동예약입니다.');
                return 'IS_PENDING_PROCESS_TRUE';
            }
            
    
            Datetime dt = Datetime.now();
            System.debug('Arrival Time (User TimeZone): ' + dt);    
            Time tm = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
    
            sa.WorkCompletionTime__c = dt;
            if(!Test.isRunningTest()) {
                sa.Status = 'Completed';
                sa.Is_Complete__c = true;
            }
            update sa;
            // WorkOrder Update
            if (sa.WorkerType__c == 'Service Resource (Main)') {
                wo.Status = 'Completed';
                wo.FM_WorkCompletionTime__c	 = dt; // 완료일시
                System.debug('wo:::' + wo);
                update wo;
            }
    
            if (wo.OrderType__c == '104') {
                wor.WorkOrder__c = sa.ParentRecordId;
                wor.WorkEndTime__c = tm; // 도착
                System.debug('설치시운전 시 wor:::' + wor);
                update wor;
            }else if (wor.WorkType__c == 'WK' && wor.ServiceAppointment__c == sa.Id) {
                wor.WorkOrder__c = sa.ParentRecordId;
                wor.ServiceAppointment__c = sa.Id; // ID
                wor.ServiceResource__c = sa.ServiceResource__c; // 작업자
                wor.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
                wor.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
                wor.WorkEndTime__c = tm; // 도착
                wor.WorkType__c = 'WK'; // 작업구분
                wor.ResultType__c = 'WH'; // 작업구분
                System.debug('wor:::' + wor);
                update wor;
            } else {
                WorkOrderResult__c newWOResult = new WorkOrderResult__c();
                newWOResult.WorkOrder__c = sa.ParentRecordId;
    
                newWOResult.ServiceAppointment__c = sa.Id; // ID
                newWOResult.ServiceResource__c = sa.ServiceResource__c; // 작업자
                newWOResult.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
                newWOResult.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
                newWOResult.WorkEndTime__c = tm == null ? null : tm; // 도착
                newWOResult.WorkType__c = 'WK'; // 작업구분
                newWOResult.ResultType__c = 'WH'; // 작업구분
                System.debug('newWOResult:::' + newWOResult);
                insert newWOResult;
                
            }
            
            DN_ModelManagerController.updateCompletIF(
                wo.ServiceOrderNumber__c, sr.StaffNumber__c, 
                String.valueOf(sa.Department__c == null ? null : sa.Department__c.Date()), String.valueOf(sa.Department__c == null ? null : sa.Department__c.Time()),   // 출발
                String.valueOf(sa.Arrival__c == null ? null : sa.Arrival__c.Date()), String.valueOf(sa.Arrival__c == null ? null : sa.Arrival__c.Time()),               // 도착
                String.valueOf(completeTime.Date()), String.valueOf(completeTime.Time())                                                                                // 완료
                );
            return 'SUCCESS';
        }
    }

    // 완료보고
    @AuraEnabled
    public static String createResult(Id saId, String saveObject) {
        System.debug('createResult');
        String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
        Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
        if (isDNSA) {
            System.debug('isDNSA true');
            Datetime completeTime = Datetime.now();
            String eastDNSATime = completeTime.format('yyyy-MM-dd HH:mm:ss', 'America/New_York');
            completeTime = Datetime.valueOf(eastDNSATime);
            System.debug('Arrival Time (User TimeZone): ' + completeTime);

            // Map<String, Object> saveData = (Map<String, Object>) JSON.deserializeUntyped(saveObject);
            System.debug('saveObject:::' + saveObject);
            System.debug('saId' + saId);
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, Service_Territory__c, StaffNumber__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
            serviceAppointment sa = [
                SELECT Id, WorkOrder__r.Id, ParentRecordId, WorkerType__c, Department__c, Arrival__c, ServiceResource__c, WorkCompletionTime__c, Is_Pending_Process__c, Is_Complete__c, Status, SchedEndTime
                FROM serviceAppointment 
                WHERE ParentRecordId = :saId 
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            System.debug('sa' + sa);
    
            Map<String, Object> newWOResultMap = (Map<String, Object>) JSON.deserializeUntyped(saveObject);
            System.debug('newWOResultMap:::'+newWOResultMap);
            WorkOrder wo = [
                SELECT Id, Status, CaseId, OrderType__c, FailurePhenomenonDetail__c, CauseOfFailureDetail__c, FM_WorkCompletionTime__c, FailureArea__c, FailureAreaGroup__c, FailurePhenomenon__c, 
                       CauseOfFailure__c, RepairAction__c, InspectionDetails__c, FailureAreaValue__c, FailureAreaGroupValue__c, FailurePhenomenonValue__c, CauseOfFailureValue__c, RepairActionValue__c, 
                       PendingOrCustomerMatters__c, ServiceOrderNumber__c
                FROM WorkOrder 
                WHERE Id = :sa.ParentRecordId 
                LIMIT 1
            ];
            System.debug('wo:::'+wo);
            // ServiceResource sr = [SELECT Id, CurrentStatus__c, Service_Territory__c, StaffNumber__c FROM ServiceResource WHERE Id = :sa.ServiceResource__c];
            System.debug('sr: ' + sr);
            Case ca = [
                SELECT Id, FailureArea__c, FailureAreaValue__c, FailureAreaDetail__c, FailureAreaDetailValue__c, FailurePhenomenon__c, FailurePhenomenonValue__c
                FROM Case 
                WHERE Id = :wo.CaseId 
                LIMIT 1
            ];
            
            // WorkOrderResult__c wor = [
            //     SELECT Id, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, WorkDate__c, WorkStartTime__c, WorkEndTime__c, WorkType__c, ResultType__c 
            //     FROM WorkOrderResult__c 
            //     WHERE ServiceAppointment__c = :sa.Id 
            //     ORDER BY CreatedDate DESC
            //     LIMIT 1
            // ];  
            if (sa.Is_Complete__c == true || wo.Status == 'Confirm') {
                System.debug('완료처리가 진행된 출동예약입니다.');
                return 'IS_COMPLETE_TRUE';
            }
    
            if (sa.Is_Pending_Process__c == true) {
                System.debug('미결처리가 진행된 출동예약입니다.');
                return 'IS_PENDING_PROCESS_TRUE';
            }
            
    
            Datetime dt = Datetime.now();
            System.debug('Arrival Time (User TimeZone): ' + dt);    
            Time tm = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
    
            // WorkCompletionTime__c 여기서 완료 보고한 시점으로 값을 넣어줌 250715
            sa.WorkCompletionTime__c = dt;
            sa.SchedEndTime = dt;
            if(!Test.isRunningTest()) {
                sa.Status = 'Completed';
                sa.Is_Complete__c = true;
            }
            update sa;
            // ServiceAppointment Update
            if (isDNSA) {
                Map<String, Object> failureAreaMajorMap = (Map<String, Object>) newWOResultMap.get('failureAreaMajor');
                ca.FailureArea__c = String.valueOf(failureAreaMajorMap.get('label')); // 고장부위
                ca.FailureAreaValue__c = String.valueOf(failureAreaMajorMap.get('value')); // 고장부위
                Map<String, Object> failureAreaMiddleMap = (Map<String, Object>) newWOResultMap.get('failureAreaMiddle');
                ca.FailureAreaDetail__c = String.valueOf(failureAreaMiddleMap.get('label')); // 고장부위 그룹
                ca.FailureAreaDetailValue__c = String.valueOf(failureAreaMiddleMap.get('value')); // 고장부위 그룹
                Map<String, Object> failurePhenomenonMap = (Map<String, Object>) newWOResultMap.get('failurePhenomenon');
                ca.FailurePhenomenon__c = String.valueOf(failurePhenomenonMap.get('label')); // 고장현상
                ca.FailurePhenomenonValue__c = String.valueOf(failurePhenomenonMap.get('value')); // 고장현상
                update ca;
            }
            // WorkOrder Update
            if (isDNSA) {
                wo.Status = 'Completed';
                wo.FM_WorkCompletionTime__c	 = dt; // 완료일시
                Map<String, Object> failureAreaMajorMap = (Map<String, Object>) newWOResultMap.get('failureAreaMajor');
                wo.FailureArea__c = String.valueOf(failureAreaMajorMap.get('label')); // 고장부위
                wo.FailureAreaValue__c = String.valueOf(failureAreaMajorMap.get('value')); // 고장부위
    
                Map<String, Object> failureAreaMiddleMap = (Map<String, Object>) newWOResultMap.get('failureAreaMiddle');
                wo.FailureAreaGroup__c = String.valueOf(failureAreaMiddleMap.get('label')); // 고장부위 그룹
                wo.FailureAreaGroupValue__c = String.valueOf(failureAreaMiddleMap.get('value')); // 고장부위 그룹
    
                Map<String, Object> failurePhenomenonMap = (Map<String, Object>) newWOResultMap.get('failurePhenomenon');
                wo.FailurePhenomenon__c = String.valueOf(failurePhenomenonMap.get('label')); // 고장현상
                wo.FailurePhenomenonValue__c = String.valueOf(failurePhenomenonMap.get('value')); // 고장현상
    
                Map<String, Object> failureCauseMap = (Map<String, Object>) newWOResultMap.get('failureCause');
                wo.CauseOfFailure__c = String.valueOf(failureCauseMap.get('label')); // 고장원인
                wo.CauseOfFailureValue__c = String.valueOf(failureCauseMap.get('value')); // 고장원인
                // wo.CauseOfFailure__c = String.valueOf(newWOResultMap.get('failureCause')); // 고장원인
    
                Map<String, Object> repairActionMap = (Map<String, Object>) newWOResultMap.get('repairAction');
                wo.RepairAction__c = String.valueOf(repairActionMap.get('label')); // 조치내역
                wo.RepairActionValue__c = String.valueOf(repairActionMap.get('value')); // 조치내역
                wo.PendingOrCustomerMatters__c = String.valueOf(newWOResultMap.get('pendingOrCustomerMatters')); // 조치내용
                wo.FailurePhenomenonDetail__c = String.valueOf(newWOResultMap.get('failurePhenomenonDetail')); // 고장부위/현상 상세
                wo.CauseOfFailureDetail__c = String.valueOf(newWOResultMap.get('causeOfFailureDetail')); // 고장원인 상세
                System.debug('wo:::' + wo);
                update wo;
            }
    
            // if (wo.OrderType__c == '104') {
            //     wor.WorkOrder__c = sa.ParentRecordId;
            //     wor.WorkEndTime__c = tm; // 도착
            //     System.debug('wor:::' + wor);
            //     update wor;
            // } else if (wor.WorkType__c == 'WK' && wor.ServiceAppointment__c == sa.Id) {
            //     wor.WorkOrder__c = sa.ParentRecordId;
            //     wor.ServiceAppointment__c = sa.Id; // ID
            //     wor.ServiceResource__c = sa.ServiceResource__c; // 작업자
            //     wor.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
            //     wor.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
            //     wor.WorkEndTime__c = tm; // 도착
            //     wor.WorkType__c = 'WK'; // 작업구분
            //     wor.ResultType__c = 'WH'; // 작업구분
            //     System.debug('wor:::' + wor);
            //     update wor;
            // } else {
            //     WorkOrderResult__c newWOResult = new WorkOrderResult__c();
            //     newWOResult.WorkOrder__c = sa.ParentRecordId;
    
            //     newWOResult.ServiceAppointment__c = sa.Id; // ID
            //     newWOResult.ServiceResource__c = sa.ServiceResource__c; // 작업자
            //     newWOResult.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
            //     newWOResult.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
            //     newWOResult.WorkEndTime__c = tm == null ? null : tm; // 도착
            //     newWOResult.WorkType__c = 'WK'; // 작업구분
            //     newWOResult.ResultType__c = 'WH'; // 작업구분
            //     System.debug('newWOResult:::' + newWOResult);
            //     insert newWOResult;
            // }

            // dnsa는 아직 workorderresult 확정 아님
            // WorkOrderResult__c newWOResult = new WorkOrderResult__c();
            // newWOResult.WorkOrder__c = sa.ParentRecordId;

            // newWOResult.ServiceAppointment__c = sa.Id; // ID
            // newWOResult.ServiceResource__c = sa.ServiceResource__c; // 작업자
            // newWOResult.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
            // newWOResult.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
            // newWOResult.WorkEndTime__c = tm == null ? null : tm; // 도착
            // newWOResult.WorkType__c = 'WK'; // 작업구분
            // newWOResult.ResultType__c = 'WH'; // 작업구분
            // System.debug('newWOResult:::' + newWOResult);
            // insert newWOResult;
            

            return 'SUCCESS';
        } else {
            Datetime completeTime = Datetime.now();
            // Map<String, Object> saveData = (Map<String, Object>) JSON.deserializeUntyped(saveObject);
            System.debug('saveObject:::' + saveObject);
            System.debug('saId' + saId);
            Id currentUserId = UserInfo.getUserId();
            ServiceResource sr = [SELECT Id, CurrentStatus__c, Service_Territory__c, StaffNumber__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
            serviceAppointment sa = [
                SELECT Id, WorkOrder__r.Id, ParentRecordId, WorkerType__c, Department__c, Arrival__c, ServiceResource__c, WorkCompletionTime__c, Is_Pending_Process__c, Is_Complete__c, Status 
                FROM serviceAppointment 
                WHERE ParentRecordId = :saId 
                AND ServiceResource__c = :sr.Id 
                AND Status NOT IN ('Canceled', 'Order Canceled')
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            System.debug('sa' + sa);
    
            Map<String, Object> newWOResultMap = (Map<String, Object>) JSON.deserializeUntyped(saveObject);
            System.debug('newWOResultMap:::'+newWOResultMap);
            WorkOrder wo = [
                SELECT Id, Status, CaseId, OrderType__c, FailurePhenomenonDetail__c, CauseOfFailureDetail__c, FM_WorkCompletionTime__c, FailureArea__c, FailureAreaGroup__c, FailurePhenomenon__c, 
                       CauseOfFailure__c, RepairAction__c, InspectionDetails__c, FailureAreaValue__c, FailureAreaGroupValue__c, FailurePhenomenonValue__c, CauseOfFailureValue__c, RepairActionValue__c, 
                       PendingOrCustomerMatters__c, ServiceOrderNumber__c
                FROM WorkOrder 
                WHERE Id = :sa.ParentRecordId 
                LIMIT 1
            ];
            System.debug('wo:::'+wo);
            // ServiceResource sr = [SELECT Id, CurrentStatus__c, Service_Territory__c, StaffNumber__c FROM ServiceResource WHERE Id = :sa.ServiceResource__c];
            System.debug('sr: ' + sr);
            Case ca = [
                SELECT Id, FailureArea__c, FailureAreaValue__c, FailureAreaDetail__c, FailureAreaDetailValue__c, FailurePhenomenon__c, FailurePhenomenonValue__c
                FROM Case 
                WHERE Id = :wo.CaseId 
                LIMIT 1
            ];
            
            WorkOrderResult__c wor = [
                SELECT Id, WorkOrder__c, ServiceAppointment__c, ServiceResource__c, WorkDate__c, WorkStartTime__c, WorkEndTime__c, WorkType__c, ResultType__c 
                FROM WorkOrderResult__c 
                WHERE ServiceAppointment__c = :sa.Id 
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];  
            if (sa.Is_Complete__c == true || wo.Status == 'Confirm') {
                System.debug('완료처리가 진행된 출동예약입니다.');
                return 'IS_COMPLETE_TRUE';
            }
    
            if (sa.Is_Pending_Process__c == true) {
                System.debug('미결처리가 진행된 출동예약입니다.');
                return 'IS_PENDING_PROCESS_TRUE';
            }
            
    
            Datetime dt = Datetime.now();
            System.debug('Arrival Time (User TimeZone): ' + dt);    
            Time tm = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
    
            sa.WorkCompletionTime__c = dt;
            if(!Test.isRunningTest()) {
                sa.Status = 'Completed';
                sa.Is_Complete__c = true;
            }
            update sa;
            // ServiceAppointment Update
            if (sa.WorkerType__c == 'Service Resource (Main)') {
                Map<String, Object> failureAreaMajorMap = (Map<String, Object>) newWOResultMap.get('failureAreaMajor');
                ca.FailureArea__c = String.valueOf(failureAreaMajorMap.get('label')); // 고장부위
                ca.FailureAreaValue__c = String.valueOf(failureAreaMajorMap.get('value')); // 고장부위
                Map<String, Object> failureAreaMiddleMap = (Map<String, Object>) newWOResultMap.get('failureAreaMiddle');
                ca.FailureAreaDetail__c = String.valueOf(failureAreaMiddleMap.get('label')); // 고장부위 그룹
                ca.FailureAreaDetailValue__c = String.valueOf(failureAreaMiddleMap.get('value')); // 고장부위 그룹
                Map<String, Object> failurePhenomenonMap = (Map<String, Object>) newWOResultMap.get('failurePhenomenon');
                ca.FailurePhenomenon__c = String.valueOf(failurePhenomenonMap.get('label')); // 고장현상
                ca.FailurePhenomenonValue__c = String.valueOf(failurePhenomenonMap.get('value')); // 고장현상
                update ca;
            }
            // WorkOrder Update
            if (sa.WorkerType__c == 'Service Resource (Main)') {
                wo.Status = 'Completed';
                wo.FM_WorkCompletionTime__c	 = dt; // 완료일시
                Map<String, Object> failureAreaMajorMap = (Map<String, Object>) newWOResultMap.get('failureAreaMajor');
                wo.FailureArea__c = String.valueOf(failureAreaMajorMap.get('label')); // 고장부위
                wo.FailureAreaValue__c = String.valueOf(failureAreaMajorMap.get('value')); // 고장부위
    
                Map<String, Object> failureAreaMiddleMap = (Map<String, Object>) newWOResultMap.get('failureAreaMiddle');
                wo.FailureAreaGroup__c = String.valueOf(failureAreaMiddleMap.get('label')); // 고장부위 그룹
                wo.FailureAreaGroupValue__c = String.valueOf(failureAreaMiddleMap.get('value')); // 고장부위 그룹
    
                Map<String, Object> failurePhenomenonMap = (Map<String, Object>) newWOResultMap.get('failurePhenomenon');
                wo.FailurePhenomenon__c = String.valueOf(failurePhenomenonMap.get('label')); // 고장현상
                wo.FailurePhenomenonValue__c = String.valueOf(failurePhenomenonMap.get('value')); // 고장현상
    
                Map<String, Object> failureCauseMap = (Map<String, Object>) newWOResultMap.get('failureCause');
                wo.CauseOfFailure__c = String.valueOf(failureCauseMap.get('label')); // 고장원인
                wo.CauseOfFailureValue__c = String.valueOf(failureCauseMap.get('value')); // 고장원인
                // wo.CauseOfFailure__c = String.valueOf(newWOResultMap.get('failureCause')); // 고장원인
    
                Map<String, Object> repairActionMap = (Map<String, Object>) newWOResultMap.get('repairAction');
                wo.RepairAction__c = String.valueOf(repairActionMap.get('label')); // 조치내역
                wo.RepairActionValue__c = String.valueOf(repairActionMap.get('value')); // 조치내역
                // wo.RepairAction__c = String.valueOf(newWOResultMap.get('repairAction')); // 조치내역
    
                // Map<String, Object> objMap6 = (Map<String, Object>) newWOResultMap.get('pendingOrCustomerMatters');
                // wo.InspectionDetails__c = String.valueOf(objMap6.get('label')); // 조치내용
                wo.PendingOrCustomerMatters__c = String.valueOf(newWOResultMap.get('pendingOrCustomerMatters')); // 조치내용
                // wo.InspectionDetails__c = String.valueOf(newWOResultMap.get('inspectionDetails')); // 조치내용
                
                // Map<String, Object> objMap7 = (Map<String, Object>) newWOResultMap.get('failurePhenomenonDetail');
                // wo.FailurePhenomenonDetail__c = String.valueOf(objMap7.get('label')); // 고장부위/현상 상세
                wo.FailurePhenomenonDetail__c = String.valueOf(newWOResultMap.get('failurePhenomenonDetail')); // 고장부위/현상 상세
                
                // Map<String, Object> objMap8 = (Map<String, Object>) newWOResultMap.get('causeOfFailureDetail');
                // wo.CauseOfFailureDetail__c = String.valueOf(objMap8.get('label')); // 고장원인 상세
                wo.CauseOfFailureDetail__c = String.valueOf(newWOResultMap.get('causeOfFailureDetail')); // 고장원인 상세
                System.debug('wo:::' + wo);
                update wo;
            }
    
            if (wo.OrderType__c == '104') {
                // WorkOrderResult__c wor = [SELECT Id, ServiceAppointment__c, WorkEndTime__c, WorkType__c FROM WorkOrderResult__c WHERE ServiceAppointment__c = :sa.Id LIMIT 1];
                wor.WorkOrder__c = sa.ParentRecordId;
                // Map<String, Object> failureAreaMajorMap = (Map<String, Object>) newWOResultMap.get('failureAreaMajor');
                // wor.FailureArea__c = String.valueOf(failureAreaMajorMap.get('value')); // 고장부위
    
                // Map<String, Object> failureAreaMiddleMap = (Map<String, Object>) newWOResultMap.get('failureAreaMiddle');
                // wor.FailureAreaGroup__c = String.valueOf(failureAreaMiddleMap.get('value')); // 고장부위 그룹
    
                // Map<String, Object> failurePhenomenonMap = (Map<String, Object>) newWOResultMap.get('failurePhenomenon');
                // wor.FailurePhenomenon__c = String.valueOf(failurePhenomenonMap.get('value')); // 고장현상
    
                // Map<String, Object> failureCauseMap = (Map<String, Object>) newWOResultMap.get('failureCause');
                // wor.CauseOfFailure__c = String.valueOf(failureCauseMap.get('value')); // 고장원인
                // // wo.CauseOfFailure__c = String.valueOf(newWOResultMap.get('failureCause')); // 고장원인
    
                // Map<String, Object> repairActionMap = (Map<String, Object>) newWOResultMap.get('repairAction');
                // wor.RepairAction__c = String.valueOf(repairActionMap.get('value')); // 조치내역
                // // wor.FailureArea__c = String.valueOf(newWOResultMap.get('failureAreaMajor')); // 고장부위
                // // wor.FailureAreaGroup__c = String.valueOf(newWOResultMap.get('failureAreaMiddle')); // 고장부위 그룹
                // // wor.FailurePhenomenon__c = String.valueOf(newWOResultMap.get('failurePhenomenon')); // 고장현상
                // // wor.CauseOfFailure__c = String.valueOf(newWOResultMap.get('failureCause')); // 고장원인
                // // wor.RepairAction__c = String.valueOf(newWOResultMap.get('repairAction')); // 조치내역
                // wor.PendingOrCustomerMatters__c = String.valueOf(newWOResultMap.get('pendingOrCustomerMatters')); // 조치내용
                // wor.FailurePhenomenonDetail__c = String.valueOf(newWOResultMap.get('failurePhenomenonDetail')); // 고장부위/현상 상세
                // wor.CauseOfFailureDetail__c = String.valueOf(newWOResultMap.get('causeOfFailureDetail')); // 고장원인 상세
    
                wor.WorkEndTime__c = tm; // 도착
                System.debug('wor:::' + wor);
                update wor;
            }else if (wor.WorkType__c == 'WK' && wor.ServiceAppointment__c == sa.Id) {
                wor.WorkOrder__c = sa.ParentRecordId;
                wor.ServiceAppointment__c = sa.Id; // ID
                wor.ServiceResource__c = sa.ServiceResource__c; // 작업자
                wor.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
                wor.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
                wor.WorkEndTime__c = tm; // 도착
                wor.WorkType__c = 'WK'; // 작업구분
                wor.ResultType__c = 'WH'; // 작업구분
                System.debug('wor:::' + wor);
                update wor;
            } else {
                WorkOrderResult__c newWOResult = new WorkOrderResult__c();
                newWOResult.WorkOrder__c = sa.ParentRecordId;
    
                newWOResult.ServiceAppointment__c = sa.Id; // ID
                newWOResult.ServiceResource__c = sa.ServiceResource__c; // 작업자
                newWOResult.WorkDate__c = Date.newInstance(dt.year(), dt.month(), dt.day()); // 작업일
                newWOResult.WorkStartTime__c = sa.Arrival__c == null ? null : sa.Arrival__c.Time(); // 출발
                newWOResult.WorkEndTime__c = tm == null ? null : tm; // 도착
                newWOResult.WorkType__c = 'WK'; // 작업구분
                newWOResult.ResultType__c = 'WH'; // 작업구분
                System.debug('newWOResult:::' + newWOResult);
                insert newWOResult;
                
            }
            
            DN_ModelManagerController.updateCompletIF(
                wo.ServiceOrderNumber__c, sr.StaffNumber__c, 
                String.valueOf(sa.Department__c == null ? null : sa.Department__c.Date()), String.valueOf(sa.Department__c == null ? null : sa.Department__c.Time()),   // 출발
                String.valueOf(sa.Arrival__c == null ? null : sa.Arrival__c.Date()), String.valueOf(sa.Arrival__c == null ? null : sa.Arrival__c.Time()),               // 도착
                String.valueOf(completeTime.Date()), String.valueOf(completeTime.Time())                                                                                // 완료
                );
            return 'SUCCESS';
        }
    }

    // 완료시간 업데이트
    @Future(callout=true)
    public static void updateCompletIF(String serviceOrderNumber, String staffNumber, String msdd, String msdz, String isdd, String isdz, String iedd, String iedz) {
        List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST> t_i_list = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST>();
    
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST item = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req_T_I_LIST();
        item.AUFNR = serviceOrderNumber;
        item.PERNR = staffNumber;
        item.MSDD = msdd == null ? null : msdd; // 출발 날짜
        item.MSDZ = msdz == null ? null : msdz; // 출발 시간
        item.ISDD = isdd == null ? null : isdd; // 도착 날짜
        item.ISDZ = isdz == null ? null : isdz; // 도착 시간
        item.IEDD = iedd;                       // 완료 날짜
        item.IEDZ = iedz;                       // 완료 시간
    
        // 완료시간 - 도착시간 = 작업시간 계산
        Decimal LTXA1 = calculateLTXA1(isdd, isdz, iedd, iedz);
        item.LTXA1 = String.valueOf(LTXA1); // 작업시간

        // 소수점 반올림 후 정수로 표시 - 작업시간
        // Decimal roundedValue = LTXA1.setScale(0, RoundingMode.HALF_UP);

        // // 항상 .0 형식으로 표시 7.6 -> 8.0
        // item.LTXA1 = String.format('{0,number,#}.0', new Object[]{roundedValue});
    
        t_i_list.add(item);
    
        IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req request = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_028_Req();
        request.T_I_LIST = t_i_list;
    
        IF_ERP_WorkOrder method = new IF_ERP_WorkOrder();
        method.IF_CSPLUS_028(request);
    }
    
    // 완료시간 - 도착시간
    public static Decimal calculateLTXA1(String startDate, String startTime, String endDate, String endTime) {
        if (String.isEmpty(startDate) || String.isEmpty(startTime) || String.isEmpty(endDate) || String.isEmpty(endTime)) {
            System.debug('완료 작업만 진행');
            return 0; // 완료만 진행했을 경우 0
        }

        try {
            // Date와 Time 결합하여 DateTime 생성
            Date startDt = Date.valueOf(startDate);
            Date endDt = Date.valueOf(endDate);

            Time startT = parseTime(startTime);
            Time endT = parseTime(endTime);

            DateTime workStart = DateTime.newInstance(startDt, startT);
            DateTime workEnd = DateTime.newInstance(endDt, endT);

            System.debug('workStart:::' + workStart);
            System.debug('workEnd:::' + workEnd);

            // Math.abs 절대값 지정
            Decimal workHour = Math.abs(workEnd.getTime() - workStart.getTime()) / (60 * 60 * 1000.0);
            System.debug('workHour:::' + workHour);

            // 반올림 
            return workHour.setScale(1, RoundingMode.HALF_UP);
        } catch (Exception e) {
            System.debug('시간 계산 오류: ' + e.getMessage());
            return 0;
        }
    }
    // Time변환 메서드, 정리
    public static Time parseTime(String timeStr) {
        try {
            // Z나 소수점 제거
            if (timeStr.contains('.')) {
                timeStr = timeStr.split('\\.')[0]; // 소수점 이후 제거
            }
            if (timeStr.endsWith('Z')) {
                timeStr = timeStr.substring(0, timeStr.length() - 1); // Z 제거 |startTime|"15:55:28.000Z" -> 15:55:28
            }
    
            // HH:mm 또는 HH:mm:ss 형태로 분리
            List<String> parts = timeStr.split(':');
            Integer hours = Integer.valueOf(parts[0]);
            Integer minutes = Integer.valueOf(parts[1]);
            Integer seconds = parts.size() > 2 ? Integer.valueOf(parts[2]) : 0;
    
            return Time.newInstance(hours, minutes, seconds, 0);
        } catch (Exception e) {
            System.debug('Time 변환 오류: ' + e.getMessage());
            throw new IllegalArgumentException('잘못된 시간 형식: ' + timeStr);
        }
    }
}