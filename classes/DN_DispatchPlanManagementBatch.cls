/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-11-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public with sharing class DN_DispatchPlanManagementBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
 
    private List<ServiceTerritory> stList;
    private List<PendingprocessingReport__c> existPrList;
    private List<PendingprocessingReport__c> addPrList;
    private List<ServiceResource> srList;
    Map<String, PendingprocessingReport__c> existingKeyMap = new Map<String, PendingprocessingReport__c>();
    Map<String, Integer> srMap = new Map<String, Integer>();

    public Database.QueryLocator start(Database.BatchableContext context) {
        List<PendingprocessingReport__c> insertPRList = new List<PendingprocessingReport__c>();
        List<PendingprocessingReport__c> updatePRList = new List<PendingprocessingReport__c>();
        String thisYear = String.valueOf(System.Today().year());

        // 데이터에 Work Order 에 배정되어 있는 지사만 나오기 vs 전체 지사를 일단 기준으로 다 나오기. => 나중에 체크해보기, 일단 전체 지사를 기준으로 해봄
        // 현재 W/C
        stList = [
            SELECT Id, Name, PlanningPlant__c, IsActive
            FROM ServiceTerritory
            WHERE PlanningPlant__c = '184S' // 국내만
            AND IsActive = true
        ];

        Set<String> keyIds = new Set<String>();
        for(ServiceTerritory st : stList) {
            keyIds.add(thisYear + '_' + st.Name);
        }
        System.debug('keyIds => ' + keyIds);
        
        existPrList = [ // 현재 Insert 되어있는 'Years + WC__c' Key
          SELECT Id, Year__c, WC__c, TotalWorkingDay__c,
          JanuaryDay__c, JanuaryWorkingDay__c, FebruaryDay__c, FebruaryWorkingDay__c, MarchDay__c, MarchWorkingDay__c, AprilDay__c, AprilWorkingDay__c,
          MayDay__c, MayWorkingDay__c, JuneDay__c, JuneWorkingDay__c, JulyDay__c, JulyWorkingDay__c, AugustDay__c, AugustWorkingDay__c, SeptemberDay__c, SeptemberWorkingDay__c,
          OctoberDay__c, OctoberWorkingDay__c, NovemberDay__c, NovemberWorkingDay__c, DecemberDay__c, DecemberWorkingDay__c, Persons__c
          FROM PendingprocessingReport__c
          WHERE DispatchPlanManagement__c = true
        ];
        for(PendingprocessingReport__c pr : existPrList) {
            existingKeyMap.put(pr.Year__c + '_' + pr.WC__c, pr);
        }
        
        srList = [
            SELECT Name, Service_Territory__c, Service_Territory__r.Name, Service_Territory__r.Id
            FROM ServiceResource
        ];
        // srMap 초기화 (기본값 0 설정)
        Map<String, Integer> srMap = new Map<String, Integer>();
        for (String key : keyIds) {
            srMap.put(key, 0);
        }

        // ServiceResource 정보를 이용해 srMap 채우기
        for (ServiceResource sr : srList) {
            String key = thisYear + '_' + sr.Service_Territory__r.Name;
            if (srMap.containsKey(key)) {
                srMap.put(key, srMap.get(key) + 1);
            }
        }

        Set<String> existingKeys = new Set<String>();
        if(existPrList.size() == 0) {
            for (String key : keyIds) {
                PendingprocessingReport__c newPr = new PendingprocessingReport__c();
                String[] parts = key.split('_');
                if (parts.size() > 1) {
                    newPr.Year__c = parts[0];
                    newPr.WC__c   = parts[1];
                }
                newPr.DispatchPlanManagement__c = true;
                newPr.Persons__c = srMap.get(key); // ServiceResource의 값 반영
                insertPRList.add(newPr);
            }
        } else {
            for (PendingprocessingReport__c pr : existPrList) {
                existingKeys.add(pr.Year__c + '_' + pr.WC__c);
            }            
            for (String key : keyIds) { // key : 2025_대구지사
                if (!existingKeys.contains(key)) {  // 존재하지 않을 때
                    String[] parts = key.split('_');
                    if (parts.size() > 1) {
                        PendingprocessingReport__c newPr = new PendingprocessingReport__c();
                        newPr.Year__c = parts[0];
                        newPr.WC__c   = parts[1];
                        newPr.DispatchPlanManagement__c = true;
                        newPr.Persons__c                = srMap.get(key);
                        insertPRList.add(newPr);
                    }
                } else { // 존재할 때
                    String[] parts = key.split('_');
                    if (parts.size() > 1) {
                        PendingprocessingReport__c updatePr = existingKeyMap.get(key);
                        updatePr.Persons__c                = srMap.get(key);
                        updatePRList.add(updatePr);
                    }
                }
            }
        }

        if(insertPRList.size() > 0) {
            insert insertPRList;
            for(PendingprocessingReport__c pr : insertPRList) {
                existingKeyMap.put(pr.Year__c + '_' + pr.WC__c, pr);
            }
            if (addPrList == null) {
                addPrList = new List<PendingprocessingReport__c>();
            }            
            addPrList.addAll(insertPRList);
        }
        if(existPrList.size() > 0) {
            if (addPrList == null) {
                addPrList = new List<PendingprocessingReport__c>();
            }            
            addPrList.addAll(existPrList);
        }
        if(updatePRList.size() > 0) {
            update updatePRList;
        }
        
        return Database.getQueryLocator([
            SELECT Id, CreatedDate, ServiceTerritoryId, ServiceTerritory.Name, RecordType.Name, Worker__c, Worker__r.Name
            FROM WorkOrder
            WHERE RecordType.Name = 'Work Order Record Type'
            AND ServiceTerritoryId != null
            // AND CreateDate = THIS_YEAR   // 이건 나중에 Mig 해서 예전 데이터 다 넣고 설정해놓기
            AND CreatedDate = Yesterday
        ]);
    }

    public void execute(Database.BatchableContext context, List<WorkOrder> scope) {
        System.debug(' =============== Batch Execute ================');
        System.debug('scope.Size() : ' + scope.size());
        System.debug('scope : ' + scope);

        Set<Id> processedIds      = new Set<Id>();
        Set<String> processedKeys = new Set<String>();

        List<PendingprocessingReport__c> updateReport = new List<PendingprocessingReport__c>();
        for(WorkOrder wo : scope) {
            // wo 의 CreatedDate 를 읽어서 WorkOrder 의 Year + ServiceTerritory.Name 으로 Key 를 만들고, existingKeyMap 을 이용하여 해당 Record 에 wo 의 Month 에 맞게 ++.
            Integer yearInt   = wo.CreatedDate.year();       // 연도 값 추출
            String yearString = String.valueOf(yearInt);     // 2025
            String stName     = wo.ServiceTerritory.Name;    // 대전지사
            String woKey      = yearString + '_' + stName;

            // 중복 woKey 업데이트 제거
            if (processedKeys.contains(woKey)) {
                continue;
            }
            processedKeys.add(woKey);

            PendingprocessingReport__c obj = existingKeyMap.get(woKey);
            System.debug('obj => ' + obj);
            if (obj != null) {
                String monthField;
                switch on wo.CreatedDate.month() {
                    when 1 { monthField = 'JanuaryDay__c'; }
                    when 2 { monthField = 'FebruaryDay__c'; }
                    when 3 { monthField = 'MarchDay__c'; }
                    when 4 { monthField = 'AprilDay__c'; }
                    when 5 { monthField = 'MayDay__c'; }
                    when 6 { monthField = 'JuneDay__c'; }
                    when 7 { monthField = 'JulyDay__c'; }
                    when 8 { monthField = 'AugustDay__c'; }
                    when 9 { monthField = 'SeptemberDay__c'; }
                    when 10 { monthField = 'OctoberDay__c'; }
                    when 11 { monthField = 'NovemberDay__c'; }
                    when 12 { monthField = 'DecemberDay__c'; }
                        }
        
                if (monthField != null) {
                    Integer monthValue = (Decimal) obj.get(monthField) != null ? ((Decimal) obj.get(monthField)).intValue() : 0;
                    monthValue = (monthValue != null) ? monthValue + 1 : 1;
                    obj.put(monthField, monthValue);
        
                    if (!processedIds.contains(obj.Id)) {
                        updateReport.add(obj);
                        processedIds.add(obj.Id);
                    }
                }
            }
        }

        Date yesterday = Date.today().addDays(-1);  // 3/12
        Integer monthInt = yesterday.month();   // 3
        Integer dayInt = yesterday.day();   // 12

       // 어제까지의 '평일 개수' 계산
        Integer workingDays = 0;
        Date firstDay = Date.newInstance(yesterday.year(), monthInt, 1);
        
        for (Date d = firstDay; d <= yesterday; d = d.addDays(1)) {
            Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());  
            Integer dayOfWeek = Integer.valueOf(dt.format('u')); // 요일을 정수로 변환

            if (dayOfWeek != 6 && dayOfWeek != 7) { // 토요일(6), 일요일(7) 제외
                workingDays++;
            }
        }

        List<PendingprocessingReport__c> updatePRT = new List<PendingprocessingReport__c>();
        for(PendingprocessingReport__c prt : addPrList) {
            switch on monthInt {
                when 1 {
                    prt.JanuaryWorkingDay__c = dayInt + ' (' +workingDays+ ')';
                    updatePRT.add(prt);
                }
                when 2 {
                    prt.FebruaryWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
                when 3 {
                    prt.MarchWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
                when 4 {
                    prt.AprilWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
                when 5 {
                    prt.MayWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
                when 6 {
                    prt.JuneWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
                when 7 {
                    prt.JulyWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
                when 8 {
                    prt.AugustWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
                when 9 {
                    prt.SeptemberWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
                when 10 {
                    prt.OctoberWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
                when 11 {
                    prt.NovemberWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
                when 12 {
                    prt.DecemberWorkingDay__c = dayInt + ' (' + workingDays + ')';
                    updatePRT.add(prt);
                }
            }
        }

        if (!updateReport.isEmpty()) {
            update updateReport;
        }
        if (!updatePRT.isEmpty()) {
            update updatePRT;
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Batch 종료');
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 200);
    }
}