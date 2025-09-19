/**
 * @description       : 포탈 서비스 관리 Controller
 * @author            : Chungwoo Lee
 * @last modified on  : 05-23-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-01-2024   Chungwoo Lee   Initial Version
**/
public without sharing class DN_PortalServiceController {

    /**
    * @description 로그인된 사용자 정보 조회 
    **/
    @AuraEnabled
    public static Map<String, Object> getLoginUserInfo() {
        Map<String, Object> resMap = new Map<String, Object>();
        String workCenter = '';
        Boolean isBranch = false;
        List<ServiceResource> workerInfoList = new List<ServiceResource>(); 
        ServiceTerritory workCenterInfo = new ServiceTerritory(); 
        try {
            if (String.isBlank(UserInfo.getUserId())) {
                workCenter = '';
                resMap.put('flag','warning');
                resMap.put('message', 'Please check your login status.');
                return resMap;
            } else {
                workerInfoList  = [SELECT Id , Name , Service_Territory__c, Service_Territory__r.Name, Service_Territory__r.ControlWorkcenter__c , Service_Territory__r.classify__c, AccountId, Account.Name, RelatedRecordId
                                FROM ServiceResource WHERE RelatedRecordId =: UserInfo.getUserId() LIMIT 1];
    
                if(workerInfoList.isEmpty()) {
                    resMap.put('workerInfo', '');
                    resMap.put('flag','warning');
                    resMap.put('message', 'This user is not registered as a worker.');
                    return resMap;
                } else {
                    ServiceResource workerInfo = workerInfoList[0];
                    workCenterInfo  = [SELECT Id , Name, ControlWorkcenter__c, classify__c, PlanningPlant__c FROM ServiceTerritory WHERE Id =: workerInfo.Service_Territory__c LIMIT 1];

                    if (workerInfo.Service_Territory__r.classify__c == '지사') {
                        isBranch = true;
                    }
                    resMap.put('isBranch', isBranch);
                    resMap.put('workCenterInfo', workCenterInfo);
                    resMap.put('workerInfo', workerInfo);
                    resMap.put('flag', 'success');
                }
            }
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 서비스 조회 시 로그인 유저의 워크센터 기반 조회 (지사의 경우 하위 워크센터 조회 가능)
    **/
    @AuraEnabled
    public static Map<String, Object> getLoginUserWorkCenter() {
        Map<String, Object> resMap = new Map<String, Object>();
        Id sUserId = userInfo.getUserId();
        
        ServiceResource currentWorkcenterUser = [SELECT 
        Id, Service_Territory__c, Service_Territory__r.WCCode__c, Service_Territory__r.Name, Service_Territory__r.PlanningPlant__c, Service_Territory__r.classify__c, Service_Territory__r.ControlWorkcenter__c, Service_Territory__r.ControlWorkcenter__r.Name,
        RelatedRecordId, RelatedRecord.UserCode__c, RelatedRecord.SalesOrganization__c, RelatedRecord.DistributionChannel__c
        FROM ServiceResource WHERE RelatedRecordId = :sUserId LIMIT 1];
        
        List<ServiceTerritory> relatedWorkcenter = new List<ServiceTerritory>();
        String wcDivision = currentWorkcenterUser.Service_Territory__r.classify__c;
        String wcCode = currentWorkcenterUser.Service_Territory__r.WCCode__c;
        String wcPlant = currentWorkcenterUser.Service_Territory__r.PlanningPlant__c;
        relatedWorkcenter.add(new ServiceTerritory( Id = currentWorkcenterUser.Service_Territory__c, WCCode__c = wcCode, Name = currentWorkcenterUser.Service_Territory__r.Name, PlanningPlant__c = wcPlant, classify__c = wcDivision ));
        
        if('184S'.equals(wcPlant)) {
            if('지사'.equals(wcDivision) || 'POST'.equals(wcDivision)) {
                String lv1Code = wcCode.left(4) + '%';
                relatedWorkcenter.addAll([SELECT Id, WCCode__c, Name, PlanningPlant__c, classify__c FROM ServiceTerritory WHERE ControlWorkcenter__r.WCCode__c LIKE :lv1Code]);
            }
        }
        System.debug(relatedWorkcenter);
        resMap.put('wcList', relatedWorkcenter);
        return resMap;
    }

    /**
    * @description 서비스 이력 조회 (영업 포탈)
    * @author Chungwoo Lee | 11-21-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> getServiceHistoryList(Map<String, Object> searchData) {
        Map<String, Object> resMap = new Map<String, Object>();
        List<WorkOrder> serviceHistoryList = new List<WorkOrder>();
        User currentUser = [SELECT Id, Name, UserRole.Name, AccountId, Profile.Name, SalesOffice__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        
        if(currentUser == null) {
            resMap.put('flag', 'NoneUserInfo');
            resMap.put('message', 'Please check your login status.');
            return resMap;
        } 

        try {
            String psoNumber = (String) searchData.get('psoNumber');
            String customerCode = (String) searchData.get('customerCode');
            String customerName = (String) searchData.get('customerName');
            String machineName = (String) searchData.get('machineName');
            String assetName = (String) searchData.get('assetName');

            Datetime receiptDateFrom = Date.valueOf(((String)searchData.get('receiptDateFrom')).substring(0, 10));
            Datetime receiptDateTo =  Date.valueOf(((String)searchData.get('receiptDateTo')).substring(0, 10)).addDays(1);

            String queryString = 'SELECT Id, WorkOrderNumber, CreatedDate, toLabel(OrderType__c), toLabel(PMActivityType__c), '+ 
                                'ServiceOrderNumber__c, ConfirmedDate__c, InspectionDetails__c, Account.CustomerCode__c, Account.Name, Account.SalesOffice__c, Asset.InstallationFinish__c, ' +
                                'Asset.WarrantyStartDateWages__c, Asset.MachineName__c, Asset.Name, Asset.Order__r.ERPPSONo__c, Case.ApplicationDateTime__c,' +
                                'Case.CreatedDate, Case.ClosedDate, Case.Description, Case.ReceptionDetails__c, ' +
                                'Case.ResultOfMeasure__c, ServiceTerritory.Name, Worker__r.Name, PendingOrCustomerMatters__c ' +
                                'FROM WorkOrder ';

            List<String> whereString = new List<String>();

            if (receiptDateFrom != null) {
                whereString.add('Case.ApplicationDateTime__c >= ' + receiptDateFrom.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
            }
            if (receiptDateTo != null) {
                whereString.add('Case.ApplicationDateTime__c < ' + receiptDateTo.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
            }
            
            if (String.isNotBlank(psoNumber)) {
                whereString.add('Asset.Order__r.ERPPSONo__c = \'' + String.escapeSingleQuotes(psoNumber) + '\'');
            }
            if (String.isNotBlank(customerCode)) {
                whereString.add('Account.CustomerCode__c = \'' + String.escapeSingleQuotes(customerCode) + '\'');
            }
            if (String.isNotBlank(machineName)) {
                whereString.add('Asset.MachineName__c = \'' + String.escapeSingleQuotes(machineName) + '\'');
            }
            if (String.isNotBlank(assetName)) {
                whereString.add('Asset.Name = \'' + String.escapeSingleQuotes(assetName) + '\'');
            }

            // 딜러포탈(영업) 서비스 이력 조회 시 영업 딜러(현재 로그인된 유저)가 판매한 장비의 서비스 이력을 조회
            if (currentUser.UserRole.Name.contains('Manager') || currentUser.UserRole.Name.contains('관리자')) {
                whereString.add('Asset.Order__r.RelatedDealer__c = \'' + String.escapeSingleQuotes(currentUser.AccountId) + '\'');
            } else if (currentUser.Profile.Name.contains('직영영업') || currentUser.Profile.Name.contains('영업 지원')) {
                //whereString.add('Account.SalesOffice__c = \'' + String.escapeSingleQuotes(currentUser.SalesOffice__c) + '\'');
            } else {
                whereString.add('Asset.Order__r.OwnerId = \'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\'');
            }
            
            if (!whereString.isEmpty()) {
                queryString += ' WHERE ' + String.join(whereString, ' AND ');
            }

            System.debug('queryString ::: ' + JSON.serialize(queryString,true));

            queryString += ' ORDER BY CreatedDate DESC LIMIT 2000';

            serviceHistoryList = Database.query(queryString);

            if (serviceHistoryList.isEmpty()) {
                resMap.put('flag', 'warning');
                resMap.put('message', 'No records found.');
            } else {
                resMap.put('flag', 'success');
                resMap.put('serviceHistoryList', serviceHistoryList);
            }
            resMap.put('queryString', queryString);
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 서비스 진행업무 조회
    * @author Chungwoo Lee | 11-12-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> searchProgressWork(Map<String, Object> searchData) {
        Map<String, Object> resMap = new Map<String, Object>();
        
        ServiceResource loginUserInfo;

        User currentLoginUser = [SELECT Id, IsPortalEnabled FROM User WHERE Id = :userInfo.getUserId()];

        if (!currentLoginUser.IsPortalEnabled) {
            resMap.put('CRM_USER', 'CRM_USER');
        } else {
            List<ServiceResource> loginUserInfoList  = [SELECT Id , Name, Service_Territory__c, RelatedRecord.IsPortalEnabled, Service_Territory__r.PlanningPlant__c FROM ServiceResource WHERE RelatedRecordId =: UserInfo.getUserId() LIMIT 1];
        
            if(!loginUserInfoList.isEmpty()) {
                loginUserInfo = loginUserInfoList[0];
            } else {
                resMap.put('flag', 'notServiceResource');
                return resMap;
            }
        }

        List<WorkOrder> serviceList = new List<WorkOrder>();
        try {
            String workStatus           = (String) searchData.get('workStatus') != '전체' ? (String) searchData.get('workStatus'): '';
            String startDate            = (String) searchData.get('workStartDate') ;
            String endDate              = (String) searchData.get('workEndDate');
            String serviceOrderNumber   = (String) searchData.get('workOrderNumber');
            String orderType            = (String) searchData.get('orderType');
            Boolean hasWarranty         = (Boolean) searchData.get('hasWarranty');

            String queryString = 'SELECT Id, WorkOrderNumber, ServiceOrderNumber__c, toLabel(OrderType__c), toLabel(PMActivityType__c), Status, HasWarrantyDirectManagement__c, ' + 
                     'ServiceTerritory.Name, Worker__r.Name, Asset.MachineName__c, Asset.Name, Asset.WarrantyStartDateWages__c, Account.Name, Account.Representative__c, ' + 
                     'ScheduledDispatchTime__c, Account.Mobile__c, Account.Phone, FM_WorkPlanDateTime__c, Case.ReceptionDetails__c, Case.ApplicationDateTime__c, ' +
                     'Case.RepairRequestDateTime__c, Service_Appointment__r.SchedStartTime, FailurePhenomenonDetail__c, ReceiptDate__c ' +
                     'FROM WorkOrder WHERE Status != \'Canceled\' AND ServiceOrderNumber__c != null AND ';

            List<String> whereString = new List<String>();

            if (loginUserInfo !=null) {
                whereString.add('ServiceTerritoryId = \'' + loginUserInfo.Service_Territory__c + '\'');
            } 
            if (String.isNotBlank(workStatus)) {
                if (workStatus == 'notConfirm') {
                    if ('414S'.equals(loginUserInfo.Service_Territory__r.PlanningPlant__c)) {
                        whereString.add(' Status NOT IN (\'Confirm\',\'Completed\')');
                    } else {
                        whereString.add(' Status != \'' + 'Confirm' + '\'');
                    }
                } else {
                    if ('414S'.equals(loginUserInfo.Service_Territory__r.PlanningPlant__c)) {
                        whereString.add(' Status IN (\'Confirm\',\'Completed\')');
                    } else {
                        whereString.add(' Status = \'' + workStatus + '\'');
                    }
                }
            }
            if (String.isNotBlank(serviceOrderNumber)) {
                whereString.add('ServiceOrderNumber__c = \'' + serviceOrderNumber + '\'');
            }
            if (String.isNotBlank(orderType)) {
                whereString.add('PMActivityType__c = \'' + orderType + '\'');
            }
            if (hasWarranty != null) {
                whereString.add('HasWarrantyDirectManagement__c != ' + hasWarranty);

                if (hasWarranty) {
                    if (startDate != null) {
                        Datetime workStartDate = Datetime.valueOf(startDate + ' ' + '00:00:00');
                        whereString.add('ScheduledDispatchTime__c >= ' + workStartDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + '');
                    }
                    if (endDate != null) {
                        Datetime workEndDate = Datetime.valueOf(endDate + ' ' + '00:00:00').addDays(1);
                        whereString.add('ScheduledDispatchTime__c < ' + workEndDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + '');
                    }
                } else {
                    if (startDate != null) {
                        whereString.add('ReceiptDate__c >= ' + startDate);
                    }
                    if (endDate != null) {
                        whereString.add('ReceiptDate__c <= ' + endDate);
                    }
                }
            }
            if (!whereString.isEmpty()) {
                queryString += String.join(whereString, ' AND ');
            }
            if (hasWarranty) {
                queryString += ' ORDER BY ScheduledDispatchTime__c DESC LIMIT 2000';
            } else {
                queryString += ' ORDER BY ReceiptDate__c DESC LIMIT 2000';
            }
            
            serviceList = Database.query(queryString);

            resMap.put('queryString', queryString);

            if (serviceList.isEmpty()) {
                resMap.put('flag', 'warning');
                resMap.put('message', 'No records found.');
            } else {
                resMap.put('flag', 'success');
                resMap.put('serviceList', serviceList);
            }
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 서비스 이력 조회 (CS 포탈)
    * @author Chungwoo Lee | 11-22-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> getCSServiceHistoryList(Map<String, Object> searchData) {
        Map<String, Object> resMap = new Map<String, Object>();
        List<WorkOrder> serviceHistoryList = new List<WorkOrder>();

        Map<String, Object> loginUserWCList = getLoginUserWorkCenter();
        List<ServiceTerritory> getWCList = (List<ServiceTerritory>) loginUserWCList.get('wcList');

        Set<String> serviceTerritoryIds = new Set<String>();
        for (ServiceTerritory st : getWCList) {
            serviceTerritoryIds.add(st.Id);
        }
        
        try {
            String orderNumber      = (String) searchData.get('orderNumber');
            String customerCode     = (String) searchData.get('customerName');
            String machineName      = (String) searchData.get('machineName');
            String assetName        = (String) searchData.get('assetName');
            String orderType        = (String) searchData.get('orderType');
            String workCenter       = (String) searchData.get('workCenter');
            String worker           = (String) searchData.get('worker');
            String ncType           = (String) searchData.get('ncType');
            String receiptDateFrom  = (String) searchData.get('receiptDateFrom');
            String receiptDateTo    = (String) searchData.get('receiptDateTo');
            
            String queryString = 'SELECT Id, WorkOrderNumber, ServiceOrderNumber__c, CreatedDate, toLabel(OrderType__c), toLabel(PMActivityType__c), '+ 
                                'ConfirmedDate__c, InspectionDetails__c, Account.CustomerCode__c, Account.Name, PendingOrCustomerMatters__c, ' +
                                'Asset.ShippingDate__c, Asset.MachineName__c, Asset.Name, Asset.FM_EquipmentWarrantyEquipmentParts__c, ' +
                                'Case.CreatedDate, Case.ClosedDate, Case.ApplicationDateTime__c, Case.Description, Case.ReceptionDetails__c, Order__r.OrderNumber, ' +
                                'Case.Owner.Name, Case.ResultOfMeasure__c, ServiceTerritory.Name, Worker__r.Name, Asset.NCType__c ' +
                                'FROM WorkOrder WHERE Status != \'Canceled\' AND ServiceOrderNumber__c != null AND ';

            List<String> whereString = new List<String>();

            if (!serviceTerritoryIds.isEmpty()) {
                
                if (String.isNotBlank(workCenter)) {
                    whereString.add('ServiceTerritory.Name = \'' + String.escapeSingleQuotes(workCenter) + '\'');
                } else {
                    whereString.add('ServiceTerritoryId IN :serviceTerritoryIds');
                }
            }

            if (receiptDateFrom != null) {
                Datetime convertReceiptDateFrom = Datetime.valueOf(receiptDateFrom + ' ' + '00:00:00');
                whereString.add('Case.ApplicationDateTime__c >= ' + convertReceiptDateFrom.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + '');
            }
            if (receiptDateTo != null) {
                Datetime convertreceiptDateTo = Datetime.valueOf(receiptDateTo + ' ' + '00:00:00').addDays(1);
                whereString.add('Case.ApplicationDateTime__c <= ' + convertreceiptDateTo.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + '');
            }
            if (String.isNotBlank(orderNumber)) {
                whereString.add('ServiceOrderNumber__c = \'' + String.escapeSingleQuotes(orderNumber) + '\'');
            }
            if (String.isNotBlank(customerCode)) {
                whereString.add('Account.Name = \'' + String.escapeSingleQuotes(customerCode) + '\'');
            }
            if (String.isNotBlank(machineName)) {
                whereString.add('Asset.MachineName__c = \'' + String.escapeSingleQuotes(machineName) + '\'');
            }
            if (String.isNotBlank(assetName)) {
                whereString.add('Asset.Name = \'' + String.escapeSingleQuotes(assetName) + '\'');
            }
            if (String.isNotBlank(orderType)) {
                whereString.add('PMActivityType__c = \'' + String.escapeSingleQuotes(orderType) + '\'');
            }
            if (String.isNotBlank(worker)) {
                whereString.add('Worker__c = \'' + String.escapeSingleQuotes(worker) + '\'');
            }
            if (String.isNotBlank(ncType)) {
                whereString.add('Asset.NCType__c = \'' + String.escapeSingleQuotes(ncType) + '\'');
            }
            
            if (!whereString.isEmpty()) {
                queryString += String.join(whereString, ' AND ');
            }
            queryString += ' ORDER BY CreatedDate DESC LIMIT 2000';

            serviceHistoryList = Database.query(queryString);

            if (serviceHistoryList.isEmpty()) {
                resMap.put('flag', 'warning');
                resMap.put('message', 'No records found.');
                resMap.put('queryString', queryString);
            } else {
                resMap.put('flag', 'success');
                resMap.put('serviceHistoryList', serviceHistoryList);
                resMap.put('queryString', queryString);
            }
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }  

    /**
    * @description 서비스 이력 조회 (품번)
    * @author Chungwoo Lee | 12-27-2024 
    **/
    @AuraEnabled
    public static Map<String, Object> getCSServiceHistoryByPartNumber(Map<String, Object> searchData) {
        Map<String, Object> resMap = new Map<String, Object>();

        List<ServiceHistoryWrapper> serviceHistoryList = new List<ServiceHistoryWrapper>();

        Map<String, Object> loginUserWCList = getLoginUserWorkCenter();
        List<ServiceTerritory> getWCList = (List<ServiceTerritory>) loginUserWCList.get('wcList');

        Set<String> serviceTerritoryIds = new Set<String>();
        for (ServiceTerritory st : getWCList) {
            serviceTerritoryIds.add(st.Id);
        }
        
        String queryString = 'SELECT Id, WorkOrderNumber, ServiceOrderNumber__c, toLabel(OrderType__c) , toLabel(PMActivityType__c) , ConfirmedDate__c, ' +
            'Account.CustomerCode__c, Account.Name, PendingOrCustomerMatters__c, Asset.ShippingDate__c, Asset.MachineName__c, Asset.Name, Asset.FM_EquipmentWarrantyEquipmentParts__c, ' +
            'Case.CreatedDate, Case.ClosedDate, Case.ApplicationDateTime__c, Case.Description, Case.ReceptionDetails__c, Case.Owner.Name, Case.ResultOfMeasure__c, ' +
            'ServiceTerritory.Name, Worker__r.Name, Asset.NCType__c, ' +
            '(SELECT Id, ProductCode__c, Product__r.Name FROM ProductRequests) ' +
            'FROM WorkOrder WHERE Status != \'Canceled\' AND ServiceOrderNumber__c != null AND ';

        try {

            List<String> whereString = new List<String>();

            if(searchData.containsKey('receiptDateFrom') && searchData.get('receiptDateFrom') != null){
                String receiptDateFrom = (String)searchData.get('receiptDateFrom');
                if(String.isNotBlank(receiptDateFrom)){
                    Datetime dtFrom = Datetime.valueOf(receiptDateFrom + ' ' + '00:00:00');
                    whereString.add('Case.ApplicationDateTime__c >= ' + dtFrom.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                }
            }
            if(searchData.containsKey('receiptDateTo') && searchData.get('receiptDateTo') != null){
                String receiptDateTo = (String)searchData.get('receiptDateTo');
                if(String.isNotBlank(receiptDateTo)){
                    Datetime dtTo = Datetime.valueOf(receiptDateTo + ' ' + '00:00:00').addDays(1);
                    whereString.add('Case.ApplicationDateTime__c < ' + dtTo.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                }
            }
            if(searchData.containsKey('orderNumber')){
                String orderNumber = (String)searchData.get('orderNumber');
                if(String.isNotBlank(orderNumber)){
                    whereString.add('ServiceOrderNumber__c = \'' + String.escapeSingleQuotes(orderNumber) + '\'');
                }
            }
            if(searchData.containsKey('customerCode')){
                String customerCode = (String)searchData.get('customerCode');
                if(String.isNotBlank(customerCode)){
                    whereString.add('Account.CustomerCode__c = \'' + String.escapeSingleQuotes(customerCode) + '\'');
                }
            }
            if(searchData.containsKey('machineName')){
                String machineName = (String)searchData.get('machineName');
                if(String.isNotBlank(machineName)){
                    whereString.add('Asset.MachineName__c = \'' + String.escapeSingleQuotes(machineName) + '\'');
                }
            }
            if(searchData.containsKey('assetName')){
                String assetName = (String)searchData.get('assetName');
                if(String.isNotBlank(assetName)){
                    whereString.add('Asset.Name = \'' + String.escapeSingleQuotes(assetName) + '\'');
                }
            }
            if(searchData.containsKey('orderType')){
                String orderType = (String)searchData.get('orderType');
                if(String.isNotBlank(orderType)){
                    whereString.add('PMActivityType__c = \'' + String.escapeSingleQuotes(orderType) + '\'');
                }
            }
            if (!serviceTerritoryIds.isEmpty()) {
                String workCenter = (String)searchData.get('workCenter');
                if (String.isNotBlank(workCenter)) {
                    whereString.add('ServiceTerritory.Name = \'' + String.escapeSingleQuotes(workCenter) + '\'');
                } else {
                    whereString.add('ServiceTerritoryId IN :serviceTerritoryIds');
                }
            }
            if(searchData.containsKey('worker')){
                String worker = (String)searchData.get('worker');
                if(String.isNotBlank(worker)){
                    whereString.add('Worker__c = \'' + String.escapeSingleQuotes(worker) + '\'');
                }
            }
            if(searchData.containsKey('ncType')){
                String ncType = (String)searchData.get('ncType');
                if(String.isNotBlank(ncType)){
                    whereString.add('Asset.NCType__c = \'' + String.escapeSingleQuotes(ncType) + '\'');
                }
            }
            if(searchData.containsKey('productNumber')){
                String productNumber = (String)searchData.get('productNumber');
                if(String.isNotBlank(productNumber)){
                    whereString.add('Id IN (SELECT WorkOrderId FROM ProductRequest WHERE ProductCode__c = \'' + String.escapeSingleQuotes(productNumber) + '\')');
                }
            }

            if(!whereString.isEmpty()){
                queryString += String.join(whereString, ' AND ');
            }
            
            queryString += ' ORDER BY CreatedDate DESC LIMIT 2000';

            List<WorkOrder> workOrders = Database.query(queryString);
            
            for (WorkOrder wo : workOrders) {
                if (wo.ProductRequests != null && !wo.ProductRequests.isEmpty()) {
                    for (ProductRequest pr : wo.ProductRequests) {
                        ServiceHistoryWrapper wrapper = new ServiceHistoryWrapper();
                        
                        wrapper.accountName     = wo.Account != null && wo.Account.Name != null ? wo.Account.Name : ''; 
                        wrapper.pmActivityType  = wo.PMActivityType__c != null ? wo.PMActivityType__c : ''; 
                        wrapper.orderType       = wo.OrderType__c != null ? wo.OrderType__c : '';      
                        wrapper.createdDate     = wo.Case != null && wo.Case.CreatedDate != null ? String.valueOf(wo.Case.CreatedDate.format('yyyy-MM-dd')) : '';
                        wrapper.confirmedDate   = wo.ConfirmedDate__c != null ? String.valueOf(wo.ConfirmedDate__c.format('yyyy-MM-dd')) : '';
                        wrapper.warrantyType    = wo.Asset != null && wo.Asset.FM_EquipmentWarrantyEquipmentParts__c != null ? wo.Asset.FM_EquipmentWarrantyEquipmentParts__c : '';
                        wrapper.workCenter      = wo.ServiceTerritory != null && wo.ServiceTerritory.Name != null ? wo.ServiceTerritory.Name : '';
                        wrapper.orderNumber     = wo.ServiceOrderNumber__c != null ? wo.ServiceOrderNumber__c : '';
                        wrapper.assetModel      = wo.Asset != null && wo.Asset.MachineName__c != null ? wo.Asset.MachineName__c : '';
                        wrapper.assetName       = wo.Asset != null && wo.Asset.Name != null ? wo.Asset.Name : '';
                        wrapper.caseOwner       = wo.Case != null && wo.Case.Owner != null ? wo.Case.Owner.Name : '';
                        wrapper.receptionDetail = wo.Case != null && wo.Case.ReceptionDetails__c != null ? wo.Case.ReceptionDetails__c : '';
                        wrapper.actionDetail    = wo.PendingOrCustomerMatters__c != null ? wo.PendingOrCustomerMatters__c : '';
                        wrapper.worker          = wo.Worker__r != null && wo.Worker__r.Name != null ? wo.Worker__r.Name : '';
                        wrapper.ncType          = wo.Asset != null && wo.Asset.NCType__c != null ? wo.Asset.NCType__c : '';
                
                        wrapper.productCode     = pr.ProductCode__c != null ? pr.ProductCode__c : '';
                        wrapper.productName     = pr.Product__r != null && pr.Product__r.Name != null ? pr.Product__r.Name : '';
                        
                        serviceHistoryList.add(wrapper);
                    }
                } else {
                    // WorkOrder에 ProductRequest가 없는 경우
                    ServiceHistoryWrapper wrapper = new ServiceHistoryWrapper();
                    wrapper.accountName     = wo.Account != null && wo.Account.Name != null ? wo.Account.Name : ''; 
                    wrapper.pmActivityType  = wo.PMActivityType__c != null ? wo.PMActivityType__c : ''; 
                    wrapper.orderType       = wo.OrderType__c != null ? wo.OrderType__c : '';      
                    wrapper.createdDate     = wo.Case != null && wo.Case.CreatedDate != null ? String.valueOf(wo.Case.CreatedDate.format('yyyy-MM-dd')) : '';
                    wrapper.confirmedDate   = wo.ConfirmedDate__c != null ? String.valueOf(wo.ConfirmedDate__c.format('yyyy-MM-dd')) : '';
                    wrapper.warrantyType    = wo.Asset != null && wo.Asset.FM_EquipmentWarrantyEquipmentParts__c != null ? wo.Asset.FM_EquipmentWarrantyEquipmentParts__c : '';
                    wrapper.workCenter      = wo.ServiceTerritory != null && wo.ServiceTerritory.Name != null ? wo.ServiceTerritory.Name : '';
                    wrapper.orderNumber     = wo.ServiceOrderNumber__c != null ? wo.ServiceOrderNumber__c : '';
                    wrapper.assetModel      = wo.Asset != null && wo.Asset.MachineName__c != null ? wo.Asset.MachineName__c : '';
                    wrapper.assetName       = wo.Asset != null && wo.Asset.Name != null ? wo.Asset.Name : '';
                    wrapper.caseOwner       = wo.Case != null && wo.Case.Owner != null ? wo.Case.Owner.Name : '';
                    wrapper.receptionDetail = wo.Case != null && wo.Case.ReceptionDetails__c != null ? wo.Case.ReceptionDetails__c : '';
                    wrapper.actionDetail    = wo.PendingOrCustomerMatters__c != null ? wo.PendingOrCustomerMatters__c : '';
                    wrapper.worker          = wo.Worker__r != null && wo.Worker__r.Name != null ? wo.Worker__r.Name : '';
                    wrapper.ncType          = wo.Asset != null && wo.Asset.NCType__c != null ? wo.Asset.NCType__c : '';
                    
                    serviceHistoryList.add(wrapper);
                }
            }
            if (serviceHistoryList.isEmpty()) {
                resMap.put('flag', 'warning');
                resMap.put('message', 'No records found.');
                resMap.put('queryString', queryString);
            } else {
                resMap.put('flag', 'success');
                resMap.put('serviceHistoryList', serviceHistoryList);
                resMap.put('queryString', queryString);
            }
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }

    // 서비스 이력 조회 Wrapper
    public class ServiceHistoryWrapper {
        @AuraEnabled public String accountName      {get;set;} // 고객사
        @AuraEnabled public String pmActivityType   {get;set;} // 오더 유형
        @AuraEnabled public String orderType        {get;set;} // 오더 유형2
        @AuraEnabled public String createdDate      {get;set;} // 생성일자 (표시용)
        @AuraEnabled public String confirmedDate    {get;set;} // 확정처리일시
        @AuraEnabled public String warrantyType     {get;set;} // 보증 구분
        @AuraEnabled public String workCenter       {get;set;} // 워크 센터
        @AuraEnabled public String caseOwner        {get;set;} // 상담원
        @AuraEnabled public String orderNumber      {get;set;} // 오더 번호
        @AuraEnabled public String assetModel       {get;set;} // 기종
        @AuraEnabled public String assetName        {get;set;} // 장비번호
        @AuraEnabled public String receptionDetail  {get;set;} // 접수내용
        @AuraEnabled public String actionDetail     {get;set;} // 조치내역
        @AuraEnabled public String worker           {get;set;} // 작업자
        @AuraEnabled public String ncType           {get;set;} // NC Type
        @AuraEnabled public String productCode      {get;set;} // 부품번호
        @AuraEnabled public String productName      {get;set;} // 부품명    
    }

    /**
    * @description ResourceAbsenceList 목록을 조회
    * @author iltae.seo | 2024-11-28
    **/
    @AuraEnabled
    public static Map<String,Object> getList(String resource, String type, Date searchDate, PageReturn pageInfo){
        Map<String,Object> result = new Map<String,Object>();
        try {
            ServiceResource service = [SELECT Id, Service_Territory__c,IsActive FROM ServiceResource WHERE RelatedRecordId =: UserInfo.getUserId() LIMIT 500];
            String workCenter = service.Service_Territory__c;

            String seradchResource = '%' +resource+'%';
            String query = 'select Id,AbsenceNumber, ResourceId, Resource.Name, toLabel(Type) Type, format(Start) Start,format(End) End,Description from ResourceAbsence WHERE Resource.Service_Territory__c =:workCenter';
            if(String.isNotEmpty(resource)) {
                query += ' and Resource.Name LIKE :seradchResource ';
            }
            if(String.isNotEmpty(type)) {
                query += ' and Type=:type';
            }
            if(String.isNotEmpty(String.valueOf(searchDate))) {
                query += ' and (Day_Only(Start) >=:searchDate or Day_Only(End) =:searchDate)';
            }
            System.debug(searchDate + ' < ===searchDate');
            System.debug(query + ' < ===query');
            List<ResourceAbsence> resourceAbsenceList = database.query(query + ' ORDER BY AbsenceNumber DESC LIMIT 500');
            List<ResourceAbsence> returnList = new List<ResourceAbsence>();
            System.debug(resourceAbsenceList + ' < ===resourceAbsenceList');
            if(pageInfo == null) {
                pageInfo = new PageReturn();
                pageInfo.totalRecordSize = resourceAbsenceList.size();
            }
            setpageSetting(pageInfo);

            for(Integer i = pageInfo.startIdx-1; i < pageInfo.endIdx; i++) {
                if(i < resourceAbsenceList.size()) {
                    ResourceAbsence resources = resourceAbsenceList[i];
                    returnList.add(resources);
                }
            }

            System.debug(returnList + ' ::: returnList');
            result.put('returnList', returnList);
            result.put('pageInfo', pageInfo);
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description ResourceAbsenceList 생성
    * @author iltae.seo | 2024-11-28
    **/
    @AuraEnabled
    public static ResourceAbsence resourceAbsenceInsert(Resource res, Boolean isWorck){
        try {
            // 현재 시간 가져오기
            DateTime now = DateTime.now();
            // 현재 사용자의 타임존 가져오기
            TimeZone userTimeZone = UserInfo.getTimeZone();
            // 오프셋 계산 (밀리초 → 분 → 시간 변환)
            Integer offsetMinutes = userTimeZone.getOffset(now) / 60000; // 분 단위로 변환
            Integer offsetHours = offsetMinutes / 60; // 시간 단위로 변환

            ResourceAbsence resourceInsert = new ResourceAbsence();
            resourceInsert.ResourceId = res.resourceId;
            resourceInsert.Type = res.type;
            resourceInsert.Start = res.startDate.addHours(-offsetHours);
            resourceInsert.End  = res.endDate.addHours(-offsetHours);
            resourceInsert.Description  = res.description;
            if(isWorck) { // 지사
                resourceInsert.AccountName__c  = res.accountName;
                resourceInsert.Equipment__c  = res.equipment;
            } else { // 지사외
                resourceInsert.MachineName__c       = res.machineName;                        
                resourceInsert.EquipmentText__c     = res.equipmentText;                        
                resourceInsert.AccountNameText__c   = res.accountNameText;                            
                resourceInsert.AccountAddress__c    = res.accountAddress;                            
            }
            
            insert resourceInsert;
            return resourceInsert;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description ResourceAbsence 수정
    * @author iltae.seo | 2024-11-28
    **/
    @AuraEnabled
    public static ResourceAbsence resourceAbsenceUpdate(Resource resource, Boolean isWorck){
        try {
            System.debug(resource + ' < ==resource');
            System.debug(isWorck + ' < ==isWorck');
             // 현재 시간 가져오기
             DateTime now = DateTime.now();
             // 현재 사용자의 타임존 가져오기
             TimeZone userTimeZone = UserInfo.getTimeZone();
             // 오프셋 계산 (밀리초 → 분 → 시간 변환)
             Integer offsetMinutes = userTimeZone.getOffset(now) / 60000; // 분 단위로 변환
             Integer offsetHours = offsetMinutes / 60; // 시간 단위로 변환

            ResourceAbsence resourceUpdate = new ResourceAbsence();
            resourceUpdate.Id = resource.id;
            resourceUpdate.ResourceId = resource.resourceId;
            resourceUpdate.Type = resource.type;
            resourceUpdate.Start = resource.startDate;
            resourceUpdate.End  = resource.endDate;
            resourceUpdate.Description  = resource.description;
            if(isWorck) { 
                resourceUpdate.AccountName__c  = resource.accountName;
                resourceUpdate.Equipment__c  = resource.equipment;
            } else { 
                System.debug(resource.machineName + ' < ==resource.machineName');
                System.debug(resource.equipmentText + ' < ==resource.equipmentText');
                System.debug(resource.accountNameText + ' < ==resource.accountNameText');
                resourceUpdate.MachineName__c       = resource.machineName;                        
                resourceUpdate.EquipmentText__c     = resource.equipmentText;                        
                resourceUpdate.AccountNameText__c   = resource.accountNameText;                            
                resourceUpdate.AccountAddress__c    = resource.accountAddress;                            
            }
            update resourceUpdate;
            return resourceUpdate;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' < ==e.getMessage()');
            System.debug(e.getLineNumber() + ' < ==e.getLineNumber()');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description ResourceAbsence 삭제
    * @author iltae.seo | 2024-11-28
    **/
    @AuraEnabled
    public static void resourceAbsenceDelete(List<String> selected){
        try {
            List<ResourceAbsence> deleteResourceList = [select Id from ResourceAbsence where Id IN: selected];
            delete deleteResourceList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // 출동인원관리(부재) Wrapper
    public class Resource {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String resourceId {get;set;}
        @AuraEnabled public String resourceName {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public DateTime startDate {get;set;}
        @AuraEnabled public DateTime endDate {get;set;}
        @AuraEnabled public String equipmentText {get;set;}
        @AuraEnabled public String equipment {get;set;}
        @AuraEnabled public String accountNameText {get;set;}
        @AuraEnabled public String accountName {get;set;}
        @AuraEnabled public String machineName {get;set;}
        @AuraEnabled public String accountAddress {get;set;}
        public Resource() {}
        
        public Resource(ResourceAbsence reAb) {
            this.resourceId = reAb.ResourceId;
            this.resourceName = reAb.Resource.Name;
            this.type = reAb.Type;
            this.startDate = reAb.Start;
            this.endDate = reAb.End;
        }
    }

    /**
    * @description 장비번호 별 점검 이력 조회
    **/
    @AuraEnabled
    public static Map<String, Object> searchHistorybyAsset(Map<String, Object> fieldMap) {
        Map<String, Object> resMap = new Map<String, Object>();
        List<WorkOrder> serviceHistoryList = new List<WorkOrder>();

        Map<String, Object> loginUserWCList = getLoginUserWorkCenter();
        List<ServiceTerritory> getWCList = (List<ServiceTerritory>) loginUserWCList.get('wcList');

        Set<String> serviceTerritoryIds = new Set<String>();
        for (ServiceTerritory st : getWCList) {
            serviceTerritoryIds.add(st.Id);
        }
        
        try {
            String machineName      = (String) fieldMap.get('machineName');
            String assetName        = (String) fieldMap.get('assetName');
            String startDate        = (String) fieldMap.get('startDate');
            String endDate          = (String) fieldMap.get('endDate');

            List<String> whereString = new List<String>();

            if(String.isNotBlank(startDate)) {
                whereString.add('FM_LastServiceDate__c >= ' + startDate);
            }
            if(String.isNotBlank(endDate)) {
                whereString.add('FM_LastServiceDate__c <= ' + endDate);
            }                      
            
            if (!serviceTerritoryIds.isEmpty()) {
                whereString.add('ServiceTerritoryId IN :serviceTerritoryIds');
            }

            if (String.isNotBlank(machineName)) {
                whereString.add('Asset.MachineName__c = :machineName');
            }
            if (String.isNotBlank(assetName)) {
                whereString.add('Asset.Name = :assetName');
            }
            System.debug('whereString ::: ' +  JSON.serialize(whereString));
            String whereClause = whereString.isEmpty() ? '' : String.join(whereString, ' AND ');
            System.debug('whereClause ::: ' + JSON.serialize(whereClause));
            String queryString = 'SELECT Id, WorkOrderNumber, ServiceOrderNumber__c, CreatedDate, toLabel(OrderType__c), toLabel(PMActivityType__c), ' +
                                'FailureAreaValue__c, FailureAreaGroupValue__c, FailureArea__c, FailureAreaGroup__c, FailurePhenomenonValue__c, FailurePhenomenon__c, FailurePhenomenonDetail__c, '+
                                'CauseOfFailureValue__c, CauseOfFailure__c, CauseOfFailureDetail__c, RepairActionValue__c, RepairAction__c, PendingOrCustomerMatters__c, Case.ReceptionDetails__c, '+
                                'Account.Name, Account.Representative__c, Account.Phone, Asset.WarrantyStartDateWages__c, '+
                                'ConfirmedDate__c, InspectionDetails__c, Asset.WarrantyStartDate__c, Asset.WarrantyEnd__c, '+
                                'Asset.ShippingDate__c, Asset.MachineName__c, Asset.Name, Asset.FM_EquipmentWarrantyEquipmentParts__c, '+
                                'ApplicationDetails__c, ServiceTerritory.Name, Worker__r.Name, LastModifiedDate, FM_LastServiceDate__c FROM WorkOrder WHERE Status != \'Canceled\' AND ' +
                                whereClause +
                                ' ORDER BY FM_LastServiceDate__c DESC LIMIT 2000';
                                System.debug('queryString ::: ' +  JSON.serialize(queryString));

            serviceHistoryList = Database.query(queryString);

            System.debug('serviceHistoryList ::: ' + JSON.serialize(serviceHistoryList));

            if (serviceHistoryList.isEmpty()) {
                resMap.put('flag', 'warning');
                resMap.put('message', 'No records found.');
                resMap.put('queryString', queryString);
            } else {
                resMap.put('flag', 'success');
                resMap.put('serviceHistoryList', serviceHistoryList);
                resMap.put('queryString', queryString);
            }
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }

    /**
    * @description 장비 NC Type 픽리스트 조회 
    **/
    @AuraEnabled
    public static Map<String, Object> getpicklistValues() {
        Map<String, Object> resMap = new Map<String, Object>();
        List<PicklistWrapper>   picklistValues  = new List<PicklistWrapper>();
        try {
            Schema.DescribeFieldResult fieldResult      = Schema.SObjectType.Asset.fields.getMap().get('SRCH_NCType__c').getDescribe();
            List<Schema.PicklistEntry> picklistEntries  = fieldResult.getPicklistValues();
            
            if(UserInfo.getLanguage() == 'en_US') {
                picklistValues.add(new PicklistWrapper('ALL', ''));
            } else {
                picklistValues.add(new PicklistWrapper('선택', ''));
            }
            
            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistValues.add(new PicklistWrapper(entry.getLabel(), entry.getValue()));
            }

            System.debug('picklistValues ::: ' + picklistValues);

            resMap.put('picklistValues' , picklistValues);
            resMap.put('flag'           , 'success');
        } catch (Exception e) {
            System.debug('Error by Exception ::: ' + e.getMessage());
            throw new AuraHandledException(e.getStackTraceString() + ' ::: ' + e.getMessage());
        }
        return resMap;
    }
    public class PicklistWrapper {
        @AuraEnabled public String label  {get;set;} // Category__c Picklist Label
        @AuraEnabled public String value  {get;set;} // Category__c Picklist Value

        public PicklistWrapper(String Label, String Value) {
            this.label = Label;
            this.value = Value;
        }
    }

    public static void setpageSetting(PageReturn returnPages) {
        Integer startIdx = 0;
        Integer endIdx = 0;
        
        //페이지 클릭한 경우 처리로직 - 같은 경우 뒤로가기 또는 현재 페이지 클릭
        if(returnPages.currentPage == returnPages.nextPage) {
            startIdx = (returnPages.currentPage * returnPages.itemsPerPage);
            startIdx = (startIdx - returnPages.itemsPerPage); // + 1
            endIdx = (returnPages.nextPage*returnPages.itemsPerPage);    
        } else {
            returnPages.currentPage = returnPages.nextPage;
            startIdx = (returnPages.nextPage*returnPages.itemsPerPage -returnPages.itemsPerPage);
            endIdx = (returnPages.nextPage*returnPages.itemsPerPage);       
        }
        returnPages.startIdx = returnPages.currentPage ==1 ? 1 : startIdx;
        returnPages.endIdx =returnPages.currentPage ==1 ? returnPages.itemsPerPage : endIdx;
    }


    public class PageReturn {
        @AuraEnabled public Integer totalRecordSize { get; set; } // 전체 레코드 사이즈
        @AuraEnabled public Integer itemsPerPage { 
            get {
                if(itemsPerPage == null) itemsPerPage = 100;
                return itemsPerPage;
            }
            set; 
        } // 한 페이지당 표시할 데이터 수
        @AuraEnabled public Integer currentPage { 
            get {
                if(currentPage == null) currentPage = 1;
                return currentPage;
            }
            set; 
        } // 현재 페이지
        @AuraEnabled public Integer nextPage {
            get {
                if(nextPage == null) nextPage = currentPage;
                return nextPage;
            }
            set;
        }// 다음 페이지
        @AuraEnabled public Integer startIdx { // 시작인덱스
            get {
                if(startIdx == null) startIdx = 0;
                return startIdx;
            }
            set;
        } 
        @AuraEnabled public Integer endIdx {
            get {
                if(endIdx == null) endIdx = 0;
                return endIdx;
            }
            set;
        } // 마지막인덱스
        public PageReturn() {}
    }
}