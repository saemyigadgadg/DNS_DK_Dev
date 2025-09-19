/**
* @Class : CollaboratorTriggerHandler
*
* @Author : Hayeong, Min
* @Date : 2024. 06. 13.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-06-13 | Hayeong, Min   | 최초작성
*  2. | 2024-10-30 | Suheon, Ha     | 공동작업자 생성 시 노티
*
*/
public without sharing class CollaboratorTriggerHandler extends TriggerHandler{

    /**
     * @Description
     * 	- Collaborator Before Insert
     * @author Hayeong Min 
    **/ 
    public override void onBeforeInsert(List<sObject> news){
        if(isExecuting){
            List<Collaborator__c> collaboratorList = (List<Collaborator__c>) news;
            Set<Id> workOrderIds = new Set<Id>();
            for(Collaborator__c obj : collaboratorList){
                workOrderIds.add(obj.WorkOrder__c);
            }

            List<ServiceAppointment> saList = [SELECT Id, ServiceResource__c FROM ServiceAppointment WHERE ParentRecordId IN : workOrderIds];
            List<String> srArr = new List<String>();
            for(ServiceAppointment sa : saList){
                srArr.add(sa.ServiceResource__c);
            }
            
            for(Collaborator__c obj : collaboratorList){
                if(srArr.contains(obj.ServiceResource__c)){
                    obj.addError(System.Label.DNS_M_AlreadyAssignedResource);
                }
            }
        }
    }

    /**
     * @Description
     * 	- Collaborator After Insert
     * @author Hayeong Min 
    **/ 
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting){
            List<Collaborator__c> collaboratorList = (List<Collaborator__c>) news;
            Set<Id> collabolatorIds = new Set<Id>();
            for(Collaborator__c obj : collaboratorList){
                collabolatorIds.add(obj.Id);
            }
            Map<Id, Collaborator__c> collaboratorNewMap = (Map<Id, Collaborator__c>) newMap;

            // Service Appointment 생성 시, WorkOrderResult 자동 생성
            List<WorkOrderResult__c> worList = new List<WorkOrderResult__c>();
            
            Set<Id> serviceResourceIds = new Set<Id>();
            Set<Id> workOrderIds = new Set<Id>();
            
            for (Collaborator__c collaborator : collaboratorList) {
                // WorkOrderResult 생성
                WorkOrderResult__c wor = new WorkOrderResult__c();
                wor.ServiceAppointment__c = collaborator.Id;
                worList.add(wor);

                if (collaborator.ServiceResource__c != null) {
                    serviceResourceIds.add(collaborator.ServiceResource__c);
                }
                if (collaborator.WorkOrder__c != null) {
                    workOrderIds.add(collaborator.WorkOrder__c);
                }
            }
    
            Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>();
            for (ServiceResource sr : [SELECT Id, Name, RelatedRecordId, RelatedRecord.Name, Service_Territory__c FROM ServiceResource WHERE Id IN :serviceResourceIds]) {
                srMap.put(sr.Id, sr);
            }
    
            Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(
                [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id IN :workOrderIds]
            );
    
            List<ServiceAppointment> saList = new List<ServiceAppointment>();
            List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();
    
            String alertManagerID = [
                SELECT Id FROM AlertManager__c WHERE Name = 'CS Sub Worker Create Noti' LIMIT 1
            ].Id;

            //상위 work order의 메인작업자의 ServiceAppointment에서 start/end 정보 가져와서 공동작업자에게 동일하게 배정하기
            List<ServiceAppointment> mainSaList = [SELECT Id, ParentRecordId, DueDate, SchedStartTime, SchedEndTime, RepairRequestDateTime__c FROM ServiceAppointment 
                                                    WHERE WorkerType__c = 'Service Resource (Main)' 
                                                    AND ParentRecordId IN : workOrderIds
                                                    ORDER BY CreatedDate DESC];
            Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>();
            if(mainSaList.size()>0){
                for(ServiceAppointment sa : mainSaList){
                    if(!saMap.containsKey(sa.ParentRecordId)){
                        saMap.put(sa.ParentRecordId, sa);
                    }
                }
            }
            
            for (Collaborator__c obj : collaboratorList) {
                ServiceAppointment sa = new ServiceAppointment();
                sa.ParentRecordId = collaboratorNewMap.get(obj.Id).WorkOrder__c;
                sa.ServiceResource__c = obj.ServiceResource__c;
                sa.ServiceTerritoryId = srMap.get(obj.ServiceResource__c).Service_Territory__c;
                sa.Collaborator__c = obj.Id;
                sa.Status = 'Assigned';
                sa.WorkerType__c = 'Service Resource (Sub)';
                sa.SchedStartTime = saMap.containsKey(obj.WorkOrder__c) ? saMap.get(obj.WorkOrder__c).SchedStartTime : System.now();
                sa.SchedEndTime = saMap.containsKey(obj.WorkOrder__c) ? saMap.get(obj.WorkOrder__c).SchedEndTime : System.now().addHours(4);
                sa.RepairRequestDateTime__c = saMap.containsKey(obj.WorkOrder__c) ? saMap.get(obj.WorkOrder__c).RepairRequestDateTime__c : System.now().addHours(1);

                saList.add(sa);
            }
            
            List<Collaborator__c> colList = [
                SELECT Id, ServiceResource__c, ServiceResource__r.RelatedRecordId, WorkOrder__c, 
                       WorkOrder__r.ServiceOrderNumber__c, WorkOrder__r.Account.Name, 
                       WorkOrder__r.Asset.Name, WorkOrder__r.Asset.MachineName__c
                FROM Collaborator__c 
                WHERE ID IN :collabolatorIds
            ];
            for (Collaborator__c obj : colList) {
                Id relatedUserId = srMap.get(obj.ServiceResource__c).RelatedRecordId;
                WorkOrder wo = woMap.get(obj.WorkOrder__c);
                UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
                hw.alertID = alertManagerID;
                hw.targetID = collaboratorNewMap.get(obj.Id).WorkOrder__c;
                hw.alertType = 'Notification';
                hw.alertLanguage = 'ko';
                hw.title = '공동작업자로 배정되었습니다.';
                String element = 
                    (obj.WorkOrder__r.ServiceOrderNumber__c != null ? obj.WorkOrder__r.ServiceOrderNumber__c : '') + ' / ' +
                    (obj.WorkOrder__r.Account != null ? obj.WorkOrder__r.Account.Name : '') + ' / ' +
                    (obj.WorkOrder__r.Asset != null ? obj.WorkOrder__r.Asset.Name : '') + ' / ' +
                    (obj.WorkOrder__r.Asset != null ? obj.WorkOrder__r.Asset.MachineName__c : '');
                hw.elementList = new List<String>{ element };    
                hw.receiverforID = new Set<Id>{relatedUserId};
                hwList.add(hw);
            }

            UTIL_Alert.runAlertEvent(hwList);
            insert saList;
        }
    }
    

    /**
     * @Description
     * 	- Collaborator Before Update
     * @author Hayeong Min 
    **/ 
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        System.debug('CollaboratorTriggerHandler.onBeforeUpdate');
        if(isExecuting) {
            List<Collaborator__c> collaboratorList = (List<Collaborator__c>) news;
            Set<Id> collaboratorIds = new Set<Id>();
            Set<Id> workOrderIds = new Set<Id>();
            Map<String, String> srMap = new Map<String, String>();
            Map<String, String> stMap = new Map<String, String>();
            
            Map<Id, Collaborator__c> colMap = new Map<Id, Collaborator__c>();
            Map<Id, ServiceResourceWarpper> wo_colMap = new Map<Id, ServiceResourceWarpper>(); 
            for(Collaborator__c obj : collaboratorList){
                Collaborator__c oldObj = (Collaborator__c)oldMap.get(obj.Id);
                if((obj.ServiceResource__c != null) && (oldObj.ServiceResource__c != obj.ServiceResource__c)){
                    workOrderIds.add(obj.WorkOrder__c);
                    collaboratorIds.add(obj.Id);
                    
                    colMap.put(obj.Id, obj);
                    
                    ServiceResourceWarpper srwrapper = new ServiceResourceWarpper();
                    srwrapper.oldServiceResource = oldObj.ServiceResource__c;
                    srwrapper.newServiceResource = obj.ServiceResource__c;
                    wo_colMap.put(obj.WorkOrder__c, srwrapper);
                }
            }


            if(collaboratorIds.size() > 0){
                //WorkOrder의 Status == 'Confirm'인 경우 Update 불가
                Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([
                    SELECT Id, Status FROM WorkOrder WHERE ID IN : workOrderIds
                ]);

                //이미 등록된 공동작업자인 경우, 공동작업자 수정 불가
                List<ServiceAppointment> existList = [SELECT Id, ServiceResource__c FROM ServiceAppointment WHERE ParentRecordId IN : workOrderIds];
                Set<Id> srIds = new Set<Id>();
                if(existList.size()>0){
                    for(ServiceAppointment sa : existList){
                        srIds.add(sa.ServiceResource__c);
                    }
                }                
                
                Boolean hasError = false;
                for(Collaborator__c obj : collaboratorList){
                    //ERROR MESSAGE : 확정된 오더는 공동작업자를 변경/제거할 수 없습니다.
                    if(woMap.containsKey(obj.WorkOrder__c) && woMap.get(obj.WorkOrder__c).Status == 'Confirm'){
                        obj.addError(System.Label.DNS_E_CollaboratorCannotDelete);
                        hasError = true;
                    }

                    //ERROR MESSAGE : 이미 지정된 작업자 입니다.
                    if(srIds.contains(obj.ServiceResource__c)){
                        obj.addError(System.Label.DNS_M_AlreadyAssignedResource);
                        hasError = true;
                    }
                }

                //공동작업자 Service Resource 변경 시 연결된 Service Appointment
                List<ServiceAppointment> saList = [SELECT Id, ServiceResource__c, ServiceTerritoryId, Collaborator__c FROM ServiceAppointment WHERE Collaborator__c IN :collaboratorIds];
                if(saList.size()>0 && hasError == false){
                    for(ServiceAppointment sa : saList){
                        sa.ServiceTerritoryId = colMap.get(sa.Collaborator__c).FM_ServiceTerritoryId__c;
                        sa.ServiceResource__c = colMap.get(sa.Collaborator__c).ServiceResource__c;
                    }
                    update saList;
                }

                //공동작업자 Service Resource 변경 시 연결된 WorkOrderResult
                List<WorkOrderResult__c> wrList = [SELECT Id, ServiceResource__c, WorkOrder__c FROM WorkOrderResult__c WHERE WorkOrder__c IN : workOrderIds];
                if(wrList.size()>0){
                    for(WorkOrderResult__c wr : wrList){
                        if(wo_colMap.containsKey(wr.WorkOrder__c) && wr.ServiceResource__c == wo_colMap.get(wr.WorkOrder__c).oldServiceResource){
                            wr.ServiceResource__c = wo_colMap.get(wr.WorkOrder__c).newServiceResource;
                        }
                    }
                    update wrList;
                }
            }
        }
    }

    /**
     * @Description
     * 	- Collaborator Before Delete
     * @author Hayeong Min 
    **/ 
    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
        List<Collaborator__c> collaboratorList = (List<Collaborator__c>) dels;
        Set<Id> collabolatorIds = new Set<Id>();
        Set<Id> woIds = new Set<Id>();
        Set<Id> srIds = new Set<Id>();
        Boolean hasError = false;
        for(Collaborator__c obj : collaboratorList){
            if(obj.FM_OrderStatus__c == 'Confirm'){
                obj.addError(System.Label.DNS_E_CollaboratorCannotDelete);
                hasError = true;
            }

            if(String.isNotEmpty(obj.ServiceResource__c)){
                srIds.add(obj.ServiceResource__c);
            }

            collabolatorIds.add(obj.Id);
            woIds.add(obj.WorkOrder__c);
        }

        List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();
        //공동작업자 제거시 관련 Service Appointment Delete
        if(collabolatorIds.size()>0 && hasError == false){
            List<ServiceAppointment> saList = [SELECT ID FROM ServiceAppointment WHERE Collaborator__c IN : collabolatorIds];
            List<WorkOrderResult__c> wrList = [SELECT ID FROM WorkOrderResult__c WHERE WorkOrder__c IN : woIds AND ServiceResource__c IN : srIds];
            String alertManagerID = [
                SELECT Id FROM AlertManager__c WHERE Name = 'WorkOrder Assignment Cancel Noti' LIMIT 1
            ].Id;

            List<Collaborator__c> colList = [
                SELECT Id, ServiceResource__c, ServiceResource__r.RelatedRecordId, WorkOrder__c, WorkOrder__r.ServiceOrderNumber__c, 
                WorkOrder__r.Account.Name, WorkOrder__r.Asset.Name, WorkOrder__r.Asset.MachineName__c, WorkOrder__r.Status
                FROM Collaborator__c 
                WHERE ID IN :collabolatorIds];

            
            for(Collaborator__c obj : colList){
                //ERROR MESSAGE : 확정된 오더는 공동작업자를 변경/제거할 수 없습니다.
                UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
                hw.alertID = alertManagerID;
                hw.targetID = obj.WorkOrder__c;
                hw.alertType = 'Notification';
                hw.alertLanguage = 'ko';
                String element = 
                    (obj.WorkOrder__r.ServiceOrderNumber__c != null ? obj.WorkOrder__r.ServiceOrderNumber__c : '') + ' / ' +
                    (obj.WorkOrder__r.Account != null ? obj.WorkOrder__r.Account.Name : '') + ' / ' +
                    (obj.WorkOrder__r.Asset != null ? obj.WorkOrder__r.Asset.Name : '') + ' / ' +
                    (obj.WorkOrder__r.Asset != null ? obj.WorkOrder__r.Asset.MachineName__c : '');
                hw.elementList = new List<String>{ element };               
                hw.receiverforID = new Set<Id>{obj.ServiceResource__r.RelatedRecordId};
                hwList.add(hw);
            }

            if(saList.size()>0) delete saList;
            if(wrList.size()>0) delete wrList;

            //공동작업자 제거시 상위 WorkOrder의 공동작업자 정보 Null로 변경
            if(woIds.size()>0){
                List<WorkOrder> woList = [SELECT ID, Collaborator__c FROM WorkOrder WHERE ID IN :woIds];
                for(WorkOrder wo : woList){
                    wo.Collaborator__c = null;
                }
                update woList;
            }

            if(hwList.size()>0) {
                UTIL_Alert.runAlertEvent(hwList);
            }

        }        
    }

    /*
     * @Description 
     *  - 변경 전/후 Service Resource Id Wrapper
     * 
     * @Variable 
     *  - oldServiceResource 	: 변경 전 ServiceResource Id 
     *  - newServiceResource 	: 변경 후 ServiceResource Id 
     */
    public class ServiceResourceWarpper {
        @AuraEnabled
        public String oldServiceResource		{get; set;}
        @AuraEnabled
        public String newServiceResource		    {get; set;}
        
        public ServiceResourceWarpper(){
            this.oldServiceResource 	            = '';
            this.newServiceResource 	                = '';
        }
    }    
}