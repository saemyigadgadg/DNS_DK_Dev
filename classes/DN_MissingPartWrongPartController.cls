/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public without sharing class DN_MissingPartWrongPartController {

    // @AuraEnabled
    // public static Map<String, String> getWorkOrder(Id recordId) {
    //     String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
    //     Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
    //     if (isDNSA) {
    //         // 빈 맵 생성
    //         // return new Map<String, String>();
    //         System.debug('dnsa');
    //         WorkOrder wo = [
    //             SELECT Id, OrderType__c, AccountId, ContactId, AssetId
    //             FROM WorkOrder 
    //             WHERE Id = :recordId 
    //             LIMIT 1
    //         ];
    //         System.debug('wo:::' + wo);

    //         if (wo.AccountId == null || wo.ContactId == null || wo.AssetId == null) {
    //             System.debug('WorkOrder를 찾을 수 없습니다.');
    //             Map<String, String> result = new Map<String, String>();
    //             result.put('status', 'SUCCESS');
    //             result.put('accountId', wo.AccountId != null ? wo.AccountId : '');
    //             // result.put('contactId', wo.ContactId != null ? wo.ContactId : '');
    //             result.put('assetId', wo.AssetId != null ? wo.AssetId : '');
    //             result.put('status', 'NO_DATA'); 
    //             return result;
    //         } else {
    //             Map<String, String> result = new Map<String, String>();
    //             result.put('status', 'SUCCESS');
    //             result.put('accountId', wo.AccountId != null ? wo.AccountId : '');
    //             result.put('contactId', wo.ContactId != null ? wo.ContactId : '');
    //             result.put('assetId', wo.AssetId != null ? wo.AssetId : '');
                
    //             return result;
    //         }
            
        
    //     } else {
    //         WorkOrder wo = [
    //             SELECT Id, OrderType__c, AccountId, ContactId, AssetId
    //             FROM WorkOrder 
    //             WHERE Id = :recordId 
    //             LIMIT 1
    //         ];
    //         System.debug('wo:::' + wo);
            
    //         Map<String, String> result = new Map<String, String>();
    //         result.put('status', 'SUCCESS');
    //         result.put('accountId', wo.AccountId != null ? wo.AccountId : '');
    //         result.put('contactId', wo.ContactId != null ? wo.ContactId : '');
    //         result.put('assetId', wo.AssetId != null ? wo.AssetId : '');
        
    //         if (wo.OrderType__c != '104') {
    //             System.debug('설치오더가 아닙니다.');
    //             result.put('status', 'NO_INSTALL'); 
    //         }
        
    //         return result;
    //     }
    // }

    // Ticket 생성 메서드
    @AuraEnabled
    public static void createTicket(Id accountId, Id contactId, Id assetId, String receiptDetails, List<String> uploadedFileIds) {
        try {
            String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
            Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
            System.debug('AccountId: ' + accountId);
            System.debug('ContactId: ' + contactId);
            System.debug('AssetId: ' + assetId);
            System.debug('receiptDetails: ' + receiptDetails);
            System.debug('uploadedFiles: ' + uploadedFileIds);

            Id currentUserId = UserInfo.getUserId();

            Id dnsRecordTypeId;
            try {
                dnsRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Ticket(DNSA)' AND SObjectType = 'Case' LIMIT 1].Id;
            } catch (Exception e) {
                System.debug('RecordType "DNSA" not found: ' + e.getMessage());
                return;
            }

            // 새로운 Case 생성
            Case newCase = new Case();
            newCase.AccountId = accountId;
            newCase.Requester__c = contactId;
            newCase.AssetId = assetId;
            newCase.ReceptionPath__c = 'Mobile Indirect application';
            newCase.Status = 'New';
            newCase.ReceptionDetails__c = receiptDetails;
            newCase.TicketType__c = 'Internal request';
            newCase.InternalTicketType__c = 'Missing Part, Wrong Part';
            DateTime dt = System.now();
            newCase.ApplicationDateTime__c = dt;
            newCase.BreakdownDateTime__c = dt;
            newCase.Is_MissingPart_WrongPart__c = true;
            newCase.InternalRequester__c = currentUserId;
            if (isDNSA) {
                newCase.RecordTypeId = dnsRecordTypeId;
            }

            System.debug('newCase:::'+newCase);
            insert newCase;

            List<ContentDocumentLink> links = new List<ContentDocumentLink>();
            for (String fileId : uploadedFileIds) {
                links.add(new ContentDocumentLink(
                    ContentDocumentId = fileId,
                    LinkedEntityId = newCase.Id,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                ));
            }
            insert links;

        } catch (Exception ex) {
            System.debug('Ticket Creation Failed: ' + ex.getMessage());
        }
    }

    // 파일 업로드 메서드
    @AuraEnabled
    public static Id uploadFileContentVersion(String fileName, String base64Data, String contentType) {
        try {
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
            contentVersion.IsMajorVersion = true;
            // contentVersion.ContentType = contentType;
            insert contentVersion;
            return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading file: ' + e.getMessage());
        }
    }

    // public static void executeFlow(String recordId) {
    //     try {
    //         // Flow 실행 인수 설정
    //         Map<String, Object> flowInputs = new Map<String, Object>();
    //         flowInputs.put('Id', recordId);
    
    //         // Flow 호출
    //         Flow.Interview flowInterview = Flow.Interview.createInterview('CS_FieldServiceMobileFlow', flowInputs);
    //         flowInterview.start();
    
    //         // 성공 로그
    //         System.debug('Flow executed successfully with recordId: ' + recordId);
    //     } catch (Exception ex) {
    //         System.debug('Error executing flow: ' + ex.getMessage());
    //         throw new AuraHandledException('Error executing flow: ' + ex.getMessage());
    //     }
    // }
}