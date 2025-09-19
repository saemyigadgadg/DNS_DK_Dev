/**
* @Class : ServiceAppointmentTriggerHandler
*
* @Author : Hayeong, Min
* @Date : 2024. 06. 14.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-06-14 | Hayeong, Min   | 최초작성
*  2. | 2024-09-25 | Suheon, Ha     | WorkerType__c변경시 Noti 발송
*  2. | 2024-10-21 | Suheon, Ha     | 
*  3. | 2024-11-15 | Junyeong, Choi | ServiceAppointment 의 ParentRecordId => WorkOrder__c 에도 Update
*/
public without sharing class ServiceAppointmentTriggerHandler extends TriggerHandler{
    
    /**
     * @Description
     * 	- ServiceAppointment Before Insert
     * @author Hayeong Min 
    **/ 
    public override void onBeforeInsert(List<sObject> news) {
        if (isExecuting) {
            System.debug('ServiceAppointmentTriggerHandler onBeforeInsert');
            List<ServiceAppointment> srList = (List<ServiceAppointment>) news;
            Set<Id> woIds = new Set<Id>();
            Set<Id> resourceIds = new Set<Id>();
            String dnsaRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ServiceAppointment_DNSA').getRecordTypeId();
            for(ServiceAppointment obj : srList){
                if(String.isNotEmpty(obj.ParentRecordId)) {
                    obj.WorkOrder__c = obj.ParentRecordId;
                    woIds.add(obj.ParentRecordId);
                }
                if(String.isNotEmpty(obj.ServiceResource__c)){
                    obj.Status = 'Assigned';
                    resourceIds.add(obj.ServiceResource__c);
                }
            }
            System.debug('woIds ::: '+woIds);
            // suheon.ha 2025-05-20
            if (!woIds.isEmpty()) {
                Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(
                    [SELECT Id, Status FROM WorkOrder WHERE Id IN :woIds]
                );

                for (ServiceAppointment sa : srList) {
                    if (sa.isPortal__c == true && sa.WorkOrder__c != null) {
                        WorkOrder wo = woMap.get(sa.WorkOrder__c);
                        if (wo.Status == 'Uncompleted') {
                            sa.Status = 'Uncompleted';
                        } else {
                            sa.Status = 'Completed';
                        }
                    }
                }
            }
            
            //상위 work order의 ContactID를 service Appointment에서도 넣기 (+ 2025-02-06 (DNSA)서영덕 추가 Work Order의 Account의 주소넣기)
            // 20250226수정
            if(!woIds.isEmpty()){
                List<WorkOrder> woList = [SELECT Id, ContactId, AccountId, HasWarrantyDirectManagement__c, FM_ApplicationDateTime__c, ScheduledDispatchTime__c FROM WorkOrder WHERE Id IN :woIds];
                Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();
                Set<Id> accIds = new Set<Id>();
                Set<Id> caseIds = new Set<Id>();
                for(WorkOrder wo : woList){
                    woMap.put(wo.Id, wo);
                    accIds.add(wo.AccountId);
                }

                Map<Id, Account> accMap = new Map<Id, Account>();
                List<Account> accList = [SELECT Id, ShippingCountry, ShippingState, ShippingCity, ShippingStreet, ShippingPostalCode FROM Account WHERE Id IN :accIds];
                System.debug('accList ::: '+accList);
                for(Account acc : accList){
                    accMap.put(acc.Id, acc);
                }

                for(ServiceAppointment obj : srList){
                    DateTime applicationDT = System.today();
                    if(woMap.get(obj.ParentRecordId).FM_ApplicationDateTime__c != null){
                        applicationDT = woMap.get(obj.ParentRecordId).FM_ApplicationDateTime__c;
                    }else{
                        //출동요청일시
                        applicationDT = woMap.get(obj.ParentRecordId).ScheduledDispatchTime__c;
                    }
                    obj.EarliestStartTime = applicationDT;
                    obj.DueDate = applicationDT == null ? null : applicationDT.addDays(14);

                    if(String.isNotEmpty(obj.ParentRecordId) && woMap.containsKey(obj.ParentRecordId)) {
                        obj.ContactId = woMap.get(obj.ParentRecordId).ContactId;

                        obj.Duration = 4;
                        if (obj.RecordTypeId == dnsaRecordTypeId) {
                            String tmpAccId = woMap.get(obj.ParentRecordId).AccountId;
                            if (accMap.containsKey(tmpAccId)) {
                                Account acc = accMap.get(tmpAccId);
                                obj.city = acc.ShippingCity;
                                obj.country = acc.ShippingCountry;
                                obj.state = acc.ShippingState;
                                obj.street = acc.ShippingStreet;
                                obj.postalCode = acc.ShippingPostalCode;
                                // obj.Duration = 4;
                                System.debug('acc::'+acc);
                            }
                        }
                    }
                }
            }

            //작업자 정보 있는 Service Appointment인 경우 작업자를 owner로 설정
            if(!resourceIds.isEmpty()){
                List<ServiceResource> resourceList = [SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id IN :resourceIds];
                System.debug('resourceList :: '+resourceList);
                Map<Id, Id> resourceMap = new Map<Id, Id>();
                for(ServiceResource sr : resourceList){
                    resourceMap.put(sr.Id, sr.RelatedRecordId);
                }
                System.debug('resourceMap :: '+resourceMap);
                for(ServiceAppointment obj : srList){
                    if(String.isNotEmpty(obj.ServiceResource__c)) {
                        obj.OwnerId = resourceMap.get(obj.ServiceResource__c);
                        System.debug('SA Owner ID ::: '+obj.OwnerId);
                    }
                }
            }else{
                System.debug('예로롱');
            }
            
        }
    }
    /**
     * @Description
     * 	- Work Order After Insert
     * @Created By | Hayeong Min
     * @Last Modified Date | 2024-08-09
    **/ 
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
        if (isExecuting) {
            System.debug('ServiceAppointmentTriggerHandler_onAfterInsert');
            List<ServiceAppointment> srList = (List<ServiceAppointment>) news;
    
            String dnsaRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ServiceAppointment_DNSA').getRecordTypeId();
            // Service Appointment 생성 시, WorkOrderResult 자동 생성
            List<WorkOrderResult__c> worList = new List<WorkOrderResult__c>();
            // Service Appointment 생성 시, AssignedResouce 자동 생성
            List<AssignedResource> arList = new List<AssignedResource>();
            Set<Id> parentWorkOrderIds = new Set<Id>();
            // 공동작업자용 Service Appointment 생성시 해당 공동작업자 user 상위 workOrder의 공동작업자 필드에 mapping
            Set<Id> subReourceIds = new Set<Id>();
            Map<Id, Id> collaboMap = new Map<Id,Id>();

            Map<Id, ServiceAppointment> dnsaSA = new Map<Id, ServiceAppointment>();
            Set<Id> dnsa_woIds = new Set<Id>();

            for (ServiceAppointment obj : srList) {
                if (obj.ParentRecordId != null) {
                    parentWorkOrderIds.add(obj.ParentRecordId);
                }
            }    

            Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([
                SELECT Id, OrderType__c, ContactId, AccountId, HasWarrantyDirectManagement__c, FM_ApplicationDateTime__c
                FROM WorkOrder 
                WHERE Id IN :parentWorkOrderIds
            ]);

            System.debug('woMap ::: '+woMap);
    
            for (ServiceAppointment obj : srList) {
                if (obj.ParentRecordId != null) {
                    WorkOrder wo = woMap.get(obj.ParentRecordId);
                    if (!wo.HasWarrantyDirectManagement__c && !obj.isPortal__c) {
                        // WorkOrderResult 생성
                        WorkOrderResult__c wor = new WorkOrderResult__c();
                        wor.ServiceAppointment__c = obj.Id;
                        wor.WorkType__c = (wo.OrderType__c == '104') ? null : 'MV';
                        wor.ResultType__c = 'WH';
                        wor.WorkOrder__c = obj.ParentRecordId;
                        wor.ServiceResource__c = obj.ServiceResource__c;
                        wor.Description__c = '고객사로 이동';
                        wor.WorkDate__c = obj.SchedStartTime.Date();
                        worList.add(wor);
                        System.debug('worList:::' + worList);
                    }
                }               
    
                System.debug('obj.ServiceResource__c ::: '+obj.ServiceResource__c);
                //작업자 정보가 있으면 AssignedResource 생성
                if(String.isNotEmpty(obj.ServiceResource__c)){
                    AssignedResource ar = new AssignedResource();
                    ar.ServiceAppointmentId = obj.Id;
                    ar.ServiceResourceId = obj.ServiceResource__c; // Service Appointment의 작업자 정보 입력
                    arList.add(ar);
                    System.debug('arList ::: ' + arList);
                    
                }

                //공동작업자인 경우, 상위 work order의 공동작업자 필드에 mapping하기
                if(obj.WorkerType__c == 'Service Resource (Sub)' && obj.ParentRecordId != null){
                    subReourceIds.add(obj.ParentRecordId);
                    collaboMap.put(obj.ServiceResource__c, obj.ParentRecordId);
                }

                if((obj.RecordTypeId == dnsaRecordTypeId) && (obj.ParentRecordId != null) && (String.isNotEmpty(obj.ServiceResource__c))){
                    dnsa_woIds.add(obj.ParentRecordId);
                }
                if (obj.RecordTypeId != dnsaRecordTypeId) {
                    // (딜러포탈)자체유상서비스리포트인(HasWarrantyDirectManagement__c=true) 경우 SKIP
                    if (!woMap.get(obj.ParentRecordId).HasWarrantyDirectManagement__c && obj.WorkerType__c == 'Service Resource (Main)' && !obj.isPortal__c) {
                        System.debug('알림톡 호출');
                        createSAAlarm(srList, new Map<Id, ServiceAppointment>());
                    }
                }
                
            }


            if(arList.size()>0){insert arList;}
            if(worList.size()>0){insert worList;}
            
            if(!dnsa_woIds.isEmpty()){
                CommonWrapper cw = dnsaOrderUpdate(dnsa_woIds);
            }

            if(subReourceIds.size()>0){//공동작업자가 등록된 Service Appointment의 workOrder ID
                List<ServiceResource> collaboList = [SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id IN : collaboMap.keySet()];
                Map<Id, Id> srMap = new Map<Id,Id>();
                for(ServiceResource sr : collaboList){
                    if(collaboMap.containsKey(sr.Id)){
                        srMap.put(collaboMap.get(sr.Id), sr.RelatedRecordId);
                    }
                }

                List<WorkOrder> woList = [SELECT ID, Collaborator__c FROM WorkOrder WHERE ID IN :subReourceIds];
                for(WorkOrder wo : woList){
                    if(srMap.containsKey(wo.Id)){
                       wo.Collaborator__c = srMap.get(wo.Id);
                    }
                }
                update woList;
            }
        }
    }
    

    /**
     * @Description
     * 	- Work Order Before Update
     * @Created By | Hayeong Min
     * @Last Modified Date | 2025-01-04
    **/ 
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('ServiceAppointmentTriggerHandler_onBeforeUpdate');
            List<ServiceAppointment> saList = (List<ServiceAppointment>) news;
            Set<Id> parentWorkOrderIds = new Set<Id>();
            Map<Id, Id> collaboMap = new Map<Id, Id>();
            
            Set<Id> srIds = new Set<Id>();
            Map<String, String> saMap = new Map<String, String>();
            String domestic_recId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ServiceAppointment').getRecordTypeId();


            for (ServiceAppointment sa : saList) {
                ServiceAppointment oldObj = (ServiceAppointment)oldMap.get(sa.Id);

                if(oldObj.Status != sa.Status && sa.Status == '발송됨' && sa.RecordTypeId == domestic_recId){
                    sa.addError('[발송됨] 상태로 변경할 수 없습니다.');
                }

                if (sa.ParentRecordId != null) {
                    parentWorkOrderIds.add(sa.ParentRecordId);
                }

                if((String.isNotEmpty(sa.ServiceResource__c)) && (sa.ServiceResource__c != oldObj.ServiceResource__c)){
                    sa.Status = 'Assigned';
                    saMap.put(sa.Id, sa.ServiceResource__c);
                    srIds.add(sa.ServiceResource__c);
                }
    
            }

            // ServiceResourceId 업데이트
            if(!saMap.isEmpty()){
                System.debug('saMap ::: '+saMap);
                List<ServiceResource> srList = [SELECT Id, RelatedRecordId, Service_Territory__c FROM ServiceResource WHERE ID IN : srIds];
                Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>();
                for(ServiceResource sr : srList){
                    srMap.put(sr.Id, sr);
                }   
                
                for (ServiceAppointment sa : saList) {
                    if (saMap.containsKey(sa.Id)) {
                        sa.OwnerId = srMap.get(sa.ServiceResource__c).RelatedRecordId;
                        sa.ServiceTerritoryId = srMap.get(sa.ServiceResource__c).Service_Territory__c;
                    }
                }
            }
    
            // WorkOrder의 ContactId 가져와서 ServiceAppointment에 설정
            if (!parentWorkOrderIds.isEmpty()) {
                Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(
                    [SELECT Id, ContactId FROM WorkOrder WHERE Id IN :parentWorkOrderIds]
                );
    
                List<ServiceAppointment> saUpdate = new List<ServiceAppointment>();
                for (ServiceAppointment sa : saList) {
                    ServiceAppointment oldSa = (ServiceAppointment) oldMap.get(sa.Id);
                    if (sa.ParentRecordId != null && woMap.containsKey(sa.ParentRecordId)) {
                        if (sa.ContactId != woMap.get(sa.ParentRecordId).ContactId) {
                            sa.ContactId = woMap.get(sa.ParentRecordId).ContactId;
                        }
                    }
                }
            }            

            
    
            // 2024.08.02 suheon.ha
            List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();
    
            Set<Id> srSet = new Set<Id>();
            for (ServiceAppointment obj : saList) {
                if (obj.ServiceResource__c != null) {
                    srSet.add(obj.ServiceResource__c);
                }
                
                if(String.isNotEmpty(obj.ParentRecordId)) obj.WorkOrder__c = obj.ParentRecordId;
            }
    
            Map<Id, String> srMap = new Map<Id, String>();
            List<ServiceResource> srList = [
                SELECT Id, Name 
                FROM ServiceResource 
                WHERE Id IN :srSet
            ];
    
            for (ServiceResource sr : srList) {
                srMap.put(sr.Id, sr.Name);
            }
    

            String subAlertManagerID = [
                SELECT Id FROM AlertManager__c WHERE Name = 'CS Worker Type Noti' LIMIT 1
            ].Id;
    
            // WorkOrder 데이터 미리 조회
            Set<Id> parentRecordIds = new Set<Id>();
            for (ServiceAppointment obj : saList) {
                if (obj.ParentRecordId != null) {
                    parentRecordIds.add(obj.ParentRecordId);
                }
            }
    
            Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(
                [SELECT Id, OrderType__c, Case.Requester__c, Case.InternalRequester__c, Case.CaseNumber, TimeAgreedOnSite__c
                FROM WorkOrder
                WHERE Id IN :parentRecordIds]
            );

            // 20250226수정
            Set<String> profileIds = new Set<String>();
            List<Profile> profileList = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', '시스템 관리자', 'DNSA CS Admin', 'DNS CS Admin')];
            for (Profile profile : profileList) {
                profileIds.add(profile.Id);
            }
    
            // WorkOrder 업데이트를 위한 리스트
            List<WorkOrder> woUpdate = new List<WorkOrder>();
    
            for (ServiceAppointment obj : saList) {
                ServiceAppointment oldObj = (ServiceAppointment) oldMap.get(obj.Id);
                if (oldObj.OnsiteDate__c == null && obj.OnsiteDate__c != null) {
                    if (obj.Status != 'ScheduledToDispatch') {
                        obj.Status = 'ScheduledToDispatch';
                    }
                }

                if (!profileIds.contains(UserInfo.getProfileId())) {
                    if (oldObj.Arrival__c != null && obj.Arrival__c != oldObj.Arrival__c) {
                        obj.addError('도착(Mobile)이 이미 설정되어 있어 수정할 수 없습니다.');
                    }
        
                    if (oldObj.Department__c != null && obj.Department__c != oldObj.Department__c) {
                        obj.addError('출발(Mobile)이 이미 설정되어 있어 수정할 수 없습니다.');
                    }
        
                    if (oldObj.WorkCompletionTime__c != null && obj.WorkCompletionTime__c != oldObj.WorkCompletionTime__c) {
                        obj.addError('작업완료시간(Mobile)이 이미 설정되어 있어 수정할 수 없습니다.');
                    }
                }
    
                // 2024.08.02 suheon.ha - 보조 작업자 노티 발생 조건
                if ((obj.WorkerType__c == 'Service Resource (Sub)') &&
                    obj.WorkerType__c != oldObj.WorkerType__c) {
                    
                    UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
                    hw.alertID = subAlertManagerID;
                    hw.targetID = obj.Id;
                    hw.alertType = 'Notification';
                    hw.alertLanguage = 'ko';
                    hw.title = 'Worker Type이 변경되었습니다. 서비스요원: ' + srMap.get(obj.ServiceResource__c);
                    hw.elementList.add(obj.WorkerType__c);
                    hw.receiverforID = new Set<Id>{obj.OwnerId};
                    System.debug('Alert Wrapper Created: ' + hw);
                    hwList.add(hw);
                }

                // ServiceAppointment 도착예정시간이 변경된 경우 관련 WorkOrder 업데이트 - 알림톡으로 고객한테 보내야됨
                if (obj.OnsiteDate__c != null && obj.OnsiteDate__c != oldObj.OnsiteDate__c) {
                    WorkOrder wo = woMap.get(obj.ParentRecordId);
                    if (wo != null) {
                        wo.TimeAgreedOnSite__c = obj.OnsiteDate__c;
                        woUpdate.add(wo);
                    }
                }
            }
    
            // 알림 발생
            if(hwList.size() > 0){
                System.debug('Alert Wrappers: ' + hwList);
                UTIL_Alert.runAlertEvent(hwList);
            }
    
            // WorkOrder 도착예정시간 업데이트 실행
            if (!woUpdate.isEmpty()) {
                try {
                    update woUpdate;
                    System.debug('woUpdate::: ' + woUpdate);

                } catch (Exception e) {
                    System.debug('Error WorkOrders: ' + e.getMessage());
                }
            }
    
        }
    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if (isExecuting) {
            System.debug('ServiceAppointmentTriggerHandler_onAfterUpdate');

            List<ServiceAppointment> saList = new List<ServiceAppointment>();
            Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();
            Set<Id> woSet = new Set<Id>();
            Map<Id, Case> caseMap = new Map<Id, Case>();
            Map<Id, Account> accountMap = new Map<Id, Account>();
            Set<Id> accountIds = new Set<Id>();
            Map<Id, Id> srMap = new Map<Id, Id>();

            String dnsaRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('ServiceAppointment_DNSA').getRecordTypeId();
            Set<Id> dnsa_woIds = new Set<Id>();

            for (ServiceAppointment newRecord : (List<ServiceAppointment>)news) {
                ServiceAppointment oldRecord = (ServiceAppointment)oldMap.get(newRecord.Id);
                
                if (newRecord.ParentRecordId != null) {
                    woSet.add(newRecord.ParentRecordId);
                }
                if (newRecord.AccountId != null) {
                    accountIds.add(newRecord.AccountId);
                }

                if(String.isNotEmpty(newRecord.ServiceResource__c) && (newRecord.ServiceResource__c != oldRecord.ServiceResource__c)){
                    srMap.put(newRecord.Id, newRecord.ServiceResource__c);
                }

                // Service Resource (Main)이고 OnsiteDate__c가 변경되었을 때 고객한테 알림톡 발송
                if (newRecord.WorkerType__c == 'Service Resource (Main)' && newRecord.OnsiteDate__c != null && newRecord.OnsiteDate__c != oldRecord.OnsiteDate__c) {
                    updateOnsiteDate(new List<ServiceAppointment>{newRecord}, (Map<Id, ServiceAppointment>) oldMap);
                }

                if((newRecord.RecordTypeId == dnsaRecordTypeId) && (String.isNotEmpty(newRecord.ServiceResource__c) && (newRecord.ServiceResource__c != oldRecord.ServiceResource__c))){
                    dnsa_woIds.add(newRecord.ParentRecordId);
                }
            }

            // WorkOrder 및 Account 정보 조회
            if (!woSet.isEmpty()) {
                for (WorkOrder wo : [SELECT Id, CaseId FROM WorkOrder WHERE Id IN :woSet]) {
                    woMap.put(wo.Id, wo);
                    if (wo.CaseId != null) {
                        caseMap.put(wo.CaseId, new Case(Id = wo.CaseId));
                    }
                }
            }

            if (!accountIds.isEmpty()) {
                for (Account acc : [SELECT Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry FROM Account WHERE Id IN :accountIds]) {
                    accountMap.put(acc.Id, acc);
                }
            }
    
            for (ServiceAppointment newRecord : (List<ServiceAppointment>)news) {
                ServiceAppointment oldRecord = (ServiceAppointment)oldMap.get(newRecord.Id);
    
                if (newRecord.Status == 'Uncompleted' && oldRecord.Status != 'Uncompleted') {
                    ServiceAppointment sa = new ServiceAppointment();
                    sa.RepairRequestDateTime__c = null;
                    sa.ServiceResource__c = oldRecord.ServiceResource__c;
                    sa.Pendingprocessing__c = null;
                    sa.PendingDetail__c = null;
                    sa.ParentRecordId = oldRecord.ParentRecordId;
                    sa.WorkerType__c = oldRecord.WorkerType__c;
                    sa.ContactId = oldRecord.ContactId;
                    sa.isPortal__c  = false;
    
                    // 날짜 설정 (현재 시간 + 1일)
                    DateTime currentTime = System.now();
                    DateTime nextDay = currentTime.addDays(1);
                    sa.EarliestStartTime = currentTime.addDays(1);
                    sa.DueDate = currentTime.addDays(1);
                    sa.SchedStartTime = DateTime.newInstance(nextDay.year(), nextDay.month(), nextDay.day(), 9, 0, 0);
                    sa.SchedEndTime = DateTime.newInstance(nextDay.year(), nextDay.month(), nextDay.day(), 13, 0, 0);
    
                    System.debug('newRecord.AccountId:::'+newRecord.AccountId);
                    if (newRecord.AccountId != null) {
                        Account acc = accountMap.get(newRecord.AccountId);
                        sa.State = acc.ShippingState;
                        sa.City = acc.ShippingCity;
                        sa.Street = acc.ShippingStreet;
                        sa.PostalCode = acc.ShippingPostalCode;
                        sa.Country = acc.ShippingCountry;
                    }
    
                    sa.Status = 'Assigned';
                    System.debug('sa:::' + sa);
                    saList.add(sa);
    
                    System.debug('newRecord.ParentRecordId:::' + newRecord.ParentRecordId);
                    if (newRecord.ParentRecordId != null) {
                        WorkOrder relatedWO = woMap.get(newRecord.ParentRecordId);
                        if (relatedWO.CaseId != null) {
                            Case newCase = caseMap.get(relatedWO.CaseId);
                            newCase.Pendingprocessing__c = newRecord.Pendingprocessing__c;
                            newCase.PendingDetail__c = newRecord.PendingDetail__c;
                            caseMap.put(newCase.Id, newCase);
                        }
                    }
                }
            }
    
            if (!saList.isEmpty()) {
                System.debug('saList:::' + saList);
                insert saList;
            }
    
            if (!caseMap.isEmpty()) {
                System.debug('caseMap.values():::' + caseMap.values());
                update caseMap.values();
            }

            if(!srMap.isEmpty()){
                List<AssignedResource> arList = [SELECT ServiceAppointmentId, ServiceResourceId FROM AssignedResource WHERE ServiceAppointmentId IN : srMap.keySet()];
                System.debug('arList ::: '+arList);
                if (arList.size() > 0) {
                    Boolean isChanged = false;
                    for(AssignedResource ar : arList){
                        if(ar.ServiceResourceId != srMap.get(ar.ServiceAppointmentId)){
                            ar.ServiceResourceId = srMap.get(ar.ServiceAppointmentId);
                            isChanged = true;
                        }
                    }
                    if(isChanged) {update arList;}
                } else {
                    List<AssignedResource> insertARList = new List<AssignedResource>();
                    for (String saId : srMap.keySet()) {
                        AssignedResource ar = new AssignedResource();
                        ar.ServiceAppointmentId = saId;
                        ar.ServiceResourceId = srMap.get(ar.ServiceAppointmentId);
                        insertARList.add(ar);
                    }
                    if (insertARList.size() > 0) insert insertARList;
                }
            }

            if(!dnsa_woIds.isEmpty()){
                CommonWrapper cw = dnsaOrderUpdate(dnsa_woIds);
                System.debug('dnsaOrderUpdate Result :: '+cw);
            }
        }
    }

    /*
     * @Description
     * 		- 공용Wrapper
     * 
     * @Variable
     *  	- isSuccess 			: 성공여부
     *  	- errMessage 			: 실패시 에러메세지
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
        }
    }

    // 서비스 요원 방문 예약 알림
    private void updateOnsiteDate(List<ServiceAppointment> saList, Map<Id, ServiceAppointment> oldMap) {
        List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();

        Set<Id> conId = new Set<Id>();
        for (ServiceAppointment sa : saList) {
            if (sa.ContactId != null) {
                conId.add(sa.ContactId);
            }
        }

        Set<Id> woId = new Set<Id>();
        for (ServiceAppointment sa : saList) {
            if (sa.ParentRecordId != null) {
                woId.add(sa.ParentRecordId);
            }
        }

        Map<Id, Contact> conMap = new Map<Id, Contact>(
            [SELECT Id, Name, MobilePhone FROM Contact WHERE Id IN :conId]
        );

        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(
            [SELECT Id, WorkOrderNumber, CaseId, Case.CaseNumber, TimeAgreedOnSite__c, ServiceOrderNumber__c 
             FROM WorkOrder 
             WHERE Id IN :woId]
        );

        String alertAlarmTalkId = [
            SELECT Id FROM AlertManager__c WHERE IsActive__c = true AND Name = 'CS Estimated Time Arrival Alarm Talk' LIMIT 1
        ].Id;

        for (ServiceAppointment sa : saList) {
            ServiceAppointment oldSa = oldMap.get(sa.Id);
            if(String.isNotEmpty(sa.ContactId) && (!conMap.isEmpty())){
                if(conMap.containsKey(sa.ContactId)){
                    String mobilePhone = conMap.get(sa.ContactId).MobilePhone == null ? '' : conMap.get(sa.ContactId).MobilePhone;
        
                    WorkOrder relatedWO = woMap.get(sa.ParentRecordId);
                    String ticketNumber = relatedWO.Case.CaseNumber;
                    String woNumber = relatedWO.ServiceOrderNumber__c;
                    Id caseId = relatedWO.CaseId;
                    String arrivalTime = sa.OnsiteDate__c.format();
                    String ctiUrl = System.Label.CTI_Url;
        
                    System.debug('arrivalTime:::'+arrivalTime);
        
                    Map<String, String> alertMap = new Map<String, String>();
                    alertMap.put('rcpt_no', ticketNumber); // 접수번호 Ticket번호
                    alertMap.put('order_no', woNumber); // 서비스오더번호 Work Order번호
                    alertMap.put('kt_resv_dt', arrivalTime); // 방문예약시간 
                    alertMap.put('url', ctiUrl + '?ticket=' + ticketNumber);
                    
                    UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
                    hw.alertID = alertAlarmTalkId;
                    hw.targetID = caseId;
                    hw.alertType = 'AlarmTalk';
                    hw.alertLanguage = 'ko';
                    hw.receiverforPhone = new Set<String>{mobilePhone};
                    hw.elementMap = alertMap;
        
                    System.debug('hwList:::'+hwList);
                    hwList.add(hw);
                }
            }
        }
        
        if(hwList.size()>0){
            UTIL_Alert.runAlertEvent(hwList);
        }
    }

    // 서비스 요원 배정 알림
    private void createSAAlarm(List<ServiceAppointment> saList, Map<Id, ServiceAppointment> oldMap) {
        List<UTIL_Alert.historyWrapper> hwList = new List<UTIL_Alert.historyWrapper>();

        Set<Id> conId = new Set<Id>();
        for (ServiceAppointment sa : saList) {
            if (sa.ContactId != null) {
                conId.add(sa.ContactId);
            }
        }

        Set<Id> woId = new Set<Id>();
        for (ServiceAppointment sa : saList) {
            if (sa.ParentRecordId != null) {
                woId.add(sa.ParentRecordId);
            }
        }

        Map<Id, Contact> conMap = new Map<Id, Contact>(
            [SELECT Id, Name, MobilePhone FROM Contact WHERE Id IN :conId]
        );

        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(
            [SELECT Id, WorkOrderNumber, Case.CaseNumber, TimeAgreedOnSite__c, ServiceOrderNumber__c, CaseId FROM WorkOrder WHERE Id IN :woId]
        );

        String alertAlarmTalkId = [
            SELECT Id FROM AlertManager__c WHERE IsActive__c = true AND Name = 'CS Assigning Service Resource Alarm Talk' LIMIT 1
        ].Id;

        for (ServiceAppointment sa : saList) {
            ServiceAppointment oldSa = oldMap.get(sa.Id);
            if(String.isNotEmpty(sa.ContactId) && (!conMap.isEmpty())){
                if(conMap.containsKey(sa.ContactId)){
                    String mobilePhone = String.isNotEmpty(conMap.get(sa.ContactId).MobilePhone) ? conMap.get(sa.ContactId).MobilePhone : '';
                    WorkOrder relatedWO = woMap.get(sa.ParentRecordId);
                    String ticketNumber = relatedWO.Case.CaseNumber;
                    String woNumber = relatedWO.ServiceOrderNumber__c;
                    Id caseId = relatedWO.CaseId;
                    String ctiUrl = System.Label.CTI_Url;

                    Map<String, String> alertMap = new Map<String, String>();
                    alertMap.put('rcpt_no', ticketNumber); // 접수번호 Ticket번호
                    alertMap.put('order_no', woNumber); // 서비스오더번호 Work Order번호
                    alertMap.put('url', ctiUrl + '?ticket=' + ticketNumber); //A/S 진행상황 조회 URL
        
                    UTIL_Alert.historyWrapper hw = new UTIL_Alert.historyWrapper();
                    hw.alertID = alertAlarmTalkId;
                    hw.targetID = caseId;
                    hw.alertType = 'AlarmTalk';
                    hw.alertLanguage = 'ko';
                    hw.receiverforPhone = new Set<String>{mobilePhone};
                    hw.elementMap = alertMap;
        
                    hwList.add(hw);
                    System.debug('hwList:::'+hwList);
                }
            }
        }
        

        if(hwList.size()>0){
            UTIL_Alert.runAlertEvent(hwList);
        }
    }

    private static CommonWrapper dnsaOrderUpdate(Set<Id> woIds){
        CommonWrapper cw = new CommonWrapper();
        try{
            List<ServiceAppointment> dnsaSaList = [SELECT Id, ParentRecordId, CreatedDate, ServiceTerritoryId, ServiceResource__c FROM ServiceAppointment WHERE ParentRecordId IN :woIds];
            Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>();
    
            for(ServiceAppointment sa : dnsaSaList){
                if(saMap.containsKey(sa.ParentRecordId)){
                    ServiceAppointment oldSa = saMap.get(sa.ParentRecordId);
                    if(sa.CreatedDate <= oldSa.CreatedDate){
                        saMap.put(sa.ParentRecordId, sa);
                    }
                }else{
                    saMap.put(sa.ParentRecordId, sa);
                }
            }
    
            System.debug('DNSA saMap :: '+saMap);
    
            List<WorkOrder> woList = [SELECT Id, Worker__c, ServiceTerritoryId FROM WorkOrder WHERE Id IN :saMap.keySet()];
            for(WorkOrder wo : woList){
                ServiceAppointment sa = saMap.get(wo.Id);
                wo.Worker__c = sa.ServiceResource__c;
                wo.ServiceTerritoryId = sa.ServiceTerritoryId;
            }
            update woList;
        }catch(Exception e){
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }
}