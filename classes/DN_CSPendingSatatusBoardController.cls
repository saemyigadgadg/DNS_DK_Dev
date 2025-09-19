/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-25
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-12-20   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class DN_CSPendingSatatusBoardController {

    public DN_CSPendingSatatusBoardController() {}

    // 지사별 클레임 미결현황 (일간) 정보 가져오는 메서드(지도 이미지가 있는 지사만)
    @AuraEnabled
    public static StatusData getStatusData() {
        StatusData result = new StatusData();
        List<String> NameList = new List<String>{'수원지사', '인천지사', '대구지사', '대전지사', '천안POST', '광주POST', '부산지사', '창원지사'};
        List<ServiceTerritory> fullTerritoryList = [SELECT Id, Name, classify__c, ControlWorkcenter__c, ControlWorkcenter__r.Name, (SELECT Id, ServiceResource.CurrentStatus__c FROM ServiceResources) FROM ServiceTerritory WHERE IsActive = true AND PlanningPlant__c = '184S' AND (Name IN :NameList OR ControlWorkcenter__r.Name IN :NameList)];
        List<WorkOrder> workOrderList = [SELECT Id, ServiceTerritoryId, Status FROM WorkOrder WHERE CreatedDate = TODAY];
        Map<String, List<WorkOrder>> workOrderListMap = new Map<String, List<WorkOrder>>();

        for (WorkOrder wo : workOrderList) {
            List<WorkOrder> valueList = new List<WorkOrder>();
            if (workOrderListMap.get(wo.ServiceTerritoryId) != null) {
                valueList = workOrderListMap.get(wo.ServiceTerritoryId);
            }
            valueList.add(wo);
            workOrderListMap.put(wo.ServiceTerritoryId, valueList);
        }

        for (ServiceTerritory st : fullTerritoryList) {

            WorkcenterData wd = new WorkcenterData();

            List<WorkOrder> currentWOList = workOrderListMap.get(st.Id) == null ? new List<WorkOrder>() : workOrderListMap.get(st.Id);

            if (st.classify__c == '지사' || st.classify__c == 'POST') {
                result.workCenterSet.add(st.Name);

                if (result.workCenterData.get(st.Name) != null) {
                    wd = result.workCenterData.get(st.Name);
                }

                wd.AllOrderCount += currentWOList.size();

                for (WorkOrder wo : currentWOList) {
                    if (wo.Status != 'Completed' && wo.Status != 'Confirm') {
                        wd.pendingOrderCount += 1;
                    }
                }

                Decimal completionCount = wd.AllOrderCount - wd.pendingOrderCount;

                wd.completionRate = wd.AllOrderCount == 0 ? 0 : (completionCount / wd.AllOrderCount) * 100;

                if (st.ServiceResources.size() > 0) {

                    wd.personCount += st.ServiceResources.size();

                    for (Integer i = 0; i < st.ServiceResources.size(); i++) {
                        String personStatus = st.ServiceResources[i].ServiceResource.CurrentStatus__c;

                        switch on personStatus {
                            when 'Wait' {
                                wd.statusWait ++;
                            }
                            when 'Education' {
                                wd.statusEdu ++;
                            }
                            when 'SelfWork' {
                                wd.statusEdu ++;
                            }
                            when 'Work' {
                                wd.statusWork ++;
                            }
                        }
                    }
                }

                result.workCenterData.put(st.Name, wd);

            } else if (st.classify__c == 'W/C') {

                if (st.ControlWorkcenter__r.Name == null) {
                    continue;
                }

                result.workCenterSet.add(st.ControlWorkcenter__r.Name);

                if (result.workCenterData.get(st.ControlWorkcenter__r.Name) != null) {
                    wd = result.workCenterData.get(st.ControlWorkcenter__r.Name);
                }

                wd.AllOrderCount += currentWOList.size();

                for (WorkOrder wo : currentWOList) {
                    if (wo.Status != 'Completed' && wo.Status != 'Confirm') {
                        wd.pendingOrderCount += 1;
                    }
                }

                Decimal completionCount = wd.AllOrderCount - wd.pendingOrderCount;

                wd.completionRate = wd.AllOrderCount == 0 ? 0 : (completionCount / wd.AllOrderCount) * 100;

                if (st.ServiceResources.size() > 0) {

                    wd.personCount += st.ServiceResources.size();

                    for (Integer i = 0; i < st.ServiceResources.size(); i++) {
                        String personStatus = st.ServiceResources[i].ServiceResource.CurrentStatus__c;

                        switch on personStatus {
                            when 'Wait' {
                                wd.statusWait ++;
                            }
                            when 'Education' {
                                wd.statusEdu ++;
                            }
                            when 'SelfWork' {
                                wd.statusEdu ++;
                            }
                            when 'Work' {
                                wd.statusWork ++;
                            }
                        }
                    }
                }

                result.workCenterData.put(st.ControlWorkcenter__r.Name, wd);
            } else {
                continue;
            }
        }

        return result;
    }

    public class StatusData {
        
        @AuraEnabled public Set<String>                 workCenterSet   {get; set;}
        @AuraEnabled public Map<String, workCenterData> workCenterData  {get; set;}

        public StatusData() {
            this.workCenterSet = new Set<String>();
            this.workCenterData = new Map<String, WorkcenterData>();
        }
    }
    
    public class WorkcenterData {

        @AuraEnabled public String name                 {get; set;}
        // @AuraEnabled public String imageUrl             {get; set;}
        @AuraEnabled public Decimal AllOrderCount       {get; set;}
        @AuraEnabled public Decimal pendingOrderCount   {get; set;}
        @AuraEnabled public Decimal completionRate      {get; set;}
        @AuraEnabled public Decimal personCount         {get; set;}
        @AuraEnabled public Decimal statusWork          {get; set;}
        @AuraEnabled public Decimal statusWait          {get; set;}
        @AuraEnabled public Decimal statusEdu           {get; set;}

        public WorkcenterData() {
            // this.imageUrl = '';
            this.AllOrderCount = 0;
            this.pendingOrderCount = 0;
            this.completionRate = 0;
            this.personCount = 0;
            this.statusWork = 0;
            this.statusWait = 0;
            this.StatusEdu = 0;
        }

    }
    
}