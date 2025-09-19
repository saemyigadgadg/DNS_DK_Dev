/**
* @Class : DN_TicketEscalationRuleBatch
* @Description : 등록된 Ticket Escalation Rule 을 기준으로 조건에 맞는 Ticket 의 Escalation Lv. 변경 Batch
* @Author : Junyeong, Choi
* @Date : 2024. 12. 23.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-12-23 | Junyeong, Choi   | 최초작성
*
*/
global class DN_TicketEscalationRuleBatch implements Database.Batchable<TicketEscalationRule__c>, Database.Stateful, Database.AllowsCallouts{
    // Batch를 현재 실행 중인 사용자 ID를 저장하기 위해 -> 실시간 or 배치 구분
    public String recordId = '';
    public String currentUserId = '';
    public List<TicketEscalationRule__c> batchRule                        = new List<TicketEscalationRule__c>();
    public List<TicketEscalationRule__c> batchRuleList                    = new List<TicketEscalationRule__c>();
    public Map<Id, List<TicketEscalationFailureArea__c>> FAListForERId    = new Map<Id, List<TicketEscalationFailureArea__c>>();
    public Map<Id, List<TicketEscalationEquipment__c>> equipListForERId   = new Map<Id, List<TicketEscalationEquipment__c>>();
    public Map<Id, List<TicketEscalationRegion__c>> regionListForERId     = new Map<Id, List<TicketEscalationRegion__c>>();
    public Map<Id, List<TicketManager__c>> managerListForERId             = new Map<Id, List<TicketManager__c>>();
    public Map<Id, List<TicketEscalationQueue__c>> queueListForERId       = new Map<Id, List<TicketEscalationQueue__c>>();
    public Map<Id, List<TicketEscalationRole__c>> roleListForERId         = new Map<Id, List<TicketEscalationRole__c>>();

    public DN_TicketEscalationRuleBatch(String recordId, String currentUserId) {
        System.debug('recordId : ' + recordId);
        System.debug('currentUserId : ' + currentUserId);
        this.recordId        = recordId;
        this.currentUserId   = currentUserId;

        if(String.isNotEmpty(recordId)) {
            //-------------------------------------------------------
            //---------------------Realtime--------------------------
            //-------------------------------------------------------
            this.batchRule =
            [
                SELECT Id, Account__c, Branch__c, Country__c, ElapsedDay__c, EscalationLv__c, EscalationType__c,
                IndexNumber__c, IsActive__c, TargetEscalationLv__c, TicketType__c, InternalTicketType__c, IsChange__c
                FROM TicketEscalationRule__c 
                WHERE Id =: recordId
            ];
            // 고장부위
            List<TicketEscalationFailureArea__c> failureAreaList = 
            [
                SELECT Id, TicketEscalationRule__c, FailureAreaMain__c, FailureAreaMiddle__c, FailurePhenomenon__c
                FROM TicketEscalationFailureArea__c
                WHERE TicketEscalationRule__c =: recordId
            ];
            if(!failureAreaList.isEmpty()) {
                for(TicketEscalationFailureArea__c fa : failureAreaList) {
                    if (!this.FAListForERId.containsKey(fa.TicketEscalationRule__c)) {
                        this.FAListForERId.put(fa.TicketEscalationRule__c, new List<TicketEscalationFailureArea__c>());
                    }
                    this.FAListForERId.get(fa.TicketEscalationRule__c).add(fa);
                }
            }   
            // 장비
            List<TicketEscalationEquipment__c> equipmentList = 
            [
                SELECT Id, Escalation__c, EquipmentNo__c
                FROM TicketEscalationEquipment__c
                WHERE Escalation__c =: recordId
            ];
            if(!equipmentList.isEmpty()) {
                for(TicketEscalationEquipment__c equip : equipmentList) {
                    if (!this.equipListForERId.containsKey(equip.Escalation__c)) {
                        this.equipListForERId.put(equip.Escalation__c, new List<TicketEscalationEquipment__c>());
                    }
                    this.equipListForERId.get(equip.Escalation__c).add(equip);
                }
            }
            // Region
            List<TicketEscalationRegion__c> regionList = 
            [
                SELECT Id, Escalation__c, StateCity__c, CityWard__c
                FROM TicketEscalationRegion__c
                WHERE Escalation__c =: recordId
            ];
            if(!regionList.isEmpty()) {
                for(TicketEscalationRegion__c re : regionList) {
                    if (!this.regionListForERId.containsKey(re.Escalation__c)) {
                        this.regionListForERId.put(re.Escalation__c, new List<TicketEscalationRegion__c>());
                    }
                    this.regionListForERId.get(re.Escalation__c).add(re);
                }
            }
            // 담당자
            List<TicketManager__c> managerList = 
            [
                SELECT Id, TicketEscalationRule__c, Employee__c, Function__c, Record_Type__c
                FROM TicketManager__c
                WHERE TicketEscalationRule__c =: recordId
            ];
            if(!managerList.isEmpty()) {
                for(TicketManager__c tm : managerList) {
                    if (!this.managerListForERId.containsKey(tm.TicketEscalationRule__c)) {
                        this.managerListForERId.put(tm.TicketEscalationRule__c, new List<TicketManager__c>());
                    }
                    this.managerListForERId.get(tm.TicketEscalationRule__c).add(tm);
                }
            }
            // Queue 목록
            List<TicketEscalationQueue__c> queueList =
            [
                SELECT Id, Name, TicketEscalationRule__c
                FROM TicketEscalationQueue__c
                WHERE TicketEscalationRule__c =: recordId
            ];
            if(!queueList.isEmpty()) {
                for(TicketEscalationQueue__c teq : queueList) {
                    if (!this.queueListForERId.containsKey(teq.TicketEscalationRule__c)) {
                        this.queueListForERId.put(teq.TicketEscalationRule__c, new List<TicketEscalationQueue__c>());
                    }
                    this.queueListForERId.get(teq.TicketEscalationRule__c).add(teq);
                }
            }
            // Role 목록
            List<TicketEscalationRole__c> roleList =
            [
                SELECT Id, Name, TicketEscalationRule__c
                FROM TicketEscalationRole__c
                WHERE TicketEscalationRule__c =: recordId
            ];
            if(!roleList.isEmpty()) {
                for(TicketEscalationRole__c ter : roleList) {
                    if (!this.roleListForERId.containsKey(ter.TicketEscalationRule__c)) {
                        this.roleListForERId.put(ter.TicketEscalationRule__c, new List<TicketEscalationRole__c>());
                    }
                    this.roleListForERId.get(ter.TicketEscalationRule__c).add(ter);
                }
            }
        //-------------------------------------------------------
        //---------------------Batch-----------------------------
        //-------------------------------------------------------
        } else {
            this.batchRuleList = 
            [
                SELECT Id, Account__c, Branch__c, Country__c, ElapsedDay__c, EscalationLv__c, EscalationType__c, 
                IndexNumber__c, IsActive__c, TargetEscalationLv__c, TicketType__c, InternalTicketType__c, IsChange__c
                FROM TicketEscalationRule__c
                WHERE IsActive__c = true
                AND EscalationType__c = 'Batch'
                ORDER BY EscalationLv__c DESC, IndexNumber__c ASC
            ];
            List<Id> ruleIds = new List<Id>();
            for(TicketEscalationRule__c rule : this.batchRuleList) ruleIds.add(rule.Id);
            
            // 고장부위
            List<TicketEscalationFailureArea__c> failureAreaList = [
                SELECT Id, TicketEscalationRule__c, FailureAreaMain__c, FailureAreaMiddle__c, FailurePhenomenon__c
                FROM TicketEscalationFailureArea__c
                WHERE TicketEscalationRule__c =: ruleIds
            ];
            if(!failureAreaList.isEmpty()) {
                for (TicketEscalationFailureArea__c fa : failureAreaList) {
                    if (!this.FAListForERId.containsKey(fa.TicketEscalationRule__c)) {
                        this.FAListForERId.put(fa.TicketEscalationRule__c, new List<TicketEscalationFailureArea__c>());
                    }
                    this.FAListForERId.get(fa.TicketEscalationRule__c).add(fa);
                }
            }
            // 장비
            List<TicketEscalationEquipment__c> equipmentList = 
            [
                SELECT Id, Escalation__c, EquipmentNo__c
                FROM TicketEscalationEquipment__c
                WHERE Escalation__c =: ruleIds
            ];
            if(!equipmentList.isEmpty()) {
                for(TicketEscalationEquipment__c equip : equipmentList) {
                    if (!this.equipListForERId.containsKey(equip.Escalation__c)) {
                        this.equipListForERId.put(equip.Escalation__c, new List<TicketEscalationEquipment__c>());
                    }
                    this.equipListForERId.get(equip.Escalation__c).add(equip);
                }
            }
            // Region
            List<TicketEscalationRegion__c> regionList = 
            [
                SELECT Id, Escalation__c, StateCity__c, CityWard__c
                FROM TicketEscalationRegion__c
                WHERE Escalation__c =: ruleIds
            ];
            if(!regionList.isEmpty()) {
                for(TicketEscalationRegion__c re : regionList) {
                    if (!this.regionListForERId.containsKey(re.Escalation__c)) {
                        this.regionListForERId.put(re.Escalation__c, new List<TicketEscalationRegion__c>());
                    }
                    this.regionListForERId.get(re.Escalation__c).add(re);
                }
            }
            // 담당자
            List<TicketManager__c> managerList = 
            [
                SELECT Id, TicketEscalationRule__c, Employee__c, Function__c, Record_Type__c
                FROM TicketManager__c
                WHERE TicketEscalationRule__c =: ruleIds
            ];
            if(!managerList.isEmpty()) {
                for(TicketManager__c tm : managerList) {
                    if (!this.managerListForERId.containsKey(tm.TicketEscalationRule__c)) {
                        this.managerListForERId.put(tm.TicketEscalationRule__c, new List<TicketManager__c>());
                    }
                    this.managerListForERId.get(tm.TicketEscalationRule__c).add(tm);
                }
            }
        }
    }

    // Batch Start
    public List<TicketEscalationRule__c> start(Database.BatchableContext context){
        if(String.isNotEmpty(recordId)) {
            return this.batchRule;
        } else {
            return this.batchRuleList;
      }
    }

    // Batch Execute
    public void execute(Database.BatchableContext context, List<TicketEscalationRule__c> scope) {
        Savepoint sp = Database.setSavepoint(); 
        try {
            System.debug(' =============== Batch Execute ================');
            System.debug('scope.Size() : ' + scope.size());
            System.debug('scope.Size() : ' + scope);
            List<TicketEscalationRule__c> ruleList = (List<TicketEscalationRule__c>) scope;
            // Rule
            String accountName;        // 업체명
            String ticketMajor;        // 티켓대분류
            String ticketMiddle;       // 티켓중분류
            String escalationLv;       // Escalation Lv.
            String targetEscalationLv; // Target Escalation Lv.
            String branch;             // 지사
            String country;            // Ticket Owner 의 국가
            Decimal elapsedDay = 0;    // 티켓 접수일 이후 경과일수
            Decimal indexNumber = 0;   // 우선순위
            Boolean isChange = null;   // Check 시 진짜 Owner 를 변경해주고, Uncheck 시 알림만 전송

            List<TicketEscalationFailureArea__c> failureAreaList = new List<TicketEscalationFailureArea__c>();
            List<TicketEscalationEquipment__c> equipmentList     = new List<TicketEscalationEquipment__c>();
            List<TicketEscalationRegion__c> regionList           = new List<TicketEscalationRegion__c>();
            List<TicketManager__c> managerList                   = new List<TicketManager__c>();
            List<TicketEscalationQueue__c> queueList             = new List<TicketEscalationQueue__c>();
            List<TicketEscalationRole__c> roleList               = new List<TicketEscalationRole__c>();

            List<Case> caseList                                  = new List<Case>();
            for(TicketEscalationRule__c rule : ruleList) {
                failureAreaList      = this.FAListForERId.get(rule.Id);      // 고장부위 List
                equipmentList        = this.equipListForERId.get(rule.Id);   // 장비 List   v
                regionList           = this.regionListForERId.get(rule.Id);  // Region List
                managerList          = this.managerListForERId.get(rule.Id); // Manager List
                queueList            = this.queueListForERId.get(rule.Id);   // Queue List
                roleList             = this.roleListForERId.get(rule.Id);    // Role List

                accountName          = rule.Account__c;
                ticketMajor          = rule.TicketType__c;
                ticketMiddle         = rule.InternalTicketType__c;
                branch               = rule.Branch__c;
                escalationLv         = rule.EscalationLv__c;
                targetEscalationLv   = rule.TargetEscalationLv__c;
                country              = rule.Country__c;
                elapsedDay           = rule.ElapsedDay__c;
                indexNumber          = rule.IndexNumber__c;
                isChange             = rule.IsChange__c;
            }
            
            String sQuery = 
            'SELECT Id, CaseNumber, AccountId, Account.ShippingPostalCode, TicketType__c, InternalTicketType__c, EscLev__c, FailureArea__c, FailureAreaDetail__c, FailurePhenomenon__c, AssetId, ApplicationDateTime__c, FM_Country__c, Status FROM Case';
            List<String> wQuery = new List<String>();
            
            if (String.isNotEmpty(accountName)) {
                wQuery.add('AccountId = \'' + accountName + '\'');
            }
            if (String.isNotEmpty(ticketMajor)) {
                wQuery.add('TicketType__c = \'' + ticketMajor + '\'');
            }
            if (String.isNotEmpty(ticketMiddle)) {
                wQuery.add('InternalTicketType__c = \'' + ticketMiddle + '\'');
            }
            if (String.isNotEmpty(escalationLv)) {
                wQuery.add('EscLev__c = \'' + escalationLv + '\'');
            }
            if(equipmentList != null && equipmentList.size() > 0) {
                SET<Id> equipIds = new SET<Id>();
                for(TicketEscalationEquipment__c equipment : equipmentList) {
                    equipIds.add(equipment.EquipmentNo__c);
                }
                
                if (!equipIds.isEmpty()) {
                    List<String> equipIdStrings = new List<String>();
                    for (Id equipId : equipIds) {
                        equipIdStrings.add('\'' + String.valueOf(equipId) + '\'');
                    }
                    wQuery.add('AssetId IN (' + String.join(equipIdStrings, ', ') + ')');
                }
            }
            if (elapsedDay > 0) {
                Date targetDate = Date.today().addDays(-Integer.valueOf(elapsedDay));
                wQuery.add('ApplicationDateTime__c <= :targetDate');
            }
            if (String.isNotEmpty(branch)) {
                wQuery.add('FM_Country__c = \'' + branch + '\'');
            }
            wQuery.add('Status NOT IN (\'Closed\')');
            
            if (!wQuery.isEmpty()) {
                sQuery += ' WHERE ' + String.join(wQuery, ' AND ');
            }
            System.debug('sQuery ::: ' + sQuery);
            caseList = Database.query(sQuery);
            System.debug('caseList ::: ' + caseList);
            
            // 고장부위 조건 적용
            List<Case> addFACaseList = new List<Case>();
            if((caseList != null && caseList.size() > 0) && (failureAreaList != null && failureAreaList.size() > 0)) {
                for(Case ca : caseList){
                    for(TicketEscalationFailureArea__c fArea : failureAreaList) {
                        String faKey = '';
                        if(fArea.FailureAreaMain__c != null && fArea.FailureAreaMiddle__c == null && fArea.FailurePhenomenon__c == null) {
                            faKey += fArea.FailureAreaMain__c;
                            if(ca.FailureArea__c != null && ca.FailureArea__c.equals(faKey)) {
                                addFACaseList.add(ca);
                            }
                        }
                        if(fArea.FailureAreaMain__c != null && fArea.FailureAreaMiddle__c != null && fArea.FailurePhenomenon__c == null) {
                            faKey += fArea.FailureAreaMain__c + fArea.FailureAreaMiddle__c;
                            if(ca.FailureArea__c != null && ca.FailureAreaDetail__c != null && (ca.FailureArea__c + ca.FailureAreaDetail__c).equals(faKey)) {
                                addFACaseList.add(ca);
                            }
                        }
                        if(fArea.FailureAreaMain__c != null && fArea.FailureAreaMiddle__c != null && fArea.FailurePhenomenon__c != null) {
                            faKey += fArea.FailureAreaMain__c + fArea.FailureAreaMiddle__c + fArea.FailurePhenomenon__c;
                            if(ca.FailureArea__c != null && ca.FailureAreaDetail__c != null && ca.FailurePhenomenon__c != null && (ca.FailureArea__c + ca.FailureAreaDetail__c + ca.FailurePhenomenon__c).equals(faKey)) {
                                addFACaseList.add(ca);
                            }
                        }
                    }
                }
            } else {
                addFACaseList = caseList;
            }
            System.debug('addFACaseList ::: ' + addFACaseList);

            // Region 조건 적용
            List<Case> addRGCaseList = new List<Case>();
            Map<String, JurisdictionalInformation__mdt> zipCodeMap = new Map<String, JurisdictionalInformation__mdt>();
            List<JurisdictionalInformation__mdt> zipCodeList = 
            [
                SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, CityCounty__c, ZipCode__c, City__c, CityCounty2__c 
                FROM JurisdictionalInformation__mdt 
            ];
            for(JurisdictionalInformation__mdt zip : zipCodeList) {
                if(!zipCodeMap.containsKey(zip.ZipCode__c)) {
                    zipCodeMap.put(zip.ZipCode__c, zip);
                }
            }
            if((addFACaseList != null && addFACaseList.size() > 0) && (regionList != null && regionList.size() > 0)) {
                for(Case c : addFACaseList) {
                    String accZipCode = c.Account.ShippingPostalCode.substring(0,3);
                    if(accZipCode != null && zipCodeMap.containsKey(accZipCode)) {
                        String city     = zipCodeMap.get(accZipCode).City__c;
                        String region   = zipCodeMap.get(accZipCode).CityCounty__c;

                        for(TicketEscalationRegion__c reg : regionList) {
                            String stateCity = reg.StateCity__c;
                            String cityWard	 = reg.CityWard__c;

                            if(stateCity != null && cityWard != null) {
                                if(city+region == stateCity+cityWard) {
                                    addRGCaseList.add(c);
                                }
                            }
                            if(stateCity != null && cityWard == null) {
                                if(city == stateCity) {
                                    addRGCaseList.add(c);
                                }
                            }
                            if(stateCity == null && cityWard != null) {
                                if(region == cityWard) {
                                    addRGCaseList.add(c);
                                }
                            }
                        }

                    } else {
                        // Account 에 Zipcode 가 없거나 메타데이터에 해당 코드가 없는경우,
                        System.debug('ZipCode OR MetaData 에 Data 없음');
                    }
                }
            } else {
                addRGCaseList = addFACaseList;
            }
            System.debug('addRGCaseList ::: ' + addRGCaseList);
            
            // Target Escalation Lv.적용
            if(isChange) {
                // Ticket Manager 적용
                if(managerList != null && managerList.size() > 0) {
                    switch on managerList[0].Record_Type__c	{
                        when 'Employee'{
                            for(Case cs : addRGCaseList) {
                                if(managerList.get(0).Employee__c != null) {
                                    cs.OwnerId   = managerList[0].Employee__c;
                                    cs.EscLev__c = targetEscalationLv;
                                } else {
                                    System.debug('Employee -> Null');
                                }
                            }
                            if(addRGCaseList != null || addRGCaseList.size() > 0) {   
                                update addRGCaseList;
                            }
                        }
                        when 'Queue'{
                            if(queueList != null || queueList.size() > 0) {
                                System.debug('queueList =>' + queueList);
                                Group gro = [SELECT Id, Name, Type FROM Group WHERE Name = :queueList[0].Name AND Type = 'Queue' LIMIT 1];
                                List<GroupMember> groupMemberList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :gro.Id];
                                Set<Id> userIds = new Set<Id>();
                                for(GroupMember gm : groupMemberList) {
                                    userIds.add(gm.UserOrGroupId);
                                }
                                List<User> userList = [SELECT Id, Name, Email FROM User WHERE Id IN :userIds];
                                System.debug('userList =>' + userList);
                                if(managerList[0].Function__c == 'setSequentiallyAssign') {
                                    setSequentiallyAssign(addRGCaseList, userList, targetEscalationLv);
                                }
                            } else {
                                System.debug('등록된 Queue 없음');
                            }
                        }
                        when 'Role'{
                            if(roleList != null || roleList.size() > 0) {
                                System.debug('roleList =>' + roleList);
                                UserRole targetRole = [SELECT Id FROM UserRole WHERE Name = :roleList[0].Name LIMIT 1];
                                List<User> userList = [SELECT Id, Name, UserRoleId FROM User WHERE UserRoleId = :targetRole.Id];
                                System.debug('userList =>' + userList);
                                if(managerList[0].Function__c == 'setSequentiallyAssign') {
                                    setSequentiallyAssign(addRGCaseList, userList, targetEscalationLv);
                                }
                            } else {
                                System.debug('등록된 Role 없음');
                            }
                        }
                        when 'Function'{
                            if(managerList[0].Function__c == 'setModelManager') {
                                setModelManager(addRGCaseList, targetEscalationLv);
                            }
                        }
                    }
                }
            } else {
                isNotChange(addRGCaseList, escalationLv, targetEscalationLv);
            }

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context){
        System.debug('배치 실행 완료');
    }

    //---------------------setSequentiallyAssign(순차배정)-----------------------------
    public void setSequentiallyAssign(List<Case> addRGCaseList, List<User> userList, String targetEscalationLv) {
        System.debug('addRGCaseList'+addRGCaseList);
        System.debug('userList'+userList);
        if (addRGCaseList.isEmpty() || userList.isEmpty()) {
            System.debug('addRGCaseList || userList is Null');
            return;
        }
        Integer memberCount = userList.size();
        Integer index = 0;
        for (Integer i = 0; i < addRGCaseList.size(); i++) {
            addRGCaseList[i].OwnerId   = userList[index].Id;
            addRGCaseList[i].EscLev__c = targetEscalationLv;
            index++;
            if (index >= memberCount) {
                index = 0;
            }
        }
        update addRGCaseList;
    }

    //----------------해당 Ticket 장비의 Model 담당자를 Owner 로 지정---------------------
    public void setModelManager(List<Case> addRGCaseList, String targetEscalationLv) {
        System.debug('caseList'+addRGCaseList);
        if (addRGCaseList.size() > 0) {
            Map<String, String> modelManagerMap = new Map<String, String>();
            List<ModelManager__c> mmList = [SELECT Id, Manager__c, Name FROM ModelManager__c];
            for(ModelManager__c mm : mmList) {
                modelManagerMap.put(mm.Name, mm.Manager__c);
            }
            for(Case caseInfo : addRGCaseList) {
                if(caseInfo.Asset.MachineName__c != null) {
                    Id ownerId = modelManagerMap.get(caseInfo.Asset.MachineName__c);
                    if (ownerId != null) {
                        caseInfo.OwnerId = ownerId;
                    } else {
                        System.debug('OwnerId를 찾을 수 없음: ' + caseInfo.Asset.MachineName__c);
                    }
                    caseInfo.EscLev__c = targetEscalationLv;
                } else {
                    System.debug('장비에 Model 명이 없음');
                }
            }
            update addRGCaseList;
        }
    }

    //----------------------is Change = False => Noti 만 발송--------------------------
    public void isNotChange(List<Case> caseList, String escalationLv, String targetEscalationLv) {
        System.debug('caseList =>' + caseList);
        if (caseList == null || caseList.isEmpty()) {
            return;
        }
        List<UTIL_Alert.HistoryWrapper> wrappers   = new List<UTIL_Alert.HistoryWrapper>();
        String alertManagerID = [SELECT Id, Name FROM AlertManager__c WHERE IsActive__c = true AND Name = 'Ticket Escalation Change Noti' LIMIT 1].Id;
        for(Case obj : caseList) {
            UTIL_Alert.HistoryWrapper wrapper = new UTIL_Alert.HistoryWrapper();
            wrapper.alertType       = 'Notification';
            wrapper.elementList.add(obj.CaseNumber);
            wrapper.elementList.add(escalationLv);
            wrapper.elementList.add(targetEscalationLv);
            wrapper.alertID         = alertManagerID;
            wrapper.targetID        = obj.Id;
            wrapper.receiverforID   = new Set<Id>{obj.OwnerId};
            wrapper.alertLanguage   = 'ko';
            wrappers.add(wrapper);
        }
        System.debug('wrappers'+wrappers);
        UTIL_Alert.runAlertEvent(wrappers);
    }
}