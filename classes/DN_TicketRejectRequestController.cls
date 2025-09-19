/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 09-01-2025
 * @last modified by  : Hanyeong Choi
**/
public with sharing class DN_TicketRejectRequestController {

    /**
     * 티켓 거절 요청을 처리하고 알림 및 이메일을 전송합니다.
     */
    @AuraEnabled
    public static string sendTicketRejectRequest(String recordId, String reason) {
        try {
            Case ticket = [
                SELECT  Id
                        , OwnerId 
                        , FM_TicketName__c
                FROM Case 
                WHERE Id = :recordId 
                LIMIT 1
            ];

            sendTicketRejectRequestNoti(ticket, reason);
            sendTicketRejectRequestEmail(ticket, reason);
            
            return 'Success';
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            // throw new AuraHandledException(e.getMessage());
            return 'Error';
        }
    }

    /**
     * 티켓 거절 요청에 대한 알림을 전송합니다.
     */
    private static void sendTicketRejectRequestNoti(Case ticket, String reason) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Ticket Reject Request Alert' LIMIT 1];
        
        User u = DN_WithoutSharingClass.getUserEmail(ticket.OwnerId);
        if(u.LanguageLocaleKey == 'ko') {
            receiver.add(u.Id);
        } else {
            receiverEN.add(u.Id);
        }

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(ticket.FM_TicketName__c);
                history.alertID         = am[0].Id;
                history.targetID        = ticket.Id;
                history.receiverforID   = receiver;
                history.alertLanguage   = 'ko';
                ahwList.add(history);
            }

            if(!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(ticket.FM_TicketName__c);
                history.alertID         = am[0].Id;
                history.targetID        = ticket.Id;
                history.receiverforID   = receiverEN;
                history.alertLanguage   = 'en';
                ahwList.add(history);
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * 티켓 거절 요청에 대한 이메일 알림을 전송합니다.
     */
    private static void sendTicketRejectRequestEmail(Case ticket, String reason) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();
        Map<String, Boolean> emailToIsPortalUser = new Map<String, Boolean>();

        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
        String crmUrl = URL.getOrgDomainURL().toExternalForm();

        User u = DN_WithoutSharingClass.getUserEmail(ticket.OwnerId);
        Boolean isPortalUser = false;
        if(u.IsPortalEnabled) {
            isPortalUser = true;
        }
        if (u.LanguageLocaleKey == 'ko') {
            receiver.add(u.Email);
        } else {
            receiverEN.add(u.Email);
        }
        emailToIsPortalUser.put(u.Email, isPortalUser);

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Ticket Reject Request Alert' LIMIT 1];
        if (!am.isEmpty()) {
            if (!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType = 'Email';
                history.elementList.add(ticket.FM_TicketName__c);
                history.elementList.add(reason);

                Boolean hasPortalUser = false;
                for (String email : receiver) {
                    if (emailToIsPortalUser.get(email)) {
                        hasPortalUser = true;
                        break;
                    }
                }
                String url = hasPortalUser ? baseUrl : crmUrl;
                history.elementList.add(url + '/' + ticket.Id);
                history.alertID = am[0].Id;
                history.targetID = ticket.Id;
                history.receiverforEmail = receiver;
                history.alertLanguage = 'ko';
                ahwList.add(history);
            }

            if (!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType = 'Email';
                history.elementList.add(ticket.FM_TicketName__c);
                history.elementList.add(reason);

                Boolean hasPortalUser = false;
                for (String email : receiverEN) {
                    if (emailToIsPortalUser.get(email)) {
                        hasPortalUser = true;
                        break;
                    }
                }
                String url = hasPortalUser ? baseUrl : crmUrl;
                history.elementList.add(url + '/' + ticket.Id);
                history.alertID = am[0].Id;
                history.targetID = ticket.Id;
                history.receiverforEmail = receiverEN;
                history.alertLanguage = 'en';
                ahwList.add(history);
            }

            if (!ahwList.isEmpty()) {
                UTIL_Alert.runAlertEvent(ahwList);
            }
        }
        return;
    }
}