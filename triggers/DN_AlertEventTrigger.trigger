/**
 * @description       : Custom Notification
 * @author            : yeongju.yun
 * @last modified on  : 2025-05-29
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-10-23   yeongju.yun   Initial Version
**/
trigger DN_AlertEventTrigger on AlertEvent__e (after insert) {

    runEvent(Trigger.New);

    private static void runEvent(List<AlertEvent__e> events) {
        Set<String> historyIdSet = new Set<String>();
        for(AlertEvent__e event : events){
            List<String> tempIds = event.Histories__c.split(',');
            historyIdSet.addAll(tempIds);
        }

        System.debug('runEvent - historyIdSet ::: ' + historyIdSet);

        List<AlertHistory__c> historyList = [
            SELECT  Id
                    , AlertManagerID__c
                    , AlertType__c
                    , AlertResult__c
                    , ErrorMsg__c
                    , TargetId__c
                    , Language__c
                    , Title__c
                    , Body__c
                    , BodyText__c
                    // bell
                    , ReceiverForBell__c
                    , CustomNotificationTypeId__c
                    , NotificationPageRef__c
                    // email
                    , Sender__c
                    , ReceiverForEmail__c
                    , ReceiverForEmailCC__c
                    , Attachment__c
                    // alarmTalk
                    , ReceiverForAlarmTalk__c
                    , ReplaceMap__c
                    , TemplateCode__c
            FROM    AlertHistory__c
            WHERE   AlertResult__c = 'Draft'
            AND     Id = : historyIdSet
        ];

        // File
        Set<String> fileIds = new Set<String>();
        for(AlertHistory__c history : historyList) {
            if(String.isBlank(history.Attachment__c)) continue;

            List<String> tempFileIds = history.Attachment__c.split(',');
            fileIds.addAll(tempFileIds);
        }

        Map<Id, Attachment>     attMap = new Map<Id, Attachment>();
        Map<Id, ContentVersion> cvMap  = new Map<Id, ContentVersion>();
        if(!fileIds.isEmpty()) {
            List<Attachment> attchList = [
                SELECT  Id, ParentId, Name, IsPrivate, ContentType, BodyLength, Body 
                FROM    Attachment 
                WHERE   Id IN: fileIds
            ];

            List<ContentVersion> cvList = [
                SELECT  Id, Title, VersionData, FileExtension, ContentDocumentId 
                FROM    ContentVersion 
                WHERE   ContentDocumentId IN: fileIds
            ];

            for(Attachment att : attchList) {
                attMap.put(att.Id, att);
            }

            for(ContentVersion cv : cvList) {
                cvMap.put(cv.ContentDocumentId, cv);
            }
        }

        List<OrgWideEmailAddress> owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress];

        List<AlertHistory__c> updateHistoryList = new List<AlertHistory__c>();
        for(AlertHistory__c history : historyList) {
            if(history.AlertType__c == 'Notification'){
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                try{

                    notification.setTitle(history.Title__c);
                    // notification.setBody(history.Body__c);
                    notification.setBody(history.BodyText__c);
                    notification.setNotificationTypeId(history.CustomNotificationTypeId__c);
                    if (history.NotificationPageRef__c == null) {
                        notification.setTargetId(history.TargetId__c);
                    } else {
                        String externalLink = '{type:\'standard__webPage\',attributes:{url:\'' + history.NotificationPageRef__c + '\'}}';
                        notification.setTargetPageRef(externalLink);
                    }

                    String notiUserStr = history.ReceiverForBell__c;
                    List<String> notiUserList = notiUserStr.split(',');
                    Set<String>  notiUserSet  = new Set<String>(notiUserList); 
                    notification.send(notiUserSet);

                    history.AlertResult__c  = 'Success';
                    history.SendDateTime__c      = System.now();
                    updateHistoryList.add(history);

                } catch(Exception e){
                    history.AlertResult__c = 'Fail';
                    history.ErrorMsg__c         = e.getMessage();
					updateHistoryList.add(history);
                    System.debug('runEvent - Notification Error ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
                }

            } else if(history.AlertType__c == 'Email') {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                try{
                    mail.setBccSender(false);
                    mail.setSubject(history.Title__c);
                    // mail.setHtmlBody(history.Body__c);
                    mail.setHtmlBody(history.BodyText__c);
                    
                    List<String> emailList = history.ReceiverForEmail__c.split(',');
                    mail.setToAddresses(emailList);

                    if(String.isNotBlank(history.ReceiverForEmailCC__c)) {
                        List<String> ccEmailList = history.ReceiverForEmailCC__c.split(',');
                        mail.setCcAddresses(ccEmailList);
                    }

                    mail.setOrgWideEmailAddressId(owea[0].Id);

                    // File
                    if(String.isNotBlank(history.Attachment__c)) {
                        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                        
                        List<String> attList = history.Attachment__c.split(',');
                        for(String attId : attList) {

                            if(attMap.containsKey(attId)) {
                                Attachment file = attMap.get(attId);

                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName(file.Name);
                                efa.setBody(file.Body);
                                efa.setContentType(file.ContentType);
                                attachments.add(efa);

                            } else if(cvMap.containsKey(attId)){
                                ContentVersion file = cvMap.get(attId);

                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName(file.Title + '.' + file.FileExtension);
                                efa.setBody(file.VersionData);
                                attachments.add(efa);
                            }
                        }
                        System.debug('runEvent - attachments ::: ' + attachments);

                        mail.setFileAttachments(attachments);
                    }
                    Messaging.sendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                    if (r[0].success) {
                        history.AlertResult__c  = 'Success';
                        history.SendDateTime__c = System.now();
                        updateHistoryList.add(history);
                    } else {
                        history.AlertResult__c = 'Fail';
                        history.ErrorMsg__c    = System.Label.DNS_M_NotiDeliveryFail + ' : ' + r[0].errors[0].message; // // Notification delivey failed.
                        updateHistoryList.add(history);
                        System.debug('runEvent - Email Error ::: ' + history.ErrorMsg__c);
                    }
                    
                } catch(Exception e){
                    history.AlertResult__c = 'Fail';
                    history.ErrorMsg__c         = e.getMessage();
					updateHistoryList.add(history);
                    System.debug('runEvent - Email Error ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
                }
            } else if (history.AlertType__c == 'AlarmTalk') {
                try {
                    Map<String, String> elementMap = (Map<String, String>) JSON.deserialize(history.ReplaceMap__c, Map<String, String>.class);
                    List<String> phoneList = history.ReceiverForAlarmTalk__c.split(',');

                    UTIL_Alert.futureAlarmTalkAPIcall(phoneList, history.TemplateCode__c, elementMap);

                    history.AlertResult__c  = 'Success';
                    history.SendDateTime__c = System.now();
                    updateHistoryList.add(history);
                } catch (Exception e) {
                    history.AlertResult__c = 'Fail';
                    history.ErrorMsg__c         = e.getMessage();
					updateHistoryList.add(history);
                    System.debug('runEvent - Email Error ::: ' + e.getLineNumber() + ' / ' + e.getMessage());
                }            
            }
        }
        System.debug('runEvent - updateHistoryList ::: ' + updateHistoryList);
        if(updateHistoryList.size() > 0) update updateHistoryList;
    }

}