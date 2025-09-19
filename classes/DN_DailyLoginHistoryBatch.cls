/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-06-2024
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-06-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class DN_DailyLoginHistoryBatch implements Database.Batchable<ServiceResource>, Database.Stateful, Database.AllowsCallouts, Schedulable{

    public List<ServiceResource> start(Database.BatchableContext context){
        return [SELECT Id, RelatedRecordId, Service_Territory__c  FROM ServiceResource WHERE IsActive = True AND Service_Territory__r.classify__c  = 'W/C'];
    }

    public void execute(Database.BatchableContext context, List<ServiceResource> scope) {
        System.debug(' =============== Batch Execute ================');
        System.debug('scope.Size() : ' + scope.size());
        System.debug('scope : ' + scope);
        Savepoint sp; 
        try{
            List<LoginHistory__c> insertLoginHistoryList = new List<LoginHistory__c>();
            Map<ID, LoginHistory__c> insertLoginHistoryMap = new Map<ID, LoginHistory__c>();
            
            Map<ID,ID> resourceMap 	= new Map<ID,ID>();
            SET<ID> resourceIDS 	= new SET<ID>();
            SET<ID> stIDS 			= new SET<ID>();
            for(ServiceResource obj : scope){
                resourceIDS.add(obj.RelatedRecordId);
                resourceMap.put(obj.RelatedRecordId, obj.Service_Territory__c);
                stIDS.add(obj.Service_Territory__c);
            }
            
            // 휴일 체크
            List<Holiday> hdList = [SELECT ID FROM Holiday WHERE ActivityDate = Yesterday];
            
            // 초기 맵 설정
            for(ID ids : stIDS){
                Boolean isHolday = hdList.size() > 0; 
                insertLoginHistoryMap.put(ids, new LoginHistory__c(WorkCenterId__c = ids,
                                                                  WCEmpCount__c = 0,
                                                                  LoginCount__c = 0,
                                                                  isHolyDay__c = isHolday,
                                                                  WorkOrderCount__c = 0,
                                                                  SeriviceAppointmentCount__c = 0,
                                                                  ArrivalCount__c = 0,
                                                                  CompleteCount__c = 0,
                                                                  X2HourDispatchCount__c = 0,
                                                                  X24HourRepairedCount__c = 0,
                                                                  LoginDate__c = System.now().addDays(-1)));
            }
                
            // 로그인 수 집계
            AggregateResult[] lhList = [SELECT UserID, Count(ID) LoginCount FROM LoginHistory 
                                        WHERE LoginTime = Yesterday AND UserID IN : resourceIDS Group By UserId ];
            for(AggregateResult obj : lhList){
                
                ID uID = (ID)obj.get('UserID');
                ID territoryID = resourceMap.get(uID);
                LoginHistory__c oldHistory = insertLoginHistoryMap.get(territoryID);
                oldHistory.LoginCount__c +=  (Decimal)obj.get('LoginCount');
                insertLoginHistoryMap.put(territoryID, oldHistory);
            }
            
            // W/C 직원 수 집계
            for(ServiceResource obj : scope){
                ID territoryID = resourceMap.get(obj.RelatedRecordId);
                LoginHistory__c oldHistory 	= insertLoginHistoryMap.get(territoryID);
                oldHistory.WCEmpCount__c 	+= 1;
                insertLoginHistoryMap.put(territoryID, oldHistory);
            }
          	
            // 접수건수
            List<WorkOrder> receptionWOList = [SELECT ID, ServiceTerritoryId FROM WorkOrder WHERE CreatedDate = Yesterday ];
            for(WorkOrder obj : receptionWOList){
                LoginHistory__c oldHistory 	= insertLoginHistoryMap.get(obj.ServiceTerritoryId);
                if (oldHistory != null) {
                    oldHistory.WorkOrderCount__c += 1;
                    insertLoginHistoryMap.put(obj.ServiceTerritoryId, oldHistory);
                }
            }
            
            // 출동건수
            List<WorkOrder> saList = [SELECT ID, ServiceTerritoryId From WorkOrder WHERE CreatedDate = YesterDay AND Status != 'Assigned' AND Status != 'AssignedRefused'];
            for(WorkOrder obj : saList){
                LoginHistory__c oldHistory 	= insertLoginHistoryMap.get(obj.ServiceTerritoryId);
                if (oldHistory != null) {
                    oldHistory.SeriviceAppointmentCount__c 	+= 1;
                    insertLoginHistoryMap.put(obj.ServiceTerritoryId, oldHistory);
                }
            }
            
            // 도착건수
            List<WorkOrder> dpList = [SELECT ID, ServiceTerritoryId From WorkOrder WHERE CreatedDate = YesterDay AND Status != 'Assigned' AND Status != 'AssignedRefused' AND Status != 'Started'];
            for(WorkOrder obj : dpList){
                LoginHistory__c oldHistory 	= insertLoginHistoryMap.get(obj.ServiceTerritoryId);
                if (oldHistory != null) {
                    oldHistory.ArrivalCount__c 	+= 1;
                    insertLoginHistoryMap.put(obj.ServiceTerritoryId, oldHistory);
                }
            }
            
            // 완료건수
            List<WorkOrder> cpList = [SELECT ID, ServiceTerritoryId From WorkOrder WHERE CreatedDate = YesterDay AND (Status = 'Completed' OR Status = 'Confirm')];
            for(WorkOrder obj : cpList){
                LoginHistory__c oldHistory 	= insertLoginHistoryMap.get(obj.ServiceTerritoryId);
                if (oldHistory != null) {
                    oldHistory.CompleteCount__c 	+= 1;
                    insertLoginHistoryMap.put(obj.ServiceTerritoryId, oldHistory);
                }
            }
            
            // 2HR 출동 건수
            List<WorkOrder> x2HrList = [SELECT ID, ServiceTerritoryId, FM_RepairRequestDateTime__c, ActualDispatchTime__c From WorkOrder WHERE CreatedDate = YesterDay AND FM_RepairRequestDateTime__c != null AND ActualDispatchTime__c != null];
            for(WorkOrder obj : x2HrList){
                if(obj.FM_RepairRequestDateTime__c.day() == obj.ActualDispatchTime__c.day()){
                    Long xhr = (obj.FM_RepairRequestDateTime__c.getTime() - obj.ActualDispatchTime__c.getTime()) / 1000 / 60 / 60 / 24;
                    if(xhr > 2){
                        LoginHistory__c oldHistory 	= insertLoginHistoryMap.get(obj.ServiceTerritoryId);
                        if (oldHistory != null) {
                            oldHistory.X2HourDispatchCount__c 	+= 1;
                            insertLoginHistoryMap.put(obj.ServiceTerritoryId, oldHistory);
                        }
                    }
                }else{
                    LoginHistory__c oldHistory 	= insertLoginHistoryMap.get(obj.ServiceTerritoryId);
                    if (oldHistory != null) {
                        oldHistory.X2HourDispatchCount__c 	+= 1;
                        insertLoginHistoryMap.put(obj.ServiceTerritoryId, oldHistory);
                    }
                }
            }
            
            // 24HR 수리 건수
            List<WorkOrder> x24HrList = [SELECT ID, ServiceTerritoryId, FM_WorkCompletionTime__c, CreatedDate From WorkOrder WHERE CreatedDate = YesterDay AND FM_WorkCompletionTime__c != null];
            for(WorkOrder obj : x24HrList){
                if(obj.CreatedDate.addDays(1) > obj.FM_WorkCompletionTime__c){
                    LoginHistory__c oldHistory 	= insertLoginHistoryMap.get(obj.ServiceTerritoryId);
                    if (oldHistory != null) {
                    oldHistory.X24HourRepairedCount__c 	+= 1;
                    insertLoginHistoryMap.put(obj.ServiceTerritoryId, oldHistory);
                    }
                }
            }
            
            // Map To List 
            for(ID ids : insertLoginHistoryMap.keySet()){
                insertLoginHistoryList.add(insertLoginHistoryMap.get(ids));
            }
            if(insertLoginHistoryList.size() > 0 ) insert insertLoginHistoryList;            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
        }
    }

    public void finish(Database.BatchableContext context){
        System.debug('배치 실행 완료');
    }

    public void execute(SchedulableContext sc) {
        DN_DailyLoginHistoryBatch batch = new DN_DailyLoginHistoryBatch();
        Database.executeBatch(batch, 200);        
    }
}