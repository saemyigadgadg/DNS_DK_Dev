/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class ResourceAbsenceTriggerHandler extends TriggerHandler {

    public override void onBeforeInsert(List<sObject> news){
        if(isExecuting) {
            List<ResourceAbsence> absenceList = (List<ResourceAbsence>) news;
            System.debug('Absence List Insert: ' + absenceList);
            
            //updateField(absenceList);
            checkAbsences(absenceList);
        }
    }

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting) {
            List<ResourceAbsence> absenceList = (List<ResourceAbsence>) news;
            System.debug('Absence List Update: ' + absenceList);

            // Type 변경 시 Start = 현재 시간 업데이트 End = Start + 1시간 업데이트 
            // for (ResourceAbsence newAbsence : absenceList) {
            //     ResourceAbsence oldAbsence = (ResourceAbsence) oldMap.get (newAbsence.Id);

            //     if (newAbsence.Type != oldAbsence.Type) {
            //         System.debug('Type field change: ' + newAbsence.Id);

            //         DateTime currentTime = System.now();
            //         newAbsence.Start = currentTime;
            //         newAbsence.End = currentTime.addHours(1);

            //         // 화긴
            //         System.debug('Updated Start: ' + newAbsence.Start + ', End: ' + newAbsence.End);
            //     }
            // }

            //updateField(absenceList);
            checkAbsences(absenceList);
        }
    }

    // 중복된 ResourceAbsence 레코드가 있는지 확인하는 메소드
    private void checkAbsences(List<ResourceAbsence> absenceList) {
        Set<Id> resourceIds = new Set<Id>();

        // 새로 들어오는 레코드들의 ResourceId 수집
        for (ResourceAbsence absence : absenceList) {
            resourceIds.add(absence.ResourceId);
        }

        System.debug('Resource ID: ' + resourceIds);

        // 해당 ResourceId들에 대한 기존 ResourceAbsence 레코드 조회
        List<ResourceAbsence> existingAbsences = [
            SELECT Id, ResourceId, Start, End 
            FROM ResourceAbsence 
            WHERE ResourceId IN :resourceIds
        ];

        System.debug('Existing Absences: ' + existingAbsences);

        // 중복 확인 로직
        for (ResourceAbsence newAbsence : absenceList) {
            for (ResourceAbsence existingAbsence : existingAbsences) {
                // 자신과는 비교하지 않도록 함 (업데이트의 경우)
                if (newAbsence.Id == existingAbsence.Id) {
                    continue;
                }

                System.debug('Comparing Absences - New: ' + newAbsence + ', Existing: ' + existingAbsence);

                // 중복되는 기간 확인 (Start와 End가 겹치는지 확인)
                if (newAbsence.ResourceId == existingAbsence.ResourceId &&
                    (newAbsence.Start <= existingAbsence.End && newAbsence.End >= existingAbsence.Start)) {
                    System.debug('중복시간 - 신규 부재: ' + newAbsence + ', 기존 부재: ' + existingAbsence);
                    newAbsence.addError('해당 일자 및 시간에 이미 생성된 일정이 있습니다. 기존 일정을 편집해 주세요.');
                }
            }
        }
    }

    // Lookup필드를 입력하면 -> Text필드로 라벨값 입력
    /*private void updateField(List<ResourceAbsence> absenceList) {
        Set<Id> equipmentIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for (ResourceAbsence absence : absenceList) {
            if (absence.Equipment__c != null) {
                equipmentIds.add(absence.Equipment__c);
            }
            if (absence.AccountName__c != null) {
                accountIds.add(absence.AccountName__c);
            }
        }

        Map<Id, Asset> equipmentMap = new Map<Id, Asset>(
            [SELECT Id, Name FROM Asset WHERE Id IN :equipmentIds]
        );

        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
        );

        for (ResourceAbsence absence : absenceList) {
            if (absence.Equipment__c != null && equipmentMap.containsKey(absence.Equipment__c)) {
                absence.EquipmentText__c = equipmentMap.get(absence.Equipment__c).Name;
            } else {
                absence.EquipmentText__c = null;
            }

            if (absence.AccountName__c != null && accountMap.containsKey(absence.AccountName__c)) {
                absence.AccountNameText__c = accountMap.get(absence.AccountName__c).Name;
            } else {
                absence.AccountNameText__c = null;
            }
        }
    }*/
}