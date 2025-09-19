/**
 * @author            : iltae.seo
 * @last modified on  : 2024-11-22
 * @last modified by  : iltae.seo
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-11-25   iltae.seo     Initial Version
**/
public without sharing class DN_PopManagerController {
    
    /**
    * @Method : currentLoginUser
    * @description : 현재 로그인한 유저 정보
    * @author iltae.seo | 2024-11-22  
    **/
    public static User currentLoginUser {
        get {
            if (currentLoginUser == null) {
                System.debug('soql currentUser');
                currentLoginUser = [SELECT 
                                Id, Name, Username, UserCode__c, SalesOrganization__c, DistributionChannel__c, Division__c, SalesOffice__c, ERP_Key__c,
                                AccountId, Account.CustomerCode__c, Country__c, Profile.Name, ContactId, IsPortalEnabled
                                FROM User WHERE Id = :userInfo.getUserID() LIMIT 1];
            }
            return currentLoginUser;
        }
        set;
    }
    
    /**
    * @Method : getBoardIds
    * @description : 조건식에 따른 게시판 목록 반환
    * @author iltae.seo | 2024-11-22  
    **/
    @AuraEnabled
    public static List<Board__c> getBoardIds(){
        try {
            System.debug(currentLoginUser + ' ::: currentLoginUser');
            if ('1800'.equals(currentLoginUser.SalesOrganization__c)) {
                return popUpBoardListWithSales(currentLoginUser.SalesOrganization__c, currentLoginUser.SalesOffice__c);
            } else if ('1846'.equals(currentLoginUser.SalesOrganization__c)) {
                return popUpBoardListWithCs();
            } else {
                return new List<Board__c>();
            }
        } catch (Exception e) {
            throw new DN_PopManagerControllerException(e.getMessage());
        }
    }

    /**
    * @Method : popUpBoardListWithSales
    * @description : Sales 사용자 게시판 목록 반환
    * @author iltae.seo | 2024-11-22  
    **/
    public static List<Board__c> popUpBoardListWithSales(String salesOrganization, String salesOffice){
        DateTime utcNow = System.now();
        System.debug(utcNow + ' < ==utcNow');

        String query = 'select Id,  Name,Contents__c,IsTodayView__c,IsScroll__c,Width__c,Height__c from Board__c';
                    query  +=' where IsPopUp__c = true';
                    query  +=' AND RecordType.DeveloperName =\'Announcement\'';
                    query  +=' AND BoardStartDate__c <=:utcNow';
                    query  +=' AND BoardEndDate__c >=:utcNow';
                    query  +=' AND SalesOffice__c  INCLUDES (:salesOffice)'; 
                    query  +=' AND SalesOrganization__c INCLUDES (:salesOrganization)';
        System.debug(query + ' <=query');
        List<Board__c> boardList = database.query(query);
        System.debug(boardList + ' < ===boardList');
        return boardList;
    }

    /**
    * @Method : popUpBoardListWithCs
    * @description : CS 사용자 게시판 목록 반환
    * @author iltae.seo | 2024-11-22  
    **/
    public static List<Board__c> popUpBoardListWithCs(){
        DateTime utcNow = System.now();
        System.debug(utcNow + ' < ==utcNow');
        
        String query = 'select Id,  Name,Contents__c,IsTodayView__c,IsScroll__c,Width__c,Height__c from Board__c';
                    query  +=' where IsPopUp__c = true';
                    query  +=' AND RecordType.DeveloperName =\'Announcement\'';
                    query  +=' AND BoardStartDate__c <=:utcNow';
                    query  +=' AND BoardEndDate__c >=:utcNow';
                    query  +=' AND NoticeTarget__c = \'' + currentLoginUser.Profile.Name + '\'';
        System.debug(query + ' <=query');
        List<Board__c> boardList = database.query(query);
        System.debug(boardList + ' < ===boardList');
        return boardList;
    }

    /**
    * @Method : popUpBoardListWithCs
    * @description 내부 CRM 화면에서 미리보기 기능
    * @author iltae.seo | 2024-12-24
    * @param String recordId 
    **/
    @AuraEnabled
    public static Board__c getPreview(String recordId){
        try {
            Board__c board = [select Id, Name, Contents__c, IsTodayView__c, IsScroll__c, Width__c, Height__c, NoticeTarget__c, SalesOrganization__c from Board__c where Id =:recordId];
            System.debug(board + ' < ===boardList');
            return board;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @Method : getFileInfo
    * @description : 게시판의 Id 기준으로 파일 목록 반환
    * @author iltae.seo | 2024-11-22 
    * @param String recordId 
    **/
    @AuraEnabled
    public static Notice getFileInfo(String recordId){
        try {
            List<Board__c> board = [select Id,  Name, Contents__c, IsTodayView__c from Board__c where Id=:recordId];
            Notice notice = new Notice();
            if(board.size() > 0) {
                Notice notice2 = new Notice(board[0]);
                notice = notice2;
                set<String> ContentDocumentIds = new set<String>();
                
                List<ContentDocumentLink> contentLinkList =  [select Id, LinkedEntityId, ContentDocumentId,ContentDocument.FileType,ShareType  from ContentDocumentLink where LinkedEntityId=:recordId];
                List<FileInfo> fileInfoList = new List<FileInfo>();
                if(contentLinkList.size() >0) {
                    for(ContentDocumentLink conLink: contentLinkList) {
                        ContentDocumentIds.add(conLink.ContentDocumentId);
                    }
                    List<ContentDistribution> publicLinkList =  [SELECT Id, ContentDocumentId, DistributionPublicUrl, Name,ContentDownloadUrl
                                                                    FROM ContentDistribution
                                                                    WHERE ContentDocumentId IN : ContentDocumentIds];
                    
                    for(ContentDistribution conDistr : publicLinkList) {
                        fileInfoList.add(new FileInfo(conDistr));
                    }
                }
                notice.fileInfo = fileInfoList;
            } 
            
            
            return Notice;
        } catch (Exception e) {
            throw new DN_PopManagerControllerException(e);
        }
    }

    /**
    * @description : 공지사항 Wrapper
    * @author iltae.seo | 2024-11-22     
    **/
    public class Notice {
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String contents {get;set;}
        @AuraEnabled public Boolean isTodayView {get;set;}
        @AuraEnabled public List<FileInfo> fileInfo {get;set;}
        /**
        * @description : Notice 클래스에 게시판 데이터 매핑
        * @author iltae.seo | 2024-11-22     
        **/
        public Notice() {}
        public Notice(Board__c board) {
            this.name = board.Name;
            this.contents = board.Contents__c;
            this.isTodayView = board.IsTodayView__c;
            this.fileInfo = new List<FileInfo>();
        }
    }

    /**
    * @description : FileInfo(파일정보)
    * @author iltae.seo | 2024-11-22     
    **/
    public class FileInfo {
        @AuraEnabled public String fileId {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String distributionPublicUrl {get;set;}
        /**
        * @description : ContentDistribution 정보로 매핑
        * @author iltae.seo | 2024-11-22     
        **/
        public FileInfo(ContentDistribution cont) {
            this.fileId = cont.ContentDocumentId;
            this.name = cont.Name;
            this.distributionPublicUrl = cont.ContentDownloadUrl;
        }
    }

    public class DN_PopManagerControllerException extends Exception {

    }
}