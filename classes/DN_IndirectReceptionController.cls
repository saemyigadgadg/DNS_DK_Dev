/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 07-22-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public without sharing class DN_IndirectReceptionController {

    // 티켓 생성 메서드
    @AuraEnabled
    public static String createTicket(Id accountId, Id contactId, Id assetId, String dispatchStatus, String completionStatus, String receiptDetails, Datetime onsiteDateTime) {
        String salesOrg = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()].SalesOrganization__c;
        Boolean isDNSA = (salesOrg == '4140' || salesOrg == '4146');
        System.debug('AccountId: ' + accountId);
        System.debug('ContactId: ' + contactId);
        System.debug('AssetId: ' + assetId);
        System.debug('Dispatch Status: ' + dispatchStatus);
        System.debug('Completion Status: ' + completionStatus);
        System.debug('receiptDetails: ' + receiptDetails);
        System.debug('onsiteDateTime: ' + onsiteDateTime);

        Id currentUserId = UserInfo.getUserId();
        System.debug('currentUserId:::' + currentUserId);

        // DNS
        if (assetId != null && !isDNSA) {
            Asset asset = [SELECT Id, AccountId FROM Asset WHERE Id = :assetId];
            if (asset.AccountId != accountId) {
                System.debug('선택한 Asset의 고객 정보가 일치하지 않습니다.');
                return 'NOACCOUNT';
                // throw new AuraHandledException('선택한 Asset의 고객 정보가 일치하지 않습니다.');
            }
        }
        // DNSA
        if (assetId != null && isDNSA) {
            Asset asset = [SELECT Id, AccountId FROM Asset WHERE Id = :assetId];
            if (asset.AccountId != accountId) {
                System.debug('선택한 Asset의 고객 정보가 일치하지 않습니다.');
                return 'NOACCOUNTDNSA';
                // throw new AuraHandledException('선택한 Asset의 고객 정보가 일치하지 않습니다.');
            }
        }

        Id dnsRecordTypeId;
        if (isDNSA) {
            dnsRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Ticket(DNSA)' AND SObjectType = 'Case' LIMIT 1].Id;
        }
        // try {
        //     dnsRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Ticket(DNSA)' AND SObjectType = 'Case' LIMIT 1].Id;
        // } catch (Exception e) {
        //     System.debug('RecordType DNSA not found: ' + e.getMessage());
        //     return;
        // }

        // 새로운 Case 생성
        Case newCase = new Case();
        newCase.AccountId = accountId;
        newCase.Requester__c = contactId;
        newCase.AssetId = assetId;
        newCase.ReceptionPath__c = 'Mobile Indirect application';
        newCase.Status = 'New';
        newCase.ReceptionDetails__c = receiptDetails;
        newCase.TicketType__c = 'Technical inquiry';
        newCase.InternalTicketType__c = 'Failure receipt';
        newCase.InternalRequester__c = currentUserId;
        if (isDNSA) {
            newCase.RecordTypeId = dnsRecordTypeId;
        }
    
        // Ticket 수리요청일시 반드시 입력해야 Work Order 생성 가능함!! 중요함다.
        DateTime dt = System.now();
        newCase.RepairRequestDateTime__c = dt.addHours(1); //수리요청일시는 접수일시  + 1시간
        if(onsiteDateTime == null) {
            newCase.ApplicationDateTime__c = dt; // 접수일시
        } else {
            newCase.ApplicationDateTime__c = onsiteDateTime; // 접수일시
        }
        newCase.BreakdownDateTime__c = dt;
        
        // Case를 삽입
        Database.SaveResult sr = Database.insert(newCase);
        if (sr.isSuccess()) {
            System.debug('New Case Id: ' + sr.getId());
        } else {
            System.debug('Case Insert Failed: ' + sr.getErrors());
            return'CASEFAIL'; // Case 생성 실패 시 종료
        }

        try {
            if (dispatchStatus == 'Dispatch') {
                // WorkOrder와 Case의 상태 설정
                if (completionStatus == 'Complete') {
                    newCase.Status = 'New';
                    // newCase.EndOfReason__c = 'Dispatch completed';
                } else if (completionStatus == 'Not Complete') {
                    newCase.Status = 'New';
                }
                update newCase;

            } else if (dispatchStatus == 'Not Dispatch') {
                if (completionStatus == 'Complete') {
                    newCase.Status = 'New';
                } else if (completionStatus == 'Not Complete') {
                    newCase.Status = 'New';
                }
                update newCase; // 상태 변경 후 Case 업데이트
            }
            newCase.ReceptionDetails__c = receiptDetails + ' | Dispatched: ' + dispatchStatus + ' | Completed: ' + completionStatus;
            update newCase; // 오류 메시지를 포함하여 Case 업데이트
        } catch (Exception ex) {
            System.debug('WorkOrder Creation Failed: ' + ex.getMessage());
        }
        return 'SUCCESS';
    }
}