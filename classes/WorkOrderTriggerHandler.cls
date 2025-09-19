/**
* @Class : WorkOrderTriggerHandler
*
* @Author : Hayeong, Min
* @Date : 2024. 06. 13.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-06-13 | Hayeong, Min   | 최초작성
*  2. | 2024-07-25 | Junyeong, Choi | ver.2
*  3. | 2024-09-10 | Hayeong, Min   | ver.3
*  4. | 2024-11-12 | Suheon, Ha     | ver.4
*
*/
public without sharing class WorkOrderTriggerHandler extends TriggerHandler{
    /**
     * @Description
     * 	- Work Order Before Insert
     * @author Hayeong Min | 2024-01-08
    **/ 
    public override void onBeforeInsert(List<sObject> news){
        if(isExecuting){
            System.debug('WorkOrderTriggerHandler onBeforeInsert');
            List<WorkOrder> workOrderList = (List<WorkOrder>) news;
        
            //250617 by Hayeong Min : 기본적인 Workorder 입력값 Setting
            madeWorkOrderForm(workOrderList);
            //250617 by Hayeong Min : 작업자 전화번호 insert 
            insertWorkerPhoneNumber(workOrderList);
            //250617 by Hayeong Min : 상위 Ticket의 Owner의 MobilePhone 정보 insert
            insertTechPhoneNumber(workOrderList);
        }
    }


    /**
     * @Description
     * 	- Work Order After Insert
     *  1. WorkOrder 생성 시 센터장에게 Noti & Email 발송
     *  2. Service Appointment 자동 생성
     * @author Hayeong Min | 2024-01-08
    **/ 
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting){
            System.debug('WorkOrderTriggerHandler onAfterInsert');
            List<WorkOrder> workOrderList = (List<WorkOrder>) news;
            
            //Service Appointment 자동 생성
            CommonWrapper cw1 = createServiceAppointment(workOrderList);
            System.debug('createServiceAppointment isSuccess : '+cw1.isSuccess);
            //240725 by Juneyong Choi : WorkOrder ProductRequest에 Campaign의 Common Parts 추가 Trigger
            CommonWrapper cw2 = getCommonParts(workOrderList);
            //250618 by Hayeong Min
            // 설치시운전/설치검수 WorkOrder 생성 시 OrderManagement Update
            // 설치시운전 생성 시 장비 정보 가져오기 (updateAssetFromERP)
            // 설치시운전 생성 시 sms 전송 (sendInternalRequesterSMS)
            checkInstallrequestOrderType(workOrderList);
            //20250226 by 박지영 : 납품 후 교육 sms 발송
            sendPostDeliveryTrainingSMS(workOrderList);
            
            // 지사별 클레임 미결현황 플랫폼 이벤트 (서영덕)
            StatusBoardEvent__e event = new StatusBoardEvent__e();
            Database.SaveResult sr = EventBus.publish(event);
            System.debug('sr ::: ' + sr);
            if(sr.isSuccess()) {
                System.debug('Success');
            }
        }
    }


    /**
     * @Description
     * 	- Work Order Before Update
     * @author Hayeong Min | 2024-01-08
    **/ 
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting) {
            System.debug('WorkOrderTriggerHandler.onBeforeUpdate');

            List<WorkOrder> workOrderList = (List<WorkOrder>) news;
            Map<Id, WorkOrder> oldWorkOrderMap = (Map<Id, WorkOrder>) oldMap;
                        
            // PM Activity Type 변경 시 부품청구 있으면 변경 불가
            validationUpdatePMActivity(workOrderList, oldWorkOrderMap);
            //SPTask Validation 체크
            validationSPTask(workOrderList, oldWorkOrderMap);
            //납품후교육 정책 & P-Claim은 지정된 사람만 설정 가능
            checkPermission(workOrderList, oldWorkOrderMap);

            //필드작업자 정보 있으면 해당 작업자의 service territory 정보 입력
            updateFieldWorker(workOrderList, oldWorkOrderMap);

            //WorkOrder 정보 변경
            // - 상태가 완료일 때 완료시간도 넣기 Completed
            // - 입고수리 관련 일자 입력 시 진행사항 필드 Update
            // - PM Activity에 맞게 Order Type 변경
            updateOrderInfo(workOrderList, oldWorkOrderMap);

            //Validation
            // - 직영유상의 오더일 때 해당 작업자가 직영소속이 아니면 Error Validation
            checkIsDirectValidation(workOrderList, oldWorkOrderMap);
            // - Confirm 된 Service Order I/F 업데이트 필드 수정 불가
            // - 직영유상일 때 PM activity가 202 아니면 ERROR Validation
            checkValidation(workOrderList, oldWorkOrderMap);

            //작업자 전화번호 업데이트
            updateWorkerInfo(workOrderList, oldWorkOrderMap);

            //250701 by Hayeong Min : 상위 Ticket의 Requester 정보와 Service Order의 Contact 정보가 다르면 Update
            updateContact(workOrderList, oldWorkOrderMap);
            //250704 by Hayeong Min : Migration DATA 중 고장정보가 없는 CS02 데이터 addError(해당 Ticket에 고장정보 없음을 나타내는 에러)
            checkFailureInfo(workOrderList, oldWorkOrderMap);
        }


    }


    /**
     * @Description
     * 	- Work Order After Update
     * @author Hayeong Min | 2025-07-07
    **/ 
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if (isExecuting) {
            System.debug('WorkOrderTriggerHandler.onAfterUpdate');
            List<WorkOrder> workOrderList = (List<WorkOrder>) news;
            Map<Id, WorkOrder> oldWorkOrderMap = (Map<Id, WorkOrder>) oldMap;

            //250707 by Hayeong Min : Service Order의 작업자 정보 변경 시 하위 메인작업자 Service Appointment 작업자 정보 변경
            updateServivceAppointmentData(workOrderList, oldWorkOrderMap);
            //250707 by Hayeong Min : Service Order의 작업자 정보 변경 시 하위 메인작업자 Service Order Result 작업자 정보 변경
            updateWorkorderResultData(workOrderList, oldWorkOrderMap);

            //250701 by Hayeong Min : Service Order의 출동요청일시 변경시, 하위 Service Appointment의 정보 수정
            updateServiceAppointement(workOrderList, oldWorkOrderMap);

            //250701 by Hayeong Min : WorkOrder가 Confirm이 되는 순간 상위 Ticket의 Status를 Closed, 종결이유는 Dispatch Completed로 Update
            updateTicketToClosed(workOrderList, oldWorkOrderMap);   
            
            //250707 by Hayeong Min : 재배정된Service Order의 하위 Service Appointment 상태 Assigned로 정보 변경
            updateAssignedData(workOrderList, oldWorkOrderMap);

            // 설치 시운전 서비스 오더 Confirm시 장비 WorkCenter/설치 담당자 추가
            updateConfirmEquipment(workOrderList, oldWorkOrderMap);
            //설치 시운전 서비스 오더 Canceled시 장비 WorkCenter/설치 담당자 제거
            updateCanceledEquipment(workOrderList, oldWorkOrderMap);
            //250701 by Hayeong Min : Service Order I/F Update & SMS 재발송
            for (WorkOrder obj : workOrderList) {
                WorkOrder oldObj = (WorkOrder) oldMap.get(obj.Id);
                //250701 서비스오더 정보 수정 시 서비스오더 수정 I/F By Hayeong Min 
                //WorkOrder FieldSet > UpdateWorkOrder에 해당 필드 입력함 => 작업자, WorkCenter, 출동요청일시, Order Type, PM Activity Type
                Boolean isIF = isFieldSetChanged(obj, oldObj);
                System.debug('is this workOrder need to run Interface :: '+isIF);

                //250701 납품 후 교육 Service Order 작업자, 출동요청일시 변경 시 SMS 재발송 By Hayeong Min 
                Boolean isSMS = false;
                if((obj.TicketType__c == 'Post-delivery training') && ((obj.Worker__c != oldObj.Worker__c) || (obj.ScheduledDispatchTime__c != oldObj.ScheduledDispatchTime__c))){
                        isSMS = true;
                }

                //workorder Update I/F
                if (isIF) orderUpdate_IF(obj.Id, isSMS);
            }            

            // 지사별 클레임 미결현황 플랫폼 이벤트 (서영덕)
            for (WorkOrder newWo : workOrderList) {
                WorkOrder oldWo = (WorkOrder) oldMap.get(newWo.Id);
                if (newWo.ServiceTerritoryId != oldWo.ServiceTerritoryId) {
                    StatusBoardEvent__e event = new StatusBoardEvent__e();
                    Database.SaveResult sr = EventBus.publish(event);
                    System.debug('sr ::: ' + sr);
                    if(sr.isSuccess()) {
                        System.debug('Success');
                    }
                }
            }
        }
    }
    

    /**
     * @Description
     * 	- WorkOrder onBeforeDelete
     * @author Hayeong Min
    **/
    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
        //WorkOrder 삭제시 연결된 ServiceAppointment & ProductRequest 삭제
        delServiceAppointment(dels);
    }


    public override void onAfterDelete(sObject delRecord){
        // 지사별 클레임 미결현황 플랫폼 이벤트 (서영덕)
        StatusBoardEvent__e event = new StatusBoardEvent__e();
        Database.SaveResult sr = EventBus.publish(event);
        System.debug('sr ::: ' + sr);
        if(sr.isSuccess()) {
            System.debug('Success');
        }
    }


    /**
     * @Description
     * 	- ServiceResource Map 반환
     * @return 
     * - Map<ServiceResourceId, ServiceResource>
     * @author Hayeong Min | 20240809
    **/
    public static Map<Id, ServiceResource> ResourceTerritory(){
        // Map<Id, String> srMap = new Map<Id, String>();
        Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>();
        List<ServiceResource> srList = [SELECT Id, Name, Service_Territory__c, RelatedRecordId FROM ServiceResource WHERE Service_Territory__c != NULL];
        if(srList.size()>0){
            for(ServiceResource sr : srList){
                srMap.put(sr.Id, sr);
            }
        }
        System.debug('srMap ::: '+srMap);
        return srMap;
    }


    /**
     * @Description
     * 	- Service Appointmnet 자동 생성
     * @author Hayeong Min | 20241028
    **/
    public static CommonWrapper createServiceAppointment(List<WorkOrder> newList){
        CommonWrapper cw = new CommonWrapper();
        try{

            Set<Id> workOrderIds = new Set<Id>();
            for(WorkOrder wo : newList){
                if(wo.Country__c == 'DNS'){
                    workOrderIds.add(wo.Id);
                }
            }

            Set<Id> saIDs = new Set<Id>();
            List<WorkOrder> woList = [SELECT Id, WorkOrderNumber, Worker__c, ServiceTerritoryId, Status,
            ScheduledDispatchTime__c, AccountId, Is_Indirect_Reception__c
                                    FROM WorkOrder WHERE Id IN :workOrderIds];
            System.debug('woList::: '+woList);
            System.debug('WorkOrderIDS : '+workOrderIds);
            
            Map<Id, ServiceResource> srMap = ResourceTerritory();
            List<ServiceAppointment> saList = new List<ServiceAppointment>();

            Set<Id> accIDs = new Set<Id>();
            for(WorkOrder obj : woList){
                accIDs.add(obj.AccountId);
            }

            Map<Id, Account> accAddress = getAccountAddress(accIDs);
            Id saDomesticRecType = [SELECT ID FROM RecordType WHERE DeveloperName = 'ServiceAppointment' LIMIT 1].Id;
            for(WorkOrder obj : woList){
                ServiceAppointment sa = new ServiceAppointment();
                sa.RecordTypeId = saDomesticRecType;
                DateTime dt = obj.ScheduledDispatchTime__c; // Ticket의 수리요청일시(방문요청일)
                sa.ParentRecordId = obj.Id;
                sa.RepairRequestDateTime__c = dt; //수리요청일시
                sa.EarliestStartTime = dt;  //접수 시간

                //1일 이내 수리완료(목표)는 Ticket의 수리요청일 당일 23:59분으로 설정
                sa.DueDate = DateTime.newInstance(dt.year(), dt.month(), dt.day(), 23, 59, 59);
                sa.ScheduledDispatchTime__c = dt;
                sa.SchedStartTime = dt;
                sa.SchedEndTime = dt.addHours(4); //(+4시간)
                if(String.isNotEmpty(obj.Worker__c)){
                    sa.ServiceResource__c = obj.Worker__c;
                    sa.ServiceTerritoryId = obj.ServiceTerritoryId; 
                }
                sa.WorkerType__c = 'Service Resource (Main)';
                sa.Status = 'Assigned';
                sa.OwnerId = srMap.get(obj.Worker__c).RelatedRecordId;
                // sa.Duration = 4;
                System.debug('sa :::: '+sa);
                //Noti용으로 Address 넣어야 함 무슨 주소로 할지 확인 필요
                //--------------------------------주소 시작
                    Account acc = accAddress.get(obj.AccountId);
                    sa.city = acc.ShippingCity;
                    sa.country = acc.ShippingCountry;
                    sa.state = acc.ShippingState;
                    sa.street = acc.ShippingStreet;
                    sa.postalCode = acc.ShippingPostalCode;
                //--------------------------------여기까지 주소
                saList.add(sa);
                saIDs.add(sa.Id);
                
            }

            if(saList.size()>0){
                insert saList;           
            }
            
        }catch(Exception e){
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        System.debug('createServiceAppointment : '+cw);
        return cw;
        
    }

    /**
     * @Description
     * 	- Account Map
     * @Return
     *  - Map<Id, Account>
     * @author Hayeong Min | 20240910
    **/
    public static Map<Id, Account> getAccountAddress(Set<Id> accSet){
        Map<Id, Account> accMap = new Map<Id, Account>();
        List<Account> accList = [SELECT Id, ShippingCountry, ShippingState, ShippingCity, ShippingStreet, ShippingPostalCode FROM Account WHERE Id IN :accSet];
        for(Account acc : accList){
            accMap.put(acc.Id, acc);
        }
        return accMap;
    }

    /**
     * @Description
     * 	- Get CaseIds
     * @Return
     *  - Set<Id>
     * @author Junyeong Choi | 20241029
    **/
    public static CommonWrapper getCommonParts(List<WorkOrder> workOrderList){
        Set<Id> workOrderIds                       = new Set<Id>();
        Set<Id> caseIds                            = new Set<Id>();
        Set<Id> campaignIds                        = new Set<Id>();
        List<CommonPart__c> cpList                 = new List<CommonPart__c>();
        List<ProductRequest> prList                = new List<ProductRequest>();
        List<ContentDocumentLink> workOrderLinks   = new List<ContentDocumentLink>();
        CommonWrapper cw                           = new CommonWrapper();
        try{
            for (WorkOrder obj : workOrderList) {
                if (String.isNotEmpty(obj.CaseId)) {
                    caseIds.add(obj.CaseId);
                }
                workOrderIds.add(obj.Id);
            }
            // Case ID가 있으면 관련된 Campaign ID 가져오기
            if (!caseIds.isEmpty()) {
                List<Case> caseList = [
                    SELECT Id, Campaign__c, InternalTicketType__c 
                    FROM Case 
                    WHERE Id IN :caseIds 
                    AND (InternalTicketType__c = 'Service Campaign' OR InternalTicketType__c = 'Pre-Call')
                ];
                System.debug('caseList: ' + caseList);
                for (Case obj : caseList) {
                    if (String.isNotEmpty(obj.Campaign__c)) {
                        campaignIds.add(obj.Campaign__c);
                    }
                }
            }
            List<ContentDocumentLink> campaignFiles = new List<ContentDocumentLink>();
            if (!campaignIds.isEmpty()) {
                List<Campaign> campaignList = [
                    SELECT Id, (SELECT Id, Product__c, Quantity__c, PartsNo__c FROM CommonPart__r) 
                    FROM Campaign 
                    WHERE Id IN :campaignIds
                ];

                campaignFiles = [
                    SELECT ContentDocumentId, LinkedEntityId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :campaignIds AND IsDeleted = FALSE
                ];

                System.debug('campaignList: ' + campaignList);
                for (Campaign obj : campaignList) {
                    for (CommonPart__c cp : obj.CommonPart__r) {
                        cpList.add(cp);
                    }
                }
                System.debug('cpList: ' + cpList);
            }
    
            // WorkOrder와 CommonPart를 연관지어 ProductRequest 생성
            for (WorkOrder wo : workOrderList) {
                for (CommonPart__c cp : cpList) {
                    ProductRequest pr = new ProductRequest();
                    pr.WorkOrderId = wo.Id;
                    pr.Product__c  = cp.Product__c;
                    pr.Quantity__c = cp.Quantity__c;
                    prList.add(pr);
                }
            }

            if (!prList.isEmpty()) {
                insert prList;
                System.debug('prList inserted: ' + prList);
            }

            for (ContentDocumentLink file : campaignFiles) {
                for (Id workOrderId : workOrderIds) {
                    ContentDocumentLink newLink   = new ContentDocumentLink();
                    newLink.ContentDocumentId     = file.ContentDocumentId;
                    newLink.LinkedEntityId        = workOrderId;
                    newLink.ShareType             = 'V';
                    workOrderLinks.add(newLink);
                }
            }
            
            if (!workOrderLinks.isEmpty()) {
                insert workOrderLinks;
                System.debug('workOrderLinks inserted: ' + workOrderLinks);
            }

        }catch(Exception e){
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        System.debug('getCommonParts result: ' + cw);
        return cw;
        
    }

    /**
    * @description User 정보 Map으로 반환
    * @author yeongju.yun | 2024-10-24 
    * TicketTriggerHandler.getUserInfoMap();
    **/
    // private static Map<Id, UserWrapper> getUserInfoMap(){
    //     List<User> users = [SELECT Id, Email, LanguageLocaleKey FROM User WHERE IsActive = TRUE];
    //     Map<Id, UserWrapper> userMap = new Map<Id, UserWrapper>();
    //     for(User u : users){
    //         UserWrapper uw = new UserWrapper();
    //         uw.Id = String.valueOf(u.Id);
    //         uw.Email = u.Email;
    //         uw.language = (u.LanguageLocaleKey == 'ko') ? 'ko' : 'en';
    //         userMap.put(u.Id, uw);
    //     }
    //     return userMap;
    // }

    //장비의 SalesOrder를 찾아 Sales Order로 수주정보관리 (OrderManagement__c)를 찾아  그 Row데이터에 아래 내용 업데이트
    //설치 시운전 WorkOrder 생성시
    //MainWorkCenter__c (설치오더의 W.C)
    //SVCOrder__c (설치오더)
    //ConfirmServiceResource__c (설치검수 오더의 Main 작업자)
    //InstallConfirmDate__c (설치검수 Order 생성일)
    private static CommonWrapper updateOrderManagement(String activityType, List<WorkOrder> woList){
        CommonWrapper cw = new CommonWrapper();
        try{
            Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();
            for(WorkOrder wo : woList){
                woMap.put(wo.AssetId, wo);
            }
            List<Asset> equipList = [SELECT Id, Order__c FROM Asset WHERE ID IN :woMap.keySet()]; 

            Map<Id, WorkOrder> soMap = new Map<Id, WorkOrder>();
            for(Asset e : equipList){
                soMap.put(e.Order__c, woMap.get(e.Id));
            }

            if(!soMap.isEmpty()){
                List<Order> soList = [SELECT Id FROM Order WHERE Id IN :soMap.keySet()];
                Set<Id> odIds = new Set<Id>();
                for(Order o : soList){
                    odIds.add(o.Id);
                }
                System.debug('odIds ::: '+odIds);
                List<OrderManagement__c> omList = [SELECT Id, SalesOrder__c, SVCOrder__c, MainWorkCenter__c, ConfirmServiceResource__c, InstallConfirmDate__c FROM OrderManagement__c WHERE SalesOrder__c IN : odIds];
                if(omList.size()>0){
                    if(activityType == '104'){
                        for(OrderManagement__c om : omList){
                            om.MainWorkCenter__c = soMap.get(om.SalesOrder__c).ServiceTerritoryId;
                            om.SVCOrder__c = soMap.get(om.SalesOrder__c).Id;
                        }
                    }else if(activityType == '809'){
                        for(OrderManagement__c om : omList){
                            om.ConfirmServiceResource__c = soMap.get(om.SalesOrder__c).Worker__c;
                            om.InstallConfirmDate__c = soMap.get(om.SalesOrder__c).CreatedDate.date();
                        }
                    }
                    System.debug('omList ::: '+omList);
                    update omList;
                }
            }
        }catch(Exception e){
            System.debug('e.getMessage :: '+e.getMessage());
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    //DNSA용 WorkOrderNumber 값을 Service Order Number에 입력하기 위한 메소드
    private static void updateServiceOrderNum(Set<Id> dnsaIDs){
        List<WorkOrder> woList = [SELECT Id, WorkOrderNumber, ServiceOrderNumber__c FROM WorkOrder WHERE ID IN :dnsaIDs];
        for(WorkOrder wo :woList){
            wo.ServiceOrderNumber__c = wo.WorkOrderNumber;
        }
        update woList;
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
     *  - Service Order Update I/F
     * 
     * @Variable 
     *  - woId 	    : WorkOrder ID
     *  - doSendSMS : SMS 발송여부
     */
    @future(callout=true)
    private static void orderUpdate_IF(String woId, Boolean doSendSMS) {
        try {
            WorkOrder wo = [SELECT Id, ScheduledDispatchTime__c, PMActivityType__c, OrderType__c, ReceptionDetail__c, CreatedDate,
            SPTask__c, ServiceOrderNumber__c, FM_Contact__c, Case.FM_PhoneNumber__c, 
            Worker__c, Worker__r.Name, Worker__r.StaffNumber__c, Worker__r.FM_isDirect__c,
            Worker__r.Service_Territory__r.PlanningPlant__c,
            Asset.Name, Asset.MachineName__c, Asset.SerialNumber, 
            Case.FM_EquipmentWarranty__c, Case.FM_LaborWarranty__c, Case.FM_PartsWarranty__c,
            SoldTo__r.CustomerCode__c, SoldTo__r.Name, SoldTo__r.ShippingPostalCode,
            SoldTo__r.ShippingCity, SoldTo__r.ShippingStreet, 
            Account.Name,  Account.CustomerCode__c, Account.ShippingPostalCode,
            Account.ShippingCity, Account.ShippingStreet, 
            Case.BreakdownDateTime__c, Case.ApplicationDateTime__c, FM_RepairRequestDateTime__c,
            ServiceTerritoryId, ServiceTerritory.Name, ServiceTerritory.WCCode__c, ServiceTerritory.PlanningPlant__c,
            ServiceTerritory.classify__c, ServiceTerritory.ControlWorkcenter__r.WCCode__c, ServiceTerritory.WCID__c,
            Case.SalesOrder__r.ERPPSONo__c, isMachineDown__c,
            OwnerId, Owner.Name, isIFSuccess__c, 
            Noti_Number__c , RepairStartDate__c, RepairEndDate__c, RepairActionValue__c, CauseOfFailureValue__c, CauseOfFailureDetail__c, PendingOrCustomerMatters__c,
            FailureArea__c, FailureAreaValue__c, FailureAreaGroup__c, FailureAreaGroupValue__c, FailurePhenomenon__c, FailurePhenomenonValue__c, FailurePhenomenonDetail__c,
            Case.FailureAreaValue__c, Case.FailureAreaDetailValue__c, Case.FailurePhenomenonValue__c, FM_isDirect__c, IsDirectPaidService__c 
            FROM WorkOrder WHERE Id = :woId];

            User u = [SELECT Id, Name, EmployeeNumber, ERP_Key__c FROM User WHERE ID = :UserInfo.getUserId()];
            //IF_CSPLUS_010
            if(wo.OrderType__c == '201' || wo.OrderType__c == '202' || wo.OrderType__c == '203' || wo.OrderType__c == '204'
            || wo.OrderType__c == '214' || wo.OrderType__c == '215' || wo.OrderType__c == '217' || wo.OrderType__c == '216'
            || wo.OrderType__c == '218' || wo.OrderType__c == '219' || wo.OrderType__c == '220'){

                //하자 유형 코드
                String QMCOD = '';
                switch on wo.OrderType__c {
                    when '201', '202'{
                        QMCOD = '01';
                    }
                    when '204', '218' {
                        QMCOD = '06';
                    }
                    when '214', '215' {
                        QMCOD = '10';
                    }
                    when '203'  {
                        QMCOD = '11';
                    }
                    when '216' {
                        QMCOD = '12';
                    }
                    when '217' {
                        QMCOD = '14';
                    }
                    when '219', '220' {
                        QMCOD = '20';
                    }
                    when else {
                        QMCOD = '19';
                    }
                }

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER i_header = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER();

                Boolean isWoInfo = true;
                if(String.isEmpty(wo.FailureAreaValue__c) 
                || String.isEmpty(wo.FailureAreaGroupValue__c) 
                || String.isEmpty(wo.FailurePhenomenonValue__c)){
                    isWoInfo = false;
                }

                if(isWoInfo){
                    i_header.QMCOD = QMCOD;// 하자유형 코드
                    i_header.WHR_YN= (wo.OrderType__c == '218' || wo.OrderType__c == '219') ? 'Y':'N'; // P-Claim 입고처리 : Y / P - Claim : N
                    i_header.OTGRP = wo.FailureAreaValue__c + '00000'; //고장부위(대) ERPCodeGroup__c => 00000
                    i_header.OTEIL = wo.FailureAreaGroupValue__c.right(2); //고장부위 (중) Value
                    i_header.FEGRP = wo.FailureAreaValue__c + wo.FailureAreaGroupValue__c + '00'; // 대 + 중 + '00'
                    i_header.FECOD = wo.FailurePhenomenonValue__c; //고장현상 Value
                }else{
                    i_header.QMCOD = QMCOD;// 하자유형 코드
                    i_header.WHR_YN= (wo.OrderType__c == '218' || wo.OrderType__c == '219') ? 'Y':'N'; // P-Claim 입고처리 : Y / P - Claim : N
                    i_header.OTGRP = wo.Case.FailureAreaValue__c + '00000'; //고장부위(대) ERPCodeGroup__c => 00000
                    i_header.OTEIL = wo.Case.FailureAreaDetailValue__c.right(2); //고장부위 (중) Value
                    i_header.FEGRP = wo.Case.FailureAreaValue__c + wo.Case.FailureAreaDetailValue__c + '00'; // 대 + 중 + '00'
                    i_header.FECOD = wo.Case.FailurePhenomenonValue__c; //고장현상 Value
                }

                DateTime failureDate = wo.Case.BreakdownDateTime__c != null ? wo.Case.BreakdownDateTime__c : wo.Case.ApplicationDateTime__c;
                i_header.TRBL_DT = failureDate.format('yyyyMMdd'); //'20241101'; //고장일자
                i_header.TRBL_TM = failureDate.format('HH:mm:ss'); //'110000'; //고장시간
                i_header.RECV_DT = wo.Case.ApplicationDateTime__c.format('yyyyMMdd'); //'20241101'; //접수일자
                i_header.RECV_TM = wo.Case.ApplicationDateTime__c.format('HH:mm:ss'); //'120000'; //접수시간
                i_header.LTRMN = wo.FM_RepairRequestDateTime__c.format('yyyyMMdd');//'20241101'; //수리요청일자
                i_header.LTRUR = wo.FM_RepairRequestDateTime__c.format('HH:mm:ss');//'120000'; //수리요청일시

                i_header.QMNAM = wo.Owner.Name; //상담자명(기술상담사)
                i_header.ARBPL = wo.ServiceTerritory.WCCode__c; //워크센터 코드
                i_header.DAUNO ='1'; //작업요구시간(고정값)
                i_header.S_DATE = wo.ScheduledDispatchTime__c.format('yyyyMMdd');//작업시작일자 = 출동예정일시  
                
                i_header.PERNR = wo.Worker__r.StaffNumber__c; //서비스요원 코드
                i_header.TYPBZ = wo.Asset.MachineName__c; //장비 기종
                i_header.SERNR = wo.Asset.SerialNumber; // 장비 호기정보

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER2 i_header_2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_I_HEADER2();
                i_header_2.KUNNR = wo.SoldTo__r.CustomerCode__c; // 고객사 코드
                i_header_2.NAME1 = wo.SoldTo__r.Name;//고객명
                i_header_2.POST_CODE1 = wo.Account.ShippingPostalCode; //우편번호                                       
                i_header_2.CITY1 = wo.Account.ShippingCity;                                    
                i_header_2.STREET = wo.Account.ShippingStreet;                                    
                i_header_2.ERNAM = u.EmployeeNumber; //접수자
                i_header_2.AENAM = u.EmployeeNumber; //변경자

                List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2> t_i_list2 = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2>();
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2 tiItem2 = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST2();
                tiItem2.TEXT = wo.ReceptionDetail__c;
                t_i_list2.add(tiItem2);

                //부품청구 내역 T_I_LIST
                List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST> t_i_list = new List<IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST>();
                List<ProductRequest> proReq = [SELECT Id, Quantity__c, Seq__c, 
                                                TransportsDivision__c, ReturnStatus__c,
                                                ProductType__c, Product__r.ProductCode, 
                                                WorkCenterId__c, WorkCenterId__r.Name
                                                FROM ProductRequest
                                                WHERE WorkOrderId =: woId AND Status='Approved' 
                                                AND IsDealerPortalDelete__c = false 
                                                ORDER BY Seq__c];
                Boolean isSpin = false;
                if(proReq.size()>0){
                    // 청구된 ProductRequest의 대리점 Map
                    Set<Id> dealerIds = new Set<Id>(); 
                    for(ProductRequest pr : proReq){
                        if(String.isNotEmpty(pr.WorkCenterId__c)){
                            dealerIds.add(pr.WorkCenterId__c);
                        }
                    }

                    Map<Id, String> dealerMap = new Map<Id,String>();
                    if(!dealerIds.isEmpty()){
                        List<ServiceTerritory> dealerList = [SELECT Id, ServiceWorkCenter__c, WCCode__c FROM ServiceTerritory WHERE ServiceWorkCenter__c IN : dealerIds];
                        for(ServiceTerritory dealer : dealerList){
                            dealerMap.put(dealer.ServiceWorkCenter__c, dealer.WCCode__c);
                        }
                    }
                    
                    // 대리점점
                    List<String> transportDivisions = new List<String>{'1', '2', '3', '4'};
                    for(ProductRequest pr : proReq){
                        IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST tiItem = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req_T_I_LIST();

                        tiItem.SPIND = String.isNotEmpty(pr.ProductType__c) ? pr.ProductType__c : ''; //스핀들구분 
                        tiItem.RSPOS = '0';// 부품예약순번
                        tiItem.MENGE = String.valueOf(pr.Quantity__c); //수량  
                        tiItem.RSNUM = '0';// 부품예약번호
                        tiItem.POSNR = pr.Seq__c; //순번 
                        tiItem.VSBED = pr.TransportsDivision__c;// 탁송구분
                        tiItem.MATNR = pr.Product__r.ProductCode; //부품번호(품번)
                        tiItem.RETURN_YN = pr.ReturnStatus__c; //폐품반납

                        String tranDiv = ''; //공급구분
                        tiItem.SUPPLY_TP = transportDivisions.contains(pr.TransportsDivision__c) ?  'N' : 'L'; // L:부품부청구(본사) , N:대리점구입(대리점)

                        if(String.isNotEmpty(pr.WorkCenterId__c) && dealerMap.containsKey(pr.WorkCenterId__c)){
                            tiItem.VENDOR = dealerMap.get(pr.WorkCenterId__c);
                        }else{
                            tiItem.VENDOR = '';
                        }

                        if(String.isNotEmpty(pr.ProductType__c)){
                            isSpin = true;
                        }
                        
                        t_i_list.add(tiItem);
                    }
                    
                }

                String warranty = '';
                if(wo.OrderType__c == '202' || wo.OrderType__c == '215' || wo.OrderType__c == '214' || wo.OrderType__c == '218'){
                    warranty = wo.Case.FM_PartsWarranty__c;
                }else{
                    warranty = wo.Case.FM_LaborWarranty__c;
                }

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Req();
                req.I_AUFNR = wo.ServiceOrderNumber__c;
                req.I_EQUNR     = wo.Asset.Name; //장비번호 
                req.I_WARR_YN   = warranty; // 보증여부 ('Y': Under warranty, 'N': Out of warranty) 
                req.I_NEW_CLICK = 'C'; //생성 Flag('I':New create, 'C': Change)
                req.I_SOLDTO = wo.SoldTo__r.CustomerCode__c; // 고객사 코드

                req.I_SAFETY = (wo.OrderType__c == '214' || wo.OrderType__c == '215' || wo.OrderType__c == '218') ? 'X' : '';  //스핀들수리여부   
                req.I_OUT_WARR = (wo.OrderType__c == '202' || wo.OrderType__c == '215') ? 'X' : '';  //'X' : Out warranty    
                req.I_DIRECT = ((wo.OrderType__c == '202' || wo.OrderType__c == '215') && (wo.Worker__r.FM_isDirect__c)) ? 'X' : ''; // 직영유상여부               

                req.I_SKIP_SBOM = 'X'; //S-BOM
                req.I_PART_OUT_WARR = wo.Case.FM_PartsWarranty__c; //부품보증 / 'X' : Out warranty

                if(proReq.size()>0){ req.I_MAT_CLICK = 'Y'; }
                if(wo.OrderType__c == '214' || wo.OrderType__c == '215' || wo.OrderType__c == '218'){ req.I_TASKLIST = wo.SPTask__c; }

                String docType = '';
                if(isSpin) {
                    docType = 'YDOR';
                } else {
                    if(wo.OrderType__c == '201'){
                        docType = 'YDCO';
                    } else if (wo.OrderType__c == '202') {
                        if (warranty == 'N') {
                            docType = 'YDOW';
                        }else {
                            docType = wo.IsDirectPaidService__c ? 'YDOW' : 'YDCO'; 
                        }
                    } else if ( wo.OrderType__c == '215') {
                        docType = 'YDOW'; 
                    }  else if (wo.OrderType__c == '203' || wo.OrderType__c == '204' || wo.OrderType__c == '214' || wo.OrderType__c == '217' || wo.OrderType__c == '218') {
                        docType = 'YDCO';
                    } else if (wo.OrderType__c == '219') {
                        docType='YDVF';
                    } else {
                        docType = 'YDCO';
                    }
                }
                // if(isSpin) { //(유)스핀들 
                //     docType='YDOR';
                // } else if(wo.OrderType__c == '215'){ // 유상SP입고수리
                //     docType='YDOW';
                // } else if(wo.OrderType__c == '219'){ // 유상SP입고수리
                //     docType='YDVF';
                // }  else if(wo.OrderType__c == '220'){ // 유상SP입고수리
                //     docType='YDCO';
                // }  else if(req.I_DIRECT == 'X'){ //직영유상
                //     if(warranty == 'Y'){ //보증내
                //         docType='YDCO';
                //     } else { //보증외
                //         docType='YDOW';
                //     }
                // }else {
                //     docType='YDCO';
                // }
                req.I_DOC_TYPE = docType;// 영업오더유형

                req.I_HEADER = i_header;
                req.I_HEADER2 = i_header_2;
                req.T_I_LIST = t_i_list;
                req.T_I_LIST2 = t_i_list2;


                System.debug('orderTypeCS02 req ::: '+req);
                IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res res = instance.IF_CSPLUS_010(req);
                System.debug('orderTypeCS02 res ::: '+res);

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_010_Res_O_RETURN o_return = res.O_RETURN;

                if(String.isEmpty(res.O_AUFNR)){
                    System.debug('IF_CSPLUS_010 INTERFACE ERROR : '+o_return.MESSAGE);
                    wo.isIFSuccess__c = false;
                }else{
                    wo.isIFSuccess__c = true;
                }
            }else if(wo.OrderType__c == '801' || wo.OrderType__c == '802' || wo.OrderType__c == '803'){//IF_CSPLUS_005 : 납품 후 교육

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req wrapper = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Req();
                wrapper.I_EQUNR     = wo.Asset.Name; //장비번호
                wrapper.I_SOLDTO    = wo.SoldTo__r.CustomerCode__c; //Sold To 고객코드
                wrapper.I_KTEXT     = wo.ReceptionDetail__c; //설명
                wrapper.I_PERNR     = wo.Worker__r.StaffNumber__c; //서비스요원 코드
                wrapper.I_ILART     = wo.OrderType__c; //오더 activity type
                wrapper.I_VAPLZ     = wo.ServiceTerritory.WCCode__c; //워크센터 코드
                wrapper.I_MANAGER   = wo.FM_Contact__c; //요청자명
                wrapper.I_TELF1     = wo.Case.FM_PhoneNumber__c; //업체담당전화
                wrapper.I_GSTRP     = wo.ScheduledDispatchTime__c.format('yyyyMMdd');//시작일시
                wrapper.I_GLTRP     = wo.ScheduledDispatchTime__c.format('yyyyMMdd');//시작일시
                wrapper.I_AUFNR     = wo.ServiceOrderNumber__c;//오더번호
                wrapper.I_PSTLZ     = wo.Account.ShippingPostalCode; //우편번호
                wrapper.I_ADDR1     = wo.Account.ShippingCity; //주소
                wrapper.I_ADDR2     = wo.Account.ShippingStreet; //상세주소
                wrapper.I_SWERKS    = wo.Worker__r.Service_Territory__r.PlanningPlant__c; //Service Plant 

                IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res res = instance.IF_CSPLUS_005(wrapper);  
                System.debug('res :: '+res);

                IF_ERP_WorkOrder_Classes.IF_CSPLUS_005_Res_O_RETURN o_return = res.O_RETURN;
                if(o_return.TYPE != 'S'){
                    System.debug('IF_CSPLUS_005 INTERFACE ERROR : '+o_return.MESSAGE);
                    wo.isIFSuccess__c = false;                                  
                }else{
                    System.debug('doSendSMS ::: '+doSendSMS);
                    wo.isIFSuccess__c = true;
                }

                if(doSendSMS){
                    SendSMS__e smsEvent = new SendSMS__e(
                        WorkOrderId__c = wo.Id
                    );
                    Database.SaveResult sr = EventBus.publish(smsEvent);
                    System.debug('sr ::: '+ sr);
                }
            }else if(wo.OrderType__c == '104'){//설치시운전

                String wcCode = '';
                String brachCode = '';
                if(wo.ServiceTerritory.classify__c == 'W/C'){
                    wcCode = wo.ServiceTerritory.WCCode__c;
                    brachCode = wo.ServiceTerritory.ControlWorkcenter__r.WCCode__c;
                }else{
                    wcCode = wo.ServiceTerritory.WCCode__c;
                    brachCode = wcCode;
                }                                                                                       

                IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Req req = new IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Req();
                req.I_EQUNR          = wo.Asset.Name; // Equipment Number
                req.I_SWERKS         = '184S';        // serviceTerritory Planning Plant
                req.I_ARBPL          = wcCode; // 직영 WorkCenter 코드
                req.I_GSTRP          = wo.ScheduledDispatchTime__c.format('yyyy-MM-dd'); // 출동요청일시
                req.I_PARNR          = wo.Worker__r.StaffNumber__c; //서비스요원 코드
                
                req.I_VBELN     = wo.Case.SalesOrder__r.ERPPSONo__c; //Sales Order Number
                req.I_WADAT     = wo.ScheduledDispatchTime__c.format('yyyy-MM-dd');
                req.I_LFDAT     = wo.ScheduledDispatchTime__c.format('yyyy-MM-dd');
                req.I_VKBUR     = brachCode; 

                req.I_SOLDTO    = wo.SoldTo__r.CustomerCode__c; // Sold To 고객코드
                req.I_AUFNR     = wo.ServiceOrderNumber__c; // Order Number
                
                IF_ERP_InstAndComm instance = new IF_ERP_InstAndComm();
                IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res res = instance.IF_CSPLUS_043(req);
                System.debug('res :: '+res);

                List<IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res_OT_RETURN> ot_return = res.OT_RETURN;
                IF_ERP_InstAndComm_Classes.IF_CSPLUS_043_Res_OT_RETURN o_return = ot_return[0];
                if(o_return.TYPE != 'S'){
                    System.debug('IF_CSPLUS_043 INTERFACE ERROR : '+o_return.MESSAGE);
                    wo.isIFSuccess__c = false;
                }else{
                    wo.isIFSuccess__c = true;
                }
            }else if(wo.OrderType__c == '809' || wo.OrderType__c == '106' || wo.OrderType__c == '103'){//설치검수, 순회서비스, 정기점검
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req req = new IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Req();
                req.I_EQUNR     = wo.Asset.Name;
                req.I_KTEXT     = wo.ReceptionDetail__c;
                req.I_PERNR     = wo.Worker__r.StaffNumber__c;
                req.I_ILART     = wo.OrderType__c;
                req.I_VAPLZ     = wo.ServiceTerritory.WCCode__c;
                req.I_GSTRP     = wo.ScheduledDispatchTime__c.format('yyyyMMdd');
                req.I_KUNUM     = wo.Account.CustomerCode__c;//soldTo
                req.I_AUFNR     = wo.ServiceOrderNumber__c;

                IF_ERP_WorkOrder instance = new IF_ERP_WorkOrder();
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res res = instance.IF_CSPLUS_042(req);

                System.debug('res :: '+res);
                IF_ERP_WorkOrder_Classes.IF_CSPLUS_042_Res_O_RETURN o_return = res.O_RETURN;
                if(o_return.TYPE != 'S'){
                    System.debug('IF_CSPLUS_042 INTERFACE ERROR : '+o_return.MESSAGE);
                    wo.isIFSuccess__c = false;
                }else{
                    wo.isIFSuccess__c = true;
                }
            } 
            //DNSA
            if(wo.PMActivityType__c == 'HS01'){//DNSA

                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_HEADER header = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_HEADER();
                header.AUFNR        = wo.ServiceOrderNumber__c;
                header.QMNUM        = '000'+ wo.Noti_Number__c;
                header.ILART        = '699';
                DateTime failureDate = wo.Case.BreakdownDateTime__c != null ? wo.Case.BreakdownDateTime__c : wo.Case.ApplicationDateTime__c;
                header.FAIL_DT      = failureDate.format('yyyyMMdd'); //고장일자 
                header.FAIL_TM      = failureDate.format('HH:mm:ss'); //고장시간 
                header.QMDAT        = wo.Case.ApplicationDateTime__c.format('yyyyMMdd'); //접수일자     
                header.REG_TIME     = wo.Case.ApplicationDateTime__c.format('HH:mm:ss'); //접수시간
                header.REQUIRE_DAT  = wo.ScheduledDispatchTime__c.format('yyyyMMdd'); //출동일자(수리요청일자)
                header.REQUIRE_TIM  = wo.ScheduledDispatchTime__c.format('HH:mm:ss'); //출동일시(수리요청일시)
                header.ARRVAL_DT    = wo.RepairStartDate__c != null ? String.valueOf(wo.RepairStartDate__c).replace('-', '') : ''; //작업시작일시(도착시간)
                header.FAIL_END_DT  = wo.RepairEndDate__c != null ? String.valueOf(wo.RepairEndDate__c).replace('-', '') : ''; //작업완료시간
                header.REPORTEDBY   = u.EmployeeNumber;
                header.TYPBZ        = wo.Asset.MachineName__c; //장비기종
                header.SERNR        = wo.Asset.SerialNumber; //장비번호
                header.BREAKDOWN    = wo?.isMachineDown__c == true ? 'X' : '';

                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_USERINFO userInfo = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_I_USERINFO();
                userInfo.BNAME      = u.Id;//'CS_DMTA'; // User Name in User Master Record -> LOG 저장용
                userInfo.RNAME      = String.valueOf(u.ERP_Key__c); //User Name in User Master Record -> LOG 저장용
                // userInfo.HIER       = 'A'; //[SS] User Hierrchy (Portal)
                userInfo.NAME1      = wo.SoldTo__r.Name; //고객사 이름
                userInfo.WAERS      = 'USD'; // Currency Key
                userInfo.ARBPL      = '1262215'; //Work Center 코드 고정
                userInfo.KUNN2      = wo.SoldTo__r.CustomerCode__c; //고객번호 
                userInfo.LAND1      = 'US'; // Country Key
                userInfo.REGIO      = 'CA'; // Region (State, Province, County)
                userInfo.WERKS      = '414S'; //Plant 정보 고정
                userInfo.VERAN      = '440'; // Person responsible for the work center
                userInfo.DF_CHK     = 'X'; // Default Check
                userInfo.FOREIGN    = 'X'; // Land Gubun Code
                userInfo.ERDAT      = wo.CreatedDate.format('yyyyMMdd'); //Date on Which Record Was Created ???
                userInfo.ERNAM      = u.EmployeeNumber; // 접수자

                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM> t_claim_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM> ();
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM claim = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_CLAIM();
                claim.CLAIM_SEQ = '0001'; //Claim Seq
                claim.CODE_01 = wo.FailureAreaValue__c; //고장부위(대)
                claim.CODE_03 = wo.FailureAreaGroupValue__c.right(2); //고장부위 (중) Value
                claim.OTGRP = wo.FailureAreaValue__c + '00000'; //고장부위(대) ERPCodeGroup__c => 00000
                claim.OTEIL = wo.FailureAreaGroupValue__c.right(2); //고장부위 (중) Value
                claim.KURZTEXT  = wo.FailureArea__c + ' - ' + wo.FailureAreaGroup__c;
                claim.FEGRP = wo.FailureAreaValue__c + wo.FailureAreaGroupValue__c + '00'; // 대 + 중 + '00'
                claim.FECOD = wo.FailurePhenomenonValue__c; //고장현상 Value
                claim.FETXT = wo.FailurePhenomenonDetail__c; //Notification Item Short Text
                claim.URGRP     = wo.FailureAreaValue__c + wo.FailureAreaGroupValue__c + wo.FailurePhenomenonValue__c; // Code Group - Causes
                claim.URCOD     = wo.CauseOfFailureValue__c; //Cause Code
                claim.URTXT     = wo.CauseOfFailureDetail__c; //Short Text for Cause Code
                claim.MNGRP     = '90000000'; //Code Group - Activities
                claim.MNCOD     = wo.RepairActionValue__c; //Activity Code
                claim.MATXT     = wo.PendingOrCustomerMatters__c;
                t_claim_list.add(claim); 

                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE> t_date_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE> ();
                List<WorkOrderResult__c> whList =  [SELECT Id, Name, WorkOrder__c, WorkCenter__c, ResultType__c, CreatedDate, WorkOrder__r.WorkOrderNumber, 
                                        ServiceAppointment__c, SAKey__c, ServiceResource__c, ServiceResource__r.Name, WorkOrder__r.ServiceOrderNumber__c,
                                        ServiceResource__r.StaffNumber__c, ServiceResource__r.AD_ID__c, WorkDate__c, WorkEndDate__c, WorkStartTime__c, WorkOrder__r.Noti_Number__c,
                                        WorkEndTime__c, WorkTime__c, WorkType__c, Description__c, InitialDefectType__c, InitialDefectDetail__c, 
                                        ActionDetail__c, Note__c, StandardWorkFailureArea__c, StandardWorkItem__c, WorkOrder__r.RepairStartDate__c, WorkOrder__r.RepairEndDate__c,
                                        StandardWorkTime__c, StandardWorkForce__c, IsChangeStandardWork__c, ActualWorkTime__c, 
                                        ActualWorkForce__c, ChangeRequestReason__c, StandardHour__c, ProductNumber__c, 
                                        ProductName__c, IsCause__c, Quantity__c, OverReason__c, InspectionDetail__c,
                                        MainInstallationTime__c, TemporaryInstallationTime__c, FenseAPCCover__c, SemiSplashGuard__c, 
                                        OverTools__c, PMG__c, AAC__c, IsTemporaryInstallationTime__c, IsFenseAPCCover__c, 
                                        IsSemiSplashGuard__c, IsOverTools__c, IsPMG__c, IsAAC__c, EtcTime__c, ReasonOfETC__c, 
                                        IsHoliday__c, TotalInstallationTime__c, ReadinessStatus__c, AirTrip__c, TravelHour__c
                                    FROM WorkOrderResult__c
                                    WHERE ResultType__c = 'WH' AND WorkOrder__c = :woId
                                    ORDER BY SaKey__c, WorkStartTime__c];
                if(whList.size()>0){
                    for(WorkOrderResult__c work : whList){
                        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE t_date = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_DATE();
                        t_date.AUFNR = wo.ServiceOrderNumber__c;
                        t_date.QMNUM = wo.Noti_Number__c;
                        t_date.REP_FR_DT    = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
                        t_date.REP_FR_TM    = work.WorkStartTime__c != null ? String.valueOf(work.WorkStartTime__c).replace('-', '') : '';
                        t_date.REP_TO_DT    = work.WorkDate__c != null ? String.valueOf(work.WorkDate__c).replace('-', '') : '';
                        t_date.REP_TO_TM    = work.WorkEndTime__c != null ? String.valueOf(work.WorkEndTime__c).replace('-', '') : '';
                        t_date.ISMNW        = work.WorkTime__c != null ? work.WorkTime__c : '';
                        t_date.ISMNW_PDK    = work.TravelHour__c != null ? work.TravelHour__c : '';
                        t_date.AIR_TRIP     = work.AirTrip__c != null && work.AirTrip__c == 'Yes' ? 'Y' : 'N';
                        t_date_list.add(t_date);
                    }
                }
                

                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART> t_part_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART> ();
                List<WorkOrderResult__c> ptList =  [SELECT Id, Name, WorkOrder__c, WorkCenter__c, ResultType__c, CreatedDate, WorkOrder__r.WorkOrderNumber, 
                                        ServiceAppointment__c, SAKey__c, ServiceResource__c, ServiceResource__r.Name, WorkOrder__r.ServiceOrderNumber__c,
                                        ServiceResource__r.StaffNumber__c, ServiceResource__r.AD_ID__c, WorkDate__c, WorkEndDate__c, WorkStartTime__c, WorkOrder__r.Noti_Number__c,
                                        WorkEndTime__c, WorkTime__c, WorkType__c, Description__c, InitialDefectType__c, InitialDefectDetail__c, 
                                        ActionDetail__c, Note__c, StandardWorkFailureArea__c, StandardWorkItem__c, WorkOrder__r.RepairStartDate__c, WorkOrder__r.RepairEndDate__c,
                                        StandardWorkTime__c, StandardWorkForce__c, IsChangeStandardWork__c, ActualWorkTime__c, 
                                        ActualWorkForce__c, ChangeRequestReason__c, StandardHour__c, ProductNumber__c, 
                                        ProductName__c, IsCause__c, Quantity__c, OverReason__c, InspectionDetail__c,
                                        MainInstallationTime__c, TemporaryInstallationTime__c, FenseAPCCover__c, SemiSplashGuard__c, 
                                        OverTools__c, PMG__c, AAC__c, IsTemporaryInstallationTime__c, IsFenseAPCCover__c, 
                                        IsSemiSplashGuard__c, IsOverTools__c, IsPMG__c, IsAAC__c, EtcTime__c, ReasonOfETC__c, 
                                        IsHoliday__c, TotalInstallationTime__c, ReadinessStatus__c, AirTrip__c, TravelHour__c
                                    FROM WorkOrderResult__c
                                    WHERE ResultType__c = 'PT' AND WorkOrder__c = :woId
                                    ORDER BY SaKey__c, WorkStartTime__c];

                if(ptList.size()>0){
                    for(WorkOrderResult__c work : ptList){
                        IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART t_part = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_PART();
                        t_part.SEQNO        = '0001';
                        t_part.MATNR        = work.ProductName__c != null ? work.ProductName__c : '';
                        t_part.MENGE        = work.Quantity__c != null ? String.valueOf(work.Quantity__c) : '';
                        t_part.CAUSE_PRT    = work.IsCause__c == true ? 'X' : '';
                        t_part.RETURN_TEXT  = work.Note__c != null ? work.Note__c : '';
                        t_part.AUFNR        = wo.ServiceOrderNumber__c;
                        t_part_list.add(t_part);
                    }
                }


                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP> t_tmp_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_TMP> ();
                List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE> t_file_list = new List<IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req_T_FILE> ();

                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req req = new IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Req();
                req.I_UNAME = 'CS_DMTA';
                req.I_LANGU = 'E';
                req.I_USERINFO = userInfo;
                req.I_HEADER   = header;
                req.T_CLAIM = t_claim_list;
                req.T_DATE  = t_date_list;
                req.T_PART  = t_part_list;
                req.T_TMP = t_tmp_list;
                req.T_FILE = t_file_list;

                IF_ERP_SalesOrder execute = new IF_ERP_SalesOrder();
                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res res = execute.IF_CSPLUS_044(req);
                System.debug('res :: '+res);

                IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res_O_RETURN o_return = res.O_RETURN;
                if(o_return.TYPE != 'S'){
                    System.debug('IF_CSPLUS_044 INTERFACE ERROR : '+o_return.MESSAGE);
                    wo.isIFSuccess__c = false;
                }else{
                    System.debug('WorkORder Number : '+wo.ServiceOrderNumber__c);
                    wo.isIFSuccess__c = true;
                }
            }

            System.debug('WorkORder isIFSuccess__c : '+wo.isIFSuccess__c);
            update wo;

            //알림 전송
            if(!wo.isIFSuccess__c){
                String alertManagerId = [SELECT Id FROM AlertManager__c WHERE Name = 'Service Order ERP Error Notification' AND IsActive__c = TRUE].Id; 
                List<UTIL_Alert.HistoryWrapper> hwlist = new List<UTIL_Alert.HistoryWrapper>();
                UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                notihw.alertID = alertManagerId;
                notihw.targetID = wo.Id;
                notihw.alertType = 'Notification';
                notihw.elementList = new List<String>{wo.ServiceOrderNumber__c};
                notihw.receiverforID = new Set<Id>{wo.OwnerId};
                User owner = [SELECT Id, LanguageLocaleKey FROM User WHERE ID = :wo.OwnerId];
                String lang = owner.LanguageLocaleKey == 'ko'? 'ko' : 'en';
                notihw.alertLanguage = lang;
                System.debug('notihw ::: '+notihw);
                hwList.add(notihw);
                UTIL_Alert.ResultWrapper rw = UTIL_Alert.runAlertEvent(hwList);
                System.debug('Alert Result ::: '+rw);
            }
            

        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
        }
    }


    /*
     * @Description 
     *  - SMS 발송 I/F
     * 
     * @Variable 
     *  - smsWorkOrderIds 	    : sms 전송할 WorkOrder ID
     */
    @future(callout=true)
    public static void sendSMS(Set<Id> smsWorkOrderIds) {
        try {
            List<WorkOrder> smsWorkOrderList = [SELECT Id, CaseId, ScheduledDispatchTime__c, ServiceOrderNumber__c, Worker__r.Name, FM_MachineName__c,
                                                Case.OwnerId, Case.SalesOrder__r.Owner__c, Case.Requester__c, Worker__r.RelatedRecordId
                                                FROM WorkOrder 
                                                WHERE Id IN:smsWorkOrderIds];

            Set<Id> caseIds = new Set<Id>();
            for(WorkOrder obj : smsWorkOrderList){
                if (obj.CaseId != null) {
                    caseIds.add(obj.CaseId);
                }
            }
            Map<Id, Case> caseMap = new Map<Id, Case>(
                [SELECT Id, TicketType__c, InternalTicketType__c, OwnerId, 
                        SalesOrder__r.Owner__r.MobilePhone, SalesOrder__r.Owner__r.Name, SalesOrder__r.Owner__c,
                        Account.Name, Requester__r.Name, Requester__r.MobilePhone, Account.FM_Address__c, ContactPhone__c
                FROM Case 
                WHERE Id IN :caseIds]
            );

            List<IF_BIZ_SMS.T_SMS_DATA> smsList = new List<IF_BIZ_SMS.T_SMS_DATA>();

            Set<Id> userIds = new Set<Id>();
            Set<Id> conIds = new Set<Id>();

            for(WorkOrder obj : smsWorkOrderList){
                Case ticket = caseMap.get(obj.CaseId);
                if (obj.CaseId != null && caseMap.containsKey(obj.CaseId)){
                    userIds.add(ticket.OwnerId);

                    if(String.isNotEmpty(ticket.SalesOrder__r.Owner__c)){
                        userIds.add(ticket.SalesOrder__r.Owner__c);
                    }

                    if(String.isNotEmpty(obj.Worker__r.RelatedRecordId)){
                        userIds.add(obj.Worker__r.RelatedRecordId);
                    }

                    if(String.isNotEmpty(ticket.Requester__c)){
                        conIds.add(ticket.Requester__c);
                    }
                }
            }

            Map<Id, User> userMap = new Map<Id, User>();
            if(userIds.size()>0){
                List<User> userList = [SELECT Id, LanguageLocaleKey, MobilePhone FROM User WHERE ID IN :userIds];
                for(User u : userList){
                    userMap.put(u.Id, u);
                }
            }

            Map<Id, Contact> conMap = new Map<Id, Contact>();
            if(conIds.size()>0){
                List<Contact> conList = [SELECT Id, MobilePhone FROM Contact WHERE ID IN :conIds];
                for(Contact c : conList){
                    conMap.put(c.Id, c);
                }
            }

            List<SMSHistory__c> smsHistoryList = new List<SMSHistory__c>();
            for(WorkOrder obj : smsWorkOrderList){
                if (obj.CaseId != null && caseMap.containsKey(obj.CaseId)) {
                    Case ticket = caseMap.get(obj.CaseId);

                    String requester = ticket.Requester__r.Name == null ? '' : ticket.Requester__r.Name;
                    String requesterPhone = ticket.Requester__r.MobilePhone == null ? '' : ticket.Requester__r.MobilePhone;
                    String scheduledDispatchTime = obj.ScheduledDispatchTime__c == null ? '' : obj.ScheduledDispatchTime__c.format('yyyy.MM.dd');
                    String salesOrderName = ticket.SalesOrder__r.Owner__r.Name == null ? '' : ticket.SalesOrder__r.Owner__r.Name;
                    String salesOrderPhone = ticket.SalesOrder__r.Owner__r.MobilePhone == null ? '' : ticket.SalesOrder__r.Owner__r.MobilePhone;
                    
                    String contentBody = '[납품 후 교육 배정 안내]\n';
                    contentBody += ticket.Account.Name+' ('+requester+', '+requesterPhone+', '+obj.ServiceOrderNumber__c+') 교육이 ';
                    contentBody += obj.Worker__r.Name+'님께 배정 완료되었습니다.\n';
                    contentBody += '(' + scheduledDispatchTime+' / '+obj.FM_MachineName__c+' / '+ticket.Account.FM_Address__c+ ')\n';
                    contentBody += '(판매담당자 '+salesOrderName+'님 '+salesOrderPhone+')\n';

                    System.debug('contentBody>>>'+contentBody);

                    // Ticket Owenr 에게 발송
                    // User owner = [SELECT Id, LanguageLocaleKey, MobilePhone FROM User WHERE ID = :ticket.OwnerId];
                    User owner = userMap.get(ticket.OwnerId);
                    if (owner != null) {
                        // System.debug('Ticket Owner 번호:::'+owner.MobilePhone);
                        if(owner.MobilePhone != null && owner.MobilePhone != ''){
                            IF_BIZ_SMS.T_SMS_DATA sms = new IF_BIZ_SMS.T_SMS_DATA();
                            sms.TRAN_PHONE = String.valueOf(owner.MobilePhone).replace('+82 ', '');     // 수신자 번호
                            sms.TRAN_CALLBACK = '1600-4522';        // 발신자 번호 (콜센터 대표번호)
                            sms.TRAN_MSG = contentBody;             // 본문(\n 으로 다음줄 조절)
                            sms.TRAN_ETC1 = 'CRM';
                            smsList.add(sms);

                            //History 내역 남기기
                            SMSHistory__c smshistory1 = new SMSHistory__c();
                            smshistory1.OutBoundCall__c = '1600-4522';     
                            smshistory1.InboundCall__c = String.valueOf(owner.MobilePhone).replace('+82 ', '');
                            smshistory1.Content__c = contentBody;
                            smshistory1.SendTargetList__c = '내부직원';
                            smshistory1.WorkOrder__c = obj.Id;
                            smsHistoryList.add(smshistory1);
                        }
                    }

                    // Service Order Worker 에게 발송
                    User worker = userMap.get(obj.Worker__r.RelatedRecordId);
                    if (worker != null) {
                        // System.debug('Service Order worker 번호:::' + worker.MobilePhone);
                        if(worker.MobilePhone != null && worker.MobilePhone != ''){
                            IF_BIZ_SMS.T_SMS_DATA sms = new IF_BIZ_SMS.T_SMS_DATA();
                            sms.TRAN_PHONE = String.valueOf(worker.MobilePhone).replace('+82 ', '');     // 수신자 번호
                            sms.TRAN_CALLBACK = '1600-4522';        // 발신자 번호 (콜센터 대표번호)
                            sms.TRAN_MSG = contentBody;             // 본문(\n 으로 다음줄 조절)
                            sms.TRAN_ETC1 = 'CRM';
                            smsList.add(sms);

                            //History 내역 남기기
                            SMSHistory__c smshistory4 = new SMSHistory__c();
                            smshistory4.OutBoundCall__c = '1600-4522';     
                            smshistory4.InboundCall__c = String.valueOf(worker.MobilePhone).replace('+82 ', '');
                            smshistory4.Content__c = contentBody;
                            smshistory4.SendTargetList__c = '작업자';
                            smshistory4.WorkOrder__c = obj.Id;
                            smsHistoryList.add(smshistory4);
                        }
                    }
                    
                    // Sales Order Owner 에게 발송
                    // User salesOwner = [SELECT Id, LanguageLocaleKey, MobilePhone FROM User WHERE ID = :ticket.SalesOrder__r.Owner__c];
                    User salesOwner = userMap.get(ticket.SalesOrder__r.Owner__c);
                    if (salesOwner != null) {
                        // System.debug('Sales Order Owner 번호:::'+salesOwner.MobilePhone);
                        if(salesOwner.MobilePhone != null && salesOwner.MobilePhone != ''){
                            IF_BIZ_SMS.T_SMS_DATA smsSales = new IF_BIZ_SMS.T_SMS_DATA();
                            smsSales.TRAN_PHONE = String.valueOf(salesOwner.MobilePhone).replace('+82 ', '');   // 수신자 번호
                            smsSales.TRAN_CALLBACK = '1600-4522';           // 발신자 번호 (콜센터 대표번호)
                            smsSales.TRAN_MSG = contentBody;                // 본문(\n 으로 다음줄 조절)
                            smsSales.TRAN_ETC1 = 'CRM';
                            smsList.add(smsSales);

                            //History 내역 남기기
                            SMSHistory__c smshistory2 = new SMSHistory__c();
                            smshistory2.OutBoundCall__c = '1600-4522';     
                            smshistory2.InboundCall__c = String.valueOf(salesOwner.MobilePhone).replace('+82 ', '');
                            smshistory2.Content__c = contentBody;
                            smshistory2.SendTargetList__c = '내부직원';
                            smshistory2.WorkOrder__c = obj.Id;
                            smsHistoryList.add(smshistory2);
                        }
                    }

                    // Ticket의 Requester 에게 발송
                    // ContactPhone__c
                    // System.debug('Requester 번호:::'+con.MobilePhone);
                    if(ticket.ContactPhone__c != null && ticket.ContactPhone__c != ''){
                        IF_BIZ_SMS.T_SMS_DATA sms = new IF_BIZ_SMS.T_SMS_DATA();
                        sms.TRAN_PHONE = String.valueOf(ticket.ContactPhone__c).replace('+82 ', '');          // 수신자 번호
                        sms.TRAN_CALLBACK = '1600-4522';           // 발신자 번호 (콜센터 대표번호)
                        sms.TRAN_MSG = contentBody;                // 본문(\n 으로 다음줄 조절)
                        sms.TRAN_ETC1 = 'CRM';
                        smsList.add(sms);
                    } else {
                        Contact con = ticket.Requester__c == null ? null : conMap.get(ticket.Requester__c);
                        if (con != null) {
                        // System.debug('Requester 번호:::'+con.MobilePhone);
                            if(con.MobilePhone != null && con.MobilePhone != ''){
                                IF_BIZ_SMS.T_SMS_DATA sms = new IF_BIZ_SMS.T_SMS_DATA();
                                sms.TRAN_PHONE = String.valueOf(con.MobilePhone).replace('+82 ', '');          // 수신자 번호
                                sms.TRAN_CALLBACK = '1600-4522';           // 발신자 번호 (콜센터 대표번호)
                                sms.TRAN_MSG = contentBody;                // 본문(\n 으로 다음줄 조절)
                                sms.TRAN_ETC1 = 'CRM';
                                smsList.add(sms);

                                //History 내역 남기기
                                SMSHistory__c smshistory3 = new SMSHistory__c();
                                smshistory3.OutBoundCall__c = '1600-4522';     
                                smshistory3.InboundCall__c = String.valueOf(con.MobilePhone).replace('+82 ', '');
                                smshistory3.Content__c = contentBody;
                                smshistory3.SendTargetList__c = '고객';
                                smshistory3.WorkOrder__c = obj.Id;
                                smsHistoryList.add(smshistory3);
                            }
                        }
                        
                    }
                }
            }

            IF_BIZ_SMS.DICCSAP_SEND_SMS_WP send = new IF_BIZ_SMS.DICCSAP_SEND_SMS_WP();
            if (smsList.size() > 0) System.debug(send.DICCSAP_SEND_SMS_M(smsList));
            if (smsHistoryList.size() > 0) insert smsHistoryList;

        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
        }
    }

    /*
     * @Description 
     *  - 내부사용자에게 SMS 발송 I/F
     * 
     * @Variable 
     *  - smsWorkOrderIds 	    : sms 전송할 WorkOrder ID
     */
    @future(callout=true)
    public static void sendInternalRequesterSMS(String smsWorkOrderIds) {
        try {
            List<WorkOrder> smsWorkOrderList = [SELECT Id, CaseId, ScheduledDispatchTime__c, ServiceOrderNumber__c, Worker__r.Name, FM_MachineName__c,
                                                Case.OwnerId, Case.SalesOrder__r.Owner__c, Case.Requester__c, Case.InternalRequester__c
                                                FROM WorkOrder 
                                                WHERE Id =:smsWorkOrderIds];

            Set<Id> caseIds = new Set<Id>();
            for(WorkOrder obj : smsWorkOrderList){
                if (obj.CaseId != null) {
                    caseIds.add(obj.CaseId);
                }
            }
            Map<Id, Case> caseMap = new Map<Id, Case>(
                [SELECT Id, TicketType__c, InternalTicketType__c, OwnerId, 
                        SalesOrder__r.Owner__r.MobilePhone, SalesOrder__r.Owner__r.Name, SalesOrder__r.Owner__c, InternalRequester__c,
                        Account.Name, InternalRequester__r.Name, InternalRequester__r.MobilePhone, Account.FM_Address__c, ContactPhone__c
                FROM Case 
                WHERE Id IN :caseIds]
            );

            List<IF_BIZ_SMS.T_SMS_DATA> smsList = new List<IF_BIZ_SMS.T_SMS_DATA>();

            Set<Id> userIds = new Set<Id>();
            Set<Id> conIds = new Set<Id>();

            for(WorkOrder obj : smsWorkOrderList){
                Case ticket = caseMap.get(obj.CaseId);
                if (obj.CaseId != null && caseMap.containsKey(obj.CaseId)){
                    userIds.add(ticket.OwnerId);
                    if(String.isNotEmpty(ticket.SalesOrder__r.Owner__c)){
                        userIds.add(ticket.SalesOrder__r.Owner__c);
                    }

                    if(String.isNotEmpty(ticket.InternalRequester__c)){
                        conIds.add(ticket.InternalRequester__c);
                    }
                }
            }

            Map<Id, User> userMap = new Map<Id, User>();
            if(userIds.size()>0){
                List<User> userList = [SELECT Id, LanguageLocaleKey, MobilePhone FROM User WHERE ID IN :userIds];
                for(User u : userList){
                    userMap.put(u.Id, u);
                }
            }

            Map<Id, Contact> conMap = new Map<Id, Contact>();
            if(conIds.size()>0){
                List<Contact> conList = [SELECT Id, MobilePhone FROM Contact WHERE ID IN :conIds];
                for(Contact c : conList){
                    conMap.put(c.Id, c);
                }
            }

            List<SMSHistory__c> smsHistoryList = new List<SMSHistory__c>();
            for(WorkOrder obj : smsWorkOrderList){
                if (obj.CaseId != null && caseMap.containsKey(obj.CaseId)) {
                    Case ticket = caseMap.get(obj.CaseId);

                    String requester = ticket.InternalRequester__r.Name == null ? '' : ticket.InternalRequester__r.Name;
                    String requesterPhone = ticket.InternalRequester__r.MobilePhone == null ? '' : ticket.InternalRequester__r.MobilePhone;
                    String scheduledDispatchTime = obj.ScheduledDispatchTime__c == null ? '' : obj.ScheduledDispatchTime__c.format('yyyy.MM.dd');
                    String salesOrderName = ticket.SalesOrder__r.Owner__r.Name == null ? '' : ticket.SalesOrder__r.Owner__r.Name;
                    String salesOrderPhone = ticket.SalesOrder__r.Owner__r.MobilePhone == null ? '' : ticket.SalesOrder__r.Owner__r.MobilePhone;
                    
                    String contentBody = '[설치시운전 배정 안내]\n';
                    contentBody += ticket.Account.Name+' ('+requester+', '+requesterPhone+', '+obj.ServiceOrderNumber__c+') 서비스오더가 ';
                    contentBody += obj.Worker__r.Name+'님께 배정 완료되었습니다.\n';
                    contentBody += '(' + scheduledDispatchTime+' / '+obj.FM_MachineName__c+' / '+ticket.Account.FM_Address__c+ ')\n';
                    contentBody += '(판매담당자 '+salesOrderName+'님 '+salesOrderPhone+')\n';

                    System.debug('contentBody>>>'+contentBody);

                    if(requester != null && requester != '') {
                        IF_BIZ_SMS.T_SMS_DATA sms = new IF_BIZ_SMS.T_SMS_DATA();
                        sms.TRAN_PHONE = String.valueOf(requesterPhone).replace('+82 ', '');          // 수신자 번호
                        // sms.TRAN_PHONE = String.valueOf(con.MobilePhone).replace('+82 ', '');          // 수신자 번호
                        sms.TRAN_CALLBACK = '1600-4522';           // 발신자 번호 (콜센터 대표번호)
                        sms.TRAN_MSG = contentBody;                // 본문(\n 으로 다음줄 조절)
                        sms.TRAN_ETC1 = 'CRM';
                        smsList.add(sms);

                        //History 내역 남기기
                        SMSHistory__c smshistory3 = new SMSHistory__c();
                        smshistory3.OutBoundCall__c = '1600-4522';     
                        smshistory3.InboundCall__c = String.valueOf(requesterPhone).replace('+82 ', '');
                        smshistory3.Content__c = contentBody;
                        smshistory3.SendTargetList__c = '고객';
                        smshistory3.WorkOrder__c = obj.Id;
                        smsHistoryList.add(smshistory3);
                    }
                }
            }

            IF_BIZ_SMS.DICCSAP_SEND_SMS_WP send = new IF_BIZ_SMS.DICCSAP_SEND_SMS_WP();
            if (smsList.size() > 0) System.debug(send.DICCSAP_SEND_SMS_M(smsList));
            if (smsHistoryList.size() > 0) insert smsHistoryList;

        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
        }
    } 

    // Service Order 생성 후 장비 정보 가져오기
    @future(callout=true)
    public static void updateAssetFromERP(String recordId, String status) {

        DN_AssetIFRunController.ResultWrapper result = new DN_AssetIFRunController.ResultWrapper();
        Asset asset = [SELECT Id, Name, IsECUSCahnge__c, Order__c, SalesAgency__c FROM Asset WHERE Id = :recordId LIMIT 1];

        try {
    
            IF_ERP_Material_Classes.IF_CSPLUS_018_Req request = new IF_ERP_Material_Classes.IF_CSPLUS_018_Req();
            IF_ERP_Material_Classes.IF_CSPLUS_018_Req_T_ITEM t_item = new IF_ERP_Material_Classes.IF_CSPLUS_018_Req_T_ITEM();
            t_item.EQUNR = asset.Name;
            request.T_ITEM.add(t_item);
            
            IF_ERP_Material instance = new IF_ERP_Material();
            IF_ERP_Material_Classes.IF_CSPLUS_018_Res response = instance.IF_CSPLUS_018(request);

            result.message = response.O_RETURN.MESSAGE;
            if (response.O_RETURN.TYPE == 'E') {
                result.isSuccess = false;
                asset.IsERPUpdate__c = true;
                asset.ERPUpdateError__c = response.O_RETURN.MESSAGE;
            } else if (response.O_RETURN.TYPE == 'S') {
                if (response.T_ITEM.size() > 0) {
                    asset.IsERPUpdate__c = false;
                    asset.ERPUpdateError__c = '';
                    IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_ITEM ifMaterial = response.T_ITEM[0];

                    // General
                    asset.MachineName__c        = ifMaterial.TYPBZ;
                    asset.Description           = ifMaterial.EQKTX;
                    asset.Material__c           = ifMaterial.MATNR;
                    asset.SerialNumber          = ifMaterial.SERNR;
                    asset.Status                = ifMaterial.TXT04;
                    asset.InternNote__c         = ifMaterial.INTERNAL_NOTE;
                    
                    asset.Class__c              = ifMaterial.IF_CLASS;
                    asset.ObjectType__c         = ifMaterial.EQART;
                    asset.StartUpDate__c        = ifMaterial.INBDT == '0000-00-00'? null: Date.valueOf(ifMaterial.INBDT);
                    asset.AcquisitionDate__c    = ifMaterial.ANSDT == '0000-00-00'? null: Date.valueOf(ifMaterial.ANSDT);
                    asset.ManufacturerCode__c   = ifMaterial.HERST;
        
                    asset.NCType__c             = ifMaterial.M_ATWRT;
                    asset.NCNo__c               = ifMaterial.ATWRT;
                    asset.ManufacturerName__c   = ifMaterial.HERST == '' ? null : ifMaterial.HERST.contains('/') ? ifMaterial.HERST.split('/')[1] : ifMaterial.HERST;
                    asset.ManufCountry__c       = ifMaterial.HERLD;
                    asset.CharValue__c          = ifMaterial.M_ATWRT2;
                    if (ifMaterial.BAUJJ == '' || ifMaterial.BAUMM == '') {
                        asset.ConstrYrMth__c = '';
                    } else {
                        asset.ConstrYrMth__c        = ifMaterial.BAUJJ + '/' + ifMaterial.BAUMM;
                    }
                    asset.InstallationStart__c  = ifMaterial.ZZ_INST_START       == '0000-00-00'? null: Date.valueOf(ifMaterial.ZZ_INST_START);
                    asset.InstallationFinish__c = ifMaterial.ZZ_INST_FINISH      == '0000-00-00'? null: Date.valueOf(ifMaterial.ZZ_INST_FINISH);

                    // asset.SalesAgency__c = ifMaterial.ZI_NAME1;
                    if (ifMaterial.KDAUF != '') {
                        List<Order> orderList = [SELECT Id, RelatedDealer__r.Name, ERPRSONo__c FROM Order WHERE ERPPSONo__c = :ifMaterial.KDAUF];

                        // 변경 로직
                        if(orderList.size() > 1){
                            for(Order order : orderList){
                                if(order.ERPRSONo__c != null){
                                    asset.Order__c          = order.Id;
                                    asset.SalesAgency__c    = order.RelatedDealer__r.Name;
                                    continue;
                                }
                            }
                        }else if(orderList.size() > 0 && orderList[0].RelatedDealer__r.Name != null){
                            asset.Order__c          = orderList[0].Id;
                            asset.SalesAgency__c    = orderList[0].RelatedDealer__r.Name;
                        }
                    }
                    if (status == 'Confirm') {
                        if (ifMaterial.PERSON_RES != '' && ifMaterial.PERSON_RES != '00000000') {
                            String staffNumber = ifMaterial.PERSON_RES.substring(4);
                            List<ServiceResource> srList = [SELECT Id FROM ServiceResource WHERE StaffNumber__c = :staffNumber];
                            asset.InstEngineer__c = srList.size() > 0 ? srList[0].Id : null;
                        } else {
                            asset.InstEngineer__c = null;
                        }

                        if (ifMaterial.RES_MN_WK_CTR != '') {
                            List<ServiceTerritory> wcList = [SELECT Id FROM ServiceTerritory WHERE WCCode__c = :ifMaterial.RES_MN_WK_CTR];
                            asset.InstWorkCenter__c = wcList.size() > 0 ? wcList[0].Id : null;
                        } else {
                            asset.InstWorkCenter__c = null;
                        }
                    }
                    

                    // Warranty
                    asset.WarrantyStartDateWages__c     = ifMaterial.GWLDT   == '0000-00-00'? null : Date.valueOf(ifMaterial.GWLDT);
                    asset.WarrantyEndWages__c           = ifMaterial.GWLEN   == '0000-00-00'? null : Date.valueOf(ifMaterial.GWLEN);
                    asset.WarrantyStartDate__c          = ifMaterial.V_GWLDT == '0000-00-00'? null : Date.valueOf(ifMaterial.V_GWLDT);
                    asset.WarrantyEnd__c                = ifMaterial.V_GWLEN == '0000-00-00'? null : Date.valueOf(ifMaterial.V_GWLEN);
                    asset.Biliing__c                    = ifMaterial.WADAT_IST == '0000-00-00'? 'N' : 'Y';
                    asset.WarrantyMasterLabor__c        = ifMaterial.MGANR == '' ? null : ifMaterial.MGANR;
        
                    // Location
                    asset.Maintplant__c         = ifMaterial.SWERK;
                    asset.PlantSectionCode__c   = ifMaterial.BEBER;
                    asset.PlantSectionName__c   = ifMaterial.BEBER_TXT;
                    if (ifMaterial.LOC_ARBPL != '') {
                        List<ServiceTerritory> wcList = [SELECT Id FROM ServiceTerritory WHERE WCCode__c = :ifMaterial.LOC_ARBPL];
                        asset.WorkCenter__c = wcList.size() > 0 ? wcList[0].Id : null;
                    } else {
                        asset.WorkCenter__c = null;
                    }
        
                    // Organization
                    asset.CompanyCode__c        = ifMaterial.BUKRS;
                    asset.BusinessArea__c       = ifMaterial.GSBER; // Business Area
                    asset.PlanningPlant__c      = ifMaterial.IWERK; // Planning Plant
                    asset.PlannerGrp__c         = ifMaterial.INGRP; // Planner Grp
                    if (ifMaterial.ORG_ARBPL != '') {
                        // WCCode__c
                        List<ServiceTerritory> wcList = [SELECT Id FROM ServiceTerritory WHERE WCCode__c = :ifMaterial.ORG_ARBPL];
                        asset.MainWorkCtr__c = wcList.size() > 0 ? wcList[0].Id : null;
                    } else {
                        asset.MainWorkCtr__c = null;
                    }
        
                    asset.CatalogProfile__c     = ifMaterial.RBNR; // Catalog Profile

                }

                Map<String, String> partnerMap = new Map<String, String>();
                if (response.T_PARTNERS_INFO.size() > 0) {
                    for (IF_ERP_Material_Classes.IF_CSPLUS_018_Res_T_PARTNERS_INFO partner : response.T_PARTNERS_INFO) {
                        if (partner.VTEXT == 'Sold-to party') {
                            partnerMap.put('Sold-to party', String.valueOf(Integer.valueOf(partner.PARNR)));
                        } else if (partner.VTEXT == 'Ship-to party') {
                            partnerMap.put('Ship-to party', String.valueOf(Integer.valueOf(partner.PARNR)));
                        }
                    }

                    List<Account> partnerList = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c IN :partnerMap.values()];
                    Map<String, String> accMap = new Map<String, String>();

                    for (Account acc : partnerList) {
                        accMap.put(acc.CustomerCode__c, acc.Id);
                    }

                    asset.SoldTo__c = accMap.get(partnerMap.get('Sold-to party'));
                    asset.AccountId = accMap.get(partnerMap.get('Ship-to party'));
                } else {
                    asset.SoldTo__c = null;
                    asset.AccountId = null;
                }

                asset.IsERPUpdate__c = false;
                asset.ERPUpdateError__c = '';
                TriggerHandler.bypass('AssetTriggerHandler');
                
                Database.SaveResult sr = Database.update(asset);
                if (sr.isSuccess()) {
                    List<IF_Material__c> materialList = [SELECT Id FROM IF_Material__c WHERE IsComplete__c = false AND EQUNR__c = :asset.Name];
                    if (materialList.size() > 0) {
                        List<IF_Material__c> updateList = new List<IF_Material__c>();
                        for (IF_Material__c material : materialList) {
                            material.IsComplete__c = true;
                            updateList.add(material);
                        }

                        if (updateList.size() > 0) update updateList;
                    }
                }

                TriggerHandler.clearBypass('AssetTriggerHandler');
            }
            
        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
            result.isSuccess = false;
            result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
            asset.IsERPUpdate__c = true;
            asset.ERPUpdateError__c = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
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
            this.newServiceResource 	            = '';
        }
    }



    /**
    * @description WorkOrder 생성시 작업자 전화번호 정보 입력(국내)
    * @operationtype before insert
    * @author Hayeong Min | 2025-06-17 
    * @param List<WorkOrder> newList 
    **/
    private void insertWorkerPhoneNumber(List<WorkOrder> newList) {
        System.debug('insertWorkerPhoneNumber');
        Set<Id> workerIds = new Set<Id>();

        for(WorkOrder wo : newList){
            if(String.isNotEmpty(wo.Worker__c)){
                workerIds.add(wo.Worker__c);
            }
        }

        if(workerIds.size()>0){
            Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>(
                [SELECT Id, Name, PhoneNumber__c FROM ServiceResource WHERE Id IN :workerIds]
            );

            for(WorkOrder wo : newList){
                if(srMap.containsKey(wo.Worker__c)){
                    wo.WorkerPhone__c = srMap.get(wo.Worker__c).PhoneNumber__c;
                }
                System.debug('wo.WorkerPhone__c :: '+wo.WorkerPhone__c);
            }
        }
    }

    /**
    * @description WorkOrder 생성시 상위 Ticket의 Owner의 MobilePhone 정보 입력
    * @operationtype before insert
    * @author Hayeong Min | 2025-06-17 
    * @param List<WorkOrder> newList 
    **/
    private void insertTechPhoneNumber(List<WorkOrder> newList) {
        System.debug('insertTechPhoneNumber');
        Set<Id> caseIds = new Set<Id>();

        for(WorkOrder wo : newList){
            if(String.isNotEmpty(wo.CaseId)){
                caseIds.add(wo.CaseId);
            }
        }

        if(caseIds.size()>0){
            List<Case> ticketList = [SELECT Id, OwnerId FROM Case WHERE Id IN :caseIds];

            Set<Id> ownerIds = new Set<Id>();
            Map<Id, Id> case_user = new Map<Id, Id>();
            for(Case ticket : ticketList){
                if (ticket.OwnerId != null) {
                    case_user.put(ticket.Id, ticket.OwnerId);
                    ownerIds.add(ticket.OwnerId);
                }
            }

            Map<Id, User> ownerMap = new Map<Id, User>();
            if (!ownerIds.isEmpty()) {
                ownerMap = new Map<Id, User>(
                    [SELECT Id, MobilePhone FROM User WHERE Id IN :ownerIds AND MobilePhone != NULL]
                );
            }

            for (WorkOrder wo : newList) {
                if(String.isNotEmpty(wo.CaseId) && ownerMap.containsKey(case_user.get(wo.CaseId))){
                    wo.TechnicalConsultantPhone__c = ownerMap.get(case_user.get(wo.CaseId)).MobilePhone;
                }
                System.debug('wo.TechnicalConsultantPhone__c :: '+wo.TechnicalConsultantPhone__c);
            }
        }
        
    }

    /**
    * @description WorkOrder 생성 시 상위 Ticket의 정보 자동입력
        - Country에 맞춰서 WorkType Mapping
        - 상위 Ticket의 고장정보 Mapping 
        - 상위 Ticket의 접수내용 입력
        - 상위 Ticket의 요청자 정보 입력
        - RPM 정보 장비의 CharValue 입력
    * @operationtype before insert
    * @author Hayeong Min | 2025-06-17 
    * @param List<WorkOrder> newList 
    **/
    private void madeWorkOrderForm(List<WorkOrder> newList) {
        System.debug('madeWorkOrderForm');

        //WorkOrder RecordType ID
        String recType_dns = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WorkOrder_Domestic').getRecordTypeId();
        String recType_dnsa = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WorkOrder_DNSA').getRecordTypeId();

        //WorkType 정보 Mapping
        List<WorkType> wtList = [SELECT Id, Name FROM WorkType];
        Map<String, String> wtMap = new Map<String, String>();
        for (WorkType wt : wtList) {
            wtMap.put(wt.Name, wt.Id);
        }

        //상위 Ticket의 정보 Mapping 
        Set<Id> caseIds = new Set<Id>();

        for(WorkOrder wo : newList){
            if(String.isNotEmpty(wo.CaseId)){
                caseIds.add(wo.CaseId);
            }
        }
        System.debug('caseIds : ' + caseIds);

        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Case> ticketList = [SELECT 
                                    Id, ContactId, Requester__c, FM_Country__c, 
                                    ReceptionDetails__c, FM_PhoneNumber__c, 
                                    OwnerId, Asset.CharValue__c,
                                    FailureArea__c, FailureAreaValue__c, 
                                    FailureAreaDetail__c, FailureAreaDetailValue__c, 
                                    FailurePhenomenon__c, FailurePhenomenonValue__c
                                FROM Case WHERE Id IN :caseIds];

        if(ticketList.size()>0){
            for(Case ticket : ticketList){
                caseMap.put(ticket.Id, ticket);
            }
        }

        //Made WorkOrder Form 
        for (WorkOrder wo : newList) {
            if(caseMap.containsKey(wo.CaseId)){
                Case ticket = caseMap.get(wo.CaseId);

                //상위 Ticket Country 정보(DNS, DNSA) 구분
                wo.Country__c = ticket.FM_Country__c;
                if (ticket.FM_Country__c == 'DNS') {
                    wo.RecordTypeId = recType_dns;
                    wo.WorkTypeId = wtMap.get('Standard');
                } else if (ticket.FM_Country__c == 'DNSA') {
                    wo.RecordTypeId = recType_dnsa;
                    wo.WorkTypeId = wtMap.get('DNSA');
                    wo.Status = 'New'; //DNSA의 경우, 기본 Status는 'New'로 설정
                }

                //상위 Ticket 요청자 정보
                wo.ContactId = ticket.Requester__c;
                wo.PhoneNumberCall__c = ticket.FM_PhoneNumber__c;

                //상위 Ticket 고장정보
                wo.FailureArea__c = ticket.FailureArea__c;
                wo.FailureAreaValue__c = ticket.FailureAreaValue__c;
                wo.FailureAreaGroup__c = ticket.FailureAreaDetail__c;
                wo.FailureAreaGroupValue__c = ticket.FailureAreaDetailValue__c;
                wo.FailurePhenomenon__c = ticket.FailurePhenomenon__c;
                wo.FailurePhenomenonValue__c = ticket.FailurePhenomenonValue__c;

                //접수내용 : 설치검수(809) 오더일 때는 '설치검수요청'으로, 그 외의 오더의 경우 상위 Ticket의 접수내용 자동 입력
                if(wo.OrderType__c == '809'){
                    wo.ReceptionDetail__c = '설치 검수 요청';
                }else{
                    wo.ReceptionDetail__c = ticket.ReceptionDetails__c;
                }

                //RPM 정보 장비의 CharValue 입력
                wo.RPM__c = ticket.Asset.CharValue__c;                
            }
        }
    }

    /**
    * @description WorkOrder 삭제시 연결된 ServiceAppointment/ProductRequest 삭제
    * @operationtype before delete
    * @author Hayeong Min | 2025-06-17 
    * @param List<sObject> dels 
    **/
     private static void delServiceAppointment(List<sObject> dels){
        System.debug('delServiceAppointment');
        List<WorkOrder> delList = (List<WorkOrder>) dels;
        
        Set<Id> workOrderIds = new Set<Id>();
        for(WorkOrder obj : delList){
            workOrderIds.add(obj.Id);
        }

        List<ServiceAppointment> saList = [SELECT ID FROM ServiceAppointment WHERE ParentRecordId IN : workOrderIds];
        if(saList.size()>0) delete saList;

        List<ProductRequest> prList = [SELECT Id FROM ProductRequest WHERE WorkOrderId IN : workOrderIds];
        if(prList.size()>0) delete prList;
    }

    /**
    * @description 설치시운전/설치검수 WorkOrder 생성 시 OrderManagement Update
    * @operationtype after insert
    * @author Hayeong Min | 2025-06-18 
    * @param List<WorkOrder> newList 
    **/
    private void checkInstallrequestOrderType(List<WorkOrder> newList) {
        System.debug('checkInstallrequestOrderType');
        List<WorkOrder> installRun = new List<WorkOrder>();
        List<WorkOrder> installInspection = new List<WorkOrder>();

        for(WorkOrder wo : newList){
            if(wo.OrderType__c == '104'){
                // 설치시운전 생성 시 장비 정보 가져오기
                WorkOrderTriggerHandler.updateAssetFromERP(wo.AssetId, wo.Status);
                if (wo.FM_Receptionist__c != null && wo.FM_Receptionist__c != '') {
                    WorkOrderTriggerHandler.sendInternalRequesterSMS(wo.Id);
                }
                installRun.add(wo);
            }
            if(wo.OrderType__c == '809'){
                installInspection.add(wo);
            }
        }

        if(installRun.size()>0){
            CommonWrapper cw = updateOrderManagement('104', installRun);
        }
        if(installInspection.size()>0){
            CommonWrapper cw = updateOrderManagement('104', installRun);
        }
    }

    /**
    * @description 납품 후 교육 문자발송
    * @operationtype after insert
    * @author 박지영 | 2025-02-26 
    * @param List<WorkOrder> newList 
    **/
    private void sendPostDeliveryTrainingSMS(List<WorkOrder> newList) {
        System.debug('sendPostDeliveryTrainingSMS');
        Set<Id> smsWorkOrderIds = new Set<Id>();

        for(WorkOrder wo : newList){
            if(String.isNotEmpty(wo.CaseId) && wo.Country__c == 'DNS' && wo.TicketType__c == 'Post-delivery training'){
                smsWorkOrderIds.add(wo.Id);
            }
        }

        //2025.02.26 박지영_납품 후 교육 문자발송
        if(smsWorkOrderIds.size() > 0) sendSMS(smsWorkOrderIds);
    }


    /**
    * @description 필드작업자 WorkCenter 값 입력
    * @operationtype before update
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void updateFieldWorker(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateFieldWorker');

        String dnsRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WorkOrder_Domestic').getRecordTypeId();

        Set<Id> fieldWorker = new Set<Id>();
        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);

            if(String.isNotEmpty(wo.FieldWorker__c) && (wo.FieldWorker__c != oldObj.FieldWorker__c)){
                fieldWorker.add(wo.FieldWorker__c);
            }
        }

        Map<Id, Id> wcMap = new Map<Id, Id>();
        if(fieldWorker.size()>0){
            List<ServiceResource> fieldWorkerList = [SELECT Id, Service_Territory__c FROM ServiceResource WHERE ID IN :fieldWorker];
            for(ServiceResource sr : fieldWorkerList){
                wcMap.put(sr.Id, sr.Service_Territory__c);
            }
        }

        if(!wcMap.isEmpty()){
            for(WorkOrder wo : woList){
                WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);
                if(String.isNotEmpty(wo.FieldWorker__c) && (wo.FieldWorker__c != oldObj.FieldWorker__c)){
                    wo.FieldWorkerWC__c =  wcMap.get(wo.FieldWorker__c);
                }
            }
        }
    }

    /**
    * @description PM Activity 유형을 납품 후 교육 정책(803), P-Claim(204, 218) 변경 권한 확인
    * @operationtype before update
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void checkPermission(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('checkPermission');

        String dnsRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WorkOrder_Domestic').getRecordTypeId();

        Set<Id> pclaimIDs = new Set<Id>();
        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);

            if((wo.RecordTypeId == dnsRecordTypeId) && (wo.OrderType__c != oldObj.OrderType__c) 
                && (wo.OrderType__c == '204' || wo.OrderType__c == '218' || wo.OrderType__c == '219' || wo.OrderType__c == '220' || wo.OrderType__c == '803')){
                pclaimIDs.add(wo.Id);
            }
        }

        //납품후교육 정책 & P-Claim은 지정된 사람만 설정 가능
        Set<Id> userIds = new Set<Id>();
        if(pclaimIDs.size()>0){
            String pclaimRule = [SELECT Id FROM AssignmentRule__c WHERE Name = 'P-Claim 사용자' LIMIT 1].Id;
            if(String.isNotEmpty(pclaimRule)){
                List<AssignmentMember__c> pclaimUser = [SELECT Id, User__c FROM AssignmentMember__c WHERE AssignmentRule__c = :pclaimRule];
                for (AssignmentMember__c u : pclaimUser) {
                    userIds.add(u.User__c);
                }
            }else{
                System.debug('There is no [P-Claim 사용자] Assignment Rule...');
            }
        }

        if(userIds.size()>0){
            for (WorkOrder wo : woList) {
                // P-Claim 추가 시, 권한 설정하는 부분 
                if(wo.OrderType__c == '204' || wo.OrderType__c == '218' || wo.OrderType__c == '803'){
                    Boolean isCurrentUserInList = userIds.contains(UserInfo.getUserId());
                    if(!isCurrentUserInList){
                        wo.addError(System.Label.DNS_E_NoCreatePermissionForOrder);
                    }
                }  
            }
        }
    }

    /**
    * @description WorkOrder 필드 자동 입력
        - Status가 Completed될 때 completionTime__c 입력
    * @operationtype before update
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void updateOrderInfo(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateOrderInfo');

        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);

            //완료 시간 입력
            if(wo.Status != oldObj.Status && wo.Status == 'Completed'){
                wo.completionTime__c = System.now();
            }

            //입고수리 내역 정보 변경
            if(wo.ExpectedArrivalDate__c != oldObj.ExpectedArrivalDate__c 
                && wo.ExpectedArrivalDate__c != null){
                wo.Progress__c = 'Scheduled Stock';
            }
            if(wo.DateOfReceipt__c != oldObj.DateOfReceipt__c 
                && wo.DateOfReceipt__c != null){
                wo.Progress__c = 'Under Repair';
            }
            if(wo.CompletionDate__c != oldObj.CompletionDate__c 
                && wo.CompletionDate__c != null){
                wo.Progress__c = 'Repair Completed';
            }

            //PM Activity에 맞게 Order Type 변경
            if(wo.OrderType__c != oldObj.OrderType__c){
                String frontNum = wo.OrderType__c.left(1);
                switch on frontNum{
                    when '1'{
                        wo.PMActivityType__c = 'CS01';
                    }
                    when '2'{
                        wo.PMActivityType__c = 'CS02';
                    }
                    when '8'{
                        wo.PMActivityType__c = 'CS08';
                    }
                    when else{
                        wo.PMActivityType__c = 'HS01';
                    }

                } 
            } 

            //작업자 정보 변경 시 Assigned로 상태 변경
            if ((wo.Worker__c != null) && (oldObj.Worker__c != wo.Worker__c)) {
                wo.Status = 'Assigned';
            }

        }
        
    } 


    /**
    * @description WorkOrder Validation
        - Confirm 된 Service Order I/F 업데이트 필드 수정 불가
        - 직영유상일 때 PM activity가 202 아니면 ERROR Validation
    * @operationtype before update
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void checkValidation(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('checkValidation');

        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);

            //직영유상일 때 PM activity가 202 아니면 ERROR Validation
            if((wo.IsDirectPaidService__c && (wo.OrderType__c != '202'))){
                System.debug('DNS_E_CheckDirectWarranty');
                wo.addError(System.Label.DNS_E_CheckDirectWarranty);
            }

            //Confirm 된 Service Order I/F 업데이트 필드 수정 불가
            if(wo.Status == 'Confirm' || oldObj.Status == 'Confirm'){
                Boolean isIF = isFieldSetChanged(wo, oldObj);
                System.debug('isIF : '+isIF);
                if(isIF){
                    wo.addError(System.Label.DNS_E_ConfirmOrderCannotChange);
                }  
            }
        }    
    } 

    
    /**
    * @description 국내 오더의 경우, 직영유상의 오더일 때 해당 작업자가 직영소속이 아니면 Error Validation
    * @operationtype before update
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void checkIsDirectValidation(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('checkIsDirectValidation');

        Set<Id> workerIds = new Set<Id>();
        for(WorkOrder obj : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(obj.Id);

            if(obj.IsDirectPaidService__c){//직영유상일 때
                workerIds.add(obj.Worker__c);
            }
        } 

        if(workerIds.size()>0){
            Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>(
                [SELECT Id, Name, PhoneNumber__c, Service_Territory__r.isDirect__c FROM ServiceResource WHERE Id IN :workerIds]
            );

            for(WorkOrder wo : woList){
                if(wo.IsDirectPaidService__c && srMap.containsKey(wo.Worker__c) && (!srMap.get(wo.Worker__c).Service_Territory__r.isDirect__c)){
                    wo.addError(System.Label.DNS_E_NoDirectResource);
                }
            }
        }
    } 

    /**
    * @description Migration DATA 중 고장정보가 없는 CS02 데이터 addError(해당 Ticket에 고장정보 없음을 나타내는 에러)
    * @operationtype before update
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - woList : 변경 후 SObject
        - oldMap : 변경 전 SObject
    **/
    private void checkFailureInfo(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('checkFailureInfo');

        Set<Id> caseIds = new Set<Id>();
        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);

            if (!isCSPLUS_010(wo.OrderType__c)) continue;
            System.debug('isCSPLUS_010 :'+isCSPLUS_010(wo.OrderType__c));
            if (!isMissingFailureInfo(wo)) continue;
            System.debug('isMissingFailureInfo :'+isMissingFailureInfo(wo));

            if (String.isNotEmpty(wo.CaseId)) {
                caseIds.add(wo.CaseId);
            } else {
                System.debug('There is no failure information and CaseId in this Service Order...');
            }
        }    

        Set<Id> ticketIds = new Set<Id>();
        if(caseIds.size()>0){
            System.debug('caseIds :'+caseIds);
            List<Case> ticketList = [SELECT Id, FailureAreaValue__c, FailureAreaDetailValue__c, FailurePhenomenonValue__c FROM Case WHERE ID IN :caseIds];
            
            for(Case c : ticketList){
                if(String.isEmpty(c.FailureAreaValue__c) || String.isEmpty(c.FailureAreaDetailValue__c) || String.isEmpty(c.FailurePhenomenonValue__c)){
                    System.debug('There is no failure information in this Ticket...');
                    ticketIds.add(c.Id);
                }
            }
        }

        if(ticketIds.size()>0){
            for(WorkOrder wo : woList){
                WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);

                if (!isCSPLUS_010(wo.OrderType__c)) continue;
                if (!isMissingFailureInfo(wo)) continue;
                if (!ticketIds.contains(wo.CaseId)) continue;
                    wo.addError(System.Label.DNS_E_EnterTicketFailureInfo);           
            } 
        }
    }

    /**
    * @description IF-CSPLUS-010 오더유형 확인
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - orderType : PM Activity Type
    **/
    private Boolean isCSPLUS_010(String orderType) {
        return new Set<String>{'201','202','203','204','214','215','216','217','218'}.contains(orderType);
    }

    /**
    * @description 고장부위 정보 존재 여부 
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - wo : 해당 Service Order
    **/
    private Boolean isMissingFailureInfo(WorkOrder wo) {
        return String.isEmpty(wo.FailureAreaValue__c) 
            || String.isEmpty(wo.FailureAreaGroupValue__c) 
            || String.isEmpty(wo.FailurePhenomenonValue__c);
    }


    /**
    * @description 국내 오더의 작업자 정보 변경 시
        - 작업자 전화번호 Update
        - 직영유상의 오더일 때 해당 작업자가 직영소속이 아니면 Error Validation
    * @operationtype before update
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void updateWorkerInfo(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateWorkerInfo');
        
        String dnsRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WorkOrder_Domestic').getRecordTypeId();
        Set<Id> workerIds = new Set<Id>();
        for(WorkOrder obj : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(obj.Id);

            if(obj.RecordTypeId == dnsRecordTypeId
                && String.isNotEmpty(obj.Worker__c) 
                && (obj.Worker__c != oldObj.Worker__c)){
                workerIds.add(obj.Worker__c);
            }
        }

        if(workerIds.size()>0){
            Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>(
                [SELECT Id, Name, PhoneNumber__c, Service_Territory__c FROM ServiceResource WHERE Id IN :workerIds]
            );

            for(WorkOrder wo : woList){
                if(srMap.containsKey(wo.Worker__c)){
                    wo.WorkerPhone__c = srMap.get(wo.Worker__c).PhoneNumber__c;
                    wo.ServiceTerritoryId = srMap.get(wo.Worker__c).Service_Territory__c;
                }                    
            }
        }
    } 




    /**
    * @description Field Set에 입력한 WorkOrder 필드 수정 시 I/F 업데이트 유무 반환
    * @operationtype after update
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    public static Boolean isFieldSetChanged(SObject newObj, SObject oldObj) {
        Schema.DescribeSObjectResult describeResult = WorkOrder.SObjectType.getDescribe();
        Schema.FieldSet fieldSet = describeResult.fieldSets.getMap().get('UpdateWorkOrder');

        for (Schema.FieldSetMember member : fieldSet.getFields()) {
            String fieldApiName = member.getFieldPath();
            
            Object newVal = newObj.get(fieldApiName);
            Object oldVal = oldObj.get(fieldApiName);
            
            if ((newVal != null && !newVal.equals(oldVal)) ||
                (newVal == null && oldVal != null)) {
                return true; // 하나라도 변경되었으면 true
            }
        }
        return false; 
    }


    /**
    * @description Service Order의 출동요청일시 변경 시, 하위 Service Appointment 정보 수정
    * @operationtype after update
    * @author Hayeong Min | 2025-07-01 
    * @param  List<WorkOrder> woList, Map<Id, WorkOrder> oldMap
    **/
    private void updateServiceAppointement(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateServiceAppointement');

        Map<Id, DateTime> woMap = new Map<Id, DateTime>();
        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);            
            if(wo.ScheduledDispatchTime__c != oldObj.ScheduledDispatchTime__c){
                woMap.put(wo.Id, wo.ScheduledDispatchTime__c);
            }
        }

        if(!woMap.isEmpty()){
            List<ServiceAppointment> saList = [SELECT Id, ParentRecordId, ScheduledDispatchTime__c, SchedStartTime, SchedEndTime 
                                                FROM ServiceAppointment 
                                                WHERE ParentRecordId IN :woMap.keySet()];
            for(ServiceAppointment sa : saList){
                sa.ScheduledDispatchTime__c = woMap.get(sa.ParentRecordId);
                sa.SchedStartTime = woMap.get(sa.ParentRecordId);
                sa.SchedEndTime = woMap.get(sa.ParentRecordId).addHours(4);
            }
            update saList;
        }
    }


    /**
    * @description WorkOrder가 Confirm/Canceled가 되었을 때 상위 Ticket에 엮인 모든 WorkOrder들이 종료되었다면 Ticket을 종결
    * @operationtype after update
    * @author Hayeong Min | 2025-07-01 
    * @param  List<WorkOrder> woList, Map<Id, WorkOrder> oldMap
    **/
    private void updateTicketToClosed(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateTicketToClosed');

        Set<Id> caseIds = new Set<Id>();
        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);
            // Set<Id> caseIds = new Set<Id>();
            if(wo.Status != oldObj.Status && wo.Status == 'Confirm' && wo.CaseId != null){
                caseIds.add(wo.CaseId);
            }
        }

        Set<Id> closedIds = new Set<Id>();//closed 해야 하는 CaseId 목록
        if(caseIds.size()>0){
            closedIds = new Set<Id>(caseIds); // 복사
            //상위 Ticket의 WorkOrder 중 아직 미완료된 WorkOrder 목록
            List<WorkOrder> workOrders = [
                SELECT Id, Status, CaseId
                FROM WorkOrder
                WHERE CaseId IN :caseIds AND (Status != 'Confirm' AND Status !='Canceled')
            ];

            Set<Id> notClosed = new Set<Id>();
            for(WorkOrder obj : workOrders){
                notClosed.add(obj.CaseId);
            }
            System.debug('notClosed ::: '+notClosed);

            //종결되지 않은 오더가 아직 존재하는 Ticket 
            if(notClosed.size()>0){
                // closedIds = new Set<Id>(caseIds); // 복사
                closedIds.removeAll(notClosed);
                System.debug('removeAll closedIds ::: '+closedIds);
            }
        }

        System.debug('closedIds ::: '+closedIds);
        if(closedIds.size()>0){
            List<Case> caseList = [SELECT Id, Status, EndOfReason__c FROM Case WHERE ID IN :closedIds];
            for (Case c : caseList) {
                c.Status = 'Closed';
                c.EndOfReason__c = 'Dispatch Completed';
            }

            update caseList;
        }
    }


    
    /**
    * @description 상위 Ticket의 요청자 정보 변경시, Service Order의 Contact 정보 동기화
    * @operationtype before update
    * @author Hayeong Min | 2025-07-01 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void updateContact(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateContact');

        Set<Id> caseIds = new Set<Id>();
        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);

            if(wo.CaseId != null){
                caseIds.add(wo.CaseId);
            }
        }

        if(caseIds.size()>0){
            //상위 Ticket의 WorkOrder 중 아직 미완료된 WorkOrder 목록
            Map<Id, Case> caseMap = new Map<Id, Case>(
                [SELECT Id, Requester__c FROM Case WHERE Id IN :caseIds]
            );

            List<WorkOrder> woUpdate = new List<WorkOrder>();
            for (WorkOrder wo : woList) {
                if(caseMap.containsKey(wo.CaseId)){
                    wo.ContactId = caseMap.get(wo.CaseId).Requester__c;
                }
            }
        }
        
    }
    
    /**
    * @description Service Order의 작업자 정보 변경 시 하위 Service Appointment의 작업자 정보 Update
    * @operationtype before update
    * @author Hayeong Min | 2025-07-07 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void updateServivceAppointmentData(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateServivceAppointmentData');
        
        String dnsRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WorkOrder_Domestic').getRecordTypeId();

        Set<Id> workerIds = new Set<Id>();
        Map<Id, Id> woMap = new Map<Id, Id>(); //WorkOrder ID, ServiceResource Id
        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);

            //국내 Service Order의 경우, 작업자 정보 변경 시 ServiceAppointment & WorkOrderResult 작업자 정보 Update
            if (wo.RecordTypeId == dnsRecordTypeId && (wo.Worker__c != null) && (oldObj.Worker__c != wo.Worker__c)) {
                workerIds.add(wo.Worker__c);
                woMap.put(wo.Id, wo.Worker__c);
            }
        }
        System.debug('workerIds ::: '+workerIds);    
        System.debug('woMap ::: '+woMap);    

        Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>();
        if(workerIds.size()>0){
            List<ServiceResource> srList = [SELECT Id, RelatedRecordId, Service_Territory__c FROM ServiceResource WHERE Id IN :workerIds];
            for (ServiceResource sr : srList) {
                srMap.put(sr.Id, sr);
            }
        }
        System.debug('srMap ::: '+srMap);
        

        if(!woMap.isEmpty()){
            List<ServiceAppointment> saList = [SELECT Id, ServiceResource__c, ServiceTerritoryId, Collaborator__c, ParentRecordId, OwnerId
                                                    FROM ServiceAppointment 
                                                    WHERE ParentRecordId IN :woMap.keySet() 
                                                    AND WorkerType__c = 'Service Resource (Main)' 
                                                    AND Collaborator__c = null];
            if(saList.size()>0){
                for(ServiceAppointment sa : saList){
                    if(srMap.containsKey(woMap.get(sa.ParentRecordId))){
                        System.debug('변경될 Worker 정보 :: '+srMap.get(woMap.get(sa.ParentRecordId)));
                        sa.ServiceResource__c = srMap.get(woMap.get(sa.ParentRecordId)).Id;
                        sa.ServiceTerritoryId = srMap.get(woMap.get(sa.ParentRecordId)).Service_Territory__c;
                        sa.OwnerId = srMap.get(woMap.get(sa.ParentRecordId)).RelatedRecordId;
                    }
                }

                System.debug('ServiceAppointment OwnerId Changed..');
                update saList;
            }
        }
    } 


    /**
    * @description Service Order의 작업자 정보 변경 시 하위 Service Order Result의 작업자 정보 Update
    * @operationtype before update
    * @author Hayeong Min | 2025-07-07 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void updateWorkorderResultData(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateWorkorderResultData');
        
        String dnsRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WorkOrder_Domestic').getRecordTypeId();

        Set<Id> woIds = new Set<Id>();
        Map<Id, ServiceResourceWarpper> wo_srMap = new Map<Id, ServiceResourceWarpper>(); 
        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);

            //국내 Service Order의 경우, 작업자 정보 변경 시 ServiceAppointment & WorkOrderResult 작업자 정보 Update
            if (wo.RecordTypeId == dnsRecordTypeId && (wo.Worker__c != null) && (oldObj.Worker__c != wo.Worker__c)) {
                woIds.add(wo.Id);

                ServiceResourceWarpper srwrapper = new ServiceResourceWarpper();
                srwrapper.oldServiceResource = oldObj.Worker__c;
                srwrapper.newServiceResource = wo.Worker__c;
                wo_srMap.put(wo.Id, srwrapper);
            }
        }
        System.debug('woIds ::: '+woIds);    
        System.debug('wo_srMap ::: '+wo_srMap);    

        if(woIds.size()>0){
            List<WorkOrderResult__c> wrList = [SELECT Id, ServiceResource__c, WorkOrder__c FROM WorkOrderResult__c WHERE WorkOrder__c IN : woIds];
            if(wrList.size()>0){
                for(WorkOrderResult__c wr : wrList){
                    if(wo_srMap.containsKey(wr.WorkOrder__c) && wr.ServiceResource__c == wo_srMap.get(wr.WorkOrder__c).oldServiceResource){
                        wr.ServiceResource__c = wo_srMap.get(wr.WorkOrder__c).newServiceResource;
                        System.debug('wrList.get(wr.WorkOrder__c).newServiceResource ::: '+wo_srMap.get(wr.WorkOrder__c).newServiceResource);
                        System.debug('wr.ServiceResource__c ::: '+wr.ServiceResource__c);
                    }
                }
                update wrList;
            }
        }
    } 


    /**
    * @description 재배정된 Service Order의 하위 Service Appointment 상태 Assigned로 Update
    * @operationtype after update
    * @author Hayeong Min | 2025-07-07 
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void updateAssignedData(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateAssignedData');
        
        String dnsRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WorkOrder_Domestic').getRecordTypeId();

        Set<Id> woIds = new Set<Id>();
        Map<Id, List<ServiceAppointment>> wo_saMap = new Map<Id, List<ServiceAppointment>>();
        for(WorkOrder wo : woList){
            WorkOrder oldObj = (WorkOrder) oldMap.get(wo.Id);

            //국내 Service Order의 경우, 작업자 정보 변경 시 ServiceAppointment & WorkOrderResult 작업자 정보 Update
            if (wo.RecordTypeId == dnsRecordTypeId && wo.Status == 'Assigned') {
                woIds.add(wo.Id);
            }
        }
        System.debug('woIds ::: '+woIds);    

        if(woIds.size()>0){
            List<ServiceAppointment> saList = [
                SELECT Id, Status, ParentRecordId, WorkerType__c
                FROM ServiceAppointment
                WHERE ParentRecordId IN :woIds 
                AND WorkerType__c = 'Service Resource (Main)'
                AND Status = 'Canceled'
            ];
            
            if(saList.size()>0){
                for(ServiceAppointment sa : saList){
                    sa.Status = 'Assigned';
                }
                update saList;
            }
        }
    }

    /**
    * @description SPTask 변경 시 이전 데이터가 있으면 에러 발생
    * @operationtype before update
    * @author Hayeong Min | 2025-07-16
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void validationSPTask(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('validationSPTask');
        String dnsRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WorkOrder_Domestic').getRecordTypeId();

        Set<Id> workerIds = new Set<Id>();
        Map<Id,String> woMap = new Map<Id, String>();
        for (WorkOrder wo : woList) {
            WorkOrder oldObj = oldMap.get(wo.Id);
            
            if (wo.RecordTypeId == dnsRecordTypeId && (oldObj.SPTask__c != wo.SPTask__c)) {
                woMap.put(wo.Id, wo.SPTask__c);
            }
        }

        if (!woMap.isEmpty()) {
            List<WorkOrderHistory> woHistoryList = [
                SELECT Id, Field, OldValue, WorkOrderId
                FROM WorkOrderHistory
                WHERE WorkOrderId IN :woMap.keySet()
                AND Field = 'SPTask__c'
            ];

            Map<Id, WorkOrder> targetWOMap = new Map<Id, WorkOrder>();
            for (WorkOrder wo : woList) {
                targetWOMap.put(wo.Id, wo);
            }

            for (WorkOrderHistory woHistory : woHistoryList) {
                String newSPTaskId = woMap.get(woHistory.WorkOrderId);
                
                if (String.valueOf(woHistory.OldValue) == String.valueOf(newSPTaskId)) {
                    if (targetWOMap.containsKey(woHistory.WorkOrderId)) {
                        targetWOMap.get(woHistory.WorkOrderId).addError(System.Label.DNS_E_NoUpdateSPTaskForOrder);
                    }
                }
            }
        }
    }

    /**
    * @description PM Activity Type 변경 시 부품청구 있으면 변경 불가
    * @operationtype before update
    * @author Hayeong Min | 2025-07-16
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void validationUpdatePMActivity(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('validationUpdatePMActivity');
        
        String dnsRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName()
                                    .get('WorkOrder_Domestic').getRecordTypeId();

        Set<Id> changedWoIds = new Set<Id>();
        Map<Id, WorkOrder> changedWoMap = new Map<Id, WorkOrder>();

        for (WorkOrder wo : woList) {
            WorkOrder oldObj = oldMap.get(wo.Id);
            if (wo.RecordTypeId == dnsRecordTypeId && oldObj != null && oldObj.OrderType__c != wo.OrderType__c) {
                changedWoIds.add(wo.Id);
                changedWoMap.put(wo.Id, wo);
            }

            if (wo.OrderType__c == '204' && wo.EquipmentWarranty__c.contains('Y')) {
                changedWoIds.clear();
                changedWoMap.clear();
            }
        }

        if (!changedWoIds.isEmpty()) {
            Set<Id> woWithProductRequests = new Set<Id>();
            for (ProductRequest pr : [SELECT WorkOrderId FROM ProductRequest WHERE IsDealerPortalDelete__c = false AND WorkOrderId IN :changedWoIds]) {
                woWithProductRequests.add(pr.WorkOrderId);
            }

            for (Id woId : woWithProductRequests) {
                if (changedWoMap.containsKey(woId)) {
                    changedWoMap.get(woId).addError(System.Label.DNS_E_NoUpdatePMACForOrder);
                }
            }
        }
    }

    /**
    * @description 설치 시운전 서비스 오더 Canceled시 장비 WorkCenter/설치 담당자 제거
    * @operationtype after update
    * @author Hayeong Min | 2025-08-26
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void updateCanceledEquipment(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateCanceledEquipment');

        Set<Id> assetIds = new Set<Id>();
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();
        for (WorkOrder wo : woList) {
            WorkOrder oldObj = oldMap.get(wo.Id);
            if(wo.OrderType__c == '104' && wo.Country__c == 'DNS' && ((oldObj.Status == 'Confirm' && wo.Status == 'Completed') || wo.Status == 'Canceled') && oldObj.Status != wo.Status ){
                if (wo.AssetId != null) {
                    assetIds.add(wo.AssetId);
                }
            }
        }
        List<Asset> assetList = [SELECT Id, InstEngineer__c,WorkCenter__c, InstWorkCenter__c, MainWorkCtr__c FROM Asset WHERE Id IN :assetIds];

        for (Asset a : assetList) {
            a.InstEngineer__c   = null;
            a.InstWorkCenter__c = null;
        }

        if (!assetList.isEmpty()) {
            update assetList;
        }
    }

    /**
    * @description 설치 시운전 서비스 오더 Confirm시 장비 WorkCenter/설치 담당자 추가
    * @operationtype after update
    * @author Hayeong Min | 2025-08-26
    * @param  
        - SObject newObj : 변경 후 SObject
        - SObject oldObj : 변경 전 
    **/
    private void updateConfirmEquipment(List<WorkOrder> woList, Map<Id, WorkOrder> oldMap) {
        System.debug('updateConfirmEquipment');

        Set<Id> assetIds = new Set<Id>();
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();
        for (WorkOrder wo : woList) {
            WorkOrder oldObj = oldMap.get(wo.Id);
            if (wo.OrderType__c == '104' && wo.Country__c == 'DNS' && wo.Status == 'Confirm' && oldObj.Status != wo.Status){
                // 설치시운전 생성 시 장비 정보 가져오기
                WorkOrderTriggerHandler.updateAssetFromERP(wo.AssetId, wo.Status);
            }
        }
    }

}