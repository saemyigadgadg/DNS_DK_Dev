/**
 * @description       : (포탈) Support > [T]Q&A
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 06-16-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-31-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public without sharing class QnABoardTriggerHandler extends TriggerHandler {
    public QnABoardTriggerHandler() {}

    private static final Id recordType_Question = Schema.SObjectType.QnABoard__c.getRecordTypeInfosByDeveloperName().get('Question').getRecordTypeId();
    private static final Id recordType_Answer   = Schema.SObjectType.QnABoard__c.getRecordTypeInfosByDeveloperName().get('Answer').getRecordTypeId();

    public override void onBeforeInsert(List<sObject> news) {
        // 자동 채번 및 요건에 따른 QnA 구성
        madeQnAForm(news);    
    }

    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
        System.debug('isExecuting : '+isExecuting);
        System.debug(isExecuting);
        if (isExecuting) {
            // 담당자 이메일 보내는 메서드
            inSendEmailNotification(news);
            // Question Status 변경
            insertStatusQuestion(news);
        }
    }

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if (isExecuting) {
            // Validation Rule : 제목 변경 방지 메서드
            nameValidation(news,olds);
        }
    }
    

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        isExecuting = true;
        if (isExecuting) {
            // 담당자 이메일 보내는 메서드
            afSendEmailNotification(news);
        }
    }

    private void inSendEmailNotification(List<sObject> news) {
        System.debug('after insert sendEmailNotification >> ' +news);
        QnABoard__c qna = (QnABoard__c)news[0];
        String recordType = this.missingRecord(qna);
        String qnaId = qna.Id;
        Id mainParentId = qna.MainParent__c;
        String category = qna.Category__c;

        // 담당자 이메일 리스트
        List<String> repEmailList = new List<String>();
        List<String> repEmailListCC = new List<String>();

        if(recordType == 'Question') {
            List<Email_Recipient__c> repUserEmail = [SELECT Id, user__r.Email, RecipientEmail__c, RecipientType__c, isActive__c  FROM Email_Recipient__c WHERE Category__c = :category];
            System.debug('q se email >>' +repUserEmail);
    
            for (Email_Recipient__c uEmail : repUserEmail) {
                if (uEmail.isActive__c) {
                    if (uEmail.RecipientType__c == 'To') {
                        if (uEmail.user__r != null && String.isNotBlank(uEmail.user__r.Email)) {
                            repEmailList.add(uEmail.user__r.Email);
                        }
                        if (String.isNotBlank(uEmail.RecipientEmail__c)) {
                            repEmailList.add(uEmail.RecipientEmail__c);
                        }
                    } else if (uEmail.RecipientType__c == 'Cc') {
                        if (uEmail.user__r != null && String.isNotBlank(uEmail.user__r.Email)) {
                            repEmailListCC.add(uEmail.user__r.Email);
                        }
                        if (String.isNotBlank(uEmail.RecipientEmail__c)) {
                            repEmailListCC.add(uEmail.RecipientEmail__c);
                        }
                    }
                }
            }
        }else if(recordType == 'Answer') {    
            List<QnABoard__c> repUserEmail = [SELECT Id, Email__c FROM QnABoard__c WHERE Id = :mainParentId LIMIT 1];
            System.debug('q se email >>' +repUserEmail);
            for(QnABoard__c uEmail : repUserEmail) {
                repEmailList.add(uEmail.Email__c);
            }
        }
        
        System.debug('TO mail 확인 >>' + repEmailList);
        System.debug('CC mail 확인 >>' + repEmailListCC);
        if (!repEmailList.isEmpty()) {
            QnABoardEmailNotifier.SendCreationNotification(repEmailList, repEmailListCC, qnaId, recordType);
        }
    }

    private void afSendEmailNotification(List<sObject> news) {
        QnABoard__c qna = (QnABoard__c)news[0];
        String recordType = this.missingRecord(qna);
        String qnaId = qna.Id;
        Id mainParentId = qna.MainParent__c;

        List<String> repEmailList = new List<String>();
        List<String> repEmailListCC = new List<String>();

        System.debug('mainParentId >>> ' + mainParentId);
        
        if(recordType == 'Answer') {
            List<QnABoard__c> repUserEmail = [SELECT Id, Email__c FROM QnABoard__c WHERE Id = :mainParentId LIMIT 1];
            System.debug('re email >>' +repUserEmail);
            for(QnABoard__c uEmail : repUserEmail) {
                repEmailList.add(uEmail.Email__c);
            }
        }
        if (!repEmailList.isEmpty()) {
            System.debug('onAfterUpdate 작동' + recordType);
            QnABoardEmailNotifier.SendCreationNotification(repEmailList, repEmailListCC, qnaId, recordType);
        }
    }

    private void madeQnAForm(List<sObject> news) {
        QnABoard__c qna = (QnABoard__c)news[0];
        Set<Id> parentIds = new Set<Id>();
        for (QnABoard__c obj : (List<QnABoard__c>)news) {
            parentIds.add(obj.Parent__c);
        }

        Id accountId = null;
        User u = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        accountId = u.AccountId;
        System.debug(accountId);

        // 시작
        Map<Id, QnABoard__c> parentMaps = new Map<Id, QnABoard__c>([SELECT Id, OwnerId, Email__c, Category__c, MainParent__r.OwnerId, Title__c, MainParent__c, Level__c, SortNo__c, MainParent__r.Account__c, Account__c FROM QnABoard__c WHERE Id = :parentIds]);
        System.debug('parentMaps >> ' + parentMaps);
        list<QnABoard__c> qnaList = new list<QnABoard__c>();
        qnaList = [SELECT Id, Name FROM QnABoard__c ORDER BY Name desc limit 1];
        
        Integer autoNumber;
        
        if (qnaList != null && !qnaList.isEmpty()) {
            autoNumber = extractSequence(qnaList.get(0).Name);
        } else {
            autoNumber = 0000000000;
        }

        System.debug('autoNumber >> '+ autoNumber);
        
        for (QnABoard__c obj : (List<QnABoard__c>)news) {
            autoNumber++;
            if (parentMaps.containsKey(obj.Parent__c)) {
                System.debug('>>>Answer');
                QnABoard__c tmpObj = parentMaps.get(obj.Parent__c);

                obj.Name = 'QA' + String.valueOf(autoNumber).leftPad(10, '0');
                obj.RecordTypeId = recordType_Answer;
                obj.Title__c     = '[RE] ' + tmpObj.Title__c;
                obj.MainParent__c = tmpObj.MainParent__c == null ? obj.Parent__c : tmpObj.MainParent__c;
                obj.Category__c  = tmpObj.Category__c;
                obj.Email__c = tmpObj.Email__c;
                obj.Level__c = tmpObj.Level__c + 1;
                obj.SortNo__c = tmpObj.SortNo__c + '.' + String.valueOf(autoNumber).leftPad(10, '0');
                obj.Account__c = tmpObj.MainParent__c == null ? tmpObj.Account__c : tmpObj.MainParent__r.Account__c;
                System.debug('Insert obj>>>   '+obj);
            } else {
                System.debug('>>>Question');
                obj.RecordTypeId = recordType_Question;
                obj.Name = 'QA' + String.valueOf(autoNumber).leftPad(10, '0');
                Long reverse = 9999999999L - autoNumber;
                obj.SortNo__c = String.valueOf(reverse).leftPad(10, '0');
                obj.Account__c = accountId;
            }
        }
    }  

    private void nameValidation(List<sObject> news, List<sObject> olds) {
        QnABoard__c qnaN = (QnABoard__c)news[0];
        QnABoard__c qnaO = (QnABoard__c)olds[0];
        
        System.debug('qnaO.Name >> ' + qnaO.Name);
        System.debug('qnaN.Name >> ' + qnaN.Name);
        
        if (qnaO.Name != qnaN.Name) {
            System.debug('작동');
            qnaN.addError('제목은 변경하시면 안 됩니다.');
        }
    }

    private String missingRecord(QnABoard__c qna){
        String recordType = '';
        if(recordType_Question == qna.RecordTypeId) {
            recordType = 'Question';
        } else if (recordType_Answer == qna.RecordTypeId) {
            recordType = 'Answer';
        } else {
            qna.addError('레코드 타입이 이상합니다. 담당자에게 문의 부탁 드립니다.');
        }
        return recordType;
    }

    // Question Status 변경
    private void insertStatusQuestion(List<sObject> news) {
        QnABoard__c qna = (QnABoard__c)news[0];
        String recordType = this.missingRecord(qna);

        if(recordType == 'Answer') {
            if(qna.status__c != null) {
                QnABoard__c mainRecord = [SELECT Id, status__c FROM QnABoard__c WHERE Id =: qna.Parent__c LIMIT 1];
                mainRecord.status__c = qna.status__c;
                update mainRecord;
            }
        }
    }

    private Integer extractSequence(String autoNumber) {
        pattern p = Pattern.compile('\\d+');
        Matcher m = p.matcher(autoNumber);
        if (m.find()) {
            return Integer.valueOf(m.group());
        } else {
            return null;
        }
    }

}