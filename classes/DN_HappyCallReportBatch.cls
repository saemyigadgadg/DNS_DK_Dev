/**
@ description       : DNS Happy Call 만족도 조사 Report 용 Batch
**/
public with sharing class DN_HappyCallReportBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    public DateTime customStartTime;
    public DateTime customEndTime;
    // ── 테스트용 주입 변수 ─────────────────────────────────────────────────────
        @TestVisible
        private static List<CampaignTarget__c>    testScope;
        @TestVisible
        private static DateTime                    testStartTime;
        @TestVisible
        private static DateTime                    testEndTime;
    // ──────────────────────────────────────────────────────────────────────────

    public DN_HappyCallReportBatch() {}

    public DN_HappyCallReportBatch(DateTime startTime, DateTime endTime) {
        this.customStartTime = startTime;
        this.customEndTime = endTime;
    }

    public Iterable<SObject> start(Database.BatchableContext bc) {

        List<CampaignMaster__c> masterList = [SELECT Id FROM CampaignMaster__c WHERE Type__c = 'Survey' AND IsActive__c = true];
        System.debug('masterList ::: ' + masterList);
        
        Set<String> masterIds = new Set<String>();
        for(CampaignMaster__c master : masterList) {
            masterIds.add(master.Id);
        }

        // 어제기준
        DateTime nowUtc = DateTime.now();
        DateTime nowKst = nowUtc.addHours(9);
        Date yesterdayKst = nowKst.date().addDays(-1);
        DateTime std = DateTime.newInstance(yesterdayKst, Time.newInstance(0, 0, 0, 0));
        DateTime edt   = DateTime.newInstance(yesterdayKst, Time.newInstance(23, 59, 59, 999));
        System.debug('startTime ::: ' + std);
        System.debug('endTime ::: ' + edt);

        // 테스트 중이라면, 지정해둔 날짜 구간으로 오버라이드
        // DateTime startTime = (Test.isRunningTest() && testStartTime != null) ? testStartTime : std;
        // DateTime endTime   = (Test.isRunningTest() && testEndTime   != null) ? testEndTime   : edt;

        DateTime startTime;
        DateTime endTime;

        if (customStartTime != null && customEndTime != null) {
            startTime = customStartTime;
            endTime   = customEndTime;
        } else if (Test.isRunningTest() && testStartTime != null && testEndTime != null) {
            startTime = testStartTime;
            endTime   = testEndTime;
        } else {
            startTime = std;
            endTime   = edt;
        }
        
        System.debug('startTime ::: ' + startTime);
        System.debug('endTime ::: ' + endTime);
        System.debug('masterIds ::: ' + masterIds);

        Set<Id> ctIds = new Set<Id>();
        Map<Id, Id> srToCtMap = new Map<Id, Id>();

        List<SurveyResponse> srList = [
            SELECT Id, CreatedDate, Invitation.CampaignTarget__c, Invitation.CampaignTarget__r.Campaign__r.CampaignMaster__c, Status
            FROM SurveyResponse
            WHERE CreatedDate >= :startTime
            AND CreatedDate <= :endTime
            AND Invitation.CampaignTarget__r.Campaign__r.CampaignMaster__c IN :masterIds
            AND Invitation.CampaignTarget__r.Campaign__r.IsMigration__c = False
            AND Status = 'Completed'
        ];

        for(SurveyResponse sr : srList) {
            Id ctId = sr.Invitation.CampaignTarget__c;
            if (ctId != null) {
                ctIds.add(ctId);
                srToCtMap.put(sr.Id, ctId);
            }
        }

        List<SurveyQuestionResponse> sqrList = [
            SELECT Id, ResponseId, ResponseValue
            FROM SurveyQuestionResponse
            WHERE ResponseId IN :srToCtMap.keySet()
        ];
                
        // 3. SurveyResponse별 점수 계산
        Map<Id, Integer> srScoreMap = new Map<Id, Integer>();

        for (SurveyQuestionResponse sqr : sqrList) {
            Integer score = srScoreMap.containsKey(sqr.ResponseId) ? srScoreMap.get(sqr.ResponseId) : 0;

            if (sqr.ResponseValue == '매우만족') {
                score += 100;
            } else if (sqr.ResponseValue == '만족') {
                score += 80;
            } else if (sqr.ResponseValue == '보통') {
                score += 60;
            } else if (sqr.ResponseValue == '불만족') {
                score += 40;
            }
            System.debug('score' + score);
            srScoreMap.put(sqr.ResponseId, score);
        }

        // 4. CampaignTarget 업데이트
        List<CampaignTarget__c> ctToUpdate = new List<CampaignTarget__c>();

        for (Id srId : srScoreMap.keySet()) {
            Id ctId = srToCtMap.get(srId);
            if (ctId != null) {
                CampaignTarget__c ct = new CampaignTarget__c(
                    Id = ctId,
                    Score__c = srScoreMap.get(srId)
                );
                ctToUpdate.add(ct);
            }
        }

        if (!ctToUpdate.isEmpty()) {
            update ctToUpdate;
        }
        System.debug('ctToUpdate' + ctToUpdate);
        // DateTime startKST   = DateTime.now().addHours(9);
        // Date startTarget    = startKST.date().addDays(-28);
        // DateTime endKST     = DateTime.now().addHours(9);
        // Date endTarget      = endKST.date().addDays(-1);

        // DateTime startTime   = DateTime.newInstance(startTarget, Time.newInstance(0, 0, 0, 0));
        // DateTime endTime     = DateTime.newInstance(endTarget, Time.newInstance(23, 59, 59, 999));
        return ctToUpdate;
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope){
    
        try {
            List<CampaignTarget__c> campaignTargetList = (Test.isRunningTest() && testScope != null) ? testScope : (List<CampaignTarget__c>) scope;
            System.debug('campaignTargetList ::: ' + campaignTargetList);

            Set<Id> executeIds = new Set<Id>();
            for(CampaignTarget__c campaigntarget : campaignTargetList) {
                executeIds.add(campaigntarget.Id);
            }

            List<CampaignTarget__c> executeCtList = 
            [
                SELECT Id, Campaign__r.CampaignMaster__r.Id, Campaign__r.CampaignMaster__r.Name, Status__c, AdjustScore__c, 
                SurveyCompletedDate__c, Score__c, CreatedDate, Campaign__r.CampaignMaster__r.Survey__c, Ticket__c, Campaign__r.CampaignMaster__r.Survey__r.Name 
                FROM CampaignTarget__c 
                WHERE Id IN :executeIds
            ];
            System.debug('executeCtList ::: ' + executeCtList);

            // First WorkOrder 에서 Work Center 랑 Type 얻기 (Map Key : CampaignTarget)
            Set<Id> ticketIds = new Set<Id>();
            for(CampaignTarget__c obj : executeCtList) {
                if(obj.Ticket__c != null) {
                    ticketIds.add(obj.Ticket__c);
                }
            }

            List<WorkOrder> woList = 
            [
                SELECT Id, CaseId, CreatedDate, ServiceTerritoryId, ServiceTerritory.classify__c, ServiceTerritory.ControlWorkcenter__c,
                ServiceTerritory.ControlWorkcenter__r.Name 
                FROM WorkOrder
                WHERE CaseId IN : ticketIds 
                ORDER BY CreatedDate ASC
            ];

            if (woList == null || woList.size() < 1) {
                return;
            }
            
            Map<String, WorkOrder> woByTicket = new Map<String, WorkOrder>();
            for(WorkOrder wo : woList) {
                if (!woByTicket.containsKey(wo.CaseId)) {
                    woByTicket.put(wo.CaseId, wo);
                }
            }

            ///////////////////////////////////////////////////////////////////////////

            // HappyCallReport Key 설정
            List<HappyCallReport__c> hcrList = 
            [
                SELECT Survey__c, Year__c, WorkCenter__c, Type__c, HappyCallType__c, Count1__c, Count2__c, Count3__c, Count4__c, Count5__c, 
                Count6__c, Count7__c, Count8__c, Count9__c, Count10__c, Count11__c, Count12__c, TotalScore1__c, TotalScore2__c,
                TotalScore3__c,TotalScore4__c,TotalScore5__c,TotalScore6__c,TotalScore7__c,TotalScore8__c,TotalScore9__c,
                TotalScore10__c,TotalScore11__c,TotalScore12__c,AverageScore1__c,AverageScore2__c,AverageScore3__c,AverageScore4__c,
                AverageScore5__c,AverageScore6__c,AverageScore7__c,AverageScore8__c,AverageScore9__c,AverageScore10__c,AverageScore11__c,AverageScore12__c
                FROM HappyCallReport__c
            ];

            Map<String, HappyCallReport__c> hcrMap = new Map<String, HappyCallReport__c>();
            // Map<String, HappyCallReport__c> hcrYearMap = new Map<String, HappyCallReport__c>();
            for(HappyCallReport__c hcr : hcrList) {
                String hcKey = hcr.Survey__c + '!' + hcr.Year__c + '!' + hcr.WorkCenter__c + '!' + hcr.Type__c;     // 창원지사 + 지사
                // String hcYKey = hcr.Survey__c + '!' + hcr.Year__c;  // 연도별
                hcrMap.put(hcKey, hcr);
                // hcrYearMap.put(hcYKey, hcr);
            }

            // Key 가 있으면 Update
            Map<Id, HappyCallReport__c> hcrToUpdateMap = new Map<Id, HappyCallReport__c>();
            // Key 가 없으면 Insert
            List<HappyCallReport__c> hcrToInsert = new List<HappyCallReport__c>();

            for(CampaignTarget__c ct : executeCtList) {
                if (ct.SurveyCompletedDate__c == null || ct.Campaign__r.CampaignMaster__r.Survey__c == null || ct.Ticket__c == null) {
                    continue;
                }
                WorkOrder woObj     = woByTicket.get(ct.Ticket__c);
                String year         = ct.SurveyCompletedDate__c.format('yyyy'); // 2025
                // String year         = String.valueOf(ct.RegisterDate__c.year());
                String survey       = ct.Campaign__r.CampaignMaster__r.Survey__c; // 설치알림톡
                String workCenter   = '';
                String classify     = '';

                if(woObj != null && woObj.ServiceTerritoryId != null) {
                    workCenter = woObj.ServiceTerritoryId;
                    classify   = woObj.ServiceTerritory.classify__c;
                }

                String key     = survey + '!' + year + '!' + workCenter + '!' + classify;
                // String yearKey = survey + '!' + year;

                String month = ct.SurveyCompletedDate__c.format('MM');  // 01, 02 ...
                // String month = ct.RegisterDate__c.month() < 10 ? '0' + ct.RegisterDate__c.month() : String.valueOf(ct.RegisterDate__c.month());

                if(hcrMap.containsKey(key)) {
                    // 기존 HappyCallReport Update
                    HappyCallReport__c existingHCR = hcrMap.get(key);
                    switch on month {
                        when '01' {
                            existingHCR.Count1__c          = (existingHCR.Count1__c == null ? 0 : existingHCR.Count1__c) + 1;
                            existingHCR.TotalScore1__c     = (existingHCR.TotalScore1__c == null ? 0 : existingHCR.TotalScore1__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore1__c   = (existingHCR.TotalScore1__c / existingHCR.Count1__c).setScale(2);
                        }
                        when '02' {
                            existingHCR.Count2__c = (existingHCR.Count2__c == null ? 0 : existingHCR.Count2__c) + 1;
                            existingHCR.TotalScore2__c     = (existingHCR.TotalScore2__c == null ? 0 : existingHCR.TotalScore2__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore2__c   = (existingHCR.TotalScore2__c / existingHCR.Count2__c).setScale(2);
                        }
                        when '03' {
                            existingHCR.Count3__c = (existingHCR.Count3__c == null ? 0 : existingHCR.Count3__c) + 1;
                            existingHCR.TotalScore3__c     = (existingHCR.TotalScore3__c == null ? 0 : existingHCR.TotalScore3__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore3__c   = (existingHCR.TotalScore3__c / existingHCR.Count3__c).setScale(2);
                        }
                        when '04' {
                            existingHCR.Count4__c = (existingHCR.Count4__c == null ? 0 : existingHCR.Count4__c) + 1;
                            existingHCR.TotalScore4__c     = (existingHCR.TotalScore4__c == null ? 0 : existingHCR.TotalScore4__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore4__c   = (existingHCR.TotalScore4__c / existingHCR.Count4__c).setScale(2);
                        }
                        when '05' {
                            existingHCR.Count5__c = (existingHCR.Count5__c == null ? 0 : existingHCR.Count5__c) + 1;
                            existingHCR.TotalScore5__c     = (existingHCR.TotalScore5__c == null ? 0 : existingHCR.TotalScore5__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore5__c   = (existingHCR.TotalScore5__c / existingHCR.Count5__c).setScale(2);
                        }
                        when '06' {
                            existingHCR.Count6__c = (existingHCR.Count6__c == null ? 0 : existingHCR.Count6__c) + 1;
                            existingHCR.TotalScore6__c     = (existingHCR.TotalScore6__c == null ? 0 : existingHCR.TotalScore6__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore6__c   = (existingHCR.TotalScore6__c / existingHCR.Count6__c).setScale(2);
                        }
                        when '07' {
                            existingHCR.Count7__c = (existingHCR.Count7__c == null ? 0 : existingHCR.Count7__c) + 1;
                            existingHCR.TotalScore7__c     = (existingHCR.TotalScore7__c == null ? 0 : existingHCR.TotalScore7__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore7__c   = (existingHCR.TotalScore7__c / existingHCR.Count7__c).setScale(2);
                        }
                        when '08' {
                            existingHCR.Count8__c = (existingHCR.Count8__c == null ? 0 : existingHCR.Count8__c) + 1;
                            existingHCR.TotalScore8__c     = (existingHCR.TotalScore8__c == null ? 0 : existingHCR.TotalScore8__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore8__c   = (existingHCR.TotalScore8__c / existingHCR.Count8__c).setScale(2);
                        }
                        when '09' {
                            existingHCR.Count9__c = (existingHCR.Count9__c == null ? 0 : existingHCR.Count9__c) + 1;
                            existingHCR.TotalScore9__c     = (existingHCR.TotalScore9__c == null ? 0 : existingHCR.TotalScore9__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore9__c   = (existingHCR.TotalScore9__c / existingHCR.Count9__c).setScale(2);
                        }
                        when '10' {
                            existingHCR.Count10__c = (existingHCR.Count10__c == null ? 0 : existingHCR.Count10__c) + 1;
                            existingHCR.TotalScore10__c     = (existingHCR.TotalScore10__c == null ? 0 : existingHCR.TotalScore10__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore10__c   = (existingHCR.TotalScore10__c / existingHCR.Count10__c).setScale(2);
                        }
                        when '11' {
                            existingHCR.Count11__c = (existingHCR.Count11__c == null ? 0 : existingHCR.Count11__c) + 1;
                            existingHCR.TotalScore11__c     = (existingHCR.TotalScore11__c == null ? 0 : existingHCR.TotalScore11__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore11__c   = (existingHCR.TotalScore11__c / existingHCR.Count11__c).setScale(2);
                        }
                        when '12' {
                            existingHCR.Count12__c = (existingHCR.Count12__c == null ? 0 : existingHCR.Count12__c) + 1;
                            existingHCR.TotalScore12__c     = (existingHCR.TotalScore12__c == null ? 0 : existingHCR.TotalScore12__c) + (ct.AdjustScore__c != null ? ct.AdjustScore__c : ct.Score__c);
                            existingHCR.AverageScore12__c   = (existingHCR.TotalScore12__c / existingHCR.Count12__c).setScale(2);
                        }
                    }

                    hcrToUpdateMap.put(existingHCR.Id, existingHCR);

                } else {
                    HappyCallReport__c newHCR = new HappyCallReport__c();
                    newHCR.Year__c            = year;
                    newHCR.WorkCenter__c      = workCenter;
                    newHCR.Survey__c          = ct.Campaign__r.CampaignMaster__r.Survey__c;
                    newHCR.HappyCallType__c   = ct.Campaign__r.CampaignMaster__r.Survey__r.Name;
                    newHCR.Type__c            = classify;
                    // newHCR.IsMigration__c     = true;   //

                    switch on month {
                        when '01' {
                            newHCR.Count1__c        = 1;
                            newHCR.TotalScore1__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore1__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '02' {
                            newHCR.Count2__c        = 1;
                            newHCR.TotalScore2__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore2__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '03' {
                            newHCR.Count3__c        = 1;
                            newHCR.TotalScore3__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore3__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '04' {
                            newHCR.Count4__c        = 1;
                            newHCR.TotalScore4__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore4__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '05' {
                            newHCR.Count5__c        = 1;
                            newHCR.TotalScore5__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore5__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '06' {
                            newHCR.Count6__c        = 1;
                            newHCR.TotalScore6__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore6__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '07' {
                            newHCR.Count7__c        = 1;
                            newHCR.TotalScore7__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore7__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '08' {
                            newHCR.Count8__c        = 1;
                            newHCR.TotalScore8__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore8__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '09' {
                            newHCR.Count9__c        = 1;
                            newHCR.TotalScore9__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore9__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '10' {
                            newHCR.Count10__c        = 1;
                            newHCR.TotalScore10__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore10__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '11' {
                            newHCR.Count11__c        = 1;
                            newHCR.TotalScore11__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore11__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                        when '12' {
                            newHCR.Count12__c        = 1;
                            newHCR.TotalScore12__c   = (ct.AdjustScore__c != null) ? ct.AdjustScore__c : ct.Score__c;
                            newHCR.AverageScore12__c = (ct.AdjustScore__c != null) ? ct.AdjustScore__c.setScale(2) : (ct.Score__c != null) ? ct.Score__c.setScale(2) : 0;
                        }
                    }
                    hcrToInsert.add(newHCR);
                }
            }

            if (!hcrToInsert.isEmpty()) {
                insert hcrToInsert;
            }
            if (!hcrToUpdateMap.isEmpty()) {
                update hcrToUpdateMap.values();
            }
        } catch (Exception e) {
            System.debug('Error in happyreportbatch: ' + e.getMessage());
            System.debug('Error Stack: ' + e.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('배치 실행 완료');
    }

    public void execute(SchedulableContext sc) {
        DN_HappyCallReportBatch batch = new DN_HappyCallReportBatch();
        Database.executeBatch(batch, 1);
    }
}