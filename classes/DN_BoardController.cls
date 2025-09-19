/**
 * @description       : 
 * @author            : Joohyun Lee
 * @group             : 
 * @last modified on  : 05-13-2025
 * @last modified by  : Hanyeong Choi
**/
public with sharing class DN_BoardController {
    
    /**
     * @description       : 현재 유저 정보
     * @author            : daewook.kim@sbtglobal.com
     * @group             : 
     * @last modified on  : 05-13-2025
     * @last modified by  : daewook.kim@sbtglobal.com
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
     * @Description
     * 	- 통합 게시판 검색 시, get List (영업)
     * @author Hanyeong Choi | 07-31-2024
     * @Parameter
     *  - category              : Picklist
     *  - title                 : String
     *  - keyword               : String
     *  - searchBoardMonth      : Date
    **/ 
    @AuraEnabled
    public static Map<String, Object> getBoardList(String category, String title, String keyword, String searchBoardMonth,String recordType) {
        Map<String, Object>     resMap          = new Map<String, Object>();
        List<Board__c>          boardList       = new List<Board__c>();
        List<PicklistWrapper>   picklistValues  = new List<PicklistWrapper>();
        Map<String, String>     dateMap         = new Map<String, String>();
        
        try {
            Id loginUserId = UserInfo.getUserId();
            User loginUser = [
                SELECT id
                        , Name
                        , Username
                        , IsPortalEnabled
                        , AccountId
                        , ContactId
                        , SalesOffice__c
                        , SalesOrganization__c
                FROM User 
                WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED 
                LIMIT 1
            ];
            String sofficeValue = '(\'' + loginUser.SalesOffice__c + '\')';
            String sorgValue    = '(\'' + loginUser.SalesOrganization__c + '\')';
            String  queryString  = 'SELECT Id, tolabel(Category__c) Category__c, Name, keyword__c, FM_Writer__c, PostingDate__c, Contents__c, SalesOffice__c, SalesOrganization__c FROM Board__c';
            queryString += '\n WHERE SalesOffice__c INCLUDES ' + sofficeValue;
            queryString += '\n AND SalesOrganization__c INCLUDES ' + sorgValue;
            if(recordType !='All') {
                queryString += ' AND RecordTypeId =\''+recordType+'\'';
            }
            if (String.isNotBlank(searchBoardMonth)) {
                dateMap = formatDate(searchBoardMonth);
                queryString += '\n AND PostingDate__c <= ' + dateMap.get('lDate');
                queryString += '\n AND PostingDate__c >= ' + dateMap.get('fDate');
            }
            if(String.isNotBlank(category) && category != 'All') {
                queryString += '\n AND Category__c = \'' + category + '\'';
            }
    
            if(String.isNotBlank(title)) {
                queryString += '\n AND Name LIKE \'%' + title + '%\'';
            }
            queryString += '\n ORDER BY PostingDate__c DESC';
            List<Board__c> boards = DataBase.query(queryString);
    
            if(String.isNotBlank(keyword)) {
                for(Board__c record : boards) {
                    if(
                        record.Name.contains(keyword) ||
                        (record.keyword__c != null && record.keyword__c.contains(keyword)) ||
                        (record.Contents__c != null && record.Contents__c.contains(keyword))
                    ) {
                        boardList.add(record);
                    }
                }
            } else {
                boardList = boards;
            } 
            // resMap.put('recordId'       , recordTypeId);
            resMap.put('recordTypeId'  , recordType);
            resMap.put('boardList'      , boardList != null ? boardList : null);
            // resMap.put('picklistValues' , picklistValues);
            resMap.put('flag'           , 'success');
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'error');
        }
        return resMap;
    }

    /**
     * @description       : CS 통합 게시판(공지사항, 일반게시판, Q&A) 목록 검색
     * @author            : iltae.seo
     * @group             : 
     * @last modified on  : 05-13-2025
     * @last modified by  : daewook.kim@sbtglobal.com
    **/
    @AuraEnabled
    public static Map<String, Object> getBoardListwithCs(String category, String title, String keyword, String searchBoardMonth,String recordType) {
        Map<String, Object>     resMap          = new Map<String, Object>();
        List<Board__c>          boardList       = new List<Board__c>();
        Map<String, String>     dateMap         = new Map<String, String>();
        
        try {
            if (String.isBlank(recordType)) {
                System.debug('recordType is blank ::: ' + recordType);
                resMap.put('boardList'      , boardList);
                resMap.put('flag'           , 'success');
                return resMap;
            }
            String  queryString  = 'SELECT Id, tolabel(Category__c) Category__c, Name, FM_Writer__c, PostingDate__c, AnswerContent__c, FM_Respondent__c FROM Board__c'
            + ' WHERE RecordTypeId = \'' + recordType + '\'' + ' AND NoticeTarget__c = \'' + currentLoginUser.Profile.Name + '\'';
            if(String.isNotBlank(category) && category != 'All') {
                queryString += '\n AND Category__c = \'' + category + '\'';
            }
            if (String.isNotBlank(searchBoardMonth)) {
                dateMap = formatDate(searchBoardMonth);
                queryString += ' AND PostingDate__c <= ' + dateMap.get('lDate');
                queryString += ' AND PostingDate__c >= ' + dateMap.get('fDate');
            }
            if(String.isNotBlank(title)) {
                queryString += '\n AND Name LIKE \'%' + title + '%\'';
            }
            queryString += '\n ORDER BY PostingDate__c DESC';
            boardList = DataBase.query(queryString);
            resMap.put('recordTypeId'   , recordType);
            resMap.put('boardList'      , boardList);
            resMap.put('soql', queryString);
            resMap.put('flag'           , 'success');
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('boardList'      , boardList);
            resMap.put('flag', 'error');
        }
        return resMap;
    }

    /**
     * @description       : 게시판 저장 기능
     * @author            : iltae.seo
     * @group             : 
     * @last modified on  : 05-13-2025
     * @last modified by  : daewook.kim@sbtglobal.com
    **/
    @AuraEnabled
    public static Map<String, Object> saveQnA(String title, String question){
        Map<String, Object> resMap = new Map<String, Object>();
        try {

            Id qnaRecordTypeId = SObjectType.Board__c.getRecordTypeInfosByDeveloperName().get('Q_A').getRecordTypeId();
            String noticeTarget = '';
            Set<String> chkProfileSet = new Set<String>{'DNS CS Service_Partner','DNS CS Parts_Partner'};
            noticeTarget = chkProfileSet.contains(currentLoginUser.Profile.Name) ? currentLoginUser.Profile.Name : '';
            System.debug(noticeTarget);
            if (String.isBlank(noticeTarget)) {
                return new Map<String, Object>{'flag'=>'error', 'msg'=>'check permission'};
            }
            Board__c obj = new Board__c();
            obj.Name = title;
            obj.RecordTypeId = qnaRecordTypeId;
            obj.NoticeTarget__c = noticeTarget;
            obj.QuestionContent__c = question;
            obj.PostingDate__c = Date.TODAY();
            insert obj;
            resMap.put('flag', 'success');
            resMap.put('recordId', obj.Id);
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            resMap.put('flag', 'error');
            resMap.put('msg', e.getLineNumber() + ':' + e.getMessage());
        }
        return resMap;
    }
    

    /**
     * @Description
     * 	- Home 화면, get Board List
     * @author Hanyeong Choi | 08-05-2024
     * @Parameter
     *  - category              : Picklist
     *  - searchBoardMonth      : Date
    **/ 
    @AuraEnabled
    public static List<Board__c> getHomeBoardList(String category, String searchBoardMonth, String recordType) {
        if ('1800'.equals(currentLoginUser.SalesOrganization__c)) {
            return homeBoardListwithSales(category, searchBoardMonth, recordType);
        } else if ('1846'.equals(currentLoginUser.SalesOrganization__c)) {
            return homeBoardListwithCs(category, searchBoardMonth, recordType);
        } else {
            return new List<Board__c>();
        }
    }

    /**
     * @description       : 홈 대시보드(Sales) 목록 조회
     * @author            : iltae.seo
     * @group             : 
     * @last modified on  : 05-13-2025
     * @last modified by  : daewook.kim@sbtglobal.com
    **/
    public static List<Board__c> homeBoardListwithSales(String category, String searchBoardMonth, String recordType) {
        try {
            Map<String, String> dateMap = formatDate(searchBoardMonth);

            Id loginUserId = UserInfo.getUserId();
            User loginUser = [
                SELECT id
                        , SalesOffice__c
                        , SalesOrganization__c
                FROM User 
                WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED 
                LIMIT 1
            ];
            String sofficeValue = '(\'' + loginUser.SalesOffice__c + '\')';
            String sorgValue    = '(\'' + loginUser.SalesOrganization__c + '\')';

            String  queryString  = 'SELECT Id, Name, tolabel(Category__c) Category__c, FM_Writer__c, PostingDate__c FROM Board__c';
            queryString += '\n WHERE SalesOffice__c INCLUDES ' + sofficeValue;
            queryString += '\n AND SalesOrganization__c INCLUDES ' + sorgValue;
            queryString += '\n AND PostingDate__c <= ' + dateMap.get('lDate');
            queryString += '\n AND PostingDate__c >= ' + dateMap.get('fDate');
            if(recordType !='All') {
                queryString += ' AND RecordTypeId =\''+recordType+'\'';
            }
            queryString += '\n ORDER BY PostingDate__c DESC';
            queryString += '\n LIMIT 3';
            List<Board__c> boards = DataBase.query(queryString);
            
            return boards;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description       : 홈 대시보드(CS) 목록 조회
     * @author            : iltae.seo
     * @group             : 
     * @last modified on  : 05-13-2025
     * @last modified by  : daewook.kim@sbtglobal.com
    **/
    public static List<Board__c> homeBoardListwithCs(String category, String searchBoardMonth, String recordType) {
        try {
            Map<String, String> dateMap = formatDate(searchBoardMonth);

            String  queryString  = 'SELECT Id, Name, tolabel(Category__c) Category__c, FM_Writer__c, PostingDate__c FROM Board__c' + 
                                ' WHERE Id != null AND NoticeTarget__c = \'' + currentLoginUser.Profile.Name + '\'';
                    
                                queryString += ' AND PostingDate__c <= ' + dateMap.get('lDate') + ' AND PostingDate__c >= ' + dateMap.get('fDate');
            if(recordType !='All') {
                queryString += ' AND RecordTypeId =\''+recordType+'\'';
            }
            queryString += ' ORDER BY PostingDate__c DESC LIMIT 3';
            List<Board__c> boards = DataBase.query(queryString);
            return boards;
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }



    /**
     * @Description
     * 	- searchBoardMonth를 yyyy-mm-dd 형식으로 변환
     * @author Hanyeong Choi | 07-31-2024
     * @Parameter
     *  - searchBoardMonth      : DateTime
    **/ 
    private static Map<String, String> formatDate(String searchBoardMonth) {
        Map<String, String> resMap = new Map<String, String>();
        if (String.isNotBlank(searchBoardMonth)) {
            List<String> dateList = searchBoardMonth.split('-');
            Integer year            = Integer.valueOf(dateList[0]);
            Integer month           = Integer.valueOf(dateList[1]);
            Date    monthFirstDate  = Date.newinstance(year, month - 1, 1); 
            Date    monthLastDate   = Date.newinstance(year, month + 1, 0); 
            String  fDate           = String.valueOf(monthFirstDate).split(' ')[0];
            String  lDate           = String.valueOf(monthLastDate).split(' ')[0];
            resMap.put('fDate', fDate);
            resMap.put('lDate', lDate);
        }
        return resMap;
    }
    
    /**
     * @Description
     * 	- Picklist Wrapper
     * @author Hanyeong Choi | 07-31-2024
     * @Parameter
    **/ 
    public class PicklistWrapper {
        @AuraEnabled public String label  {get;set;} // Category__c Picklist Label
        @AuraEnabled public String value  {get;set;} // Category__c Picklist Value
        public PicklistWrapper() {}
        public PicklistWrapper(String Label, String Value) {
            this.label = Label;
            this.value = Value;
        }
    }
}