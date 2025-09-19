/**
 * @description       : CS 포탈 서비스 리포트 & 자체 유상 리포트 
 * @author            : Chungwoo Lee
 * @last modified on  : 05-30-2025
 * @last modified by  : Chungwoo Lee
**/
public without sharing class DN_PortalServiceReportController {

    /**
    * @description CRM 내부 서비스 리포트 조회 시 해당 서비스오더 번호 조회 
    **/
    @AuraEnabled
    public static String getServiceOrderNumber(Id recordId) {
        WorkOrder order = [SELECT ServiceOrderNumber__c FROM WorkOrder WHERE Id = :recordId LIMIT 1];   
        return order.ServiceOrderNumber__c;
    }

    /**
    * @description 로그인된 사용자 확인 
    * @author Chungwoo Lee | 11-12-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> getLoginUserInfo() {
        Map<String, Object> resMap = new Map<String, Object>();
        String workCenter = '';
        Boolean isBranch = false;
        ServiceResource loginUserInfo = new ServiceResource(); 
        
        try {
            if (String.isBlank(UserInfo.getUserId())) {
                workCenter = '';
                resMap.put('flag','warning');
                resMap.put('Message', '로그인 상태 또는 계정을 확인해주세요.');
                return resMap;
            } else {
                loginUserInfo  = [SELECT Id , Name 
                                , Service_Territory__c, Service_Territory__r.Name, AD_ID__c, Service_Territory__r.WCID__c, Service_Territory__r.PlanningPlant__c
                                , RelatedRecord.LanguageLocaleKey
                                , Service_Territory__r.classify__c, AccountId, Account.Name, RelatedRecordId, RelatedRecord.Profile.Name
                                FROM ServiceResource 
                                WHERE RelatedRecordId =: UserInfo.getUserId()
                                LIMIT 1];
            }
            
            if(loginUserInfo == null) {
                resMap.put('loginUserInfo', 'W/C 미등록');
                resMap.put('flag','warning');
                resMap.put('Message', 'This user is not registered as a worker.');
                return resMap;
            }
            resMap.put('loginUserInfo', loginUserInfo);
            resMap.put('flag', 'success');
        } catch (Exception e) {
            System.debug('Error in getLoginUserInfo: ' + e.getMessage());
            resMap.put('flag', 'error');
            resMap.put('Message', 'catch Exception ::: ' + e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 설치 검수 표를 통해 검수 점수 업데이트된 값 동기화
    * @author Chungwoo Lee | 03-07-2025 
    **/
    @AuraEnabled
    public static Integer getUpdateScore(Id recordId) {
        Integer inspectionScore = 0;

        List<LaunchingExcellence__c> launchingExcellenceList = [SELECT Value__c FROM LaunchingExcellence__c WHERE FORMID__c = 'SUM' AND WorkOrder__c =:recordId LIMIT 1];

        if (launchingExcellenceList.isEmpty()) {
            inspectionScore = 0;
        } else {
            LaunchingExcellence__c launchingExcellence = launchingExcellenceList[0];
            inspectionScore = launchingExcellence.Value__c != null ? Integer.valueOf(launchingExcellence.Value__c) : 0;
        }
        

        return inspectionScore;
    }

    /**
    * @description 서비스 리포트 주문 번호 검색 전 Call Out
    **/
    @AuraEnabled
    public static Map<String, Object> searchBeforeCallOut(String orderNumber){
        Map<String, Object> resMap              = new Map<String, Object>();
        DN_PortalServiceWrapper searchService   = new DN_PortalServiceWrapper();

        try {
            List<WorkOrder> workOrderList = new List<WorkOrder>();

            User currentLoginUser = [SELECT Id, IsPortalEnabled FROM User WHERE Id = :userInfo.getUserId()];

            if (!currentLoginUser.IsPortalEnabled) {
                workOrderList = [
                    SELECT Id, OrderType__c, CaseId, Asset.ObjectType__c, AccountId, FM_WorkOrderResult_Template__c, WorkOrderNumber, Status, Asset.Name, ServiceOrderNumber__c,
                    ServiceTerritory.Id, ServiceTerritory.ControlWorkcenter__c, PMActivityType__c
                    FROM WorkOrder
                    WHERE ServiceOrderNumber__c =:orderNumber 
                    LIMIT 1
                ];
            } else {
                workOrderList = [
                    SELECT Id, OrderType__c, CaseId, Asset.ObjectType__c, AccountId, FM_WorkOrderResult_Template__c, WorkOrderNumber, Status, Asset.Name, ServiceOrderNumber__c,
                    ServiceTerritory.Id, ServiceTerritory.ControlWorkcenter__c, PMActivityType__c
                    FROM WorkOrder
                    WHERE ServiceOrderNumber__c =:orderNumber AND Status != 'Canceled'
                    LIMIT 1
                ];
            }

            if (workOrderList.isEmpty()) {
                resMap.put('flag', 'noWorkOrder'); 
                return resMap;
            } else {
                WorkOrder workOrder = workOrderList[0];
                
                // 권한 Check
                Boolean isPortalEnabled = true; // 포탈 유저라 가정해 초기 값으로 true로 설정
                Boolean isPermission = false;
                if (!currentLoginUser.IsPortalEnabled) {
                    // 내부사용자인경우 조회 가능
					searchService.isConfirmed = true;
					isPermission = true;
                    isPortalEnabled = false;
                } else {
					// 파트너사용자인경우
                    System.debug('@@ userInfo.getUserId() : ' + userInfo.getUserId());
					List<ServiceResource> currentWorkcenterUsers = [SELECT Id, Service_Territory__c, Service_Territory__r.WCCode__c, Service_Territory__r.Name, Service_Territory__r.PlanningPlant__c, Service_Territory__r.classify__c, Service_Territory__r.ControlWorkcenter__c, Service_Territory__r.ControlWorkcenter__r.Name,
					RelatedRecordId, RelatedRecord.UserCode__c, RelatedRecord.SalesOrganization__c, RelatedRecord.DistributionChannel__c
					FROM ServiceResource WHERE RelatedRecordId = :userInfo.getUserId() LIMIT 1];
					
                    if (currentWorkcenterUsers.isEmpty()) {
                        resMap.put('flag', 'not Service Resource'); 
                        return resMap;
                    } else {
                        ServiceResource currentWorkcenterUser = currentWorkcenterUsers[0];
                        Set<Id> relatedWorkcenter = new Set<Id>();
                        relatedWorkcenter.add(currentWorkcenterUser.Service_Territory__c);

                        String wcDivision = currentWorkcenterUser.Service_Territory__r.classify__c;
                        String wcCode = currentWorkcenterUser.Service_Territory__r.WCCode__c;
                        String wcPlant = currentWorkcenterUser.Service_Territory__r.PlanningPlant__c;

                        if('184S'.equals(wcPlant)) {
                            // 대전지사(114D), 천안POST(114D1)
                            if('지사'.equals(wcDivision)) {
                                String lv1Code = wcCode.left(4) + '%';
                                for(ServiceTerritory sv : [SELECT Id FROM ServiceTerritory WHERE ControlWorkcenter__r.WCCode__c LIKE :lv1Code]) {
                                    relatedWorkcenter.add(sv.Id);
                                }
                            } else if ('POST'.equals(wcDivision)) {
                                String lv1Code = wcCode;
                                for(ServiceTerritory sv : [SELECT Id FROM ServiceTerritory WHERE ControlWorkcenter__r.WCCode__c = :lv1Code]) {
                                    relatedWorkcenter.add(sv.Id);
                                }
                            }
                        }
                        // 서비스오더 WorkCenter 확인
                        if(relatedWorkcenter.contains(workOrder.ServiceTerritory.Id)) {
                            searchService.isConfirmed = workOrder.Status == 'Confirm' ? true : false;
                            isPermission = true;
                        }
                        System.debug('relatedWorkcenter ::: '+relatedWorkcenter);
                    }
                }
                if (!isPermission) {
                    resMap.put('flag', 'No permission'); 
                    return resMap;
                } else if (workOrder.FM_WorkOrderResult_Template__c == 'RT09') {
                    resMap.put('isPortalEnabled', isPortalEnabled);
                    resMap.put('flag', 'isDNSA');
                } else {

                    DN_PortalServiceReportInterface callOut = new DN_PortalServiceReportInterface();
                    IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res responseData = callOut.interfaceCall054(workOrder.Id, workOrder.FM_WorkOrderResult_Template__c);
                    
                    resMap.put('flag', 'success');
                    resMap.put('responseData', responseData);
                    resMap.put('isPortalEnabled', isPortalEnabled);             
                }
            }
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 서비스 리포트 주문 번호 검색
    * @author Chungwoo Lee | 11-01-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> orderNumberSearch(String orderNumber){
        Map<String, Object> resMap              = new Map<String, Object>();
        DN_PortalServiceWrapper searchService   = new DN_PortalServiceWrapper();
        List<WorkOrderResult__c> searchWorkOrderResultList = new List<WorkOrderResult__c>();
        List<ProductRequest> searchProductRequestList = new List<ProductRequest>();
        List<CommonPart__c> searchCommonPartsList = new List<CommonPart__c>();
        Boolean isTypeCheck     = false;

        try {
            List<WorkOrder> workOrderList = new List<WorkOrder>();

            User currentLoginUser = [SELECT Id, IsPortalEnabled FROM User WHERE Id = :userInfo.getUserId()];

            if (!currentLoginUser.IsPortalEnabled) {
                // 내부사용자
                workOrderList = [
                    SELECT Id, OrderType__c, CaseId, Asset.ObjectType__c, AccountId, FM_WorkOrderResult_Template__c, WorkOrderNumber, Status, Asset.Name, ServiceOrderNumber__c,
                    ServiceTerritory.Id, ServiceTerritory.ControlWorkcenter__c, Case.Campaign__c, Worker__r.RelatedRecordId, Worker__r.Service_Territory__c, Worker__r.Service_Territory__r.WCCode__c
                    FROM WorkOrder
                    WHERE ServiceOrderNumber__c =:orderNumber 
                    LIMIT 1
                ];
            } else {
                // 파트너사용자
                workOrderList = [
                    SELECT Id, OrderType__c, CaseId, Asset.ObjectType__c, AccountId, FM_WorkOrderResult_Template__c, WorkOrderNumber, Status, Asset.Name, ServiceOrderNumber__c,
                    ServiceTerritory.Id, ServiceTerritory.ControlWorkcenter__c, Case.Campaign__c
                    FROM WorkOrder
                    WHERE ServiceOrderNumber__c =:orderNumber AND Status != 'Canceled'
                    LIMIT 1
                ];
            }

            if (workOrderList.isEmpty()) {
                resMap.put('flag', 'noWorkOrder'); 
                return resMap;
            } else {
                WorkOrder workOrder = workOrderList[0];
                
                // 권한 Check
                Boolean isPermission = false;
                if (!currentLoginUser.IsPortalEnabled) {
                    // 내부사용자인경우
                    // Service Order의 작업자이며 확정 or 취소 상태가 아니면 편집 가능
                    // 추가 : DNSA 서비스 오더이며 내부사용자인 경우 확정, 완료, 취소 상태가 아니면 편집 가능
                    // 수정 : 내부 사용자인 경우 Service Order의 작업자의 WorkCenter 소속 유저이면 확정 or 취소 상태를 제외하고 편집 가능
                    Id currentWorkCenter;
                    List<ServiceResource> srList = [ SELECT Service_Territory__c FROM ServiceResource WHERE RelatedRecordId = :UserInfo.getUserId() ];

                    if (!srList.isEmpty()) {
                        currentWorkCenter = srList[0].Service_Territory__c;
                    }

                    // 2025-05-08 메인 작업자가 WCCode__c(114Z) 협력 업체인 경우에도 CS 내부직원이 수정 가능
                    if (WorkOrder.FM_WorkOrderResult_Template__c == 'RT09' && !('Confirm'.equals(workOrder.Status) || 'Canceled'.equals(workOrder.Status) || 'Completed'.equals(workOrder.Status)) ) {
                        searchService.isConfirmed = false;
                    }
                    else if (
                        WorkOrder.FM_WorkOrderResult_Template__c != 'RT09' &&
                        ((workOrder.Worker__r.Service_Territory__c == currentWorkCenter && !('Confirm'.equals(workOrder.Status) || 'Canceled'.equals(workOrder.Status))) || workOrder.Worker__r.Service_Territory__r.WCCode__c == '114Z')
                    ) {
                        searchService.isConfirmed = false;
                    }
                    else {
                        searchService.isConfirmed = true;
                    }

					isPermission = true;

                } else {
					// 파트너사용자인경우
					List<ServiceResource> currentWorkcenterUsers = [SELECT Id, Service_Territory__c, Service_Territory__r.WCCode__c, Service_Territory__r.Name, Service_Territory__r.PlanningPlant__c, Service_Territory__r.classify__c, Service_Territory__r.ControlWorkcenter__c, Service_Territory__r.ControlWorkcenter__r.Name,
					RelatedRecordId, RelatedRecord.UserCode__c, RelatedRecord.SalesOrganization__c, RelatedRecord.DistributionChannel__c
					FROM ServiceResource WHERE RelatedRecordId = :userInfo.getUserId() LIMIT 1];
					
                    if (currentWorkcenterUsers.isEmpty()) {
                        resMap.put('flag', 'not Service Resource'); 
                        return resMap;
                    } else {
                        ServiceResource currentWorkcenterUser = currentWorkcenterUsers[0];
                        Set<Id> relatedWorkcenter = new Set<Id>();
                        relatedWorkcenter.add(currentWorkcenterUser.Service_Territory__c);

                        String wcDivision = currentWorkcenterUser.Service_Territory__r.classify__c;
                        String wcCode = currentWorkcenterUser.Service_Territory__r.WCCode__c;
                        String wcPlant = currentWorkcenterUser.Service_Territory__r.PlanningPlant__c;

                        if('184S'.equals(wcPlant)) {
                            // 대전지사(114D), 천안POST(114D1)
                            if('지사'.equals(wcDivision)) {
                                String lv1Code = wcCode.left(4) + '%';
                                for(ServiceTerritory sv : [SELECT Id FROM ServiceTerritory WHERE ControlWorkcenter__r.WCCode__c LIKE :lv1Code]) {
                                    relatedWorkcenter.add(sv.Id);
                                }
                            } else if ('POST'.equals(wcDivision)) {
                                String lv1Code = wcCode;
                                for(ServiceTerritory sv : [SELECT Id FROM ServiceTerritory WHERE ControlWorkcenter__r.WCCode__c = :lv1Code]) {
                                    relatedWorkcenter.add(sv.Id);
                                }
                            }
                        }
                        System.debug('@@@@@@@@@workOrder :::@@@@@@@@@ : ' + workOrder);
                        // 서비스오더 WorkCenter 확인
                        if(relatedWorkcenter.contains(workOrder.ServiceTerritory.Id)) {
                            if ('414S'.equals(wcPlant)) {
                                searchService.isConfirmed = workOrder.Status == 'Confirm' || workOrder.Status == 'Completed' ? true : false;
                                System.debug('@@@@@@@@@@@@@@@@@@1');
                            } else {
                                searchService.isConfirmed = workOrder.Status == 'Confirm' ? true : false;
                                System.debug('@@@@@@@@@@@@@@@@@@2');
                            }
                            isPermission = true;
                        }
                        System.debug('relatedWorkcenter ::: '+relatedWorkcenter);
                    }
                }
                    
                if (!isPermission) {
                    resMap.put('flag', 'No permission'); 
                    return resMap;
                } else {                    
                    String orderRTNumber = workOrder.FM_WorkOrderResult_Template__c;
                    switch on orderRTNumber {
                        when 'RT01', 'RT03', 'RT06', 'RT07'  {  
                            searchService.templateNumber = orderRTNumber;
                            if (searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber) != null) {
                                searchService = searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber);
                            } 
                        } when 'RT02'     { 
                            searchService.templateNumber = orderRTNumber;
                            String assetName = workOrder.Asset.Name;
                            if (assetName != null) {
                                searchService = getModelInstallInfo(assetName, searchService);
                                
                            }
                            if (searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber) != null) {
                                searchService = searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber);
                            } 
                            
                        } when 'RT04', 'RT05' { 
                            searchService.templateNumber = orderRTNumber;
                            if (orderRTNumber == 'RT04') {
                                isTypeCheck   = true;
                            }
                            if (searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber) != null) {
                                searchService = searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber);
                            } 
                            if (workOrder.Asset.ObjectType__c != null) {
                                List<DN_FailureAreaController.CustomSelectOption> failureAreaList =  getFailureAreaMajor(workOrder.Asset.ObjectType__c);
                                resMap.put('failureAreaList', failureAreaList);
                            }
                        } when 'RT08'     { 
                            searchService.templateNumber = orderRTNumber;
                            searchService.serviceReportInfo.orderType = '필드서비스오더';
                            searchService.serviceReportInfo.workOrderType = '유상 Claim';
                            if (searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber) != null) {
                                searchService = searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber);
                            } 
                        } when 'RT09'     { 
                            searchService.templateNumber = orderRTNumber;
                            if (searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber) != null) {
                                searchService = searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber);
                            } 
                        } when else       { 
                            searchService.templateNumber = '';
                            resMap.put('flag', 'none Template');
                            return resMap;
                        }
                    }
                
                    searchService.workOrderId = workOrder.Id;
                    searchService.workOrderNumber = workOrder.WorkOrderNumber;
                    searchService.serviceOrderNumber = workOrder.ServiceOrderNumber__c;
        
                    if (workOrder.FM_WorkOrderResult_Template__c == 'RT08') {
                        searchService       = searchPaidServiceReportInfo(workOrder, searchService);
                    } else {
                        searchService       = searchServiceReportInfo(workOrder, searchService);
                    }
        
                    if (searchWorkOrderResultList(workOrder.Id, searchService) != null) {
                        searchService = searchWorkOrderResultList(workOrder.Id, searchService);
                    }
        
                    if (!searchProductRequestList(workOrder.Id).isEmpty()) {
                        searchProductRequestList = searchProductRequestList(workOrder.Id);
                        resMap.put('searchProductRequestList', searchProductRequestList);
                    }

                    if (!searchCommonPartsList(workOrder.Case.Campaign__c).isEmpty()) {
                        searchCommonPartsList = searchCommonPartsList(workOrder.Case.Campaign__c);
                        resMap.put('searchCommonPartsList', searchCommonPartsList);
                    }
                    
                    resMap.put('flag', 'success');
                    resMap.put('isTypeCheck', isTypeCheck);
                    resMap.put('searchService', searchService);
                }
            }        
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }
    
    /**
    * @description WorkOrder 기준 Ticket 과 Asset 정보 조회
    * @author Chungwoo Lee | 11-08-2024 
    **/
    private static DN_PortalServiceWrapper searchServiceReportInfo(WorkOrder searchWorkOrder, DN_PortalServiceWrapper wrapper) {
        List<WorkOrder> workOrderList = [ SELECT Id, 
                    WorkOrderNumber, toLabel(OrderType__c) ordertypelabel, ServiceOrderNumber__c, OrderType__c, FM_WorkOrderResult_Template__c, CreatedDate, ConfirmedDate__c, Case.Campaign__c, HECare__c,
                    HasWarrantyDirectManagement__c, toLabel(PMActivityType__c), ServiceTerritoryId, ServiceTerritory.Name, TargetCompletionDate__c, Report_Type__c, RepairStartDate__c, RepairEndDate__c,
                    Asset.MachineName__c, Asset.Name, Asset.ObjectType__c, Case.FM_EquipmentWarranty__c, Asset.InstallDate,
                    FM_Requester__c, Case.FM_PhoneNumber__c, Case.ApplicationDateTime__c, Case.RepairRequestDateTime__c, Case.Description, Case.ReceptionDetails__c, toLabel(Case.FailureStatus__c),
                    Case.Account.Name, Case.Account.Representative__c, Case.Account.Mobile__c, Case.Account.FM_Address__c, Case.Account.Phone, ScheduledDispatchTime__c,Case.FM_AccountPhone__c,
                    FieldManagerName__c, FieldManagerMobilePhone__c, WorkerName__c, WorkerMobilePhone__c, Asset.WarrantyStartDateWages__c, InspectionScore__c, IsSavePortal__c,
                    Asset.FieldManagerName__c, Asset.FieldManagerMobilePhone__c , Asset.WorkerName__c , Asset.WorkerMobilePhone__c, Case.AccountShippingAddress__c,
                    isMachineDown__c, ServiceEngineerName__c, SignatureDate__c, CustomerName__c, CustomerPosition__c, Noti_Number__c, Case.BreakdownDateTime__c, Asset.NCType__c, Asset.NCNo__c,
                    (SELECT CreatedDate FROM ServiceAppointments Order by CreatedDate asc limit 1) 
                FROM WorkOrder
                WHERE Id = :searchWorkOrder.Id LIMIT 1 ];
        if (!workOrderList.isEmpty()) {
            WorkOrder workOrder = workOrderList[0];
            wrapper.serviceOrderNumber                      = workOrder.ServiceOrderNumber__c;
            wrapper.serviceReportInfo.machineName           = workOrder.Asset?.MachineName__c == null ? '' : workOrder.Asset.MachineName__c;
            wrapper.serviceReportInfo.assetName             = workOrder.Asset?.Name == null ? '' : workOrder.Asset.Name;
            wrapper.serviceReportInfo.objectType            = workOrder.Asset?.ObjectType__c == null ? '' : workOrder.Asset.ObjectType__c;
            wrapper.serviceReportInfo.notiNumber            = workOrder.Noti_Number__c == null ? '' : workOrder.Noti_Number__c;
            wrapper.serviceReportInfo.warranty              = workOrder.Case?.FM_EquipmentWarranty__c == null ? '' : workOrder.Case.FM_EquipmentWarranty__c;
            wrapper.serviceReportInfo.installDate           = workOrder.Asset?.WarrantyStartDateWages__c == null ? '' : String.valueOf(workOrder.Asset.WarrantyStartDateWages__c);
            if (workOrder.FM_WorkOrderResult_Template__c == 'RT09') {
                wrapper.serviceReportInfo.orderType             = workOrder.PMActivityType__c == null ? '' : 'History Order';
                if (workOrder.ServiceAppointments != null && !workOrder.ServiceAppointments.isEmpty()) {
                    wrapper.serviceReportInfo.createdDate = workOrder.ServiceAppointments[0].CreatedDate.date();
                }
            } else {
                wrapper.serviceReportInfo.orderType             = workOrder.PMActivityType__c == null ? '' : workOrder.PMActivityType__c;
                wrapper.serviceReportInfo.createdDate           = workOrder.CreatedDate?.Date();
            }
            wrapper.serviceReportInfo.workOrderType         = workOrder.OrderType__c == null ? '' : (String) workOrder.get('ordertypelabel');
            wrapper.serviceReportInfo.workOrderTypeCode     = workOrder.OrderType__c == null ? '' : workOrder.OrderType__c;
            wrapper.serviceReportInfo.warrantyService       = workOrder.HasWarrantyDirectManagement__c;
            wrapper.serviceReportInfo.accountName           = workOrder.Case?.Account?.Name == null ? '' : workOrder.Case.Account.Name;
            wrapper.serviceReportInfo.requester             = workOrder.FM_Requester__c == null ? '' : workOrder.FM_Requester__c;
            wrapper.serviceReportInfo.contactPhone          = workOrder.Case?.FM_PhoneNumber__c == null ? '' : workOrder.Case.FM_PhoneNumber__c;
            wrapper.serviceReportInfo.representative        = workOrder.Case?.Account?.Representative__c == null ? '' : workOrder.Case.Account.Representative__c;
            
            // 납품 후 교육 시 배송처 주소로 변경 2025.04.04
            if (workOrder.FM_WorkOrderResult_Template__c == 'RT06') {
                wrapper.serviceReportInfo.accountAddress        = workOrder.Case?.AccountShippingAddress__c == null ? '' : workOrder.Case.AccountShippingAddress__c;
            } else {
                wrapper.serviceReportInfo.accountAddress        = workOrder.Case?.Account?.FM_Address__c == null ? '' : workOrder.Case.Account.FM_Address__c;
            }

            wrapper.serviceReportInfo.accountTel            = workOrder.Case?.FM_AccountPhone__c == null ? '' : String.valueOf(workOrder.Case.FM_AccountPhone__c);
            wrapper.serviceReportInfo.repairRequestDateTime = workOrder.ScheduledDispatchTime__c == null ? '' : workOrder.ScheduledDispatchTime__c.format('yyyy-MM-dd HH:mm:ss');
            wrapper.serviceReportInfo.ReceptionDetails      = workOrder.Case?.ReceptionDetails__c == null ? '' : workOrder.Case.ReceptionDetails__c;
    
            wrapper.serviceReportInfo.failureStatus         = workOrder.Case?.FailureStatus__c == null ? '' : workOrder.Case.FailureStatus__c;
            wrapper.serviceReportInfo.workCenter            = workOrder.ServiceTerritory?.Name == null ? '' : workOrder.ServiceTerritory.Name;
            wrapper.serviceReportInfo.confirmedDate         = workOrder.ConfirmedDate__c == null ? '' : workOrder.ConfirmedDate__c.format('yyyy-MM-dd HH:mm:ss');

            wrapper.serviceReportInfo.siteManager           = workOrder.FieldManagerName__c != null ? workOrder.FieldManagerName__c : (workOrder.Asset.FieldManagerName__c != null ? workOrder.Asset.FieldManagerName__c : '');
            wrapper.serviceReportInfo.siteManagerPhone      = workOrder.FieldManagerMobilePhone__c != null ? workOrder.FieldManagerMobilePhone__c : (workOrder.Asset.FieldManagerMobilePhone__c != null ? workOrder.Asset.FieldManagerMobilePhone__c : '');
            wrapper.serviceReportInfo.mainWorker            = workOrder.WorkerName__c != null ? workOrder.WorkerName__c : (workOrder.Asset.WorkerName__c != null ? workOrder.Asset.WorkerName__c : '');
            wrapper.serviceReportInfo.mainWorkerPhone       = workOrder.WorkerMobilePhone__c != null ? workOrder.WorkerMobilePhone__c : (workOrder.Asset.WorkerMobilePhone__c != null ? workOrder.Asset.WorkerMobilePhone__c : '');
            wrapper.serviceReportInfo.applicationDateTime   = workOrder.Case?.ApplicationDateTime__c == null ? '' : workOrder.Case.ApplicationDateTime__c.format('yyyy-MM-dd HH:mm:ss');
            wrapper.installTestInfo.isHECareByAsset         = workOrder.HECare__c;
            // 조회되는 WorkOrder 딜러 포탈에서 저장된 적 있는지 유무
            wrapper.isSavePortal = workOrder.IsSavePortal__c;

            // 검수 점수 LaunchingExcellence 오브젝트 통해서 조회
            List<LaunchingExcellence__c> launchingExcellenceList = [SELECT Value__c FROM LaunchingExcellence__c WHERE FORMID__c = 'SUM' AND WorkOrder__c =:workOrder.Id LIMIT 1];
            if (launchingExcellenceList.isEmpty()) {
                wrapper.inspectionScore                 = 0;
            } else {
                LaunchingExcellence__c launchingExcellence = launchingExcellenceList[0];
                wrapper.inspectionScore                 = launchingExcellence.Value__c != null ? Integer.valueOf(launchingExcellence.Value__c) : 0;
            }

            // DNSA 사용 필드
            wrapper.serviceReportInfo.reportType            = workOrder.Report_Type__c != null ? workOrder.Report_Type__c : '';
            wrapper.serviceReportInfo.controllerModel       = workOrder.Asset.NCType__c != null ? workOrder.Asset.NCType__c : '';
            wrapper.serviceReportInfo.controllerSerial      = workOrder.Asset.NCNo__c != null ? workOrder.Asset.NCNo__c : '';

            wrapper.serviceReportInfo.repairStartDate       = workOrder.RepairStartDate__c;
            wrapper.serviceReportInfo.repairEndDate         = workOrder.RepairEndDate__c;
            wrapper.serviceReportInfo.failureDate           = workOrder?.Case?.BreakdownDateTime__c?.format('yyyy-MM-dd HH:mm:ss');

            wrapper.serviceReportInfo.isMachineDown         = workOrder.isMachineDown__c;
            wrapper.serviceReportInfo.serviceEngineerName   = workOrder.ServiceEngineerName__c != null ? workOrder.ServiceEngineerName__c : '';
            wrapper.serviceReportInfo.signatureDate         = workOrder.SignatureDate__c;
            wrapper.serviceReportInfo.customerName          = workOrder.CustomerName__c != null ? workOrder.CustomerName__c : '';
            wrapper.serviceReportInfo.customerPosition      = workOrder.CustomerPosition__c != null ? workOrder.CustomerPosition__c : '';
        }

        return wrapper;
    }

    /**
    * @description 자체 유상 서비스 리포트(Case없음)  조회
    **/
    private static DN_PortalServiceWrapper searchPaidServiceReportInfo(WorkOrder searchWorkOrder, DN_PortalServiceWrapper wrapper) {
        List<WorkOrder> workOrderList = [ SELECT Id, 
                    WorkOrderNumber, toLabel(OrderType__c), FM_WorkOrderResult_Template__c, CreatedDate, ConfirmedDate__c, 
                    HasWarrantyDirectManagement__c, toLabel(PMActivityType__c), ServiceTerritoryId, ServiceTerritory.Name, TargetCompletionDate__c,
                    Asset.MachineName__c, Asset.Name, Asset.ObjectType__c, Asset.InstallDate, Asset.FM_EquipmentWarrantyEquipmentParts__c,
                    Asset.Account.Name, Asset.Account.Representative__c, Asset.Account.Mobile__c, Asset.Account.FM_Address__c, Asset.Account.Phone, Asset.WarrantyStartDateWages__c
                FROM WorkOrder
                WHERE Id = :searchWorkOrder.Id LIMIT 1 ];

        if(!workOrderList.isEmpty()) {
            WorkOrder workOrder = workOrderList[0];
            wrapper.serviceReportInfo.machineName           = workOrder.Asset != null && workOrder.Asset.MachineName__c != null ? workOrder.Asset.MachineName__c : '';
            wrapper.serviceReportInfo.assetName             = workOrder.Asset != null && workOrder.Asset.Name != null ? workOrder.Asset.Name : '';
            wrapper.serviceReportInfo.objectType            = workOrder.Asset != null && workOrder.Asset.ObjectType__c != null ? workOrder.Asset.ObjectType__c : '';
            wrapper.serviceReportInfo.warranty              = workOrder.Asset != null && workOrder.Asset.FM_EquipmentWarrantyEquipmentParts__c != null ? workOrder.Asset.FM_EquipmentWarrantyEquipmentParts__c : '';
            wrapper.serviceReportInfo.installDate           = workOrder.Asset != null && workOrder.Asset.WarrantyStartDateWages__c != null ? String.valueOf(workOrder.Asset.WarrantyStartDateWages__c) : '';
            wrapper.serviceReportInfo.orderType             = workOrder.PMActivityType__c != null  ? workOrder.PMActivityType__c : '';
            wrapper.serviceReportInfo.workOrderType         = workOrder.OrderType__c != null  ? workOrder.OrderType__c : '';
            wrapper.serviceReportInfo.warrantyService       = workOrder.HasWarrantyDirectManagement__c;
            wrapper.serviceReportInfo.accountName           = workOrder.Asset.Account != null ? workOrder.Asset.Account.Name : '';
            wrapper.serviceReportInfo.representative        = workOrder.Asset.Account != null ? workOrder.Asset.Account.Representative__c : '';
            wrapper.serviceReportInfo.accountAddress        = workOrder.Asset.Account != null && workOrder.Asset.Account.FM_Address__c != null ? workOrder.Asset.Account.FM_Address__c : '';
            wrapper.serviceReportInfo.accountTel            = workOrder.Asset.Account != null && workOrder.Asset.Account.Mobile__c != null ? String.valueOf(workOrder.Asset.Account.Mobile__c) : '';
            wrapper.serviceReportInfo.workCenter            = workOrder.ServiceTerritory != null && workOrder.ServiceTerritory.Name != null ? workOrder.ServiceTerritory.Name : '';
            wrapper.serviceReportInfo.confirmedDate         = workOrder.ConfirmedDate__c != null ? workOrder.ConfirmedDate__c.format('yyyy-MM-dd HH:mm:ss') : '';
        }

        return wrapper;
    }

    /**
    * @description WorkOrderNumber 기준 Work Order Result 단일 값 필드 Wrapper
    **/
    private static DN_PortalServiceWrapper searchWorkOrderResultInfo(Id workOrderId, DN_PortalServiceWrapper wrapper, String orderRTNumber) {
        List<WorkOrderResult__c> workOrderResultList = [
            SELECT
            Id, Name, WorkOrder__c, WorkCenter__c, ResultType__c, ActionDetail__c, WorkOrder__r.WorkOrderNumber, WorkOrder__r.InstallTestFinish__c,
            MainInstallationTime__c, IsTemporaryInstallationTime__c, TemporaryInstallationTime__c, IsHoliday__c, 
            SpecificationInstallationTime__c, IsFenseAPCCover__c, IsSemiSplashGuard__c, IsOverTools__c, IsPMG__c, IsAAC__c, IsEtc__c, EtcTime__c, ReasonOfETC__c,
            TotalInstallationTime__c, TotalInputTime__c, ReadinessStatus__c, InspectionDetail__c,
            ResponsibleDepartment__c, TotalWork__c, TotalStandardWork__c, Overtime__c, OverReason__c,
            WorkOrder__r.FieldManagerName__c, WorkOrder__r.FieldManagerMobilePhone__c, WorkOrder__r.WorkerName__c, WorkOrder__r.WorkerMobilePhone__c,
            WorkOrder__r.Asset.InstallationFinish__c, WorkOrder__r.HECare__c, WorkOrder__r.Asset.Name, Worker__c, Worker__r.Name,
            FenseApcCover__c, SemiSplashGuard__c , OverTools__c, PMG__c, AAC__c
            FROM WorkOrderResult__c
            WHERE WorkOrder__c = :workOrderId AND ResultType__c ='COM' LIMIT 1
        ];
        
        if (!workOrderResultList.isEmpty()) {
            WorkOrderResult__c workOrderResult = workOrderResultList[0];
            // 리포트 공통 정보
            wrapper.workOrderResultId   = workOrderResult.Id != null ? workOrderResult.Id : '';
            wrapper.resultType          = workOrderResult.ResultType__c != null ? workOrderResult.ResultType__c : '';
            wrapper.actionDetail        = workOrderResult.ActionDetail__c != null ? workOrderResult.ActionDetail__c : '';

            wrapper.repairHistoryInfo.worker                = workOrderResult.Worker__c != null ? workOrderResult.Worker__r.Name : '';
            wrapper.repairHistoryInfo.workOrderResultId     = workOrderResult.Id;
            wrapper.repairHistoryInfo.resultType            = workOrderResult.ResultType__c;
            wrapper.repairHistoryInfo.responsibleDepartment = workOrderResult.ResponsibleDepartment__c != null ? workOrderResult.ResponsibleDepartment__c : '';
            wrapper.repairHistoryInfo.totalWorkTime         = workOrderResult.TotalWork__c != null ? workOrderResult.TotalWork__c : 0;
            wrapper.repairHistoryInfo.totalStandardWorkTime = workOrderResult.TotalStandardWork__c != null ? workOrderResult.TotalStandardWork__c : 0;
            wrapper.repairHistoryInfo.overWork              = workOrderResult.Overtime__c != null ? workOrderResult.Overtime__c : 0;
            wrapper.repairHistoryInfo.reasonForOrverWork    = workOrderResult.OverReason__c != null ? workOrderResult.OverReason__c : '';

            if (orderRTNumber == 'RT02') {
                // 설치 시운전 정보
                if (workOrderResult.WorkOrder__r.InstallTestFinish__c != null) {
                    wrapper.installTestInfo.installationFinish  = workOrderResult.WorkOrder__r.InstallTestFinish__c;
                }
                wrapper.installTestInfo.workOrderResultId   = workOrderResult.Id;
                wrapper.installTestInfo.resultType          = workOrderResult.ResultType__c;
                wrapper.installTestInfo.isHoliday           = workOrderResult.IsHoliday__c;
                wrapper.installTestInfo.isTemporaryInstall  = workOrderResult.IsTemporaryInstallationTime__c;
                wrapper.installTestInfo.specInstallTime     = workOrderResult.SpecificationInstallationTime__c != null ? workOrderResult.SpecificationInstallationTime__c : 0;
                wrapper.installTestInfo.isFenseApcCover     = workOrderResult.IsFenseAPCCover__c;
                wrapper.installTestInfo.isSemiSplashGuard   = workOrderResult.IsSemiSplashGuard__c;
                wrapper.installTestInfo.isOverTools         = workOrderResult.IsOverTools__c;
                wrapper.installTestInfo.isPMG               = workOrderResult.IsPMG__c;
                wrapper.installTestInfo.isAAC               = workOrderResult.IsAAC__c;
                wrapper.installTestInfo.isEtc               = workOrderResult.IsEtc__c;
                wrapper.installTestInfo.etcTime             = workOrderResult.EtcTime__c != null ? workOrderResult.EtcTime__c : 0;
                wrapper.installTestInfo.reasonOfETC         = workOrderResult.ReasonOfETC__c != null ? workOrderResult.ReasonOfETC__c : '';
                wrapper.installTestInfo.preparationOptions  = workOrderResult.ReadinessStatus__c != null ? workOrderResult.ReadinessStatus__c : '';
                wrapper.installTestInfo.inspectionDetails   = workOrderResult.InspectionDetail__c != null ? workOrderResult.InspectionDetail__c : '';
                wrapper.installTestInfo.totalInstallTime    = workOrderResult.TotalInstallationTime__c != null ? workOrderResult.TotalInstallationTime__c : 0;
                wrapper.installTestInfo.totalInputTime      = workOrderResult.TotalInputTime__c != null ? workOrderResult.TotalInputTime__c : 0;

                wrapper.installTestInfo.mainInstallTime     = workOrderResult.MainInstallationTime__c != null ? workOrderResult.MainInstallationTime__c : wrapper.installTestInfo.mainInstallTime;
                wrapper.installTestInfo.tempInstallTime     = workOrderResult.TemporaryInstallationTime__c != null ? workOrderResult.TemporaryInstallationTime__c : wrapper.installTestInfo.tempInstallTime;

                wrapper.installTestInfo.fenseApcCover       = workOrderResult.FenseAPCCover__c != null ? workOrderResult.FenseAPCCover__c : wrapper.installTestInfo.fenseApcCover;
                wrapper.installTestInfo.semiSplashGuard     = workOrderResult.SemiSplashGuard__c != null ? workOrderResult.SemiSplashGuard__c : wrapper.installTestInfo.semiSplashGuard;
                wrapper.installTestInfo.overTools           = workOrderResult.OverTools__c != null ? workOrderResult.OverTools__c : wrapper.installTestInfo.overTools;
                wrapper.installTestInfo.pmgTime             = workOrderResult.PMG__c != null ? workOrderResult.PMG__c : wrapper.installTestInfo.pmgTime;
                wrapper.installTestInfo.accTime             = workOrderResult.AAC__c != null ? workOrderResult.AAC__c : wrapper.installTestInfo.accTime;
            }

        }
        if (orderRTNumber == 'RT04' || orderRTNumber == 'RT05' || orderRTNumber == 'RT08' || orderRTNumber == 'RT09') {
            List<WorkOrder> workOrderList = [SELECT
                                    Id, WorkOrderNumber,  ResponsibleDepartment__c, RepairStartDate__c, RepairEndDate__c,
                                    FailureArea__c, FailureAreaValue__c, FailureAreaGroup__c, FailureAreaGroupValue__c,
                                    FailurePhenomenon__c, FailurePhenomenonValue__c, FailurePhenomenonDetail__c,
                                    CauseOfFailure__c, CauseOfFailureValue__c, FailureStatusCode__c, FailureStatus__c, RepairActionDetail__c,
                                    RepairAction__c, RepairActionValue__c, PendingOrCustomerMatters__c, CauseOfFailureDetail__c,
                                    DefectDate__c, ReceiptDate__c, ActionCallDate__c, PendingMattersCustomerRequirements__c
                                    FROM WorkOrder WHERE Id =:workOrderId LIMIT 1];
                                    
            if (!workOrderList.isEmpty()) {
                WorkOrder workOrder = workOrderList[0];
                
                wrapper.repairHistoryInfo.defectDate                              = workOrder.DefectDate__c;
                wrapper.repairHistoryInfo.receiptDate                             = workOrder.ReceiptDate__c;
                wrapper.repairHistoryInfo.actionCallDate                          = workOrder.ActionCallDate__c;

                wrapper.repairHistoryInfo.selectedBrokenArea.brokenAreaGroup      = workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c : '';
                wrapper.repairHistoryInfo.selectedBrokenArea.brokenAreaCode       = workOrder.FailureAreaGroupValue__c != null ? workOrder.FailureAreaGroupValue__c : '';
                wrapper.repairHistoryInfo.selectedBrokenArea.failureArea          = workOrder.FailureArea__c != null ? workOrder.FailureArea__c : '';
                wrapper.repairHistoryInfo.selectedBrokenArea.failureAreaDetail    = workOrder.FailureAreaGroup__c != null ? workOrder.FailureAreaGroup__c : '';
                wrapper.repairHistoryInfo.selectedBrokenArea.brokenAreaPart       = workOrder.FailureArea__c != null ? workOrder.FailureArea__c + ' - ' + workOrder.FailureAreaGroup__c : '';
                wrapper.repairHistoryInfo.selectedBrokenArea.phenomenonGroup      = workOrder.FailureAreaValue__c != null ? workOrder.FailureAreaValue__c + workOrder.FailureAreaGroupValue__c + '00' : '';
    
                wrapper.repairHistoryInfo.selectedPhenomenon.phenomenonCode       = workOrder.FailurePhenomenonValue__c != null ? workOrder.FailurePhenomenonValue__c : '';
                wrapper.repairHistoryInfo.selectedPhenomenon.phenomenonPart       = workOrder.FailurePhenomenon__c != null ? workOrder.FailurePhenomenon__c : '';
                wrapper.repairHistoryInfo.selectedPhenomenon.phenomenonDetail     = workOrder.FailurePhenomenonDetail__c != null ? workOrder.FailurePhenomenonDetail__c : '';
                wrapper.repairHistoryInfo.selectedPhenomenon.causeAreaGroup       = workOrder.FailureAreaValue__c != null && workOrder.FailureAreaGroupValue__c != null && workOrder.FailurePhenomenonValue__c != null ?
                                                                                    workOrder.FailureAreaValue__c + workOrder.FailureAreaGroupValue__c + workOrder.FailurePhenomenonValue__c : '';
    
                wrapper.repairHistoryInfo.selectedCauseArea.causeAreaCode         = workOrder.CauseOfFailureValue__c != null ? workOrder.CauseOfFailureValue__c : '';
                wrapper.repairHistoryInfo.selectedCauseArea.causeAreaPart         = workOrder.CauseOfFailure__c != null ? workOrder.CauseOfFailure__c : '';
                wrapper.repairHistoryInfo.selectedCauseArea.causeAreaDetail       = workOrder.CauseOfFailureDetail__c != null ? workOrder.CauseOfFailureDetail__c : '';

                wrapper.repairHistoryInfo.selectedRepairAction.repairActionCode   = workOrder.RepairActionValue__c != null ? workOrder.RepairActionValue__c : '';
                wrapper.repairHistoryInfo.selectedRepairAction.repairActionPart   = workOrder.RepairAction__c != null ? workOrder.RepairAction__c : '';
                wrapper.repairHistoryInfo.selectedRepairAction.repairActionDetail = workOrder.PendingOrCustomerMatters__c != null ? workOrder.PendingOrCustomerMatters__c : '';

                wrapper.repairHistoryInfo.selectedBrokenStatus.brokenStatusCode   = workOrder.FailureStatusCode__c != null ? workOrder.FailureStatusCode__c : '';
                wrapper.repairHistoryInfo.selectedBrokenStatus.brokenStatusPart   = workOrder.FailureStatus__c != null ? workOrder.FailureStatus__c : '';

                wrapper.repairHistoryInfo.responsibleDepartment                   = workOrder.ResponsibleDepartment__c != null ? workOrder.ResponsibleDepartment__c : '';
                wrapper.repairHistoryInfo.pendingOrCustomerMatters                = workOrder.PendingMattersCustomerRequirements__c != null ? workOrder.PendingMattersCustomerRequirements__c : '';
            }               
        } 
        
        return wrapper;
    }

    /**
    * @description WorkOrderResult 작업내역, 초기하자, 표준 공수 리스트 조회
    **/
    private static DN_PortalServiceWrapper searchWorkOrderResultList (Id Id, DN_PortalServiceWrapper wrapper) {
        List<WorkOrderResult__c> workOrderResultList = [SELECT Id, 
                Name, WorkOrder__c, WorkCenter__c, ResultType__c, CreatedDate, WorkOrder__r.WorkOrderNumber, 
                ServiceAppointment__c, ServiceResource__c, ServiceResource__r.Name, WorkDate__c, SAKey__c,
                WorkStartTime__c, WorkEndTime__c, WorkTime__c, WorkType__c, Description__c, TravelHour__c, AirTrip__c,
                InitialDefectType__c, InitialDefectDetail__c, ActionDetail__c, Note__c, WorkOrder__r.OrderType__c,
                StandardWorkFailureArea__c, StandardWorkItem__c, StandardWorkTime__c, StandardWorkForce__c,
                IsChangeStandardWork__c, ActualWorkTime__c, ActualWorkForce__c, ChangeRequestReason__c, StandardHour__c,
                ProductNumber__c, ProductName__c, IsCause__c, Quantity__c,WorkEndDate__c, IsHoliday__c
            FROM WorkOrderResult__c
            WHERE WorkOrder__c = :Id AND ResultType__c !='COM'
            Order By ServiceResource__r.Name , WorkDate__c, WorkStartTime__c 
        ]; // SaKey__c -> ServiceResource__r.Name 순서변경

        if (!workOrderResultList.isEmpty()) {
            wrapper.workList            = new List<DN_PortalServiceWrapper.WorkList>();
            wrapper.defectList          = new List<DN_PortalServiceWrapper.DefectList>();
            wrapper.standardWorkList    = new List<DN_PortalServiceWrapper.StandardWorkList>();
            wrapper.productRequestList  = new List<DN_PortalServiceWrapper.ProductRequestList>();
            for (WorkOrderResult__c wor : workOrderResultList) {
                if (wor.ResultType__c == 'WH') {
                    DN_PortalServiceWrapper.WorkList workItem = new DN_PortalServiceWrapper.WorkList();
                    workItem.worker.Id              = wor.ServiceResource__c;
                    workItem.worker.Name            = wor.ServiceResource__r.Name;

                    workItem.workDate               = wor.WorkDate__c;
                    workItem.workStartTime          = wor.WorkStartTime__c  == null ? null : String.valueOf(wor.WorkStartTime__c);
                    workItem.workEndDate            = wor.WorkEndDate__c;
                    workItem.workEndTime            = wor.WorkEndTime__c    == null ? null : String.valueOf(wor.WorkEndTime__c);
                    workItem.workTime               = wor.WorkTime__c       == null ? null : String.valueOf(wor.WorkTime__c);
                    workItem.workType               = wor.WorkType__c       == null ? '' : wor.WorkType__c;
                    workItem.description            = wor.Description__c    == null ? '' : wor.Description__c;
                    workItem.travelHour             = wor.TravelHour__c     == null ? '' : wor.TravelHour__c;
                    workItem.airTripType            = wor.AirTrip__c        == null ? '' : wor.AirTrip__c;
                    workItem.isHoliday              = wor.IsHoliday__c;

                    workItem.workOrderResultId      = wor.Id;
                    workItem.serviceAppointmentId   = wor.ServiceAppointment__c == null ? '' : wor.ServiceAppointment__c;
                    workItem.saKey                  = wor.SAKey__c == null ? '' : wor.SAKey__c;
                    workItem.resultType             = wor.ResultType__c;

                    wrapper.workList.add(workItem); 
                }
            
                if (wor.resultType__c == 'ITD') {
                    DN_PortalServiceWrapper.DefectList defectItem = new DN_PortalServiceWrapper.DefectList();
                    defectItem.defectType           = wor.InitialDefectType__c == null ? '' : wor.InitialDefectType__c;
                    defectItem.defectDetail         = wor.InitialDefectDetail__c == null ? '' : wor.InitialDefectDetail__c;
                    defectItem.defectAction         = wor.ActionDetail__c == null ? '' : wor.ActionDetail__c;
                    defectItem.note                 = wor.Note__c == null ? '' : wor.Note__c;

                    defectItem.workOrderResultId    = wor.Id;
                    defectItem.resultType           = wor.ResultType__c;

                    wrapper.defectList.add(defectItem); 
                }

                if (wor.resultType__c == 'SWT') {
                    DN_PortalServiceWrapper.StandardWorkList standardWorkItem = new DN_PortalServiceWrapper.StandardWorkList();
                    standardWorkItem.breakDownPart          = wor.StandardWorkFailureArea__c == null ? '' : wor.StandardWorkFailureArea__c;
                    standardWorkItem.standardWorkItem       = wor.StandardWorkItem__c == null ? '' : wor.StandardWorkItem__c;
                    standardWorkItem.standardWorkTime       = wor.StandardWorkTime__c == null ? 0 : wor.StandardWorkTime__c;
                    standardWorkItem.standardWorkPeople     = wor.StandardWorkForce__c == null ? 0 : wor.StandardWorkForce__c;
                    standardWorkItem.isChangeStandardWork   = wor.IsChangeStandardWork__c == null ? false : wor.IsChangeStandardWork__c;
                    standardWorkItem.actualWorkTime         = wor.ActualWorkTime__c == null ? 0 : wor.ActualWorkTime__c;
                    standardWorkItem.actualWorkPeople       = wor.ActualWorkForce__c == null ? 0 : wor.ActualWorkForce__c;
                    standardWorkItem.changeRequestReason    = wor.ChangeRequestReason__c == null ? '' : wor.ChangeRequestReason__c;
                    standardWorkItem.standardHourId         = wor.StandardHour__c == null ? '' : wor.StandardHour__c;

                    standardWorkItem.workOrderResultId      = wor.Id;
                    standardWorkItem.resultType             = wor.ResultType__c;

                    wrapper.standardWorkList.add(standardWorkItem); 
                }

                if (wor.resultType__c == 'PT' && wor.workOrder__r.OrderType__c != '106') {
                    DN_PortalServiceWrapper.ProductRequestList usageItem = new DN_PortalServiceWrapper.ProductRequestList();
                    usageItem.productCode    = wor.ProductNumber__c == null ? '' : wor.ProductNumber__c;
                    usageItem.productName           = wor.ProductName__c == null ? '' : wor.ProductName__c;
                    usageItem.isCause                = wor.IsCause__c == null ? false : wor.IsCause__c;
                    usageItem.quantity               = wor.Quantity__c == null ? 0 : wor.Quantity__c;
                    usageItem.returnNote             = wor.Note__c == null ? '' : wor.Note__c;

                    usageItem.workOrderResultId      = wor.Id;
                    usageItem.resultType             = wor.ResultType__c;

                    wrapper.productRequestList.add(usageItem);
                }
            }
        }

        return wrapper;
    }

    /**
    * @description 부품 사용 내역 목록 조회(Product Request) : 서비스 리포트
    **/
    private static List<ProductRequest> searchProductRequestList(Id workOrderId) {
        List<ProductRequest> productRequestList = [ SELECT Id, Product__r.FM_MaterialDetails__c, Product__r.ProductCode, 
                Product__r.Name, Product__r.Name__c, Quantity__c, DeliveryCompleted__c, Product__r.Unit__c, Status, MENGE_GI__c, PGMNG__c,
                IsCause__c, ShippingCheck__c, ReturnStatus__c, ReturnType__c, Reason1__c, Reason2__c, ReturnNote__c
            FROM ProductRequest
            WHERE Status = 'Approved' AND WorkOrderId = :workOrderId AND IsDealerPortalDelete__c = false AND IsDealerPortalPartition__c = false
        ];
        
        return productRequestList != null ? productRequestList : new List<ProductRequest>();
    }

    /**
    * @description 부품 사용 내역 목록 조회(Common Parts) : 기획/순회서비스
    **/
    private static List<CommonPart__c> searchCommonPartsList(Id campaignId) {
        List<CommonPart__c> commonPartList = [SELECT Id, Product__r.ProductCode, Product__r.FM_MaterialDetails__c, Quantity__c, Note__c 
                                                FROM CommonPart__c 
                                                WHERE Campaign__c = :campaignId];

        return commonPartList != null ? commonPartList : new List<CommonPart__c>();
    }

    /**
    * @description 설치시운전 기종 별 설치시간 데이터 조회
    **/
    private static DN_PortalServiceWrapper getModelInstallInfo (String assetName, DN_PortalServiceWrapper wrapper) {
        
        String modelCode = assetName.split('-')[0];

        List<ModelManager__c> modelManagerList = [SELECT Id, Name, ModelCode__c, Manager__c, HECare__c, ModelCategory__c, 
                TempInstall__c, MainInstall__c, FenseAPCCover__c, SemiSplashGuard__c, ToolUp90__c, OPTNHR4__c, ACC6stUp__c, 
                UserTraining_KR__c, UserTraining_EN__c, Install_KR__c, Install_EN__c, isPortalHECare__c
                FROM ModelManager__c WHERE ModelCode__c =:modelCode LIMIT 1];

        if (!modelManagerList.isEmpty()) {
            ModelManager__c modelManager = modelManagerList[0];

            wrapper.installTestInfo.isHEModel           = modelManager.HECare__c;
            wrapper.installTestInfo.isHECare            = modelManager.isPortalHECare__c;

            wrapper.installTestInfo.mainInstallTime     = modelManager.MainInstall__c != null ? modelManager.MainInstall__c : 0;
            wrapper.installTestInfo.tempInstallTime     = modelManager.TempInstall__c != null ? modelManager.TempInstall__c : 0;

            wrapper.installTestInfo.fenseApcCover       = modelManager.FenseAPCCover__c != null ? modelManager.FenseAPCCover__c : 0;
            wrapper.installTestInfo.semiSplashGuard     = modelManager.SemiSplashGuard__c != null ? modelManager.SemiSplashGuard__c : 0;
            wrapper.installTestInfo.overTools           = modelManager.ToolUp90__c != null ? modelManager.ToolUp90__c : 0;
            wrapper.installTestInfo.pmgTime             = modelManager.OPTNHR4__c != null ? modelManager.OPTNHR4__c : 0;
            wrapper.installTestInfo.accTime             = modelManager.ACC6stUp__c != null ? modelManager.ACC6stUp__c : 0;
            
            wrapper.installTestInfo.totalInstallTime    = modelManager.MainInstall__c != null ? modelManager.MainInstall__c * 1.5 : 0;   
            wrapper.installTestInfo.totalInputTime      = modelManager.MainInstall__c != null ? modelManager.MainInstall__c : 0;   
        }
            
        return wrapper;
    }
    
    /**
    * @description Service Report 저장, 확정 시 Upsert
    **/
    @AuraEnabled
    public static Map<String, Object> upsertServiceReport(Map<String, Object> fieldMap) {
        Map<String, Object> resMap = new Map<String, Object>();
        DN_PortalServiceWrapper searchService   = new DN_PortalServiceWrapper();
        List<ProductRequest> searchProductRequestList = new List<ProductRequest>();
        List<Id> updatedWorkIds = new List<Id>();
        List<Id> syncWorkListIds = new List<Id>();
        List<Map<String, String>> docMapList = new List<Map<String, String>>();
        Asset assetData;
        String assetName = '';
        String modelCode = '';

        Map<Object, Object> worInfo = (Map<Object, Object>) fieldMap.get('workOrderResultData');
        String worId = '';
        if (worInfo != null && worInfo.containsKey('workOrderResultId')) {
            worId = (String) worInfo.get('workOrderResultId');
        }

        String workOrderId = (String) fieldMap.get('workOrderId');

        try {
            System.debug('saveServiceReport fieldMap :::   ' + JSON.serialize(fieldMap));
            
            WorkOrder workOrder = [SELECT Id, AssetId, CaseId, OrderType__c, FM_WorkOrderResult_Template__c, ServiceOrderNumber__c FROM WorkOrder WHERE Id =:workOrderId LIMIT 1];
            String caseId = workOrder.CaseId;
            String orderRTNumber = workOrder.FM_WorkOrderResult_Template__c;
            String orderType = workOrder.OrderType__c;

            Object rawProductRequests = fieldMap.get('productRequests');
            if (rawProductRequests != null) {
                List<Map<Object, Object>> productRequests = new List<Map<Object, Object>>();

                if (rawProductRequests instanceof String) {
                    productRequests = (List<Map<Object, Object>>) JSON.deserializeUntyped((String) rawProductRequests);
                } else if (rawProductRequests instanceof List<Object>) {
                    for (Object item : (List<Object>) rawProductRequests) {
                        productRequests.add((Map<Object, Object>) item);
                    }
                } else {
                    // throw new AuraHandledException('Unsupported data type for productRequests');
                }
    
                if (!productRequests.isEmpty()) {
                    List<ProductRequest> productRequestRecords = new List<ProductRequest>();
    
                    for (Map<Object, Object> productRequest : productRequests) {
                        ProductRequest record = new ProductRequest();
                        record.Id = (String) productRequest.get('Id');
                        record.IsCause__c = (Boolean) productRequest.get('IsCause__c');
                        record.ReturnStatus__c = (String) productRequest.get('ReturnStatus__c') != null ? (String) productRequest.get('ReturnStatus__c') : '';
                        record.ReturnType__c = (String) productRequest.get('ReturnType__c') != null ? (String) productRequest.get('ReturnType__c') : '';
                        record.Reason1__c = (String) productRequest.get('Reason1__c') != null ? (String) productRequest.get('Reason1__c') : '';
                        record.Reason2__c = (String) productRequest.get('Reason2__c') != null ? (String) productRequest.get('Reason2__c') : '';
                        record.ReturnNote__c = (String) productRequest.get('ReturnNote__c') != null ? (String) productRequest.get('ReturnNote__c') : '';
                        productRequestRecords.add(record);
                    }
    
                    if (!productRequestRecords.isEmpty()) {
                        update productRequestRecords;
                    }
                }
            }
            
            List<Object> workList = (List<Object>) fieldMap.get('workList');
            List<Object> defectList = (List<Object>) fieldMap.get('defectList');
            List<Object> standardWorkList = (List<Object>) fieldMap.get('standardWorkList');

            Map<Object, Object> workOrderResultInfo    = (Map<Object, Object>) fieldMap.get('workOrderResultData');

            String installationFinish   = (String) workOrderResultInfo.get('installationFinish') != null ? (String) workOrderResultInfo.get('installationFinish') : '';
            Decimal inspectionScore     = (Decimal) workOrderResultInfo.get('inspectionScore') != null ? (Decimal) workOrderResultInfo.get('inspectionScore') : 0;
            
            Boolean isConfirmed         = (Boolean) fieldMap.get('isConfirmed');
            Boolean isHECareByAsset     = (Boolean) workOrderResultInfo.get('isHECareByAsset');
            String siteManager          = (String) fieldMap.get('siteManager') != null ? (String) fieldMap.get('siteManager') : '';
            String siteManagerPhone     = (String) fieldMap.get('siteManagerPhone') != null ? (String) fieldMap.get('siteManagerPhone') : '';
            String mainWorker           = (String) fieldMap.get('mainWorker') != null ? (String) fieldMap.get('mainWorker') : '';
            String mainWorkerPhone      = (String) fieldMap.get('mainWorkerPhone') != null ? (String) fieldMap.get('mainWorkerPhone') : '';

            List<Asset> assetDataList = [SELECT Id, WarrantyStartDate__c, WarrantyEnd__c, WarrantyStartDateWages__c, WarrantyEndWages__c, Name,
                                        HECare__c, FieldManagerName__c, FieldManagerMobilePhone__c, WorkerName__c, WorkerMobilePhone__c, AccountId
                                        FROM Asset 
                                        WHERE Id=:workOrder.AssetId LIMIT 1];

            List<Campaign> campaignList = [SELECT Id FROM Campaign WHERE RegularServiceType__c = 'HE Care' AND IsActive =true LIMIT 1];

            if (!assetDataList.isEmpty()) {
                assetData = assetDataList[0];
                assetName = assetData.Name;
                modelCode = assetName.split('-')[0];

                Campaign searchCampaign = campaignList[0];

                List<CampaignTarget__c> campaignTargetList = [SELECT Id, Equipment__c, Campaign__c, Account__c FROM CampaignTarget__c WHERE Equipment__c =:assetData.Id LIMIT 1];

                assetData.FieldManagerName__c           = siteManager;
                assetData.FieldManagerMobilePhone__c    = siteManagerPhone;
                assetData.WorkerName__c                 = mainWorker;
                assetData.WorkerMobilePhone__c          = mainWorkerPhone;

                if (orderType == '104'  && isConfirmed == true && String.isNotBlank(installationFinish)) {
                    Date warrantyEnd = Date.valueOf(installationFinish).addYears(2);
                    Date warrantyEndWages = Date.valueOf(installationFinish).addYears(1);

                    if (isHECareByAsset != null) {
                        assetData.HECare__c = isHECareByAsset;
                    }
                    
                    // if (isConfirmed == true && isHECareByAsset == true && campaignTargetList.isEmpty()) {
                    //     CampaignTarget__c campaignTarget = new CampaignTarget__c();
                    //     campaignTarget.Equipment__c = assetData.Id;
                    //     campaignTarget.Account__c   = assetData.AccountId;
                    //     campaignTarget.Campaign__c  = searchCampaign.Id;
                    //     insert campaignTarget;
                    // } else if (isConfirmed == false && isHECareByAsset == false && !campaignTargetList.isEmpty()) {
                    //     CampaignTarget__c deletedRecord = campaignTargetList[0];
                    //     delete deletedRecord;
                    // } else {
                    //     System.debug('already campaign target.');
                    // }
                }
                if (assetData != null) {
                    update assetData;
                }                
            } else {
                resMap.put('flag', 'none Asset.');
                return resMap;
            }
            
            // Delete Work Order Result Records & ContentDocument
            Set<Id> deletedWorkIds = new Set<Id>();
            List<String> deletedFileIds = new List<String>();
            List<Object> deletedWorkList = (List<Object>) fieldMap.get('deletedWorkList');
            List<Object> deletedFileList = (List<Object>) fieldMap.get('deletedFileList');
            System.debug('deletedWorkList>>>' + deletedWorkList);
            if (!deletedWorkList.isEmpty()) {
                for (Object idValue : deletedWorkList) {
                    String tmpId = (String) idValue;
                    if (String.isNotBlank(tmpId)) {
                        deletedWorkIds.add(tmpId);
                    }                    
                }
            }
            if (!deletedWorkIds.isEmpty() ) {
                List<WorkOrderResult__c> worList = [ SELECT Id FROM WorkOrderResult__c WHERE Id IN :deletedWorkIds ];
                delete worList;
            }
            
            // if (!deletedFileList.isEmpty() && deletedFileList != null) {
            if (deletedFileList != null) {
                for (Object idValue : deletedFileList) {
                    deletedFileIds.add((String) idValue);
                }
                docMapList = fileRemove(deletedFileIds);
            }

            // Insert and Update 
            Map<Object, Object> serviceData            = (Map<Object, Object>) fieldMap.get('serviceData');
            Map<Object, Object> selectedBrokenArea     = (Map<Object, Object>) workOrderResultInfo.get('selectedBrokenArea');
            Map<Object, Object> selectedPhenomenon     = (Map<Object, Object>) workOrderResultInfo.get('selectedPhenomenon');
            Map<Object, Object> selectedCauseArea      = (Map<Object, Object>) workOrderResultInfo.get('selectedCauseArea');
            Map<Object, Object> selectedRepairAction   = (Map<Object, Object>) workOrderResultInfo.get('selectedRepairAction');
            Map<Object, Object> selectedBrokenStatus   = (Map<Object, Object>) workOrderResultInfo.get('selectedBrokenStatus');
            
            if (workOrderResultInfo != null) {
                WorkOrderResult__c wor = new WorkOrderResult__c();
                WorkOrder wo = new WorkOrder();
                Case caseRecord = new Case();

                caseRecord.Id = caseId;
                
                if(selectedBrokenArea != null) {
                    caseRecord.FailureAreaValue__c            = selectedBrokenArea.get('brokenAreaGroup') != null ? (String) selectedBrokenArea.get('brokenAreaGroup') : '';
                    caseRecord.FailureAreaDetailValue__c      = selectedBrokenArea.get('brokenAreaCode') != null ? (String) selectedBrokenArea.get('brokenAreaCode') : '';
                    caseRecord.FailureArea__c                 = selectedBrokenArea.get('failureArea') != null ? (String) selectedBrokenArea.get('failureArea') : '';
                    caseRecord.FailureAreaDetail__c           = selectedBrokenArea.get('failureAreaDetail') != null ? (String) selectedBrokenArea.get('failureAreaDetail') : '';
                }
         
                if (selectedPhenomenon != null) {
                    caseRecord.FailurePhenomenonValue__c      = selectedPhenomenon.get('phenomenonCode') != null ? (String) selectedPhenomenon.get('phenomenonCode') : '';
                    caseRecord.FailurePhenomenon__c           = selectedPhenomenon.get('phenomenonPart') != null ? (String) selectedPhenomenon.get('phenomenonPart') : '';
                }

                // Case가 있는 리포트의 경우 Id값을 가지고 있으므로 Update
                if (String.isNotBlank(caseId)) {
                    update caseRecord;
                }
                
                wo.Id = workOrderId;
                wo.IsSavePortal__c = true;

                if (String.isNotBlank(installationFinish)) {
                    wo.InstallTestFinish__c = Date.valueOf(installationFinish);
                }

                wo.FieldManagerName__c          = siteManager;
                wo.FieldManagerMobilePhone__c   = siteManagerPhone;
                wo.WorkerName__c                = mainWorker;
                wo.WorkerMobilePhone__c         = mainWorkerPhone;

                if (isHECareByAsset != null) {
                    wo.HECare__c = isHECareByAsset;
                }

                if (inspectionScore != null) {
                    wo.InspectionScore__c = inspectionScore;
                }
                
                if(selectedBrokenArea != null) {
                    wo.FailureAreaValue__c            = selectedBrokenArea.get('brokenAreaGroup') != null ? (String) selectedBrokenArea.get('brokenAreaGroup') : '';
                    wo.FailureAreaGroupValue__c       = selectedBrokenArea.get('brokenAreaCode') != null ? (String) selectedBrokenArea.get('brokenAreaCode') : '';
                    wo.FailureArea__c                 = selectedBrokenArea.get('failureArea') != null ? (String) selectedBrokenArea.get('failureArea') : '';
                    wo.FailureAreaGroup__c            = selectedBrokenArea.get('failureAreaDetail') != null ? (String) selectedBrokenArea.get('failureAreaDetail') : '';
                }
                
                if (selectedPhenomenon != null) {
                    wo.FailurePhenomenonValue__c      = selectedPhenomenon.get('phenomenonCode') != null ? (String) selectedPhenomenon.get('phenomenonCode') : '';
                    wo.FailurePhenomenon__c           = selectedPhenomenon.get('phenomenonPart') != null ? (String) selectedPhenomenon.get('phenomenonPart') : '';
                    wo.FailurePhenomenonDetail__c     = selectedPhenomenon.get('phenomenonDetail') != null ? (String) selectedPhenomenon.get('phenomenonDetail') : '';
                }
                
                if (selectedCauseArea != null) {
                    wo.CauseOfFailureValue__c         = selectedCauseArea.get('causeAreaCode') != null ? (String) selectedCauseArea.get('causeAreaCode') : '';
                    wo.CauseOfFailure__c              = selectedCauseArea.get('causeAreaPart') != null ? (String) selectedCauseArea.get('causeAreaPart') : '';
                    wo.CauseOfFailureDetail__c        = selectedCauseArea.get('causeAreaDetail') != null ? (String) selectedCauseArea.get('causeAreaDetail') : '';
                }

                if (selectedRepairAction != null) {
                    wo.RepairActionValue__c           = selectedRepairAction.get('repairActionCode') != null ? (String) selectedRepairAction.get('repairActionCode') : '';
                    wo.RepairAction__c                = selectedRepairAction.get('repairActionPart') != null ? (String) selectedRepairAction.get('repairActionPart') : '';
                    wo.PendingOrCustomerMatters__c    = selectedRepairAction.get('repairActionDetail') != null ? (String) selectedRepairAction.get('repairActionDetail') : '';
                }

                if (SelectedBrokenStatus != null) {
                    wo.FailureStatusCode__c           = SelectedBrokenStatus.get('brokenStatusCode') != null ? (String) SelectedBrokenStatus.get('brokenStatusCode') : '';
                    wo.FailureStatus__c               = SelectedBrokenStatus.get('brokenStatusPart') != null ? (String) SelectedBrokenStatus.get('brokenStatusPart') : '';
                }

                wo.ResponsibleDepartment__c           = workOrderResultInfo.get('responsibleDepartment') != null ? (String) workOrderResultInfo.get('responsibleDepartment') : '';
                wo.PendingMattersCustomerRequirements__c = (String) workOrderResultInfo.get('pendingOrCustomerMatters') != null ? (String) workOrderResultInfo.get('pendingOrCustomerMatters') : '';
                
                if (wo != null) {
                    update wo;
                }

                wor.WorkOrder__c    = workOrderId;
                wor.ActionDetail__c = (String) workOrderResultInfo.get('actionDetail') != null ? (String) workOrderResultInfo.get('actionDetail') : '';
                wor.resultType__c = 'COM';
                wor.MainInstallationTime__c = workOrderResultInfo.get('mainInstallTime') != null ? (Decimal) workOrderResultInfo.get('mainInstallTime') : 0;
                wor.IsTemporaryInstallationTime__c = (Boolean) workOrderResultInfo.get('isTemporaryInstall') != null ? (Boolean) workOrderResultInfo.get('isTemporaryInstall') : false;
                wor.TemporaryInstallationTime__c = workOrderResultInfo.get('tempInstallTime') != null ? (Decimal) workOrderResultInfo.get('tempInstallTime') : 0;
                wor.IsHoliday__c = (Boolean) workOrderResultInfo.get('isHoliday') != null ? (Boolean) workOrderResultInfo.get('isHoliday') : false;
                wor.SpecificationInstallationTime__c = workOrderResultInfo.get('specInstallTime') != null ? (Decimal) workOrderResultInfo.get('specInstallTime') : 0;

                wor.FenseApcCover__c = workOrderResultInfo.get('fenseApcCover') != null ? (Decimal) workOrderResultInfo.get('fenseApcCover') : 0;
                wor.SemiSplashGuard__c = workOrderResultInfo.get('semiSplashGuard') != null ? (Decimal) workOrderResultInfo.get('semiSplashGuard') : 0;
                wor.OverTools__c = workOrderResultInfo.get('overTools') != null ? (Decimal) workOrderResultInfo.get('overTools') : 0;
                wor.PMG__c = workOrderResultInfo.get('pmgTime') != null ? (Decimal) workOrderResultInfo.get('pmgTime') : 0;
                wor.AAC__c = workOrderResultInfo.get('accTime') != null ? (Decimal) workOrderResultInfo.get('accTime') : 0;
                
                wor.IsFenseAPCCover__c = (Boolean) workOrderResultInfo.get('isFenseApcCover') != null ? (Boolean) workOrderResultInfo.get('isFenseApcCover') : false;
                wor.IsSemiSplashGuard__c = (Boolean) workOrderResultInfo.get('isSemiSplashGuard') != null ? (Boolean) workOrderResultInfo.get('isSemiSplashGuard') : false;
                wor.IsOverTools__c = (Boolean) workOrderResultInfo.get('isOverTools') != null ? (Boolean) workOrderResultInfo.get('isOverTools') : false;
                wor.IsPMG__c = (Boolean) workOrderResultInfo.get('isPMG') != null ? (Boolean) workOrderResultInfo.get('isPMG') : false;
                wor.IsAAC__c = (Boolean) workOrderResultInfo.get('isAAC') != null ? (Boolean) workOrderResultInfo.get('isAAC') : false;
                wor.IsEtc__c = (Boolean) workOrderResultInfo.get('isEtc') != null ? (Boolean) workOrderResultInfo.get('isEtc') : false;
                wor.EtcTime__c = workOrderResultInfo.get('etcTime') != null ? (Decimal) workOrderResultInfo.get('etcTime') : 0;
                wor.ReasonOfETC__c = workOrderResultInfo.get('reasonOfETC') != null ? (String) workOrderResultInfo.get('reasonOfETC') : '';
                wor.TotalInstallationTime__c = workOrderResultInfo.get('totalInstallTime') != null ? (Decimal) workOrderResultInfo.get('totalInstallTime') : 0;
                wor.TotalInputTime__c = workOrderResultInfo.get('totalInputTime') != null ?(Decimal) workOrderResultInfo.get('totalInputTime') : 0;

                if (workOrderResultInfo.containsKey('preparationOptions') && workOrderResultInfo.get('preparationOptions') != null) {
                    wor.ReadinessStatus__c = (String) workOrderResultInfo.get('preparationOptions');
                }
                wor.InspectionDetail__c = workOrderResultInfo.containsKey('inspectionDetails') != null ? (String) workOrderResultInfo.get('inspectionDetails') : '';

                wor.TotalWork__c                   = workOrderResultInfo.get('totalWorkTime') != null ? (Decimal) workOrderResultInfo.get('totalWorkTime') : 0;
                wor.TotalStandardWork__c           = workOrderResultInfo.get('totalStandardWorkTime') != null ? (Decimal) workOrderResultInfo.get('totalStandardWorkTime') : 0;
                wor.Overtime__c                    = workOrderResultInfo.get('overWork') != null ? (Decimal) workOrderResultInfo.get('overWork') : 0;
                wor.OverReason__c                  = workOrderResultInfo.get('reasonForOrverWork') != null ? (String) workOrderResultInfo.get('reasonForOrverWork') : '';

                system.debug('service order result ' +  JSON.serialize(wor));

                if (String.isBlank((String) workOrderResultInfo.get('workOrderResultId'))) {
                    insert wor;
                } else {
                    wor.Id = (String) workOrderResultInfo.get('workOrderResultId');
                    update wor;
                }
                updatedWorkIds.add(wor.Id);
            }
            
            // 작업내역 추가 레코드 처리
            if (workList != null && !workList.isEmpty()) {
                List<Id> addRecordsIds = saveChildWorkList(workList, workOrderId);
                updatedWorkIds.addAll(addRecordsIds);
                syncWorkListIds.addAll(addRecordsIds);

                // Service Appointment 연동
                List<WorkOrderResult__c> newInsertList = new List<WorkOrderResult__c>();
                List<WorkOrderResult__c> newUpdateList = new List<WorkOrderResult__c>();

                List<WorkOrderResult__c> newWorkList = [SELECT Id, ServiceResource__c, WorkDate__c, WorkEndDate__c, WorkStartTime__c, WorkEndTime__c, WorkTime__c, WorkType__c, ServiceAppointment__c, SAKey__c
                                                        FROM WorkOrderResult__c WHERE ResultType__c =:'WH' AND Id IN :syncWorkListIds];
                                                        
                syncServiceAppointment(newWorkList, workOrderId);
            }

            // 초기하자 추가 레코드 처리
            if (defectList != null && !defectList.isEmpty()) {
                updatedWorkIds.addAll(saveChildDefectList(defectList, workOrderId));
            }

            // 표준공수 추가 레코드 처리
            if (standardWorkList != null && !standardWorkList.isEmpty()) {    
                updatedWorkIds.addAll(saveChildStandardWorkList(standardWorkList, workOrderId, modelCode, workOrder.ServiceOrderNumber__c));
            }

            // Upsert 후 Wrapper 다시 조회하고 리턴
            searchService = searchServiceReportInfo(workOrder, searchService);
            if (orderRTNumber == 'RT02') {
                if (String.isNotBlank(assetName)) {
                    searchService = getModelInstallInfo(assetName, searchService);
                }
                if (searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber) != null) {
                    searchService = searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber);
                } 
            } else {
                if (searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber) != null) {
                    searchService = searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber);
                }
            }
            
            if (searchWorkOrderResultList(workOrder.Id, searchService) != null) {
                searchService = searchWorkOrderResultList(workOrder.Id, searchService);
            }

            if (!searchProductRequestList(workOrder.Id).isEmpty()) {
                searchProductRequestList = searchProductRequestList(workOrder.Id);
                resMap.put('searchProductRequestList', searchProductRequestList);
            }

            // // 1. 업로드 되어있던 파일 HTML로 변환하여 새로운 ContentVersion 생성
            List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :workOrderId];
            System.debug('SELECT contentLinks ::: ' + JSON.serialize(contentLinks));

            List<Id> contentDocumentIdList = new List<Id>();
            for (ContentDocumentLink link : contentLinks) {
                contentDocumentIdList.add(link.ContentDocumentId);
            }

            List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion WHERE IsDealerPotalERP__c = false AND ERPDocNo__c = null AND ContentDocumentId IN :contentDocumentIdList];

            List<Id> contentVersionIdList = new List<Id>();
            for (ContentVersion version : contentVersions) {
                contentVersionIdList.add(version.Id);
            }
            IF_FilePackingService service = new IF_FilePackingService(); 
            List<Id> packedFileConversionIds =  service.packingToListByHTML(contentVersionIdList);

            // // 2. 저장 시 HTML로 연결된 파일 Content Version HTML로 변환
            resMap.put('convertFileIds', packedFileConversionIds); 
            
            if (searchService != null) {
                resMap.put('searchService', searchService);
            }
            resMap.put('docMapList', docMapList); // RFC에 전달하기 위한 삭제할 파일 docNO 목록
            resMap.put('flag', 'success');
        } catch (Exception e) {
            String apexMethodName = 'upsertServiceReport';
            String userId         = UserInfo.getUserId();
            String errorSummary   = e.getTypeName() + ' : ' + e.getMessage();
            String stackTrace     = e.getStackTraceString();
            String serializedFM   = JSON.serializePretty(fieldMap);
        
            String logText = '[Apex Method: ' + apexMethodName + '] [User: ' + userId + '] \n'
                           + '[ ' + errorSummary + '] \n'
                           + '[ ' + stackTrace + '] \n'
                           + '[ ' + serializedFM + '] ';
        
            System.debug('LOG By WorkOrderResult Id = ' + worId);
        
            try {
                try {
                    WorkOrderResult__c wr;
                
                    List<WorkOrderResult__c> wrList = [SELECT Id , ResultLog__c FROM WorkOrderResult__c WHERE WorkOrder__c = :workOrderId AND ResultType__c = 'COM' LIMIT 1];
                
                    if (!wrList.isEmpty()) {
                        wr = wrList[0];
                    } else {
                        wr = new WorkOrderResult__c(); 
                        wr.WorkOrder__c = workOrderId;
                        wr.ResultType__c = 'COM';
                    }
                    wr.ResultLog__c = '[ERROR LOG]\n' + logText;
                
                    upsert wr; 
                } catch (DmlException dmlException) {
                    System.debug('로그 저장 실패 무시 ::: ' + dmlException.getMessage());
                }
                
                resMap.put('errorString', e.getMessage());
            } catch (DmlException dmlException) {
                System.debug('로그 저장 실패 무시 ::: ' + dmlException.getMessage());
            }
        }
        
        return resMap;
    }
    
    /*
    * @description 서비스 리포트 저장 / 확정 후 IF CallOut
    */
    @AuraEnabled
    public static Map<String, Object> callOutServiceOrder(String recordId, Boolean isConfirmed, List<Map<String, String>> docMapList, List<String> convertVersionIdList) {
        Map<String, Object> resMap = new Map<String, Object>();
        DN_PortalServiceWrapper searchService   = new DN_PortalServiceWrapper();
        try {           
            if (String.isNotBlank(recordId)) {
                WorkOrder workOrder = [SELECT Id, OrderType__c, ServiceOrderNumber__c, HasWarrantyDirectManagement__c, FM_WorkOrderResult_Template__c FROM WorkOrder WHERE Id =:recordId];
                
                // ServiceOrderNumber__c 가 있는 경우 (본사 배정인 경우) || 자체유상인 경우, 만약 포탈 자체유상 제외하고 다른 방식으로 true 생성되면 여기 체크해야함
                if ( String.isNotBlank(workOrder.ServiceOrderNumber__c) || workOrder.HasWarrantyDirectManagement__c == true) {
                    DN_PortalServiceReportInterface callOut = new DN_PortalServiceReportInterface();
                    DN_PortalPaidReportInterface paidCallOut = new DN_PortalPaidReportInterface();
                    String serviceOrderNumber = workOrder.ServiceOrderNumber__c;
                    
                    switch on workOrder.OrderType__c {
                        when '103', '106', '809', '801', '802', '803', '810' {
                            // (103)정기점검, (106)기획/순회서비스, (809)설치검수, (801)납품 후 교육 무상, (802)납품 후 교육 유상, (803)납품 후 교육 정책
                            if(isConfirmed) {
                                Map<String, Object> res015 = callOut.interfaceCall015(recordId, isConfirmed);
                                resMap.put('res015', res015);
                            }
                            IF_ERP_DeliveryTraining_Classes.IF_PARTS_025_Res res025 = callOut.interfaceCall025(recordId, isConfirmed, docMapList, convertVersionIdList);
                            resMap.put('resParam', res025);

                            if (searchServiceReportInfo(workOrder, searchService) != null) {
                                searchService = searchServiceReportInfo(workOrder, searchService);
                            } 

                            if (res025.O_RETURN.TYPE == 'S' && isConfirmed == true) {
                                WorkOrder wo = new WorkOrder();
                                datetime myDateTime = datetime.now();
                                wo.Id                = recordId;
                                wo.ConfirmedDate__c  = myDateTime;
                                wo.Status            = 'Confirm';
                                update wo;

                                // 1. recordId를 기준으로 ContentDocumentId 추출
                                List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
                            
                                // 2. ContentDocumentId Set으로 중복 제거
                                Set<Id> contentDocumentIds = new Set<Id>();
                                for (ContentDocumentLink link : contentLinks) {
                                    if (link.ContentDocumentId != null) {
                                        contentDocumentIds.add(link.ContentDocumentId);
                                    }
                                }
                            
                                // 3. 해당 DocumentId 기준으로 ContentVersion 조회
                                List<ContentVersion> versionsToUpdate = [SELECT Id, Title, FileExtension, DealerPotalFileType__c, ERPDocNo__c, IsDealerPotalERP__c FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
                            
                                // 4. 필드 업데이트 Set
                                for (ContentVersion cv : versionsToUpdate) {
                                    cv.IsDealerPotalERP__c = true;
                                }
                            
                                // 5. 업데이트
                                if (!versionsToUpdate.isEmpty()) {
                                    update versionsToUpdate;
                                }
                            }
                            
                            resMap.put('searchService', searchService);
                        }

                        when '104' {
                            // (104)설치시운전
                            if(isConfirmed) {
                                Map<String, Object> res015 = callOut.interfaceCall015(recordId, isConfirmed);
                                resMap.put('res015', res015);
                            }
                            IF_ERP_Service_InstAndComm_Classes.IF_SERVICE_045_Res res045 = callOut.interfaceCall045(recordId, isConfirmed, docMapList, convertVersionIdList);
                            resMap.put('resParam', res045);
                            
                            if (res045.O_RETURN.TYPE == 'S' && isConfirmed == true) {
                                WorkOrder wo = new WorkOrder();
                                datetime myDateTime = datetime.now();
                                wo.Id                = recordId;
                                wo.ConfirmedDate__c  = myDateTime;
                                wo.Status            = 'Confirm';
                                update wo;

                                // 1. recordId를 기준으로 ContentDocumentId 추출
                                List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
                            
                                // 2. ContentDocumentId Set으로 중복 제거
                                Set<Id> contentDocumentIds = new Set<Id>();
                                for (ContentDocumentLink link : contentLinks) {
                                    if (link.ContentDocumentId != null) {
                                        contentDocumentIds.add(link.ContentDocumentId);
                                    }
                                }
                            
                                // 3. 해당 DocumentId 기준으로 ContentVersion 조회
                                List<ContentVersion> versionsToUpdate = [SELECT Id, Title, FileExtension, DealerPotalFileType__c, ERPDocNo__c, IsDealerPotalERP__c FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
                            
                                // 4. 필드 업데이트 Set
                                for (ContentVersion cv : versionsToUpdate) {
                                    cv.IsDealerPotalERP__c = true;
                                }
                            
                                // 5. 업데이트
                                if (!versionsToUpdate.isEmpty()) {
                                    update versionsToUpdate;
                                }
                            }
                            
                            if (searchServiceReportInfo(workOrder, searchService) != null) {
                                searchService = searchServiceReportInfo(workOrder, searchService);
                            } 
                            resMap.put('searchService', searchService);
                        }

                        when '201', '202', '203', '204', '218', '214', '215', '216', '217', '221', '219', '220' {
                            System.debug('Warranty ::: ' + workOrder.HasWarrantyDirectManagement__c);
                            // (201)무상Claim, (202)유상Claim, (203)PreCall, (204)P-Claim, (218)P-Claim 입고처리, (214)무상SP입고수리, (215)유상SP입고수리, (216)업무대행, (217)부품만청구, (221)Care 1612, (219)Value Fund, (220) Customer Care
                            if (workOrder.HasWarrantyDirectManagement__c) {
                                System.debug('Warranty ::: ' + workOrder.HasWarrantyDirectManagement__c);
                                
                                IF_ERP_Service_Report_Classes.IF_SERVICE_049_Res resParam = paidCallOut.interfaceCall049(recordId, isConfirmed, convertVersionIdList);

                                System.debug('resParam 049  ::: ' + JSON.serialize(resParam));
                                resMap.put('resParam', resParam);
                            } else {
                                if(isConfirmed) {
                                    Map<String, Object> res015 = callOut.interfaceCall015(recordId, isConfirmed);
                                    resMap.put('res015', res015);

                                    Map<String, Object> resParam = callOut.interfaceCall046(recordId, isConfirmed, docMapList, convertVersionIdList);
                                    resMap.put('resParam', resParam);
                                    
                                } else {
                                    Map<String, Object> res046 = callOut.interfaceCall046(recordId, isConfirmed, docMapList, convertVersionIdList);
                                    resMap.put('resParam', res046);

                                    IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res res054 = callOut.interfaceCall054(recordId, workOrder.FM_WorkOrderResult_Template__c);
                                    resMap.put('res054', res054);
                                }
                            }
                        }

                        when '601', '602' {
                            // (699)DNSA Service Report 가 맞으나 None Warranty Claim(DNSA)	: 602 , Warranty Claim(DNSA) : 601
                            IF_ERP_SalesOrder_Classes.IF_CSPLUS_044_Res resParam = callOut.interfaceCall044(recordId, isConfirmed, docMapList, convertVersionIdList);
                            resMap.put('resParam', resParam);
                        }

                        when else {
                            System.debug('none RFC.');
                            resMap.put('message', 'none RFC.');
                        }
                    }
                }
            }

            List<WorkOrder> workOrderList = [SELECT Id, ServiceOrderNumber__c, Status, ConfirmedDate__c FROM WorkOrder WHERE Id =:recordId];
            if (!workOrderList.isEmpty() && isConfirmed) {
                User user = [SELECT TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
                TimeZone timeZone = TimeZone.getTimeZone(user.TimeZoneSidKey);
                if (workOrderList[0].ConfirmedDate__c != null) {
                    String confirmedDate = workOrderList[0].ConfirmedDate__c.format('yyyy-MM-dd HH:mm:ss', timeZone.getID());
                    resMap.put('confirmedDate',confirmedDate);
                } 
            }

            resMap.put('flag', 'SUCCESS');
            System.debug('resMap ::: ' + JSON.serialize(resMap));
        } catch (Exception e) {
            String apexMethodName = 'callOutServiceOrder';
            String userId = UserInfo.getUserId();
            String errorSummary = e.getTypeName() + ': ' + e.getMessage();
            String stackTrace  = e.getStackTraceString();
        
            String logText =
                '[Apex Method: ' + apexMethodName + '] [User: ' + userId + '] [WorkOrder Id: ' + recordId + '] \n'
              + '[ ' + errorSummary + '] \n'
              + '[ ' + stackTrace + '] \n'
              + '[ ' + JSON.serializePretty(resMap) + '] \n'; 
            
            try {
                List<WorkOrderResult__c> resultList = [SELECT Id, ResultLog__c FROM WorkOrderResult__c WHERE WorkOrder__c = :recordId AND ResultType__c = 'COM' LIMIT 1 ];
                if (!resultList.isEmpty()) {
                    WorkOrderResult__c result = resultList[0];
                    result.ResultLog__c = '[ERROR LOG]\n' + logText;
                    update result;
                } else {
                    System.debug('None WorkOrderResult Records.');
                }
            } catch (DmlException dmlException) {
                System.debug('로그 저장 실패 ::: ' + dmlException.getMessage());
            }
            resMap.put('errorString', e.getMessage());
        }
        
        return resMap;
    }

    /**
    * @description 서비스 리포트 확정 시 저장(IF-SERVICE-046) > 확정(IF-SERVICE-050) 호출 후 재 조회 Callout (IF-SERVICE-054) 
    **/  
    @AuraEnabled
    public static Map<String,Object> callOutServiceOrder054(String recordId) {
        Map<String,Object> resMap = new Map<String,Object>();
        try {
            String orderType = [SELECT FM_WorkOrderResult_Template__c FROM WorkOrder WHERE Id = :recordId LIMIT 1].FM_WorkOrderResult_Template__c;
    
            DN_PortalServiceReportInterface cli = new DN_PortalServiceReportInterface();
            IF_ERP_Service_Report_Classes.IF_SERVICE_054_Res res054 = cli.interfaceCall054(recordId, orderType);
            resMap.put('res054', res054);
            resMap.put('flag', 'SUCCESS');
        } catch (Exception e) {
            System.debug('@@@ : ' + e.getMessage() +',,, : ' + e.getStackTraceString());
            resMap.put('errorString', e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 작업내역(WorkOrderResult)레코드 방문예약(Service Appointment) 레코드에 동기화
    * @author Chungwoo Lee | 12-21-2024 
    **/    
    public static void syncServiceAppointment(List<WorkOrderResult__c> workList, String workOrderId) {
        System.debug('!!!!!!!!!! syncServiceAppointment');
        try{
            System.debug('workList for SA ::: ' + JSON.serialize(workList));
            WorkOrder searchedWorkOrder = [SELECT 
                                        OrderType__c, FM_RepairRequestDateTime__c, HasWarrantyDirectManagement__c, CreatedDate, Worker__c
                                        FROM WorkOrder WHERE Id = :workOrderId];

            Datetime dt = searchedWorkOrder.FM_RepairRequestDateTime__c;
            Boolean hasWarranty = searchedWorkOrder.HasWarrantyDirectManagement__c;
            String orderType = searchedWorkOrder.OrderType__c;
            Datetime createdDate = searchedWorkOrder.CreatedDate;
            String mainWorker = searchedWorkOrder.Worker__c;
            List<ServiceAppointment> appointmentsToInsert = new List<ServiceAppointment>();
            List<ServiceAppointment> appointmentsToUpdate = new List<ServiceAppointment>();
        
            Map<String, Id> groupKeyToSAIdMap = new Map<String, Id>();
            Map<String, List<WorkOrderResult__c>> groupedWorkList = new Map<String, List<WorkOrderResult__c>>();
            Id saDomesticRecType = [SELECT ID FROM RecordType WHERE DeveloperName = 'ServiceAppointment' LIMIT 1].Id;

        
            for (WorkOrderResult__c wor : workList) {
                String saKey = wor.SAKey__c;
                
                if (!groupedWorkList.containsKey(saKey)) {
                    groupedWorkList.put(saKey, new List<WorkOrderResult__c>());
                }
                groupedWorkList.get(saKey).add(wor);
            }
            List<String> saIdDupleCheckSet = new List<String>();
            System.debug('@@ groupedWorkList : ' + groupedWorkList);

            for (String key : groupedWorkList.keySet()) {
                List<WorkOrderResult__c> workItems = groupedWorkList.get(key);

                Datetime schedStartTime = null; // ServiceAppointment.DepartmentReport__c (예약의 시작과 출발시간)
                Datetime moveSchedEndTime = null; // ServiceAppointment.ArrivalReport__c (도착시간은 이동 타입의 종료시간)
                Datetime workSchedEndTime = null; // ServiceAppointment.SchedEndTime (예약 종료 시간은 가장 늦게 종료된 작업 타입의 종료시간)
                Datetime workCompletionTimeMobile = null; // ServiceAppointment.workCompletionTimeMobile__c (작업완료 시간, SchedEndTime과 동일)
                Id serviceResourceId = null;
                Id serviceAppointmentId = null;

                System.debug('@@ workItems : ' + workItems);

                for (WorkOrderResult__c workItem : workItems) {
                    Date workDate = workItem.WorkDate__c;
                    Date workEndDate = workItem.WorkEndDate__c;
                    Time startTime = workItem.WorkStartTime__c;
                    Time endTime = workItem.WorkEndTime__c;

                    Datetime convertStart = Datetime.newInstance(workDate, startTime);
                    Datetime convertEnd = Datetime.newInstance(workDate, endTime);
                    
                    if (orderType == '104' && workDate < workEndDate) {
                        convertEnd = Datetime.newInstance(workEndDate, endTime);
                    } 

                    String workType = workItem.WorkType__c != null ? workItem.WorkType__c : '';
    
                    System.debug('@@ workType : ' + workType);
                    if (orderType == '104') {
                        serviceAppointmentId = workItem.ServiceAppointment__c;
                        if (schedStartTime == null || convertStart < schedStartTime) {
                            schedStartTime = convertStart;
                        }
                        if (moveSchedEndTime == null || convertEnd > moveSchedEndTime) {
                            moveSchedEndTime = convertEnd;
                        }
                    } else if (hasWarranty) {
                        serviceAppointmentId = workItem.ServiceAppointment__c;
                        if (schedStartTime == null || convertStart < schedStartTime) {
                            schedStartTime = convertStart;
                        }
                        if (moveSchedEndTime == null || convertEnd > moveSchedEndTime) {
                            moveSchedEndTime = convertEnd;
                        }
                    } else {
                        if (workType == 'MV') {
                            System.debug('@@ MV');
                            if (!saIdDupleCheckSet.contains(workItem.ServiceAppointment__c)) {
                                saIdDupleCheckSet.add(workItem.ServiceAppointment__c);
                                
                                serviceAppointmentId = workItem.ServiceAppointment__c;
                            } else {
                                serviceAppointmentId = null;
                            }

                            if (schedStartTime == null || convertStart < schedStartTime) {
                                schedStartTime = convertStart;
                            }
                            if (moveSchedEndTime == null) {
                                moveSchedEndTime = convertEnd;
                            }
                        }
                        if (workType == 'WK' || workType == 'DN') {
                            if (convertEnd != null || convertEnd > workSchedEndTime) {
                                workSchedEndTime = convertEnd;
                                workCompletionTimeMobile = convertEnd;
                            }
                        }
                    }
                    
                    serviceResourceId = workItem.ServiceResource__c;
                }
                System.debug('@@ serviceAppointmentId : ' + serviceAppointmentId);
                
                if (schedStartTime != null && moveSchedEndTime != null) {
                    ServiceAppointment sa = new ServiceAppointment();
                    // 설치시운전 
                    if (orderType == '104') {
                        sa.ServiceResource__c = serviceResourceId;
                        sa.ParentRecordId = workOrderId;
                        sa.WorkOrder__c = workOrderId;
                        sa.SchedStartTime = schedStartTime;
                        sa.SchedEndTime = moveSchedEndTime;
                        sa.DepartmentReport__c = schedStartTime;
                        sa.WorkCompletionTimeMobile__c = moveSchedEndTime;
                    } else if (hasWarranty) {
                        sa.ServiceResource__c = serviceResourceId;
                        sa.ParentRecordId = workOrderId;
                        sa.WorkOrder__c = workOrderId;
                        sa.SchedStartTime = schedStartTime;
                        sa.SchedEndTime = moveSchedEndTime;
                    } else {
                        sa.SchedStartTime = schedStartTime;
                        if (workSchedEndTime == null) {
                            // 작업 없이 이동만 먼저 생성되는 경우 예약 종료시간은 이동 종료시간 +3으로 생성
                            sa.SchedEndTime = moveSchedEndTime.addHours(3);
                        } else {
                            sa.SchedEndTime = workSchedEndTime;
                        }
                        sa.ServiceResource__c = serviceResourceId;
                        sa.ParentRecordId = workOrderId;
                        sa.WorkOrder__c = workOrderId;
                        sa.DepartmentReport__c = schedStartTime;
                        sa.ArrivalReport__c = moveSchedEndTime;
                        if(WorkCompletionTimeMobile != null) {
                            sa.WorkCompletionTimeMobile__c = WorkCompletionTimeMobile;
                        }
                    }
                    
                    if (serviceAppointmentId != null) {
                        sa.Id = serviceAppointmentId;
                        appointmentsToUpdate.add(sa);
                        groupKeyToSAIdMap.put(key, sa.Id);
                    } else {
                        sa.WorkerType__c = serviceResourceId == mainWorker ? 'Service Resource (Main)' : 'Service Resource (Sub)';
                        sa.isPortal__c = true;
                        appointmentsToInsert.add(sa);
                        groupKeyToSAIdMap.put(key, null);
                    }
                }
                System.debug('@@ appointmentsToUpdate : ' + appointmentsToUpdate );
            }

            System.debug('@@ appointmentsToInsert : ' + appointmentsToInsert);

            if (!appointmentsToInsert.isEmpty()) {
                insert appointmentsToInsert;
    
                Integer index = 0;
                for (String key : groupKeyToSAIdMap.keySet()) {
                    if (groupKeyToSAIdMap.get(key) == null) {
                        groupKeyToSAIdMap.put(key, appointmentsToInsert[index].Id);
                        index++;
                    }
                }
            } else if (!appointmentsToUpdate.isEmpty()) {
                update appointmentsToUpdate;
            }           
    
            System.debug('@@ groupKeyToSAIdMap : '+ groupKeyToSAIdMap);

            List<WorkOrderResult__c> workOrderResultsToUpdate = new List<WorkOrderResult__c>();
            for (String key : groupKeyToSAIdMap.keySet()) {
                List<WorkOrderResult__c> workItems = groupedWorkList.get(key);
                Id saId = groupKeyToSAIdMap.get(key);
    
                for (WorkOrderResult__c workItem : workItems) {
                    WorkOrderResult__c wor = new WorkOrderResult__c();
                    wor.Id = workItem.Id;
                    wor.ServiceAppointment__c = saId;
                    workOrderResultsToUpdate.add(wor);
                }
            }
    
            if (!workOrderResultsToUpdate.isEmpty()) {
                update workOrderResultsToUpdate;
            }
    
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new DmlException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
    }
    
    /**
    * @description 작업 내역 레코드 처리
    **/  
    private static List<Id> saveChildWorkList(List<Object> childRecords, String workOrderId) {
        List<Id> updatedIds = new List<Id>();
        List<WorkOrderResult__c> recordsToInsert = new List<WorkOrderResult__c>();
        List<WorkOrderResult__c> recordsToUpdate = new List<WorkOrderResult__c>();

        for (Integer i = 0; i < childRecords.size(); i++) {
            Map<Object, Object> recordData = (Map<Object, Object>) childRecords[i];
            WorkOrderResult__c record = new WorkOrderResult__c();

            record.WorkOrder__c = workOrderId;
            record.ResultType__c = 'WH';
            String workDate = (String) recordData.get('workDate');

            Map<Object, Object> worker = recordData.get('worker') != null && recordData.get('worker') != '' ? (Map<Object, Object>) recordData.get('worker') : new Map<Object, Object>();
            
            if ((String) recordData.get('saKey') != null) {
                record.SAKey__c = (String) recordData.get('saKey');
            }
            if (worker != null && worker.get('Id') != null) {
                record.ServiceResource__c = (String) worker.get('Id');
            }

            record.WorkDate__c = Date.valueOf(workDate);

            String workEndDate = (String) recordData.get('workEndDate');
            if(String.isNotBlank(workEndDate)){
                record.WorkEndDate__c = Date.valueOf(workEndDate);
            }

            // 작업 시작 시간 처리
            String startTime = (String) recordData.get('startTime');
            String[] splitStartTime = startTime.split(':');
            Time convertStartTime = Time.newInstance(Integer.valueOf(splitStartTime[0]) ,Integer.valueOf(splitStartTime[1]), 0 ,0);
            record.WorkStartTime__c = convertStartTime;

            // 작업 종료 시간 처리
            String endTime = (String) recordData.get('endTime');
            String[] splitEndTime = endTime.split(':');
            Time convertEndTime = Time.newInstance(Integer.valueOf(splitEndTime[0]) ,Integer.valueOf(splitEndTime[1]), 0 ,0);
            record.WorkEndTime__c = convertEndTime;

            // 작업 시간 처리
            if (String.isNotBlank((String) recordData.get('workHours'))) {
                record.WorkTime__c = (String) recordData.get('workHours');
            }
            
            if(String.isNotBlank((String) recordData.get('workType'))) {
                record.WorkType__c = (String) recordData.get('workType');
            }
            if(String.isNotBlank((String) recordData.get('workContent'))) {
                record.Description__c = (String) recordData.get('workContent');
            }

            if(String.isNotBlank((String) recordData.get('travelHour'))) {
                record.TravelHour__c = (String) recordData.get('travelHour');
            }
            if(String.isNotBlank((String) recordData.get('airTripType'))) {
                record.AirTrip__c = (String) recordData.get('airTripType');
            }
            
            if (recordData.containsKey('isHoliday') && recordData.get('isHoliday') != null) {
                record.IsHoliday__c = (Boolean) recordData.get('isHoliday');
            }
            
            String workId = (String) recordData.get('workId');
            if (String.isNotBlank(workId)) {
                record.Id = workId; 
                recordsToUpdate.add(record);
            } else {
                recordsToInsert.add(record); 
            }
        }

        // Insert
        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;

            for (SObject record : recordsToInsert) {
                updatedIds.add(record.Id); 
            }
        }

        // Update
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;

            for (SObject record : recordsToUpdate) {
                updatedIds.add(record.Id); 
            }
        }

        return updatedIds;
    }

    /**
    * @description 초기 하자 추가 레코드 처리 
    **/ 
    private static List<Id> saveChildDefectList(List<Object> childRecords, String workOrderId) {
        List<Id> updatedIds = new List<Id>();
        List<WorkOrderResult__c> recordsToInsert = new List<WorkOrderResult__c>();
        List<WorkOrderResult__c> recordsToUpdate = new List<WorkOrderResult__c>();

        for (Integer i = 0; i < childRecords.size(); i++) {
            Map<Object, Object> recordData = (Map<Object, Object>) childRecords[i];
            WorkOrderResult__c record = new WorkOrderResult__c();

            record.WorkOrder__c = workOrderId;
            record.ResultType__c    = 'ITD';

            record.InitialDefectType__c = (String) recordData.get('type');
            record.InitialDefectDetail__c = (String) recordData.get('content');
            record.ActionDetail__c = (String) recordData.get('actionTaken');
            record.Note__c = (String) recordData.get('remarks');
        
            String workId = (String) recordData.get('workId');
            if (String.isNotBlank(workId)) {
                record.Id = workId; 
                recordsToUpdate.add(record);
            } else {
                recordsToInsert.add(record); 
            }
        }
        // Insert
        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;

            for (SObject record : recordsToInsert) {
                updatedIds.add(record.Id); 
            }
        }
        // Update
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;

            for (SObject record : recordsToUpdate) {
                updatedIds.add(record.Id); 
            }
        }
        return updatedIds;
    }

    /**
    * @description 표준 공수 레코드 처리
    **/ 
    private static List<Id> saveChildStandardWorkList(List<Object> standardWorkList, String workOrderId, String modelCode, String ServiceOrderNumber) {
        List<Id> updatedIds = new List<Id>();
        List<WorkOrderResult__c> recordsToInsert = new List<WorkOrderResult__c>();
        List<WorkOrderResult__c> recordsToUpdate = new List<WorkOrderResult__c>();
        List<RequestStandardHR__c> requestStandardHRUpdate = new List<RequestStandardHR__c>();

        for (Object standardWork : standardWorkList) {
            Map<Object, Object> recordData = (Map<Object, Object>) standardWork;
            System.debug('STR CHECK ::: ' + JSON.serialize(recordData));
            WorkOrderResult__c record = new WorkOrderResult__c();

            record.WorkOrder__c = workOrderId;
            record.ResultType__c = 'SWT';
            record.StandardWorkFailureArea__c = (String) recordData.get('breakdownPart');
            record.StandardWorkItem__c = (String) recordData.get('standardWorkItem');
            record.StandardWorkTime__c = recordData.get('standardWorkTime') != null ? (Decimal) recordData.get('standardWorkTime') : 0;
            record.StandardWorkForce__c = recordData.get('standardWorkPeople') != null ? (Decimal) recordData.get('standardWorkPeople') : 0;
            record.StandardHour__c      = (String) recordData.get('standardHourId') != null ? (String) recordData.get('standardHourId') : null;

            record.IsChangeStandardWork__c = (Boolean) recordData.get('isChangedStandardWork');
            record.ActualWorkTime__c = recordData.get('actualWorkTime') != null ? (Decimal) recordData.get('actualWorkTime') : 0;
            record.ActualWorkForce__c = recordData.get('actualWorkPeople') != null ? (Decimal) recordData.get('actualWorkPeople') : 0;
            record.ChangeRequestReason__c = (String) recordData.get('changeRequestReason') != null ? (String) recordData.get('changeRequestReason') : '';

            String workId = (String) recordData.get('workId');
            if (String.isNotBlank(workId)) {
                record.Id = workId;
                recordsToUpdate.add(record);
            } else {
                recordsToInsert.add(record);
            }
        }
        // Insert
        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
            for (SObject record : recordsToInsert) {
                updatedIds.add(record.Id);
            }
        }
        // Update
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
            for (SObject record : recordsToUpdate) {
                updatedIds.add(record.Id);
            }
        }

        // 아래는 표준 공수 변경 필요 true인 경우 실행
        Set<String> alreadyRequestedStandardHourIds = new Set<String>();
        
        for (RequestStandardHR__c alreadyRequest : [SELECT StandardHour__c FROM RequestStandardHR__c WHERE ApprovalStatus__c = '승인대기']) {
            if (alreadyRequest.StandardHour__c != null) {
                alreadyRequestedStandardHourIds.add(alreadyRequest.StandardHour__c);
            }
        }

        List<ModelManager__c> modelManagerList = [SELECT Id, Name, ModelCode__c, Manager__c FROM ModelManager__c WHERE ModelCode__c =:modelCode LIMIT 1];
        ModelManager__c modelManager = null;
        
        if(!modelManagerList.isEmpty()) {
            modelManager = modelManagerList[0];
        }

        for (Object standardWork : standardWorkList) {
            Map<Object, Object> recordData = (Map<Object, Object>) standardWork;

            if ((Boolean) recordData.get('isChangedStandardWork')) {
                // 표준공수 마스터 ID
                String standardHourId = (String) recordData.get('standardHourId'); 

                // 기존 'Requested' 상태에 포함되지 않는 경우에만 요청 생성
                if (!alreadyRequestedStandardHourIds.contains(standardHourId)) {
                    RequestStandardHR__c requestRecord = new RequestStandardHR__c();
                    requestRecord.ServiceOrder__c       = workOrderId;
                    requestRecord.FaultArea__c          = (String) recordData.get('breakdownPart');
                    requestRecord.StandardHourItem__c   = (String) recordData.get('standardWorkItem');
                    requestRecord.Requester__c          = UserInfo.getUserId();
                    requestRecord.StandardWorkTime__c   = (Decimal) recordData.get('actualWorkTime');
                    requestRecord.StandardWorkForce__c  = (Decimal) recordData.get('actualWorkPeople');
                    requestRecord.RequestReason__c      = (String) recordData.get('changeRequestReason');
                    requestRecord.ModelManager__c       = modelManager != null ? modelManager.Id : '';
                    requestRecord.Approver__c           = modelManager != null ? modelManager.Manager__c : '';
                    requestRecord.ApprovalStatus__c     = '승인대기';
                    requestRecord.OrderNo__c            = ServiceOrderNumber;

                    if (standardHourId != null) {
                        requestRecord.StandardHour__c       = standardHourId;
                        requestRecord.RequestType__c        = '변경';
                        requestRecord.BeforeWorkTime__c     = (Decimal) recordData.get('standardWorkTime');
                        requestRecord.BeforeWorkForce__c    = (Decimal) recordData.get('standardWorkPeople');
                    } else {
                        requestRecord.RequestType__c        = '신규';
                        requestRecord.BeforeWorkTime__c     = 0;
                        requestRecord.BeforeWorkForce__c    = 0;
                    }
                    
                    requestStandardHRUpdate.add(requestRecord);
                }
            }
        }

        if (!requestStandardHRUpdate.isEmpty()) {
            insert requestStandardHRUpdate;

            // 생성된 요청 ID를 Set에 저장
            Set<Id> requestHRIds = new Set<Id>();
            for (RequestStandardHR__c request : requestStandardHRUpdate) {
                requestHRIds.add(request.Id);
            }

            // 알림 전송
            if (!requestHRIds.isEmpty()) {
                List<UTIL_Alert.HistoryWrapper> notiList = new List<UTIL_Alert.HistoryWrapper>();
                String alertManager = [SELECT Id FROM AlertManager__c WHERE Name = 'CS StandardMH Request Noti' LIMIT 1].Id;

                List<RequestStandardHR__c> requestHRList = [SELECT Id, Name, Approver__c FROM RequestStandardHR__c WHERE Id IN :requestHRIds];

                for (RequestStandardHR__c requestHR : requestHRList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType = 'Notification';
                    history.elementList.add(requestHR.Name);
                    history.alertID = alertManager;
                    history.targetID = requestHR.Id;
                    history.receiverforID = new Set<Id>{requestHR.Approver__c};
                    history.alertLanguage = 'ko';
                    notiList.add(history);
                }

                UTIL_Alert.runAlertEvent(notiList);
            }
        }

        return updatedIds;
    }

    /**
    * @description 유상 Claim 리포트(MT) 등록 시 장비번호 검색
    * @author Chungwoo Lee | 12-10-2024 
    * @param machineName 
    * @param assetName 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> searchServiceData(String machineName, String assetName) {
        Map<String, Object> resMap = new Map<String, Object>();
        DN_PortalServiceWrapper.ServiceReportInfo searchService = new DN_PortalServiceWrapper.ServiceReportInfo();

        try {
            if (String.isNotBlank(assetName)) {
                Asset asset = [
                    SELECT Id, Name, MachineName__c, FM_EquipmentWarrantyEquipmentParts__c, InstallDate, ObjectType__c,
                    AccountId, Account.Name, Account.Representative__c, Account.Mobile__c, Account.FM_Address__c, WarrantyStartDateWages__c
                    FROM Asset
                    WHERE Name = :assetName
                    LIMIT 1
                ];
                if (asset != null) {
                    searchService.machineName = Asset.MachineName__c != null ? Asset.MachineName__c : '';
                    searchService.assetName = Asset.Name != null ? Asset.Name : '';
                    searchService.objectType = Asset.ObjectType__c != null ? Asset.ObjectType__c : '';
                    searchService.warranty = Asset.FM_EquipmentWarrantyEquipmentParts__c != null ? Asset.FM_EquipmentWarrantyEquipmentParts__c : '';
                    searchService.installDate = asset.WarrantyStartDateWages__c != null ? String.valueOf(asset.WarrantyStartDateWages__c) : '';
                    searchService.orderType = '필드서비스 오더'; // 고정 값
                    searchService.workOrderType = '유상 Claim'; // 고정 값
                    searchService.accountName = Asset.Account.Name != null ? Asset.Account.Name : '';
                    searchService.representative = Asset.Account.Representative__c != null ? Asset.Account.Representative__c : '';
                    searchService.accountTel = Asset.Account.Mobile__c != null ? Asset.Account.Mobile__c : '';
                    searchService.accountAddress = Asset.Account.FM_Address__c != null ? Asset.Account.FM_Address__c : '';
                }

                if (searchService != null) {
                    resMap.put('flag', 'success');
                    resMap.put('searchService', searchService);
                }    
            } else {
                resMap.put('flag', 'warning');
                resMap.put('searchService', '');
            }
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 자체 유상 서비스 리포트 IF 송신 후 등록 / 확정
    * @author Chungwoo Lee | 12-18-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> savePaidService(Map<String, Object> fieldMap) {
        Map<String, Object> resMap = new Map<String, Object>();
        List<Id> updatedWorkIds = new List<Id>();
        List<Id> syncWorkListIds = new List<Id>();
        Id resultId = null;

        try {
            System.debug('savePaidService fieldMap ::: ' + JSON.serialize(fieldMap, true));

            Map<Object, Object> serviceInfo = (Map<Object, Object>) fieldMap.get('searchService');
            List<Object> workList = (List<Object>) fieldMap.get('workList');

            String orderType = (String )serviceInfo.get('workOrderTypeCode');
            String assetName = (String) serviceInfo.get('assetName');
            String reportedBy    = (String) fieldMap.get('reportedBy');
            String worker    = (String) fieldMap.get('worker');
            String workCenter = (String) fieldMap.get('workCenter');

            List<Asset> assetDataList = [SELECT Id, AccountId FROM Asset WHERE Name =:assetName LIMIT 1];
            Asset assetData = null;
            if (assetDataList.isEmpty()) {
                resMap.put('flag', 'WARNING');
                resMap.put('message', 'Asset does not exist.');
                return resMap;
            } else {
                assetData = assetDataList[0];    
            }

            // Delete
            Set<Id> deletedWorkIds = new Set<Id>();
            List<Object> deletedWorkList = (List<Object>) fieldMap.get('deletedWorkList');

            if (deletedWorkList != null) {
                for (Object idValue : deletedWorkList) {
                    deletedWorkIds.add((String) idValue);
                }
            }

            if (!deletedWorkIds.isEmpty()) {
                List<WorkOrderResult__c> worList = [ SELECT Id FROM WorkOrderResult__c WHERE Id IN :deletedWorkIds ];
                delete worList;
            }

            String workOrderId    = (String) fieldMap.get('workOrderId');
            Map<Object, Object> workOrderResultInfo    = (Map<Object, Object>) fieldMap.get('workOrderResultData');
            Map<Object, Object> selectedBrokenArea     = (Map<Object, Object>) workOrderResultInfo.get('selectedBrokenArea');
            Map<Object, Object> selectedPhenomenon     = (Map<Object, Object>) workOrderResultInfo.get('selectedPhenomenon');
            Map<Object, Object> selectedCauseArea      = (Map<Object, Object>) workOrderResultInfo.get('selectedCauseArea');
            Map<Object, Object> selectedRepairAction   = (Map<Object, Object>) workOrderResultInfo.get('selectedRepairAction');
            Map<Object, Object> selectedBrokenStatus   = (Map<Object, Object>) workOrderResultInfo.get('selectedBrokenStatus');

            String defectDateStr        = (String) fieldMap.get('defectDate');
            String receiptDateStr       = (String) fieldMap.get('receiptDate');
            String actionCallDateStr    = (String) fieldMap.get('actionCallDate');

            if (assetData != null) {
                WorkOrder paidWorkOrder = new WorkOrder();

                // 수리이력
                if(selectedBrokenArea != null) {
                    paidWorkOrder.FailureAreaValue__c            = selectedBrokenArea.get('brokenAreaGroup') != null ? (String) selectedBrokenArea.get('brokenAreaGroup') : '';
                    paidWorkOrder.FailureAreaGroupValue__c       = selectedBrokenArea.get('brokenAreaCode') != null ? (String) selectedBrokenArea.get('brokenAreaCode') : '';
                    paidWorkOrder.FailureArea__c                 = selectedBrokenArea.get('failureArea') != null ? (String) selectedBrokenArea.get('failureArea') : '';
                    paidWorkOrder.FailureAreaGroup__c            = selectedBrokenArea.get('failureAreaDetail') != null ? (String) selectedBrokenArea.get('failureAreaDetail') : '';
                }
                
                if (selectedPhenomenon != null) {
                    paidWorkOrder.FailurePhenomenonValue__c      = selectedPhenomenon.get('phenomenonCode') != null ? (String) selectedPhenomenon.get('phenomenonCode') : '';
                    paidWorkOrder.FailurePhenomenon__c           = selectedPhenomenon.get('phenomenonPart') != null ? (String) selectedPhenomenon.get('phenomenonPart') : '';
                    paidWorkOrder.FailurePhenomenonDetail__c     = selectedPhenomenon.get('phenomenonDetail') != null ? (String) selectedPhenomenon.get('phenomenonDetail') : '';
                }
                
                if (selectedCauseArea != null) {
                    paidWorkOrder.CauseOfFailureValue__c         = selectedCauseArea.get('causeAreaCode') != null ? (String) selectedCauseArea.get('causeAreaCode') : '';
                    paidWorkOrder.CauseOfFailure__c              = selectedCauseArea.get('causeAreaPart') != null ? (String) selectedCauseArea.get('causeAreaPart') : '';
                    paidWorkOrder.CauseOfFailureDetail__c        = selectedCauseArea.get('causeAreaDetail') != null ? (String) selectedCauseArea.get('causeAreaDetail') : '';
                }

                if (selectedRepairAction != null) {
                    paidWorkOrder.RepairActionValue__c           = selectedRepairAction.get('repairActionCode') != null ? (String) selectedRepairAction.get('repairActionCode') : '';
                    paidWorkOrder.RepairAction__c                = selectedRepairAction.get('repairActionPart') != null ? (String) selectedRepairAction.get('repairActionPart') : '';
                    paidWorkOrder.PendingOrCustomerMatters__c    = selectedRepairAction.get('repairActionDetail') != null ? (String) selectedRepairAction.get('repairActionDetail') : '';
                }

                if (selectedBrokenStatus != null) {
                    paidWorkOrder.FailureStatus__c               = selectedBrokenStatus.get('brokenStatusPart') != null ? (String) selectedBrokenStatus.get('brokenStatusPart') : '';
                    paidWorkOrder.FailureStatusCode__c           = selectedBrokenStatus.get('brokenStatusCode') != null ? (String) selectedBrokenStatus.get('brokenStatusCode') : '';
                }

                if(String.isNotBlank(workOrderId)) {
                    paidWorkOrder.Id    = workOrderId;

                    update paidWorkOrder;
                    resultId    = workOrderId;
                } else {
                    paidWorkOrder.AssetId = assetData.Id;
                    paidWorkOrder.PMActivityType__c = 'CS02';
                    paidWorkOrder.OrderType__c = '202';
                    paidWorkOrder.TicketType__c = 'Failure receipt';
                    paidWorkOrder.HasWarrantyDirectManagement__c = true;
                    paidWorkOrder.Worker__c = worker;
                    paidWorkOrder.ServiceTerritoryId = workCenter;
                    paidWorkOrder.AccountId = assetData.AccountId;
                    paidWorkOrder.DefectDate__c = (Date) Date.valueOf(defectDateStr);
                    paidWorkOrder.ReceiptDate__c = (Date) Date.valueOf(receiptDateStr);
                    paidWorkOrder.ActionCallDate__c = (Date) Date.valueOf(actionCallDateStr);

                    insert paidWorkOrder;
                    resultId = paidWorkOrder.Id;
                }
            }
            
            // Insert and Update 
            if (workOrderResultInfo != null) {
                WorkOrderResult__c workOrderResult = new WorkOrderResult__c();
                
                workOrderResult.WorkOrder__c = resultId;
                workOrderResult.Worker__c = reportedBy;
                workOrderResult.ResultType__c = 'COM';
                
                if (String.isBlank((String) workOrderResultInfo.get('workId'))) {
                    insert workOrderResult;
                } else {
                    update workOrderResult;
                }
                updatedWorkIds.add(workOrderResult.Id);
            }
                
            // 작업내역 추가 레코드 처리
            if (workList != null && workList.size() > 0) {
                List<Id> addRecordsIds = saveChildWorkList(workList, resultId);
                updatedWorkIds.addAll(addRecordsIds);
                syncWorkListIds.addAll(addRecordsIds);
            }

            // Service Appointment 연동
            List<WorkOrderResult__c> newInsertList = new List<WorkOrderResult__c>();
            List<WorkOrderResult__c> newUpdateList = new List<WorkOrderResult__c>();            

            List<WorkOrderResult__c> newWorkList = [SELECT Id, ServiceResource__c, WorkDate__c, WorkEndDate__c, WorkStartTime__c, WorkEndTime__c, WorkTime__c, WorkType__c, ServiceAppointment__c, SAKey__c
                                                    FROM WorkOrderResult__c WHERE Id IN :syncWorkListIds];


            System.debug('@@ newWorkList : ' + newWorkList);
            syncServiceAppointment(newWorkList, resultId);

            // 부품 사용내역 추가 레코드 처리
            List<WorkOrderResult__c> productUsedList = New List<WorkOrderResult__c>();
            List<Object> usageList = (List<Object>) fieldMap.get('usageList');
            
            for (Integer i = 0; i < usageList.size(); i++) {
                Map<Object, Object> recordData = (Map<Object, Object>) usageList[i];
                WorkOrderResult__c record = new WorkOrderResult__c();
                
                record.WorkOrder__c = resultId;
                record.ResultType__c = 'PT';
                record.ProductNumber__c = (String) recordData.get('productCode');
                record.ProductName__c = (String) recordData.get('productName');
                record.IsCause__c =  (Boolean) recordData.get('isCause');
                record.Quantity__c = (Decimal)recordData.get('quantity');
                record.Note__c =  (String) recordData.get('returnNote');
                productUsedList.add(record);
            }

            if (!productUsedList.isEmpty()) {
                insert productUsedList;
            }

            // 자체 유상 파일 업로드 ContentDocumentLink 다시 생성 
            List<Object> fileList = (List<Object>) fieldMap.get('fileList');
            Set<String> fileIds = new Set<String>();

            if (fileList != null && !fileList.isEmpty()) {
                for (Object file : fileList) {
                    Map<Object, Object> fileMap = (Map<Object, Object>) file;
                    fileIds.add((String) fileMap.get('contentDocumentId'));
                }
    
                if (!fileIds.isEmpty()) {
                    try {
                        List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
                    
                        for (String fileId : fileIds) {
                            ContentDocumentLink newLink = new ContentDocumentLink();
                            newLink.ContentDocumentId = fileId;
                            newLink.LinkedEntityId = resultId;
                            newLink.ShareType = 'V';
                            newLink.Visibility = 'AllUsers';
                            newLinks.add(newLink);
                        }
                        System.debug('new link with workorder ::: ' + JSON.serialize(newLinks));
                        insert newLinks;
                    } catch (DmlException e) {
                        System.debug('Error linking files to WorkOrder ::: ' + e.getMessage());
                        throw new AuraHandledException('Error linking files to WorkOrder ::: ' + e.getMessage());
                    }
                } else {
                    System.debug('No fileIds found to update.');
                }
            }
 
            // 1. 업로드 되어있던 파일 HTML로 변환하여 새로운 ContentVersion 생성
            List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :resultId];
            System.debug('SELECT contentLinks ::: ' + JSON.serialize(contentLinks));

            List<Id> contentDocumentIdList = new List<Id>();
            for (ContentDocumentLink link : contentLinks) {
                contentDocumentIdList.add(link.ContentDocumentId);
            }

            List<ContentVersion> contentVersions = [SELECT Id, Title, FileExtension, VersionData ,DealerPotalFileType__c, ERPDocNo__c, IsDealerPotalERP__c
                                                    FROM ContentVersion 
                                                    WHERE IsDealerPotalERP__c = false AND ERPDocNo__c = null AND ContentDocumentId IN :contentDocumentIdList];

                                                    System.debug('SELECT contentVersions ::: ' + JSON.serialize(contentVersions));

            List<Id> contentVersionIdList = new List<Id>();
            for (ContentVersion version : contentVersions) {
                contentVersionIdList.add(version.Id);
            }
            IF_FilePackingService service = new IF_FilePackingService(); 
            List<Id> packedFileConversionIds =  service.packingToListByHTML(contentVersionIdList);

            // 2. 저장 시 HTML로 연결된 파일 Content Version HTML로 변환
            resMap.put('convertFileIds', packedFileConversionIds); 

            DN_PortalServiceWrapper searchService   = new DN_PortalServiceWrapper();
            WorkOrder workOrder = [SELECT Id, AssetId, FM_WorkOrderResult_Template__c FROM WorkOrder WHERE Id =:resultId LIMIT 1];
            String orderRTNumber = workOrder.FM_WorkOrderResult_Template__c;

            searchService = searchServiceReportInfo(workOrder, searchService);

            if (searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber) != null) {
                searchService = searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber);
            } 
                
            if (searchWorkOrderResultList(workOrder.Id, searchService) != null) {
                searchService = searchWorkOrderResultList(workOrder.Id, searchService);
                
            }
            
            if (searchService != null) {
                resMap.put('searchService', searchService);
            }
            resMap.put('workOrderId', workOrder.Id);
            resMap.put('flag', 'success');
        } 
        catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }

    /**
    * @description DNSA Service Report Save
    **/
    @AuraEnabled
    public static Map<String, Object> saveDNSAServiceReport(Map<String, Object> fieldMap) {
        Map<String, Object> resMap = new Map<String, Object>();
        List<Id> updatedWorkIds = new List<Id>();
        List<Id> syncWorkListIds = new List<Id>();
        List<Map<String, String>> docMapList = new List<Map<String, String>>();

        try {
            System.debug('savePaidService fieldMap ::: ' + JSON.serialize(fieldMap, true));
            Map<Object, Object> serviceReportInfo = (Map<Object, Object>) fieldMap.get('serviceReportInfo');

            List<Object> workList = (List<Object>) fieldMap.get('workList');
            String assetName = (String) serviceReportInfo.get('assetName');
            String worker = (String) fieldMap.get('worker');
            String workCenter = (String) fieldMap.get('workCenter');

            List<Asset> assetDataList = [SELECT Id, AccountId FROM Asset WHERE Name =:assetName LIMIT 1];
            Asset assetData = null;

            if (assetDataList.isEmpty()) {
                resMap.put('flag', 'WARNING');
                resMap.put('message', 'Asset does not exist.');
                return resMap;
            } else {
                assetData = assetDataList[0];    
            }

            // Delete
            Set<Id> deletedWorkIds = new Set<Id>();
            List<Object> deletedWorkList = (List<Object>) fieldMap.get('deletedWorkList');

            if (deletedWorkList != null) {
                for (Object idValue : deletedWorkList) {
                    deletedWorkIds.add((String) idValue);
                }
            }

            if (!deletedWorkIds.isEmpty()) {
                List<WorkOrderResult__c> worList = [ SELECT Id FROM WorkOrderResult__c WHERE Id IN :deletedWorkIds ];
                delete worList;
            }

            // Delete File List
            List<String> deletedFileIds = new List<String>();
            List<Object> deletedFileList = (List<Object>) fieldMap.get('deletedFileList');
            if (deletedFileList != null) {
                for (Object idValue : deletedFileList) {
                    deletedFileIds.add((String) idValue);
                }
                docMapList = fileRemove(deletedFileIds);
                resMap.put('docMapList', docMapList); // RFC에 전달하기 위한 파일 삭제 목록
            }

            String workOrderId    = (String) fieldMap.get('workOrderId');
            Map<Object, Object> workOrderResultInfo    = (Map<Object, Object>) fieldMap.get('workOrderResultData');
            Map<Object, Object> selectedBrokenArea     = (Map<Object, Object>) workOrderResultInfo.get('selectedBrokenArea');
            Map<Object, Object> selectedPhenomenon     = (Map<Object, Object>) workOrderResultInfo.get('selectedPhenomenon');
            Map<Object, Object> selectedCauseArea      = (Map<Object, Object>) workOrderResultInfo.get('selectedCauseArea');
            Map<Object, Object> selectedRepairAction   = (Map<Object, Object>) workOrderResultInfo.get('selectedRepairAction');
            Map<Object, Object> selectedBrokenStatus   = (Map<Object, Object>) workOrderResultInfo.get('selectedBrokenStatus');

            String reportType           = (String) serviceReportInfo.get('reportType');
            String repairStartDate      = (String) serviceReportInfo.get('repairStartDate');
            String repairEndDate        = (String) serviceReportInfo.get('repairEndDate');
            String signatureDate        = (String) serviceReportInfo.get('signatureDate');

            if (assetData != null) {
                WorkOrder paidWorkOrder = new WorkOrder();

                // 수리이력
                if(selectedBrokenArea != null) {
                    paidWorkOrder.FailureAreaValue__c            = selectedBrokenArea.get('brokenAreaGroup') != null ? (String) selectedBrokenArea.get('brokenAreaGroup') : '';
                    paidWorkOrder.FailureAreaGroupValue__c       = selectedBrokenArea.get('brokenAreaCode') != null ? (String) selectedBrokenArea.get('brokenAreaCode') : '';
                    paidWorkOrder.FailureArea__c                 = selectedBrokenArea.get('failureArea') != null ? (String) selectedBrokenArea.get('failureArea') : '';
                    paidWorkOrder.FailureAreaGroup__c            = selectedBrokenArea.get('failureAreaDetail') != null ? (String) selectedBrokenArea.get('failureAreaDetail') : '';
                }
                
                if (selectedPhenomenon != null) {
                    paidWorkOrder.FailurePhenomenonValue__c      = selectedPhenomenon.get('phenomenonCode') != null ? (String) selectedPhenomenon.get('phenomenonCode') : '';
                    paidWorkOrder.FailurePhenomenon__c           = selectedPhenomenon.get('phenomenonPart') != null ? (String) selectedPhenomenon.get('phenomenonPart') : '';
                    paidWorkOrder.FailurePhenomenonDetail__c     = selectedPhenomenon.get('phenomenonDetail') != null ? (String) selectedPhenomenon.get('phenomenonDetail') : '';
                }
                
                if (selectedCauseArea != null) {
                    paidWorkOrder.CauseOfFailureValue__c         = selectedCauseArea.get('causeAreaCode') != null ? (String) selectedCauseArea.get('causeAreaCode') : '';
                    paidWorkOrder.CauseOfFailure__c              = selectedCauseArea.get('causeAreaPart') != null ? (String) selectedCauseArea.get('causeAreaPart') : '';
                    paidWorkOrder.CauseOfFailureDetail__c        = selectedCauseArea.get('causeAreaDetail') != null ? (String) selectedCauseArea.get('causeAreaDetail') : '';
                }

                if (selectedRepairAction != null) {
                    paidWorkOrder.RepairActionValue__c           = selectedRepairAction.get('repairActionCode') != null ? (String) selectedRepairAction.get('repairActionCode') : '';
                    paidWorkOrder.RepairAction__c                = selectedRepairAction.get('repairActionPart') != null ? (String) selectedRepairAction.get('repairActionPart') : '';
                    paidWorkOrder.PendingOrCustomerMatters__c    = selectedRepairAction.get('repairActionDetail') != null ? (String) selectedRepairAction.get('repairActionDetail') : '';
                }

                paidWorkOrder.Id    = workOrderId;
                paidWorkOrder.Report_Type__c                 = reportType != null ? reportType : '';
                paidWorkOrder.RepairStartDate__c             = (Date) Date.valueOf(repairStartDate);
                if (String.isNotBlank(repairEndDate)) {
                    paidWorkOrder.RepairEndDate__c               = (Date) Date.valueOf(repairEndDate);
                    
                    paidWorkOrder.Status = 'Completed';
                    paidWorkOrder.ConfirmedDate__c = datetime.now();
                } else {
                    paidWorkOrder.RepairEndDate__c    = null;
                }
                
                paidWorkOrder.isMachineDown__c             = (Boolean) serviceReportInfo.get('isMachineDown');
                paidWorkOrder.ServiceEngineerName__c       = serviceReportInfo.get('serviceEngineerName')!= null ? (String) serviceReportInfo.get('serviceEngineerName') : '';
                paidWorkOrder.SignatureDate__c             = (Date) Date.valueOf(signatureDate);
                paidWorkOrder.CustomerName__c              = serviceReportInfo.get('customerName') != null ? (String) serviceReportInfo.get('customerName') : '';
                paidWorkOrder.CustomerPosition__c          = serviceReportInfo.get('customerPosition') != null ? (String) serviceReportInfo.get('customerPosition') : '';

                if(paidWorkOrder != null) {
                    update paidWorkOrder;
                }
            }
                            
            // 작업내역 추가 레코드 처리
            if (workList != null && workList.size() > 0) {
                List<Id> addRecordsIds = saveChildWorkList(workList, workOrderId);
                updatedWorkIds.addAll(addRecordsIds);
                syncWorkListIds.addAll(addRecordsIds);
            }

            // 부품 사용내역 추가 레코드 처리
            List<WorkOrderResult__c> insertProductUsedList = New List<WorkOrderResult__c>();
            List<WorkOrderResult__c> updateProductUsedList = New List<WorkOrderResult__c>();
            List<Object> usageList = (List<Object>) fieldMap.get('usageList');
            
            for (Integer i = 0; i < usageList.size(); i++) {
                Map<Object, Object> recordData = (Map<Object, Object>) usageList[i];
                WorkOrderResult__c record = new WorkOrderResult__c();
                
                record.WorkOrder__c = workOrderId;
                record.ResultType__c = 'PT';
                record.ProductNumber__c = (String) recordData.get('productCode');
                record.ProductName__c = (String) recordData.get('productName');
                record.IsCause__c =  (Boolean) recordData.get('isCause');
                record.Quantity__c = (Decimal)recordData.get('quantity');
                record.Note__c =  (String) recordData.get('returnNote');

                if(String.isNotBlank((String) recordData.get('workId'))) {
                    record.Id = (String) recordData.get('workId');
                    updateProductUsedList.add(record);
                } else {
                    insertProductUsedList.add(record);
                }
            }

            if (!insertProductUsedList.isEmpty()) {
                insert insertProductUsedList;
            }
            if (!updateProductUsedList.isEmpty()) {
                update updateProductUsedList;
            }

            // 1. 업로드 되어있던 파일 HTML로 변환하여 새로운 ContentVersion 생성
            List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :workOrderId];
            System.debug('SELECT contentLinks ::: ' + JSON.serialize(contentLinks));

            List<Id> contentDocumentIdList = new List<Id>();
            for (ContentDocumentLink link : contentLinks) {
                contentDocumentIdList.add(link.ContentDocumentId);
            }

            List<ContentVersion> contentVersions = [SELECT Id, Title, FileExtension, VersionData ,DealerPotalFileType__c, ERPDocNo__c, IsDealerPotalERP__c
                                                    FROM ContentVersion 
                                                    WHERE IsDealerPotalERP__c = false AND ERPDocNo__c = null AND ContentDocumentId IN :contentDocumentIdList];

                                                    System.debug('SELECT contentVersions ::: ' + JSON.serialize(contentVersions));

            List<Id> contentVersionIdList = new List<Id>();
            for (ContentVersion version : contentVersions) {
                contentVersionIdList.add(version.Id);
            }
            IF_FilePackingService service = new IF_FilePackingService(); 
            List<Id> packedFileConversionIds =  service.packingToListByHTML(contentVersionIdList);

            // 2. 저장 시 HTML로 연결된 파일 Content Version HTML로 변환
            resMap.put('convertFileIds', packedFileConversionIds); 

            DN_PortalServiceWrapper searchService   = new DN_PortalServiceWrapper();
            List<WorkOrder> workOrderList = [SELECT Id, AssetId, FM_WorkOrderResult_Template__c FROM WorkOrder WHERE Id =:workOrderId LIMIT 1];
            if (!workOrderList.isEmpty()) {
                WorkOrder workOrder =  workOrderList[0];
                String orderRTNumber = workOrder.FM_WorkOrderResult_Template__c;

                searchService = searchServiceReportInfo(workOrder, searchService);
    
                if (searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber) != null) {
                    searchService = searchWorkOrderResultInfo(workOrder.Id, searchService, orderRTNumber);
                } 
                    
                if (searchWorkOrderResultList(workOrder.Id, searchService) != null) {
                    searchService = searchWorkOrderResultList(workOrder.Id, searchService);
                }
                
                if (searchService != null) {
                    resMap.put('searchService', searchService);
                }
                resMap.put('flag', 'success');
            }
            
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 부품 사용 내역 Dependency Picklist 
    **/
    @AuraEnabled
    public static List<Map<String,String>> getPicklistValueList(String fieldValue, String fieldName) {
        System.debug('selectedValueMap ::: ' + fieldValue + 'Key ::: ' + fieldName);
        List<Map<String,String>> picklistValues = new List<Map<String,String>>();

        try {
            if (fieldName == 'returnStatus') {
                List<Map<String,String>> valuesReturnType = DN_PortalServiceReportController.getDependentPicklistValues(ProductRequest.ReturnType__c).get(fieldValue);
                if (!valuesReturnType.isEmpty()) {
                    picklistValues = valuesReturnType;
                } else {
                    picklistValues = null;
                    return picklistValues;
                }
            } else if (fieldName == 'returnType') {
                if(ProductRequest.Reason1__c != null){
                    List<Map<String,String>> valuesFirstReason = DN_PortalServiceReportController.getDependentPicklistValues(ProductRequest.Reason1__c).get(fieldValue);
                    if (!valuesFirstReason.isEmpty()) {
                        picklistValues = valuesFirstReason;
                    } else {
                        picklistValues = null;
                        return picklistValues;
                    }
                }else{
                    picklistValues = null;
                    return picklistValues;
                }
                
            } else if (fieldName == 'firstReason') {
                List<Map<String,String>> valuesSecondReason = DN_PortalServiceReportController.getDependentPicklistValues(ProductRequest.Reason2__c).get(fieldValue);
                if (!valuesSecondReason.isEmpty()) {
                    picklistValues = valuesSecondReason;
                } else {
                    picklistValues = null;
                    return picklistValues;
                }
            } else {
                picklistValues.add(null);
            }
            
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getLineNumber() + 'MSG' + e.getMessage());
        }
        return picklistValues;
    }

    /**
    * @description 부품 사용 내역 Dependency Picklist 단계 별 Values 반환
    **/
    public static Map<String, List<Map<String, String>>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<Map<String, String>>>();
        }
    
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if (control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
    
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String, List<Map<String, String>>> dependentPicklistValues = new Map<String, List<Map<String, String>>>();
    
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars = String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
    
                    if (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0)
                        continue;
    
                    // Initialize if control value is not present
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<Map<String, String>>());
                    }
    
                    // Add label and value for each dependent picklist
                    dependentPicklistValues.get((String) controlValue).add(new Map<String, String>{
                        'label' => entry.getLabel(),
                        'value' => entry.getValue()
                    });
                }
            }
        }
        
        return dependentPicklistValues;
    }

    // 수리내역 고장부위(대) 조회
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getFailureAreaMajor(String objectType) {
        return DN_FailureAreaController.getFailureAreaMajor(objectType);
    }
    // 수리내역 고장부위(중) 조회
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getFailureAreaMiddle(String majorValue) {
        return DN_FailureAreaController.getFailureAreaMiddle(majorValue);
    }
    // 수리내역 고장현상 조회
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getFailurePhenomenon(String middleValue) {
        return DN_FailureAreaController.getFailurePhenomenon(middleValue);
    }
    // 수리내역 고장원인 조회
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getFailureCause(String phenomenonValue) {
        return DN_FailureAreaController.getFailureCause(phenomenonValue);
    }
    // 수리내역 조치사항 조회
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getRepairAction(String objectType) {
        return DN_FailureAreaController.getRepairAction(objectType);
    }

    /**
    * @description DNSA Service Report Type 초기 픽리스트 밸류 조회
    **/
    @AuraEnabled
    public static Map<String, Object> getServiceReportType() {
        Map<String, Object> resMap = new Map<String, Object>();
        List<PicklistWrapper>   picklistValues  = new List<PicklistWrapper>();
        Schema.DescribeFieldResult fieldResult      = Schema.SObjectType.WorkOrder.fields.getMap().get('Report_Type__c').getDescribe();
        List<Schema.PicklistEntry> picklistEntries  = fieldResult.getPicklistValues();        
        picklistValues.add(new PicklistWrapper('None', ''));
        for (Schema.PicklistEntry entry : picklistEntries) {
            if (entry.isActive()) {
                picklistValues.add(new PicklistWrapper(entry.getLabel(), entry.getValue()));
            }
        }
        resMap.put('picklistValues' , picklistValues);
        resMap.put('flag'           , 'success');
        return resMap;
    }

    /**
    * @description DNSA Service Report Type 초기 픽리스트 Wrapper
    **/
    public class PicklistWrapper {
        @AuraEnabled public String label  {get;set;} 
        @AuraEnabled public String value  {get;set;} 

        public PicklistWrapper() {}

        public PicklistWrapper(String Label, String Value) {
            this.label = Label;
            this.value = Value;
        }
    }

    /** 
    * @description 딜러포탈에서 서비스 리포트에서 파일타입 : 서비스리포트,기타자료 첨부로 구분하기 위함
    * @author iltae.seo | 2024-11-27
    * @param List<FileInfo>
    * @return List<ContentVersion>
    **/
    @AuraEnabled
    public static Map<String, Object> uploadfinished(List<FileInfo> fileList) {
        try {
            Map<String, Object> resMap = new Map<String, Object>();

            List<ContentVersion> contentVersionList = new List<ContentVersion>();

            for(FileInfo file: fileList) {
                ContentVersion cont = new ContentVersion();
                cont.Id = file.contentVersionId;
                cont.DealerPotalFileType__c = file.fileType;
                cont.IsDealerPotal__c = true;
                contentVersionList.add(cont);
            }

            if(contentVersionList.size() > 0) {
                update contentVersionList;
            }   
            return resMap;
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        } 
      
    }
    
    /**
    * @description 현재 서비스 리포트(서비스 오더) 기준 파일 조회
    **/
    @AuraEnabled
    public static List<FileInfo> getFileList(String recordId){
        try {
            set<String> docIds = new set<String>();
            List<FileInfo> fileInfoList = new List<FileInfo>();
            List<ContentDocumentLink> docLinkList = [select Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility from ContentDocumentLink 
                                                        where LinkedEntityId =:recordId];
            for(ContentDocumentLink conLink : docLinkList) {
                docIds.add(conLink.ContentDocumentId);
            }
            List<ContentVersion> conVersionList = [select Id,VersionDataUrl, ContentDocumentId,Title,FileType,DealerPotalFileType__c, ERPDocNo__c, IsDealerPotalERP__c from ContentVersion 
                                                        where IsLatest =true 
                                                        AND ContentDocumentId IN :docIds];
                                                        
            // Sersvice Report를 통해 만들어진 보고서 확인
            Set<Id> srCVIdSet = new Set<Id>();
            for (ServiceReport sr : [SELECT ID, ContentVersionDocumentId FROM ServiceReport WHERE ParentId = :recordId]){
                srCVIdSet.add(sr.ContentVersionDocumentId);
            }
            
            for(ContentVersion cv: conVersionList) {
                if(srCVIdSet.contains(cv.Id)) {
                    FileInfo tmpFile = new FileInfo();
                    tmpFile.contentDocumentId = cv.ContentDocumentId;
                    tmpFile.contentVersionId = cv.Id;
                    tmpFile.fileType = 'report';
                    tmpFile.fileVersionURL = cv.VersionDataUrl;
                    tmpFile.title = cv.Title;
                    tmpFile.isDelete = false;
                    tmpFile.isERP = cv.IsDealerPotalERP__c;
                    tmpFile.erpDocNo = cv.ERPDocNo__c;
                    fileInfoList.add(tmpFile);
                } else {
                    fileInfoList.add(new FileInfo(cv));
                }            
            }
            return fileInfoList;
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
    }

    /**
    * @description 파일 삭제
    **/
    @AuraEnabled
    public static List<Map<String, String>> fileRemove(List<String> fileIds) {
        List<Map<String, String>> docMapList = new List<Map<String, String>>();

        try {
            if (fileIds != null && !fileIds.isEmpty()) {
                
                List<ContentVersion> contentVersions = [SELECT Id, ERPDocNo__c, DealerPotalFileType__c FROM ContentVersion WHERE ContentDocumentId IN :fileIds];

                for (ContentVersion content : contentVersions) {
                    if (content.ERPDocNo__c != null) {
                        Map<String, String> tempMap = new Map<String, String>();
                        tempMap.put('erpDocNo', content.ERPDocNo__c);
                        tempMap.put('reportType', content.DealerPotalFileType__c);
                        docMapList.add(tempMap);
                    }
                }

                List<ContentDocument> deleteList = [SELECT Id FROM ContentDocument WHERE Id IN :fileIds];
                delete deleteList;
            }
            System.debug('docMapList ::: ' + JSON.Serialize(docMapList));
            
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        
        return docMapList;
    }

    /**
    * @description 부품진행상태 Call 메서드
    **/
    @AuraEnabled
    public static Map<String, Object> searchPartCallOut(String orderNumber) {
        DN_PartProgressController.SearchObject searchObject = new DN_PartProgressController.SearchObject();
        Map<String, Object> resMap = new Map<String, Object>();
        
        Date today = Date.today();
        String monthStr = today.month() < 10 ? '0' + today.month() : String.valueOf(today.month());
        String dayStr = today.day() < 10 ? '0' + today.day() : String.valueOf(today.day());
        String todayStr = today.year() + '-' + monthStr + '-' + dayStr;
        
        Date oneYearAgo = Date.today().addYears(-3);
        String oneYearAgomonthStr = oneYearAgo.month() < 10 ? '0' + oneYearAgo.month() : String.valueOf(oneYearAgo.month());
        String oneYearAgodayStr = oneYearAgo.day() < 10 ? '0' + oneYearAgo.day() : String.valueOf(oneYearAgo.day());
        String oneYearAgoStr = oneYearAgo.year() + '-' + oneYearAgomonthStr + '-' + oneYearAgodayStr;
        
        searchObject.searchStartDate = oneYearAgoStr;
        searchObject.searchEndDate = todayStr;
        searchObject.searchOrderNumber = orderNumber;
        try {
            DN_PartProgressController.PartsResultWrapper partCheck = DN_PartProgressController.getPartsList(searchObject);
            resMap.put('Parts', partCheck);
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            resMap.put('flag', 'error');
            resMap.put('Message', 'catch Exception ::: ' + e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }
    
    /**
    * @description 파일 정보 Wrapper
    **/
    public class FileInfo {
        @AuraEnabled public String  contentDocumentId   {get;set;}
        @AuraEnabled public String  title               {get;set;}
        @AuraEnabled public String  contentVersionId    {get;set;}
        @AuraEnabled public String  fileType            {get;set;}
        @AuraEnabled public String  fileVersionURL      {get;set;}
        @AuraEnabled public Boolean isDelete            {get;set;}
        @AuraEnabled public String  fileTitle           {get;set;} 
        @AuraEnabled public Boolean isERP               {get;set;} 
        @AuraEnabled public String  erpDocNo            {get;set;} 
    
        public FileInfo() {}
    
        public FileInfo(ContentVersion cont) {
            this.contentDocumentId = cont.ContentDocumentId;
            this.contentVersionId = cont.Id;
            this.fileType = cont.DealerPotalFileType__c;
            this.isERP = cont.IsDealerPotalERP__c;
            this.erpDocNo = cont.ERPDocNo__c;
            this.fileVersionURL = cont.VersionDataUrl;
            this.title = cont.Title;
            this.isDelete = true;
            this.fileTitle = cont.Title;
        }
    }
    
    /**
    * @description DNSA Service Report Print page
    **/
    public String recordId { get; set; }
    public String startTime { get; set; }
    public String endTime { get; set; }
    public Decimal totalWorkTime { get; set; }
    public Decimal totalTravelHour { get; set; }
    public String failureDate { get; set; } 
    public String registeredDate { get; set; }
    public String requiredEndDate { get; set; }
    public String engineerSignature {get; set;}
    public String customerSignature {get; set;}
    public String engineerName {get; set;}
    public String customerName {get; set;}

    public DN_PortalServiceWrapper serviceWrapper { get; set; }

    public DN_PortalServiceReportController() {
        serviceWrapper = new DN_PortalServiceWrapper();

        totalWorkTime = 0;
        totalTravelHour = 0;
        
        System.debug('DNSA recordId ::: ' + ApexPages.currentPage().getParameters().get('recordId'));

        try {
            recordId = '';
            String engiSigId = '';
            String custSigId = '';
            engineerName = '';
            customerName = '';

            engineername = ApexPages.currentPage().getParameters().get('engineerName');
            customerName = ApexPages.currentPage().getParameters().get('customerName');
            recordId = ApexPages.currentPage().getParameters().get('recordId');
            if(String.isNotBlank(engineername) && String.isNotBlank(customerName)){
                engineerSignature = SignatureContainerController.getSignature(recordId, 'Signature-Engineer-FSL');
                customerSignature = SignatureContainerController.getSignature(recordId, 'Signature-Customer-FSL');
            }else{
                engineerSignature = SignatureContainerController.getSignature(recordId, 'engineer');
                customerSignature = SignatureContainerController.getSignature(recordId, 'customer');
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }    
    
    public void calculateTotals() {
        if(serviceWrapper.workList != null){
            for(DN_PortalServiceWrapper.WorkList wl : serviceWrapper.workList) {
                totalWorkTime += Decimal.valueOf(wl.workTime);
                totalTravelHour += Decimal.valueOf(wl.travelHour);
                wl.workStartTime = wl.workStartTime.substring(0,8);
                wl.workEndTime = wl.workEndTime.substring(0,8);
            }
        }
    }
    
    public void getAction() {
        try {
            WorkOrder wo = [ SELECT Id, WorkOrderNumber, ServiceOrderNumber__c, FM_WorkOrderResult_Template__c FROM WorkOrder WHERE Id = :recordId LIMIT 1 ];
            serviceWrapper = searchServiceReportInfo(wo, serviceWrapper);
            serviceWrapper = searchWorkOrderResultInfo(wo.Id, serviceWrapper, wo.FM_WorkOrderResult_Template__c);
            serviceWrapper = searchWorkOrderResultList(wo.Id, serviceWrapper);

            System.debug('serviceWrapper ::: ' + JSON.serialize(serviceWrapper));


            if (String.isNotBlank(serviceWrapper.repairHistoryInfo.selectedPhenomenon.phenomenonDetail) && serviceWrapper.repairHistoryInfo.selectedPhenomenon.phenomenonDetail.contains('\n')) {
                serviceWrapper.repairHistoryInfo.selectedPhenomenon.phenomenonDetail = serviceWrapper.repairHistoryInfo.selectedPhenomenon.phenomenonDetail.replaceAll('\n', '<br/>');
            }
            if (String.isNotBlank(serviceWrapper.repairHistoryInfo.selectedCauseArea.causeAreaDetail) && serviceWrapper.repairHistoryInfo.selectedCauseArea.causeAreaDetail.contains('\n')) {
                serviceWrapper.repairHistoryInfo.selectedCauseArea.causeAreaDetail = serviceWrapper.repairHistoryInfo.selectedCauseArea.causeAreaDetail.replaceAll('\n', '<br/>');
            }
            if (String.isNotBlank(serviceWrapper.repairHistoryInfo.selectedRepairAction.repairActionDetail) && serviceWrapper.repairHistoryInfo.selectedRepairAction.repairActionDetail.contains('\n')) {
                serviceWrapper.repairHistoryInfo.selectedRepairAction.repairActionDetail = serviceWrapper.repairHistoryInfo.selectedRepairAction.repairActionDetail.replaceAll('\n', '<br/>');
            }
            
            if(String.isNotBlank(serviceWrapper.serviceReportInfo.failureDate)) {
                failureDate = serviceWrapper.serviceReportInfo.failureDate.substring(0,10);
                system.debug('failureDate ::: ' + failureDate);
            } else {
                failureDate = null;
            }
            if(String.isNotBlank(serviceWrapper.serviceReportInfo.applicationDateTime)) {
                registeredDate = serviceWrapper.serviceReportInfo.applicationDateTime.substring(0,10);
                system.debug('registeredDate ::: ' + registeredDate);
            } else {
                registeredDate = null;
            }
            if(String.isNotBlank(serviceWrapper.serviceReportInfo.repairRequestDateTime)) {
                requiredEndDate = serviceWrapper.serviceReportInfo.repairRequestDateTime.substring(0,10);
                system.debug('requiredEndDate ::: ' + requiredEndDate);
            } else {
                requiredEndDate = null;
            }
            if(String.isNotBlank(engineerName)){
                serviceWrapper.serviceReportInfo.serviceEngineerName = engineerName;
            }
            if(String.isNotBlank(customerName)){
                serviceWrapper.serviceReportInfo.customerName = customerName;
            }
            
            calculateTotals();
        } catch (Exception e) {
            
        } 
    }

    /**
    * @description DNSA 서비스 리포트 프린트되는 PDF 파일 메일로 전송
    **/
    @AuraEnabled
    public static String sendPDFEmail(String emailAddresses, Id recordId) {
        try {
            PageReference pdfPage = Page.DN_ServiceReportAPrint;
            pdfPage.getParameters().put('recordId', String.valueOf(recordId));
            Blob pdfBlob;
            if(Test.isRunningTest()){
                pdfBlob = Blob.valueOf('dummy pdf content');
            } else {
                pdfBlob = pdfPage.getContentAsPDF();
            }

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('ServiceReport.pdf');
            attachment.setBody(pdfBlob);
            attachment.setContentType('application/pdf');

            List<String> splitEmailAddress = emailAddresses.split('[,;]');
            Set<String> setEmails = new Set<String>();

            for (String email : splitEmailAddress) {
                email = email.trim().replaceAll('\\s+', '');
                if (!String.isEmpty(email)) {
                    setEmails.add(email);
                }
            }

            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<OrgWideEmailAddress> owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress]; 

            for (String singleEmail : setEmails) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ singleEmail });
                mail.setSubject('Service Report PDF');
                mail.setPlainTextBody('Please find attached the service report PDF.');
                mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });
                mail.setOrgWideEmailAddressId(owea.get(0).Id);

                emailList.add(mail);
            }

            if (!emailList.isEmpty()) {
                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emailList);
                Boolean allSuccess = true;
                for (Messaging.SendEmailResult result : emailResult) {
                    if (!result.isSuccess()) {
                        allSuccess = false;
                        System.debug('Email failed: ' + result.getErrors()[0].getMessage());
                    }
                }
                return allSuccess ? 'All emails sent successfully' : 'Some emails failed to send';
            } else {
                return 'No valid email addresses provided';
            }
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
            return 'Error sending email: ' + e.getMessage();
        }
    }
}