/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public without sharing class DN_AnnouncementController{

    // 공지사항 게시판의 해당 레코드의 정보와 파일을 가져오는 메서드
    @AuraEnabled
    public static List<Map<String, Object>> getBoard() {
        try {
            List<Board__c> boardList = [
                SELECT Id, Name, Owner.Name, ContentTextarea__c, CreatedDate, NoticeTarget__c, RecordTypeId, RecordType.Name, Respondent__r.Name, DateOfReply__c, AnswerContent__c, QuestionContent__c,
                    (SELECT ContentDocumentId, 
                            ContentDocument.Title, 
                            ContentDocument.LatestPublishedVersionId 
                        FROM ContentDocumentLinks) 
                FROM Board__c 
                WHERE NoticeTarget__c = 'Field Service'
                ORDER BY CreatedDate DESC
            ];

            List<ContentDistribution> distributionList = [
                SELECT DistributionPublicUrl, ContentDocumentId
                FROM ContentDistribution
            ];

            String domainUrl = URL.getOrgDomainUrl().toExternalForm();
            
            List<Map<String, Object>> resultList = new List<Map<String, Object>>();
            
            for (Board__c board : boardList) {
                Map<String, Object> boardData = new Map<String, Object>();
                boardData.put('Id', board.Id);
                boardData.put('Name', board.Name);
                boardData.put('OwnerName', board.Owner.Name);
                boardData.put('Respondent', board.Respondent__r.Name);
                boardData.put('Contents', board.ContentTextarea__c);
                boardData.put('QuestionContent', board.QuestionContent__c);
                boardData.put('AnswerContent', board.AnswerContent__c);
                boardData.put('CreatedDate', board.CreatedDate);
                boardData.put('DateOfReply', board.DateOfReply__c);
                boardData.put('recordType', board.RecordType.Name);
                
                List<Map<String, Object>> fileList = new List<Map<String, Object>>();
                
                // 각 게시글의 첨부파일 다운로드 생성
                for (ContentDocumentLink cdl : board.ContentDocumentLinks) {
                    Map<String, Object> fileData = new Map<String, Object>();
                    fileData.put('Title', cdl.ContentDocument.Title);
                    
                    // String downloadLink = domainUrl + '/' + cdl.ContentDocument.LatestPublishedVersionId;

                    // 테스트
                    // String downloadLink = domainUrl + '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                    // distributionList에서 ContentDocumentId를 비교하여 Public URL 설정
                    String downloadLink;
                    for (ContentDistribution dist : distributionList) {
                        if (dist.ContentDocumentId == cdl.ContentDocumentId) {
                            downloadLink = dist.DistributionPublicUrl;
                            break;
                        }
                    }

                    // 만약 DistributionPublicUrl이 없다면 기본 URL을 설정
                    if (String.isBlank(downloadLink)) {
                        downloadLink = domainUrl + '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                    }


                    fileData.put('DownloadLink', downloadLink);
                    fileList.add(fileData);
                }
                
                boardData.put('Files', fileList);
                resultList.add(boardData);
            }
            return resultList;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving announcements: ' + e.getMessage());
        }
    }

    // 공지사항 게시판의 게시글을 가져오는 메서드
    @AuraEnabled
    public static List<Map<String, Object>> getBoards(String sortBy) {
        try {
            String query = 'SELECT Id, Name, Owner.Name, ContentTextarea__c, CreatedDate, NoticeTarget__c, RecordTypeId, RecordType.Name, Respondent__r.Name, DateOfReply__c, AnswerContent__c, QuestionContent__c, ' +
                           '(SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLinks) ' +
                           'FROM Board__c WHERE NoticeTarget__c = \'Field Service\' ';
            
            // if (isAnnouncement) {
            //     query += 'AND RecordType.Name = \'Announcement\' ';
            // } else {
            //     query += 'AND RecordType.Name = \'Q & A\' ';
            // }

            if (sortBy == 'announceName' || sortBy == 'qnaName') {
                query += 'ORDER BY Name ASC';
            } else if (sortBy == 'announceDate' || sortBy == 'qnaDate') {
                query += 'ORDER BY CreatedDate DESC';
            } else {
                query += 'ORDER BY CreatedDate DESC';
            }

            List<Board__c> boardList = Database.query(query);
            System.debug('query:::' + query);

            List<ContentDistribution> distributionList = [
                SELECT DistributionPublicUrl, ContentDocumentId
                FROM ContentDistribution
            ];

            String domainUrl = URL.getOrgDomainUrl().toExternalForm();
            
            List<Map<String, Object>> resultList = new List<Map<String, Object>>();
            
            for (Board__c board : boardList) {
                Map<String, Object> boardData = new Map<String, Object>();
                boardData.put('Id', board.Id);
                boardData.put('Name', board.Name);
                boardData.put('OwnerName', board.Owner.Name);
                boardData.put('Respondent', board.Respondent__r.Name);
                boardData.put('Contents', board.ContentTextarea__c);
                boardData.put('QuestionContent', board.QuestionContent__c);
                boardData.put('AnswerContent', board.AnswerContent__c);
                boardData.put('CreatedDate', board.CreatedDate);
                boardData.put('DateOfReply', board.DateOfReply__c);
                boardData.put('recordType', board.RecordType.Name);
                
                List<Map<String, Object>> fileList = new List<Map<String, Object>>();
                
                // 각 게시글의 첨부파일 다운로드 생성
                for (ContentDocumentLink cdl : board.ContentDocumentLinks) {
                    Map<String, Object> fileData = new Map<String, Object>();
                    fileData.put('Title', cdl.ContentDocument.Title);
                    
                    // String downloadLink = domainUrl + '/' + cdl.ContentDocument.LatestPublishedVersionId;

                    // 테스트
                    // String downloadLink = domainUrl + '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                    // distributionList에서 ContentDocumentId를 비교하여 Public URL 설정
                    String downloadLink;
                    for (ContentDistribution dist : distributionList) {
                        if (dist.ContentDocumentId == cdl.ContentDocumentId) {
                            downloadLink = dist.DistributionPublicUrl;
                            break;
                        }
                    }

                    // 만약 DistributionPublicUrl이 없다면 기본 URL을 설정
                    if (String.isBlank(downloadLink)) {
                        downloadLink = domainUrl + '/sfc/servlet.shepherd/version/download/' + cdl.ContentDocument.LatestPublishedVersionId;
                    }


                    fileData.put('DownloadLink', downloadLink);
                    fileList.add(fileData);
                }
                
                boardData.put('Files', fileList);
                resultList.add(boardData);
            }
            return resultList;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving announcements: ' + e.getMessage());
        }
    }

    // 필드 서비스 사용자들에게 노티를 보내는 메서
    @AuraEnabled
    public static void sendNotification(Id recordId) {
        // List<Board__c> boardList = (List<Board__c>) news;
        List<Board__c> boardList = [
                SELECT Id, Name, Owner.Name, Contents__c, CreatedDate, NoticeTarget__c, RecordType.Name, RecordTypeId,
                    (SELECT ContentDocumentId, 
                            ContentDocument.Title, 
                            ContentDocument.LatestPublishedVersionId 
                        FROM ContentDocumentLinks) 
                FROM Board__c 
                WHERE Id =: recordId AND NoticeTarget__c = 'Field Service'
                ORDER BY CreatedDate DESC
            ];
        List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();
        String alertManagerID = [
                    SELECT Id FROM AlertManager__c WHERE IsActive__c = true AND Name = 'CS Announcement Noti' LIMIT 1
                ].Id;

        // 활성화된 서비스요원
        Set<Id> mobileUserIds = new Set<Id>();
        List<ServiceResource> serviceResourceList = [SELECT Id, RelatedRecordId FROM ServiceResource WHERE IsActive = true AND Branch__c = 'DNS' AND ResourceType = 'T'];

        for (ServiceResource sr : serviceResourceList) {
            mobileUserIds.add(sr.RelatedRecordId);
        }
        // 하수헌 유저 아이디
        // mobileUserIds.add('005F7000006DOYwIAO');


        // if (mobileUserIds.size() > 10) {
        //     Integer count = 0;
        //     for (Integer i = 0; i < mobileUserIds.size(); i++ ) {
                
        //     }
        // }
        // DNSA유저는 DNSA유저가 버튼 눌렀을 때만 노티가고 아니면 안가도록  수정
        for(Board__c board : boardList) {
            UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
            hw.alertID = alertManagerID;
            hw.targetID = board.Id;
            hw.alertType = 'Notification';
            hw.alertLanguage = 'ko';
            hw.elementList.add(board.RecordType.Name);
            hw.title = '새로운 공지사항이 등록되었습니다. 제목:' + board.Name;
            hw.receiverforID = mobileUserIds;
            // hw.pageRef = JSON.serialize(new Map<String, Object>{
            //             'type' => 'standard__component',
            //             'attributes' => new Map<String, String>{
            //                 'componentName' => 'DN_AnnouncementButton'
            //             },
            //             'state' => new Map<String, String>{
            //                 'recordId' => board.Id
            //             }
            //         });
            
            hwList.add(hw);
        }
        

        if (!hwList.isEmpty()) {
            UTIL_Alert.runAlertEvent(hwList);
            System.debug('Notification Sent for Board__c Insert');
        }
        System.debug('Sending notification for record: ' + recordId);
    }

    // 공지사항 게시판에 Q&A를 생성하는 메서드
    @AuraEnabled
    public static void createQnA(String newName, String newPostingDate, String newQuestion) {
        try {


            Board__c bo = [
                SELECT Id, Name, RecordTypeId, NoticeTarget__c, RecordType.Name
                FROM Board__c
                WHERE NoticeTarget__c = 'Field Service' AND RecordType.Name = 'Q & A'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            DateTime dt = System.now();

            Board__c newBoard = new Board__c();
            newBoard.Name = newName;
            newBoard.RecordTypeId = bo.RecordTypeId;
            newBoard.QuestionContent__c = newQuestion;
            newBoard.NoticeTarget__c = bo.NoticeTarget__c;
            if (String.isBlank(newPostingDate)) {
                newBoard.PostingDate__c = System.today();
            } else {
                newBoard.PostingDate__c = Date.valueOf(newPostingDate);
            }

            insert newBoard;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving announcements: ' + e.getMessage());
        }
    }
}