/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 07-23-2025
 * @last modified by  : Hanyeong Choi
**/
public without sharing class DN_SQDateAlertBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    private static final String ALERT_NAME = 'SQ Registration Date Alert';
    private static final Set<String> EXCLUDED_STAGES = new Set<String>{'Final Confirm', 'Drop'};
    // private static final Set<String> INCLUDED_STAGES = new Set<String>{'R&D Review'};
    // private static final Set<String> TESTID = new Set<String>{'a02JO000001LE61YAG'};
    private static final List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
    private static final List<User> userInfo = [SELECT Id, Profile.UserLicense.Name, Email FROM User WHERE IsActive = true];

    /**
     * 배치 작업을 시작하며, 제외된 단계가 아닌 SQ Registration 레코드를 조회합니다.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        if(!Test.isRunningTest()) {
            query = 'SELECT Id, Stage__c, FM_DateAlert__c, ReviewRequestDate__c, Manager__c, Message_Group__c, OwnerId, Name ' +
                    'FROM SQRegistration__c ' +
                    'WHERE Stage__c NOT IN :EXCLUDED_STAGES AND FM_DateAlert__c < 3 ' +
                    // 'WHERE Stage__c NOT IN :EXCLUDED_STAGES AND FM_DateAlert__c < 3 AND Stage__c =: INCLUDED_STAGES AND Id =: TESTID ' +
                    'ORDER BY ReviewRequestDate__c DESC';
        } else {
            query = 'SELECT Id, Stage__c, FM_DateAlert__c, ReviewRequestDate__c, Manager__c, Message_Group__c, OwnerId, Name ' +
                    'FROM SQRegistration__c ' +
                    'WHERE Stage__c NOT IN :EXCLUDED_STAGES AND FM_DateAlert__c < 3 ' +
                    'ORDER BY ReviewRequestDate__c DESC LIMIT 100';
        }
        return Database.getQueryLocator(query);
    }

    /**
     * 배치 작업을 실행하여 알림 및 이메일을 전송하고, SQ Registration 데이터를 처리합니다.
     */
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<SQRegistration__c> sqrList = (List<SQRegistration__c>) scope;
        if (sqrList.isEmpty()) return;

        RecipientData data = prepareRecipientData(sqrList);

        List<UTIL_Alert.HistoryWrapper> notificationAlerts = new List<UTIL_Alert.HistoryWrapper>();
        List<UTIL_Alert.HistoryWrapper> emailAlerts = new List<UTIL_Alert.HistoryWrapper>();

        for (SQRegistration__c sqr : sqrList) {
            Recipients rec = getRecipientsForSqr(sqr, data);
            if (!rec.isEmpty()) {
                notificationAlerts.addAll(buildAlerts(new List<SQRegistration__c>{sqr}, rec, 'Notification', data.alertId));
                emailAlerts.addAll(buildAlerts(new List<SQRegistration__c>{sqr}, rec, 'Email', data.alertId));
            }
        }

        if (!notificationAlerts.isEmpty() && !Test.isRunningTest()) {
            UTIL_Alert.runAlertEvent(notificationAlerts);
        }
        if (!emailAlerts.isEmpty() && !Test.isRunningTest()) {
            UTIL_Alert.runAlertEvent(emailAlerts);
        }
    }

    /**
     * 배치 작업을 완료합니다.
     */
    public void finish(Database.BatchableContext bc) {}

    /**
     * 스케줄러를 통해 배치 작업을 실행합니다.
     */
    public void execute(SchedulableContext sc) {
        DN_SQDateAlertBatch batch = new DN_SQDateAlertBatch();
        Database.executeBatch(batch, 200);        
    }

    /**
     * 알림 및 이메일 수신자 데이터를 준비합니다.
     */
    private RecipientData prepareRecipientData(List<SQRegistration__c> sqrList) {
        RecipientData data = new RecipientData();
        Set<Id> sqrIds = new Set<Id>();
        Set<Id> managerIds = new Set<Id>();
        Set<Id> teamIds = new Set<Id>();

        for (SQRegistration__c sqr : sqrList) {
            if (sqr.Stage__c == 'R&D Review') {
                sqrIds.add(sqr.Id);
            }
            if (sqr.Manager__c != null) {
                managerIds.add(sqr.Manager__c);
            }
            if (sqr.Message_Group__c != null) {
                teamIds.add(sqr.Message_Group__c);
            }
        }

        if (!sqrIds.isEmpty()) {
            List<SQReview__c> reviews = getReviews(sqrIds);
            for (SQReview__c review : reviews) {
                if (!data.reviewsBySqr.containsKey(review.SQRegistration__c)) {
                    data.reviewsBySqr.put(review.SQRegistration__c, new List<SQReview__c>());
                }
                data.reviewsBySqr.get(review.SQRegistration__c).add(review);
            }
        }

        if (!managerIds.isEmpty()) {
            List<User> managers = DN_WithoutSharingClass.getUserEmails(managerIds);
            data.managersById = new Map<Id, User>(managers);
        }

        if (!teamIds.isEmpty()) {
            List<Message_Group_Junction__c> mgjs = getMessageGroupJunctions(teamIds);
            for (Message_Group_Junction__c mgj : mgjs) {
                if (!data.mgjsByGroup.containsKey(mgj.Message_Group__c)) {
                    data.mgjsByGroup.put(mgj.Message_Group__c, new List<Message_Group_Junction__c>());
                }
                data.mgjsByGroup.get(mgj.Message_Group__c).add(mgj);
            }
        }

        List<AlertManager__c> alertManagers = [SELECT Id FROM AlertManager__c WHERE Name = :ALERT_NAME LIMIT 1];
        data.alertId = alertManagers.isEmpty() ? null : alertManagers[0].Id;

        return data;
    }

    /**
     * 주어진 SQ Registration ID에 대한 리뷰 데이터를 가져옵니다.
     */
    private List<SQReview__c> getReviews(Set<Id> sqrIds) {
        return [
            SELECT  Id, Product_Representative__r.User__c, Product_Representative__r.MachineEmail__c,
                    Product_Representative__r.ControlUser__c, Product_Representative__r.ControlEmail__c,
                    Comments__c, KRWcost__c, Part__c, OwnerId, Owner.Email, Owner.IsActive, IsComplete__c, SQRegistration__c,
                    FM_OwnerManagerId__c, FM_OwnerManagerEmail__c //R&D담당자의 Manager추가_250723
            FROM SQReview__c
            WHERE SQRegistration__c IN :sqrIds
            AND Owner.IsActive = true
        ];
    }

    /**
     * 메시지 그룹 Junction 데이터를 가져옵니다.
     */
    public List<Message_Group_Junction__c> getMessageGroupJunctions(Set<Id> teamIds) {
        return [
            SELECT User__c, FM_UserEmail__c, FM_UserLanguage__c, User__r.IsActive, User__r.Email, Message_Group__c
            FROM Message_Group_Junction__c
            WHERE Message_Group__c IN :teamIds
            AND User__r.IsActive = true
        ];
    }

    /**
     * SQ Registration에 대한 수신자 정보를 가져옵니다.
     */
    private Recipients getRecipientsForSqr(SQRegistration__c sqr, RecipientData data) {
        Recipients recipients = new Recipients();

        if (data.reviewsBySqr.containsKey(sqr.Id)) {
            recipients.addFromReviews(data.reviewsBySqr.get(sqr.Id));
        }

        if (sqr.Manager__c != null) {
            User manager = data.managersById.get(sqr.Manager__c);
            if (manager != null && manager.IsActive) {
                recipients.addFromManagers(new List<User>{manager});
            }
        }

        if (sqr.Message_Group__c != null) {
            List<Message_Group_Junction__c> mgjs = data.mgjsByGroup.get(sqr.Message_Group__c);
            if (mgjs != null) {
                recipients.addFromMessageGroups(mgjs);
            }
        }

        return recipients;
    }

    /**
     * 알림을 전송합니다.
     */
    private void sendNotifications(List<SQRegistration__c> sqrList, Recipients recipients) {
        List<UTIL_Alert.HistoryWrapper> alerts = buildAlerts(sqrList, recipients, 'Notification', null);
        if (!alerts.isEmpty()) {
            UTIL_Alert.runAlertEvent(alerts);
        }
    }

    /**
     * 이메일을 전송합니다.
     */
    private void sendEmails(List<SQRegistration__c> sqrList, Recipients recipients) {
        List<UTIL_Alert.HistoryWrapper> emails = buildAlerts(sqrList, recipients, 'Email', null);
        if (!emails.isEmpty()) {
            UTIL_Alert.runAlertEvent(emails);
        }
    }

    /**
     * 알림 또는 이메일을 생성합니다.
     */
    private List<UTIL_Alert.HistoryWrapper> buildAlerts(List<SQRegistration__c> sqrList, Recipients recipients, String alertType, Id alertId) {
        if (alertId == null) return new List<UTIL_Alert.HistoryWrapper>();

        List<UTIL_Alert.HistoryWrapper> alerts = new List<UTIL_Alert.HistoryWrapper>();

        for (String language : new List<String>{'ko', 'en'}) {
            Set<Id> receiverIds;
            Set<String> receiverEmails;

            if (language == 'ko') {
                receiverIds = recipients.koIds;
                receiverEmails = recipients.koEmails;
            } else {
                receiverIds = recipients.enIds;
                receiverEmails = recipients.enEmails;
            }

            if (receiverIds.isEmpty() && receiverEmails.isEmpty()) continue;

            for (SQRegistration__c sqr : sqrList) {
                List<UTIL_Alert.HistoryWrapper> alert = createAlert(alertType, sqr, alertId, receiverEmails, language, receiverIds);
                if(!alert.isEmpty()){
                    for(Integer i = 0; i < alert.size(); i++){
                        alerts.add(alert[i]);
                    }
                }
            }
        }

        return alerts;
    }

    /**
     * 단일 알림 객체를 생성합니다.
     */
    private List<UTIL_Alert.HistoryWrapper> createAlert(String alertType, SQRegistration__c sqr, Id alertId, Set<String> receiverEmailSet, String language, Set<Id> receiverIds) {
        Map<Id, User> userMap = new Map<Id, User>();
        if(!userInfo.isEmpty()){
            for(User u : userInfo){
                userMap.put(u.Id, u);
            }
        }

        List<UTIL_Alert.HistoryWrapper> alerts = new List<UTIL_Alert.HistoryWrapper>();

        String message = (sqr.FM_DateAlert__c >= 0)
            ? (language == 'ko' ? '검토 완료 요청일로부터 ' + sqr.FM_DateAlert__c + '일 남았습니다.'
                                : 'You have ' + sqr.FM_DateAlert__c + ' days left from the review completion request date.')
            : (language == 'ko' ? '검토 완료 요청일로부터 ' + Math.abs(sqr.FM_DateAlert__c) + '일 초과 되었습니다.'
                                : 'It\'s been ' + Math.abs(sqr.FM_DateAlert__c) + ' days since your review completion request.');

        Set<String> receiverCRM = new Set<String>();
        Set<String> receiverRnD = new Set<String>();
        if(!receiverIds.isEmpty()){
            for(Id u : receiverIds){
                if(userMap.get(u).Profile.UserLicense.Name == 'Salesforce'){
                    receiverCRM.add(userMap.get(u).Email);
                }else{
                    receiverRnD.add(userMap.get(u).Email);
                }
            }

            if(!receiverCRM.isEmpty()){
                UTIL_Alert.HistoryWrapper alert = new UTIL_Alert.HistoryWrapper();
                    alert.alertType     = alertType;
                    alert.alertID       = alertId;
                    alert.targetID      = sqr.Id;
                    alert.alertLanguage = language;
                    alert.elementList.add(message);
                if (alertType == 'Email') {
                    alert.elementList.add(sqr.Name);
                    alert.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqr.Id);
                    alert.receiverforEmail = new List<String>(receiverCRM);
                } else {
                    alert.receiverforID = receiverIds;
                }
                alerts.add(alert);
            }

            if(!receiverRnD.isEmpty()){
                UTIL_Alert.HistoryWrapper alert = new UTIL_Alert.HistoryWrapper();
                    alert.alertType     = alertType;
                    alert.alertID       = alertId;
                    alert.targetID      = sqr.Id;
                    alert.alertLanguage = language;
                    alert.elementList.add(message);
                if (alertType == 'Email') {
                    alert.elementList.add(sqr.Name);
                    alert.elementList.add(Network.getLoginUrl(portal[0].Id).removeEnd('/s/login') + '/' + sqr.Id);
                    alert.receiverforEmail = new List<String>(receiverRnD);
                } else {
                    alert.receiverforID = receiverIds;
                }
                alerts.add(alert);
            }

        }
        return alerts;
    }

    /* 수신자 정보 wrapper */
    public class Recipients {
        public Set<Id> koIds = new Set<Id>();
        public Set<Id> enIds = new Set<Id>();
        public Set<String> koEmails = new Set<String>();
        public Set<String> enEmails = new Set<String>();

        /* 빈값 체크 */
        public Boolean isEmpty() {
            return koIds.isEmpty() && enIds.isEmpty();
        }

        /* SQReview__c의 Owner 추가 */
        public void addFromReviews(List<SQReview__c> reviews) {
            for (SQReview__c review : reviews) {
                if(review.Owner.IsActive && !review.IsComplete__c) {
                    if (review.OwnerId != null) koIds.add(review.OwnerId);
                    if (review.Owner.Email != null) koEmails.add(review.Owner.Email);
                    //R&D담당자의 manager추가_250723
                    if (review.FM_OwnerManagerId__c != null) koIds.add(review.FM_OwnerManagerId__c);
                    if (review.FM_OwnerManagerEmail__c != null) koEmails.add(review.FM_OwnerManagerEmail__c);

                }
            }
        }

        /* 유저의 manager 추가 */
        public void addFromManagers(List<User> managers) {
            for (User user : managers) {
                if (user.Email == null) continue;

                if (user.LanguageLocaleKey == 'ko') {
                    koIds.add(user.Id);
                    koEmails.add(user.Email);
                } else {
                    enIds.add(user.Id);
                    enEmails.add(user.Email);
                }
            }
        }

        /* message group의 유저 추가 */
        public void addFromMessageGroups(List<Message_Group_Junction__c> mgjs) {
            for (Message_Group_Junction__c mgj : mgjs) {
                if (mgj.FM_UserEmail__c == null || mgj.User__c == null) continue;

                if (mgj.FM_UserLanguage__c == 'ko') {
                    koIds.add(mgj.User__c);
                    koEmails.add(mgj.FM_UserEmail__c);
                } else {
                    enIds.add(mgj.User__c);
                    enEmails.add(mgj.FM_UserEmail__c);
                }
            }
        }
    }

    /* 수신자 데이터 */
    private class RecipientData {
        public Map<Id, List<SQReview__c>> reviewsBySqr = new Map<Id, List<SQReview__c>>();
        public Map<Id, User> managersById = new Map<Id, User>();
        public Map<Id, List<Message_Group_Junction__c>> mgjsByGroup = new Map<Id, List<Message_Group_Junction__c>>();
        public Id alertId;
    }
}