/**
 * @description       : ContentDocumentLink Trigger Handler
 * @author           : SeJin, Kwon
 * @last modified on : 2025-07-30
 * @last modified by : suheon.ha
 * 
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   2024-07-25   SeJin, Kwon       Initial Version
 * 1.0   2024-07-31   Hanyeong Choi     updateBoardVisibility() 추가
 * 1.0   2024-09-25   suheon ha         createDistribution() 추가
 * 1.0   2024-11-11   suheon ha         updateCaseFile() 추가
 * 1.1   2025-07-30   ChatGPT           최적화 및 배포 가능한 코드 리팩토링
**/
public without sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler {

    public override void onAfterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
        if (!isExecuting || newList.isEmpty()) return;

        System.debug('ContentDocumentLink AFTER_INSERT Trigger Start');

        List<ContentDocumentLink> newLinks = (List<ContentDocumentLink>) newList;
        Set<Id> linkedEntityIds = new Set<Id>();
        Set<Id> contentDocIds = new Set<Id>();
        List<ContentDocumentLink> caseLinks = new List<ContentDocumentLink>();
        Set<Id> distributionDocIds = new Set<Id>();
        List<String> distributionTargetObjs = new List<String>{ 'DeliveryOrder__c' };

        // 사용자 프로필 조회 1회
        String userProfileName = [
            SELECT Profile.Name 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ].Profile.Name;

        // 신규 링크 분류
        for (ContentDocumentLink cdl : newLinks) {
            if (cdl.LinkedEntityId == null || cdl.ContentDocumentId == null) continue;

            linkedEntityIds.add(cdl.LinkedEntityId);
            String objName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();

            // Case 또는 EmailMessage 또는 서비스센터 프로필이면 Case 처리 대상
            if (objName == 'Case' || objName == 'EmailMessage' || userProfileName == '서비스센터 프로필') {
                caseLinks.add(cdl);
            }

            // Board / Model / PS → 배포 및 공유 대상
            if (objName == 'Board__c' || objName == 'Model__c' || objName == 'PS__c') {
                contentDocIds.add(cdl.ContentDocumentId);
            }

            // 배포 대상 객체
            if (distributionTargetObjs.contains(objName)) {
                distributionDocIds.add(cdl.ContentDocumentId);
            }
        }

        // Case 파일 수 업데이트
        if (!caseLinks.isEmpty()) {
            updateCaseFileCount(caseLinks);
        }

        // 서비스센터 프로필이 아닌 경우 공유 타입 업데이트
        if (userProfileName != '서비스센터 프로필') {
            boardShareType(newLinks);
        }

        // ContentDistribution 생성
        Set<Id> allDistributionDocs = new Set<Id>();
        allDistributionDocs.addAll(contentDocIds);
        allDistributionDocs.addAll(distributionDocIds);
        if (!allDistributionDocs.isEmpty()) {
            createDistribution(allDistributionDocs);
        }

        // Model__c → ContentVersion 연계 업데이트
        if (!linkedEntityIds.isEmpty() && !contentDocIds.isEmpty()) {
            List<Model__c> modelList = [
                SELECT Id 
                FROM Model__c 
                WHERE Id IN :linkedEntityIds
            ];
            if (!modelList.isEmpty()) {
                updateModelWithContent(modelList[0].Id, contentDocIds);
            }
        }

        setting(false, TriggerOperation.AFTER_INSERT);
        System.debug('ContentDocumentLink AFTER_INSERT Trigger End');
    }

    // -------------------------------
    // Model__c와 ContentVersion 연계 업데이트
    // -------------------------------
    private static void updateModelWithContent(Id modelId, Set<Id> contentDocIds) {
        if (modelId == null || contentDocIds.isEmpty()) return;

        // 첫 번째 ContentDocumentLink → Visibility AllUsers로 변경
        List<ContentDocumentLink> cdLinks = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :modelId 
            LIMIT 1
        ];
        if (!cdLinks.isEmpty()) {
            ContentDocumentLink updateCdl = new ContentDocumentLink(
                Id = cdLinks[0].Id,
                Visibility = 'AllUsers'
            );
            update updateCdl;
        }

        // 첫 번째 ContentVersion → Model__c.contentVersionId__c 업데이트
        List<ContentVersion> cvList = [
            SELECT Id 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentDocIds
            LIMIT 1
        ];
        if (!cvList.isEmpty()) {
            update new Model__c(
                Id = modelId,
                contentVersionId__c = cvList[0].Id
            );
        }
    }

    // -------------------------------
    // ContentDocumentLink ShareType = 'V' & Visibility = AllUsers
    // -------------------------------
    private static void boardShareType(List<ContentDocumentLink> links) {
        List<ContentDocumentLink> toUpdate = new List<ContentDocumentLink>();

        for (ContentDocumentLink cdl : links) {
            if (cdl.LinkedEntityId == null) continue;

            String objName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
            if (objName == 'Board__c' || objName == 'LaunchingExcellenceDoc__c' ||
                objName == 'WorkOrder' || objName == 'Case' || objName == 'PS__c') {
                toUpdate.add(new ContentDocumentLink(
                    Id = cdl.Id,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                ));
            }
        }

        if (!toUpdate.isEmpty()) {
            try {
                update toUpdate;
                System.debug('Updated ContentDocumentLink records: ' + toUpdate.size());
            } catch (DmlException e) {
                System.debug('Error updating ContentDocumentLink: ' + e.getMessage());
            }
        }
    }

    // -------------------------------
    // ContentDistribution 생성
    // -------------------------------
    private static void createDistribution(Set<Id> contentDocIds) {
        if (contentDocIds.isEmpty()) return;

        List<ContentVersion> cvList = [
            SELECT Id, ContentDocumentId, PathOnClient
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocIds
        ];

        List<ContentDistribution> toInsert = new List<ContentDistribution>();
        for (ContentVersion cv : cvList) {
            toInsert.add(new ContentDistribution(
                Name = cv.PathOnClient,
                ContentVersionId = cv.Id,
                PreferencesNotifyOnVisit = false,
                PreferencesAllowViewInBrowser = true,
                PreferencesExpires = true,
                ExpiryDate = System.now().addYears(100)
            ));
        }

        if (!toInsert.isEmpty()) {
            try {
                insert toInsert;
                System.debug('ContentDistribution created: ' + toInsert.size());
            } catch (DmlException e) {
                System.debug('Error creating ContentDistribution: ' + e.getMessage());
            }
        }
    }

    // -------------------------------
    // Case 파일 수 업데이트
    // -------------------------------
    private static void updateCaseFileCount(List<ContentDocumentLink> links) {
        Map<Id, Decimal> caseFileCountMap = new Map<Id, Decimal>();
        Set<Id> emailMsgIds = new Set<Id>();

        for (ContentDocumentLink cdl : links) {
            if (cdl.LinkedEntityId == null) continue;

            SObjectType objType = cdl.LinkedEntityId.getSObjectType();
            if (objType == Case.SObjectType) {
                caseFileCountMap.put(cdl.LinkedEntityId, caseFileCountMap.get(cdl.LinkedEntityId) + 1);
            } else if (objType == EmailMessage.SObjectType) {
                emailMsgIds.add(cdl.LinkedEntityId);
            }
        }

        // EmailMessage → Case 매핑
        if (!emailMsgIds.isEmpty()) {
            for (EmailMessage em : [
                SELECT Id, ParentId 
                FROM EmailMessage 
                WHERE Id IN :emailMsgIds
            ]) {
                if (em.ParentId != null && em.ParentId.getSObjectType() == Case.SObjectType) {
                    caseFileCountMap.put(em.ParentId, caseFileCountMap.get(em.ParentId) + 1);
                }
            }
        }

        if (!caseFileCountMap.isEmpty()) {
            List<Case> toUpdate = [
                SELECT Id, FileCount__c 
                FROM Case 
                WHERE Id IN :caseFileCountMap.keySet()
            ];
            for (Case c : toUpdate) {
                Decimal currentCount = (c.FileCount__c == null) ? 0 : c.FileCount__c;
                c.FileCount__c = currentCount + caseFileCountMap.get(c.Id);
            }
            try {
                update toUpdate;
                System.debug('Updated Case FileCount__c: ' + toUpdate.size());
            } catch (DmlException e) {
                System.debug('Error updating Case: ' + e.getMessage());
            }
        }
    }
}