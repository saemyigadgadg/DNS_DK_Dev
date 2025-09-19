/**
* @Class : ServiceResourcesTriggerHandler
*
* @Author : Junyeong, Choi
* @Date : 2024. 11. 08.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-11-08 | Junyeong, Choi   | 최초작성
*
*/
public with sharing class ServiceResourcesTriggerHandler extends TriggerHandler{
    /**
     * @Description
     * 	- ServiceResource After Insert
    **/ 
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting){
            List<ServiceResource> newSRList = (List<ServiceResource>) news;

            // ServiceResource 생성시 ServiceTerritoryMember 에도 추가 - 2024.12.06, Junyeong Choi
            List<ServiceTerritoryMember> newSTMList = new List<ServiceTerritoryMember>();
            for(ServiceResource sr : newSRList) {
                if(sr.Service_Territory__c != null) {
                    ServiceTerritoryMember stm = new ServiceTerritoryMember();
                    stm.ServiceTerritoryId = sr.Service_Territory__c;
                    stm.ServiceResourceId = sr.Id;
                    stm.EffectiveStartDate = Datetime.newInstance(2020, 1, 1, 0, 0, 0); 
                    stm.TerritoryType = 'P';
                    newSTMList.add(stm);
                }
            }
            if(!newSTMList.isEmpty()) {
                insert newSTMList;
            }

            // 가용인력 Count 추가 - 2024.12.06, Sangil Park
            Map<ID, Decimal> srCntMap = new Map<ID, Decimal>();
            for(ServiceResource sr : newSRList){
                if(srCntMap.get(sr.Service_Territory__c) == null){
                    srCntMap.put(sr.Service_Territory__c, 0);
                }else{
                    srCntMap.put(sr.Service_Territory__c, srCntMap.get(sr.Service_Territory__c) + 1);
                }
            }
            
            List<ServiceTerritory> srtList = [SELECT ID, AvailableServiceResource__c FROM ServiceTerritory WHERE ID IN: srCntMap.keySet()];
            for(ServiceTerritory obj : srtList){
                obj.AvailableServiceResource__c += srCntMap.get(obj.ID);
            }
            update srtList;

            // ServiceResource 생성시 User정보에 WorkcenterId를 Text로 업데이트 (2025-03-20 서영덕 추가)
            Map<String, String> userWorkcenterMap = new Map<String, String>();
            for(ServiceResource sr : newSRList){
                if (sr.Service_Territory__c != null) {
                    userWorkcenterMap.put(sr.RelatedRecordId, sr.Service_Territory__c);
                }
            }
            if (userWorkcenterMap.keySet().size() > 0) {
                List<User> userList = [SELECT Id FROM User WHERE Id IN :userWorkcenterMap.keySet()];
                List<User> updateUserList = new List<User>();
                for (User user : userList) {
                    user.ResourceWorkCenterID__c = userWorkcenterMap.get(user.Id);
                    updateUserList.add(user);
                }
    
                if (updateUserList.size() > 0) update updateUserList;
            }

            // 지사별 클레임 미결현황 플랫폼 이벤트 (서영덕)
            StatusBoardEvent__e event = new StatusBoardEvent__e();
            event.ServiceResourceId__c = newSRList[0].Id;
            Database.SaveResult sr = EventBus.publish(event);
            System.debug('sr ::: ' + sr);
            if(sr.isSuccess()) {
                System.debug('Success');
            }
        }
    }

    /**
     * @Description
     * 	- ServiceResource After Update
     *  1. Service Resource 수정시 Service Territory Member 도 업데이트
    **/ 
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting) {
            List<ServiceResource> oldSRList = (List<ServiceResource>) olds;
            List<ServiceResource> newSRList = (List<ServiceResource>) news;
            System.debug('newSRList ::: ' + newSRList);
            Map<Id, ServiceResource> oldServiceResourceMap = (Map<Id, ServiceResource>) oldMap;
            Map<Id, ServiceResource> newServiceResourceMap = (Map<Id, ServiceResource>) newMap;
    
            Map<Id, Id> serviceResourceToTerritoryMap = new Map<Id, Id>();
            Set<Id> serviceResourceToDelete = new Set<Id>();
    
            for(ServiceResource newSR : newSRList) {
                ServiceResource oldSR = (ServiceResource) oldMap.get(newSR.Id);
                System.debug('oldSR ::: ' + oldSR);
                
                if(newSR.Service_Territory__c != oldSR.Service_Territory__c) {
                    if(newSR.IsActive){ // Service Resource 가 무조건 Active 인것만 ServiceTerritoryMember 에 넣을 수 있다. // Config 자체가 막힘
                        if(newSR.Service_Territory__c == null) {
                            serviceResourceToDelete.add(newSR.Id);
                        } else {
                            System.debug('Service_Territory__c ::: ' + newSR.Service_Territory__c);
                            serviceResourceToTerritoryMap.put(newSR.Id, newSR.Service_Territory__c);
                        }
                    }
                }
            }
    
            if(!serviceResourceToDelete.isEmpty() || !serviceResourceToTerritoryMap.isEmpty()) {
                List<ServiceTerritoryMember> stmToDelete = [
                    SELECT Id, ServiceResourceId 
                    FROM ServiceTerritoryMember 
                    WHERE ServiceResourceId IN :serviceResourceToDelete
                    OR ServiceResourceId IN :serviceResourceToTerritoryMap.keySet()
                ];
    
                List<ServiceTerritoryMember> stmToInsert = new List<ServiceTerritoryMember>();
                for(Id srId : serviceResourceToTerritoryMap.keySet()) {
                    Id newTerritoryId = serviceResourceToTerritoryMap.get(srId);
                    ServiceTerritoryMember newStm = new ServiceTerritoryMember();
                    newStm.ServiceTerritoryId = newTerritoryId;
                    newStm.ServiceResourceId = srId;
                    newStm.EffectiveStartDate = Datetime.newInstance(2020, 1, 1, 0, 0, 0);
                    newStm.TerritoryType = 'P';
                    stmToInsert.add(newStm);
                }
    
                if(!stmToDelete.isEmpty()) {
                    delete stmToDelete; // ServiceTerritotyMember 는 읽기전용(업데이트 x), 지웠다가 다시 생성해야함.
                }
                if(!stmToInsert.isEmpty()) {
                    insert stmToInsert; // Work Center(Service Territoty 가 InActive 이면 Insert 가 되질 않는다)
                }
            }
            
            
            // 가용인력 Count 추가 - 2024.12.06, Sangil Park
            // List<ServiceResource> oldSRList = (List<ServiceResource>) olds;
            // List<ServiceResource> newSRList = (List<ServiceResource>) news;
            // Map<Id, ServiceResource> oldServiceResourceMap = (Map<Id, ServiceResource>) oldMap;
            // Map<Id, ServiceResource> newServiceResourceMap = (Map<Id, ServiceResource>) newMap;
            Map<ID, Decimal> srCntMap = new Map<ID, Decimal>();
            for(ServiceResource sr : newSRList){
                ServiceResource oldSR = oldServiceResourceMap.get(sr.ID);
                // 서비스 요원의 Territory가 변경되었을때
                if(sr.Service_Territory__c != oldSR.Service_Territory__c && sr.IsActive){
                    if(srCntMap.get(sr.Service_Territory__c ) == null) srCntMap.put(sr.Service_Territory__c, 1) ;
                    else srCntMap.put(sr.Service_Territory__c, srCntMap.get(sr.Service_Territory__c) + 1);
                    
                    if(srCntMap.get(oldSR.Service_Territory__c)== null) srCntMap.put(oldSR.Service_Territory__c, -1) ;
                    else srCntMap.put(oldSR.Service_Territory__c, srCntMap.get(oldSR.Service_Territory__c) - 1);
                }// 서비스 요원 Active 상태 변경
                else if(sr.IsActive != oldSR.IsActive){
                    if(sr.IsActive){
                        if(srCntMap.get(sr.Service_Territory__c ) == null) srCntMap.put(sr.Service_Territory__c, 1) ;
                        else srCntMap.put(sr.Service_Territory__c, srCntMap.get(sr.Service_Territory__c) + 1);
                    }else{
                        if(srCntMap.get(sr.Service_Territory__c ) == null) srCntMap.put(sr.Service_Territory__c, -1) ;
                        else srCntMap.put(sr.Service_Territory__c, srCntMap.get(sr.Service_Territory__c) -1);
                    }
                }
            }
            
            
            List<ServiceTerritory> srtList = [SELECT ID, AvailableServiceResource__c FROM ServiceTerritory WHERE ID IN: srCntMap.keySet()];
            for(ServiceTerritory obj : srtList){
                obj.AvailableServiceResource__c += srCntMap.get(obj.ID);
            }
            update srtList;
            
            for (ServiceResource newSr : newSRList) {
                ServiceResource oldSr = (ServiceResource) oldMap.get(newSr.Id);

                if (newSr.CurrentStatus__c != oldSr.CurrentStatus__c) {
                    // 지사별 클레임 미결현황 플랫폼 이벤트 (서영덕)
                    StatusBoardEvent__e event = new StatusBoardEvent__e();
                    event.ServiceResourceId__c = newSRList[0].Id;
                    Database.SaveResult sr = EventBus.publish(event);
                    System.debug('sr ::: ' + sr);
                    if(sr.isSuccess()) {
                        System.debug('Success');
                    }
                }
            }

            // ServiceResource Workcenter 변경 업데이트시 User정보에 WorkcenterId를 Text로 업데이트 (2025-03-20 서영덕 추가)
            Map<String, String> userWorkcenterMap = new Map<String, String>();
            for(ServiceResource sr : newSRList){
                ServiceResource oldSr = (ServiceResource) oldMap.get(sr.Id);
                if (sr.Service_Territory__c != oldSr.Service_Territory__c) {
                    userWorkcenterMap.put(sr.RelatedRecordId, sr.Service_Territory__c);
                }
            }
            if (userWorkcenterMap.keySet().size() > 0) {
                List<User> userList = [SELECT Id FROM User WHERE Id IN :userWorkcenterMap.keySet()];
                List<User> updateUserList = new List<User>();
                for (User user : userList) {
                    user.ResourceWorkCenterID__c = userWorkcenterMap.get(user.Id);
                    updateUserList.add(user);
                }
    
                if (updateUserList.size() > 0) update updateUserList;
            }
        }

    }

    public override void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap){

        // 지사별 클레임 미결현황 플랫폼 이벤트 (서영덕)
        StatusBoardEvent__e event = new StatusBoardEvent__e();
        Database.SaveResult sr = EventBus.publish(event);
        System.debug('sr ::: ' + sr);
        if(sr.isSuccess()) {
            System.debug('Success');
        }

    }

    /*
     * @Description
     * 		- 공용Wrapper
     * 
     * @Variable
     *  	- isSuccess 			: 성공여부
     *  	- errMessage 			: 실패시 에러메세지
     * 		- returnValue 			: 성공시 Return 값 
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		{get; set;}
        @AuraEnabled
        public String errMessage		{get; set;} 
        @AuraEnabled
        public String returnValue		{get; set;}

        
        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
            this.returnValue 	= '';
        }
    }
}