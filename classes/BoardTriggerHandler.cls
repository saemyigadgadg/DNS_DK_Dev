/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-09-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-30-2024   Hanyeong Choi   Initial Version
**/
public without sharing class BoardTriggerHandler extends TriggerHandler {
    

    public override void onBeforeInsert(List<sObject> news){
        try {
            if (isExecuting) {
                System.debug('Board__c BEFORE_INSERT TRIGGER Start');
                List<Board__c> boardList = (List<Board__c>) news;

                for(Board__c board : boardList){
                    validationCheck(board, 'Insert');
                }
            
                setting(false, TriggerOperation.BEFORE_INSERT);
                System.debug('Board__c BEFORE_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        try {
            if (isExecuting) {
                System.debug('Board__c AFTER_INSERT TRIGGER Start');
                List<Board__c> boardList = (List<Board__c>) news;
                List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();
                

                String alertManagerID = [
                    SELECT Id FROM AlertManager__c WHERE IsActive__c = true AND Name = 'CS Announcement Noti' LIMIT 1
                ].Id;

                // Profile이 'Partner Community User (CS)'인 User가 Q & A를 작성하면 담당자한테 노티발송인데 아직 안정해짐 하수헌한테
                Set<Id> mobileUserIds = new Set<Id>();
                List<User> userList = [SELECT Id, Name, ProfileId, Profile.Name FROM User WHERE Name = '하수헌 Suheon Ha' AND IsActive = true];
                for(User user : userList) {
                    mobileUserIds.add(user.Id);
                }
                for(Board__c board : boardList) {
                    if (board.RecordType.Name == 'Q & A') {
                        UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
                        hw.alertID = alertManagerID;
                        hw.targetID = board.Id;
                        hw.alertType = 'Notification';
                        hw.alertLanguage = 'ko';
                        hw.title = '새로운 공지사항이 등록되었습니다. 제목: ' + board.Name;
                        hw.elementList = new List<String>{board.ContentTextarea__c};
                        hw.receiverforID = mobileUserIds;
                        
                        // targetPageRef 설정 추가 - 나중에 확인
                        // hw.targetPageRef = JSON.serialize(new Map<String, Object>{
                        //     'type' => 'standard__component',
                        //     'attributes' => new Map<String, String>{
                        //         'componentName' => 'DN_AnnouncementButton'
                        //     },
                        //     'state' => new Map<String, String>{
                        //         'recordId' => board.Id
                        //     }
                        // });
                        
                        hwList.add(hw);
                    }
                }
                

                if (!hwList.isEmpty()) {
                    UTIL_Alert.runAlertEvent(hwList);
                    System.debug('Notification Sent for Board__c Insert');
                }
                
                System.debug('Board__c AFTER_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        List<Board__c> boardList = (List<Board__c>) news;
        Id currentUserId = UserInfo.getUserId();
        System.debug('currentUserId::' + currentUserId);
        DateTime dt = System.now();
        System.debug('dt:::'+dt);
        Set<Id> boardIds = new Set<Id>();
        Map<Id, Board__c> oldBoardMap = (Map<Id, Board__c>) oldMap;
        for(Board__c obj : boardList){
            boardIds.add(obj.OwnerId);
        }

        for (Board__c newRecord : boardList) {
            Board__c oldRecord = (Board__c) oldMap.get(newRecord.Id);
            // Q & A 답변하면 등록일은 현재시간, 답변자는 유저ID를 기입
            if ((newRecord.AnswerContent__c != null) && (oldRecord.AnswerContent__c != newRecord.AnswerContent__c)) {
                newRecord.DateOfReply__c = dt;
                newRecord.Respondent__c = currentUserId;
            }
        }
    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        List<Board__c> boardList = (List<Board__c>) news;
        Set<Id> boardIds = new Set<Id>();
        Map<Id, Board__c> oldBoardMap = (Map<Id, Board__c>) oldMap;
        for(Board__c obj : boardList){
            boardIds.add(obj.OwnerId);
        }
        List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();

        String alertManagerID = [
            SELECT Id FROM AlertManager__c WHERE IsActive__c = true AND Name = 'CS QnA Noti' LIMIT 1
        ].Id;

        for (Board__c newRecord : boardList) {
            Board__c oldRecord = (Board__c) oldMap.get(newRecord.Id);
            // Q & A 답변하면 해당 Q & A의 소유자한테 알림 발송
            if ((newRecord.AnswerContent__c != null) && (oldRecord.AnswerContent__c != newRecord.AnswerContent__c)) {               
                UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
                hw.alertID = alertManagerID;
                hw.targetID = newRecord.Id;
                hw.alertType = 'Notification';
                hw.alertLanguage = 'ko';
                hw.title = '새로운 답변이 등록되었습니다. 제목: ' + newRecord.Name;
                hw.elementList = new List<String>{newRecord.Name};
                // hw.receiverforID = newRecord.OwnerId;
                hw.receiverforID = new Set<Id>{newRecord.OwnerId}; 
                

                hwList.add(hw);
            }
        }

        UTIL_Alert.ResultWrapper rw = UTIL_Alert.runAlertEvent(hwList);


    }


    /**
    * @Description
    *  - Board__c Validation Check
    * @author Hanyeong Choi | 07-30-2024
    * @Parameter
    *  - board      : Board__c Record
    *  - type       : Operation Type
    **/
    private static void validationCheck(Board__c board, String type) {
        if(type == 'Insert') {
            if(board.PostingDate__c == null) {
                board.PostingDate__c = System.today();
            }
        }
        return;
    }
}