/**
 * @Description       : 
 * @author            : suheon.ha
 * @last modified on  : 2025-06-09
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
public without sharing class AssignedResourceTriggerHandler extends TriggerHandler {
    private static Boolean isUpdated = false;

    /**
     * @Description
     * 	- AssignedResource After Insert
     * @author Hayeong Min 
    **/ 
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
        if(isExecuting) {
            List<AssignedResource> arList = (List<AssignedResource>) news;

            //해당 ServiceResource에게 WorkOrder 배정 알림
            Map<Id, Id> arMap = new Map<Id, Id>();
            for(AssignedResource obj : arList){
                if(obj.ServiceResourceId != null){
                    arMap.put(obj.Id, obj.ServiceResourceId);
                }
            }

            if(!arMap.isEmpty()){
                CommonWrapper cw = sendAlertToWorker(arMap);
                System.debug('sendAlertToWorker Result ::: '+cw);
            }
        }
    }
    
    /**
     * @Description
     * 	- AssignedResource After Update
     * @author Hayeong Min 
    **/ 
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting) {
            List<AssignedResource> arList = (List<AssignedResource>) news;

            Map<Id, Id> arMap = new Map<Id, Id>();
            for(AssignedResource obj : arList){
                AssignedResource oldObj = (AssignedResource) oldMap.get(obj.Id);
                if(obj.ServiceResourceId != oldObj.ServiceResourceId){
                    arMap.put(obj.Id, obj.ServiceResourceId);
                    System.debug('oldObj :: '+ oldObj.ServiceResourceId);
                    System.debug('newObj :: '+ obj.ServiceResourceId);
                }
            }

            System.debug('arMap ::: '+arMap);
            if(!arMap.isEmpty()){
                CommonWrapper cw = sendAlertToWorker(arMap);
                System.debug('sendAlertToWorker Result ::: '+cw);
            }
        }
    }

    /**
     * @Description
     * 	- Service Resource에게 WorkOrder 배정 알림 발송
     *  - 상위 Work Order 유형이 설치시운전인 경우, Ticket에 첨부된 파일들 모두 모아서 Email에 첨부하기
     * 
     * @author Hayeong Min | 2025-02-17
     * @Parameter
     *  - arMap      : <AssignedResource Id, ServiceResource Id>
    **/ 
    private static CommonWrapper sendAlertToWorker(Map<Id, Id> arMap){
        CommonWrapper cw = new CommonWrapper();
        try{
            //WorkOrder의 간접접수 여부 확인 & ServiceAppointment의 포탈에서 생성여부 확인 -> 이 경우에는 알림이 가면 안됨
            List<AssignedResource> arList = [SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId, 
                                        ServiceResource.Service_Territory__c, 
                                        ServiceAppointmentId, ServiceAppointment.ServiceResource__c,
                                        ServiceAppointment.isPortal__c,
                                        ServiceAppointment.ParentRecordId,
                                        ServiceAppointment.WorkOrder__c,
                                        ServiceAppointment.WorkOrder__r.OrderType__c ,
                                        ServiceAppointment.WorkOrder__r.RecordType.Name ,
                                        ServiceAppointment.WorkOrder__r.ServiceOrderNumber__c,
                                        ServiceAppointment.SchedStartTime,
                                        ServiceAppointment.WorkOrder__r.CaseId,
                                        ServiceAppointment.WorkOrder__r.Account.Name,
                                        ServiceAppointment.WorkOrder__r.Asset.Name,
                                        ServiceAppointment.WorkOrder__r.Asset.MachineName__c
                                        FROM AssignedResource 
                                        WHERE Id IN :arMap.keySet()
                                        AND ServiceAppointment.WorkerType__c != 'Service Resource (Sub)'];
                                    
            Map<Id, AssignedResource> woMap = new Map<Id, AssignedResource>();
            Map<Id, AssignedResource> saMap = new Map<Id, AssignedResource>();
            Set<ID> userIds = new Set<Id>();
            Set<Id> woIds = new Set<Id>();
            if(arList.size()>0){
                for(AssignedResource ar : arList){
                    woIds.add(ar.ServiceAppointment.ParentRecordId);
                    //포탈에서 생성된 경우 알림 발송 X
                    if(!ar.ServiceAppointment.isPortal__c){
                        woMap.put(ar.ServiceAppointment.ParentRecordId , ar);
                        userIds.add(ar.ServiceResource.RelatedRecordId);
                    }
                    
                    //상위 ServiceAppointment의 작업자 & W/C 정보 변경
                    saMap.put(ar.ServiceAppointmentId , ar);
                }

                //ServiceAppointment의 작업자 & W/C 정보 변경
                List<ServiceAppointment> saList = [SELECT Id, ServiceResource__c, ServiceTerritoryId 
                                                    FROM ServiceAppointment 
                                                    WHERE ID IN : saMap.keySet()];
                System.debug('saList ::: '+saList);
                Boolean isChanged = false;
                for(ServiceAppointment sa : saList){
                    System.debug('sa.ServiceResource__c ::: '+sa.ServiceResource__c);
                    System.debug('saMap.get(sa.Id).ServiceResourceId ::: '+saMap.get(sa.Id).ServiceResourceId);
                    if(sa.ServiceResource__c != saMap.get(sa.Id).ServiceResourceId){
                        sa.ServiceResource__c = saMap.get(sa.Id).ServiceResourceId;
                        sa.ServiceTerritoryId = saMap.get(sa.Id). ServiceResource.Service_Territory__c;
                        isChanged = true;
                    }
                }
                if(isChanged) {update saList;}

                List<WorkOrder> woList = [SELECT Id, ServiceOrderNumber__c, Is_Indirect_Reception__c
                                        FROM WorkOrder 
                                        WHERE ID IN : woMap.keySet()
                                        AND Is_Indirect_Reception__c = FALSE];

                Map<Id, String> numMap = new Map<Id, String>();
                if(woList.size()>0){
                    for(WorkOrder wo :woList){
                        numMap.put(wo.Id, wo.ServiceOrderNumber__c);
                    }
                }

                Map<Id, Set<Id>> fileMap = getFileIds(woIds);

                if(!numMap.isEmpty()){
                    List<UTIL_Alert.HistoryWrapper> hwlist = new List<UTIL_Alert.HistoryWrapper>();
                    String alertManagerId = [SELECT Id FROM AlertManager__c WHERE Name = 'WorkOrder Assignment Service Resource Notification'].Id; 
                    String amId = [SELECT Id FROM AlertManager__c WHERE Name = 'WorkOrder Assignment DNSA Service Resource Notification'].Id; 
                    Map<Id, UserWrapper> userInfo = getUserInfoMap(userIds);
                    for(AssignedResource ar : arList){
                        if(!ar.ServiceAppointment.isPortal__c){
                            //AlertType : Notfication
                            UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                            notihw.alertID = alertManagerId;
                            notihw.targetID = ar.ServiceAppointment.ParentRecordId;
                            notihw.alertType = 'Notification';
                            String element = 
                                (ar.ServiceAppointment.WorkOrder__r.ServiceOrderNumber__c != null ? ar.ServiceAppointment.WorkOrder__r.ServiceOrderNumber__c : '') + ' / ' +
                                (ar.ServiceAppointment.WorkOrder__r.Account != null ? ar.ServiceAppointment.WorkOrder__r.Account.Name : '') + ' / ' +
                                (ar.ServiceAppointment.WorkOrder__r.Asset != null ? ar.ServiceAppointment.WorkOrder__r.Asset.Name : '') + ' / ' +
                                (ar.ServiceAppointment.WorkOrder__r.Asset != null ? ar.ServiceAppointment.WorkOrder__r.Asset.MachineName__c : '');
                            notihw.elementList = new List<String>{ element };   
                            // notihw.elementList = new List<String>{numMap.get(ar.ServiceAppointment.ParentRecordId)};
                            notihw.receiverforID = new Set<Id>{ar.ServiceResource.RelatedRecordId};
                            notihw.alertLanguage = userInfo.get(ar.ServiceResource.RelatedRecordId).language;
                            System.debug('notihw ::: '+notihw);
                            hwList.add(notihw);
                        }

                        if(ar.ServiceAppointment.WorkOrder__r.OrderType__c == '104'){
                            String goToURL = URL.getOrgDomainURL().toExternalForm() + '/' + ar.ServiceAppointment.WorkOrder__c;
                            UTIL_Alert.historyWrapper emailhw = new UTIL_Alert.historyWrapper();
                            emailhw.alertID = alertManagerId;
                            emailhw.targetID = ar.ServiceAppointment.ParentRecordId;
                            emailhw.alertType = 'Email';
                            emailhw.elementList = new List<String>{ar.ServiceAppointment.WorkOrder__r.ServiceOrderNumber__c, goToURL};
                            emailhw.receiverforEmail = new List<String>{userInfo.get(ar.ServiceResource.RelatedRecordId).Email};
                            emailhw.alertLanguage = userInfo.get(ar.ServiceResource.RelatedRecordId).language;
                            emailhw.attachmentIDS = fileMap.containsKey(ar.ServiceAppointment.WorkOrder__r.CaseId) ? fileMap.get(ar.ServiceAppointment.WorkOrder__r.CaseId) : null;
                            System.debug('emailhw ::: '+emailhw);
                            hwList.add(emailhw);
                        }
                        if(ar.ServiceAppointment.WorkOrder__r.RecordType.Name == 'WorkOrder(DNSA)'){
                            UTIL_Alert.historyWrapper dnsaEmailhw = new UTIL_Alert.historyWrapper();
                            dnsaEmailhw.alertID = amId;
                            dnsaEmailhw.targetID = ar.ServiceAppointment.ParentRecordId;
                            dnsaEmailhw.alertType = 'Email';
                            dnsaEmailhw.elementList = new List<String>{ar.ServiceAppointment.WorkOrder__r.ServiceOrderNumber__c, ar.ServiceAppointment.WorkOrder__r.Account.Name, ar.ServiceAppointment.WorkOrder__r.Asset.Name, ar.ServiceAppointment.SchedStartTime != null ? String.valueOf(ar.ServiceAppointment.SchedStartTime) : ''};
                            dnsaEmailhw.receiverforEmail = new List<String>{userInfo.get(ar.ServiceResource.RelatedRecordId).Email};
                            dnsaEmailhw.alertLanguage = userInfo.get(ar.ServiceResource.RelatedRecordId).language;
                            // dnsaEmailhw.attachmentIDS = fileMap.containsKey(ar.ServiceAppointment.WorkOrder__r.CaseId) ? fileMap.get(ar.ServiceAppointment.WorkOrder__r.CaseId) : null;
                            System.debug('dnsaEmailhw ::: '+dnsaEmailhw);
                            hwList.add(dnsaEmailhw);
                        }
                    }
                    UTIL_Alert.ResultWrapper rw = UTIL_Alert.runAlertEvent(hwList);
                    if(!rw.isSuccess){
                        cw.isSuccess = false;
                        cw.errMessage = rw.errMessage;
                    }
                }            
            }     
        }catch(Exception e){
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
    * @description User 정보 Map으로 반환
    * @author Hayeong Min | 2025-02-17
    * AssignedResourceTriggerHandler.getUserInfoMap();
    **/
    private static Map<Id, UserWrapper> getUserInfoMap(Set<Id> userIds){
        List<User> users = [SELECT Id, Email, LanguageLocaleKey FROM User WHERE ID IN :userIds AND IsActive = TRUE];
        Map<Id, UserWrapper> userMap = new Map<Id, UserWrapper>();
        for(User u : users){
            UserWrapper uw = new UserWrapper();
            uw.Id = String.valueOf(u.Id);
            uw.Email = u.Email;
            uw.language = (u.LanguageLocaleKey == 'ko') ? 'ko' : 'en';
            userMap.put(u.Id, uw);
        }
        return userMap;
    }

    public static Map<Id, Set<Id>> getFileIds(Set<Id> woIds){
        List<WorkOrder> woList = [SELECT Id, CaseId, OrderType__c FROM WorkOrder WHERE Id IN :woIds];
        Set<Id> ticketIds = new Set<Id>();
        for(WorkOrder obj : woList){
            if(obj.OrderType__c == '104'){//설치시운전인 경우
                ticketIds.add(obj.CaseId);
            }
        }
        
        Map<Id, Set<Id>> cdMap = new Map<Id, Set<Id>>(); // ticketId, ContentDocumentId Set
        if(ticketIds.size()>0){
            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId, Id, LinkedEntityId 
                                                    FROM ContentDocumentLink 
                                                    WHERE LinkedEntity.Type = 'Case' AND LinkedEntityId IN :ticketIds];
            for(ContentDocumentLink cdl : cdlList){
                if(cdMap.containsKey(cdl.LinkedEntityId)){
                    Set<Id> cdSet = cdMap.get(cdl.LinkedEntityId);
                    cdSet.add(cdl.ContentDocumentId);
                    cdMap.put(cdl.LinkedEntityId, cdSet);
                }else{
                    Set<Id> cdSet = new Set<Id>{cdl.ContentDocumentId};
                    cdMap.put(cdl.LinkedEntityId, cdSet);
                }
            }
        }
        return cdMap;
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

    /*
     * @Description 
     *  - User 정보 Wrapper
     * 
     * @Variable 
     *  - Id 	    : 사용자 아이디
     *  - Email 	: 사용자 이메일
     *  - language 	: 사용자 언어
     */ 
    public class UserWrapper{
        @AuraEnabled public String Id       { get; set;}
        @AuraEnabled public String Email    { get; set;}
        @AuraEnabled public String language { get; set;}
        
        public UserWrapper(){
            this.Id = '';
            this.Email = '';
            this.language = '';
        }
    }
}