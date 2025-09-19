/**
 * @description       : Launching Excellence Document 생성 및 파일 업로드
 * @author            : Hayeong Min
 * @last test date    : 2025-04-01
 * @last modified by  : Hayeong Min
**/
public with sharing class DN_LaunchingExcellenceUploadController {
    
    /**
     * @Description
     *  - 선택한 문서(RecordType)로 Launching Excellence Document 생성
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper getInitInfo(String recordTypeId){
        CommonWrapper cw = new CommonWrapper();
        try {
            LaunchingExcellenceDoc__c doc = new LaunchingExcellenceDoc__c();
            doc.RecordTypeId = recordTypeId;
            insert doc;
            cw.returnValue = doc.Id;
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     *  - 문서 등록 취소 시 생성된 ContentDocument 제거
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper deleteDoc(String documentId){
        CommonWrapper cw = new CommonWrapper();
        try {
            ContentDocument doc = [SELECT Id FROM ContentDocument WHERE ID = :documentId];
            delete doc;
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     *  - 문서 등록 취소 시 생성된 Launching Excellence Document 제거
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper deleteRec(String recId){
        CommonWrapper cw = new CommonWrapper();
        try {
            LaunchingExcellenceDoc__c rec = [SELECT Id FROM LaunchingExcellenceDoc__c WHERE ID = :recId];
            delete rec;
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     *  - 문서의 Public Link를 생성하기 위한 ContentDistribution 생성
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper createPublicLink(String recId, String cvId, String docTitle){
        CommonWrapper cw = new CommonWrapper();
        try {

            ContentDistribution cb = new ContentDistribution();
            cb.Name = docTitle;
            cb.ContentVersionId = cvId;
            cb.PreferencesAllowViewInBrowser = true;
            cb.PreferencesLinkLatestVersion = true;
            cb.PreferencesNotifyOnVisit = false;
            cb.PreferencesPasswordRequired = false;
            cb.PreferencesAllowOriginalDownload = true;
            insert cb;
            
            cw.returnValue = cb.Id;
            //ContentDownloadUrl
            LaunchingExcellenceDoc__c lex = [SELECT Id, Name FROM LaunchingExcellenceDoc__c WHERE ID = :recId];
            lex.Name = docTitle;
            update lex;


        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /*
     * @Description
     * 		- 공용Wrapper
     * 
     * @Variable
     *  	- isSuccess 			: 성공여부
     *  	- errMessage 			: 실패시 에러메세지
     *  	- returnValue 			: 반환 값
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		{get; set;}
        @AuraEnabled
        public String errMessage		{get; set;} 
        @AuraEnabled
        public String returnValue		{get; set;}

        
        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
        }
    }
}