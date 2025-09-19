/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-29
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-06   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public class DN_TrendReportBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable{

    public List<SObject> start(Database.BatchableContext context){

        List<Case> caseList = new List<Case>();

        if (!Test.isRunningTest()) {
            caseList = [ SELECT  Id, Asset.MachineName__c, CreatedDate, Owner.Name, Status, EndOfReason__c, ApplicationDateTime__c,
                            (SELECT Id, ServiceTerritory.Name, ServiceTerritory.classify__c, ServiceTerritory.ControlWorkcenter__r.Name, ServiceTerritory.WCID__c, CreatedDate FROM WorkOrders ORDER BY CreatedDate LIMIT 1)
                         FROM Case
                         WHERE ApplicationDateTime__c != null
                         AND ApplicationDateTime__c = LAST_MONTH
            ];
        } else {
            caseList = [ SELECT  Id, Asset.MachineName__c, CreatedDate, Owner.Name, Status, EndOfReason__c, ApplicationDateTime__c,
                            (SELECT Id, ServiceTerritory.Name, ServiceTerritory.classify__c, ServiceTerritory.ControlWorkcenter__r.Name, ServiceTerritory.WCID__c, CreatedDate FROM WorkOrders ORDER BY CreatedDate LIMIT 1)
                         FROM Case
                         WHERE ApplicationDateTime__c != null
            ];
        }
        
        return caseList;
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {

        List<Case> caseList = (List<Case>) scope;

        // 연도 + 기종 별 접수현황 Map
        Map<String, List<Case>> machineNameMap = new Map<String, List<Case>>();

        // 연도 + 상담원 별 접수현황
        Map<String, List<Case>> ownerMap = new Map<String, List<Case>>();

        // 연도 + 지사 별 접수현황
        Map<String, List<WorkOrder>> workcenterMap = new Map<String, List<WorkOrder>>();

        // 콜서비스 월별 통계현황
        Map<String, List<Case>> callServiceMap = new Map<String, List<Case>>();
        
        // 월별 오더 통계현황
        Map<String, List<WorkOrder>> orderMap = new Map<String, List<WorkOrder>>();


        for (Case ticket : caseList) {

            String year = ticket.ApplicationDateTime__c.format('yyyy');

            // 연도 + 기종 별 접수현황
            List<Case> machineList = new List<Case>();
            
            if (ticket.Asset.MachineName__c != null && ticket.Asset.MachineName__c != '') {
                if (machineNameMap.get(year + '!' + ticket.Asset.MachineName__c) != null) {
                    machineList = machineNameMap.get(year + '!' + ticket.Asset.MachineName__c);
                }
                machineList.add(ticket);
                machineNameMap.put(year + '!' + ticket.Asset.MachineName__c, machineList);
            }
            
            // 연도 + 상담원 별 접수현황
            List<Case> ownerList = new List<Case>();

            if (ownerMap.get(year + '!' + ticket.Owner.Name) != null) {
                ownerList = ownerMap.get(year + '!' + ticket.Owner.Name);
            }
            ownerList.add(ticket);
            ownerMap.put(year + '!' + ticket.Owner.Name, ownerList);

            // 연도 + 지사 별 접수현황
            List<WorkOrder> workcenterList = new List<WorkOrder>();

            // 월별 오더 통계현황
            List<WorkOrder> orderList = new List<WorkOrder>();

            if (ticket.WorkOrders.size() > 0) {
                WorkOrder caseOrder = ticket.WorkOrders[0];
                
                if (orderMap.get(caseOrder.CreatedDate.format('yyyy') + ' 오더 통계') != null) {
                    orderList = orderMap.get(caseOrder.CreatedDate.format('yyyy') + ' 오더 통계');
                }
                orderList.add(caseOrder);
                orderMap.put(caseOrder.CreatedDate.format('yyyy') + ' 오더 통계', orderList);
                
                if (caseOrder.ServiceTerritory.classify__c == '지사' || caseOrder.ServiceTerritory.classify__c == 'POST') {
                    if (workcenterMap.get(caseOrder.CreatedDate.format('yyyy') + '!' + caseOrder.ServiceTerritory.Name + '!' + caseOrder.ServiceTerritory.Name) != null) {
                        workcenterList = workcenterMap.get(caseOrder.CreatedDate.format('yyyy') + '!' + caseOrder.ServiceTerritory.Name + '!' + caseOrder.ServiceTerritory.Name);
                    }
                    workcenterList.add(caseOrder);
                    workcenterMap.put(caseOrder.CreatedDate.format('yyyy') + '!' + caseOrder.ServiceTerritory.Name + '!' + caseOrder.ServiceTerritory.Name, workcenterList);
                } else {
                    if (workcenterMap.get(caseOrder.CreatedDate.format('yyyy') + '!' + caseOrder.ServiceTerritory.ControlWorkcenter__r.Name + '!' + caseOrder.ServiceTerritory.Name) != null) {
                        workcenterList = workcenterMap.get(caseOrder.CreatedDate.format('yyyy') + '!' + caseOrder.ServiceTerritory.ControlWorkcenter__r.Name + '!' + caseOrder.ServiceTerritory.Name);
                    }
                    workcenterList.add(caseOrder);
                    workcenterMap.put(caseOrder.CreatedDate.format('yyyy') + '!' + caseOrder.ServiceTerritory.ControlWorkcenter__r.Name + '!' + caseOrder.ServiceTerritory.Name, workcenterList);
                }
            }

            // 콜서비스 월별 통계현황
            List<Case> callServiceList = new List<Case>();
            
            if (ticket.Status == 'Closed' && ticket.EndOfReason__c == 'Call Service') {
                if (callServiceMap.get(year + '!' + ticket.Owner.Name + ' Call Service') != null) {
                    callServiceList = callServiceMap.get(year + '!' + ticket.Owner.Name + ' Call Service');
                }
                callServiceList.add(ticket);
                callServiceMap.put(year + '!' + ticket.Owner.Name + ' Call Service', callServiceList);
            }

        }

        // TrendReportObject
        List<TrendReport__c> trendList = [  SELECT  Id, Model__c, Year__c, Type__c, OwnerName__c, WorkCenter__c, TopWorkCenter__c, WorkCenterCode__c,
                                                    Month1__c, Month2__c, Month3__c, Month4__c, Month5__c, Month6__c,
                                                    Month7__c, Month8__c, Month9__c, Month10__c, Month11__c, Month12__c
                                            FROM TrendReport__c];

        // 기종 별 통계 Map
        Map<String, TrendReport__c> machineNameTrendMap = new Map<String, TrendReport__c>();

        // 상담원 별 통계 Map
        Map<String, TrendReport__c> ownerNameTrendMap = new Map<String, TrendReport__c>();

        // 지사 별 접수 Map
        Map<String, TrendReport__c> workcenterTrendMap = new Map<String, TrendReport__c>();

        // 콜서비스 Map
        Map<String, TrendReport__c> callServiceTrendMap = new Map<String, TrendReport__c>();

        // 월 별 오더 Map
        Map<String, TrendReport__c> orderTrendMap = new Map<String, TrendReport__c>();

        for (TrendReport__c trend : trendList) {
            String year = trend.Year__c;
            if (trend.Type__c == '기종 별 통계') {
                machineNameTrendMap.put(year + '!' + trend.Model__c, trend);
            } else if (trend.Type__c == '상담원 별 접수') {
                ownerNameTrendMap.put(year + '!' + trend.OwnerName__c, trend);
            } else if (trend.Type__c == '지사 별 접수') {
                workcenterTrendMap.put(year + '!' + trend.TopWorkCenter__c + '!' + trend.WorkCenter__c, trend);
            } else if (trend.Type__c == '월 별 콜 접수') {
                callServiceTrendMap.put(year + '!' + trend.OwnerName__c + ' Call Service', trend);
            } else if (trend.Type__c == '월 별 오더') {
                orderTrendMap.put(year + ' 오더 통계', trend);
            }
        }

        // Upsert할 TrendReport__c 리스트
        List<TrendReport__c> upsertList = new List<TrendReport__c>();

        // 기종 별 통계 로직
        for (String key : machineNameMap.keySet()) {
            TrendReport__c trend = new TrendReport__c();
            List<Case> ticketList = new List<Case>();

            if (machineNameTrendMap.get(key) != null) {
                trend = machineNameTrendMap.get(key);
            } else {
                trend.Name = key.replace('!', ' ');
                trend.Year__c = key.split('!')[0];
                trend.Model__c = key.split('!')[1];
                trend.Type__c = '기종 별 통계';
            }

            if (machineNameMap.get(key) != null) {
                ticketList = machineNameMap.get(key);
            }

            for (Case ticket : ticketList) {
                switch on ticket.ApplicationDateTime__c.format('MM') {
                    when '01' {
                        trend.Month1__c = trend.Month1__c == null ? 1 : trend.Month1__c + 1;
                    }
                    when '02' {
                        trend.Month2__c = trend.Month2__c == null ? 1 : trend.Month2__c + 1;
                    }
                    when '03' {
                        trend.Month3__c = trend.Month3__c == null ? 1 : trend.Month3__c + 1;
                    }
                    when '04' {
                        trend.Month4__c = trend.Month4__c == null ? 1 : trend.Month4__c + 1;
                    }
                    when '05' {
                        trend.Month5__c = trend.Month5__c == null ? 1 : trend.Month5__c + 1;
                    }
                    when '06' {
                        trend.Month6__c = trend.Month6__c == null ? 1 : trend.Month6__c + 1;
                    }
                    when '07' {
                        trend.Month7__c = trend.Month7__c == null ? 1 : trend.Month7__c + 1;
                    }
                    when '08' {
                        trend.Month8__c = trend.Month8__c == null ? 1 : trend.Month8__c + 1;
                    }
                    when '09' {
                        trend.Month9__c = trend.Month9__c == null ? 1 : trend.Month9__c + 1;
                    }
                    when '10' {
                        trend.Month10__c = trend.Month10__c == null ? 1 : trend.Month10__c + 1;
                    }
                    when '11' {
                        trend.Month11__c = trend.Month11__c == null ? 1 : trend.Month11__c + 1;
                    }
                    when '12' {
                        trend.Month12__c = trend.Month12__c == null ? 1 : trend.Month12__c + 1;
                    }
                }
            }
            upsertList.add(trend);
        }

        // 상담원 별 접수 로직
        for (String key : ownerMap.keySet()) {
            TrendReport__c trend = new TrendReport__c();
            List<Case> ticketList = new List<Case>();

            if (ownerNameTrendMap.get(key) != null) {
                trend = ownerNameTrendMap.get(key);
            } else {
                trend.Name = key.replace('!', ' ');
                trend.Year__c = key.split('!')[0];
                trend.OwnerName__c = key.split('!')[1];
                trend.Type__c = '상담원 별 접수';
            }

            if (ownerMap.get(key) != null) {
                ticketList = ownerMap.get(key);
            }

            for (Case ticket : ticketList) {
                switch on ticket.ApplicationDateTime__c.format('MM') {
                    when '01' {
                        trend.Month1__c = trend.Month1__c == null ? 1 : trend.Month1__c + 1;
                    }
                    when '02' {
                        trend.Month2__c = trend.Month2__c == null ? 1 : trend.Month2__c + 1;
                    }
                    when '03' {
                        trend.Month3__c = trend.Month3__c == null ? 1 : trend.Month3__c + 1;
                    }
                    when '04' {
                        trend.Month4__c = trend.Month4__c == null ? 1 : trend.Month4__c + 1;
                    }
                    when '05' {
                        trend.Month5__c = trend.Month5__c == null ? 1 : trend.Month5__c + 1;
                    }
                    when '06' {
                        trend.Month6__c = trend.Month6__c == null ? 1 : trend.Month6__c + 1;
                    }
                    when '07' {
                        trend.Month7__c = trend.Month7__c == null ? 1 : trend.Month7__c + 1;
                    }
                    when '08' {
                        trend.Month8__c = trend.Month8__c == null ? 1 : trend.Month8__c + 1;
                    }
                    when '09' {
                        trend.Month9__c = trend.Month9__c == null ? 1 : trend.Month9__c + 1;
                    }
                    when '10' {
                        trend.Month10__c = trend.Month10__c == null ? 1 : trend.Month10__c + 1;
                    }
                    when '11' {
                        trend.Month11__c = trend.Month11__c == null ? 1 : trend.Month11__c + 1;
                    }
                    when '12' {
                        trend.Month12__c = trend.Month12__c == null ? 1 : trend.Month12__c + 1;
                    }
                }
            }
            upsertList.add(trend);
        }

        // 지사 별 접수 로직
        for (String key : workcenterMap.keySet()) {
            TrendReport__c trend = new TrendReport__c();
            List<WorkOrder> orderList = new List<WorkOrder>();

            if (workcenterTrendMap.get(key) != null) {
                trend = workcenterTrendMap.get(key);
            } else {
                trend.Name = key.replace('!', ' ');
                trend.Year__c = key.split('!')[0];
                trend.TopWorkCenter__c = key.split('!')[1];
                trend.WorkCenter__c = key.split('!')[2];
                trend.Type__c = '지사 별 접수';
            }

            if (workcenterMap.get(key) != null) {
                orderList = workcenterMap.get(key);
            }

            trend.WorkCenterCode__c = trend.WorkCenterCode__c == null ? orderList[0].ServiceTerritory.WCID__c : trend.WorkCenterCode__c;

            for (WorkOrder order : orderList) {
                switch on order.CreatedDate.format('MM') {
                    when '01' {
                        trend.Month1__c = trend.Month1__c == null ? 1 : trend.Month1__c + 1;
                    }
                    when '02' {
                        trend.Month2__c = trend.Month2__c == null ? 1 : trend.Month2__c + 1;
                    }
                    when '03' {
                        trend.Month3__c = trend.Month3__c == null ? 1 : trend.Month3__c + 1;
                    }
                    when '04' {
                        trend.Month4__c = trend.Month4__c == null ? 1 : trend.Month4__c + 1;
                    }
                    when '05' {
                        trend.Month5__c = trend.Month5__c == null ? 1 : trend.Month5__c + 1;
                    }
                    when '06' {
                        trend.Month6__c = trend.Month6__c == null ? 1 : trend.Month6__c + 1;
                    }
                    when '07' {
                        trend.Month7__c = trend.Month7__c == null ? 1 : trend.Month7__c + 1;
                    }
                    when '08' {
                        trend.Month8__c = trend.Month8__c == null ? 1 : trend.Month8__c + 1;
                    }
                    when '09' {
                        trend.Month9__c = trend.Month9__c == null ? 1 : trend.Month9__c + 1;
                    }
                    when '10' {
                        trend.Month10__c = trend.Month10__c == null ? 1 : trend.Month10__c + 1;
                    }
                    when '11' {
                        trend.Month11__c = trend.Month11__c == null ? 1 : trend.Month11__c + 1;
                    }
                    when '12' {
                        trend.Month12__c = trend.Month12__c == null ? 1 : trend.Month12__c + 1;
                    }
                }
            }
            upsertList.add(trend);
        }

        // 콜서비스 월별 통계 로직
        for (String key : callServiceMap.keySet()) {
            TrendReport__c trend = new TrendReport__c();
            List<Case> ticketList = new List<Case>();

            if (callServiceTrendMap.get(key) != null) {
                trend = callServiceTrendMap.get(key);
            } else {
                trend.Name = key.replace('!', ' ');
                trend.Year__c = key.split('!')[0];
                trend.OwnerName__c = key.split('!')[1].replace(' Call Service', '');
                trend.Type__c = '월 별 콜 접수';
            }

            if (callServiceMap.get(key) != null) {
                ticketList = callServiceMap.get(key);
            }

            for (Case ticket : ticketList) {
                switch on ticket.ApplicationDateTime__c.format('MM') {
                    when '01' {
                        trend.Month1__c = trend.Month1__c == null ? 1 : trend.Month1__c + 1;
                    }
                    when '02' {
                        trend.Month2__c = trend.Month2__c == null ? 1 : trend.Month2__c + 1;
                    }
                    when '03' {
                        trend.Month3__c = trend.Month3__c == null ? 1 : trend.Month3__c + 1;
                    }
                    when '04' {
                        trend.Month4__c = trend.Month4__c == null ? 1 : trend.Month4__c + 1;
                    }
                    when '05' {
                        trend.Month5__c = trend.Month5__c == null ? 1 : trend.Month5__c + 1;
                    }
                    when '06' {
                        trend.Month6__c = trend.Month6__c == null ? 1 : trend.Month6__c + 1;
                    }
                    when '07' {
                        trend.Month7__c = trend.Month7__c == null ? 1 : trend.Month7__c + 1;
                    }
                    when '08' {
                        trend.Month8__c = trend.Month8__c == null ? 1 : trend.Month8__c + 1;
                    }
                    when '09' {
                        trend.Month9__c = trend.Month9__c == null ? 1 : trend.Month9__c + 1;
                    }
                    when '10' {
                        trend.Month10__c = trend.Month10__c == null ? 1 : trend.Month10__c + 1;
                    }
                    when '11' {
                        trend.Month11__c = trend.Month11__c == null ? 1 : trend.Month11__c + 1;
                    }
                    when '12' {
                        trend.Month12__c = trend.Month12__c == null ? 1 : trend.Month12__c + 1;
                    }
                }
            }
            upsertList.add(trend);
        }

        // 월별 오더 통계 로직
        for (String key : orderMap.keySet()) {
            TrendReport__c trend = new TrendReport__c();
            List<WorkOrder> orderList = new List<WorkOrder>();

            if (orderTrendMap.get(key) != null) {
                trend = orderTrendMap.get(key);
            } else {
                trend.Name = key;
                trend.Year__c = key.split(' ')[0];
                trend.Type__c = '월 별 오더';
            }

            if (orderMap.get(key) != null) {
                orderList = orderMap.get(key);
            }

            for (WorkOrder order : orderList) {
                switch on order.CreatedDate.format('MM') {
                    when '01' {
                        trend.Month1__c = trend.Month1__c == null ? 1 : trend.Month1__c + 1;
                    }
                    when '02' {
                        trend.Month2__c = trend.Month2__c == null ? 1 : trend.Month2__c + 1;
                    }
                    when '03' {
                        trend.Month3__c = trend.Month3__c == null ? 1 : trend.Month3__c + 1;
                    }
                    when '04' {
                        trend.Month4__c = trend.Month4__c == null ? 1 : trend.Month4__c + 1;
                    }
                    when '05' {
                        trend.Month5__c = trend.Month5__c == null ? 1 : trend.Month5__c + 1;
                    }
                    when '06' {
                        trend.Month6__c = trend.Month6__c == null ? 1 : trend.Month6__c + 1;
                    }
                    when '07' {
                        trend.Month7__c = trend.Month7__c == null ? 1 : trend.Month7__c + 1;
                    }
                    when '08' {
                        trend.Month8__c = trend.Month8__c == null ? 1 : trend.Month8__c + 1;
                    }
                    when '09' {
                        trend.Month9__c = trend.Month9__c == null ? 1 : trend.Month9__c + 1;
                    }
                    when '10' {
                        trend.Month10__c = trend.Month10__c == null ? 1 : trend.Month10__c + 1;
                    }
                    when '11' {
                        trend.Month11__c = trend.Month11__c == null ? 1 : trend.Month11__c + 1;
                    }
                    when '12' {
                        trend.Month12__c = trend.Month12__c == null ? 1 : trend.Month12__c + 1;
                    }
                }
            }
            upsertList.add(trend);
        }

        upsert upsertList;
    }

    public void finish(Database.BatchableContext context){
        System.debug('Batch 끝');
    }

    public void execute(SchedulableContext sc) {
        DN_TrendReportBatch batch = new DN_TrendReportBatch();
        Database.executeBatch(batch);
    }

}