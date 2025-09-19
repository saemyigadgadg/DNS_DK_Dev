/**
 * @author            : Se-Jin Kwon
 * @description       : 
 *  - 영업기회 단계 이동 일정 기간이상 이동 없을 시 알림 (기준일 * 1.5 했을 때 날짜 되었을 때 알림)
 *  - 단계이동 이외 어떤 필드도 업데이트 없을 경우 60일 이상 초과 시 알림
 * @last modified on  : 2025-05-26
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-10-31   SEJIN KWON                 Initial Version
**/
public class DN_OpportunityActivityAlertBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    // 내부 클래스 정의
    private class OpportunityNotification {
        public Id opportunityId { get; set; }
        public Id ownerId { get; set; }
        public String message { get; set; }
        public Integer duration { get; set; }
        public String email { get; set; }
        public String lang { get; set; }
        public String license { get; set; }
        public String accName { get; set; }
        public String opptyName { get; set; }

        // 생성자
        public OpportunityNotification(Id opportunityId, Id ownerId, String message, Integer duration, String email, String lang, String license, String accName, String opptyName) {
            this.opportunityId = opportunityId;
            this.ownerId = ownerId;
            this.message = message;
            this.duration = duration;
            this.email = email;
            this.lang = lang;
            this.license = license;
            this.accName = accName;
            this.opptyName = opptyName;
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT
                Id,
                Name,
                StageName,
                CreatedDate,
                LastModifiedDate,
                Account.Name,

                OpportunityIdentifier__c,
                OpportunityIdentifier__r.Email,
                OpportunityIdentifier__r.LanguageLocaleKey,
                OpportunityIdentifier__r.Profile.UserLicense.Name,

                Opportunity_Owner__c,
                Opportunity_Owner__r.Email,
                Opportunity_Owner__r.LanguageLocaleKey,
                Opportunity_Owner__r.Profile.UserLicense.Name,

                Opportunity_Owner__r.Profile.Name
            FROM
                Opportunity
            WHERE
                StageName NOT IN ('Closed Won', 'Closed Drop', 'Closed Lost')
                and OpportunityIdentifier__c != null 
                and RecordType.Name IN ('General','Turn-Key (AE)')
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope){
        List<Opportunity> identifiedOppty = new List<Opportunity>();//current stage identified Global 30일 * 1.5
        List<Opportunity> identifiedOpptyKR = new List<Opportunity>();//current stage identified 한국 15일 * 1.5

        List<Opportunity> validatedOppty = new List<Opportunity>();//current stage validated Global 30일 * 1.5
        Set<Id> validatedOpptyId = new Set<Id>();

        List<Opportunity> validatedOpptyKR = new List<Opportunity>();//current stage validated 한국 15일 * 1.5
        Set<Id> validatedOpptyIdKR = new Set<Id>();

        List<Opportunity> qualifiedOppty = new List<Opportunity>();//current stage qualified Global, 한국 60일 * 1.5 공통
        Set<Id> qualifiedOpptyId = new Set<Id>();

        List<Opportunity> conditionOppty = new List<Opportunity>();//current stage conditional Global 30일 * 1.5
        Set<Id> conditionOpptyId = new Set<Id>();

        List<Opportunity> conditionOpptyKR = new List<Opportunity>();//current stage conditional 한국 15일 * 1.5
        Set<Id> conditionOpptyIdKR = new Set<Id>();

        List<Opportunity> alertOppty = new List<Opportunity>();//60일 초과동안 아무 update없음
        Set<Id> alertOpptyId = new Set<Id>();

        List<OpportunityNotification> notifications = new List<OpportunityNotification>();
        List<OpportunityNotification> setnotifications = new List<OpportunityNotification>();

        Date today = Date.today();
        //Stage별 추출
        for(Opportunity opp : scope){
            if(opp.StageName == 'Identified' && opp.Opportunity_Owner__r.Profile.Name.contains('영업 글로벌 대리점')){
                identifiedOppty.add(opp);
            }else if(opp.StageName == 'Identified' && (opp.Opportunity_Owner__r.Profile.Name.contains('영업 직영영업') || opp.Opportunity_Owner__r.Profile.Name.contains('영업 국내 대리점'))){
                identifiedOpptyKR.add(opp);

            }else if(opp.StageName == 'Validated' && opp.Opportunity_Owner__r.Profile.Name.contains('영업 글로벌 대리점')){
                validatedOppty.add(opp);
                validatedOpptyId.add(opp.Id);
            }else if(opp.StageName == 'Validated' && (opp.Opportunity_Owner__r.Profile.Name.contains('영업 직영영업') || opp.Opportunity_Owner__r.Profile.Name.contains('영업 국내 대리점'))){
                validatedOpptyKR.add(opp);
                validatedOpptyIdKR.add(opp.Id);

            }else if(opp.StageName == 'Qualified' && (opp.Opportunity_Owner__r.Profile.Name.contains('영업 직영영업') || opp.Opportunity_Owner__r.Profile.Name.contains('영업 국내 대리점') || opp.Opportunity_Owner__r.Profile.Name.contains('영업 글로벌 대리점'))){
                qualifiedOppty.add(opp);
                qualifiedOpptyId.add(opp.Id);

            }else if(opp.StageName == 'Conditional Agreement' && opp.Opportunity_Owner__r.Profile.Name.contains('영업 글로벌 대리점')){
                conditionOppty.add(opp);
                conditionOpptyId.add(opp.Id);
            }else if(opp.StageName == 'Conditional Agreement' && (opp.Opportunity_Owner__r.Profile.Name.contains('영업 직영영업') || opp.Opportunity_Owner__r.Profile.Name.contains('영업 국내 대리점'))){
                conditionOpptyKR.add(opp);
                conditionOpptyIdKR.add(opp.Id);
            }

            if(opp.LastModifiedDate.date().daysBetween(today) > 60 || System.Test.isRunningTest()){
                alertOppty.add(opp);
                alertOpptyId.add(opp.Id);
            }
        }
        for(Opportunity oppStg : identifiedOppty){ //identified global 30일 * 1.5
            Integer duration = oppStg.CreatedDate.date().daysBetween(today);
            if(duration > 45 || System.Test.isRunningTest()){
                notifications.add(new OpportunityNotification(
                                                                oppStg.Id, 
                                                                oppStg.OpportunityIdentifier__c, 
                                                                'Identified', 
                                                                duration, 
                                                                oppStg.OpportunityIdentifier__r.Email,
                                                                oppStg.OpportunityIdentifier__r.LanguageLocaleKey,
                                                                oppStg.OpportunityIdentifier__r.Profile.UserLicense.Name,
                                                                oppStg.Account.Name,
                                                                oppStg.Name
                                                            ));
            }
        }

        for(Opportunity oppStg : identifiedOpptyKR){ //identified 한국 15일 * 1.5
            Integer duration = oppStg.CreatedDate.date().daysBetween(today);
            if(duration > 23 || System.Test.isRunningTest()){
                notifications.add(new OpportunityNotification(
                                                                oppStg.Id, 
                                                                oppStg.OpportunityIdentifier__c, 
                                                                'Identified', 
                                                                duration, 
                                                                oppStg.OpportunityIdentifier__r.Email,
                                                                oppStg.OpportunityIdentifier__r.LanguageLocaleKey,
                                                                oppStg.OpportunityIdentifier__r.Profile.UserLicense.Name,
                                                                oppStg.Account.Name,
                                                                oppStg.Name
                                                            ));
            }
        }

        //current가 validated인 record 조회 Global
        List<Opportunity_Stage_Tracker__c> vadlidateTracker = 
        [SELECT 
            Id, 
            Opportunity__c, 
            OwnerId,
            CreatedDate,
            Opportunity__r.Opportunity_Owner__r.Email,
            Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey,
            Opportunity__r.Opportunity_Owner__r.Profile.UserLicense.Name,
            Opportunity__r.Account.Name,
            Opportunity__r.Name
        FROM 
            Opportunity_Stage_Tracker__c 
        WHERE
            StageName__c = 'Identified' and Opportunity__c IN: validatedOpptyId];

        for(Opportunity_Stage_Tracker__c oppStg : vadlidateTracker){
            Integer duration = oppStg.CreatedDate.date().daysBetween(today);
            if(duration > 45 || System.Test.isRunningTest()){
                System.debug('Opportunity ID: ' + oppStg.Id + ', Duration: ' + duration);
                notifications.add(new OpportunityNotification(  oppStg.Id, 
                                                                oppStg.OwnerId, 
                                                                'Validated', 
                                                                duration, 
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.Email,
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey,
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.Profile.UserLicense.Name,
                                                                oppStg.Opportunity__r.Account.Name,
                                                                oppStg.Opportunity__r.Name
                                                            ));
            }
        }

        //current가 validated인 record 조회 한국
        List<Opportunity_Stage_Tracker__c> vadlidateTrackerKR = 
        [SELECT 
            Id, 
            Opportunity__c, 
            OwnerId,
            CreatedDate,
            Opportunity__r.Opportunity_Owner__r.Email,
            Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey,
            Opportunity__r.Opportunity_Owner__r.Profile.UserLicense.Name,
            Opportunity__r.Account.Name,
            Opportunity__r.Name
        FROM 
            Opportunity_Stage_Tracker__c 
        WHERE
            StageName__c = 'Identified' and Opportunity__c IN: validatedOpptyIdKR];

        for(Opportunity_Stage_Tracker__c oppStg : vadlidateTrackerKR){
            Integer duration = oppStg.CreatedDate.date().daysBetween(today);
            if(duration > 23 || System.Test.isRunningTest()){
                System.debug('Opportunity ID: ' + oppStg.Id + ', Duration: ' + duration);
                notifications.add(new OpportunityNotification(  oppStg.Id, 
                                                                oppStg.OwnerId, 
                                                                'Validated', 
                                                                duration, 
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.Email,
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey,
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.Profile.UserLicense.Name,
                                                                oppStg.Opportunity__r.Account.Name,
                                                                oppStg.Opportunity__r.Name
                                                            ));
            }
        }


        //current가 qualified인 record 조회
        List<Opportunity_Stage_Tracker__c> qualifiedTracker = 
        [SELECT 
            Id, 
            Opportunity__c, 
            OwnerId,
            CreatedDate ,
            Opportunity__r.Opportunity_Owner__r.Email,
            Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey,
            Opportunity__r.Opportunity_Owner__r.Profile.UserLicense.Name,
            Opportunity__r.Account.Name,
            Opportunity__r.Name
        FROM 
            Opportunity_Stage_Tracker__c 
        WHERE
            StageName__c = 'Validated' and Opportunity__c IN: qualifiedOpptyId];
        for(Opportunity_Stage_Tracker__c oppStg : qualifiedTracker){
            Integer duration = oppStg.CreatedDate.date().daysBetween(today);
            if(duration > 90 || System.Test.isRunningTest()){
                notifications.add(new OpportunityNotification(  oppStg.Id, 
                                                                oppStg.OwnerId, 
                                                                'Qualified', 
                                                                duration, 
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.Email,
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey,
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.Profile.UserLicense.Name,
                                                                oppStg.Opportunity__r.Account.Name,
                                                                oppStg.Opportunity__r.Name
                                                            ));
            }
        }

        //current가 conditional인 record 조회 Global
        List<Opportunity_Stage_Tracker__c> conditionTracker = 
        [SELECT 
            Id, 
            Opportunity__c, 
            OwnerId,
            CreatedDate,
            Opportunity__r.Opportunity_Owner__r.Email,
            Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey,
            Opportunity__r.Opportunity_Owner__r.Profile.UserLicense.Name,
            Opportunity__r.Account.Name,
            Opportunity__r.Name
        FROM 
            Opportunity_Stage_Tracker__c 
        WHERE
            StageName__c = 'Qualified' and Opportunity__c IN: conditionOpptyId];
        for(Opportunity_Stage_Tracker__c oppStg : conditionTracker){
            Integer duration = oppStg.CreatedDate.date().daysBetween(today);
            if(duration > 45 || System.Test.isRunningTest()){
                notifications.add(new OpportunityNotification(  oppStg.Id, 
                                                                oppStg.OwnerId, 
                                                                'Conditional Agreement', 
                                                                duration, 
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.Email,
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey,
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.Profile.UserLicense.Name,
                                                                oppStg.Opportunity__r.Account.Name,
                                                                oppStg.Opportunity__r.Name
                                                            ));
            }
        }

        //current가 conditional인 record 조회 한국
        List<Opportunity_Stage_Tracker__c> conditionTrackerKR = 
        [SELECT 
            Id, 
            Opportunity__c, 
            OwnerId,
            CreatedDate,
            Opportunity__r.Opportunity_Owner__r.Email,
            Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey,
            Opportunity__r.Opportunity_Owner__r.Profile.UserLicense.Name,
            Opportunity__r.Account.Name,
            Opportunity__r.Name
        FROM 
            Opportunity_Stage_Tracker__c 
        WHERE
            StageName__c = 'Qualified' and Opportunity__c IN: conditionOpptyIdKR];
        for(Opportunity_Stage_Tracker__c oppStg : conditionTrackerKR){
            Integer duration = oppStg.CreatedDate.date().daysBetween(today);
            if(duration > 23 || System.Test.isRunningTest()){
                notifications.add(new OpportunityNotification(  oppStg.Id, 
                                                                oppStg.OwnerId, 
                                                                'Conditional Agreement', 
                                                                duration, 
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.Email,
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.LanguageLocaleKey,
                                                                oppStg.Opportunity__r.Opportunity_Owner__r.Profile.UserLicense.Name,
                                                                oppStg.Opportunity__r.Account.Name,
                                                                oppStg.Opportunity__r.Name
                                                            ));
            }
        }

        //60일 이상 활동 없는 레코드
        for(Opportunity oppStg : alertOppty){
            Integer duration = oppStg.LastModifiedDate.date().daysBetween(today);
            if(oppStg.StageName == 'Identified'){
                notifications.add(new OpportunityNotification(  oppStg.Id, 
                                                                oppStg.OpportunityIdentifier__c, 
                                                                'No Activity', 
                                                                duration, 
                                                                oppStg.OpportunityIdentifier__r.Email,
                                                                oppStg.OpportunityIdentifier__r.LanguageLocaleKey,
                                                                oppStg.OpportunityIdentifier__r.Profile.UserLicense.Name,
                                                                oppStg.Account.Name,
                                                                oppStg.Name
                                                            ));
            }else{
                notifications.add(new OpportunityNotification(  oppStg.Id, 
                                                                oppStg.Opportunity_Owner__c, 
                                                                'No Activity', 
                                                                duration, 
                                                                oppStg.Opportunity_Owner__r.Email,
                                                                oppStg.Opportunity_Owner__r.LanguageLocaleKey,
                                                                oppStg.Opportunity_Owner__r.Profile.UserLicense.Name,
                                                                oppStg.Account.Name,
                                                                oppStg.Name
                                                            ));
            }
        }
        System.debug('noti size : ' + notifications.size());
        System.debug(notifications);
        Set<Id> setownerId = new Set<Id>();
        for(OpportunityNotification ownerId : notifications){
            setownerId.add(ownerId.ownerId);
        }
        
        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        List<UTIL_Alert.HistoryWrapper> totalEmail = new List<UTIL_Alert.HistoryWrapper>();

        for(String ownerId : setownerId){
            String stageMessage = '';
            String activityMessage = '';
            String email;
            String lang;
            Integer stageCount = 0;
            Integer activityCount = 0;
            for(OpportunityNotification setoppNoti : notifications){
                if(setoppNoti.ownerId == ownerId){
                    String baseUrl;
                    String recordLink;

                    if(setoppNoti.license != null && setoppNoti.license.contains('Partner Community')){
                        baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
                        recordLink = baseUrl + '/' + setoppNoti.opportunityId;
                    }else{
                        baseUrl = URL.getOrgDomainUrl().toExternalForm();
                        recordLink = baseUrl + '/' + setoppNoti.opportunityId;
                    }
    
                    String instanceUrl = recordLink;

                    if(setoppNoti.message == 'No Activity'){
                        if(setoppNoti.lang == 'ko'){
                            activityMessage += 
                            + '고객사 : ' + setoppNoti.accName + '<br>' 
                            + '영업기회 : ' + setoppNoti.opptyName + '<br>' 
                            + '영업단계 : ' + setoppNoti.message + '<br>' 
                            + '초과일수 : ' + setoppNoti.duration + '<br>'
                            + '링크 : ' + instanceUrl + '<br><br>';
                        }else if(setoppNoti.lang == 'en_US'){
                            activityMessage += 
                            + 'Account : ' + setoppNoti.accName + '<br>' 
                            + 'Opportunity : ' + setoppNoti.opptyName + '<br>' 
                            + 'Stage or Activity : ' + setoppNoti.message + '<br>' 
                            + 'Duration : ' + setoppNoti.duration + '<br>'
                            + 'Link : ' + instanceUrl + '<br><br>';
                        }else{
                            activityMessage += 
                            + '고객사 : ' + setoppNoti.accName + '<br>' 
                            + '영업기회 : ' + setoppNoti.opptyName + '<br>' 
                            + '영업단계 : ' + setoppNoti.message + '<br>' 
                            + '초과일수 : ' + setoppNoti.duration + '<br>'
                            + '링크 : ' + instanceUrl + '<br><br>';
                        }
                        email = setoppNoti.email;
                        lang = setoppNoti.lang;
                        activityCount++;
                    }else{
                        if(setoppNoti.lang == 'ko'){
                            stageMessage += 
                            + '고객사 : ' + setoppNoti.accName + '<br>' 
                            + '영업기회 : ' + setoppNoti.opptyName + '<br>' 
                            + '영업단계 : ' + setoppNoti.message + '<br>' 
                            + '초과일수 : ' + setoppNoti.duration + '<br>'
                            + '링크 : ' + instanceUrl + '<br><br>';
                        }else if(setoppNoti.lang == 'en_US'){
                            stageMessage += 
                            + 'Account : ' + setoppNoti.accName + '<br>' 
                            + 'Opportunity : ' + setoppNoti.opptyName + '<br>' 
                            + 'Stage or Activity : ' + setoppNoti.message + '<br>' 
                            + 'Duration : ' + setoppNoti.duration + '<br>'
                            + 'Link : ' + instanceUrl + '<br><br>';
                        }else{
                            stageMessage += 
                            + '고객사 : ' + setoppNoti.accName + '<br>' 
                            + '영업기회 : ' + setoppNoti.opptyName + '<br>' 
                            + '영업단계 : ' + setoppNoti.message + '<br>' 
                            + '초과일수 : ' + setoppNoti.duration + '<br>'
                            + '링크 : ' + instanceUrl + '<br><br>';
                        }
                        
                        email = setoppNoti.email;
                        lang = setoppNoti.lang;
                        stageCount++;
                    }
                }
            }
            List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Opportunity Duration Over Email Alert'];
                Id alertId;

                if(!am.isEmpty()){
                    alertId = am[0].Id;
                }else{
                    alertId = 'a0xF7000009v1TZIAY';
                }
            if(stageMessage != ''){
                

                UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();

                wrapEmail.alertID            = alertId;
                wrapEmail.alertType          = 'Email';
                wrapEmail.receiverforEmail   = new List<String>{Email};
                wrapEmail.elementList        = new List<String>{stageMessage, String.valueOf(stageCount)};
                if(lang == 'ko'){
                    wrapEmail.title              = '영업기회 단계 이동 기준일 초과 알림';
                    wrapEmail.alertLanguage      = 'ko';
                }else if(lang == 'en_US'){
                    wrapEmail.title              = 'Opportunity Stage Duration Over Notification';
                    wrapEmail.alertLanguage      = 'en';
                }else{
                    wrapEmail.title              = '영업기회 단계 이동 기준일 초과 알림';
                    wrapEmail.alertLanguage      = 'ko';

                }
                totalEmail.add(wrapEmail);  
            }
            if(activityMessage != ''){
                UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();

                wrapEmail.alertID            = alertId;
                wrapEmail.alertType          = 'Email';
                wrapEmail.receiverforEmail   = new List<String>{Email};
                wrapEmail.elementList        = new List<String>{activityMessage, String.valueOf(activityCount)};
                if(lang == 'ko'){
                    wrapEmail.title              = '비활동 기준일 초과 알림';
                    wrapEmail.alertLanguage      = 'ko';
                }else if(lang == 'en_US'){
                    wrapEmail.title              = 'No Activity Notification';
                    wrapEmail.alertLanguage      = 'en';
                }else{
                    wrapEmail.title              = '비활동 기준일 초과 알림';
                    wrapEmail.alertLanguage      = 'ko';

                }
                totalEmail.add(wrapEmail);  
            }
        }
        UTIL_Alert.runAlertEvent(totalEmail);
        
    }

    public void finish(Database.BatchableContext bc){
        System.debug('DN_OpportunityActivityAlertBatch completed :: ' + System.now());
    }

    public void execute(SchedulableContext sc) {
        DN_OpportunityActivityAlertBatch batch = new DN_OpportunityActivityAlertBatch();
        Database.executeBatch(batch);
    }
}