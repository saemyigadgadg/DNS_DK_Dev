/**
 * @related           : [dN_ShareFileForPortal]
 * @description       : 포탈에 공유할 파일 업로드 컨트롤러
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-22
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2025-03-19   yeongju.yun   Initial Version
**/
public with sharing class DN_ShareFileForPortalController {
    public static DN_OrderService ordSvc = new DN_OrderService();
    
    /**
    * @description 기회와 연결 된 파일 리스트 조회
    **/
    @AuraEnabled
    public static ResultWrapper fetchInit(String recordId){
        ResultWrapper result = new ResultWrapper();
        try {
            Boolean isShow   = false;

            Id targetId = Id.valueOf(recordId);
            String sObjName = targetId.getSObjectType().getDescribe().getName();


            if(sObjName == 'Opportunity') {
                Id turnkeyTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Turn_Key').getRecordTypeId();

                Opportunity opty = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id =: recordId];
                if(turnkeyTypeId == opty.RecordTypeId) { isShow = true; }
            }

            List<ContentDocumentLink> cdLinkList = [
                SELECT  ContentDocumentId, ContentDocument.Title, ContentDocument.Owner.Name, ContentDocument.LastModifiedDate, ContentDocument.FileExtension
                FROM    ContentDocumentLink 
                WHERE   LinkedEntityId = :recordId
                AND     Visibility = 'AllUsers'
                ORDER BY ContentDocument.LastModifiedDate DESC
            ];

            List<FileWrapper> files = new List<FileWrapper>();
            Set<Id> cdIdSet = new Set<Id>();
            for(ContentDocumentLink cdLink : cdLinkList) {
                files.add(new FileWrapper(cdLink));
                cdIdSet.add(cdLink.ContentDocumentId);
            }

            List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: cdIdSet];
            Map<Id, Id> documentMap = new Map<Id, Id>(); // key : ContentDocumentId, value : ContentVersionId
            for(ContentVersion cv : cvList) {
                documentMap.put(cv.ContentDocumentId, cv.Id);
            }

            for(FileWrapper fWrap : files) {
                fWrap.cvId = documentMap.get(fWrap.cdId);
            }

            result.data.put('isShow', isShow);
            result.data.put('files',  files);
            
            return result;
        } catch (Exception e) {
            System.debug('fetchInit : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 파일 업로드 및 Dealer용 권한 확장
    **/
    @AuraEnabled
    public static void uploadFiles(String recordId, List<Map<String, String>> files){
        Savepoint sp = Database.setSavepoint(); 
        
        try {
            
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (Map<String, String> file : files) {
                ContentVersion cv         = new ContentVersion();
                cv.Title                  = file.get('fileName');
                cv.PathOnClient           = file.get('fileName');
                cv.VersionData            = EncodingUtil.base64Decode(file.get('base64Data'));
                cv.FirstPublishLocationId = recordId;
                cvList.add(cv);
            }
            insert cvList;
            Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>(cvList);

            List<ContentVersion> getCVList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cvMap.keySet()];

            Set<Id> cdIdSet = new Set<Id>();
            for(ContentVersion cv : getCVList) {
                cdIdSet.add(cv.ContentDocumentId);
            }

            List<ContentDocumentLink> linksToUpdate = new List<ContentDocumentLink>();
            for (ContentDocumentLink link : [SELECT Id, ShareType, Visibility FROM ContentDocumentLink WHERE ContentDocumentId = :cdIdSet]) {
                link.Visibility = 'AllUsers';
                linksToUpdate.add(link);
            }

            if (!linksToUpdate.isEmpty()) { update linksToUpdate; }
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('uploadFiles : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description ID값으로 파일 삭제
    **/
    @AuraEnabled
    public static void deleteFile(String cdId){
        try {
            
            List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id =: cdId];
            delete cdList;
            
        } catch (Exception e) {
            System.debug('deleteFile : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 결과 반환 Wrapper
    **/
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess  {get;set;}
        @AuraEnabled public String  errMessage {get;set;}

        @AuraEnabled public Map<String, Object> data {get;set;}
        
        public ResultWrapper(){
            this.isSuccess  = true;
            this.errMessage = '';
            this.data = new Map<String, Object>();
        }
    }

    /**
    * @description 파일 리스트를 위한 wrapper
    **/
    public class FileWrapper {
        @AuraEnabled public String cdId {get;set;}
        @AuraEnabled public String cvId {get;set;}
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String extention {get;set;}
        @AuraEnabled public String ownerName {get;set;}
        @AuraEnabled public DateTime lastModifiedDate {get;set;}

        public FileWrapper(ContentDocumentLink cdLink) {
            this.cdId             = cdLink.ContentDocumentId;
            this.title            = cdLink.ContentDocument.Title;
            this.extention        = cdLink.ContentDocument.FileExtension;
            this.ownerName        = cdLink.ContentDocument.Owner.Name;
            this.lastModifiedDate = cdLink.ContentDocument.LastModifiedDate;
        }
    }
}