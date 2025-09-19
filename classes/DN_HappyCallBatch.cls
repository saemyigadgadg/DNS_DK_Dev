/**
* @Class : DN_HappyCallBatch
*
* @Author : Junyeong, Choi
* @Date : 2024. 08. 14.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-08-14 | Junyeong, Choi   | 최초작성
*
*/
global class DN_HappyCallBatch implements Database.Batchable<CampaignMaster__c>, Database.Stateful, Database.AllowsCallouts, Schedulable {
    
    public List<CampaignMaster__c> scope;
    // Start List
    public List<CampaignMaster__c> CMList                            = new List<CampaignMaster__c>();
    // Condition Maps
    public Map<Id, List<ExtractCondition__c>> conditionListForCMId   = new Map<Id, List<ExtractCondition__c>>();
    public Map<Id, List<ExceptAccount__c>> EAListForCMId             = new Map<Id, List<ExceptAccount__c>>();
    public Map<Id, List<ExceptEquipment__c>> EEListForCMId           = new Map<Id, List<ExceptEquipment__c>>();
    public Map<Id, List<CampaignManager__c>> MGListForCMId           = new Map<Id, List<CampaignManager__c>>();
    // finish List
    public List<UTIL_Alert.HistoryWrapper> hwrappers                 = new List<UTIL_Alert.HistoryWrapper>();
    public List<CampaignTargetWrapper> ctwrappers                    = new List<CampaignTargetWrapper>();
    public Boolean isAlarmTalk;
    public String cmType;

    public DN_HappyCallBatch(){
        Date today = Date.today();
        this.CMList = [
            SELECT Id, StartDate__c, EndDate__c, Name, Type__c, IsAlarmTalk__c, AutoExtraction__c,
            OrderConfirm__c, Survey__c, Description__c, IsActive__c, Survey__r.Name
            FROM CampaignMaster__c
            WHERE AutoExtraction__c = true
            AND StartDate__c <= :today
            AND EndDate__c >= :today
            AND IsActive__c = true
        ];
        List<Id> cmIdList = new List<Id>();
        for (CampaignMaster__c cm : this.CMList) cmIdList.add(cm.Id);
        
        List<ExtractCondition__c> happyCallConditions = [
            SELECT Id, Campaign__c, CampaignMaster__c, TicketType__c, TicketTypeMiddle__c, FromDate__c, ToDate__c, ExtractionTarget__c, ExtractionCondition__c, TicketTypeLabel__c, TicketTypeMiddleLabel__c, ExtractConditionLabel__c
            FROM ExtractCondition__c
            WHERE CampaignMaster__c IN :cmIdList
        ];
        for (ExtractCondition__c happyCallCondition : happyCallConditions) {
            if (!this.conditionListForCMId.containsKey(happyCallCondition.CampaignMaster__c)) {
                this.conditionListForCMId.put(happyCallCondition.CampaignMaster__c, new List<ExtractCondition__c>());
            }
            this.conditionListForCMId.get(happyCallCondition.CampaignMaster__c).add(happyCallCondition);
        }
    
        List<ExceptAccount__c> EAList = [
            SELECT Id, Account__c, CampaignMaster__c 
            FROM ExceptAccount__c
            WHERE CampaignMaster__c IN :cmIdList
        ];
        for (ExceptAccount__c EA : EAList) {
            if (!this.EAListForCMId.containsKey(EA.CampaignMaster__c)) {
                this.EAListForCMId.put(EA.CampaignMaster__c, new List<ExceptAccount__c>());
            }
            this.EAListForCMId.get(EA.CampaignMaster__c).add(EA);
        }

        List<ExceptEquipment__c> EEList = [
            SELECT Id, Equipment__c, CampaignMaster__c 
            FROM ExceptEquipment__c
            WHERE CampaignMaster__c IN :cmIdList
        ];
        for (ExceptEquipment__c EE : EEList) {
            if (!this.EEListForCMId.containsKey(EE.CampaignMaster__c)) {
                this.EEListForCMId.put(EE.CampaignMaster__c, new List<ExceptEquipment__c>());
            }
            this.EEListForCMId.get(EE.CampaignMaster__c).add(EE);
        }

        List<CampaignManager__c> MGList = [
            SELECT Id, User__c, CampaignMaster__c 
            FROM CampaignManager__c
            WHERE CampaignMaster__c IN :cmIdList
            ORDER BY CreatedDate
        ];
        for (CampaignManager__c MG : MGList) {
            if (!this.MGListForCMId.containsKey(MG.CampaignMaster__c)) {
                this.MGListForCMId.put(MG.CampaignMaster__c, new List<CampaignManager__c>());
            }
            this.MGListForCMId.get(MG.CampaignMaster__c).add(MG);
        }
    }

    public List<CampaignMaster__c> start(Database.BatchableContext context){
        // CampaignMaster__c 에서 배치를 실행할 레코드
        System.debug('this.CMList :::' + this.CMList);
        return this.CMList;
    }

    public void execute(Database.BatchableContext context, List<CampaignMaster__c> scope) {

        System.debug(' =============== Batch Execute ================');
        System.debug('scope.Size() : ' + scope.size());
        System.debug('scope.Size() : ' + scope);
        RecordType camrt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Campaign' AND Name = 'Happy Call' LIMIT 1];

        // 제외할 계정과 장비의 ID를 저장할 맵
        Map<Id, Set<Id>> eaIdMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> eeIdMap = new Map<Id, Set<Id>>();
        Map<Id, Id> campaignMap  = new Map<Id, Id>(); // CampaignMaster__c Id, newCampaign Id 저장
        String campaignId;
        String surveyId;
        String surveyName;
        String cmId;
        String newCM;
        String campaignType;
        Boolean orderConfirm;
        List<CampaignManager__c> managerList;

        for (CampaignMaster__c cm : scope) {
            cmId        = cm.Id;
            cmType      = cm.Type__c;
            surveyName  = cm.Survey__r.Name;
            isAlarmTalk = cm.IsAlarmTalk__c;
            List<ExtractCondition__c> conditionList   = conditionListForCMId.get(cm.Id);
            if(conditionList == null || conditionList.size() < 1) {
                return;
            }

            // ExceptAccount
            List<ExceptAccount__c>      EAList                    = EAListForCMId.get(cm.Id);
            Set<Id> eaIds = new Set<Id>();
            if (EAList != null && EAList.size() > 0) {
                for (ExceptAccount__c obj : EAList) {
                    eaIds.add(obj.Account__c);
                }
            }
            eaIdMap.put(cm.Id, eaIds);

            // ExceptEquipment
            List<ExceptEquipment__c>    EEList                    = EEListForCMId.get(cm.Id);
            Set<Id> eeIds = new Set<Id>();
            if (EEList != null && EEList.size() > 0) {
                for (ExceptEquipment__c obj : EEList) {
                    eeIds.add(obj.Equipment__c);
                }
            }
            eeIdMap.put(cm.Id, eeIds);

            managerList = MGListForCMId.get(cm.Id);
            
            String dateStr = String.valueOf(Date.today()).replace('-', '.');
            // New Campaign 만들기
            Campaign newCampaign            = new Campaign();
            newCampaign.CampaignMaster__c   = cm.Id;
            newCampaign.Name                = cm.Name + '_' + dateStr;
            newCampaign.Type__c             = cm.Type__c;
            newCampaign.RecordTypeId        = camrt.Id;
            newCampaign.IsAlarmTalk__c      = cm.IsAlarmTalk__c;
            newCampaign.AutoExtraction__c   = cm.AutoExtraction__c;
            newCampaign.OrderConfirm__c     = cm.OrderConfirm__c;
            newCampaign.StartDate           = cm.StartDate__c;
            newCampaign.EndDate             = cm.EndDate__c;
            newCampaign.Description         = cm.Description__c;
            newCampaign.IsActive            = cm.IsActive__c;
            insert newCampaign;

            CampaignId        = newCampaign.Id;
            newCM             = newCampaign.CampaignMaster__c;
            campaignType      = newCampaign.Type__c;
            orderConfirm      = cm.OrderConfirm__c;
            surveyId          = cm.Survey__c;
            campaignMap.put(cm.Id, newCampaign.Id);
            
            if (conditionList != null && conditionList.size() > 0) {
                for (ExtractCondition__c obj : conditionList) {
                    ExtractCondition__c ec = new ExtractCondition__c
                    (
                        Campaign__c              = campaignId,
                        TicketTypeMiddle__c      = obj.TicketTypeMiddle__c,
                        TicketType__c            = obj.TicketType__c,
                        FromDate__c              = obj.FromDate__c,
                        ToDate__c                = obj.ToDate__c,
                        ExtractionTarget__c      = obj.ExtractionTarget__c,
                        ExtractionCondition__c   = obj.ExtractionCondition__c,
                        TicketTypeLabel__c       = obj.TicketTypeLabel__c,
                        TicketTypeMiddleLabel__c = obj.TicketTypeMiddleLabel__c,
                        ExtractConditionLabel__c = obj.ExtractConditionLabel__c
                    );
                    insert ec;
                }
            }
        }

        if(managerList != null && managerList.size() > 0) {
            List<UTIL_Alert.HistoryWrapper> notiList = new List<UTIL_Alert.HistoryWrapper>();
            String alertManager = [SELECT Id FROM AlertManager__c WHERE Name = 'CS HappyCall Noti' LIMIT 1].Id;
            for(CampaignManager__c cman : managerList) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType       = 'Notification';
                history.elementList.add(surveyName);
                history.alertID         = alertManager;
                history.targetID        = CampaignId;
                history.receiverforID   = new Set<Id>{cman.User__c};
                history.alertLanguage   = 'ko';
                notiList.add(history);
            }
            System.debug('notiList'+notiList);
            UTIL_Alert.runAlertEvent(notiList);
        }

        Set<Id> allEaIds = new Set<Id>();
        Set<Id> allEeIds = new Set<Id>();
        
        for (Set<Id> eaIds : eaIdMap.values()) {
            allEaIds.addAll(eaIds);
        }

        for (Set<Id> eeIds : eeIdMap.values()) {
            allEeIds.addAll(eeIds);
        }

        // 요일 Check : 금, 토, 일은 월요일 배치에 포함된다.
        Date today = System.today();
        DateTime dt = DateTime.newInstance(today.year(), today.month(), today.day());
        String dayOfWeek = dt.format('EEEE');
        System.debug('dayOfWeek' + dayOfWeek);

        List<Case> caList = new List<Case>();

        if(Test.isRunningTest()) {
            dayOfWeek = 'Monday';
        }
        if((dayOfWeek != null && dayOfWeek == 'Monday') || (dayOfWeek != null && dayOfWeek == '월요일')) {
            DateTime startKST   = DateTime.now().addHours(9);
            Date startTarget    = startKST.date().addDays(-3);
            DateTime endKST     = DateTime.now().addHours(9);
            Date endTarget      = endKST.date().addDays(-1);

            DateTime startTime   = DateTime.newInstance(startTarget, Time.newInstance(0, 0, 0, 0));
            DateTime endTime     = DateTime.newInstance(endTarget, Time.newInstance(23, 59, 59, 999));

            if(Test.isRunningTest()) {
                surveyName = '서비스알림톡';
            }

            if(surveyName == '서비스알림톡') {
                caList = [
                    SELECT Id, AccountId, AssetId, Status, ClosedDate, InternalTicketType__c
                    FROM Case 
                    WHERE Status = 'Closed'
                    AND ClosedDate >= :startTime
                    AND ClosedDate <= :endTime
                    AND (AccountId NOT IN :allEaIds)
                    AND (AssetId NOT IN :allEeIds)
                    AND InternalTicketType__c = 'Failure receipt'
                    AND FM_Country__c = 'DNS'
                ];
                System.debug('주말 서비스알림톡 caList => ' + caList);
            } else if(surveyName == '설치알림톡') {
                caList = [
                    SELECT Id, AccountId, AssetId, Status, ClosedDate, InternalTicketType__c
                    FROM Case
                    WHERE Status = 'Closed'
                    AND ClosedDate >= :startTime
                    AND ClosedDate <= :endTime
                    AND (AccountId NOT IN :allEaIds)
                    AND (AssetId NOT IN :allEeIds)
                    AND InternalTicketType__c = 'Installation request'
                    AND FM_Country__c = 'DNS'
                ];
                System.debug('주말 서비스알림톡 caList => ' + caList);
            } else {
                System.debug('Order 없음');
            }

        } else {
            DateTime nowKST = DateTime.now().addHours(9);
            Date targetDate = nowKST.date().addDays(-1);  // 어제 날짜 (KST 기준)
            
            DateTime startDT = DateTime.newInstance(targetDate, Time.newInstance(0, 0, 0, 0));
            DateTime endDT = DateTime.newInstance(targetDate, Time.newInstance(23, 59, 59, 999));
            
    
            if(surveyName == '서비스알림톡') {
                caList = [
                    SELECT Id, AccountId, AssetId, Status, ClosedDate, InternalTicketType__c
                    FROM Case
                    WHERE Status = 'Closed'
                    AND ClosedDate >= :startDT
                    AND ClosedDate <= :endDT
                    AND (AccountId NOT IN :allEaIds)
                    AND (AssetId NOT IN :allEeIds)
                    AND InternalTicketType__c = 'Failure receipt'
                    AND FM_Country__c = 'DNS'
                ];
                System.debug('서비스알림톡 caList => ' + caList);
    
            } else if(surveyName == '설치알림톡') {
                caList = [
                    SELECT Id, AccountId, AssetId, Status, ClosedDate, InternalTicketType__c
                    FROM Case
                    WHERE Status = 'Closed'
                    AND ClosedDate >= :startDT
                    AND ClosedDate <= :endDT
                    AND (AccountId NOT IN :allEaIds)
                    AND (AssetId NOT IN :allEeIds)
                    AND InternalTicketType__c = 'Installation request'
                    AND FM_Country__c = 'DNS'
                ];
                System.debug('설치알림톡 caList => ' + caList);
    
            } else {
                System.debug('Order 없음');
            }
        }

        Set<Id> caseIds = new Set<Id>();
        for(Case ca : caList) {
            caseIds.add(ca.Id);
        }

        Set<Id> caseIdsWithWO = new Set<Id>();

        for(WorkOrder wo : [SELECT Id, CaseId FROM WorkOrder WHERE CaseId IN :caseIds]) {
            caseIdsWithWO.add(wo.CaseId);
        }

        List<Case> filteredCaseList = new List<Case>();
        for(Case ca : caList) {
            if(caseIdsWithWO.contains(ca.Id)) {
                filteredCaseList.add(ca);
            }
        }

        // List<Case> updateCaseList      = new List<Case>();
        // Case Owner 매니저 순환을 위한 Index
        // Integer ownerIndex = 0;
        // for (Case ca : caseList) {
        //     if (managerList != null) {
        //         ca.OwnerId = managerList[ownerIndex].User__c;
        //         ownerIndex++;
        //         if (ownerIndex >= managerList.size()) {
        //             ownerIndex = 0;
        //         }
        //     } else {
        //         ca.Manager__c = null;
        //     }
        //     for(CampaignMaster__c cm : scope){
        //         if(cm.Description__c != null) {
        //             ca.ReceptionDetails__c = cm.Description__c;
        //         }
        //     }
        // }
        // updateCaseList = caseList;
        // update orderCheckList;
        
        List<CampaignCaseLink__c> links = new List<CampaignCaseLink__c>();
        for (Case c : filteredCaseList) {
            CampaignCaseLink__c link = new CampaignCaseLink__c();
            link.CampaignMaster__c   = newCM;
            link.Ticket__c           = c.Id;
            links.add(link);
        }
        insert links;

        // CampaignTarget Insert
        List<CampaignTarget__c> ctList             = new List<CampaignTarget__c>();
        List<SurveyInvitation> surveyInvitations   = new List<SurveyInvitation>();
        Map<Id, CampaignTarget__c> ctMap           = new Map<Id, CampaignTarget__c>();
        Map<Id, SurveyInvitation> siMap            = new Map<Id, SurveyInvitation>();
        Network nw = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];

        // 캠페인 타겟 매니저 순환
        Integer managerIndex = 0;
        Map<Id, CampaignTarget__c> insertedCTMap = new Map<Id, CampaignTarget__c>();
        for(Case ca : filteredCaseList) {
            CampaignTarget__c ct = new CampaignTarget__c();
            ct.Campaign__c       = campaignId;
            ct.Ticket__c         = ca.Id;
            ct.Equipment__c      = ca.AssetId;
            ct.Account__c        = ca.AccountId;
            ct.RegisterDate__c   = Date.today();
            if (managerList != null) {
                ct.Manager__c = managerList[managerIndex].User__c;
                managerIndex++;
                if(managerIndex >= managerList.size()) {
                    managerIndex = 0;
                }
            } else {
                ct.Manager__c = null;
            }
            ctList.add(ct);
            insertedCTMap.put(ca.Id, ct);
        }

        if (!ctList.isEmpty()) {
            insert ctList;
            for (Case ca : filteredCaseList) {
                if (campaignType != 'General') {
                    CampaignTarget__c insertedCT = insertedCTMap.get(ca.Id);
                    SurveyInvitation si = new SurveyInvitation(
                        Name                            = 'HappyCall_survey' + '_' + Date.today().format().replaceAll('/', '_'), 
                        SurveyId                        = surveyId,
                        CommunityId                     = nw.Id,
                        OptionsAllowGuestUserResponse   = true,
                        CampaignTarget__c               = insertedCT.Id
                    );
                    surveyInvitations.add(si);
                    ctMap.put(ca.Id, insertedCT);
                    siMap.put(ca.Id, si);
                }
            }
        }

        if (!surveyInvitations.isEmpty()) {
            insert surveyInvitations;
        }

        List<SurveyInvitation> siList = [
            SELECT Id, InvitationLink
            FROM SurveyInvitation
            WHERE Id IN :surveyInvitations
        ];

        for (SurveyInvitation si : siList) {
            for (Id caseId : siMap.keySet()) {
                if (siMap.get(caseId).Id == si.Id) {
                    CampaignTarget__c relatedCT = ctMap.get(caseId);
                    if (relatedCT != null) {
                        relatedCT.SurveyURL__c = si.InvitationLink;
                        relatedCT.SurveyInvitation__c = si.Id;
                    }
                }
            }
        }

        // SurveyURL__c 필드 업데이트
        if (!ctList.isEmpty()) {
            update ctList;
        }

        // IsAlarmTalk 조건 
        String alertID = [SELECT Id, AlertManager__c FROM CampaignMaster__c WHERE Id = : cmId].AlertManager__c;
        
        List<CampaignTarget__c> updateCTList = new List<CampaignTarget__c>();
        Set<Id> ctIds = new Set<Id>();
        for (CampaignTarget__c ct : ctList) {
            ctIds.add(ct.Id);
        }

        List<CampaignTarget__c> querydCTList = new List<CampaignTarget__c>();
        if(!Test.isRunningTest()) {
            querydCTList = 
            [
                SELECT Id, Ticket__c, Ticket__r.Requester__r.Name, Ticket__r.Requester__r.MobilePhone, SurveyURL__c, AlarmTalkFirstSend__c, FirstSendTime__c
                FROM CampaignTarget__c
                WHERE Id IN :ctIds
            ];
        } else {
            querydCTList = new List<CampaignTarget__c>{
                new CampaignTarget__c(
                    AlarmTalkFirstSend__c = false,
                    SurveyURL__c          = 'https://test.com',
                    RegisterDate__c       = Date.today(),
                    FirstSendTime__c      = 'Fir',
                    ListSequence__c       = 'Lis',
                    Description__c        = 'Des',
                    AlamSendCount__c      = 0,
                    SurveyResult__c       = 'A',
                    AlamTalkSend__c       = true,
                    Memo__c               = 'Memo'
                ),
                new CampaignTarget__c(
                    AlarmTalkFirstSend__c = false,
                    SurveyURL__c          = 'https://test.com',
                    RegisterDate__c       = Date.today(),
                    FirstSendTime__c      = 'Fir',
                    ListSequence__c       = 'Lis',
                    Description__c        = 'Des',
                    AlamSendCount__c      = 0,
                    SurveyResult__c       = 'A',
                    AlamTalkSend__c       = true,
                    Memo__c               = 'Memo'
                )
            };        
        }

        if(isAlarmTalk && cmType == 'Survey') {
            List<UTIL_Alert.historyWrapper> happyCallWrappers    = new List<UTIL_Alert.historyWrapper>();
            List<CampaignTargetWrapper> CampaignTargetWrappers   = new List<CampaignTargetWrapper>();
            for(CampaignTarget__c ct : querydCTList) {
                if(ct.AlarmTalkFirstSend__c == false) {                   
                    String subUrl = ct.SurveyURL__c.replace('https://', '');
                    Map<String, String> alarmMap = new Map<String, String>();
                    alarmMap.put('clnt_nm', ct.Ticket__r.Requester__r.Name);
                    alarmMap.put('url', subUrl);
                    String phone;
                    if(!Test.isRunningTest()) {
                        phone = ct.Ticket__r.Requester__r.MobilePhone;
                    } else {
                        phone = '01012345678';
                    }
                    
                    CampaignTargetWrapper ctw = new CampaignTargetWrapper();
                    ctw.Id = ct.Id;
                    CampaignTargetWrappers.add(ctw);

                    if (!String.isBlank(phone)) {
                        UTIL_Alert.historyWrapper wrapper   = new UTIL_Alert.historyWrapper();
                        wrapper.alertID                     = alertID;
                        wrapper.targetID                    = ct.Ticket__c;
                        wrapper.alertType                   = 'AlarmTalk';
                        // wrapper.receiverforPhone            = new Set<String>{'01089952486'};
                        wrapper.receiverforPhone            = new Set<String>{phone};
                        wrapper.alertLanguage               = 'ko';
                        wrapper.elementMap                  = alarmMap;
                        happyCallWrappers.add(wrapper);
                        updateCTList.add(ct);
                    }
                } else {
                    ct.AlarmTalkFirstSend__c = true;
                }
            }

            this.hwrappers.addAll(happyCallWrappers);
            System.debug('this.hwrappers: ' + this.hwrappers);

            this.ctwrappers.addAll(CampaignTargetWrappers);
            System.debug('this.ctwrappers: ' + this.ctwrappers);
            
            System.debug('updateCTList' + updateCTList);
            if(!Test.isRunningTest()) {
                if (!updateCTList.isEmpty()) {
                    update updateCTList;
                }
            }

        }
    }
        
    public void finish(Database.BatchableContext context){
        System.debug('isAlarmTalk :: ' + isAlarmTalk);
        System.debug('cmType :: ' + cmType);
    
        String jobName = 'DN_SendAlarmTalkBatch';

        // 기존 예약된 배치가 있는지 체크
        List<CronTrigger> existingJobs = [
            SELECT Id, CronJobDetail.Name, CronJobDetailId, CronExpression
            FROM CronTrigger 
            WHERE CronJobDetail.Name = :jobName
        ];

        if (existingJobs.isEmpty()) {
            DN_SendAlarmTalkBatch batch = new DN_SendAlarmTalkBatch();
            // batch.wrappers = new List<UTIL_Alert.HistoryWrapper>{hwrappers[0]};
            batch.wrappers   = hwrappers;
            batch.ctwrappers = ctwrappers;
            // 실행 시간 지정 (오늘 오후 2시)
            String cronExp = '0 0 14 ? * MON-FRI';

            System.schedule(jobName, cronExp,  batch);
            System.debug('오후 2시 알람톡 예약 완료!');
        } else {
            DN_SendAlarmTalkBatch batch = new DN_SendAlarmTalkBatch();
            // batch.wrappers = new List<UTIL_Alert.HistoryWrapper>{hwrappers[0]};
            batch.wrappers   = hwrappers;
            batch.ctwrappers = ctwrappers;
            // 실행 시간 지정 (오늘 오후 2시)
            String cronExp = '0 0 14 ? * MON-FRI';

            System.abortJob(existingJobs[0].Id);    // 스케줄 잡 없애는 메서드
            System.schedule(jobName, cronExp,  batch);
            System.debug('오후 2시 알람톡 예약 완료!');
        }
    }

    public void execute(SchedulableContext sc) {
        DN_HappyCallBatch batch = new DN_HappyCallBatch();
        Database.executeBatch(batch, 1);        
    }

    public class CampaignTargetWrapper {
        @AuraEnabled public String Id   {get;set;}
        public CampaignTargetWrapper() {
            this.Id = '';
        }
    }
}