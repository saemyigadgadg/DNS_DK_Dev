/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 05-02-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-31-2025   daewook.kim@sbtglobal.com   Initial Version
**/
public without sharing class QnABoardEmailNotifier {
    public static void SendCreationNotification(List<String> repEmailList, List<String> repEmailListCC, String qnaId, String recordType) {
        // recordType == Question or Answer
        AlertManager__c am = [
            SELECT Id, Name
            FROM AlertManager__c
            WHERE Name = 'QnA Notification Email' AND IsActive__c = true
            LIMIT 1
        ];

        String amId = am.Id;

        List<QnABoard__c> qab = [
            SELECT Id, Title__c, Contents__c, IsQSend__c, Status__c, toLabel(Category__c), recordType.Name, CreatedDate, Owner.Name
            FROM QnABoard__c 
            WHERE Id =: qnaId
        ];

        QnABoard__c qna = (QnABoard__c)qab[0];

        Boolean isQS = qna.IsQSend__c;
        Boolean isAS = qna.Status__c == '완료' ? true : false;

        String createDate = String.valueOf(qna.CreatedDate.date());
        String qTitle     = qna.Title__c;
        String aTitle     = '['+qna.Category__c+']_'+ qna.Owner.Name+'_'+createDate+'_'+qna.Title__c; // [{카테고리}]_{부품대리점명}_{생성일자}_제목
        String qnaContent = qna.Contents__c;

        // String urlink = String.valueOf(URL.getOrgDomainUrl());
        String dLink = 'https://dn-solutions.lightning.force.com/lightning/r/QnABoard__c/';
        String pLink = 'https://dportal.dn-solutions.com/s/qnaboard/';

        // String dLink = 'https://dn-solutions--dev.sandbox.lightning.force.com/lightning/r/QnABoard__c/';
        // String pLink = 'https://dn-solutions--dev.sandbox.my.site.com/partners/s/qnaboard/';
        // String view  = 'view';
        String link = recordType == 'Question' ? dLink : pLink;
        String view = recordType == 'Question' ? '/view' : '';
        List<UTIL_Alert.HistoryWrapper> wrappers = new List<UTIL_Alert.HistoryWrapper>();
        UTIL_Alert.HistoryWrapper wrap = new UTIL_Alert.HistoryWrapper();
        wrap.alertID            = amId;
        wrap.targetID           = qnaId;
        wrap.alertType          = 'Email';
        wrap.alertLanguage      = 'ko';
        // wrap.title              = recordType == 'Question' ? qTitle : aTitle;
        wrap.title              = aTitle;
        wrap.elementList        = new List<String>{qTitle, qnaContent, link, qnaId, view};
        wrap.receiverforEmail   = repEmailList;
        wrap.receiverforEmailCC = repEmailListCC;

        wrappers.add(wrap);

        try{
            if (!isQS && recordType == 'Question') {
                UTIL_Alert.runAlertEvent(wrappers);
                system.debug('send Question');
                update new QnABoard__c(Id = qnaId, IsQSend__c = true);
            } else if(isAS && !isQS && recordType == 'Answer') {
                UTIL_Alert.runAlertEvent(wrappers);
                system.debug('send Answer');
                update new QnABoard__c(Id = qnaId, IsQSend__c = true);
            }
        }catch(Exception e) {
            System.debug('❌ 이메일 전송 실패 (' + recordType + '): ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAnswersByMainParent(Id currentId) {
        QnABoard__c mpId = [ SELECT Id, MainParent__c
                             FROM QnABoard__c 
                             WHERE Id = :currentId
                             LIMIT 1
        ];
        String mainId = mpId.MainParent__c != null ? mpId.MainParent__c : mpId.Id;

        List<QnABoard__c> mainList = [ SELECT Id, Name, Title__c, RecordType.Name, Status__c, CreatedDate, SortNo__c
                                       FROM QnABoard__c 
                                       WHERE MainParent__c =: mainId
                                    //    ORDER BY SortNo__c DESC
                                       ORDER BY SortNo__c ASC
                                       
        ];
        List<QnABoard__c> mainParent = [ SELECT Id, Name, Title__c, RecordType.Name, CreatedDate
                                         FROM QnABoard__c 
                                         WHERE Id =: mainId LIMIT 1
        ];

        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for(QnABoard__c record : mainParent) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('Id', record.Id);
            row.put('Name', record.Name);
            row.put('Type', record.RecordType.Name);
            row.put('Date', record.CreatedDate);
            row.put('Title', record.Title__c);
            result.add(row);
        }        
        for(QnABoard__c record : mainList) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('Id', record.Id);
            row.put('Name', record.Name);
            row.put('Type', record.RecordType.Name);
            row.put('Status', record.Status__c);
            row.put('Date', record.CreatedDate);
            row.put('Title', record.Title__c);
            result.add(row);
        }
        return result;
    }
}