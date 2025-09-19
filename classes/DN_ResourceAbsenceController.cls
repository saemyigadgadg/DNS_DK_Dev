/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public without sharing class DN_ResourceAbsenceController {
    // 현재 사용자와 동일한 서비스요원 조회
    @AuraEnabled
    public static void updateSRStatus(String workOrderId, String status) {    
        Id currentUserId = UserInfo.getUserId();
        List<ServiceResource> srList = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
        
        if (!srList.isEmpty()) {
            ServiceResource sr = srList[0];
            sr.CurrentStatus__c = status;
            update sr;
        } else {
            throw new AuraHandledException('현재 사용자와 관련 ServiceResource가 없습니다.');
        }
    }
    // 서비스요원 상태를 변경하는 메서
    @AuraEnabled
    public static String changeStatus(String recordId) {
        System.debug('recordId:::' + recordId);
        try {
            WorkOrder wo = [
                SELECT Id, Status, ActualDispatchTime__c, Arrival__c, OrderType__c, ServiceOrderNumber__c 
                FROM WorkOrder 
                WHERE Id = :recordId
            ];

            List<ServiceAppointment> saList = [
                SELECT Id, Status, ParentRecordId
                FROM ServiceAppointment
                WHERE ParentRecordId = :recordId
            ];

            wo.Status = 'Confirm';
            update wo;

            List<ServiceAppointment> updateList = new List<ServiceAppointment>();
            for (ServiceAppointment sa : saList) {
                if (sa.Status != 'Uncompleted') {
                    sa.Status = 'Completed';
                    updateList.add(sa);
                }
            }

            if (!updateList.isEmpty()) {
                update updateList;
            }

            System.debug('Status 변경 성공 wo:::' + wo + ' sa:::' + updateList);
            return 'SUCCESS';

        } catch (Exception e) {
            System.debug('오류 발생 :::' + e.getMessage());
            return 'ERROR: ' + e.getMessage();
        }
    }

    // 서비스요원 상태를 조회하는 메서드
    @AuraEnabled
    public static String getSRStatus(String workOrderId) {
        Id currentUserId = UserInfo.getUserId();
        ServiceResource sr = [SELECT Id, CurrentStatus__c, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId = :currentUserId LIMIT 1];
        return sr.CurrentStatus__c;

    }
}