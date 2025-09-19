/**
 * @description       : DO화면에서 파일 관리
 * @author            : yeongju.yun
 * @last modified on  : 2025-07-17
 * @last modified by  : yeongju.yun
**/
public with sharing class DN_DOFileManagerController {

    /**
    * @description ERP 전송 여부 반환
    **/
    @AuraEnabled
    public static Boolean getFlagSentERP(String recordId){
        try {
            DeliveryOrder__c dOrder = [SELECT Id, ERPDONo__c FROM DeliveryOrder__c WHERE Id =: recordId];
            return String.isNotBlank(dOrder.ERPDONo__c);
        } catch (Exception e) {
            System.debug('getFlagSentERP : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description DO에 연결 된 파일 반환
    **/
    @AuraEnabled
    public static List<FileWrapper> getUploadedFiles(String recordId) {
        try {

            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
                ];

            if (links.isEmpty()) {
                return new List<FileWrapper>();
            }

            List<Id> documentIds = new List<Id>();
            for (ContentDocumentLink link : links) {
                documentIds.add(link.ContentDocumentId);
            }

            List<ContentVersion> versions = [
                SELECT ContentDocumentId, Title, FileType__c
                FROM ContentVersion
                WHERE ContentDocumentId IN :documentIds
                AND IsLatest = true
            ];

            Map<Id, FileWrapper> fileMap = new Map<Id, FileWrapper>();
            for (ContentVersion version : versions) {
                FileWrapper fileWrap = new FileWrapper();
                fileWrap.fileId      = version.ContentDocumentId;
                fileWrap.fileName    = version.Title;
                fileWrap.fileType    = version.FileType__c;
                fileMap.put(fileWrap.fileId, fileWrap);
            }

            // for portal
            List<ContentDistribution> distributions = [
                SELECT  Id, ContentDocumentId, DistributionPublicUrl 
                FROM    ContentDistribution 
                WHERE   ContentDocumentId IN :documentIds
            ];

            List<FileWrapper> fileWraps = new List<FileWrapper>();
            if(!distributions.isEmpty()) {
                for(ContentDistribution distribution : distributions) {
                    FileWrapper fileWrap = fileMap.get(distribution.ContentDocumentId);
                    fileWrap.publicURL   = distribution.DistributionPublicUrl;
                    fileWraps.add(fileWrap);
                }
            }
    
            return fileWraps;

        } catch (Exception e) {
            System.debug('getUploadedFiles : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description DO에 연결 된 파일 삭제
    **/
    @AuraEnabled
    public static void deleteFile(String fileId) {
        try {
            List<ContentDocument> documentsToDelete = [
                SELECT Id FROM ContentDocument WHERE Id = :fileId
            ];
            delete documentsToDelete;
        } catch (Exception e) {
            System.debug('deleteFile : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description DO에 파일 업로드
    **/
    @AuraEnabled
    public static String uploadFile(String fileName, String base64Data, String contentType, String fileType, String recordId) {

        try {
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            cv.IsMajorVersion = true;
            cv.FileType__c = fileType;
            insert cv;

            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            link.LinkedEntityId = recordId;
            link.ShareType = 'I';
            link.Visibility = 'AllUsers';
            insert link;

            return link.ContentDocumentId;
        } catch (Exception e) {
            System.debug('uploadFile : ' + e.getLineNumber() + ' / ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description File 화면 노출용 Wrapper
    **/
    public class FileWrapper {
        @AuraEnabled public Id fileId        {get;set;}
        @AuraEnabled public String fileName  {get;set;}
        @AuraEnabled public String fileType  {get;set;}
        @AuraEnabled public String publicURL {get;set;}
        
        public FileWrapper(){
            this.fileName = '';
            this.fileType = '';
            this.publicURL = '';
        }
    }
}