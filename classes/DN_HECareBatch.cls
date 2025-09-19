/**
* @Class : DN_HECareBatch
*
* @Author : Junyeong, Choi
* @Date : 2024. 11. 13.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-11-13 | Junyeong, Choi   | 최초작성
*
*
*
@ description       : HECare 1612 장비 Ticket 생성 및 관련 사용자에게 Email 전송
**/
global class DN_HECareBatch implements Database.Batchable<Campaign>, Database.Stateful, Database.AllowsCallouts, Schedulable{
    public List<Campaign> CPList                             = new List<Campaign>();
    public List<Asset> assetList                             = new List<Asset>();
    public List<CampaignTarget__c> ctList                    = new List<CampaignTarget__c>();
    public Map<Id, List<CampaignTarget__c>> cpIdFORCTarget   = new Map<Id, List<CampaignTarget__c>>();

    public DN_HECareBatch() {
        Date today = Date.today();
        this.CPList = [
            SELECT Id, Name, RegularServiceType__c, StartDate, EndDate, InstallationDateStart__c, InstallationDateEnd__c, IsActive
            FROM Campaign
            WHERE RegularServiceType__c = 'HE Care'
            AND IsActive = True
            AND StartDate <= :today
            AND EndDate >= :today
        ];

        Set<Id> cpIds = new Set<Id>();
        for(Campaign cp : this.CPList) cpIds.add(cp.Id);

        this.ctList = [
            SELECT Id, Campaign__c, Equipment__c, X_1month__c, X_6month__c, X_12month__c, Equipment__r.InstallationFinish__c, Account__c
            FROM CampaignTarget__c
            WHERE Campaign__c IN :cpIds
        ];

        for(CampaignTarget__c ct : this.ctList) {
            if(!this.cpIdFORCTarget.containsKey(ct.Campaign__c)) {
                this.cpIdFORCTarget.put(ct.Campaign__c, new List<CampaignTarget__c>{ct});
            } else {
                this.cpIdFORCTarget.get(ct.Campaign__c).add(ct);
            }
        }
    }   

    public List<Campaign> start(Database.BatchableContext context){
        return this.CPList;
    }

    public void execute(Database.BatchableContext context, List<Campaign> scope) {
        System.debug(' =============== Batch Execute ================');
        System.debug('scope.Size() : ' + scope.size());
        System.debug('scope : ' + scope);
        Savepoint sp;
        try{
            Set<Id> ctIds = new Set<Id>();    
            List<Case> newCaseList                  = new List<Case>();
            Map<Integer, Id> caseToTarget1MonMap    = new Map<Integer, Id>();
            Map<Integer, Id> caseToTarget6MonMap    = new Map<Integer, Id>();
            Map<Integer, Id> caseToTarget12MonMap   = new Map<Integer, Id>();
            
            for(Campaign cp : scope) {
                Date add1Month;
                Date add6Month;
                Date add12Month;
                Date today                          = System.today();         // 25.04.27

                Date testToday                      = Date.newInstance(2026, 2, 7);
                List<CampaignTarget__c> getCTList   = cpIdFORCTarget.get(cp.Id);
                System.debug('getCTList' + getCTList);
                System.debug('today'+today);
                System.debug('testToday'+testToday);
                if(getCTList != null) {
                    for(CampaignTarget__c obj : getCTList) {
                        if(obj.Equipment__r?.InstallationFinish__c != null) {
                            add1Month    = obj.Equipment__r?.InstallationFinish__c.addMonths(1);   // 25.04.26
                            add6Month    = obj.Equipment__r?.InstallationFinish__c.addMonths(5);   // 25.09.03 // 1,5,11 로 Ticket 을 생성해달라고 하셔서 설정해놓음.
                            add12Month   = obj.Equipment__r?.InstallationFinish__c.addMonths(11);  // 26.03.03 // 1,5,11 로 Ticket 을 생성해달라고 하셔서 설정해놓음.
                            System.debug('add1Month'+add1Month);
                            System.debug('add6Month'+add6Month);
                            System.debug('add12Month'+add12Month);
    
                            if(today == add1Month && obj.X_1month__c == null) {
                                Case newCase                     = new Case();
                                newCase.Campaign__c              = cp.Id;
                                newCase.AssetId                  = obj.Equipment__c;
                                newCase.AccountId                = obj.Account__c;
                                newCase.TicketType__c            = 'Internal request';
                                newCase.InternalTicketType__c    = 'Regular Inspections';
                                newCase.ReceptionDetails__c	     = 'HE Care1612 , 1개월차';
                                newCaseList.add(newCase);

                                caseToTarget1MonMap.put(newCaseList.size() - 1, obj.Id);
                            }
                            if(today == add6Month && obj.X_6month__c == null) {
                                Case newCase                     = new Case();
                                newCase.Campaign__c              = cp.Id;
                                newCase.AssetId                  = obj.Equipment__c;
                                newCase.AccountId                = obj.Account__c;
                                newCase.TicketType__c            = 'Internal request';
                                newCase.InternalTicketType__c    = 'Regular Inspections';
                                newCase.ReceptionDetails__c	     = 'HE Care1612 , 6개월차';
                                newCaseList.add(newCase);

                                caseToTarget6MonMap.put(newCaseList.size() - 1, obj.Id);
                            }
                            if(today == add12Month && obj.X_12month__c == null) {
                                Case newCase                     = new Case();
                                newCase.Campaign__c              = cp.Id;
                                newCase.AssetId                  = obj.Equipment__c;
                                newCase.AccountId                = obj.Account__c;
                                newCase.TicketType__c            = 'Internal request';
                                newCase.InternalTicketType__c    = 'Regular Inspections';
                                newCase.ReceptionDetails__c	     = 'HE Care1612 , 12개월차';
                                newCaseList.add(newCase);

                                caseToTarget12MonMap.put(newCaseList.size() - 1, obj.Id);
                            }
                        } else {
                            System.debug('장비의 설치일자 없음');
                        }
                    }
                }
            }
    
            Database.saveResult[] clList = Database.insert(newCaseList);
            Set<Id> caseIds = new Set<Id>();
            for (Database.SaveResult sr : clList) {
                if (sr.isSuccess()) {
                    caseIds.add(sr.getId());
                }
            }
            List<CampaignTarget__c> targetsToUpdate = new List<CampaignTarget__c>();
            List<UTIL_Alert.HistoryWrapper> wrappers = new List<UTIL_Alert.HistoryWrapper>();

            String alertManagerID = [SELECT Id FROM AlertManager__c WHERE Name = 'HE Care 1612 Alert' LIMIT 1].Id;

            List<HE_Equipment__mdt> equipmentList = [
                SELECT Id, Email__c, To_1Month__c, To_6Month__c, To_11Month__c, 
                       CC_1Month__c, CC_6Month__c, CC_11Month__c
                FROM HE_Equipment__mdt
            ];

            List<Case> caseQuery = [SELECT Id, CaseNumber, AccountId, Account.Name, AssetId, Asset.Name, Account.FM_Address__c, Asset.MachineName__c, Asset.MainWorkCtr__r.Name FROM Case WHERE Id IN :caseIds];
            Map<Id, Case> caseMap = new Map<Id, Case>(caseQuery);

            List<String> to1MonthEmailList = new List<String>();
            List<String> to6MonthEmailList = new List<String>();
            List<String> to12MonthEmailList = new List<String>();
            List<String> cc1MonthEmailList = new List<String>();
            List<String> cc6MonthEmailList = new List<String>();
            List<String> cc12MonthEmailList = new List<String>();
            
            for (HE_Equipment__mdt obj : equipmentList) {
                if (obj.To_1Month__c == true) {
                    to1MonthEmailList.add(obj.Email__c);
                }
                if (obj.To_6Month__c == true) {
                    to6MonthEmailList.add(obj.Email__c);
                }
                if (obj.To_11Month__c == true) {
                    to12MonthEmailList.add(obj.Email__c);
                }
                if (obj.CC_1Month__c == true) {
                    cc1MonthEmailList.add(obj.Email__c);
                }
                if (obj.CC_6Month__c == true) {
                    cc6MonthEmailList.add(obj.Email__c);
                }
                if (obj.CC_11Month__c == true) {
                    cc12MonthEmailList.add(obj.Email__c);
                }
            }

            System.debug('to1MonthEmailList'+to1MonthEmailList);
            System.debug('to6MonthEmailList'+to6MonthEmailList);
            System.debug('to12MonthEmailList'+to12MonthEmailList);
            System.debug('cc1MonthEmailList'+cc1MonthEmailList);
            System.debug('cc6MonthEmailList'+cc6MonthEmailList);
            System.debug('cc12MonthEmailList'+cc12MonthEmailList);

            for (Integer i = 0; i < clList.size(); i++) {
                if (clList[i].isSuccess()) {
                    Id caseId = clList[i].getId();
                    Case caseObj = caseMap.get(caseId);
                    System.debug('caseObj' + caseObj);
                    UTIL_Alert.HistoryWrapper wrapper = new UTIL_Alert.HistoryWrapper();
                    wrapper.alertID       = alertManagerID;
                    wrapper.targetID      = caseId;
                    wrapper.alertType     = 'Email';
                    wrapper.alertLanguage = 'ko';
            
                    if (caseToTarget1MonMap.containsKey(i)) {
                        System.debug('1개월차 메일');
                        Id targetId = caseToTarget1MonMap.get(i);
                        CampaignTarget__c target = new CampaignTarget__c(Id = targetId, X_1month__c = caseId);
                        targetsToUpdate.add(target);
            
                        wrapper.title              = 'HE Care 1612 1개월차 Ticket 생성 알림';
                        wrapper.receiverforEmail   = to1MonthEmailList;
                        wrapper.receiverforEmailCC = cc1MonthEmailList;
                        wrapper.elementList        = new List<String>{ caseObj.CaseNumber, caseObj.Account.Name, caseObj.Asset.Name, caseObj.Asset.MachineName__c, caseObj.Account.FM_Address__c, caseObj.Asset.MainWorkCtr__r.Name };

                        wrappers.add(wrapper);
            
                    } else if (caseToTarget6MonMap.containsKey(i)) {
                        System.debug('6개월차 메일');
                        Id targetId = caseToTarget6MonMap.get(i);
                        CampaignTarget__c target = new CampaignTarget__c(Id = targetId, X_6month__c = caseId);
                        targetsToUpdate.add(target);
            
                        wrapper.title              = 'HE Care 1612 6개월차 Ticket 생성 알림';
                        wrapper.receiverforEmail   = to6MonthEmailList;
                        wrapper.receiverforEmailCC = cc6MonthEmailList;
                        wrapper.elementList        = new List<String>{ caseObj.CaseNumber, caseObj.Account.Name, caseObj.Asset.Name, caseObj.Asset.MachineName__c, caseObj.Account.FM_Address__c, caseObj.Asset.MainWorkCtr__r.Name};

                        wrappers.add(wrapper);
            
                    } else if (caseToTarget12MonMap.containsKey(i)) {
                        System.debug('12개월차 메일');
                        Id targetId = caseToTarget12MonMap.get(i);
                        CampaignTarget__c target = new CampaignTarget__c(Id = targetId, X_12month__c = caseId);
                        targetsToUpdate.add(target);
            
                        wrapper.title              = 'HE Care 1612 12개월차 Ticket 생성 알림';
                        wrapper.receiverforEmail   = to12MonthEmailList;
                        wrapper.receiverforEmailCC = cc12MonthEmailList;
                        wrapper.elementList        = new List<String>{ caseObj.CaseNumber, caseObj.Account.Name, caseObj.Asset.Name, caseObj.Asset.MachineName__c, caseObj.Account.FM_Address__c, caseObj.Asset.MainWorkCtr__r.Name};

                        wrappers.add(wrapper);
                    }
                }
            }
                        
            if (!targetsToUpdate.isEmpty()) {
                update targetsToUpdate;
            }
            if (!wrappers.isEmpty()) {
                UTIL_Alert.runAlertEvent(wrappers);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context){
        System.debug('배치 실행 완료');
    }

    public void execute(SchedulableContext sc) {
        DN_HECareBatch batch = new DN_HECareBatch();
        Database.executeBatch(batch, 1);        
    }
}