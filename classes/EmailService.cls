/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-25
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-26   yeongdeok.seo@sbtglobal.com   Initial Version
**/
global with sharing class EmailService implements Messaging.InboundEmailHandler {

    // EmailService 동작 메서드
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        Id caseId = EmailMessages.getRecordIdFromEmail(email.subject, email.plainTextBody, email.htmlBody);

        if (caseId != null) {
            TriggerHandler.bypass('EmailMessageTriggerHandler');
            TriggerHandler.bypass('ContentVersionTriggerHandler');
            TriggerHandler.bypass('ContentDocumentLinkTriggerHandler');
            TriggerHandler.bypass('ContentDocumentTriggerHandler');
            System.debug('attach ::: ' + email.binaryAttachments);
            EmailMessage em = [SELECT Id, Subject, TextBody, HtmlBody FROM EmailMessage WHERE ParentId = :caseId ORDER BY CreatedDate DESC LIMIT 1];
            System.debug('em ::: ' + em);

            if (em.TextBody != email.plainTextBody) {
                String toAddresses;
                if (email.toAddresses != null) {
                    toAddresses = String.join(email.toAddresses, '; ');
                }
        
                EmailMessage newEM = new EmailMessage(
                    Status = '0',
                    MessageIdentifier = email.messageId,
                    ParentId = caseId,
                    FromAddress = email.fromAddress,      
                    FromName = email.fromName,
                    ToAddress = toAddresses,
                    CcAddress = email.ccAddresses != null ? String.join(email.ccAddresses, ',') : null,
                    TextBody = email.plainTextBody,
                    HtmlBody = email.htmlBody,
                    Subject = email.subject,
                    ClientThreadIdentifier = getClientThreadIdentifier(email.headers)
                );
                Database.SaveResult sr = Database.insert(newEM);
                if (sr.isSuccess()) {
                     System.debug('newEMId ::: ' + sr.getId());
                     if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                         List<ContentVersion> cvList = new List<ContentVersion>();

                         for (Integer i = 0; i < email.binaryAttachments.size(); i++) {
                            
                             System.debug('email.binaryAttachments[i] ::: ' + email.binaryAttachments[i]);
                            
                             ContentVersion cv = new ContentVersion();
                             cv.VersionData = email.binaryAttachments[i].body;
                            cv.Title = String.valueOf(email.binaryAttachments[i].fileName);
                             cv.PathOnClient = String.valueOf(email.binaryAttachments[i].fileName);
                             cv.FirstPublishLocationId = sr.getId();
                             cvList.add(cv);
                         }

                         if (cvList.size() > 0) insert cvList;
                     }
                 }
                // 첨부파일 처리
        		//if (email.binaryAttachments != null && !email.binaryAttachments.isEmpty()) {
            	///List<ContentVersion> contentList = new List<ContentVersion>();

            	//for (Messaging.InboundEmail.BinaryAttachment att : email.binaryAttachments) {
                //Boolean isInline = false;

                // 첨부파일 헤더 확인
                //if (att.headers != null) {
                //    for (Messaging.InboundEmail.Header h : att.headers) {
                //         if (h.name.equalsIgnoreCase('Content-Disposition') && h.value.containsIgnoreCase('inline')) {
                //            isInline = true;
                //        }
                //        if (h.name.equalsIgnoreCase('Content-ID')) {
                //            isInline = true;
                //        }
                //    }
                //}

                	// 작은 이미지 파일은 로고/서명으로 간주
                //	if (isInline || (att.mimeTypeSubType.startsWithIgnoreCase('image') && att.body.size() < 50000)) {
                //    	System.debug('Skip Inline Attachment: ' + att.fileName);
                //    	continue;
                //	}

                	// ContentVersion 객체 생성
                //	ContentVersion cv = new ContentVersion();
                //	cv.Title = att.fileName;
                //	cv.PathOnClient = att.fileName;
                //	cv.VersionData = att.body;
                //	cv.FirstPublishLocationId = sr.getId();

                //	contentList.add(cv);
            	//}

            	//if (!contentList.isEmpty()) {
                //	insert contentList;
                //	System.debug('Saved attachments: ' + contentList.size());
            	//}
        	//}
               System.debug('New EmailMessage Object: ' + newEM );
            }
        }
        TriggerHandler.clearAllBypasses();
        result.success = true;
        
        return result;
    }

    private String getClientThreadIdentifier(List<Messaging.InboundEmail.Header> headers) {
        if (headers == null || headers.size() == 0) return null;
        try {
            for (Messaging.InboundEmail.Header header : headers) {
                if (header.name.equalsIgnoreCase('thread-index')) {
                    Blob threadIndex = EncodingUtil.base64Decode(header.value.trim());
                    return EncodingUtil.convertToHex(threadIndex).substring(0, 44).toUpperCase();
                }
            }
        } catch (Exception e){
            return null;
        }
        return null;
      }
}