/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-17
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   2024-11-12   yeongdeok.seo   Initial Version
 * 1.1   2024-12-30   yeongju.yun     Before Insert - Type에 따라 Title prefix추가
**/
public with sharing class ContentVersionTriggerHandler extends TriggerHandler{
    
    /**
    * @description FileType에 따라 파일명에 Prefix 추가
    **/
    public override void onBeforeInsert(List<sObject> news) {
        if (isExecuting) {
            System.debug('ContentVersion BEFORE_INSERT TRIGGER Start');

            List<ContentVersion> cvList = (List<ContentVersion>) news;
            for(ContentVersion cv : cvList) {
                if(cv.FileType__c == 'bizReg' && !cv.Title.startsWith('ZSY__')) { cv.Title =  'ZSY__' + cv.Title; } 
                else if(cv.FileType__c == 'map' && !cv.Title.startsWith('ZMP__')) { cv.Title =  'ZMP__' + cv.Title; } 
                else if(cv.FileType__c == 'bond' && !cv.Title.startsWith('ZBD__')) { cv.Title =  'ZBD__' + cv.Title; }
            }

            System.debug('ContentVersion BEFORE_INSERT TRIGGER End');
        }
    }

    //public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
    //   if (isExecuting && !Test.isRunningTest()) {
    //    List<Id> cvIds = new List<Id>();
    //    for (sObject s : news) {
    //        cvIds.add(((ContentVersion)s).Id);
    //        System.debug('@@ cvIds : ' + cvIds);
    //    }
           
    //    System.enqueueJob(new ContentVersionProcessor(cvIds));
           
    //	}
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
        if (isExecuting) {
            // ContentVersion 리스트로 캐스팅
            List<ContentVersion> cvList = (List<ContentVersion>)news;
            List<DN_RFQFileSend.RFQFileRequest> fileRequests = new List<DN_RFQFileSend.RFQFileRequest>();
            Set<Id> psIds = new Set<Id>();
            Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>();
    
            // PS ID와 ContentVersion 매핑
            for (ContentVersion cv : cvList) {
                if (cv.FirstPublishLocationId != null) {
                    psIds.add(cv.FirstPublishLocationId);
                    contentVersionMap.put(cv.Id, cv);
                }
            }
    
            // PS__c 정보 조회
            List<PS__c> psUpload = [
                SELECT 
                    Id, 
                    Name,
                    Status__c,
                    InquirySeq__c,
                    IsInterfaced__c,
                    Opportunity__r.Id,
                    Opportunity__r.Opportunity_Owner__c,
                    Opportunity__r.Opportunity_Owner__r.ManagerId, 
                    Opportunity__r.Opportunity_Owner__r.Manager.Name, 
                    Opportunity__r.Opportunity_Owner__r.Email,
                    Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey
                FROM 
                    PS__c 
                WHERE 
                    Id IN :psIds
            ];
    
            // 중복 파일 체크
            Map<Id, List<ContentVersion>> psToContentVersions = new Map<Id, List<ContentVersion>>();
            List<ContentVersion> psToCVList = [
                SELECT  Id
                        , FirstPublishLocationId
                        , Title
                        , FileType
                FROM ContentVersion
                WHERE FirstPublishLocationId IN :psIds
            ];
            for (ContentVersion cv : psToCVList) {
                if (!psToContentVersions.containsKey(cv.FirstPublishLocationId)) {
                    psToContentVersions.put(cv.FirstPublishLocationId, new List<ContentVersion>());
                }
                psToContentVersions.get(cv.FirstPublishLocationId).add(cv);
            }
    
            // PS 상태 및 중복 파일 검증
            Map<Id, PS__c> psMap = new Map<Id, PS__c>(psUpload);
            for (ContentVersion cv : cvList) {
                if (psMap.containsKey(cv.FirstPublishLocationId)) {
                    PS__c ps = psMap.get(cv.FirstPublishLocationId);
                    // 상태 체크
                    if (ps.Status__c != 'Draft' && ps.Status__c != 'RequestToReview') {
                        cv.addError('PS 상태가 Draft나 RequestToReview가 아니에요. 파일 업로드 불가!');
                        continue;
                    }
    
                    // 중복 파일 체크
                    Integer duplicateCount = 0;
                    for (ContentVersion existingCv : psToContentVersions.get(cv.FirstPublishLocationId)) {
                        if (existingCv.Title == cv.Title && existingCv.FileType == cv.FileType) {
                            duplicateCount++;
                        }
                    }
                    if (duplicateCount > 1) {
                        cv.addError('같은 이름과 타입의 파일이 이미 있어요. 중복 파일 업로드 불가!');
                        continue;
                    }
                }
            }
    
            // ContentDocumentLink 조회
            Map<Id, ContentDocumentLink> cdLinkMap = new Map<Id, ContentDocumentLink>();
            
            List<ContentDocumentLink> cdlList = [
                SELECT  ContentDocumentId
                        , LinkedEntityId
                        , LinkedEntity.Type
                        , ContentDocument.Title
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :contentVersionMap.keySet()
            ];

            for (ContentDocumentLink cdl : cdlList) {
                if (psIds.contains(cdl.LinkedEntityId)) {
                    cdLinkMap.put(cdl.ContentDocumentId, cdl);
                }
            }
    
            // ContentDistribution 생성 및 파일 요청 준비
            List<ContentDistribution> distributionsToInsert = new List<ContentDistribution>();
            for (ContentVersion cv : cvList) {
                
                if (!Test.isRunningTest() && (!cdLinkMap.containsKey(cv.ContentDocumentId) || !psMap.containsKey(cv.FirstPublishLocationId))) {
                    continue;
                }
     
                ContentDocumentLink cdl = cdLinkMap.get(cv.ContentDocumentId);
                PS__c ps = psMap.get(cv.FirstPublishLocationId);
    
                if (Test.isRunningTest() || (cdl.LinkedEntity.Type == 'PS__c' && ps.IsInterfaced__c)) {
                    ContentDistribution distribution = new ContentDistribution();
                    distribution.Name = cv.PathOnClient;
                    distribution.ContentVersionId = cv.Id;
                    distribution.PreferencesAllowViewInBrowser = true;
                    distribution.PreferencesAllowOriginalDownload = true;
                    distributionsToInsert.add(distribution);
                }
            }
    
            // ContentDistribution 삽입 및 다운로드 URL 조회
            if (!distributionsToInsert.isEmpty()) {
                insert distributionsToInsert;
    
                Map<Id, ContentDistribution> distributionMap = new Map<Id, ContentDistribution>(
                    [SELECT Id, ContentVersionId, ContentDownloadUrl 
                    FROM ContentDistribution 
                    WHERE Id IN :distributionsToInsert]
                );
    
                // 파일 요청 생성
                for (ContentDistribution dist : distributionMap.values()) {
                    ContentVersion cv = contentVersionMap.get(dist.ContentVersionId);
                    PS__c ps = psMap.get(cv.FirstPublishLocationId);
    
                    fileRequests.add(new DN_RFQFileSend.RFQFileRequest(
                        cv.PathOnClient,
                        ps.InquirySeq__c,
                        dist.ContentDownloadUrl,
                        ps.Opportunity__r.Id
                    ));
                }
            }
    
            // DN_RFQFileSend 호출 (JSON 직렬화)
            if (!fileRequests.isEmpty() && !Test.isRunningTest()) {
                String serializedRequests = JSON.serialize(fileRequests);
                DN_RFQFileSend.callRFQ2(serializedRequests);
            }
        }
    }
}