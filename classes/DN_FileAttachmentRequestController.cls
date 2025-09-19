/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-25
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-31   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_FileAttachmentRequestController {
    public DN_FileAttachmentRequestController() {}

    // 해당 Ticket의 파일첨부요청을 고객에게 알림톡으로 전송하는 메서드
    @AuraEnabled
    public static ResultWrapper sendFileAlarmtalk(String recordId) {
        ResultWrapper result = new ResultWrapper();

        try {
            Case ticket = [SELECT Id, CaseNumber, FM_PhoneNumber__c FROM Case WHERE Id = :recordId LIMIT 1];
            AlertManager__c alertManager = [SELECT Id FROM AlertManager__c WHERE Name = 'AS File Attachment Request' LIMIT 1];
    
            String host = Label.DNS_AS_AlarmtalkURL;
            String url = host + ticket.CaseNumber;
            Map<String, String> alarmMap = new Map<String, String>{
                'rcpt_no'   => ticket.CaseNumber,
                'url'       => url
            };
            
            if (ticket.FM_PhoneNumber__c == null || ticket.FM_PhoneNumber__c == '') {
                result.isSuccess = false;
                result.message = '요청자 번호가 없습니다.';
            } else {
                List<UTIL_Alert.HistoryWrapper> hwList = new List<UTIL_Alert.HistoryWrapper>();
                UTIL_Alert.historyWrapper talkWrapper = new UTIL_Alert.historyWrapper();
                talkWrapper.alertID = alertManager.Id;
                talkWrapper.targetID = ticket.Id;
                talkWrapper.alertType = 'AlarmTalk';
                talkWrapper.alertLanguage = 'ko';
                talkWrapper.elementMap = alarmMap;
                talkWrapper.receiverforPhone = new Set<String>{ ticket.FM_PhoneNumber__c };
                hwList.add(talkWrapper);
                UTIL_Alert.runAlertEvent(hwList);
            }

        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
            result.isSuccess = false;
            result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
        }

        return result;

    }

    public class ResultWrapper {

        @AuraEnabled public Boolean isSuccess   { get; set;}
        @AuraEnabled public String  message     { get; set;}

        public ResultWrapper() {
            this.isSuccess = true;
            this.message = '';
        }
    }

}