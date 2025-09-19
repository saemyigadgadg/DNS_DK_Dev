/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public without sharing class DN_WorkOrderRejectionController {
    // 배정거절을 생성하는 메서드
    @AuraEnabled
    public static Map<String, Object> createAssignReject(String workOrderId, String rejectionReason) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('isSuccess', false);
        

        try {
            Id profileId = UserInfo.getProfileId();

            String profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
            System.debug('Profile Name: ' + profileName);
            
            Id currentUserId = UserInfo.getUserId();
            System.debug('currentUserId:::' + currentUserId);
            
            // WorkOrder 레코드 가져오기
            WorkOrder wo = [
                SELECT Id, Worker__c, Worker__r.Name, WorkOrderNumber, ServiceTerritoryId, Status, Worker__r.RelatedRecordId, OwnerId, Case.OwnerId, CaseId
                FROM WorkOrder
                WHERE Id = :workOrderId
                LIMIT 1
            ];
            System.debug('wo:::'+wo);
            
            if (wo.Status != 'Assigned') {
                System.debug('배정거절은 WorkOrder가 배정 상태일 때만 가능합니다:::');
                response.put('errorMessage', '배정거절은 WorkOrder가 배정 상태일 때만 가능합니다.');
                return response;
            }

            
            List<ServiceAppointment> saList = [
                SELECT Id, ServiceResource__c, ServiceResource__r.RelatedRecordId, WorkerType__c, Status
                FROM ServiceAppointment
                WHERE ServiceResource__r.RelatedRecordId = :currentUserId
                AND WorkerType__c = 'Service Resource (Main)' 
                AND Status = 'Assigned' // SA 상태값 변경됨 수정
                // AND Status NOT IN ('Canceled', 'Completed', 'Uncompleted') // SA 상태값 변경됨 수정
                AND ParentRecordId = :wo.Id
                LIMIT 1
                ];
            System.debug('saList:::'+saList);
            
            if (saList.isEmpty() || saList[0].Status != 'Assigned') {
                System.debug('배정거절은 서비스요원이 배정 상태일 때만 가능합니다.:::');
                response.put('errorMessage', '배정거절은 서비스요원이 배정 상태일 때만 가능합니다.');
                return response;
            }
            if (saList.isEmpty() || saList[0].WorkerType__c != 'Service Resource (Main)') {
                System.debug('작업자의 유형이 메인 작업자가 아닙니다.:::');
                response.put('errorMessage', '작업자의 유형이 메인 작업자가 아닙니다.');
                return response;
            }

            if(!Test.isRunningTest()) {
                // 배정거절이 SA 상태 취소로 변경
                saList[0].Status = 'Canceled';
                update saList[0];
            }

            // ServiceResource의 CurrentStatus__c가 Work 상태인지 확인
            // ServiceResource sr = [SELECT Id, CurrentStatus__c FROM ServiceResource WHERE Id = :wo.Worker__c LIMIT 1];
            // if (sr.CurrentStatus__c != 'Work') {
            //     response.put('errorMessage', '서비스요원의 현재 상태가 작업이 아닙니다.');
            //     return response;
            // }

            
            // 현재 사용자와 담당자가 일치하는지 확인
            // if (wo.Worker__r.RelatedRecordId != UserInfo.getUserId()) {
            //     response.put('errorMessage', '현재 사용자와 담당자가 일치하지 않습니다.');
            //     return response;
            // }

            // AssignReject__c 레코드 생성
            AssignReject__c newAssignReject = new AssignReject__c();
            newAssignReject.Work_Order__c = workOrderId;
            newAssignReject.AssignReject__c = rejectionReason;
            newAssignReject.Worker__c = wo.Worker__c;
            // newAssignReject.Name = wo.Worker__r.Name;
            // 2024.11.14 잠깐 주석
            // newAssignReject.WorkCenter__c = wo.ServiceTerritoryId;
            insert newAssignReject;

            // WorkOrder 상태 업데이트
            wo.Status = 'AssignedRefused';
            update wo;
            
            List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();
            List<AlertManager__c> alertManagerIDList = [
                SELECT Id FROM AlertManager__c WHERE Name = 'CS Assignment Rejection Noti' LIMIT 1
            ];
            System.debug('AlertManagerID ::: ' + alertManagerIDList[0].Id);


            Set<Id> mobileUserIds = new Set<Id>();
            // List<User> userList = [SELECT Id FROM User WHERE Profile.Name = 'Partner Community User (CS)' AND IsActive = true];
            // for(User user : userList) {
            //     mobileUserIds.add(user.Id);
            // }
            // 하수헌 유저 아이디
            // mobileUserIds.add('005F7000006DOYwIAO');

            if(wo.Status == 'AssignedRefused') {
                UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
                hw.alertID = alertManagerIDList[0].Id;
                hw.targetID = wo.Id;
                hw.alertType = 'Notification';
                hw.alertLanguage = 'ko';
                // hw.elementList.add(wo.WorkOrderNumber);
                hw.elementList.add(wo.Worker__r.Name);
                hw.title = '배정거절이 요청이 왔습니다. Work Order:' + wo.WorkOrderNumber;
                hw.receiverforID = new Set<Id>{wo.Case.OwnerId};
                // hw.receiverforID = mobileUserIds;
                System.debug('hw : '+hw);
                hwList.add(hw);
            }
            
            System.debug('hwList : '+hwList);
            if (!hwList.isEmpty()) {
                UTIL_Alert.runAlertEvent(hwList);
                System.debug('배정거절노티');
            }
            
            response.put('isSuccess', true);
            response.put('message', '배정거절이 성공적으로 저장되었습니다.');
        } catch (Exception e) {
            response.put('errorMessage', 'Error: ' + e.getMessage());
        }


        return response;
    }
}